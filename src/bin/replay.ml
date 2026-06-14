open Bos
open Explode_js_gen
module String = Astring.String

let get_node_path () = try Unix.getenv "NODE_PATH" with Not_found -> ""

let get_full_env custom_vars =
  let parent_env = Unix.environment () in
  Array.append parent_env (Array.of_list custom_vars)

let replay_env =
  let sharejs = List.hd Sites.Share.nodejs in
  let node_path = get_node_path () in
  get_full_env [ Fmt.str "NODE_PATH=%s:.:%a" node_path Path.pp sharejs ]

let setup_npm_dependencies env =
  let open Eio in
  let fs = Stdenv.fs env in
  let proc_mgr = Stdenv.process_mgr env in
  let package_lock_json = Path.(fs / "./package-lock.json") in
  Path.with_open_out ~create:`Never Path.(fs / "/dev/null") @@ fun dev_null ->
  if Path.is_file package_lock_json then
    Process.run ~stderr:dev_null ~stdout:dev_null proc_mgr [ "npm"; "ci" ]
  else
    let package_json = Path.(fs / "./package.json") in
    if Path.is_file package_json then
      Process.run ~stderr:dev_null ~stdout:dev_null proc_mgr [ "npm"; "i" ]

let generate_poc ~dir scheme model =
  let model = Model.from_smtml model in
  let poc = Exploit_templates.Literal.render model scheme in
  let poc_file = Eio.Path.(dir / "poc.js") in
  Eio.Path.save ~create:(`Or_truncate 0o644) poc_file poc;
  poc_file

let with_potential_effects fs f =
  let open Replay_effect in
  (* Don't care if these file operations fail *)
  let aux_file = Eio.Path.(fs / "./exploited") in
  Eio.Path.save ~create:(`Or_truncate 0o644) aux_file "success\n";
  Fun.protect ~finally:(fun () -> Eio.Path.unlink aux_file) @@ fun () ->
  f
    (let p = Path.of_string (Eio.Path.native_exn aux_file) |> Result.get_ok in
     File_access p :: Replay_effect.defaults )

let run_node_file ~fs ~proc_mgr ~env file =
  let open Eio in
  let native_file = Path.native_exn file in
  let out_file = Path.(fs / (native_file ^ ".stdout")) in
  let err_file = Path.(fs / (native_file ^ ".stderr")) in
  let result =
    Path.with_open_out ~create:(`Or_truncate 0o644) out_file @@ fun stdout ->
    Path.with_open_out ~create:(`Or_truncate 0o644) err_file @@ fun stderr ->
    Switch.run @@ fun sw ->
    let proc =
      Process.spawn ~sw proc_mgr ~stdout ~stderr ~env [ "node"; native_file ]
    in
    Process.await proc
  in
  (result, Path.load out_file, Path.load err_file)

let check_poc_effects ~fs out_output err_output potential_effects =
  let open Eio in
  let visiable_effect = function
    | Replay_effect.Stdout sub ->
      String.find_sub ~sub out_output |> Option.is_some
    | File file -> Path.(is_file (fs / Fpath.to_string file))
    | File_access file ->
      let { File.Stat.atime; ctime; _ } =
        Path.(stat ~follow:false (fs / Fpath.to_string file))
      in
      atime > ctime
    | Error str ->
      let sub = Fmt.str "Error: %s" str in
      String.find_sub ~sub err_output |> Option.is_some
  in
  List.find_opt visiable_effect potential_effects

let execute_and_check_poc ~fs ~proc_mgr ~env poc_file =
  with_potential_effects fs @@ fun potential_effects ->
  let status, out_output, err_output =
    run_node_file ~fs ~proc_mgr ~env poc_file
  in
  let eff = check_poc_effects ~fs out_output err_output potential_effects in
  (status, eff)

let log_and_cleanup_effect ~fs eff =
  match eff with
  | Some eff -> begin
    let () =
      match eff with
      | Replay_effect.File file -> Eio.Path.(unlink (fs / Fpath.to_string file))
      | _ -> ()
    in
    Logs.app (fun k -> k "[+] \u{2714} Status: Success %a" Replay_effect.pp eff);
    Some eff
    end
  | None ->
    Logs.app (fun k -> k "[-] \u{2716} Status: No side effect");
    None

let test_model_exploit ~env ~dir scheme model =
  Logs.app (fun k ->
    k "[+] \u{1F4C4} Trying model :@\n %a"
      (Smtml.Model.pp ~no_values:false)
      model );
  setup_npm_dependencies env;
  let fs = Eio.Stdenv.fs env in
  let proc_mgr = Eio.Stdenv.process_mgr env in
  let poc = generate_poc ~dir scheme model in
  let status, eff = execute_and_check_poc ~fs ~proc_mgr ~env:replay_env poc in
  Logs.app (fun k -> k "[+] \u{1F4C4} Node %a" OS.Cmd.pp_status status);
  let final_effect = log_and_cleanup_effect ~fs eff in
  Option.map (fun eff -> (poc, eff)) final_effect

let find_exploitable_model ~env ~dir scheme (model : Sym_failure.t) =
  let open Option.Syntax in
  let* model = model.model in
  let result = test_model_exploit ~env ~dir scheme model.data in
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
