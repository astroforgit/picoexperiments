; ------------------------------------------------------------------
; Particle systems: the cart's pm() (create), iy() (update) and kv()
; (draw), with their emitters.  A system holds a linked list of
; particles from a shared pool.  Life (es) is 4.12 fixed point.
; ------------------------------------------------------------------

; system templates: ja (255 = 1.0, 0 = none), cs (16 bit, 4.12), ml, jw,
; ir, bp
T_LR    = 0
T_EQ    = 1
T_EQ0   = 2         ; text that stays (cs = 0)
T_TRAIL = 3
T_DEATH = 4
T_PICK  = 5
T_KX    = 6
T_AURA  = 7
T_STAR  = 8
T_BOSS  = 9
T_QR    = 10
T_SUMM  = 11
tp_em   dta 1,1,1,1,0,0,0,1,1,1,1,0
tp_ja   dta 255,255,255,255,0,0,0,154,255,255,0,0
tp_csl  dta <287,<164,0,<205,<51,<102,<287,<123,<410,<164,<164,<102
tp_csh  dta >287,>164,0,>205,>51,>102,>287,>123,>410,>164,>164,>102
tp_ml   dta 0,0,0,0,251,246,0,0,0,0,243,246
tp_jw   dta 0,26,26,0,26,0,51,0,0,0,0,0
tp_ir   dta 0,102,102,0,102,0,0,0,0,0,0,0
tp_bp   dta 0,1,1,1,0,1,0,1,0,1,1,0

; emitters
EM_NONE = 0
EM_LR   = 1
EM_FI   = 2
EM_EQ   = 3

part_reset
        ldx #0
pr_l    txa
        clc
        adc #1
        sta p_next,x
        inx
        cpx #MAXP
        bne pr_l
        lda #$ff
        sta p_next+MAXP-1   ; the last particle ends the free list
        lda #0
        sta p_free
        rts
p_free  dta 0

; ps_new: A = template -> X = system (C = 1 none free); ps_gen bumped
ps_new  sta tmp
        ldx #0
pn_f    lda ps_on,x
        beq pn_got
        inx
        cpx #MAXPS
        bne pn_f
        sec
        rts
pn_got  lda #1
        sta ps_on,x
        inc ps_gen,x
        ldy tmp
        lda tp_em,y
        sta ps_em,x
        lda tp_ja,y
        sta ps_ja,x
        lda tp_csl,y
        sta ps_cs,x
        lda tp_csh,y
        sta ps_csh,x
        lda tp_ml,y
        sta ps_ml,x
        lda tp_jw,y
        sta ps_jw,x
        lda tp_ir,y
        sta ps_ir,x
        lda tp_bp,y
        sta ps_bp,x
        lda #$ff
        sta ps_head,x
        lda #EM_NONE
        sta ps_kind,x
        lda #0
        sta ps_y,x
        clc
        rts

; ps_stop: A = system ($ff none), Y = its gen: stop emitting (ku.ja = nil)
; keeps X
ps_stop cmp #$ff
        beq pst_d
        stx pst_x
        tax
        lda ps_on,x
        beq pst_r
        tya
        cmp ps_gen,x
        bne pst_r
        lda #0
        sta ps_em,x
pst_r   ldx pst_x
pst_d   rts
pst_x   dta 0

; p_new: new particle in system ps -> X (C = 1 none free); fields zeroed,
; es = 1.0
p_new   ldx p_free
        cpx #$ff
        bne pw_ok
        sec
        rts
pw_ok   lda p_next,x
        sta p_free
        ldy ps
        lda ps_head,y
        sta p_next,x
        txa
        sta ps_head,y
        lda #0
        sta p_xf,x
        sta p_xl,x
        sta p_xh,x
        sta p_yf,x
        sta p_yl,x
        sta p_zf,x
        sta p_zl,x
        sta p_zh,x
        sta p_vxf,x
        sta p_vxl,x
        sta p_vyf,x
        sta p_vyl,x
        sta p_vzf,x
        sta p_vzl,x
        sta p_esf,x
        sta p_ko,x
        sta p_je,x
        sta p_oe,x
        lda #$10            ; 1.0 in 4.12
        sta p_esl,x
        clc
        rts

; ------------------------------------------------------------------
; iy(): update all systems
part_update
        lda #0
        sta ps
pu_l    ldx ps
        lda ps_on,x
        jeq pu_n
        lda ps_ml,x
        sta pu_ml
        lda ps_jw,x
        sta pu_jw
        lda ps_ir,x
        sta pu_ir
        lda ps_cs,x
        sta pu_cs
        lda ps_csh,x
        sta pu_csh
        lda ps_bp,x
        sta pu_bp
        lda #$ff
        sta pu_prev
        lda ps_head,x
pu_p    cmp #$ff
        jeq pu_pd
        sta pp
        tax
        jsr p_physics
        ldx pp
        ; es -= cs
        lda p_esf,x
        sec
        sbc pu_cs
        sta p_esf,x
        lda p_esl,x
        sbc pu_csh
        sta p_esl,x
        bcc pu_dead
        lda pu_bp
        bne pu_nc
        jsr p_clamp
        ldx pp
