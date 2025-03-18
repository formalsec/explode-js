let run time_limit output_dir input_file scheme_file =
  let prog, argv =
    ( "explode-js"
    , [ "explode-js"
      ; "run"
      ; "--workspace"
      ; Fpath.to_string output_dir
      ; "--filename"
      ; Fpath.to_string input_file
      ; Fpath.to_string scheme_file
      ] )
  in
  Run_proc.run ~time_limit prog argv

let full ?(enumerate_all = false) ~package_dir ~proto_pollution ~lazy_values
  time_limit output_dir input_file =
  let argv =
    [ "--workspace"; Fpath.to_string output_dir; Fpath.to_string input_file ]
  in
  let argv = if proto_pollution then "--proto-pollution" :: argv else argv in
  let argv = if enumerate_all then "--enumerate-all" :: argv else argv in
  let argv =
    match package_dir with
    | None -> argv
    | Some package_dir -> "--package-dir" :: package_dir :: argv
  in
  let prog, argv =
    ( "explode-js"
    , "explode-js" :: "full" :: "--lazy-values" :: Bool.to_string lazy_values
      :: argv )
  in
  Logs.debug (fun k ->
    k "Running '%s': %a" prog (Fmt.list ~sep:Fmt.sp Fmt.string) argv );
  Run_proc.run ~time_limit prog argv
