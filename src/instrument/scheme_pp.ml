open Scheme

let merge_heuristic filename : t =
  { filename
  ; ty = Some Vuln_type.Proto_pollution
  ; source = Some "module.exports"
  ; source_lineno = None
  ; sink = None
  ; sink_lineno = None
  ; tainted_params = []
  ; params =
      [ ("dst_obj", Object (`Normal []))
      ; ( "src_obj"
        , Union
            [ Object (`Polluted 1); Object (`Polluted 2); Object (`Polluted 3) ]
        )
      ]
  ; cont = None
  }

let merge_heuristic2 filename : t =
  { filename
  ; ty = Some Vuln_type.Proto_pollution
  ; source = Some "module.exports"
  ; source_lineno = None
  ; sink = None
  ; sink_lineno = None
  ; tainted_params = []
  ; params =
      [ ("deep", Boolean)
      ; ("dst_obj", Object (`Normal []))
      ; ("src_obj", Object (`Polluted 2))
      ]
  ; cont = None
  }

let set_heuristic filename source : t =
  { filename
  ; ty = Some Vuln_type.Proto_pollution
  ; source = Some source
  ; source_lineno = None
  ; sink = None
  ; sink_lineno = None
  ; tainted_params = []
  ; params =
      [ ("dst_obj", Object (`Normal []))
      ; ("path", Union [ Array [ String; String ]; String ])
      ; ("value", String)
      ]
  ; cont = None
  }
