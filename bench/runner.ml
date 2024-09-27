open Bos
module Json = Yojson.Basic

let ( let* ) = Result.bind

let list_bind_map f l =
  let rec list_bind_map_cps f l k =
    match l with
    | [] -> k (Ok [])
    | hd :: tl ->
      list_bind_map_cps f tl @@ fun rest ->
      let* rest in
      let* hd = f hd in
      k (Ok (hd :: rest))
  in
  list_bind_map_cps f l Fun.id

type 'a benchmarks =
  { cwe22 : 'a
  ; cwe78 : 'a
  ; cwe94 : 'a
  ; cwe471 : 'a
  ; cwe1321 : 'a
  }

let log fmt k = match fmt with None -> () | Some fmt -> k (Fmt.pf fmt)

let filename = Fpath.(v "datasets" / "metadata" / "vulcan-file-index.json")

let config =
  let filename = Fpath.to_string filename in
  Json.from_file ~fname:filename filename

let pp_json fmt v = Json.pretty_print ~std:true fmt v

let fpath = function
  | `String str -> Ok (Fpath.v str)
  | x -> Error (`Msg (Fmt.str "Could not parse string from: %a" pp_json x))

let list parser = function
  | `Null -> Ok []
  | `List l -> list_bind_map parser l
  | x -> Error (`Msg (Fmt.str "Could not parse list from: %a" pp_json x))

let vulcan_prefix =
  Fpath.(v "datasets" / "vulcan-dataset" / "_build" / "packages")

let set_prefix_path_for cwe p = Fpath.(vulcan_prefix / cwe // p)

let parsed_benchmarks =
  let* cwe22 = list fpath @@ Json.Util.member "packages/CWE-22" config in
  let* cwe78 = list fpath @@ Json.Util.member "packages/CWE-78" config in
  let* cwe94 = list fpath @@ Json.Util.member "packages/CWE-94" config in
  let* cwe471 = list fpath @@ Json.Util.member "packages/CWE-471" config in
  let* cwe1321 = list fpath @@ Json.Util.member "packages/CWE-1321" config in
  Ok { cwe22; cwe78; cwe94; cwe471; cwe1321 }

let benchmarks =
  let* { cwe22; cwe78; cwe94; cwe471; cwe1321 } = parsed_benchmarks in
  let cwe22 = List.map (set_prefix_path_for "CWE-22") cwe22 in
  let cwe78 = List.map (set_prefix_path_for "CWE-78") cwe78 in
  let cwe94 = List.map (set_prefix_path_for "CWE-94") cwe94 in
  let cwe471 = List.map (set_prefix_path_for "CWE-471") cwe471 in
  let cwe1321 = List.map (set_prefix_path_for "CWE-1321") cwe1321 in
  Ok { cwe22; cwe78; cwe94; cwe471; cwe1321 }

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

(* TODO: use marker instead *)
let pp_status fmt = function
  | `Timeout -> Fmt.pf fmt "Timeout"
  | `Exited n -> Fmt.pf fmt "Exited %a" Fmt.int n
  | `Signaled n -> Fmt.pf fmt "Signaled %a" Fmt.int n
  | `Stopped n -> Fmt.pf fmt "Stopped %a" Fmt.int n

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
  ( ( if !did_timeout then `Timeout
      else
        match status with
        | WEXITED code -> `Exited code
        | WSIGNALED code -> `Signaled code
        | WSTOPPED code -> `Stopped code )
  , duration )

let dup2 src dst =
  let file = Unix.openfile (Fpath.to_string dst) [ O_CREAT; O_WRONLY ] 0o666 in
  Fun.protect ~finally:(fun () -> Unix.close file) @@ fun () ->
  Unix.dup2 file src

let fork_work fmt timeout output benchmark =
  let benchmark = Fpath.normalize benchmark in
  let short_path =
    match Fpath.rem_prefix vulcan_prefix benchmark with
    | Some path -> path
    | None -> assert false
  in
  let workspace_dir = Fpath.(output // short_path) in
  ( match OS.Dir.create ~path:true ~mode:0o777 workspace_dir with
  | Ok _ -> ()
  | Error (`Msg err) -> Fmt.failwith "%s" err );
  let out = Fpath.(workspace_dir / "stdout") in
  let err = Fpath.(workspace_dir / "stderr") in
  let result, duration =
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
      m "@[<v 2>Run %a@;%a in %a@]@." Fpath.pp workspace_dir pp_status result
        Fmt.float duration )

let map_fork_work fmt time_limit output l =
  List.map (fork_work fmt time_limit output) l

let main _jobs timeout output =
  let* { cwe22; cwe78; cwe94; cwe471; cwe1321 } = benchmarks in
  let output = Fpath.(output // results_dir) in
  let* _ = OS.Dir.create ~path:true ~mode:0o777 output in
  Out_channel.with_open_text Fpath.(to_string (output / "results")) @@ fun oc ->
  let fmt = Some (Format.formatter_of_out_channel oc) in
  log fmt (fun m -> m "Started at %a@." pp_time started_at);
  let results =
    { cwe22 = map_fork_work fmt timeout output cwe22
    ; cwe78 = map_fork_work fmt timeout output cwe78
    ; cwe94 = map_fork_work fmt timeout output cwe94
    ; cwe471 = map_fork_work fmt timeout output cwe471
    ; cwe1321 = map_fork_work fmt timeout output cwe1321
    }
  in
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
