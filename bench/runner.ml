open Bos

[@@@ocaml.warning "-32"]

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

let filename = Fpath.v "vulcan-22-78-94-471-1321-all.json"

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

let explode ~workspace_dir ~file time_limit =
  let cmd0 = Cmd.(v "explode-js" % "full" % "--workspace" % p workspace_dir) in
  match time_limit with
  | None -> Cmd.(cmd0 % p file)
  | Some timeout -> Cmd.(cmd0 % "--timeout" % string_of_int timeout % p file)

let pp_status fmt = function
  | `Exited n -> Fmt.pf fmt "Exited %a" Fmt.int n
  | `Signaled n -> Fmt.pf fmt "Signaled %a" Fmt.int n

(* FIXME: Maybe we could return the error instead of raising an exception? *)
let run_worker timeout output benchmark =
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
  let err = OS.Cmd.err_file @@ Fpath.(workspace_dir / "stderr") in
  let run_out =
    OS.Cmd.run_out ~err @@ explode ~workspace_dir ~file:benchmark timeout
  in
  let status =
    match OS.Cmd.out_file out run_out with
    | Ok ((), (_, status)) -> status
    | Error (`Msg _err) -> Fmt.failwith "Could not write file: %a" Fpath.pp out
  in
  Eio.traceln "@[<v 2>Run %a@;%a@]" Fpath.pp workspace_dir pp_status status

let map_run_worker sw pool timeout output l =
  List.map
    (fun elt ->
      Eio.Executor_pool.submit_fork ~sw pool ~weight:1.0 (fun () ->
          run_worker timeout output elt ) )
    l

let map_wait_worker l =
  List.map
    (fun promise ->
      match Eio.Promise.await promise with
      | Ok () -> ()
      | Error exn -> Fmt.epr "uncaught exception: %s@." (Printexc.to_string exn)
      )
    l

let main _jobs timeout output =
  Fmt.pr "Started at %a@." pp_time started_at;
  let* { cwe22; cwe78; cwe94; cwe471; cwe1321 } = benchmarks in
  let output = Fpath.v @@ Fmt.str "%s-%a" output pp_time started_at in
  let* _ = OS.Dir.create ~path:true ~mode:0o777 output in
  Eio_main.run @@ fun env ->
  let domain_mgr = Eio.Stdenv.domain_mgr env in
  Eio.Switch.run @@ fun sw ->
  (* Domain_count = 1 because graphjs can't be run in parallel *)
  let domain_count = 1 in
  let pool = Eio.Executor_pool.create ~sw ~domain_count domain_mgr in
  let { cwe22; cwe78; cwe94; cwe471; cwe1321 } =
    { cwe22 = map_run_worker sw pool timeout output cwe22
    ; cwe78 = map_run_worker sw pool timeout output cwe78
    ; cwe94 = map_run_worker sw pool timeout output cwe94
    ; cwe471 = map_run_worker sw pool timeout output cwe471
    ; cwe1321 = map_run_worker sw pool timeout output cwe1321
    }
  in
  let results =
    { cwe22 = map_wait_worker cwe22
    ; cwe78 = map_wait_worker cwe78
    ; cwe94 = map_wait_worker cwe94
    ; cwe471 = map_wait_worker cwe471
    ; cwe1321 = map_wait_worker cwe1321
    }
  in
  Ok results

let cli =
  let open Cmdliner in
  let jobs =
    let doc = "Number of threads to use (currently ignored)" in
    Arg.(value & opt int 1 & info [ "jobs" ] ~doc)
  in
  let timeout =
    let doc = "Time limit per benchmark run" in
    Arg.(value & opt (some int) None & info [ "timeout" ] ~doc)
  in
  let output =
    let doc = "Output directory to store results" in
    Arg.(value & opt string "res" & info [ "output" ] ~doc)
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
