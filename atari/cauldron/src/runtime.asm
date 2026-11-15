; ------------------------------------------------------------------
; Cauldron for Atari XL/XE + VBXE: runtime that runs the original C64
; program. Code A ($0200-$0DFF) is always visible: the stubs and hooks the
; patched game calls, the NMI and IRQ entries, and the runner of the
; game's raster/collision IRQ handlers. Bank R (bank.asm, 8K of VRAM at
; $E000 through MEMAC-A) holds the renderer and the sound driver.
;
; Timing: the vertical blank NMI counts C64 frames (ticks) and wakes the
; IRQ with a one-pixel blit when nothing else is running. The IRQ (the
; VBXE blitter's end-of-list interrupt) runs a C64 frame for each tick -
; the game's IRQ handlers in raster order - then composes the next picture
; and starts its blitter runs; each run's end is another IRQ. Running the
; game's handlers from a real IRQ keeps the game's SEI/CLI sections.
; ------------------------------------------------------------------
        icl 'defs.asm'
        icl '../gen/entry.asm'          ; ENTRY_PC, ENTRY_SP
RMIN    = 2                     ; a picture every 2 frames at most
MAIN_VC = 56                    ; the game's main loop needs about this much
                                ; time per frame (VCOUNT units = 2 lines, about
                                ; 13.4K cycles: what it gets on a C64); a new
                                ; picture starts only when it got its share

; ---- variables --------------------------------------------------
        org $DC10
vb_page   .ds 1         ; $D6 or $D7
ntsc      .ds 1
tick_ph   .ds 1
ticks     .ds 1         ; C64 frames to run
irq_busy  .ds 1
kick_on   .ds 1         ; a wake-up blit is running
chain_on  .ds 1         ; a picture's blitter runs are in progress
in_c64    .ds 1         ; running a game IRQ handler (raster reads: cur_*)
cur_lo    .ds 1         ; its raster line
cur_hi    .ds 1         ; ($80 when >= 256)
prev_lo   .ds 1
prev_hi   .ds 1
frame_par .ds 1
stub_x    .ds 1         ; main context stub scratch
stub_t    .ds 1
ss_latch  .ds 1         ; $D01E
sb_latch  .ds 1         ; $D01F
ss_new    .ds 1         ; sprite-sprite collisions of the last picture
nsbg      .ds 1         ; sprite-background collisions: groups by line
sbg_bits  .ds 8
sbg_lo    .ds 8
sbg_hi    .ds 8
c64_irq   .ds 2         ; the game's IRQ and NMI vectors (its $FFFE/$FFFA)
c64_nmi   .ds 2
mema_cur  .ds 1         ; MEMAC-A bank select as the running code expects
nlog      .ds 1         ; IRQ log entries this frame
shift_n   .ds 1         ; coarse scroll steps since the last picture (+ = left)
band_row  .ds 1
ready     .ds 1         ; framebuffer composed, waiting for the NMI ($FF none)
shown     .ds 1         ; framebuffer on screen
pal_dirty .ds 1
snd_on    .ds 1
irq_lost  .ds 1
vbot      .ds 1         ; $80: a C64 frame ended (raster bit 8 for the main context)
since_r   .ds 1         ; vertical blanks since the last picture began
log_on    .ds 1         ; this C64 frame is logged for a picture
debt      .ds 2         ; main loop time owed (VCOUNT units, signed)
irq_vc    .ds 1         ; time at the IRQ's entry (see now)
irq_vbi   .ds 2
vbi_cnt   .ds 1
vc_frame  .ds 1         ; VCOUNT units per frame (156 PAL, 131 NTSC)
vc_owe    .ds 1         ; MAIN_VC - vc_frame (as a negative byte)
edge      .ds 25        ; columns scrolled into each row (bit 7: on the left)
rowoff    .ds 25        ; the renderer's shadow ring offset of each row
; palettes of the picture to show (written by the renderer, set by the NMI)
pal_new   .ds 3*14      ; per palette: $D020-$D026 colours, $D027-$D02E
pal_cur   .ds 3*14
        .print 'vars DC: ', *
        ert * > $DD00

        org $DD10
site_hit  .ds 97        ; screen writer sites that ran (NSITE)
rowd      .ds 25        ; rows to compare with the shadow
cs_dirty  .ds 64        ; charset $7000-$7FFF: chars rewritten (bitmap)
cs_any    .ds 1
bcb       .ds 21        ; the renderer's band shift BCB
        .print 'vars DD: ', *
        ert * > $DE00

        org $DE40
vline     .ds 156       ; VCOUNT -> C64 raster line / 2
pat_nop   .ds 16        ; the renderer's sprite patch slots that are NOPs
        .print 'vars DE: ', *
        ert * > $DF00

        org $DF20
LOG       .ds 4*49      ; the renderer's IRQ log: line lo, hi, VIC $00-$2E
        .print 'vars DF: ', *
        ert * > $E000

; ---- code A -----------------------------------------------------
        org $0200
; RT_BOOT: entered from the XEX starter with the OS off, A = VBXE page.
rt_boot sei
        cld
        ldx #$FF
        txs
        sta ZP+5                ; VBXE page (operands relocated by the loader)
        lda #$E9                ; MEMAC-A: 8K at $E000, CPU access
vm_c    sta VBX+VB_MEMC
        lda #0
        jsr mema_set
        ; the RAM image: pages $0F-$FF from VRAM staging (not the I/O)
        ldx #$0F
rb_pg   cpx #$D0
        bcc rb_cp
        cpx #$D8
        bcc rb_nx
rb_cp   jsr stage_page
rb_nx   inx
        bne rb_pg
        lda ZP+5
        sta vb_page
        ; page 0 (before the set-up: its framebuffer clear overwrites the
        ; staging area; the set-up only uses the runtime's own zero page)
        lda #MEMB_ON|(V_STAGE>>14)
vm_b0   sta VBX+VB_MEMB
        ldx #0
rb_z    lda WIN,x
        sta $0000,x
        inx
        bne rb_z
        lda #0
vm_b1   sta VBX+VB_MEMB
        lda #BK_I
        jsr mema_set
        jsr bank_init
        lda #BK_R
        jsr mema_set
        jsr r_init
        lda #BK_N
        jsr mema_set
        jsr n_init
        lda #0
        jsr mema_set

; the game, from its entry point
rt_enter
        lda #<nmi
        sta $FFFA
        lda #>nmi
        sta $FFFB
        lda #<irq
        sta $FFFE
        lda #>irq
        sta $FFFF
        lda #1
vi_c    sta VBX+VB_IRQC         ; blitter IRQ on
        lda #$40
        sta NMIEN
        ldx #ENTRY_SP
        txs
        lda #$24
        pha
        lda #0
        tax
        tay
        plp
        jmp ENTRY_PC

; RAM image page X (VRAM V_STAGE + X*256) into place, through the buffer
; page $0E00 (the destination may be under the MEMAC-B window); X kept
stage_page
        txa
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        ora #MEMB_ON|(V_STAGE>>14)
vm_b2   sta VBX+VB_MEMB
        txa
        and #$3F
        ora #>WIN
        sta sp_s+2
        stx sp_d+2
        ldy #0
sp_s    lda WIN,y
        sta $0E00,y
        iny
        bne sp_s
        lda #0
vm_b3   sta VBX+VB_MEMB
sp_c    lda $0E00,y
sp_d    sta $FF00,y
        iny
        bne sp_c
        rts

; time: A = VCOUNT units since the last vertical blank, X = blanks so far
now     ldx vbi_cnt
        lda VCOUNT
        sec
        sbc #124                ; (the vertical blank NMI is at line 248)
        bcs nw_1
        adc vc_frame
nw_1    cpx vbi_cnt             ; (a blank in between: again)
        bne now
        rts

; MEMAC-A bank select (0 = off)
mema_set
        sta mema_cur
vm_s    sta VBX+VB_MEMS
        rts

; ------------------------------------------------------------------
; read/write stubs called by the patched game (A, X, Y kept as the
; instruction would; N/Z from the value, C/V kept)
; ------------------------------------------------------------------
rd_d012 php
        lda in_c64
        bne r12_i
        stx stub_x
        ldx VCOUNT
        lda vline,x
        asl
        ora frame_par
        ldx stub_x
        plp
        and #$FF
        rts
r12_i   lda cur_lo
        plp
        and #$FF
        rts

; main context: bit 7 (line >= 256) is set once after each C64 frame (the
; game waits for it to sync with the bottom of the screen; the IRQ may use
; the whole vertical blank, so the beam itself is no use)
rd_d011 php
        lda in_c64
        bne r11_i
        sei
        lda vbot
        sta stub_t
        lda #0
        sta vbot
        lda VIC+$11
        and #$7F
        ora stub_t
        plp
        and #$FF
        rts
r11_i   lda VIC+$11
        and #$7F
        ora cur_hi
        plp
        and #$FF
        rts

rd_d01e php
        sei
        lda ss_latch
        pha
        lda #0
        sta ss_latch
        pla
        plp
        and #$FF
        rts

rd_d01f php
        sei
        lda sb_latch
        pha
        lda #0
        sta sb_latch
        pla
        plp
        and #$FF
        rts

wr_d019 php
        sei
        pha
        eor #$FF
        and VIC+$19
        sta VIC+$19
        pla
        plp
        rts

rd_rand php
        lda RANDOM
        plp
        and #$FF
        rts

; C64 joystick port 2: bits 0-3 up/down/left/right, 4 fire (0 = pressed)
rd_joy  php
        lda TRIG0
        lsr
        lda PORTA
        and #$0F
        ora #$E0
        bcc rj_1
        ora #$10
rj_1    plp
        and #$FF
        rts

; ------------------------------------------------------------------
; screen and charset writes (hooks.asm trampolines)
; mark_addr: A = high, X = low byte of a store's address. Marks its row
; (screen or colour RAM) or its character (charset). Uses A, X, flags.
; ------------------------------------------------------------------
mark_addr
        cmp #$40
        bcc ma_x
        cmp #$44
        bcc ma_scr
        cmp #$70
        bcc ma_x
        cmp #$80
        bcc ma_cs
        cmp #$D8
        bcc ma_x
        cmp #$DC
        bcs ma_x
ma_scr  and #3                  ; offset/8 = (hi&3)*32 + lo/8
        asl
        asl
        asl
        asl
        asl
        pha
        txa
        lsr
        lsr
        lsr
        tsx
        ora $0101,x
        tax
        pla
        lda row8,x              ; (offsets past the screen give 25)
        tax
        lda #1
        sta rowd,x
ma_x    rts
ma_cs   php                     ; bitmap byte = (hi&$0F)*4 + lo/64,
        sei                     ; bit = (lo/8)&7
        and #$0F
        asl
        asl
        pha
        txa
        pha                     ; lo
        rol
        rol
        rol
        and #3
        tsx
        ora $0102,x             ; byte index
        sta stub_t
        pla
        lsr
        lsr
        lsr
        and #7
        tax
        lda bitv,x
        ldx stub_t
        ora cs_dirty,x
        sta cs_dirty,x
        lda #1
        sta cs_any
        pla
        plp
        rts

bitv    dta $01,$02,$04,$08,$10,$20,$40,$80
row8    :125 dta #/5            ; screen offset/8 -> row
        :3 dta 25

; coarse scroll calls of the game (left: content moves left); a change of
; direction since the last picture makes the band rows compare in full
hk_left php                     ; (no picture between the game's scroll
        sei                     ; and its count: the main context calls it too)
        jsr $A6A3
        pha
        lda shift_n
        bpl hl_1
        jsr hk_mix
hl_1    inc shift_n
        jmp hk_band
hk_right
        php
        sei
        jsr $A84F
        pha
        lda shift_n
        beq hr_1
        bmi hr_1
        jsr hk_mix
hr_1    dec shift_n
hk_band txa
        pha
        lda $BC                 ; band: the row of the pointer at $BB
        sec
        sbc #$40
        tax
        lda $BB
        lsr
        lsr
        lsr
        ora rtab_hi,x
        tax
        lda row8,x
        sta band_row
        pla
        tax
        pla
        plp
        rts
hk_mix  txa
        pha
        tya
        pha
        ldx band_row
        ldy #7
        lda #1
hm_l    sta rowd,x
        inx
        dey
        bne hm_l
        pla
        tay
        pla
        tax
        rts
rtab_hi dta $00,$20,$40,$60

        icl '../gen/hooks.asm'

; ------------------------------------------------------------------
; NMI: vertical blank
; ------------------------------------------------------------------
nmi     pha
        txa
        pha
        tya
        pha
        sta NMIRES
        inc vbi_cnt
        cld
        lda mema_cur
        pha
        lda #BK_N
        jsr mema_set
        jsr nmi_work            ; bank N: picture flip, palettes, sound
        pla
        jsr mema_set
nm_nt   lda irq_busy
        ora chain_on
        ora kick_on
        bne nm_x
        inc kick_on             ; wake the IRQ: a one-pixel blit
        lda #<V_DUMMY
vn_0    sta VBX+VB_BLAD
        lda #>V_DUMMY
vn_1    sta VBX+VB_BLAD+1
        lda #^V_DUMMY
vn_2    sta VBX+VB_BLAD+2
        lda #1
vn_3    sta VBX+VB_BLIT
nm_x    pla
        tay
        pla
        tax
        pla
        rti

; ------------------------------------------------------------------
; IRQ: the blitter finished a list
; ------------------------------------------------------------------
irq     pha
        txa
        pha
        tya
        pha
        cld
        lda #1
vq_0    sta VBX+VB_IRQC         ; acknowledge
        lda irq_busy
        beq iq_go
        inc irq_lost            ; a run ended inside a game handler (CLI):
        jmp iq_x                ; the outer IRQ starts the next run
iq_go   inc irq_busy
        jsr now                 ; (time in the IRQ is not the game's main loop)
        sta irq_vc
        stx irq_vbi
        lda #0
        sta kick_on
        lda chain_on            ; (a wake-up blit runs only without a chain)
        beq iq_t
        jsr do_step             ; a run of the chain ended
iq_t    lda ticks               ; C64 frames (also while the chain runs)
        beq iq_r
        dec ticks
        jsr c64_frame
        lda irq_lost
        beq iq_t
        dec irq_lost
        jsr do_step
        jmp iq_t
iq_r    lda chain_on            ; a new picture when the blitter is free, the
        bne iq_d                ; last one is on screen and the game had its
        lda ready               ; share of the time since the last one
        bpl iq_d
        lda debt+1
        bpl iq_d                ; (debt >= 0)
        lda since_r
        cmp #RMIN
        bcc iq_d
        lda nlog                ; (the last frame was logged)
        beq iq_d
        lda #0
        sta since_r
        lda #BK_R
        jsr mema_set
        jsr render              ; (starts the chain)
        lda #0
        jsr mema_set
iq_d    lda ticks               ; (a vertical blank came meanwhile)
        bne iq_t
        jsr now                 ; debt += time spent here: frames * vc_frame
        sec                     ; + phase - phase at the entry
        sbc irq_vc
        sta irq_vc
        lda #0
        sbc #0
        sta irq_vbi+1           ; (hi of the phase difference)
        txa
        sec
        sbc irq_vbi
        tax
        beq iq_v2
iq_v1   lda irq_vc
        clc
        adc vc_frame
        sta irq_vc
        bcc iq_v0
        inc irq_vbi+1
iq_v0   dex
        bne iq_v1
iq_v2   lda irq_vc
        clc
        adc debt
        sta debt
        lda irq_vbi+1
        adc debt+1
        sta debt+1
        dec irq_busy
iq_x    pla
        tay
        pla
        tax
        pla
        rti

do_step lda #BK_R
        jsr mema_set
        jsr chain_step
        lda #0
        jmp mema_set

; ------------------------------------------------------------------
; one C64 frame: the collision IRQs of the last picture, then the raster
; IRQ handlers in raster order (each one sets the next line). The VIC
; state after each handler goes to the log the renderer reads.
; ------------------------------------------------------------------
c64_frame
        lda #1
        sta in_c64
        lda #0
        sta nlog
        sta cur_lo
        sta cur_hi
        sta log_on              ; logged only when a picture can follow
        lda ticks               ; (another frame runs first)
        bne cf_nl
        lda ready
        bpl cf_nl
        lda debt+1
        bpl cf_nl
        lda since_r
        cmp #RMIN
        bcc cf_nl
        inc log_on
cf_nl   jsr log_vic             ; entry 0: the state at the top of the frame
        ; sprite-sprite collisions
        lda ss_new
        beq cf_sb
        ldx ss_latch
        ora ss_latch
        sta ss_latch
        lda #0
        sta ss_new
        cpx #0
        bne cf_sb
        lda VIC+$1A
        and #4
        beq cf_sb
        sta VIC+$19
        jsr call_irq
cf_sb   ldx #0
cf_sl   cpx nsbg
        bcs cf_sd
        stx cf_i
        lda sbg_lo,x
        sta cur_lo
        lda sbg_hi,x
        sta cur_hi
        ldy sb_latch
        lda sbg_bits,x
        ora sb_latch
        sta sb_latch
        cpy #0
        bne cf_sn
        lda VIC+$1A
        and #2
        beq cf_sn
        sta VIC+$19
        jsr call_irq
cf_sn   ldx cf_i
        inx
        bne cf_sl
cf_sd   lda #0
        sta nsbg
        ; raster handlers
        lda #8
        sta cf_n
        lda #$FF
        sta prev_hi
cf_r    lda VIC+$1A
        and #1
        beq cf_x
        lda VIC+$11
        and #$80
        sta cur_hi
        lda VIC+$12
        sta cur_lo
        lda cur_hi
        beq cf_1
        lda cur_lo
        cmp #<312
        bcs cf_x
cf_1    lda prev_hi
        bmi cf_go               ; first handler
        lda cur_hi
        cmp prev_hi
        bcc cf_x
        bne cf_go
        lda cur_lo
        cmp prev_lo
        bcc cf_x
        beq cf_x
cf_go   lda cur_lo
        sta prev_lo
        lda cur_hi
        sta prev_hi
        lda #$81
        sta VIC+$19
        jsr call_irq
        jsr log_vic
        dec cf_n                ; (at most 8 handlers: a safety stop)
        bne cf_r
cf_x    lda #0
        sta in_c64
        lda #$80
        sta vbot
        rts
cf_i    dta 0
cf_n    dta 0

; the game's IRQ handler, as an interrupt (its RTI returns here)
call_irq
        lda #>ci_ret
        pha
        lda #<ci_ret
        pha
        php
        jmp (c64_irq)
ci_ret  rts

; VIC shadow and the current line into log entry nlog (bank R)
log_vic lda log_on
        beq lv_x
        lda #BK_R
        jsr mema_set
        jsr log_put
        lda #0
        jmp mema_set
lv_x    rts

        .print 'code A: ', *
        ert * > $0D38                   ; ($0D38-$0DFF: the renderer's cell list)

; ---- bank R -----------------------------------------------------
        icl 'bank.asm'
        org $FFFA                       ; (a bank is mapped over the vectors)
        dta a(nmi), a(rt_boot), a(irq)
        icl 'nbank.asm'
        icl 'ibank.asm'
