;==============================================================================
; HEROES OF LOWREZ - VBXE BATTLE PROTOTYPE
;
; Native Atari XL/XE + VBXE interpretation of ../web.
; Build: mads heroes-vbxe.asm -o:heroes-vbxe.xex
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
STRIG0   = $D010
CONSOL   = $D01F
DMACTL   = $D400

; VBXE FX registers (relocated to D7xx at runtime when required)
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
ASSET_PAGES = 58
BACKGROUND_BANK = 3

COLS       = 7
ROWS       = 6
CELLS      = 42
MAX_UNITS  = 12
BATTLES    = 4
TEAM_HERO  = 0
TEAM_ENEMY = 1
T_OPEN     = 0
T_TREE     = 1

U_KNIGHT   = 0
U_ARCHER   = 1
U_MINIBEAST= 2
U_SKELETON = 3
U_OGRE     = 4
U_BAT      = 5
U_WARLOCK  = 6
U_IMP      = 7
U_SK_ARCHER= 8

; VBXE palette indexes
C_CLEAR     = 0
C_GRASS     = 1
C_GRASS_ALT = 2
C_MOVE      = 3
C_MOVE_LAST = 4
C_TREE_DARK = 5
C_TREE      = 6
C_HERO      = 7
C_HERO_HI   = 8
C_ENEMY     = 9
C_ENEMY_DARK= 10
C_BONE      = 11
C_WARLOCK   = 12
C_WHITE     = 13
C_BLACK     = 14
C_ATTACK    = 15
C_HEALTH    = 16
C_BOW       = 17
C_SHADOW    = 18

; Zero page pointers
work_ptr = $CB
data_ptr = $CD
text_src = $CF
text_dst = $D1
calc_out = $D3                 ; three bytes

        org $2000

;==============================================================================
; Main
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
        jsr upload_assets
        jsr load_palette
        lda #0
        sta front_bank
        sta render_bank
        lda #1
        sta back_bank
        jsr clear_framebuffer
        jsr wait_blit
        lda #1
        sta render_bank
        jsr clear_framebuffer
        jsr wait_blit
        lda #BACKGROUND_BANK
        sta render_bank
        jsr draw_terrain_background
        jsr wait_blit
        jsr enable_display

        lda #0
        sta battle_number
        sta old_fire
        sta anim_frame
        lda #15
        sta old_stick
        lda #7
        sta old_console
        lda #$FF
        sta CH
        jsr init_battle
        jsr draw_everything

?loop   jsr wait_frame
        jsr read_joystick
        jsr read_console
        jsr read_keyboard
        lda RTCLOK+2
        and #7
        bne ?loop
        inc anim_frame
        jsr draw_everything
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
.proc read_joystick
        lda PORTA
        and #15
        cmp old_stick
        beq ?fire
        sta old_stick
        cmp #14
        bne ?down
        jsr cursor_up
        jmp ?redraw
?down   cmp #13
        bne ?left
        jsr cursor_down
        jmp ?redraw
?left   cmp #11
        bne ?right
        jsr cursor_left
        jmp ?redraw
?right  cmp #7
        bne ?fire
        jsr cursor_right
?redraw jsr draw_everything

?fire   lda STRIG0
        eor #1
        cmp old_fire
        beq ?done
        sta old_fire
        beq ?done
        jsr confirm_cell
        jsr draw_everything
?done   rts
.endp

.proc read_console
        lda CONSOL
        and #7
        cmp old_console
        beq ?done
        sta old_console
        and #2                    ; SELECT restarts
        bne ?done
        jsr init_battle
        jsr draw_everything
?done   rts
.endp

.proc read_keyboard
        lda CH
        cmp #$FF
        beq ?done
        and #$3F
        sta key_temp
        lda #$FF
        sta CH
        lda key_temp
        cmp #$2E                  ; W
        bne ?a
        jsr cursor_up
        jmp ?draw
?a      cmp #$3F                  ; A
        bne ?s
        jsr cursor_left
        jmp ?draw
?s      cmp #$3E                  ; S
        bne ?d
        jsr cursor_down
        jmp ?draw
?d      cmp #$3A                  ; D
        bne ?skip
        jsr cursor_right
        jmp ?draw
?skip   cmp #$21                  ; Space
        bne ?previous
        jsr skip_hero
        jmp ?draw
?previous
        cmp #$1F                  ; 1
        bne ?next
        jsr previous_battle
        jmp ?draw
?next   cmp #$1E                  ; 2
        bne ?restart
        jsr next_battle
        jmp ?draw
?restart
        cmp #$28                  ; R
        bne ?done
        jsr init_battle
?draw   jsr draw_everything
?done   rts
.endp

.proc cursor_left
        ldx cursor_cell
        lda cell_col,x
        beq ?done
        dec cursor_cell
?done   rts
.endp

.proc cursor_right
        ldx cursor_cell
        lda cell_col,x
        cmp #COLS-1
        beq ?done
        inc cursor_cell
?done   rts
.endp

.proc cursor_up
        lda cursor_cell
        cmp #COLS
        bcc ?done
        sec
        sbc #COLS
        sta cursor_cell
?done   rts
.endp

.proc cursor_down
        lda cursor_cell
        cmp #CELLS-COLS
        bcs ?done
        clc
        adc #COLS
        sta cursor_cell
?done   rts
.endp

.proc previous_battle
        lda battle_number
        bne ?dec
        lda #BATTLES-1
        bne ?store
