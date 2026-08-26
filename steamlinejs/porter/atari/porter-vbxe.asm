; ============================================================================
; PORTER PATCH - new Atari 8-bit / VBXE port
; Based directly on porterpatch1-1.p8 by Blu Makes Games.
; MADS source.  Requires VBXE core 1.2x.
; ============================================================================

        icl '../atariold/atari.hea'

; --- display / VBXE layout --------------------------------------------------
SCR_W           = 320
SCR_H           = 200
VIEW_X          = 64
VIEW_Y          = 4
VIEW_SIZE       = 192
TILE_DRAW       = 12

SHAPES_V        = $00000
SCREEN_A_V      = $10000
ROOM_CACHE_V    = $20000
SCREEN_B_V      = $30000
XDL_A_V         = $7f000
XDL_B_V         = $7f020
BCB_V           = $7f100
MEMW            = $4000              ; MEMAC-B 16K CPU window

JOY_UP          = $01
JOY_DOWN        = $02
JOY_LEFT        = $04
JOY_RIGHT       = $08
JOY_FIRE        = $10

KEY_PREV_LEVEL  = $1f               ; Atari KBCODE for 1
KEY_NEXT_LEVEL  = $1e               ; Atari KBCODE for 2

FLAG_SOLID      = $01
FLAG_HAZARD     = $04
FLAG_BLOCK      = $08

; The original cartridge uses dark sprites for an inactive field and bright
; sprites for an active (solid/lethal) field.  Red is the initial phase.
FIELD_BLUE_OFF  = 71
FIELD_BLUE_ON   = 72
FIELD_RED_OFF   = 87
FIELD_RED_ON    = 88

SWITCH_RED      = 0
SWITCH_BLUE     = 1

MODE_TITLE      = 0
MODE_PLAY       = 1
MODE_END        = 2

; --- zero page --------------------------------------------------------------
        opt h-
        org $80
fx_ptr          org *+2
src_ptr         org *+2
dst_ptr         org *+2
map_ptr         org *+2
tmp_ptr         org *+2
col_x           org *+2
col_y           org *+2
old_x           org *+2
old_y           org *+2
actor_x         org *+2
actor_y         org *+2
tmp0            org *+1
tmp1            org *+1
tmp2            org *+1
tmp3            org *+1
tmp4            org *+1
row_no          org *+1
col_no          org *+1
sprite_id       org *+1
sprite_flip     org *+1
dest_bank       org *+1
dest_pitch      org *+2
room_dirty      org *+1
blit_wait_lo    org *+1
blit_wait_hi    org *+1
joy_state       org *+1
joy_prev        org *+1
joy_pressed     org *+1
space_pending   org *+1
space_pressed   org *+1
level_prev_pending org *+1
level_next_pending org *+1
frame           org *+1
vblank          org *+1
game_mode       org *+1
front_bank      org *+1
back_bank       org *+1

p_x             org *+2
p_y             org *+2
p_start_x       org *+2
p_start_y       org *+2
p_dx            org *+1
p_dy            org *+1
p_face          org *+1
p_ground        org *+1
p_can_tele      org *+1
p_coyote        org *+1
p_jumpbuf       org *+1
p_sprite        org *+1

cam_x           org *+1
cam_y           org *+1
cam_old_x       org *+1
cam_old_y       org *+1
deaths          org *+2
teleports       org *+2
level_no        org *+1
green_state     org *+1
switch_x        org *+1
switch_y        org *+1
switch_down     org *+1
switch_state    org *+1
room_clock      org *+1
crumble_x       org *+1
crumble_y       org *+1
crumble_time    org *+1
sound_time      org *+1
sound_enabled   org *+1
option_latch    org *+1
        opt h+

; --- ordinary RAM -----------------------------------------------------------
        org $0800
coin_alive      :28 dta 1
rock_y_lo       :5 dta 0
rock_y_hi       :5 dta 0
rock_dy         :5 dta 0
feather_y_lo    :16 dta 0
feather_y_hi    :16 dta 0

        org $1000
carrier_dlist
        :28 dta $70                 ; 224 stable blank scanlines
        dta $41,a(carrier_dlist)
carrier_screen
        :26*40 dta 0

        org $1500
sprite_bounce
        :256 dta 0

; --- code -------------------------------------------------------------------
        org $2000

nmi
        bit nmist
        bpl @nmi_vbi
        jmp (dliv)
@nmi_vbi
        pha
        txa
        pha
        tya
        pha
        inc vblank
        pla
        tay
        pla
        tax
        pla
        rti

dli_dummy
        rti

; POKEY raises this IRQ for every newly detected key depression. Capture SPACE
; as an event instead of trying to infer presses from periodically sampled
; key levels.
irq_keyboard
        pha
        lda irqst
        and #$40
        bne @irq_keyboard_done
        lda kbcode
        and #$3f
        cmp #key_space
        beq @irq_keyboard_space
        cmp #KEY_PREV_LEVEL
        beq @irq_keyboard_prev_level
        cmp #KEY_NEXT_LEVEL
        beq @irq_keyboard_next_level
        bne @irq_keyboard_ack
@irq_keyboard_space
        lda #1
        sta space_pending
        bne @irq_keyboard_ack
@irq_keyboard_prev_level
        lda #1
        sta level_prev_pending
        bne @irq_keyboard_ack
@irq_keyboard_next_level
        lda #1
        sta level_next_pending
@irq_keyboard_ack
        lda #0                      ; clear the latched keyboard IRQ
        sta irqen
        lda #$40                    ; and arm the next key depression
        sta irqen
@irq_keyboard_done
        pla
        rti

start
        sei
        lda #0
        sta nmien
        sta irqen
        sta irqens
        sta dmactl
        sta 559
        sta colbak
        sta colbaks
        lda #3
        sta skctl
        ; Expose RAM under the ROMs for vectors. All game assets are deliberately
        ; linked below $A000, so XEX loading never depends on BASIC shadow RAM.
        lda #$fc
        sta portb
        mwa #dli_dummy dliv
        mwa #nmi nmivec
        mwa #irq_keyboard irqvec
        lda #$40
        sta irqens
        sta irqen
        lda #64
        sta nmien
        cli

        jsr vbxe_init
        lda #SCREEN_A_V>>16
        sta front_bank
        lda #SCREEN_B_V>>16
        sta back_bank
        mwa #carrier_dlist dlptr
        lda #scr40
        sta dmactl
        sta 559
        lda #1
        sta sound_enabled
        lda #0
        sta option_latch
        jsr init_game
        lda #MODE_TITLE
        sta game_mode
        jsr draw_title

main_loop
        jsr wait_vbl
main_loop_after_wait
        jsr read_joystick
        jsr read_keyboard
        jsr update_sound_toggle
        jsr sound_update
        jsr update_debug_level
        lda game_mode
        cmp #MODE_TITLE
        beq title_loop
        cmp #MODE_END
        beq end_loop

        jsr update_animations
        jsr update_actors
        jsr update_player
        lda game_mode
        cmp #MODE_END
        beq main_loop
        jsr draw_game
        inc frame
        ; draw_game presents at VBL, so begin constructing the next frame
        ; immediately instead of waiting through a second vertical blank.
        jmp main_loop_after_wait

title_loop
        inc frame
        lda joy_pressed
        and #JOY_FIRE
        bne @title_loop_start
        lda joy_state
        and #(JOY_UP|JOY_DOWN|JOY_LEFT|JOY_RIGHT)
        bne @title_loop_start
        lda frame
        cmp #100                    ; original intro also enters play automatically
        bcc main_loop
@title_loop_start
        jsr clear_back_buffer
        lda #1
        sta room_dirty
        lda #MODE_PLAY
        sta game_mode
        jsr sfx_teleport
        jmp main_loop

end_loop
        lda joy_pressed
        and #JOY_FIRE
        beq main_loop
        jsr init_game
        jsr clear_back_buffer
        lda #MODE_PLAY
        sta game_mode
        jmp main_loop

wait_vbl
        lda vblank
@wait_vbl_wait
        cmp vblank
        beq @wait_vbl_wait
        rts

; ============================================================================
; Input, game initialization and state
; ============================================================================

read_joystick
        lda joy_state
        sta joy_prev
        lda #0
        sta joy_state
        lda porta
        and #$0f
        sta tmp0
        lsr
        bcs @read_joystick_down
        lda joy_state
        ora #JOY_UP
        sta joy_state
@read_joystick_down
        lda tmp0
        and #2
        bne @read_joystick_left
        lda joy_state
        ora #JOY_DOWN
        sta joy_state
@read_joystick_left
        lda tmp0
        and #4
        bne @read_joystick_right
        lda joy_state
        ora #JOY_LEFT
        sta joy_state
@read_joystick_right
        lda tmp0
        and #8
        bne @read_joystick_fire
        lda joy_state
        ora #JOY_RIGHT
        sta joy_state
@read_joystick_fire
        lda trig0
        bne @read_joystick_pressed
        lda joy_state
        ora #JOY_FIRE
        sta joy_state
@read_joystick_pressed
        lda joy_prev
        eor #$ff
        and joy_state
        sta joy_pressed
        rts

; Transfer the keyboard IRQ latch into this gameplay frame.
read_keyboard
        lda #0
        sta space_pressed
        lda space_pending
        bne @read_keyboard_done
        rts
@read_keyboard_done
        lda #0
        sta space_pending
        lda #1
        sta space_pressed
        rts

