; ------------------------------------------------------------------
; Scenes, the update/draw drivers, the title, game over and results.
; ------------------------------------------------------------------
QW_TITLE = 1
QW_NEW  = 2
QW_NEXT = 3

game_init
        lda #QW_TITLE
        sta qw
        lda #0
        sta stage_ld
        rts

; one update (the cart's _update60: lo, pj, sl) plus the drawable timers
game_tick
        jsr read_buttons
        jsr update_all
        lda qw
        beq gt_1
        pha
        lda #0
        sta qw
        jsr world_reset
        pla
        cmp #QW_TITLE
        bne gt_n
        jsr title_start
        jmp gt_1
gt_n    cmp #QW_NEW
        bne gt_s
        jsr new_game
        jmp gt_1
gt_s    jsr next_stage
gt_1    jsr resolve_attacks
        jsr draw_tick
        jmp refl_tick

; one frame (the cart's _draw)
game_draw
        lda o_
        beq gd_play
        jmp melt_draw
gd_play ; camera(sin(t/4)*gr, cos(t/4)*gr)
        lda #0
        sta camx
        sta camx+1
        sta camy
        sta camy+1
        lda gr
        beq gd_1
        lda frames          ; t/4 turns = frames/8: angle frames*32
        asl
        asl
        asl
        asl
        asl
        sta tmp+7
        jsr psin
        jsr gd_shk
        sta camx
        stx camx+1
        lda tmp+7
        jsr pcos
        jsr gd_shk
        sta camy
        stx camy+1
gd_1    jsr cls_raw
        jsr clip_reset
        jsr draw_all
        ; screen palette: ip(nt[1], nt[2], 1)
        ldx #0
        lda nt_tab
        beq gd_p
        lda nt_lvl
        beq gd_p
        cmp #5
        bcc gd_l
        lda #4
gd_l    ldy nt_tab
        cpy #2
        bne gd_hf
        clc
        adc #BK_LG
        tax
        jmp gd_p
gd_hf   clc
        adc #BK_HF
        tax
gd_p    cpx spal_t
        beq gd_d
        stx spal_t
        lda #1
        sta pal_req
gd_d    rts
; flr(m_u * gr/2) -> A (lo), X (hi)
gd_shk  lda #0
        sta m_v
        lda gr
        lsr
        sta m_v+1
        lda #0
        ror
        sta m_v             ; gr/2 as 8.8
        jsr mulu
        lda m_v+1
        ldx #0
        cmp #$80
        bcc gs_p
        dex
gs_p    rts

; ------------------------------------------------------------------
; the title: bl()
title_start
        lda #C_LQ
        jsr ent_new
        lda #0
        sta e_yl,x
        lda #R_SJ
        ldy #0
        jsr draw_new
        lda #0
        sta title_dy
        lda #$f8            ; dy = -8
        sta title_dy+1
        lda #0
        jsr music
        lda #48
        jmp refl_reset

; cz(nz): jr of the title - O opens the menu
h_cz    lda in_new
        and #BTN_O
        beq cz_d
        ldx self
        lda #S_MI
        ldy #55
        jsr set_state
cz_d    clc
        rts

; qj(nz): the menu - left/right: difficulty, O: start
h_qj    lda in_new
        and #BTN_L
        beq qj_1
        lda kh
        cmp #2
        bcc qj_s
        dec kh
qj_s    lda #55
        jsr kl
qj_1    lda in_new
        and #BTN_R
        beq qj_2
        lda kh
        cmp #5
        bcs qj_s2
        inc kh
qj_s2   lda #55
        jsr kl
qj_2    lda in_new
        and #BTN_O
        beq qj_d
        lda #QW_NEW
        sta qw
        lda #55
        jsr kl
qj_d    clc
        rts

; sj tick: nz.dy = ej(nz.dy, pf and 0.5 or -8)
t_sj    ldx dd
        ldy d_ent,x
        lda e_st,y
        cmp #S_MI
        beq ts_m
        lda #<(-8*256)
        sta tmp
        lda #>(-8*256)
        sta tmp+1
        jmp ts_e
ts_m    lda #$80
        sta tmp
        lda #0
        sta tmp+1
ts_e    lda title_dy
        sec
        sbc tmp
        sta m_v
        lda title_dy+1
        sbc tmp+1
        sta m_v+1
        lda #219
        jsr mulf
        lda m_v
        clc
        adc tmp
        sta title_dy
        lda m_v+1
        adc tmp+1
        sta title_dy+1
        rts

; camera y = ceil(A:X 8.8) -> camy
cam_ceil
        stx tmp+1
        cmp #0
        beq cc_i
        inc tmp+1
cc_i    lda tmp+1
        sta camy
        ldx #0
        cmp #$80
        bcc cc_p
        dex
cc_p    stx camy+1
        lda #0
        sta camx
        sta camx+1
        rts

; sj(nz): draw the title
dr_sj    sty sj_e
        lda title_dy
        ldx title_dy+1
        jsr cam_ceil
        ; rectfill(-127, 58, 127, 58, 1)
        lda #<(-127)
        sta rx0
        lda #>(-127)
        sta rx0+1
        lda #127
        sta rx1
        lda #0
        sta rx1+1
        sta ry0+1
        sta ry1+1
        lda #58
        sta ry0
        sta ry1
        lda #1
        jsr rectfill
        ; rw(63, 35, 25)
        lda #<(63-MOON1_C)
        sta bx
        lda #>(63-MOON1_C)
        sta bx+1
        lda #<(35-MOON1_C)
        sta by
        lda #>(35-MOON1_C)
        sta by+1
        lda #<VR_MOON1
        ldx #>VR_MOON1
        ldy #MOON1_S
        jsr moon_blit
        ; ip(lg, 4); spr(140, 48, 32, 4, 4); print("the", 58, 15, 0); spr(114, 53, 21, 3, 1)
        lda #(BK_LG+4)*16
        sta dbank
        lda #4
        sta spr_tw
        sta spr_th
        lda #0
        sta spr_fx
        sta spr_fy
        sta bx+1
        sta by+1
        lda #48
        sta bx
        lda #32
        sta by
        lda #140
        jsr spr_draw
        lda #<t_the
        sta str_p
        lda #>t_the
        sta str_p+1
        lda #58
        sta tx_x
        lda #15
        sta tx_y
        lda #0
        sta tx_x+1
        sta tx_y+1
        jsr print
        lda #3
        sta spr_tw
        lda #1
        sta spr_th
        lda #53
        sta bx
        lda #21
        sta by
        lda #0
        sta bx+1
        sta by+1
        lda #114
        jsr spr_draw
        jsr tb_reset
        ; jl(64, 59, 48)
        lda #64
        ldx #59
        jsr refl_draw
        ldy sj_e
        lda e_st,y
        cmp #S_MI
        beq sj_menu
        ; press [z] to start (after 60 t, blinking hr(60, 30))
        lda e_th,y
        bne sj_p
        lda e_tl,y
        cmp #121
        bcc sj_c
sj_p    ldx #120
        jsr mod_frames
        cmp #60
        bcs sj_c
        lda #<t_press
        sta str_p
        lda #>t_press
        sta str_p+1
        lda #28
        sta tx_x
        lda #85
        sta tx_y
        lda #0
        sta tx_x+1
        sta tx_y+1
        lda #13
        jsr gm
sj_c    lda #<t_cred1
        sta str_p
        lda #>t_cred1
        sta str_p+1
        lda #2
        sta tx_x
        lda #102
        sta tx_y
        lda #0
        sta tx_x+1
        sta tx_y+1
        lda #1
        jsr print
        lda #<t_cred2
        sta str_p
        lda #>t_cred2
        sta str_p+1
        lda #2
        sta tx_x
        lda #108
        sta tx_y
        lda #1
        jmp print
sj_menu ; camera(0, nz.dy * 5)
        lda title_dy
        sta tmp
        lda title_dy+1
        sta tmp+1
        asl tmp
        rol tmp+1
        asl tmp
        rol tmp+1
        lda tmp
        clc
        adc title_dy
        pha
        lda tmp+1
        adc title_dy+1
        tax
        pla
        jsr cam_ceil
        ; mg = dget(kh), jc = t/5 % 3
        ldx kh
        lda cdata-1,x
        sta sj_mg
        ; rectfill(64, 87, 64, mg > 0 and 123 or 108, 1)
        lda #64
        sta rx0
        sta rx1
        lda #87
        sta ry0
        lda #108
        ldx sj_mg
        beq sj_1
        lda #123
sj_1    sta ry1
        lda #0
        sta rx0+1
        sta rx1+1
        sta ry0+1
        sta ry1+1
        lda #1
        jsr rectfill
        lda #<t_diff
        ldx #>t_diff
        ldy #17
        jsr sj_txt
        lda #92
        sta tx_y
        lda #13
        jsr print
        ldx kh
        lda t_dn_lo,x
        sta str_p
        lda t_dn_hi,x
        sta str_p+1
        lda #69
        sta tx_x
        lda #100
        sta tx_y
        lda #1
        jsr print
        lda sj_mg
        beq sj_2
        lda #<t_best
        ldx #>t_best
        ldy #17
        jsr sj_txt
        lda #113
        sta tx_y
        lda #13
        jsr print
        lda #69
        sta bx
        lda #112
        sta by
        lda #0
        sta bx+1
        sta by+1
        lda sj_mg
        clc
        adc #57
        jsr spr1
sj_2    ; arrows: spr(12, -jc, 92); spr(13, 120 + jc, 92); jc = (frames/10) % 3
        ldx #30
        jsr mod_frames
        ldx #0
sj_jc   cmp #10
        bcc sj_j1
        sbc #10
        inx
        jmp sj_jc
sj_j1   stx sj_jc0
        lda #0
        sec
        sbc sj_jc0
        sta bx
        lda #0
        sbc #0
        sta bx+1
        lda #92
        sta by
        lda #0
        sta by+1
        lda #12
        jsr spr1
        lda #120
        clc
        adc sj_jc0
        sta bx
        lda #0
        sta bx+1
        lda #92
        sta by
        lda #13
        jsr spr1
        ; the five skulls
        lda #1
        sta sj_i
sj_sk   jsr tb_reset
        lda #0
        sta sj_d
        lda sj_i
        cmp kh
        beq sj_on
        bcs sj_off
sj_on   lda #1
        sta sj_d
        ldx sj_i
        lda qd_oz,x
        beq sj_s
        cmp #4
        bcc sj_oz
        lda #3
sj_oz   clc
        adc #BK_SZ
        asl
        asl
        asl
        asl
        sta dbank
        jmp sj_s
sj_off  lda #(BK_LG+3)*16
        sta dbank
sj_s    ; spr(1, 60 + i*8, 90.5 + cos(t/20 + i*0.4) * d)
        lda sj_i
        asl
        asl
        asl
        clc
        adc #60
        sta bx
        lda #0
        sta bx+1
        lda #90
        sta by
        lda #0
        sta by+1
        lda sj_d
        beq sj_y
        ; t/20 = frames/40 turns; i*0.4 turns
        ldx #40
        jsr mod_frames
        sta m_n+1
        lda #0
        sta m_n
        lda #40
        sta m_d
        lda #0
        sta m_d+1
        jsr div16           ; frames%40 * 256/40
        ldx sj_i
        lda m_q
        clc
        adc sj_ph,x
        jsr pcos
        ; 90.5 + cos: floor
        lda m_u
        clc
        adc #$80
        lda m_u+1
        adc #90
        sta by
        lda #0
        sta by+1
sj_y    lda #1
        jsr spr1
        inc sj_i
        lda sj_i
        cmp #6
        jne sj_sk
        rts
sj_e    dta 0
sj_mg   dta 0
sj_i    dta 0
sj_d    dta 0
sj_jc0  dta 0
sj_ph   dta 0,102,205,51,154,0      ; i*0.4 turns (byte angles)
; str_p = A/X, tx_x = Y
sj_txt  sta str_p
        stx str_p+1
        sty tx_x
        lda #0
        sta tx_x+1
        sta tx_y+1
        rts

; ------------------------------------------------------------------
; game over: the screen melts (the cart's o_ branch of _draw) and qb()
melt_start
        lda #1
        sta melt_new
        rts
melt_draw
        lda melt_new
        beq md_go
        lda #0
        sta melt_new
        ; melt the frame that is on screen
        lda shown_bank
        sta melt_bank
md_go   lda melt_bank
        sta back_bank
        ; CPU: pset(rnd(128), 127, 13) and N circles of pget colours
        jsr melt_cpu
        lda bcb_bank
        jsr set_bank
        jsr tb_reset
        lda #0
        sta camx
        sta camx+1
        sta camy
        sta camy+1
        jsr clip_reset
        ; qb(): nu(48, 35, 78, 35, 1, 1, 2), spr(1, 60, 31), gm("you perished", 40, 40, 15)
        lda #48
        sta nu_x1
        lda #78
        sta nu_x2
        lda #35
        sta nu_y1
        sta nu_y2
        lda #0
        sta nu_x1+1
        sta nu_x2+1
        sta nu_y1+1
        sta nu_y2+1
        sta nu_rm
        sta nu_qc+1
        lda #1
        sta nu_qc
        sta nu_n
        lda #2
        sta nu_fg
        sta nu_bg
        jsr nu_bar
        lda #60
        sta bx
        lda #31
        sta by
        lda #0
        sta bx+1
        sta by+1
        lda #1
        jsr spr1
        lda #<t_perish
        sta str_p
        lda #>t_perish
        sta str_p+1
        lda #40
        sta tx_x
        sta tx_y
        lda #0
        sta tx_x+1
        sta tx_y+1
        lda #15
        jmp gm
melt_new  dta 0
melt_bank dta 0

MELT_N  = 120
melt_cpu
        lda #$ff
        sta mc_bank
        ; pset(rnd(128), 127, 13)
        jsr rnd8
        and #127
        tax
        ldy #127
        lda #$fd
        jsr mc_put
        lda #MELT_N
        sta mc_n
mc_l    jsr rnd8
        and #127
        sta mc_x
        jsr rnd8
        and #127
        sta mc_y
        ldx mc_x
        ldy mc_y
        jsr mc_get
        tay
        lda idx_pc,y
        sta mc_c
        lda #31             ; mc(0.12)
        jsr chance_c
        bcc mc_k
        ldy mc_c
        lda hk_tab,y
        sta mc_c
mc_k    lda mc_c
        ora #$f0
        sta mc_c
        ; circ(x, y - 1, 1): (x-1, y-1), (x+1, y-1), (x, y-2), (x, y)
        ldy mc_y
        dey
        bmi mc_3
        ldx mc_x
        dex
        bmi mc_1
        lda mc_c
        jsr mc_put
mc_1    ldx mc_x
        inx
        bmi mc_2
        ldy mc_y
        dey
        lda mc_c
        jsr mc_put
mc_2    ldy mc_y
        dey
        dey
        bmi mc_3
        ldx mc_x
        lda mc_c
        jsr mc_put
mc_3    ldx mc_x
        ldy mc_y
        lda mc_c
        jsr mc_put
        dec mc_n
        bne mc_l
        rts
; pixel (X, Y) of the melt buffer via MEMAC: address $9000 + (y&31)*128 + x
mc_addr tya
        lsr
        lsr
        lsr
        lsr
        lsr
        sta tmp             ; y / 32
        lda melt_bank
        asl
        asl
        clc
        adc tmp             ; bank = buffer*4 + y/32
        cmp mc_bank
        beq mca_1
        sta mc_bank
        pha
        tya
        pha
        txa
        pha
        lda mc_bank
        jsr set_bank
        pla
        tax
        pla
        tay
        pla
mca_1   tya
        and #31
        lsr
        sta ptr+1
        lda #0
        ror
        stx tmp
        ora tmp
        sta ptr
        lda ptr+1
        ora #$90
        sta ptr+1
        rts
mc_get  jsr mc_addr
        ldy #0
        lda (ptr),y
        rts
mc_put  sta mc_v
        jsr mc_addr
        ldy #0
        lda mc_v
        sta (ptr),y
        rts
mc_bank dta 0
mc_n    dta 0
mc_x    dta 0
mc_y    dta 0
mc_c    dta 0
mc_v    dta 0

; ------------------------------------------------------------------
; pe(): the end of a stage - scores and rank
results ldx eg
        lda #0
        sta e_jm,x
        ldx fr
        lda #S_IB
        ldy #$ff
        jsr set_state
        ldx eg
        lda #S_CO
        ldy #$ff
        jsr set_state
        ; ck in tenths of a second = flr(frames / 6)
        lda pl_ckl
        sta m_n
        lda pl_ckh
        sta m_n+1
        lda #6
        sta m_d
        lda #0
        sta m_d+1
        jsr div16
        lda m_q
        sta kd_sv0
        lda m_q+1
        sta kd_sv0+1
        ; ek = ta * fc in tenths: ta * fc(8.8) * 10 / 256
        ldx kh
        lda qd_fc_lo,x
        sta m_v
        lda qd_fc_hi,x
        sta m_v+1
        lda lv_ta
        ldx m_v
        jsr umul8           ; ta * fc_lo
        lda m_hi
        sta tmp
        lda lv_ta
        ldx m_v+1
        jsr umul8
        lda m_lo
        clc
        adc tmp
        sta tmp             ; ta*fc (integer, 8 bit is enough for <= 255)
        lda m_hi
        adc #0
        sta tmp+1
        ; * 10
        lda tmp
        ldx #10
        jsr umul8
        lda m_lo
        sta tmp+2
        lda m_hi
        sta tmp+3           ; ek tenths (16 bit)
        ; line 1: bx = max((500 - v) * kh, 0) with v = sv - ek (tenths)
        lda #<500
        sec
        sbc kd_sv0
        sta m_v
        lda #>500
        sbc kd_sv0+1
        sta m_v+1
        lda m_v
        clc
        adc tmp+2
        sta m_v
        lda m_v+1
        adc tmp+3
        sta m_v+1           ; 500 - sv + ek
        bpl rs_1
        lda #0
        sta m_v
        sta m_v+1
rs_1    ; * kh * 8 (scores are kept in eighths)
        jsr rs_kh8
        ldx #0
        jsr rs_store
        ; line 2: v = oh; B8 = 4000 - 120 v + v*v; bx = B8 * kh
        lda pl_ohl
        sta kd_sv1
        sta tmp+4
        lda #0
        sta kd_sv1+1
        lda tmp+4
        tax
        jsr umul8           ; v*v
        lda m_lo
        sta tmp
        lda m_hi
        sta tmp+1
        lda #0
        sta tmp+2
        lda tmp+4
        ldx #120
        jsr umul8           ; 120 v
        ; 4000 + v*v - 120 v (24 bit)
        lda tmp
        clc
        adc #<4000
        sta tmp
        lda tmp+1
        adc #>4000
        sta tmp+1
        lda tmp+2
        adc #0
        sta tmp+2
        lda tmp
        sec
        sbc m_lo
        sta tmp
        lda tmp+1
        sbc m_hi
        sta tmp+1
        lda tmp+2
        sbc #0
        sta tmp+2
        bpl rs_2
        lda #0
        sta tmp
        sta tmp+1
        sta tmp+2
rs_2    jsr rs_mkh          ; * kh
        ldx #1
        jsr rs_store
        ; line 3: v = min(gk, 20); bx = (85 v - 2 v v) * kh
        ldx eg
        lda e_gk,x
        sta kd_sv2
        cmp #21
        bcc rs_3
        lda #20
rs_3    sta tmp+4
        ldx #85
        jsr umul8
        lda m_lo
        sta tmp
        lda m_hi
        sta tmp+1
        lda tmp+4
        tax
        jsr umul8
        asl m_lo
        rol m_hi
        lda tmp
        sec
        sbc m_lo
        sta m_v
        lda tmp+1
        sbc m_hi
        sta m_v+1
        bpl rs_4
        lda #0
        sta m_v
        sta m_v+1
rs_4    jsr rs_kh8
        ldx #2
        jsr rs_store
        ; total: score += the three
        ldx #0
rs_t    lda pl_sc0
        clc
        adc kd_bx0,x
        sta pl_sc0
        lda pl_sc1
        adc kd_bx1,x
        sta pl_sc1
        lda pl_sc2
        adc kd_bx2,x
        sta pl_sc2
        inx
        cpx #3
        bne rs_t
        lda pl_sc0
        sta kd_bx0+3
        lda pl_sc1
        sta kd_bx1+3
        lda pl_sc2
        sta kd_bx2+3
        ; rank: while score < mt[rank]*kh*jn (*8): rank -= 1
        lda #5
        sta rank
rs_r    ldx rank
        cpx #1
        beq rs_rd
        lda mt_lo-1,x
        sta m_v
        lda mt_hi-1,x
        sta m_v+1
        jsr rs_kh8          ; mt * 8 * kh
        jsr rs_mjn          ; * jn
        lda pl_sc0
        cmp tmp
        lda pl_sc1
        sbc tmp+1
        lda pl_sc2
        sbc tmp+2
        bcs rs_rd
        dec rank
        jmp rs_r
rs_rd   ; if fr.qy: dset(kh, max(rank, dget(kh)))
        lda lv_qy
        beq rs_cw
        ldx kh
        lda rank
        cmp cdata-1,x
        bcc rs_cw
        sta cdata-1,x
rs_cw   ; cw(eg, ri, 129, {kd, rank})
        ldx eg
        lda #R_RI
        ldy #129
        jmp draw_new

; tmp (24 bit) = m_v * kh * 8
rs_kh8  lda m_v
        sta tmp
        lda m_v+1
        sta tmp+1
        lda #0
        sta tmp+2
        ldx #3
r8_l    asl tmp
        rol tmp+1
        rol tmp+2
        dex
        bne r8_l
; tmp (24 bit) *= kh
rs_mkh  lda tmp
        sta tmp+3
        lda tmp+1
        sta tmp+4
        lda tmp+2
        sta tmp+5
        ldx kh
rk_l    dex
        beq rk_d
        lda tmp
        clc
        adc tmp+3
        sta tmp
        lda tmp+1
        adc tmp+4
        sta tmp+1
        lda tmp+2
        adc tmp+5
        sta tmp+2
        jmp rk_l
rk_d    rts
; tmp *= jn (tmp+3.. hold the kh product step)
rs_mjn  lda tmp
        sta tmp+3
        lda tmp+1
        sta tmp+4
        lda tmp+2
        sta tmp+5
        ldx jn
rj_l    dex
        beq rk_d
        lda tmp
        clc
        adc tmp+3
        sta tmp
        lda tmp+1
        adc tmp+4
        sta tmp+1
        lda tmp+2
        adc tmp+5
        sta tmp+2
        jmp rj_l
; line X score = tmp (24 bit)
rs_store
        lda tmp
        sta kd_bx0,x
        lda tmp+1
        sta kd_bx1,x
        lda tmp+2
        sta kd_bx2,x
        rts

; ri tick: the counting sounds
t_ri    ldx dd
        ldy d_ent,x
        ; p.t == 180 (frames 360)
        lda e_th,y
        cmp #>360
        bne tri_1
        lda e_tl,y
        cmp #<360
        bne tri_1
        lda #59
        jmp kl
tri_1   ; a line counting: 0 < c < 1 -> kl(59)
        ldx #1
tri_l   stx tmp+7
        jsr ri_prog
        beq tri_n
        cmp #255
        beq tri_n
        lda #59
        jmp kl
tri_n   ldx tmp+7
        inx
        cpx #5
        bne tri_l
        rts

; c = mid((p.t - i*35)/30, 0, 1) for line X (1..4) of the hero's results
; -> A = c * 255 (0..255)
ri_prog ldy eg
        lda e_tl,y
        sta m_n
        lda e_th,y
        sta m_n+1
        ; t - 35i in frames: frames - 70 i
        txa
        ldx #70
        jsr umul8
        lda m_n
        sec
        sbc m_lo
        sta m_n
        lda m_n+1
        sbc m_hi
        sta m_n+1
        bmi rp_0
        ; / 60 frames -> 0..1
        lda m_n+1
        bne rp_1
        lda m_n
        cmp #60
        bcs rp_1
        ; A * 255 / 60 ~ A * 17 / 4
        ldx #17
        jsr umul8
        lsr m_hi
        ror m_lo
        lsr m_hi
        ror m_lo
        lda m_lo
        rts
rp_0    lda #0
        rts
rp_1    lda #255
        rts

; ri(p, v): the results
dr_ri    lda #1
        sta ri_i
ri_l    ldx ri_i
        jsr ri_prog
        sta ri_c
        bne ri_go
        jmp ri_n
ri_go   ; y = i*7 + 42
        lda ri_i
        asl
        asl
        asl
        sec
        sbc ri_i
        clc
        adc #42
        sta ri_y
        ; gm(r.q_, 6, y, 7)
        ldx ri_i
        lda ri_lab_lo-1,x
        sta str_p
        lda ri_lab_hi-1,x
        sta str_p+1
        lda #6
        sta tx_x
        lda ri_y
        sta tx_y
        lda #0
        sta tx_x+1
        sta tx_y+1
        lda #7
        jsr gm
        ; the value (lines 1..3), right aligned at 89
        ldx ri_i
        cpx #4
        beq ri_sc
        jsr ri_value
        lda #89
        jsr ri_right
        lda #9
        jsr gm
ri_sc   ; gm(flr(r.bx*c).."0", 122, y, 9, 1)
        ldx ri_i
        lda kd_bx0-1,x
        sta tmp
        lda kd_bx1-1,x
        sta tmp+1
        lda kd_bx2-1,x
        sta tmp+2
        ; * c/255 then / 8
        lda ri_c
        cmp #255
        beq ri_f
        jsr ri_mulc
ri_f    ldx #3
ri_8    lsr tmp+2
        ror tmp+1
        ror tmp
        dex
        bne ri_8
        jsr fmt_u24
        ldx #0
        jsr num_cat
        lda #'0'
        sta strbuf,x
        inx
        lda #0
        sta strbuf,x
        lda #122
        jsr ri_right
        lda #9
        jsr gm
ri_n    inc ri_i
        lda ri_i
        cmp #5
        jne ri_l
        ; rank after p.t > 180
        ldy eg
        lda e_th,y
        cmp #>361
        bcc ri_d
        bne ri_rk
        lda e_tl,y
        cmp #<361
        bcc ri_d
ri_rk   lda #<t_rank
        sta str_p
        lda #>t_rank
        sta str_p+1
        lda #50
        sta tx_x
        lda #88
        sta tx_y
        lda #0
        sta tx_x+1
        sta tx_y+1
        lda #9
        jsr gm
        lda #72
        sta bx
        lda #86
        sta by
        lda #0
        sta bx+1
        sta by+1
        lda rank
        clc
        adc #57
        jmp spr1
ri_d    rts
ri_i    dta 0
ri_c    dta 0
ri_y    dta 0
ri_lab_lo dta <t_pc1,<t_pc2,<t_pc3,<t_total
ri_lab_hi dta >t_pc1,>t_pc2,>t_pc3,>t_total

; str_p = strbuf; tx_x = A - len*4; tx_y = ri_y
ri_right
        sta tmp
        ldx #0
rr_c    lda strbuf,x
        beq rr_e
        inx
        bne rr_c
rr_e    txa
        asl
        asl
        sta tmp+1
        lda tmp
        sec
        sbc tmp+1
        sta tx_x
        lda #0
        sbc #0
        sta tx_x+1
        lda ri_y
        sta tx_y
        lda #0
        sta tx_y+1
        lda #<strbuf
        sta str_p
        lda #>strbuf
        sta str_p+1
        rts

; the shown value of line X: "52.3S", "23", "5X" -> strbuf
ri_value
        cpx #1
        bne rv_2
        ; seconds with one decimal: tenths / 10 "." tenths % 10 (no ".0")
        lda kd_sv0
        sta m_n
        lda kd_sv0+1
        sta m_n+1
        lda #10
        sta m_d
        lda #0
        sta m_d+1
        jsr div16
        lda m_rm
        pha
        lda m_q
        sta m_n
        lda m_q+1
        sta m_n+1
        jsr fmt_u16
        ldx #0
        jsr num_cat
        pla
        beq rv_s
        pha
        lda #'.'
        sta strbuf,x
        inx
        pla
        ora #'0'
        sta strbuf,x
        inx
rv_s    lda #'S'
        sta strbuf,x
        inx
        lda #0
        sta strbuf,x
        rts
rv_2    cpx #2
        bne rv_3
        lda kd_sv1
        sta m_n
        lda #0
        sta m_n+1
        jsr fmt_u16
        ldx #0
        jmp num_cat
rv_3    lda kd_sv2
        sta m_n
        lda #0
        sta m_n+1
        jsr fmt_u16
        ldx #0
        jsr num_cat
        lda #'X'
        sta strbuf,x
        inx
        lda #0
        sta strbuf,x
        rts

; tmp (24 bit) = tmp * ri_c / 256
ri_mulc lda tmp
        ldx ri_c
        jsr umul8
        lda m_hi
        sta tmp+3
        lda tmp+1
        ldx ri_c
        jsr umul8
        lda m_lo
        clc
        adc tmp+3
        sta tmp+3
        lda m_hi
        adc #0
        sta tmp+4
        lda tmp+2
        ldx ri_c
        jsr umul8
        lda m_lo
        clc
        adc tmp+4
        sta tmp+4
        lda m_hi
        adc #0
        sta tmp+2
        lda tmp+3
        sta tmp
        lda tmp+4
        sta tmp+1
        rts

; fmt_u24: tmp (24 bit) -> numbuf
fmt_u24 ldx #0
        stx fm_lead
        ldy #6
f24_d   lda #0
        sta fm_dig
f24_s   lda tmp
        sec
        sbc d24_0,y
        sta tmp+3
        lda tmp+1
        sbc d24_1,y
        sta tmp+4
        lda tmp+2
        sbc d24_2,y
        bcc f24_p
        sta tmp+2
        lda tmp+4
        sta tmp+1
        lda tmp+3
        sta tmp
        inc fm_dig
        jmp f24_s
f24_p   lda fm_dig
        ora fm_lead
        bne f24_w
        cpy #0
        bne f24_n
f24_w   lda fm_dig
        ora #'0'
        sta numbuf,x
        inx
        sta fm_lead
f24_n   dey
        bpl f24_d
        lda #0
        sta numbuf,x
        rts
d24_0   dta <1,<10,<100,<1000,<10000,<100000,<1000000
d24_1   dta >1,>10,>100,>1000,>10000,>100000,>1000000
d24_2   dta ^1,^10,^100,^1000,^10000,^100000,^1000000
