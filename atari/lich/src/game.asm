; ------------------------------------------------------------------
; States (_update / _draw), the title screen and the level.
; ------------------------------------------------------------------
swap_title
        lda #0
        beq sw_s
swap_level
        lda #1
sw_s    sta next_state
        lda #1
        sta change_state
        rts

game_update
        jsr read_buttons
        lda change_state
        beq gu_1
        lda next_state
        sta state
        lda #0
        sta change_state
        jsr windows_reset
        lda state
        bne gu_li
        jsr title_init
        jmp gu_1
gu_li   jsr level_init
gu_1    jsr update_windows
        bcc gu_2
        lda state
        bne gu_lu
        jsr title_update
        jmp gu_2
gu_lu   jsr level_update
gu_2    lda fade_p
        beq gu_r
        sec
        sbc #15
        bcs gu_3
        lda #0
gu_3    sta fade_p
gu_r    rts

game_draw
        inc tc_clock
        inc frame30
        lda frame30
        cmp #30
        bcc gd_1
        lda #0
        sta frame30
gd_1    jsr clip_reset
        lda state
        bne gd_lv
        jsr title_draw
        jmp gd_2
gd_lv   jsr level_draw
gd_2    jsr clip_reset
        jsr draw_windows
; update_fade: k = flr(6 * fade_progress)
update_fade
        ldx #0
        lda fade_p
uf_kl   cmp fade_thr,x
        bcc uf_k
        inx
        cpx #6
        bne uf_kl
uf_k    stx fade_k
        rts
fade_thr dta 34,67,100,134,167,200

; fadeout(): fade the shown frame to black
fadeout lda fade_p
        cmp #200
        bcs fo_r
        clc
        adc #10
        cmp #200
        bcc fo_2
        lda #200
fo_2    sta fade_p
        jsr update_fade
        jsr flip
        jmp fadeout
fo_r    rts

; ---------------------------------------------------------- title
title_init
        lda #0
        sta title_t
        sta title_t+1
        rts

title_update
        inc title_t
        bne tu_1
        inc title_t+1
tu_1    lda title_t+1
        cmp #>769
        bcc tu_2
        lda title_t
        cmp #<769
        bcc tu_2
        lda #0
        sta title_t
        sta title_t+1
tu_2    lda next_btn
        bmi tu_r
        cmp #4
        bcc tu_r
        lda #53
        jsr sfx
        jsr fadeout
        jsr swap_level
tu_r    lda #$ff
        sta next_btn
        rts

title_draw
        jsr title_bg
        ; logo spr(139,44,27,5,2)
        lda #5
        sta spr_tw
        lda #2
        sta spr_th
        lda #0
        sta spr_flip
        sta spr_var
        sta bx+1
        sta by+1
        lda #44
        sta bx
        lda #27
        sta by
        lda #139
        jsr spr_draw
        ; story: clip(0,50,128,33), y = 86 - ceil(t/7) + 7k
        lda #50
        sta cy0
        lda #83
        sta cy1
        lda title_t
        clc
        adc #6
        sta m_r
        lda title_t+1
        adc #0
        sta m_r+1
        lda #7
        sta tmp
        jsr div16_8
        sta td_off
        lda #86
        sec
        sbc td_off
        sta td_y
        lda #0
        sbc #0
        sta td_y+1
        lda #6
        sta txt_c1
        lda #2
        sta txt_c2
        lda #0
        sta td_k
td_l    ; visible when y < 83 and y + 7 > 50
        lda td_y+1
        bmi td_n
        bne td_d
        lda td_y
        cmp #83
        bcs td_d
        cmp #44
        bcc td_n
        lda td_k
        asl
        tay
        lda ml_story+1,y
        sta sp
        lda ml_story+2,y
        sta sp+1
        lda #16
        sta bx
        lda #0
        sta bx+1
        lda td_y
        sta by
        lda #0
        sta by+1
        jsr text_draw
td_n    lda td_y
        clc
        adc #7
        sta td_y
        lda td_y+1
        adc #0
        sta td_y+1
        inc td_k
        lda td_k
        cmp ml_story
        bcc td_l
