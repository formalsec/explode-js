type t =
  [ `Number of float
  | `String of string
  | `Bool of bool
  | `Undefined
  ]

module Map = Map.Make (String)

let pp fmt = function
  | `Number x -> Format.pp_print_float fmt x
  | `String x -> Format.fprintf fmt "%S" x
  | `Bool x -> Format.pp_print_bool fmt x
  | `Undefined -> Format.pp_print_string fmt "undefined"

module Parser = struct
  open Syntax.Result
  module Json = Yojson.Basic
  module Util = Yojson.Basic.Util

  let from_json (json : Json.t) : t Map.t =
    let add_binding map (name, json) =
      match Util.member "value" json with
      | `Null -> map
      | `Float x -> Map.add name (`Number x) map
      | `String x -> Map.add name (`String x) map
      | `Bool x -> Map.add name (`Bool x) map
      | _ ->
        Format.eprintf "Value.Parser.from_json: unexpected value in witness@.";
        map
    in
    let model = Util.member "model" json |> Util.to_assoc in
    List.fold_left add_binding Map.empty model

  let from_file (fname : string) : (t Map.t, [> Result.err ]) result =
    let* json =
      try Ok (Json.from_file ~fname fname)
      with Yojson.Json_error msg -> Error (`Malformed_json msg)
    in
    Ok (from_json json)
end
