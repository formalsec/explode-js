open Syntax.Result
module Json = Yojson.Basic

type t = Fpath.t list

let pp_json = Json.pretty_print ~std:true

let json_from_file filename = Json.from_file ~fname:filename filename

let fpath = function
  | `String str -> Ok (Fpath.v str)
  | x -> Error (`Msg (Fmt.str "Could not parse string from: %a" pp_json x))

let fpath_exn = function
  | `String str -> Fpath.v str
  | x -> Fmt.failwith "Could not parse string from: %a" pp_json x

let list parser = function
  | `Null -> Ok []
  | `List l -> list_bind_map parser l
  | x -> Error (`Msg (Fmt.str "Could not parse list from: %a" pp_json x))

let from_file filename =
  let json_index = json_from_file filename in
  List.concat_map
    (fun pkg ->
      let vulns = Json.Util.(to_list @@ member "vulns" pkg) in
      List.map (fun vuln -> fpath_exn @@ Json.Util.member "filename" vuln) vulns
      )
    (Json.Util.to_list json_index)
