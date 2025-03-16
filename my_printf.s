;:================================================
;: 0-Linux-nasm-64.s                   (c)Ded,2012
;:================================================

; nasm -f elf64 -l 1-nasm.lst 1-nasm.s  ;  ld -s -o 1-nasm 1-nasm.o

section .text

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

        mov rax, 0x01      ; write64 (rdi, rsi, rdx) ... r10, r8, r9
        mov rdi, 1         ; stdout
        mov rsi, Msg
        mov rdx, MsgLen    ; strlen (Msg)
        syscall

        ; mov rax, 0x3C      ; exit64 (rdi)
        ; xor rdi, rdi
        ; syscall

        mov rsp, rbp
        pop rbp
        mov rbx, [rsp]
        add rsp, 6 * 16
        jmp rbx

flush_buf:

section     .data

Buffer:     resb 64
Msg:        db "Hello World", 0x0a
MsgLen      equ $ - Msg
