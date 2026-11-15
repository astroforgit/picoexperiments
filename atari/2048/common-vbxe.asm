; Shared VBXE setup, framebuffer, blitter, font, and controls.
detect  lda $d640
        cmp #$10
        beq d6
        lda $d740
        cmp #$10
        beq d7
        clc
        rts
d6      lda #$d6
        bne patch_regs
d7      lda #$d7
patch_regs
        sta patch_page+1
        mwa #reg_list ptr
        ldy #0
patch_next
        lda (ptr),y
        sta zp2
        iny
        lda (ptr),y
        sta zp2+1
        iny
patch_page lda #$d6
        ldx #0
        sta (zp2,x)
        cpy #reg_list_end-reg_list
        bne patch_next
        sec
        rts
reg_list
        dta a(reg_memac+2),a(reg_xdlbank+2)
        dta a(reg_csel+2),a(reg_psel+2),a(reg_cr+2),a(reg_cg+2),a(reg_cb+2)
        dta a(reg_bl0+2),a(reg_bl1+2),a(reg_bl2+2)
        dta a(reg_vctl+2),a(reg_xdl0+2),a(reg_xdl1+2),a(reg_xdl2+2)
        dta a(reg_fontbank+2),a(reg_blwait+2),a(reg_blbank+2),a(reg_blstart+2)
        dta a(reg_present_xdl0+2)
        dta a(reg_stage_memac+2),a(reg_stage_bank+2)
        dta a(reg_view_bank+2),a(reg_plot_bank+2)
reg_list_end

setup_xdl
        lda #$ff
reg_xdlbank sta BANKSEL
        ldx #xdl_end-xdl_data-1
xdl_copy
        lda xdl_data,x
        sta MEMW,x
        dex
        bpl xdl_copy
        rts
xdl_data
        dta $74,$08,7,0,0,0,$40,$01,$11,$ff
        dta $62,$88,199,0,0,0,$40,$01,$11,$ff
        :12 dta 0
        dta $74,$08,7,0,0,0,$40,$01,$11,$ff
        dta $62,$88,199,0,0,5,$40,$01,$11,$ff
xdl_end
present_frame
        jsr blwait
        lda RTCLOK
present_wait
        cmp RTCLOK
        beq present_wait
        lda framebuffer_bank
        beq present_front
        lda #$20
        bne present_switch
present_front
        lda #0
present_switch
reg_present_xdl0 sta XDL0
        lda framebuffer_bank
        eor #5
        sta framebuffer_bank
        rts
framebuffer_bank dta 5

palette
        lda #1
reg_psel sta PSEL
        ldx #0
pal_next
        lda palette_data,x
        cmp #$ff
        beq pal_done
reg_csel sta CSEL
        lda palette_data+1,x
reg_cr  sta CR
        lda palette_data+2,x
reg_cg  sta CG
        lda palette_data+3,x
reg_cb  sta CB
        txa
        clc
        adc #4
        tax
        jmp pal_next
pal_done rts
palette_data
        dta 0,0,0,0, 1,29,43,83, 2,126,37,83
        dta 3,0,135,81, 4,171,82,54, 5,95,87,79
        dta 6,194,195,199, 7,255,241,232, 8,255,0,77
        dta 9,255,163,0, 10,255,236,39, 11,0,228,54
        dta 12,41,173,255, 13,131,118,156
        dta 14,255,119,168, 15,255,204,170, $ff

upload_font
        lda #$e1
reg_fontbank sta BANKSEL
        mwa #font_data ptr
        mwa #MEMW zp2
        ldx #16
font_page
        ldy #0
font_byte
        lda (ptr),y
        sta (zp2),y
        iny
        bne font_byte
        inc ptr+1
        inc zp2+1
        dex
        bne font_page
        rts

init_view_stage
        lda PORTB
        ora #2
        sta PORTB
        jsr detect
        bcc stage_done
        lda #$98
reg_stage_memac sta MEMAC
        ldx stage_index
        lda stage_bank_table,x
reg_stage_bank sta BANKSEL
        mwa #$8000 ptr
        mwa #MEMW zp2
        ldx #16
