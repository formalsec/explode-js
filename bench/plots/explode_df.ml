let debug = false

let debug k = if debug then k Format.eprintf

let ( let* ) = Result.bind

module File = struct
  let _find_all pattern = Glob.glob ~recursive:true pattern

  let _find pattern =
    let* files = Glob.glob ~recursive:true pattern in
    match files with
    | [] ->
      Error
        (`Msg (Format.asprintf "Could not find files with: %a" Fpath.pp pattern))
    | x :: _ -> Ok x
end

let parse_line (bs, ms, sts, sys, ts) line =
  let line = String.trim line in
  match String.split_on_char ' ' line with
  | [ "Run"; filename ] -> (filename :: bs, ms, sts, sys, ts)
  | [ "Exited"; _code; _; total_time ] ->
    ( bs
    , "Finished" :: ms
    , 0. :: sts
    , 0. :: sys
    , float_of_string total_time :: ts )
  | [ "Timeout"; _; total_time ] ->
    (bs, "Timeout" :: ms, 0. :: sts, 0. :: sys, float_of_string total_time :: ts)
  | _ -> Format.ksprintf failwith "could not parse line: %s" line

let parse_results (bs, ms, sts, sys, ts) results_file =
  In_channel.with_open_text results_file @@ fun ic ->
  let lines = In_channel.input_lines ic in
  List.fold_left parse_line (bs, ms, sts, sys, ts) (List.tl lines)

let main () =
  let open Owl in
  let vulcan = "results/res-20240925T135331/results" in
  let bs, ms, sts, sys, ts = parse_results ([], [], [], [], []) vulcan in
  let df =
    Dataframe.make
      [| "benchmark"; "marker"; "static_time"; "symbolic_time"; "total_time" |]
      ~data:
        [| Dataframe.pack_string_series @@ Array.of_list bs
         ; Dataframe.pack_string_series @@ Array.of_list ms
         ; Dataframe.pack_float_series @@ Array.of_list sts
         ; Dataframe.pack_float_series @@ Array.of_list sys
         ; Dataframe.pack_float_series @@ Array.of_list ts
        |]
  in
  Format.printf "%a" Owl_pretty.pp_dataframe df;
  Ok (Dataframe.to_csv ~sep:',' df "explode-vulcan-results.csv")

let () = match main () with Ok () -> exit 0 | Error (`Msg err) -> failwith err
