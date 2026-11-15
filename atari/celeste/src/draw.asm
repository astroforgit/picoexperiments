; ------------------------------------------------------------------
; Drawing primitives.  Each one appends a blitter command that draws
; into the back framebuffer; coordinates are biased (pico + 64) and the
; screenshake camera offset is applied here.
; These routines use tmp..tmp+3 only and keep dr_y.
; ------------------------------------------------------------------

; destination = back_bank : (dr_y - cam_y) : (dr_x - cam_x)
set_dst lda dr_x
        sec
        sbc cam_x
        sta tpl_dst
        lda dr_y
        sec
        sbc cam_y
        sta tpl_dst+1
        lda back_bank
        sta tpl_dst+2
        rts

; PICO-8 colour -> VBXE index (0 becomes the opaque black 16)
vcol    cmp #0
        bne vc_1
        lda #16
vc_1    and #31
        rts

; constants shared by every framebuffer kind: dest step 256
tpl_fb  lda #0
        sta tpl_dsy
        sta tpl_w+1
        sta tpl_xor
        lda #1
        sta tpl_dsy+1
        rts

; spr(A, dr_x, dr_y) with dr_fx/dr_fy flips and dr_var hair palette
spr_draw
        sta tmp
        ldy tpl_kind
        cpy #K_SPR
        beq sd_k
        jsr tpl_fb
        lda #7
        sta tpl_w
        sta tpl_h
        lda #$ff
        sta tpl_and
        lda #1
        sta tpl_ctrl
        lda #K_SPR
        sta tpl_kind
sd_k    lda tmp
        asl
        asl
        asl
        and #$78
        sta tpl_src
        lda tmp
        lsr
        lsr
        and #$3c
        sta tpl_src+1
        lda #2
        sta tpl_src+2
        lda dr_var
        beq sd_1
        ldy tmp
        cpy #16
        bcs sd_1
        sec
        sbc #1
        asl
        asl
        ora #$40
        sta tpl_src+1
sd_1    lda #128
        sta tpl_ssy
        lda #0
        sta tpl_ssy+1
        lda #1
        sta tpl_ssx
        lda dr_fx
        beq sd_2
        lda tpl_src
        ora #7
        sta tpl_src
        lda #$ff
        sta tpl_ssx
sd_2    lda dr_fy
        beq sd_3
        lda tpl_src
        ora #$80
        sta tpl_src
        lda tpl_src+1
        clc
        adc #3
        sta tpl_src+1
        lda #$80
        sta tpl_ssy
        lda #$ff
        sta tpl_ssy+1
sd_3    jsr set_dst
        jmp bcb_add

; rectfill(dr_x,dr_y,dr_x1,dr_y1,dr_c)
fill_rect
        lda tpl_kind
        cmp #K_FILL
        beq fr_k
        jsr tpl_fb
        lda #0
        sta tpl_src
        sta tpl_src+1
        sta tpl_src+2
        sta tpl_ssy
        sta tpl_ssy+1
        sta tpl_ssx
        sta tpl_and
        sta tpl_ctrl
        lda #K_FILL
        sta tpl_kind
fr_k    lda dr_x1
        cmp dr_x
        bcs fr_1
        ldy dr_x
        sta dr_x
        sty dr_x1
fr_1    lda dr_y1
        cmp dr_y
        bcs fr_2
        ldy dr_y
        sta dr_y
        sty dr_y1
fr_2    lda dr_x
        sec
        sbc cam_x
        sta tpl_dst
        lda dr_y
        sec
        sbc cam_y
        sta tpl_dst+1
        lda back_bank
        sta tpl_dst+2
        lda dr_x1
        sec
        sbc dr_x
        sta tpl_w
        lda dr_y1
        sec
        sbc dr_y
        sta tpl_h
        lda dr_c
        bne fr_3
        lda #16
fr_3    sta tpl_xor
        jmp bcb_add

; print(txtp, dr_x, dr_y, dr_c) - 4 pixels per character
print
        lda dr_c
        jsr vcol
        sta pr_col
        lda #0
        sta pr_i
pr_loop ldy pr_i
        lda (txtp),y
        beq pr_done
        cmp #' '
        beq pr_skip
        and #$7f
        tax
        lda ascii_glyph,x
        cmp #$ff
        beq pr_skip
        sta tmp
        lda tpl_kind
        cmp #K_GLYPH
        beq pr_k
        jsr tpl_fb
        lda #2
        sta tpl_src+2
        sta tpl_w
        lda #3
        sta tpl_ssy
        lda #0
        sta tpl_ssy+1
        lda #1
        sta tpl_ssx
        sta tpl_ctrl
        lda #4
        sta tpl_h
        lda #K_GLYPH
        sta tpl_kind
pr_k    lda tmp
        asl
        asl
        asl
        asl
        sta tpl_src
        lda tmp
        lsr
        lsr
        lsr
        lsr
        clc
        adc #$50
        sta tpl_src+1
        lda pr_col
        sta tpl_and
        jsr set_dst
        jsr bcb_add
