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

org 0x7C00
bits 16

start:
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0xFFFF
    
    mov ah, 0x0E
    mov al, 'A'
    int 0x10
    
    hlt

times 446 - ($-$$) db 0

db 0            ; Boot indicator

db 0            ; Starting CHS
db 2
db 0

db 0xEE         ; OS type

db 0xFF         ; Ending CHS
db 0xFF
db 0xFF

dd 1            ; Starting LBA

dd 0xFFFFFFFF   ; Size in LBA

times 510 - ($-$$) db 0

dw 0xAA55