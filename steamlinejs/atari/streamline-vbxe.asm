;==============================================================================
; STREAMLINE VBXE
;
; Atari XL/XE + VBXE port of Francois van Niekerk's Streamline.
; Rules and level data are derived from steamlinejs/orggame/orggame.js.
;
; Build:
;   mads streamline-vbxe.asm -o:streamline-vbxe.xex
;
; Controls:
;   joystick 0 / W A S D  move
;   fire / Space          switch line in Dual levels
;   U or Z / OPTION       undo
;   R / SELECT            restart level
;
; The game uses a 320x200, 256-colour VBXE overlay. ANTIC supplies the status
; text underneath transparent overlay colour 0. All game graphics are rendered
; by the VBXE blitter; no external graphics files are required.
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

; ---- VBXE FX 1.2x register page (relocated to $D7 when necessary) ------------
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

; ---- original CellType values ------------------------------------------------
CT_EMPTY   = 0
CT_START   = 1
CT_END     = 2
CT_WALL    = 3
CT_PAUSE   = 4
CT_RESET   = 5
CT_TRAP    = 6
CT_PORTAL  = 7
CT_FORCE_U = 8
CT_FORCE_R = 9
CT_FORCE_D = 10
CT_FORCE_L = 11
CT_LOCK    = 12
CT_KEY     = 13

DIR_UP    = 0
DIR_RIGHT = 1
DIR_DOWN  = 2
DIR_LEFT  = 3

CELL_SIZE = 11
MAX_MOVES = 128

; ---- VBXE palette indices -----------------------------------------------------
C_BOARD      = 1
C_BOARD_ALT  = 2
C_GRID       = 3
C_WALL       = 4
C_WALL_EDGE  = 5
C_PLAYER0    = 6
C_PLAYER0_HI = 7
C_PLAYER1    = 8
C_PLAYER1_HI = 9
C_END        = 10
C_PAUSE      = 11
C_RESET      = 12
C_TRAP       = 13
C_PORTAL     = 14
C_FORCE      = 15
C_LOCK       = 16
C_KEY        = 17
C_WHITE      = 18
C_SHADOW     = 19

; ---- zero page ---------------------------------------------------------------
level_ptr = $CB                ; 2
work_ptr  = $CD                ; 2
calc_out  = $CF                ; 3
text_src  = $D2                ; 2
text_dst  = $D4                ; 2

        org $2000

;==============================================================================
; Program entry and frame loop
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
        lda #<[text_screen+12*40+10]
        sta text_dst
        lda #>[text_screen+12*40+10]
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
        jsr load_palette
        jsr enable_display

        lda #0
        sta level_number
        sta old_fire
        lda #15
        sta old_stick
        sta old_console
        lda #$FF
        sta CH
        jsr init_level
        jsr draw_everything

?loop   jsr wait_frame
        lda game_complete
        bne ?complete_input
        lda game_won
        beq ?playing
        lda STRIG0
        beq ?next
        lda CH
        and #$3F
        cmp #$21               ; Space
        beq ?next
        lda win_timer
        beq ?next
        dec win_timer
        jmp ?loop
?next   lda #$FF
        sta CH
        jsr next_level
        jmp ?loop

?complete_input
        lda STRIG0
        beq ?restart_all
        lda CH
        and #$3F
        cmp #$28               ; R
        bne ?loop
?restart_all
        lda #0
        sta level_number
        sta game_complete
        jsr init_level
        jsr draw_everything
        jmp ?loop

?playing
        jsr read_joystick
        jsr read_console
        jsr read_keyboard
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
        lda #DIR_UP
        jsr do_direction
        jmp ?fire
?down   cmp #13
        bne ?left
        lda #DIR_DOWN
        jsr do_direction
        jmp ?fire
?left   cmp #11
        bne ?right
        lda #DIR_LEFT
        jsr do_direction
        jmp ?fire
?right  cmp #7
        bne ?fire
        lda #DIR_RIGHT
        jsr do_direction

?fire   lda STRIG0
        eor #1
        cmp old_fire
        beq ?done
        sta old_fire
        beq ?done
        jsr switch_player
        jsr draw_everything
?done   rts
.endp

.proc read_console
        lda CONSOL
        and #7
        cmp old_console
        beq ?done
        sta old_console
        and #4                  ; OPTION
        bne ?select
        jsr undo_move
        bcc ?done
        jsr draw_everything
        rts
?select lda old_console
        and #2                  ; SELECT
        bne ?done
        jsr init_level
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
        cmp #$2E               ; W
        bne ?a
        lda #DIR_UP
        jmp do_direction
