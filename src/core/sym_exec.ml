open Bos
open Result
include Ecma_sl_symbolic.Symbolic_interpreter.Make (Sym_failure) ()

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

let pp_model fmt v = Yojson.pretty_print ~std:true fmt (Smtml.Model.to_json v)

let from_file ~workspace filename =
  Ecma_sl.Log.Config.log_warns := true;
  (* Ecma_sl.Log.Config.log_debugs := true; *)
  let* prog = dispatch_file_ext prog_of_js filename in
  let testsuite = Fpath.(workspace / "test-suite") in
  let* _ = OS.Dir.create ~mode:0o777 ~path:true testsuite in
  let result, report =
    run ~no_stop_at_failure:false
      ~out_cb:(fun _ _ -> ())
      ~err_cb:(fun thread ty -> Sym_path_resolver.solve ty testsuite thread)
      filename prog
  in
  Logs.debug (fun k -> k "  exec time : %fs" report.execution_time);
  Logs.debug (fun k -> k "solver time : %fs" report.solver_time);
  match result with
  | Ok () ->
    assert (report.num_failures = 0);
    Logs.app (fun k -> k "All Ok!");
    Ok report
  | Error (`Failure msg) -> Error (`Msg msg)
  | Error _ (* Error from symbolic execution, we can ignore *) ->
    Logs.app (fun k -> k "Found %d problems!" report.num_failures);
    Ok report
