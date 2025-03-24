open Bos

let cmd ~optimized_import ~file ~output =
  let optimized_load = Cmd.(on optimized_import (v "--optimized-import")) in
  Cmd.(
    v "graphjs" %% optimized_load % "--silent" % "--with-types" % "--dirty"
    % "-f" % p file % "-o" % p output )

let run ~optimized_import ~file ~output =
  let cmd = cmd ~optimized_import ~file ~output in
  OS.Cmd.run_status cmd
