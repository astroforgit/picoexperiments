; ------------------------------------------------------------------
; Vertical blank: show the finished frame, compose the next one with
; the blitter, read the controls, then run the game's NMI handler.
; ------------------------------------------------------------------

; ---- used inside the VBI (below $4000: MEMAC-B may cover $4000-$7FFF)
phys_page dta >NT_A,>NT_B
phys_row32 dta 0,32
phys_row128 dta 0,128
bitmask dta 1,2,4,8,16,32,64,128

; A = PRG bank for $8000-$BFFF
prg_bank
        and #7
        asl
        asl
        ora #$80
        sta mems_sh
pb_mems sta VBX+VB_MEMS
        rts

nmi     pha
        txa
        pha
        tya
        pha
        bit NMIST
        bmi nm_dli_tick
        jsr frame_schedule
        jmp nm_check
nm_dli_tick
        lda ticks_owed
        cmp #2
        bcs nm_check
        inc ticks_owed
nm_check
        lda in_vbi
        beq nm_enter
        ; A long NES update must not hold a finished picture off-screen.
        ; flip touches no borrowed ZP/window state, and pending guarantees
        ; that the compositor has finished its descriptors and palette.
        bit NMIST
        bmi nm_nested_done
        lda pending
        beq nm_nested_done
nm_nested_busy lda VBX+VB_BLIT
        bne nm_nested_done
        jsr flip_due
        bcc nm_nested_done
        jsr flip
nm_nested_done
        lda #0
        sta NMIRES
        jmp nc_skip
nm_enter
        lda NMIST
        and #$80
        sta nmi_kind
        sta NMIRES
        inc in_vbi
        cld
        lda mems_sh
        sta render_mems
        lda memb_sh
        sta render_memb
        lda render_active
        beq nm_windows
        ldx #7
nm_save lda ZP,x
        sta zp_save,x
        lda game_zp,x
        sta ZP,x
        dex
        bpl nm_save
nm_windows
        lda #0
        sta memb_sh
mb_4    sta VBX+VB_MEMB
        lda ACTIVE_NES_BANK
        jsr prg_bank
        jsr read_input
        lda nmi_kind
        bne nm_game
vw_busy lda VBX+VB_BLIT
        bne nm_game
        lda pending
        beq nm_game
        jsr flip_due
        bcc nm_game
        jsr flip
nm_game
        ; Finish a newly loaded stage before allowing its first gameplay tick.
        ; This gives the compositor the CPU while the player is still safe.
        lda $18
        cmp #5
        bne nm_loading_reset
        lda $2C
        cmp #4
        bne nm_loading_reset
        lda scene_ready
        bne nm_tick
        lda any_dirty
        ora chr_dirty
        ora render_active
        beq nm_loading_done
        lda #0
        sta ticks_owed
        jmp nm_done
nm_loading_done
        lda #1
        sta scene_ready
        bne nm_tick
nm_loading_reset
        lda #0
        sta scene_ready
nm_tick lda ticks_owed
        beq nm_done
        dec ticks_owed
        lda nmi_on
        bpl nm_done
        lda #>nm_game_done
        pha
        lda #<nm_game_done
        pha
        php
        jmp NES_NMI
nm_game_done
        jsr convert_audio
nm_done lda render_active
        beq nm_winrestore
        ldx #7
nm_restore
        lda ZP,x
        sta game_zp,x
        lda zp_save,x
        sta ZP,x
        dex
        bpl nm_restore
nm_winrestore
        lda render_mems
        sta mems_sh
nm_ms sta VBX+VB_MEMS
        lda render_memb
        sta memb_sh
nm_mb   sta VBX+VB_MEMB
        dec in_vbi
nc_skip pla
        tay
        pla
        tax
        pla
        rti

; Compositor runs in the NES idle loop and yields to game NMIs.
; Game and compositor each retain their own eight scratch ZP bytes.
render_idle
        php
        pha
        lda pending
        bne rd_tiles
        ; Nothing to do before the next picture is due: return at once. The
        ; NMIEN switches below would otherwise run in a tight loop, and an
        ; interrupt arriving while NMIEN is 0 is lost.
        jsr sample_due
        bcs rd_begin
        lda any_dirty
        ora chr_dirty
        bne rd_begin
rd_quick
        pla
        plp
        rts
        ; A finished picture waits for its vertical blank: its blits are
        ; done, so new tiles can already go into the nametable bitmaps.
rd_tiles
        lda any_dirty
        ora chr_dirty
        beq rd_quick
rd_begin
        txa
        pha
        tya
        pha
        lda #0
        sta NMIEN
        ldx #7
rd_save lda ZP,x
        sta game_zp,x
        dex
        bpl rd_save
        lda #1
        sta render_active
        lda #$C0
        sta NMIEN
        cli
rd_busy lda VBX+VB_BLIT
        bne rd_done
        jsr pattern_select
        lda chr_dirty
        beq rd_sprites
        lda #0
        sta chr_dirty
        jsr mark_chr_dirty
rd_sprites
        lda #0
        sta spr_dirty
rd_clean
        jsr compose
rd_done lda #0
        sta NMIEN
        sta render_active
        sta memb_sh
rd_mb   sta VBX+VB_MEMB
        lda ACTIVE_NES_BANK
        jsr prg_bank
        ldx #7
rd_restore
        lda game_zp,x
        sta ZP,x
        dex
        bpl rd_restore
        lda #$C0
        sta NMIEN
        pla
        tay
        pla
        tax
        pla
        plp
        rts

; ---- pacing: a picture is sampled every `pace` game ticks and shown
; `pace` ticks after its sample, so every picture covers the same game time
; and stays on screen for the same time. When the game is not ticking
; (loads, NMI off), a picture is still taken every PACE_WAIT video frames.
PACE_WAIT = 6
; C=1 when the pending picture may be shown in this vertical blank: this
; blank's game tick will complete its `pace` ticks
flip_due
        lda $1A
        sec
        sbc snapshot_tick
        clc
        adc #1
        cmp pace
        bcs fd_rts
fd_frames
        lda vframe
        sec
        sbc snap_vframe
        cmp #PACE_WAIT
fd_rts  rts
; C=1 when the next picture may be sampled
sample_due
        lda $1A
        sec
        sbc snapshot_tick
        cmp pace
        bcc fd_frames
        rts

