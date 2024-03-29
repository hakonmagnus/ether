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

org 0x100000
bits 64

%include "./version.asm"

%define EFI_IMAGE_SUBSYSTEM_EFI_APPLICATION         10
%define EFI_IMAGE_SUBSYSTEM_EFI_BOOT_SERVICE_DRIVER 11
%define EFI_IMAGE_SUBSYSTEM_EFI_RUNTIME_DRIVER      12

%define EFI_IMAGE_MACHINE_IA32                      0x014C
%define EFI_IMAGE_MACHINE_IA64                      0x0200
%define EFI_IMAGE_MACHINE_EBC                       0x0EBC
%define EFI_IMAGE_MACHINE_x64                       0x8664
%define EFI_IMAGE_MACHINE_ARMTHUMB_MIXED            0x01C2
%define EFI_IMAGE_MACHINE_AARCH64                   0xAA64
%define EFI_IMAGE_MACHINE_RISCV32                   0x5032
%define EFI_IMAGE_MACHINE_RISCV64                   0x5064
%define EFI_IMAGE_MACHINE_RISCV128                  0x5128

section .header
dos_header:
    dw 0x5A4D       ; Magic number
    times 29 dw 0   ; Reserved
    dd 0x00000080   ; Address of PE header

dos_stub:
    times 32 dw 0   ; DOS stub

pe_header:
    dd 0x00004550           ; PE header
    dw EFI_IMAGE_MACHINE_x64 ; Machine architecture
    dw 2                    ; Two sections (.text, .data)
    dd 0x61A0EA9A           ; Current epoch
    dd 0                    ; No symbol table
    dd 0                    ; No symbols in the symbol table
    dw oSize                ; Size of optional header
    dw 0x1002               ; System file

oSize equ optional_header_end - optional_header_standard_fields

optional_header_standard_fields:
    dw 0x020B               ; PE32+ Executable
    dw 0                    ; Linker
    dd 4096                 ; Size of code segment
    dd 1024                 ; Size of data segment
    dd 0                    ; No .bss section
    dd 1024                 ; Entry point
    dd 1024                 ; First instruction

optional_header_windows_fields:
    dq 0x100000             ; Entry point address
    dd 1024                 ; Section alignment
    dd 1024                 ; File alignment
    dw 0                    ; Operating system requirements
    dw 0                    ; Cont.
    dw 1                    ; Major image version number
    dw 0                    ; Minor image version number
    dw 0                    ; Major subsystem version
    dw 0                    ; Minor subsystem version
    dd 0                    ; Zero
    dd 6144                 ; Image size
    dd 1024                 ; Header size
    dd 0                    ; Checksum
    dw EFI_IMAGE_SUBSYSTEM_EFI_APPLICATION ; Subsystem
    dw 0                    ; Not a DLL

    dq 0x8000               ; Stack space to reserve
    dq 0x8000               ; Stack space to commit immediately
    dq 0x8000               ; Heap space to reserve
    dq 0                    ; Local heap space to commit immediately
    dd 0                    ; Zero
    dd 0                    ; Number of data dictionary entries

optional_header_end:

section_table:
.1: ; Text section
    dq `.text`              ; Name of section
    dd 4096                 ; Virtual size
    dd 1024                 ; Virtual entry point address
    dd 4096                 ; Actual size
    dd 1024                 ; Actual entry point address
    dd 0                    ; Relocations
    dd 0                    ; Line numbers
    dw 0                    ; Relocations
    dw 0                    ; Line numbers
    dd 0x60000020           ; Contains executable code, can be executed as code, can be read

.2: ; Data section
    dq `.data`              ; Name of section
    dd 1024                 ; Virtual size
    dd 5120                 ; Virtual entry point address
    dd 1024                 ; Actual size
    dd 5120                 ; Actual entry point address
    dd 0                    ; Relocations
    dd 0                    ; Line numbers
    dw 0                    ; Relocations
    dw 0                    ; Line numbers
    dd 0xC0000040           ; Contains initialized data, can be read, can be written to

times 1024 - ($-$$) db 0    ; Alignment

section .text follows=.header

