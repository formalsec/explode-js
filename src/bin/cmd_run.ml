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

let run_with_timeout limit f =
  let exception Out_of_time in
  let set_timer limit =
    ignore
    @@ Unix.setitimer Unix.ITIMER_REAL
         Unix.{ it_value = limit; it_interval = 0.01 }
  in
  let unset () =
    ignore
    @@ Unix.setitimer Unix.ITIMER_REAL Unix.{ it_value = 0.; it_interval = 0. }
  in
  set_timer limit;
  Sys.set_signal Sys.sigalrm (Sys.Signal_handle (fun _ -> raise Out_of_time));
  let f () = try `Ok (f ()) with Out_of_time -> `Timeout in
  Fun.protect f ~finally:unset

let run_single ~time_limit ~(workspace : Fpath.t) (filename : Fpath.t) : int =
  let result =
    run_with_timeout time_limit (fun () ->
        let n =
          Cmd_symbolic.main { filename; entry_func = "main"; workspace } ()
        in
        if n <> 0 then n else Cmd_replay.main { filename; workspace } () )
  in
  match result with
  | `Ok n -> n
  | `Timeout ->
    Format.eprintf "warning: Reached time limit@.";
    4

let run_all ({ config; filename; workspace_dir; time_limit } : options) =
  let* _ = Bos.OS.Dir.create ~mode:0o777 workspace_dir in
  let* symbolic_tests = get_tests workspace_dir config filename in
  let rec loop = function
    | [] -> Ok 0
    | test :: remaning ->
      let workspace = Fpath.(workspace_dir // rem_ext (base test)) in
      let n = run_single ~time_limit ~workspace test in
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
