; ------------------------------------------------------------------
; Blitter lists of a picture (bank R, MEMAC-B window of V_UPD..V_RUNS).
; The lists have a fixed layout whose constant fields are written once
; (bank I, list_init); a picture only writes the variable fields:
;   run 0  cell updates (backwards from V_REG), then at V_REG 6 regions x
;          4 BCBs (copy or fill, fine scroll gap, left and right border);
;          unused BCBs copy one byte to NOPD
;   runs   per sprite n at V_RUNS + n*256: probe A (+0), probe B (+48),
;          draw + two behind-the-foreground patches (+96, +117, +138).
; A probe XORs the sprite's shape into the framebuffer with collision
; detection on the character foreground, then XORs it again (restored).
; A patch copies the character layer's foreground over the sprite.
; ------------------------------------------------------------------
LW      = MEMB_ON|(V_REG>>14)   ; window of V_UPD..V_RUNS
REGW    = WIN+(V_REG&$3FFF)
RUNW    = WIN+(V_RUNS&$3FFF)
NOPD    = V_DUMMY+48            ; where unused BCBs write
NREGB   = 6                     ; regions with BCBs
B_SRC   = 0                     ; BCB fields
B_DST   = 6
B_W     = 12
B_H     = 14
B_AND   = 15
B_XOR   = 16

; ---- cell updates ----------------------------------------------
put_updates
        lda fix_hi              ; the slot the last band shift used: its
        beq pu_0                ; constant fields again
        sta ZP+1
        lda fix_lo
        sta ZP
        ldy #20
pu_f    lda upd_tpl,y
        sta (ZP),y
        dey
        bpl pu_f
        lda #0
        sta fix_hi
pu_0    lda #<REGW
        sta ZP
        lda #>REGW
        sta ZP+1
        rts

; the cells of the last diff batch, below the slots written so far (ZP)
pu_cells
        ldx #0
pu_l    cpx ncell
        jcs pu_x
        stx t4
        lda ZP                  ; next slot below
        sec
        sbc #21
        sta ZP
        bcs pu_1
        dec ZP+1
pu_1    lda cells,x             ; row
        sta t0
        lda cells+1,x
        sta t1                  ; column
        ldx t0
        lda t1                  ; char and colour from the shadows (rings)
        clc
        adc rowoff,x
        cmp #40
        bcc pu_r
        sbc #40
pu_r    sta t5
        lda rowsh_lo,x
        clc
        adc t5
        sta pu_c+1
        lda rowsh_hi,x
        adc #0
        sta pu_c+2
        lda colsh_lo,x
        clc
        adc t5
        sta pu_k+1
        lda colsh_hi,x
        adc #0
        sta pu_k+2
pu_k    lda $FFFF
        sta t2                  ; colour
pu_c    lda $FFFF
        sta t3                  ; char
        lda rowcs,x
        asl                     ; slot = charset*2 (+1 hires)
        sta t5
        lda t2
        and #8
        bne pu_mc
        inc t5
        jmp pu_hs
pu_mc   jsr tile_fresh
        lda t2
        and #7
        ora #$F8
        bne pu_m
pu_hs   jsr tile_fresh
        lda t2
        and #15
        ora #$F0
pu_m    ldy #B_AND
        sta (ZP),y
        ; src = V_TILE + slot*$4000 + ch*64
        lda t3
        asl
        asl
        asl
        asl
        asl
        asl
        ldy #0
        sta (ZP),y
        lda t5
        asl
        asl
        asl
        asl
        asl
        asl
        sta t5
        lda t3
        lsr
        lsr
        ora t5
        iny
        sta (ZP),y
        lda #^V_TILE
        iny
        sta (ZP),y
        ; dst = V_CL + row*2560 + column*8 (no carry out of the middle byte)
        lda t1
        asl
        asl
        asl
        sta t5
        lda #0
        rol
        sta t2
        lda t5
        clc
        adc cl_row0,x
        ldy #6
        sta (ZP),y
        lda cl_row1,x
        adc t2
        iny
        sta (ZP),y
        lda #^V_CL                ; (the layer is within one 64K bank)
        iny
        sta (ZP),y
        ldx t4
        inx
        inx
        jmp pu_l
pu_x    rts

