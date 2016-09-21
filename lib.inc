section .data
temp: dq 0
char_diff: db 0x00
newline_char: db 0xA
word_buffer: times 256 db 0


section .text

;take rdi 
;give rax
string_length:
	mov rax, rdi
	dec rax
	.loop:	;идём по строке, пока не встретим 0х00
	inc rax
	cmp byte[rax], 0	;проверка символа
	jnz .loop
	sub rax, rdi		;символ конца строки не входит в длину строки
	ret

;take rdi
;change rsi, rdi
print_string:
	mov rsi, rdi
	call string_length
	mov rdx, rax	;выводим строку, зная, сколько байт она занимает
	mov rax, 1
	mov rdi, 1
	syscall
	ret

;take rdi
;change rsi
print_char:
	push rdi
   	mov rax, 1
	mov rsi, rsp 	;передаём ссылку на вершину стека в качестве символа ввода
	mov rdi, 1
	mov rdx,1
	syscall
	pop rdi
    	ret


;take rdi
;change r8, rdi
print_uint:
	mov rax, rdi
	mov qword[temp], rsp
	mov r8, 10
	dec rsp
	mov byte[rsp], 0
	dec rsp
	mov byte[rsp], ' '
	.loop:
	xor rdx, rdx			;в каждой итерации считаем число по модулю 10	
    	div r8
    	dec rsp
	add dl, '0'		;прибавляем к цифре код нуля, чтобы получить код самой цифры
    	mov [rsp], dl
    	test rax, rax
    	jnz .loop
	mov rdi, rsp
	call print_string	;после разложения, осталось только забрать из памяти строку
	mov rsp, qword[temp]
    	ret

;take rdi
;change rdi
print_int:
	test rdi, rdi	;проверяем число на отрицательность
	jns .loop
	neg rdi			;для удобства работы берём противоположное число
	push rdi
	mov rdi, '-'	;кладём знак в начало числа
	call print_char
	pop rdi
	.loop:
	jmp print_uint

;take rdi, rsi
;change rdi, rsi, r8
;get rax, rdi, rsi
string_equals:		
	xor rax, rax
	.loop:				;идём по строке, пока не встретим разные элементы, или символ конца строки
	mov r8b, byte[rdi]
	mov dl, byte[rsi]
	cmp r8b, dl
	jnz .result
	inc rdi
	inc rsi
	test r8b, r8b
	jnz .loop
	mov rax, 1			;если строки равной длины и все их элементы соответственно равны - строки равны
    .result:
    ret

;change rdi, rsi
;get rax
read_char:
	push 0
	mov rax, 0
	mov rdi, 0
	mov rsi, rsp		
	mov rdx, 1
	syscall
	pop rax
    	ret  


read_word:
	mov r8, word_buffer
	xor r9, r9
	.loop:
	call read_char
	cmp al, byte 0xA		;проверяем, что введённый символ - не пробел
	jz .null
	cmp al, byte 0x9
	jz .null
	cmp al, byte 0x20
	jz .null
	test al, al						;если встретили символ конца строки - идём в конец
	jz .return
	mov r9, 1
	mov byte[r8], al
	inc r8							
	jmp .loop
	.null:
	test r9b, r9b				;если уже встречали цифры, значит одно число мы считали
	jz .loop					;завершаем выполнение функции
	.return:
	mov byte[r8], 0x00
	mov rax, word_buffer
	mov rdx, r8
	sub rdx, word_buffer
   	 ret


; rdi points to a string
; returns rax: number, rdx : length
parse_uint:
	xor rdx, rdx
	xor rax, rax
	xor r8, r8
	.loop:
	mov r8b, byte[rdi]
	inc rdi
	test r8b, r8b 
	jz .return
	cmp r8b, '0'
	jb .continue 
	cmp r8b, '9'
	ja .continue
	inc rdx
	imul rax, 0xA
	sub r8b, '0'
	add rax, r8
	jmp .loop
	.continue:
	xor rax, rax
	xor rdx, rdx
	.return:
   	ret


parse_int:
	cmp byte[rdi], '-'
	jnz .loop
	inc rdi
	push .loop + 2
	.loop: jmp parse_uint
	test rdx, rdx
	jz .ret
	neg rax
	inc rdx
	.ret: ret

string_copy:
	.loop:		;посимвольно копируем строку, начиная с указанной ячейки памяти
	mov al, [rdi]
	mov [rsi], al
	inc rdi
	inc rsi
	test al, al	;Если встретили символ конца строки - завершаем работу
	jnz .loop
	ret

;in - rdi - string label
;out - nothing
;to do - if char is between 'A' and 'Z' - sub diff between 'A' and 'a' from it
;uses r8
lower_case:
	mov r8b, 'A'
	sub r8b, 'a'
	mov byte[char_diff], r8b
	.loop:
	mov r8b, byte[rdi]
	inc rdi
	test r8b, r8b
	jz .ret
	cmp r8b, 'A'
	jb .loop
	cmp r8b, 'Z'
	ja .loop
	sub r8b, byte[char_diff]
	mov byte[rdi - 1], r8b
	jmp .loop
	.ret:
	ret


