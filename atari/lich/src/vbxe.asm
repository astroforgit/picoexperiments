; ------------------------------------------------------------------
; VBXE detection, VRAM uploads, palette and the blitter command list.
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

memac_off
        lda #0
        ldy #VB_BANK
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

; Expand the 4-bit sprite sheet at $a000 into four 8-bit copies, one per
; palette (raw, lit, dark, flash) at VRAM $10000, $14000, $18000, $1c000.
stage_gfx
        jsr basic_off
        jsr detect_vbxe
        bcc stg_done
        jsr memac_on
        lda #0
        sta stg_v
stg_var mwa #$a000 ptr
        lda stg_v
        asl
        asl
        adc #$10
        sta up_bank
        lda stg_v
        asl
        asl
        asl
        asl
        sta stg_map
        jsr unpack4
        inc stg_v
        lda stg_v
        cmp #4
        bne stg_var
        jsr memac_off
stg_done rts
stg_v   dta 0
stg_map dta 0
up_bank dta 0

; unpack 8K packed bytes from (ptr) to VRAM bank up_bank:$000 through
; the colour map sheet_maps+stg_map
unpack4
        lda up_bank
        jsr set_bank
        mwa #MEMW ptr2
        ldx #0              ; 8K = 32 pages
up_loop ldy #0
        lda (ptr),y
        pha
        and #15
        ora stg_map
        tay
        lda sheet_maps,y
        ldy #0
        sta (ptr2),y
        pla
        lsr
        lsr
        lsr
        lsr
        ora stg_map
        tay
        lda sheet_maps,y
        ldy #1
        sta (ptr2),y
        inw ptr
        lda ptr2
        clc
        adc #2
        sta ptr2
        bcc up_l1
        inc ptr2+1
        lda ptr2+1
        cmp #$a0
        bne up_l1
        lda #$90
        sta ptr2+1
        inc up_bank
        lda up_bank
        jsr set_bank
up_l1   lda ptr+1
        cmp #$c0
        bne up_loop
        rts

; copy font masks and XDLs (7K) to VRAM $0c000
stage_misc
        jsr detect_vbxe
        bcc sx_done
        jsr memac_on
        mwa #$a000 ptr
        lda #$0c
        ldx #28
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
        lda #$ff
        sta pal_k_shown
        lda #0
        sta fade_k
        jsr apply_fade
        ; blitter list address $0f000
        ldy #VB_BLAD
        lda #$00
        sta (vb),y
        iny
        lda #$f0
        sta (vb),y
        iny
        lda #$00
        sta (vb),y
        jsr bcb_prefill
        lda #$0e
        sta bcb_bank
        ; clear the framebuffers, the text cache and the map
        jsr bcb_begin
        lda #0
        sta back_bank
        jsr cls
        lda #1
        sta back_bank
        jsr cls
        lda #2
        sta back_bank
        jsr cls
        jsr bcb_flush
        lda #0
        sta back_bank
        ; show framebuffer 1 (cleared) through XDL at $0d400
        ldy #VB_XDL0
        lda #0
        sta (vb),y
        iny
        lda #$d4
        sta (vb),y
        iny
        lda #0
        sta (vb),y
        ldy #VB_VCTL
        lda #1              ; XDL enabled
        sta (vb),y
        rts

; ---------------------------------------------------------- palette
; Overlay palette 1: entries 1..15 show PICO colour fade_tab[k][i]
; (the screen palette of update_fade), entry 16 is an opaque black.
apply_fade
        lda fade_k
        cmp pal_k_shown
        beq af_done
        sta pal_k_shown
        asl
        asl
        asl
        asl
        sta nmi_a
        ldy #VB_PSEL
        lda #1
        sta (vb),y
        ldy #VB_CSEL
        lda #0
        sta (vb),y
        ldx #0
