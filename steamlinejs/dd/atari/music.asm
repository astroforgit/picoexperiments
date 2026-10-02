; Original SAP player owns all four POKEY voices while playing.
; Swap its $cb-$dd workspace with the renderer's zero-page workspace.
music_enter
        ldx #18
music_enter_loop
        lda $cb,x
        sta music_game_zp,x
        lda music_zp,x
        sta $cb,x
        dex
        bpl music_enter_loop
        rts
music_leave
        ldx #18
music_leave_loop
        lda $cb,x
        sta music_zp,x
        lda music_game_zp,x
        sta $cb,x
        dex
        bpl music_leave_loop
        rts
music_init
        lda #1
        sta music_busy        ; VBI must not enter the self-modifying player here
        jsr music_enter
        lda #0
        ldx #$00
        ldy #$a4
        jsr $0600
        jsr music_leave
        lda #0
        sta music_busy
        rts
music_install
        ; This game has no DLI. Disable NMI only while replacing the vector.
        lda #0
        sta $d40e
        mwa $222 music_old_vbi
        mwa #music_vbi $222
        lda #$40
        sta $d40e
        rts
music_vbi
        ; Chain the OS immediate VBI, retaining its clock/keyboard processing.
        pha
        txa
        pha
        tya
        pha
        php
        cld
        lda music_busy
        bne music_vbi_done
        jsr music_frame
music_vbi_done
        plp
        pla
        tay
        pla
        tax
        pla
        jmp (music_old_vbi)
music_frame
        lda mode
        cmp #PLAY
        bne music_silence
        lda muted
        bne music_silence
        ; Exactly one player call per VBI; never burst to catch up rendering.
        ; Launch this NTSC composition in NTSC. PAL fallback is stable at 50 Hz.
        jsr music_enter
        jsr $0603
        jsr music_leave
music_done
        rts
music_silence
        lda #0
        sta $d201
        sta $d203
        sta $d205
        sta $d207
        rts
music_busy dta 0
music_old_vbi dta a(0)
music_zp :19 dta 0
music_game_zp :19 dta 0
