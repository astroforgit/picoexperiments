;==============================================================================
; SULKA VBXE
;
; A self-contained Atari XL/XE + VBXE interpretation of Sulka.
;
; Build:
;   mads sulka-vbxe.asm -o:sulka-vbxe.xex
;
; Controls:
;   joystick left/right or A/D   move
;   fire or Space/W              jump
;   SELECT or R                  restart level
;   1-0,Q,E,T-Y,U-I,O-P,S-J     select playable level (temporary)
;
; Requires a VBXE with an FX 1.2x core. Graphics and levels are embedded.
; The game uses a 320x200, 256-colour VBXE overlay and the VBXE blitter.
;==============================================================================

; ---- Atari OS / hardware -----------------------------------------------------
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
STRIG0   = $D010
CONSOL   = $D01F
DMACTL   = $D400
KBCODE   = $D209
SKSTAT   = $D20F

; ---- VBXE FX registers; runtime-patched from $D6 to $D7 when required -------
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
ROOM_CACHE_BANK = 2
FLY_SPRITE_BANK = 3
FLY_SPRITE_MEM_BANK = FLY_SPRITE_BANK*16

; ---- game geometry -----------------------------------------------------------
MAP_W     = 24
MAP_H     = 14
MAP_SIZE  = MAP_W*MAP_H
TILE      = 10
BOARD_X   = 40
BOARD_Y   = 28
BOARD_ADDR = BOARD_Y*SCR_W+BOARD_X
PLAYER_W  = 6                   ; collision footprint
PLAYER_H  = 8
SPRITE_W  = 10                  ; original sPlayer artwork
SPRITE_H  = 12
FLY_W     = 10                  ; original sFlySpike artwork
FLY_H     = 10
LEVELS    = 24
LEVEL_SHORTCUT_COUNT = 23

; Map data uses readable ATASCII characters.
T_EMPTY   = '.'
T_WALL    = '#'
T_PLAYER  = 'P'
T_KEY     = 'K'
T_DOOR    = 'D'
T_DOOR_UP = 'd'
T_NEST    = 'N'
T_SPIKE   = '^'
T_SPIKE_UP = 'v'
T_SPIKE_RIGHT = '>'
T_SPIKE_LEFT = '<'
T_SPIKE_DECOR = 's'
T_LINE    = '='
T_FLY     = 'F'

; ---- palette indices ---------------------------------------------------------
C_BG       = 1
C_BOARD    = 2
C_WALL     = 3
C_WALL_HI  = 4
C_PLAYER   = 5
C_PLAYER_H = 6
C_EYE      = 7
C_KEY      = 8
C_KEY_HI   = 9
C_DOOR     = 10
C_LOCK     = 11
C_LINE     = 12
C_LINE_HI  = 13
C_SPIKE    = 14
C_WHITE    = 15
C_SHADOW   = 16

; ---- zero-page pointers ------------------------------------------------------
level_ptr = $CB                 ; 2
work_ptr  = $CD                 ; 2
calc_out  = $CF                 ; 3
text_src  = $D2                 ; 2
text_dst  = $D4                 ; 2

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
        lda #$34
        sta COLOR4
        lda #<s_need_vbxe
        sta text_src
        lda #>s_need_vbxe
        sta text_src+1
        lda #<[text_screen+12*40+12]
        sta text_dst
        lda #>[text_screen+12*40+12]
        sta text_dst+1
        jsr copy_text
        jmp *

?vbxe   lda #$90+MC_CPU
vbreg_main_memac
        sta VBXE_MEMAC_CTRL
        lda #0
vbreg_main_vctl
        sta VBXE_VCTL
        jsr setup_xdl
        jsr blit_init
        jsr upload_fly_sprite
        jsr load_palette
        jsr enable_display

        lda #0
        sta level_number
        sta old_fire
        sta front_bank
        lda #1
        sta back_bank
        lda #0
        sta render_bank
        jsr clear_framebuffer
        jsr wait_blit
        lda #1
        sta render_bank
        jsr clear_framebuffer
        jsr wait_blit
        lda #15
        sta old_stick
        sta old_console
        lda #$FF
        sta CH
        jsr init_level

?loop   lda game_complete
        bne ?complete
        jsr read_input
        jsr update_player
        jsr update_fly_spikes
        jsr check_fly_spikes
        jsr check_special_tiles
        jsr draw_dynamic
        jmp ?loop

?complete
        jsr wait_frame
        jsr read_complete_input
        jmp ?loop
.endp

.proc wait_frame
        lda RTCLOK+2
?wait   cmp RTCLOK+2
        beq ?wait
        rts
.endp

;==============================================================================
; Input
;==============================================================================
.proc read_input
        lda #0
        sta input_x
        lda PORTA
        and #15
        sta stick_now
        and #4
        bne ?right
        lda #$FF
        sta input_x
?right  lda stick_now
        and #8
        bne ?fire
        lda #1
        sta input_x

?fire   lda STRIG0
        eor #1
        sta fire_now
        cmp old_fire
        beq ?keyboard
        sta old_fire
        beq ?keyboard
        lda #1
        sta jump_pressed

?keyboard
        lda SKSTAT
        and #4                  ; zero while a keyboard key is held
        bne ?key_event
        lda KBCODE
        and #$3F
        cmp #$3F               ; A
        bne ?held_d
        lda #$FF
        sta input_x
        jmp ?key_event
?held_d cmp #$3A               ; D
        bne ?key_event
        lda #1
        sta input_x

?key_event
        lda CH
        cmp #$FF
        beq ?console
        and #$3F
        sta key_temp
        lda #$FF
        sta CH
        lda key_temp
        jsr select_level_shortcut
        bcc ?game_key
        jmp ?console
?game_key
        lda key_temp
        cmp #$3F               ; A
        bne ?key_d
        lda #$FF
        sta input_x
        jmp ?console
?key_d  cmp #$3A               ; D
        bne ?key_jump
        lda #1
        sta input_x
        jmp ?console
?key_jump
        cmp #$21               ; Space
        beq ?jump
        cmp #$2E               ; W
        bne ?key_restart
?jump   lda #1
        sta jump_pressed
        jmp ?console
?key_restart
        cmp #$28               ; R
        bne ?console
        jsr init_level

?console
        lda CONSOL
        and #7
        sta console_now
        cmp old_console
        beq ?done
        sta old_console
        and #2                  ; SELECT
        bne ?done
        jsr init_level
?done   rts
.endp

; Temporary direct room selection for testing. These are physical POKEY key
; codes with Shift/Control bits removed. Gameplay keys A/D/W/R/Space are not
; present. Slot 13 (rKey0) is an empty automatic transition, so it is omitted.
.proc select_level_shortcut
        ldx #0
?find   cmp level_shortcut_codes,x
        beq ?select
        inx
        cpx #LEVEL_SHORTCUT_COUNT
        bcc ?find
        clc
        rts
?select lda level_shortcut_levels,x
        sta level_number
        jsr init_level
        sec
        rts

;       1   2   3   4   5   6   7   8   9   0   Q   E
level_shortcut_codes
        dta $1F,$1E,$1A,$18,$1D,$1B,$33,$35,$30,$32,$2F,$2A
;       T   Y   U   I   O   P   S   F   G   H   J
        dta $2D,$2B,$0B,$0D,$08,$0A,$3E,$38,$3D,$39,$01
level_shortcut_levels
        dta 0,1,2,3,4,5,6,7,8,9,10,11
        dta 13,14,15,16,17,18,19,20,21,22,23
.endp

.proc read_complete_input
        lda STRIG0
        beq ?restart
        lda CH
        cmp #$FF
        beq ?done
        and #$3F
        sta key_temp
        lda #$FF
        sta CH
        lda key_temp
        jsr select_level_shortcut
        bcs ?done
        lda key_temp
        cmp #$21               ; Space
        bne ?done
?restart
        lda #$FF
        sta CH
        lda #0
        sta level_number
        sta game_complete
        jsr init_level
?done   rts
.endp

;==============================================================================
; Level setup
;==============================================================================
.proc init_level
        ; rKey0 is the original non-playable halfway interstitial. Continue to
        ; rKey1 just as its fade controller does in Sulka.js.
        lda level_number
        cmp #12
        bne ?playable
        inc level_number
?playable
        lda #0
        sta game_complete
        sta jump_pressed
        sta input_x
        sta vy
        sta y_fraction
        sta gravity_phase
        sta line_latch
        sta line_speed
        sta offscreen_side
        sta message_timer
        sta player_anim_tick
        sta player_anim_frame
        sta player_anim_mode
        sta player_anim_moving
        lda #1
        sta gravity_dir

        ldx level_number
        lda levels_lo,x
        sta level_ptr
        lda levels_hi,x
        sta level_ptr+1
        jsr copy_level
        jsr scan_level
        jsr init_fly_spikes
        lda spawn_x
        sta player_x
        lda spawn_y
        sta player_y
        jsr draw_status
        jsr build_room_cache
        jmp draw_dynamic
.endp

.proc copy_level
        lda level_ptr
        sta work_ptr
        lda level_ptr+1
        sta work_ptr+1
        lda #<level_map
        sta text_dst
        lda #>level_map
        sta text_dst+1
        ldx #>MAP_SIZE
        ldy #0
?page   lda (work_ptr),y
        sta (text_dst),y
        iny
        bne ?page
        inc work_ptr+1
        inc text_dst+1
        dex
        bne ?page
        ldx #<MAP_SIZE
        beq ?done
?tail   lda (work_ptr),y
        sta (text_dst),y
        iny
        dex
        bne ?tail
?done   rts
.endp

.proc scan_level
        lda #0
        sta keys_left
        sta scan_x
        sta scan_y
        lda #<level_map
        sta work_ptr
        lda #>level_map
        sta work_ptr+1
        ldy #0
?cell   lda (work_ptr),y
        cmp #T_KEY
        bne ?player
        inc keys_left
        jmp ?next
