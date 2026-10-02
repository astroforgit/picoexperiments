; VBXE routines adapted from ../heroes-vbxe.asm; city owns its palette and upload layout.

.proc setup_antic
        lda #<display_list
        sta SDLSTL
        lda #>display_list
        sta SDLSTL+1
        lda #$22
        sta SDMCTL
        sta DMACTL
        lda #$E0
        sta CHBAS
        lda #$4E
        sta COLOR1
        lda #$02
        sta COLOR2
        lda #0
        sta COLOR4
        ldx #0
        lda #0
?clear  sta text_screen,x
        sta text_screen+$100,x
        sta text_screen+$200,x
        sta text_screen+$300,x
        inx
        bne ?clear
        rts
.endp

.proc copy_text
        ldy #0
        lda (text_src),y
        tax
        beq ?done
?loop   iny
        lda (text_src),y
        dey
        sta (text_dst),y
        iny
        dex
        bne ?loop
?done   rts
.endp

.proc wait_frame
        lda RTCLOK+2
?wait   cmp RTCLOK+2
        beq ?wait
        rts
.endp

.proc detect_vbxe
        lda VBXE_VCTL
        cmp #$10
        beq ?d6
        lda $D740
        cmp #$10
        beq ?d7
        clc
        rts
?d6     lda #$D6
        bne ?found
?d7     lda #$D7
?found  jsr relocate_vbxe_registers
        sec
        rts
.endp

.proc relocate_vbxe_registers
        sta ?page+1
        lda #<vbxe_relocations
        sta work_ptr
        lda #>vbxe_relocations
        sta work_ptr+1
        ldy #0
?next   lda (work_ptr),y
        sta text_dst
        iny
        lda (work_ptr),y
        sta text_dst+1
        iny
?page   lda #$D6
        ldx #0
        sta (text_dst,x)
        cpy #vbxe_relocations_end-vbxe_relocations
        bne ?next
        rts
.endp

.proc setup_xdl
        lda #BANK_EN+BANK_XDL
vbreg_setup_bank
        sta VBXE_BANK_SEL
        ldx #xdl_len-1
?copy   lda xdl_data,x
        sta MEMW,x
        dex
        bpl ?copy
        ldx #xdl_len-1
?copy_b lda xdl_data_b,x
        sta MEMW+XDL_B_OFF,x
        dex
        bpl ?copy_b
        rts
.endp

.proc enable_display
        lda #VC_XDL_ON+VC_XCOLOR
vbreg_vctl
        sta VBXE_VCTL
        lda #0
vbreg_xdl0
        sta VBXE_XDL0
        lda #$F0
vbreg_xdl1
        sta VBXE_XDL1
        lda #$07
vbreg_xdl2
        sta VBXE_XDL2
        rts
.endp

.proc present_back_buffer
        jsr wait_frame
        lda front_bank
        pha
        lda back_bank
        sta front_bank
        pla
        sta back_bank
        lda front_bank
        beq ?xdl_a
        lda #<XDL_B_OFF
present_vbreg_xdl0_b
        sta VBXE_XDL0
        lda #$F0
present_vbreg_xdl1_b
        sta VBXE_XDL1
        jmp ?high
?xdl_a lda #0
present_vbreg_xdl0_a
        sta VBXE_XDL0
        lda #$F0
present_vbreg_xdl1_a
        sta VBXE_XDL1
?high   lda #$07
present_vbreg_xdl2
        sta VBXE_XDL2
        rts
.endp

.proc blit_init
        lda #<BCB_OFF
vbreg_bl0
        sta VBXE_BL_ADR0
        lda #$F1
vbreg_bl1
        sta VBXE_BL_ADR1
        lda #$07
vbreg_bl2
        sta VBXE_BL_ADR2
        rts
.endp

.proc wait_blit
?wait
vbreg_busy
        lda VBXE_BLITTER
        bne ?wait
        rts
.endp

.proc do_blit
        jsr wait_blit
        lda #BANK_EN+BANK_XDL
vbreg_blit_bank
        sta VBXE_BANK_SEL
        lda bl_src
        sta MEMW+BCB_OFF+0
        lda bl_src+1
        sta MEMW+BCB_OFF+1
        lda bl_src+2
        sta MEMW+BCB_OFF+2
        lda bl_ssy
        sta MEMW+BCB_OFF+3
        lda bl_ssy+1
        sta MEMW+BCB_OFF+4
        lda bl_ssx
        sta MEMW+BCB_OFF+5
        lda bl_dst
        sta MEMW+BCB_OFF+6
        lda bl_dst+1
        sta MEMW+BCB_OFF+7
        lda bl_dst+2
        sta MEMW+BCB_OFF+8
        lda bl_dsy
        sta MEMW+BCB_OFF+9
        lda bl_dsy+1
        sta MEMW+BCB_OFF+10
        lda bl_dsx
        sta MEMW+BCB_OFF+11
        lda bl_w
        sta MEMW+BCB_OFF+12
        lda bl_w+1
        sta MEMW+BCB_OFF+13
        lda bl_h
        sta MEMW+BCB_OFF+14
        lda bl_and
        sta MEMW+BCB_OFF+15
        lda bl_xor
        sta MEMW+BCB_OFF+16
        lda #0
        sta MEMW+BCB_OFF+17
        sta MEMW+BCB_OFF+18
        sta MEMW+BCB_OFF+19
        lda bl_mode
        sta MEMW+BCB_OFF+20
        lda #1
