;==============================================================================
; GRAPPLE - VBXE SCROLLING MAP PROTOTYPE
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
VIEW_W    = 160
VIEW_H    = 100
MAP_COLS  = 12
MAP_ROWS  = 240
MAP_H     = MAP_ROWS*16-16
CAMERA_MAX = MAP_H-VIEW_H
BANK_XDL  = $7F
BCB_OFF   = $100
XDL_B_OFF = $20
; Bank 2 produced blank blits for its first 4K on FX 1.26/Altirra. Bank 4 is
; outside the two screen buffers and background cache and renders all frames.
ASSET_VBANK = 4
ASSET_MEM_BANK = ASSET_VBANK*16
ASSET_PAGES = 122

DIR_UP    = 0
DIR_RIGHT = 1
DIR_DOWN  = 2
DIR_LEFT  = 3

GRAPPLE_NONE  = 0
GRAPPLE_SHOOT = 1
GRAPPLE_PULL  = 2

MOVER_X_FRAC = 0
MOVER_X      = 1
MOVER_Y_FRAC = 2
MOVER_Y_LO   = 3
MOVER_Y_HI   = 4
MOVER_DIR    = 5
MOVER_SPEED_LO = 6
MOVER_SPEED_HI = 7

; 8.8 per-frame physics at 50 Hz. Player gravity is deliberately doubled from
; the browser's 800 px/s^2 for a sharper VBXE version; terminal speed stays at
; 400 px/s so long falls remain controllable.
GRAVITY_STEP = 164             ; round(1600 / 50 / 50 * 256)
PULL_STEP    = 1792            ; faster Atari traversal: 350 / 50 * 256
MAX_FALL     = 2048            ; 400 / 50 * 256
HOOK_STEP    = 24              ; faster hook: 1200 / 50
MOVER_COUNT  = 6
MOVER_SIZE   = 8
SPIKE_COUNT  = 41
SPIKE_SIZE   = 4
LAVA_SIZE    = 3
CANNON_COUNT = 3
CANNON_SIZE  = 9
CANNON_ROT   = 3
CANNON_TIMER = 4
CANNON_VX_LO = 5
CANNON_VX_HI = 6
CANNON_VY_LO = 7
CANNON_VY_HI = 8
BALL_COUNT   = 8
BALL_SIZE    = 10
BALL_GRAVITY = 41              ; 400 px/s^2 at 50 Hz in 8.8
BALL_DRAG    = 20              ; 200 px/s^2 at 50 Hz in 8.8
BALL_ACTIVE  = 0
BALL_X_FRAC  = 1
BALL_X       = 2
BALL_Y_FRAC  = 3
BALL_Y_LO    = 4
BALL_Y_HI    = 5
BALL_VX_LO   = 6
BALL_VX_HI   = 7
BALL_VY_LO   = 8
BALL_VY_HI   = 9

THW_X_FRAC = 0
THW_X      = 1
THW_Y_FRAC = 2
THW_Y_LO   = 3
THW_Y_HI   = 4
THW_STATE  = 5
THW_TIMER  = 6
THW_DIR    = 7
THW_SPEED_LO = 8
THW_SPEED_HI = 9
THWOMP_COUNT = 9
THWOMP_SIZE = 10
THW_AWAKE  = 0
THW_ACTIVE = 1
THW_SLEEP  = 2
THW_SLEEP_FRAMES = 35          ; original 0.7 seconds at PAL 50 Hz
THW_ACCEL = 256                ; aggressive 2500 px/s^2 acceleration
THW_START_SPEED_HI = 3         ; attack begins immediately at 150 px/s
THW_MAX_SPEED_HI = 10          ; 500 px/s / 50 = 10 px/frame
CHECKPOINT_COUNT = 11
CHECKPOINT_SIZE = 4

        icl 'level-constants.asm'

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
C_MOVER_DARK = 22
C_LAVA       = 23

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
        jsr update_movers
        jsr update_thwomps
        jsr update_cannons
        jsr update_cannonballs
        jsr update_player
        jsr check_player_checkpoints
        jsr check_player_movers
        jsr check_player_thwomps
        jsr check_player_hazards
        jsr check_player_cannonballs
        jsr update_camera
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
        lda player_y+2
        sbc #0
        sta hook_y+1
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
        sta player_y+2
        sta vel_x
        sta vel_x+1
        sta vel_y
        sta vel_y+1
        sta grapple_state
        sta frame_counter
        sta facing_left
        lda respawn_x
        sta player_x+1
        lda respawn_y
        sta player_y+1
        lda respawn_y+1
        sta player_y+2
        jsr reset_movers
        jsr reset_thwomps
        jsr reset_cannons
        jsr update_camera
        rts
.endp

;==============================================================================
; Player physics
;==============================================================================
player_x      dta a(0)         ; 8.8 logical pixels, sprite centre X
player_y      dta 0,0,0        ; 16.8 world pixels, sprite bottom Y
vel_x         dta a(0)
vel_y         dta a(0)
hook_x        dta 0
hook_y        dta a(0)
grapple_state dta 0
grapple_dir   dta 0
facing_left   dta 0
frame_counter dta 0
hero_frame    dta 0
animation_phase dta 0
camera_y      dta a(0)

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
        lda player_x
        sta old_player_x
        lda player_x+1
        sta old_player_x+1
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
        lda old_player_x
        sta player_x
        lda old_player_x+1
        sta player_x+1
        lda #0
        sta vel_x
        sta vel_x+1
?done   rts
.endp

.proc move_player_y
        lda player_y
        sta old_player_y
        lda player_y+1
        sta old_player_y+1
        lda player_y+2
        sta old_player_y+2
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
        ldx vel_y+1
        bmi ?negative
        lda player_y+2
        adc #0
        sta player_y+2
        jmp ?collision
?negative
        lda player_y+2
        adc #$FF
        sta player_y+2
?collision
        jsr collide_player
        bcc ?done
        lda old_player_y
        sta player_y
        lda old_player_y+1
        sta player_y+1
        lda old_player_y+2
        sta player_y+2
        lda #0
        sta vel_y
        sta vel_y+1
?done   rts
.endp

old_player_x dta a(0)
old_player_y dta 0,0,0

; Player body is RectBounds(-4,-12,8,12), with right/bottom exclusive. The
; four corners are sufficient because the body is smaller than one 16x16 tile.
bbox_l dta 0
bbox_t dta 0
bbox_t_hi dta 0
bbox_r dta 0
bbox_b dta 0
bbox_b_hi dta 0
point_x dta 0
point_y dta a(0)
tile_row dta 0
tile_col dta 0
map_index dta a(0)
map_four dta a(0)
map_y_temp dta a(0)

.proc collide_player
        lda player_x+1
        sec
        sbc #4
        sta bbox_l
        lda player_x+1
        clc
        adc #3
        sta bbox_r
        lda player_y+1
        sec
        sbc #12
        sta bbox_t
        lda player_y+2
        sbc #0
        sta bbox_t_hi
        lda player_y+1
        sec
        sbc #1
        sta bbox_b
        lda player_y+2
        sbc #0
        sta bbox_b_hi

        lda bbox_l
        sta point_x
        lda bbox_t
        sta point_y
        lda bbox_t_hi
        sta point_y+1
        jsr point_is_solid
        bcs ?hit
        lda bbox_r
        sta point_x
        jsr point_is_solid
        bcs ?hit
        lda bbox_b
        sta point_y
        lda bbox_b_hi
        sta point_y+1
        jsr point_is_solid
        bcs ?hit
        lda bbox_l
        sta point_x
        jsr point_is_solid
        bcs ?hit
        clc
        rts
?hit    sec
        rts
.endp

; Read the original map at a world-space point. The browser tilemap is offset
; by (-16,-16), so adding 16 converts world pixels to map cells.
.proc point_is_solid
        lda point_x
        cmp #VIEW_W
        bcs ?solid
        lda point_y+1
        cmp #$0F
        bcs ?solid

        clc
        lda point_y
        adc #16
        sta map_y_temp
        lda point_y+1
        adc #0
        sta map_y_temp+1

        lda map_y_temp+1
        asl
        asl
        asl
        asl
        sta tile_row
        lda map_y_temp
        lsr
        lsr
        lsr
        lsr
        ora tile_row
        sta tile_row
        cmp #MAP_ROWS
        bcs ?solid

        lda point_x
        clc
        adc #16
        lsr
        lsr
        lsr
        lsr
        sta tile_col
        jsr load_map_tile
        cmp #1
        bcc ?empty
        cmp #11
        bcc ?solid
?empty  clc
        rts
?solid  sec
        rts
.endp

; Return the byte at tile_row*12+tile_col in A.
.proc load_map_tile
        lda tile_row
        sta map_index
        lda #0
        sta map_index+1
        asl map_index
        rol map_index+1
        asl map_index
        rol map_index+1       ; row*4
        lda map_index
        sta map_four
        lda map_index+1
        sta map_four+1
        asl map_index
        rol map_index+1       ; row*8
        clc
        lda map_index
        adc map_four
        sta map_index
        lda map_index+1
        adc map_four+1
        sta map_index+1       ; row*12

        clc
        lda #<world_map
        adc map_index
        sta data_ptr
        lda #>world_map
        adc map_index+1
        sta data_ptr+1
        ldy tile_col
        lda (data_ptr),y
        rts
