open I2
open Cmdliner

let symbolic debug taint_summary file output =
  if debug then Logs.set_level (Some Debug);
  match Run.run ?file ~config:taint_summary ~output () with
  | Ok _n -> 0
  | Error err ->
    Format.eprintf "unexpected error: %a@." Result.pp err;
    Result.to_code err

let literal debug taint_summary file witness output =
  if debug then Logs.set_level (Some Debug);
  match Run.literal ?file taint_summary witness output with
  | Ok _n -> 0
  | Error err ->
    Format.eprintf "unexpected error: %a@." Result.pp err;
    Result.to_code err

let debug =
  let doc = "debug mode" in
  Arg.(value & flag & info [ "debug" ] ~doc)

let taint_summary =
  let doc = "taint summary" in
  Arg.(required & pos 0 (some non_dir_file) None & info [] ~docv:"SUMM" ~doc)

let file =
  let doc = "normalized file" in
  Arg.(value & pos 1 (some non_dir_file) None & info [] ~docv:"FILE" ~doc)

let witness =
  let doc = "witness file" in
  Arg.(required & opt (some string) None & info [ "witness" ] ~doc)

let output =
  let doc = "output file" in
  Arg.(value & opt string "symbolic_test" & info [ "output"; "o" ] ~doc)

let cmd_symbolic =
  let info = Cmd.info "symbolic" in
  Cmd.v info Term.(const symbolic $ debug $ taint_summary $ file $ output)

let cmd_literal =
  let info = Cmd.info "literal" in
  Cmd.v info
    Term.(const literal $ debug $ taint_summary $ file $ witness $ output)

let cmd =
  let doc = "Instrumentor2" in
  let man =
    [ `S Manpage.s_bugs
    ; `P "Report them in https://github.com/formalsec/instrumentation2/issues"
    ]
  in
  let info = Cmd.info "instrumentation2" ~version:"%%VERSION%%" ~doc ~man in
  Cmd.group info [ cmd_symbolic; cmd_literal ]

let () = exit @@ Cmd.eval' cmd
