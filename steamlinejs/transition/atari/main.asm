; ---------------------------------------------------------------------------
; TRANSITION - Atari XL/XE edition
; Native 6502 program, assembled with MADS 2.x
;
; Based on transition.txt by NinaBirb. The display/build structure follows
; atari/sokoban-3d, which remains an unchanged reference project.
; ---------------------------------------------------------------------------

        opt h+

; OS shadow registers
SDMCTL  = $022f
SDLSTL  = $0230
COLOR0  = $02c4
COLOR1  = $02c5
COLOR2  = $02c6
COLOR3  = $02c7
COLBK   = $02c8
PCOLR0  = $02c0
PCOLR1  = $02c1
PCOLR2  = $02c2
PCOLR3  = $02c3
GPRIOR  = $026f
CHBAS   = $02f4
STICK0  = $0278
STRIG0  = $0284
ATRACT  = $004d
RTCLOK2 = $0014
CH      = $02fc

; Hardware registers
AUDF1   = $d200
AUDC1   = $d201
SKSTAT  = $d20f
CONSOL  = $d01f
PRIOR   = $d01b
NMIEN   = $d40e

; Entity collision layer
E_NONE     = 0
E_WALL1    = 1
E_WALL2    = 2
E_GWALL    = 3
E_LOCK1    = 4
E_LOCK2    = 5
E_GLOCK    = 6
E_PLAYER1  = 7
E_PLAYER2  = 8
E_GPLAYER  = 9
E_PPLAYER1 = 10
E_PPLAYER2 = 11
E_CRATE1   = 12
E_CRATE2   = 13
E_GCRATE   = 14
E_PCRATE1  = 15
E_PCRATE2  = 16
E_KEY1     = 17
E_KEY2     = 18
E_GKEY     = 19
E_PKEY1    = 20
E_PKEY2    = 21
E_DEAD1    = 22
E_DEAD2    = 23
E_GDEAD    = 24

; Persistent spawn layer
S_NONE   = 0
S_WALL1  = 1
S_WALL2  = 2
S_LOCK1  = 3
S_LOCK2  = 4
S_KEY1   = 5
S_KEY2   = 6
S_CRATE1 = 7
S_CRATE2 = 8
S_DEAD1  = 9
S_DEAD2  = 10

; Floor layer bits
F_TARGET = 1
F_DEATH  = 2
F_FLAG   = 4
F_NFLAG  = 8

; GTIA mode 10 palette indexes. Blue and gray deliberately have separate,
; fixed registers: blue marks the immutable/purple family and player clothing,
; while gray is reserved for inactive players.
P_DARK   = 0
P_ORANGE = 1
P_WHITE  = 2
P_BLUE   = 3
P_GRAY   = 4
P_GREEN1 = 5
P_GREEN2 = 6
P_YELLOW = 7
P_BROWN  = 8
P_TRANS  = $ff

WALL_EDGE_TOP    = 1
WALL_EDGE_BOTTOM = 2
WALL_EDGE_LEFT   = 4
WALL_EDGE_RIGHT  = 8

SCREEN       = $8000
CHARSET      = $8400
DLIST_TEXT   = $8800
DLIST_GAME   = $8900
DLIST_TITLE  = $8a00
GAME_SCREEN1 = $4000
GAME_SCREEN2 = $5000
GAME_SCREEN3 = $6000
TITLE_BITMAP = $7000
DESCRIPTION_TEXT = $7a00
GAME_SCREEN1_END = GAME_SCREEN1+$0a00
GAME_SCREEN2_END = GAME_SCREEN2+$0a00
ENTITY_GRID  = $9000
SPAWN_GRID   = $9200
FLOOR_GRID   = $9400
UNDO_GRID    = $9600
VISIBLE_ENTITY = $9800
VISIBLE_FLOOR  = $9900
VISIBLE_DIRTY  = $9a00

BOARD_W = 26
BOARD_H = 13
ROOM_W  = 13
CELL_COUNT = 338
SPRITE_W = 6
SPRITE_H = 7
SPRITE_SIZE = SPRITE_W*SPRITE_H
BOARD_X = 1
BOARD_Y = 5
GAME_ROW_BYTES = 40
LEVEL_COUNT = 21
DESCRIPTION_PAGE_COUNT = 5

; Zero-page pointers
str_ptr    = $80
dest_ptr   = $82
cell_ptr   = $84
source_ptr = $86
floor_ptr  = $88

        org $2000

Start
        sei
        lda #0
        sta SDMCTL
        sta AUDC1
        jsr InitCharset
        mwa #DLIST_TEXT SDLSTL
        lda #>CHARSET
        sta CHBAS
        lda #$c0
        sta NMIEN
        lda #$22
        sta SDMCTL
        cli

        jsr RunTitleMenu
        lda #0
        sta level_no

BeginLevel
        jsr ShowIntro
        jsr WaitFire
        jsr ResetLevel

MainLoop
        jsr WaitFrame
        jsr UpdateMoveSound
        lda #0
        sta ATRACT
        jsr ReadKeyboard
        jsr ReadConsole
        jsr ReadJoystick
        jmp MainLoop

; ---------------------------------------------------------------------------
; Input
; ---------------------------------------------------------------------------

ReadKeyboard
        lda CH
        cmp #$ff
        beq rk_done
        pha
        lda #$ff
        sta CH
        pla
        and #$3f
        cmp #$17                ; Z
        bne rk_reset
        jsr UndoMove
        rts
rk_reset
        cmp #$28                ; R
        bne rk_up
        jsr ResetLevel
        rts
rk_up
        cmp #$0e                ; cursor up
        bne rk_down
        lda #0
        jsr TryMove
        rts
rk_down
        cmp #$0f
        bne rk_left
        lda #1
        jsr TryMove
        rts
rk_left
        cmp #$06
        bne rk_right
        lda #2
        jsr TryMove
        rts
rk_right
        cmp #$07
        bne rk_done
        lda #3
        jsr TryMove
rk_done
        rts

ReadConsole
        lda CONSOL
        cmp #7
        bne rc_pressed
        lda #0
        sta console_latch
        rts
rc_pressed
        lda console_latch
        bne rc_done
        lda #1
        sta console_latch
        lda CONSOL
        and #4                  ; OPTION
        bne rc_select
        jsr UndoMove
        rts
rc_select
        lda CONSOL
        and #2                  ; SELECT
        bne rc_done
        jsr ResetLevel
rc_done
        rts

ReadJoystick
        lda input_delay
        beq rj_ready
        dec input_delay
rj_ready
        lda STICK0
        cmp #15
        bne rj_direction
        lda #0
        sta input_delay
        rts
rj_direction
        ldx input_delay
        bne rj_done
        ldx #1                  ; repeat every frame; renderer remains synchronized
        stx input_delay
        cmp #14
        bne rj_down
        lda #0
        jsr TryMove
        rts
rj_down
        cmp #13
        bne rj_left
        lda #1
        jsr TryMove
        rts
rj_left
        cmp #11
        bne rj_right
        lda #2
        jsr TryMove
        rts
rj_right
        cmp #7
        bne rj_done
        lda #3
        jsr TryMove
rj_done
        rts

; ---------------------------------------------------------------------------
; Movement and push chains
; ---------------------------------------------------------------------------

TryMove
        sta direction
        tax
        lda player_x
        clc
        adc dx_table,x
        sta next_x
        lda player_y
        clc
        adc dy_table,x
        sta next_y
        lda next_x
        cmp #BOARD_W
        bcc tm_y_in_bounds
        jmp tm_blocked
tm_y_in_bounds
        lda next_y
        cmp #BOARD_H
        bcc tm_get_destination
        jmp tm_blocked

tm_get_destination
        ldx next_x
        ldy next_y
        jsr GetEntity
        sta scan_entity
        bne tm_destination_occupied
        jmp tm_walk
tm_destination_occupied
        jsr IsPushable
        bcs tm_begin_scan
        jmp tm_blocked

tm_begin_scan
        lda #0
        sta chain_len
        lda next_x
        sta scan_x
        lda next_y
        sta scan_y
tm_scan
        ldx scan_x
        ldy scan_y
        jsr GetEntity
        sta scan_entity
        bne tm_scan_occupied
        jmp tm_push
tm_scan_occupied
        jsr IsPushable
        bcc tm_scan_blocker
        ldx chain_len
        lda scan_x
        sta chain_x,x
        lda scan_y
        sta chain_y,x
        lda scan_entity
        sta chain_entity,x
        inc chain_len
        ldx direction
        lda scan_x
        clc
        adc dx_table,x
        sta scan_x
        lda scan_y
        clc
        adc dy_table,x
        sta scan_y
        lda scan_x
        cmp #BOARD_W
        bcc tm_scan_y_bounds
        jmp tm_blocked
tm_scan_y_bounds
        lda scan_y
        cmp #BOARD_H
        bcc tm_scan
        jmp tm_blocked

tm_scan_blocker
        lda scan_entity
        jsr IsLock
        bcs tm_have_lock
        jmp tm_blocked
tm_have_lock
        ldx chain_len
        bne tm_have_chain
        jmp tm_blocked
tm_have_chain
        dex
        lda chain_entity,x
        jsr IsKey
        bcs tm_key_unlocks
        jmp tm_blocked
tm_key_unlocks
        jmp tm_unlock

tm_walk
        jsr SaveUndo
        ldx player_x
        ldy player_y
        lda #E_NONE
        jsr SetEntity
        ldx next_x
        ldy next_y
        lda player_type
        jsr SetEntity
        lda next_x
        sta player_x
        lda next_y
        sta player_y
        jmp tm_finish

tm_push
        jsr SaveUndo
        lda scan_x
        sta shift_x
        lda scan_y
        sta shift_y
        ldx chain_len
        dex
tm_shift_loop
        stx chain_index
        lda chain_entity,x
        pha
        ldx shift_x
        ldy shift_y
        pla
        jsr SetEntity
        ldx chain_index
        lda chain_x,x
        sta shift_x
        lda chain_y,x
        sta shift_y
        dex
        bpl tm_shift_loop
        inc pushes
        jmp tm_place_player

tm_unlock
        jsr SaveUndo
        ; Remove the lock and the key that reached it.
        ldx scan_x
        ldy scan_y
        lda #E_NONE
        jsr SetEntity
        ldx chain_len
        dex
        stx chain_index
        lda chain_x,x
        sta shift_x
        lda chain_y,x
        sta shift_y
        ldx shift_x
        ldy shift_y
        lda #E_NONE
        jsr SetEntity
        ldx chain_index
        dex
        bmi tm_place_player
tm_unlock_shift
        stx chain_index
        lda chain_entity,x
        pha
        ldx shift_x
        ldy shift_y
        pla
        jsr SetEntity
        ldx chain_index
        lda chain_x,x
        sta shift_x
        lda chain_y,x
        sta shift_y
        dex
        bpl tm_unlock_shift
        lda #$70
        ldx #2
        jsr Tone

tm_place_player
        ldx player_x
        ldy player_y
        lda #E_NONE
        jsr SetEntity
        ldx next_x
        ldy next_y
        lda player_type
        jsr SetEntity
        lda next_x
        sta player_x
        lda next_y
        sta player_y

tm_finish
        inc moves
        lda player_frame
        eor #1
        sta player_frame
        jsr ApplyLateRules
        jsr DrawAfterMove
        lda #$98
        sta AUDF1
        lda #$a6
        sta AUDC1
        lda #1
        sta move_sound_timer    ; non-blocking one-frame movement click
        rts

