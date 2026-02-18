open Rule
module StringMap = Map.Make (String)
module StringSet = Set.Make (String)

type t = StringSet.t StringMap.t

let get_dependencies (rule : Rule.t) : StringSet.t =
  List.fold_left
    (fun acc case ->
      List.fold_left
        (fun acc atom ->
          match atom with
          | Non_terminal id -> StringSet.add id acc
          | Terminal _ -> acc )
        acc case )
    StringSet.empty rule.body

let build (rules : Rule.t list) : t =
  List.fold_left
    (fun acc rule -> StringMap.add rule.name (get_dependencies rule) acc)
    StringMap.empty rules

let dependencies name cg =
  StringMap.find_opt name cg |> Option.value ~default:StringSet.empty

let recursive_nonterminals cg =
  let nodes = StringMap.bindings cg |> List.map fst in
  let rec can_reach start target visited =
    if StringSet.mem start visited then false
    else
      let deps = dependencies start cg in
      if StringSet.mem target deps then true
      else
        StringSet.exists
          (fun next -> can_reach next target (StringSet.add start visited))
          deps
  in
  List.filter (fun node -> can_reach node node StringSet.empty) nodes
  |> StringSet.of_list
