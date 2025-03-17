;:================================================
;: 0-Linux-nasm-64.s                   (c)Ded,2012
;:================================================

; nasm -f elf64 -l 1-nasm.lst 1-nasm.s  ;  ld -s -o 1-nasm 1-nasm.o

section .text

%define BUF_POS r15
%define FMT_ADR rbx
%define SYMBOL  r14b
%define CUR_ARG r13
%define BUF_SIZE 64

;-------------------------------------------
; Writes to buffer from
;
; Destr: BUF_POS, FMT_ADR
;-------------------------------------------
%macro WRITE_TO_BUFFER 0
        mov byte [Buffer + BUF_POS], SYMBOL

        inc FMT_ADR
        inc BUF_POS
%endmacro

;-------------------------------------------
; Flushes buffer from buffer
;
; Destr: rax, rdi, rsi, rdx
;-------------------------------------------
%macro FLUSH_BUF 0
        mov rax, 0x01           ; write64 (rdi, rsi, rdx) ... r10, r8, r9
        mov rdi, 1              ; stdout
        mov rsi, Buffer
        mov rdx, 64             ; strlen (Msg)
        syscall
%endmacro

global _start                  ; predefined entry point name for ld
; global _Z9my_printfPKcz
global my_printf


;-------------------------------------------
; My printf. Arguments by fastcall, fmt in rdi (first)
; ...
;-------------------------------------------
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

        xor FMT_ADR, FMT_ADR
        mov FMT_ADR, [rbp + 16]         ; fmt string
        xor BUF_POS, BUF_POS            ; r15 - counter of buffer
        mov CUR_ARG, 3

.parse_char:
        xor r14, r14
        mov SYMBOL, [FMT_ADR]
        cmp SYMBOL, '%'
        je .is_percent
        cmp SYMBOL, 0
        je .end_of_parse

        WRITE_TO_BUFFER                 ; common char

        jmp .parse_char
.is_percent:
        inc rbx
        mov SYMBOL, [rbx]

        cmp SYMBOL, '%'
        je .perc_parse
        ; jump table
        ; TODO: optimise by sub before cmp`s and then cmp only greater
        cmp SYMBOL, 'b'
        jb .wrong_symbol
        cmp SYMBOL, 'x'
        ja .wrong_symbol

        sub SYMBOL, 'b'
        mov rdi, r14
        jmp [.jump_table + rdi * 8]

.jump_table:               ; offset of functions for each of char
        dq .bin_parse      ; b - bin
        dq .chr_parse      ; c - char
        dq .dec_parse      ; d - digit
        times ('x' - 'd' - 1) dq .wrong_symbol  ; not anyone
        dq .hex_parse      ; x - hex

.bin_parse:
        call parse_bin
        jmp .switch_end

.hex_parse:
        call parse_hex
        jmp .switch_end

.dec_parse:
        call parse_hex
        jmp .switch_end

.chr_parse:
        call parse_char
        jmp .switch_end

.perc_parse:
        WRITE_TO_BUFFER
        jmp .switch_end

.wrong_symbol:
        jmp .end_of_parse

.switch_end:
        inc CUR_ARG
        jmp .parse_char

.end_of_parse
        FLUSH_BUF

        mov rsp, rbp
        pop rbp
        mov rbx, [rsp]
        add rsp, 6 * 16         ; restore stack
        jmp rbx                 ; return

parse_char:
        mov SYMBOL, [rbp + CUR_ARG * 8]
        WRITE_TO_BUFFER
        ret

parse_hex:
        mov SYMBOL, [rbp + CUR_ARG * 8]
        mov byte [Buffer + BUF_POS], SYMBOL
        inc BUF_POS
        inc rbx
        ret

parse_dec:
        mov SYMBOL, [rbp + CUR_ARG * 8]
        mov byte [Buffer + BUF_POS], SYMBOL
        inc BUF_POS
        inc rbx
        ret

parse_bin:
        mov SYMBOL, [rbp + CUR_ARG * 8]
        mov byte [Buffer + BUF_POS], SYMBOL
        inc BUF_POS
        inc rbx
        ret

section     .data
Buffer:     resb BUF_SIZE
