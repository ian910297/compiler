grammar Rose;

// main
program : procedure identifier is declare variables begin statements end ;

variables
  : variables variable
  ;

variable : identifier ':' integer ;

statements
  : statements statement
  ;

statement
  : ( assignment_statement
    | if_statement
    | for_statement
    | exit_statement
    | read_statement
    | write_statement
    )
  ;

assignment_statement
  : identifier ':=' arith_expression
  ;

if_statement
  : ( if bool_expression then statements end if
    | if bool_expression then statements else statements end if
    )
  ;

for_statement
  : for identifier in arith_expression '..' arith_expression loop statements end loop
  ;

exit_statement
  : exit
  ;

read_statement
  : read identifier
  ;

write_statement
  : write arith_expression
  ;

bool_expression
  : ( bool_expression '||' bool_term
    | bool_term
    )
  ;

bool_term
  : ( bool_term '&&' bool_factor
    | bool_factor
    )
  ;

bool_factor
  : ( '!' bool_primary
    | bool_primary
    )
  ;

bool_primary
  : arith_expression relation_op arith_expression
  ;

relation_op
  : '=' | '<>' | '>' | '>=' | '<' | '<='i
  ;


arith_expression
  : ( arith_expression '+' arith_term
    | arith_expression '-' arith_term
    | arith_term
    )
  ;

arith_term
  : ( arith_term '*' arith_factor
    | arith_term '/' arith_factor
    | arith_term '%' arith_factor
    | arith_factor
    )
  ;

arith_factor
  : ( '-' arith_primary
    | arith_primary
    )
  ;
arith_primary
  : ( constant
    | identifier
    | '(' arith_expression ')'
    )
  ;

// Keywords


// Operators
LeftParen : '(';
RightParen : ')';

Assign : ':=';
Colon : ':';
Semi : ';';
DotDot : '..';

Plus : '+';
Minus : '-';
Star : '*';
Div : '/';
Mod : '%';

Less : '<';
LessEqual : '<=';
Greater : '>';
GreaterEqual : '>=';

Not : '!';
AndAnd : '&&';
OrOr : '||';

