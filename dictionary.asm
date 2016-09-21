section .text

;Some arifmetic words

native '+', plus, 2
	pop r8
	add [rsp], r8
	jmp return

native '-', minus, 2
	pop r8
	sub [rsp], r8
	jmp return

native '*', mul, 2
	pop rax
	imul qword[rsp]
	mov [rsp], rax
	jmp return

native '/', div, 2
	add rsp, data_size
	mov rax, [rsp]
	cqo
	idiv qword[rsp - data_size]
	mov [rsp], rax
	jmp return

native '<', less, 2
	add rsp, data_size
	mov rax, [rsp]
	mov qword[rsp], 0
	cmp rax, [rsp - data_size]
	jae return
	inc qword[rsp]
	jmp return

native '=', equal, 2
	add rsp, data_size
	mov rax, [rsp]
	mov qword[rsp], 0
	cmp rax, [rsp - data_size]
	jne return
	inc qword[rsp]
	jmp return

;logical words

native 'and', and, 2
	pop rax
	and [rsp], rax 
	jmp return

native '!', write, 2
	pop rax
	pop rdi
	mov qword[rax], rdi
	jmp return

native '@', read, 1
	pop rax
	mov rax, [rax]
	push rax
	jmp return

native 'not', neg, 1
	pop rax
	test rax, rax
	jz .zero
	push 0
	jmp .ret
	.zero:
	push 1
	.ret:
	jmp return

;Work with data stack

native '.s', print
	mov r9, rsp
.loop:
	cmp r9, [data_top]
	jae .return
	mov rdi, qword[r9]
	call print_int
	add r9, data_size
	jmp .loop
.return:
	jmp return

native 'dup', dup, 1
	mov rax, [rsp]
	push rax
	jmp return

native 'branch', branch, 'N'
	add w, word_size
	mov rax, [w]
	mov rdx, word_size
	imul rdx
	add w, rax
	jmp return

native '0branch', ifbranch, 'N'
	add w, word_size
	mov rax, qword[rsp]
	test rax, rax
	jnz .ret
	mov rax, [w]
	mov rdx, word_size
	imul rdx
	add w, rax
.ret: 
	jmp return


native '.', pop, 1
	mov rdi, [rsp]
	add rsp, data_size
	call print_int
	jmp return

native 'rot', rotate, 3
	add rsp, 2 * data_size
	mov rax, [rsp]
	sub rsp, data_size
	mov rdx, [rsp]
	mov [rsp + data_size], rdx
	sub rsp, data_size
	mov rdx, [rsp]
	mov [rsp + data_size], rdx
	mov [rsp], rax
	jmp return

native 'swap', swap, 2
	pop rax
	pop rdx
	push rax
	push rdx
	jmp return

native 'drop', drop, 1
	pop rax
	jmp return

native 'mem', mem
	push dictionary
	jmp return

native 'key', key
	call read_char
	push rax
	jmp return

native 'emit', keyout, 1
	pop rdi
	call print_char
	jmp return

native 'lit', lit
	add w, word_size
	mov rdi, [w]
	jmp push_num

native 'number', number
	call read_word
	mov rdi, rax
	call parse_int
	test rdx, rdx
	jnz .finish
	mov rdi, err1
	add rtop, word_size
	jmp error
.finish:
	mov rdi, rax
	jmp push_num


native ':', begin,'I'
	mov al, byte[state]
	mov rdi, err1
	test al, al	
	jnz error
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
	jmp return


native ';', end,'I'
	mov al, byte[state]
	mov rdi, err1
	test al, al	
	jz error
	mov byte[state], 0
	mov qword[here], xt_end_word
	add here, word_size
	jmp return

native 'exit', exit
	mov rax, 60
	xor rdi, rdi
	syscall	

colon '>', greater
	dq xt_swap
	dq xt_less
	dq xt_end_word



section .data
last_word: dq link
xt_end_word: dq end_word
