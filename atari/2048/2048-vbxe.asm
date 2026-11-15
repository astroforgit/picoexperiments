; PicoRacer-2048: Atari XL/XE + VBXE FX adaptation.
; MADS 2.x. Eight courses resampled from the original PICO-8 map bytes.

SDMCTL=$022f
PORTA=$d300
PORTB=$d301
STRIG0=$d010
STRIG1=$d011
CONSOL=$d01f
RTCLOK=$14
CH=$02fc
VCTL=$d640
XDL0=$d641
XDL1=$d642
XDL2=$d643
CSEL=$d644
PSEL=$d645
CR=$d646
CG=$d647
CB=$d648
BLADR0=$d650
BLADR1=$d651
BLADR2=$d652
BLITTER=$d653
MEMAC=$d65e
BANKSEL=$d65f
MEMW=$9000

ptr=$cb
zp2=$cd
text_ptr=$cf
track_ptr=$d1

        org $2000
main    lda PORTB
        ora #2
        sta PORTB
        jsr detect
        bcs detected
        lda #$34
        sta $02c8
        jmp *
detected
        lda #0
        sta SDMCTL
        sta $d400
        lda #$98
reg_memac sta MEMAC
        jsr setup_xdl
        jsr palette
        jsr upload_font
        lda #0
reg_bl0 sta BLADR0
        lda #$f1
reg_bl1 sta BLADR1
        lda #7
reg_bl2 sta BLADR2
        lda #3
reg_vctl sta VCTL
        lda #0
reg_xdl0 sta XDL0
        lda #$f0
reg_xdl1 sta XDL1
        lda #7
reg_xdl2 sta XDL2
        lda #0
        sta mode
        sta old_input
        lda #5
        sta framebuffer_bank
        lda $d014               ; GTIA PAL register
        and #$0e
        beq pal_timer
        lda #30                ; one update per two NTSC frames
        bne set_timer
pal_timer
        lda #25                ; one update per two PAL frames
set_timer
        sta timer_rate
loop    lda RTCLOK
wait_tick
        cmp RTCLOK
        beq wait_tick
        jsr read_input
        lda mode
        beq menu_loop
        cmp #2
        beq result_loop
        jsr update_game
        jsr draw_game
        jsr present_frame
        jmp loop
menu_loop
        jsr update_menu
        jsr draw_menu
        jsr present_frame
        jmp loop
result_loop
        lda input_edge
        and #16
        beq result_draw
        lda #0
        sta mode
result_draw
        jsr draw_result
        jsr present_frame
        jmp loop

        icl 'common-vbxe.asm'

update_menu
        lda input_edge
        and #1
        beq menu_down
        lda menu_option
        beq menu_down
        dec menu_option
menu_down
        lda input_edge
        and #2
        beq menu_value
        lda menu_option
        cmp #2
        bcs menu_value
        inc menu_option
menu_value
        lda input_edge
        and #12
        beq menu_start
        lda menu_option
        beq menu_change_mode
        cmp #1
        beq menu_change_course
        lda input_edge
        and #4
        beq car_next
        lda car_class
        beq menu_start
        dec car_class
        jmp menu_start
car_next
        lda car_class
        cmp #2
        bcs menu_start
        inc car_class
        jmp menu_start
menu_change_course
        lda input_edge
        and #4
        beq course_next
        lda course
        beq menu_start
        dec course
        jmp menu_start
course_next
        lda course
        cmp #7
        bcs menu_start
        inc course
        jmp menu_start
menu_change_mode
        lda game_type
        eor #1
        sta game_type
menu_start
        lda input_edge
        and #16
        beq menu_done
        jsr start_game
menu_done rts

start_game
        lda #1
        sta mode
        lda #0
        sta seg
        sta seg+1
        sta lap
        sta speed
        sta lane
        sta tick_count
        sta move_count
        sta frame_count
        sta seconds
        sta seconds+1
        sta ai_lap
        sta old_heading
        lda #3
        sta ai_seg
        lda #0
        sta ai_seg+1
        lda #100
        sta nitro
        lda course
        asl
        tax
        lda course_view_index,x
        sta track_ptr
        lda course_view_index+1,x
        sta track_ptr+1
        lda course_lengths,x
        sta course_length
        lda course_lengths+1,x
        sta course_length+1
        rts

update_game
        inc tick_count
        lda tick_count
        cmp timer_rate
        bcc not_second
        lda #0
        sta tick_count
        inc seconds
        bne not_second
        inc seconds+1
not_second
        lda input
        and #1
        beq no_accel
        lda frame_count
        and #3
        bne no_accel
        lda speed
        ldx car_class
        cmp max_speeds,x
        bcs no_accel
        inc speed
no_accel
        lda input
        and #2
        beq no_brake
        lda speed
        beq no_brake
        dec speed
no_brake
        lda frame_count
        and #1
        bne no_steer
        lda input
        and #4
        beq no_left
        dec lane
no_left lda input
        and #8
        beq no_steer
        inc lane
