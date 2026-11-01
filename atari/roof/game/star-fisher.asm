; Star Fisher - native Atari XL/XE + VBXE FX, PAL 320x240.
; Boot/MEMAC loader follows ../lich/intro-slideshow; double buffered rendering.
        opt h+
vb = $80
src = $82
dst = $84
points = $86
line_points = $88
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
        sta $d208
        sta $d201
        sta $d203
        sta $d205
        sta $d207
        lda #3
        sta $d20f
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
main_loop
        lda frame
wait_tick
        cmp frame
        beq wait_tick
        jsr input
        jsr update
        jsr render
; Present only on vertical blank, then draw to the other buffer.
        lda frame
wait_present
        cmp frame
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
        lda #0
        sta $d40f
        inc frame
        pla
        rti
irq     rti

; A ($3f), Space ($21), or joystick fire. R ($28) restarts.
input
        lda pressed
        sta previous_pressed
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
        cmp #$28
        bne not_reset
        jsr reset_game
        rts
not_reset
        cmp #$3f
        beq key_cast
        cmp #$21
        bne input_done
key_cast
        lda #1
        sta pressed
input_done
        lda previous_pressed
        eor #$ff
        and pressed
        sta press_edge
        rts
reset_game
        lda #0
        sta state
        sta charge
        sta power
        sta phase
        sta score
        sta casts
        sta ticks
        sta tone
        sta $d201
        lda #$ff
        sta caught
        sta previous_pressed
        lda #0
        sta pressed
        sta press_edge
        sta bite_timer
        lda $d20a
        ora #1
        sta random_seed
        ldx #2
reset_stars
        jsr spawn_star
        dex
        bpl reset_stars
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
spawn_star
        jsr random_byte
        cmp #224
        bcs spawn_star
        clc
        adc #16
        sta stars_x,x
spawn_y
        jsr random_byte
        and #$7f
        cmp #96
        bcs spawn_y
        clc
        adc #32
        sta stars_y,x
        jsr random_byte
        and #63
        clc
        adc #28
        sta stars_life,x
        lda #1
        sta stars_active,x
        rts
update_stars
        ldx #2
star_life_loop
        dec stars_life,x
        bne star_life_next
        jsr spawn_star
star_life_next
        ; Two of the three stars drift slowly between their random appearances.
        cpx #0
        beq star_motion_done
        lda ticks
        and #15
        bne star_motion_done
        lda stars_life,x
        cmp #12
        bcc star_motion_done
        cpx #1
        bne star_fly_left
        inc stars_x,x
        lda stars_x,x
        cmp #240
        bcc star_motion_done
        lda #16
        sta stars_x,x
        bne star_motion_done
star_fly_left
        dec stars_x,x
        lda stars_x,x
        cmp #16
        bcs star_motion_done
        lda #239
        sta stars_x,x
star_motion_done
        dex
        bpl star_life_loop
        rts
new_wait
        lda #5
        sta state
        lda #$ff
        sta caught
        jsr random_byte
        and #63
        clc
        adc #60
        sta wait_timer
        rts

update
        jsr update_lights
        lda tone
        beq sound_off
        dec tone
        bne sound_done
sound_off
        lda #0
        sta $d201
sound_done
        lda state
        cmp #4
        bne not_won
        rts
not_won
        jsr update_stars
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
        bne state_not_reel
        jmp reeling
state_not_reel
        cmp #5
        bne state_bite
        jmp waiting
state_bite
        jmp biting

idle
        lda press_edge
        beq update_done
        lda #1
        sta state
        lda #0
        sta charge
update_done
        rts
charging
        lda pressed
        beq launch
        lda charge
        cmp #60
        bcs update_done
        inc charge
        rts
launch
        lda charge
        ldx #0
        cmp #20
        bcc power_ready
        inx
        cmp #40
        bcc power_ready
        inx
power_ready
        stx power
        lda #0
        sta phase
        lda #2
        sta state
        inc casts
        lda #$ff
        sta caught
        lda #90
        sta $d200
        lda #$a3
        sta $d201
        lda #3
        sta tone
        rts
casting
        inc phase
        lda phase
        cmp #24
        bcs cast_landed
        rts
cast_landed
        lda #23
        sta phase
        jsr select_pose
        jmp new_wait
; Float remains out indefinitely: bites time out back to waiting, never auto-reel.
waiting
        lda press_edge
        beq keep_waiting
        lda #3
        sta state
        rts
keep_waiting
        dec wait_timer
        beq start_bite
        rts
start_bite
; One of the blinking stars appears at the bait, then the float dips.
        lda hook_x
        sta stars_x
        lda hook_y
        sta stars_y
        lda #1
        sta stars_active
        lda #80
        sta stars_life
        lda #6
        sta state
        lda #48
        sta bite_timer
        lda #55
        sta $d200
        lda #$a5
        sta $d201
        lda #4
        sta tone
        rts
biting
        lda press_edge
        beq bite_wait
        lda #0
        sta caught
        sta stars_active
        lda #3
        sta state
        rts
bite_wait
        dec bite_timer
        bne bite_done
        ldx #0
        jsr spawn_star
        jmp new_wait
bite_done
        rts

reeling
        lda phase
        cmp #5
        bcc landed
        dec phase
        rts
landed
        lda caught
        cmp #$ff
        beq empty_cast
        inc score
        ldx #0
        jsr spawn_star
        lda #35
        sta $d200
        lda #$a7
        sta $d201
        lda #6
        sta tone
