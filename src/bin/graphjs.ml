open Bos
open Result

module Settings = struct
  type t =
    { optimized_import : bool [@default false]
    ; file : Path.t
    ; output : Path.t
    }
  [@@deriving make]
end

let cmd (settings : Settings.t) =
  let optimized_load =
    Cmd.(on settings.optimized_import (v "--optimized-import"))
  in
  Cmd.(
    v "graphjs" %% optimized_load % "--silent" % "--with-types" % "--dirty"
    % "-f" % p settings.file % "-o" % p settings.output )

let run ?stderr ?stdout settings =
  let open Syntax in
  let cmd = cmd settings in
  let err = Option.map OS.Cmd.err_file stderr in
  match stdout with
  | None -> OS.Cmd.run_status ?err cmd
  | Some out_file ->
    let run_out = OS.Cmd.run_out ?err cmd in
    let* (), (_, status) = OS.Cmd.out_file out_file run_out in
    Ok status