%define EFI_SUCCESS                             0
%define EFI_LOAD_ERROR                          1
%define EFI_INVALID_PARAMETER                   2
%define EFI_UNSUPPORTED                         3
%define EFI_BAD_BUFFER_SIZE                     4
%define EFI_BUFFER_TOO_SMALL                    5
%define EFI_NOT_READY                           6
%define EFI_DEVICE_ERROR                        7
%define EFI_WRITE_PROTECTED                     8
%define EFI_OUT_OF_RESOURCES                    9
%define EFI_VOLUME_CORRUPTED                    10
%define EFI_VOLUME_FULL                         11
%define EFI_NO_MEDIA                            12
%define EFI_MEDIA_CHANGED                       13
%define EFI_NOT_FOUND                           14
%define EFI_ACCESS_DENIED                       15
%define EFI_NO_RESPONSE                         16
%define EFI_NO_MAPPING                          17
%define EFI_TIMEOUT                             18
%define EFI_NOT_STARTED                         19
%define EFI_ALREADY_STARTED                     20
%define EFI_ABORTED                             21
%define EFI_ICMP_ERROR                          22
%define EFI_TFTP_ERROR                          23
%define EFI_PROTOCOL_ERROR                      24
%define EFI_INCOMPATIBLE_VERSION                25
%define EFI_SECURITY_VIOLATION                  26
%define EFI_CRC_ERROR                           27
%define EFI_END_OF_MEDIA                        28
%define EFI_END_OF_FILE                         31
%define EFI_INVALID_LANGUAGE                    32
%define EFI_COMPROMISED_DATA                    33
%define EFI_IP_ADDRESS_CONFLICT                 34
%define EFI_HTTP_ERROR                          35
%define EFI_WARN_UNKNOWN_GLYPH                  1
%define EFI_WARN_DELETE_FAILURE                 2
%define EFI_WARN_WRITE_FAILURE                  3
%define EFI_WARN_BUFFER_TOO_SMALL               4
%define EFI_WARN_STALE_DATA                     5
%define EFI_WARN_FILE_SYSTEM                    6
%define EFI_WARN_RESET_REQUIRED                 7

%define EFI_TABLE_HEADER                        24

%define OFFSET_TABLE_FIRMWARE_VENDOR            EFI_TABLE_HEADER + 10
%define OFFSET_TABLE_FIRMWARE_REVISION          EFI_TABLE_HEADER + 12
%define OFFSET_TABLE_INPUT_CONSOLE_HANDLE       EFI_TABLE_HEADER + 16
%define OFFSET_TABLE_INPUT_CONSOLE              EFI_TABLE_HEADER + 24
%define OFFSET_TABLE_OUTPUT_CONSOLE_HANDLE      EFI_TABLE_HEADER + 32
%define OFFSET_TABLE_OUTPUT_CONSOLE             EFI_TABLE_HEADER + 40
%define OFFSET_TABLE_ERROR_CONSOLE_HANDLE       EFI_TABLE_HEADER + 48
%define OFFSET_TABLE_ERROR_CONSOLE              EFI_TABLE_HEADER + 56
%define OFFSET_TABLE_RUNTIME_SERVICES           EFI_TABLE_HEADER + 64
%define OFFSET_TABLE_BOOT_SERVICES              EFI_TABLE_HEADER + 72
%define OFFSET_TABLE_NUM_TABLE_ENTRIES          EFI_TABLE_HEADER + 80
%define OFFSET_TABLE_CONFIGURATION_TABLE        EFI_TABLE_HEADER + 88

