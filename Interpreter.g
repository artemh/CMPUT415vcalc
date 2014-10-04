tree grammar Interpreter;

options {
  language = Java;
  tokenVocab = vCalc;
  ASTLabelType = CommonTree;
}

@header {
	import helpers.*;
}

@members {
	SymbolTable symtab = new SymbolTable();
	Scope currentScope = symtab.globals;
}

program
  : (declaration)*
    (statement)*
  ;
  
declaration
  : ^(DECL type VARNUM exp=expression)
  	// Call evaluate on expression's evaluator and declare the variable in the current scope
  	{
  		Integer value = (Integer)$exp.e.evaluate();
  		VarSymbol S = new VarSymbol($VARNUM.text, $type.tsym, value);
  		currentScope.define(S);
  	}
  ;
  
// The idea on how to do if and loop statements in the interpreter
// was based on the code on the following page:
//
// http://www.linguamantra.org/wiki/display/CS652/Tree-based+interpreters
statement
  : ^(IFSTAT exp=expression { int block = input.index(); } .) 
  {
    int next = input.index();
    // need to do type checking here
    int cond = (Integer)$exp.e.evaluate();
    if (cond != 0) {
      input.seek(block);
      block();
    }
    input.seek(next);
   }
  // for expr, ANTLR places that code immediately after the LOOPSTAT token,
  // but there is an additional <DOWN> token before the position we actually
  // want to be at, needing the + 1
  | ^(LOOPSTAT { int expr = input.index() + 1; } exp=expression { int block = input.index(); } .) 
  {
    int next = input.index();
    input.seek(expr);
    // need to do type checking here
    int cond = (Integer)expression().evaluate();
    while (cond != 0) {
      input.seek(block);
      block();
      input.seek(expr);
      cond = (Integer)expression().evaluate();
    }
    input.seek(next);
  }
  | ^(PRINTSTAT exp=expression)
  	//Call evaluate on expression's evaluator and print the result
  	{
  		Evaluator eval = $exp.e;
  		Type type = eval.getType();
  		if (type.getName().equals("int")) {
  			Integer value = (Integer)eval.evaluate(); 
  			System.out.println(value);	 
  		} else if (type.getName().equals("vector")) {
  			System.out.println("[ " + "Can't print vectors yet" + " ]");
  		}
  	}
  | ^(ASSIGN VARNUM exp=expression)
    //Call evaluate on expression's evaluator, check type and assign to variable
    {
    	Evaluator eval = $exp.e;
    	Symbol S = currentScope.resolve($VARNUM.text);
    	// Perform type checking
    	Type lhsType = S.getType();
    	Type rhsType = eval.getType();
    	if (!lhsType.getName().equals(rhsType.getName())) {
    		System.err.println("Incompatible types for assignment: " + 
    		lhsType.getName() + "=" + rhsType.getName() + ";\n" + "in line " +
    		$VARNUM.getLine());
    		System.exit(1);
    	}
    	// For now, assume int
    	Integer value = (Integer)eval.evaluate();
    	((BaseScope)currentScope).setValue(S.getName(), value);
    }
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
    { $e = new EvaluatorIndex($op1.e, $op2.e); }
  | VARNUM 
  	// Resolve the variable to a value in the current scope,
  	// get it's type and pass to the appropriate evaluator.
  	{
  		Symbol S = currentScope.resolve($VARNUM.text); 	// Need this for type checking
  		Integer value = (Integer)currentScope.getValue($VARNUM.text);
  		$e = new EvaluatorInt(value);
  	}
    // OR { $e = new EvaluatorVec(VARNUM); } 
  | INTEGER
  	{ $e = new EvaluatorInt(Integer.parseInt($INTEGER.text)); }
  ;
  
type returns [Type tsym]
  : INT
  	{$tsym = (Type)currentScope.resolve($INT.text);}
  | VECTOR
  	{$tsym = (Type)currentScope.resolve($VECTOR.text);}
  ;