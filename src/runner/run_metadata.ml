module Cwe = Explode_js.Cwe

type t =
  { timestamp : int
  ; time_limit : int
  ; output_dir : Fpath.t
  ; filter : Cwe.t option
  ; index : Fpath.t
  }

let pp fmt { timestamp; time_limit; output_dir; filter; index } =
  Fmt.pf fmt
    "@[<hov>Run %a:@;Time limit: %a,@;Output: %a,@;Filter: %a,@;Index: %a@]"
    Fmt.int timestamp Fmt.int time_limit Fpath.pp output_dir (Fmt.option Cwe.pp)
    filter Fpath.pp index

let to_jg { timestamp; time_limit; output_dir; filter; index } =
  let open Jingoo in
  let filter = match filter with None -> "None" | Some f -> Cwe.to_string f in
  Jg_types.(
    Tobj
      [ ("timestamp", Tint timestamp)
      ; ("time_limit", Tint time_limit)
      ; ("output_dir", Tstr (Fpath.to_string output_dir))
      ; ("filter_", Tstr filter)
      ; ("index", Tstr (Fpath.to_string index))
      ] )

let prepare_db db =
  Db.exec0 db
    {|CREATE TABLE IF NOT EXISTS
      run_metadata (
        timestamp INTEGER PRIMARY KEY,
        time_limit INTEGER,
        output_dir TEXT,
        filter TEXT,
        index_ TEXT
      );
    |}
  |> Db.to_result

let to_db db { timestamp; time_limit; output_dir; filter; index } =
  let filter = match filter with None -> "None" | Some f -> Cwe.to_string f in
  Db.exec_no_cursor db "INSERT INTO run_metadata VALUES (?, ?, ?, ?, ?);"
    ~ty:Db.Ty.(p5 int int text text text)
    timestamp time_limit
    (Fpath.to_string output_dir)
    filter (Fpath.to_string index)
  |> Db.unwrap_db

let select_db db =
  Db.exec_no_params db "SELECT * FROM run_metadata;"
    ~ty:
      Db.Ty.
        ( p2 int int @>> p3 text text text
        , fun timestamp time_limit output_dir filter index ->
            let output_dir = Fpath.v output_dir in
            let filter =
              match filter with
              | "None" -> None
              | _ -> (
                match Cwe.of_string filter with
                | Ok cwe -> Some cwe
                | Error _ -> None )
            in
            let index = Fpath.v index in
            { timestamp; time_limit; output_dir; filter; index } )
    ~f:Db.Cursor.to_list_rev
  |> Db.unwrap_db