no_steer
        lda input
        and #16
        beq no_boost
        lda nitro
        beq no_boost
        dec nitro
        lda #10
        sta speed
        jmp nitro_done
no_boost
        lda speed
        cmp #8
        bcc boost_decay_done
        lda frame_count
        and #3
        bne boost_decay_done
        dec speed
boost_decay_done
        lda input
        and #16
        bne nitro_done
        lda frame_count
        and #3
        bne nitro_done
        lda nitro
        cmp #100
        bcs nitro_done
        inc nitro
nitro_done
        inc frame_count
        lda lane
        cmp #9
        bcc lane_ok
        cmp #128
        bcs lane_negative
        lda #8
        sta lane
        jmp lane_hit
lane_negative
        cmp #248
        bcs lane_ok
        lda #248
        sta lane
lane_hit
        lda speed
        beq lane_ok
        dec speed
lane_ok
        lda speed
        beq update_ai
        clc
        adc move_count
        sta move_count
        cmp #12
        bcc update_ai
        sec
        sbc #12
        sta move_count
        inc seg
        bne compare_lap
        inc seg+1
compare_lap
        lda seg+1
        cmp course_length+1
        bcc update_ai
        bne next_lap
        lda seg
        cmp course_length
        bcc update_ai
next_lap
        lda #0
        sta seg
        sta seg+1
        inc lap
        lda lap
        cmp #3
        bcc update_ai
        lda #2
        sta mode
        lda #0
        sta winner
        jmp game_done
update_ai
        lda game_type
        bne game_done
        lda frame_count
        and #1
        bne game_done
        inc ai_seg
        bne compare_ai_lap
        inc ai_seg+1
compare_ai_lap
        lda ai_seg+1
        cmp course_length+1
        bcc game_done
        bne ai_next_lap
        lda ai_seg
        cmp course_length
        bcc game_done
ai_next_lap
        lda #0
        sta ai_seg
        sta ai_seg+1
        inc ai_lap
        lda ai_lap
        cmp #3
        bcc game_done
        lda #2
        sta mode
        lda #1
        sta winner
game_done rts

        icl 'vector-renderer.asm'

draw_hud
        lda lap
        clc
        adc #'1'
        sta hud_lap+4
        lda course
        clc
        adc #'1'
        sta hud_track+6
        lda speed
        cmp #10
        bcc speed_single
        lda #'1'
        sta hud_speed+6
        lda #'0'
        sta hud_speed+7
        jmp speed_ready
speed_single
        pha
        lda #'0'
        sta hud_speed+6
        pla
        clc
        adc #'0'
        sta hud_speed+7
speed_ready
        lda nitro
        ldx #0
nitro_10
        cmp #10
        bcc nitro_digits
        sec
        sbc #10
        inx
        bne nitro_10
nitro_digits
        txa
        clc
        adc #'0'
        sta hud_nitro+6
        lda seconds
        jsr decimal_3
        mwa #hud_lap text_ptr
        mwa #8 text_x
        lda #4
        sta text_y
        lda #9
        sta text_col
        jsr text
        mwa #hud_track text_ptr
        mwa #104 text_x
        jsr text
        mwa #hud_speed text_ptr
        mwa #240 text_x
        lda #145
        sta text_y
        jsr text
        mwa #hud_nitro text_ptr
        mwa #8 text_x
        lda #164
        sta text_y
        lda #8
        sta text_col
        jsr text
        mwa #hud_time text_ptr
        mwa #160 text_x
        jsr text
        mwa #hud_help text_ptr
        mwa #8 text_x
        lda #183
        sta text_y
        lda #6
        sta text_col
        jmp text
decimal_3
        ldx #0
dec_hundreds
        cmp #100
        bcc dec_tens
        sec
        sbc #100
        inx
        bne dec_hundreds
dec_tens
        txa
        clc
        adc #'0'
        sta hud_time+5
        lda seconds
        ; Lower two digits are calculated from the remaining byte.
        sec
        sbc hundreds_table,x
        ldx #0
dec_tens_loop
        cmp #10
        bcc dec_ones
        sec
        sbc #10
        inx
        bne dec_tens_loop
dec_ones
        pha
        txa
        clc
        adc #'0'
        sta hud_time+6
        pla
        clc
        adc #'0'
        sta hud_time+7
        rts
hundreds_table dta 0,100,200
hud_lap dta c'LAP 1/3',0
hud_track dta c'TRACK 1',0
hud_speed dta c'SPEED 00',0
hud_nitro dta c'NITRO 0',0
hud_time dta c'TIME 000',0
hud_help dta c'UP GAS  DOWN BRAKE  FIRE BOOST  STEER',0

