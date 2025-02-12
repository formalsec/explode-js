module Map = Map.Make (String)

type t = Value.t Map.t

let get m x =
  match Map.find_opt x m with Some v -> v | None -> Value.Undefined

module Parser = struct
  module Json = Yojson.Basic
  module Util = Yojson.Basic.Util

  let from_json (json : Json.t) : t =
    let add_binding map (name, json) =
      match Util.member "value" json with
      | `Null -> map
      | `Int x -> Map.add name (Value.Number (float_of_int x)) map
      | `Float x -> Map.add name (Value.Number x) map
      | `String x -> Map.add name (Value.String x) map
      | `Bool x -> Map.add name (Value.Bool x) map
      | `Assoc _ | `List _ ->
        Fmt.epr "Value.Parser.from_json: unexpected value in witness@.";
        map
    in
    let model = Util.member "model" json |> Util.to_assoc in
    List.fold_left add_binding Map.empty model

  let from_file (fname : string) : (t, [> Instrument_result.err ]) result =
    let open Result in
    match Json.from_file ~fname fname with
    | exception Yojson.Json_error msg -> Error (`Malformed_json msg)
    | json -> Ok (from_json json)
end
