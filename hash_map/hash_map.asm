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
  mov r15, dict_info
  mov eax, 8      ; number of buckets
  mov edx, 8      ; element size (bytes)
  mov [r15], edx
  mov [r15+4], eax
  call init_map

  mov rsi, key
  mov r15, dict_info
  mov rcx, 6
  mov r13, value
  call store_value

  mov rsi, key
  call hash_func

  mov rdi, r12
  call print_string
  call print_newline

  mov rax, 60
  xor rdi, rdi
  syscall

store_value:
  ; args: r15 -> pointer to dict_info
  ;       rcx -> length of value
  ;       rsi -> pointer to key
  ;       r13 -> pointer to value
  call hash_func  ; returns bucket address in r12
  mov rdi, r12    ; dest (bucket)
  mov rsi, r13
  cld
  rep movsb
  ret

hash_func:
  ; args -> r15 -> pointer to dict_info
  ;         rsi -> pointer to key
  ; returns: r12 -> address of key
  mov rax, 5381
  .hash_loop:
    movzx rbx, byte [rsi]   ; load zero-extended next char
    test bl, bl
    jz .hash_done
    mov rdx, rax
    shl rax, 5
    add rax, rdx
    add rax, rbx
    inc rsi
    jmp .hash_loop

.hash_done:
  xor rdx, rdx
  movzx rbx, dword [r15+4]
  div rbx       ; rax = quotient, rdx = remainder
  mov rax, rdx  ; index = remainder
  movzx rbx, dword [r15]  ; element size
  imul rax, rbx ; rax = index * element_size
  mov r12, [r15+8]
  add r12, rax  ; r13 = base + offset
  ret

init_map:
  ; args: r15 -> pointer to dict_info
  ; returns: dict_info -> address
  
  movzx rdx, dword [r15]
  movzx rax, dword [r15+4]
  
  mul rdx
  mov rsi, rax

  mov rax, 9
  xor rdi, rdi 
  mov rdx, 3
  mov r8, -1
  xor r9, r9
  mov r10, 0x22
  syscall

  mov [r15+8], rax   ; base address
  ret

