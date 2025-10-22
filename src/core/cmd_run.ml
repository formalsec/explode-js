let run_package (settings : Settings.Cmd_run.t) =
  let open Result.Syntax in
  Logs.app (fun m ->
    m "Starting static analysis on %a" Path.pp settings.input_path );
  let* scheme_file = Static_analysis.find_vulnerabilities settings in
  Taint_analysis.run_from_file { settings with input_path = scheme_file }

let run (settings : Settings.Cmd_run.t) =
  let open Result.Syntax in
  let* stats = Bos.OS.Path.stat settings.input_path in
  match stats.st_kind with
  | Unix.S_REG -> Taint_analysis.run_from_file settings
  | S_DIR -> run_package settings
  | S_CHR | S_BLK | S_LNK | S_FIFO | S_SOCK ->
    Error
      (`Msg (Fmt.str "%a: unsupported file type" Fpath.pp settings.input_path))