empty_cast
        lda #$ff
        sta caught
        lda #0
        sta state
        sta phase
        sta charge
        lda score
        cmp #5
        bcs won_game
        rts
won_game
        lda #4
        sta state
        rts
select_pose
        ldx power
        lda pose_base,x
        clc
        adc phase
        tax
        lda hook_x_table,x
        sta hook_x
        lda hook_y_table,x
        sta hook_y
        lda pose_lo,x
        sta line_points
        lda pose_hi,x
        sta line_points+1
        ldx phase
        lda rod_lo,x
        sta points
        lda rod_hi,x
        sta points+1
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
; Charge and goal HUD in reserved strips.
        lda #250
        sta color
        lda #153
        sta px
        lda #5
        sta py
        lda score
        jsr digit
        lda #167
        sta px
        lda #5
        jsr digit
        lda #251
        sta color
        lda #218
        sta px
        lda casts
reduce_casts
        cmp #10
        bcc cast_digit
        sec
        sbc #10
        jmp reduce_casts
cast_digit
        jsr digit
        lda state
        cmp #1
        bne no_charge
        ldx charge
        beq no_charge
charge_bar
        txa
        clc
        adc #251
        sta offset
        lda #0
        adc #0
        sta offset+1
        ; y=11 at x=251..311
        clc
        lda offset
        adc #<3520
        sta offset
        lda offset+1
        adc #>3520
        sta offset+1
        jsr plot_offset
        dex
        bne charge_bar
no_charge
; Three stars blink, disappear and reappear at new random sky positions.
        ldx #2
render_stars
        stx star_index
        lda stars_active,x
        beq skip_star
        lda stars_life,x
        cmp #12
        bcc skip_star
        lda stars_x,x
        sta px
        lda stars_y,x
        sta py
        lda stars_life,x
        and #4
        beq star_gold
        lda #252
        bne star_color
star_gold
        lda #250
star_color
        sta color
        jsr star
skip_star
        ldx star_index
        dex
        bpl render_stars
        lda state
        cmp #2
        beq draw_cast
        cmp #3
        beq draw_cast
        cmp #5
        beq draw_cast
        cmp #6
        beq draw_cast
        lda #0
        sta power
        sta phase
        lda state
        cmp #1
        bne idle_pose
        lda charge
        lsr
        lsr
        lsr
        lsr
        and #3
        sta phase
idle_pose
        jsr select_pose
        jmp draw_rod
draw_cast
        jsr select_pose
draw_rod
        lda #253
        sta color
        jsr draw_points
        mwa line_points points
        lda #254
        sta color
        jsr draw_points
        jmp rod_done
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
rod_done
        lda hook_x
        sta px
        lda hook_y
        sta py
        lda caught
        cmp #$ff
        beq bare_hook
        lda #252
        sta color
        jsr star
        jmp win_display
bare_hook
        jsr draw_float
win_display
        ldx state
        lda status_lo,x
        sta points
        lda status_hi,x
        sta points+1
        lda #250
        sta color
        jsr draw_points
        lda state
        cmp #4
        bne render_done
        mwa #win_banner points
        lda #252
        sta color
        jsr draw_points
; Five bright stars at screen centre celebrate completion.
        lda #128
        sta px
        lda #24
        sta py
        lda #252
        sta color
        ldx #5
win_stars
        stx win_count
        jsr star
        clc
        lda px
        adc #16
        sta px
        ldx win_count
        dex
        bne win_stars
render_done
        rts

; A small two-colour fishing float. The line stays attached at its top.
draw_float
        lda #255
        sta color
        jsr plot_xy
        inc py
        dec px
        jsr plot_xy
        inc px
        jsr plot_xy
        inc px
        jsr plot_xy
        dec px
        inc py
        lda #252
        sta color
        jsr plot_xy
        inc py
        jsr plot_xy
        lda state
        cmp #6
        bne float_done
        lda ticks
        and #2
        beq float_done
        ; Flashing expanding cross signals a bite; no automatic retrieval.
        inc py
        jsr star
float_done
        rts

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

xdl_data
        dta $62,$88,239,0,0,2,$40,$01,$01,$ff
        :6 dta 0
        dta $62,$88,239,0,0,4,$40,$01,$01,$ff
        :6 dta 0
blit_data
        dta 0,0,0,a(320),1,0,0,2,a(320),1,a(319),239,$ff,0,0,0,0,0
frame dta 0
buffer dta 2
draw_bank dta $a0
state dta 0
charge dta 0
power dta 0
phase dta 0
score dta 0
casts dta 0
ticks dta 0
tone dta 0
pressed dta 0
caught dta $ff
hook_x dta 0
hook_y dta 0
star_index dta 0
star_origin_x dta 0
star_origin_y dta 0
previous_pressed dta 0
press_edge dta 0
random_seed dta 1
wait_timer dta 0
bite_timer dta 0
win_count dta 0
px dta 0
py dta 0
color dta 250
offset dta a(0)
pose_base dta 0,24,48
times64 dta 0,64,128,192
stars_x :3 dta 0
stars_y :3 dta 0
stars_active :3 dta 1
stars_life :3 dta 0
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
basic_off
        lda $d301
        ora #2
        sta $d301
        lda #0
        sta $022f
        rts
        icl 'gen/tables.asm'
        .if * > $9000
        .error "Code overlaps MEMAC window"
        .endif
        ini basic_off
        icl 'gen/loads.asm'
        run main
