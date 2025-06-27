open Bos
open Result
open Ecma_sl_symbolic
module Symbolic_memory = Symbolic_memory.Make (Symbolic_object_default)
include Symbolic_engine.Make (Symbolic_memory) (Sym_failure) ()

let dispatch_file_ext on_js (file : Fpath.t) =
  if Fpath.has_ext ".js" file then on_js file
  else Error (`Msg (Fmt.str "%a :unreconized file type" Fpath.pp file))

let prog_of_js file =
  let js2ecma_sl file output =
    Cmd.(v "js2ecma-sl" % "-s" % "-c" % "-i" % p file % "-o" % p output)
  in
  let ast_file = Fpath.(file -+ "_ast.cesl") in
  let* () = OS.Cmd.run (js2ecma_sl file ast_file) in
  let* ast = OS.File.read ast_file in
  let es6 = Ecma_sl.Share.es6_sym_interp () in
  let program = String.concat ";\n" [ ast; es6 ] in
  let+ () = OS.File.delete ast_file in
  Ecma_sl.Parsing.parse_prog program

let print_model fmt model =
  Yojson.pretty_print ~std:true fmt (Smtml.Model.to_json model)

let print_report fmt report =
  Yojson.pretty_print ~std:true fmt (Symbolic_result.to_json report)

let dummy_report input_file =
  { Symbolic_result.filename = input_file
  ; execution_time = 0.
  ; solver_time = 0.
  ; solver_queries = 0
  ; num_failures = 1
  ; failures = []
  }

let run_file ~deterministic ~lazy_values ~workspace_dir input_file =
  Ecma_sl.Log.Config.log_warns := true;
  (* Ecma_sl.Log.Config.log_debugs := true; *)
  Logs.app (fun k -> k "├── Symbolic execution output:");
  let* prog = dispatch_file_ext prog_of_js input_file in
  let testsuite = Fpath.(workspace_dir / "test-suite") in
  let* _ = OS.Dir.create ~mode:0o777 ~path:true testsuite in
  let result, report =
    try
      run ~lazy_values ~timeout:30 ~print_return_value:false
        ~no_stop_at_failure:false
        ~solver_type:Smtml.Solver_type.Z3_solver
        ~callback_out:(fun _ _ -> ())
        ~callback_err:(fun thread ty ->
          let solver = Choice.solver thread in
          let pc = Choice.pc thread in
          Sym_path_resolver.solve solver pc ty testsuite )
        input_file prog
    with exn ->
      (Error (`Failure (Printexc.to_string exn)), dummy_report input_file)
  in
  if not deterministic then
    Logs.app (fun k ->
      k "├── Symbolic execution stats: clock: %fs | solver: %fs"
        report.execution_time report.solver_time );
  match result with
  | Ok () ->
    assert (report.num_failures = 0);
    Logs.app (fun k -> k "└── \u{2714} No issues detected.");
    Ok report
  | Error (`Failure msg) -> Error (`Msg msg)
  | Error _ (* Error from symbolic execution, we can ignore *) ->
    Logs.app (fun k ->
      k "├── \u{26A0} Detected %d issue(s)!" report.num_failures );
    Ok report
