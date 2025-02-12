open Bos_setup
module Json = Yojson.Basic
module Util = Yojson.Basic.Util

let get_test_name prefix i =
  match prefix with
  | "-" -> Fpath.v "-"
  | _ -> Fmt.kstr Fpath.v "%s_%d.js" prefix i

let write_test ~mode ~file module_data vuln =
  Format.eprintf "Genrating %a@." Fpath.pp file;
  OS.File.writef ~mode file "%s@\n%a@." module_data Vuln_symbolic.pp vuln

let write_literal_test ~mode map file module_data vuln =
  Format.eprintf "Genrating %a@." Fpath.pp file;
  OS.File.writef ~mode file "%s@\n%a@." module_data (Vuln_literal.pp map) vuln

(** [run file config output] creates symbolic tests [file] from [config] *)
let run ?(mode = 0o644) ?file ~config ~output () =
  let open Result in
  let+ vulns = Vuln_parser.from_file config in
  let confs = List.concat_map Vuln.unroll vulns in
  List.mapi
    (fun i conf ->
      let output_file = get_test_name output i in
      let filename =
        match file with
        | Some f -> f
        | None ->
          let filename =
            match conf.Vuln_intf.filename with
            | Some f -> f
            | None -> assert false
          in
          Filename.(concat (dirname config) filename)
      in
      let module_data = In_channel.(with_open_text filename input_all) in
      let () =
        match write_test ~mode ~file:output_file module_data conf with
        | Ok () -> ()
        | Error (`Msg msg) -> failwith msg
      in
      output_file )
    confs

let literal ?(mode = 0o644) ?file taint_summary witness output =
  let open Result in
  let* vulns = Vuln_parser.from_file taint_summary in
  let+ model = Model.Parser.from_file witness in
  let confs = List.concat_map Vuln.unroll vulns in
  List.iteri
    (fun i conf ->
      let st = Fmt.str "symbolic_test_%d" i in
      match Astring.String.find_sub ~sub:st witness with
      | None -> ()
      | Some _ -> (
        let output_file = get_test_name output i in
        let filename =
          match file with
          | Some f -> f
          | None ->
            let filename =
              match conf.Vuln_intf.filename with
              | Some f -> f
              | None -> assert false
            in
            Filename.(concat (dirname taint_summary) filename)
        in
        let module_data = In_channel.(with_open_text filename input_all) in
        match write_literal_test ~mode model output_file module_data conf with
        | Ok () -> ()
        | Error (`Msg msg) -> failwith msg ) )
    confs
