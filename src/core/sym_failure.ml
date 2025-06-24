open Ecma_sl_symbolic

let ( let* ) = Result.bind

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

type exploit =
  { mutable success : bool
  ; mutable effect_ : Replay_effect.t option
  }

let default_exploit () = { success = false; effect_ = None }

let exploit_to_json { success; effect_ } =
  `Assoc
    [ ("success", `Bool success)
    ; ( "effect"
      , match effect_ with
        | None -> `Null
        | Some e -> `String (Fmt.str "%a" Replay_effect.pp e) )
    ]

type t =
  { ty : Symbolic_error.t
  ; pc : Smtml.Expr.Set.t
  ; pc_path : Fpath.t
  ; model : model option
  ; exploit : exploit
  }

let pp fmt { ty; pc; model; _ } =
  Fmt.pf fmt "@[<hov 1>((type %a)@;(pc %a)@;(model %a))@]" Symbolic_error.pp ty
    (Smtml.Expr.Set.pretty Smtml.Expr.pp)
    pc (Fmt.option pp_model) model

let to_json { ty; pc; pc_path; model; exploit } =
  let ty = Symbolic_error.to_json ty in
  let remaining =
    `Assoc
      [ ("pc", `String (Fmt.str "%a" (Smtml.Expr.Set.pretty Smtml.Expr.pp) pc))
      ; ("pc_path", `String (Fpath.to_string pc_path))
      ; ( "model"
        , match model with None -> `Null | Some model -> model_to_json model )
      ; ("exploit", exploit_to_json exploit)
      ]
  in
  match (ty, remaining) with
  | `Assoc a, `Assoc b -> `Assoc (a @ b)
  | _ -> assert false

let serialize =
  let mode = 0o666 in
  let next_int, _ = Ecma_sl.Base.make_counter 0 1 in
  fun workspace pc model ->
    let f = Fmt.kstr Fpath.(add_seg workspace) "witness-%d" (next_int ()) in
    let pp_model fmt v =
      Yojson.pretty_print ~std:true fmt (Smtml.Model.to_json v)
    in
    let* model =
      match model with
      | None -> Ok None
      | Some m ->
        let model_path = Fpath.(f + ".json") in
        let* () = Bos.OS.File.writef ~mode model_path "%a" pp_model m in
        Ok (Some { data = m; path = model_path })
    in
    let pc_path = Fpath.(f + ".smtml") in
    let* () =
      Bos.OS.File.writef ~mode pc_path "%a"
        (Smtml.Expr.Set.pretty Smtml.Expr.pp)
        pc
    in
    Ok (pc_path, model)
