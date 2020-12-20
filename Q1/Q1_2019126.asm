; Vasudev Singhal
; 2019126


; Below command will tell nasm is 16 bit code
bits 16
; this will tell nasam to start outputting stuff at offset
org 0x7c00



boot16:
	mov ax, 0x2401
	int 0x15
	mov ax, 0x3
	int 0x10
	cli ; in order to prevent race conditions with interrupt hander cli diables all the interrupts
	lgdt [gdt_pointer] ; to load the GDT (Global Descriptor Table) table
	mov eax, cr0 ; move th2 cr0 register to eax
	or eax,0x1 ;  to set the protected mode bit on special CPU register cr0
	mov cr0, eax ; write the chnages of eax back to cr0
	jmp CODE_SEG:boot32 ; jump to the code segment of 32 bits


gdt_start:
	dq 0x0


gdt_code:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10011010b
	db 11001111b
	db 0x0


gdt_data:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0


gdt_end:


gdt_pointer:
	dw gdt_end - gdt_start
	dd gdt_start



CODE_SEG equ gdt_code - gdt_start


DATA_SEG equ gdt_data - gdt_start



; this command will tell nasm is 32 bit code
bits 32


boot32:
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov eax, 0x000000 
	mov esi,str1 ; point esi register to str1 label memoery i.e. "Hello"
	mov ebx,0xb8000 ; Setting the VGA Buffer


; this label will print hello
print1:
	lodsb
	or al,al
	jz set ; jump tp set label
	or eax,0x5f00 ; this decides the color and color of text
	mov word [ebx], ax ; this line will print on the console
	add ebx,2 ; add 2 to ebx
	jmp print1 ; jump to print1 back



;this will set new string to esi
set:
	mov esi,str2 ; point esi register to str2 label memoery i.e. "world!"
	jmp print2 ; jump tp print2




; this label will print world
print2:
	lodsb
	or al,al
	jz print3 ; jump tp print3 label
	or eax,0x5f00 ; this decides the color and color of text
	mov word [ebx], ax ; this line will print on the console
	add ebx,2 ; add 2 to ebx
	jmp print2 ; jump to print2 back



; Printing cr0 value
print3:
	mov edi, 0xb8000 + 158		; setting the VGA buffer
	mov edx, 31			; setting edx to 31, for the index of the msb in cr3 (it is 64 bits in size)
	xor ecx, ecx				; initialising ecx as 0



	printcr0:
		cmp edx, 0				; comparing if our counter edx is 0
		jl end              ; if edx is 0, we jump end label
		mov eax, cr0			; Move value of cr0 to eax
		mov ebx, 0				; initialise our counter eax to 0


		shift_eax:
			cmp ebx, edx		; If ebx equals edx
			je next             ; jump to the next label
			add ebx, 1			; increment in ebx counter by 1
			shr eax, 1			; right shift by 1 position of eax
			jmp shift_eax	; jump to shift_eax back



		next:
			and eax, 1			; AND one particular index of eax with 1
			add ecx, 2			; add ecx with 2
			cmp eax, 1			; If our print bit is 1
			je eax_one   ; jump to eax_one if eax is equals to 1


			mov eax, 0xf530	; else print it on VGA as 0
			mov [edi+ecx], eax ; this line will print on the console
			jmp loop ; jump to loop label


			eax_one:
				mov eax, 0xf531	; print it on the VGA as 1
				mov [edi+ecx], eax  ; this line will print on the console
				jmp loop ; jump to loop label

			loop:
			sub edx, 1			; Subtract by in our edx counter
			jmp printcr0 ; jump tp printcro back




end:
	cli ; clear interrupt flag
	hlt ; halt execution


; str1 contains "Hello "
str1: db "Hello ",0
; str2 contains "world!"
str2: db "world!",0



times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeroes



dw 0xaa55 ;  marks this 512 byte sector bootable