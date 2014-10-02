tree grammar Templater;

options {
  language = Java;
  output = template;
  tokenVocab = vCalc;
  ASTLabelType = CommonTree;
}

program
  : (d+=declaration)*
    (s+=statement)* 
  ;
  
declaration
  : ^(DECL v=VARNUM e=expression)
  ;

statement
  : ^(IFSTAT exp=expression b=block)
  | ^(LOOPSTAT exp=expression b=block)
  | ^(PRINTSTAT exp=expression)
  | ^(ASSIGN VARNUM exp=expression)
  ;
  
block
  : ^(BLOCK s+=statement*)
  ;

expression
  : ^('==' op1=expression op2=expression)
  | ^('!=' op1=expression op2=expression)
  | ^('<' op1=expression op2=expression)
  | ^('>' op1=expression op2=expression)
  | ^('+' op1=expression op2=expression)
  | ^('-' op1=expression op2=expression)
  | ^('*' op1=expression op2=expression)
  | ^('/' op1=expression op2=expression)
  | ^('..' op1=expression op2=expression)
  | ^(GEN VARNUM op1=expression op2=expression)
  | ^(FILT VARNUM op1=expression op2=expression)
  | ^(INDEX VARNUM op=expression)
  | VARNUM 
  | INTEGER
  ;