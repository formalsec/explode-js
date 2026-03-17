Basic verification:
  $ explode-js injector verify ../mutual.bnf <<EOF
  > 3
  > A_2
  > cba
  > EOF
  Original grammar:
  <A> ::= <B> "a" | "c";
  <B> ::= <A> "b" | "d";
  Unfolding level:
  Unfolded grammar (k = 3):
  <A_3> ::= <B_2> "a" | "c";
  <A_2> ::= <B_1> "a" | "c";
  <A_1> ::= <B_0> "a" | "c";
  <A_0> ::= "c";
  <B_3> ::= <A_2> "b" | "d";
  <B_2> ::= <A_1> "b" | "d";
  <B_1> ::= <A_0> "b" | "d";
  <B_0> ::= "d";
  Desired rule:
  Grammar candidate:
  SMT Expr: (str.in_re "cba"
             (regexp.union
              ((regexp.++
                ((regexp.union ((regexp.++ ((str.to_re "c"), (str.to_re "b"))),
                  (str.to_re "d"))), (str.to_re "a"))), (str.to_re "c"))))
  Candiate 'cba' is a valid sentence of A_2
