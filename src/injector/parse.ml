let pp_pos fmt buf =
  let start, stop = Sedlexing.lexing_positions buf in
  Fmt.pf fmt "%d:%d-%d:%d" start.pos_lnum start.pos_bol stop.pos_lnum
    stop.pos_bol

let parse_with_error =
  let parser =
    MenhirLib.Convert.Simplified.traditional2revised Parser.grammar
  in
  fun buf ->
    let provider () =
      let tok = Lexer.token buf in
      let start, stop = Sedlexing.lexing_positions buf in
      (tok, start, stop)
    in
    try parser provider
    with exn -> Fmt.failwith "%a: %s" pp_pos buf (Printexc.to_string exn)

let from_file path =
  Bos.OS.File.with_ic path
    (fun chan () ->
      let buf = Sedlexing.Utf8.from_channel chan in
      Sedlexing.set_filename buf (Path.to_string path);
      parse_with_error buf )
    ()

let from_string str =
  let buf = Sedlexing.Utf8.from_string str in
  parse_with_error buf
