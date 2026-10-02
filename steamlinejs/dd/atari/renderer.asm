; Draw only into the non-displayed framebuffer, then switch XDL at VBL.
render
        ldx #20
background_command
        lda background_bcb,x
        sta command,x
        dex
        bpl background_command
        lda camera
        sta command
        lda camera+1
        sta command+1
        lda back
        sta command+8
        jsr blit
        jsr build_actors
        lda #0
        sta entity
draw_actor
        ldy entity
        ldx depth_order,y
        lda actor_tile,x
        cmp #255
        beq next_actor
        pha
        lda actor_x,x
        sta draw_x
        lda #0
        sta draw_x+1
        lda actor_y,x
        sta draw_y
        pla
        jsr sprite
next_actor
        inc entity
        lda entity
        cmp #4
        bne draw_actor
        ; Compact life bar, kept in addition to the numeric ANTIC HUD.
        mwa #12 draw_x
        lda #8
        sta draw_y
        mwa #52 rect_w
        lda #8
        sta rect_h
        lda #1
        jsr fill
        mwa #14 draw_x
        lda #10
        sta draw_y
        lda health
        beq no_health_bar
        asl
        asl
        sta rect_w
        lda #4
        sta rect_h
        lda #96
        jsr fill
no_health_bar
        lda mode
        cmp #PLAY
        bne mode_panel
        lda travel
        beq stage_banner
        mwa #208 draw_x
        lda #30
        sta draw_y
        mwa #go_text str
        jsr text
        jmp present
stage_banner
        lda banner_ticks
        jeq present
        mwa #96 draw_x
        lda #32
        sta draw_y
        ldx stage
        lda stage_lo,x
        sta str
        lda stage_hi,x
        sta str+1
        jsr text
        jmp present
mode_panel
        mwa #40 draw_x
        lda #24
        sta draw_y
        mwa #240 rect_w
        lda #94
        sta rect_h
        lda #1
        jsr fill
        mwa #104 draw_x
        lda #34
        sta draw_y
        mwa #title_text str
        jsr text
        mwa #64 draw_x
        lda #56
        sta draw_y
        ldx mode
        lda panel_lo,x
        sta str
        lda panel_hi,x
        sta str+1
        jsr text
        mwa #64 draw_x
        lda #78
        sta draw_y
        mwa #controls_text str
        jsr text
        mwa #64 draw_x
        lda #94
        sta draw_y
        mwa #kick_text str
        jsr text
present
        jsr wait_blit
        lda $14
wait_frame
        cmp $14
        beq wait_frame
        ldy #$41
        lda back
        beq show_a
        lda #20
show_a
        sta (reg),y
        lda back
        eor #1
        sta back
        jmp draw_hud

build_actors
        ldx #2
build_enemies
        lda enemy_x,x
        sta actor_x+1,x
        lda enemy_y,x
        sta actor_depth+1,x
        sec
        sbc #56
        sta actor_y+1,x
        lda #255
        ldy enemy_hp,x
        beq save_enemy_tile
        lda enemy_stun,x
        beq enemy_visible
        lda tick
        and #2
        bne hide_enemy
enemy_visible
        lda enemy_type,x
        asl
        asl
        asl
        clc
        adc enemy_face,x
        sta pose_base
        lda enemy_pose,x
        bne enemy_selected_pose
        lda tick
        lsr
        lsr
        lsr
        and #1
enemy_selected_pose
        clc
        adc pose_base
        jmp save_enemy_tile
hide_enemy
        lda #255
save_enemy_tile
        sta actor_tile+1,x
        dex
        bpl build_enemies
        lda px
        sta actor_x
        lda py
        sta actor_depth
        sec
        sbc #56
        ldx jump
        sec
        sbc jump_height,x
        sta actor_y
        lda #255
        ldx health
        beq save_player_tile
        lda immune
        beq player_visible
        lda tick
        and #2
        bne hide_player
player_visible
        lda attack
        beq walking_pose
        lda attack_kind
        tax
        lda player_attack_pose,x
        jmp player_pose
walking_pose
        lda moving
        beq player_pose
        lda tick
        lsr
        lsr
        and #1
player_pose
        clc
        adc facing
        jmp save_player_tile
hide_player
        lda #255
