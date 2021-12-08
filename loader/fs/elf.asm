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

elf_image dd 0
elf_phoff dd 0
elf_phnum dd 0
elf_phsize dd 0
elf_entry dd 0

;=============================================================================;
; elf_execute                                                                 ;
; @param ESI = ELF image                                                      ;
; @param EDX = Load address                                                   ;
;=============================================================================;
elf_execute:
    pusha
    mov dword [elf_image], esi

    cmp dword [esi], 0x464C457F
    jne .error

    mov dword eax, [esi+0x20]
    mov dword [elf_phoff], eax

    xor eax, eax
    mov word ax, [esi+0x38]
    mov dword [elf_phnum], eax
    mov ecx, eax

    mov word ax, [esi+0x36]
    mov dword [elf_phsize], eax

    mov dword eax, [elf_phoff]
    add esi, eax

.next_ph:
    push esi
    mov word ax, [esi]

    cmp ax, 1
    jne .skip_ph

    push ecx

    mov dword eax, [esi+24]
    mov dword ecx, [esi+8]
    mov dword ebx, [esi+32]
    mov dword [elf_entry], eax

    mov dword esi, [elf_image]
    add esi, ecx

    mov edi, eax

    xor edx, edx
    mov eax, ebx
    mov ebx, 4
    div ebx
    mov ecx, eax
    cld
    rep movsd

    pop ecx

.skip_ph:
    pop esi

    add dword esi, [elf_phsize]
    dec ecx

    cmp ecx, 0
    je .execute
    
    jmp .next_ph

.execute:
    popa
    
    jmp 0x8:0x100000
    ret

.error:
    popa
    stc
    ret
