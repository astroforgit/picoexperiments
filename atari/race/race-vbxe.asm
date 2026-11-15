; Bikini Race - Atari XL/XE VBXE port of Pico Off Road
; Course layouts and waypoint order extracted from Assembler Bot's Pico-8 game.
; MADS 2.x. Joystick 0: up accelerate, down reverse, left/right steer, fire nitro.

SDMCTL=$022f
PORTA=$d300
PORTB=$d301
STRIG0=$d010
STRIG1=$d011
CONSOL=$d01f
RTCLOK=$12
CH=$02fc
DMACTL=$d400
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
text_ptr=$d0
course_ptr=$d2
waypoint_ptr=$d4
start_ptr=$d6
visual_map_ptr=$d8
route_ptr=$da

        org $2000
main
        lda PORTB
        ora #2
        sta PORTB
        jsr detect
        bcs found
        lda #$34
        sta $02c8
        jmp *
found   lda #0
        sta SDMCTL
        sta DMACTL
        lda #$98
reg_memac sta MEMAC
        jsr setup_xdl
        jsr setup_blitter
        jsr palette
        jsr upload_tiles
        jsr enable_vbxe
        lda #5                  ; draw first frame at VRAM $050000
        sta framebuffer_bank
        jsr select_course
        jsr build_map
        lda #0
        sta mode
        sta prev_input
frame   lda RTCLOK+2
waitf   cmp RTCLOK+2
        beq waitf
        lda mode
        beq menu_frame
        cmp #2
        beq results_frame
        jsr controls
        jsr update_race
        jsr render_race
        jsr present_frame
        jmp frame
menu_frame
        jsr menu_controls
        jsr render_menu
        jsr present_frame
        jmp frame
results_frame
        jsr results_controls
        jsr render_results
        jsr present_frame
        jmp frame

; The XEX loader calls this while the car mesh segment is present at $3600.
; The next XEX segment reuses that RAM for the original track graphics.
init_font_stage
        lda PORTB
        ora #2
        sta PORTB
        jsr detect
        bcc font_stage_done
        lda #$98
reg_font_memac sta MEMAC
        jsr upload_font
font_stage_done
        rts

init_car_stage
        lda PORTB
        ora #2
        sta PORTB
        jsr detect
        bcc car_stage_done
        lda #$98
reg_stage_memac sta MEMAC
        jsr upload_cars
car_stage_done
        rts

; Five XEX overlays reuse $3600 and upload a 320x160 title scene.
init_title_stage
        lda PORTB
        ora #2
        sta PORTB
        jsr detect
        bcc title_stage_done
        lda #$98
reg_title_memac sta MEMAC
        ldx title_stage_index
        lda title_stage_banks,x
        sta title_bank
        ora #$80
        jsr set_car_bank
        mwa #$3600 ptr
        lda #0
        sta zp2
        ldx title_stage_index
        lda title_stage_offsets,x
        sta zp2+1
        ldx #40
        jsr upload_title_pages
        inc title_stage_index
title_stage_done
        rts
title_stage_index dta 0
title_stage_banks dta $30,$32,$35,$37,$3a
title_stage_offsets dta $90,$98,$90,$98,$90

; All VBXE register operands are patched to D7xx if that page is detected.
detect  lda $d640
        cmp #$10
        beq d6
        lda $d740
        cmp #$10
        beq d7
        clc
        rts
d6      lda #$d6
        bne patch_regs
d7      lda #$d7
patch_regs
        sta patch_page+1
        mwa #reg_list ptr
        ldy #0
patch_next
        lda (ptr),y
        sta zp2
        iny
        lda (ptr),y
        sta zp2+1
        iny
patch_page lda #$d6
        ldx #0
        sta (zp2,x)
        cpy #reg_list_end-reg_list
        bne patch_next
        sec
        rts
reg_list
        dta a(reg_memac+2),a(reg_stage_memac+2),a(reg_font_memac+2),a(reg_xdl_bank+2)
        dta a(reg_bl0+2),a(reg_bl1+2),a(reg_bl2+2)
        dta a(reg_psel+2),a(reg_csel+2),a(reg_cr+2),a(reg_cg+2),a(reg_cb+2)
        dta a(reg_font_bank+2),a(reg_vctl+2),a(reg_xdl0+2),a(reg_xdl1+2),a(reg_xdl2+2)
        dta a(reg_title_memac+2)
        dta a(reg_car_bank+2)
        dta a(reg_blwait+2),a(reg_blbank+2),a(reg_blstart+2)
        dta a(reg_present_xdl0+2)
reg_list_end

setup_xdl
        lda #$ff
reg_xdl_bank sta BANKSEL
        ldx #xdl_end-xdl_data-1
xdl_copy lda xdl_data,x
        sta MEMW,x
        dex
        bpl xdl_copy
        rts
xdl_data
        dta $74,$08,7,0,0,0,$40,$01,$11,$ff
        dta $62,$88,199,0,0,0,$40,$01,$11,$ff
        :12 dta 0
        dta $74,$08,7,0,0,0,$40,$01,$11,$ff
        dta $62,$88,199,0,0,5,$40,$01,$11,$ff
xdl_end
setup_blitter
        lda #0
reg_bl0 sta BLADR0
        lda #$f1
reg_bl1 sta BLADR1
        lda #7
reg_bl2 sta BLADR2
        rts
enable_vbxe
        lda #3
reg_vctl sta VCTL
        lda #0
reg_xdl0 sta XDL0
        lda #$f0
reg_xdl1 sta XDL1
        lda #7
reg_xdl2 sta XDL2
        rts
; Complete the hidden framebuffer, then switch XDLs during vertical blank.
present_frame
        jsr blwait
        lda RTCLOK+2
present_wait
        cmp RTCLOK+2
        beq present_wait
        lda framebuffer_bank
        beq present_front
        lda #$20
        bne present_switch
present_front
        lda #0
present_switch
reg_present_xdl0 sta XDL0
        lda framebuffer_bank
        eor #5
        sta framebuffer_bank
        rts
