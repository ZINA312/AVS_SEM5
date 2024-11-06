use16
.println:
    lodsb 			; вывод сообщений
    test al, al
    jz   .exit_println
    mov  ah, 0xE
    int  0x10
    jmp  .println
.exit_println:
    mov  al, 0xA 	
    int  0x10 
    mov al, 0x0d 	
    int 0x10
    ret
	
.read_sector:   ; чтение сектора
    push bp
    mov bp, sp
    
    mov ah, 2 			
    mov al, 1			
    mov dh, 0
    mov dl, 1 		
    mov ch, 0
    mov cl, [bp+4] 		
    mov bx, [bp+6] 		
    int 0x13
    
    mov sp, bp
    pop bp
    ret
