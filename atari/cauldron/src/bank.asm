; ------------------------------------------------------------------
; Bank R: 8K of VRAM at $E000-$FFFF (MEMAC-A) while the runtime works.
; Renderer, blitter chain, NMI work, set-up and the sound driver.
;
; Picture: the C64 screen is kept as a 320x200 character layer (V_CL).
; Rows whose cells the game may have changed (the hooks mark them) are
; compared with a shadow copy of screen and colour RAM, and the changed
; cells are blitted from expanded tiles. A coarse scroll of the game is
; applied as a shift of its band of rows. Each picture copies the layer
; into the back framebuffer per raster region (fine scroll, 38 columns,
; blanking) and draws the sprites. Pixel values are palette indices that
; say which colour register they use (defs.asm), so the colour registers
; only change the palettes; each region gets one of the three overlay
; palettes (XDL).
;
; Collisions: before the sprites are drawn, each sprite's rectangle of
; the framebuffer is copied to a scratch area and the sprite is blitted
; there with the blitter's collision detection set to the character
; foreground (sprite-background); the sprites are then drawn (7 first, so
; 0 is on top) with detection set to sprite pixels (sprite-sprite). Each
; of these is one blitter run; the IRQ at its end reads the code.
; ------------------------------------------------------------------
scr_sh  = $F570                 ; screen shadow (1000)
col_sh  = $F958                 ; colour shadow (1000)
LOGSZ   = 49                    ; log entry: line lo, line hi, VIC $00-$2E
cells   = $0D38                 ; changed cells: row, column (2 bytes each; code A RAM)
CELLB   = 200                   ; (100 cells per picture)
charrows = $FD40                ; row groups where each char was drawn
vars    = $FE40                 ; to $FEF9
dchar   = $FEFA                 ; dirty chars (charset update), stale tiles

        org vars
nreg      .ds 1
reg_y0    .ds 8         ; region: first framebuffer row
reg_y1    .ds 8
reg_e     .ds 8         ; its log entry
reg_p     .ds 8         ; its palette (1-3)
npal      .ds 1
rowcs     .ds 25        ; charset of each row (0: $7000, 1: $7800)
ncell     .ds 1         ; bytes used in cells
sweep     .ds 1         ; background check row
nrun      .ds 1         ; runs after run 0
run_i     .ds 1         ; run in progress (0 = run 0)
run_k     .ds 24        ; run: sprite n, bit 7 = draw (else probe)
run_l     .ds 24        ; probe: C64 line of its first row
run_h     .ds 24
back      .ds 1         ; framebuffer being composed
gl        .ds 8         ; glyph bytes
t0        .ds 1
t1        .ds 1
t2        .ds 1
t3        .ds 1
t4        .ds 1
t5        .ds 1
n8        .ds 1
dch       .ds 1
cu_bits   .ds 1
cu_x      .ds 1
cu_y      .ds 1
bl_lo     .ds 1         ; run 0 address
bl_mid    .ds 1
bl_hi     .ds 1
ss_acc    .ds 1
sbg_tl    .ds 8         ; per sprite: line of its first probe part that hit
sbg_th    .ds 8         ; ($FF none)
ptrs      .ds 8
        .print 'bank vars end: ', *
        ert * > dchar
tag_p   = $0E00                 ; sprite cache tags (buffer page, after boot)
tag_k   = $0E80

        org $E000
rbank_start

; ------------------------------------------------------------------
; log: VIC shadow + current line into entry nlog
; ------------------------------------------------------------------
log_put ldx nlog
        cpx #4
        bcs lp_x
        lda log_off,x
        tay
        lda cur_lo
        sta LOG,y
        lda cur_hi
        sta LOG+1,y
        ldx #0
lp_l    lda VIC,x
        sta LOG+2,y
        iny
        inx
        cpx #$2F
        bne lp_l
        inc nlog
lp_x    rts
log_off :4 dta #*LOGSZ

; ------------------------------------------------------------------
; the picture: called in the IRQ after the C64 frame
; ------------------------------------------------------------------
render  jsr regions
        jsr row_charsets
        lda cs_any
        beq rn_1
        jsr charset_update
rn_1    lda shift_n
        beq rn_2
        jsr band_shift
rn_2    jsr site_rows
        ldx sweep               ; background check: one row per picture
        inx
        cpx #25
        bcc rn_3
        ldx #0
rn_3    stx sweep
        lda #1
        sta rowd,x
        jsr palettes
        lda back
        eor #1
        sta back
        ; run 0 (cells, regions) starts now; the sprites' runs are written
        ; while it runs (its end IRQ waits for this one to return)
        lda #LW                 ; changed cells: diff and blits in batches
        jsr memb
        jsr put_updates
        lda #3
        sta t6
rn_d    lda #0
        jsr memb
        jsr diff_rows
        lda #LW
        jsr memb
        lda ncell
        beq rn_e
        jsr pu_cells
        dec t6
        bne rn_d
rn_e    jsr pu_end
        jsr put_regions
        jsr put_xdl
        lda #0
        jsr memb
        lda #0
        sta run_i
        sta ss_acc
        sta nrun
        ldx #7
        lda #$FF
rn_c    sta sbg_th,x
        dex
        bpl rn_c
        lda #1
        sta chain_on
        lda bl_lo
