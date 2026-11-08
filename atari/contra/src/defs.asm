; ------------------------------------------------------------------
; Contra (Atari XL/XE + VBXE): memory map and hardware symbols.
; ------------------------------------------------------------------

; --- Atari hardware (the OS is switched off while the game runs)
HPOSP0  = $D000
SIZEP0  = $D008
GRAFP0  = $D00D
TRIG0   = $D010
TRIG1   = $D011
COLPM0  = $D012
COLBK   = $D01A
PRIOR   = $D01B
GRACTL  = $D01D
CONSOL  = $D01F
AUDF1   = $D200
AUDC1   = $D201
AUDCTL  = $D208
POT0    = $D200
KBCODE  = $D209
POTGO   = $D20B
IRQEN   = $D20E
IRQST   = $D20E
SKCTL   = $D20F
SKSTAT  = $D20F
RANDOM  = $D20A
PORTA   = $D300
PORTB   = $D301
DMACTL  = $D400
DLISTL  = $D402
DLISTH  = $D403
NMIEN   = $D40E
NMIST   = $D40F
NMIRES  = $D40F

; --- VBXE register offsets (base $D600 or $D700, patched at start-up)
VB_VCTL = $40
VB_XDL0 = $41
VB_CSEL = $44
VB_PSEL = $45
VB_CR   = $46
VB_CG   = $47
VB_CB   = $48
VB_BLAD = $50
VB_BLIT = $53
VB_IRQC = $54
VB_MEMB = $5D
VB_MEMC = $5E
VB_MEMS = $5F
VBX     = $D600          ; assembled base; operands are patched for $D700

; --- NES side (addresses the translated banks use)
        icl '../gen/vectors.asm'
VMADDL = $0A40
VMADDH = $0A41
PPU_CONTROL_STATE = $FF
PPU_MASK_STATE    = $09F0
ACTIVE_NES_BANK   = $09F1
BANK_SWITCH_CTRL_REGS = $09F4
BUNNY_MODE = $09FC     ; title's BAX BUNNY entry (written by the NES code)
        icl '../gen/nes-labels.asm'
; NES_NMI = generated
; NES_RESET = generated

; --- VRAM layout (19-bit addresses)
V_PRG     = $00000       ; PRG banks 0-6, 16K each
V_SLOT_BG = $1C000       ; expanded background tiles (256 x 64 bytes)
V_NT_A    = $20000       ; nametable bitmap A, 256x240
V_LIST0   = $2F000       ; blitter list for framebuffer 0 (4K)
V_NT_B    = $30000       ; nametable bitmap B
V_XDL     = $3F000       ; two XDLs, scratch pixel
V_FB0     = $40000       ; framebuffers 256x240
V_LIST1   = $4F000       ; blitter list for framebuffer 1
V_FB1     = $50000
V_CHRIDX  = $60000       ; writable NES CHR RAM: two 4K pattern tables
V_SLOT_OBJ = $78000      ; 256 expanded 8x16 sprite patterns (32K)
V_SCRATCH = $3F800       ; target of unused list entries
V_STAGE   = $40000       ; load-time staging of the RAM images (in FB0/FB1)

MEMB_LIST0 = $80 | (V_LIST0 >> 14)
MEMB_LIST1 = $80 | (V_LIST1 >> 14)
MEMB_SBG  = $80 | (V_SLOT_BG >> 14)
MEMB_SOBJ = $80 | (V_SLOT_OBJ >> 14)
MEMB_XDL  = $80 | (V_XDL >> 14)
LISTCPU   = $4000 + (V_LIST0 & $3FFF)
        ert (V_LIST0 & $3FFF) <> (V_LIST1 & $3FFF)
XDLCPU    = $4000 + (V_XDL & $3FFF)

; --- blitter list layout (21-byte BCBs at V_LIST0/V_LIST1)
MAXT      = 112          ; tile slots, filled from the end backwards
NBG       = 6            ; background/HUD rectangles
MAXS      = 64           ; sprite slots
BG0       = MAXT         ; first background slot
SPR0      = MAXT + NBG   ; first sprite slot

; --- main RAM
ZP        = $10          ; 8 bytes of scratch, saved by the NMI handler
NT_A      = $2800        ; nametable shadows, 1K each
NT_B      = $2C00
DIRTY     = $0C00        ; [phys*128 + row*4 + col/8], bit col&7
ROWDIRTY  = $0D00        ; [phys*32 + row]
PALSH     = $0D80        ; NES palette RAM shadow (32)
PALSNAP   = $0DA0        ; palette of the frame being composed (32)
SC_Y      = $0E00        ; per list and sprite slot (list*64 + slot): what the
SC_T      = $0E80        ; slot's BCB draws: OAM y, tile, attribute (bit 5 set:
SC_A      = $0F00        ; hidden) and x
SC_X      = $0F80
EXPF_BG   = $3880        ; expanded-tile flags, one byte per tile
EXPF_OBJ  = $3980
DLISTS    = $0900        ; PAL tick display lists (read by ANTIC, below the window)

ROW_USES = $3000       ; 64 tile rows x 256-bit pattern membership (conservative)
CHR_BITS = $3800       ; background patterns changed since last renderer scan
CHR_SNAP = $3820
CHR_LIST = $3840
CHR_COUNT = $3860
MDC_MAX  = 96           ; cached CHR scan marks: DIRTY index and bits
MDC_IDX  = $3B40        ; (free gap after the NES palette tables)
MDC_VAL  = $3BA0

; Fail the build if any allocation reaches the following VRAM region.
        ert V_PRG + 7*$4000 > V_SLOT_BG
        ert V_SLOT_BG + 256*64 > V_NT_A
        ert V_NT_A + 256*240 > V_LIST0
        ert V_LIST0 + (MAXT+NBG+MAXS)*21 > V_NT_B
        ert V_NT_B + 256*240 > V_XDL
        ert V_XDL + $40 + 10 > V_SCRATCH
        ert V_SCRATCH + 1 > V_FB0
        ert V_FB0 + 256*240 > V_LIST1
        ert V_LIST1 + (MAXT+NBG+MAXS)*21 > V_FB1
        ert V_FB1 + 256*240 > V_CHRIDX
        ert V_CHRIDX + $2000 > V_SLOT_OBJ
        ert V_SLOT_OBJ + 256*128 > $80000

; Game ticks per picture (see flip_due): NTSC 60 ticks/s -> 30 pictures/s;
; PAL 60 ticks/s in 50 frames -> 20 pictures/s, each exactly 3 ticks.
PACE_NTSC = 2
; PAL_60HZ = 1 drives the game at the NES's 60 ticks per second on PAL as
; well (an extra DLI tick in five of six frames). 0 runs one tick per frame,
; 50 per second like the European NES release: the game is a sixth slower
; but a sixth of the CPU goes to drawing instead.
PAL_60HZ = 0
    .if PAL_60HZ
PACE_PAL = 3
    .else
PACE_PAL = 2
    .endif
