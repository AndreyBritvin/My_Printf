all:
	nasm -f elf64 -l listing/my_printf.lst my_printf.s -o build/my_printf.o
	gcc -c main.cpp -o build/main.o -O0
	ld -e main -o print.out build/my_printf.o build/main.o

run:
	edb --run print.out
	./print.out
