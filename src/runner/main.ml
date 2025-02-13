let cli =
  let open Cmdliner in
  let fpath = ((fun str -> `Ok (Fpath.v str)), Fpath.pp) in
  let jobs =
    let doc = "Number of threads to use." in
    let absent = Domain.recommended_domain_count () in
    Arg.(value & opt int absent & info [ "jobs" ] ~doc)
  in
  let timeout =
    let doc = "Time limit per benchmark run." in
    Arg.(value & opt int 60 & info [ "timeout" ] ~doc)
  in
  let output =
    let doc = "Output directory to store results." in
    Arg.(value & opt fpath (Fpath.v ".") & info [ "output" ] ~doc)
  in
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
  in
  let index =
    let doc = "Benchmark index." in
    Arg.(required & pos 0 (some fpath) None & info [] ~doc ~docv:"PATH")
  in
  let address =
    let doc = "Webserver address." in
    Arg.(value & opt string "127.0.0.1" & info [ "addr" ] ~doc)
  in
  let port =
    let doc = "Webserver port (default: 8080)." in
    Arg.(value & opt int 8080 & info [ "port"; "p" ] ~doc)
  in
  let db =
    let doc = "Path to database." in
    Arg.(value & opt fpath (Fpath.v "results.db") & info [ "db" ] ~doc)
  in
  let cmd_run =
    let doc = "Explode-js benchmark runner." in
    let info = Cmd.info "run" ~doc in
    Cmd.v info
      Term.(const Cmd_run.main $ jobs $ timeout $ output $ filter $ index)
  in
  let cmd_web =
    let doc = "Explode-js benchmark webapp." in
    let info = Cmd.info "web" ~doc in
    Cmd.v info Term.(const Cmd_web.main $ address $ port $ db)
  in
  let info = Cmd.info "runner" in
  Cmd.group info [ cmd_run; cmd_web ]

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
      );
      Cmd.Exit.some_error )
  | Error e -> (
    match e with
    | `Term -> Cmd.Exit.some_error
    | `Parse -> Cmd.Exit.cli_error
    | `Exn -> Cmd.Exit.internal_error )

let () = exit result