?dec    dec battle_number
        jmp init_battle
?store  sta battle_number
        jmp init_battle
.endp

.proc next_battle
        inc battle_number
        lda battle_number
        cmp #BATTLES
        bcc ?go
        lda #0
        sta battle_number
?go     jmp init_battle
.endp

key_temp    dta 0
old_stick   dta 15
old_fire    dta 0
old_console dta 7
anim_frame  dta 0

;==============================================================================
; Battle state and initialization
;==============================================================================
battle_number dta 0
turn_number   dta 1
game_state    dta 0             ; 0 playing, 1 won, 2 lost
selected_unit dta 0
cursor_cell   dta 15
unit_count    dta 0
terrain       :CELLS dta 0
unit_type     :MAX_UNITS dta 0
unit_team     :MAX_UNITS dta 0
unit_cell     :MAX_UNITS dta 0
unit_hp       :MAX_UNITS dta 0
unit_acted    :MAX_UNITS dta 0
unit_moved    :MAX_UNITS dta 0
unit_move_left:MAX_UNITS dta 0

type_hp     dta 5,3,3,3,6,2,7,2,2
type_damage dta 2,2,1,1,3,1,2,1,1
type_range  dta 1,3,1,1,1,1,3,1,3
type_move   dta 2,2,2,1,1,2,1,2,1

tree_ptr_lo dta <battle1_trees,<battle2_trees,<battle3_trees,<battle4_trees
tree_ptr_hi dta >battle1_trees,>battle2_trees,>battle3_trees,>battle4_trees
unit_ptr_lo dta <battle1_units,<battle2_units,<battle3_units,<battle4_units
unit_ptr_hi dta >battle1_units,>battle2_units,>battle3_units,>battle4_units

.proc init_battle
        ldx #CELLS-1
        lda #T_OPEN
?terrain
        sta terrain,x
        dex
        bpl ?terrain
        ldx #MAX_UNITS-1
        lda #0
?units sta unit_type,x
        sta unit_team,x
        sta unit_cell,x
        sta unit_hp,x
        sta unit_acted,x
        sta unit_moved,x
        sta unit_move_left,x
        dex
        bpl ?units

        lda #0
        sta unit_count
        sta game_state
        lda #1
        sta turn_number

        lda #U_KNIGHT
        ldx #TEAM_HERO
        ldy #15                  ; (1,2)
        jsr add_unit
        lda #U_ARCHER
        ldx #TEAM_HERO
        ldy #28                  ; (0,4)
        jsr add_unit

        ldx battle_number
        lda tree_ptr_lo,x
        sta data_ptr
        lda tree_ptr_hi,x
        sta data_ptr+1
        ldy #0
?tree  lda (data_ptr),y
        cmp #$FF
        beq ?enemy_ptr
        tax
        lda #T_TREE
        sta terrain,x
        iny
        bne ?tree

?enemy_ptr
        ldx battle_number
        lda unit_ptr_lo,x
        sta data_ptr
        lda unit_ptr_hi,x
        sta data_ptr+1
        ldy #0
?enemy lda (data_ptr),y
        cmp #$FF
        beq ?ready
        sta add_type
        iny
        lda (data_ptr),y
        sta add_cell
        iny
        tya
        pha
        lda add_type
        ldx #TEAM_ENEMY
        ldy add_cell
        jsr add_unit
        pla
        tay
        jmp ?enemy
?ready lda #0
        sta selected_unit
        lda unit_cell
        sta cursor_cell
        rts
.endp

add_type dta 0
add_cell dta 0

; A type, X team, Y cell
.proc add_unit
        sta add_type
        stx add_team
        sty add_cell
        ldx unit_count
        cpx #MAX_UNITS
        bcs ?full
        lda add_type
        sta unit_type,x
        tay
        lda add_team
        sta unit_team,x
        lda add_cell
        sta unit_cell,x
        lda type_hp,y
        sta unit_hp,x
        lda type_move,y
        sta unit_move_left,x
        lda #0
        sta unit_acted,x
        sta unit_moved,x
        inc unit_count
        txa
        sec
        rts
?full   clc
        rts
.endp
add_team dta 0

;==============================================================================
; Hex and occupancy helpers
;==============================================================================
target_cell dta 0
target_unit dta 0
lookup_cell dta 0
source_cell dta 0
test_cell   dta 0
test_dir    dta 0
test_cost   dta 0
action_move_cost dta 0

; A cell -> C set and X unit, or C clear.
.proc unit_at
        sta lookup_cell
        ldx #0
?loop   cpx unit_count
        bcs ?none
        lda unit_hp,x
        beq ?next
        lda unit_cell,x
        cmp lookup_cell
        beq ?found
?next   inx
        bne ?loop
?found  sec
        rts
?none   clc
        rts
.endp

; A cell -> C set when open.
.proc is_open
        cmp #CELLS
        bcs ?no
        sta lookup_cell
        tax
        lda terrain,x
        bne ?no
        lda lookup_cell
        jsr unit_at
        bcs ?no
        sec
        rts
?no     clc
        rts
.endp

; A source, X destination -> A distance.
.proc distance_cells
        tay
        lda distance_row_lo,y
        sta work_ptr
        lda distance_row_hi,y
        sta work_ptr+1
        txa
        tay
        lda (work_ptr),y
        rts
.endp