tm_blocked
        lda #$e0
        ldx #1
        jsr Tone
        rts

; A=entity. Carry set for a pushable object.
IsPushable
        cmp #E_CRATE1
        bcc ip_no
        cmp #E_GDEAD+1
        bcs ip_no
        ; Locks are below this range; players are below crates.
        sec
        rts
ip_no
        clc
        rts

IsKey
        cmp #E_KEY1
        bcc ik_no
        cmp #E_PKEY2+1
        bcs ik_no
        sec
        rts
ik_no
        clc
        rts

IsLock
        cmp #E_LOCK1
        bcc il_no
        cmp #E_GLOCK+1
        bcs il_no
        sec
        rts
il_no
        clc
        rts

IsCrate
        cmp #E_CRATE1
        bcc ic_no
        cmp #E_PCRATE2+1
        bcs ic_no
        sec
        rts
ic_no
        clc
        rts

IsGObject
        cmp #E_GWALL
        beq igo_yes
        cmp #E_GPLAYER
        beq igo_yes
        cmp #E_GCRATE
        beq igo_yes
        cmp #E_GKEY
        beq igo_yes
        cmp #E_GDEAD
        beq igo_yes
        clc
        rts
igo_yes
        sec
        rts

; ---------------------------------------------------------------------------
; PuzzleScript late-rule phases
; ---------------------------------------------------------------------------

ApplyLateRules
        jsr FindPlayer
        bcs alr_have_player
        jmp alr_targets
alr_have_player
        ldx player_x
        ldy player_y
        jsr GetFloor
        and #F_DEATH
        beq alr_special
        jsr HandleDeath

alr_special
        jsr FindPlayer
        bcs alr_have_special_player
        jmp alr_targets
alr_have_special_player
        jsr ApplyBlockedTransfers

        ; Reset the object family belonging to the room left behind. This is
        ; deliberately before ordinary boundary respawning, as in the source.
        jsr FindPlayer
        bcs alr_have_reset_player
        jmp alr_targets
alr_have_reset_player
        lda player_x
        cmp #ROOM_W
        bcc alr_reset_room2
        jsr ResetRoom1Objects
        jmp alr_boundary
alr_reset_room2
        jsr ResetRoom2Objects

alr_boundary
        jsr FindPlayer
        bcc alr_targets
        lda player_type
        cmp #E_PLAYER1
        bne alr_check_player2
        lda player_x
        cmp #ROOM_W
        bcc alr_targets
        ldx player_x
        ldy player_y
        lda #E_NONE
        jsr SetEntity
        lda reset1_x
        cmp #$ff
        beq alr_targets
        ldx reset1_x
        ldy reset1_y
        jsr GetEntity
        jsr IsGObject
        bcs alr_no_player
        ldx reset1_x
        ldy reset1_y
        lda #E_PLAYER1
        jsr SetEntity
        jmp alr_refresh

alr_check_player2
        cmp #E_PLAYER2
        bne alr_targets
        lda player_x
        cmp #ROOM_W
        bcs alr_targets
        ldx player_x
        ldy player_y
        lda #E_NONE
        jsr SetEntity
        lda reset2_x
        cmp #$ff
        beq alr_targets
        ldx reset2_x
        ldy reset2_y
        jsr GetEntity
        bne alr_no_player
        ldx reset2_x
        ldy reset2_y
        lda #E_PLAYER2
        jsr SetEntity
alr_refresh
        jsr FindPlayer
        lda #$48
        ldx #2
        jsr Tone
        jmp alr_targets
alr_no_player
        jsr FindPlayer

alr_targets
        jsr UpdateTargets
        jsr CheckWin
        rts

ApplyBlockedTransfers
        lda player_type
        cmp #E_PLAYER1
        bne abt_player2
        lda player_x
        cmp #ROOM_W
        bcs abt_p1_crossed
        rts
abt_p1_crossed
        lda reset1_x
        cmp #$ff
        bne abt_p1_has_reset
        rts
abt_p1_has_reset
        ldx reset1_x
        ldy reset1_y
        jsr GetEntity
        jsr IsGObject
        bcs abt_p1_blocked
        rts
abt_p1_blocked

        lda #E_DEAD1
        jsr FindTypeRoom2
        bcs abt_p1_room2
        lda #E_DEAD1
        jsr FindTypeAll
        bcs abt_p1_dead_found
        rts
abt_p1_dead_found
        lda #E_PLAYER1
        sta transfer_type
        jmp abt_do_player1
abt_p1_room2
        lda #E_PLAYER2
        sta transfer_type
abt_do_player1
        ldx player_x
        ldy player_y
        lda #E_NONE
        jsr SetEntity
        lda #$ff
        sta reset1_x
        ldx found_x
        ldy found_y
        lda transfer_type
        jsr SetEntity
        lda transfer_type
        cmp #E_PLAYER2
        bne abt_set_reset1
        lda found_x
        sta reset2_x
        lda found_y
        sta reset2_y
        jmp abt_refresh
abt_set_reset1
        lda found_x
        sta reset1_x
        lda found_y
        sta reset1_y
        jmp abt_refresh

abt_player2
        cmp #E_PLAYER2
        beq abt_p2_type
        rts
abt_p2_type
        lda player_x
        cmp #ROOM_W
        bcc abt_p2_crossed
        rts
abt_p2_crossed
        lda reset2_x
        cmp #$ff
        bne abt_p2_has_reset
        rts
abt_p2_has_reset
        ldx reset2_x
        ldy reset2_y
        jsr GetEntity
        jsr IsGObject
        bcs abt_p2_blocked
        rts
abt_p2_blocked

        lda #E_DEAD2
        jsr FindTypeRoom1
        bcs abt_p2_room1
        lda #E_DEAD1
        jsr FindTypeRoom1
        bcs abt_p2_room1
        lda #E_DEAD2
        jsr FindTypeAll
        bcs abt_p2_dead_found
        rts
abt_p2_dead_found
        lda #E_PLAYER2
        sta transfer_type
        jmp abt_do_player2
abt_p2_room1
        lda #E_PLAYER1
        sta transfer_type
abt_do_player2
        ldx player_x
        ldy player_y
        lda #E_NONE
        jsr SetEntity
        lda #$ff
        sta reset2_x
        ldx found_x
        ldy found_y
        lda transfer_type
        jsr SetEntity
        lda transfer_type
        cmp #E_PLAYER1
        bne abt_set_reset2
        lda found_x
        sta reset1_x
        lda found_y
        sta reset1_y
        jmp abt_refresh
abt_set_reset2
        lda found_x
        sta reset2_x
        lda found_y
        sta reset2_y
abt_refresh
        jsr FindPlayer
        lda #$48
        ldx #2
        jsr Tone
abt_done
        rts

HandleDeath
        lda player_type
        sta dead_player_type
        ldx player_x
        ldy player_y
        lda #E_NONE
        jsr SetEntity

        lda #E_DEAD1
        jsr FindTypeRoom2
        bcs hd_player2
        lda #E_DEAD2
        jsr FindTypeRoom1
        bcs hd_player1
        lda #E_GDEAD
        jsr FindTypeAll
        bcs hd_gplayer
        lda #E_DEAD1
        jsr FindTypeAll
        bcs hd_player1
        lda #E_DEAD2
        jsr FindTypeAll
        bcs hd_player2
        jmp hd_old_reset

hd_player1
        lda #E_PLAYER1
        sta transfer_type
        lda found_x
        sta reset1_x
        lda found_y
        sta reset1_y
        jmp hd_place
hd_player2
        lda #E_PLAYER2
        sta transfer_type
        lda found_x
        sta reset2_x
        lda found_y
        sta reset2_y
        jmp hd_place
hd_gplayer
        lda #E_GPLAYER
        sta transfer_type
hd_place
        ldx found_x
        ldy found_y
        lda transfer_type
        jsr SetEntity
        jmp hd_sound

hd_old_reset
        lda dead_player_type
        cmp #E_PLAYER1
        bne hd_old_player2
        lda reset1_x
        cmp #$ff
        beq hd_sound
        ldx reset1_x
        ldy reset1_y
        jsr GetEntity
        bne hd_sound
        lda #E_PLAYER1
        jsr SetEntity
        jmp hd_sound
hd_old_player2
        cmp #E_PLAYER2
        bne hd_sound
        lda reset2_x
        cmp #$ff
        beq hd_sound
        ldx reset2_x
        ldy reset2_y
        jsr GetEntity
        bne hd_sound
        lda #E_PLAYER2
        jsr SetEntity
hd_sound
        jsr FindPlayer
        lda #$b8
        ldx #4
        jsr Tone
        rts

; Remove every Room 1 family object, then recreate it at unblocked spawners.
ResetRoom1Objects
        lda #1
        sta reset_family
        jsr RemoveFamilyObjects
        jmp RestoreFamilySpawns

ResetRoom2Objects
        lda #2
        sta reset_family
        jsr RemoveFamilyObjects
        jmp RestoreFamilySpawns

RemoveFamilyObjects
        lda #0
        sta scan_y
rfo_row
        lda #0
        sta scan_x
rfo_col
        ldx scan_x
        ldy scan_y
        jsr GetEntity
        sta scan_entity
        lda reset_family
        cmp #1
        bne rfo_family2
        lda scan_entity
        cmp #E_WALL1
        beq rfo_remove
        cmp #E_LOCK1
        beq rfo_remove
        cmp #E_CRATE1
        beq rfo_remove
        cmp #E_KEY1
        beq rfo_remove
        cmp #E_DEAD1
        beq rfo_remove
        jmp rfo_next
rfo_family2
        lda scan_entity
        cmp #E_WALL2
        beq rfo_remove
        cmp #E_LOCK2
        beq rfo_remove
        cmp #E_CRATE2
        beq rfo_remove
        cmp #E_KEY2
        beq rfo_remove
        cmp #E_DEAD2
        bne rfo_next
rfo_remove
        ldx scan_x
        ldy scan_y
        lda #E_NONE
        jsr SetEntity
rfo_next
        inc scan_x
        lda scan_x
        cmp #BOARD_W
        bne rfo_col
        inc scan_y
        lda scan_y
        cmp #BOARD_H
        bne rfo_row
        rts

RestoreFamilySpawns
        lda #0
        sta scan_y
rfs_row
        lda #0
        sta scan_x
rfs_col
        ldx scan_x
        ldy scan_y
        jsr GetSpawn
        sta scan_spawn
        beq rfs_next
        lda reset_family
        cmp #1
        bne rfs_family2
        lda scan_spawn
        cmp #S_WALL1
        beq rfs_wall1
        cmp #S_LOCK1
        beq rfs_lock1
        cmp #S_KEY1
        beq rfs_key1
        cmp #S_CRATE1
        beq rfs_crate1
        cmp #S_DEAD1
        beq rfs_dead1
        jmp rfs_next
rfs_wall1
        lda #E_WALL1
        bne rfs_try
rfs_lock1
        lda #E_LOCK1
        bne rfs_try
rfs_key1
        lda #E_KEY1
        bne rfs_try
rfs_crate1
        lda #E_CRATE1
        bne rfs_try
rfs_dead1
        lda #E_DEAD1
        bne rfs_try
rfs_family2
        lda scan_spawn
        cmp #S_WALL2
        beq rfs_wall2
        cmp #S_LOCK2
        beq rfs_lock2
        cmp #S_KEY2
        beq rfs_key2
        cmp #S_CRATE2
        beq rfs_crate2
        cmp #S_DEAD2
        beq rfs_dead2
        jmp rfs_next
