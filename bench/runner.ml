module Json = Yojson.Basic

[@@@ocaml.warning "-69"]

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

type benchmarks =
  { cwe22 : Fpath.t list
  ; cwe78 : Fpath.t list
  ; cwe94 : Fpath.t list
  ; cwe471 : Fpath.t list
  ; cwe1321 : Fpath.t list
  }

let filename = Fpath.v "vulcan-22-78-94-471-1321-all.json"

let config =
  let filename = Fpath.to_string filename in
  Json.from_file ~fname:filename filename

let fpath = function
  | `String str -> Ok (Fpath.v str)
  | x ->
    Error
      (Format.asprintf "Could not parse string from: %a"
         (Json.pretty_print ~std:true)
         x )

let list parser = function
  | `List l -> list_bind_map parser l
  | x ->
    Error
      (Format.asprintf "Could not parse list from: %a"
         (Json.pretty_print ~std:true)
         x )

let set_prefix_path_for cwe p =
  Fpath.(v "datasets" / "vulcan-dataset" / "_build" / "packages" / cwe // p)

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

let p_time fmt
  ({ tm_year; tm_mon; tm_mday; tm_hour; tm_min; tm_sec; _ } : Unix.tm) =
  Format.fprintf fmt "%04d%02d%02dT%02d%02d%02d" (tm_year + 1900) (tm_mon + 1)
    tm_mday tm_hour tm_min tm_sec

let pp_time fmt
  ({ tm_year; tm_mon; tm_mday; tm_hour; tm_min; tm_sec; _ } : Unix.tm) =
  Format.fprintf fmt "%04d-%02d-%02dT%02d:%02d:%02d" (tm_year + 1900)
    (tm_mon + 1) tm_mday tm_hour tm_min tm_sec

let _ = [ p_time; pp_time ]

let run_worker p =
  Eio.traceln "Processing %a" Fpath.pp p;
  Eio_unix.sleep 5.0

let results =
  Format.printf "Started at %a@." pp_time started_at;
  let* benchmarks in
  Eio_main.run @@ fun env ->
  let domain_mgr = Eio.Stdenv.domain_mgr env in
  Eio.Switch.run @@ fun sw ->
  let pool = Eio.Executor_pool.create ~sw ~domain_count:4 domain_mgr in
  let promises =
    List.map
      (fun p ->
        Eio.Executor_pool.submit_fork ~sw pool ~weight:1.0 (fun () ->
            run_worker p ) )
      benchmarks.cwe22
  in
  let results =
    List.map
      (fun promise ->
        match Eio.Promise.await promise with
        | Ok () -> ()
        | Error _exn -> Format.eprintf "An exception was raised@." )
      promises
  in
  Ok results

let () =
  match results with
  | Ok _ -> exit 0
  | Error err ->
    Format.eprintf "@[<v>unexpected error:@ %s@]@." err;
    exit 1
