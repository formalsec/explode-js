let copy_file src dst =
  let open Result.Syntax in
  let* content = Bos.OS.File.read src in
  Bos.OS.File.write dst content