rfs_wall2
        lda #E_WALL2
        bne rfs_try
rfs_lock2
        lda #E_LOCK2
        bne rfs_try
rfs_key2
        lda #E_KEY2
        bne rfs_try
rfs_crate2
        lda #E_CRATE2
        bne rfs_try
rfs_dead2
        lda #E_DEAD2
rfs_try
        sta restore_entity
        ldx scan_x
        ldy scan_y
        jsr GetEntity
        bne rfs_next
        ldx scan_x
        ldy scan_y
        lda restore_entity
        jsr SetEntity
rfs_next
        inc scan_x
        lda scan_x
        cmp #BOARD_W
        beq rfs_row_advance
        jmp rfs_col
rfs_row_advance
        inc scan_y
        lda scan_y
        cmp #BOARD_H
        beq rfs_done
        jmp rfs_row
rfs_done
        rts

UpdateTargets
        lda #0
        sta has_target
        sta open_target
        sta scan_y
ut_row
        lda #0
        sta scan_x
ut_col
        ldx scan_x
        ldy scan_y
        jsr GetFloor
        and #F_TARGET
        beq ut_next
        lda #1
        sta has_target
        ldx scan_x
        ldy scan_y
        jsr GetEntity
        jsr IsCrate
        bcs ut_next
        lda #1
        sta open_target
ut_next
        inc scan_x
        lda scan_x
        cmp #BOARD_W
        bne ut_col
        inc scan_y
        lda scan_y
        cmp #BOARD_H
        bne ut_row
        lda has_target
        beq ut_done

        lda #0
        sta scan_y
utf_row
        lda #0
        sta scan_x
utf_col
        ldx scan_x
        ldy scan_y
        jsr GetFloor
        sta floor_temp
        and #F_FLAG+F_NFLAG
        beq utf_next
        lda floor_temp
        and #$f3
        sta floor_temp
        lda open_target
        bne utf_inactive
        lda floor_temp
        ora #F_FLAG
        bne utf_store
utf_inactive
        lda floor_temp
        ora #F_NFLAG
utf_store
        ldx scan_x
        ldy scan_y
        jsr SetFloor
utf_next
        inc scan_x
        lda scan_x
        cmp #BOARD_W
        bne utf_col
        inc scan_y
        lda scan_y
        cmp #BOARD_H
        bne utf_row
ut_done
        rts

CheckWin
        jsr FindPlayer
        bcc cw_no
        ldx player_x
        ldy player_y
        jsr GetFloor
        and #F_FLAG
        beq cw_no
        jsr LevelWon
cw_no
        rts

LevelWon
        jsr VictorySound
        jsr ShowClear
        jsr WaitFire
        inc level_no
        lda level_no
        cmp #LEVEL_COUNT
        bcc lw_next
        jsr ShowComplete
        jsr WaitFire
        lda #0
        sta level_no
lw_next
        jmp BeginLevel

; ---------------------------------------------------------------------------
; Level loading and undo
; ---------------------------------------------------------------------------

ResetLevel
        ldx level_no
        lda level_data_lo,x
        sta source_ptr
        lda level_data_hi,x
        sta source_ptr+1
        mwa #ENTITY_GRID dest_ptr
        mwa #SPAWN_GRID cell_ptr
        lda #<FLOOR_GRID
        sta floor_ptr
        lda #>FLOOR_GRID
        sta floor_ptr+1
        lda #$ff
        sta reset1_x
        sta reset1_y
        sta reset2_x
        sta reset2_y
        lda #0
        sta load_x
        sta load_y
        sta moves
        sta pushes
        sta undo_valid
        sta player_frame
        sta move_sound_timer
        sta AUDC1
        lda #1                  ; face down when a level first appears
        sta direction

rl_cell
        ldy #0
        lda (source_ptr),y
        sta level_char
        lda #E_NONE
        sta load_entity
        lda #S_NONE
        sta load_spawn
        lda #0
        sta load_floor
        jsr DecodeLevelChar
        ldy #0
        lda load_entity
        sta (dest_ptr),y
        lda load_spawn
        sta (cell_ptr),y
        lda load_floor
        sta (floor_ptr),y
        jsr IncrementLoadPointers
        inc load_x
        lda load_x
        cmp #BOARD_W
        bne rl_cell
        lda #0
        sta load_x
        inc load_y
        lda load_y
        cmp #BOARD_H
        bne rl_cell

        jsr FindPlayer
        jsr UpdateTargets
        jsr SetGameDisplay
        jsr DrawBoard
        rts

DecodeLevelChar
        lda level_char
        cmp #'#'
        bne dlc_wall2
        lda #E_WALL1
        sta load_entity
        lda #S_WALL1
        sta load_spawn
        rts
dlc_wall2
        cmp #'z'
        bne dlc_gwall
        lda #E_WALL2
        sta load_entity
        lda #S_WALL2
        sta load_spawn
        rts
dlc_gwall
        cmp #'r'
        bne dlc_gplayer
        lda #E_GWALL
        sta load_entity
        rts
dlc_gplayer
        cmp #'g'
        bne dlc_player1a
        lda #E_GPLAYER
        sta load_entity
        rts
dlc_player1a
        cmp #'P'
        beq dlc_player1
        cmp #'p'
        bne dlc_crate1
dlc_player1
        lda #E_PLAYER1
        sta load_entity
        lda load_x
        sta reset1_x
        lda load_y
        sta reset1_y
        rts
dlc_crate1
        cmp #'*'
        bne dlc_crate2
        lda #E_CRATE1
        sta load_entity
        lda #S_CRATE1
        sta load_spawn
        rts
dlc_crate2
        cmp #'$'
        bne dlc_gcrate
        lda #E_CRATE2
        sta load_entity
        lda #S_CRATE2
        sta load_spawn
        rts
dlc_gcrate
        cmp #'h'
        bne dlc_gcrate_target
        lda #E_GCRATE
        sta load_entity
        rts
dlc_gcrate_target
        cmp #'&'
        bne dlc_target_upper
        lda #E_GCRATE
        sta load_entity
        lda #F_TARGET
        sta load_floor
        rts
dlc_target_upper
        cmp #'O'
        beq dlc_target
        cmp #'o'
        bne dlc_lock1
dlc_target
        lda #F_TARGET
        sta load_floor
        rts
dlc_lock1
        cmp #'l'
        bne dlc_lock2
        lda #E_LOCK1
        sta load_entity
        lda #S_LOCK1
        sta load_spawn
        rts
dlc_lock2
        cmp #'m'
        bne dlc_key1
        lda #E_LOCK2
        sta load_entity
        lda #S_LOCK2
        sta load_spawn
        rts
dlc_key1
        cmp #'j'
        bne dlc_key2
        lda #E_KEY1
        sta load_entity
        lda #S_KEY1
        sta load_spawn
        rts
dlc_key2
        cmp #'q'
        bne dlc_gkey
        lda #E_KEY2
        sta load_entity
        lda #S_KEY2
        sta load_spawn
        rts
dlc_gkey
        cmp #'b'
        bne dlc_glock
        lda #E_GKEY
        sta load_entity
        rts
dlc_glock
        cmp #'x'
        bne dlc_pcrate1
        lda #E_GLOCK
        sta load_entity
        rts
dlc_pcrate1
        cmp #'f'
        bne dlc_pcrate2
        lda #E_PCRATE1
        sta load_entity
        rts
dlc_pcrate2
        cmp #'n'
        bne dlc_pkey1
        lda #E_PCRATE2
        sta load_entity
        rts
dlc_pkey1
        cmp #'c'
        bne dlc_pkey2
        lda #E_PKEY1
        sta load_entity
        rts
dlc_pkey2
        cmp #'s'
        bne dlc_flag
        lda #E_PKEY2
        sta load_entity
        rts
dlc_flag
        cmp #'a'
        bne dlc_nflag
        lda #F_FLAG
        sta load_floor
        rts
dlc_nflag
        cmp #'%'
        bne dlc_death
        lda #F_NFLAG
        sta load_floor
        rts
dlc_death
        cmp #'d'
        bne dlc_dead1
        lda #F_DEATH
        sta load_floor
        rts
dlc_dead1
        cmp #'3'
        bne dlc_dead2
        lda #E_DEAD1
        sta load_entity
        lda #S_DEAD1
        sta load_spawn
        rts
dlc_dead2
        cmp #'4'
        bne dlc_gdead
        lda #E_DEAD2
        sta load_entity
        lda #S_DEAD2
        sta load_spawn
        rts
dlc_gdead
        cmp #'5'
        bne dlc_pplayer1
        lda #E_GDEAD
        sta load_entity
        rts
dlc_pplayer1
        cmp #'6'
        bne dlc_pplayer2
        lda #E_PPLAYER1
        sta load_entity
        rts
dlc_pplayer2
        cmp #'7'
        bne dlc_player2
        lda #E_PPLAYER2
        sta load_entity
        rts
dlc_player2
        cmp #'8'
        bne dlc_crate2_target
        lda #E_PLAYER2
        sta load_entity
        lda load_x
        sta reset2_x
        lda load_y
        sta reset2_y
        rts
dlc_crate2_target
        cmp #'9'
        bne dlc_crate1_target
        lda #E_CRATE2
        sta load_entity
        lda #S_CRATE2
        sta load_spawn
        lda #F_TARGET
        sta load_floor
        rts
dlc_crate1_target
        cmp #'0'
        bne dlc_done
        lda #E_CRATE1
        sta load_entity
        lda #S_CRATE1
        sta load_spawn
        lda #F_TARGET
        sta load_floor
dlc_done
        rts

IncrementLoadPointers
        inc source_ptr
        bne ilp_dest
        inc source_ptr+1
ilp_dest
        inc dest_ptr
        bne ilp_spawn
        inc dest_ptr+1
ilp_spawn
        inc cell_ptr
        bne ilp_floor
        inc cell_ptr+1
ilp_floor
        inc floor_ptr
        bne ilp_done
        inc floor_ptr+1
ilp_done
        rts

SaveUndo
        ldx #0
su_page
        lda ENTITY_GRID,x
        sta UNDO_GRID,x
        inx
        bne su_page
        ldx #0
su_tail
        lda ENTITY_GRID+$100,x
        sta UNDO_GRID+$100,x
        inx
        cpx #82
        bne su_tail
        lda reset1_x
        sta undo_reset1_x
        lda reset1_y
        sta undo_reset1_y
        lda reset2_x
        sta undo_reset2_x
        lda reset2_y
        sta undo_reset2_y
        lda moves
        sta undo_moves
        lda pushes
        sta undo_pushes
        lda #1
        sta undo_valid
        rts

UndoMove
        lda undo_valid
        bne um_restore
        rts
um_restore
        ldx #0
um_page
        lda UNDO_GRID,x
        sta ENTITY_GRID,x
        inx
        bne um_page
        ldx #0
um_tail
        lda UNDO_GRID+$100,x
        sta ENTITY_GRID+$100,x
        inx
        cpx #82
        bne um_tail
        lda undo_reset1_x
        sta reset1_x
        lda undo_reset1_y
        sta reset1_y
        lda undo_reset2_x
        sta reset2_x
        lda undo_reset2_y
        sta reset2_y
        lda undo_moves
        sta moves
        lda undo_pushes
        sta pushes
        lda #0
        sta undo_valid
        jsr FindPlayer
        jsr UpdateTargets
        jsr DrawBoard
        rts