vr_0    sta VBX+VB_BLAD
        lda bl_mid
vr_1    sta VBX+VB_BLAD+1
        lda bl_hi
vr_2    sta VBX+VB_BLAD+2
        lda #1
vr_3    sta VBX+VB_BLIT
        jsr sprite_prep
        lda #LW
        jsr memb
        jsr put_runs
        lda #0
        jmp memb

; ------------------------------------------------------------------
; chain: a run ended (IRQ). Its collision code, then the next run.
; ------------------------------------------------------------------
chain_step
        ldx run_i
        beq cs_next             ; run 0: layer, regions, scratch copies
vc_0    lda VBX+VB_BLAD         ; BLT_COLLISION_CODE
        beq cs_next
        sta t1
        lda run_k-1,x
        bmi cs_draw
        tay                     ; probe of sprite Y hit the foreground
        lda sbg_th,y
        cmp #$FF
        bne cs_next             ; (an earlier part hit already)
        lda run_l-1,x
        sta sbg_tl,y
        lda run_h-1,x
        sta sbg_th,y
        jmp cs_next
cs_draw and #7                  ; draw of sprite n hit sprite (code-$C0)/4
        tay
        lda bitv,y
        ora ss_acc
        sta ss_acc
        lda t1
        lsr
        lsr
        and #7
        tay
        lda bitv,y
        ora ss_acc
        sta ss_acc
cs_next inc run_i
        ldx run_i
        dex
        cpx nrun
        bcs cs_done
        lda rl_lo,x
vc_1    sta VBX+VB_BLAD
        lda rl_mid,x
vc_2    sta VBX+VB_BLAD+1
        lda #^V_RUNS
vc_3    sta VBX+VB_BLAD+2
        lda #1
vc_4    sta VBX+VB_BLIT
        rts
cs_done lda #0
        sta chain_on
        lda back
        sta ready
        lda ss_acc              ; collisions for the game's next frame
        ora ss_new
        sta ss_new
        jmp sbg_groups

; sprite-background hits -> groups (line, sprites) in raster order
sbg_groups
        lda #0
        sta nsbg
sg_l    ldy #$FF                ; the earliest remaining hit
        lda #$FF
        sta t0
        sta t2
        ldx #7
sg_f    lda sbg_th,x
        cmp #$FF
        beq sg_n
        cmp t2
        bcc sg_b
        bne sg_n
        lda sbg_tl,x
        cmp t0
        bcs sg_n
sg_b    lda sbg_tl,x
        sta t0
        lda sbg_th,x
        sta t2
        txa
        tay
sg_n    dex
        bpl sg_f
        cpy #$FF
        beq sg_x
        ldx nsbg                ; all sprites with that line form the group
        lda t0
        sta sbg_lo,x
        lda t2
        sta sbg_hi,x
        lda #0
        sta sbg_bits,x
        ldy #7
sg_g    lda sbg_th,y
        cmp t2
        bne sg_gn
        lda sbg_tl,y
        cmp t0
        bne sg_gn
        lda bitv,y
        ora sbg_bits,x
        sta sbg_bits,x
        lda #$FF
        sta sbg_th,y
sg_gn   dey
        bpl sg_g
        inc nsbg
        lda nsbg
        cmp #8
        bcc sg_l
sg_x    rts

; ------------------------------------------------------------------
; regions of the picture from the log: entry 0 from row 0, entry i from
; the row after its line (lines 51-250 are rows 0-199)
; ------------------------------------------------------------------
regions lda #1
        sta nreg
        lda #0
        sta reg_y0
        sta reg_e
        ldx #1
rg_l    cpx nlog
        bcs rg_end
        ldy log_off,x
        lda LOG+1,y             ; line >= 256: below the picture
        bne rg_end
        lda LOG,y
        sec
        sbc #50                 ; row = line + 1 - 51
        bcs rg_1
        lda #0
rg_1    cmp #200
        bcs rg_end
        ldy nreg
        cmp reg_y0-1,y
        bne rg_new
        lda log_off,x           ; same first row: replaces the region
        sta reg_e-1,y
        jmp rg_n
rg_new  sta reg_y0,y
        lda log_off,x
        sta reg_e,y
        inc nreg
rg_n    inx
        lda nreg
        cmp #8
        bcc rg_l
rg_end  ldx nreg
        lda #200
        sta reg_y1-1,x
        dex
        beq rg_x
rg_e    lda reg_y0,x
        sta reg_y1-1,x
        dex
        bne rg_e
rg_x    rts

; region of framebuffer row A -> X, its log entry -> Y (A kept)
region_of
        ldx nreg
ro_l    dex
        beq ro_x
        cmp reg_y0,x
        bcc ro_l
ro_x    ldy reg_e,x
        rts

; charset of each row (the region of its middle line); rows that change
; charset are redrawn
row_charsets
        lda #0
        sta t3                  ; region
        ldy #0                  ; row
rc_l    tya
        asl
        asl
        asl
        ora #4                  ; its middle line
        ldx t3
rc_f    cmp reg_y1,x
        bcc rc_in
        inx
        bne rc_f
