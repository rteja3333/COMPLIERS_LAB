int printStr(char *s);
int readInt(int *eP);
int printInt(int n);

int main() {    
    int num1 = 809;
    printStr("\nNumber 1: ");
    printInt(num1);

    int num2 = 1109;
    printStr("\nNumber 2: ");
    printInt(num2);

    int num3 = 1809;
    printStr("\nNumber 3: ");
    printInt(num3);

    printStr("\nTesting operators \n");

    printStr("\nTesting != operator: ");
    if (num1 != num2) {
        printStr("Pass");
    }
    else {
        printStr("Fail");
    }

    printStr("\nTesting == operator:");
    num2 = 809;
    if (num1 == num2) {
        printStr("Pass");
    }
    else {
        printStr("Fail");
    }

    printStr("\nTesting < operator: ");
    num2 = num3;
    if (num1 < num2) {
        printStr("Pass");
    }
    else {
        printStr("Fail");
    }

    num2 = -81;
    num1 = 7;
    printStr("\nTesting > operator: ");
    if (num1 > num2) {
        printStr("Pass");
    }
    else {
        printStr("Fail");
    }

    num1 = -81;
    printStr("\nTesting <= operator: ");
    if (num1 <= num2) {
        printStr("Pass");
    }
    else {
        printStr("Fail");
    }

    printStr("\nTesting <= operator: ");
    if (num1 <= num2) {
        printStr("Pass");
    }
    else {
        printStr("Fail");
    }
    printStr("\n");
    return 0;
}
