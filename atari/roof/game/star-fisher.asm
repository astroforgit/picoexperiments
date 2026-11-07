; Star Fisher - native Atari XL/XE + VBXE FX, PAL 320x240.
; Boot/MEMAC loader follows ../lich/intro-slideshow; double buffered rendering.
        opt h+
vb = $80
src = $82
dst = $84
points = $86
bob_ptr = $8a
        org $2000
main
        sei
        lda #0
        sta $d40e
        sta $d400
        sta $022f
        jsr detect
        bcs supported
        jmp unsupported
supported
        lda $d301
        and #$fe
        ora #$82
        sta $d301
        lda #0
        sta $d20e
        sta $d01a
        sta $d01b
        sta $d01d
        jsr sound_init
        mwa #nmi $fffa
        mwa #irq $fffe
        lda #$98
        ldy #$5e
        sta (vb),y
        lda #1
        ldy #$45
        sta (vb),y
        lda #0
        ldy #$44
        sta (vb),y
        ldx #0
pal_loop
        ldy #$46
        lda palette_0,x
        sta (vb),y
        iny
        lda palette_1,x
        sta (vb),y
        iny
        lda palette_2,x
        sta (vb),y
        inx
        bne pal_loop
; Two XDLs at $7e000 and $7e010, buffers at $20000/$40000.
        lda #$fe
        ldy #$5f
        sta (vb),y
        ldx #31
copy_xdl
        lda xdl_data,x
        sta $9000,x
        dex
        bpl copy_xdl
        lda #0
        ldy #$41
        sta (vb),y
        iny
        lda #$e0
        sta (vb),y
        iny
        lda #7
        sta (vb),y
; Blitter command at $7f000.
        lda #0
        ldy #$50
        sta (vb),y
        iny
        lda #$f0
        sta (vb),y
        iny
        lda #7
        sta (vb),y
        jsr reset_game
        lda #0
        sta menu_release
        sta result_armed
        lda #2
        sta buffer
        jsr render
        lda #0
        ldy #$41
        sta (vb),y
        lda #4
        sta buffer
        lda #5
        ldy #$40
        sta (vb),y
        lda #$40
        sta $d40e
        cli
; Idle time in both waits copies the next recorded sound from VBXE memory.
main_loop
        lda frame
        sta wait_frame
wait_tick
        jsr sound_load
        lda frame
        cmp wait_frame
        beq wait_tick
        jsr input
        jsr update
        jsr render
        lda popup_active
        beq no_bobber_popup
        jsr draw_bobber_popup
no_bobber_popup
; Present only on vertical blank, then draw to the other buffer.
        lda frame
        sta wait_frame
wait_present
        jsr sound_load
        lda frame
        cmp wait_frame
        beq wait_present
        lda buffer
        cmp #2
        beq present_a
        lda #16
        bne present_set
present_a
        lda #0
present_set
        ldy #$41
        sta (vb),y
        lda buffer
        eor #6
        sta buffer
        inc ticks
        jmp main_loop
nmi
        pha
        txa
        pha
        tya
        pha
        lda #0
        sta $d40f
        inc frame
        jsr charge_vblank
        jsr bite_vblank
        jsr sky_vblank
        jsr sound_vblank
        pla
        tay
        pla
        tax
        pla
        rti

; A ($3f), Space ($21), or joystick fire. R ($28) returns to the menu.
; Directions: joystick, or the arrow keys - = + * (bits up, down, left, right).
input
        lda state
        cmp #STATE_GAME_OVER
        bne input_not_results
        jmp game_over_input
input_not_results
        lda menu_release
        beq input_normal
        jsr read_any_input
        bne input_blocked
        sta menu_release
input_blocked
        rts
input_normal
        lda popup_keys
        sta popup_previous
        lda #0
        sta popup_keys
        lda pressed
        sta previous_pressed
        lda dirs
        sta previous_dirs
        lda $d300
        eor #$0f
        and #$0f
        sta dirs
        lda #0
        sta pressed
        lda $d010
        bne keyboard
        inc pressed
keyboard
        lda $d20f
        and #4
        bne input_done
        lda $d209
        and #$3f
        cmp #$15
        bne key_not_b
        lda #1
        sta popup_keys
        jmp input_done
key_not_b
        cmp #$0c
        bne key_not_enter
        lda #2
        sta popup_keys
        jmp input_done
key_not_enter
        cmp #$1c
        bne key_not_escape
        lda #4
        sta popup_keys
        jmp input_done
key_not_escape
        cmp #$25
        bne key_not_menu
        lda #8
        sta popup_keys
        jmp input_done
