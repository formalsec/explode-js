type options =
  { input : Fpath.t
  ; filename : Fpath.t option
  ; workspace_dir : Fpath.t
  ; time_limit : int
  }

val options : Fpath.t -> Fpath.t option -> Fpath.t -> int -> options

val main : options -> unit