pu_nc   lda p_yl,x
        ldy ps
        sta ps_y,y
        stx pu_prev
        lda p_next,x
        jmp pu_p
pu_dead ; unlink and free
        lda p_next,x
        sta tmp
        ldy pu_prev
        cpy #$ff
        bne pu_d1
        ldy ps
        sta ps_head,y
        jmp pu_d2
pu_d1   sta p_next,y
pu_d2   lda p_free
        sta p_next,x
        stx p_free
        lda tmp
        jmp pu_p
pu_pd   ; emit
        ldx ps
        lda ps_em,x
        beq pu_ne
        lda ps_ja,x
        cmp #255
        beq pu_em
        jsr chance_c
        bcc pu_ne
pu_em   jsr ps_emit
pu_ne   ldx ps
        lda ps_head,x
        cmp #$ff
        bne pu_n
        lda ps_em,x
        bne pu_n
        lda #0
        sta ps_on,x
pu_n    inc ps
        lda ps
        cmp #MAXPS
        jne pu_l
        rts
pu_ml   dta 0
pu_jw   dta 0
pu_ir   dta 0
pu_cs   dta 0
pu_csh  dta 0
pu_bp   dta 0
pu_prev dta 0

; bu(p, ku): particle X
p_physics
        ; resting particles (no velocity) only age
        lda p_vxf,x
        ora p_vxl,x
        ora p_vyf,x
        ora p_vyl,x
        ora p_vzf,x
        ora p_vzl,x
        bne pp_mv
        lda pu_jw
        bne pp_mv
        rts
pp_mv   ; x += vx
        lda p_vxf,x
        ora p_vxl,x
        beq pp_y
        lda p_xf,x
        clc
        adc p_vxf,x
        sta p_xf,x
        lda p_vxl,x
        bmi pp_xn
        adc p_xl,x
        sta p_xl,x
        bcc pp_y
        inc p_xh,x
        jmp pp_y
pp_xn   adc p_xl,x
        sta p_xl,x
        bcs pp_y
        dec p_xh,x
pp_y    lda p_yf,x
        clc
        adc p_vyf,x
        sta p_yf,x
        lda p_yl,x
        adc p_vyl,x
        sta p_yl,x
        ; z += vz
        lda p_zf,x
        clc
        adc p_vzf,x
        sta p_zf,x
        lda p_vzl,x
        bmi pp_zn
        adc p_zl,x
        sta p_zl,x
        bcc pp_f
        inc p_zh,x
        jmp pp_f
pp_zn   adc p_zl,x
        sta p_zl,x
        bcs pp_f
        dec p_zh,x
pp_f    ; friction (every second update, squared): see p_fric
        lda pu_ml
        beq pp_g
        lda frames
        lsr
        bcs pp_g
        lda p_vxf,x
        ora p_vxl,x
        beq pp_f2
        lda p_vxf,x
        sta m_v
        lda p_vxl,x
        sta m_v+1
        jsr p_fric
        lda m_v
        sta p_vxf,x
        lda m_v+1
        sta p_vxl,x
pp_f2   lda p_vyf,x
        ora p_vyl,x
        beq pp_f3
        lda p_vyf,x
        sta m_v
        lda p_vyl,x
        sta m_v+1
        jsr p_fric
        lda m_v
        sta p_vyf,x
        lda m_v+1
        sta p_vyl,x
pp_f3   lda p_vzf,x
        ora p_vzl,x
        beq pp_g
        lda p_vzf,x
        sta m_v
        lda p_vzl,x
        sta m_v+1
        jsr p_fric
        lda m_v
        sta p_vzf,x
        lda m_v+1
        sta p_vzl,x
pp_g    ; vz += jw
        lda p_vzf,x
        clc
        adc pu_jw
        sta p_vzf,x
        bcc pp_b
        inc p_vzl,x
pp_b    ; bounce: if ir and z > 0
        lda pu_ir
        jeq pp_d
        lda p_zh,x
        jmi pp_d
        bne pp_bo
        lda p_zl,x
        ora p_zf,x
        jeq pp_d
pp_bo   ; z *= -ir, vz *= -ir, vx *= ir
        lda p_zf,x
        sta m_v
        lda p_zl,x
        sta m_v+1
        lda pu_ir
        jsr mulf
        jsr neg_v
        ldx pp
        lda m_v
        sta p_zf,x
        lda m_v+1
        sta p_zl,x
        lda #$ff
        sta p_zh,x
        lda p_vzf,x
        sta m_v
        lda p_vzl,x
        sta m_v+1
        lda pu_ir
        jsr mulf
        jsr neg_v
        ldx pp
        lda m_v
        sta p_vzf,x
        lda m_v+1
        sta p_vzl,x
        lda p_vxf,x
        sta m_v
        lda p_vxl,x
        sta m_v+1
        lda pu_ir
        jsr mulf
        ldx pp
        lda m_v
        sta p_vxf,x
        lda m_v+1
        sta p_vxl,x
        ; |vz| < 0.5: rest
        lda p_vzl,x
        beq pp_r1
        cmp #$ff
        bne pp_d
        lda p_vzf,x
        cmp #$81
        bcc pp_d
        bcs pp_rest
