; ------------------------------------------------------------------
; Entities: allocation, the update loop (the cart's pj), state changes
; (lp), movement helpers, the attack queue (fp / sl) and drawables (cw).
; The current entity is in X for most helpers and in self for handlers.
; ------------------------------------------------------------------

; ed(): empty world
world_reset
        ldx #MAXE-1
        lda #0
wr_e    sta e_cls,x
        dex
        bpl wr_e
        ldx #MAXD-1
wr_d    sta d_kind,x
        dex
        bpl wr_d
        ldx #MAXPS-1
wr_p    sta ps_on,x
        dex
        bpl wr_p
        jsr part_reset
        lda #0
        sta frames
        sta frames+1
        sta ent_top
        sta ang120
        sta ang120+1
        sta ang20
        sta ang20+1
        sta fm12
        sta fm3
        sta o_
        sta gr
        sta hu_n
        sta alloc_e
        sta nt_tab
        sta nt_lvl
        sta boss_kton
        lda #$ff
        sta boss
        sta boss_qr
        sta ei
        rts

; ent_new: A = class -> X = new entity (C = 1: none free)
ent_new sta tmp
        ldx #0
en_f    lda e_cls,x
        beq en_got
        inx
        cpx #MAXE
        bne en_f
        sec
        rts
en_got  cpx ent_top
        bcc en_t
        inx
        stx ent_top
        dex
en_t    lda tmp
        sta e_cls,x
        tay
        lda c_grp,y
        and #G_KS
        beq en_jr
        lda #S_GF
        bne en_st
en_jr   lda #S_JR
en_st   sta e_st,x
        lda #0
        sta e_tl,x
        sta e_th,x
        sta e_il,x
        sta e_xf,x
        sta e_xl,x
        sta e_xh,x
        sta e_yf,x
        sta e_yl,x
        sta e_zf,x
        sta e_zl,x
        sta e_zh,x
        sta e_vxf,x
        sta e_vxl,x
        sta e_vyf,x
        sta e_vyl,x
        sta e_vzf,x
        sta e_vzl,x
        sta e_paf,x
        sta e_pal,x
        sta e_gjon,x
        sta e_dn0,x
        sta e_dn1,x
        sta e_dn2,x
        sta e_dn3,x
        sta e_dn4,x
        sta e_dnn,x
        sta e_gbt,x
        sta e_nb,x
        sta e_dx,x
        sta e_chg,x
        sta e_jm,x
        sta e_fkl,x
        sta e_fkh,x
        sta e_gk,x
        sta e_njon,x
        sta e_od,x
        sta e_mxf,x
        sta e_mxl,x
        sta e_myf,x
        sta e_myl,x
        sta e_axf,x
        sta e_axl,x
        sta e_ayf,x
        sta e_ayl,x
        sta e_df,x
        sta e_rs,x
        sta e_var,x
        sta e_rf,x
        sta e_ri,x
        sta e_ihf,x
        sta e_mf,x
        lda c_dg,y
        sta e_dg,x
        lda c_s_,y
        sta e_s_,x
        lda c_es,y
        sta e_es,x
        lda c_oe,y
        sta e_oe,x
        lda c_jw,y
        sta e_jw,x
        lda #1
        sta e_qn,x
        lda #$ff
        sta e_ku,x
        sta e_ih,x
        ; b_ = pu = -100 (t units) = -200 frames; rj = -1 -> -2 frames
        lda #<(-200)
        sta e_bl,x
        sta e_pul,x
        lda #>(-200)
        sta e_bh,x
        sta e_puh,x
        lda #<(-2)
        sta e_rjl,x
        lda #>(-2)
        sta e_rjh,x
        clc
        rts

; free entity X and its drawables
ent_free
        lda #0
        sta e_cls,x
        stx tmp
        ldy #MAXD-1
ef_l    lda d_kind,y
        beq ef_n
        txa
        cmp d_ent,y
        bne ef_n
        lda #0
        sta d_kind,y
ef_n    dey
        bpl ef_l
        rts

; group test: C = 1 when entity X is in group A
in_group
        sta tmp
        lda e_cls,x
        beq ig_no
        tay
        lda c_grp,y
        and tmp
        beq ig_no
        sec
        rts
ig_no   clc
        rts

; count entities in group A -> A
group_count
        sta tmp+1
        lda #0
        sta tmp+2
        ldx ent_top
        dex
        bmi gc_d0
gc_l    lda e_cls,x
        beq gc_n
        tay
        lda c_grp,y
        and tmp+1
        beq gc_n
        inc tmp+2
gc_n    dex
        bpl gc_l
gc_d0   lda tmp+2
        rts

; ------------------------------------------------------------------
; pj(): one update.  Each entity's state handler runs unless it is in
; hit-stop; a handler returning C = 1 removes the entity.
update_all
        inc frames
        bne ua_a
        inc frames+1
ua_a    lda ang120
        clc
        adc #<546
        sta ang120
        lda ang120+1
        adc #>546
        sta ang120+1
        lda ang20
        clc
        adc #<3277
        sta ang20
        lda ang20+1
        adc #>3277
        sta ang20+1
        inc fm12
        lda fm12
        cmp #12
        bcc ua_b
        lda #0
        sta fm12
ua_b    inc fm3
        lda fm3
        cmp #3
        bcc ua_0
        lda #0
        sta fm3
ua_0    lda #G_MONSTER
        jsr group_count
        sta mon_cnt
        lda #0
        sta self
        lda ent_top
        beq ua_x
ua_l    ldx self
        lda e_cls,x
        beq ua_n
        lda e_il,x
        beq ua_run
        dec e_il,x
        jmp ua_n
ua_run  ; handler: row of the state, column of the class
        ldy e_st,x
        lda hrl_lo,y
        sta ptr
        lda hrl_hi,y
        sta ptr+1
        lda hrh_lo,y
        sta ptr2
        lda hrh_hi,y
        sta ptr2+1
        ldy e_cls,x
        lda (ptr),y
        sta ua_j+1
        lda (ptr2),y
        sta ua_j+2
ua_j    jsr h_none
        ldx self
        bcc ua_t
        jsr ent_free
        jmp ua_n
ua_t    inc e_tl,x
        bne ua_n
        inc e_th,x
ua_n    inc self
        lda self
        cmp ent_top
        bcc ua_l
ua_x    jmp part_update

h_none  clc
        rts

; tm = the entity's state time in frames (16 bit) -> A = low, X = high clamp
; helpers: compare tm (frames) with A: C = 1 when tm >= A (A < 256)
tm_ge   ldx self
        ldy e_th,x
        bne tg_y
        cmp e_tl,x
        beq tg_y
        bcs tg_n            ; A > tm
tg_y    sec
        rts
tg_n    clc
        rts
; Z = 1 when tm == A frames
tm_eq   ldx self
        ldy e_th,x
        bne te_n
        cmp e_tl,x
        rts
te_n    lda #1              ; Z = 0
        rts

; ------------------------------------------------------------------
; lp(e, state, sfx): X = entity, A = state, Y = sfx ($ff none)
set_state
        cmp e_st,x
        beq ss_same
        sta tmp
        sty tmp+1
        lda e_st,x
        cmp #S_JP
        bne ss_1
        ; leaving the charge: sfx(-1, 3)
        txa
        pha
        lda #3
        jsr sfx_stop
        pla
        tax
ss_1    lda #0
        sta e_tl,x
        sta e_th,x
        sta e_dn0,x
        sta e_dn1,x
        sta e_dn2,x
        sta e_dn3,x
        sta e_dn4,x
        sta e_dnn,x
        sta e_gbt,x
        sta e_gjon,x
        lda tmp
        sta e_st,x
        cmp #S_DT
        bne ss_2
        lda e_ih,x
        ldy e_ihg,x
        jsr ps_stop
ss_2    lda e_ku,x
        ldy e_kug,x
        jsr ps_stop
        lda tmp+1
        cmp #$ff
        beq ss_same
        jsr kl
ss_same rts

; kb(cond, e, state, sfx) = if C then set_state
set_state_if
        bcc ssi_n
        jmp set_state
ssi_n   rts

; ------------------------------------------------------------------
; movement
; he(mn): x += vx, y += vy, v *= ml, |vx|+|vy| < 0.5 -> 0
he_move ldx self
he_x    lda e_vxl,x
        ora e_vxf,x
        beq he_y
        jsr add_vx
he_y    lda e_vyl,x
        ora e_vyf,x
        beq he_f
        jsr add_vy
he_f    ldy e_cls,x
        lda c_ml,y
he_ml   sta he_m
        beq he_z            ; ml = 1
        lda e_vxf,x
        sta m_v
        lda e_vxl,x
        sta m_v+1
        lda he_m
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
        lda he_m
        jsr mulf
        ldx self
        lda m_v
        sta e_vyf,x
        lda m_v+1
        sta e_vyl,x
he_z    ; |vx| + |vy| < 0.5
        lda e_vxl,x
        bmi he_z1
        bne he_d            ; >= 1
        lda e_vxf,x
        jmp he_z2
he_z1   cmp #$ff
        bne he_d
        lda #0
        sec
        sbc e_vxf,x
        beq he_d            ; exactly -1.0
he_z2   sta tmp
        lda e_vyl,x
        bmi he_z3
        bne he_d
        lda e_vyf,x
        jmp he_z4
he_z3   cmp #$ff
        bne he_d
        lda #0
        sec
        sbc e_vyf,x
        beq he_d
he_z4   clc
        adc tmp
        bcs he_d
        cmp #128
        bcs he_d
        lda #0
        sta e_vxf,x
        sta e_vxl,x
        sta e_vyf,x
        sta e_vyl,x
he_d    rts
he_m    dta 0

; x += vx (24 bit + signed 8.8)
add_vx  lda e_xf,x
        clc
        adc e_vxf,x
        sta e_xf,x
        lda e_vxl,x
        bmi av_n
        adc e_xl,x
        sta e_xl,x
        bcc av_d
        inc e_xh,x
av_d    rts
av_n    adc e_xl,x
        sta e_xl,x
        bcs av_d
        dec e_xh,x
        rts
add_vy  lda e_yf,x
        clc
        adc e_vyf,x
        sta e_yf,x
        lda e_yl,x
        adc e_vyl,x
        sta e_yl,x
        rts
add_vz  lda e_zf,x
        clc
        adc e_vzf,x
        sta e_zf,x
        lda e_vzl,x
        bmi az_n
        adc e_zl,x
        sta e_zl,x
        bcc az_d
        inc e_zh,x
az_d    rts
az_n    adc e_zl,x
        sta e_zl,x
        bcs az_d
        dec e_zh,x
        rts

; ru(c, dx, dy): mv_dx / mv_dy signed 8.8.  c.dx = dx; walking flag;
; x += dx; y += dy
ru_move ldx self
        lda mv_dx+1
        bmi rm_dn
        bne rm_dp
        lda mv_dx
        bne rm_dp
        lda #0
        beq rm_ds
rm_dn   lda #$ff
        bne rm_ds
rm_dp   lda #1
rm_ds   sta e_dx,x
        ; |dx|+|dy| > 0.01 (3/256)
        lda mv_dx
        ldy mv_dx+1
        jsr abs88
        sta tmp
        sty tmp+1
        lda mv_dy
        ldy mv_dy+1
        jsr abs88
        clc
        adc tmp
        sta tmp
        tya
        adc tmp+1
        bne rm_w
        lda tmp
        cmp #3
        bcs rm_w
        lda #0
        sta e_gjon,x
        beq rm_mv
rm_w    lda e_gjon,x
        bne rm_mv
        lda #1
        sta e_gjon,x
        lda frames
        sta e_gjl,x
        lda frames+1
        sta e_gjh,x
rm_mv   lda e_xf,x
        clc
        adc mv_dx
        sta e_xf,x
        lda mv_dx+1
        bmi rm_xn
        adc e_xl,x
        sta e_xl,x
        bcc rm_y
        inc e_xh,x
        jmp rm_y
rm_xn   adc e_xl,x
        sta e_xl,x
        bcs rm_y
        dec e_xh,x
rm_y    lda e_yf,x
        clc
        adc mv_dy
        sta e_yf,x
        lda e_yl,x
        adc mv_dy+1
        sta e_yl,x
        rts
mv_dx   dta a(0)
mv_dy   dta a(0)

; |A:Y| (signed 8.8, lo in A) -> A:Y
abs88   cpy #$80
        bcc ab_d
        eor #$ff
        clc
        adc #1
        pha
        tya
        eor #$ff
        adc #0
        tay
        pla
ab_d    rts

; l_(v): keep inside the floor; x too unless it is a monster
clamp_pos
        ldx self
clamp_x ldy e_cls,x
        lda c_mon,y
        bne cp_y
clamp_xy
        lda e_xh,x
        bmi cp_x0
        bne cp_x1
        lda e_xl,x
        bmi cp_x1
        cmp #127
        bcc cp_y            ; 0..126.99
        lda e_xf,x
        beq cp_y            ; 127.0
cp_x1   lda #127
        sta e_xl,x
        lda #0
        sta e_xh,x
        sta e_xf,x
        jmp cp_y
cp_x0   lda #0
        sta e_xl,x
        sta e_xh,x
        sta e_xf,x
cp_y    lda e_yl,x
        cmp #80
        bcs cp_y1
        lda #80
        sta e_yl,x
        lda #0
        sta e_yf,x
        rts
cp_y1   cmp #101
        bcc cp_d
        bne cp_y2
        lda e_yf,x
        beq cp_d
cp_y2   lda #101
        sta e_yl,x
        lda #0
        sta e_yf,x
cp_d    rts

; k_(c): hovering, z = sin(t/60) * 2.5 - 2.5
hover   lda ang120+1        ; t/60 turns = frames/120 turns
        jsr psin
        lda m_u
        sta m_v
        lda m_u+1
        sta m_v+1
        ; * 2.5 = *2 + /2
        lda m_v
        asl
        sta tmp
        lda m_v+1
        rol
        sta tmp+1
        lda m_v+1
        cmp #$80
        ror
        sta tmp+3
        lda m_v
        ror
        clc
        adc tmp
        sta tmp
        lda tmp+3
        adc tmp+1
        sta tmp+1           ; sin*2.5 (8.8)
        ldx self
        lda tmp
        sec
        sbc #$80
        sta e_zf,x
        lda tmp+1
        sbc #2
        sta e_zl,x
        ldy #0              ; z is -5..0: sign extend
        cmp #$80
        bcc hv_p
        dey
hv_p    tya
        sta e_zh,x
        rts

; byte angle for frames/120 turns: (frames mod 120) * 256 / 120
ang_div120
        ldx #120
        jsr mod_frames
        ; A*256/120 = A*32/15
        sta m_n+1
        lda #0
        sta m_n
        lda #120
        sta m_d
        lda #0
        sta m_d+1
        jsr div16
        lda m_q
        rts

; kk(c): he, l_ (not the boss), hover, death
kk_move jsr he_move
        ldx self
        cpx boss
        beq kk_1
        jsr clamp_x
kk_1    ldx self
        ldy e_cls,x
        lda c_ow,y
        beq kk_2
        jsr hover
kk_2    ; kb(c.pa >= c.qg, c, "dt")
        ldx self
        ldy e_cls,x
        lda e_pal,x
        cmp c_qg,y
        bcc kk_d
        lda #S_DT
        ldy #$ff
        jmp set_state
kk_d    rts

; ------------------------------------------------------------------
; fp(e, box, group, cb): queue an attack.  A = box, X = group bit,
; Y = callback (0 hit_player, 1 hit_monster, 2 hit_proj, 3 hit_radar)
attack  stx tmp
        ldx hu_n
        cpx #MAXHU
        bcs at_d
        sta hu_box,x
        lda tmp
        sta hu_grp,x
        tya
        sta hu_cb,x
        lda self
        sta hu_e,x
        inc hu_n
at_d    rts

; box of entity X with hitbox A -> bx1 (24 bit), bx2, by1, by2 (16 bit)
hit_box tay
        lda of_y1,y
        sta hb_dy1
        lda of_y2,y
        sta hb_dy2
        lda e_qn,x
        bmi hb_f
        lda of_x1,y
        sta hb_dx1
        lda of_x2,y
        sta hb_dx2
        jmp hb_c
hb_f    lda #0
        sec
        sbc of_x2,y
        sta hb_dx1
        lda #0
        sec
        sbc of_x1,y
        sta hb_dx2
hb_c    ; x1 = x + dx1 ...
        lda hb_dx1
        jsr hb_addx
        sta hb_x1+2
        sty hb_x1+1
        lda e_xf,x
        sta hb_x1
        lda hb_dx2
        jsr hb_addx
        sta hb_x2+2
        sty hb_x2+1
        lda e_xf,x
        sta hb_x2
        lda e_yl,x
        clc
        adc hb_dy1
        sta hb_y1+1
        lda e_yl,x
        clc
        adc hb_dy2
        sta hb_y2+1
        lda e_yf,x
        sta hb_y1
        sta hb_y2
        rts
; (int part of x) + signed A -> Y = low, A = high
hb_addx sta tmp
        clc
        adc e_xl,x
        tay
        lda tmp
        bmi hba_n
        lda e_xh,x
        adc #0
        rts
hba_n   lda e_xh,x
        adc #$ff
        rts
hb_dx1  dta 0
hb_dx2  dta 0
hb_dy1  dta 0
hb_dy2  dta 0
hb_x1   dta 0,0,0
hb_x2   dta 0,0,0
hb_y1   dta 0,0
hb_y2   dta 0,0

; jf(): hurtbox of entity X -> A (0 = none)
hurtbox ldy e_cls,x
        lda c_grp,y
        and #G_KS
        beq hu_proj
        ; gd(c): z >= -5, t >= rj, state not oo/qi/dt/ok
        lda e_zh,x
        bpl hu_z
        cmp #$ff
        bne hu_none
        lda e_zl,x
        cmp #<(-5)
        bcc hu_none
hu_z    lda frames
        cmp e_rjl,x
        lda frames+1
        sbc e_rjh,x
        bvc hu_v
        eor #$80
hu_v    bmi hu_none
        lda e_st,x
        cmp #S_OO
        beq hu_none
        cmp #S_QI
        beq hu_none
        cmp #S_DT
        beq hu_none
        cmp #S_OK
        beq hu_none
        cmp #S_DE
        bne hu_sm
        lda #15
        rts
hu_sm   lda c_sm,y
        rts
hu_proj lda #6
        rts
hu_none lda #0
        rts

; sl(): resolve the queued attacks
resolve_attacks
        lda #0
        sta ra_i
ra_l    ldx ra_i
        cpx hu_n
        jcs ra_done
        lda hu_e,x
        sta ra_att
        lda hu_box,x
        pha
        lda hu_grp,x
        sta ra_grp
        lda hu_cb,x
        sta ra_cb
        ldx ra_att
        pla
        jsr hit_box
        ldx #5
ra_cp   lda hb_x1,x
        sta ra_a,x
        dex
        bpl ra_cp
        lda hb_y1+1
        sta ra_ay1
        lda hb_y1
        sta ra_ayf
        lda hb_y2+1
        sta ra_ay2
        ; targets (the player group is the hero alone)
        lda #0
        sta ra_j
        lda ra_grp
        cmp #G_PLAYER
        bne ra_t
        lda eg
        sta ra_j
        lda #1
        sta ra_one
ra_t    ldx ra_j
        ldy e_cls,x
        jeq ra_tn
        lda c_grp,y
        and ra_grp
        jeq ra_tn
        jsr hurtbox
        jeq ra_tn
        ldx ra_j
        jsr hit_box
        ; a.x2 >= b.x1 and b.x2 >= a.x1 and a.y2 >= b.y1 and b.y2 >= a.y1
        lda ra_a+3
        cmp hb_x1
        lda ra_a+4
        sbc hb_x1+1
        lda ra_a+5
        sbc hb_x1+2
        bvc ra_v1
        eor #$80
ra_v1   bmi ra_tn
        lda hb_x2
        cmp ra_a
        lda hb_x2+1
        sbc ra_a+1
        lda hb_x2+2
        sbc ra_a+2
        bvc ra_v2
        eor #$80
ra_v2   bmi ra_tn
        ; y (unsigned 8.8; boxes stay within 0..255)
        lda ra_ayf
        cmp hb_y1
        lda ra_ay2
        sbc hb_y1+1
        bcc ra_tn
        lda hb_y2
        cmp ra_ayf
        lda hb_y2+1
        sbc ra_ay1
        bcc ra_tn
        ; hit: callback of the attacker's class
        ldx ra_att
        lda e_cls,x
        beq ra_tn
        tay
        lda ra_cb
        asl
        tax
        lda cbt_lo,x
        sta ptr
        lda cbt_lo+1,x
        sta ptr+1
        lda (ptr),y
        sta ra_jmp+1
        lda cbt_hi,x
        sta ptr
        lda cbt_hi+1,x
        sta ptr+1
        lda (ptr),y
        sta ra_jmp+2
        lda ra_att
        sta self
        lda ra_j
        sta other
ra_jmp  jsr h_none
ra_tn   lda ra_one
        bne ra_n1
        inc ra_j
        lda ra_j
        cmp ent_top
        jcc ra_t
ra_n1   lda #0
        sta ra_one
        inc ra_i
        jmp ra_l
ra_done lda #0
        sta hu_n
        rts
cbt_lo  dta a(cb_hit_player_lo),a(cb_hit_monster_lo),a(cb_hit_proj_lo),a(cb_hit_radar_lo)
cbt_hi  dta a(cb_hit_player_hi),a(cb_hit_monster_hi),a(cb_hit_proj_hi),a(cb_hit_radar_hi)
ra_i    dta 0
ra_j    dta 0
ra_one  dta 0
ra_att  dta 0
ra_grp  dta 0
ra_cb   dta 0
ra_a    dta 0,0,0,0,0,0
ra_ay1  dta 0
ra_ayf  dta 0
ra_ay2  dta 0

; call a class callback: A = table index (CB_EC, CB_RA, CB_DU, CB_KC),
; X = entity (self).  C as returned (C = 0 when the class has none).
CB_EC   = 0
CB_RA   = 1
CB_DU   = 2
CB_KC   = 3
call_cb asl
        tay
        lda cb2_lo,y
        sta ptr
        lda cb2_lo+1,y
        sta ptr+1
        lda cb2_hi,y
        sta ptr2
        lda cb2_hi+1,y
        sta ptr2+1
        ldy e_cls,x
        lda (ptr),y
        sta cc_j+1
        lda (ptr2),y
        sta cc_j+2
cc_j    jmp h_none
cb2_lo  dta a(cb_ec_lo),a(cb_ra_lo),a(cb_du_lo),a(cb_kc_lo)
cb2_hi  dta a(cb_ec_hi),a(cb_ra_hi),a(cb_du_hi),a(cb_kc_hi)

; ------------------------------------------------------------------
; drawables.  cw(target X, kind A, layer Y ($ff = the target's y)) ->
; X = drawable.  Slots 0 and 1 are the named ones: "lasthit", "combo".
D_LASTHIT = 0
D_COMBO = 1
draw_new
        sta tmp
        sty tmp+1
        stx tmp+2
        ldx #2
dn_f    lda d_kind,x
        beq dn_got
        inx
        cpx #MAXD
        bne dn_f
        rts                 ; none free: not drawn
dn_got
draw_set                    ; (X = slot)
        lda tmp
        sta d_kind,x
        lda tmp+1
        sta d_layer,x
        lda tmp+2
        sta d_ent,x
        lda #0
        sta d_t,x
        sta d_th,x
        sta d_a,x
        sta d_b,x
        sta d_c,x
        rts
; named slot: A = kind, Y = layer, X = target, d_named = slot
draw_named
        sta tmp
        sty tmp+1
        stx tmp+2
        ldx d_named
        jmp draw_set
d_named dta 0
