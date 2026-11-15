; ------------------------------------------------------------------
; Rooms, _update and _draw
; ------------------------------------------------------------------

music
        .if PLAY_MUSIC
        sta mus_req
        .endif
        rts

title_screen
        ldx #31
        lda #0
ts_clr  sta got_fruit,x
        dex
        bpl ts_clr
        sta frames
        sta deaths
        sta deaths+1
        sta start_game
        sta start_game_flash
        sta seconds
        sta minutes
        sta minutes+1
        lda #1
        sta max_djump
        lda #40
        jsr music
        lda #7
        ldy #3
        jmp load_room

begin_game
        lda #0
        sta frames
        sta seconds
        sta minutes
        sta minutes+1
        sta music_timer
        sta start_game
        lda #10
        sta palflash
        lda #0
        jsr music
        lda #0
        tay
        jmp load_room

next_room
        lda room_y
        cmp #1
        bne nr_1
        lda room_x
        cmp #2
        beq nr_m30
        cmp #3
        bne nr_go
        lda #20
        jsr music
        jmp nr_go
nr_1    cmp #2
        bne nr_2
        lda room_x
        cmp #4
        beq nr_m30
        bne nr_go
nr_2    cmp #3
        bne nr_go
        lda room_x
        cmp #5
        bne nr_go
nr_m30  lda #30
        jsr music
nr_go   lda room_x
        cmp #7
        bne nr_right
        ldy room_y
        iny
        lda #0
        jmp load_room
nr_right
        clc
        adc #1
        ldy room_y
        jmp load_room

; load_room(A=x, Y=y)
load_room
        sta room_x
        sty room_y
        lda #0
        sta has_dashed
        sta has_key
        sta obj_count
        sta need_compact
        sta list_n
        sta list_n+1
        sta list_n+2
        sta list_n+3
        lda #$fe
        sta pl_idx
        lda #0
        lda #1
        sta room_changed
        lda room_y
        asl
        asl
        asl
        ora room_x
        sta lvl
        ; copy the room's 16x16 tiles out of VRAM ($28000)
        ldx #0
lr_row  stx tmp+4
        lda room_y
        asl
        asl
        asl
        asl
        clc
        adc tmp+4           ; map row r = room_y*16+ty
        sta tmp+5
        lsr
        lsr
        lsr
        lsr
        lsr
        clc
        adc #$28
        jsr set_bank
        ; window offset = (r&31)*128 + room_x*16
        lda tmp+5
        and #31
        lsr
        sta ptr+1
        lda #0
        ror
        sta ptr
        lda room_x
        asl
        asl
        asl
        asl
        ora ptr
        sta ptr
        lda ptr+1
        clc
        adc #>MEMW
        sta ptr+1
        lda tmp+4
        asl
        asl
        asl
        asl
        tax
        ldy #0
lr_copy lda (ptr),y
        sta room_tiles,x
        inx
        iny
        cpy #16
        bne lr_copy
        ldx tmp+4
        inx
        cpx #16
        bne lr_row
        jsr bake_room
        ; entities
        lda #0
        sta lr_tx
lr_tx_l lda #0
        sta lr_ty
lr_ty_l lda lr_ty
        asl
        asl
        asl
        asl
        ora lr_tx
        tay
        lda room_tiles,y
        beq lr_next
        sta lr_tile
        lda lr_tx
        asl
        asl
        asl
        clc
        adc #BIAS
        sta io_x
        lda lr_ty
        asl
        asl
        asl
        clc
        adc #BIAS
        sta io_y
        lda lr_tile
        cmp #11
        beq lr_plat
        cmp #12
        beq lr_plat
        ldy #11
lr_find cmp spawn_tiles,y
        beq lr_found
        dey
        bpl lr_find
        bmi lr_next
lr_found
        lda spawn_types,y
        jsr init_object
        jmp lr_next
lr_plat lda #T_PLATFORM
        jsr init_object
        bcs lr_next
        lda #$ff
        ldx lr_tile
        cpx #11
        beq lr_dir
        lda #1
