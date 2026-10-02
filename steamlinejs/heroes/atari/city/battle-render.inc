; Indexed VBXE scenery, transparent fighters and thin tactical hex outlines.
.proc draw
        mva #0 dirty
        mva back_bank render_bank
        rect 0,0,320,200,1
        ldx region
        mva #0 bl_src
        lda map_hi,x
        sta bl_src+1
        lda map_bank,x
        sta bl_src+2
        mwa #320 bl_ssy
        mwa #319 bl_w
        mva #127 bl_h
        mwa #0 calc_x
        mva #28 calc_y
        jsr transparent_blit
        ldx contract
        mva contract_name_lo,x text_src
        mva contract_name_hi,x text_src+1
        mwa #8 text_x
        mva #4 text_y
        jsr draw_text
        labeltext 214,4,s_round
        mva turn_number number_value
        mva #0 number_value+1
        jsr format_number
        labeltext 256,4,number_text+2
        rect 0,15,320,1,2
        labeltext 8,18,s_hint
        mva #0 draw_cell
?grid   mva #0 hex_kind
        lda game_state
        ora enemy_busy
        ora animation_active
        ora attack_frame
        bne ?hex
        lda draw_cell
        jsr action_at
        beq ?hex
        sta hex_kind
?hex    jsr hex
        inc draw_cell
        lda draw_cell
        cmp #42
        bne ?grid
        lda cursor_cell
        cmp #42
        bcs ?no_cursor
        sta draw_cell
        mva #3 hex_kind
        jsr hex
?no_cursor
        mva #0 draw_cell
?units  ldx draw_cell
        lda terrain,x
        beq ?fighter
        jsr obstacle
?fighter
        lda draw_cell
        jsr unit_at
        bcc ?next
        stx draw_id
        jsr fighter
?next   inc draw_cell
        lda draw_cell
        cmp #42
        bne ?units
?hud    jsr projectile
        jsr hud
        lda popup_open
        ora game_state
        beq ?present
        jsr modal
?present
        jsr wait_blit
        jmp present_back_buffer
.endp
map_hi dta $40,$00,$A0,$40
map_bank dta 4,6,6,7
draw_cell dta 0
draw_id dta 0
hex_kind dta 0
hex_lo dta <$E400,<$E700,<$EA00,<$ED00,<$F000
hex_hi dta >$E400,>$E700,>$EA00,>$ED00,>$F000
.proc hex
        ldx hex_kind
        lda hex_lo,x
        sta bl_src
        lda hex_hi,x
        sta bl_src+1
        mva #3 bl_src+2
        mwa #32 bl_ssy
        mwa #31 bl_w
        mva #23 bl_h
        ldx draw_cell
        lda cell_x_lo,x
        sec
        sbc #16
        sta calc_x
        mva #0 calc_x+1
        lda cell_y,x
        sec
        sbc #12
        sta calc_y
        jmp transparent_blit
.endp
.proc fighter
        ldx draw_id
        ldy unit_cell,x
        mva cell_x_lo,y foot_x
        mva cell_y,y foot_y
        lda animation_active
        beq ?base
        cpx animation_unit
        bne ?base
        mva animation_x foot_x
        mva animation_y foot_y
?base   lda attack_frame
        beq ?ground
        cpx attacker_unit
        bne ?ground
        lda attack_ranged
        bne ?ground
        ldy attack_frame
        lda unit_team,x
        bne ?left_lunge
        clc
        lda foot_x
        adc lunge-1,y
        sta foot_x
        jmp ?ground
?left_lunge
        sec
        lda foot_x
        sbc lunge-1,y
        sta foot_x
?ground lda foot_x
        sec
        sbc #10
        sta calc_x
        mva #0 calc_x+1
        lda foot_y
        clc
        adc #2
        sta calc_y
        mwa #20 fr_w
        mva #3 fr_h
        mva #8 fr_col
        lda unit_team,x
        beq ?friendly
        mva #9 fr_col
        jmp ?ellipse
?friendly
        cpx selected_unit
        bne ?ellipse
        mva #2 fr_col
?ellipse jsr fill_rect
        lda attack_flash
        beq ?sprite
        lda draw_id
        cmp attack_flash_target
        beq ?bar
?sprite lda foot_x
        sec
        sbc #16
        sta calc_x
        mva #0 calc_x+1
        lda foot_y
        sec
        sbc #24
        sta calc_y
        ldx draw_id
        lda unit_type,x
        jsr hero_sprite
?bar    rts
.endp
foot_x dta 0
foot_y dta 0
bar_acc dta 0
bar_width dta 0
bar_ticks dta 0
enemy_sprite_lo dta <$E000,<$E380,<$E700,<$EA80,<$EE00,<$F180,<$F500,<$F880,<$FC00
enemy_sprite_hi dta >$E000,>$E380,>$E700,>$EA80,>$EE00,>$F180,>$F500,>$F880,>$FC00
.proc hud
        rect 0,158,320,42,1
        rect 0,157,320,1,2
        ldx selected_unit
        lda enemy_busy
        beq ?focus
        ldx enemy_id
        jmp ?show
?focus  lda cursor_cell
        cmp #42
        bcs ?show
        jsr unit_at
        bcs ?show
        ldx selected_unit
?show   mva #159 info_y
        jsr info
        labeltext 8,170,s_health_label
        labeltext 92,170,s_damage_label
        labeltext 172,170,s_move_label
        labeltext 248,170,s_shoot_label
        labeltext 8,180,stats_line+2
        labeltext 92,180,stats_line+9
        labeltext 172,180,stats_line+12
        labeltext 248,180,stats_line+17
        rect 7,191,80,9,7
        rect 233,191,80,9,7
        lda cursor_cell
        cmp #42
        bcc ?labels
        mwa #7 calc_x
        cmp #43
        bne ?border
        mwa #233 calc_x
