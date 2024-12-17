open Explode_js

let ( let* ) = Result.bind

let get_tests workspace (config : Fpath.t) (filename : Fpath.t option) =
  let file = Option.map Fpath.to_string filename in
  let config = Fpath.to_string config in
  let output = Fpath.(to_string @@ (workspace / "symbolic_test")) in
  I2.Run.run ~mode:0o666 ?file ~config ~output ()

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

let run ~config ~filename ~workspace_dir ~time_limit:_ =
  let workspace_dir = Fpath.(workspace_dir / "run") in
  let* _ = Bos.OS.Dir.create ~path:true ~mode:0o777 workspace_dir in
  let* symbolic_tests = get_tests workspace_dir config filename in
  let rec loop results = function
    | [] -> Ok results
    | test :: remaning ->
      let workspace = Fpath.(workspace_dir // rem_ext (base test)) in
      let* sym_result = run_single ~workspace test filename config in
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
