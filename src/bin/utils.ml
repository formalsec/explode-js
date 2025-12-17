let create_dir (dir : Path.t) =
  let open Result.Syntax in
  let* _ = Bos.OS.Dir.create ~path:true dir in
  Ok Path.(v (Unix.realpath (to_string dir)))

let write_file (file : Path.t) content =
  let open Result.Syntax in
  let* () = Bos.OS.File.writef file "%s@." content in
  Ok file

let write_time (file : Path.t) time =
  (* Not a problem if we cannot write the time *)
  let _ =
    Bos.OS.File.writef file "%f@." time
    |> Result.iter_error @@ fun (`Msg err) ->
       Logs.err (fun m -> m "write_time: %s" err)
  in
  ()
