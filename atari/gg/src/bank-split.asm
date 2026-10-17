; bank SPLIT: IRQ chain recording (NMI)
; ------------------------------------------------------------------
; IRQ chain recording (NMI)
; ------------------------------------------------------------------
; The NMI records the IRQ chain as a log: one 64-byte record per handler
; (and one for line 0, the state left by the last frame): raster line,
; VIC registers $00-$2E, $DD00 and the 8 sprite pointers. The main context
; turns the newest complete log into regions and sprite instances
; (compose_main). Two logs alternate; one the main context is reading is
; not overwritten (that frame is not recorded).
LOGREC  = 64
LOGMAX  = 31

split_begin
        lda log_w
        cmp log_busy
        bne sb_ok
        lda #$FF                ; the main context reads this log: skip
        sta log_on
        rts
sb_ok   lda #0
        sta log_on
        sta log_n
        sta cur_lo
        sta cur_hi
        jmp log_rec

split_take
        lda log_on
        bne st_x
        lda log_n
        cmp #LOGMAX
        bcs st_x
        jmp log_rec
st_x    rts

split_end
        lda log_on
        bne se_x
        ldx log_w
        lda log_n
        sta log_cnt,x
        stx log_ri              ; the newest complete log
        lda #1
        sta log_new
        txa
        eor #1
        sta log_w
se_x    rts

; one record at log_w, index log_n
log_rec ; sprite pointers at screen + $3F8 (read first: under the window maybe)
        lda CIA2
        and #3
        eor #3
        asl
        asl
        asl
        asl
        asl
        asl
        sta lr_t
        lda VIC+$18
        lsr
        lsr
        and #$3C
        ora lr_t
        clc
        adc #3
        sta lr_p+2
        ldy #7
lr_p    lda $FFF8,y
        sta lr_ptr,y
        dey
        bpl lr_p
        ; window address: V_LOG + log_w*2048 + log_n*64
        lda log_n
        lsr
        lsr
        sta lr_t
        lda log_n
        ror
        ror
        ror
        and #$C0                ; record offset in the page (0, 64, 128, 192)
        sta lr_a0+1
        ora #1
        sta lr_a1+1
        and #$C0
        ora #2
        sta lr_av+1
        and #$C0
        ora #49
        sta lr_ad+1
        and #$C0
        ora #50
        sta lr_ap+1
        lda log_w
        asl
        asl
        asl
        ora lr_t
        clc
        adc #>(WIN+(V_LOG&$3FFF))
        sta lr_a0+2
        sta lr_a1+2
        sta lr_av+2
        sta lr_ad+2
        sta lr_ap+2
        lda #MEMB_ON|(V_LOG>>14)
        sta memb_sh
        jsr vbx_memb
        lda cur_lo
lr_a0   sta WIN
        lda cur_hi
lr_a1   sta WIN+1
        ldy #$2E
lr_v    lda VIC,y
lr_av   sta WIN+2,y
        dey
        bpl lr_v
        lda CIA2
lr_ad   sta WIN+49
        ldy #7
lr_q    lda lr_ptr,y
lr_ap   sta WIN+50,y
        dey
        bpl lr_q
        inc log_n
        lda #0
        jmp vbx_memb_a
lr_ptr  .ds 8
lr_t    dta 0


; per char row: the screen line, charset and mode of the region its first
; raster line falls in (only when the regions differ from the last time)
rows_state
        lda nregion
        cmp rws_n
        bne rws_go
        ldx nregion
        dex
rws_c   lda rg_l0,x
        cmp rws_l0,x
        bne rws_go
        lda rg_d011,x
        cmp rws_11,x
        bne rws_go
        lda rg_d016,x
        cmp rws_16,x
        bne rws_go
        lda rg_d018,x
        cmp rws_18,x
        bne rws_go
        lda rg_dd00,x
        cmp rws_dd,x
        bne rws_go
        lda rg_d020,x
        cmp rws_20,x
        bne rws_go
        lda rg_d021,x
        cmp rws_21,x
        bne rws_go
        dex
        bpl rws_c
        rts
rws_go  ldx nregion
        stx rws_n
        dex
rws_s   lda rg_l0,x
        sta rws_l0,x
        lda rg_d011,x
        sta rws_11,x
        lda rg_d016,x
        sta rws_16,x
        lda rg_d018,x
        sta rws_18,x
        lda rg_dd00,x
        sta rws_dd,x
        lda rg_d020,x
        sta rws_20,x
        lda rg_d021,x
        sta rws_21,x
        dex
        bpl rws_s
        lda #2
        sta reg_dirty
        ldy #0                  ; region index
        ldx #0                  ; row