framebuffer_bank dta 5
palette
        lda #1
reg_psel sta PSEL
        ldx #0
pal_loop lda palette_data,x
        cmp #$ff
        beq pal_done
reg_csel sta CSEL
        lda palette_data+1,x
reg_cr  sta CR
        lda palette_data+2,x
reg_cg  sta CG
        lda palette_data+3,x
reg_cb  sta CB
        txa
        clc
        adc #4
        tax
        jmp pal_loop
pal_done rts
palette_data
        dta 0,6,13,20, 1,235,242,231, 2,246,204,80
        dta 3,56,170,203, 4,222,67,51, 5,106,218,91
        dta 6,178,178,188, 7,244,225,111, 8,84,52,30
        dta 9,47,31,22, 10,67,100,57, 11,83,130,68
        dta 12,101,151,74, 13,115,168,79, 14,133,182,86
        dta 15,142,146,114, 16,160,162,126, 17,179,177,138
        dta 18,192,190,146, 19,207,202,156
        dta 20,85,81,77, 21,100,96,89, 22,115,110,97
        dta 23,131,124,107, 24,146,138,117
        dta 25,101,65,39, 26,119,78,44, 27,136,91,49
        dta 28,152,105,55, 29,169,118,62
        dta 30,111,26,37, 31,24,57,116
        dta 32,0,0,0, 33,18,40,78, 34,30,89,160, 35,0,135,81
        dta 36,171,82,54, 37,95,87,79, 38,127,183,225, 39,255,241,232
        dta 40,36,151,242, 41,255,163,0, 42,255,236,39, 43,0,228,54
        dta 44,41,173,255, 45,93,161,219, 46,79,202,255, 47,255,204,170
        icl 'title-palette.asm'
        dta $ff

upload_font
        lda #$e1
reg_font_bank sta BANKSEL
        mwa #font_data ptr
        mwa #MEMW zp2
        ldx #16
font_page
        ldy #0
font_byte
        lda (ptr),y
        sta (zp2),y
        iny
        bne font_byte
        inc ptr+1
        inc zp2+1
        dex
        bne font_page
        rts
upload_title_pages
title_page
        ldy #0
title_byte
        lda (ptr),y
        sta (zp2),y
        iny
        bne title_byte
        inc ptr+1
        inc zp2+1
        lda zp2+1
        cmp #$a0
        bne title_page_done
        lda #$90
        sta zp2+1
        inc title_bank
        lda title_bank
        ora #$80
        jsr set_car_bank
title_page_done
        dex
        bne title_page
        rts
title_bank dta 0

; Upload one mesh sheet four times, recolouring body and trim for each racer.
; Each 28x24x16 sheet is $2a00 bytes; MEMAC advances every 4K bank.
upload_cars
        lda #$62
        sta car_bank
        lda #$e2
        jsr set_car_bank
        mwa #MEMW zp2
        lda #0
        sta car_upload_variant
car_variant_loop
        mwa #car_sprite_data ptr
        lda #42
        sta car_pages
car_page_loop
        ldy #0
car_byte_loop
        lda (ptr),y
        cmp #30
        beq car_body_byte
        cmp #31
        beq car_trim_byte
        jmp car_store_byte
car_body_byte
        ldx car_upload_variant
        lda car_body_colours,x
        jmp car_store_byte
car_trim_byte
        ldx car_upload_variant
        lda car_trim_colours,x
car_store_byte
        sta (zp2),y
        iny
        bne car_byte_loop
        inc ptr+1
        inc zp2+1
        lda zp2+1
        cmp #$a0
        bne car_page_done
        lda #$90
        sta zp2+1
        inc car_bank
        lda car_bank
        ora #$80
        jsr set_car_bank
car_page_done
        dec car_pages
        bne car_page_loop
        inc car_upload_variant
        lda car_upload_variant
        cmp #4
        bne car_variant_loop
        rts
set_car_bank
reg_car_bank sta BANKSEL
        rts
car_bank dta 0
car_pages dta 0
car_upload_variant dta 0
car_body_colours dta 4,5,3,2
car_trim_colours dta 30,10,31,26

; Expand 4-bit Pico-8 tiles to VBXE palette entries 32..47 at VRAM $70000.
upload_tiles
        lda #$70
        sta tile_bank
        lda #$f0
        jsr set_car_bank
        mwa #road_tile_data ptr
        mwa #MEMW zp2
        mwa #ROAD_TILE_BYTES tile_bytes_left
tile_unpack_loop
        ldy #0
        lda (ptr),y
        sta packed_pixel_pair
        and #15
        clc
        adc #32
        sta (zp2),y
        jsr advance_tile_destination
        lda packed_pixel_pair
        lsr
        lsr
        lsr
        lsr
        clc
        adc #32
        ldy #0
        sta (zp2),y
        jsr advance_tile_destination
        inc ptr
        bne tile_source_advanced
        inc ptr+1
tile_source_advanced
        lda tile_bytes_left
        bne tile_count_low
        dec tile_bytes_left+1
tile_count_low
        dec tile_bytes_left
        lda tile_bytes_left
        ora tile_bytes_left+1
        bne tile_unpack_loop
        rts
advance_tile_destination
        inc zp2
        bne tile_destination_done
        inc zp2+1
        lda zp2+1
        cmp #$a0
        bne tile_destination_done
        lda #$90
        sta zp2+1
        inc tile_bank
        lda tile_bank
        ora #$80
        jsr set_car_bank
tile_destination_done
        rts
tile_bank dta 0
tile_bytes_left dta a(0)
packed_pixel_pair dta 0

; VBXE blitter command. Width/height are actual sizes; encoded as size-1.
bl_src dta 0,0,0
bl_ssy dta a(0)
bl_ssx dta 1
bl_dst dta 0,0,0
bl_dsy dta a(320)
bl_dsx dta 1
bl_w dta a(7)
bl_h dta 7
bl_and dta 0
bl_xor dta 0
bl_mode dta 0
blit
blwait
reg_blwait lda BLITTER
        bne blwait
        lda #$ff
