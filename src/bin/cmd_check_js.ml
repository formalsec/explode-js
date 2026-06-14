open Result
module String = Astring.String

let run (settings : Settings.Cmd_run.t) =
  Eio_main.run @@ fun env ->
  let open Result.Syntax in
  let sym_settings =
    Sym_exec.Settings.make ~deterministic:settings.deterministic
      ~lazy_values:settings.lazy_values ~workspace_dir:settings.workspace_dir
      ~solver_type:settings.solver_type ~path_only:false settings.input_path
  in
  Logs.app (fun m ->
    m "[+] Starting symbolic execution on %s" settings.input_path );
  let* sym_result = Sym_exec.run_file ~env sym_settings in
  let failures = sym_result.failures in
  let n = List.length failures in
  if n = 0 then (
    Logs.app (fun m -> m "[!] No exploitable paths found.");
    Ok () )
  else (
    Logs.app (fun m ->
      m "[+] Found %d potential exploit(s). Starting validation..." n );
    let fs = Eio.Stdenv.fs env in
    let proc_mgr = Eio.Stdenv.process_mgr env in
    let i = Atomic.make 1 in
    List.iter
      (fun (failure : Sym_failure.t) ->
        let current_i = Atomic.fetch_and_add i 1 in
        match failure.model with
        | None -> ()
        | Some { path = witness_file; _ } ->
          Logs.app (fun k ->
            k "[+] [%d/%d] Validating with witness: %a" current_i n Fpath.pp
              witness_file );
          let env = Replay.make_replay_env ~witness_file () in
          let harness = Eio.Path.(fs / settings.input_path) in
          let status, eff =
            Replay.execute_and_check_poc ~fs ~proc_mgr ~env harness
          in
          Logs.app (fun k ->
            k "[+] [%d/%d] Node exited with %a" current_i n
              Eio.Process.pp_status status );
          ignore (Replay.log_and_cleanup_effect ~fs eff) )
      failures;
    Ok () )
