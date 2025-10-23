%include "../algorithms.asm"

section .data
    key:       db "key", 0
    value:     db "value", 0
    debug_msg: db "debug", 0x0a

section .bss
    buff: resb 12

section .text
    global _start

_start:
    mov r14, 8      ; number of buckets
    mov r15, 8      ; element size (bytes)
    call init_map

    mov r14, key
    mov r15, value
    call store_value

    mov r14, key
    call get_value

    mov rsi, r13
    call print_string
    call print_newline

    mov rax, 60
    xor rdi, rdi
    syscall

; ------------------------------------------------------------------
; store_value: copies r15 (value) into bucket computed by hash_func
;   args: r10 = element size (bytes)
;         r14 = pointer to key (string)
;         r15 = pointer to value (string)
; returns: nothing
store_value:
    call hash_func      ; returns bucket address in r13
    mov rcx, r10        ; byte count
    mov rsi, r15        ; source
    mov rdi, r13        ; dest (bucket)
    cld
    rep movsb
    ret

; ------------------------------------------------------------------
; get_value: compute bucket for r14 (key) and return pointer in r12
get_value:
    call hash_func
    ret

; ------------------------------------------------------------------
; hash_func:
;  r14 -> key pointer
;  r13 -> base map address (must be set by init_map)
;  r10 -> element size (bytes)
;  r11 -> number of buckets
; returns:
;  r12 -> address of chosen bucket (base + index*element_size)
hash_func:
    mov rax, 5381
.hash_loop:
    movzx rbx, byte [r14]   ; load zero-extended next char
    test bl, bl
    jz .hash_done
    ; multiply rax by 33: rax = rax*33  -> use shift+add to avoid problematic encodings
    mov rdx, rax
    shl rax, 5
    add rax, rdx
    add rax, rbx
    inc r14
    jmp .hash_loop

.hash_done:
    xor rdx, rdx
    mov rbx, r11            ; divisor (number of buckets)
    div rbx                 ; rax = quotient, rdx = remainder
    mov rax, rdx            ; index = remainder
    mov rbx, r10            ; element size
    imul rax, rbx           ; rax = index * element_size
    mov r12, r13
    add r12, rax            ; r13 = base + offset
    ret

; ------------------------------------------------------------------
; init_map:
;  r14 -> number of elements (buckets)
;  r15 -> element size (bytes)
; returns:
;  r13 -> base address (mmap return)
;  r10 -> element size
;  r11 -> number of elements
init_map:
    mov rax, r14
    mul r15              ; rdx:rax = rax * r15
    mov rsi, rax         ; length arg for mmap

    mov rax, 9           ; SYS_mmap
    xor rdi, rdi         ; addr = 0 (kernel choose)
    mov rdx, 3           ; PROT_READ | PROT_WRITE
    mov r8, -1
    xor r9, r9
    mov r10, 0x22        ; MAP_PRIVATE | MAP_ANONYMOUS
    syscall

    mov r13, rax         ; base address
    mov r10, r15         ; element size
    mov r11, r14         ; number of buckets
    ret

