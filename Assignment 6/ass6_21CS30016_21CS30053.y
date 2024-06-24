%{
    #include "ass6_21CS30012_21CS30014_translator.h"
    extern int lineCounter;
    extern int yylex();
    void yyerror(string);
    void yyinfo(string);
%}

%union {
    int integer;
    char *floating;
    char *character;
    char *string;
    char *identifierName;
    char *unaryOperator;
    int instructionNumber;
    int parameterCount;
    Exp *expression;
    statement *stmt;
    arr *array;
    sym_type *symbolType;
    sym *symbol;
}

%token AUTO
%token BREAK
%token CASE
%token CHAR_TYPE
%token CONST
%token CONTINUE
%token DEFAULT
%token DO
%token DOUBLE
%token ELSE
%token ENUM
%token EXTERN
%token FLOAT_TYPE
%token FOR
%token GOTO
%token IF
%token INLINE
%token INT_TYPE
%token LONG
%token REGISTER
%token RESTRICT
%token RETURN
%token SHORT
%token SIGNED
%token SIZEOF
%token STATIC
%token STRUCT
%token SWITCH
%token TYPEDEF
%token UNION
%token UNSIGNED
%token VOID_TYPE
%token VOLATILE
%token WHILE
%token _BOOL
%token _COMPLEX
%token _IMAGINARY

%token OPEN_SQUARE_BRACKET
%token CLOSED_SQUARE_BRACKET
%token OPEN_PARENTHESES
%token CLOSED_PARENTHESES
%token OPEN_CURLY_BRACKET
%token CLOSED_CURLY_BRACKET
%token INCREMENT
%token DECREMENT
%token ASTERISK
%token ADD_SIGN
%token SUBTRACT_SIGN
%token MODULO_SIGN
%token DIVIDE_SIGN
%token ASSIGNMENT
%token MULTIPLY_ASSIGNMENT
%token DIVIDE_ASSIGNMENT
%token MODULO_ASSIGNMENT
%token ADD_ASSIGNMENT
%token SUBTRACT_ASSIGNMENT
%token LEFT_SHIFT_ASSIGNMENT
%token LEFT_SHIFT
%token RIGHT_SHIFT
%token LESS_THAN
%token GREATER_THAN
%token LESS_THAN_EQUAL
%token GREATER_THAN_EQUAL
%token AND_BITWISE
%token EQUALS
%token XOR_BITWISE
%token OR_BITWISE
%token AND_LOGICAL
%token OR_LOGICAL
%token RIGHT_SHIFT_ASSIGNMENT
%token NOT_EQUALS
%token BITWISE_AND_ASSIGNMENT
%token BITWISE_OR_ASSIGNMENT
%token BITWISE_XOR_ASSIGNMENT
%token QUESTION_MARK
%token EXCLAMATION
%token TILDE
%token COMMA
%token DOT
%token HASH
%token COLON
%token SEMI_COLON
%token ELLIPSIS
%token ARROW

%token INVALID

%token<symbol> IDENTIFIER
%token<integer> INTEGER_CONSTANT
%token<floating> FLOATING_POINT_CONSTANT
%token<character> CHARACTER_CONSTANT
%token<string> STRING_LITERAL


%start translation_unit
%right THEN ELSE

%type<unaryOperator> 
    unary_operator

%type<parameterCount> 
    argument_expression_list 
    argument_expression_list_opt

%type<expression>
	expression
	primary_expression 
	multiplicative_expression
	additive_expression
	shift_expression
	relational_expression
	equality_expression
	AND_expression
	exclusive_OR_expression
	inclusive_OR_expression
	logical_AND_expression
	logical_OR_expression
	conditional_expression
	assignment_expression
	expression_statement
    expression_opt

%type<array> 
    postfix_expression
	unary_expression
	cast_expression

%type <stmt>  
    statement
	compound_statement
	selection_statement
	iteration_statement
	labeled_statement 
	jump_statement
	block_item
	block_item_list
	block_item_list_opt
    N

%type<symbolType> 
    pointer

%type<symbol> 
    initialiser
    direct_declarator 
    init_declarator 
    declarator

%type <instructionNumber> M

%%

primary_expression: 
                    IDENTIFIER { 
                            yyinfo("primary_expression -> IDENTIFIER");
                            $$ = new Exp();
                            $$->symbol = $1;
                            $$->type = Exp::_type::NON_BOOLEAN; 
                        }
                    | INTEGER_CONSTANT { 
                            yyinfo("primary_expression -> INTEGER_CONSTANT"); 
                            $$ = new Exp();
                            $$->symbol = generate_temp(sym_type::_type::INT, convertToString($1));
                            emit("=", $$->symbol->name, $1);
                        }
                    | FLOATING_POINT_CONSTANT { 
                            yyinfo("primary_expression -> FLOATING_POINT_CONSTANT"); 
                            $$ = new Exp();
                            $$->symbol = generate_temp(sym_type::_type::FLOAT, $1);
                            emit("=", $$->symbol->name, $1);
                        }
                    | CHARACTER_CONSTANT { 
                            yyinfo("primary_expression -> CHARACTER_CONSTANT"); 
                            $$ = new Exp();
                            $$->symbol = generate_temp(sym_type::_type::CHAR, $1);
                            emit("=", $$->symbol->name, $1);
                        }
                    | STRING_LITERAL { 
                            yyinfo("primary_expression -> STRING_LITERAL"); 
                            $$ = new Exp();
		                    $$->symbol = generate_temp(sym_type::_type::PTR, $1);
		                    $$->symbol->type->arrType = new sym_type(sym_type::_type::CHAR);
                            emit("=str", $$->symbol->name, int(str_list.size()));
                            str_list.push_back($1);
                        }
                    | OPEN_PARENTHESES expression CLOSED_PARENTHESES { 
                            yyinfo("primary_expression -> ( expression )"); 
                            $$ = $2;
                        }
                    ;

