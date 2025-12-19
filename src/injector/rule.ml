type identifier = string [@@deriving show]

type ruleatom =
  | Terminal of string
  | Non_terminal of identifier
[@@deriving show]

type rulecase = ruleatom list [@@deriving show]

type t =
  { name : identifier
  ; body : rulecase list
  }
[@@deriving show]
