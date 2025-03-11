let dup2 ~src ~dst =
  Unix.dup2 src dst;
  Unix.close src

let set_time_limit time_limit =
  let time_limit = Some (Int64.of_int time_limit) in
  ExtUnix.Specific.setrlimit RLIMIT_CPU ~soft:time_limit ~hard:time_limit

let read_tmp_file file =
  let file_data = In_channel.with_open_bin file In_channel.input_all in
  Unix.unlink file;
  file_data

let int_of_status = function
  | Unix.WEXITED n -> n
  | WSIGNALED n -> n
  | WSTOPPED n -> n

let run ~time_limit prog argv : Run_proc_result.t =
  let start = Unix.gettimeofday () in
  let stdout_file = Filename.temp_file "stdout" ".txt" in
  let stderr_file = Filename.temp_file "stderr" ".txt" in
  let pid = Unix.fork () in
  if pid = 0 then begin
    ExtUnix.Specific.setpgid 0 0;
    let stdout_fd = Unix.openfile stdout_file [ O_WRONLY; O_CREAT ] 0o666 in
    let stderr_fd = Unix.openfile stderr_file [ O_WRONLY; O_CREAT ] 0o666 in
    dup2 ~src:stdout_fd ~dst:Unix.stdout;
    dup2 ~src:stderr_fd ~dst:Unix.stderr;
    set_time_limit time_limit;
    let _ = time_limit in
    Unix.execvp prog (Array.of_list argv)
  end
  else begin
    let exception Sigchld in
    let did_timeout = ref false in
    begin
      try
        Sys.set_signal Sys.sigchld
          (Signal_handle (fun (_ : int) -> raise Sigchld));
        Unix.sleep time_limit;
        did_timeout := true;
        (* we kill the process group id (pgid) which should be equal to pid *)
        Unix.kill (-pid) Sys.sigkill;
        Sys.set_signal Sys.sigchld Signal_default
      with Sigchld -> ()
    end;
    Sys.set_signal Sys.sigchld Signal_default;
    let wpid, status, ruse = ExtUnix.Specific.wait4 [] (-pid) in
    assert (pid = wpid);
    let stdout = read_tmp_file stdout_file in
    let stderr = read_tmp_file stderr_file in
    { Run_proc_result.returncode = int_of_status status
    ; stdout
    ; stderr
    ; rtime = Unix.gettimeofday () -. start
    ; utime = ruse.ru_utime
    ; stime = ruse.ru_stime
    }
  end