lr_dir  sta o_v0,y
lr_next inc lr_ty
        lda lr_ty
        cmp #16
        bne lr_ty_l
        inc lr_tx
        lda lr_tx
        cmp #16
        bne lr_tx_l
        lda lvl
        cmp #31
        beq lr_done
        lda #BIAS
        sta io_x
        sta io_y
        lda #T_ROOMTITLE
        jsr init_object
lr_done ldx self
        rts
lr_tx   dta 0
lr_ty   dta 0
lr_tile dta 0
spawn_tiles dta 1,18,22,23,26,28,64,8,20,86,96,118
spawn_types dta T_SPAWN,T_SPRING,T_BALLOON,T_FALLFLOOR,T_FRUIT,T_FLYFRUIT
            dta T_FAKEWALL,T_KEY,T_CHEST,T_MESSAGE,T_BIGCHEST,T_FLAG

; Pre-render map layer 4 (background) to $30000 and layer 2 (terrain)
; to $34000.  Neither changes while the room is shown.
bake_room
        jsr bcb_begin
        lda #K_NONE
        sta tpl_kind
        lda #0
        sta tpl_src
        sta tpl_src+1
        sta tpl_src+2
        sta tpl_ssy
        sta tpl_ssy+1
        sta tpl_ssx
        sta tpl_dst
        sta tpl_dst+1
        sta tpl_and
        sta tpl_xor
        sta tpl_ctrl
        lda #3
        sta tpl_dst+2
        mwa #128 tpl_dsy
        lda #1
        sta tpl_dsx
        mwa #127 tpl_w
        lda #255
        sta tpl_h
        jsr bcb_add
        ; common tile settings
        mwa #128 tpl_ssy
        lda #1
        sta tpl_ssx
        mwa #128 tpl_dsy
        lda #7
        sta tpl_h
        lda #$ff
        sta tpl_and
        lda #1
        sta tpl_ctrl
        lda #0
        sta tpl_xor
        sta tpl_w+1
        lda #2
        sta tpl_src+2
        lda #3
        sta tpl_dst+2
        lda #K_BAKE
        sta tpl_kind
        lda #4
        sta bk_mask
        lda #0
        sta bk_base
        sta bk_off
        jsr bake_layer
        lda #2
        sta bk_mask
        lda #$40
        sta bk_base
        lda #0
        ldx lvl
        cpx #31
        bne bk_1
        lda #$fc            ; title: terrain drawn 4 pixels left
bk_1    sta bk_off
        jsr bake_layer
        jmp bcb_flush
bk_mask dta 0
bk_base dta 0
bk_off  dta 0
bk_i    dta 0

bake_layer
        lda #0
        sta bk_i
bl_loop ldy bk_i
        lda room_tiles,y
        beq bl_next
        tax
        lda tile_flags,x
        and bk_mask
        beq bl_next
        txa
        ; source: sprite sheet $20000
        asl
        asl
        asl
        and #$78
        sta tpl_src
        txa
        lsr
        lsr
        and #$3c
        sta tpl_src+1
        lda #2
        sta tpl_src+2
        mwa #7 tpl_w
        ; destination: base + ty*1024 + tx*8 + off
        lda bk_i
        and #15
        asl
        asl
        asl
        clc
        adc bk_off
        bcs bl_dst          ; positive or wrapped-back value
        ldx bk_off
        bpl bl_dst
        ; clipped on the left (title offset): skip 4 source columns
        lda tpl_src
        clc
        adc #4
        sta tpl_src
        mwa #3 tpl_w
        lda #0
bl_dst  sta tpl_dst
        lda bk_i
        lsr
        lsr
        and #$3c
        clc
        adc bk_base
        sta tpl_dst+1
        lda #3
        sta tpl_dst+2
        jsr bcb_add
bl_next inc bk_i
        bne bl_loop
        rts

; ---------------------------------------------------------- effects
init_effects
        ldx #16