; ---- show the composed frame
flip    lda #0
        sta pending
        ldx back
        lda xdl_lo,x
vf_x0   sta VBX+VB_XDL0
        lda #>(V_XDL & $FFFF)
vf_x1   sta VBX+VB_XDL0+1
        lda #V_XDL >> 16
vf_x2   sta VBX+VB_XDL0+2
        lda snap_dirty
        beq fl_1
        jsr load_palette
fl_1    lda snap_hpos
        sta HPOSP0
        lda back
        eor #1
        sta back
        rts
xdl_lo  dta <V_XDL, <(V_XDL+$40)

; overlay palette 1: $10+k shows NES palette entry k^16 (sprites, then background)
load_palette
        lda #0
        sta snap_dirty
        lda #1
lp_ps   sta VBX+VB_PSEL
        lda #$10
lp_cs   sta VBX+VB_CSEL
        ldx #0
lp_1    txa
        eor #$10
        tay
        lda PALSNAP,y
        tay
        lda nes_r,y
lp_r    sta VBX+VB_CR
        lda nes_g,y
lp_g    sta VBX+VB_CG
        lda nes_b,y
lp_b    sta VBX+VB_CB
        inx
        cpx #32
        bne lp_1
        ; the left-column mask (player 0, PF palette 0 colour 2) shows the backdrop
        lda #0
lp_ps2  sta VBX+VB_PSEL
        lda #2
lp_cs2  sta VBX+VB_CSEL
        ldy PALSNAP
        lda nes_r,y
lp_r2   sta VBX+VB_CR
        lda nes_g,y
lp_g2   sta VBX+VB_CG
        lda nes_b,y
lp_b2   sta VBX+VB_CB
        rts

; ------------------------------------------------------------------
; compose the frame the NES displayed last: dirty tiles into the
; nametable bitmaps, the scrolled background (and HUD), the sprites.
; ------------------------------------------------------------------
compose
        ; A vertical blank can show the pending picture (and switch `back`)
        ; while this compose does tile work for it: keep this compose's list.
        lda back
        sta c_back
        lda pending
        sta c_pend
        ldx #EXP_BUDGET
        lda PPU_MASK_STATE
        and #$18
        bne co_1
        ldx #EXP_BUDGET_DARK    ; nothing visible: catch up on tiles
co_1    stx budget
        ldx c_back
        lda list_memb,x
        sta c_memb
        sta memb_sh
mb_1    sta VBX+VB_MEMB
        lda #MAXT
        sta tslot
        lda any_dirty
        beq co_2
        lda #EXP_BUDGET_DARK    ; tiles waiting: catch up quickly
        sta budget
        jsr emit_tiles
        lda any_dirty
        beq co_2
        lda scene_ready
        bne co_2
        jmp catch_up            ; still behind: keep the old picture
co_2    lda c_pend
        bne co_cu               ; a picture waits: tile work only
        jsr sample_due
        bcs co_2a
co_cu   jmp catch_up            ; too early: tile work only
co_2a   ldx back
        lda cu_end,x
        beq co_2b
        lda #0
        sta cu_end,x
        ldx #MAXT-1
        lda slot_lo,x
        sta ZP
        lda slot_hi,x
        sta ZP+1
        ldy #20
        lda #8
        sta (ZP),y              ; the tiles continue into the background slots
co_2b   lda snapshot_tick
        sta snap_prev
        lda snap_vframe
        sta snap_vprev
        jsr snapshot_frame
        jsr emit_bg
        ; The tiles and the background (the list ends at the last background
        ; slot) are blitted while the CPU writes the sprite slots.
        ldx tslot
        jsr start_list
        jsr emit_sprites
        lda es_missing
        beq co_ready
        ; never display a frame with missing sprite tiles: keep the old
        ; picture, and sample again as soon as the tiles are expanded
        lda snap_prev
        sta snapshot_tick
        lda snap_vprev
        sta snap_vframe
        jmp wait_blit
co_ready
        jsr wait_blit
        ldx #SPR0
        jsr start_list
        ; palette and left column of this frame
        lda pal_dirty
        beq co_3
        lda #0
        sta pal_dirty
        ldx #31
co_p    lda PALSH,x
        sta PALSNAP,x
        dex
        bpl co_p
        lda #1
        sta snap_dirty
co_3    ldx #0
        lda c_mask
        and #2
        bne co_4
        ldx #64                 ; NES left 8 pixels hidden
co_4    stx snap_hpos
        lda #1
        sta pending
        rts

; start the blitter at slot X of the back list
start_list
        lda slot_lo,x
        clc
        adc #<(V_LIST0 - LISTCPU)
co_bl0  sta VBX+VB_BLAD
        lda slot_hi,x
        adc #>(V_LIST0 - LISTCPU)
co_bl1  sta VBX+VB_BLAD+1
        ldx back
        lda list_hi,x
co_bl2  sta VBX+VB_BLAD+2
        lda #1
co_bs   sta VBX+VB_BLIT
        rts
wait_blit
wb_busy lda VBX+VB_BLIT
        bne wait_blit
        rts

snapshot_frame
        ; Retry if a game NMI changes OAM/scroll during the copy. Keep NMIs
        ; enabled: masking them for the whole copy loses timing events.
        lda $1A                 ; original FRAME_COUNTER
        sta snapshot_tick
        ldx #31
co_oam  lda $0200,x
        sta $0800,x
        lda $0220,x
        sta $0820,x
        lda $0240,x
        sta $0840,x
        lda $0260,x
        sta $0860,x
        lda $0280,x
        sta $0880,x
        lda $02A0,x
        sta $08A0,x
        lda $02C0,x
        sta $08C0,x
        lda $02E0,x
        sta $08E0,x
        dex
        bpl co_oam
        lda hud_nt
        sta c_hudnt
        lda PPU_MASK_STATE
        sta c_mask
        lda lat_x
        sta c_x
        lda lat_y
        sta c_y
        lda lat_ctrl
        sta c_ctrl
        lda $1A
        cmp snapshot_tick
        bne snapshot_frame
        lda vframe
        sta snap_vframe
        lda hud_on               ; HUD split this frame? A frame in which the
        beq co_nh               ; game's handler did not run (lag) keeps the
        lda #0                  ; last split; 8 frames without one end it
        sta hud_on
        sta hud_age
        lda #1
        bne co_h
