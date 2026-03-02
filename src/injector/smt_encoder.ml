open Rule
module StringMap = Map.Make (String)

let encode (grammar : Rule.t list) (target_rule : string)
  (input_expr : Smtml.Typed.String.t) : Smtml.Typed.Bool.t =
  let rule_map =
    List.fold_left
      (fun acc (r : Rule.t) -> StringMap.add r.name r acc)
      StringMap.empty grammar
  in

  let memo = Hashtbl.create 17 in

  let rec encode_rule name =
    match Hashtbl.find_opt memo name with
    | Some res -> res
    | None ->
      let rule =
        match StringMap.find_opt name rule_map with
        | Some r -> r
        | None -> Fmt.failwith "Undefined non-terminal: %s" name
      in
      let res = encode_body rule.body in
      Hashtbl.add memo name res;
      res
  and encode_body body =
    let cases = List.map encode_case body in
    match cases with
    | [ one ] -> one
    | _ -> Smtml.Typed.String.Re.union cases
  and encode_case atoms =
    let res = List.map encode_atom atoms in
    match res with
    | [ one ] -> one
    | _ -> Smtml.Typed.String.Re.concat res
  and encode_atom = function
    | Terminal s ->
      let s =
        if String.length s >= 2 && s.[0] = '"' && s.[String.length s - 1] = '"'
        then String.sub s 1 (String.length s - 2)
        else s
      in
      let s = Smtml.Typed.String.v s in
      Smtml.Typed.String.to_re s
    | Non_terminal id -> encode_rule id
  in

  let re = encode_rule target_rule in
  (* Assumes String_in_re is a valid relop for Ty_str *)
  Smtml.Typed.String.in_re input_expr re
