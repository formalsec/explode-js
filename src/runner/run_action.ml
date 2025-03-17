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

let full ~proto_pollution ~lazy_values time_limit output_dir input_file =
  let argv =
    [ "--workspace"; Fpath.to_string output_dir; Fpath.to_string input_file ]
  in
  let prog, argv =
    ( "explode-js"
    , "explode-js" :: "full" :: "--lazy-values" :: Bool.to_string lazy_values
      :: (if proto_pollution then "--proto-pollution" :: argv else argv) )
  in
  Logs.debug (fun k ->
    k "Running '%s': %a" prog (Fmt.list ~sep:Fmt.sp Fmt.string) argv );
  Run_proc.run ~time_limit prog argv
