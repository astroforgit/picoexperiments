;==============================================================================
; STREAMLINE STANDARD ATARI
;
; Atari XL/XE ANTIC 4 character-graphics port of Francois van Niekerk's Streamline.
; Rules and level data are derived from steamlinejs/orggame/orggame.js.
;
; Build:
;   mads streamline-atari.asm -o:streamline-atari.xex
;
; Controls:
;   joystick 0 / W A S D  move
;   fire / Space          switch line in Dual levels
;   U or Z / OPTION       undo
;   R / SELECT            restart level
;
; Adaptive large tiles, per-row RAM fonts and shaded five-colour ANTIC 4
; graphics, with no VBXE dependency.
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
SKSTAT   = $D20F
DMACTL   = $D400

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

MAX_MOVES = 255

; ---- zero page ---------------------------------------------------------------
level_ptr = $CB                ; 2
work_ptr  = $CD                ; 2
calc_out  = $CF                ; 3
calc_x    = calc_out
calc_y    = calc_out+1
text_src  = $D2                ; 2
text_dst  = $D4                ; 2
text_ptr  = text_dst
tile_src  = $D6                ; 2, source glyph pointer

        org $2000

;==============================================================================
; Program entry and frame loop
;==============================================================================
.proc main
        lda PORTB
        ora #2
        sta PORTB
        cld
        jsr setup_title
        jsr wait_title_start
        jsr setup_antic
        lda #0
        sta level_number
        lda STRIG0
        eor #1
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

; The ANTIC F picture lives in the row-font RAM, which gameplay will reuse.
.proc setup_title
        lda #0
        sta SDMCTL
        sta DMACTL
        sta $D40E
        sta $D01D
        lda #<title_display_list
        sta SDLSTL
        lda #>title_display_list
        sta SDLSTL+1
        lda #$E0
        sta CHBAS
        sta $D409
        lda #$0E
        sta COLOR1
        sta $D017             ; hi-res 1-bits use COLPF1 luminance
        lda #0
        sta COLOR2            ; hi-res 0-bits use COLPF2 color
        sta COLOR4
        sta $D018
        sta $D01A
        lda #$FF
        sta CH
        lda #$40               ; keep the OS VBI, no display interrupts
        sta $D40E
        lda #$22
        sta SDMCTL
        rts
.endp

.proc wait_title_start
?loop   jsr wait_frame
        lda STRIG0
        beq ?start
        lda CONSOL
        and #1                  ; START key
        beq ?start
        lda CH
        and #$3F
        cmp #$21               ; Space
        bne ?loop
?start  lda #$FF
        sta CH
        rts
.endp

;==============================================================================
; Input
;==============================================================================
.proc read_joystick
        lda PORTA
        and #15
        tax
        lda joystick_directions,x
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
        cmp #0                 ; CMP old_fire left Z clear on both edges
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
        bcs ?moved
        jsr draw_status
        rts
?moved
        jsr check_win
        jsr draw_everything
?done   rts
.endp

key_temp dta 0
old_stick dta 15
old_fire dta 0
old_console dta 7
; Normalize diagonal stick positions to one legal direction (horizontal wins).
; Opposite contacts cancel. Compare normalized values to avoid repeated moves
; when an analog stick wobbles between a cardinal direction and a diagonal.
joystick_directions dta 15,15,15,15,15,7,7,7,15,11,11,11,15,13,14,15

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
storage_full dta 0

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
        sta storage_full

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
?ok     ; Original player enumeration is column-major (x, then y).
        lda player_count
        cmp #2
        bne ?ordered
        lda path0
        sta current_index
        jsr index_to_xy
        lda current_x
        sta target_index
        lda path1
        sta current_index
        jsr index_to_xy
        lda current_x
        cmp target_index
        bcs ?ordered
        lda path0
        ldx path1
        sta path1
        stx path0
?ordered
        jsr draw_status
        rts
.endp

.proc next_level
        inc level_number
        lda level_number
        cmp #LEVEL_COUNT
        bcc ?load
        lda #1
        sta game_complete
        jsr clear_board
        jsr draw_status
        rts
