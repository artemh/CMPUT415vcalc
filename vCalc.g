grammar vCalc;

options {
  language = Java;
  output = AST;
  ASTLabelType = CommonTree;
}

tokens {
  DECL; ASSIGN; IFSTAT; LOOPSTAT; PRINTSTAT; BLOCK; OK; INDEX; GEN; FILT;
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
  : term (('*'^ | '/'^) term)*
  ;
  
range
  : INTEGER '..'^ INTEGER
  | INTEGER '..'^ VARNUM
  | VARNUM '..'^ INTEGER
  | VARNUM '..'^ VARNUM
  ; 
  
term
  : VARNUM
  | VARNUM '[' expression ']'
  -> ^(INDEX VARNUM expression)
  | INTEGER
  | '('! expression ')'!
  | generator
  | filter
  | range
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
  : '[' VARNUM IN e1=expression '|' e2=expression ']'
  -> ^(GEN VARNUM $e1 $e2)
  ;
  
filter
  : FILTER '(' VARNUM IN e1=expression '|' e2=expression ')'
  -> ^(FILT VARNUM $e1 $e2)
  ;
     
IF : 'if';
FI : 'fi';
LOOP : 'loop';
POOL : 'pool';
INT : 'int';
VECTOR : 'vector';
FILTER : 'filter';
PRINT : 'print';
IN : 'in';
VARNUM : ('a'..'z'|'A'..'Z') ('a'..'z'|'A'..'Z'|'0'..'9')*;
INTEGER : ('0'..'9')+;
WS : (' '|'\r'|'\n'|'\t') {$channel = HIDDEN;};