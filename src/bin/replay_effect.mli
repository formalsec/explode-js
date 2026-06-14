type t =
  | Stdout of string
  | File of string
  | File_access of string
  | Error of string

val defaults : t list

val pp : t Fmt.t

val to_yojson : t -> Yojson.Safe.t

val of_yojson : Yojson.Safe.t -> (t, string) result