; run 0's head: a band shift first, then the cells
pu_end  lda shift_pend          ; a band shift goes first
        beq pu_x1
        lda ZP
        sec
        sbc #21
        sta ZP
        sta fix_lo
        bcs pu_s
        dec ZP+1
pu_s    lda ZP+1
        sta fix_hi
        ldy #20
pu_s1   lda bcb,y
        sta (ZP),y
        dey
        bpl pu_s1
        lda #0
        sta shift_pend
pu_x1   lda ZP                  ; run 0 starts at the last slot written
        sta bl_lo
        lda ZP+1
        clc
        adc #>(V_REG-REGW)
        sta bl_mid
        lda #^V_REG
        sta bl_hi
        rts

; the cell's tile (slot t5: charset*2 + hires) of char t3: expanded now
; when stale (the char changed while it was not on screen)
tile_fresh
        stx hf_x
        ldy t5
        ldx t3
        lda dchar,x
        and slot_stale,y
        beq hf_x0
        lda ZP
        pha
        lda ZP+1
        pha
        lda t5
        pha
        lda t4
        pha
        lda t3
        pha
        lda t5
        and #1
        tax
        lda slot_k,x
        sta ec_k
        lda t5
        lsr                     ; charset
        ldx t3
        jsr expand_char
        pla
        sta t3
        pla
        sta t4
        pla
        sta t5
        pla
        sta ZP+1
        pla
        sta ZP
        lda #LW
        jsr memb
hf_x0   ldx hf_x
        rts
hf_x    dta 0
slot_stale dta $08,$02,$10,$04
slot_k  dta 1,2

fix_lo  dta 0
fix_hi  dta 0
upd_tpl dta 0,0,0, 8,0, 1, 0,0,0, <320,>320, 1, 7,0, 7, $FF,0, 0,0,0, 8

; framebuffer row A -> rowa (lo, mid, hi) in the back buffer: A*320
fb_row  sta t0
        and #3
        lsr
        ror
        ror                     ; (A&3)<<6
        sta rowa
        lda t0
        lsr
        lsr
        clc
        adc t0
        sta rowa+1
        lda back
        sta rowa+2              ; FB0 $00000, FB1 $10000
        rts
rowa    dta 0,0,0

; (ZP) BCB: dst = rowa + A (A < 256)
put_dst ldy #B_DST
        clc
        adc rowa
        sta (ZP),y
        iny
        lda rowa+1
        adc #0
        sta (ZP),y
        iny
        lda rowa+2
        adc #0
        sta (ZP),y
        rts

; (ZP) BCB: width - 1 = A (< 256), height - 1 = t3
put_wh  ldy #B_W
        sta (ZP),y
        iny
        lda #0
        sta (ZP),y
        iny
        lda t3
        sta (ZP),y
        rts

; (ZP) BCB writes one byte at NOPD
put_nop ldy #B_DST
        lda #<NOPD
        sta (ZP),y
        iny
        lda #>NOPD
        sta (ZP),y
        iny
        lda #^NOPD
        sta (ZP),y
        lda #0
        ldy #B_W
        sta (ZP),y
        iny
        sta (ZP),y
        iny
        sta (ZP),y
        rts

; ZP = region BCB X (0-23)
reg_ptr lda rb_lo,x
        sta ZP
        lda rb_hi,x
        sta ZP+1
        rts