co_nh   lda hud_age
        cmp #8
        bcs co_h0
        inc hud_age
        lda c_hud
        jmp co_h
co_h0   lda #0
co_h    sta c_hud
        rts

list_memb dta MEMB_LIST0, MEMB_LIST1
list_hi dta V_LIST0 >> 16, V_LIST1 >> 16
EXP_BUDGET = 4
EXP_BUDGET_DARK = 12

; more tiles changed than one frame can draw (a new screen): blit only the
; tiles, ending the list at the last tile slot, and do not flip
catch_up
        ldx tslot
        cpx #MAXT
        beq cu_none
        ldx #MAXT-1
        lda slot_lo,x
        sta ZP
        lda slot_hi,x
        sta ZP+1
        ldy #20
        lda #0
        sta (ZP),y              ; end of the list
        ldx c_back
        lda #1
        sta cu_end,x            ; restored by this list's next full compose
        ldx tslot
        lda slot_lo,x
        clc
        adc #<(V_LIST0 - LISTCPU)
cu_bl0  sta VBX+VB_BLAD
        lda slot_hi,x
        adc #>(V_LIST0 - LISTCPU)
cu_bl1  sta VBX+VB_BLAD+1
        ldx c_back
        lda list_hi,x
cu_bl2  sta VBX+VB_BLAD+2
        lda #1
cu_bs   sta VBX+VB_BLIT
cu_none rts

; ---- dirty tiles, written into tile slots MAXT-1 downwards
emit_tiles
        lda #0
        sta et_p
        sta et_bcol
et_np   ldx et_p
        lda phys_row32,x
        sta et_ri
        lda phys_row128,x
        sta et_di
        lda #0
        sta et_r
et_row  ldx et_ri
        lda ROWDIRTY,x
        beq et_nextrow
        lda #0
        sta et_b
et_byte lda et_di
        clc
        adc et_b
        tax
        lda DIRTY,x
        beq et_nextbyte
        sta et_v
        ldy #0
et_bit  lsr et_v
        bcc et_nb
        ; tile at column et_b*8+y
        sty et_k
        tya
        ora et_bcol
        sta et_c
        lda tslot
        beq et_full
        jsr emit_tile
        bcs et_full2            ; expansion budget exhausted
        lda et_di
        clc
        adc et_b
        tax
        ldy et_k
        lda DIRTY,x
        and notmask,y
        sta DIRTY,x
        ldy et_k
et_nb   iny
        lda et_v
        bne et_bit
et_nextbyte
        lda et_b
        clc
        adc #1
        sta et_b
        asl
        asl
        asl
        sta et_bcol
        lda et_b
        cmp #4
        bne et_byte
        lda #0
        sta et_bcol
        ldx et_ri
        sta ROWDIRTY,x
et_nextrow
        lda #0
        sta et_bcol
        lda et_di
        clc
        adc #4
        sta et_di
        inc et_ri
        inc et_r
        lda et_r
        cmp #30
        beq et_pdone
        jmp et_row
et_pdone
        inc et_p
        lda et_p
        cmp #2
        beq et_alldone
        jmp et_np
et_alldone
        lda #0
        sta any_dirty
        rts
et_full2
et_full lda #0
        sta et_bcol
        rts                     ; any_dirty stays set: continue next frame
notmask dta $FE,$FD,$FB,$F7,$EF,$DF,$BF,$7F
; per nametable row: low byte of the cell row, page offset, attribute row
et_row_lo
        dta $00,$20,$40,$60,$80,$A0,$C0,$E0,$00,$20,$40,$60,$80,$A0,$C0
        dta $E0,$00,$20,$40,$60,$80,$A0,$C0,$E0,$00,$20,$40,$60,$80,$A0
et_row_hi
        dta $00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01
        dta $01,$02,$02,$02,$02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$03
et_row_at
        dta $C0,$C0,$C0,$C0,$C8,$C8,$C8,$C8,$D0,$D0,$D0,$D0,$D8,$D8,$D8
        dta $D8,$E0,$E0,$E0,$E0,$E8,$E8,$E8,$E8,$F0,$F0,$F0,$F0,$F8,$F8

; emit a tile BCB for physical nametable et_p, row et_r, column et_c.
; C=1 if the tile could not be expanded this frame.
emit_tile
        ; shadow cell and attribute addresses from per-row tables
        ldx et_r
        ldy et_p
        lda et_row_hi,x
        clc
        adc phys_page,y
        sta ZP+1                ; page = base + row/8
        lda phys_page,y
        adc #3                  ; C = 0: page + row/8 < 256
        sta ZP+3
        lda et_row_lo,x
        ora et_c
        sta ZP
        lda et_c
        lsr
        lsr
        ora et_row_at,x
        sta ZP+2                ; $3C0 + (row/4)*8 + col/4
        ldy #0
        lda (ZP),y
        sta et_tile
        lda (ZP+2),y
        ; palette bits of this 16x16 quadrant, as (pal << 2) | 3
        sta et_attr
        lda et_r
        and #2
        beq et_qt
        lda et_attr
        lsr
        lsr
        lsr
        lsr
        sta et_attr
et_qt   lda et_c
        and #2
        bne et_qr
        lda et_attr
        asl
        asl
        jmp et_qp
et_qr   lda et_attr
et_qp   and #$0C
        ora #3
        sta et_and
        ; make sure the tile is expanded
        ldx et_tile
        jsr bg_ready
        bcs et_rts
        ; BCB for the next slot downwards
        dec tslot
        ldx tslot
        lda slot_lo,x
        sta ZP
        lda slot_hi,x
        sta ZP+1
        ldy #0
        lda et_tile
        and #3
        lsr
        ror
        ror
        sta (ZP),y              ; src lo = (tile&3)<<6
        iny
        lda et_tile
        lsr
        lsr
        ora #>(V_SLOT_BG & $FFFF)
        sta (ZP),y
        iny
        lda #V_SLOT_BG >> 16
        sta (ZP),y
        ldy #6
        lda et_c
        asl
        asl
        asl
        sta (ZP),y              ; dst lo = col*8
        iny
        lda et_r
        asl
        asl
        asl
        sta (ZP),y              ; dst mid = row*8
        iny
        lda et_p
        clc
        adc #V_NT_A >> 16
        sta (ZP),y
        ldy #15
        lda et_and
        sta (ZP),y
        clc
