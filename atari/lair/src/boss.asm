; ------------------------------------------------------------------
; The boss: intro, hovering, summoning, vulnerable phase, death.
; Its z (24 bit) goes far above the screen.
; ------------------------------------------------------------------

; ie(b, tm): gf - the intro
h_ie    ; nt = {lg, sq(150 - tm, 5, 2)} = clamp(flr((300 - frames)/10), 0, 2):
        ; frames <= 280 -> 2, 281..290 -> 1, else 0
        ldx self
        lda e_th,x
        bne ie_l0
        lda e_tl,x
        cmp #<281
        bcc ie_l2
        cmp #<291
        bcc ie_l1
ie_l0   lda #0
        beq ie_lv
ie_l1   lda #1
        bne ie_lv
ie_l2   lda #2
ie_lv   sta nt_lvl
        lda #2
        sta nt_tab          ; lg
        ; tm == 0: set up
        lda #0
        jsr tm_eq
        jne ie_1
        ldx self
        stx boss
        lda #0
        sta e_xf,x
        sta e_xh,x
        sta e_yf,x
        sta e_zf,x
        lda #64
        sta e_xl,x
        lda #79
        sta e_yl,x
        lda #$80            ; z = -167.5
        sta e_zf,x
        lda #<(-168)
        sta e_zl,x
        lda #>(-168)
        sta e_zh,x
        lda #$ff
        jsr music
        ; ef(b, eg, 15); eg.pa, eg.oh, eg.bv = 0, 0, 2
        lda eg
        sta other
        lda #0
        sta dmg
        lda #15
        sta dmg+1
        jsr deal
        ldx eg
        lda #0
        sta e_paf,x
        sta e_pal,x
        sta pl_ohf
        sta pl_ohl
        lda #2
        sta pl_bv
        ; the aura: pm({jw=0, ml=1, cs=0.04, ja=1, bp=1}, 0, fi(b, b.z-16, ...))
        lda #T_BOSS
        jsr ps_new
        bcs ie_1
        lda #EM_FI
        sta ps_kind,x
        lda #FI_BOSS
        sta ps_a,x
        lda self
        sta ps_own,x
        lda #0
        sta ps_d,x
        lda #$ff
        sta ps_e,x
        lda #2              ; z = owner z * 2 - 16: see emit_fi (ps_c = 2)
        sta ps_c,x
        lda #<(-16)
        sta ps_b,x
ie_1    lda #80             ; tm == 40
        jsr tm_eq
        bne ie_2
        lda #23
        jsr music
        lda #<t_far
        sta ptr
        lda #>t_far
        sta ptr+1
        lda #80
        sta eq_ol
        lda #110
        sta eq_sy
        lda #2
        sta eq_iuv
        lda #0
        sta eq_env          ; en = 0.2
        lda #<492           ; dh = 0.12 (4.12)
        sta eq_dhv
        lda #>492
        sta eq_dhv+1
        lda #14
        jsr eq_start
ie_2    ; if hr(rc.p_) and abs(tm - 150) <= 50 then qx()
        ldx self
        lda e_th,x
        ldy e_tl,x
        ; frames 200..400
        cmp #0
        bne ie_h1
        cpy #200
        bcc ie_3
        bcs ie_h2
ie_h1   cmp #1
        bne ie_3
        cpy #<400+1
        bcs ie_3
ie_h2   jsr hr_p
        bne ie_3
        jsr qx_rock
ie_3    ; tm == 230: lp(b, "ox"); b.t = 90
        lda #<460
        ldy #>460
        jsr tm_eq16
        bne ie_4
        ldx self
        lda #S_OX
        ldy #$ff
        jsr set_state
        ldx self
        lda #180
        sta e_tl,x
        lda #0
        sta e_th,x
ie_4    ; tm >= 65: b.z += 1.4 - b.t/163 (frames * 201/256 / 256)
        ldx self
        lda e_th,x
        bne ie_5
        lda e_tl,x
        cmp #130
        bcc ie_d
