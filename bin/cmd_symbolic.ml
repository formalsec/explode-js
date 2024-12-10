open Bos
open Ecma_sl
open Ecma_sl.Syntax.Result
module PC = Choice_monad.PC
module Env = Symbolic.P.Env
module Value = Symbolic.P.Value
module Choice = Symbolic.P.Choice
module Thread = Choice_monad.Thread
module Translator = Value_translator
module Extern_func = Symbolic.P.Extern_func

let ext_esl = ".esl"

let ext_cesl = ".cesl"

let ext_js = ".js"

type options =
  { filename : Fpath.t
  ; entry_func : string
  ; workspace : Fpath.t
  }

let options filename entry_func workspace = { filename; entry_func; workspace }

let dispatch_file_ext on_plus on_core on_js (file : Fpath.t) =
  if Fpath.has_ext ext_esl file then Ok (on_plus file)
  else if Fpath.has_ext ext_cesl file then Ok (on_core file)
  else if Fpath.has_ext ext_js file then on_js file
  else Error (`Msg (Fmt.asprintf "%a :unreconized file type" Fpath.pp file))

let prog_of_plus file =
  let file, path = (Fpath.filename file, Fpath.to_string file) in
  EParsing.load_file ~file path
  |> EParsing.parse_eprog ~file path
  |> Preprocessor.Imports.resolve_imports |> Preprocessor.Macros.apply_macros
  |> Compiler.compile_prog

let prog_of_core file =
  let file = Fpath.to_string file in
  Parsing.load_file file |> Parsing.parse_prog ~file

let prog_of_js file =
  let js2ecma_sl file output =
    Cmd.(v "js2ecma-sl" % "-s" % "-c" % "-i" % p file % "-o" % p output)
  in
  let ast_file = Fpath.(file -+ "_ast.cesl") in
  let* () = OS.Cmd.run (js2ecma_sl file ast_file) in
  let* ast = OS.File.read ast_file in
  let* es6 = OS.File.read (Fpath.v (Option.get (Share.es6_interp ()))) in
  let program = String.concat ";\n" [ ast; es6 ] in
  let+ () = OS.File.delete ast_file in
  Parsing.parse_prog program

let link_env ~extern filename prog =
  let env0 = Env.Build.empty () |> Env.Build.add_functions prog in
  Env.Build.add_extern_functions (extern filename env0) env0

let pp_model fmt v = Yojson.pretty_print ~std:true fmt (Smtml.Model.to_json v)

let serialize_thread =
  let module Term = Smtml.Expr in
  fun (witness : Sym_failure_type.t) workspace thread ->
    let pc = PC.to_list @@ Thread.pc thread in
    let solver = Thread.solver thread in
    let model =
      match Solver.check solver pc with
      | `Unsat | `Unknown -> None
      | `Sat -> Solver.model solver
    in
    let* pc_path, model = Sym_failure.serialize workspace pc model in
    let exploit = Sym_failure.default_exploit () in
    Ok { Sym_failure.ty = witness; pc; pc_path; model; exploit}

let no_stop_at_failure = false

let run ~workspace ~filename ~entry_func =
  let open Syntax.Result in
  let* prog = dispatch_file_ext prog_of_plus prog_of_core prog_of_js filename in
  let env = link_env ~extern:Symbolic_extern.api filename prog in
  let start = Stdlib.Sys.time () in
  let thread = Choice_monad.Thread.create () in
  let result = Symbolic_interpreter.main env entry_func in
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
            | `ReadFile_failure _ ) as witness ) ->
        let cnt = succ cnt in
        let* failure = serialize_thread witness workspace thread in
        let failures = failure :: failures in
        if no_stop_at_failure then print_and_count_failures (cnt, failures) tl
        else Ok (cnt, failures) )
  in
  let* n, failures = print_and_count_failures (0, []) results in
  if n = 0 then Fmt.printf "All Ok!@." else Fmt.printf "Found %d problems!@." n;
  let solv_time = !Solver.solver_time in
  let solv_cnt = !Solver.solver_count in
  Log.debug "  exec time : %fs@." exec_time;
  Log.debug "solver time : %fs@." solv_time;
  let res = { Sym_result.filename; exec_time; solv_time; solv_cnt; failures } in
  Ok res
