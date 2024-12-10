module Value = Ecma_sl.Symbolic_value.M

type t =
  [ `Abort of string
  | `Assert_failure of Value.value
  | `Eval_failure of Value.value
  | `Exec_failure of Value.value
  | `Failure of string
  | `ReadFile_failure of Value.value
  ]

let pp fmt = function
  | `Abort msg -> Fmt.pf fmt "Abort %S" msg
  | `Assert_failure v -> Fmt.pf fmt "Assert_failure %a" Value.pp v
  | `Eval_failure v -> Fmt.pf fmt "Eval_failure %a" Value.pp v
  | `Exec_failure v -> Fmt.pf fmt "Exec_failure %a" Value.pp v
  | `Failure msg -> Fmt.pf fmt "Failure %S" msg
  | `ReadFile_failure v -> Fmt.pf fmt "ReadFile_failure %a" Value.pp v

let to_json = function
  | `Abort msg -> `Assoc [ ("type", `String "Abort"); ("sink", `String msg) ]
  | `Assert_failure v ->
    let v = Fmt.str "%a" Value.pp v in
    `Assoc [ ("type", `String "Assert failure"); ("sink", `String v) ]
  | `Eval_failure v ->
    let v = Fmt.str "%a" Value.pp v in
    `Assoc [ ("type", `String "Eval failure"); ("sink", `String v) ]
  | `Exec_failure v ->
    let v = Fmt.str "%a" Value.pp v in
    `Assoc [ ("type", `String "Exec failure"); ("sink", `String v) ]
  | `ReadFile_failure v ->
    let v = Fmt.str "%a" Value.pp v in
    `Assoc [ ("type", `String "ReadFile failure"); ("sink", `String v) ]
  | `Failure msg ->
    `Assoc [ ("type", `String "Failure"); ("sink", `String msg) ]