postfix_expression:
                    primary_expression
                        { 
                            yyinfo("postfix_expression -> primary_expression"); 
                            $$ = new arr();
                            $$->symbol = $1->symbol;
                            $$->loc = $$->symbol;
                            $$->arr_type = $1->symbol->type;
                        }
                    | postfix_expression OPEN_SQUARE_BRACKET expression CLOSED_SQUARE_BRACKET
                        { 
                            yyinfo("postfix_expression -> postfix_expression [ expression ]"); 
                            $$ = new arr();
                            $$->symbol = $1->symbol;
                            $$->arr_type = $1->arr_type->arrType;
                            $$->loc = generate_temp(sym_type::_type::INT);
                            $$->type = arr::_type::ARR;

                            if($1->type == arr::_type::ARR) {
                                sym *temp1 = generate_temp(sym_type::_type::INT);
                                emit("*", temp1->name, $3->symbol->name, convertToString($$->arr_type->getWidth()));
                                emit("+", $$->loc->name, $1->loc->name, temp1->name);
                            } else {
                                emit("*", $$->loc->name, $3->symbol->name, convertToString($$->arr_type->getWidth()));
                            }

                        }
                    | postfix_expression OPEN_PARENTHESES argument_expression_list_opt CLOSED_PARENTHESES
                        { 
                            yyinfo("postfix_expression -> postfix_expression ( argument_expression_list_opt )"); 
                            $$ = new arr();
                            $$->symbol = generate_temp($1->symbol->type->type);
                            $$->symbol->type->arrType = $1->symbol->type->arrType;
                            emit("call", $$->symbol->name, $1->symbol->name, convertToString($3));
                        }
                    | postfix_expression DOT IDENTIFIER
                        { 
                            yyinfo("postfix_expression -> postfix_expression . IDENTIFIER"); 
                        }
                    | postfix_expression ARROW IDENTIFIER
                        { 
                            yyinfo("postfix_expression -> postfix_expression -> IDENTIFIER"); 
                        }
                    | postfix_expression INCREMENT
                        { 
                            yyinfo("postfix_expression -> postfix_expression ++");
                            $$ = new arr();
                            $$->symbol = generate_temp($1->symbol->type->type);
                            emit("=", $$->symbol->name, $1->symbol->name);
                            emit("+", $1->symbol->name, $1->symbol->name, convertToString(1)); 
                        }
                    | postfix_expression DECREMENT
                        { 
                            yyinfo("postfix_expression -> postfix_expression --"); 
                            $$ = new arr();
                            $$->symbol = generate_temp($1->symbol->type->type);
                            emit("=", $$->symbol->name, $1->symbol->name);
                            emit("-", $1->symbol->name, $1->symbol->name, convertToString(1));
                        }
                    | OPEN_PARENTHESES type_name CLOSED_PARENTHESES OPEN_CURLY_BRACKET initialiser_list CLOSED_CURLY_BRACKET
                        { 
                            yyinfo("postfix_expression -> ( type_name ) { initialiser_list }"); 
                        }
                    | OPEN_PARENTHESES type_name CLOSED_PARENTHESES OPEN_CURLY_BRACKET initialiser_list COMMA CLOSED_CURLY_BRACKET
                        { 
                            yyinfo("postfix_expression -> ( type_name ) { initialiser_list , }"); 
                        }
                    ;


argument_expression_list_opt:
                                argument_expression_list
                                    { 
                                        yyinfo("argument_expression_list_opt -> argument_expression_list"); 
                                        $$ = $1;
                                    }
                                | 
                                    { 
                                        yyinfo("argument_expression_list_opt -> epsilon");
                                        $$ = 0;
                                    }
                                ;

argument_expression_list:
                            assignment_expression
                                { 
                                    yyinfo("argument_expression_list -> assignment_expression"); 
                                    emit("param", $1->symbol->name);
                                    $$ = 1;
                                }
                            | argument_expression_list COMMA assignment_expression
                                { 
                                    yyinfo("argument_expression_list -> argument_expression_list , assignment_expression");
                                    emit("param", $3->symbol->name);
                                    $$ = $1 + 1; 
                                }
                            ;

unary_expression:
                    postfix_expression
                        { 
                            yyinfo("unary_expression -> postfix_expression"); 
                            $$ = $1;
                        }
                    | INCREMENT unary_expression
                        { 
                            yyinfo("unary_expression -> ++ unary_expression"); 
                            $$ = $2;
                            emit("+", $2->symbol->name, $2->symbol->name, convertToString(1));
                        }
                    | DECREMENT unary_expression
                        { 
                            yyinfo("unary_expression -> -- unary_expression"); 
                            $$ = $2;
                            emit("-", $2->symbol->name, $2->symbol->name, convertToString(1));
                        }
                    | unary_operator cast_expression
                        { 
                            yyinfo("unary_expression -> unary_operator cast_expression");
                            if(strcmp($1, "&") == 0) {
                                $$ = new arr();
                                $$->symbol = generate_temp(sym_type::_type::PTR);
                                $$->symbol->type->arrType = $2->symbol->type;
                                emit("=&", $$->symbol->name, $2->symbol->name);
                            } else if(strcmp($1, "*") == 0) {
                                $$ = new arr();
                                $$->symbol = $2->symbol;
                                $$->loc = generate_temp($2->loc->type->arrType->type);
                                $$->loc->type->arrType = $2->loc->type->arrType->arrType;
                                $$->type = arr::_type::PTR;
                                emit("=*", $$->loc->name, $2->loc->name);
                            } else if(strcmp($1, "+") == 0) {
                                $$ = $2;
                            } else { 
                                $$ = new arr();
                                $$->symbol = generate_temp($2->symbol->type->type);
                                emit($1, $$->symbol->name, $2->symbol->name);
                            }
                        }
                    | SIZEOF unary_expression
                        { 
                            yyinfo("unary_expression -> sizeof unary_expression"); 
                        }
                    | SIZEOF OPEN_PARENTHESES type_name CLOSED_PARENTHESES
                        { 
                            yyinfo("unary_expression -> sizeof ( type_name )"); 
                        }
                    ;

unary_operator:
                AND_BITWISE
                    { 
                        yyinfo("unary_operator -> &"); 
                        $$ = strdup("&"); 
                    }
                | ASTERISK
                    { 
                        yyinfo("unary_operator -> *"); 
                        $$ = strdup("*"); 
                    }
                | ADD_SIGN
                    { 
                        yyinfo("unary_operator -> +"); 
                        $$ = strdup("+"); 
                    }
                | SUBTRACT_SIGN
                    { 
                        yyinfo("unary_operator -> -"); 
                        $$ = strdup("=-"); 
                    }
                | TILDE
                    { 
                        yyinfo("unary_operator -> ~"); 
                        $$ = strdup("~"); 
                    }
                | EXCLAMATION
                    { 
                        yyinfo("unary_operator -> !"); 
                        $$ = strdup("!"); 
                    }
                ;

cast_expression:
                unary_expression
                    { 
                        yyinfo("cast_expression -> unary_expression"); 
                        $$ = $1;
                    }
                | OPEN_PARENTHESES type_name CLOSED_PARENTHESES cast_expression 
                    { 
                        yyinfo("cast_expression -> ( type_name ) cast_expression"); 
                        $$ = new arr();
                        $$->symbol = $4->symbol->typeCast(curr_type);
                    }
                ;

