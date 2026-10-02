; ------------------------------------------------------------------
; Drawing primitives.  Each one appends a blitter command that draws
; into the back framebuffer (128x128, stride 128) at screen position
; bx,by (signed 16 bit), clipped to cx0..cx1-1, cy0..cy1-1.
; ------------------------------------------------------------------

; step for a shift code: 0 -> 0, n -> 1 << n
step_lo dta 0,2,4,8,16,32,64,128,0,0,0
step_hi dta 0,0,0,0,0,0,0,0,1,2,4

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

; clipped blit to the back framebuffer
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
        jne bf_out          ; 256 or more off screen
        lda tmp
        jeq bf_out
        lda #0
        sec
        sbc tmp
        sta tmp             ; d = cx0 - bx (1..255)
        ldx bw+1
        bne bf_l_fit
        cmp bw
        jcs bf_out          ; d >= bw: nothing visible
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
        ; source += d * ssx
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
        ; ---- right: bx >= cx0 >= 0 now
        lda bx+1
        bne bf_out          ; x >= 256
        lda bx
        cmp cx1
        bcs bf_out
        ; room = cx1 - bx
        lda cx1
        sec
        sbc bx
        ldx bw+1
        bne bf_r_set        ; bw >= 256 > room
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
        ; dst = back_bank * $4000 + by*128 + bx
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
        lda fb_bank,x
        sta bi_dst+2
        lda #7
        sta tmp
        jmp blit_emit
; framebuffers: $00000, $04000, $30000
fb_hi   dta $00,$40,$00,$40
fb_bank dta 0,0,3,3
bf_out  rts

; write the command: source bsrc/bssx/bssy, destination bi_dst with the
; dest step shift in tmp, size bw x bh, masks band/bxor, mode bmode
blit_emit
        lda bsrc
        sta bi_src
        lda bsrc+1
        sta bi_src+1
        lda bsrc+2
        and #7
        sta bi_src+2
        ldx bssy
        lda step_lo,x
        sta bi_ssy
        lda step_hi,x
        sta bi_ssy+1
        lda bssx
        sta bi_ssx
        ldx tmp
        lda step_lo,x
        sta bi_dsy
        lda step_hi,x
        sta bi_dsy+1
        lda bw
        sec
        sbc #1
        sta bi_w
        lda bw+1
        sbc #0
        sta bi_w+1
        ldx bh
        dex
        stx bi_h
        lda band
        sta bi_and
        lda bxor
        sta bi_xor
        lda bmode
        ora #8
        sta bi_ctrl
        jmp bcb_add

; ---------------------------------------------------------- primitives
; PICO colour -> VBXE index (0 becomes the opaque black 16)
vcol    and #15
        bne vc_1
        lda #16
vc_1    rts

; clip(): whole screen
clip_reset
        lda #0
        sta cx0
        sta cy0
        lda #128
        sta cx1
        sta cy1
        rts

; cls(): the back framebuffer is filled with 0
cls     lda #0
        sta bx
        sta bx+1
        sta by
        sta by+1
        lda #128
        sta bw
        sta bh
        lda #0
        sta bw+1
        sta bh+1
        lda #0
        sta band
        sta bxor
        sta bssx
        sta bssy
        sta bsrc
        sta bsrc+1
        sta bsrc+2
        sta bmode
        lda cx0
        pha
        lda cy0
        pha
        lda cx1
        pha
        lda cy1
        pha
        jsr clip_reset
        jsr blit_fb
        pla
        sta cy1
        pla
        sta cx1
        pla
        sta cy0
        pla
        sta cx0
        rts

; rectfill: bx,by,bw,bh (bw/bh low bytes, >0), colour A
fill_draw
        jsr vcol
        sta bxor
        lda #0
        sta bw+1
        sta bh+1
        sta band
        sta bssx
        sta bssy
        sta bsrc
        sta bsrc+1
        sta bsrc+2
        sta bmode
        jmp blit_fb

; pset(bx,by,A)
pset_draw
        ldx #1
        stx bw
        stx bh
        jmp fill_draw

; rect(x0,y0,x1,y1,c): a0/a1 = x0 (16), a2/a3 = y0, a4 = width-1, a5 = height-1,
; a6 = colour.  Outline only.
rect_draw
        ; top
        jsr rd_xy
        lda a4
        clc
        adc #1
        sta bw
        lda #1
        sta bh
        lda a6
        jsr fill_draw
        ; bottom
        jsr rd_xy
        lda by
        clc
        adc a5
        sta by
        bcc rd_1
        inc by+1
rd_1    lda a4
        clc
        adc #1
        sta bw
        lda #1
        sta bh
        lda a6
        jsr fill_draw
        ; left
        jsr rd_xy
        lda #1
        sta bw
        lda a5
        clc
        adc #1
        sta bh
        lda a6
        jsr fill_draw
        ; right
        jsr rd_xy
        lda bx
        clc
        adc a4
        sta bx
        bcc rd_2
        inc bx+1
