; ------------------------------------------------------------------
; Disk loader. The game calls $55DE (via $54B8) with A = file, Y = number
; of crunched segments, X = mode (0 crunched, 1 raw, 2 save). The files
; are in VRAM (gen/files.asm has the directory). The game's own
; decruncher ($54BD) runs; its byte fetch ($5659) reads VRAM, and its
; output store/back-reference fetch go through ls_store / lf_fetch, which
; send the VIC bank $C000-$FFFF to the VRAM image of that bank.
; ------------------------------------------------------------------
        icl '../gen/files.asm'

ldr_entry
        sei
        and #$7F                ; (the save of the high scores asks for $8C)
        sta ld_file
        sty ld_segs
        stx ld_mode
        lda $01
        pha
        lda #$34
        sta $01
        ldx ld_file
        jsr ld_open
        lda ld_mode
        beq ld_crunch
        cmp #1
        beq ld_raw
        jsr ld_save
        jmp ld_done
ld_crunch
        jsr $54BD
        dec ld_segs
        bne ld_crunch
        jmp ld_done
ld_raw  jsr ldr_get
        sta $C3
        jsr ldr_get
        sta $C4
        ldx ld_file
        lda fd_len_lo,x
        sec
        sbc #2
        sta ld_cnt
        lda fd_len_hi,x
        sbc #0
        sta ld_cnt+1
        ldy #0
ld_r1   lda ld_cnt
        ora ld_cnt+1
        beq ld_done
        jsr ldr_get
        eor #$B3
        sta ($C3),y
        inc $C3
        bne ld_r2
        inc $C4
ld_r2   lda ld_cnt
        bne ld_r3
        dec ld_cnt+1
ld_r3   dec ld_cnt
        jmp ld_r1
ld_done ; the file's patches: records (address, length, bytes), length 0 ends
        ldx ld_file
        lda fp_bank,x
        beq ld_np
        sta lg_bank
        lda fp_lo,x
        sta lg_rd+1
        lda fp_hi,x
        sta lg_rd+2
ld_p1   jsr ldr_get
        sta ZP
        jsr ldr_get
        sta ZP+1
        jsr ldr_get             ; (keeps P: test the length here)
        tax
        beq ld_np
        ldy #0
ld_p2   jsr ldr_get
        sta (ZP),y
        iny
        dex
        bne ld_p2
        jmp ld_p1
ld_np   jsr render_loaded
        pla
        sta $01
        ldx #0
        rts

; X = file: stream position at its start
ld_open lda fd_bank,x
        sta lg_bank
        lda fd_lo,x
        sta lg_rd+1
        lda fd_hi,x
        sta lg_rd+2
        rts

; mode 2: memory from ($C3) to $61FF, EOR $B3, becomes the file's contents
; (in the save buffer; later loads of the file read it from there)
ld_save ldx ld_file
        lda #MEMB_ON|(V_SAVE>>14)
        sta fd_bank,x
        sta lg_bank
        lda #<(WIN+(V_SAVE&$3FFF))
        sta fd_lo,x
        sta ls_w+1
        lda #>(WIN+(V_SAVE&$3FFF))
        sta fd_hi,x
        sta ls_w+2
        lda $C3
        jsr ls_put
        lda $C4
        jsr ls_put
        lda #2
        sta ld_cnt
        lda #0
        sta ld_cnt+1
        ldy #0
ls_s1   lda $C4
        cmp #$62
        bcs ls_s2
        lda ($C3),y
        eor #$B3
        jsr ls_put
        inc ld_cnt
        bne ls_s3
        inc ld_cnt+1
ls_s3   inc $C3
        bne ls_s1
        inc $C4
        bne ls_s1
ls_s2   ldx ld_file
        lda ld_cnt
        sta fd_len_lo,x
        lda ld_cnt+1
        sta fd_len_hi,x
        rts
ls_put  pha
        lda lg_bank
        sta memb_sh
vm_l3   sta VBX+VB_MEMB
        pla
ls_w    sta WIN
        inc ls_w+1
        bne ls_p1
        inc ls_w+2
ls_p1   lda #0
        sta memb_sh
vm_l4   sta VBX+VB_MEMB
        rts

; the decruncher's byte fetch ($5659): A = next byte, P, X, Y preserved
ldr_get php
        lda lg_bank
        sta memb_sh
vm_l1   sta VBX+VB_MEMB
lg_rd   lda WIN
        pha
        inc lg_rd+1
        bne lg_1
        inc lg_rd+2
        lda lg_rd+2
        cmp #>(WIN+$4000)
        bne lg_1
        lda #>WIN
        sta lg_rd+2
        inc lg_bank
lg_1    lda #0
        sta memb_sh
vm_l2   sta VBX+VB_MEMB
        pla
        plp
        rts

; decruncher output store ($552F: STA $FFFF,Y; operand written by $55CA)
ls_store
        php
        pha
        lda ls_op+2
        cmp #$BF
        bcs ls_slow
        pla
ls_op   sta $FFFF,y
        plp
        rts
ls_slow stx ld_x
        tya
        clc
        adc ls_op+1
        sta ls_x1+1
        sta ls_x2+1
        lda ls_op+2
        adc #0
        sta ls_x1+2
        cmp #$C0
        bcc ls_ram
        ; VIC bank: always the VRAM image, RAM as well for $C000-$C2FF and $F000+
        sec
        sbc #$C0-(>WIN)
        sta ls_x2+2
        lda #MEMB_ON|(V_VIC>>14)
        sta memb_sh
vm_l5   sta VBX+VB_MEMB
        pla
        pha
ls_x2   sta WIN
        lda #0
        sta memb_sh
vm_l6   sta VBX+VB_MEMB
        lda ls_x1+2
        cmp #$C3
        bcc ls_ram
        cmp #$F0
        bcc ls_out
ls_ram  pla
        pha
ls_x1   sta $FFFF
ls_out  pla
        ldx ld_x
        plp
        rts

; back-reference fetch ($5529: LDA $FFFF,Y; operand written at $55AC/$55B8,
; decremented at $5523)
lf_fetch
        php
        lda lf_op+2
        cmp #$BF
        bcs lf_slow
lf_op   lda $FFFF,y
        plp
        rts
lf_slow stx ld_x
        tya
        clc
        adc lf_op+1
        sta lf_x1+1
        sta lf_x2+1
        lda lf_op+2
        adc #0
        sta lf_x1+2
        cmp #$C0
        bcc lf_ram
        cmp #$C3
        bcc lf_ram
        cmp #$F0
        bcs lf_ram
        sec
        sbc #$C0-(>WIN)
        sta lf_x2+2
        lda #MEMB_ON|(V_VIC>>14)
        sta memb_sh
vm_l7   sta VBX+VB_MEMB
lf_x2   lda WIN
        tax
        lda #0
        sta memb_sh
vm_l8   sta VBX+VB_MEMB
        txa
        ldx ld_x
        plp
        rts
lf_ram
lf_x1   lda $FFFF
        ldx ld_x
        plp
        rts
