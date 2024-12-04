include Sqlite3_utils

let to_result = function Ok v -> Ok v | Error rc -> Error (`Sqlite3 rc)

let unwrap_db = function
  | Ok v -> v
  | Error rc -> Fmt.failwith "uncaught sqlite3 error: %s" (Rc.to_string rc)
