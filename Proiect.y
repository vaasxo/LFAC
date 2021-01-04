%{
	#include <stdio.h>
	extern 

}%

%union{
	int num;
	char* str;
	char* dataType;
	float float;

}

%token <dataType> TYPE
%token <dataType> OBJECT

%token <dataType> VARIABLE
%token <str> ARRAY
%token <intVal> INTEGER
%token <floatVal>  FLOAT_VALUE
%token <charVal> CHARACTER
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