(* LL(1) Parser state, keeps the next symbol in `lookahead` without consuming
   it *)
type 'a t =
  { mutable lookahead : 'a option
  ; provider : unit -> 'a
  }

let create provider = { lookahead = None; provider }

let peek state =
  match state.lookahead with
  | Some token -> token
  | None ->
    let token = state.provider () in
    state.lookahead <- Some token;
    token

let consume state =
  match state.lookahead with
  | Some token ->
    state.lookahead <- None;
    token
  | None -> state.provider ()

let consume_and_peek state =
  let _ = consume state in
  peek state
