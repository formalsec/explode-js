type identifier = string

type ruleatom =
  | Terminal of string
  | Non_terminal of identifier

let pp_ruleatom fmt = function
  | Terminal token -> Fmt.pf fmt "%s" token
  | Non_terminal token -> Fmt.pf fmt "<%s>" token

type rulecase = ruleatom list

let pp_rulecase atoms = Fmt.hbox (Fmt.list ~sep:Fmt.sp pp_ruleatom) atoms

type t =
  { name : identifier
  ; body : rulecase list
  }

let pp fmt { name; body } =
  Fmt.pf fmt "@[<hov 2><%s> ::= @[<hv>%a@]@];" name
    (Fmt.list ~sep:(Fmt.any "@ | ") pp_rulecase)
    body
