open Bos
open Ecma_sl_symbolic
include Symbolic_engine.Make (Sym_failure) ()

module Settings = struct
  type t =
    { deterministic : bool [@default false]
    ; lazy_values : bool
    ; timeout : int [@default 30]
    ; workspace_dir : string
    ; solver_type : Smtml.Solver_type.t
    ; path_only : bool
    ; input_file : string [@main]
    }
  [@@deriving make, show]
end

module Input = struct
  let ast_file_suffix = "_ast.cesl"

  let js2ecma_sl ~input_file ~output_file =
    let input_file = Fpath.to_string input_file in
    EslJSParser.Api.cmd ~output:(Fpath.to_string output_file) input_file

  let from_javascript_file file =
    let open Result.Syntax in
    let file = Fpath.of_string (Eio.Path.native_exn file) |> Result.get_ok in
    let ast_file = Fpath.(file -+ ast_file_suffix) in
    Fun.protect ~finally:(fun () -> ignore @@ OS.File.delete ast_file)
    @@ fun () ->
    let* () = OS.Cmd.run (js2ecma_sl ~input_file:file ~output_file:ast_file) in
    let* ast_content = OS.File.read ast_file in
    let build_ast = Ecma_sl.Parsing.parse_func ast_content in
    let prog = Ecma_sl.Share.nodejs_interp () |> Ecma_sl.Parsing.parse_prog in
    Hashtbl.replace (Ecma_sl.Prog.funcs prog)
      (Ecma_sl.Func.name' build_ast)
      build_ast;
    Ok prog

  let load_program file =
    let ext = Filename.extension (Eio.Path.native_exn file) in
    if String.equal ext ".js" then from_javascript_file file
    else Error (`Msg (Fmt.str "%a :unreconized file type" Eio.Path.pp file))
end

module Execution = struct
  let make_error_report (settings : Settings.t) exn_msg =
    let filename = Fpath.of_string settings.input_file |> Result.get_ok in
    let report =
      { Symbolic_result.filename
      ; execution_time = 0.
      ; solver_time = 0.
      ; solver_queries = 0
      ; num_failures = 1
      ; failures = []
      }
    in
    (Error (`Failure exn_msg), report)

  let run (settings : Settings.t) prog =
    let filename = Fpath.of_string settings.input_file |> Result.get_ok in
    let engine_settings =
      Symbolic_engine.Settings.make ~lazy_values:settings.lazy_values
        ~timeout:settings.timeout ~print_return_value:false
        ~solver_type:settings.solver_type
        ~memory_type:Symbolic_memory_type.Default ~filename prog
    in
    let workspace = Fpath.of_string settings.workspace_dir |> Result.get_ok in
    let testsuite_dir = Fpath.(workspace / "test-suite") in
    try
      run engine_settings ~callback_err:(fun thread ty ->
        let solver = Thread.solver thread in
        let pc =
          Thread.pc thread |> Symex.Path_condition.to_list
          |> List.fold_left Smtml.Expr.Set.union Smtml.Expr.Set.empty
        in
        let ty = Option.get ty in
        Sym_path_resolver.solve ~path_only:settings.path_only solver pc ty
          testsuite_dir )
    with exn -> make_error_report settings (Printexc.to_string exn)
end

module Reporting = struct
  let process_and_log_result (settings : Settings.t) report result =
    if not settings.deterministic then
      Logs.app (fun k ->
        k "[+] Symbolic execution stats: clock: %fs | solver: %fs"
          report.Symbolic_result.execution_time report.solver_time );
    match result with
    | Ok () ->
      assert (report.num_failures = 0);
      Logs.app (fun k -> k "[-] \u{2714} No issues detected.");
      Ok report
    | Error (`Failure msg) -> Error (`Msg msg)
    | Error _ (* Error from symbolic execution, we can ignore *) ->
      Logs.app (fun k ->
        k "[+] \u{26A0} Detected %d issue(s)!" report.num_failures );
      Ok report
end

let setup_environment ~fs (settings : Settings.t) =
  Ecma_sl.Log.Config.log_warns := true;
  (* Ecma_sl.Log.Config.log_debugs := true; *)
  Logs.app (fun k -> k "[+] Symbolic execution output:");
  let testsuite = Eio.Path.(fs / settings.workspace_dir / "test-suite") in
  Eio.Path.mkdirs ~exists_ok:true ~perm:0o777 testsuite

let run_file ~env settings =
  let open Result.Syntax in
  let fs = Eio.Stdenv.fs env in
  setup_environment ~fs settings;
  let* program = Input.load_program Eio.Path.(fs / settings.input_file) in
  let result, report = Execution.run settings program in
  Reporting.process_and_log_result settings report result
