; ------------------------------------------------------------------
; VBXE detection, load-time staging, palette and the blitter lists.
; Register accesses go through (vb),y so either base page works; the
; palette writer is patched to the detected page.
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

; Expand the 4-bit sprite sheet at $a000 into three 8-bit copies (normal,
; captain and fire-spitter colours) at VRAM $10000, $14000, $18000.
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
        cmp #3
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
; PICO-8 colour -> stored byte: 3 is transparent (0), 0 is stored as 3
sheet_maps
        dta $f3,$f1,$f2,$00,$f4,$f5,$f6,$f7,$f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff
        ; captain: pal(i, mp[i]) applied
        dta $f3,$f1,$f1,$00,$f5,$f4,$f9,$f7,$fc,$f6,$fa,$fb,$fc,$fd,$fe,$ff
        ; fire spitter
        dta $f3,$f1,$f2,$00,$f2,$f5,$f6,$f7,$f8,$f8,$fe,$fb,$fc,$fd,$fe,$ff

; font masks, outlined font area and XDLs (8K) to VRAM $0c000

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

; a VRAM image piece: stage_arg = 4K bank, page in the bank, pages
stage_vr
        jsr detect_vbxe
        bcc svr_d
        jsr memac_on
        mwa #$a000 ptr
        lda stage_arg
        sta up_bank
        jsr set_bank
        lda stage_arg+1
        clc
        adc #>MEMW
        sta ptr2+1
        lda #0
        sta ptr2
        ldx stage_arg+2
svr_pg  ldy #0
svr_b   lda (ptr),y
        sta (ptr2),y
        iny
        bne svr_b
        inc ptr+1
        inc ptr2+1
        lda ptr2+1
        cmp #$a0
        bne svr_n
        lda #$90
        sta ptr2+1
        inc up_bank
        lda up_bank
        jsr set_bank
svr_n   dex
        bne svr_pg
        jsr memac_off
svr_d   rts
stage_arg dta 0,0,0

; tables, sound effects and music to the RAM under the OS ROM: the
; staging area $a000.. is copied to HI_START.. with the ROM switched off
stage_hi
        sei
        lda NMIEN
        pha
        lda #0
        sta NMIEN
        lda PORTB
        pha
        and #$fe
        sta PORTB
        mwa #$a000 ptr
        mwa #HI_START ptr2
        ldy #0
sh_l    lda (ptr),y
        sta (ptr2),y
        inw ptr
        inw ptr2
        lda ptr
        cmp #<($a000+HI_LEN)
        lda ptr+1
        sbc #>($a000+HI_LEN)
        bcc sh_l
        pla
        sta PORTB
        pla
        sta NMIEN
        cli
        rts

; ---------------------------------------------------------- setup
vbxe_setup
        jsr memac_on
        ; patch the palette writer to the register page
        lda vb+1
        sta apr_r+2
        sta apr_g+2
        sta apr_b+2
        lda #1
        sta pal_req
        jsr apply_palette
        jsr bcb_prefill
        lda #$0e
        sta bcb_bank
        ; clear the framebuffers
        jsr bcb_begin
        lda #0
        sta back_bank
        jsr cls_raw
        lda #1
        sta back_bank
        jsr cls_raw
        lda #2
        sta back_bank
        jsr cls_raw
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
; Overlay palette 1: entry (k<<4)|n shows PICO colour bank_pico[k][n]
; through the screen palette effect spal_t (a bank table, 0 = none).
apply_palette
        lda #0
        sta pal_req
        lda spal_t
        asl
        asl
        asl
        asl
        sta ap_m+1
        ldy #VB_PSEL
        lda #1
        sta (vb),y
        ldy #VB_CSEL
        lda #0
        sta (vb),y
        ldx #0
ap_l    ldy idx_pico,x
ap_m    lda scr_pico,y          ; low byte patched: screen map of spal_t
        tay
        lda pal_r,y
apr_r   sta $d646
        lda pal_g,y
apr_g   sta $d647
        lda pal_b,y
apr_b   sta $d648
        inx
        bne ap_l
        rts

; ---------------------------------------------------------- blitter lists
; Two lists ($0e000 and $0f000, 195 commands each) alternate.  A full
; list is started and the next one is built in the other buffer while
; the blitter runs.  bcb_kind remembers what each slot held, so the
; fields that stay the same are not written again.
BCBMAX  = 195
K_NONE  = 0
K_FB    = 1                 ; framebuffer destination (dst steps 128/1)
K_PSET  = 2                 ; 1x1 fill into a framebuffer
K_ROW   = 3                 ; a 128 pixel row into a framebuffer
K_REFL  = 4                 ; a reflection row

blit_wait
        ldy #VB_BLIT
bw_loop lda (vb),y
        bne bw_loop
        rts

bcb_begin
        lda bcb_bank
        eor #1
        sta bcb_bank
        jsr set_bank
        mwa #MEMW bcbp
        lda #0
        sta bcb_n
        lda bcb_bank
        and #1
        tax
        lda kind_lo,x
        sta bk_ptr
        lda kind_hi,x
        sta bk_ptr+1
        rts
kind_lo dta <bcb_kind,<(bcb_kind+BCBMAX)
kind_hi dta >bcb_kind,>(bcb_kind+BCBMAX)

; after writing a command: advance; a full list is started
bcb_next
        lda bcbp
        clc
        adc #21
        sta bcbp
        bcc bn_1
        inc bcbp+1
bn_1    inc bcb_n
        lda bcb_n
        cmp #BCBMAX
        bcs bn_full
        rts
bn_full jsr bcb_start
        jmp bcb_begin

; start the list without waiting for it
bcb_kick
        jmp bcb_start

; run the list and wait for it
bcb_flush
        jsr bcb_start
        jsr blit_wait
        jmp bcb_begin
bcb_bank dta $0e
bcb_start
        lda bcb_n
        beq bf_empty
        jsr blit_wait           ; the previous list must be finished
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
        lda #0
        sta bcb_n
bf_empty
        rts

; fill both lists with a neutral command
bcb_prefill
        lda #$0e
        jsr bp_bank
        lda #$0f
bp_bank jsr set_bank
        mwa #MEMW ptr2
        ldx #BCBMAX
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
        ldx #0
        lda #K_NONE
bp_k    sta bcb_kind,x
        sta bcb_kind+BCBMAX,x
        inx
        cpx #BCBMAX
        bne bp_k
        rts

; a raw command from bcb_img (any destination)
bcb_raw ldy bcb_n
        lda #K_NONE
        sta (bk_ptr),y
        ldy #20
br_l    lda bcb_img,y
        sta (bcbp),y
        dey
        bpl br_l
        jmp bcb_next

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

; a 1x1 fill: destination bi_dst, colour A
bcb_pset
        sta bi_xor
        ldy bcb_n
        lda (bk_ptr),y
        cmp #K_PSET
        beq bps_k
        lda #K_PSET
        sta (bk_ptr),y
        ldy #20
bps_i   lda pset_img,y
        sta (bcbp),y
        dey
        bpl bps_i
bps_k   ldy #6
        lda bi_dst
        sta (bcbp),y
        iny
        lda bi_dst+1
        sta (bcbp),y
        iny
        lda bi_dst+2
        sta (bcbp),y
        ldy #16
        lda bi_xor
        sta (bcbp),y
        ldy #20
        lda #8
        sta (bcbp),y
        jmp bcb_next
pset_img
        dta 0,0,0, 0,0, 0, 0,0,0, 128,0, 1, 0,0, 0, 0, 0, 0,0,0, 8