ie_5    ; dz = 1.4 - tm/163 (8.8) = 358 - (frames*201 >> 8)
        lda e_tl,x
        ldx #201
        jsr umul8
        lda m_hi
        sta tmp+2
        lda #0
        sta tmp+3
        ldx self
        lda e_th,x
        beq ie_6
        lda tmp+2
        clc
        adc #201
        sta tmp+2
        lda #0
        adc #0
        sta tmp+3
ie_6    lda #<358
        sec
        sbc tmp+2
        sta tmp
        lda #>358
        sbc tmp+3
        sta tmp+1
        ldx self
        lda e_zf,x
        clc
        adc tmp
        sta e_zf,x
        lda e_zl,x
        adc tmp+1
        sta e_zl,x
        lda tmp+1
        and #$80
        beq ie_7
        lda #$ff
ie_7    adc e_zh,x
        sta e_zh,x
ie_d    clc
        rts

; Z = 1 when the state time equals A + 256*Y frames
tm_eq16 ldx self
        cmp e_tl,x
        bne te16
        tya
        cmp e_th,x
te16    rts

; hr(rc.p_): Z = 1 when frames % (2 p_) == 0
hr_p    ldy kh
        lda qd_p_,y
        asl
        tax
        jsr mod_frames
        rts

; qx(): a rock falls from above: rq("lz", pq({z=-180, jw=0.125, es=100}), fo)
qx_rock lda #C_LZ
        jsr ent_new
        bcs qx_d
        stx qx_e
        jsr pq_rand
        ldx qx_e
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
        lda #<(-180)
        sta e_zl,x
        lda #>(-180)
        sta e_zh,x
        lda #32
        sta e_jw,x
        lda #100
        sta e_es,x
        lda #R_FO
        ldy #$ff
        jsr draw_new
qx_d    rts
qx_e    dta 0

; z = z * 0.967 + target * 0.033 (ej towards A: 0 or -40)
; z -= (z - target) >> 5
boss_ej sta be_t
        ldx self
        ; d = z - target (24 bit)
        lda e_zf,x
        sta tmp
        lda e_zl,x
        sec
        sbc be_t
        sta tmp+1
        lda be_t
        bmi be_n
        lda e_zh,x
        sbc #0
        jmp be_1
be_n    lda e_zh,x
        sbc #$ff
be_1    sta tmp+2
        ldy #5
be_s    lda tmp+2
        cmp #$80
        ror tmp+2
        ror tmp+1
        ror tmp
        dey
        bne be_s
        lda e_zf,x
        sec
        sbc tmp
        sta e_zf,x
        lda e_zl,x
        sbc tmp+1
        sta e_zl,x
        lda e_zh,x
        sbc tmp+2
        sta e_zh,x
        rts
be_t    dta 0

; ep(b, tm): ox - hovering
h_ep    ldx self
        ; if b.z < -5
        lda e_zh,x
        bpl ep_k
        cmp #$ff
        bne ep_e
        lda e_zl,x
        cmp #<(-5)
        bcs ep_k
ep_e    lda #0
        jsr boss_ej
        jmp ep_1
ep_k    jsr hover
ep_1    ; tm >= rc.kg and #ma("monster") < 5: summon
        ldy kh
        lda qd_kg,y
        sta tmp+4
        ldx self
        ; frames >= 2*kg (kg <= 150: up to 300)
        lda tmp+4
        asl
        sta tmp+5
        lda #0
        rol
        sta tmp+6
        lda e_tl,x
        cmp tmp+5
        lda e_th,x
        sbc tmp+6
        bcc ep_2
        lda #G_MONSTER
        jsr group_count
        cmp #5
        bcs ep_2
        ldx self
        lda #S_ND
        ldy #$ff
        jsr set_state
ep_2    jsr iw_vuln
        clc
        rts

; iw(b): the vulnerable phase (flash, its end) and kk
iw_vuln lda boss_kton
        beq iw_k
        ; nt = {hf, 9 - (t - kt)}
        lda frames
        sec
        sbc boss_ktl
        sta tmp
        lda frames+1
        sbc boss_kth
        sta tmp+1
        bmi iw_l4           ; kt in the future (hits pushed it): level 4
        bne iw_l0
        ; level = flr((18 - frames) / 2), up to 4
        lda #18
        sec
        sbc tmp
        bcc iw_l0
        lsr
        beq iw_l0
        cmp #5
        bcc iw_l
