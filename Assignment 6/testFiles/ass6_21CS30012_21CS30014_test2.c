int printInt(int num);
int printStr(char * c);
int readInt(int *eP);

int some_function(int *a)
{
    return a;
}

int main()
{
    int a,b;
    int *e;
    
    printStr("\nTesting Functions\n");
    
    b = 3;
    e = &b;

    printStr("\nPassing parameter to function :\n        int some_function(int *a)    \n");
    printStr("\nValue passed to function: ");
    printInt(b);
    printStr("\n");
    
    a = some_function(b);
    printStr("\nAddress returned from function: ");
    printInt(a);
    printStr("\n");
    return 0;
}