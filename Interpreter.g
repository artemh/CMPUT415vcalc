tree grammar Interpreter;

options {
  language = Java;
  tokenVocab = sCalc;
  ASTLabelType = CommonTree;
}

@members {
  SymbolTable symbols = new SymbolTable();
}

program
  : (declaration)*
    (statement)*
  ;
  
declaration
  : ^(DECL VARNUM exp=expression) { symbols.define(new VarSymbol($VARNUM.text, (Type)symbols.resolve("int"), $exp.result)); }
  ;
  
// The idea on how to do if and loop statements in the interpreter
// was based on the code on the following page:
//
// http://www.linguamantra.org/wiki/display/CS652/Tree-based+interpreters
statement
  : ^(IFSTAT exp=expression { int block = input.index(); } .) {
    int next = input.index();
    if ($exp.result != 0) {
      input.seek(block);
      block();
    }
    input.seek(next);
  }
  // for expr, ANTLR places that code immediately after the LOOPSTAT token,
  // but there is an additional <DOWN> token before the position we actually
  // want to be at, needing the + 1
  | ^(LOOPSTAT { int expr = input.index() + 1; } . { int block = input.index(); } .) {
    int next = input.index();
    input.seek(expr);
    int cond = expression();
    while (cond != 0) {
      input.seek(block);
      block();
      input.seek(expr);
      cond = expression();
    }
    input.seek(next);
  }
  | ^(PRINTSTAT exp=expression { System.out.println(Integer.toString($exp.result)); })
  | ^(ASSIGN VARNUM exp=expression) { symbols.define(new VarSymbol($VARNUM.text, (Type)symbols.resolve("int"), $exp.result)); }
  ;
  
block
  : ^(BLOCK statement*)
  ;

expression returns [int result]
  : ^('==' op1=expression op2=expression) { if ($op1.result == $op2.result) { result = 1; } else { result = 0; } }
  | ^('!=' op1=expression op2=expression) { if ($op1.result != $op2.result) { result = 1; } else { result = 0; } }
  | ^('<' op1=expression op2=expression) { if ($op1.result < $op2.result) { result = 1; } else { result = 0; } }
  | ^('>' op1=expression op2=expression) { if ($op1.result > $op2.result) { result = 1; } else { result = 0; } }
  | ^('+' op1=expression op2=expression) { result = ($op1.result + $op2.result); }
  | ^('-' op1=expression op2=expression) { result = ($op1.result - $op2.result); }
  | ^('*' op1=expression op2=expression) { result = ($op1.result * $op2.result); }
  | ^('/' op1=expression op2=expression) { result = ($op1.result / $op2.result); }
  | VARNUM  { result = (Integer)symbols.getValue($VARNUM.text); }
  | INTEGER { result = Integer.parseInt($INTEGER.text); }
  ;