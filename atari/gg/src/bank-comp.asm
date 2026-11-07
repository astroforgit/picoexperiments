; bank COMP: picture composition (NMI)
; ------------------------------------------------------------------
; palette
; ------------------------------------------------------------------
; entries that do not depend on colour registers
pal_fixed
        lda #1
        sta pf_p
pf_pl   lda pf_p
pf_0    sta VBX+VB_PSEL
        lda #0
pf_1    sta VBX+VB_CSEL
        ldx #0                  ; 0: black (transparent)
        jsr pal_put
        ldy #$20                ; sprite colours
        jsr pal_16
        ldy #$70                ; colour RAM: multicolour cells use c & 7
        jsr pal_16
        ldy #$80                ; hires colours
        jsr pal_16
        ldy #$E0                ; fills
        jsr pal_16
        ; $78-$7F are c & 7
        lda #$78
pf_2    sta VBX+VB_CSEL
        ldx #0
pf_3    jsr pal_put
        inx
        cpx #8
        bne pf_3
        inc pf_p                ; palettes 1-3
        lda pf_p
        cmp #4
        bne pf_pl
        ldx #3*6-1              ; no colour sets yet
        lda #$FF
pf_s    sta pslot,x
        dex
        bpl pf_s
        rts
pf_p    dta 0
; 16 entries from Y: colours 0-15
pal_16
pf_4    sty VBX+VB_CSEL
        ldx #0
p16_l   jsr pal_put
        inx
        cpx #16
        bne p16_l
        rts
; one entry: C64 colour X (CSEL advances)
pal_put lda c64_r,x
pp_0    sta VBX+VB_CR
        lda c64_g,x
pp_1    sta VBX+VB_CG
        lda c64_b,x
pp_2    sta VBX+VB_CB
        rts
; Y = first entry, A = C64 colour: 16 entries of that colour
pal_run
pr_0    sty VBX+VB_CSEL
        and #15
        tax
        ldy #16
pr_l    jsr pal_put
        dey
        bne pr_l
        rts
; palettes and XDL segments of the picture in list bl: each region's
; colour set ($D021-$D026) in one of palettes 1-3
pal_regions
        ldx #0
pg_l    cpx nregion
        bcs pg_seg
        lda rg_d021,x
        and #15
        sta pg_s
        lda rg_c22,x
        and #15
        sta pg_s+1
        lda rg_c23,x
        and #15
        sta pg_s+2
        lda rg_c24,x
        and #15
        sta pg_s+3
        lda rg_c25,x
        and #15
        sta pg_s+4
        lda rg_c26,x
        and #15
        sta pg_s+5
        stx pg_i
        jsr pg_find
        ldx pg_i
        sta rg_pal,x
        inx
        jmp pg_l
pg_seg  ; segments over FB lines 0-199, neighbours with the same palette merged
        lda bl
        beq pg_s0
        lda #NR
pg_s0   sta pg_b                ; list offset in the segment tables
        lda #0
        sta pg_n
        sta pg_lp
        ldx #0
pg_r    cpx nregion
        bcs pg_end
        stx pg_i
        inx
        cpx nregion
        bcs pg_e200
        lda rg_l0,x             ; the next region's first line
        jmp pg_e1
pg_e200 lda #200
pg_e1   ldx pg_i
        sec
        sbc rg_l0,x             ; lines of region x
        beq pg_nx
        bcc pg_nx
        sta pg_ln
        lda rg_pal,x
        clc
        adc #1                  ; palette 1-3
        cmp pg_lp
        bne pg_new
        lda pg_b                ; same palette: the last segment grows
        clc
        adc pg_n
        tay
        dey
        lda seg_ln,y
        clc
        adc pg_ln
        sta seg_ln,y
        jmp pg_nx
pg_new  sta pg_lp
        pha
        lda pg_b
        clc
        adc pg_n
        tay
        pla
        sta seg_pl,y
        lda pg_ln
        sta seg_ln,y
        inc pg_n
pg_nx   inx
        jmp pg_r
pg_end  ldx bl
        lda pg_n
        bne pg_e2
        lda #1                  ; (no region: 200 lines of palette 1)
        sta pg_n
        ldy pg_b
        sta seg_pl,y
        lda #200
        sta seg_ln,y
        lda #1
pg_e2   sta seg_n,x
        rts

