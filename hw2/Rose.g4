grammar Rose;

// Parser Rules
program : PROCEDURE Identifier IS DECLARE variables BEGIN statements END Semi;

variables
  : variables variable
    | /* eplison */
  ;

variable : Identifier ':' 'integer' ';';

statements
  : statements statement
    | /* eplison */
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
  : Identifier ':=' arith_expression ';'
  ;

if_statement
  : ( 'if' bool_expression 'then' statements 'end' 'if' ';'
    | 'if' bool_expression 'then' statements 'else' statements 'end' 'if' ';'
    )
  ;

for_statement
  : 'for' Identifier 'in' arith_expression '..' arith_expression 'loop' statements 'end' 'loop' ';'
  ;

exit_statement
  : 'exit' ';'
  ;

read_statement
  : 'read' Identifier ';'
  ;

write_statement
  : 'write' arith_expression ';'
  ;

/*
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
*/
bool_expression
  : bool_term bool_expression_R
  ;

bool_expression_R
  : '||' bool_term bool_expression_R
    |
  ;

bool_term
  : bool_factor bool_term_R
  ;

bool_term_R
  : '&&' bool_factor bool_term_R
    |
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
  : '=' | '<>' | '>' | '>=' | '<' | '<='
  ;

/*
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
*/

arith_expression
  : arith_term arith_expression_R
  ;

arith_expression_R
  :   '+' arith_term arith_expression_R
    | '-' arith_term arith_expression_R
    |
  ;

arith_term
  : arith_factor arith_term_R
  ;

arith_term_R
  :   '*' arith_factor arith_term_R
    | '/' arith_factor arith_term_R
    | '%' arith_factor arith_term_R
    |
  ;

arith_factor
  : ( '-' arith_primary
    | arith_primary
    )
  ;
arith_primary
  : ( Constant
    | Identifier
    | '(' arith_expression ')'
    )
  ;

// Lexer Rule
Identifier
  : ( Uppercase
    | '_'
    )
    ( Uppercase
    | '_'
    | Digit
    )*
  ;

Constant
  : (   NonzeroDigit Digit*
      | Digit
    )
  ;

// Identifier Element
Uppercase : [A-Z];
Underscore : '_';
NonzeroDigit : [1-9];
Digit : [0-9];

// Keywords
PROCEDURE: 'procedure';
IS: 'is';
DECLARE: 'declare';
BEGIN: 'begin';
END: 'end';

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

// Skip
Whitespace
  : [ \t]+
    -> skip
  ;
Newline
  : (   '\r''\n'?
      | '\n'
    )
    ->skip
  ;
BlockComment
  : '/*' .*? '*/'
    -> skip
  ;
LineComment
  : '//' ~[\r\n]*
    -> skip
  ;

