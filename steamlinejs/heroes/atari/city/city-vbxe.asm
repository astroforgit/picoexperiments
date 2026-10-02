; Native city prototype. MADS / 6502, XL/XE + VBXE FX.
; CPU: code $2000..$5FFF; staged loader $6000..$6FFF; ANTIC $8000.
; VRAM: front/back $00000/$10000, background $20000, sprites/font $30000,
;       XDL $7F000, blitter $7F100. 4K CPU aperture $9000..$9FFF.
SDMCTL=$022F
SDLSTL=$0230
COLOR1=$02C5
COLOR2=$02C6
COLOR4=$02C8
CHBAS=$02F4
CH=$02FC
SKSTAT=$D20F
KBCODE=$D209
RTCLOK=$12
PORTA=$D300
PORTB=$D301
STRIG0=$D010
CONSOL=$D01F
DMACTL=$D400
VBXE_VCTL=$D640
VBXE_XDL0=$D641
VBXE_XDL1=$D642
VBXE_XDL2=$D643
VBXE_CSEL=$D644
VBXE_PSEL=$D645
VBXE_CR=$D646
VBXE_CG=$D647
VBXE_CB=$D648
VBXE_BL_ADR0=$D650
VBXE_BL_ADR1=$D651
VBXE_BL_ADR2=$D652
VBXE_BLITTER=$D653
VBXE_MEMAC_CTRL=$D65E
VBXE_BANK_SEL=$D65F
VC_XDL_ON=1
VC_XCOLOR=2
MEMW=$9000
BANK_EN=$80
BANK_XDL=$7F
BCB_OFF=$100
XDL_B_OFF=$20
SCR_W=320
SCR_H=200
work_ptr=$CB
data_ptr=$CD
text_src=$CF
text_dst=$D1
calc_out=$D3

.macro labeltext
        mwa #:1 text_x
        mva #:2 text_y
        mwa #:3 text_src
        jsr draw_text
.endm
.macro rect
        mwa #:1 calc_x
        mva #:2 calc_y
        mwa #:3 fr_w
        mva #:4 fr_h
        mva #:5 fr_col
        jsr fill_rect
.endm

        org $2000
.proc loader_init
        cld
        jsr detect_vbxe
        bcc ?done
        mva #1 hardware_ok
        lda #$98
reg_memac
        sta VBXE_MEMAC_CTRL
        lda #0
reg_vctl
        sta VBXE_VCTL
?done   rts
.endp

.proc upload_chunk
        lda hardware_ok
        beq ?done
        lda upload_index
        ora #BANK_EN
reg_bank
        sta VBXE_BANK_SEL
        mwa #$6000 data_ptr
        mwa #MEMW text_dst
        ldx #16
        ldy #0
?byte   lda (data_ptr),y
        sta (text_dst),y
        iny
        bne ?byte
        inc data_ptr+1
        inc text_dst+1
        dex
        bne ?byte
        inc upload_index
        lda #0
reg_restore
        sta VBXE_BANK_SEL
?done   rts
.endp
hardware_ok dta 0
upload_index dta 32

main
        cld
        lda PORTB
        ora #2
        sta PORTB
        jsr setup_antic
        lda hardware_ok
        bne hardware_ready
        mwa #s_missing text_src
        mwa #text_screen+12*40+12 text_dst
        jsr copy_text
no_vbxe
        jmp no_vbxe
hardware_ready
        jsr setup_xdl
        jsr blit_init
        jsr load_city_palette
        jsr new_city
        mva #0 front_bank
        mva #1 back_bank
        ; Paint both buffers before enabling the overlay.
        mva #0 render_bank
        jsr copy_background_cache
        jsr wait_blit
        mva #1 render_bank
        jsr copy_background_cache
        jsr wait_blit
        jsr enable_display
        jsr draw_city
main_loop
        jsr wait_frame
        jsr poll_input
        lda dirty
        beq main_loop
        jsr draw_city
        jmp main_loop

.proc new_city
        mwa #START_GOLD gold
        ldx #4
