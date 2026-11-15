; ---------------------------------------------------------------------------
; SOKOBAN ... IN 3D! - Atari XL/XE edition
; Native 6502 program, assembled with MADS 2.x
;
; Based on steamlinejs/sokonan3d/game.txt by Beekie.
; Joystick 1 moves, Z/OPTION undo, R/SELECT reset, SPACE/FIRE/START continues.
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
VDSLST  = $0200
CH      = $02fc

; Hardware registers
AUDF1   = $d200
AUDC1   = $d201
CONSOL  = $d01f
PRIOR   = $d01b
WSYNC   = $d40a
NMIEN   = $d40e

; Logical map tiles
T_WALL  = 0
T_FLOOR = 1
T_ORANGE= 2
T_BLUE  = 3
T_HOLE  = 4

; ANTIC mode 6 character color selectors (text rows)
C_ORANGE= $00
C_BLUE  = $40
C_GREEN = $80
C_WHITE = $c0

; GTIA mode 10 color indexes used by the exact PuzzleScript sprites.
P_DARK   = 0
P_ORANGE = 1
P_WHITE  = 2
P_BLUE   = 3
P_DEEP   = 4
P_GREEN1 = 5
P_GREEN2 = 6
P_BRICK  = 7
P_BG     = 8
P_TRANS  = $ff

SCREEN      = $4000
DLIST_TEXT  = $4400
CHARSET     = $4800
GAME_SCREEN1= $5000           ; first 64 GTIA scan lines (40 bytes each)
GAME_SCREEN2= $6000           ; second 64 lines; avoids ANTIC's 4K wrap
DLIST_GAME  = $6e00

BOARD_X = 18                  ; (80 - 9*5) / 2, rounded toward the center
BOARD_Y = 14                  ; (128 - 10*10) / 2
GAME_ROW_BYTES = 40

        org $2000

Start
        sei
        lda #0
        sta SDMCTL
        sta AUDC1

        jsr InitCharset
        mwa #DLIST_TEXT SDLSTL
        mwa #GameDLI VDSLST
        lda #>CHARSET
        sta CHBAS

        lda #$26                ; warm orange / brown
        sta COLOR0
        lda #$86                ; blue
        sta COLOR1
        lda #$c6                ; green
        sta COLOR2
        lda #$0e                ; cream / white
        sta COLOR3
        lda #$02                ; charcoal background
        sta COLBK
        lda #0
        sta GPRIOR
        sta PRIOR
        lda #$c0                ; OS vertical blank + display-list interrupts
        sta NMIEN

        lda #$22                ; normal-width playfield, DMA on
        sta SDMCTL
        cli

        jsr ShowTitle
        jsr WaitFire

        lda #0
        sta level_no

        jmp BeginLevel
BeginLevel
        jsr ShowIntro
        jsr WaitFire
        jsr ResetLevel

MainLoop
        jsr WaitFrame
        lda #0
        sta ATRACT

        jsr ReadKeyboard
        jsr ReadConsole
        jsr ReadJoystick
        jmp MainLoop

; ---------------------------------------------------------------------------
; Input and game flow
; ---------------------------------------------------------------------------

; Atari internal keyboard codes: Z=$17, R=$28. Modifier bits are ignored so
; either letter works regardless of Shift/Control state.
ReadKeyboard
        lda CH
        cmp #$ff
        beq rk_done
        pha
        lda #$ff
        sta CH                  ; consume this keypress
        pla
        and #$3f
        cmp #$17                ; Z: back / undo
        bne rk_reset
        jsr UndoMove
        rts
rk_reset
        cmp #$28                ; R: reset current level
        bne rk_done
        jsr ResetLevel
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
        and #4                  ; OPTION: undo
        bne rc_select
        jsr UndoMove
        rts
rc_select
        lda CONSOL
        and #2                  ; SELECT: reset level
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
        ldx #7
        stx input_delay

        cmp #14                 ; up
        bne rj_down
        lda #0
        jsr TryMove
        rts
rj_down
        cmp #13                 ; down
        bne rj_left
        lda #1
        jsr TryMove
        rts
rj_left
        cmp #11                 ; left
        bne rj_right
        lda #2
        jsr TryMove
        rts
rj_right
        cmp #7                  ; right
        bne rj_done
        lda #3
        jsr TryMove
rj_done
        rts

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

        ; Higher states may walk across wall tops, but PuzzleScript's level
        ; bounds still block every collision layer.
        lda next_x
        cmp #9
        bcs tm_outside
        lda next_y
        cmp #10
        bcc tm_in_bounds
tm_outside
        jmp tm_blocked
tm_in_bounds

        lda level_no
        bne tm_3d

        ; Flat level: only crates move; targets remain part of the floor.
        ldx next_x
        ldy next_y
        jsr GetTile
        cmp #T_WALL
        beq tm_blocked
        jsr CrateAtNext
        cmp #$ff
        bne tm_flat_push
        jmp tm_walk
tm_flat_push

        sta moving_crate
        tax
        lda crate_x,x
        ldy direction
        clc
        adc dx_table,y
        sta beyond_x
        lda crate_y,x
        clc
        adc dy_table,y
        sta beyond_y

        ldx beyond_x
        ldy beyond_y
        jsr GetTile
        cmp #T_WALL
        beq tm_blocked

        jsr CrateAtBeyond
        bcc tm_push
tm_blocked
        lda #$f0
        ldx #1
        jsr Tone
        rts

tm_push
        jsr SaveUndo
        ldx moving_crate
        lda beyond_x
        sta crate_x,x
        lda beyond_y
        sta crate_y,x
        inc pushes
        jmp tm_finish_player

tm_3d
        ; Crates share the player's layer; targets have their own layer. This
        ; permits a crate and target to combine in one cell. A combined pair
        ; is pushed together, as in the expanded PuzzleScript Pushable rules.
        ; A state-0 push also carries state-1 objects stacked on the pushable.
        ; State-1 pushes remain independent, so a player standing on a wall
        ; can push the upper object away from the lower one.
        lda player_z
        sta move_z

        ; At height two the original rules provide no push rule.  The player
        ; may walk, but a same-height crate still occupies its collision layer.
        cmp #2
        bne tm_3d_pushable
        jsr CrateAtNextZ
        cmp #$ff
        bne tm_blocked
        jmp tm_walk

tm_3d_pushable
        ; Ground-height walls block the player.  Higher objects can cross the
        ; top of a wall and will remain supported there.
        lda move_z
        bne tm_3d_find
        ldx next_x
        ldy next_y
        jsr GetTile
        cmp #T_WALL
        beq tm_blocked

tm_3d_find
        lda #$ff
        sta moving_crate
        sta moving_target
        sta carried_crate
        sta carried_target
        jsr CrateAtNextZ
        sta moving_crate
        jsr TargetAtNextZ
        sta moving_target
        lda moving_crate
        cmp #$ff
        bne tm_3d_have_pushable
        lda moving_target
        cmp #$ff
        bne tm_3d_have_pushable
        jmp tm_walk

tm_3d_have_pushable
        ; PuzzleScript's [> Obj0s Obj1s] rule gives the upper object the same
        ; movement as a moving object directly below it.  Only ground pushes
        ; do this: a height-one player addresses the upper layer by itself.
        lda move_z
        bne tm_3d_find_done
        inc move_z
        jsr CrateAtNextZ
        sta carried_crate
        jsr TargetAtNextZ
        sta carried_target
        dec move_z
tm_3d_find_done
        ldx direction
        lda next_x
        clc
        adc dx_table,x
        sta beyond_x
        lda next_y
        clc
        adc dy_table,x
        sta beyond_y
        ; PuzzleScript expands Pushable0/Pushable1 into every concrete pair.
        ; Consequently any stationary pushable ahead stops every member of a
        ; combined pair, even when the two objects use different collision
        ; layers.  Overlaps are created and removed through respawning.
        jsr CanMovePushablesZ
        bcs tm_3d_push_blocked

        ; A carried upper object must also have a free destination on its own
        ; height.  Treat the stack as one unit when either layer is blocked.
        lda carried_crate
        cmp #$ff
        bne tm_3d_check_upper
        lda carried_target
        cmp #$ff
        beq tm_3d_do_move
