; ------------------------------------------------------------------
; The hero's states, the shared hurt/death states and damage.
; Handlers: self = entity (also in X), state time e_tl/e_th in frames
; (the cart's tm * 2).  C = 1 on return removes the entity.
; ------------------------------------------------------------------

BTN_L   = 1
BTN_R   = 2
BTN_U   = 4
BTN_D   = 8
BTN_O   = 16
BTN_X   = 32

; og(p): gf - standing / walking
h_og    lda #128            ; bn(p, 0.5, true)
        ldx #1
        jsr hero_move
        jsr td_scroll
        ldx self
        lda #0
        sta e_chg,x
        lda in_new          ; kb(gq[4], p, "jp")
        and #BTN_O
        beq og_1
        lda #S_JP
        ldy #$ff
        jsr set_state
og_1    jsr km_check
        clc
        rts

; gz(p): oo - dash
h_gz    jsr td_scroll
        lda in_new          ; any button: back to gf and run og
        beq gz_1
        ldx self
        lda #S_GF
        ldy #$ff
        jsr set_state
        jmp h_og
gz_1    jsr sa_test         ; kb(sa(p), p, "gf")
        bcc gz_2
        lda #S_GF
        ldy #$ff
        jsr set_state
gz_2    clc
        rts

; cp(p, tm): co - walking off after a stage
h_cp    ldx self
        lda #1
        sta e_qn,x
        lda #0
        sta mv_dx
        sta mv_dy
        sta mv_dy+1
        lda #1
        sta mv_dx+1
        jsr ru_move
        lda #30             ; tm == 15
        jsr tm_eq
        bne cpl_d
        lda #32
        jsr music
        lda #<t_scomp
        sta ptr
        lda #>t_scomp
        sta ptr+1
        lda lv_qy
        beq cpl_1
        lda #<t_qcomp
        sta ptr
        lda #>t_qcomp
        sta ptr+1
cpl_1    lda #0
        sta eq_ol
        lda #9
        jsr eq_start
        lda #1              ; dset(63, 1): the tutorial was seen
        sta cdata+6
cpl_d    clc
        rts

; kn(p, tm): jp - charging
h_kn    lda #64             ; bn(p, 0.25)
        ldx #0
        jsr hero_move
        jsr td_scroll
        lda #10             ; tm == 5
        jsr tm_eq
        bne kn_1
        ; p.ku = lr(p, -7, 1, -16, 8, 12); sfx(63, 3)
        lda #<(-7)
        sta lr_dx
        lda #1
        sta lr_dy
        lda #<(-16)
        sta lr_dz
        lda #8
        sta lr_r
        lda #12
        sta lr_oe
        ldx self
        jsr lr_start
        ldx self
        sta e_ku,x
        tya
        sta e_kug,x
        lda #63
        ldx #3
        jsr sfx_ch
kn_1    lda #10             ; tm >= 5
        jsr tm_ge
        bcc kn_r
        ; gb = {hf, abs(sin(t/10) * charge/10.6)}
        lda ang20+1         ; t/10 turns = frames/20 turns
        jsr psin
        lda m_u+1
        bpl kn_s
        lda #0
        sec
        sbc m_u
        sta m_u
        lda #0
        sbc m_u+1
        sta m_u+1
kn_s    ; level = |sin| * charge / 10.6 ; charge = chg/2 -> chg * |sin| / 21.2
        ldx self
        lda e_chg,x
        sta m_v+1
        lda #0
        sta m_v             ; chg as 8.8
        jsr mulu            ; * |sin|
        ; / 21.2 = * 0.04717 (12/256 = 0.0469)
        lda #12
        jsr mulf
        ldx self
        lda m_v+1           ; integer level
        beq kn_g0
        cmp #4
        bcc kn_g
        lda #4
kn_g    clc
        adc #BK_HF
        jmp kn_g1
kn_g0   lda #0
kn_g1   sta e_gbt,x
        ; if not fr.hl then p.fk += 0.5
        lda lv_hl
        bne kn_2
        inc e_fkl,x
        bne kn_2
        inc e_fkh,x
kn_2    lda e_chg,x         ; charge < 40 -> += 0.5, else stop the sparks
        cmp #80
        bcs kn_3
        inc e_chg,x
        jmp kn_r
kn_3    lda e_ku,x
        ldy e_kug,x
        jsr ps_stop
kn_r    ; released O: lunge and stab
        lda in_held
        and #BTN_O
        bne kn_d
        ldx self
        ; vx = qn * (0.6 + charge*0.1) = qn * (154 + chg*12.8)/256
        lda e_chg,x
        ldx #13
        jsr umul8
        lda m_lo
        clc
        adc #154
        sta m_v
        lda m_hi
        adc #0
        sta m_v+1
        ldx self
        lda e_qn,x
        bpl kn_4
        jsr neg_v
kn_4    lda m_v
        sta e_vxf,x
        lda m_v+1
        sta e_vxl,x
        lda #S_HC
        ldy #58
        jsr set_state
kn_d    clc
        rts

; byte angle of t/10 turns: t/10 = frames/20 -> (frames mod 20) * 256 / 20
ang_div20
        ldx #20
        jsr mod_frames
        sta m_n+1
        lda #0
        sta m_n
        lda #20
        sta m_d
        lda #0
        sta m_d+1
        jsr div16
        lda m_q
        rts

; jj(p, tm): de - shield
h_jj    lda #64
        ldx #0
        jsr hero_move
        jsr td_scroll
        ldx self
        lda in_held         ; kb(not ct[5], p, "gf")
        and #BTN_X
        bne jj_1
        lda #S_GF
        ldy #$ff
        jsr set_state
jj_1    lda in_new          ; kb(gq[4], p, "jp")
        and #BTN_O
        beq jj_2
        ldx self
        lda #S_JP
        ldy #$ff
        jsr set_state
jj_2    lda #9              ; fp(p, 9, "proj")
        ldx #G_PROJ
        ldy #2
        jsr attack
        clc
        rts

; cg(p, tm): hc - stab
h_cg    jsr td_scroll
        jsr km_check
        jsr sa_test
        bcc cg_1
        lda #6              ; tm >= 3
        jsr tm_ge
        bcc cg_1
        ldx self
        lda #S_GF
        ldy #$ff
        jsr set_state
        clc
        rts
cg_1    lda #5              ; fp(p, 5, "monster")
        ldx #G_MONSTER
        ldy #1
        jsr attack
        clc
        rts

; gu(p, tm): qi of the hero
h_gu    jsr h_qo
        jsr km_check
        clc
        rts

; km(p): shield and dash
km_check
        lda in_new
        and #BTN_X
        beq km_1
        ldx self
        lda #S_DE
        ldy #$ff
        jsr set_state
km_1    ; pl[0..3]: double tap -> dash 1.5 in that direction
        ldx #0
km_l    lda in_dbl
        and bit_tab,x
        beq km_n
        stx tmp+4
        ldy self
        lda tf_vxf,x
        sta e_vxf,y
        lda tf_vxl,x
        sta e_vxl,y
        lda tf_vyf,x
        sta e_vyf,y
        lda tf_vyl,x
        sta e_vyl,y
        lda frames
        sta e_pul,y
        lda frames+1
        sta e_puh,y
        ldx self
        lda #S_OO
        ldy #58
        jsr set_state
        ldx tmp+4
km_n    inx
        cpx #4
        bne km_l
        rts
; tf * 1.5: left (-2.25, 0), right (2.25, 0), up (0, -1.5), down (0, 1.5)
tf_vxf  dta $c0,$40,0,0
tf_vxl  dta $fd,$02,0,0
tf_vyf  dta 0,0,$80,$80
tf_vyl  dta 0,0,$fe,$01

; bn(p, sw, qq): A = sw (fraction), X = 1: may turn
hero_move
        sta hm_sw
        stx hm_qq
        lda #0
        sta mv_dx
        sta mv_dx+1
        sta mv_dy
        sta mv_dy+1
        lda in_held
        and #BTN_L
        beq hm_1
        ; dx -= 1.5 * sw
        jsr hm_15
        lda mv_dx
        sec
        sbc tmp
        sta mv_dx
        lda mv_dx+1
        sbc tmp+1
        sta mv_dx+1
hm_1    lda in_held
        and #BTN_R
        beq hm_2
        jsr hm_15
        lda mv_dx
        clc
        adc tmp
        sta mv_dx
        lda mv_dx+1
        adc tmp+1
        sta mv_dx+1
hm_2    lda in_held
        and #BTN_U
        beq hm_3
        lda mv_dy
        sec
        sbc hm_sw
        sta mv_dy
        lda mv_dy+1
        sbc #0
        sta mv_dy+1
hm_3    lda in_held
        and #BTN_D
        beq hm_4
        lda mv_dy
        clc
        adc hm_sw
        sta mv_dy
        lda mv_dy+1
        adc #0
        sta mv_dy+1
hm_4    ; turn
        lda hm_qq
        beq hm_5
        lda mv_dx
        ora mv_dx+1
        beq hm_5
        ldx self
        lda mv_dx+1
        bmi hm_q1
        lda #1
        bne hm_q2
hm_q1   lda #$ff
hm_q2   sta e_qn,x
hm_5    jsr ru_move
        ; footsteps: if p.gj and hr(12) and fr.qy and fr.x > -256: kl(59)
        ldx self
        lda e_gjon,x
        beq hm_d
        lda lv_qy
        beq hm_d
        lda lv_xh           ; fr.x > -256
        beq hm_x
        cmp #$ff
        bne hm_d
        lda lv_xl
        ora lv_xf
        beq hm_d
hm_x
        ldx #24
        jsr mod_frames
        bne hm_d
        lda #59
        jsr kl
hm_d    rts
; tmp = 1.5 * sw
hm_15   lda hm_sw
        lsr
        clc
        adc hm_sw
        sta tmp
        lda #0
        adc #0
        sta tmp+1
        rts
hm_sw   dta 0
hm_qq   dta 0

; sa(mn): C = 1 when the entity stands still
sa_test ldx self
        lda e_vxf,x
        ora e_vxl,x
        ora e_vyf,x
        ora e_vyl,x
        bne sa_n
        sec
        rts
sa_n    clc
        rts

; td(p): scrolling, fight time, combo timeout, kk
td_scroll
        ldx self
        lda lv_hl
        jeq td_fight
        ; gg = min(p.x - 56, 1.5)
        lda e_xf,x
        sta tmp
        lda e_xl,x
        sec
        sbc #56
        sta tmp+1
        lda e_xh,x
        sbc #0
        sta tmp+2
        jmi td_wait         ; gg <= 0 ... (x < 56)
        bne td_cap
        lda tmp+1
        cmp #1
        bcc td_g            ; < 1.0
        bne td_cap
        lda tmp
        cmp #$80
        bcc td_g            ; < 1.5
td_cap  lda #$80
        sta tmp
        lda #1
        sta tmp+1
td_g    lda tmp
        ora tmp+1
        beq td_wait         ; gg = 0
        lda e_dx,x
        beq td_wait
        bmi td_wait
        ; p.mo = 0; fr.x -= gg*rk; p.x -= gg; if p.x > 56 then p.x -= 1
        lda #0
        sta pl_mol
        sta pl_moh
        lda tmp
        sta m_v
        lda tmp+1
        sta m_v+1
        lda lv_rk
        jsr mulf
        lda lv_xf
        sec
        sbc m_v
        sta lv_xf
        lda lv_xl
        sbc m_v+1
        sta lv_xl
        lda lv_xh
        sbc #0
        sta lv_xh
        ldx self
        lda e_xf,x
        sec
        sbc tmp
        sta e_xf,x
        lda e_xl,x
        sbc tmp+1
        sta e_xl,x
        lda e_xh,x
        sbc #0
        sta e_xh,x
        ; x > 56
        lda e_xh,x
        bne td_cm
        lda e_xl,x
        cmp #56
        bcc td_cm
        bne td_m1
        lda e_xf,x
        beq td_cm
td_m1   dec e_xl,x
        jmp td_cm
td_wait inc pl_mol
        bne td_cm
        inc pl_moh
        jmp td_cm
td_fight
        inc pl_ckl          ; ck += 1/6 per frame: counted in frames
        bne td_cm
        inc pl_ckh
td_cm   ; if t - p.fk >= 45: p.jm = 0
        ldx self
        lda frames
        sec
        sbc e_fkl,x
        sta tmp
        lda frames+1
        sbc e_fkh,x
        bne td_j0
        lda tmp
        cmp #90
        bcc td_k
td_j0   lda #0
        sta e_jm,x
td_k    jmp kk_move

; ------------------------------------------------------------------
; qo(c, tm): qi - hurt: kb(tm > c.ht, c, "gf"); kk(c)
h_qo    ldx self
        ldy e_cls,x
        lda c_ht,y
        asl
        jsr tm_gt
        bcc qo_1
        ldx self
        lda #S_GF
        ldy #$ff
        jsr set_state
qo_1    jsr kk_move
        clc
        rts

; C = 1 when tm > A frames (A < 256)
tm_gt   ldx self
        ldy e_th,x
        bne tgt_y
        cmp e_tl,x
        bcc tgt_y
        clc
        rts
tgt_y   sec
        rts

; ft(c, tm): dt - falls apart; drops a pickup now and then
h_ft    ldx self
        lda #1
        sta e_nb,x
        lda #1              ; tm == 0.5
        jsr tm_eq
        bne ft_r
        jsr ft_burst
ft_r    ; return tm > 45 and c ~= eg
        ldx self
        cpx eg
        beq ft_k
        lda #90
        jmp tm_gt
ft_k    clc
        rts

ft_burst
        ; eh(c, pm({jw=0.1, ir=0.4, ml=0.98, cs=0.0125}))
        lda #T_DEATH
        jsr ps_new
        bcs ft_1
        stx ps
        ldx self
        jsr disintegrate
ft_1    ldx self
        ldy e_cls,x
        lda c_ro,y
        jeq ft_d
        ; eg.hj += im(1, 1.25)
        lda #64
        jsr rnd_mul
        clc
        adc pl_hjf
        sta pl_hjf
        lda pl_hjl
        adc #1
        sta pl_hjl
        ; if eg.hj >= rc.nw
        ldy kh
        lda pl_hjf
        cmp qd_nw_lo,y
        lda pl_hjl
        sbc qd_nw_hi,y
        jcc ft_d
        lda pl_hjf
        sec
        sbc qd_nw_lo,y
        sta pl_hjf
        lda pl_hjl
        sbc qd_nw_hi,y
        sta pl_hjl
        ; rq(mc(eg.pa/24) and "sb" or "qf", {z=-10, vz=-1.5, es=75} at c)
        ldx eg
        lda e_pal,x         ; chance pa/24 -> pa*256/24 = pa*10.67
        ldx #11
        jsr umul8
        lda m_hi
        bne ft_sb
        lda m_lo
        jsr chance_c
        bcs ft_sb
        lda #C_QF
        bne ft_new
ft_sb   lda #C_SB
ft_new  jsr ent_new
        bcs ft_d
        ldy self
        jsr copy_pos
        lda #<(-10)
        sta e_zl,x
        lda #$ff
        sta e_zh,x
        lda #$80
        sta e_vzf,x
        lda #$fe
        sta e_vzl,x
        lda #75
        sta e_es,x
        stx tmp+5
        ; p.vx, p.vy = sin(a), cos(a)*0.5
        jsr rnd8
        sta tmp+6
        jsr psin
        ldx tmp+5
        lda m_u
        sta e_vxf,x
        lda m_u+1
        sta e_vxl,x
        lda tmp+6
        jsr pcos
        lda m_u+1
        cmp #$80
        ror
        ldx tmp+5
        sta e_vyl,x
        lda m_u
        ror
        sta e_vyf,x
        lda #R_FO
        ldy #$ff
        jsr draw_new
ft_d    rts

; ------------------------------------------------------------------
; damage
; ef(e = self, nj = other, s_ = dmg (signed 8.8)): C = 1 when it hit
deal    ldx other
        ldy e_cls,x
        ; s_ -= nj.te
        lda dmg+1
        sec
        sbc c_te,y
        sta dmg+1
        ; already hit by this attack?
        lda other
        jsr dn_test
        bcc dl_new
        clc
        rts
dl_new  lda other
        jsr dn_add          ; also counts
        ; ec interceptors (shield, boss, crystal)
        ldx other
        lda #CB_EC
        jsr call_cb
        bcc dl_go
        clc
        rts
dl_go   ldx other
        cpx eg
        bne dl_1
        ; nj.rj = t + 10
        lda frames
        clc
        adc #20
        sta e_rjl,x
        lda frames+1
        adc #0
        sta e_rjh,x
dl_1    ; nj.pa += s_
        lda e_paf,x
        clc
        adc dmg
        sta e_paf,x
        lda e_pal,x
        adc dmg+1
        sta e_pal,x
        ldy dmg+1
        bmi dl_neg
        bcc dl_2
        lda #255            ; saturate
        sta e_pal,x
        jmp dl_2
dl_neg  bcs dl_2
        lda #0              ; below 0
        sta e_paf,x
        sta e_pal,x
dl_2    ; kb(not (nj.ez or e.ix), nj, "qi")
        ldy e_cls,x
        lda c_ez,y
        bne dl_3
        ldy self
        lda e_cls,y
        tay
        lda c_ix,y
        bne dl_3
        lda #S_QI
        ldy #$ff
        jsr set_state
dl_3    ldx other
        lda frames
        sta e_bl,x
        lda frames+1
        sta e_bh,x
        ; kl(fe and 5 or flr(im(60, 62)))
        cpx eg
        bne dl_s
        lda #5
        bne dl_s2
dl_s    jsr rnd8
        and #1
        clc
        adc #60
dl_s2   jsr kl
        ; if not e.ix: knock back and hit-stop
        ldy self
        lda e_cls,y
        tay
        lda c_ix,y
        bne dl_4
        ; speed = min(s_ / nj.d_, 3)
        ldx other
        ldy e_cls,x
        lda c_d_,y
        sta m_d
        lda #0
        sta m_d+1
        lda dmg
        sta m_n
        lda dmg+1
        bpl dl_p
        lda #0              ; negative damage: no push
        sta m_n
dl_p    sta m_n+1
        jsr div16           ; (8.8) / d_
        lda m_q+1
        cmp #3
        bcc dl_sp
        lda #3
        sta m_q+1
        lda #0
        sta m_q
dl_sp   lda m_q
        sta ho_s
        lda m_q+1
        sta ho_s+1
        ldx self
        ldy other
        jsr ho_vec          ; vector from self to other * ho_s -> ho_vx, ho_vy
        ldx other
        lda ho_vx
        sta e_vxf,x
        lda ho_vx+1
        sta e_vxl,x
        lda ho_vy
        sta e_vyf,x
        lda ho_vy+1
        sta e_vyl,x
        ; e.il, nj.il = ii, ii  (ii = #dn + 2.5 -> 2*#dn + 5 frames)
        ldy self
        lda e_dnn,y
        asl
        clc
        adc #5
        sta e_il,y
        sta e_il,x
dl_4    ; gr = fe and 4 or 2  (stored * 2)
        lda #4
        ldx other
        cpx eg
        bne dl_5
        lda #8
dl_5    sta gr
        sec
        rts
dmg     dta 0,0

; dn list (bit mask of the entities hit by self's current attack)
; dn_test: A = entity, C = 1 when present
dn_test jsr dn_bit
        ldx self
dn_and  and e_dn0,x         ; (patched by dn_bit to the right byte)
dn_t2   beq dn_no
        sec
        rts
dn_no   clc
        rts
dn_add  jsr dn_bit
        sta tmp
        ldx self
        ldy dn_byte
        lda dn_lo,y
        sta da_r+1
        sta da_w+1
        lda dn_hi,y
        sta da_r+2
        sta da_w+2
        lda tmp
da_r    ora e_dn0,x
da_w    sta e_dn0,x
        inc e_dnn,x
        rts
; A = entity -> A = bit, dn_byte = 0..3; patches dn_test's AND
dn_bit  pha
        lsr
        lsr
        lsr
        sta dn_byte
        tay
        lda dn_lo,y
        sta dn_and+1
        lda dn_hi,y
        sta dn_and+2
        pla
        and #7
        tay
        lda bit8,y
        rts
dn_byte dta 0
dn_lo   dta <e_dn0,<e_dn1,<e_dn2,<e_dn3,<e_dn4
dn_hi   dta >e_dn0,>e_dn1,>e_dn2,>e_dn3,>e_dn4
bit8    dta 1,2,4,8,16,32,64,128

; ho(a = X, b = Y, s = ho_s): (b - a) * s / |b - a| -> ho_vx, ho_vy
ho_vec  jsr vec_xy
        jsr vnorm
ho_scale
        lda nv_ux
        sta m_u
        lda nv_ux+1
        sta m_u+1
        lda ho_s
        sta m_v
        lda ho_s+1
        sta m_v+1
        jsr mulu
        lda m_v
        sta ho_vx
        lda m_v+1
        sta ho_vx+1
        lda nv_uy
        sta m_u
        lda nv_uy+1
        sta m_u+1
        lda ho_s
        sta m_v
        lda ho_s+1
        sta m_v+1
        jsr mulu
        lda m_v
        sta ho_vy
        lda m_v+1
        sta ho_vy+1
        rts
ho_s    dta 0,0
ho_vx   dta 0,0
ho_vy   dta 0,0

; difference of entity Y and entity X positions -> nv_dx, nv_dy
vec_xy  lda e_xf,y
        sec
        sbc e_xf,x
        sta nv_dx
        lda e_xl,y
        sbc e_xl,x
        sta nv_dx+1
        lda e_xh,y
        sbc e_xh,x
        sta nv_dx+2
        lda e_yf,y
        sec
        sbc e_yf,x
        sta nv_dy
        lda e_yl,y
        sbc e_yl,x
        sta nv_dy+1
        lda #0
        sbc #0
        sta nv_dy+2
        rts

; ij(a = X, b = Y) -> nv_d (8.8)
dist    jsr vec_xy
        jmp vnorm

; ------------------------------------------------------------------
; callbacks
; oa(mv, nj): hit_player of most things: if mv.s_ > 0 then ef(mv, nj, mv.s_)
h_oa    ldx self
        lda e_s_,x
        beq oa_d
        bmi oa_d
        sta dmg+1
        lda #0
        sta dmg
        jsr deal
oa_d    rts

; dk(p, m): the hero's stab hits a monster
h_dk    ; s_ = (p.s_ + p.jm) * (1 + p.charge/30): base * (256 + f) as 8.8,
        ; f = charge/30*256 = chg*256/60 ~ (chg*68) >> 4
        ldx self
        lda e_s_,x
        clc
        adc e_jm,x
        sta tmp+4           ; base
        lda e_chg,x
        ldx #68
        jsr umul8
        ldx #4
dk_sh   lsr m_hi
        ror m_lo
        dex
        bne dk_sh
        inc m_hi            ; 256 + f
        lda m_lo
        sta tmp+5
        lda m_hi
        sta tmp+6
        lda tmp+4
        ldx tmp+5
        jsr umul8           ; base * lo
        lda m_lo
        sta dmg
        lda m_hi
        sta dmg+1
        lda tmp+4
        ldx tmp+6
        jsr umul8           ; base * hi (* 256)
        lda m_lo
        clc
        adc dmg+1
        sta dmg+1
dk_1    ; cw(m, lb, 129, {qn=true}, "lasthit")
        lda #D_LASTHIT
        sta d_named
        ldx other
        lda #R_LB
        ldy #129
        jsr draw_named
        lda #1
        sta d_a,x           ; qn = true (right side)
        lda #$ff
        sta d_b,x           ; hp not yet shown
        jsr deal
        bcc dk_d
        lda #1
        jmp nh_add
dk_d    rts

; nh(p, d): combo
nh_add  ldx eg
        clc
        adc e_jm,x
        sta e_jm,x
        cmp e_gk,x
        bcc nh_1
        sta e_gk,x
nh_1    lda frames
        sta e_fkl,x
        lda frames+1
        sta e_fkh,x
        lda e_jm,x
        beq nh_d
        ; cw(p, ga, 129, {pz=-70}, "combo")
        lda #D_COMBO
        sta d_named
        lda #R_GA
        ldy #129
        jsr draw_named
        lda #<(-70)
        sta d_a,x           ; pz (signed int)
nh_d    rts

; hz(p, pr): the shield bats projectiles back
h_hz    ldx other
        lda e_vxf,x
        ora e_vxl,x
        beq hz_d
        ; pr.z > -16
        lda e_zh,x
        bpl hz_y
        cmp #$ff
        bne hz_d
        lda e_zl,x
        cmp #<(-16)
        bcc hz_d
        bne hz_y
        lda e_zf,x
        beq hz_d
hz_y    lda e_vxf,x
        sta m_v
        lda e_vxl,x
        sta m_v+1
        lda #179            ; * 0.7
        jsr mulf
        jsr neg_v
        ldx other
        lda m_v
        sta e_vxf,x
        lda m_v+1
        sta e_vxl,x
        lda #59
        jsr kl
hz_d    rts

; dp(p, m, s_): ec of the hero (called with X = hero = other, self = m)
; C = 1: blocked
h_dp    ldx eg
        lda e_st,x
        cmp #S_DE
        jne dp_no
        ; sgn(m.x - p.x) == p.qn
        ldy self
        lda e_xf,y
        cmp e_xf,x
        lda e_xl,y
        sbc e_xl,x
        lda e_xh,y
        sbc e_xh,x
        bmi dp_l
        lda #1
        bne dp_s
dp_l    lda #$ff
dp_s    cmp e_qn,x
        jne dp_no
        lda e_cls,y
        tay
        lda c_ix,y
        jne dp_no
        ; p.vx, p.vy = ho(m, p, max(abs(m.bf), 0.8))
        lda c_bf_lo,y
        sta ho_s
        lda c_bf_hi,y
        sta ho_s+1
        cmp #0
        bne dp_b
        lda ho_s
        cmp #205
        bcs dp_b
        lda #205
        sta ho_s
dp_b    ldx self
        ldy eg
        jsr ho_vec
        ldx eg
        lda ho_vx
        sta e_vxf,x
        lda ho_vx+1
        sta e_vxl,x
        lda ho_vy
        sta e_vyf,x
        lda ho_vy+1
        sta e_vyl,x
        lda #54
        jsr kl
        ldx self
        ldy e_cls,x
        lda c_mon,y
        beq dp_yes
        ; m.vx, m.pu, p.pu = -m.qn*0.75, t, t
        lda e_qn,x
        bmi dp_r
        lda #$40
        sta e_vxf,x
        lda #$ff
        sta e_vxl,x
        jmp dp_t
dp_r    lda #$c0
        sta e_vxf,x
        lda #0
        sta e_vxl,x
dp_t    lda frames
        sta e_pul,x
        ldy eg
        sta e_pul,y
        lda frames+1
        sta e_puh,x
        sta e_puh,y
        lda #0
        jsr nh_add
        ldx self
        lda #S_LX
        ldy #$ff
        jsr set_state
        ldx eg
        lda #S_GF
        ldy #$ff
        jsr set_state
dp_yes  sec
        rts
dp_no   ; p.oh += s_
        lda pl_ohf
        clc
        adc dmg
        sta pl_ohf
        lda pl_ohl
        adc dmg+1
        sta pl_ohl
        clc
        rts

; cm(p, eg): a pickup is collected
h_cm    ldx self
        lda e_cls,x
        cmp #C_QF
        bne cm_h
        ldy eg
        lda e_s_,y
        clc
        adc #1
        sta e_s_,y
        jmp cm_1
cm_h    ; eg.pa = max(eg.pa - 8, 0)
        ldy eg
        lda e_pal,y
        sec
        sbc #8
        bcs cm_h1
        lda #0
        sta e_paf,y
cm_h1   sta e_pal,y
cm_1    ldx self
        lda #0
        sta e_es,x
        ldy eg
        lda frames
        sta e_pul,y
        lda frames+1
        sta e_puh,y
        ; eq(p.hh, p.oe, 15)
        lda #<t_health
        sta ptr
        lda #>t_health
        sta ptr+1
        lda e_cls,x
        cmp #C_QF
        bne cm_2
        lda #<t_strength
        sta ptr
        lda #>t_strength
        sta ptr+1
cm_2    lda #15
        sta eq_ol
        lda e_oe,x
        jsr eq_start
        lda #3
        jsr kl
        ; kx(p, {om=0, s_=0, oe=7, kw=6, w=9})
        ldx self
        lda #KX_CM
        jsr explode
        ; 16 rising sparks: pm({cs=0.025, ml=0.96, jw=0, bp=1}, 16, fi(p, 0, ...))
        lda #T_PICK
        jsr ps_new
        bcs cm_d
        stx ps
        lda #EM_FI
        sta ps_kind,x
        lda #FI_PICK
        sta ps_a,x
        lda self
        sta ps_own,x
        lda #0
        sta ps_b,x
        sta ps_d,x
        lda #1
        sta ps_c,x
        ldy self
        lda e_oe,y
        sta ps_e,x
        lda #16
        sta tmp+7
cm_l    ldx ps
        jsr emit_fi
        dec tmp+7
        bne cm_l
        ; the pickup is gone: no more emission
        ldx ps
        lda #0
        sta ps_em,x
cm_d    rts
