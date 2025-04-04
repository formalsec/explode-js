type t =
  | Single_shot of Fpath.t
  | Client_server of
      { client : Fpath.t
      ; server : Fpath.t
      }

let generate_test_file prefix i =
  match prefix with
  | "-" -> Fpath.v "-"
  | _ -> Fmt.kstr Fpath.v "%s_%d.js" prefix i

let resolve_file dir scheme = function
  | Some f -> f
  | None -> (
    match Scheme.filename scheme with
    | Some original_file ->
      (* If path is relative, it is relative to the scheme dir *)
      if Fpath.is_abs original_file then original_file
      else Fpath.append dir original_file
    | None -> assert false )

module Symbolic = struct
  let write ~mode ~output_file original_file scheme =
    let open Result in
    Logs.app (fun k -> k "├── \u{1F4C4} %a" Fpath.pp output_file);
    (* When rendering templates we get a symbolic test *)
    let test_data = Exploit_templates.Symbolic.render scheme in
    let* module_data = Bos.OS.File.read original_file in
    Bos.OS.File.writef ~mode output_file "%s@\n%s@." module_data test_data

  let write_all ?(mode = 0o644) ?original_file ~scheme_file ~output_dir schemes
      =
    let open Result in
    let n = List.length schemes in
    Logs.app (fun k -> k "\u{2692} Generating %d template(s):" n);
    let i = ref 0 in
    list_map
      (fun scheme ->
        let n = !i in
        incr i;
        let dirname = Fpath.parent scheme_file in
        let original_file = resolve_file dirname scheme original_file in
        match Scheme.ty scheme with
        | None
        | Some (Vuln_type.Cmd_injection | Code_injection | Proto_pollution) ->
          let output_file = generate_test_file output_dir n in
          let+ () = write ~mode ~output_file original_file scheme in
          (Single_shot output_file, scheme)
        | Some Path_traversal ->
          if Scheme.needs_client scheme then
            (* It's empty for now. We only generate a client for the concrete
               exploit *)
            let client = Fpath.v "." in
            Ok (Client_server { client; server = original_file }, scheme)
          else
            let output_file = generate_test_file output_dir n in
            let+ () = write ~mode ~output_file original_file scheme in
            (Single_shot output_file, scheme) )
      schemes

  let generate_all ?(mode = 0o644) ?original_file ~proto_pollution ~scheme_file
    ~output_dir () =
    let open Result in
    let* schemes = Scheme.Parser.from_file ~proto_pollution scheme_file in
    write_all ~mode ?original_file ~scheme_file ~output_dir schemes
end

module Literal = struct
  let write ~mode output_file original_file model scheme =
    let open Result in
    let test_data = Exploit_templates.Literal.render model scheme in
    let* module_data = Bos.OS.File.read original_file in
    Bos.OS.File.writef ~mode output_file "%s@\n%s@." module_data test_data

  let generate_single ?(mode = 0o644) ?original_file ~workspace_dir witness_file
    scheme_file scheme i =
    let open Result in
    let* model = Model.Parser.from_file witness_file in
    let parent_dir = Fpath.parent scheme_file in
    let original_file = resolve_file parent_dir scheme original_file in
    let output_file = Fpath.(workspace_dir / Fmt.str "literal_%d.js" i) in
    write ~mode output_file original_file model scheme

  let generate_client ?(mode = 0o644) workspace_dir witness_file scheme i =
    let open Result in
    let* model = Model.Parser.from_file witness_file in
    let output_file = Fpath.(workspace_dir / Fmt.str "literal_%d.js" i) in
    let test_data = Exploit_templates.Literal.render model scheme in
    let+ () = Bos.OS.File.writef ~mode output_file "%s" test_data in
    output_file

  let generate_all ?(mode = 0o644) ?original_file ~proto_pollution ~output_dir
    scheme_file witness_file =
    let open Result in
    let* model = Model.Parser.from_file witness_file in
    let* schemes = Scheme.Parser.from_file ~proto_pollution scheme_file in
    let i = ref 0 in
    list_iter
      (fun scheme ->
        let n = !i in
        incr i;
        let st = Fmt.str "symbolic_test_%d" n in
        match
          Astring.String.find_sub ~sub:st (Fpath.to_string witness_file)
        with
        | None -> Ok ()
        | Some _ -> begin
          let parent_dir = Fpath.parent scheme_file in
          let original_file = resolve_file parent_dir scheme original_file in
          let output_file = generate_test_file output_dir n in
          write ~mode output_file original_file model scheme
        end )
      schemes
end
