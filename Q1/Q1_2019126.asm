; Vasudev Singhal
; 2019126

; Below command will tell NASM is 16 Bit code
bits 16
; 
org 0x7c00

boot:
	mov ax, 0x2401
	int 0x15
	mov ax, 0x3
	int 0x10
	cli
	lgdt [gdt_pointer]
	mov eax, cr0
	or eax,0x1
	mov cr0, eax
	jmp CODE_SEG:boot2
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

bits 32
boot2:
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov eax, 0x000000 
	mov esi,str
	mov ebx,0xb8000
	print:
	lodsb
	or al,al
	jz print2
	or eax,0x5f00
	mov word [ebx], ax
	add ebx,2
	jmp print

	; Printing CR0 value
	print2:
		mov edi, 0xb8000 + 158		; Setting the VGA Buffer
		mov edx, 0x1f			; Setting RDX to 63, for the index of the MSB in CR3 (it is 64 bits in size)
		xor ecx, ecx				; Initialising RCX as 0
		printcr0:
			cmp edx, 0				; Comparing if our counter RDX is 0
			jl end              ; If RDX is 0, our printing has finished and we move to finish
			mov eax, cr0			; Move value of CR3 to RAX
			mov ebx, 0				; Initialise our counter RBX to 0

			shift_eax:
				cmp ebx, edx		; If RBX equals RDX
				je next             ; Jump to the next stage
				add ebx, 1			; Increment our counter
				shr eax, 1			; Right shift by 1 position
				jmp shift_eax
			next:
				and eax, 1			; AND one particular index of RAX with 1
				add ecx, 2			; Increment RCX with 2
				cmp eax, 0			; If our print bit is 0
				je eax_zero
					mov eax, 0x5f31	; Print it on the VGA as 1
					mov [edi+ecx], eax
					jmp end_if
				eax_zero:
					mov eax, 0x5f30	; Else print it on VGA as 0
					mov [edi+ecx], eax
				end_if:
				sub edx, 1			; Subtract our Index counter by 1
				jmp printcr0

end:
	cli
	hlt
str: db "Hello world!",0

times 510 - ($-$$) db 0
dw 0xaa55