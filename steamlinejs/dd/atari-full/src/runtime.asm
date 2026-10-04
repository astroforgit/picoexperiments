; ------------------------------------------------------------------
; Double Dragon for Atari XL/XE + VBXE: runtime that runs the original
; NES game code. Assembled as a RAM image for $0A50-$3FFF; the loader
; (boot.asm) stages it in VRAM and copies it into place.
; ------------------------------------------------------------------
        icl 'defs.asm'

; ---- variables ($0A50-$0BFF)
        org $0A50
pw_val  .ds 1
pw_a    .ds 1
pw_x    .ds 1
pw_y    .ds 1
pw_t    .ds 1
pw_mask .ds 1
pw_col  .ds 1
pw_row  .ds 1
pw_phys .ds 1
ppu_inc .ds 1
inc_bit .ds 1
mirror  .ds 1
any_dirty .ds 1
pal_dirty .ds 1
nmi_on .ds 1
nes_buttons .ds 1
nes_buttons2 .ds 1
obj_bank .ds 1
bg_bank .ds 1
lat_x   .ds 1
lat_y   .ds 1
lat_ctrl .ds 1
hud_nt  .ds 1
hud_on  .ds 1
in_vbi  .ds 1
zp_save .ds 8
pending .ds 1
back    .ds 1
snap_dirty .ds 1
snap_hpos .ds 1
drops   .ds 1
vframe  .ds 2
c_hud   .ds 1
c_hudnt .ds 1
c_mask  .ds 1
c_x     .ds 1
c_y     .ds 1
c_ctrl  .ds 1
budget  .ds 1
tslot   .ds 1
et_p    .ds 1
et_ri   .ds 1
et_di   .ds 1
et_r    .ds 1
et_b    .ds 1
et_bcol .ds 1
et_v    .ds 1
et_k    .ds 1
et_c    .ds 1
et_tile .ds 1
et_attr .ds 1
et_sh   .ds 1
et_and  .ds 1
br_k    .ds 1
br_t    .ds 1
eb_n    .ds 1
eb_s    .ds 1
eb_nt   .ds 1
eb_ys   .ds 1
eb_y    .ds 1
eb_h    .ds 1
eb_sy   .ds 1
eb_sx   .ds 1
eb_dx   .ds 1
eb_w    .ds 1
eb_cur  .ds 1
es_n    .ds 1
es_i    .ds 1
es_y    .ds 1
es_a    .ds 1
es_x    .ds 1
es_t    .ds 1
ex_memb .ds 1
ex_t    .ds 1
ex_b    .ds 1
ex_i    .ds 1
ex_o    .ds 1
ri_b    .ds 1
c_memb  .ds 1
es_on   .ds 1
es_ci   .ds 1
es_cy   .ds 1
es_f    .ds 1
es_w0   .ds 1
oe_x    .ds 1
vbl_seen .ds 1
memb_sh .ds 1
id_ot   .ds 1
id_odone .ds 1
id_bt   .ds 1
id_bdone .ds 1
id_bank .ds 1
id_t    .ds 1
id_memb .ds 1
id_b    .ds 1
id_u    .ds 2
id_k    .ds 1
id_buf  .ds 16
wv_x    .ds 1
s_len   .ds 4
s_env   .ds 4
s_div   .ds 4
s_start .ds 4
s_hi    .ds 4
s_lin   .ds 1
s_vol   .ds 1
s_reg   .ds 1
s_t     .ds 2
s_oct   .ds 1
s_p     .ds 3
s_m     .ds 3
s_k     .ds 1
s_audf  .ds 1
pitch_k .ds 1
wv_y    .ds 1
cu_flag .ds 1
cu_patched .ds 1
        ert * > $0B00
; ---- more variables ($0B80-$0BFF)
        org $0B80
ri_b2   .ds 1
pot_val .ds 4
pot_rest .ds 4
src_armed .ds 1
nc_a    .ds 1
tick_mode .ds 1
ti_fire .ds 1
ti_ud   .ds 1
kb_head .ds 1
kb_tail .ds 1
kb_ring .ds 8
kdir    .ds 1
kpulse  .ds 1
kpulse_t .ds 1
hud_age .ds 1
ti_pulse_f .ds 1
ti_pulse_s .ds 1
tick_phase .ds 1
ticks_owed .ds 1
nmi_depth .ds 1
memb_save .ds 8
vbxe_hi .ds 1
        .print 'variables end: ', *
        ert * > $0C00
