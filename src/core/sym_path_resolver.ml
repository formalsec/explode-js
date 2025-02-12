open Ecma_sl_symbolic
module Thread = Choice_monad.Thread
module Solver = Solver

let ( let* ) = Result.bind

let solve (ty : Symbolic_error.t) workspace thread =
  let pc = Smtml.Expr.Set.to_list @@ Thread.pc thread in
  let solver = Thread.solver thread in
  let pcs = Exploit_patterns.apply pc ty in
  let result =
    Result.list_map pcs ~f:(fun pc ->
      let model =
        match Solver.check solver pc with
        | `Unsat | `Unknown -> None
        | `Sat -> Solver.model solver
      in
      let* pc_path, model = Sym_failure.serialize workspace pc model in
      let exploit = Sym_failure.default_exploit () in
      Ok { Sym_failure.ty; pc; pc_path; model; exploit } )
  in
  match result with Ok v -> v | Error (`Msg err) -> Fmt.failwith "%s" err
