open Bos
open Result
open Explode_js_gen
module String = Astring.String

let npm_install = Cmd.(v "npm" % "i")

let node program_file = Cmd.(v "node" % p program_file)

let env =
  let sharejs = List.hd Sites.Share.nodejs in
  let node_path = OS.Env.opt_var "NODE_PATH" ~absent:"" in
  let node_path = Fmt.str "%s:.:%a" node_path Path.pp sharejs in
  String.Map.of_list [ ("NODE_PATH", node_path) ]

let setup_npm_dependencies () =
  let open Result.Syntax in
  let package_json = Path.(v "." / "package.json") in
  let* file_exists = OS.File.exists package_json in
  if not file_exists then Ok ()
  else
    let* _ = OS.Cmd.(run_out ~err:OS.Cmd.err_run_out npm_install |> out_null) in
    Ok ()

let generate_poc ~dir scheme model =
  let open Result.Syntax in
  let model = Model.from_smtml model in
  let poc = Exploit_templates.Literal.render model scheme in
  let poc_file = Path.(dir / "poc.js") in
  let* () = Bos.OS.File.writef poc_file "%s@." poc in
  Ok poc_file

let with_potential_effects f =
  let open Replay_effect in
  (* Don't care if these file operations fail *)
  let aux_file = Path.(v "./exploited") in
  let _ = OS.File.write aux_file "success\n" in
  Fun.protect ~finally:(fun () -> ignore (OS.File.delete aux_file)) @@ fun () ->
  f (File_access aux_file :: Replay_effect.defaults)

let run_node_file ~env file =
  let open Result.Syntax in
  let cmd = node file in
  let err_file = Path.add_ext ".stderr" file in
  let out_file = Path.add_ext ".stdout" file in
  let run_result =
    OS.Cmd.run_out ~env ~err:(OS.Cmd.err_file err_file) cmd
    |> OS.Cmd.out_file out_file
  in
  let status_result =
    let+ (), status = run_result in
    status
  in
  let* err_output = OS.File.read err_file in
  let+ out_output = OS.File.read out_file in
  (status_result, out_output, err_output)

let check_poc_effects out_output err_output potential_effects =
  let visiable_effect = function
    | Replay_effect.Stdout sub ->
      String.find_sub ~sub out_output |> Option.is_some
    | File file ->
      begin match OS.File.exists file with
      | Ok file_exists -> file_exists
      | Error (`Msg err) -> Fmt.failwith "%s" err
      end
    | File_access file ->
      let { Unix.st_atime; st_ctime; _ } = Unix.stat (Path.to_string file) in
      st_atime > st_ctime
    | Error str ->
      let sub = Fmt.str "Error: %s" str in
      String.find_sub ~sub err_output |> Option.is_some
  in
  List.find_opt visiable_effect potential_effects

let execute_and_check_poc ~env poc_file =
  let open Result.Syntax in
  with_potential_effects @@ fun potential_effects ->
  let+ status_result, out_output, err_output = run_node_file ~env poc_file in
  let eff = check_poc_effects out_output err_output potential_effects in
  (status_result, eff)

let log_and_cleanup_effect eff =
  match eff with
  | Some eff -> begin
    let () =
      match eff with
      | Replay_effect.File file -> ignore @@ OS.Path.delete file
      | _ -> ()
    in
    Logs.app (fun k -> k "[+] \u{2714} Status: Success %a" Replay_effect.pp eff);
    Some eff
    end
  | None ->
    Logs.app (fun k -> k "[-] \u{2716} Status: No side effect");
    None

let test_model_exploit ~dir scheme model =
  let open Result.Syntax in
  Logs.app (fun k ->
    k "[+] \u{1F4C4} Trying model :@\n %a"
      (Smtml.Model.pp ~no_values:false)
      model );
  let* () = setup_npm_dependencies () in
  let* poc_file = generate_poc ~dir scheme model in
  let+ status_result, eff = execute_and_check_poc ~env poc_file in
  match status_result with
  | Ok (_, status) -> begin
    Logs.app (fun k -> k "[+] \u{1F4C4} Node %a" OS.Cmd.pp_status status);
    let final_effect = log_and_cleanup_effect eff in
    Option.map (fun eff -> (poc_file, eff)) final_effect
    end
  | Error (`Msg err) -> begin
    Logs.app (fun k -> k "[-] \u{1F4C4} Node: %s" err);
    None
    end

let find_exploitable_model ~dir scheme (model : Sym_failure.t) =
  let open Option.Syntax in
  let* model = model.model in
  let* result = test_model_exploit ~dir scheme model.data |> Result.to_option in
  result

(* let run_server ~workspace_dir server_file scheme *)
(*   (sym_result : Sym_exec.Symbolic_result.t) = *)
(*   let open Result.Syntax in *)
(*   let* () = setup_npm_dependencies () in *)
(*   let* testsuite_dir = OS.Dir.must_exist Path.(workspace_dir / "test-suite") in *)
(*   let env = env testsuite_dir in *)
(*   let i = ref 0 in *)
(*   let failures = sym_result.failures in *)
(*   let n = List.length failures in *)
(*   if n = 0 then Ok () *)
(*   else begin *)
(*     Logs.app (fun k -> k "│   ├── \u{21BA} Replaying %d test case(s)" n); *)
(*     list_iter *)
(*       (fun { Sym_failure.model; exploit; _ } -> *)
(*         incr i; *)
(*         match model with *)
(*         | None -> Ok () *)
(*         | Some { path = witness_file; _ } -> *)
(*           Logs.app (fun k -> *)
(*             k "│   │   ├── \u{1F4C4} [%d/%d] Using test case: %a" !i n Path.pp *)
(*               witness_file ); *)
(*           let pid = Unix.fork () in *)
(*           if pid = 0 then begin *)
(*             (1* Set the PGID the same as pid's *1) *)
(*             ExtUnix.Specific.setpgid 0 0; *)
(*             (1* Launch server in the child *1) *)
(*             let cmd = node1 server_file in *)
(*             match Bos.OS.Cmd.(run_out ~env cmd |> to_null) with *)
(*             | Ok () -> exit 0 *)
(*             | Error (`Msg err) -> Fmt.failwith "%s" err *)
(*           end *)
(*           else begin *)
(*             (1* Generate client test, and run it *1) *)
(*             let result = *)
(*               let* client_file = *)
(*                 Explode_js_gen.Test.Literal.generate_client workspace_dir *)
(*                   witness_file scheme !i *)
(*               in *)
(*               Unix.sleepf 0.100; *)
(*               execute_witness ~env client_file witness_file *)
(*             in *)
(*             (1* Don't need the child anymore, so clean it up. *1) *)
(*             Unix.kill ~-pid Sys.sigkill; *)
(*             let waited_pid, _status = Unix.waitpid [] ~-pid in *)
(*             (1* Sanity check *1) *)
(*             assert (waited_pid = pid); *)
(*             let+ status, effect_ = result in *)
(*             begin *)
(*               match status with *)
(*               | Ok (_, status) -> *)
(*                 Logs.app (fun k -> *)
(*                   k "│   │   │   ├── Node %a" OS.Cmd.pp_status status ) *)
(*               | Error (`Msg err) -> *)
(*                 Logs.app (fun k -> k "│   │   │   ├── Node: %s" err) *)
(*             end; *)
(*             let _ = check_effect exploit effect_ in *)
(*             () *)
(*           end ) *)
(*       failures *)
(*   end *)
