section .text

%define BUF_POS r15
%define FMT_ADR rbx
%define SYMBOL  r14b
%define CUR_ARG r13
%define RET_REG r10
%define BUF_SIZE 64
%define FLUSH_BUF_COM FLUSH_BUF Buffer, BUF_SIZE
%define WRITE_TO_BUFFER WRITE_TO_BUFFER_DIR 0,
;-------------------------------------------
; Writes to buffer from SYMBOL (full register)
; Args: %1 - base, 2/8/10/16
;       %2 - mask           for hex/oct/bin
;       %3 - shifting       for hex/oct/bin
;       %4 - repeating part for hex/oct/bin
;
; Destr: BUF_POS, FMT_ADR, r8b
;-------------------------------------------
%macro WRITE_NUM_TO_BUF 4
        mov r14, [rbp + CUR_ARG * 8]
        mov r12, r14
    push rax
    push rcx
    push rdx
    xor r8b, r8b                                  ; register to check if there some zeros
    ; mov bx, cs
    shl r12, 32                                 ; because this support only 32bit ints

    %if %1 == 8                                 ; because oct has N*3 parts, and 3 is very strange
    shr r12, 1
    %endif

    mov rcx, %4 / 2                                 ; in 16 bit register _4_ parts of 4 bits
    %%GET_DIGIT:
    mov rdx, r12                                ; save in dx
    and r12, %2                                 ; mask first 4 bits
    shr r12, 64 - %3                            ; delete zeros (bc little endian)
    lea r11, [rel HEX_TO_ASCCI_ARR]
    add r11, r12
    mov al, byte [r11]                          ; get ascii character
    shl rdx, %3                                 ; delete first 4 bits and replace new value
    mov r12, rdx                                ; resave dx to bx
    mov SYMBOL, al

    cmp al, '0'
    je %%zero
    mov r8b, 1
    %%zero:
    cmp r8b, 1
    jne %%not_print
    WRITE_TO_BUFFER 0
    %%not_print:
    loop %%GET_DIGIT

    cmp r8b, 0
    jne %%there_were_smth_printed
    WRITE_CHAR_TO_BUFFER '0'
    %%there_were_smth_printed:

    pop rdx
    pop rcx
    pop rax
%endmacro

;-------------------------------------------
; Flushes buffer from buffer
; Args: %1 - addr to print
;       %2 - strlen(%1)
; Destr: rax, rdi, rsi
;-------------------------------------------
%macro FLUSH_BUF 2
        push rdx
        push rcx
        mov rax, 0x01           ; write64 (rdi, rsi, rdx) ... r10, r8, r9
        mov rdi, 1              ; stdout
        mov rsi, %1
        ; mov rsi, Buffer
        mov rdx, %2             ; strlen (Msg)
	    push r10
        syscall
    	pop r10
        mov BUF_POS, 0
        pop rcx
        pop rdx
%endmacro

;-------------------------------------------
; Writes to buffer from SYMBOL
; Args: %1 - 1 = inc FMT_ADR, else 0
;
; Destr: BUF_POS, FMT_ADR
;-------------------------------------------
%macro WRITE_TO_BUFFER_DIR 2
        mov byte [Buffer + BUF_POS], SYMBOL

        %if %2
            inc FMT_ADR
        %endif

        %if %1 == 0
            inc BUF_POS
        %else
            dec BUF_POS
        %endif

        inc RET_REG
        cmp BUF_POS, BUF_SIZE - 1
        jne %%NO_FLUSH
        FLUSH_BUF_COM
        %%NO_FLUSH

%endmacro
;-------------------------------------------

;-------------------------------------------
; Writes to buffer symbol
; Args: %1 - char to write
;
; Destr: BUF_POS
;-------------------------------------------
%macro WRITE_CHAR_TO_BUFFER 1
        mov byte [Buffer + BUF_POS], %1
        inc BUF_POS
        inc RET_REG
        cmp BUF_POS, BUF_SIZE - 1
        jne %%NO_FLUSH
        FLUSH_BUF_COM
        %%NO_FLUSH
%endmacro
;-------------------------------------------

;-------------------------------------------
; Destr: rcx, rdi
; Ret: rcx - strlen(rdi)
;-------------------------------------------
%macro my_strlen 0
        xor rcx, rcx                ; rcx = 0 (счётчик символов)
%%loop:
        cmp byte [rdi], 0           ; Проверяем символ на '\0'
        je %%done                    ; Если нулевой терминатор, выходим
        inc rdi                     ; Сдвигаем указатель на следующий символ
        inc rcx                     ; Увеличиваем счётчик
        jmp %%loop                  ; Повторяем цикл
        %%done
%endmacro
;-------------------------------------------

; TODO:
; + make return value
; +Inverse dec digits
; Make sign for dec
; Reduce zeros amount
; + Make serial bufferisation
; Make atexit

global _start                  ; predefined entry point name for ld
; global _Z9my_printfPKcz
global my_printf
global my_flush

