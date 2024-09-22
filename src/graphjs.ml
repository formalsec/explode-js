open Bos

let cmd ~file ~output =
  Cmd.(
    v "graphjs" % "--silent" % "--with-types" % "-f" % p file % "-o" % p output )

let run ~file ~output =
  let cmd = cmd ~file ~output in
  OS.Cmd.run_status cmd
