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
      Type exprType = $exp.tsym;
      
  	  if (!exprType.getName().equals(type.getName())) {
  		throw new RuntimeException("Type Check error.");	
  	  }
  	  
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
  : ^(IFSTAT exp=expression 
    {
      if (!($exp.tsym.getName().equals("int"))) {
        throw new RuntimeException("Error: statement conditional must be an integer.");
      }
      counter++;
      int localCounter = counter;
      ifCounter++;
      int localIfCounter = ifCounter;
    }
     b=block) 
    -> if(counter = {localCounter}, if_counter = {localIfCounter}, expr_counter = {$exp.c}, expr={$exp.st}, b={$b.st})
  | ^(LOOPSTAT exp=expression
    {
      if (!($exp.tsym.getName().equals("int"))) {
        throw new RuntimeException("Error: statement conditional must be an integer.");
      }
      counter++;
      int localCounter = counter;
      loopCounter++;
      int localLoopCounter = loopCounter;
    }
     b=block) 
    -> loop(counter = {localCounter}, loop_counter = {localLoopCounter}, expr_counter = {$exp.c}, expr={$exp.st}, b={$b.st})
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
  : ^(BLOCK s+=statement*)
    -> block(s = {$s})
  ;

expression returns [int c, Type tsym]
  : ^('==' lhs=expression rhs=expression)
    {
      counter = counter + 2;
      $c = counter;
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.getName().equals("vector") && $rhs.tsym.getName().equals("vector")}? eqVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.getName().equals("vector")}? eqVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.getName().equals("vector")}? eqIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> eqIntInt(c1 = {counter - 1}, c2 = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('!=' lhs=expression rhs=expression)
{
      counter = counter + 2;
      $c = counter;
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.getName().equals("vector") && $rhs.tsym.getName().equals("vector")}? neVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.getName().equals("vector")}? neVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.getName().equals("vector")}? neIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> neIntInt(c1 = {counter - 1}, c2 = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('<' lhs=expression rhs=expression)
{
      counter = counter + 2;
      $c = counter;
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.getName().equals("vector") && $rhs.tsym.getName().equals("vector")}? ltVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.getName().equals("vector")}? ltVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.getName().equals("vector")}? ltIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> ltIntInt(c1 = {counter - 1}, c2 = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('>' lhs=expression rhs=expression)
{
      counter = counter + 2;
      $c = counter;
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.getName().equals("vector") && $rhs.tsym.getName().equals("vector")}? gtVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.getName().equals("vector")}? gtVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.getName().equals("vector")}? gtIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> gtIntInt(c1 = {counter - 1}, c2 = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
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
  | ^('..' lhs=expression rhs=expression)
    {
      counter++;
      $c = counter;
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
  | generator
    {
      counter++;
      $c = counter;
      $tsym = new BuiltInTypeSymbol("vector");
    }
  | filter
    {
      counter++;
      $c = counter;
      $tsym = new BuiltInTypeSymbol("vector");
    }
  | index
    {
      counter++;
      $c = counter;
      $tsym = $index.tsym;
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
  
index returns [Type tsym]
@init {
	ArrayList<Type> indexTypes = new ArrayList<Type>();
}
  :	^(INDEX expression ^(INDECES (exp=expression {indexTypes.add($exp.tsym);})+))
  {
  	$tsym = new BuiltInTypeSymbol("vector");
  	
  	for (int i = 0; i < indexTypes.size(); i++) {
  		Type t = indexTypes.get(i);
  		if (t.getName().equals("int")) {
  			if (i < indexTypes.size()-1) 
  			{
  				throw new RuntimeException("Type check error. Only vectors can be indexed.");
  			}
  			$tsym = new BuiltInTypeSymbol("int"); 
  			break;
  		}
  	}
  }
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