rd_2    lda #1
        sta bw
        lda a5
        clc
        adc #1
        sta bh
        lda a6
        jmp fill_draw
rd_xy   lda a0
        sta bx
        lda a1
        sta bx+1
        lda a2
        sta by
        lda a3
        sta by+1
        rts

; spr(A, bx, by, spr_tw, spr_th, spr_flip) from sheet spr_var
spr_tw  dta 1
spr_th  dta 1
spr_flip dta 0
spr_var dta 0
spr_draw
        sta tmp
        and #15
        asl
        asl
        asl
        sta bsrc
        lda tmp
        lsr
        lsr
        lsr
        lsr
        sta bsrc+1          ; row * 8 * 128 = row * 1024 -> high byte row*4
        asl bsrc+1
        asl bsrc+1
        lda spr_var
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
        lda spr_flip
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
        lda #$ff
        sta band
        lda #0
        sta bxor
        lda #1
        sta bmode
        jmp blit_fb

; sprite with default size/flags
spr1    ldx #1
        stx spr_tw
        stx spr_th
        ldx #0
        stx spr_flip
        stx spr_var
        jmp spr_draw

; ---------------------------------------------------------- the map
; map window: tiles camtx-8..camtx+8 x camty-8..camty+8 of the baked map
map_draw
        ; x range
        lda camtx
        sec
        sbc #8
        bcs md_x0
        lda #0
md_x0   sta tmp+1           ; tx0
        lda camtx
        clc
        adc #8
        cmp #128
        bcc md_x1
        lda #127
md_x1   sec
        sbc tmp+1
        jcc md_out
        adc #0              ; +1 (carry set)
        sta tmp+2           ; tiles wide
        lda camty
        sec
        sbc #8
        bcs md_y0
        lda #0
md_y0   sta tmp+3           ; ty0
        lda camty
        clc
        adc #8
        cmp #32
        bcc md_y1
        lda #31
md_y1   sec
        sbc tmp+3
        jcc md_out
        adc #0
        sta tmp+7           ; tiles high
        ; size
        lda tmp+2
        asl
        asl
        asl
        sta bw
        lda #0
        rol
        sta bw+1
        lda tmp+7
        asl
        asl
        asl
        sta bh
        lda #0
        rol
        sta bh+1
        ; source = VR_MAP + ty0*8*1024 + tx0*8
        lda tmp+1
        asl
        asl
        asl
        sta bsrc
        lda #0
        rol
        sta bsrc+1
        ; ty0*8192 = ty0 << 13 : byte1 = (ty0<<5)&255, byte2 = ty0>>3
        lda tmp+3
        asl
        asl
        asl
        asl
        asl
        clc
        adc bsrc+1
        sta bsrc+1
        lda tmp+3
        lsr
        lsr
        lsr
        clc
        adc #4              ; VR_MAP = $40000
        sta bsrc+2
        ; screen position = tx0*8 - camx
        lda tmp+1
        asl
        asl
        asl
        sta bx
        lda #0
        rol
        sta bx+1
        lda bx
        sec
        sbc camx
        sta bx
        lda bx+1
        sbc camx+1
        sta bx+1
        lda tmp+3
        asl
        asl
        asl
        sta by
        lda #0
        rol
        sta by+1
        lda by
        sec
        sbc camy
        sta by
        lda by+1
        sbc camy+1
        sta by+1
        lda #1
        sta bssx
        lda #10
        sta bssy
        lda #$ff
        sta band
        lda #0
        sta bxor
        sta bmode
        jmp blit_fb
md_out  rts

; Bake tile (a0, a1) into the map buffer according to its fog value:
; 2 or tile 0 = black, 1 = dark sheet, 0 = lit sheet.
bake_tile
        ldy a0
        ldx a1
        jsr tile_ofs        ; ptr = row offset; Y = x
        lda (ptr),y         ; ptr points into TMAP
        sta tmp+1
        lda ptr+1
        clc
        adc #>(FOG-TMAP)
        sta ptr+1
        lda (ptr),y
        sta tmp+2
        ; destination VR_MAP + a1*8192 + a0*8
        lda a0
        asl
        asl
        asl
        sta bi_dst
        lda #0
        rol
        sta bi_dst+1
        lda a1
        asl
        asl
        asl
        asl
        asl
        clc
        adc bi_dst+1
        sta bi_dst+1
        lda a1
        lsr
        lsr
        lsr
        clc
        adc #4
        sta bi_dst+2
        lda #8
        sta bw
        sta bh
        lda #0
        sta bw+1
        sta bh+1
        sta bmode
        lda tmp+2
        cmp #2
        beq bk_black
        lda tmp+1
        beq bk_black
        ; tile from the lit (fog 0) or dark (fog 1) sheet
        lda tmp+1
        and #15
        asl
        asl
        asl
        sta bsrc
        lda tmp+1
        lsr
        lsr
        and #$3c
        ldx tmp+2
        ora bk_sheet,x
        sta bsrc+1
        lda #1
        sta bsrc+2
        sta bssx
        lda #7
        sta bssy
        lda #$ff
        sta band
        lda #0
        sta bxor
        lda #10
        sta tmp
        jmp blit_emit
