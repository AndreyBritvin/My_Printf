all:
	nasm -f elf64 -l listing/my_printf.lst my_printf.s -o build/my_printf.o
	gcc -c main.cpp -o build/main.o
	ld -s -o print.out build/my_printf.o build/main.o

run:
	./print.out
