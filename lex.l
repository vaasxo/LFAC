%%

#include <stdio.h>

%%

"int"|"long"|"double"|"float"|"char"|"string"|"bool" : {return TYPE;}
"if" : {return IF;}
"else" : {return ELSE;}
"for" : {return FOR;}
"while" : {return WHILE;}
"print" : {return PRINT;}
"class" : {return CLASS;}
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
"{" {return LBLOCK;}
"}" {return RBLOCK;}
"(" {return LPARAN;}
")" {return RPARAN;}
"[" {return LBRACKET;}
"]" {return RBRACKET;}
":" {return COLON;}
";" {return SEMICOLON;}
"," {return COMMA;}
"+" {return PLUS;}
"-" {return MINUS;}
"*" {return MUL;}
"/" {return DIV;}
"." {return DOT;}
. {}
[ \t] {}
\n {yylineno++;}

%%

int yywrap() {return 1;}