key_not_menu
        cmp #$28
        bne not_reset
        lda popup_active
        beq key_reset_allowed
        jmp input_done
key_reset_allowed
        jsr reset_game
        rts
not_reset
        cmp #$1f
        bne key_not_rainbow
        lda #0
        jsr equip_worm
        jmp input_done
key_not_rainbow
        cmp #$1e
        bne key_not_electric
        lda #1
        jsr equip_worm
        jmp input_done
key_not_electric
        ldx #3
key_direction
        cmp key_dir_codes,x
        bne key_direction_next
        pha
        lda key_dir_bits,x
        ora dirs
        sta dirs
        pla
key_direction_next
        dex
        bpl key_direction
        cmp #$3f
        beq key_cast
        cmp #$21
        bne input_done
key_cast
        lda #1
        sta pressed
input_done
        lda popup_previous
        eor #$ff
        and popup_keys
        sta popup_edge
        lda previous_pressed
        eor #$ff
        and pressed
        sta press_edge
        lda previous_dirs
        eor #$ff
        and dirs
        sta dir_edge
        rts
key_dir_codes dta $0e,$0f,$06,$07
key_dir_bits dta 1,2,4,8
reset_game
        lda #2
        sta worm_stock
        sta worm_stock+1
        lda #0
        sta menu_resume
        lda #<DIVE_INTERVAL_FRAMES
        sta dive_timer
        lda #>DIVE_INTERVAL_FRAMES
        sta dive_timer+1
        lda #4
        sta worms_spare
        lda #0
        sta worm_type
        sta interest_bonus
        lda #1
        sta bait_present
        lda #0
        sta bite_stage
        sta bite_timer
        sta bite_timer+1
        sta popup_active
        sta state
        sta charge
        sta power
        sta phase
        sta score
        sta casts
        sta ticks
        sta $d201
        lda #$ff
        sta caught
        sta previous_pressed
        sta previous_dirs
        lda #STATE_MENU
        sta state
        sta menu_dirty
        lda #0
        sta menu_row
        sta pressed
        sta press_edge
        lda $d20a
        ora #1
        sta random_seed
        jsr reset_sky
        lda random_seed
        eor #$a5
        ora #1
        sta light_seed
        ldx #WINDOW_COUNT-1
reset_lights
        lda light_initial,x
        sta light_on,x
        lda light_delay,x
        sta light_timer,x
        lda #0
        sta light_flicker,x
        dex
        bpl reset_lights
        rts
; Small LFSR seeded from POKEY at reset; X survives all random routines.
random_byte
        lda random_seed
        asl
        bcc random_ready
        eor #$1d
random_ready
        sta random_seed
        rts

update
        lda state
        cmp #STATE_GAME_OVER
        bne update_live
        rts
update_live
        jsr toggle_menu
        lda menu_block
        beq update_menu_ready
        rts
update_menu_ready
        jsr bobber_controls
        lda popup_block
        beq update_unpaused
        rts
update_unpaused
        jsr update_sky
        jsr update_lights
        lda state
        cmp #STATE_MENU
        bne not_menu_update
        jmp menu
not_menu_update
        cmp #4
        bne not_won
        rts
not_won
        lda state
        bne state_not_idle
        jmp idle
state_not_idle
        cmp #1
        bne state_not_charge
        jmp charging
state_not_charge
        cmp #2
        bne state_not_cast
        jmp casting
state_not_cast
        cmp #3
        bne state_wait
        jmp reeling
state_wait
        jmp waiting

; Start menu over the live night scene. Up/down picks a row; left/right or
; fire changes a setting or activates the highlighted menu entry.
STATE_MENU = 7
menu
        lda popup_edge
        and #2
        ora press_edge
        sta menu_activate
        ora dir_edge
        beq menu_no_dirty
        lda #1
        sta menu_dirty
menu_no_dirty
        lda dir_edge
        and #1
        beq menu_not_up
        lda menu_row
        beq menu_not_up
        dec menu_row
menu_not_up
        lda dir_edge
        and #2
        beq menu_not_down
        lda menu_row
        cmp #4
        bcs menu_not_down
        inc menu_row
menu_not_down
        ldx menu_row
        bne menu_setting
        jmp menu_start
menu_setting
        cpx #2
        bcs menu_extra
        lda dir_edge
        and #4
        beq menu_not_left
        lda cloud_level
        beq menu_not_left
        dec cloud_level
menu_not_left
        lda dir_edge
        and #8
        ora menu_activate
        beq menu_apply
        lda cloud_level
        clc
        adc #1
        cmp #3
        bcc menu_store
        lda dir_edge
        and #8
        bne menu_apply
        lda #0
