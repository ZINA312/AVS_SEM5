
use32

code_selector:			   
lea esi, [msg - data_selector]  
xor edi, edi
; копируем сообщение в видео память  
lea ecx, [msg_end - msg]
rep movsb
jmp $

db 512-($-code_selector) dup(0)

data_selector:
ATR EQU 0x8f ; белый цвет

msg         db 'p', ATR, 'r', ATR, 'o', ATR, 't', ATR, 'e', ATR, 'c', ATR, 't', ATR, 'e', ATR, 'd', ATR, ' ', ATR
            db 'm', ATR, 'o', ATR, 'd', ATR, 'e', ATR
msg_end:           

db 512-($-data_selector) dup(0)