; A = palette slot (0-2) holding colour set pg_s; a new set gets a slot no
; picture on screen, running or waiting uses, nor an earlier region of this one
pg_find ldx #0
pf_k    stx pf_t
        txa
        asl
        adc pf_t
        asl                     ; slot * 6
        tay
        ldx #0
pf_c    lda pslot,y
        cmp pg_s,x
        bne pf_nk
        iny
        inx
        cpx #6
        bne pf_c
        lda pf_t                ; found
        rts
pf_nk   ldx pf_t
        inx
        cpx #3
        bne pf_k
        ; not there: the slots in use
        lda #0
        sta pf_busy
        ldx shown
        jsr pf_use
        lda pending
        beq pf_u1
        ldx run
        jsr pf_use
pf_u1   ldx ready
        bmi pf_u2
        jsr pf_use
pf_u2   ldx pg_i
        beq pf_u4
pf_u3   dex
        lda rg_pal,x
        tay
        lda bit8tab,y
        ora pf_busy
        sta pf_busy
        txa
        bne pf_u3
pf_u4   ldx #0
pf_f    lda pf_busy
        and bit8tab,x
        beq pf_new
        inx
        cpx #3
        bne pf_f
        ldx #0                  ; all in use (should not happen): slot 0
pf_new  stx pf_t
        txa
        asl
        adc pf_t
        asl
        tay                     ; slot * 6
        ldx #0
pf_cp   lda pg_s,x
        sta pslot,y
        iny
        inx
        cpx #6
        bne pf_cp
        lda pf_t
        clc
        adc #1
        jsr pal_set
        lda pf_t
        rts
; mark the palettes of list X's segments
pf_use  lda seg_n,x
        beq pfu_x
        sta pf_t+1
        txa
        beq pfu_0
        lda #NR
pfu_0   tay
pfu_l   lda seg_pl,y
        tax
        dex
        lda bit8tab,x
        ora pf_busy
        sta pf_busy
        iny
        dec pf_t+1
        bne pfu_l
pfu_x   rts
bit8tab dta 1,2,4,8
pg_s    .ds 6
pg_i    dta 0
pg_b    dta 0
pg_n    dta 0
pg_a    dta 0
pg_ln   dta 0
pg_lp   dta 0
pf_t    dta 0,0
pf_busy dta 0

; palette A (1-3): the entries that depend on the colour registers (pg_s)
pal_set
pu_0    sta VBX+VB_PSEL
        ldx #5
pu_l    stx nt
        lda pg_s,x
        ldy pu_e1,x
        jsr pal_run
        ldx nt
        ldy pu_e2,x
        beq pu_n
        lda pg_s,x
        jsr pal_run
        ldx nt
pu_n    dex
        bpl pu_l
        rts
pu_e1   dta $40,$50,$60,$D0,$10,$30
pu_e2   dta $A0,$B0,$C0,0,0,0

c64_r   dta $00,$FF,$68,$70,$6F,$58,$35,$B8,$6F,$43,$9A,$44,$6C,$9A,$6C,$95
c64_g   dta $00,$FF,$37,$A4,$3D,$8D,$28,$C7,$4F,$39,$67,$44,$6C,$D2,$5E,$95
c64_b   dta $00,$FF,$2B,$B2,$86,$43,$79,$6F,$25,$00,$59,$44,$6C,$84,$B5,$95

; main context: regions and sprites into list bl, then the list is ready
; for the NMI to start
compose_list
        jsr pal_regions
        lda #MEMB_LST
        jsr vbx_memb_a
        jsr compose
cl_w    lda ready               ; the last list has not started yet: its
        bpl cl_w                ; cell updates must run (rarely waits)
        ; update slots this list used last time beyond this time's: no
        ; writes (AND mask 0, transparent copy)
        ldx bl
        lda upd_cnt,x
        sta cl_k
        cmp upd_hi,x
        bcs cl_s2
        jsr mul21               ; nt/nt+1 = slot * 21
        ldx bl
        lda lst_w_lo,x
        clc
        adc nt
        sta ZPN
        lda lst_w_hi,x
        adc nt+1
        sta ZPN+1
cl_s1   lda #0
        ldy #15
        sta (ZPN),y             ; AND mask 0: no writes
        lda ZPN
        clc
        adc #21
        sta ZPN
        bcc cl_s3
        inc ZPN+1
cl_s3   inc cl_k
        lda cl_k
        cmp upd_hi,x
        bcc cl_s1