et_rts  rts

; ---- X = background tile: C=0 when expanded (expanding it if allowed)
bg_ready
        lda EXPF_BG,x
        bne br_ok
        lda budget
        beq br_no
        dec budget
        lda #1
        sta EXPF_BG,x
        lda bg_bank
        ldy #MEMB_SBG
        jsr expand
        lda c_memb
        sta memb_sh
mb_2    sta VBX+VB_MEMB
br_ok   clc
        rts
br_no   sec
        rts

; ---- Y = sprite tile not yet expanded: expand it if allowed (C=1: not now).
; X and the BCB pointer are kept.
obj_expand
        lda budget
        beq br_no
        dec budget
        lda #1
        sta EXPF_OBJ,y
        stx oe_x
        lda ZP
        pha
        lda ZP+1
        pha
        tya
        tax
        lda obj_bank
        ldy #MEMB_SOBJ
        jsr expand
        lda c_memb
        sta memb_sh
mb_3    sta VBX+VB_MEMB
        pla
        sta ZP+1
        pla
        sta ZP
        ldx oe_x
        clc
        rts

; ---- background and HUD rectangles (slots BG0..BG0+5)
emit_bg lda #0
        sta eb_n
        ; split line
        lda #240
        sta eb_s
        lda c_hud
        beq eb_1
        lda $0800               ; snapshotted sprite 0 marks the split
        clc
        adc #5
        cmp #240
        bcs eb_1
        sta eb_s
eb_1    lda c_mask
        and #8
        bne eb_2
        ; background off: backdrop fill
        jsr eb_fill
        jmp eb_pad
eb_2    ; X0 = c_x + 256*(ctrl&1); split column xs = 256 - c_x
        lda c_ctrl
        and #3
        sta eb_nt
        lda c_y
        cmp #240
        bcc eb_3
        lda #0                  ; out-of-range Y: treat as 0
        sta c_y
eb_3    lda #240
        sec
        sbc c_y
        sta eb_ys               ; first row coming from the next nametable down
        ; upper strip: lines 0 .. min(ys, s)-1
        lda #0
        sta eb_y
        lda eb_ys
        cmp eb_s
        bcc eb_4
        lda eb_s
eb_4    sta eb_h
        lda c_y
        sta eb_sy
        lda eb_nt
        sta eb_cur
        jsr eb_strip
        ; lower strip: lines ys .. s-1
        lda eb_ys
        cmp eb_s
        bcs eb_hud
        sta eb_y
        lda eb_s
        sec
        sbc eb_ys
        sta eb_h
        lda #0
        sta eb_sy
        lda eb_nt
        eor #2
        sta eb_cur
        jsr eb_strip
eb_hud  lda eb_s
        cmp #240
        bcs eb_pad
        ; HUD: logical nametable c_hudnt, source rows from 200, no scroll
        sta eb_y
        lda #0
        sta eb_sx
        sta eb_dx
        sta eb_w                ; width 256
        lda c_hudnt
        sta eb_cur
        lda #200
        sta eb_sy
        lda #240
        sec
        sbc eb_s                ; HUD lines
        cmp #41
        bcc eb_h1
        ; more than 40 lines: rows 200..239, then the next nametable down
        pha
        lda #40
        sta eb_h
        jsr eb_rect
        lda eb_y
        clc
        adc #40
        sta eb_y
        lda #0
        sta eb_sy
        lda eb_cur
        eor #2
        sta eb_cur
        pla
        sec
        sbc #40
eb_h1   sta eb_h
        jsr eb_rect
eb_pad  lda eb_n
        cmp #NBG
        bcs eb_rts
        jsr eb_noop
        jmp eb_pad
eb_rts  rts

; one horizontal strip of the playfield: eb_y, eb_h, source row eb_sy,
; logical nametable eb_cur; splits at the horizontal wrap
eb_strip
        lda eb_h
        beq eb_rts
        lda c_x
        sta eb_sx
        lda #0
        sta eb_dx
        lda c_x
        beq es_full
        lda #0
        sec
        sbc c_x
        sta eb_w                ; 256 - x
        jsr eb_rect
        lda eb_w
        sta eb_dx
        lda c_x
        sta eb_w                ; remaining width = x
        lda #0
        sta eb_sx
        lda eb_cur
        eor #1
        sta eb_cur
        jsr eb_rect
        lda eb_cur
        eor #1
        sta eb_cur
        rts
es_full lda #0
        sta eb_w
        jmp eb_rect

; write a copy BCB: source logical nametable eb_cur at (eb_sx, eb_sy),
; destination (eb_dx, eb_y), width eb_w (0 = 256), height eb_h. The other
; fields of the background slots are fixed (init_list).
eb_rect jsr eb_ptr
        ldy #0
        lda eb_sx
        sta (ZP),y
        iny
        lda eb_sy
        sta (ZP),y
        iny
        lda eb_cur
        asl
        asl
        tax
        lda nt_physof+$20,x
        clc
        adc #V_NT_A >> 16
        sta (ZP),y
        ldy #6
        lda eb_dx
        sta (ZP),y
        iny
        lda eb_y
        sta (ZP),y
        iny
        lda back
        clc
        adc #V_FB0 >> 16
        sta (ZP),y
        ldy #12
        lda eb_w
        sec
        sbc #1
        sta (ZP),y              ; width-1 (0 -> 255)
        ldy #14
        lda eb_h
        sec
        sbc #1
        sta (ZP),y
        iny
        lda #$FF
        sta (ZP),y              ; AND
        iny
        lda #0
        sta (ZP),y              ; XOR
        inc eb_n
        rts

; backdrop fill of the whole frame / an empty 1x1 copy to the scratch pixel
eb_fill ldx #0
        beq eb_tpl
eb_noop ldx #eb_t_noop-eb_t_fill
eb_tpl  jsr eb_ptr
        ldy #0
eb_t1   lda eb_t_fill,x
        sta (ZP),y
        inx
        iny
        cpy #3
        bne eb_t1
        ldy #6
eb_t2   lda eb_t_fill,x
        sta (ZP),y
        inx
        iny
        cpy #9
        bne eb_t2
        ldy #12
        lda eb_t_fill,x
        sta (ZP),y
        inx
        ldy #14
