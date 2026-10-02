; Decompress a 4bpp pose into the shared VBXE scratch sprite at $7E000.
; $8400..$87FF is CPU staging scratch, separate from ANTIC and the aperture.

        icl 'generated/hero-animation.inc'
.proc hero_sprite
        tax
        mva #255 idle_pending
        lda hero_set,x
        sta pose_id
        lda hero_palette_lo,x
        sta pose_palette
        lda hero_palette_hi,x
        sta pose_palette+1
        ldx draw_id
        lda animation_active
        beq ?attack
        cpx animation_unit
        bne ?attack
        lda animation_step
        and #3
        jmp ?frame
?attack lda attack_frame
        beq ?idle
        cpx attacker_unit
        bne ?idle
        lda attack_frame
        cmp #5
        lda #4
        adc #0
        eor #1
        jmp ?frame
?idle   ldx #IDLE_CACHE_COUNT-1
?find   lda idle_ids,x
        cmp pose_id
        beq ?hit
        dex
        bpl ?find
        ldx idle_next
        cpx #IDLE_CACHE_COUNT
        bcs ?uncached
        lda pose_id
        sta idle_ids,x
        stx idle_pending
        inc idle_next
?uncached
        lda #0
        jmp ?frame
?hit    mva idle_cache_lo,x bl_src
        mva idle_cache_hi,x bl_src+1
        mva idle_cache_bank,x bl_src+2
        jmp ?blit
?frame  clc
        adc pose_id
        cmp pose_cached
        jeq ?ready
        sta pose_cached
        tax
        jsr wait_blit
        lda hero_bank,x
        ora #128
reg_source
        sta VBXE_BANK_SEL
        mva hero_src_lo,x work_ptr
        mva hero_src_hi,x work_ptr+1
        mwa #$8400 data_ptr
        ldy #0
?copy   lda (work_ptr),y
        sta (data_ptr),y
        beq ?decode
        inw work_ptr
        inw data_ptr
        jmp ?copy
?decode mwa pose_palette work_ptr
        lda #$FE
reg_cache
        sta VBXE_BANK_SEL
        mwa #$8400 data_ptr
        mwa #MEMW text_dst
?token  jsr get
        beq ?ready
        bmi ?run
        sta pose_count
?literal
        jsr get
        jsr pair
        dec pose_count
        bne ?literal
        jmp ?token
?run    sta pose_token
        and #63
        clc
        adc #1
        sta pose_count
        lda pose_token
        cmp #192
        bcc ?zero
        jsr get
        jmp ?repeat
?zero   lda #0
?repeat sta pose_repeat
?fill   lda pose_repeat
        jsr pair
        dec pose_count
        bne ?fill
        jmp ?token
?ready  lda idle_pending
        cmp #255
        beq ?scratch
        jsr save_idle
?scratch mwa #$E000 bl_src
        mva #7 bl_src+2
?blit   mwa #32 bl_ssy
        mwa #31 bl_w
        mva #27 bl_h
        jmp transparent_blit
.endp
; Blitter copies opaque cached pixels, including transparent zeroes.
.proc save_idle
        tax
        mwa #$E000 bl_src
        mva #7 bl_src+2
        mva idle_cache_lo,x bl_dst
        mva idle_cache_hi,x bl_dst+1
        mva idle_cache_bank,x bl_dst+2
        mwa #32 bl_ssy
        mwa #32 bl_dsy
        mwa #31 bl_w
        mva #27 bl_h
        mva #1 bl_ssx
        sta bl_dsx
        mva #255 bl_and
        mva #0 bl_xor
        sta bl_mode
        jsr do_blit
        mva #255 idle_pending
        rts
.endp
idle_ids :IDLE_CACHE_COUNT dta 255
idle_next dta 0
idle_pending dta 255
.proc get
        ldy #0
        lda (data_ptr),y
        inw data_ptr
        cmp #0
        rts
.endp
.proc pair
        sta pose_packed
        lsr
        lsr
        lsr
        lsr
        tay
        lda (work_ptr),y
        ldy #0
        sta (text_dst),y
        inw text_dst
        lda pose_packed
        and #15
        tay
        lda (work_ptr),y
        ldy #0
        sta (text_dst),y
        inw text_dst
        rts
.endp
pose_cached dta 255
pose_id dta 0
pose_palette dta a(0)
pose_count dta 0
pose_token dta 0
pose_repeat dta 0
pose_packed dta 0

.proc prepare_projectile
        ldx attacker_unit
        lda unit_cell,x
        ldy defender_unit
        ldx unit_cell,y
        jsr distance_cells
        cmp #2
        lda #0
        rol
        sta attack_ranged
        ldx attacker_unit
        ldy unit_cell,x
        mva cell_x_lo,y projectile_x
        mva cell_y,y projectile_y
        ldx defender_unit
        ldy unit_cell,x
        lda cell_x_lo,y
        sec
        sbc projectile_x
        jsr step
        sta projectile_dx
        lda cell_y,y
        sec
        sbc projectile_y
        jsr step
        sta projectile_dy
        rts
.endp
; C tells the sign of the coordinate subtraction; retain Y (cell index).
.proc step
        bcs ?positive
        eor #255
        clc
        adc #1
        lsr
        lsr
        lsr
        eor #255
        clc
        adc #1
        rts
?positive
        lsr
        lsr
        lsr
        rts
.endp
.proc advance_projectile
        clc
        lda projectile_x
        adc projectile_dx
        sta projectile_x
        clc
        lda projectile_y
        adc projectile_dy
        sta projectile_y
        rts
.endp
.proc projectile
        lda attack_frame
        beq ?done
        lda attack_ranged
        beq ?done
        mva projectile_x calc_x
        mva #0 calc_x+1
        lda projectile_y
        sec
        sbc #12
        sta calc_y
        mwa #5 fr_w
        mva #2 fr_h
        mva #2 fr_col
        jsr fill_rect
?done   rts
.endp
attack_ranged dta 0
projectile_x dta 0
projectile_y dta 0
projectile_dx dta 0
projectile_dy dta 0
