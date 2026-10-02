; Native NMOS 6502 packet decoder for all source CHR sets.
; Assemble with MADS. This module is NOT an Atari executable.
; Input: packed_src, packed_end (exclusive), unpack_dst, unpack_end
; (exclusive). Buffer ranges must not wrap around $ffff or overlap.
; Output: C clear on exact successful decode; C set on malformed/trailing
; input or a packet crossing the destination bound. Never writes past end.
; Clobbers A/X/Y and private ZP $e0-$e7. The engine adapter must save these
; bytes when invoking this module because the original game uses them.
packed_src = $e0
packed_end = $e2
unpack_dst = $e4
unpack_end = $e6

        opt h-
        org $1000
unpack_chr
        ldy #0
unpack_packet
        lda unpack_dst+1
        cmp unpack_end+1
        bcc unpack_more
        bne unpack_error
        lda unpack_dst
        cmp unpack_end
        bcc unpack_more
        bne unpack_error
        lda packed_src
        cmp packed_end
        bne unpack_error
        lda packed_src+1
        cmp packed_end+1
        bne unpack_error
        clc
        rts
unpack_more
        jsr unpack_read
        bcs unpack_error
        sta unpack_control
        and #$7f
        tax
        inx
        bit unpack_control
        bpl unpack_literal
        jsr unpack_read
        bcs unpack_error
        sta unpack_value
unpack_run
        lda unpack_value
        jsr unpack_write
        bcs unpack_error
        dex
        bne unpack_run
        jmp unpack_packet
unpack_literal
        jsr unpack_read
        bcs unpack_error
        jsr unpack_write
        bcs unpack_error
        dex
        bne unpack_literal
        jmp unpack_packet
unpack_error
        sec
        rts
unpack_read
        lda packed_src+1
        cmp packed_end+1
        bcc unpack_read_ok
        bne unpack_error
        lda packed_src
        cmp packed_end
        bcs unpack_error
unpack_read_ok
        lda (packed_src),y
        inc packed_src
        bne unpack_read_done
        inc packed_src+1
unpack_read_done
        clc
        rts
unpack_write
        sta unpack_pending
        lda unpack_dst+1
        cmp unpack_end+1
        bcc unpack_write_ok
        bne unpack_error
        lda unpack_dst
        cmp unpack_end
        bcs unpack_error
unpack_write_ok
        lda unpack_pending
        sta (unpack_dst),y
        inc unpack_dst
        bne unpack_write_done
        inc unpack_dst+1
unpack_write_done
        clc
        rts
unpack_control dta 0
unpack_value dta 0
unpack_pending dta 0