?player cmp #T_PLAYER
        bne ?next
        lda scan_x
        jsr times_ten
        clc
        adc #2
        sta spawn_x
        lda scan_y
        jsr times_ten
        clc
        adc #1
        sta spawn_y
        lda #T_EMPTY
        sta (work_ptr),y
?next   inc work_ptr
        bne ?ptr_ok
        inc work_ptr+1
?ptr_ok inc scan_x
        lda scan_x
        cmp #MAP_W
        bcc ?continue
        lda #0
        sta scan_x
        inc scan_y
        lda scan_y
        cmp #MAP_H
        bcs ?done
?continue
        jmp ?cell
?done   rts
.endp

.proc times_ten
        sta math_temp
        asl
        sta math_temp2
        asl
        asl
        clc
        adc math_temp2
        rts
.endp

;==============================================================================
; Original moving fly-spikes (oFlySpike)
;==============================================================================
.proc init_fly_spikes
        ldx level_number
        lda fly_config_lo,x
        sta work_ptr
        lda fly_config_hi,x
        sta work_ptr+1
        ldy #0
        lda (work_ptr),y
        sta fly_count
        tax
        beq ?done
        ldx #0
?copy  iny
        lda (work_ptr),y
        sta fly_x,x
        sta fly_start_x,x
        iny
        lda (work_ptr),y
        sta fly_y,x
        sta fly_start_y,x
        iny
        lda (work_ptr),y
        sta fly_end_x,x
        iny
        lda (work_ptr),y
        sta fly_end_y,x
        lda #0
        sta fly_direction,x
        sta fly_pause,x
        inx
        cpx fly_count
        bcc ?copy
?done  rts
.endp

.proc update_fly_spikes
        ldx #0
?next  cpx fly_count
        bcs ?done
        lda fly_pause,x
        beq ?targets
        dec fly_pause,x
        jmp ?advance

?targets
        lda fly_direction,x
        beq ?toward_end
        lda fly_start_x,x
        sta fly_target_x
        lda fly_start_y,x
        sta fly_target_y
        jmp ?move_x
?toward_end
        lda fly_end_x,x
        sta fly_target_x
        lda fly_end_y,x
        sta fly_target_y

?move_x
        lda fly_x,x
        cmp fly_target_x
        beq ?move_y
        bcc ?inc_x
        dec fly_x,x
        jmp ?move_y
?inc_x inc fly_x,x

?move_y
        lda fly_y,x
        cmp fly_target_y
        beq ?at_target
        bcc ?inc_y
        dec fly_y,x
        jmp ?advance
?inc_y inc fly_y,x
        jmp ?advance

?at_target
        lda fly_x,x
        cmp fly_target_x
        bne ?advance
        lda fly_direction,x
        eor #1
        sta fly_direction,x
        lda #15                ; original 0.5 s pause at 2x elapsed-time rate
        sta fly_pause,x
?advance
        inx
        jmp ?next
?done  rts
.endp

.proc check_fly_spikes
        lda offscreen_side
        bne ?done
        ldx #0
?next  cpx fly_count
        bcs ?done
        lda fly_x,x
        clc
        adc #2                  ; exact sFlySpike bounding box: 2..7
        sta test_x
        lda player_x
        clc
        adc #PLAYER_W-1
        cmp test_x
        bcc ?advance
        lda fly_x,x
        clc
        adc #8
        sta test_x
        lda player_x
        cmp test_x
        bcs ?advance
        lda fly_y,x
        clc
        adc #2
        sta test_y
        lda player_y
        clc
        adc #PLAYER_H-1
        cmp test_y
        bcc ?advance
        lda fly_y,x
        clc
        adc #8
        sta test_y
        lda player_y
        cmp test_y
        bcs ?advance
        jsr player_died
        rts
?advance
        inx
        jmp ?next
?done  rts
.endp

;==============================================================================
; Player physics
;==============================================================================
.proc update_player
        lda #0
        sta player_anim_moving
        lda message_timer
        beq ?active
        dec message_timer
        rts

?active lda offscreen_side
        beq ?room_input
        ; Off-screen movement has no room geometry to collide with, but keep
        ; horizontal steering so Sulka can choose where to re-enter.
        lda input_x
        beq ?gravity
        bmi ?offscreen_left
        lda #1
        sta facing
        lda player_x
        cmp #MAP_W*TILE-PLAYER_W-1
        bcs ?gravity
        clc
        adc #2
        sta player_x
        jmp ?gravity
?offscreen_left
        lda #$FF
        sta facing
        lda player_x
        cmp #2
        bcc ?offscreen_left_edge
        sec
        sbc #2
        sta player_x
        jmp ?gravity
?offscreen_left_edge
        lda #0
        sta player_x
        jmp ?gravity

?room_input
        lda input_x
        beq ?gravity
        bmi ?left
        lda #1
        jsr move_horizontal
        bcc ?face_right
        inc player_anim_moving
        lda #1
        jsr move_horizontal
?face_right
        lda #1
        sta facing
        jmp ?gravity
?left   lda #$FF
        jsr move_horizontal
        bcc ?face_left
        inc player_anim_moving
        lda #$FF
        jsr move_horizontal
?face_left
        lda #$FF
        sta facing

?gravity
        lda gravity_dir
        bmi ?grav_up
        lda vy
        bmi ?inc_down
        cmp #48                ; 2x-time fall limit: 12 px/frame
        bcs ?jump
?inc_down
        lda gravity_phase
        eor #1
        sta gravity_phase
        clc
        adc #2                 ; alternate 3/2 quarters = 0.625 px/frame^2
        clc
        adc vy
        sta vy
        jmp ?jump
?grav_up
        lda vy
        bpl ?inc_up
        cmp #$D0               ; -48 quarter-pixels = -12 px/frame
        bcc ?jump
        beq ?jump
?inc_up
        lda gravity_phase
        eor #1
        sta gravity_phase
        clc
        adc #2
        sta math_temp
        lda vy
        sec
        sbc math_temp
        sta vy

?jump   lda jump_pressed
        beq ?vertical
        lda #0
        sta jump_pressed
        lda offscreen_side
        bne ?vertical
        jsr is_grounded
        bcc ?vertical
        lda #0
        sta gravity_phase
        lda gravity_dir
        bmi ?jump_down
        lda #$E8               ; -24 quarter-pixels = -6 px/frame
        sta vy
        jmp ?vertical
?jump_down
        lda #24
        sta vy

?vertical
        lda vy
        beq ?done
        clc
        adc y_fraction
        bmi ?move_up
        sta move_sum
        and #3
        sta y_fraction
        lda move_sum
        lsr
        lsr
        sta move_steps
        beq ?done
?down_loop
        lda #1
        jsr move_vertical
        bcc ?stop
        dec move_steps
        bne ?down_loop
        jmp ?done
?move_up
        sta move_sum
        eor #$FF
        clc
        adc #1
        sta math_temp
        clc
        adc #3
        lsr
        lsr
        sta move_steps
        asl
        asl
        sec
        sbc math_temp
        sta y_fraction
?up_loop
        lda #$FF
        jsr move_vertical
        bcc ?stop
        dec move_steps
        bne ?up_loop
        jmp ?done
?stop   lda #0
        sta vy
        sta y_fraction
        sta line_speed
?done   rts
.endp

; A = signed one-pixel horizontal delta. Carry set if movement succeeded.
.proc move_horizontal
        sta move_delta
        clc
        adc player_x
        sta test_x
        lda move_delta
        bmi ?left_edge
        lda test_x
        clc
        adc #PLAYER_W-1
        jmp ?test
?left_edge
        lda test_x
?test   sta pixel_x
        lda player_y
        sta pixel_y
        jsr solid_at_pixel
        bcs ?blocked
        lda player_y
        clc
        adc #PLAYER_H-1
        sta pixel_y
        jsr solid_at_pixel
        bcs ?blocked
        lda test_x
        sta player_x
        sec
        rts
?blocked
        clc
        rts
.endp

; A = signed one-pixel vertical delta. Carry set if movement succeeded.
.proc move_vertical
        sta move_delta
        lda offscreen_side
        beq ?inside
        bmi ?above

        ; Below the room: move freely until an upward step returns the
        ; player's top edge from Y=101 to the last in-room position, Y=100.
        lda move_delta
        bmi ?below_up
        lda player_y
        cmp #239
        bcc ?direct
        lda #240               ; distant safety clamp; check_special decides
        sta player_y
        clc
        rts
?below_up
        lda player_y
        cmp #MAP_H*TILE-PLAYER_H+1
        beq ?calculate
        jmp ?direct

        ; Above the room: move freely until a downward step wraps -1 to Y=0.
?above
        lda move_delta
        bpl ?above_down
        lda player_y
        cmp #129
        bcs ?direct
        lda #128               ; symmetric distant safety clamp
        sta player_y
        clc
        rts
?above_down
        lda player_y
        cmp #$FF
        beq ?calculate
?direct
        lda move_delta
        clc
        adc player_y
        sta player_y
        sec
        rts

?inside
        lda move_delta
        bpl ?inside_down
        lda player_y
        bne ?calculate
        lda #$FF
        sta player_y
        sta offscreen_side
        sec
        rts
?inside_down
        lda player_y
        cmp #MAP_H*TILE-PLAYER_H
        bne ?calculate
        lda #MAP_H*TILE-PLAYER_H+1
        sta player_y
        lda #1
        sta offscreen_side
        sec
        rts

?calculate
        lda move_delta
        clc
        adc player_y
        sta test_y
        lda move_delta
        bmi ?top_edge
        lda test_y
        clc
        adc #PLAYER_H-1
        jmp ?test
?top_edge
        lda test_y
