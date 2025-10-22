type t =
  | Stdout of string
  | File of Path.t
  | File_access of Path.t
  | Error of string
[@@deriving yojson]

let defaults =
  [ File (Path.v "./success")
  ; Stdout "success"
  ; Error "I pollute."
  ; Stdout "polluted"
  ]

let pp fmt = function
  | Stdout str -> Fmt.pf fmt "(\"%s\" in stdout)" str
  | File fpath -> Fmt.pf fmt "(created file \"%a\")" Path.pp fpath
  | File_access _ -> Fmt.pf fmt "(undesired file access occurred)"
  | Error str -> Fmt.pf fmt "(threw Error(\"%s\"))" str
