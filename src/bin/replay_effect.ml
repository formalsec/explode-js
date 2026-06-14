type t =
  | Stdout of string
  | File of string
  | File_access of string
  | Error of string
[@@deriving yojson]

let defaults =
  [ File "./success"; Stdout "success"; Error "I pollute."; Stdout "polluted" ]

let pp fmt = function
  | Stdout str -> Fmt.pf fmt "(\"%s\" in stdout)" str
  | File fpath -> Fmt.pf fmt "(created file \"%s\")" fpath
  | File_access _ -> Fmt.pf fmt "(undesired file access occurred)"
  | Error str -> Fmt.pf fmt "(threw Error(\"%s\"))" str