.endp

; Move the hook one logical pixel at a time so its Atari-tuned speed cannot
; tunnel through the map's narrow ledges or a lava boundary.
.proc advance_hook
        ldy #HOOK_STEP
?step   lda grapple_dir
        cmp #DIR_UP
        bne ?right
        lda hook_y
        bne ?up_low
        dec hook_y+1
?up_low dec hook_y
        jmp ?test
?right  cmp #DIR_RIGHT
        bne ?down
        inc hook_x
        jmp ?test
?down   cmp #DIR_DOWN
        bne ?left
        inc hook_y
        bne ?test
        inc hook_y+1
        jmp ?test
?left   dec hook_x
?test   jsr point_in_wall
        bcs ?hit
        jsr point_in_lava
        bcs ?lava
        dey
        bne ?step
        rts
?hit    lda #GRAPPLE_PULL
        sta grapple_state
        rts
?lava   lda #GRAPPLE_NONE
        sta grapple_state
        rts
.endp

.proc point_in_wall
        lda hook_x
        sta point_x
        lda hook_y
        sta point_y
        lda hook_y+1
        sta point_y+1
        jmp point_is_solid
.endp

; Lava has the original game's no_grapple tag. Cancel the shot as soon as its
; point enters any lava tile instead of allowing it to anchor to a wall
; hidden on the other side.
.proc point_in_lava
        ldx #0
?lava  lda point_x
        cmp lava_initial,x
        bcc ?next
        lda lava_initial,x
        clc
        adc #16
        sta bbox_r               ; exclusive right edge
        lda point_x
        cmp bbox_r
        bcs ?next

        lda point_y+1
        cmp lava_initial+2,x
        bcc ?next
        bne ?bottom
        lda point_y
        cmp lava_initial+1,x
        bcc ?next

?bottom
        clc
        lda lava_initial+1,x
        adc #16
        sta hazard_bottom        ; exclusive bottom edge
        lda lava_initial+2,x
        adc #0
        sta hazard_bottom+1
        lda point_y+1
        cmp hazard_bottom+1
        bcc ?hit
        bne ?next
        lda point_y
        cmp hazard_bottom
        bcc ?hit

?next  txa
        clc
        adc #LAVA_SIZE
        tax
        cpx #LAVA_COUNT*LAVA_SIZE
        bcc ?lava
        clc
        rts
?hit   sec
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
        ; Match the browser's 12 fps idle cadence. animation_phase advances
        ; at 12.5 fps on PAL, the same timing used by the movement states.
        lda animation_phase
        and #3
        sta hero_frame          ; original idle frames 0..3
        rts
.endp

; Keep the hero near the middle of the 160x100 logical viewport. The direct
; pixel camera is intentionally simple for this milestone, but scrolls smoothly
; because it follows the player's integer world position rather than tile rows.
.proc update_camera
        sec
        lda player_y+1
        sbc #VIEW_H/2
        sta camera_y
        lda player_y+2
        sbc #0
        sta camera_y+1
        bcc ?top

        cmp #>CAMERA_MAX
        bcc ?done
        bne ?bottom
        lda camera_y
        cmp #<CAMERA_MAX
        bcc ?done
        beq ?done
?bottom lda #<CAMERA_MAX
        sta camera_y
        lda #>CAMERA_MAX
        sta camera_y+1
?done   rts
?top    lda #0
        sta camera_y
        sta camera_y+1
        rts
.endp

;==============================================================================
; Original moving blocks (tile entity 13)
;==============================================================================
mover_state :MOVER_COUNT*MOVER_SIZE dta 0
mover_index dta 0
mover_old dta 0,0,0,0,0
mover_top dta a(0)
mover_bottom dta a(0)

.proc reset_movers
        ldx #0
        ldy #0
?copy   lda #0
        sta mover_state+MOVER_X_FRAC,y
        lda mover_initial,x
        sta mover_state+MOVER_X,y
        inx
        lda #0
        sta mover_state+MOVER_Y_FRAC,y
        lda mover_initial,x
        sta mover_state+MOVER_Y_LO,y
        inx
        lda mover_initial,x
        sta mover_state+MOVER_Y_HI,y
        inx
        lda mover_initial,x
        sta mover_state+MOVER_DIR,y
        inx
        lda mover_initial,x
        sta mover_state+MOVER_SPEED_LO,y
        inx
        lda mover_initial,x
        sta mover_state+MOVER_SPEED_HI,y
        inx
        tya
        clc
        adc #MOVER_SIZE
        tay
        cpx #MOVER_COUNT*6
        bcc ?copy
        rts
.endp

.proc update_movers
        ldx #0
?mover stx mover_index
        ; Keep distant entities parked at their authored map positions. This
        ; avoids 24 map probes per frame near the entrance and guarantees the
        ; blocks are present when their chamber first scrolls into view.
        sec
        lda mover_state+MOVER_Y_LO,x
        sbc camera_y
        sta map_y_temp
        lda mover_state+MOVER_Y_HI,x
        sbc camera_y+1
        beq ?below_camera
        bmi ?above_camera
        jmp ?next
?above_camera
        cmp #$FF
        bne ?skip_far
        lda map_y_temp
        cmp #224                ; -32 logical pixels
        bcs ?active
?skip_far
        jmp ?next
?below_camera
        lda map_y_temp
        cmp #132                ; viewport plus 32 logical pixels
        bcs ?skip_far

?active
        lda mover_state+MOVER_X_FRAC,x
        sta mover_old+0
        lda mover_state+MOVER_X,x
        sta mover_old+1
        lda mover_state+MOVER_Y_FRAC,x
        sta mover_old+2
        lda mover_state+MOVER_Y_LO,x
        sta mover_old+3
        lda mover_state+MOVER_Y_HI,x
        sta mover_old+4

        lda mover_state+MOVER_DIR,x
        cmp #DIR_UP
        beq ?up
        cmp #DIR_RIGHT
        beq ?right
        cmp #DIR_DOWN
        beq ?down

?left   sec
        lda mover_state+MOVER_X_FRAC,x
        sbc mover_state+MOVER_SPEED_LO,x
        sta mover_state+MOVER_X_FRAC,x
        lda mover_state+MOVER_X,x
        sbc mover_state+MOVER_SPEED_HI,x
        sta mover_state+MOVER_X,x
        jmp ?collision

?right  clc
        lda mover_state+MOVER_X_FRAC,x
        adc mover_state+MOVER_SPEED_LO,x
        sta mover_state+MOVER_X_FRAC,x
        lda mover_state+MOVER_X,x
        adc mover_state+MOVER_SPEED_HI,x
        sta mover_state+MOVER_X,x
        jmp ?collision

?up     sec
        lda mover_state+MOVER_Y_FRAC,x
        sbc mover_state+MOVER_SPEED_LO,x
        sta mover_state+MOVER_Y_FRAC,x
        lda mover_state+MOVER_Y_LO,x
        sbc mover_state+MOVER_SPEED_HI,x
        sta mover_state+MOVER_Y_LO,x
        lda mover_state+MOVER_Y_HI,x
        sbc #0
        sta mover_state+MOVER_Y_HI,x
        jmp ?collision

?down   clc
        lda mover_state+MOVER_Y_FRAC,x
        adc mover_state+MOVER_SPEED_LO,x
        sta mover_state+MOVER_Y_FRAC,x
        lda mover_state+MOVER_Y_LO,x
        adc mover_state+MOVER_SPEED_HI,x
        sta mover_state+MOVER_Y_LO,x
        lda mover_state+MOVER_Y_HI,x
        adc #0
        sta mover_state+MOVER_Y_HI,x

?collision
        jsr mover_collides_map
        bcc ?next
        ldx mover_index
        lda mover_old+0
        sta mover_state+MOVER_X_FRAC,x
        lda mover_old+1
        sta mover_state+MOVER_X,x
        lda mover_old+2
        sta mover_state+MOVER_Y_FRAC,x
        lda mover_old+3
        sta mover_state+MOVER_Y_LO,x
        lda mover_old+4
        sta mover_state+MOVER_Y_HI,x
        lda mover_state+MOVER_DIR,x
        eor #2                  ; reverse cardinal direction
        sta mover_state+MOVER_DIR,x

?next   ldx mover_index
        txa
        clc
        adc #MOVER_SIZE
        tax
        cpx #MOVER_COUNT*MOVER_SIZE
        bcs ?done
        jmp ?mover
?done
        rts
.endp

