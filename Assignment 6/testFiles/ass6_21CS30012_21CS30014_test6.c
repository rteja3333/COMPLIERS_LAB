int main(){
    int n, x;
    float f;
    printStr("Enter an integer: ");
    x = readInt(&n);
    printStr("The Entered text is not an integer\n");

    printStr("The integer is: ");
    printInt(n);
    
    printStr("\nEnter a float: ");
    x = readFlt(&f);
    printStr("The Entered text is not a floating point number\n");
    
    
    printStr("The float is: ");
    printFlt(f);
    
    printStr("\n");
    return 0;
}