tm_3d_check_upper
        inc move_z
        jsr CanMovePushablesZ
        dec move_z
        bcc tm_3d_do_move
tm_3d_push_blocked
        jmp tm_blocked

tm_3d_do_move
        jsr SaveUndo
        ldx moving_crate
        cpx #$ff
        beq tm_3d_target
        lda beyond_x
        sta crate_x,x
        lda beyond_y
        sta crate_y,x
tm_3d_target
        ldx moving_target
        cpx #$ff
        beq tm_3d_count_push
        lda beyond_x
        sta target_x,x
        lda beyond_y
        sta target_y,x
tm_3d_count_push
        ldx carried_crate
        cpx #$ff
        beq tm_3d_carried_target
        lda beyond_x
        sta crate_x,x
        lda beyond_y
        sta crate_y,x
tm_3d_carried_target
        ldx carried_target
        cpx #$ff
        beq tm_3d_push_done
        lda beyond_x
        sta target_x,x
        lda beyond_y
        sta target_y,x
tm_3d_push_done
        inc pushes
        jmp tm_finish_player

tm_walk
        jsr SaveUndo

tm_finish_player
        lda next_x
        sta player_x
        lda next_y
        sta player_y
tm_finish_rules
        inc moves
        lda level_no
        beq tm_draw
        jsr Resolve3DRules
tm_draw
        jsr DrawDirtyMove

        lda #$90
        ldx #1
        jsr Tone
        jsr CheckWin
        bcc tm_done
        jsr LevelWon
tm_done
        rts

; Return A = crate index 0/1, or $ff when the next square is empty.
CrateAtNext
        ldx #0
can_loop
        lda crate_x,x
        cmp next_x
        bne can_next
        lda crate_y,x
        cmp next_y
        beq can_found
can_next
        inx
        cpx #2
        bne can_loop
        lda #$ff
        rts
can_found
        txa
        rts

; Return A = target index 0/1, or $ff when the next square has no target.
TargetAtNext
        ldx #0
tan_loop
        lda target_x,x
        cmp next_x
        bne tan_next
        lda target_y,x
        cmp next_y
        beq tan_found
tan_next
        inx
        cpx #2
        bne tan_loop
        lda #$ff
        rts
tan_found
        txa
        rts

; Carry set if a crate occupies the beyond square.
CrateAtBeyond
        ldx #0
cab_loop
        lda crate_x,x
        cmp beyond_x
        bne cab_next
        lda crate_y,x
        cmp beyond_y
        beq cab_found
cab_next
        inx
        cpx #2
        bne cab_loop
        clc
        rts
cab_found
        sec
        rts

; Return the same-height crate/target at next, or $ff.  Flat mode keeps using
; the height-free helpers above.
CrateAtNextZ
        ldx #0
cnz_loop
        lda crate_x,x
        cmp next_x
        bne cnz_next
        lda crate_y,x
        cmp next_y
        bne cnz_next
        lda crate_z,x
        cmp move_z
        beq cnz_found
cnz_next
        inx
        cpx #2
        bne cnz_loop
        lda #$ff
        rts
cnz_found
        txa
        rts

TargetAtNextZ
        ldx #0
tnz_loop
        lda target_x,x
        cmp next_x
        bne tnz_next
        lda target_y,x
        cmp next_y
        bne tnz_next
        lda target_z,x
        cmp move_z
        beq tnz_found
tnz_next
        inx
        cpx #2
        bne tnz_loop
        lda #$ff
        rts
tnz_found
        txa
        rts

; Carry clear means every same-height pushable can enter beyond. Ground walls
; block state zero only; state-one objects may move across their tops.
CanMovePushablesZ
        lda beyond_x
        cmp #9
        bcs cmpz_blocked
        lda beyond_y
        cmp #10
        bcs cmpz_blocked
        lda move_z
        bne cmpz_crates
        ldx beyond_x
        ldy beyond_y
        jsr GetTile
        cmp #T_WALL
        beq cmpz_blocked
cmpz_crates
        ldx #0
cmpz_crate_loop
        lda crate_x,x
        cmp beyond_x
        bne cmpz_crate_next
        lda crate_y,x
        cmp beyond_y
        bne cmpz_crate_next
        lda crate_z,x
        cmp move_z
        beq cmpz_blocked
cmpz_crate_next
        inx
        cpx #2
        bne cmpz_crate_loop
        ldx #0
cmpz_target_loop
        lda target_x,x
        cmp beyond_x
        bne cmpz_target_next
        lda target_y,x
        cmp beyond_y
        bne cmpz_target_next
        lda target_z,x
        cmp move_z
        beq cmpz_blocked
cmpz_target_next
        inx
        cpx #2
        bne cmpz_target_loop
        clc
        rts
cmpz_blocked
        sec
        rts

; Objects that enter Hole at ground height are removed and recreated at their
; transparent spawner at height two.  Gravity then lowers each object until a
; wall or another object supports it.  This is the stable-state equivalent of
; the original n1..n4 fall and FramePause respawn animation.
Resolve3DRules
        lda player_z
        bne r3d_crates
        ldx player_x
        ldy player_y
        jsr GetTile
        cmp #T_HOLE
        bne r3d_crates
        lda #5
        sta player_x
        lda #6
        sta player_y
        lda #2
        sta player_z

r3d_crates
        lda crate_z
        bne r3d_blue_crate
        ldx crate_x
        ldy crate_y
        jsr GetTile
        cmp #T_HOLE
        bne r3d_blue_crate
        lda #6
        sta crate_x
        lda #3
        sta crate_y
        lda #2
        sta crate_z
r3d_blue_crate
        lda crate_z+1
        bne r3d_targets
        ldx crate_x+1
        ldy crate_y+1
        jsr GetTile
        cmp #T_HOLE
        bne r3d_targets
        lda #3
        sta crate_x+1
        lda #4
        sta crate_y+1
        lda #2
        sta crate_z+1

r3d_targets
        lda target_z
        bne r3d_blue_target
        ldx target_x
        ldy target_y
        jsr GetTile
        cmp #T_HOLE
        bne r3d_blue_target
        lda #2
        sta target_x
        lda #7
        sta target_y
        lda #2
        sta target_z
r3d_blue_target
        lda target_z+1
        bne r3d_gravity
        ldx target_x+1
        ldy target_y+1
        jsr GetTile
        cmp #T_HOLE
        bne r3d_gravity
        lda #6
        sta target_x+1
        lda #3
        sta target_y+1
        lda #2
        sta target_z+1

r3d_gravity
        jsr ApplyGravity
        rts

ApplyGravity
ag_again
        lda #0
        sta gravity_changed
        ldx #0
        jsr LowerTarget
        ldx #1
        jsr LowerTarget
        ldx #0
        jsr LowerCrate
        ldx #1
        jsr LowerCrate
        jsr LowerPlayer
        lda gravity_changed
        bne ag_again
        rts

; Lower target X by one state when its destination target layer is free.
; A player also supports a falling target, as specified by the source rules.
LowerTarget
        stx gravity_index
        lda target_z,x
        beq lt_done
        sec
        sbc #1
        sta gravity_dest
        bne lt_player
        lda target_x,x
        pha
        lda target_y,x
        tay
        pla
        tax
        jsr GetTile
        cmp #T_WALL
        beq lt_done_restore
lt_player
        ldx gravity_index
        lda player_z
        cmp gravity_dest
        bne lt_other
        lda player_x
        cmp target_x,x
        bne lt_other
        lda player_y
        cmp target_y,x
        beq lt_done
lt_other
        txa
        eor #1
        tay
        lda target_z,y
        cmp gravity_dest
        bne lt_lower
        lda target_x,y
        cmp target_x,x
        bne lt_lower
        lda target_y,y
        cmp target_y,x
        beq lt_done
lt_lower
        dec target_z,x
        lda #1
        sta gravity_changed
lt_done
        rts
lt_done_restore
        ldx gravity_index
        rts