save_player_tile
        sta actor_tile
        ldx #3
sort_init
        txa
        sta depth_order,x
        dex
        bpl sort_init
        lda #3
        sta sort_limit
sort_pass
        lda #0
        sta sort_index
sort_pair
        ldx sort_index
        lda depth_order,x
        ldy depth_order+1,x
        tax
        lda actor_depth,x
        cmp actor_depth,y
        bcc sort_next
        beq sort_next
        ldx sort_index
        lda depth_order,x
        ldy depth_order+1,x
        sta depth_order+1,x
        tya
        sta depth_order,x
sort_next
        inc sort_index
        lda sort_index
        cmp sort_limit
        bcc sort_pair
        dec sort_limit
        bne sort_pass
        rts

sprite
        tax
        lda sprite_lo,x
        sta command
        lda sprite_hi,x
        sta command+1
        lda sprite_bank,x
        sta command+2
        lda #64
        sta command+3
        lda #0
        sta command+4
        sta command+13
        lda #63
        sta command+12
        lda #55
        sta command+14
        jsr opaque_defaults
        lda #1
        sta command+20
        jsr destination
        jmp blit

; Null-terminated ASCII, eight-pixel cells. All characters share one atlas.
text
        lda #0
        sta letter
text_loop
        ldy letter
        lda (str),y
        beq text_done
        sec
        sbc #32
        tax
        lda font_lo,x
        sta command
        lda font_hi,x
        sta command+1
        lda font_bank,x
        sta command+2
        lda #8
        sta command+3
        lda #0
        sta command+4
        sta command+13
        lda #7
        sta command+12
        lda #11
        sta command+14
        jsr opaque_defaults
        lda #1
        sta command+20
        jsr destination
        jsr blit
        clc
        lda draw_x
        adc #8
        sta draw_x
        bcc next_letter
        inc draw_x+1
next_letter
        inc letter
        bne text_loop
text_done
        rts

fill
        pha
        jsr opaque_defaults
        pla
        sta command+16
        lda #0
        sta command+15
        sta command
        sta command+1
        sta command+2
        sta command+3
        sta command+4
        lda rect_w
        sec
        sbc #1
        sta command+12
        lda rect_w+1
        sbc #0
        sta command+13
        lda rect_h
        sec
        sbc #1
        sta command+14
        jsr destination
        jmp blit
opaque_defaults
        lda #1
        sta command+5
        sta command+11
        lda #64
        sta command+9
        lda #1
        sta command+10
        lda #255
        sta command+15
        lda #0
        sta command+16
        sta command+17
        sta command+18
        sta command+19
        sta command+20
        rts
destination
        ldx draw_y
        clc
        lda row_lo,x
        adc draw_x
        sta command+6
        lda row_hi,x
        adc draw_x+1
        sta command+7
        lda back
        sta command+8
        rts
blit
        jsr wait_blit
        jsr map_control
        ldx #20
copy_command
        lda command,x
        sta MEMAC_WINDOW+$100,x
        dex
        bpl copy_command
        ldy #$53
        lda #1
        sta (reg),y
        rts
wait_blit
        ldy #$53
blit_busy
        lda (reg),y
        bne blit_busy
        rts
map_control
        ldy #$5e
        lda #MEMAC_CONFIG    ; configure the window, not just its VRAM bank
        sta (reg),y
        iny
        lda #$ff
        sta (reg),y
        rts

draw_hud
        ldx #39
hud_clear
        lda hud_template,x
        sta status,x
        dex
        bpl hud_clear
        lda stage
        clc
        adc #17
        sta status+hud_stage-hud_template
        lda wave
        cmp #3
        bcc hud_wave
        lda #2
hud_wave
        clc
        adc #17
        sta status+hud_wave_number-hud_template
        lda health
        jsr decimal
        stx status+hud_health-hud_template
        sta status+hud_health-hud_template+1
        lda lives
        clc
        adc #16
        sta status+hud_lives-hud_template
        lda seconds
        jsr decimal
        stx status+hud_time-hud_template
        sta status+hud_time-hud_template+1
        lda points
        jsr decimal
        stx status+hud_points-hud_template
        sta status+hud_points-hud_template+1
        ldx mode
        lda help_lo,x
        sta src
        lda help_hi,x
        sta src+1
        ldy #39
