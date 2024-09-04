open Format
open Vuln_intf

let template0 : ('a, Format.formatter, unit) format =
  "let esl_symbolic = require(\"esl_symbolic\");@\n\
   esl_symbolic.sealProperties(Object.prototype);@\n\
   // Vuln: %a@\n\
   %a"

let template1 : ('a, Format.formatter, unit) format =
  "let esl_symbolic = require(\"esl_symbolic\");@\n\
   // Vuln: %a@\n\
   %a@\n\
   if (({}).toString == \"polluted\") { throw Error(\"I pollute.\"); }"

let get_template = function
  | Some (Cmd_injection | Code_injection | Path_traversal) -> template0
  | Some Proto_pollution | None -> template1

let fresh_str =
  let id = ref 0 in
  fun () ->
    incr id;
    Format.sprintf "x_%d" !id

let pp_vuln_type fmt = function
  | Some Cmd_injection -> fprintf fmt "command-injection"
  | Some Code_injection -> fprintf fmt "code-injection"
  | Some Path_traversal -> fprintf fmt "path-traversal"
  | Some Proto_pollution -> fprintf fmt "prototype-pollution"
  | None -> ()

let array_iter x f arr = List.iteri (fun i v -> f (x ^ string_of_int i, v)) arr

let pp_iter ~pp_sep iter pp_v fmt v =
  let is_first = ref true in
  let pp_v v =
    if !is_first then is_first := false else pp_sep fmt ();
    pp_v fmt v
  in
  iter pp_v v

let pp_array (iter : ('a -> unit) -> 'b -> unit) pp_v fmt v =
  pp_iter ~pp_sep:(fun fmt () -> pp_print_string fmt ", ") iter pp_v fmt v

let rec pp_param (box : ('a, formatter, unit) format) fmt
  ((x, ty) : string * param_type) =
  let rec pp_p fmt (x, ty) =
    match ty with
    | Any -> fprintf fmt {|esl_symbolic.any("%s")|} x
    | Number -> fprintf fmt {|esl_symbolic.number("%s")|} x
    | String -> fprintf fmt {|esl_symbolic.string("%s")|} x
    | Boolean -> fprintf fmt {|esl_symbolic.boolean("%s")|} x
    | Function -> fprintf fmt {|esl_symbolic.function("%s")|} x
    | Object `Lazy -> fprintf fmt "esl_symbolic.lazy_object()"
    | Object (`Polluted n) -> fprintf fmt "esl_symbolic.polluted_object(%d)" n
    | Object (`Normal props) -> fprintf fmt "@[{ %a@ }@]" pp_obj_props props
    | Array arr -> fprintf fmt "[ %a ]" (pp_array (array_iter x) pp_p) arr
    | Union _ -> assert false
  in
  fprintf fmt box x pp_p (x, ty)

and pp_obj_props fmt props =
  pp_print_list
    ~pp_sep:(fun fmt () -> fprintf fmt "@\n, ")
    (pp_param "@[<hov 2>%s:@ %a@]")
    fmt props

and pp_params_as_decl fmt (params : (string * param_type) list) =
  pp_print_list
    ~pp_sep:(fun fmt () -> fprintf fmt ";@\n")
    (pp_param "@[<hov 2>let %s =@ %a@]")
    fmt params

let pp_params_as_args fmt (args : (string * 'a) list) =
  let args = List.map fst args in
  pp_print_list
    ~pp_sep:(fun fmt () -> pp_print_string fmt ", ")
    pp_print_string fmt args

let normalize = String.map (fun c -> match c with '.' | ' ' -> '_' | _ -> c)
let ( let* ) v f = Option.bind v f

let pp fmt (v : vuln_conf) =
  let rec pp_aux fmt { source; params; cont; _ } =
    if List.length params > 0 then fprintf fmt "%a;@\n" pp_params_as_decl params;
    match (cont, source) with
    | None, Some source -> fprintf fmt "%s(%a);" source pp_params_as_args params
    | Some (Return ret), Some source ->
      let var_aux = "ret_" ^ normalize source in
      fprintf fmt "var %s = %s(%a);@\n" var_aux source pp_params_as_args params;
      let source =
        let* ret_source = ret.source in
        Some (var_aux ^ ret_source)
      in
      pp_aux fmt { ret with source }
    | Some (Sequence cont), Some source ->
      fprintf fmt "%s(%a);@\n" source pp_params_as_args params;
      pp_aux fmt cont
    | _, None -> assert false
  in
  let template = get_template v.ty in
  fprintf fmt template pp_vuln_type v.ty pp_aux v