; Lower crate X by one state when the player/crate layer below is free.
LowerCrate
        stx gravity_index
        lda crate_z,x
        beq lc_done
        sec
        sbc #1
        sta gravity_dest
        bne lc_player
        lda crate_x,x
        pha
        lda crate_y,x
        tay
        pla
        tax
        jsr GetTile
        cmp #T_WALL
        beq lc_done_restore
lc_player
        ldx gravity_index
        lda player_z
        cmp gravity_dest
        bne lc_other
        lda player_x
        cmp crate_x,x
        bne lc_other
        lda player_y
        cmp crate_y,x
        beq lc_done
lc_other
        txa
        eor #1
        tay
        lda crate_z,y
        cmp gravity_dest
        bne lc_lower
        lda crate_x,y
        cmp crate_x,x
        bne lc_lower
        lda crate_y,y
        cmp crate_y,x
        beq lc_done
lc_lower
        dec crate_z,x
        lda #1
        sta gravity_changed
lc_done
        rts
lc_done_restore
        ldx gravity_index
        rts

; Player gravity uses every state-0/state-1 entity as support, matching Obj0s
; and Obj1s in game.txt.
LowerPlayer
        lda player_z
        beq lp_done
        sec
        sbc #1
        sta gravity_dest
        bne lp_crates
        ldx player_x
        ldy player_y
        jsr GetTile
        cmp #T_WALL
        beq lp_done
lp_crates
        ldx #0
lp_crate_loop
        lda crate_z,x
        cmp gravity_dest
        bne lp_crate_next
        lda crate_x,x
        cmp player_x
        bne lp_crate_next
        lda crate_y,x
        cmp player_y
        beq lp_done
lp_crate_next
        inx
        cpx #2
        bne lp_crate_loop
        ldx #0
lp_target_loop
        lda target_z,x
        cmp gravity_dest
        bne lp_target_next
        lda target_x,x
        cmp player_x
        bne lp_target_next
        lda target_y,x
        cmp player_y
        beq lp_done
lp_target_next
        inx
        cpx #2
        bne lp_target_loop
        dec player_z
        lda #1
        sta gravity_changed
lp_done
        rts

SaveUndo
        lda player_x
        sta undo_player_x
        lda player_y
        sta undo_player_y
        lda player_z
        sta undo_player_z
        lda crate_x
        sta undo_crate_x
        lda crate_y
        sta undo_crate_y
        lda crate_x+1
        sta undo_crate_x+1
        lda crate_y+1
        sta undo_crate_y+1
        lda crate_z
        sta undo_crate_z
        lda crate_z+1
        sta undo_crate_z+1
        lda target_x
        sta undo_target_x
        lda target_y
        sta undo_target_y
        lda target_x+1
        sta undo_target_x+1
        lda target_y+1
        sta undo_target_y+1
        lda target_z
        sta undo_target_z
        lda target_z+1
        sta undo_target_z+1
        lda moves
        sta undo_moves
        lda pushes
        sta undo_pushes
        lda #1
        sta undo_valid
        rts

UndoMove
        lda undo_valid
        bne um_have_undo
        rts
um_have_undo
        ; Keep the positions being left so undo can repaint only those cells.
        lda player_x
        sta dirty_player_x
        lda player_y
        sta dirty_player_y
        lda crate_x
        sta dirty_crate_x
        lda crate_y
        sta dirty_crate_y
        lda crate_x+1
        sta dirty_crate_x+1
        lda crate_y+1
        sta dirty_crate_y+1
        lda target_x
        sta dirty_target_x
        lda target_y
        sta dirty_target_y
        lda target_x+1
        sta dirty_target_x+1
        lda target_y+1
        sta dirty_target_y+1
        lda undo_player_x
        sta player_x
        lda undo_player_y
        sta player_y
        lda undo_player_z
        sta player_z
        lda undo_crate_x
        sta crate_x
        lda undo_crate_y
        sta crate_y
        lda undo_crate_x+1
        sta crate_x+1
        lda undo_crate_y+1
        sta crate_y+1
        lda undo_crate_z
        sta crate_z
        lda undo_crate_z+1
        sta crate_z+1
        lda undo_target_x
        sta target_x
        lda undo_target_y
        sta target_y
        lda undo_target_x+1
        sta target_x+1
        lda undo_target_y+1
        sta target_y+1
        lda undo_target_z
        sta target_z
        lda undo_target_z+1
        sta target_z+1
        lda undo_moves
        sta moves
        lda undo_pushes
        sta pushes
        lda #0
        sta undo_valid
        jsr DrawDirtyUndo
        lda #$b0
        ldx #2
        jsr Tone
um_done
        rts

ResetLevel
        lda #5
        sta player_x
        lda #6
        sta player_y
        lda #0
        sta player_z

        lda #6                  ; orange crate starts on blue target
        sta crate_x
        lda #3
        sta crate_y
        lda #3                  ; blue crate
        sta crate_x+1
        lda #4
        sta crate_y+1
        lda #0
        sta crate_z
        sta crate_z+1

        lda #2                  ; orange target / TargetL spawner
        sta target_x
        lda #7
        sta target_y
        lda #6                  ; blue target / TargetR spawner
        sta target_x+1
        lda #3
        sta target_y+1
        lda #0
        sta target_z
        sta target_z+1

        lda #0
        sta moves
        sta pushes
        sta undo_valid
        sta input_delay
        sta console_latch
        jsr DrawGameScreen
        rts

CheckWin
        lda crate_z
        ora target_z
        bne cw_no
        lda crate_x              ; matching colors may overlap in one cell
        cmp target_x
        bne cw_no
        lda crate_y
        cmp target_y
        bne cw_no
        lda crate_z+1
        ora target_z+1
        bne cw_no
        lda crate_x+1
        cmp target_x+1
        bne cw_no
        lda crate_y+1
        cmp target_y+1
        bne cw_no
        sec
        rts
cw_no
        clc
        rts

LevelWon
        jsr VictorySound
        jsr ShowClear
        jsr WaitFire
        inc level_no
        lda level_no
        cmp #2
        bcc lw_next
        jsr ShowComplete
        jsr WaitFire
        lda #0
        sta level_no
lw_next
        jsr ShowIntro
        jsr WaitFire
        jsr ResetLevel
        rts

; ---------------------------------------------------------------------------
; Drawing
; ---------------------------------------------------------------------------

ClearScreen
        lda #0
        ldx #0
cs_loop
        sta SCREEN,x
        sta SCREEN+$100,x
        sta SCREEN+$200,x
        sta SCREEN+$300,x
        inx
        bne cs_loop
        rts

ShowTitle
        jsr SetTextDisplay
        jsr ClearScreen
        mwa #title1 str_ptr
        lda #1
        ldx #4
        ldy #C_WHITE
        jsr PrintAt
        mwa #title2 str_ptr
        lda #5
        ldx #6
        ldy #C_ORANGE
        jsr PrintAt
        mwa #title3 str_ptr
        lda #1
        ldx #9
        ldy #C_BLUE
        jsr PrintAt
        mwa #title4 str_ptr
        lda #2
        ldx #15
        ldy #C_GREEN
        jsr PrintAt
        mwa #fire_text str_ptr
        lda #3
        ldx #19
        ldy #C_WHITE
        jsr PrintAt
        rts

ShowIntro
        jsr SetTextDisplay
        jsr ClearScreen
        lda level_no
        bne si_level2
        mwa #intro1a str_ptr
        lda #6
        ldx #5
        ldy #C_ORANGE
        jsr PrintAt
        mwa #intro1b str_ptr
        lda #3
        ldx #9
        ldy #C_WHITE
        jsr PrintAt
        mwa #intro1c str_ptr
        lda #2
        ldx #11
        ldy #C_WHITE
        jsr PrintAt
        jmp si_footer
si_level2
        mwa #intro2a str_ptr
        lda #1
        ldx #5
        ldy #C_BLUE
        jsr PrintAt
        mwa #intro2b str_ptr
        lda #2
        ldx #9
        ldy #C_WHITE
        jsr PrintAt
        mwa #intro2c str_ptr
        lda #2
        ldx #11
        ldy #C_GREEN
        jsr PrintAt
