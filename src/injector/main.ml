module Settings = struct
  type t = { input_path : Path.t [@main] } [@@deriving make, show]
end

let cmd_verify (settings : Settings.t) =
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

let cmd_complete (settings : Settings.t) =
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

let cmds =
  let open Cmdliner in
  let fpath = Arg.conv (Path.of_string, Path.pp) in

  let input_path =
    let docv = "PATH" in
    let doc = "Path to the input file. Can be a directory." in
    Arg.(required & pos 0 (some fpath) None & info [] ~doc ~docv)
  in

  let cmd_verify =
    let info =
      let doc = "Experimental payload verification engine" in
      let description =
        "This command is still experimental and intentionally not documented. \
         Use at your own risk!"
      in
      let man = [ `S Manpage.s_description; `P description ] in
      let man_xrefs = [] in
      Cmd.info "verify" ~doc ~man ~man_xrefs
    in
    let command =
      let open Term.Syntax in
      let+ input_path in
      let settings = Settings.make input_path in
      cmd_verify settings
    in
    Cmd.v info command
  in

  let cmd_complete =
    let info =
      let doc = "Experimental payload completion engine" in
      let description =
        "This command is still experimental and intentionally not documented. \
         Use at your own risk!"
      in
      let man = [ `S Manpage.s_description; `P description ] in
      let man_xrefs = [] in
      Cmd.info "complete" ~doc ~man ~man_xrefs
    in
    let command =
      let open Term.Syntax in
      let+ input_path in
      let settings = Settings.make input_path in
      cmd_complete settings
    in
    Cmd.v info command
  in

  let info =
    let doc = "Experimental injector backend" in
    let description =
      [ `P
          "This command is still experimental and intentionally not \
           documented. Use at your own risk!"
      ]
    in
    let man = `S Manpage.s_description :: description in
    let man_xrefs = [] in
    Cmd.info ~doc ~man ~man_xrefs "injector"
  in
  Cmd.group info [ cmd_verify; cmd_complete ]

let returncode =
  let open Cmdliner in
  match Cmd.eval_value cmds with
  | Ok (`Version | `Help) -> Cmd.Exit.ok
  | Ok (`Ok result) ->
    begin match result with
    | Ok () -> Cmd.Exit.ok
    | Error (`Msg str) ->
      Logs.err (fun m -> m "%s" str);
      1
    end
  | Error e ->
    begin match e with
    | `Term -> Cmd.Exit.some_error
    | `Parse -> Cmd.Exit.cli_error
    | `Exn -> Cmd.Exit.internal_error
    end

let () = exit returncode
