let () =
  match Cmdliner.Cmd.eval_value Cli.main with
  | Error (`Parse | `Term | `Exn) -> exit 2
  | Ok (`Ok _ | `Version | `Help) -> ()