td_d    jsr clip_reset
        jsr title_dither
        lda #12
        sta txt_c1
        lda #5
        sta txt_c2
        mwa #s_embark sp
        lda #46
        ldx #104
        jsr pr_at
        lda #5
        sta txt_c1
        lda #1
        sta txt_c2
        mwa #s_credit1 sp
        lda #26
        ldx #115
        jsr pr_at
        mwa #s_credit2 sp
        lda #26
        ldx #122
        jmp pr_at
td_off  dta 0
td_y    dta a(0)
td_k    dta 0

; ---------------------------------------------------------- level
free_entities
        ldx #MAXENT-1
fe_l    cpx pl
        beq fe_n
        lda #0
        sta e_id,x
fe_n    dex
        cpx #$ff
        bne fe_l
        lda #0
        sta ent_n
        rts

level_init
        lda #$ff
        sta pl
        jsr free_entities
        lda #0
        sta a0
        sta a1
        jsr make_player
        lda #0
        sta ent_n
        lda #1
        sta pl_depth
        sta pl_lvl
        lda #0
        sta pl_win
        sta pl_blind
        sta inv_n
        sta sleep
        sta pl_xp
        sta pl_xp+1
        ldx #8
li_inv  sta it_on,x
        dex
        bpl li_inv
        lda #$ff
        sta pl_wpn
        mwa #s_none hit_name
        ; starting items (a stick and an apple)
        ldy #0
li_si   lda start_items,y
        beq li_sd
        sty li_y
        ldx #0
        jsr make_item
        lda #1
        jsr give_item
        ldy li_y
        iny
        bne li_si
li_sd
        ; hud = add_window(0,115,{" "},128)
        lda #0
        ldx #115
        jsr win_new
        mwa #s_space sp
        jsr win_line
        lda #128
        jsr win_finish
        ldx w_i
        lda #1
        sta wn_hud,x
        sta hud_dirty
        jsr make_new_level
        lda #2
        jsr music
        lda pl_depth
        cmp #1
        bne li_r
        lda #10
        ldx #10
        jsr win_new
        mwa #ml_intro sp
        jsr win_lines
        lda #108
        jsr win_finish
        lda #0
        jsr add_modal
li_r    rts

; fog = 2 everywhere
fog_reset
        lda #2
        ldx #0
mnl_fog sta FOG,x
        sta FOG+$100,x
        sta FOG+$200,x
        sta FOG+$300,x
        sta FOG+$400,x
        sta FOG+$500,x
        sta FOG+$600,x
        sta FOG+$700,x
        sta FOG+$800,x
        sta FOG+$900,x
        sta FOG+$a00,x
        sta FOG+$b00,x
        sta FOG+$c00,x
        sta FOG+$d00,x
        sta FOG+$e00,x
        sta FOG+$f00,x
        inx
        bne mnl_fog
        rts

make_new_level
        lda #0
        sta phase
        sta floater_delay
        jsr free_entities
        jsr occ_clear
        ldx #MAXPART-1
        lda #0
mnl_p   sta pa_life,x
        dex
        bpl mnl_p
        ldx #MAXFLT-1
mnl_f   sta fl_on,x
        dex
        bpl mnl_f
        jsr fog_reset
        ; rooms = base + per_floor * depth
        lda #P_ROOMS_BASE
        ldx pl_depth
mnl_r1  clc
        adc #P_ROOMS_PER_FLOOR
        dex
        bne mnl_r1
        cmp #MAXROOM-6
        bcc mnl_r2
        lda #MAXROOM-6
mnl_r2  sta num_rooms
        jsr clear_map
        jsr generate_level
        ldx pl
        lda e_tx,x
        sta camtx
        lda e_ty,x
        sta camty
        lda #0
        sta move_cam
        jsr update_fog
        lda pl_depth
        cmp #2
        bcc mnl_r
        jsr sb_clear
        mwa #s_floor sp
        jsr sb_str
        lda pl_depth
        jsr sb_num
        lda #0
        ldx #60
        jsr show_alert_sb
        ldx w_i
        lda #30
        sta wn_dly,x
mnl_r   rts

; iterate the entity list: X = entity, calls (lu_fn) for each
; (handles removal of the current entity)
ent_each
        lda #0
        sta ee_i
