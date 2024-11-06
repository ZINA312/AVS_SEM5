align 8
.gdt_start: 
    ; начало 8 пустых байтов
    dd 0x0 ; 4 байта
    dd 0x0 

; для сегмента кода база 0х7е00, длина 0х200 доступ RX
.gdt_code: 
	db 0x00, 0x02, 0x00, 0x7e, 0x00, 0x9a, 0x40, 0x00 

; для сегмента данных база 0х8000, длина 0х200 доступ RW
.gdt_data:
	db 0x00, 0x02, 0x00, 0x80, 0x00, 0x92, 0x40, 0x00 

; для сегмента данных база 0хb8000, длина 0хffff доступ RW	
.gdt_gpu:
	db 0xff, 0xff, 0x00, 0x80, 0x0b, 0x92, 0x40, 0x00 
	
; для сегмента данных база 0x8200, длина 0х200 доступ RW
.gdt_stack:
	db 0x00, 0x02, 0x00, 0x82, 0x00, 0x92, 0x40, 0x00 

.gdt_end:

; GDT дескриптор
.gdt_descriptor:
    dw .gdt_end - .gdt_start - 1 	
    dd .gdt_start 				

; определение констант сегментов
CODE_SEG equ .gdt_code - .gdt_start
DATA_SEG equ .gdt_data - .gdt_start
GPU_SEG equ .gdt_gpu - .gdt_start
STACK_SEG equ .gdt_stack - .gdt_start