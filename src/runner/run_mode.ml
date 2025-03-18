type run_type =
  | Expected
  | No_vis

let dispatch = function
  | Expected -> "expected_output.json"
  | No_vis -> "no-vis.json"

type full_type =
  | Regular
  | Zeroday

let dispatch_full = function
  | Regular -> false
  | Zeroday -> true

type t =
  | Full of full_type
  | Run of run_type

let pp fmt = function
  | Full Regular -> Fmt.string fmt "full"
  | Full Zeroday -> Fmt.string fmt "full-zeroday"
  | Run Expected -> Fmt.string fmt "run"
  | Run No_vis -> Fmt.string fmt "run-no-vis"

let of_string = function
  | "full" -> Ok (Full Regular)
  | "full-zeroday" -> Ok (Full Zeroday)
  | "run" -> Ok (Run Expected)
  | "run-no-vis" -> Ok (Run No_vis)
  | s -> Error (`Msg (Fmt.str "unexpected run mode: %s" s))

let conv = Cmdliner.Arg.conv (of_string, pp)
