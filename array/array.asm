%include "../algorithms.asm"

section .text
	global _start

_start:
	mov rax, 60
	xor rdi, rdi
	syscall

create_array:
	; args: r14 -> size
	;				r15 > element size
	; returns: r13 -> address
	mov rax, r15
	mul r14
	
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

expand_array:
	; args: r14 -> array size
	;				r15 -> address of array
	;	returns: r13 -> address of new array
	mov rax, 2
	mul r14
	mov rsi, rax
	mov rax, 9
	mov rdx, 3
	xor rdi, rdi
	mov r8, -1
	xor r9, r9
	mov r10, 0x22
	syscall
	
	mov r13, rax
	xor rdx, rdx
	move_array:
		mov [rax], [r15+rdx]
		cmp r14, rdx
		je finish_moving
		inc rdx
		jmp move_array

	finish_moving:
	mov rax, 11
	mov rdi, r15
	mov rsi, r14
	syscall
	ret
