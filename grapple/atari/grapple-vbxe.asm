;==============================================================================
; GRAPPLE - VBXE SINGLE-ROOM MOVEMENT PROTOTYPE
;
; Atari XL/XE + VBXE FX 1.2x.  The movement constants, collision body, grapple
; states, and hero animation frame lists are taken from ../src/player.ts and
; ../src/grapple.ts.  Original hero pixels are generated from player.png.
;==============================================================================

; Atari OS / hardware
SDMCTL   = $022F
SDLSTL   = $0230
COLOR1   = $02C5
COLOR2   = $02C6
COLOR4   = $02C8
CHBAS    = $02F4
CH       = $02FC
RTCLOK   = $12
PORTA    = $D300
PORTB    = $D301
CONSOL   = $D01F
DMACTL   = $D400

; VBXE FX registers; operands are relocated to D7xx when required
VBXE_VCTL       = $D640
VBXE_XDL0       = $D641
VBXE_XDL1       = $D642
VBXE_XDL2       = $D643
VBXE_CSEL       = $D644
VBXE_PSEL       = $D645
VBXE_CR         = $D646
VBXE_CG         = $D647
VBXE_CB         = $D648
VBXE_BL_ADR0    = $D650
VBXE_BL_ADR1    = $D651
VBXE_BL_ADR2    = $D652
VBXE_BLITTER    = $D653
VBXE_MEMAC_CTRL = $D65E
VBXE_BANK_SEL   = $D65F

VC_XDL_ON = $01
VC_XCOLOR = $02
MC_CPU    = $08
BANK_EN   = $80
MEMW      = $9000
SCR_W     = 320
SCR_H     = 200
BANK_XDL  = $7F
BCB_OFF   = $100
XDL_B_OFF = $20
ASSET_VBANK = 2
ASSET_MEM_BANK = ASSET_VBANK*16
ASSET_PAGES = 64
BACKGROUND_BANK = 3

DIR_UP    = 0
DIR_RIGHT = 1
DIR_DOWN  = 2
DIR_LEFT  = 3

GRAPPLE_NONE  = 0
GRAPPLE_SHOOT = 1
GRAPPLE_PULL  = 2

; 8.8 per-frame physics at 50 Hz, corresponding to the browser constants:
; gravity 800 px/s^2, pull 200 px/s, grapple 800 px/s, max fall 400 px/s.
GRAVITY_STEP = 82              ; round(800 / 50 / 50 * 256)
PULL_STEP    = 1024            ; 200 / 50 * 256
MAX_FALL     = 2048            ; 400 / 50 * 256
HOOK_STEP    = 16              ; 800 / 50

; VBXE palette indexes
C_CLEAR      = 0
C_BG         = 1
C_BG_ALT     = 2
C_STONE      = 3
C_STONE_HI   = 4
C_STONE_DARK = 5
C_ROPE       = 6
C_HOOK       = 7
C_PLAYER_RED = 20
C_PLAYER_WHT = 21

; Zero-page pointers
work_ptr = $CB
data_ptr = $CD
text_src = $CF
text_dst = $D1
calc_out = $D3                 ; three bytes

        org $2000

;==============================================================================
; Entry and main loop
;==============================================================================
.proc main
        lda PORTB
        ora #2
        sta PORTB
        jsr setup_antic
        jsr detect_vbxe
        bcs ?vbxe
        lda #<s_need_vbxe
        sta text_src
        lda #>s_need_vbxe
        sta text_src+1
        lda #<[text_screen+12*40+13]
        sta text_dst
        lda #>[text_screen+12*40+13]
        sta text_dst+1
        jsr copy_text
        jmp *

?vbxe  lda #$90+MC_CPU
vbreg_main_memac
        sta VBXE_MEMAC_CTRL
        lda #0
vbreg_main_vctl
        sta VBXE_VCTL
        jsr setup_xdl
        jsr blit_init
        jsr upload_assets
        jsr load_palette

        lda #BACKGROUND_BANK
        sta render_bank
        jsr draw_room_cache
        jsr wait_blit
        lda #0
        sta render_bank
        jsr copy_background_cache
        jsr wait_blit
        lda #1
        sta render_bank
        jsr copy_background_cache
        jsr wait_blit

        lda #0
        sta front_bank
        sta frame_counter
        lda #1
        sta back_bank
        lda #7
        sta old_console
        lda #$FF
        sta CH
        jsr reset_player
        jsr enable_display
        jsr draw_everything