ie_cl   stx tmp+4
        jsr rnd8
        sta cl_xl,x
        lda #128
        jsr rnd_n
        clc
        adc #BIAS
        ldx tmp+4
        sta cl_xh,x
        lda #128
        jsr rnd_n
        clc
        adc #BIAS
        ldx tmp+4
        sta cl_y,x
        ; spd = 1+rnd(4)
        jsr rnd8
        sta tmp
        asl
        asl
        ldx tmp+4
        sta cl_sl,x
        lda tmp
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        clc
        adc #1
        sta cl_sh,x
        ; w = 32+rnd(32), h = flr(4+(1-w/64)*12)
        lda #32
        jsr rnd_n
        clc
        adc #32
        ldx tmp+4
        sta cl_w,x
        jsr cloud_h
        ldx tmp+4
        dex
        bpl ie_cl
        ; particles
        ldx #24
ie_pa   stx tmp+4
        jsr rnd8
        ldx tmp+4
        sta pa_xl,x
        sta pa_yl,x
        lda #128
        jsr rnd_n
        clc
        adc #BIAS
        ldx tmp+4
        sta pa_xh,x
        lda #128
        jsr rnd_n
        clc
        adc #BIAS
        ldx tmp+4
        sta pa_yh,x
        ; s = flr(rnd(5)/4)
        jsr rnd8
        ldy #0
        cmp #51
        bcs ie_s
        iny
ie_s    tya
        ldx tmp+4
        sta pa_s,x
        ; spd = 0.25+rnd(5)
        jsr rnd8
        sta mul_a
        lda #5
        sta mul_b
        jsr mul8
        ldx tmp+4
        lda mul_r
        clc
        adc #64
        sta pa_sl,x
        lda mul_r+1
        adc #0
        sta pa_sh,x
        ; off = rnd(1)
        jsr rnd8
        ldx tmp+4
        sta pa_ol,x
        jsr rnd8
        ldx tmp+4
        sta pa_oh,x
        ; turn step = min(0.05, spd/32) = min(3277, spd*8)
        lda pa_sl,x
        sta z16
        lda pa_sh,x
        sta z16+1
        asl z16
        rol z16+1
        asl z16
        rol z16+1
        asl z16
        rol z16+1
        lda z16+1
        cmp #>3277
        bcc ie_st
        bne ie_stc
        lda z16
        cmp #<3277
        bcc ie_st
ie_stc  mwa #3277 z16
ie_st   lda z16
        sta pa_dl,x
        lda z16+1
        sta pa_dh,x
        ; c = 6 or 7
        jsr maybe
        clc
        adc #6
        ldx tmp+4
        sta pa_c,x
        dex
        bmi ie_done
        jmp ie_pa
ie_done ldx #7
        lda #$ff
ie_dp   sta dp_t,x
        dex
        bpl ie_dp
        rts

; cl_h[x] from cl_w[x]:  4 + flr((64-w)*12/64)
cloud_h lda #64
        sec
        sbc cl_w,x
        sta tmp
        asl
        clc
        adc tmp             ; *3
        lsr
        lsr
        lsr
        lsr                 ; /16
        clc
        adc #4
        sta cl_h,x
        rts

; ---------------------------------------------------------- _update
game_update
        inc frames
        lda frames
        cmp #30
        bcc gu_f
        lda #0
        sta frames
        lda lvl
        cmp #30
        bcs gu_f
        inc seconds
        lda seconds
        cmp #60
        bcc gu_f
        lda #0
        sta seconds
        inc minutes
        bne gu_f
        inc minutes+1
gu_f    lda music_timer
        beq gu_mt
        dec music_timer
        bne gu_mt
        lda #10
        jsr music
gu_mt   lda sfx_timer
        beq gu_st
        dec sfx_timer
gu_st   lda freeze
        beq gu_nf
        dec freeze
        rts
gu_nf   ; screenshake
        lda shake
        beq gu_sh
        dec shake
        lda #0
        sta cam_x
        sta cam_y
        lda shake
        beq gu_sh
        lda #5
        jsr rnd_n
        sec
        sbc #2
        sta cam_x
        lda #5
        jsr rnd_n
        sec
        sbc #2
        sta cam_y