.proc mover_collides_map
        ldx mover_index
        lda mover_state+MOVER_X,x
        sec
        sbc #6
        sta bbox_l
        lda mover_state+MOVER_X,x
        clc
        adc #5
        sta bbox_r
        lda mover_state+MOVER_Y_LO,x
        sec
        sbc #6
        sta bbox_t
        lda mover_state+MOVER_Y_HI,x
        sbc #0
        sta bbox_t_hi
        lda mover_state+MOVER_Y_LO,x
        clc
        adc #5
        sta bbox_b
        lda mover_state+MOVER_Y_HI,x
        adc #0
        sta bbox_b_hi

        lda bbox_l
        sta point_x
        lda bbox_t
        sta point_y
        lda bbox_t_hi
        sta point_y+1
        jsr point_is_solid
        bcs ?hit
        lda bbox_r
        sta point_x
        jsr point_is_solid
        bcs ?hit
        lda bbox_b
        sta point_y
        lda bbox_b_hi
        sta point_y+1
        jsr point_is_solid
        bcs ?hit
        lda bbox_l
        sta point_x
        jsr point_is_solid
        bcs ?hit
        clc
        rts
?hit    sec
        rts
.endp

;==============================================================================
; Original line-of-sight thwomps (tile entity 17)
;==============================================================================
thwomp_state :THWOMP_COUNT*THWOMP_SIZE dta 0
thwomp_index dta 0
thwomp_other_index dta 0
thwomp_old dta 0,0,0,0,0

.proc reset_thwomps
        ldx #0
        ldy #0
?copy   lda #0
        sta thwomp_state+THW_X_FRAC,y
        sta thwomp_state+THW_Y_FRAC,y
        sta thwomp_state+THW_STATE,y
        sta thwomp_state+THW_TIMER,y
        sta thwomp_state+THW_DIR,y
        sta thwomp_state+THW_SPEED_LO,y
        sta thwomp_state+THW_SPEED_HI,y
        lda thwomp_initial,x
        sta thwomp_state+THW_X,y
        inx
        lda thwomp_initial,x
        sta thwomp_state+THW_Y_LO,y
        inx
        lda thwomp_initial,x
        sta thwomp_state+THW_Y_HI,y
        inx
        tya
        clc
        adc #THWOMP_SIZE
        tay
        cpx #THWOMP_COUNT*3
        bcc ?copy
        rts
.endp

.proc update_thwomps
        ldx #0
?thwomp
        stx thwomp_index
        ; Like movers, only simulate thwomps close to the current viewport.
        sec
        lda thwomp_state+THW_Y_LO,x
        sbc camera_y
        sta map_y_temp
        lda thwomp_state+THW_Y_HI,x
        sbc camera_y+1
        beq ?below_camera
        cmp #$FF
        beq ?above_camera
        jmp ?next
?above_camera
        lda map_y_temp
        cmp #224                ; -32 logical pixels
        bcs ?active_range
        jmp ?next
?below_camera
        lda map_y_temp
        cmp #132
        bcc ?active_range
        jmp ?next

?active_range
        ldx thwomp_index
        lda thwomp_state+THW_STATE,x
        cmp #THW_SLEEP
        beq ?sleep
        cmp #THW_ACTIVE
        beq ?move
        jsr thwomp_detect_player
        jmp ?next

?sleep lda thwomp_state+THW_TIMER,x
        beq ?wake
        dec thwomp_state+THW_TIMER,x
        beq ?wake
        jmp ?next
?wake  lda #THW_AWAKE
        sta thwomp_state+THW_STATE,x
        jmp ?next

?move  lda thwomp_state+THW_X_FRAC,x
        sta thwomp_old+0
        lda thwomp_state+THW_X,x
        sta thwomp_old+1
        lda thwomp_state+THW_Y_FRAC,x
        sta thwomp_old+2
        lda thwomp_state+THW_Y_LO,x
        sta thwomp_old+3
        lda thwomp_state+THW_Y_HI,x
        sta thwomp_old+4

        clc
        lda thwomp_state+THW_SPEED_LO,x
        adc #<THW_ACCEL
        sta thwomp_state+THW_SPEED_LO,x
        lda thwomp_state+THW_SPEED_HI,x
        adc #>THW_ACCEL
        sta thwomp_state+THW_SPEED_HI,x
        cmp #THW_MAX_SPEED_HI
        bcc ?direction
        lda #0
        sta thwomp_state+THW_SPEED_LO,x
        lda #THW_MAX_SPEED_HI
        sta thwomp_state+THW_SPEED_HI,x

?direction
        lda thwomp_state+THW_DIR,x
        cmp #DIR_UP
        beq ?up
        cmp #DIR_RIGHT
        beq ?right
        cmp #DIR_DOWN
        beq ?down

?left  sec
        lda thwomp_state+THW_X_FRAC,x
        sbc thwomp_state+THW_SPEED_LO,x
        sta thwomp_state+THW_X_FRAC,x
        lda thwomp_state+THW_X,x
        sbc thwomp_state+THW_SPEED_HI,x
        sta thwomp_state+THW_X,x
        jmp ?collision

?right clc
        lda thwomp_state+THW_X_FRAC,x
        adc thwomp_state+THW_SPEED_LO,x
        sta thwomp_state+THW_X_FRAC,x
        lda thwomp_state+THW_X,x
        adc thwomp_state+THW_SPEED_HI,x
        sta thwomp_state+THW_X,x
        jmp ?collision

?up    sec
        lda thwomp_state+THW_Y_FRAC,x
        sbc thwomp_state+THW_SPEED_LO,x
        sta thwomp_state+THW_Y_FRAC,x
        lda thwomp_state+THW_Y_LO,x
        sbc thwomp_state+THW_SPEED_HI,x
        sta thwomp_state+THW_Y_LO,x
        lda thwomp_state+THW_Y_HI,x
        sbc #0
        sta thwomp_state+THW_Y_HI,x
        jmp ?collision

?down  clc
        lda thwomp_state+THW_Y_FRAC,x
        adc thwomp_state+THW_SPEED_LO,x
        sta thwomp_state+THW_Y_FRAC,x
        lda thwomp_state+THW_Y_LO,x
        adc thwomp_state+THW_SPEED_HI,x
        sta thwomp_state+THW_Y_LO,x
        lda thwomp_state+THW_Y_HI,x
        adc #0
        sta thwomp_state+THW_Y_HI,x

?collision
        jsr thwomp_collides_map
        bcs ?impact
        jsr thwomp_collides_thwomps
        bcc ?next
?impact
        ldx thwomp_index
        lda thwomp_old+0
        sta thwomp_state+THW_X_FRAC,x
        lda thwomp_old+1
        sta thwomp_state+THW_X,x
        lda thwomp_old+2
        sta thwomp_state+THW_Y_FRAC,x
        lda thwomp_old+3
        sta thwomp_state+THW_Y_LO,x
        lda thwomp_old+4
        sta thwomp_state+THW_Y_HI,x
        lda #0
        sta thwomp_state+THW_SPEED_LO,x
        sta thwomp_state+THW_SPEED_HI,x
        lda #THW_SLEEP
        sta thwomp_state+THW_STATE,x
        lda #THW_SLEEP_FRAMES
        sta thwomp_state+THW_TIMER,x

?next  ldx thwomp_index
        txa
        clc
        adc #THWOMP_SIZE
        tax
        cpx #THWOMP_COUNT*THWOMP_SIZE
        bcs ?done
        jmp ?thwomp
?done  rts
.endp

; Build the original 16x16 thwomp bounds in the shared bbox variables.
.proc set_thwomp_bbox
        ldx thwomp_index
        lda thwomp_state+THW_X,x
        sec
        sbc #8
        sta bbox_l
        lda thwomp_state+THW_X,x
        clc
        adc #7
        sta bbox_r
        lda thwomp_state+THW_Y_LO,x
        sec
        sbc #8
        sta bbox_t
        lda thwomp_state+THW_Y_HI,x
        sbc #0
        sta bbox_t_hi
        lda thwomp_state+THW_Y_LO,x
        clc
        adc #7
        sta bbox_b
        lda thwomp_state+THW_Y_HI,x
        adc #0
        sta bbox_b_hi
        rts
.endp

.proc thwomp_collides_map
        jsr set_thwomp_bbox
        lda bbox_l
        sta point_x
        lda bbox_t
        sta point_y
        lda bbox_t_hi
        sta point_y+1
        jsr point_is_solid
        bcs ?hit
        lda bbox_r
        sta point_x
        jsr point_is_solid
        bcs ?hit
        lda bbox_b
        sta point_y
        lda bbox_b_hi
        sta point_y+1
        jsr point_is_solid
        bcs ?hit
        lda bbox_l
        sta point_x
        jsr point_is_solid
        bcs ?hit
        clc
        rts
?hit    sec
        rts
.endp

.proc thwomp_collides_thwomps
        jsr set_thwomp_bbox
        ldx #0
?other stx thwomp_other_index
        cpx thwomp_index
        beq ?next
        lda thwomp_state+THW_X,x
        sec
        sbc #8
        cmp bbox_r
        bcc ?right
        beq ?right
        jmp ?next
?right  lda thwomp_state+THW_X,x
        clc
        adc #7
        cmp bbox_l
        bcc ?next

        lda thwomp_state+THW_Y_LO,x
        sec
        sbc #8
        sta hazard_top
        lda thwomp_state+THW_Y_HI,x
        sbc #0
        sta hazard_top+1
        lda bbox_b_hi
        cmp hazard_top+1
        bcc ?next
        bne ?bottom
        lda bbox_b
        cmp hazard_top
        bcc ?next
