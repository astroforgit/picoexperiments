; Helpers live in BASIC RAM ($A000), enabled by main before use.
.proc detect_player_water
        lda #0
        sta player_in_water
        ; Body bottom is exclusive. Water covers the playable width.
        lda player_y+1
        cmp #<[WATER_TOP+1]
        lda player_y+2
        sbc #>[WATER_TOP+1]
        bcc ?done
        lda player_y+1
        sec
        sbc #12
        sta point_y
        lda player_y+2
        sbc #0
        sta point_y+1
        lda point_y
        cmp #<WATER_BOTTOM
        lda point_y+1
        sbc #>WATER_BOTTOM
        bcs ?done
        inc player_in_water
?done   rts
.endp

.proc apply_player_drag
        lda vel_x
        ora vel_x+1
        bne ?moving
        rts
?moving
        ; Test both feet against the ground (bottom of body is exclusive).
        lda player_y+1
        sta point_y
        lda player_y+2
        sta point_y+1
        lda player_x+1
        sec
        sbc #4
        sta point_x
        jsr point_is_solid
        bcs ?drag
        lda player_x+1
        clc
        adc #3
        sta point_x
        jsr point_is_solid
        bcc ?done
?drag   lda vel_x+1
        bmi ?negative
        lda vel_x
        sec
        sbc #FRICTION_STEP
        sta vel_x
        lda vel_x+1
        sbc #0
        sta vel_x+1
        bpl ?done
        bmi ?zero
?negative
        clc
        lda vel_x
        adc #FRICTION_STEP
        sta vel_x
        lda vel_x+1
        adc #0
        sta vel_x+1
        bmi ?done
?zero   lda #0
        sta vel_x
        sta vel_x+1
?done   rts
.endp

; Draw a rectangle with signed logical screen Y. X/width are physical pixels.
; Clips before doubling Y so partial tiles cannot wrap into another buffer.
rect_y dta a(0)
rect_h dta 0
.proc fill_logical_rect
        lda rect_y+1
        beq ?positive
        cmp #$FF
        bne ?done
        lda rect_y
        clc
        adc rect_h
        bcc ?done
        beq ?done
        sta rect_h
        lda #0
        sta rect_y
?positive
        lda rect_y
        cmp #VIEW_H
        bcs ?done
        asl
        sta calc_y
        lda #VIEW_H
        sec
        sbc rect_y
        cmp rect_h
        bcs ?height
        sta rect_h
?height lda rect_h
        beq ?done
        asl
        sta fr_h
        jmp fill_rect
?done   rts
.endp

.proc draw_water
        ; Entire water region is taller than the viewport: clip its top first,
        ; then its bottom using 16-bit world coordinates.
        lda #<WATER_TOP
        sec
        sbc camera_y
        sta rect_y
        lda #>WATER_TOP
        sbc camera_y+1
        sta rect_y+1
        bmi ?top_clipped
        bne ?done
        lda rect_y
        cmp #VIEW_H
        bcs ?done
        bcc ?bottom
?top_clipped
        lda #0
        sta rect_y
        sta rect_y+1
?bottom
        lda #<WATER_BOTTOM
        sec
        sbc camera_y
        sta water_bottom_screen
        lda #>WATER_BOTTOM
        sbc camera_y+1
        bmi ?done
        bne ?full_bottom
        lda water_bottom_screen
        cmp #VIEW_H
        bcc ?height
?full_bottom
        lda #VIEW_H
?height sec
        sbc rect_y
        beq ?done
        bcc ?done
        sta rect_h
        lda #0
        sta calc_x
        sta calc_x+1
        lda #<SCR_W
        sta fr_w
        lda #>SCR_W
        sta fr_w+1
        lda #24
        sta fr_col
        jmp fill_logical_rect
?done   rts
.endp
water_bottom_screen dta 0

; A fast attack may overshoot a wall by up to ten pixels. After the main
; movement rolls back, advance only on this impact frame to the last free
; pixel. Exact contact lets a 16px block turn into a 16px shaft after waking.
thwomp_gap_dir dta 0
thwomp_gap_steps dta 0
.proc thwomp_close_gap
        ldx thwomp_index
        lda thwomp_state+THW_DIR,x
        sta thwomp_gap_dir
        lda #THW_MAX_SPEED_HI
        sta thwomp_gap_steps
?step  jsr thwomp_step_pixel
        jsr thwomp_collides_map
        bcs ?blocked
        jsr thwomp_collides_thwomps
        bcs ?blocked
        dec thwomp_gap_steps
        bne ?step
        rts
?blocked
        lda thwomp_gap_dir
        eor #2
        sta thwomp_gap_dir
        jmp thwomp_step_pixel
.endp

.proc thwomp_step_pixel
        ldx thwomp_index
        lda thwomp_gap_dir
        cmp #DIR_UP
        beq ?up
        cmp #DIR_RIGHT
        beq ?right
        cmp #DIR_DOWN
        beq ?down
        dec thwomp_state+THW_X,x
        rts
?right inc thwomp_state+THW_X,x
        rts
?up    lda thwomp_state+THW_Y_LO,x
        bne ?up_low
        dec thwomp_state+THW_Y_HI,x
?up_low
        dec thwomp_state+THW_Y_LO,x
        rts
?down  inc thwomp_state+THW_Y_LO,x
        bne ?done
        inc thwomp_state+THW_Y_HI,x
?done  rts
.endp
