type t =
  | Single_shot of Fpath.t
  | CLient_server of
      { client : Fpath.t
      ; server : Fpath.t
      }

let generate_test_path prefix i =
  match prefix with
  | "-" -> Fpath.v "-"
  | _ -> Fmt.kstr Fpath.v "%s_%d.js" prefix i

let resolve_filename dirname scheme = function
  | Some f -> f
  | None -> (
    match Scheme.filename scheme with
    | Some file -> Fpath.append dirname file
    | None -> assert false )

module Symbolic = struct
  let write ~mode ~output_file filename scheme =
    let open Result in
    Logs.app (fun k -> k "├── \u{1F4C4} %a" Fpath.pp output_file);
    (* When rendering templates we get a symbolic test *)
    let test = Exploit_templates.Symbolic.render scheme in
    let* module_data = Bos.OS.File.read filename in
    Bos.OS.File.writef ~mode output_file "%s@\n%s@." module_data test

  let write_all ?(mode = 0o644) ?file ~scheme_path ~output_dir schemes =
    let open Result in
    let n = List.length schemes in
    Logs.app (fun k -> k "\u{2692} Generating %d template(s):" n);
    let i = ref 0 in
    list_map
      (fun scheme ->
        let n = !i in
        incr i;
        let dirname = Fpath.parent scheme_path in
        let original_file = resolve_filename dirname scheme file in
        let output_file = generate_test_path output_dir n in
        let* () = write ~mode ~output_file original_file scheme in
        Ok output_file )
      schemes

  let generate_all ?(mode = 0o644) ?file ~scheme_path ~output_dir () =
    let open Result in
    let* schemes = Scheme.Parser.from_file scheme_path in
    write_all ~mode ?file ~scheme_path ~output_dir schemes
end

module Literal = struct
  let write ~mode model output_file filename scheme =
    let open Result in
    let test = Exploit_templates.Literal.render model scheme in
    let* module_data = Bos.OS.File.read filename in
    Bos.OS.File.writef ~mode output_file "%s@\n%s@." module_data test

  let generate_all ?(mode = 0o644) ?file scheme_path witness output_dir =
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
          let dirname = Fpath.parent scheme_path in
          let original_file = resolve_filename dirname scheme file in
          let output_file = generate_test_path output_dir n in
          write ~mode model output_file original_file scheme
        end )
      schemes
end