multiplicative_expression:
                            cast_expression
                                { 
                                    yyinfo("multiplicative_expression -> cast_expression"); 
                                    sym_type *baseType = $1->symbol->type;
                                    while(baseType->arrType)
                                        baseType = baseType->arrType;
                                    $$ = new Exp();
                                    if($1->type == arr::_type::ARR) {
                                        $$->symbol = generate_temp(baseType->type);
                                        emit("=[]", $$->symbol->name, $1->symbol->name, $1->loc->name);
                                    } else if($1->type == arr::_type::PTR) {
                                        $$->symbol = $1->loc;
                                    } else {
                                        $$->symbol = $1->symbol;
                                    }
                                }
                            | multiplicative_expression ASTERISK cast_expression
                                { 
                                    yyinfo("multiplicative_expression -> multiplicative_expression * cast_expression"); 
                                    sym_type *baseType = $3->symbol->type;
                                    while(baseType->arrType)
                                        baseType = baseType->arrType;
                                    sym *temp;
                                    if($3->type == arr::_type::ARR) {
                                        temp = generate_temp(baseType->type);
                                        emit("=[]", temp->name, $3->symbol->name, $3->loc->name);
                                    } else if($3->type == arr::_type::PTR) {
                                        temp = $3->loc;
                                    } else {
                                        temp = $3->symbol;
                                    }
                                    if(check_sym_type($1->symbol, temp)) {
                                        $$ = new Exp();
                                        $$->symbol = generate_temp($1->symbol->type->type);
                                        emit("*", $$->symbol->name, $1->symbol->name, temp->name);
                                    } else {
                                        yyerror("Type error.");
                                    }
                                }
                            | multiplicative_expression DIVIDE_SIGN cast_expression
                                { 
                                    yyinfo("multiplicative_expression -> multiplicative_expression / cast_expression");
                                    sym_type *baseType = $3->symbol->type;
                                    while(baseType->arrType)
                                        baseType = baseType->arrType;
                                    sym *temp;
                                    if($3->type == arr::_type::ARR) {
                                        temp = generate_temp(baseType->type);
                                        emit("=[]", temp->name, $3->symbol->name, $3->loc->name);
                                    } else if($3->type == arr::_type::PTR) {
                                        temp = $3->loc;
                                    } else {
                                        temp = $3->symbol;
                                    }
                                    if(check_sym_type($1->symbol, temp)) {
                                        $$ = new Exp();
                                        $$->symbol = generate_temp($1->symbol->type->type);
                                        emit("/", $$->symbol->name, $1->symbol->name, temp->name);
                                    } else {
                                        yyerror("Type error.");
                                    }
                                }
                            | multiplicative_expression MODULO_SIGN cast_expression
                                { 
                                    yyinfo("multiplicative_expression -> multiplicative_expression % cast_expression");
                                    sym_type *baseType = $3->symbol->type;
                                    while(baseType->arrType)
                                        baseType = baseType->arrType;
                                    sym *temp;
                                    if($3->type == arr::_type::ARR) {
                                        temp = generate_temp(baseType->type);
                                        emit("=[]", temp->name, $3->symbol->name, $3->loc->name);
                                    } else if($3->type == arr::_type::PTR) {
                                        temp = $3->loc;
                                    } else {
                                        temp = $3->symbol;
                                    } 
                                    if(check_sym_type($1->symbol, temp)) {
                                        $$ = new Exp();
                                        $$->symbol = generate_temp($1->symbol->type->type);
                                        emit("%", $$->symbol->name, $1->symbol->name, temp->name);
                                    } else {
                                        yyerror("Type error.");
                                    }
                                }
                            ;

additive_expression:
                    multiplicative_expression
                        { 
                            yyinfo("additive_expression -> multiplicative_expression"); 
                            $$ = $1;
                        }
                    | additive_expression ADD_SIGN multiplicative_expression
                        { 
                            yyinfo("additive_expression -> additive_expression + multiplicative_expression"); 
                            if(check_sym_type($1->symbol, $3->symbol)) {
                                $$ = new Exp();
                                $$->symbol = generate_temp($1->symbol->type->type);
                                emit("+", $$->symbol->name, $1->symbol->name, $3->symbol->name);
                            } else {
                                yyerror("Type error.");
                            }
                        }
                    | additive_expression SUBTRACT_SIGN multiplicative_expression
                        { 
                            yyinfo("additive_expression -> additive_expression - multiplicative_expression"); 
                            if(check_sym_type($1->symbol, $3->symbol)) {
                                $$ = new Exp();
                                $$->symbol = generate_temp($1->symbol->type->type);
                                emit("-", $$->symbol->name, $1->symbol->name, $3->symbol->name);
                            } else {
                                yyerror("Type error.");
                            }
                        }
                    ;

shift_expression:
                    additive_expression
                        { 
                            yyinfo("shift_expression -> additive_expression");
                            $$ = $1;
                        }
                    | shift_expression LEFT_SHIFT additive_expression
                        { 
                            yyinfo("shift_expression -> shift_expression << additive_expression"); 
                            if($3->symbol->type->type == sym_type::_type::INT) {
                                $$ = new Exp();
                                $$->symbol = generate_temp(sym_type::_type::INT);
                                emit("<<", $$->symbol->name, $1->symbol->name, $3->symbol->name);
                            } else {
                                yyerror("Type error.");
                            }
                        }
                    | shift_expression RIGHT_SHIFT additive_expression
                        { 
                            yyinfo("shift_expression -> shift_expression >> additive_expression"); 
                            if($3->symbol->type->type == sym_type::_type::INT) {
                                $$ = new Exp();
                                $$->symbol = generate_temp(sym_type::_type::INT);
                                emit(">>", $$->symbol->name, $1->symbol->name, $3->symbol->name);
                            } else {
                                yyerror("Type error.");
                            }
                        }
                    ;

relational_expression:
                        shift_expression
                            { 
                                yyinfo("relational_expression -> shift_expression"); 
                                $$ = $1;
                            }
                        | relational_expression LESS_THAN shift_expression
                            { 
                                yyinfo("relational_expression -> relational_expression < shift_expression"); 
                                if(check_sym_type($1->symbol, $3->symbol)) {
                                    $$ = new Exp();
                                    $$->type = Exp::_type::BOOLEAN;
                                    $$->true_list = make_list(next_instrn());
			                        $$->false_list = make_list(next_instrn() + 1);
                                    emit("<", "", $1->symbol->name, $3->symbol->name);
                                    emit("goto", "");
                                } else {
                                    yyerror("Type error.");
                                }
                            }
                        | relational_expression GREATER_THAN shift_expression
                            { 
                                yyinfo("relational_expression -> relational_expression > shift_expression"); 
                                if(check_sym_type($1->symbol, $3->symbol)) {
                                    $$ = new Exp();
                                    $$->type = Exp::_type::BOOLEAN;
                                    $$->true_list = make_list(next_instrn());
			                        $$->false_list = make_list(next_instrn() + 1);
                                    emit(">", "", $1->symbol->name, $3->symbol->name);
                                    emit("goto", "");
                                } else {
                                    yyerror("Type error.");
                                }
                            }
                        | relational_expression LESS_THAN_EQUAL shift_expression
                            { 
                                yyinfo("relational_expression -> relational_expression <= shift_expression"); 
                                if(check_sym_type($1->symbol, $3->symbol)) {
                                    $$ = new Exp();
                                    $$->type = Exp::_type::BOOLEAN;
                                    $$->true_list = make_list(next_instrn());
			                        $$->false_list = make_list(next_instrn() + 1);
                                    emit("<=", "", $1->symbol->name, $3->symbol->name);
                                    emit("goto", "");
                                } else {
                                    yyerror("Type error.");
                                }
                            }
                        | relational_expression GREATER_THAN_EQUAL shift_expression
                            { 
                                yyinfo("relational_expression -> relational_expression >= shift_expression"); 
                                if(check_sym_type($1->symbol, $3->symbol)) {
                                    $$ = new Exp();
                                    $$->type = Exp::_type::BOOLEAN;
                                    $$->true_list = make_list(next_instrn());
			                        $$->false_list = make_list(next_instrn() + 1);
                                    emit(">=", "", $1->symbol->name, $3->symbol->name);
                                    emit("goto", "");
                                } else {
                                    yyerror("Type error.");
                                }
                            }
                        ;

