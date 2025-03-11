let run time_limit output_dir input_file scheme_file =
  let argv =
    [ "explode-js"
    ; "run"
    ; "--workspace"
    ; Fpath.to_string output_dir
    ; "--filename"
    ; Fpath.to_string input_file
    ; Fpath.to_string scheme_file
    ]
  in
  Run_proc.run ~time_limit "explode-js" argv

let full time_limit output_dir input_file =
  let argv =
    [ "explode-js"
    ; "full"
    ; "--workspace"
    ; Fpath.to_string output_dir
    ; Fpath.to_string input_file
    ]
  in
  Run_proc.run ~time_limit "explode-js" argv
