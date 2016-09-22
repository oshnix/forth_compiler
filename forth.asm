%define data_size 8
%define here r13
%define w r14
%define pc rbx
%define rtop rbp


section .data
state: db 0
rstack_end:
	times 65536 dq 0
rstack: dq 0
data_top: dq 0
dictionary: times 65536 db 0
userdata: times 65536 dq 0
err1: db 'wrong input!', 10, 0
err2: db 'not enough opperands', 10, 0

section .text

%include 'lib.inc'
%include 'macro.asm'
%include 'dictionary.asm'
%include 'functions.asm'
global _start
_start:
	mov [data_top], rsp
	mov here, dictionary
	mov rtop, rstack
	jmp interpreter_loop

interpreter_loop:
	mov al, byte[state]
	test al, al
	jnz compiler_loop
	call input
	sub rtop, word_size
	mov qword[rtop], interpreter_loop
	test rax, rax
	jz .num
	xor rdi, rdi
	mov dil, byte[rax]
	mov w, rax
	cmp dil, 'I'
	jz .imm
	cmp dil, 'N'
	jz .err
	call underflow_check
.imm:
	inc w
	mov pc, w
	jmp [w]

.num:
	mov rdi, word_buffer
	call parse_int
	mov rdi, err1
	test rdx, rdx
	jz error
	mov rdi, rax
	jmp push_num
.err:
	mov rdi, err1
	jmp error

compiler_loop:
	mov al, byte[state]
	test al, al
	jz interpreter_loop

	call input
	sub rtop, word_size
	mov qword[rtop], compiler_loop
	test rax, rax
	jz .num
	mov dil, byte[rax]
	inc rax
	cmp dil, 'I'
	jz .imm
	mov qword[here], rax
	add here, word_size
	jmp compiler_loop

.num:
	call parse_int
	mov rdi, err1
	test rdx, rdx
	jz error
	mov rdi, [here - word_size]
	cmp rdi, xt_branch
	jz .add
	cmp rdi, xt_ifbranch
	jz .add
	add rtop, word_size
	mov qword[here], xt_lit
	add here, word_size
	mov qword[here], rax	
	add here, word_size
	jmp compiler_loop
.add:
	mov qword[here], rax
	add here, word_size
	jmp compiler_loop
	
.imm:
	jmp [rax]
	
	