si_footer
        mwa #fire_text str_ptr
        lda #3
        ldx #18
        ldy #C_ORANGE
        jsr PrintAt
        rts

ShowClear
        jsr SetTextDisplay
        jsr ClearScreen
        mwa #clear1 str_ptr
        lda #2
        ldx #7
        ldy #C_ORANGE
        jsr PrintAt
        mwa #clear2 str_ptr
        lda #4
        ldx #11
        ldy #C_WHITE
        jsr PrintAt
        jsr PrintResult
        mwa #continue_text str_ptr
        lda #2
        ldx #18
        ldy #C_BLUE
        jsr PrintAt
        rts

ShowComplete
        jsr SetTextDisplay
        jsr ClearScreen
        mwa #complete1 str_ptr
        lda #1
        ldx #6
        ldy #C_ORANGE
        jsr PrintAt
        mwa #complete2 str_ptr
        lda #2
        ldx #10
        ldy #C_WHITE
        jsr PrintAt
        mwa #complete3 str_ptr
        lda #1
        ldx #13
        ldy #C_GREEN
        jsr PrintAt
        mwa #complete4 str_ptr
        lda #1
        ldx #18
        ldy #C_BLUE
        jsr PrintAt
        rts

DrawGameScreen
        jsr SetGameDisplay
        jsr ClearScreen
        mwa #controls1 str_ptr
        lda #1
        ldx #19
        ldy #C_WHITE
        jsr PrintAt
        mwa #controls2 str_ptr
        lda #1
        ldx #21
        ldy #C_WHITE
        jsr PrintAt
        jmp DrawBoard

DrawBoard
        jsr ClearGameBitmap
        lda #0
        sta board_pos_y
db_row
        lda #0
        sta board_pos_x
db_col
        jsr DrawBaseTile
        inc board_pos_x
        lda board_pos_x
        cmp #9
        bne db_col
        inc board_pos_y
        lda board_pos_y
        cmp #10
        bne db_row

        ; The 3D objects have the same cross-cell "top" pieces as game.txt.
        lda level_no
        beq db_entities
        jsr DrawLevel2Tops

db_entities
        lda level_no
        bne db_3d_entities
        jmp db_flat_entities
db_3d_entities

        ; Movable orange target (TargetL2Top above TargetL2).
        jsr SelectTargetLTop
        lda #$f6
        sta sprite_y_adjust
        ldx target_x
        ldy target_y
        jsr DrawSprite
        jsr SelectTargetLMain
        lda #0
        sta sprite_y_adjust
        ldx target_x
        ldy target_y
        jsr DrawSprite

        ; Movable blue target (TargetR2Top above TargetR2).
        jsr SelectTargetRTop
        lda #$f6
        sta sprite_y_adjust
        ldx target_x+1
        ldy target_y+1
        jsr DrawSprite
        jsr SelectTargetRMain
        lda #0
        sta sprite_y_adjust
        ldx target_x+1
        ldy target_y+1
        jsr DrawSprite

        ; Orange crate (CrateL2Top above CrateL2).
        jsr SelectCrateLTop
        lda #$f6                ; -10 scan lines: one 5x5 cell above
        sta sprite_y_adjust
        ldx crate_x
        ldy crate_y
        jsr DrawSprite
        jsr SelectCrateLMain
        lda #0
        sta sprite_y_adjust
        ldx crate_x
        ldy crate_y
        jsr DrawSprite

        ; Blue crate (CrateR2Top above CrateR2).
        jsr SelectCrateRTop
        lda #$f6
        sta sprite_y_adjust
        ldx crate_x+1
        ldy crate_y+1
        jsr DrawSprite
        jsr SelectCrateRMain
        lda #0
        sta sprite_y_adjust
        ldx crate_x+1
        ldy crate_y+1
        jsr DrawSprite

        ; Player2Top above Player2.
        jsr SelectPlayerTop
        lda #$f6
        sta sprite_y_adjust
        ldx player_x
        ldy player_y
        jsr DrawSprite
        jsr SelectPlayerMain
        lda #0
        sta sprite_y_adjust
        ldx player_x
        ldy player_y
        jsr DrawSprite
        jmp db_done

db_flat_entities
        mwa #spr_td_crate_l str_ptr
        lda #0
        sta sprite_y_adjust
        ldx crate_x
        ldy crate_y
        jsr DrawSprite
        mwa #spr_td_crate_r str_ptr
        ldx crate_x+1
        ldy crate_y+1
        jsr DrawSprite
        mwa #spr_td_player str_ptr
        ldx player_x
        ldy player_y
        jsr DrawSprite

db_done
        jsr DrawStatus
        rts

; Movement redraws only the old/new footprints of the player and both crates.
; The undo snapshot contains all positions from immediately before the move.
DrawDirtyMove
        ldx undo_player_x
        ldy undo_player_y
        jsr RedrawFootprint
        ldx player_x
        ldy player_y
        jsr RedrawFootprint
        ldx undo_crate_x
        ldy undo_crate_y
        jsr RedrawFootprint
        ldx crate_x
        ldy crate_y
        jsr RedrawFootprint
        ldx undo_crate_x+1
        ldy undo_crate_y+1
        jsr RedrawFootprint
        ldx crate_x+1
        ldy crate_y+1
        jsr RedrawFootprint
        lda level_no
        beq ddm_status
        ldx undo_target_x
        ldy undo_target_y
        jsr RedrawFootprint
        ldx target_x
        ldy target_y
        jsr RedrawFootprint
        ldx undo_target_x+1
        ldy undo_target_y+1
        jsr RedrawFootprint
        ldx target_x+1
        ldy target_y+1
        jsr RedrawFootprint
ddm_status
        jmp DrawStatus

; Undo uses the saved departure positions plus the now-restored game state.
DrawDirtyUndo
        ldx dirty_player_x
        ldy dirty_player_y
        jsr RedrawFootprint
        ldx player_x
        ldy player_y
        jsr RedrawFootprint
        ldx dirty_crate_x
        ldy dirty_crate_y
        jsr RedrawFootprint
        ldx crate_x
        ldy crate_y
        jsr RedrawFootprint
        ldx dirty_crate_x+1
        ldy dirty_crate_y+1
        jsr RedrawFootprint
        ldx crate_x+1
        ldy crate_y+1
        jsr RedrawFootprint
        lda level_no
        beq ddu_status
        ldx dirty_target_x
        ldy dirty_target_y
        jsr RedrawFootprint
        ldx target_x
        ldy target_y
        jsr RedrawFootprint
        ldx dirty_target_x+1
        ldy dirty_target_y+1
        jsr RedrawFootprint
        ldx target_x+1
        ldy target_y+1
        jsr RedrawFootprint
ddu_status
        jmp DrawStatus

; Redraw an entity's own cell and, in level two, the cell containing its
; PuzzleScript Top sprite. X/Y are logical board coordinates.
RedrawFootprint
        stx footprint_x
        sty footprint_y
        jsr RedrawCell
        lda level_no
        beq rf_done
        lda footprint_y
        beq rf_done
        tay
        dey
        ldx footprint_x
        jsr RedrawCell
rf_done
        rts

; Reconstruct one complete logical cell from the map and current entity state.
; This is the small dirty-region equivalent of the ordered full-board passes.
RedrawCell
        cpx #9
        bcs redcell_done
        cpy #10
        bcs redcell_done
        stx board_pos_x
        sty board_pos_y
        jsr DrawBaseTile
        lda level_no
        beq DrawFlatEntitiesInCell
        jsr DrawStaticTopInCell
        jmp Draw3DEntitiesInCell
redcell_done
        rts

DrawStaticTopInCell
        lda board_pos_y
        cmp #9
        beq dst_done
        clc
        adc #1
        sta redraw_below_y
        tay
        ldx board_pos_x
        jsr GetTile
        cmp #T_WALL
        beq dst_wall
        rts
dst_wall
        mwa #spr_wall0_top str_ptr
        jmp dst_draw
dst_draw
        lda #$f6
        sta sprite_y_adjust
        ldx board_pos_x
        ldy redraw_below_y
        jsr DrawSprite
dst_done
        rts

