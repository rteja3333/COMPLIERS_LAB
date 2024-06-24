int main(){
    int n, x;
    float f;
    printStr("Enter an integer: ");
    x = readInt(&n);
    printStr("input of an integer is taken"\n);
    

    printStr("The integer is: ");
    printInt(n);
    
    printStr("\nEnter a float: ");
    x = readFlt(&f);
    
    printStr("input of an float is taken\n");

    printStr("The float is: ");
    printFlt(f);
    
    printStr("\n");
    return 0;
}
