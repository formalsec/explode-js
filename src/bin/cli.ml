open Cmdliner
open Cmdliner.Term.Syntax

let real_fpath exists s =
  let file = Fpath.v s in
  match exists file with
  | Ok true -> Ok file
  | Ok false -> Error (`Msg (Fmt.str "File '%s' not found!" s))
  | Error _ as err -> err

let fpath = Arg.conv (Fpath.of_string, Fpath.pp)

let _valid_fpath = Arg.conv (real_fpath Bos.OS.Path.exists, Fpath.pp)

let non_dir_fpath = Arg.conv (real_fpath Bos.OS.File.exists, Fpath.pp)

let dir_fpath = Arg.conv (real_fpath Bos.OS.Dir.exists, Fpath.pp)

let debug =
  let doc = "Debug mode." in
  Arg.(value & flag & info [ "debug" ] ~doc)

let deterministic =
  let doc = "Deterministic output for tests." in
  Arg.(value & flag & info [ "deterministic" ] ~doc)

let input_file =
  let docv = "FILE" in
  let doc = "Name of the input file." in
  Arg.(required & pos 0 (some non_dir_fpath) None & info [] ~doc ~docv)

let input_file_opt =
  let doc = "Overwrite input file in scheme_path" in
  Arg.(value & opt (some fpath) None & info [ "filename" ] ~doc)

let input_dir =
  let docv = "DIR" in
  let doc = "Name of the input directory containing the package." in
  Arg.(value & pos 0 dir_fpath (Fpath.v "./") & info [] ~doc ~docv)

let workspace_dir =
  let doc = "Directory to store intermediate results" in
  Arg.(value & opt fpath (Fpath.v "_results") & info [ "workspace" ] ~doc)

let time_limit =
  let doc = "Maximum time limit for analysis" in
  Arg.(value & opt (some float) None & info [ "timeout" ] ~doc)

let lazy_values =
  let doc = "Lazy values" in
  Arg.(value & opt bool true & info [ "lazy-values" ] ~doc)

let proto_pollution =
  let doc = "Turn prototype pollution heuristics on" in
  Arg.(value & flag & info [ "proto-pollution" ] ~doc)

let enumerate_all =
  let doc = "Enumerate all possible exploits" in
  Arg.(value & flag & info [ "enumerate-all" ] ~doc)

let package_dir =
  let doc = "Path to package under analysis" in
  Arg.(value & opt (some fpath) None & info [ "package-dir" ] ~doc)

let optimized_import =
  let doc = "Use optimized import heuristics in graphjs" in
  Arg.(value & flag & info [ "optimized-import" ] ~doc)

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
  and+ package_dir
  and+ deterministic
  and+ lazy_values
  and+ proto_pollution
  and+ enumerate_all
  and+ scheme_file = input_file
  and+ original_file = input_file_opt
  and+ time_limit in
  Cmd_run.run ~deterministic ~lazy_values ~proto_pollution ~enumerate_all
    ~workspace_dir ~package_dir ~scheme_file ~original_file ~time_limit

let info_exploit =
  let doc = "Explode.js single file symbolic confirmation" in
  let description = "Tries to blow stuff up" in
  let man = [ `S Manpage.s_description; `P description ] in
  let man_xrefs = [] in
  Cmd.info "exploit" ~doc ~sdocs ~man ~man_xrefs

let cmd_exploit =
  let+ input_file
  and+ deterministic
  and+ lazy_values
  and+ workspace_dir
  and+ time_limit in
  Cmd_exploit.run ~deterministic ~lazy_values ~input_file ~workspace_dir
    ~time_limit

let info_full =
  let doc = "Explode.js full analysis" in
  let description = "Tries to blow stuff up" in
  let man = [ `S Manpage.s_description; `P description ] in
  let man_xrefs = [] in
  Cmd.info "full" ~doc ~sdocs ~man ~man_xrefs

let cmd_full =
  let+ input_file
  and+ package_dir
  and+ deterministic
  and+ proto_pollution
  and+ enumerate_all
  and+ lazy_values
  and+ workspace_dir
  and+ time_limit
  and+ optimized_import in
  Cmd_full.run ~deterministic ~lazy_values ~proto_pollution ~enumerate_all
    ~package_dir ~input_file ~workspace_dir ~time_limit ~optimized_import

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
  let witness_file =
    let doc = "Concrete witness file." in
    Arg.(value & opt (some fpath) None & info [ "witness" ] ~doc)
  in
  let+ debug
  and+ mode
  and+ scheme_file = input_file
  and+ original_file = input_file_opt
  and+ witness_file
  and+ output_path in
  Cmd_instrument.run ~debug ~mode ~scheme_file ~original_file ~witness_file
    ~output_path

let info_package =
  let doc = "Explode.js full package analysis" in
  let description = "Tries to blow stuff up" in
  let man = [ `S Manpage.s_description; `P description ] in
  let man_xrefs = [] in
  Cmd.info "package" ~doc ~sdocs ~man ~man_xrefs

let cmd_package =
  let+ proto_pollution
  and+ workspace_dir
  and+ input_dir in
  Cmd_package.run ~proto_pollution ~workspace_dir ~input_dir

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
    ; Cmd.v info_package cmd_package
    ]