?loop   jsr read_input
        jsr update_player
        inc frame_counter
        jsr draw_everything
        jmp ?loop
.endp

;==============================================================================
; Input and grapple state
;==============================================================================
stick_value  dta 15
input_dir    dta $FF
old_console dta 7
key_temp     dta 0

.proc read_input
        lda PORTA
        and #15
        sta stick_value
        lda #$FF
        sta input_dir

        ; Same precedence as player.ts: down, up, right, then left.
        lda stick_value
        and #2
        beq ?down
        lda stick_value
        and #1
        beq ?up
        lda stick_value
        and #8
        beq ?right
        lda stick_value
        and #4
        beq ?left
        jmp ?direction_done
?down   lda #DIR_DOWN
        bne ?set
?up     lda #DIR_UP
        beq ?set
?right  lda #DIR_RIGHT
        bne ?set
?left   lda #DIR_LEFT
?set    sta input_dir

?direction_done
        lda grapple_state
        beq ?maybe_start
        ldx grapple_dir
        lda stick_value
        and direction_mask,x
        beq ?facing
        jsr release_grapple
        ; player.ts may release one direction and launch another in the same
        ; update (for example when rolling from up to right).
        lda input_dir
        cmp #$FF
        beq ?reset
        jsr start_grapple
        jmp ?facing

?maybe_start
        lda input_dir
        cmp #$FF
        beq ?reset
        jsr start_grapple

?facing
        lda input_dir
        cmp #DIR_LEFT
        bne ?face_right
        lda #1
        sta facing_left
        bne ?reset
?face_right
        cmp #DIR_RIGHT
        bne ?reset
        lda #0
        sta facing_left

?reset  lda CONSOL
        and #7
        cmp old_console
        beq ?keyboard
        sta old_console
        and #2                  ; SELECT
        bne ?keyboard
        jsr reset_player

?keyboard
        lda CH
        cmp #$FF
        beq ?done
        and #$3F
        sta key_temp
        lda #$FF
        sta CH
        lda key_temp
        cmp #$28               ; R
        bne ?done
        jsr reset_player
?done   rts
.endp

direction_mask dta 1,8,2,4

.proc start_grapple
        sta grapple_dir
        lda #GRAPPLE_SHOOT
        sta grapple_state
        lda #0
        sta vel_x
        sta vel_x+1
        sta vel_y
        sta vel_y+1
        lda player_x+1
        sta hook_x
        lda player_y+1
        sec
        sbc #6
        sta hook_y
        rts
.endp

.proc release_grapple
        lda #GRAPPLE_NONE
        sta grapple_state
        rts
.endp

.proc reset_player
        lda #0
        sta player_x
        sta player_y
        sta vel_x
        sta vel_x+1
        sta vel_y
        sta vel_y+1
        sta grapple_state
        sta frame_counter
        sta facing_left
        lda #40
        sta player_x+1
        lda #68                ; standing on the left platform
        sta player_y+1
        rts
.endp

;==============================================================================
; Player physics
;==============================================================================
player_x      dta a(0)         ; 8.8 logical pixels, sprite centre X
player_y      dta a(0)         ; 8.8 logical pixels, sprite bottom Y
vel_x         dta a(0)
vel_y         dta a(0)
hook_x        dta 0
hook_y        dta 0
grapple_state dta 0
grapple_dir   dta 0
facing_left   dta 0
frame_counter dta 0
hero_frame    dta 0
animation_phase dta 0

.proc update_player
        lda grapple_state
        beq ?falling
        cmp #GRAPPLE_SHOOT
        beq ?shooting

        ; Pulling is a constant cardinal 200 px/s, exactly as player.ts.
        lda #0
        sta vel_x
        sta vel_x+1
        sta vel_y
        sta vel_y+1
        lda grapple_dir
        cmp #DIR_UP
        bne ?pull_right
        lda #$FC               ; -1024 in 8.8
        sta vel_y+1
        jmp ?move
?pull_right
        cmp #DIR_RIGHT
        bne ?pull_down
        lda #4
        sta vel_x+1
        bne ?move
?pull_down
        cmp #DIR_DOWN
        bne ?pull_left
        lda #4
        sta vel_y+1
        bne ?move
?pull_left
        lda #$FC
        sta vel_x+1
        bne ?move

?shooting
        lda #0
        sta vel_x
        sta vel_x+1
        sta vel_y
        sta vel_y+1
        jmp ?move