?test   sta pixel_y
        lda player_x
        sta pixel_x
        jsr solid_at_pixel
        bcs ?blocked
        lda player_x
        clc
        adc #PLAYER_W-1
        sta pixel_x
        jsr solid_at_pixel
        bcs ?blocked

        ; Sulka may steer while outside. On re-entry, also test the trailing
        ; edge so the sprite cannot come back through a floor or ceiling.
        lda offscreen_side
        beq ?accept
        bmi ?above_trailing
        lda test_y
        clc
        adc #PLAYER_H-1
        jmp ?test_trailing
?above_trailing
        lda test_y
?test_trailing
        sta pixel_y
        lda player_x
        sta pixel_x
        jsr solid_at_pixel
        bcs ?blocked
        lda player_x
        clc
        adc #PLAYER_W-1
        sta pixel_x
        jsr solid_at_pixel
        bcs ?blocked

?accept
        lda test_y
        sta player_y
        lda #0
        sta offscreen_side
        sec
        rts
?blocked
        clc
        rts
.endp

.proc is_grounded
        lda gravity_dir
        bmi ?up
        lda player_y
        clc
        adc #PLAYER_H
        jmp ?test
?up     lda player_y
        sec
        sbc #1
?test   sta pixel_y
        lda player_x
        sta pixel_x
        jsr solid_at_pixel
        bcs ?yes
        lda player_x
        clc
        adc #PLAYER_W-1
        sta pixel_x
        jsr solid_at_pixel
        bcs ?yes
        clc
        rts
?yes    sec
        rts
.endp

.proc solid_at_pixel
        jsr get_tile_at_pixel
        cmp #T_WALL
        beq ?solid
        clc
        rts
?solid  sec
        rts
.endp

; pixel_x/pixel_y are local board coordinates. Returns tile in A.
.proc get_tile_at_pixel
        lda pixel_x
        ldx #0
?col   cmp #TILE
        bcc ?col_done
        sec
        sbc #TILE
        inx
        bne ?col
?col_done
        stx tile_col
        lda pixel_y
        ldx #0
?row   cmp #TILE
        bcc ?row_done
        sec
        sbc #TILE
        inx
        bne ?row
?row_done
        stx tile_row

        lda #0
        sta tile_index
        sta tile_index+1
        ldx tile_row
        beq ?add_col
?add_row
        clc
        lda tile_index
        adc #MAP_W
        sta tile_index
        bcc ?row_nc
        inc tile_index+1
?row_nc
        dex
        bne ?add_row
?add_col
        clc
        lda tile_index
        adc tile_col
        sta tile_index
        bcc ?addr
        inc tile_index+1
?addr   clc
        lda #<level_map
        adc tile_index
        sta work_ptr
        lda #>level_map
        adc tile_index+1
        sta work_ptr+1
        ldy #0
        lda (work_ptr),y
        rts
.endp

;==============================================================================
; Keys, spikes, gravity lines and exits
;==============================================================================
.proc check_special_tiles
        lda offscreen_side
        beq ?onscreen
        bmi ?above_room

        ; rViiva0 deliberately finishes by falling into the nest below.
        lda level_number
        cmp #5
        beq ?offscreen_complete
        lda player_y
        cmp #240
        bcs ?offscreen_dead
        lda gravity_dir
        bmi ?offscreen_safe     ; upward gravity can bring Sulka back
        jmp ?offscreen_dead

?above_room
        lda player_y
        cmp #129
        bcc ?offscreen_dead
        lda gravity_dir
        bpl ?offscreen_safe     ; downward gravity can bring Sulka back
?offscreen_dead
        jsr player_died
        jmp ?done
?offscreen_complete
        jsr complete_level
        jmp ?done
?offscreen_safe
        rts

?onscreen
        lda player_x
        clc
        adc #PLAYER_W/2
        sta pixel_x
        lda player_y
        clc
        adc #PLAYER_H/2
        sta pixel_y
        jsr get_tile_at_pixel
        sta current_tile

        cmp #T_LINE
        bne ?leave_line
        lda line_latch
        bne ?hazards
        lda gravity_dir
        bmi ?line_gravity_up

        ; The original line changes normal gravity only while Sulka is
        ; falling.  Jumping upward through it must not launch the player off
        ; the top of the room.
        lda vy
        beq ?hazards
        bmi ?hazards
        lda #1
        sta line_latch
        lda #$FF
        sta gravity_dir
        lda vy
        cmp #24                ; original minimum 3 px/frame, doubled here
        bcs ?compare_down_speed
        lda #24
?compare_down_speed
        cmp line_speed
        bcs ?store_down_speed
        lda line_speed
?store_down_speed
        sta vy
        sta line_speed
        jmp ?hazards

?line_gravity_up
        ; The inverse transition likewise happens only while moving upward.
        lda vy
        beq ?flip_gravity_down
        bpl ?hazards
?flip_gravity_down
        lda #1
        sta line_latch
        lda #1
        sta gravity_dir
        lda vy
        beq ?minimum_up_speed
        eor #$FF
        clc
        adc #1                 ; absolute upward speed
        cmp #24
        bcs ?compare_up_speed
?minimum_up_speed
        lda #24
?compare_up_speed
        cmp line_speed
        bcs ?store_up_speed
        lda line_speed
?store_up_speed
        sta line_speed
        eor #$FF
        clc
        adc #1
        sta vy
        jmp ?hazards
?leave_line
        lda #0
        sta line_latch

?hazards
        lda current_tile
        cmp #T_KEY
        bne ?spike
        jsr erase_current_tile
        lda #T_EMPTY
        ldy #0
        sta (work_ptr),y
        lda keys_left
        beq ?status
        dec keys_left
?status jsr draw_status
        jsr build_room_cache
        jmp ?done

?spike  cmp #T_SPIKE
        bne ?spike_up
        lda pixel_y
?spike_mod
        cmp #TILE
        bcc ?spike_half
        sec
        sbc #TILE
        bcs ?spike_mod
?spike_half
        cmp #5                  ; lower half contains the upright spike
        bcs ?spike_hit
        jmp ?done
?spike_hit
        jsr player_died
        jmp ?done

?spike_up
        cmp #T_SPIKE_UP
        bne ?spike_right
        lda pixel_y
?spike_up_mod
        cmp #TILE
        bcc ?spike_up_half
        sec
        sbc #TILE
        bcs ?spike_up_mod
?spike_up_half
        cmp #5                  ; upper half contains the inverted spike
        bcs ?done
        jsr player_died
        jmp ?done

?spike_right
        cmp #T_SPIKE_RIGHT
        bne ?spike_left
        lda pixel_x
?spike_right_mod
        cmp #TILE
        bcc ?spike_right_half
        sec
        sbc #TILE
        bcs ?spike_right_mod
?spike_right_half
        cmp #5
        bcc ?done
        jsr player_died
        jmp ?done

?spike_left
        cmp #T_SPIKE_LEFT
        bne ?door
        lda pixel_x
?spike_left_mod
        cmp #TILE
        bcc ?spike_left_half
        sec
        sbc #TILE
        bcs ?spike_left_mod
?spike_left_half
        cmp #5
        bcs ?done
        jsr player_died
        jmp ?done

?door   cmp #T_DOOR
        beq ?at_door
        cmp #T_DOOR_UP
        bne ?nest
?at_door
        lda keys_left
        bne ?done
        jsr complete_level
        jmp ?done

?nest   cmp #T_NEST
        bne ?bounds
        lda level_number
        cmp #LEVELS-1
        bne ?bounds
        jsr complete_level
        jmp ?done

?bounds
        lda player_x
        cmp #MAP_W*TILE-PLAYER_W
        bcs ?dead
        bcc ?done
?dead   jsr player_died
?done   rts
.endp

.proc player_died
        ; Death restarts the whole room, not only the player's position.
        ; This recopies the original level map, restores collected keys,
        ; closes keyed doors, resets moving hazards, and rebuilds the cache.
        jsr init_level
        lda #20
        sta message_timer
        rts
.endp

.proc complete_level
        inc level_number
        lda level_number
        cmp #LEVELS
        bcc ?next
        lda #1
        sta game_complete
        jsr draw_status
        jsr build_room_cache
        jmp draw_dynamic
?next   jmp init_level
.endp

;==============================================================================
; ANTIC status text
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
        lda #$9A
        sta COLOR1
        lda #$00
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

.proc draw_status
        ldx #39
        lda #0
?clear  sta text_screen,x
        sta text_screen+40,x
        sta text_screen+23*40,x
        sta text_screen+24*40,x
        dex
        bpl ?clear

        lda #<s_title
        sta text_src
        lda #>s_title
        sta text_src+1
        lda #<[text_screen+14]
        sta text_dst
        lda #>[text_screen+14]
        sta text_dst+1
        jsr copy_text

        lda #<s_level
        sta text_src
        lda #>s_level
        sta text_src+1
        lda #<[text_screen+40+2]
        sta text_dst
        lda #>[text_screen+40+2]
        sta text_dst+1
        jsr copy_text
        lda game_complete
        beq ?level_value
        lda #LEVELS-1
        bne ?level_ready
?level_value
        lda level_number
?level_ready
        clc
        adc #1
        ldx #0
?level_tens
        cmp #10
        bcc ?level_digits
        sec
        sbc #10
        inx
        bne ?level_tens
?level_digits
        pha
        txa
        beq ?blank_tens
        clc
        adc #16
?blank_tens
        sta text_screen+40+8
        pla
        clc
        adc #16
        sta text_screen+40+9
        lda #15                ; ATASCII screen-code slash
        sta text_screen+40+10
        lda #18                ; 2
        sta text_screen+40+11
        lda #20                ; 4
        sta text_screen+40+12

        lda #<s_keys
        sta text_src
        lda #>s_keys
        sta text_src+1
        lda #<[text_screen+40+14]
        sta text_dst
        lda #>[text_screen+40+14]
        sta text_dst+1
        jsr copy_text
        lda keys_left
        clc
        adc #16
        sta text_screen+40+19

        lda #<s_controls
        sta text_src
        lda #>s_controls
        sta text_src+1
        lda #<[text_screen+23*40]
        sta text_dst
        lda #>[text_screen+23*40]
        sta text_dst+1
        jsr copy_text

        lda game_complete
        beq ?hint
        lda #<s_complete
        sta text_src
        lda #>s_complete
        sta text_src+1
        jmp ?message
