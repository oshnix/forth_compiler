%define data_top rbx
%define return_top rbp
%define here r13
%define w r14
%define data_size 8

section .data
state: db 0
stack_data:
	times 65535 db 0
data: db 0
stack_return:
	times 65535 db 0
return db 0
dictionary: times 65536 db 0
err1: db 'wrong input!', 0
err2: db 'Not enough opperands', 0
userdata: times 65536 db 0
section .text

%include 'lib.inc'
%include 'macro.asm'
%include 'dictionary.asm'


global _start
_start:
	mov data_top, stack_data
	mov here, dictionary
interpretator:
	call input
	test rdx, rdx
	jz .word
	call push_num
	jmp interpretator
.word:
	mov rdi, word_buffer 
	call lower_case
	mov rdi, word_buffer
	call find_word
	test rax, rax
	jz error
	inc rax
	mov w, rax
	call [w]
	jmp interpretator 

error:
	mov rdi, err1
	call print_string
	jmp interpretator	
	

compilator:
.loop:
	mov al, byte[state]
	test al, al
	jz interpretator
	call input
	test rdx, rdx
	jz .word
	mov qword[here], put
	add here, word_size
	mov qword[here], rax	
	add here, word_size
.word:	
	mov rdi, word_buffer
	call lower_case
	mov rdi, word_buffer
	call find_word
	test rax, rax
	jz error
	mov dil, byte[rax]
	inc rax
	test dil, dil
	jnz .int 
	mov qword[here], rax
	add here, word_size
	jmp .loop
.int:
	call [rax]
		
	
	
