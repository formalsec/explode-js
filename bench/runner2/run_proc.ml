module Unix = Core_unix

let dup2 ~src ~dst =
  Unix.dup2 ~src ~dst ();
  Unix.close src

let set_time_limit time_limit =
  let open Unix.RLimit in
  let time_limit = Int64.of_int time_limit in
  set cpu_seconds { cur = Limit time_limit; max = Limit time_limit }

let with_ic fd f =
  let ic = Unix.in_channel_of_descr fd in
  Fun.protect ~finally:(fun () -> In_channel.close ic) (fun () -> f ic)

let int_of_status = function
  | Ok () -> 0
  | Error e -> (
    match e with
    | `Exit_non_zero i -> i
    | `Signal signal -> Core.Signal.to_caml_int signal )

let run ?time_limit prog argv : Run_proc_result.t =
  let start = Unix.gettimeofday () in
  let stdout_read, stdout_write = Unix.pipe ~close_on_exec:false () in
  let stderr_read, stderr_write = Unix.pipe ~close_on_exec:false () in
  let pid =
    Unix.fork_exec ~prog ~argv () ~preexec_fn:(fun () ->
        Unix.close stdout_read;
        Unix.close stderr_read;
        dup2 ~src:stdout_write ~dst:Unix.stdout;
        dup2 ~src:stderr_write ~dst:Unix.stderr;
        Option.iter set_time_limit time_limit )
  in
  Unix.close stdout_write;
  Unix.close stderr_write;
  let stdout = with_ic stdout_read In_channel.input_all in
  let stderr = with_ic stderr_read In_channel.input_all in
  let (wpid, status), ruse = Unix.wait_with_resource_usage (`Pid pid) in
  assert (Core.Pid.equal pid wpid);
  { Run_proc_result.returncode = int_of_status status
  ; stdout
  ; stderr
  ; rtime = Unix.gettimeofday () -. start
  ; utime = ruse.utime
  ; stime = ruse.stime
  }
