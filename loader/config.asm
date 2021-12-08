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

config_file dd 0
line dd 0

;=============================================================================;
; config_error                                                                ;
; Error in the configuration file.                                            ;
;=============================================================================;
config_error:
    mov esi, .msg
    call vga_text_print_string
    cli
    hlt

    .msg db "Invalid boot config file.", 13, 10, 0

;=============================================================================;
; config_skip_space                                                           ;
; Skip space in EDI                                                           ;
;=============================================================================;
config_skip_space:
    cmp byte [edi], ' '
    jne .done

    inc edi
    jmp config_skip_space

.done:
    ret

;=============================================================================;
; next_line                                                                   ;
; Read the next line of the config file                                       ;
;=============================================================================;
next_line:
    push eax
    push edi

    mov dword edi, [line]

.loop:
    mov byte al, [esi]

    cmp al, 0
    je .eof

    cmp al, 0x0A
    je .done

    mov byte [edi], al
    inc esi
    inc edi
    jmp .loop

.done:
    mov byte [edi], 0
    pop edi
    pop eax
    inc esi
    clc
    ret

.eof:
    pop edi
    pop eax
    stc
    ret

;=============================================================================;
; config_load                                                                 ;
; Load the configuration file                                                 ;
;=============================================================================;
config_load:
    mov eax, 512
    call mm_alloc
    mov dword [line], eax

    mov eax, 4096
    call mm_alloc
    mov dword [config_file], eax

    mov edi, eax
    call ebfs_read_file

    mov dword esi, [config_file]

.parse_line:
    call next_line
    jc .done

    mov dword edi, [line]
    call config_skip_space

    cmp byte [edi], '#'
    je .skip_line

    push esi
    mov esi, kernel_text
    mov ecx, 6
    call string_compare_c
    jc .parse_kernel
    pop esi

.skip_line:
    jmp .parse_line

.parse_kernel:
    pop esi

    add edi, 6
    call config_skip_space

    push esi
    mov esi, boot_text
    mov ecx, 6
    call string_compare_c
    jnc .pop_config_error
    pop esi

    add edi, 6

    ;==NOTE==;
    ; Currently this only handles a filename in the root directory of /boot.

    pusha
    mov esi, edi
    mov edi, KERNEL_IMAGE
    call ebfs_read_file
    popa

    jmp .skip_line

.pop_config_error:
    pop esi
    jmp config_error

.done:
    ret

kernel_text db "kernel", 0
boot_text db "/boot/", 0
