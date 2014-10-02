tree grammar Interpreter;

options {
  language = Java;
  tokenVocab = vCalc;
  ASTLabelType = CommonTree;
}

program
  : (declaration)*
    (statement)*
  ;
  
declaration
  : ^(DECL type VARNUM exp=expression)
  ;
  
// The idea on how to do if and loop statements in the interpreter
// was based on the code on the following page:
//
// http://www.linguamantra.org/wiki/display/CS652/Tree-based+interpreters
statement
  : ^(IFSTAT exp=expression { int block = input.index(); } .) {
    int next = input.index();
    // need to do type checking here
    int cond = $exp.e.evaluate();
    if (cond != 0) {
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
    // need to do type checking here
    int cond = expression().evaluate();
    while (cond != 0) {
      input.seek(block);
      block();
      input.seek(expr);
      cond = expression().evaluate();
    }
    input.seek(next);
  }
  | ^(PRINTSTAT exp=expression)
  | ^(ASSIGN VARNUM exp=expression)
  ;
  
block
  : ^(BLOCK statement*)
  ;

expression returns [Evaluator e]
  : ^('==' op1=expression op2=expression)
  | ^('!=' op1=expression op2=expression)
  | ^('<' op1=expression op2=expression)
  | ^('>' op1=expression op2=expression)
  | ^('+' op1=expression op2=expression)
  | ^('-' op1=expression op2=expression)
  | ^('*' op1=expression op2=expression)
  | ^('/' op1=expression op2=expression)
  | ^('..' op1=expression op2=expression)
  | ^(GEN VARNUM op1=expression op2=expression)
  | ^(FILT VARNUM op1=expression op2=expression)
  | ^(INDEX VARNUM op=expression)
  | VARNUM 
  | INTEGER
  ;
  
type
  : INT
  | VECTOR
  ;