; ---------------------------------------------------------------------------
; Grid helpers
; ---------------------------------------------------------------------------

CalcIndex
        stx calc_x
        lda row_offset_lo,y
        clc
        adc calc_x
        sta grid_index
        lda row_offset_hi,y
        adc #0
        sta grid_index+1
        rts

PointEntity
        jsr CalcIndex
        lda #<ENTITY_GRID
        clc
        adc grid_index
        sta cell_ptr
        lda #>ENTITY_GRID
        adc grid_index+1
        sta cell_ptr+1
        rts

GetEntity
        jsr PointEntity
        ldy #0
        lda (cell_ptr),y
        rts

SetEntity
        pha
        jsr PointEntity
        pla
        ldy #0
        sta (cell_ptr),y
        rts

PointSpawn
        jsr CalcIndex
        lda #<SPAWN_GRID
        clc
        adc grid_index
        sta cell_ptr
        lda #>SPAWN_GRID
        adc grid_index+1
        sta cell_ptr+1
        rts

GetSpawn
        jsr PointSpawn
        ldy #0
        lda (cell_ptr),y
        rts

PointUndo
        jsr CalcIndex
        lda #<UNDO_GRID
        clc
        adc grid_index
        sta cell_ptr
        lda #>UNDO_GRID
        adc grid_index+1
        sta cell_ptr+1
        rts

GetUndoEntity
        jsr PointUndo
        ldy #0
        lda (cell_ptr),y
        rts

PointFloor
        jsr CalcIndex
        lda #<FLOOR_GRID
        clc
        adc grid_index
        sta cell_ptr
        lda #>FLOOR_GRID
        adc grid_index+1
        sta cell_ptr+1
        rts

GetFloor
        jsr PointFloor
        ldy #0
        lda (cell_ptr),y
        rts

SetFloor
        pha
        jsr PointFloor
        pla
        ldy #0
        sta (cell_ptr),y
        rts

FindPlayer
        lda #0
        sta find_y
fp_row
        lda #0
        sta find_x
fp_col
        ldx find_x
        ldy find_y
        jsr GetEntity
        cmp #E_PLAYER1
        bcc fp_next
        cmp #E_PPLAYER2+1
        bcs fp_next
        sta player_type
        lda find_x
        sta player_x
        lda find_y
        sta player_y
        sec
        rts
fp_next
        inc find_x
        lda find_x
        cmp #BOARD_W
        bne fp_col
        inc find_y
        lda find_y
        cmp #BOARD_H
        bne fp_row
        clc
        rts

FindTypeRoom1
        sta find_type
        lda #0
        sta find_start_x
        lda #ROOM_W
        sta find_end_x
        jmp FindTypeRange

FindTypeRoom2
        sta find_type
        lda #ROOM_W
        sta find_start_x
        lda #BOARD_W
        sta find_end_x
        jmp FindTypeRange

FindTypeAll
        sta find_type
        lda #0
        sta find_start_x
        lda #BOARD_W
        sta find_end_x

FindTypeRange
        lda #0
        sta find_y
ftr_row
        lda find_start_x
        sta find_x
ftr_col
        ldx find_x
        ldy find_y
        jsr GetEntity
        cmp find_type
        beq ftr_found
        inc find_x
        lda find_x
        cmp find_end_x
        bne ftr_col
        inc find_y
        lda find_y
        cmp #BOARD_H
        bne ftr_row
        clc
        rts
ftr_found
        lda find_x
        sta found_x
        lda find_y
        sta found_y
        sec
        rts

; ---------------------------------------------------------------------------
; Drawing and screens
; ---------------------------------------------------------------------------

DrawBoard
        jsr SetGameDisplay
        jsr ClearGameBitmap
        jsr SelectVisibleRoom
        sta drawn_room_start
        lda #1
        sta skip_tile_clear
        jsr DrawAllCells
        lda #0
        sta skip_tile_clear
        rts

; Rebuild a newly selected flickscreen over the existing bitmap. Every tile
; starts with an opaque background sprite, so no visible clear-frame occurs.
DrawBoardRefresh
        jsr SelectVisibleRoom
        sta drawn_room_start
        sta room_start
        jsr MarkRoomChanges
        jsr ExpandRoomDirty
        jmp DrawRoomDirty

SelectVisibleRoom
        jsr FindPlayer
        lda #0
        bcc svr_done
        lda player_x
        cmp #ROOM_W
        bcc svr_room1
        lda #ROOM_W
        rts
svr_room1
        lda #0
svr_done
        rts

DrawAllCells
        lda drawn_room_start
        sta room_start
        lda #0
        sta board_pos_y
db_row
        lda #0
        sta board_pos_x
db_col
        jsr DrawCell
        inc board_pos_x
        lda board_pos_x
        cmp #ROOM_W
        bne db_col
        inc board_pos_y
        lda board_pos_y
        cmp #BOARD_H
        beq db_done
        jmp db_row
db_done
        rts

; Compare the newly selected room with the visual state currently on screen.
; Equivalent object families (wall1/wall2, player1/player2, and so on) share a
; cached visual id, avoiding redraws when their appearance is identical.
MarkRoomChanges
        lda #0
        sta board_pos_y
mrc_row
        lda #0
        sta board_pos_x
mrc_col
        ldx board_pos_x
        ldy board_pos_y
        jsr CalcVisibleIndex
        stx visible_index
        lda #0
        sta VISIBLE_DIRTY,x

        lda board_pos_x
        clc
        adc room_start
        tax
        ldy board_pos_y
        jsr GetEntity
        jsr NormalizeVisualEntity
        ldx visible_index
        cmp VISIBLE_ENTITY,x
        bne mrc_dirty

        lda board_pos_x
        clc
        adc room_start
        tax
        ldy board_pos_y
        jsr GetFloor
        ldx visible_index
        cmp VISIBLE_FLOOR,x
        beq mrc_next
mrc_dirty
        lda #1
        ldx visible_index
        sta VISIBLE_DIRTY,x
mrc_next
        inc board_pos_x
        lda board_pos_x
        cmp #ROOM_W
        bne mrc_col
        inc board_pos_y
        lda board_pos_y
        cmp #BOARD_H
        bne mrc_row
        rts

; Redraw the direct neighbors of changed cells too. This keeps exposed wall
; edges correct without repainting the entire room. Value 1 is an original
; change and value 2 is an expanded neighbor, preventing recursive expansion.
ExpandRoomDirty
        lda #0
        sta board_pos_y
erd_row
        lda #0
        sta board_pos_x
erd_col
        ldx board_pos_x
        ldy board_pos_y
        jsr CalcVisibleIndex
        stx visible_index
        lda VISIBLE_DIRTY,x
        cmp #1
        bne erd_next

        lda board_pos_y
        beq erd_down
        ldx visible_index
        txa
        sec
        sbc #ROOM_W
        tax
        jsr MarkExpandedCell
erd_down
        lda board_pos_y
        cmp #BOARD_H-1
        beq erd_left
        ldx visible_index
        txa
        clc
        adc #ROOM_W
        tax
        jsr MarkExpandedCell
erd_left
        lda board_pos_x
        beq erd_right
        ldx visible_index
        dex
        jsr MarkExpandedCell
erd_right
        lda board_pos_x
        cmp #ROOM_W-1
        beq erd_next
        ldx visible_index
        inx
        jsr MarkExpandedCell
erd_next
        inc board_pos_x
        lda board_pos_x
        cmp #ROOM_W
        bne erd_col
        inc board_pos_y
        lda board_pos_y
        cmp #BOARD_H
        bne erd_row
        rts

MarkExpandedCell
        lda VISIBLE_DIRTY,x
        bne mec_done
        lda #2
        sta VISIBLE_DIRTY,x
mec_done
        rts

DrawRoomDirty
        lda #0
        sta board_pos_y
drd_row
        lda #0
        sta board_pos_x
drd_col
        ldx board_pos_x
        ldy board_pos_y
        jsr CalcVisibleIndex
        lda VISIBLE_DIRTY,x
        beq drd_next
        jsr DrawCell
drd_next
        inc board_pos_x
        lda board_pos_x
        cmp #ROOM_W
        bne drd_col
        inc board_pos_y
        lda board_pos_y
        cmp #BOARD_H
        bne drd_row
        rts

; Repaint only cells whose collision-layer entity changed since SaveUndo.
; Flag cells are also refreshed because target coverage can change their floor
; sprite without changing the entity occupying that cell.
DrawAfterMove
        jsr SelectVisibleRoom
        cmp drawn_room_start
        beq dam_same_room
        jmp DrawBoardRefresh
dam_same_room
        sta room_start
        lda #0
        sta board_pos_y
dam_row
        lda #0
        sta board_pos_x
dam_col
        lda board_pos_x
        clc
        adc room_start
        sta dirty_world_x
        tax
        ldy board_pos_y
        jsr GetEntity
        sta dirty_entity
        ldx dirty_world_x
        ldy board_pos_y
        jsr GetUndoEntity
        sta dirty_old_entity
        cmp dirty_entity
        bne dam_redraw
        ldx dirty_world_x
        ldy board_pos_y
        jsr GetFloor
        and #F_FLAG+F_NFLAG
        beq dam_next
dam_redraw
        ; A wall appearing or disappearing changes the outline of its adjacent
        ; wall cells too. Repaint the room in place so every join is correct;
        ; wall changes are rare and DrawBoardRefresh never clears the bitmap.
        lda dirty_entity
        jsr IsAnyWall
        bcs dam_wall_changed
        lda dirty_old_entity
        jsr IsAnyWall
        bcs dam_wall_changed
        jsr DrawCell
dam_next
        inc board_pos_x
        lda board_pos_x
        cmp #ROOM_W
        bne dam_col
        inc board_pos_y
        lda board_pos_y
        cmp #BOARD_H
        beq dam_done
        jmp dam_row
dam_done
        rts
dam_wall_changed
        jmp DrawBoardRefresh

; A=entity. Carry set for any of the three wall types.
IsAnyWall
        cmp #E_WALL1
        bcc iaw_no
        cmp #E_GWALL+1
        bcs iaw_no
        sec
        rts
iaw_no
        clc
        rts

; Paint one complete tile from the background upward. The opaque first pass is
; what lets movement erase old sprites without clearing the whole display.
DrawCell
        lda #0
        sta sprite_wall_mode
        sta wall_edges
        lda #P_TRANS
        sta sprite_tint
        lda skip_tile_clear
        bne dc_background_ready
        jsr ClearCurrentTile
dc_background_ready
        lda board_pos_x
        clc
        adc room_start
        tax
        ldy board_pos_y
        jsr GetFloor
        sta drawn_floor
        and #F_TARGET
        beq db_flag
        mwa #spr_target str_ptr
        jsr DrawCurrentSprite
db_flag
        lda drawn_floor
        and #F_FLAG
        beq db_nflag
        mwa #spr_flag str_ptr
        jsr DrawCurrentSprite
db_nflag
        lda drawn_floor
        and #F_NFLAG
        beq db_death
        mwa #spr_nflag str_ptr
        jsr DrawCurrentSprite
db_death
        lda drawn_floor
        and #F_DEATH
        beq db_entity
        mwa #spr_death str_ptr
        jsr DrawCurrentSprite
db_entity
        lda #0
        sta sprite_wall_mode
        lda board_pos_x
        clc
        adc room_start
        tax
        ldy board_pos_y
        jsr GetEntity
        beq dc_done
        jsr SelectEntitySprite
        lda sprite_wall_mode
        beq dc_draw_entity
        jsr PrepareWallEdges
