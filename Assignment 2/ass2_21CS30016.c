
#define BUFF 20
#define OK 1
#define ERR -1
#define MAX_BUFFER_SIZE 100


int printStr(char *str){
    int i=0;
    char buff[MAX_BUFFER_SIZE];
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

int printInt(int n) {
    char buff[BUFF], buff1[BUFF], zero = '0';
    int i = 0, j, k, bytes;
    int flag = OK;

    if (n == 0) {
        buff[i++] = zero;
    } else {
        if (n < 0) {
            buff[i++] = '-';
            n *= -1;
        }
        while (n) {
            int d = n % 10;
            buff[i++] = (char)(zero + d);
            n /= 10;
        }
        j = 0;
        k = i - 1;
        while (j < k) {
            buff1[j] = buff[k]; // Corrected copying order
            buff1[k] = buff[j];
            j++;
            k--;
        }
        buff1[j] = '\n';
        bytes = j + 1;

        asm volatile (
            "movq $1, %%rax\n\t"     // Load the syscall number (1 for write) into RAX
            "movq $1, %%rdi\n\t"     // Load file descriptor (1 for stdout) into RDI
            "syscall\n\t"            // Invoke the syscall
            :
            : "S"(buff1), "d"(bytes) // Input constraints for buffer and bytes
            : "rax", "rdi"
        );
    }

    return (flag == OK) ? (i + 1) : ERR; // Return the number of characters printed or ERR
}

int printFlt(float f) {
    char buff[MAX_BUFFER_SIZE];
    int charsPrinted = 0;
    int buffIndex = 0;

    // Handle negative numbers
    if (f < 0) {
        buff[buffIndex++] = '-';
        f = -f;
    } else {
        buff[buffIndex++] = ' ';
    }

    // Print integer part
    int intPart = (int)f;
    if (intPart == 0) {
        buff[buffIndex++] = '0';
        charsPrinted++;
    } else {
        int i = 0;
        while (intPart > 0) {
            int digit = intPart % 10;
            buff[buffIndex++] = digit + '0';
            intPart /= 10;
            i++;
        }
        while (i > 0) {
            i--;
            charsPrinted++;
        }
    }

    // Print decimal point
    buff[buffIndex++] = '.';
    charsPrinted++;

    // Print fractional part
    float fracPart = f - (float)intPart;
    int fracChars = 0;
    while (fracChars < 6) { // Print up to 6 decimal places
        fracPart *= 10;
        int digit = (int)fracPart;
        buff[buffIndex++] = digit + '0';
        fracChars++;
        fracPart -= (float)digit;
    }
    charsPrinted += fracChars;

    buff[buffIndex] = '\0'; // Null-terminate the buffer

    // Print using syscall and inline assembly
    __asm__ __volatile__(
        "movl $1, %%eax\n\t"          // Syscall number for write
        "movq $1, %%rdi\n\t"          // File descriptor (stdout)
        "syscall\n\t"
        :
        : "S" (buff), "d" (buffIndex)  // Input constraints for buffer and length
    );

    return charsPrinted;
}


int readInt(int *n) {
    *n = 0; // Initialize the integer to store the result
    int bytesRead = 0;
    int sign = 1; // Positive by default

    // Read characters until newline or space is encountered
    while (1) {
        char c;
        asm volatile (
            "mov $0, %%rax\n\t" // Syscall number for sys_read
            "mov $0, %%rdi\n\t" // File descriptor (stdin)
            "leaq %[c], %%rsi\n\t" // Address of the character buffer
            "mov $1, %%rdx\n\t" // Number of bytes to read
            "syscall\n\t"
            : 
            : [c] "m" (c)
            : "rax", "rdi", "rsi", "rdx"
        );

        bytesRead++;

        if (c == '\n' || c == ' ') {
            if (bytesRead > 1) { // Check if we've read more than just the newline or space
                break;
            }
        } else if (c == '-') {
            sign = -1; // Set negative sign
        } else if (c >= '0' && c <= '9') {
            *n = (*n * 10) + (c - '0');
        } else {
            return ERR; // Invalid character
        }
    }

    *n *= sign; // Apply the sign

    return OK;
}

int readFlt(float *f) {
    *f = 0.0f; // Initialize the floating-point number to store the result
    //char buffer[20]; // Assuming maximum of 19 characters for a floating-point number
    int bytesRead = 0;
    int negative = 0;
    int started = 0;
    int decimalSeen = 0;
    float decimalMultiplier = 0.1f;

    // Read characters until newline or space is encountered
    while (1) {
        char c;
        asm volatile (
            "mov $0, %%rax\n\t" // Syscall number for sys_read
            "mov $0, %%rdi\n\t" // File descriptor (stdin)
            "leaq %[c], %%rsi\n\t" // Address of the character buffer
            "mov $1, %%rdx\n\t" // Number of bytes to read
            "syscall\n\t"
            : 
            : [c] "m" (c)
            : "rax", "rdi", "rsi", "rdx"
        );

        bytesRead++;

        if (c == '\n' || c == ' ') {
            if (started) {
                break;
            }
        } else if (c == '-' && !started) {
            negative = 1;
        } else if (c == '.' && !decimalSeen) {
            decimalSeen = 1;
        } else if (c >= '0' && c <= '9') {
            started = 1;
            if (decimalSeen) {
                *f += (c - '0') * decimalMultiplier;
                decimalMultiplier *= 0.1f;
            } else {
                *f = (*f * 10.0f) + (c - '0');
            }
        } else {
            return ERR; // Invalid character
        }
    }

    if (negative) {
        *f = -(*f);
    }

    return OK;
}
