open Explode_js_instrumentation

type instrument =
  | Symbolic
  | Concrete

let pp_instrument fmt = function
  | Symbolic -> Fmt.string fmt "symbolic"
  | Concrete -> Fmt.string fmt "concrete"

let instrument_of_string s =
  match String.lowercase_ascii s with
  | "symbolic" -> Ok Symbolic
  | "concrete" -> Ok Concrete
  | _ -> Error (`Msg "unknown instrument type")

let instrument_conv =
  ( (fun s ->
      match instrument_of_string s with
      | Ok mode -> `Ok mode
      | Error (`Msg err) -> `Error err )
  , pp_instrument )

let run ~debug ~mode ~taint_summary ~file ~witness ~output_file =
  if debug then Logs.set_level (Some Debug);
  let taint_summary = Fpath.to_string taint_summary in
  let file = Option.map Fpath.to_string file in
  match mode with
  | Symbolic -> (
    match Run.run ?file ~config:taint_summary ~output:output_file () with
    | Error _ as e -> e
    | Ok _n -> Ok 0 )
  | Concrete -> (
    let witness = Option.get witness in
    match Run.literal ?file taint_summary witness output_file with
    | Ok () -> Ok 0
    | Error _ as e -> e )
