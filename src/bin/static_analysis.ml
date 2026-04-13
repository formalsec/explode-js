let extract_from_package_json package_json =
  let json_data = Yojson.Safe.from_file @@ Fpath.to_string package_json in
  match Yojson.Safe.Util.member "main" json_data with
  | `String path -> Ok (Fpath.v path)
  | `Null ->
    (* When "main" not present assume index.js *)
    Ok (Fpath.v "./index.js")
  | _ -> Error (`Msg "could not extract entry file from package.json")

let find_entry_file path =
  let open Result.Syntax in
  let package_json = Fpath.(path / "package.json") in
  let* package_json_exists = Bos.OS.File.exists package_json in
  (* If packae.json doesn't exist we fallback to index.js *)
  let* main_file =
    if not package_json_exists then Ok (Fpath.v "index.js")
    else extract_from_package_json package_json
  in
  Ok (Fpath.normalize Fpath.(path // main_file))

let find_vulnerabilities (settings : Settings.Cmd_run.t) =
  let open Result.Syntax in
  let start_time = Unix.gettimeofday () in
  let workspace_dir = settings.workspace_dir in
  (* Input path is a directory, we must resolve it to a file *)

  let* entry_file = find_entry_file settings.input_path in

  let* graphjs_result =
    let settings =
      Graphjs.Settings.make ~file:entry_file ~output:workspace_dir ()
    in
    let stderr = Fpath.(workspace_dir / "graphjs-stderr.txt") in
    let stdout = Fpath.(workspace_dir / "graphjs-stdout.txt") in
    Graphjs.run ~stderr ~stdout settings
  in

  let execution_time = Unix.gettimeofday () -. start_time in
  Utils.write_time Path.(workspace_dir / "graphjs_time.txt") execution_time;
  match graphjs_result with
  | `Exited 0 -> begin
    Bos.OS.File.must_exist Fpath.(workspace_dir / "taint_summary.json")
    end
  | `Exited n | `Signaled n ->
    Error (`Msg (Fmt.str "Graphjs exited with non-zero code: %d" n))