menu_store
        sta cloud_level
menu_apply
        lda dir_edge
        ora menu_activate
        beq menu_clouds
        sta menu_dirty
menu_clouds
        ldx cloud_level
        lda cloud_counts,x
        sta cloud_count
        rts
menu_extra
        cpx #4
        beq menu_sound
        cpx #3
        bne menu_bobber_activate
        lda dir_edge
        and #4
        beq difficulty_not_left
        lda difficulty
        beq difficulty_not_left
        dec difficulty
difficulty_not_left
        lda dir_edge
        and #8
        ora menu_activate
        beq difficulty_applied
        lda difficulty
        clc
        adc #1
        cmp #3
        bcc difficulty_store
        lda dir_edge
        and #8
        bne difficulty_applied
        lda #0
difficulty_store
        sta difficulty
difficulty_applied
        jmp menu_apply
menu_sound
        lda dir_edge
        and #12
        ora menu_activate
        beq menu_sound_done
        jsr sound_toggle
menu_sound_done
        jmp menu_apply
menu_bobber_activate
        lda menu_activate
        beq menu_extra_done
        jmp menu_bobbers
menu_extra_done
        rts
menu_bobbers
        lda bobber_selected
        sta popup_selected
        lda #1
        sta popup_active
        rts
menu_start
        lda menu_activate
        beq menu_apply
        lda menu_resume
        cmp #STATE_GAME_OVER
        beq play_new_night
        cmp #4
        beq play_new_night
        lda worms_spare
        ora bait_present
        beq play_new_night
        lda menu_resume
        sta state
        jmp menu_apply
play_new_night
        jsr reset_game
        lda #0
        sta state
        jmp menu_apply
idle
        lda bait_present
        beq update_done
        lda press_edge
        beq update_done
        lda #0
        sta charge
        sta charge_ticks
        lda #1
        sta gauge_dir
        sta state
update_done
        rts
; Charge follows PAL time, reaching maximum after 25 VBIs (half a second).
; Preserve the editor's optional spring bounce, independent of render speed.
charge_vblank
        lda state
        cmp #1
        bne charge_clock_done
        lda popup_active
        bne charge_clock_done
        lda gauge_dir
        bmi charge_down
        lda charge_ticks
        cmp #25
        bcs charge_clock_done
        inc charge_ticks
        lda charge_ticks
        cmp #25
        bne charge_map
        lda spring_mode
        beq charge_map
        lda #$ff
        sta gauge_dir
        bne charge_map
charge_down
        dec charge_ticks
        bne charge_map
        lda #1
        sta gauge_dir
charge_map
        ldx charge_ticks
        lda charge_levels,x
        sta charge
charge_clock_done
        rts
charging
        lda pressed
        beq launch
        rts
; More power casts farther forward (left), never back toward the fisherman.
launch
        ldx charge
        stx power
        lda charge_height,x
        sta target_y
        lda charge_distance,x
        sta target_x
        lda #0
        sta phase
        lda #2
        sta state
        inc casts
        lda #$ff
        sta caught
        rts
FLIGHT_START = 8
casting
        inc phase
        lda phase
        jsr set_rod
        lda phase
        cmp #FLIGHT_START
        bcs cast_flight
        jmp hang_float
cast_flight
        bne cast_step
        jsr hang_float
        lda target_x
        sta goal_x
        lda target_y
        sta goal_y
        jsr aim
cast_step
        jsr path_add
        lda phase
        sec
        sbc #FLIGHT_START
        tax
        lda pos_hi+1
        sec
        sbc arc_table,x
        bcc arc_clamp
        cmp #14
        bcs arc_ready
arc_clamp
        lda #14
arc_ready
        sta float_y
        lda phase
        cmp #23
        bcs cast_landed
        rts
cast_landed
        lda target_x
        sta base_x
        sta float_x
        lda target_y
        sta base_y
        sta float_y
        jmp new_wait

reeling
        lda phase
        beq landed
        dec phase
        jmp path_add
landed
        lda #0
        sta interest_bonus
        sta bite_stage
        lda caught
        cmp #$ff
        beq empty_cast
        inc score
empty_cast
        lda #0
        sta state
        sta phase
        sta charge
        lda score
        cmp #5
        bcs won_game
        jsr auto_rebait
        lda bait_present
        ora worms_spare
        bne landed_ready
        jmp game_over_enter
landed_ready
        rts
won_game
        jmp game_over_enter

