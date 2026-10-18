; ------------------------------------------------------------------
; Ghosts'n Goblins Arcade (Atari XL/XE + VBXE): memory map and symbols.
;
; The C64 program runs at its own addresses. The Atari runtime uses RAM
; the game never touches after its boot (see README):
;   $C300-$CFFF, $E000-$EFFF   runtime code
;   $DC10-$DCFF, $DD10-$DFFF   runtime variables, shadows of the C64 chips
;   $0400-$05FF, $1A00-$1BFF   screen shadow (char layer contents)
;   zero page $40-$4F          runtime pointers
; $DC00-$DC0F and $DD00-$DD0F stay the C64 CIA registers (plain RAM);
; $D800-$DBFF is the C64 colour RAM.
; ------------------------------------------------------------------

; --- Atari hardware (the OS is switched off while the game runs)
TRIG0   = $D010
TRIG1   = $D011
PAL     = $D014
COLBK   = $D01A
PRIOR   = $D01B
CONSOL  = $D01F
AUDF1   = $D200
AUDC1   = $D201
AUDF2   = $D202
AUDC2   = $D203
AUDF3   = $D204
AUDC3   = $D205
AUDF4   = $D206
AUDC4   = $D207
AUDCTL  = $D208
KBCODE  = $D209
RANDOM  = $D20A
IRQEN   = $D20E
IRQST   = $D20E
SKCTL   = $D20F
SKSTAT  = $D20F
PORTA   = $D300
PORTB   = $D301
DMACTL  = $D400
DLISTL  = $D402
DLISTH  = $D403
VCOUNT  = $D40B
NMIEN   = $D40E
NMIST   = $D40F
NMIRES  = $D40F

; --- VBXE register offsets (base $D600, patched to $D700 at start-up
; through the table the build appends: every absolute operand $D640-$D65F)
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
VB_P0   = $55
VB_MEMB = $5D
VB_MEMC = $5E
VB_MEMS = $5F
VBX     = $D600

; --- C64 chip shadows (Atari RAM)
VIC     = $DE00          ; 64 bytes: VIC-II registers as the game wrote them
SID     = $DF00          ; 32 bytes: SID registers (same low address byte)
CIA1    = $DC00          ; the game's own view of the CIAs (plain RAM)
CIA2    = $DD00

; --- runtime zero page (never used by the game): $40-$47 for code running
; in the main context (KERNAL calls, loader, idle work), $48-$4F and
; $30-$39 for the NMI
ZP      = $40
upd_ptr = $44            ; next char-layer update slot (window address)
sc_p    = $46            ; sprite blit cache entry (bank SPR, main context)
ZPN     = $48
ZPX     = $30
spr_tag = $0320          ; sprite cache tags (200 bytes)

; --- VRAM layout (19-bit addresses)
FBW     = 368            ; framebuffer stride: 24 + 320 + 24
FBH     = 200            ; C64 raster lines 51-250
FBM     = 24             ; left margin
V_FB0   = $00000
V_FB1   = $12000
V_CL    = $24000         ; char layer 320x200, row-ring per char row
V_TILE  = $34000         ; 6 tile slots x 16K (256 chars x 64 bytes)
NSLOT   = 6
V_SPR   = $4C000         ; 200 sprite slots x 512 (24 x 21 pixels)
NSPR    = 200
V_LIST0 = $65000         ; blitter list of framebuffer 0
V_LIST1 = $66800         ; blitter list of framebuffer 1
V_VIC   = $68000         ; image of the VIC bank $C000-$FFFF as the VIC sees it
V_XDL   = $6C000         ; two XDLs ($6C000, $6C100), scratch pixel at $6C200
V_COLSH = $6C400         ; colour RAM shadow (1000 bytes)
V_SAVE  = $6C800         ; saved high scores (256 bytes)
V_FILES = $6CA00         ; packed disk files and patch tables
V_STAGE = $00000         ; load-time staging of the RAM image (in FB0/FB1)
V_RTIMG = $10000         ; load-time staging of the runtime ($C000-$EFFF image)
V_LOG   = $7E000         ; two IRQ chain logs (2K each, 64-byte records)

MEMB_ON = $80            ; MEMAC-B: bank | $80 maps VRAM at $4000-$7FFF
WIN     = $4000

; --- blitter list layout (21-byte BCBs)
NUPD    = 144            ; char layer updates per frame
NREG    = 24             ; region copies and border fills
NSPRB   = 56             ; sprite blits
LST_UPD = 0
LST_REG = NUPD*21
LST_SPR = (NUPD+NREG)*21
LST_LEN = (NUPD+NREG+NSPRB)*21
