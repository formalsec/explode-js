let create_dir (dir : Path.t) =
  let open Result.Syntax in
  let* _ = Bos.OS.Dir.create ~path:true dir in
  Ok dir

let write_file (file : Path.t) content =
  let open Result.Syntax in
  let* () = Bos.OS.File.writef file "%s@." content in
  Ok file
