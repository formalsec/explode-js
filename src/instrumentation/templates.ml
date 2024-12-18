module Symbolic = struct
  let default =
    Template.(
      text "var esl_symbolic = require(\"esl_symbolic\");\n"
      & text "// Vuln: " & var "vuln_ty" & text "\n" & var "test" & eof )

  let prototype_pollution =
    Template.(
      text "var esl_symbolic = require(\"esl_symbolic\");\n"
      & text "// Vuln: " & var "vuln_ty" & text "\n" & var "test" & text "\n"
      & text
          "if (({}).toString == \"polluted\") { throw Error(\"I pollute.\"); }"
      & eof )

  let dispatch = function
    | Some (Vuln_type.Cmd_injection | Code_injection | Path_traversal) ->
      default
    | Some Proto_pollution | None -> prototype_pollution

  let v ({ Vuln_intf.ty; _ } as summary) =
    let template = dispatch ty in
    let models =
      [ ("vuln_ty", Fmt.str "%a" (Fmt.option Vuln_type.pp) ty)
      ; ("test", Vuln_symbolic.to_string summary)
      ]
    in
    Template.render template models
end

module Literal = struct
  let default =
    Template.(text "// Vuln: " & var "vuln_ty" & text "\n" & var "test" & eof)

  let prototype_pollution =
    Template.(
      text "// Vuln: " & var "vuln_ty" & text "\n" & var "test" & text "\n"
      & text
          "if (({}).toString == \"polluted\") { throw Error(\"I pollute.\"); }"
      & eof )

  let dispatch = function
    | Some (Vuln_type.Cmd_injection | Code_injection | Path_traversal) ->
      default
    | Some Proto_pollution | None -> prototype_pollution

  let v map ({ Vuln_intf.ty; _ } as summary) =
    let template = dispatch ty in
    let models =
      [ ("vuln_ty", Fmt.str "%a" (Fmt.option Vuln_type.pp) ty)
      ; ("test", Vuln_literal.to_string map summary)
      ]
    in
    Template.render template models
end
