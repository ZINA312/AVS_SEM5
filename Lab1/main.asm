use16 
org 0x7c00 ; ��������� ������
.main:
    xor ax, ax   
    mov ds, ax
    mov ss, ax                 
    mov sp, 0x7c00 ; ���� ����� ����������
    cld            ; �������� ������
	
	; ������� ������
	mov ax, 0x3
	int 0x10

    lea si, [MSG_REAL_MODE]
    call .println
	
	; �������� �������
    xor ax, ax
    int 0x16
	
	mov ax, 0x3
	int 0x10

	; ������ ������ ����
	mov si, 0x7e00		)
	push si
	push 1 
	call .read_sector
	add sp, 2
	
	; ������ ������ ������
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

; ���������
times 510-($-$$) db 0
dw 0xaa55