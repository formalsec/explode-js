open Cmdliner
open Cmdliner.Term.Syntax

let fpath = Arg.conv (Fpath.of_string, Fpath.pp)

let debug =
  let doc = "Turn debug mode on." in
  Arg.(value & flag & info [ "debug" ] ~doc)

let jobs =
  let doc = "Number of threads to use." in
  let absent = Domain.recommended_domain_count () in
  Arg.(value & opt int absent & info [ "jobs" ] ~doc)

let time_limit =
  let doc = "Time limit per benchmark run." in
  Arg.(value & opt int 60 & info [ "timeout" ] ~doc)

let output_dir =
  let doc = "Output directory to store results." in
  Arg.(value & opt (some fpath) None & info [ "output" ] ~doc)

let filter =
  let doc =
    "Filter vulnerabilities by CWE (options available: CWE-22 | CWE-78 | \
     CWE-94 | CWE-1321)."
  in
  let cwe =
    ( (fun str ->
        match Explode_js.Cwe.of_string str with
        | Ok cwe -> `Ok cwe
        | Error (`Parsing str) -> `Error str )
    , Explode_js.Cwe.pp )
  in
  Arg.(value & opt (some cwe) None & info [ "filter" ] ~doc)

let index =
  let doc = "Benchmark index." in
  Arg.(required & pos 0 (some fpath) None & info [] ~doc ~docv:"PATH")

let address =
  let doc = "Webserver address." in
  Arg.(value & opt string "127.0.0.1" & info [ "addr" ] ~doc)

let port =
  let doc = "Webserver port." in
  Arg.(value & opt int 8080 & info [ "port"; "p" ] ~doc)

let db_path =
  let doc = "Path to database." in
  Arg.(value & opt fpath (Fpath.v "results.db") & info [ "db" ] ~doc)

let run_mode =
  let doc = "Run mode." in
  Arg.(value & opt Run_mode.conv Run_mode.default & info [ "run-mode" ] ~doc)

let lazy_values =
  let doc = "Lazy values." in
  Arg.(value & opt bool true & info [ "lazy-values" ] ~doc)

let proto_pollution =
  let doc = "Turn prototype pollution heuristics on" in
  Arg.(value & flag & info [ "proto-pollution" ] ~doc)

let info_run =
  let doc = "Explode-js benchmark runner." in
  let description = "Independent explode-js runner" in
  let man = [ `S Manpage.s_description; `P description ] in
  let man_xrefs = [] in
  Cmd.info "run" ~doc ~man ~man_xrefs

let cmd_run =
  let+ debug
  and+ lazy_values
  and+ proto_pollution
  and+ jobs
  and+ time_limit
  and+ output_dir
  and+ filter
  and+ run_mode
  and+ index in
  Cmd_run.main ~debug ~lazy_values ~proto_pollution ~jobs ~time_limit
    ~output_dir ~filter ~run_mode ~index

let info_web =
  let doc = "Explode-js benchmark webapp." in
  Cmd.info "web" ~doc

let cmd_web =
  let+ address
  and+ port
  and+ db_path in
  Cmd_web.main ~address ~port ~db_path

let cli =
  let info = Cmd.info "runner" in
  Cmd.group info [ Cmd.v info_run cmd_run; Cmd.v info_web cmd_web ]

let result =
  let open Cmdliner in
  match Cmd.eval_value cli with
  | Ok (`Help | `Version) -> Cmd.Exit.ok
  | Ok (`Ok res) -> (
    match res with
    | Ok () -> Cmd.Exit.ok
    | Error e ->
      ( match e with
      | `Parsing err -> Fmt.epr "parsing error: %s@." err
      | `Exn exn -> Fmt.epr "uncaught exception: %s@." (Printexc.to_string exn)
      | `Sqlite3 rc -> Fmt.epr "sqlite3 error: %s@." (Sqlite3.Rc.to_string rc)
      | `Msg err -> Fmt.epr "err: %s@." err );
      Cmd.Exit.some_error )
  | Error e -> (
    match e with
    | `Term -> Cmd.Exit.some_error
    | `Parse -> Cmd.Exit.cli_error
    | `Exn -> Cmd.Exit.internal_error )

let () = exit result
