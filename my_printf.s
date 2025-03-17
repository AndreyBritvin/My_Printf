;:================================================
;: 0-Linux-nasm-64.s                   (c)Ded,2012
;:================================================

; nasm -f elf64 -l 1-nasm.lst 1-nasm.s  ;  ld -s -o 1-nasm 1-nasm.o

section .text

%macro FLUSH_BUF 0
        mov rax, 0x01      ; write64 (rdi, rsi, rdx) ... r10, r8, r9
        mov rdi, 1         ; stdout
        mov rsi, Buffer
        mov rdx, 64    ; strlen (Msg)
        syscall
%endmacro

global _start                  ; predefined entry point name for ld
; global _Z9my_printfPKcz
global my_printf

; _Z9my_printfPKcz:
my_printf:
        pop  rax              ; save return address
        push r9
        push r8
        push rcx
        push rdx
        push rsi
        push rdi
        push rax              ; relocate ret address

        push rbp
        mov rbp, rsp

        xor rbx, rbx
        mov rbx, [rbp + 16]     ; fmt string
        xor r15, r15            ; r15 - counter of buffer

.parse_char:
        xor r14, r14
        mov r14b, [rbx]
        cmp r14b, '%'
        je .is_percent
        cmp r14b, 0
        je .end_of_parse

        mov byte [Buffer + r15], r14b

        inc rbx
        inc r15

        jmp .parse_char
.is_percent:
        ; parse
        jmp .parse_char

.end_of_parse
        FLUSH_BUF

        mov rsp, rbp
        pop rbp
        mov rbx, [rsp]
        add rsp, 6 * 16         ; restore stack
        jmp rbx                 ; return



flush_buf:

section     .data

Buffer:     resb 64
Msg:        db "Hello World", 0x0a
MsgLen      equ $ - Msg
