let returncode =
  let open Cmdliner in
  match Cmd.eval_value Cli.v with
  | Ok (`Version | `Help) -> 0
  | Ok (`Ok result) -> (
    match result with
    | Ok n -> n
    | Error err -> (
      match err with
      | #I2.Result.err as error ->
        Format.eprintf "error: %a@." I2.Result.pp error;
        I2.Result.to_code error
      | `Status n ->
        Format.eprintf "error: Failed during symbolic execution/confirmation@.";
        n ) )
  | Error e -> (
    match e with
    | `Term -> Cmd.Exit.some_error
    | `Parse -> Cmd.Exit.cli_error
    | `Exn -> Cmd.Exit.internal_error )

let () = exit returncode
