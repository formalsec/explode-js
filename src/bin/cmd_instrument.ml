open Explode_js_instrument

module Settings = struct
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

  let instrument_conv = Cmdliner.Arg.conv (instrument_of_string, pp_instrument)

  type t =
    { debug : bool
    ; mode : instrument
    ; scheme_file : Fpath.t
    ; original_file : Fpath.t option
    ; witness_file : Fpath.t option
    ; output_path : string
    }
  [@@deriving make]
end

let run
  { Settings.debug
  ; mode
  ; scheme_file
  ; original_file
  ; witness_file
  ; output_path
  } =
  if debug then Logs.set_level (Some Debug);
  match mode with
  | Settings.Symbolic -> (
    match
      Test.Symbolic.generate_all ?original_file ~proto_pollution:false
        ~scheme_file ~output_dir:output_path ()
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
      Test.Literal.generate_all ?original_file ~proto_pollution:false
        ~output_dir:output_path scheme_file witness_file
    with
    | Ok () -> Ok 0
    | Error _ as e -> e )
