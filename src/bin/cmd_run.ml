open Explode_js
open Result

let copy_file src dst =
  let open Bos in
  let* content = OS.File.read src in
  OS.File.write dst content

let with_workspace workspace_dir scheme_path filename f =
  let timestamp =
    let now = Unix.localtime @@ Unix.gettimeofday () in
    ExtUnix.Specific.strftime "%Y%m%dT%H%M%S" now
  in
  let workspace_dir = Fpath.(workspace_dir / "run" / timestamp) in
  (* Create workspace_dir *)
  let* _ = Bos.OS.Dir.create ~path:true ~mode:0o777 workspace_dir in
  (* Copy sources and scheme_path *)
  let* schemes = Explode_js_instrument.Scheme.Parser.from_file scheme_path in
  let* () =
    list_iter
      (fun scheme ->
        let dname = Fpath.parent scheme_path in
        let fname = Explode_js_instrument.Scheme.filename scheme in
        match fname with
        | None -> Ok ()
        | Some fname ->
          let fpath = Fpath.(dname // fname) in
          let fpath' = Fpath.(workspace_dir // fname) in
          let dirs = Fpath.parent fpath' in
          let* file_exists = Bos.OS.Dir.exists dirs in
          let* () =
            if not file_exists then begin
              let+ _ = Bos.OS.Dir.create ~path:true dirs in
              ()
            end
            else Ok ()
          in
          copy_file fpath fpath' )
      schemes
  in
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
  let f () = f (Fpath.v ".") scheme_path schemes filename in
  let* result = Bos.OS.Dir.with_current workspace_dir f () in
  result

let get_tmpls workspace (scheme_path : Fpath.t) (file : Fpath.t option) schemes
    =
  let output_dir = Fpath.(to_string @@ (workspace / "symbolic_test")) in
  Explode_js_instrument.Test.Symbolic.write_all ~mode:0o666 ?file ~scheme_path
    ~output_dir schemes

let run_single ~(workspace : Fpath.t) (test : Fpath.t) original_file scheme_path
    =
  let* sym_result = Sym_exec.from_file ~workspace test in
  let* () = Replay.run ?original_file ~scheme_path test workspace sym_result in
  let report_path = Fpath.(workspace / "report.json") in
  let report = Sym_exec.Symbolic_result.to_json sym_result in
  let* () =
    Bos.OS.File.writef ~mode:0o666 report_path "%a"
      (Yojson.pretty_print ~std:true)
      report
  in
  Ok sym_result

let run ~workspace_dir ~scheme_path ~filename ~time_limit:_ =
  Logs.app (fun k -> k "── PHASE 1: TEMPLATE GENERATION ──");
  Logs.app (fun k -> k "\u{2714} Loaded: %a" Fpath.pp scheme_path);
  with_workspace workspace_dir scheme_path filename
  @@ fun workspace_dir scheme_path schemes filename ->
  let* exploit_tmpls = get_tmpls workspace_dir scheme_path filename schemes in
  let n = List.length exploit_tmpls in
  let rec loop i results = function
    | [] -> Ok results
    | test :: remaning ->
      Logs.app (fun k -> k "\u{25C9} [%d/%d] Procesing %a" i n Fpath.pp test);
      let workspace = Fpath.(workspace_dir // rem_ext (base test)) in
      let* sym_result = run_single ~workspace test filename scheme_path in
      loop (succ i) (sym_result :: results) remaning
  in
  Logs.app (fun k -> k "@\n── PHASE 2: ANALYSIS & VALIDATION ──");
  let* results = loop 1 [] exploit_tmpls in
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
