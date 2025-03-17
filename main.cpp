// #include <stdio.h>

extern "C" int my_printf(const char* fmt, ...);

int main()
{
    int test_var = 12345;
    my_printf("Oaoaoa %c %% %c  %x    %x   %x   %x    %x   %x\n",
                     'f',  's', 'c', 'a', 'l', 777, 888, 999);

    return 0;
}
