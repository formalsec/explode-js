type run_type =
  | Expected
  | No_vis

let dispatch = function
  | Expected -> "expected_output.json"
  | No_vis -> "no-vis.json"

type t =
  | Full
  | Run of run_type

let pp fmt = function
  | Full -> Fmt.string fmt "full"
  | Run Expected  -> Fmt.string fmt "run"
  | Run No_vis -> Fmt.string fmt "run-no-vis"

let of_string = function
  | "full" -> Ok Full
  | "run" -> Ok (Run Expected)
  | "run-no-vis" -> Ok (Run No_vis)
  | s -> Error (`Msg (Fmt.str "unexpected run mode: %s" s))

let conv = Cmdliner.Arg.conv (of_string, pp)