gu_sh   ; restart (soon)
        lda will_restart
        beq gu_rs
        lda delay_restart
        beq gu_rs
        dec delay_restart
        bne gu_rs
        lda #0
        sta will_restart
        lda room_x
        ldy room_y
        jsr load_room
gu_rs   ; update each object
        lda #0
        sta room_changed
        sta loop_i
gu_obj  ldx loop_i
        cpx obj_count
        bcs gu_objd
        stx self
        lda o_type,x
        beq gu_on
        jsr obj_move
        ldx self
        lda o_type,x
        asl
        tay
        lda update_tab,y
        sta jv
        lda update_tab+1,y
        sta jv+1
        jsr jump_jv
        lda room_changed
        bne gu_objr
gu_on   inc loop_i
        jmp gu_obj
gu_objd jsr compact
gu_objr ; start game
        lda lvl
        cmp #31
        bne gu_done
        lda start_game
        bne gu_sg
        lda btn_j
        ora btn_x
        beq gu_done
        lda #$fe
        jsr music
        lda #50
        sta start_game_flash
        lda #1
        sta start_game
        lda #38
        jsr sfx
gu_sg   dec start_game_flash
        lda start_game_flash
        bpl gu_done
        cmp #$e3            ; <= -30
        bcs gu_done
        jmp begin_game
gu_done rts

; ---------------------------------------------------------- _draw
game_draw
        jsr bcb_begin
        ; start game flash (pal() on colours 1,5,6,7,12,13)
        lda #10
        ldx start_game
        beq gd_pf
        ldx start_game_flash
        bmi gd_pf0
        cpx #11
        bcc gd_pf1
        ; frames%10<5 -> 7
        lda frames
gd_m10  cmp #10
        bcc gd_m10d
        sbc #10
        bcs gd_m10
gd_m10d cmp #5
        lda #10
        bcs gd_pf
        lda #7
        bne gd_pf
gd_pf1  lda #2
        cpx #6
        bcs gd_pf
        lda #1
        cpx #1
        bcs gd_pf
gd_pf0  lda #0
gd_pf   sta palflash
        ; clear screen
        lda #0
        ldx flash_bg
        beq gd_bg1
        lda frames
        ldy #0
gd_div5 cmp #5
        bcc gd_d5
        sbc #5
        iny
        bne gd_div5
gd_d5   tya
        jmp gd_bg2
gd_bg1  ldx new_bg
        beq gd_bg2
        lda #2
gd_bg2  sta dr_c
        lda #BIAS
        sta dr_x
        sta dr_y
        lda #BIAS+128
        sta dr_x1
        sta dr_y1
        jsr fill_rect
        ; clouds
        lda lvl
        cmp #31
        beq gd_nocl
        jsr draw_clouds
gd_nocl ; bg terrain
        lda #$00
        jsr layer_draw
        ; platforms / big chest
        lda #0
        sta gd_pass
        jsr draw_objects
        ; terrain
        lda #$40
        jsr layer_draw
        ; other objects
        lda #1
        sta gd_pass
        jsr draw_objects
        jsr compact
        jsr draw_particles
        jsr draw_dead
        ; draw outside of the screen for screenshake (only visible while
        ; the camera is shaken)
        lda cam_x
        ora cam_y
        beq gd_nobrd
        ldx #3
gd_brd  stx tmp+4
        lda brd_x0,x
        sta dr_x
        lda brd_y0,x
        sta dr_y
        lda brd_x1,x
        sta dr_x1
        lda brd_y1,x
        sta dr_y1
        lda #0
        sta dr_c
        jsr fill_rect
        ldx tmp+4
        dex
        bpl gd_brd
