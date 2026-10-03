; ------------------------------------------------------------------
; Stages: start (the cart's py / mk), the level controller (gs, eb),
; waves (me), the background (dc) and the VRAM strips it is drawn from.
; ------------------------------------------------------------------

; mf(): new game
new_game
        lda #0
        sta jn
        ldy kh
        lda qd_da,y
        sta pl_s_
        lda #0
        sta pl_sc0
        sta pl_sc1
        sta pl_sc2
        lda #1
        sta pl_qn
; py(): next stage
next_stage
        lda #$ff
        jsr music
        inc jn
        ; the level entity
        lda #C_FR
        jsr ent_new
        stx fr
        lda #0
        sta e_yl,x
        lda #R_DC
        ldy #0
        jsr draw_new
        jsr mk_waves
        ldx jn
        lda nc_bv,x
        sta pl_bv
        lda nc_rk,x
        sta lv_rk
        lda nc_qy,x
        sta lv_qy
        lda nc_ta,x
        sta lv_ta
        lda nc_fl,x
        sta lv_fl
        lda nc_cl,x
        sta lv_cl
        lda #0
        sta lv_xf
        sta lv_xl
        sta lv_xh
        sta lv_mr
        sta lv_hl
        ; the hero
        lda #C_PLAYER
        jsr ent_new
        stx eg
        lda #0
        sta e_xf,x
        sta e_yf,x
        lda #56
        sta e_xl,x
        lda #90
        sta e_yl,x
        lda pl_s_
        sta e_s_,x
        lda pl_qn
        sta e_qn,x
        lda #0
        sta pl_ohf
        sta pl_ohl
        sta pl_ckl
        sta pl_ckh
        sta pl_mol
        sta pl_moh
        sta pl_hjf
        sta pl_hjl
        sta e_gk,x
        ; rj = -100 (t units)
        lda #<(-200)
        sta e_rjl,x
        lda #>(-200)
        sta e_rjh,x
        lda #R_RT
        ldy #$ff
        jsr draw_new
        ldx eg
        lda #R_LB
        ldy #129
        jsr draw_new
        lda #$ff
        sta d_b,x           ; hp not shown yet
        lda #0
        sta d_a,x           ; left
        jsr build_stage
        lda #0
        ldx jn
        cpx #1
        bne ns_r
        lda #38
ns_r    jmp refl_reset

; mk(): the waves of this stage
mk_waves
        lda #0
        sta lv_nw
        lda jn
        cmp #3
        jcs mk_fin
        lda #$ff
        sta mk_ql
        sta mk_ql+1
        lda #1
        sta mk_i
mk_l    ; row = flr(rc.po + rc.jn*jn + rc.mw*i)  (8.8 sums)
        ldy kh
        lda qd_po_lo,y
        sta tmp
        lda qd_po_hi,y
        sta tmp+1
        ldx jn
mk_a1   lda tmp
        clc
        adc qd_jn_lo,y
        sta tmp
        lda tmp+1
        adc qd_jn_hi,y
        sta tmp+1
        dex
        bne mk_a1
        ldx mk_i
mk_a2   lda tmp
        clc
        adc qd_mw_lo,y
        sta tmp
        lda tmp+1
        adc qd_mw_hi,y
        sta tmp+1
        dex
        bne mk_a2
        lda tmp+1
        sta mk_row
        ; repeat ke = nl(pi[row]) until ke ~= ql
mk_r    ldy mk_row
        lda pi_lo,y
        sta ptr
        lda pi_hi,y
        sta ptr+1
        ldy #0
        lda (ptr),y
        jsr rnd_mul
        asl
        tay
        iny
        lda (ptr),y
        sta tmp+4
        iny
        lda (ptr),y
        sta tmp+5
        cmp mk_ql+1
        bne mk_ok
        lda tmp+4
        cmp mk_ql
        beq mk_r
mk_ok   lda tmp+4
        sta mk_ql
        lda tmp+5
        sta mk_ql+1
        ldx lv_nw
        lda tmp+4
        sta w_str,x
        lda tmp+5
        sta w_strh,x
        lda #1
        sta w_kq,x
        ; x = -135*i - rnd(100)
        lda mk_i
        ldx #135
        jsr umul8
        lda m_lo
        sta tmp
        lda m_hi
        sta tmp+1
        lda #100
        jsr rnd_mul
        clc
        adc tmp
        sta tmp
        lda tmp+1
        adc #0
        sta tmp+1
        ldx lv_nw
        lda #0
        sec
        sbc tmp
        sta w_xl,x
        lda #0
        sbc tmp+1
        sta w_xh,x
        inc lv_nw
        inc mk_i
        lda mk_i
        cmp #8
        jcc mk_l
        ; the final fight: x = -1100, the mini bosses of this stage
        ldx lv_nw
        lda #<(-1100)
        sta w_xl,x
        lda #>(-1100)
        sta w_xh,x
        lda #2
        sta w_kq,x
        ldy kh
        lda jn
        cmp #2
        beq mk_m2
        lda cs_mini1_lo,y
        sta w_str,x
        lda cs_mini1_hi,y
        sta w_strh,x
        jmp mk_m
mk_m2   lda cs_mini2_lo,y
        sta w_str,x
        lda cs_mini2_hi,y
        sta w_strh,x
mk_m    inc lv_nw
        lda #<(-1130)
        sta lv_ex
        lda #>(-1130)
        sta lv_exh
        rts
mk_fin  ; the final stage: the boss at x = -256
        lda #<(-256)
        sta w_xl
        lda #>(-256)
        sta w_xh
        lda #<mk_boss
        sta w_str
        lda #>mk_boss
        sta w_strh
        lda #0
        sta w_kq
        lda #1
        sta lv_nw
        lda #<(-256)
        sta lv_ex
        lda #>(-256)
        sta lv_exh
        rts
mk_boss dta BK_BOSS,0
mk_i    dta 0
mk_row  dta 0
mk_ql   dta 0,0

; gs(l, tm): the level controller
h_gs    lda #40             ; tm == 20: stage banner, music
        jsr tm_eq
        bne gs_1
        ldx jn
        lda nc_ik_lo,x
        sta ptr
        lda nc_ik_hi,x
        sta ptr+1
        lda #60
        sta eq_ol
        lda #12
        jsr eq_start
        ldx jn
        lda nc_le_lo,x
        sta ptr
        lda nc_le_hi,x
        sta ptr+1
        lda #60
        sta eq_ol
        lda #37
        sta eq_sy
        lda #15
        jsr eq_start
        ldx jn
        lda nc_bm,x
        jsr music
gs_1    ; l.hl = #ma("kj") == 1
        lda #G_KJ
        jsr group_count
        ldx #0
        cmp #1
        bne gs_2
        inx
gs_2    stx lv_hl
        ; if l.x <= l.ex and l.mr > #l.se and l.hl then pe()
        lda lv_hl
        beq gs_3
        lda lv_mr
        cmp lv_nw
        bcc gs_3
        jsr x_le_ex
        bcc gs_3
        jsr results
gs_3    ; the hero is dead
        ldx eg
        lda e_nb,x
        beq gs_4
        lda #$ff
        jsr music
        ldx eg
        lda e_th,x
        bne gs_dd
        lda e_tl,x
        cmp #60
        bcc gs_4
gs_dd   lda o_
        bne gs_4
        lda #1
        sta o_
        jsr melt_start
        lda #31
        jsr music
        ldx fr
        lda #S_IB
        ldy #$ff
        jsr set_state
gs_4    ; the next wave: l.x <= gp.x
        ldx lv_mr
        cpx lv_nw
        bcs gs_d
        lda w_xl,x
        sta tmp
        lda w_xh,x
        sta tmp+1
        jsr x_le_t
        bcc gs_d
        jsr wave_spawn
        inc lv_mr
gs_d    clc
        rts

; C = 1 when lv.x <= lv.ex
x_le_ex lda lv_ex
        sta tmp
        lda lv_exh
        sta tmp+1
; C = 1 when lv.x <= tmp (16 bit integer): floor(x) < t, or equal with no fraction
x_le_t  lda tmp
        cmp lv_xl
        lda tmp+1
        sbc lv_xh
        bvc xl_v
        eor #$80
xl_v    bmi xl_n            ; t < floor(x)
        lda tmp
        cmp lv_xl
        bne xl_y
        lda tmp+1
        cmp lv_xh
        bne xl_y
        lda lv_xf           ; equal: only without a fraction
        bne xl_n
xl_y    sec
        rts
xl_n    clc
        rts

; me(e): spawn wave lv_mr
wave_spawn
        ldx lv_mr
        lda w_str,x
        sta ws_p
        lda w_strh,x
        sta ws_p+1
        lda #0
        sta ws_i
ws_l    lda ws_p
        sta ptr
        lda ws_p+1
        sta ptr+1
        ldy ws_i
        lda (ptr),y
        beq ws_e
        jsr ent_new
        bcs ws_n
        stx ws_e2
        jsr pq_rand
        ; x = 64 + sgn(im0(1)) * im(72, 128)
        lda #56
        jsr rnd_mul
        clc
        adc #72
        sta tmp
        jsr rnd8
        bmi ws_lt
        lda #64
        clc
        adc tmp
        sta tmp
        lda #0
        adc #0
        jmp ws_x
ws_lt   lda #64
        sec
        sbc tmp
        sta tmp
        lda #0
        sbc #0
ws_x    ldx ws_e2
        sta e_xh,x
        lda tmp
        sta e_xl,x
        lda pq_xf
        sta e_xf,x
        lda pq_yl
        sta e_yl,x
        lda pq_yf
        sta e_yf,x
        lda #R_RT
        ldy #$ff
        jsr draw_new
ws_n    inc ws_i
        jmp ws_l
ws_e    ldx lv_mr
        lda w_kq,x
        beq ws_d
        ; eq(e.kq, e.oe); sfx loop start = bb; sfx(33, 2, dr); sfx(34, 3, dr)
        cmp #2
        beq ws_ff
        lda #<t_fight
        sta ptr
        lda #>t_fight
        sta ptr+1
        lda #10
        sta ws_oe
        lda #12
        sta ws_bb
        lda #0
        sta ws_dr
        jmp ws_q
ws_ff   lda #<t_ffight
        sta ptr
        lda #>t_ffight
        sta ptr+1
        lda #8
        sta ws_oe
        lda #31
        sta ws_bb
        lda #16
        sta ws_dr
ws_q    lda ws_oe
        jsr eq_start
        lda ws_bb
        sta SFXDATA+33*68+65
        sta SFXDATA+34*68+65
        lda #33
        ldx #2
        ldy ws_dr
        jsr sfx_full
        lda #34
        ldx #3
        ldy ws_dr
        jsr sfx_full
ws_d    rts
ws_p    dta 0,0
ws_i    dta 0
ws_e2   dta 0
ws_oe   dta 0
ws_bb   dta 0
ws_dr   dta 0

; eb(l): ib - waiting for O: to the title (final stage or dead) or on
h_eb    lda in_new
        and #BTN_O
        beq eb_d
        lda #QW_NEXT
        ldx lv_qy
        bne eb_t
        ldx eg
        ldy e_nb,x
        beq eb_s
eb_t    lda #QW_TITLE
eb_s    sta qw
eb_d    clc
        rts

; ------------------------------------------------------------------
; stage graphics: the map layer strips of stage jn (VRAM, stride 1024)
build_stage
        lda jn
        cmp stage_ld
        bne sg_go
        jmp fl_copy
sg_go   sta stage_ld
        jsr fl_copy
        jsr bcb_begin
        ldx #0
sg_l    stx sg_ly
        lda ly_stage,x
        cmp jn
        jne sg_n
        ; clear: 2 fills of 512 x h*8
        lda ly_h,x
        asl
        asl
        asl
        sta sg_h
        lda #0
        sta bi_src
        sta bi_src+1
        sta bi_src+2
        sta bi_ssy
        sta bi_ssy+1
        sta bi_ssx
        sta bi_and
        sta bi_xor
        sta bi_coll
        sta bi_zoom
        sta bi_patt
        lda #0
        sta bi_dsy
        lda #4
        sta bi_dsy+1        ; 1024
        lda #1
        sta bi_dsx
        lda #$ff
        sta bi_w
        lda #1
        sta bi_w+1          ; 512
        ldx sg_h
        dex
        stx bi_h
        lda #8
        sta bi_ctrl
        ldx sg_ly
        lda #0
        sta bi_dst
        lda ly_vr1,x
        sta bi_dst+1
        lda ly_vr2,x
        sta bi_dst+2
        jsr bcb_raw
        ldx sg_ly
        lda #0
        sta bi_dst
        lda ly_vr1,x
        clc
        adc #2
        sta bi_dst+1
        lda ly_vr2,x
        adc #0
        sta bi_dst+2
        jsr bcb_raw
        ; tiles
        lda #0
        sta sg_r
sg_row  ; copy the map row to sg_buf (window bank $4c)
        ldx sg_ly
        lda ly_row,x
        clc
        adc sg_r
        lsr
        sta ptr+1
        lda #0
        ror
        sta ptr             ; row * 128
        lda ptr+1
        ora #$90
        sta ptr+1
        lda #$4c
        jsr set_bank
        ldy #0
sg_cp   lda (ptr),y
        sta sg_buf,y
        iny
        bpl sg_cp
        lda bcb_bank
        jsr set_bank
        ; columns: map column ly_col + c (0 when >= 128)
        lda #1
        sta bi_ssx
        lda #128
        sta bi_ssy
        lda #0
        sta bi_ssy+1
        lda #7
        sta bi_w
        lda #0
        sta bi_w+1
        lda #7
        sta bi_h
        lda #$ff
        sta bi_and
        lda #0
        sta bi_xor
        lda #8
        sta bi_ctrl
        lda #0
        sta sg_c
sg_col  ldx sg_ly
        lda ly_col,x
        clc
        adc sg_c
        bmi sg_cn           ; >= 128: empty
        tay
        lda sg_buf,y
        beq sg_cn
        ; src = sheet + (t/16)*1024 + (t%16)*8
        sta tmp
        and #15
        asl
        asl
        asl
        sta bi_src
        lda tmp
        lsr
        lsr
        and #$3c
        sta bi_src+1
        lda #1
        sta bi_src+2
        ; dst = strip + r*8*1024 + c*8
        lda sg_c
        asl
        asl
        asl
        sta bi_dst
        lda #0
        rol
        sta tmp+1
        lda sg_r
        asl
        asl
        asl
        asl
        asl                 ; r*32 (x 256 = r*8*1024)
        clc
        adc tmp+1
        clc
        adc ly_vr1,x
        sta bi_dst+1
        lda ly_vr2,x
        adc #0
        sta bi_dst+2
        jsr bcb_raw
sg_cn   inc sg_c
        lda sg_c
        cmp #128
        bne sg_col
        inc sg_r
        ldx sg_ly
        lda sg_r
        cmp ly_h,x
        jcc sg_row
sg_n    ldx sg_ly
        inx
        cpx #NLAYER
        jcc sg_l
        jmp bcb_flush
sg_ly   dta 0
sg_h    dta 0
sg_r    dta 0
sg_c    dta 0

; the floor offsets of stage jn: VRAM $4e000 + first*32 -> fl_buf
fl_copy ldx jn
        lda fl_first,x
        sta m_n
        lda #0
        sta m_n+1
        ldy #5
fc_s    asl m_n
        rol m_n+1
        dey
        bne fc_s            ; first * 32
        lda m_n
        sta ptr
        lda m_n+1
        clc
        adc #$90            ; window $9000 = VRAM $4e000
        sta ptr+1
        lda #<fl_buf
        sta ptr2
        lda #>fl_buf
        sta ptr2+1
        lda #$4e
        jsr set_bank
        ldx #4              ; 4 pages (960 bytes and some)
        ldy #0
fc_l    lda (ptr),y
        sta (ptr2),y
        iny
        bne fc_l
        inc ptr+1
        inc ptr2+1
        dex
        bne fc_l
        lda bcb_bank
        jmp set_bank

; ------------------------------------------------------------------
; dc(lv): the level background
dr_dc   ; palette: ip(lv.qh, t/2 % 3 + 1) on stages with torches
        ldx jn
        lda nc_qh,x
        beq dc_0
        ldx #12
        jsr mod_frames      ; (frames/4) % 3 = (frames % 12) / 4
        lsr
        lsr
        clc
        adc #BK_PG+1
        asl
        asl
        asl
        asl
        sta dbank
dc_0    lda dbank
        sta lv_bgk
        jsr floor_draw
        ; rect(0, 105, 128, 105, 1)
        lda #0
        sta rx0
        sta rx0+1
        sta ry0+1
        sta rx1+1
        lda #128
        sta rx1
        lda #105
        sta ry0
        lda #1
        jsr vcol
        jsr hspan
        lda jn
        cmp #1
        bne dc_1
        jsr pk_bg
dc_1    lda lv_bgk
        sta dbank
        jsr layers_draw
        ; go arrow: mo >= 90 and cv < 23
        lda pl_moh
        bne dc_g
        lda pl_mol
        cmp #180
        bcc dc_d
dc_g    jsr go_phase        ; A = mo_frames % 90
        cmp #46
        bcs dc_d
        ; ip(hf, 4 - cv): level flr(4 - g/2)
        sta tmp
        lda #8
        sec
        sbc tmp
        bmi dc_n
        lsr
        beq dc_n
        cmp #5
        bcc dc_l
        lda #4
dc_l    clc
        adc #BK_HF
        asl
        asl
        asl
        asl
        sta dbank
        jmp dc_s
dc_n    lda #0
        sta dbank
dc_s    lda #115
        sta bx
        lda #42
        sta by
        lda #0
        sta bx+1
        sta by+1
        lda #7
        jsr spr1
        lda #<t_go
        sta str_p
        lda #>t_go
        sta str_p+1
        lda #114
        sta tx_x
        lda #51
        sta tx_y
        lda #0
        sta tx_x+1
        sta tx_y+1
        lda #9
        jmp gm
dc_d    rts

; A = mo (frames) mod 90
go_phase
        lda pl_mol
        sta m_n
        lda pl_moh
        sta m_n+1
        ldx #90
        jmp mod8

; tick of dc: kl(55) when cv == 0
t_dc    lda pl_moh
        bne tdc_1
        lda pl_mol
        cmp #180
        bcc tdc_d
tdc_1   jsr go_phase
        bne tdc_d
        lda #55
        jsr kl
tdc_d   rts

; the floor (and the ceiling): the rows are drawn into a cache (VRAM
; $7e000, "framebuffer" 5) when the scroll or the camera x changed, with
; the raw colours; the cache is copied through the palette every frame.
; Cache rows 0..23: floor y 80..103; rows 24..29: ceiling y 32..37.
FLC_FB  = 5
floor_draw
        ; ovq = (lv.x mod 16) * 2
        lda lv_xl
        and #15
        asl
        sta tmp
        lda lv_xf
        asl
        lda tmp
        adc #0
        sta fd_q
        cmp fl_key+1
        bne fd_new
        lda jn
        cmp fl_key
        bne fd_new
        lda camx
        cmp fl_key+2
        jeq fd_copy
fd_new  lda jn
        sta fl_key
        lda fd_q
        sta fl_key+1
        lda camx
        sta fl_key+2
        lda back_bank
        pha
        lda #FLC_FB
        sta back_bank
        ldx #30
        jsr cache_clear
        ldx jn
        lda fl_y_lo,x
        sta fd_yp
        lda fl_y_hi,x
        sta fd_yp+1
        lda fl_n,x
        sta fd_n
        lda #$ff
        sta band
        lda #4
        sta bsrc+2
        lda #0
        sta fd_r
fdr_l   ; source column = fl_buf[r * 32 + ovq] + camera x
        lda #0
        sta ptr+1
        lda fd_r
        asl
        asl
        asl
        asl
        asl
        rol ptr+1
        clc
        adc fd_q
        adc #<fl_buf
        sta ptr
        lda ptr+1
        adc #>fl_buf
        sta ptr+1
        ldy #0
        lda (ptr),y
        clc
        adc camx
        cmp #128
        bcc fd_c1
        lda #0              ; (negative)
fd_c1   sta bsrc
        ; source row: $46000 + (jn-1)*$2000 + r*256
        lda jn
        asl
        asl
        asl
        asl
        asl
        clc
        adc #$40            ; $60 - $20
        clc
        adc fd_r
        sta bsrc+1
        ; cache row: y - 80 (floor) or y - 32 + 24 (ceiling)
        ldy fd_r
        lda (fd_yp),y
        sec
        sbc #80
        bcs fd_cr
        adc #80-32+24
fd_cr   jsr row_emit
        inc fd_r
        lda fd_r
        cmp fd_n
        jne fdr_l
        pla
        sta back_bank
fd_copy ; floor band: cache rows 0..23 -> y 80
        lda #0
        sta bsrc
        lda #$e0
        sta bsrc+1
        lda #7
        sta bsrc+2
        lda #80
        ldx #24
        jsr flc_blit
        lda lv_cl
        beq fd_d
        lda #0
        sta bsrc
        lda #$ec            ; row 24
        sta bsrc+1
        lda #7
        sta bsrc+2
        lda #32
        ldx #6
        jmp flc_blit
fd_d    rts
; cache copy: screen y A, X rows (blit_cam applies the camera; the camera
; x is already in the cache, so the copy starts at x = camx)
flc_blit
        sta by
        lda #0
        sta by+1
        lda camx
        sta bx
        lda camx+1
        sta bx+1
        stx bh
        lda #128
        sta bw
        lda #0
        sta bw+1
        sta bh+1
        sta bxor
        lda #1
        sta bssx
        sta bmode
        lda #7
        sta bssy
        lda dbank
        ora #$0f
        sta band
        jmp blit_cam
; clear X rows (128 wide) of the framebuffer back_bank
cache_clear
        stx bh
        lda #0
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
        jsr clip_reset
        jmp blit_fb
fd_q    dta 0
fd_n    dta 0
fd_r    dta 0
fd_yp   = sp

; the map layers (parallax): one blit each from the strips
layers_draw
        ldx #0
ld_l    stx ld_i
        lda ly_stage,x
        cmp jn
        jne ld_n
        ; os = |lv.x| * speed (16 bit integer part)
        lda #0
        sec
        sbc lv_xf
        sta tmp
        lda #0
        sbc lv_xl
        sta tmp+1
        lda #0
        sbc lv_xh
        sta tmp+2           ; |x| (frac, lo, hi)
        lda ly_spd_hi,x
        beq ld_f
        ; speed 1.0
        lda tmp+1
        sta ld_os
        lda tmp+2
        sta ld_os+1
        jmp ld_m
ld_f    lda ly_spd_lo,x
        bne ld_f1
        lda #0
        sta ld_os
        sta ld_os+1
        jmp ld_m
ld_f1   ; |x| * f / 256 (24 bit * 8 bit)
        sta tmp+3
        lda tmp+1
        ldx tmp+3
        jsr umul8
        lda m_lo
        sta tmp+4
        lda m_hi
        sta ld_os
        lda #0
        sta ld_os+1
        lda tmp+2
        ldx tmp+3
        jsr umul8
        lda m_lo
        clc
        adc ld_os
        sta ld_os
        lda m_hi
        adc #0
        sta ld_os+1
        ; plus the fraction's contribution
        lda tmp
        ldx tmp+3
        jsr umul8
        lda m_hi
        clc
        adc tmp+4
        bcc ld_m
        inc ld_os
        bne ld_m
        inc ld_os+1
ld_m    ; o = os mod 896
ld_mo   lda ld_os
        cmp #<896
        lda ld_os+1
        sbc #>896
        bcc ld_bl
        sta ld_os+1
        lda ld_os
        sec
        sbc #<896
        sta ld_os
        jmp ld_mo
ld_bl   ldx ld_i
        lda ld_os
        sta bsrc
        lda ld_os+1
        clc
        adc ly_vr1,x
        sta bsrc+1
        lda ly_vr2,x
        adc #0
        sta bsrc+2
        lda #0
        sta bx
        sta bx+1
        sta by+1
        lda ly_y,x
        sta by
        lda #128
        sta bw
        lda ly_h,x
        asl
        asl
        asl
        sta bh
        lda #0
        sta bw+1
        sta bh+1
        sta bxor
        lda #1
        sta bssx
        sta bmode
        lda #10             ; stride 1024
        sta bssy
        lda dbank
        ora #$0f
        sta band
        jsr blit_cam
ld_n    ldx ld_i
        inx
        cpx #NLAYER
        jcc ld_l
        rts
ld_i    dta 0
ld_os   dta 0,0

; pk(): stage 1 - the moon over the sea, and the controls
pk_bg   lda #0
        sta dbank
        ; rw(102, 38, 17)
        lda #<(102-MOON2_C)
        sta bx
        lda #>(102-MOON2_C)
        sta bx+1
        lda #<(38-MOON2_C)
        sta by
        lda #>(38-MOON2_C)
        sta by+1
        lda #<(VR_MOON2)
        ldx #>(VR_MOON2)
        ldy #MOON2_S
        jsr moon_blit
        ; rectfill(0, 50, 127, 50, 1); rectfill(0, 51, 127, 60, 0)
        lda #0
        sta rx0
        sta rx0+1
        sta rx1+1
        sta ry0+1
        sta ry1+1
        lda #127
        sta rx1
        lda #50
        sta ry0
        sta ry1
        lda #1
        jsr rectfill
        lda #0
        sta rx0
        sta rx0+1
        sta rx1+1
        sta ry0+1
        sta ry1+1
        lda #127
        sta rx1
        lda #51
        sta ry0
        lda #60
        sta ry1
        lda #0
        jsr rectfill
        ; jl(102, 51, 38)
        lda #102
        ldx #51
        jsr refl_draw
        ; the controls: fr.x > -200 and dget(63) == 0
        lda cdata+6
        bne pk_d
        lda lv_xh
        beq pk_t
        cmp #$ff
        bne pk_d
        lda lv_xl
        cmp #<(-200)
        bcc pk_d
        bne pk_t
        lda lv_xf
        beq pk_d
pk_t    lda #55
        sta tx_x
        lda #104
        sta tx_y
        lda #0
        sta tx_x+1
        sta tx_y+1
        ldx #0
pk_l    stx pk_i
        lda pk_lo,x
        sta str_p
        lda pk_hi,x
        sta str_p+1
        lda #13
        jsr gm
        lda tx_y
        clc
        adc #6
        sta tx_y
        lda #55
        sta tx_x
        ldx pk_i
        inx
        cpx #4
        bne pk_l
pk_d    rts
pk_i    dta 0
pk_lo   dta <t_tut1,<t_tut2,<t_tut3,<t_tut4
pk_hi   dta >t_tut1,>t_tut2,>t_tut3,>t_tut4

; moon image (A/X = VRAM address bits 0..15, bank 4, Y = size) at bx, by
moon_blit
        sta bsrc
        stx bsrc+1
        lda #4
        sta bsrc+2
        sty bw
        sty bh
        lda #0
        sta bw+1
        sta bh+1
        sta bxor
        lda #1
        sta bssx
        sta bmode
        lda #7
        sta bssy
        lda dbank
        ora #$0f
        sta band
        jmp blit_cam
VR_MOON1 = $0000
VR_MOON2 = $2000

; ------------------------------------------------------------------
; jl(sx, sy, fq): the moon's reflection, 17 rows of nested spans whose
; half width sways: w = sin(t*(0.008+0.0037*mu) + mu) * (1 - y*0.055) * fq.
; The row images are chosen every fourth update (refl_rows); A = sx, X = sy
RFC_FB  = 6
refl_draw
        sta rf_sx
        stx rf_sy
        lda rf_gen
        cmp rf_key
        jeq rfd_copy
        sta rf_key
        lda back_bank
        pha
        lda #RFC_FB
        sta back_bank
        ldx #17
        jsr cache_clear
        ldx #0
rfd_l   stx rf_i
        ; source row = VR_REFL + idx*128
        lda rf_idx,x
        lsr
        sta bsrc+1
        lda #0
        ror
        sta bsrc
        lda bsrc+1
        clc
        adc #>VR_REFL
        sta bsrc+1
        lda #^VR_REFL
        sta bsrc+2
        ; x0 = sx - 48, width = min(97, 128 - x0)
        lda rf_sx
        sec
        sbc #48
        sta tmp
        lda #128
        sec
        sbc tmp
        cmp #97
        bcc rfd_w
        lda #97
rfd_w   sta tmp+1
        ; cache row i
        lda rf_i
        lsr
        sta bi_dst+1
        lda #0
        ror
        ora tmp
        sta bi_dst
        lda bi_dst+1
        ora #$f0
        sta bi_dst+1
        lda #7
        sta bi_dst+2
        jsr refl_emit
        ldx rf_i
        inx
        cpx #17
        bne rfd_l
        pla
        sta back_bank
rfd_copy
        ; the cached 17 rows (the full width: empty columns are 0) -> y sy+1
        lda #0
        sta bsrc
        lda #$f0
        sta bsrc+1
        lda #7
        sta bsrc+2
        lda #0
        sta bx
        sta bx+1
        lda rf_sy
        clc
        adc #1
        sta by
        lda #0
        sta by+1
        lda #128
        sta bw
        lda #17
        sta bh
        lda #0
        sta bw+1
        sta bh+1
        sta bxor
        lda #1
        sta bssx
        sta bmode
        lda #7
        sta bssy
        lda dbank
        ora #$0f
        sta band
        jmp blit_cam
rf_sx   dta 0
rf_sy   dta 0
rf_i    dta 0

; a reflection row: source bsrc, destination bi_dst, width tmp+1
refl_emit
        ldy bcb_n
        lda (bk_ptr),y
        cmp #K_REFL
        beq rem_k
        lda #K_REFL
        sta (bk_ptr),y
        ldy #20
rem_i   lda row_img,y
        sta (bcbp),y
        dey
        bpl rem_i
rem_k   ldy #0
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
        ldy #12
        ldx tmp+1
        dex
        txa
        sta (bcbp),y
        ldy #15
        lda #$ff
        sta (bcbp),y
        ldy #20
        lda #8              ; copy (clears the row's other pixels... see below)
        sta (bcbp),y
        jmp bcb_next

; reflection phases and row widths: reset at a scene start (A = fq, 0 =
; no reflection), advanced every update
refl_reset
        sta rf_fq
        ldx #16
rr_l    lda jl_ph0_lo,x
        sta jl_ph_lo,x
        lda jl_ph0_hi,x
        sta jl_ph_hi,x
        stx rf_i
        lda jl_amp,x
        ldx rf_fq
        jsr umul8
        ldx rf_i
        lda m_lo
        sta rf_al,x
        lda m_hi
        sta rf_ah,x
        dex
        bpl rr_l
        jmp refl_rows
refl_tick
        ldx #16
rt_l    lda jl_ph_lo,x
        clc
        adc jl_spd_lo,x
        sta jl_ph_lo,x
        lda jl_ph_hi,x
        adc jl_spd_hi,x
        sta jl_ph_hi,x
        dex
        bpl rt_l
        lda rf_fq
        beq rt_d
        lda frames
        and #3
        bne rt_d
; the row images of the 17 rows: round(|sin(phase) * amp * fq| * 2)
refl_rows
        ldx #16
rw_l    stx rf_i
        lda rf_al,x
        sta m_v
        lda rf_ah,x
        sta m_v+1
        lda jl_ph_hi,x
        jsr psin
        jsr mulu
        lda m_v
        ldy m_v+1
        jsr abs88
        sta tmp
        tya
        asl tmp
        rol
        ldx tmp
        bpl rw_r
        clc
        adc #1
rw_r    cmp #97
        bcc rw_i
        lda #96
rw_i    ldx rf_i
        sta rf_idx,x
        dex
        bpl rw_l
        inc rf_gen
rt_d    rts