nt_page   = $0B00        ; 64: shadow page for each PPU address high byte
nt_physof = $0B40        ; 64: physical nametable for each high byte

; ---- the fixed service vector table the banks call
        icl '../gen/vector-table.asm'
        ert * > $10A0

; ---- code
        org $10A0
        icl 'render.asm'

; ------------------------------------------------------------------
; start: entered from the loader with the OS off, A = VBXE page ($D6/$D7)
; ------------------------------------------------------------------
start   sei
        cld
        ldx #$FF
        txs
        sta vbxe_hi
        lda #0
        sta NMIEN
        sta DMACTL
        sta IRQEN
        lda #$FE
        sta PORTB               ; OS ROM off, BASIC off
        jsr vbxe_patch
        ; vectors
        lda #<nmi
        sta $FFFA
        lda #>nmi
        sta $FFFB
        lda #<irq
        sta $FFFE
        sta $FFFC
        lda #>irq
        sta $FFFF
        sta $FFFD
        ; POKEY and GTIA
        lda #0
        sta AUDCTL
        ldx #7
st_au   sta AUDF1,x
        dex
        bpl st_au
        lda #3
        sta SKCTL

        lda #0
        sta GRACTL
        sta PRIOR
        sta SIZEP0
        sta HPOSP0
        sta COLBK
        lda #$F0
        sta GRAFP0
        lda #2
        sta COLPM0
        ; NES RAM and the runtime's state
        lda #0
        tax
st_clr  sta $0000,x
        sta $0200,x
        sta $0300,x
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        sta $0800,x
        sta $0900,x
        sta $0A00,x
        sta DIRTY,x
        sta ROWDIRTY,x
        sta PALSH-$80,x
        inx
        bne st_clr
        ldx #$4F
st_clr2 sta $0100,x
        dex
        bpl st_clr2
        ldx #146                ; POKEY pitch constant: NTSC
        lda $D014
        and #$0E
        bne st_ntsc
        ldx #145                ; PAL
st_ntsc stx pitch_k
        lda #$FF
        sta pot_rest
        sta pot_rest+1
        sta pot_rest+2
        sta pot_rest+3
        lda #0
        sta src_armed
        sta kb_head
        sta kb_tail
        sta kdir
        sta kpulse
        sta kpulse_t
        lda #$40                ; keyboard IRQ
        sta IRQEN
        lda #$80
        sta RDNMI
        lda #1
        sta ppu_inc
        lda #$FF
        sta obj_bank
        sta bg_bank
        lda #$1F
        sta BANK_SWITCH_CTRL_REGS
        lda #$FF
        sta mirror
        lda #3
        jsr set_mirroring
        jsr gfx_init
        lda #0
gi_19   sta VBX+VB_MEMB         ; services in $4000-$7FFF visible
        lda #6
        sta ACTIVE_NES_BANK
        jsr prg_bank
        jsr ticks_init
        cli
        jmp NES_RESET

; PAL: 60 game ticks per second from display list interrupts (the original
; runs at 60 Hz); NTSC: one per vertical blank.
ticks_init
        lda #0
        sta tick_phase
        sta ticks_owed
        sta tick_mode
        lda $D014
        and #$0E
        bne ti_ntsc
        inc tick_mode
        ; five display lists: blank lines, a DLI at the end of line L, JVB
        ldx #0
ti_dl   txa
        asl
        asl
        asl
        asl
        asl                     ; 32 bytes each
        tay
        lda dli_line,x
        beq ti_jvb
        sec
        sbc #7                  ; lines 8..L
ti_8    cmp #9
        bcc ti_rest
        pha
        lda #$70
        sta DLISTS,y
        iny
        pla
        sec
        sbc #8
        jmp ti_8
ti_rest sec
        sbc #1
        asl
        asl
        asl
        asl
        ora #$80                ; (n-1)<<4 blank lines with DLI
        sta DLISTS,y
        iny
ti_jvb  lda #$41
        sta DLISTS,y
        txa
        asl
        asl
        asl
        asl
        asl
        clc
        adc #<DLISTS
        sta DLISTS+1,y
        lda #>DLISTS
        adc #0
        sta DLISTS+2,y
        inx
        cpx #5
        bne ti_dl
        lda dl_lo
        sta DLISTL
        lda dl_hi
        sta DLISTH
        lda #$20                ; display list DMA only
        sta DMACTL
        lda #$C0
        sta NMIEN
        rts
