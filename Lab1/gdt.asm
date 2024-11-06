align 8
.gdt_start: 
    ; ������ 8 ������ ������
    dd 0x0 ; 4 �����
    dd 0x0 

; ��� �������� ���� ���� 0�7�00, ����� 0�200 ������ RX
.gdt_code: 
	db 0x00, 0x02, 0x00, 0x7e, 0x00, 0x9a, 0x40, 0x00 

; ��� �������� ������ ���� 0�8000, ����� 0�200 ������ RW
.gdt_data:
	db 0x00, 0x02, 0x00, 0x80, 0x00, 0x92, 0x40, 0x00 

; ��� �������� ������ ���� 0�b8000, ����� 0�ffff ������ RW	
.gdt_gpu:
	db 0xff, 0xff, 0x00, 0x80, 0x0b, 0x92, 0x40, 0x00 
	
; ��� �������� ������ ���� 0x8200, ����� 0�200 ������ RW
.gdt_stack:
	db 0x00, 0x02, 0x00, 0x82, 0x00, 0x92, 0x40, 0x00 

.gdt_end:

; GDT ����������
.gdt_descriptor:
    dw .gdt_end - .gdt_start - 1 	
    dd .gdt_start 				

; ����������� �������� ���������
CODE_SEG equ .gdt_code - .gdt_start
DATA_SEG equ .gdt_data - .gdt_start
GPU_SEG equ .gdt_gpu - .gdt_start
STACK_SEG equ .gdt_stack - .gdt_start