?a      cmp #$3F               ; A
        bne ?s
        lda #DIR_LEFT
        jmp do_direction
?s      cmp #$3E               ; S
        bne ?d
        lda #DIR_DOWN
        jmp do_direction
?d      cmp #$3A               ; D
        bne ?undo
        lda #DIR_RIGHT
        jmp do_direction
?undo   cmp #$0B               ; U
        beq ?do_undo
        cmp #$17               ; Z
        bne ?reset
?do_undo
        jsr undo_move
        bcc ?done
        jmp draw_everything
?reset  cmp #$28               ; R
        bne ?switch
        jsr init_level
        jmp draw_everything
?switch cmp #$21               ; Space
        bne ?done
        jsr switch_player
        jmp draw_everything
?done   rts
.endp

.proc do_direction
        sta move_dir
        jsr can_reverse_undo
        bcc ?move
        jsr undo_move
        bcc ?done
        jsr draw_everything
        rts
?move   jsr player_move
        bcc ?done
        jsr check_win
        jsr draw_everything
?done   rts
.endp

key_temp dta 0
old_stick dta 15
old_fire dta 0
old_console dta 7

;==============================================================================
; Level and game state
;==============================================================================
level_number dta 0
level_width  dta 0
level_height dta 0
level_cells  dta 0
player_count dta 0
active_player dta 0
path_len dta 1,1
history_count dta 0
game_won dta 0
game_complete dta 0
win_timer dta 0

move_dir dta 0
move_steps dta 0
before_len dta 0
current_index dta 0
next_index dta 0
current_x dta 0
current_y dta 0
target_index dta 0
scan_player dta 0
scan_pos dta 0
portal_entry dta 0
saved_active dta 0

.proc init_level
        ldx level_number
        lda level_ptr_lo,x
        sta level_ptr
        lda level_ptr_hi,x
        sta level_ptr+1
        ldy #0
        lda (level_ptr),y
        sta level_width
        iny
        lda (level_ptr),y
        sta level_height

        lda #0
        sta player_count
        sta active_player
        sta history_count
        sta game_won
        sta game_complete
        sta win_timer

        ; level_cells = width * height (all supplied levels stay below 256)
        lda #0
        ldx level_height
?mul    clc
        adc level_width
        dex
        bne ?mul
        sta level_cells

        ldx #0
?scan   txa
        jsr cell_type_at
        cmp #CT_START
        bne ?next
        lda player_count
        beq ?p0
        txa
        sta path1
        lda #1
        sta path_len+1
        inc player_count
        jmp ?next
?p0     txa
        sta path0
        lda #1
        sta path_len
        inc player_count
?next   inx
        cpx level_cells
        bne ?scan
        lda player_count
        bne ?ok
        lda #1                 ; corrupt level guard
        sta player_count
        sta path_len
        lda #0
        sta path0
?ok     jsr draw_status
        rts
.endp

.proc next_level
        inc level_number
        lda level_number
        cmp #LEVEL_COUNT
        bcc ?load
        lda #1
        sta game_complete
        jsr clear_framebuffer
        jsr draw_status
        rts
?load   jsr init_level
        jmp draw_everything
.endp

.proc switch_player
        lda player_count
        cmp #2
        bcc ?done
        lda active_player
        eor #1
        sta active_player
?done   rts
.endp

; A = linear cell index, returns A = cell type.
.proc cell_type_at
        tay
        iny
        iny
        lda (level_ptr),y
        rts
.endp

; Load active player's head into A.
.proc get_head
        ldx active_player
        lda path_len,x
        tax
        dex
        lda active_player
        bne ?p1
        lda path0,x
        rts
?p1     lda path1,x
        rts
.endp

; A = path position, returns active player's cell index.
.proc get_active_path
        tax
        lda active_player
        bne ?p1
        lda path0,x
        rts
?p1     lda path1,x
        rts
.endp

; A = cell index. Append to active path. C=1 on success.
.proc append_active_path
        sta next_index
        ldx active_player
        lda path_len,x
        cmp #$FF
        beq ?full
        tax
        lda active_player
        bne ?p1
        lda next_index
        sta path0,x
        jmp ?inc
?p1     lda next_index
        sta path1,x
?inc    ldx active_player
        inc path_len,x
        sec
        rts
?full   clc
        rts
.endp

; A = player (0/1), X = path position. Returns path cell in A.
.proc get_player_path_x
        cmp #0
        bne ?p1
        lda path0,x
        rts
