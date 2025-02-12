let run time_limit output_dir filename exploit_template =
  let argv =
    [ "explode-js"
    ; "run"
    ; "--workspace"
    ; Fpath.to_string output_dir
    ; "--filename"
    ; Fpath.to_string filename
    ; Fpath.to_string exploit_template
    ]
  in
  Run_proc.run ~time_limit "explode-js" argv

let full _ = assert false