?falling
        clc
        lda vel_y
        adc #<GRAVITY_STEP
        sta vel_y
        lda vel_y+1
        adc #>GRAVITY_STEP
        sta vel_y+1
        bmi ?move
        cmp #>MAX_FALL
        bcc ?move
        bne ?cap
        lda vel_y
        cmp #<MAX_FALL
        bcc ?move
?cap    lda #<MAX_FALL
        sta vel_y
        lda #>MAX_FALL
        sta vel_y+1

?move   jsr move_player_x
        jsr move_player_y
        lda grapple_state
        cmp #GRAPPLE_SHOOT
        bne ?animation
        jsr advance_hook
?animation
        jmp choose_hero_frame
.endp

.proc move_player_x
        lda vel_x
        ora vel_x+1
        beq ?done
        clc
        lda player_x
        adc vel_x
        sta player_x
        lda player_x+1
        adc vel_x+1
        sta player_x+1
        jsr collide_player
        bcc ?done
        lda #0
        sta player_x
        lda vel_x+1
        bmi ?moving_left
        ldx collision_offset
        lda walls+0,x
        sec
        sbc #4
        sta player_x+1
        jmp ?stop
?moving_left
        ldx collision_offset
        lda walls+2,x
        clc
        adc #4
        sta player_x+1
?stop   lda #0
        sta vel_x
        sta vel_x+1
?done   rts
.endp

.proc move_player_y
        lda vel_y
        ora vel_y+1
        beq ?done
        clc
        lda player_y
        adc vel_y
        sta player_y
        lda player_y+1
        adc vel_y+1
        sta player_y+1
        jsr collide_player
        bcc ?done
        lda #0
        sta player_y
        lda vel_y+1
        bmi ?moving_up
        ldx collision_offset
        lda walls+1,x
        sta player_y+1
        jmp ?stop
?moving_up
        ldx collision_offset
        lda walls+3,x
        clc
        adc #12
        sta player_y+1
?stop   lda #0
        sta vel_y
        sta vel_y+1
?done   rts
.endp

; Player body is RectBounds(-4,-12,8,12), with right/bottom exclusive.
bbox_l dta 0
bbox_t dta 0
bbox_r dta 0
bbox_b dta 0
collision_offset dta 0

.proc collide_player
        lda player_x+1
        sec
        sbc #4
        sta bbox_l
        lda player_x+1
        clc
        adc #4
        sta bbox_r
        lda player_y+1
        sec
        sbc #12
        sta bbox_t
        lda player_y+1
        sta bbox_b

        ldx #0
?wall   lda bbox_r
        cmp walls+0,x
        bcc ?next
        beq ?next
        lda bbox_l
        cmp walls+2,x
        bcs ?next
        lda bbox_b
        cmp walls+1,x
        bcc ?next
        beq ?next
        lda bbox_t
        cmp walls+3,x
        bcs ?next
        stx collision_offset
        sec
        rts
?next   txa
        clc
        adc #4
        tax
        cpx #WALL_COUNT*4
        bcc ?wall
        clc
        rts
.endp

; Move the hook one logical pixel at a time so 800 px/s cannot tunnel through
; the room's narrow ledges.
.proc advance_hook
        ldy #HOOK_STEP
?step   lda grapple_dir
        cmp #DIR_UP
        bne ?right
        dec hook_y
        jmp ?test
?right  cmp #DIR_RIGHT
        bne ?down
        inc hook_x
        jmp ?test
?down   cmp #DIR_DOWN
        bne ?left
        inc hook_y
        jmp ?test
?left   dec hook_x
?test   jsr point_in_wall
        bcs ?hit
        dey
        bne ?step
        rts
?hit    ldx collision_offset
        lda grapple_dir
        cmp #DIR_UP
        bne ?snap_right
        lda walls+3,x
        clc
        adc #3
        sta hook_y
        jmp ?latched
?snap_right
        cmp #DIR_RIGHT
        bne ?snap_down
        lda walls+0,x
        sec
        sbc #3
        sta hook_x
        jmp ?latched
?snap_down
        cmp #DIR_DOWN
        bne ?snap_left
        lda walls+1,x
        sec
        sbc #3
        sta hook_y
        jmp ?latched
?snap_left
        lda walls+2,x
        clc
        adc #3
        sta hook_x
?latched
        lda #GRAPPLE_PULL
        sta grapple_state
        rts
.endp