; A cell, X direction -> A neighbour or FF.
.proc get_neighbour
        tay
        lda neighbour_row_lo,y
        sta work_ptr
        lda neighbour_row_hi,y
        sta work_ptr+1
        txa
        tay
        lda (work_ptr),y
        rts
.endp

; A target -> A cost 1/2 or FF. Uses selected unit and current move budget.
.proc move_cost
        sta target_cell
        jsr is_open
        bcc ?bad
        ldx selected_unit
        lda unit_cell,x
        sta source_cell
        ldx target_cell
        jsr distance_cells
        cmp #1
        beq ?one
        cmp #2
        bne ?bad
        ldx selected_unit
        lda unit_move_left,x
        cmp #2
        bcc ?bad
        lda #0
        sta test_dir
?mid   lda source_cell
        ldx test_dir
        jsr get_neighbour
        cmp #$FF
        beq ?next
        sta test_cell
        jsr is_open
        bcc ?next
        lda test_cell
        ldx target_cell
        jsr distance_cells
        cmp #1
        beq ?two
?next   inc test_dir
        lda test_dir
        cmp #6
        bcc ?mid
?bad    lda #$FF
        rts
?one    lda #1
        rts
?two    lda #2
        rts
.endp

; A cell -> A 0 invalid, 1 movement, 2 attack.
.proc action_at
        sta target_cell
        lda game_state
        bne ?none
        ldx selected_unit
        lda unit_acted,x
        bne ?none
        lda target_cell
        jsr unit_at
        bcc ?movement
        lda unit_team,x
        cmp #TEAM_ENEMY
        bne ?none
        stx target_unit
        ldx selected_unit
        lda unit_cell,x
        ldx target_cell
        jsr distance_cells
        sta test_cost
        ldx selected_unit
        ldy unit_type,x
        lda type_range,y
        cmp test_cost
        bcc ?none
        lda #2
        rts
?movement
        ldx selected_unit
        lda unit_move_left,x
        beq ?none
        lda target_cell
        jsr move_cost
        cmp #$FF
        beq ?none
        sta test_cost
        ldx selected_unit
        lda unit_move_left,x
        cmp test_cost
        bcc ?none
        lda #1
        rts
?none   lda #0
        rts
.endp

;==============================================================================
; Player actions and combat
;==============================================================================
.proc confirm_cell
        lda cursor_cell
        jsr action_at
        cmp #2
        beq ?attack
        cmp #1
        beq ?move
        rts
?attack ldx selected_unit
        stx attacker_unit
        ldx target_unit
        stx defender_unit
        jsr animate_attack
        jsr attack_units
        jsr finish_hero
        jmp check_result
?move   lda cursor_cell
        jsr move_cost
        sta action_move_cost
        ldx selected_unit
        stx animation_unit
        lda unit_cell,x
        sta animation_from
        lda cursor_cell
        sta animation_to
        jsr animate_move
        ldx selected_unit
        lda cursor_cell
        sta unit_cell,x
        lda #1
        sta unit_moved,x
        lda unit_move_left,x
        sec
        sbc action_move_cost
        sta unit_move_left,x
        bne ?done
        jmp finish_hero
?done   rts
.endp

.proc skip_hero
        lda game_state
        bne ?done
        jmp finish_hero
?done   rts
.endp

.proc finish_hero
        ldx selected_unit
        lda #1
        sta unit_acted,x
        inx
?scan   cpx unit_count
        bcs ?enemies
        lda unit_team,x
        bne ?next
        lda unit_hp,x
        beq ?next
        lda unit_acted,x
        beq ?select
?next   inx
        bne ?scan
?select stx selected_unit
        lda unit_cell,x
        sta cursor_cell
        rts
?enemies
        jsr enemy_phase
        rts
.endp

attacker_unit dta 0
defender_unit dta 0
animation_active dta 0
animation_unit   dta 0
animation_from   dta 0
animation_to     dta 0
animation_x      dta 0
animation_y      dta 0
animation_target_x dta 0
animation_target_y dta 0
attack_flash     dta 0
attack_flash_target dta 0
attack_frame     dta 0

.proc animate_move
        ldx animation_from
        lda cell_x_lo,x
        sta animation_x
        lda cell_y,x
        sta animation_y
        ldx animation_to
        lda cell_x_lo,x
        sta animation_target_x
        lda cell_y,x
        sta animation_target_y
        lda #1
        sta animation_active
?frame  jsr draw_everything
        lda animation_x
        cmp animation_target_x
        bne ?advance
        lda animation_y
        cmp animation_target_y
        beq ?done
?advance
        jsr advance_animation_position
        jmp ?frame
?done   lda #0
        sta animation_active
        rts
.endp

.proc advance_animation_position
        lda animation_x
        cmp animation_target_x
        beq ?vertical
        bcc ?x_add
        sec
        sbc animation_target_x
        cmp #5
        bcc ?x_set
        lda animation_x
        sec
        sbc #4
        sta animation_x
        jmp ?vertical
?x_add  lda animation_target_x
        sec
        sbc animation_x
        cmp #5
        bcc ?x_set
        lda animation_x
        clc
        adc #4
        sta animation_x
        jmp ?vertical
?x_set  lda animation_target_x
        sta animation_x

?vertical
        lda animation_y
        cmp animation_target_y
        beq ?done
        bcc ?y_add
        sec
        sbc animation_target_y
        cmp #4
        bcc ?y_set
        lda animation_y
        sec
        sbc #3
        sta animation_y
        rts
