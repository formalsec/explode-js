open I2
open Ecma_sl.Syntax.Result

type options =
  { config : Fpath.t
  ; filename : Fpath.t option
  ; workspace_dir : Fpath.t
  ; time_limit : float
  }

let options config filename workspace_dir time_limit =
  { config; filename; workspace_dir; time_limit }

let get_tests workspace (config : Fpath.t) (filename : Fpath.t option) =
  let file = Option.map Fpath.to_string filename in
  let config = Fpath.to_string config in
  let output = Fpath.(to_string @@ (workspace / "symbolic_test")) in
  Run.run ~mode:0o666 ?file ~config ~output ()

let run_single ~time_limit:_ ~(workspace : Fpath.t) (filename : Fpath.t)
  original_file taint_summary : int =
  let original_file = Option.map Fpath.to_string original_file in
  let taint_summary = Fpath.to_string taint_summary in
  let n = Cmd_symbolic.main { filename; entry_func = "main"; workspace } () in
  if n <> 0 then n
  else begin
    match
      Cmd_replay.replay ?original_file ~taint_summary filename workspace
    with
    | Error (`Msg msg) ->
      Format.eprintf "%s" msg;
      1
    | Ok () -> 0
  end

let run_all ({ config; filename; workspace_dir; time_limit } : options) =
  let* _ = Bos.OS.Dir.create ~mode:0o777 workspace_dir in
  let* symbolic_tests = get_tests workspace_dir config filename in
  let rec loop = function
    | [] -> Ok 0
    | test :: remaning ->
      let workspace = Fpath.(workspace_dir // rem_ext (base test)) in
      let n = run_single ~time_limit ~workspace test filename config in
      if n <> 0 then Error (`Status n) else loop remaning
  in
  loop symbolic_tests

let main opts =
  match run_all opts with
  | Ok n -> n
  | Error err -> (
    match err with
    | #I2.Result.err as error ->
      Format.eprintf "error: %a@." I2.Result.pp error;
      I2.Result.to_code error
    | `Status n ->
      Format.eprintf "error: Failed during symbolic execution/confirmation@.";
      n )
