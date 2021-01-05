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
  	struct funInfo{
  		char* type;
  		char* name;

  	};

  	int varCount=0;
  	int findVariable(char*varName)
  	{
  		for(int i=0;i<varCount;i++)
  			if(strcmp(variables[i].name,varName)==0)
  				return i;
  		return -1;
  	}
  	void declare(char * type, char* varName,bool isConst)
  	{
  		if(findVariable(varName)!=-1)
  		{
  			char buffer[50];
  			sprintf(buffer,"Variable '%s' has already been declared.",varName);
  			yyerror(buffer);
  			exit(0);
  		}

  		variables[varCount].name=strdup(varName);

  		if(isConst==0)
  			variables[varCount].type=strdup(type);
  		//else
  			//variables[varCount].type=strdup(strcat("const ",varName));

  		variables[varCount].isConst=isConst;
  		variables[varCount].isAssigned=0;
  		varCount++;


  	}

  	void assign(char * type,float assignedValue)  //modified
  	{
  		if(strcmp(type,"int")==0)
  		{
  			int aux = assignedValue;

  			if(aux!=assignedValue)
  			{
  				char buffer[50];
  				sprintf(buffer,"Cannot assign value of type <float> to type <%s>.",type);
  				yyerror(buffer);
  				exit(0);
  			}

  			variables[varCount-1].isAssigned=1;
  			variables[varCount-1].value=aux;
  		}

  		if(strcmp(type,"float")==0)
  		{
  			float aux = (float)assignedValue;

  			variables[varCount-1].isAssigned=1;
  			variables[varCount-1].value=aux;
  		}

  	}
  	/*void assignFloat(char * type, float assignedValue)
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
  	}*/
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
%type <floatVal> VALUE

%%
DECLARE : EXPRESSIONS SEMICOLON
		| FUNCTIONS SEMICOLON 
		| CLASS SEMICOLON
		;

EXPRESSIONS : EXPRESSION
		    | EXPRESSIONS SEMICOLON EXPRESSION

EXPRESSION : TYPE VARIABLE {declare($1,$2,0);}
		   | CONST TYPE VARIABLE ASSIGN VALUE{declare($2,$3,1);assign($2,$5);}
		   | EXPRESSION COMMA VARIABLE {declare($1,$3,0);}
		   | EXPRESSION ASSIGN VALUE {assign($1,$3);}
		   | TYPE ARRAY
		   ;

VALUE : INTEGER{$$=$1;}
	  | FLOAT_VALUE{$$=$1;}
	  ;

FUNCTIONS : FUNCTION
		  | FUNCTIONS SEMICOLON FUNCTION 
		  ;	

FUNCTION : TYPE VARIABLE PARANTHESES_OPEN LIST_VARIABLE PARANTHESES_CLOSE
         | TYPE VARIABLE PARANTHESES_OPEN PARANTHESES_CLOSE
         ;

METHODS : FUNCTIONS SEMICOLON
		;

CLASS : OBJECT VARIABLE CURLY_OPEN CURLY_CLOSE
      | OBJECT VARIABLE CURLY_OPEN EXPRESSIONS SEMICOLON CURLY_CLOSE
      | OBJECT VARIABLE CURLY_OPEN METHODS CURLY_CLOSE
      | OBJECT VARIABLE CURLY_OPEN EXPRESSIONS SEMICOLON METHODS CURLY_CLOSE
      ;

LIST_VARIABLE : TYPE VARIABLE
              | LIST_VARIABLE COMMA TYPE VARIABLE
              ;
%%

int main(int argc, char *argv[])
{
	if(argc>1)
		yyin = fopen(argv[1], "r");
	yyparse();
	FILE *f=fopen("usedSymbols.txt","w");
	fprintf(f,"Used variables are:\n");
	for(int i=0;i<varCount;i++)
		fprintf(f,"%d. name: %s; type: %s; value: %d \n",i+1,variables[i].name,variables[i].type,variables[i].value);

  	return 0;
}