?copy   lda initial_levels,x
        sta building_levels,x
        dex
        bpl ?copy
        mva #0 selected_plot
        sta screen_mode
        sta selected_location
        sta popup_open
        sta notice
        sta action_latched
        sta release_ticks
        mva #2 background_bank
        mva #15 old_stick
        mva #$FF CH
        jsr clear_army
        ldx #4
?army   lda initial_army,x
        sta army_units,x
        cmp #255
        beq ?empty
        inc army_count
        tay
        mva unit_price_lo,y army_paid_lo,x
        mva unit_price_hi,y army_paid_hi,x
?empty  dex
        bpl ?army
        jsr capacity
        ldx #3
?progress
        mva #0 region_wins,x
        dex
        bpl ?progress
        mva #1 dirty
        rts
.endp

        icl 'army.inc'

; A is 0 up, 1 down, 2 left, 3 right. Fixed directional neighbour graph.
.proc navigate
        tax
        lda screen_mode
        cmp #2
        bne ?not_battle
        jmp battle.navigate
?not_battle
        cmp #0
        beq ?city_mode
        jmp map_navigate
?city_mode
        lda popup_open
        beq ?city
        mva #0 notice
        cpx #0
        beq ?previous
        cpx #2
        beq ?previous
        inc popup_choice
        lda popup_choice
        cmp #3
        bcc ?redraw
        mva #0 popup_choice
        jmp ?redraw
?previous
        dec popup_choice
        bpl ?redraw
        mva #2 popup_choice
        jmp ?redraw
?city   lda direction_offsets,x
        clc
        adc selected_plot
        tax
        lda neighbours,x
        sta selected_plot
        mva #0 notice
?redraw mva #1 dirty
        rts
.endp

.proc close_popup
        lda screen_mode
        cmp #2
        bne ?not_battle
        jmp battle.cancel
?not_battle
        lda popup_open
        bne ?dismiss
        lda screen_mode
        beq ?dismiss
        jmp show_city
?dismiss
        mva #0 popup_open
        sta notice
        mva #1 dirty
        rts
.endp

.proc poll_input
        lda PORTA
        and #15
        cmp old_stick
        beq ?fire
        sta old_stick
        cmp #14
        bne ?down
        lda #0
        jsr navigate
        jmp ?fire
?down   cmp #13
        bne ?left
        lda #1
        jsr navigate
        jmp ?fire
?left   cmp #11
        bne ?right
        lda #2
        jsr navigate
        jmp ?fire
?right  cmp #7
        bne ?fire
        lda #3
        jsr navigate
?fire   mva #0 action_mask
        lda STRIG0
        and #1
        bne ?console
        mva #1 action_mask
?console
        lda CONSOL
        and #2
        bne ?keyboard
        lda action_mask
        ora #2
        sta action_mask
?keyboard
        ; Raw key state persists while CH produces OS typematic repeats.
        lda SKSTAT
        and #4
        bne ?buffered
        lda KBCODE
        and #$3F
        jsr classify_action
?buffered
        lda CH
        sta key_temp
        mva #$FF CH             ; drain even while an action is locked
        lda key_temp
        cmp #$FF
        beq ?sampled
        and #$3F
        sta key_temp
        jsr classify_action
?sampled
        lda action_mask
        beq ?released
        mva #0 release_ticks
        lda action_latched
        bne ?directions
        mva #1 action_latched
        lda action_mask
        and #2
        beq ?confirm
        jsr close_popup        ; cancel wins if sources disagree
        jmp ?directions
?confirm
        jsr confirm_action
        jmp ?directions
?released
        lda release_ticks
        cmp #2
        bcs ?directions
        inc release_ticks
        lda release_ticks
        cmp #2
        bcc ?directions
        mva #0 action_latched
?directions
        lda key_temp
        cmp #$FF
        beq ?done
        cmp #$2E                 ; W
        beq ?upkey
        cmp #$0E                 ; Up arrow
        beq ?upkey
        cmp #$3E                 ; S
        beq ?downkey
        cmp #$0F                 ; Down arrow
        beq ?downkey
        cmp #$3F                 ; A
        beq ?leftkey
        cmp #$06                 ; Left arrow
        beq ?leftkey
        cmp #$3A                 ; D
        beq ?rightkey
        cmp #$07                 ; Right arrow
        bne ?done