cl_s2   lda upd_cnt,x
        sta upd_hi,x
        ; the list starts at update slot 0
        lda lst_v_lo,x
        sta rdy_lo
        lda lst_v_mid,x
        sta rdy_mid
        lda lst_v_hi,x
        sta rdy_hi
        lda cm_T                ; (the scroll it shows)
        sta lstT,x
        stx ready               ; (last: the NMI may start it at once)
        lda #0
        jmp vbx_memb_a

cl_k    dta 0

; A = slot: nt/nt+1 = A * 21
mul21   sta nt
        lda #0
        sta nt+1
        lda nt
        asl
        rol nt+1
        asl
        rol nt+1                ; *4
        adc nt
        bcc m21_1
        inc nt+1
m21_1   sta nt+3                ; *5
        lda nt+1
        sta nt+4
        lda nt+3
        asl
        rol nt+4
        asl
        rol nt+4                ; *20
        clc
        adc nt
        sta nt
        lda nt+4
        adc #0
        sta nt+1                ; *21
        rts

; tail of list bl: regions, then sprites; ZPN = slot window address
compose
        ldx bl
        lda lst_w_lo,x
        clc
        adc #<LST_REG
        sta ZPN
        lda lst_w_hi,x
        adc #>LST_REG
        sta ZPN+1
        lda reg_dirty
        bne cmp_reg
        jmp spr_finish          ; regions as built two frames ago for this list
cmp_reg dec reg_dirty
        lda #0
        sta nt+7                ; region slots written
        jsr compose_regions
        ; unused region slots of this list become no-ops again
        ldx bl
        lda nt+7
        sta cr_cnt
cr_nop  lda cr_cnt
        cmp reg_used,x
        bcs cr_nd
        jsr nop_slot
        inc cr_cnt
        jmp cr_nop
cr_nd   lda nt+7
        sta reg_used,x
        jmp spr_finish
cr_cnt  dta 0

; ZPN = window address of the region slot nt+7 (computed from the base)
reg_slot
        ldx bl
        lda nt+7
        jsr mul21b
        lda lst_r_lo,x
        clc
        adc ZPX
        sta ZPN
        lda lst_r_hi,x
        adc ZPX+1
        sta ZPN+1
        rts
lst_r_lo dta <(WIN+(V_LIST0&$3FFF)+LST_REG), <(WIN+(V_LIST1&$3FFF)+LST_REG)
lst_r_hi dta >(WIN+(V_LIST0&$3FFF)+LST_REG), >(WIN+(V_LIST1&$3FFF)+LST_REG)

; A * 21 into ZPX/ZPX+1 (keeps X)
mul21b  sta ZPX+2
        lda #0
        sta ZPX+1
        lda ZPX+2
        ldy #21
        sta ZPX
        lda #0
        sta ZPX
m21b_l  lda ZPX
        clc
        adc ZPX+2
        sta ZPX
        bcc m21b_1
        inc ZPX+1
m21b_1  dey
        bne m21b_l
        rts

; the next region slot (ZPN) becomes a no-op
nop_slot
        ldy #20
ns_l    lda nop_bcb_c,y
        sta (ZPN),y
        dey
        bpl ns_l
        jmp slot_adv

; write the BCB in bcb (21 bytes) to region slot nt+7, nt+7++
emit_reg
        lda nt+7
        cmp #NREG
        bcs er_x
        ldy #20
er_l    lda bcb,y
        sta (ZPN),y
        dey
        bpl er_l
        inc nt+7
slot_adv
        lda ZPN
        clc
        adc #21
        sta ZPN
        bcc er_x
        inc ZPN+1
er_x    rts
bcb     .ds 21
V_SCRC  = V_XDL+$200
nop_bcb_c dta <V_SCRC,>V_SCRC,^V_SCRC, 0,0, 0, <V_SCRC,>V_SCRC,^V_SCRC, 0,0, 0, 0,0, 0, $FF,0, 0,0,0, 8

; the regions: char layer copies, blank and border fills
compose_regions
        ; display window from the region covering the middle of the screen
        lda #0
        sta cg_r
        ldx #0
cg_mid  inx
        cpx nregion
        bcs cg_md
        lda rg_l0,x
        cmp #100
        bcc cg_mid
cg_md   dex
        lda rg_d011,x
        and #8
        beq cg_24
        lda #0
        sta win_top
        lda #200
        sta win_bot
        jmp cg_c
cg_24   lda #4
        sta win_top
        lda #196
        sta win_bot
