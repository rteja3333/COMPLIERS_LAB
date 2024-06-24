int printStr(char *c);
int printInt(int i);
int readInt(int *eP);


int fibonacci(int a){
  printStr("\nEntered fibonacci function for n = ");
  printInt(a);
  int b=a-1,c,d;
  if(b<=0) return 1;
  else {
    c=fibonacci(b);
    b=b-1;
    d=fibonacci(b);
    c=c+d;
    return c;
  }
  return 1;
}

int main () {
  int eP;
  printStr("\n\nRecursive Fibonacci function\n\n");
  printStr("\nEnter a value of n: ");
  int p = readInt(&eP);
  printStr("\nEntered number is: ");
  int c = printInt(p);
  printStr("\n");
  printStr("\nCalling Fibonacci function \n");
  int ret=0;
  ret=fibonacci(p);
  printStr("\n\nReturned from recursive fibonacci function\n");
  printStr("----------- SUCCESSFULLY TERMINATED ----------");

}