?p1     lda path1,x
        rts
.endp

; Convert current_index into current_x/current_y.
.proc index_to_xy
        lda current_index
        ldx #0
?row    cmp level_width
        bcc ?ready
        sec
        sbc level_width
        inx
        bne ?row
?ready  sta current_x
        stx current_y
        rts
.endp

; Uses current_index/current_x/current_y/move_dir. C=1 and A=next index.
.proc compute_next
        lda move_dir
        beq ?up
        cmp #DIR_RIGHT
        beq ?right
        cmp #DIR_DOWN
        beq ?down
        ; left
        lda current_x
        beq ?blocked
        dec current_x
        dec current_index
        lda current_index
        sec
        rts
?right  lda current_x
        clc
        adc #1
        cmp level_width
        bcs ?blocked
        sta current_x
        inc current_index
        lda current_index
        sec
        rts
?up     lda current_y
        beq ?blocked
        dec current_y
        lda current_index
        sec
        sbc level_width
        sta current_index
        sec
        rts
?down   lda current_y
        clc
        adc #1
        cmp level_height
        bcs ?blocked
        sta current_y
        lda current_index
        clc
        adc level_width
        sta current_index
        sec
        rts
?blocked
        clc
        rts
.endp

; A = cell index, C=1 if terrain can be entered.
.proc is_navigable
        sta target_index
        jsr cell_type_at
        cmp #CT_WALL
        beq ?no
        cmp #CT_LOCK
        bne ?yes
        jsr is_key_collected
        rts
?yes    sec
        rts
?no     clc
        rts
.endp

; A = cell index, C=1 if it belongs to any active body after its latest RESET.
.proc has_body
        sta target_index
        lda #0
        sta scan_player
?player ldx scan_player
        lda path_len,x
        beq ?next_player
        sec
        sbc #1
        sta scan_pos
?cell   ldx scan_pos
        lda scan_player
        jsr get_player_path_x
        cmp target_index
        beq ?found
        jsr cell_type_at
        cmp #CT_RESET
        beq ?next_player
        lda scan_pos
        beq ?next_player
        dec scan_pos
        jmp ?cell
?next_player
        inc scan_player
        lda scan_player
        cmp player_count
        bcc ?player
        clc
        rts
?found  sec
        rts
.endp

; C=1 if any complete path (including before RESET) contains a key.
.proc is_key_collected
        lda #0
        sta scan_player
?player ldx scan_player
        lda path_len,x
        sta scan_pos
        lda #0
        sta target_index
?cell   lda target_index
        cmp scan_pos
        bcs ?next_player
        tax
        lda scan_player
        jsr get_player_path_x
        jsr cell_type_at
        cmp #CT_KEY
        beq ?yes
        inc target_index
        jmp ?cell
?next_player
        inc scan_player
        lda scan_player
        cmp player_count
        bcc ?player
        clc
        rts
?yes    sec
        rts
.endp

; portal_entry is one portal. C=1/A=the other portal if available.
.proc find_other_portal
        ldx #0
?scan   txa
        cmp portal_entry
        beq ?next
        jsr cell_type_at
        cmp #CT_PORTAL
        beq ?found
?next   inx
        cpx level_cells
        bne ?scan
        clc
        rts
?found  txa
        sec
        rts
.endp

; C=1 if move_dir points at the immediately previous path cell.
.proc can_reverse_undo
        ldx active_player
        lda path_len,x
        cmp #2
        bcc ?no
        jsr get_head
        sta current_index
        jsr index_to_xy
        jsr compute_next
        bcc ?no
        sta target_index
        ldx active_player
        lda path_len,x
        sec
        sbc #2
        jsr get_active_path
        cmp target_index
        bne ?no
        sec
        rts
?no     clc
        rts
.endp

; Original orggame movement: slide until wall/body/END/PAUSE/TRAP. PORTAL jumps
; to its pair and continues. FORCER changes direction without ending the move.
.proc player_move
        jsr get_head
        jsr cell_type_at
        cmp #CT_END
        bne ?not_end
        jmp ?failed
?not_end
        cmp #CT_TRAP
        bne ?can_start
        jmp ?failed
?can_start

        ldx active_player
        lda path_len,x
        sta before_len
        lda #0
        sta move_steps
        jsr get_head
        sta current_index
        jsr index_to_xy