bk_black
        lda #0
        sta band
        sta bxor
        sta bssx
        sta bssy
        sta bsrc
        sta bsrc+1
        sta bsrc+2
        lda #10
        sta tmp
        jmp blit_emit
bk_sheet dta $40,$80        ; fog 0: lit sheet $14000, fog 1: dark $18000

; clear the whole map buffer (two 512x256 fills)
clear_map
        lda #0
        sta bi_dst
        sta bi_dst+1
        sta bw
        sta bh
        sta band
        sta bxor
        sta bssx
        sta bssy
        sta bmode
        lda #2
        sta bw+1
        lda #1
        sta bh+1            ; bh = 256 (the emitter takes the low byte - 1)
        lda #4
        sta bi_dst+2
        lda #10
        sta tmp
        jsr blit_emit
        lda #2
        sta bi_dst+1
        lda #4
        sta bi_dst+2
        lda #0
        sta bw
        lda #2
        sta bw+1
        lda #0
        sta bh
        lda #10
        sta tmp
        jmp blit_emit

; ---------------------------------------------------------- title
; draw map(112,0) into VR_TITLE once
bake_title
        jsr bcb_begin
        ; clear
        lda #0
        sta bi_dst
        sta bi_dst+1
        lda #>VR_TITLE
        sta bi_dst+1
        lda #^VR_TITLE
        sta bi_dst+2
        lda #128
        sta bw
        sta bh
        lda #0
        sta bw+1
        sta bh+1
        sta band
        sta bxor
        sta bssx
        sta bssy
        sta bmode
        lda #7
        sta tmp
        jsr blit_emit
        ldx #0
bt_loop stx lp
        lda title_map,x
        beq bt_next
        sta tmp+1
        ; source raw sheet
        and #15
        asl
        asl
        asl
        sta bsrc
        lda tmp+1
        lsr
        lsr
        and #$3c
        sta bsrc+1
        lda #1
        sta bsrc+2
        sta bssx
        sta bmode
        lda #7
        sta bssy
        lda #$ff
        sta band
        lda #0
        sta bxor
        lda #8
        sta bw
        sta bh
        ; dest VR_TITLE + (i/16)*1024 + (i&15)*8
        lda lp
        and #15
        asl
        asl
        asl
        sta bi_dst
        lda lp
        lsr
        lsr
        and #$3c
        clc
        adc #>VR_TITLE
        sta bi_dst+1
        lda #^VR_TITLE
        sta bi_dst+2
        lda #7
        sta tmp
        jsr blit_emit
bt_next ldx lp
        inx
        bne bt_loop
        jmp bcb_flush

; title background to the screen
title_bg
        lda #0
        sta bx
        sta bx+1
        sta by
        sta by+1
        sta bsrc
        sta bsrc+1
        lda #>VR_TITLE
        sta bsrc+1
        lda #^VR_TITLE
        sta bsrc+2
        lda #128
        sta bw
        sta bh
        lda #0
        sta bw+1
        sta bh+1
        sta bxor
        sta bmode
        lda #1
        sta bssx
        lda #7
        sta bssy
        lda #$ff
        sta band
        jmp blit_fb

; fillp checker rect(0,50,127,82,0): dots where (x+y) is even
title_dither
        lda #2
        sta bi_dsx
        lda #64
        sta bw
        lda #1
        sta bh
        lda #7
        sta tmp
        lda #<(50*128)
        ldx #>(50*128)
        jsr td_emit
        lda #<(82*128)
        ldx #>(82*128)
        jsr td_emit
        lda #1
        sta bi_dsx
        sta bw
        lda #17
        sta bh
        lda #8
        sta tmp
        lda #<(50*128)
        ldx #>(50*128)
        jsr td_emit
        lda #16
        sta bh
        lda #<(51*128+127)
        ldx #>(51*128+127)
td_emit sta bi_dst
        stx tmp+1
        ldx back_bank
        lda fb_hi,x
        ora tmp+1
        sta bi_dst+1
        lda fb_bank,x
        sta bi_dst+2
        lda #0
        sta bw+1
        sta bh+1
        sta band
        sta bssx
        sta bssy
        sta bmode
        lda #16
        sta bxor
        jmp blit_emit