rb_lo   :24 dta <(REGW+#*21)
rb_hi   :24 dta >(REGW+#*21)

; ---- regions ----------------------------------------------------
put_regions
        lda #0
        sta t4
prg_l   lda t4
        asl
        asl
        sta t5                  ; first BCB of the region
        ldx t4
        cpx nreg
        bcc prg_on
        cpx preg
        jcs prg_n0              ; (NOPs already)
        lda #4                  ; unused region: four NOPs
        sta t0
prg_u   ldx t5
        jsr reg_ptr
        jsr put_nop
        inc t5
        dec t0
        bne prg_u
        jmp prg_n
prg_on  lda reg_y1,x
        sec
        sbc reg_y0,x
        sec
        sbc #1
        sta t3                  ; height - 1
        lda reg_y0,x
        jsr fb_row
        ldx t4
        lda reg_e,x
        tax
        lda LOG+2+$11,x
        and #$10
        sta t1                  ; display on
        lda LOG+2+$16,x
        sta t2                  ; $D016
        ldx t5
        jsr reg_ptr
        lda t1
        bne prg_cp
        ; display off: the copy BCB fills with the border colour
        ldy #B_AND
        lda #0
        sta (ZP),y
        iny
        lda #PX_BRD
        sta (ZP),y
        lda #0
        jsr put_dst
        lda #<319
        jsr put_wh
        ldy #B_W+1
        lda #>319
        sta (ZP),y
        ldx t5
        inx
        jsr reg_ptr
        jsr put_nop
        ldx t5
        inx
        inx
        jsr reg_ptr
        jsr put_nop
        ldx t5
        inx
        inx
        inx
        jsr reg_ptr
        jsr put_nop
        jmp prg_n
prg_cp  ldy #B_AND              ; copy: src = V_CL + y0*320
        lda #$FF
        sta (ZP),y
        iny
        lda #0
        sta (ZP),y
        ldy #B_SRC
        lda rowa
        sta (ZP),y
        iny
        lda rowa+1
        sta (ZP),y
        lda t2                  ; dst = row + fine scroll, width 320 - xs
        and #7
        sta t0
        jsr put_dst
        lda #<319
        sec
        sbc t0
        ldy #B_W
        sta (ZP),y
        iny
        lda #>319
        sbc #0
        sta (ZP),y
        iny
        lda t3
        sta (ZP),y
        ldx t5                  ; the fine scroll's gap
        inx
        jsr reg_ptr
        lda t2
        and #7
        beq prg_g0
        sec
        sbc #1
        sta t0
        lda #0
        jsr put_dst
        lda t0
        jsr put_wh
        jmp prg_b
prg_g0  jsr put_nop
prg_b   ldx t5                  ; 38 columns: border over 7 + 9 pixels
        inx
        inx
        jsr reg_ptr
        lda t2
        and #8
        bne prg_b0
        lda #0
        jsr put_dst
        lda #6
        jsr put_wh
        ldx t5
        inx
        inx
        inx
        jsr reg_ptr
        lda #<311
        jsr put_dst311
        lda #8
        jsr put_wh
        jmp prg_n
prg_b0  jsr put_nop
        ldx t5
        inx
        inx
        inx
        jsr reg_ptr
        jsr put_nop
prg_n   inc t4
        lda t4
        cmp #NREGB
        bcs prg_x
        jmp prg_l
prg_n0  jmp prg_n
prg_x   lda nreg
        sta preg
        rts
preg    dta NREGB

; dst = rowa + 311
put_dst311
        ldy #B_DST
        lda rowa
        clc
        adc #<311
        sta (ZP),y
        iny
        lda rowa+1
        adc #>311
        sta (ZP),y
        iny
        lda rowa+2
        adc #0
        sta (ZP),y
        rts

; ---- sprites ------------------------------------------------------
spn     dta 0
po      dta 0,0                 ; (sprite_parts: rows * 24 into the sprite)

; run list entry: address (lo, mid) of ZP
add_run ldx nrun
        lda ZP
        sta rl_lo,x
        lda ZP+1
        clc
        adc #>(V_RUNS-RUNW)
        sta rl_mid,x
        inc nrun
        rts
rl_lo   .ds 24
rl_mid  .ds 24

; (ZP) BCB of part X: cache source, framebuffer destination, the sprite's
; width, the part's rows
part_bcb
        ldy #B_SRC
        lda pk_sl,x
        sta (ZP),y
        iny
        lda pk_sh,x
        sta (ZP),y
        ldy #B_DST
        lda pk_dl,x
        sta (ZP),y
        iny
        lda pk_dm,x
        sta (ZP),y
        iny
        lda pk_dh,x
        sta (ZP),y
        ldy spn
        lda sp_w1,y
        ldy #B_W
        sta (ZP),y
        ldy #B_H
        lda pk_h1,x
        sta (ZP),y
        rts

put_runs
        lda #0
        sta nrun
        ldx #7                  ; probes: the XOR and its undo, per part
pr_s    stx spn
        lda sp_on,x
        beq pr_sn
        txa
        clc
        adc #>RUNW
        sta ZP+1
        txa
        asl
        sta t5                  ; part k = n*2
        lda #0
        sta ZP
pr_p    ldx nrun
        lda spn
        sta run_k,x
        ldx t5
        lda pk_y,x              ; C64 line = row + 51
        clc
        adc #51
        ldx nrun
        sta run_l,x
        lda #0
        adc #0
        sta run_h,x
        jsr add_run
        ldx t5
        jsr part_bcb
        lda ZP
        clc
        adc #21
        sta ZP
        jsr part_bcb
        ldx spn
        lda sp_np,x
        cmp #2
        bcc pr_sn
        lda t5
        lsr
        bcs pr_sn               ; (both parts done)
        inc t5
        lda #48
        sta ZP
        bne pr_p
pr_sn   ldx spn
        dex
        bpl pr_s
        ldx #7                  ; draws, 7 first (sprite 0 on top)
pd_s    stx spn
        lda sp_on,x
        beq pd_sn
        txa
        clc
        adc #>RUNW
        sta ZP+1
        lda #96
        sta ZP
        ldx nrun
        lda spn
        ora #$80
        sta run_k,x
        jsr add_run
        lda spn
        asl
        sta t5
        tax
        jsr part_bcb            ; part 0: the sprite's first row...
        ldx spn
        lda sp_h,x              ; ...and all its rows
        sec
        sbc #1
        ldy #B_H
        sta (ZP),y
        lda #117                ; behind-the-foreground patches
        jsr patch
        lda #138
        inc t5
        jsr patch
pd_sn   ldx spn
        dex
        bpl pd_s
        rts

; (ZP lo = A) patch of part t5 (or a NOP)
patch   sta ZP
        ldx t5
        txa
        and #1
        ldy spn
        beq pt_0                ; part 0 exists
        lda sp_np,y
        cmp #2
        bcc pt_nop
pt_0    lda pk_bh,x
        beq pt_nop
        lda #0
        sta pat_nop,x
        ldy #B_SRC
        lda pk_cl,x
        sta (ZP),y
        iny
        lda pk_cm,x
        sta (ZP),y
        ldy #B_DST
        lda pk_pl,x
        sta (ZP),y
        iny
        lda pk_pm,x
        sta (ZP),y
        iny
        lda pk_dh,x
        sta (ZP),y
        ldy #B_W
        lda pk_pw,x
        sta (ZP),y
        ldy #B_H
        lda pk_h1,x
        sta (ZP),y
        rts
pt_nop  lda pat_nop,x
        bne pt_x                ; (a NOP already)
        inc pat_nop,x
        jmp put_nop
pt_x    rts

; ---- XDL of the back framebuffer -----------------------------------
put_xdl lda #MEMB_ON|(V_XDL>>14)
        jsr memb
        lda back
        lsr
        ror                     ; *$80
        clc
        adc #<(WIN+(V_XDL&$3FFF))
        sta ZP
        lda #>(WIN+(V_XDL&$3FFF))
        adc #0
        sta ZP+1
        ldy #0
        lda #$24                ; 20 blank lines
        sta (ZP),y
        iny
        lda #0
        sta (ZP),y
        iny
        lda #19
        sta (ZP),y
        iny
        sty xdl_y
        ldx #0
px_l    stx t4
        txa                     ; merge regions with the same palette
        tay
px_m    lda reg_p+1,y
        cmp reg_p,x
        bne px_m1
        iny
        cpy nreg
        bcc px_m
px_m1   cpy nreg                ; Y: last region of the segment
        bcc px_m2
        ldy nreg
        dey
px_m2   sty t5
        lda reg_y0,x
        jsr fb_row
        ldy xdl_y
        lda #$62                ; overlay, repeat, address
        sta (ZP),y
        iny
        ldx t5
        inx
        cpx nreg
        lda #$08                ; attributes (+ end)
        bcc px_1
        lda #$88
px_1    sta (ZP),y
        iny
        ldx t5
        lda reg_y1,x
        ldx t4
        sec
        sbc reg_y0,x
        sec
        sbc #1
        sta (ZP),y
        iny
        lda rowa
        sta (ZP),y
        iny
        lda rowa+1
        sta (ZP),y
        iny
        lda rowa+2
        sta (ZP),y
        iny
        lda #<320
        sta (ZP),y
        iny
        lda #>320
        sta (ZP),y
        iny
        lda reg_p,x
        asl
        asl
        asl
        asl
        ora #$01                ; normal width, palette
        sta (ZP),y
        iny
        lda #$FF
        sta (ZP),y
        iny
        sty xdl_y
        ldx t5
        inx
        cpx nreg
        jcc px_l
        rts
xdl_y   dta 3