?load   jsr maybe_story_pause
        jsr init_level
        jmp draw_everything
.endp

story_page_index dta 0
story_pages_left dta 0
story_line_len dta 0

; A break is keyed by the number of boards already completed. Its pages are
; compiled from story_pauses.json, so further breaks need no new game logic.
.proc maybe_story_pause
        ldx #0
?scan   cpx #STORY_BREAK_TOTAL
        bcs ?done
        lda story_break_level,x
        cmp level_number
        beq ?found
        inx
        bne ?scan
?found  lda story_break_first,x
        sta story_page_index
        lda story_break_pages,x
        sta story_pages_left
        jsr setup_story
?page   ldx story_page_index
        lda story_page_lo,x
        sta text_src
        lda story_page_hi,x
        sta text_src+1
        jsr render_story_page
        jsr wait_story_continue
        inc story_page_index
        dec story_pages_left
        bne ?page
        jsr setup_antic
        lda #0
        sta cached_width        ; the story overwrote the board screen
        lda STRIG0
        eor #1
        sta old_fire
        lda CONSOL
        and #7
        sta old_console
        lda #$FF
        sta CH
?done   rts
.endp

.proc setup_story
        lda #0
        sta SDMCTL
        sta DMACTL
        sta $D40E
        lda #<story_display_list
        sta SDLSTL
        lda #>story_display_list
        sta SDLSTL+1
        lda #>story_font
        sta CHBAS
        sta $D409
        lda #$0E               ; pale, high-contrast lettering
        sta COLOR1
        sta $D017
        lda #0
        sta COLOR2
        sta COLOR4
        sta $D018
        sta $D01A
        lda #$40               ; OS VBI only; board DLIs are off
        sta $D40E
        rts
.endp

; Page data is a sequence of [row, column, length, screen codes], ending $FF.
.proc render_story_page
        ldx #0
        lda #0
        sta SDMCTL
        sta DMACTL
?clear  sta text_screen,x
        sta text_screen+$100,x
        sta text_screen+$200,x
        cpx #192
        bcs ?skip
        sta text_screen+$300,x
?skip   inx
        bne ?clear
?record jsr read_story_byte
        cmp #$FF
        beq ?done
        tax
        lda #<text_screen
        sta text_dst
        lda #>text_screen
        sta text_dst+1
?row    cpx #0
        beq ?column
        clc
        lda text_dst
        adc #40
        sta text_dst
        bcc ?next_row
        inc text_dst+1
?next_row
        dex
        bne ?row
?column jsr read_story_byte
        clc
        adc text_dst
        sta text_dst
        bcc ?length
        inc text_dst+1
?length jsr read_story_byte
        sta story_line_len
?char   jsr read_story_byte
        ldy #0
        sta (text_dst),y
        inc text_dst
        bne ?count
        inc text_dst+1
?count  dec story_line_len
        bne ?char
        jmp ?record
?done   lda #$22
        sta SDMCTL            ; reveal only the complete page
        rts
.endp

.proc read_story_byte
        ldy #0
        lda (text_src),y
        inc text_src
        bne ?done
        inc text_src+1
?done   rts
.endp

; Every page needs a release followed by a fresh press. CH alone cannot
; detect a held Space key: the OS can repeat it on the next page.
.proc wait_story_continue
?release
        jsr wait_frame
        lda #$FF
        sta CH
        lda STRIG0
        beq ?release
        lda CONSOL
        and #1
        beq ?release
        lda SKSTAT
        and #$04               ; active low while a key is held
        beq ?release
        lda #$FF
        sta CH
?press  jsr wait_frame
        lda STRIG0
        beq ?done
        lda CONSOL
        and #1
        beq ?done
        lda CH
        and #$3F
        cmp #$21               ; Space
        bne ?press
?done   lda #$FF
        sta CH
        rts
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
        lda #0
        sta storage_full
        lda history_count
        cmp #MAX_MOVES
        bcc ?room
        jmp ?capacity
?room
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
        bcs ?appended
        jmp ?rollback
