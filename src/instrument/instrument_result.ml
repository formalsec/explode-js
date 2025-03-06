type err =
  [ `Msg of string
  | `Unknown_vuln_type of string
  | `Unknown_param_type of string
  | `Unknown_param of string
  | `Expected_string
  | `Expected_list
  | `Expected_assoc
  | `Malformed_json of string
  ]

let pp fmt = function
  | `Msg s -> Fmt.string fmt s
  | `Unknown_vuln_type s -> Fmt.pf fmt "Unknown vulnerability type: %s" s
  | `Unknown_param_type s -> Fmt.pf fmt "Unknown parameter type: %s" s
  | `Unknown_param s -> Fmt.pf fmt "Unknown parameter: %s" s
  | `Expected_string -> Fmt.pf fmt "Expected a string"
  | `Expected_list -> Fmt.pf fmt "Expected a list"
  | `Expected_assoc -> Fmt.pf fmt "Expected an object"
  | `Malformed_json s -> Fmt.pf fmt "Malformed summary: %s" s

let to_code = function
  | `Msg _ -> 1
  | `Unknown_vuln_type _ -> 2
  | `Unknown_param_type _ -> 3
  | `Unknown_param _ -> 4
  | `Expected_string -> 5
  | `Expected_list -> 6
  | `Expected_assoc -> 7
  | `Malformed_json _ -> 8
