open Injector

let test_grammar = {|
<A> ::= <A> "b" | "c";
|}

let test_grammar_mutual = {|
<A> ::= <B> "a" | "c";
<B> ::= <A> "b" | "d";
|}

let () =
  Fmt.pr "--- Direct Recursion (k = 2) ---@.";
  let rules = Parse.from_string test_grammar in
  let unfolded = Transform.unfold rules 2 in
  List.iter (fun rule -> Fmt.pr "%a@." Rule.pp rule) unfolded;

  Fmt.pr "--- Mutual Recursion (k = 2) ---@.";
  let rules_mutual = Parse.from_string test_grammar_mutual in
  let unfolded_mutual = Transform.unfold rules_mutual 2 in
  List.iter (fun rule -> Fmt.pr "%a@." Rule.pp rule) unfolded_mutual
