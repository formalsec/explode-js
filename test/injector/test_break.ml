open Injector

let test_grammar_long =
  {|<very_long_rule_name_to_force_a_break_at_some_point_if_we_are_lucky> ::= "case1" | "case2" | "case3" | "case4" | "case5" | "case6" | "case7" | "case8" | "case9" | "case10";|}

let () =
  let rules = Parse.from_string test_grammar_long in
  List.iter (fun rule -> Fmt.pr "%a@." Rule.pp rule) rules
