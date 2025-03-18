open Explode_js
open Result

let copy_file src dst =
  let open Bos in
  let* content = OS.File.read src in
  OS.File.write dst content

let with_workspace ~proto_pollution workspace_dir scheme_path package_dir
  filename f =
  let _timestamp =
    let now = Unix.localtime @@ Unix.gettimeofday () in
    ExtUnix.Specific.strftime "%Y%m%dT%H%M%S" now
  in
  let workspace_dir = Fpath.(workspace_dir / "run") in
  (* Create workspace_dir *)
  let* _ = Bos.OS.Dir.create ~path:true ~mode:0o777 workspace_dir in
  (* Copy package contents if they exist *)
  let _ =
    match package_dir with
    | None -> Ok ()
    | Some package_dir ->
      let src_dir = Fpath.to_string package_dir in
      let dst_dir = Fpath.to_string workspace_dir in
      let _ = Fmt.kstr Unix.system "cp -r %s/. %s" src_dir dst_dir in
      Ok ()
  in
  (* Copy sources and scheme_path *)
  let* schemes =
    let open Explode_js_instrument in
    let+ schemes0 = Scheme.Parser.from_file scheme_path in
    if not proto_pollution then schemes0
    else begin
      let schemes1 =
        match schemes0 with
        | [] ->
          Heuristics.Pollution.merge2 None
          :: Scheme.unroll (Heuristics.Pollution.merge None)
          @ Scheme.unroll (Heuristics.Pollution.set None "module.exports")
        | vises -> Scheme.unroll (Heuristics.Pollution.merge None) @ vises
      in
      match filename with
      | None -> schemes1
      | Some filename ->
        if Heuristics.Pollution.has_recursive filename then
          Scheme.unroll
            (Heuristics.Pollution.merge ~source:"module.exports.recursive" None)
          @ schemes1
        else schemes1
    end
  in
  (* List.iter (fun scheme -> *)
  (*   Fmt.pr "SCHEME:@\n%a@." Explode_js_instrument.Scheme.pp scheme) schemes; *)
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

let get_tmpls workspace_dir (scheme_file : Fpath.t)
  (original_file : Fpath.t option) schemes =
  let output_dir = Fpath.(to_string @@ (workspace_dir / "symbolic_test")) in
  Explode_js_instrument.Test.Symbolic.write_all ~mode:0o666 ?original_file
    ~scheme_file ~output_dir schemes

let write_report report_file result =
  Bos.OS.File.writef ~mode:0o666 report_file "%a" Sym_exec.print_report result

let run_single ~lazy_values ~(workspace_dir : Fpath.t) (test_file : Fpath.t)
  original_file scheme_file scheme =
  let* res = Sym_exec.run_file ~lazy_values ~workspace_dir test_file in
  let* found_witness =
    Replay.run_single ?original_file ~scheme_file ~scheme ~workspace_dir
      test_file res
  in
  let+ () = write_report Fpath.(workspace_dir / "report.json") res in
  (found_witness, res)

let run_server ~lazy_values ~(workspace_dir : Fpath.t) (server_file : Fpath.t)
  scheme =
  let* res = Sym_exec.run_file ~lazy_values ~workspace_dir server_file in
  let* () = Replay.run_server ~workspace_dir server_file scheme res in
  let+ () = write_report Fpath.(workspace_dir / "report.json") res in
  res

let write_reports reports_file results =
  let results = `List (List.map Sym_exec.Symbolic_result.to_json results) in
  Bos.OS.File.writef ~mode:0o666 reports_file "%a"
    (Yojson.pretty_print ~std:true)
    results

let run ~lazy_values ~proto_pollution ~enumerate_all ~workspace_dir ~package_dir
  ~scheme_file ~original_file ~time_limit:_ =
  Logs.app (fun k -> k "── PHASE 1: TEMPLATE GENERATION ──");
  Logs.app (fun k -> k "\u{2714} Loaded: %a" Fpath.pp scheme_file);
  with_workspace ~proto_pollution workspace_dir scheme_file package_dir
    original_file
  @@ fun workspace_dir scheme_file schemes orig_file ->
  let* exploit_tmpls = get_tmpls workspace_dir scheme_file orig_file schemes in
  let n = List.length exploit_tmpls in
  let rec loop i results = function
    | [] -> Ok results
    | (Explode_js_instrument.Test.Single_shot test, scheme) :: remaning ->
      Logs.app (fun k -> k "\u{25C9} [%d/%d] Procesing %a" i n Fpath.pp test);
      let workspace_dir = Fpath.(workspace_dir // rem_ext (base test)) in
      let found_witness, results =
        match
          run_single ~lazy_values ~workspace_dir test orig_file scheme_file
            scheme
        with
        | Ok (found_witness, sym_result) ->
          (found_witness, sym_result :: results)
        | Error (`Msg err) ->
          Logs.err (fun k -> k "run_single: %s" err);
          (false, results)
      in
      if found_witness && not enumerate_all then Ok results
      else loop (succ i) results remaning
    | (Client_server { client = _; server }, scheme) :: remaning ->
      Logs.app (fun k -> k "\u{25C9} [%d/%d] Procesing %a" i n Fpath.pp server);
      let workspace_dir = Fpath.(workspace_dir // rem_ext (base server)) in
      let* sym_result = run_server ~lazy_values ~workspace_dir server scheme in
      loop (succ i) (sym_result :: results) remaning
  in
  Logs.app (fun k -> k "@\n── PHASE 2: ANALYSIS & VALIDATION ──");
  let* results = loop 1 [] exploit_tmpls in
  let+ () = write_reports Fpath.(workspace_dir / "report.json") results in
  Logs.err_count ()