reg_blbank sta BANKSEL
        ldx #0
blit_copy
        lda bl_src,x
        sta MEMW+$100,x
        inx
        cpx #17
        bne blit_copy
        lda #0
        sta MEMW+$111
        sta MEMW+$112
        sta MEMW+$113
        lda bl_mode
        sta MEMW+$114
        lda #1
reg_blstart sta BLITTER
        rts

; fill rectangle: fx/fy, fw/fh, fc in the hidden framebuffer.
fx      dta a(0)
fy      dta 0
fw      dta a(8)
fh      dta 8
fc      dta 0
fill
        jsr screen_address
        lda #0
        sta bl_src
        sta bl_src+1
        sta bl_src+2
        sta bl_ssy
        sta bl_ssy+1
        lda #1
        sta bl_ssx
        lda fw
        sec
        sbc #1
        sta bl_w
        lda fw+1
        sbc #0
        sta bl_w+1
        lda fh
        sec
        sbc #1
        sta bl_h
        lda #0
        sta bl_and
        sta bl_mode
        lda fc
        sta bl_xor
        jmp blit
; address fy*320+fx in the hidden framebuffer.
screen_address
        lda fy
        lsr
        lsr
        clc
        adc fy
        sta bl_dst+1
        lda fy
        and #3
        tax
        lda times64,x
        clc
        adc fx
        sta bl_dst
        lda bl_dst+1
        adc fx+1
        sta bl_dst+1
        lda framebuffer_bank
        sta bl_dst+2
        rts
times64 dta 0,64,128,192

; font glyph: ASCII 32..95 at VRAM $61000, 8x8 source.
text_x   dta a(0)
text_y   dta 0
text_col dta 1
text
        ldy #0
text_next
        lda (text_ptr),y
        bne text_has_char
        jmp text_done
text_has_char
        sty text_saved_y
        sec
        sbc #32
        cmp #16
        bcc text_glyph_ready
        cmp #26
        bcs text_glyph_ready
        sec
        sbc #16
        tax
        lda digit_glyphs,x
text_glyph_ready
        sta glyph
        and #3
        tax
        lda times64,x
        sta bl_src
        lda glyph
        lsr
        lsr
        clc
        adc #$10
        sta bl_src+1
        lda #6
        sta bl_src+2
        mwa #8 bl_ssy
        lda #1
        sta bl_ssx
        mwa #320 bl_dsy
        lda #1
        sta bl_dsx
        mwa #7 bl_w
        lda #7
        sta bl_h
        lda text_col
        sta bl_and
        lda #0
        sta bl_xor
        lda #1
        sta bl_mode
        mwa text_x fx
        lda text_y
        sta fy
        jsr screen_address
        jsr blit
        ldy text_saved_y
text_skip
        clc
        lda text_x
        adc #8
        sta text_x
        bcc text_nocarry
        inc text_x+1
text_nocarry
        iny
        jmp text_next
text_done rts
text_saved_y dta 0
glyph dta 0
digit_glyphs dta 34,42,45,49,56,58,59,60,61,62

; The source cartridge has a 64x32 sprite map for each course. Render its
; exact 8x8 tiles once into a 512x256 VBXE bitmap at $10000.
select_course
        lda track
        asl
        tax
        lda course_ptrs,x
        sta course_ptr
        lda course_ptrs+1,x
        sta course_ptr+1
        lda waypoint_ptrs,x
        sta waypoint_ptr
        lda waypoint_ptrs+1,x
        sta waypoint_ptr+1
        lda start_ptrs,x
        sta start_ptr
        lda start_ptrs+1,x
        sta start_ptr+1
        lda road_map_ptrs,x
        sta visual_map_ptr
        lda road_map_ptrs+1,x
        sta visual_map_ptr+1
        lda ai_route_ptrs,x
        sta route_ptr
        lda ai_route_ptrs+1,x
        sta route_ptr+1
        lda track
        tax
        lda ai_route_lengths,x
        sta route_length
        rts
course_ptrs dta a(track1,track2,track3)
waypoint_ptrs dta a(waypoints1,waypoints2,waypoints3)
start_ptrs dta a(starts1,starts2,starts3)
road_map_ptrs dta a(road_map1,road_map2,road_map3)

build_map
        mwa visual_map_ptr ptr
        lda #0
        sta tile_col
        sta tile_row
        sta map_index
        sta map_index+1
map_loop
        ldy #0
        lda (ptr),y
        sta tile_value
        and #3
        tax
        lda times64,x
        sta bl_src
        lda tile_value
        lsr
        lsr
        sta bl_src+1
        lda #7
        sta bl_src+2
        mwa #8 bl_ssy
        lda #1
        sta bl_ssx
        ; Map destination = $10000 + row*$1000 + col*8.
        lda tile_col
        asl
        asl
        asl
        sta bl_dst
        lda tile_col
        lsr
        lsr
        lsr
        lsr
        lsr
        sta map_hi
        lda tile_row
        and #15
        asl
        asl
        asl
        asl
        clc
        adc map_hi
        sta bl_dst+1
        lda tile_row
        lsr
        lsr
        lsr
        lsr
        clc
        adc #1
        sta bl_dst+2
        mwa #512 bl_dsy
        lda #1
        sta bl_dsx
        mwa #7 bl_w
        lda #7
        sta bl_h
        lda #$ff
        sta bl_and
        lda #0
        sta bl_xor
        sta bl_mode
        jsr blit
        inc ptr
        bne map_ptr_ok
        inc ptr+1
map_ptr_ok
        inc tile_col
        lda tile_col
        cmp #64
        bne map_advance
        lda #0
        sta tile_col
        inc tile_row
map_advance
        inc map_index
        bne map_check
        inc map_index+1
map_check
        lda map_index+1
        cmp #8
        beq map_finished
        jmp map_loop
map_finished
        rts
