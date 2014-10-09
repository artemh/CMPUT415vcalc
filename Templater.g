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
  int rangeCounter = 0;
  int counter = 0;
  int fgc = 0;

  Type intType = new BuiltInTypeSymbol("int");
  Type vecType = new BuiltInTypeSymbol("vector");

  public Type exprType(Type lhs, Type rhs) {
     if (lhs.equals(vecType) || rhs.equals(vecType)) {
       return vecType;
     } else {
       return intType;
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

  	  if (!exprType.equals(type)) {
  	    throw new RuntimeException("Type Check error.");
  	  }

      if (type.equals(intType)) {
        container.inits.put($VARNUM.text, $exp.st);
        container.types.put($VARNUM.text, false);
        container.names.add($VARNUM.text);
        container.counters.put($VARNUM.text, new Integer($exp.c));
      } else if (type.equals(vecType)) {
        container.inits.put($VARNUM.text, $exp.st);
        container.types.put($VARNUM.text, true);
        container.names.add($VARNUM.text);
        container.counters.put($VARNUM.text, new Integer($exp.c));
      } else {
        throw new RuntimeException("Invalid type " + type.getName());
      }
    }
  	-> {type.equals(intType)}?  declInt(name = {$VARNUM.text})
  	// Add expression template to intInits
  	-> declVec(name = {$VARNUM.text})
  	// Add expression template to vecInits
  ;


statement
  : ^(IFSTAT exp=expression
    {
      if (!($exp.tsym.equals(intType))) {
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
      if (!($exp.tsym.equals(intType))) {
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
    -> {$exp.tsym.equals(vecType)}? printVec(counter = {counter}, expr_counter = {$exp.c}, expr = {$exp.st})
    -> printInt(counter = {counter}, expr_counter = {$exp.c}, expr = {$exp.st})
  | ^(ASSIGN VARNUM exp=expression)
    {
      Symbol s = currentScope.resolve($VARNUM.text);
      Type stype = s.getType();
      Type exptype = $exp.tsym;
      if (!(stype.equals(exptype))) {
        throw new RuntimeException("Error: type mismatch");
      }
      String var = resolveVar($VARNUM.text);
    }
    -> {$exp.tsym.equals(vecType)}? assignVec(name = {var}, expr_counter = {$exp.c}, expr = {$exp.st})
    -> assignInt(name = {var}, expr_counter = {$exp.c}, expr = {$exp.st})
  ;

block
  : ^(BLOCK s+=statement*)
    -> block(s = {$s})
  ;

expression returns [int c, Type tsym, ArrayList<String> varNames]
@init { ArrayList<String> varNamesList = new ArrayList<String>(); }
@after { $varNames = varNamesList; }
  : ^('==' lhs=expression rhs=expression)
    {
      counter++;
      $c = counter;
      for(String str:$lhs.varNames) {varNamesList.add(str);}
      for(String str:$rhs.varNames) {varNamesList.add(str);}
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.equals(vecType) && $rhs.tsym.equals(vecType)}? eqVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.equals(vecType)}? eqVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.equals(vecType)}? eqIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> eqIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('!=' lhs=expression rhs=expression)
{
      counter++;
      $c = counter;
      for(String str:$lhs.varNames) {varNamesList.add(str);}
      for(String str:$rhs.varNames) {varNamesList.add(str);}
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.equals(vecType) && $rhs.tsym.equals(vecType)}? neVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.equals(vecType)}? neVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.equals(vecType)}? neIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> neIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('<' lhs=expression rhs=expression)
{
      counter++;
      $c = counter;
      for(String str:$lhs.varNames) {varNamesList.add(str);}
      for(String str:$rhs.varNames) {varNamesList.add(str);}
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.equals(vecType) && $rhs.tsym.equals(vecType)}? ltVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.equals(vecType)}? ltVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.equals(vecType)}? ltIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> ltIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('>' lhs=expression rhs=expression)
{
      counter++;
      $c = counter;
      for(String str:$lhs.varNames) {varNamesList.add(str);}
      for(String str:$rhs.varNames) {varNamesList.add(str);}
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.equals(vecType) && $rhs.tsym.equals(vecType)}? gtVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.equals(vecType)}? gtVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.equals(vecType)}? gtIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> gtIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('+' lhs=expression rhs=expression)
    {
      counter++;
      $c = counter;
      for(String str:$lhs.varNames) {varNamesList.add(str);}
      for(String str:$rhs.varNames) {varNamesList.add(str);}
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.equals(vecType) && $rhs.tsym.equals(vecType)}? addVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.equals(vecType)}? addVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.equals(vecType)}? addIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> addIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('-' lhs=expression rhs=expression)
    {
      counter++;
      $c = counter;
      for(String str:$lhs.varNames) {varNamesList.add(str);}
      for(String str:$rhs.varNames) {varNamesList.add(str);}
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.equals(vecType) && $rhs.tsym.equals(vecType)}? subVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.equals(vecType)}? subVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.equals(vecType)}? subIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> subIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('*' lhs=expression rhs=expression)
    {
      counter++;
      $c = counter;
      for(String str:$lhs.varNames) {varNamesList.add(str);}
      for(String str:$rhs.varNames) {varNamesList.add(str);}
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.equals(vecType) && $rhs.tsym.equals(vecType)}? mulVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.equals(vecType)}? mulVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.equals(vecType)}? mulIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> mulIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('/' lhs=expression rhs=expression)
    {
      counter++;
      $c = counter;
      for(String str:$lhs.varNames) {varNamesList.add(str);}
      for(String str:$rhs.varNames) {varNamesList.add(str);}
      $tsym = exprType($lhs.tsym, $rhs.tsym);
    }
    -> {$lhs.tsym.equals(vecType) && $rhs.tsym.equals(vecType)}? divVecVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$lhs.tsym.equals(vecType)}? divVecInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> {$rhs.tsym.equals(vecType)}? divIntVec(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
    -> divIntInt(counter = {counter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | ^('..' lhs=expression rhs=expression)
    {
      counter = counter + 2;
      rangeCounter++;
      $c = counter;
      $tsym = vecType;
      Type lhstype = $lhs.tsym;
      Type rhstype = $rhs.tsym;
      if (!(lhstype.equals(intType)) || !(rhstype.equals(intType))) {
        throw new RuntimeException("Type check error. Range indexes must be integers.");
      }
    }
    -> range(c1 = {counter - 1}, c2 = {counter}, rc = {rangeCounter}, lhs_counter = {$lhs.c}, lhs = {$lhs.st}, rhs_counter = {$rhs.c}, rhs = {$rhs.st})
  | generator
    {
      $tsym = vecType;
      $c = $generator.c;
    } -> write(input = {$generator.st})
  | filter
    {
      $tsym = vecType;
      $c = $filter.c;
    } -> write(input = {$filter.st})
  | index
    {
      $tsym = $index.tsym;
      $c = $index.c;
    } -> write(input = {$index.st})
  | VARNUM
    {
      varNamesList.add($VARNUM.text);  
      counter++;
      $c = counter;
      Boolean flag = false;
      int varcounter = 0;
      Symbol symbol = currentScope.resolve($VARNUM.text);
      if (symbol.value != null) {
        int value = (Integer)symbol.value;
        if (value != 0) {
          flag = true;
          varcounter = value;
        }
      }
      if (symbol.getType().equals(intType)) {
        $tsym = intType;
      } else if (symbol.getType().equals(vecType)) {
        $tsym = vecType;
      } else {
        throw new RuntimeException("Invalid type");
      }
      String scope = symbol.scope.getScopeName();
      String name = resolveVar($VARNUM.text);
    }
    -> {symbol.getType().equals(vecType) && flag}? varnumVec(counter = {$c}, name = {name}, varcounter = {varcounter})
    -> {symbol.getType().equals(vecType)}? varnumVec(counter = {$c}, name = {name})
    -> {flag}? varnumInt(counter = {$c}, name = {name}, varcounter = {varcounter})
    -> varnumInt(counter = {$c}, name = {name})
  | INTEGER
    {
      counter++;
      $c = counter;
      $tsym = intType;
    }
    -> integer(counter = {$c}, value = {Integer.parseInt($INTEGER.text)})
  ;

index returns [Type tsym, int c]
@init {
	ArrayList<Type> indexTypes = new ArrayList<Type>();
}
  :	^(INDEX e1=expression ^(INDECES (exp=expression {indexTypes.add($exp.tsym);})+))
  {
  	$tsym = vecType;
  	counter++;
    $c = counter;
  	for (int i = 0; i < indexTypes.size(); i++) {
  		Type t = indexTypes.get(i);
  		if (t.equals(intType)) {
  			if (i < indexTypes.size()-1)
  			{
  				throw new RuntimeException("Type check error. Only vectors can be indexed.");
  			}
  			$tsym = intType;
  			break;
  		}
  	}
  }
  -> {indexTypes.get(0).equals(vecType)}? indexVec(counter = {$c}, lhs_counter = {$e1.c}, lhs = {$e1.st}, rhs_counter = {$exp.c}, rhs = {$exp.st})
  -> indexInt(counter = {$c}, lhs_counter = {$e1.c}, lhs = {$e1.st}, rhs_counter = {$exp.c}, rhs = {$exp.st})
  ;

filter returns [int c]
@init {
currentScope = new LocalScope(currentScope);
}
@after {
currentScope = currentScope.getEnclosingScope();
}
  : ^(FILT VARNUM { fgc++; currentScope.define(new VarSymbol($VARNUM.text, intType, fgc)); } op1=expression op2=expression) { counter++; $c = counter; }
    -> filter(counter = {counter}, var = {$VARNUM.text}, d_counter = {$op1.c}, d = {$op1.st}, exp_counter = {$op2.c}, exp = {$op2.st}, fgc = {fgc})
  ;

generator returns [int c]
@init {
currentScope = new LocalScope(currentScope);
}
@after {
currentScope = currentScope.getEnclosingScope();
}
  : ^(GEN VARNUM { fgc++; currentScope.define(new VarSymbol($VARNUM.text, vecType, fgc)); } op1=expression op2=expression)
  {
    counter++;
    $c = counter;
    boolean flag = false;
    ArrayList<String> list = $op2.varNames;
    for (String name : list) {
        if(name.equals($VARNUM.text)) { flag = true; } 
    }
    if (flag == true) {
      counter--;
      $c = counter;
    }
  }
    -> {flag}? generator(counter = {counter}, var = {$VARNUM.text}, d_counter = {$op1.c}, d = {$op1.st}, exp_counter = {$op2.c}, exp = {$op2.st}, flag = {";"}, fgc = {fgc})
    -> generator(counter = {counter}, var = {$VARNUM.text}, d_counter = {$op1.c}, d = {$op1.st}, exp_counter = {$op2.c}, exp = {$op2.st}, flag = {""}, fgc = {fgc})
  ;

type returns [Type tsym]
  : INT
      {$tsym = intType;}
  | VECTOR
      {$tsym = vecType;}
  ;
