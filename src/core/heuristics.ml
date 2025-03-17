module Pollution = struct
  open Explode_js_instrument

  let merge ?(objects = 3) ?(source = "module.exports") filename : Scheme.t =
    let polluting_objects =
      match objects with
      | 1 -> Scheme.Object (`Polluted 2)
      | _ ->
        Union
          [ Object (`Polluted 1); Object (`Polluted 2); Object (`Polluted 3) ]
    in
    { filename
    ; ty = Some Vuln_type.Proto_pollution
    ; source = Some source
    ; source_lineno = None
    ; sink = None
    ; sink_lineno = None
    ; tainted_params = []
    ; params =
        [ ("dst_obj", Object (`Normal [])); ("src_obj", polluting_objects) ]
    ; cont = None
    }

  let merge2 ?(source = "module.exports") filename : Scheme.t =
    { filename
    ; ty = Some Vuln_type.Proto_pollution
    ; source = Some source
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

  let set filename source : Scheme.t =
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

  let has_recursive =
    let re = Dune_re.(compile @@ Perl.re {|exports.recursive|}) in
    fun input_file ->
      In_channel.with_open_text (Fpath.to_string input_file) @@ fun ic ->
      let file_data = In_channel.input_all ic in
      match Dune_re.exec_opt re file_data with
      | None -> false
      | Some _ -> true
end
