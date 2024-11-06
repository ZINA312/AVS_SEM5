use16 
org 0x7c00 ; загрузчик отступ
.main:
    xor ax, ax   
    mov ds, ax
    mov ss, ax                 
    mov sp, 0x7c00 ; стек после загрузчика
    cld            ; движение вперед
	
	; очистка экрана
	mov ax, 0x3
	int 0x10

    lea si, [MSG_REAL_MODE]
    call .println
	
	; ожидание символа
    xor ax, ax
    int 0x16
	
	mov ax, 0x3
	int 0x10

	; читаем сектор кода
	mov si, 0x7e00		)
	push si
	push 1 
	call .read_sector
	add sp, 2
	
	; читаем сектор данных
	mov si, 0x8000		
	push si
	push 2 			
	call .read_sector
	add sp, 2
	
	call .switch_to_protected_mode
  
include 'utils.asm'
include 'gdt.asm'
include "switch_protected_mode.asm"

MSG_REAL_MODE db "real mode", 0      

; загрузчик
times 510-($-$$) db 0
dw 0xaa55