?bottom
        lda thwomp_state+THW_Y_LO,x
        clc
        adc #7
        sta hazard_bottom
        lda thwomp_state+THW_Y_HI,x
        adc #0
        sta hazard_bottom+1
        lda hazard_bottom+1
        cmp bbox_t_hi
        bcc ?next
        bne ?hit
        lda hazard_bottom
        cmp bbox_t
        bcc ?next
?hit    sec
        rts

?next  ldx thwomp_other_index
        txa
        clc
        adc #THWOMP_SIZE
        tax
        cpx #THWOMP_COUNT*THWOMP_SIZE
        bcc ?other
        clc
        rts
.endp

; Match the browser raycast: arm only if the player is the first object seen
; horizontally or vertically. Walls and other thwomps block the ray.
.proc thwomp_detect_player
        lda player_x+1
        sec
        sbc #4
        sta bbox_l
        lda player_x+1
        clc
        adc #3
        sta bbox_r
        lda player_y+1
        sec
        sbc #12
        sta bbox_t
        lda player_y+2
        sbc #0
        sta bbox_t_hi
        lda player_y+1
        sec
        sbc #1
        sta bbox_b
        lda player_y+2
        sbc #0
        sta bbox_b_hi

        ldx thwomp_index
        ; Is the thwomp centre within the player's vertical body span?
        sec
        lda thwomp_state+THW_Y_LO,x
        sbc bbox_t
        sta map_y_temp
        lda thwomp_state+THW_Y_HI,x
        sbc bbox_t_hi
        bne ?vertical
        lda map_y_temp
        cmp #12
        bcs ?vertical
        lda thwomp_state+THW_X,x
        cmp bbox_l
        bcc ?player_right
        cmp bbox_r
        bcc ?done
        beq ?done
        lda #DIR_LEFT
        bne ?try
?player_right
        lda #DIR_RIGHT
        bne ?try

?vertical
        lda thwomp_state+THW_X,x
        cmp bbox_l
        bcc ?done
        sec
        sbc bbox_l
        cmp #8
        bcs ?done
        lda thwomp_state+THW_Y_HI,x
        cmp bbox_t_hi
        bcc ?player_down
        bne ?player_up
        lda thwomp_state+THW_Y_LO,x
        cmp bbox_t
        bcc ?player_down
?player_up
        lda #DIR_UP
        bne ?try
?player_down
        lda #DIR_DOWN

?try   ldx thwomp_index
        sta thwomp_state+THW_DIR,x
        jsr thwomp_ray_clear
        bcc ?done
        ldx thwomp_index
        lda #0
        sta thwomp_state+THW_SPEED_LO,x
        lda #THW_START_SPEED_HI
        sta thwomp_state+THW_SPEED_HI,x
        lda #THW_ACTIVE
        sta thwomp_state+THW_STATE,x
?done  rts
.endp

.proc thwomp_ray_clear
        ldx thwomp_index
        lda thwomp_state+THW_X,x
        sta point_x
        lda thwomp_state+THW_Y_LO,x
        sta point_y
        lda thwomp_state+THW_Y_HI,x
        sta point_y+1
?step  ldx thwomp_index
        lda thwomp_state+THW_DIR,x
        cmp #DIR_UP
        beq ?up
        cmp #DIR_RIGHT
        beq ?right
        cmp #DIR_DOWN
        beq ?down
?left  sec
        lda point_x
        sbc #8
        sta point_x
        cmp bbox_r
        bcc ?clear
        beq ?clear
        jmp ?probe
?right clc
        lda point_x
        adc #8
        sta point_x
        cmp bbox_l
        bcs ?clear
        jmp ?probe
?up    sec
        lda point_y
        sbc #8
        sta point_y
        lda point_y+1
        sbc #0
        sta point_y+1
        cmp bbox_b_hi
        bcc ?clear
        bne ?probe
        lda point_y
        cmp bbox_b
        bcc ?clear
        beq ?clear
        jmp ?probe
?down  clc
        lda point_y
        adc #8
        sta point_y
        lda point_y+1
        adc #0
        sta point_y+1
        cmp bbox_t_hi
        bcc ?probe
        bne ?clear
        lda point_y
        cmp bbox_t
        bcs ?clear

?probe jsr point_is_solid
        bcs ?blocked
        jsr point_in_other_thwomp
        bcs ?blocked
        jmp ?step
?clear sec
        rts
?blocked
        clc
        rts
.endp

.proc point_in_other_thwomp
        ldx #0
?other stx thwomp_other_index
        cpx thwomp_index
        beq ?next
        lda thwomp_state+THW_X,x
        sec
        sbc #8
        cmp point_x
        bcc ?x_right
        beq ?x_right
        jmp ?next
?x_right
        lda point_x
        sec
        sbc thwomp_state+THW_X,x
        clc
        adc #8
        cmp #16
        bcs ?next

        lda thwomp_state+THW_Y_LO,x
        sec
        sbc #8
        sta hazard_top
        lda thwomp_state+THW_Y_HI,x
        sbc #0
        sta hazard_top+1
        sec
        lda point_y
        sbc hazard_top
        sta map_y_temp
        lda point_y+1
        sbc hazard_top+1
        bne ?next
        lda map_y_temp
        cmp #16
        bcc ?hit

?next  ldx thwomp_other_index
        txa
        clc
        adc #THWOMP_SIZE
        tax
        cpx #THWOMP_COUNT*THWOMP_SIZE
        bcc ?other
        clc
        rts
?hit    sec
        rts
.endp

;==============================================================================
; Original cannons (tile entity 14) and cannonballs
;==============================================================================
cannon_timers :CANNON_COUNT dta 0
cannon_index dta 0
cannon_number dta 0
ball_index dta 0
ball_sign dta 0
cannonballs :BALL_COUNT*BALL_SIZE dta 0

.proc reset_cannons
        ldx #BALL_COUNT*BALL_SIZE-1
        lda #0
?clear  sta cannonballs,x
        dex
        bpl ?clear
        ldx #0
        ldy #0
?timer  lda cannon_initial+CANNON_TIMER,x
        sta cannon_timers,y
        txa
        clc
        adc #CANNON_SIZE
        tax
        iny
        cpy #CANNON_COUNT
        bcc ?timer
        rts
.endp

.proc update_cannons
        ldx #0
        ldy #0
?cannon
        stx cannon_index
        sty cannon_number
        sec
        lda cannon_initial+1,x
        sbc camera_y
        sta map_y_temp
        lda cannon_initial+2,x
        sbc camera_y+1
        beq ?below
        cmp #$FF
        bne ?next
        lda map_y_temp
        cmp #136                ; -120 logical pixels
        bcc ?next
        bcs ?active
?below lda map_y_temp
        cmp #120
        bcs ?next
?active
        ldy cannon_number
        lda cannon_timers,y
        beq ?shoot
        sec
        sbc #1
        sta cannon_timers,y
        bne ?next
?shoot jsr spawn_cannonball
        ldy cannon_number
        lda #50                 ; original one-second cadence at PAL 50 Hz
        sta cannon_timers,y

?next  ldx cannon_index
        txa
        clc
        adc #CANNON_SIZE
        tax
        ldy cannon_number
        iny
        cpy #CANNON_COUNT
        bcs ?done
        jmp ?cannon
?done   rts
.endp

.proc spawn_cannonball
        ldx #0
?find  lda cannonballs+BALL_ACTIVE,x
        beq ?slot
        txa
        clc
        adc #BALL_SIZE
        tax
        cpx #BALL_COUNT*BALL_SIZE
        bcc ?find
        rts

?slot  stx ball_index
        lda #1
        sta cannonballs+BALL_ACTIVE,x
        lda #0
        sta cannonballs+BALL_X_FRAC,x
        sta cannonballs+BALL_Y_FRAC,x
        ldx cannon_index
        lda cannon_initial+CANNON_ROT,x
        tay
        lda cannon_initial,x
        clc
        adc cannon_spawn_x,y
        ldx ball_index
        sta cannonballs+BALL_X,x

        ldx cannon_index
        lda cannon_initial+1,x
        clc
        adc cannon_spawn_y,y
        ldx ball_index
        sta cannonballs+BALL_Y_LO,x
        ldx cannon_index
        lda cannon_initial+2,x
        adc cannon_spawn_sign,y
        ldx ball_index
        sta cannonballs+BALL_Y_HI,x
        ldx cannon_index
        lda cannon_initial+CANNON_VX_LO,x
        ldx ball_index
        sta cannonballs+BALL_VX_LO,x
        ldx cannon_index
        lda cannon_initial+CANNON_VX_HI,x
        ldx ball_index
        sta cannonballs+BALL_VX_HI,x
        ldx cannon_index
        lda cannon_initial+CANNON_VY_LO,x
        ldx ball_index
        sta cannonballs+BALL_VY_LO,x
        ldx cannon_index
        lda cannon_initial+CANNON_VY_HI,x
        ldx ball_index
        sta cannonballs+BALL_VY_HI,x
        rts
.endp

cannon_spawn_x    dta $F9,7,7,$F9
cannon_spawn_y    dta $F9,$F9,7,7
cannon_spawn_sign dta $FF,$FF,0,0