dc_draw_entity
        jsr DrawCurrentSprite
dc_done
        jmp UpdateVisibleCache

DrawCurrentSprite
        ldx board_pos_x
        ldy board_pos_y
        jmp DrawSprite

SelectEntitySprite
        cmp #E_WALL1
        bne ses_wall2
        lda #1
        sta sprite_wall_mode
        mwa #spr_wall1 str_ptr
        rts
ses_wall2
        cmp #E_WALL2
        bne ses_gwall
        lda #1
        sta sprite_wall_mode
        mwa #spr_wall2 str_ptr
        rts
ses_gwall
        cmp #E_GWALL
        bne ses_lock1
        lda #2
        sta sprite_wall_mode
        mwa #spr_gwall str_ptr
        rts
ses_lock1
        cmp #E_LOCK1
        bne ses_lock2
        mwa #spr_lock1 str_ptr
        rts
ses_lock2
        cmp #E_LOCK2
        bne ses_glock
        mwa #spr_lock2 str_ptr
        rts
ses_glock
        cmp #E_GLOCK
        bne ses_player1
        lda #P_GREEN1
        sta sprite_tint
        mwa #spr_lock1 str_ptr
        rts
ses_player1
        cmp #E_PLAYER1
        beq ses_player
        cmp #E_PLAYER2
        beq ses_player
        cmp #E_GPLAYER
        bne ses_pplayer
        lda #P_GREEN1
        sta sprite_tint
        jmp SelectPlayerSprite
ses_pplayer
        cmp #E_PPLAYER1
        beq ses_purple_player
        cmp #E_PPLAYER2
        bne ses_crate1
ses_purple_player
        lda #P_BLUE
        sta sprite_tint
        jmp SelectPlayerSprite
ses_player
        jmp SelectPlayerSprite
ses_crate1
        cmp #E_CRATE1
        bne ses_crate2
        mwa #spr_crate1 str_ptr
        rts
ses_crate2
        cmp #E_CRATE2
        bne ses_gcrate
        mwa #spr_crate2 str_ptr
        rts
ses_gcrate
        cmp #E_GCRATE
        bne ses_pcrate
        lda #P_GREEN1
        sta sprite_tint
        mwa #spr_crate1 str_ptr
        rts
ses_pcrate
        cmp #E_PCRATE1
        beq ses_purple_crate
        cmp #E_PCRATE2
        bne ses_key1
ses_purple_crate
        lda #P_BLUE
        sta sprite_tint
        mwa #spr_crate1 str_ptr
        rts
ses_key1
        cmp #E_KEY1
        bne ses_key2
        mwa #spr_key1 str_ptr
        rts
ses_key2
        cmp #E_KEY2
        bne ses_gkey
        mwa #spr_key2 str_ptr
        rts
ses_gkey
        cmp #E_GKEY
        bne ses_pkey
        lda #P_GREEN1
        sta sprite_tint
        mwa #spr_key1 str_ptr
        rts
ses_pkey
        cmp #E_PKEY1
        beq ses_purple_key
        cmp #E_PKEY2
        bne ses_dead1
ses_purple_key
        lda #P_BLUE
        sta sprite_tint
        mwa #spr_key1 str_ptr
        rts
ses_dead1
        cmp #E_DEAD1
        beq ses_dead
        cmp #E_DEAD2
        beq ses_dead
        cmp #E_GDEAD
        bne ses_blank
        jmp ses_dead
ses_dead
        mwa #spr_dead str_ptr
        rts
ses_blank
        mwa #spr_blank str_ptr
        rts

; All controllable player families share the same direction and walk frames.
; Green and immutable blue players are recolored by sprite_tint; the normal
; player keeps the four source colors in the artwork.
SelectPlayerSprite
        lda direction
        asl
        ora player_frame
        tax
        lda player_sprite_lo,x
        sta str_ptr
        lda player_sprite_hi,x
        sta str_ptr+1
        rts

; Compute exposed wall sides once. DrawSpriteRow applies these edges while it
; paints the wall face, replacing the former four extra sprite-overlay passes.
PrepareWallEdges
        lda #0
        sta wall_edges
        lda sprite_wall_mode
        cmp #2
        bne pwe_yellow_edge
        lda #P_GREEN2
        bne pwe_store_edge_color
pwe_yellow_edge
        lda #P_DARK
pwe_store_edge_color
        sta wall_edge_color

        lda board_pos_y
        beq pwe_mark_top
        sec
        sbc #1
        tay
        lda board_pos_x
        clc
        adc room_start
        tax
        jsr GetEntity
        jsr IsSameWall
        bcs pwe_check_bottom
pwe_mark_top
        lda wall_edges
        ora #WALL_EDGE_TOP
        sta wall_edges

pwe_check_bottom
        lda board_pos_y
        cmp #BOARD_H-1
        beq pwe_mark_bottom
        clc
        adc #1
        tay
        lda board_pos_x
        clc
        adc room_start
        tax
        jsr GetEntity
        jsr IsSameWall
        bcs pwe_check_left
pwe_mark_bottom
        lda wall_edges
        ora #WALL_EDGE_BOTTOM
        sta wall_edges

pwe_check_left
        lda board_pos_x
        beq pwe_mark_left
        sec
        sbc #1
        clc
        adc room_start
        tax
        ldy board_pos_y
        jsr GetEntity
        jsr IsSameWall
        bcs pwe_check_right
pwe_mark_left
        lda wall_edges
        ora #WALL_EDGE_LEFT
        sta wall_edges

pwe_check_right
        lda board_pos_x
        cmp #ROOM_W-1
        beq pwe_mark_right
        clc
        adc #1
        clc
        adc room_start
        tax
        ldy board_pos_y
        jsr GetEntity
        jsr IsSameWall
        bcs pwe_done
pwe_mark_right
        lda wall_edges
        ora #WALL_EDGE_RIGHT
        sta wall_edges
pwe_done
        rts

; A=neighbor entity. Carry set when it belongs to the current wall family.
IsSameWall
        ldx sprite_wall_mode
        cpx #2
        beq isw_green
        cmp #E_WALL1
        beq isw_yes
        cmp #E_WALL2
        beq isw_yes
        clc
        rts
isw_green
        cmp #E_GWALL
        beq isw_yes
        clc
        rts
isw_yes
        sec
        rts

; X=local x, Y=local y. Return X=(y*13)+x for the visible-room caches.
CalcVisibleIndex
        stx calc_x
        tya
        asl
        asl
        sta math_temp            ; 4*y
        tya
        asl
        asl
        asl                      ; 8*y
        clc
        adc math_temp            ; 12*y
        clc
        adc calc_x
        tax
        rts

; Collapse entities with identical artwork to a shared cache id.
NormalizeVisualEntity
        cmp #E_WALL2
        bne nve_lock2
        lda #E_WALL1
        rts
nve_lock2
        cmp #E_LOCK2
        bne nve_player2
        lda #E_LOCK1
        rts
nve_player2
        cmp #E_PLAYER2
        bne nve_pplayer2
        lda #E_PLAYER1
        rts
nve_pplayer2
        cmp #E_PPLAYER2
        bne nve_crate2
        lda #E_PPLAYER1
        rts
nve_crate2
        cmp #E_CRATE2
        bne nve_pcrate2
        lda #E_CRATE1
        rts
nve_pcrate2
        cmp #E_PCRATE2
        bne nve_key2
        lda #E_PCRATE1
        rts
nve_key2
        cmp #E_KEY2
        bne nve_pkey2
        lda #E_KEY1
        rts
nve_pkey2
        cmp #E_PKEY2
        bne nve_dead2
        lda #E_PKEY1
        rts
nve_dead2
        cmp #E_DEAD2
        bne nve_gdead
        lda #E_DEAD1
        rts
nve_gdead
        cmp #E_GDEAD
        bne nve_done
        lda #E_DEAD1
nve_done
        rts

; Record the completed tile so a later flickscreen transition can compare the
; next room directly with what is actually visible, not with mutable game data.
UpdateVisibleCache
        ldx board_pos_x
        ldy board_pos_y
        jsr CalcVisibleIndex
        stx visible_index

        lda board_pos_x
        clc
        adc room_start
        tax
        ldy board_pos_y
        jsr GetEntity
        jsr NormalizeVisualEntity
        ldx visible_index
        sta VISIBLE_ENTITY,x

        lda board_pos_x
        clc
        adc room_start
        tax
        ldy board_pos_y
        jsr GetFloor
        ldx visible_index
        sta VISIBLE_FLOOR,x
        rts

; X/Y = 13x13 screen cell, str_ptr = 42-byte 6x7 sprite.
DrawSprite
        stx draw_x
        sty draw_y
        jsr PositionSprite
        lda #0
        sta sprite_source_index
        lda #SPRITE_H
        sta sprite_rows
ds_source_row
        lda sprite_source_index
        sta sprite_row_start
        lda #2                  ; seven source rows = fourteen scanlines
        sta sprite_repeats
ds_repeat_row
        lda sprite_row_start
        sta sprite_source_index
        jsr DrawSpriteRow
        jsr NextBitmapLine
        dec sprite_repeats
        bne ds_repeat_row
        dec sprite_rows
        bne ds_source_row
        rts

; X/Y = screen cell. Calculate its first GTIA pixel and bitmap scanline.
PositionSprite
        txa
        asl
        sta math_temp
        asl
        clc
        adc math_temp
        clc
        adc #BOARD_X
        sta sprite_base_x
        tya
        asl
        sta math_temp
        asl
        asl
        asl
        sec
        sbc math_temp
        clc
        adc #BOARD_Y
        sta sprite_base_y
        cmp #64
        bcc ps_first_half
        sec
        sbc #64
        cmp #64
        bcc ps_second_half
        sec
        sbc #64
        tax
        mwa #GAME_SCREEN3 dest_ptr
        jmp ps_seek_start
ps_second_half
        tax
        mwa #GAME_SCREEN2 dest_ptr
        jmp ps_seek_start
ps_first_half
        tax
        mwa #GAME_SCREEN1 dest_ptr
ps_seek_start
        cpx #0
        beq ps_row_ready
ps_seek_row
        clc
        lda dest_ptr
        adc #GAME_ROW_BYTES
        sta dest_ptr
        bcc ps_seek_no_carry
        inc dest_ptr+1
ps_seek_no_carry
        dex
        bne ps_seek_row
ps_row_ready
        rts

; Clear one 6x14 tile directly as four packed bytes per scanline. BOARD_X is
; odd and every tile is six color clocks wide, so this preserves the outside
; nibbles while replacing the six interior pixels with background color 8.
ClearCurrentTile
        ldx board_pos_x
        ldy board_pos_y
        jsr PositionSprite
        lda sprite_base_x
        lsr
        sta tile_byte_offset
        ldx #SPRITE_H*2
cct_line
        ldy tile_byte_offset
        lda (dest_ptr),y
        and #$f0
        ora #P_BROWN
        sta (dest_ptr),y
        iny
        lda #$88
        sta (dest_ptr),y
        iny
        sta (dest_ptr),y
        iny
        lda (dest_ptr),y
        and #$0f
        ora #P_BROWN*16
        sta (dest_ptr),y
        jsr NextBitmapLine
        dex
        bne cct_line
        rts

DrawSpriteRow
        lda #0
        sta sprite_col
