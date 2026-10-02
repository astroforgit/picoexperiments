.proc selection_name_pointer
        lda screen_mode
        beq ?city
        jmp location_name_pointer
?city   ldx selected_plot
        cpx #5
        beq ?gate
        bcs ?slot
        lda building_name_lo,x
        sta text_src
        lda building_name_hi,x
        sta text_src+1
        rts
?gate   mwa #s_gate text_src
        rts
?slot   txa
        sec
        sbc #6
        tax
        cpx army_capacity
        bcc ?available
        mwa #s_locked_slot text_src
        rts
?available
        lda army_units,x
        cmp #255
        jeq ?empty
        tax
        lda unit_name_lo,x
        sta text_src
        lda unit_name_hi,x
        sta text_src+1
        rts
?empty  mwa #s_empty_slot text_src
        rts
.endp

.proc draw_popup
        jsr describe_selection
        rect 22,28,280,128,1
        rect 24,30,276,124,7
        rect 24,30,276,16,1
        mwa #22 calc_x
        mva #28 calc_y
        mwa #280 fr_w
        mva #128 fr_h
        mva #2 fr_col
        jsr outline
        jsr selection_name_pointer
        mwa #32 text_x
        mva #34 text_y
        jsr draw_text
        labeltext 32,50,s_level
        lda current_level
        clc
        adc #48
        sta one_char
        labeltext 68,50,one_char
        lda selected_plot
        cmp #6
        bcs ?unit
        labeltext 86,50,s_building_level
?unit   lda selected_plot
        cmp #3
        bne ?fighter
        labeltext 32,64,s_chapel_capacity
        lda army_capacity
        clc
        adc #48
        sta one_char
        labeltext 164,64,one_char
        lda current_level
        cmp #3
        bcc ?effect
        lda #2
?effect tax
        mva chapel_effect_lo,x text_src
        mva chapel_effect_hi,x text_src+1
        mwa #32 text_x
        mva #80 text_y
        jsr draw_text
        jmp ?notice
?fighter lda target_index
        cmp #255
        jeq ?empty
        lda popup_choice
        bne ?current_label
        lda upgrade_available
        beq ?current_label
        labeltext 32,64,s_next_label
        jmp ?unit_name
?current_label
        labeltext 32,64,s_unit_label
?unit_name
        ldx target_index
        lda unit_name_lo,x
        sta text_src
        lda unit_name_hi,x
        sta text_src+1
        mwa #68 text_x
        mva #64 text_y
        jsr draw_text
        labeltext 32,80,s_hp
        ldy target_index
        lda unit_hp,y
        sta number_value
        mva #0 number_value+1
        jsr format_number
        labeltext 50,80,number_text+3
        labeltext 86,80,s_attack
        ldy target_index
        lda unit_damage,y
        sta number_value
        mva #0 number_value+1
        jsr format_number
        labeltext 110,80,number_text+3
        labeltext 140,80,s_range
        ldy target_index
        lda unit_range,y
        clc
        adc #48
        sta one_char
        labeltext 164,80,one_char
        mwa #253 calc_x
        mva #52 calc_y
        lda target_index
        jsr draw_portrait
        jmp ?notice
?empty  lda selected_plot
        sec
        sbc #6
        cmp army_capacity
        bcc ?empty_open
        labeltext 32,66,s_unlock_help
        jmp ?notice
?empty_open labeltext 32,66,s_empty_help
?notice lda notice
        beq ?rows
        tax
        lda notice_lo,x
        sta text_src
        lda notice_hi,x
        sta text_src+1
        mwa #32 text_x
        mva #94 text_y
        jsr draw_text
?rows   mva #0 button_index
?row    ldx button_index
        lda button_y,x
        sta calc_y
        mwa #32 calc_x
        mwa #256 fr_w
        mva #13 fr_h
        mva #1 fr_col
        jsr fill_rect
        lda button_index
        cmp popup_choice
        bne ?label
        ldx button_index
        lda button_y,x
        sta calc_y
        mwa #32 calc_x
        mwa #256 fr_w
        mva #13 fr_h
        mva #2 fr_col
        jsr outline
