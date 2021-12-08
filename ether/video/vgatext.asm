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

%define VGA_TEXT_VIDEO_MEMORY   0xB8000
%define VGA_TEXT_COLS           80
%define VGA_TEXT_LINES          25

section .text

global vga_text_put_char
global vga_text_print_string
global vga_text_clear_screen
global vga_text_move_cursor

;=============================================================================;
; vga_text_put_char                                                           ;
; Print a single character to the console                                     ;
; @param RDI = ASCII character                                                ;
;=============================================================================;
vga_text_put_char:
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    mov rax, rdi

    cmp al, 0x08
    jne .cont1

    cmp byte [vga_text_cursor_x], 0
    je .cont1

    dec byte [vga_text_cursor_x]
    jmp .finish

.cont1:
    cmp al, 0x09
    je .tab

    cmp al, 0x0D
    je .cr

    cmp al, 0x0A
    je .nl

    cmp al, 0x20
    jb .finish
    
    mov bl, al
    mov rdi, VGA_TEXT_VIDEO_MEMORY
    xor rax, rax

    mov ecx, VGA_TEXT_COLS * 2
    mov byte al, [vga_text_cursor_y]
    mul rcx
    push rax

    mov byte al, [vga_text_cursor_x]
    mov cl, 2
    mul cl
    pop rcx
    add rax, rcx

    xor rcx, rcx
    add rdi, rax

    mov dl, bl
    mov byte dh, [vga_text_color]
    mov word [rdi], dx

    inc byte [vga_text_cursor_x]
    jmp .finish

.tab:
    add byte [vga_text_cursor_x], 8
    and byte [vga_text_cursor_x], ~7
    jmp .finish

.cr:
    mov byte [vga_text_cursor_x], 0
    jmp .finish

.nl:
    mov byte [vga_text_cursor_x], 0
    inc byte [vga_text_cursor_y]

.finish:
    cmp byte [vga_text_cursor_x], 80
    jb .done

    mov byte [vga_text_cursor_x], 0
    inc byte [vga_text_cursor_y]

.done:
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    call vga_text_move_cursor
    ret

;=============================================================================;
; vga_text_print_string                                                       ;
; Print a string to the console                                               ;
; @param RDI = Pointer to string                                              ;
;=============================================================================;
vga_text_print_string:
    push rax

.loop:
    xor rax, rax
    mov byte al, [rdi]
    
    test al, al
    jz .done

    push rdi
    mov rdi, rax
    call vga_text_put_char
    pop rdi

    inc rdi
    jmp .loop

.done:
    pop rax
    ret

;=============================================================================;
; vga_text_clear_screen                                                       ;
; Clear the screen to the current attribute byte                              ;
;=============================================================================;
vga_text_clear_screen:
    pushf
    push rax
    push rcx
    push rdi
    
    cld
    mov rdi, VGA_TEXT_VIDEO_MEMORY
    mov rcx, 2000
    mov byte ah, [vga_text_color]
    mov al, ' '
    rep stosw

    mov byte [vga_text_cursor_x], 0
    mov byte [vga_text_cursor_y], 0
    call vga_text_move_cursor

    pop rdi
    pop rcx
    pop rax
    popf
    ret

;=============================================================================;
; vga_text_move_cursor                                                        ;
; Move the hardware cursor                                                    ;
;=============================================================================;
vga_text_move_cursor:
    push rax
    push rbx
    push rcx
    push rdx

    mov byte bh, [vga_text_cursor_y]
    mov byte bl, [vga_text_cursor_x]

    xor rax, rax
    mov rcx, VGA_TEXT_COLS
    mov al, bh
    mul rcx
    add al, bl
    mov rbx, rax

    mov al, 0x0F
    mov dx, 0x3D4
    out dx, al

    mov al, bl
    mov dx, 0x3D5
    out dx, al

    xor rax, rax

    mov al, 0x0E
    mov dx, 0x3D4
    out dx, al

    mov al, bh
    mov dx, 0x3D5
    out dx, al

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

section .data

vga_text_cursor_x               dq 0            ; X position
vga_text_cursor_y               dq 0            ; Y position
vga_text_color                  dq 0x0F         ; Attribute byte
