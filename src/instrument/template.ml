type value =
  | Text of string
  | Var of string

let text x = Text x

let var x = Var x

type t =
  | Eof
  | Compose of value * t

let eof = Eof

let compose a b = Compose (a, b)

let ( & ) a b = compose a b [@@inline]

let render template models =
  let rec loop acc = function
    | Eof -> acc
    | Compose (a, b) ->
      let text =
        match a with
        | Text x -> x
        | Var x -> begin
          match List.assoc_opt x models with
          | Some s -> s
          | None -> Fmt.failwith "No value for template variable '%s'" x
        end
      in
      loop (Fmt.str "%s%s" acc text) b
  in
  loop "" template
