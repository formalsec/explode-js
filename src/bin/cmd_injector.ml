let cmd_verify (settings : Settings.Cmd_injector.t) =
  let open Result.Syntax in
  let module Solver = Smtml.Solver.Batch (Smtml.Z3_mappings) in
  let solver = Solver.create ~logic:QF_S () in

  let+ rules = Injector.Parse.from_file settings.input_path in
  Fmt.pr "Original grammar:@.";
  List.iter (fun rule -> Fmt.pr "%a@." Injector.Rule.pp rule) rules;

  let k =
    Fmt.pr "Unfolding level:@.";
    read_line () |> String.trim |> int_of_string
  in
  let unfolded_rules = Injector.Transform.unfold rules k in
  Fmt.pr "Unfolded grammar (k = %d):@." k;
  List.iter (fun rule -> Fmt.pr "%a@." Injector.Rule.pp rule) unfolded_rules;

  let desired_rule =
    Fmt.pr "Desired rule:@.";
    read_line () |> String.trim
  in

  let candidate =
    Fmt.pr "Grammar candidate:@.";
    read_line () |> String.trim
  in

  let e =
    Injector.Smt_encoder.encode unfolded_rules desired_rule
      (Smtml.Typed.String.v candidate)
  in
  Fmt.pr "SMT Expr: %a@." Smtml.Typed.Bool.pp e;

  match Solver.check solver [ (e :> Smtml.Expr.t) ] with
  | `Sat ->
    Fmt.pr "Candiate '%s' is a valid sentence of %s@." candidate desired_rule
  | `Unsat ->
    Fmt.pr "Canidate '%s' is not a valid sentence of %s@." candidate
      desired_rule
  | `Unknown -> assert false

let cmd_complete (settings : Settings.Cmd_injector.t) =
  let open Result.Syntax in
  let module Solver = Smtml.Solver.Batch (Smtml.Z3_mappings) in
  let solver = Solver.create ~logic:QF_S () in

  let+ rules = Injector.Parse.from_file settings.input_path in
  Fmt.pr "Original grammar:@.";
  List.iter (fun rule -> Fmt.pr "%a@." Injector.Rule.pp rule) rules;

  let k =
    Fmt.pr "Unfolding level:@.";
    read_line () |> String.trim |> int_of_string
  in
  let unfolded_rules = Injector.Transform.unfold rules k in
  Fmt.pr "Unfolded grammar (k = %d):@." k;
  List.iter (fun rule -> Fmt.pr "%a@." Injector.Rule.pp rule) unfolded_rules;

  let desired_rule =
    Fmt.pr "Desired rule:@.";
    read_line () |> String.trim
  in

  let candidate_str =
    Fmt.pr "Grammar constraint (contains):@.";
    read_line () |> String.trim
  in

  let x = Smtml.Typed.symbol Smtml.Typed.Types.string "x" in
  let c = Smtml.Typed.String.(contains x ~sub:(v candidate_str)) in
  let e = Injector.Smt_encoder.encode unfolded_rules desired_rule x in
  Fmt.pr "SMT Expr: %a@." Smtml.Typed.Bool.pp e;

  match Solver.check solver [ (c :> Smtml.Expr.t); (e :> Smtml.Expr.t) ] with
  | `Sat ->
    begin match Solver.model solver with
    | None -> assert false
    | Some m ->
      Fmt.pr "Satisfying model:@;%a@." (Smtml.Model.pp ~no_values:false) m
    end
  | `Unsat ->
    Fmt.pr "It's not possile to contain '%s' in the grammar@." candidate_str
  | `Unknown -> assert false
