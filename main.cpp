#include <stdio.h>
#include <stdlib.h>

extern "C" int my_printf(const char* fmt, ...);

int main()
{
    int test_var = 12345;
    my_printf("Oaoaoa \n%s %c %% %c  %x   %x   %b   %o   %x    %x   %x \n",
                     "ILS", 'f',  's', 'c', 'a', 'a', 'a', 777, 888, 999);

    //exit(0);
    __asm__ __volatile__(
        "movq $60, %rax\n\t"  // sys_exit (0x3C = 60)
        "xorq %rdi, %rdi\n\t" // exit(0)
        "syscall"
    );

}