; OPTION toggles all game sound. Console keys are active-low.
update_sound_toggle
        lda consol
        and #4
        bne @update_sound_toggle_released
        lda option_latch
        bne @update_sound_toggle_done
        lda #1
        sta option_latch
        lda sound_enabled
        eor #1
        sta sound_enabled
        bne @update_sound_toggle_done
        lda #0
        sta sound_time
        sta audc1
@update_sound_toggle_done
        rts
@update_sound_toggle_released
        lda #0
        sta option_latch
        rts

init_game
        lda #1
        ldx #27
@init_game_coins
        sta coin_alive,x
        dex
        bpl @init_game_coins
        lda #0
        sta deaths
        sta deaths+1
        sta teleports
        sta teleports+1
        sta frame
        sta switch_down
        sta switch_state
        sta room_clock
        sta space_pending
        sta space_pressed
        sta level_prev_pending
        sta level_next_pending
        sta crumble_time
        lda #1
        sta room_dirty
        sta green_state
        lda #1
        sta level_no
        lda #28
        sta p_start_x
        lda #0
        sta p_start_x+1
        lda #52
        sta p_start_y
        lda #0
        sta p_start_y+1
        jsr respawn_player
        jsr init_actors
        jsr update_camera
        rts

; Debug level navigation. Keys are IRQ-latched, so holding a number does not
; race through several levels. Level 1 has its special intro spawn offset;
; levels 2..29 start at the preceding checkpoint's destination.
update_debug_level
        lda level_prev_pending
        beq @update_debug_level_next
        lda #0
        sta level_prev_pending
        sta level_next_pending
        lda level_no
        cmp #1
        beq @update_debug_level_done
        dec level_no
        jmp debug_load_level
@update_debug_level_next
        lda level_next_pending
        beq @update_debug_level_done
        lda #0
        sta level_prev_pending
        sta level_next_pending
        lda level_no
        cmp #29
        bcs @update_debug_level_done
        inc level_no
        jmp debug_load_level
@update_debug_level_done
        rts

debug_load_level
        lda level_no
        cmp #1
        bne @debug_load_level_checkpoint
        lda #28                      ; level 1: 4*8-4
        sta p_start_x
        lda #0
        sta p_start_x+1
        lda #52                      ; level 1: 8*8-12
        sta p_start_y
        lda #0
        sta p_start_y+1
        jmp @debug_load_level_ready
@debug_load_level_checkpoint
        sec
        sbc #2
        tax
        lda coin_next_x,x
        jsr tile_to_pixel
        lda tmp0
        sta p_start_x
        lda tmp1
        sta p_start_x+1
        lda coin_next_y,x
        jsr tile_to_pixel
        sec
        lda tmp0
        sbc #8
        sta p_start_y
        lda tmp1
        sbc #0
        sta p_start_y+1
@debug_load_level_ready
        ; Restore this level's checkpoint coin if it was collected earlier.
        lda level_no
        cmp #29
        bcs @debug_load_level_no_coin
        tax
        dex
        lda #1
        sta coin_alive,x
@debug_load_level_no_coin
        lda #MODE_PLAY
        sta game_mode
        jsr clear_back_buffer
        jsr respawn_player
        lda #10
        jsr start_sound
        rts

respawn_player
        mwa p_start_x p_x
        mwa p_start_y p_y
        lda #0
        sta p_dx
        sta p_dy
        sta p_face
        sta p_ground
        sta p_can_tele
        sta p_jumpbuf
        sta switch_down
        sta crumble_time
        lda #1
        sta green_state
        sta room_dirty
        lda #8                      ; no jump before the initial landing
        sta p_coyote
        jsr reset_room_objects
        jsr reset_actors
        rts

init_actors
reset_actors
        ldx #ROCKS_COUNT-1
@reset_actors_rocks
        lda rocks_start_y,x
        jsr tile_to_pixel
        lda tmp0
        sta rock_y_lo,x
        lda tmp1
        sta rock_y_hi,x
        lda #0
        sta rock_dy,x
        dex
        bpl @reset_actors_rocks
        ldx #FEATHERS_COUNT-1
@reset_actors_feathers
        lda feathers_start_y,x
        jsr tile_to_pixel
        lda tmp0
        sta feather_y_lo,x
        lda tmp1
        sta feather_y_hi,x
        dex
        bpl @reset_actors_feathers
        rts

; A=tile coordinate -> tmp1:tmp0 pixel coordinate
tile_to_pixel
        sta tmp2
        asl
        asl
        asl
        sta tmp0
        lda tmp2
        lsr
        lsr
        lsr
        lsr
        lsr
        sta tmp1
        rts

; ============================================================================
; Player physics and teleport
; ============================================================================

update_player
        lda space_pressed
        beq @update_player_move
        jsr try_teleport
@update_player_move
        lda p_ground
        bne @update_player_input
        lda p_coyote
        cmp #8
        bcs @update_player_input
        inc p_coyote
@update_player_input
        lda joy_state
        and #JOY_LEFT
        beq @update_player_right
        lda #1
        sta p_face
        ; Match the original game's sub-pixel acceleration closely enough for
        ; precise field-edge positioning: a fresh tap moves one pixel, while a
        ; held direction reaches the port's normal two-pixel running speed.
        lda joy_pressed
        and #JOY_LEFT
        beq @update_player_left_held
        lda #$ff
        bne @update_player_store_dx
@update_player_left_held
        lda #$fe
        bne @update_player_store_dx
@update_player_store_dx
        sta p_dx
        jmp @update_player_jump
@update_player_right
        lda joy_state
        and #JOY_RIGHT
        beq @update_player_friction
        lda #0
        sta p_face
        lda joy_pressed
        and #JOY_RIGHT
        beq @update_player_right_held
        lda #1
        bne @update_player_store_right_dx
@update_player_right_held
        lda #2
@update_player_store_right_dx
        sta p_dx
        jmp @update_player_jump
@update_player_friction
        lda #0
        sta p_dx

@update_player_jump
        lda joy_pressed
        and #JOY_FIRE
        beq @update_player_buffer_tick
        lda p_ground
        bne @update_player_do_jump
        lda p_coyote
        cmp #4
        bcc @update_player_do_jump
        lda #6
        sta p_jumpbuf
        jmp @update_player_buffer_tick
@update_player_do_jump
        lda #$fc
        sta p_dy
        lda #0
        sta p_ground
        lda #8
        sta p_coyote               ; consuming a jump forbids another air jump
        lda #8
        jsr start_sound

@update_player_buffer_tick
        lda p_jumpbuf
        beq @update_player_gravity
        dec p_jumpbuf

@update_player_gravity
        lda frame
        and #1
        bne @update_player_horizontal
        lda p_dy
        bmi @update_player_grav_add
        cmp #3
        bcs @update_player_horizontal
@update_player_grav_add
        inc p_dy

@update_player_horizontal
        lda p_dx
        beq @update_player_vertical
        bmi @update_player_left_steps
        sta tmp3
@update_player_right_steps
        jsr try_step_right
        bcs @update_player_stop_h
        dec tmp3
        bne @update_player_right_steps
        jmp @update_player_vertical
@update_player_left_steps
        eor #$ff
        clc
        adc #1
        sta tmp3
@update_player_left_loop
        jsr try_step_left
        bcs @update_player_stop_h
        dec tmp3
        bne @update_player_left_loop
        jmp @update_player_vertical
@update_player_stop_h
        lda #0
        sta p_dx

@update_player_vertical
        lda p_dy
        beq @update_player_ground_check
        bmi @update_player_up_steps
        sta tmp3
        lda #0
        sta p_ground
@update_player_down_loop
        jsr try_step_down
        bcs @update_player_land
        dec tmp3
        bne @update_player_down_loop
        jmp @update_player_after_move
@update_player_land
        lda #0
        sta p_dy
        lda #1
        sta p_ground
        sta p_can_tele
        lda p_jumpbuf
        beq @update_player_land_sound
        lda #0
        sta p_jumpbuf
        lda #$fc
        sta p_dy
        jmp @update_player_after_move
@update_player_land_sound
        lda #3
        jsr start_sound
        jmp @update_player_after_move

@update_player_up_steps
        eor #$ff
        clc
        adc #1
        sta tmp3
@update_player_up_loop
        jsr try_step_up
        bcs @update_player_ceiling
        dec tmp3
        bne @update_player_up_loop
        jmp @update_player_after_move
@update_player_ceiling
        lda #0
        sta p_dy
        jmp @update_player_after_move

@update_player_ground_check
        jsr player_ground_test
        bcc @update_player_air
        lda #1
        sta p_ground
        sta p_can_tele
        lda #0
        sta p_coyote
        jmp @update_player_after_move
@update_player_air
        lda #0
        sta p_ground
        jmp @update_player_after_move

@update_player_after_move
        jsr interact_tiles
        jsr actor_player_collision
        jsr player_dead_test
        bcc @update_player_sprite
        inc deaths
        bne @update_player_respawn
        inc deaths+1
@update_player_respawn
        lda #12
        jsr start_sound
        jsr respawn_player

@update_player_sprite
        lda p_dy
        bmi @update_player_jump_sprite
        beq @update_player_ground_sprite
        lda #8
        bne @update_player_store_sprite
@update_player_jump_sprite
        lda #7
        bne @update_player_store_sprite
@update_player_ground_sprite
        lda p_dx
        beq @update_player_idle_sprite
        lda frame
        lsr
        lsr
        and #3
        clc
        adc #3
        bne @update_player_store_sprite
@update_player_idle_sprite
        lda #1
@update_player_store_sprite
        sta p_sprite
        rts

try_step_right
        mwa p_x col_x
        clc
        lda col_x
        adc #8
        sta col_x
        bcc @+
        inc col_x+1
