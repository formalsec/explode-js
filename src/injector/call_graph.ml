open Rule
module StringMap = Map.Make (String)
module StringSet = Set.Make (String)

type t = StringSet.t StringMap.t

let get_dependencies (rule : Rule.t) : StringSet.t =
  let rec atom_deps acc = function
    | Non_terminal id -> StringSet.add id acc
    | Terminal _ | Range _ -> acc
    | Star atom | Plus atom | Opt atom -> atom_deps acc atom
    | Group body ->
      List.fold_left
        (fun acc case -> List.fold_left atom_deps acc case)
        acc body
  in
  List.fold_left
    (fun acc case -> List.fold_left atom_deps acc case)
    StringSet.empty rule.body

let build (rules : Rule.t list) : t =
  List.fold_left
    (fun acc rule -> StringMap.add rule.name (get_dependencies rule) acc)
    StringMap.empty rules

let dependencies name cg =
  StringMap.find_opt name cg |> Option.value ~default:StringSet.empty

let can_reach cg start target =
  let rec loop start target visited =
    if StringSet.mem start visited then false
    else
      let deps = dependencies start cg in
      if StringSet.mem target deps then true
      else
        StringSet.exists
          (fun next -> loop next target (StringSet.add start visited))
          deps
  in
  loop start target StringSet.empty

let recursive_nonterminals cg =
  let nodes = StringMap.bindings cg |> List.map fst in
  List.filter (fun node -> can_reach cg node node) nodes |> StringSet.of_list
