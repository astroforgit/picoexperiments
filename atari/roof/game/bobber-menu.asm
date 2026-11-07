; B opens a modal catalogue without changing the fishing state.
bobber_controls
        lda #0
        sta popup_block
        lda popup_edge
        and #1
        beq popup_other_keys
        inc popup_block
        lda popup_active
        bne popup_cancel
        lda bobber_selected
        sta popup_selected
        lda #1
        sta popup_active
        rts
popup_other_keys
        lda popup_active
        beq popup_controls_done
        inc popup_block
        lda popup_edge
        and #4
        bne popup_cancel
        lda dir_edge
        and #4
        beq popup_not_left
        lda popup_selected
        sec
        sbc #2
        and #15
        sta popup_selected
popup_not_left
        lda dir_edge
        and #8
        beq popup_not_right
        lda popup_selected
        clc
        adc #2
        and #15
        sta popup_selected
popup_not_right
        lda dir_edge
        and #3
        beq popup_not_size
        lda popup_selected
        eor #1
        sta popup_selected
popup_not_size
        lda popup_edge
        and #2
        ora press_edge
        beq popup_controls_done
        lda popup_selected
        sta bobber_selected
popup_cancel
        lda #0
        sta popup_active
popup_controls_done
        rts

draw_bobber_popup
        lda buffer
        sta blit_bank
        mwa #bobber_panel_blit points
        jsr run_blit
        ldx popup_selected
        lda bobber_border_lo,x
        sta border_start
        sta offset
        lda bobber_border_hi,x
        sta border_start+1
        sta offset+1
        lda #250
        sta color
        jsr border_horizontal
        clc
        lda border_start
        adc #<(31*320)
        sta offset
        lda border_start+1
        adc #>(31*320)
        sta offset+1
        jsr border_horizontal
        clc
        lda border_start
        adc #<320
        sta offset
        lda border_start+1
        adc #>320
        sta offset+1
        ldx #30
border_sides
        jsr plot_offset
        clc
        lda offset
        adc #24
        sta offset
        bcc border_right
        inc offset+1
border_right
        jsr plot_offset
        clc
        lda offset
        adc #<296
        sta offset
        lda offset+1
        adc #>296
        sta offset+1
        dex
        bne border_sides
        rts
border_horizontal
        ldx #25
border_h_pixel
        jsr plot_offset
        inc offset
        bne border_h_next
        inc offset+1
border_h_next
        dex
        bne border_h_pixel
        rts
border_start dta a(0)
bobber_panel_blit
        dta 0,$60,1,a(240),1,<(38*320+40),>(38*320+40),0,a(320),1,a(239),163,$ff,0,0,0,0,0
bobber_selected dta 2 ; 02 Quill, small
popup_selected dta 2
popup_active dta 0
popup_block dta 0
popup_keys dta 0
popup_previous dta 0
popup_edge dta 0
bob_dx dta 0
bob_dy dta 0