?appended
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
        bcs ?after_portal
        jmp ?rollback
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
?rollback
        ldx active_player
        lda before_len
        sta path_len,x
?capacity
        lda #1
        sta storage_full
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
        sta storage_full
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
        lda #0
        sta SDMCTL
        sta DMACTL
        sta $D40E
        sta $D01D
        sta dli_index
        lda #<display_list
        sta SDLSTL
        lda #>display_list
        sta SDLSTL+1
        lda #$E0               ; ROM text for the status area
        sta CHBAS
        sta $D409
        lda #$0C
        sta COLOR1
        lda #$02
        sta COLOR2
        lda #0
        sta COLOR4
        lda #<display_interrupt
        sta $0200
        lda #>display_interrupt
        sta $0201
        lda #<frame_interrupt
        sta $0224              ; deferred VBI, OS preserves A/X/Y
        lda #>frame_interrupt
        sta $0225
        lda #$C0               ; OS VBI plus display-list interrupts
        sta $D40E
        ldx #0
        lda #0
?clear  sta text_screen,x
        sta text_screen+$100,x
        sta text_screen+$200,x
        sta text_screen+$300,x
        inx
        bne ?clear
        lda #$22
        sta SDMCTL
        ; The OS starts DMA with the new display list at the next VBI.
        rts
.endp

; Re-anchor the font/palette sequence every frame, including the first one.
.proc frame_interrupt
        lda #0
        sta dli_index
        jmp $E462              ; OS XITVBV restores registers and returns
.endp

; Each ANTIC 4 row selects a private font and its shade of the palette.
; The final interrupt restores ROM characters and the status background.
.proc display_interrupt
        pha
        txa
        pha
        ldx dli_index
        lda font_pages,x
        sta $D40A              ; WSYNC, change before the next row is fetched
        sta $D409
        lda dli_blue,x
        sta $D018
        lda dli_copper,x
        sta $D019
        lda dli_stone,x
        sta $D016
        inc dli_index
        lda dli_index
        cmp #21
        bcc ?done
        lda #0
        sta dli_index
?done   pla
        tax
        pla
        rti
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
?c      sta status_screen,x
        sta status_screen+40,x
        sta status_screen+80,x
        sta status_screen+120,x
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
        lda #<[status_screen+11]
        sta text_dst
        lda #>[status_screen+11]
        sta text_dst+1
        jsr copy_text

        lda #<s_level
        sta text_src
        lda #>s_level
        sta text_src+1
        lda #<[status_screen+1*40+2]
        sta text_dst
        lda #>[status_screen+1*40+2]
        sta text_dst+1
        jsr copy_text
        lda level_number
        clc
        adc #1
        lda #<[status_screen+1*40+8]
        sta text_dst
        lda #>[status_screen+1*40+8]
        sta text_dst+1
        lda level_number
        clc
        adc #1
        cmp #LEVEL_COUNT+1
        bcc ?level_digits
        lda #LEVEL_COUNT
?level_digits
        jsr draw_2digits

        lda #<s_of_57
        sta text_src
        lda #>s_of_57
        sta text_src+1
        lda #<[status_screen+1*40+10]
        sta text_dst
        lda #>[status_screen+1*40+10]
        sta text_dst+1
        jsr copy_text

        lda #<s_moves
        sta text_src
        lda #>s_moves
        sta text_src+1
        lda #<[status_screen+1*40+16]
        sta text_dst
        lda #>[status_screen+1*40+16]
        sta text_dst+1
        jsr copy_text
        lda #<[status_screen+1*40+22]
        sta text_dst
        lda #>[status_screen+1*40+22]
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
        lda #<[status_screen+1*40+29]
        sta text_dst
        lda #>[status_screen+1*40+29]
        sta text_dst+1
        jsr copy_text
        lda active_player
        clc
        adc #17                ; screen-code digit 1/2
        sta status_screen+1*40+35