equality_expression:
                    relational_expression
                        { 
                            yyinfo("equality_expression -> relational_expression"); 
                            $$ = $1;
                        }
                    | equality_expression EQUALS relational_expression
                        { 
                            yyinfo("equality_expression -> equality_expression == relational_expression"); 
                            if(check_sym_type($1->symbol, $3->symbol)) {
                                $1->convertToInt();
                                $3->convertToInt();
                                $$ = new Exp();
                                $$->type = Exp::_type::BOOLEAN;
                                $$->true_list = make_list(next_instrn());
			                    $$->false_list = make_list(next_instrn() + 1);
                                emit("==", "", $1->symbol->name, $3->symbol->name);
                                emit("goto", "");
                            } else {
                                yyerror("Type error.");
                            }
                        }
                    | equality_expression NOT_EQUALS relational_expression
                        { 
                            yyinfo("equality_expression -> equality_expression != relational_expression"); 
                            if(check_sym_type($1->symbol, $3->symbol)) {
                                $1->convertToInt();
                                $3->convertToInt();
                                $$ = new Exp();
                                $$->type = Exp::_type::BOOLEAN;
                                $$->true_list = make_list(next_instrn());
			                    $$->false_list = make_list(next_instrn() + 1);
                                emit("!=", "", $1->symbol->name, $3->symbol->name);
                                emit("goto", "");
                            } else {
                                yyerror("Type error.");
                            }
                        }
                    ;

AND_expression:
                equality_expression
                    { 
                        yyinfo("AND_expression -> equality_expression"); 
                        $$ = $1;
                    }
                | AND_expression AND_BITWISE equality_expression
                    { 
                        yyinfo("AND_expression -> AND_expression & equality_expression"); 
                        $1->convertToInt();
                        $3->convertToInt();
                        $$ = new Exp();
                        $$->type = Exp::_type::NON_BOOLEAN;
                        $$->symbol = generate_temp(sym_type::_type::INT);
                        emit("&", $$->symbol->name, $1->symbol->name, $3->symbol->name);
                    }
                ;

exclusive_OR_expression:
                        AND_expression
                            { 
                                yyinfo("exclusive_OR_expression -> AND_expression"); 
                                $$ = $1;
                            }
                        | exclusive_OR_expression XOR_BITWISE AND_expression
                            { 
                                yyinfo("exclusive_OR_expression -> exclusive_OR_expression ^ AND_expression"); 
                                $1->convertToInt();
                                $3->convertToInt();
                                $$ = new Exp();
                                $$->type = Exp::_type::NON_BOOLEAN;
                                $$->symbol = generate_temp(sym_type::_type::INT);
                                emit("^", $$->symbol->name, $1->symbol->name, $3->symbol->name);
                            }
                        ;

inclusive_OR_expression:
                        exclusive_OR_expression
                            { 
                                yyinfo("inclusive_OR_expression -> exclusive_OR_expression"); 
                                $$ = $1;
                            }
                        | inclusive_OR_expression OR_BITWISE exclusive_OR_expression
                            { 
                                yyinfo("inclusive_OR_expression -> inclusive_OR_expression | exclusive_OR_expression"); 
                                $1->convertToInt();
                                $3->convertToInt();
                                $$ = new Exp();
                                $$->type = Exp::_type::NON_BOOLEAN;
                                $$->symbol = generate_temp(sym_type::_type::INT);
                                emit("|", $$->symbol->name, $1->symbol->name, $3->symbol->name);
                            }
                        ;

logical_AND_expression:
                        inclusive_OR_expression
                            { 
                                yyinfo("logical_AND_expression -> inclusive_OR_expression"); 
                                $$ = $1;
                            }
                        | logical_AND_expression AND_LOGICAL M inclusive_OR_expression
                            { 
                                yyinfo("logical_AND_expression -> logical_AND_expression && inclusive_OR_expression");
                                $1->convertToBool();
                                $4->convertToBool();
                                $$ = new Exp();
                                $$->type = Exp::_type::BOOLEAN;
                                back_patch($1->true_list, $3);
                                $$->true_list = $4->true_list;
                                $$->false_list = merge($1->false_list, $4->false_list);
                            }
                        ;

logical_OR_expression:
                        logical_AND_expression
                            { 
                                yyinfo("logical_OR_expression -> logical_AND_expression"); 
                                $$ = $1;
                            }
                        | logical_OR_expression OR_LOGICAL M logical_AND_expression
                            { 
                                yyinfo("logical_OR_expression -> logical_OR_expression || logical_AND_expression"); 
                                $1->convertToBool();
                                $4->convertToBool();
                                $$ = new Exp();
                                $$->type = Exp::_type::BOOLEAN;
                                back_patch($1->false_list, $3);
                                $$->true_list = merge($1->true_list, $4->true_list);
                                $$->false_list = $4->false_list;
                            }
                        ;

conditional_expression:
                        logical_OR_expression
                            { 
                                yyinfo("conditional_expression -> logical_OR_expression"); 
                                $$ = $1;
                            }
                        | logical_OR_expression N QUESTION_MARK M expression N COLON M conditional_expression
                            { 
                                yyinfo("conditional_expression -> logical_OR_expression ? expression : conditional_expression"); 
                                $$->symbol = generate_temp($5->symbol->type->type);
                                emit("=", $$->symbol->name, $9->symbol->name);
                                list<int> l = make_list(next_instrn());
                                emit("goto", "");
                                back_patch($6->next_list, next_instrn());
                                emit("=", $$->symbol->name, $5->symbol->name);
                                l = merge(l, make_list(next_instrn()));
                                emit("goto", "");
                                back_patch($2->next_list, next_instrn());
                                $1->convertToBool();
                                back_patch($1->true_list, $4);
                                back_patch($1->false_list, $8);
                                back_patch(l, next_instrn());
                            }
                        ;