draw_menu
        mwa #0 fx
        lda #0
        sta fy
        mwa #320 fw
        lda #200
        sta fh
        lda #0
        sta fc
        jsr fill
        ; Original cartridge sprite sheet: title, purple ground, yellow strip.
        mwa #$b000 bl_src
        lda #7
        sta bl_src+2
        mwa #128 bl_ssy
        lda #1
        sta bl_ssx
        mwa #320 bl_dsy
        lda #1
        sta bl_dsx
        mwa #127 bl_w
        lda #127
        sta bl_h
        lda #$ff
        sta bl_and
        lda #0
        sta bl_xor
        sta bl_mode
        mwa #16 fx
        lda #16
        sta fy
        jsr screen_address
        jsr blit
        jsr blwait
        lda framebuffer_bank
        asl
        asl
        asl
        asl
        sta pixel_base
        lda #16
        sta pixel_x_base
        jsr draw_minimap
        mwa #title text_ptr
        mwa #168 text_x
        lda #16
        sta text_y
        lda #8
        sta text_col
        jsr text
        mwa #label_mode text_ptr
        mwa #168 text_x
        lda #37
        sta text_y
        lda #6
        sta text_col
        lda menu_option
        bne mode_label_dim
        lda #9
        sta text_col
mode_label_dim
        jsr text
        lda game_type
        beq menu_ai
        mwa #menu_time text_ptr
        jmp menu_mode_draw
menu_ai mwa #menu_race text_ptr
menu_mode_draw
        mwa #168 text_x
        lda #49
        sta text_y
        lda #7
        sta text_col
        jsr text
        mwa #label_track text_ptr
        mwa #168 text_x
        lda #70
        sta text_y
        lda #6
        sta text_col
        lda menu_option
        cmp #1
        bne track_label_dim
        lda #9
        sta text_col
track_label_dim
        jsr text
        lda course
        asl
        tax
        lda course_names,x
        sta text_ptr
        lda course_names+1,x
        sta text_ptr+1
        mwa #168 text_x
        lda #82
        sta text_y
        lda #7
        sta text_col
        jsr text
        mwa #label_car text_ptr
        mwa #168 text_x
        lda #103
        sta text_y
        lda #6
        sta text_col
        lda menu_option
        cmp #2
        bne car_label_dim
        lda #9
        sta text_col
car_label_dim
        jsr text
        lda car_class
        asl
        tax
        lda car_names,x
        sta text_ptr
        lda car_names+1,x
        sta text_ptr+1
        mwa #168 text_x
        lda #115
        sta text_y
        lda #7
        sta text_col
        jsr text
        mwa #menu_help text_ptr
        mwa #168 text_x
        lda #144
        sta text_y
        lda #6
        sta text_col
        jsr text
        mwa #menu_change text_ptr
        mwa #168 text_x
        lda #157
        sta text_y
        jsr text
        mwa #menu_start_text text_ptr
        mwa #168 text_x
        lda #179
        sta text_y
        lda #8
        sta text_col
        jmp text
title dta c'PICO RACER 2048',0
label_mode dta c'MODE',0
label_track dta c'TRACK',0
label_car dta c'CAR',0
menu_race dta c'RACE VS AI',0
menu_time dta c'TIME ATTACK',0
menu_help dta c'UP DOWN SELECT',0
menu_change dta c'LEFT RIGHT CHANGE',0
menu_start_text dta c'FIRE TO RACE',0
car_names dta a(car_easy),a(car_medium),a(car_hard)
car_easy dta c'EASY',0
car_medium dta c'MEDIUM',0
car_hard dta c'HARD',0
course_names
        dta a(name0),a(name1),a(name2),a(name3)
        dta a(name4),a(name5),a(name6),a(name7)
name0 dta c'BERLIN',0
name1 dta c'VANCOUVER',0
name2 dta c'MELBOURNE',0
name3 dta c'DETROIT',0
name4 dta c'JAKARTA',0
name5 dta c'WELLINGTON',0
name6 dta c'HANOI',0
name7 dta c'OSAKA',0

draw_result
        jsr draw_game
        mwa #32 fx
        lda #45
        sta fy
        mwa #256 fw
        lda #60
        sta fh
        lda #4
        sta fc
        jsr fill
        lda winner
        beq player_win
        mwa #lost_text text_ptr
        jmp result_text
player_win
        mwa #won_text text_ptr
result_text
        mwa #80 text_x
        lda #58
        sta text_y
        lda #8
        sta text_col
        jsr text
        mwa #result_help text_ptr
        mwa #60 text_x
        lda #82
        sta text_y
        lda #1
        sta text_col
        jmp text
won_text dta c'RACE COMPLETE',0
lost_text dta c'RIVAL WINS',0
result_help dta c'FIRE TO RETURN TO MENU',0

mode dta 0
course dta 0
game_type dta 0
menu_option dta 0
car_class dta 0
max_speeds dta 6,7,8
seg dta a(0)
lap dta 0
ai_seg dta a(0)
ai_lap dta 0
speed dta 0
lane dta 0
nitro dta 100
tick_count dta 0
timer_rate dta 30
frame_count dta 0
move_count dta 0
seconds dta a(0)
winner dta 0
input dta 0
input_edge dta 0
old_input dta 0
old_heading dta 0
course_length dta a(0)
        icl 'views-index.asm'
        icl 'views-banks.asm'
        icl 'views-rows.asm'
        icl 'views-motion.asm'
        icl 'views-minimaps.asm'
font_data ins 'font.bin'
        icl 'views-loader.asm'
        run main