?hint   lda keys_left
        beq ?door_open
        lda #<s_hint_keys
        sta text_src
        lda #>s_hint_keys
        sta text_src+1
        jmp ?message
?door_open
        lda #<s_hint_door
        sta text_src
        lda #>s_hint_door
        sta text_src+1
?message
        lda #<[text_screen+24*40]
        sta text_dst
        lda #>[text_screen+24*40]
        sta text_dst+1
        jmp copy_text
.endp

s_title      dta 10,d'SULKA VBXE'
s_level      dta 6,d'LEVEL '
s_keys       dta 5,d'KEYS '
s_controls   dta 39,d'JOY/A-D MOVE  FIRE/SPACE JUMP  SELECT/R'
s_hint_keys  dta 36,d'COLLECT EVERY KEY. GRAVITY LINES FLIP.'
s_hint_door  dta 35,d'DOOR OPEN! REACH THE GOLDEN EXIT NOW.'
s_complete   dta 37,d'ALL LEVELS COMPLETE! FIRE TO REPLAY.'
s_need_vbxe  dta 13,d'VBXE REQUIRED'

;==============================================================================
; Renderer
;==============================================================================
.proc draw_screen
        jsr build_room_cache
        jmp draw_dynamic
.endp

; Porter-style double buffering. The displayed framebuffer is never modified:
; a complete frame is assembled in the hidden buffer and published at VBL.
.proc draw_dynamic
        jsr copy_room_cache
        lda back_bank
        sta render_bank
        lda game_complete
        bne ?present
        jsr draw_fly_spikes
        lda offscreen_side
        bne ?present
        jsr draw_player
?present
        jsr wait_blit
        jmp present_back_buffer
.endp

.proc draw_fly_spikes
        lda #0
        sta fly_index
?next  ldx fly_index
        cpx fly_count
        bcs ?done
        lda fly_x,x
        clc
        adc #BOARD_X
        sta calc_x
        lda #0
        adc #0
        sta calc_x+1
        lda fly_y,x
        clc
        adc #BOARD_Y
        sta calc_y
        jsr draw_fly_sprite
        inc fly_index
        jmp ?next
?done  rts
.endp

; One transparent 10x10 VBXE blit replaces the 31 tiny fill operations that
; were previously used to draw every moving enemy as a static floor spike.
.proc draw_fly_sprite
        jsr calc_addr
        lda #0
        sta bl_src
        sta bl_src+1
        lda #FLY_SPRITE_BANK
        sta bl_src+2
        lda #FLY_W
        sta bl_ssy
        lda #0
        sta bl_ssy+1
        lda #1
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
        lda #FLY_W-1
        sta bl_w
        lda #0
        sta bl_w+1
        lda #FLY_H-1
        sta bl_h
        lda #$FF
        sta bl_and
        lda #0
        sta bl_xor
        lda #1                  ; zero pixels are transparent
        sta bl_mode
        jmp do_blit
.endp

.proc build_room_cache
        lda #ROOM_CACHE_BANK
        sta render_bank
        jsr clear_framebuffer
        jsr draw_board
        lda game_complete
        bne ?done
        jsr draw_map
?done   jmp wait_blit
.endp

.proc copy_room_cache
        jsr wait_blit
        lda #<BOARD_ADDR
        sta bl_src
        lda #>BOARD_ADDR
        sta bl_src+1
        lda #ROOM_CACHE_BANK
        sta bl_src+2
        lda #<SCR_W
        sta bl_ssy
        lda #>SCR_W
        sta bl_ssy+1
        lda #1
        sta bl_ssx
        lda #<BOARD_ADDR
        sta bl_dst
        lda #>BOARD_ADDR
        sta bl_dst+1
        lda back_bank
        sta bl_dst+2
        lda #<SCR_W
        sta bl_dsy
        lda #>SCR_W
        sta bl_dsy+1
        lda #1
        sta bl_dsx
        lda #<[MAP_W*TILE-1]
        sta bl_w
        lda #>[MAP_W*TILE-1]
        sta bl_w+1
        lda #MAP_H*TILE-1
        sta bl_h
        lda #$FF
        sta bl_and
        lda #0
        sta bl_xor
        sta bl_mode
        jmp do_blit
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

.proc erase_player
        jsr calculate_visual_position
        lda visual_x
        clc
        adc #BOARD_X
        sta calc_x
        lda #0
        adc #0
        sta calc_x+1
        lda visual_y
        clc
        adc #BOARD_Y
        sta calc_y
        lda #SPRITE_W
        ldx #SPRITE_H
        ldy #C_BOARD
        jmp small_fill
.endp

; Restore only the map cells touched by the old 10x12 bird. This replaces the
; previous full-room redraw and keeps the main loop close to one Atari frame.
.proc redraw_old_tiles
        lda visual_x
        sta pixel_x
        lda visual_y
        sta pixel_y
        jsr redraw_pixel_tile
        lda visual_x
        clc
        adc #SPRITE_W-1
        sta pixel_x
        jsr redraw_pixel_tile

        lda visual_x
        sta pixel_x
        lda visual_y
        clc
        adc #6
        sta pixel_y
        jsr redraw_pixel_tile
        lda visual_x
        clc
        adc #SPRITE_W-1
        sta pixel_x
        jsr redraw_pixel_tile

        lda visual_x
        sta pixel_x
        lda visual_y
        clc
        adc #SPRITE_H-1
        sta pixel_y
        jsr redraw_pixel_tile
        lda visual_x
        clc
        adc #SPRITE_W-1
        sta pixel_x
        jmp redraw_pixel_tile
.endp

.proc redraw_pixel_tile
        jsr get_tile_at_pixel
        sta draw_type
        lda tile_col
        jsr times_ten
        clc
        adc #BOARD_X
        sta tile_x
        lda #0
        adc #0
        sta tile_x+1
        lda tile_row
        jsr times_ten
        clc
        adc #BOARD_Y
        sta tile_y
        lda draw_type
        cmp #T_WALL
        beq ?wall
        cmp #T_KEY
        beq ?key
        cmp #T_DOOR
        beq ?door
        cmp #T_DOOR_UP
        beq ?door_up
        cmp #T_NEST
        beq ?nest
        cmp #T_SPIKE
        beq ?spike
        cmp #T_SPIKE_UP
        beq ?spike_up
        cmp #T_SPIKE_RIGHT
        beq ?spike_right
        cmp #T_SPIKE_LEFT
        beq ?spike_left
        cmp #T_SPIKE_DECOR
        beq ?spike
        cmp #T_LINE
        beq ?line
        rts
?wall   jmp draw_wall
?key    jmp draw_key
?door   jmp draw_door
?door_up
        jmp draw_door_up
?nest   jmp draw_nest
?spike  jmp draw_spike
?spike_up
        jmp draw_spike_up
?spike_right
        jmp draw_spike_right
?spike_left
        jmp draw_spike_left
?line   jmp draw_line
.endp

; get_tile_at_pixel leaves tile_col/tile_row identifying the collected key.
.proc erase_current_tile
        lda tile_col
        jsr times_ten
        clc
        adc #BOARD_X
        sta calc_x
        lda #0
        adc #0
        sta calc_x+1
        lda tile_row
        jsr times_ten
        clc
        adc #BOARD_Y
        sta calc_y
        lda #TILE
        ldx #TILE
        ldy #C_BOARD
        jmp small_fill
.endp

.proc clear_framebuffer
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

        rts
.endp

.proc draw_board
        lda #BOARD_X
        sta calc_x
        lda #0
        sta calc_x+1
        lda #BOARD_Y
        sta calc_y
        lda #MAP_W*TILE
        sta fr_w
        lda #0
        sta fr_w+1
        lda #MAP_H*TILE
        sta fr_h
        lda #C_BOARD
        sta fr_col
        jmp fill_rect
.endp

.proc draw_map
        lda #<level_map
        sta work_ptr
        lda #>level_map
        sta work_ptr+1
        lda #0
        sta draw_row
        lda #BOARD_Y
        sta tile_y
?row    lda #0
        sta draw_col
        lda #BOARD_X
        sta tile_x
        lda #0
        sta tile_x+1
?cell   ldy #0
        lda (work_ptr),y
        sta draw_type
        inc work_ptr
        bne ?ptr_ok
        inc work_ptr+1
?ptr_ok
        lda draw_type
        cmp #T_WALL
        beq ?wall
        cmp #T_KEY
        beq ?key
        cmp #T_DOOR
        beq ?door
        cmp #T_DOOR_UP
        beq ?door_up
        cmp #T_NEST
        beq ?nest
        cmp #T_SPIKE
        beq ?spike
        cmp #T_SPIKE_UP
        beq ?spike_up
        cmp #T_SPIKE_RIGHT
        beq ?spike_right
        cmp #T_SPIKE_LEFT
        beq ?spike_left
        cmp #T_SPIKE_DECOR
        beq ?spike
        cmp #T_LINE
        beq ?line
        jmp ?next
?wall   jsr draw_wall
        jmp ?next
?key    jsr draw_key
        jmp ?next
?door   jsr draw_door
        jmp ?next
?door_up
        jsr draw_door_up
        jmp ?next
?nest   jsr draw_nest
        jmp ?next
?spike  jsr draw_spike
        jmp ?next
?spike_up
        jsr draw_spike_up
        jmp ?next
?spike_right
        jsr draw_spike_right
        jmp ?next
?spike_left
        jsr draw_spike_left
        jmp ?next
?line   jsr draw_line
?next   lda tile_x
        clc
        adc #TILE
        sta tile_x
        bcc ?tile_x_ok
        inc tile_x+1
?tile_x_ok
        inc draw_col
        lda draw_col
        cmp #MAP_W
        bcs ?next_row
        jmp ?cell