tile_col dta 0
tile_row dta 0
tile_value dta 0
map_hi dta 0
map_index dta a(0)

; Main menu. Up/down chooses a course, fire/START starts.
menu_controls
        jsr read_input
        lda input_edge
        and #1
        beq menu_down
        lda track
        beq menu_down
        dec track
        jsr select_course
        jsr build_map
menu_down
        lda input_edge
        and #2
        beq menu_left
        lda track
        cmp #2
        beq menu_left
        inc track
        jsr select_course
        jsr build_map
menu_left
menu_start
        lda input_edge
        and #16
        bne begin_race
        lda CONSOL
        and #1
        bne menu_return
begin_race
        jsr init_race
menu_return rts

init_race
        jsr select_course
        jsr build_map
        lda #1
        sta mode
        lda #0
        sta frame_count
        sta winner
        sta turbo
        sta reverse_flag
        sta impact_cooldown
        sta heading
        lda #4
        sta heading
        lda #1
        sta next_waypoint
        lda #0
        sta lap
        sta speed
        ; Starting grid: first two bytes in the chosen course's start list.
        ldy #0
        lda (start_ptr),y
        sta car_x
        iny
        lda (start_ptr),y
        sta car_x+1
        iny
        lda (start_ptr),y
        sta car_z
        iny
        lda (start_ptr),y
        sta car_z+1
        ldx #0
init_ai
        txa
        asl
        asl
        clc
        adc #4
        tay
        lda (start_ptr),y
        sta ai_x,x
        iny
        lda (start_ptr),y
        sta ai_x_hi,x
        iny
        lda (start_ptr),y
        sta ai_z,x
        iny
        lda (start_ptr),y
        sta ai_z_hi,x
        lda #0
        sta ai_next,x
        lda #0
        sta ai_lap,x
        sta ai_heading,x
        sta ai_impact_time,x
        inx
        cpx #3
        bne init_ai
        rts

read_input
        lda PORTA
        eor #$ff
        sta joystick_bits
        and #15
        sta input
        lda joystick_bits
        lsr
        lsr
        lsr
        lsr
        ora input
        sta input
        lda STRIG0
        beq joystick_fire
        lda STRIG1
        bne no_fire
joystick_fire
        lda input
        ora #16
        sta input
no_fire
        lda CH
        cmp #$21                ; Atari SPACE scan code
        bne no_space
        lda #$ff
        sta CH
        lda input
        ora #16
        sta input
no_space
        lda input
        eor prev_input
        and input
        sta input_edge
        lda input
        sta prev_input
        rts

controls
        jsr read_input
        lda frame_count
        and #1
        bne accelerate
        lda input
        and #4
        beq turn_right
        dec heading
        lda heading
        and #15
        sta heading
turn_right
        lda input
        and #8
        beq accelerate
        inc heading
        lda heading
        and #15
        sta heading
accelerate
        lda input
        and #1
        beq reverse
        lda reverse_flag
        beq forward_accel
        lda speed
        beq clear_reverse
        dec speed
        bne nitro_input
clear_reverse
        lda #0
        sta reverse_flag
        jmp nitro_input
forward_accel
        lda speed
        cmp #4
        bcs nitro_input
        inc speed
        jmp nitro_input
reverse
        lda input
        and #2
        beq coast
        lda reverse_flag
        beq brake_forward
        lda speed
        cmp #2
        bcs nitro_input
        inc speed
        jmp nitro_input
brake_forward
        lda speed
        beq engage_reverse
        dec speed
        jmp nitro_input
engage_reverse
        lda #1
        sta reverse_flag
        sta speed
        jmp nitro_input
coast   lda frame_count
        and #7
        bne nitro_input
        lda speed
        beq nitro_input
        dec speed
nitro_input
        lda reverse_flag
        bne no_nitro
        lda input
        and #16
        beq no_nitro
        lda turbo
        cmp #100
        bcs no_nitro
        inc turbo
        lda speed
        cmp #6
        bcs no_nitro
        inc speed
no_nitro rts

update_race
        inc frame_count
        lda impact_cooldown
        beq impact_timer_done
        dec impact_cooldown
impact_timer_done
        lda speed
        sta move_count
move_player
        lda move_count
        beq player_done
        ldx heading
        lda dx,x
        sta step_x
        lda dz,x
        sta step_z
        lda reverse_flag
        beq forward_step
        lda step_x
        eor #$ff
        clc
        adc #1
        sta step_x
        lda step_z
        eor #$ff
        clc
        adc #1
        sta step_z
forward_step
        jsr player_step
        jsr check_car_impacts
        dec move_count
        jmp move_player
player_done
        jsr check_waypoint
        ; Each rival follows the driveable route at its own pace.
        ldx #0
ai_loop lda ai_speed,x
        sta ai_move_count
ai_move_loop
        jsr ai_step
        dec ai_move_count
        bne ai_move_loop
        inx
        cpx #3
        bne ai_loop
        jmp check_car_impacts

player_step
        lda car_x
        clc
        adc step_x
        sta candidate_x
        lda step_x
        bmi step_x_neg
        lda car_x+1
        adc #0
        jmp step_x_set
step_x_neg lda car_x+1
        adc #$ff
step_x_set and #1
        sta candidate_x+1
        lda car_z
        clc
        adc step_z
        sta candidate_z
        lda step_z
        bmi step_z_neg
        lda car_z+1
        adc #0
        jmp step_z_set
step_z_neg lda car_z+1
        adc #$ff
step_z_set
        bmi rebound_z
        cmp #2
        bcs rebound_z
        sta candidate_z+1
        jsr swept_step_clear
        bcc step_blocked
step_accept
        mwa candidate_x car_x
        mwa candidate_z car_z
        rts
step_blocked
        lda step_x
        beq rebound_z
        mwa car_z candidate_z
        jsr position_is_clear
        bcs rebound_z
rebound_x
        ; Slide along the x wall instead of reflecting across it.
        lda step_z
        bmi rebound_north
        bne rebound_south
        lda input
        and #8
        bne rebound_south
