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

let run ~debug ~mode ~scheme_file ~original_file ~witness_file ~output_path =
  if debug then Logs.set_level (Some Debug);
  match mode with
  | Symbolic -> (
    match
      Test.Symbolic.generate_all ?original_file ~scheme_file
        ~output_dir:output_path ()
    with
    | Error _ as e -> e
    | Ok _n -> Ok 0 )
  | Concrete -> (
    let witness_file =
      match witness_file with
      | Some wit -> wit
      | None -> assert false
    in
    match
      Test.Literal.generate_all ?original_file ~output_dir:output_path
        scheme_file witness_file
    with
    | Ok () -> Ok 0
    | Error _ as e -> e )
