; ------------------------------------------------------------------
; Drawing primitives.  Each appends a blitter command that draws into
; the back framebuffer (128x128, stride 128).  Positions are PICO-8
; coordinates (signed 16 bit); the camera is subtracted and the result
; is clipped to cx0..cx1-1, cy0..cy1-1 (the cart's clip()).
;
; Colours: index (bank << 4) | nibble, where the nibble is the PICO-8
; colour and colour 0 is stored as 3 (3 is always transparent in this
; cart).  dbank holds bank << 4: the draw palette set with the cart's
; pal() calls (see gen/tables.asm, bank_*).
; ------------------------------------------------------------------

; step for a shift code: 0 -> 0, n -> 1 << n
step_lo dta 0,2,4,8,16,32,64,128,0,0,0
step_hi dta 0,0,0,0,0,0,0,0,1,2,4

; colour A (PICO-8, through the draw palette) -> VBXE index: bank 15,
; nibble = the final colour
vcol    and #15
        ora dbank
        tax
        lda bank_tab,x
        ora #$f0
        rts

; source += A << bssy (A = 0..255)
src_add_y
        ldx bssy
        beq say_done
        sta tmp+4
        lda #0
        sta tmp+5
        sta tmp+6
say_l   asl tmp+4
        rol tmp+5
        rol tmp+6
        dex
        bne say_l
        lda bsrc
        clc
        adc tmp+4
        sta bsrc
        lda bsrc+1
        adc tmp+5
        sta bsrc+1
        lda bsrc+2
        adc tmp+6
        sta bsrc+2
say_done rts

; clipped blit to the back framebuffer; bx/by in PICO-8 coordinates
blit_cam
        lda bx
        sec
        sbc camx
        sta bx
        lda bx+1
        sbc camx+1
        sta bx+1
        lda by
        sec
        sbc camy
        sta by
        lda by+1
        sbc camy+1
        sta by+1
; clipped blit; bx/by in screen coordinates
blit_fb
        ; ---- left
        lda bx
        sec
        sbc cx0
        sta tmp
        lda bx+1
        sbc #0
        bpl bf_l_ok
        cmp #$ff
        jne bf_out
        lda tmp
        jeq bf_out
        lda #0
        sec
        sbc tmp
        sta tmp             ; d = cx0 - bx (1..255)
        ldx bw+1
        bne bf_l_fit
        cmp bw
        jcs bf_out
bf_l_fit
        lda bw
        sec
        sbc tmp
        sta bw
        lda bw+1
        sbc #0
        sta bw+1
        lda cx0
        sta bx
        lda #0
        sta bx+1
        lda bssx
        beq bf_l_ok
        bmi bf_l_neg
        lda bsrc
        clc
        adc tmp
        sta bsrc
        bcc bf_l_ok
        inc bsrc+1
        bne bf_l_ok
        inc bsrc+2
        jmp bf_l_ok
bf_l_neg
        lda bsrc
        sec
        sbc tmp
        sta bsrc
        bcs bf_l_ok
        lda bsrc+1
        bne bf_l_n1
        dec bsrc+2
bf_l_n1 dec bsrc+1
bf_l_ok
        ; ---- top
        lda by
        sec
        sbc cy0
        sta tmp
        lda by+1
        sbc #0
        bpl bf_t_ok
        cmp #$ff
        jne bf_out
        lda tmp
        jeq bf_out
        lda #0
        sec
        sbc tmp
        sta tmp
        ldx bh+1
        bne bf_t_fit
        cmp bh
        jcs bf_out
bf_t_fit
        lda bh
        sec
        sbc tmp
        sta bh
        lda bh+1
        sbc #0
        sta bh+1
        lda cy0
        sta by
        lda #0
        sta by+1
        lda tmp
        jsr src_add_y
bf_t_ok
        ; ---- right
        lda bx+1
        bne bf_out
        lda bx
        cmp cx1
        bcs bf_out
        lda cx1
        sec
        sbc bx
        ldx bw+1
        bne bf_r_set
        cmp bw
        bcs bf_r_ok
bf_r_set
        sta bw
        lda #0
        sta bw+1
bf_r_ok
        ; ---- bottom
        lda by+1
        bne bf_out
        lda by
        cmp cy1
        bcs bf_out
        lda cy1
        sec
        sbc by
        ldx bh+1
        bne bf_b_set
        cmp bh
        bcs bf_b_ok
bf_b_set
        sta bh
        lda #0
        sta bh+1
bf_b_ok
        lda bw
        ora bw+1
        beq bf_out
        lda bh
        beq bf_out
        ; dst = framebuffer + by*128 + bx
        lda by
        lsr
        sta bi_dst+1
        lda #0
        ror
        ora bx
        sta bi_dst
        ldx back_bank
        lda fb_hi,x
        ora bi_dst+1
        sta bi_dst+1
        lda fb_bk,x
        sta bi_dst+2
        jmp fb_emit
bf_out  rts
; framebuffers: $00000, $04000, $08000, scratch $4d000 (32 rows)
fb_hi   dta $00,$40,$80,$d0,$f0,$e0,$f0
fb_bk   dta 0,0,0,4,4,7,7

; write a framebuffer command straight into the list: source bsrc
; (steps bssx, bssy code), destination bi_dst, size bw x bh, band, bxor,
; bmode.  Constant fields are written only when the slot held another kind.
fb_emit ldy bcb_n
        lda (bk_ptr),y
        cmp #K_FB
        beq fe_k
        lda #K_FB
        sta (bk_ptr),y
        ldy #9
        lda #128
        sta (bcbp),y
        iny
        lda #0
        sta (bcbp),y
        iny
        lda #1
        sta (bcbp),y
        lda #0
        ldy #17
        sta (bcbp),y
        iny
        sta (bcbp),y
        iny
        sta (bcbp),y
fe_k    ldy #0
        lda bsrc
        sta (bcbp),y
        iny
        lda bsrc+1
        sta (bcbp),y
        iny
        lda bsrc+2
        and #7
        sta (bcbp),y
        iny
        ldx bssy
        bmi fe_neg
        lda step_lo,x
        sta (bcbp),y
        iny
        lda step_hi,x
        sta (bcbp),y
        jmp fe_1
fe_neg  lda #$80            ; -128 (vertically flipped sprites)
        sta (bcbp),y
        iny
        lda #$ff
        sta (bcbp),y
fe_1    iny
        lda bssx
        sta (bcbp),y
        iny
        lda bi_dst
        sta (bcbp),y
        iny
        lda bi_dst+1
        sta (bcbp),y
        iny
        lda bi_dst+2
        sta (bcbp),y
        ldy #12
        lda bw
        sec
        sbc #1
        sta (bcbp),y
        iny
        lda bw+1
        sbc #0
        sta (bcbp),y
        iny
        lda bh
        sec
        sbc #1
        sta (bcbp),y
        iny
        lda band
        sta (bcbp),y
        iny
        lda bxor
        sta (bcbp),y
        ldy #20
        lda bmode
        ora #8
        sta (bcbp),y
        jmp bcb_next

; a full-width row (128 pixels) into the framebuffer: source bsrc (bank
; 3 bytes), screen row A (0..127), AND mask band; transparent copy
row_emit
        lsr
        sta bi_dst+1
        lda #0
        ror
        sta bi_dst
        ldx back_bank
        lda fb_hi,x
        ora bi_dst+1
        sta bi_dst+1
        lda fb_bk,x
        sta bi_dst+2
        ldy bcb_n
        lda (bk_ptr),y
        cmp #K_ROW
        beq re_k
        lda #K_ROW
        sta (bk_ptr),y
        ldy #20
re_i    lda row_img,y
        sta (bcbp),y
        dey
        bpl re_i
re_k    ldy #0
        lda bsrc
        sta (bcbp),y
        iny
        lda bsrc+1
        sta (bcbp),y
        iny
        lda bsrc+2
        sta (bcbp),y
        ldy #6
        lda bi_dst
        sta (bcbp),y
        iny
        lda bi_dst+1
        sta (bcbp),y
        iny
        lda bi_dst+2
        sta (bcbp),y
        ldy #15
        lda band
        sta (bcbp),y
        ldy #20
        lda #9
        sta (bcbp),y
        jmp bcb_next
row_img dta 0,0,0, 0,0, 1, 0,0,0, 128,0, 1, 127,0, 0, $ff, 0, 0,0,0, 9

; ---------------------------------------------------------- primitives
; clip(): whole screen
clip_reset
        lda #0
        sta cx0
        sta cy0
        lda #128
        sta cx1
        sta cy1
        rts

; clip(a0, a1, a2, a3): x, y, w, h (signed bytes x/y, clamped)
clip_set
        lda a0
        bpl cs_1
        clc
        adc a2
        sta a2
        lda #0
        sta a0
cs_1    sta cx0
        clc
        adc a2
        bcs cs_2
        cmp #129
        bcc cs_3
cs_2    lda #128
cs_3    sta cx1
        lda a1
        bpl cs_4
        clc
        adc a3
        sta a3
        lda #0
        sta a1
cs_4    sta cy0
        clc
        adc a3
        bcs cs_5
        cmp #129
        bcc cs_6
cs_5    lda #128
cs_6    sta cy1
        rts

; cls(): the back framebuffer is filled with 0 (transparent = black)
cls_raw lda #0
        sta bx
        sta bx+1
        sta by
        sta by+1
        sta bw+1
        sta bh+1
        sta band
        sta bxor
        sta bssx
        sta bssy
        sta bmode
        lda #128
        sta bw
        sta bh
        jsr clip_reset
        jmp blit_fb

; rectfill(rx0, ry0, rx1, ry1, A) in PICO-8 coordinates (signed 16, any order)
rectfill
        jsr vcol
rectfill_i
        sta bxor
        ; order
        lda rx1
        sec
        sbc rx0
        lda rx1+1
        sbc rx0+1
        bpl rf_xo
        ldx rx0
        lda rx1
        sta rx0
        stx rx1
        ldx rx0+1
        lda rx1+1
        sta rx0+1
        stx rx1+1
rf_xo   lda ry1
        sec
        sbc ry0
        lda ry1+1
        sbc ry0+1
        bpl rf_yo
        ldx ry0
        lda ry1
        sta ry0
        stx ry1
        ldx ry0+1
        lda ry1+1
        sta ry0+1
        stx ry1+1
rf_yo   lda rx1
        sec
        sbc rx0
        sta bw
        lda rx1+1
        sbc rx0+1
        sta bw+1
        inc bw
        bne rf_1
        inc bw+1
rf_1    lda ry1
        sec
        sbc ry0
        sta bh
        lda ry1+1
        sbc ry0+1
        sta bh+1
        inc bh
        bne rf_2
        inc bh+1
rf_2    lda bh+1
        beq rf_3
        lda #255            ; taller than the screen
        sta bh
        lda #0
        sta bh+1
rf_3    lda rx0
        sta bx
        lda rx0+1
        sta bx+1
        lda ry0
        sta by
        lda ry0+1
        sta by+1
fill_go lda #0
        sta band
        sta bssx
        sta bssy
        sta bsrc
        sta bsrc+1
        sta bsrc+2
        sta bmode
        jmp blit_cam

; hspan: x0..x1 (signed 16, x0 <= x1) on row y (signed 16), colour index A
hspan   sta bxor
        lda rx1
        sec
        sbc rx0
        sta bw
        lda rx1+1
        sbc rx0+1
        bmi hs_out
        sta bw+1
        inc bw
        bne hs_1
        inc bw+1
hs_1    lda #1
        sta bh
        lda #0
        sta bh+1
        lda rx0
        sta bx
        lda rx0+1
        sta bx+1
        lda ry0
        sta by
        lda ry0+1
        sta by+1
        jmp fill_go
hs_out  rts

; pset(bx, by, A): colour through the draw palette; fast path
pset    jsr vcol
pset_i  sta tmp+3
        lda bx
        sec
        sbc camx
        tax
        lda bx+1
        sbc camx+1
        bne ps_out
        cpx cx0
        bcc ps_out
        cpx cx1
        bcs ps_out
        lda by
        sec
        sbc camy
        tay
        lda by+1
        sbc camy+1
        bne ps_out
        cpy cy0
        bcc ps_out
        cpy cy1
        bcs ps_out
        tya
        lsr
        sta bi_dst+1
        lda #0
        ror
        stx tmp
        ora tmp
        sta bi_dst
        ldx back_bank
        lda fb_hi,x
        ora bi_dst+1
        sta bi_dst+1
        lda fb_bk,x
        sta bi_dst+2
        lda tmp+3
        jmp bcb_pset
ps_out  rts

; spr(A, bx, by): sprite n from the sheet dsheet, spr_tw x spr_th tiles
; (spr_th may be 0: nothing), spr_fx/spr_fy flips, palette bank dbank.
spr_draw
        ldx spr_th
        jeq sd_out
        ldx spr_tw
        jeq sd_out
        sta tmp
        and #15
        asl
        asl
        asl
        sta bsrc
        lda tmp
        lsr
        lsr
        and #$3c
        sta bsrc+1          ; row * 1024
        lda dsheet
        asl
        asl
        asl
        asl
        asl
        asl
        ora bsrc+1
        sta bsrc+1
        lda #1
        sta bsrc+2          ; VR_SHEET = $10000
        lda spr_tw
        asl
        asl
        asl
        sta bw
        lda spr_th
        asl
        asl
        asl
        sta bh
        lda #0
        sta bw+1
        sta bh+1
        lda #1
        sta bssx
        lda spr_fx
        beq sd_nf
        lda bsrc
        clc
        adc bw
        sec
        sbc #1
        sta bsrc
        lda #$ff
        sta bssx
sd_nf   lda #7
        sta bssy
        lda spr_fy
        beq sd_nfy
        ; start at the last row, step -128
        lda bh
        sec
        sbc #1
        lsr
        sta tmp
        lda #0
        ror
        clc
        adc bsrc
        sta bsrc
        lda tmp
        adc bsrc+1
        sta bsrc+1
        lda #$80
        sta bssy
sd_nfy  lda dbank
        ora #$0f
        sta band
        lda #0
        sta bxor
        lda #1
        sta bmode
        jmp blit_cam
sd_out  rts
spr_tw  dta 1
spr_th  dta 1
spr_fx  dta 0
spr_fy  dta 0

; spr with size 1x1, no flips
spr1    ldx #1
        stx spr_tw
        stx spr_th
        ldx #0
        stx spr_fx
        stx spr_fy
        jmp spr_draw

; ---------------------------------------------------------- ellipse
; is(x, y, rx, ry, w, c): the cart's ellipse ring.  For dy = 0..ry the
; half width is dx = rx - k with k the smallest whole number for which
; (dx/rx)^2 + (dy/ry)^2 <= 1, that is k = ceil(rx - rx*sqrt(1-(dy/ry)^2)).
; Spans of min(dx, w) pixels are drawn at both ends, mirrored up and down:
;   flr(x+dx-k')..flr(x+dx) and flr(x-dx)..flr(x-dx+k'),  k' = min(dx, w)
; Inputs: el_x (24 bit: frac, lo, hi), el_y (16 bit int), el_rx, el_ry,
; el_w (8.8), colour index A.
el_draw sta el_c
        lda el_ry+1
        ora el_ry
        jeq el_out          ; ry = 0: only dy = 0 ... drawn below as a row
        lda #0
        sta el_dy
ed_row  ; u = dy / ry (fraction)
        lda el_dy
        bne ed_u
        lda #0
        jmp ed_s
ed_u    lda #0
        sta m_n
        lda el_dy
        sta m_n+1
        lda el_ry
        sta m_d
        lda el_ry+1
        sta m_d+1
        ; dy <= ry: dy*256 <= ry*256
        lda m_n+1
        cmp m_d+1
        bcc ed_u1
        bne ed_u0
        lda m_d
        bne ed_u1
ed_u0   lda #255
        jmp ed_s
ed_u1   jsr frac_div
ed_s    tax
        ; rx*s, s = sqrt(1 - u^2) (sqrt1_tab: 0 means 1.0)
        lda el_rx
        sta m_v
        lda el_rx+1
        sta m_v+1
        lda sqrt1_tab,x
        jsr mulf
        ; diff = rx - rx*s ; k = ceil(diff) ; dx = rx - k
        lda el_rx
        sec
        sbc m_v
        sta tmp
        lda el_rx+1
        sbc m_v+1
        ldx tmp
        beq ed_c
        clc
        adc #1              ; ceil
ed_c    sta tmp             ; k
        lda el_rx+1
        sec
        sbc tmp
        sta el_dx+1
        lda el_rx
        sta el_dx           ; dx = rx - k (8.8), may be < 0
        jcc ed_next         ; negative: nothing visible
        ; k' = min(dx, w)
        lda el_dx
        cmp el_w
        lda el_dx+1
        sbc el_w+1
        bcc ed_kd
        lda el_w
        sta el_k
        lda el_w+1
        sta el_k+1
        jmp ed_k1
ed_kd   lda el_dx
        sta el_k
        lda el_dx+1
        sta el_k+1
ed_k1   ; right span: flr(x+dx-k') .. flr(x+dx)
        lda el_x
        clc
        adc el_dx
        sta tmp
        lda el_x+1
        adc el_dx+1
        sta rx1
        lda el_x+2
        adc #0
        sta rx1+1
        lda tmp
        sec
        sbc el_k
        lda rx1
        sbc el_k+1
        sta rx0
        lda rx1+1
        sbc #0
        sta rx0+1
        jsr ed_pair
        ; left span: flr(x-dx) .. flr(x-dx+k')
        lda el_x
        sec
        sbc el_dx
        sta tmp
        lda el_x+1
        sbc el_dx+1
        sta rx0
        lda el_x+2
        sbc #0
        sta rx0+1
        lda tmp
        clc
        adc el_k
        lda rx0
        adc el_k+1
        sta rx1
        lda rx0+1
        adc #0
        sta rx1+1
        jsr ed_pair
ed_next inc el_dy
        lda el_dy
        cmp el_ry+1
        jcc ed_row
        jeq ed_row
el_out  rts
; the span on rows y+dy and y-dy (drawn once when dy = 0)
ed_pair lda rx0
        sta el_s0
        lda rx0+1
        sta el_s0+1
        lda el_y
        clc
        adc el_dy
        sta ry0
        lda el_y+1
        adc #0
        sta ry0+1
        lda el_c
        jsr hspan
        lda el_dy
        beq ep_d
        lda el_s0
        sta rx0
        lda el_s0+1
        sta rx0+1
        lda el_y
        sec
        sbc el_dy
        sta ry0
        lda el_y+1
        sbc #0
        sta ry0+1
        lda el_c
        jmp hspan
ep_d    rts
