let run (settings : Settings.Cmd_complete.t) =
  let open Result.Syntax in
  let+ rules = Injector.Parse.from_file settings.input_path in
  Fmt.pr "Original grammar:@.";
  List.iter (fun rule -> Fmt.pr "%a@." Injector.Rule.pp rule) rules;

  let unfolded_rules = Injector.Transform.unfold rules 2 in
  Fmt.pr "Unfolded grammar (k = 2):@.";
  List.iter (fun rule -> Fmt.pr "%a@." Injector.Rule.pp rule) unfolded_rules;