rebound_north
        lda #0
        jmp rebound_heading
rebound_south
        lda #8
        jmp rebound_heading
rebound_z
        ; A z wall uses the nearest east/west tangent.
        lda step_x
        bmi rebound_west
        bne rebound_east
        lda input
        and #8
        bne rebound_east
rebound_west
        lda #12
        jmp rebound_heading
rebound_east
        lda #4
rebound_heading
        and #15
        sta heading
        lda #0
        sta reverse_flag
        jsr soften_impact_speed
        rts
soften_impact_speed
        lda speed
        beq impact_from_rest
        cmp #3
        bcc impact_speed_done
        dec speed
impact_speed_done
        rts
impact_from_rest
        lda #1
        sta speed
        rts
step_x dta 0
step_z dta 0
candidate_x dta a(0)
candidate_z dta a(0)

; Keep a short impact window so overlapping sprites cause one decisive shove.
check_car_impacts
        lda impact_cooldown
        beq impact_ready
        rts
impact_ready
        ldx #0
impact_car_loop
        lda car_x
        sec
        sbc ai_x,x
        sta impact_dx
        lda car_x+1
        sbc ai_x_hi,x
        and #1
        sta impact_dx_hi
        beq impact_x_positive
        lda impact_dx
        cmp #245
        bcs impact_check_z
        jmp impact_next
impact_x_positive
        lda impact_dx
        cmp #12
        bcc impact_check_z
        jmp impact_next
impact_check_z
        lda car_z
        sec
        sbc ai_z,x
        sta impact_dz
        lda car_z+1
        sbc ai_z_hi,x
        beq impact_z_positive
        cmp #$ff
        bne impact_next
        lda impact_dz
        cmp #245
        bcc impact_next
        jmp impact_hit
impact_z_positive
        lda impact_dz
        cmp #12
        bcs impact_next
impact_hit
        lda #12
        sta impact_cooldown
        lda #16
        sta ai_impact_time,x
        jsr soften_impact_speed
        lda #0
        sta reverse_flag
        lda impact_dx_hi
        beq impact_right
        lda heading
        sec
        sbc #2
        and #15
        sta heading
        lda ai_heading,x
        clc
        adc #2
        and #15
        sta ai_heading,x
        rts
impact_right
        lda heading
        clc
        adc #2
        and #15
        sta heading
        lda ai_heading,x
        sec
        sbc #2
        and #15
        sta ai_heading,x
impact_done
        rts
impact_next
        inx
        cpx #3
        beq impact_done
        jmp impact_car_loop

; The course tile under the car center is the one collision authority.
position_is_clear
        jsr tile_at_candidate
        bmi position_clear
        and #15
        cmp #6
        bcc position_clear
        cmp #11
        bcc position_blocked
position_clear
        sec
        rts
position_blocked
        clc
        rts
; Signed 16 compass headings: 0 north, 4 east, 8 south, 12 west.
dx dta 0,1,1,2,2,2,1,1,0,$ff,$ff,$fe,$fe,$fe,$ff,$ff
dz dta $fe,$fe,$ff,$ff,0,1,1,2,2,2,1,1,0,$ff,$ff,$fe

; Read tile at candidate_x, candidate_z. Map uses 64 tiles per row.
tile_at_candidate
        lda candidate_z
        lsr
        lsr
        lsr
        and #3
        tax
        lda tile_low64,x
        sta tile_index
        lda candidate_x
        lsr
        lsr
        lsr
        ora tile_index
        sta tile_index
        lda candidate_x+1
        and #1
        asl
        asl
        asl
        asl
        asl
        ora tile_index
        sta tile_index
        lda candidate_z
        lsr
        lsr
        lsr
        lsr
        lsr
        sta tile_index+1
        lda candidate_z+1
        and #1
        asl
        asl
        asl
        ora tile_index+1
        sta tile_index+1
        lda tile_index
        clc
        adc course_ptr
        sta ptr
        lda tile_index+1
        adc course_ptr+1
        sta ptr+1
        ldy #0
        lda (ptr),y
        rts
tile_index dta a(0)
tile_low64 dta 0,64,128,192

check_waypoint
        mwa car_x candidate_x
        mwa car_z candidate_z
        jsr tile_at_candidate
        bpl no_waypoint
        and #$0f
        cmp next_waypoint
        bne no_waypoint
        inc next_waypoint
        lda next_waypoint
        cmp #15
        bne waypoint_test_zero
        lda #0
        sta next_waypoint
        rts
waypoint_test_zero
        cmp #1
        bne no_waypoint
        inc lap
        lda lap
        cmp laps
        bcc no_waypoint
        lda #2
        sta mode
no_waypoint rts

; Each rival advances between safe turn points on the selected course.
ai_step
        stx ai_index
        lda ai_impact_time,x
        beq ai_route_step
        dec ai_impact_time,x
        rts
ai_route_step
        lda ai_next,x
        asl
        tay
        lda (route_ptr),y
        sta route_coord
        asl
        asl
        asl
        clc
        adc #4
        sta target_x
        lda route_coord
        lsr
        lsr
        lsr
        lsr
        lsr
        sta target_x+1
        iny
        lda (route_ptr),y
        sta target_dir
        and #63
        sta route_coord
        asl
        asl
        asl
        clc
        adc #4
        sta target_z
        lda route_coord
        lsr
        lsr
        lsr
        lsr
        lsr
        sta target_z+1
        lda target_dir
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        sta target_dir
        ldx ai_index
        lda ai_x,x
        sec
        sbc target_x
        sta delta_x
        lda ai_x_hi,x
        sbc target_x+1
        sta delta_x+1
        ; The course wraps horizontally; choose the shorter direction.
        cmp #1
        bne ai_delta_x_negative
        lda #$ff
        sta delta_x+1
        jmp ai_delta_x_done
ai_delta_x_negative
        cmp #$fe
        bne ai_delta_x_done
        lda #0
        sta delta_x+1
