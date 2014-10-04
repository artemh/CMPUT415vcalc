tree grammar Interpreter;

options {
  language = Java;
  tokenVocab = vCalc;
  ASTLabelType = CommonTree;
}

@header {
	import helpers.*;
}

program
  : (declaration)*
    (statement)*
  ;
  
declaration
  : ^(DECL type VARNUM exp=expression)
  	// Call evaluate on expression's evaluator and declare the variable in the current scope
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
  	//Call evaluate on expression's evaluator and print the result
  | ^(ASSIGN VARNUM exp=expression)
    //Call evaluate on expression's evaluator and assign to variable
  ;
  
block
  : ^(BLOCK statement*)
  ;

expression returns [Evaluator e]
  : ^('==' op1=expression op2=expression)
   	{ $e = new EvaluatorEquals($op1.e, $op2.e); }
  | ^('!=' op1=expression op2=expression)
   	{ $e = new EvaluatorNotEquals($op1.e, $op2.e); }
  | ^('<' op1=expression op2=expression)
   	{ $e = new EvaluatorLess($op1.e, $op2.e); }
  | ^('>' op1=expression op2=expression)
  	{ $e = new EvaluatorGreater($op1.e, $op2.e); }
  | ^('+' op1=expression op2=expression)
  	{ $e = new EvaluatorPlus($op1.e, $op2.e); }
  | ^('-' op1=expression op2=expression)
  	{ $e = new EvaluatorMinus($op1.e, $op2.e); }
  | ^('*' op1=expression op2=expression)
  	{ $e = new EvaluatorMult($op1.e, $op2.e); }
  | ^('/' op1=expression op2=expression)
  	{ $e = new EvaluatorDivide($op1.e, $op2.e); }
  | ^('..' op1=expression op2=expression)
  	{ $e = new EvaluatorRange($op1.e, $op2.e); }
  | ^(GEN VARNUM op1=expression op2=expression)
  	// push new scope on the stack, define VARNUM, return evaluator
    { $e = new EvaluatorGenerator($op1.e, $op2.e); }
    // After, pop the local scope from the stack
  | ^(FILT VARNUM op1=expression op2=expression)
    // push new scope on the stack, define VARNUM, return evaluator
    { $e = new EvaluatorFilter($VARNUM.text, $op1.e, $op2.e); }
    // After, pop the local scope from the stack
  | ^(INDEX op1=expression op2=expression)
    { $e = new EvaluatorIndex($op1.e, $op.e); }
  | VARNUM 
  	// Resolve the variable to a value in the current scope,
  	// get it's type and pass to the appropriate evaluator.
    { $e = new EvaluatorInt(VARNUM); }
    { $e = new EvaluatorVec(VARNUM); } //OR
  | INTEGER
  	{ $e = new EvaluatorInt(INTEGER); }
  ;
  
type
  : INT
  | VECTOR
  ;