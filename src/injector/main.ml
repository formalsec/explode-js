module Settings = struct
  type t =
    { input_path : Fpath.t [@main]
    ; solver_type : Smtml.Solver_type.t [@default Smtml.Solver_type.Z3_solver]
    }
  [@@deriving make, show]
end

let cmd_verify (settings : Settings.t) =
  let open Result.Syntax in
  let module Mappings =
    (val Smtml.Solver_dispatcher.mappings_of_solver settings.solver_type)
  in
  let module Solver = Smtml.Solver.Batch (Mappings) in
  let solver = Solver.create ~logic:QF_S () in

  let+ rules = Injector.Parse.from_file settings.input_path in
  Logs.app (fun k ->
    k "Original grammar:@;%a" (Fmt.list ~sep:Fmt.cut Injector.Rule.pp) rules );

  let depth =
    Logs.app (fun k -> k "Unfolding level:");
    read_line () |> String.trim |> int_of_string
  in
  let unfolded_rules = Injector.Transform.unfold rules depth in
  Logs.app (fun k ->
    k "Unfolded grammar (depth = %d):@;%a" depth
      (Fmt.list ~sep:Fmt.cut Injector.Rule.pp)
      unfolded_rules );

  let desired_rule =
    Logs.app (fun k -> k "Desired rule:");
    read_line () |> String.trim
  in

  let candidate =
    Logs.app (fun k -> k "Grammar candidate:");
    read_line () |> String.trim
  in

  let e =
    Injector.Smt_encoder.encode unfolded_rules desired_rule
      (Smtml.Typed.String.v candidate)
  in
  Logs.app (fun k -> k "SMT Expr: %a" Smtml.Typed.Bool.pp e);

  match Solver.check solver [ (e :> Smtml.Expr.t) ] with
  | `Sat ->
    Logs.app (fun k ->
      k "Candiate '%s' is a valid sentence of %s" candidate desired_rule )
  | `Unsat ->
    Logs.app (fun k ->
      k "Canidate '%s' is not a valid sentence of %s" candidate desired_rule )
  | `Unknown -> assert false

let cmd_complete (settings : Settings.t) =
  let open Result.Syntax in
  let module Mappings =
    (val Smtml.Solver_dispatcher.mappings_of_solver settings.solver_type)
  in
  let module Solver = Smtml.Solver.Batch (Mappings) in
  let solver = Solver.create ~logic:QF_S () in

  let+ rules = Injector.Parse.from_file settings.input_path in
  Logs.app (fun k ->
    k "Original grammar:@;%a" (Fmt.list ~sep:Fmt.cut Injector.Rule.pp) rules );

  let depth =
    Logs.app (fun k -> k "Unfolding level:");
    read_line () |> String.trim |> int_of_string
  in
  let unfolded_rules = Injector.Transform.unfold rules depth in
  Logs.app (fun k ->
    k "Unfolded grammar (depth = %d):@;%a" depth
      (Fmt.list ~sep:Fmt.cut Injector.Rule.pp)
      unfolded_rules );

  let desired_rule =
    Logs.app (fun k -> k "Desired rule:");
    read_line () |> String.trim
  in

  let candidate_str =
    Logs.app (fun k -> k "Grammar constraint (contains):");
    read_line () |> String.trim
  in

  let x = Smtml.Typed.symbol Smtml.Typed.Types.string "x" in
  let c = Smtml.Typed.String.(contains x ~sub:(v candidate_str)) in
  let e = Injector.Smt_encoder.encode unfolded_rules desired_rule x in
  Logs.app (fun k -> k "SMT Expr: %a" Smtml.Typed.Bool.pp e);

  match Solver.check solver [ (c :> Smtml.Expr.t); (e :> Smtml.Expr.t) ] with
  | `Sat ->
    begin match Solver.model solver with
    | None -> assert false
    | Some m ->
      Logs.app (fun k ->
        k "Satisfying model:@;%a@." (Smtml.Model.pp ~no_values:false) m )
    end
  | `Unsat ->
    Logs.app (fun k ->
      k "It's not possile to contain '%s' in the grammar" candidate_str )
  | `Unknown -> assert false

