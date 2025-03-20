CFLAGS = -D _DEBUG -ggdb3 -std=c++17 -O0 -Wall -Wextra -Weffc++ -Waggressive-loop-optimizations -Wc++14-compat -Wmissing-declarations -Wcast-align -Wcast-qual -Wchar-subscripts -Wconditionally-supported -Wconversion -Wctor-dtor-privacy -Wempty-body -Wfloat-equal -Wformat-nonliteral -Wformat-security -Wformat-signedness -Wformat=2 -Winline -Wlogical-op -Wnon-virtual-dtor -Wopenmp-simd -Woverloaded-virtual -Wpacked -Wpointer-arith -Winit-self -Wredundant-decls -Wshadow -Wsign-conversion -Wsign-promo -Wstrict-null-sentinel -Wstrict-overflow=2 -Wsuggest-attribute=noreturn -Wsuggest-final-methods -Wsuggest-final-types -Wsuggest-override -Wswitch-default -Wswitch-enum -Wsync-nand -Wundef -Wunreachable-code -Wunused -Wuseless-cast -Wvariadic-macros -Wno-literal-suffix -Wno-missing-field-initializers -Wno-narrowing -Wno-old-style-cast -Wno-varargs -Wstack-protector -fcheck-new -fsized-deallocation -fstack-protector -fstrict-overflow -flto-odr-type-merging -fno-omit-frame-pointer -Wlarger-than=8192 -Wstack-usage=8192 -Werror=vla -fsanitize=alignment,bool,bounds,enum,float-cast-overflow,float-divide-by-zero,integer-divide-by-zero,leak,nonnull-attribute,null,object-size,return,returns-nonnull-attribute,shift,signed-integer-overflow,undefined,unreachable,vla-bound,vptr

debug:
	nasm -f elf64 -l listing/my_printf.lst my_printf.s -o build/my_printf.o
	gcc -c main.cpp -o build/main.o -O0 -fPIE -no-pie
#$(CFLAGS)
	gcc -o print.out build/my_printf.o build/main.o -lc -fPIE -no-pie -g -e main -static
# $(CFLAGS)

all:
	nasm -f elf64 -l listing/my_printf.lst my_printf.s -o build/my_printf.o
	gcc -c main.cpp -o build/main.o -O0 -fPIE -no-pie $(CFLAGS)
	gcc -o print.out build/my_printf.o build/main.o -lc -fPIE -no-pie -g  $(CFLAGS)

help:
	nasm -f elf64 -l listing/my_printf.lst my_printf.s -o build/my_printf.o
	gcc -c main.cpp -o build/main.o -fPIE $(CFLAGS) -no-pie
	gcc -o print.out build/my_printf.o build/main.o -lc -fPIE -no-pie $(CFLAGS) -g

help2:
	nasm -f elf64 -l listing/my_printf.lst my_printf.s -o build/my_printf.o
	gcc -c main.cpp -o build/main.o -fPIE $(CFLAGS) -no-pie -O0
	gcc -o print.out build/my_printf.o build/main.o -lc -fPIE -no-pie -static -e main $(CFLAGS) -g

run:
	edb --run print.out
	./print.out
