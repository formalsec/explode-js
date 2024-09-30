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
  ; mutable solv_time : float list
  ; mutable detection : string list
  ; mutable exploit : string list
  }

let empty_series () =
  { benchmark = []
  ; cwe = []
  ; marker = []
  ; rtime = []
  ; utime = []
  ; stime = []
  ; solv_time = []
  ; detection = []
  ; exploit = []
  }

let header
  { benchmark = _
  ; cwe = _
  ; marker = _
  ; rtime = _
  ; utime = _
  ; stime = _
  ; solv_time = _
  ; detection = _
  ; exploit = _
  } =
  [| "benchmark"
   ; "cwe"
   ; "marker"
   ; "rtime"
   ; "utime"
   ; "stime"
   ; "solv_time"
   ; "detection"
   ; "exploit"
  |]

let parse_time =
  let re = Dune_re.(compile @@ Perl.re {|(real|user|sys)\s+(\d+)m([\d.]+)s|}) in
  fun file ->
    In_channel.with_open_text (Fpath.to_string file) @@ fun ic ->
    let rec loop acc =
      match In_channel.input_line ic with
      | None -> acc
      | Some line -> (
        debug (fun k -> k "parse_time: line: %s@." line);
        let group = Dune_re.exec_opt re line in
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
  let re = Dune_re.(compile @@ Perl.re {|.*(CWE-\d+).*|}) in
  fun path ->
    match Dune_re.exec_opt re path with
    | None -> "CWE-XX"
    | Some group -> Dune_re.Group.get group 1

let parse_answer =
  let det_re = Dune_re.(compile @@ Perl.re {|Detection:\s+(\w+)|}) in
  let exp_re = Dune_re.(compile @@ Perl.re {|Exploit:\s+(\w+)|}) in
  fun file ->
    In_channel.with_open_text Fpath.(to_string file) @@ fun ic ->
    let contents = In_channel.input_all ic in
    let detection = Dune_re.exec_opt det_re contents in
    let detection = Option.map (fun g -> Dune_re.Group.get g 1) detection in
    let exploit = Dune_re.exec_opt exp_re contents in
    let exploit = Option.map (fun g -> Dune_re.Group.get g 1) exploit in
    (detection, exploit)

let parse_solv_time =
  let re =
    Dune_re.(compile @@ Perl.re {|"pass":\s+"3",\s+"time":\s+([0-9.]+)|})
  in
  fun file ->
    In_channel.with_open_text Fpath.(to_string file) @@ fun ic ->
    let contents = In_channel.input_all ic in
    let solv_time = Dune_re.exec_opt re contents in
    Option.map (fun g -> float_of_string @@ Dune_re.Group.get g 1) solv_time

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
      series.utime <- Float.nan :: series.utime;
      series.stime <- Float.nan :: series.stime;
      series.solv_time <- Float.nan :: series.solv_time;
      series.detection <- "failed" :: series.detection;
      series.exploit <- "failed" :: series.exploit;
      Ok ()
    | Exited 1 ->
      let* time_file = File.find Fpath.(dir / "**" / "time.txt") in
      let times = parse_time time_file in
      series.benchmark <- results_dir :: series.benchmark;
      series.cwe <- cwe :: series.cwe;
      series.marker <- Marker.to_string marker :: series.marker;
      series.rtime <- List.assoc "real" times :: series.rtime;
      series.utime <- List.assoc "user" times :: series.utime;
      series.stime <- List.assoc "sys" times :: series.stime;
      series.solv_time <- Float.nan :: series.solv_time;
      series.detection <- "failed" :: series.detection;
      series.exploit <- "failed" :: series.exploit;
      Ok ()
    | _ ->
      let* time_file = File.find Fpath.(dir / "**" / "time.txt") in
      let times = parse_time time_file in
      let* eval_ndjson = File.find Fpath.(dir / "**" / "evaluation.ndjson") in
      let solv_time = parse_solv_time eval_ndjson in
      let* log_file = File.find Fpath.(dir / "**" / "fast-stdout.log") in
      let det, exp = parse_answer log_file in
      series.benchmark <- results_dir :: series.benchmark;
      series.cwe <- cwe :: series.cwe;
      series.marker <- Marker.to_string marker :: series.marker;
      series.rtime <- List.assoc "real" times :: series.rtime;
      series.utime <- List.assoc "user" times :: series.utime;
      series.stime <- List.assoc "sys" times :: series.stime;
      series.solv_time <-
        Option.value solv_time ~default:Float.nan :: series.solv_time;
      series.detection <- Option.value det ~default:"failed" :: series.detection;
      series.exploit <- Option.value exp ~default:"failed" :: series.exploit;
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
         ; Dataframe.pack_float_series @@ Array.of_list series.solv_time
         ; Dataframe.pack_string_series @@ Array.of_list series.detection
         ; Dataframe.pack_string_series @@ Array.of_list series.exploit
        |]
  in
  Format.printf "%a" Owl_pretty.pp_dataframe df;
  Ok (Dataframe.to_csv ~sep:',' df "fast-vulcan-secbench-results.csv")

let () = match main () with Ok () -> exit 0 | Error (`Msg err) -> failwith err
