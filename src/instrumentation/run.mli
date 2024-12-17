val run :
     ?mode:int
  -> ?file:string
  -> config:string
  -> output:string
  -> unit
  -> (Fpath.t list, [> Instrument_result.err ]) result

val literal :
     ?mode:int
  -> ?file:string
  -> string
  -> string
  -> string
  -> (unit, [> Instrument_result.err ]) result