?y_add  lda animation_target_y
        sec
        sbc animation_y
        cmp #4
        bcc ?y_set
        lda animation_y
        clc
        adc #3
        sta animation_y
        rts
?y_set  lda animation_target_y
        sta animation_y
?done   rts
.endp

.proc animate_attack
        lda defender_unit
        sta attack_flash_target
        lda #8
        sta attack_frame
?frame  lda attack_frame
        and #1
        sta attack_flash
        jsr draw_everything
        dec attack_frame
        bne ?frame
        lda #0
        sta attack_flash
        rts
.endp

.proc attack_units
        ldx attacker_unit
        ldy unit_type,x
        lda type_damage,y
        sta attack_damage
        ldx defender_unit
        lda unit_hp,x
        sec
        sbc attack_damage
        bcs ?alive
        lda #0
?alive  sta unit_hp,x
        rts
.endp
attack_damage dta 0

.proc enemy_phase
        lda battle_number
        cmp #BATTLES-1
        bne ?begin
        jsr summon_imp
?begin  lda #2
        sta enemy_id
?enemy ldx enemy_id
        cpx unit_count
        bcs ?new_turn
        lda unit_hp,x
        beq ?next
        jsr enemy_act
        jsr check_result
        lda game_state
        bne ?done
?next   inc enemy_id
        jmp ?enemy

?new_turn
        inc turn_number
        ldx #0
?reset  cpx unit_count
        bcs ?select
        lda #0
        sta unit_acted,x
        sta unit_moved,x
        ldy unit_type,x
        lda type_move,y
        sta unit_move_left,x
        inx
        bne ?reset
?select ldx #0
?hero   cpx unit_count
        bcs ?done
        lda unit_team,x
        bne ?hn
        lda unit_hp,x
        bne ?found
?hn     inx
        bne ?hero
?found  stx selected_unit
        lda unit_cell,x
        sta cursor_cell
?done   rts
.endp

enemy_id       dta 0
enemy_target   dta 0
enemy_best     dta 0
enemy_best_dist dta 0

.proc enemy_act
        ; Find closest living hero.
        lda #$FF
        sta enemy_target
        lda #$7F
        sta enemy_best_dist
        ldx #0
?hero   cpx #2
        bcs ?have
        lda unit_hp,x
        beq ?next
        stx scan_id
        ldx enemy_id
        lda unit_cell,x
        ldy scan_id
        ldx unit_cell,y
        jsr distance_cells
        cmp enemy_best_dist
        bcs ?restore
        sta enemy_best_dist
        lda scan_id
        sta enemy_target
?restore
        ldx scan_id
?next   inx
        jmp ?hero

?have   lda enemy_target
        cmp #$FF
        bne ?has_target
        rts
?has_target
        ldx enemy_id
        ldy unit_type,x
        lda type_range,y
        cmp enemy_best_dist
        bcc ?move
        lda enemy_id
        sta attacker_unit
        lda enemy_target
        sta defender_unit
        jsr animate_attack
        jmp attack_units

?move   lda #$FF
        sta enemy_best
        lda enemy_best_dist
        sta candidate_dist
        lda #0
        sta test_dir
?dir    ldx enemy_id
        lda unit_cell,x
        ldx test_dir
        jsr get_neighbour
        cmp #$FF
        beq ?dn
        sta test_cell
        jsr is_open
        bcc ?dn
        ldy enemy_target
        ldx unit_cell,y
        lda test_cell
        jsr distance_cells
        cmp candidate_dist
        bcs ?dn
        sta candidate_dist
        lda test_cell
        sta enemy_best
?dn     inc test_dir
        lda test_dir
        cmp #6
        bcc ?dir
        lda enemy_best
        cmp #$FF
        beq ?done
        ldx enemy_id
        stx animation_unit
        lda unit_cell,x
        sta animation_from
        lda enemy_best
        sta animation_to
        jsr animate_move
        ldx enemy_id
        lda enemy_best
        sta unit_cell,x
?done   rts
.endp
scan_id        dta 0
candidate_dist dta 0

.proc summon_imp
        ldx #0
?find   cpx unit_count
        bcs ?done
        lda unit_hp,x
        beq ?next
        lda unit_type,x
        cmp #U_WARLOCK
        beq ?warlock
?next   inx
        bne ?find
?warlock
        stx scan_id
        lda #0
        sta test_dir
?dir    ldx scan_id
        lda unit_cell,x
        ldx test_dir
        jsr get_neighbour
        cmp #$FF
        beq ?dn
        sta add_cell
        jsr is_open
        bcc ?dn
        lda #U_IMP
        ldx #TEAM_ENEMY
        ldy add_cell
        jsr add_unit
        rts
?dn     inc test_dir
        lda test_dir
        cmp #6
        bcc ?dir
?done   rts
.endp

.proc check_result
        lda #0
        sta hero_alive
        sta enemy_alive
        ldx #0
?scan   cpx unit_count
        bcs ?test
        lda unit_hp,x
        beq ?next
        lda unit_team,x
        bne ?enemy
        inc hero_alive
        jmp ?next
?enemy  inc enemy_alive
?next   inx
        bne ?scan
?test   lda enemy_alive
        bne ?heroes
        lda #1
        sta game_state
        rts
?heroes lda hero_alive
        bne ?done
        lda #2
        sta game_state
?done   rts
.endp
hero_alive  dta 0
enemy_alive dta 0

