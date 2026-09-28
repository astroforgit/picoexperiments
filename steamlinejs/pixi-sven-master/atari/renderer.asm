; One opaque background copy, depth-sorted actors, then mood/progress icons.
; All sprites share dimensions and a bottom-center anchor.
render
        ldx #20
bg_command
        lda background_bcb,x
        sta command,x
        dex
        bpl bg_command
        lda back
        sta command+8
        lda mode
        cmp #MODE_READY
        bne render_meadow
        lda #6
        sta command+2
        jsr blit
        jmp present
render_meadow
        jsr blit
        jsr build_actors
        lda #0
        sta entity
entity_loop
        ldy entity
        ldx depth_order,y
        lda actor_tile,x
        cmp #255
        beq next_entity
        lda actor_x,x
        sta draw_x
        lda actor_y,x
        sta draw_y
        lda actor_tile,x
        jsr sprite
next_entity
        inc entity
        lda entity
        cmp #14
        bne entity_loop
        lda shock_ticks
        beq no_shock_overlay
        lda world_tick
        and #2
        beq no_shock_overlay
        lda px
        sta draw_x
        lda py
        sta draw_y
        lda #105
        jsr sprite
no_shock_overlay
        ; Mood/progress symbols stay readable above the depth-sorted scene.
        lda #0
        sta entity
ui_loop
        ldx entity
        lda alive,x
        cmp #1
        bne ui_next
        lda sheep_x,x
        sta draw_x
        lda sheep_y,x
        sec
        sbc #6
        sta draw_y
        lda sheep_reaction,x
        beq normal_mood
        lda #89
        bne mood_icon
normal_mood
        lda sheep_age,x
        cmp #20
        bcc sunny_icon
        cmp #35
        bcc cloudy_icon
        cmp #50
        bcc rain_icon
        lda #100
        bne mood_icon
rain_icon
        lda #64
        bne mood_icon
cloudy_icon
        lda #59
        bne mood_icon
sunny_icon
        lda #54
mood_icon
        clc
        adc progress,x
        jsr sprite
ui_next
        inc entity
        lda entity
        cmp #8
        bne ui_loop

present
        jsr wait_blit
        lda $14
wait_frame
        cmp $14
        beq wait_frame
        jsr select_screen_palette
        ldy #$41
        lda back
        beq show_a
        lda #20
show_a  sta (reg),y
        lda back
        eor #1
        sta back
        ldx #39
        lda mode
        cmp #MODE_READY
        bne game_status
title_status
        lda title_help,x
        sta status,x
        dex
        bpl title_status
        rts
game_status
        lda game_help,x
        sta status,x
        dex
        bpl game_status
        lda score
        clc
        adc #16
        sta hud_sheep
        lda lives
        clc
        adc #16
        sta hud_lives
        lda seconds
        jsr decimal_two
        sta hud_time+1
        stx hud_time
        lda points
        ldx #16
hundreds_loop
        cmp #100
        bcc hundreds_done
        sec
        sbc #100
        inx
        bne hundreds_loop
hundreds_done
        stx hud_points
        jsr decimal_two
        sta hud_points+2
        stx hud_points+1
        rts

; Change palettes only on title/game transitions, at presentation time.
select_screen_palette
        lda #0
        ldx mode
        cpx #MODE_READY
        bne screen_palette_mode
        lda #1
screen_palette_mode
        cmp active_palette
        beq screen_palette_done
        sta active_palette
        cmp #0
        bne screen_title_palette
        mwa #palette src
        jmp screen_palette_load
screen_title_palette
        mwa #title_palette src
screen_palette_load
        ldy #$45
        lda #1
        sta (reg),y
        dey
        lda #0
        sta (reg),y
        ldx #0
screen_palette_color
        ldy #0
        lda (src),y
        ldy #$46
        sta (reg),y
        ldy #1
        lda (src),y
        ldy #$47
        sta (reg),y
        ldy #2
        lda (src),y
        ldy #$48
        sta (reg),y
        clc
        lda src
        adc #3
        sta src
        bcc screen_palette_next
        inc src+1
screen_palette_next
        inx
        bne screen_palette_color
screen_palette_done
        rts
active_palette dta 255

decimal_two
        ldx #16
subtract_tens
        cmp #10
        bcc digits
        sec
        sbc #10
        inx
        bne subtract_tens
digits
        clc
        adc #16
        rts

build_actors
        lda world_tick
        lsr
        lsr
        lsr
        tax
        lda love_cycle,x
        sta love_pose
        ldx #7
actor_sheep
        lda sheep_x,x
        sta actor_x,x
        lda sheep_y,x
        sta actor_y,x
        lda alive,x
        beq absent_sheep
        cmp #2
        beq absent_sheep
        cpx previous_target
        bne idle_sheep
        ldy sheep_direction,x
        lda love_base,y
        clc
        adc love_pose
        bne save_sheep_tile
idle_sheep
        lda sheep_age,x
        cmp #50
        bcc white_sheep
        cmp #52
        bcs red_sheep
        lda world_tick
        and #4
        beq white_sheep
red_sheep
        lda sheep_direction,x
        clc
        adc #94
        bne save_sheep_tile
white_sheep
        lda sheep_direction,x
        clc
        adc #20
        bne save_sheep_tile
love_sheep
        ldy vanish,x
        lda love_frames,y
        sta love_offset
        ldy sheep_direction,x
        lda love_base,y
        clc
        adc love_offset
        bne save_sheep_tile
absent_sheep
        lda #255
save_sheep_tile
        sta actor_tile,x
        dex
        bpl actor_sheep
        lda px
        sta actor_x+8
        lda py
        sta actor_y+8
        lda previous_target
        cmp #255
        bne hidden_player
        lda invulnerable
        beq visible_player
        lda world_tick
        and #4
        beq visible_player
