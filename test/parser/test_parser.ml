open Auto_complete

let () =
  let result = Parse.from_string "var x = 0; var y = 1; var z = " in
  match result with
  | Ok stmts ->
    Fmt.pr "%a@."
      (Fmt.list ~sep:(fun fmt () -> Fmt.pf fmt "@\n") Fmt.string)
      stmts
  | Error msg -> Fmt.epr "%s" msg