DrawFlatEntitiesInCell
        lda crate_x
        cmp board_pos_x
        bne dfec_blue
        lda crate_y
        cmp board_pos_y
        bne dfec_blue
        mwa #spr_td_crate_l str_ptr
        lda #0
        sta sprite_y_adjust
        ldx crate_x
        ldy crate_y
        jsr DrawSprite
dfec_blue
        lda crate_x+1
        cmp board_pos_x
        bne dfec_player
        lda crate_y+1
        cmp board_pos_y
        bne dfec_player
        mwa #spr_td_crate_r str_ptr
        lda #0
        sta sprite_y_adjust
        ldx crate_x+1
        ldy crate_y+1
        jsr DrawSprite
dfec_player
        lda player_x
        cmp board_pos_x
        bne dfec_done
        lda player_y
        cmp board_pos_y
        bne dfec_done
        mwa #spr_td_player str_ptr
        lda #0
        sta sprite_y_adjust
        ldx player_x
        ldy player_y
        jsr DrawSprite
dfec_done
        rts

Draw3DEntitiesInCell
        lda #$ff
        sta redraw_below_y
        lda board_pos_y
        cmp #9
        beq d3ec_target_l_top
        clc
        adc #1
        sta redraw_below_y

        ; Movable target top/main pairs are drawn before crates.
d3ec_target_l_top
        lda target_x
        cmp board_pos_x
        bne d3ec_target_l_main
        lda target_y
        cmp redraw_below_y
        bne d3ec_target_l_main
        jsr SelectTargetLTop
        lda #$f6
        sta sprite_y_adjust
        ldx target_x
        ldy target_y
        jsr DrawSprite
d3ec_target_l_main
        lda target_x
        cmp board_pos_x
        bne d3ec_target_r_top
        lda target_y
        cmp board_pos_y
        bne d3ec_target_r_top
        jsr SelectTargetLMain
        lda #0
        sta sprite_y_adjust
        ldx target_x
        ldy target_y
        jsr DrawSprite

d3ec_target_r_top
        lda target_x+1
        cmp board_pos_x
        bne d3ec_target_r_main
        lda target_y+1
        cmp redraw_below_y
        bne d3ec_target_r_main
        jsr SelectTargetRTop
        lda #$f6
        sta sprite_y_adjust
        ldx target_x+1
        ldy target_y+1
        jsr DrawSprite
d3ec_target_r_main
        lda target_x+1
        cmp board_pos_x
        bne d3ec_orange_top
        lda target_y+1
        cmp board_pos_y
        bne d3ec_orange_top
        jsr SelectTargetRMain
        lda #0
        sta sprite_y_adjust
        ldx target_x+1
        ldy target_y+1
        jsr DrawSprite

d3ec_orange_top
        ; Top/main pairs, in the same object order as the full renderer.
        lda crate_x
        cmp board_pos_x
        bne d3ec_orange_main
        lda crate_y
        cmp redraw_below_y
        bne d3ec_orange_main
        jsr SelectCrateLTop
        lda #$f6
        sta sprite_y_adjust
        ldx crate_x
        ldy crate_y
        jsr DrawSprite
d3ec_orange_main
        lda crate_x
        cmp board_pos_x
        bne d3ec_blue_top
        lda crate_y
        cmp board_pos_y
        bne d3ec_blue_top
        jsr SelectCrateLMain
        lda #0
        sta sprite_y_adjust
        ldx crate_x
        ldy crate_y
        jsr DrawSprite

d3ec_blue_top
        lda crate_x+1
        cmp board_pos_x
        bne d3ec_blue_main
        lda crate_y+1
        cmp redraw_below_y
        bne d3ec_blue_main
        jsr SelectCrateRTop
        lda #$f6
        sta sprite_y_adjust
        ldx crate_x+1
        ldy crate_y+1
        jsr DrawSprite
d3ec_blue_main
        lda crate_x+1
        cmp board_pos_x
        bne d3ec_player_top
        lda crate_y+1
        cmp board_pos_y
        bne d3ec_player_top
        jsr SelectCrateRMain
        lda #0
        sta sprite_y_adjust
        ldx crate_x+1
        ldy crate_y+1
        jsr DrawSprite

d3ec_player_top
        lda player_x
        cmp board_pos_x
        bne d3ec_player_main
        lda player_y
        cmp redraw_below_y
        bne d3ec_player_main
        jsr SelectPlayerTop
        lda #$f6
        sta sprite_y_adjust
        ldx player_x
        ldy player_y
        jsr DrawSprite
d3ec_player_main
        lda player_x
        cmp board_pos_x
        bne d3ec_done
        lda player_y
        cmp board_pos_y
        bne d3ec_done
        jsr SelectPlayerMain
        lda #0
        sta sprite_y_adjust
        ldx player_x
        ldy player_y
        jsr DrawSprite
d3ec_done
        rts

; Choose the literal PuzzleScript sprite for the object's settled height.
; All selectors leave the result in str_ptr for DrawSprite.
SelectTargetLMain
        lda target_z
        beq stlm_0
        cmp #1
        beq stlm_1
        mwa #spr_target_l2 str_ptr
        rts
stlm_1
        mwa #spr_target_l1 str_ptr
        rts
stlm_0
        mwa #spr_target_l0 str_ptr
        rts

SelectTargetLTop
        lda target_z
        beq stlt_0
        cmp #1
        beq stlt_1
        mwa #spr_target_l2_top str_ptr
        rts
stlt_1
        mwa #spr_target1_top str_ptr
        rts
stlt_0
        mwa #spr_blank str_ptr
        rts

SelectTargetRMain
        lda target_z+1
        beq strm_0
        cmp #1
        beq strm_1
        mwa #spr_target_r2 str_ptr
        rts
strm_1
        mwa #spr_target_r1 str_ptr
        rts
strm_0
        mwa #spr_target_r0 str_ptr
        rts

SelectTargetRTop
        lda target_z+1
        beq strt_0
        cmp #1
        beq strt_1
        mwa #spr_target_r2_top str_ptr
        rts
strt_1
        mwa #spr_target1_top str_ptr
        rts
strt_0
        mwa #spr_blank str_ptr
        rts

SelectCrateLMain
        lda crate_z
        beq sclm_0
        cmp #1
        beq sclm_1
        mwa #spr_crate_l2 str_ptr
        rts
sclm_1
        mwa #spr_crate_l1 str_ptr
        rts
sclm_0
        mwa #spr_crate_l0 str_ptr
        rts

SelectCrateLTop
        lda crate_z
        beq sclt_0
        cmp #1
        beq sclt_1
        mwa #spr_crate_l2_top str_ptr
        rts
sclt_1
        mwa #spr_crate_l1_top str_ptr
        rts
sclt_0
        mwa #spr_crate_l0_top str_ptr
        rts

SelectCrateRMain
        lda crate_z+1
        beq scrm_0
        cmp #1
        beq scrm_1
        mwa #spr_crate_r2 str_ptr
        rts
scrm_1
        mwa #spr_crate_r1 str_ptr
        rts
scrm_0
        mwa #spr_crate_r0 str_ptr
        rts

SelectCrateRTop
        lda crate_z+1
        beq scrt_0
        cmp #1
        beq scrt_1
        mwa #spr_crate_r2_top str_ptr
        rts
scrt_1
        mwa #spr_crate_r1_top str_ptr
        rts
scrt_0
        mwa #spr_crate_r0_top str_ptr
        rts

SelectPlayerMain
        lda player_z
        beq spm_0
        cmp #1
        beq spm_1
        mwa #spr_player2 str_ptr
        rts
spm_1
        mwa #spr_player1 str_ptr
        rts
spm_0
        mwa #spr_player0 str_ptr
        rts

SelectPlayerTop
        lda player_z
        beq spt_0
        cmp #1
        beq spt_1
        mwa #spr_player2_top str_ptr
        rts
spt_1
        mwa #spr_player1_top str_ptr
        rts
spt_0
        mwa #spr_player0_top str_ptr
        rts