dsr_pixel
        ldy sprite_source_index
        lda (str_ptr),y
        inc sprite_source_index
        cmp #P_TRANS
        beq dsr_next
        ldx sprite_tint
        cpx #P_TRANS
        beq dsr_source_color
        txa
dsr_source_color
        sta pixel_color
        lda sprite_wall_mode
        beq dsr_have_color
        lda wall_edges
        and #WALL_EDGE_TOP
        beq dsr_wall_bottom
        lda sprite_row_start
        beq dsr_edge_color
dsr_wall_bottom
        lda wall_edges
        and #WALL_EDGE_BOTTOM
        beq dsr_wall_left
        lda sprite_row_start
        cmp #SPRITE_W*(SPRITE_H-1)
        beq dsr_edge_color
dsr_wall_left
        lda wall_edges
        and #WALL_EDGE_LEFT
        beq dsr_wall_right
        lda sprite_col
        beq dsr_edge_color
dsr_wall_right
        lda wall_edges
        and #WALL_EDGE_RIGHT
        beq dsr_have_color
        lda sprite_col
        cmp #SPRITE_W-1
        bne dsr_have_color
dsr_edge_color
        lda wall_edge_color
        sta pixel_color
dsr_have_color
        lda sprite_base_x
        clc
        adc sprite_col
        sta pixel_x
        jsr PutGtiaPixel
dsr_next
        inc sprite_col
        lda sprite_col
        cmp #SPRITE_W
        bne dsr_pixel
        rts

NextBitmapLine
        clc
        lda dest_ptr
        adc #GAME_ROW_BYTES
        sta dest_ptr
        bcc nbl_done
        inc dest_ptr+1
nbl_done
        ; Each display-list bank contains exactly 64 lines (64*40=$0a00
        ; bytes), but the banks live at $4000, $5000, and $6000 rather than
        ; consecutively. A 14-line tile can straddle either boundary, so remap
        ; the pointer instead of writing into the unused $4a00/$5a00 gaps.
        lda dest_ptr
        bne nbl_return
        lda dest_ptr+1
        cmp #>GAME_SCREEN1_END
        beq nbl_bank2
        cmp #>GAME_SCREEN2_END
        beq nbl_bank3
nbl_return
        rts
nbl_bank2
        mwa #GAME_SCREEN2 dest_ptr
        rts
nbl_bank3
        mwa #GAME_SCREEN3 dest_ptr
        rts

PutGtiaPixel
        lda pixel_x
        lsr
        tay
        lda pixel_x
        and #1
        bne pgp_low
        lda pixel_color
        asl
        asl
        asl
        asl
        sta pixel_bits
        lda (dest_ptr),y
        and #$0f
        ora pixel_bits
        sta (dest_ptr),y
        rts
pgp_low
        lda (dest_ptr),y
        and #$f0
        ora pixel_color
        sta (dest_ptr),y
        rts

ClearGameBitmap
        mwa #GAME_SCREEN1 dest_ptr
        ldx #10
        jsr ClearGamePages
        mwa #GAME_SCREEN2 dest_ptr
        ldx #10
        jsr ClearGamePages
        mwa #GAME_SCREEN3 dest_ptr
        ldx #10
ClearGamePages
cgb_page
        ldy #0
        lda #$88
cgb_byte
        sta (dest_ptr),y
        iny
        bne cgb_byte
        inc dest_ptr+1
        dex
        bne cgb_page
        rts

ClearTextScreen
        lda #0
        ldx #0
cts_loop
        sta SCREEN,x
        sta SCREEN+$100,x
        inx
        bne cts_loop
        rts

SetTextDisplay
        lda #0
        sta GPRIOR
        sta PRIOR
        mwa #DLIST_TEXT SDLSTL
        lda #$26
        sta COLOR0
        lda #$86
        sta COLOR1
        lda #$c6
        sta COLOR2
        lda #$0e
        sta COLOR3
        lda #$02
        sta COLBK
        rts

SetGameDisplay
        lda #$22
        sta PCOLR0              ; dark brown mortar and outlines
        lda #$28
        sta PCOLR1              ; orange/red
        lda #$0e
        sta PCOLR2              ; white/gray
        lda #$86
        sta PCOLR3              ; blue/purple
        lda #$08
        sta COLOR0              ; neutral gray, reserved for inactive players
        lda #$c8
        sta COLOR1              ; light green
        lda #$c4
        sta COLOR2              ; green
        lda #$1e
        sta COLOR3              ; yellow
        lda #$24
        sta COLBK               ; brown
        lda #$80
        sta GPRIOR
        sta PRIOR
        mwa #DLIST_GAME SDLSTL
        rts

InitCharset
        ldx #0
ic_os_loop
        lda $e000,x
        sta CHARSET,x
        lda $e100,x
        sta CHARSET+$100,x
        lda $e200,x
        sta CHARSET+$200,x
        lda $e300,x
        sta CHARSET+$300,x
        inx
        bne ic_os_loop
        rts

PrintAt
        sta print_col
        sty text_color
        lda screen_row_lo,x
        clc
        adc print_col
        sta dest_ptr
        lda screen_row_hi,x
        adc #0
        sta dest_ptr+1
        ldy #0
pa_loop
        lda (str_ptr),y
        beq pa_done
        sec
        sbc #32
        and #$3f
        ora text_color
        sta (dest_ptr),y
        iny
        bne pa_loop
pa_done
        rts

ShowTitle
        jsr SetTitleDisplay
        jsr ClearTextScreen
        mwa #title_tagline_1 str_ptr
        lda #0
        ldx #6
        ldy #$c0
        jsr PrintAt
        mwa #title_tagline_2 str_ptr
        lda #3
        ldx #7
        ldy #$c0
        jsr PrintAt
        jsr DrawTitleMenu
        rts

SetTitleDisplay
        lda #0
        sta GPRIOR
        sta PRIOR
        mwa #DLIST_TITLE SDLSTL
        lda #$26                ; amber bricks
        sta COLOR0
        lda #$86                ; cool blue room
        sta COLOR1
        lda #$ca                ; portal glow
        sta COLOR2
        lda #$0e                ; white title
        sta COLOR3
        lda #$02
        sta COLBK
        rts

DrawTitleMenu
        lda title_choice
        bne dtm_description
        mwa #menu_start_selected str_ptr
        lda #5
        ldx #2
        ldy #$80
        jsr PrintAt
        mwa #menu_description str_ptr
        lda #5
        ldx #3
        ldy #$40
        jsr PrintAt
        rts
dtm_description
        mwa #menu_start str_ptr
        lda #5
        ldx #2
        ldy #$40
        jsr PrintAt
        mwa #menu_description_selected str_ptr
        lda #5
        ldx #3
        ldy #$80
        jsr PrintAt
        rts

RunTitleMenu
        lda #0
        sta title_choice
        jsr WaitRelease         ; discard loader/boot key state before menu input
rtm_redraw
        jsr ShowTitle
rtm_loop
        jsr WaitFrame
        lda #0
        sta ATRACT
        jsr AnimateTitle

        lda CH
        cmp #$ff
        beq rtm_joystick
        pha
        lda #$ff
        sta CH
        pla
        and #$3f
        cmp #$0e                ; cursor up
        beq rtm_move
        cmp #$0f                ; cursor down
        beq rtm_move
        cmp #$21                ; space
        beq rtm_accept
        jmp rtm_loop

rtm_joystick
        lda STICK0
        cmp #14
        beq rtm_move
        cmp #13
        beq rtm_move
        lda CONSOL
        and #2                  ; SELECT changes the menu item
        beq rtm_move
        lda STRIG0
        beq rtm_accept
        lda CONSOL
        and #1                  ; START confirms
        bne rtm_loop

rtm_accept
        lda #$80
        ldx #2
        jsr Tone
        lda title_choice
        beq rtm_start
        jsr ShowDescription
        jmp rtm_redraw
rtm_start
        jsr WaitRelease
        rts

rtm_move
        lda title_choice
        eor #1
        sta title_choice
        jsr DrawTitleMenu
        lda #$b0
        ldx #1
        jsr Tone
rtm_wait_direction
        jsr WaitFrame
        lda #0
        sta ATRACT
        lda STICK0
        cmp #15
        bne rtm_wait_direction
        lda CONSOL
        and #2
        beq rtm_wait_direction
        lda SKSTAT
        and #4                  ; wait for a keyboard cursor key to be released
        beq rtm_wait_direction
        lda #$ff                ; discard any OS keyboard autorepeat event
        sta CH
        jmp rtm_loop

AnimateTitle
        lda RTCLOK2
        lsr
        lsr
        lsr
        and #7
        tax
        lda title_glow,x
        sta COLOR2
        rts

ShowDescription
        lda #0
        sta description_page
sd_page
        jsr SetTextDisplay
        jsr ClearTextScreen
        mwa #description_title str_ptr
        lda #3
        ldx #0
        ldy #$00
        jsr PrintAt

        ldx description_page
        lda description_page_lo,x
        sta str_ptr
        lda description_page_hi,x
        sta str_ptr+1
        lda #2
        sta description_row
        jsr PrintDescriptionLines

        ldx description_page
        cpx #DESCRIPTION_PAGE_COUNT-1
        beq sd_menu_prompt
        mwa #description_next str_ptr
        lda #4
        bne sd_print_prompt
sd_menu_prompt
        mwa #description_menu str_ptr
        lda #4
sd_print_prompt
        ldx #22
        ldy #$c0
        jsr PrintAt
        jsr WaitFire
        inc description_page
        lda description_page
        cmp #DESCRIPTION_PAGE_COUNT
        bcc sd_page
        rts

PrintDescriptionLines
pdl_next
        ldy #0
        lda (str_ptr),y
        cmp #$ff
        beq pdl_done
        lda description_row
        and #3                  ; cycle through all four text colors
        :6 asl
        tay
        lda #0
        ldx description_row
        jsr PrintAt
        iny
        tya
        clc
        adc str_ptr
        sta str_ptr
        bcc pdl_advance_row
        inc str_ptr+1
pdl_advance_row
        inc description_row
        jmp pdl_next
pdl_done
        rts

ShowIntro
        jsr SetTextDisplay
        jsr ClearTextScreen
        mwa #level_text str_ptr
        lda #6
        ldx #5
        ldy #$00
        jsr PrintAt
        lda level_no
        clc
        adc #1
        jsr PutLevelNumber
        ldx level_no
        lda level_title_lo,x
        sta str_ptr
        lda level_title_hi,x
        sta str_ptr+1
        lda #0
        ldx #9
        ldy #$40
        jsr PrintAt
        mwa #controls_text str_ptr
        lda #1
        ldx #14
        ldy #$c0
        jsr PrintAt
        mwa #undo_text str_ptr
        lda #1
        ldx #16
        ldy #$c0
        jsr PrintAt
        mwa #fire_text str_ptr
        lda #3
        ldx #20
        ldy #$80
        jsr PrintAt
        rts

PutLevelNumber
        cmp #10
        bcc pln_one
        ldx #1
pln_tens
        sec
        sbc #10
        cmp #10
        bcc pln_store
        inx
        bne pln_tens
pln_store
        pha
        txa
        ora #16
        sta SCREEN+5*20+12
        pla
        ora #16
        sta SCREEN+5*20+13
        rts
pln_one
        ora #16
        sta SCREEN+5*20+12
        rts

ShowClear
        jsr SetTextDisplay
        jsr ClearTextScreen
        mwa #clear_text str_ptr
        lda #3
        ldx #8
        ldy #$00
        jsr PrintAt
        mwa #continue_text str_ptr
        lda #2
        ldx #17
        ldy #$40
        jsr PrintAt
        rts