let cmd_generate (settings : Settings.t) =
  let open Result.Syntax in
  let module Mappings =
    (val Smtml.Solver_dispatcher.mappings_of_solver settings.solver_type)
  in
  let module Solver = Smtml.Solver.Batch (Mappings) in
  let solver = Solver.create ~logic:QF_S () in

  let+ rules = Injector.Parse.from_file settings.input_path in
  Logs.app (fun k ->
    k "Original grammar:@;%a" (Fmt.list ~sep:Fmt.cut Injector.Rule.pp) rules );

  let depth =
    Logs.app (fun k -> k "Unfolding level:");
    read_line () |> String.trim |> int_of_string
  in
  let unfolded_rules = Injector.Transform.unfold rules depth in
  Logs.app (fun k ->
    k "Unfolded grammar (depth = %d):@;%a" depth
      (Fmt.list ~sep:Fmt.cut Injector.Rule.pp)
      unfolded_rules );

  let desired_rule =
    Logs.app (fun k -> k "Desired rule:");
    read_line () |> String.trim
  in

  let test_cases =
    Logs.app (fun k -> k "Number of cases:");
    read_line () |> String.trim |> int_of_string
  in

  let x = Smtml.Typed.symbol Smtml.Typed.Types.string "x" in
  let e = Injector.Smt_encoder.encode unfolded_rules desired_rule x in
  Logs.app (fun k -> k "SMT Expr: %a" Smtml.Typed.Bool.pp e);

  let rec loop remaining =
    if remaining = 0 then ()
    else
      match Solver.check solver [] with
      | `Sat ->
        begin match Solver.model solver with
        | None -> assert false
        | Some m ->
          Logs.app (fun k ->
            k "Satisfying model:@;%a" (Smtml.Model.pp ~no_values:false) m );
          let v =
            Smtml.Model.evaluate m (Smtml.Symbol.make Ty_str "x")
            |> Option.get |> Smtml.Expr.value |> Smtml.Typed.Unsafe.wrap
          in
          Solver.add solver
            [ (Smtml.Typed.Bool.(not (eq x v)) :> Smtml.Expr.t) ];
          loop (remaining - 1)
        end
      | `Unsat -> Logs.app (fun k -> k "Grammar is not satisfiable")
      | `Unknown -> assert false
  in
  Solver.add solver [ (e :> Smtml.Expr.t) ];
  loop test_cases

type injection_config =
  { name : string
  ; grammar : string
  ; attack : string
  ; target_rule : string
  }

let parse_injection_type path =
  let open Result.Syntax in
  let* json =
    try Ok (Yojson.Safe.from_file (Fpath.to_string path))
    with exn ->
      Fmt.error_msg "Failed to parse metadata.json: %s" (Printexc.to_string exn)
  in
  let open Yojson.Safe.Util in
  match json |> member "error" |> member "type" |> to_string_option with
  | Some typ -> Ok typ
  | None -> Fmt.error_msg "Could not find error.type in metadata.json"

let config_of_type = function
  | "code-injection" ->
    Ok
      { name = "code-injection"
      ; grammar = Injector_grammars.Code.raw
      ; attack = "attack()"
      ; target_rule = "start"
      }
  | "command-injection" ->
    Ok
      { name = "command-injection"
      ; grammar = Injector_grammars.Command.raw
      ; attack = "; id"
      ; target_rule = "start"
      }
  | "sql-injection" ->
    Ok
      { name = "sql-injection"
      ; grammar = Injector_grammars.Sql.raw
      ; attack = "' OR '1'='1"
      ; target_rule = "start"
      }
  | s -> Fmt.error_msg "Unknown injection type: '%s'" s

let write_result path json =
  let str = Yojson.Safe.pretty_to_string ~std:true json in
  try
    Out_channel.with_open_text (Fpath.to_string path) @@ fun oc ->
    output_string oc str;
    output_string oc "\n"
  with exn ->
    Logs.err (fun k ->
      k "Failed to write result to %a: %s" Fpath.pp path
        (Printexc.to_string exn) )

let cmd_run (settings : Settings.t) =
  let open Smtml in
  let open Result.Syntax in
  let module Mappings =
    (val Solver_dispatcher.mappings_of_solver settings.solver_type)
  in
  let module Solver = Solver.Incremental (Mappings) in
  let meta_path = Fpath.(settings.input_path / "metadata.json") in
  let result_path = Fpath.(settings.input_path / "injector-result.json") in

  match parse_injection_type meta_path with
  | Error (`Msg msg) as err ->
    write_result result_path
      (`Assoc [ ("status", `String "error"); ("message", `String msg) ]);
    err
  | Ok inj_type ->
    begin match config_of_type inj_type with
    | Error (`Msg msg) as err ->
      write_result result_path
        (`Assoc [ ("status", `String "error"); ("message", `String msg) ]);
      err
    | Ok config ->
      Logs.app (fun k -> k "Injection type: %s" config.name);
      Logs.app (fun k -> k "Attack payload: %S" config.attack);

      let rules = Injector.Parse.from_string config.grammar in
      Logs.app (fun k -> k "Parsed grammar (%d rules)" (List.length rules));

      let expr_path = Fpath.(settings.input_path / "expr.smtml") in
      let pc_path = Fpath.(settings.input_path / "pc.smtml") in

      let* expr_expr =
        Parse.Smtml.Expr.from_file expr_path
        |> Result.map_error @@ fun (`Msg msg) ->
           Logs.err (fun k -> k "Error parsing %a: %s" Fpath.pp expr_path msg);
           write_result result_path
             (`Assoc
                [ ("status", `String "error")
                ; ("message", `String ("parse expr.smtml: " ^ msg))
                ] );
           `Msg "Failed to parse expr.smtml"
      in
      (* Coerce into a string term *)
      let expr_expr : Typed.String.t = Typed.Unsafe.wrap expr_expr in
      let* pc_script =
        Parse.Smtml.Script.from_file pc_path
        |> Result.map_error @@ fun (`Msg msg) ->
           Logs.err (fun k -> k "Error parsing %a: %s" Fpath.pp pc_path msg);
           write_result result_path
             (`Assoc
                [ ("status", `String "error")
                ; ("message", `String ("parse pc.smtml: " ^ msg))
                ] );
           `Msg "Failed to parse pc.smtml"
      in

      Logs.app (fun k -> k "Expression:@;%a" Typed.String.pp expr_expr);

      let pc_asserts =
        List.filter_map
          (function
            | Smtml.Ast.Assert e -> Some e
            | _ -> None )
          pc_script
      in
      let len_pc = List.length pc_asserts in
      Logs.app (fun k -> k "Path constraints: %d assertions" len_pc);
      if len_pc > 0 then
        Logs.app (fun k -> k "  %a" (Fmt.list ~sep:Fmt.cut Expr.pp) pc_asserts);

      let attack = Typed.String.v config.attack in
      let contains = Typed.String.contains expr_expr ~sub:attack in

      let rec search depth =
        if depth > 3 then (
          Logs.app (fun k ->
            k "Result: UNSAT -- Injection is NOT possible (tried depth 1-3)." );
          write_result result_path (`Assoc [ ("status", `String "unsat") ]);
          Ok () )
        else
          let unfolded = Injector.Transform.unfold rules depth in
          let grammar_c =
            Injector.Smt_encoder.encode unfolded config.target_rule expr_expr
          in
          let solver = Solver.create () in
          Solver.add solver
            ((grammar_c :> Expr.t) :: (contains :> Expr.t) :: pc_asserts);
          Logs.app (fun k -> k "Trying depth %d..." depth);
          match Solver.check solver [] with
          | `Sat ->
            Logs.app (fun k ->
              k "Result: SAT at depth %d -- Injection IS possible!" depth );
            let model_json =
              match Solver.model solver with
              | None -> `Null
              | Some m -> Smtml.Model.to_json m
            in
            write_result result_path
              (`Assoc
                 [ ("status", `String "sat")
                 ; ("depth", `Int depth)
                 ; ("model", model_json)
                 ] );
            Ok ()
          | `Unsat ->
            Logs.app (fun k -> k "  Depth %d: UNSAT, trying deeper..." depth);
            search (depth + 1)
          | `Unknown ->
            Logs.app (fun k -> k "  Depth %d: UNKNOWN" depth);
            write_result result_path (`Assoc [ ("status", `String "unknown") ]);
            Ok ()
      in
      search 1
    end