ai_delta_x_done
        lda ai_z,x
        sec
        sbc target_z
        sta delta_z
        lda ai_z_hi,x
        sbc target_z+1
        sta delta_z+1
        ; Move to the exact turn before steering around a wall.
        lda delta_x+1
        bmi ai_right
        cmp #1
        beq ai_right
        lda delta_x
        cmp #1
        bcc ai_x_near
        lda #$ff
        sta step_x
        jmp ai_z_dir
ai_right
        lda delta_x+1
        cmp #$fe
        beq ai_left
        lda #1
        sta step_x
        jmp ai_z_dir
ai_left
        lda #$ff
        sta step_x
        jmp ai_z_dir
ai_x_near lda #0
        sta step_x
ai_z_dir
        lda delta_z+1
        bmi ai_down
        lda delta_z
        cmp #1
        bcc ai_z_near
        lda #$ff
        sta step_z
        jmp ai_steer
ai_down lda #1
        sta step_z
        jmp ai_steer
ai_z_near lda #0
        sta step_z
ai_steer
        lda target_dir
        cmp #2
        bcs ai_vertical_route
        lda step_z
        bne ai_align_z
        lda step_x
        beq ai_move
        lda target_dir
        beq ai_force_east
        lda #$ff
        bne ai_set_x
ai_force_east
        lda #1
ai_set_x sta step_x
        jmp ai_move
ai_align_z
        lda #0
        sta step_x
        jmp ai_move
ai_vertical_route
        lda step_x
        bne ai_align_x
        lda step_z
        beq ai_move
        lda target_dir
        cmp #2
        beq ai_force_south
        lda #$ff
        bne ai_set_z
ai_force_south
        lda #1
ai_set_z sta step_z
        jmp ai_move
ai_align_x
        lda #0
        sta step_z
ai_move lda step_x
        ora step_z
        beq ai_arrive
        jsr set_ai_heading
        ldx ai_index
        lda ai_x,x
        clc
        adc step_x
        sta candidate_x
        lda step_x
        bmi ai_x_negative
        lda ai_x_hi,x
        adc #0
        jmp ai_x_store
ai_x_negative lda ai_x_hi,x
        adc #$ff
ai_x_store and #1
        sta candidate_x+1
        lda ai_z,x
        clc
        adc step_z
        sta candidate_z
        lda step_z
        bmi ai_z_negative
        lda ai_z_hi,x
        adc #0
        jmp ai_z_store
ai_z_negative lda ai_z_hi,x
        adc #$ff
ai_z_store
        cmp #2
        bcs ai_wall_hit
        sta candidate_z+1
        jsr position_is_clear
        bcc ai_wall_hit
ai_commit
        ldx ai_index
        lda candidate_x
        sta ai_x,x
        lda candidate_x+1
        sta ai_x_hi,x
        lda candidate_z
        sta ai_z,x
        lda candidate_z+1
        sta ai_z_hi,x
        rts
ai_wall_hit
        ldx ai_index
        lda ai_heading,x
        clc
        adc #2
        and #15
        sta ai_heading,x
        lda #4
        sta ai_impact_time,x
        rts
ai_arrive
        ldx ai_index
        inc ai_next,x
        lda ai_next,x
        cmp route_length
        bne ai_return
        lda #0
        sta ai_next,x
        inc ai_lap,x
        lda ai_lap,x
        cmp laps
        bcc ai_return
        lda mode
        cmp #1
        bne ai_return
        txa
        clc
        adc #1
        sta winner
        lda #2
        sta mode
ai_return
        ldx ai_index
        rts
set_ai_heading
        lda step_x
        beq ai_heading_vertical
        bmi ai_heading_left
        lda step_z
        beq ai_heading_east
        bmi ai_heading_northeast
        lda #6
        bne ai_heading_store
ai_heading_east
        lda #4
        bne ai_heading_store
ai_heading_northeast
        lda #2
        bne ai_heading_store
ai_heading_left
        lda step_z
        beq ai_heading_west
        bmi ai_heading_northwest
        lda #10
        bne ai_heading_store
ai_heading_west
        lda #12
        bne ai_heading_store
ai_heading_northwest
        lda #14
        bne ai_heading_store
ai_heading_vertical
        lda step_z
        bmi ai_heading_north
        lda #8
        bne ai_heading_store
ai_heading_north
        lda #0
ai_heading_store
        ldx ai_index
        sta ai_heading,x
        rts
ai_index dta 0
route_coord dta 0
ai_move_count dta 0
ai_speed dta 5,6,7
route_length dta 0
target_x dta a(0)
target_z dta a(0)
target_dir dta 0
delta_x dta a(0)
delta_z dta a(0)

; Project flat car coordinates into the track art without a height offset.
project_position
        lda candidate_z+1
        lsr
        lda candidate_z
        ror
        sta projected_y
        lda candidate_x
        sec
        sbc projected_y
        sta projected_x
        lda candidate_x+1
        sbc #0
        sta projected_x+1
        lda projected_x
        sec
        sbc #1
        sta projected_x
        lda projected_x+1
        sbc #0
        and #1
        sta projected_x+1
        rts
projected_x dta a(0)
projected_y dta 0

; Map crop, cars, HUD. Source 512-byte rows at VRAM $10000.
render_map
        mwa car_x candidate_x
        mwa car_z candidate_z
        jsr project_position
        lda projected_x
        sec
        sbc #160
        sta camera_x
        lda projected_x+1
        sbc #0
        sta camera_x+1
        bpl cam_x_positive
        mwa #0 camera_x
cam_x_positive
        lda camera_x+1
        bne cam_x_limit
        lda camera_x
        cmp #192
        bcc cam_x_ok
cam_x_limit
        mwa #192 camera_x
cam_x_ok
        lda projected_y
        sec
        sbc #80
        sta camera_z
        bcc cam_z_zero
        lda camera_z
        cmp #96
        bcc cam_z_ok
        lda #96
        bne cam_z_set
