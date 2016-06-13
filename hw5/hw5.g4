grammar hw5;

options {
  language = Java;
}

@header{
	import java.util.List;
	import java.io.*;
}

start :
  answer = value { System.out.println($answer.vals); } ;

value returns [int vals]
  : ( num=NUM { $vals = $num.int; }
    | '(' num2=expr ')' { $vals = $num2.exprs; }
    )
  ;

expr returns [int exprs]
  : ( '+' first=values['+'] { $exprs = $first.valss; }
    | '*' first2=values['*'] { $exprs = $first2.valss; }
    )
  ;

values [char valuesType] returns [int valss]
  : values1=value
    values2=values[$valuesType]
    {
    	if($valuesType == '+') {
    		$valss =  $values1.vals + $values2.valss;
    	} else if($valuesType == '*') {
    		$valss =  $values1.vals * $values2.valss;
    	}
    }
    |
    {
    	if($valuesType == '+') {
    		$valss = 0;
    	} else if($valuesType == '*') {
    		$valss = 1;
    	}
    }
  ;


token
  : ( NUM
    | Add
    | Mul
    | LeftParen
    | RightParen
    )*
  ;

NUM:[0-9]+;
Add : '+';
Mul : '*';
LeftParen : '(';
RightParen : ')';

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
