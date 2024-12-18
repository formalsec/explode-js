type template =
  | Text of string
  | Var of string

type t =
  | Eof
  | Compose of template * t

let text x = Text x

let var x = Var x

let eof = Eof

let compose a b = Compose (a, b)

let ( & ) a b = compose a b [@@inline]

let render template models =
  let rec loop acc = function
    | Eof -> acc
    | Compose (a, b) ->
      let text = match a with Text x -> x | Var x -> List.assoc x models in
      loop (Fmt.str "%s%s" acc text) b
  in
  loop "" template