?next_row
        lda tile_y
        clc
        adc #TILE
        sta tile_y
        inc draw_row
        lda draw_row
        cmp #MAP_H
        bcs ?done
        jmp ?row
?done
        rts
.endp

.proc set_tile_calc
        clc
        adc tile_x
        sta calc_x
        lda #0
        adc #0
        sta calc_x+1
        tya
        clc
        adc tile_y
        sta calc_y
        rts
.endp

; A=width, X=height, Y=colour.
.proc small_fill
        sta fr_w
        lda #0
        sta fr_w+1
        stx fr_h
        sty fr_col
        jmp fill_rect
.endp

.proc draw_wall
        lda #$FD                ; centre the original 16-pixel sBox
        ldy #0
        jsr set_tile_sprite_base
        lda #<platform_pixels
        ldx #>platform_pixels
        ldy #16
        jmp draw_tile_runs
.endp

.proc draw_key
        lda #$FF                ; original 12x6 sKey frame
        ldy #2
        jsr set_tile_sprite_base
        lda #<key_pixels
        ldx #>key_pixels
        ldy #12
        jmp draw_tile_runs
.endp

.proc draw_door
        lda #$FF                ; the 17-pixel door stands on the next row
        ldy #$F9
        jsr set_tile_sprite_base
        lda keys_left
        beq ?open
        lda #<door_locked_pixels
        ldx #>door_locked_pixels
        bne ?draw
?open   lda #<door_pixels
        ldx #>door_pixels
?draw   ldy #12
        jmp draw_tile_runs
.endp

.proc draw_door_up
        lda #$FF                ; upside-down exit used after gravity lines
        ldy #0
        jsr set_tile_sprite_base
        lda keys_left
        beq ?open
        lda #<door_locked_pixels
        ldx #>door_locked_pixels
        bne ?draw
?open   lda #<door_pixels
        ldx #>door_pixels
?draw   sta text_src
        stx text_src+1
        lda #12
        sta run_sprite_w
        lda #17
        sta run_sprite_h
        lda #0
        sta run_flip_x
        lda #$FF
        sta run_flip_y
        jmp draw_run_sprite
.endp

.proc draw_line
        ; Align the line with ceiling spikes and the bottom edge of the
        ; seven-pixel platform artwork in the cell above.
        lda #1
        ldy #$FD               ; -3: touch the brick above
        jsr set_tile_calc
        lda #2
        ldx #2
        ldy #C_KEY
        jsr small_fill
        lda #5
        ldy #$FD
        jsr set_tile_calc
        lda #2
        ldx #2
        ldy #C_KEY
        jsr small_fill
        lda #9
        ldy #$FD
        jsr set_tile_calc
        lda #1
        ldx #2
        ldy #C_KEY
        jmp small_fill
.endp

.proc draw_spike
        lda #$FE                ; centre original 14x5 sSpike
        ldy #5
        jsr set_tile_sprite_base
        lda #<spike_pixels
        ldx #>spike_pixels
        ldy #14
        jmp draw_tile_runs
.endp

.proc draw_nest
        lda #0
        ldy #0
        jsr set_tile_sprite_base
        lda #<nest_pixels
        ldx #>nest_pixels
        ldy #18
        jmp draw_tile_runs
.endp

.proc draw_spike_up
        lda #$FE
        ldy #$FD               ; -3: close the platform cell's visual gap
        jsr set_tile_sprite_base
        lda #<spike_pixels
        sta text_src
        lda #>spike_pixels
        sta text_src+1
        lda #14
        sta run_sprite_w
        lda #5
        sta run_sprite_h
        lda #0
        sta run_flip_x
        lda #$FF
        sta run_flip_y
        jmp draw_run_sprite
.endp

.proc draw_spike_right
        lda #5
        ldy #$FE
        jsr set_tile_sprite_base
        lda #<spike_right_pixels
        ldx #>spike_right_pixels
        ldy #5
        jmp draw_tile_runs
.endp

.proc draw_spike_left
        lda #0
        ldy #$FE
        jsr set_tile_sprite_base
        lda #<spike_left_pixels
        ldx #>spike_left_pixels
        ldy #5
        jmp draw_tile_runs
.endp

.proc draw_player
        jsr calculate_visual_position

        ; The original changes between sPlayer and sPlayer_walk only while
        ; grounded. In the air, the selected animation keeps running.
        jsr is_grounded
        bcc ?advance
        lda player_anim_moving
        beq ?idle
        lda #1
        bne ?mode
?idle   lda #0
?mode   cmp player_anim_mode
        beq ?advance
        sta player_anim_mode
        lda #0
        sta player_anim_tick
        sta player_anim_frame
?advance
        lda player_anim_mode
        beq ?advance_idle
        clc
        lda player_anim_tick
        adc #16                 ; exact 16 fps accumulator at a 60 Hz game rate
        sta player_anim_tick
        cmp #60
        bcc ?select_walk
        sec
        sbc #60
        sta player_anim_tick
        inc player_anim_frame
        lda player_anim_frame
        and #3
        sta player_anim_frame
?select_walk
        ldx player_anim_frame
        lda walk_frames_lo,x
        sta text_src
        lda walk_frames_hi,x
        sta text_src+1
        jmp ?position

?advance_idle
        inc player_anim_tick
        lda player_anim_tick
        cmp #60                 ; original sPlayer playback speed: 1 fps
        bcc ?select_idle
        lda #0
        sta player_anim_tick
        inc player_anim_frame
        lda player_anim_frame
        and #1
        sta player_anim_frame
?select_idle
        ldx player_anim_frame
        lda idle_frames_lo,x
        sta text_src
        lda idle_frames_hi,x
        sta text_src+1

?position
        clc
        lda visual_x
        adc #BOARD_X
        sta sprite_base_x
        lda #0
        adc #0
        sta sprite_base_x+1
        clc
        lda visual_y
        adc #BOARD_Y
        sta sprite_base_y
        lda #SPRITE_W
        sta run_sprite_w
        lda #SPRITE_H
        sta run_sprite_h
        lda #0
        sta run_flip_x
        sta run_flip_y
        lda facing
        bpl ?gravity
        dec run_flip_x
?gravity
        lda gravity_dir
        bpl ?draw
        dec run_flip_y
?draw   jmp draw_run_sprite
.endp

; A=signed X offset and Y=signed Y offset from the current map cell.
.proc set_tile_sprite_base
        sta math_temp
        clc
        lda tile_x
        adc math_temp
        sta sprite_base_x
        lda #0
        bit math_temp
        bpl ?x_sign
        lda #$FF
?x_sign adc tile_x+1
?x_ready
        sta sprite_base_x+1
        tya
        clc
        adc tile_y
        sta sprite_base_y
        rts
.endp

; A/X=run table address, Y=logical width. Tile sprites are never mirrored.
.proc draw_tile_runs
        sta text_src
        stx text_src+1
        sty run_sprite_w
        lda #0
        sta run_flip_x
        sta run_flip_y
        jmp draw_run_sprite
.endp

; Draw x,y,width,colour runs terminated by $FF.
.proc draw_run_sprite
?next   ldy #0
        lda (text_src),y
        cmp #$FF
        beq ?done
        sta bird_run_x
        iny
        lda (text_src),y
        sta bird_run_y
        iny
        lda (text_src),y
        sta bird_run_w
        iny
        lda (text_src),y
        sta bird_run_col
        clc
        lda text_src
        adc #4
        sta text_src
        bcc ?ptr_ok
        inc text_src+1
?ptr_ok

        lda run_flip_x
        beq ?x_ready
        lda run_sprite_w
        sec
        sbc bird_run_x
        sec
        sbc bird_run_w
        sta bird_run_x
?x_ready
        lda run_flip_y
        beq ?y_ready
        lda run_sprite_h
        sec
        sbc #1
        sec
        sbc bird_run_y
        sta bird_run_y
?y_ready
        clc
        lda sprite_base_x
        adc bird_run_x
        sta calc_x
        lda sprite_base_x+1
        adc #0
        sta calc_x+1
        clc
        lda sprite_base_y
        adc bird_run_y
        sta calc_y
        lda bird_run_w
        ldx #1
        ldy bird_run_col
        jsr small_fill
        jmp ?next
?done   rts
.endp

.proc calculate_visual_position
        lda player_x
        cmp #2
        bcc ?x_zero
        sec
        sbc #2
        bcs ?store_x
?x_zero lda #0
?store_x
        sta visual_x
        lda player_y
        cmp #4
        bcc ?y_zero
        sec
        sbc #4
        bcs ?store_y
?y_zero lda #0
?store_y
        sta visual_y
        rts
.endp

; Exact opaque runs extracted from Sulka_texture_0.png. Entries are
; x, y, width, palette colour; $FF terminates.
player_idle_0
        dta 4,0,4,C_PLAYER
        dta 4,1,1,C_PLAYER, 5,1,2,C_EYE, 7,1,2,C_PLAYER
        dta 3,2,1,C_PLAYER_H, 4,2,1,C_PLAYER, 5,2,2,C_EYE, 7,2,3,C_PLAYER
        dta 2,3,1,C_PLAYER, 3,3,1,C_PLAYER_H, 4,3,4,C_PLAYER
        dta 2,4,1,C_PLAYER, 3,4,5,C_PLAYER_H
        dta 1,5,4,C_PLAYER, 5,5,2,C_PLAYER_H, 7,5,1,C_PLAYER
        dta 0,6,5,C_PLAYER, 5,6,2,C_PLAYER_H, 7,6,1,C_PLAYER
        dta 2,7,4,C_PLAYER, 6,7,1,C_PLAYER_H, 7,7,1,C_PLAYER
        dta 2,8,6,C_PLAYER
        dta 3,9,1,C_PLAYER_H, 6,9,1,C_PLAYER_H
        dta 3,10,1,C_PLAYER, 6,10,1,C_PLAYER
        dta 3,11,1,C_PLAYER, 6,11,1,C_PLAYER
        dta $FF

