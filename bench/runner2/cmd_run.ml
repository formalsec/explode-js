open Syntax

let work db ({ timestamp; time_limit; output_dir; filter; _ } : Run_metadata.t)
  (pkg : Package.t) : Run_result.t list =
  let vulns =
    match filter with
    | None -> pkg.vulns
    | Some cwe ->
      List.filter (fun (v : Vulnerability.t) -> Cwe.equal cwe v.cwe) pkg.vulns
  in
  List.fold_left
    (fun acc (vuln : Vulnerability.t) ->
      let base_dir = Fpath.(parent (parent vuln.filename)) in
      let exploit_tmpl = Fpath.(base_dir / "expected_output.json") in
      if not (Sys.file_exists (Fpath.to_string exploit_tmpl)) then acc
      else
        let output_dir = Fpath.(output_dir / string_of_int vuln.id) in
        Core_unix.mkdir_p (Fpath.to_string output_dir);
        let raw =
          Run_action.run time_limit output_dir vuln.filename exploit_tmpl
        in
        let res = { Run_result.pkg; vuln; raw; timestamp } in
        Fmt.epr "%a@." Run_result.pp res;
        Run_result.to_db db res;
        res :: acc )
    [] vulns

let timestamp =
  let now = Unix.localtime @@ Unix.gettimeofday () in
  int_of_string @@ Core_unix.strftime now "%Y%m%d%H%M%S"

let prepare_db db =
  let* () = Run_result.prepare_db db in
  Run_metadata.prepare_db db

let main _jobs time_limit output filter index =
  Db.with_db "results.db" @@ fun db ->
  let* () = prepare_db db in
  let output_dir = Fpath.(output / Fmt.str "res-%d" timestamp) in
  Core_unix.mkdir_p (Fpath.to_string output_dir);
  let metadata =
    { Run_metadata.timestamp; time_limit; output_dir; filter; index }
  in
  Fmt.epr "%a@." Run_metadata.pp metadata;
  Run_metadata.to_db db metadata;
  let* pkgs = Json_index.Parse.from_file index in
  let results = List.concat_map (work db metadata) pkgs in
  Ok (Run_result.to_csv results Fpath.(output_dir / "results.csv"))
