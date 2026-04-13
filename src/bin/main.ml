let returncode =
  let open Cmdliner in
  match Cmd.eval_value Cli.commands with
  | Ok (`Version | `Help) -> Cmd.Exit.ok
  | Ok (`Ok result) ->
    begin match result with
    | Ok () -> Cmd.Exit.ok
    | Error (`Msg str) ->
      Logs.err (fun m -> m "%s" str);
      1
    end
  | Error e ->
    begin match e with
    | `Term -> Cmd.Exit.some_error
    | `Parse -> Cmd.Exit.cli_error
    | `Exn -> Cmd.Exit.internal_error
    end

let () = exit returncode
