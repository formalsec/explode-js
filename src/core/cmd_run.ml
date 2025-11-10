let run_package (settings : Settings.Cmd_run.t) =
  let open Result.Syntax in
  Logs.app (fun m ->
    m "Starting static analysis on %a" Path.pp settings.input_path );
  let* result =
    (* Create workspace_dir prior to starting static analysis because we have to
       change dir *)
    let* workspace_dir = Utils.create_dir settings.workspace_dir in
    Bos.OS.Dir.with_current settings.input_path
      (fun input_path ->
        (* Workspace dir is a global path here*)
        let settings = { settings with input_path; workspace_dir } in
        let* scheme_file = Static_analysis.find_vulnerabilities settings in
        Taint_analysis.run_from_file { settings with input_path = scheme_file } )
      Path.(v ".")
  in
  result

let run (settings : Settings.Cmd_run.t) =
  let open Result.Syntax in
  let* stats = Bos.OS.Path.stat settings.input_path in
  match stats.st_kind with
  | Unix.S_REG -> Taint_analysis.run_from_file settings
  | S_DIR -> run_package settings
  | S_CHR | S_BLK | S_LNK | S_FIFO | S_SOCK ->
    Error
      (`Msg (Fmt.str "%a: unsupported file type" Fpath.pp settings.input_path))