player_walk_1
        dta 4,0,4,C_PLAYER
        dta 4,1,1,C_PLAYER, 5,1,2,C_EYE, 7,1,2,C_PLAYER
        dta 3,2,1,C_PLAYER_H, 4,2,1,C_PLAYER, 5,2,2,C_EYE, 7,2,3,C_PLAYER
        dta 2,3,1,C_PLAYER, 3,3,1,C_PLAYER_H, 4,3,4,C_PLAYER
        dta 2,4,1,C_PLAYER, 3,4,5,C_PLAYER_H
        dta 1,5,4,C_PLAYER, 5,5,2,C_PLAYER_H, 7,5,1,C_PLAYER
        dta 0,6,5,C_PLAYER, 5,6,2,C_PLAYER_H, 7,6,1,C_PLAYER
        dta 2,7,4,C_PLAYER, 6,7,1,C_PLAYER_H, 7,7,1,C_PLAYER
        dta 2,8,6,C_PLAYER
        dta 3,9,1,C_PLAYER_H, 6,9,1,C_PLAYER
        dta 3,10,1,C_PLAYER, 6,10,1,C_PLAYER
        dta 3,11,1,C_PLAYER
        dta $FF

player_idle_1
        dta 4,1,4,C_PLAYER
        dta 4,2,1,C_PLAYER, 5,2,2,C_EYE, 7,2,2,C_PLAYER
        dta 2,3,1,C_PLAYER, 3,3,1,C_PLAYER_H, 4,3,1,C_PLAYER
        dta 5,3,2,C_EYE, 7,3,3,C_PLAYER
        dta 2,4,1,C_PLAYER, 3,4,1,C_PLAYER_H, 4,4,4,C_PLAYER
        dta 1,5,2,C_PLAYER, 3,5,5,C_PLAYER_H
        dta 0,6,5,C_PLAYER, 5,6,2,C_PLAYER_H, 7,6,1,C_PLAYER
        dta 2,7,3,C_PLAYER, 5,7,2,C_PLAYER_H, 7,7,1,C_PLAYER
        dta 2,8,4,C_PLAYER, 6,8,1,C_PLAYER_H, 7,8,1,C_PLAYER
        dta 3,9,1,C_PLAYER_H, 6,9,1,C_PLAYER_H
        dta 3,10,1,C_PLAYER, 6,10,1,C_PLAYER
        dta 3,11,1,C_PLAYER, 6,11,1,C_PLAYER
        dta $FF

player_walk_3
        dta 4,1,4,C_PLAYER
        dta 4,2,1,C_PLAYER, 5,2,2,C_EYE, 7,2,2,C_PLAYER
        dta 2,3,1,C_PLAYER, 3,3,1,C_PLAYER_H, 4,3,1,C_PLAYER
        dta 5,3,2,C_EYE, 7,3,3,C_PLAYER
        dta 2,4,1,C_PLAYER, 3,4,1,C_PLAYER_H, 4,4,4,C_PLAYER
        dta 1,5,2,C_PLAYER, 3,5,5,C_PLAYER_H
        dta 0,6,5,C_PLAYER, 5,6,2,C_PLAYER_H, 7,6,1,C_PLAYER
        dta 2,7,3,C_PLAYER, 5,7,2,C_PLAYER_H, 7,7,1,C_PLAYER
        dta 2,8,4,C_PLAYER, 6,8,1,C_PLAYER_H, 7,8,1,C_PLAYER
        dta 3,9,1,C_PLAYER, 6,9,1,C_PLAYER_H
        dta 3,10,1,C_PLAYER, 6,10,1,C_PLAYER
        dta 6,11,1,C_PLAYER
        dta $FF

idle_frames_lo dta <player_idle_0,<player_idle_1
idle_frames_hi dta >player_idle_0,>player_idle_1
walk_frames_lo dta <player_idle_0,<player_walk_1,<player_idle_1,<player_walk_3
walk_frames_hi dta >player_idle_0,>player_walk_1,>player_idle_1,>player_walk_3

; Exact sFlySpike frame from Sulka_texture_0.png (atlas entry 104 at 840,500).
; Transparent pixels are zero; the opaque pixels use the original #46878f.
fly_sprite_raw
        dta 0,0,0,0,C_PLAYER_H,C_PLAYER_H,0,0,0,0
        dta 0,0,0,0,C_PLAYER_H,C_PLAYER_H,0,0,0,0
        :2 dta 0,0,0,0,0,0,0,0,0,0
        dta C_PLAYER_H,C_PLAYER_H,0,0,C_PLAYER_H,C_PLAYER_H,0,0,C_PLAYER_H,C_PLAYER_H
        dta C_PLAYER_H,C_PLAYER_H,0,0,C_PLAYER_H,C_PLAYER_H,0,0,C_PLAYER_H,C_PLAYER_H
        :2 dta 0,0,0,0,0,0,0,0,0,0
        dta 0,0,0,0,C_PLAYER_H,C_PLAYER_H,0,0,0,0
        dta 0,0,0,0,C_PLAYER_H,C_PLAYER_H,0,0,0,0

platform_pixels
        dta 0,0,1,C_EYE, 1,0,14,C_WALL, 15,0,1,C_EYE
        dta 0,1,16,C_WALL, 0,2,16,C_WALL, 0,3,16,C_WALL
        dta 0,4,16,C_WALL, 0,5,16,C_WALL
        dta 0,6,1,C_EYE, 1,6,14,C_WALL, 15,6,1,C_EYE
        dta $FF

door_pixels
        dta 3,0,6,C_EYE
        dta 3,1,1,C_EYE, 4,1,4,C_KEY, 8,1,1,C_EYE
        dta 1,2,10,C_EYE
        dta 1,3,1,C_EYE, 2,3,1,C_KEY, 3,3,6,C_EYE, 9,3,1,C_KEY, 10,3,1,C_EYE
        :6 dta 0,4+#*2,12,C_EYE
        :6 dta 0,5+#*2,1,C_EYE, 1,5+#*2,1,C_KEY, 2,5+#*2,8,C_EYE, 10,5+#*2,1,C_KEY, 11,5+#*2,1,C_EYE
        dta 0,16,12,C_EYE
        dta $FF

door_locked_pixels
        dta 3,0,6,C_EYE
        dta 3,1,1,C_EYE, 4,1,4,C_WALL, 8,1,1,C_EYE
        dta 1,2,10,C_EYE
        dta 1,3,1,C_EYE, 2,3,1,C_WALL, 3,3,6,C_EYE, 9,3,1,C_WALL, 10,3,1,C_EYE
        :6 dta 0,4+#*2,12,C_EYE
        :6 dta 0,5+#*2,1,C_EYE, 1,5+#*2,1,C_WALL, 2,5+#*2,8,C_EYE, 10,5+#*2,1,C_WALL, 11,5+#*2,1,C_EYE
        dta 0,16,12,C_EYE
        dta $FF

key_pixels
        dta 0,0,12,C_EYE
        dta 0,1,1,C_EYE, 1,1,4,C_KEY, 5,1,7,C_EYE
        dta 0,2,1,C_EYE, 1,2,1,C_KEY, 2,2,2,C_EYE, 4,2,1,C_KEY
        dta 5,2,1,C_EYE, 6,2,5,C_KEY, 11,2,1,C_EYE
        dta 0,3,1,C_EYE, 1,3,1,C_KEY, 2,3,2,C_EYE, 4,3,1,C_KEY
        dta 5,3,3,C_EYE, 8,3,1,C_KEY, 9,3,1,C_EYE, 10,3,1,C_KEY, 11,3,1,C_EYE
        dta 0,4,1,C_EYE, 1,4,4,C_KEY, 5,4,3,C_EYE, 8,4,1,C_KEY
        dta 9,4,1,C_EYE, 10,4,1,C_KEY, 11,4,1,C_EYE
        dta 0,5,12,C_EYE
        dta $FF

spike_pixels
        dta 0,0,14,C_EYE
        dta 0,1,1,C_EYE, 1,1,2,C_PLAYER_H, 3,1,3,C_EYE
        dta 6,1,2,C_PLAYER_H, 8,1,3,C_EYE, 11,1,2,C_PLAYER_H, 13,1,1,C_EYE
        dta 0,2,1,C_PLAYER_H, 1,2,2,C_EYE, 3,2,1,C_PLAYER_H
        dta 4,2,1,C_EYE, 5,2,1,C_PLAYER_H, 6,2,2,C_EYE
        dta 8,2,1,C_PLAYER_H, 9,2,1,C_EYE, 10,2,1,C_PLAYER_H
        dta 11,2,2,C_EYE, 13,2,1,C_PLAYER_H
        dta 0,3,1,C_PLAYER_H, 1,3,2,C_EYE, 3,3,1,C_PLAYER_H
        dta 4,3,1,C_EYE, 5,3,1,C_PLAYER_H, 6,3,2,C_EYE
        dta 8,3,1,C_PLAYER_H, 9,3,1,C_EYE, 10,3,1,C_PLAYER_H
        dta 11,3,2,C_EYE, 13,3,1,C_PLAYER_H
        dta 0,4,14,C_EYE
        dta $FF