cam_z_zero
        lda #0
cam_z_set
        sta camera_z
cam_z_ok
        lda #0
        sta camera_z+1
        lda camera_z
        asl
        sta bl_src+1
        lda camera_z+1
        rol
        clc
        adc #1
        sta bl_src+2
        lda camera_x
        sta bl_src
        lda camera_x+1
        clc
        adc bl_src+1
        sta bl_src+1
        bcc map_source_ok
        inc bl_src+2
map_source_ok
        mwa #512 bl_ssy
        lda #1
        sta bl_ssx
        mwa #0 bl_dst
        lda framebuffer_bank
        sta bl_dst+2
        mwa #320 bl_dsy
        lda #1
        sta bl_dsx
        mwa #319 bl_w
        lda #159
        sta bl_h
        lda #$ff
        sta bl_and
        lda #0
        sta bl_xor
        sta bl_mode
        jmp blit
camera_x dta a(0)
camera_z dta a(0)

render_race
        jsr render_map
        mwa car_x candidate_x
        mwa car_z candidate_z
        lda #0
        sta car_variant_current
        lda heading
        sta car_direction
        jsr draw_car
        ldx #0
render_ai
        lda ai_x,x
        sta candidate_x
        lda ai_x_hi,x
        sta candidate_x+1
        lda ai_z,x
        sta candidate_z
        lda ai_z_hi,x
        sta candidate_z+1
        txa
        clc
        adc #1
        sta car_variant_current
        lda ai_heading,x
        sta car_direction
        stx ai_index
        jsr draw_car
        ldx ai_index
        inx
        cpx #3
        bne render_ai
        jsr hud
        rts

draw_car
        jsr project_position
        lda projected_x
        sec
        sbc camera_x
        sta fx
        lda projected_x+1
        sbc camera_x+1
        sta fx+1
        lda fx
        sec
        sbc #14
        sta fx
        lda fx+1
        sbc #0
        sta fx+1
        lda projected_y
        sec
        sbc camera_z
        sta fy
        lda #0
        sbc camera_z+1
        sta car_screen_hi
        lda fy
        sec
        sbc #12
        sta fy
        lda car_screen_hi
        sbc #0
        sta car_screen_hi
        lda #12
        sec
        sbc car_direction
        and #15
        sta car_sprite_idx
        lda car_variant_current
        asl
        asl
        asl
        asl
        ora car_sprite_idx
        sta car_sprite_idx
        asl
        clc
        adc car_sprite_idx
        tay
        lda car_sprite_addresses,y
        sta bl_src
        iny
        lda car_sprite_addresses,y
        sta bl_src+1
        iny
        lda car_sprite_addresses,y
        sta bl_src+2
        mwa #28 bl_ssy
        lda #1
        sta bl_ssx
        mwa #320 bl_dsy
        lda #1
        sta bl_dsx
        mwa #27 bl_w
        lda #23
        sta bl_h
        lda #$ff
        sta bl_and
        lda #0
        sta bl_xor
        lda #1
        sta bl_mode
        jsr clip_car
        bcc car_invisible
        jsr screen_address
        jsr blit
car_invisible rts
car_variant_current dta 0
car_direction dta 0
car_sprite_idx dta 0
car_screen_hi dta 0

hud     mwa #0 fx
        lda #160
        sta fy
        mwa #320 fw
        lda #40
        sta fh
        lda #9
        sta fc
        lda #0
        sta bl_dst+2
        jsr fill
        lda lap
        clc
        adc #'1'
        sta hud_lap+4
        lda laps
        clc
        adc #'0'
        sta hud_lap+6
        lda track
        clc
        adc #'1'
        sta hud_track+6
        lda turbo
        lsr
        lsr
        lsr
        lsr
        clc
        adc #'0'
        sta hud_nitro+6
        mwa #hud_lap text_ptr
        mwa #8 text_x
        lda #165
        sta text_y
        lda #1
        sta text_col
        jsr text
        mwa #hud_track text_ptr
        mwa #112 text_x
        jsr text
        mwa #hud_nitro text_ptr
        mwa #216 text_x
        jsr text
        mwa #hud_help text_ptr
        mwa #8 text_x
        lda #181
        sta text_y
        lda #2
        sta text_col
        jmp text
hud_lap dta c'LAP 1/4',0
hud_track dta c'TRACK 1',0
hud_nitro dta c'NITRO 0',0
hud_help dta c'UP GAS  FIRE NITRO  LEFT RIGHT STEER',0

render_menu
        mwa #0 fx
        lda #160
        sta fy
        mwa #320 fw
        lda #40
        sta fh
        lda #0
        sta fc
        jsr fill
        jsr draw_title_scene
        mwa #0 fx
        lda #160
        sta fy
        mwa #320 fw
        lda #2
        sta fh
        lda #44
        sta fc
        jsr fill
        mwa #menu_author text_ptr
        mwa #216 text_x
        lda #165
        sta text_y
        lda #2
        sta text_col
        jsr text
        lda track
        clc
        adc #'1'
        sta menu_track+6
        mwa #menu_track text_ptr
        mwa #16 text_x
        lda #179
        sta text_y
        lda #1
        sta text_col
        jsr text
        mwa #menu_help text_ptr
        mwa #184 text_x
        lda #179
        sta text_y
        lda #2
        sta text_col
        jmp text
draw_title_scene
        mwa #0 bl_src
        lda #3
        sta bl_src+2
        mwa #320 bl_ssy
        lda #1
        sta bl_ssx
        mwa #320 bl_dsy
        lda #1
        sta bl_dsx
        mwa #319 bl_w
        lda #159
        sta bl_h
        lda #$ff
        sta bl_and
        lda #0
        sta bl_xor
        lda #0
        sta bl_mode
        mwa #0 fx
        lda #0
        sta fy
        jsr screen_address
        jmp blit
menu_author dta c'BY ASTROFOR',0
menu_track dta c'TRACK 1  UP/DOWN',0
menu_help dta c'FIRE TO START',0

