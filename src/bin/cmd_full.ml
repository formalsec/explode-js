open Explode_js
open Result

let run_with_timeout limit f =
  let exception Sigchld in
  let open Unix in
  let did_timeout = ref false in
  let pid = fork () in
  if pid = 0 then begin
    exit (f ())
  end
  else begin
    ( try
        Sys.set_signal Sys.sigchld (Signal_handle (fun _ -> raise Sigchld));
        Unix.sleepf limit;
        did_timeout := true;
        Unix.kill pid Sys.sigkill;
        Sys.set_signal Sys.sigchld Signal_default
      with Sigchld -> () );
    let chldpid, status = waitpid [] pid in
    assert (chldpid = pid);
    if !did_timeout then `Timeout
    else
      match status with
      | WEXITED n -> `Ok n
      | WSIGNALED _ | WSTOPPED _ -> `Timeout
  end

let full ~deterministic ~lazy_values ~proto_pollution ~enumerate_all package_dir
  input_file workspace_dir optimized_import =
  let res =
    let graphjs_time_path = Fpath.(workspace_dir / "graphjs_time.txt") in
    let explode_time_path = Fpath.(workspace_dir / "explode_time.txt") in
    (* 1. Run graphjs *)
    let graphjs_start = Unix.gettimeofday () in
    let* status =
      Graphjs.run ~optimized_import ~file:input_file ~output:workspace_dir ()
    in
    let graphjs_time = Unix.gettimeofday () -. graphjs_start in
    let _ = Bos.OS.File.writef graphjs_time_path "%f@." graphjs_time in
    (* Use: Bos.OS.Cmd.success *)
    let* () =
      match status with
      | `Exited 0 -> Ok ()
      | `Exited n | `Signaled n ->
        Error (`Msg (Fmt.str "Graphjs exited with non-zero code: %d" n))
    in
    let scheme_file = Fpath.(workspace_dir / "taint_summary.json") in
    let* scheme_file_exists = Bos.OS.File.exists scheme_file in
    if scheme_file_exists then
      let explode_start = Unix.gettimeofday () in
      let result =
        Cmd_run.run ~deterministic ~lazy_values ~proto_pollution ~enumerate_all
          ~workspace_dir ~package_dir ~scheme_file
          ~original_file:(Some input_file) ~time_limit:(Some 30.0)
      in
      let explode_time = Unix.gettimeofday () -. explode_start in
      let _ = Bos.OS.File.writef explode_time_path "%f@." explode_time in
      result
    else Ok 0
  in
  match res with
  | Ok n -> n
  | Error err -> (
    let open Explode_js_instrument in
    match err with
    | #Instrument_result.err as error ->
      Fmt.epr "error: %a@." Instrument_result.pp error;
      Instrument_result.to_code error
    | `Status n ->
      Fmt.epr "error: Failed during symbolic execution/confirmation@.";
      n )

let run ~deterministic ~lazy_values ~proto_pollution ~enumerate_all ~package_dir
  ~input_file ~workspace_dir ~time_limit ~optimized_import =
  let* _ = Bos.OS.Dir.create ~path:true ~mode:0o777 workspace_dir in
  let work () =
    full ~deterministic ~lazy_values ~proto_pollution ~enumerate_all package_dir
      input_file workspace_dir optimized_import
  in
  let res =
    match time_limit with
    | None -> `Ok (work ())
    | Some limit -> run_with_timeout limit work
  in
  match res with
  | `Ok n -> Ok n
  | `Timeout ->
    Logs.warn (fun m -> m "Time limit reached");
    Ok 0