cg_c    lda rg_d016,x
        and #8
        beq cg_38
        lda #24
        sta win_l
        lda #<344
        sta win_r
        lda #>344
        sta win_r+1
        jmp cg_go
cg_38   lda #31
        sta win_l
        lda #<335
        sta win_r
        lda #>335
        sta win_r+1
cg_go   ; regions in turn
        lda #0
        sta cg_r
cg_loop ldx cg_r
        cpx nregion
        bcc cg_1
        jmp cg_border
cg_1    lda rg_l0,x
        sta cg_a                ; FB lines a..b
        inx
        cpx nregion
        bcc cg_2
        lda #200
        bne cg_3
cg_2    lda rg_l0,x
cg_3    sta cg_b
        dex
        ; clip to the display window
        lda cg_a
        cmp win_top
        bcs cg_4
        lda win_top
        sta cg_a
cg_4    lda cg_b
        cmp win_bot
        bcc cg_5
        lda win_bot
        sta cg_b
cg_5    lda cg_a
        cmp cg_b
        bcs cg_next
        ; blank or invalid mode: black fill
        lda rg_d011,x
        and #$10
        beq cg_blank
        lda rg_d011,x
        and #$60
        beq cg_text
        cmp #$40
        beq cg_text
cg_blank
        lda #$E0
        jsr fill_lines
        jmp cg_next
cg_text jsr copy_lines
cg_next inc cg_r
        jmp cg_loop
cg_border
        ; top and bottom borders (24-row mode), side borders (38 columns)
        lda win_top
        beq cgb_1
        lda #0
        sta cg_a
        lda win_top
        sta cg_b
        jsr border_col
        jsr fill_lines
cgb_1   lda win_bot
        cmp #200
        bcs cgb_2
        sta cg_a
        lda #200
        sta cg_b
        jsr border_col
        jsr fill_lines
cgb_2   lda win_l
        cmp #31
        bne cgb_x
        lda win_top
        sta cg_a
        lda win_bot
        sta cg_b
        jsr border_col
        sta cg_fc
        lda #0
        ldx #7
        jsr fill_strip
        lda #<311
        ldx #9
        jsr fill_strip_hi
cgb_x   rts
cg_r    dta 0
cg_a    dta 0
cg_b    dta 0
cg_fc   dta 0

; fill colour of the border ($E0 | d020 of the middle region) into A
border_col
        ldx #0
bc_l    inx
        cpx nregion
        bcs bc_d
        lda rg_l0,x
        cmp #100
        bcc bc_l
bc_d    dex
        lda rg_d020,x
        and #15
        ora #$E0
        rts

; fill FB lines cg_a..cg_b-1, x 0..319, with colour A
fill_lines
        sta bcb+16              ; xor = colour
        lda #0
        sta bcb+15              ; and = 0: constant source
        lda #<(320-1)
        sta bcb+12
        lda #>(320-1)
        sta bcb+13
        lda #0
        sta ZPX+3               ; x offset 0
        jmp fill_common
; fill FB lines cg_a..cg_b-1, x A..A+X-1 (x < 256)
fill_strip
        sta ZPX+3
        lda #0
        sta ZPX+4
        jmp fs_c
fill_strip_hi
        sta ZPX+3
        lda #1
        sta ZPX+4
fs_c    dex
        stx bcb+12
        lda #0
        sta bcb+13
        sta bcb+15
        lda cg_fc
        sta bcb+16
        jmp fill_c2
fill_common
        lda #0
        sta ZPX+4
fill_c2 lda cg_b
        sec
        sbc cg_a
        beq fc_x
        sec
        sbc #1
        sta bcb+14
        lda #0
        sta bcb
        sta bcb+1
        sta bcb+2
        sta bcb+3
        sta bcb+4
        sta bcb+5
        sta bcb+17
        sta bcb+18
        sta bcb+19
        lda #<FBW
        sta bcb+9
        lda #>FBW
        sta bcb+10
        lda #1
        sta bcb+11
        lda #8
        sta bcb+20
        ; dst = FB + a*368 + 24 + x
        lda cg_a
        jsr fb_row              ; ZPX..+2 = FB(bl) + A*368
        lda ZPX
        clc
        adc #FBM
        sta bcb+6
        lda ZPX+1
        adc #0
        sta bcb+7
        lda ZPX+2
        adc #0
        sta bcb+8
        lda bcb+6
        clc
        adc ZPX+3
        sta bcb+6
        lda bcb+7
        adc ZPX+4
        sta bcb+7
        bcc fc_1
        inc bcb+8
