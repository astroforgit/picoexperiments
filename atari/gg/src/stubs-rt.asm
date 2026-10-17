; ------------------------------------------------------------------
; Helpers of the generated I/O stubs (gen/stubs.asm). Each computes the
; value a C64 register read returns into rv and preserves A, X, Y and P.
; ------------------------------------------------------------------

; current C64 raster line into gr_lo/gr_hi: the line of the IRQ handler
; being run, else a virtual line for the main program: line 0 when the
; NMI ended, line 311 at the next vertical blank (the main program never
; runs while the NMI does). Busy-wait loops for one line are replaced by
; wait_line (see tools/patch.py).
raster_now
        lda in_chain
        beq rn_live
        lda cur_lo
        sta gr_lo
        lda cur_hi
        sta gr_hi
        rts
rn_live txa
        pha
        jsr raster_time
        lda rs_base
        sta gr_lo
        lda rs_base+1
        sta gr_hi
        pla
        tax
        rts

; rs_base = virtual line now (X used)
raster_time
        lda VCOUNT
        sec
        sbc rs_vend             ; VCOUNT steps since the NMI ended
        bcs rt_1
        adc rs_vtot
rt_1    cmp rs_avail
        bcc rt_2
        lda rs_avail
        sbc #1
rt_2    cmp rs_d
        beq rt_x
        bcs rt_fw
        ldx #0                  ; earlier than the last time: count from 0
        stx rs_base
        stx rs_base+1
        stx rs_frac
        ldx #$FF
        stx rs_d
rt_fw   sta rs_t
rt_m    lda rs_d
        cmp rs_t
        beq rt_x
        inc rs_d
        lda rs_frac
        clc
        adc rs_k
        sta rs_frac
        lda rs_base
        adc rs_k+1
        sta rs_base
        bcc rt_m
        inc rs_base+1
        jmp rt_m
rt_x    lda rs_base+1           ; keep within 0..311
        beq rt_ok
        lda rs_base
        cmp #<312
        bcc rt_ok
        lda #<311
        sta rs_base
rt_ok   rts

; wait until the virtual raster reaches line A (0-255) in this frame, or in
; the next one when it is already past; the renderer works meanwhile.
; Returns with A = the line; X, Y kept.
wait_line
        sta wl_n
        stx wl_x
        sty wl_y
        lda vframe
        sta wl_f
        jsr raster_time
        lda rs_base+1
        bne wl_next
        lda rs_base
        cmp wl_n
        bcc wl_l                ; not reached yet in this frame
wl_next lda vframe              ; past it: the next frame
        cmp wl_f
        bne wl_l
        jsr wl_idle
        jmp wl_next
wl_l    jsr raster_time
        lda rs_base+1
        bne wl_ok
        lda rs_base
        cmp wl_n
        bcs wl_ok
        jsr wl_idle
        jmp wl_l
wl_ok   ldx wl_x
        ldy wl_y
        lda wl_n
        rts
wl_idle lda nmi_busy              ; (in the IRQ chain: no renderer work)
        bne wl_ix
        jmp co_run              ; a whole step (co_pre 0: not suspended)
wl_ix   rts
wl_n    dta 0
wl_x    dta 0
wl_y    dta 0
wl_f    dta 0

; NMI end: start of the main program's virtual frame
raster_sync
        lda VCOUNT
        sta rs_vend
        ldx #156
        lda ntsc
        beq rsy_1
        ldx #131
rsy_1   stx rs_vtot
        ; VCOUNT steps until the next VBI (VCOUNT 124)
        lda #124
        sec
        sbc rs_vend
        bcs rsy_2
        adc rs_vtot
rsy_2   cmp #8
        bcs rsy_3
        lda #8                  ; (an NMI that overran: keep some range)
rsy_3   cmp rs_avail
        beq rsy_same
        sta rs_avail
        ; k = 312 * 256 / avail: table in bank SPLIT (the NMI restores
        ; the bank it interrupted)
        lda #BK_SPLIT
        jsr mema_set
        ldx rs_avail
        lda rsk_lo-8,x
        sta rs_k
        lda rsk_hi-8,x
        sta rs_k+1
        clc
        adc #1
        sta rs_step
rsy_same
        lda #$FF
        sta rs_d
        lda #0
        sta rs_base
        sta rs_base+1
        sta rs_frac
        rts
gr_lo   dta 0
gr_hi   dta 0
gr_t    dta 0,0
rs_vend dta 0
rs_vtot dta 156
rs_avail dta 0
rs_k    dta 0,3
rs_step dta 4
rs_d    dta $FF
rs_base dta 0,0
rs_cap  dta 0
rs_n    dta 0,0,0
rs_frac dta 0
rs_t    dta 0
rs_last dta $FF,$FF

get_d012
        php
        pha
        jsr raster_now
        lda gr_lo
        sta rv
        pla
        plp
        rts

get_d011
        php
        pha
        jsr raster_now
        lda gr_hi
        lsr
        lda VIC+$11
        and #$7F
        bcc g11_1
        ora #$80
g11_1   sta rv
        pla
        plp
        rts

; CIA1 port A: the column lines the game drives, with joystick 2 pulling
get_dc00
        php
        pha
        lda CIA1
        and joy2
        sta rv
        pla
        plp
        rts

; CIA1 port B: rows of the keys in the selected columns
get_dc01
        php
        pha
        lda #$FF
        sta rv
        lda key_pa
        beq g01_s
        and CIA1
        bne g01_s
        lda key_pb
        sta rv
g01_s   lda shift_on
        beq g01_x
        lda CIA1
        and #$02                ; left SHIFT: PA1 / PB7
        bne g01_x
        lda rv
        and #$7F
        sta rv
g01_x   pla
        plp
        rts

; colour RAM was written (the stub did the store)
col_mark
        php
        pha
        lda #$FF
        sta col_dirty
        pla
        plp
        rts

; the game rewrote charset memory
cs_mark
        php
        pha
        lda #$FF
        sta cs_dirty
        pla
        plp
        rts

; the IRQ swapped the animated characters ($FA/$FB, $FC/$FD)
anim_mark1
        php
        pha
        lda anim_dirty
        ora #1
        sta anim_dirty
        pla
        plp
        rts
anim_mark2
        php
        pha
        lda anim_dirty
        ora #2
        sta anim_dirty
        pla
        plp
        rts

; SID oscillator 3 / envelope 3 readback: a random value
get_rnd php
        pha
        lda RANDOM
        sta rv
        pla
        plp
        rts
