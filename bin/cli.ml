open Cmdliner

let parse_fpath f str =
  let file = Fpath.v str in
  match f file with
  | Ok true -> `Ok file
  | Ok false -> `Error (Format.asprintf "File '%s' not found!" str)
  | Error (`Msg err) -> `Error err

let fpath = ((fun str -> `Ok (Fpath.v str)), Fpath.pp)

let _valid_fpath = (parse_fpath Bos.OS.Path.exists, Fpath.pp)

let non_dir_fpath = (parse_fpath Bos.OS.File.exists, Fpath.pp)

let _dir_fpath = (parse_fpath Bos.OS.Dir.exists, Fpath.pp)

let debug =
  let doc = "Run in debug mode" in
  Arg.(value & flag & info [ "debug" ] ~doc)

let input =
  let docv = "FILE" in
  let doc = "Name of the input file." in
  Arg.(required & pos 0 (some non_dir_fpath) None & info [] ~docv ~doc)

let filename =
  let docv = "FILE" in
  let doc = "Overwrite input file in taint_summary" in
  Arg.(value & opt (some fpath) None & info [ "filename" ] ~docv ~doc)

let workspace_dir =
  let docv = "DIR" in
  let doc = "Directory to store intermediate results" in
  Arg.(
    value & opt fpath (Fpath.v "explode-out") & info [ "workspace" ] ~docv ~doc )

let time_limit =
  let docv = "VAL" in
  let doc = "Maximum time limit for analysis" in
  Arg.(value & opt float 0.0 & info [ "timeout" ] ~docv ~doc)

let cmd_run =
  let doc = "Explode.js symbolic vulnerability confirmation engine" in
  let sdocs = Manpage.s_common_options in
  let description = "Tries to blow stuff up" in
  let man = [ `S Manpage.s_description; `P description ] in
  let man_xrefs = [] in
  let exits =
    [ Cmd.Exit.info ~doc:"on application failure" 1
    ; Cmd.Exit.info ~doc:"on unsupported/unknown vulnerability type" 2
    ; Cmd.Exit.info ~doc:"on unsupported/malformed taint summary" 3
    ; Cmd.Exit.info ~doc:"on internal timeout (when set)" 4
    ]
  in
  let options =
    Term.(
      const Cmd_run.options $ debug $ input $ filename $ workspace_dir
      $ time_limit )
  in
  let info = Cmd.info "run" ~doc ~sdocs ~exits ~man ~man_xrefs in
  Cmd.v info Term.(const Cmd_run.main $ options)

let cmd_exploit =
  let doc = "Explode.js single file symbolic confirmation" in
  let sdocs = Manpage.s_common_options in
  let description = "Tries to blow stuff up" in
  let man = [ `S Manpage.s_description; `P description ] in
  let man_xrefs = [] in
  let options =
    Term.(const Cmd_exploit.options $ debug $ input $ workspace_dir $ time_limit)
  in
  let info = Cmd.info "exploit" ~doc ~sdocs ~man ~man_xrefs in
  Cmd.v info Term.(const Cmd_exploit.main $ options)

let main =
  let info = Cmd.info "explode-js" in
  Cmd.group info [ cmd_run; cmd_exploit ]
