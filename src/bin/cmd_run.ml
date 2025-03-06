open Explode_js
open Result

let copy_file src dst =
  let open Bos in
  let* content = OS.File.read src in
  OS.File.write dst content

let with_workspace workspace_dir scheme_path filename f =
  let workspace_dir = Fpath.(workspace_dir / "run") in
  (* Create workspace_dir *)
  let* _ = Bos.OS.Dir.create ~path:true ~mode:0o777 workspace_dir in
  (* Copy sources and scheme_path *)
  let* scheme_path =
    let file_base = Fpath.base scheme_path in
    let* () = copy_file scheme_path Fpath.(workspace_dir // file_base) in
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
  let f () = f (Fpath.v ".") scheme_path filename in
  let* result = Bos.OS.Dir.with_current workspace_dir f () in
  result

let get_tmpls workspace (scheme_path : Fpath.t) (file : Fpath.t option) =
  let output_dir = Fpath.(to_string @@ (workspace / "symbolic_test")) in
  Explode_js_instrument.Util.gen_symbolic_tmpls ~mode:0o666 ?file ~scheme_path
    ~output_dir ()

let run_single ~(workspace : Fpath.t) (test : Fpath.t) original_file
  scheme_path =
  let* sym_result = Sym_exec.from_file ~workspace test in
  let* () =
    Replay.run ?original_file ~scheme_path test workspace sym_result
  in
  let report_path = Fpath.(workspace / "report.json") in
  let report = Sym_exec.Symbolic_result.to_json sym_result in
  let* () =
    Bos.OS.File.writef ~mode:0o666 report_path "%a"
      (Yojson.pretty_print ~std:true)
      report
  in
  Ok sym_result

let run ~workspace_dir ~scheme_path ~filename ~time_limit:_ =
  with_workspace workspace_dir scheme_path filename
  @@ fun workspace_dir scheme_path filename ->
  let* symbolic_tests = get_tmpls workspace_dir scheme_path filename in
  let rec loop results = function
    | [] -> Ok results
    | test :: remaning ->
      let workspace = Fpath.(workspace_dir // rem_ext (base test)) in
      let* sym_result = run_single ~workspace test filename scheme_path in
      loop (sym_result :: results) remaning
  in
  let* results = loop [] symbolic_tests in
  let results_json =
    `List (List.map Sym_exec.Symbolic_result.to_json results)
  in
  let results_report = Fpath.(workspace_dir / "report.json") in
  let* () =
    Bos.OS.File.writef ~mode:0o666 results_report "%a"
      (Yojson.pretty_print ~std:true)
      results_json
  in
  Ok 0
