let ( let* ) = Result.bind

let error fmt = Fmt.kstr Result.error fmt

let pp_position fmt
  ( Lexing.{ pos_lnum = llnum; pos_cnum = lcnum; _ }
  , Lexing.{ pos_lnum = rlnum; pos_cnum = rcnum; _ } ) =
  Fmt.pf fmt "%d:%d-%d:%d" llnum lcnum rlnum rcnum

(* A program is a list of statements *)
let rec program provider =
  let st = State.create provider in
  let rec loop acc =
    let* acc in
    let token, _pos = State.peek st in
    match token with
    | Token.Eof -> Ok (List.rev acc)
    | _ ->
      let* stmt = stmt st in
      loop (Ok (stmt :: acc))
  in
  loop (Ok [])

and stmt st =
  let token, pos = State.peek st in
  match token with
  | Var -> var_decl st
  | Semicolon ->
    let _ = State.consume st in
    stmt st
  | _ -> (
    match expr st with
    | Ok _expr as result -> result
    | Error _ ->
      error "stmt: %a: unexpected token \"%a\"" pp_position pos Token.pp token )

and var_decl st =
  let token, pos = State.consume_and_peek st in
  match token with
  | Id x -> begin
    let token, pos = State.consume_and_peek st in
    match token with
    | Eq ->
      let* e = expr st in
      Ok (Fmt.str "var %s = %s" x e)
    | Semicolon | Eof -> Ok (Fmt.str "var %s" x)
    | _ ->
      error "var_decl: %a: unexpected token \"%a\"" pp_position pos Token.pp
        token
  end
  | _ ->
    error "var_decl: %a: unexpected token \"%a\"" pp_position pos Token.pp token

and expr st =
  let token, pos = State.consume_and_peek st in
  match token with
  | Id x -> begin
    let token, _ = State.consume_and_peek st in
    match token with Dot -> assert false | _ -> Ok x
  end
  | Num f ->
    let _ = State.consume st in
    Ok (Fmt.str "%.12g" f)
  | Eof ->
    (* Expression cannot be Eof *)
    Ok (Fmt.str "\"completed\"")
  | _ ->
    error "expr: %a: unexpected token \"%a\"" pp_position pos Token.pp token
