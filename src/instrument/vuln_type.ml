type t =
  | Cmd_injection
  | Code_injection
  | Path_traversal
  | Proto_pollution

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