@
        jsr side_points_solid
        bcs @try_step_right_blocked
        inc p_x
        bne @try_step_right_ok
        inc p_x+1
@try_step_right_ok
        clc
        rts
@try_step_right_blocked
        sec
        rts

try_step_left
        mwa p_x col_x
        lda col_x
        bne @+
        dec col_x+1
@
        dec col_x
        jsr side_points_solid
        bcs @try_step_left_blocked
        lda p_x
        bne @+
        dec p_x+1
@
        dec p_x
        clc
        rts
@try_step_left_blocked
        sec
        rts

side_points_solid
        mwa p_y col_y
        clc
        lda col_y
        adc #3
        sta col_y
        bcc @+
        inc col_y+1
@
        jsr point_solid
        bcs @side_points_solid_hit
        clc
        lda col_y
        adc #4
        sta col_y
        bcc @+
        inc col_y+1
@
        jsr point_solid
@side_points_solid_hit
        rts

try_step_down
        mwa p_y col_y
        clc
        lda col_y
        adc #8
        sta col_y
        bcc @+
        inc col_y+1
@
        mwa p_x col_x
        clc
        lda col_x
        adc #2
        sta col_x
        bcc @+
        inc col_x+1
@
        jsr point_solid
        bcs @try_step_down_blocked
        clc
        lda col_x
        adc #4
        sta col_x
        bcc @+
        inc col_x+1
@
        jsr point_solid
        bcs @try_step_down_blocked
        inc p_y
        bne @try_step_down_ok
        inc p_y+1
@try_step_down_ok
        clc
        rts
@try_step_down_blocked
        sec
        rts

try_step_up
        mwa p_y col_y
        lda col_y
        bne @+
        dec col_y+1
@
        dec col_y
        mwa p_x col_x
        clc
        lda col_x
        adc #2
        sta col_x
        bcc @+
        inc col_x+1
@
        jsr point_solid
        bcs @try_step_up_blocked
        clc
        lda col_x
        adc #4
        sta col_x
        bcc @+
        inc col_x+1
@
        jsr point_solid
        bcs @try_step_up_blocked
        lda p_y
        bne @+
        dec p_y+1
@
        dec p_y
        clc
        rts
@try_step_up_blocked
        sec
        rts

player_ground_test
        mwa p_y col_y
        clc
        lda col_y
        adc #8
        sta col_y
        bcc @+
        inc col_y+1
@
        mwa p_x col_x
        clc
        lda col_x
        adc #2
        sta col_x
        bcc @+
        inc col_x+1
@
        jsr point_solid
        bcs @player_ground_test_hit
        clc
        lda col_x
        adc #4
        sta col_x
        bcc @+
        inc col_x+1
@
        jsr point_solid
@player_ground_test_hit
        rts

try_teleport
        lda joy_state
        and #JOY_UP
        beq @try_teleport_down
        sec
        lda p_y
        sbc #32
        sta p_y
        bcs @try_teleport_resolve
        dec p_y+1
        jmp @try_teleport_resolve
@try_teleport_down
        lda joy_state
        and #JOY_DOWN
        beq @try_teleport_left
        clc
        lda p_y
        adc #32
        sta p_y
        bcc @try_teleport_resolve
        inc p_y+1
        jmp @try_teleport_resolve
@try_teleport_left
        lda joy_state
        and #JOY_LEFT
        bne @try_teleport_tele_left
        lda joy_state
        and #JOY_RIGHT
        bne @try_teleport_tele_right
        lda p_face
        beq @try_teleport_tele_right
@try_teleport_tele_left
        sec
        lda p_x
        sbc #32
        sta p_x
        bcs @try_teleport_resolve
        dec p_x+1
        jmp @try_teleport_resolve
@try_teleport_tele_right
        clc
        lda p_x
        adc #32
        sta p_x
        bcc @try_teleport_resolve
        inc p_x+1

@try_teleport_resolve
        lda p_x+1
        cmp #4
        bcs @try_teleport_lethal
        lda p_y+1
        cmp #1
        bcc @try_teleport_collision
        bne @try_teleport_lethal
        lda p_y
        cmp #128
        bcs @try_teleport_lethal
@try_teleport_collision
        ; The cursor is an aim point, not a one-pixel precision test.  The
        ; original cartridge nudges a teleport target against nearby walls;
        ; additionally allow a one-tile horizontal/four-pixel vertical landing
        ; snap so narrow field platforms remain usable during a jump.
        jsr teleport_snap_to_support
        jsr player_inside_solid
        bcc @try_teleport_success
        ; Teleporting into a solid tile succeeds as a lethal teleport. Force
        ; the regular death/respawn path after recording the attempt.
@try_teleport_lethal
        lda #2
        sta p_y+1
@try_teleport_success
        inc teleports
        bne @try_teleport_sound
        inc teleports+1
@try_teleport_sound
        jsr sfx_teleport
@try_teleport_done
        rts

; Search around the nominal destination for a safe position with solid ground
; directly beneath Porter's feet.  Horizontal and vertical offsets alternate
; around zero so the closest match wins.  This fixes the one-tile field in the
; early red/blue room: an aim point at its edge now lands on it instead of
; requiring the cursor to be exactly centred.
teleport_snap_to_support
        mwa p_x old_x
        mwa p_y old_y
        lda #0
        sta row_no
@teleport_snap_y
        lda #0
        sta col_no
@teleport_snap_x
        mwa old_x p_x
        mwa old_y p_y
        ldx col_no
        lda teleport_snap_x_offsets,x
        jsr add_signed_to_player_x
        ldx row_no
        lda teleport_snap_y_offsets,x
        jsr add_signed_to_player_y
        jsr player_inside_solid
        bcs @teleport_snap_next
        jsr player_ground_test
        bcc @teleport_snap_next
        lda #0
        sta p_dy
        lda #1
        sta p_ground
        sta p_can_tele
        rts
@teleport_snap_next
        inc col_no
        lda col_no
        cmp #17
        bne @teleport_snap_x
        inc row_no
        lda row_no
        cmp #9
        bne @teleport_snap_y
        ; No nearby supported destination: retain the exact cursor position.
        ; The caller still accepts it in open air or rejects it inside a wall.
        mwa old_x p_x
        mwa old_y p_y
        rts

add_signed_to_player_x
        bmi @add_signed_to_player_x_negative
        clc
        adc p_x
        sta p_x
        bcc @add_signed_to_player_x_done
        inc p_x+1
@add_signed_to_player_x_done
        rts
@add_signed_to_player_x_negative
        clc
        adc p_x
        sta p_x
        bcs @add_signed_to_player_x_negative_done
        dec p_x+1
@add_signed_to_player_x_negative_done
        rts

add_signed_to_player_y
        bmi @add_signed_to_player_y_negative
        clc
        adc p_y
        sta p_y
        bcc @add_signed_to_player_y_done
        inc p_y+1
@add_signed_to_player_y_done
        rts
@add_signed_to_player_y_negative
        clc
        adc p_y
        sta p_y
        bcs @add_signed_to_player_y_negative_done
        dec p_y+1
@add_signed_to_player_y_negative_done
        rts

player_inside_solid
        mwa p_x col_x
        clc
        lda col_x
        adc #2
        sta col_x
        bcc @+
        inc col_x+1
@
        mwa p_y col_y
        clc
        lda col_y
        adc #2
        sta col_y
        bcc @+
        inc col_y+1
@
        jsr point_solid
        bcs @player_inside_solid_hit
        clc
        lda col_x
        adc #4
        sta col_x
        bcc @+
        inc col_x+1
@
        jsr point_solid
        bcs @player_inside_solid_hit
        clc
        lda col_y
        adc #5
        sta col_y
        bcc @+
        inc col_y+1
@
        jsr point_solid
        bcs @player_inside_solid_hit
        sec
        lda col_x
        sbc #4
        sta col_x
        bcs @+
        dec col_x+1
@
        jsr point_solid
@player_inside_solid_hit
        rts

player_dead_test
        lda p_x+1
        cmp #4
        bcs @player_dead_test_dead
        lda p_y+1
        cmp #1
        bcc @player_dead_test_camera
        bne @player_dead_test_dead
        lda p_y
        cmp #128
        bcs @player_dead_test_dead
@player_dead_test_camera
        ; The PICO-8 camera is locked to the current checkpoint screen. Crossing
        ; a 128-pixel screen edge without collecting the coin is offscreen death.
        lda p_x
        and #$80
        lsr
        lsr
        lsr
        sta tmp0
        lda p_x+1
        asl
        asl
        asl
        asl
        asl
        ora tmp0
        cmp cam_x
        bne @player_dead_test_dead
        lda p_y
        and #$80
        lsr
        lsr
        lsr
        sta tmp0
        lda p_y+1
        asl
        asl
        asl
        asl
        asl
        ora tmp0
        cmp cam_y
        bne @player_dead_test_dead
@player_dead_test_tile
        mwa p_x col_x
        clc
        lda col_x
        adc #4
        sta col_x
        bcc @+
        inc col_x+1
@
        mwa p_y col_y
        clc
        lda col_y
        adc #4
        sta col_y
        bcc @+
        inc col_y+1
@
        jsr sample_pixel
        tax
        lda tile_flags,x
        and #(FLAG_HAZARD|FLAG_BLOCK)
        bne @player_dead_test_dead
        clc
        rts
@player_dead_test_dead
        sec
        rts

; ============================================================================
; Map addressing and interactions
; ============================================================================

