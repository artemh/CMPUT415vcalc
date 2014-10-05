tree grammar Templater;

options {
  language = Java;
  output = template;
  tokenVocab = vCalc;
  ASTLabelType = CommonTree;
}

@header {
	import helpers.*;
	
	import java.util.ArrayList;
	import java.util.HashMap;
	import java.util.List;
	import java.util.Map;
}

@members {	
  SymbolTable symtab = new SymbolTable();
  Scope currentScope = symtab.globals;
  
  InitContainer container = new InitContainer();
  
  int equalsCounter = 0;
  int notEqualsCounter = 0;
  int lessThanCounter = 0;
  int greaterThanCounter = 0;
  int ifCounter = 0;
  int loopCounter = 0;
  int counter = 0;
}

program
  : (decl+=declaration)*
    (stat+=statement)*
    -> program(container = {container}, decl = {$decl}, stat = {$stat})
  ;
  
declaration
  : ^(DECL type VARNUM exp=expression)
    {
      Type type = $type.tsym;
      VarSymbol S = new VarSymbol($VARNUM.text, type);
      currentScope.define(S);
      if (type.getName().equals("int")) {
        container.inits.put($VARNUM.text, $exp.st);
        container.intNames.add($VARNUM.text);
        container.counters.put($VARNUM.text, new Integer($exp.c));
      } else {
        container.inits.put($VARNUM.text, $exp.st);
        container.vecNames.add($VARNUM.text);
        container.counters.put($VARNUM.text, new Integer($exp.c));
      }
    }
  	-> {$type.tsym.getName().equals("int")}?  declInt(name = {$VARNUM.text})
  	// Add expression template to intInits
  	-> declVec(name = {$VARNUM.text})
  	// Add expression template to vecInits
  ;
  

statement
  : ^(IFSTAT expression .) 
  | ^(LOOPSTAT . .) 
  | ^(PRINTSTAT exp=expression)
    -> print(expr_counter={$exp.c}, expr={$exp.st})
  | ^(ASSIGN VARNUM exp=expression)
  ;
  
block
  : ^(BLOCK statement*)
  ;

expression returns [int c]
  : ^('==' expression expression)
    {
      counter++;
      $c = counter;
    }
  | ^('!=' expression expression)
    {
      counter++;
      $c = counter;
    }
  | ^('<' expression expression)
    {
      counter++;
      $c = counter;
    }
  | ^('>' expression expression)
    {
      counter++;
      $c = counter;
    }
  | ^('+' expression expression)
    {
      counter++;
      $c = counter;
    }
  | ^('-' expression expression)
    {
      counter++;
      $c = counter;
    }
  | ^('*' expression expression)
    {
      counter++;
      $c = counter;
    }
  | ^('/' expression expression)
    {
      counter++;
      $c = counter;
    }
  | ^('..' expression expression)
    {
      counter++;
      $c = counter;
    }
  | generator
    {
      counter++;
      $c = counter;
    }
  | filter
    {
      counter++;
      $c = counter;
    }
  | index
    {
      counter++;
      $c = counter;
    }
  | VARNUM 
    {
      counter++;
      $c = counter;
      Symbol symbol = currentScope.resolve($VARNUM.text);
    }
    -> {symbol.scope.equals("global")}? varnum(name = {"@" + $VARNUM.text})
    -> varnum(counter = {$c}, name = {"\%" + $VARNUM.text})
  | INTEGER
    {
      counter++;
      $c = counter;
    }
    -> integer(counter = {$c}, value = {Integer.parseInt($INTEGER.text)})
  ;
  
index 
  :	^(INDEX expression ^(INDECES (expression)+))
  ;
  
filter
  : ^(FILT VARNUM op1=expression op2=expression)
  ;
  
generator
  :^(GEN VARNUM op1=expression op2=expression)
  ;
  
type returns [Type tsym]
  : INT
      {$tsym = new BuiltInTypeSymbol("int");}
  | VECTOR
      {$tsym = new BuiltInTypeSymbol("vector");}
  ;