rc_in   stx t3
        lda reg_e,x
        tax
        lda LOG+2+$18,x
        lsr
        and #1                  ; $0C -> 0 ($7000), $0E -> 1 ($7800)
        cmp rowcs,y
        beq rc_n
        sta rowcs,y
        sty t2
        ldx t2
        jsr row_invalid
        ldy t2
rc_n    iny
        cpy #25
        bne rc_l
        lda #0                  ; row groups of each charset
        sta csgrp
        sta csgrp+1
        ldy #24
rc_g    ldx rowcs,y
        lda grp_bit,y
        ora csgrp,x
        sta csgrp,x
        dey
        bpl rc_g
        rts
csgrp   dta 0,0

; row X: compare all its cells (the colour shadow gets impossible values)
row_invalid
        lda #1
        sta rowd,x
        lda colsh_lo,x
        sta ri_s+1
        lda colsh_hi,x
        sta ri_s+2
        ldy #39
        lda #$FF
ri_s    sta $FFFF,y
        dey
        bpl ri_s
        rts
rowsh_lo :25 dta <(scr_sh+#*40)
rowsh_hi :25 dta >(scr_sh+#*40)
colsh_lo :25 dta <(col_sh+#*40)
colsh_hi :25 dta >(col_sh+#*40)
scrrow_lo :25 dta <($4000+#*40)
scrrow_hi :25 dta >($4000+#*40)

; ------------------------------------------------------------------
; rows the game's screen writers reached
; ------------------------------------------------------------------
site_rows
        ldx #NSITE-1
sr_l    lda site_hit,x
        beq sr_n
        lda #0
        sta site_hit,x
        ldy site_r0,x
sr_r    lda #1
        sta rowd,y
        tya
        cmp site_r1,x
        iny
        bcc sr_r
sr_n    dex
        bpl sr_l
        rts

; ------------------------------------------------------------------
; diff: dirty rows against the shadows; changed cells -> cells
; ------------------------------------------------------------------
diff_rows
        lda #0
        sta ncell
        ldx #0
dr_l    lda ncell
        cmp #CELLB-80
        bcs dr_x                ; full: the rows stay dirty
        lda #0
        sta dr_lo
        lda #39
        sta dr_hi
        lda rowd,x
        bne dr_full
        lda edge,x              ; only the columns a scroll brought in
        beq dr_n
        bmi dr_el
        eor #$FF                ; right edge: 40-n..39
        sec
        adc #40
        sta dr_lo
        jmp dr_e
dr_el   and #$7F                ; left edge: 0..n-1
        sec
        sbc #1
        sta dr_hi
        jmp dr_e
dr_full lda #0
        sta rowd,x
dr_e    lda #0
        sta edge,x
        stx t2
        jsr diff_row
        ldx t2
dr_n    inx
        cpx #25
        bne dr_l
dr_x    rts

diff_row
        lda grp_bit,x
        sta dr_g
        lda scrrow_lo,x         ; screen and colour RAM of the row
        sta dr_s+1
        sta dr_c+1
        sta dr_r1+1
        sta dr_r2+1
        lda scrrow_hi,x
        sta dr_s+2
        sta dr_r1+2
        clc
        adc #$98                ; colour RAM = screen + $9800
        sta dr_c+2
        sta dr_r2+2
        ; columns 40-off..39 are at shadow 0..off-1, columns 0..39-off at
        ; off..39: two passes with the shadow base moved
        lda rowoff,x
        sta t3
        beq dr_p2
        sec
        sbc #40
        jsr dr_base             ; base + off - 40
        lda #40                 ; columns max(40-off, lo)..hi
        sec
        sbc t3
        cmp dr_lo
        bcs dr_l1
        lda dr_lo
dr_l1   sta dr_lim
        ldy dr_hi
        cpy dr_lim
        bcc dr_p2
        jsr dr_pass
dr_p2   lda t3
        jsr dr_base             ; base + off
        lda dr_lo               ; columns lo..min(39-off, hi)
        sta dr_lim
        lda #39
        sec
        sbc t3
        cmp dr_hi
        bcc dr_l2
        lda dr_hi
dr_l2   tay
        cpy dr_lim
        bcc dr_x0
        jmp dr_pass

; shadow bases of row t2 + A (signed)
dr_base sta t4
        ldx t2
        lda rowsh_lo,x
        clc
        adc t4
        sta dr_ss+1
        sta dr_w1+1
        lda t4
        and #$80
        beq dr_b1
        lda #$FF
dr_b1   sta t5
        adc rowsh_hi,x
        sta dr_ss+2
        sta dr_w1+2
        lda colsh_lo,x
        clc
        adc t4
        sta dr_cs+1
        sta dr_w2+1
        lda t5
        adc colsh_hi,x
        sta dr_cs+2
        sta dr_w2+2
dr_x0   rts

; compare columns Y down to dr_lim
dr_pass
dr_s    lda $4000,y
dr_ss   cmp $FFFF,y
        bne dr_ch
dr_c    lda $D800,y
dr_cs   cmp $FFFF,y
        bne dr_ch
dr_nx   dey
        bmi dr_x0
        cpy dr_lim
        bcs dr_s
        rts
dr_ch   lda ncell
        cmp #CELLB
        bcs dr_nx
dr_r1   lda $4000,y
dr_w1   sta $FFFF,y
        tax                     ; the char is seen in this row group
dr_r2   lda $D800,y
dr_w2   sta $FFFF,y
        and #8                  ; (bit 7: shown in hires)
        cmp #8
        lda #$80
        bcc dr_h
        lda #0
dr_h    ora dr_g
        ora charrows,x
        sta charrows,x
        ldx ncell
        lda t2
        sta cells,x
        tya
        sta cells+1,x
        inx
        inx
        stx ncell
        jmp dr_nx
dr_g    dta 0
dr_lim  dta 0
dr_lo   dta 0
dr_hi   dta 39
grp_bit :25 dta 1<<(#>>2)       ; row group (4 rows) bit

; ------------------------------------------------------------------
; charset rewritten by the game: expand the dirty chars again, then make
; the cells showing them compare as changed
; ------------------------------------------------------------------
charset_update
        lda #0
        sta cs_any
        sta cu_grp
        sta ndch
        tax
cu_b    lda cs_dirty,x
        jeq cu_bn
        sta cu_bits
        lda #0
        sta cs_dirty,x
        stx cu_x
        ldy #0
cu_bit  lsr cu_bits
        bcc cu_bn1
        sty cu_y
        txa                     ; char = x*8 + y (0-511)
        asl
        asl
        asl
        ora cu_y
        tax
        lda cu_x
        lsr
        lsr
        lsr
        lsr
        lsr
        sta t3                  ; charset 0/1
        tay
        lda charrows,x          ; row groups of this charset showing it
        and csgrp,y
        bne cu_vis
        lda dchar,x             ; not on screen: both tiles stale, expanded
        ora stale_bit,y         ; when a cell needs them (put_updates)
        ora stale_bit+2,y
        sta dchar,x
        jmp cu_nx
cu_vis  sta t0
        ora cu_grp
        sta cu_grp
        lda t0
        eor #$FF
        and charrows,x          ; (those groups are rebuilt by the diff)
        sta charrows,x
        and #$80                ; hires tile now only if shown in hires
        asl
        rol
        rol
        ora #1
        sta ec_k
        lda dchar,x
        ora #1                  ; scan for it
        sta dchar,x
        txa
        ldy ndch
        sta dch_l,y
        cpy #31
        bcs cu_nd
        inc ndch
cu_nd
        lda t3
        jsr expand_char
cu_nx   ldx cu_x
        ldy cu_y
cu_bn1  iny
        cpy #8
        bne cu_bit
cu_bn   inx
        cpx #64
        jne cu_b
        lda #0
        jsr memb
        ldx #24                 ; rows of those groups: the cells with a
cu_r    lda grp_bit,x           ; dirty char compare as changed
        and cu_grp
        beq cu_rn
        stx t2
        lda scrrow_lo,x
        sta cu_s+1
        lda scrrow_hi,x
        sta cu_s+2
        lda colsh_lo,x
        sta cu_w+1
        lda colsh_hi,x
        sta cu_w+2
        ldy #39
cu_s    ldx $4000,y
        lda dchar,x
        lsr
        bcc cu_sn
        ldx t2                  ; (ring index of the column)
        tya
        clc
        adc rowoff,x
        cmp #40
        bcc cu_i
        sbc #40
cu_i    tax
        lda #$FF
cu_w    sta $FFFF,x
        ldx t2
        lda #1
        sta rowd,x
cu_sn   dey
        bpl cu_s
        ldx t2
cu_rn   dex
        bpl cu_r
        ldy ndch                ; clear the dirty bits
        beq cu_c0
cu_c    ldx dch_l-1,y
        lda dchar,x
        and #$FE
        sta dchar,x
        dey
        bne cu_c
cu_c0   rts
dch_l   .ds 32                  ; (the last one may repeat: harmless)
cu_grp  dta 0
shift_pend dta 0
ndch    dta 0

; char X of charset A (0/1): glyph -> tile slots; ec_k: bit 0 multicolour,
; bit 1 hires. The tiles not expanded keep their stale bits (dchar).
expand_char
        sta t3
        stx t4
        lda #0
        jsr memb
        lda t4                  ; glyph $7000 + A*$800 + X*8
        sta ZP
        lda #0
        asl ZP
        rol
        asl ZP
        rol
        asl ZP
        rol
        sta ZP+1
        lda t3
        asl
        asl
        asl
        ora ZP+1
        ora #$70
        sta ZP+1
        ldy #7
ec_g    lda (ZP),y
        sta gl,y
        dey
        bpl ec_g
        lda t4                  ; tile: $4000 + ch*64 in the slot's window
        sta ZP
        lda #0
        ldx #6
ec_sh   asl ZP
        rol
        dex
        bne ec_sh
        ora #>WIN
        sta ZP+1
        lda t3                  ; slot = charset*2 (+1 hires)
        asl
        ora #MEMB_ON|(V_TILE>>14)
        sta t5
        lda ec_k
        lsr
        bcc ec_hi
        ldx t4                  ; multicolour: fresh
        ldy t3
        lda stale_bit,y
        eor #$FF
        and dchar,x
        sta dchar,x
        lda t5
        jsr memb
        ldx #0                  ; pairs -> codes, doubled
        ldy #0
ec_m    lda gl,x
        sta ec_b
        lda #4
        sta ec_n
ec_mp   lda #0
        asl ec_b
        rol
        asl ec_b
        rol
        stx ec_x
        tax
        lda mc_code,x
        ldx ec_x
        sta (ZP),y
        iny
        sta (ZP),y
        iny
        dec ec_n
        bne ec_mp
        inx
        cpx #8
        bne ec_m
ec_hi   lda ec_k
        and #2
        beq ec_x0
        ldx t4                  ; hires: fresh
        ldy t3
        lda stale_bit+2,y
        eor #$FF
        and dchar,x
        sta dchar,x
        lda t5
        ora #1
        jsr memb
        ldx #0
        ldy #0
ec_h    lda gl,x
        sta ec_b
        lda #8
        sta ec_n
ec_hp   asl ec_b
        lda #PX_BG
        bcc ec_h0
        lda #PX_HI|$0F
ec_h0   sta (ZP),y
        iny
        dec ec_n
        bne ec_hp
        inx
        cpx #8
        bne ec_h
ec_x0   rts
ec_k    dta 3               ; tiles to expand: bit 0 multicolour, bit 1 hires
stale_bit dta $08,$10,$02,$04   ; dchar: multicolour stale (charset 0, 1), hires
ec_b    dta 0
ec_n    dta 0
ec_x    dta 0
mc_code dta PX_BG,PX_BG1,PX_FG2,PX_MC|7

; MEMAC-B: A = value
memb
vb_0    sta VBX+VB_MEMB
        rts

; ------------------------------------------------------------------
; coarse scroll: shift the band of 7 rows in the layer and the shadows
; by shift_n columns (+ = content moved left); the new columns then
; differ from the shadow and are drawn by the diff
; ------------------------------------------------------------------
band_shift
        lda shift_n
        ldx #0
        stx shift_n
        sta t1                  ; sign
        bpl bs_1
        eor #$FF
        clc
        adc #1
bs_1    sta t0                  ; columns
        cmp #32
        bcc bs_2
        ldx band_row            ; scrolled very far: redraw the band
        lda #7
        sta t3
bs_all  jsr row_invalid
        inx
        dec t3
        bne bs_all
        rts
bs_2    asl
        asl
        asl
        sta n8                  ; pixels
        ldx band_row            ; shadow rows are rings: column x is at
        lda #7                  ; (x + rowoff) mod 40
        sta t3
bs_r    lda t1
        bmi bs_rn
        lda rowoff,x            ; content moved left: offset + n
        clc
        adc t0
        cmp #40
        bcc bs_o
        sbc #40
        jmp bs_o
bs_rn   lda rowoff,x            ; right: offset - n
        sec
        sbc t0
        bcs bs_o
        adc #40
bs_o    sta rowoff,x
        jsr bs_inv              ; (the new columns' ring slots: invalid)
        lda t1                  ; the new columns to compare: the right edge
        and #$80                ; for a left scroll, the left edge (bit 7)
        sta t5                  ; for a right one; both: the whole row
        ldy edge,x
        bne bs_e0
        lda t0
        jmp bs_e4
bs_e0   tya
        eor t5
        bmi bs_e2               ; (direction changed)
        tya
        and #$7F
        clc
        adc t0
        cmp #40
        bcc bs_e4
        lda #39
bs_e4   ora t5
        sta edge,x
        jmp bs_e3
bs_e2   lda #1
        sta rowd,x
bs_e3
        inx
        dec t3
        bne bs_r
        ; the layer: one blit of the band's 56 lines
        ldx #20
bs_c    lda shift_bcb,x
        sta bcb,x
        dex
        bpl bs_c
        lda #<319               ; width - 1 = 319 - 8n
        sec
        sbc n8
        sta bcb+12
        lda #>319
        sbc #0
        sta bcb+13
        ldx band_row
        lda t1
        bmi bs_right
        lda cl_row0,x           ; left: dst = band, src = band + 8n
        sta bcb+6
        clc
        adc n8
        sta bcb
        lda cl_row1,x
        sta bcb+7
        adc #0
        sta bcb+1
        lda #^V_CL                ; (the layer is within one 64K bank)
        sta bcb+8
        adc #0
        sta bcb+2
        jmp bs_go
bs_right                        ; right: backwards from the band's last pixel
        lda cl_row0,x
        clc
        adc #<(55*320+319)
        sta bcb+6
        lda cl_row1,x
        adc #>(55*320+319)
        sta bcb+7
        lda #^V_CL                ; (the layer is within one 64K bank)
        adc #0
        sta bcb+8
        lda bcb+6
        sec
        sbc n8
        sta bcb
        lda bcb+7
        sbc #0
        sta bcb+1
        lda bcb+8
        sbc #0
        sta bcb+2
        lda #<[-320]
        sta bcb+3
        sta bcb+9
        lda #>[-320]&$1F
        sta bcb+4
        sta bcb+10
        lda #$FF
        sta bcb+5
        sta bcb+11
bs_go   lda #8                  ; (it heads run 0: put_updates)
        sta bcb+20
        sta shift_pend
        rts

; ring slots of the t0 new columns of row X (right edge for a left
; scroll): their colour shadow gets an impossible value
bs_inv  lda colsh_lo,x
        sta bv_w+1
        lda colsh_hi,x
        sta bv_w+2
        ldy t0
bv_l    tya                     ; column: 40-k (left scroll) or k-1 (right)
        bit t1
        bmi bv_r
        eor #$FF
        sec
        adc #40
        jmp bv_c
bv_r    sec
        sbc #1
bv_c    clc
        adc rowoff,x
        cmp #40
        bcc bv_1
        sbc #40
bv_1    stx bv_x
        tax
        lda #$FF
bv_w    sta $FFFF,x
        ldx bv_x
        dey
        bne bv_l
        rts
bv_x    dta 0

shift_bcb
        dta 0,0,0, <320,>320, 1, 0,0,0, <320,>320, 1, 0,0, 55, $FF,0, 0,0,0, 0
cl_row0 :25 dta <(V_CL+#*2560)
cl_row1 :25 dta >(V_CL+#*2560)

; ------------------------------------------------------------------
; palettes: each region's colours ($D020-$D023, $D025-$D02E) in one of
; palettes 1-3 (pal_new, 14 bytes each), the region's palette in reg_p
; ------------------------------------------------------------------
palettes
        lda #0
        sta npal
        sta t2                  ; region
pa_r    ldx t2
        lda reg_e,x
        tax
        lda LOG+2+$20,x
        and #15
        sta pkey+0
        lda LOG+2+$21,x
        and #15
        sta pkey+1
        lda LOG+2+$22,x
        and #15
        sta pkey+2
        lda LOG+2+$23,x
        and #15
        sta pkey+3
        lda LOG+2+$25,x
        and #15
        sta pkey+4
        lda LOG+2+$26,x
        and #15
        sta pkey+5
        lda LOG+2+$27,x
        and #15
        sta pkey+6
        lda LOG+2+$28,x
        and #15
        sta pkey+7
        lda LOG+2+$29,x
        and #15
        sta pkey+8
        lda LOG+2+$2A,x
        and #15
        sta pkey+9
        lda LOG+2+$2B,x
        and #15
        sta pkey+10
        lda LOG+2+$2C,x
        and #15
        sta pkey+11
        lda LOG+2+$2D,x
        and #15
        sta pkey+12
        lda LOG+2+$2E,x
        and #15
        sta pkey+13

        ldx #0                  ; an equal palette?
pa_f    cpx npal
        bcs pa_new
        stx t3
        lda pal_off,x
        tax
        ldy #0
pa_c    lda pkey,y
        cmp pal_new,x
        bne pa_fn
        inx
        iny
        cpy #14
        bne pa_c
        ldx t3
        jmp pa_set
pa_fn   ldx t3
        inx
        bne pa_f
pa_new  cpx #3
        bcc pa_n1
        ldx #2                  ; (more than three: the last one)
        bne pa_set
pa_n1   stx t3
        lda pal_off,x
        tax
        ldy #0
pa_cp   lda pkey,y
        sta pal_new,x
        inx
        iny
        cpy #14
        bne pa_cp
        ldx t3
        inc npal
pa_set  inx
        txa
        ldx t2
        sta reg_p,x
        inc t2
        lda t2
        cmp nreg
        jcc pa_r
        rts
pal_off dta 0,14,28
pkey    dta 0,0,0,0,0,0,0,0,0,0,0,0,0,0

; ------------------------------------------------------------------
; sprites of the picture: geometry from the log entry of the region of
; each sprite's first row; cache misses expanded now
; ------------------------------------------------------------------
NSPR    = 8
sp_x0   .ds 8           ; clipped rectangle in the framebuffer
sp_x0h  .ds 8
sp_y0   .ds 8
sp_w    .ds 8
sp_h    .ds 8
sp_off  .ds 8           ; offset in the 24x21 sprite (lo, hi)
sp_offh .ds 8
sp_on   .ds 8           ; drawn
sp_slot .ds 8
sp_e    .ds 8           ; log entry (offset)
t5x     dta 0

sprite_prep
        ldx #7
sp_p    lda $43F8,x
        sta ptrs,x
        dex
        bpl sp_p
        ldx #7
sp_l    stx t2
        lda #0
        sta sp_on,x
        jsr sprite_geom
        ldx t2
        lda sp_on,x
        beq sp_n
        jsr sprite_parts
sp_n    ldx t2
        dex
        bpl sp_l
        rts

; sprite t2's rows by region (two parts at most) and the blitter fields of
; each part k = n*2 + p: cache source, framebuffer destination, rows - 1,
; behind the foreground ($D01B) and the patch from the character layer
; (shifted by the region's fine scroll)
sprite_parts
        ldx t2
        lda sp_w,x
        sec
        sbc #1
        sta sp_w1,x
        lda sp_y0,x
        sta t0
        clc
        adc sp_h,x
        sta t1                  ; end
        txa
        asl
        sta t4                  ; part index n*2
        lda #0
        sta sp_np,x
        sta po                  ; rows * 24 into the sprite
        sta po+1
spt_l   lda t0
        jsr region_of           ; X region, Y entry offset
        lda reg_y1,x
        cmp t1
        bcc spt_1
        lda t1
spt_1   ldx t2
        pha
        lda sp_np,x
        beq spt_2
        pla                     ; (the second part takes the rest)
        lda t1
        pha
spt_2   ldx t4
        pla
        sec
        sbc t0
        sta t6                  ; rows
        sec
        sbc #1
        sta pk_h1,x
        lda t0
        sta pk_y,x
        lda LOG+2+$1B,y
        sta t5
        lda LOG+2+$16,y
        and #7
        sta t3                  ; fine scroll
        ; source: cache slot*512 + sprite offset + po
        ldy t2
        lda sp_off,y
        clc
        adc po
        sta pk_sl,x
        lda sp_slot,y
        asl
        adc sp_offh,y
        clc
        adc po+1
        sta pk_sh,x
        ; destination: back framebuffer + row*320 + x0
        lda t0
        jsr fb_row
        ldx t4
        ldy t2
        lda rowa
        clc
        adc sp_x0,y
        sta pk_dl,x
        lda rowa+1
        adc sp_x0h,y
        sta pk_dm,x
        lda rowa+2
        adc #0
        sta pk_dh,x
        ; behind: patch = layer at x0 - xs (pixels left of 0 are the gap)
        lda t5
        and bitv,y
        sta pk_bh,x
        beq spt_n
        lda sp_x0,y
        sec
        sbc t3
        sta t5
        lda sp_x0h,y
        sbc #0                  ; (negative: skip -x pixels)
        bpl spt_p
        lda t5
        eor #$FF
        clc
        adc #1                  ; skipped
        cmp sp_w,y
        bcs spt_nb              ; (all of it)
        sta t3
        lda sp_w1,y
        sec
        sbc t3
        sta pk_pw,x
        lda rowa                ; src = layer row start
        sta pk_cl,x
        lda rowa+1
        sta pk_cm,x
        lda pk_dl,x             ; dst + skipped
        clc
        adc t3
        sta pk_pl,x
        lda pk_dm,x
        adc #0
        sta pk_pm,x
        jmp spt_n
spt_nb  lda #0
        sta pk_bh,x
        beq spt_n
spt_p   sta t3                  ; layer x hi
        lda rowa
        clc
        adc t5
        sta pk_cl,x
        lda rowa+1
        adc t3
        sta pk_cm,x
        lda pk_dl,x
        sta pk_pl,x
        lda pk_dm,x
        sta pk_pm,x
        lda sp_w1,y
        sta pk_pw,x
spt_n   lda t6                  ; po += rows * 24, next row
        asl
        clc
        adc t6
        asl
        asl
        asl
        php
        clc
        adc po
        sta po
        lda #0
        adc po+1
        plp
        adc #0
        sta po+1
        lda t6
        clc
        adc t0
        sta t0
        inc t4
        ldx t2
        inc sp_np,x
        lda sp_np,x
        cmp #2
        bcs spt_x
        lda t0
        cmp t1
        bcs spt_x
        jmp spt_l
spt_x   rts
sp_np   .ds 8
sp_w1   .ds 8
pk_sl   .ds 16              ; per part: cache source lo, mid
pk_sh   .ds 16
pk_dl   .ds 16              ; framebuffer destination lo, mid, hi
pk_dm   .ds 16
pk_dh   .ds 16
pk_h1   .ds 16              ; rows - 1
pk_bh   .ds 16              ; behind the foreground
pk_cl   .ds 16              ; patch: layer source lo, mid; destination lo,
pk_cm   .ds 16              ; mid (hi as pk_dh); width - 1
pk_pl   .ds 16
pk_pm   .ds 16
pk_pw   .ds 16
pk_y    .ds 16              ; first row
t6      dta 0

; sprite t2: geometry and cache slot (sp_on = 1 when visible)
sprite_geom
        lda t2                  ; Y (entry 0): the region of row max(Y-50, 0)
        asl
        sta t5                  ; 2n
        tax
        lda LOG+3,x
        sec
        sbc #50
        bcs sg_y1
        lda #0
sg_y1   cmp #200
        bcc sg_y2
        lda #199
sg_y2   jsr region_of
        tya
        ldx t2
        sta sp_e,x
        tax                     ; X = entry offset
        ldy t2
        lda LOG+2+$15,x
        and bitv,y
        bne sg_en
        rts
sg_en   lda LOG+2+$10,x         ; X hi
        and bitv,y
        beq sg_x0
        lda #1
sg_x0   sta t5x
        txa
        clc
        adc t5
        tax                     ; entry + 2n
        lda LOG+3,x             ; Y
        sta t0
        sec                     ; fb_y = Y - 50 (signed, -50..205)
        sbc #50
        sta t1
        lda #0
        sbc #0
        sta t3                  ; hi (0 or $FF)
        lda LOG+2,x             ; fb_x = X - 24
        sec
        sbc #24
        sta t4
        lda t5x
        sbc #0
        sta t5                  ; signed (-24..487)
        bmi sg_xn               ; fb_x < 0
        bne sg_off              ; >= 256
        ; 0 <= fb_x < 256
        lda t4
        sta sp_x0,y
        lda #0
        sta sp_x0h,y
        sta sp_off,y            ; x part of the offset: 0
        lda #24
        sta sp_w,y
        jmp sg_y
sg_off  lda t4                  ; 256..: visible while < 320
        cmp #<320
        jcs sg_none
        sta sp_x0,y
        lda #1
        sta sp_x0h,y
        lda #0
        sta sp_off,y
        lda #<320               ; width = min(24, 320 - fb_x)
        sec
        sbc t4
        cmp #24
        bcc sg_w1
        lda #24
sg_w1   sta sp_w,y
        jmp sg_y
sg_xn   lda t4                  ; -24 < fb_x < 0
        cmp #<-23
        jcc sg_none
        eor #$FF
        clc
        adc #1                  ; -fb_x
        sta sp_off,y
        lda #24
        sec
        sbc sp_off,y
        sta sp_w,y
        lda #0
        sta sp_x0,y
        sta sp_x0h,y
sg_y    ; rows: fb_y in t1/t3
        lda #0
        sta sp_offh,y
        lda t3
        bmi sg_yn
        lda t1
        cmp #200
        jcs sg_none
        sta sp_y0,y
        lda #<200               ; h = min(21, 200 - fb_y)
        sec
        sbc t1
        cmp #21
        bcc sg_h1
        lda #21
sg_h1   sta sp_h,y
        jmp sg_slot
sg_yn   lda t1                  ; fb_y < 0: skip -fb_y rows
        cmp #<-20
        jcc sg_none
        eor #$FF
        clc
        adc #1
        sta t0                  ; rows skipped
        lda #21
        sec
        sbc t0
        sta sp_h,y
        lda #0
        sta sp_y0,y
        lda t0                  ; offset += rows * 24
        asl
        asl
        asl
        sta t1
        asl
        clc
        adc t1                  ; *24 (rows <= 20: fits 9 bits)
        sta t1
        lda #0
        rol
        sta sp_offh,y
        lda sp_off,y
        clc
        adc t1
        sta sp_off,y
        bcc sg_slot
        lda sp_offh,y
        adc #0
        sta sp_offh,y
sg_slot lda #1
        sta sp_on,y
        ; cache: slot = pointer & 127, tag (pointer, kind)
        lda ptrs,y
        and #NSLOT-1
        sta sp_slot,y
        tax
        lda ptrs,y
        sta t0
        ldx sp_e,y
        lda LOG+2+$1C,x
        and bitv,y
        beq sg_k
        lda #1
sg_k    sta t1                  ; kind (1 = multicolour)
        ldx sp_slot,y
        lda tag_p,x
        cmp t0
        bne sg_miss
        lda tag_k,x
        cmp t1
        beq sg_hit
sg_miss lda t0
        sta tag_p,x
        lda t1
        sta tag_k,x
        jsr expand_sprite
sg_hit  rts
sg_none lda #0
        sta sp_on,y
        rts

; pointer t0, kind t1 -> cache slot X (24 x 21 codes $FC|k, 0 = clear)
expand_sprite
        stx t3
        lda #0
        jsr memb
        lda t0                  ; data = $4000 + ptr*64
        sta ZP
        lda #0
        ldx #6
es_a    asl ZP
        rol
        dex
        bne es_a
        ora #$40
        sta ZP+1
        ldy #62
es_c    lda (ZP),y
        sta sbuf,y
        dey
        bpl es_c
        lda t3                  ; slot window: bank 16 + slot/32, (slot&31)*512
        lsr
        lsr
        lsr
        lsr
        lsr
        ora #MEMB_ON|(V_SPR>>14)
        jsr memb
        lda t3
        and #31
        asl
        ora #>WIN
        sta ZP+1
        lda #0
        sta ZP
        ldx #0                  ; source byte
        ldy #0
es_b    lda sbuf,x
        sta ec_b
        lda t1
        beq es_hi
        lda #4                  ; multicolour pairs
        sta ec_n
es_mp   lda #0
        asl ec_b
        rol
        asl ec_b
        rol
        beq es_m0
        ora #$FC
es_m0   sta (ZP),y
        iny
        sta (ZP),y
        iny
        dec ec_n
        bne es_mp
        jmp es_nx
es_hi   lda #8
        sta ec_n
es_hp   asl ec_b
        lda #0
        bcc es_h0
        lda #$FE
es_h0   sta (ZP),y
        iny
        dec ec_n
        bne es_hp
es_nx   cpy #0                  ; (row 10 crosses a page: Y wraps)
        bne es_n1
        inc ZP+1
es_n1   inx
        cpx #63
        bne es_b
        lda #0
        jmp memb
sbuf    .ds 63

        .print 'bank part 1 end: ', *
        icl 'lists.asm'

; set-up: tiles of both charsets, shadows that compare as changed
r_init  lda #0
        sta t0
ri_t    lda #0
        ldx t0
        jsr expand_char
        lda #1
        ldx t0
        jsr expand_char
        inc t0
        bne ri_t
        lda #0
        jsr memb
        ldx #24
ri_r    jsr row_invalid
        lda #0
        sta rowcs,x
        dex
        bpl ri_r
        ldx #0
        txa
ri_c    sta charrows,x
        sta dchar,x
        inx
        bne ri_c
        ldx #NSLOT-1
        lda #$FF
ri_k    sta tag_k,x
        dex
        bpl ri_k
        lda #0
        sta back
        sta sweep
        sta shift_n
        rts
        .print 'bank R end: ', *
        ert * > scr_sh
