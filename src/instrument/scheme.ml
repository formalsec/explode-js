type param_type =
  | Any
  | Number
  | String
  | Boolean
  | Function
  | Array of param_type list
  | Object of
      [ `Lazy | `Polluted of int | `Normal of (string * param_type) list ]
  | Union of param_type list

let rec equal_param_type a b =
  match (a, b) with
  | Any, Any
  | Number, Number
  | String, String
  | Boolean, Boolean
  | Function, Function ->
    true
  | Array tys1, Array tys2 -> List.for_all2 equal_param_type tys1 tys2
  | Union tys1, Union tys2 -> List.for_all2 equal_param_type tys1 tys2
  | Object ty1, Object ty2 -> begin
    match (ty1, ty2) with
    | `Lazy, `Lazy -> true
    | `Polluted a, `Polluted b -> a = b
    | `Normal a_props, `Normal b_props ->
      List.for_all2
        (fun (a_prop, a_ty) (b_prop, b_ty) ->
          String.equal a_prop b_prop && equal_param_type a_ty b_ty )
        a_props b_props
    | (`Lazy | `Polluted _ | `Normal _), _ -> false
  end
  | ( (Any | Number | String | Boolean | Function | Array _ | Union _ | Object _)
    , _ ) ->
    false

type t =
  { filename : Fpath.t option
  ; ty : Vuln_type.t option
  ; source : string option
  ; source_lineno : int option
  ; sink : string option
  ; sink_lineno : int option
  ; tainted_params : string list
  ; params : (string * param_type) list
  ; cont : cont option
  }

and cont =
  | Return of t
  | Sequence of t

let filename { filename; _ } = filename

(** [unroll_params params] performs type unrolling of union types *)
let rec unroll_params (params : (string * param_type) list) :
  (string * param_type) list list =
  let open List in
  let rec loop wl acc =
    match wl with
    | [] -> acc
    | ((x, ty) as param) :: wl' ->
      let acc' =
        match ty with
        | Object (`Normal prps) ->
          let* prps' = unroll_params prps in
          let+ params = acc in
          List.cons (x, Object (`Normal prps')) params
        | Union tys ->
          let* ty = tys in
          let+ params = acc in
          List.cons (x, ty) params
        | _ ->
          let+ params = acc in
          List.cons param params
      in
      loop wl' acc'
  in
  let+ params = loop params [ [] ] in
  List.rev params

let rec unroll (tmpl : t) : t list =
  let open List in
  let cs =
    let+ params = unroll_params tmpl.params in
    { tmpl with params }
  in
  match tmpl.cont with
  | None -> cs
  | Some (Return cont) ->
    let* conf = unroll cont in
    let+ c = cs in
    { c with cont = Some (Return conf) }
  | Some (Sequence cont) ->
    let* conf = unroll cont in
    let+ c = cs in
    { c with cont = Some (Sequence conf) }

module Parser : sig
  val from_file : Fpath.t -> (t list, [> Instrument_result.err ]) result
end = struct
  open Result
  module Json = Yojson.Basic
  module Json_util = Yojson.Basic.Util

  let param_type_of_string (ty : string) =
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
      Fmt.str "dp%d" !counter
    | str -> str

  let rec param_of_json (json : Json.t) =
    match json with
    | `String ty -> param_type_of_string ty
    | `Assoc obj -> begin
      match Json_util.member "_union" json with
      | `Null ->
        let+ params =
          list_map
            (fun (k, v) ->
              let+ ty = param_of_json v in
              (fix_dynamic_prop k, ty) )
            obj
        in
        Object (`Normal params)
      | `List tys ->
        let+ tys = list_map param_of_json tys in
        Union tys
      | _ ->
        (* should not happen *)
        assert false
    end
    | `List arr ->
      let+ arr = list_map param_of_json arr in
      Array arr
    | _ -> Error (`Unknown_param (Fmt.str "%a" Json.pp json))

  let string_opt = function
    | `String str -> Some str
    | `Null | _ -> None

  let string = function
    | `String str -> Ok str
    | _ -> Error `Expected_string

  let int_opt = function
    | `Int i -> Some i
    | `Null | _ -> None

  let list = function
    | `List lst -> Ok lst
    | _ -> Error `Expected_list

  let assoc = function
    | `Assoc lst -> Ok lst
    | _ -> Error `Expected_assoc

  let bind v f =
    match v with
    | None -> Ok None
    | Some v ->
      let+ v = f v in
      Some v

  let rec t_of_json (json : Json.t) =
    let filename =
      Json_util.member "filename" json |> string_opt |> Option.map Fpath.v
    in
    let* ty =
      let vuln_type = Json_util.member "vuln_type" json |> string_opt in
      bind vuln_type Vuln_type.of_string
    in
    let source = Json_util.member "source" json |> string_opt in
    let source_lineno = Json_util.member "source_lineno" json |> int_opt in
    let sink = Json_util.member "sink" json |> string_opt in
    let sink_lineno = Json_util.member "sink_lineno" json |> int_opt in
    let* tainted_params =
      let* tainted = Json_util.member "tainted_params" json |> list in
      list_map string tainted
    in
    let* params =
      let* params = Json_util.member "params_types" json |> assoc in
      list_map
        (fun (k, v) ->
          let+ ty = param_of_json v in
          (fix_dynamic_prop k, ty) )
        params
    in
    let+ cont =
      (* Can only have one type of continuation at a time *)
      (* FIXME: To Allow return(s?) I made this horrible nested match *)
      match Json_util.member "return" json with
      | `Null -> begin
        match Json_util.member "returns" json with
        | `Null -> begin
          match Json_util.member "sequence" json with
          | `Null -> Ok None
          | tree ->
            let+ tree = t_of_json tree in
            Some (Sequence tree)
        end
        | tree ->
          let+ tree = t_of_json tree in
          Some (Return tree)
      end
      | tree ->
        let+ tree = t_of_json tree in
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

  let from_file fname =
    let fname = Fpath.to_string fname in
    match Json.from_file ~fname fname with
    | exception Yojson.Json_error msg -> Error (`Malformed_json msg)
    | json ->
      let* vulns = list json in
      let+ vulns = list_map t_of_json vulns in
      List.concat_map unroll vulns
end