stage_page
        ldy #0
stage_byte
        lda (ptr),y
        sta (zp2),y
        iny
        bne stage_byte
        inc ptr+1
        inc zp2+1
        dex
        bne stage_page
        inc stage_index
stage_done rts
stage_index dta 0

bl_src dta 0,0,0
bl_ssy dta a(0)
bl_ssx dta 1
bl_dst dta 0,0,0
bl_dsy dta a(320)
bl_dsx dta 1
bl_w dta a(7)
bl_h dta 7
bl_and dta 0
bl_xor dta 0
bl_mode dta 0
blit
blwait
reg_blwait lda BLITTER
        bne blwait
        lda #$ff
reg_blbank sta BANKSEL
        ldx #0
blit_copy
        lda bl_src,x
        sta MEMW+$100,x
        inx
        cpx #17
        bne blit_copy
        lda #0
        sta MEMW+$111
        sta MEMW+$112
        sta MEMW+$113
        lda bl_mode
        sta MEMW+$114
        lda #1
reg_blstart sta BLITTER
        rts
fx dta a(0)
fy dta 0
fw dta a(8)
fh dta 8
fc dta 0
fill
        jsr screen_address
        lda #0
        sta bl_src
        sta bl_src+1
        sta bl_src+2
        sta bl_ssy
        sta bl_ssy+1
        lda #1
        sta bl_ssx
        lda fw
        sec
        sbc #1
        sta bl_w
        lda fw+1
        sbc #0
        sta bl_w+1
        lda fh
        sec
        sbc #1
        sta bl_h
        lda #0
        sta bl_and
        sta bl_mode
        lda fc
        sta bl_xor
        jmp blit
screen_address
        lda fy
        lsr
        lsr
        clc
        adc fy
        sta bl_dst+1
        lda fy
        and #3
        tax
        lda times64,x
        clc
        adc fx
        sta bl_dst
        lda bl_dst+1
        adc fx+1
        sta bl_dst+1
        lda framebuffer_bank
        sta bl_dst+2
        rts
times64 dta 0,64,128,192

text_x dta a(0)
text_y dta 0
text_col dta 1
text
        ldy #0
text_next
        lda (text_ptr),y
        bne text_has_char
        jmp text_done
text_has_char
        sty saved_char
        sec
        sbc #32
        cmp #16
        bcc glyph_ready
        cmp #26
        bcs glyph_ready
        sec
        sbc #16
        tax
        lda digit_glyphs,x
glyph_ready
        sta glyph
        and #3
        tax
        lda times64,x
        sta bl_src
        lda glyph
        lsr
        lsr
        clc
        adc #$10
        sta bl_src+1
        lda #6
        sta bl_src+2
        mwa #8 bl_ssy
        lda #1
        sta bl_ssx
        mwa #320 bl_dsy
        lda #1
        sta bl_dsx
        mwa #7 bl_w
        lda #7
        sta bl_h
        lda text_col
        sta bl_and
        lda #0
        sta bl_xor
        lda #1
        sta bl_mode
        mwa text_x fx
        lda text_y
        sta fy
        jsr screen_address
        jsr blit
        ldy saved_char
        clc
        lda text_x
        adc #8
        sta text_x
        bcc text_no_carry
        inc text_x+1
text_no_carry
        iny
        jmp text_next
text_done rts
saved_char dta 0
glyph dta 0
digit_glyphs dta 34,42,45,49,56,58,59,60,61,62

read_input
        lda PORTA
        eor #$ff
        sta input
        lsr
        lsr
        lsr
        lsr
        ora input
        and #15
        sta input
        lda STRIG0
        beq joystick_fire
        lda STRIG1
        bne no_fire
joystick_fire
        lda input
        ora #16
        sta input
no_fire
        lda CH
        cmp #$21
        bne no_space
        lda #$ff
        sta CH
        lda input
        ora #16
        sta input
no_space
        lda CONSOL
        and #1
        bne no_start
        lda input
        ora #16
        sta input
no_start
        lda old_input
        eor #$ff
        and input
        sta input_edge
        lda input
        sta old_input
        rts
