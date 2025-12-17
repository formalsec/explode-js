open Explode_js_gen

type exploit =
  { path : Path.t
  ; effect_ : Replay_effect.t
  }
[@@deriving yojson]

type outcome =
  | Path_not_found
  | Path_found
  | Exploit_found of exploit
[@@deriving yojson]

type test_result =
  { path : Path.t
  ; outcome : outcome
  ; time : float
  }
[@@deriving make, yojson]

type t =
  { filename : Path.t
  ; vuln_type : Vuln_type.t option
  ; sink : string option
  ; sink_lineno : int option
  ; result : test_result option
  ; raw_results : test_result list
  }
[@@deriving make, yojson]
