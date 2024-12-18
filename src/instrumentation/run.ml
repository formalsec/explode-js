open Bos_setup
module Json = Yojson.Basic
module Util = Yojson.Basic.Util

type test_type =
  | Single_shot of Fpath.t
  | Client_server of
      { client : Fpath.t
      ; server : Fpath.t
      }

let fresh_testname prefix i =
  match prefix with
  | "-" -> Fpath.v "-"
  | _ -> Fmt.kstr Fpath.v "%s_%d.js" prefix i

let get_filename dirname taint_summary = function
  | Some f -> f
  | None -> (
    match taint_summary.Vuln_intf.filename with
    | Some file -> Filename.concat dirname file
    | None -> assert false )

let write_test ~mode ~file filename vuln =
  Fmt.epr "Genrating %a@." Fpath.pp file;
  let test = Templates.Symbolic.v vuln in
  let module_data = In_channel.(with_open_text filename input_all) in
  OS.File.writef ~mode file "%s@\n%s@." module_data test

let write_literal_test ~mode map file filename vuln =
  Format.eprintf "Genrating %a@." Fpath.pp file;
  let test = Templates.Literal.v map vuln in
  let module_data = In_channel.(with_open_text filename input_all) in
  OS.File.writef ~mode file "%s@\n%s@." module_data test

(** [run file config output] creates symbolic tests [file] from [config] *)
let run ?(mode = 0o644) ?file:filename ~config:ts_path ~output:output_file () =
  let open Result in
  let+ vulns = Vuln_parser.from_file ts_path in
  let tss = List.concat_map Vuln.unroll vulns in
  List.mapi
    (fun i ts ->
      let filename = get_filename (Filename.dirname ts_path) ts filename in
      let output_file = fresh_testname output_file i in
      match ts.ty with
      | None | Some (Vuln_type.Cmd_injection | Code_injection | Proto_pollution)
        ->
        let () =
          match write_test ~mode ~file:output_file filename ts with
          | Ok () -> ()
          | Error (`Msg msg) -> failwith msg
        in
        Single_shot output_file
      | Some Path_traversal ->
        Client_server { client = Fpath.v "."; server = Fpath.v "." } )
    tss

let literal ?(mode = 0o644) ?file:filename taint_summary_path witness output =
  let open Result in
  let* vulns = Vuln_parser.from_file taint_summary_path in
  let+ model = Model.Parser.from_file witness in
  let confs = List.concat_map Vuln.unroll vulns in
  List.iteri
    (fun i ts ->
      let st = Fmt.str "symbolic_test_%d" i in
      match Astring.String.find_sub ~sub:st witness with
      | None -> ()
      | Some _ -> (
        let dirname = Filename.dirname taint_summary_path in
        let filename = get_filename dirname ts filename in
        let output_file = fresh_testname output i in
        match write_literal_test ~mode model output_file filename ts with
        | Ok () -> ()
        | Error (`Msg msg) -> failwith msg ) )
    confs
