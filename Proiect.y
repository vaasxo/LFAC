%{
	#include <stdio.h>
	extern void yyerror();
  	extern int yylex();
  	extern char* yytext;
  	extern int yylineno;

  	int eval(int x)
  	{

  	}
%}

%union{

	char* str;
	char* dataType;
	float floatVal;
	int intVal;
	char charVal;
	char* strVal;
}

%token <dataType> TYPE
%token <dataType> OBJECT

%token <dataType> VARIABLE
%token <str> ARRAY
%token <intVal> INTEGER
%token <floatVal>  FLOAT_VALUE
%token <charVal> CHARACTER
%token <strVal> STRING_VALUE
%token CONST

%token IF
%token ELSE
%token FOR
%token WHILE

%token AND
%token OR
%token EQUAL
%token NOTEQUAL
%token GOREQ
%token LOREQ
%token GTHAN
%token LTHAN
%token NOT
%token GETS

%token CURLY_OPEN
%token CURLY_CLOSE
%token PARANTHESES_OPEN
%token PARANTHESES_CLOSE
%token BRACKET_OPEN
%token BRACKET_CLOSE
%token COLON
%token SEMICOLON
%token COMMA

//Arithmetic exp

%token PLUS
%token MINUS
%token MUL
%token DIV
%token DOT

%type <str> FUNCTION
%type <str> DECLARE
%type <str> EXPRESSION

%%
DECLARE : EXPRESSION SEMICOLON
		| FUNCTION SEMICOLON 
		| CLASS SEMICOLON
		;

EXPRESSION : TYPE VARIABLE
		   | CONST TYPE VARIABLE
		   | EXPRESSION COMMA VARIABLE
		   | EXPRESSION EQUAL VALUE
		   | TYPE ARRAY
		   | EXPRESSION EQUAL PARANTHESES_OPEN PARAMETERS PARANTHESES_CLOSE
		   ;

VALUE : INTEGER
	  | FLOAT_VALUE
	  | CHARACTER
	  ;

MEMBERS : EXPRESSION
		| LIST_EXPRESSION SEMICOLON
		;

METHODS : FUNCTION
		| LIST_FUNCTION SEMICOLON
		;

PARAMETERS : VALUE
		   | PARAMETERS COMMA VALUE
		   ;

FUNCTION : TYPE VARIABLE PARANTHESES_OPEN LIST_VARIABLE PARANTHESES_CLOSE
		 ;

CLASS : OBJECT VARIABLE CURLY_OPEN MEMBERS METHODS CURLY_CLOSE
      | OBJECT VARIABLE CURLY_OPEN MEMBERS CURLY_CLOSE
      | OBJECT VARIABLE CURLY_OPEN METHODS CURLY_CLOSE
      ;

LIST_FUNCTION : FUNCTION
			  | LIST_FUNCTION COMMA FUNCTION
			  ;

LIST_EXPRESSION : EXPRESSION
			    | LIST_EXPRESSION COMMA EXPRESSION
			    ;

LIST_VARIABLE : TYPE VARIABLE
              | LIST_VARIABLE COMMA TYPE VARIABLE

%%

int main(){

  yyparse();
  printf("No Errors!!\n");
  return 0;
}