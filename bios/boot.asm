bits 16
org 0

start:
    mov ax, 0x07C0
    add ax, 544
    cli
    mov ss, ax
    mov sp, 4096
    sti

    mov ax, 0x07C0
    mov ds, ax

    mov si, boot_msg
    call print_string

    cmp dl, 0
    je .no_change

    mov byte [bootdev], dl
    mov ah, 8
    int 0x13
    jc disk_error
    and cx, 0x3F
    mov word [SectorsPerTrack], cx
    movzx dx, dh
    inc dx
    mov word [Sides], dx

.no_change:
    mov eax, 0

    cli
    hlt

disk_error:
    mov si, .msg
    call print_string
    xor ax, ax
    int 0x16
    xor ax, ax
    int 0x19

.msg db "Disk error. Press any key to reboot...", 13, 10, 0

print_string:
    pusha
    mov ah, 0x0E

.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop

.done:
    popa
    ret

bootdev db 0
SectorsPerTrack dw 0
Sides dw 0
boot_msg db "Booting Ether...", 13, 10, 0

times 0x1B8-($-$$) db 0

; Disk signature
dd 0
dw 0

; Non-bootable
db 0

; CHS 0,0,2
db 0
db 2
db 0

; GPT partitioned disk

db 0xEE

; End CHS

db 0xFF
db 0xFF
db 0xFF

; Relative sectors

dd 0

; Partition size

dd 0xFFFFFFFF

times 0x30 db 0

dw 0xAA55