ee_l    ldy ee_i
        cpy ent_n
        bcs ee_r
        lda ent_list,y
        sta ee_e
        tax
        jsr ee_call
        ldy ee_i
        lda ent_list,y
        cmp ee_e
        bne ee_l
        inc ee_i
        jmp ee_l
ee_r    rts
ee_call jmp (ee_fn)
ee_fn   dta a(0)
ee_i    dta 0
ee_e    dta 0

level_update
        lda sleep
        beq lu_go
        dec sleep
        jmp lu_uf
lu_go   lda phase
        bne lu_p2
        ldx pl
        jsr player_logic
        jmp lu_p3
lu_p2   cmp #2
        bne lu_p3
        ; stairs?
        ldx pl
        ldy e_tx,x
        lda e_ty,x
        tax
        jsr mget
        cmp #16
        bne lu_win
        lda #53
        jsr sfx
        jsr fadeout
        inc pl_depth
        jmp make_new_level
lu_win  lda pl_win
        beq lu_mobs
        jsr win_game
        jmp lu_p3
lu_mobs mwa #lu_mob ee_fn
        jsr ent_each
        mwa #lu_trap ee_fn
        jsr ent_each
        inc phase
        ldx pl
        lda e_conf,x
        ora e_para,x
        beq lu_p3
        lda #20
        sta sleep
lu_p3   lda phase
        cmp #3
        bne lu_uf
        ; wait for the moves; attacks wait for the animations
        lda #0
        sta lu_atk
        lda #1
        sta lu_on
        ldy #0
lu_al   cpy ent_n
        bcs lu_ad
        ldx ent_list,y
        lda e_mt,x
        cmp #8
        bcs lu_a1
        lda #0
        sta lu_on
lu_a1   lda e_fl,x
        and #F_ATKD
        beq lu_a2
        lda #1
        sta lu_atk
lu_a2   iny
        jmp lu_al
lu_ad   lda lu_atk
        beq lu_inc
        lda lu_on
        beq lu_uf
lu_inc  inc phase
lu_uf   ; per-frame entity updates
        jsr update_all
        lda phase
        cmp #4
        bcc lu_np
        jsr sort_entities
        lda #0
        sta phase
        ldx pl
        jsr update_status
lu_np   jsr update_particles
        jmp update_floaters
lu_atk  dta 0
lu_on   dta 0

lu_mob  lda e_fl,x
        and #F_TRAP
        bne lm_r
        cpx pl
        beq lm_r
        lda e_hp,x
        beq lm_r
        bmi lm_r
        lda e_logic,x
        beq lm_r
        stx lm_e
        jsr update_status
        ldx lm_e
        jmp run_logic
lm_r    rts
lm_e    dta 0
lu_trap lda e_fl,x
        and #F_TRAP
        beq lm_r
        lda e_logic,x
        beq lm_r
        jmp run_logic
; update every entity (the list may lose the current one).  Props far
; from the camera are static and skipped (only their sparkles differ).
update_all
        ldy #0
ua_l    cpy ent_n
        bcs ua_r
        sty ua_i
        lda ent_list,y
        sta ua_e
        tax
        lda e_fl,x
        and #F_PROP
        beq ua_go
        lda e_tx,x
        sec
        sbc camtx
        clc
        adc #10
        cmp #21
        bcs ua_n
        lda e_ty,x
        sec
        sbc camty
        clc
        adc #10
        cmp #21
        bcs ua_n
ua_go   jsr lu_upd
        ldy ua_i
        lda ent_list,y
        cmp ua_e
        bne ua_l
ua_n    ldy ua_i
        iny
        jmp ua_l
ua_r    rts
ua_i    dta 0
ua_e    dta 0

; draw the entities within the map window
draw_all
        ldy #0
da_l    cpy ent_n
        bcs ua_r
        sty ua_i
        ldx ent_list,y
        lda e_tx,x
        sec
        sbc camtx
        clc
        adc #9
        cmp #19
        bcs da_n
        lda e_ty,x
        sec
        sbc camty
        clc
        adc #9
        cmp #19
        bcs da_n
        jsr draw_entity
