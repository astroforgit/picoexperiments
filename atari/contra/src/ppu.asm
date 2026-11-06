; ------------------------------------------------------------------
; NES PPU and mapper services called by the translated banks.
; The nametables live in RAM shadows; changed tiles are marked dirty
; and redrawn into the VRAM nametable bitmaps by the renderer.
; Every service preserves the registers the original code preserved.
; ------------------------------------------------------------------

; ---- $2007 writes: value in A, X or Y; A/X/Y/P preserved
ppu_w_a php
        sta pw_val
        sta pw_a
        jmp pw_core
ppu_w_x php
        sta pw_a
        stx pw_val
        jmp pw_core
ppu_w_y php
        sta pw_a
        sty pw_val
pw_core stx pw_x
        sty pw_y
        jsr ppu_store
        ldy pw_y
        lda VMADDL
        clc
        adc ppu_inc
        sta VMADDL
        bcc pw_1
        inc VMADDH
pw_1    ldx pw_x
        lda pw_a
        plp
        rts

; store pw_val at PPU address VMADDH:VMADDL (no increment). A/X/Y clobbered.
ppu_store
        lda VMADDH
        and #$3F
        cmp #$20
        bcs ps_nt
        jmp chr_store
ps_nt
        cmp #$3F
        beq ps_pal
        tay                     ; Y = address high byte
        lda nt_page,y
        sta ps_ld+2
        sta ps_st+2
        ldx VMADDL
ps_ld   lda $FF00,x
        cmp pw_val
        beq ps_rts              ; unchanged
        lda pw_val
ps_st   sta $FF00,x
        lda nt_physof,y
        sta pw_phys
        tya
        and #3
        cmp #3
        bne ps_tile
        cpx #$C0
        bcs ps_attr
ps_tile asl                     ; DIRTY index: phys*128 + (hi&3)*32 + lo/8
        asl
        asl
        asl
        asl
        sta pw_t
        txa
        lsr
        lsr
        lsr
        ora pw_t
        ldy pw_phys
        ora phys_row128,y
        tay
        txa
        and #7
        tax
        lda DIRTY,y
        ora bitmask,x
        sta DIRTY,y
        tya                     ; ROWDIRTY index: phys*32 + row
        and #$7F
        lsr
        lsr
        ldy pw_phys
        ora phys_row32,y
        tay
        lda #1
        sta ROWDIRTY,y
        sta any_dirty
        jsr record_row_tile
ps_rts  rts

ps_pal  lda VMADDL
        and #$1F
        tax
        and #3
        bne ps_p1
        txa
        and #$0F
        tax
ps_p1   lda pw_val
        and #$3F
        cmp PALSH,x
        beq ps_rts
        sta PALSH,x
        lda #1
        sta pal_dirty
        rts

ps_attr txa
        sec
        sbc #$C0
        sta pw_t                ; attribute index 0..63
        and #1
        tax
        lda attr_mask,x
        sta pw_mask
        lda pw_t
        and #7
        lsr
        sta pw_col              ; dirty byte within a row
        lda pw_t
        lsr
        lsr
        lsr
        asl
        asl
        sta pw_row              ; first tile row
        ldx pw_phys
        lda pw_row
        clc
        adc phys_row32,x
        tay                     ; ROWDIRTY index
        lda pw_row
        asl
        asl
        adc pw_col
        adc phys_row128,x
        tax                     ; DIRTY index
        lda #4
        sta pw_t
pa_loop lda pw_row
        cmp #30
        bcs pa_done
        lda DIRTY,x
        ora pw_mask
        sta DIRTY,x
        lda #1
        sta ROWDIRTY,y
        inc pw_row
        iny
        inx
        inx
        inx
        inx
        dec pw_t
        bne pa_loop
pa_done lda #1
        sta any_dirty
        rts
attr_mask dta $0F,$F0

; ---- $2007 read (dummy reads only): A = value, flags N/Z; X/Y and C/V kept
ppu_r_a php
        stx pw_x
        lda VMADDH
        and #$3F
        cmp #$20
        bcc pr_zero
        cmp #$3F
        beq pr_pal
        tax
        lda nt_page,x
        sta pr_ld+2
        ldx VMADDL
pr_ld   lda $FF00,x
        jmp pr_out
pr_pal  lda VMADDL
        and #$1F
        tax
        lda PALSH,x
        jmp pr_out
pr_zero lda #0
pr_out  sta pw_val
        lda VMADDL
        clc
        adc ppu_inc
        sta VMADDL
        bcc pr_1
        inc VMADDH
pr_1    ldx pw_x
        plp
        lda pw_val
        rts

; ---- mirroring: rebuild nt_page/nt_physof for MMC1 mode (BANK_SWITCH_CTRL_REGS & 3)
set_mirroring
        and #3
        sta mirror
        asl
        asl
        sta sm_ofs
        ldx #0
sm_loop txa
        lsr
        lsr
        and #3
        ora sm_ofs
        tay
        lda nt_map,y            ; physical nametable 0/1
        sta nt_physof,x
        tay
        txa
        and #3
        ora phys_page,y
        sta nt_page,x
        inx
        cpx #$40
        bne sm_loop
        jmp mark_all_dirty
sm_ofs  dta 0
nt_map  dta 0,0,0,0, 1,1,1,1, 0,1,0,1, 0,0,1,1

mark_all_dirty
        ldx #0
        lda #$FF
mad_1   sta DIRTY,x
        inx
        bpl mad_1
        ldx #0
mad_2   sta DIRTY+128,x
        inx
        bpl mad_2
        ldx #29
        lda #1
mad_3   sta ROWDIRTY,x
        sta ROWDIRTY+32,x
        dex
        bpl mad_3
        sta any_dirty
        rts


; Y = physical tile row; pw_val = new pattern. Track membership in RAM.
record_row_tile
        tya
        lsr
        lsr
        lsr
        clc
        adc #>ROW_USES
        sta rr_load+2
        sta rr_store+2
        tya
        asl
        asl
        asl
        asl
        asl
        sta rr_load+1
        sta rr_store+1
        lda pw_val
        lsr
        lsr
        lsr
        tax
        lda pw_val
        and #7
        tay
rr_load lda ROW_USES,x
        ora bitmask,y
rr_store sta ROW_USES,x
        rts
