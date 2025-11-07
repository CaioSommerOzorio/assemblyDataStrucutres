%include "../algorithms.asm"

section .data
  key:   db "key", 0
  value: db "value", 0

section .bss
  ; First 8 bytes: element size and number of elements
  ; Second 8 bytes: Address of dictionary
  dict_info: resq 2
  buff: resb 12

section .text
  global _start

_start:
  mov eax, 8      ; number of buckets
  mov edx, 8      ; element size (bytes)
  mov [dict_info], edx
  mov [dict_info+4], rdx
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

store_value:
  ; args: dict_info
  ;       r14 -> pointer to key
  ;       r15 -> pointer to value
  call hash_func  ; returns bucket address in r13
  mov rdi, r15
  mov rsi, r15            ; source
  call string_length 
  mov rcx, r15            ; length
  mov rdi, [dict_info+8]  ; dest (bucket)
  cld
  rep movsb
  ret

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
  ; args -> dict_info
  ;         r14 -> pointer to key
  ; returns: r12 -> address of key
  mov rax, 5381
  .hash_loop:
    movzx rbx, byte [r14]   ; load zero-extended next char
    test bl, bl
    jz .hash_done
    mov rdx, rax
    shl rax, 5
    add rax, rdx
    add rax, rbx
    inc r14
    jmp .hash_loop

.hash_done:
  xor rdx, rdx
  movzx rbx, dword [dict_info+4]
  div rbx       ; rax = quotient, rdx = remainder
  mov rax, rdx  ; index = remainder
  movzx rbx, dword [dict_info]  ; element size
  imul rax, rbx ; rax = index * element_size
  mov r12, [dict_info+8]
  add r12, rax  ; r13 = base + offset
  ret

init_map:
  ; args: dict_info -> element size and dict size
  ; returns: dict_info -> address

  mov r15, [dict_info]
  mov rax, [dict_info+4]
  
  mul r15
  mov rsi, rax         

  mov rax, 9           
  xor rdi, rdi         
  mov rdx, 3           
  mov r8, -1
  xor r9, r9
  mov r10, 0x22        
  syscall

  mov rbx, rax

  mov [dict_info+8], rax   ; base address
  ret

