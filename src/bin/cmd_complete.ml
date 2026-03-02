let run (settings : Settings.Cmd_complete.t) =
  let open Result.Syntax in
  let+ rules = Injector.Parse.from_file settings.input_path in
  Fmt.pr "Original grammar:@.";
  List.iter (fun rule -> Fmt.pr "%a@." Injector.Rule.pp rule) rules;

  let k = 3 in
  let unfolded_rules = Injector.Transform.unfold rules k in
  Fmt.pr "Unfolded grammar (k = %d):@." k;
  List.iter (fun rule -> Fmt.pr "%a@." Injector.Rule.pp rule) unfolded_rules;
  let e = Injector.Smt_encoder.encode unfolded_rules "A_3" (Smtml.Typed.String.v "cba") in
  Fmt.pr "SMT Expr: %a@." Smtml.Typed.Bool.pp e