eb_t3   lda eb_t_fill,x
        sta (ZP),y
        inx
        iny
        cpy #17
        bne eb_t3
        cpx #eb_t_noop-eb_t_fill+1  ; the fill goes to the back buffer
        bcs eb_t4
        lda back
        clc
        adc #V_FB0 >> 16
        ldy #8
        sta (ZP),y
eb_t4   inc eb_n
        rts
; src(3) dst(3) w-1 h-1 and xor
eb_t_fill dta 0,0,0, 0,0,0, 255, 239, 0,$20
eb_t_noop dta <V_SCRATCH,>(V_SCRATCH&$FFFF),V_SCRATCH>>16
        dta <V_SCRATCH,>(V_SCRATCH&$FFFF),V_SCRATCH>>16, 0, 0, $FF,0

eb_ptr  lda eb_n                 ; X kept
        clc
        adc #BG0
        tay
        lda slot_lo,y
        sta ZP
        lda slot_hi,y
        sta ZP+1
        rts

; ---- sprites: slot j draws OAM entry 63-j (sprite 0 ends on top). Each
; list caches what its slots draw (SC_*: y, tile, attribute, x; attribute
; bit 5 = hidden) and only the changed BCB fields are written. A hidden
; slot has AND mask 0: in blitter mode 1 it writes nothing.
emit_sprites
        lda #0
        sta es_missing
        ldy #0
        ldx back
        beq es_0
        ldy #64
es_0    lda slot_lo+SPR0
        sta ZP
        lda slot_hi+SPR0
        sta ZP+1
        lda c_mask
        and #$10
        bne es_go
        ; sprites off: hide every slot
        ldx #64
es_off  jsr es_hide1
        jsr es_inc
        iny
        dex
        bne es_off
        rts
es_go   ldx #252                ; OAM offset of entry 63; Y = cache index
es_loop lda $0800,x
        cmp #$EF
        bcc es_vis              ; on screen
es_hide lda SC_A,y
        and #$20
        bne es_hn
        jsr es_hide1
es_hn   jmp es_next
es_vis  lda $0801,x
        sta es_t
        stx oe_x
        tax
        lda EXPF_OBJ,x
        ldx oe_x
        cmp #0
        beq es_s
        lda es_t
        cmp SC_T,y
        bne es_s
        lda $0802,x
        eor SC_A,y
        and #$D0                ; flips changed, or the source must be rewritten
        beq es_px
es_s    jsr es_wsrc
        bcc es_px
        inc es_missing          ; never display a frame with missing sprite tiles
        jmp es_hide
es_px   lda $0803,x             ; x
        cmp SC_X,y
        beq es_py
        sta SC_X,y
        sty es_cy
        ldy #6
        sta (ZP),y
        ldy es_cy
        cmp #249
        bcs es_wc
        lda SC_A,y
        and #4
        beq es_py
es_wc   jsr es_wclip
es_py   lda $0800,x             ; y
        cmp SC_Y,y
        beq es_pal
        sta SC_Y,y
        sty es_cy
        ldy #7
        clc
        adc #1
        sta (ZP),y
        ldy es_cy
        cmp #225
        bcs es_hc
        lda SC_A,y
        and #8
        beq es_pal
es_hc   jsr es_hclip
es_pal  lda $0802,x
        eor SC_A,y
        and #$23                ; palette changed or the slot was hidden
        beq es_next
        jsr es_wpal
es_next lda ZP
        clc
        adc #21
        sta ZP
        bcc es_n1
        inc ZP+1
es_n1   iny
        txa
        sec
        sbc #4
        tax
        bcc es_end
        jmp es_loop
es_end  rts
es_inc  lda ZP
        clc
        adc #21
        sta ZP
        bcc es_i1
        inc ZP+1
es_i1   rts

es_hide1
        lda SC_A,y
        ora #$20
        sta SC_A,y
        lda #0
        sty es_cy
        ldy #15
        sta (ZP),y              ; AND 0: draws nothing
        ldy es_cy
        rts

es_wpal lda $0802,x
        and #$C3
        sta es_f
        lda SC_A,y
        and #$1C                ; keep source-rewrite and clip flags
        ora es_f
        sta SC_A,y
        lda es_f
        and #3
        asl
        asl
        ora #$13
        sty es_cy
        ldy #15
        sta (ZP),y
        ldy es_cy
        rts

; width for x = SC_X (clipped at the right edge); flag bit 2
es_wclip
        lda SC_X,y
        cmp #249
        bcc ewc_7
        eor #$FF                ; 255 - x
        pha
        lda SC_A,y
        ora #4
        bne ewc_w
ewc_7   lda #7
        pha
        lda SC_A,y
        and #$FB
ewc_w   sta SC_A,y
        pla
        sty es_cy
        ldy #12
        sta (ZP),y
        ldy es_cy
        rts

; height for y = SC_Y (clipped at the bottom); flag bit 3
es_hclip
        lda SC_Y,y
        cmp #224
        bcc ehc_7
        sta es_f
        lda #238
        sec
        sbc es_f
        pha
        lda SC_A,y
        ora #8
        bne ehc_w
ehc_7   lda #15
        pha
        lda SC_A,y
        and #$F7
ehc_w   sta SC_A,y
        pla
        sty es_cy
        ldy #14
        sta (ZP),y
        ldy es_cy
        rts

; source: tile and flips (X = OAM offset, Y = cache index; both kept)
es_wsrc lda $0801,x
        sta es_t
        sty es_cy
        tay
        lda EXPF_OBJ,y
        bne ews_e
        jsr obj_expand
        ldy es_cy
        bcc ews_e
        rts                     ; C=1: no expansion budget left this frame
ews_e   ldy es_cy
        lda es_t
        sta SC_T,y
        lda SC_A,y
        and #$EF
        sta SC_A,y
        lda $0802,x
        eor SC_A,y
        and #$C0
        beq ews_1
        eor SC_A,y
        sta SC_A,y              ; new flips
        asl                     ; C = vertical flip
        php
        ldy #3
        lda #8
        bcc ews_a
        lda #$F8
ews_a   sta (ZP),y
        iny
        lda #0
        bcc ews_b
        lda #$1F
ews_b   sta (ZP),y
        iny
        plp
        ldy es_cy
        lda SC_A,y
        asl
        asl                     ; C = horizontal flip
        lda #1
        bcc ews_c
        lda #$FF
