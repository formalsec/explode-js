open Scheme

let template0 : ('a, Format.formatter, unit) format = "// Vuln: %a@\n%a"

let template1 : ('a, Format.formatter, unit) format =
  "// Vuln: %a@\n\
   %a@\n\
   if (({}).toString == \"polluted\") { throw Error(\"I pollute.\"); }"

let get_template = function
  | Some (Vuln_type.Cmd_injection | Code_injection | Path_traversal) ->
    template0
  | Some Proto_pollution | None -> template1

let fresh_str =
  let id = ref 0 in
  fun () ->
    incr id;
    Fmt.str "x_%d" !id

let array_iter x f arr = List.iteri (fun i v -> f (Fmt.str "%s%d" x i, v)) arr

let pp_array (iter : ('a -> unit) -> 'b -> unit) pp_v fmt v =
  Fmt.iter ~sep:(fun fmt () -> Fmt.string fmt ", ") iter pp_v fmt v

let rec pp_param model (box : ('a, Format.formatter, unit) format) fmt
  ((x, ty) : string * param_type) =
  let rec pp_p fmt (x, ty) =
    match ty with
    | Any | Number | String | Boolean ->
      let v = Model.get model x in
      Fmt.pf fmt "%a" Value.pp v
    | Function -> Fmt.pf fmt {|(_) => { return () => {}; };|}
    | Object `Lazy -> Fmt.pf fmt "{}"
    | Object (`Polluted 2) ->
      Fmt.pf fmt {|{ ["__proto__"]: { "toString": "polluted" } }|}
    | Object (`Polluted 3) ->
      Fmt.pf fmt
        {|{ "constructor": { "prototype": { "toString": "polluted" } } }|}
    | Object (`Normal props) ->
      Fmt.pf fmt "@[{ %a@ }@]" (pp_obj_props model) props
    | Array arr -> Fmt.pf fmt "[ %a ]" (pp_array (array_iter x) pp_p) arr
    | Union _ | Object (`Polluted _) -> assert false
  in
  Fmt.pf fmt box x pp_p (x, ty)

and pp_obj_props map fmt props =
  Fmt.list
    ~sep:(fun fmt () -> Fmt.pf fmt "@\n, ")
    (pp_param map "@[<hov 2>%s:@ %a@]")
    fmt props

and pp_params_as_decl map fmt (params : (string * param_type) list) =
  Fmt.list
    ~sep:(fun fmt () -> Fmt.pf fmt ";@\n")
    (pp_param map "@[<hov 2>var %s =@ %a@]")
    fmt params

let pp_params_as_args fmt (args : (string * 'a) list) =
  let args = List.map fst args in
  Fmt.list ~sep:(fun fmt () -> Fmt.string fmt ", ") Fmt.string fmt args

let normalize = String.map (fun c -> match c with '.' | ' ' -> '_' | _ -> c)

let ( let* ) v f = Option.bind v f

let pp map fmt (v : t) =
  let rec pp_aux fmt { source; params; cont; _ } =
    if List.length params > 0 then
      Fmt.pf fmt "%a;@\n" (pp_params_as_decl map) params;
    match (cont, source) with
    | None, Some source -> Fmt.pf fmt "%s(%a);" source pp_params_as_args params
    | Some (Return ret), Some source ->
      let var_aux = Fmt.str "ret_%s" (normalize source) in
      Fmt.pf fmt "var %s = %s(%a);@\n" var_aux source pp_params_as_args params;
      let source =
        let* ret_source = ret.source in
        Some (String.cat var_aux ret_source)
      in
      pp_aux fmt { ret with source }
    | Some (Sequence cont), Some source ->
      Fmt.pf fmt "%s(%a);@\n" source pp_params_as_args params;
      pp_aux fmt cont
    | _, None -> assert false
  in
  let template = get_template v.ty in
  Fmt.pf fmt template (Fmt.option Vuln_type.pp) v.ty pp_aux v
