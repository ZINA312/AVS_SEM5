.386p
RM_seg segment para public "CODE" use16
        assume cs:RM_seg,ds:PM_seg,ss:stack_seg
start:
; �������� �������
        mov        ax,3
        int        10h
; ����������� ���������� ��������
        push       PM_seg
        pop        ds    
; ��������� ���� ��� ���� ������������ ��������� ������
        xor        eax, eax
        mov        ax,RM_seg
        shl        eax,4
        mov        word ptr [GDT_16bitCS+2],ax
        shr        eax,16
        mov        byte ptr GDT_16bitCS+4,al
        mov        ax,PM_seg
        shl        eax,4
        mov        word ptr GDT_32bitCS+2,ax
        mov        word ptr GDT_32bitSS+2,ax
        shr        eax,16
        mov        byte ptr GDT_32bitCS+4,al
        mov        byte ptr GDT_32bitSS+4,al
; ��������� �������� ����� GDT
        xor        eax,eax
        mov        ax,PM_seg
        shl        eax,4
        push       eax
        add        eax,offset GDT
        mov        dword ptr gdtr+2,eax
; ��������� GDT
        lgdt       fword ptr gdtr
; ��������� �������� ������ ��������� TSS ���� �����
        pop        eax
        push       eax
        add        eax,offset TSS_0
        mov        word ptr GDT_TSS0+2,ax
        shr        eax,16
        mov        byte ptr GDT_TSS0+4,al
        pop        eax
        add        eax,offset TSS_1
        mov        word ptr GDT_TSS1+2,ax
        shr        eax,16
        mov        byte ptr GDT_TSS1+4,al
; ������� �20
        mov        al,2
        out        92h,al
; ��������� ����������
        cli
; ��������� NMI
        in         al,70h
        or         al,80h
        out        70h,al
; ������������� � ��
        mov        eax,cr0
        or         al,1
        mov        cr0,eax
; ��������� CS
        db         66h
        db         0EAh
        dd         offset PM_entry
        dw         SEL_32bitCS
 
RM_return:
; �������������    � �������� ����� RM
        mov        eax,cr0
        and        al,0FEh
        mov        cr0,eax
; �������� ������� ����������� � ��������� CS
        db         0EAh
        dw         $+4
        dw         RM_seg
; ��������� ���������� �������� ��� ��������� ������
        mov        ax,PM_seg
        mov        ds,ax
        mov        es,ax
        mov        ax,stack_seg
        mov        bx,stack_l
        mov        ss,ax
        mov        sp,bx
; ��������� NMI
        in         al,70h
        and        al,07FH
        out        70h,al
; ��������� ����������
        sti
; ��������� ���������
        mov        ah,4Ch
        int        21h
RM_seg  ends
 
PM_seg segment para public "CODE" use32
        assume cs:PM_seg
 
; ������� ���������� ������������
GDT       label    byte
                   db    8 dup(0)
GDT_flatDS         db    0FFh,0FFh,0,0,0,10010010b,11001111b,0
GDT_16bitCS        db    0FFh,0FFh,0,0,0,10011010b,0,0
GDT_32bitCS        db    0FFh,0FFh,0,0,0,10011010b,11001111b,0
GDT_32bitSS        db    0FFh,0FFh,0,0,0,10010010b,11001111b,0
; ������� TSS ������ 0 (32-������ ��������� TSS)
GDT_TSS0           db    067h,0,0,0,0,10001001b,01000000b,0
; ������� TSS ������ 1 (32-������ ��������� TSS)
GDT_TSS1           db    067h,0,0,0,0,10001001b,01000000b,0
gdt_size = $ - GDT
gdtr               dw    gdt_size-1    ; ������ GDT
                   dd    ?             ; ����� GDT
; ������������ ���������
SEL_flatDS         equ   001000b
SEL_16bitCS        equ   010000b
SEL_32bitCS        equ   011000b
SEL_32bitSS        equ   100000b
SEL_TSS0           equ   101000b
SEL_TSS1           equ   110000b
 
; ������� TSS_0 
TSS_0              db    68h dup(0)
; ������� TSS_1
TSS_1              dd    0,0,0,0,0,0,0,0                ; �����, �����, CR3
                   dd    offset task_1                  ; EIP
; �������� ������ ����������
                   dd    0,0,0,0,0,stack_l2,0,0,0B8140h ; (ESP � EDI)
; ���������� ��������
                   dd    SEL_flatDS,SEL_32bitCS,SEL_32bitSS,SEL_flatDS,0,0
                   dd    0                              ; LDTR
                   dd    0                              ; ����� ������� �����-������
 
; ����� ����� � 32-������ ���������� �����
PM_entry:
; ����������� ��������
        xor        eax,eax
        mov        ax,SEL_flatDS
        mov        ds,ax
        mov        es,ax
        mov        ax,SEL_32bitSS
        mov        ebx,stack_l
        mov        ss,ax
        mov        esp,ebx
; ��������� TSS ������ 0 � ������� TR
        mov        ax,SEL_TSS0
        ltr        ax
; ������� � PM
        xor        eax,eax
        mov        edi,0B8000h          ; DS:EDI - ����� ������ ������
        mov        al,65 
task_0:
        mov        byte ptr ds:[edi],al ; ������� ������ AL �� �����
; ������� ������� �� TSS ������ 1
        db         0EAh
        dd         0
        dw         SEL_TSS1
        add        edi,2                ; DS:EDI - ����� ���������� �������
        inc        al                   ; AL - ��� ���������� �������,
        cmp        al,91                ; ���� ��� 80,
        jb         task_0               ; ����� �� �����
; ������� ������� �� ��������� ������ � �������� �����
        db         0EAh
        dd         offset RM_return
        dw         SEL_16bitCS
 
; ������ 1
task_1:
mov al, 65
task_loop:
        mov        byte ptr ds:[edi],al ; ������� ������ �� �����
        inc        al                   ; ��������� ��� �������
        add        edi,2                ; ��������� ����� �������
; ������������� �� ������ 0
        db         0EAh
        dd         0
        dw         SEL_TSS0
        mov        ecx,02000000h        ; ��������� �����
        loop       $                    
        jmp        task_loop
 
PM_seg  ends
         
stack_seg segment para stack "STACK"
stack_start        db    100h dup(?)    ; ���� ������ 0
stack_l = $ - stack_start
stack_task2        db    100h dup(?)    ; ���� ������ 1
stack_l2 = $ - stack_start
stack_seg ends
 
        end        start