ews_c   ldy #5
        sta (ZP),y
ews_1   ldy es_cy
        lda SC_A,y
        asl                     ; C = vertical flip
        lda #0
        bcc ews_2
        lda #120
ews_2   sta es_f
        lda SC_A,y
        and #$40
        beq ews_3
        lda #7
        ora es_f
        sta es_f
ews_3   lda es_t
        and #1
        lsr
        ror
        ora es_f
        ldy #0
        sta (ZP),y
        iny
        lda es_t
        lsr
        ora #>(V_SLOT_OBJ & $FFFF)
        sta (ZP),y
        ldy es_cy
        clc
        rts

; ------------------------------------------------------------------
; Expand background tile X or 8x16 sprite X, selected by MEMAC-B value Y.
; Uses MEMAC-A to read NES CHR RAM; sprite bit 0 selects the pattern table.
; ------------------------------------------------------------------
expand  sty ex_memb
        stx ex_t
        cpy #MEMB_SBG
        bne ex_sprite
        lda #8
        sta ex_height
        txa
        lsr
        lsr
        ora #$40
        sta ZP+3
        txa
        and #3
        asl
        asl
        asl
        asl
        asl
        asl
        sta ZP+2
        lda bg_bank
        sta ex_b
        txa
        jmp ex_source
ex_sprite
        lda #16
        sta ex_height
        txa
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        clc
        adc #MEMB_SOBJ
        sta ex_memb
        txa
        and #$7F
        lsr
        ora #$40
        sta ZP+3
        txa
        and #1
        sta ex_b
        lsr
        ror
        sta ZP+2
        txa
        and #$FE
ex_source
        pha
        lsr
        lsr
        lsr
        lsr
        sta ZP+1
        lda ex_b
        asl
        asl
        asl
        asl
        ora ZP+1
        ora #$80
        sta ZP+1
        pla
        asl
        asl
        asl
        asl
        sta ZP
        lda #$80 | ((V_CHRIDX >> 14) << 2)
        sta mems_sh
ex_ms1 sta VBX+VB_MEMS
        lda ex_memb
        sta memb_sh
ex_mb   sta VBX+VB_MEMB
        lda #0
        sta ex_i
        sta ex_o
ex_loop lda ex_i
        cmp #8
        bcc ex_top
        clc
        adc #8
ex_top  tay
        lda (ZP),y
        sta ex_p0
        tya
        clc
        adc #8
        tay
        lda (ZP),y
        sta ex_p1
        and #$F0
        sta ex_b
        lda ex_p0
        lsr
        lsr
        lsr
        lsr
        ora ex_b
        tax
        ldy ex_o
        lda xt0,x
        sta (ZP+2),y
        iny
        lda xt1,x
        sta (ZP+2),y
        iny
        lda xt2,x
        sta (ZP+2),y
        iny
        lda xt3,x
        sta (ZP+2),y
        iny
        sty ex_o
        lda ex_p1
        asl
        asl
        asl
        asl
        sta ex_b
        lda ex_p0
        and #15
        ora ex_b
        tax
        ldy ex_o
        lda xt0,x
        sta (ZP+2),y
        iny
        lda xt1,x
        sta (ZP+2),y
        iny
        lda xt2,x
        sta (ZP+2),y
        iny
        lda xt3,x
        sta (ZP+2),y
        iny
        sty ex_o
        inc ex_i
        lda ex_i
        cmp ex_height
        beq ex_done
        jmp ex_loop
ex_done
        rts
; ------------------------------------------------------------------
; controls -> NES pad bits (A B Select Start Up Down Left Right)
; Player 1: joystick 0; fire = B (shoot). A (jump): SHIFT, jump keys, the
; second/third button of a 2-button joystick (Joy2B+, POT 0/1) and, in
; one-player games, joystick 1's fire.
; Player 2 (PLAYER_MODE_1D bit 2): joystick 1, fire = B, POT 2/3 = A.
; START = Start, SELECT = Select.
; A source counts once it has been seen released (Altirra holds a console
; key while booting; an unused POT line may read as pressed). A POT button
; is a change from the level the line had once the first scans finished.
; ------------------------------------------------------------------
read_input
        ; POT lines finish counting 228 scan lines after POTGO. Read and
        ; restart the scan only at the vertical blank: an extra game tick
        ; from a mid-frame DLI would otherwise see half-counted lines as a
        ; held second button (the player kept jumping on PAL).
        lda nmi_kind
        beq ri_vbi
        rts                     ; PAL's extra mid-frame tick: keep the inputs
ri_vbi  ldx #3
ri_p    lda POT0,x
        sta pot_val,x
        dex
        bpl ri_p
        sta POTGO
        lda PORTA
        and #$0F
        tax
        lda stick_tab,x
        sta ri_b
        lda PORTA
        lsr
        lsr
        lsr
        lsr
        tax
        lda stick_tab,x
        sta ri_b2
        ; player 1 fire = B
        lda TRIG0
        cmp #1                  ; C = 0 when pressed
        ldx #0
        jsr src_chk
        bcc ri_1
        lda ri_b
        ora #$40
        sta ri_b
ri_1    lda ri_b
        sta ri_j                ; joystick 1 alone: for the menus
        ; player 1 A
        lda SKSTAT
        and #8                  ; SHIFT
        cmp #1
        ldx #1
        jsr src_chk
        bcs ri_a1
        ldx #0
        jsr pot_btn
        ldx #3
        jsr src_chk
        bcs ri_a1
        ldx #1
        jsr pot_btn
        ldx #4
        jsr src_chk
        bcs ri_a1
        lda $1D
        and #4
        cmp #4
        beq ri_2                ; two players: joystick 1 belongs to player 2
        ; Joystick 2's fire jumps only while joystick 1's fire is up: an
        ; emulator that maps one key to both sticks would otherwise jump on
        ; every shot.
        lda TRIG0
        beq ri_t0
        lda TRIG1
        cmp #1
        bcc ri_t1
ri_t0   sec
ri_t1   ldx #5
        jsr src_chk
        bcc ri_2
ri_a1   lda ri_b
        ora #$80
        sta ri_b
ri_2    ; player 2
        lda $1D
        and #4
        cmp #4
        beq ri_p2
        lda #0
        sta ri_b2
        beq ri_con
