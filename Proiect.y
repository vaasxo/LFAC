%{
	#include <stdio.h>
	#include <stdbool.h>
	#include<string.h>
	#include<stdlib.h>
	extern void yyerror();
  	extern int yylex();
  	extern char* yytext;
  	extern int yylineno;
  	extern FILE *yyin;
  	struct varInfo{
  		char*type;
  		char*name;
  		int value;
  		bool isConst;
  		bool isAssigned;
  	}variables[300];

  	int varCount=0;
  	int findVariable(char*varName)
  	{
  		for(int i=0;i<varCount;i++)
  			if(strcmp(variables[i].name,varName)==0)
  				return 1;
  		return 0;
  	}
  	void declare(char * type, char* varName,bool isConst)
  	{
  		if(findVariable(varName)==1)
  		{
  			char buffer[50];
  			sprintf(buffer,"Variable '%s' has already been declared.",varName);
  			yyerror(buffer);
  			exit(0);
  		}
  		variables[varCount].name=strdup(type);

  		if(isConst==0)
  			variables[varCount].type=strdup(varName);
  		//else
  			//variables[varCount].type=strdup(strcat("const ",varName));

  		variables[varCount].isConst=isConst;
  		variables[varCount].isAssigned=0;
  		varCount++;


  	}

  	void assignInt(char * type,int assignedValue)
  	{
  		if(strcmp(type,"int")!=0&&strcmp(type,"float")!=0 )
  		{
  			char buffer[50];
  			sprintf(buffer,"Cannot assign value of type <int> to type <%s>.",type);
  			yyerror(buffer);
  			exit(0);
  		}

  		variables[varCount-1].isAssigned=1;
  		variables[varCount-1].value=assignedValue;
  	}
  	void assignFloat(char * type, float assignedValue)
  	{
  		if(strcmp(type,"float")!=0 )
  		{
  			char buffer[50];
  			sprintf(buffer,"Cannot assign value of type <float> to type <%s>.",type);
  			yyerror(buffer);
  			exit(0);
  		}
  		variables[varCount-1].isAssigned=1;
  		variables[varCount-1].value=assignedValue;
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
%token ASSIGN

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
		| DECLARE DECLARE
		;

EXPRESSION : TYPE VARIABLE {declare($1,$2,0);}
		   | CONST TYPE VARIABLE {yyerror("Value must be assigned to constant variable.");}
		   | CONST TYPE VARIABLE ASSIGN INTEGER{declare($2,$3,1);assignInt($2,$5);}
		   | CONST TYPE VARIABLE ASSIGN FLOAT_VALUE{declare($2,$3,1);assignFloat($2,$5);}
		   | EXPRESSION COMMA VARIABLE 
		   | EXPRESSION ASSIGN VALUE
		   | TYPE ARRAY
		   | EXPRESSION EQUAL PARANTHESES_OPEN PARAMETERS PARANTHESES_CLOSE
		   ;

VALUE : INTEGER
	  | FLOAT_VALUE
	  | CHARACTER
	  ;

MEMBERS : EXPRESSION SEMICOLON
		| LIST_EXPRESSION SEMICOLON
		;

METHODS : FUNCTION SEMICOLON
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
      | OBJECT VARIABLE CURLY_OPEN CURLY_CLOSE
      ;

LIST_FUNCTION : FUNCTION
			  | LIST_FUNCTION COMMA FUNCTION
			  ;

LIST_EXPRESSION : EXPRESSION
			    | LIST_EXPRESSION COMMA EXPRESSION
			    ;

LIST_VARIABLE : TYPE VARIABLE
              | LIST_VARIABLE COMMA TYPE VARIABLE
              ;
%%

int main(int argc, char *argv[])
{
	if(argc>1)
		yyin = fopen(argv[1], "r");
	FILE *f=fopen("usedSymbols.txt","w");
	fprintf(f,"Used variables are:\n");
	for(int i=0;i<varCount;i++)
		fprintf(f,"%d. name: %s; type: %s; \n",i+1,variables[i].name,variables[i].type);

  	if(!yyparse())
    	printf("\nParsing complete\n");
  	else
       printf("\nParsing failed\n");
  	return 0;
}