da_n    ldy ua_i
        iny
        jmp da_l

lu_upd  lda e_fl,x
        and #F_PROP
        beq lup_e
        jmp update_prop
lup_e   cpx pl
        bne lup_m
        jsr update_entity
        bcc lup_r
        lda phase
        cmp #1
        bne lup_r
        inc phase
lup_r   rts
lup_m   jmp update_entity

; stable insertion sort of ent_list by ty
sort_entities
        ldy #1
se_l    cpy ent_n
        bcs se_r
        sty se_k
se_j    ldx ent_list,y
        lda e_ty,x
        ldx ent_list-1,y
        cmp e_ty,x
        bcs se_n
        ; swap a[j-1], a[j]
        lda ent_list,y
        sta ent_list-1,y
        txa
        sta ent_list,y
        dey
        bne se_j
se_n    ldy se_k
        iny
        bne se_l
se_r    rts
se_k    dta 0


player_logic
        lda e_hp,x
        beq pl_dead
        bmi pl_dead
        lda e_para,x
        beq pl_1
        inc phase
        lda #0
        sta a4
        sta a5
        sta a6
        jsr move_anim
        jmp pl_end
pl_1    lda e_conf,x
        beq pl_2
        lda #4
        jsr intrnd
        sta next_btn
pl_2    lda next_btn
        cmp #4
        bcs pl_3
        tay
        iny
        lda dirx,y
        sta a4
        lda diry,y
        sta a5
        ldx pl
        jsr move_entity
        bcc pl_end
        jsr update_fog
        inc phase
        jmp pl_end
pl_3    cmp #5
        bne pl_end
        jsr show_inventory
pl_end  lda #$ff
        sta next_btn
        rts
pl_dead lda e_hitc,x
        bne pl_dr
        lda #$ff
        sta e_hitc,x
        ; "", "^killed by X", "on floor N.", ""
        lda #32
        ldx #32
        jsr win_new
        mwa #s_none sp
        jsr win_line
        jsr sb_clear
        mwa #s_killedby sp
        jsr sb_str
        mwa hit_name sp
        jsr sb_str
        lda #0
        jsr win_linebuf
        jsr sb_clear
        mwa #s_onfloor sp
        jsr sb_str
        lda pl_depth
        jsr sb_num
        lda #G_DOT
        jsr sb_glyph
        lda #1
        jsr win_linebuf
        mwa #s_none sp
        jsr win_line
        lda #0
        jsr win_finish
        lda #1
        jmp add_modal
pl_dr   rts

win_game
        lda #$fe
        jsr music
        lda #6
        jsr sfx
        ldx #50
wg_l    stx wg_n
        jsr flip
        ldx wg_n
        dex
        bne wg_l
        jsr fadeout
        lda #23
        jsr music
        lda #8
        ldx #24
        jsr win_new
        mwa #ml_win sp
        jsr win_lines
        lda #112
        jsr win_finish
        lda #2
        jmp add_modal
wg_n    dta 0
li_y    dta 0

; ---------------------------------------------------------- level draw
level_draw
        ; camera follows the hero with a dead zone of 2 tiles
        ldx pl
        lda camtx
        sec
        sbc #2
        bmi ld_c1
        cmp e_tx,x
        bcc ld_c1
        beq ld_c1
        dec camtx
        jmp ld_cm
ld_c1   lda camtx
        clc
        adc #2
        cmp e_tx,x
        bcs ld_c2
        inc camtx
        jmp ld_cm
ld_c2   lda camty
        sec
        sbc #2
        bmi ld_c3
        cmp e_ty,x
        bcc ld_c3
        beq ld_c3
        dec camty
        jmp ld_cm
ld_c3   lda camty
        clc
        adc #2
        cmp e_ty,x
        bcs ld_cs
        inc camty
ld_cm   lda #1
        sta move_cam
ld_cs   ; camera = (camtx-8)*8+4 (+ hero offset while moving)
        lda camtx
        jsr cam_base
        sta camx
        stx camx+1
        lda camty
        jsr cam_base
        sta camy
        stx camy+1
        lda move_cam
        beq ld_nm
        ldx pl
        lda e_oxh,x
        jsr add_camx
        lda e_oyh,x
        jsr add_camy