.proc update_cannonballs
        ldx #0
?ball  stx ball_index
        lda cannonballs+BALL_ACTIVE,x
        bne ?active
        jmp ?next
?active
        lda cannonballs+BALL_VX_HI,x
        bmi ?drag_negative
        ora cannonballs+BALL_VX_LO,x
        beq ?gravity
        sec
        lda cannonballs+BALL_VX_LO,x
        sbc #BALL_DRAG
        sta cannonballs+BALL_VX_LO,x
        lda cannonballs+BALL_VX_HI,x
        sbc #0
        sta cannonballs+BALL_VX_HI,x
        bmi ?zero_x
        jmp ?gravity
?drag_negative
        clc
        lda cannonballs+BALL_VX_LO,x
        adc #BALL_DRAG
        sta cannonballs+BALL_VX_LO,x
        lda cannonballs+BALL_VX_HI,x
        adc #0
        sta cannonballs+BALL_VX_HI,x
        bmi ?gravity
?zero_x
        lda #0
        sta cannonballs+BALL_VX_LO,x
        sta cannonballs+BALL_VX_HI,x

?gravity
        clc
        lda cannonballs+BALL_VY_LO,x
        adc #BALL_GRAVITY
        sta cannonballs+BALL_VY_LO,x
        lda cannonballs+BALL_VY_HI,x
        adc #0
        sta cannonballs+BALL_VY_HI,x

        clc
        lda cannonballs+BALL_X_FRAC,x
        adc cannonballs+BALL_VX_LO,x
        sta cannonballs+BALL_X_FRAC,x
        lda cannonballs+BALL_X,x
        adc cannonballs+BALL_VX_HI,x
        sta cannonballs+BALL_X,x
        cmp #VIEW_W
        bcs ?kill

        lda cannonballs+BALL_VY_HI,x
        bmi ?negative_y
        lda #0
        beq ?sign_ready
?negative_y
        lda #$FF
?sign_ready
        sta ball_sign
        clc
        lda cannonballs+BALL_Y_FRAC,x
        adc cannonballs+BALL_VY_LO,x
        sta cannonballs+BALL_Y_FRAC,x
        lda cannonballs+BALL_Y_LO,x
        adc cannonballs+BALL_VY_HI,x
        sta cannonballs+BALL_Y_LO,x
        lda cannonballs+BALL_Y_HI,x
        adc ball_sign
        sta cannonballs+BALL_Y_HI,x
        bmi ?kill
        cmp #$0F
        bcs ?kill

        lda cannonballs+BALL_X,x
        sta point_x
        lda cannonballs+BALL_Y_LO,x
        sta point_y
        lda cannonballs+BALL_Y_HI,x
        sta point_y+1
        jsr point_is_solid
        bcc ?next
?kill  ldx ball_index
        lda #0
        sta cannonballs+BALL_ACTIVE,x

?next  ldx ball_index
        txa
        clc
        adc #BALL_SIZE
        tax
        cpx #BALL_COUNT*BALL_SIZE
        bcs ?done
        jmp ?ball
?done   rts
.endp

; Movers are tagged deadly in the browser game. Until checkpoints/death effects
; exist, touching one performs a silent reset to the original entrance.
.proc check_player_movers
        lda player_x+1
        sec
        sbc #4
        sta bbox_l
        lda player_x+1
        clc
        adc #3
        sta bbox_r
        lda player_y+1
        sec
        sbc #12
        sta bbox_t
        lda player_y+2
        sbc #0
        sta bbox_t_hi
        lda player_y+1
        sec
        sbc #1
        sta bbox_b
        lda player_y+2
        sbc #0
        sta bbox_b_hi

        ldx #0
?mover stx mover_index
        lda mover_state+MOVER_X,x
        sec
        sbc #6
        sta point_x             ; mover left
        lda bbox_r
        cmp point_x
        bcc ?next
        lda mover_state+MOVER_X,x
        clc
        adc #5                  ; mover right
        cmp bbox_l
        bcc ?next

        lda mover_state+MOVER_Y_LO,x
        sec
        sbc #6
        sta mover_top
        lda mover_state+MOVER_Y_HI,x
        sbc #0
        sta mover_top+1
        lda bbox_b_hi
        cmp mover_top+1
        bcc ?next
        bne ?test_bottom
        lda bbox_b
        cmp mover_top
        bcc ?next

?test_bottom
        lda mover_state+MOVER_Y_LO,x
        clc
        adc #5
        sta mover_bottom
        lda mover_state+MOVER_Y_HI,x
        adc #0
        sta mover_bottom+1
        lda bbox_t_hi
        cmp mover_bottom+1
        bcc ?hit
        bne ?next
        lda bbox_t
        cmp mover_bottom
        bcc ?hit
        beq ?hit

?next   ldx mover_index
        txa
        clc
        adc #MOVER_SIZE
        tax
        cpx #MOVER_COUNT*MOVER_SIZE
        bcc ?mover
        rts
?hit    jsr reset_player
        rts
.endp

; Thwomps keep their original full 16x16 deadly body in every state.
.proc check_player_thwomps
        lda player_x+1
        sec
        sbc #4
        sta bbox_l
        lda player_x+1
        clc
        adc #3
        sta bbox_r
        lda player_y+1
        sec
        sbc #12
        sta bbox_t
        lda player_y+2
        sbc #0
        sta bbox_t_hi
        lda player_y+1
        sec
        sbc #1
        sta bbox_b
        lda player_y+2
        sbc #0
        sta bbox_b_hi

        ldx #0
?thwomp
        stx thwomp_index
        lda thwomp_state+THW_X,x
        sec
        sbc #8
        cmp bbox_r
        bcc ?right
        beq ?right
        jmp ?next
?right  lda thwomp_state+THW_X,x
        clc
        adc #7
        cmp bbox_l
        bcc ?next

        lda thwomp_state+THW_Y_LO,x
        sec
        sbc #8
        sta hazard_top
        lda thwomp_state+THW_Y_HI,x
        sbc #0
        sta hazard_top+1
        lda bbox_b_hi
        cmp hazard_top+1
        bcc ?next
        bne ?bottom
        lda bbox_b
        cmp hazard_top
        bcc ?next
?bottom
        lda thwomp_state+THW_Y_LO,x
        clc
        adc #7
        sta hazard_bottom
        lda thwomp_state+THW_Y_HI,x
        adc #0
        sta hazard_bottom+1
        lda hazard_bottom+1
        cmp bbox_t_hi
        bcc ?next
        bne ?hit
        lda hazard_bottom
        cmp bbox_t
        bcs ?hit

?next  ldx thwomp_index
        txa
        clc
        adc #THWOMP_SIZE
        tax
        cpx #THWOMP_COUNT*THWOMP_SIZE
        bcc ?thwomp
        rts
?hit    jmp reset_player
.endp

checkpoint_current dta $FF     ; byte offset in checkpoint_initial, or none
checkpoint_index dta 0
checkpoint_left dta 0
checkpoint_right dta 0
checkpoint_top dta a(0)
checkpoint_bottom dta a(0)
respawn_x dta 56               ; original entrance: 3*16+8
respawn_y dta a(152)           ; original entrance: 9*16+8

; Touching a flag makes it the sole active checkpoint and updates the position
; used by reset_player. Checkpoint bounds match the original offset flag body.
.proc check_player_checkpoints
        lda player_x+1
        sec
        sbc #4
        sta bbox_l
        lda player_x+1
        clc
        adc #3
        sta bbox_r
        lda player_y+1
        sec
        sbc #12
        sta bbox_t
        lda player_y+2
        sbc #0
        sta bbox_t_hi
        lda player_y+1
        sec
        sbc #1
        sta bbox_b
        lda player_y+2
        sbc #0
        sta bbox_b_hi

        ldx #0
?checkpoint
        stx checkpoint_index
        cpx checkpoint_current
        bne ?test
        jmp ?next
?test
        lda checkpoint_initial+3,x
        and #1
        bne ?sideways

        lda checkpoint_initial,x
        sec
        sbc #8
        sta checkpoint_left
        lda checkpoint_initial,x
        clc
        adc #7
        sta checkpoint_right
        lda checkpoint_initial+1,x
        sec
        sbc #16
        sta checkpoint_top
        lda checkpoint_initial+2,x
        sbc #0
        sta checkpoint_top+1
        lda checkpoint_initial+1,x
        sec
        sbc #1
        sta checkpoint_bottom
        lda checkpoint_initial+2,x
        sbc #0
        sta checkpoint_bottom+1
        jmp ?overlap

?sideways
        lda checkpoint_initial,x
        sta checkpoint_left
        clc
        adc #15
        sta checkpoint_right
        lda checkpoint_initial+1,x
        sec
        sbc #8
        sta checkpoint_top
        lda checkpoint_initial+2,x
        sbc #0
        sta checkpoint_top+1
        lda checkpoint_initial+1,x
        clc
        adc #7
        sta checkpoint_bottom
        lda checkpoint_initial+2,x
        adc #0
        sta checkpoint_bottom+1

