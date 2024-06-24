%{
#include <stdio.h>
#define keyword 1
#define identifier 2
#define constant 3
#define string_literal 4
#define punctuator 5
#define comments 6
#define ERROR 7
%}
%x MULTI_LINE_COMMENT_BODY

ID [_a-zA-Z][_a-zA-Z0-9]*

digit [0-9]
non_zero_digit [1-9]
integer_constant {non_zero_digit}({digit})*

digit_seq [0-9]+
sign [+-]
exp_part [eE]({sign}?)[0-9]+
frac_constant (({digit_seq})?\.({digit_seq}))|(({digit_seq})\.)
float_constant ({frac_constant}({exp_part}?))|({digit_seq}{exp_part})

escape_seq \\(\'|\"|\?|\\|a|b|f|n|r|t|v)
c_char ([^'\\\n])|({escape_seq})
c_char_seq ({c_char}+)
character_const [\']({c_char_seq})[\']

Constant {integer_constant}|{float_constant}|{character_const} 


s_char ([^"\\\n])|({escape_seq})
s_char_seq ({s_char}+)
String_literal [\"]({s_char_seq}?)[\"]


Keyword "auto"|"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"float"|"for"|"goto"|"if"|"inline"|"unsigned"|"void"|"volatile"|"while"|"_Bool"|"_Complex"|"_Imaginary"|"int"|"long"|"register"|"restrict"|"return"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"


Punctuator ([-\[\(\)\{\}\+*&~!\/%<>=\]]|&&|&=|\|\||<=|>=|==|!=|\||<<|>>|\^|\^=|\|=|\.\.\.|\.|->|\*=|\/=|%=|\+=|\+\+|--|-=|<<=|>>=|\?|\:|;|#|,)



multi_comment "/*"[\*|[^\*]+\*]"/"

single_comment "//"([^\n]*)? 
 
Comments {multi_comment}|{single_comment}

%%

{Keyword}       {return keyword;}
{Punctuator}         {return punctuator;}
{Constant}      {return constant;}
{ID}            {return identifier;}
{String_literal} {return string_literal;}


{Comments}  {return comments;}
.               {return ERROR;}


%%


int yywrap(void)
{
    return (1);
}