;==============================================================================
; ANTIC text status
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
        lda #<[text_screen+9]
        sta text_dst
        lda #>[text_screen+9]
        sta text_dst+1
        jsr copy_text
        lda #<s_battle
        sta text_src
        lda #>s_battle
        sta text_src+1
        lda #<[text_screen+40+2]
        sta text_dst
        lda #>[text_screen+40+2]
        sta text_dst+1
        jsr copy_text
        lda battle_number
        clc
        adc #17
        sta text_screen+40+9
        lda #<s_turn
        sta text_src
        lda #>s_turn
        sta text_src+1
        lda #<[text_screen+40+14]
        sta text_dst
        lda #>[text_screen+40+14]
        sta text_dst+1
        jsr copy_text
        lda turn_number
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
        lda game_state
        beq ?playing
        cmp #1
        beq ?won
        lda #<s_lost
        sta text_src
        lda #>s_lost
        sta text_src+1
        jmp ?message
?won    lda #<s_won
        sta text_src
        lda #>s_won
        sta text_src+1
        jmp ?message
?playing
        ldx selected_unit
        lda unit_moved,x
        beq ?move
        lda #<s_last_action
        sta text_src
        lda #>s_last_action
        sta text_src+1
        jmp ?message
?move   lda #<s_move
        sta text_src
        lda #>s_move
        sta text_src+1
?message
        lda #<[text_screen+24*40]
        sta text_dst
        lda #>[text_screen+24*40]
        sta text_dst+1
        jmp copy_text
.endp

s_title       dta 22,d'HEROES OF LOWREZ  VBXE'
s_battle      dta 7,d'BATTLE '
s_turn        dta 5,d'TURN '
s_controls    dta 40,d'JOY CURSOR FIRE ACT SPACE SKIP 1/2 BATTLE'
s_move        dta 39,d'MOVE UP TO 2 HEXES OR ATTACK. R RESTART'
s_last_action dta 38,d'ONE STEP LEFT: MOVE ATTACK OR SKIP'
s_won         dta 34,d'VICTORY! R RESTART OR 1/2 BATTLE'
s_lost        dta 33,d'DEFEAT! R RESTART OR 1/2 BATTLE'
s_need_vbxe   dta 13,d'VBXE REQUIRED'

;==============================================================================
; Renderer
;==============================================================================
draw_cell_id dta 0
draw_unit_id dta 0
draw_colour dta 0
highlight_kind dta 0
draw_action dta 0
point_x     dta a(0)
point_y     dta 0
terrain_x   dta a(0)
terrain_y   dta 0
front_bank  dta 0
back_bank   dta 1
render_bank dta 0

.proc draw_everything
        jsr draw_status
        lda back_bank
        sta render_bank
        jsr copy_background_cache
        jsr draw_board
        jsr draw_trees
        jsr draw_units
        jsr draw_cursor
        jsr draw_hud
        jsr wait_blit
        jmp present_back_buffer
.endp

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
        lda #C_GRASS
        sta fr_col
        jmp fill_rect
.endp

.proc draw_terrain_background
        lda #0
        sta terrain_y
?row    lda #0
        sta terrain_x
        sta terrain_x+1
?column
        lda terrain_x
        sta calc_x
        lda terrain_x+1
        sta calc_x+1
        lda terrain_y
        sta calc_y
        jsr calc_addr
        lda #0
        sta bl_src
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
        lda terrain_y
        cmp #192
        bne ?full_height
        lda #7
        bne ?height
?full_height
        lda #31
?height sta bl_h
        lda #$FF
        sta bl_and
        lda #0
        sta bl_xor
        sta bl_mode
        jsr do_blit
        clc
        lda terrain_x
        adc #32
        sta terrain_x
        bcc ?x_no_carry
        inc terrain_x+1
?x_no_carry
        lda terrain_x+1
        cmp #>SCR_W
        bcs ?x_high_enough
        jmp ?column
?x_high_enough
        bne ?next_row
        lda terrain_x
        cmp #<SCR_W
        bcs ?next_row
        jmp ?column
?next_row
        clc
        lda terrain_y
        adc #32
        sta terrain_y
        cmp #SCR_H
        bcs ?done
        jmp ?row
?done
        rts
.endp

.proc cell_position
        ldx draw_cell_id
        lda cell_x_lo,x
        sta point_x
        lda cell_x_hi,x
        sta point_x+1
        lda cell_y,x
        sta point_y
        rts
.endp

.proc draw_board
        lda #0
        sta draw_cell_id
?cell  ldx draw_cell_id
        lda cell_row,x
        eor cell_col,x
        and #1
        clc
        adc #C_GRASS
        sta draw_colour
        lda draw_cell_id
        jsr action_at
        beq ?next
        sta draw_action
        lda #0
        sta highlight_kind
        lda draw_action
        cmp #1
        bne ?attack
        ldx selected_unit
        lda unit_moved,x
        beq ?move
        lda #1
        sta highlight_kind
?move
?attack
?base   jsr cell_position
        jsr draw_shadow_hex
?next
        inc draw_cell_id
        lda draw_cell_id
        cmp #CELLS
        bcc ?cell
        rts
.endp

.proc draw_shadow_hex
        lda point_x
        sec
        sbc #13
        sta calc_x
        lda point_x+1
        sbc #0
        sta calc_x+1
        lda point_y
        sec
        sbc #11
        sta calc_y
        jsr calc_addr
        lda #0
        sta bl_src
        lda highlight_kind
        beq ?light
        lda #$37                  ; second 768-byte hex slot
        bne ?source
