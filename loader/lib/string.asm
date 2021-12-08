;=============================================================================|
;  _______ _________          _______  _______                                |
;  (  ____ \\__   __/|\     /|(  ____ \(  ____ )                              |
;  | (    \/   ) (   | )   ( || (    \/| (    )|                              |
;  | (__       | |   | (___) || (__    | (____)|    By Hákon Hjaltalín.       |
;  |  __)      | |   |  ___  ||  __)   |     __)    Licensed under MIT.       |
;  | (         | |   | (   ) || (      | (\ (                                 |
;  | (____/\   | |   | )   ( || (____/\| ) \ \__                              |
;  (_______/   )_(   |/     \|(_______/|/   \__/                              |
;=============================================================================|

bits 32

;=============================================================================;
; string_compare_c                                                            ;
; Compares two strings with count                                             ;
; @param ESI = String one                                                     ;
; @param EDI = String two                                                     ;
; @param ECX = String length                                                  ;
; @return CF set if equal                                                     ;
;=============================================================================;
string_compare_c:
    pusha

.loop:
    mov byte al, [esi]
    mov byte bl, [edi]
    
    cmp al, bl
    jne .noteq

    dec ecx

    cmp ecx, 0
    je .eq

    inc esi
    inc edi
    jmp .loop

.noteq:
    popa
    clc
    ret

.eq:
    popa
    stc
    ret

;=============================================================================;
; string_compare                                                              ;
; Compares two strings                                                        ;
; @param ESI = String one                                                     ;
; @param EDI = String two                                                     ;
; @return CF set if equal                                                     ;
;=============================================================================;
string_compare:
    pusha

.loop:
    mov byte al, [esi]
    mov byte bl, [edi]

    cmp al, bl
    jne .noteq

    test al, al
    jz .eq

    inc esi
    inc edi
    jmp .loop

.noteq:
    popa
    clc
    ret

.eq:
    popa
    stc
    ret

;=============================================================================;
; int_to_string                                                               ;
; Convert an integer to a string                                              ;
; @param EAX = Integer                                                        ;
; @return ESI = String                                                        ;
;=============================================================================;
int_to_string:
    pusha

    xor ecx, ecx
    mov ebx, 10
    mov edi, .t

.push:
    xor edx, edx
    div ebx
    inc ecx
    push edx
    test eax, eax
    jnz .push

.pop:
    pop edx
    add dl, '0'
    mov byte [edi], dl
    inc edi
    dec ecx
    jnz .pop

    mov byte [edi], 0

    popa
    lea dword esi, [.t]
    ret

    .t times 18 db 0
