open Ecma_sl_symbolic
module Json_util = Yojson.Basic.Util

type model =
  { data : Smtml.Model.t
  ; path : Fpath.t
  }

let model_to_json { data; path } =
  `Assoc
    [ ("data", Smtml.Model.to_json data)
    ; ("path", `String (Fpath.to_string path))
    ]

let pp_model fmt { data; _ } = Smtml.Model.pp ~no_values:false fmt data

type t =
  { ty : Symbolic_error.t
  ; pc : Smtml.Expr.Set.t
  ; pc_path : Fpath.t
  ; model : model option
  }
[@@deriving make]

let pp fmt { ty; pc; model; _ } =
  Fmt.pf fmt "@[<hov 1>((type %a)@;(pc %a)@;(model %a))@]" Symbolic_error.pp ty
    Smtml.Expr.Set.pp pc (Fmt.option pp_model) model

let to_json { ty; pc; pc_path; model } =
  let ty = Symbolic_error.to_json ty in
  let remaining =
    `Assoc
      [ ("pc", `String (Fmt.str "%a" Smtml.Expr.Set.pp pc))
      ; ("pc_path", `String (Fpath.to_string pc_path))
      ; ( "model"
        , match model with
          | None -> `Null
          | Some model -> model_to_json model )
      ]
  in
  match (ty, remaining) with
  | `Assoc a, `Assoc b -> `Assoc (a @ b)
  | _ -> assert false

let make_witness_writer =
  let open Result.Syntax in
  let mode = 0o666 in

  let pp_model fmt v =
    Yojson.pretty_print ~std:true fmt (Smtml.Model.to_json v)
  in

  let write_model file model =
    match model with
    | None -> Ok None
    | Some m ->
      let model_path = Fpath.(file + ".json") in
      let* () = Bos.OS.File.writef ~mode model_path "%a" pp_model m in
      Ok (Some { data = m; path = model_path })
  in

  fun () ->
    let next_int, _ = Ecma_sl.Base.make_counter 0 1 in

    fun workspace pc model ->
      let base_name = Fmt.str "witness-%d" (next_int ()) in
      let base_path = Path.(workspace / base_name) in
      let* model = write_model base_path model in
      let pc_path = Path.(base_path + ".smtml") in
      let+ () = Bos.OS.File.writef ~mode pc_path "%a" Smtml.Expr.Set.pp pc in
      (pc_path, model)