pr_skip lda dr_x
        clc
        adc #4
        sta dr_x
        inc pr_i
        bne pr_loop
pr_done rts
pr_col  dta 0
pr_i    dta 0

; circfill(dr_x, dr_y, A, dr_c) for radius 1 or 2
circ_draw
        sta tmp
        lda tpl_kind
        cmp #K_CIRC
        beq cd_k
        jsr tpl_fb
        lda #$58
        sta tpl_src+1
        lda #2
        sta tpl_src+2
        lda #8
        sta tpl_ssy
        lda #0
        sta tpl_ssy+1
        lda #1
        sta tpl_ssx
        sta tpl_ctrl
        lda #K_CIRC
        sta tpl_kind
cd_k    lda dr_x
        sta tmp+1
        sec
        sbc tmp
        sta dr_x
        lda dr_y
        sta tmp+2
        sec
        sbc tmp
        sta dr_y
        lda #0
        ldx #2
        ldy tmp
        cpy #2
        bne cd_1
        lda #$40
        ldx #4
cd_1    sta tpl_src
        stx tpl_w
        stx tpl_h
        lda dr_c
        jsr vcol
        sta tpl_and
        jsr set_dst
        lda tmp+1
        sta dr_x
        lda tmp+2
        sta dr_y
        jmp bcb_add

; map layer: A = $00 (background, $30000) or $40 (terrain, $34000)
layer_draw
        sta tmp
        lda tpl_kind
        cmp #K_LAYER
        beq ld_k
        jsr tpl_fb
        lda #0
        sta tpl_src
        sta tpl_ssy+1
        lda #3
        sta tpl_src+2
        lda #128
        sta tpl_ssy
        lda #1
        sta tpl_ssx
        sta tpl_ctrl
        lda #127
        sta tpl_w
        sta tpl_h
        lda #$ff
        sta tpl_and
        lda #K_LAYER
        sta tpl_kind
ld_k    lda tmp
        sta tpl_src+1
        lda #BIAS
        sta dr_x
        sta dr_y
        jsr set_dst
        jmp bcb_add

; ---------------------------------------------------------- numbers
; decimal of A(lo)/Y(hi) into txtbuf from offset X, zero terminated;
; tmp = offset of the terminator
fmt_u16_at1
        ldx #1
fmt_u16_x
        sta tmp+1
        sty tmp+2
        stx tmp
        lda #0
        sta tmp+3
        ldy #0
fm_pow  ldx #0
fm_sub  lda tmp+1
        sec
        sbc pow_lo,y
        pha
        lda tmp+2
        sbc pow_hi,y
        bcc fm_dig
        sta tmp+2
        pla
        sta tmp+1
        inx
        bne fm_sub
fm_dig  pla
        txa
        ora tmp+3
        bne fm_out
        cpy #4
        bne fm_next
fm_out  txa
        clc
        adc #'0'
        ldx tmp
        sta txtbuf,x
        inc tmp
        lda #1
        sta tmp+3
fm_next iny
        cpy #5
        bne fm_pow
        ldx tmp
        lda #0
        sta txtbuf,x
        rts
pow_lo  dta <10000,<1000,<100,<10,<1
pow_hi  dta >10000,>1000,>100,>10,>1

; two digits of A (0..99) at txtbuf,x; X += 2
two_digits
        ldy #'0'
td_10   cmp #10
        bcc td_1
        sbc #10
        iny
        bne td_10
td_1    pha
        tya
        sta txtbuf,x
        pla
        clc
        adc #'0'
        sta txtbuf+1,x
        inx
        inx
        rts

; draw_time(A=x, Y=y): black box and hh:mm:ss
draw_time
        sta dt_x
        sty dt_y
        sta dr_x
        sty dr_y
        clc
        adc #32
        sta dr_x1
        tya
        clc
        adc #6
        sta dr_y1
        lda #0
        sta dr_c
        jsr fill_rect
        ; h = flr(minutes/60), m = minutes%60
        lda minutes
        sta tmp
        lda minutes+1
        sta tmp+1
        lda #0
        sta tmp+2
dt_div  lda tmp
        sec
        sbc #60
        tay
        lda tmp+1
        sbc #0
        bcc dt_dd
        sta tmp+1
        sty tmp
        inc tmp+2
        bne dt_div
dt_dd   lda tmp+2
        cmp #100
        bcc dt_h
        lda #99
dt_h    ldx #0
        jsr two_digits
        lda #':'
        sta txtbuf,x
        inx
        lda tmp
        jsr two_digits
        lda #':'
        sta txtbuf,x
        inx
        lda seconds
        jsr two_digits
        lda #0
        sta txtbuf,x
        lda dt_x
        clc
        adc #1
        sta dr_x
        lda dt_y
        clc
        adc #1
        sta dr_y
        lda #7
        sta dr_c
        mwa #txtbuf txtp
        jmp print
dt_x    dta 0
dt_y    dta 0
