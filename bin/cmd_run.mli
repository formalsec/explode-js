type options =
  { debug : bool
  ; config : Fpath.t
  ; filename : Fpath.t option
  ; workspace_dir : Fpath.t
  ; time_limit : float
  }

val options : bool -> Fpath.t -> Fpath.t option -> Fpath.t -> float -> options

val main : options -> int