;-------------------------------------------
; Flushes buffer
;
; Destr: nothing
;-------------------------------------------
my_flush:
	cmp qword [SAVED_BUF_POS], 0
	je .no_need_flush
	push rax
	push rdi
	push rsi
	FLUSH_BUF Buffer, [SAVED_BUF_POS]
	mov qword [SAVED_BUF_POS], 0
	; mov rax, 0x3C      ; exit64 (rdi)
	; xor rdi, rdi
	; syscall
	pop rsi
	pop rdi
	pop rax
	.no_need_flush
	ret
;-------------------------------------------

;-------------------------------------------
; My printf. Arguments by fastcall, fmt in rdi (first)
;
; Destr: many things...
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

        xor RET_REG, RET_REG
        xor FMT_ADR, FMT_ADR
        mov FMT_ADR, [rbp + 16]         ; fmt string
        ; xor BUF_POS, BUF_POS            ; r15 - counter of buffer
        mov BUF_POS, [SAVED_BUF_POS]
        mov CUR_ARG, 3

.parse_char:
        xor r14, r14
        mov SYMBOL, [FMT_ADR]
        cmp SYMBOL, '%'
        je .is_percent
        cmp SYMBOL, 0
        je .end_of_parse

        WRITE_TO_BUFFER 1                ; common char

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
        						dq .dec_parse      ; d - dec
        times ('o' - 'd' - 1) 	dq .wrong_symbol   ; not anyone
        						dq .oct_parse      ; o - oct
        times ('s' - 'o' - 1) 	dq .wrong_symbol   ; not anyone
        						dq .str_parse      ; s - str
        times ('x' - 's' - 1)	dq .wrong_symbol   ; not anyone
        						dq .hex_parse      ; x - hex

.bin_parse:
		WRITE_CHAR_TO_BUFFER '0'
		WRITE_CHAR_TO_BUFFER 'b'
        WRITE_NUM_TO_BUF 2, 0x80000000, 1, 64
        jmp .switch_end

.hex_parse:
		WRITE_CHAR_TO_BUFFER '0'
		WRITE_CHAR_TO_BUFFER 'x'
        WRITE_NUM_TO_BUF 16, 0xF0000000, 4, 16
        jmp .switch_end

.oct_parse:
		WRITE_CHAR_TO_BUFFER '0'
        WRITE_NUM_TO_BUF 8, 0xE0000000, 3, 22
        jmp .switch_end

.str_parse:
        call parse_string
        jmp .switch_end

.dec_parse:
        call parse_dec
        jmp .switch_end

.chr_parse:
        call parse_char
        jmp .switch_end

.perc_parse:
        WRITE_TO_BUFFER 1
        jmp .parse_char

.wrong_symbol:
        mov RET_REG, -1
        jmp .end_of_parse

.switch_end:
        inc CUR_ARG
        inc FMT_ADR
        jmp .parse_char

.end_of_parse

        mov rsp, rbp
        pop rbp
        mov rbx, [rsp]
		mov [SAVED_BUF_POS], BUF_POS
        add rsp, 8 * 7         ; restore stack
        mov rax, RET_REG        ; return value
	jmp rbx                 ; return
;-------------------------------------------

;-------------------------------------------
; Put char in
;
; Destr: FMT_ADR, BUF_POS
;-------------------------------------------
parse_char:
        mov SYMBOL, [rbp + CUR_ARG * 8]
        WRITE_TO_BUFFER 1
        ret


parse_dec:
	mov r11, [rbp + CUR_ARG * 8]
    push rax
    push rdx
    push rcx

    mov rcx, 10             ; Максимальное количество цифр (32-битное число)
    add BUF_POS, 10        ; Смещаемся для инвертированного порядка

    .GET_DIGIT:
    	xor rdx, rdx            ; Очистка старшей части для 64-битного деления
		mov rdi, 10
        mov rax, r11        ; Загружаем число в RAX
        div rdi             ; RAX / 10 -> Частное в RAX, Остаток (mod 10) в RDX

        ; Преобразуем остаток (младшую цифру) в ASCII
        mov r14b, [HEX_TO_ASCCI_ARR + rdx]
        WRITE_TO_BUFFER_DIR 1, 0      ; Отправляем символ в буфер

        mov r11, rax        ; Обновляем r11 (частное)
        test rax, rax       ; Если частное стало 0 — значит, все цифры напечатаны
    loop .GET_DIGIT

    add BUF_POS, 11        ; Смещаемся в конец числа + 1 - для следующего символа

    pop rcx
    pop rdx
    pop rax
    ret

parse_string:
        mov r14, [rbp + CUR_ARG * 8]    ; save in r14 addr of string
        mov rdi, r14
        my_strlen
        cmp rcx, BUF_SIZE * 2
        jb .copy_to_buf
        FLUSH_BUF_COM               ; flush buf
        FLUSH_BUF r14, rcx
        jmp .end
        .copy_to_buf
        mov rdi, BUF_POS
        mov rsi, r14
        add rdi, Buffer
        add BUF_POS, rcx
        rep movsb
        .end
        ret

section     .bss

Buffer:     resb BUF_SIZE

section     .data

SAVED_BUF_POS dq 0
HEX_TO_ASCCI_ARR:
    db '0123456789ABCDEF'