?step   jsr compute_next
        bcc ?finish
        sta next_index
        jsr is_navigable
        bcc ?finish
        lda next_index
        jsr has_body
        bcs ?finish
        lda next_index
        jsr append_active_path
        bcc ?finish
        inc move_steps

        lda next_index
        jsr cell_type_at
        cmp #CT_PORTAL
        bne ?after_portal
        lda next_index
        sta portal_entry
        jsr find_other_portal
        bcc ?after_portal
        sta next_index
        jsr is_navigable
        bcc ?after_portal
        lda next_index
        jsr has_body
        bcs ?after_portal
        lda next_index
        jsr append_active_path
        bcc ?after_portal
?after_portal
        jsr get_head
        sta current_index
        jsr index_to_xy
        lda current_index
        jsr cell_type_at
        cmp #CT_END
        beq ?finish
        cmp #CT_PAUSE
        beq ?finish
        cmp #CT_TRAP
        beq ?finish
        cmp #CT_FORCE_U
        bcc ?step
        cmp #CT_LOCK
        bcs ?step
        sec
        sbc #CT_FORCE_U
        sta move_dir
        jmp ?step

?finish lda move_steps
        beq ?failed
        ldx history_count
        cpx #MAX_MOVES
        bcs ?history_full
        lda active_player
        sta history_player,x
        lda before_len
        sta history_length,x
        inc history_count
?history_full
        jsr auto_select_player
        sec
        rts
?failed clc
        rts
.endp

; Undo is global, exactly like Grid.undoLastMove(): restore the player that made
; the most recent move and truncate that player's path to its saved length.
.proc undo_move
        lda history_count
        beq ?none
        dec history_count
        ldx history_count
        lda history_player,x
        sta active_player
        tay
        lda history_length,x
        sta path_len,y
        lda #0
        sta game_won
        sec
        rts
?none   clc
        rts
.endp

.proc auto_select_player
        jsr get_head
        jsr cell_type_at
        cmp #CT_END
        bne ?done
        lda player_count
        cmp #2
        bcc ?done
        lda active_player
        eor #1
        sta scan_player
        sta active_player
        jsr get_head
        jsr cell_type_at
        cmp #CT_END
        bne ?done
        lda scan_player
        eor #1
        sta active_player
?done   rts
.endp

.proc check_win
        lda active_player
        sta saved_active
        lda #0
        sta scan_player
?p      lda scan_player
        sta active_player
        jsr get_head
        jsr cell_type_at
        cmp #CT_END
        bne ?not
        inc scan_player
        lda scan_player
        cmp player_count
        bcc ?p
        lda #1
        sta game_won
        lda #45
        sta win_timer
        lda #0
        sta active_player
        sec
        rts
?not    lda saved_active
        sta active_player
        clc
        rts
.endp

;==============================================================================
; Screen text
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

; text_src points to [length, screen-code bytes], text_dst is destination.
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

.proc clear_status_rows
        ldx #39
        lda #0
?c      sta text_screen,x
        sta text_screen+40,x
        sta text_screen+23*40,x
        sta text_screen+24*40,x
        dex
        bpl ?c
        rts
.endp

.proc draw_status
        jsr clear_status_rows
        lda #<s_title
        sta text_src
        lda #>s_title
        sta text_src+1
        lda #<[text_screen+11]
        sta text_dst
        lda #>[text_screen+11]
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
        lda level_number
        clc
        adc #1
        lda #<[text_screen+40+8]
        sta text_dst
        lda #>[text_screen+40+8]
        sta text_dst+1
        lda level_number
        clc
        adc #1
        jsr draw_2digits

        lda #<s_of_56
        sta text_src
        lda #>s_of_56
        sta text_src+1
        lda #<[text_screen+40+10]
        sta text_dst
        lda #>[text_screen+40+10]
        sta text_dst+1
        jsr copy_text

        lda #<s_moves
        sta text_src
        lda #>s_moves
        sta text_src+1
        lda #<[text_screen+40+16]
        sta text_dst
        lda #>[text_screen+40+16]
        sta text_dst+1
        jsr copy_text
        lda #<[text_screen+40+22]
        sta text_dst
        lda #>[text_screen+40+22]
        sta text_dst+1
        lda history_count
        jsr draw_3digits

        lda player_count
        cmp #2
        bcc ?controls
        lda #<s_dual
        sta text_src
        lda #>s_dual
        sta text_src+1
        lda #<[text_screen+40+29]
        sta text_dst
        lda #>[text_screen+40+29]
        sta text_dst+1
        jsr copy_text
        lda active_player
        clc
        adc #17                ; screen-code digit 1/2
        sta text_screen+40+34