pp_r1   lda p_vzf,x
        cmp #$80
        bcs pp_d
pp_rest lda #0
        sta p_vxf,x
        sta p_vxl,x
        sta p_vyf,x
        sta p_vyl,x
        sta p_vzf,x
        sta p_vzl,x
        sta p_zf,x
        sta p_zl,x
        sta p_zh,x
pp_d    rts

; friction on even updates with the squared factor (the same decay):
; m_v -= m_v * k / 256 with k = 256 - ml^2/256 -- 0.98: k 10 (>>5 + >>7),
; 0.96: k 20 (>>4 + >>6), 0.95: k 25 (>>4 + >>5 + >>8); keeps X
p_fric  lda m_v+1
        sta pf_t            ; s8 = v >> 8: the high byte, sign extended
        cmp #$80
        lda #0
        bcc pf_p
        lda #$ff
pf_p    sta pf_th
        lda m_v+1           ; s4 = v >> 4
        sta pf_5h
        lda m_v
        sta pf_5
        ldy #4
pf_s    lda pf_5h
        cmp #$80
        ror pf_5h
        ror pf_5
        dey
        bne pf_s
        lda pu_ml
        cmp #251
        beq pf_98
        ; 0.96 / 0.95: d = s4 + (s6 or s5)
        lda pf_5
        sta pf_d
        lda pf_5h
        sta pf_dh
        jsr pf_sh           ; s5
        lda pu_ml
        cmp #243
        beq pf_95
        jsr pf_sh           ; s6
        jsr pf_add5
        jmp pf_sub
pf_95   jsr pf_add5         ; + s5 + s8
        jsr pf_addt
        jmp pf_sub
pf_98   ; d = s5 + s7
        jsr pf_sh           ; s5
        lda pf_5
        sta pf_d
        lda pf_5h
        sta pf_dh
        jsr pf_sh
        jsr pf_sh           ; s7
        jsr pf_add5
pf_sub  lda m_v
        sec
        sbc pf_d
        sta m_v
        lda m_v+1
        sbc pf_dh
        sta m_v+1
        rts
pf_sh   lda pf_5h
        cmp #$80
        ror pf_5h
        ror pf_5
        rts
pf_add5 lda pf_d
        clc
        adc pf_5
        sta pf_d
        lda pf_dh
        adc pf_5h
        sta pf_dh
        rts
pf_addt lda pf_d
        clc
        adc pf_t
        sta pf_d
        lda pf_dh
        adc pf_th
        sta pf_dh
        rts
pf_5    dta 0
pf_5h   dta 0
pf_d    dta 0
pf_dh   dta 0
pf_t    dta 0
pf_th   dta 0

; l_(p) for a particle: x 0..127, y 80..101
p_clamp lda p_xh,x
        bmi pc_x0
        bne pc_x1
        lda p_xl,x
        bpl pc_y
pc_x1   lda #127
        sta p_xl,x
        lda #0
        sta p_xh,x
        sta p_xf,x
        jmp pc_y
pc_x0   lda #0
        sta p_xl,x
        sta p_xh,x
        sta p_xf,x
pc_y    lda p_yl,x
        cmp #80
        bcs pc_y1
        lda #80
        sta p_yl,x
        lda #0
        sta p_yf,x
        rts
pc_y1   cmp #101
        bcc pc_d
        lda #101
        sta p_yl,x
        lda #0
        sta p_yf,x
pc_d    rts

; ------------------------------------------------------------------
; emitters (system X = ps)
ps_emit lda ps_kind,x
        cmp #EM_LR
        bne pe_1
        jmp emit_lr
pe_1    cmp #EM_FI
        bne pe_2
        jmp emit_fi
pe_2    cmp #EM_EQ
        bne pe_3
        jmp emit_eq
pe_3    rts

; owner of the system, C = 1 when it is gone
ps_owner
        ldx ps
        lda ps_own,x
        tay
        lda e_cls,y
        bne po_ok
        lda #0              ; the owner is gone: stop
        sta ps_em,x
        sec
        rts
po_ok   tya
        tax
        clc
        rts

; position helpers for new particle em_pp, from entity em_e:
; p.x = e.x + m_v (signed 8.8) + em_ox (signed int)
pos_x   ldx em_pp
        ldy em_e
        lda e_xf,y
        clc
        adc m_v
        sta p_xf,x
        lda e_xl,y
        adc m_v+1
        sta p_xl,x
        lda m_v+1
        and #$80
        beq px_1
        lda #$ff
px_1    adc e_xh,y
        sta p_xh,x
        lda em_ox
        jmp px_add
; p.x += signed A (integer)
px_add  ldy #0
        cmp #$80
        bcc pxa_1
        dey
pxa_1   sty tmp
        clc
        adc p_xl,x
        sta p_xl,x
        lda p_xh,x
        adc tmp
        sta p_xh,x
        rts
