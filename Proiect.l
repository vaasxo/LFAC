%{

#include <string.h>
#include <stdlib.h>
#include "y.tab.h"

void extern yyerror(char*);
void InvalidToken();

%}


%%

"int"    |
"float"  |
"char"   |
"string" |
"bool"    {yylval.dataType = strdup(yytext);return TYPE;}

"const"  {return CONST;}

"object"  {yylval.dataType = strdup(yytext);return OBJECT;}


"if"  {return IF;}
"else"  {return ELSE;}
"for"  {return FOR;}
"while"  {return WHILE;}

"&&" {return AND;}
"||" {return OR;}
"==" {return EQUAL;}
"!=" {return NOTEQUAL;}
">=" {return GOREQ;}
"<=" {return LOREQ;}
">" {return GTHAN;}
"<" {return LTHAN;}
"!" {return NOT;}
"=" {return GETS;}

"{" {return CURLY_OPEN;}
"}" {return CURLY_CLOSE;}
"(" {return PARANTHESES_OPEN;}
")" {return PARANTHESES_CLOSE;}
"[" {return BRACKET_OPEN;}
"]" {return BRACKET_CLOSE;}
":" {return COLON;}
";" {return SEMICOLON;}
"," {return COMMA;}

"+" {return PLUS;}
"-" {return MINUS;}
"*" {return MUL;}
"/" {return DIV;}
"." {return DOT;}

[a-zA-Z][_a-zA-Z0-9]*(\[[0-9]+\])+  {yylval.str = strdup(yytext);return ARRAY;}

[a-zA-Z][_a-zA-Z0-9]*               {yylval.dataType = strdup(yytext);return VARIABLE;}

[0-9]+ 							    {yylval.intVal= atoi(yytext);return INTEGER;}

[0-9]*\.?[0-9]+                     {yylval.floatVal = atof(yytext);return FLOAT_VALUE;}

\"[_a-zA-Z0-9]*\"              {yylval.charVal = yytext[1];return CHARACTER;}


. 			{InvalidToken();}						
[\n] 			{yylineno++;}

%%

int yywrap() {return 1;}

void yyerror(char *s) {
    fprintf(stderr, "\nERROR ON LINE %d : \n %s\n", yylineno, s);
    exit(0);
}

void InvalidToken(){
    printf("ERROR ON LINE %d : \n Invalid Token %s\n", yylineno,yytext);
    exit(0);
}
