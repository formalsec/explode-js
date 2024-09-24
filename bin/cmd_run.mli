type options =
  { config : Fpath.t
  ; filename : Fpath.t option
  ; workspace_dir : Fpath.t
  ; time_limit : float option
  }

val options : Fpath.t -> Fpath.t option -> Fpath.t -> float option -> options

val main : options -> int
