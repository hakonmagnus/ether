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

%include "./version.asm"

%define KERNEL_IMAGE 0x200000

loader32:
    cli
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000
    
%ifdef ETHER_DEBUG
    call vga_text_clear_screen
    mov esi, welcome_text
    call vga_text_print_string
%endif

    call idt_init
    call pic_remap
    sti

    ; All else fails, use ATA PIO mode
    lea dword esi, [ata_lba_read]
    mov dword [disk_read], esi

    lea dword esi, [ata_lba_read_c]
    mov dword [disk_read_c], esi

    call ebfs_init
    mov esi, config_path
    call config_load

    mov esi, KERNEL_IMAGE
    call elf_execute

    jmp $

welcome_text db "Ether OS Loader v1.0.0", 13, 10, 0
config_path db "boot.config", 0

disk_read dd 0
disk_read_c dd 0

%include "./loader/lib/string.asm"
%include "./loader/video/vgatext.asm"
%include "./loader/cpu/idt.asm"
%include "./loader/apic/pic.asm"
%include "./loader/disk/atapio.asm"
%include "./loader/memory/mm.asm"
%include "./loader/fs/ebfs.asm"
%include "./loader/fs/elf.asm"
%include "./loader/config.asm"

loader_end:
