; Fixed 50 Hz game simulation, driven by a coherent 16-bit OS VBL clock.
restart
        lda #134
        sta px
        lda #81
        sta py
        lda #0
        sta score
        sta direction
        sta phase
        sta moving
        sta time_frames
        sta sim_fraction
        sta sound_ticks
        sta fire_pending
        sta $d201
        lda #90
        sta seconds
        lda #MODE_PLAY
        sta mode
        ldx #7
reset_sheep
        lda #1
        sta alive,x
        lda #0
        sta vanish,x
        dex
        bpl reset_sheep
        jsr reset_clock
        jmp refresh_message

; Read the two clock bytes without accepting a torn VBI update.
read_clock
        lda $13
        sta now+1
        lda $14
        sta now
        lda $13
        cmp now+1
        bne read_clock
        rts
reset_clock
        jsr read_clock
        mwa now last_clock
        rts

poll_input
        lda $d300
        and #15
        sta stick
        lda $d010
        eor #1
        and #1
        sta fire
        lda #255
        sta key
        lda $d20f
        and #4
        bne keyboard_done
        lda $d209
        and #$3f
        sta key
        cmp #63                     ; A
        bne key_d
        lda stick
        and #11
        sta stick
key_d
        lda key
        cmp #58                     ; D
        bne key_w
        lda stick
        and #7
        sta stick
key_w
        lda key
        cmp #46                     ; W
        bne key_s
        lda stick
        and #14
        sta stick
key_s
        lda key
        cmp #62                     ; S
        bne key_space
        lda stick
        and #13
        sta stick
key_space
        lda key
        cmp #33
        bne keyboard_done
        lda #1
        sta fire
keyboard_done
        lda #255
        sta $2fc                   ; discard OS repeat latch, use held state
        lda fire
        beq console_input
        lda old_fire
        bne console_input
        lda #1
        sta fire_pending
console_input
        lda $d01f
        and #7
        sta console
        eor #7
        and old_console
        sta console_pressed
        lda console
        sta old_console
        lda key
        cmp old_key
        bne new_key
        lda #255
new_key
        sta key_pressed
        lda key
        sta old_key
        lda fire
        sta old_fire
        lda console_pressed
        and #4                     ; OPTION: mute
        beq check_restart
        lda sound_enabled
        eor #1
        sta sound_enabled
        bne check_restart
        sta $d201
check_restart
        lda console_pressed
        and #1                     ; START or R, only on new press
        bne input_restart
        lda key_pressed
        cmp #40
        bne check_pause
input_restart
        jsr restart
        rts
check_pause
        lda console_pressed
        and #2                     ; SELECT or P
        bne toggle_pause
        lda key_pressed
        cmp #10
        bne check_mode
toggle_pause
        lda mode
        cmp #MODE_PLAY
        beq pause_game
        cmp #MODE_PAUSE
        bne check_mode
        lda #MODE_PLAY
        bne set_pause
pause_game
        lda #MODE_PAUSE
set_pause
        sta mode
        lda #0
        sta fire_pending
        sta $d201
        jsr reset_clock
        jsr refresh_message
check_mode
        lda mode
        cmp #MODE_PLAY
        beq input_done
        cmp #MODE_PAUSE
        beq discard_fire
        lda fire_pending
        beq input_done
        jsr restart
        rts
discard_fire
        lda #0
        sta fire_pending
input_done
        rts

advance_time
        jsr read_clock
        sec
        lda now
        sbc last_clock
        sta elapsed
        lda now+1
        sbc last_clock+1
        sta elapsed+1
        mwa now last_clock
        lda #5                     ; prevent large movement bursts after a stall
        sta step_budget
elapsed_loop
        lda elapsed
        ora elapsed+1
        beq advance_done
        lda elapsed
        bne elapsed_low
        dec elapsed+1
elapsed_low
        dec elapsed
        lda mode
        cmp #MODE_PLAY
        bne sim_time
        inc time_frames
        lda time_frames
        cmp rate
        bcc sim_time
        lda #0
        sta time_frames
        dec seconds
        bne sim_time
        lda #MODE_LOSE
        sta mode
        lda #20
        sta sound_ticks
        lda #180
        sta sound_pitch
        jsr refresh_message
sim_time
        lda mode
        cmp #MODE_PAUSE
        beq elapsed_loop
        cmp #MODE_READY
        beq elapsed_loop
        clc
        lda sim_fraction
        adc #50
        cmp rate
        bcc save_fraction
        sbc rate                   ; CMP left carry set
        sta sim_fraction
        lda step_budget
        beq elapsed_loop
        dec step_budget
        jsr game_tick
        jmp elapsed_loop