?rightkey
        lda #3
        jmp navigate
?leftkey
        lda #2
        jmp navigate
?downkey
        lda #1
        jmp navigate
?upkey  lda #0
        jmp navigate
?done   rts
.endp

; Aggregate keyboard and joystick events into ONE logical action per press.
.proc classify_action
        cmp #$0C
        beq ?confirm
        cmp #$21
        beq ?confirm
        cmp #$1C
        bne ?done
        lda action_mask
        ora #2
        sta action_mask
        rts
?confirm
        lda action_mask
        ora #1
        sta action_mask
?done   rts
.endp

gold dta a(0)
building_levels :5 dta 0
army_units :5 dta 255
army_count dta 0
selected_plot dta 0
screen_mode dta 0             ; 0 city, 1 encounter map
selected_location dta 0
background_bank dta 2
popup_open dta 0
popup_choice dta 0
current_level dta 0
target_index dta 0
purchase_cost dta a(0)
notice dta 0                  ; 0 normal, 1 insufficient funds, 2 recruited/upgraded
dirty dta 1
old_stick dta 15
action_latched dta 0
release_ticks dta 0
action_mask dta 0
key_temp dta 0
type_base dta 0,3,6,9,12
direction_offsets dta 0,11,22,33
neighbours
        dta 5,5,5,0,2,5,3,3,3,4,4 ; up
        dta 3,3,4,7,9,1,6,7,8,9,10 ; down into army
        dta 0,0,1,3,3,0,6,6,7,8,9 ; left
        dta 1,2,2,4,4,2,7,8,9,10,10 ; right

.proc draw_city
        lda screen_mode
        cmp #2
        bne ?not_battle
        jmp battle.draw
?not_battle
        cmp #0
        beq ?city
        jmp draw_encounters
?city
        mva #0 dirty
        lda back_bank
        sta render_bank
        jsr copy_background_cache
        ; Ground selection is drawn before all sprites, preserving depth.
        ldx selected_plot
        cpx #5
        bcs ?buildings
        lda plot_x,x
        sta calc_x
        mva #0 calc_x+1
        lda plot_y,x
        clc
        adc #48
        sta calc_y
        mwa #56 fr_w
        mva #16 fr_h
        mva #2 fr_col
        jsr outline
?buildings
        mva #0 draw_plot
?plot   ldx draw_plot
        lda plot_x,x
        sta calc_x
        mva #0 calc_x+1
        lda plot_y,x
        sta calc_y
        lda building_levels,x
        beq ?empty
        sec
        sbc #1
        clc
        adc type_base,x
        jsr draw_building
        jmp ?next
?empty  lda calc_x
        clc
        adc #23
        sta text_x
        mva #0 text_x+1
        lda calc_y
        clc
        adc #47
        sta text_y
        mwa #s_plus text_src
        jsr draw_text
?next   inc draw_plot
        lda draw_plot
        cmp #5
        bne ?plot
        jsr draw_header
        jsr draw_city_gate
        jsr draw_city_hud
        lda popup_open
        beq ?present
        jsr draw_popup
?present
        jsr wait_blit
        jmp present_back_buffer
.endp
draw_plot dta 0

.proc draw_header
        rect 0,0,320,16,1
        rect 0,15,320,1,2
        jsr selection_name_pointer
        mwa #8 text_x
        mva #4 text_y
        jsr draw_text
        labeltext 214,4,s_gold
        mwa gold number_value
        jsr format_number
        labeltext 248,4,number_text
        rts
.endp

.proc draw_city_hud
        rect 0,158,320,42,1
        rect 0,158,320,1,2
        mva #0 draw_slot
?slot   ldx draw_slot
        lda slot_x,x
        sta calc_x
        mva #0 calc_x+1
        mva #162 calc_y
        mwa #58 fr_w
        mva #35 fr_h
        mva #7 fr_col
        jsr fill_rect
        ldx draw_slot
        lda slot_x,x
        sta calc_x
        mva #162 calc_y
        mwa #58 fr_w
        mva #35 fr_h
        mva #4 fr_col
        lda screen_mode
        bne ?border
        txa
        clc
        adc #6
        cmp selected_plot
        bne ?border
        mva #2 fr_col
