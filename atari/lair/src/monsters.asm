; ------------------------------------------------------------------
; Monsters, projectiles and explosions.
; ------------------------------------------------------------------

; nr(m): gf of the melee monsters
h_nr    jsr gc_brain
        ldx self
        cpx ei
        bne nr_d
        lda #CB_DU
        jsr call_cb
nr_d    clc
        rts

; gc(m): the common monster brain
gc_brain
        jsr cn_front
        ; m.od = ns(m, m.nj)
        jsr ns_move
        ldx self
        sta e_od,x
        ; if m.od and mc(0.05) or not m.nj then m:du()
        lda e_njon,x
        beq gcb_du
        lda e_od,x
        beq gcb_1
        lda #13
        jsr chance_c
        bcc gcb_1
gcb_du   ldx self
        lda #CB_DU
        jsr call_cb
gcb_1    ; m.qn = sgn(eg.x - m.x)
        ldx self
        ldy eg
        lda e_xf,y
        cmp e_xf,x
        lda e_xl,y
        sbc e_xl,x
        lda e_xh,y
        sbc e_xh,x
        bmi gcb_l
        lda #1
        bne gcb_q
gcb_l    lda #$ff
gcb_q    sta e_qn,x
        ; fp(m, m.nq, "player", "radar")
        ldy e_cls,x
        lda c_nq,y
        ldx #G_PLAYER
        ldy #3
        jsr attack
        jmp kk_move

; cn(): the front attacker ei is a monster in state gf
cn_front
        ldx ei
        cpx #MAXE
        bcs cn_pick
        lda e_cls,x
        beq cn_pick
        lda #G_MONSTER
        jsr in_group
        bcc cn_pick
        ldx ei
        lda e_st,x
        cmp #S_GF
        beq cn_d
cn_pick ; count the monsters in gf, pick one at random
        lda #0
        sta tmp+2
        ldx ent_top
        dex
        bmi cn_d
cn_c    lda #G_MONSTER
        jsr in_group
        bcc cn_cn
        lda e_st,x
        cmp #S_GF
        bne cn_cn
        inc tmp+2
cn_cn   dex
        bpl cn_c
        lda tmp+2
        beq cn_d
        jsr rnd_mul
        sta tmp+3
        ldx ent_top
        dex
cn_f    lda #G_MONSTER
        jsr in_group
        bcc cn_fn
        lda e_st,x
        cmp #S_GF
        bne cn_fn
        lda tmp+3
        beq cn_got
        dec tmp+3
cn_fn   dex
        bpl cn_f
        rts
cn_got  stx ei
cn_d    rts

; ns(m, t): move towards the target; A = 1 when arrived (within 2)
ns_move ldx self
        lda e_njon,x
        bne ns_1
        lda #0
        rts
ns_1    jsr vec_nj
        jsr vnorm
        lda nv_d+1
        cmp #2
        bcs ns_go
        ldx self
        lda #0
        sta e_gjon,x
        lda #1
        rts
ns_go   ; dx, dy = ho(m, t, m.sw); ru(m, dx, dy*0.666)
        ldx self
        ldy e_cls,x
        lda c_sw_lo,y
        sta ho_s
        lda c_sw_hi,y
        sta ho_s+1
        jsr ho_scale
        lda ho_vx
        sta mv_dx
        lda ho_vx+1
        sta mv_dx+1
        lda ho_vy
        sta m_v
        lda ho_vy+1
        sta m_v+1
        lda #171            ; * 0.666
        jsr mulf
        lda m_v
        sta mv_dy
        lda m_v+1
        sta mv_dy+1
        jsr ru_move
        lda #0
        rts

; vector from entity X to its target -> nv_dx, nv_dy
vec_nj  lda e_njxf,x
        sec
        sbc e_xf,x
        sta nv_dx
        lda e_njxl,x
        sbc e_xl,x
        sta nv_dx+1
        lda e_njxh,x
        sbc e_xh,x
        sta nv_dx+2
        lda e_njyf,x
        sec
        sbc e_yf,x
        sta nv_dy
        lda e_njyl,x
        sbc e_yl,x
        sta nv_dy+1
        lda #0
        sbc #0
        sta nv_dy+2
        rts

