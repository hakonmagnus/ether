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

%define IDT_NUM_ENTRIES 256

%macro ISR 2
isr%1:
    cli
    lea dword esi, [.msg]
    call vga_text_print_string
    hlt
    
    .msg db %2, 13, 10, 0
%endmacro

%macro ISRSET 1
    mov eax, %1
    lea dword esi, [isr%1]
    call idt_set_gate
%endmacro

ISR 0, "Division by zero exception."
ISR 1, "Debug exception."
ISR 2, "Non-maskable interrupt exception."
ISR 3, "Breakpoint exception."
ISR 4, "Overflow exception."
ISR 5, "Bound range exceeded exception."
ISR 6, "Invalid opcode exception."
ISR 7, "Device not available exception."
ISR 8, "Double fault exception."
ISR 10, "Invalid TSS exception."
ISR 11, "Segment not present exception."
ISR 12, "Stack segment fault exception."
ISR 13, "General protection fault exception."
ISR 14, "Page fault exception."
ISR 16, "x87 floating-point exception."
ISR 17, "Alignment check exception."
ISR 18, "Machine check exception."
ISR 19, "SIMD floating-point exception."
ISR 20, "Virtualization exception."
ISR 21, "Control protection exception."
ISR 28, "Hypervisor injection exception."
ISR 29, "VMM communication exception."
ISR 30, "Security exception."

;=============================================================================;
; idt_set_gate                                                                ;
; Set an interrupt gate                                                       ;
; @param EAX = Number                                                         ;
; @param EBX = Selector                                                       ;
; @param ECX = Flags                                                          ;
; @param ESI = Base                                                           ;
;=============================================================================;
idt_set_gate:
    pusha
    
    lea dword edi, [idt_start]
    push ebx
    mov ebx, 8
    mul ebx
    pop ebx
    add edi, eax
    
    mov eax, esi
    mov word [edi], ax
    shr eax, 16
    mov word [edi+6], ax
    mov byte [edi+5], cl
    mov word [edi+2], bx
    
    popa
    ret

;=============================================================================;
; idt_init                                                                    ;
; Initialize the IDT                                                          ;
;=============================================================================;
idt_init:
    pusha
    
    mov ebx, 0x08
    mov ecx, 0x8E
    
    ISRSET 0
    ISRSET 1
    ISRSET 2
    ISRSET 3
    ISRSET 4
    ISRSET 5
    ISRSET 6
    ISRSET 7
    ISRSET 8
    ISRSET 10
    ISRSET 11
    ISRSET 12
    ISRSET 13
    ISRSET 14
    ISRSET 16
    ISRSET 17
    ISRSET 18
    ISRSET 19
    ISRSET 20
    ISRSET 21
    ISRSET 28
    ISRSET 29
    ISRSET 30
    
    sidt [idt_old]
    lidt [idt_ptr]
    
    popa
    ret

idt_old:
    dw 0
    dd 0

idt_start:
    times IDT_NUM_ENTRIES * 8 db 0

idt_ptr:
    dw idt_ptr - idt_start - 1
    dd idt_start