?controls
        lda #<s_controls
        sta text_src
        lda #>s_controls
        sta text_src+1
        lda #<[status_screen+80]
        sta text_dst
        lda #>[status_screen+80]
        sta text_dst+1
        jsr copy_text

        lda game_complete
        bne ?all_done
        lda game_won
        bne ?won
        lda storage_full
        beq ?hint
        lda #<s_full
        sta text_src
        lda #>s_full
        sta text_src+1
        jmp ?message
?hint
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
        lda #<[status_screen+120]
        sta text_dst
        lda #>[status_screen+120]
        sta text_dst+1
        jsr copy_text
        jmp publish_status
.endp

; Stage text off-screen, then write only bytes that actually changed.
.proc publish_status
        ldx #39
?next   lda status_screen,x
        cmp text_screen,x
        beq ?row1
        sta text_screen,x
?row1   lda status_screen+40,x
        cmp text_screen+40,x
        beq ?row2
        sta text_screen+40,x
?row2   lda status_screen+80,x
        cmp text_screen+22*40,x
        beq ?row3
        sta text_screen+22*40,x
?row3   lda status_screen+120,x
        cmp text_screen+23*40,x
        beq ?step
        sta text_screen+23*40,x
?step   dex
        bpl ?next
        rts
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
s_title dta s_title_end-s_title-1,d'STREAMLINE: TRUNK!'
s_title_end
s_level dta s_level_end-s_level-1,d'LEVEL '
s_level_end
s_of_57 dta s_of_57_end-s_of_57-1,d'/57 '
s_of_57_end
s_moves dta s_moves_end-s_moves-1,d'MOVES '
s_moves_end
s_dual dta s_dual_end-s_dual-1,d'TRUNK /2'
s_dual_end
s_controls dta s_controls_end-s_controls-1,d'JOY MOVE  FIRE SWITCH  U UNDO  R RESTART'
s_controls_end
s_hint dta s_hint_end-s_hint-1,d'REACH THE RING. REVERSE TO UNDO.'
s_hint_end
s_full dta s_full_end-s_full-1,d'TRUNK MEMORY FULL: UNDO OR RESTART. '
s_full_end
s_won dta s_won_end-s_won-1,d'LEVEL COMPLETE! NEXT LEVEL IN A MOMENT'
s_won_end
s_all_done dta s_all_done_end-s_all_done-1,d'ALL 57 LEVELS COMPLETE! FIRE TO REPLAY.'
s_all_done_end

;==============================================================================
;==============================================================================
; Standard Atari text-mode board renderer
;==============================================================================
; Square 1x1, 2x2 or 3x3 character tiles; ANTIC pixels have 2:1 aspect. Each visible character has
; private glyph bytes in its row's font. No glyph-cache eviction is needed.
; Colour 3 selects blue or copper per character; DLIs provide the shading.
cached_width dta 0
cached_height dta 0
board_x dta 0
board_y dta 0
board_w dta 0
board_h dta 0
tile_cols dta 2
tile_rows dta 1
zoom dta 0
tile_col dta 0
tile_row dta 0
copy_row dta 0
copy_col dta 0
copy_rows_left dta 0
copy_cols_left dta 0
tile_colour dta 0
frame_row dta 0
frame_col dta 0
palette_phase dta 0
dli_index dta 0
font_pages dta $40,$44,$48,$4C,$50,$54,$58,$5C,$60,$64,$68,$6C,$80,$84,$88,$8C,$90,$94,$98,$9C,$E0
dli_blue :20 dta $9C
        dta $02
dli_copper :20 dta $18
        dta $28
dli_stone :20 dta $04
        dta $06
