open Bos
open Result
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
  let sharejs =
    match Sites.Share.nodejs with
    | hd :: _ -> hd
    | [] -> assert false
  in
  let node_path = OS.Env.opt_var "NODE_PATH" ~absent:"" in
  let node_path = Fmt.str "%s:.:%s:%a" node_path ws Fpath.pp sharejs in
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
    Fmt.pr "    running : %a@." Fpath.pp witness;
    let cmd = node test witness in
    let+ out, status = Cmd.(run_out ~env cmd |> out_string) in
    ( match status with
    | _, `Exited 0 -> ()
    | _, `Exited _ | _, `Signaled _ ->
      Logs.app (fun k -> k "unexpected node failure: %s" out) );
    List.find_opt
      (function
        | Replay_effect.Stdout sub -> String.find_sub ~sub out |> Option.is_some
        | File file -> begin
          match OS.File.exists file with
          | Ok file_exists -> file_exists
          | Error (`Msg err) -> Fmt.failwith "%s" err
        end
        | File_access file ->
          let { Unix.st_atime; st_ctime; _ } =
            Unix.stat (Fpath.to_string file)
          in
          Float.Infix.(st_atime > st_ctime)
        | Error str ->
          let sub = Fmt.str "Error: %s" str in
          String.find_sub ~sub out |> Option.is_some )
      observable_effects )

let generate_literal_test ?original_file scheme_path workspace witness =
  match scheme_path with
  | None -> ()
  | Some scheme_path ->
    let output = Fpath.(workspace / "literal") in
    let output = Fpath.to_string output in
    let witness = Fpath.to_string witness in
    let _ =
      Explode_js_instrument.Util.gen_literal_tmpls ~mode:0o666
        ?file:original_file scheme_path witness output
    in
    ()

let run ?original_file ?scheme_path filename workspace
  (sym_result : Sym_exec.Symbolic_result.t) =
  Logs.app (fun k -> k "  replaying : %a..." Fpath.pp filename);
  let* () = setup_npm_dependencies () in
  let* testsuite = OS.Dir.must_exist Fpath.(workspace / "test-suite") in
  let env = env testsuite in
  let failures = sym_result.failures in
  list_iter
    (fun { Sym_failure.model; exploit; _ } ->
      match model with
      | None -> Ok ()
      | Some { path = witness; _ } -> (
        generate_literal_test ?original_file scheme_path workspace witness;
        let+ effect_ = execute_witness ~env filename witness in
        match effect_ with
        | Some ((Stdout _ | File_access _ | Error _) as eff) ->
          Logs.app (fun k -> k "     status : true %a" Replay_effect.pp eff);
          exploit.success <- true;
          exploit.effect_ <- Some eff;
          ()
        | Some (File file as eff) ->
          let _ = OS.Path.delete file in
          Logs.app (fun k -> k "     status : true %a" Replay_effect.pp eff);
          exploit.success <- true;
          exploit.effect_ <- Some eff;
          ()
        | None -> Logs.app (fun k -> k "     status : false (no side effect).")
        ) )
    failures
