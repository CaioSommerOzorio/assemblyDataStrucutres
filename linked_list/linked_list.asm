default rel
%include "../print_num.asm"

section .data
	head: dq 0,0
	tail: dq head
	size: db 0
	debug_msg: db "debug",0x0a

section .bss
	buff: resb 12
  tempvar: resb 8

section .text
	global _start

_start:
	mov r14, 7
	mov dl, 0
	call change_node_val
	mov r14, 9
	call append_node
	mov r14, 13
	call append_node
	call print_list
	mov rax, 60
	xor rdi,rdi
	syscall

get_new_addr:
	; mmap 16 bytes for new addr into rax
	mov rax, 9
	xor rdi, rdi
	mov rsi, 16
	mov rdx, 3
	mov r8, -1
	xor r9, r9
	mov r10, 0x22
	syscall

	ret

delete_node:
	; args: dl -> index
	cmp dl, 0
	je end 							; cannot delete head node
	call get_node_data
	mov r12, rcx				; save address of del node
	dec dl							; node before del node
	call get_node_data
	mov r13, [r12+8]	
	mov [rcx+8], r13		; load del node ptr into prev ptr
	cmp [rcx+8], 0
	jne not_last_node
	mov [tail], rcx

	not_last_node:

	; free address of deleted node
	mov rax, 11
	mov rdi, r12
	mov rsi, 16
	syscall
	
	end:
		ret

print_list:
	xor dh, dh
	mov rax, [head]
	mov rbx, [head+8]
	mov rcx, head
	;call debug
	check:
		mov rdi, rcx
		mov rsi, buff
		call print_num
		cmp rbx, 0
		je end_of_list
		mov rcx, rbx
		mov rax, [rcx]
		mov rbx, [rcx+8]
		inc dh
		jmp check 

	end_of_list:
		ret

get_node_data:
	; args: dl -> index
	; returns:  rax -> value
	;						rbx -> pointer
	;						rcx -> address
	
	xor dh, dh					; clear counter
	mov rax, [head]			; load head value into rax
	mov rbx, [head+8]		; load head pointer into rbx
	mov rcx, head				; load head address into rcx
	search:
		cmp dh, dl				; end loop if node is reached
		je found_node
		mov rcx, rbx			; move onto next node
		mov rax, [rcx]		; load value of node into rax
		mov rbx, [rcx+8]	; load pointer of next node into rbx
		inc dh
		jmp search
	found_node:
		ret
	
change_node_val:
	; args: r14 -> value
	;				dl -> index (byte)
	call get_node_data
	mov [rcx], r14
	ret

insert_after:
	; args: r14 -> value
	;				dl -> index (byte)
	call get_new_addr
	mov rax, r12						; save address of new node
	call get_node_data
	mov r13, [rcx+8]
	mov [r12+8], r13				; set new node pointer to dl pointer
	mov [r12], r14					; set new node value
	mov [rcx+8], r12				; set dl node pointer to new address
	ret

append_node:
	; args: r14 -> value
	
	call get_new_addr 		; mmap 16 bytes for new node
	; rax has new address
	mov r13, [tail]       ; move new address into tail pointer
  mov [r13+8], rax		  ;	
	mov [rax], r14				; move new value into new address
	mov qword [rax+8], 0	; set tail pointer to 0
	mov [tail], rax 			; update pointer

  ret

debug:
	push rax
	push rdi
	push rsi
	push rdx
	mov rax, 1
	mov rdi, 1
	lea rsi, [debug_msg]
	mov rdx, 6
	syscall
	pop rdx
	pop rsi
	pop rdi
	pop rax
	ret

