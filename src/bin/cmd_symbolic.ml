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
  let (file, path) = (Fpath.filename file, Fpath.to_string file) in
  EParsing.load_file ~file path
  |> EParsing.parse_eprog ~file path
  |> Preprocessor.Imports.resolve_imports
  |> Preprocessor.Macros.apply_macros
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

let pp_model fmt v =
  let open Smtml in
  let pp_mapping fmt (s, v) =
    Fmt.fprintf fmt {|"%a" : %a|} Symbol.pp s Value.pp v
  in
  let pp_vars fmt v =
    Fmt.pp_print_list
      ~pp_sep:(fun fmt () -> Fmt.fprintf fmt "@\n, ")
      pp_mapping fmt v
  in
  Fmt.fprintf fmt "@[<v 2>module.exports.symbolic_map =@ { %a@\n}@]" pp_vars
    (Model.get_bindings v)

let err_to_json = function
  | `Abort msg -> `Assoc [ ("type", `String "Abort"); ("sink", `String msg) ]
  | `Assert_failure v ->
    let v = Fmt.asprintf "%a" Value.pp v in
    `Assoc [ ("type", `String "Assert failure"); ("sink", `String v) ]
  | `Eval_failure v ->
    let v = Fmt.asprintf "%a" Value.pp v in
    `Assoc [ ("type", `String "Eval failure"); ("sink", `String v) ]
  | `Exec_failure v ->
    let v = Fmt.asprintf "%a" Value.pp v in
    `Assoc [ ("type", `String "Exec failure"); ("sink", `String v) ]
  | `ReadFile_failure v ->
    let v = Fmt.asprintf "%a" Value.pp v in
    `Assoc [ ("type", `String "ReadFile failure"); ("sink", `String v) ]
  | `Failure msg ->
    `Assoc [ ("type", `String "Failure"); ("sink", `String msg) ]

let serialize_thread =
  let module Term = Smtml.Expr in
  let mode = 0o666 in
  let (next_int, _) = Base.make_counter 0 1 in
  fun ?(witness :
         [ `Abort of string
         | `Assert_failure of Extern_func.value
         | `Eval_failure of Extern_func.value
         | `Exec_failure of Extern_func.value
         | `ReadFile_failure of Extern_func.value
         ]
         option ) workspace thread ->
    let pc = PC.to_list @@ Thread.pc thread in
    let solver = Thread.solver thread in
    match Solver.check solver pc with
    | `Unsat | `Unknown -> Ok ()
    | `Sat ->
      let m = Solver.model solver in
      let f =
        Fmt.ksprintf
          Fpath.(add_seg (workspace / "test-suite"))
          (match witness with None -> "testcase-%d" | Some _ -> "witness-%d")
          (next_int ())
      in
      let* () =
        OS.File.writef ~mode Fpath.(f + ".js") "%a" (Fmt.pp_opt pp_model) m
      in
      OS.File.writef ~mode Fpath.(f + ".smtml") "%a" Term.pp_smt pc

let write_report ~workspace filename exec_time solver_time solver_count problems
    =
  let mode = 0o666 in
  let json : Yojson.t =
    `Assoc
      [ ("filename", `String (Fpath.to_string filename))
      ; ("execution_time", `Float exec_time)
      ; ("solver_time", `Float solver_time)
      ; ("solver_queries", `Int solver_count)
      ; ("num_problems", `Int (List.length problems))
      ; ("problems", `List (List.map err_to_json problems))
      ]
  in
  let rpath = Fpath.(workspace / "symbolic-execution.json") in
  OS.File.writef ~mode rpath "%a" (Yojson.pretty_print ~std:true) json

let run ~workspace filename entry_func =
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
  let* problems =
    list_filter_map
      ~f:(fun (ret, thread) ->
        let+ witness =
          match ret with
          | Ok _ -> Ok None
          | Error
              ( ( `Abort _ | `Assert_failure _ | `Eval_failure _
                | `Exec_failure _ | `ReadFile_failure _ ) as err ) ->
            Ok (Some err)
          | Error (`Failure msg) -> Error (`Msg msg)
        in
        ( match serialize_thread ?witness workspace thread with
        | Error (`Msg msg) -> Log.log ~header:false "%s" msg
        | Ok () -> () );
        witness )
      results
  in
  let n = List.length problems in
  if n = 0 then Fmt.printf "All Ok!@." else Fmt.printf "Found %d problems!@." n;
  let solv_time = !Solver.solver_time in
  let solv_cnt = !Solver.solver_count in
  Log.debug "  exec time : %fs@." exec_time;
  Log.debug "solver time : %fs@." solv_time;
  write_report ~workspace filename exec_time solv_time solv_cnt problems

let main { filename; entry_func; workspace } () =
  match run ~workspace filename entry_func with
  | Error (`Msg s) ->
    Log.log ~header:false "%s" s;
    1
  | Ok () -> 0
