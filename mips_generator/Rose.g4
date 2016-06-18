grammar Rose;

options {
  language = Java;
}

@header {
  import java.util.*;
  import java.io.*;
}

@members {
  private int label = 0;
  private int reg = 0;

  private int if_true;
  private int if_false;
  private int if_break;

  private int debugPrintReg(int target) {
    System.out.println("move\t\$a0, \$t" + (target));
    System.out.println("li\t\$v0, 1");
    System.out.println("syscall");

    //ascii code for LF, if you have any trouble try 0xD for CR.
    System.out.println("addi\t\$a0, \$0, 0xA");
    //syscall 11 prints the lower 8 bits of \$a0 as an ascii character.
    System.out.println("addi\t\$v0, \$0, 0xB");
    System.out.println("syscall");

    return 0;
  }

  private int newline() {
    //ascii code for LF, if you have any trouble try 0xD for CR.
    System.out.println("addi\t\$a0, \$0, 0xA");
    //syscall 11 prints the lower 8 bits of \$a0 as an ascii character.
    System.out.println("addi\t\$v0, \$0, 0xB");
    System.out.println("syscall");

    return 0;
  }
}

// Parser Rules
program : PROCEDURE Identifier IS
{ System.out.println(".data"); } DECLARE variables
{ System.out.println(".text"); System.out.println("main:"); } BEGIN statements
END Semi;

variables
: variables variable
| /* eplison */
;

variable
: Identifier ':' 'integer' ';' {
    System.out.println($Identifier.text + ":\t.word\t0");
  }
;

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
: Identifier {
    System.out.println("la\t\$t" + reg + ", " + $Identifier.text);
    reg++;
  }
  ':=' arith_expression ';' {
    System.out.println("sw\t\$t" + (reg-1) + ", 0(\$t" + (reg-2) + ")");
    reg = reg - 2;
  }
;

if_statement
: ( 'if' bool_expression 'then' {
      if_true = label++;
      if_break = label++;

      reg--;
      System.out.println("beq\t\$t" + reg + ", \$zero, L" + if_true);
      System.out.println("j L" + if_break);

      System.out.println("L" + if_true + ":");
    }
    statements {
      System.out.println("L" + if_break + ":");
    }
    'end' 'if' ';'
    | 'if' bool_expression 'then' {
      if_true = label++;
      if_false = label++;
      if_break = label++;

      reg--;
      System.out.println("bne\t\$t" + reg + ", \$zero, L" + if_true);
      System.out.println("j L" + if_false);

      System.out.println("L" + if_true + ":");
    }
    statements 'else' {
      System.out.println("j L" + if_break);
      System.out.println("L" + if_false + ":");
    }
    statements 'end' 'if' ';' {
      System.out.println("L" + if_break + ":");
    }
  )
;

for_statement
: 'for' {
    System.out.println("L" + label + ":");
  }
  Identifier 'in' arith_expression '..' arith_expression 'loop' {

  }
  statements {

  }
  'end' 'loop' ';'
;

exit_statement
: 'exit' ';'
;

read_statement
: 'read' Identifier ';' {
    System.out.println("li\t\$v0, 5");
    System.out.println("syscall");

    System.out.println("la\t\$t" + reg + ", " + $Identifier.text);
    System.out.println("sw\t\$v0, 0(\$t" + reg + ")");
  }
;

write_statement
: 'write' arith_expression ';' {
    System.out.println("move \t\$a0, \$t" + (reg-1));
    System.out.println("li\t\$v0, 1");
    System.out.println("syscall");

    reg--;
  }
;

bool_expression
: bool_term bool_expression_R
;

bool_expression_R
: '||' bool_term bool_expression_R {
    System.out.println("or\t\$t" + (reg-2) + ", \$t" + (reg-2) + ", \$t" + (reg-1));
    reg--;
  }
  |
;

bool_term
: bool_factor bool_term_R
;

bool_term_R
: '&&' bool_factor bool_term_R {
    System.out.println("and\t\$t" + (reg-2) + ", \$t" + (reg-2) + ", \$t" + (reg-1));
    reg--;
  }
  |
;