ld_nm   ldx pl
        lda e_oxh,x
        ora e_oyh,x
        ora e_oxl,x
        ora e_oyl,x
        bne ld_1
        sta move_cam
ld_1    jsr cls
        jsr map_draw
        jsr draw_all
        jsr draw_particles
        jsr draw_floaters
        ; top-left icon and the backpack hint
        lda #2
        sta spr_tw
        sta spr_th
        lda #0
        sta spr_flip
        sta spr_var
        sta bx+1
        sta by+1
        sta by
        lda #1
        sta bx
        lda #174
        jsr spr_draw
        ldx pl
        lda e_hp,x
        beq ld_r
        bmi ld_r
        lda modal_top
        bpl ld_r
        lda #5
        sta txt_c1
        lda #$ff
        sta txt_c2
        mwa #s_btn sp
        lda #16
        ldx #7
        jsr pr_at
        lda #12
        sta txt_c1
        ldx #6
        lda inv_n
        cmp #8
        bne ld_2
        lda #8
        sta txt_c1
        ldy frame30
        ldx bob_tab,y
ld_2    lda #16
        jsr pr_at
ld_r    rts

; (A - 8) * 8 + 4 -> A low, X high (signed)
cam_base
        sec
        sbc #8
        sta tmp
        lda #0
        sbc #0
        sta tmp+1
        asl tmp
        rol tmp+1
        asl tmp
        rol tmp+1
        asl tmp
        rol tmp+1
        lda tmp
        clc
        adc #4
        sta tmp
        bcc cb_1
        inc tmp+1
cb_1    lda tmp
        ldx tmp+1
        rts
add_camx
        clc
        adc camx
        sta camx
        lda e_oxh,x
        and #$80
        beq acx
        lda #$ff
acx     adc camx+1
        sta camx+1
        rts
add_camy
        clc
        adc camy
        sta camy
        lda e_oyh,x
        and #$80
        beq acy
        lda #$ff
acy     adc camy+1
        sta camy+1
        rts

; bx, by = entity X position on screen
ent_screen
        lda e_tx,x
        jsr times8
        lda pt_x
        clc
        adc e_oxh,x
        sta bx
        lda e_oxh,x
        and #$80
        beq es_1
        lda #$ff
es_1    adc pt_x+1
        sta bx+1
        lda bx
        sec
        sbc camx
        sta bx
        lda bx+1
        sbc camx+1
        sta bx+1
        lda e_ty,x
        jsr times8
        lda pt_x
        clc
        adc e_oyh,x
        sta by
        lda e_oyh,x
        and #$80
        beq es_2
        lda #$ff
es_2    adc pt_x+1
        sta by+1
        lda by
        sec
        sbc camy
        sta by
        lda by+1
        sbc camy+1
        sta by+1
        rts

draw_entity
        stx de_e
        ldy e_tx,x
        lda e_ty,x
        tax
        jsr fog_get
        cmp #2
        jeq de_r
        sta de_fog
        ldx de_e
        ; invisible monsters show only next to the hero
        ldy e_id,x
        lda m_abil3,y
        and #AB3_INVIS
        beq de_vis
        ldy pl
        lda e_tx,x
        sec
        sbc e_tx,y
        clc
        adc #1
        cmp #3
        jcs de_r
        lda e_ty,x
        sec
        sbc e_ty,y
        clc
        adc #1
        cmp #3
        jcs de_r
de_vis  ; palette: dark in fog, flash when hit
        lda de_fog
        ldy #0
        cmp #1
        bne de_1
        ldy #2
de_1    lda e_hitc,x
        beq de_2
        bmi de_2
        lda e_t,x
        jsr mod3
        bne de_2
        ldy #3
de_2    sty spr_var
        jsr ent_screen
        lda bx
        sta de_x
        lda bx+1
        sta de_x+1
        lda by
        sta de_y
        lda by+1
        sta de_y+1
        ldx de_e
        lda #1
        sta spr_tw
        sta spr_th
        lda #0
        sta spr_flip
        lda e_dir,x
        bpl de_3
        inc spr_flip