fc_1    jmp emit_reg
fc_x    rts

; ZPX/ZPX+1/ZPX+2 = framebuffer bl + A * 368 (A = FB line); keeps X
fb_row  tay
        stx fr_x
        ldx bl
        lda fbr_lo,y
        clc
        adc fb_lo,x
        sta ZPX
        lda fbr_mid,y
        adc fb_mid,x
        sta ZPX+1
        lda fbr_hi,y
        adc fb_hi,x
        sta ZPX+2
        ldx fr_x
        rts
fr_x    dta 0
fbr_lo  :201 dta <[#*FBW]
fbr_mid :201 dta >[#*FBW]
fbr_hi  :201 dta ^[#*FBW]

; copy char layer lines for FB lines cg_a..cg_b-1 of region x (cg_r),
; one group of rows with the same ring offset at a time
copy_lines
        ldx cg_r
        lda rg_d016,x
        and #7
        sta cl_xs
        lda rg_d011,x
        and #7
        sta cl_ys
        lda cg_a
        sta cl_y                ; current FB line
cl_loop lda cl_y
        cmp cg_b
        bcc cl_1
        rts
cl_1    ; char layer line = FB line + 3 - ys
        clc
        adc #3
        sec
        sbc cl_ys
        bcs cl_2
        ; above the char layer: the line shows the background
        jmp cl_bgline
cl_2    cmp #200
        bcc cl_3
        jmp cl_bgline
cl_3    sta cl_cy
        lsr
        lsr
        lsr
        sta cl_row
        ; lines while the row offset stays the same (and within the region)
        tax
        lda row_off,x
        sta cl_off
cl_g    inx
        cpx #25
        bcs cl_ge
        lda row_off,x
        cmp cl_off
        beq cl_g
cl_ge   ; rows cl_row..x-1: char layer lines up to x*8
        txa
        asl
        asl
        asl
        sec
        sbc cl_cy               ; lines available in these rows
        sta cl_n
        lda cg_b
        sec
        sbc cl_y
        cmp cl_n
        bcs cl_4
        sta cl_n
cl_4    jsr copy_part
        lda cl_y
        clc
        adc cl_n
        sta cl_y
        jmp cl_loop
cl_bgline
        ; one line of background colour (above/below the char layer)
        lda cl_y
        sta cg_a
        clc
        adc #1
        sta cg_b
        ldx cg_r
        lda rg_d021,x
        and #15
        ora #$40
        jsr fill_lines
        ldx cg_r
        inc cl_y
        lda cl_y
        sta cg_a
        ldx cg_r
        lda cg_b                ; restore the region end
        jmp cl_rest
cl_rest ; recompute the region end from the region list
        ldx cg_r
        inx
        cpx nregion
        bcc cl_r1
        lda #200
        bne cl_r2
cl_r1   lda rg_l0,x
cl_r2   cmp win_bot
        bcc cl_r3
        lda win_bot
cl_r3   sta cg_b
        jmp cl_loop
cl_xs   dta 0
cl_ys   dta 0
cl_y    dta 0
cl_cy   dta 0
cl_row  dta 0
cl_off  dta 0
cl_n    dta 0

; copy cl_n lines from char layer line cl_cy (ring offset cl_off) to FB
; line cl_y, shifted right by cl_xs: two blits when the ring wraps
copy_part
        lda #0
        sta bcb+17
        sta bcb+18
        sta bcb+19
        lda #1
        sta bcb+5
        sta bcb+11
        lda #<320
        sta bcb+3
        lda #>320
        sta bcb+4
        lda #<FBW
        sta bcb+9
        lda #>FBW
        sta bcb+10
        lda #$FF
        sta bcb+15
        lda #0
        sta bcb+16
        lda #8
        sta bcb+20
        lda cl_n
        sec
        sbc #1
        sta bcb+14
        ; source line address: V_CL + cy*320
        lda cl_cy
        sta ZPX+5
        lda #0
        sta ZPX+6
        lda ZPX+5
        asl
        rol ZPX+6
        asl
        rol ZPX+6
        asl
        rol ZPX+6
        asl
        rol ZPX+6
        asl
        rol ZPX+6
        asl
        rol ZPX+6               ; cy*64
        sta cp_s
        lda ZPX+6
        clc
        adc ZPX+5               ; + cy*256
        sta cp_s+1
        lda #0
        adc #0
        sta cp_s+2
        lda cp_s
        clc
        adc #<V_CL
        sta cp_s
        lda cp_s+1
        adc #>V_CL
        sta cp_s+1
        lda cp_s+2
        adc #^V_CL
        sta cp_s+2
        ; destination line: FB + y*368 + 24 + xs
        lda cl_y
        jsr fb_row
        lda ZPX
        clc
        adc #FBM
        sta cp_d
        lda ZPX+1
        adc #0
        sta cp_d+1
        lda ZPX+2
        adc #0
        sta cp_d+2
        lda cp_d
        clc
        adc cl_xs
        sta cp_d
        bcc cpp_1
        inc cp_d+1
        bne cpp_1
        inc cp_d+2
cpp_1   ; part 1: ring columns off..39 -> screen columns 0..39-off
        lda cl_off
        asl
        asl
        asl
        sta cp_o                ; off*8 (< 256 for off < 32)
        lda #0
        rol
        sta cp_o+1
        lda cl_off
        cmp #32
        bcc cpp_2
        ; off*8 >= 256
        lda cl_off
        asl
        asl
        asl
        sta cp_o
        lda #1
        sta cp_o+1
cpp_2   ; src = cp_s + off*8, width = 320 - off*8
        lda cp_s
        clc
        adc cp_o
        sta bcb
        lda cp_s+1
        adc cp_o+1
        sta bcb+1
        lda cp_s+2
        adc #0
        sta bcb+2
        lda cp_d
        sta bcb+6
        lda cp_d+1
        sta bcb+7
        lda cp_d+2
        sta bcb+8
        lda #<319
        sec
        sbc cp_o
        sta bcb+12
        lda #>319
        sbc cp_o+1
        sta bcb+13
        jsr emit_reg
        lda cl_off
        bne cpp_3
        rts
cpp_3   ; part 2: ring columns 0..off-1 -> screen columns 40-off..39
        lda cp_s
        sta bcb
        lda cp_s+1
        sta bcb+1
        lda cp_s+2
        sta bcb+2
        lda #<320
        sec
        sbc cp_o
        sta cp_w
        lda #>320
        sbc cp_o+1
        sta cp_w+1
        lda cp_d
        clc
        adc cp_w
        sta bcb+6
        lda cp_d+1
        adc cp_w+1
        sta bcb+7
        lda cp_d+2
        adc #0
        sta bcb+8
        lda cp_o
        sec
        sbc #1
        sta bcb+12
        lda cp_o+1
        sbc #0
        sta bcb+13
        jmp emit_reg
cp_s    dta 0,0,0
cp_d    dta 0,0,0
cp_o    dta 0,0
cp_w    dta 0,0

; ------------------------------------------------------------------
; sprites (NMI): instances of hardware sprites 7..0 (0 ends on top)
; ------------------------------------------------------------------
; sprite blits of list bl: spr_begin before the replay, spr_emit per
; finished instance (em_*), spr_finish after the regions
spr_begin
        lda #0
        sta spr_n
        lda #1
        sta ex_budget
        ldx bl
        lda lst_w_lo,x
        clc
        adc #<LST_SPR
        sta sp_lo
        lda lst_w_hi,x
        adc #>LST_SPR
        sta sp_hi
        rts

; end the list at the last sprite (or the last region slot)
spr_finish
        ldx bl
        lda spr_n
        clc
        adc #NUPD+NREG-1
        cmp endslot,x
        beq csp_x
        pha
        lda endslot,x           ; the old end gets NEXT back
        jsr slot_ptr
        ldy #20
        lda (ZPX),y
        ora #8
        sta (ZPX),y
        pla
        sta endslot,x
        jsr slot_ptr
        ldy #20
        lda (ZPX),y
        and #$F7
        sta (ZPX),y
        rts
csp_x   ; same end slot as last time: make sure it ends
        lda endslot,x
        jsr slot_ptr
        ldy #20
        lda (ZPX),y
        and #$F7
        sta (ZPX),y
        rts

; ZPX = window address of slot A of list bl (keeps X)
slot_ptr
        stx sp_x
        jsr mul21b              ; ZPX = A*21
        ldx bl
        lda ZPX
        clc
        adc lst_w_lo,x
        sta ZPX
        lda ZPX+1
        adc lst_w_hi,x
        sta ZPX+1
        ldx sp_x
        rts
sp_x    dta 0


