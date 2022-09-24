include "defines.asm"

ORG 0x0066

PUSH AF
PUSH BC
PUSH DE
PUSH HL
; start a new session
LD A, send_mem_cmd
OUT (31), A
; save first 16k
LD HL, 0x4000
LD BC, 0xFF1F
LD A, 0x40
saveLoop:
    OTIR
    LD B, 0xFF
    DEC A
JR NZ, saveLoop
; load the main app
LD A, recv_mem_cmd
OUT (31), A
; load our code
LD HL, 0x4000
LD BC, 0xFF1F
LD A, 0x40
loadLoop:
    INIR
    LD B, 0xFF
    DEC A
JR NZ, loadLoop
; jump into unkown :)
JP 0x5800