?overlap
        lda bbox_r
        cmp checkpoint_left
        bcc ?next
        lda checkpoint_right
        cmp bbox_l
        bcc ?next
        lda bbox_b_hi
        cmp checkpoint_top+1
        bcc ?next
        bne ?bottom
        lda bbox_b
        cmp checkpoint_top
        bcc ?next
?bottom
        lda checkpoint_bottom+1
        cmp bbox_t_hi
        bcc ?next
        bne ?activate
        lda checkpoint_bottom
        cmp bbox_t
        bcc ?next

?activate
        ldx checkpoint_index
        stx checkpoint_current
        lda checkpoint_initial,x
        sta respawn_x
        clc
        lda checkpoint_initial+1,x
        adc #7
        sta respawn_y
        lda checkpoint_initial+2,x
        adc #0
        sta respawn_y+1
        rts

?next  ldx checkpoint_index
        txa
        clc
        adc #CHECKPOINT_SIZE
        tax
        cpx #CHECKPOINT_COUNT*CHECKPOINT_SIZE
        bcs ?done
        jmp ?checkpoint
?done
        rts
.endp

hazard_index  dta 0
hazard_top    dta a(0)
hazard_bottom dta a(0)

; Spikes use their original 14x14 deadly bounds. Lava uses independent 16x16
; editor cells stored in the same top-to-bottom world coordinate system.
.proc check_player_hazards
        lda player_x+1
        sec
        sbc #4
        sta bbox_l
        lda player_x+1
        clc
        adc #3
        sta bbox_r
        lda player_y+1
        sec
        sbc #12
        sta bbox_t
        lda player_y+2
        sbc #0
        sta bbox_t_hi
        lda player_y+1
        sec
        sbc #1
        sta bbox_b
        lda player_y+2
        sbc #0
        sta bbox_b_hi

        ldx #0
?spike stx hazard_index
        lda spike_initial+1,x
        sec
        sbc #7
        sta hazard_top
        lda spike_initial+2,x
        sbc #0
        sta hazard_top+1
        lda bbox_b_hi
        cmp hazard_top+1
        bcc ?cannon_start       ; records are sorted from top to bottom
        bne ?spike_x
        lda bbox_b
        cmp hazard_top
        bcc ?cannon_start

?spike_x
        lda spike_initial,x
        sec
        sbc #7
        sta point_x
        lda bbox_r
        cmp point_x
        bcc ?spike_next
        lda spike_initial,x
        clc
        adc #6
        cmp bbox_l
        bcc ?spike_next
?spike_bottom
        lda spike_initial+1,x
        clc
        adc #6
        sta hazard_bottom
        lda spike_initial+2,x
        adc #0
        sta hazard_bottom+1
        lda hazard_bottom+1
        cmp bbox_t_hi
        bcc ?spike_next
        beq ?spike_bottom_low
        jmp ?hit
?spike_bottom_low
        lda hazard_bottom
        cmp bbox_t
        bcc ?spike_next
        jmp ?hit

?spike_next
        ldx hazard_index
        txa
        clc
        adc #SPIKE_SIZE
        tax
        cpx #SPIKE_COUNT*SPIKE_SIZE
        bcc ?spike

?cannon_start
        ldx #0
?cannon
        stx hazard_index
        lda cannon_initial,x
        sec
        sbc #7
        sta point_x
        lda bbox_r
        cmp point_x
        bcc ?cannon_next
        lda cannon_initial,x
        clc
        adc #6
        cmp bbox_l
        bcc ?cannon_next
        lda cannon_initial+1,x
        sec
        sbc #7
        sta hazard_top
        lda cannon_initial+2,x
        sbc #0
        sta hazard_top+1
        lda bbox_b_hi
        cmp hazard_top+1
        bcc ?cannon_next
        bne ?cannon_bottom
        lda bbox_b
        cmp hazard_top
        bcc ?cannon_next
?cannon_bottom
        lda cannon_initial+1,x
        clc
        adc #6
        sta hazard_bottom
        lda cannon_initial+2,x
        adc #0
        sta hazard_bottom+1
        lda hazard_bottom+1
        cmp bbox_t_hi
        bcc ?cannon_next
        beq ?cannon_bottom_low
        jmp ?hit
?cannon_bottom_low
        lda hazard_bottom
        cmp bbox_t
        bcc ?cannon_next
        jmp ?hit

?cannon_next
        ldx hazard_index
        txa
        clc
        adc #CANNON_SIZE
        tax
        cpx #CANNON_COUNT*CANNON_SIZE
        bcc ?cannon

?lava_start
        ldx #0
?lava  stx hazard_index
        lda lava_initial,x
        sta point_x
        lda bbox_r
        cmp point_x
        bcc ?lava_next
        lda lava_initial,x
        clc
        adc #15
        cmp bbox_l
        bcc ?lava_next

        lda lava_initial+1,x
        sta hazard_top
        lda lava_initial+2,x
        sta hazard_top+1
        lda bbox_b_hi
        cmp hazard_top+1
        bcc ?lava_next
        bne ?lava_bottom
        lda bbox_b
        cmp hazard_top
        bcc ?lava_next
?lava_bottom
        clc
        lda lava_initial+1,x
        adc #15
        sta hazard_bottom
        lda lava_initial+2,x
        adc #0
        sta hazard_bottom+1
        lda hazard_bottom+1
        cmp bbox_t_hi
        bcc ?lava_next
        bne ?hit
        lda hazard_bottom
        cmp bbox_t
        bcs ?hit

?lava_next
        ldx hazard_index
        txa
        clc
        adc #LAVA_SIZE
        tax
        cpx #LAVA_COUNT*LAVA_SIZE
        bcs ?done
        jmp ?lava
?done
        rts

?hit   jmp reset_player
.endp

.proc check_player_cannonballs
        lda player_x+1
        sec
        sbc #4
        sta bbox_l
        lda player_x+1
        clc
        adc #3
        sta bbox_r
        lda player_y+1
        sec
        sbc #12
        sta bbox_t
        lda player_y+2
        sbc #0
        sta bbox_t_hi
        lda player_y+1
        sec
        sbc #1
        sta bbox_b
        lda player_y+2
        sbc #0
        sta bbox_b_hi

        ldx #0
?ball  stx ball_index
        lda cannonballs+BALL_ACTIVE,x
        beq ?next
        lda cannonballs+BALL_X,x
        sec
        sbc #4
        sta point_x
        lda bbox_r
        cmp point_x
        bcc ?next
        lda cannonballs+BALL_X,x
        clc
        adc #3
        cmp bbox_l
        bcc ?next
        lda cannonballs+BALL_Y_LO,x
        sec
        sbc #4
        sta hazard_top
        lda cannonballs+BALL_Y_HI,x
        sbc #0
        sta hazard_top+1
        lda bbox_b_hi
        cmp hazard_top+1
        bcc ?next
        bne ?bottom
        lda bbox_b
        cmp hazard_top
        bcc ?next
?bottom
        lda cannonballs+BALL_Y_LO,x
        clc
        adc #3
        sta hazard_bottom
        lda cannonballs+BALL_Y_HI,x
        adc #0
        sta hazard_bottom+1
        lda hazard_bottom+1
        cmp bbox_t_hi
        bcc ?next
        bne ?hit
        lda hazard_bottom
        cmp bbox_t
        bcs ?hit

?next  ldx ball_index
        txa
        clc
        adc #BALL_SIZE
        tax
        cpx #BALL_COUNT*BALL_SIZE
        bcc ?ball
        rts
?hit   jmp reset_player
.endp

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
        jsr clear_view
        jsr draw_lava
        jsr draw_map
        jsr draw_spikes
        jsr draw_cannons
        jsr draw_movers
        jsr draw_thwomps
        jsr draw_checkpoints
        jsr draw_cannonballs
        jsr draw_grapple
        jsr draw_hero
        jsr wait_blit
        jmp present_back_buffer
.endp

.proc clear_view
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
        jmp fill_rect
.endp

draw_screen_y dta a(0)
draw_tile_y dta 0
draw_tile_h dta 0
draw_col dta 0
draw_row_temp dta 0
draw_run_start dta 0
draw_run_length dta 0

; Draw the solid portion of the original 12x240 map. The browser tilemap is
; offset by (-16,-16), leaving columns 1..10 in the 160-pixel-wide viewport.
.proc draw_map
        clc
        lda camera_y
        adc #16
        sta map_y_temp
        lda camera_y+1
        adc #0
        sta map_y_temp+1

        lda map_y_temp+1
        asl
        asl
        asl
        asl
        sta tile_row
        lda map_y_temp
        lsr
        lsr
        lsr
        lsr
        ora tile_row
        sta tile_row

        ; screen y = tile_row*16 - 16 - camera_y
        sec
        sbc #1
        sta draw_row_temp
        and #$0F
        asl
        asl
        asl
        asl
        sta draw_screen_y
        lda draw_row_temp
        lsr
        lsr
        lsr
        lsr
        sta draw_screen_y+1
        sec
        lda draw_screen_y
        sbc camera_y
        sta draw_screen_y
        lda draw_screen_y+1
        sbc camera_y+1
        sta draw_screen_y+1

?row   lda tile_row
        cmp #MAP_ROWS
        bcc ?row_in_map
        jmp ?done
