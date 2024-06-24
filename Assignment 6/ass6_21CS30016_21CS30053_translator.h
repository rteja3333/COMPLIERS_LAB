#ifndef _TRANSLATOR_H
#define _TRANSLATOR_H

#include <iostream>
#include <map>
#include <vector>
#include <algorithm>
#include <list>
#include <stack>
#include <functional>
#include <iomanip>
#include <string.h>
using namespace std;

extern FILE *yyin;
extern int yyparse();

class sym_type;
class sym_table;
class sym;
class activation_record;
class label;
class quad;
class quad_array;
class Exp;
class arr;
class statement;

// Class definition
class sym_type{
public:
    enum _type {VOID, INT, FLOAT, CHAR, PTR, FUNC, ARR, BLOCK} type;
    int symWidth;
    sym_type* arrType;

    sym_type(_type, int = 1, sym_type* = NULL);
    int getWidth();
    string printType();
};

class sym {
public:
    string name;
    int size;
    int offset;
    sym_type* type;
    sym_table* childTable;
    enum Grp {LOC, GLB, PARAMS, TEMP, FUNC} grp;
    string initValue;

    sym(string, sym_type::_type = sym_type::INT, string = "");
    sym* updateSym(sym_type*);
    sym* typeCast(sym_type::_type);
    sym* linkChildSymTable(sym_table*);
};

enum _regType {RET, PARAM};

class activation_record {
public:
    map<string, int> shift;
    int final_shift;

    activation_record();
};

class sym_table {
public:
    string name;
    map<string, sym> symbolMap;
    vector<string> params;
    sym_table* parent;
    activation_record *act_rec;
    sym_table(string = "NULL", sym_table* = NULL);
    sym* lookup(string);
    void print();
    void update();
};

class quad {
public:
    string opcode, arg1, arg2, result;
    
    //opcode, result, arg1, arg2
    quad(string, string, string, string = ""); 
    quad(string, string, int, string = "");
    quad(string, string, float, string = "");

    void print();
};

class quad_array {
public:
    vector<quad *> array;
    void print();
};

class Exp {
public:
    sym* symbol;
    enum _type {NON_BOOLEAN, BOOLEAN} type;  
    list<int> true_list, false_list, next_list;
    void convertToBool();  
    void convertToInt();
};

class arr {
public: 
    sym* loc;
    enum _type {NEXP, PTR, ARR} type; 
    sym *symbol; 
    sym* ptr_symtable;
    sym_type* arr_type; 
};

class statement {
public:
    list<int> next_list;
};

// emit function for quad generations
// opcode, result, arg1, arg2
void emit(string, string, string = "", string = "");  
void emit(string, string, int, string = "");  
void emit(string, string, float, string = "");  

// backpatching
void back_patch(list<int>, int);
void back_patch_last();
list<int> make_list(int i);
list<int> merge(list<int>, list<int>);

string convertToString(char);
string convertToString(int);  
string convertToString(float);

int next_instrn();
sym *generate_temp(sym_type::_type, string = "");  
void switch_table(sym_table* new_table);  
bool check_sym_type(sym *&s1, sym *&s2);  

// Global variables to be exported to the cxx file
extern vector<quad *> quad_arr; // array of quads
extern sym_table *curr_table; // current symbol table
extern sym_table *global_table; // global symbol table
extern sym *curr_symbol;  // A pointer pointing to the current symbol
extern sym_type::_type curr_type;  // current type
extern int table_cnt, temp_cnt; // counters for symbol table and temporary symbols
extern vector<string> str_list;

#endif