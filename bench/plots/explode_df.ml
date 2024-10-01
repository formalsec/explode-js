open Explode_js_bench

let debug = false

let debug k = if debug then k Format.eprintf

let _ = debug

type series =
  { mutable benchmark : string list
  ; mutable cwe : string list
  ; mutable marker : string list
  ; mutable rtime : float list
  ; mutable static_time : float list
  ; mutable symb_time : float list
  }

let empty_series () =
  { benchmark = []
  ; cwe = []
  ; marker = []
  ; rtime = []
  ; static_time = []
  ; symb_time = []
  }

let header
  { benchmark = _
  ; cwe = _
  ; marker = _
  ; rtime = _
  ; static_time = _
  ; symb_time = _
  } =
  [| "benchmark"; "cwe"; "marker"; "rtime"; "static_time"; "symb_time" |]

let parse_cwe =
  let pattern = Dune_re.(compile @@ Perl.re {|.*(CWE-\d+).*|}) in
  fun path ->
    match Dune_re.exec_opt pattern path with
    | None -> "CWE-XX"
    | Some group -> Dune_re.Group.get group 1

let parse_line series line =
  let line = String.trim line in
  match String.split_on_char ' ' line with
  | [ "Run"; filename ] ->
    series.benchmark <- filename :: series.benchmark;
    series.cwe <- parse_cwe filename :: series.cwe
  | [ "Exited"; code; _; total_time ] ->
    series.marker <-
      Marker.(to_string @@ exited @@ int_of_string code) :: series.marker;
    series.rtime <- float_of_string total_time :: series.rtime;
    series.static_time <- 0.0 :: series.static_time;
    series.symb_time <- 0.0 :: series.symb_time
  | [ "Timeout"; _; total_time ] ->
    series.marker <- Marker.(to_string timeout) :: series.marker;
    series.rtime <- float_of_string total_time :: series.rtime;
    series.static_time <- 0.0 :: series.static_time;
    series.symb_time <- 0.0 :: series.symb_time
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
         ; Dataframe.pack_float_series @@ Array.of_list series.rtime
         ; Dataframe.pack_float_series @@ Array.of_list series.static_time
         ; Dataframe.pack_float_series @@ Array.of_list series.symb_time
        |]
  in
  Format.printf "%a" Owl_pretty.pp_dataframe df;
  Ok (Dataframe.to_csv ~sep:',' df "explode-vulcan-results.csv")

let () = match main () with Ok () -> exit 0 | Error (`Msg err) -> failwith err
