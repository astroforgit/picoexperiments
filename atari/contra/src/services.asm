; Native Atari replacements for NES register accesses. Stores preserve A/X/Y/P.
ctrl_a  php
        pha
        sta nmi_on
        sta lat_ctrl
        and #4
        beq ctl_inc1
        lda #32
        bne ctl_inc
ctl_inc1 lda #1
ctl_inc sta ppu_inc
        pla
        plp
        rts
mask_a  sta PPU_MASK_STATE
        rts
addr_a  php
        pha
        lda ppu_latch
        bne addr_low
        pla
        pha
        and #$3F
        sta VMADDH
        inc ppu_latch
        bne addr_done
addr_low
        pla
        pha
        sta VMADDL
        lda #0
        sta ppu_latch
addr_done pla
        plp
        rts
scroll_a php
        pha
        lda ppu_latch
        bne scroll_y
        pla
        pha
        sta lat_x
        inc ppu_latch
        bne addr_done
scroll_y pla
        pha
        sta lat_y
        lda #0
        sta ppu_latch
        beq addr_done
status_a
        lda #0
        sta ppu_latch
        lda #$80
        rts
bank_a  php
        pha
        sta ACTIVE_NES_BANK
        and #7                  ; prg_bank, inlined: the game switches often
        asl
        asl
        ora #$80
        sta mems_sh
ba_mems sta VBX+VB_MEMS
        pla
        plp
        rts
controller_read
        lda nes_buttons
        sta $04
        lda nes_buttons2
        sta $05
        ldx #0
        ldy #0
        rts

; CHR RAM is stored as original NES two-plane bytes in VRAM $60000.
; Called with game registers already saved by ppu_w_a/x/y.
chr_store
        lda memb_sh
        pha
        lda #$80 | (V_CHRIDX >> 14)
        sta memb_sh
chr_mb  sta VBX+VB_MEMB
        lda VMADDH
        and #$1F
        ora #$40
        sta chr_st+2
        sta chr_ld+2
        ldy VMADDL
chr_ld  lda $4000,y
        cmp pw_val
        beq chr_unchanged
        lda pw_val
chr_st  sta $4000,y
        lda VMADDH
        and #15
        asl
        asl
        asl
        asl
        sta pw_t
        tya
        lsr
        lsr
        lsr
        lsr
        ora pw_t
        tax
        lda VMADDH
        lsr
        lsr
        lsr
        lsr
        and #1
        cmp bg_bank
        bne chr_obj
        ; Only the valid-to-invalid transition needs a background scan.
        ; Further bytes belong to an already queued tile. Expansion sets
        ; this flag before reading CHR, so an interrupting upload requeues it.
        lda EXPF_BG,x
        beq chr_obj
        lda #0
        sta EXPF_BG,x
        stx pw_col
        txa
        lsr
        lsr
        lsr
        tay
        txa
        and #7
        tax
        lda CHR_BITS,y
        ora bitmask,x
        sta CHR_BITS,y
        ldx pw_col
        lda #1
        sta chr_dirty
chr_obj txa
        and #$FE
        sta pw_t
        lda VMADDH
        lsr
        lsr
        lsr
        lsr
        and #1
        ora pw_t
        tax
        lda #0
        sta EXPF_OBJ,x
chr_end lda #1
        sta spr_dirty
chr_unchanged
        pla
        sta memb_sh
chr_mb2 sta VBX+VB_MEMB
        rts

apu_length_x
        php
        pha
        stx apu_idx
        sta $0A03,x
        txa
        jmp apu_length
apu_length_y
        php
        pha
        stx apu_idx
        sta $0A03,y
        tya
apu_length
        lsr
        lsr
        and #3
        tax
        lda #1
        sta s_trigger,x
        ldx apu_idx
        pla
        plp
        rts
apu_idx dta 0
