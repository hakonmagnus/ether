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

global sse_init
global sse2_supported
global sse3_supported
global ssse3_supported
global sse41_supported
global sse42_supported
global sse4a_supported
global xop_supported
global fma4_supported
global cvt16_supported
global avx_supported
global xsave_supported
global avx2_supported

section .text

;=============================================================================;
; sse_init                                                                    ;
; Detect SSE/AVX capabilities and enable                                      ;
;=============================================================================;
sse_init:
    push rax
    push rdx

    mov rax, 1
    cpuid
    test rdx, 1 << 25
    jz .done            ; No SSE supported

    mov rax, cr0        ; Enable SSE
    and ax, 0xFFFB
    or ax, 2
    mov cr0, rax
    mov rax, cr4
    or ax, 3 << 9
    mov cr4, rax

    mov rax, 1
    cpuid

    test rdx, 1 << 26   ; Test for SSE2
    jz .no_sse2

    mov byte [sse2_supported], 1

.no_sse2:
    test rcx, 1 << 0    ; Test for SSE3
    jz .no_sse3

    mov byte [sse3_supported], 1

.no_sse3:
    test rcx, 1 << 9    ; Test for SSSE3
    jz .no_ssse3

    mov byte [ssse3_supported], 1

.no_ssse3:
    test rcx, 1 << 19   ; Test for SSE4.1
    jz .no_sse41

    mov byte [sse41_supported], 1

.no_sse41:
    test rcx, 1 << 20   ; Test for SSE4.2
    jz .no_sse42

    mov byte [sse42_supported], 1

.no_sse42:
    test rcx, 1 << 6    ; Test for SSE4A
    jz .no_sse4a

    mov byte [sse4a_supported], 1

.no_sse4a:
    test rcx, 1 << 11   ; Test for XOP
    jz .no_xop

    mov byte [xop_supported], 1

.no_xop:
    test rcx, 1 << 16   ; Test for FMA4
    jz .no_fma4

    mov byte [fma4_supported], 1

.no_fma4:
    test rcx, 1 << 29   ; Test for CVT16
    jz .no_cvt16

    mov byte [cvt16_supported], 1

.no_cvt16:
    test rcx, 1 << 28   ; Test for AVX
    jz .no_avx

    push rax
    push rcx
    push rdx

    xor rcx, rcx
    xgetbv
    or rax, 7
    xsetbv

    pop rdx
    pop rcx
    pop rax

    mov byte [avx_supported], 1

.no_avx:
    test rcx, 1 << 26   ; Test for XSAVE
    jz .no_xsave

    mov byte [xsave_supported], 1

.no_xsave:
    mov rax, 7
    mov rcx, 0
    cpuid

    test rdx, 1 << 26   ; Test for AVX2
    jz .done

    mov byte [avx2_supported], 1

.done:
    pop rdx
    pop rax
    ret

section .data

sse2_supported          db 0
sse3_supported          db 0
ssse3_supported         db 0
sse41_supported         db 0
sse42_supported         db 0
sse4a_supported         db 0
xop_supported           db 0
fma4_supported          db 0
cvt16_supported         db 0
avx_supported           db 0
xsave_supported         db 0
avx2_supported          db 0
