open Eio.Std

(* "z3" or "cvc5" *)
let solver = "z3"

module SSet = Set.Make (String)

(* exclude packages that have harnesses but that we don't find anything *)
let excludes =
  SSet.of_list
  (* code-injection *)
  @@ [ "cryo-0.0.6"
     ; "handlebars-3.0.8"
     ; "hot-formula-parser-3.0.0"
     ; "js-deobfuscator-1.1.0"
     ; "mathjs-3.10.3"
     ; "md-to-pdf-4.1.0"
     ; "metacalc-0.0.2"
     ; "mongoosemask-0.0.6"
     ; "mosc-1.0.0"
     ; "realms-shim-1.1.0"
     ; "reduce-css-calc-1.2.4"
     ; "swig-templates-2.0.3"
     ; "value-censorship-1.1.0"
     ; "xmlhttprequest-1.6.0"
     ]
  (* command-injection *)
  @ [ "acrontum-filesystem-template-0.0.1"
    ; "apiconnect-cli-plugins-6.0.2"
    ; "chrome-launcher-0.13.1"
    ; "codecov-3.6.4"
    ; "cycle-import-check-1.3.1"
    ; "enpeem-2.2.0"
    ; "git-diff-apply-0.22.1"
    ; "git-interface-2.1.1"
    ; "giting-0.0.8"
    ; "gulp-tape-1.0.0"
    ; "gulp-styledocco-0.0.3"
    ; "keep-module-latest-1.0.1"
    ; "kill-port-process-2.1.0"
    ; "libnmap-0.4.11"
    ; "lycwed-spritesheetjs-1.2.5"
    ; "mversion-1.13.0"
    ; "node-notifier-5.4.5"
    ; "npm-git-publish-0.2.4-beta"
    ; "npm-lockfile-2.0.3"
    ; "npos-tesseract-0.0.3"
    ; "push-dir-0.4.1"
    ; "react-dev-utils-5.0.1"
    ; "ssh2-1.3.0"
    ; "standard-version-8.0.0"
    ; "strong-nginx-controller-1.0.2"
    ; "systeminformation-5.21.6"
    ; "thi.ng-egf-0.3.0"
    ]

module State = struct
  type t =
    { mutable completed : int
    ; mutable active_jobs : SSet.t
    ; total : int
    ; mutex : Eio.Mutex.t
    }

  let make total =
    { completed = 0
    ; active_jobs = SSet.empty
    ; total
    ; mutex = Eio.Mutex.create ()
    }

  let print state =
    let active = SSet.cardinal state.active_jobs in
    let active_str = String.concat ", " (SSet.to_list state.active_jobs) in
    Fmt.pr "\r\x1b[K[%a/%a/%d] Active: %s@?"
      (Fmt.styled (`Fg `Blue) Fmt.int)
      active
      (Fmt.styled (`Fg `Green) Fmt.int)
      state.completed state.total active_str

  let start_job state job =
    Eio.Mutex.use_rw state.mutex ~protect:false @@ fun () ->
    state.active_jobs <- SSet.add job state.active_jobs;
    print state

  let finish_job state job =
    Eio.Mutex.use_rw state.mutex ~protect:false @@ fun () ->
    state.completed <- state.completed + 1;
    state.active_jobs <- SSet.remove job state.active_jobs;
    print state
end

module Vuln_type = struct
  type t =
    | Code_injection
    | Command_injection
    | Sql_injection

  let equal a b =
    match (a, b) with
    | Code_injection, Code_injection
    | Command_injection, Command_injection
    | Sql_injection, Sql_injection ->
      true
    | (Code_injection | Command_injection | Sql_injection), _ -> false

  let pp fmt = function
    | Code_injection -> Fmt.pf fmt "code-injection"
    | Command_injection -> Fmt.pf fmt "command-injection"
    | Sql_injection -> Fmt.pf fmt "sql-injection"

  let of_string = function
    | "code-injection" -> Ok Code_injection
    | "command-injection" -> Ok Command_injection
    | "sql-injection" -> Ok Sql_injection
    | vuln_type -> Error (Fmt.str "unkown vuln_type: %s" vuln_type)

  let of_yojson = function
    | `String s -> of_string s
    | _ -> Error "vuln_type"

  let to_yojson ty = `String (Fmt.str "%a" pp ty)
end

module Vulnerability = struct
  type sink =
    { file : string option
    ; line : int option [@alias "lineno"]
    ; code : string option
    }
  [@@deriving yojson]

  type t =
    { type_ : Vuln_type.t [@key "type"]
    ; ghsa : string option
    ; sink : sink
    }
  [@@deriving yojson { strict = false }]

  let from_file fpath =
    let open Result.Syntax in
    let data = Eio.Path.load fpath in
    let* json =
      try Ok (Yojson.Safe.from_string data)
      with Yojson.Json_error msg -> Error msg
    in
    Yojson.Safe.Util.member "vulnerability" json |> of_yojson
end

module Tool_output = struct
  type failure =
    { type_ : string [@key "type"]
    ; sink : string
    ; line : string
    ; file : string
    }
  [@@deriving yojson { strict = false }]

  type t =
    { failures : failure list
    ; execution_time : float
    ; num_failures : int
    }
  [@@deriving yojson { strict = false }]
end

module Symb_result = struct
  type outcome =
    | Found
    | Not_found
    | Timeout
    | Error of string

  let symb_outcome_to_string = function
    | Found -> "found"
    | Not_found -> "not_found"
    | Timeout -> "timeout"
    | Error e -> "error: " ^ e

  type t =
    { outcome : outcome
    ; time : float option
    }
end

module Injector_result = struct
  type injector_model =
    { depth : int
    ; model : string
    }

  type outcome =
    | Sat of injector_model
    | Unsat
    | Timeout
    | Error of string

  type t =
    { outcome : outcome
    ; time : float option
    }
end

type job_result =
  { package : string
  ; expected : Vuln_type.t
  ; symb_result : Symb_result.t option
  ; injector_result : Injector_result.t option
  }

module Job = struct
  type t =
    { path : [ `Dir ] Eio.Path.t
    ; vuln : Vulnerability.t
    }
  [@@deriving make]
end

let quote_csv_string s =
  let escaped = String.concat {|""|} (String.split_on_char '"' s) in
  Fmt.str {|"%s"|} escaped

let parse_symbolic_json data expected =
  match Yojson.Safe.from_string data with
  | exception Yojson.Json_error msg ->
    Symb_result.Error (Fmt.str "invalid symbolic-execution.json: %s" msg)
  | json ->
    begin match Tool_output.of_yojson json with
    | Error msg -> Symb_result.Error msg
    | Ok results ->
      let found =
        List.exists
          (fun (f : Tool_output.failure) ->
            match Vuln_type.of_string f.type_ with
            | Ok t -> Vuln_type.equal t expected
            | Error _ -> false )
          results.failures
      in
      if found then Found else Not_found
    end

let run_symb ~cwd ~time_limit ~memory_limit ~clock proc_mgr expected =
  let open Eio in
  (* By default: 3 GiB virtual memory limit in KiB *)
  let _mem_limit_kb = memory_limit * 1024 * 1024 in
  let command =
    [ "ecma-sl"
    ; "symbolic"
    ; "--solver"
    ; solver
    ; "harness.js"
    ; "--workspace"
    ; "results"
    ]
  in
  match
    let start_time = Unix.gettimeofday () in
    let out_file = Eio.Path.(cwd / "ecma-sl_out.txt") in
    Path.with_open_out ~create:(`Or_truncate 0o644) out_file @@ fun out ->
    Time.with_timeout clock time_limit @@ fun () ->
    Process.run ~cwd
      ~is_success:(fun _ -> true)
      ~stderr:out ~stdout:out proc_mgr command;
    Ok (Unix.gettimeofday () -. start_time)
  with
  | Error `Timeout -> { Symb_result.outcome = Timeout; time = None }
  | Ok time ->
    let result_path = Path.(cwd / "results" / "symbolic-execution.json") in
    if Path.is_file result_path then
      let data = Path.load result_path in
      { outcome = parse_symbolic_json data expected; time = Some time }
    else
      { outcome = Error "no symbolic-execution.json produced"
      ; time = Some time
      }

let parse_injector_json json_str =
  try
    let json = Yojson.Safe.from_string json_str in
    let open Yojson.Safe.Util in
    match json |> member "status" |> to_string with
    | "sat" ->
      let depth = json |> member "depth" |> to_int in
      let model =
        match json |> member "model" with
        | `Null -> ""
        | m -> Yojson.Safe.to_string m
      in
      Injector_result.Sat { depth; model }
    | "unsat" -> Injector_result.Unsat
    | "error" ->
      let msg =
        json |> member "message" |> to_string_option |> Option.value ~default:""
      in
      Injector_result.Error msg
    | s -> Injector_result.Error ("unknown status: " ^ s)
  with exn -> Injector_result.Error (Printexc.to_string exn)

let run_injector ~cwd ~time_limit ~memory_limit ~clock proc_mgr path_dir =
  let open Eio in
  (* By default: 3 GiB virtual memory limit in KiB *)
  let mem_limit_kb = memory_limit * 1024 * 1024 in
  let command =
    [ "sh"
    ; "-c"
    ; Fmt.str "ulimit -v %d && exec injector-js run %s" mem_limit_kb
        (Filename.quote path_dir)
    ]
  in
  try
    begin match
      let start_time = Unix.gettimeofday () in
      let out_file = Path.(cwd / "injector-out.txt") in
      Path.with_open_out ~create:(`Or_truncate 0o644) out_file @@ fun out ->
      Time.with_timeout clock time_limit @@ fun () ->
      Process.run ~cwd ~stdout:out ~stderr:out proc_mgr command;
      Ok (Unix.gettimeofday () -. start_time)
    with
    | Error `Timeout -> { Injector_result.outcome = Timeout; time = None }
    | Ok time ->
      let result_path = Path.(cwd / path_dir / "injector-result.json") in
      if Path.is_file result_path then
        let data = Path.load result_path in
        { outcome = parse_injector_json (String.trim data); time = Some time }
      else
        { outcome = Error "no injector-result.json produced"; time = Some time }
    end
  with exn -> { outcome = Error (Printexc.to_string exn); time = None }

let run_injector_on_paths ~cwd ~time_limit ~memory_limit ~clock proc_mgr
  results_dir =
  let open Eio in
  let path = Path.(cwd / results_dir) in
  if not (Path.is_directory path) then []
  else
    let entries = Path.read_dir path in
    let path_dirs =
      List.filter
        (fun entry ->
          String.length entry >= 5
          && String.sub entry 0 5 = "path-"
          && Path.is_directory Path.(path / entry) )
        entries
    in
    List.map
      (fun dir ->
        let full_dir = Filename.concat results_dir dir in
        let result =
          run_injector ~cwd ~time_limit ~memory_limit ~clock proc_mgr full_dir
        in
        (dir, result) )
      path_dirs

let run time_limit memory_limit env (job : Job.t) : job_result =
  let open Eio in
  let fs = Stdenv.fs env in
  let proc_mgr = Stdenv.process_mgr env in
  let clock = Stdenv.clock env in
  let package_name = Filename.basename (Path.native_exn job.path) in

  let cwd = job.path in

  let install_package_dependencies () =
    let command = [ "npm"; "ci" ] in
    Path.with_open_out ~create:`Never Path.(fs / "/dev/null") @@ fun dev_null ->
    Time.with_timeout clock time_limit @@ fun () ->
    Process.run ~cwd ~stderr:dev_null ~stdout:dev_null proc_mgr command;
    Ok ()
  in

  let run_pipeline () =
    let open Result.Syntax in
    (* 1. Install dependencies *)
    let* () = install_package_dependencies () in

    (* 2. Run ecma-sl and parse results *)
    let symb_result =
      run_symb ~cwd ~time_limit ~memory_limit ~clock proc_mgr job.vuln.type_
    in

    (* 3. Run injector to synthesize payload *)
    let injector_result =
      match symb_result.outcome with
      | Found -> begin
        let outcomes =
          run_injector_on_paths ~cwd ~time_limit ~memory_limit ~clock proc_mgr
            "results"
        in
        let sat_outcomes =
          List.filter_map
            (fun (_dir, result) ->
              match result.Injector_result.outcome with
              | Sat _ -> Some result
              | _ -> None )
            outcomes
        in
        match sat_outcomes with
        | [] ->
          begin match outcomes with
          | [] -> None
          | _ -> Some (snd (List.hd outcomes))
          end
        | res :: _ -> Some res
        end
      | _ -> None
    in
    Ok
      { package = package_name
      ; expected = job.vuln.type_
      ; symb_result = Some symb_result
      ; injector_result
      }
  in

  match run_pipeline () with
  | Error `Timeout ->
    { package = package_name
    ; expected = job.vuln.type_
    ; symb_result = None
    ; injector_result = None
    }
  | Ok report -> report

let init () = Fmt.set_style_renderer Fmt.stdout `Ansi_tty

let main vuln_type time_limit memory_limit max_fibers env =
  init ();

  let get_jobs_from_dirs env =
    let cwd = Eio.Stdenv.cwd env in
    let packages_root = Eio.Path.(cwd / "packages") in
    let packages = Eio.Path.read_dir packages_root in
    List.filter_map
      (fun package_path ->
        let path = Eio.Path.(packages_root / package_path) in
        if SSet.mem package_path excludes || not (Eio.Path.is_directory path)
        then None
        else
          let harness = Eio.Path.(path / "harness.js") in
          let metadata = Eio.Path.(path / "package.json") in
          if not Eio.Path.(is_file harness && is_file metadata) then None
          else
            begin match Vulnerability.from_file metadata with
            | Error msg ->
              Fmt.epr "@.Unabled to parse package.json in \"%a\": %s@."
                Eio.Path.pp path msg;
              None
            | Ok vuln ->
              begin match vuln_type with
              | None -> Some (Job.make ~path ~vuln)
              | Some vuln_type ->
                if Vuln_type.equal vuln_type vuln.type_ then
                  Some (Job.make ~path ~vuln)
                else None
              end
            end )
      packages
  in

  let jobs = get_jobs_from_dirs env in
  let state = State.make (List.length jobs) in

  Switch.run @@ fun _sw ->
  Fmt.pr "Starting %d external jobs...@." state.total;

  let results =
    Fiber.List.map ~max_fibers
      (fun (job : Job.t) ->
        let filename = Filename.basename (Eio.Path.native_exn job.path) in
        State.start_job state filename;
        let result = run time_limit memory_limit env job in
        State.finish_job state filename;
        result )
      jobs
  in

  Fmt.pr "\r\x1b[KAll %d jobs completed successfully.@." state.total;

  let csv_path = "results.csv" in
  Out_channel.with_open_text csv_path @@ fun oc ->
  let oc = Format.formatter_of_out_channel oc in
  Fmt.pf oc
    "package,expected,symb_status,symb_time,injector_status,injector_time,injector_depth,injector_model\n";
  List.iter
    (fun (r : job_result) ->
      let time_to_string = Fmt.to_to_string (Fmt.option Fmt.float) in
      let symb_status, symb_time =
        match r.symb_result with
        | None -> ("", "")
        | Some { outcome; time } ->
          (Symb_result.symb_outcome_to_string outcome, time_to_string time)
      in
      let inj_status, inj_time, inj_depth, inj_model =
        match r.injector_result with
        | None -> ("", "", "", "")
        | Some { outcome = Sat { depth; model }; time } ->
          ("sat", time_to_string time, string_of_int depth, model)
        | Some { outcome = Unsat; time } ->
          ("unsat", time_to_string time, "", "")
        | Some { outcome = Timeout; time } ->
          ("timeout", time_to_string time, "", "")
        | Some { outcome = Error msg; time } ->
          ( quote_csv_string (Fmt.str "error: %s" msg)
          , time_to_string time
          , ""
          , "" )
      in
      Fmt.pf oc "%s,%a,%s,%s,%s,%s,%s,%s\n" r.package Vuln_type.pp r.expected
        symb_status symb_time inj_status inj_time inj_depth inj_model )
    results;
  Fmt.pr "Results written to %s@." csv_path

module Cli = struct
  open Cmdliner

  let vuln_type =
    let doc = "" in
    let type_conv =
      Arg.Conv.make ~docv:"VULN" ~parser:Vuln_type.of_string ~pp:Vuln_type.pp ()
    in
    Arg.(value & opt (some type_conv) None & info [ "type" ] ~doc)

  let time_limit =
    let doc = "Maximum time allowed (s) for each subprocess spawned." in
    Arg.(value & opt float 600.0 & info [ "time-limit" ] ~doc)

  let memory_limit =
    let doc = "Maximum memory allowed (GiB) for each subprocess spawned." in
    Arg.(value & opt int 3 & info [ "memory-limit" ] ~doc)

  let jobs =
    let doc = "Number of concurrent jobs to run." in
    Arg.(value & opt int 6 & info [ "jobs" ] ~doc)

  let cmd =
    let open Term.Syntax in
    let term =
      let+ vuln_type
      and+ time_limit
      and+ memory_limit
      and+ jobs in
      Eio_main.run (main vuln_type time_limit memory_limit jobs)
    in
    let info = Cmd.info "runner" in
    Cmd.make info term
end

let () = exit (Cmdliner.Cmd.eval Cli.cmd)