; Draw the opaque/ground part of one logical map cell.
DrawBaseTile
        ldx board_pos_x
        ldy board_pos_y
        jsr GetTile
        sta drawn_tile
        cmp #T_HOLE
        beq dbt_hole

        mwa #spr_grass str_ptr
        jsr DrawCurrentSprite
        lda drawn_tile
        cmp #T_WALL
        beq dbt_wall
        cmp #T_ORANGE
        beq dbt_orange
        cmp #T_BLUE
        beq dbt_blue
        rts

dbt_hole
        lda level_no
        beq dbt_td_hole
        mwa #spr_hole str_ptr
        jmp DrawCurrentSprite
dbt_td_hole
        mwa #spr_td_hole str_ptr
        jmp DrawCurrentSprite

dbt_wall
        lda level_no
        beq dbt_td_wall
        mwa #spr_wall0 str_ptr
        jmp DrawCurrentSprite
dbt_td_wall
        mwa #spr_td_wall str_ptr
        jmp DrawCurrentSprite

dbt_orange
        lda level_no
        beq dbt_td_orange
        rts                     ; movable entity in the 3D level
dbt_td_orange
        mwa #spr_td_target_l str_ptr
        jmp DrawCurrentSprite

dbt_blue
        lda level_no
        beq dbt_td_blue
        rts                     ; movable entity in the 3D level
dbt_td_blue
        mwa #spr_td_target_r str_ptr
        jmp DrawCurrentSprite

DrawCurrentSprite
        lda #0
        sta sprite_y_adjust
        ldx board_pos_x
        ldy board_pos_y
        jmp DrawSprite

; Draw the pieces that PuzzleScript places in the cell above each 3D object.
DrawLevel2Tops
        lda #0
        sta board_pos_y
dlt_row
        lda #0
        sta board_pos_x
dlt_col
        ldx board_pos_x
        ldy board_pos_y
        jsr GetTile
        cmp #T_WALL
        beq dlt_wall
        jmp dlt_next
dlt_wall
        mwa #spr_wall0_top str_ptr
        jmp dlt_draw
dlt_draw
        lda #$f6
        sta sprite_y_adjust
        ldx board_pos_x
        ldy board_pos_y
        jsr DrawSprite
dlt_next
        inc board_pos_x
        lda board_pos_x
        cmp #9
        bne dlt_col
        inc board_pos_y
        lda board_pos_y
        cmp #10
        bne dlt_row
        rts

; X/Y = board cell. str_ptr = 5x5 sprite. P_TRANS pixels are untouched.
; Each PuzzleScript row is doubled vertically; the source pixels themselves
; are never stretched horizontally, cropped, or rearranged.
DrawSprite
        stx draw_x
        sty draw_y

        txa
        asl
        asl
        clc
        adc draw_x
        clc
        adc #BOARD_X
        sta sprite_base_x

        tya
        asl
        sta math_temp
        asl
        asl
        clc
        adc math_temp
        clc
        adc #BOARD_Y
        clc
        adc sprite_y_adjust
        sta sprite_base_y

        lda sprite_base_y
        cmp #64
        bcc ds_first_half
        sec
        sbc #64
        tax
        mwa #GAME_SCREEN2 dest_ptr
        jmp ds_seek_start
ds_first_half
        tax
        mwa #GAME_SCREEN1 dest_ptr
ds_seek_start
        cpx #0
        beq ds_row_ready
ds_seek_row
        clc
        lda dest_ptr
        adc #GAME_ROW_BYTES
        sta dest_ptr
        bcc ds_seek_no_carry
        inc dest_ptr+1
ds_seek_no_carry
        dex
        bne ds_seek_row

ds_row_ready
        lda #0
        sta sprite_source_index
        lda #5
        sta sprite_rows
ds_source_row
        lda sprite_source_index
        sta sprite_row_start
        jsr DrawSpriteRow
        jsr NextBitmapLine
        lda sprite_row_start
        sta sprite_source_index
        jsr DrawSpriteRow
        jsr NextBitmapLine
        dec sprite_rows
        bne ds_source_row
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
        sta pixel_color
        lda sprite_base_x
        clc
        adc sprite_col
        sta pixel_x
        jsr PutGtiaPixel
dsr_next
        inc sprite_col
        lda sprite_col
        cmp #5
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
        ldx #10                 ; 10 pages = 40*64 bytes
        jsr ClearGamePages
        mwa #GAME_SCREEN2 dest_ptr
        ldx #10
ClearGamePages
cgb_page
        ldy #0
        lda #$88                ; two background-colored GTIA pixels
cgb_byte
        sta (dest_ptr),y
        iny
        bne cgb_byte
        inc dest_ptr+1
        dex
        bne cgb_page
        rts

SetTextDisplay
        lda #0
        sta GPRIOR
        sta PRIOR
        sta dli_phase
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
        lda #$02                ; charcoal; also keeps GTIA side borders dark
        sta PCOLR0
        lda #$36                ; orange
        sta PCOLR1
        lda #$0e                ; white
        sta PCOLR2
        lda #$86                ; blue
        sta PCOLR3
        lda #$84                ; deep blue
        sta COLOR0
        lda #$c8                ; bright grass
        sta COLOR1
        lda #$c4                ; dark grass
        sta COLOR2
        lda #$26                ; brick light (also colors game status rows)
        sta COLOR3
        lda #$02                ; #313638 approximation
        sta COLBK
        lda #0                  ; text starts in normal GTIA priority mode
        sta GPRIOR
        sta PRIOR
        sta dli_phase
        mwa #DLIST_GAME SDLSTL
        rts

; The mixed game display needs normal mode for text and GTIA mode 10 only for
; the 128-line bitmap band. Two DLI markers toggle that hardware bit each frame.
GameDLI
        pha
        lda dli_phase
        eor #1
        sta dli_phase
        sta WSYNC
        beq gdli_text
        lda #$80
        bne gdli_set
gdli_text
        lda #0
gdli_set
        sta PRIOR
        pla
        rti

; Copy the OS font so the mode 6 title/status rows remain readable.
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

; Print a zero-terminated ATASCII string.
; A=column, X=row, Y=color selector.
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

DrawStatus
        mwa #status_text str_ptr
        lda #1
        ldx #1
        ldy #C_WHITE
        jsr PrintAt
        lda level_no
        clc
        adc #1+16+C_WHITE
        sta SCREEN+1*20+7
        lda moves
        ldx #<(SCREEN+1*20+16)
        ldy #>(SCREEN+1*20+16)
        jsr PutDecimalAt
        rts

PrintResult
        mwa #moves_text str_ptr
        lda #3
        ldx #13
        ldy #C_WHITE
        jsr PrintAt
        lda moves
        ldx #<(SCREEN+13*20+10)
        ldy #>(SCREEN+13*20+10)
        jsr PutDecimalAt
        mwa #pushes_text str_ptr
        lda #3
        ldx #15
        ldy #C_BLUE
        jsr PrintAt
        lda pushes
        ldx #<(SCREEN+15*20+11)
        ldy #>(SCREEN+15*20+11)
        jsr PutDecimalAt
        rts

; A=value, X=low destination address, Y=high destination address.
PutDecimalAt
        stx dest_ptr
        sty dest_ptr+1
        ldx #0
pda_hundreds
        cmp #100
        bcc pda_tens_start
        sec
        sbc #100
        inx
        bne pda_hundreds
pda_tens_start
        pha
        txa
        ora #16+C_WHITE
        ldy #0
        sta (dest_ptr),y
        pla
        ldx #0
pda_tens
        cmp #10
        bcc pda_ones
        sec
        sbc #10
        inx
        bne pda_tens
pda_ones
        pha
        txa
        ora #16+C_WHITE
        iny
        sta (dest_ptr),y
        pla
        ora #16+C_WHITE
        iny
        sta (dest_ptr),y
        rts

; X=x, Y=y, return A=tile.
GetTile
        stx temp_x
        ldx map_offset,y
        txa
        clc
        adc temp_x
        tax
        lda level_map,x
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
        cmp #$21                ; SPACE also continues on a real Atari keyboard
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
        rts

; A=frequency, X=duration in frames.
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
; Data
; ---------------------------------------------------------------------------