.proc point_in_wall
        lda hook_x
        sec
        sbc #3
        sta bbox_l
        lda hook_x
        clc
        adc #3
        sta bbox_r
        lda hook_y
        sec
        sbc #3
        sta bbox_t
        lda hook_y
        clc
        adc #3
        sta bbox_b
        ldx #0
?wall   lda bbox_r
        cmp walls+0,x
        bcc ?next
        beq ?next
        lda bbox_l
        cmp walls+2,x
        bcs ?next
        lda bbox_b
        cmp walls+1,x
        bcc ?next
        beq ?next
        lda bbox_t
        cmp walls+3,x
        bcs ?next
        stx collision_offset
        sec
        rts
?next   txa
        clc
        adc #4
        tax
        cpx #WALL_COUNT*4
        bcc ?wall
        clc
        rts
.endp

.proc choose_hero_frame
        lda frame_counter
        lsr
        lsr                     ; active movement: 12.5 fps at PAL 50 Hz
        sta animation_phase
        lda grapple_state
        beq ?free
        lda grapple_dir
        cmp #DIR_UP
        beq ?jump
        cmp #DIR_DOWN
        beq ?fall
        lda animation_phase
        and #1
        clc
        adc #14                 ; original frames 17,18
        sta hero_frame
        rts
?jump   lda animation_phase
        and #1
        clc
        adc #9                  ; original frames 11,12
        sta hero_frame
        rts
?fall   lda animation_phase
        and #1
        clc
        adc #11                 ; original frames 13,14
        sta hero_frame
        rts

?free   lda vel_y+1
        bmi ?jump
        bne ?fall
        lda vel_y
        cmp #103                ; 20 px/s animation threshold
        bcs ?fall
        ; The browser's nominal 12 fps idle is visually frantic with these
        ; high-contrast Atari frames. Idle alone runs at half rate; movement
        ; states retain their original responsive timing.
        lda frame_counter
        lsr
        lsr
        lsr                     ; 6.25 fps at PAL 50 Hz
        and #3
        sta hero_frame          ; original idle frames 0..3
        rts
.endp

; Collision rectangles are left, top, right-exclusive, bottom-exclusive.
WALL_COUNT = 8
walls
        dta 0,0,160,8
        dta 0,0,8,100
        dta 152,0,160,100
        dta 0,92,160,100
        dta 24,68,70,76
        dta 92,56,136,64
        dta 74,24,86,50
        dta 112,24,152,32

;==============================================================================
; ANTIC text underlay
;==============================================================================
.proc setup_antic
        lda #<display_list
        sta SDLSTL
        lda #>display_list
        sta SDLSTL+1
        lda #$22
        sta SDMCTL
        sta DMACTL
        lda #$E0
        sta CHBAS
        lda #$4E
        sta COLOR1
        lda #$02
        sta COLOR2
        lda #0
        sta COLOR4
        ldx #0
        lda #0
?clear  sta text_screen,x
        sta text_screen+$100,x
        sta text_screen+$200,x
        sta text_screen+$300,x
        inx
        bne ?clear
        rts
.endp

.proc copy_text
        ldy #0
        lda (text_src),y
        tax
        beq ?done
?loop   iny
        lda (text_src),y
        dey
        sta (text_dst),y
        iny
        dex
        bne ?loop
?done   rts
.endp

s_need_vbxe dta 13,d'VBXE REQUIRED'

;==============================================================================
; Renderer
;==============================================================================
front_bank  dta 0
back_bank   dta 1
render_bank dta 0

.proc draw_everything
        lda back_bank
        sta render_bank
        jsr copy_background_cache
        jsr draw_grapple
        jsr draw_hero
        jsr wait_blit
        jmp present_back_buffer
.endp

.proc draw_room_cache
        lda #0
        sta calc_x
        sta calc_x+1
        sta calc_y
        lda #<SCR_W
        sta fr_w
        lda #>SCR_W
        sta fr_w+1
        lda #SCR_H
        sta fr_h
        lda #C_BG
        sta fr_col
        jsr fill_rect

        lda #<wall_draw_data
        sta work_ptr
        lda #>wall_draw_data
        sta work_ptr+1
?next   ldy #0
        lda (work_ptr),y
        cmp #$FF
        beq ?details
        sta calc_x
        iny
        lda (work_ptr),y
        sta calc_x+1
        iny
        lda (work_ptr),y
        sta calc_y
        iny
        lda (work_ptr),y
        sta fr_w
        iny
        lda (work_ptr),y
        sta fr_w+1
        iny
        lda (work_ptr),y
        sta fr_h
        iny
        lda (work_ptr),y
        sta fr_col
        jsr fill_rect
        clc
        lda work_ptr
        adc #7
        sta work_ptr
        bcc ?next
        inc work_ptr+1
        jmp ?next

