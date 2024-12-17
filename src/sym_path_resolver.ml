module PC = Ecma_sl.Choice_monad.PC
module Thread = Ecma_sl.Choice_monad.Thread
module Solver = Ecma_sl.Solver

let ( let* ) = Result.bind

let solve (ty : Sym_failure_type.t) workspace thread =
  let pc = PC.to_list @@ Thread.pc thread in
  let solver = Thread.solver thread in
  let pcs = Exploit_patterns.apply pc ty in
  Result.list_map pcs ~f:(fun pc ->
    let model =
      match Solver.check solver pc with
      | `Unsat | `Unknown -> None
      | `Sat -> Solver.model solver
    in
    let* pc_path, model = Sym_failure.serialize workspace pc model in
    let exploit = Sym_failure.default_exploit () in
    Ok { Sym_failure.ty; pc; pc_path; model; exploit } )