ShowComplete
        jsr SetTextDisplay
        jsr ClearTextScreen
        mwa #complete1 str_ptr
        lda #2
        ldx #7
        ldy #$00
        jsr PrintAt
        mwa #complete2 str_ptr
        lda #1
        ldx #11
        ldy #$80
        jsr PrintAt
        mwa #complete3 str_ptr
        lda #1
        ldx #17
        ldy #$40
        jsr PrintAt
        rts

; ---------------------------------------------------------------------------
; Timing and sound
; ---------------------------------------------------------------------------

WaitFrame
        lda RTCLOK2
wf_loop
        cmp RTCLOK2
        beq wf_loop
        rts

WaitFire
        jsr WaitRelease
wf_press
        lda #0
        sta ATRACT
        lda CH
        cmp #$ff
        beq wf_joystick
        pha
        lda #$ff
        sta CH
        pla
        and #$3f
        cmp #$21
        beq wf_got
wf_joystick
        lda STRIG0
        beq wf_got
        lda CONSOL
        and #1
        bne wf_press
wf_got
        lda #$80
        ldx #2
        jsr Tone
        jsr WaitRelease
        rts

WaitRelease
        lda STRIG0
        beq WaitRelease
        lda CONSOL
        and #1
        beq WaitRelease
        lda SKSTAT
        and #4
        beq WaitRelease
        lda #$ff
        sta CH
        rts

Tone
        sta AUDF1
        lda #$a6
        sta AUDC1
tone_wait
        jsr WaitFrame
        dex
        bne tone_wait
        lda #0
        sta AUDC1
        rts

UpdateMoveSound
        lda move_sound_timer
        beq ums_done
        dec move_sound_timer
        bne ums_done
        lda #0
        sta AUDC1
ums_done
        rts

VictorySound
        lda #$a0
        ldx #3
        jsr Tone
        lda #$78
        ldx #3
        jsr Tone
        lda #$58
        ldx #3
        jsr Tone
        lda #$38
        ldx #6
        jsr Tone
        rts

; ---------------------------------------------------------------------------
; Sprite data (6x7 pixels, doubled vertically to square-looking 6x14 tiles)
; ---------------------------------------------------------------------------

spr_blank
        :SPRITE_SIZE dta P_TRANS

spr_flag
        dta P_TRANS,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_TRANS
        dta P_TRANS,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_TRANS
        dta P_TRANS,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_TRANS
        dta P_TRANS,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_DARK,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_DARK,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_DARK,P_TRANS
spr_nflag
        dta P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_YELLOW
        dta P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_YELLOW
        dta P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_YELLOW
        dta P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_YELLOW
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_YELLOW
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_YELLOW
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_YELLOW
spr_target
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_BLUE,P_BLUE,P_BLUE,P_BLUE,P_TRANS
        dta P_TRANS,P_BLUE,P_TRANS,P_TRANS,P_BLUE,P_TRANS
        dta P_TRANS,P_BLUE,P_WHITE,P_WHITE,P_BLUE,P_TRANS
        dta P_TRANS,P_BLUE,P_TRANS,P_TRANS,P_BLUE,P_TRANS
        dta P_TRANS,P_BLUE,P_BLUE,P_BLUE,P_BLUE,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

; Brick faces keep their outermost pixels solid. Exposed boundaries are drawn
; afterward by the edge overlays, so adjoining cells become one continuous wall.
spr_wall1
spr_wall2
        dta P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW
        dta P_YELLOW,P_DARK,P_DARK,P_YELLOW,P_DARK,P_YELLOW
        dta P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW
        dta P_YELLOW,P_DARK,P_YELLOW,P_DARK,P_DARK,P_YELLOW
        dta P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW
        dta P_YELLOW,P_DARK,P_DARK,P_DARK,P_YELLOW,P_YELLOW
        dta P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW
spr_gwall
        dta P_GREEN1,P_GREEN1,P_GREEN1,P_GREEN1,P_GREEN1,P_GREEN1
        dta P_GREEN1,P_GREEN2,P_GREEN2,P_GREEN1,P_GREEN2,P_GREEN1
        dta P_GREEN1,P_GREEN1,P_GREEN1,P_GREEN1,P_GREEN1,P_GREEN1
        dta P_GREEN1,P_GREEN2,P_GREEN1,P_GREEN2,P_GREEN2,P_GREEN1
        dta P_GREEN1,P_GREEN1,P_GREEN1,P_GREEN1,P_GREEN1,P_GREEN1
        dta P_GREEN1,P_GREEN2,P_GREEN2,P_GREEN2,P_GREEN1,P_GREEN1
        dta P_GREEN1,P_GREEN1,P_GREEN1,P_GREEN1,P_GREEN1,P_GREEN1

spr_lock1
spr_lock2
        dta P_TRANS,P_TRANS,P_YELLOW,P_YELLOW,P_TRANS,P_TRANS
        dta P_TRANS,P_YELLOW,P_TRANS,P_TRANS,P_YELLOW,P_TRANS
        dta P_TRANS,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_TRANS
        dta P_YELLOW,P_YELLOW,P_TRANS,P_YELLOW,P_YELLOW,P_YELLOW
        dta P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW
        dta P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW
        dta P_TRANS,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_TRANS
spr_key1
spr_key2
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_YELLOW,P_YELLOW,P_YELLOW,P_TRANS,P_TRANS,P_TRANS
        dta P_YELLOW,P_TRANS,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW
        dta P_YELLOW,P_YELLOW,P_YELLOW,P_TRANS,P_YELLOW,P_TRANS
        dta P_TRANS,P_TRANS,P_YELLOW,P_YELLOW,P_YELLOW,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

; Normal players keep their black/orange/white/blue colors. The same frames are
; tinted solid green or blue for the other active player families.
spr_player_up0
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_TRANS
        dta P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE
        dta P_TRANS,P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_TRANS
        dta P_TRANS,P_BLUE,P_BLUE,P_BLUE,P_BLUE,P_TRANS
        dta P_TRANS,P_BLUE,P_TRANS,P_TRANS,P_BLUE,P_TRANS
spr_player_up1
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_TRANS
        dta P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE
        dta P_TRANS,P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_TRANS
        dta P_TRANS,P_BLUE,P_BLUE,P_BLUE,P_BLUE,P_TRANS
        dta P_BLUE,P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_BLUE
spr_player_down0
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_ORANGE,P_DARK,P_DARK,P_ORANGE,P_TRANS
        dta P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_TRANS
        dta P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE
        dta P_TRANS,P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_TRANS
        dta P_TRANS,P_BLUE,P_BLUE,P_BLUE,P_BLUE,P_TRANS
        dta P_TRANS,P_BLUE,P_TRANS,P_TRANS,P_BLUE,P_TRANS
spr_player_down1
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_ORANGE,P_DARK,P_DARK,P_ORANGE,P_TRANS
        dta P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_TRANS
        dta P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE
        dta P_TRANS,P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_TRANS
        dta P_TRANS,P_BLUE,P_BLUE,P_BLUE,P_BLUE,P_TRANS
        dta P_BLUE,P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_BLUE
spr_player_left0
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_TRANS,P_TRANS
        dta P_ORANGE,P_ORANGE,P_DARK,P_ORANGE,P_TRANS,P_TRANS
        dta P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_TRANS,P_TRANS
        dta P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_TRANS
        dta P_TRANS,P_WHITE,P_WHITE,P_WHITE,P_TRANS,P_TRANS
        dta P_TRANS,P_BLUE,P_BLUE,P_BLUE,P_TRANS,P_TRANS
        dta P_BLUE,P_TRANS,P_TRANS,P_BLUE,P_TRANS,P_TRANS
spr_player_left1
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_TRANS,P_TRANS
        dta P_ORANGE,P_ORANGE,P_DARK,P_ORANGE,P_TRANS,P_TRANS
        dta P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_TRANS,P_TRANS
        dta P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_TRANS
        dta P_TRANS,P_WHITE,P_WHITE,P_WHITE,P_TRANS,P_TRANS
        dta P_TRANS,P_BLUE,P_BLUE,P_BLUE,P_TRANS,P_TRANS
        dta P_TRANS,P_BLUE,P_TRANS,P_TRANS,P_BLUE,P_TRANS
spr_player_right0
        dta P_TRANS,P_TRANS,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_TRANS,P_ORANGE,P_DARK,P_ORANGE,P_ORANGE
        dta P_TRANS,P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_TRANS
        dta P_TRANS,P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE
        dta P_TRANS,P_TRANS,P_WHITE,P_WHITE,P_WHITE,P_TRANS
        dta P_TRANS,P_TRANS,P_BLUE,P_BLUE,P_BLUE,P_TRANS
        dta P_TRANS,P_TRANS,P_BLUE,P_TRANS,P_TRANS,P_BLUE
spr_player_right1
        dta P_TRANS,P_TRANS,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_TRANS,P_ORANGE,P_DARK,P_ORANGE,P_ORANGE
        dta P_TRANS,P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_TRANS
        dta P_TRANS,P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE
        dta P_TRANS,P_TRANS,P_WHITE,P_WHITE,P_WHITE,P_TRANS
        dta P_TRANS,P_TRANS,P_BLUE,P_BLUE,P_BLUE,P_TRANS
        dta P_TRANS,P_BLUE,P_TRANS,P_TRANS,P_BLUE,P_TRANS

spr_dead
        dta P_TRANS,P_GRAY,P_GRAY,P_GRAY,P_GRAY,P_TRANS
        dta P_TRANS,P_GRAY,P_WHITE,P_WHITE,P_GRAY,P_TRANS
        dta P_TRANS,P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_TRANS
        dta P_GRAY,P_GRAY,P_GRAY,P_GRAY,P_GRAY,P_GRAY
        dta P_TRANS,P_GRAY,P_GRAY,P_GRAY,P_GRAY,P_TRANS
        dta P_TRANS,P_GRAY,P_TRANS,P_TRANS,P_GRAY,P_TRANS
        dta P_GRAY,P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_GRAY

spr_crate1
spr_crate2
        dta P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW
        dta P_YELLOW,P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_YELLOW
        dta P_YELLOW,P_TRANS,P_YELLOW,P_YELLOW,P_TRANS,P_YELLOW
        dta P_YELLOW,P_TRANS,P_YELLOW,P_YELLOW,P_TRANS,P_YELLOW
        dta P_YELLOW,P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_YELLOW
        dta P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW
        dta P_TRANS,P_YELLOW,P_YELLOW,P_YELLOW,P_YELLOW,P_TRANS
spr_death
        dta P_TRANS,P_ORANGE,P_TRANS,P_TRANS,P_ORANGE,P_TRANS
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE
        dta P_TRANS,P_ORANGE,P_TRANS,P_ORANGE,P_ORANGE,P_TRANS
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE
        dta P_TRANS,P_ORANGE,P_ORANGE,P_TRANS,P_ORANGE,P_TRANS
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE
        dta P_TRANS,P_ORANGE,P_TRANS,P_TRANS,P_ORANGE,P_TRANS

player_sprite_lo
        dta l(spr_player_up0),l(spr_player_up1)
        dta l(spr_player_down0),l(spr_player_down1)
        dta l(spr_player_left0),l(spr_player_left1)
        dta l(spr_player_right0),l(spr_player_right1)