?details
        ; Small cave marks keep the room close to the original red/white art.
        lda #36
        sta calc_x
        lda #0
        sta calc_x+1
        lda #38
        sta calc_y
        lda #18
        sta fr_w
        lda #0
        sta fr_w+1
        lda #3
        sta fr_h
        lda #C_STONE_DARK
        sta fr_col
        jsr fill_rect
        lda #<264
        sta calc_x
        lda #>264
        sta calc_x+1
        lda #164
        sta calc_y
        lda #20
        sta fr_w
        lda #0
        sta fr_w+1
        lda #3
        sta fr_h
        lda #C_STONE_DARK
        sta fr_col
        jmp fill_rect
.endp

; x lo, x hi, y, width lo, width hi, height, colour
wall_draw_data
        dta <0,>0,0,<320,>320,16,C_STONE
        dta <0,>0,0,<16,>16,200,C_STONE
        dta <304,>304,0,<16,>16,200,C_STONE
        dta <0,>0,184,<320,>320,16,C_STONE
        dta <48,>48,136,<92,>92,16,C_STONE
        dta <184,>184,112,<88,>88,16,C_STONE
        dta <148,>148,48,<24,>24,52,C_STONE
        dta <224,>224,48,<80,>80,16,C_STONE
        dta <16,>16,16,<288,>288,3,C_STONE_HI
        dta <48,>48,136,<92,>92,3,C_STONE_HI
        dta <184,>184,112,<88,>88,3,C_STONE_HI
        dta <148,>148,48,<24,>24,3,C_STONE_HI
        dta <224,>224,48,<80,>80,3,C_STONE_HI
        dta <0,>0,181,<320,>320,3,C_STONE_HI
        dta $FF

.proc copy_background_cache
        jsr wait_blit
        lda #0
        sta bl_src
        sta bl_src+1
        lda #BACKGROUND_BANK
        sta bl_src+2
        lda #<SCR_W
        sta bl_ssy
        lda #>SCR_W
        sta bl_ssy+1
        lda #1
        sta bl_ssx
        lda #0
        sta bl_dst
        sta bl_dst+1
        lda render_bank
        sta bl_dst+2
        lda #<SCR_W
        sta bl_dsy
        lda #>SCR_W
        sta bl_dsy+1
        lda #1
        sta bl_dsx
        lda #<[SCR_W-1]
        sta bl_w
        lda #>[SCR_W-1]
        sta bl_w+1
        lda #SCR_H-1
        sta bl_h
        lda #$FF
        sta bl_and
        lda #0
        sta bl_xor
        sta bl_mode
        jmp do_blit
.endp

.proc draw_grapple
        lda grapple_state
        bne ?active
        rts
?active lda grapple_dir
        and #1
        bne ?horizontal

        ; Vertical rope: x = player centre, y spans source to hook.
        lda player_x+1
        jsr double_a_to_calc_x
        lda player_y+1
        sec
        sbc #6
        sta rope_source
        lda hook_y
        cmp rope_source
        bcs ?v_hook_after
        sta rope_min
        lda rope_source
        sec
        sbc hook_y
        jmp ?v_length
?v_hook_after
        lda rope_source
        sta rope_min
        lda hook_y
        sec
        sbc rope_source
?v_length
        asl
        clc
        adc #2
        sta fr_h
        lda rope_min
        asl
        sta calc_y
        lda #2
        sta fr_w
        lda #0
        sta fr_w+1
        lda #C_ROPE
        sta fr_col
        jsr fill_rect
        jmp ?hook

?horizontal
        lda player_y+1
        sec
        sbc #6
        asl
        sta calc_y
        lda player_x+1
        sta rope_source
        lda hook_x
        cmp rope_source
        bcs ?h_hook_after
        sta rope_min
        lda rope_source
        sec
        sbc hook_x
        jmp ?h_length
?h_hook_after
        lda rope_source
        sta rope_min
        lda hook_x
        sec
        sbc rope_source
?h_length
        asl
        clc
        adc #2
        sta fr_w
        lda #0
        sta fr_w+1
        lda rope_min
        jsr double_a_to_calc_x
        lda #2
        sta fr_h
        lda #C_ROPE
        sta fr_col
        jsr fill_rect