?controls
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
        bne ?all_done
        lda game_won
        bne ?won
        lda #<s_hint
        sta text_src
        lda #>s_hint
        sta text_src+1
        jmp ?message
?won    lda #<s_won
        sta text_src
        lda #>s_won
        sta text_src+1
        jmp ?message
?all_done
        lda #<s_all_done
        sta text_src
        lda #>s_all_done
        sta text_src+1
?message
        lda #<[text_screen+24*40]
        sta text_dst
        lda #>[text_screen+24*40]
        sta text_dst+1
        jmp copy_text
.endp

; A 0..99 -> two Atari screen-code digits at text_dst.
.proc draw_2digits
        ldx #0
?tens   cmp #10
        bcc ?store
        sec
        sbc #10
        inx
        bne ?tens
?store  pha
        txa
        clc
        adc #16
        ldy #0
        sta (text_dst),y
        pla
        clc
        adc #16
        iny
        sta (text_dst),y
        rts
.endp

; A 0..255 -> three Atari screen-code digits at text_dst.
.proc draw_3digits
        ldx #0
?hund   cmp #100
        bcc ?tens_start
        sec
        sbc #100
        inx
        bne ?hund
?tens_start
        pha
        txa
        clc
        adc #16
        ldy #0
        sta (text_dst),y
        pla
        ldx #0
?tens   cmp #10
        bcc ?ones
        sec
        sbc #10
        inx
        bne ?tens
?ones   pha
        txa
        clc
        adc #16
        iny
        sta (text_dst),y
        pla
        clc
        adc #16
        iny
        sta (text_dst),y
        rts
.endp

; MADS d'...' emits Atari screen codes.
s_title      dta 16,d'STREAMLINE  VBXE'
s_level      dta 6,d'LEVEL '
s_of_56      dta 4,d'/56 '
s_moves      dta 6,d'MOVES '
s_dual       dta 8,d'LINE  /2'
s_controls   dta 40,d'JOY MOVE  FIRE SWITCH  U UNDO  R RESTART'
s_hint       dta 40,d'REACH PURPLE. REVERSE DIRECTION TO UNDO.'
s_won        dta 38,d'LEVEL COMPLETE! NEXT LEVEL IN A MOMENT'
s_all_done   dta 39,d'ALL 56 LEVELS COMPLETE! FIRE TO REPLAY.'
s_need_vbxe  dta 13,d'VBXE REQUIRED'

;==============================================================================
; Board renderer
;==============================================================================
board_x dta a(0)
board_y dta 0
board_w dta a(0)
board_h dta 0
tile_x dta a(0)
tile_y dta 0
draw_x dta 0
draw_y dta 0
draw_index dta 0
draw_type dta 0
render_start dta 0
render_pos dta 0
render_prev dta 0
render_player dta 0
player_colour dta 0
player_highlight dta 0
point_x dta a(0)
point_y dta 0
prev_x dta a(0)
prev_y dta 0

.proc draw_everything
        lda active_player
        sta saved_active
        jsr draw_status
        jsr clear_framebuffer
        jsr calculate_board
        jsr draw_board_base
        jsr draw_terrain
        lda #0
        jsr draw_player
        lda player_count
        cmp #2
        bcc ?done
        lda #1
        jsr draw_player
?done   lda saved_active
        sta active_player
        jmp wait_blit
.endp

.proc calculate_board
        ; board_w = width*11
        lda #0
        sta board_w
        sta board_w+1
        ldx level_width
?wmul   clc
        lda board_w
        adc #CELL_SIZE
        sta board_w
        bcc ?wnc
        inc board_w+1
?wnc    dex
        bne ?wmul
        ; x = (320-board_w)/2
        lda #<SCR_W
        sec
        sbc board_w
        sta board_x
        lda #>SCR_W
        sbc board_w+1
        sta board_x+1
        lsr board_x+1
        ror board_x

        lda #0
        sta board_h
        ldx level_height
?hmul   clc
        adc #CELL_SIZE
        dex
        bne ?hmul
        sta board_h
        lda #SCR_H
        sec
        sbc board_h
        lsr
        sta board_y
        rts
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
        lda #0
        sta fr_col
        jmp fill_rect
.endp

.proc draw_board_base
        lda board_x
        clc
        adc #2
        sta calc_x
        lda board_x+1
        adc #0
        sta calc_x+1
        lda board_y
        clc
        adc #2
        sta calc_y
        lda board_w
        sta fr_w
        lda board_w+1
        sta fr_w+1
        lda board_h
        sta fr_h
        lda #C_SHADOW
        sta fr_col
        jsr fill_rect
        lda board_x
        sta calc_x
        lda board_x+1
        sta calc_x+1
        lda board_y
        sta calc_y
        lda #C_BOARD
        sta fr_col
        jmp fill_rect
