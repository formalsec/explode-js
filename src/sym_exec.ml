open Bos
open Result

[@@@ocaml.warning "-21"]

module Env = Ecma_sl.Symbolic.P.Env
module Value = Ecma_sl.Symbolic.P.Value
module Choice = Ecma_sl.Symbolic.P.Choice
module Thread = Ecma_sl.Choice_monad.Thread
module Solver = Ecma_sl.Solver
module Extern_func = Ecma_sl.Symbolic.P.Extern_func

let ext_esl = ".esl"

let ext_cesl = ".cesl"

let ext_js = ".js"

let dispatch_file_ext on_plus on_core on_js (file : Fpath.t) =
  if Fpath.has_ext ext_esl file then Ok (on_plus file)
  else if Fpath.has_ext ext_cesl file then Ok (on_core file)
  else if Fpath.has_ext ext_js file then on_js file
  else Error (`Msg (Fmt.str "%a :unreconized file type" Fpath.pp file))

let prog_of_plus file =
  let open Ecma_sl in
  let file, path = (Fpath.filename file, Fpath.to_string file) in
  EParsing.load_file ~file path
  |> EParsing.parse_eprog ~file path
  |> Preprocessor.Imports.resolve_imports ~stdlib:Ecma_sl.Share.stdlib
  |> Preprocessor.Macros.apply_macros |> Compiler.compile_prog

let prog_of_core file =
  let file = Fpath.to_string file in
  Ecma_sl.Parsing.load_file file |> Ecma_sl.Parsing.parse_prog ~file

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

let link_env filename prog =
  let open Ecma_sl in
  let env0 = Env.Build.empty () |> Env.Build.add_functions prog in
  Env.Build.add_extern_functions (Symbolic_esl_ffi.extern_cmds env0) env0
  |> Env.Build.add_extern_functions Symbolic_esl_ffi.concrete_api
  |> Env.Build.add_extern_functions (Symbolic_esl_ffi.symbolic_api filename)

let pp_model fmt v = Yojson.pretty_print ~std:true fmt (Smtml.Model.to_json v)

let no_stop_at_failure = false

let from_file ~workspace filename =
  Ecma_sl.Log.Config.log_warns := true;
  (* Ecma_sl.Log.Config.log_debugs := true; *)
  let* prog = dispatch_file_ext prog_of_plus prog_of_core prog_of_js filename in
  let env = link_env filename prog in
  let start = Stdlib.Sys.time () in
  let thread = Thread.create () in
  let result = Ecma_sl.Symbolic_interpreter.main env "main" in
  let results = Choice.run result thread in
  let exec_time = Stdlib.Sys.time () -. start in
  let testsuite = Fpath.(workspace / "test-suite") in
  let* _ = OS.Dir.create ~mode:0o777 ~path:true testsuite in
  let rec print_and_count_failures (cnt, failures) results =
    match results () with
    | Seq.Nil -> Ok (cnt, failures)
    | Seq.Cons ((result, thread), tl) -> (
      match result with
      | Ok _ -> print_and_count_failures (cnt, failures) tl
      | Error (`Failure msg) -> Error (`Msg msg)
      | Error
          ( ( `Abort _ | `Assert_failure _ | `Eval_failure _ | `Exec_failure _
            | `ReadFile_failure _ ) as ty ) ->
        let cnt = succ cnt in
        let* witnesses = Sym_path_resolver.solve ty workspace thread in
        let failures = witnesses @ failures in
        if no_stop_at_failure then print_and_count_failures (cnt, failures) tl
        else Ok (cnt, failures) )
  in
  let* n, failures = print_and_count_failures (0, []) results in
  if n = 0 then Fmt.pr "All Ok!@." else Fmt.pr "Found %d problems!@." n;
  let solv_time = !Solver.solver_time in
  let solv_cnt = !Solver.solver_count in
  Ecma_sl.Log.debug "  exec time : %fs" exec_time;
  Ecma_sl.Log.debug "solver time : %fs" solv_time;
  Ok { Sym_result.filename; exec_time; solv_time; solv_cnt; failures }
