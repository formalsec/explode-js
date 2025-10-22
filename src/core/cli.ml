open Cmdliner

let real_fpath exists s =
  let open Result.Syntax in
  let file = Fpath.v s in
  let* file_exists = exists file in
  if file_exists then Ok file
  else Error (`Msg (Fmt.str "File '%a' not found" Fpath.pp file))

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

let input_path =
  let docv = "PATH" in
  let doc = "Name of the input path." in
  Arg.(required & pos 0 (some fpath) None & info [] ~doc ~docv)

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

let solver_type =
  let doc = "SMT solver to use" in
  Arg.(
    value
    & opt Smtml.Solver_type.conv Smtml.Solver_type.Cvc5_solver
    & info [ "solver" ] ~doc )

let sdocs = Manpage.s_common_options

let version = Cmd_version.version

(* let info_run = *)
(*   let doc = "Explode.js symbolic vulnerability confirmation engine" in *)
(*   let description = "Tries to blow stuff up" in *)
(*   let man = [ `S Manpage.s_description; `P description ] in *)
(*   let man_xrefs = [] in *)
(*   let exits = *)
(*     [ Cmd.Exit.info ~doc:"on application failure" 1 *)
(*     ; Cmd.Exit.info ~doc:"on unsupported/unknown vulnerability type" 2 *)
(*     ; Cmd.Exit.info ~doc:"on unsupported/malformed taint summary" 3 *)
(*     ; Cmd.Exit.info ~doc:"on internal timeout (when set)" 4 *)
(*     ] *)
(*   in *)
(*   Cmd.info "run" ~doc ~sdocs ~exits ~man ~man_xrefs *)

(* let cmd_run = *)
(*   let+ workspace_dir *)
(*   and+ package_dir *)
(*   and+ deterministic *)
(*   and+ lazy_values *)
(*   and+ proto_pollution *)
(*   and+ enumerate_all *)
(*   and+ scheme_file = input_file *)
(*   and+ original_file = input_file_opt *)
(*   and+ time_limit *)
(*   and+ solver_type in *)
(*   let settings = *)
(*     Cmd_run.Settings.make ~workspace_dir ?package_dir ~deterministic *)
(*       ~lazy_values ~proto_pollution ~enumerate_all ~scheme_file ?original_file *)
(*       ?time_limit ~solver_type () *)
(*   in *)
(*   Cmd_run.run settings *)

(* let info_exploit = *)
(*   let doc = "Explode.js single file symbolic confirmation" in *)
(*   let description = "Tries to blow stuff up" in *)
(*   let man = [ `S Manpage.s_description; `P description ] in *)
(*   let man_xrefs = [] in *)
(*   Cmd.info "exploit" ~doc ~sdocs ~man ~man_xrefs *)

(* let cmd_exploit = *)
(*   let+ input_file *)
(*   and+ deterministic *)
(*   and+ lazy_values *)
(*   and+ workspace_dir *)
(*   and+ time_limit *)
(*   and+ solver_type in *)
(*   let settings = *)
(*     Cmd_exploit.Settings.make ~deterministic ~lazy_values ~input_file *)
(*       ~workspace_dir ?time_limit ~solver_type () *)
(*   in *)
(*   Cmd_exploit.run settings *)

(* let info_full = *)
(*   let doc = "Explode.js full analysis" in *)
(*   let description = "Tries to blow stuff up" in *)
(*   let man = [ `S Manpage.s_description; `P description ] in *)
(*   let man_xrefs = [] in *)
(*   Cmd.info "full" ~doc ~sdocs ~man ~man_xrefs *)

(* let cmd_full = *)
(*   let+ input_file *)
(*   and+ package_dir *)
(*   and+ deterministic *)
(*   and+ proto_pollution *)
(*   and+ enumerate_all *)
(*   and+ lazy_values *)
(*   and+ workspace_dir *)
(*   and+ time_limit *)
(*   and+ optimized_import *)
(*   and+ solver_type in *)
(*   let settings = *)
(*     Cmd_full.Settings.make ~input_file ?package_dir ~deterministic *)
(*       ~proto_pollution ~enumerate_all ~lazy_values ~workspace_dir ?time_limit *)
(*       ~optimized_import ~solver_type () *)
(*   in *)
(*   Cmd_full.run settings *)

(* let info_instrument = *)
(*   let doc = "Explode.js test instrumentator" in *)
(*   let description = "" in *)
(*   let man = [ `S Manpage.s_description; `P description ] in *)
(*   let man_xrefs = [] in *)
(*   Cmd.info "instrument" ~doc ~sdocs ~man ~man_xrefs *)

(* let cmd_instrument = *)
(*   let mode = *)
(*     let open Cmd_instrument in *)
(*     let doc = "Instrumentation mode." in *)
(*     Arg.(value & opt Settings.instrument_conv Symbolic & info [ "mode" ] ~doc) *)
(*   in *)
(*   let output_path = *)
(*     let doc = "Output path." in *)
(*     Arg.(value & opt string "symbolic_test" & info [ "output"; "o" ] ~doc) *)
(*   in *)
(*   let witness_file = *)
(*     let doc = "Concrete witness file." in *)
(*     Arg.(value & opt (some fpath) None & info [ "witness" ] ~doc) *)
(*   in *)
(*   let+ debug *)
(*   and+ mode *)
(*   and+ scheme_file = input_file *)
(*   and+ original_file = input_file_opt *)
(*   and+ witness_file *)
(*   and+ output_path in *)
(*   let settings = *)
(*     Cmd_instrument.Settings.make ~debug ~mode ~scheme_file ?original_file *)
(*       ?witness_file ~output_path () *)
(*   in *)
(*   Cmd_instrument.run settings *)

(* let info_package = *)
(*   let doc = "Explode.js full package analysis" in *)
(*   let description = "Tries to blow stuff up" in *)
(*   let man = [ `S Manpage.s_description; `P description ] in *)
(*   let man_xrefs = [] in *)
(*   Cmd.info "package" ~doc ~sdocs ~man ~man_xrefs *)

(* let cmd_package = *)
(*   let+ proto_pollution *)
(*   and+ workspace_dir *)
(*   and+ input_dir *)
(*   and+ solver_type *)
(*   and+ enumerate_all in *)
(*   let settings = *)
(*     Cmd_package.Settings.make ~proto_pollution ~workspace_dir ~input_dir *)
(*       ~solver_type ~enumerate_all *)
(*   in *)
(*   Cmd_package.run settings *)

(* let v : *)
(*   ( int *)
(*   , [ `Expected_assoc *)
(*     | `Expected_list *)
(*     | `Expected_string *)
(*     | `Malformed_json of string *)
(*     | `Msg of string *)
(*     | `Status of int *)
(*     | `Unknown_param of string *)
(*     | `Unknown_param_type of string *)
(*     | `Unknown_vuln_type of string *)
(*     ] ) *)
(*   result *)
(*   Cmd.t = *)
(*   let info = Cmd.info "explode-js" in *)
(*   Cmd.group info *)
(*     [ Cmd.v info_exploit cmd_exploit *)
(*     ; Cmd.v info_run cmd_run *)
(*     ; Cmd.v info_full cmd_full *)
(*     ; Cmd.v info_instrument cmd_instrument *)
(*     ; Cmd.v info_package cmd_package *)
(*     ] *)
let cmd_version =
  let info =
    let doc = "Explode.js version" in
    let descrption = "" in
    let man = [ `S Manpage.s_description; `P descrption ] in
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
    let doc = "Explode.js symbolic vulnerability confirmation engine" in
    let description = "Tries to blow stuff up" in
    let man = [ `S Manpage.s_description; `P description ] in
    let man_xrefs = [] in
    Cmd.info "run" ~version ~doc ~sdocs ~man ~man_xrefs
  in
  let command =
    let open Term.Syntax in
    let+ workspace_dir
    and+ lazy_values
    and+ solver_type
    and+ input_path in
    let settings =
      Settings.Cmd_run.make ~workspace_dir ~lazy_values ~solver_type input_path
    in
    Cmd_run.run settings
  in
  Cmd.v info command

let commands =
  let info = Cmd.info ~version "explode-js" in
  Cmd.group info [ cmd_version; cmd_run ]
