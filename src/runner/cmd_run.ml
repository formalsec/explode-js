open Syntax
module Json = Yojson.Basic

let parse_report output_dir =
  let report_path = Fpath.(output_dir / "run" / "report.json") in
  if not (Sys.file_exists (Fpath.to_string report_path)) then ("", false, false)
  else
    let json = Json.from_file (Fpath.to_string report_path) in
    let json_list = Json.Util.to_list json in
    let control_path =
      List.exists
        (fun json ->
          let failures = Json.Util.(member "failures" json |> to_list) in
          List.length failures > 0 )
        json_list
    in
    let exploit =
      List.exists
        (fun json ->
          let failures = Json.Util.(member "failures" json |> to_list) in
          List.exists
            (fun json ->
              Json.Util.member "exploit" json
              |> Json.Util.member "success" |> Json.Util.to_bool )
            failures )
        json_list
    in
    (Fmt.str "%a" (Json.pretty_print ~std:true) json, control_path, exploit)

let work db ({ timestamp; time_limit; output_dir; filter; _ } : Run_metadata.t)
  (pkg : Package.t) : Run_result.t list =
  let vulns =
    match filter with
    | None -> pkg.vulns
    | Some cwe ->
      List.filter
        (fun (v : Vulnerability.t) -> Explode_js.Cwe.equal cwe v.cwe)
        pkg.vulns
  in
  List.fold_left
    (fun acc (vuln : Vulnerability.t) ->
      (* let base_dir = Fpath.(parent (parent vuln.filename)) in *)
      (* let exploit_tmpl = Fpath.(base_dir / "expected_output.json") in *)
      (* if not (Sys.file_exists (Fpath.to_string exploit_tmpl)) then acc *)
      (* else *)
      let output_dir = Fpath.(output_dir / string_of_int vuln.id) in
      begin
        match Bos.OS.Dir.create ~path:true output_dir with
        | Ok _ -> ()
        | Error (`Msg err) ->
          Fmt.epr "could not create directory '%a': %s@." Fpath.pp output_dir
            err
      end;
      let raw = Run_action.full time_limit output_dir vuln.filename in
      let report, control_path, exploit = parse_report output_dir in
      let res =
        { Run_result.pkg; vuln; raw; report; control_path; exploit; timestamp }
      in
      Fmt.epr "%a@." Run_result.pp res;
      Run_result.to_db db res;
      res :: acc )
    [] vulns

let timestamp =
  let now = Unix.localtime @@ Unix.gettimeofday () in
  int_of_string @@ ExtUnix.Specific.strftime "%Y%m%d%H%M%S" now

let prepare_db db =
  let* () = Run_result.prepare_db db in
  Run_metadata.prepare_db db

let main _jobs time_limit output filter index =
  Db.with_db "results.db" @@ fun db ->
  let* () = prepare_db db in
  let output_dir = Fpath.(output / Fmt.str "res-%d" timestamp) in
  let* _ = Bos.OS.Dir.create ~path:true output_dir in
  let metadata =
    { Run_metadata.timestamp; time_limit; output_dir; filter; index }
  in
  Fmt.epr "%a@." Run_metadata.pp metadata;
  Run_metadata.to_db db metadata;
  let* pkgs = Json_index.Parse.from_file index in
  let results = List.concat_map (work db metadata) pkgs in
  Ok (Run_result.to_csv results Fpath.(output_dir / "results.csv"))