; A = rod frame. Sets the rod pixel list and its tip.
set_rod
        tax
        lda rod_lo,x
        sta points
        lda rod_hi,x
        sta points+1
        lda tip_x_table,x
        sta tip_x
        lda tip_y_table,x
        sta tip_y
        rts
hang_float
        lda tip_x
        sec
        sbc #4
        sta float_x
        lda tip_y
        clc
        adc #43
        sta float_y
        rts
; 16-step straight path from the float to goal, in 8.8 fixed point.
aim
        ldx #1
aim_axis
        lda float_x,x
        sta pos_hi,x
        lda #$80
        sta pos_lo,x
        lda goal_x,x
        sec
        sbc float_x,x
        sta inc_lo,x
        lda #0
        sbc #0
        sta inc_hi,x
        ldy #4
aim_shift
        asl inc_lo,x
        rol inc_hi,x
        dey
        bne aim_shift
        dex
        bpl aim_axis
        rts
path_add
        ldx #1
path_axis
        clc
        lda pos_lo,x
        adc inc_lo,x
        sta pos_lo,x
        lda pos_hi,x
        adc inc_hi,x
        sta pos_hi,x
        sta float_x,x
        dex
        bpl path_axis
        rts

render
        jsr background
        lda buffer
        asl
        asl
        asl
        asl
        ora #$80
        sta draw_bank
        jsr draw_windows
        jsr draw_gauge
        jsr draw_starfield
        lda state
        cmp #STATE_GAME_OVER
        beq render_panel
        cmp #STATE_MENU
        bne render_fishing
render_panel
        jsr draw_meteor
        jsr draw_clouds
        jmp draw_menu
render_fishing
; Rod frame: wind-up while charging, swing while casting, rest otherwise.
        lda state
        cmp #2
        beq rod_cast
        cmp #3
        beq rod_rest
        cmp #5
        beq rod_rest
        lda #0
        ldx state
        cpx #1
        bne rod_idle
        lda charge
        lsr
        lsr
        lsr
        cmp #4
        bcc rod_idle
        lda #3
rod_idle
        jsr set_rod
        jsr hang_float
        jmp rod_ready
rod_rest
        lda #23
        jsr set_rod
        jmp rod_ready
rod_cast
        lda phase
        jsr set_rod
rod_ready
; Out in the sky the float is far away, so clouds pass in front of it.
        lda #0
        sta float_far
        lda state
        cmp #2
        bne far_state
        lda phase
        cmp #FLIGHT_START
        bcs far_float
        bcc far_done
far_state
        cmp #3
        beq far_float
        cmp #5
        bne far_done
far_float
        inc float_far
        jsr draw_float
        jsr draw_bait
far_done
        jsr draw_meteor
        jsr draw_clouds
        lda #253
        sta color
        jsr draw_points
; The line shows while casting, reeling and at rest, not while the float waits.
        lda state
        cmp #5
        beq near_float
        jsr draw_line
near_float
        lda float_far
        bne win_display
        jsr draw_float
        jsr draw_bait
win_display
render_done
        rts

draw_points
point_loop
        ldy #0
        lda (points),y
        sta offset
        iny
        lda (points),y
        cmp #$ff
        beq points_done
        sta offset+1
        jsr plot_offset
        clc
        lda points
        adc #2
        sta points
        bcc point_loop
        inc points+1
        jmp point_loop
points_done
        rts

; Menu panel: dark fill with rails, title, three rows, cursor and help.
; It is drawn into spare VRAM at $60000 (same 320 stride) only after a
; change, then one blit copies it into every frame.
draw_menu
        lda menu_dirty
        beq menu_copy
        lda #0
        sta menu_dirty
        lda draw_bank
        pha
        lda #$e0
        sta draw_bank
        lda #6
        sta blit_bank
        lda state
        cmp #STATE_GAME_OVER
        bne compose_pause_menu
        jsr compose_results
        jmp panel_composed
compose_pause_menu
        jsr compose_menu
panel_composed
        pla
        sta draw_bank
menu_copy
        lda buffer
        sta blit_bank
        mwa #menu_blit points
        jmp run_blit
compose_menu
        mwa #panel_blit points
        jsr run_blit
        mwa #rail_top points
        jsr run_blit
        mwa #rail_bottom points
        jsr run_blit
        jsr draw_menu_inventory
        lda #0
        jsr row_color
        ldx #0
        jsr draw_text
        lda #1
        jsr row_color
        pha
        lda cloud_level
        clc
        adc #1
        tax
        pla
        jsr draw_text
        lda #2
        jsr row_color
        ldx #4
        jsr draw_text
        lda #3
        jsr row_color
        pha
        lda difficulty
        clc
        adc #5
        tax
        pla
        jsr draw_text
        lda #4
        jsr row_color
        pha
        lda sound_active
        clc
        adc #8
        tax
        pla
        jsr draw_text
        lda menu_row
        clc
        adc #10
        tax
        lda #250