?hook   lda hook_x
        jsr double_a_to_calc_x
        sec
        lda calc_x
        sbc #4
        sta calc_x
        lda calc_x+1
        sbc #0
        sta calc_x+1
        lda hook_y
        asl
        sec
        sbc #4
        sta calc_y
        lda #8
        sta fr_w
        lda #0
        sta fr_w+1
        lda #8
        sta fr_h
        lda #C_HOOK
        sta fr_col
        jsr fill_rect
        clc
        lda calc_x
        adc #2
        sta calc_x
        bcc ?no_carry
        inc calc_x+1
?no_carry
        inc calc_y
        inc calc_y
        lda #4
        sta fr_w
        lda #0
        sta fr_w+1
        lda #4
        sta fr_h
        lda #C_BG
        sta fr_col
        jmp fill_rect
.endp

rope_source dta 0
rope_min    dta 0

.proc draw_hero
        ; 16x16 original art doubled to 32x32; bottom-centre anchor.
        lda player_x+1
        jsr double_a_to_calc_x
        sec
        lda calc_x
        sbc #16
        sta calc_x
        lda calc_x+1
        sbc #0
        sta calc_x+1
        lda player_y+1
        asl
        sec
        sbc #32
        sta calc_y
        jsr calc_addr

        lda hero_frame
        asl
        asl
        sta bl_src+1            ; each frame occupies four 256-byte pages
        lda #0
        sta bl_src
        lda #ASSET_VBANK
        sta bl_src+2
        lda #32
        sta bl_ssy
        lda #0
        sta bl_ssy+1
        lda facing_left
        beq ?normal
        lda bl_src
        clc
        adc #31
        sta bl_src
        bcc ?reverse
        inc bl_src+1
?reverse
        lda #$FF
        bne ?source_step
?normal lda #1
?source_step
        sta bl_ssx
        lda calc_out
        sta bl_dst
        lda calc_out+1
        sta bl_dst+1
        lda calc_out+2
        sta bl_dst+2
        lda #<SCR_W
        sta bl_dsy
        lda #>SCR_W
        sta bl_dsy+1
        lda #1
        sta bl_dsx
        lda #31
        sta bl_w
        lda #0
        sta bl_w+1
        lda #31
        sta bl_h
        lda #$FF
        sta bl_and
        lda #0
        sta bl_xor
        lda #1                  ; source colour zero is transparent
        sta bl_mode
        jmp do_blit
.endp

.proc double_a_to_calc_x
        asl
        sta calc_x
        lda #0
        rol
        sta calc_x+1
        rts
.endp

;==============================================================================
; VBXE initialization, palette, and blitter
;==============================================================================
.proc detect_vbxe
        lda VBXE_VCTL
        cmp #$10
        beq ?d6
        lda $D740
        cmp #$10
        beq ?d7
        clc
        rts
?d6     lda #$D6
        bne ?found
?d7     lda #$D7
?found  jsr relocate_vbxe_registers
        sec
        rts
.endp

.proc relocate_vbxe_registers
        sta ?page+1
        lda #<vbxe_relocations
        sta work_ptr
        lda #>vbxe_relocations
        sta work_ptr+1
        ldy #0
?next   lda (work_ptr),y
        sta text_dst
        iny
        lda (work_ptr),y
        sta text_dst+1
        iny
?page   lda #$D6
        ldx #0
        sta (text_dst,x)
        cpy #vbxe_relocations_end-vbxe_relocations
        bne ?next
        rts
.endp

vbxe_relocations
        dta a(main.vbreg_main_memac+2),a(main.vbreg_main_vctl+2)
        dta a(setup_xdl.vbreg_setup_bank+2)
        dta a(enable_display.vbreg_vctl+2),a(enable_display.vbreg_xdl0+2)
        dta a(enable_display.vbreg_xdl1+2),a(enable_display.vbreg_xdl2+2)
        dta a(load_palette.vbreg_psel+2),a(load_palette.vbreg_csel+2)
        dta a(load_palette.vbreg_cr+2),a(load_palette.vbreg_cg+2)
        dta a(load_palette.vbreg_cb+2)
        dta a(blit_init.vbreg_bl0+2),a(blit_init.vbreg_bl1+2)
        dta a(blit_init.vbreg_bl2+2),a(wait_blit.vbreg_busy+2)
        dta a(upload_assets.vbreg_asset_bank+2)
        dta a(upload_assets.vbreg_asset_restore+2)
        dta a(do_blit.vbreg_blit_bank+2),a(do_blit.vbreg_start+2)
        dta a(present_back_buffer.present_vbreg_xdl0_b+2)
        dta a(present_back_buffer.present_vbreg_xdl1_b+2)
        dta a(present_back_buffer.present_vbreg_xdl0_a+2)
        dta a(present_back_buffer.present_vbreg_xdl1_a+2)
        dta a(present_back_buffer.present_vbreg_xdl2+2)
