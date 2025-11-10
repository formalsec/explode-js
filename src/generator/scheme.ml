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
[@@deriving show]

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
[@@deriving show]

and cont =
  | Return of t
  | Sequence of t
  | Client of
      { request_ty : [ `GET | `POST ]
      ; port : int
      }
[@@deriving show]

let ty { ty; _ } = ty

let filename { filename; _ } = filename

let metadata { filename; ty; sink; sink_lineno; _ } =
  (Option.get filename, ty, sink, sink_lineno)

let rec client { cont; _ } =
  match cont with
  | None -> `None
  | Some (Client { request_ty; port }) -> `Client (request_ty, port)
  | Some (Return cont | Sequence cont) -> client cont

let needs_client scheme =
  match client scheme with
  | `None -> false
  | `Client _ -> true

(** [unroll_params params] performs type unrolling of union types *)
let rec unroll_params ~proto_pollution (params : (string * param_type) list) :
  (string * param_type) list list =
  let open List.Syntax in
  let rec loop wl acc =
    match wl with
    | [] -> acc
    | ((x, ty) as param) :: wl' ->
      let acc' =
        match ty with
        | Any ->
          (* Mega hack *)
          let+ params = acc in
          if proto_pollution && String.equal x "target" then
            (x, Object (`Normal [])) :: params
          else param :: params
        | Object (`Normal prps) ->
          let* prps' = unroll_params ~proto_pollution prps in
          let+ params = acc in
          List.cons (x, Object (`Normal prps')) params
        | Union tys -> begin
          let tys =
            if proto_pollution && List.mem (Array [ String ]) tys then
              tys @ [ Array [ String; String ] ]
            else tys
          in
          let* ty = tys in
          match ty with
          | Object (`Normal prps) ->
            let* prps' = unroll_params ~proto_pollution prps in
            let+ params = acc in
            List.cons (x, Object (`Normal prps')) params
          | _ ->
            let+ params = acc in
            List.cons (x, ty) params
        end
        | Array [ String ] ->
          let lst1 =
            let+ acc in
            List.cons param acc
          in
          let lst2 =
            if proto_pollution then
              let+ acc in
              List.cons (x, Array [ String; String ]) acc
            else []
          in
          lst1 @ lst2
        | _ ->
          let+ params = acc in
          List.cons param params
      in
      loop wl' acc'
  in
  let+ params = loop params [ [] ] in
  List.rev params

let rec unroll ~proto_pollution (tmpl : t) : t list =
  let open List.Syntax in
  let cs =
    let+ params = unroll_params ~proto_pollution tmpl.params in
    { tmpl with params }
  in
  match tmpl.cont with
  | None | Some (Client _) -> cs
  | Some (Return cont) ->
    let* conf = unroll ~proto_pollution cont in
    let+ c = cs in
    { c with cont = Some (Return conf) }
  | Some (Sequence cont) ->
    let* conf = unroll ~proto_pollution cont in
    let+ c = cs in
    { c with cont = Some (Sequence conf) }

module Parser : sig
  val from_file :
    proto_pollution:bool -> Fpath.t -> (t list list, [> `Msg of string ]) result
end = struct
  module Json = Yojson.Safe
  module Json_util = Yojson.Safe.Util

  let param_type_of_string (ty : string) =
    match String.trim ty with
    | "any" | "undefined" -> Ok Any
    | "number" -> Ok Number
    | "string" -> Ok String
    | "bool" | "boolean" -> Ok Boolean
    | "function" -> Ok Function
    | "array" -> Ok (Array [ String ])
    | "object" -> Ok (Object (`Normal []))
    | "polluted_object1" -> Ok (Object (`Polluted 1))
    | "polluted_object2" -> Ok (Object (`Polluted 2))
    | "polluted_object3" -> Ok (Object (`Polluted 3))
    | "lazy_object" -> Ok (Object `Lazy)
    | x -> Error (`Msg (Fmt.str "unexpected param type: '%s'" x))

  let fix_dynamic_prop =
    let counter = ref ~-1 in
    function
    | "*" ->
      incr counter;
      Fmt.str "dp%d" !counter
    | str -> str

  let rec param_of_json (json : Json.t) =
    let open Result.Syntax in
    match json with
    | `String ty -> param_type_of_string ty
    | `Assoc obj -> begin
      match Json_util.member "_union" json with
      | `Null ->
        let+ params =
          Result.list_map
            (fun (k, v) ->
              let+ ty = param_of_json v in
              (fix_dynamic_prop k, ty) )
            obj
        in
        Object (`Normal params)
      | `List tys ->
        let+ tys = Result.list_map param_of_json tys in
        Union tys
      | _ ->
        (* should not happen *)
        assert false
    end
    | `List arr ->
      let+ arr = Result.list_map param_of_json arr in
      Array arr
    | _ -> Error (`Msg (Fmt.str "unexpected param %a" Json.pp json))

  let string_opt = function
    | `String str -> Some str
    | `Null | _ -> None

  let string = function
    | `String str -> Ok str
    | json -> Error (`Msg (Fmt.str "expecting 'String' but got %a" Json.pp json))

  let int_opt = function
    | `Int i -> Some i
    | `Null | _ -> None

  let int = function
    | `Int i -> Ok i
    | json -> Error (`Msg (Fmt.str "expecting 'Int' but got %a" Json.pp json))

  let list = function
    | `List lst -> Ok lst
    | json -> Error (`Msg (Fmt.str "expecting 'List' but got %a" Json.pp json))

  let assoc = function
    | `Assoc lst -> Ok lst
    | json -> Error (`Msg (Fmt.str "expecting 'Assoc' but got %a" Json.pp json))

  let bind v f =
    let open Result.Syntax in
    match v with
    | None -> Ok None
    | Some v ->
      let+ v = f v in
      Some v

  let request_ty_of_json json =
    let open Result.Syntax in
    let* s = string json in
    match s with
    | "GET" -> Ok `GET
    | "POST" -> Ok `POST
    | _ -> Error (`Msg (Fmt.str "unexpected client request of type: %s" s))

  let rec t_of_json (json : Json.t) =
    let open Result.Syntax in
    let* filename =
      match Json_util.member "filename" json with
      | `Null -> Ok None
      | json ->
        let* filename = string json in
        Ok (Some (Fpath.v (Unix.realpath filename)))
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
      Result.list_map string tainted
    in
    let* params =
      let* params = Json_util.member "params_types" json |> assoc in
      Result.list_map
        (fun (k, v) ->
          let+ ty = param_of_json v in
          (fix_dynamic_prop k, ty) )
        params
    in
    let+ cont = cont_of_json json in
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

  and cont_of_json json =
    let open Result.Syntax in
    (* Can only have one type of continuation at a time *)
    (* FIXME: To Allow return(s?) I made this horrible nested match *)
    match Json_util.member "return" json with
    | `Null -> begin
      match Json_util.member "returns" json with
      | `Null -> begin
        match Json_util.member "sequence" json with
        | `Null -> begin
          match Json_util.member "client" json with
          | `Null -> Ok None
          | tree ->
            let* request_ty =
              Json_util.member "type" tree |> request_ty_of_json
            in
            let+ port = Json_util.member "port" tree |> int in
            Some (Client { request_ty; port })
        end
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

  let from_file ~proto_pollution fname =
    let open Result.Syntax in
    let fname = Fpath.to_string fname in
    match Json.from_file ~fname fname with
    | exception Yojson.Json_error msg -> Error (`Msg msg)
    | json ->
      let* vulns = list json in
      let+ vulns = Result.list_map t_of_json vulns in
      List.map (unroll ~proto_pollution) vulns
end