let cmds =
  let open Cmdliner in
  let fpath = Arg.conv (Fpath.of_string, Fpath.pp) in

  let input_path =
    let docv = "PATH" in
    let doc = "Path to the input file. Can be a directory." in
    Arg.(required & pos 0 (some fpath) None & info [] ~doc ~docv)
  in

  let solver_type =
    let docv = "SOLVER" in
    let doc = "Name of the SMT solver to use for constraint solving" in
    Arg.(
      value
      & opt (some Smtml.Solver_type.conv) None
      & info [ "solver" ] ~doc ~docv )
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
      let+ input_path
      and+ solver_type in
      let settings = Settings.make ?solver_type input_path in
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
      let+ input_path
      and+ solver_type in
      let settings = Settings.make ?solver_type input_path in
      cmd_complete settings
    in
    Cmd.v info command
  in

  let cmd_generate =
    let info =
      let doc = "Experimental payload completion engine" in
      let description =
        "This command is still experimental and intentionally not documented. \
         Use at your own risk!"
      in
      let man = [ `S Manpage.s_description; `P description ] in
      let man_xrefs = [] in
      Cmd.info "generate" ~doc ~man ~man_xrefs
    in
    let command =
      let open Term.Syntax in
      let+ input_path
      and+ solver_type in
      let settings = Settings.make ?solver_type input_path in
      cmd_generate settings
    in
    Cmd.v info command
  in

  let cmd_run =
    let info =
      let doc = "Experimental payload completion engine" in
      let description =
        "This command is still experimental and intentionally not documented. \
         Use at your own risk!"
      in
      let man = [ `S Manpage.s_description; `P description ] in
      let man_xrefs = [] in
      Cmd.info "run" ~doc ~man ~man_xrefs
    in
    let command =
      let open Term.Syntax in
      let+ input_path
      and+ solver_type in
      let settings = Settings.make ?solver_type input_path in
      cmd_run settings
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
  Cmd.group info [ cmd_verify; cmd_complete; cmd_generate; cmd_run ]

let init () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Debug)

let returncode =
  let open Cmdliner in
  init ();
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
