%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"
    int count=1;
%}

%x SINGLE_LINE_COMMENT
%x MULTI_LINE_COMMENT

ESCAPE_SEQUENCE         "\\\'"|"\\\""|"\\?"|"\\\\"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"
IDENTIFIER             [A-Za-z_][A-Za-z0-9_]*

DIGIT                  [0-9] 
NONZERO_DIGIT          [1-9]
DIGIT_SEQUENCE         {DIGIT}+
INTEGER_CONSTANT       {NONZERO_DIGIT}{DIGIT}*

EXPONENT_PART          [eE]([+-]?){DIGIT_SEQUENCE}
FRACTIONAL_CONSTANT    ({DIGIT_SEQUENCE}?\.{DIGIT_SEQUENCE})|({DIGIT_SEQUENCE}\.)
FLOATING_CONSTANT      ({FRACTIONAL_CONSTANT}{EXPONENT_PART}?)|({DIGIT_SEQUENCE}{EXPONENT_PART})
ENUMERATION_CONSTANT   {IDENTIFIER}

C_CHAR                 [^\'\\\n]|{ESCAPE_SEQUENCE}
C_CHAR_SEQUENCE        {C_CHAR}+
CHAR_CONSTANT          \'({C_CHAR_SEQUENCE})\'
CONSTANT               {INTEGER_CONSTANT}|{FLOATING_CONSTANT}|{ENUM_CONSTANT}|{CHAR_CONSTANT}

S_CHAR                 [^\"\\\n]|{ESCAPE_SEQUENCE}
S_CHAR_SEQUENCE        {S_CHAR}+
STRING_LITERAL         \"({S_CHAR_SEQUENCE}?)\"

WHITE_SPACE            [ \t]
NEWLINE                  \n



%%

"auto"                          { return AUTO; }
"break"                         { return BREAK; }
"case"                          { return CASE; }
"char"                          { return CHAR; }
"const"                         { return CONST; }
"continue"                      { return CONTINUE; }
"default"                       { return DEFAULT; }
"do"                            { return DO; }
"double"                        { return DOUBLE; }
"else"                          { return ELSE; }
"enum"                          { return ENUM; }
"extern"                        { return EXTERN; }
"float"                         { return FLOAT; }
"for"                           { return FOR; }
"goto"                          { return GOTO; }
"if"                            { return IF; }
"inline"                        { return INLINE; }
"int"                           { return INT; }
"long"                          { return LONG; }
"register"                      { return REGISTER; }
"restrict"                      { return RESTRICT; }
"return"                        { return RETURN; }
"short"                         { return SHORT; }
"signed"                        { return SIGNED; }
"sizeof"                        { return SIZEOF; }
"static"                        { return STATIC; }
"struct"                        { return STRUCT; }
"switch"                        { return SWITCH; }
"typedef"                       { return TYPEDEF; }
"union"                         { return UNION; }
"unsigned"                      { return UNSIGNED; }
"void"                          { return VOID; }
"volatile"                      { return VOLATILE; }
"while"                         { return WHILE; }
"_Bool"                         { return _BOOL; }
"_Complex"                      { return _COMPLEX; }
"_Imaginary"                    { return _IMAGINARY; }


{IDENTIFIER}           { yylval.identifierVal=strdup(yytext);return IDENTIFIER; }
{INTEGER_CONSTANT}     {yylval.intVal = atoi(yytext); return INTEGER_CONSTANT; }
{FLOATING_CONSTANT}    { yylval.floatVal = atof(yytext);return FLOATING_CONSTANT; }
{CHAR_CONSTANT}        { yylval.charVal = strdup(yytext);return CHARACTER_CONSTANT; }
{STRING_LITERAL}       { yylval.stringVal = strdup(yytext);return STRING_LITERAL; }

"["                             { return LEFT_SQUARE_BRACKET; }
"++"                            { return INCREMENT; }
"/"                             { return SLASH; }
"?"                             { return QUESTION_MARK; }
"="                             { return ASSIGNMENT; }
","                             { return COMMA; }
"]"                             { return RIGHT_SQUARE_BRACKET; }
"("                             { return LEFT_PARENTHESES; }
"{"                             { return LEFT_CURLY_BRACKET; }
"}"                             { return RIGHT_CURLY_BRACKET; }
"."                             { return DOT; }
"->"                            { return ARROW; }
"*"                             { return ASTERISK; }
"+"                             { return PLUS; }
"-"                             { return MINUS; }
"~"                             { return TILDE; }
"!"                             { return EXCLAMATION; }
"%"                             { return MODULO; }
"<<"                            { return LEFT_SHIFT; }
">>"                            { return RIGHT_SHIFT; }
"<"                             { return LESS_THAN; }
">"                             { return GREATER_THAN; }
"<="                            { return LESS_EQUAL_THAN; }
">="                            { return GREATER_EQUAL_THAN; }
":"                             { return COLON; }
";"                             { return SEMI_COLON; }
"..."                           { return ELLIPSIS; }
"*="                            { return ASTERISK_ASSIGNMENT; }
"/="                            { return SLASH_ASSIGNMENT; }
"%="                            { return MODULO_ASSIGNMENT; }
"+="                            { return PLUS_ASSIGNMENT; }
"-="                            { return MINUS_ASSIGNMENT; }
"<<="                           { return LEFT_SHIFT_ASSIGNMENT; }
"#"                             { return HASH; }
"--"                            { return DECREMENT; }
")"                             { return RIGHT_PARENTHESES; }
"&"                             { return BITWISE_AND; }
"=="                            { return EQUALS; }
"^"                             { return BITWISE_XOR; }
"|"                             { return BITWISE_OR; }
"&&"                            { return LOGICAL_AND; }
"||"                            { return LOGICAL_OR; }
">>="                           { return RIGHT_SHIFT_ASSIGNMENT; }
"!="                            { return NOT_EQUALS; }
"&="                            { return BITWISE_AND_ASSIGNMENT; }
"|="                            { return BITWISE_OR_ASSIGNMENT; }
"^="                            { return BITWISE_XOR_ASSIGNMENT; }


{WHITE_SPACE}            { }


"//"                            { BEGIN(SINGLE_LINE_COMMENT); }
<SINGLE_LINE_COMMENT>.          {}
<SINGLE_LINE_COMMENT>\n         { BEGIN(INITIAL);count++;printf("\n.....parsing line No.%d.....\n",count) ; }
<SINGLE_LINE_COMMENT><<EOF>>    { BEGIN(INITIAL); }

"/*"                            { BEGIN(MULTI_LINE_COMMENT); }
<MULTI_LINE_COMMENT>"*/"        { BEGIN(INITIAL);}
<MULTI_LINE_COMMENT>.           {}
<MULTI_LINE_COMMENT>\n          {count++, printf("\n......Parsing Line No.%d.........\n",count);}

{NEWLINE}                       { count++; printf("\n Parsing Line No. %d \n",count); }

.                               { printf("ERROR [Line %d] : Invalid token %s\n", count, yytext); return INVALID_TOKEN; }

%%