.endp

.proc draw_terrain
        lda #0
        sta draw_y
        sta draw_index
?row    lda #0
        sta draw_x
?cell   lda draw_index
        jsr cell_type_at
        sta draw_type
        jsr calculate_tile_position
        lda draw_type
        cmp #CT_WALL
        beq ?wall
        cmp #CT_END
        beq ?end
        cmp #CT_PAUSE
        beq ?pause
        cmp #CT_RESET
        beq ?reset
        cmp #CT_TRAP
        beq ?trap
        cmp #CT_PORTAL
        beq ?portal
        cmp #CT_FORCE_U
        bcc ?next
        cmp #CT_LOCK
        bcc ?forcer
        cmp #CT_LOCK
        beq ?lock
        cmp #CT_KEY
        beq ?key
        jmp ?next
?wall   jsr draw_wall
        jmp ?next
?end    jsr draw_end
        jmp ?next
?pause  jsr draw_pause
        jmp ?next
?reset  jsr draw_reset
        jmp ?next
?trap   jsr draw_trap
        jmp ?next
?portal jsr draw_portal
        jmp ?next
?forcer jsr draw_forcer
        jmp ?next
?lock   jsr draw_lock
        jmp ?next
?key    jsr draw_key
?next   inc draw_index
        inc draw_x
        lda draw_x
        cmp level_width
        bcc ?cell
        inc draw_y
        lda draw_y
        cmp level_height
        bcs ?done
        jmp ?row
?done
        rts
.endp

.proc calculate_tile_position
        lda board_x
        sta tile_x
        lda board_x+1
        sta tile_x+1
        ldx draw_x
        beq ?y
?xadd   clc
        lda tile_x
        adc #CELL_SIZE
        sta tile_x
        bcc ?xnc
        inc tile_x+1
?xnc    dex
        bne ?xadd
?y      lda board_y
        ldx draw_y
        beq ?store_y
?yadd   clc
        adc #CELL_SIZE
        dex
        bne ?yadd
?store_y
        sta tile_y
        rts
.endp

; Set calc to tile + A (x inset), Y (y inset).
.proc set_tile_calc
        clc
        adc tile_x
        sta calc_x
        lda tile_x+1
        adc #0
        sta calc_x+1
        tya
        clc
        adc tile_y
        sta calc_y
        rts
.endp

; A=width, X=height, Y=colour. Uses current calc_x/calc_y.
.proc small_fill
        sta fr_w
        lda #0
        sta fr_w+1
        stx fr_h
        sty fr_col
        jmp fill_rect
.endp

.proc draw_wall
        lda #1
        ldy #1
        jsr set_tile_calc
        lda #9
        ldx #9
        ldy #C_WALL
        jsr small_fill
        lda #2
        ldy #2
        jsr set_tile_calc
        lda #7
        ldx #2
        ldy #C_WALL_EDGE
        jmp small_fill
.endp

.proc draw_end
        lda #1
        ldy #1
        jsr set_tile_calc
        lda #9
        ldx #9
        ldy #C_END
        jsr small_fill
        lda #3
        ldy #3
        jsr set_tile_calc
        lda #5
        ldx #5
        ldy #C_BOARD
        jmp small_fill
.endp

.proc draw_pause
        lda #2
        ldy #2
        jsr set_tile_calc
        lda #2
        ldx #7
        ldy #C_PAUSE
        jsr small_fill
        lda #7
        ldy #2
        jsr set_tile_calc
        lda #2
        ldx #7
        ldy #C_PAUSE
        jmp small_fill
.endp

.proc draw_reset
        lda #1
        ldy #1
        jsr set_tile_calc
        lda #9
        ldx #9
        ldy #C_RESET
        jsr small_fill
        lda #3
        ldy #3
        jsr set_tile_calc
        lda #5
        ldx #5
        ldy #C_BOARD
        jsr small_fill
        lda #5
        ldy #1
        jsr set_tile_calc
        lda #4
        ldx #2
        ldy #C_RESET
        jmp small_fill
.endp