gradient_blue dta $9C,$9A,$98
gradient_copper dta $1A,$18,$16
gradient_stone dta $04,$04,$04
screen_row_lo dta <[text_screen+80],<[text_screen+120],<[text_screen+160],<[text_screen+200],<[text_screen+240],<[text_screen+280],<[text_screen+320],<[text_screen+360],<[text_screen+400],<[text_screen+440],<[text_screen+480],<[text_screen+520],<[text_screen+560],<[text_screen+600],<[text_screen+640],<[text_screen+680],<[text_screen+720],<[text_screen+760],<[text_screen+800],<[text_screen+840]
screen_row_hi dta >[text_screen+80],>[text_screen+120],>[text_screen+160],>[text_screen+200],>[text_screen+240],>[text_screen+280],>[text_screen+320],>[text_screen+360],>[text_screen+400],>[text_screen+440],>[text_screen+480],>[text_screen+520],>[text_screen+560],>[text_screen+600],>[text_screen+640],>[text_screen+680],>[text_screen+720],>[text_screen+760],>[text_screen+800],>[text_screen+840]
; Earth-coloured obstacles and keys; blue goals, portals and elephants.
tile_attributes dta 0,0,0,$80,$80,0,$80,0,$80,$80,$80,$80,$80,$80,$80
        :20 dta 0
; Outgoing neighbour mask: up=1, right=2, down=4, left=8.
elephant_faces dta 31,33,34,31,31,31,31,31,32
draw_x dta 0
draw_y dta 0
draw_index dta 0
render_start dta 0
render_pos dta 0
render_player dta 0
render_cell dta 0
render_mask dta 0
render_colour dta 0
neighbour dta 0

.proc draw_everything
        lda active_player
        sta saved_active
        jsr draw_status
        lda level_width
        cmp cached_width
        bne ?layout
        lda level_height
        cmp cached_height
        beq ?compose
?layout jsr calculate_board
        jsr clear_board
        lda level_width
        sta cached_width
        lda level_height
        sta cached_height
?compose
        ; Compose terrain and both elephants in RAM, never erase a visible
        ; trunk with terrain as an intermediate step.
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
        jmp flush_tiles
.endp

; Publish each changed tile once; leave the other glyphs and frame untouched.
.proc flush_tiles
        lda #0
        sta draw_index
?cell   ldx draw_index
        lda next_tiles,x
        cmp cached_tiles,x
        bne ?changed
        lda next_colours,x
        cmp cached_colours,x
        beq ?next
?changed
        lda next_tiles,x
        sta cached_tiles,x
        lda next_colours,x
        sta cached_colours,x
        sta render_colour
        stx current_index
        jsr calculate_point_position
        ldx draw_index
        lda next_tiles,x
        jsr put_tile
?next   inc draw_index
        lda draw_index
        cmp level_cells
        bcc ?cell
        rts
.endp

.proc calculate_board
        lda #0
        sta zoom
        lda #1
        sta tile_cols
        lda #1
        sta tile_rows
        lda level_width
        cmp #10
        bcs ?size
        lda level_height
        cmp #10
        bcs ?size
        inc zoom
        lda #2
        sta tile_cols
        lda #2
        sta tile_rows
        lda level_width
        cmp #7
        bcs ?size
        lda level_height
        cmp #7
        bcs ?size
        inc zoom
        lda #3
        sta tile_cols
        lda #3
        sta tile_rows
?size   lda #0
        ldx level_width
?width  clc
        adc tile_cols
        dex
        bne ?width
        sta board_w
        lda #40
        sec
        sbc board_w
        lsr
        sta board_x
        lda #0
        ldx level_height
?height clc
        adc tile_rows
        dex
        bne ?height
        sta board_h
        lda #20
        sec
        sbc board_h
        lsr
        sta board_y
        lda #0
        sta palette_phase
        ldx #0
?shade  ldy palette_phase
        lda gradient_blue,y
        sta dli_blue,x
        lda gradient_copper,y
        sta dli_copper,x
        lda gradient_stone,y
        sta dli_stone,x
        txa
        cmp board_y
        bcc ?next
        inc palette_phase
        lda palette_phase
        cmp tile_rows
        bcc ?next
        lda #0
        sta palette_phase
?next   inx
        cpx #20
        bne ?shade
        rts
.endp

.proc clear_board
        ldx #0
        lda #$FF
?invalidate
        sta cached_tiles,x
        inx
        bne ?invalidate
        lda #0
        sta cached_width
        lda #0
        sta frame_row
?row    ldx frame_row
        lda font_pages,x
        sta work_ptr+1
        lda #0
        sta work_ptr
        ldy #0
