open Rule
open Call_graph

let unfold (rules : Rule.t list) (k : int) : Rule.t list =
  let cg = Call_graph.build rules in
  let recursive = Call_graph.recursive_nonterminals cg in

  (* Create an ordering of non-terminals to break cycles exactly once *)
  let order =
    List.mapi (fun i (r : Rule.t) -> (r.name, i)) rules
    |> List.to_seq |> StringMap.of_seq
  in
  let get_order name =
    StringMap.find_opt name order |> Option.value ~default:0
  in

  let make_name name i = Printf.sprintf "%s_%d" name i in

  let rec transform_atom current_name i atom =
    match atom with
    | Terminal _ | Range _ -> Some atom
    | Star atom ->
      Option.map (fun a -> Star a) (transform_atom current_name i atom)
    | Plus atom ->
      Option.map (fun a -> Plus a) (transform_atom current_name i atom)
    | Opt atom ->
      Option.map (fun a -> Opt a) (transform_atom current_name i atom)
    | Group body ->
      let new_body = List.filter_map (transform_case current_name i) body in
      if List.is_empty new_body then None else Some (Group new_body)
    | Non_terminal id ->
      if StringSet.mem id recursive then
        let next_i =
          if
            Call_graph.can_reach cg id current_name
            && get_order id <= get_order current_name
          then i - 1
          else i
        in
        if next_i < 0 then None else Some (Non_terminal (make_name id next_i))
      else Some (Non_terminal id)
  and transform_case current_name i case =
    let rec loop acc = function
      | [] -> Some (List.rev acc)
      | hd :: tl -> (
        match transform_atom current_name i hd with
        | None -> None
        | Some a -> loop (a :: acc) tl )
    in
    loop [] case
  in

  let build_new_rules rule =
    let rec loop acc i =
      if i < 0 then acc
      else
        let new_name = make_name rule.name i in
        let new_body = List.filter_map (transform_case rule.name i) rule.body in
        let new_rule = { name = new_name; body = new_body } in
        loop (new_rule :: acc) (i - 1)
    in
    loop [] k
  in

  let base_rules =
    List.fold_left
      (fun acc rule ->
        if StringSet.mem rule.name recursive then build_new_rules rule @ acc
        else
          let new_body =
            List.filter_map (transform_case rule.name k) rule.body
          in
          let new_rule = { name = rule.name; body = new_body } in
          new_rule :: acc )
      [] rules
  in

  List.rev base_rules
