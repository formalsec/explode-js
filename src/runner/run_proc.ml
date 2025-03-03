let dup2 ~src ~dst =
  Unix.dup2 src dst;
  Unix.close src

let set_time_limit time_limit =
  let time_limit = Some (Int64.of_int time_limit) in
  ExtUnix.Specific.setrlimit RLIMIT_CPU ~soft:time_limit ~hard:time_limit

let with_ic fd f =
  let ic = Unix.in_channel_of_descr fd in
  Fun.protect ~finally:(fun () -> In_channel.close ic) (fun () -> f ic)

let int_of_status = function
  | Unix.WEXITED n -> n
  | WSIGNALED n -> n
  | WSTOPPED n -> n

let run ?time_limit prog argv : Run_proc_result.t =
  let start = Unix.gettimeofday () in
  let stdout_read, stdout_write = Unix.pipe ~cloexec:false () in
  let stderr_read, stderr_write = Unix.pipe ~cloexec:false () in
  let pid = Unix.fork () in
  if pid = 0 then begin
    Unix.close stdout_read;
    Unix.close stderr_read;
    dup2 ~src:stdout_write ~dst:Unix.stdout;
    dup2 ~src:stderr_write ~dst:Unix.stderr;
    Option.iter set_time_limit time_limit;
    Unix.execv prog (Array.of_list argv)
  end
  else begin
    Unix.close stdout_write;
    Unix.close stderr_write;
    let stdout = with_ic stdout_read In_channel.input_all in
    let stderr = with_ic stderr_read In_channel.input_all in
    let wpid, status, ruse = ExtUnix.Specific.wait4 [] pid in
    assert (pid = wpid);
    { Run_proc_result.returncode = int_of_status status
    ; stdout
    ; stderr
    ; rtime = Unix.gettimeofday () -. start
    ; utime = ruse.ru_utime
    ; stime = ruse.ru_stime
    }
  end