assignment_expression:
                        conditional_expression
                            { 
                                yyinfo("assignment_expression -> conditional_expression"); 
                                $$ = $1;
                            }
                        | unary_expression assignment_operator assignment_expression
                            { 
                                yyinfo("assignment_expression -> unary_expression assignment_operator assignment_expression"); 
                                if($1->type == arr::_type::ARR) {
                                    $3->symbol = $3->symbol->typeCast($1->arr_type->type);
                                    emit("[]=", $1->symbol->name, $1->loc->name, $3->symbol->name);
                                } else if($1->type == arr::_type::PTR) {
                                    $3->symbol = $3->symbol->typeCast($1->loc->type->type);
                                    emit("*=", $1->loc->name, $3->symbol->name);
                                } else {
                                    $3->symbol = $3->symbol->typeCast($1->symbol->type->type);
			                        emit("=", $1->symbol->name, $3->symbol->name);
                                }
                                $$ = $3;
                            }
                        ;

assignment_operator:
                    ASSIGNMENT
                        { 
                            yyinfo("assignment_operator -> ="); 
                        }
                    | MULTIPLY_ASSIGNMENT
                        { 
                            yyinfo("assignment_operator -> *="); 
                        }
                    | DIVIDE_ASSIGNMENT
                        { 
                            yyinfo("assignment_operator -> /="); 
                        }
                    | MODULO_ASSIGNMENT
                        { 
                            yyinfo("assignment_operator -> %="); 
                        }
                    | ADD_ASSIGNMENT
                        { 
                            yyinfo("assignment_operator -> += "); 
                        }
                    | SUBTRACT_ASSIGNMENT
                        { 
                            yyinfo("assignment_operator -> -= "); 
                        }
                    | LEFT_SHIFT_ASSIGNMENT
                        { 
                            yyinfo("assignment_operator -> <<="); 
                        }
                    | RIGHT_SHIFT_ASSIGNMENT
                        { 
                            yyinfo("assignment_operator -> >>="); 
                        }
                    | BITWISE_AND_ASSIGNMENT
                        { 
                            yyinfo("assignment_operator -> &="); 
                        }
                    | BITWISE_XOR_ASSIGNMENT
                        { 
                            yyinfo("assignment_operator -> ^="); 
                        }
                    | BITWISE_OR_ASSIGNMENT
                        { 
                            yyinfo("assignment_operator -> |="); 
                        }
                    ;

expression:
            assignment_expression
                { 
                    yyinfo("expression -> assignment_expression"); 
                    $$ = $1;
                }
            | expression COMMA assignment_expression
                {
                     yyinfo("expression -> expression , assignment_expression"); 
                }
            ;

constant_expression:
                    conditional_expression
                        {
                             yyinfo("constant_expression -> conditional_expression"); 
                        }
                    ;

declaration:
            declaration_specifiers init_declarator_list_opt SEMI_COLON
                {
                     yyinfo("declaration -> declaration_specifiers init_declarator_list_opt ;"); 
                }
            ;

init_declarator_list_opt:
                            init_declarator_list
                                {
                                     yyinfo("init_declarator_list_opt -> init_declarator_list"); 
                                }
                            |
                                {
                                     yyinfo("init_declarator_list_opt -> epsilon"); 
                                }
                            ;

declaration_specifiers:
                        storage_class_specifier declaration_specifiers_opt
                            {
                                 yyinfo("declaration_specifiers -> storage_class_specifier declaration_specifiers_opt"); 
                            }
                        | type_specifier declaration_specifiers_opt
                            {
                                 yyinfo("declaration_specifiers -> type_specifier declaration_specifiers_opt"); 
                            }
                        | type_qualifier declaration_specifiers_opt
                            {
                                 yyinfo("declaration_specifiers -> type_qualifier declaration_specifiers_opt"); 
                            }
                        | function_specifier declaration_specifiers_opt
                            {
                                 yyinfo("declaration_specifiers -> function_specifier declaration_specifiers_opt"); 
                            }
                        ;

declaration_specifiers_opt:
                            declaration_specifiers
                                {
                                     yyinfo("declaration_specifiers_opt -> declaration_specifiers"); 
                                }
                            |
                                {
                                     yyinfo("declaration_specifiers_opt -> epsilon "); 
                                }
                            ;

init_declarator_list:
                        init_declarator
                            {
                                 yyinfo("init_declarator_list -> init_declarator"); 
                            }
                        | init_declarator_list COMMA init_declarator
                            {
                                 yyinfo("init_declarator_list -> init_declarator_list , init_declarator"); 
                            }
                        ;

init_declarator:
                declarator
                    { 
                        yyinfo("init_declarator -> declarator"); 
                        $$ = $1;
                    }
                | declarator ASSIGNMENT initialiser
                    { 
                        yyinfo("init_declarator -> declarator = initialiser");
                        if($3->initValue != "") 
                            $1->initValue = $3->initValue;
		                emit("=", $1->name, $3->name);
                    }
                ;

storage_class_specifier:
                        EXTERN
                            {
                                 yyinfo("storage_class_specifier -> extern"); 
                            }
                        | STATIC
                            {
                                 yyinfo("storage_class_specifier -> static"); 
                            }
                        | AUTO
                            {
                                 yyinfo("storage_class_specifier -> auto"); 
                            }
                        | REGISTER
                            {
                                 yyinfo("storage_class_specifier -> register"); 
                            }
                        ;

type_specifier:
                VOID_TYPE
                    { 
                        yyinfo("type_specifier -> void");
                        curr_type = sym_type::_type::VOID;
                    }
                | CHAR_TYPE
                    { 
                        yyinfo("type_specifier -> char"); 
                        curr_type = sym_type::_type::CHAR;
                    }
                | SHORT
                    {
                         yyinfo("type_specifier -> short"); 
                    }
                | INT_TYPE
                    { 
                        yyinfo("type_specifier -> int"); 
                        curr_type = sym_type::_type::INT;
                    }
                | LONG
                    {
                         yyinfo("type_specifier -> long"); 
                    }
                | FLOAT_TYPE
                    { 
                        yyinfo("type_specifier -> float"); 
                        curr_type = sym_type::_type::FLOAT;
                    }
                | DOUBLE
                    {
                         yyinfo("type_specifier -> double"); 
                    }
                | SIGNED
                    {
                         yyinfo("type_specifier -> signed"); 
                    }
                | UNSIGNED
                    {
                         yyinfo("type_specifier -> unsigned"); 
                    }
                // | _BOOL
                //     {
                //          yyinfo("type_specifier -> _Bool"); 
                //     }
                // | _COMPLEX
                //     {
                //          yyinfo("type_specifier -> _Complex"); 
                //     }
                // | _IMAGINARY
                //     {
                //          yyinfo("type_specifier -> _Imaginary"); 
                //     }
                | enum_specifier 
                    {
                         yyinfo("type_specifier -> enum_specifier"); 
                    }
                ;

specifier_qualifier_list:
                            type_specifier specifier_qualifier_list_opt
                                { 
                                    yyinfo("specifier_qualifier_list -> type_specifier specifier_qualifier_list_opt"); 
                                }
                            | type_qualifier specifier_qualifier_list_opt
                                { 
                                    yyinfo("specifier_qualifier_list -> type_qualifier specifier_qualifier_list_opt"); 
                                }
                            ;

