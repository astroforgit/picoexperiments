; Surreal sketch scenery lives outside the main code/data segment.
        org $AC00

; Unpack 112x70 sketches (2x) and a 56x35 painted galaxy (4x) once.
; VRAM banks 4, 5 and 6 are separate from frames, room cache and sprites.
.proc upload_ruins
        jsr wait_blit
        lda #56
        sta ruins_cols
        lda #1
        sta ruins_scale_mask
        lda #32
        sta ruins_colour_base
        lda #<ruins_1_packed
        ldx #>ruins_1_packed
        ldy #$C0
        jsr unpack
        lda #<ruins_2_packed
        ldx #>ruins_2_packed
        ldy #$D0
        jsr unpack
        lda #28
        sta ruins_cols
        lda #3
        sta ruins_scale_mask
        lda #64
        sta ruins_colour_base
        lda #<galaxy_packed
        ldx #>galaxy_packed
        ldy #$E0
        jsr unpack
        lda #BANK_EN+BANK_XDL
vbreg_restore
        sta VBXE_BANK_SEL
        rts
unpack  sta text_src
        stx text_src+1
        sty ruins_mem_bank
        tya
vbreg_bank
        sta VBXE_BANK_SEL
        lda #0
        sta text_dst
        lda #>MEMW
        sta text_dst+1
        lda #140
        sta ruins_rows
?row    ldy #0
        ldx ruins_cols
?byte   sty ruins_out_col
        ldy #0
        lda (text_src),y
        sta ruins_byte
        inc text_src
        bne ?source_ok
        inc text_src+1
?source_ok
        ldy ruins_out_col
        lsr
        lsr
        lsr
        lsr
        ora ruins_colour_base
        jsr pair
        lda ruins_byte
        and #15
        ora ruins_colour_base
        jsr pair
        dex
        bne ?byte
        inc text_dst+1
        lda text_dst+1
        cmp #$A0
        bne ?bank_ok
        lda #>MEMW
        sta text_dst+1
        inc ruins_mem_bank
        lda ruins_mem_bank
vbreg_next_bank
        sta VBXE_BANK_SEL
?bank_ok
        dec ruins_rows
        beq ?done
        lda ruins_rows
        and ruins_scale_mask
        beq ?row
        ; Repeat each input scanline for the selected 2x or 4x enlargement.
        sec
        lda text_src
        sbc ruins_cols
        sta text_src
        lda text_src+1
        sbc #0
        sta text_src+1
        jmp ?row
?done   rts
pair    sta (text_dst),y
        iny
        sta (text_dst),y
        iny
        pha
        lda ruins_scale_mask
        cmp #3
        beq ?four
        pla
        rts
?four   pla
        sta (text_dst),y
        iny
        sta (text_dst),y
        iny
?done_pair
        rts
.endp

; One background blit during cache rebuild; never part of collision state.
.proc draw_ruins
        lda level_number
        cmp #6
        bcs ?later
        and #1
        beq ?first
        bne ?second
?later  lda #6
        bne ?selected
?first  lda #4
        bne ?selected
?second lda #5
?selected
        sta ruins_bank
        lda #BOARD_X+8
        sta calc_x
        lda #0
        sta calc_x+1
        lda #BOARD_Y
        sta calc_y
        jsr calc_addr
        lda calc_out
        sta bl_dst
        lda calc_out+1
        sta bl_dst+1
        lda calc_out+2
        sta bl_dst+2
        lda #0
        sta bl_src
        sta bl_src+1
        sta bl_ssy
        sta bl_w+1
        sta bl_xor
        sta bl_mode
        lda ruins_bank
        sta bl_src+2
        lda #1
        sta bl_ssy+1
        sta bl_ssx
        sta bl_dsx
        lda #<SCR_W
        sta bl_dsy
        lda #>SCR_W
        sta bl_dsy+1
        lda #223
        sta bl_w
        lda #139
        sta bl_h
        lda #$FF
        sta bl_and
        jsr do_blit

        ; Dark backing around the actual map objects preserves silhouettes.
        ; Re-evaluated after edits, before any gameplay sprite is painted.
        lda level_ptr
        sta work_ptr
        lda level_ptr+1
        sta work_ptr+1
        lda #0
        sta draw_row
        lda #BOARD_Y-8
        sta tile_y
?row    lda #0
        sta draw_col
        lda #BOARD_X-4
        sta tile_x
        lda #0
        sta tile_x+1
?cell   ldy #0
        lda (work_ptr),y
        cmp #T_EMPTY
        beq ?next
        cmp #T_PLAYER
        beq ?next
        cmp #T_FLY
        beq ?next
        lda tile_x
        sta calc_x
        lda tile_x+1
        sta calc_x+1
        lda tile_y
        sta calc_y
        lda #18
        ldx #20
        ldy #C_BOARD
        jsr small_fill
?next   inc work_ptr
        bne ?ptr_ok
        inc work_ptr+1
?ptr_ok clc
        lda tile_x
        adc #TILE
        sta tile_x
        bcc ?x_ok
        inc tile_x+1
?x_ok   inc draw_col
        lda draw_col
        cmp #MAP_W
        bne ?cell
        clc
        lda tile_y
        adc #TILE
        sta tile_y
        inc draw_row
        lda draw_row
        cmp #MAP_H
        bne ?row
        rts
.endp
ruins_mem_bank dta 0
ruins_rows dta 0
ruins_byte dta 0
ruins_out_col dta 0
ruins_bank dta 0
ruins_cols dta 56
ruins_scale_mask dta 1
ruins_colour_base dta 32

; The caller already sets the original sprite origin at tile_x-3, tile_y.
.proc draw_sketch_platform
        lda level_number
        cmp #6
        bcs ?neon
        lda draw_col
        eor draw_row
        and #1
        beq ?first
        lda #<sketch_platform_1
        ldx #>sketch_platform_1
        jmp ?draw
?first  lda #<sketch_platform_0
        ldx #>sketch_platform_0
        jmp ?draw
?neon   lda draw_col
        eor draw_row
        and #1
        beq ?neon_first
        lda #<neon_platform_1
        ldx #>neon_platform_1
        jmp ?draw
?neon_first
        lda #<neon_platform_0
        ldx #>neon_platform_0
?draw   ldy #16
        jmp draw_tile_runs
.endp
        icl 'generated/sojka-platforms.inc'
        ert * > $B000
