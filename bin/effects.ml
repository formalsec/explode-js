type t =
  | Stdout of string
  | File of string
  | File_access of Fpath.t
  | Error of string

let pp fmt = function
  | Stdout str -> Format.fprintf fmt "(\"%s\" in stdout)" str
  | File f -> Format.fprintf fmt "(created file \"%s\")" f
  | File_access _ -> Format.fprintf fmt "(undesired file access occurred)"
  | Error str -> Format.fprintf fmt "(threw Error(\"%s\"))" str

let default =
  [ File "success"; Stdout "success"; Error "I pollute."; Stdout "polluted" ]
