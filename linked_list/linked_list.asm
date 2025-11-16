default rel

get_new_addr:
	; args: r15 -> pointer to list info
	; returns: rax -> new addr
	mov rax, 9
	xor rdi, rdi
	mov rsi, [list_info+16]
	mov rdx, 3
	mov r8, -1
	xor r9, r9
	mov r10, 0x22
	syscall

	ret

init_list:
	; args: r14 -> element size
	;				r15 -> pointer to list_info
	; returns: list_info -> head, tail, element size, size
	mov [r15+16], r14
	call get_new_addr
	mov [r15], rax
	mov [r15+24], 1
	ret

delete_node:
	; args: dl -> index
	;				r15 -> pointer to list_info
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
	mov [r15+8], rcx

	not_last_node:

	; free address of deleted node
	mov rax, 11
	mov rdi, r15
	mov rsi, 16
	syscall
	
	end:
		ret

iterate_list:
	; args: r15 -> list_info
	; 			r12 -> function to execute
	;	for each iteration, returns:
	;				rax -> value
	;				rbx -> pointer to value
	;				rcx -> pointer to next value
	mov r13, [r15+24]
	mov rcx, [r15]			; load address of head
	mov rax, [rcx]			; load value of head
	mov rbx, [rcx+r13]	;	load pointer of head
	check:
		push rax
		push rbx
		push rcx
		call r12
		pop rcx
		pop rbx
		pop rax
		cmp rbx, 0					; check if pointer is 0
		je end_of_list			; if it is, finish loop
		mov rcx, rbx				; move onto new node from pointer
		mov rax, [rcx]			; load value into rax
		mov rbx, [rcx+r13]	; load new pointer
		jmp check						; continue recursing 

	end_of_list:
		ret

get_node_data:
	; args: dl -> index
	;				r15 -> pointer to list_info
	; returns:  rax -> value
	;						rbx -> pointer
	;						rcx -> address
	xor dh, dh							; clear counter
	mov rcx, [r15]					; load head address into rcx
	mov rax, qword [rcx]		; load head value into rax
	mov rbx, qword [rcx+8]	; load head pointer into rbx
	search:
		cmp dh, dl						; end loop if node is reached
		je found_node
		mov rcx, rbx					; move onto next node
		mov rax, [rcx]				; load value of node into rax
		mov rbx, [rcx+8]			; load pointer of next node into rbx
		inc dh
		jmp search
	found_node:
		ret
	
change_node_val:
	; args: r15 -> pointer to list_info
	;				r12 -> pointer to value
	;				dl -> index (byte)
	call get_node_data
	mov rsi, r12
	mov rdi, rcx
	mov rcx, [r15+16]
	cld
	rep movsb
	ret

insert_after:
	; args: r15 -> pointer to list_info
	;				r12 -> data
	;				dl -> index (byte)
	push rdx
	call get_new_addr
	xor rdx, rdx
	pop rdx
	mov r14, rax						; save address of new node
	call get_node_data
	mov r13, [rcx+8]				; load dl node pointer 
	mov [r14+8], r13				; set new node pointer to dl pointer
	mov [r14], r12					; set new node value
	mov [rcx+8], r14				; set dl node pointer to new address
	ret

append_node:
	; args: r12 -> value
	;				r15 -> pointer to list_info
	call get_new_addr 		 	; mmap 16 bytes for new node
	mov r13, qword [r15+8]	; move new address into tail pointer
  mov [r13+8], rax		  	;	
	mov [rax], r15					; move new value into new address
	mov qword [rax+8], 0		; set tail pointer to 0
	mov [list_info+8], rax 	; update pointer
	ret
