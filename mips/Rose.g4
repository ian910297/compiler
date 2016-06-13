grammar Rose;

options {
  language = Java;
}

@header {
  import java.util.*;
  import java.io.*;
}

@members {
  // Produce Declare Expression
  private String declare(String str) {
    String name = str.split(":")[0];
    String type = ".word";
    String value = "0";

    return name + ":" + "\t" + type + "\t" + value;
  }

  private boolean isNumeric(String str) {
    return str.matches("-?\\d+(\\.\\d+)?");
  }
  /*
  private boolean isNumeric(String string) {
    if (string == null || string.isEmpty()) {
      return false;
    }
    int i = 0;
    int stringLength = string.length();
    if (string.charAt(0) == '-') {
      if (stringLength > 1) {
        i++;
      } else {
        return false;
      }
    }
    if (!Character.isDigit(string.charAt(i))
        || !Character.isDigit(string.charAt(stringLength - 1))) {
      return false;
    }
    i++;
    stringLength--;
    if (i >= stringLength) {
      return true;
    }
    for (; i < stringLength; i++) {
      if (!Character.isDigit(string.charAt(i))
          && string.charAt(i) != '.') {
        return false;
      }
    }
    return true;
  }
  */
}

// Parser Rules
program : PROCEDURE Identifier IS
{ System.out.println(".data"); } DECLARE variables
{ System.out.println(".main"); } BEGIN statements
{ System.out.println("exit"); } END Semi;

variables
: variables variable { System.out.println(declare($variable.text)); }
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
: Identifier ':=' r_assignment_statement=arith_expression ';' {
  if($r_assignment_statement.expr!=null) {
    if(isNumeric($r_assignment_statement.expr)) {// immediate value
      System.out.println("li\t\$t0, 0");
      System.out.println("la\t\$t1, " + $Identifier.text);
      System.out.println("sw\t\$t0, 0(\$t1)");
    } else {

    }
  }
}
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

arith_expression returns [String expr]
: r_arith_expression=arith_term { $expr=$r_arith_expression.expr; } arith_expression_R
;

arith_expression_R returns [String expr]
:   '+' r_arith_expression_R=arith_term { $expr=$r_arith_expression_R.expr; }arith_expression_R
| '-' r_arith_expression_R=arith_term { $expr=$r_arith_expression_R.expr; }arith_expression_R
|
;

arith_term returns [String expr]
: r_arith_term=arith_factor { $expr=$r_arith_term.expr; } arith_term_R
;

arith_term_R returns [String expr]
:   '*' r_arith_term_R=arith_factor arith_term_R { $expr=$r_arith_term_R.expr; }
| '/' r_arith_term_R=arith_factor arith_term_R { $expr=$r_arith_term_R.expr; }
| '%' r_arith_term_R=arith_factor arith_term_R { $expr=$r_arith_term_R.expr; }
|
;

arith_factor returns [String expr]
: ( '-' r_arith_factor=arith_primary { $expr=$r_arith_factor.expr; }
    | r_arith_factor=arith_primary { $expr=$r_arith_factor.expr; }
  )
;

arith_primary returns [String expr]
: ( Constant { $expr=$Constant.text; }
    | Identifier { $expr=$Identifier.text; }
    | '(' r_arith_primary=arith_expression ')' { $expr=$r_arith_primary.expr; }
  )
;

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

// Lexer Rule
// Identifier Element
fragment Uppercase
: [A-Z]
;

fragment Underscore
: '_'
;

fragment NonzeroDigit
: [1-9]
;

fragment Digit
: [0-9]
;

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

