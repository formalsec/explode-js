type t =
  { returncode : int
  ; stdout : string
  ; stderr : string
  ; rtime : float
  ; utime : float
  ; stime : float
  }

let dummy =
  { returncode = 0
  ; stdout = ""
  ; stderr = ""
  ; rtime = 0.
  ; utime = 0.
  ; stime = 0.
  }

let pp fmt { returncode; utime; stime; rtime; _ } =
  Fmt.pf fmt "@[<hov>Exited %d in@;%.03fs user@;%.03fs system@;%0.3fs total@]"
    returncode utime stime rtime

let pp_csv fmt { returncode; stdout; stderr; rtime; utime; stime } =
  let stdout = String.escaped stdout in
  let stderr = String.escaped stderr in
  Fmt.pf fmt "%d|%s|%s|%f|%f|%f" returncode stdout stderr rtime utime stime
