grammar Rose;

// Parser Rules
token
  : ( Keywords
    | Identifier
    | IntegerConstant
    | Operators
    | Whitespace// From this the following means skip
    | Newline
    | BlockComment
    | LineComment
    )*
  ;

// Keywords
Keywords
  : ( BEGIN
    | DECLARE
    | ELSE
    | END
    | EXIT
    | FOR
    | IF
    | IN
    | INTEGER
    | IS
    | LOOP
    | PROCEDURE
    | READ
    | THEN
    | WRITE
    )
  ;

// Keywords Element
BEGIN : 'begin';
DECLARE : 'declare';
ELSE : 'else';
END : 'end';
EXIT : 'exit';
FOR : 'for';
IF : 'if';
IN : 'in';
INTEGER : 'integer';
IS : 'is';
LOOP : 'loop';
PROCEDURE : 'procedure';
READ : 'read';
THEN : 'then';
WRITE : 'write';


Identifier
  : ( Uppercase
    | '_'
    )
    ( Uppercase
    | '_'
    | Digit
    )*
  ;

IntegerConstant
  : (   NonzeroDigit Digit*
      | Digit
    )
  ;

// Identifier Element
Uppercase : [A-Z];
Underscore : '_';
NonzeroDigit : [1-9];
Digit : [0-9];

// Operators
Operators
  : ( LeftParen
    | RightParen
    | Assign
    | Colon
    | Semi
    | DotDot
    | Plus
    | Minus
    | Star
    | Div
    | Mod
    | Less
    | LessEqual
    | Greater
    | GreaterEqual
    | Not
    | AndAnd
    | OrOr
    )
  ;
// Operators Element
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

