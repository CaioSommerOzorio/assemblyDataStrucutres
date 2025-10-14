section .data
	head: dq 0,0
	tail: dq head
	size: db 0

section .text
	global _start

_start:
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
	mov [rcx+8], r13; load del node ptr into prev ptr

	; free address of deleted node
	mov rax, 11
	mov rdi, r12
	mov rsi, 16
	syscall
	
	end:
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
		mov rax, [rbx]		; load value of node into rax
		mov rbx, [rax+8]	; load pointer of next node into rbx
		inc dh
		jmp search
	found_node:
		ret
	
insert_after:
	; args: r11 -> value
	;				dl -> index (byte)
	call get_new_addr
	mov rax, r12						; save address of new node
	call get_node_data
	mov r13, [rcx+8]
	mov [r12+8], r13	; set new node pointer to dl pointer
	mov [r12], r11					; set new node value
	mov [rcx+8], r12				; set dl node pointer to new address	
	ret

append_node:
	; args: r11 -> value
	
	call get_new_addr ; mmap 16 bytes for new node

	; rax has new address
	mov rbx, [tail+8]			; load address of tail pointer
	mov [rbx], rax				; move new address into tail pointer
	mov [rax], r11				; move new value into new address
	mov qword [rax+8], 0	; set tail pointer to 0
	mov [tail], rax 			; update pointer
	
	ret