iw_l4   lda #4
iw_l    sta nt_lvl
        lda #1
        sta nt_tab          ; hf
        jmp iw_c
iw_l0   lda #0
        sta nt_lvl
iw_c    ; kb(t - b.kt > 150, b, "jh")
        lda tmp+1
        bmi iw_k
        cmp #>301
        bcc iw_k
        bne iw_j
        lda tmp
        cmp #<301
        bcc iw_k
iw_j    ldx self
        lda #S_JH
        ldy #$ff
        jsr set_state
iw_k    jmp kk_move

; eu(b, tm): jh - rises again
h_eu    lda #<(-40)
        jsr boss_ej
        jsr hr_p
        bne eu_1
        jsr qx_rock
eu_1    lda #60             ; tm == 30
        jsr tm_eq
        bne eu_2
        lda #0
        sta boss_kton
eu_2    lda #120            ; tm == 60
        jsr tm_eq
        bne eu_d
        ldx self
        lda #S_OX
        ldy #$ff
        jsr set_state
eu_d    clc
        rts

; dw(b, tm): nd - summons
h_dw    jsr hover
        lda #1              ; tm == 0.5
        jsr tm_eq
        bne dw_1
        lda #<(-13)
        sta lr_dx
        lda #2
        sta lr_dy
        lda #<(-26)
        sta lr_dz
        lda #25
        sta lr_r
        lda #15
        sta lr_oe
        ldx self
        jsr lr_start
        ldx self
        sta e_ku,x
        tya
        sta e_kug,x
        lda #48
        jsr kl
dw_1    lda #40             ; tm == 20
        jsr tm_eq
        bne dw_2
        ; sk(nl(qp[kh]), bt)
        ldy kh
        lda qp_lo,y
        sta ptr
        lda qp_hi,y
        sta ptr+1
        ldy #0
        lda (ptr),y         ; count
        jsr rnd_mul
        asl
        tay
        iny
        lda (ptr),y
        sta dw_s
        iny
        lda (ptr),y
        sta dw_s+1
        lda #0
        sta dw_i
dw_l    lda dw_s
        sta ptr
        lda dw_s+1
        sta ptr+1
        ldy dw_i
        lda (ptr),y
        beq dw_e
        jsr summon
        inc dw_i
        jmp dw_l
dw_e    ldx self
        lda #S_OX
        ldy #$ff
        jsr set_state
dw_2    jsr iw_vuln
        clc
        rts
dw_s    dta 0,0
dw_i    dta 0

; bt(bo): summon one monster of class A on the far side of the hero
summon  jsr ent_new
        bcc sm_ok
        rts
sm_ok   stx sm_e
        jsr pq_rand
        ldx sm_e
        ; x = (eg.x + im(56, 72)) % 128
        lda #16
        jsr rnd_mul
        ldy eg
        clc
        adc e_xl,y
        clc
        adc #56
        and #127
        ldx sm_e
        sta e_xl,x
        lda #0
        sta e_xh,x
        lda pq_xf
        sta e_xf,x
        lda pq_yf
        sta e_yf,x
        lda pq_yl
        sta e_yl,x
        ; t = 15, pf = "ok"
        lda #S_OK
        sta e_st,x
        lda #30
        sta e_tl,x
        lda #R_RT
        ldy #$ff
        jsr draw_new
        ; pm({jw=0, cs=0.025, ml=0.96}, 16, fi(px, 0, ...))
        lda #T_SUMM
        jsr ps_new
        bcs sm_d
        stx ps
        lda #EM_FI
        sta ps_kind,x
        lda #FI_SUMM
        sta ps_a,x
        lda sm_e
        sta ps_own,x
        lda #0
        sta ps_b,x
        sta ps_d,x
        lda #1
        sta ps_c,x
        lda #$ff
        sta ps_e,x
        lda #16
        sta tmp+7
