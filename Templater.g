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
  
  public Type exprType(Type lhs, Type rhs) {
     if (lhs.getName().equals("vector") || rhs.getName().equals("vector")) {
       return new BuiltInTypeSymbol("vector");
     } else {
       return new BuiltInTypeSymbol("int");
     }
  }
  
  public String resolveVar(String v) {
    Symbol symbol = currentScope.resolve(v);
    String scope = symbol.scope.getScopeName();
    if (scope.equals("global")) {
      return "@" + v;
    } else {
      return "\%" + v;
    }
  }
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
    {
      counter++;
    }
    -> print(counter = {counter}, expr_counter = {$exp.c}, expr = {$exp.st})
  | ^(ASSIGN VARNUM exp=expression)
    {
      Symbol s = currentScope.resolve($VARNUM.text);
      Type stype = s.getType();
      Type exptype = $exp.tsym;
      if (!(stype.getName().equals(exptype.getName()))) {
        throw new RuntimeException("Error: type mismatch");
      }
      String var = resolveVar($VARNUM.text);
    }
    -> {$exp.tsym.getName().equals("vector")}? assignVec(name = {var}, expr_counter = {$exp.c}, expr = {$exp.st})
    -> assignInt(name = {var}, expr_counter = {$exp.c}, expr = {$exp.st})
  ;
  
block
  : ^(BLOCK statement*)
  ;

expression returns [int c, Type tsym]
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
  | ^('+' lhs=expression rhs=expression)
    {
      counter++;
      $c = counter;
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.getName().equals("vector") && $rhs.tsym.getName().equals("vector")}? addVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.getName().equals("vector")}? addVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.getName().equals("vector")}? addIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> addIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('-' lhs=expression rhs=expression)
    {
      counter++;
      $c = counter;
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.getName().equals("vector") && $rhs.tsym.getName().equals("vector")}? subVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.getName().equals("vector")}? subVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.getName().equals("vector")}? subIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> subIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('*' lhs=expression rhs=expression)
    {
      counter++;
      $c = counter;
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.getName().equals("vector") && $rhs.tsym.getName().equals("vector")}? mulVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.getName().equals("vector")}? mulVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.getName().equals("vector")}? mulIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> mulIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('/' lhs=expression rhs=expression)
    {
      counter++;
      $c = counter;
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.getName().equals("vector") && $rhs.tsym.getName().equals("vector")}? divVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.getName().equals("vector")}? divVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.getName().equals("vector")}? divIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> divIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
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
      String var = resolveVar($VARNUM.text);
    }
    -> varnum(counter = {$c}, name = {var})
  | INTEGER
    {
      counter++;
      $c = counter;
      $tsym = new BuiltInTypeSymbol("int");
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