#include "myl.h"

#define size 100

int printInt(int n){
    char buff[size],zero='0';
    int i=0,j,k,bytes;
    if(n==0){
        buff[i++]=zero;
    }
    else{
        if(n<0){
            buff[i++]='-';
            n=-n;
        }
        while(n){
            int digit = n%10;
            buff[i++]= (char)(digit+zero);
            n/=10;
        }
        if(buff[0]=='-'){
            j=1;
        }
        else{
            j=0;
        }
        k=i-1;
        while(j<k){
            char temp=buff[j];
            buff[j++]=buff[k];
            buff[k--]=temp;
        }
    }
    buff[i]='\n';
    bytes = i+1;
    __asm__ __volatile__ (
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t"
        "syscall \n\t"
        :
        :"S"(buff), "d"(bytes)
    );
    return k;
}

int printFlt(float f){
    char buff[size],zero='0';
    int i=0,j,k,bytes;
    if(f==0){
        buff[i++]=zero;
    }
    else{
        if(f<0){
            buff[i++]='-';
            f=-f;
        }
        int n = (int)f;
        while(n){
            int digit = n%10;
            buff[i++]= (char)(digit+zero);
            n/=10;
        }
        if(buff[0]=='-'){
            j=1;
        }
        else{
            j=0;
        }
        k=i-1;
        while(j<k){
            char temp=buff[j];
            buff[j++]=buff[k];
            buff[k--]=temp;
        }
        buff[i++]='.';
        f=f-(int)f;
        while(f){
            f*=10;
            int digit = (int)f;
            buff[i++]= (char)(digit+zero);
            f-=digit;
        }
    }
    buff[i]='\n';
    bytes = i+1;
    __asm__ __volatile__ (
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t"
        "syscall \n\t"
        :
        :"S"(buff), "d"(bytes)
    );
    return k;
}

int printStr(char *str){
    int i=0;
    char buff[size];
    while(str[i]!='\0'){
        buff[i]=str[i];
        i++;
    }
    buff[i]='\0';
    int bytes = i+1;
    __asm__ __volatile__ (
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t"
        "syscall \n\t"
        :
        :"S"(buff), "d"(bytes)
    );
    return i;
}

int readInt(int *n){
    char buff[size],zero='0';
    int j,k=0,bytes=20;
    __asm__ __volatile__ (
        "movl $0, %%eax \n\t"
        "movq $0, %%rdi \n\t"
        "syscall \n\t"
        :
        :"S"(buff), "d"(bytes)
    );
    while(buff[k]!='\n'){
        if(buff[k]=='.'){
            return 0;
        }
        k++;
    }
    int x=k;
    printInt(x);
    if((buff[0]<zero || buff[0]>(zero+9))&&!(buff[0]=='-')){
        return 0;
    }
    else{
        if(buff[0]=='-'){
            j=1;
        }
        else{
            j=0;
        }
        *n=0;
        for(int i=0;i<x;i++){
            if(buff[i]=='-'){
                continue;
            }
            *n = (*n)*10 + (buff[i]-'0');
        }
        if(buff[0]=='-'){
            *n=-(*n);
        }
    }
    return 1;

}

int readFlt(float *f){
    char buff[size],zero='0';
    int j,k=0,bytes=20,pos=0;
    __asm__ __volatile__ (
        "movl $0, %%eax \n\t"
        "movq $0, %%rdi \n\t"
        "syscall \n\t"
        :
        :"S"(buff), "d"(bytes)
    );
    while(buff[k]!='\n'){
        k++;
    }
    int n=k;
    if((buff[0]<zero || buff[0]>(zero+9))&&!(buff[0]=='-')){
        return 0;
    }
    else{
        if(buff[0]=='-'){
            j=1;
        }
        else{
            j=0;
        }
        int i=0;
        while(buff[i]!='.'){
            i++;
        }
        pos=i;
        *f=0;
        for(i=0;i<pos;i++){
            if(buff[i]=='-'){
                continue;
            }
            *f = *f*10 + (buff[i]-'0');
        }
      float temp=0.1;
        for(i=pos+1;i<n;i++){

             *f = *f + (buff[i]-'0')*temp;
            temp/=10;
        }
        if(buff[0]=='-'){
            *f=-(*f);
        }

    }
    return 1;
}
