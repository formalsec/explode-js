type options =
  { input : Fpath.t
  ; filename : Fpath.t option
  ; workspace_dir : Fpath.t
  ; time_limit : int
  }

let options input filename workspace_dir time_limit =
  { input; filename; workspace_dir; time_limit }

let main _ = ()
