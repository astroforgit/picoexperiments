; ------------------------------------------------------------------
; VBXE detection, VRAM uploads and the blitter command list.
; All register accesses go through (vb),y so either base page works.
; ------------------------------------------------------------------

; C=1 and vb set when a VBXE FX core is present at $d600 or $d700.
detect_vbxe
        lda #0
        sta vb
        lda #$d6
        sta vb+1
        ldy #VB_VCTL
        lda (vb),y
        cmp #$10
        beq dv_ok
        lda #$d7
        sta vb+1
        lda (vb),y
        cmp #$10
        beq dv_ok
        clc
        rts
dv_ok   sec
        rts

; select 4K VRAM bank A (0..127) in the $9000 window
set_bank
        ora #$80
        ldy #VB_BANK
        sta (vb),y
        rts

memac_on
        lda #$98            ; window at $9000, 4K, CPU access
        ldy #VB_MEMC
        sta (vb),y
        rts

; ---------------------------------------------------------- staging
basic_off
        lda PORTB
        ora #2
        sta PORTB
        lda #0
        sta SDMCTL
        rts

; Expand the 4-bit sprite sheet at $a000 to VRAM $20000 (8 bpp), then
; three copies of the top sprite row with hair colour 8 replaced by
; 7, 11 and 12 at $24000, $24400, $24800.
stage_gfx
        jsr basic_off
        jsr detect_vbxe
        bcc stg_done
        jsr memac_on
        mwa #$a000 ptr
        mwa #$2000 up_len
        lda #$20
        sta up_bank
        lda #8
        sta up_recol
        jsr unpack4
        ldx #0
stg_var  stx tmp+7
        mwa #$a000 ptr
        mwa #512 up_len
        lda stg_bank,x
        sta up_bank
        lda stg_col,x
        sta up_recol
        jsr unpack4
        ldx tmp+7
        inx
        cpx #3
        bne stg_var
        jsr memac_off
stg_done rts
stg_bank dta $24,$24,$24
stg_col  dta 7,11,12
stg_off  dta 0,4,8

memac_off
        lda #0
        ldy #VB_BANK
        sta (vb),y
        rts

up_len  dta a(0)
up_bank dta 0
up_recol dta 8
up_dst  dta a(0)

; unpack up_len packed bytes from (ptr) to VRAM bank up_bank:$000
; (hair variants start at an offset: see stage_gfx / stg_off)
unpack4
        lda up_bank
        jsr set_bank
        lda #<MEMW
        sta ptr2
        lda #>MEMW
        sta ptr2+1
        ; hair variants: offset inside bank $24
        lda up_recol
        cmp #8
        beq up_loop
        ldx tmp+7
        lda stg_off,x
        clc
        adc ptr2+1
        sta ptr2+1
up_loop ldy #0
        lda (ptr),y
        pha
        and #15
        jsr up_px
        pla
        lsr
        lsr
        lsr
        lsr
        jsr up_px
        inw ptr
        lda up_len
        bne up_l1
        dec up_len+1
up_l1   dec up_len
        lda up_len
        ora up_len+1
        bne up_loop
        rts
up_px   cmp #8
        bne up_px1
        lda up_recol
up_px1  ldy #0
        sta (ptr2),y
        inc ptr2
        bne up_px2
        inc ptr2+1
        lda ptr2+1
        cmp #$a0
        bne up_px2
        lda #$90
        sta ptr2+1
        inc up_bank
        lda up_bank
        jsr set_bank
up_px2  rts

; copy the 8K tile map to VRAM $28000
stage_map
        jsr detect_vbxe
        bcc sm_done
        jsr memac_on
        mwa #$a000 ptr
        lda #$28
        ldx #32
        jsr upload_pages
        jsr memac_off
sm_done rts

; copy font, circles and XDLs (6K) to VRAM $25000
stage_misc
        jsr detect_vbxe
        bcc sx_done
        jsr memac_on
        mwa #$a000 ptr
        lda #$25
        ldx #24
        jsr upload_pages
        jsr memac_off
sx_done rts

; copy X pages from (ptr) to VRAM bank A, offset 0
upload_pages
        sta up_bank
        jsr set_bank
        mwa #MEMW ptr2
upg_pg  ldy #0
upg_b   lda (ptr),y
        sta (ptr2),y
        iny
        bne upg_b
        inc ptr+1
        inc ptr2+1
        lda ptr2+1
        cmp #$a0
        bne upg_nx
        lda #$90
        sta ptr2+1
        inc up_bank
        lda up_bank
        jsr set_bank
upg_nx  dex
        bne upg_pg
        rts

; ---------------------------------------------------------- setup
vbxe_setup
        jsr memac_on
        ; palette 1 (overlay): pico colours 0..15 and opaque black 16
        ldy #VB_PSEL
        lda #1
        sta (vb),y
        ldx #0