af_loop txa
        ora nmi_a
        stx snd_t+7
        tax
        lda fade_tab,x
        tax
        ldy #VB_CR
        lda pal_r,x
        sta (vb),y
        iny
        lda pal_g,x
        sta (vb),y
        iny
        lda pal_b,x
        sta (vb),y
        ldx snd_t+7
        inx
        cpx #16
        bne af_loop
        ldy #VB_CR          ; entry 16
        lda #0
        sta (vb),y
        iny
        sta (vb),y
        iny
        sta (vb),y
af_done rts

; ---------------------------------------------------------- blitter list
; bcb_img is appended to the list at $0f000 (window $9000).  A full list
; is executed and restarted.
bcb_img
bi_src  dta 0,0,0
bi_ssy  dta a(0)
bi_ssx  dta 1
bi_dst  dta 0,0,0
bi_dsy  dta a(128)
bi_dsx  dta 1
bi_w    dta a(7)
bi_h    dta 7
bi_and  dta $ff
bi_xor  dta 0
bi_coll dta 0
bi_zoom dta 0
bi_patt dta 0
bi_ctrl dta 9

blit_wait
        ldy #VB_BLIT
bw_loop lda (vb),y
        bne bw_loop
        rts

; Two lists ($0e000 and $0f000) alternate, so the next list is built
; while the blitter still runs the previous one.
bcb_begin
        lda bcb_bank
        eor #1
        sta bcb_bank
        jsr set_bank
        mwa #MEMW bcbp
        lda #0
        sta bcb_n
        rts

bcb_add
        ldy #0
        lda bcb_img+0
        sta (bcbp),y
        ldy #1
        lda bcb_img+1
        sta (bcbp),y
        ldy #2
        lda bcb_img+2
        sta (bcbp),y
        ldy #3
        lda bcb_img+3
        sta (bcbp),y
        ldy #4
        lda bcb_img+4
        sta (bcbp),y
        ldy #5
        lda bcb_img+5
        sta (bcbp),y
        ldy #6
        lda bcb_img+6
        sta (bcbp),y
        ldy #7
        lda bcb_img+7
        sta (bcbp),y
        ldy #8
        lda bcb_img+8
        sta (bcbp),y
        ldy #9
        lda bcb_img+9
        sta (bcbp),y
        ldy #10
        lda bcb_img+10
        sta (bcbp),y
        ldy #11
        lda bcb_img+11
        sta (bcbp),y
        ldy #12
        lda bcb_img+12
        sta (bcbp),y
        ldy #13
        lda bcb_img+13
        sta (bcbp),y
        ldy #14
        lda bcb_img+14
        sta (bcbp),y
        ldy #15
        lda bcb_img+15
        sta (bcbp),y
        ldy #16
        lda bcb_img+16
        sta (bcbp),y
        ldy #20
        lda bcb_img+20
        sta (bcbp),y
        lda bcbp
        clc
        adc #21
        sta bcbp
        bcc ba_nc
        inc bcbp+1
ba_nc   inc bcb_n
        lda bcb_n
        cmp #190
        bcs bcb_flush
        rts

bcb_prefill
        lda #$0e
        jsr bp_bank
        lda #$0f
bp_bank jsr set_bank
        mwa #MEMW ptr2
        ldx #195
bp_loop ldy #20
bp_b    lda bcb_img,y
        sta (ptr2),y
        dey
        bpl bp_b
        lda ptr2
        clc
        adc #21
        sta ptr2
        bcc bp_nc
        inc ptr2+1
bp_nc   dex
        bne bp_loop
        rts

; start the list without waiting for it
bcb_kick
        jmp bcb_start

; run the list and wait for it; the list restarts empty
bcb_flush
        jsr bcb_start
        jsr blit_wait
        jmp bcb_begin
bcb_bank dta $0e
bcb_start
        lda bcb_n
        beq bf_empty
        jsr blit_wait           ; the previous list must be finished
        ; list address
        ldy #VB_BLAD
        lda #0
        sta (vb),y
        iny
        lda bcb_bank
        asl
        asl
        asl
        asl
        sta (vb),y
        iny
        lda #0
        sta (vb),y
        ; clear NEXT on the last command
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
        ldy #VB_BLIT
        lda #1
        sta (vb),y
bf_empty
        rts
