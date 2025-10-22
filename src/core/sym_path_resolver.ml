open Ecma_sl_symbolic

let solve solver pc (ty : Symbolic_error.t) workspace =
  let open Result.Syntax in
  let witness_writer = Sym_failure.make_witness_writer () in

  let get_model_safely solver pc =
    match Solver.get_sat_model solver pc with
    | `Model m -> Some m
    | `Unsat | `Unknown -> None
    | exception exn -> begin
      Logs.err (fun k ->
        k "solver: %s: cannot encode desired pc" (Printexc.to_string exn) );
      None
    end
  in

  let process_path_condition pc =
    let model = get_model_safely solver pc in
    let+ pc_path, model = witness_writer workspace pc model in
    Sym_failure.make ~ty ~pc ~pc_path ?model ()
  in

  let pcs = Exploit_patterns.apply pc ty in
  Result.list_map process_path_condition pcs |> Result.get_ok
