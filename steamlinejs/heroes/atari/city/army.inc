; Buildings unlock troops; the five army slots are independent of plot order.
.proc clear_army
        ldx #4
        lda #255
?next   sta army_units,x
        mva #0 army_paid_lo,x
        sta army_paid_hi,x
        lda #255
        dex
        bpl ?next
        mva #0 army_count
        rts
.endp

; Refresh action prices and preview without mutating city or army state.
.proc describe_selection
        jsr capacity
        mva #0 upgrade_available
        sta secondary_available
        sta upgrade_cost
        sta upgrade_cost+1
        sta secondary_cost
        sta secondary_cost+1
        sta current_level
        mva #255 current_unit
        sta next_unit
        sta target_index
        lda selected_plot
        cmp #6
        bcs ?slot
        tax
        stx family_index
        lda building_levels,x
        sta current_level
        cpx #3
        beq ?next_building
        cmp #0
        beq ?next_building
        sec
        sbc #1
        clc
        adc type_base,x
        sta current_unit
        tay
        lda unit_price_lo,y
        sta secondary_cost
        lda unit_price_hi,y
        sta secondary_cost+1
        jsr recruit_discount
        mva #1 secondary_available
?next_building
        lda current_level
        cmp #3
        bcs ?preview
        clc
        adc type_base,x
        sta next_unit
        tay
        lda cost_lo,y
        sta upgrade_cost
        lda cost_hi,y
        sta upgrade_cost+1
        mva #1 upgrade_available
        jmp ?preview
?slot   sec
        sbc #6
        sta army_slot
        tax
        lda army_units,x
        cmp #255
        beq ?preview
        sta current_unit
        tay
        lda army_paid_hi,x
        lsr
        sta secondary_cost+1
        lda army_paid_lo,x
        ror
        sta secondary_cost
        mva #1 secondary_available
        lda unit_family,y
        sta family_index
        tax
        lda unit_tier,y
        sta current_level
        cmp building_levels,x
        bcs ?preview
        iny
        sty next_unit
        sec
        lda unit_price_lo,y
        sbc unit_price_lo-1,y
        sta upgrade_cost
        lda unit_price_hi,y
        sbc unit_price_hi-1,y
        sta upgrade_cost+1
        mva #1 upgrade_available
?preview
        lda selected_plot
        cmp #3
        beq ?support
        mva current_unit target_index
        lda popup_choice
        bne ?done
        lda upgrade_available
        beq ?done
        mva next_unit target_index
        jmp ?done
?support mva #255 target_index
        mva #0 secondary_available
?done   mwa upgrade_cost purchase_cost
        rts
.endp

.proc confirm_action
        lda screen_mode
        cmp #2
        bne ?not_battle
        jmp battle.confirm
?not_battle
        cmp #0
        beq ?city
        jmp map_confirm
?city   lda selected_plot
        cmp #5
        bne ?inspect
        jmp show_map
?inspect
        lda popup_open
        bne ?popup
        mva #1 popup_open
        mva #0 popup_choice
        sta notice
        jsr describe_selection
        lda upgrade_available
        bne ?redraw
        inc popup_choice
        lda secondary_available
        bne ?redraw
        inc popup_choice
        jmp ?redraw
?popup  lda popup_choice
        cmp #2
        beq ?close
        cmp #1
        beq ?secondary
        jsr purchase
        jmp ?redraw
?secondary
        lda selected_plot
        cmp #6
        bcs ?dismiss
        jsr recruit
        jmp ?redraw
?dismiss
        jsr dismiss_unit
        jmp ?redraw
?close  jsr close_popup
?redraw mva #1 dirty
        rts
.endp

; Carry set only after a successful 16-bit payment.
.proc pay_gold
        lda gold+1
        cmp purchase_cost+1
        bcc ?poor
        bne ?pay
        lda gold
        cmp purchase_cost
        bcc ?poor
?pay    sec
        lda gold
        sbc purchase_cost
        sta gold
        lda gold+1
        sbc purchase_cost+1
        sta gold+1
        sec
        rts
?poor   mva #1 notice
        mva #1 dirty
        clc
        rts
.endp

.proc action_done
        mva #0 popup_open
        sta notice
        mva #1 dirty
        rts
.endp

.proc purchase
        jsr describe_selection
        lda upgrade_available
        jeq action_unavailable
        jsr pay_gold
        bcc ?done
        lda selected_plot
        cmp #6
        bcs ?unit
        tax
        inc building_levels,x
        jsr capacity
        jmp action_done
?unit   ldx army_slot
        lda next_unit
        sta army_units,x
        clc
        lda army_paid_lo,x
        adc purchase_cost
        sta army_paid_lo,x
        lda army_paid_hi,x
        adc purchase_cost+1
        sta army_paid_hi,x
        jmp action_done
?done   rts
.endp

action_unavailable
        mva #5 notice
        mva #1 dirty
        rts

.proc recruit
        jsr describe_selection
        lda secondary_available
        jeq action_unavailable
        mva #255 free_slot
        ldx #0
?scan   lda army_units,x
        cmp #255
        beq ?empty
        jmp ?next
?empty  lda free_slot
        cmp #255
        bne ?next
        stx free_slot
?next   inx
        cpx army_capacity
        bne ?scan
        lda free_slot
        cmp #255
        beq ?full
        mwa secondary_cost purchase_cost
        jsr pay_gold
        bcc ?done
        ldx free_slot
        lda current_unit
        sta army_units,x
        mva purchase_cost army_paid_lo,x
        mva purchase_cost+1 army_paid_hi,x
        inc army_count
        jmp action_done
?full   mva #4 notice
        mva #1 dirty
?done   rts
.endp

.proc dismiss_unit
        jsr describe_selection
        lda secondary_available
        jeq action_unavailable
        clc
        lda gold
        adc secondary_cost
        sta gold
        lda gold+1
        adc secondary_cost+1
        sta gold+1
        bcc ?remove
        mwa #65535 gold
?remove ldx army_slot
        mva #255 army_units,x
        dec army_count
        jmp action_done
.endp
upgrade_available dta 0
secondary_available dta 0
upgrade_cost dta a(0)
secondary_cost dta a(0)
current_unit dta 255
next_unit dta 255
family_index dta 0
army_slot dta 0
free_slot dta 255

; Chapel levels 0/1/2/3 give capacity 3/4/5/5.
.proc capacity
        lda building_levels+3
        cmp #3
        bcc ?add
        lda #2
?add    clc
        adc #3
        sta army_capacity
        rts
.endp
.proc recruit_discount
        lda building_levels+3
        cmp #3
        bcc ?done
        sec
        lda secondary_cost
        sbc #10
        sta secondary_cost
        lda secondary_cost+1
        sbc #0
        sta secondary_cost+1
        bcc ?minimum
        ora secondary_cost
        bne ?done
?minimum mwa #1 secondary_cost
?done   rts
.endp
army_capacity dta 3
army_paid_lo :5 dta 0
army_paid_hi :5 dta 0