ri_p2   lda TRIG1
        cmp #1
        ldx #5
        jsr src_chk
        bcc ri_3
        lda ri_b2
        ora #$40
        sta ri_b2
ri_3    ldx #2
        jsr pot_btn
        ldx #6
        jsr src_chk
        bcs ri_a2
        ldx #3
        jsr pot_btn
        ldx #7
        jsr src_chk
        bcc ri_con
ri_a2   lda ri_b2
        ora #$80
        sta ri_b2
ri_con  jsr kb_read             ; W/A/S/D, punch/kick keys, RETURN
        ora ri_b
        sta ri_b
        lda CONSOL
        lsr
        bcs ri_c3
        tax
        ldy #$10                ; START = Start ...
ri_s    tya
        ora ri_b
        sta ri_b
        txa
ri_c3   lsr
        bcs ri_c4
        lda ri_b
        ora #$20
        sta ri_b
ri_c4   jsr menu_input
        jsr bunny_input
        lda ri_b
        sta nes_buttons
        lda ri_b2
        sta nes_buttons2
        rts

irq     pha
        lda IRQST
        and #$40
        bne irq_x               ; not the keyboard
        lda #0                  ; acknowledge
        sta IRQEN
        lda #$40
        sta IRQEN
        txa
        pha
        ldx kb_head
        lda KBCODE
        sta kb_ring,x
        inx
        txa
        and #7
        cmp kb_tail
        beq kb_full
        sta kb_head
kb_full pla
        tax
irq_x   pla
        rti

; A = NES bits from the keyboard
kb_read
kr_ev   ldy kb_tail
        cpy kb_head
        beq kr_end
        lda kb_ring,y
        iny
        tya
        and #7
        sta kb_tail
        lda kb_ring-1,y
        and #$3F
kr_k    ldx #key_bits-key_codes-1
kr_f    cmp key_codes,x
        beq kr_found
        dex
        bpl kr_f
        bmi kr_ev
kr_found
        cpx #4
        bcs kr_act
        lda kdir                ; a direction: held
        and key_clear,x
        ora key_bits,x
        sta kdir
        jmp kr_ev
kr_act  lda key_bits,x          ; an action: a short press
        ora kpulse
        sta kpulse
        lda #4
        sta kpulse_t
        jmp kr_ev
kr_end  lda SKSTAT
        and #4
        beq kr_held
        lda #0                  ; keyboard idle: directions released
        sta kdir
kr_held lda kpulse_t
        beq kr_np
        dec kpulse_t
        lda kdir
        ora kpulse
        rts
kr_np   sta kpulse
        lda kdir
        rts
; W S A D, then punch O Z C N, kick P X V SPACE, Start RETURN
key_codes dta $2E,$3E,$3F,$3A, $08,$17,$12,$23, $0A,$16,$10,$21, $0C
key_bits  dta $08,$04,$02,$01, $40,$40,$40,$40, $80,$80,$80,$80, $10
key_clear dta $FF^$04,$FF^$08,$FF^$01,$FF^$02

; C = 0: source X pressed (raw). Returns C = 1 when pressed and the source
; has been seen released before.
src_chk bcc sc_down
        lda bitmask,x           ; released: arm it
        ora src_armed
        sta src_armed
        clc
        rts
sc_down lda bitmask,x
        and src_armed
        cmp #1                  ; C = armed
        rts

; The title, demo, CONTINUE/END and game over screens only react to Start
; and Select. There joystick 1's fire is Start and pushing it up or down is
; Select, so a game starts with the joystick alone. A button held into a
; menu (fire while dying) counts only after its release. Keyboard keys keep
; their NES meaning, so the Konami code still works with W/S/A/D, O and P.
menu_input
        lda $18                 ; GAME_ROUTINE_INDEX
        cmp #3
        bcc mi_menu             ; intro, player select, demo
        cmp #5
        bne mi_off
        lda $2C                 ; LEVEL_ROUTINE_INDEX
        cmp #6
        bcc mi_off
        cmp #8
        bcc mi_menu             ; 6 = CONTINUE/END, 7 = game over
mi_off  lda #0
        sta mi_arm
        rts
mi_menu lda ri_j
        eor #$FF
        and #$4C
        ora mi_arm
        sta mi_arm              ; released fire / up / down: armed
        and ri_j
        tax
        and #$40
        beq mi_sel
        lda ri_b
        ora #$10                ; fire = Start
        sta ri_b
mi_sel  txa
        and #$0C
        beq mi_done
        pha
        eor #$FF
        and mi_arm
        sta mi_arm              ; one step per push: release to step again
        pla
        ; On the title's player select menu up and down move the cursor (it
        ; stops at the ends). Elsewhere (intro scroll, demo, CONTINUE/END,
        ; game over) they act as Select.
        ldy $18                 ; GAME_ROUTINE_INDEX
        cpy #1
        bne mi_selb
        ldy $FD                 ; HORIZONTAL_SCROLL: 0 once the menu shows
        bne mi_selb
        and #4
        bne mi_down
        lda BUNNY_MODE          ; up: BAX BUNNY -> 2 PLAYERS -> 1 PLAYER
        beq mi_1p
        lda #0
        sta BUNNY_MODE
        lda #1
        sta $22                 ; PLAYER_MODE
        rts
mi_1p   sta $22
        rts
mi_down lda BUNNY_MODE          ; down: 1 PLAYER -> 2 PLAYERS -> BAX BUNNY
        bne mi_done
        lda $22
        bne mi_bun
        inc $22
        rts
mi_bun  lda #0
        sta $22
        lda #1
        sta BUNNY_MODE
        rts
mi_selb lda ri_b
        ora #$20                ; Select
        sta ri_b
mi_done rts

; BAX BUNNY: a one-player game whose player also jumps on their own every
; 0.5-1.5 s. A jump presses A for a few ticks; unless the player steers, it
; drifts left, right or straight up. The player's own input always counts.
BUNNY_TICKS = 32                   ; ticks of one automatic jump
BUNNY_PRESS = 6                   ; of which A is held
bunny_input
        lda BUNNY_MODE
        beq bu_off
        lda $18                 ; GAME_ROUTINE_INDEX: playing a level
        cmp #5
        bne bu_off
        lda $2C                 ; LEVEL_ROUTINE_INDEX: level running
        cmp #4
        bne bu_off
        lda $25                 ; PAUSE_STATE
        bne bu_done
        lda bu_t
        bne bu_jump
        lda bu_wait
        beq bu_new
        dec bu_wait
        rts
