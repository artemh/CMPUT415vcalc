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
    {
      counter++;
    }
    -> print(counter = {counter}, expr_counter = {$exp.c}, expr = {$exp.st})
  | ^(ASSIGN VARNUM exp=expression)
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
      Type lhstype = $lhs.tsym;
      Type rhstype = $rhs.tsym;
      if (lhstype.getName().equals("vector") || rhstype.getName().equals("vector")) {
        $tsym = new BuiltInTypeSymbol("vector");
      } else {
        $tsym = new BuiltInTypeSymbol("int");
      }
    }
    -> {lhstype.getName().equals("vector") && rhstype.getName().equals("vector")}? addVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {lhstype.getName().equals("vector")}? addVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {rhstype.getName().equals("vector")}? addIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> addIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('-' lhs=expression rhs=expression)
    {
      counter++;
      $c = counter;
      Type lhstype = $lhs.tsym;
      Type rhstype = $rhs.tsym;
      if (lhstype.getName().equals("vector") || rhstype.getName().equals("vector")) {
        $tsym = new BuiltInTypeSymbol("vector");
      } else {
        $tsym = new BuiltInTypeSymbol("int");
      }
    }
    -> {lhstype.getName().equals("vector") && rhstype.getName().equals("vector")}? subVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {lhstype.getName().equals("vector")}? subVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {rhstype.getName().equals("vector")}? subIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> subIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('*' lhs=expression rhs=expression)
    {
      counter++;
      $c = counter;
      Type lhstype = $lhs.tsym;
      Type rhstype = $rhs.tsym;
      if (lhstype.getName().equals("vector") || rhstype.getName().equals("vector")) {
        $tsym = new BuiltInTypeSymbol("vector");
      } else {
        $tsym = new BuiltInTypeSymbol("int");
      }
    }
    -> {lhstype.getName().equals("vector") && rhstype.getName().equals("vector")}? mulVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {lhstype.getName().equals("vector")}? mulVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {rhstype.getName().equals("vector")}? mulIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> mulIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('/' lhs=expression rhs=expression)
    {
      counter++;
      $c = counter;
      Type lhstype = $lhs.tsym;
      Type rhstype = $rhs.tsym;
      if (lhstype.getName().equals("vector") || rhstype.getName().equals("vector")) {
        $tsym = new BuiltInTypeSymbol("vector");
      } else {
        $tsym = new BuiltInTypeSymbol("int");
      }
    }
    -> {lhstype.getName().equals("vector") && rhstype.getName().equals("vector")}? divVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {lhstype.getName().equals("vector")}? divVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {rhstype.getName().equals("vector")}? divIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
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
      Symbol symbol = currentScope.resolve($VARNUM.text);
      if (symbol.getType().getName().equals("int")) {
        $tsym = new BuiltInTypeSymbol("int");
      } else if (symbol.getType().getName().equals("vector")) {
        $tsym = new BuiltInTypeSymbol("vector");
      } else {
        throw new RuntimeException("Invalid type");
      }
      String scope = symbol.scope.getScopeName();
    }
    -> {scope.equals("global")}? varnum(counter = {$c}, name = {"@" + $VARNUM.text})
    -> varnum(counter = {$c}, name = {"\%" + $VARNUM.text})
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