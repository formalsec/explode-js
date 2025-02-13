type t =
  | Comma
  | Eof
  | Eq
  | False
  | For
  | Function
  | Id of string
  | True
  | Num of float
  | Null
  | L_brace
  | L_paren
  | R_brace
  | R_paren
  | Semicolon
  | Var

let equal a b =
  match (a, b) with
  | Comma, Comma
  | Eof, Eof
  | Eq, Eq
  | False, False
  | For, For
  | Function, Function
  | True, True
  | Null, Null
  | L_brace, L_brace
  | L_paren, L_paren
  | R_brace, R_brace
  | R_paren, R_paren
  | Semicolon, Semicolon
  | Var, Var ->
    true
  | Id a, Id b -> String.equal a b
  | Num a, Num b -> Float.equal a b
  | ( ( Comma | Eof | Eq | False | For | Function | True | Null | L_brace
      | L_paren | R_brace | R_paren | Semicolon | Var | Id _ | Num _ )
    , _ ) ->
    false

let pp fmt = function
  | Comma -> Fmt.string fmt ","
  | Eof -> Fmt.string fmt "eof"
  | Eq -> Fmt.string fmt "="
  | False -> Fmt.string fmt "false"
  | For -> Fmt.string fmt "for"
  | Function -> Fmt.string fmt "function"
  | Id x -> Fmt.string fmt x
  | True -> Fmt.string fmt "true"
  | Num n -> Fmt.float fmt n
  | Null -> Fmt.string fmt "null"
  | L_brace -> Fmt.string fmt "{"
  | L_paren -> Fmt.string fmt "("
  | R_brace -> Fmt.string fmt "}"
  | R_paren -> Fmt.string fmt ")"
  | Semicolon -> Fmt.string fmt ";"
  | Var -> Fmt.string fmt "var"
