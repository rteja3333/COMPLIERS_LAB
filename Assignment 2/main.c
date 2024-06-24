#include <stdio.h>
#include <unistd.h>

int printStr(char *c);
int readInt(int *n);
int readFlt(float *f);
int printFlt(float f);

int main() {
    char str[] = "Hello, World!";
    printf("Printing string: %s\n", str);
    int strLength = printStr(str);
    printf("String length: %d\n", strLength);

    printf("Enter an integer: ");
    int numInt;
    int resultInt = readInt(&numInt);
    if (resultInt == 1) {
        printf("You entered: %d\n", numInt);
    } else {
        printf("Invalid input\n");
    }

    printf("Enter a floating-point number: ");
    float numFloat;
    int resultFloat = readFlt(&numFloat);
    if (resultFloat == 1) {
        printf("You entered: %f\n", numFloat);
    } else {
        printf("Invalid input\n");
    }

    float testFloat = 12345.6789;
    printf("Printing float: %f\n", testFloat);
    int floatChars = printFlt(testFloat);
    printf("\nTotal characters printed: %d\n", floatChars);

    return 0;
}
