open Cmdliner

let fpath = Arg.conv (Path.of_string, Path.pp)

let debug =
  let doc = "Debug mode." in
  Arg.(value & flag & info [ "debug" ] ~doc)

let deterministic =
  let doc = "Removes undeterministic values from outputs. Useful for tests." in
  Arg.(value & flag & info [ "deterministic" ] ~doc)

let input_path =
  let docv = "PATH" in
  let doc = "Path to the input file. Can be a directory." in
  Arg.(required & pos 0 (some fpath) None & info [] ~doc ~docv)

let workspace_dir =
  let doc = "Directory to store intermediate results." in
  Arg.(value & opt fpath (Path.v "_results") & info [ "workspace" ] ~doc)

let lazy_values =
  let doc =
    "Turn lazy values in symbolic execution on/off (resp. true/false)."
  in
  Arg.(value & opt bool true & info [ "lazy-values" ] ~doc)

let proto_pollution =
  let doc = "Use prototype pollution heuristics." in
  Arg.(value & flag & info [ "proto-pollution" ] ~doc)

let solver_type =
  let doc = "SMT solver to use." in
  Arg.(
    value
    & opt Smtml.Solver_type.conv Smtml.Solver_type.Z3_solver
    & info [ "solver" ] ~doc )

let path_only =
  let doc = "Only search for paths that reach dangerous sinks." in
  Arg.(value & flag & info [ "path-only" ] ~doc)

let sdocs = Manpage.s_common_options

let version = Cmd_version.version

let cmd_version =
  let info =
    let doc = "Show program and library versions" in
    let description =
      "This command allows users to verify which version of explode-js they \
       are running. Additionally, the command outputs the versions of \
       statically linked libraries. This is useful for debugging."
    in
    let man = [ `S Manpage.s_description; `P description ] in
    let man_xrefs = [] in
    Cmd.info "version" ~version ~doc ~sdocs ~man ~man_xrefs
  in

  let command =
    let open Term.Syntax in
    let+ () = Term.const () in
    Cmd_version.run ()
  in
  Cmd.v info command

let cmd_run =
  let info =
    let doc = "Start the exploit generation engine" in
    let description =
      "This command executes the main exploit generation engine. It initiates \
       the two-stage pipeline, combining static analysis with symbolic \
       execution, to analyze a target. The main input should be either a \
       directory (e.g., \".\" for the local directory) or a JSON file \
       containing a vulnerable interaction scheme (VIS)."
    in
    let man = [ `S Manpage.s_description; `P description ] in
    let man_xrefs = [] in
    Cmd.info "run" ~version ~doc ~sdocs ~man ~man_xrefs
  in

  let command =
    let open Term.Syntax in
    let+ workspace_dir
    and+ lazy_values
    and+ solver_type
    and+ input_path
    and+ path_only in
    let settings =
      Settings.Cmd_run.make ~workspace_dir ~lazy_values ~solver_type ~path_only
        input_path
    in
    Cmd_run.run settings
  in
  Cmd.v info command

let cmd_injector =
  let cmd_verify =
    let info =
      let doc = "Experimental payload verification engine" in
      let description =
        "This command is still experimental and intentionally not documented. \
         Use at your own risk!"
      in
      let man = [ `S Manpage.s_description; `P description ] in
      let man_xrefs = [] in
      Cmd.info "verify" ~version ~doc ~sdocs ~man ~man_xrefs
    in
    let command =
      let open Term.Syntax in
      let+ input_path in
      let settings = Settings.Cmd_injector.make input_path in
      Cmd_injector.cmd_verify settings
    in
    Cmd.v info command
  in

  let cmd_complete =
    let info =
      let doc = "Experimental payload completion engine" in
      let description =
        "This command is still experimental and intentionally not documented. \
         Use at your own risk!"
      in
      let man = [ `S Manpage.s_description; `P description ] in
      let man_xrefs = [] in
      Cmd.info "complete" ~version ~doc ~sdocs ~man ~man_xrefs
    in
    let command =
      let open Term.Syntax in
      let+ input_path in
      let settings = Settings.Cmd_injector.make input_path in
      Cmd_injector.cmd_complete settings
    in
    Cmd.v info command
  in

  let info =
    let doc = "Experimental injector backend" in
    let description =
      [ `P
          "This command is still experimental and intentionally not \
           documented. Use at your own risk!"
      ]
    in
    let man = `S Manpage.s_description :: description in
    let man_xrefs = [] in
    Cmd.info ~version ~doc ~man ~man_xrefs "injector"
  in
  Cmd.group info [ cmd_verify; cmd_complete ]

let commands =
  let info =
    let doc = "An automatic exploit generator for Node.js packages" in
    let description =
      [ `P
          "$(b,explode-js) is an exploit generation tool for Node.js packages \
           that can automatically synthesize functional exploits for \
           $(i,multi-interaction vulnerablitilties). That is, vulnerabilities \
           that require a series of interactions with the vulnerable package \
           to be exploited. Given a vulnerable package, explode-js can \
           identify code injection, command injection, prototype pollution, \
           and path traversal vulnerabilities, and build a JS program that is \
           guaranteed to produce observable side effects, thereby confirming \
           the existence of the vulnerability and eliminating false positives."
      ; `P
          "$(b,explode-js) uses a two-stage algorithm to generate exploits. \
           First, static analysis builds an $(i,exploit template), a symbolic \
           call chain defined by a $(i,vulnerable interaction scheme) (VIS), \
           designed to reach a sensitive sink. Second, symbolic execution runs \
           this template to find a valid path. The resulting path constraints \
           are extended to ensure an attacker-controlled effect at the sink. \
           An SMT solver finds concrete inputs that satisfy these constraints, \
           which are then injected into the template to produce a functional \
           exploit."
      ; `P
          "Use: $(b,explode-js) $(i,COMMAND) --help, for more information on a \
           specific command."
      ]
    in
    let man = `S Manpage.s_description :: description in
    let man_xrefs = [] in
    Cmd.info ~version ~doc ~man ~man_xrefs "explode-js"
  in
  Cmd.group info [ cmd_version; cmd_run; cmd_injector ]
