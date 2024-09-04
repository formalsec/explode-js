open Bos_setup
open Syntax.Result
module Json = Yojson.Basic
module Util = Yojson.Basic.Util

let get_test_name prefix (i, j) =
  match prefix with
  | "-" -> Fpath.v "-"
  | _ -> Format.ksprintf Fpath.v "%s_%d_%d.js" prefix i j

let write_test ~mode ~file module_data vuln =
  Format.eprintf "Genrating %a@." Fpath.pp file;
  OS.File.writef ~mode file "%s@\n%a@." module_data Vuln_symbolic.pp vuln

let write_literal_test ~mode map file module_data vuln =
  Format.eprintf "Genrating %a@." Fpath.pp file;
  OS.File.writef ~mode file "%s@\n%a@." module_data (Vuln_literal.pp map) vuln

(** [run file config output] creates symbolic tests [file] from [config] *)
let run ?(mode = 0o644) ?file ~config ~output () =
  let+ vulns = Vuln_parser.from_file config in
  List.mapi
    (fun i vuln ->
      let confs = Vuln.unroll vuln in
      List.mapi
        (fun j conf ->
          let output_file = get_test_name output (i, j) in
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
          begin
            match write_test ~mode ~file:output_file module_data conf with
            | Ok () -> ()
            | Error (`Msg msg) -> failwith msg
          end;
          output_file )
        confs )
    vulns
  |> List.concat

let literal ?(mode = 0o644) ?file taint_summary witness output =
  let* vulns = Vuln_parser.from_file taint_summary in
  let+ witness_map = Value.Parser.from_file witness in
  List.iteri
    (fun i vuln ->
      let confs = Vuln.unroll vuln in
      List.iteri
        (fun j conf ->
          let st = Format.sprintf "symbolic_test_%d_%d" i j in
          match Astring.String.find_sub ~sub:st witness with
          | Some _ ->
            let output_file = get_test_name output (i, j) in
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
            begin
              match
                write_literal_test ~mode witness_map output_file module_data
                  conf
              with
              | Ok () -> ()
              | Error (`Msg msg) -> failwith msg
            end
          | None -> () )
        confs )
    vulns
