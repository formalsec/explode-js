open Bos

let cmd ~file ~output =
  Cmd.(v "graphjs" % "--with-types" % "-f" % p file % "-o" % p output)

let run ~file ~output =
  let cmd = cmd ~file ~output in
  let out = Fpath.(output / "stdout.txt") in
  let err = OS.Cmd.err_file ~append:true Fpath.(output / "stderr.txt") in
  let run_out = OS.Cmd.run_out ~err cmd in
  OS.Cmd.out_file ~append:true out run_out
