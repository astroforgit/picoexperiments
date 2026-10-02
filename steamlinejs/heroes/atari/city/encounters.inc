; Two-screen navigation and static encounter map. Army/city state persists.
.proc show_map
        mva #1 screen_mode
        mva #5 background_bank
        mva #0 popup_open
        sta notice
        mva #1 dirty
        rts
.endp

.proc show_city
        mva #0 screen_mode
        sta popup_open
        sta notice
        mva #2 background_bank
        mva #1 dirty
        rts
.endp

.proc map_confirm
        lda popup_open
        beq ?location
        lda popup_choice
        bne ?close
        jsr can_enter_battle
        bcc ?done
        jmp battle.start
?close  jmp close_popup
?location
        lda selected_location
        cmp #3
        bne ?scout
        jmp show_city
?scout  mva #1 popup_open
        sta dirty
        mva #0 popup_choice
?done   rts
.endp

.proc can_enter_battle
        lda army_count
        beq ?no
        ldx selected_location
        lda location_region,x
        beq ?yes
        tax
        dex
        lda region_wins,x
        cmp #3
        bcc ?no
?yes    sec
        rts
?no     clc
        rts
.endp
region_wins dta 0,0,0,0
location_region dta 0,1,2,255,3

.proc map_navigate
        lda popup_open
        beq ?map
        lda popup_choice
        eor #1
        sta popup_choice
        mva #1 dirty
        rts
?map    lda map_direction_offsets,x
        clc
        adc selected_location
        tax
        lda map_neighbours,x
        sta selected_location
        mva #1 dirty
        rts
.endp
map_direction_offsets dta 0,5,10,15
map_neighbours
        dta 0,1,2,0,2
        dta 3,3,4,3,4
        dta 0,0,1,3,3
        dta 1,2,2,4,4

.proc draw_city_gate
        ; Select the existing dark gateway in the top-center city wall.
        lda selected_plot
        cmp #5
        bne ?done
        mwa #143 calc_x
        mva #31 calc_y
        mwa #34 fr_w
        mva #26 fr_h
        mva #2 fr_col
        jmp outline
?done   rts
.endp

.proc draw_encounters
        mva #0 dirty
        mva back_bank render_bank
        jsr copy_background_cache
        ldx selected_location
        lda map_cursor_x,x
        sta calc_x
        mva #0 calc_x+1
        lda map_cursor_y,x
        sta calc_y
        lda map_cursor_w,x
        sta fr_w
        mva #0 fr_w+1
        mva #18 fr_h
        mva #2 fr_col
        jsr outline
        jsr draw_header
        ; Replace the city title with the selected location's name.
        rect 0,0,207,15,1
        jsr location_name_pointer
        mwa #8 text_x
        mva #4 text_y
        jsr draw_text
        jsr draw_city_hud
        lda popup_open
        beq ?present
        jsr draw_scout_report
?present
        jsr wait_blit
        jmp present_back_buffer
.endp
map_cursor_x dta 27,136,222,44,193
map_cursor_y dta 61,62,59,136,130
map_cursor_w dta 56,56,56,72,56

.proc location_name_pointer
        ldx selected_location
        lda location_name_lo,x
        sta text_src
        lda location_name_hi,x
        sta text_src+1
        rts
.endp

.proc draw_scout_report
        rect 22,28,280,128,1
        rect 24,30,276,124,7
        rect 24,30,276,16,1
        mwa #22 calc_x
        mva #28 calc_y
        mwa #280 fr_w
        mva #128 fr_h
        mva #2 fr_col
        jsr outline
        jsr location_name_pointer
        mwa #32 text_x
        mva #34 text_y
        jsr draw_text
        labeltext 32,54,s_scout
        ldx selected_location
        lda location_desc_lo,x
        sta text_src
        lda location_desc_hi,x
        sta text_src+1
        mwa #32 text_x
        mva #72 text_y
        jsr draw_text
        ldx selected_location
        lda location_detail_lo,x
        sta text_src
        lda location_detail_hi,x
        sta text_src+1
        mwa #32 text_x
        mva #88 text_y
        jsr draw_text
        labeltext 32,105,s_wins
        ldx selected_location
        ldy location_region,x
        lda region_wins,y
        clc
        adc #48
        sta one_char
        labeltext 68,105,one_char
        labeltext 80,105,s_three
        jsr can_enter_battle
        bcs ?ready
        lda army_count
        beq ?no_army
        labeltext 32,119,s_locked
        jmp ?buttons
?no_army
        labeltext 32,119,s_recruit_first
        jmp ?buttons
?ready  labeltext 32,119,s_ready
?buttons
        rect 32,134,119,15,1
        rect 170,134,119,15,1
        lda popup_choice
        bne ?back
        mwa #32 calc_x
        jmp ?outline
?back   mwa #170 calc_x
?outline
        mva #134 calc_y
        mwa #119 fr_w
        mva #15 fr_h
        mva #2 fr_col
        jsr outline
        labeltext 74,138,s_fight
        labeltext 217,138,s_back
        rts
.endp
s_wins dta c'WINS',0
s_three dta c'/ 3',0
s_locked dta c'CLEAR PREVIOUS REGION FIRST',0
s_recruit_first dta c'RECRUIT AN ARMY IN THE CITY',0
s_ready dta c'FIRE: FIGHT   ESC: BACK',0
s_fight dta c'FIGHT',0

s_scout dta c'SCOUT REPORT',0
s_scout_return dta c'FIRE / ESC: RETURN TO MAP',0
location_name_lo dta <s_forest,<s_cemetery,<s_caves,<s_city_return,<s_ruins
location_name_hi dta >s_forest,>s_cemetery,>s_caves,>s_city_return,>s_ruins
location_desc_lo dta <s_forest_desc,<s_cemetery_desc,<s_caves_desc,<s_city_desc,<s_ruins_desc
location_desc_hi dta >s_forest_desc,>s_cemetery_desc,>s_caves_desc,>s_city_desc,>s_ruins_desc
location_detail_lo dta <s_forest_detail,<s_cemetery_detail,<s_caves_detail,<s_city_desc,<s_ruins_detail
location_detail_hi dta >s_forest_detail,>s_cemetery_detail,>s_caves_detail,>s_city_desc,>s_ruins_detail
s_forest dta c'DARK FOREST',0
s_cemetery dta c'CATACOMBS',0
s_caves dta c'MONSTER CAVES',0
s_city_return dta c'BACK TO GREENHAVEN',0
s_ruins dta c'NECROMANCER RUINS',0
s_forest_desc dta c'EVIL EYES GLOW BENEATH BLACK ROOTS.',0
s_forest_detail dta c'BEASTS HUNT AMONG THORNS AND WEBS.',0
s_cemetery_desc dta c'A SKULL GATE DESCENDS INTO DARKNESS.',0
s_cemetery_detail dta c'THE RESTLESS DEAD GUARD THE TUNNELS.',0
s_caves_desc dta c'CLAW MARKS SCAR THE CAVERN MOUTH.',0
s_caves_detail dta c'OGRES AND HUNGRY BATS LURK WITHIN.',0
s_city_desc dta c'RETURN HOME TO BUILD AND UPGRADE.',0
s_ruins_desc dta c'GREEN SOUL FIRE SPLITS THE RUINS.',0
s_ruins_detail dta c'UNDEAD AND IMPS SERVE THE WARLOCK.',0
