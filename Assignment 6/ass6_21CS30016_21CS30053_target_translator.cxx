#include "ass6_21CS30016_21CS30053_translator.h"
#include <fstream>

activation_record *current_func_act_rec;

map<int, string> returnRegMap = {{1, "al"}, {4, "eax"}, {8, "rax"}};
vector<map<int, string>> paramRegMap = {{{1, "dil"}, {4, "edi"}, {8, "rdi"}},
                                  {{1, "sil"}, {4, "esi"}, {8, "rsi"}},
                                  {{1, "dl"}, {4, "edx"}, {8, "rdx"}},
                                  {{1, "cl"}, {4, "ecx"}, {8, "rcx"}}};

map<int, string> labelsInAsm;

string getReg(_regType regType, int size, int paramIndex = 0) {
    //cout << "getReg: " << regType << " " << size << " " << paramIndex << endl;
    return regType == _regType::RET ? "%" + returnRegMap[size] : "%" + paramRegMap[paramIndex][size];
}

int getCharAscii(string a) {
    //cout << "getCharAscii" << endl;
    return (int)a[1];
}

string stack_location(string param) {
    //cout << "stack_location" << endl;
    if(current_func_act_rec->shift.count(param))
        return convertToString(current_func_act_rec->shift[param]) + "(%rbp)";
    else 
        return param;
}

void pushRegtoStack(string paramName, int paramIndex) {
    //cout << "pushRegtoStack" << endl;
    sym *symbol = curr_table->lookup(paramName);
    int size = symbol->size;
    auto s_type = symbol->type->type;
    string mov_instruction = "mov";
    if(s_type == sym_type::ARR) size = 8;
    if (size == 1) {
        mov_instruction += "b";
    } else if (size == 4) {
        mov_instruction += "l";
    } else if (size == 8) {
        mov_instruction += "q";
    }
    string reg = getReg(_regType::PARAM, size, paramIndex);
    cout << "\t" << mov_instruction << " " << reg << ", " << stack_location(paramName) << endl;
}


void popRegfromStack(string paramName, int paramIndex) {
    //cout << "popRegfromStack" << endl;
    sym *symbol = curr_table->lookup(paramName);
    int size = symbol->size;
    auto s_type = symbol->type->type;
    string mov_instruction = "mov";
    if(s_type == sym_type::ARR) size = 8;
    if (size == 1) {
        mov_instruction += "b";
    } else if (size == 4) {
        mov_instruction += "l";
    } else if (size == 8) {
        if(s_type == sym_type::ARR) mov_instruction = "leaq";
        else mov_instruction += "q";
    }
    string reg = getReg(_regType::PARAM, size, paramIndex);

    cout << "\t" << mov_instruction << " " << stack_location(paramName) << ", " << reg << endl;
}