results_controls
        jsr read_input
        lda input_edge
        and #16
        bne results_back
        lda CONSOL
        and #1
        bne results_exit
results_back
        lda #0
        sta mode
results_exit rts
render_results
        jsr render_race
        mwa #24 fx
        lda #44
        sta fy
        mwa #272 fw
        lda #75
        sta fh
        lda #9
        sta fc
        lda #0
        sta bl_dst+2
        jsr fill
        lda winner
        beq result_player
        clc
        adc #'0'
        sta result_rival+6
        mwa #result_rival text_ptr
        jmp result_draw_title
result_player
        mwa #result_title text_ptr
result_draw_title
        mwa #72 text_x
        lda #55
        sta text_y
        lda #2
        sta text_col
        jsr text
        mwa #result_help text_ptr
        mwa #50 text_x
        lda #89
        sta text_y
        lda #1
        sta text_col
        jmp text
result_title dta c'YOU WIN',0
result_rival dta c'RIVAL 1 WINS',0
result_help dta c'FIRE TO RETURN',0

mode dta 0
track dta 2
laps dta 4
lap dta 0
next_waypoint dta 1
heading dta 4
speed dta 0
reverse_flag dta 0
turbo dta 0
frame_count dta 0
winner dta 0
input dta 0
input_edge dta 0
prev_input dta 0
joystick_bits dta 0
move_count dta 0
car_x dta a(0)
car_z dta a(0)
ai_x :3 dta 0
ai_x_hi :3 dta 0
ai_z :3 dta 0
ai_z_hi :3 dta 0
ai_next :3 dta 1
ai_lap :3 dta 0
ai_heading :3 dta 0
ai_impact_time :3 dta 0
impact_cooldown dta 0
impact_dx dta 0
impact_dx_hi dta 0
impact_dz dta 0

        icl 'course-data.asm'
        icl 'ai-route-data.asm'
        icl 'car-sprite-addrs.asm'
        icl 'road-data.asm'

        org $3600
font_data ins 'font.bin'
        ini init_font_stage

        org $3600
title_scene_part1 ins 'title-part1.bin'
        ini init_title_stage

        org $3600
title_scene_part2 ins 'title-part2.bin'
        ini init_title_stage

        org $3600
title_scene_part3 ins 'title-part3.bin'
        ini init_title_stage

        org $3600
title_scene_part4 ins 'title-part4.bin'
        ini init_title_stage

        org $3600
title_scene_part5 ins 'title-part5.bin'
        ini init_title_stage

        org $3600
car_sprite_data ins 'car-sprites.bin'
        ini init_car_stage

        org $3600
road_tile_data ins 'road-assets.bin'

; Clip car sprites at all four viewport edges. Their source rows remain 28
; pixels wide even when the visible destination rectangle is narrower.
clip_car
        lda fx+1
        beq clip_y_start
        cmp #$ff
        beq clip_left
        cmp #1
        bne clip_x_reject
        lda fx
        cmp #64
        bcs clip_x_reject
        cmp #37
        bcc clip_y_start
        sta clip_count
        lda #63
        sec
        sbc clip_count
        sta bl_w
        jmp clip_y_start
clip_x_reject
        jmp clip_reject
clip_left
        lda fx
        cmp #229
        bcc clip_reject
        eor #$ff
        clc
        adc #1
        sta clip_count
        lda #0
        sta fx
        sta fx+1
        lda #27
        sec
        sbc clip_count
        sta bl_w
        lda clip_count
        jsr clip_source_add
clip_y_start
        lda car_screen_hi
        beq clip_y_positive
        cmp #$ff
        bne clip_reject
        lda fy
        cmp #233
        bcc clip_reject
        eor #$ff
        clc
        adc #1
        sta clip_count
        lda #0
        sta fy
        lda #23
        sec
        sbc clip_count
        sta bl_h
        ldx clip_count
clip_top_row
        lda #28
        jsr clip_source_add
        dex
        bne clip_top_row
        sec
        rts
clip_y_positive
        lda fy
        cmp #160
        bcs clip_reject
        cmp #137
        bcc clip_accept
        sta clip_count
        lda #159
        sec
        sbc clip_count
        sta bl_h
clip_accept
        sec
        rts
clip_reject
        clc
        rts
clip_source_add
        clc
        adc bl_src
        sta bl_src
        lda bl_src+1
        adc #0
        sta bl_src+1
        lda bl_src+2
        adc #0
        sta bl_src+2
        rts
clip_count dta 0

        org $5f40
; A fast car checks the midpoint as well as the end of each movement step.
swept_step_clear
        mwa candidate_x sweep_end_x
        mwa candidate_z sweep_end_z
        lda car_x
        sta candidate_x
        lda car_x+1
        sta candidate_x+1
        lda step_x
        beq sweep_z
        bmi sweep_x_back
        inc candidate_x
        bne sweep_z
        inc candidate_x+1
        jmp sweep_z
sweep_x_back
        dec candidate_x
        lda candidate_x
        cmp #$ff
        bne sweep_z
        dec candidate_x+1
sweep_z
        lda candidate_x+1
        and #1
        sta candidate_x+1
        lda car_z
        sta candidate_z
        lda car_z+1
        sta candidate_z+1
        lda step_z
        beq sweep_probe
        bmi sweep_z_back
        inc candidate_z
        bne sweep_probe
        inc candidate_z+1
        jmp sweep_probe
sweep_z_back
        dec candidate_z
        lda candidate_z
        cmp #$ff
        bne sweep_probe
        dec candidate_z+1
sweep_probe
        jsr position_is_clear
        php
        mwa sweep_end_x candidate_x
        mwa sweep_end_z candidate_z
        plp
        bcc sweep_done
        jsr position_is_clear
sweep_done
        rts
sweep_end_x dta a(0)
sweep_end_z dta a(0)

        org $6000
track1  ins 'track1.bin'
track2  ins 'track2.bin'
track3  ins 'track3.bin'

        run main
