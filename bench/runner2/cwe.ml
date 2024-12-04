type t =
  | CWE_22
  | CWE_78
  | CWE_94
  | CWE_1321

let pp fmt = function
  | CWE_22 -> Fmt.string fmt "CWE-22"
  | CWE_78 -> Fmt.string fmt "CWE-78"
  | CWE_94 -> Fmt.string fmt "CWE-94"
  | CWE_1321 -> Fmt.string fmt "CWE-1321"

let to_string = Fmt.str "%a" pp

let of_string = function
  | "CWE-22" -> Ok CWE_22
  | "CWE-78" -> Ok CWE_78
  | "CWE-94" -> Ok CWE_94
  | "CWE-471" | "CWE-1321" -> Ok CWE_1321
  | s -> Error (`Parsing (Fmt.str "unknown cwe %s" s))

let equal a b =
  match (a, b) with
  | CWE_22, CWE_22 | CWE_78, CWE_78 | CWE_94, CWE_94 | CWE_1321, CWE_1321 ->
    true
  | (CWE_22 | CWE_78 | CWE_94 | CWE_1321), _ -> false
