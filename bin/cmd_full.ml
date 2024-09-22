open Explode_js
open Ecma_sl.Syntax.Result

type options =
  { filename : Fpath.t
  ; workspace_dir : Fpath.t
  ; time_limit : float
  }

let options filename workspace_dir time_limit =
  { filename; workspace_dir; time_limit }

let run { filename; workspace_dir; time_limit } =
  let* _ = Bos.OS.Dir.create ~path:true ~mode:0o777 workspace_dir in
  let graphjs_time_path = Fpath.(workspace_dir / "graphjs_time.txt") in
  let explode_time_path = Fpath.(workspace_dir / "explode_time.txt") in
  (* 1. Run graphjs *)
  let graphjs_start = Unix.gettimeofday () in
  let* status = Graphjs.run ~file:filename ~output:workspace_dir in
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
          Cmd_run.options taint_summary (Some filename) workspace_dir time_limit
        in
        let explode_start = Unix.gettimeofday () in
        let result = Cmd_run.main options in
        let explode_time = Unix.gettimeofday () -. explode_start in
        let _ = Bos.OS.File.writef explode_time_path "%f@." explode_time in
        result
      else 0 )

let main opt = match run opt with Ok n -> n | Error _err -> 1
