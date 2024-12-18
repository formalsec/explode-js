open Format
open Vuln_intf

let template0 : ('a, Format.formatter, unit) format =
  "var esl_symbolic = require(\"esl_symbolic\");@\n\
   // Vuln: %a@\n\
   %a"

let template1 : ('a, Format.formatter, unit) format =
  "var esl_symbolic = require(\"esl_symbolic\");@\n\
   // Vuln: %a@\n\
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

let array_iter x f arr = List.iteri (fun i v -> f (x ^ string_of_int i, v)) arr

let rec pp_param (box : ('a, formatter, unit) format) fmt
  ((x, ty) : string * param_type) =
  let rec pp_p fmt (x, ty) =
    match ty with
    | Any -> Fmt.pf fmt {|esl_symbolic.any("%s")|} x
    | Number -> Fmt.pf fmt {|esl_symbolic.number("%s")|} x
    | String -> Fmt.pf fmt {|esl_symbolic.string("%s")|} x
    | Boolean -> Fmt.pf fmt {|esl_symbolic.boolean("%s")|} x
    | Function -> Fmt.pf fmt {|esl_symbolic.function("%s")|} x
    | Object `Lazy -> Fmt.pf fmt "esl_symbolic.lazy_object()"
    | Object (`Polluted n) -> Fmt.pf fmt "esl_symbolic.polluted_object(%d)" n
    | Object (`Normal props) -> Fmt.pf fmt "@[{ %a@ }@]" pp_obj_props props
    | Array arr ->
      Fmt.pf fmt "@[<hov 2>[ %a ]@]"
        (Fmt.iter ~sep:Fmt.comma (array_iter x) pp_p)
        arr
    | Union _ -> assert false
  in
  Fmt.pf fmt box x pp_p (x, ty)

and pp_obj_props fmt props =
  pp_print_list
    ~pp_sep:(fun fmt () -> Fmt.pf fmt "@\n, ")
    (pp_param "@[<hov 2>%s:@ %a@]")
    fmt props

and pp_params_as_decl fmt (params : (string * param_type) list) =
  pp_print_list
    ~pp_sep:(fun fmt () -> Fmt.pf fmt ";@\n")
    (pp_param "@[<hov 2>var %s =@ %a@]")
    fmt params

let pp_params_as_args fmt (args : (string * 'a) list) =
  let args = List.map fst args in
  pp_print_list
    ~pp_sep:(fun fmt () -> pp_print_string fmt ", ")
    pp_print_string fmt args

let normalize = String.map (fun c -> match c with '.' | ' ' -> '_' | _ -> c)

let ( let* ) v f = Option.bind v f

let pp fmt (v : t) =
  let rec pp_aux fmt { source; params; cont; _ } =
    if List.length params > 0 then Fmt.pf fmt "%a;@\n" pp_params_as_decl params;
    match (cont, source) with
    | None, Some "" -> ()
    | None, Some source -> Fmt.pf fmt "%s(%a);" source pp_params_as_args params
    | Some (Return ret), Some source ->
      let var_aux = "ret_" ^ normalize source in
      Fmt.pf fmt "var %s = %s(%a);@\n" var_aux source pp_params_as_args params;
      let source =
        let* ret_source = ret.source in
        Some (var_aux ^ ret_source)
      in
      pp_aux fmt { ret with source }
    | Some (Sequence cont), Some source ->
      Fmt.pf fmt "%s(%a);@\n" source pp_params_as_args params;
      pp_aux fmt cont
    | _, None -> assert false
  in
  let template = get_template v.ty in
  Fmt.pf fmt template (Fmt.option Vuln_type.pp) v.ty pp_aux v
