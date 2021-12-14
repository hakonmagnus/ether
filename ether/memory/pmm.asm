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

extern itoa
extern vga_text_print_string

%define PMM_PAGE_SIZE           4096
%define PMM_PAGES_PER_QWORD     64
%define PMM_PAGES_PER_BYTE      8

global pmm_init
global pmm_reserve_region

section .data

pmm_memory_size                 dq 0
integer                         times 18 db 0

section .text

;=============================================================================;
; pmm_reserve_region                                                          ;
; Reserve a region of memory                                                  ;
; @param RDI = Start of region                                                ;
; @param RSI = Length of region                                               ;
;=============================================================================;
pmm_reserve_region:
    push rsi
    push rdi
    push rax
    push rbx
    push rcx
    push rdx
    
    pop rdx
    pop rcx
    pop rbx
    pop rax
    pop rsi
    pop rdi
    ret

;=============================================================================;
; pmm_init                                                                    ;
;=============================================================================;
pmm_init:
    push rdi
    push rsi
    push rax
    push rbx
    push rdx

    mov rax, rdi
    mov rbx, 1024 * 1024
    mul rbx

    mov qword [pmm_memory_size], rax

.done:
    pop rdx
    pop rbx
    pop rax
    pop rsi
    pop rdi
    ret