?border jsr outline
        ldx draw_slot
        cpx army_capacity
        bcc ?unlocked
        lda slot_x,x
        clc
        adc #11
        sta text_x
        lda #0
        adc #0
        sta text_x+1
        mva #176 text_y
        mwa #s_locked_slot text_src
        jsr draw_text
        jmp ?next
?unlocked
        lda army_units,x
        cmp #255
        beq ?next
        sta portrait_index
        lda slot_x,x
        clc
        adc #13
        sta calc_x
        lda #0
        adc #0
        sta calc_x+1
        mva #164 calc_y
        lda portrait_index
        jsr draw_portrait
        ; Three small pips communicate tier without textual labels.
        mva #0 pip_index
?pips   ldx draw_slot
        lda army_units,x
        tay
        lda unit_tier,y
        cmp pip_index
        beq ?next
        lda slot_x,x
        sta calc_x
        mva #0 calc_x+1
        ldx pip_index
        lda pip_offsets,x
        clc
        adc #21
        clc
        adc calc_x
        sta calc_x
        lda #0
        adc #0
        sta calc_x+1
        mva #193 calc_y
        mwa #3 fr_w
        mva #2 fr_h
        mva #2 fr_col
        jsr fill_rect
        inc pip_index
        lda pip_index
        cmp #3
        bne ?pips
?next   inc draw_slot
        lda draw_slot
        cmp #5
        beq ?done
        jmp ?slot
?done   rts
.endp
slot_x dta 7,69,131,193,255
draw_slot dta 0
portrait_index dta 0
pip_index dta 0
pip_offsets dta 0,6,12

.proc draw_portrait
        cmp #6
        bcc ?standard
        cmp #9
        bcs ?standard
        pha
        mva #255 battle.draw_id
        pla
        jmp battle.hero_sprite
?standard tax
        lda portrait_lo,x
        sta bl_src
        lda portrait_hi,x
        sta bl_src+1
        mva #4 bl_src+2
        mwa #32 bl_ssy
        mwa #31 bl_w
        mva #27 bl_h
        jmp transparent_blit
.endp

        icl 'army-ui.inc'

; A is building*3+tier-1. calc_x/calc_y are the top-left of its 56x64 cell.
.proc draw_building
        tax
        lda sprite_lo,x
        sta bl_src
        lda sprite_hi,x
        sta bl_src+1
        mva #3 bl_src+2
        mwa #SPRITE_W bl_ssy
        mwa #SPRITE_W-1 bl_w
        mva #SPRITE_H-1 bl_h
        jmp transparent_blit
.endp

.proc transparent_blit
        jsr calc_addr
        mva calc_out bl_dst
        mva calc_out+1 bl_dst+1
        mva calc_out+2 bl_dst+2
        mwa #320 bl_dsy
        mva #1 bl_ssx
        sta bl_dsx
        sta bl_mode
        mva #255 bl_and
        mva #0 bl_xor
        jmp do_blit
.endp

; ASCII, 0 terminated; all game text uses a transparent 5x7 font.
.proc draw_text
        mva #0 text_index
?next   ldy text_index
        lda (text_src),y
        beq ?done
        sec
        sbc #32
        tax
        lda glyph_lo,x
        sta bl_src
        lda glyph_hi,x
        sta bl_src+1
        mva #3 bl_src+2
        mwa #6 bl_ssy
        mwa #5 bl_w
        mva #7 bl_h
        mwa text_x calc_x
        mva text_y calc_y
        jsr transparent_blit
        clc
        lda text_x
        adc #6
        sta text_x
        bcc ?no_carry
        inc text_x+1
?no_carry
        inc text_index
        jmp ?next
?done   rts
.endp
text_x dta a(0)
text_y dta 0
text_index dta 0

; 16-bit decimal conversion, right aligned, independent of decimal CPU mode.
.proc format_number
        mva #0 number_started
        ldx #0