?light  lda #$34                  ; assets.bin offset $3400
?source sta bl_src+1
        lda #ASSET_VBANK
        sta bl_src+2
        lda #26
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
        lda #25
        sta bl_w
        lda #0
        sta bl_w+1
        lda #21
        sta bl_h
        lda #$FF
        sta bl_and
        lda #0
        sta bl_xor
        lda #1                    ; transparent outside the hex
        sta bl_mode
        jmp do_blit
.endp

.proc draw_hex
        ; Wide middle and narrower caps make a low-resolution flat-top hex.
        lda point_x
        sec
        sbc #13
        sta calc_x
        lda point_x+1
        sbc #0
        sta calc_x+1
        lda point_y
        sec
        sbc #8
        sta calc_y
        lda #26
        ldx #16
        ldy draw_colour
        jsr small_fill
        lda point_x
        sec
        sbc #8
        sta calc_x
        lda point_x+1
        sbc #0
        sta calc_x+1
        lda point_y
        sec
        sbc #11
        sta calc_y
        lda #16
        ldx #3
        ldy draw_colour
        jsr small_fill
        lda point_y
        clc
        adc #8
        sta calc_y
        lda #16
        ldx #3
        ldy draw_colour
        jmp small_fill
.endp

.proc draw_trees
        lda #0
        sta draw_cell_id
?cell  ldx draw_cell_id
        lda terrain,x
        cmp #T_TREE
        bne ?next
        jsr cell_position
        lda point_x
        sec
        sbc #14
        sta calc_x
        lda point_x+1
        sbc #0
        sta calc_x+1
        lda point_y
        sec
        sbc #30
        sta calc_y
        lda draw_cell_id
        and #1
        clc
        adc #4
        jsr draw_sprite_frame
?next   inc draw_cell_id
        lda draw_cell_id
        cmp #CELLS
        bcc ?cell
        rts
.endp

.proc draw_units
        lda #0
        sta draw_unit_id
?unit  ldx draw_unit_id
        cpx unit_count
        bcs ?done
        lda unit_hp,x
        beq ?next
        lda animation_active
        beq ?normal_position
        lda draw_unit_id
        cmp animation_unit
        bne ?normal_position
        lda animation_x
        sta point_x
        lda #0
        sta point_x+1
        lda animation_y
        sta point_y
        jmp ?draw
?normal_position
        ldx draw_unit_id
        lda unit_cell,x
        sta draw_cell_id
        jsr cell_position
?draw
        jsr draw_one_unit
?next   inc draw_unit_id
        jmp ?unit
?done   rts
.endp

.proc draw_one_unit
        ; Use the same six-frame sheet as the web build.
        ldx draw_unit_id
        ldy unit_type,x
        lda sprite_frame_for_type,y
        sta sprite_frame
        cpx selected_unit
        bne ?position
        lda game_state
        bne ?position
        lda anim_frame
        and #1
        beq ?position
        dec point_y
        dec point_y
?position
        lda point_x
        sec
        sbc #14
        sta calc_x
        lda point_x+1
        sbc #0
        sta calc_x+1
        lda point_y
        sec
        sbc #30
        sta calc_y
        lda sprite_frame
        jsr draw_sprite_frame

        ; Small HP bar remains a native Atari overlay.
        lda point_x
        sec
        sbc #7
        sta calc_x
        lda point_x+1
        sbc #0
        sta calc_x+1
        lda point_y
        clc
        adc #13
        sta calc_y
        lda #14
        ldx #2
        ldy #C_BLACK
        jsr small_fill
        ldx draw_unit_id
        lda unit_hp,x
        asl
        cmp #14
        bcc ?hp
        lda #14
?hp     ldx #2
        ldy #C_HEALTH
        jsr small_fill
        lda attack_flash
        beq ?done
        lda draw_unit_id
        cmp attack_flash_target
        bne ?done
        lda point_x
        sec
        sbc #8
        sta calc_x
        lda point_x+1
        sbc #0
        sta calc_x+1
        lda point_y
        sec
        sbc #2
        sta calc_y
        lda #16
        ldx #3
        ldy #C_WHITE
        jsr small_fill
        lda point_x
        sec
        sbc #1
        sta calc_x
        lda point_x+1
        sbc #0
        sta calc_x+1
        lda point_y
        sec
        sbc #9
        sta calc_y
        lda #3
        ldx #18
        ldy #C_WHITE
        jsr small_fill
?done   rts
.endp

sprite_frame_for_type
        dta 0,1,2,3,2,2,2,2,1
sprite_frame dta 0

; A = frame 0..5, calc_x/calc_y = top-left. Pre-scaled web frame is 28x46.
.proc draw_sprite_frame
        asl
        asl
        asl
        clc
        adc #4                    ; assets.bin: 1024-byte terrain tile first
        sta bl_src+1
        lda #0
        sta bl_src
        lda #ASSET_VBANK
        sta bl_src+2
        lda #28
        sta bl_ssy
        lda #0
        sta bl_ssy+1
        lda #1
        sta bl_ssx
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
        lda #27
        sta bl_w
        lda #0
        sta bl_w+1
        lda #45
        sta bl_h
        lda #$FF
        sta bl_and
        lda #0
        sta bl_xor
        lda #1                    ; source colour zero is transparent
        sta bl_mode
        jmp do_blit
.endp

