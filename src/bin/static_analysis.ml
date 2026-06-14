let extract_from_package_json package_json =
  let contents = Eio.Path.load package_json in
  let json_data = Yojson.Safe.from_string contents in
  match Yojson.Safe.Util.member "main" json_data with
  | `String path -> Ok path
  | `Null ->
    (* When "main" not present assume index.js *)
    Ok "./index.js"
  | _ -> Error (`Msg "could not extract entry file from package.json")

let find_entry_file path =
  let open Result.Syntax in
  let package_json = Eio.Path.(path / "package.json") in
  (* If packae.json doesn't exist we fallback to index.js *)
  let* main_file =
    if not (Eio.Path.is_file package_json) then Ok "index.js"
    else extract_from_package_json package_json
  in
  Ok Eio.Path.(path / main_file)

let find_vulnerabilities ~env (settings : Settings.Cmd_run.t) =
  let open Eio in
  let open Result.Syntax in
  let fs = Stdenv.fs env in
  let start_time = Unix.gettimeofday () in
  let workspace_dir = Path.(fs / settings.workspace_dir) in
  (* Input path is a directory, we must resolve it to a file *)

  let* entry_file = find_entry_file Path.(fs / settings.input_path) in

  let graphjs_result =
    let stderr = Path.(workspace_dir / "graphjs-stderr.txt") in
    let stdout = Path.(workspace_dir / "graphjs-stdout.txt") in
    Graphjs.run ~env ~stderr ~stdout workspace_dir entry_file
  in

  let execution_time = Unix.gettimeofday () -. start_time in
  Utils.write_time Path.(workspace_dir / "graphjs_time.txt") execution_time;

  match graphjs_result with
  | `Exited 0 ->
    let taint_summary = Path.(workspace_dir / "taint_summary.json") in
    assert (Path.is_file taint_summary);
    Ok taint_summary
  | `Exited n | `Signaled n ->
    Error (`Msg (Fmt.str "Graphjs exited with non-zero code: %d" n))