draw_text
        sta color
        lda menu_lo,x
        sta points
        lda menu_hi,x
        sta points+1
        jmp draw_points
row_color
        cmp menu_row
        beq row_bright
        lda #251
        rts
row_bright
        lda #252
        rts
; Copies the 21-byte blitter command at points into the current buffer.
run_blit
        jsr blwait
        lda #$ff
        ldy #$5f
        sta (vb),y
        ldy #20
run_blit_copy
        lda (points),y
        sta $9000,y
        dey
        bpl run_blit_copy
        lda blit_bank
        sta $9008
        lda #1
        ldy #$53
        sta (vb),y
        jmp blwait
PANEL_X = 80
PANEL_Y = 54
PANEL_W = 160
PANEL_H = 84
panel_blit dta 0,0,0,a(0),0,<(PANEL_Y*320+PANEL_X),>(PANEL_Y*320+PANEL_X),0,a(320),1,a(PANEL_W-1),PANEL_H-1,0,249,0,0,0,0
rail_top dta 0,0,0,a(0),0,<((PANEL_Y-1)*320+PANEL_X),>((PANEL_Y-1)*320+PANEL_X),0,a(320),1,a(PANEL_W-1),0,0,251,0,0,0,0
menu_blit dta <((PANEL_Y-1)*320+PANEL_X),>((PANEL_Y-1)*320+PANEL_X),6,a(320),1,<((PANEL_Y-1)*320+PANEL_X),>((PANEL_Y-1)*320+PANEL_X),0,a(320),1,a(PANEL_W-1),PANEL_H+1,$ff,0,0,0,0,0
rail_bottom dta 0,0,0,a(0),0,<((PANEL_Y+PANEL_H)*320+PANEL_X),>((PANEL_Y+PANEL_H)*320+PANEL_X),0,a(320),1,a(PANEL_W-1),0,0,251,0,0,0,0

; Unlabelled spring gauge: two rails, coils every fourth column.
GAUGE_X = 279
draw_gauge
        lda state
        cmp #1
        bne gauge_done
        lda #251
        sta color
        ldx #GAUGE_MAX+1
gauge_rail
        txa
        clc
        adc #<(4*320+GAUGE_X)
        sta offset
        lda #>(4*320+GAUGE_X)
        adc #0
        sta offset+1
        jsr plot_offset
        clc
        lda offset
        adc #<(6*320)
        sta offset
        lda offset+1
        adc #>(6*320)
        sta offset+1
        jsr plot_offset
        dex
        bpl gauge_rail
        ldx charge
        beq gauge_done
gauge_column
        dex
        lda #250
        sta color
        txa
        and #3
        cmp #3
        bne gauge_coil
        lda #252
        sta color
gauge_coil
        txa
        clc
        adc #<(5*320+GAUGE_X)
        sta offset
        lda #>(5*320+GAUGE_X)
        adc #0
        sta offset+1
        lda #5
        sta gauge_rows
gauge_row
        jsr plot_offset
        clc
        lda offset
        adc #<320
        sta offset
        lda offset+1
        adc #>320
        sta offset+1
        dec gauge_rows
        bne gauge_row
        txa
        bne gauge_column
gauge_done
        rts

; Straight charcoal line from the rod tip to the float, 8-bit coordinates.
draw_line
        lda #254
        sta color
        lda tip_x
        sta px
        lda tip_y
        sta py
        ldx #0
line_axis
        lda float_x,x
        sec
        sbc tip_x,x
        ldy #1
        bcs line_delta
        eor #$ff
        adc #1
        ldy #$ff
line_delta
        sta line_dx,x
        tya
        sta line_sx,x
        inx
        cpx #2
        bne line_axis
        lda line_dx
        cmp line_dy
        bcc line_steep
        sta line_count
        lsr
        sta line_acc
shallow_loop
        jsr plot_xy
        lda line_count
        beq line_done
        dec line_count
        clc
        lda px
        adc line_sx
        sta px
        lda line_acc
        clc
        adc line_dy
        bcs shallow_y
        cmp line_dx
        bcc shallow_keep
shallow_y
        sbc line_dx
        sta line_acc
        clc
        lda py
        adc line_sy
        sta py
        jmp shallow_loop
shallow_keep
        sta line_acc
        jmp shallow_loop
line_steep
        lda line_dy
        sta line_count
        lsr
        sta line_acc
