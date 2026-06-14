let run_package ~env (settings : Settings.Cmd_run.t) =
  let open Result.Syntax in
  Logs.app (fun m ->
    m "[+] Starting static analysis (dir %s)" settings.input_path );
  let* result =
    (* Create workspace_dir prior to starting static analysis because we have to
       change dir *)
    let fs = Eio.Stdenv.fs env in
    let workspace_dir =
      Utils.create_dir Eio.Path.(fs / settings.workspace_dir)
    in
    Bos.OS.Dir.with_current
      (Fpath.of_string settings.input_path |> Result.get_ok)
      (fun input_path ->
        (* Workspace dir is a global path here*)
        let settings =
          { settings with
            input_path
          ; workspace_dir = Eio.Path.native_exn workspace_dir
          }
        in
        let* scheme_file = Static_analysis.find_vulnerabilities ~env settings in
        Taint_analysis.run_from_file ~env
          { settings with input_path = Eio.Path.native_exn scheme_file } )
      "."
  in
  result

let run (settings : Settings.Cmd_run.t) =
  Eio_main.run @@ fun env ->
  let fs = Eio.Stdenv.fs env in
  let kind = Eio.Path.kind ~follow:true Eio.Path.(fs / settings.input_path) in
  match kind with
  | `Regular_file -> Taint_analysis.run_from_file ~env settings
  | `Directory -> run_package ~env settings
  | _ -> Error (`Msg (Fmt.str "%s: unsupported file type" settings.input_path))
