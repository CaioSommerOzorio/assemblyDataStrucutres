;-----------------------------------------
; print_num.asm
; Reusable number-to-ASCII routine for NASM
; Designed to be included via `%include`
; rdi -> pointer to 32-bit number
; rsi -> pointer to buffer (at least 12 bytes)
;-----------------------------------------
default rel

; Make sure it doesn't export `_start` — this is just a function
; Usage: call print_num

print_num:
    mov eax, [rdi]        ; load number
    xor rcx, rcx           ; digit counter
    mov rbx, 10            ; divisor

    ; Special case: zero
    cmp eax, 0
    jne .convert
    mov byte [rsi], '0'
    inc rcx
    jmp .done

.convert:
    xor rdx, rdx           ; clear RDX for div
.convert_loop:
    xor edx, edx
    div ebx                ; divide eax by 10
    add dl, '0'            ; convert remainder to ASCII
    push rdx               ; save digit
    inc rcx
    cmp eax, 0
    jne .convert_loop

.done:
    mov rdi, rsi           ; buffer pointer
.pop_loop:
    cmp rcx, 0
    je .newline
    pop rax
    mov [rdi], al
    inc rdi
    dec rcx
    jmp .pop_loop

.newline:
    mov byte [rdi], 0x0a   ; newline
    inc rdi

    ; write string to stdout
    mov rdx, rdi
    sub rdx, rsi            ; length
    mov rax, 1              ; syscall write
    mov rdi, 1              ; stdout
    lea rsi, [rsi]          ; buffer pointer
    syscall
    ret

