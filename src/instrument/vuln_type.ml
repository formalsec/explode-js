type t =
  | Cmd_injection
  | Code_injection
  | Path_traversal
  | Proto_pollution

let discr = function
  | Cmd_injection -> 0
  | Code_injection -> 1
  | Path_traversal -> 2
  | Proto_pollution -> 3

let compare a b = compare (discr a) (discr b)

let equal a b = compare a b = 0

let pp fmt = function
  | Cmd_injection -> Fmt.string fmt "command-injection"
  | Code_injection -> Fmt.string fmt "code-injection"
  | Path_traversal -> Fmt.string fmt "path-traversal"
  | Proto_pollution -> Fmt.string fmt "prototype-pollution"

let of_string = function
  | "command-injection" -> Ok Cmd_injection
  | "code-injection" -> Ok Code_injection
  | "path-traversal" -> Ok Path_traversal
  | "prototype-pollution" -> Ok Proto_pollution
  | str -> Error (`Unknown_vuln_type str)