?row_in_map
        lda draw_screen_y+1
        beq ?positive
        cmp #$FF
        beq ?negative
        jmp ?done
?negative
        lda draw_screen_y
        clc
        adc #16
        bne ?partial_row
        jmp ?next_row
?partial_row
        asl
        sta draw_tile_h
        lda #0
        sta draw_tile_y
        beq ?columns

?positive
        lda draw_screen_y
        cmp #VIEW_H
        bcc ?visible_row
        jmp ?done
?visible_row
        asl
        sta draw_tile_y
        lda #VIEW_H
        sec
        sbc draw_screen_y
        cmp #16
        bcc ?short
        lda #16
?short  asl
        sta draw_tile_h

?columns
        lda #1
        sta draw_col
?find_solid
        lda draw_col
        cmp #11
        bcc ?column_in_range
        jmp ?next_row
?column_in_range
        sta tile_col
        jsr load_map_tile
        cmp #1
        bcs ?maybe_solid
        jmp ?skip_empty
?maybe_solid
        cmp #11
        bcc ?solid
        jmp ?skip_empty

?solid
        lda draw_col
        sta draw_run_start
?extend_run
        inc draw_col
        lda draw_col
        cmp #11
        bcs ?run_ready
        sta tile_col
        jsr load_map_tile
        cmp #1
        bcc ?run_ready
        cmp #11
        bcc ?extend_run

?run_ready
        sec
        lda draw_col
        sbc draw_run_start
        sta draw_run_length

        lda draw_run_start
        sec
        sbc #1
        sta calc_x
        lda #0
        sta calc_x+1
        asl calc_x
        rol calc_x+1
        asl calc_x
        rol calc_x+1
        asl calc_x
        rol calc_x+1
        asl calc_x
        rol calc_x+1
        asl calc_x
        rol calc_x+1
        lda draw_tile_y
        sta calc_y
        lda draw_run_length
        sta fr_w
        lda #0
        sta fr_w+1
        asl fr_w
        rol fr_w+1
        asl fr_w
        rol fr_w+1
        asl fr_w
        rol fr_w+1
        asl fr_w
        rol fr_w+1
        asl fr_w
        rol fr_w+1
        lda draw_tile_h
        sta fr_h
        lda #C_STONE
        sta fr_col
        jsr fill_rect
        jmp ?find_solid

?skip_empty
        inc draw_col
        jmp ?find_solid

?next_row
        inc tile_row
        clc
        lda draw_screen_y
        adc #16
        sta draw_screen_y
        bcs ?row_carry
        jmp ?row
?row_carry
        inc draw_screen_y+1
        jmp ?row
?done   rts
.endp

.proc draw_lava
        ldx #0
?lava  stx hazard_index
        sec
        lda lava_initial+1,x
        sbc camera_y
        sta draw_screen_y
        lda lava_initial+2,x
        sbc camera_y+1
        sta draw_screen_y+1
        beq ?positive
        cmp #$FF
        beq ?negative
        jmp ?next

?negative
        clc
        lda draw_screen_y
        adc #16
        bcc ?next
        beq ?next
        sta draw_tile_h
        lda #0
        sta draw_screen_y
        beq ?dimensions

?positive
        lda draw_screen_y
        cmp #VIEW_H
        bcs ?next
        sta map_y_temp
        lda #VIEW_H
        sec
        sbc map_y_temp
        cmp #16
        bcc ?height_ready
        lda #16
?height_ready
        sta draw_tile_h

?dimensions
        lda lava_initial,x
        jsr double_a_to_calc_x
        lda draw_screen_y
        asl
        sta calc_y
        lda #16
        asl
        sta fr_w
        lda #0
        rol
        sta fr_w+1
        lda draw_tile_h
        asl
        sta fr_h
        lda #C_LAVA
        sta fr_col
        jsr fill_rect

?next  ldx hazard_index
        txa
        clc
        adc #LAVA_SIZE
        tax
        cpx #LAVA_COUNT*LAVA_SIZE
        bcs ?done
        jmp ?lava
?done
        rts
.endp

.proc draw_spikes
        ldx #0
?spike stx hazard_index
        sec
        lda spike_initial+1,x
        sbc camera_y
        sta draw_screen_y
        lda spike_initial+2,x
        sbc camera_y+1
        beq ?vertical_visible
        bpl ?below_view
        jmp ?next
?below_view
        jmp ?done
?vertical_visible
        lda draw_screen_y
        cmp #8
        bcs ?below_top
        jmp ?next
?below_top
        cmp #93
        bcc ?draw
        jmp ?done

?draw   lda spike_initial,x
        jsr double_a_to_calc_x
        sec
        lda calc_x
        sbc #16
        sta calc_x
        lda calc_x+1
        sbc #0
        sta calc_x+1
        lda draw_screen_y
        asl
        sec
        sbc #16
        sta calc_y
        jsr calc_addr

        lda #0
        sta bl_src
        ldx hazard_index        ; calc_addr uses X for its address lookup
        lda spike_initial+3,x
        asl
        asl
        clc
        adc #$44               ; after hero ($00..$3F) and mover ($40..$43)
        sta bl_src+1
        lda #ASSET_VBANK
        sta bl_src+2
        lda #32
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
        lda #1
        sta bl_mode
        jsr do_blit

?next  ldx hazard_index
        txa
        clc
        adc #SPIKE_SIZE
        tax
        cpx #SPIKE_COUNT*SPIKE_SIZE
        bcs ?done
        jmp ?spike
?done   rts
.endp

.proc draw_cannons
        ldx #0
?cannon
        stx cannon_index
        sec
        lda cannon_initial+1,x
        sbc camera_y
        sta draw_screen_y
        lda cannon_initial+2,x
        sbc camera_y+1
        beq ?vertical_visible
        bmi ?past
        jmp ?done
?past  jmp ?next
?vertical_visible
        lda draw_screen_y
        cmp #8
        bcs ?below_top
        jmp ?next
?below_top
        cmp #93
        bcc ?draw
        jmp ?done

?draw
        lda cannon_initial,x
        jsr double_a_to_calc_x
        sec
        lda calc_x
        sbc #16
        sta calc_x
        lda calc_x+1
        sbc #0
        sta calc_x+1
        lda draw_screen_y
        asl
        sec
        sbc #16
        sta calc_y
        jsr calc_addr

        lda #0
        sta bl_src
        ldx cannon_index
        lda cannon_initial+CANNON_ROT,x
        asl
        asl
        clc
        adc #$54               ; after hero, mover, and spike graphics
        sta bl_src+1
        lda #ASSET_VBANK
        sta bl_src+2
        lda #32
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
        lda #1
        sta bl_mode
        jsr do_blit

?next  ldx cannon_index
        txa
        clc
        adc #CANNON_SIZE
        tax
        cpx #CANNON_COUNT*CANNON_SIZE
        bcs ?done
        jmp ?cannon
?done  rts
.endp

.proc draw_cannonballs
        ldx #0
?ball  stx ball_index
        lda cannonballs+BALL_ACTIVE,x
        bne ?active
        jmp ?next
?active
        sec
        lda cannonballs+BALL_Y_LO,x
        sbc camera_y
        sta draw_screen_y
        lda cannonballs+BALL_Y_HI,x
        sbc camera_y+1
        beq ?vertical_visible
        jmp ?next
?vertical_visible
        lda draw_screen_y
        cmp #5
        bcs ?below_top
        jmp ?next
?below_top
        cmp #96
        bcc ?test_x
        jmp ?next
?test_x
        lda cannonballs+BALL_X,x
        cmp #5
        bcs ?right_edge
        jmp ?next
?right_edge
        cmp #156
        bcc ?draw
        jmp ?next

?draw
        jsr double_a_to_calc_x
        sec
        lda calc_x
        sbc #10
        sta calc_x
        lda calc_x+1
        sbc #0
        sta calc_x+1
        lda draw_screen_y
        asl
        sec
        sbc #10
        sta calc_y
        jsr calc_addr

        lda #0
        sta bl_src
        lda #$64               ; 20x20 cannonball after four cannon frames
        sta bl_src+1
        lda #ASSET_VBANK
        sta bl_src+2
        lda #20
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
        lda #19
        sta bl_w
        lda #0
        sta bl_w+1
        lda #19
        sta bl_h
        lda #$FF
        sta bl_and
        lda #0
        sta bl_xor
        lda #1
        sta bl_mode
        jsr do_blit

?next  ldx ball_index
        txa
        clc
        adc #BALL_SIZE
        tax
        cpx #BALL_COUNT*BALL_SIZE
        bcs ?done
        jmp ?ball
?done  rts
.endp

.proc draw_movers
        ldx #0
?mover stx mover_index
        sec
        lda mover_state+MOVER_Y_LO,x
        sbc camera_y
        sta draw_screen_y
        lda mover_state+MOVER_Y_HI,x
        sbc camera_y+1
        beq ?vertical_visible
        jmp ?next
?vertical_visible
        lda draw_screen_y
        cmp #8
        bcs ?below_top
        jmp ?next
?below_top
        cmp #93
        bcc ?draw
        jmp ?next
