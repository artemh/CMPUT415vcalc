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
	Type intType = new BuiltInTypeSymbol("int");
	Type vecType = new BuiltInTypeSymbol("vector");
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
  		Type exprType = $exp.e.getType();
		if (!type.equals(exprType)) {
			throw new RuntimeException("Type Check error.");	
		}
  		if (type.equals(intType)) {
  			Integer value = (Integer)$exp.e.evaluate();
  			VarSymbol S = new VarSymbol($VARNUM.text, $type.tsym, value);
  			currentScope.define(S);
  		} else if (type.equals(vecType)) {
  			ArrayList<Integer> value = (ArrayList<Integer>)$exp.e.evaluate();
  			VarSymbol S = new VarSymbol($VARNUM.text, $type.tsym, value);
  			currentScope.define(S);
  		} else { 
  		  throw new RuntimeException("Invalid type " + type.getName());
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
    if (type.equals(intType)) {
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
    if (type.equals(intType)) {
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
  		if (type.equals(intType)) {
  			Integer value = (Integer)eval.evaluate(); 
  			System.out.println(value);	 
  		} else if (type.equals(vecType)) {
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
    	if (!lhsType.equals(rhsType)) {
    		System.err.println("Incompatible types for assignment: " + 
    		lhsType.getName() + "=" + rhsType.getName() + ";\n" + "in line " +
    		$VARNUM.getLine());
    		System.exit(1);
    	}
    	if (lhsType.equals(intType)) {
	    	Integer value = (Integer)eval.evaluate();
	    	currentScope.setValue(S.getName(), value);
	    } else if (lhsType.equals(vecType)) {
	      ArrayList<Integer> value = (ArrayList<Integer>)eval.evaluate();
	      currentScope.setValue(S.getName(), value);
	    } else {
	      throw new RuntimeException("Invalid type " + lhsType.getName());
	    }
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
  | index
  	{ $e = $index.e; }
  | VARNUM 
  	{ $e = new EvaluatorVar(currentScope, $VARNUM.text);	}
  | INTEGER
  	{ $e = new EvaluatorInt(Integer.parseInt($INTEGER.text)); }
  ;
  
index returns [Evaluator e]
@init {
	ArrayList<Evaluator> indList = new ArrayList<Evaluator>();
}
  :	^(INDEX op1=expression ^(INDECES (op2=expression {indList.add($op2.e);})+ ))
    { $e = new EvaluatorIndex($op1.e, indList); }
  ;
  
filter returns [Evaluator e]
@init {
currentScope = new LocalScope(currentScope);
}
@after {
currentScope = currentScope.getEnclosingScope();
}
  : ^(FILT VARNUM {currentScope.define(new VarSymbol($VARNUM.text, intType, 0));} op1=expression op2=expression)
    { 
    	$e = new EvaluatorFilter(currentScope, $VARNUM.text, $op1.e, $op2.e); 
    }
  ;
  
generator returns [Evaluator e]
@init {
currentScope = new LocalScope(currentScope);
}
@after {
currentScope = currentScope.getEnclosingScope();
}
  :^(GEN VARNUM {currentScope.define(new VarSymbol($VARNUM.text, intType, 0));} op1=expression op2=expression)
    { 
    	$e = new EvaluatorGenerator(currentScope, $VARNUM.text, $op1.e, $op2.e); 
    }
  ;
  
type returns [Type tsym]
  : INT
  	{$tsym = intType;}
  | VECTOR
  	{$tsym = vecType;}
  ;