; Exact 90-degree rotations of spike_pixels for rKey2.
spike_right_pixels
        dta 0,0,1,C_EYE, 1,0,2,C_PLAYER_H, 3,0,2,C_EYE
        dta 0,1,3,C_EYE, 3,1,1,C_PLAYER_H, 4,1,1,C_EYE
        dta 0,2,3,C_EYE, 3,2,1,C_PLAYER_H, 4,2,1,C_EYE
        dta 0,3,1,C_EYE, 1,3,2,C_PLAYER_H, 3,3,2,C_EYE
        dta 0,4,5,C_EYE
        dta 0,5,1,C_EYE, 1,5,2,C_PLAYER_H, 3,5,2,C_EYE
        dta 0,6,3,C_EYE, 3,6,1,C_PLAYER_H, 4,6,1,C_EYE
        dta 0,7,3,C_EYE, 3,7,1,C_PLAYER_H, 4,7,1,C_EYE
        dta 0,8,1,C_EYE, 1,8,2,C_PLAYER_H, 3,8,2,C_EYE
        dta 0,9,5,C_EYE
        dta 0,10,1,C_EYE, 1,10,2,C_PLAYER_H, 3,10,2,C_EYE
        dta 0,11,3,C_EYE, 3,11,1,C_PLAYER_H, 4,11,1,C_EYE
        dta 0,12,3,C_EYE, 3,12,1,C_PLAYER_H, 4,12,1,C_EYE
        dta 0,13,1,C_EYE, 1,13,2,C_PLAYER_H, 3,13,2,C_EYE
        dta $FF

spike_left_pixels
        dta 0,0,2,C_EYE, 2,0,2,C_PLAYER_H, 4,0,1,C_EYE
        dta 0,1,1,C_EYE, 1,1,1,C_PLAYER_H, 2,1,3,C_EYE
        dta 0,2,1,C_EYE, 1,2,1,C_PLAYER_H, 2,2,3,C_EYE
        dta 0,3,2,C_EYE, 2,3,2,C_PLAYER_H, 4,3,1,C_EYE
        dta 0,4,5,C_EYE
        dta 0,5,2,C_EYE, 2,5,2,C_PLAYER_H, 4,5,1,C_EYE
        dta 0,6,1,C_EYE, 1,6,1,C_PLAYER_H, 2,6,3,C_EYE
        dta 0,7,1,C_EYE, 1,7,1,C_PLAYER_H, 2,7,3,C_EYE
        dta 0,8,2,C_EYE, 2,8,2,C_PLAYER_H, 4,8,1,C_EYE
        dta 0,9,5,C_EYE
        dta 0,10,2,C_EYE, 2,10,2,C_PLAYER_H, 4,10,1,C_EYE
        dta 0,11,1,C_EYE, 1,11,1,C_PLAYER_H, 2,11,3,C_EYE
        dta 0,12,1,C_EYE, 1,12,1,C_PLAYER_H, 2,12,3,C_EYE
        dta 0,13,2,C_EYE, 2,13,2,C_PLAYER_H, 4,13,1,C_EYE
        dta $FF

nest_pixels
        dta 1,4,16,C_EYE
        dta 0,5,2,C_EYE, 2,5,1,C_WALL, 3,5,1,C_EYE
        dta 4,5,1,C_WALL, 5,5,1,C_EYE, 6,5,1,C_WALL, 7,5,1,C_EYE
        dta 8,5,2,C_WALL, 10,5,1,C_EYE, 11,5,1,C_WALL
        dta 12,5,1,C_EYE, 13,5,1,C_WALL, 14,5,1,C_EYE
        dta 15,5,1,C_WALL, 16,5,2,C_EYE
        dta 0,6,1,C_EYE, 1,6,1,C_WALL, 2,6,1,C_EYE, 3,6,1,C_WALL
        dta 4,6,1,C_EYE, 5,6,1,C_WALL, 6,6,1,C_EYE, 7,6,1,C_WALL
        dta 8,6,2,C_EYE, 10,6,1,C_WALL, 11,6,1,C_EYE
        dta 12,6,1,C_WALL, 13,6,1,C_EYE, 14,6,1,C_WALL
        dta 15,6,1,C_EYE, 16,6,1,C_WALL, 17,6,1,C_EYE
        dta 0,7,2,C_EYE, 2,7,1,C_WALL, 3,7,1,C_EYE
        dta 4,7,1,C_WALL, 5,7,1,C_EYE, 6,7,1,C_WALL, 7,7,1,C_EYE
        dta 8,7,2,C_WALL, 10,7,1,C_EYE, 11,7,1,C_WALL
        dta 12,7,1,C_EYE, 13,7,1,C_WALL, 14,7,1,C_EYE
        dta 15,7,1,C_WALL, 16,7,2,C_EYE
        dta 1,8,2,C_EYE, 3,8,1,C_WALL, 4,8,1,C_EYE
        dta 5,8,1,C_WALL, 6,8,1,C_EYE, 7,8,1,C_WALL
        dta 8,8,2,C_EYE, 10,8,1,C_WALL, 11,8,1,C_EYE
        dta 12,8,1,C_WALL, 13,8,1,C_EYE, 14,8,1,C_WALL
        dta 15,8,1,C_EYE, 16,8,1,C_EYE
        dta 2,9,2,C_EYE, 4,9,1,C_WALL, 5,9,1,C_EYE
        dta 6,9,1,C_WALL, 7,9,1,C_EYE, 8,9,2,C_WALL
        dta 10,9,1,C_EYE, 11,9,1,C_WALL, 12,9,1,C_EYE
        dta 13,9,1,C_WALL, 14,9,2,C_EYE
        dta $FF

;==============================================================================
; VBXE initialization and blitter
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
        dta a(upload_fly_sprite.vbreg_fly_bank+2)
        dta a(upload_fly_sprite.vbreg_fly_restore+2)
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

; Upload the exact 10x10 sFlySpike image once. Keeping it as a packed bitmap
; in its own VRAM page allows every moving enemy to be drawn with one blit.
.proc upload_fly_sprite
        lda #BANK_EN+FLY_SPRITE_MEM_BANK
vbreg_fly_bank
        sta VBXE_BANK_SEL
        ldx #0
?copy  lda fly_sprite_raw,x
        sta MEMW,x
        inx
        cpx #FLY_W*FLY_H
        bcc ?copy
        lda #BANK_EN+BANK_XDL
vbreg_fly_restore
        sta VBXE_BANK_SEL
        rts
.endp

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
        dta 0,   0,  0,  0
        dta 1,   7,  3, 17
        dta 2,  14,  7, 27
        dta 3,   5, 31, 57
        dta 4,   7,111,145
        dta 5, 226,243,228
        dta 6,  70,135,143
        dta 7,  14,  7, 27
        dta 8, 148,227, 68
        dta 9, 239,255,158
        dta 10,148,227, 68
        dta 11,245, 79,119
        dta 12,  38,177,218
        dta 13,150,236,255
        dta 14, 70,135,143
        dta 15,255,255,255
        dta 16,  3,  1, 10
        dta $FF

; Generic blitter control block.
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

fr_w dta a(0)
fr_h dta 0
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
; Game state and embedded maps
;==============================================================================
level_number  dta 0
game_complete dta 0
keys_left     dta 0
player_x      dta 0
player_y      dta 0
spawn_x       dta 0
spawn_y       dta 0
vy            dta 0
y_fraction    dta 0
gravity_dir   dta 1
gravity_phase dta 0             ; dithers gravity between 1/2 and 3/4 px
line_latch    dta 0
line_speed    dta 0             ; remembered gravity-line amplitude
offscreen_side dta 0            ; 0=in room, 1=below, $FF=above
message_timer dta 0
facing        dta 1
player_anim_tick  dta 0
player_anim_frame dta 0
player_anim_mode  dta 0
player_anim_moving dta 0

input_x       dta 0
jump_pressed  dta 0
old_fire      dta 0
fire_now      dta 0
old_stick     dta 15
stick_now     dta 15
old_console   dta 7
console_now   dta 7
key_temp      dta 0

move_delta dta 0
move_steps dta 0
move_sum   dta 0
test_x     dta 0
test_y     dta 0
pixel_x    dta 0
pixel_y    dta 0
tile_col   dta 0
tile_row   dta 0
tile_index dta a(0)
current_tile dta 0
math_temp  dta 0
math_temp2 dta 0
fly_count dta 0
fly_index dta 0
fly_x dta 0,0
fly_y dta 0,0
fly_start_x dta 0,0
fly_start_y dta 0,0
fly_end_x dta 0,0
fly_end_y dta 0,0
fly_direction dta 0,0
fly_pause dta 0,0
fly_target_x dta 0
fly_target_y dta 0
scan_x     dta 0
scan_y     dta 0
draw_col   dta 0
draw_row   dta 0
draw_type  dta 0
tile_x     dta a(0)
tile_y     dta 0
bird_run_x   dta 0
bird_run_y   dta 0
bird_run_w   dta 0
bird_run_col dta 0
visual_x   dta 0
visual_y   dta 0
sprite_base_x dta a(0)
sprite_base_y dta 0
run_sprite_w  dta 0
run_sprite_h  dta 0
run_flip_x    dta 0
run_flip_y    dta 0
front_bank dta 0
back_bank  dta 1
render_bank dta 0

; BEGIN SULKA EDITOR LEVEL DATA
; Generated by the Sulka VBXE Map Editor. Replace the marked block in
; atari/sulka-vbxe.asm, then assemble normally with MADS.
levels_lo
 dta <level1,<level2,<level3,<level4,<level5,<level6,<level7,<level8
 dta <level9,<level10,<level11,<level12,<level13,<level14,<level15,<level16
 dta <level17,<level18,<level19,<level20,<level21,<level22,<level23,<level24
levels_hi
 dta >level1,>level2,>level3,>level4,>level5,>level6,>level7,>level8
 dta >level9,>level10,>level11,>level12,>level13,>level14,>level15,>level16
 dta >level17,>level18,>level19,>level20,>level21,>level22,>level23,>level24

fly_config_lo
 dta <fly_level1,<fly_level2,<fly_level3,<fly_level4,<fly_level5,<fly_level6,<fly_level7,<fly_level8
 dta <fly_level9,<fly_level10,<fly_level11,<fly_level12,<fly_level13,<fly_level14,<fly_level15,<fly_level16
 dta <fly_level17,<fly_level18,<fly_level19,<fly_level20,<fly_level21,<fly_level22,<fly_level23,<fly_level24
