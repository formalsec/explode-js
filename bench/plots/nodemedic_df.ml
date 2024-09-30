open Explode_js_bench

let debug = false

let debug k = if debug then k Format.eprintf

let ( let* ) = Result.bind

let parse_time =
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

let parse_results (ds, ms, rs, us, ss) dir =
  let result =
    let results_dir = Fpath.to_string dir in
    assert (Sys.is_directory results_dir);
    let* marker_file = File.find Fpath.(dir / "**" / "finished.marker") in
    let marker = Marker.from_file marker_file in
    match marker with
    | `Timeout ->
      Ok
        ( results_dir :: ds
        , Marker.to_string marker :: ms
        , 600. :: rs
        , 0. :: us
        , 0. :: ss )
    | _ ->
      let* time_file =
        File.find Fpath.(dir / "**" / "NodeMedic-docker-duration-seconds.txt")
      in
      let times = parse_time time_file in
      let rtime = List.assoc "real" times in
      Ok
        ( results_dir :: ds
        , Marker.to_string marker :: ms
        , rtime :: rs
        , 0. :: us
        , 0. :: ss )
  in
  match result with Ok res -> res | Error (`Msg err) -> failwith err

let main () =
  let open Owl in
  let* vulcan =
    File.find_all Fpath.(v "results/vulcan-nodemedic-out/**/*_NodeMedic")
  in
  let* secbench =
    File.find_all Fpath.(v "results/secbench-nodemedic-out/**/*_NodeMedic")
  in
  let ds, ms, rs, us, ss =
    List.fold_left parse_results ([], [], [], [], []) vulcan
  in
  let ds, ms, rs, us, ss =
    List.fold_left parse_results (ds, ms, rs, us, ss) secbench
  in
  let df =
    Dataframe.make
      [| "benchmark"; "marker"; "rtime"; "utime"; "stime" |]
      ~data:
        [| Dataframe.pack_string_series @@ Array.of_list ds
         ; Dataframe.pack_string_series @@ Array.of_list ms
         ; Dataframe.pack_float_series @@ Array.of_list rs
         ; Dataframe.pack_float_series @@ Array.of_list us
         ; Dataframe.pack_float_series @@ Array.of_list ss
        |]
  in
  Format.printf "%a" Owl_pretty.pp_dataframe df;
  Ok (Dataframe.to_csv ~sep:',' df "nodemedic-vulcan-secbench-results.csv")

let () = match main () with Ok () -> exit 0 | Error (`Msg err) -> failwith err
