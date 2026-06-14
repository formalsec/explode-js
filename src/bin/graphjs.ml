let run ~env ~stderr ~stdout workspace_dir entry_file =
  let open Eio in
  let proc_mgr = Stdenv.process_mgr env in
  Path.with_open_out ~create:(`Or_truncate 0o644) stderr @@ fun stderr ->
  Path.with_open_out ~create:(`Or_truncate 0o644) stdout @@ fun stdout ->
  Switch.run @@ fun sw ->
  let proc =
    Process.spawn ~sw proc_mgr ~stdout ~stderr
      [ "graphjs"
      ; "--silent"
      ; "--with-types"
      ; "--dirty"
      ; "-f"
      ; Path.native_exn entry_file
      ; "-o"
      ; Path.native_exn workspace_dir
      ]
  in
  Process.await proc
