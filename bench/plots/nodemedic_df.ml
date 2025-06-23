open Explode_js_bench
module Json = Yojson.Basic

let debug = false

let debug k = if debug then k Format.eprintf

let ( let* ) = Result.bind

type series =
  { mutable benchmark : string list
  ; mutable cwe : string list
  ; mutable marker : string list
  ; mutable fuzz_time : float list
  ; mutable expl_time : float list
  ; mutable total_time : float list
  ; mutable taintpath : string list
  ; mutable exploit : string list
  }

let empty_series () =
  { benchmark = []
  ; cwe = []
  ; marker = []
  ; fuzz_time = []
  ; expl_time = []
  ; total_time = []
  ; taintpath = []
  ; exploit = []
  }

let header
  { benchmark = _
  ; cwe = _
  ; marker = _
  ; fuzz_time = _
  ; expl_time = _
  ; total_time = _
  ; taintpath = _
  ; exploit = _
  } =
  [| "benchmark"
   ; "cwe"
   ; "marker"
   ; "fuzz_time"
   ; "expl_time"
   ; "total_time"
   ; "taintpath"
   ; "exploit"
  |]

let parse_run_times =
  let pattern = Dune_re.Perl.re {|([\d.]+)|} in
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
          let time = float_of_string @@ Dune_re.Group.get group 1 in
          debug (fun k -> k "parse_time: %f@." time);
          loop (("real", time) :: acc) )
    in
    loop []

(* What *)
let parse_cwe =
  let index =
    let index_file = Fpath.(v "explodejs-datasets" / "index.json") in
    Yojson.Basic.from_file Fpath.(to_string index_file)
    |> Yojson.Basic.Util.to_list
  in
  let re =
    Dune_re.(
      compile
      @@ Perl.re
           {|([a-zA-Z0-9-]+)-(\d+\.\d+\.\d+(?:-[a-zA-Z0-9]+\.\d+)?(?:-[a-zA-Z0-9]+)?)|} )
  in
  fun path ->
    let basename = Fpath.(basename (v path)) in
    let package, _version =
      let group = Dune_re.exec re basename in
      (Dune_re.Group.get group 1, Dune_re.Group.get group 2)
    in
    let pkg =
      List.find_opt
        (fun json ->
          String.equal
            Yojson.Basic.Util.(to_string (member "package" json))
            package )
        index
    in
    Option.map
      (fun pkg ->
        let vulns = Yojson.Basic.Util.(to_list (member "vulns" pkg)) in
        let vuln0 = List.hd vulns in
        Yojson.Basic.Util.(to_string (member "cwe" vuln0)) )
      pkg

let task_time_or_zero = function
  | `Null -> 0.
  | json -> Json.Util.(to_number @@ member "time" json)

let find_taint =
  let re =
    Dune_re.(
      compile @@ Perl.re ".*Found the following input that causes a flow.*" )
  in
  fun str -> Dune_re.execp re str

let find_expl =
  let re = Dune_re.(compile @@ Perl.re ".*Exploit(s) found for functions:.*") in
  fun str -> Dune_re.execp re str

let parse_results results_file stdout_file =
  let file = Fpath.to_string results_file in
  let json = Json.from_file ~fname:file file in
  let results = Json.Util.(to_list @@ member "rows" json) in
  assert (List.length results = 1);
  let results = List.hd results in
  let task_results = Json.Util.member "taskResults" results in
  let fuzz_time =
    Json.Util.member "runInstrumented" task_results |> task_time_or_zero
  in
  let expl0 =
    Json.Util.member "trivialExploit" task_results |> task_time_or_zero
  in
  let expl1 =
    Json.Util.member "checkExploit" task_results |> task_time_or_zero
  in
  let expl2 = Json.Util.member "smt" task_results |> task_time_or_zero in
  let has_taintpath, has_exploit =
    In_channel.with_open_text (Fpath.to_string stdout_file) @@ fun ic ->
    let data = In_channel.input_all ic in
    (string_of_bool @@ find_taint data, string_of_bool @@ find_expl data)
  in
  ( fuzz_time /. 1000.
  , (expl0 +. expl1 +. expl2) /. 1000.
  , has_taintpath
  , has_exploit )

let parse_results series dir =
  let result =
    let results_dir = Fpath.to_string dir in
    assert (Sys.is_directory results_dir);
    let* marker_file = File.find Fpath.(dir / "**" / "finished.marker") in
    let marker = Marker.from_file marker_file in
    let cwe =
      match parse_cwe @@ Fpath.to_string dir with
      | Some cwe -> cwe
      | None -> "CWE-XYZ"
    in
    match marker with
    | Timeout ->
      series.benchmark <- results_dir :: series.benchmark;
      series.cwe <- cwe :: series.cwe;
      series.marker <- Marker.to_string marker :: series.marker;
      series.fuzz_time <- Float.nan :: series.fuzz_time;
      series.expl_time <- Float.nan :: series.expl_time;
      series.total_time <- 600.0 :: series.total_time;
      series.taintpath <- "false" :: series.taintpath;
      series.exploit <- "false" :: series.exploit;
      Ok ()
    | _ ->
      let* time_file =
        File.find Fpath.(dir / "**" / "NodeMedic-docker-duration-seconds.txt")
      in
      let results_file = Fpath.(dir / "results.json") in
      let* stdout_file = File.find Fpath.(dir / "**" / "PID-*.stdout.log") in
      let run_times = parse_run_times time_file in
      let fuzz_time, expl_time, has_taintpath, has_exploit =
        parse_results results_file stdout_file
      in
      series.benchmark <- results_dir :: series.benchmark;
      series.cwe <- cwe :: series.cwe;
      series.marker <- Marker.to_string marker :: series.marker;
      series.fuzz_time <- fuzz_time :: series.fuzz_time;
      series.expl_time <- expl_time :: series.expl_time;
      series.total_time <- List.assoc "real" run_times :: series.total_time;
      series.taintpath <- has_taintpath :: series.taintpath;
      series.exploit <- has_exploit :: series.exploit;
      Ok ()
  in
  match result with
  | Ok res -> res
  | Error (`Msg err) -> failwith err

let main () =
  let open Owl in
  let* results =
    (*   let* vulcan = *)
    (*     File.find_all Fpath.(v "results/nodemedic/20240906-vulcan/**/*_NodeMedic") *)
    (*   in *)
    (*   let* secbench = *)
    (*     File.find_all *)
    (*       Fpath.(v "results/nodemedic/20240906-secbench/**/*_NodeMedic") *)
    (*   in *)
    (*   Ok (vulcan @ secbench) *)
    File.find_all Fpath.(v "results/nodemedic/zeroday/**/*_NodeMedic")
  in
  let series = empty_series () in
  List.iter (parse_results series) results;
  let df =
    Dataframe.make (header series)
      ~data:
        [| Dataframe.pack_string_series @@ Array.of_list series.benchmark
         ; Dataframe.pack_string_series @@ Array.of_list series.cwe
         ; Dataframe.pack_string_series @@ Array.of_list series.marker
         ; Dataframe.pack_float_series @@ Array.of_list series.fuzz_time
         ; Dataframe.pack_float_series @@ Array.of_list series.expl_time
         ; Dataframe.pack_float_series @@ Array.of_list series.total_time
         ; Dataframe.pack_string_series @@ Array.of_list series.taintpath
         ; Dataframe.pack_string_series @@ Array.of_list series.exploit
        |]
  in
  Format.printf "%a" Owl_pretty.pp_dataframe df;
  (* let csv_output_path = "nodemedic-vulcan-secbench-results.csv" in *)
  let csv_output_path = "nodemedic-vulcan-zeroday.csv" in
  Ok (Dataframe.to_csv ~sep:',' df csv_output_path)

let () =
  match main () with
  | Ok () -> exit 0
  | Error (`Msg err) -> failwith err
