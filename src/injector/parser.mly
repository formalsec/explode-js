%{

%}

%token SEMI
%token LBRACKET
%token RBRACKET
%token UNION
%token DEQ
%token EOF

%token <string> STR

%start <Rule.t list> grammar
%%

let grammar :=
  | rules = terminated(rule, SEMI)+; EOF; { rules }

let rule :=
  | name = rulename; DEQ; body = rulebody; { { Rule.name; body } }

let rulename :=
  | LBRACKET; s = STR; RBRACKET; { s }

let rulebody :=
  | rulecases = separated_nonempty_list(UNION, rulecase); { rulecases }

let rulecase :=
  | case = ruleatom+; { case }

let ruleatom :=
  | name = rulename; { Rule.Non_terminal name }
  | t = STR; { Rule.Terminal t }
