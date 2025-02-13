open Token
open Sedlexing

exception Unexpected_character of string

let unexpected_character buf =
  let tok = Utf8.lexeme buf in
  raise @@ Unexpected_character (Fmt.str "unexpected character %S" tok)

let lexeme = Utf8.lexeme

let letter = [%sedlex.regexp? 'a' .. 'z' | 'A' .. 'Z' | '$']

let id_letter = [%sedlex.regexp? letter | '_']

let id = [%sedlex.regexp? id_letter, Star id_letter]

let sign = [%sedlex.regexp? '+' | '-']

let digit = [%sedlex.regexp? '0' .. '9']

let digit_non_zero = [%sedlex.regexp? '1' .. '9']

let intlit = [%sedlex.regexp? '0' | digit_non_zero, Star digit]

let alphanum = [%sedlex.regexp? digit | letter]

let word = [%sedlex.regexp? letter, Star alphanum]

let hexdigit = [%sedlex.regexp? digit | 'a' .. 'f' | 'A' .. 'F']

let bindigit = [%sedlex.regexp? '0' | '1']

let blank = [%sedlex.regexp? ' ' | '\t']

let newline = [%sedlex.regexp? '\r' | '\n' | "\r\n"]

let any_blank = [%sedlex.regexp? blank | newline]

let rec token buf =
  match%sedlex buf with
  | Plus any_blank -> token buf
  | intlit -> Num (Float.of_string @@ lexeme buf)
  | "," -> Comma
  | ";" -> Semicolon
  | "{" -> L_brace
  | "}" -> R_brace
  | "(" -> L_paren
  | ")" -> R_paren
  | "=" -> Eq
  | id -> (
    let id = lexeme buf in
    match id with
    | "null" -> Null
    | "false" -> False
    | "true" -> True
    | "var" -> Var
    | "for" -> For
    | "function" -> Function
    | _ -> Id id )
  | eof -> Eof
  | any -> unexpected_character buf
  | _ -> unexpected_character buf