fly_config_hi
 dta >fly_level1,>fly_level2,>fly_level3,>fly_level4,>fly_level5,>fly_level6,>fly_level7,>fly_level8
 dta >fly_level9,>fly_level10,>fly_level11,>fly_level12,>fly_level13,>fly_level14,>fly_level15,>fly_level16
 dta >fly_level17,>fly_level18,>fly_level19,>fly_level20,>fly_level21,>fly_level22,>fly_level23,>fly_level24

; count, then start-x/start-y/end-x/end-y in local board pixels.
fly_level1 dta 0
fly_level2 dta 0
fly_level3 dta 0
fly_level4 dta 1,110,30,110,90
fly_level5 dta 2,70,40,150,40,110,120,110,40
fly_level6 dta 0
fly_level7 dta 0
fly_level8 dta 1,110,50,170,50
fly_level9 dta 0
fly_level10 dta 0
fly_level11 dta 2,50,40,130,40,50,90,180,90
fly_level12 dta 1,50,50,176,50
fly_level13 dta 0
fly_level14 dta 0
fly_level15 dta 0
fly_level16 dta 0
fly_level17 dta 0
fly_level18 dta 1,50,110,170,110
fly_level19 dta 0
fly_level20 dta 0
fly_level21 dta 0
fly_level22 dta 0
fly_level23 dta 1,50,50,170,50
fly_level24 dta 0

; 24 x 14 VBXE tile maps. One cell is one 10 x 10 VBXE tile.

level1
 ; rTuto1
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'.................D......'
 dta c'...............####.....'
 dta c'...............####.....'
 dta c'......P....##...........'
 dta c'...........##...........'
 dta c'.....####...............'
 dta c'.....####...............'
 dta c'........................'
 dta c'........................'

level2
 ; rTuto2
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'............^^..........'
 dta c'....P...##..##..........'
 dta c'........##..##..........'
 dta c'....##............D.....'
 dta c'....##............##....'
 dta c'..................##....'
 dta c'..........##..##........'
 dta c'..........##..##........'
 dta c'........................'
 dta c'........................'

level3
 ; rTuto3
 dta c'........................'
 dta c'........................'
 dta c'...........ss...........'
 dta c'...........####.........'
 dta c'.....D.....####.........'
 dta c'.....####........##.....'
 dta c'.....####........##.....'
 dta c'...............##.......'
 dta c'.............^^##.......'
 dta c'.....P.....####.........'
 dta c'.........^^####.........'
 dta c'.....######.............'
 dta c'.....######.............'
 dta c'........................'

level4
 ; rTuto4
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'.....P.....F............'
 dta c'.......^^......^^.......'
 dta c'.....######..####.......'
 dta c'.....######..####.......'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'.......D.......^^.......'
 dta c'.......####..######.....'
 dta c'.......####..######.....'
 dta c'........................'

level5
 ; rTuto5
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'.......F................'
 dta c'........................'
 dta c'.....P..................'
 dta c'.......^^......^^D......'
 dta c'.....######..######.....'
 dta c'.....######..######.....'
 dta c'........................'
 dta c'........................'
 dta c'...........F............'
 dta c'........................'

level6
 ; rViiva0
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'.....P..................'
 dta c'........................'
 dta c'.........^^......##.....'
 dta c'.....##..##.............'
 dta c'........................'
 dta c'.......##...............'
 dta c'........................'
 dta c'........................'
 dta c'........................'

level7
 ; rViiva1
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'......P.................'
 dta c'........................'
 dta c'....######..##....##....'
 dta c'....######..##....##....'
 dta c'......d.......====......'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'

level8
 ; rViiva2
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'...P.......F............'
 dta c'.......^^..........^^...'
 dta c'...##..##..##..##..##...'
 dta c'...##==##==##==##==##...'
 dta c'...vv......vv..vv..d....'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'

level9
 ; rViiva3
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'....D...................'
 dta c'....##...##...##........'
 dta c'....##...##...##........'
 dta c'....##......P.....##....'
 dta c'....##............##....'
 dta c'....##......########....'
 dta c'....##======########....'
 dta c'....vv......vvvvvvvv....'
 dta c'........................'
 dta c'........................'

level10
 ; rViiva4
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'.....D..................'
 dta c'.....##...P......##.....'
 dta c'.....##..........##.....'
 dta c'.....##.................'
 dta c'.....##........####.....'
 dta c'.....####......####.....'
 dta c'.....####======####.....'
 dta c'.....##.................'
 dta c'.....##.................'
 dta c'........................'

level11
 ; rViiva5
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'.....F.........##.......'
 dta c'...............##.......'
 dta c'...P....................'
 dta c'........................'
 dta c'...##==============##...'
 dta c'...##F.............##...'
 dta c'...##...............##..'
 dta c'...##...................'
 dta c'...d....................'
 dta c'........................'

level12
 ; rViiva6
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'.....F..............D...'
 dta c'...P...............##...'
 dta c'.......^^..^^......##...'
 dta c'...##..##..##..##..##...'
 dta c'...##==##==##==##==##...'
 dta c'...##......vv..vv.......'
 dta c'...##...................'
 dta c'........................'
 dta c'........................'

level13
 ; rKey0 -- Original halfway interstitial; the VBXE game skips this slot.
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'

level14
 ; rKey1
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'.................K......'
 dta c'.....P.....D............'
 dta c'.....##....##....##.....'
 dta c'.....##====##....##.....'
 dta c'.................K......'
 dta c'........................'
 dta c'........................'
 dta c'........................'

level15
 ; rKey2
 dta c'........................'
 dta c'............^^..........'
 dta c'............##..........'
 dta c'.....P......##K.........'
 dta c'............vv..........'
 dta c'.....##>.........##.....'
 dta c'.....##>.........##.....'
 dta c'.....##..........##.....'
 dta c'.....##..........##.....'
 dta c'.....##==========##.....'
 dta c'.....##...^^.....##.....'
 dta c'.....d....##....K.......'
 dta c'..........##............'
 dta c'..........vv............'

level16
 ; rKey3
 dta c'........................'
 dta c'........................'
 dta c'............^^..^^......'
 dta c'............##..##......'
 dta c'.......D..K.##..##......'
 dta c'......##P...vv..##......'
 dta c'......##........##......'
 dta c'......####......##......'
 dta c'......####......##......'
 dta c'......vvvv======vv......'
 dta c'........................'
 dta c'.........K......K.......'
 dta c'........................'
 dta c'........................'

level17
 ; rKey4
 dta c'........................'
 dta c'.......K................'
 dta c'........................'
 dta c'............K...K.......'
 dta c'..............##........'
 dta c'..............##........'
 dta c'....P.........##........'
 dta c'....####==##..##........'
 dta c'....####..##..##..##....'
 dta c'....####..##==##==##....'
 dta c'....####..vv..##..vv....'
 dta c'....##........##........'
 dta c'....##........d.........'
 dta c'........................'

level18
 ; rKey5
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'...P...............K....'
 dta c'........................'
 dta c'...##..............##...'
 dta c'...##..^^..^^..^^..##...'
 dta c'...##..##..##..##..##...'
 dta c'...##..##..##..##..##...'
 dta c'...##==vv==vv==vv==##...'
 dta c'...##..............##...'
 dta c'....dF.............vv...'
 dta c'........................'
 dta c'........................'

level19
 ; rGrav1
 dta c'........K....D..........'
 dta c'.......##....##.........'
 dta c'.......##....##.........'
 dta c'.........====...........'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'..........P.............'
 dta c'.........##...##........'
 dta c'.........##===##K.......'
 dta c'........................'
 dta c'........................'
 dta c'........................'

level20
 ; rGrav2
 dta c'........................'
 dta c'.....K..................'
 dta c'........................'
 dta c'.....##..##..##..##.....'
 dta c'.....##..##..##==##.....'
 dta c'.....d...vv......vv.....'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'.............P..........'
 dta c'.....##..##..##..##.....'
 dta c'.....##..##..##..##.....'
 dta c'.....K.........==.......'
 dta c'........................'

level21
 ; rGrav3
 dta c'........................'
 dta c'............K...........'
 dta c'..................D.....'
 dta c'...P...............##...'
 dta c'...................##...'
 dta c'...##....##.............'
 dta c'...##....##.............'
 dta c'...vv====##.............'
 dta c'.........##....^^.......'
 dta c'.........##....##.......'
 dta c'.........##....##.......'
 dta c'.........vv====vv.......'
 dta c'......K.................'
 dta c'........................'

level22
 ; rGrav4
 dta c'........................'
 dta c'.........^^..^^.........'
 dta c'.........##..##.........'
 dta c'.........##..##.........'
 dta c'.........vv==vv.........'
 dta c'.....P..................'
 dta c'.........^^..^^...D.....'
 dta c'.....##..##..##..##.....'
 dta c'.....##..##..##..##.....'
 dta c'.....vv==......==vv.....'
 dta c'........................'
 dta c'........................'
 dta c'.......K...K...K........'
 dta c'........................'

level23
 ; rGrav5
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'...........K............'
 dta c'.....F..................'
 dta c'...P....................'
 dta c'.......^^......^^...D...'
 dta c'...##..##..##..##..##...'
 dta c'...##..##..##..##..##...'
 dta c'...##==..==vv==vv==.....'
 dta c'...##...................'
 dta c'........................'
 dta c'...........K............'

level24
 ; rEnding
 dta c'........................'
 dta c'........N...............'
 dta c'........##.##...........'
 dta c'........##......##......'
 dta c'........vv....==##......'
 dta c'........................'
 dta c'..P.....................'
 dta c'........................'
 dta c'....====##..............'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'........................'
 dta c'..##....................'

; END SULKA EDITOR LEVEL DATA

level_map :MAP_SIZE dta 0

; Keep the ANTIC underlay solid. The VBXE overlay is 320x200, while ANTIC can
; remain visible in the surrounding overscan; text rows there leak fragments
; of the status display around the game image on real hardware and Altirra.
display_list
        :25 dta $70
        dta $41,a(display_list)

        org $7000
text_screen
        :1000 dta 0

        run main
