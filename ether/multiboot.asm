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

extern _start
extern vga_text_print_string
extern vga_text_put_char
extern itoa

global multiboot_parse
global mem_lower
global mem_upper
global bios_boot_device
global bios_memory_map

section .multiboot
align 4
header_start:
dd 0xE85250D6
dd 0
dd header_start - header_end
dd 0x100000000 - 0xE85250D6 - (header_start - header_end)

; Entry tag
dw 3
dw 0
dd 12
dd _start

dw 0
dw 0
dw 0
header_end:

section .data
global boot_info

boot_info dq 0

mem_lower dq 0
mem_upper dq 0
bios_boot_device dq 0
bios_memory_map times 64 dd 0

int_string times 15 db 0

section .text

;=============================================================================;
; multiboot_parse                                                             ;
; Parse the multiboot info passed from the bootloader                         ;
;=============================================================================;
multiboot_parse:
    push rsi
    push rax
    push rbx
    push rcx

    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx

    mov qword rsi, [boot_info]
    mov dword ecx, [rsi]
    add rsi, 8
    sub rcx, 8

.next_tag:
    cmp rcx, 0
    jbe .done
    
    mov dword eax, [rsi]
    mov dword ebx, [rsi+4]

    cmp eax, 4
    je .memory_info_tag

    cmp eax, 5
    je .boot_device_tag

    cmp eax, 6
    je .memory_map_tag

    cmp eax, 0
    je .done

.skip_tag:
    add rsi, rbx
    sub rcx, rbx
    jmp .next_tag

.memory_info_tag:
    mov dword eax, [rsi+8]
    mov dword [mem_lower], eax

    mov dword eax, [rsi+12]
    mov dword [mem_upper], eax

    jmp .skip_tag

.boot_device_tag:
    mov dword eax, [rsi+8]
    mov dword [bios_boot_device], eax

    jmp .skip_tag

.memory_map_tag:
    push rcx
    push rsi

    cld
    mov rcx, rbx
    lea qword rdi, [bios_memory_map]
    add rsi, 16
    sub rcx, 16
    rep movsb

    pop rsi
    pop rcx
    jmp .skip_tag

.done:
    pop rcx
    pop rbx
    pop rax
    pop rsi
    ret