de_3    ; frame sprite
        lda e_fmode,x
        beq de_fn
        cmp #2
        beq de_fl
        lda e_frame,x
        cmp #8
        bcc de_f8
        clc
        adc #P_DEATH_SPRITE-7
        jmp de_fs
de_f8   lda #P_DEATH_SPRITE
        jmp de_fs
de_fl   lda #P_BOSS_DEAD_SPRITE
        jmp de_fs
de_fn   lda e_pg,x
        sta spr_page
        lda e_fbase,x
        clc
        adc e_frame,x
de_fs   jsr spr_draw
        lda #0
        sta spr_page
        ldx de_e
        lda e_hp,x
        jeq de_r
        jmi de_r
        ; weapon
        cpx pl
        bne de_ind
        ldy pl_wpn
        bmi de_ind
        lda #0
        sta spr_var
        lda de_x
        clc
        adc e_dir,x
        sta bx
        lda e_dir,x
        and #$80
        beq de_w1
        lda #$ff
de_w1   adc de_x+1
        sta bx+1
        lda de_y
        sta by
        lda de_y+1
        sta by+1
        lda it_spr,y
        clc
        adc e_frame,x
        jsr spr_draw
        ldx de_e
de_ind  ; "?" when confused, "..." when paralyzed
        lda e_para,x
        beq de_i1
        mwa #s_dots sp
        lda #6-6
        jmp de_i2
de_i1   lda e_conf,x
        beq de_r
        mwa #s_quest sp
        lda #6-2
de_i2   clc
        adc de_x
        sta bx
        lda de_x+1
        adc #0
        sta bx+1
        lda de_y
        sec
        sbc #6
        sta by
        lda de_y+1
        sbc #0
        sta by+1
        lda #10
        sta txt_c1
        lda #$ff
        sta txt_c2
        jsr text_draw
de_r    ldx de_e
        rts
de_e    dta 0
de_fog  dta 0
de_x    dta a(0)
de_y    dta a(0)

mod3    cmp #3
        bcc m3_r
        sbc #3
        jmp mod3
m3_r    cmp #0
        rts

draw_particles
        ldx #MAXPART-1
dp_l    lda pa_life,x
        beq dp_n
        stx dp_i
        lda pa_xl,x
        sec
        sbc camx
        sta bx
        lda pa_xh,x
        sbc camx+1
        sta bx+1
        lda pa_yl,x
        sec
        sbc camy
        sta by
        lda #0
        sbc camy+1
        sta by+1
        ; colour: random element of the list
        lda pa_c,x
        cmp #PC_SINGLE
        bcc dp_list
        and #15
        jmp dp_c
dp_list tay
        lda pcol_n,y
        jsr intrnd
        clc
        adc pcol_o,y
        tay
        lda pcol_c,y
dp_c    jsr pset_draw
        ldx dp_i
dp_n    dex
        bpl dp_l
        rts
dp_i    dta 0

draw_floaters
        ldx #0
df_l    lda fl_on,x
        beq df_n
        lda fl_dly,x
        bne df_n
        stx df_i
        ; text
        txa
        asl
        asl
        asl
        asl
        clc
        adc #<fl_str
        sta sp
        lda #>fl_str
        adc #0
        sta sp+1
        jsr tlen
        lsr
        sta df_hw
        ldx df_i
        lda fl_c,x
        sta txt_c1
        lda #1
        sta txt_c2
        lda fl_oyh,x
        sta df_oy
        ldy fl_e,x
        tya
        tax
        jsr ent_screen
        ; x += 4 - w/2, y += -4 + oy
        lda bx
        clc
        adc #4
        sta bx
        bcc df_1
        inc bx+1
df_1    lda bx
        sec
        sbc df_hw
        sta bx
        bcs df_2
        dec bx+1
df_2    lda df_oy
        sec
        sbc #4
        sta tmp
        clc
        adc by
        sta by
        lda tmp
        and #$80
        beq df_3
        lda #$ff
df_3    adc by+1
        sta by+1
        jsr text_draw
        ldx df_i
df_n    inx
        cpx #MAXFLT
        bne df_l
        rts
df_i    dta 0
df_hw   dta 0
df_oy   dta 0