save_fraction
        sta sim_fraction
        jmp elapsed_loop
advance_done
        rts

game_tick
        jsr update_sound
        jsr update_vanish
        lda mode
        cmp #MODE_PLAY
        bne tick_done
        jsr move_player
        jsr collect
tick_done
        rts

move_player
        lda #0
        sta moving
        lda stick
        and #12
        cmp #8
        beq move_left
        cmp #4
        beq move_right
        jmp vertical
move_left
        lda #8
        sta direction
        lda px
        cmp #11
        bcc vertical
        sec
        sbc #2
        cmp #10
        bcs left_store
        lda #10
left_store
        sta px
        inc moving
        jmp vertical
move_right
        lda #12
        sta direction
        lda px
        cmp #250
        bcs vertical
        clc
        adc #2
        cmp #250
        bcc right_store
        lda #250
right_store
        sta px
        inc moving
vertical
        lda stick
        and #3
        cmp #2
        beq move_up
        cmp #1
        beq move_down
        jmp animation
move_up
        lda #4
        sta direction
        lda py
        cmp #43
        bcc animation
        dec py
        inc moving
        jmp animation
move_down
        lda #0
        sta direction
        lda py
        cmp #148
        bcs animation
        inc py
        inc moving
animation
        lda moving
        beq stop_animation
        inc phase
        rts
stop_animation
        lda #0
        sta phase
        rts

collect
        lda fire_pending
        beq collect_done
        lda #0
        sta fire_pending
        ; Choose the nearest eligible sheep, using Manhattan distance.
        lda #255
        sta nearest
        sta best_distance
        ldx #7
near_sheep
        lda alive,x
        cmp #1
        bne next_sheep
        lda px
        sec
        sbc sheep_x,x
        bcs positive_x
        eor #255
        adc #1
positive_x
        cmp #23
        bcs next_sheep
        sta distance
        lda py
        sec
        sbc sheep_y,x
        bcs positive_y
        eor #255
        adc #1
positive_y
        cmp #17
        bcs next_sheep
        clc
        adc distance
        cmp best_distance
        bcs next_sheep
        sta best_distance
        stx nearest
next_sheep
        dex
        bpl near_sheep
        ldx nearest
        bmi collect_done
        lda #2
        sta alive,x
        inc score
        lda #12
        sta sound_ticks
        lda #60
        sta sound_pitch
        lda score
        cmp #8
        bne collect_done
        lda #MODE_WIN
        sta mode
        lda #30
        sta sound_ticks
        lda #30
        sta sound_pitch
        jsr refresh_message
collect_done
        rts

update_vanish
        ldx #7
vanish_loop
        lda alive,x
        cmp #2
        bne vanish_next
        inc vanish,x
        lda vanish,x
        cmp #42
        bcc vanish_next
        lda #0
        sta alive,x
vanish_next
        dex
        bpl vanish_loop
        rts

; Finite envelopes continue after winning/losing, and always end in silence.
update_sound
        lda sound_ticks
        beq silence
        dec sound_ticks
        lda sound_enabled
        beq silence
        lda sound_pitch
        clc
        adc sound_ticks
        sta $d200
        lda sound_ticks
        lsr
        lsr
        clc
        adc #1
        ora #$a0
        sta $d201
        rts
silence
        lda #0
        sta $d201
        rts

refresh_message
        ldx mode
        lda messages_lo,x
        sta src
        lda messages_hi,x
        sta src+1
message
        ldy #39
copy_message
        lda (src),y
        sta status+40,y
        dey
        bpl copy_message
        rts

px dta 134
py dta 81
score dta 0
seconds dta 90
rate dta 50
mode dta MODE_READY
fire dta 0
old_fire dta 0
fire_pending dta 0
stick dta 15
phase dta 0
direction dta 0
moving dta 0
key dta 255
old_key dta 255
key_pressed dta 255
console dta 7
old_console dta 7
console_pressed dta 0
time_frames dta 0
sim_fraction dta 0
last_clock dta a(0)
now dta a(0)
elapsed dta a(0)
step_budget dta 0
nearest dta 255
best_distance dta 255
distance dta 0
sound_ticks dta 0
sound_pitch dta 60
sound_enabled dta 1
alive :8 dta 1
vanish :8 dta 0
sheep_x dta 30,95,185,232,55,165,20,205
sheep_y dta 44,56,42,78,101,101,138,135
