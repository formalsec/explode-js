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
  (* 1. Run graphjs *)
  let* (), (_, status) = Graphjs.run ~file:filename ~output:workspace_dir in
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
        Cmd_run.main options
      else 0 )

let main opt = match run opt with Ok n -> n | Error _err -> 1
