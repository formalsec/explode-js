open Rule
open Call_graph

let unfold (rules : Rule.t list) (k : int) : Rule.t list =
  let cg = Call_graph.build rules in
  let recursive = Call_graph.recursive_nonterminals cg in

  let make_name name i = Printf.sprintf "%s_%d" name i in

  let is_recursive_atom = function
    | Non_terminal id -> StringSet.mem id recursive
    | Terminal _ -> false
  in

  let is_recursive_case case = List.exists is_recursive_atom case in

  let transform_atom i atom =
    match atom with
    | Terminal t -> Terminal t
    | Non_terminal id ->
      if StringSet.mem id recursive then Non_terminal (make_name id i)
      else Non_terminal id
  in

  let transform_case i case = List.map (transform_atom i) case in

  let build_new_rules rule =
    let rec loop acc i =
      if i < 0 then acc
      else
        let new_name = make_name rule.name i in
        let new_body =
          if i = 0 then
            (* Filter out cases that contain recursive calls *)
            List.filter (fun case -> not (is_recursive_case case)) rule.body
          else List.map (transform_case (i - 1)) rule.body
        in
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
          (* Not recursive one might call recursive ones *)
          let new_rule =
            { name = rule.name; body = List.map (transform_case k) rule.body }
          in
          new_rule :: acc )
      [] rules
  in

  List.rev base_rules