; fh(m): du - the front attacker stands next to the hero, the others
; below him (the cart's angle is nil: sin = 0, cos = 1)
h_fh    ldx self
        ldy eg
        lda #1
        sta e_njon,x
        cpx ei
        bne fh_o
        ; nj = g_(eg, -m.qn*12)
        lda e_xf,y
        sta e_njxf,x
        lda e_qn,x
        bmi fh_r
        lda e_xl,y
        sec
        sbc #12
        sta e_njxl,x
        lda e_xh,y
        sbc #0
        sta e_njxh,x
        jmp fh_y
fh_r    lda e_xl,y
        clc
        adc #12
        sta e_njxl,x
        lda e_xh,y
        adc #0
        sta e_njxh,x
fh_y    lda e_yf,y
        sta e_njyf,x
        lda e_yl,y
        sta e_njyl,x
        jmp fh_clamp
fh_o    ; d = ij(m, eg); nj = (eg.x, eg.y + d*0.25)
        jsr dist            ; X = m, Y = eg
        ldx self
        ldy eg
        lda e_xf,y
        sta e_njxf,x
        lda e_xl,y
        sta e_njxl,x
        lda e_xh,y
        sta e_njxh,x
        lda nv_d+1
        lsr
        sta tmp
        lda nv_d
        ror
        lsr tmp
        ror                 ; d/4 (8.8)
        clc
        adc e_yf,y
        sta e_njyf,x
        lda e_yl,y
        adc tmp
        bcc fh_y1
        lda #255
fh_y1   sta e_njyl,x
fh_clamp
        ; l_(m.nj): x 0..127, y 80..101
        lda e_njxh,x
        bmi fhc_0
        bne fhc_1
        lda e_njxl,x
        bpl fhc_y
fhc_1   lda #127
        sta e_njxl,x
        lda #0
        sta e_njxh,x
        sta e_njxf,x
        jmp fhc_y
fhc_0   lda #0
        sta e_njxl,x
        sta e_njxh,x
        sta e_njxf,x
fhc_y   lda e_njyl,x
        cmp #80
        bcs fhc_2
        lda #80
        sta e_njyl,x
        lda #0
        sta e_njyf,x
        clc
        rts
fhc_2   cmp #101
        bcc fhc_d
        lda #101
        sta e_njyl,x
        lda #0
        sta e_njyf,x
fhc_d   clc
        rts

; pq(gx): random position x = 1..126 (or pq_x when pq_xs), y = 81..100
; -> pq_xl/xh, pq_yl (fractions in pq_xf, pq_yf)
pq_rand jsr rnd8
        sta pq_xf
        lda #125
        jsr rnd_mul
        clc
        adc #1
        sta pq_xl
        lda #0
        sta pq_xh
        jsr rnd8
        sta pq_yf
        lda #19
        jsr rnd_mul
        clc
        adc #81
        sta pq_yl
        rts
pq_xf   dta 0
pq_xl   dta 0
pq_xh   dta 0
pq_yf   dta 0
pq_yl   dta 0

; iq(m): du of the spitters: a random spot on the far side
h_iq    jsr pq_rand
        ldx self
        ; x = (qn > 0 and 30 or 97) + im0(25)
        lda #50
        jsr rnd_mul
        sec
        sbc #25
        ldx self
        ldy e_qn,x
        bmi iq_r
        clc
        adc #30
        jmp iq_s
iq_r    clc
        adc #97
iq_s    sta e_njxl,x
        lda #0
        sta e_njxh,x
        lda pq_xf
        sta e_njxf,x
        lda pq_yl
        sta e_njyl,x
        lda pq_yf
        sta e_njyf,x
        lda #1
        sta e_njon,x
        clc
        rts

; hg(m): C = 1 when abs(m.x - 64) < 60 (on screen)
hg_test ldx self
        lda e_xh,x
        bne hg_n
        lda e_xl,x
        cmp #5
        bcc hg_4
        cmp #124
        bcc hg_y
        bne hg_n
        lda e_xf,x          ; 124 + fraction: |x-64| >= 60
        bne hg_n
        clc
        rts
hg_4    cmp #4
        bne hg_n
        lda e_xf,x          ; 4.x: > 4 when there is a fraction
        beq hg_n
hg_y    sec
        rts
hg_n    clc
        rts

; C = 1 with probability frames * A / 65536 (state time based chances)
chance_tm
        ldx self
        tay
        lda e_tl,x
        sta m_s
        lda e_th,x
        sta m_t
        ; m_n = tm_frames * A (16 bit, saturating)
        tya
        ldx m_s
        jsr umul8
        lda m_lo
        sta m_n
        lda m_hi
        sta m_n+1
        lda m_t
        beq ct_1
        tya
        ldx m_t
        jsr umul8
        lda m_hi
        bne ct_sat
        lda m_lo
        clc
        adc m_n+1
        sta m_n+1
        bcc ct_1
ct_sat  lda #$ff
        sta m_n
        sta m_n+1
ct_1    jmp chance16

; on(m, tm): gf of the spitters
h_on    jsr gc_brain
        ldx self
        lda e_od,x
        beq on_1
        lda #CB_DU
        jsr call_cb
on_1    ; mc(0.0015*tm) and hg(m): 0.00075 per frame -> 49/65536
        lda #49
        jsr chance_tm
        bcc on_d
        jsr hg_test
        bcc on_d
        ; m.rg = g_(eg); lp(m, "ln")
        ldx self
        ldy eg
        lda e_xf,y
        sta e_rgxf,x
        lda e_xl,y
        sta e_rgxl,x
        lda e_xh,y
        sta e_rgxh,x
        lda e_yf,y
        sta e_rgyf,x
        lda e_yl,y
        sta e_rgyl,x
        lda #S_LN
        ldy #$ff
        jsr set_state
on_d    clc
        rts

; lt(m, tm): ln of the spitters - spit bd shots for five frames
h_lt    ldx self
        lda e_th,x
        bne lt_2
        lda e_tl,x
        cmp #30
        bcc lt_2
        cmp #35
        bcs lt_2
        ldy e_cls,x
        lda c_bd,y
        sta lt_n
lt_l    jsr lt_shot
        dec lt_n
        bne lt_l
lt_2    lda #32             ; tm == 16
        jsr tm_eq
        bne lt_3
        ldx self
        ldy e_cls,x
        lda c_ce,y
        jsr kl
lt_3    lda #64             ; kb(tm == 32, m, "gf")
        jsr tm_eq
        bne lt_d
        ldx self
        lda #S_GF
        ldy #$ff
        jsr set_state
lt_d    clc
        rts
lt_n    dta 0

lt_shot ldx self
        ldy e_cls,x
        lda c_cq,y
        jsr ent_new
        bcc ls_ok
        rts
ls_ok   stx ls_e
        ldy self
        jsr copy_pos
        ; x += m.qn*4 + im0(fm), y += dy = im0(fm*0.75)
        ldy self
        lda e_cls,y
        tay
        lda c_fm,y
        sta tmp+4
        asl
        jsr rnd_mul         ; 0 .. 2fm
        sec
        sbc tmp+4           ; -fm .. fm
        ldy self
        ldx e_qn,y
        bmi ls_l
        clc
        adc #4
        jmp ls_x
ls_l    sec
        sbc #4
ls_x    ldx ls_e
        jsr ex_add8
        ; dy = im0(fm*0.75): -0.75fm .. 0.75fm (8.8)
        lda tmp+4
        ldx #192
        jsr umul8           ; fm*0.75 (8.8 in m_hi:m_lo... *192/256)
        lda m_lo
        sta m_v
        lda m_hi
        sta m_v+1
        asl m_v
        rol m_v+1           ; 2 * 0.75fm
        jsr rnd_v
        lda tmp+4
        ldx #192
        jsr umul8
        lda m_v
        sec
        sbc m_lo
        sta m_v
        lda m_v+1
        sbc m_hi
        sta m_v+1           ; dy (signed 8.8)
        ldx ls_e
        lda e_yf,x
        clc
        adc m_v
        sta e_yf,x
        lda e_yl,x
        adc m_v+1
        sta e_yl,x
        ; colours: dy > 0 -> 1 (fg 3, bg 1) else 0 (fg 11, bg 3)
        lda #0
        ldy m_v+1
        bmi ls_c
        lda m_v
        ora m_v+1
        beq ls_c
        lda #1
ls_c    sta e_var,x
        ; z = -im(8, 12)
        jsr rnd8
        sta tmp
        lda #4
        jsr rnd_mul
        clc
        adc #8
        ldx ls_e
        eor #$ff            ; -(8..11) - fraction
        sta e_zl,x
        lda tmp
        eor #$ff
        sta e_zf,x
        lda #$ff
        sta e_zh,x
        ; drawable: bh -> gt, else fo
        lda e_cls,x
        cmp #C_BH
        bne ls_fo
        lda #R_GT
        bne ls_dr
ls_fo   lda #R_FO
ls_dr   ldy #$ff
        jsr draw_new
        ; sp.vz = m.nk * ni(m, m.rg, sp, mz, cr)
        ldx self
        ldy e_cls,x
        lda c_mz,y
        sta ni_f
        lda c_cr,y
        sta ni_cap
        ; vector m -> rg
        lda e_rgxf,x
        sec
        sbc e_xf,x
        sta nv_dx
        lda e_rgxl,x
        sbc e_xl,x
        sta nv_dx+1
        lda e_rgxh,x
        sbc e_xh,x
        sta nv_dx+2
        lda e_rgyf,x
        sec
        sbc e_yf,x
        sta nv_dy
        lda e_rgyl,x
        sbc e_yl,x
        sta nv_dy+1
        lda #0
        sbc #0
        sta nv_dy+2
        lda ls_e
        sta ni_e
        jsr ni_lob
        ; vz = nk * pw
        ldx self
        ldy e_cls,x
        lda ni_pw
        sta m_v
        lda ni_pw+1
        sta m_v+1
        lda c_nk_hi,y
        cmp #$ff
        bne ls_h
        lda c_nk_lo,y
        bne ls_h            ; -0.5
        jsr neg_v           ; -1
        jmp ls_vz
ls_h    lda m_v+1           ; -0.5
        lsr
        sta m_v+1
        ror m_v
        jsr neg_v
ls_vz   ldx ls_e
        lda m_v
        sta e_vzf,x
        lda m_v+1
        sta e_vzl,x
        rts
ls_e    dta 0

; x of entity X += signed A
ex_add8 ldy #0
        cmp #$80
        bcc ea_1
        dey
ea_1    sty tmp
        clc
        adc e_xl,x
        sta e_xl,x
        lda e_xh,x
        adc tmp
        sta e_xh,x
        rts

; ni(m, p, s, mq, jo, jx): the lob speed for a shot.  nv_dx/nv_dy = vector
; from m to the target, ni_f = the factor (fraction), ni_cap (0 = none),
; ni_e = the shot.  pw = mid(sqrt(dist) * f * 0.5, 0.7, cap);
; shot v = unit * pw (|vx| >= 0.07 in the direction m faces)
ni_lob  jsr vnorm
        ; sqrt(dist) in 4.4 from the integer distance -> 8.8 (<< 4)
        ldx nv_d+1
        lda sqrt44,x
        sta m_v
        lda #0
        sta m_v+1
        asl m_v
        rol m_v+1
        asl m_v
        rol m_v+1
        asl m_v
        rol m_v+1
        asl m_v
        rol m_v+1
        lda ni_f
        jsr mulf
        lsr m_v+1           ; * 0.5
        ror m_v
        ; mid(pw, 0.7, cap)
        lda m_v+1
        bne ni_c
        lda m_v
        cmp #179
        bcs ni_c
        lda #179
        sta m_v
ni_c    lda ni_cap
        beq ni_s
        cmp m_v+1
        beq ni_c2
        bcs ni_s
ni_c2   sta m_v+1           ; cap (integer)
        lda #0
        sta m_v
ni_s    lda m_v
        sta ni_pw
        sta ho_s
        lda m_v+1
        sta ni_pw+1
        sta ho_s+1
        jsr ho_scale
        ldx ni_e
        lda ho_vx
        sta e_vxf,x
        lda ho_vx+1
        sta e_vxl,x
        lda ho_vy
        sta e_vyf,x
        lda ho_vy+1
        sta e_vyl,x
        ; if abs(vx) < 0.07 then vx = 0.07 * m.qn
        lda ho_vx
        ldy ho_vx+1
        jsr abs88
        cpy #0
        bne ni_d
        cmp #18
        bcs ni_d
        ldy self
        lda e_qn,y
        bmi ni_n
        lda #18
        sta e_vxf,x
        lda #0
        sta e_vxl,x
        rts
ni_n    lda #<(-18)
        sta e_vxf,x
        lda #$ff
        sta e_vxl,x
ni_d    rts
ni_f    dta 0
ni_cap  dta 0
ni_e    dta 0
ni_pw   dta 0,0

; ey(m, tm): gf of the elder
h_ey    jsr gc_brain
        ldx self
        ldy eg
        jsr dist
        ldx self
        lda nv_d+1
        cmp #30
        bcs ey_far
        ; m.df += 0.5; kb(mc(m.df/130), m, "ln", 50)
        lda e_df,x
        cmp #255
        beq ey_1
        inc e_df,x
ey_1    lda e_df,x          ; df/130 = frames/260 ~ frames/256
        jsr chance_c
        bcc ey_d
        ldx self
        lda #S_LN
        ldy #50
        jsr set_state
        clc
        rts
ey_far  lda #0
        sta e_df,x
        ; kb(mc(tm/5000) and hg(m), m, "j_", 49): frames/10000 -> 7/65536
        lda #7
        jsr chance_tm
        bcc ey_d
        jsr hg_test
        bcc ey_d
        ldx self
        lda #S_J_
        ldy #49
        jsr set_state
ey_d    clc
        rts

; iz(m): when m.t == 0.5: charge particles and the anchor position
iz_start
        lda #1
        jsr tm_eq
        bne iz_d
        lda #0
        sta lr_dx
        lda #2
        sta lr_dy
        lda #<(-16)
        sta lr_dz
        lda #15
        sta lr_r
        lda #7
        sta lr_oe
        ldx self
        jsr lr_start
        ldx self
        sta e_ku,x
        tya
        sta e_kug,x
        ; po = g_(m)
        lda e_xf,x
        sta e_rgxf,x
        lda e_xl,x
        sta e_rgxl,x
        lda e_xh,x
        sta e_rgxh,x
        lda e_yf,x
        sta e_rgyf,x
        lda e_yl,x
        sta e_rgyl,x
iz_d    rts

; lc(m, tm): j_ - throws two rocks
h_lc    jsr iz_start
        lda #40             ; tm == 20
        jsr tm_eq
        jne lc_d
        ; m.vx -= m.qn*2.5
        ldx self
        lda e_qn,x
        bmi lc_l
        lda e_vxf,x
        sec
        sbc #$80
        sta e_vxf,x
        lda e_vxl,x
        sbc #2
        sta e_vxl,x
        jmp lc_r
lc_l    lda e_vxf,x
        clc
        adc #$80
        sta e_vxf,x
        lda e_vxl,x
        adc #2
        sta e_vxl,x
lc_r    lda #0
        sta lc_i
lc_l2   lda #C_LZ
        jsr ent_new
        bcs lc_n
        stx ni_e
        ldy self
        jsr copy_pos
        inc e_yl,x
        lda #<(-16)
        sta e_zl,x
        lda #$ff
        sta e_zh,x
        lda #$80
        sta e_vzf,x
        lda #$ff
        sta e_vzl,x
        lda #100
        sta e_es,x
        lda #R_FO
        ldy #$ff
        jsr draw_new
        ; ni(m, eg, db, 0.45+pw, 0.6+pw): pw = 0.15, 0.30
        ldx self
        ldy eg
        jsr vec_xy
        ldx lc_i
        lda lc_f0,x
        sta tmp
        lda #38             ; range 0.15
        jsr rnd_mul
        clc
        adc tmp
        sta ni_f
        lda #0
        sta ni_cap
        jsr ni_lob
lc_n    inc lc_i
        lda lc_i
        cmp #2
        bne lc_l2
        ldx self
        lda #S_GF
        ldy #$ff
        jsr set_state
lc_d    clc
        rts
lc_i    dta 0
lc_f0   dta 154,192         ; 0.6, 0.75

; mb(m, tm): ln of the elder - shakes, then a blast
h_mb    jsr iz_start
        ; bj(m, g_(m.po, im0(tm/9), im0(tm/9)))
        ldx self
        lda e_tl,x
        ldy #57             ; tm/9 = frames/18: frames * 14.2 / 256 -> 2*amp in 8.8
        ldx #28
        jsr umul8           ; frames * 28 = 2*tm/9 * 256
        lda m_lo
        sta tmp+4
        lda m_hi
        sta tmp+5           ; range (8.8)
        jsr mb_off
        ldx self
        lda e_rgxf,x
        clc
        adc m_v
        sta e_xf,x
        lda e_rgxl,x
        adc m_v+1
        sta e_xl,x
        lda m_v+1
        and #$80
        beq mb_1
        lda #$ff
mb_1    adc e_rgxh,x
        sta e_xh,x
        jsr mb_off
        ldx self
        lda e_rgyf,x
        clc
        adc m_v
        sta e_yf,x
        lda e_rgyl,x
        adc m_v+1
        sta e_yl,x
        lda #40             ; tm > 20
        jsr tm_gt
        bcc mb_k
        ldx self
        lda #0
        sta kx_dx
        lda #KX_MB
        jsr explode
        ldx self
        lda #S_GF
        ldy #$ff
        jsr set_state
mb_k    jsr kk_move
        clc
        rts
; m_v = rnd(range) - range/2
mb_off  lda tmp+4
        sta m_v
        lda tmp+5
        sta m_v+1
        jsr rnd_v
        lda tmp+5
        lsr
        sta tmp+7
        lda tmp+4
        ror
        sta tmp+6
        lda m_v
        sec
        sbc tmp+6
        sta m_v
        lda m_v+1
        sbc tmp+7
        sta m_v+1
        rts

; hd(m, tm): ln of the melee monsters - wind up, then lunge
h_hd    ldx self
        lda #0
        sta e_gjon,x
        jsr kk_move
        ldx self
        ldy e_cls,x
        lda c_mj,y
        asl
        jsr tm_ge
        bcc hd_d
        ldx self
        lda e_axf,x
        sta e_vxf,x
        lda e_axl,x
        sta e_vxl,x
        lda e_ayf,x
        sta e_vyf,x
        lda e_ayl,x
        sta e_vyl,x
        lda #CB_KC
        jsr call_cb
        ldx self
        ldy e_cls,x
        lda c_li,y
        tay
        lda #S_HC
        jsr set_state
hd_d    clc
        rts

; r_(m, tm): hc of the melee monsters
h_r_    jsr kk_move
        ldx self
        ldy e_cls,x
        lda c_mh,y
        asl
        jsr tm_ge
        bcs r_1
        ldx self
        ldy e_cls,x
        lda c_cj,y
        ldx #G_PLAYER
        ldy #0
        jsr attack
r_1     ldx self
        ldy e_cls,x
        lda c_rn,y
        asl
        jsr tm_gt
        bcc r_d
        ldx self
        lda #S_GF
        ldy #$ff
        jsr set_state
r_d     clc
        rts

; si(m, p): hit_radar - the hero is in reach: aim and wind up
h_si    ldx self
        ldy e_cls,x
        lda c_bf_lo,y
        sta ho_s
        lda c_bf_hi,y
        sta ho_s+1
        ldy other
        jsr ho_vec
        ldx self
        lda ho_vx
        sta e_axf,x
        lda ho_vx+1
        sta e_axl,x
        lda ho_vy
        sta e_ayf,x
        lda ho_vy+1
        sta e_ayl,x
        lda e_st,x
        cmp #S_QI
        beq si_d
        lda #S_LN
        ldy #$ff
        jsr set_state
si_d    rts

; cc(s): kc of the stone golem - steps forward, shock wave in front
h_cc    ldx self
        lda e_qn,x
        asl
        asl
        asl                 ; qn*8
        jsr ex_add8
        ldx self
        lda e_qn,x
        bmi cc_l
        lda #20
        bne cc_x
cc_l    lda #<(-20)
cc_x    sta kx_dx
        lda #KX_CC
        jsr explode
        clc
        rts

; hm(w, tm): gf of the wraith
h_hm    ldx self
        lda e_ih,x
        cmp #$ff
        bne hmw_1
        ; w.ih = pm({jw=0, ml=1, ja=0.6, cs=0.03, bp=1}, 0, fi(w, -10, ...))
        lda #T_AURA
        jsr ps_new
        bcs hmw_1
        lda #EM_FI
        sta ps_kind,x
        lda #FI_AURA
        sta ps_a,x
        lda self
        sta ps_own,x
        lda #<(-10)
        sta ps_b,x
        lda #1
        sta ps_c,x
        lda #0
        sta ps_d,x
        lda #$ff
        sta ps_e,x
        txa
        ldx self
        sta e_ih,x
        tay
        lda ps_gen,y
        sta e_ihg,x
hmw_1    ; if mc(tm*0.0003): teleport by the hero
        lda #10
        jsr chance_tm
        bcc hmw_nr
        ldx self
        lda #1
        sta e_rs,x
        lda #S_OK
        ldy #32
        jsr set_state
        clc
        rts
hmw_nr   jmp h_nr

; ou(c, tm): ok - teleport
h_ou    ldx self
        ; tm < 7 or tm > 14: gb = {hf, 7 - tm%14}, else {lg, tm - 7}
        lda e_th,x
        bne ou_hf
        lda e_tl,x
        cmp #14
        bcc ou_hf
        cmp #29
        bcs ou_hf
        ; lg level = flr(tm - 7) = (frames - 14) >> 1
        sec
        sbc #14
        lsr
        jsr ou_lvl
        beq ou_g0
        clc
        adc #BK_LG
        jmp ou_g
ou_hf   ; n*2 = 14 - (frames mod 28); level = flr(n)
        ldx #28
        jsr ou_mod
        sta tmp
        lda #14
        sec
        sbc tmp
        bcc ou_g0
        lsr
        jsr ou_lvl
        beq ou_g0
        clc
        adc #BK_HF
        jmp ou_g
ou_g0   lda #0
ou_g    ldx self
        sta e_gbt,x
        ; tm == 14: move
        lda #28
        jsr tm_eq
        bne ou_2
        ldx self
        lda e_rs,x
        beq ou_pq
        ; g_(eg, ho(w, eg, 25))
        lda #0
        sta ho_s
        lda #25
        sta ho_s+1
        ldy eg
        jsr ho_vec
        ldx self
        ldy eg
        lda e_xf,y
        clc
        adc ho_vx
        sta e_xf,x
        lda e_xl,y
        adc ho_vx+1
        sta e_xl,x
        lda ho_vx+1
        and #$80
        beq ou_3
        lda #$ff
ou_3    adc e_xh,y
        sta e_xh,x
        lda e_yf,y
        clc
        adc ho_vy
        sta e_yf,x
        lda e_yl,y
        adc ho_vy+1
        sta e_yl,x
        jmp ou_2
ou_pq   jsr pq_rand
        ldx self
        lda pq_xf
        sta e_xf,x
        lda pq_xl
        sta e_xl,x
        lda pq_xh
        sta e_xh,x
        lda pq_yf
        sta e_yf,x
        lda pq_yl
        sta e_yl,x
ou_2    lda #42             ; kb(tm == 21, c, "gf")
        jsr tm_eq
        bne ou_4
        ldx self
        lda #S_GF
        ldy #$ff
        jsr set_state
ou_4    jsr kk_move
        clc
        rts
; A = state frames mod X
ou_mod  stx tmp+1
        ldx self
        lda e_th,x
        sta m_n+1
        lda e_tl,x
        sta m_n
        ldx tmp+1
        jmp mod8
; palette level: flr(min(n, 4)) for n >= 1 (A = n, integer) -> A (0 = none)
ou_lvl  cmp #5
        bcc ol_1
        lda #4
ol_1    cmp #0
        rts

; oi(m, tm): lx - parried, seeing stars
h_oi    lda #2              ; tm == 1
        jsr tm_eq
        bne oi_1
        lda #T_STAR
        jsr ps_new
        bcs oi_1
        lda #EM_FI
        sta ps_kind,x
        lda #FI_STAR
        sta ps_a,x
        lda self
        sta ps_own,x
        ; z = -m.en*8 - 2, y + 1, no owner z
        ldy self
        lda e_cls,y
        tay
        lda c_en,y
        asl
        asl
        asl
        clc
        adc #2
        eor #$ff
        clc
        adc #1
        sta ps_b,x
        lda #0
        sta ps_c,x
        lda #1
        sta ps_d,x
        lda #$ff
        sta ps_e,x
        txa
        ldx self
        sta e_ku,x
        tay
        lda ps_gen,y
        sta e_kug,x
oi_1    jsr kk_move
        ; kb(tm > m.rn + 10, m, "gf")
        ldx self
        ldy e_cls,x
        lda c_rn,y
        clc
        adc #10
        asl
        jsr tm_gt
        bcc oi_d
        ldx self
        lda #S_GF
        ldy #$ff
        jsr set_state
oi_d    clc
        rts

; ds(m, tm): gf of the flame imp - waits until it is on screen
h_ds    lda #164            ; mc(0.005*tm): frames * 0.0025
        jsr chance_tm
        bcs ds_go
        jsr hg_test
        bcc ds_d
ds_go   ldx self
        lda #0
        sta e_mf,x          ; mx/my not set yet
        lda #S_SF
        ldy #56
        jsr set_state
ds_d    clc
        rts

; gy(m): sf - chases the hero
h_gy    ldx self
        ldy e_cls,x
        lda c_sw_lo,y
        sta ho_s
        lda c_sw_hi,y
        sta ho_s+1
        ldy eg
        jsr ho_vec
        ldx self
        lda e_mf,x
        bne gy_e
        lda #1
        sta e_mf,x
        lda ho_vx
        sta e_mxf,x
        lda ho_vx+1
        sta e_mxl,x
        lda ho_vy
        sta e_myf,x
        lda ho_vy+1
        sta e_myl,x
        jmp gy_m
gy_e    ; mx = dx + (mx - dx) * 0.857
        lda e_mxf,x
        sec
        sbc ho_vx
        sta m_v
        lda e_mxl,x
        sbc ho_vx+1
        sta m_v+1
        lda #219
        jsr mulf
        ldx self
        lda m_v
        clc
        adc ho_vx
        sta e_mxf,x
        lda m_v+1
        adc ho_vx+1
        sta e_mxl,x
        lda e_myf,x
        sec
        sbc ho_vy
        sta m_v
        lda e_myl,x
        sbc ho_vy+1
        sta m_v+1
        lda #219
        jsr mulf
        ldx self
        lda m_v
        clc
        adc ho_vy
        sta e_myf,x
        lda m_v+1
        adc ho_vy+1
        sta e_myl,x
gy_m    ; qn = sgn(mx); ru(m, mx, my)
        lda e_mxl,x
        bmi gy_l
        lda #1
        bne gy_q
gy_l    lda #$ff
gy_q    sta e_qn,x
        lda e_mxf,x
        sta mv_dx
        lda e_mxl,x
        sta mv_dx+1
        lda e_myf,x
        sta mv_dy
        lda e_myl,x
        sta mv_dy+1
        jsr ru_move
        jsr kk_move
        ; if ij(m, eg) < 16: pounce
        ldx self
        ldy eg
        jsr dist
        lda nv_d+1
        cmp #16
        bcs gy_d
        ldx self
        ; v = m * 2.5
        lda e_mxf,x
        sta m_v
        lda e_mxl,x
        sta m_v+1
        jsr x25
        ldx self
        lda m_v
        sta e_vxf,x
        lda m_v+1
        sta e_vxl,x
        lda e_myf,x
        sta m_v
        lda e_myl,x
        sta m_v+1
        jsr x25
        ldx self
        lda m_v
        sta e_vyf,x
        lda m_v+1
        sta e_vyl,x
        lda #S_NX
        ldy #56
        jsr set_state
gy_d    clc
        rts
; m_v *= 2.5
x25     lda m_v
        sta tmp
        lda m_v+1
        sta tmp+1
        asl m_v
        rol m_v+1
        lda tmp+1
        cmp #$80
        ror tmp+1
        ror tmp
        lda m_v
        clc
        adc tmp
        sta m_v
        lda m_v+1
        adc tmp+1
        sta m_v+1
        rts

; ca(m, tm): nx - the pounce
h_ca    jsr kk_move
        lda #2
        ldx #G_PLAYER
        ldy #0
        jsr attack
        ; kb(tm > im(35, 65), m, "sf")
        lda #60
        jsr rnd_mul
        clc
        adc #70
        jsr tm_gt
        bcc ca_d
        ldx self
        lda #S_SF
        ldy #$ff
        jsr set_state
ca_d    clc
        rts

; ky(c, tm): gf of the crystals
h_ky    lda #4              ; mc(tm/8000): frames/16000
        jsr chance_tm
        bcs ky_ok
        ; t - c.b_ < 10
        ldx self
        lda frames
        sec
        sbc e_bl,x
        sta tmp
        lda frames+1
        sbc e_bh,x
        bne ky_k
        lda tmp
        cmp #20
        bcs ky_k
ky_ok   ldx self
        lda #S_OK
        ldy #$ff
        jsr set_state
ky_k    jsr kk_move
        clc
        rts

; bq(c, e, s_): ec of the crystals - breaking one opens the boss
h_bq    ldx other           ; the crystal (self = the attacker)
        lda e_paf,x
        clc
        adc dmg
        lda e_pal,x
        adc dmg+1
        ldy e_cls,x
        cmp c_qg,y
        bcc bq_d
        lda frames
        sta boss_ktl
        lda frames+1
        sta boss_kth
        lda #1
        sta boss_kton
        lda #57
        jsr kl
bq_d    clc
        rts

; ------------------------------------------------------------------
; projectiles
; jb(p, tm): jr of the projectiles
h_jb    jsr proj_phys
        ldx self
        jsr clamp_xy
        ldx self
        lda e_zh,x
        bmi jb_d
        lda #CB_RA
        jsr call_cb
        bcc jb_at
        ldx self
        lda #S_DT
        ldy #$ff
        jsr set_state
        sec
        rts
jb_at   ldx self
        ldy e_cls,x
        lda c_qa,y
        ldx #G_PLAYER
        ldy #0
        jsr attack
jb_d    clc
        rts

; ci(fb, tm): jr of the fireballs
h_ci    ldx self
        lda e_ih,x
        cmp #$ff
        bne ci_1
        lda #T_TRAIL
        jsr ps_new
        bcs ci_1
        lda #EM_FI
        sta ps_kind,x
        lda #FI_TRAIL
        sta ps_a,x
        lda self
        sta ps_own,x
        lda #<(-1)
        sta ps_b,x
        lda #1
        sta ps_c,x
        lda #0
        sta ps_d,x
        lda #$ff
        sta ps_e,x
        txa
        ldx self
        sta e_ih,x
        tay
        lda ps_gen,y
        sta e_ihg,x
ci_1    lda #6              ; tm > 3
        jsr tm_gt
        bcc ci_2
        lda #14
        ldx #G_PLAYER
        ldy #0
        jsr attack
ci_2    jmp h_jb

; fu(d): ra of the rocks and fireballs: explode
h_fu    ldx self
        lda #0
        sta kx_dx
        ldy e_cls,x
        lda c_lu,y
        jsr explode
        sec
        rts

; er(p): ra of the pickups: es -= 1, gone at 0
h_er    ldx self
        lda e_es,x
        beq er_y
        dec e_es,x
        beq er_y
        clc
        rts
er_y    sec
        rts

; gw(s, tm): ra of the puddles: mc(#monsters == 0 and 0.5 or tm*0.0004)
h_gw    lda mon_cnt
        bne gw_1
        lda #128
        jmp chance_c
gw_1    lda #13             ; tm*0.0004 = frames*0.0002 -> 13/65536
        jmp chance_tm

; bu(p, p) for a projectile entity: own ml, jw, ir
proj_phys
        ldx self
        ; resting on the floor (z = 0, no speed, no bounce): the cart's bu()
        ; only toggles vz between 0 and jw there, z stays 0
        lda e_zf,x
        ora e_zl,x
        ora e_zh,x
        ora e_vxf,x
        ora e_vxl,x
        ora e_vyf,x
        ora e_vyl,x
        ora e_vzl,x
        bne pph_go
        ldy e_cls,x
        lda c_ir,y
        bne pph_go
        lda #0
        sta e_vzf,x
        rts
pph_go  jsr add_vx
        jsr add_vy
        jsr add_vz
        ldy e_cls,x
        lda c_ml,y
        sta pph_m
        beq pph_j
        lda e_vxf,x
        sta m_v
        lda e_vxl,x
        sta m_v+1
        lda pph_m
        jsr mulf
        ldx self
        lda m_v
        sta e_vxf,x
        lda m_v+1
        sta e_vxl,x
        lda e_vyf,x
        sta m_v
        lda e_vyl,x
        sta m_v+1
        lda pph_m
        jsr mulf
        ldx self
        lda m_v
        sta e_vyf,x
        lda m_v+1
        sta e_vyl,x
        lda e_vzf,x
        sta m_v
        lda e_vzl,x
        sta m_v+1
        lda pph_m
        jsr mulf
        ldx self
        lda m_v
        sta e_vzf,x
        lda m_v+1
        sta e_vzl,x
pph_j   lda e_vzf,x
        clc
        adc e_jw,x
        sta e_vzf,x
        bcc pph_b
        inc e_vzl,x
pph_b   ; ir: if z > 0 (all projectiles have one; 0 stops them dead)
        lda e_zh,x
        jmi pph_d
        bne pph_bo
        lda e_zl,x
        ora e_zf,x
        jeq pph_d
pph_bo  ldy e_cls,x
        lda c_ir,y
        sta pph_ir
        beq pph_stop
        lda e_zf,x
        sta m_v
        lda e_zl,x
        sta m_v+1
        lda pph_ir
        jsr mulf
        jsr neg_v
        ldx self
        lda m_v
        sta e_zf,x
        lda m_v+1
        sta e_zl,x
        lda #$ff
        sta e_zh,x
        lda e_vzf,x
        sta m_v
        lda e_vzl,x
        sta m_v+1
        lda pph_ir
        jsr mulf
        jsr neg_v
        ldx self
        lda m_v
        sta e_vzf,x
        lda m_v+1
        sta e_vzl,x
        lda e_vxf,x
        sta m_v
        lda e_vxl,x
        sta m_v+1
        lda pph_ir
        jsr mulf
        ldx self
        lda m_v
        sta e_vxf,x
        lda m_v+1
        sta e_vxl,x
        ; |vz| < 0.5: stop
        lda e_vzl,x
        beq pph_r1
        cmp #$ff
        bne pph_d
        lda e_vzf,x
        cmp #$81
        bcc pph_d
        bcs pph_stop
pph_r1  lda e_vzf,x
        cmp #$80
        bcs pph_d
pph_stop
        lda #0
        sta e_vxf,x
        sta e_vxl,x
        sta e_vyf,x
        sta e_vyl,x
        sta e_vzf,x
        sta e_vzl,x
        sta e_zf,x
        sta e_zl,x
        sta e_zh,x
pph_d   rts
pph_m   dta 0
pph_ir  dta 0

; ------------------------------------------------------------------
; qv(b, tm): jr of the explosion ring
h_qv    ldx self
        lda #0
        jsr tm_eq
        bne qv_1
        ldx self
        lda e_om,x
        beq qv_1
        lda #62
        jsr kl
qv_1    ldx self
        ; r += kw; kw *= 0.707
        lda e_rf,x
        clc
        adc e_kwf,x
        sta e_rf,x
        lda e_ri,x
        adc e_kwi,x
        sta e_ri,x
        lda e_kwf,x
        sta m_v
        lda e_kwi,x
        sta m_v+1
        lda #181
        jsr mulf
        ldx self
        lda m_v
        sta e_kwf,x
        lda m_v+1
        sta e_kwi,x
        ; if kw > 0.2 and eg:jf() and |(dx, 3dy)| < r: b:hit_player(eg)
        lda e_kwi,x
        bne qv_k
        lda e_kwf,x
        cmp #52
        bcc qv_w
qv_k    ldx eg
        jsr hurtbox
        beq qv_w
        ldx self
        ldy eg
        jsr vec_xy
        ; dy * 3
        lda nv_dy
        sta tmp
        lda nv_dy+1
        sta tmp+1
        lda nv_dy+2
        sta tmp+2
        asl nv_dy
        rol nv_dy+1
        rol nv_dy+2
        lda nv_dy
        clc
        adc tmp
        sta nv_dy
        lda nv_dy+1
        adc tmp+1
        sta nv_dy+1
        lda nv_dy+2
        adc tmp+2
        sta nv_dy+2
        jsr vnorm
        ldx self
        lda nv_d
        cmp e_rf,x
        lda nv_d+1
        sbc e_ri,x
        bcs qv_w
        lda eg
        sta other
        jsr h_oa
qv_w    ; w -= 0.5; return w <= 0
        ldx self
        lda e_wf,x
        sec
        sbc #$80
        sta e_wf,x
        lda e_wi,x
        sbc #0
        sta e_wi,x
        bmi qv_y
        ora e_wf,x
        beq qv_y
        clc
        rts
qv_y    sec
        rts
