; ------------------------------------------------------------------
; Drawables (the cart's c_ list): each frame they are drawn in layer
; order 0..129 (the target's y, or a fixed layer), with the particle
; systems sorted in among them.  Their timers advance once per update
; (draw_tick) so skipped frames do not slow them down.
; ------------------------------------------------------------------
R_RT    = 1         ; rt: characters
R_FO    = 2         ; fo: projectiles
R_GT    = 3         ; gt: blob shots
R_EX    = 4         ; e_: explosion ring
R_LB    = 5         ; lb: health bar box
R_GA    = 6         ; ga: combo counter
R_RI    = 7         ; ri: stage results
R_KR    = 8         ; kr: the boss's shield
R_DC    = 9         ; dc: the level background
R_SJ    = 10        ; sj: the title
NLAYER2 = 130

; qm(): draw everything in layer order
draw_all
        ldx #NLAYER2-1
        lda #$ff
da_c    sta bucket,x
        dex
        cpx #$ff
        bne da_c
        lda #NLAYER2-1
        sta da_min
        lda #0
        sta da_max
        ; drawables
        ldx #MAXD-1
da_d    lda d_kind,x
        beq da_dn
        lda d_layer,x
        cmp #$ff
        bne da_dl
        ldy d_ent,x
        lda e_yl,y
        cmp #NLAYER2
        bcc da_dl
        lda #NLAYER2-1
da_dl   tay
        jsr da_rng
        lda bucket,y
        sta d_next,x
        txa
        sta bucket,y
da_dn   dex
        bpl da_d
        ; particle systems (index MAXD + n)
        ldx #MAXPS-1
da_p    lda ps_on,x
        beq da_pn
        lda ps_head,x
        cmp #$ff
        beq da_pn
        lda ps_y,x
        cmp #NLAYER2
        bcc da_pl
        lda #NLAYER2-1
da_pl   tay
        jsr da_rng
        lda bucket,y
        sta ps_next,x
        txa
        clc
        adc #MAXD
        sta bucket,y
da_pn   dex
        bpl da_p
        ; draw
        lda #0
        sta hud_done
        lda da_min
        sta da_layer
da_l    ldy da_layer
        lda bucket,y
da_i    cmp #$ff
        beq da_ln
        cmp #MAXD
        bcs da_ps
        sta dd
        jsr tb_reset
        jsr draw_one
        ldx dd
        lda d_next,x
        jmp da_i
da_ps   sec
        sbc #MAXD
        sta ps
        jsr tb_reset
        jsr part_draw
        ldx ps
        lda ps_next,x
        jmp da_i
da_ln   lda da_layer
        cmp da_max
        jcs da_end
        inc da_layer
        jmp da_l
da_end  rts
; keep the range of used layers (Y = layer)
da_rng  cpy da_min
        bcs dr_1
        sty da_min
dr_1    cpy da_max
        bcc dr_2
        sty da_max
dr_2    rts
da_layer dta 0
da_min  dta 0
da_max  dta 0

; tb(): pal(), palt(0, false), palt(3, true)
tb_reset
        lda #0
        sta dbank
        sta dsheet
        rts

draw_one
        ldx dd
        lda d_kind,x
        asl
        tay
        lda rnd_tab-2,y
        sta do_j+1
        lda rnd_tab-1,y
        sta do_j+2
        ldy d_ent,x
do_j    jmp $ffff
rnd_tab dta a(dr_rt),a(dr_fo),a(dr_gt),a(dr_ex),a(hud_draw),a(dr_ga),a(dr_ri),a(dr_kr),a(dr_dc),a(dr_sj)

; per update: drawable timers
draw_tick
        ldx #MAXD-1
dt_l    stx dd
        lda d_kind,x
        beq dt_n
        cmp #R_LB
        bne dt_1
        jsr t_lb
        jmp dt_t
dt_1    cmp #R_GA
        bne dt_2
        jsr t_ga
        jmp dt_t
dt_2    cmp #R_KR
        bne dt_3
        jsr t_kr
        jmp dt_t
dt_3    cmp #R_RI
        bne dt_4
        jsr t_ri
        jmp dt_t
dt_4    cmp #R_SJ
        bne dt_5
        jsr t_sj
        jmp dt_t
dt_5    cmp #R_DC
        bne dt_t
        jsr t_dc
dt_t    ldx dd
        inc d_t,x
        bne dt_n
        inc d_th,x
dt_n    ldx dd
        dex
        bpl dt_l
        ; the screen shake decays: gr = max(gr - 0.5, 0)
        lda gr
        beq dt_g
        dec gr
dt_g    rts

; ------------------------------------------------------------------
; rt(c): a character.  Y = entity
dr_rt    sty rt_e
        lda e_nb,y
        beq rt_1
        lda e_dg,y
        bne rt_1
        rts
rt_1    ; walking frame
        lda #0
        sta fs_jg
        lda e_gjon,y
        beq rt_2
        ; jg = wc[flr((t - gj)/bv) % #wc + 1]
        lda frames
        sec
        sbc e_gjl,y
        sta m_n
        lda frames+1
        sbc e_gjh,y
        sta m_n+1
        lda e_cls,y
        tax
        lda c_bv,x
        cpy eg
        bne rt_bv
        lda pl_bv
rt_bv   asl
        tax
        jsr mod8            ; m_q = (t - gj) / (2 bv)
        ldy rt_e
        ldx e_cls,y
        lda c_hw,x
        cmp #2
        beq rt_w2
        lda m_q
        and #3
        tax
        lda na_1,x
        jmp rt_w
rt_w2   lda m_q
        and #1
        tax
        lda na_2,x
rt_w    sta fs_jg
rt_2    ldy rt_e
        lda e_st,y
        cmp #S_QI
        beq rt_j2
        cmp #S_LN
        bne rt_3
rt_j2   lda #2
        sta fs_jg
rt_3    ; shadow: is(c.x - 1, c.y, fw/2, 2.97, fw, 0)
        ldx e_cls,y
        lda c_sm,x
        sec
        sbc #1
        sta tmp+4           ; shadow image sm - 1
        lda e_xl,y
        sec
        sbc #1
        sta bx
        lda e_xh,y
        sbc #0
        sta bx+1
        lda e_yl,y
        sta by
        lda #0
        sta by+1
        lda #0
        jsr vcol
        ldx tmp+4
        jsr draw_shadow
        ; fx = c.x - sm*4, fy = c.y + c.z
        ldy rt_e
        ldx e_cls,y
        lda c_sm,x
        asl
        asl
        sta tmp
        lda e_xl,y
        sec
        sbc tmp
        sta fs_x
        lda e_xh,y
        sbc #0
        sta fs_x+1
        lda e_yf,y
        clc
        adc e_zf,y
        lda e_yl,y
        adc e_zl,y
        sta fs_y
        lda #0
        adc e_zh,y
        sta fs_y+1
        ; hp bar (not the boss)
        cpy boss
        beq rt_4
        jsr rt_bar
rt_4    ; palette: hit flash, parry flash or the entity's own effect
        ldy rt_e
        lda frames
        sec
        sbc e_bl,y
        sta tmp
        lda frames+1
        sbc e_bh,y
        bne rt_p
        lda tmp
        jsr flash_lvl
        beq rt_p
        ldx e_cls,y
        sta tmp
        lda c_jv,x
        beq rt_sz
        lda tmp
        clc
        adc #BK_HF
        jmp rt_g
rt_sz   lda tmp
        clc
        adc #BK_SZ
        jmp rt_g
rt_p    lda frames
        sec
        sbc e_pul,y
        sta tmp
        lda frames+1
        sbc e_puh,y
        bne rt_o
        lda tmp
        jsr flash_lvl
        beq rt_o
        clc
        adc #BK_HF
        jmp rt_g
rt_o    lda e_gbt,y
rt_g    sta fs_gb
        ldx rt_e
        jmp fs_draw
rt_e    dta 0

; sq(11 - dt/2, 3): A = frames since -> level 0..3 (Z = 1 when 0)
flash_lvl
        cmp #17
        bcs fl_0
        cmp #5
        bcc fl_3
        cmp #11
        bcc fl_2
        lda #1
        rts
fl_2    lda #2
        rts
fl_3    lda #3
        rts
fl_0    lda #0
        rts

; nu(fx+2, by, fx+fw-1, by, qg - pa, qg, 8, 2): the bar over a character
rt_bar  ldy rt_e
        ldx e_cls,y
        ; by = fy - en*8 - 1 + ms
        lda c_en,x
        asl
        asl
        asl
        clc
        adc #1
        sta tmp
        lda fs_y
        sec
        sbc tmp
        sta nu_y1
        lda fs_y+1
        sbc #0
        sta nu_y1+1
        lda c_ms,x
        ldy #0
        cmp #$80
        bcc rb_1
        dey
rb_1    clc
        adc nu_y1
        sta nu_y1
        tya
        adc nu_y1+1
        sta nu_y1+1
        lda nu_y1
        sta nu_y2
        lda nu_y1+1
        sta nu_y2+1
        ; x1 = fx + 2, x2 = fx + fw - 1 = fx + sm*8 - 3
        lda fs_x
        clc
        adc #2
        sta nu_x1
        lda fs_x+1
        adc #0
        sta nu_x1+1
        lda c_sm,x
        asl
        asl
        asl
        sec
        sbc #3
        clc
        adc fs_x
        sta nu_x2
        lda fs_x+1
        adc #0
        sta nu_x2+1
        ; qc = qg - pa, n = qg
        ldy rt_e
        lda c_qg,x
        sta nu_n
        sec
        sbc e_pal,y
        sta nu_qc
        lda #0
        sbc #0
        sta nu_qc+1
        lda #8
        sta nu_fg
        lda #2
        sta nu_bg
        lda #0
        sta nu_rm
        jmp nu_bar

; nu(x1, y1, x2, y2, qc, n, fg, bg, rm): a bar.  x2 may be left of x1.
nu_bar  lda nu_rm
        bne nb_1
        ; rectfill(x1-1, y1-1, x2+1, y2+1, 0), x order as given
        jsr nb_ord
        lda rx0
        sec
        sbc #1
        sta rx0
        bcs nb_a
        dec rx0+1
nb_a    inc rx1
        bne nb_b
        inc rx1+1
nb_b    lda nu_y1
        sec
        sbc #1
        sta ry0
        lda nu_y1+1
        sbc #0
        sta ry0+1
        lda nu_y2
        clc
        adc #1
        sta ry1
        lda nu_y2+1
        adc #0
        sta ry1+1
        lda #0
        jsr rectfill
nb_1    jsr nb_ord
        jsr nb_y
        lda nu_bg
        jsr rectfill
        ; w = flr(qc/n * abs(x2-x1))
        lda nu_qc+1
        bmi nb_d
        lda nu_qc
        beq nb_d
        jsr nb_ord
        lda rx1
        sec
        sbc rx0
        ldx nu_qc
        jsr umul8           ; qc * width
        lda m_lo
        sta m_n
        lda m_hi
        sta m_n+1
        ldx nu_n
        jsr mod8
        lda m_q
        beq nb_d
        sta tmp+6
        ; rectfill(x1, y1, x1 + w*sgn(x2-x1), y2, fg)
        lda nu_x1
        sta rx0
        lda nu_x1+1
        sta rx0+1
        lda nu_x2
        cmp nu_x1
        lda nu_x2+1
        sbc nu_x1+1
        bmi nb_l
        lda nu_x1
        clc
        adc tmp+6
        sta rx1
        lda nu_x1+1
        adc #0
        sta rx1+1
        jmp nb_f
nb_l    lda nu_x1
        sec
        sbc tmp+6
        sta rx1
        lda nu_x1+1
        sbc #0
        sta rx1+1
nb_f    jsr nb_y
        lda nu_fg
        jmp rectfill
nb_d    rts
; rx0/rx1 = min/max of x1, x2
nb_ord  lda nu_x2
        cmp nu_x1
        lda nu_x2+1
        sbc nu_x1+1
        bmi nbo_r
        lda nu_x1
        sta rx0
        lda nu_x1+1
        sta rx0+1
        lda nu_x2
        sta rx1
        lda nu_x2+1
        sta rx1+1
        rts
nbo_r   lda nu_x2
        sta rx0
        lda nu_x2+1
        sta rx0+1
        lda nu_x1
        sta rx1
        lda nu_x1+1
        sta rx1+1
        rts
nb_y    lda nu_y1
        sta ry0
        lda nu_y1+1
        sta ry0+1
        lda nu_y2
        sta ry1
        lda nu_y2+1
        sta ry1+1
        rts

; shadow image X (0..4) centred at bx, by; colour index A
draw_shadow sta band
        txa
        asl                 ; image * 512 -> byte 1 += image*2
        clc
        adc #>(SHADOW & $ffff)
        sta bsrc+1
        lda #<SHADOW
        sta bsrc
        lda #^SHADOW
        sta bsrc+2
        lda bx
        sec
        sbc #16
        sta bx
        lda bx+1
        sbc #0
        sta bx+1
        lda by
        sec
        sbc #3
        sta by
        lda by+1
        sbc #0
        sta by+1
        lda #33
        sta bw
        lda #7
        sta bh
        lda #0
        sta bw+1
        sta bh+1
        sta bxor
        lda #1
        sta bssx
        sta bmode
        lda #6              ; stride 64
        sta bssy
        jmp blit_cam

; ------------------------------------------------------------------
; fs(cls, x, y, jg, state, flip, gb): entity X, fs_x / fs_y, fs_jg (0 nil),
; fs_gb (bank, 0 none).  The cart draws the body once per clip region
; (head row, then the legs frame) and then the overlay sprites.
fs_draw stx fs_e
        lda e_cls,x
        sta fs_c
        ; layout: row of the state, column of the class
        ldy e_st,x
        lda sprr_lo,y
        sta ptr
        lda sprr_hi,y
        sta ptr+1
        ldy fs_c
        lda (ptr),y
        tay
        lda jy_lo,y
        sta sp
        lda jy_hi,y
        sta sp+1
        ldy fs_c
        lda c_mp,y
        sta dsheet
        lda fs_gb
        asl
        asl
        asl
        asl
        sta dbank
        lda c_rb,y
        beq fs_1
        lda #0
        sta fs_jg
fs_1    ; jg = jy.jg or jg or jy.jk or 1
        ldy #0
        lda (sp),y
        bne fs_jgs
        lda fs_jg
        bne fs_jgs
        iny
        lda (sp),y
        bne fs_jgs
        lda #1
fs_jgs  sta fs_jg
        ; frame offset la[jg]
        ldy fs_c
        ldx c_la,y
        lda fs_jg
        cmp #2
        beq fs_f2
        bcs fs_f3
        lda jt_f1,x
        jmp fs_f
fs_f2   lda jt_f2,x
        jmp fs_f
fs_f3   lda jt_f3,x
fs_f    asl
        asl
        asl
        asl
        clc
        adc c_po,y
        sta fs_legs
        lda jt_kz,x
        sta fs_kz
        lda jt_cu,x
        sta fs_cu
        lda jt_ff,x
        sta fs_ff
        lda c_sm,y
        sta fs_sm
        lda c_en,y
        sta fs_en
        lda c_po,y
        sta fs_po
        ldx fs_e
        lda e_qn,x
        and #$80
        sta spr_fx
        lda #0
        sta spr_fy
        ; clip entries
        ldy #2
        lda (sp),y
        sta fs_n
        iny
        sty fs_p
fs_cl   lda fs_n
        jeq fs_ov
        ldy fs_p
        lda (sp),y
        beq fs_nc
        ; clip(flip ? x+sm*8-cx-cw : x+cx, y+cy, cw, ch)
        iny
        lda (sp),y
        sta tmp             ; cx
        iny
        lda (sp),y
        sta tmp+1           ; cy
        iny
        lda (sp),y
        sta tmp+2           ; cw
        iny
        lda (sp),y
        sta tmp+3           ; ch
        lda spr_fx
        beq fs_cn
        lda fs_sm
        asl
        asl
        asl
        sec
        sbc tmp
        sec
        sbc tmp+2
        sta tmp
fs_cn   jsr fs_clip
fs_nc   ; spr(po, x, y-en*8+1, sm, kz, flip)
        lda fs_sm
        sta spr_tw
        lda fs_kz
        sta spr_th
        lda fs_x
        sta bx
        lda fs_x+1
        sta bx+1
        lda fs_en
        asl
        asl
        asl
        sec
        sbc #1
        sta tmp
        lda fs_y
        sec
        sbc tmp
        sta by
        lda fs_y+1
        sbc #0
        sta by+1
        lda fs_po
        jsr spr_draw
        ; spr(po + la[jg]*16, x, y - cu, sm, ff, flip)
        lda fs_sm
        sta spr_tw
        lda fs_ff
        sta spr_th
        lda fs_x
        sta bx
        lda fs_x+1
        sta bx+1
        lda fs_y
        sec
        sbc fs_cu
        sta by
        lda fs_y+1
        sbc #0
        sta by+1
        lda fs_legs
        jsr spr_draw
        lda fs_p
        clc
        adc #5
        sta fs_p
        dec fs_n
        jmp fs_cl
fs_ov   jsr clip_reset
        ; overlays: n, dx, dy, w, h
        ldy fs_p
        lda (sp),y
        sta fs_n
        iny
        sty fs_p
fs_ol   lda fs_n
        beq fs_d
        ldy fs_p
        lda (sp),y
        sta fs_k
        iny
        lda (sp),y
        sta tmp             ; dx
        iny
        lda (sp),y
        sta tmp+1           ; dy
        iny
        lda (sp),y
        sta spr_tw
        iny
        lda (sp),y
        sta spr_th
        ; x: flip ? x + (sm - w)*8 - dx : x + dx
        lda spr_fx
        beq fs_ox
        lda fs_sm
        sec
        sbc spr_tw
        asl
        asl
        asl
        sec
        sbc tmp
        sta tmp
fs_ox   lda tmp
        ldy #0
        cmp #$80
        bcc fs_o1
        dey
fs_o1   clc
        adc fs_x
        sta bx
        tya
        adc fs_x+1
        sta bx+1
        lda tmp+1
        ldy #0
        cmp #$80
        bcc fs_o2
        dey
fs_o2   clc
        adc fs_y
        sta by
        tya
        adc fs_y+1
        sta by+1
        lda fs_k
        jsr spr_draw
        lda fs_p
        clc
        adc #5
        sta fs_p
        dec fs_n
        jmp fs_ol
fs_d    rts

; clip(fs_x + tmp, fs_y + tmp+1, tmp+2, tmp+3) in screen coordinates
; (the cart's clip ignores the camera)
fs_clip lda tmp
        ldy #0
        cmp #$80
        bcc fc_1
        dey
fc_1    clc
        adc fs_x
        sta rx0
        tya
        adc fs_x+1
        sta rx0+1
        lda tmp+1
        ldy #0
        cmp #$80
        bcc fc_2
        dey
fc_2    clc
        adc fs_y
        sta ry0
        tya
        adc fs_y+1
        sta ry0+1
        lda tmp+2
        sta rx1
        lda tmp+3
        sta ry1
; clip16(rx0, ry0 (signed 16), w = rx1, h = ry1)
clip16  lda rx0
        clc
        adc rx1
        sta tmp+4
        lda rx0+1
        adc #0
        sta tmp+5           ; x + w
        jsr c16_x0
        sta cx0
        lda tmp+4
        ldx tmp+5
        jsr c16_c
        sta cx1
        lda ry0
        clc
        adc ry1
        sta tmp+4
        lda ry0+1
        adc #0
        sta tmp+5
        lda ry0
        ldx ry0+1
        jsr c16_c
        sta cy0
        lda tmp+4
        ldx tmp+5
        jsr c16_c
        sta cy1
        rts
c16_x0  lda rx0
        ldx rx0+1
; clamp A:X (signed) to 0..128
c16_c   cpx #0
        beq cc_1
        bmi cc_0
        lda #128
        rts
cc_0    lda #0
        rts
cc_1    cmp #129
        bcc cc_2
        lda #128
cc_2    rts

fs_e    dta 0
fs_c    dta 0
fs_x    dta 0,0
fs_y    dta 0,0
fs_jg   dta 0
fs_gb   dta 0
fs_legs dta 0
fs_kz   dta 0
fs_cu   dta 0
fs_ff   dta 0
fs_sm   dta 0
fs_en   dta 0
fs_po   dta 0
fs_n    dta 0
fs_p    dta 0
fs_k    dta 0

; ------------------------------------------------------------------
; fo(p): projectiles
dr_fo    sty rt_e
        ; if p.es < 13 and hr(2, 1): skip (blinks)
        lda e_es,y
        cmp #13
        bcs fo_1
        lda frames
        and #2
        beq fo_r
fo_1    ; shadow is(p.x, p.y, 4, 1.2, 4, p.ll)
        lda e_xl,y
        sta bx
        lda e_xh,y
        sta bx+1
        lda e_yl,y
        sta by
        lda #0
        sta by+1
        ldx e_cls,y
        lda c_ll,x
        jsr vcol
        ldx #4
        jsr draw_shadow
        ; spr(p.dq, p.x - 4, p.y + p.z + p.dy)
        ldy rt_e
        ldx e_cls,y
        lda e_xl,y
        sec
        sbc #4
        sta bx
        lda e_xh,y
        sbc #0
        sta bx+1
        lda c_dy,x
        sta tmp
        lda e_yf,y
        clc
        adc e_zf,y
        lda e_yl,y
        adc e_zl,y
        sta by
        lda #0
        adc e_zh,y
        sta by+1
        lda tmp
        ldy #0
        cmp #$80
        bcc fo_2
        dey
fo_2    clc
        adc by
        sta by
        tya
        adc by+1
        sta by+1
        ldy rt_e
        ldx e_cls,y
        lda c_dq,x
        jmp spr1
fo_r    rts

; gt(s): blob shots and puddles
dr_gt    sty rt_e
        lda e_var,y
        tax
        lda gt_fg,x
        sta tmp+6
        lda gt_bg,x
        sta tmp+7
        lda e_zh,y
        bpl gt_g
        ; in the air: pset(x, y, 0); pset(x, y + z, fg)
        lda e_xl,y
        sta bx
        lda e_xh,y
        sta bx+1
        lda e_yl,y
        sta by
        lda #0
        sta by+1
        lda #0
        jsr pset
        ldy rt_e
        lda e_xl,y
        sta bx
        lda e_xh,y
        sta bx+1
        lda e_yf,y
        clc
        adc e_zf,y
        lda e_yl,y
        adc e_zl,y
        sta by
        lda #0
        adc e_zh,y
        sta by+1
        lda tmp+6
        jmp pset
gt_g    ; rectfill(x-2, y, x+2, y+1, bg); rectfill(x-1, y, x+1, y, fg):
        ; one blit of the pre-drawn puddle (SHADOW rows 40/44)
        lda e_xl,y
        sec
        sbc #2
        sta bx
        lda e_xh,y
        sbc #0
        sta bx+1
        lda e_yl,y
        sta by
        lda #0
        sta by+1
        sta bw+1
        sta bh+1
        sta bxor
        lda e_var,y
        asl
        asl
        asl                 ; 4 rows * 64 = 256 per variant
        clc
        adc #>(SHADOW+40*64)
        sta bsrc+1
        lda #<(SHADOW+40*64)
        sta bsrc
        lda #^SHADOW
        sta bsrc+2
        lda #5
        sta bw
        lda #2
        sta bh
        lda #1
        sta bssx
        sta bmode
        lda #6
        sta bssy
        lda #$ff
        sta band
        jmp blit_cam
gt_fg   dta 11,3
gt_bg   dta 3,1

; e_(b): explosion ring, faded by its age, inside the floor
dr_ex    sty rt_e
        ; ip(lg, min(b.t/4, 2)): frames/8
        lda e_th,y
        bne ex_2
        lda e_tl,y
        lsr
        lsr
        lsr
        beq ex_0
        cmp #2
        bcc ex_1
ex_2    lda #2
ex_1    clc
        adc #BK_LG
        asl
        asl
        asl
        asl
ex_0    sta dbank
        ; clip(0, 80, 127, 22)
        lda #0
        sta cx0
        lda #127
        sta cx1
        lda #80
        sta cy0
        lda #102
        sta cy1
        ldy rt_e
        lda e_xf,y
        sta el_x
        lda e_xl,y
        sta el_x+1
        lda e_xh,y
        sta el_x+2
        lda e_yl,y
        sta el_y
        lda #0
        sta el_y+1
        lda e_rf,y
        sta el_rx
        sta m_v
        lda e_ri,y
        sta el_rx+1
        sta m_v+1
        lda #84             ; ry = r * 0.33
        jsr mulf
        lda m_v
        sta el_ry
        lda m_v+1
        sta el_ry+1
        ldy rt_e
        lda e_wf,y
        sta el_w
        lda e_wi,y
        sta el_w+1
        lda e_oe,y
        jsr vcol
        jsr el_draw
        jmp clip_reset

; ------------------------------------------------------------------
; lb(c, v): the health box at the top (left: the hero, right: last hit)
t_lb    ldx dd
        ldy d_ent,x
        ; removal: c.nb and hr(6, 3) and c.t >= 41
        lda e_nb,y
        beq tl_hp
        jsr hr63
        ldy d_ent,x
        bcc tl_hp
        lda e_th,y
        bne tl_rm
        lda e_tl,y
        cmp #82
        bcc tl_hp
tl_rm   lda #0
        sta d_kind,x
        rts
tl_hp   ; v.hp = ej(v.hp, c.qg - c.pa): hp + (target - hp) * (1 - 0.857)
        lda e_cls,y
        tax
        lda c_qg,x
        sec
        sbc e_pal,y
        sta tmp+1
        lda #0
        sbc e_paf,y
        sta tmp             ; target 8.8 (qg - pa)
        lda tmp+1
        sbc #0
        sta tmp+1
        ldx dd
        lda d_b,x
        cmp #$ff
        bne tl_e
        ; first time: hp = target
        lda tmp
        sta d_c,x
        lda tmp+1
        sta d_b,x
        rts
tl_e    ; hp = target + (hp - target) * 0.857
        lda d_c,x
        sec
        sbc tmp
        sta m_v
        lda d_b,x
        sbc tmp+1
        sta m_v+1
        lda #219
        jsr mulf
        ldx dd
        lda m_v
        clc
        adc tmp
        sta d_c,x
        lda m_v+1
        adc tmp+1
        sta d_b,x
        rts

; C = 1 when hr(6, 3): frames % 12 < 6
hr63    lda fm12
        cmp #6
        bcc h63_y
        clc
        ldx dd
        rts
h63_y   sec
        ldx dd
        rts

dr_lb    sty lb_e
        ldx dd
        lda d_a,x
        sta lb_f
        lda e_nb,y
        beq lb_1
        jsr hr63
        bcc lb_1
        rts
lb_1    ; clip(0, 0, 128, 10)
        lda #0
        sta cx0
        sta cy0
        lda #128
        sta cx1
        lda #10
        sta cy1
        ; fs(re, f and 128 - sm*8 or 0, en*8 - 1 - ms, 1, "idle", f)
        ldy lb_e
        ldx e_cls,y
        lda #0
        sta fs_x
        sta fs_x+1
        lda lb_f
        beq lb_2
        lda c_sm,x
        asl
        asl
        asl
        eor #$ff
        sec
        adc #128
        sta fs_x
lb_2    lda c_en,x
        asl
        asl
        asl
        sec
        sbc #1
        sec
        sbc c_ms,x
        sta fs_y
        lda #0
        sta fs_y+1
        lda #1
        sta fs_jg
        lda #0
        sta fs_gb
        ; state "idle": not a state of any class -> the lw / lf layout
        lda e_st,y
        pha
        lda e_qn,y
        pha
        lda #S_IDLE
        sta e_st,y
        lda lb_f
        beq lb_q
        lda #$ff
        bne lb_q2
lb_q    lda #1
lb_q2   sta e_qn,y
        ldx lb_e
        jsr fs_draw
        ldy lb_e
        pla
        sta e_qn,y
        pla
        sta e_st,y
        jsr tb_reset
        ; the bars: bw = mid(qg, 21, 60)
        ldy lb_e
        ldx e_cls,y
        lda c_qg,x
        sta nu_n
        cmp #21
        bcs lb_3
        lda #21
lb_3    cmp #61
        bcc lb_4
        lda #60
lb_4    sta lb_bw
        ; qc = v.hp (8.8): integer part, clamp at 0
        ldx dd
        lda d_b,x
        bpl lb_5
        lda #0
lb_5    sta nu_qc
        lda #0
        sta nu_qc+1
        ldx #0
lb_bars stx lb_i
        lda lb_f
        beq lb_l
        lda #127
        sta nu_x1
        lda #128
        sec
        sbc lb_bw
        sta nu_x2
        jmp lb_b
lb_l    lda #0
        sta nu_x1
        lda lb_bw
        sec
        sbc #1
        sta nu_x2
lb_b    lda #0
        sta nu_x1+1
        sta nu_x2+1
        sta nu_y1+1
        sta nu_y2+1
        lda ss_y1,x
        sta nu_y1
        lda ss_y2,x
        sta nu_y2
        lda ss_c1,x
        sta nu_fg
        lda ss_c2,x
        sta nu_bg
        lda ss_nf,x
        sta nu_rm
        jsr nu_bar
        ldx lb_i
        inx
        cpx #3
        bne lb_bars
        ; print(h_, f and 128 - #h_*4 or 2, 11, 7), h_ = flr(max(hp+0.5,0)).."/"..qg
        ldx dd
        lda d_c,x
        clc
        adc #$80
        lda d_b,x
        adc #0
        bpl lb_6
        lda #0
lb_6    sta m_n
        lda #0
        sta m_n+1
        jsr fmt_u16
        txa
        tax
        ldy #0
lb_cp   lda numbuf,y
        sta strbuf,y
        beq lb_7
        iny
        bne lb_cp
lb_7    tya
        tax
        lda #'/'
        sta strbuf,x
        inx
        stx tmp+7
        ldy lb_e
        ldx e_cls,y
        lda c_qg,x
        sta m_n
        lda #0
        sta m_n+1
        jsr fmt_u16
        ldx tmp+7
        jsr num_cat
        stx tmp+7           ; length
        lda #<strbuf
        sta str_p
        lda #>strbuf
        sta str_p+1
        lda #11
        sta tx_y
        lda #0
        sta tx_y+1
        sta tx_x+1
        lda #2
        sta tx_x
        lda lb_f
        beq lb_8
        lda tmp+7
        asl
        asl
        eor #$ff
        sec
        adc #128
        sta tx_x
lb_8    lda #7
        jsr print
        ; spr(28, 16, 2)
        lda #16
        sta bx
        lda #2
        sta by
        lda #0
        sta bx+1
        sta by+1
        lda #28
        jsr spr1
        ; print(flr(eg.s_ * (1 + eg.charge/30)), 24, 3, 13)
        ldx eg
        lda e_s_,x
        sta tmp+4
        lda e_chg,x
        ldx #68
        jsr umul8
        ldx #4
lb_sh   lsr m_hi
        ror m_lo
        dex
        bne lb_sh
        inc m_hi
        lda m_lo
        sta tmp+5
        lda m_hi
        sta tmp+6
        lda tmp+4
        ldx tmp+5
        jsr umul8
        lda m_hi
        sta tmp+5
        lda tmp+4
        ldx tmp+6
        jsr umul8
        lda m_lo
        clc
        adc tmp+5
        sta m_n
        lda m_hi
        adc #0
        sta m_n+1
        jsr fmt_u16
        lda #<numbuf
        sta str_p
        lda #>numbuf
        sta str_p+1
        lda #24
        sta tx_x
        lda #3
        sta tx_y
        lda #0
        sta tx_x+1
        sta tx_y+1
        lda #13
        jmp print
lb_e    dta 0
lb_f    dta 0
lb_bw   dta 0
lb_i    dta 0
ss_y1   dta 11,11,12
ss_y2   dta 16,14,12
ss_c1   dta 2,8,8
ss_c2   dta 0,1,5
ss_nf   dta 0,1,1

; ------------------------------------------------------------------
; The health boxes are drawn into a buffer (VRAM $4f000, "framebuffer"
; 4) only when what they show changes; every frame copies it with one blit.
HUD_FB  = 4
hud_draw
        lda hud_done
        beq hd_go
        rts
hd_go   inc hud_done
        lda #0
        sta hs_dirty
        lda dd
        pha
        ; signature: per box (slots ascending): slot, entity, hp, hp frac >> 5,
        ; blink; then the hero's strength and charge
        ldy #0
        ldx #0
hs_l    lda d_kind,x
        cmp #R_LB
        bne hs_n
        stx dd
        txa
        jsr hs_put
        lda d_ent,x
        jsr hs_put
        lda d_b,x
        jsr hs_put
        lda d_c,x
        and #$e0
        jsr hs_put
        lda d_a,x
        sta hs_t
        lda d_ent,x
        tax
        lda e_nb,x
        beq hs_v
        sty hs_y
        jsr hr63
        ldy hs_y
        lda #0
        rol
hs_v    ora hs_t
        jsr hs_put
        ldx dd
hs_n    inx
        cpx #MAXD
        bne hs_l
        ldx eg
        lda e_s_,x
        jsr hs_put
        lda e_chg,x
        jsr hs_put
        lda #$ff
hs_f    cpy #16
        bcs hs_c
        jsr hs_put
        jmp hs_f
hs_c    lda hs_dirty
        beq hd_blit
        ; render the boxes into the buffer
        lda back_bank
        pha
        lda camx
        pha
        lda camx+1
        pha
        lda camy
        pha
        lda camy+1
        pha
        lda #HUD_FB
        sta back_bank
        lda #0
        sta camx
        sta camx+1
        sta camy
        sta camy+1
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
        lda #18
        sta bh
        jsr clip_reset
        jsr blit_fb
        ldx #0
hr_l    lda d_kind,x
        cmp #R_LB
        bne hr_n
        stx dd
        jsr tb_reset
        ldx dd
        ldy d_ent,x
        jsr dr_lb
        jsr clip_reset
        ldx dd
hr_n    inx
        cpx #MAXD
        bne hr_l
        pla
        sta camy+1
        pla
        sta camy
        pla
        sta camx+1
        pla
        sta camx
        pla
        sta back_bank
hd_blit jsr tb_reset
        lda #0
        sta bx
        sta bx+1
        sta by
        sta by+1
        sta bsrc
        sta bw+1
        sta bh+1
        sta bxor
        lda #$f0
        sta bsrc+1
        lda #4
        sta bsrc+2
        lda #128
        sta bw
        lda #18
        sta bh
        lda #1
        sta bssx
        sta bmode
        lda #7
        sta bssy
        lda #$ff
        sta band
        jsr blit_cam
        pla
        sta dd
        rts
; store A as signature byte Y (marks a change)
hs_put  cpy #16
        bcs hp_d
        cmp hud_sig,y
        beq hp_s
        sta hud_sig,y
        lda #1
        sta hs_dirty
hp_s    iny
hp_d    rts
hs_t    dta 0
hs_y    dta 0
hs_dirty dta 0

; ------------------------------------------------------------------
; ga(p, v): the combo counter
; visible when v.t < 30 or (hr(1.5) and p.jm > 0)
ga_vis  ldx dd
        lda d_th,x
        bne gv_1
        lda d_t,x
        cmp #30
        bcc gv_y
gv_1    lda fm3
        bne gv_n
        ldx eg
        lda e_jm,x
        beq gv_n
gv_y    sec
        rts
gv_n    clc
        rts

t_ga    jsr ga_vis
        bcc tg_d
        ; pz /= 2 (signed byte)
        ldx dd
        lda d_a,x
        cmp #$80
        ror
        bpl tg_s
        adc #0              ; round towards 0 like a division
tg_s    sta d_a,x
tg_d    rts

dr_ga    jsr ga_vis
        bcs ga_go
        rts
ga_go   ; gm(p.jm.." HIT", pz + 1.99, 32, 8)
        ldx eg
        lda e_jm,x
        sta m_n
        lda #0
        sta m_n+1
        jsr fmt_u16
        ldx #0
        jsr num_cat
        lda #<t_hit
        sta sp
        lda #>t_hit
        sta sp+1
        jsr str_cat
        lda #<strbuf
        sta str_p
        lda #>strbuf
        sta str_p+1
        ldx dd
        lda d_a,x
        clc
        adc #1
        sta tx_x
        ldy #0
        cmp #$80
        bcc ga_1
        dey
ga_1    sty tx_x+1
        lda #32
        sta tx_y
        lda #0
        sta tx_y+1
        lda #8
        jsr gm
        ; print("+"..p.jm, 32 - pz/4, 3, 5)
        lda #'+'
        sta strbuf
        ldx eg
        lda e_jm,x
        sta m_n
        lda #0
        sta m_n+1
        jsr fmt_u16
        ldx #1
        jsr num_cat
        lda #<strbuf
        sta str_p
        lda #>strbuf
        sta str_p+1
        ldx dd
        lda d_a,x
        cmp #$80
        ror
        cmp #$80
        ror
        sta tmp
        lda #32
        sec
        sbc tmp
        sta tx_x
        lda #0
        sta tx_x+1
        lda #3
        sta tx_y
        lda #5
        jmp print

; ------------------------------------------------------------------
; kr(b, v): the boss's shield flashes when it blocks a hit
t_kr    ldx dd
        lda d_t,x
        cmp #12
        bcc tk_d
        lda #0
        sta d_kind,x
tk_d    rts

dr_kr    sty rt_e
        ; p = v.t/2 - 3; ip(p < 0 and hf or lg, abs(p)): level = |t - 6| >> 1
        ldx dd
        lda d_t,x
        sec
        sbc #6
        bcs kr_lg
        eor #$ff
        adc #1
        lsr
        beq kr_0
        clc
        adc #BK_HF
        jmp kr_b
kr_lg   lsr
        beq kr_0
        cmp #5
        bcc kr_l
        lda #4
kr_l    clc
        adc #BK_LG
kr_b    asl
        asl
        asl
        asl
        sta dbank
kr_0    ldx #3
kr_lp   stx kr_i
        ldy rt_e
        lda e_xl,y
        clc
        adc kr_dx,x
        sta bx
        lda e_xh,y
        adc kr_dxh,x
        sta bx+1
        lda e_yf,y
        clc
        adc e_zf,y
        lda e_yl,y
        adc e_zl,y
        sta tmp
        lda #0
        adc e_zh,y
        sta tmp+1
        lda tmp
        clc
        adc kr_dy,x
        sta by
        lda tmp+1
        adc #$ff
        sta by+1
        lda #1
        sta spr_tw
        lda #2
        sta spr_th
        lda kr_fx,x
        sta spr_fx
        lda kr_fy,x
        sta spr_fy
        lda #170
        jsr spr_draw
        ldx kr_i
        dex
        bpl kr_lp
        rts
kr_i    dta 0
kr_dx   dta <(-20),12,<(-20),12
kr_dxh  dta $ff,0,$ff,0
kr_dy   dta <(-31),<(-31),<(-15),<(-15)
kr_fx   dta 0,1,0,1
kr_fy   dta 0,0,1,1
