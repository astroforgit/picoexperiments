; Slow clouds and an occasional downward meteor. Independent of fishing RNG.
reset_sky
        lda random_seed
        eor #$63
        ora #1
        sta sky_seed
        lda #160
        sta meteor_wait
        lda #0
        sta meteor_life
        sta sky_ticks
        ldx #2
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
update_sky
        inc sky_ticks
        lda sky_ticks
        and #7
        bne meteor_tick
        ldx #2
cloud_move
        lda cloud_x,x
        clc
        adc cloud_dir,x
        sta cloud_x,x
        cmp #224
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
        lda sky_ticks
        and #3
        bne sky_done
        dec meteor_wait
        bne sky_done
        jsr sky_random
        and #127
        clc
        adc #24
        sta meteor_x
        lda #34
        sta meteor_y
        lda #24
        sta meteor_life
        jsr sky_random
        ora #128
        sta meteor_wait
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
; Three 96x24 wisps bounce gently within the full 320px sky.
draw_clouds
        ldx #2
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
        dta 0,$40,1,a(96),1,0,0,2,a(320),1,a(95),23,$ff,0,0,0,0,1
cloud_row_lo dta <(43*320),<(81*320),<(113*320)
cloud_row_hi dta >(43*320),>(81*320),>(113*320)
cloud_start dta 8,119,207
cloud_initial_dir dta 1,255,1
cloud_x :3 dta 0
cloud_dir :3 dta 0
cloud_index dta 0
sky_ticks dta 0
sky_seed dta 1
meteor_wait dta 160
meteor_life dta 0
meteor_x dta 0
meteor_y dta 0
meteor_tail dta 0
