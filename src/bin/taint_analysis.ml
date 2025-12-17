open Explode_js_gen
module Json = Yojson.Safe

let execute_scheme (settings : Settings.Cmd_run.t) i (scheme : Scheme.t) =
  let open Result.Syntax in
  let workspace = settings.workspace_dir in
  let* test_file =
    Utils.write_file
      Path.(workspace / Fmt.str "symbolic_test_%d.js" i)
      (Exploit_templates.Symbolic.render scheme)
  in
  let* sym_workspace =
    Utils.create_dir Path.(workspace / Fmt.str "symbolic_test_%d" i)
  in
  let sym_settings =
    Sym_exec.Settings.make ~lazy_values:settings.lazy_values
      ~workspace_dir:sym_workspace ~solver_type:settings.solver_type
      ~path_only:settings.path_only test_file
  in
  let time, outcome =
    let sym_result = Sym_exec.run_file sym_settings in
    match sym_result with
    | Error (`Msg err) ->
      Logs.err (fun m -> m "run_scheme: %s" err);
      (0.0, Analysis_results.Path_not_found)
    | Ok results when results.num_failures = 0 ->
      (results.execution_time, Path_not_found)
    | Ok results -> begin
      if settings.path_only then (results.execution_time, Path_found)
      else
        let find_model = Replay.find_exploitable_model ~dir:workspace scheme in
        match List.find_map find_model results.failures with
        | None -> (results.execution_time, Path_found)
        | Some (path, effect_) ->
          (results.execution_time, Exploit_found { path; effect_ })
    end
  in
  Ok (Analysis_results.make_test_result ~path:test_file ~outcome ~time)

let test_vulnerability (settings : Settings.Cmd_run.t) i
  (schemes : Scheme.t list) =
  let open Result.Syntax in
  let* workspace_dir =
    Utils.create_dir Path.(settings.workspace_dir / Fmt.str "vuln_%d" i)
  in
  let rec loop (best_so_far, all_results) i = function
    | [] -> Ok (best_so_far, all_results)
    | scheme :: rest -> begin
      Logs.app (fun k -> k "[+] Trying scheme %d..." i);
      let* result =
        execute_scheme { settings with workspace_dir } i scheme
        |> Result.map_error @@ fun (`Msg err) ->
           Logs.err (fun m -> m "Failed to execute scheme: %s" err);
           `Msg err
      in
      let all_results = result :: all_results in
      match result.outcome with
      | Exploit_found _ -> Ok (Some result, all_results)
      | Path_found ->
        if settings.path_only then Ok (Some result, all_results)
        else loop (Some result, all_results) (i + 1) rest
      | Path_not_found -> loop (best_so_far, all_results) (i + 1) rest
    end
  in
  let scheme0 = List.hd schemes in
  let filename, vuln_type, sink, sink_lineno = Scheme.metadata scheme0 in
  if Option.is_some vuln_type then
    Logs.app (fun k ->
      k "[+] Testing %a vulnerability ..." (Fmt.option Vuln_type.pp) vuln_type );
  let+ result, raw_results = loop (None, []) 0 schemes in
  Analysis_results.make ~filename ?vuln_type ?sink ?sink_lineno ?result
    ~raw_results ()

let run_from_file (settings : Settings.Cmd_run.t) =
  let open Result.Syntax in
  let start_time = Unix.gettimeofday () in
  let* _ = Utils.create_dir settings.workspace_dir in
  let* vulns =
    Scheme.Parser.from_file ~proto_pollution:false settings.input_path
  in

  let num_vulns = List.length vulns in
  ( match num_vulns with
  | 0 -> Logs.app (fun k -> k "[-] No potential vulnerabilities detected")
  | 1 -> Logs.app (fun k -> k "[+] Found 1 potential vulnerability")
  | n -> Logs.app (fun k -> k "[+] Found %d potential vulnerabilties" n) );

  let successes, failures =
    let results = List.mapi (test_vulnerability settings) vulns in
    List.partition_map
      (function
        | Ok v -> Either.Left v
        | Error e -> Either.Right e )
      results
  in
  let execution_time = Unix.gettimeofday () -. start_time in

  List.iter
    (fun (`Msg err) ->
      Logs.err (fun m -> m "Failed to test vulnerability: %s" err) )
    failures;

  Utils.write_time
    Path.(settings.workspace_dir / "explode_time.txt")
    execution_time;

  let json_results = List.map Analysis_results.to_yojson successes in
  let output_file = Path.(settings.workspace_dir / "results.json") in
  Bos.OS.File.writef output_file "%a@."
    (Json.pretty_print ~std:true)
    (`List json_results)