?clear  sta (work_ptr),y
        iny
        bne ?clear
        inc work_ptr+1
        ldy #63
?tail   sta (work_ptr),y
        dey
        bpl ?tail
        dec work_ptr+1
        lda screen_row_lo,x
        sta text_ptr
        lda screen_row_hi,x
        sta text_ptr+1
        lda #0
        sta frame_col
?column lda frame_col
        ora #$80
        ldy #0
        sta (text_ptr),y
        lda frame_row
        beq ?top
        cmp #19
        beq ?bottom
        lda frame_col
        beq ?left
        cmp #39
        beq ?right
        jmp ?advance
?top    lda #$FF
        sta (work_ptr),y
        iny
        lda #$AA
        sta (work_ptr),y
        jmp ?advance
?bottom ldy #6
        lda #$55
        sta (work_ptr),y
        iny
        lda #$FF
        sta (work_ptr),y
        jmp ?advance
?left   lda #$E0
        bne ?edge
?right  lda #$0B
?edge   ldy #7
?stripe sta (work_ptr),y
        dey
        bpl ?stripe
?advance
        clc
        lda work_ptr
        adc #8
        sta work_ptr
        bcc ?screen
        inc work_ptr+1
?screen inc text_ptr
        bne ?count
        inc text_ptr+1
?count  inc frame_col
        lda frame_col
        cmp #40
        bcc ?column
        inc frame_row
        lda frame_row
        cmp #20
        bcs ?done
        jmp ?row
?done   rts
.endp

.proc draw_terrain
        lda #0
        sta draw_index
?cell   lda draw_index
        jsr cell_type_at
        cmp #CT_LOCK
        bne ?draw
        jsr is_key_collected
        lda #CT_LOCK
        bcc ?draw
        lda #14
?draw   ldx draw_index
        sta next_tiles,x
        lda #0
        sta next_colours,x
        inc draw_index
        lda draw_index
        cmp level_cells
        bcc ?cell
        rts
.endp

; current_index -> adaptive character coordinates inside the board area.
.proc calculate_point_position
        jsr index_to_xy
        lda board_x
        ldx current_x
        beq ?x_done
?x      clc
        adc tile_cols
        dex
        bne ?x
?x_done sta tile_col
        lda board_y
        ldx current_y
        beq ?y_done
?y      clc
        adc tile_rows
        dex
        bne ?y
?y_done sta tile_row
        rts
.endp

; A = tile 0..34. Copy glyphs into the row fonts and select character colours.
.proc put_tile
        tax
        lda tile_attributes,x
        ora render_colour
        sta tile_colour
        lda zoom
        beq ?small
        cmp #1
        beq ?medium
        lda tile_large_lo,x
        sta tile_src
        lda tile_large_hi,x
        jmp ?source
?medium lda tile_medium_lo,x
        sta tile_src
        lda tile_medium_hi,x
        jmp ?source
?small  lda tile_small_lo,x
        sta tile_src
        lda tile_small_hi,x
?source sta tile_src+1
        lda tile_row
        sta copy_row
        lda tile_rows
        sta copy_rows_left
?row    ldx copy_row
        lda tile_col
        asl
        asl
        asl
        sta work_ptr
        lda font_pages,x
        adc #0
        sta work_ptr+1
        clc
        lda screen_row_lo,x
        adc tile_col
        sta text_ptr
        lda screen_row_hi,x
        adc #0
        sta text_ptr+1
        lda tile_col
        sta copy_col
        lda tile_cols
        sta copy_cols_left
?char   lda copy_col
        ora tile_colour
        ldy #0
        sta (text_ptr),y
?pixels lda (tile_src),y
        sta (work_ptr),y
        iny
        cpy #8
        bcc ?pixels
        clc
        lda tile_src
        adc #8
        sta tile_src
        bcc ?dest
        inc tile_src+1
?dest   clc
        lda work_ptr
        adc #8
        sta work_ptr
        bcc ?screen
        inc work_ptr+1
