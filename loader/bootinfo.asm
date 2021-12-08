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

boot_info:
    dd boot_info_end - boot_info            ; total_size
    dd 0                                    ; reserved

    ; Basic memory information
    dd 4                                    ; type
    dd 16                                   ; size
    .mem_lower dd 0                         ; mem_lower
    .mem_upper dd 0                         ; mem_upper

    ; BIOS boot device
    dd 5                                    ; type
    dd 20                                   ; size
    .biosdev dd 0                           ; biosdev
    .partition dd 0                         ; partition
    .sub_partition dd 0                     ; sub_partition

boot_info_end:
