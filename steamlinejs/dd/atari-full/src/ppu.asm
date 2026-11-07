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
        bcc ps_rts              ; pattern tables are CHR ROM
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

; ---- the services named after the SNES port's JSL targets
store_vmaddh_to_proper_range
        sta VMADDH
        rts

set_vram_increment_based_on_a_and_store
        lda $15
        and #4
        jsr set_inc
        lda PPU_CONTROL_STATE
        and #$FB
        ora inc_bit
        sta PPU_CONTROL_STATE
        rts
set_vram_increment_to_1_and_store
        lda #0
        jsr set_inc
        lda PPU_CONTROL_STATE
        and #$FB
        sta PPU_CONTROL_STATE
        rts
set_vram_increment_to_32_no_store
        lda #4
        jsr set_inc
        lda PPU_CONTROL_STATE
        ora #4
        rts
change_write_increment_based_on_carry_flag
        lda #0
        bcc cw_1
        lda #4
cw_1    jsr set_inc
        lda PPU_CONTROL_STATE
        and #$FB
        ora inc_bit
        sta PPU_CONTROL_STATE
        rts
; A = 0 or 4
set_inc sta inc_bit
        cmp #4
        lda #1
        bcc si_1
        lda #32
si_1    sta ppu_inc
        rts

restore_ppu_control_from_a
change_ppu_vblank_status
        php
        sta PPU_CONTROL_STATE
        sta nmi_on
        plp
        rts
enable_nmi_and_store
        lda PPU_CONTROL_STATE
        ora #$80
        sta PPU_CONTROL_STATE
        sta nmi_on
        rts
disable_nmi_and_store
        lda PPU_CONTROL_STATE
        and #$7F
        sta PPU_CONTROL_STATE
        sta nmi_on
        rts

disable_sprites_and_bg_and_store
        lda PPU_MASK_STATE
        and #$E7
        jmp mask_st
enable_bg_and_sprites_and_store
        lda PPU_MASK_STATE
        ora #$18
        jmp mask_st
disable_sprites_and_store
        lda PPU_MASK_STATE
        and #$EF
        jmp mask_st
enable_sprites_and_store
        lda PPU_MASK_STATE
        ora #$10
        jmp mask_st
disable_bg_and_store
        lda PPU_MASK_STATE
        and #$F7
        jmp mask_st
enable_bg_and_store
        lda PPU_MASK_STATE
        ora #$08
mask_st sta PPU_MASK_STATE
        rts

augment_input
        lda nes_buttons
        sta $F5
        lda nes_buttons2
        sta $F6
        lda #0
        sta $00
        sta $01
        tax
        rts

handle_mmc1_control_register
        pha
        txa
        pha
        tya
        pha
        lda BANK_SWITCH_CTRL_REGS
        and #3
        cmp mirror
        beq hm_1
        jsr set_mirroring
hm_1    pla
        tay
        pla
        tax
        pla
        rts


; A = CHR bank (4K) for sprites
bankswitch_obj_chr_data
        and #31
        cmp obj_bank
        beq bo_rts
        sta obj_bank
        lda #0
        sta id_ot
        sta id_odone
        tax
bo_1    sta EXPF_OBJ,x
        inx
        bne bo_1
        ldx #127                ; every sprite slot must rewrite its source
bo_2    lda SC_A,x
        ora #$10
        sta SC_A,x
        dex
        bpl bo_2
bo_rts  rts

; A = CHR bank (4K) for the background
check_for_bg_chr_bankswap
        and #31
        cmp bg_bank
        beq bb_rts
        sta bg_bank
        lda #0
        sta id_bt
        sta id_bdone
        tax
bb_1    sta EXPF_BG,x
        inx
        bne bb_1
        jmp mark_all_dirty
bb_rts  rts

check_for_initial_obj_loads
convert_nes_attributes_and_immediately_dma_them
do_critical_snes_nmi_chores
write_tile_and_attribute_rewrite
        rts

dd_update_row_attributes
        lda #0
        sta $1C
        rts

; JSL'ed in the SNES port: pull the two bytes the caller pushed
dd_one_off_update
        pla
        sta oo_ret
        pla
        sta oo_ret+1
        pla
        sta $1F
        pla
        sta $1E
        tax
        lda oo_ret+1
        pha
        lda oo_ret
        pha
        txa
        rts
