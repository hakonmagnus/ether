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

org 0x500
bits 16

;=============================================================================;
; start                                                                       ;
; Loader 16-bit entry point                                                   ;
;=============================================================================;
start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0xFFFF
    sti
    
    call gdt_install
    call a20_enable

    xor eax, eax
    xor ebx, ebx
    call bios_get_memory_size

    mov word [boot_info.mem_lower], ax
    mov word [boot_info.mem_upper], bx

    mov eax, 0
    mov ds, ax
    mov di, 0x9000
    call bios_get_memory_map
    
    cli
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x8:loader32

%include "./loader/rm/gdt.asm"
%include "./loader/rm/a20.asm"
%include "./loader/rm/memory.asm"
%include "./loader/bootinfo.asm"
%include "./loader/loader32.asm"