vs_pal  txa
        ldy #VB_CSEL
        sta (vb),y
        ldy #VB_CR
        lda pal_r,x
        sta (vb),y
        iny
        lda pal_g,x
        sta (vb),y
        iny
        lda pal_b,x
        sta (vb),y
        inx
        cpx #17
        bne vs_pal
        ; blitter list address $7f000
        ldy #VB_BLAD
        lda #$00
        sta (vb),y
        iny
        lda #$f0
        sta (vb),y
        iny
        lda #$07
        sta (vb),y
        jsr bcb_prefill
        ; clear both framebuffers
        lda #0
        sta back_bank
        jsr bcb_begin
        jsr clear_fb
        lda #1
        sta back_bank
        jsr clear_fb
        jsr bcb_flush
        lda #0
        sta back_bank
        ; show framebuffer 1 (cleared) through XDL at $26400
        ldy #VB_XDL0
        lda #0
        sta (vb),y
        iny
        lda #$64
        sta (vb),y
        iny
        lda #2
        sta (vb),y
        ldy #VB_VCTL
        lda #1              ; XDL enabled
        sta (vb),y
        rts

clear_fb
        lda #K_NONE
        sta tpl_kind
        lda #0
        sta tpl_src
        sta tpl_src+1
        sta tpl_src+2
        sta tpl_ssy
        sta tpl_ssy+1
        sta tpl_ssx
        sta tpl_dst
        sta tpl_dst+1
        lda back_bank
        sta tpl_dst+2
        mwa #256 tpl_dsy
        lda #1
        sta tpl_dsx
        mwa #255 tpl_w
        lda #255
        sta tpl_h
        lda #0
        sta tpl_and
        sta tpl_xor
        sta tpl_ctrl
        jmp bcb_add

; ---------------------------------------------------------- flash palette
; palflash: 10 = normal colours, else colours 1,5,6,7,12,13 show pico c.
apply_flash
        lda palflash
        cmp pf_last
        beq af_done
        sta pf_last
        ldy #VB_PSEL
        lda #1
        sta (vb),y
        ldx #5
af_loop stx snd_t
        lda af_cols,x
        ldy #VB_CSEL
        sta (vb),y
        lda palflash
        cmp #10
        bne af_set
        lda af_cols,x
af_set  tax
        ldy #VB_CR
        lda pal_r,x
        sta (vb),y
        iny
        lda pal_g,x
        sta (vb),y
        iny
        lda pal_b,x
        sta (vb),y
        ldx snd_t
        dex
        bpl af_loop
af_done rts
pf_last dta 10
af_cols dta 1,5,6,7,12,13

; ---------------------------------------------------------- blitter list
; The 21-byte template below is appended to the list at $7f000
; (window $9000). A full list is executed and restarted.
tpl_src  dta 0,0,0
tpl_ssy  dta a(0)
tpl_ssx  dta 1
tpl_dst  dta 0,0,0
tpl_dsy  dta a(256)
tpl_dsx  dta 1
tpl_w    dta a(7)
tpl_h    dta 7
tpl_and  dta $ff
tpl_xor  dta 0
tpl_coll dta 0
tpl_zoom dta 0
tpl_patt dta 0
tpl_ctrl dta 1

blit_wait
        ldy #VB_BLIT
bw_loop lda (vb),y
        bne bw_loop
        rts

bcb_begin
        jsr blit_wait
        lda #$7f
        jsr set_bank
        lda end_valid           ; the previous list's end gets NEXT back
        beq bb_1
        ldy #0
        sty end_valid
        lda (end_ptr),y
        ora #8
        sta (end_ptr),y
bb_1    mwa #MEMW bcbp
        lda #0
        sta bcb_n
        rts
end_valid dta 0

; Append the template.  A slot that held the same kind of command last
; time only needs the fields that kind varies; others are rewritten.
bcb_add
        ldx bcb_n
        lda tpl_kind
        beq ba_full
        cmp slot_kind,x
        bne ba_full
        asl
        tax
        lda ba_fast_tab-2,x
        sta jv
        lda ba_fast_tab-1,x
        sta jv+1
        jmp (jv)
ba_full sta slot_kind,x
        ldy #0
        lda tpl_src+0
        sta (bcbp),y
        ldy #1
        lda tpl_src+1
        sta (bcbp),y
        ldy #2
        lda tpl_src+2
        sta (bcbp),y
        ldy #3
        lda tpl_src+3
        sta (bcbp),y
        ldy #4
        lda tpl_src+4
        sta (bcbp),y
        ldy #5
        lda tpl_src+5
        sta (bcbp),y
        ldy #6
        lda tpl_src+6
        sta (bcbp),y
        ldy #7
        lda tpl_src+7
        sta (bcbp),y
        ldy #8
        lda tpl_src+8
        sta (bcbp),y
        ldy #9
        lda tpl_src+9
        sta (bcbp),y
        ldy #10
        lda tpl_src+10
        sta (bcbp),y
        ldy #12
        lda tpl_src+12
        sta (bcbp),y
        ldy #13
        lda tpl_src+13
        sta (bcbp),y
        ldy #14
        lda tpl_src+14
        sta (bcbp),y
        ldy #15
        lda tpl_src+15
        sta (bcbp),y
        ldy #16
        lda tpl_src+16
        sta (bcbp),y
