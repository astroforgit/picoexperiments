; ------------------------------------------------------------------
; Phoenix (Atari XL/XE + VBXE): memory map and hardware symbols
; ------------------------------------------------------------------

; --- Atari hardware (the OS ROM is switched off while the game runs)
TRIG0   = $D010
TRIG1   = $D011
COLPF0  = $D016
COLBK   = $D01A
PRIOR   = $D01B
GRACTL  = $D01D
CONSOL  = $D01F
PAL     = $D014
AUDF1   = $D200
AUDC1   = $D201
AUDCTL  = $D208
POT0    = $D200
KBCODE  = $D209
RANDOM  = $D20A
POTGO   = $D20B
IRQEN   = $D20E
SKCTL   = $D20F
SKSTAT  = $D20F
PORTA   = $D300
PORTB   = $D301
DMACTL  = $D400
NMIEN   = $D40E
NMIST   = $D40F
NMIRES  = $D40F
VCOUNT  = $D40B

; --- VBXE registers (assembled for $D600; build.py lists every use so the
; start-up code can move them to $D700)
VBX     = $D600
VB_VCTL = VBX+$40
VB_XDL0 = VBX+$41
VB_XDL1 = VBX+$42
VB_XDL2 = VBX+$43
VB_CSEL = VBX+$44
VB_PSEL = VBX+$45
VB_CR   = VBX+$46
VB_CG   = VBX+$47
VB_CB   = VBX+$48
VB_BLAD0 = VBX+$50
VB_BLAD1 = VBX+$51
VB_BLAD2 = VBX+$52
VB_BLIT = VBX+$53
VB_IRQC = VBX+$54
VB_MEMB = VBX+$5D
VB_MEMC = VBX+$5E
VB_MEMS = VBX+$5F

; --- VRAM layout (19-bit addresses)
V_FG     = $00000       ; fg layer bitmap, 256 x 256 (arcade 208 x 256 at x = 0)
V_BG     = $10000       ; bg layer bitmap
V_FB0    = $20000       ; framebuffers 256 x 240
V_FB1    = $30000
V_FGT    = $40000       ; fg tiles, 256 x 64 bytes
V_BGT    = $44000       ; bg tiles
V_BANK1  = $48000       ; the arcade RAM bank that is not at $4000
V_XDL    = $49000       ; two XDLs
V_LIST   = $4A000       ; blitter list (4K)
V_SCRATCH = $4BF00      ; target of dummy blits
V_STAGE  = $50000       ; load-time images of the RAM areas

WIN      = $5000        ; MEMAC-A window, 4K
MEMC_WIN = $58          ; MEMAC-A at $5000, 4K, CPU access
BANK_LIST = $80|(V_LIST>>12)
BANK_XDL  = $80|(V_XDL>>12)
BANK_B1   = $80|(V_BANK1>>12)

; --- blitter list layout (21-byte BCBs in the list bank)
TMAX     = 150          ; tile slots, filled from the end backwards
NBGB     = 4            ; background pieces
NFGB     = 16           ; foreground runs + terminator
SLOT_BG  = TMAX
SLOT_FG  = TMAX+NBGB
NSLOT    = TMAX+NBGB+NFGB

; --- zero page: the 8080 registers and runtime scratch
zL      = $80
zH      = $81
zE      = $82
zD      = $83
zC      = $84
zB      = $85
tA      = $86
tF      = $87
tF2     = $88
tR      = $89
tR2     = $8A
rp      = $90           ; runtime pointers / scratch $90-$BF
rp2     = $92
rp3     = $94
rt0     = $96
rt1     = $97
rt2     = $98
rt3     = $99
rt4     = $9A
rt5     = $9B
sv_a    = $9C
sv_r    = $9D
q_head  = $9E
q_tail  = $9F
vframe  = $A0
cur_bank = $A1
cur_pal = $A2
scroll  = $A3
slot    = $A4           ; next free tile slot (counts down)
sp_lo   = $A5           ; its address in the window
sp_hi   = $A6
back    = $A7           ; framebuffer being composed (0/1)
flip_req = $A8
comp_ready = $A9
comp_pal = $AA
shown_pal = $AB
rescan  = $AC           ; 0, or 1 while comparing all tiles with the shadows
rs_pos  = $AD           ; rescan position (0..$67F: fg $000-$33F, bg $340-$67F)
rs_hi   = $AE
is_pal  = $AF
tick6   = $B0
inbits  = $B1           ; IN0 bits pressed (active high), built in the VBI
vreg    = $B2
in_prev = $B3
armed   = $B4
q_lx    = $B5
snd_a   = $B6
snd_b   = $B7
nmi_a   = $B8
nmi_x   = $B9
nmi_y   = $BA
fg_run  = $BB
code    = $BC
cnt     = $BD
rs_lim  = $BE
vtime   = $C0           ; VCOUNT units since start (VBI adds a frame)
tk_now  = $C2
tk_next = $C4
tk_fr   = $C6           ; VCOUNT units per frame
tk_per  = $C7           ; per game tick
tk_v    = $C8
vc_vbi  = $C9           ; VCOUNT at the last VBI
snd_rp  = $CA           ; hook argument pointer (main program)
snd_vp  = $CC           ; sound table pointer (VBI)

; --- main RAM
Q_LO    = $0200         ; tile queue: addresses of changed video RAM bytes
Q_HI    = $0300
ROMDATA = $0400         ; arcade ROM $0400-$3FFF (data tables) at its own address
ZRAM    = $4000         ; arcade RAM
