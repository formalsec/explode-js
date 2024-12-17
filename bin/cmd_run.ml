open Explode_js

let ( let* ) = Result.bind

let copy_file src dst =
  let open Bos in
  let* content = OS.File.read src in
  OS.File.write dst content

let with_workspace workspace_dir taint_summary filename f =
  let workspace_dir = Fpath.(workspace_dir / "run") in
  (* Create workspace_dir *)
  let* _ = Bos.OS.Dir.create ~path:true ~mode:0o777 workspace_dir in
  (* Copy taint_summary *)
  let* taint_summary =
    let file_base = Fpath.base taint_summary in
    let* () = copy_file taint_summary Fpath.(workspace_dir // file_base) in
    Ok file_base
  in
  (* Copy filename and package.json if they exist *)
  let* filename =
    match filename with
    | None -> Ok None
    | Some file ->
      let file_base = Fpath.base file in
      let* () = copy_file file Fpath.(workspace_dir // file_base) in
      let dir = Fpath.parent file in
      let pkg = Fpath.(dir / "package.json") in
      let* file_exists = Bos.OS.File.exists pkg in
      let* () =
        if not file_exists then Ok ()
        else copy_file pkg Fpath.(workspace_dir / "package.json")
      in
      Ok (Some file_base)
  in
  (* Run in the workspace_dir *)
  let* result =
    Bos.OS.Dir.with_current workspace_dir f
      (Fpath.v ".", taint_summary, filename)
  in
  result

let get_tests workspace (config : Fpath.t) (filename : Fpath.t option) =
  let file = Option.map Fpath.to_string filename in
  let config = Fpath.to_string config in
  let output = Fpath.(to_string @@ (workspace / "symbolic_test")) in
  Instrumentation.Run.run ~mode:0o666 ?file ~config ~output ()

let run_single ~(workspace : Fpath.t) (test : Fpath.t) filename taint_summary =
  let original_file = Option.map Fpath.to_string filename in
  let taint_summary = Fpath.to_string taint_summary in
  let* sym_result = Sym_exec.from_file ~workspace test in
  let* () =
    Replay.run ?original_file ~taint_summary test workspace sym_result
  in
  let report_path = Fpath.(workspace / "report.json") in
  let report = Sym_result.to_json sym_result in
  let* () =
    Bos.OS.File.writef ~mode:0o666 report_path "%a"
      (Yojson.pretty_print ~std:true)
      report
  in
  Ok sym_result

let run ~workspace_dir ~taint_summary ~filename ~time_limit:_ =
  with_workspace workspace_dir taint_summary filename
  @@ fun (workspace_dir, taint_summary, filename) ->
  let* symbolic_tests = get_tests workspace_dir taint_summary filename in
  let rec loop results = function
    | [] -> Ok results
    | test :: remaning ->
      let workspace = Fpath.(workspace_dir // rem_ext (base test)) in
      let* sym_result = run_single ~workspace test filename taint_summary in
      loop (sym_result :: results) remaning
  in
  let* results = loop [] symbolic_tests in
  let results_json = `List (List.map Sym_result.to_json results) in
  let results_report = Fpath.(workspace_dir / "report.json") in
  let* () =
    Bos.OS.File.writef ~mode:0o666 results_report "%a"
      (Yojson.pretty_print ~std:true)
      results_json
  in
  Ok 0
