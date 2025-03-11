type t =
  | Full
  | Run

let pp fmt = function
  | Full -> Fmt.string fmt "full"
  | Run -> Fmt.string fmt "run"

let of_string = function
  | "full" -> Ok Full
  | "run" -> Ok Run
  | s -> Error (`Msg (Fmt.str "unexpected run mode: %s" s))

let conv = Cmdliner.Arg.conv (of_string, pp)
