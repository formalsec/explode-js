open Explode_js_instrument

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

let run ~debug ~mode ~scheme_path ~file ~witness ~output_file =
  if debug then Logs.set_level (Some Debug);
  match mode with
  | Symbolic -> (
    match
      Test.Symbolic.generate_all ?file ~scheme_path ~output_dir:output_file ()
    with
    | Error _ as e -> e
    | Ok _n -> Ok 0 )
  | Concrete -> (
    let witness =
      match witness with
      | Some wit -> wit
      | None -> assert false
    in
    match Test.Literal.generate_all ?file scheme_path witness output_file with
    | Ok () -> Ok 0
    | Error _ as e -> e )