?label  lda button_index
        cmp #2
        jeq ?back
        cmp #1
        beq ?secondary
        lda upgrade_available
        bne ?upgrade
        mwa #s_no_upgrade text_src
        jmp ?text
?upgrade
        mwa #s_upgrade text_src
        lda selected_plot
        cmp #6
        bcs ?text
        mwa #s_upgrade_building text_src
        lda current_level
        bne ?text
        mwa #s_build text_src
        jmp ?text
?secondary
        lda selected_plot
        cmp #3
        bne ?recruit_or_dismiss
        mwa #s_support_only text_src
        jmp ?text
?recruit_or_dismiss
        lda selected_plot
        cmp #6
        bcs ?dismiss
        mwa #s_recruit text_src
        lda secondary_available
        bne ?text
        mwa #s_build_first text_src
        jmp ?text
?dismiss
        mwa #s_dismiss text_src
        lda secondary_available
        bne ?text
        mwa #s_empty_slot text_src
        jmp ?text
?back   mwa #s_back text_src
?text   mwa #40 text_x
        ldx button_index
        lda button_y,x
        clc
        adc #3
        sta text_y
        jsr draw_text
        lda button_index
        cmp #2
        beq ?next
        cmp #1
        beq ?secondary_price
        lda upgrade_available
        beq ?next
        mwa upgrade_cost number_value
        jmp ?price
?secondary_price
        lda secondary_available
        beq ?next
        mwa secondary_cost number_value
?price  jsr format_number
        mwa #242 text_x
        ldx button_index
        lda button_y,x
        clc
        adc #3
        sta text_y
        mwa #number_text text_src
        jsr draw_text
        mwa #278 text_x
        mwa #s_gold_suffix text_src
        jsr draw_text
?next   inc button_index
        lda button_index
        cmp #3
        beq ?done
        jmp ?row
?done   rts
.endp
button_index dta 0
button_y dta 108,122,136
s_gate dta c'ENCOUNTER GATE',0
s_locked_slot dta c'LOCKED',0
s_unlock_help dta c'UPGRADE CHAPEL TO UNLOCK',0
s_support_only dta c'SUPPORT BUILDING',0
s_chapel_capacity dta c'ARMY CAPACITY:',0
chapel_effect_lo dta <s_chapel_1,<s_chapel_2,<s_chapel_3
chapel_effect_hi dta >s_chapel_1,>s_chapel_2,>s_chapel_3
s_chapel_1 dta c'NEXT: UNLOCK FOURTH ARMY SLOT',0
s_chapel_2 dta c'NEXT: UNLOCK FIFTH ARMY SLOT',0
s_chapel_3 dta c'RECRUIT DISCOUNT: 10 GOLD',0
s_empty_slot dta c'EMPTY ARMY SLOT',0
s_empty_help dta c'RECRUIT AT A CITY BUILDING',0
s_building_level dta c'BUILDING',0
s_upgrade_building dta c'UPGRADE BUILDING',0
s_dismiss dta c'DISMISS / REFUND',0
s_build_first dta c'RECRUIT - BUILD FIRST',0
s_no_upgrade dta c'UPGRADE UNAVAILABLE',0
s_duplicate dta c'UNIT FAMILY ALREADY IN ARMY',0
s_full dta c'ARMY FULL - DISMISS A UNIT',0
s_unavailable dta c'ACTION NOT AVAILABLE',0
notice_lo dta <s_poor,<s_poor,<s_updated,<s_duplicate,<s_full,<s_unavailable
notice_hi dta >s_poor,>s_poor,>s_updated,>s_duplicate,>s_full,>s_unavailable

s_next_label dta c'NEXT:',0
s_unit_label dta c'UNIT:',0
s_gold_suffix dta c'G',0