.proc draw_cursor
        lda cursor_cell
        sta draw_cell_id
        jsr cell_position
        lda cursor_cell
        jsr action_at
        cmp #2
        bne ?normal
        lda #C_ATTACK
        bne ?colour
?normal lda #C_WHITE
?colour sta draw_colour
        ; Four corner blocks around the cell.
        lda point_x
        sec
        sbc #15
        sta calc_x
        lda point_x+1
        sbc #0
        sta calc_x+1
        lda point_y
        sec
        sbc #11
        sta calc_y
        lda #6
        ldx #2
        ldy draw_colour
        jsr small_fill
        lda #2
        ldx #6
        ldy draw_colour
        jsr small_fill
        lda point_x
        clc
        adc #9
        sta calc_x
        lda point_x+1
        adc #0
        sta calc_x+1
        lda #6
        ldx #2
        ldy draw_colour
        jsr small_fill
        lda point_x
        clc
        adc #13
        sta calc_x
        lda point_x+1
        adc #0
        sta calc_x+1
        lda #2
        ldx #6
        ldy draw_colour
        jsr small_fill
        lda point_x
        sec
        sbc #15
        sta calc_x
        lda point_x+1
        sbc #0
        sta calc_x+1
        lda point_y
        clc
        adc #9
        sta calc_y
        lda #6
        ldx #2
        ldy draw_colour
        jsr small_fill
        lda point_y
        clc
        adc #5
        sta calc_y
        lda #2
        ldx #6
        ldy draw_colour
        jsr small_fill
        lda point_x
        clc
        adc #9
        sta calc_x
        lda point_x+1
        adc #0
        sta calc_x+1
        lda point_y
        clc
        adc #9
        sta calc_y
        lda #6
        ldx #2
        ldy draw_colour
        jsr small_fill
        lda point_x
        clc
        adc #13
        sta calc_x
        lda point_x+1
        adc #0
        sta calc_x+1
        lda point_y
        clc
        adc #5
        sta calc_y
        lda #2
        ldx #6
        ldy draw_colour
        jmp small_fill
.endp

; Original-style lower status strip: SKIP, move, damage, HP, and flag.
.proc draw_hud
        lda selected_unit
        sta hud_unit_id
        lda cursor_cell
        jsr unit_at
        bcc ?stats_ready
        stx hud_unit_id
?stats_ready
        lda #0
        sta calc_x
        sta calc_x+1
        lda #174
        sta calc_y
        lda #<SCR_W
        sta fr_w
        lda #>SCR_W
        sta fr_w+1
        lda #2
        sta fr_h
        lda #C_MOVE
        sta fr_col
        jsr fill_rect

        lda #4
        sta hud_x
        lda #0
        sta hud_x+1
        lda #181
        sta hud_y
        lda #<hud_skip
        sta text_src
        lda #>hud_skip
        sta text_src+1
        jsr draw_hud_text

        jsr draw_move_icon
        lda #86
        sta hud_x
        lda #0
        sta hud_x+1
        lda #181
        sta hud_y
        ldx hud_unit_id
        ldy unit_type,x
        lda type_move,y
        jsr draw_hud_glyph

        jsr draw_sword_icon
        lda #145
        sta hud_x
        lda #0
        sta hud_x+1
        lda #181
        sta hud_y
        ldx hud_unit_id
        ldy unit_type,x
        lda type_damage,y
        jsr draw_hud_glyph

        jsr draw_heart_icon
        lda #207
        sta hud_x
        lda #0
        sta hud_x+1
        lda #181
        sta hud_y
        ldx hud_unit_id
        lda unit_hp,x
        jsr draw_hud_glyph

        jsr draw_flag_icon
        lda #<265
        sta hud_x
        lda #1
        sta hud_x+1
        lda #181
        sta hud_y
        lda #<hud_flag
        sta text_src
        lda #>hud_flag
        sta text_src+1
        jmp draw_hud_text
.endp

hud_x dta a(0)
hud_y dta 0
hud_unit_id dta 0
hud_text_index dta 0
hud_glyph_bits dta 0
hud_glyph_row dta 0
hud_glyph_col dta 0

.proc draw_hud_text
        lda #0
        sta hud_text_index
?next   ldy hud_text_index
        lda (text_src),y
        cmp #$FF
        beq ?done
        jsr draw_hud_glyph
        clc
        lda hud_x
        adc #12
        sta hud_x
        bcc ?no_carry
        inc hud_x+1
?no_carry
        inc hud_text_index
        jmp ?next
?done   rts
.endp

; A = glyph number. Glyph rows contain three bits, drawn as 3x3 pixels.
.proc draw_hud_glyph
        tax
        lda hud_glyph_lo,x
        sta work_ptr
        lda hud_glyph_hi,x
        sta work_ptr+1
        lda #0
        sta hud_glyph_row
?row    ldy hud_glyph_row
        lda (work_ptr),y
        sta hud_glyph_bits
        lda #0
        sta hud_glyph_col
?column ldx hud_glyph_col
        lda hud_glyph_mask,x
        and hud_glyph_bits
        beq ?next_column
        ldx hud_glyph_col
        lda hud_x
        clc
        adc hud_glyph_x,x
        sta calc_x
        lda hud_x+1
        adc #0
        sta calc_x+1
        ldx hud_glyph_row
        lda hud_y
        clc
        adc hud_glyph_y,x
        sta calc_y
        lda #3
        ldx #3
        ldy #C_WHITE
        jsr small_fill
