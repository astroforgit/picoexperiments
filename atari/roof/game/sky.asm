; Slow clouds and an occasional downward meteor. Independent of fishing RNG.
reset_sky
        lda random_seed
        eor #$63
        ora #1
        sta sky_seed
        lda #0
        sta meteor_life
        sta sky_ticks
        sta meteor_trials
        sta cloud_pending
        lda #64
        sta cloud_clock
        lda #<500
        sta meteor_clock
        lda #>500
        sta meteor_clock+1
        ldx #CLOUD_SLOTS-1
reset_cloud
        lda cloud_start,x
        sta cloud_x,x
        lda cloud_initial_dir,x
        sta cloud_dir,x
        dex
        bpl reset_cloud
        rts
sky_random
        lda sky_seed
        asl
        bcc sky_random_done
        eor #$1d
sky_random_done
        sta sky_seed
        rts
 ; Called once per PAL VBI: weather timing is independent of render speed.
sky_vblank
        inc sky_ticks
        dec cloud_clock
        bne sky_clock_meteor
        lda #64
        sta cloud_clock
        inc cloud_pending
sky_clock_meteor
        lda meteor_clock
        bne sky_clock_low
        dec meteor_clock+1
sky_clock_low
        dec meteor_clock
        lda meteor_clock
        ora meteor_clock+1
        bne sky_clock_done
        lda #<500
        sta meteor_clock
        lda #>500
        sta meteor_clock+1
        inc meteor_trials
sky_clock_done
        rts
update_sky
        lda cloud_pending
        beq meteor_tick
        dec cloud_pending
        ldx #CLOUD_SLOTS-1
cloud_move
        lda cloud_x,x
        clc
        adc cloud_dir,x
        sta cloud_x,x
        cmp #160
        bne cloud_left_edge
        lda #255
        sta cloud_dir,x
        bne cloud_next
cloud_left_edge
        cmp #0
        bne cloud_next
        lda #1
        sta cloud_dir,x
cloud_next
        dex
        bpl cloud_move
meteor_tick
        lda meteor_life
        beq meteor_pause
        dec meteor_life
        clc
        lda meteor_x
        adc #2
        sta meteor_x
        clc
        lda meteor_y
        adc #3
        sta meteor_y
        rts
meteor_pause
        lda meteor_trials
        beq sky_done
        dec meteor_trials
        jsr sky_random
meteor_roll_compare
        cmp #METEOR_THRESHOLD
        bcc meteor_start
        bne sky_done
meteor_start
        jsr sky_random
        and #127
        clc
        adc #24
        sta meteor_x
        lda #34
        sta meteor_y
        lda #24
        sta meteor_life
sky_done
        rts

draw_meteor
        lda meteor_life
        beq sky_done
        lda meteor_x
        sta px
        lda meteor_y
        sta py
        lda #252
        sta color
        jsr plot_xy
        lda #251
        sta color
        lda #4
        sta meteor_tail
meteor_tail_pixel
        dec px
        dec py
        dec py
        jsr plot_xy
        dec meteor_tail
        bne meteor_tail_pixel
        rts

; Blitter mode 1 skips zero edges, but the cloud body replaces sky/stars.
; 160x40 wisps bounce gently within the full 320px sky. The menu's cloud
; level draws none, the first three, or all six.
draw_clouds
        ldx cloud_count
        dex
        bpl cloud_draw
        rts
cloud_draw
        stx cloud_index
        jsr blwait
        lda cloud_x,x
        clc
        adc cloud_row_lo,x
        sta cloud_blit+6
        lda cloud_row_hi,x
        adc #0
        sta cloud_blit+7
        lda buffer
        sta cloud_blit+8
        lda #$ff
        ldy #$5f
        sta (vb),y
        ldx #20
cloud_command
        lda cloud_blit,x
        sta $9000,x
        dex
        bpl cloud_command
        lda #1
        ldy #$53
        sta (vb),y
        jsr blwait
        ldx cloud_index
        dex
        bpl cloud_draw
        rts
cloud_blit
        dta 0,$40,1,a(160),1,0,0,2,a(320),1,a(159),39,$ff,0,0,0,0,1
CLOUD_SLOTS = 6
cloud_row_lo dta <(40*320),<(74*320),<(104*320),<(26*320),<(58*320),<(90*320)
cloud_row_hi dta >(40*320),>(74*320),>(104*320),>(26*320),>(58*320),>(90*320)
cloud_start dta 8,79,147,120,12,64
cloud_initial_dir dta 1,255,1,255,1,255
cloud_x :CLOUD_SLOTS dta 0
cloud_dir :CLOUD_SLOTS dta 0
cloud_count dta 3
cloud_index dta 0
sky_ticks dta 0
sky_seed dta 1
meteor_clock dta a(500)
meteor_trials dta 0
cloud_clock dta 64
cloud_pending dta 0
meteor_life dta 0
meteor_x dta 0
meteor_y dta 0
meteor_tail dta 0

; Fixed positions generated from editor settings. Only intensity changes.
draw_starfield
        .if STARFIELD_COUNT > 0
        lda sky_ticks
        lsr
        lsr
        lsr
        lsr
        lsr
        sta field_tick
        ldx #0
field_draw
        lda #STAR_BRIGHT
        sta color
        lda field_flags,x
        and #2
        beq field_bright
        lda field_phase,x
        clc
        adc field_tick
        and #7
        bne field_bright
        lda #STAR_DIM
        sta color
field_bright
        lda field_lo,x
        sta offset
        lda field_hi,x
        sta offset+1
        jsr plot_offset
        lda field_flags,x
        and #1
        beq field_next
        inc offset
        bne field_second
        inc offset+1
field_second
        jsr plot_offset
field_next
        inx
        cpx #STARFIELD_COUNT
        bne field_draw
        .endif
        rts
field_tick dta 0
