open Bos
open Ecma_sl
open Ecma_sl.Syntax.Result
module String = Astring.String

let npmi = Cmd.(v "npm" % "i")

let node test witness = Cmd.(v "node" % p test % p witness)

let setup_npm_dependencies () =
  let pkg_json = Fpath.(v "." / "package.json") in
  let* file_exists = OS.File.exists pkg_json in
  if not file_exists then Ok ()
  else
    let run_out = OS.Cmd.run_out ~err:OS.Cmd.err_run_out npmi in
    let* _ = OS.Cmd.out_null run_out in
    Ok ()

let env testsuite =
  let ws = Unix.realpath @@ Fpath.to_string testsuite in
  let sharejs = List.hd Sites.Share.nodejs in
  let node_path = OS.Env.opt_var "NODE_PATH" ~absent:"" in
  let node_path = Fmt.asprintf "%s:.:%s:%s" node_path ws sharejs in
  String.Map.of_list [ ("NODE_PATH", node_path) ]

let with_effects f =
  let open Replay_effect in
  (* Don't care if these file operations fail *)
  let exploit_file = Fpath.(v "./exploited") in
  let _ = OS.File.write exploit_file "success\n" in
  let result = f (File_access exploit_file :: Replay_effect.defaults) in
  let _ = OS.File.delete exploit_file in
  result

let execute_witness ~env (test : Fpath.t) (witness : Fpath.t) =
  let open OS in
  with_effects (fun observable_effects ->
    Log.app "    running : %a" Fpath.pp witness;
    let cmd = node test witness in
    let+ out, status = Cmd.(run_out ~env cmd |> out_string) in
    ( match status with
    | _, `Exited 0 -> ()
    | _, `Exited _ | _, `Signaled _ ->
      Fmt.printf "unexpected node failure: %s" out );
    List.find_opt
      (fun effect ->
        match effect with
        | Replay_effect.Stdout sub -> String.find_sub ~sub out |> Option.is_some
        | File file -> Sys.file_exists file
        | File_access file ->
          let stats = Unix.stat (Fpath.to_string file) in
          stats.Unix.st_atime > stats.Unix.st_ctime
        | Error str ->
          let sub = Format.sprintf "Error: %s" str in
          String.find_sub ~sub out |> Option.is_some )
      observable_effects )

let generate_literal_test ?original_file taint_summary workspace witness =
  match taint_summary with
  | None -> ()
  | Some taint_summary ->
    let output = Fpath.(workspace / "literal") in
    let output = Fpath.to_string output in
    let witness = Fpath.to_string witness in
    let _ =
      Instrumentation.Run.literal ~mode:0o666 ?file:original_file taint_summary
        witness output
    in
    ()

let run ?original_file ?taint_summary filename workspace sym_result =
  Log.app "  replaying : %a..." Fpath.pp filename;
  let* () = setup_npm_dependencies () in
  let* testsuite = OS.Dir.must_exist Fpath.(workspace / "test-suite") in
  let env = env testsuite in
  let failures = sym_result.Sym_result.failures in
  list_iter failures ~f:(fun { Sym_failure.model; exploit; _ } ->
    match model with
    | None -> Ok ()
    | Some { path = witness; _ } -> (
      generate_literal_test ?original_file taint_summary workspace witness;
      let+ effect = execute_witness ~env filename witness in
      match effect with
      | Some ((Stdout _ | File_access _ | Error _) as effect) ->
        Log.app "     status : true %a" Replay_effect.pp effect;
        exploit.success <- true;
        exploit.effect <- Some effect;
        ()
      | Some (File file as effect) ->
        ignore @@ OS.Path.delete (Fpath.v file);
        Log.app "     status : true %a" Replay_effect.pp effect;
        exploit.success <- true;
        exploit.effect <- Some effect;
        ()
      | None -> Log.app "     status : false (no side effect)" ) )
