type t =
  | Number of float
  | String of string
  | Bool of bool
  | Undefined

let pp fmt = function
  | Number x -> Fmt.float fmt x
  | String x -> Fmt.pf fmt "%S" x
  | Bool x -> Fmt.bool fmt x
  | Undefined -> Fmt.string fmt "undefined"