specifier_qualifier_list_opt:
                                specifier_qualifier_list
                                    { 
                                        yyinfo("specifier_qualifier_list_opt -> specifier_qualifier_list"); 
                                    }
                                | 
                                    { 
                                        yyinfo("specifier_qualifier_list_opt -> epsilon"); 
                                    }
                                ;

enum_specifier:
                ENUM identifier_opt OPEN_CURLY_BRACKET enumerator_list CLOSED_CURLY_BRACKET 
                    { 
                        yyinfo("enum_specifier -> enum identifier_opt { enumerator_list }"); 
                    }
                | ENUM identifier_opt OPEN_CURLY_BRACKET enumerator_list COMMA CLOSED_CURLY_BRACKET
                    { 
                        yyinfo("enum_specifier -> enum identifier_opt { enumerator_list , }"); 
                    }
                | ENUM IDENTIFIER
                    { 
                        yyinfo("enum_specifier -> enum IDENTIFIER"); 
                    }
                ;

identifier_opt:
                IDENTIFIER 
                    { 
                        yyinfo("identifier_opt -> IDENTIFIER"); 
                    }
                | 
                    { 
                        yyinfo("identifier_opt -> epsilon"); 
                    }
                ;

enumerator_list:
                enumerator 
                    { 
                        yyinfo("enumerator_list -> enumerator"); 
                    }
                | enumerator_list COMMA enumerator
                    { 
                        yyinfo("enumerator_list -> enumerator_list , enumerator"); 
                    }
                ;

enumerator:
            IDENTIFIER 
                { 
                    yyinfo("enumerator -> ENUMERATION_CONSTANT"); 
                }
            | IDENTIFIER ASSIGNMENT constant_expression
                { 
                    yyinfo("enumerator -> ENUMERATION_CONSTANT = constant_expression"); 
                }
            ;

type_qualifier:
                CONST
                    { 
                        yyinfo("type_qualifier -> const"); 
                    }
                | RESTRICT
                    { 
                        yyinfo("type_qualifier -> restrict"); 
                    }
                | VOLATILE
                    { 
                        yyinfo("type_qualifier -> volatile"); 
                    }
                ;

function_specifier:
                    INLINE
                        { 
                            yyinfo("function_specifier -> inline"); 
                        }
                    ;

declarator:
            pointer direct_declarator
                { 
                    yyinfo("declarator -> pointer direct_declarator"); 
                    sym_type *it = $1;
                    while(it->arrType != NULL) 
                        it = it->arrType;
                    it->arrType = $2->type;
                    $$ = $2->updateSym($1);
                }
            | direct_declarator
                { 
                    yyinfo("declarator -> direct_declarator"); 
                }
            ;

direct_declarator:
                    IDENTIFIER 
                        { 
                            yyinfo("direct_declarator -> IDENTIFIER"); 
                            $$ = $1->updateSym(new sym_type(curr_type));
                            curr_symbol = $$;
                        }
                    | OPEN_PARENTHESES declarator CLOSED_PARENTHESES
                        { 
                            yyinfo("direct_declarator -> ( declarator )"); 
                            $$ = $2;
                        }
                    | direct_declarator OPEN_SQUARE_BRACKET type_qualifier_list assignment_expression CLOSED_SQUARE_BRACKET
                        { 
                            yyinfo("direct_declarator -> direct_declarator [ type_qualifier_list assignment_expression ]"); 
                        }
                    | direct_declarator OPEN_SQUARE_BRACKET type_qualifier_list CLOSED_SQUARE_BRACKET
                        { 
                            yyinfo("direct_declarator -> direct_declarator [ type_qualifier_list ]"); 
                        }
                    | direct_declarator OPEN_SQUARE_BRACKET assignment_expression CLOSED_SQUARE_BRACKET
                        { 
                            yyinfo("direct_declarator -> direct_declarator [ assignment_expression ]"); 
                            sym_type *it1 = $1->type, *it2 = NULL;
                            while(it1->type == sym_type::_type::ARR) { 
                                it2 = it1;
                                it1 = it1->arrType;
                            }
                            if(it2 != NULL) { 
                                it2->arrType =  new sym_type(sym_type::_type::ARR, atoi($3->symbol->initValue.c_str()), it1);	
                                $$ = $1->updateSym($1->type);
                            }
                            else { 
                                $$ = $1->updateSym(new sym_type(sym_type::_type::ARR, atoi($3->symbol->initValue.c_str()), $1->type));
                            }
                        }
                    | direct_declarator OPEN_SQUARE_BRACKET CLOSED_SQUARE_BRACKET
                        { 
                            yyinfo("direct_declarator -> direct_declarator [ ]"); 
                            sym_type *it1 = $1->type, *it2 = NULL;
                            while(it1->type == sym_type::_type::ARR) { 
                                it1 = it1->arrType;
                            }
                            if(it2 != NULL) { 
                                it2->arrType =  new sym_type(sym_type::_type::ARR, 0, it1);	
                                $$ = $1->updateSym($1->type);
                            }
                            else { 
                                $$ = $1->updateSym(new sym_type(sym_type::_type::ARR, 0, $1->type));
                            }
                        }
                    | direct_declarator OPEN_SQUARE_BRACKET STATIC type_qualifier_list assignment_expression CLOSED_SQUARE_BRACKET
                        { 
                            yyinfo("direct_declarator -> direct_declarator [ static type_qualifier_list assignment_expression ]"); 
                        }
                    | direct_declarator OPEN_SQUARE_BRACKET STATIC assignment_expression CLOSED_SQUARE_BRACKET
                        { 
                            yyinfo("direct_declarator -> direct_declarator [ assignment_expression ]"); 
                        }
                    | direct_declarator OPEN_SQUARE_BRACKET type_qualifier_list STATIC assignment_expression CLOSED_SQUARE_BRACKET
                        { 
                            yyinfo("direct_declarator -> direct_declarator [ type_qualifier_list static assignment_expression ]"); 
                        }
                    | direct_declarator OPEN_SQUARE_BRACKET type_qualifier_list ASTERISK CLOSED_SQUARE_BRACKET
                        { 
                            yyinfo("direct_declarator -> direct_declarator [ type_qualifier_list * ]"); 
                        }
                    | direct_declarator OPEN_SQUARE_BRACKET ASTERISK CLOSED_SQUARE_BRACKET
                        { 
                            yyinfo("direct_declarator -> direct_declarator [ * ]"); 
                        }
                    | direct_declarator OPEN_PARENTHESES change_scope parameter_type_list CLOSED_PARENTHESES
                        { 
                            yyinfo("direct_declarator -> direct_declarator ( parameter_type_list )"); 
                            curr_table->name = $1->name;
                            if($1->type->type != sym_type::_type::VOID) {
                                curr_table->lookup("return")->updateSym($1->type);
                            }
                            //cout << "childTable change: " << $1->childTable << " " << curr_table << endl;
                            $1->childTable = curr_table;
                            $1->grp = sym::Grp::FUNC;
                            curr_table->parent = global_table;
                            switch_table(global_table);
                            curr_symbol = $$;
                        }
                    | direct_declarator OPEN_PARENTHESES identifier_list CLOSED_PARENTHESES
                        { 
                            yyinfo("direct_declarator -> direct_declarator ( identifier_list )"); 
                        }
                    | direct_declarator OPEN_PARENTHESES change_scope CLOSED_PARENTHESES
                        { 
                            yyinfo("direct_declarator -> direct_declarator ( )"); 
                            curr_table->name = $1->name;
                            if($1->type->type != sym_type::_type::VOID) {
                                curr_table->lookup("return")->updateSym($1->type);
                            }
                            //cout << "childTable change: " << $1->childTable << " " << curr_table << endl;
                            $1->childTable = curr_table;
                            $1->grp = sym::Grp::FUNC;
                            curr_table->parent = global_table;
                            switch_table(global_table);
                            curr_symbol = $$;
                        }
                    ;