oo_ret  dta a(0)

dd_update_column_attributes
        cpx #$1E
        bmi dc_1
        ldx #0
        inc $1F
dc_1    stx $1E
        dec $08
        rts

; PPU writes done by the original loops these services replaced
clear_bg_vm_jsl
        pha
        txa
        pha
        lda #0
        tax
cb_1    sta NT_A,x
        sta NT_A+$100,x
        sta NT_A+$200,x
        sta NT_A+$300,x
        sta NT_B,x
        sta NT_B+$100,x
        sta NT_B+$200,x
        sta NT_B+$300,x
        inx
        bne cb_1
        jsr mark_all_dirty
        pla
        tax
        pla
        rts

full_attribute_copy_from_0628
        php
        pha
        txa
        pha
        tya
        pha
        jsr save_vmadd
        lda #$23
        sta VMADDH
        lda #$C0
        sta VMADDL
        ldy #0
fa_1    lda $0628,y
        jsr store_inc1
        iny
        cpy #$40
        bne fa_1
        lda #$2B
        sta VMADDH
        lda #$C0
        sta VMADDL
fa_2    lda $0628,y
        jsr store_inc1
        iny
        cpy #$80
        bne fa_2
        jmp svc_restore

set_bottom_3_rows_of_attributes_to_55
        php
        pha
        txa
        pha
        tya
        pha
        jsr save_vmadd
        lda #$2B
        sta VMADDH
        lda #$E8
        sta VMADDL
        ldy #24
sb_1    lda #$55
        jsr store_inc1
        dey
        bne sb_1
svc_restore
        lda vm_save
        sta VMADDL
        lda vm_save+1
        sta VMADDH
        pla
        tay
        pla
        tax
        pla
        plp
        rts

save_vmadd
        lda VMADDL
        sta vm_save
        lda VMADDH
        sta vm_save+1
        rts
vm_save dta a(0)

; A = value; store at VMADD and step by one. Y kept.
store_inc1
        sta pw_val
        sty si_y
        jsr ppu_store
        ldy si_y
        inc VMADDL
        bne si1_1
        inc VMADDH
si1_1   rts
si_y    dta 0

; palette: PALETTE_ENTRY_CNT bytes from ($02) to $3F00+PALETTE_OFFSET; C=1
write_palette_data
        txa
        pha
        tya
        pha
        lda PALETTE_OFFSET
        sta wp_dst
        ldy #0
wp_1    cpy PALETTE_ENTRY_CNT
        beq wp_2
        lda ($02),y
        jsr pal_store
        inc wp_dst
        iny
        bne wp_1
wp_2    pla
        tay
        pla
        tax
        sec
        rts
wp_dst  dta 0

write_8_palette_entries_from_f1b6
        pha
        txa
        pha
        tya
        pha
        lda #$10
        sta wp_dst
        ldy #0
w8_1    lda $F1B6,y
        jsr pal_store
        inc wp_dst
        iny
        cpy #8
        bne w8_1
        pla
        tay
        pla
        tax
        pla
        rts

; A = colour, wp_dst = palette index. Y kept.
pal_store
        and #$3F
        pha
        lda wp_dst
        and #$1F
        tax
        and #3
        bne pst_1
        txa
        and #$0F
        tax
pst_1   pla
        cmp PALSH,x
        beq pst_2
        sta PALSH,x
        lda #1
        sta pal_dirty
pst_2   rts

; FCBF: the frame's scroll and PPUCTRL (originally written to $2005/$2000)
latch_scroll
        php
        pha
        lda $FD
        sta lat_x
        lda $FC
        sta lat_y
        lda PPU_CONTROL_STATE
        sta lat_ctrl
        pla
        plp
        rts

; EC79: after the sprite-0 hit the original set the HUD's nametable and scroll
hud_scroll
        lda $3B
        and #1
        beq hs_2
        lda #0
        sta hud_nt
        lda PPU_CONTROL_STATE
        and #$FC
        jmp hs_3
hs_2    lda #2
        sta hud_nt
        lda PPU_CONTROL_STATE
        and #$FC
        ora #$02
hs_3    sta PPU_CONTROL_STATE
        pha
        lda #1
        sta hud_on
        pla
        rts
