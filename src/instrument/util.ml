open Bos_setup
module Json = Yojson.Basic
module Util = Yojson.Basic.Util

let get_test_name prefix i =
  match prefix with
  | "-" -> Fpath.v "-"
  | _ -> Fmt.kstr Fpath.v "%s_%d.js" prefix i

let write_symbolic_tmpl ~mode ~file module_data scheme =
  Logs.app (fun k -> k "├── \u{1F4C4} %a" Fpath.pp file);
  let test = Exploit_templates.Symbolic.render scheme in
  OS.File.writef ~mode file "%s@\n%s@." module_data test

let write_literal_tmpl ~mode map file module_data scheme =
  let test = Exploit_templates.Literal.render map scheme in
  OS.File.writef ~mode file "%s@\n%s@." module_data test

let serialize_symbolic_tmpls ?(mode = 0o644) ?file ~scheme_path ~output_dir
  schemes =
  let open Result in
  let n = List.length schemes in
  Logs.app (fun k -> k "\u{2692} Generating %d template(s):" n);
  let i = ref 0 in
  list_map
    (fun scheme ->
      let n = !i in
      incr i;
      let output_file = get_test_name output_dir n in
      let filename =
        match file with
        | Some f -> f
        | None ->
          let file =
            match Scheme.filename scheme with
            | Some f -> f
            | None -> assert false
          in
          Fpath.(parent scheme_path // file)
      in
      let* module_data = OS.File.read filename in
      let* () =
        write_symbolic_tmpl ~mode ~file:output_file module_data scheme
      in
      Ok output_file )
    schemes

let gen_symbolic_tmpls ?(mode = 0o644) ?file ~scheme_path ~output_dir () =
  let open Result in
  let* schemes = Scheme.Parser.from_file scheme_path in
  serialize_symbolic_tmpls ~mode ?file ~scheme_path ~output_dir schemes

let gen_literal_tmpls ?(mode = 0o644) ?file scheme_path witness output_dir =
  let open Result in
  let* model = Model.Parser.from_file witness in
  let* schemes = Scheme.Parser.from_file scheme_path in
  let i = ref 0 in
  list_iter
    (fun scheme ->
      let n = !i in
      incr i;
      let st = Fmt.str "symbolic_test_%d" n in
      match Astring.String.find_sub ~sub:st witness with
      | None -> Ok ()
      | Some _ -> begin
        let output_file = get_test_name output_dir n in
        let filename =
          match file with
          | Some f -> f
          | None ->
            let file =
              match Scheme.filename scheme with
              | Some f -> f
              | None -> assert false
            in
            Fpath.(parent scheme_path // file)
        in
        let* module_data = OS.File.read filename in
        write_literal_tmpl ~mode model output_file module_data scheme
      end )
    schemes
