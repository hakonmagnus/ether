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
    sti
    
    mov byte [bootdev], dl
    
    mov ah, 8
    int 0x13
    jc disk_error
    
    and cx, 0x3F
    mov word [sectors_per_track], cx
    movzx dx, dh
    inc dx
    mov word [sides], dx
    
    mov ax, 1
    call lba_to_hts
    
    mov bx, 0x500
    mov ah, 2
    mov al, 1
    
    pusha

.read_gpt:
    popa
    pusha
    
    stc
    int 0x13
    
    jnc .search_gpt
    call reset_disk
    jnc .read_gpt
    
    jmp disk_error
    
.search_gpt:
    mov si, 0x500
    
    mov word ax, [si]
    cmp ax, 0x4645
    jne corrupt_image
    
    mov word ax, [si+0x48]
    mov word cx, [si+0x50]
    
    push cx
    
    call lba_to_hts
    mov bx, 0x500
    mov ah, 2
    mov al, 32
    
    pusha

.read_entries:
    popa
    pusha
    
    stc
    int 0x13
    
    jnc .search_entries
    call reset_disk
    jnc .read_entries
    
    jmp disk_error

.search_entries:
    pop cx
    mov si, 0x500

.next_entry:
    mov word ax, [si]
    
    cmp ax, 0x6148
    jne .skip_entry
    
    mov word ax, [si+2]
    
    cmp ax, 0x2168
    jne .skip_entry
    
    mov word ax, [si+4]
    
    cmp ax, 0x6449
    jne .skip_entry
    
    mov word ax, [si+6]
    
    cmp ax, 0x6E6F
    je .found_entry

.skip_entry:
    add si, 0x80
    loop .next_entry
    
    jmp corrupt_image

.found_entry:
    mov word ax, [si+0x20]
    call lba_to_hts
    
    mov bx, 0x500
    mov ah, 2
    mov al, 48
    
    pusha
    
.read_loader:
    popa
    pusha
    
    stc
    int 0x13
    
    jnc .execute_loader
    call reset_disk
    jnc .read_loader
    
    jmp disk_error

.execute_loader:
    mov byte dl, [bootdev]
    jmp 0x0:0x500
    cli
    hlt

corrupt_image:
    mov si, .msg
    call print_string
    jmp reboot
    
    .msg db "Corrupt disk image. Press any key to reboot...", 13, 10, 0

disk_error:
    mov si, .msg
    call print_string
    jmp reboot
    
    .msg db "Disk error. Press any key to reboot...", 13, 10, 0

reboot:
    xor ax, ax
    int 0x16
    xor ax, ax
    int 0x19

reset_disk:
    push ax
    push dx
    
    xor ax, ax
    mov byte dl, [bootdev]
    stc
    int 0x13
    
    pop dx
    pop ax
    ret

print_string:
    pusha
    mov ah, 0x0E

.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop

.done:
    popa
    ret

lba_to_hts:
    push bx
    push ax
    
    mov bx, ax
    
    xor dx, dx
    div word [sectors_per_track]
    inc dl
    mov cl, dl
    mov ax, bx
    
    xor dx, dx
    div word [sectors_per_track]
    xor dx, dx
    div word [sides]
    mov dh, dl
    mov ch, al
    
    pop ax
    pop bx
    
    mov byte dl, [bootdev]
    
    ret

bootdev db 0
sectors_per_track dw 0
sides dw 0

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