vbxe_relocations_end

.proc setup_xdl
        lda #BANK_EN+BANK_XDL
vbreg_setup_bank
        sta VBXE_BANK_SEL
        ldx #xdl_len-1
?copy   lda xdl_data,x
        sta MEMW,x
        dex
        bpl ?copy
        ldx #xdl_len-1
?copy_b lda xdl_data_b,x
        sta MEMW+XDL_B_OFF,x
        dex
        bpl ?copy_b
        rts
.endp

.proc upload_assets
        lda #<asset_raw
        sta data_ptr
        lda #>asset_raw
        sta data_ptr+1
        lda #<MEMW
        sta text_dst
        lda #>MEMW
        sta text_dst+1
        lda #ASSET_MEM_BANK
        sta current_asset_bank
        lda #0
        sta asset_page_in_bank
        lda #ASSET_PAGES
        sta asset_pages_left
?page   lda current_asset_bank
        ora #BANK_EN
vbreg_asset_bank
        sta VBXE_BANK_SEL
        ldy #0
?byte   lda (data_ptr),y
        sta (text_dst),y
        iny
        bne ?byte
        inc data_ptr+1
        inc text_dst+1
        inc asset_page_in_bank
        lda asset_page_in_bank
        cmp #16
        bcc ?count
        lda #0
        sta asset_page_in_bank
        lda #>MEMW
        sta text_dst+1
        inc current_asset_bank
?count  dec asset_pages_left
        bne ?page
        lda #BANK_EN+BANK_XDL
vbreg_asset_restore
        sta VBXE_BANK_SEL
        rts
.endp

current_asset_bank dta 0
asset_page_in_bank dta 0
asset_pages_left dta 0

xdl_data
        dta $74,$08
        dta 7
        dta $00,$00,$00
        dta $40,$01
        dta $11,$FF
        dta $62,$88
        dta SCR_H-1
        dta $00,$00,$00
        dta $40,$01
        dta $11,$FF
xdl_len = *-xdl_data

xdl_data_b
        dta $74,$08
        dta 7
        dta $00,$00,$01
        dta $40,$01
        dta $11,$FF
        dta $62,$88
        dta SCR_H-1
        dta $00,$00,$01
        dta $40,$01
        dta $11,$FF

.proc enable_display
        lda #VC_XDL_ON+VC_XCOLOR
vbreg_vctl
        sta VBXE_VCTL
        lda #0
vbreg_xdl0
        sta VBXE_XDL0
        lda #$F0
vbreg_xdl1
        sta VBXE_XDL1
        lda #$07
vbreg_xdl2
        sta VBXE_XDL2
        rts
.endp

.proc wait_frame
        lda RTCLOK+2
?wait   cmp RTCLOK+2
        beq ?wait
        rts
.endp

.proc present_back_buffer
        jsr wait_frame
        lda front_bank
        pha
        lda back_bank
        sta front_bank
        pla
        sta back_bank
        lda front_bank
        beq ?xdl_a
        lda #<XDL_B_OFF
present_vbreg_xdl0_b
        sta VBXE_XDL0
        lda #$F0
present_vbreg_xdl1_b
        sta VBXE_XDL1
        jmp ?high
?xdl_a lda #0
present_vbreg_xdl0_a
        sta VBXE_XDL0
        lda #$F0
present_vbreg_xdl1_a
        sta VBXE_XDL1
?high   lda #$07
present_vbreg_xdl2
        sta VBXE_XDL2
        rts
.endp

.proc load_palette
        lda #1
vbreg_psel
        sta VBXE_PSEL
        ldx #0
?next   lda palette,x
        cmp #$FF
        beq ?done
vbreg_csel
        sta VBXE_CSEL
        lda palette+1,x
vbreg_cr
        sta VBXE_CR
        lda palette+2,x
vbreg_cg
        sta VBXE_CG
        lda palette+3,x
vbreg_cb
        sta VBXE_CB
        txa
        clc
        adc #4
        tax
        jmp ?next
?done   rts
.endp