gd_nobrd
        ; credits
        lda lvl
        cmp #31
        bne gd_nocr
        lda #5
        sta dr_c
        lda #BIAS+58
        sta dr_x
        lda #BIAS+80
        sta dr_y
        mwa #str_xc txtp
        jsr print
        lda #BIAS+42
        sta dr_x
        lda #BIAS+96
        sta dr_y
        mwa #str_matt txtp
        jsr print
        lda #BIAS+46
        sta dr_x
        lda #BIAS+102
        sta dr_y
        mwa #str_noel txtp
        jsr print
        lda #BIAS+8
        sta dr_x
        lda #BIAS+116
        sta dr_y
        mwa #str_port txtp
        jsr print
gd_nocr lda lvl
        cmp #30
        bne gd_done
        jmp draw_summit
gd_done rts
gd_pass dta 0
brd_x0  dta BIAS-5,BIAS-5,BIAS-5,BIAS+128
brd_y0  dta BIAS-5,BIAS-5,BIAS+128,BIAS-5
brd_x1  dta BIAS-1,BIAS+133,BIAS+133,BIAS+133
brd_y1  dta BIAS+133,BIAS-1,BIAS+133,BIAS+133
str_xc  dta c'x+c',0
str_matt dta c'matt thorson',0
str_noel dta c'noel berry',0
str_port dta c'atari vbxe version: astrofor',0

; draw pass 0: platforms and big chest, pass 1: everything else
draw_objects
        lda #0
        sta loop_i
do_loop ldx loop_i
        cpx obj_count
        bcs do_done
        stx self
        lda o_type,x
        beq do_next
        cmp #T_PLATFORM
        beq do_first
        cmp #T_BIGCHEST
        beq do_first
        lda gd_pass
        beq do_next
        bne do_draw
do_first
        lda gd_pass
        bne do_next
do_draw lda o_type,x
        asl
        tay
        lda draw_tab,y
        sta jv
        lda draw_tab+1,y
        sta jv+1
        jsr jump_jv
do_next inc loop_i
        jmp do_loop
do_done rts

draw_clouds
        ldx #16
dc_loop stx tmp+4
        lda cl_xl,x
        clc
        adc cl_sl,x
        sta cl_xl,x
        lda cl_xh,x
        adc cl_sh,x
        sta cl_xh,x
        ; x0 = max(x, -8), x1 = min(x+w, 136)
        sta dr_x
        clc
        adc cl_w,x
        bcs dc_cx1
        cmp #BIAS+136
        bcc dc_x1
dc_cx1  lda #BIAS+136
dc_x1   sta dr_x1
        lda dr_x
        cmp #BIAS-8
        bcs dc_x0
        lda #BIAS-8
        sta dr_x
dc_x0   lda cl_y,x
        sta dr_y
        clc
        adc cl_h,x
        sta dr_y1
        lda #1
        ldy new_bg
        beq dc_c
        lda #14
dc_c    sta dr_c
        lda dr_x1
        cmp dr_x
        bcc dc_skip
        jsr fill_rect
dc_skip ldx tmp+4
        ; wrap: x > 128 -> x = -w, y = rnd(120)
        lda cl_xh,x
        cmp #BIAS+128
        bcc dc_next
        bne dc_wrap
        lda cl_xl,x
        beq dc_next
dc_wrap lda #BIAS
        sec
        sbc cl_w,x
        sta cl_xh,x
        lda #0
        sta cl_xl,x
        lda #120
        jsr rnd_n
        clc
        adc #BIAS
        ldx tmp+4
        sta cl_y,x
dc_next dex
        bpl dc_loop
        rts

draw_particles
        ldx #24