?draw

        lda mover_state+MOVER_X,x
        jsr double_a_to_calc_x
        sec
        lda calc_x
        sbc #16
        sta calc_x
        lda calc_x+1
        sbc #0
        sta calc_x+1
        lda draw_screen_y
        asl
        sec
        sbc #16
        sta calc_y
        jsr calc_addr

        lda #0
        sta bl_src
        lda #$40               ; immediately after 16 hero frames
        sta bl_src+1
        lda #ASSET_VBANK
        sta bl_src+2
        lda #32
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
        lda #1
        sta bl_mode
        jsr do_blit

?next   ldx mover_index
        txa
        clc
        adc #MOVER_SIZE
        tax
        cpx #MOVER_COUNT*MOVER_SIZE
        bcs ?done
        jmp ?mover
?done
        rts
.endp

thwomp_asset_hi dta $6A,$6E,$66 ; awake, active, sleep after $6600 base

.proc draw_thwomps
        ldx #0
?thwomp
        stx thwomp_index
        sec
        lda thwomp_state+THW_Y_LO,x
        sbc camera_y
        sta draw_screen_y
        lda thwomp_state+THW_Y_HI,x
        sbc camera_y+1
        beq ?vertical_visible
        jmp ?next
?vertical_visible
        lda draw_screen_y
        cmp #8
        bcs ?below_top
        jmp ?next
?below_top
        cmp #93
        bcc ?test_x
        jmp ?next
?test_x
        lda thwomp_state+THW_X,x
        cmp #8
        bcs ?right_edge
        jmp ?next
?right_edge
        cmp #153
        bcc ?draw
        jmp ?next

?draw  jsr double_a_to_calc_x
        sec
        lda calc_x
        sbc #16
        sta calc_x
        lda calc_x+1
        sbc #0
        sta calc_x+1
        lda draw_screen_y
        asl
        sec
        sbc #16
        sta calc_y
        jsr calc_addr

        lda #0
        sta bl_src
        ldx thwomp_index
        ldy thwomp_state+THW_STATE,x
        lda thwomp_asset_hi,y
        sta bl_src+1
        lda #ASSET_VBANK
        sta bl_src+2
        lda #32
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
        lda #1
        sta bl_mode
        jsr do_blit

?next  ldx thwomp_index
        txa
        clc
        adc #THWOMP_SIZE
        tax
        cpx #THWOMP_COUNT*THWOMP_SIZE
        bcs ?done
        jmp ?thwomp
?done  rts
.endp

checkpoint_frame dta 0
checkpoint_frame_hi dta $72,$76
checkpoint_rotated_hi dta $75,$79

.proc draw_checkpoints
        ldx #0
?checkpoint
        stx checkpoint_index
        sec
        lda checkpoint_initial+1,x
        sbc camera_y
        sta draw_screen_y
        lda checkpoint_initial+2,x
        sbc camera_y+1
        beq ?vertical_visible
        bmi ?above_view
        jmp ?done
?above_view
        jmp ?next
?vertical_visible
        lda draw_screen_y
        cmp #8
        bcs ?below_top
        jmp ?next
?below_top
        cmp #93
        bcc ?draw
        jmp ?done

?draw
        lda checkpoint_initial,x
        jsr double_a_to_calc_x
        sec
        lda calc_x
        sbc #16
        sta calc_x
        lda calc_x+1
        sbc #0
        sta calc_x+1
        lda draw_screen_y
        asl
        sec
        sbc #16
        sta calc_y
        jsr calc_addr

        ldx checkpoint_index
        ldy #0
        cpx checkpoint_current
        bne ?frame_ready
        iny
?frame_ready
        sty checkpoint_frame
        lda checkpoint_initial+3,x
        and #1
        bne ?rotated
        lda #0
        sta bl_src
        lda checkpoint_frame_hi,y
        sta bl_src+1
        lda #32
        sta bl_ssy
        lda #0
        sta bl_ssy+1
        lda #1
        sta bl_ssx
        jmp ?source_ready

        ; A 90-degree source walk avoids storing duplicate rotated artwork.
?rotated
        lda #$E0               ; frame base + $03E0, bottom-left pixel
        sta bl_src
        lda checkpoint_rotated_hi,y
        sta bl_src+1
        lda #1
        sta bl_ssy
        lda #0
        sta bl_ssy+1
        lda #$E0               ; signed source X step: -32 bytes
        sta bl_ssx

?source_ready
        lda #ASSET_VBANK
        sta bl_src+2
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
        lda #1
        sta bl_mode
        jsr do_blit

?next  ldx checkpoint_index
        txa
        clc
        adc #CHECKPOINT_SIZE
        tax
        cpx #CHECKPOINT_COUNT*CHECKPOINT_SIZE
        bcs ?done
        jmp ?checkpoint
?done  rts
.endp

.proc draw_grapple
        lda grapple_state
        bne ?active
        rts
?active
        lda player_y+1
        sec
        sbc #6
        sta world_draw_y
        lda player_y+2
        sbc #0
        sta world_draw_y+1
        jsr clamp_world_y
        sta rope_player_y
        lda hook_y
        sta world_draw_y
        lda hook_y+1
        sta world_draw_y+1
        jsr clamp_world_y
        sta rope_hook_y

        lda grapple_dir
        and #1
        bne ?horizontal

        ; Vertical rope: x = player centre, y spans source to hook.
        lda player_x+1
        jsr double_a_to_calc_x
        lda rope_player_y
        sta rope_source
        lda rope_hook_y
        cmp rope_source
        bcs ?v_hook_after
        sta rope_min
        lda rope_source
        sec
        sbc rope_hook_y
        jmp ?v_length
?v_hook_after
        lda rope_source
        sta rope_min
        lda rope_hook_y
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
        lda rope_player_y
        asl
        sta calc_y
        lda player_x+1
        sta rope_source
        lda hook_x
        cmp #VIEW_W
        bcc ?hook_x_ok
        lda #VIEW_W-1
?hook_x_ok
        sta rope_hook_x
        cmp rope_source
        bcs ?h_hook_after
        sta rope_min
        lda rope_source
        sec
        sbc rope_hook_x
        jmp ?h_length
?h_hook_after
        lda rope_source
        sta rope_min
        lda rope_hook_x
        sec
        sbc rope_source
?h_length
        asl
        sta fr_w
        lda #0
        rol
        sta fr_w+1
        clc
        lda fr_w
        adc #2
        sta fr_w
        bcc ?width_ready
        inc fr_w+1
?width_ready
        lda rope_min
        jsr double_a_to_calc_x
        lda #2
        sta fr_h
        lda #C_ROPE
        sta fr_col
        jsr fill_rect

?hook   lda hook_x
        cmp #2
        bcs ?hook_left_ok
        lda #2
?hook_left_ok
        cmp #158
        bcc ?hook_right_ok
        lda #157
?hook_right_ok
        jsr double_a_to_calc_x
        sec
        lda calc_x
        sbc #4
        sta calc_x
        lda calc_x+1
        sbc #0
        sta calc_x+1
        lda rope_hook_y
        cmp #2
        bcs ?hook_top_ok
        lda #2
?hook_top_ok
        cmp #98
        bcc ?hook_bottom_ok
        lda #97
?hook_bottom_ok
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
rope_player_y dta 0
rope_hook_y dta 0
rope_hook_x dta 0
world_draw_y dta a(0)

.proc clamp_world_y
        sec
        lda world_draw_y
        sbc camera_y
        sta draw_screen_y
        lda world_draw_y+1
        sbc camera_y+1
        bmi ?top
        bne ?bottom
        lda draw_screen_y
        cmp #VIEW_H
        bcc ?done
?bottom lda #VIEW_H-1
        rts
?top    lda #0
?done   rts
.endp

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
        sec
        lda player_y+1
        sbc camera_y
        sta draw_screen_y
        lda player_y+2
        sbc camera_y+1
        lda draw_screen_y
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
?pair   ldx #0
        lda (data_ptr,x)
        pha
        lsr
        lsr
        lsr
        lsr
        tax
        lda asset_unpack,x
        sta (text_dst),y
        iny
        pla
        and #$0F
        tax
        lda asset_unpack,x
        sta (text_dst),y
        iny
        inc data_ptr
        bne ?source_ready
        inc data_ptr+1
?source_ready
        tya
        bne ?pair
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
asset_unpack dta 0,C_PLAYER_RED,C_PLAYER_WHT,C_MOVER_DARK

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
        dta 22,176, 24, 48
        dta 23,255,106,  0
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
        org $8F00
display_list
        dta $42,a(text_screen)
        :24 dta $02
        dta $41,a(display_list)

        org $4000
asset_raw
        ins 'assets-packed.bin'

        org $7D00
text_screen
        :1000 dta 0

        org $8100
world_map
        ins 'world-map.bin'

        org $8C40
mover_initial
        ins 'mover-data.bin'

spike_initial
        ins 'spike-data.bin'

lava_initial
        ins 'lava-data.bin'

cannon_initial
        ins 'cannon-data.bin'

thwomp_initial
        ins 'thwomp-data.bin'

checkpoint_initial
        ins 'checkpoint-data.bin'

        run main
