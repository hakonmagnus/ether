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

bits 64

%include "./version.asm"

struc memory_region
    .base       resq 1
    .length     resq 1
    .type       resd 1
    .reserved   resd 1
endstruc

extern boot_info
extern multiboot_parse
extern mem_lower
extern mem_upper
extern bios_boot_device
extern bios_memory_map
extern sse_init
extern itoa
extern stringinit
extern vga_text_print_string
extern vga_text_clear_screen
extern vga_text_put_char

section .text

global main

main:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    call sse_init
    call stringinit

    call vga_text_clear_screen
    lea qword rdi, [welcome_text]
    call vga_text_print_string

    call multiboot_parse

    mov qword rax, [mem_upper]
    mov rbx, 64
    mul rbx
    add rax, 1024
    add qword rax, [mem_lower]

    xor rdx, rdx
    mov rbx, 1024
    div rbx

    lea qword rdi, [mem_text_1]
    call vga_text_print_string

    mov rdi, rax
    lea qword rsi, [integer]
    mov rdx, 15
    mov rcx, 10
    call itoa

    lea qword rdi, [integer]
    call vga_text_print_string

    lea qword rdi, [mem_text_2]
    call vga_text_print_string

    lea qword rdi, [boot_dev_text]
    call vga_text_print_string

    mov qword rdi, [bios_boot_device]
    lea qword rsi, [integer]
    mov rdx, 15
    mov rcx, 16
    call itoa

    lea qword rdi, [integer]
    call vga_text_print_string

    mov rdi, 0x0A
    call vga_text_put_char

    lea qword rdi, [bios_memory_map]
    xor rcx, rcx

.next_entry:
    mov dword eax, [rdi+memory_region.type]

    cmp eax, 4
    jbe .cont

    mov dword [rdi+memory_region.type], 1

.cont:
    cmp rcx, 0
    je .cont2

    cmp qword [rdi+memory_region.base], 0
    je .finish

.cont2:
    xor r10, r10
    mov qword r8, [rdi+memory_region.base]
    mov qword r9, [rdi+memory_region.length]
    mov dword r10d, [rdi+memory_region.type]

    push rdi
    push rcx

    lea qword rdi, [region_text_1]
    call vga_text_print_string

    mov rdi, r8
    lea qword rsi, [integer]
    mov rdx, 18
    mov rcx, 16
    call itoa

    lea qword rdi, [integer]
    call vga_text_print_string

    lea qword rdi, [region_text_2]
    call vga_text_print_string

    mov rdi, r9
    lea qword rsi, [integer]
    mov rdx, 18
    mov rcx, 16
    call itoa

    lea qword rdi, [integer]
    call vga_text_print_string

    lea qword rdi, [region_text_3]
    call vga_text_print_string

    dec r10

    cmp r10, 0
    je .available

    cmp r10, 1
    je .reserved

    cmp r10, 2
    je .acpi_reclaim

    lea qword rdi, [acpi_nvs_text]
    call vga_text_print_string
    jmp .skip_entry

.available:
    lea qword rdi, [available_text]
    call vga_text_print_string
    jmp .skip_entry

.reserved:
    lea qword rdi, [reserved_text]
    call vga_text_print_string
    jmp .skip_entry

.acpi_reclaim:
    lea qword rdi, [acpi_reclaim_text]
    call vga_text_print_string

.skip_entry:
    mov rdi, 0x0A
    call vga_text_put_char

    pop rcx
    pop rdi

    add rdi, 24
    inc rcx
    jmp .next_entry

.finish:

    cli
    hlt

section .data

integer times 18 db 0
welcome_text db "Ether Operating System ", ETHER_VERSION_STRING, " ", ETHER_VERSION_CODENAME, 13, 10, 0
mem_text_1 db "Memory manager initialized with ", 0
mem_text_2 db "MiB of memory.", 13, 10, 0
boot_dev_text db "BIOS boot device: 0x", 0
region_text_1 db "Region start: 0x", 0
region_text_2 db " Region length: 0x", 0
region_text_3 db " Region type: ", 0
acpi_nvs_text db "ACPI NVS Memory", 0
acpi_reclaim_text db "ACPI Reclaim", 0
reserved_text db "Reserved", 0
available_text db "Available", 0
