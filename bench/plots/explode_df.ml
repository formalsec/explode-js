open Explode_js_bench

let debug = false

let debug k = if debug then k Format.eprintf

let _ = debug

type series =
  { mutable benchmark : string list
  ; mutable cwe : string list
  ; mutable marker : string list
  ; mutable static_time : float list
  ; mutable symb_time : float list
  ; mutable total_time : float list
  }

let empty_series () =
  { benchmark = []
  ; cwe = []
  ; marker = []
  ; static_time = []
  ; symb_time = []
  ; total_time = []
  }

let header
  { benchmark = _
  ; cwe = _
  ; marker = _
  ; static_time = _
  ; symb_time = _
  ; total_time = _
  } =
  [| "benchmark"; "cwe"; "marker"; "static_time"; "symb_time"; "total_time" |]

let parse_cwe =
  let pattern = Dune_re.(compile @@ Perl.re {|.*(CWE-\d+).*|}) in
  fun path ->
    match Dune_re.exec_opt pattern path with
    | None -> "CWE-XX"
    | Some group -> Dune_re.Group.get group 1

let parse_time =
  let re = Dune_re.(compile @@ Perl.re {|([\d.]+)|}) in
  fun fpath ->
    let filename = Fpath.to_string fpath in
    if not @@ Sys.file_exists filename then 0.0
    else
      In_channel.with_open_text filename @@ fun ic ->
      let line = String.trim @@ input_line ic in
      float_of_string @@ Dune_re.(Group.get (exec re line) 1)

let parse_times file =
  let file = Fpath.v file in
  let rel_path = Option.get @@ Fpath.rem_prefix (Fpath.v "/bench/") file in
  let static_time = Fpath.(rel_path / "graphjs_time.txt") in
  let symbolic_time = Fpath.(rel_path / "explode_time.txt") in
  (parse_time static_time, parse_time symbolic_time)

let parse_line series line =
  let line = String.trim line in
  match String.split_on_char ' ' line with
  | [ "Run"; filename ] ->
    series.benchmark <- filename :: series.benchmark;
    series.cwe <- parse_cwe filename :: series.cwe
  | [ "Exited"; code; _; total_time ] ->
    series.marker <-
      Marker.(to_string @@ exited @@ int_of_string code) :: series.marker;
    let static_time, symbolic_time = parse_times @@ List.hd series.benchmark in
    series.static_time <- static_time :: series.static_time;
    series.symb_time <- symbolic_time :: series.symb_time;
    series.total_time <- float_of_string total_time :: series.total_time
  | [ "Timeout"; _; total_time ] ->
    series.marker <- Marker.(to_string timeout) :: series.marker;
    series.static_time <- 0.0 :: series.static_time;
    series.symb_time <- 0.0 :: series.symb_time;
    series.total_time <- float_of_string total_time :: series.total_time
  | _ -> Format.ksprintf failwith "could not parse line: %s" line

let parse_results series results_file =
  In_channel.with_open_text results_file @@ fun ic ->
  let lines = In_channel.input_lines ic in
  List.iter (parse_line series) (List.tl lines)

let main () =
  let open Owl in
  let vulcan = "results/res-20240929T012449/results" in
  let series = empty_series () in
  parse_results series vulcan;
  let df =
    Dataframe.make (header series)
      ~data:
        [| Dataframe.pack_string_series @@ Array.of_list series.benchmark
         ; Dataframe.pack_string_series @@ Array.of_list series.cwe
         ; Dataframe.pack_string_series @@ Array.of_list series.marker
         ; Dataframe.pack_float_series @@ Array.of_list series.static_time
         ; Dataframe.pack_float_series @@ Array.of_list series.symb_time
         ; Dataframe.pack_float_series @@ Array.of_list series.total_time
        |]
  in
  Format.printf "%a" Owl_pretty.pp_dataframe df;
  Ok (Dataframe.to_csv ~sep:',' df "explode-vulcan-results.csv")

let () = match main () with Ok () -> exit 0 | Error (`Msg err) -> failwith err