steep_loop
        jsr plot_xy
        lda line_count
        beq line_done
        dec line_count
        clc
        lda py
        adc line_sy
        sta py
        lda line_acc
        clc
        adc line_dx
        bcs steep_x
        cmp line_dy
        bcc steep_keep
steep_x
        sbc line_dy
        sta line_acc
        clc
        lda px
        adc line_sx
        sta px
        jmp steep_loop
steep_keep
        sta line_acc
        jmp steep_loop
line_done
        rts

; All sixteen sprite variants share a top-centre attachment and lift rotation.
draw_float
        lda state
        cmp #5
        bne bobber_setup
        lda bite_stage
        cmp #2
        bne bobber_setup
        lda bait_present
        beq bobber_setup
        rts
bobber_setup
        ldx bobber_selected
        lda bobber_visible,x
        clc
        adc base_y
        sta bobber_waterline
        lda bobber_lo,x
        sta bob_ptr
        lda bobber_hi,x
        sta bob_ptr+1
bobber_pixel
        ldy #2
        lda (bob_ptr),y
        beq bobber_end
        sta color
        dey
        lda (bob_ptr),y
        sta bob_dy
        dey
        lda (bob_ptr),y
        sta bob_dx
        lda float_x
        clc
        adc bob_dx
        sta px
        lda float_y
        clc
        adc bob_dy
        sta py
        lda state
        cmp #5
        bne bobber_visible_pixel
        lda py
        cmp bobber_waterline
        bcs bobber_skip_pixel
bobber_visible_pixel
        jsr plot_xy
bobber_skip_pixel
        clc
        lda bob_ptr
        adc #3
        sta bob_ptr
        bcc bobber_pixel
        inc bob_ptr+1
        jmp bobber_pixel
bobber_end
float_done
        rts
 ; Four-pixel luminous worm on a three-pixel leader below the bobber.
; Palette cycling is slow (32 PAL frames per step); no fishing RNG is used.
draw_bait
        lda state
        cmp #5
        bne bait_full_height
        rts
bait_full_height
        ldx bobber_selected
        lda bobber_height,x
        clc
        adc float_y
bait_anchor
        sta py
        lda float_x
        sta px
        lda #254
        sta color
        jsr plot_xy
        inc py
        jsr plot_xy
        inc py
        jsr plot_xy
        inc py
        lda caught
        cmp #$ff
        beq bait_or_hook
        jmp draw_caught_star
bait_or_hook
        lda bait_present
        bne bait_worm
        lda #251
        sta color
        jsr plot_xy
        inc py
        jsr plot_xy
        inc px
        jsr plot_xy
        dec py
        jmp plot_xy
bait_worm
        lda frame
        lsr
        lsr
        lsr
        and #28
        ldx worm_type
        beq bait_palette_ready
        clc
        adc #32
bait_palette_ready
        tax
        lda bait_colors,x
        sta color
        jsr plot_xy
        inc py
        inx
        lda bait_colors,x
        sta color
        jsr plot_xy
        inc px
        inc py
        inx
        lda bait_colors,x
        sta color
        jsr plot_xy
        inc py
        inx
        lda bait_colors,x
        sta color
        jsr plot_xy
bait_draw_done
        rts
bait_colors
        dta 248,247,254,251
        dta 255,250,251,252
        dta 250,251,252,255
        dta 251,252,255,250
        dta 252,255,250,251
        dta 251,248,247,254
        dta 254,248,247,254
        dta 254,247,254,254
        dta 254,251,254,251
        dta 251,252,251,252
        dta 252,251,252,251
        dta 251,252,251,252
        dta 252,252,251,252
        dta 251,254,251,254
        dta 254,251,254,251
        dta 254,254,251,254

; Four brilliant core pixels with a pulsing square halo, never a star silhouette.
draw_caught_star
        lda px
        sta catch_left
        lda py
        sta catch_top
        ldx #0
catch_square_loop
        lda catch_dx,x
        clc
        adc catch_left
        sta px
        lda catch_dy,x
        clc
        adc catch_top
        sta py
        lda #252
        cpx #4
        bcc catch_square_color
        lda frame
        lsr
        lsr
        lsr
        lsr
        lsr
        and #7
        tay
        lda catch_glow,y
catch_square_color
        sta color
        jsr plot_xy
        inx
        cpx #12
        bne catch_square_loop
        rts
catch_dx dta 0,1,0,1,255,2,255,2,0,1,0,1
catch_dy dta 0,0,1,1,0,0,1,1,255,255,2,2
catch_glow dta 254,251,250,252,250,251,254,254
catch_left dta 0
catch_top dta 0
bite_status dta 5,7,8,10,11,12,17,18

