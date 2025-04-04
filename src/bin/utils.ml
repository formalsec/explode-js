open Result

let copy_file src dst =
  let open Bos in
  let* content = OS.File.read src in
  OS.File.write dst content
