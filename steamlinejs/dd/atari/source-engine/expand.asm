; Convert a complete original 4 KB two-plane CHR set into 256 linear VBXE
; tiles (16 KB). Input: chr_src/chr_dst. No palettes are discarded: output
; is pixel indices 0..3, to be combined with the original attribute palette.
; Clobbers A/X/Y and private ZP $e0-$e3; caller saves game state.
chr_src = $e0
chr_dst = $e2

        opt h-
        org $1200
expand_chr
        lda #0
        sta expand_tiles
expand_tile
        lda #0
        sta expand_row
expand_row_loop
        ldy expand_row
        lda (chr_src),y
        sta expand_plane0
        tya
        ora #8
        tay
        lda (chr_src),y
        sta expand_plane1
        lda expand_row
        asl
        asl
        asl
        tay
        ldx #8
expand_pixel
        lda #0
        asl expand_plane1
        rol
        asl expand_plane0
        rol
        sta (chr_dst),y
        iny
        dex
        bne expand_pixel
        inc expand_row
        lda expand_row
        cmp #8
        bne expand_row_loop
        clc
        lda chr_src
        adc #16
        sta chr_src
        bcc expand_src_done
        inc chr_src+1
expand_src_done
        clc
        lda chr_dst
        adc #64
        sta chr_dst
        bcc expand_dst_done
        inc chr_dst+1
expand_dst_done
        dec expand_tiles
        bne expand_tile
        rts
expand_tiles dta 0
expand_row dta 0
expand_plane0 dta 0
expand_plane1 dta 0