ti_ntsc lda #$40
        sta NMIEN
        rts
dli_line dta 0,196,144,92,40
dl_lo   :5 dta <(DLISTS+#*32)
dl_hi   :5 dta >(DLISTS+#*32)

; ---- patch every VBXE register operand to the detected page
vbxe_patch
        lda vbxe_hi
        cmp #>VBX
        beq vp_rts
        ldx #0
vp_1    lda vbxe_sites,x
        sta ZP
        lda vbxe_sites+1,x
        sta ZP+1
        ora ZP
        beq vp_rts
        ldy #0
        lda vbxe_hi
        sta (ZP),y
        inx
        inx
        bne vp_1
vp_rts  rts
vbxe_sites
        dta a(pb_mems+2, vw_busy+2, vf_x0+2, vf_x1+2, vf_x2+2, lp_ps+2, lp_cs+2)
        dta a(lp_r+2, lp_g+2, lp_b+2, lp_ps2+2, lp_cs2+2, lp_r2+2, lp_g2+2, lp_b2+2)
        dta a(mb_1+2, mb_2+2, mb_3+2, co_bl0+2, co_bl1+2, co_bl2+2, co_bs+2)
        dta a(ex_ms1+2, ex_ms2+2, ex_mb+2)
        dta a(gi_1+2, gi_2+2, gi_3+2, gi_4+2, gi_5+2, gi_6+2, gi_7+2, gi_8+2, gi_9+2)
        dta a(gi_10+2, gi_11+2, gi_12+2, gi_13+2, gi_14+2, gi_15+2, gi_16+2, gi_17+2, gi_18+2)
        dta a(gi_19+2)
        dta a(mb_7+2, mb_8+2, mb_9+2, mb_10+2)
        dta a(mb_4+2, mb_5+2, cu_bl0+2, cu_bl1+2, cu_bl2+2, cu_bs+2)
        dta a(0)

; ------------------------------------------------------------------
; VBXE set-up: windows, cleared bitmaps, list slots, XDLs, palette
; ------------------------------------------------------------------
gfx_init
        lda #0
gi_1    sta VBX+VB_VCTL
gi_2    sta VBX+VB_IRQC
        lda #$8A                ; MEMAC-A: 16K at $8000, CPU only
gi_3    sta VBX+VB_MEMC
        lda #MEMB_LIST0
gi_4    sta VBX+VB_MEMB
        ; clear both nametable bitmaps and framebuffers: 4 fills
        ldx #4*21-1
gi_c1   lda clear_list,x
        sta LISTCPU,x
        dex
        bpl gi_c1
        lda #<V_LIST0
gi_5    sta VBX+VB_BLAD
        lda #>(V_LIST0&$FFFF)
gi_6    sta VBX+VB_BLAD+1
        lda #V_LIST0>>16
gi_7    sta VBX+VB_BLAD+2
        lda #1
gi_8    sta VBX+VB_BLIT
gi_w    lda VBX+VB_BLIT
        bne gi_w
gi_9    = gi_w
        ; fixed fields of every slot in both lists
        lda #MEMB_LIST0
        ldx #0
        jsr init_list
        lda #MEMB_LIST1
        ldx #1
        jsr init_list
        ; sprite caches: every slot hidden, tile 0 at (0,0) unflipped
        ldx #127
gi_sc   lda #0
        sta SC_Y,x
        sta SC_T,x
        sta SC_X,x
        lda #$20
        sta SC_A,x
        dex
        bpl gi_sc
        lda #0
        tax
gi_ef   sta EXPF_BG,x
        sta EXPF_OBJ,x
        inx
        bne gi_ef
        ; XDLs
        lda #MEMB_XDL
gi_10   sta VBX+VB_MEMB
        ldx #xdl_len-1
gi_x    lda xdl0,x
        sta XDLCPU,x
        lda xdl1,x
        sta XDLCPU+$40,x
        dex
        bpl gi_x
        lda #MEMB_LIST0
gi_11   sta VBX+VB_MEMB
        ; all palette entries black
        lda #1
gi_12   sta VBX+VB_PSEL
        lda #0
gi_13   sta VBX+VB_CSEL
        ldx #0
gi_p    lda #0
gi_14   sta VBX+VB_CR
gi_15   sta VBX+VB_CG
gi_16   sta VBX+VB_CB
        inx
        bne gi_p
        ; show framebuffer 0, compose into 1
        lda #0
        sta back
        jsr flip_init
        lda #1
gi_17   sta VBX+VB_VCTL         ; XDL on
        rts
flip_init
        lda #0
        sta snap_dirty
        sta snap_hpos
        jmp flip

; A = MEMAC-B value of the list, X = framebuffer number
init_list
gi_18   sta VBX+VB_MEMB
        txa
        clc
        adc #V_FB0 >> 16
        sta il_dh
        ldx #0
il_t    lda slot_lo,x
        sta ZP
        lda slot_hi,x
        sta ZP+1
        ldy #20
        cpx #SPR0
        bcs il_s
        cpx #BG0
        bcs il_b
il_t1   lda tile_bcb,y
        sta (ZP),y
        dey
        bpl il_t1
        jmp il_n
il_b    lda bg_bcb,y
        sta (ZP),y
        dey
        bpl il_b
        jmp il_n
il_s    lda spr_bcb,y
        sta (ZP),y
        dey
        bpl il_s
        ldy #8
        lda il_dh
        sta (ZP),y
il_n    inx
        cpx #SPR0+MAXS
        bne il_t
        ldy #20                 ; the last sprite slot ends the list
        lda #1
        sta (ZP),y
        rts
il_dh   dta 0

clear_list
        dta 0,0,0, 0,0, 0, <V_NT_A,>(V_NT_A&$FFFF),V_NT_A>>16, 0,1, 1, 255,0, 239, 0,$20, 0,0,0, 8
        dta 0,0,0, 0,0, 0, <V_NT_B,>(V_NT_B&$FFFF),V_NT_B>>16, 0,1, 1, 255,0, 239, 0,$20, 0,0,0, 8
        dta 0,0,0, 0,0, 0, <V_FB0,>(V_FB0&$FFFF),V_FB0>>16, 0,1, 1, 255,0, 239, 0,$20, 0,0,0, 8
        dta 0,0,0, 0,0, 0, <V_FB1,>(V_FB1&$FFFF),V_FB1>>16, 0,1, 1, 255,0, 239, 0,$20, 0,0,0, 0
tile_bcb
        dta 0,0,0, 8,0, 1, 0,0,0, 0,1, 1, 7,0, 7, $FF,$20, 0,0,0, 8
bg_bcb  dta <V_SCRATCH,>(V_SCRATCH&$FFFF),V_SCRATCH>>16, 0,1, 1
        dta <V_SCRATCH,>(V_SCRATCH&$FFFF),V_SCRATCH>>16, 0,1, 1, 0,0, 0, $FF,0, 0,0,0, 8
spr_bcb dta 0,>(V_SLOT_OBJ&$FFFF),V_SLOT_OBJ>>16, 8,0, 1, 0,1,0, 0,1, 1, 7,0, 7, 0,0, 0,0,0, 9

; XDL: 240 lines of 256-pixel 8-bit overlay, palette 1, player 0 above it
xdl0    dta $62,$88, 239, <V_FB0,>(V_FB0&$FFFF),V_FB0>>16, 0,1, $10,$FE
xdl_len = * - xdl0
xdl1    dta $62,$88, 239, <V_FB1,>(V_FB1&$FFFF),V_FB1>>16, 0,1, $10,$FE

; BCB slot addresses in the list window
NSLOTS = MAXT + NBG + MAXS
slot_lo :NSLOTS dta <(LISTCPU + # * 21)
slot_hi :NSLOTS dta >(LISTCPU + # * 21)

        .print 'code end: ', *
        ert * > NT_A

; ---- tables above the relocated block and the expansion flags
        org $3A80
        icl '../gen/tables.asm'
        .print 'tables end: ', *
        ert * > $4000

; ---- game-side services: main RAM under the MEMAC-B window, which the
; VBI switches off before returning (nothing here runs inside the VBI)
        org $4000
        icl 'ppu.asm'
        icl 'sound.asm'
        .print 'services end: ', *
        ert * > $8000

; ---- the relocated bank-7 block
        org RELOC
        ins '../gen/reloc.bin'
        .print 'reloc end: ', *
        ert * > $4000
