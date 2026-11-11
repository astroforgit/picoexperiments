; Resident transitions between league code and the original game bank.
LEAGUE_BANK = $f1
LEAGUE_DATA = $9e
LEAGUE_TEXT = $7800

league_boot
        lda $d01f
        and #4
        beq legacy_boot         ; OPTION at boot starts the original menu
league_enter
        ldx #$ff
        txs
        lda #1
        sta league_screen
        sta menu_mode
        lda #LEAGUE_BANK
vbrel_32
        sta $d65f
        jmp $c000
legacy_boot
        jmp $970f

league_match_setup
        lda league_match
        beq legacy_setup
        ldx #10
save_classic
        lda $92b7,x
        sta classic_settings,x
        dex
        bpl save_classic
        ldx #7
league_settings
        lda league_cfg,x
        sta $92b7,x             ; modes, pitch, duration and team 1 options
        dex
        bpl league_settings
        ; Team 2 uses the same array with a four-byte stride.
        lda league_cfg+7
        sta $92be               ; team 2 controller
        lda league_away_formation
        sta $92bf
        lda league_away_shirt
        sta $92c0
        lda #4
        sta $92c1
        jsr $941c
        ldx #1
        lda league_cfg+7
        beq league_joystick
        dex
league_joystick
        lda #1
        sta $e282,x             ; C64 port 2 corresponds to Atari joystick 1
        rts
legacy_setup
        jmp $ee61

league_launch
        jsr league_game_bank
        lda #0
        jsr memb
        sta league_screen
        sta $de21
        sta $03fb
        sta $ee5b
        dec $ee5b               ; discard any in-progress legacy cup
        lda #$ff
        sta $de15
        lda #1
        sta first
        lda frames
        sta lastwait
        jmp $970f

league_match_end
        lda league_match
        beq legacy_match_end
        lda $010e              ; team slot 0 keeps this score across half-time
        sta league_goals
        lda $010f
        sta league_goals+1
        ldx #10
restore_classic
        lda classic_settings,x
        sta $92b7,x
        dex
        bpl restore_classic
        lda #1
        sta league_return
        jmp league_enter
legacy_match_end
        jmp $9faa

league_game_bank
        lda #GBANK
vbrel_33
        sta $d65f
        rts

; The menu builds a character screen in the league data bank. Copy its
; cells to the game bank and use the existing double-buffered renderer.
league_draw
        lda pending
        bne league_draw
        jsr blit_wait
        jsr league_game_bank
        ldx #0
league_copy
        lda LEAGUE_TEXT,x
        sta $c000,x
        lda LEAGUE_TEXT+$100,x
        sta $c100,x
        lda LEAGUE_TEXT+$200,x
        sta $c200,x
        cpx #232
        bcs league_copy_next
        lda LEAGUE_TEXT+$300,x
        sta $c300,x
league_copy_next
        inx
        bne league_copy
        lda #$ff
        sta $e4
        lda #0
        sta $de15
        sta $de21
        sta $11d7
        lda #3
        sta $11d8
        lda #$0c
        sta $11d9
        jsr render_tramp
        lda #LEAGUE_BANK
vbrel_34
        sta $d65f
        lda #LEAGUE_DATA
        jmp memb
