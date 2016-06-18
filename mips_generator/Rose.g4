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

  private int if_index = 0;
  private int [] if_true = new int [100];
  private int [] if_false = new int [100];
  private int [] if_break = new int [100];

  private int for_index = 0;
  private int [] for_start = new int [100];
  private int [] for_end = new int [100];

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
      if_true[if_index] = label++;
      if_false[if_index] = label++;
      if_break[if_index] = label++;
      reg--;
      System.out.println("bne\t\$t" + reg + ", \$zero, L" + if_true[if_index]);
      System.out.println("j L" + if_break[if_index]);

      System.out.println("L" + if_true[if_index] + ":");
      if_index++;
    }
    statements {
      if_index--;
      System.out.println("L" + if_break[if_index] + ":");
    }
    'end' 'if' ';'
    | 'if' bool_expression 'then' {
      if_true[if_index] = label++;
      if_false[if_index] = label++;
      if_break[if_index] = label++;

      reg--;
      System.out.println("bne\t\$t" + reg + ", \$zero, L" + if_true[if_index]);
      System.out.println("j L" + if_false[if_index]);

      System.out.println("L" + if_true[if_index] + ":");
      if_index++;
    }
    statements 'else' {
      if_index--;
      System.out.println("j L" + if_break[if_index]);
      System.out.println("L" + if_false[if_index] + ":");
      if_index++;
    }
    statements 'end' 'if' ';' {
      if_index--;
      System.out.println("L" + if_break[if_index] + ":");
    }
  )
;

for_statement
: 'for' Identifier 'in' arith_expression '..' arith_expression 'loop' {
    for_start[for_index] = label++;
    for_end[for_index] = label++;

    System.out.println("la\t\$t" + reg + ", " + $Identifier.text);
    System.out.println("sw\t\$t" + (reg-2) + ", 0(\$t" + reg + ")");

    System.out.println("beq\t\$t" + (reg-2) + ", \$t" + (reg-1) + ", L" + for_end[for_index]);
    System.out.println("L" + for_start[for_index] + ":");
    for_index++;
  }
  statements {
    for_index--;
    System.out.println("la\t\$t" + reg + ", " + $Identifier.text);
    System.out.println("lw\t\$t" + (reg-2) + ", 0(\$t" + reg + ")");

    System.out.println("sub\t\$t" + (reg+1) + ", \$t" + (reg-2) + ", \$t" + (reg-1));
    System.out.println("bgtz\t\$t" + (reg+1) + ", L" + for_end[for_index]);

    System.out.println("addi\t\$t" + (reg-2) + ", \$t" + (reg-2) + ", 1");
    System.out.println("sw\t\$t" + (reg-2) + ", 0(\$t" + reg + ")");
    System.out.println("j L" + for_start[for_index]);

    System.out.println("L" + for_end[for_index] + ":");
    reg -= 2;
  }
  'end' 'loop' ';'
;

exit_statement
: 'exit' ';' {
  System.out.println("li\t\$v0, 10");
  System.out.println("syscall");
}
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

