#include <stdio.h>
#include <stdlib.h>

extern "C" int my_printf(const char* fmt, ...);
extern "C" void my_flush();

void flush_exit()
{
    my_flush();
    exit(0);
}

int main()
{

    int test_var = 12345;
    int ret_val2 = my_printf("Hello world\n");
    int ret_val  = my_printf("Oaoaoa %d   \n%s    %c  %% %c  %x   %x   %b   %o   %x    %x   %x \n",
                     12345, "ILS", 'f',  's', 'c', 'a', 'a', 'a', 777, 888, 999);
    my_flush();
    int sec_val = my_printf("Ret val = %d\n", ret_val);
    my_printf("Ret val = %d\n", sec_val);
    my_flush();
    my_flush();
    int res = my_printf("%o\n%d %s %x %d%%%c%b\n%d %s %x %d%%%c%b\n", -1, -1, "love", 3802, 100, 33, 127,
                                                                         -1, "love", 3802, 100, 33, 127);

    return my_printf("%d\n", res) <= 0;

    // atexit(flush_exit);
    // exit(0);
    // __asm__ __volatile__(
    //     "movq $60, %rax\n\t"  // sys_exit (0x3C = 60)
    //     "xorq %rdi, %rdi\n\t" // exit(0)
    //     "syscall"
    // );
    // exit(0);
    return 0;
    // Oaoaoa 5432100000
//ILS    f % s 0x00000063   0x00000061   0b00000000000000000000000001100001   000000000141   0x00000309    0x00000378   0x000003E7
}
