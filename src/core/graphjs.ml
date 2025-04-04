open Bos
open Result

let cmd ~optimized_import ~file ~output =
  let optimized_load = Cmd.(on optimized_import (v "--optimized-import")) in
  Cmd.(
    v "graphjs" %% optimized_load % "--silent" % "--with-types" % "--dirty"
    % "-f" % p file % "-o" % p output )

let run ?stderr ?stdout ~optimized_import ~file ~output () =
  let cmd = cmd ~optimized_import ~file ~output in
  let err =
    match stderr with
    | Some err_file -> Some (OS.Cmd.err_file err_file)
    | None -> None
  in
  match stdout with
  | None -> OS.Cmd.run_status ?err cmd
  | Some out_file ->
    let run_out = OS.Cmd.run_out ?err cmd in
    let* (), (_, status) = OS.Cmd.out_file out_file run_out in
    Ok status