type_qualifier_list_opt:
                        type_qualifier_list
                            { 
                                yyinfo("type_qualifier_list_opt -> type_qualifier_list"); 
                            }
                        |
                            { 
                                yyinfo("type_qualifier_list_opt -> epsilon"); 
                            }
                        ;

pointer:
        ASTERISK type_qualifier_list_opt
            { 
                yyinfo("pointer -> * type_qualifier_list_opt"); 
                $$ = new sym_type(sym_type::_type::PTR);
            }
        | ASTERISK type_qualifier_list_opt pointer
            { 
                yyinfo("pointer -> * type_qualifier_list_opt pointer"); 
                $$ = new sym_type(sym_type::_type::PTR, 1, $3);
            }
        ;

type_qualifier_list:
                    type_qualifier
                        { 
                            yyinfo("type_qualifier_list -> type_qualifier"); 
                        }
                    | type_qualifier_list type_qualifier
                        { 
                            yyinfo("type_qualifier_list -> type_qualifier_list type_qualifier"); 
                        }
                    ;

parameter_type_list:
                    parameter_list
                        { 
                            yyinfo("parameter_type_list -> parameter_list"); 
                        }
                    | parameter_list COMMA ELLIPSIS
                        { 
                            yyinfo("parameter_type_list -> parameter_list , ..."); 
                        }
                    ;

parameter_list:
                parameter_declaration
                    { 
                        yyinfo("parameter_list -> parameter_declaration"); 
                    }
                | parameter_list COMMA parameter_declaration
                    { 
                        yyinfo("parameter_list -> parameter_list , parameter_declaration"); 
                    }
                ;

parameter_declaration:
                        declaration_specifiers declarator
                            { 
                                yyinfo("parameter_declaration -> declaration_specifiers declarator"); 
                                $2->grp = sym::Grp::PARAMS; 
                                curr_table->params.push_back($2->name);
                            }
                        | declaration_specifiers
                            { 
                                yyinfo("parameter_declaration -> declaration_specifiers"); 
                            }
                        ;

identifier_list:
                IDENTIFIER 
                    { 
                        yyinfo("identifier_list -> IDENTIFIER"); 
                    }
                | identifier_list COMMA IDENTIFIER
                    { 
                        yyinfo("identifier_list -> identifier_list , IDENTIFIER"); 
                    }
                ;

type_name:
            specifier_qualifier_list
                { 
                    yyinfo("type_name -> specifier_qualifier_list"); 
                }
            ;

initialiser:
            assignment_expression
                { 
                    yyinfo("initialiser -> assignment_expression"); 
                    $$ = $1->symbol;
                }
            | OPEN_CURLY_BRACKET initialiser_list CLOSED_CURLY_BRACKET
                { 
                    yyinfo("initialiser -> { initialiser_list }"); 
                }  
            | OPEN_CURLY_BRACKET initialiser_list COMMA CLOSED_CURLY_BRACKET
                { 
                    yyinfo("initialiser -> { initialiser_list , }"); 
                }
            ;

initialiser_list:
                    designation_opt initialiser
                        { 
                            yyinfo("initialiser_list -> designation_opt initialiser"); 
                        }
                    | initialiser_list COMMA designation_opt initialiser
                        { 
                            yyinfo("initialiser_list -> initialiser_list , designation_opt initialiser"); 
                        }
                    ;

designation_opt:
                designation
                    { 
                        yyinfo("designation_opt -> designation"); 
                    }
                |
                    { 
                        yyinfo("designation_opt -> epsilon"); 
                    }
                ;

designation:
            designator_list ASSIGNMENT
                { 
                    yyinfo("designation -> designator_list ="); 
                }
            ;

designator_list:
                designator
                    { 
                        yyinfo("designator_list -> designator"); 
                    }
                | designator_list designator
                    { 
                        yyinfo("designator_list -> designator_list designator"); 
                    }
                ;

designator:
            OPEN_SQUARE_BRACKET constant_expression CLOSED_SQUARE_BRACKET
                { 
                    yyinfo("designator -> [ constant_expression ]"); 
                }
            | DOT IDENTIFIER
                { 
                    yyinfo("designator -> . IDENTIFIER"); 
                }   
            ;

statement:
            labeled_statement
                { 
                    yyinfo("statement -> labeled_statement"); 
                }
            | compound_statement
                { 
                    yyinfo("statement -> compound_statement");
                    $$ = $1; 
                }
            | expression_statement
                { 
                    yyinfo("statement -> expression_statement"); 
                    $$ = new statement();
                    $$->next_list = $1->next_list;
                }
            | selection_statement
                { 
                    yyinfo("statement -> selection_statement"); 
                    $$ = $1;
                }
            | iteration_statement
                { 
                    yyinfo("statement -> iteration_statement"); 
                    $$ = $1;
                }
            | jump_statement
                { 
                    yyinfo("statement -> jump_statement"); 
                    $$ = $1;
                }
            ;

labeled_statement:
                    IDENTIFIER COLON statement
                        { 
                            yyinfo("labeled_statement -> IDENTIFIER : statement"); 
                        }
                    | CASE constant_expression COLON statement
                        { 
                            yyinfo("labeled_statement -> case constant_expression : statement"); 
                        }    
                    | DEFAULT COLON statement
                        { 
                            yyinfo("labeled_statement -> default : statement"); 
                        }
                    ;

compound_statement:
                    OPEN_CURLY_BRACKET block_item_list_opt CLOSED_CURLY_BRACKET
                        { 
                            yyinfo("compound_statement -> { block_item_list_opt }"); 
                            $$ = $2;
                            // switch_table(curr_table->parent); 
                        }
                    ;

block_item_list_opt:
                    block_item_list
                        { 
                            yyinfo("block_item_list_opt -> block_item_list"); 
                            $$ = $1;
                        }
                    |
                        { 
                            yyinfo("block_item_list_opt -> epsilon"); 
                            $$ = new statement();
                        }
                    ;

