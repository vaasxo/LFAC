%{
	#include <stdio.h>
	#include <stdbool.h>
	#include <string.h>
	#include <stdlib.h>
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

  	int varCount=0,functionCount=0,parametersCount=0,eval_returns[10],eval_counter=0;

  	int eval(float expression)
  	{
  		int aux = expression;
  		if(aux==expression)
  		{
  			eval_returns[eval_counter]=aux;
  			eval_counter++;
  		}
  	}

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
 		variables[varCount].type=strdup(type);
  		variables[varCount].isConst=isConst;
  		variables[varCount].isAssigned=0;
  		varCount++;


  	}

  	void assign(char * type,float assignedValue)  //modified
  	{
  		if(strcmp(type,"int")==0)
  		{
  			int aux = (int)assignedValue;

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

  	void assign_2(char * name,float value)  //Checks if a value was declared before assigning new value
  	{
  		int position = findVariable(name);
  		if(position!=-1 && variables[position].isConst==0)
  			variables[position].value=value;
  		else
  		{
  			char buffer[50];
  			sprintf(buffer,"Cannot assign value to undeclared/const variable.");
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

    float getVal(char* name)
    {
    	int position = findVariable(name);
  		if(position!=-1 && variables[position].isAssigned==1)
  			return variables[position].value;
  		else
  		{
  			char buffer[50];
  			sprintf(buffer,"Cannot get value of undefined variable.");
  			yyerror(buffer);
  			exit(0);
		}
    }

    void FunEval(char* name)
    {
    	int position = findFunction(name);
  		if(position!=-1)
  			exit(0);
  			//Evaluate the function call - to be implemented
  		else
  		{
  			char buffer[50];
  			sprintf(buffer,"Cannot call undeclared function.");
  			yyerror(buffer);
  			exit(0);
		}
    }
%}

%left COMMA
%left AND
%left OR
%left NOT
%left PLUS MINUS
%left MUL DIV


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

%type <floatVal> VALUE expr_list expr

%type <str> function_call

%%

compile : program {printf("Success.\n");}
        ;

program : class_list declaration_list main
        | declaration_list main
        | class_list main
        | main
        ;

class_list : class SEMICOLON
        | class_list class SEMICOLON
        ;

class : OBJECT VARIABLE CURLY_OPEN CURLY_CLOSE 
      | OBJECT VARIABLE CURLY_OPEN declaration_list CURLY_CLOSE  
      ;

declaration_list : declaration 
			     | declaration_list declaration 

declaration : CONST TYPE VARIABLE ASSIGN VALUE SEMICOLON{declare($2,$3,1);assign($2,$5);}
		    | TYPE VARIABLE ASSIGN VALUE SEMICOLON{declare($1,$2,0);assign($1,$4);}
		    | CONST TYPE VARIABLE SEMICOLON{yyerror("Constant variable must be assigned with value");}
		    | TYPE VARIABLE SEMICOLON{declare($1,$2,0);}
		    | TYPE ARRAY SEMICOLON{declare($1,$2,0);}
		    | TYPE VARIABLE PARANTHESES_OPEN LIST_VARIABLE PARANTHESES_CLOSE SEMICOLON{defineFunction($1,$2);}
            | TYPE VARIABLE PARANTHESES_OPEN PARANTHESES_CLOSE SEMICOLON{defineFunction($1,$2);}
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
      | block code
      ; 

code  : IF PARANTHESES_OPEN condition_list PARANTHESES_CLOSE CURLY_OPEN statement_list CURLY_CLOSE 
      | IF PARANTHESES_OPEN condition_list PARANTHESES_CLOSE CURLY_OPEN statement_list CURLY_CLOSE ELSE CURLY_OPEN statement_list CURLY_CLOSE 
      | WHILE PARANTHESES_OPEN condition_list PARANTHESES_CLOSE CURLY_OPEN statement_list CURLY_CLOSE 
      | statement SEMICOLON
      | declaration
      ;

condition_list : condition AND condition
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

statement_list : statement SEMICOLON
               | statement_list statement SEMICOLON
               ;

statement : VARIABLE ASSIGN expr_list {assign_2($1,$3);}
          | function_call
          | statement COMMA VARIABLE EQUAL expr_list
          ;

expr_list : expr PLUS expr {$$ = $1 + $3; eval($$);}
      | expr MINUS expr {$$ = $1 - $3;eval($$);}
      | expr MUL expr {$$ = $1 * $3;eval($$);}
      | expr DIV expr {$$ = $1 / $3;eval($$);}
      | expr
      ;

expr : PARANTHESES_OPEN expr PARANTHESES_CLOSE {$$ = $2;}
     | VALUE {$$ = $1;}
     | VARIABLE BRACKET_OPEN VALUE BRACKET_CLOSE {$$ = 0;}
     | VARIABLE {$$=getVal($1);}
     ;

function_call : VARIABLE PARANTHESES_OPEN params PARANTHESES_CLOSE {FunEval($1);}
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
		fprintf(f,"%d. name: %s; type: %s; value: %d; isConstant: %d\n",i+1,variables[i].name,variables[i].type,variables[i].value,variables[i].isConst);
    if(varCount==0)
        fprintf(f,"NONE\n");

    fprintf(f,"Used functions are:\n");

    for(int i=0;i<functionCount;i++)
    {

        fprintf(f,"%d. %s %s(",i+1,functions[i].type,functions[i].name);
        if(functions[i].paramCount!=0)
        {
        	int j;
        	for(j=0;j<functions[i].paramCount-1;j++)
            	fprintf(f,"%s %s,",functions[i].parameters[j].type,functions[i].parameters[j].name);
            fprintf(f,"%s %s",functions[i].parameters[j].type,functions[i].parameters[j].name);
        }

        fprintf(f,")\n");
    }

    if(functionCount==0)
        fprintf(f,"NONE\n");

    for(int i=0;i<eval_counter;i++)
    	printf("%d \n", eval_returns[i]);


  	return 0;
}