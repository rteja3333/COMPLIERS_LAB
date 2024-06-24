%{
    #include "ass6_21CS30012_21CS30014_translator.h"
    #include "y.tab.h"
    int lineCounter = 1;
    extern void yyerror(const char *);
%}

%option noyywrap

/* Regular Expression Definitions */

IDENTIFIER_NONDIGIT	    ([A-Za-z_])
DIGIT			        ([0-9])
IDENTIFIER		        ({IDENTIFIER_NONDIGIT}({IDENTIFIER_NONDIGIT}|{DIGIT})*)


NONZERO_DIGIT		    ([1-9])
INTEGER_CONSTANT	    ({NONZERO_DIGIT}{DIGIT}*|"0")

DIGIT_SEQUENCE		    ({DIGIT}+)
FRACTIONAL_CONSTANT	    (({DIGIT_SEQUENCE}?"."{DIGIT_SEQUENCE})|({DIGIT_SEQUENCE}"."))

SIGN			        ("+"|"-")
EXPONENT_PART		    (("e"|"E"){SIGN}?{DIGIT_SEQUENCE})
FLOATING_POINT_CONSTANT	(({FRACTIONAL_CONSTANT}{EXPONENT_PART}?)|({DIGIT_SEQUENCE}{EXPONENT_PART}))

ENUMERATION_CONSTANT	({IDENTIFIER})

ESCAPE_SEQUENCE		    ("\\\'"|"\\\""|"\\?"|"\\\\"|"\\0"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v")
C_CHAR			        ({ESCAPE_SEQUENCE}|[^\'\n\\])
C_CHAR_SEQUENCE         ({C_CHAR}+)
CHARACTER_CONSTANT      (\'{C_CHAR_SEQUENCE}\')

S_CHAR                  ({ESCAPE_SEQUENCE}|[^\"\n\\])
S_CHAR_SEQUENCE         ({S_CHAR}+)
STRING_LITERAL          (\"{S_CHAR_SEQUENCE}?\")

SINGLE_LINE_COMMENT		("//"[^("\n")]*)
MULTI_LINE_COMMENT		("/*"[^"*"]*"*"("*"|([^"/*"]*[^"*"]*"*"))*"/")

NEWLINE                 (\n)
WHITE_SPACE              [ \t]

%%
{SINGLE_LINE_COMMENT}					{ }
{MULTI_LINE_COMMENT} 					{ }

"auto"                                  { return AUTO; }
"break"                                 { return BREAK; }
"case"                                  { return CASE; }
"char"                                  { return CHAR_TYPE; }
"const"                                 { return CONST; }
"continue"                              { return CONTINUE; }
"default"                               { return DEFAULT; }
"do"                                    { return DO; }
"double"                                { return DOUBLE; }
"else"                                  { return ELSE; }
"enum"                                  { return ENUM; }
"extern"                                { return EXTERN; }
"float"                                 { return FLOAT_TYPE; }
"for"                                   { return FOR; }
"goto"                                  { return GOTO; }
"if"                                    { return IF; }
"inline"                                { return INLINE; }
"int"                                   { return INT_TYPE; }
"long"                                  { return LONG; }
"register"                              { return REGISTER; }
"restrict"                              { return RESTRICT; }
"return"                                { return RETURN; }
"short"                                 { return SHORT; }
"signed"                                { return SIGNED; }
"sizeof"                                { return SIZEOF; }
"static"                                { return STATIC; }
"struct"                                { return STRUCT; }
"switch"                                { return SWITCH; }
"typedef"                               { return TYPEDEF; }
"union"                                 { return UNION; }
"unsigned"                              { return UNSIGNED; }
"void"                                  { return VOID_TYPE; }
"volatile"                              { return VOLATILE; }
"while"                                 { return WHILE; }
"_Bool"                                 { return _BOOL; }
"_Complex"                              { return _COMPLEX; }
"_Imaginary"                            { return _IMAGINARY; }

{IDENTIFIER}	                        { yylval.symbol = curr_table->lookup(yytext); return IDENTIFIER; }

{INTEGER_CONSTANT}	                    { yylval.integer = atoi(yytext); return INTEGER_CONSTANT; }
{FLOATING_POINT_CONSTANT}	            { yylval.floating = strdup(yytext); return FLOATING_POINT_CONSTANT; }
{CHARACTER_CONSTANT}                    { yylval.character = strdup(yytext); return CHARACTER_CONSTANT; }

{STRING_LITERAL}                        { yylval.string = strdup(yytext); return STRING_LITERAL; }

"["                                     { return OPEN_SQUARE_BRACKET; }
"]"                                     { return CLOSED_SQUARE_BRACKET; }
"("                                     { return OPEN_PARENTHESES; }
")"                                     { return CLOSED_PARENTHESES; }
"{"                                     { return OPEN_CURLY_BRACKET; }
"}"                                     { return CLOSED_CURLY_BRACKET; }
"++"                                    { return INCREMENT; }
"--"                                    { return DECREMENT; }
"*"                                     { return ASTERISK; }
"+"                                     { return ADD_SIGN; }
"-"                                     { return SUBTRACT_SIGN; }
"%"                                     { return MODULO_SIGN; }
"/"                                     { return DIVIDE_SIGN; }
"="                                     { return ASSIGNMENT; }
"*="                                    { return MULTIPLY_ASSIGNMENT; }
"/="                                    { return DIVIDE_ASSIGNMENT; }
"%="                                    { return MODULO_ASSIGNMENT; }
"+="                                    { return ADD_ASSIGNMENT; }
"-="                                    { return SUBTRACT_ASSIGNMENT; }
"<<="                                   { return LEFT_SHIFT_ASSIGNMENT; }
"<<"                                    { return LEFT_SHIFT; }
">>"                                    { return RIGHT_SHIFT; }
"<"                                     { return LESS_THAN; }
">"                                     { return GREATER_THAN; }
"<="                                    { return LESS_THAN_EQUAL; }
">="                                    { return GREATER_THAN_EQUAL; }
"&"                                     { return AND_BITWISE; }
"=="                                    { return EQUALS; }
"^"                                     { return XOR_BITWISE; }
"|"                                     { return OR_BITWISE; }
"&&"                                    { return AND_LOGICAL; }
"||"                                    { return OR_LOGICAL; }
">>="                                   { return RIGHT_SHIFT_ASSIGNMENT; }
"!="                                    { return NOT_EQUALS; }
"&="                                    { return BITWISE_AND_ASSIGNMENT; }
"|="                                    { return BITWISE_OR_ASSIGNMENT; }
"^="                                    { return BITWISE_XOR_ASSIGNMENT; }
"?"                                     { return QUESTION_MARK; }
"!"                                     { return EXCLAMATION; }
"~"                                     { return TILDE; }
","                                     { return COMMA; }
"."                                     { return DOT; }
"#"                                     { return HASH; }
":"                                     { return COLON; }
";"                                     { return SEMI_COLON; }
"..."                                   { return ELLIPSIS; }
"->"                                    { return ARROW; }

{WHITE_SPACE}                            { }

{NEWLINE}                               { lineCounter++; }

.                                       { printf("Error in line %d. Invalid token: %s", lineCounter, yytext); return INVALID;}
%%
