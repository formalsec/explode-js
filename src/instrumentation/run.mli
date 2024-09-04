val run :
     ?mode:int
  -> ?file:string
  -> config:string
  -> output:string
  -> unit
  -> (Fpath.t list, [> Result.err ]) result

val literal :
     ?mode:int
  -> ?file:string
  -> string
  -> string
  -> string
  -> (unit, [> Result.err ]) result