ba_ctrl ldy #20
        lda tpl_ctrl
        ora #8
        sta (bcbp),y
ba_fctl
        lda bcbp
        clc
        adc #21
        sta bcbp
        bcc ba_nc
        inc bcbp+1
ba_nc   inc bcb_n
        lda bcb_n
        cmp #190
        jcs bcb_flush_keep
        rts
ba_fast_tab
        dta a(ba_k1,ba_k2,ba_k3,ba_k4,ba_k5,ba_k6)
ba_k1   ; K_FILL
        ldy #6
        lda tpl_src+6
        sta (bcbp),y
        ldy #7
        lda tpl_src+7
        sta (bcbp),y
        ldy #8
        lda tpl_src+8
        sta (bcbp),y
        ldy #12
        lda tpl_src+12
        sta (bcbp),y
        ldy #14
        lda tpl_src+14
        sta (bcbp),y
        ldy #16
        lda tpl_src+16
        sta (bcbp),y
        jmp ba_fctl
ba_k2   ; K_SPR
        ldy #0
        lda tpl_src+0
        sta (bcbp),y
        ldy #1
        lda tpl_src+1
        sta (bcbp),y
        ldy #2
        lda tpl_src+2
        sta (bcbp),y
        ldy #3
        lda tpl_src+3
        sta (bcbp),y
        ldy #4
        lda tpl_src+4
        sta (bcbp),y
        ldy #5
        lda tpl_src+5
        sta (bcbp),y
        ldy #6
        lda tpl_src+6
        sta (bcbp),y
        ldy #7
        lda tpl_src+7
        sta (bcbp),y
        ldy #8
        lda tpl_src+8
        sta (bcbp),y
        jmp ba_fctl
ba_k3   ; K_GLYPH
        ldy #0
        lda tpl_src+0
        sta (bcbp),y
        ldy #1
        lda tpl_src+1
        sta (bcbp),y
        ldy #6
        lda tpl_src+6
        sta (bcbp),y
        ldy #7
        lda tpl_src+7
        sta (bcbp),y
        ldy #8
        lda tpl_src+8
        sta (bcbp),y
        ldy #15
        lda tpl_src+15
        sta (bcbp),y
        jmp ba_fctl
ba_k4   ; K_CIRC
        ldy #0
        lda tpl_src+0
        sta (bcbp),y
        ldy #6
        lda tpl_src+6
        sta (bcbp),y
        ldy #7
        lda tpl_src+7
        sta (bcbp),y
        ldy #8
        lda tpl_src+8
        sta (bcbp),y
        ldy #12
        lda tpl_src+12
        sta (bcbp),y
        ldy #14
        lda tpl_src+14
        sta (bcbp),y
        ldy #15
        lda tpl_src+15
        sta (bcbp),y
        jmp ba_fctl
ba_k5   ; K_LAYER
        ldy #1
        lda tpl_src+1
        sta (bcbp),y
        ldy #6
        lda tpl_src+6
        sta (bcbp),y
        ldy #7
        lda tpl_src+7
        sta (bcbp),y
        ldy #8
        lda tpl_src+8
        sta (bcbp),y
        jmp ba_fctl
ba_k6   ; K_BAKE
        ldy #0
        lda tpl_src+0
        sta (bcbp),y
        ldy #1
        lda tpl_src+1
        sta (bcbp),y
        ldy #6
        lda tpl_src+6
        sta (bcbp),y
        ldy #7
        lda tpl_src+7
        sta (bcbp),y
        ldy #12
        lda tpl_src+12
        sta (bcbp),y
        jmp ba_fctl

; Every list slot keeps dest step x = 1 and no collision, zoom or
; pattern, so bcb_add never writes those bytes.
bcb_prefill
        lda #$7f
        jsr set_bank
        mwa #MEMW ptr2
        ldx #195
bp_loop ldy #11
        lda #1
        sta (ptr2),y
        lda #0
        ldy #17
        sta (ptr2),y
        iny
        sta (ptr2),y
        iny
        sta (ptr2),y
        lda ptr2
        clc
        adc #21
        sta ptr2
        bcc bp_nc
        inc ptr2+1
bp_nc   dex
        bne bp_loop
        ldx #189
        lda #K_NONE
bp_kind sta slot_kind,x
        dex
        bpl bp_kind
        rts

; start the list without waiting for it
bcb_kick
        jmp bcb_start

; run the list and wait for it; the list restarts empty
bcb_flush_keep
bcb_flush
        jsr bcb_start
        jmp bcb_begin
bcb_start
        lda bcb_n
        beq bf_empty
        ; clear NEXT on the last command (bcb_begin sets it again)
        lda bcbp
        sec
        sbc #1
        sta end_ptr
        lda bcbp+1
        sbc #0
        sta end_ptr+1
        ldy #0
        lda (end_ptr),y
        and #$f7
        sta (end_ptr),y
        lda #1
        sta end_valid
        ldy #VB_BLIT
        lda #1
        sta (vb),y
bf_empty
        rts
