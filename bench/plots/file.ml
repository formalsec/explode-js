let ( let* ) = Result.bind

let find_all pattern = Glob.glob ~recursive:true pattern

let find pattern =
  let* files = Glob.glob ~recursive:true pattern in
  match files with
  | [] ->
    Error
      (`Msg (Format.asprintf "Could not find files with: %a" Fpath.pp pattern))
  | x :: _ -> Ok x
