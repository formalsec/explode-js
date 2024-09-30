type t =
  | Timeout
  | Exited of int
  | Signaled of int
  | Stopped of int

let timeout = Timeout

let exited n = Exited n

let signaled n = Signaled n

let stopped n = Stopped n

let pp fmt = function
  | Timeout -> Format.fprintf fmt "Timeout"
  | Exited n -> Format.fprintf fmt "Exited %d" n
  | Signaled n -> Format.fprintf fmt "Signaled %d" n
  | Stopped n -> Format.fprintf fmt "Stopped %d" n

let to_string v = Format.asprintf "%a" pp v

let from_file file =
  In_channel.with_open_text (Fpath.to_string file) @@ fun ic ->
  let line = input_line ic in
  if String.starts_with ~prefix:"timeout" line then timeout
  else if String.starts_with ~prefix:"success" line then exited 0
  else if String.starts_with ~prefix:"tool error" line then exited 1
  else assert false
