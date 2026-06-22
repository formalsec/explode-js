open Eio.Std
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

module Job_status = struct
  type t =
    | Found
    | Not_found
    | Timeout
    | Error of string

  let to_string = function
    | Found -> "found"
    | Not_found -> "not_found"
    | Timeout -> "timeout"
    | Error e -> "error: " ^ e
end

type job_result =
  { package : string
  ; expected : Vuln_type.t
  ; status : Job_status.t
  ; time : float option
  }

module Job = struct
  type t =
    { path : [ `Dir ] Eio.Path.t
    ; vuln : Vulnerability.t
    }
  [@@deriving make]
end

let run time_limit env (job : Job.t) : job_result =
  let open Eio in
  let fs = Stdenv.fs env in
  let proc_mgr = Stdenv.process_mgr env in
  let clock = Stdenv.clock env in
  let package_name = Filename.basename (Path.native_exn job.path) in
  let report_error msg =
    { package = package_name
    ; expected = job.vuln.type_
    ; status = Error msg
    ; time = None
    }
  in
  Path.with_open_out ~create:`Never Path.(fs / "/dev/null") @@ fun dev_null ->
  let cwd = job.path in
  let npm_ci () =
    let command = [ "npm"; "ci" ] in
    match
      Time.with_timeout clock time_limit @@ fun () ->
      Process.run ~cwd ~stderr:dev_null ~stdout:dev_null proc_mgr command;
      Ok ()
    with
    | Error `Timeout -> Error `Timeout
    | Ok () -> Ok ()
  in
  match npm_ci () with
  | Error `Timeout ->
    { package = package_name
    ; expected = job.vuln.type_
    ; status = Timeout
    ; time = None
    }
  | Ok () -> begin
    let command =
      [ "ecma-sl"; "symbolic"; "harness.js"; "--workspace"; "results" ]
    in
    let out_txt = Path.(cwd / "out.txt") in
    Path.with_open_out ~create:(`Or_truncate 0o644) out_txt @@ fun out ->
    match
      Time.with_timeout clock time_limit @@ fun () ->
      Process.run ~cwd
        ~is_success:(fun _ -> true)
        ~stderr:out ~stdout:out proc_mgr command;
      Ok ()
    with
    | Error `Timeout ->
      { package = package_name
      ; expected = job.vuln.type_
      ; status = Timeout
      ; time = None
      }
    | Ok () -> (
      let results_path = Path.(cwd / "results" / "symbolic-execution.json") in
      if not (Path.is_file results_path) then
        report_error "Missing results file"
      else
        let data = Path.load results_path in
        match Yojson.Safe.from_string data |> Tool_output.of_yojson with
        | Error msg -> report_error ("Parse error: " ^ msg)
        | Ok results ->
          let found =
            List.exists
              (fun (f : Tool_output.failure) ->
                match Vuln_type.of_string f.type_ with
                | Ok t -> Vuln_type.equal t job.vuln.type_
                | Error _ -> false )
              results.failures
          in
          { package = package_name
          ; expected = job.vuln.type_
          ; status = (if found then Found else Not_found)
          ; time = Some results.execution_time
          } )
    end

let init () = Fmt.set_style_renderer Fmt.stdout `Ansi_tty

let main vuln_type time_limit max_fibers env =
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
        let result = run time_limit env job in
        State.finish_job state filename;
        result )
      jobs
  in

  Fmt.pr "\r\x1b[KAll %d jobs completed successfully.@." state.total;

  let csv_path = "results.csv" in
  Out_channel.with_open_text csv_path @@ fun oc ->
  Printf.fprintf oc "package,expected,status,time\n";
  List.iter
    (fun (r : job_result) ->
      let status_str = Job_status.to_string r.status in
      let time_str =
        match r.time with
        | Some t -> string_of_float t
        | None -> ""
      in
      Printf.fprintf oc "%s,%s,%s,%s\n" r.package
        (Fmt.to_to_string Vuln_type.pp r.expected)
        status_str time_str )
    results;
  Fmt.pr "Results written to %s@." csv_path

module Cli = struct
  open Cmdliner

  let vuln_type =
    let type_conv =
      Arg.Conv.make ~docv:"VULN" ~parser:Vuln_type.of_string ~pp:Vuln_type.pp ()
    in
    Arg.(value & opt (some type_conv) None & info [ "type" ])

  let time_limit = Arg.(value & opt float 600.0 & info [ "time-limit" ])

  let jobs = Arg.(value & opt int 6 & info [ "jobs" ])

  let cmd =
    let open Term.Syntax in
    let term =
      let+ vuln_type
      and+ time_limit
      and+ jobs in
      Eio_main.run (main vuln_type time_limit jobs)
    in
    let info = Cmd.info "runner" in
    Cmd.make info term
end

let () = exit (Cmdliner.Cmd.eval Cli.cmd)
