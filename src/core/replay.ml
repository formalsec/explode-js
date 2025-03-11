open Bos
open Result
module String = Astring.String

let npm_install = Cmd.(v "npm" % "i")

let node1 program_file = Cmd.(v "node" % p program_file)

let node2 test_file witness_file = Cmd.(v "node" % p test_file % p witness_file)

let setup_npm_dependencies () =
  let pkg_json = Fpath.(v "." / "package.json") in
  let* file_exists = OS.File.exists pkg_json in
  if not file_exists then Ok ()
  else
    let run_out = OS.Cmd.run_out ~err:OS.Cmd.err_run_out npm_install in
    let* _ = OS.Cmd.out_null run_out in
    Ok ()

let env testsuite_dir =
  let ws = Unix.realpath @@ Fpath.to_string testsuite_dir in
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

let execute_witness ~env (test_file : Fpath.t) (witness_file : Fpath.t) =
  let open OS in
  with_effects @@ fun potential_effects ->
  let cmd = node2 test_file witness_file in
  let err_fpath = Fpath.add_ext ".stderr" witness_file in
  let err = Cmd.err_file err_fpath in
  let out_fpath = Fpath.add_ext ".stdout" witness_file in
  let* (), status = Cmd.(run_out ~env ~err cmd |> out_file out_fpath) in
  let* err = OS.File.read err_fpath in
  let+ out = OS.File.read out_fpath in
  let visiable_effect = function
    | Replay_effect.Stdout sub -> String.find_sub ~sub out |> Option.is_some
    | File file -> begin
      match OS.File.exists file with
      | Ok file_exists -> file_exists
      | Error (`Msg err) -> Fmt.failwith "%s" err
    end
    | File_access file ->
      let { Unix.st_atime; st_ctime; _ } = Unix.stat (Fpath.to_string file) in
      Float.Infix.(st_atime > st_ctime)
    | Error str ->
      let sub = Fmt.str "Error: %s" str in
      String.find_sub ~sub err |> Option.is_some
  in
  let effect_ = List.find_opt visiable_effect potential_effects in
  (status, effect_)

let generate_literal_test ?original_file workspace_dir scheme_file scheme
  witness_file i =
  match (scheme_file, scheme) with
  | Some scheme_file, Some scheme ->
    let _ =
      Explode_js_instrument.Test.Literal.generate_single ~mode:0o666
        ?original_file ~workspace_dir witness_file scheme_file scheme i
    in
    ()
  | (None | Some _), _ -> ()

let check_effect (exploit : Sym_failure.exploit) effect_ =
  match effect_ with
  | Some ((Replay_effect.Stdout _ | File_access _ | Error _) as eff) ->
    Logs.app (fun k ->
      k "│   │   │   └── \u{2714} Status: Success %a" Replay_effect.pp eff );
    exploit.success <- true;
    exploit.effect_ <- Some eff
  | Some (File file as eff) ->
    let _ = OS.Path.delete file in
    Logs.app (fun k ->
      k "│   │   │   └── \u{2714} Status: Success %a" Replay_effect.pp eff );
    exploit.success <- true;
    exploit.effect_ <- Some eff
  | None ->
    Logs.app (fun k -> k "│   │   │   └── \u{2716} Status: No side effect" )

let run_single ?original_file ?scheme_file ?scheme ~workspace_dir input_file
  (sym_result : Sym_exec.Symbolic_result.t) =
  let* () = setup_npm_dependencies () in
  let* testsuite_dir = OS.Dir.must_exist Fpath.(workspace_dir / "test-suite") in
  let env = env testsuite_dir in
  let i = ref 0 in
  let failures = sym_result.failures in
  let n = List.length failures in
  if n = 0 then Ok ()
  else begin
    Logs.app (fun k -> k "│   ├── \u{21BA} Replaying %d test case(s)" n);
    list_iter
      (fun { Sym_failure.model; exploit; _ } ->
        incr i;
        match model with
        | None -> Ok ()
        | Some { path = witness; _ } ->
          Logs.app (fun k ->
            k "│   │   ├── \u{1F4C4} [%d/%d] Using test case: %a" !i n Fpath.pp
              witness );
          generate_literal_test ?original_file workspace_dir scheme_file scheme
            witness !i;
          let+ (_, status), effect_ = execute_witness ~env input_file witness in
          Logs.app (fun k ->
            k "│   │   │   ├── Node %a" OS.Cmd.pp_status status );
          check_effect exploit effect_ )
      failures
  end

let run_server ~workspace_dir server_file scheme
  (sym_result : Sym_exec.Symbolic_result.t) =
  let* () = setup_npm_dependencies () in
  let* testsuite_dir = OS.Dir.must_exist Fpath.(workspace_dir / "test-suite") in
  let env = env testsuite_dir in
  let i = ref 0 in
  let failures = sym_result.failures in
  let n = List.length failures in
  if n = 0 then Ok ()
  else begin
    Logs.app (fun k -> k "│   ├── \u{21BA} Replaying %d test case(s)" n);
    list_iter
      (fun { Sym_failure.model; exploit; _ } ->
        incr i;
        match model with
        | None -> Ok ()
        | Some { path = witness_file; _ } ->
          Logs.app (fun k ->
            k "│   │   ├── \u{1F4C4} [%d/%d] Using test case: %a" !i n Fpath.pp
              witness_file );
          let pid = Unix.fork () in
          if pid = 0 then begin
            (* Set the PGID the same as pid's *)
            ExtUnix.Specific.setpgid 0 0;
            (* Launch server in the child *)
            let cmd = node1 server_file in
            match Bos.OS.Cmd.(run_out ~env cmd |> to_null) with
            | Ok () -> exit 0
            | Error (`Msg err) -> Fmt.failwith "%s" err
          end
          else begin
            (* Generate client test, and run it *)
            let result =
              let* client_file =
                Explode_js_instrument.Test.Literal.generate_client workspace_dir
                  witness_file scheme !i
              in
              Unix.sleepf 0.100;
              execute_witness ~env client_file witness_file
            in
            (* Don't need the child anymore, so clean it up. *)
            Unix.kill ~-pid Sys.sigkill;
            let waited_pid, _status = Unix.waitpid [] ~-pid in
            (* Sanity check *)
            assert (waited_pid = pid);
            let* (_, status), effect_ = result in
            Logs.app (fun k ->
              k "│   │   │   ├── Node %a" OS.Cmd.pp_status status );
            check_effect exploit effect_;
            Ok ()
          end )
      failures
  end