; Literal 5x5 object pixels from game.txt. P_TRANS is PuzzleScript '.'.
; The Atari palette is necessarily quantized, but pixel positions and layers
; are kept verbatim.
spr_grass
        dta P_GREEN2,P_GREEN2,P_GREEN2,P_GREEN2,P_GREEN2
        dta P_GREEN1,P_GREEN2,P_GREEN2,P_GREEN2,P_GREEN2
        dta P_GREEN2,P_GREEN2,P_GREEN2,P_GREEN1,P_GREEN2
        dta P_GREEN2,P_GREEN2,P_GREEN2,P_GREEN2,P_GREEN2
        dta P_GREEN2,P_GREEN1,P_GREEN2,P_GREEN2,P_GREEN2

spr_td_hole
        dta P_DARK,P_DARK,P_DARK,P_DARK,P_DARK
        dta P_BG,P_DARK,P_DARK,P_DARK,P_DARK
        dta P_DARK,P_DARK,P_DARK,P_BG,P_DARK
        dta P_DARK,P_DARK,P_DARK,P_DARK,P_DARK
        dta P_DARK,P_BG,P_DARK,P_DARK,P_DARK

spr_hole
        dta P_DARK,P_DARK,P_DARK,P_DARK,P_DARK
        dta P_DARK,P_BG,P_DARK,P_BG,P_DARK
        dta P_BG,P_BG,P_BG,P_BG,P_BG
        dta P_BG,P_BG,P_BG,P_BG,P_BG
        dta P_BG,P_BG,P_BG,P_BG,P_BG

spr_td_wall
        dta P_BRICK,P_BRICK,P_BRICK,P_ORANGE,P_BRICK
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE
        dta P_BRICK,P_ORANGE,P_BRICK,P_BRICK,P_BRICK
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE
        dta P_BRICK,P_BRICK,P_BRICK,P_ORANGE,P_BRICK

spr_td_target_l
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS
        dta P_TRANS,P_DEEP,P_ORANGE,P_DEEP,P_TRANS
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_td_target_r
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS
        dta P_TRANS,P_DEEP,P_BLUE,P_DEEP,P_TRANS
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_td_crate_l
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE
        dta P_ORANGE,P_TRANS,P_TRANS,P_TRANS,P_ORANGE
        dta P_ORANGE,P_TRANS,P_TRANS,P_TRANS,P_ORANGE
        dta P_ORANGE,P_TRANS,P_TRANS,P_TRANS,P_ORANGE
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE

spr_td_crate_r
        dta P_BLUE,P_BLUE,P_BLUE,P_BLUE,P_BLUE
        dta P_BLUE,P_TRANS,P_TRANS,P_TRANS,P_BLUE
        dta P_BLUE,P_TRANS,P_TRANS,P_TRANS,P_BLUE
        dta P_BLUE,P_TRANS,P_TRANS,P_TRANS,P_BLUE
        dta P_BLUE,P_BLUE,P_BLUE,P_BLUE,P_BLUE

spr_td_player
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_TRANS
        dta P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE
        dta P_TRANS,P_BLUE,P_BLUE,P_BLUE,P_TRANS
        dta P_TRANS,P_BLUE,P_TRANS,P_BLUE,P_TRANS

spr_wall0
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE
        dta P_BRICK,P_ORANGE,P_BRICK,P_BRICK,P_BRICK
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE
        dta P_BRICK,P_BRICK,P_BRICK,P_ORANGE,P_BRICK
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_DARK,P_ORANGE

spr_wall0_top
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_BRICK,P_BRICK,P_BRICK,P_ORANGE,P_BRICK

spr_blank
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_target_l0
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS
        dta P_TRANS,P_DEEP,P_ORANGE,P_DEEP,P_TRANS
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_target_r0
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS
        dta P_TRANS,P_DEEP,P_BLUE,P_DEEP,P_TRANS
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_target_l1
        dta P_TRANS,P_DEEP,P_ORANGE,P_DEEP,P_TRANS
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_target_r1
        dta P_TRANS,P_DEEP,P_BLUE,P_DEEP,P_TRANS
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_target1_top
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS

spr_crate_l0
        dta P_ORANGE,P_DARK,P_DARK,P_DARK,P_ORANGE
        dta P_ORANGE,P_TRANS,P_TRANS,P_TRANS,P_ORANGE
        dta P_ORANGE,P_TRANS,P_TRANS,P_TRANS,P_ORANGE
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE
        dta P_DARK,P_DARK,P_DARK,P_DARK,P_DARK

spr_crate_r0
        dta P_BLUE,P_DEEP,P_DEEP,P_DEEP,P_BLUE
        dta P_BLUE,P_TRANS,P_TRANS,P_TRANS,P_BLUE
        dta P_BLUE,P_TRANS,P_TRANS,P_TRANS,P_BLUE
        dta P_BLUE,P_BLUE,P_BLUE,P_BLUE,P_BLUE
        dta P_DEEP,P_DEEP,P_DEEP,P_DEEP,P_DEEP

spr_crate_l0_top
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE

spr_crate_r0_top
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_BLUE,P_BLUE,P_BLUE,P_BLUE,P_BLUE

spr_crate_l1
        dta P_ORANGE,P_TRANS,P_TRANS,P_TRANS,P_ORANGE
        dta P_ORANGE,P_TRANS,P_TRANS,P_TRANS,P_ORANGE
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE
        dta P_DARK,P_DARK,P_DARK,P_DARK,P_DARK
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_crate_r1
        dta P_BLUE,P_TRANS,P_TRANS,P_TRANS,P_BLUE
        dta P_BLUE,P_TRANS,P_TRANS,P_TRANS,P_BLUE
        dta P_BLUE,P_BLUE,P_BLUE,P_BLUE,P_BLUE
        dta P_DEEP,P_DEEP,P_DEEP,P_DEEP,P_DEEP
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_crate_l1_top
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE
        dta P_ORANGE,P_DARK,P_DARK,P_DARK,P_ORANGE

spr_crate_r1_top
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_BLUE,P_BLUE,P_BLUE,P_BLUE,P_BLUE
        dta P_BLUE,P_DEEP,P_DEEP,P_DEEP,P_BLUE

spr_player0
        dta P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_TRANS
        dta P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE
        dta P_WHITE,P_BLUE,P_BLUE,P_BLUE,P_WHITE
        dta P_TRANS,P_BLUE,P_DEEP,P_BLUE,P_TRANS
        dta P_TRANS,P_DEEP,P_TRANS,P_DEEP,P_TRANS

spr_player0_top
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_TRANS

spr_player1
        dta P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE
        dta P_WHITE,P_BLUE,P_BLUE,P_BLUE,P_WHITE
        dta P_TRANS,P_BLUE,P_DEEP,P_BLUE,P_TRANS
        dta P_TRANS,P_DEEP,P_TRANS,P_DEEP,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_player1_top
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_TRANS

spr_target_l2
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_target_r2
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_target_l2_top
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS
        dta P_TRANS,P_DEEP,P_ORANGE,P_DEEP,P_TRANS

spr_target_r2_top
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_DEEP,P_DEEP,P_DEEP,P_TRANS
        dta P_TRANS,P_DEEP,P_BLUE,P_DEEP,P_TRANS

spr_crate_l2
        dta P_ORANGE,P_TRANS,P_TRANS,P_TRANS,P_ORANGE
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE
        dta P_DARK,P_DARK,P_DARK,P_DARK,P_DARK
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_crate_r2
        dta P_BLUE,P_TRANS,P_TRANS,P_TRANS,P_BLUE
        dta P_BLUE,P_BLUE,P_BLUE,P_BLUE,P_BLUE
        dta P_DEEP,P_DEEP,P_DEEP,P_DEEP,P_DEEP
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_crate_l2_top
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE,P_ORANGE
        dta P_ORANGE,P_DARK,P_DARK,P_DARK,P_ORANGE
        dta P_ORANGE,P_TRANS,P_TRANS,P_TRANS,P_ORANGE

spr_crate_r2_top
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_BLUE,P_BLUE,P_BLUE,P_BLUE,P_BLUE
        dta P_BLUE,P_DEEP,P_DEEP,P_DEEP,P_BLUE
        dta P_BLUE,P_TRANS,P_TRANS,P_TRANS,P_BLUE

