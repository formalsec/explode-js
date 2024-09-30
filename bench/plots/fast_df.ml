open Explode_js_bench

let debug = false

let debug k = if debug then k Format.eprintf

let ( let* ) = Result.bind

type series =
  { mutable benchmark : string list
  ; mutable cwe : string list
  ; mutable marker : string list
  ; mutable rtime : float list
  ; mutable utime : float list
  ; mutable stime : float list
  }

let empty_series () =
  { benchmark = []; cwe = []; marker = []; rtime = []; utime = []; stime = [] }

let header
  { benchmark = _; cwe = _; marker = _; rtime = _; utime = _; stime = _ } =
  [| "benchmark"; "cwe"; "marker"; "rtime"; "utime"; "stime" |]

let parse_time =
  let pattern = Dune_re.Perl.re {|(real|user|sys)\s+(\d+)m([\d.]+)s|} in
  let pattern = Dune_re.compile pattern in
  fun file ->
    In_channel.with_open_text (Fpath.to_string file) @@ fun ic ->
    let rec loop acc =
      match In_channel.input_line ic with
      | None -> acc
      | Some line -> (
        debug (fun k -> k "parse_time: line: %s@." line);
        let group = Dune_re.exec_opt pattern line in
        match group with
        | None ->
          debug (fun k -> k "parse_time: no match@.");
          loop acc
        | Some group ->
          let t = Dune_re.Group.get group 1 in
          let m = float_of_string @@ Dune_re.Group.get group 2 in
          let s = float_of_string @@ Dune_re.Group.get group 3 in
          let s = (m *. 60.) +. s in
          debug (fun k -> k "parse_time: %s %f@." t s);
          loop ((t, s) :: acc) )
    in
    loop []

let parse_cwe =
  let pattern = Dune_re.(compile @@ Perl.re {|.*(CWE-\d+).*|}) in
  fun path ->
    match Dune_re.exec_opt pattern path with
    | None -> "CWE-XX"
    | Some group -> Dune_re.Group.get group 1

let parse_results series dir =
  let result =
    let results_dir = Fpath.to_string dir in
    assert (Sys.is_directory results_dir);
    let* marker_file = File.find Fpath.(dir / "**" / "finished.marker") in
    let marker = Marker.from_file marker_file in
    let cwe = parse_cwe @@ Fpath.to_string marker_file in
    match marker with
    | Timeout ->
      series.benchmark <- results_dir :: series.benchmark;
      series.cwe <- cwe :: series.cwe;
      series.marker <- Marker.to_string marker :: series.marker;
      series.rtime <- 600.0 :: series.rtime;
      series.utime <- 0.0 :: series.utime;
      series.stime <- 0.0 :: series.stime;
      Ok ()
    | _ ->
      let* time_file = File.find Fpath.(dir / "**" / "time.txt") in
      let times = parse_time time_file in
      series.benchmark <- results_dir :: series.benchmark;
      series.cwe <- cwe :: series.cwe;
      series.marker <- Marker.to_string marker :: series.marker;
      series.rtime <- List.assoc "real" times :: series.rtime;
      series.utime <- List.assoc "user" times :: series.utime;
      series.stime <- List.assoc "sys" times :: series.stime;
      Ok ()
  in
  match result with Ok res -> res | Error (`Msg err) -> failwith err

let main () =
  let open Owl in
  let* vulcan = File.find_all Fpath.(v "results/vulcan-fast-out/**/*_fast") in
  let* secbench =
    File.find_all Fpath.(v "results/secbench-fast-out/**/*_fast")
  in
  let series = empty_series () in
  List.iter (parse_results series) vulcan;
  List.iter (parse_results series) secbench;
  let df =
    Dataframe.make (header series)
      ~data:
        [| Dataframe.pack_string_series @@ Array.of_list series.benchmark
         ; Dataframe.pack_string_series @@ Array.of_list series.cwe
         ; Dataframe.pack_string_series @@ Array.of_list series.marker
         ; Dataframe.pack_float_series @@ Array.of_list series.rtime
         ; Dataframe.pack_float_series @@ Array.of_list series.utime
         ; Dataframe.pack_float_series @@ Array.of_list series.stime
        |]
  in
  Format.printf "%a" Owl_pretty.pp_dataframe df;
  Ok (Dataframe.to_csv ~sep:',' df "fast-vulcan-secbench-results.csv")

let () = match main () with Ok () -> exit 0 | Error (`Msg err) -> failwith err
