; Replacement getbyte for PMZ1. $3000-$3FFF is a circular 4K history.
; Leaves X untouched, returns A and its N/Z flags, as the PMS reader requires.
lz_write = $f2
lz_read = $f4
lz_reset
        lda #0
        sta lz_left
        sta lz_write
        lda #$30
        sta lz_write+1
        rts
lz_raw  ldy #0
        lda (ptr),y
        inc ptr
        bne lz_raw_done
        inc ptr+1
lz_raw_done
        ora #0
        rts
getbyte lda lz_left
        bne lz_have
        jsr lz_raw
        bmi lz_match
        clc
        adc #1
        sta lz_left
        lda #0
        sta lz_mode
        beq lz_have
lz_match
        and #$7f
        clc
        adc #3
        sta lz_left
        lda #1
        sta lz_mode
        jsr lz_raw
        sta lz_distance
        jsr lz_raw
        sta lz_distance+1
        sec
        lda lz_write
        sbc lz_distance
        sta lz_read
        lda lz_write+1
        sbc lz_distance+1
        and #$0f
        ora #$30
        sta lz_read+1
lz_have dec lz_left
        lda lz_mode
        bne lz_copy
        jsr lz_raw
        jmp lz_store
lz_copy ldy #0
        lda (lz_read),y
        inc lz_read
        bne lz_store
        inc lz_read+1
        pha
        lda lz_read+1
        and #$0f
        ora #$30
        sta lz_read+1
        pla
lz_store
        ldy #0
        sta (lz_write),y
        inc lz_write
        bne lz_return
        inc lz_write+1
        pha
        lda lz_write+1
        and #$0f
        ora #$30
        sta lz_write+1
        pla
lz_return
        ora #0
        rts
lz_left dta 0
lz_mode dta 0
lz_distance dta 0,0
