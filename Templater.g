tree grammar Templater;

options {
  language = Java;
  output = template;
  tokenVocab = sCalc;
  ASTLabelType = CommonTree;
}

@header {
  import java.util.LinkedHashMap;
}

@members {
  int comp = 0; 
  int ifstat = 0;
  int loopstat = 0;
  ArrayList<String> entries = new ArrayList<String>();
  LinkedHashMap<String, StringTemplate> decl = new LinkedHashMap<String, StringTemplate>();
}

program
  : (d+=declaration)*
    (s+=statement)* 
  -> program(d={$d}, s={$s}, l={entries}, m={decl})
  ;
  
declaration
  : ^(DECL v=VARNUM e=expression { entries.add($v.text); decl.put($v.text, $e.st); })
  -> declaration(v={$v})
  ;

statement
  : ^(IFSTAT exp=expression b=block) { ifstat++; } 
  -> if(b={b}, i={ifstat}, e={exp})
  | ^(LOOPSTAT exp=expression b=block) { loopstat++; } 
  -> loop(b={b}, l={loopstat}, e={exp})
  | ^(PRINTSTAT exp=expression)
  -> print(e={exp})
  | ^(ASSIGN VARNUM exp=expression)
  -> assign(e={exp}, v={$VARNUM.text})
  ;
  
block
  : ^(BLOCK s+=statement*)
  -> block(s={$s})
  ;

expression
  : ^('==' { comp++; } op1=expression op2=expression)
  -> expreq(e1={op1}, e2={op2}, c={comp})
  | ^('!=' { comp++; } op1=expression op2=expression)
  -> exprneq(e1={op1}, e2={op2}, c={comp})
  | ^('<' { comp++; } op1=expression op2=expression)
  -> exprlt(e1={op1}, e2={op2}, c={comp})
  | ^('>' { comp++; } op1=expression op2=expression)
  -> exprgt(e1={op1}, e2={op2}, c={comp})
  | ^('+' op1=expression op2=expression)
  -> expradd(e1={op1}, e2={op2})
  | ^('-' op1=expression op2=expression)
  -> exprsub(e1={op1}, e2={op2})
  | ^('*' op1=expression op2=expression)
  -> exprmul(e1={op1}, e2={op2})
  | ^('/' op1=expression op2=expression)
  -> exprdiv(e1={op1}, e2={op2})
  | VARNUM 
  -> exprvar(v={$VARNUM.text})
  | INTEGER
  -> exprint(v1={String.format("\%08x", Integer.parseInt($INTEGER.text)).substring(0, 4)}, v2={String.format("\%08X", Integer.parseInt($INTEGER.text)).substring(4, 8)})
  ;