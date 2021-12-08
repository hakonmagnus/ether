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

extern vga_text_put_char
extern sse42_supported

section .text

global stringinit
global itoa
global strrev
global strlen
global strlen_normal
global streln_sse42

stringinit:
    mov qword [strlen], strlen_normal

    cmp byte [sse42_supported], 0
    jne .sse42
    jmp .done

.sse42:
    mov qword [strlen], strlen_sse42

.done:
    ret

;=============================================================================;
; itoa                                                                        ;
; Convert an integer to a string                                              ;
; @param RDI = Number to convert                                              ;
; @param RSI = Output string pointer                                          ;
; @param RDX = Length of output string                                        ;
; @param RCX = Base                                                           ;
; @return RAX = Zero on success                                               ;
;=============================================================================;
itoa:
    push rbx
    push rcx
    push rdx
    push rdi
    push r8
    push r9
    push r10

    mov r8, rdi
    xor r9, r9
    xor r10, r10
    mov qword [.length], rdx
    dec qword [.length]
    mov qword [.string], rsi

    cmp rdx, 0
    je .done

.loop:
    xor rdx, rdx
    mov rax, r8
    div rcx

    cmp dl, 0xA
    jae .digit

    add dl, '0'
    mov byte [rsi], dl
    jmp .cont

.digit:
    add dl, 'A' - 0xA
    mov byte [rsi], dl

.cont:
    mov r8, rax
    inc rsi
    inc r9

    cmp r8, 0
    je .finish

    cmp qword r9, [.length]
    jae .finish
    jmp .loop

.finish:
    cmp r8, 0
    je .finish2

    cmp qword r9, [.length]
    je .done

.finish2:
    mov qword [.return], 0
    mov byte [rsi], 0

    mov rdi, [.string]
    call strrev

.done:
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    mov qword rax, [.return]
    ret

    .length dq 0
    .return dq -1
    .string dq 0

;=============================================================================;
; strrev                                                                      ;
; Reverse a string                                                            ;
; @param RDI = Pointer to string                                              ;
;=============================================================================;
strrev:
    push rdi
    push rax
    push rbx
    push rcx

    call [strlen]
    dec rax
    xor rcx, rcx

.loop:
    cmp rcx, rax
    jae .done

    mov byte bh, [rdi+rcx]
    mov byte bl, [rdi+rax]
    mov byte [rdi+rcx], bl
    mov byte [rdi+rax], bh

    inc rcx
    dec rax
    jmp .loop

.done:
    pop rcx
    pop rbx
    pop rax
    pop rdi
    ret

;=============================================================================;
; strlen_normal                                                               ;
; Regular strlen function                                                     ;
; @param RDI = Pointer to string                                              ;
; @return RAX = String length                                                 ;
;=============================================================================;
strlen_normal:
    push rdi
    xor rax, rax

.loop:
    cmp byte [rdi], 0
    je .done
    
    inc rdi
    inc rax
    jmp .loop

.done:
    pop rdi
    ret

;=============================================================================;
; strlen_sse42                                                                ;
; SSE4.2 strlen function                                                      ;
; @param RDI = Pointer to string                                              ;
; @return RAX = String length                                                 ;
;=============================================================================;
strlen_sse42:
    xor rax, rax
    pxor xmm0, xmm0

.loop:
    pcmpistri xmm0, [rdi + rax], 0x08
    lea qword rax, [rax + 16]
    jnz .loop

    lea qword rax, [rax + rcx - 16]
    ret

section .data

strlen dq 0