player_sprite_hi
        dta h(spr_player_up0),h(spr_player_up1)
        dta h(spr_player_down0),h(spr_player_down1)
        dta h(spr_player_left0),h(spr_player_left1)
        dta h(spr_player_right0),h(spr_player_right1)

; ---------------------------------------------------------------------------
; Tables, text, and mutable state
; ---------------------------------------------------------------------------

dx_table dta 0,0,$ff,1
dy_table dta $ff,1,0,0
row_offset_lo
        dta l(0),l(26),l(52),l(78),l(104),l(130),l(156)
        dta l(182),l(208),l(234),l(260),l(286),l(312)
row_offset_hi
        dta h(0),h(26),h(52),h(78),h(104),h(130),h(156)
        dta h(182),h(208),h(234),h(260),h(286),h(312)

title_tagline_1 dta c'KLON GRY TRANSITION',0
title_tagline_2 dta c'Z PUZZLESCRIPT',0
menu_start_selected dta c'> NOWA GRA',0
menu_start          dta c'  NOWA GRA',0
menu_description_selected dta c'> OPIS GRY',0
menu_description          dta c'  OPIS GRY',0
description_title dta c'HISTORIA ROMKA',0
description_next  dta c'FIRE - DALEJ',0
description_menu  dta c'FIRE - MENU',0

description_page_lo
        dta l(description_page_1),l(description_page_2)
        dta l(description_page_3),l(description_page_4)
        dta l(description_page_5)
description_page_hi
        dta h(description_page_1),h(description_page_2)
        dta h(description_page_3),h(description_page_4)
        dta h(description_page_5)

fire_text     dta c'FIRE OR START',0
level_text    dta c'LEVEL',0
controls_text dta c'JOYSTICK: MOVE',0
undo_text     dta c'Z UNDO  R RESTART',0
clear_text    dta c'LEVEL CLEAR!',0
continue_text dta c'FIRE TO CONTINUE',0
complete1     dta c'ROMEK COMPLETE',0
complete2     dta c'ALL ROOMS RESTORED',0
complete3     dta c'FIRE TO PLAY AGAIN',0
title_glow    dta $c4,$c6,$c8,$ca,$cc,$ce,$cc,$c8

level_title_lo
        dta l(level_title_00),l(level_title_01),l(level_title_02)
        dta l(level_title_03),l(level_title_04),l(level_title_05)
        dta l(level_title_06),l(level_title_07),l(level_title_08)
        dta l(level_title_09),l(level_title_10),l(level_title_11)
        dta l(level_title_12),l(level_title_13),l(level_title_14)
        dta l(level_title_15),l(level_title_16),l(level_title_17)
        dta l(level_title_18),l(level_title_19),l(level_title_20)
level_title_hi
        dta h(level_title_00),h(level_title_01),h(level_title_02)
        dta h(level_title_03),h(level_title_04),h(level_title_05)
        dta h(level_title_06),h(level_title_07),h(level_title_08)
        dta h(level_title_09),h(level_title_10),h(level_title_11)
        dta h(level_title_12),h(level_title_13),h(level_title_14)
        dta h(level_title_15),h(level_title_16),h(level_title_17)
        dta h(level_title_18),h(level_title_19),h(level_title_20)
level_title_00 dta c'ROOM',0
level_title_01 dta c'DOOR AND KEY',0
level_title_02 dta c'RESET',0
level_title_03 dta c'NOT ALLOWED',0
level_title_04 dta c'IMMUNE',0
level_title_05 dta c'ENTANGLEMENT',0
level_title_06 dta c'LUGGAGE',0
level_title_07 dta c'ONE KEY',0
level_title_08 dta c'DOORLEMMA',0
level_title_09 dta c'TWO KEYS',0
level_title_10 dta c'DEADLY',0
level_title_11 dta c'SWAP',0
level_title_12 dta c'ACCESS',0
level_title_13 dta c'WARP',0
level_title_14 dta c'NO ESCAPE',0
level_title_15 dta c'BLOCKADE',0
level_title_16 dta c'WHERE IS THE FLAG?',0
level_title_17 dta c'OVER THERE',0
level_title_18 dta c'SPAWNPOINT',0
level_title_19 dta c'WHERE IS THE TARGET?',0
level_title_20 dta c'THANKS FOR PLAYING',0

screen_row_lo
        :24 dta l(SCREEN+#*20)
screen_row_hi
        :24 dta h(SCREEN+#*20)

title_choice dta 0
description_page dta 0
description_row dta 0
level_no dta 0
player_x dta 0
player_y dta 0
player_type dta 0
reset1_x dta $ff
reset1_y dta $ff
reset2_x dta $ff
reset2_y dta $ff
moves dta 0
pushes dta 0
direction dta 0
player_frame dta 0
next_x dta 0
next_y dta 0
scan_x dta 0
scan_y dta 0
scan_entity dta 0
scan_spawn dta 0
shift_x dta 0
shift_y dta 0
chain_len dta 0
chain_index dta 0
chain_x :13 dta 0
chain_y :13 dta 0
chain_entity :13 dta 0
input_delay dta 0
move_sound_timer dta 0
console_latch dta 0
undo_valid dta 0
undo_reset1_x dta 0
undo_reset1_y dta 0
undo_reset2_x dta 0
undo_reset2_y dta 0
undo_moves dta 0
undo_pushes dta 0
load_x dta 0
load_y dta 0
level_char dta 0
load_entity dta 0
load_spawn dta 0
load_floor dta 0
grid_index dta a(0)
calc_x dta 0
find_x dta 0
find_y dta 0
find_type dta 0
find_start_x dta 0
find_end_x dta 0
found_x dta 0
found_y dta 0
transfer_type dta 0
dead_player_type dta 0
reset_family dta 0
restore_entity dta 0
has_target dta 0
open_target dta 0
floor_temp dta 0
room_start dta 0
drawn_room_start dta 0
dirty_world_x dta 0
dirty_entity dta 0
dirty_old_entity dta 0
visible_index dta 0
board_pos_x dta 0
board_pos_y dta 0
drawn_floor dta 0
draw_x dta 0
draw_y dta 0
sprite_base_x dta 0
sprite_base_y dta 0
tile_byte_offset dta 0
sprite_source_index dta 0
sprite_row_start dta 0
sprite_rows dta 0
sprite_repeats dta 0
sprite_wall_mode dta 0
sprite_tint dta P_TRANS
wall_edges dta 0
wall_edge_color dta P_DARK
skip_tile_clear dta 0
sprite_col dta 0
pixel_x dta 0
pixel_color dta 0
pixel_bits dta 0
math_temp dta 0
print_col dta 0
text_color dta 0

; Original Romek title artwork, packed four pixels per byte for ANTIC mode D.
        org TITLE_BITMAP
        ins 'assets/romek-title.2bpp'

; Description pages live in the unused tail of the title bitmap bank. Keeping
; this large block out of the main code segment prevents it from crossing into
; GAME_SCREEN1 at $4000.
        org DESCRIPTION_TEXT
description_page_1
        dta c'PAN ROMEK WROCIL Z',0
        dta c'DELEGACJI WCZESNIEJ,',0
        dta c'NIZ KTOKOLWIEK SIE',0
        dta c'SPODZIEWAL.',0
        dta c'GDY OTWORZYL DRZWI,',0
        dta c'ZAMARL - WIDOK',0
        dta c'PRZYPOMINAL SCENE Z',0
        dta c'TANIEGO FILMU',0
        dta c'EROTYCZNEGO.',0
        dta c'UBRANIA POROZRZUCANE',0
        dta c'PO KATACH, ZONA W',0
        dta c'LOZKU Z ROSLYM',0
        dta c'CZARNOSKORYM',0
        dta c'MIESNIAKIEM, A NA',0
        dta c'ZIEMI...',0
        dta $ff

description_page_2
        dta c'JEGO UKOCHANE ATARI',0
        dta c'LEZALO PORZUCONE NA',0
        dta c'PODLODZE W RESZTKACH',0
        dta c'JEDZENIA. JOYSTICKI',0
        dta c'POLAMANE, STAN',0
        dta c'SPRZETU - NIEZNANY.',0
        dta c'- CO TU SIE, DO',0
        dta c'DIABLA, WYRABIA?!',0
        dta c'- WYRYCZAL WSCIEKLY',0
        dta c'ROMEK.',0
        dta c'JEDNAK WRZASK NIE',0
        dta c'ZROBIL NA PARZE',0
        dta c'WIEKSZEGO WRAZENIA.',0
        dta $ff

description_page_3
        dta c'SPOCONY NIEZNAJOMY',0
        dta c'WCIAZ MOCNO',0
        dta c'PONIEWIERAL JEGO',0
        dta c'ZONE, CZEMU',0
        dta c'TOWARZYSZYL ODGLOS',0
        dta c'MIAROWEGO, GLOSNEGO',0
        dta c'KLASKANIA.',0
        dta c'- DOSYC TEGO! -',0
        dta c'WRZASNAL ROMEK. -',0
        dta c'IDE DO LAZIENKI. I',0
        dta c'BIADA WAM, JESLI PO',0
        dta c'MOIM POWROCIE',0
        dta c'ZOSTANIE TU TEN',0
        dta c'BURDEL!',0
        dta $ff

description_page_4
        dta c'GDY PO PARU MINUTACH',0
        dta c'ROMEK OSTROZNIE',0
        dta c'UCHYLIL DRZWI, POKOJ',0
        dta c'LSNIL CZYSTOSCIA.',0
        dta c'LOZKO BYLO',0
        dta c'NIENAGANNIE ZASLANE,',0
        dta c'ATARI SPOCZYWALO',0
        dta c'BEZPIECZNIE NA',0
        dta c'BLACIE, A Z KUCHNI',0
        dta c'WYLONILA SIE ZONA Z',0
        dta c'TACA PELNA',0
        dta c'PARUJACYCH',0
        dta c'PYSZNOSCI,',0
        dta c'POSYLAJAC MU',0
        dta c'NIEWINNY USMIECH.',0
        dta $ff

description_page_5
        dta c'ROMEK BYL TAK',0
        dta c'ZACHWYCONY SWOIM',0
        dta c'GENIALNYM SPOSOBEM',0
        dta c'NA GASZENIE',0
        dta c'KRYZYSOW',0
        dta c'MALZENSKICH, ZE',0
        dta c'NATYCHMIAST',0
        dta c'ZAPROGRAMOWAL O TYM',0
        dta c'GRE NA SWOJ UKOCHANY',0
        dta c'KOMPUTER.',0
        dta c'OTO I ONA, DROGI',0
        dta c'GRACZU!',0
        dta $ff

; Level data occupies its own high-memory XEX segment.
        icl 'levels.inc'

; ---------------------------------------------------------------------------
; Display lists
; ---------------------------------------------------------------------------

        org DLIST_TEXT
        dta $70,$70,$70
        dta $46,a(SCREEN)
        :23 dta $06
        dta $41,a(DLIST_TEXT)

        org DLIST_GAME
        dta $4f,a(GAME_SCREEN1)
        :63 dta $0f
        dta $4f,a(GAME_SCREEN2)
        :63 dta $0f
        dta $4f,a(GAME_SCREEN3)
        :63 dta $0f
        dta $41,a(DLIST_GAME)

        org DLIST_TITLE
        dta $70,$70,$70
        dta $4d,a(TITLE_BITMAP)
        :63 dta $0d
        dta $46,a(SCREEN)
        :7 dta $06
        dta $41,a(DLIST_TITLE)

; DOS RUN address
        org $02e0
        dta a(Start)

        opt h-
