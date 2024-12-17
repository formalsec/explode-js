open Vuln_intf
open Format
open Result
module Json = Yojson.Basic
module Util = Yojson.Basic.Util

let vuln_type = function
  | "command-injection" -> Ok Cmd_injection
  | "code-injection" -> Ok Code_injection
  | "path-traversal" -> Ok Path_traversal
  | "prototype-pollution" -> Ok Proto_pollution
  | str -> Error (`Unknown_vuln_type str)

let param_type (ty : string) =
  match String.trim ty with
  | "any" -> Ok Any
  | "number" -> Ok Number
  | "string" -> Ok String
  | "bool" | "boolean" -> Ok Boolean
  | "function" -> Ok Function
  | "array" -> Ok (Array [ String ])
  | "object" -> Ok (Object (`Normal []))
  | "polluted_object2" -> Ok (Object (`Polluted 2))
  | "polluted_object3" -> Ok (Object (`Polluted 3))
  | "lazy_object" -> Ok (Object `Lazy)
  | x -> Error (`Unknown_param_type x)

let fix_dynamic_prop =
  let counter = ref ~-1 in
  function
  | "*" ->
    incr counter;
    Format.sprintf "dp%d" !counter
  | str -> str

let rec param (json : Json.t) =
  match json with
  | `String ty -> param_type ty
  | `Assoc obj -> (
    match Util.member "_union" json with
    | `Null ->
      let+ params =
        list_map obj ~f:(fun (k, v) ->
          let+ ty = param v in
          (fix_dynamic_prop k, ty) )
      in
      Object (`Normal params)
    | `List tys ->
      let+ tys = list_map ~f:param tys in
      Union tys
    | _ ->
      (* should not happen *)
      assert false )
  | `List arr ->
    let+ arr = list_map ~f:param arr in
    Array arr
  | _ -> Error (`Unknown_param (asprintf "%a" Json.pp json))

let string_opt = function `String str -> Some str | `Null | _ -> None

let string = function `String str -> Ok str | _ -> Error `Expected_string

let int_opt = function `Int i -> Some i | `Null | _ -> None

let list = function `List lst -> Ok lst | _ -> Error `Expected_list

let assoc = function `Assoc lst -> Ok lst | _ -> Error `Expected_assoc

let bind v f =
  match v with
  | None -> Ok None
  | Some v ->
    let+ v = f v in
    Some v

let rec from_json (json : Json.t) :
  (vuln_conf, [> Instrument_result.err ]) result =
  let filename = string_opt (Util.member "filename" json) in
  let* ty = bind (string_opt (Util.member "vuln_type" json)) vuln_type in
  let source = string_opt (Util.member "source" json) in
  let source_lineno = int_opt (Util.member "source_lineno" json) in
  let sink = string_opt (Util.member "sink" json) in
  let sink_lineno = int_opt (Util.member "sink_lineno" json) in
  let* tainted_params =
    let* tainted = list (Util.member "tainted_params" json) in
    list_map ~f:string tainted
  in
  let* params =
    let* params = assoc (Util.member "params_types" json) in
    list_map params ~f:(fun (k, v) ->
      let+ ty = param v in
      (fix_dynamic_prop k, ty) )
  in
  let+ cont =
    (* Can only have one type of continuation at a time *)
    (* FIXME: To Allow return(s?) I made this horrible nested match *)
    match Util.member "return" json with
    | `Null -> (
      match Util.member "returns" json with
      | `Null -> (
        match Util.member "sequence" json with
        | `Null -> Ok None
        | tree ->
          let+ tree = from_json tree in
          Some (Sequence tree) )
      | tree ->
        let+ tree = from_json tree in
        Some (Return tree) )
    | tree ->
      let+ tree = from_json tree in
      Some (Return tree)
  in
  { filename
  ; ty
  ; source
  ; source_lineno
  ; sink
  ; sink_lineno
  ; tainted_params
  ; params
  ; cont
  }

let from_file (fname : string) :
  (vuln_conf list, [> Instrument_result.err ]) result =
  try
    let json = Json.from_file ~fname fname in
    Logs.debug (fun m -> m "json of %s:@.%a" fname Json.pp json);
    let* vulns = list json in
    list_map ~f:from_json vulns
  with Yojson.Json_error msg -> Error (`Malformed_json msg)