; sample tile at col_y:col_y+1 / col_x:col_x+1 pixel coordinate, return A
sample_pixel
        lda col_x+1
        cmp #4
        bcs @sample_pixel_outside
        lda col_y+1
        cmp #2
        bcs @sample_pixel_outside
        lda col_x
        lsr
        lsr
        lsr
        sta tmp0
        lda col_x+1
        asl
        asl
        asl
        asl
        asl
        ora tmp0
        sta tmp0                    ; tile x
        lda col_y
        lsr
        lsr
        lsr
        sta tmp1
        lda col_y+1
        asl
        asl
        asl
        asl
        asl
        ora tmp1
        sta tmp1                    ; tile y
        jmp map_at_tile
@sample_pixel_outside
        lda #0
        rts

; tmp0=tile x, tmp1=tile y. A=tile and map_ptr points at it.
map_at_tile
        lda tmp1
        lsr
        clc
        adc #>world_map
        sta map_ptr+1
        lda tmp1
        and #1
        beq @map_at_tile_top
        lda #128
        bne @map_at_tile_addx
@map_at_tile_top
        lda #0
@map_at_tile_addx
        clc
        adc tmp0
        sta map_ptr
        ldy #0
        lda (map_ptr),y
        rts

point_solid
        jsr sample_pixel
        cmp #89
        bcc @point_solid_flags
        cmp #92
        bcc @point_solid_yes
@point_solid_flags
        tax
        lda tile_flags,x
        and #FLAG_SOLID
        beq @point_solid_no
@point_solid_yes
        sec
        rts
@point_solid_no
        clc
        rts

interact_tiles
        jsr check_coin
        jsr check_key
        jsr check_switch
        jsr check_crumble
        jsr check_end
        rts

player_center_tile
        mwa p_x col_x
        clc
        lda col_x
        adc #4
        sta col_x
        bcc @+
        inc col_x+1
@
        mwa p_y col_y
        clc
        lda col_y
        adc #4
        sta col_y
        bcc @+
        inc col_y+1
@
        jsr sample_pixel
        rts

check_coin
        ; centre pixel -> tile coordinate in tmp0/tmp1 through sample_pixel
        jsr player_center_tile
        ldx #0
@check_coin_loop
        lda coin_alive,x
        beq @check_coin_next
        lda coin_tile_x,x
        cmp tmp0
        bne @check_coin_next
        lda coin_tile_y,x
        cmp tmp1
        bne @check_coin_next
        lda #0
        sta coin_alive,x
        lda coin_next_x,x
        jsr tile_to_pixel
        lda tmp0
        sta p_start_x
        lda tmp1
        sta p_start_x+1
        lda coin_next_y,x
        jsr tile_to_pixel
        sec
        lda tmp0
        sbc #8
        sta p_start_y
        lda tmp1
        sbc #0
        sta p_start_y+1
        inc level_no
        lda #10
        jsr start_sound
        jsr respawn_player
        rts
@check_coin_next
        inx
        cpx #COIN_COUNT
        bne @check_coin_loop
        rts

check_key
        jsr player_center_tile
        cmp #85
        bne @check_key_done
        lda #86
        ldy #0
        sta (map_ptr),y
        lda #1
        sta room_dirty
        lda #0
        sta green_state
        lda #9
        jsr start_sound
        jsr replace_green_room
@check_key_done
        rts

check_switch
        jsr find_switch_contact
        bcc @check_switch_release
        lda switch_down
        beq @check_switch_press
        ; The PICO-8 version stores an independent `up` latch on every button.
        ; If the player's feet move straight from one button tile to another,
        ; release the old tile and allow the new tile to toggle immediately.
        lda tmp0
        cmp switch_x
        bne @check_switch_change
        lda tmp1
        cmp switch_y
        beq @check_switch_done
@check_switch_change
        lda tmp0
        sta tmp2
        lda tmp1
        sta tmp3
        jsr release_switch
        lda tmp2
        sta tmp0
        lda tmp3
        sta tmp1
        jsr map_at_tile
@check_switch_press
        ; A switch toggles once when the player's feet enter it. Remaining on
        ; it keeps it depressed; leaving re-arms it for the next entry.
        lda tmp0
        sta switch_x
        lda tmp1
        sta switch_y
        lda #70
        ldy #0
        sta (map_ptr),y
        lda #1
        sta switch_down
        sta room_dirty
        lda #6
        jsr start_sound
        jsr toggle_switch_room
        rts
@check_switch_release
        lda switch_down
        beq @check_switch_done
        jsr release_switch
@check_switch_done
        rts

release_switch
        lda switch_x
        sta tmp0
        lda switch_y
        sta tmp1
        jsr map_at_tile
        cmp #70
        bne @check_switch_clear
        lda #69
        ldy #0
        sta (map_ptr),y
@check_switch_clear
        lda #0
        sta switch_down
        lda #1
        sta room_dirty
        rts

; A switch is pressed only by the bottom of the player's feet. Two points
; inside the player catch an actual overlap; two points one pixel below catch
; the exact frame where Porter is standing on the button's top edge.
find_switch_contact
        mwa p_x col_x
        clc
        lda col_x
        adc #2
        sta col_x
        bcc @+
        inc col_x+1
@
        mwa p_y col_y
        clc
        lda col_y
        adc #7
        sta col_y
        bcc @+
        inc col_y+1
@
        jsr sample_switch_contact
        bcc @+
        rts
@
        clc
        lda col_x
        adc #4
        sta col_x
        bcc @+
        inc col_x+1
@
        jsr sample_switch_contact
        bcc @+
        rts
@
        mwa p_x col_x
        clc
        lda col_x
        adc #2
        sta col_x
        bcc @+
        inc col_x+1
@
        mwa p_y col_y
        clc
        lda col_y
        adc #8
        sta col_y
        bcc @+
        inc col_y+1
@
        jsr sample_switch_contact
        bcc @+
        rts
@
        clc
        lda col_x
        adc #4
        sta col_x
        bcc @+
        inc col_x+1
@
        jsr sample_switch_contact
        rts

sample_switch_contact
        jsr sample_pixel
        cmp #69
        beq @sample_switch_contact_yes
        cmp #70
        beq @sample_switch_contact_yes
        clc
        rts
@sample_switch_contact_yes
        sec
        rts

check_crumble
        lda p_ground
        beq @check_crumble_reset
        mwa p_x col_x
        clc
        lda col_x
        adc #4
        sta col_x
        bcc @+
        inc col_x+1
@
        mwa p_y col_y
        clc
        lda col_y
        adc #8
        sta col_y
        bcc @+
        inc col_y+1
@
        jsr sample_pixel
        cmp #89
        bcc @check_crumble_reset
        cmp #92
        bcs @check_crumble_reset
        lda tmp0
        cmp crumble_x
        bne @check_crumble_new
        lda tmp1
        cmp crumble_y
        bne @check_crumble_new
        inc crumble_time
        lda crumble_time
        cmp #8
        bcc @check_crumble_done
        lda #0
        sta crumble_time
        ldy #0
        lda (map_ptr),y
        clc
        adc #1
        sta (map_ptr),y
        lda #1
        sta room_dirty
        rts
@check_crumble_new
        lda tmp0
        sta crumble_x
        lda tmp1
        sta crumble_y
        lda #0
        sta crumble_time
        rts
@check_crumble_reset
        lda #0
        sta crumble_time
@check_crumble_done
        rts

check_end
        jsr player_center_tile
        lda tmp0
        cmp #87
        bcc @check_end_no
        cmp #91
        bcs @check_end_no
        lda tmp1
        cmp #58
        bcc @check_end_no
        cmp #62
        bcs @check_end_no
        lda #MODE_END
        sta game_mode
        jsr draw_end
        lda #15
        jsr start_sound
@check_end_no
        rts

; Apply the same directional field transition as replace_tiles() in the
; original cartridge.  Do not blindly invert every field tile: that makes a
; room with a preserved/timed phase drift out of sync with its clock.
toggle_switch_room
        lda #1
        sta room_dirty
        lda cam_y
        sta tmp1
        lda #0
        sta row_no
@toggle_switch_room_row
        lda cam_x
        sta tmp0
        lda #0
        sta col_no
@toggle_switch_room_col
        jsr map_at_tile
        ldx switch_state
        bne @toggle_switch_room_blue
        cmp #FIELD_RED_ON
        beq @toggle_switch_room_to_red_off
        cmp #FIELD_BLUE_OFF
        beq @toggle_switch_room_to_blue_on
        jmp @toggle_switch_room_next
@toggle_switch_room_blue
        cmp #FIELD_RED_OFF
        beq @toggle_switch_room_to_red_on
        cmp #FIELD_BLUE_ON
        beq @toggle_switch_room_to_blue_off
        jmp @toggle_switch_room_next
@toggle_switch_room_to_red_off
        lda #FIELD_RED_OFF
        bne @toggle_switch_room_write
@toggle_switch_room_to_red_on
        lda #FIELD_RED_ON
        bne @toggle_switch_room_write
@toggle_switch_room_to_blue_on
        lda #FIELD_BLUE_ON
        bne @toggle_switch_room_write
@toggle_switch_room_to_blue_off
        lda #FIELD_BLUE_OFF
@toggle_switch_room_write
        ldy #0
        sta (map_ptr),y
@toggle_switch_room_next
        inc tmp0
        inc col_no
        lda col_no
        cmp #16
        bne @toggle_switch_room_col
        inc tmp1
        inc row_no
        lda row_no
        cmp #16
        bne @toggle_switch_room_row
        lda switch_state
        eor #1
        sta switch_state
        rts

replace_green_room
        lda #1
        sta room_dirty
        lda cam_y
        sta tmp1
        lda #0
        sta row_no