block_item_list:
                block_item
                    {
                        yyinfo("block_item_list -> block_item"); 
                        $$ = $1;
                    }
                | block_item_list M block_item
                    { 
                        yyinfo("block_item_list -> block_item_list block_item"); 
                        $$ = $3;
                        back_patch($1->next_list,$2);
                    }
                ;

block_item:
            declaration
                { 
                    yyinfo("block_item -> declaration"); 
                    $$ = new statement();
                }
            | statement
                { 
                    yyinfo("block_item -> statement"); 
                    $$ = $1;
                }
            ;

expression_statement:
                        expression_opt SEMI_COLON
                            { 
                                yyinfo("expression_statement -> expression_opt ;"); 
                                $$ = $1;
                            }
                        ;

expression_opt:
                expression
                    { 
                        yyinfo("expression_opt -> expression"); 
                        $$ = $1;
                    }
                |
                    { 
                        yyinfo("expression_opt -> epsilon"); 
                        $$ = new Exp();
                    }
                ;

selection_statement:
                    IF OPEN_PARENTHESES expression CLOSED_PARENTHESES M statement N %prec THEN
                        { 
                            yyinfo("selection_statement -> if ( expression ) statement"); 
                            $$ = new statement();
                            $3->convertToBool();
                            back_patch($3->true_list, $5); 
                            $$->next_list = merge($3->false_list, merge($6->next_list, $7->next_list)); 
                        }
                    | IF OPEN_PARENTHESES expression CLOSED_PARENTHESES M statement N ELSE M statement
                        { 
                            yyinfo("selection_statement -> if ( expression ) statement else statement"); 
                            $$ = new statement();
                            $3->convertToBool();
                            back_patch($3->true_list, $5); 
                            back_patch($3->false_list, $9); 
                            $$->next_list = merge($10->next_list, merge($6->next_list, $7->next_list)); 
                        }
                    | SWITCH OPEN_PARENTHESES expression CLOSED_PARENTHESES statement
                        { 
                            yyinfo("selection_statement -> switch ( expression ) statement"); 
                        }
                    ;

iteration_statement:
                    WHILE M OPEN_PARENTHESES expression CLOSED_PARENTHESES M statement
                        { 
                            yyinfo("iteration_statement -> while ( expression ) statement"); 
                            $$ = new statement();
                            $4->convertToBool();
                            back_patch($7->next_list, $2); 
                            back_patch($4->true_list, $6); 
                            $$->next_list = $4->false_list; 
                            emit("goto", convertToString($2));
                        }
                    | DO M statement M WHILE OPEN_PARENTHESES expression CLOSED_PARENTHESES SEMI_COLON
                        { 
                            yyinfo("iteration_statement -> do statement while ( expression ) ;"); 
                            $$ = new statement();
                            $7->convertToBool();
                            back_patch($7->true_list, $2);
                            back_patch($3->next_list, $4); 
                            $$->next_list = $7->false_list;
                        }
                    | FOR OPEN_PARENTHESES expression_opt SEMI_COLON M expression_opt SEMI_COLON M expression_opt N CLOSED_PARENTHESES M statement
                        { 
                            yyinfo("iteration_statement -> for ( expression_opt ; expression_opt ; expression_opt ) statement"); 
                            $$ = new statement();
                            $6->convertToBool();
                            back_patch($6->true_list, $12); 
                            back_patch($10->next_list, $5); 
                            back_patch($13->next_list, $8); 
                            emit("goto", convertToString($8));
                            $$->next_list = $6->false_list; 
                        }
                    | FOR OPEN_PARENTHESES declaration expression_opt SEMI_COLON expression_opt CLOSED_PARENTHESES statement
                        { 
                            yyinfo("iteration_statement -> for ( declaration expression_opt ; expression_opt ) statement"); 
                        }
                    ;

jump_statement:
                GOTO IDENTIFIER SEMI_COLON
                    { 
                        yyinfo("jump_statement -> goto IDENTIFIER ;"); 
                    }    
                | CONTINUE SEMI_COLON
                    { 
                        yyinfo("jump_statement -> continue ;"); 
                    }
                | BREAK SEMI_COLON
                    { 
                        yyinfo("jump_statement -> break ;"); 
                    }
                | RETURN expression_opt SEMI_COLON
                    { 
                        yyinfo("jump_statement -> return expression_opt ;"); 
                        $$ = new statement();
                        if($2->symbol != NULL) {
                            emit("return", $2->symbol->name); 
                        } else {
                            emit("return", "");
                        }
                    }
                ;

translation_unit:
                    external_declaration
                        { 
                            yyinfo("translation_unit -> external_declaration"); 
                        }
                    | translation_unit external_declaration
                        { 
                            yyinfo("translation_unit -> translation_unit external_declaration"); 
                        }
                    ;

external_declaration:
                        function_definition
                            { 
                                yyinfo("external_declaration -> function_definition"); 
                            }
                        | declaration
                            { 
                                yyinfo("external_declaration -> declaration"); 
                            }
                        ;

function_definition: 
                    declaration_specifiers declarator declaration_list_opt change_scope OPEN_CURLY_BRACKET block_item_list_opt CLOSED_CURLY_BRACKET
                        { 
                            yyinfo("function_definition -> declaration_specifiers declarator declaration_list_opt compound_statement"); 
                            table_cnt = 0;
                            emit("labelend", $2->name);
                            if($2->type->type != sym_type::_type::VOID) {
                                curr_table->lookup("return")->updateSym($2->type);
                            }
                            switch_table(global_table);
                        }
                    ;

declaration_list_opt:
                        declaration_list
                            { 
                                yyinfo("declaration_list_opt -> declaration_list"); 
                            }
                        |
                            { 
                                yyinfo("declaration_list_opt -> epsilon"); 
                            }
                        ;

declaration_list:
                    declaration
                        { 
                            yyinfo("declaration_list -> declaration"); 
                        }
                    | declaration_list declaration
                        { 
                            yyinfo("declaration_list -> declaration_list declaration"); 
                        }
                    ;

M: {
    yyinfo("M -> epsilon");
    $$ = next_instrn();
};

N: {
    yyinfo("N -> epsilon");
    $$ = new statement();
    $$->next_list = make_list(next_instrn());
    emit("goto", "");
};

// change_block: {
//                 string name = curr_table->name + "_" + convertToString(table_cnt);
//                 table_cnt++;
//                 sym *s = curr_table->lookup(name);
//                 s->childTable = new sym_table(name, curr_table);
//                 s->type = new sym_type(sym_type::_type::BLOCK);
//                 curr_symbol = s;
//             };


change_scope: {
                yyinfo("change scope");
                if(curr_symbol->childTable == NULL) {
                    switch_table(new sym_table(""));
                }
                else {
                    switch_table(curr_symbol->childTable);
                    emit("label", curr_table->name);
                }
            };

%%

void yyerror(string e) {
    printf("Error in line %d: %s\n", lineCounter, e.c_str());
}

void yyinfo(string s) {
    // Uncomment while debugging...
    // printf("Line %d: %s\n", lineCounter, s.c_str());
    // fflush(stdout);
}