bool_factor
: ( '!' bool_primary {
      System.out.println("beq\t\$zero, \$t" + (reg-1) + ", L" + label);
      System.out.println("j L" + (label+1));

      System.out.println("L" + label + ":");
      System.out.println("addi\t\$t" + (reg-1) + ", \$zero, 1");
      System.out.println("j L" + (label+2));

      System.out.println("L" + (label+1) + ":");
      System.out.println("add\t\$t" + (reg-1) + ", \$zero, \$zero");

      System.out.println("L" + (label+2) + ":");
      label += 3;
    }
    | bool_primary
  )
;

bool_primary
: arith_expression relation_op arith_expression {
    // TRUE RETURN 1
    System.out.println("sub\t\$t" + (reg-2) + ", \$t" + (reg-2) + ", \$t" + (reg-1));

    if($relation_op.text.equals("=")) {
      System.out.println("beq\t\$zero, \$t" + (reg-2) + ", L" + label);
    } else if($relation_op.text.equals("<>")) {
      System.out.println("bne\t\$zero, \$t" + (reg-2) + ", L" + label);
    } else if($relation_op.text.equals("<")) {
      System.out.println("bltz\t\$t" + (reg-2) + ", L" + label);
    } else if($relation_op.text.equals(">")) {
      System.out.println("bgtz\t\$t" + (reg-2) + ", L" + label);
    } else if($relation_op.text.equals("<=")) {
      System.out.println("blez\t\$t" + (reg-2) + ", L" + label);
    } else if($relation_op.text.equals(">=")) {
      System.out.println("bgez\t\$t" + (reg-2) + ", L" + label);
    }

    System.out.println("j L" + (label+1));

    System.out.println("L" + label + ":");
    System.out.println("addi\t\$t" + (reg-2) + ", \$zero, 1");
    System.out.println("j L" + (label+2));

    System.out.println("L" + (label+1) + ":");
    System.out.println("add\t\$t" + (reg-2) + ", \$zero, \$zero");

    System.out.println("L" + (label+2) + ":");
    label += 3;
    reg--;
  }
;

relation_op
: '=' | '<>' | '>' | '>=' | '<' | '<='
;

arith_expression
: arith_term arith_expression_R
;

arith_expression_R
:   '+' arith_term arith_expression_R {
      System.out.println("add\t\$t" + (reg-2) + ", \$t" + (reg-2) + ", \$t" + (reg-1));
      reg--;
    }
  | '-' arith_term arith_expression_R {
      System.out.println("sub\t\$t" + (reg-2) + ", \$t" + (reg-2) + ", \$t" + (reg-1));
      reg--;
    }
  |
;

arith_term
: arith_factor arith_term_R
;

arith_term_R
:   '*' arith_factor arith_term_R {
      System.out.println("mult\t\$t" + (reg-2) + ", \$t" + (reg-1));
      System.out.println("mflo\t\$t" + (reg-2));
      reg--;
    }
  | '/' arith_factor arith_term_R {
      System.out.println("div\t\$t" + (reg-2) + ", \$t" + (reg-1));
      System.out.println("mflo\t\$t" + (reg-2));
      reg--;
    }
  | '%' arith_factor arith_term_R {
      System.out.println("div\t\$t" + (reg-2) + ", \$t" + (reg-1));
      System.out.println("mfhi\t\$t" + (reg-2));
      reg--;
    }
  |
;

arith_factor
: ( '-' arith_primary {
      System.out.println("li\t\$t" + reg + ", 0");
      System.out.println("sub\t\$t" + (reg-1) + ", \$t" + (reg-1) + ", \$t" + (reg-1));
      System.out.println("sub\t\$t" + (reg-1) + ", \$t" + (reg-1) + ", \$t" + (reg-1));
    }
    | arith_primary
  )
;

arith_primary
: ( Constant {
      System.out.println("li\t\$t" + reg + ", " + $Constant.text);
      reg++;
    }
    | Identifier {
      System.out.println("la\t\$t" + (reg+1) + ", " +$Identifier.text);
      System.out.println("lw\t\$t" + reg + ", 0(\$t" + (reg+1) + ")");
      reg++;
    }
    | '(' arith_expression ')'
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