rws_l   ; first FB line of row x in region y: 8x + (d011&7) - 3
        lda rg_d011,y
        and #7
        sta nt
        txa
        asl
        asl
        asl
        clc
        adc nt                  ; 8x + ys (0..199)
        sec
        sbc #3
        bcs rws_1
        lda #0                  ; above the display: line 0
rws_1   sta nt+1
        ; advance the region while the next one starts at or before the line
rws_r   iny
        cpy nregion
        bcs rws_rb
        lda rg_l0,y
        cmp nt+1
        beq rws_r
        bcc rws_r
rws_rb  dey
        ; mode
        lda rg_d011,y
        and #$10
        beq rws_blank
        lda rg_d011,y
        and #$60
        cmp #$40
        beq rws_ecm
        cmp #0
        bne rws_blank           ; bitmap or invalid
        lda rg_d016,y
        and #$10
        beq rws_hi
        lda #MD_MC
        bne rws_m
rws_ecm lda #MD_ECM
        bne rws_m
rws_hi  lda #MD_HI
        beq rws_m
rws_blank
        lda #MD_BLANK
rws_m   sta row_md,x
        ; screen line: base + row*40
        lda rg_dd00,y
        and #3
        eor #3
        asl
        asl
        asl
        asl
        asl
        asl
        sta nt+2                ; bank high byte
        lda rg_d018,y
        lsr
        lsr
        and #$3C
        ora nt+2
        clc
        adc row40_hi,x
        sta row_scr_hi,x
        lda row40_lo,x
        sta row_scr_lo,x
        ; charset: bank + ((d018 >> 1) & 7) * $800
        lda rg_d018,y
        and #$0E
        asl
        asl
        ora nt+2
        sta row_cs,x
        inx
        cpx #25
        jcc rws_l
        rts
rws_n   dta $FF
rws_l0  .ds NR
rws_11  .ds NR
rws_16  .ds NR
rws_18  .ds NR
rws_dd  .ds NR
rws_20  .ds NR
rws_21  .ds NR

; NMI: the XDL of framebuffer X from its picture's palette segments (the
; framebuffer is not on screen yet; the XDL is read when the display starts)
xdl_write
        stx xw_l
        txa
        lsr
        ror
        and #$80                ; X * $80
        clc
        adc #<(WIN+(V_XDL&$3FFF)+3)
        sta xw_d+1
        lda #>(WIN+(V_XDL&$3FFF)+3)
        adc #0
        sta xw_d+2
        lda #MEMB_ON|(V_XDL>>14)
        jsr vbx_memb_a
        lda xw_l
        beq xw_0
        lda #NR
xw_0    sta xw_k                ; segment index in the tables
        ldx xw_l
        lda seg_n,x
        sta xw_n
        ldy #0
        ; first segment: overlay on, address and step of the framebuffer
        lda #$62
        jsr xw_put
        jsr xw_end
        jsr xw_put
        jsr xw_rpt
        ldx xw_l
        lda fb_lo,x
        clc
        adc #FBM
        jsr xw_put
        lda fb_mid,x
        adc #0
        jsr xw_put
        lda fb_hi,x
        adc #0
        jsr xw_put
        lda #<FBW
        jsr xw_put
        lda #>FBW
        jsr xw_put
        jsr xw_att
xw_l2   dec xw_n
        beq xw_x
        inc xw_k
        lda #$20                ; next segments: lines and palette only
        jsr xw_put
        jsr xw_end
        jsr xw_put
        jsr xw_rpt
        jsr xw_att
        jmp xw_l2
xw_x    rts
; A = $08 (attributes follow), $88 on the last segment
xw_end  lda xw_n
        cmp #1
        beq xw_e1
        lda #$08
        rts
xw_e1   lda #$88
        rts
xw_rpt  ldx xw_k
        lda seg_ln,x
        sec
        sbc #1
        jmp xw_put
xw_att  ldx xw_k
        lda seg_pl,x
        asl
        asl
        asl
        asl
        ora #$01                ; 320 pixels, overlay palette
        jsr xw_put
        lda #$FF
xw_put
xw_d    sta WIN,y
        iny
        rts
xw_l    dta 0
xw_k    dta 0
xw_n    dta 0