sm_l    ldx ps
        jsr emit_fi
        dec tmp+7
        bne sm_l
        ldx ps
        lda #0
        sta ps_em,x
sm_d    rts
sm_e    dta 0

; rr(b, p, s_): ec of the boss.  X = the boss, self = the hero.
h_rr    lda boss_kton
        beq rr_shield
        ; b.kt -= s_*2 (frames: dmg * 4)
        lda dmg
        sta tmp
        lda dmg+1
        asl tmp
        rol
        asl tmp
        rol
        sta tmp+1           ; dmg*4 (integer part)
        lda boss_ktl
        sec
        sbc tmp+1
        sta boss_ktl
        lda boss_kth
        sbc #0
        sta boss_kth
        clc
        rts
rr_shield
        lda #53
        jsr kl
        ; eg.vx, eg.vy = ho(b, eg, 2)
        lda #0
        sta ho_s
        lda #2
        sta ho_s+1
        ldx boss
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
        lda #G_CRST
        jsr group_count
        bne rr_1
        lda #BK_CRST
        jsr summon
rr_1    ; cw(b, kr, 85)
        ldx boss
        lda #R_KR
        ldy #85
        jsr draw_new
        sec
        rts

; qu(b, tm): dt of the boss
h_qu    lda #1              ; tm == 0.5
        jsr tm_eq
        bne qu_1
        lda #$ff
        jsr music
        ldx self
        lda #0
        sta e_zf,x
        sta e_zl,x
        sta e_zh,x
        lda #T_QR
        jsr ps_new
        bcs qu_0
        stx boss_qr
qu_0    ; every monster dies, one after the other
        lda #20
        sta tmp+4
        ldx #MAXE-1
qu_l    lda e_cls,x
        beq qu_n
        tay
        lda c_mon,y
        beq qu_n
        lda tmp+4
        sta e_il,x
        lda #0
        sta e_gjon,x
        lda #255
        sta e_pal,x
        lda tmp+4
        clc
        adc #20
        bcc qu_c
        lda #255
qu_c    sta tmp+4
qu_n    dex
        bpl qu_l
qu_1    ; b.x, b.y = im(62, 66), im(79, 82)
        ldx self
        jsr rnd8
        sta e_xf,x
        lda #4
        jsr rnd_mul
        clc
        adc #62
        ldx self
        sta e_xl,x
        lda #0
        sta e_xh,x
        jsr rnd8
        sta e_yf,x
        lda #3
        jsr rnd_mul
        clc
        adc #79
        ldx self
        sta e_yl,x
        ; tm <= 120: rising rings
        lda #241
        jsr tm_ge
        bcs qu_2
        jsr qu_ring
        ldx #12             ; hr(6)
        jsr mod_frames
        bne qu_2
        lda #62
        jsr kl
qu_2    lda #240            ; tm == 120: falls apart
        jsr tm_eq
        bne qu_3
        jsr ft_burst
        ldx self
        lda #0
        sta e_dg,x
        lda #1
        sta e_nb,x
qu_3    lda #<420           ; return tm == 210
        ldy #>420
        jsr tm_eq16
        bne qu_n2
        sec
        rts
qu_n2   clc
        rts

; one ring particle: {vz=-0.8, oe=12, x=b.x+im0(15), y=b.y+4, z=-im(2,29), je=im(2,6)}
qu_ring lda boss_qr
        cmp #$ff
        beq qr_d
        sta ps
        jsr p_new_ps
        bcs qr_d
        ldy self
        jsr p_at_ent
        lda #30
        jsr rnd_mul
        sec
        sbc #15
        ldx em_pp
        jsr px_add
        lda p_yl,x
        clc
        adc #4
        sta p_yl,x
        lda #27
        jsr rnd_mul
        clc
        adc #2
        eor #$ff
        clc
        adc #1
        sta p_zl,x
        lda #$ff
        sta p_zh,x
        lda #$33            ; vz = -0.8
        sta p_vzf,x
        lda #$ff
        sta p_vzl,x
        lda #12
        sta p_oe,x
        lda #4
        jsr rnd_mul
        clc
        adc #2
        ldx em_pp
        sta p_je,x
qr_d    rts