dp_loop stx tmp+4
        ; x += spd
        lda pa_xl,x
        clc
        adc pa_sl,x
        sta pa_xl,x
        lda pa_xh,x
        adc pa_sh,x
        sta pa_xh,x
        ; y += sin(off)
        ldy pa_oh,x
        lda pa_yl,x
        clc
        adc sin_lo,y
        sta pa_yl,x
        lda pa_yh,x
        adc sin_hi,y
        sta pa_yh,x
        ; off += min(0.05, spd/32)
        lda pa_ol,x
        clc
        adc pa_dl,x
        sta pa_ol,x
        lda pa_oh,x
        adc pa_dh,x
        sta pa_oh,x
        ; rectfill(x,y,x+s,y+s,c)
        lda pa_xh,x
        sta dr_x
        clc
        adc pa_s,x
        sta dr_x1
        lda pa_yh,x
        sta dr_y
        clc
        adc pa_s,x
        sta dr_y1
        lda pa_c,x
        sta dr_c
        lda dr_x
        cmp #BIAS+134
        bcs dp_nodraw
        jsr fill_rect
dp_nodraw
        ldx tmp+4
        lda pa_xh,x
        cmp #BIAS+133
        bcc dp_next
        lda #BIAS-4
        sta pa_xh,x
        lda #0
        sta pa_xl,x
        lda #128
        jsr rnd_n
        clc
        adc #BIAS
        ldx tmp+4
        sta pa_yh,x
dp_next dex
        jpl dp_loop
        rts

draw_dead
        ldx #7
dd_loop lda dp_t,x
        cmp #$ff
        jeq dd_next
        stx tmp+4
        lda dp_xl,x
        clc
        adc dp_sxl,x
        sta dp_xl,x
        lda dp_xh,x
        adc dp_sxh,x
        sta dp_xh,x
        lda dp_yl,x
        clc
        adc dp_syl,x
        sta dp_yl,x
        lda dp_yh,x
        adc dp_syh,x
        sta dp_yh,x
        dec dp_t,x
        ldy dp_t,x
        ; x-t/5 .. x+t/5
        lda dp_xl,x
        sec
        sbc tfifth_lo,y
        lda dp_xh,x
        sbc tfifth_hi,y
        sta dr_x
        lda dp_xl,x
        clc
        adc tfifth_lo,y
        lda dp_xh,x
        adc tfifth_hi,y
        sta dr_x1
        lda dp_yl,x
        sec
        sbc tfifth_lo,y
        lda dp_yh,x
        sbc tfifth_hi,y
        sta dr_y
        lda dp_yl,x
        clc
        adc tfifth_lo,y
        lda dp_yh,x
        adc tfifth_hi,y
        sta dr_y1
        tya
        and #1
        clc
        adc #14
        sta dr_c
        ; stay inside the framebuffer page
        lda dr_x
        cmp #16
        bcc dd_skip
        cmp #240
        bcs dd_skip
        lda dr_y
        cmp #16
        bcc dd_skip
        cmp #240
        bcs dd_skip
        jsr fill_rect
dd_skip ldx tmp+4
        lda dp_t,x
        bne dd_next
        lda #$ff
        sta dp_t,x
dd_next dex
        jpl dd_loop
        rts

; summit: darken the sides depending on the player's distance to centre
draw_summit
        ldx #0
ds_find cpx obj_count
        bcs ds_done
        lda o_type,x
        cmp #T_PLAYER
        beq ds_found
        inx
        bne ds_find
ds_done rts
ds_found
        ; diff = min(24, 40-abs(p.x+4-64))
        lda o_x,x
        sec
        sbc #BIAS+60
        bpl ds_abs
        eor #$ff
        clc
        adc #1
ds_abs  sta tmp
        lda #40
        sec
        sbc tmp
        bmi ds_d
        cmp #25
        bcc ds_d
        lda #24
ds_d    sta tmp+4           ; signed diff
        ; rectfill(0,0,diff,128,0)
        clc
        adc #BIAS
        sta dr_x1
        lda #BIAS
        sta dr_x
        sta dr_y
        lda #BIAS+128
        sta dr_y1
        lda #0
        sta dr_c
        jsr fill_rect
        ; rectfill(128-diff,0,128,128,0)
        lda #BIAS+128
        sec
        sbc tmp+4
        sta dr_x
        lda #BIAS+128
        sta dr_x1
        lda #BIAS
        sta dr_y
        lda #BIAS+128
        sta dr_y1
        jmp fill_rect
