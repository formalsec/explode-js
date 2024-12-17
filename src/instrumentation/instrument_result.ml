include Stdlib.Result

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
  | `Msg s -> Format.pp_print_string fmt s
  | `Unknown_vuln_type s ->
    Format.fprintf fmt "Unknown vulnerability type: %s" s
  | `Unknown_param_type s -> Format.fprintf fmt "Unknown parameter type: %s" s
  | `Unknown_param s -> Format.fprintf fmt "Unknown parameter: %s" s
  | `Expected_string -> Format.fprintf fmt "Expected a string"
  | `Expected_list -> Format.fprintf fmt "Expected a list"
  | `Expected_assoc -> Format.fprintf fmt "Expected an object"
  | `Malformed_json s -> Format.fprintf fmt "Malformed summary: %s" s

let to_code = function
  | `Msg _ -> 1
  | `Unknown_vuln_type _ -> 2
  | `Unknown_param_type _ -> 3
  | `Unknown_param _ -> 4
  | `Expected_string -> 5
  | `Expected_list -> 6
  | `Expected_assoc -> 7
  | `Malformed_json _ -> 8