bu_new  lda RANDOM
        and #63
        adc #30
        sta bu_wait             ; the pause after this jump
        lda RANDOM
        and #3                  ; 0/3 = straight up, 1 = right, 2 = left
        cmp #3
        bne bu_d
        lda #0
bu_d    sta bu_dir
        lda #BUNNY_TICKS
        sta bu_t
bu_jump dec bu_t
        lda bu_t
        cmp #BUNNY_TICKS-BUNNY_PRESS
        bcc bu_drift
        lda ri_b
        ora #$80                ; A = jump
        sta ri_b
bu_drift lda ri_b
        and #$03
        bne bu_done             ; the player steers
        lda ri_b
        ora bu_dir
        sta ri_b
bu_done rts
bu_off  lda #0
        sta bu_t
        lda #60
        sta bu_wait             ; a second of peace at the start
        rts

; C = 0 when POT line X differs from its resting level
pot_btn lda vframe+1
        bne pt_go
        lda vframe
        cmp #30
        bcc pt_no
pt_go   lda pot_val,x
        cmp #128
        lda #0
        rol                     ; 1 = high
        ldy pot_rest,x
        bpl pt_k
        sta pot_rest,x          ; first read: the resting level
pt_no   sec
        rts
pt_k    cmp pot_rest,x
        beq pt_no
        clc
        rts

; PORTA nibble (0 = pressed: up, down, left, right) -> NES U=8 D=4 L=2 R=1
stick_tab
        dta $0f,$07,$0b,$03,$0d,$05,$09,$01,$0e,$06,$0a,$02,$0c,$04,$08,$00

; Only the pattern selection at the end of the NES frame is displayed.
; Temporary PPUCTRL writes while uploading data must not evict caches.
pattern_select
        lda lat_ctrl
        lsr
        lsr
        lsr
        and #1
        cmp obj_bank
        beq pat_bg
        sta obj_bank
        ldx #0
        txa
pat_obj sta EXPF_OBJ,x
        inx
        bne pat_obj
        lda #1
        sta chr_dirty
pat_bg  lda lat_ctrl
        lsr
        lsr
        lsr
        lsr
        and #1
        cmp bg_bank
        beq pat_done
        sta bg_bank
        ldx #0
        txa
pat_bgt sta EXPF_BG,x
        inx
        bne pat_bgt
        lda #1
        sta chr_dirty
pat_done rts

vbi_tick dta 1,0,0,0,1

; Advance the PAL display-list phase even when a game tick is still running.
; Otherwise a DLI near VBI could keep the scheduler stuck in one phase.
frame_schedule
        inc vframe
        bne fs_tick
        inc vframe+1
fs_tick lda tick_mode
        beq fs_ntsc
        ldx tick_phase
        lda vbi_tick,x
        clc
        adc ticks_owed
        cmp #3
        bcc fs_count
        lda #2
fs_count sta ticks_owed
        inx
        cpx #5
        bcc fs_phase
        ldx #0
fs_phase stx tick_phase
        lda dl_lo,x
        sta DLISTL
        lda dl_hi,x
        sta DLISTH
        rts
fs_ntsc lda ticks_owed
        cmp #2
        bcs fs_done
        inc ticks_owed
fs_done
        rts

; CHR-RAM animation dirties only nametable cells using an invalidated tile.
; The game can update patterns while this scan is suspended by an NMI;
; such a write sets chr_dirty again for a following scan.
mark_chr_dirty
        ; Snapshot and clear the small change bitmap atomically.
        lda #0
        sta NMIEN
        sta chr_dirty
        ldx #0
        ldy #0
md_bits lda CHR_BITS,x
        sta CHR_SNAP,x
        beq md_bit_next
        txa
        sta CHR_LIST,y
        iny
md_bit_next
        lda #0
        sta CHR_BITS,x
        inx
        cpx #32
        bne md_bits
        sty CHR_COUNT
        lda #$C0
        sta NMIEN
        cpy #0
        bne md_start
        rts
md_start
        lda #0
        sta md_phys
md_table
        ldx md_phys
        lda phys_page,x
        sta ZP+1
        txa
        asl
        asl
        clc
        adc #>ROW_USES
        sta ZP+3
        lda #0
        sta ZP
        sta ZP+2
        sta md_row
        lda phys_row128,x
        sta md_di
        lda phys_row32,x
        sta md_ri
md_nextrow
        ; Most CHR animation changes only one bitmap byte. Skip rows whose
        ; conservative membership mask has no intersection with that change.
        ldx #0
md_test cpx CHR_COUNT
        bne md_test_entry
        jmp md_advance
md_test_entry
        ldy CHR_LIST,x
        lda (ZP+2),y
        and CHR_SNAP,y
        bne md_scan
        inx
        bne md_test
md_scan lda #0
        sta md_changed
        ldy #0
md_byte
        ; Pack eight cache-valid flags directly into one dirty byte.
        ; ROR puts the first cell in bit 0 after eight iterations. This
        ; avoids a read/modify/write and bit-index calculation per cell.
        .rept 8
        lda (ZP),y
        tax
        lda EXPF_BG,x
        cmp #1
        ror md_col
        iny
        .endr
        lda md_col
        eor #$FF
        ldx md_di
        ora DIRTY,x
        sta DIRTY,x
        beq md_byte_clean
        lda #1
        sta md_changed
        sta any_dirty
md_byte_clean
        inc md_di
        cpy #32
        bne md_byte
        ldx md_ri
        lda md_changed
        beq md_advance
        sta ROWDIRTY,x
md_advance
        inc md_ri
        lda md_ri
        asl
        asl
        sta md_di
        lda ZP
        clc
        adc #32
        sta ZP
        bcc md_no_page
        inc ZP+1
md_no_page
        lda ZP+2
        clc
        adc #32
        sta ZP+2
        bcc md_no_maskpage
        inc ZP+3
md_no_maskpage
        inc md_row
        lda md_row
        cmp #30
        beq md_table_done
        jmp md_nextrow
md_table_done
        inc md_phys
        lda md_phys
        cmp #2
        beq md_done
        jmp md_table
md_done rts