@replace_green_room_row
        lda cam_x
        sta tmp0
        lda #0
        sta col_no
@replace_green_room_col
        jsr map_at_tile
        ldx green_state
        bne @replace_green_room_restore
        cmp #104
        bne @replace_green_room_next
        lda #103
        bne @replace_green_room_write
@replace_green_room_restore
        cmp #103
        bne @replace_green_room_next
        lda #104
@replace_green_room_write
        ldy #0
        sta (map_ptr),y
@replace_green_room_next
        inc tmp0
        inc col_no
        lda col_no
        cmp #16
        bne @replace_green_room_col
        inc tmp1
        inc row_no
        lda row_no
        cmp #16
        bne @replace_green_room_row
        rts

reset_room_objects
        lda #1
        sta room_dirty
        jsr update_camera
        jsr detect_room_clock
        lda #SWITCH_RED
        sta switch_state
        lda cam_y
        sta tmp1
        lda #0
        sta row_no
@reset_room_objects_row
        lda cam_x
        sta tmp0
        lda #0
        sta col_no
@reset_room_objects_col
        jsr map_at_tile
        cmp #70
        beq @reset_room_objects_switch
        cmp #86
        beq @reset_room_objects_key
        cmp #90
        bcc @reset_room_objects_pairs
        cmp #93
        bcc @reset_room_objects_platform
@reset_room_objects_pairs
        ldx room_clock
        bne @reset_room_objects_preserve_fields
        cmp #FIELD_RED_OFF
        beq @reset_room_objects_blue1
        cmp #FIELD_BLUE_ON
        beq @reset_room_objects_blue2
        cmp #103
        beq @reset_room_objects_green
        jmp @reset_room_objects_next
@reset_room_objects_preserve_fields
        ; Timed rooms retain their red/blue phase on death in the original.
        ; Infer that phase from either of the two blue-phase field sprites.
        cmp #FIELD_RED_OFF
        beq @reset_room_objects_mark_blue
        cmp #FIELD_BLUE_ON
        bne @reset_room_objects_green_test
@reset_room_objects_mark_blue
        lda #SWITCH_BLUE
        sta switch_state
        jmp @reset_room_objects_next
@reset_room_objects_green_test
        cmp #103
        beq @reset_room_objects_green
        jmp @reset_room_objects_next
@reset_room_objects_key
        lda #85
        bne @reset_room_objects_write
@reset_room_objects_switch
        lda #69
        bne @reset_room_objects_write
@reset_room_objects_platform
        lda #89
        bne @reset_room_objects_write
@reset_room_objects_blue1
        lda #FIELD_RED_ON
        bne @reset_room_objects_write
@reset_room_objects_blue2
        lda #FIELD_BLUE_OFF
        bne @reset_room_objects_write
@reset_room_objects_green
        lda #104
@reset_room_objects_write
        ldy #0
        sta (map_ptr),y
@reset_room_objects_next
        inc tmp0
        inc col_no
        lda col_no
        cmp #16
        bne @reset_room_objects_col
        inc tmp1
        inc row_no
        lda row_no
        cmp #16
        bne @reset_room_objects_row
        rts

; Set room_clock when the current room contains any frame of the 119..126
; clock animation.  A second scan is intentional: field tiles can precede the
; clock in map order, but reset policy depends on knowing about the clock first.
detect_room_clock
        lda #0
        sta room_clock
        lda cam_y
        sta tmp1
        lda #0
        sta row_no
@detect_room_clock_row
        lda cam_x
        sta tmp0
        lda #0
        sta col_no
@detect_room_clock_col
        jsr map_at_tile
        cmp #119
        bcc @detect_room_clock_next
        cmp #127
        bcs @detect_room_clock_next
        lda #1
        sta room_clock
        rts
@detect_room_clock_next
        inc tmp0
        inc col_no
        lda col_no
        cmp #16
        bne @detect_room_clock_col
        inc tmp1
        inc row_no
        lda row_no
        cmp #16
        bne @detect_room_clock_row
        rts

update_animations
        lda frame
        and #7
        bne @update_animations_clock
        lda #1
        sta room_dirty
        lda cam_y
        sta tmp1
        lda #0
        sta row_no
@update_animations_row
        lda cam_x
        sta tmp0
        lda #0
        sta col_no
@update_animations_col
        jsr map_at_tile
        cmp #78
        beq @update_animations_a79
        cmp #79
        beq @update_animations_a78
        cmp #93
        beq @update_animations_a94
        cmp #94
        beq @update_animations_a95
        cmp #95
        beq @update_animations_a93
        jmp @update_animations_next
@update_animations_a79
        lda #79
        bne @update_animations_write
@update_animations_a78
        lda #78
        bne @update_animations_write
@update_animations_a94
        lda #94
        bne @update_animations_write
@update_animations_a95
        lda #95
        bne @update_animations_write
@update_animations_a93
        lda #93
@update_animations_write
        ldy #0
        sta (map_ptr),y
@update_animations_next
        inc tmp0
        inc col_no
        lda col_no
        cmp #16
        bne @update_animations_col
        inc tmp1
        inc row_no
        lda row_no
        cmp #16
        bne @update_animations_row
@update_animations_clock
        lda frame
        and #15
        bne @update_animations_done
        jsr animate_clock_room
@update_animations_done
        rts

animate_clock_room
        lda #1
        sta room_dirty
        lda cam_y
        sta tmp1
        lda #0
        sta row_no
@animate_clock_room_row
        lda cam_x
        sta tmp0
        lda #0
        sta col_no
@animate_clock_room_col
        jsr map_at_tile
        cmp #119
        bcc @animate_clock_room_next
        cmp #127
        bcs @animate_clock_room_next
        clc
        adc #1
        cmp #127
        bne @animate_clock_room_store
        lda #119
@animate_clock_room_store
        ldy #0
        sta (map_ptr),y
        cmp #119
        beq @animate_clock_room_toggle
        cmp #123
        bne @animate_clock_room_next
@animate_clock_room_toggle
        jsr toggle_switch_room
        rts
@animate_clock_room_next
        inc tmp0
        inc col_no
        lda col_no
        cmp #16
        bne @animate_clock_room_col
        inc tmp1
        inc row_no
        lda row_no
        cmp #16
        bne @animate_clock_room_row
        rts

; ============================================================================
; Moving objects
; ============================================================================

update_actors
        ldx #ROCKS_COUNT-1
@update_actors_rock_loop
        stx tmp4
        lda rocks_start_x,x
        jsr tile_to_pixel
        mwa tmp0 actor_x
        lda rock_y_lo,x
        sta actor_y
        lda rock_y_hi,x
        sta actor_y+1
        ; test one pixel below the rock
        mwa actor_x col_x
        clc
        lda col_x
        adc #4
        sta col_x
        bcc @+
        inc col_x+1
@
        mwa actor_y col_y
        clc
        lda col_y
        adc #8
        sta col_y
        bcc @+
        inc col_y+1
@
        jsr point_solid
        ldx tmp4
        bcs @update_actors_rock_land
        lda frame
        and #1
        bne @update_actors_rock_move
        lda rock_dy,x
        cmp #3
        bcs @update_actors_rock_move
        inc rock_dy,x
@update_actors_rock_move
        lda rock_y_lo,x
        clc
        adc rock_dy,x
        sta rock_y_lo,x
        bcc @update_actors_rock_next
        inc rock_y_hi,x
        jmp @update_actors_rock_next
@update_actors_rock_land
        lda #0
        sta rock_dy,x
@update_actors_rock_next
        dex
        bpl @update_actors_rock_loop

        lda frame
        and #1
        bne @update_actors_done
        ldx #FEATHERS_COUNT-1
@update_actors_feather_loop
        stx tmp4
        lda feathers_start_x,x
        jsr tile_to_pixel
        mwa tmp0 col_x
        clc
        lda col_x
        adc #4
        sta col_x
        bcc @+
        inc col_x+1
@
        lda feather_y_lo,x
        sta col_y
        lda feather_y_hi,x
        sta col_y+1
        lda col_y
        bne @+
        dec col_y+1
@
        dec col_y
        jsr point_solid
        ldx tmp4
        bcs @update_actors_feather_next
        lda feather_y_lo,x
        bne @+
        dec feather_y_hi,x
@
        dec feather_y_lo,x
@update_actors_feather_next
        dex
        bpl @update_actors_feather_loop
@update_actors_done
        rts

actor_player_collision
        ; Rocks are solid moving platforms in the original game. Porter may
        ; land on one and jump from it; unresolved overlap (for example a rock
        ; falling onto him) remains lethal.
        ldx #ROCKS_COUNT-1
@actor_player_collision_rocks
        lda rocks_start_x,x
        jsr tile_to_pixel
        mwa tmp0 actor_x
        lda rock_y_lo,x
        sta actor_y
        lda rock_y_hi,x
        sta actor_y+1
        jsr player_rock_horizontal_overlap
        bcc @actor_player_collision_rock_overlap
        lda p_dy
        bmi @actor_player_collision_rock_overlap
        ; Land only while crossing the top within this frame. The allowance of
        ; six pixels covers Porter's and the rock's maximum combined motion.
        lda p_y+1
        cmp actor_y+1
        bne @actor_player_collision_rock_overlap
        lda p_y
        cmp actor_y
        bcs @actor_player_collision_rock_overlap
        clc
        adc #8
        cmp actor_y
        bcc @actor_player_collision_rock_overlap
        sec
        sbc actor_y
        cmp #7
        bcs @actor_player_collision_rock_overlap
        sec
        lda actor_y
        sbc #8
        sta p_y
        lda actor_y+1
        sbc #0
        sta p_y+1
        lda #0
        sta p_dy
        lda #1
        sta p_ground
        sta p_can_tele
        jmp @actor_player_collision_next_rock