; Slow, independent lighting randomness does not change fishing/bite outcomes.
update_lights
        ldx #WINDOW_COUNT-1
light_tick
        lda light_flicker,x
        beq light_timer_tick
        dec light_flicker,x
light_timer_tick
        lda light_modes,x
        beq light_next
        dec light_timer,x
        bne light_next
        lda light_seed
        asl
        bcc light_seed_ready
        eor #$1d
light_seed_ready
        sta light_seed
        and #127
        clc
        adc #64
        sta light_timer,x
        lda light_modes,x
        cmp #2
        beq candle_light
        lda light_on,x
        eor #2
        jmp light_switch
candle_light
        lda #2
light_switch
        sta light_on,x
        beq light_next
        lda #6
        sta light_flicker,x
light_next
        dex
        bpl light_tick
        rts

; Full 17-bit pixel addresses: foreground windows are below the 64K boundary.
; Reuse the MEMAC drawing window, including the second 64K of each framebuffer.
draw_windows
        ldx #WINDOW_COUNT-1
window_next
        stx window_index
        lda light_on,x
        beq window_skip
        lda #248
        sta color
        lda light_flicker,x
        and #1
        beq window_bright
        dec color
window_bright
        lda window_lo,x
        sta points
        lda window_hi,x
        sta points+1
window_pixel
        ldy #0
        lda (points),y
        cmp #255
        beq window_skip
        ora draw_bank
        ldy #$5f
        sta (vb),y
        ldy #1
        lda (points),y
        sta dst
        iny
        lda (points),y
        sta dst+1
        lda color
        ldy #0
        sta (dst),y
        clc
        lda points
        adc #3
        sta points
        bcc window_pixel
        inc points+1
        jmp window_pixel
window_skip
        ldx window_index
        dex
        bpl window_next
        rts

; Restore complete background into hidden buffer using VBXE blitter.
background
        jsr blwait
        lda #$ff
        ldy #$5f
        sta (vb),y
        lda buffer
        sta blit_data+8
        ldx #20
copy_blit
        lda blit_data,x
        sta $9000,x
        dex
        bpl copy_blit
        lda #1
        ldy #$53
        sta (vb),y
blwait
        ldy #$53
        lda (vb),y
        bne blwait
        rts
; Plot an offset within the first 64K of the current framebuffer.
; All dynamic graphics remain above y=200. X/Y are preserved except Y.
plot_offset
        lda offset+1
        lsr
        lsr
        lsr
        lsr
        ora draw_bank
        ldy #$5f
        sta (vb),y
        lda offset+1
        and #15
        ora #$90
        sta dst+1
        lda offset
        sta dst
        ldy #0
        lda color
        sta (dst),y
        rts
plot_xy
        lda py
        lsr
        lsr
        clc
        adc py
        sta offset+1
        lda py
        and #3
        tay
        lda times64,y
        clc
        adc px
        sta offset
        bcc xy_ready
        inc offset+1
xy_ready
        jmp plot_offset
star
        lda px
        sta star_origin_x
        lda py
        sta star_origin_y
        ldx #0
star_pixel_loop
        lda star_origin_x
        clc
        adc star_dx,x
        sta px
        lda star_origin_y
        clc
        adc star_dy,x
        sta py
        jsr plot_xy
        inx
        cpx #STAR_PIXELS
        bne star_pixel_loop
        lda star_origin_x
        sta px
        lda star_origin_y
        sta py
        rts

digit
        sta digit_value
        lda px
        sta digit_x
        lda py
        sta digit_y
        lda digit_value
        asl
        asl
        clc
        adc digit_value
        sta digit_index
        lda #5
        sta digit_rows
digit_row
        ldx digit_index
        lda digit_data,x
        sta digit_bits
        lda #3
        sta digit_cols
        lda digit_x
        sta px
digit_pixel
        lda digit_bits
        and #4
        beq digit_blank
        jsr plot_xy
digit_blank
        asl digit_bits
        inc px
        dec digit_cols
        bne digit_pixel
        inc py
        inc digit_index
        dec digit_rows
        bne digit_row
        lda digit_x
        sta px
        lda digit_y
        sta py
        rts

; XDLC_ATT: bits 5:4 select overlay palette 1; bits 1:0 select 320px.
; $01 would select the default Atari palette 0 instead of our RGB colours.
xdl_data
        dta $62,$88,239,0,0,2,$40,$01,$11,$ff
        :6 dta 0
        dta $62,$88,239,0,0,4,$40,$01,$11,$ff
        :6 dta 0
