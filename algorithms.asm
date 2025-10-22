default rel
; general purpose outputting and comming algorithms

%macro PUSH_REGS 0
  push rax
  push rbx
  push rcx
  push rdx
  push rsi
  push rdi
  push r11
%endmacro

%macro POP_REGS 0
  pop r11
  pop rdi
  pop rsi
  pop rdx
  pop rcx
  pop rbx
  pop rax
%endmacro

; string length: returns length of a string, string must have 0 at the end
; args: rdi -> pointer to string
; returns: r15 -> length of string
string_length:
  PUSH_REGS
  xor r15, r15
  mov rdx, 0
  check_0:
    mov rax, [rdi+rdx]
    cmp rax, 0
    je end_of_string
    inc dl
    jmp check_0
  end_of_string:
  POP_REGS
  mov r15, rdx
  ret

; print_string: prints a string
; args: rsi -> pointer to string
print_string:
  PUSH_REGS
  xor r15, r15
  call string_length
  mov rax, 1
  mov rdi, 1
  mov rdx, r15
  syscall
  POP_REGS
  ret

; print_num: prints a 32 bit number
; args: rdi -> pointer to string
;       rsi -> buffer of >= 12 bits
print_num:
  PUSH_REGS
  mov eax, [rdi]
  xor rcx, rcx
  mov rbx, 10

  cmp eax, 0
  jne .convert
  mov byte [rsi], '0'
  inc rcx
  jmp .done

.convert:
  xor rdx, rdx
.convert_loop:
  xor edx, edx
  div ebx
  add dl, '0'
  push rdx
  inc rcx
  cmp eax, 0
  jne .convert_loop

.done:
  mov rdi, rsi
.pop_loop:
  cmp rcx, 0
  je .newline
  pop rax
  mov [rdi], al
  inc rdi
  dec rcx
  jmp .pop_loop

.newline:
  mov byte [rdi], 0x0a
  inc rdi
  mov rdx, rdi
  sub rdx, rsi
  mov rax, 1
  mov rdi, 1
  lea rsi, [rsi]
  syscall
  POP_REGS
  ret

; args: rsi -> debug_msg
;debug:
;  PUSH_REGS
;  mov rax, 1
;  mov rdi, 1
;  mov [debug_msg+5], 0x0a
;  mov rsi, debug_msg
;  mov rdx, 6
;  syscall
;  POP_REGS
;
;  ret
