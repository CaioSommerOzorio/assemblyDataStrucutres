%include "../algorithms.asm"

section .data

section .bss
	buff: resb 12

section .text
	global _start

_start:
	mov rax, 60
	xor rdi, rdi
	syscall

store_value:
	; args: r14 -> pointer to string
	;				r15 -> pointer to value
	call hash_func
	mov rbx, [r15]
	mov [rax], rbx	

	ret

get_value:
	; args: r14 -> pointer to string
	; returns: r12 -> pointer to value
	call hash_func
	mov r12, rax
	ret

hash_func:
	; args: r14 -> pointer to string
	; returns: rax -> address in the hash map
	mov rax, 5381
	begin_hash:
		mov bl, [r14]
		test bl, bl
		jz finished_hash
		imul rax, rax, 33
		add rax, rbx
		inc r14
		jmp begin_hash
	finished_hash:
	mov rcx, r14
	xor rdx, rdx
	div rcx
	add rax, r13
	ret

init_map:
	; args: r14 -> number of elements
	;				r15 -> element size
	; returns: r13 -> address of hash map

	mov rax, r14
	mul r15

	mov rsi, rax

	mov rax, 9
	xor rdi, rdi
	mov rdx, 3
	mov r8, -1
	xor r9, r9
	mov r10, 0x22
	syscall

	mov r13, rax

	ret