%define OFFSET_BOOT_RAISE_TPL                   EFI_TABLE_HEADER
%define OFFSET_BOOT_RESTORE_TPL                 EFI_TABLE_HEADER + 8
%define OFFSET_BOOT_ALLOCATE_PAGES              EFI_TABLE_HEADER + 16
%define OFFSET_BOOT_FREE_PAGES                  EFI_TABLE_HEADER + 24
%define OFFSET_BOOT_GET_MEMORY_MAP              EFI_TABLE_HEADER + 32
%define OFFSET_BOOT_ALLOCATE_POOL               EFI_TABLE_HEADER + 40
%define OFFSET_BOOT_FREE_POOL                   EFI_TABLE_HEADER + 48
%define OFFSET_BOOT_CREATE_EVENT                EFI_TABLE_HEADER + 54
%define OFFSET_BOOT_SET_TIMER                   EFI_TABLE_HEADER + 64
%define OFFSET_BOOT_WAIT_FOR_EVENT              EFI_TABLE_HEADER + 72
%define OFFSET_BOOT_SIGNAL_EVENT                EFI_TABLE_HEADER + 80
%define OFFSET_BOOT_CLOSE_EVENT                 EFI_TABLE_HEADER + 88
%define OFFSET_BOOT_CHECK_EVENT                 EFI_TABLE_HEADER + 96
%define OFFSET_BOOT_INSTALL_PROTOCOL_INTERFACE  EFI_TABLE_HEADER + 104
%define OFFSET_BOOT_REINSTALL_PROTOCOL_INTERFACE EFI_TABLE_HEADER + 112
%define OFFSET_BOOT_UNINSTALL_PROTOCOL_INTERFACE EFI_TABLE_HEADER + 120
%define OFFSET_BOOT_HANDLE_PROTOCOL             EFI_TABLE_HEADER + 128
%define OFFSET_BOOT_REGISTER_PROTOCOL_NOTIFY    EFI_TABLE_HEADER + 144
%define OFFSET_BOOT_LOCATE_HANDLE               EFI_TABLE_HEADER + 152
%define OFFSET_BOOT_LOCATE_DEVICE_PATH          EFI_TABLE_HEADER + 160
%define OFFSET_BOOT_INSTALL_CONFIGURATION_TABLE EFI_TABLE_HEADER + 168
%define OFFSET_BOOT_IMAGE_LOAD                  EFI_TABLE_HEADER + 176
%define OFFSET_BOOT_IMAGE_START                 EFI_TABLE_HEADER + 184
%define OFFSET_BOOT_EXIT                        EFI_TABLE_HEADER + 192
%define OFFSET_BOOT_IMAGE_UNLOAD                EFI_TABLE_HEADER + 200
%define OFFSET_BOOT_EXIT_BOOT_SERVICES          EFI_TABLE_HEADER + 208
%define OFFSET_BOOT_GET_NEXT_MONOTONIC_COUNT    EFI_TABLE_HEADER + 216
%define OFFSET_BOOT_STALL                       EFI_TABLE_HEADER + 224
%define OFFSET_BOOT_SET_WATCHDOG_TIMER          EFI_TABLE_HEADER + 232
%define OFFSET_BOOT_CONNECT_CONTROLLER          EFI_TABLE_HEADER + 248
%define OFFSET_BOOT_DISCONNECT_CONTROLLER       EFI_TABLE_HEADER + 256
%define OFFSET_BOOT_OPEN_PROTOCOL               EFI_TABLE_HEADER + 264
%define OFFSET_BOOT_CLOSE_PROTOCOL              EFI_TABLE_HEADER + 272
%define OFFSET_BOOT_PROTOCOLS_PER_HANDLE        EFI_TABLE_HEADER + 280
%define OFFSET_BOOT_LOCATE_HANDLE_BUFFER        EFI_TABLE_HEADER + 288
%define OFFSET_BOOT_LOCATE_PROTOCOL             EFI_TABLE_HEADER + 296
%define OFFSET_BOOT_INSTALL_MULTIPLE_PROTOCOL_INTERFACES EFI_TABLE_HEADER + 304
%define OFFSET_BOOT_UNINSTALL_MULTIPLE_PROTOCOL_INTERFACES EFI_TABLE_HEADER + 312
%define OFFSET_BOOT_CALCULATE_CRC32             EFI_TABLE_HEADER + 320
%define OFFSET_BOOT_COPY_MEM                    EFI_TABLE_HEADER + 328
%define OFFSET_BOOT_SET_MEM                     EFI_TABLE_HEADER + 332
%define OFFSET_BOOT_CREATE_EVENT_EX             EFI_TABLE_HEADER + 340

