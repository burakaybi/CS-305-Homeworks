%{
#include <stdio.h>
    
void yyerror (const char *s) /* Called by yyparse on error */ {
    
}
%}
%token tIF tENDIF tEQ tLT tGT tNE tLTE tGTE tIDENT tINTNUM tREALNUM tINTTYPE tINTVECTORTYPE tINTMATRIXTYPE tREALTYPE tREALVECTORTYPE tREALMATRIXTYPE tAND tOR
%start prog
%left '+' '-'
%left '/' '*'
%left tDOTPROD
%left tTRANSPOSE
%left tOR
%left tAND
%%
prog: stmtlist
;
stmtlist: stmt | stmtlist stmt
;
stmt: decl | if | asgn
;
decl: type vars '=' expr ';'
;
if: tIF '(' bool ')' stmtlist tENDIF
;
bool: comp | bool tOR bool | bool tAND bool | comp tAND bool | comp tOR bool
;
comp: tIDENT relation tIDENT
;
relation: tLTE | tGTE | tEQ | tNE | tLT | tGT
;
asgn: tIDENT '=' expr ';'
;
type: tINTTYPE | tREALTYPE |  tINTVECTORTYPE | tREALVECTORTYPE | tINTMATRIXTYPE | tREALMATRIXTYPE
;
vars: tIDENT | vars ',' tIDENT
;
expr: tINTNUM | tREALNUM | tIDENT| vectorLit| matrixLit |
| expr '+' expr | transpose | expr '-' expr | expr '/' expr | expr '*' expr | expr tDOTPROD expr
;
row: value | row ',' value
;
rows: row | rows ';' row
;
vectorLit: '[' row ']'
;
matrixLit: '[' rows ';' row ']'
;
transpose: tTRANSPOSE '(' expr ')'
;
value: tIDENT | tINTNUM | tREALNUM
;
%%
int main ()
{
if (yyparse()) {
printf("ERROR\n");
return 1;
}
else {
printf("OK\n");
return 0;
}
}
