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
        ; the playfield's scroll: running total of the game's scroll phase
        ; ($0701, the IRQ writes it to $D016), every frame the chain runs
        lda $0701
        sec
        sbc sc_701
        and #7
        cmp #4
        bcc se_1
        ora #$F8                ; (-4..-1)
se_1    clc
        adc sc_T
        sta sc_T
        lda $0701
        sta sc_701
        lda log_on
        bne se_x
        ldx log_w
        lda log_n
        sta log_cnt,x
        stx log_ri              ; the newest complete log
        lda sc_T                ; (the playfield's scroll for this log)
        sta logT,x
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
; XDL of list X's framebuffer: one entry per palette segment, each with its
; overlay address. The playfield (lines 0 to XW_BAND-1, where the game
; scrolls) is shifted by the scroll the game made since the picture's log
; (sc_T - lstT), so the background moves every frame between pictures.
XW_BAND = 147                   ; C64 raster 198: the HUD below does not scroll
xdl_write
        stx xw_l
        lda seg_n,x
        bne xw_go
        rts                     ; (no picture yet: the XDL of gfx_init)
xw_go   lda #MEMB_ON|(V_XDL>>14)
        jsr vbx_memb_a
        lda #<(WIN+(V_XDL&$3FFF)+3)
        sta xw_d+1
        txa
        clc
        adc #>(WIN+(V_XDL&$3FFF)+3)
        sta xw_d+2
        ; shift: scroll since the picture, -8..8 (the sprites move with it:
        ; more would show them far from where they are)
    .if SMOOTH=0
        lda #0                  ; (gg2 build: the picture as it was composed)
        beq xw_s1
    .endif
        lda sc_T
        sec
        sbc lstT,x
        bmi xw_sn
        cmp #9
        bcc xw_s1
        lda #8
        bne xw_s1
xw_sn   cmp #$F8
        bcs xw_s1
        lda #$F8
xw_s1   sta xw_sh
        ; first line's address
        lda fb_lo,x
        clc
        adc #FBM
        sta xw_a
        lda fb_mid,x
        adc #0
        sta xw_a+1
        lda fb_hi,x
        adc #0
        sta xw_a+2
        lda #0
        sta xw_s                ; line of the entry
        lda #$62                ; (the first entry turns the overlay on)
        sta xw_f
        txa
        beq xw_0
        lda #NR
xw_0    sta xw_k
        lda seg_n,x
        sta xw_n
        ldy #0
xw_seg  ldx xw_k
        lda seg_ln,x
        sta xw_c                ; lines left in this segment
xw_part lda xw_c
        ldx xw_s
        cpx #XW_BAND
        bcs xw_p1               ; below the playfield: the whole rest
        txa
        clc
        adc xw_c
        cmp #XW_BAND+1
        bcc xw_p0
        lda #XW_BAND            ; up to the end of the playfield
        sec
        sbc xw_s
        jmp xw_p1
xw_p0   lda xw_c
xw_p1   sta xw_m                ; lines of this entry
        jsr xw_ent
        lda xw_c
        sec
        sbc xw_m
        sta xw_c
        bne xw_part
        inc xw_k
        dec xw_n
        bne xw_seg
        ; the last entry ends the XDL
        ldy xw_e
        lda #$88
        jsr xw_put
        lda #0
        jmp vbx_memb_a
; an entry for xw_m lines from line xw_s
xw_ent  lda xw_f
        jsr xw_put
        sty xw_e                ; (its second byte)
        lda #$08
        jsr xw_put
        ldx xw_m
        dex
        txa
        jsr xw_put
        ; address (+ the shift in the playfield)
        lda #0
        ldx xw_s
        cpx #XW_BAND
        bcs xw_e1
        lda xw_sh
xw_e1   sta xw_t
        ora #$7F                ; (sign: $FF or $7F)
        bmi xw_e2
        lda #0
        .byte $2C
xw_e2   lda #$FF
        sta xw_t+1
        lda xw_a
        clc
        adc xw_t
        jsr xw_put
        lda xw_a+1
        adc xw_t+1
        jsr xw_put
        lda xw_a+2
        adc xw_t+1
        and #7
        jsr xw_put
        lda #<FBW
        jsr xw_put
        lda #>FBW
        jsr xw_put
        ldx xw_k
        lda seg_pl,x
        asl
        asl
        asl
        asl
        ora #$01                ; 320 pixels, overlay palette
        jsr xw_put
        lda #$FF
        jsr xw_put
        lda #$60                ; next entries: lines and address
        sta xw_f
        ; next line, address + lines * 368 (256 + 64 + 32 + 16)
        lda xw_s
        clc
        adc xw_m
        sta xw_s
        lda xw_m
        sta xw_t
        lda #0
        sta xw_t+1
        ldx #4
xw_m16  asl xw_t
        rol xw_t+1
        dex
        bne xw_m16
        ldx #3
xw_ma   lda xw_a
        clc
        adc xw_t
        sta xw_a
        lda xw_a+1
        adc xw_t+1
        sta xw_a+1
        bcc xw_mb
        inc xw_a+2
xw_mb   asl xw_t
        rol xw_t+1
        dex
        bne xw_ma
        lda xw_a+1
        clc
        adc xw_m
        sta xw_a+1
        bcc xw_mc
        inc xw_a+2
xw_mc   rts
xw_put
xw_d    sta WIN,y
        iny
        rts
xw_l    dta 0
xw_k    dta 0
xw_n    dta 0
xw_c    dta 0
xw_m    dta 0
xw_s    dta 0
xw_f    dta 0
xw_e    dta 0
xw_sh   dta 0
xw_t    dta 0,0
xw_a    dta 0,0,0

; raster_sync: 312 * 256 / avail for avail 8-156
rsk_lo  :149 dta <(79872/(#+8))
rsk_hi  :149 dta >(79872/(#+8))

; the game needs the renderer's zero page (loader, KERNAL calls): forget a
; suspended step and redraw everything
co_abort
        pha
        lda co_state
        beq ca_x
        lda #0
        sta co_state
        sta in_idle
        lda #$FF
        sta bl
        sta log_busy
        lda sq_on               ; a scroll waiting for the step: everything is
        beq coa_1               ; redrawn anyway
        lda #0
        sta sq_on
        lda sq_x
        sta map_lo
        lda sq_y
        sta map_hi
coa_1
        txa
        pha
        tya
        pha
        jsr t_render_loaded     ; (bank IDLE)
        pla
        tay
        pla
        tax
ca_x    pla
        rts

; the game's playfield draw ($3855) moved the map by a column: the char layer
; rows 0-18 turn their rings (called from code A: hook_scroll, co_run)
scroll_notify
        txa
        sec
        sbc map_lo
        sta sn_d
        tya
        sbc map_hi
        sta sn_d+1
        stx map_lo
        sty map_hi
        lda sn_d+1
        bne sn_neg
        lda sn_d
        cmp #1
        bne sn_x
        ; one column left
        lda #2
        sta reg_dirty
        ldx #18
sn_l    lda row_off,x
        clc
        adc #1
        cmp #40
        bcc sn_l1
        lda #0
sn_l1   sta row_off,x
        lda #1
        sta row_edge,x
        sta edge_any
        dex
        bpl sn_l
        rts
sn_neg  cmp #$FF
        bne sn_x
        lda sn_d
        cmp #$FF
        bne sn_x
        lda #2
        sta reg_dirty
        ldx #18
snr_l    lda row_off,x
        sec
        sbc #1
        bcs snr_1
        lda #39
snr_1   sta row_off,x
        lda #2
        sta row_edge,x
        sta edge_any
        dex
        bpl snr_l
        rts
sn_x    ldx #18
        lda #1
snp_l    sta row_prio,x
        sta fp_any
        dex
        bpl snp_l
        rts
sn_d    dta 0,0

