int printInt(int num);
int printStr(char * c);
int readInt(int *eP);
int main()
{
    printStr("\nMultiplying two numbers\n");
    int p;
    printStr("\nEnter first number: ");
    int a = readInt(&p);
    printStr("\nEnter second number: ");
    int b = readInt(&p);
    printStr("\nNum 1 = ");
    printInt(a);
    printStr("\nNum 2 = ");
    printInt(b);
    printStr("\nProduct = ");
    printInt(a*b);
    printStr("\n");
    return 0;
}