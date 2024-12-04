type vuln_type =
  | Cmd_injection
  | Code_injection
  | Path_traversal
  | Proto_pollution

type param_type =
  | Any
  | Number
  | String
  | Boolean
  | Function
  | Array of param_type list
  | Object of object_type
  | Union of param_type list (* | `Concrete *)

and object_type =
  [ `Lazy
  | `Polluted of int
  | `Normal of (string * param_type) list
  ]

type vuln_conf =
  { filename : string option
  ; ty : vuln_type option
  ; source : string option
  ; source_lineno : int option
  ; sink : string option
  ; sink_lineno : int option
  ; tainted_params : string list
  ; params : (string * param_type) list
  ; cont : cont option
  }

and cont =
  | Return of vuln_conf
  | Sequence of vuln_conf

module type Intf = sig
  type nonrec vuln_type = vuln_type

  type nonrec param_type = param_type

  type nonrec object_type = object_type

  type nonrec vuln_conf = vuln_conf

  type nonrec cont = cont

  val unroll : vuln_conf -> vuln_conf list
end
