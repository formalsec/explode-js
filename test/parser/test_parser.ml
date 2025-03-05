open Auto_complete

let ( let* ) = Result.bind

let ( let+ ) v f = Result.map f v

let nl fmt () = Fmt.pf fmt "@\n"

let test_empty () =
  let+ stmts = Parse.from_string "" in
  Fmt.pr "%a@." (Fmt.list ~sep:nl Fmt.string) stmts

let test_valid () =
  let+ stmts = Parse.from_string "var x = 0; var y = 1" in
  Fmt.pr "%a@." (Fmt.list ~sep:nl Fmt.string) stmts

let test_invalid_assignment () =
  let+ stmts = Parse.from_string "var x = " in
  Fmt.pr "%a@." (Fmt.list ~sep:nl Fmt.string) stmts

let test_invalid_expression () =
  let+ stmts = Parse.from_string "cl." in
  Fmt.pr "%a@." (Fmt.list ~sep:nl Fmt.string) stmts

let _test_invalid_expression2 () =
  let+ stmts = Parse.from_string "(" in
  Fmt.pr "%a@." (Fmt.list ~sep:nl Fmt.string) stmts

let result =
  let* () = test_empty () in
  let* () = test_valid () in
  let* () = test_invalid_assignment () in
  let+ () = test_invalid_expression () in
  ()

let () =
  match result with Ok () -> () | Error err -> Fmt.failwith "error: %s" err