vbreg_start
        sta VBXE_BLITTER
        rts
.endp

.proc calc_addr
        lda calc_y
        lsr
        lsr
        clc
        adc calc_y
        sta ?high
        lda calc_y
        and #3
        tax
        lda times64,x
        clc
        adc calc_x
        sta calc_out
        lda ?high
        adc calc_x+1
        sta calc_out+1
        lda render_bank
        sta calc_out+2
        rts
?high   dta 0
.endp

.proc fill_rect
        jsr calc_addr
        lda calc_out
        sta bl_dst
        lda calc_out+1
        sta bl_dst+1
        lda calc_out+2
        sta bl_dst+2
        lda #<SCR_W
        sta bl_dsy
        lda #>SCR_W
        sta bl_dsy+1
        lda #1
        sta bl_dsx
        lda #0
        sta bl_src
        sta bl_src+1
        sta bl_src+2
        sta bl_ssy
        sta bl_ssy+1
        lda #1
        sta bl_ssx
        lda fr_w
        sec
        sbc #1
        sta bl_w
        lda fr_w+1
        sbc #0
        sta bl_w+1
        lda fr_h
        sec
        sbc #1
        sta bl_h
        lda #0
        sta bl_and
        lda fr_col
        sta bl_xor
        lda #0
        sta bl_mode
        jmp do_blit
.endp

.proc copy_background_cache
        jsr wait_blit
        lda #0
        sta bl_src
        sta bl_src+1
        lda background_bank
        sta bl_src+2
        lda #<SCR_W
        sta bl_ssy
        lda #>SCR_W
        sta bl_ssy+1
        lda #1
        sta bl_ssx
        lda #0
        sta bl_dst
        sta bl_dst+1
        lda render_bank
        sta bl_dst+2
        lda #<SCR_W
        sta bl_dsy
        lda #>SCR_W
        sta bl_dsy+1
        lda #1
        sta bl_dsx
        lda #<[SCR_W-1]
        sta bl_w
        lda #>[SCR_W-1]
        sta bl_w+1
        lda #SCR_H-1
        sta bl_h
        lda #$FF
        sta bl_and
        lda #0
        sta bl_xor
        sta bl_mode
        jmp do_blit
.endp


front_bank dta 0
back_bank dta 1
render_bank dta 0
calc_x dta a(0)
calc_y dta 0
fr_w dta a(0)
fr_h dta 0
fr_col dta 0
times64 dta 0,64,128,192
bl_src dta 0,0,0
bl_ssy dta a(0)
bl_ssx dta 0
bl_dst dta 0,0,0
bl_dsy dta a(0)
bl_dsx dta 0
bl_w dta a(0)
bl_h dta 0
bl_and dta 0
bl_xor dta 0
bl_mode dta 0
xdl_data
        dta $74,$08,7,$00,$00,$00,$40,$01,$11,$FF
        dta $62,$88,199,$00,$00,$00,$40,$01,$11,$FF
xdl_len = *-xdl_data
xdl_data_b
        dta $74,$08,7,$00,$00,$01,$40,$01,$11,$FF
        dta $62,$88,199,$00,$00,$01,$40,$01,$11,$FF
vbxe_relocations

        dta a(loader_init.reg_memac+2)

        dta a(loader_init.reg_vctl+2)

        dta a(upload_chunk.reg_bank+2)

        dta a(upload_chunk.reg_restore+2)

        dta a(setup_xdl.vbreg_setup_bank+2)

        dta a(enable_display.vbreg_vctl+2)

        dta a(enable_display.vbreg_xdl0+2)

        dta a(enable_display.vbreg_xdl1+2)

        dta a(enable_display.vbreg_xdl2+2)

        dta a(load_city_palette.reg_psel+2)

        dta a(load_city_palette.reg_csel+2)

        dta a(load_city_palette.reg_red+2)

        dta a(load_city_palette.reg_green+2)

        dta a(load_city_palette.reg_blue+2)

        dta a(blit_init.vbreg_bl0+2)

        dta a(blit_init.vbreg_bl1+2)

        dta a(blit_init.vbreg_bl2+2)

        dta a(wait_blit.vbreg_busy+2)

        dta a(do_blit.vbreg_blit_bank+2)

        dta a(do_blit.vbreg_start+2)

        dta a(present_back_buffer.present_vbreg_xdl0_b+2)

        dta a(present_back_buffer.present_vbreg_xdl1_b+2)

        dta a(present_back_buffer.present_vbreg_xdl0_a+2)

        dta a(present_back_buffer.present_vbreg_xdl1_a+2)

        dta a(present_back_buffer.present_vbreg_xdl2+2)

        dta a(battle.hero_sprite.reg_source+2)
        dta a(battle.hero_sprite.reg_cache+2)
vbxe_relocations_end
