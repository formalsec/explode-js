open Eio.Std

let max_fibers = 6

let time_limit = 600.0

module State = struct
  module SSet = Set.Make (String)

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
    Fmt.pr "\r\x1b[K[%d/%d/%d] Active: %s@?" active state.completed state.total
      active_str

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

let run env _file =
  let proc_mgr = Eio.Stdenv.process_mgr env in
  let clock = Eio.Stdenv.clock env in
  let command = [ "sleep"; "1" ] in
  match
    Eio.Time.with_timeout clock time_limit (fun () ->
      Eio.Process.run proc_mgr command;
      Ok "Success" )
  with
  | Ok _ -> ()
  | Error `Timeout -> ()

let main env =
  let get_directories env =
    let cwd = Eio.Stdenv.cwd env in
    let packages_root = Eio.Path.(cwd / "packages") in
    let packages = Eio.Path.read_dir packages_root in
    List.filter_map
      (fun package ->
        let package = Eio.Path.(packages_root / package) in
        if not (Eio.Path.is_directory package) then None
        else
          let harness = Eio.Path.(package / "harness.js") in
          let metadata = Eio.Path.(package / "package.json") in
          if not Eio.Path.(is_file harness && is_file metadata) then None
          else Some package )
      packages
  in

  let dirs = get_directories env in
  let state = State.make (List.length dirs) in

  Switch.run @@ fun _sw ->
  Fmt.pr "Starting %d external jobs...@." state.total;

  Fiber.List.iter ~max_fibers
    (fun file ->
      let filename = Filename.basename (Eio.Path.native_exn file) in
      State.start_job state filename;
      run env file;
      State.finish_job state filename )
    dirs;

  Fmt.pr "\r\x1b[KAll %d jobs completed successfully.@." state.total

let () = Eio_main.run main
