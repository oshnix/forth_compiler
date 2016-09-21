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

cfa:
	xor rax, rax
	add rdi, word_size
.loop:
	mov al, [rdi]
	inc rdi
	test al, al
	jz .ret
	jmp .loop
.ret:
	inc rdi
	mov rax, rdi
	ret


docol:
	add w, word_size
	mov rax, [w]
	call [rax]
	jmp docol

put:
	add w, word_size
	mov rax, [w]
	jmp push_num


native '+', plus
	mov rdi, 2 * data_size
	call underflow_check
	sub data_top, data_size
	mov r8, [data_top]
	add [data_top - data_size], r8
	ret		

native '-', minus
	mov rdi, 2 * data_size
	call underflow_check
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
	mov rdi, 2 * data_size
	call underflow_check
	sub data_top, data_size
	mov rax, [data_top - data_size]
	imul qword[data_top]
	mov [data_top - data_size], rax
	ret

native '/', div
	mov rdi, 2 * data_size
	call underflow_check
	sub data_top, data_size
	mov rax, [data_top - data_size]
	idiv qword[data_top]
	mov [data_top - data_size], rax
	ret

native '<', less
	mov rdi, 2 * data_size
	call underflow_check
	sub data_top, 2 * data_size
	mov rax, [data_top]
	mov qword[data_top], 0
	add data_top, data_size
	cmp rax, [data_top]
	jae .return
	inc qword[data_top - data_size]
	.return: ret

native ':', begin,'I'
	mov byte[state], 1
	mov rdi, [last_word]
	mov [here], rdi
	mov qword[last_word], here
	add here, word_size
	call read_word
	mov rdi, rax
	mov rsi, here
	call string_copy
	mov here, rsi
	inc here
	mov qword[here], docol
	add here, word_size
	jmp compilator



native ';', end,'I'
	mov byte[state], 0
	mov qword[here], xt_end_word
	add here, word_size
	jmp compilator



end_word:
	pop rax
	ret



native 'mem', mem
	mov qword[data_top], userdata
	add data_top, data_size
	ret

native '=', equal
	mov rdi, 2 * data_size
	call underflow_check
	sub data_top, 2 * data_size
	mov rax, [data_top]
	mov qword[data_top], 0
	add data_top, data_size
	cmp rax, [data_top]
	jne .ret
	inc qword[data_top - data_size]
	.ret: ret

native 'dup', dup
	mov rdi, data_size
	call underflow_check
	mov rax, [data_top - data_size]
	mov [data_top], rax
	add data_top, data_size
	ret

native '.', pop
	mov rdi, data_size
	call underflow_check
	sub data_top, data_size
	mov rdi, [data_top]
	jmp print_int

native 'rot', rotate
	mov rdi, 3 * data_size
	call underflow_check
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
	mov rdi, 2 * data_size
	call underflow_check
	mov rax, [data_top - data_size]
	mov rdx, [data_top - 2 * data_size]
	mov [data_top - 2* data_size], rax
	mov [data_top - data_size], rdx
	ret

native 'drop', drop
	mov rdi, data_size
	call underflow_check
	sub data_top, data_size
	ret


native 'and', and
	mov rdi, 2 * data_size
	call underflow_check
	sub data_top, data_size
	mov rax, [data_top]
	and [data_top - data_size],rax 
	ret


native 'not', not
	mov rdi, data_size
	call underflow_check
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
	mov rdi, data_size
	call underflow_check
	sub data_top, data_size
	mov rdi, [data_top]
	jmp print_char

input:
	call read_word
	mov rdi, word_buffer
	call parse_int
	ret	

native 'number', number
	call input
	test rdx, rdx
	jnz .finish
	jmp error
.finish:
	mov rdi, rax
push_num:
	mov [data_top], rax
	add data_top, data_size
	ret

native 'exit', exit
	mov rax, 60
	xor rdi, rdi
	syscall	

colon '>', greater
	dq xt_swap
	dq xt_less
	dq xt_end_word


underflow_check:
	mov rax, data_top
	sub rax, stack_data
	sub rax, rdi
	jns .ret
	pop rax
	mov rdi, err2
	jmp print_string
	.ret: ret

section .data
last_word: dq link
xt_end_word: dq end_word	
