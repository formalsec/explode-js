open Injector

let test_grammar_features =
  {|
<Range> ::= [a-z] [A-Z] [0-9];
<Star> ::= "a"* <Range>*;
<Plus> ::= "b"+ [0-9]+;
<Group> ::= ("a" "b")* ("c" | "d")+;
<Nested> ::= ("a" [0-9]*)+ | [a-z]+;
<Id> ::= ([a-z] | [A-Z] | "_") ([a-z] | [A-Z] | [0-9] | "_")*;
<List> ::= <Id> (", " <Id>)*;
|}

let () =
  Fmt.pr "--- Grammar Features Testing ---@.";
  let rules = Parse.from_string test_grammar_features in
  List.iter (fun rule -> Fmt.pr "%a@." Rule.pp rule) rules