.proc draw_trap
        lda #2
        ldy #2
        jsr set_tile_calc
        lda #2
        ldx #2
        ldy #C_TRAP
        jsr small_fill
        lda #7
        ldy #2
        jsr set_tile_calc
        lda #2
        ldx #2
        ldy #C_TRAP
        jsr small_fill
        lda #4
        ldy #4
        jsr set_tile_calc
        lda #3
        ldx #3
        ldy #C_TRAP
        jsr small_fill
        lda #2
        ldy #7
        jsr set_tile_calc
        lda #2
        ldx #2
        ldy #C_TRAP
        jsr small_fill
        lda #7
        ldy #7
        jsr set_tile_calc
        lda #2
        ldx #2
        ldy #C_TRAP
        jmp small_fill
.endp

.proc draw_portal
        lda #1
        ldy #1
        jsr set_tile_calc
        lda #9
        ldx #9
        ldy #C_PORTAL
        jsr small_fill
        lda #3
        ldy #3
        jsr set_tile_calc
        lda #5
        ldx #5
        ldy #C_BOARD
        jsr small_fill
        lda #5
        ldy #4
        jsr set_tile_calc
        lda #1
        ldx #3
        ldy #C_PORTAL
        jmp small_fill
.endp

.proc draw_forcer
        lda #4
        ldy #4
        jsr set_tile_calc
        lda #3
        ldx #3
        ldy #C_FORCE
        jsr small_fill
        lda draw_type
        sec
        sbc #CT_FORCE_U
        beq ?up
        cmp #DIR_RIGHT
        beq ?right
        cmp #DIR_DOWN
        beq ?down
        lda #1
        ldy #5
        jsr set_tile_calc
        lda #4
        ldx #1
        ldy #C_FORCE
        jmp small_fill
?right  lda #6
        ldy #5
        jsr set_tile_calc
        lda #4
        ldx #1
        ldy #C_FORCE
        jmp small_fill
?up     lda #5
        ldy #1
        jsr set_tile_calc
        lda #1
        ldx #4
        ldy #C_FORCE
        jmp small_fill
?down   lda #5
        ldy #6
        jsr set_tile_calc
        lda #1
        ldx #4
        ldy #C_FORCE
        jmp small_fill
.endp

.proc draw_lock
        jsr is_key_collected
        bcc ?locked
        ldy #C_RESET
        bne ?draw
?locked ldy #C_LOCK
?draw   sty fr_col
        lda #2
        ldy #4
        jsr set_tile_calc
        lda #7
        ldx #5
        ldy fr_col
        jsr small_fill
        lda #3
        ldy #1
        jsr set_tile_calc
        lda #5
        ldx #4
        ldy fr_col
        jmp small_fill
.endp

.proc draw_key
        lda #2
        ldy #3
        jsr set_tile_calc
        lda #5
        ldx #5
        ldy #C_KEY
        jsr small_fill
        lda #6
        ldy #5
        jsr set_tile_calc
        lda #3
        ldx #2
        ldy #C_KEY
        jsr small_fill
        lda #7
        ldy #7
        jsr set_tile_calc
        lda #2
        ldx #2
        ldy #C_KEY
        jmp small_fill
.endp

; A = player index.
.proc draw_player
        sta render_player
        sta active_player
        beq ?p0col
        lda #C_PLAYER1
        sta player_colour
        lda #C_PLAYER1_HI
        sta player_highlight
        jmp ?find_reset
?p0col  lda #C_PLAYER0
        sta player_colour
        lda #C_PLAYER0_HI
        sta player_highlight

?find_reset
        lda #0
        sta render_start
        sta render_pos
        ldx render_player
        lda path_len,x
        sta scan_pos
?scan   lda render_pos
        cmp scan_pos
        bcs ?draw_begin
        tax
        lda render_player
        jsr get_player_path_x
        jsr cell_type_at
        cmp #CT_RESET
        bne ?scan_next
        lda render_pos
        sta render_start
?scan_next
        inc render_pos
        jmp ?scan

?draw_begin
        lda render_start
        sta render_pos
        lda #$FF
        sta render_prev
?point  ldx render_player
        lda render_pos
        cmp path_len,x
        bcs ?done
        tax
        lda render_player
        jsr get_player_path_x
        sta current_index
        jsr calculate_point_position
        lda render_prev
        cmp #$FF
        beq ?dot
        jsr draw_connection
?dot    lda point_x
        sec
        sbc #3
        sta calc_x
        lda point_x+1
        sbc #0
        sta calc_x+1
        lda point_y
        sec
        sbc #3
        sta calc_y
        lda #6
        ldx #6
        ldy player_colour
        jsr small_fill
        lda current_index
        sta render_prev
        lda point_x
        sta prev_x
        lda point_x+1
        sta prev_x+1
        lda point_y
        sta prev_y
        inc render_pos
        jmp ?point

