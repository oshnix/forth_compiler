%define data_top rbx
%define data_size 8

section .data
stack_data:
	times 65535 db 0
data: db 0
stack_return:
	times 65535 db 0
return db 0
err_mes: db 'NO_COMMAND!', 0
userdata: db 0
section .text

%include 'lib.inc'
%include 'macro.asm'
%include 'dictionary.asm'


global _start
_start:
	mov data_top, stack_data
.loop:
	call read_word
	mov rdi, rax
	call parse_int
	test rdx, rdx
	jz .word
	mov [data_top], rax
	add data_top, data_size
	jmp .loop
.word:
	mov rdi, word_buffer 
	call lower_case
	mov rdi, word_buffer
	call find_word
	test rax, rax
	jz .error
	inc rax
	call [rax]
	jmp .loop
.error:
	mov rdi, err_mes
	call print_string
	jmp .loop	
	

