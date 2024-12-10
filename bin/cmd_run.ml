let ( let* ) = Result.bind

let get_tests workspace (config : Fpath.t) (filename : Fpath.t option) =
  let file = Option.map Fpath.to_string filename in
  let config = Fpath.to_string config in
  let output = Fpath.(to_string @@ (workspace / "symbolic_test")) in
  I2.Run.run ~mode:0o666 ?file ~config ~output ()

let run_single ~(workspace : Fpath.t) (test : Fpath.t) filename taint_summary =
  let original_file = Option.map Fpath.to_string filename in
  let taint_summary = Fpath.to_string taint_summary in
  let* sym_result =
    Cmd_symbolic.run ~filename:test ~entry_func:"main" ~workspace
  in
  let* () =
    Cmd_replay.replay ?original_file ~taint_summary test workspace sym_result
  in
  let report_path = Fpath.(workspace / "report.json") in
  let report = Sym_result.to_json sym_result in
  Bos.OS.File.writef ~mode:0o666 report_path "%a"
    (Yojson.pretty_print ~std:true)
    report

let run ~config ~filename ~workspace_dir ~time_limit:_ =
  let* _ = Bos.OS.Dir.create ~mode:0o777 workspace_dir in
  let* symbolic_tests = get_tests workspace_dir config filename in
  let rec loop = function
    | [] -> Ok 0
    | test :: remaning ->
      let workspace = Fpath.(workspace_dir // rem_ext (base test)) in
      let* () = run_single ~workspace test filename config in
      loop remaning
  in
  loop symbolic_tests