?next_column
        inc hud_glyph_col
        lda hud_glyph_col
        cmp #3
        bcc ?column
        inc hud_glyph_row
        lda hud_glyph_row
        cmp #5
        bcc ?row
        rts
.endp

.proc draw_move_icon
        lda #64
        sta calc_x
        lda #0
        sta calc_x+1
        lda #179
        sta calc_y
        lda #7
        ldx #8
        ldy #C_TREE
        jsr small_fill
        lda #59
        sta calc_x
        lda #186
        sta calc_y
        lda #17
        ldx #5
        ldy #C_TREE
        jmp small_fill
.endp

.proc draw_sword_icon
        lda #0
        sta icon_step
        lda #110
        sta icon_x
        lda #192
        sta icon_y
?blade  lda icon_x
        sta calc_x
        lda #0
        sta calc_x+1
        lda icon_y
        sta calc_y
        lda #3
        ldx #3
        ldy #C_WHITE
        jsr small_fill
        clc
        lda icon_x
        adc #3
        sta icon_x
        lda icon_y
        sec
        sbc #3
        sta icon_y
        inc icon_step
        lda icon_step
        cmp #5
        bcc ?blade
        lda #106
        sta calc_x
        lda #0
        sta calc_x+1
        lda #193
        sta calc_y
        lda #10
        ldx #3
        ldy #C_BOW
        jmp small_fill
.endp
icon_step dta 0
icon_x dta 0
icon_y dta 0

.proc draw_heart_icon
        lda #165
        sta calc_x
        lda #0
        sta calc_x+1
        lda #180
        sta calc_y
        lda #8
        ldx #7
        ldy #C_ATTACK
        jsr small_fill
        lda #175
        sta calc_x
        lda #8
        ldx #7
        ldy #C_ATTACK
        jsr small_fill
        lda #162
        sta calc_x
        lda #184
        sta calc_y
        lda #24
        ldx #7
        ldy #C_ATTACK
        jsr small_fill
        lda #168
        sta calc_x
        lda #191
        sta calc_y
        lda #12
        ldx #5
        ldy #C_ATTACK
        jmp small_fill
.endp

.proc draw_flag_icon
        lda #240
        sta calc_x
        lda #0
        sta calc_x+1
        lda #178
        sta calc_y
        lda #3
        ldx #18
        ldy #C_WHITE
        jsr small_fill
        lda #243
        sta calc_x
        lda #178
        sta calc_y
        lda #14
        ldx #8
        ldy #C_WHITE
        jmp small_fill
.endp

hud_skip dta 10,11,12,13,$FF
hud_flag dta 14,15,16,17,$FF
hud_glyph_mask dta 4,2,1
hud_glyph_x dta 0,3,6
hud_glyph_y dta 0,3,6,9,12

g0 dta 7,5,5,5,7
g1 dta 2,6,2,2,7
g2 dta 7,1,7,4,7
g3 dta 7,1,7,1,7
g4 dta 5,5,7,1,1
g5 dta 7,4,7,1,7
g6 dta 7,4,7,5,7
g7 dta 7,1,1,1,1
g8 dta 7,5,7,5,7
g9 dta 7,5,7,1,7
gs dta 7,4,7,1,7
gk dta 5,5,6,5,5
gi dta 7,2,2,2,7
gp dta 6,5,6,4,4
gf dta 7,4,6,4,4
gl dta 4,4,4,4,7
ga dta 2,5,7,5,5
gg dta 7,4,5,5,7
hud_glyph_lo
        dta <g0,<g1,<g2,<g3,<g4,<g5,<g6,<g7,<g8,<g9
        dta <gs,<gk,<gi,<gp,<gf,<gl,<ga,<gg
hud_glyph_hi
        dta >g0,>g1,>g2,>g3,>g4,>g5,>g6,>g7,>g8,>g9
        dta >gs,>gk,>gi,>gp,>gf,>gl,>ga,>gg

; A width, X height, Y colour; calc_x/calc_y is top-left.
.proc small_fill
        sta fr_w
        lda #0
        sta fr_w+1
        stx fr_h
        sty fr_col
        jmp fill_rect
.endp

;==============================================================================
; VBXE initialization and blitter (FX 1.2x)
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
asset_pages_left  dta 0

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

; Publish only after the hidden frame is complete and vertical blank begins.
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
        dta 0,   0,  0,  0
        dta 1,  63,132, 72
        dta 2,  68,139, 75
        dta 3,  43,103, 55
        dta 4,  27, 75, 39
        dta 5,  45, 55, 29
        dta 6,  20,126, 65
        dta 7, 192, 63, 47
        dta 8, 238,201,109
        dta 9, 172, 39, 46
        dta 10, 91, 24, 32
        dta 11,180,193,194
        dta 12, 48, 26, 65
        dta 13,245,241,199
        dta 14, 17, 24, 39
        dta 15,237,105,115
        dta 16,111,195,223
        dta 17,150,116, 61
        dta 18, 15, 37, 24
        icl 'asset-palette.inc'
        dta $FF

; Generic VBXE blitter block
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
; Generated tables and memory
;==============================================================================
        icl 'battle-data.inc'

display_list
        dta $42,a(text_screen)
        :24 dta $02
        dta $41,a(display_list)

        org $4000
asset_raw
        ins 'assets.bin'

        org $8000
text_screen
        :1000 dta 0

        run main