; p.y = e.y + m_v + em_oy
pos_y   ldx em_pp
        ldy em_e
        lda e_yf,y
        clc
        adc m_v
        sta p_yf,x
        lda e_yl,y
        adc m_v+1
        clc
        adc em_oy
        sta p_yl,x
        rts
; p.z = m_v + em_oz (+ the owner's z when em_zo)
pos_z   ldx em_pp
        lda m_v
        sta p_zf,x
        lda m_v+1
        sta p_zl,x
        ldy #0
        cmp #$80
        bcc pz_0
        dey
pz_0    tya
        sta p_zh,x
        lda em_oz
        jsr pz_add8
        lda em_zo           ; 1: + the owner's z, 2: twice (the boss aura)
        beq pz_2
        sta tmp+1
pz_3    ldy em_e
        lda p_zf,x
        clc
        adc e_zf,y
        sta p_zf,x
        lda p_zl,x
        adc e_zl,y
        sta p_zl,x
        lda p_zh,x
        adc e_zh,y
        sta p_zh,x
        dec tmp+1
        bne pz_3
pz_2    rts
; particle X z += signed A (integer)
pz_add8 ldy #0
        cmp #$80
        bcc pz_1
        dey
pz_1    sty tmp
        clc
        adc p_zl,x
        sta p_zl,x
        lda p_zh,x
        adc tmp
        sta p_zh,x
        rts
em_ox   dta 0
em_oy   dta 0
em_oz   dta 0
em_zo   dta 0

; new particle in system ps -> em_pp; C = 1 none
p_new_ps
        jsr p_new
        stx em_pp
        rts

; lr(e, dx, dy, dz, r, oe): ps_a = dx (signed), ps_b = dy, ps_c = dz
; (signed), ps_d = r, ps_e = oe.  a = rnd(), d = im(0.5, 1),
; s = im(-r/8, -r/16); p = e + (qn*dx + r*d*sin a, dy, dz + r*d*cos a),
; v = (s*sin a, 0, s*cos a)
emit_lr jsr ps_owner
        bcc el_go
        rts
el_go   stx em_e
        jsr p_new_ps
        bcc el_ok
        rts
el_ok   ldy em_e
        lda e_qn,y
        sta tmp
        ldx ps
        lda ps_a,x
        ldy tmp
        bpl el_q
        eor #$ff
        clc
        adc #1
el_q    sta em_ox
        lda ps_b,x
        sta em_oy
        lda ps_c,x
        sta em_oz
        lda #0
        sta em_zo
        lda ps_e,x
        ldy em_pp
        sta p_oe,y
        lda ps_d,x
        sta em_r
        jsr rnd8
        sta em_a
        lda #128
        jsr rnd_mul
        clc
        adc #128
        sta em_d
        ; rd = r * d (8.8)
        lda em_r
        ldx em_d
        jsr umul8
        lda m_lo
        sta em_rd
        lda m_hi
        sta em_rd+1
        ; s = -(r/16 + rnd(r/16)), r/16 as 8.8 = r*16
        lda em_r
        asl
        asl
        asl
        asl
        sta em_s
        jsr rnd_mul
        clc
        adc em_s
        sta em_s
        lda #0
        adc #0
        sta em_s+1
        ; x, y
        lda em_a
        jsr psin
        jsr em_rdu
        jsr pos_x
        lda #0
        sta m_v
        sta m_v+1
        jsr pos_y
        ; z
        lda em_a
        jsr pcos
        jsr em_rdu
        jsr pos_z
        ; v
        lda em_a
        jsr psin
        jsr em_su
        ldx em_pp
        lda m_v
        sta p_vxf,x
        lda m_v+1
        sta p_vxl,x
        lda em_a
        jsr pcos
        jsr em_su
        ldx em_pp
        lda m_v
        sta p_vzf,x
        lda m_v+1
        sta p_vzl,x
        rts

; lr(e = X, lr_dx, lr_dy, lr_dz, lr_r, lr_oe): a charge particle system
; following e -> A = system ($ff none), Y = its gen
lr_start
        stx lrs_e
        lda #T_LR
        jsr ps_new
        bcc lrs_ok
        lda #$ff
        rts
lrs_ok  lda #EM_LR
        sta ps_kind,x
        lda lrs_e
        sta ps_own,x
        lda lr_dx
        sta ps_a,x
        lda lr_dy
        sta ps_b,x
        lda lr_dz
        sta ps_c,x
        lda lr_r
        sta ps_d,x
        lda lr_oe
        sta ps_e,x
        ldy ps_gen,x
        txa
        rts
lrs_e   dta 0

; m_v = em_rd (8.8) * m_u (unit)
em_rdu  lda em_rd
        sta m_v
        lda em_rd+1
        sta m_v+1
        jmp mulu
; m_v = -em_s * m_u
em_su   lda em_s
        sta m_v
        lda em_s+1
        sta m_v+1
        jsr mulu
        jmp neg_v

em_e    dta 0
em_r    dta 0
em_a    dta 0
em_d    dta 0
em_s    dta 0,0
em_rd   dta 0,0
em_pp   dta 0

; ------------------------------------------------------------------
; fi(px, z, p): the generic emitter, parameter set ps_a (FI_*).
; ps_own = entity giving the position (followed), ps_b = z offset
; (signed), ps_c: 1 = add the owner's z (px.z), ps_d = y offset,
; ps_e = colour override ($ff = the set's)
FI_TRAIL = 0
FI_PICK = 1
FI_AURA = 2
FI_STAR = 3
FI_BOSS = 4
FI_SUMM = 5
; rx, ry, rz (8.8), oe, s minimum and range (8.8), d minimum (byte, 0 = 1.0)
; and range, a minimum (byte angle) and range (0 = a full turn), io ($ff = a)
fi_rxl  dta 0,0,0,0,0,0
fi_rxh  dta 3,7,6,4,19,9
fi_ryl  dta 0,0,0,26,0,0
fi_ryh  dta 0,4,2,0,0,5
fi_rzl  dta 0,0,0,0,0,0
fi_rzh  dta 3,0,8,2,19,0
fi_oe   dta 10,7,12,10,15,15
fi_shl  dta 0,0,0,26,0,0
fi_shh  dta 0,1,0,0,0,1
fi_srl  dta 3,0,3,26,0,0
fi_srh  dta 0,1,0,0,0,1
fi_dd   dta 26,0,128,253,0,0
fi_dr   dta 230,0,128,3,0,0
fi_ic   dta 0,0,0,0,32,0
fi_ar   dta 0,0,0,0,192,0
fi_io   dta $ff,128,$ff,64,$ff,128

emit_fi jsr ps_owner
        bcc ef_go
        rts
ef_go   stx em_e
        ldx ps
        lda ps_a,x
        sta em_set
        cmp #FI_BOSS
        bne ef_1
        lda boss_kton       ; the boss aura only while not vulnerable
        beq ef_1
        rts
ef_1    lda #0
        sta em_ox
        lda ps_d,x
        sta em_oy
        lda ps_b,x
        sta em_oz
        lda ps_c,x
        sta em_zo
        jsr p_new_ps
        bcc ef_2
        rts
ef_2    ldy em_set
        ; a = ic + rnd(range)
        lda fi_ar,y
        beq ef_af
        jsr rnd_mul
        jmp ef_a1
ef_af   jsr rnd8
ef_a1   ldy em_set
        clc
        adc fi_ic,y
        sta em_a
        ; d
        lda fi_dr,y
        beq ef_d1
        jsr rnd_mul
        ldy em_set
        clc
        adc fi_dd,y
        jmp ef_d2
ef_d1   lda fi_dd,y
ef_d2   sta em_d
        ; s = min + rnd(range)
        ldy em_set
        lda fi_srl,y
        sta m_v
        lda fi_srh,y
        sta m_v+1
        jsr rnd_v
        ldy em_set
        lda m_v
        clc
        adc fi_shl,y
        sta em_s
        lda m_v+1
        adc fi_shh,y
        sta em_s+1
        lda fi_io,y
        cmp #$ff
        bne ef_va
        lda em_a
ef_va   sta em_va
        ; x = px.x + rx*d*sin(a)
        lda fi_rxl,y
        ldx fi_rxh,y
        jsr ef_rd
        lda em_a
        jsr psin
        jsr mulu
        jsr pos_x
        ; y = px.y + ry*d*cos(a) (+ offset)
        ldy em_set
        lda fi_ryl,y
        ldx fi_ryh,y
        jsr ef_rd
        lda em_a
        jsr pcos
        jsr mulu
        jsr pos_y
        ; z = (px.z) + z + rz*d*cos(a)
        ldy em_set
        lda fi_rzl,y
        ldx fi_rzh,y
        jsr ef_rd
        lda em_a
        jsr pcos
        jsr mulu
        jsr pos_z
        ; v = (s*sin(va), 0, s*cos(va))
        lda em_va
        jsr psin
        jsr ef_sv
        ldx em_pp
        lda m_v
        sta p_vxf,x
        lda m_v+1
        sta p_vxl,x
        lda em_va
        jsr pcos
        jsr ef_sv
        ldx em_pp
        lda m_v
        sta p_vzf,x
        lda m_v+1
        sta p_vzl,x
        ldy ps
        lda ps_e,y
        cmp #$ff
        bne ef_c
        ldy em_set
        lda fi_oe,y
ef_c    sta p_oe,x
        rts
em_set  dta 0
em_va   dta 0

; m_v = (A + 256*X) * em_d (em_d 0 = 1.0)
ef_rd   sta m_v
        stx m_v+1
        lda em_d
        jmp mulf
; m_v = em_s * m_u
ef_sv   lda em_s
        sta m_v
        lda em_s+1
        sta m_v+1
        jmp mulu

; ------------------------------------------------------------------
; eq(dm, oe, ol, sy, iu, en, dh): a text dropped letter by letter.
; ps_a/ps_b = string, ps_c = letters out (i), ps_d = colour, ps_f = y
emit_eq ldy ps
        lda eq_iu,y         ; hr(iu): frames % (2 iu) == 0
        tax
        jsr mod_frames
        bne eq_d
        ldx ps
        lda ps_a,x
        sta ptr
        lda ps_b,x
        sta ptr+1
        ldy ps_c,x
        lda (ptr),y
        bne eq_go
        lda #0              ; all letters out: ja = nil
        sta ps_em,x
eq_d    rts
eq_go   sta em_a
        inc ps_c,x
        jsr p_new_ps
        bcs eq_d
        ldy ps
        ; x = sx + i*4
        lda ps_c,y
        asl
        asl
        clc
        adc eq_sx,y
        sta p_xl,x
        lda #0
        sta p_xh,x
        lda ps_f,y
        sta p_yl,x
        ; z = im(-10, -8) * en
        jsr rnd8
        asl
        sta m_v
        lda #0
        rol
        sec
        sbc #10
        sta m_v+1
        ldy ps
        lda eq_en,y
        bne eq_z1
        lda #51             ; en = 0.2
        jsr mulf
eq_z1   ldx em_pp
        lda m_v
        sta p_zf,x
        lda m_v+1
        sta p_zl,x
        lda #$ff
        sta p_zh,x
        ; es = base - dh*i (4.12)
        ldy ps
        lda eq_esl,y
        sta tmp
        lda eq_esh,y
        sta tmp+1
        lda ps_c,y
        sta tmp+2
eq_e1   lda eq_dhl,y
        ora eq_dhh,y
        beq eq_e2
        lda tmp
        sec
        sbc eq_dhl,y
        sta tmp
        lda tmp+1
        sbc eq_dhh,y
        sta tmp+1
        dec tmp+2
        bne eq_e1
eq_e2   lda tmp
        sta p_esf,x
        lda tmp+1
        sta p_esl,x
        lda em_a
        sta p_ko,x
        lda ps_d,y
        sta p_oe,x
        rts

; eq(): ptr = string, A = colour; eq_ol = ol (0..80), eq_sy = y,
; eq_iuv = iu, eq_env = 1 (en = 1) or 0 (en = 0.2), eq_dhv = dh (4.12, 16 bit).
; The settings return to their defaults (ol 30, y 30, iu 2, en 1, dh 0).
eq_start
        sta eq_c
        lda eq_ol
        bne eqs_1
        lda #T_EQ0
        bne eqs_2
eqs_1   lda #T_EQ
eqs_2   jsr ps_new
        bcs eqs_def
        stx eq_psx
        lda #EM_EQ
        sta ps_kind,x
        lda ptr
        sta ps_a,x
        lda ptr+1
        sta ps_b,x
        lda #0
        sta ps_c,x
        lda eq_c
        sta ps_d,x
        lda eq_sy
        sta ps_f,x
        lda eq_iuv
        asl
        sta eq_iu,x
        lda eq_env
        sta eq_en,x
        lda eq_dhv
        sta eq_dhl,x
        lda eq_dhv+1
        sta eq_dhh,x
        ldy #0
eqs_l   lda (ptr),y
        beq eqs_n
        iny
        bne eqs_l
eqs_n   tya
        asl
        sta tmp
        lda #62
        sec
        sbc tmp
        sta eq_sx,x
        ; es = 1 + ol*0.07 (4.12) = 4096 + ol*287 = 4096 + ol*256 + ol*31
        lda eq_ol
        ldx #31
        jsr umul8
        ldx eq_psx
        lda m_lo
        sta eq_esl,x
        lda m_hi
        clc
        adc eq_ol
        clc
        adc #$10
        sta eq_esh,x
eqs_def lda #30
        sta eq_sy
        sta eq_ol
        lda #2
        sta eq_iuv
        lda #1
        sta eq_env
        lda #0
        sta eq_dhv
        sta eq_dhv+1
        ldx eq_psx
        rts
eq_c    dta 0
eq_ol   dta 30
eq_sy   dta 30
eq_iuv  dta 2
eq_env  dta 1
eq_dhv  dta 0,0
eq_psx  dta 0

; ------------------------------------------------------------------
; kx(c, params): explosion ring entity + debris.  X = position entity,
; A = KX_* parameter set
explode sta kx_set
        stx kx_src
        lda #$ff
        sta kx_em
        lda #C_EM
        jsr ent_new
        bcs kx_nd
        stx kx_em
        ldy kx_src
        jsr copy_pos
        lda kx_dx
        jsr ex_add8
        ldx kx_em
        ldy kx_set
        lda kx_s_,y
        sta e_s_,x
        lda kx_om,y
        sta e_om,x
        lda kx_oe,y
        sta e_oe,x
        lda kx_kwf,y
        sta e_kwf,x
        lda kx_kwi,y
        sta e_kwi,x
        lda kx_wf,y
        sta e_wf,x
        lda kx_wi,y
        sta e_wi,x
        lda #0
        sta e_rf,x
        lda #1
        sta e_ri,x          ; r = 1
        ; drawable e_ at layer 1
        lda #R_EX
        ldy #1
        jsr draw_new
kx_nd   ; debris: pm({ml=1, jw=0.2, cs=0.07}, om, ...)
        lda #T_KX
        jsr ps_new
        jcs kx_d
        stx ps
        ldy kx_set
        lda kx_om,y
        jeq kx_d
        sta kx_n
kx_l    jsr p_new_ps
        bcs kx_d
        ldy kx_src
        jsr p_at_ent
        lda kx_dx
        jsr px_add
        ; ew = rnd(); vx = sin(ew)*0.1*om, vy = cos(ew)*0.1*om
        jsr rnd8
        sta em_a
        ldy kx_set
        lda kx_om,y
        ldx #26
        jsr umul8           ; om*0.1 (8.8)
        lda m_lo
        sta kx_sp
        lda m_hi
        sta kx_sp+1
        lda em_a
        jsr psin
        jsr kx_v
        ldx em_pp
        lda m_v
        sta p_vxf,x
        lda m_v+1
        sta p_vxl,x
        lda em_a
        jsr pcos
        jsr kx_v
        ldx em_pp
        lda m_v
        sta p_vyf,x
        lda m_v+1
        sta p_vyl,x
        ; vz = -im(0, 5) = -(rnd8 * 5 / 256)  (8.8)
        jsr rnd8
        ldx #5
        jsr umul8
        ldx em_pp
        lda #0
        sec
        sbc m_lo
        sta p_vzf,x
        lda #0
        sbc m_hi
        sta p_vzl,x
        ldy kx_set
        lda kx_oe,y
        sta p_oe,x
        dec kx_n
        bne kx_l
kx_d    ; gr = om/4 (screen shake, stored *2)
        ldy kx_set
        lda kx_om,y
        lsr
        sta gr
        lda #0
        sta kx_dx
        ldx kx_em
        rts
kx_dx   dta 0
kx_v    lda kx_sp
        sta m_v
        lda kx_sp+1
        sta m_v+1
        jmp mulu
kx_set  dta 0
kx_src  dta 0
kx_em   dta 0
kx_n    dta 0
kx_sp   dta 0,0

; particle em_pp at the position of entity Y (x, y; z = 0)
p_at_ent
        ldx em_pp
        lda e_xf,y
        sta p_xf,x
        lda e_xl,y
        sta p_xl,x
        lda e_xh,y
        sta p_xh,x
        lda e_yf,y
        sta p_yf,x
        lda e_yl,y
        sta p_yl,x
        rts

; copy x, y (and z) of entity Y to entity X
copy_pos
        lda e_xf,y
        sta e_xf,x
        lda e_xl,y
        sta e_xl,x
        lda e_xh,y
        sta e_xh,x
        lda e_yf,y
        sta e_yf,x
        lda e_yl,y
        sta e_yl,x
        rts

; ------------------------------------------------------------------
; kv(): draw the particles of system ps
part_draw
        ldx ps
        lda ps_head,x
pd_l    cmp #$ff
        bne pd_go
        rts
pd_go   sta pp
        tax
        ; gb = clamp(flr((1 - es) / 0.25), 0, 3): (4096 - es) >> 10
        lda p_esl,x
        cmp #$10
        bcs pd_g0           ; es >= 1
        lda #0
        cmp p_esf,x         ; borrow when the fraction is not 0
        lda #$10
        sbc p_esl,x
        lsr
        lsr
        cmp #4
        bcc pd_g1
        lda #3
pd_g1   tay
        beq pd_g0
        ; colour = lg[gb][oe]: bank_tab[(BK_LG+gb)*16 + oe]
        tya
        clc
        adc #BK_LG
        asl
        asl
        asl
        asl
        ora p_oe,x
        tay
        lda bank_tab,y
        jmp pd_c
pd_g0   lda p_oe,x
pd_c    sta pd_col
        ; screen position: x, y + z
        lda p_xl,x
        sta bx
        lda p_xh,x
        sta bx+1
        lda p_yl,x
        clc
        adc p_zl,x
        sta by
        lda #0
        adc p_zh,x
        sta by+1
        ; (p_zf + p_yf carry into the integer part)
        lda p_yf,x
        clc
        adc p_zf,x
        bcc pd_n1
        inc by
        bne pd_n1
        inc by+1
pd_n1   lda p_ko,x
        beq pd_nk
        ; outlined letter
        sta pd_k
        lda bx
        sta tx_x
        lda bx+1
        sta tx_x+1
        lda by
        sta tx_y
        lda by+1
        sta tx_y+1
        lda pd_col
        sta tx_c
        lda pd_k
        jsr glyph_gm
        jmp pd_next
pd_nk   lda p_je,x
        beq pd_px
        ; ring: is(x, y, r, r, 2, c), r = min(1, 1-es) * je
        sta tmp
        lda p_esl,x
        cmp #$10
        bcs pd_next         ; es >= 1: r <= 0
        ; (1-es) as 8 bit fraction: (4096 - es) >> 4
        lda #0
        sec
        sbc p_esf,x
        sta tmp+1
        lda #$10
        sbc p_esl,x
        sta tmp+2
        lsr tmp+2
        ror tmp+1
        lsr tmp+2
        ror tmp+1
        lsr tmp+2
        ror tmp+1
        lsr tmp+2
        ror tmp+1
        lda tmp
        ldx tmp+1
        jsr umul8
        lda m_lo
        sta el_rx
        sta el_ry
        lda m_hi
        sta el_rx+1
        sta el_ry+1
        lda #0
        sta el_w
        lda #2
        sta el_w+1
        ldx pp
        lda p_xf,x
        sta el_x
        lda bx
        sta el_x+1
        lda bx+1
        sta el_x+2
        lda by
        sta el_y
        lda by+1
        sta el_y+1
        lda pd_col
        jsr vcol
        jsr el_draw
        jmp pd_next
pd_px   lda pd_col
        jsr pset
pd_next ldx pp
        lda p_next,x
        jmp pd_l
pd_col  dta 0
pd_k    dta 0

; ------------------------------------------------------------------
; eh(mn, ku): the dying entity X falls apart.  It is drawn (frame 2) into
; the scratch buffer at (16 - sm*4, 31), read back, and every other
; coloured pixel becomes a particle of the death system ps.
SCRATCH_FB = 3
disintegrate
        stx dg_e
        lda back_bank
        pha
        lda #0
        sta camx
        sta camx+1
        sta camy
        sta camy+1
        jsr bcb_begin
        lda #SCRATCH_FB
        sta back_bank
        jsr clip_reset
        lda #32
        sta cy1
        ; clear 32 rows
        lda #0
        sta bx
        sta bx+1
        sta by
        sta by+1
        lda #128
        sta bw
        lda #32
        sta bh
        lda #0
        sta bw+1
        sta bh+1
        sta band
        sta bxor
        sta bssx
        sta bssy
        sta bmode
        jsr blit_fb
        ; fs(re, 16 - sm*4, 31, 2, pf, flip)
        ldx dg_e
        ldy e_cls,x
        lda c_sm,y
        asl
        asl
        sta tmp
        lda #16
        sec
        sbc tmp
        sta fs_x
        lda #0
        sbc #0
        sta fs_x+1
        lda #31
        sta fs_y
        lda #0
        sta fs_y+1
        lda #2
        sta fs_jg
        lda #0
        sta fs_gb
        ldx dg_e
        jsr fs_draw
        jsr clip_reset
        jsr bcb_flush
        ; read the scratch buffer (VRAM $4d000: 32 rows of 128)
        lda #$4d
        jsr set_bank
        pla
        sta back_bank
        ; for y = 31..0, x = y%2..31 step 2
        lda #31
        sta dg_y
dg_row  lda dg_y
        and #1
        sta dg_x
dg_px   ; pixel at $9000 + y*128 + x
        lda dg_y
        lsr
        sta ptr+1
        lda #0
        ror
        ora dg_x
        sta ptr
        lda ptr+1
        ora #$90
        sta ptr+1
        ldy #0
        lda (ptr),y
        jeq dg_nx
        tay
        lda idx_pc,y
        jeq dg_nx           ; black (pget 0)
        sta dg_c
        jsr p_new_ps
        jcs dg_out
        ldy dg_e
        ; x = mn.x + x - 16 + rnd()
        jsr rnd8
        clc
        adc e_xf,y
        sta p_xf,x
        lda dg_x
        sec
        sbc #16
        sta tmp
        lda #0
        sbc #0
        sta tmp+1
        lda e_xl,y
        adc #0              ; carry from the fraction
        sta tmp+2
        lda e_xh,y
        adc #0
        sta tmp+3
        lda tmp+2
        clc
        adc tmp
        sta p_xl,x
        lda tmp+3
        adc tmp+1
        sta p_xh,x
        lda e_yf,y
        sta p_yf,x
        lda e_yl,y
        sta p_yl,x
        ; z = mn.z + y - 32
        lda dg_y
        sec
        sbc #32             ; -32..-1
        clc
        adc e_zl,y
        sta p_zl,x
        lda e_zh,y
        adc #$ff
        sta p_zh,x
        lda e_zf,y
        sta p_zf,x
        ; vx = mn.vx * im(0.5, 0.75), vy = mn.vy, vz = -0.5
        lda e_vxf,y
        sta m_v
        lda e_vxl,y
        sta m_v+1
        lda #64
        jsr rnd_mul
        clc
        adc #128
        jsr mulf
        ldx em_pp
        ldy dg_e
        lda m_v
        sta p_vxf,x
        lda m_v+1
        sta p_vxl,x
        lda e_vyf,y
        sta p_vyf,x
        lda e_vyl,y
        sta p_vyl,x
        lda #$80
        sta p_vzf,x
        lda #$ff
        sta p_vzl,x
        lda dg_c
        sta p_oe,x
dg_nx   lda dg_x
        clc
        adc #2
        sta dg_x
        cmp #32
        jcc dg_px
        dec dg_y
        jpl dg_row
dg_out  rts
dg_e    dta 0
dg_y    dta 0
dg_x    dta 0
dg_c    dta 0