void makeAssembly(string inputFile, string outputFile) {

    ofstream out(outputFile);
    streambuf *coutbuf = cout.rdbuf();
    cout.rdbuf(out.rdbuf());
    //cout << "makeAssembly" << endl;
    int labelCount = 0;
    bool isFuncBody = false;
    string glbString;
    string funcEndLabel;
    stack<string> parameters; 
    int glbInt, glbChar;


    cout << "\t.file\t" << "\"" << inputFile << "\"\n" << endl;

    cout << "#\tTemporary and function variables:-\n" << endl;
    
    for(auto &symbolIterator: global_table->symbolMap) {
        if(symbolIterator.second.grp == sym::Grp::FUNC) {
            cout << "#\t" << symbolIterator.second.name << endl;
            for(auto &arIterator : symbolIterator.second.childTable->act_rec->shift) {
                cout << "#\t" << arIterator.first << ": " << arIterator.second << endl;
            }
        }
    }
    cout << endl;

    if(str_list.size() >= 1) {
        cout << "\t.section\t.rodata" << endl;
        for(auto strListIterator = str_list.begin(); strListIterator != str_list.end(); strListIterator++) {
            cout << ".LC" << (strListIterator - str_list.begin()) << ":" << endl;
            cout << "\t.string\t" << *strListIterator << endl;
        }
    }

    for(auto &symbolIterator : global_table->symbolMap) {
        if(symbolIterator.second.initValue.empty() && symbolIterator.second.grp == sym::Grp::GLB) {
            cout << "\t.comm\t" << symbolIterator.first << ", " << symbolIterator.second.size << ", " << symbolIterator.second.size << endl;
        }
    }

    for(auto quadIterator = quad_arr.begin(); quadIterator != quad_arr.end(); quadIterator++) {
        if((*quadIterator)->opcode == "label") {
            labelsInAsm[quadIterator - quad_arr.begin() + 1] = ".LFB" + convertToString(labelCount);
        }
        else if((*quadIterator)->opcode == "labelend") {
            labelsInAsm[quadIterator - quad_arr.begin() + 1] = ".LFE" + convertToString(labelCount++);
        }
    }

    for(auto quadIterator = quad_arr.begin(); quadIterator != quad_arr.end(); quadIterator++) {
        if((*quadIterator)->opcode == "goto" || (*quadIterator)->opcode == "==" || (*quadIterator)->opcode == "!=" || (*quadIterator)->opcode == "<" || (*quadIterator)->opcode == ">" || (*quadIterator)->opcode == "<=" || (*quadIterator)->opcode == ">=") {
            int temp = stoi((*quadIterator)->result);
            if(labelsInAsm.count(temp) == 0) {
                labelsInAsm[temp] = ".L" + convertToString(labelCount++);
            }
        }
    }

    for(auto quadIterator = quad_arr.begin(); quadIterator != quad_arr.end(); quadIterator++) {

        int quadIndex = int(quadIterator - quad_arr.begin()) + 1;
        
        if((*quadIterator)->opcode =="label"){
            if(isFuncBody == false) {
                cout << "\t.text" << endl;
                isFuncBody = true;
            }
            curr_table = global_table->lookup((*quadIterator)->result)->childTable;
            int param_cnt = 1;
            current_func_act_rec = curr_table->act_rec;
            funcEndLabel = labelsInAsm[quadIndex];
            funcEndLabel[3] = 'E';

            cout << "\t" << ".globl " << (*quadIterator)->result << endl;
            cout << "\t" << ".type " << (*quadIterator)->result << ", @function" << endl;
            cout << (*quadIterator)->result << ":" << endl;
            cout << labelsInAsm[quadIndex] << ":" << endl;
            cout << "\t" << ".cfi_startproc" << endl;
            cout << "\t" << "pushq " << "%rbp" << endl;
            cout << "\t.cfi_def_cfa_offset 16" << endl;
            cout << "\t.cfi_offset 6, -16" << endl;
            cout << "\t" << "movq " << "%rsp, %rbp" << endl;
            cout << "\t.cfi_def_cfa_register 6" << endl;
            cout << "\t" << "subq " << "$" << -current_func_act_rec->final_shift << ", %rsp" << endl;

            for(auto param:curr_table->params){
                pushRegtoStack(param, param_cnt);
                param_cnt++;
            }
        }
        else if((*quadIterator)->opcode =="labelend") {
            // cout << labelsInAsm[quadIterator - quad_arr.begin()] << ":" << endl;
            cout << "\t" << "movq " << "%rbp, %rsp" << endl;
            cout << "\t" << "popq " << "%rbp" << endl;
            cout << "\t" << ".cfi_def_cfa 7, 8" << endl;
            cout << "\t" << "ret" << endl;
            cout << "\t" << ".cfi_endproc" << endl;
            cout << labelsInAsm[quadIndex] << ":" << endl;
            cout << "\t" << ".size " << (*quadIterator)->result << ", .-" << (*quadIterator)->result << endl;
        }
        else {
            if(isFuncBody) {

                if(labelsInAsm.count(quadIndex) != 0) {
                    cout << labelsInAsm[quadIndex] << ":" << endl;
                }

                string opcode = (*quadIterator)->opcode, arg1 = (*quadIterator)->arg1, arg2 = (*quadIterator)->arg2, result = (*quadIterator)->result;

                if(opcode == "=") {
                    if(isdigit(arg1[0])) {
                        cout << "\t" << "movl $" << arg1 << ", " << stack_location(result) << endl;
                    } else if(arg1[0] == '\'') {
                        cout << "\t" << "movb $" << getCharAscii(arg1) << ", " << stack_location(result) << endl;
                    }
                    else {
                        switch(curr_table->lookup(arg1)->size) {
                            case 1:
                                cout << "\t" << "movb " << stack_location(arg1) << ", %al" << endl;
                                cout << "\t" << "movb %al, " << stack_location(result) << endl;
                                break;
                            case 4:
                                cout << "\t" << "movl " << stack_location(arg1) << ", %eax" << endl;
                                cout << "\t" << "movl %eax, " << stack_location(result) << endl;
                                break;
                            case 8:
                                cout << "\t" << "movq " << stack_location(arg1) << ", %rax" << endl;
                                cout << "\t" << "movq %rax, " << stack_location(result) << endl;
                                break;
                            default:
                                break;
                        }
                    }
                }
                else if(opcode == "=str") {
                    cout << "\t" << "movq $.LC" << arg1 << ", " << stack_location(result) << endl;
                }
                else if(opcode == "param") {
                    parameters.push(result);
                }
                else if(opcode == "call") {
                    int paramsCount = stoi(arg2);
                    while(paramsCount) {
                        popRegfromStack(parameters.top(), --paramsCount);
                        parameters.pop();
                    }

                    cout << "\tcall " << arg1 << endl;
                    switch(curr_table->lookup(result)->size) {
                        case 1:
                            cout << "\t" << "movb %al, " << stack_location(result) << endl;
                            break;
                        case 4:
                            cout << "\t" << "movl %eax, " << stack_location(result) << endl;
                            break;
                        case 8:
                            cout << "\t" << "movq %rax, " << stack_location(result) << endl;
                            break;
                        default:
                            break;
                    }
                }
                else if(opcode == "return") {
                    if(!result.empty()) {
                        switch(curr_table->lookup(result)->size) {
                            case 1:
                                cout << "\t" << "movb " << stack_location(result) << ", %al" << endl;
                                break;
                            case 4:
                                cout << "\t" << "movl " << stack_location(result) << ", %eax" << endl;
                                break;
                            case 8:
                                cout << "\t" << "movq " << stack_location(result) << ", %rax" << endl;
                                break;
                            default:
                                break;
                        }
                    }
                    if((quad_arr[quadIndex])->opcode != "labelend") {
                        cout << "\tjmp " << funcEndLabel << endl;
                    }
                }
                else if(opcode == "goto") {
                    cout << "\tjmp " << labelsInAsm[stoi(result)] << endl;
                }
                else if(opcode == "==" || opcode == "!=" || opcode == "<" || opcode == ">" || opcode == "<=" || opcode == ">=") {
                    
                    switch(curr_table->lookup(arg1)->size) {
                        case 1:
                            cout << "\t" << "movb " << stack_location(arg2) << ", %al" << endl;
                            cout << "\t" << "cmpb %al, " << stack_location(arg1) << endl;
                            break;
                        case 4:
                            cout << "\t" << "movl " << stack_location(arg2) << ", %eax" << endl;
                            cout << "\t" << "cmpl %eax, " << stack_location(arg1) << endl;
                            break;
                        case 8:
                            cout << "\t" << "movq " << stack_location(arg2) << ", %rax" << endl;
                            cout << "\t" << "cmpq %rax, " << stack_location(arg1) << endl;
                            break;
                        default:
                            break;
                    }

                    if(opcode == "==") cout << "\tje " << labelsInAsm[stoi(result)] << endl;
                    else if(opcode == "!=") cout << "\tjne " << labelsInAsm[stoi(result)] << endl;
                    else if(opcode == "<") cout << "\tjl " << labelsInAsm[stoi(result)] << endl;
                    else if(opcode == ">") cout << "\tjg " << labelsInAsm[stoi(result)] << endl;
                    else if(opcode == "<=") cout << "\tjle " << labelsInAsm[stoi(result)] << endl;
                    else if(opcode == ">=") cout << "\tjge " << labelsInAsm[stoi(result)] << endl;
                }
                else if(opcode == "+") {
                    if(result == arg1) {
                        cout << "\tincl " << stack_location(result) << endl;
                    }
                    else {
                        cout << "\tmovl " << stack_location(arg1) << ", %eax" << endl;
                        cout << "\taddl " << stack_location(arg2) << ", %eax" << endl;
                        cout << "\tmovl %eax, " << stack_location(result) << endl;
                    }
                }
                else if(opcode == "-") {
                    if(result == arg1) {
                        cout << "\tdecl " << stack_location(result) << endl;
                    }
                    else {
                        cout << "\tmovl " << stack_location(arg1) << ", %eax" << endl;
                        cout << "\tsubl " << stack_location(arg2) << ", %eax" << endl;
                        cout << "\tmovl %eax, " << stack_location(result) << endl;
                    }
                }
                else if(opcode == "*") {
                    cout << "\tmovl " << stack_location(arg1) << ", %eax" << endl;
                    if(isdigit(arg2[0])) {
                        cout << "\timull $" << stack_location(arg2) << ", %eax" << endl;
                    } else {
                        cout << "\timull " << stack_location(arg2) << ", %eax" << endl;
                    }
                    cout << "\tmovl %eax, " << stack_location(result) << endl;
                }
                else if(opcode == "/") {
                    cout << "\tmovl " << stack_location(arg1) << ", %eax" << endl;
                    cout << "\tcdq" << endl;
                    cout << "\tidivl " << stack_location(arg2) << ", %eax" << endl;
                    cout << "\tmovl %eax, " << stack_location(result) << endl;
                }
                else if(opcode == "%") {
                    cout << "\tmovl " << stack_location(arg1) << ", %eax" << endl;
                    cout << "\tcdq" << endl;
                    cout << "\tidivl " << stack_location(arg2) << ", %eax" << endl;
                    cout << "\tmovl %edx, " << stack_location(result) << endl;
                }
                else if(opcode == "=[]") {
                    sym* symbol = curr_table->lookup(arg1);
                    if(symbol->grp == sym::Grp::PARAMS) {
                        cout << "\tmovl " << stack_location(arg2) << ", %eax" << endl;
                        cout << "\tcltq" << endl;
                        cout << "\taddq " << stack_location(arg1) << ", %rax" << endl;
                        cout << "\tmovl (%rax), %eax" << endl;
                        cout << "\tmovl %eax, " << stack_location(result) << endl;
                    } else {
                        cout << "\tmovl " << stack_location(arg2) << ", %eax" << endl;
                        cout << "\tcltq" << endl;
                        cout << "\taddq " << stack_location(arg1) << ", %rax" << endl;
                        cout << "\tmovl " << current_func_act_rec->shift[arg1] << "(%rbp, %rax, 1), %eax" << endl;
                        cout << "\tmovl %eax, " << stack_location(result) << endl;
                    }
                }
                else if(opcode == "[]=") {
                    sym* symbol = curr_table->lookup(result);
                    if(symbol->grp == sym::Grp::PARAMS) {
                        cout << "\tmovl " << stack_location(arg1) << ", %eax" << endl;
                        cout << "\tcltq" << endl;
                        cout << "\taddq " << stack_location(result) << ", %rax" << endl;
                        cout << "\tmovl " << stack_location(arg2) << ", %ebx" << endl;
                        cout << "\tmovl %ebx, (%rax)" << endl;
                    } else {
                        cout << "\tmovl " << stack_location(arg1) << ", %eax" << endl;
                        cout << "\tcltq" << endl;
                        cout << "\tmovl " << stack_location(arg2) << ", %ebx" << endl;
                        cout << "\tmovl %ebx, " << current_func_act_rec->shift[result] << "(%rbp, %rax, 1)" << endl;
                    }
                }
                else if(opcode == "=&") {
                    cout << "\tleaq " << stack_location(arg1) << ", %rax" << endl;
                    cout << "\tmovq %rax, " << stack_location(result) << endl;
                }
                else if(opcode == "=*") {
                    cout << "\tmovq " << stack_location(arg1) << ", %rax" << endl;
                    cout << "\tmovl (%rax), %eax" << endl;
                    cout << "\tmovl %eax, " << stack_location(result) << endl;
                }
                else if(opcode == "=-") {
                    cout << "\tmovl " << stack_location(arg1) << ", %eax" << endl;
                    cout << "\tnegl %eax" << endl;
                    cout << "\tmovl %eax, " << stack_location(result) << endl;
                }
                else if(opcode == "*=") {
                    cout << "\tmovl " << stack_location(arg1) << ", %eax" << endl;
                    cout << "\tmovq " << stack_location(result) << ", %rbx" << endl;
                    cout << "\tmovl %eax, (%rbx)" << endl;
                }
            }
            else {
                curr_symbol = global_table->lookup((*quadIterator)->result);

                if(curr_symbol->grp == sym::TEMP){
                    if(curr_symbol->type->type == sym_type::CHAR)
                        glbChar = getCharAscii((*quadIterator)->arg1);
                    else if(curr_symbol->type->type == sym_type::INT)
                        glbInt = stoi((*quadIterator)->arg1);
                    else if(curr_symbol->type->type == sym_type::PTR)
                        glbString = ".LC" + (*quadIterator)->arg1;
                }
                else {
                    if(curr_symbol->type->type == sym_type::CHAR) {
                        cout << "\t" << ".globl " << curr_symbol->name << endl;
                        cout << "\t" << ".data " << endl;
                        cout << "\t" << ".type " << curr_symbol->name << ", @object" << endl;
                        cout << "\t" << ".size " << curr_symbol->name << ", 1" << endl;
                        cout << curr_symbol->name << ":" << endl;
                        cout << "\t" << ".byte " << glbChar << endl;
                    } 
                    else if(curr_symbol->type->type == sym_type::INT) {
                        cout << "\t" << ".globl " << curr_symbol->name << endl;
                        cout << "\t" << ".data " << endl;
                        cout << "\t" << ".align " << 4 << endl;
                        cout << "\t" << ".type " << curr_symbol->name << ", @object" << endl;
                        cout << "\t" << ".size " << curr_symbol->name << ", 4" << endl;
                        cout << curr_symbol->name << ":" << endl;
                        cout << "\t" << ".long " << glbInt << endl;
                    } 
                    else if(curr_symbol->type->type == sym_type::PTR) {
                        cout << "\t" << ".section	.data.rel.local" << endl;
                        cout << "\t" << ".align " << 8 << endl;
                        cout << "\t" << ".type " << curr_symbol->name << ", @object" << endl;
                        cout << "\t" << ".size " << curr_symbol->name << ", 8" << endl;
                        cout << curr_symbol->name << ":" << endl;
                        cout << "\t" << ".quad " << glbString << endl;
                    }
                }
                
            }
        }
    }
    
    cout.rdbuf(coutbuf);
}

int main(int argc, char const *argv[]) {
    temp_cnt = table_cnt = 0;  // initialize global variables
    global_table = new sym_table("glb");
    curr_table = global_table;
    
    yyin = fopen(argv[1], "r");
    if(!yyin) cout<<"Error opening file\n";
    yyparse();
    
    global_table->update();
    global_table->print();
    back_patch_last();

    //quad_arr->print();
    int lineNo = 1;
    for(auto quad: quad_arr) {
        cout << lineNo++ << ": ";
        quad->print();
    }

    makeAssembly(string(argv[1]), string(argv[2]));

    return 0;
}