@actor_player_collision_rock_overlap
        jsr player_actor_overlap
        bcc @actor_player_collision_next_rock
        ; Side contact blocks movement instead of killing Porter.
        lda p_dx
        beq @actor_player_collision_rock_kill
        bmi @actor_player_collision_rock_left
        sec
        lda actor_x
        sbc #8
        sta p_x
        lda actor_x+1
        sbc #0
        sta p_x+1
        lda #0
        sta p_dx
        jmp @actor_player_collision_next_rock
@actor_player_collision_rock_left
        clc
        lda actor_x
        adc #8
        sta p_x
        lda actor_x+1
        adc #0
        sta p_x+1
        lda #0
        sta p_dx
        jmp @actor_player_collision_next_rock
@actor_player_collision_rock_kill
        ; Force the regular death/respawn path out of bounds.
        lda #2
        sta p_y+1
        rts
@actor_player_collision_next_rock
        dex
        bmi @actor_player_collision_feathers_start
        jmp @actor_player_collision_rocks

        ; Feathers carry Porter upward when he is immediately above one.
@actor_player_collision_feathers_start
        ldx #FEATHERS_COUNT-1
@actor_player_collision_feathers
        lda feathers_start_x,x
        jsr tile_to_pixel
        mwa tmp0 actor_x
        lda feather_y_lo,x
        sta actor_y
        lda feather_y_hi,x
        sta actor_y+1
        jsr player_actor_overlap
        bcc @actor_player_collision_next_feather
        lda p_y
        bne @+
        dec p_y+1
@
        dec p_y
        lda #0
        sta p_dy
@actor_player_collision_next_feather
        dex
        bpl @actor_player_collision_feathers
        rts

; Carry set when the original player's down sensor (x+2..x+6) overlaps
; the rock's active horizontal bounds (x+2..x+7).
player_rock_horizontal_overlap
        lda p_x+1
        cmp actor_x+1
        bne @player_rock_horizontal_overlap_no
        clc
        lda actor_x
        adc #2
        sta tmp0
        clc
        lda p_x
        adc #6
        cmp tmp0
        bcc @player_rock_horizontal_overlap_no
        beq @player_rock_horizontal_overlap_no
        clc
        lda actor_x
        adc #7
        sta tmp0
        clc
        lda p_x
        adc #2
        cmp tmp0
        bcs @player_rock_horizontal_overlap_no
        sec
        rts
@player_rock_horizontal_overlap_no
        clc
        rts

player_actor_overlap
        ; quick 16-bit bounding-box test, actor and player are both 8x8
        lda p_x+1
        cmp actor_x+1
        bne @player_actor_overlap_no
        lda p_x
        clc
        adc #7
        cmp actor_x
        bcc @player_actor_overlap_no
        lda actor_x
        clc
        adc #7
        cmp p_x
        bcc @player_actor_overlap_no
        lda p_y+1
        cmp actor_y+1
        bne @player_actor_overlap_no
        lda p_y
        clc
        adc #7
        cmp actor_y
        bcc @player_actor_overlap_no
        lda actor_y
        clc
        adc #7
        cmp p_y
        bcc @player_actor_overlap_no
        sec
        rts
@player_actor_overlap_no
        clc
        rts

; ============================================================================
; Camera and rendering
; ============================================================================

update_camera
        lda cam_x
        sta cam_old_x
        lda cam_y
        sta cam_old_y
        lda p_x
        and #$80
        lsr
        lsr
        lsr
        sta tmp0
        lda p_x+1
        asl
        asl
        asl
        asl
        asl
        ora tmp0
        sta cam_x
        lda p_y
        and #$80
        lsr
        lsr
        lsr
        sta tmp0
        lda p_y+1
        asl
        asl
        asl
        asl
        asl
        ora tmp0
        sta cam_y
        lda cam_x
        cmp cam_old_x
        bne @update_camera_changed
        lda cam_y
        cmp cam_old_y
        beq @update_camera_done
@update_camera_changed
        lda #1
        sta room_dirty
@update_camera_done
        rts

draw_game
        ; Build the complete frame in the hidden framebuffer. The displayed
        ; framebuffer is never modified while VBXE is scanning it.
        lda room_dirty
        beq @draw_game_cached
        jsr draw_room
        lda #0
        sta room_dirty
@draw_game_cached
        jsr copy_room_cache
        jsr set_screen_target
        jsr draw_coins
        jsr draw_actors
        jsr draw_teleport_preview
        jsr draw_player
        jmp present_back_buffer

draw_room
        ; Build the static room entirely in its cache. It is copied only to the
        ; hidden framebuffer, so animated-tile rebuilds cannot erase Porter
        ; partway through a displayed frame.
        lda #ROOM_CACHE_V>>16
        sta dest_bank
        mwa #192 dest_pitch
        lda cam_y
        sta tmp1
        lda #0
        sta row_no
        mwa #0 dst_ptr
@draw_room_row
        lda cam_x
        sta tmp0
        lda #0
        sta col_no
@draw_room_col
        lda #0
        sta sprite_flip
        jsr map_at_tile
        jsr blit_tile
        clc
        lda dst_ptr
        adc #TILE_DRAW
        sta dst_ptr
        bcc @+
        inc dst_ptr+1
@
        inc tmp0
        inc col_no
        lda col_no
        cmp #16
        bne @draw_room_col
        ; 12 cache scanlines minus the 192 bytes advanced across the tile row.
        clc
        lda dst_ptr
        adc #<$0840
        sta dst_ptr
        lda dst_ptr+1
        adc #>$0840
        sta dst_ptr+1
        inc tmp1
        inc row_no
        lda row_no
        cmp #16
        bne @draw_room_row
        rts

; Restore the cached 192x192 room into the hidden framebuffer with a single
; blitter command. Dynamic sprites are drawn there afterward.
copy_room_cache
        jsr wait_blitter
        ldy #$5d
        lda #$80+[BCB_V>>14]
        sta (fx_ptr),y
        lda #<ROOM_CACHE_V
        sta MEMW+[BCB_V&$3fff]+0
        lda #>ROOM_CACHE_V
        sta MEMW+[BCB_V&$3fff]+1
        lda #ROOM_CACHE_V>>16
        sta MEMW+[BCB_V&$3fff]+2
        lda #<192
        sta MEMW+[BCB_V&$3fff]+3
        lda #>192
        sta MEMW+[BCB_V&$3fff]+4
        lda #1
        sta MEMW+[BCB_V&$3fff]+5
        lda #<[VIEW_Y*SCR_W+VIEW_X]
        sta MEMW+[BCB_V&$3fff]+6
        lda #>[VIEW_Y*SCR_W+VIEW_X]
        sta MEMW+[BCB_V&$3fff]+7
        lda back_bank
        sta MEMW+[BCB_V&$3fff]+8
        lda #<SCR_W
        sta MEMW+[BCB_V&$3fff]+9
        lda #>SCR_W
        sta MEMW+[BCB_V&$3fff]+10
        lda #1
        sta MEMW+[BCB_V&$3fff]+11
        lda #<191
        sta MEMW+[BCB_V&$3fff]+12
        lda #>191
        sta MEMW+[BCB_V&$3fff]+13
        lda #191
        sta MEMW+[BCB_V&$3fff]+14
        lda #$ff
        sta MEMW+[BCB_V&$3fff]+15
        lda #0
        sta MEMW+[BCB_V&$3fff]+16
        sta MEMW+[BCB_V&$3fff]+17
        sta MEMW+[BCB_V&$3fff]+18
        sta MEMW+[BCB_V&$3fff]+19
        sta MEMW+[BCB_V&$3fff]+20
        jsr start_blitter
        jsr wait_blitter
        ldy #$5d
        lda #0
        sta (fx_ptr),y
        rts

set_screen_target
        lda back_bank
        sta dest_bank
        mwa #SCR_W dest_pitch
        rts

; Publish only a completely rendered framebuffer. Switching the XDL pointer
; during vertical blank is atomic from the viewer's perspective.
present_back_buffer
        jsr wait_vbl
        lda front_bank
        pha
        lda back_bank
        sta front_bank
        pla
        sta back_bank
        lda front_bank
        cmp #SCREEN_A_V>>16
        beq @present_back_buffer_a
        lda #<XDL_B_V
        sta tmp_ptr
        lda #>XDL_B_V
        sta tmp_ptr+1
        jmp @present_back_buffer_set
@present_back_buffer_a
        lda #<XDL_A_V
        sta tmp_ptr
        lda #>XDL_A_V
        sta tmp_ptr+1
@present_back_buffer_set
        ldy #$41
        lda tmp_ptr
        sta (fx_ptr),y
        iny
        lda tmp_ptr+1
        sta (fx_ptr),y
        iny
        lda #XDL_A_V>>16
        sta (fx_ptr),y
        rts

draw_coins
        ldx #0
@draw_coins_loop
        lda coin_alive,x
        beq @draw_coins_next
        lda coin_tile_x,x
        sec
        sbc cam_x
        bcc @draw_coins_next
        cmp #16
        bcs @draw_coins_next
        sta tmp2
        lda coin_tile_y,x
        sec
        sbc cam_y
        bcc @draw_coins_next
        cmp #16
        bcs @draw_coins_next
        sta tmp3
        stx row_no                  ; blit_sprite uses tmp4 for its copy mode
        jsr tile_local_to_dst
        lda #48
        jsr blit_sprite
        ldx row_no
