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
	mov r15, 7
	mov dl, 0
	call change_node_val
	mov r15, 9
	call append_node
	mov r15, 13
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
	mov r15, rcx				; save address of del node
	dec dl							; node before del node
	call get_node_data
	mov r13, [r15+8]	
	mov [rcx+8], r13		; load del node ptr into prev ptr
	cmp [rcx+8], 0
	jne not_last_node
	mov [tail], rcx

	not_last_node:

	; free address of deleted node
	mov rax, 11
	mov rdi, r15
	mov rsi, 16
	syscall
	
	end:
		ret

print_list:
	mov rax, [head]			; load value of head
	mov rbx, [head+8]		;	load pointer of head
	mov rcx, head				; load address of head	
	check:
		mov rdi, rcx			; load pointer to value 
		mov rsi, buff			; load buffer for printing
		call print_num		; print the number
		cmp rbx, 0				; check if pointer is 0
		je end_of_list		; if it is, finish loop
		mov rcx, rbx			; move onto new node from pointer
		mov rax, [rcx]		; load value into rax
		mov rbx, [rcx+8]	; load new pointer
		jmp check					; continue recursing 

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
	; args: r15 -> value
	;				dl -> index (byte)
	call get_node_data
	mov [rcx], r15
	ret

insert_after:
	; args: r15 -> value
	;				dl -> index (byte)
	call get_new_addr
	mov rax, r15						; save address of new node
	call get_node_data
	mov r13, [rcx+8]
	mov [r15+8], r13				; set new node pointer to dl pointer
	mov [r15], r12					; set new node value
	mov [rcx+8], r15				; set dl node pointer to new address
	ret

append_node:
	; args: r15 -> value
	
	call get_new_addr 		; mmap 16 bytes for new node
	; rax has new address
	mov r13, [tail]       ; move new address into tail pointer
  mov [r13+8], rax		  ;	
	mov [rax], r15				; move new value into new address
	mov qword [rax+8], 0	; set tail pointer to 0
	mov [tail], rax 			; update pointer
	ret

debug:
	push rcx
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
	pop rcx
	ret