palette
        dta 0,  0,  0,  0
        dta 1,  8, 10, 19
        dta 2, 13, 16, 29
        dta 3, 52, 24, 38
        dta 4,112, 38, 56
        dta 5, 28, 15, 29
        dta 6,214,214,225
        dta 7,255,255,255
        dta 20,255,  0,  0
        dta 21,255,255,255
        dta $FF

bl_src  dta 0,0,0
bl_ssy  dta a(0)
bl_ssx  dta 0
bl_dst  dta 0,0,0
bl_dsy  dta a(0)
bl_dsx  dta 0
bl_w    dta a(0)
bl_h    dta 0
bl_and  dta 0
bl_xor  dta 0
bl_mode dta 0

.proc blit_init
        lda #<BCB_OFF
vbreg_bl0
        sta VBXE_BL_ADR0
        lda #$F1
vbreg_bl1
        sta VBXE_BL_ADR1
        lda #$07
vbreg_bl2
        sta VBXE_BL_ADR2
        rts
.endp

.proc wait_blit
?wait
vbreg_busy
        lda VBXE_BLITTER
        bne ?wait
        rts
.endp

.proc do_blit
        jsr wait_blit
        lda #BANK_EN+BANK_XDL
vbreg_blit_bank
        sta VBXE_BANK_SEL
        lda bl_src
        sta MEMW+BCB_OFF+0
        lda bl_src+1
        sta MEMW+BCB_OFF+1
        lda bl_src+2
        sta MEMW+BCB_OFF+2
        lda bl_ssy
        sta MEMW+BCB_OFF+3
        lda bl_ssy+1
        sta MEMW+BCB_OFF+4
        lda bl_ssx
        sta MEMW+BCB_OFF+5
        lda bl_dst
        sta MEMW+BCB_OFF+6
        lda bl_dst+1
        sta MEMW+BCB_OFF+7
        lda bl_dst+2
        sta MEMW+BCB_OFF+8
        lda bl_dsy
        sta MEMW+BCB_OFF+9
        lda bl_dsy+1
        sta MEMW+BCB_OFF+10
        lda bl_dsx
        sta MEMW+BCB_OFF+11
        lda bl_w
        sta MEMW+BCB_OFF+12
        lda bl_w+1
        sta MEMW+BCB_OFF+13
        lda bl_h
        sta MEMW+BCB_OFF+14
        lda bl_and
        sta MEMW+BCB_OFF+15
        lda bl_xor
        sta MEMW+BCB_OFF+16
        lda #0
        sta MEMW+BCB_OFF+17
        sta MEMW+BCB_OFF+18
        sta MEMW+BCB_OFF+19
        lda bl_mode
        sta MEMW+BCB_OFF+20
        lda #1
vbreg_start
        sta VBXE_BLITTER
        rts
.endp

calc_x dta a(0)
calc_y dta 0

.proc calc_addr
        lda calc_y
        lsr
        lsr
        clc
        adc calc_y
        sta ?high
        lda calc_y
        and #3
        tax
        lda times64,x
        clc
        adc calc_x
        sta calc_out
        lda ?high
        adc calc_x+1
        sta calc_out+1
        lda render_bank
        sta calc_out+2
        rts
?high   dta 0
.endp

times64 dta 0,64,128,192

fr_w   dta a(0)
fr_h   dta 0
fr_col dta 0

.proc fill_rect
        jsr calc_addr
        lda calc_out
        sta bl_dst
        lda calc_out+1
        sta bl_dst+1
        lda calc_out+2
        sta bl_dst+2
        lda #<SCR_W
        sta bl_dsy
        lda #>SCR_W
        sta bl_dsy+1
        lda #1
        sta bl_dsx
        lda #0
        sta bl_src
        sta bl_src+1
        sta bl_src+2
        sta bl_ssy
        sta bl_ssy+1
        lda #1
        sta bl_ssx
        lda fr_w
        sec
        sbc #1
        sta bl_w
        lda fr_w+1
        sbc #0
        sta bl_w+1
        lda fr_h
        sec
        sbc #1
        sta bl_h
        lda #0
        sta bl_and
        lda fr_col
        sta bl_xor
        lda #0
        sta bl_mode
        jmp do_blit
.endp

;==============================================================================
; Data segments
;==============================================================================
display_list
        dta $42,a(text_screen)
        :24 dta $02
        dta $41,a(display_list)

        org $4000
asset_raw
        ins 'player-assets.bin'

        org $8000
text_screen
        :1000 dta 0

        run main
