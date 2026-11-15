; ------------------------------------------------------------------
; Cauldron (Atari XL/XE + VBXE): memory map and symbols.
;
; The C64 program runs at its own addresses ($0F00-$CF02, $E000-$FFFF;
; code $800A-$AA2F). The Atari runtime uses memory the game never touches:
;   $0200-$0DFF   code A: stubs, hooks, NMI/IRQ entry, C64 IRQ runner
;   $0E00-$0EFF   buffer page (boot bounce, sprite/glyph bytes)
;   $DC10-$DCFF, $DD10-$DDFF, $DE40-$DEFF, $DF20-$DFFF  variables
;   $DE00-$DE3F   VIC-II shadow, $DF00-$DF1F SID shadow
;   bank R        8K of VRAM mapped at $E000-$FFFF by MEMAC-A while the
;                 runtime renders (the game's data there is hidden then)
; $D800-$DBE7 is the C64 colour RAM (plain RAM with the OS off), the CIA
; registers $DC00-$DC0F/$DD00-$DD0F are plain RAM the game writes.
; ------------------------------------------------------------------

; --- Atari hardware (the OS is off while the game runs)
TRIG0   = $D010
PAL     = $D014
COLBK   = $D01A
CONSOL  = $D01F
AUDF1   = $D200
AUDC1   = $D201
AUDF2   = $D202
AUDC2   = $D203
AUDCTL  = $D208
KBCODE  = $D209
RANDOM  = $D20A
IRQEN   = $D20E
SKCTL   = $D20F
SKSTAT  = $D20F
PORTA   = $D300
PORTB   = $D301
DMACTL  = $D400
VCOUNT  = $D40B
NMIEN   = $D40E
NMIST   = $D40F
NMIRES  = $D40F

; --- VBXE registers (base $D600; operands are patched to $D7 at start-up
; when the core is at $D700: every absolute operand $D640-$D65F)
VBX     = $D600
VB_VCTL = $40
VB_XDL0 = $41
VB_CSEL = $44
VB_PSEL = $45
VB_CR   = $46
VB_CG   = $47
VB_CB   = $48
VB_BLAD = $50            ; write: list address; read: BLT_COLLISION_CODE
VB_BLIT = $53
VB_IRQC = $54
VB_P0   = $55
VB_MEMB = $5D
VB_MEMC = $5E
VB_MEMS = $5F

; --- C64 chip shadows
VIC     = $DE00
SID     = $DF00

; --- runtime zero page (never used by the game)
ZP      = $F3            ; $F3-$FD: IRQ context (render, chain)
ZN      = $9E            ; $9E-$A3: NMI

; --- VRAM layout
V_FB0   = $00000         ; framebuffers 320x200, stride 320
V_FB1   = $10000
V_CL    = $20000         ; character layer 320x200
V_TILE  = $30000         ; 4 slots x 16K: charset ($7000/$7800) x (MC, hires)
V_SPR   = $40000         ; sprite cache: 128 slots x 512 (24x21 bytes)
NSLOT   = 128
V_SCR   = $50000         ; sprite scratch copies: 8 x 512
V_DUMMY = $51000         ; a 1-pixel BCB (wakes the IRQ)
V_XDL   = $51100         ; XDL of FB0 ($51100) and FB1 ($51180)
V_SHIFT = $51200         ; the band shift BCB
V_UPD   = $54000         ; cell update BCBs, filled backwards from V_REG
V_REG   = $56000         ; region BCBs and sprite scratch copies (run 0)
V_RUNS  = $57000         ; probe and draw runs
V_STAGE = $00000         ; boot: RAM image staging (FB0/FB1)
V_BANK  = $7C000         ; code bank R (8K)
BK_R    = $80|(V_BANK>>12)  ; (4K units, bit 0 ignored for 8K)
BK_N    = $80|($7A000>>12) ; bank N (NMI)
BK_I    = $80|($78000>>12) ; bank I (set-up)

NUPD    = 390            ; update BCB slots
WIN     = $4000          ; MEMAC-B window
MEMB_ON = $80

; pixel codes (palette indices; colour registers only change palettes)
PX_BG   = $40            ; $D021 (multicolour 00, hires 0)
PX_BG1  = $20            ; $D022 (multicolour 01)
PX_FG2  = $80            ; $D023 (multicolour 10)
PX_MC   = $88            ; $88+c: colour RAM c&7 (multicolour 11)
PX_HI   = $90            ; $90+c: colour RAM c (hires 1)
PX_SPR  = $C0            ; $C0+4n+k: sprite n, k = 1 $D025, 2 own, 3 $D026
PX_BRD  = $E0            ; $D020
