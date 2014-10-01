grammar vCalc;

options {
  language = Java;
  output = AST;
  ASTLabelType = CommonTree;
}

tokens {
  DECL; ASSIGN; IFSTAT; LOOPSTAT; PRINTSTAT; BLOCK; OK;
}

@members {
    public void displayRecognitionError(String[] tokenNames,
                                        RecognitionException e) {
        String hdr = getErrorHeader(e);
        String msg = getErrorMessage(e, tokenNames);
        System.err.println(hdr + ": " + msg);
        System.exit(1);
    }
}

program
  : (declaration)*
    (statement)*
    EOF!
  ;
  
type
  : INT
  | VECTOR
  ;
  
declaration
  : type VARNUM '=' expression ';'
  -> ^(DECL type VARNUM expression)
  ;
  
assignment
  : VARNUM '=' expression ';'
  -> ^(ASSIGN VARNUM expression)
  ;
  
expression
  : relation (('=='^ | '!='^) relation)*
  ;
  
relation
  : addition (('<'^ | '>'^) addition)*
  ;

addition
  : multiplication (('+'^ | '-'^) multiplication)*
  ;
  
multiplication
  : range (('*'^ | '/'^) range)*
  ;
  
range
  : term ('..'^ term)?
  ;
  
term
  : VARNUM
  | VARNUM '[' expression ']'
  | INTEGER
  | '('! expression ')'!
  | generator
  | filter
  ;
  
statement
  : ifstatement
  | loopstatement
  | printstatement
  | assignment
  ;

ifstatement
  : IF '(' expression ')' (statement)* FI ';'
  -> ^(IFSTAT expression ^(BLOCK statement*))
  ;

loopstatement
  : LOOP '(' expression ')' (statement)* POOL ';'
  -> ^(LOOPSTAT expression ^(BLOCK statement*))
  ;

printstatement
  : PRINT '(' expression ')' ';'
  -> ^(PRINTSTAT expression)
  ;
  
generator
  : '[' VARNUM 'in' expression '|' expression ']'
  ;
  
filter
  : FILTER '(' VARNUM 'in' expression '|' expression ')'
  ;
     
IF : 'if';
FI : 'fi';
LOOP : 'loop';
POOL : 'pool';
INT : 'int';
VECTOR : 'vector';
FILTER : 'filter';
PRINT : 'print';
VARNUM : ('a'..'z'|'A'..'Z') ('a'..'z'|'A'..'Z'|'0'..'9')*;
INTEGER : ('0'..'9')+;
WS : (' '|'\r'|'\n'|'\t') {$channel = HIDDEN;};