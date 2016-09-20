section .text

;in - rdi.
find_word:
	xor rax, rax
	mov rsi, [last_word] 
.loop:
	mov rdi, word_buffer
	push rsi
	add rsi, 8
	call string_equals
	test rax, rax
	jnz .return
	pop rsi
	mov rsi, [rsi]
	test rsi, rsi
	jnz .loop
	xor rax, rax
	ret
	.return:
	mov rax, rsi
	pop rsi
	ret
	

native '+', plus
	sub data_top, data_size
	mov r8, [data_top]
	add [data_top - data_size], r8
	ret		

native '-', minus
	sub data_top, data_size
	mov r8, [data_top]
	sub [data_top - data_size], r8
	ret


native '.s', print
	mov r12, data_top
	sub r12, data_size
.loop:
	cmp r12, stack_data
	jb .return
	xor rdi, rdi
	mov rdi, [r12]
	call print_int
	sub r12, data_size
	jmp .loop
.return:
	ret

native '*', mul
	sub data_top, data_size
	mov rax, [data_top - data_size]
	imul qword[data_top]
	mov [data_top - data_size], rax
	ret

native '/', div
	sub data_top, data_size
	mov rax, [data_top - data_size]
	idiv qword[data_top]
	mov [data_top - data_size], rax
	ret

native '<', less
	sub data_top, 2 * data_size
	mov rax, [data_top]
	mov qword[data_top], 0
	add data_top, data_size
	cmp rax, [data_top]
	jz .return
	inc qword[data_top - data_size]
	.return: ret


native '=', equal
	sub data_top, 2 * data_size
	mov rax, [data_top]
	mov qword[data_top], 0
	add data_top, data_size
	cmp rax, [data_top]
	jne .ret
	inc qword[data_top - data_size]
	.ret: ret

native 'dup', dup
	mov rax, [data_top - data_size]
	mov [data_top], rax
	add data_top, data_size
	ret

native '.', pop
	sub data_top, data_size
	mov rdi, [data_top]
	jmp print_int

native 'rot', rotate
	sub data_top, 3 * data_size
	mov rax, [data_top]
	add data_top, data_size
	mov rdx, [data_top]
	mov [data_top - data_size], rdx
	add data_top, data_size
	mov rdx, [data_top]
	mov [data_top - data_size], rdx
	mov [data_top], rax
	add data_top, data_size
	ret

native 'swap', swap
	mov rax, [data_top - data_size]
	mov rdx, [data_top - 2 * data_size]
	mov [data_top - 2* data_size], rax
	mov [data_top - data_size], rdx
	ret

native 'drop', drop
	sub data_top, data_size
	ret


native 'and', and
	sub data_top, data_size
	mov rax, [data_top]
	and [data_top - data_size],rax 
	ret


native 'not', not
	mov rax, [data_top - data_size]
	test rax, rax
	jz .zero
	xor rax, rax
	jmp .ret
	.zero:
	mov rax, 1
	.ret:
	mov [data_top - data_size], rax
	ret

native 'key', key
	call read_char
	mov [data_top], rax
	add data_top, data_size
	ret

native 'emit', keyout
	sub data_top, data_size
	mov rdi, [data_top]
	jmp print_char


native 'exit', exit
	mov rax, 60
	xor rdi, rdi
	syscall	


section .data
last_word: dq link	
