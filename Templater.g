tree grammar Templater;

options {
  language = Java;
  output = template;
  tokenVocab = vCalc;
  ASTLabelType = CommonTree;
}

@header {
	import helpers.*;
	import java.util.Map;
	import java.util.HashMap;
}

@members {
	Map<String, StringTemplate> intInits = new HashMap<String, StringTemplate>();
	Map<String, StringTemplate> vecInits = new HashMap<String, StringTemplate>();
}

program
  : (decl+=declaration)*
    (stat+=statement)*
    -> program(decl = {$decl}, stat = {$stat})
  ;
  
declaration
  : ^(DECL type VARNUM exp=expression)
  	-> {$type.tsym.getName().equals("int")}?  declInt(name = {$VARNUM.text})
  	// Add expression template to intInits
  	-> declVec(name = {$VARNUM.text})
  	// Add expression template to vecInits
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
  | INTEGER
  ;
  
index 
  :	^(INDEX expression ^(INDECES (expression)+))
  ;
  
filter returns [Evaluator e]
  : ^(FILT VARNUM op1=expression op2=expression)
  ;
  
generator returns [Evaluator e]
  :^(GEN VARNUM op1=expression op2=expression)
  ;
  
type returns [Type tsym]
  : INT
      {$tsym = new BuiltInTypeSymbol("int");}
  | VECTOR
      {$tsym = new BuiltInTypeSymbol("vector");}
  ;