let filename = Fpath.(v "datasets" / "metadata" / "vulcan-file-index.json")

let config =
  let filename = Fpath.to_string filename in
  Json.from_file ~fname:filename filename

let pp_json fmt v = Json.pretty_print ~std:true fmt v

let fpath = function
  | `String str -> Ok (Fpath.v str)
  | x -> Error (`Msg (Fmt.str "Could not parse string from: %a" pp_json x))

let list parser = function
  | `Null -> Ok []
  | `List l -> list_bind_map parser l
  | x -> Error (`Msg (Fmt.str "Could not parse list from: %a" pp_json x))

let vulcan_prefix =
  Fpath.(v "datasets" / "vulcan-dataset" / "_build" / "packages")

let set_prefix_path_for cwe p = Fpath.(vulcan_prefix / cwe // p)

let parsed_benchmarks =
  let* cwe22 = list fpath @@ Json.Util.member "packages/CWE-22" config in
  let* cwe78 = list fpath @@ Json.Util.member "packages/CWE-78" config in
  let* cwe94 = list fpath @@ Json.Util.member "packages/CWE-94" config in
  let* cwe471 = list fpath @@ Json.Util.member "packages/CWE-471" config in
  let* cwe1321 = list fpath @@ Json.Util.member "packages/CWE-1321" config in
  Ok { cwe22; cwe78; cwe94; cwe471; cwe1321 }

let benchmarks =
  let* { cwe22; cwe78; cwe94; cwe471; cwe1321 } = parsed_benchmarks in
  let cwe22 = List.map (set_prefix_path_for "CWE-22") cwe22 in
  let cwe78 = List.map (set_prefix_path_for "CWE-78") cwe78 in
  let cwe94 = List.map (set_prefix_path_for "CWE-94") cwe94 in
  let cwe471 = List.map (set_prefix_path_for "CWE-471") cwe471 in
  let cwe1321 = List.map (set_prefix_path_for "CWE-1321") cwe1321 in
  Ok { cwe22; cwe78; cwe94; cwe471; cwe1321 }


