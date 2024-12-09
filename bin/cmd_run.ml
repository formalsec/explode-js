open I2
open Ecma_sl.Syntax.Result

let get_tests workspace (config : Fpath.t) (filename : Fpath.t option) =
  let file = Option.map Fpath.to_string filename in
  let config = Fpath.to_string config in
  let output = Fpath.(to_string @@ (workspace / "symbolic_test")) in
  Run.run ~mode:0o666 ?file ~config ~output ()

let run_single ~(workspace : Fpath.t) (filename : Fpath.t) original_file
  taint_summary =
  let original_file = Option.map Fpath.to_string original_file in
  let taint_summary = Fpath.to_string taint_summary in
  let* () = Cmd_symbolic.run ~filename ~entry_func:"main" ~workspace in
  Cmd_replay.replay ?original_file ~taint_summary filename workspace

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
