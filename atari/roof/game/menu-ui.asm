; M toggles a pause menu without resetting a cast, bite or inventory.
toggle_menu
        lda #0
        sta menu_block
        lda popup_edge
        and #8
        beq menu_toggle_done
        lda popup_active
        bne menu_toggle_done
        inc menu_block
        lda state
        cmp #STATE_MENU
        beq menu_resume_play
        sta menu_resume
        lda #STATE_MENU
        sta state
        lda #0
        sta menu_row
        lda #1
        sta menu_dirty
        rts
menu_resume_play
        lda menu_resume
        cmp #STATE_GAME_OVER
        beq menu_toggle_done
        sta state
menu_toggle_done
        rts

; Counts include the attached worm. No word labels accompany these icons.
draw_menu_inventory
        mwa #menu_rainbow_0 points
        lda #255
        sta color
        jsr draw_points
        mwa #menu_rainbow_1 points
        lda #250
        sta color
        jsr draw_points
        mwa #menu_rainbow_2 points
        lda #251
        sta color
        jsr draw_points
        mwa #menu_rainbow_3 points
        lda #252
        sta color
        jsr draw_points
        mwa #menu_electric_0 points
        lda #251
        sta color
        jsr draw_points
        mwa #menu_electric_1 points
        lda #252
        sta color
        jsr draw_points
        mwa #menu_electric_2 points
        lda #251
        sta color
        jsr draw_points
        mwa #menu_electric_3 points
        lda #252
        sta color
        jsr draw_points
        lda #201
        sta px
        lda #68
        sta py
        jsr draw_caught_star
        lda #252
        sta color
        lda #115
        sta px
        lda #66
        sta py
        ldx #0
        jsr inventory_count
        jsr digit
        lda #167
        sta px
        lda #66
        sta py
        ldx #1
        jsr inventory_count
        jsr digit
        lda #216
        sta px
        lda #66
        sta py
        lda score
        jmp digit
inventory_count
        lda worm_stock,x
        cpx worm_type
        bne inventory_count_done
        clc
        adc bait_present
inventory_count_done
        rts
menu_resume dta 0
menu_block dta 0

menu_activate dta 0
; 0 easy, 1 medium, 2 hard. Preserved when starting a new night.
difficulty dta 1

STATE_GAME_OVER = 6
; Keep the final score and stock until PLAY explicitly starts the next night.
game_over_enter
        lda #STATE_GAME_OVER
        sta state
        lda #1
        sta menu_dirty
        lda #0
        sta result_armed
        sta popup_active
        jsr clear_result_edges
        rts

; A held strike cannot skip the result. Release, then any fresh input dismisses.
read_any_input
        lda $d20f
        and #4
        beq any_input_yes
        lda $d010
        beq any_input_yes
        lda $d300
        and #15
        cmp #15
        bne any_input_yes
        lda $d01f
        and #7
        cmp #7
        bne any_input_yes
        lda #0
        rts
any_input_yes
        lda #1
        rts
game_over_input
        jsr read_any_input
        bne result_pressed
        lda #1
        sta result_armed
        rts
result_pressed
        lda result_armed
        beq result_input_done
        lda #STATE_GAME_OVER
        sta menu_resume
        lda #STATE_MENU
        sta state
        lda #1
        sta menu_dirty
        sta menu_release
        lda #0
        sta menu_row
        jsr clear_result_edges
result_input_done
        rts
clear_result_edges
        lda #0
        sta pressed
        sta previous_pressed
        sta press_edge
        sta dirs
        sta previous_dirs
        sta dir_edge
        sta popup_keys
        sta popup_previous
        sta popup_edge
        sta menu_activate
        sta menu_block
        sta popup_block
        rts
compose_results
        mwa #panel_blit points
        jsr run_blit
        mwa #rail_top points
        jsr run_blit
        mwa #rail_bottom points
        jsr run_blit
        mwa #result_title points
        lda #250
        sta color
        jsr draw_points
        mwa #result_hint points
        lda #251
        sta color
        jsr draw_points
        lda #145
        sta px
        lda #99
        sta py
        jsr draw_caught_star
        lda #252
        sta color
        lda #163
        sta px
        lda #98
        sta py
        lda score
        jmp digit
result_armed dta 0
menu_release dta 0
