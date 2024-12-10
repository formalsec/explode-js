type t =
  { filename : Fpath.t
  ; exec_time : float
  ; solv_time : float
  ; solv_cnt : int
  ; failures : Sym_failure.t list
  }

let pp fmt { filename; exec_time; solv_time; solv_cnt; failures } =
  Fmt.pf fmt
    "@[<hov 1>(sym_result@;\
     (filename %a)@;\
     (execution_time %a)@;\
     (solver_time %a)@;\
     (solver_queries %a)@;\
     (failures@;\
     %a)@;\
     )@]"
    Fpath.pp filename Fmt.float exec_time Fmt.float solv_time Fmt.int solv_cnt
    (Fmt.list Sym_failure.pp) failures

let to_json { filename; exec_time; solv_time; solv_cnt; failures } =
  `Assoc
    [ ("filename", `String (Fpath.to_string filename))
    ; ("execution_time", `Float exec_time)
    ; ("solver_time", `Float solv_time)
    ; ("solver_queries", `Int solv_cnt)
    ; ("num_failures", `Int (List.length failures))
    ; ("failures", `List (List.map Sym_failure.to_json failures))
    ]