?digit  mva #48 number_text,x
?sub    lda number_value+1
        cmp decimal_hi,x
        bcc ?emit
        bne ?subtract
        lda number_value
        cmp decimal_lo,x
        bcc ?emit
?subtract
        sec
        lda number_value
        sbc decimal_lo,x
        sta number_value
        lda number_value+1
        sbc decimal_hi,x
        sta number_value+1
        inc number_text,x
        jmp ?sub
?emit   lda number_text,x
        cmp #48
        bne ?started
        cpx #4
        beq ?advance
        lda number_started
        bne ?advance
        mva #32 number_text,x
        jmp ?advance
?started
        mva #1 number_started
?advance
        inx
        cpx #5
        bne ?digit
        rts
.endp
number_value dta a(0)
number_started dta 0
number_text dta c'00000',0
decimal_lo dta <10000,<1000,<100,<10,<1
decimal_hi dta >10000,>1000,>100,>10,>1
one_char dta c'0',0

; Outline uses the same rectangle input as fill_rect, preserves its geometry.
.proc outline
        mwa calc_x outline_x
        mva calc_y outline_y
        mwa fr_w outline_w
        mva fr_h outline_h
        mva #1 fr_h
        jsr fill_rect
        lda outline_y
        clc
        adc outline_h
        sec
        sbc #1
        sta calc_y
        jsr fill_rect
        mva outline_y calc_y
        mva outline_h fr_h
        mwa #1 fr_w
        jsr fill_rect
        clc
        lda outline_x
        adc outline_w
        sta calc_x
        lda outline_x+1
        adc outline_w+1
        sta calc_x+1
        lda calc_x
        bne ?low
        dec calc_x+1
?low    dec calc_x
        jmp fill_rect
.endp
outline_x dta a(0)
outline_y dta 0
outline_w dta a(0)
outline_h dta 0

.proc load_city_palette
        lda #1
reg_psel
        sta VBXE_PSEL
        lda #0
reg_csel
        sta VBXE_CSEL
        mwa #city_palette data_ptr
        ldx #0
?color  ldy #0
        lda (data_ptr),y
reg_red
        sta VBXE_CR
        iny
        lda (data_ptr),y
reg_green
        sta VBXE_CG
        iny
        lda (data_ptr),y
reg_blue
        sta VBXE_CB
        clc
        lda data_ptr
        adc #3
        sta data_ptr
        bcc ?same_page
        inc data_ptr+1
?same_page
        inx
        bne ?color
        rts
.endp

s_title dta c'GREENHAVEN',0
s_gold dta c'GOLD',0
s_level dta c'LEVEL',0
s_of_three dta c'/ 3',0
s_of_five dta c'/ 5',0
s_army dta c'ARMY',0
s_empty dta c'EMPTY PLOT - READY TO BUILD',0
s_updated dta c'ARMY UPDATED - FIRE TO INSPECT',0
s_controls dta c'JOY/WASD: SELECT   FIRE/ENTER: INSPECT',0
s_popup_help dta c'JOY: CHOOSE  FIRE: OK  ESC/SELECT: BACK',0
s_arrow dta c'>',0
s_max dta c'MAX LEVEL',0
s_replace dta c'UPGRADE UNIT TO',0
s_recruit dta c'RECRUIT CURRENT UNIT',0
s_current dta c'CURRENT UNIT',0
s_hp dta c'HP',0
s_attack dta c'ATK',0
s_range dta c'RNG',0
s_cost dta c'COST',0
s_complete dta c'FULLY UPGRADED',0
s_poor dta c'NOT ENOUGH GOLD',0
s_upgrade dta c'UPGRADE',0
s_build dta c'BUILD',0
s_back dta c'BACK',0
s_plus dta c'+',0
s_missing dta 13,d'VBXE REQUIRED'
        icl 'encounters.inc'
        icl 'battle.inc'
        icl 'generated/content.inc'
city_palette
        ins 'generated/palette.bin'
        icl 'vbxe.inc'
display_list
        dta $42,a(text_screen)
        :24 dta $02
        dta $41,a(display_list)
code_end
        ert code_end>$6000
        ini loader_init
        icl 'generated/uploads.inc'
        org $8000
text_screen
        :1024 dta 0
        run main
