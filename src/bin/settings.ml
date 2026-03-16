module Cmd_run = struct
  type t =
    { workspace_dir : Path.t
    ; lazy_values : bool
    ; vuln_type : Explode_js_gen.Vuln_type.t option [@default None]
    ; solver_type : Smtml.Solver_type.t
    ; path_only : bool
    ; deterministic : bool
    ; input_path : Path.t [@main]
    }
  [@@deriving make, show]
end

module Cmd_injector = struct
  type t = { input_path : Path.t [@main] } [@@deriving make, show]
end