?border mva #191 calc_y
        mwa #80 fr_w
        mva #9 fr_h
        mva #2 fr_col
        jsr outline
?labels labeltext 20,192,s_skip
        labeltext 103,192,s_fire
        labeltext 260,192,s_menu
        rts
.endp
s_health_label dta c'HEALTH',0
s_damage_label dta c'ATTACK',0
s_move_label dta c'MOVE',0
s_shoot_label dta c'SHOOT',0
.proc info
        stx info_id
        ldy unit_type,x
        lda type_name_lo,y
        sta text_src
        lda type_name_hi,y
        sta text_src+1
        mwa #8 text_x
        mva info_y text_y
        jsr draw_text
        ldx info_id
        mva unit_hp,x number_value
        mva #0 number_value+1
        jsr format_number
        mva number_text+3 stats_line+2
        mva number_text+4 stats_line+3
        ldx info_id
        ldy unit_type,x
        mva type_hp,y number_value
        jsr format_number
        mva number_text+3 stats_line+5
        mva number_text+4 stats_line+6
        ldx info_id
        ldy unit_type,x
        lda type_damage,y
        clc
        adc #48
        sta stats_line+9
        lda unit_move_left,x
        pha
        lda unit_acted,x
        beq ?moves
        pla
        lda #0
        pha
?moves  pla
        clc
        adc #48
        sta stats_line+12
        lda type_move,y
        clc
        adc #48
        sta stats_line+14
        lda type_shoot_range,y
        clc
        adc #48
        sta stats_line+17
        ldx info_id
        lda unit_team,x
        bne ?enemy
        lda unit_acted,x
        beq ?ready
        mwa #s_acted text_src
        jmp ?status
?ready  mwa #s_ready_unit text_src
        jmp ?status
?enemy  mwa #s_enemy text_src
?status mwa #264 text_x
        mva info_y text_y
        jmp draw_text
.endp
stats_line dta c'HP  /  ',0,c'A0',0,c'M0/0',0,c'S0',0
info_id dta 0
info_y dta 0
.proc modal
        rect 38,43,244,110,1
        mwa #38 calc_x
        mva #43 calc_y
        mwa #244 fr_w
        mva #110 fr_h
        mva #2 fr_col
        jsr outline
        lda game_state
        jeq ?menu
        tax
        lda result_lo,x
        sta text_src
        lda result_hi,x
        sta text_src+1
        mwa #62 text_x
        mva #57 text_y
        jsr draw_text
        labeltext 62,80,s_recovery
        labeltext 62,96,s_reward
        mwa reward number_value
        jsr format_number
        labeltext 206,96,number_text
        labeltext 62,133,s_return
        rts
?menu   labeltext 62,57,s_battle_menu
        mva #0 menu_row
?row    ldx menu_row
        mva menu_y,x text_y
        mva menu_lo,x text_src
        mva menu_hi,x text_src+1
        mwa #76 text_x
        jsr draw_text
        lda menu_row
        cmp popup_choice
        bne ?next
        ldx menu_row
        lda menu_y,x
        sec
        sbc #3
        sta calc_y
        mwa #62 calc_x
        mwa #196 fr_w
        mva #14 fr_h
        mva #2 fr_col
        jsr outline
?next   inc menu_row
        lda menu_row
        cmp #3
        bne ?row
        rts
.endp
menu_row dta 0
menu_y dta 83,105,127
menu_lo dta <s_skip,<s_retreat,<s_resume
menu_hi dta >s_skip,>s_retreat,>s_resume
result_lo dta <s_victory,<s_victory,<s_defeat,<s_retreated
result_hi dta >s_victory,>s_victory,>s_defeat,>s_retreated
s_round dta c'ROUND',0
s_hint dta c'FIRE:ACTION  DOUBLE FIRE ON ALLY:SKIP',0
s_skip dta c'SKIP UNIT',0
s_fire dta c'FIRE: ACTION',0
s_menu dta c'MENU',0
s_acted dta c'ACTED',0
s_ready_unit dta c'READY',0
s_enemy dta c'ENEMY',0
s_victory dta c'VICTORY!',0
s_defeat dta c'DEFEAT',0
s_retreated dta c'RETREATED',0
s_recovery dta c'YOUR ARMY RECOVERS FULLY',0
s_reward dta c'GOLD EARNED',0
s_return dta c'FIRE: RETURN TO MAP',0
s_battle_menu dta c'BATTLE MENU',0
s_retreat dta c'RETREAT',0
s_resume dta c'RESUME BATTLE',0

.proc obstacle
        ldx region
        ldy obstacle_type,x
        mva obstacle_lo,y bl_src
        mva obstacle_hi,y bl_src+1
        mva #3 bl_src+2
        mwa #32 bl_ssy
        mwa #31 bl_w
        mva #27 bl_h
        ldx draw_cell
        lda cell_x_lo,x
        sec
        sbc #16
        sta calc_x
        mva #0 calc_x+1
        lda cell_y,x
        sec
        sbc #24
        sta calc_y
        jmp transparent_blit
.endp
obstacle_type dta 0,1,2,1
obstacle_lo dta <$F300,<$F680,<$FA00
obstacle_hi dta >$F300,>$F680,>$FA00

lunge dta 0,2,4,6,6,4,2,0
        icl 'battle-heroes.inc'
