type t =
  [ `Timeout
  | `Finished
  | `Error
  ]

let pp fmt = function
  | `Timeout -> Format.pp_print_string fmt "Timeout"
  | `Finished -> Format.pp_print_string fmt "Finished"
  | `Error -> Format.pp_print_string fmt "Error"

let to_string v = Format.asprintf "%a" pp v

let from_file file =
  In_channel.with_open_text (Fpath.to_string file) @@ fun ic ->
  let line = input_line ic in
  if String.starts_with ~prefix:"timeout" line then `Timeout
  else if String.starts_with ~prefix:"success" line then `Finished
  else if String.starts_with ~prefix:"tool error" line then `Error
  else assert false
