module Cmd_run = struct
  type t =
    { workspace_dir : string
    ; lazy_values : bool
    ; vuln_type : Explode_js_gen.Vuln_type.t option [@default None]
    ; solver_type : Smtml.Solver_type.t
    ; path_only : bool
    ; deterministic : bool
    ; input_path : string [@main]
    }
  [@@deriving make, show]
end
