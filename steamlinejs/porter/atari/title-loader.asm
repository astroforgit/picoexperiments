; XEX INIT segments stage the title directly into VBXE RAM before the game
; overwrites the staging area. No asset is loaded underneath BASIC ROM.
; The loader itself is later replaced by the game's code at $2000.
        org $2000
title_load_bank
        dta $84                    ; SCREEN_A_V / $4000, MEMAC enabled
title_load_chunk
        php
        sei
        lda $f0
        pha
        lda $f1
        pha
        lda #0
        sta nmien
        sta $f0
        lda #$d6
        sta $f1
        ldy #$40
        lda ($f0),y
        cmp #$10
        beq title_load_found
        inc $f1
        lda ($f0),y
        cmp #$10
        bne title_load_exit
title_load_found
        lda #$40
        sta title_load_read+2
        sta title_load_write+2
title_load_page
        ldy #$5d
        lda #0
        sta ($f0),y
        ldx #0
title_load_read
        lda $4000,x
        sta title_load_bounce,x
        inx
        bne title_load_read
        lda title_load_bank
        sta ($f0),y
title_load_copy
        lda title_load_bounce,x
title_load_write
        sta $4000,x
        inx
        bne title_load_copy
        lda #0
        sta ($f0),y
        inc title_load_read+2
        inc title_load_write+2
        lda title_load_read+2
        cmp #$80
        bne title_load_page
        inc title_load_bank
title_load_exit
        pla
        sta $f1
        pla
        sta $f0
        lda #$40
        sta nmien
        plp
        rts
title_load_bounce
        :256 dta 0
        ert * > $4000

        org $4000
        ins 'data/title-0.dat'
        ini title_load_chunk
        org $4000
        ins 'data/title-1.dat'
        ini title_load_chunk
        org $4000
        ins 'data/title-2.dat'
        ini title_load_chunk
        org $4000
        ins 'data/title-3.dat'
        ini title_load_chunk

; Keep a clean gameplay background in a separate, immutable VRAM bank.
        org title_load_bank
        dta $80+[BACKGROUND_V>>14]
        org $4000
        ins 'data/background-0.dat'
        ini title_load_chunk
        org $4000
        ins 'data/background-1.dat'
        ini title_load_chunk
        org $4000
        ins 'data/background-2.dat'
        ini title_load_chunk
        org $4000
        ins 'data/background-3.dat'
        ini title_load_chunk