hud_help
        lda (src),y
        sta status+40,y
        dey
        bpl hud_help
        rts
decimal
        ldx #16
decimal_tens
        cmp #10
        bcc decimal_done
        sec
        sbc #10
        inx
        bne decimal_tens
decimal_done
        clc
        adc #16
        rts

back dta 1
entity dta 0
draw_x dta a(0)
draw_y dta 0
rect_w dta a(0)
rect_h dta 0
letter dta 0
depth_order :4 dta 0
actor_x :4 dta 0
actor_y :4 dta 0
actor_depth :4 dta 0
actor_tile :4 dta 0
pose_base dta 0
sort_index dta 0
sort_limit dta 0
jump_height dta 0,2,5,8,11,14,17,19,21,23,24,25,25,24,23,21,19,17,14,11,8,5,2
player_attack_pose dta 2,3,3,2
row_lo :200 dta <(#*320)
row_hi :200 dta >(#*320)
sprite_lo :32 dta <($62000+#*3584)
sprite_hi :32 dta >($62000+#*3584)
sprite_bank :32 dta ^($62000+#*3584)
        icl 'generated/font.asm'
background_bcb
        dta $00,$00,$03,a(1024),1
        dta $00,$00,$00,a(320),1
        dta a(319),199,$ff,0,0,0,0,0
command :21 dta 0
xdls
        dta $74,$08,7,0,0,0,a(320),$11,$ff
        dta $62,$88,199,0,0,0,a(320),$11,$ff
        dta $74,$08,7,0,0,1,a(320),$11,$ff
        dta $62,$88,199,0,0,1,a(320),$11,$ff
palette ins 'generated/palette.bin'
title_text dta c'DOUBLE DRAGON',0
go_text dta c'GO RIGHT >',0
controls_text dta c'FIRE: PUNCH  UP+FIRE: JUMP',0
kick_text dta c'LEFT/RIGHT+FIRE: KICK',0
start_text dta c'FIRE TO START - ATARI VBXE',0
pause_text dta c'PAUSED - P/SELECT RESUME',0
over_text dta c'GAME OVER - FIRE TO RETRY',0
win_text dta c'YOU WIN! FIRE TO PLAY AGAIN',0
stage1 dta c'THE STREETS',0
stage2 dta c'INDUSTRIAL AREA',0
stage3 dta c'THE CAVES',0
stage4 dta c'THE HIDEOUT',0
stage_lo dta <stage1,<stage2,<stage3,<stage4
stage_hi dta >stage1,>stage2,>stage3,>stage4
panel_lo dta <start_text,<start_text,<pause_text,<over_text,<win_text
panel_hi dta >start_text,>start_text,>pause_text,>over_text,>win_text
help_lo dta <help_title,<help_play,<help_pause,<help_over,<help_win
help_hi dta >help_title,>help_play,>help_pause,>help_over,>help_win
hud_template dta d'STAGE '
hud_stage dta d'1'
        dta d' W '
hud_wave_number dta d'1'
        dta d' HP '
hud_health dta d'12'
        dta d' L '
hud_lives dta d'3'
        dta d' T '
hud_time dta d'90'
        dta d' PTS '
hud_points dta d'0000'
        :40-(*-hud_template) dta 0
        ert *-hud_template <> 40
help_title dta d'FIRE/SPACE START - JOYSTICK OR WASD'
        :40-(*-help_title) dta 0
help_play dta d'FIRE PUNCH  DIR+FIRE KICK  UP+FIRE JUMP'
        :40-(*-help_play) dta 0
help_pause dta d'P/SELECT RESUME  R/START RESTART'
        :40-(*-help_pause) dta 0
help_over dta d'GAME OVER - FIRE/SPACE TO TRY AGAIN'
        :40-(*-help_over) dta 0
help_win dta d'CAMPAIGN CLEAR! FIRE/SPACE PLAY AGAIN'
        :40-(*-help_win) dta 0
missing dta d'VBXE FX 1.2X REQUIRED AT D600 OR D700'
        :40-(*-missing) dta 0
        .align $100,$00
display_list
        :26 dta $70
        dta $42,a(status),$02,$41,a(display_list)
status :80 dta 0