%define OFFSET_LOADED_IMAGE_PARENT_HANDLE       8
%define OFFSET_LOADED_IMAGE_SYSTEM_TABLE        16
%define OFFSET_LOADED_IMAGE_DEVICE_HANDLE       24
%define OFFSET_LOADED_IMAGE_FILE_PATH           32
%define OFFSET_LOADED_IMAGE_LOAD_OPTIONS_SIZE   48
%define OFFSET_LOADED_IMAGE_LOAD_OPTIONS        56
%define OFFSET_LOADED_IMAGE_IMAGE_BASE          64
%define OFFSET_LOADED_IMAGE_IMAGE_SIZE          72
%define OFFSET_LOADED_IMAGE_IMAGE_CODE_TYPE     80
%define OFFSET_LOADED_IMAGE_IMAGE_DATA_TYPE     88
%define OFFSET_LOADED_IMAGE_UNLOAD              96

%define OFFSET_CONSOLE_RESET                    0
%define OFFSET_CONSOLE_OUTPUT_STRING            8
%define OFFSET_CONSOLE_TEST_STRING              16
%define OFFSET_CONSOLE_QUERY_MODE               24
%define OFFSET_CONSOLE_SET_MODE                 32
%define OFFSET_CONSOLE_SET_ATTRIBUTE            40
%define OFFSET_CONSOLE_CLEAR_SCREEN             48
%define OFFSET_CONSOLE_SET_CURSOR_POSITION      56
%define OFFSET_CONSOLE_ENABLE_CURSOR            64
%define OFFSET_CONSOLE_MODE                     72

%define OFFSET_DISK_IO2_CANCEL                  8
%define OFFSET_DISK_IO2_READ                    16
%define OFFSET_DISK_IO2_WRITE                   24
%define OFFSET_DISK_IO2_FLUSH                   32

%define OFFSET_BLOCK_IO_MEDIA                   8

%define EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL    0x00000001
%define EFI_OPEN_PROTOCOL_GET_PROTOCOL          0x00000002
%define EFI_OPEN_PROTOCOL_TEST_PROTOCOL         0x00000004
%define EFI_OPEN_PROTOCOL_BY_CHILD_CONTROLLER   0x00000008
%define EFI_OPEN_PROTOCOL_BY_DRIVER             0x00000010
%define EFI_OPEN_PROTOCOL_EXCLUSIVE             0x00000020

%define EFI_BLACK                               0x00
%define EFI_BLUE                                0x01
%define EFI_GREEN                               0x02
%define EFI_CYAN                                0x03
%define EFI_RED                                 0x04
%define EFI_MAGENTA                             0x05
%define EFI_BROWN                               0x06
%define EFI_LIGHTGRAY                           0x07
%define EFI_BRIGHT                              0x08
%define EFI_DARKGRAY                            0x08
%define EFI_LIGHTBLUE                           0x09
%define EFI_LIGHTGREEN                          0x0A
%define EFI_LIGHTCYAN                           0x0B
%define EFI_LIGHTRED                            0x0C
%define EFI_LIGHTMAGENTA                        0x0D
%define EFI_YELLOW                              0x0E
%define EFI_WHITE                               0x0F

%define EFI_BACKGROUND_BLACK                    0x00
%define EFI_BACKGROUND_BLUE                     0x10
%define EFI_BACKGROUND_GREEN                    0x20
%define EFI_BACKGROUND_CYAN                     0x30
%define EFI_BACKGROUND_RED                      0x40
%define EFI_BACKGROUND_MAGENTA                  0x50
%define EFI_BACKGROUND_BROWN                    0x60
%define EFI_BACKGROUND_LIGHTGRAY                0x70

;=============================================================================;
; start                                                                       ;
; EFI image entry point                                                       ;
;=============================================================================;
start:
    sub rsp, 6*8+8
    
    mov qword [efi_handle], rcx
    mov qword [efi_system_table], rdx
    mov qword [efi_return], rsp
    
    cli
    hlt

times 4096 - ($-$$) db 0                        ; Alignment

section .data follows=.text
data_start:
    efi_handle                      dq 0        ; EFI handle
    efi_system_table                dq 0        ; System table
    efi_return                      dq 0        ; Return

times 1024 - ($-$$) db 0                        ; Alignment