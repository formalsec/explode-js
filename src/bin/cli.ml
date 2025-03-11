open Cmdliner
open Cmdliner.Term.Syntax

let parse_fpath f str =
  let file = Fpath.v str in
  match f file with
  | Ok true -> `Ok file
  | Ok false -> `Error (Fmt.str "File '%s' not found!" str)
  | Error (`Msg err) -> `Error err

let fpath = ((fun str -> `Ok (Fpath.v str)), Fpath.pp)

let _valid_fpath = (parse_fpath Bos.OS.Path.exists, Fpath.pp)

let non_dir_fpath = (parse_fpath Bos.OS.File.exists, Fpath.pp)

let _dir_fpath = (parse_fpath Bos.OS.Dir.exists, Fpath.pp)

let debug =
  let doc = "Debug mode." in
  Arg.(value & flag & info [ "debug" ] ~doc)

let input_file =
  let docv = "FILE" in
  let doc = "Name of the input file." in
  Arg.(required & pos 0 (some non_dir_fpath) None & info [] ~doc ~docv)

let input_file_opt =
  let doc = "Overwrite input file in scheme_path" in
  Arg.(value & opt (some fpath) None & info [ "filename" ] ~doc)

let workspace_dir =
  let doc = "Directory to store intermediate results" in
  Arg.(value & opt fpath (Fpath.v "_results") & info [ "workspace" ] ~doc)

let time_limit =
  let doc = "Maximum time limit for analysis" in
  Arg.(value & opt (some float) None & info [ "timeout" ] ~doc)

let sdocs = Manpage.s_common_options

let info_run =
  let doc = "Explode.js symbolic vulnerability confirmation engine" in
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
  Cmd.info "run" ~doc ~sdocs ~exits ~man ~man_xrefs

let cmd_run =
  let+ workspace_dir
  and+ scheme_file = input_file
  and+ original_file = input_file_opt
  and+ time_limit in
  Cmd_run.run ~workspace_dir ~scheme_file ~original_file ~time_limit

let info_exploit =
  let doc = "Explode.js single file symbolic confirmation" in
  let description = "Tries to blow stuff up" in
  let man = [ `S Manpage.s_description; `P description ] in
  let man_xrefs = [] in
  Cmd.info "exploit" ~doc ~sdocs ~man ~man_xrefs

let cmd_exploit =
  (* Term.(const Cmd_exploit.options $ input $ workspace_dir $ time_limit) *)
  let+ input_file
  and+ workspace_dir
  and+ time_limit in
  Cmd_exploit.run ~input_file ~workspace_dir ~time_limit

let info_full =
  let doc = "Explode.js full analysis" in
  let description = "Tries to blow stuff up" in
  let man = [ `S Manpage.s_description; `P description ] in
  let man_xrefs = [] in
  Cmd.info "full" ~doc ~sdocs ~man ~man_xrefs

let cmd_full =
  let+ input_file
  and+ workspace_dir
  and+ time_limit in
  Cmd_full.run ~input_file ~workspace_dir ~time_limit

let info_instrument =
  let doc = "Explode.js test instrumentator" in
  let description = "" in
  let man = [ `S Manpage.s_description; `P description ] in
  let man_xrefs = [] in
  Cmd.info "instrument" ~doc ~sdocs ~man ~man_xrefs

let cmd_instrument =
  let mode =
    let open Cmd_instrument in
    let doc = "Instrumentation mode." in
    Arg.(value & opt instrument_conv Symbolic & info [ "mode" ] ~doc)
  in
  let output_path =
    let doc = "Output path." in
    Arg.(value & opt string "symbolic_test" & info [ "output"; "o" ] ~doc)
  in
  let+ debug
  and+ mode
  and+ scheme_file = input_file
  and+ original_file = input_file_opt
  and+ witness_file = input_file_opt
  and+ output_path in
  Cmd_instrument.run ~debug ~mode ~scheme_file ~original_file ~witness_file
    ~output_path

let v :
  ( int
  , [ `Expected_assoc
    | `Expected_list
    | `Expected_string
    | `Malformed_json of string
    | `Msg of string
    | `Status of int
    | `Unknown_param of string
    | `Unknown_param_type of string
    | `Unknown_vuln_type of string
    ] )
  result
  Cmd.t =
  let info = Cmd.info "explode-js" in
  Cmd.group info
    [ Cmd.v info_exploit cmd_exploit
    ; Cmd.v info_run cmd_run
    ; Cmd.v info_full cmd_full
    ; Cmd.v info_instrument cmd_instrument
    ]
