type identifier = string

type ruleatom =
  | Terminal of string
  | Non_terminal of identifier
  | Range of char * char
  | Star of ruleatom
  | Plus of ruleatom
  | Opt of ruleatom
  | Group of ruleatom list list

let rec pp_ruleatom fmt = function
  | Terminal token -> Fmt.pf fmt "%s" token
  | Non_terminal token -> Fmt.pf fmt "<%s>" token
  | Range (c1, c2) -> Fmt.pf fmt "[%c-%c]" c1 c2
  | Star atom -> Fmt.pf fmt "%a*" pp_ruleatom atom
  | Plus atom -> Fmt.pf fmt "%a+" pp_ruleatom atom
  | Opt atom -> Fmt.pf fmt "%a?" pp_ruleatom atom
  | Group body -> Fmt.pf fmt "(%a)" pp_rulebody body

and pp_rulecase fmt atoms = (Fmt.list ~sep:Fmt.sp pp_ruleatom) fmt atoms

and pp_rulebody fmt body = (Fmt.list ~sep:(Fmt.any " | ") pp_rulecase) fmt body

type rulecase = ruleatom list

let pp_rulecase_hbox atoms = Fmt.hbox pp_rulecase atoms

type t =
  { name : identifier
  ; body : rulecase list
  }

let pp fmt { name; body } =
  Fmt.pf fmt "@[<hov 2><%s> ::= @[<hv>%a@]@];" name
    (Fmt.list ~sep:(Fmt.any "@ | ") pp_rulecase_hbox)
    body
