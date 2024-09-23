open Explode_js
open Ecma_sl.Syntax.Result

type options =
  { filename : Fpath.t
  ; workspace_dir : Fpath.t
  ; time_limit : float
  }

let options filename workspace_dir time_limit =
  { filename; workspace_dir; time_limit }

let full ~sw mgr filename workspace_dir =
  let* _ = Bos.OS.Dir.create ~path:true ~mode:0o777 workspace_dir in
  let graphjs_time_path = Fpath.(workspace_dir / "graphjs_time.txt") in
  let explode_time_path = Fpath.(workspace_dir / "explode_time.txt") in
  (* 1. Run graphjs *)
  let graphjs_start = Unix.gettimeofday () in

  let args = Graphjs.run ~file:filename ~output:workspace_dir in
  let handle = Eio.Process.spawn ~sw mgr args in
  let status = Eio.Process.await handle in
  let graphjs_time = Unix.gettimeofday () -. graphjs_start in
  let _ = Bos.OS.File.writef graphjs_time_path "%f@." graphjs_time in
  let* () =
    match status with
    | `Exited 0 -> Ok ()
    | `Exited n | `Signaled n ->
      Error (`Msg (Fmt.str "Graphjs exited with non-zero code: %d" n))
  in
  let taint_summary = Fpath.(workspace_dir / "taint_summary.json") in
  let* taint_summary_exists = Bos.OS.File.exists taint_summary in
  Ok
    ( if taint_summary_exists then
        let options =
          (* Runs symbolic execution tests for 30s each *)
          Cmd_run.options taint_summary (Some filename) workspace_dir 30.
        in
        let explode_start = Unix.gettimeofday () in
        let result = Cmd_run.main options in
        let explode_time = Unix.gettimeofday () -. explode_start in
        let _ = Bos.OS.File.writef explode_time_path "%f@." explode_time in
        result
      else 0 )

exception Timeout

let run_with_timelimit filename workspace_dir time_limit =
  (* FIXME: Is this horrible? I can't tell *)
  let open Eio in
  Eio_main.run @@ fun env ->
  let proc_mgr = Stdenv.process_mgr env in
  Switch.run @@ fun sw ->
  Fiber.fork_daemon ~sw (fun () ->
      Eio_unix.sleep time_limit;
      raise Timeout );
  let promise =
    Fiber.fork_promise ~sw (fun () -> full ~sw proc_mgr filename workspace_dir)
  in
  Fiber.yield ();
  Promise.await promise

let run { filename; workspace_dir; time_limit } =
  try
    match run_with_timelimit filename workspace_dir time_limit with
    | Ok res -> res
    | Error exn -> Error (`Msg (Printexc.to_string exn))
  with Timeout ->
    Logs.warn (fun m -> m "Time limit reached for: %a" Fpath.pp filename);
    Ok 0

let main opt = match run opt with Ok n -> n | Error _err -> 1
