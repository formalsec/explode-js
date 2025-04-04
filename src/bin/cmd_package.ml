open Result
open Explode_js
open Explode_js_instrument

let is_valid_npm_package input_dir =
  Bos.OS.File.exists Fpath.(input_dir / "package.json")

let parse_entry_file package_json_path =
  let json_path = Fpath.to_string package_json_path in
  let json_data = Yojson.Basic.from_file json_path in
  match Yojson.Basic.Util.member "main" json_data with
  | `String entry_file -> Fpath.v entry_file
  | `Null | _ -> assert false

let with_npm_package workspace_dir input_dir f =
  (* Create workspace_dir *)
  let* _ = Bos.OS.Dir.create ~path:true ~mode:0o777 workspace_dir in
  (* Recursively copy files from input_dir to workspace_dir *)
  let* () =
    Bos.OS.Dir.fold_contents ~elements:`Files ~traverse:`Any
      (fun src_path () ->
        match Fpath.relativize ~root:input_dir src_path with
        | None -> assert false
        | Some rel_path -> (
          let dst_path = Fpath.(workspace_dir // rel_path) in
          let parent_dir = Fpath.parent dst_path in
          let result =
            Logs.debug (fun k ->
              k "cp %a -> %a" Fpath.pp src_path Fpath.pp dst_path );
            if Fpath.(equal (normalize parent_dir) (normalize workspace_dir))
            then Utils.copy_file src_path dst_path
            else begin
              let* _ = Bos.OS.Dir.create ~path:true ~mode:0o777 parent_dir in
              Utils.copy_file src_path dst_path
            end
          in
          match result with
          | Error (`Msg err) -> Logs.err (fun k -> k "setup_workspace: %s" err)
          | Ok () -> () ) )
      () input_dir
  in
  (* Parse entry file of the module *)
  let entry_file = parse_entry_file Fpath.(workspace_dir / "package.json") in
  let f () = f (Fpath.v "./") entry_file in
  (* Run f in the workspace_dir *)
  let* result = Bos.OS.Dir.with_current workspace_dir f () in
  result

let print_detected_vulnerabilities scheme_file =
  let module Json = Yojson.Basic in
  let scheme_data = Json.from_file (Fpath.to_string scheme_file) in
  let schemes = Json.Util.to_list scheme_data in
  let n = List.length schemes in
  Logs.app (fun k -> k "Detected %d potential issue(s):" n);
  List.iteri
    (fun i scheme ->
      if i > 0 then Logs.app (fun k -> k "│");
      let filename = Json.Util.(member "filename" scheme |> to_string) in
      let vuln_type = Json.Util.(member "vuln_type" scheme |> to_string) in
      let sink = Json.Util.(member "sink" scheme |> to_string) in
      let sink_lineno = Json.Util.(member "sink_lineno" scheme |> to_int) in
      Logs.app (fun k ->
        k "├── Issue %d: %s @@ %s:%d" i vuln_type filename sink_lineno );
      Logs.app (fun k -> k "│   └── %d|  %s" sink_lineno sink) )
    schemes

let run_graphjs_timed workspace_dir entry_file =
  let start = Unix.gettimeofday () in
  let stderr = Fpath.(workspace_dir / "graphjs.stderr") in
  let stdout = Fpath.(workspace_dir / "graphjs.stdout") in
  let* status =
    Graphjs.run ~stderr ~stdout ~optimized_import:false ~output:workspace_dir
      ~file:entry_file ()
  in
  let time = Unix.gettimeofday () -. start in
  match status with
  | `Exited 0 -> Ok time
  | `Exited n | `Signaled n ->
    Error (`Msg (Fmt.str "Graphjs exited with non-zero code: %d" n))

let run_confirmation ~proto_pollution ~enumerate_all workspace_dir scheme_file =
  (* FIXME: Should be command flags *)
  let deterministic = false in
  let lazy_values = true in
  Logs.app (fun k -> k "@\n── PHASE 1: TEMPLATE GENERATION ──");
  let output_dir = Fpath.(to_string (workspace_dir / "symbolic_test")) in
  let* schemes = Scheme.Parser.from_file ~proto_pollution scheme_file in
  Logs.app (fun k -> k "\u{2714} Loaded: %a" Fpath.pp scheme_file);
  let* exploit_tmpls =
    Test.Symbolic.write_all ~mode:0o666 ~scheme_file ~output_dir schemes
  in
  let n = List.length exploit_tmpls in
  Logs.app (fun k -> k "@\n── PHASE 2: ANALYSIS & VALIDATION ──");
  let rec loop i results = function
    | [] -> Ok results
    | (Explode_js_instrument.Test.Single_shot test, scheme) :: remaning ->
      Logs.app (fun k -> k "\u{25C9} [%d/%d] Procesing %a" i n Fpath.pp test);
      let workspace_dir = Fpath.(workspace_dir // rem_ext (base test)) in
      let found_witness, results =
        match
          Cmd_run.run_single ~deterministic ~lazy_values ~workspace_dir test
            None scheme_file scheme
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
      let* sym_result =
        Cmd_run.run_server ~deterministic ~lazy_values ~workspace_dir server
          scheme
      in
      loop (succ i) (sym_result :: results) remaning
  in
  let* results = loop 1 [] exploit_tmpls in
  let+ () =
    Cmd_run.write_reports Fpath.(workspace_dir / "report.json") results
  in
  Logs.err_count ()

let run ~proto_pollution ~workspace_dir ~input_dir =
  Logs.app (fun k -> k "── PHASE 0: VULNERABILITY DETECTION ──");
  let* package_json_exists = is_valid_npm_package input_dir in
  if not package_json_exists then begin
    Logs.err (fun k ->
      k "'package.json' not found: '%a' is not a valid npm package" Fpath.pp
        input_dir );
    Ok 1
  end
  else begin
    let timestamp =
      let now = Unix.localtime @@ Unix.gettimeofday () in
      ExtUnix.Specific.strftime "%Y%m%dT%H%M%S" now
    in
    let workspace_dir = Fpath.(workspace_dir / timestamp) in
    with_npm_package workspace_dir input_dir @@ fun workspace_dir entry_file ->
    let graphjs_time_path = Fpath.(workspace_dir / "graphjs_time.txt") in
    let explode_time_path = Fpath.(workspace_dir / "explode_time.txt") in
    let* graphjs_time = run_graphjs_timed workspace_dir entry_file in
    let _ = Bos.OS.File.writef graphjs_time_path "%f@." graphjs_time in
    let scheme_file = Fpath.(workspace_dir / "taint_summary.json") in
    let* scheme_file_exists = Bos.OS.File.exists scheme_file in
    if not scheme_file_exists then begin
      Logs.app (fun k -> k "No vulnerabilities detected!");
      Ok 0
    end
    else begin
      print_detected_vulnerabilities scheme_file;
      let explode_start = Unix.gettimeofday () in
      let result =
        run_confirmation ~proto_pollution ~enumerate_all:true workspace_dir
          scheme_file
      in
      let explode_time = Unix.gettimeofday () -. explode_start in
      let _ = Bos.OS.File.writef explode_time_path "%f@." explode_time in
      result
    end
  end
