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

return:
	mov pc, qword[rtop]
	add rtop, word_size
	jmp pc

docol:
	sub rtop, word_size
	mov [rtop], w
	mov w, pc
.loop:
	add w, word_size
	mov pc, [w]
	sub rtop, word_size
	mov qword[rtop], .loop
	xor rdi, rdi
	mov dil, byte[pc - 1]
	call underflow_check
	jmp [pc]


end_word:
	add rtop, word_size
	mov w, [rtop]
	add rtop, word_size
	jmp return

next:
	mov w, pc
	add pc, 8
	mov w, [w]
	jmp [w]
	

underflow_check:
	imul rdi, 8
	add rdi, rsp
	cmp rdi, [data_top]
	jae .err
	ret
.err:
	mov rdi, err2
	pop rax
	jmp error
	

input:
	call read_word
	mov rdi, word_buffer
	call lower_case
	mov rdi, word_buffer
	jmp find_word


error:
	call print_string
	mov r15b, byte[state]
	test r15b, r15b
	jnz .ret
	mov rtop, rstack - word_size
.ret:
	jmp return 

push_num:
	push rdi
	jmp return 


