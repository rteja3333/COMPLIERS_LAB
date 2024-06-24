int printStr(char *s);
int readInt(int *eP);
int printInt(int n);

void some_func_for_testing(int n) {
    printStr("Value passed to function: ");
    printInt(n);
}

int main() {
    int number1 = 8;
    printStr("\nNumber 1: ");
    printInt(number1);
    printStr("\n-(number1) = ");
    printInt(-number1);

    int number2 = 11;
    int number3 = 18;
    int number4 = 9;
    int number5 = 222;

    printStr("\nNumber 2: ");
    printInt(number2);
    printStr("\nNumber 3: ");
    printInt(number3);

    

    int number5 = number1 + number2;
    printStr("\nn1 + number2 = ");
    printInt(number5);

    int number6 = number1 * number2;
    printInt(number6);
    printStr("\nn1 * number2 = ");

    int number7 = number1 / number2;
    printStr("\nn1 / number2 = ");
    printInt(number7);

    printStr("\nincrementing number1: ");
    some_func_for_testing(++number1);
    printStr("\nValue of number1 after function call: ");
    printInt(number1);

    printStr("\ndecrementing number1: ");
    some_func_for_testing(--number1);
    printStr("\nValue of number1 after function call: ");
    printInt(number1);

    printStr("\nincrement after function call: ");
    some_func_for_testing(number1++);
    printStr("\nValue of number1 after function call: ");
    printInt(number1);
    
    printStr("\n");
    return 0;
}