blit_data
        dta 0,0,0,a(320),1,0,0,2,a(320),1,a(319),239,$ff,0,0,0,0,0
frame dta 0
wait_frame dta 0
buffer dta 2
draw_bank dta $a0
state dta 0
charge dta 0
charge_ticks dta 0
power dta 0
phase dta 0
score dta 0
casts dta 0
ticks dta 0
pressed dta 0
caught dta $ff
gauge_dir dta 1
spring_mode dta SPRING_GAUGE
gauge_rows dta 0
target_x dta 0
target_y dta 0
base_x dta 0
base_y dta 0
; Paired x,y variables: routines index them with X=0 (x) or 1 (y).
float_x dta 0
float_y dta 0
goal_x dta 0
goal_y dta 0
tip_x dta 0
tip_y dta 0
pos_lo dta 0,0
pos_hi dta 0,0
inc_lo dta 0,0
inc_hi dta 0,0
line_dx dta 0
line_dy dta 0
line_sx dta 0
line_sy dta 0
line_count dta 0
line_acc dta 0
tilt dta 0
float_far dta 0
dirs dta 0
previous_dirs dta 0
dir_edge dta 0
menu_row dta 0
menu_dirty dta 1
blit_bank dta 2
; Cloud setting kept across games: 0 none, 1 medium, 2 heavy.
cloud_level dta 1
cloud_counts dta 0,3,6
star_origin_x dta 0
star_origin_y dta 0
previous_pressed dta 0
press_edge dta 0
random_seed dta 1
win_count dta 0
px dta 0
py dta 0
color dta 250
offset dta a(0)
times64 dta 0,64,128,192
digit_value dta 0
digit_index dta 0
digit_bits dta 0
digit_rows dta 0
digit_cols dta 0
digit_x dta 0
digit_y dta 0
light_seed dta 1
window_index dta 0
light_on :WINDOW_COUNT dta 0
light_timer :WINDOW_COUNT dta 0
light_flicker :WINDOW_COUNT dta 0
load_bank dta 0

; Reused banked XEX upload scheme from the local VBXE slideshow.
upload_bank
        jsr detect
        bcc upload_done
        lda #0
        sta $022f
        lda #$98
        ldy #$5e
        sta (vb),y
        lda load_bank
        ora #$80
        ldy #$5f
        sta (vb),y
        mwa #$a000 src
        mwa #$9000 dst
        ldx #16
        ldy #0
upload_byte
        lda (src),y
        sta (dst),y
        iny
        bne upload_byte
        inc src+1
        inc dst+1
        dex
        bne upload_byte
        inc load_bank
        lda #0
        ldy #$5f
        sta (vb),y
upload_done
        rts
detect
        lda #0
        sta vb
        lda #$d6
        sta vb+1
        ldy #$40
        lda (vb),y
        cmp #$10
        beq found
        inc vb+1
        lda (vb),y
        cmp #$10
        beq found
        clc
        rts
found   sec
        rts
unsupported
        cli
        lda #$22
        sta $022f
        ldx #0
        lda #9
        sta $0342,x
        mwa #error_text $0344,x
        mwa #error_length $0348,x
        jsr $e456
        jmp *
error_text dta $7d,c'STAR FISHER requires Atari XL/XE + VBXE FX.',$9b
error_length = *-error_text
; Load-time copy of a staged sample chunk from $A000 into RAM under the OS.
; NMIs and IRQs stay off while the OS ROM is switched out.
os_copy
        lda #0
        sta $d40e
        sei
        lda $d301
        pha
        and #$fe
        sta $d301
        mwa #$a000 src
        mwa os_copy_dest dst
        ldx os_copy_pages
        ldy #0
os_copy_byte
        lda (src),y
        sta (dst),y
        iny
        bne os_copy_byte
        inc src+1
        inc dst+1
        dex
        bne os_copy_byte
        pla
        sta $d301
        cli
        lda #$40
        sta $d40e
        rts
os_copy_dest dta a(0)
os_copy_pages dta 0
basic_off
        lda $d301
        ora #2
        sta $d301
        lda #0
        sta $022f
        rts
        icl 'menu-ui.asm'
        icl 'fishing.asm'
        icl 'bobber-menu.asm'
        icl 'sky.asm'
        icl 'sound.asm'
        icl 'gen/tables.asm'
; $7800-$8FFF holds recorded sounds (tools/samples.py REGIONS).
        .if * > $7800
        .error "Code overlaps sample RAM at $7800"
        .endif
        ini basic_off
        icl 'gen/loads.asm'
        icl 'gen/samples.asm'
        run main
