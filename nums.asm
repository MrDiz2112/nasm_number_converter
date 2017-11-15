%include "stud_io.inc"
global _start

section .data
length		db 0
length_new 	db 0
base		dw 10
result		dd 0

section .bss
array	resb 5
str_arr resb 50

section .text
_start:		mov edi, array 		; Загрузить адрес массива
			PRINT "Enter decimal value: "
			
again:		GETCHAR 			
			cmp eax, 10 ; равен ли символ '\n'
			je in_out 			
			
			cmp eax, 48	; меньше ли '0'		
			jb input_err		
			cmp eax, 57			
			ja input_err ; больше ли '9'
			
			mov [edi], al 	; записать элемент в массив
			inc edi			; переход к след. элементу
			inc byte [length]	; увеличить длину
			jmp again 			
			

			
in_out:		cmp byte [length], 5 ; если длиннее 5 символов
			ja long_var
			
	
; ========== Конвертация числа ==========

			mov cl, [length]
			mov edi, array
			
con_arr:	sub byte [edi], 48 ; вычесть код '0' из элементов
			inc edi
			loop con_arr
	
; ========== Перевод массива символов в число ===========
			
			xor ecx, ecx
			mov edi, array
			
			mov eax, [result]
			mov cl, [length] 
			

loop_int:	mul word [base] ; умножить результат на 10
			push eax		; сохранить в стек
			xor eax, eax	; очистить eax
			mov al, [edi]	; встаить в al элемент массива
			
			pop ebx			; достать из стека в ebx
			add eax, ebx	; сложить
			inc edi

			loop loop_int
			
			mov dword [result], eax ; сохранить резуьтат
			
; ========= Ввод символа СС ==========

			PUTCHAR 10
			PRINT "Choose notation (b, o, h): "
			
read_not:	GETCHAR
			mov ebx, eax
			GETCHAR
			
			mov eax, ebx
			
			cmp eax, 98 ; 'b' перевести в двоичную
			je int_to_byte_str
			
			cmp eax, 104 ; 'h' перевести в шестнадцатиручную
			je int_to_hex_str
			
			cmp eax, 111 ; 'o' перевести в восьмеричную
			je int_to_oct_str
			
; =B=B=B=B=B= Перевод в двоичную СС =B=B=B=B=B=

int_to_byte_str:
			PUTCHAR 10
			PRINT "Transfer to BIN!"
			
			mov eax, dword [result]
			mov edi, str_arr
			mov cl, 32
			
itbs_lp:	rol eax, 1 ; сдвиг влево на 1 бит
			jc itbs_1 ; если флаг CF = 1
			mov byte [edi], 48 ; '0'
			jmp itbs_end

itbs_1:		mov byte [edi], 49 ; '1'

itbs_end:	inc edi
			inc byte [length_new]
			loop itbs_lp
			
			jmp bin_out
			
			
; =O=O=O=O=O= Перевод в восьмиричную СС =O=O=O=O=O=

int_to_oct_str:
			PUTCHAR 10
			PRINT "Transfer to OCT!"
			
			mov eax, dword [result]
			mov edi, str_arr
			mov cl, 11
			
itos_lp:	push eax

			and al, 07h ; оставить в байте 3 младших бита
			call to_oct_digit ; перевеод в числа в OCT
			
			mov [edi], al ; записать в массив
			inc edi
			inc byte [length_new]
			
			pop eax
			shr eax, 3 ; сдвиг на 3 бита
			
			loop itos_lp
			
			jmp oct_hex_out
			
to_oct_digit:
			add al, 48 	; прибавление символа '0'
			ret
			

; =H=H=H=H=H= Перевод в шестнадцатиричную =H=H=H=H=H=

int_to_hex_str:
			PUTCHAR 10
			PRINT "Transfer to HEX!"
			
			mov eax, dword [result]
			mov edi, str_arr
			mov cl, 8
			xor ebx, ebx
			
iths_lp:	push eax

			and al, 0Fh ; оставить младшую тетраду
			call to_hex_digit
			
			mov [edi], al
			inc edi
			inc byte [length_new]
			
			pop eax
			shr eax, 4
			
			loop iths_lp
			
			jmp oct_hex_out
			
			
to_hex_digit:
			add al, 48 	; прибавление символа '0'
			cmp al, 57 	; сравнение с '9'
			jle end_thd
			add al, 7 	; приведение к букве, если больше 

end_thd:	ret
			
			
			
; =B=B=B=B=B= Вывод двоичного числа =B=B=B=B=B=

bin_out:	PUTCHAR 10
			PRINT "Your new number is: "
			mov cl, [length_new]
			mov edi, str_arr
			
print_bin:	PUTCHAR [edi]
			inc edi
			loop print_bin			

			FINISH
			
; =H=H=H=H=H= Вывод OCT и HEX числа =H=H=H=H=H=
			
oct_hex_out:	
			PUTCHAR 10
			PRINT "Your new number is: "
			mov cl, [length_new]
			mov edi, str_arr
			
prep_to_print_hex:	
			inc edi		; переход к последнему значению
			loop prep_to_print_hex
			
			dec edi		; вернутся к последнему элементу
			mov cl, [length_new]
			
print_hex:	PUTCHAR [edi]
			dec edi
			loop print_hex

			FINISH

; Метки для ошибок

input_err:	GETCHAR
			cmp eax, 10
			jne input_err
			PUTCHAR 10
			PRINT "Input error! Break execution!"
			FINISH
			
long_var: 	PUTCHAR 10
			PRINT "Too long input! Break execution!"
			FINISH		
