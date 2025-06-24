open Ecma_sl_symbolic

let ( let* ) = Result.bind

let solve solver pc (ty : Symbolic_error.t) workspace =
  let open Result in
  let pcs = Exploit_patterns.apply pc ty in
  let result =
    list_map
      (fun pc ->
        let model =
          try
            match Solver.get_sat_model solver pc with
            | `Unsat | `Unknown -> None
            | `Model m -> Some m
          with exn ->
            Logs.err (fun k ->
              k "solver: %s: cannot encode desired pc" (Printexc.to_string exn) );
            None
        in
        let* pc_path, model = Sym_failure.serialize workspace pc model in
        let exploit = Sym_failure.default_exploit () in
        Ok { Sym_failure.ty; pc; pc_path; model; exploit } )
      pcs
  in
  match result with
  | Ok v -> v
  | Error (`Msg err) -> Fmt.failwith "%s" err
