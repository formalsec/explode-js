%{

%}

%token SEMI
%token LANGLE
%token RANGLE
%token UNION
%token DEQ
%token LBRACKET
%token RBRACKET
%token DASH
%token STAR
%token PLUS
%token QUESTION
%token LPAREN
%token RPAREN
%token EOF

%token <string> STR

%start <Rule.t list> grammar
%%

let grammar :=
  | rules = terminated(rule, SEMI)+; EOF; { rules }

let rule :=
  | name = rulename; DEQ; UNION?; body = rulebody; { { Rule.name; body } }

let rulename :=
  | LANGLE; s = STR; RANGLE; { s }

let rulebody :=
  | rulecases = separated_nonempty_list(UNION, rulecase); { rulecases }

let rulecase :=
  | case = ruleatom+; { case }

let ruleatom :=
  | a = simple_ruleatom; { a }
  | a = simple_ruleatom; STAR; { Rule.Star a }
  | a = simple_ruleatom; PLUS; { Rule.Plus a }
  | a = simple_ruleatom; QUESTION; { Rule.Opt a }

let simple_ruleatom :=
  | name = rulename; { Rule.Non_terminal name }
  | t = STR; { Rule.Terminal t }
  | LBRACKET; c1 = char; DASH; c2 = char; RBRACKET; { Rule.Range (c1, c2) }
  | LPAREN; body = rulebody; RPAREN; { Rule.Group body }

let char :=
  | s = STR; { if String.length s = 1 then s.[0] else failwith "Expected single character" }
