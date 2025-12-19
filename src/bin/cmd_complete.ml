let run (settings : Settings.Cmd_complete.t) =
  let open Result.Syntax in
  let input_path = settings.input_path in
  Logs.app (fun k -> k "Parsing: %a" Path.pp input_path);
  let+ rules = Injector.Parse.from_file input_path in
  Fmt.pr "@[<v 1>Parsed grammar:@;%a@]@." (Fmt.list Injector.Rule.pp) rules
