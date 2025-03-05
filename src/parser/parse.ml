let from_lexbuf lexbuf =
  let provider () =
    let token = Lexer.token lexbuf in
    let pos = Sedlexing.lexing_positions lexbuf in
    (token, pos)
  in
  Parser.program provider

let from_string string = from_lexbuf @@ Sedlexing.Utf8.from_string string

let from_file filename =
  In_channel.with_open_text filename @@ fun ic ->
  from_lexbuf @@ Sedlexing.Utf8.from_channel ic
