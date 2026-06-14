let create_dir target =
  Eio.Path.mkdirs ~exists_ok:true ~perm:0o755 target;
  target

let write_file fpath content =
  Eio.Path.save ~create:(`Or_truncate 0o644) fpath content;
  fpath

let write_time fpath time =
  let _ = write_file fpath (Fmt.str "%f@\n" time) in
  ()