?done   ; redraw head larger and brighter
        lda current_index
        jsr calculate_point_position
        lda point_x
        sec
        sbc #4
        sta calc_x
        lda point_x+1
        sbc #0
        sta calc_x+1
        lda point_y
        sec
        sbc #4
        sta calc_y
        lda #8
        ldx #8
        ldy player_highlight
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
        sbc #1
        sta calc_y
        lda #2
        ldx #2
        ldy #C_WHITE
        jsr small_fill
        lda render_player
        cmp active_player
        rts
.endp

; current_index -> point_x/point_y at cell centre.
.proc calculate_point_position
        jsr index_to_xy
        lda board_x
        clc
        adc #5
        sta point_x
        lda board_x+1
        adc #0
        sta point_x+1
        ldx current_x
        beq ?y
?xa     clc
        lda point_x
        adc #CELL_SIZE
        sta point_x
        bcc ?xnc
        inc point_x+1
?xnc    dex
        bne ?xa
?y      lda board_y
        clc
        adc #5
        ldx current_y
        beq ?ys
?ya     clc
        adc #CELL_SIZE
        dex
        bne ?ya
?ys     sta point_y
        rts
.endp

.proc draw_connection
        ; Portal jumps are deliberately not connected.
        lda point_y
        cmp prev_y
        bne ?vertical
        lda point_x+1
        cmp prev_x+1
        beq ?horizontal_same_page
        rts
?horizontal_same_page
        lda point_x
        sec
        sbc prev_x
        cmp #CELL_SIZE
        beq ?h_prev
        eor #$FF
        clc
        adc #1
        cmp #CELL_SIZE
        bne ?done
        lda point_x
        jmp ?h_common
?h_prev lda prev_x
?h_common
        sec
        sbc #1
        sta calc_x
        lda point_x+1
        sbc #0
        sta calc_x+1
        lda point_y
        sec
        sbc #2
        sta calc_y
        lda #14
        ldx #4
        ldy player_colour
        jmp small_fill

?vertical
        lda point_x
        cmp prev_x
        bne ?done
        lda point_x+1
        cmp prev_x+1
        bne ?done
        lda point_y
        sec
        sbc prev_y
        cmp #CELL_SIZE
        beq ?v_prev
        eor #$FF
        clc
        adc #1
        cmp #CELL_SIZE
        bne ?done
        lda point_y
        jmp ?v_common
?v_prev lda prev_y
?v_common
        sec
        sbc #1
        sta calc_y
        lda point_x
        sec
        sbc #2
        sta calc_x
        lda point_x+1
        sbc #0
        sta calc_x+1
        lda #4
        ldx #14
        ldy player_colour
        jmp small_fill
?done   rts
.endp

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
        dta a(do_blit.vbreg_blit_bank+2),a(do_blit.vbreg_start+2)
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
        rts
.endp

xdl_data
        dta $74,$08             ; 8 transparent overscan lines
        dta 7
        dta $00,$00,$00
        dta $40,$01
        dta $11,$FF
        dta $62,$88             ; 320x200 graphics overlay, palette 1
        dta SCR_H-1
        dta $00,$00,$00
        dta $40,$01
        dta $11,$FF
xdl_len = *-xdl_data

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
        dta 1,  17, 25, 46
        dta 2,  20, 30, 52
        dta 3,  35, 47, 73
        dta 4,  41, 54, 81
        dta 5,  67, 84,120
        dta 6, 255, 61,154
        dta 7, 255,141,197
        dta 8,  63,216,255
        dta 9, 151,235,255
        dta 10,173, 92,255
        dta 11, 63,216,255
        dta 12, 85,242,195
        dta 13,255, 90,114
        dta 14, 61,157,255
        dta 15,255,188, 74
        dta 16,226,155, 58
        dta 17,255,222, 92
        dta 18,255,255,255
        dta 19,  5,  8, 18
        dta $FF

; ---- generic VBXE blitter block ---------------------------------------------
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
        lda #0
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
; Generated levels and memory
;==============================================================================
        icl 'levels.inc'

display_list
        dta $42,a(text_screen)
        :24 dta $02
        dta $41,a(display_list)

        org $7000
text_screen
        :1000 dta 0

        org $7400
path0   :256 dta 0
path1   :256 dta 0

        org $7600
history_player :MAX_MOVES dta 0
history_length :MAX_MOVES dta 0

        run main
