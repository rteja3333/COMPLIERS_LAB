#include <stdio.h>

// Keywords
int main() {
    auto a = 10;
    /*break;
    char c = 'A';
    const int x = 5;
    continue;*/
    default:
    do {
        double d = 3.14;
    } while(0);
    /*else {
        enum Color { RED, GREEN, BLUE };*/
    }
    extern int e;
    float f = 2.718;
    for (int i = 0; i < 5; i++) {
        goto label;
    }
    if (a < 5) {
        inline_func();
    }
    int i = 42;
    long l = 1234567890;
    register int r = 7;
    restrict int rp = 9;
    return 0;
    short s = 20;
    signed int si = -3;
    sizeof(int);
    static int st = 15;
    struct Point {
        int x;
        int y;
    };
    switch (c) {
        case 'A':
            break;
    }
    typedef int integer;
    union Data {
        int num;
        float f;
    };
    unsigned int ui = 50;
    void *ptr;
    volatile int v = 8;
    while (a > 0) {
        a--;
    }
    _Bool flag = 1;
    _Complex cx = 2 + 3i;
    _Imaginary im = 4 + 5I;
    
label:
    return 0;
}

// Identifiers
int identifier_nondigit = 1;
int a_identifier = 2;
int x123 = 3;

// Constants
int integer_constant = 42;
float floating_constant = 3.14159;
enum ColorEnum { RED, GREEN, BLUE };
enum ColorEnum color_constant = GREEN;
char character_constant = 'X';

// String literals
const char *string_literal = "Hello, world!";

// Punctuators
int main() {
    int arr[5] = {1, 2, 3, 4, 5};
    printf("Hello" "World");  // String concatenation
    return 0;
}