spr_player2
        dta P_WHITE,P_BLUE,P_BLUE,P_BLUE,P_WHITE
        dta P_TRANS,P_BLUE,P_DEEP,P_BLUE,P_TRANS
        dta P_TRANS,P_DEEP,P_TRANS,P_DEEP,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS

spr_player2_top
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_TRANS,P_TRANS,P_TRANS,P_TRANS
        dta P_TRANS,P_DARK,P_DARK,P_DARK,P_TRANS
        dta P_TRANS,P_ORANGE,P_ORANGE,P_ORANGE,P_TRANS
        dta P_WHITE,P_WHITE,P_WHITE,P_WHITE,P_WHITE

dx_table       dta 0,0,$ff,1
dy_table       dta $ff,1,0,0
map_offset     dta 0,9,18,27,36,45,54,63,72,81

; The playfield from game.txt. Entities are stored separately.
level_map
        dta 0,0,0,0,0,0,0,0,0
        dta 0,0,0,0,1,1,1,1,0
        dta 0,0,1,1,0,1,1,1,0
        dta 0,0,1,1,0,1,3,1,0
        dta 0,0,1,1,1,1,1,0,0
        dta 0,0,1,1,0,1,1,0,0
        dta 0,1,1,0,0,1,1,1,0
        dta 0,1,2,1,4,1,1,1,0
        dta 0,0,1,0,0,1,1,1,0
        dta 0,0,0,0,0,0,0,0,0

title1         dta c'SOKOBAN ... IN 3D!',0
title2         dta c'ATARI',0
title3         dta c'6502 NATIVE EDITION',0
title4         dta c'BEEKIE ADAPTATION',0
fire_text      dta c'FIRE OR START',0

intro1a        dta c'LEVEL 1',0
intro1b        dta c'TEST CHAMBER',0
intro1c        dta c'MATCH CRATE COLORS',0
intro2a        dta c'3D SYSTEM ONLINE',0
intro2b        dta c'SAME MAP. NEW DEPTH.',0
intro2c        dta c'NOTHING GOES WRONG',0

clear1         dta c'CHAMBER CLEAR!',0
clear2         dta c'CRATES DELIVERED',0
continue_text  dta c'FIRE TO CONTINUE',0
complete1      dta c'PRODUCTION READY!',0
complete2      dta c'THANKS FOR TESTING',0
complete3      dta c'ALL CRATES HOME',0
complete4      dta c'FIRE TO PLAY AGAIN',0

status_text    dta c'LEVEL 0  MOVES 000',0
controls1      dta c'Z/OPTION UNDO',0
controls2      dta c'R/SELECT RESET',0
moves_text     dta c'MOVES',0
pushes_text    dta c'PUSHES',0

screen_row_lo
        dta l(SCREEN+0*20),l(SCREEN+1*20),l(SCREEN+2*20),l(SCREEN+3*20)
        dta l(SCREEN+4*20),l(SCREEN+5*20),l(SCREEN+6*20),l(SCREEN+7*20)
        dta l(SCREEN+8*20),l(SCREEN+9*20),l(SCREEN+10*20),l(SCREEN+11*20)
        dta l(SCREEN+12*20),l(SCREEN+13*20),l(SCREEN+14*20),l(SCREEN+15*20)
        dta l(SCREEN+16*20),l(SCREEN+17*20),l(SCREEN+18*20),l(SCREEN+19*20)
        dta l(SCREEN+20*20),l(SCREEN+21*20),l(SCREEN+22*20),l(SCREEN+23*20)
screen_row_hi
        dta h(SCREEN+0*20),h(SCREEN+1*20),h(SCREEN+2*20),h(SCREEN+3*20)
        dta h(SCREEN+4*20),h(SCREEN+5*20),h(SCREEN+6*20),h(SCREEN+7*20)
        dta h(SCREEN+8*20),h(SCREEN+9*20),h(SCREEN+10*20),h(SCREEN+11*20)
        dta h(SCREEN+12*20),h(SCREEN+13*20),h(SCREEN+14*20),h(SCREEN+15*20)
        dta h(SCREEN+16*20),h(SCREEN+17*20),h(SCREEN+18*20),h(SCREEN+19*20)
        dta h(SCREEN+20*20),h(SCREEN+21*20),h(SCREEN+22*20),h(SCREEN+23*20)

board_row_lo
        dta l(SCREEN+5*20+5),l(SCREEN+6*20+5),l(SCREEN+7*20+5)
        dta l(SCREEN+8*20+5),l(SCREEN+9*20+5),l(SCREEN+10*20+5)
        dta l(SCREEN+11*20+5),l(SCREEN+12*20+5),l(SCREEN+13*20+5)
        dta l(SCREEN+14*20+5)
board_row_hi
        dta h(SCREEN+5*20+5),h(SCREEN+6*20+5),h(SCREEN+7*20+5)
        dta h(SCREEN+8*20+5),h(SCREEN+9*20+5),h(SCREEN+10*20+5)
        dta h(SCREEN+11*20+5),h(SCREEN+12*20+5),h(SCREEN+13*20+5)
        dta h(SCREEN+14*20+5)

; Zero-page pointers and state
str_ptr         = $80
dest_ptr        = $82

level_no        dta 0
player_x        dta 0
player_y        dta 0
player_z        dta 0
crate_x         dta 0,0
crate_y         dta 0,0
crate_z         dta 0,0
target_x        dta 0,0
target_y        dta 0,0
target_z        dta 0,0
moves           dta 0
pushes          dta 0
direction       dta 0
next_x          dta 0
next_y          dta 0
beyond_x        dta 0
beyond_y        dta 0
moving_crate    dta 0
moving_target   dta 0
carried_crate   dta 0
carried_target  dta 0
move_z          dta 0
gravity_changed dta 0
gravity_dest    dta 0
gravity_index   dta 0
input_delay     dta 0
console_latch   dta 0
undo_valid      dta 0
undo_player_x   dta 0
undo_player_y   dta 0
undo_player_z   dta 0
undo_crate_x    dta 0,0
undo_crate_y    dta 0,0
undo_crate_z    dta 0,0
undo_target_x   dta 0,0
undo_target_y   dta 0,0
undo_target_z   dta 0,0
undo_moves      dta 0
undo_pushes     dta 0
dirty_player_x  dta 0
dirty_player_y  dta 0
dirty_crate_x   dta 0,0
dirty_crate_y   dta 0,0
dirty_target_x  dta 0,0
dirty_target_y  dta 0,0
temp_x          dta 0
temp_y          dta 0
put_x           dta 0
print_col       dta 0
text_color      dta 0
board_pos_x     dta 0
board_pos_y     dta 0
drawn_tile      dta 0
draw_x          dta 0
draw_y          dta 0
sprite_y_adjust dta 0
sprite_base_x   dta 0
sprite_base_y   dta 0
sprite_source_index dta 0
sprite_row_start dta 0
sprite_rows     dta 0
sprite_col      dta 0
pixel_x         dta 0
pixel_color     dta 0
pixel_bits      dta 0
math_temp       dta 0
dli_phase       dta 0
footprint_x     dta 0
footprint_y     dta 0
redraw_below_y  dta 0

; ANTIC display list: 20 columns x 24 rows, four character colors.
        org DLIST_TEXT
        dta $70,$70,$70
        dta $46,a(SCREEN)
        :23 dta $06
        dta $41,a(DLIST_TEXT)

; Game display: three text rows, a centered 80x128 GTIA mode 10 bitmap,
; then five text rows. Two LMS blocks avoid ANTIC's 4K DMA wrap.
        org DLIST_GAME
        dta $70,$70,$70
        dta $46,a(SCREEN)
        dta $06,$86
        dta $4f,a(GAME_SCREEN1)
        :63 dta $0f
        dta $4f,a(GAME_SCREEN2)
        :62 dta $0f
        dta $8f
        dta $46,a(SCREEN+19*20)
        :4 dta $06
        dta $41,a(DLIST_GAME)

; DOS RUN address
        org $02e0
        dta a(Start)

        opt h-
