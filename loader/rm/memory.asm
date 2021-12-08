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

bits 16

struc memory_map_entry
    .base               resq 1
    .length             resq 1
    .type               resd 1
    .acpi_null          resd 1
endstruc

;=============================================================================;
; bios_get_memory_map                                                         ;
; Get memory map from BIOS.                                                   ;
; @param ES:DI = Destination for map                                          ;
; @return BP = Entry count                                                    ;
;=============================================================================;
bios_get_memory_map:
    pushad

    xor ebx, ebx
    xor bp, bp

    mov edx, 'PAMS'
    mov eax, 0xE820
    mov ecx, 24
    int 0x15
    jc .error

    cmp eax, 'PAMS'
    jne .error
    
    test ebx, ebx
    je .error

    jmp .start

.next_entry:
    mov edx, 'PAMS'
    mov ecx, 24
    mov eax, 0xE820
    int 0x15

.start:
    jcxz .skip_entry

.notext:
    mov dword ecx, [es:di + memory_map_entry.length]
    test ecx, ecx
    jne short .good_entry

    mov dword ecx, [es:di + memory_map_entry.length + 4]
    jecxz .skip_entry

.good_entry:
    inc bp
    add di, 24

.skip_entry:
    cmp ebx, 0
    jne .next_entry
    jmp .done

.error:
    stc

.done:
    popad
    ret

;=============================================================================;
; bios_get_memory_size                                                        ;
; Get memory size using the BIOS.                                             ;
; @return AX = KB between 1MB and 16MB, BX = Number of 64K blocks above 16MB  ;
; @return AX = -1, BX = 0 on error                                            ;
;=============================================================================;
bios_get_memory_size:
    push ecx
    push edx

    xor ecx, ecx
    xor edx, edx
    
    mov ax, 0xE801
    int 0x15
    jc .error

    cmp ah, 0x86
    je .error

    cmp ah, 0x80
    je .error

    jcxz .use_ax

    mov ax, cx
    mov bx, dx

.use_ax:
    pop edx
    pop ecx
    ret

.error:
    mov ax, -1
    mov bx, 0
    pop edx
    pop ecx
    ret