@draw_coins_next
        inx
        cpx #COIN_COUNT
        bne @draw_coins_loop
        rts

draw_actors
        ldx #ROCKS_COUNT-1
@draw_actors_rocks
        stx row_no
        lda rocks_start_x,x
        jsr tile_to_pixel
        mwa tmp0 actor_x
        lda rock_y_lo,x
        sta actor_y
        lda rock_y_hi,x
        sta actor_y+1
        lda #74
        jsr draw_world_actor
        ldx row_no
        dex
        bpl @draw_actors_rocks
        ldx #FEATHERS_COUNT-1
@draw_actors_feathers
        stx row_no
        lda feathers_start_x,x
        jsr tile_to_pixel
        mwa tmp0 actor_x
        lda feather_y_lo,x
        sta actor_y
        lda feather_y_hi,x
        sta actor_y+1
        lda #75
        jsr draw_world_actor
        ldx row_no
        dex
        bpl @draw_actors_feathers
        rts

draw_world_actor
        sta sprite_id
        ; Actor must be in current 128-pixel camera page.
        lda actor_x
        and #$80
        lsr
        lsr
        lsr
        sta tmp0
        lda actor_x+1
        asl
        asl
        asl
        asl
        asl
        ora tmp0
        cmp cam_x
        bne @draw_world_actor_no
        lda actor_y
        and #$80
        lsr
        lsr
        lsr
        sta tmp0
        lda actor_y+1
        asl
        asl
        asl
        asl
        asl
        ora tmp0
        cmp cam_y
        bne @draw_world_actor_no
        lda actor_x
        and #$7f
        jsr scale_local
        clc
        adc #VIEW_X
        sta tmp2
        lda actor_y
        and #$7f
        jsr scale_local
        clc
        adc #VIEW_Y
        sta tmp3
        jsr set_dst_xy
        lda sprite_id
        jmp blit_sprite
@draw_world_actor_no
        rts

draw_player
        lda p_x
        and #$7f
        jsr scale_local
        clc
        adc #VIEW_X
        sta tmp2
        lda p_y
        and #$7f
        jsr scale_local
        clc
        adc #VIEW_Y
        sta tmp3
        jsr set_dst_xy
        lda p_face
        sta sprite_flip
        lda p_sprite
        jsr blit_sprite
        lda #0
        sta sprite_flip
        rts

draw_teleport_preview
        mwa p_x actor_x
        mwa p_y actor_y
        lda joy_state
        and #JOY_UP
        beq @draw_teleport_preview_down
        sec
        lda actor_y
        sbc #32
        sta actor_y
        bcs @draw_teleport_preview_draw
        dec actor_y+1
        jmp @draw_teleport_preview_draw
@draw_teleport_preview_down
        lda joy_state
        and #JOY_DOWN
        beq @draw_teleport_preview_left
        clc
        lda actor_y
        adc #32
        sta actor_y
        bcc @draw_teleport_preview_draw
        inc actor_y+1
        jmp @draw_teleport_preview_draw
@draw_teleport_preview_left
        lda joy_state
        and #JOY_LEFT
        bne @draw_teleport_preview_go_left
        lda joy_state
        and #JOY_RIGHT
        bne @draw_teleport_preview_right
        lda p_face
        beq @draw_teleport_preview_right
@draw_teleport_preview_go_left
        sec
        lda actor_x
        sbc #32
        sta actor_x
        bcs @draw_teleport_preview_draw
        dec actor_x+1
        jmp @draw_teleport_preview_draw
@draw_teleport_preview_right
        clc
        lda actor_x
        adc #32
        sta actor_x
        bcc @draw_teleport_preview_draw
        inc actor_x+1
@draw_teleport_preview_draw
        lda #16
        jsr draw_world_actor
@draw_teleport_preview_done
        rts

; A 0..127 -> floor(A*3/2)
scale_local
        sta tmp4
        lsr
        clc
        adc tmp4
        rts

; tmp2 local tile x, tmp3 local tile y -> dst_ptr
tile_local_to_dst
        lda tmp2
        asl
        asl
        sta tmp0
        lda tmp2
        asl
        asl
        asl
        clc
        adc tmp0
        adc #VIEW_X
        sta tmp2
        lda tmp3
        asl
        asl
        sta tmp0
        lda tmp3
        asl
        asl
        asl
        clc
        adc tmp0
        adc #VIEW_Y
        sta tmp3
        jmp set_dst_xy

; tmp2=x (0..255), tmp3=y (0..199), calculate y*320+x
set_dst_xy
        lda tmp3
        and #3
        tax
        lda times64,x
        clc
        adc tmp2
        sta dst_ptr
        lda #0
        adc #0
        sta tmp1
        lda tmp3
        lsr
        lsr
        sta tmp0
        lda tmp3
        clc
        adc tmp0
        adc tmp1
        sta dst_ptr+1
        rts

times64
        dta 0,64,128,192

; ============================================================================
; Title/end compositions
; ============================================================================

draw_title
        lda front_bank
        sta dest_bank
        jsr clear_buffer
        mwa #SCR_W dest_pitch
        lda #0
        sta sprite_flip
        ; PORTER logo, assembled as in the PICO-8 title.
        lda #18
        ldx #74
        ldy #42
        jsr draw_block_2x2
        lda #20
        ldx #102
        ldy #54
        jsr draw_block_2x2
        lda #51
        ldx #130
        ldy #66
        jsr draw_block_2x1
        lda #22
        ldx #154
        ldy #42
        jsr draw_block_1x3
        lda #39
        ldx #166
        ldy #54
        jsr draw_block_2x2
        lda #51
        ldx #194
        ldy #66
        jsr draw_block_2x1
        lda #1
        ldx #154
        ldy #122
        jsr draw_sprite_xy
        lda #16
        ldx #154
        ldy #150
        jsr draw_sprite_xy
        rts

draw_end
        jsr clear_back_buffer
        jsr set_screen_target
        lda #0
        sta sprite_flip
        lda #119
        ldx #142
        ldy #48
        jsr draw_sprite_xy
        lda #1
        ldx #154
        ldy #92
        jsr draw_sprite_xy
        lda #48
        ldx #154
        ldy #132
        jsr draw_sprite_xy
        jmp present_back_buffer

draw_sprite_xy
        sta sprite_id
        stx tmp2
        sty tmp3
        jsr set_dst_xy
        lda sprite_id
        jmp blit_sprite

draw_block_2x1
        sta sprite_id
        stx tmp2
        sty tmp3
        jsr set_dst_xy
        lda sprite_id
        jsr blit_sprite
        clc
        lda dst_ptr
        adc #12
        sta dst_ptr
        bcc @+
        inc dst_ptr+1
@
        inc sprite_id
        lda sprite_id
        jmp blit_sprite

draw_block_2x2
        sta sprite_id
        stx tmp2
        sty tmp3
        jsr set_dst_xy
        lda sprite_id
        jsr blit_sprite
        clc
        lda dst_ptr
        adc #12
        sta dst_ptr
        bcc @+
        inc dst_ptr+1
@
        inc sprite_id
        lda sprite_id
        jsr blit_sprite
        clc
        lda dst_ptr
        adc #<$0ef4             ; next row minus 12
        sta dst_ptr
        lda dst_ptr+1
        adc #>$0ef4
        sta dst_ptr+1
        lda sprite_id
        clc
        adc #15
        sta sprite_id
        lda sprite_id
        jsr blit_sprite
        clc
        lda dst_ptr
        adc #12
        sta dst_ptr
        bcc @+
        inc dst_ptr+1
@
        inc sprite_id
        lda sprite_id
        jmp blit_sprite

draw_block_1x3
        sta sprite_id
        stx tmp2
        sty tmp3
        jsr set_dst_xy
        lda sprite_id
        jsr blit_sprite
        clc
        lda dst_ptr
        adc #<$0f00
        sta dst_ptr
        lda dst_ptr+1
        adc #>$0f00
        sta dst_ptr+1
        lda sprite_id
        clc
        adc #16
        sta sprite_id
        lda sprite_id
        jsr blit_sprite
        clc
        lda dst_ptr
        adc #<$0f00
        sta dst_ptr
        lda dst_ptr+1
        adc #>$0f00
        sta dst_ptr+1
        lda sprite_id
        clc
        adc #16
        jmp blit_sprite

; ============================================================================
; VBXE
; ============================================================================

vbxe_init
        mwa #$d600 fx_ptr
        jsr detect_here
        beq @vbxe_init_found
        inc fx_ptr+1
        jsr detect_here
        beq @vbxe_init_found
        jmp (10)
@vbxe_init_found
        ldy #$40
        lda #0
        sta (fx_ptr),y
        jsr upload_sprites
        jsr upload_xdl_bcb
        jsr upload_palette
        ldy #$40
        lda #1
        sta (fx_ptr),y
        iny
        lda #<XDL_A_V
        sta (fx_ptr),y
        iny
        lda #>XDL_A_V
        sta (fx_ptr),y
        iny
        lda #XDL_A_V>>16
        sta (fx_ptr),y
        ldy #$5d
        lda #0
        sta (fx_ptr),y
        rts

detect_here
        ldy #$40
        lda (fx_ptr),y
        cmp #$10
        bne @detect_here_no
        iny
        lda (fx_ptr),y
        and #$70
        cmp #$20
@detect_here_no
        rts

upload_sprites
        mwa #sprites_raw src_ptr
        mwa #MEMW dst_ptr
        ldx #SPRITE_DATA_PAGES
