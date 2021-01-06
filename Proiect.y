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
  	};
  	struct varInfo variables[300];

  	struct {
  		char* type;
  		char* name;
        int paramCount;
        struct varInfo parameters[30];
  	}functions[300];

  	int varCount=0,functionCount=0,parametersCount=0;

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

  	void assign_2(char * name,float value)  //modified
  	{
  		int position = findVariable(name);
  		if(position!=-1)
  			variables[position].value=value;
  		else
  		{
  			char buffer[50];
  			sprintf(buffer,"Cannot assign value to undeclared variable.");
  			yyerror(buffer);
  			exit(0);
		}

  	}

  	int findFunction(char*functionName)
    {
      for(int i=0;i<functionCount;i++)
        if(strcmp(functions[i].name,functionName)==0)
          return i;
      return -1;
    }

    void defineFunction(char * type, char * functionName)
    {
      //end of function declaration
      if(findFunction(functionName)!=-1)
      {
        char buffer[50];
        sprintf(buffer,"Function '%s' has already been declared.",functionName);
        yyerror(buffer);
        exit(0);
      }
      functions[functionCount].type=strdup(type);
      functions[functionCount].name=strdup(functionName);
      functions[functionCount].paramCount=parametersCount;
      parametersCount=0;
      functionCount++;
    }
    int findParameter(char*paramName)
    {
      for(int i=0;i<parametersCount;i++)
        if(strcmp(functions[functionCount].parameters[i].name,paramName)==0)
          return i;
      return -1;

    }
    void defineParameters(char * type,char* paramName)
    {
      //check parameters first
        if(findParameter(paramName)!=-1)
      {
        char buffer[50];
        sprintf(buffer,"Parameter '%s' has been declared twice.",paramName);
        yyerror(buffer);
        exit(0);
      }

      functions[functionCount].parameters[parametersCount].name=strdup(paramName);
      functions[functionCount].parameters[parametersCount].type=strdup(type);
      parametersCount++;
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

%token <str> VARIABLE
%token <str> ARRAY
%token <intVal> INTEGER
%token <floatVal>  FLOAT_VALUE
%token <charVal> CHARACTER
%token <strVal> STRING_VALUE
%token CONST

%token MAIN

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

%type <floatVal> VALUE exprs expr

%type <str> function_call

%%

compile : program {printf("Success.\n");}
        ;

program : classes declarations main
        | declarations main
        | classes main
        | main
        ;

classes : class SEMICOLON
        | classes class SEMICOLON
        ;

class : OBJECT VARIABLE CURLY_OPEN CURLY_CLOSE 
      | OBJECT VARIABLE CURLY_OPEN declarations CURLY_CLOSE  
      ;

declarations : declaration SEMICOLON
			 | declarations declaration SEMICOLON

declaration : CONST TYPE VARIABLE ASSIGN VALUE {declare($2,$3,1);assign($2,$5);}
		    | TYPE VARIABLE ASSIGN VALUE {declare($1,$2,0);assign($1,$4);}
		    | CONST TYPE VARIABLE {yyerror("Constant variable must be assigned with value");}
		    | TYPE VARIABLE  {declare($1,$2,0);}
		    | TYPE ARRAY 
		    | TYPE VARIABLE PARANTHESES_OPEN LIST_VARIABLE PARANTHESES_CLOSE {defineFunction($1,$2);}
            | TYPE VARIABLE PARANTHESES_OPEN PARANTHESES_CLOSE {defineFunction($1,$2);}
		    ;

main : MAIN CURLY_OPEN block CURLY_CLOSE
	 ;

VALUE : INTEGER{$$=$1;}
	  | FLOAT_VALUE{$$=$1;}
	  ;

LIST_VARIABLE : TYPE VARIABLE {defineParameters($1,$2);}
              | LIST_VARIABLE COMMA TYPE VARIABLE {defineParameters($3,$4);}
              ;

block : code 
       | block SEMICOLON code
       ; 

code  : IF PARANTHESES_OPEN conditions PARANTHESES_CLOSE CURLY_OPEN statements SEMICOLON CURLY_CLOSE 
      | IF PARANTHESES_OPEN conditions PARANTHESES_CLOSE CURLY_OPEN statements SEMICOLON CURLY_CLOSE ELSE CURLY_OPEN statements SEMICOLON CURLY_CLOSE 
      | WHILE PARANTHESES_OPEN conditions PARANTHESES_CLOSE CURLY_OPEN statement SEMICOLON CURLY_CLOSE 
      | statements SEMICOLON
      | declarations 
      ;

conditions : condition AND condition
           | condition OR condition
           | NOT condition
           | condition
           ;

condition : operand LTHAN operand
          | operand GTHAN operand
          | operand LOREQ operand
          | operand GOREQ operand
          | operand EQUAL operand
          | operand NOTEQUAL operand
          ;

operand : VARIABLE
        | VALUE
        | function_call
        ;

statements : statement 
           | statements SEMICOLON statement 
           ;

statement : VARIABLE ASSIGN exprs {assign_2($1,$3);}
          | function_call
          | statement COMMA VARIABLE EQUAL exprs
          ;

exprs : expr PLUS expr {$$ = $1 + $3;}
      | expr MINUS expr {$$ = $1 - $3;}
      | expr MUL expr {$$ = $1 * $3;}
      | expr DIV expr {$$ = $1 / $3;}
      | expr
      ;

expr : PARANTHESES_OPEN expr PARANTHESES_CLOSE {$$ = $2;}
     | VALUE {$$ = $1;}
     | VARIABLE BRACKET_OPEN VALUE BRACKET_CLOSE {$$ = 0;}
     | VARIABLE
     ;

function_call : VARIABLE PARANTHESES_OPEN params PARANTHESES_CLOSE
			  ;

params : expr
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
    if(varCount==0)
        fprintf(f,"NONE\n");

    fprintf(f,"Used functions are:\n");
    for(int i=0;i<functionCount;i++)
    {

        fprintf(f,"%d. %s %s(",i+1,functions[i].type,functions[i].name);
        for(int j=0;j<functions[i].paramCount;j++)
            fprintf(f,"%s %s,",functions[i].parameters[j].type,functions[i].parameters[j].name);

        fprintf(f,")\n");
    }
    //fprintf(f,"%s %s",functions[0].type,functions[0].name);
    if(functionCount==0)
        fprintf(f,"NONE\n");

  	return 0;
}