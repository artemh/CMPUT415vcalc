tree grammar Validator;

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
  {
  	if(currentScope.resolve($VARNUM.text) != null) {
  		throw new RuntimeException("line " + $VARNUM.getLine() + ":"
  		+ "\"" + $VARNUM.text  + "\"" + "redeclares a variable.");
  	}
  	currentScope.define(new VarSymbol($VARNUM.text, (Type)currentScope.resolve($type.text))); 
  }
  ;
  

statement
  : ^(IFSTAT expression .) 
  | ^(LOOPSTAT . .) 
  | ^(PRINTSTAT exp=expression)
  | ^(ASSIGN VARNUM exp=expression)
  ;
  
block
  : ^(BLOCK statement*)
  ;

expression 
  : ^('==' expression expression)
  | ^('!=' expression expression)
  | ^('<' expression expression)
  | ^('>' expression expression)
  | ^('+' expression expression)
  | ^('-' expression expression)
  | ^('*' expression expression)
  | ^('/' expression expression)
  | ^('..' expression expression)
  | generator
  | filter
  | index
  | VARNUM 
  {
  	Symbol S = currentScope.resolve($VARNUM.text);
  	if (S == null) 
  		{
  			throw new RuntimeException("line " + $VARNUM.getLine() + ":"
  			+ "\"" + $VARNUM.text  + "\"" + "undeclared variable.");
  		}
  }
  | INTEGER
  ;
  
index 
  :	^(INDEX expression ^(INDECES (expression)+))
  ;
  
filter returns [Evaluator e]
@init {
currentScope = new LocalScope(currentScope);
}
@after {
currentScope = currentScope.getEnclosingScope();
}
  : ^(FILT VARNUM {currentScope.define(new VarSymbol($VARNUM.text, new BuiltInTypeSymbol("int"), 0));} op1=expression op2=expression)
  ;
  
generator returns [Evaluator e]
@init {
currentScope = new LocalScope(currentScope);
}
@after {
currentScope = currentScope.getEnclosingScope();
}
  :^(GEN VARNUM {currentScope.define(new VarSymbol($VARNUM.text, new BuiltInTypeSymbol("int"), 0));} op1=expression op2=expression)
  ;
  
type 
  : INT
  | VECTOR
  ;
