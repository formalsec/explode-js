open I2
open Smtml.Syntax.Result

type options =
  { debug : bool
  ; config : Fpath.t
  ; filename : Fpath.t option
  ; workspace_dir : Fpath.t
  ; time_limit : float
  }

let options debug config filename workspace_dir time_limit =
  { debug; config; filename; workspace_dir; time_limit }

let get_tests workspace (config : Fpath.t) (filename : Fpath.t option) =
  let file = Option.map Fpath.to_string filename in
  let config = Fpath.to_string config in
  let output = Fpath.(to_string @@ (workspace / "symbolic_test")) in
  Run.run ~mode:0o666 ?file ~config ~output ()

let run_with_timeout limit f =
  let exception Sigchld in
  let open Unix in
  let did_timeout = ref false in
  let pid = fork () in
  if pid = 0 then begin
    exit (f ())
  end
  else begin
    ( try
        Sys.set_signal Sys.sigchld (Signal_handle (fun _ -> raise Sigchld));
        Unix.sleepf limit;
        did_timeout := true;
        Unix.kill pid Sys.sigkill;
        Sys.set_signal Sys.sigchld Signal_default
      with Sigchld -> () );
    let chldpid, status = waitpid [] pid in
    assert (chldpid = pid);
    if !did_timeout then `Timeout
    else
      match status with
      | WEXITED n -> `Ok n
      | WSIGNALED _ | WSTOPPED _ -> `Timeout
  end

let run_single ~time_limit ~(workspace : Fpath.t) debug (filename : Fpath.t)
  original_file taint_summary : int =
  let original_file = Option.map Fpath.to_string original_file in
  let taint_summary = Fpath.to_string taint_summary in
  let f () =
    let n =
      Cmd_symbolic.main { debug; filename; entry_func = "main"; workspace } ()
    in
    if n <> 0 then n
    else begin
      match
        Cmd_replay.replay ?original_file ~taint_summary filename workspace
      with
      | Error (`Msg msg) ->
        Logs.err (fun m -> m "%s" msg);
        1
      | Ok () -> 0
    end
  in
  let result =
    if time_limit > 0.0 then run_with_timeout time_limit f else `Ok (f ())
  in
  match result with
  | `Ok n -> n
  | `Timeout ->
    Logs.warn (fun m -> m "Reached time limit");
    4

let run_all ({ debug; config; filename; workspace_dir; time_limit } : options) =
  let* _ = Bos.OS.Dir.create ~mode:0o777 workspace_dir in
  let* symbolic_tests = get_tests workspace_dir config filename in
  let rec loop = function
    | [] -> Ok 0
    | test :: remaning ->
      let workspace = Fpath.(workspace_dir // rem_ext (base test)) in
      let n = run_single ~time_limit ~workspace debug test filename config in
      if n <> 0 then Error (`Status n) else loop remaning
  in
  loop symbolic_tests

let main opts =
  match run_all opts with
  | Ok n -> n
  | Error err -> (
    match err with
    | #I2.Result.err as error ->
      Logs.err (fun m -> m "%a" I2.Result.pp error);
      I2.Result.to_code error
    | `Status n ->
      Logs.err (fun m -> m "Failed during symbolic execution/confirmation");
      n )