@upload_sprites_page
        ; MEMAC-B covers $4000-$7FFF, which includes part of sprites_raw.
        ; Copy with the window disabled, then upload from a safe bounce page.
        ldy #$5d
        lda #0
        sta (fx_ptr),y
        ldy #0
@upload_sprites_stage
        lda (src_ptr),y
        sta sprite_bounce,y
        iny
        bne @upload_sprites_stage
        ldy #$5d
        lda #$80                    ; all packed sprites fit VRAM bank 0
        sta (fx_ptr),y
        ldy #0
@upload_sprites_copy
        lda sprite_bounce,y
        sta (dst_ptr),y
        iny
        bne @upload_sprites_copy
        inc src_ptr+1
        inc dst_ptr+1
        dex
        bne @upload_sprites_page
        ldy #$5d
        lda #0
        sta (fx_ptr),y
        rts

upload_xdl_bcb
        ldy #$5d
        lda #$80+[XDL_A_V>>14]
        sta (fx_ptr),y
        ldx #xdl_len-1
@upload_xdl_bcb_xdl_a
        lda xdl_data_a,x
        sta MEMW+[XDL_A_V&$3fff],x
        dex
        bpl @upload_xdl_bcb_xdl_a
        ldx #xdl_len-1
@upload_xdl_bcb_xdl_b
        lda xdl_data_b,x
        sta MEMW+[XDL_B_V&$3fff],x
        dex
        bpl @upload_xdl_bcb_xdl_b
        ldx #bcb_len-1
@upload_xdl_bcb_bcb
        lda bcb_template,x
        sta MEMW+[BCB_V&$3fff],x
        dex
        bpl @upload_xdl_bcb_bcb
        rts

upload_palette
        ldy #$44
        lda #0
        sta (fx_ptr),y
        iny
        lda #1
        sta (fx_ptr),y
        ldx #0
@upload_palette_colour
        ldy #$46
        lda pico_palette,x
        sta (fx_ptr),y
        inx
        iny
        lda pico_palette,x
        sta (fx_ptr),y
        inx
        iny
        lda pico_palette,x
        sta (fx_ptr),y
        inx
        cpx #48
        bcc @upload_palette_colour
        rts

clear_back_buffer
        lda back_bank
        sta dest_bank

clear_buffer
        ; Clear all four 16K MEMAC-B banks occupied by dest_bank's framebuffer.
        ; A CPU clear is used here because it is startup/end-screen only and
        ; avoids core/emulator differences in constant-source blitter fills.
        lda dest_bank
        asl
        asl
        ora #$80
        sta tmp1                    ; never read MEMAC_BANK_SEL back
        lda #4
        sta tmp0
@clear_screen_bank
        ldy #$5d
        lda tmp1
        sta (fx_ptr),y
        mwa #MEMW dst_ptr
        ldx #64
@clear_screen_page
        ldy #0
        lda #0
@clear_screen_byte
        sta (dst_ptr),y
        iny
        bne @clear_screen_byte
        inc dst_ptr+1
        dex
        bne @clear_screen_page
        dec tmp0
        beq @clear_screen_done
        inc tmp1
        jmp @clear_screen_bank
@clear_screen_done
        ldy #$5d
        lda #0
        sta (fx_ptr),y
        rts

blit_tile
        sta sprite_id
        lda #0
        sta tmp4
        jmp blit_common

blit_sprite
        sta sprite_id
        lda #1
        sta tmp4

blit_common
        jsr wait_blitter
        ldy #$5d
        lda #$80+[BCB_V>>14]
        sta (fx_ptr),y
        ldx sprite_id
        lda sprite_addr_lo,x
        sta MEMW+[BCB_V&$3fff]+0
        lda sprite_addr_hi,x
        sta MEMW+[BCB_V&$3fff]+1
        lda #0
        sta MEMW+[BCB_V&$3fff]+2
        lda #12
        sta MEMW+[BCB_V&$3fff]+3
        lda #0
        sta MEMW+[BCB_V&$3fff]+4
        lda sprite_flip
        beq @blit_common_normal
        clc
        lda MEMW+[BCB_V&$3fff]+0
        adc #11
        sta MEMW+[BCB_V&$3fff]+0
        bcc @+
        inc MEMW+[BCB_V&$3fff]+1
@
        lda #$ff
        bne @blit_common_srcstep
@blit_common_normal
        lda #1
@blit_common_srcstep
        sta MEMW+[BCB_V&$3fff]+5
        lda dst_ptr
        sta MEMW+[BCB_V&$3fff]+6
        lda dst_ptr+1
        sta MEMW+[BCB_V&$3fff]+7
        lda dest_bank
        sta MEMW+[BCB_V&$3fff]+8
        lda dest_pitch
        sta MEMW+[BCB_V&$3fff]+9
        lda dest_pitch+1
        sta MEMW+[BCB_V&$3fff]+10
        lda #1
        sta MEMW+[BCB_V&$3fff]+11
        lda #11
        sta MEMW+[BCB_V&$3fff]+12
        lda #0
        sta MEMW+[BCB_V&$3fff]+13
        lda #11
        sta MEMW+[BCB_V&$3fff]+14
        lda #$ff
        sta MEMW+[BCB_V&$3fff]+15
        lda #0
        sta MEMW+[BCB_V&$3fff]+16
        sta MEMW+[BCB_V&$3fff]+17
        sta MEMW+[BCB_V&$3fff]+18
        lda tmp4
        sta MEMW+[BCB_V&$3fff]+20
        jsr start_blitter
        jsr wait_blitter
        ; MEMAC-B shadows $4000-$7FFF. Release it before gameplay/map code;
        ; tile_flags is in that range and must remain visible to the CPU.
        ldy #$5d
        lda #0
        sta (fx_ptr),y
        rts

start_blitter
        ldy #$50
        lda #<BCB_V
        sta (fx_ptr),y
        iny
        lda #>BCB_V
        sta (fx_ptr),y
        iny
        lda #BCB_V>>16
        sta (fx_ptr),y
        iny
        lda #1
        sta (fx_ptr),y
        rts

wait_blitter
        lda #0
        sta blit_wait_lo
        ; Full-room cache transfers are 36 KiB. Small-blit timeout was short
        ; enough to abort these copies on slower but otherwise correct cores.
        lda #$ff
        sta blit_wait_hi
@wait_blitter_wait
        ldy #$53
        lda (fx_ptr),y
        beq @wait_blitter_done
        dec blit_wait_lo
        bne @wait_blitter_wait
        dec blit_wait_hi
        bne @wait_blitter_wait
        ; Abort a wedged blit rather than freezing with the current POKEY tone.
        lda #0
        sta (fx_ptr),y
        sta audc1
        sta sound_time
@wait_blitter_done
        rts

xdl_data_a
        dta a($24),b(3)                 ; four blank lines
        dta a($8862),b(199+4)
        dta a(SCREEN_A_V&$ffff)
        dta b(SCREEN_A_V>>16),a(SCR_W)
        dta a($ff14)
xdl_len = *-xdl_data_a

xdl_data_b
        dta a($24),b(3)
        dta a($8862),b(199+4)
        dta a(SCREEN_B_V&$ffff)
        dta b(SCREEN_B_V>>16),a(SCR_W)
        dta a($ff14)

bcb_template
        dta 0,0,0
        dta a(12),1
        dta a(SCREEN_A_V&$ffff),SCREEN_A_V>>16
        dta a(SCR_W),1
        dta a(11),11
        dta $ff,0,0
        dta 0,0,1
bcb_len = *-bcb_template

; ============================================================================
; POKEY event sounds
; ============================================================================

sfx_teleport
        lda sound_enabled
        beq @sfx_teleport_muted
        lda #180
        sta audf1
        lda #$ac
        sta audc1
        lda #7
        sta sound_time
@sfx_teleport_muted
        rts

start_sound
        ; A is both duration basis and pitch variation.
        pha
        lda sound_enabled
        bne @start_sound_enabled
        pla
        lda #0
        sta sound_time
        sta audc1
        rts
@start_sound_enabled
        pla
        sta sound_time
        asl
        asl
        clc
        adc #35
        sta audf1
        lda #$aa
        sta audc1
        rts

sound_update
        lda sound_enabled
        beq @sound_update_silent
        lda sound_time
        beq @sound_update_silent
        dec sound_time
        lda sound_time
        ora #$a0
        sta audc1
        rts
@sound_update_silent
        lda #0
        sta audc1
        rts

; Signed proximity order: exact, then one pixel left/right, and so on.  The
; horizontal range is one 8-pixel tile; vertical correction remains tighter.
teleport_snap_x_offsets
        dta 0,$ff,1,$fe,2,$fd,3,$fc,4,$fb,5,$fa,6,$f9,7,$f8,8
teleport_snap_y_offsets
        dta 0,$ff,1,$fe,2,$fd,3,$fc,4

; --- generated compact tables ----------------------------------------------
        icl 'data/sprite_addr.inc.asm'
        icl 'data/checkpoints.inc.asm'
        icl 'data/objects.inc.asm'
        icl 'data/palette.inc.asm'

; --- cartridge data segments ------------------------------------------------
; Keep the complete asset range below BASIC ROM. Some XEX loaders do not write
; reliably into RAM hidden by $A000-$BFFF even if it is exposed afterward.
; ERT guards make an accidental segment overlap a build failure.
        ert * > $3fff
        org $4000
sprites_raw
        ins 'data/sprites12.dat'

        ert * > $7bff
        org $7c00
tile_flags
        ins 'data/tile_flags.dat'

        ert * > $7fff
        org $8000
world_map
        ins 'data/world.dat'

        run start