hidden_player
        lda #255
        bne save_player_tile
visible_player
        lda moving
        beq idle_player
        lda phase
        lsr
        lsr
        lsr
        and #3
        ora direction
        jmp save_player_tile
idle_player
        lda direction
        lsr
        lsr
        clc
        adc #16
save_player_tile
        sta actor_tile+8
        ldx #1
actor_enemy
        lda enemy_x,x
        sta actor_x+9,x
        lda enemy_y,x
        sta actor_y+9,x
        cpx #0
        bne enemy_animating
        lda dog_alert
        bne enemy_animating
        lda dog_clock
        cmp #100
        bcc enemy_animating
        lda #0
        beq enemy_pose
enemy_animating
        lda world_tick
        lsr
        lsr
        lsr
        and #1
enemy_pose
        asl
        asl
        clc
        adc enemy_direction,x
        adc enemy_base,x
        sta actor_tile+9,x
        dex
        bpl actor_enemy
        lda battle_x
        sta actor_x+11
        lda battle_y
        sta actor_y+11
        lda #255
        ldy battle_ticks
        beq save_battle
        lda battle_frames,y
save_battle
        sta actor_tile+11
        ldx #1
mushroom_actors
        lda mushroom_x,x
        sta actor_x+12,x
        lda mushroom_y,x
        sta actor_y+12,x
        lda mushroom_alive,x
        beq absent_mushroom
        txa
        clc
        adc #98
        bne save_mushroom_tile
absent_mushroom
        lda #255
save_mushroom_tile
        sta actor_tile+12,x
        dex
        bpl mushroom_actors
        ; Mushrooms share the same depth sort as actors and battle cloud.
        ldx #13
order_init
        txa
        sta depth_order,x
        dex
        bpl order_init
        lda #13
        sta sort_limit
sort_pass
        lda #0
        sta sort_index
sort_pair
        ldx sort_index
        lda depth_order,x
        ldy depth_order+1,x
        tax
        lda actor_y,x
        cmp actor_y,y
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
        lda #SPRITE_W
        sta command+3
        lda #0
        sta command+4
        sta command+13
        lda #SPRITE_W-1
        sta command+12
        lda #SPRITE_H-1
        sta command+14
        lda #1
        sta command+20
        ; Constant-time Y*320+X, replacing up to 148 repeated additions.
        ldx draw_y
        clc
        lda row_lo,x
        adc draw_x
        sta command+6
        lda row_hi,x
        adc #0
        sta command+7
blit
        jsr wait_blit
        jsr map_control
        ldx #20
copy_command
        lda command,x
        sta $9100,x
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
        ldy #$5f
        lda #$ff
        sta (reg),y
        rts

back dta 1
entity dta 0
draw_x dta 0
draw_y dta 0
depth_order :14 dta 0
actor_x :14 dta 0
actor_y :14 dta 0
actor_tile :14 dta 0
enemy_base dta 38,46
sort_index dta 0
sort_limit dta 0
love_pose dta 0
love_cycle :32 dta (#%5)
love_frames :42 dta [#/4]%5
love_base dta 69,74,79,84
love_offset dta 0
battle_frames dta 255
        :42 dta 24+((41-#)/3)
row_lo :200 dta <(#*320)
row_hi :200 dta >(#*320)
sprite_lo :SPRITE_COUNT dta <($2fa00+#*SPRITE_SIZE)
sprite_hi :SPRITE_COUNT dta >($2fa00+#*SPRITE_SIZE)
sprite_bank :SPRITE_COUNT dta ^($2fa00+#*SPRITE_SIZE)
background_bcb
        dta $00,$00,$02,a(320),1
        dta $00,$00,$00,a(320),1
        dta a(319),199,$ff,0,0,0,0,0
command :21 dta 0
xdls
        dta $74,$08,7,0,0,0,a(320),$11,$ff
        dta $62,$88,199,0,0,0,a(320),$11,$ff
        dta $74,$08,7,0,0,1,a(320),$11,$ff
        dta $62,$88,199,0,0,1,a(320),$11,$ff
palette ins 'generated/palette.bin'
title_palette ins 'generated/title-palette.bin'
title_help dta d'JOYSTICK/WASD MOVE  SPACE/FIRE START    '
        ert *-title_help <> 40
game_help dta d'SHEEP 0/8 TIME 90 LIVES 3 PTS 000       '
        ert *-game_help <> 40
; ANTIC underlay blank during the meadow; two 40-column rows beneath it.
; ANTIC wraps its display-list fetch within a 1 KB page.
        .align $100,$00
display_list
        :26 dta $70
        dta $42,a(status),$02,$41,a(display_list)
status
        dta d'SHEEP '
hud_sheep dta d'0'
        dta d'/8 TIME '
hud_time dta d'90'
        dta d' LIVES '
hud_lives dta d'3'
        dta d' PTS '
hud_points dta d'000'
        :40-(*-status) dta 0
        dta d'                                        '
        ert *-status <> 80
messages_lo dta <ready,<playing,<won,<timeout,<paused
messages_hi dta >ready,>playing,>won,>timeout,>paused
ready dta d'      ATARI CONVERSION BY ASTROFOR'
        :40-(*-ready) dta 0
        ert *-ready <> 40
playing dta d'HOLD FIRE LOVE / DOUBLE FIRE WHISTLE / P'
won dta d'FLOCK HAPPY! FIRE TO PLAY AGAIN         '
timeout dta d'TIME UP! FIRE TO TRY AGAIN              '
paused dta d'PAUSED - P/SELECT RESUME - R RESTART    '
missing dta d'VBXE FX REQUIRED AT D600 OR D700        '
caught dta d'NO LIVES LEFT! FIRE TO TRY AGAIN        '
