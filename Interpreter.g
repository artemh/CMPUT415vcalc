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
  		Type type = $type.tsym;
  		if (type.getName().equals("int")) {
  			Integer value = (Integer)$exp.e.evaluate();
  			VarSymbol S = new VarSymbol($VARNUM.text, $type.tsym, value);
  			currentScope.define(S);
  		} else {
  			ArrayList<Integer> value = (ArrayList<Integer>)$exp.e.evaluate();
  			VarSymbol S = new VarSymbol($VARNUM.text, $type.tsym, value);
  			currentScope.define(S);
  		}
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
    Evaluator eval = $exp.e;
    Type type = eval.getType();
    if (type.getName().equals("int")) {
	    int cond = (Integer)eval.evaluate();
	    if (cond != 0) {
	      input.seek(block);
	      block();
	    }
	    input.seek(next);
	  } else {
	    System.err.println("Type check error. Conditional must be an integer!");
	    System.exit(1);
	  }
	}
  // for expr, ANTLR places that code immediately after the LOOPSTAT token,
  // but there is an additional <DOWN> token before the position we actually
  // want to be at, needing the + 1
  | ^(LOOPSTAT { int expr = input.index() + 1; } . { int block = input.index(); } .) 
  {
    int next = input.index();
    input.seek(expr);
    // need to do type checking here
    Evaluator eval = expression();
    Type type = eval.getType();
    if (type.getName().equals("int")) {
      int cond = (Integer)eval.evaluate();
	    while (cond != 0) {
	      input.seek(block);
	      block();
	      input.seek(expr);
	      cond = (Integer)expression().evaluate();
	    }
	    input.seek(next);
	  } else {
	    System.err.println("Type check error. Conditional must be an integer!");
      System.exit(1);
    }
  }
  | ^(PRINTSTAT exp=expression)
  	//Call evaluate on expression's evaluator and print the result
  	{
  		Evaluator eval = $exp.e;
  		Type type = eval.getType();
  		if (type.getName().equals("int")) {
  			Integer value = (Integer)eval.evaluate(); 
  			System.out.println(value + "\n");	 
  		} else if (type.getName().equals("vector")) {
  		  	ArrayList<Integer> vector = (ArrayList<Integer>)eval.evaluate(); 
  			System.out.print("[ ");
  			for (Integer i : vector) { System.out.print(i + " "); }
  			System.out.print("]\n");
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
  | generator
  	{ $e = $generator.e; }
  | filter
  	{ $e = $filter.e; }
  | ^(INDEX op1=expression op2=expression)
    { $e = new EvaluatorIndex($op1.e, $op2.e); }
  | VARNUM 
  	// Resolve the variable to a value in the current scope,
  	// get it's type and create the type appropriate evaluator.
  	{
  		Symbol S = currentScope.resolve($VARNUM.text); 	// Need this for type checking
  		Type type = S.getType();
  		if (type.getName().equals("int")) {
  			Integer value = (Integer)currentScope.getValue($VARNUM.text);
  			$e = new EvaluatorInt(value);
  		} else {
  			ArrayList<Integer> value = (ArrayList<Integer>)currentScope.getValue($VARNUM.text);
  			$e = new EvaluatorVec(value);
  		}
  	}
  | INTEGER
  	{ $e = new EvaluatorInt(Integer.parseInt($INTEGER.text)); }
  ;
  
filter returns [Evaluator e]
@init {
currentScope = new LocalScope(currentScope);
}
@after {
currentScope = currentScope.getEnclosingScope();
}
  : ^(FILT VARNUM domain=expression cond=expression)
    { 
    	Type type = new BuiltInTypeSymbol("int");
  		VarSymbol S = new VarSymbol($VARNUM.text, type);
  		currentScope.define(S);
    	$e = new EvaluatorFilter($VARNUM.text, $domain.e, $cond.e, (BaseScope)currentScope); 
    }
  ;
  
generator returns [Evaluator e]
@init {
currentScope = new LocalScope(currentScope);
}
@after {
currentScope = currentScope.getEnclosingScope();
}
  :^(GEN VARNUM op1=expression op2=expression)
  	// push new scope on the stack, define VARNUM, return evaluator
    { $e = new EvaluatorGenerator($op1.e, $op2.e); }
    // After, pop the local scope from the stack
  ;
  
type returns [Type tsym]
  : INT
  	{$tsym = (Type)currentScope.resolve($INT.text);}
  | VECTOR
  	{$tsym = (Type)currentScope.resolve($VECTOR.text);}
  ;