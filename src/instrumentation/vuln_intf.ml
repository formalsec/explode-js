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

type t =
  { filename : string option
  ; ty : Vuln_type.t option
  ; source : string option
  ; source_lineno : int option
  ; sink : string option
  ; sink_lineno : int option
  ; tainted_params : string list
  ; params : (string * param_type) list
  ; cont : cont option
  }

and cont =
  | Return of t
  | Sequence of t

module type Intf = sig
  type nonrec param_type = param_type

  type nonrec object_type = object_type

  type nonrec t = t

  type nonrec cont = cont

  val unroll : t -> t list
end
