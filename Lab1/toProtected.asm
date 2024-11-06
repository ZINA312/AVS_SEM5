use16
.switch_to_protected_mode:  
    cli          ; запрещаем прерывания

    in al, 0x92
    or al, 2
    out 0x92, al 

    lgdt [.gdt_descriptor]           	; загружаем дескриптор
    mov eax, cr0
    or eax, 0x1                       	; 32 бит режим в CR0	
    mov cr0, eax
	
	xor ax, ax
		
 ; инициализация регистров
	mov ax, DATA_SEG
    mov ds, ax
    mov fs, ax
    mov gs, ax
	
	
	mov ax, STACK_SEG
	mov ss, ax
	
	
	mov ax, GPU_SEG
	mov es, ax
	
	xor ax, ax

    mov ebp, 0x90000 	
				

    mov esp, ebp     		
	
	jmp CODE_SEG:0 		
	