?screen inc text_ptr
        bne ?next
        inc text_ptr+1
?next   inc copy_col
        dec copy_cols_left
        bne ?char
        inc copy_row
        dec copy_rows_left
        bne ?row
        rts
.endp

.proc draw_player
        sta render_player
        sta active_player
        lda #0
        sta render_colour
        sta render_start
        sta render_pos
        lda render_player
        beq ?scan
        lda #$80
        sta render_colour
?scan   ldx render_player
        lda render_pos
        cmp path_len,x
        bcs ?begin
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
?begin  lda render_start
        sta render_pos
?point  ldx render_player
        lda render_pos
        cmp path_len,x
        bcs ?done
        tax
        lda render_player
        jsr get_player_path_x
        sta render_cell
        sta current_index
        jsr index_to_xy
        lda #0
        sta render_mask
        lda render_pos
        cmp render_start
        beq ?following
        tax
        dex
        lda render_player
        jsr get_player_path_x
        jsr connect_neighbour
?following
        ldx render_player
        lda render_pos
        clc
        adc #1
        cmp path_len,x
        bcs ?tile
        tax
        lda render_player
        jsr get_player_path_x
        jsr connect_neighbour
?tile   lda render_mask
        clc
        adc #15
        ldx render_pos
        cpx render_start
        bne ?store
        ldx render_mask        ; face the first visible trunk segment
        lda elephant_faces,x
?store  ldx render_cell
        sta next_tiles,x
        lda render_colour
        sta next_colours,x
        inc render_pos
        jmp ?point
?done   rts
.endp

; Connect only orthogonally adjacent cells; never bridge a portal jump.
.proc connect_neighbour
        sta neighbour
        lda render_cell
        sec
        sbc level_width
        bcc ?down
        cmp neighbour
        bne ?down
        lda #1
        bne ?add
?down   lda render_cell
        clc
        adc level_width
        cmp neighbour
        bne ?horizontal
        lda #4
        bne ?add
?horizontal
        lda current_x
        beq ?right
        lda render_cell
        sec
        sbc #1
        cmp neighbour
        bne ?right
        lda #8
        bne ?add
?right  lda current_x
        clc
        adc #1
        cmp level_width
        bcs ?done
        lda render_cell
        clc
        adc #1
        cmp neighbour
        bne ?done
        lda #2
?add    ora render_mask
        sta render_mask
?done   rts
.endp

; Generated levels and memory
;==============================================================================
        icl 'levels-standard.inc'

        .align $100
display_list
        dta $70,$70,$70
        dta $42,a(text_screen)
        dta $82              ; first DLI selects the board font
        :20 dta $84           ; one DLI per character row
        :2 dta $02
        dta $41,a(display_list)

title_display_list
        dta $70,$70,$70
        dta $4F,a(title_bitmap)
        :95 dta $0F
        dta $4F,a(title_bitmap+$1000)
        :79 dta $0F
        dta $42,a(title_prompt)
        dta $02
        dta $41,a(title_display_list)

title_prompt
        dta d'          PRESS FIRE TO START           '
        :40 dta 0

story_display_list
        dta $70,$70,$70
        dta $42,a(text_screen)
        :23 dta $02
        dta $41,a(story_display_list)

        ert * > $4000
        org $4000
row_fonts_low
title_bitmap
        ins 'title-screen.bin'
        :$3000-(*-row_fonts_low) dta 0

        org $7000
text_screen
        :1000 dta 0

        org $7400
path0   :256 dta 0
path1   :256 dta 0

        org $7600
history_player :MAX_MOVES dta 0
history_length :MAX_MOVES dta 0

        org $7800
next_tiles :256 dta 0
next_colours :256 dta 0
cached_tiles :256 dta 0
cached_colours :256 dta 0

        org $7D00
status_screen :160 dta 0

        org $8000
row_fonts_high :$2000 dta 0

        org $A000
        icl 'tiles.inc'
        ert * > $B400

        org $B400
story_font
        ins 'story-font.bin'
        org $B800
        icl 'story-pages.inc'
        ert * > $C000

        run main
