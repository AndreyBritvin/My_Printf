// #include <stdio.h>

extern "C" int my_printf(const char* fmt, ...);

int main()
{
    int test_var = 12345;
    my_printf("Oaoaoa %c %d %x", 'fa', 'st', 'c', 'a', 'll', 777, 888, 999);

    return 0;
}
