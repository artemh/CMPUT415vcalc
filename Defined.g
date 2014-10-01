tree grammar Defined;

options {
  language = Java;
  filter = true;
  backtrack = true;
  tokenVocab = sCalc;
  ASTLabelType = CommonTree;
}

@members {
  public static SymbolTable symbols = new SymbolTable();
}

topdown: define;
bottomup: check;

define
  : ^(DECL VARNUM .) {
    if (symbols.resolve($VARNUM.text) == null) {
      symbols.define(new VarSymbol($VARNUM.text, (Type)symbols.resolve("int")));
    } else {
      System.err.print("Error: variable " + $VARNUM.text + " declared more than once");
      System.exit(1);
    }
  }
  ;

check
  : VARNUM {
      if (symbols.resolve($VARNUM.text) == null) {
         System.err.print("Undefined variable " + $VARNUM.text);
         System.exit(1);
      }
    }
  ;
