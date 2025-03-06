type t =
  | Stdout of string
  | File of Fpath.t
  | File_access of Fpath.t
  | Error of string

let pp fmt = function
  | Stdout str -> Fmt.pf fmt "(\"%s\" in stdout)" str
  | File fpath -> Fmt.pf fmt "(created file \"%a\")" Fpath.pp fpath
  | File_access _ -> Fmt.pf fmt "(undesired file access occurred)"
  | Error str -> Fmt.pf fmt "(threw Error(\"%s\"))" str

let defaults =
  [ File (Fpath.v "./success")
  ; Stdout "success"
  ; Error "I pollute."
  ; Stdout "polluted"
  ]
