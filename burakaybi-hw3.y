%{
#include <stdio.h>

void yyerror (const char *s) 
{
	printf ("%s\n", s); 
}
extern int noline;
void printing(int x);
int correctSize();
int correctDimension();

%}
%token tINTTYPE tINTVECTORTYPE tINTMATRIXTYPE tREALTYPE tREALVECTORTYPE tREALMATRIXTYPE tTRANSPOSE tIDENT tDOTPROD tIF tENDIF tREALNUM tINTNUM tAND tOR tGT tLT tGTE tLTE tNE tEQ

%left '='
%left tOR
%left tAND
%left tEQ tNE
%left tLTE tGTE tLT tGT
%left '+' '-'
%left '*' '/'
%left tDOTPROD
%left '(' ')'
%left tTRANSPOSE

%start prog

%union {
    int size;
    int array[1][2];
    int isvalue;
}

%type <size> row
%type <array> value
%type <array> vectorLit
%type <array> matrixLit
%type <array> rows
%type <array> expr
%type <array> transpose
%%




prog: 		stmtlst
;
stmtlst:	stmtlst stmt 
			| stmt
;
stmt:       decl
            | asgn
            | if   
;
decl:		type vars '=' expr ';'
;
asgn:		tIDENT '=' expr ';'
;
if:			tIF '(' bool ')' stmtlst tENDIF
;
type:		tINTTYPE
			| tINTVECTORTYPE
            | tINTMATRIXTYPE
            | tREALTYPE
            | tREALVECTORTYPE    
            | tREALMATRIXTYPE
;
vars:		vars ',' tIDENT
			| tIDENT
;
expr:		value {$1[0][0] = 0; $$[0][0] = 0;}
			| vectorLit
  			| matrixLit
| expr	'*' expr {
    if($1[0][0] != 0 && $3[0][0] != 0){ //not scalar
        if($1[0][1] != $3[0][0]){
                        exit(correctDimension());

        }
        $$[0][0] = $1[0][0];
        $$[0][1] = $3[0][1];
    }
    else if($1[0][0] != 0){ //1 is not scalar, 3 is scalar
        $$[0][0] = $1[0][0];
        $$[0][1] = $1[0][1];
    }
    else if($3[0][0] != 0){ //3 is not scalar, 1 is scalar
        $$[0][0] = $3[0][0];
        $$[0][1] = $3[0][1];
    }
    else{
        $$[0][0] = 0;
    }
}
            | expr	'/' expr {
                if($1[0][0] != 0 && $3[0][0] != 0){ //not scalar
                    if($1[0][1] != $3[0][0]){
                                    exit(correctDimension());

                    }
                    if($3[0][0] != $3[0][1]){
                                    exit(correctDimension());

                    }
                    $$[0][0] = $1[0][0];
                    $$[0][1] = $3[0][1];
                }
                else if($1[0][0] != 0){ //1 is not scalar, 3 is scalar
                    if($3[0][0] != $3[0][1]){
                                    exit(correctDimension());

                    }
                    $$[0][0] = $1[0][0];
                    $$[0][1] = $1[0][1];
                }
                else if($3[0][0] != 0){ //3 is not scalar, 1 is scalar
                    $$[0][0] = $3[0][0];
                    $$[0][1] = $3[0][1];
                }
                else{
                    $$[0][0] = 0;
                }
            }
            | expr	'+' expr {
                if($1[0][0] != 0 && $3[0][0] != 0){ //not scalar
                    if($1[0][1] != $3[0][1]){
                                    exit(correctDimension());

                    }
                    if($1[0][0] != $3[0][0]){
                                    exit(correctDimension());

                    }
                    $$[0][0] = $3[0][0];
                    $$[0][1] = $3[0][1];
                }
                else if($1[0][0] != 0){ //1 is not scalar, 3 is scalar
                    exit(correctDimension());
                }
                else if($3[0][0] != 0){ //3 is not scalar, 1 is scalar
                    exit(correctDimension());
                }
                else{
                    $$[0][0] = 0;
                }
            }
| expr	'-' expr {
    if($1[0][0] != 0 && $3[0][0] != 0){ //not scalar
        if($1[0][1] != $3[0][1]){
            exit(correctDimension());
        }
        if($3[0][0] != $1[0][0]){
            exit(correctDimension());
        }
        $$[0][0] = $1[0][0];
        $$[0][1] = $1[0][1];
    }
    else if($1[0][0] != 0){ //1 is not scalar, 3 is scalar
        exit(correctDimension());
    }
    else if($3[0][0] != 0){ //3 is not scalar, 1 is scalar
        exit(correctDimension());
    }
    else{
        $$[0][0] = 0;
    }
}
| expr tDOTPROD expr {
    if($1[0][0] != 0 && $3[0][0] != 0){ //not scalar
        if($1[0][0] != $3[0][0]){
            exit(correctDimension());
        }
        else if($3[0][1] != $1[0][1]){
            exit(correctDimension());
        }
        else if($1[0][0] != 1){
            exit(correctDimension());
        }
        $$[0][0] = $1[0][0];
        $$[0][1] = $1[0][1];
    }
    else {
        correctDimension();
        exit(0);
    }
}
| transpose {
    if($1[0][0] == 0){
        $$[0][0] = 0;
    }
    else{
        $$[0][0] = $1[0][0];
        $$[0][1] = $1[0][1];
    }
}
;    
transpose: 	tTRANSPOSE '(' expr ')' {
    if($3[0][0] != 0){
        $$[0][0] = $3[0][1];
        $$[0][1] = $3[0][0];
    }
    else $$[0][0] = 0;
}
;
vectorLit:	'[' row ']' {$$[0][0] = 1; $$[0][1] = $2;}
;
row:		row ',' value {$$ = $1 + 1;}
| value {$$ = 1; }
;
matrixLit: 	'[' rows ']' {$$[0][0] = $2[0][0]; $$[0][1] = $2[0][1];}
;
rows:		row ';' row {if($1 != $3) exit(correctSize()); else{$$[0][0] =2; $$[0][1] =$3;} }
| row ';' rows {if($3[0][1] == $1){$$[0][1] = $1; $$[0][0]= $3[0][0] + 1; } else{exit(correctSize());} }
;
value:		tINTNUM
			| tREALNUM
;
bool: 		comp
			| bool tAND bool
			| bool tOR bool
;
comp:		tIDENT relation tIDENT
;
relation:	tGT
			| tLT
			| tGTE
            | tLTE
			| tEQ
			| tNE
;

%%
int correctSize(){
    printf("ERROR 1: %d inconsistent matrix size\n\n", noline);
    return 1;
}
int correctDimension(){
    printf("ERROR 2: %d dimension mismatch\n\n", noline);
    return 1;
}
int main ()
{
   if (yyparse()) {
   // parse error
       printf("ERROR\n");
       return 1;
   }
   else {
   // successful parsing
      printf("OK\n");
      return 0;
   }
}
