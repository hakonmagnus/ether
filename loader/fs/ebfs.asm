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

%define EBFS_INODE_SIZE 24

ebfs_buffer dd 0
efi_part_text db "EFI PART", 0
ebfs_first_lba dd 0
ebfs_block_size dd 0
ebfs_group_size dd 0
ebfs_total_inodes dd 0
ebfs_root_directory dd 0
ebfs_inodes dd 0
ebfs_current_directory dd 0
ebfs_group_size_bytes dd 0

;=============================================================================;
; ebfs_read_groups                                                            ;
; Read a group sequence                                                       ;
; @param EAX = Group address                                                  ;
; @param ESI = Buffer                                                         ;
;=============================================================================;
ebfs_read_groups:
    pusha

.next_group:
    cmp eax, 0xFFFFFFFF
    je .done

    mov dword ebx, [ebfs_group_size]
    mul ebx
    add dword eax, [ebfs_first_lba]

    mov dword edi, [ebfs_buffer]
    mov ecx, 8
    call [disk_read_c]
    mov dword edi, [ebfs_buffer]

    mov dword edx, [edi+2]
    add edi, 16
    mov dword ecx, [ebfs_group_size_bytes]
    sub ecx, 16

.copyloop:
    mov dword eax, [edi]
    mov dword [esi], eax
    add esi, 4
    add edi, 4
    sub ecx, 4

    cmp ecx, 0
    jne .copyloop

    mov eax, edx
    jmp .next_group

.done:
    popa
    ret

;=============================================================================;
; ebfs_read_file                                                              ;
; Read file from the current directory                                        ;
; @param ESI = Filename                                                       ;
; @param EDI = Buffer                                                         ;
; @return EAX = File size                                                     ;
;=============================================================================;
ebfs_read_file:
    pusha

    mov dword [.buffer], edi
    mov dword edi, [ebfs_current_directory]

.next_entry:
    xor eax, eax
    mov word ax, [edi+6]

    cmp eax, 0
    je .not_found

    add edi, 8
    mov ecx, eax
    sub ecx, 8

    call string_compare_c
    jc .found

    sub edi, 8
    add edi, eax
    jmp .next_entry

.found:
    sub edi, 8

    mov dword eax, [edi]
    mov dword [.inode], eax

    mov ebx, EBFS_INODE_SIZE
    mul ebx

    mov dword ebx, [ebfs_group_size_bytes]
    sub ebx, 16
    xor edx, edx
    div ebx
    mov dword [.offset], edx

    add dword eax, [ebfs_inodes]
    mov dword ebx, [ebfs_group_size]
    mul ebx
    add dword eax, [ebfs_first_lba]
    mov dword edi, [ebfs_buffer]
    mov ecx, 8
    call [disk_read_c]

    mov dword edi, [ebfs_buffer]
    add edi, 16
    add dword edi, [.offset]

    mov dword eax, [edi+20]
    mov dword esi, [.buffer]
    call ebfs_read_groups

    popa
    clc
    mov dword eax, [.size]
    ret

.not_found:
    popa
    stc
    ret

    .buffer dd 0
    .size dd 0
    .inode dd 0
    .offset dd 0

;=============================================================================;
; ebfs_init                                                                   ;
; Initialize EBFS                                                             ;
;=============================================================================;
ebfs_init:
    pusha

    mov eax, 0x200 * 8
    call mm_alloc
    mov dword [ebfs_buffer], eax

    mov eax, 0x200 * 16
    call mm_alloc
    mov dword [ebfs_current_directory], eax

    mov eax, 1
    mov dword edi, [ebfs_buffer]
    call [disk_read]

    mov dword esi, [ebfs_buffer]
    mov edi, efi_part_text
    call string_compare
    jnc ebfs_error

    mov dword ecx, [esi+0x50]
    mov dword eax, [esi+0x48]
    mov dword edi, [ebfs_buffer]
    call [disk_read]

    mov dword esi, [ebfs_buffer]

.next_entry:
    mov dword eax, [esi]
    cmp eax, 0x1B64A89C
    jne .skip_entry

    mov dword eax, [esi+4]
    cmp eax, 0xD04A0B29
    jne .skip_entry

    mov dword eax, [esi+8]
    cmp eax, 0x530C3595
    jne .skip_entry

    mov dword eax, [esi+12]
    cmp eax, 0xC6018A3D
    je .found

.skip_entry:
    add esi, 0x80
    dec ecx

    cmp ecx, 0
    jne .next_entry

    jmp ebfs_error

.found:
    mov dword eax, [esi+0x20]
    mov dword [ebfs_first_lba], eax

    inc eax
    mov dword edi, [ebfs_buffer]
    call [disk_read]

    mov dword esi, [ebfs_buffer]

    mov word ax, [esi]
    cmp ax, 0xEBF5
    jne ebfs_error

    mov word ax, [esi+2]
    cmp ax, 0x0100
    jne ebfs_error

    mov dword eax, [esi+0x4]
    mov dword [ebfs_block_size], eax

    mov dword eax, [esi+0x8]
    mov dword [ebfs_group_size], eax

    mov dword eax, [esi+0x10]
    mov dword [ebfs_total_inodes], eax

    mov dword eax, [esi+0x24]
    mov dword [ebfs_root_directory], eax

    mov dword eax, [esi+0x28]
    mov dword [ebfs_inodes], eax

    mov dword eax, [ebfs_group_size]
    mov dword ebx, [ebfs_block_size]
    mul ebx
    mov dword [ebfs_group_size_bytes], eax

    mov dword eax, [ebfs_root_directory]
    mov dword esi, [ebfs_current_directory]
    call ebfs_read_groups

    popa
    ret

;=============================================================================;
; ebfs_error                                                                  ;
; Corrupt EBFS system.                                                        ;
;=============================================================================;
ebfs_error:
    mov esi, .msg
    call vga_text_print_string
    cli
    hlt

    .msg db "EBFS error.", 13, 10, 0
