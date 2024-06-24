#include <stdio.h>
extern int yylex();
extern char* yytext;
int main(){
    int a=yylex();
    while(a){
        switch(a){
            case 1:{
                printf("<KEYWORD, %s>\n",yytext);
                break;
            }
            case 2:{
                printf("<IDENTIFIER, %s>\n",yytext);
                break;
            }
            case 3:{
                printf("<CONSTANT, %s>\n",yytext);
                break;
            }
            case 4:{
                printf("<STRING_LITERAL, %s>\n",yytext);
                break;
            }
            case 5:{
                printf("<PUNCTUATOR, %s>\n",yytext);
                break;
            }
            case 6:{
                printf("<COMMENT, %s>\n",yytext);
                break;
            }
            case 7:{
                
                break;
            }
            default: {printf("EOF\n");
                return 0;
            }
        };
        a=yylex();
    }

    return 0;
}