include Vuln_intf

(** [unroll_params params] performs type unrolling of union types *)
let rec unroll_params (params : (string * param_type) list) :
  (string * param_type) list list =
  let open Syntax.List in
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

let rec unroll (vuln : vuln_conf) : vuln_conf list =
  let open Syntax.List in
  let cs =
    let+ params = unroll_params vuln.params in
    { vuln with params }
  in
  match vuln.cont with
  | None -> cs
  | Some (Return cont) ->
    let* conf = unroll cont in
    let+ c = cs in
    { c with cont = Some (Return conf) }
  | Some (Sequence cont) ->
    let* conf = unroll cont in
    let+ c = cs in
    { c with cont = Some (Sequence conf) }
