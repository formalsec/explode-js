open Bos
open Syntax.Result
open Explode_js_bench

let log fmt k = match fmt with None -> () | Some fmt -> k (Fmt.pf fmt)

let datasets_dir = Fpath.v "explodejs-datasets"

let filename = Fpath.(datasets_dir / "index.json")

let benchmarks =
  let benchmarks = Index.from_file (Fpath.to_string filename) in
  List.map (Fpath.append datasets_dir) benchmarks

let started_at = Unix.localtime @@ Unix.gettimeofday ()

let pp_time fmt
  ({ tm_year; tm_mon; tm_mday; tm_hour; tm_min; tm_sec; _ } : Unix.tm) =
  Fmt.pf fmt "%04d%02d%02dT%02d%02d%02d" (tm_year + 1900) (tm_mon + 1) tm_mday
    tm_hour tm_min tm_sec

let results_dir = Fpath.(v (Fmt.str "res-%a" pp_time started_at))

let explode ~workspace_dir ~file time_limit =
  Cmd.(
    v "explode-js" % "full" % "--workspace" % p workspace_dir % "--timeout"
    % string_of_float time_limit % p file )

let wait_pid pid timeout =
  let exception Sigchld in
  let did_timeout = ref false in
  let start_time = Unix.gettimeofday () in
  let () =
    try
      Sys.set_signal Sys.sigchld (Signal_handle (fun _ -> raise Sigchld));
      Unix.sleepf timeout;
      did_timeout := true;
      Unix.kill ~-pid Sys.sigkill;
      Sys.set_signal Sys.sigchld Signal_default
    with Sigchld -> ()
  in
  Sys.set_signal Sys.sigchld Signal_default;
  let waited_pid, status = Unix.waitpid [] ~-pid in
  assert (waited_pid = pid);
  let duration = Unix.gettimeofday () -. start_time in
  ( ( if !did_timeout then Marker.timeout
      else
        match status with
        | WEXITED code -> Marker.exited code
        | WSIGNALED code -> Marker.signaled code
        | WSTOPPED code -> Marker.stopped code )
  , duration )

let dup2 src dst =
  let file = Unix.openfile (Fpath.to_string dst) [ O_CREAT; O_WRONLY ] 0o666 in
  Fun.protect ~finally:(fun () -> Unix.close file) @@ fun () ->
  Unix.dup2 file src

let fork_work fmt timeout output benchmark =
  let benchmark = Fpath.normalize benchmark in
  let workspace_dir = Fpath.(output // benchmark) in
  ( match OS.Dir.create ~path:true ~mode:0o777 workspace_dir with
  | Ok _ -> ()
  | Error (`Msg err) -> Fmt.failwith "%s" err );
  let out = Fpath.(workspace_dir / "stdout") in
  let err = Fpath.(workspace_dir / "stderr") in
  let marker, duration =
    let pid = Unix.fork () in
    if pid = 0 then begin
      ExtUnix.Specific.setpgid 0 0;
      dup2 Unix.stdout out;
      dup2 Unix.stderr err;
      let args = explode ~workspace_dir ~file:benchmark timeout in
      Unix.execvp "explode-js" (Array.of_list @@ Cmd.to_list args)
    end
    else wait_pid pid timeout
  in
  log fmt (fun m ->
      m "@[<v 2>Run %a@;%a in %a@]@." Fpath.pp workspace_dir Marker.pp marker
        Fmt.float duration )

let map_fork_work fmt time_limit output l =
  List.map (fork_work fmt time_limit output) l

let main _jobs timeout output =
  let output = Fpath.(output // results_dir) in
  let* _ = OS.Dir.create ~path:true ~mode:0o777 output in
  Out_channel.with_open_text Fpath.(to_string (output / "results")) @@ fun oc ->
  let fmt = Some (Format.formatter_of_out_channel oc) in
  log fmt (fun m -> m "Started at %a@." pp_time started_at);
  let results = map_fork_work fmt timeout output benchmarks in
  Ok results

let cli =
  let open Cmdliner in
  let fpath = ((fun str -> `Ok (Fpath.v str)), Fpath.pp) in
  let jobs =
    let doc = "Number of threads to use (currently ignored)" in
    Arg.(value & opt int 1 & info [ "jobs" ] ~doc)
  in
  let timeout =
    let doc = "Time limit per benchmark run" in
    Arg.(value & opt float 60. & info [ "timeout" ] ~doc)
  in
  let output =
    let doc = "Output directory to store results" in
    Arg.(value & opt fpath (Fpath.v ".") & info [ "output" ] ~doc)
  in
  let doc = "Explode-js benchmark runner" in
  let info = Cmd.info "runner" ~doc in
  Cmd.v info Term.(const main $ jobs $ timeout $ output)

let () =
  match Cmdliner.Cmd.eval_value' cli with
  | `Exit n -> exit n
  | `Ok v -> (
    match v with
    | Ok _ -> exit 0
    | Error (`Msg err) ->
      Fmt.epr "@[<hov>unexpected error:@ %s@]@." err;
      exit 1 )
