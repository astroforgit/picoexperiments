; Native platform state for the original source-address engine.
; Source PPU nametables -> CPU $c000-$cfff, palette -> $d800-$d8ff.
; Requires Atari OS ROM off. VBXE PRG window is 16 KB at $8000.
; Services update source video state; a renderer consumes it separately.
platform_reg = $b8
platform_ptr = $ba

platform_trap
        lda vm_pc+1
        cmp #$10
        jne platform_fixed_traps
        lda vm_pc
        and #3
        jne platform_no_trap
        lda vm_pc
        lsr
        lsr
        cmp #PLATFORM_SERVICE_COUNT
        jcs platform_no_trap
        tax
        lda platform_services_lo,x
        sta platform_service_call+1
        lda platform_services_hi,x
        sta platform_service_call+2
        jsr vm_rts
        lda vm_pc
        sta platform_return
        lda vm_pc+1
        sta platform_return+1
platform_service_call
        jsr $ffff
        lda platform_return
        sta vm_pc
        lda platform_return+1
        sta vm_pc+1
        sec
        rts
platform_fixed_traps
        lda vm_pc+1
        cmp #$fe
        bne platform_check_audio
        lda vm_pc
        cmp #$ee
        bne platform_no_trap
        lda vm_a
        and #15
        jsr platform_select_bank
        lda $10ff
        jsr platform_result_a
        jmp platform_finish_trap
platform_check_audio
        cmp #$fb
        bne platform_check_barrier
        lda vm_pc
        cmp #$f8
        beq platform_finish_trap
        cmp #$e1
        bne platform_no_trap
        lda vm_a
        beq platform_finish_trap
        cmp #$1f
        bcs platform_finish_trap
        sta platform_effect
        inc platform_effect_serial
        jmp platform_finish_trap
platform_check_barrier
        cmp #$fc
        bne platform_check_snes
        lda vm_pc
        cmp #$80
        bne platform_no_trap
        lda #1
        sta platform_frame_wait
        lda $10ff
        and #$7f
        sta $10ff
        lda vm_p
        and #$bf
        ora #4
        sta vm_p
        lda vm_a
        jsr vm_set_nz
platform_finish_trap
        jsr vm_rts
        sec
        rts
platform_no_trap
        clc
        rts
platform_check_snes
        lda vm_pc
        cmp #<SOURCE_LOCAL_SET_STACK_TO_1FF
        bne platform_check_exit
        lda vm_pc+1
        cmp #>SOURCE_LOCAL_SET_STACK_TO_1FF
        bne platform_check_exit
        lda #255
        sta vm_sp
        sta vm_x
        jsr vm_set_nz
        lda #<SOURCE_LOCAL_RETURN_FROM_STACK_SHENANIGANS
        sta vm_pc
        lda #>SOURCE_LOCAL_RETURN_FROM_STACK_SHENANIGANS
        sta vm_pc+1
        sec
        rts
platform_check_exit
        lda vm_pc
        cmp #<SOURCE_LOCAL_EXIT_FROM_INTERRUPT
        bne platform_check_stz
        lda vm_pc+1
        cmp #>SOURCE_LOCAL_EXIT_FROM_INTERRUPT
        bne platform_check_stz
        jsr vm_pop
        sta vm_y
        jsr vm_pop
        sta vm_x
        jsr vm_pop
        sta vm_a
        jsr vm_pop
        ora #$20
        sta vm_p
        jsr vm_pop_pc
        sec
        rts
platform_check_stz
        lda vm_pc
        cmp #$65
        bne platform_no_trap
        lda vm_pc+1
        cmp #$ed
        bne platform_no_trap
        jsr vm_fetch
        cmp #$9c
        jne vm_illegal
        jsr vm_mode_abs
        lda #0
        jsr vm_write
        lda #4
        sta vm_cycles
        sec
        rts

platform_result_a
        sta vm_a
        jmp vm_set_nz
platform_carry
        lda vm_p
        ora #1
        sta vm_p
        rts
platform_select_bank
        cmp #8
        jcs vm_illegal
        sta platform_bank
        sta $1104
        asl
        asl
        ora #$80
        ldy #$5f
        sta (platform_reg),y
        rts

platform_io_read
        lda vm_ea+1
        cmp #$42
        bne platform_read_ppu
        lda vm_ea
        cmp #$10
        jne vm_bad_read
        lda #$80
        rts
platform_read_ppu
        cmp #$21
        bne platform_read_delay
        lda vm_ea
        cmp #$39
        jne vm_bad_read
        jsr platform_ppu_pointer
        ldy #0
        lda (platform_ptr),y
        pha
        jsr platform_ppu_advance
        pla
        rts
platform_read_delay
        cmp #$25
        jne vm_bad_read
        lda vm_ea
        cmp #$15
        jne vm_bad_read
        ; The supplied engine reads this otherwise unused SNES RAM location.
        lda #0
        rts
platform_io_write
        pha
        lda vm_ea+1
        cmp #$21
        jne vm_bad_write
        lda vm_ea
        cmp #$16
        beq platform_ppu_low
        cmp #$17
        beq platform_ppu_high
        cmp #$18
        jne vm_bad_write
        pla
        jmp platform_ppu_write
platform_ppu_low
        pla
        sta platform_ppu_address
        rts
platform_ppu_high
        pla
        and #$3f
        sta platform_ppu_address+1
        rts
platform_ppu_pointer
        lda platform_ppu_address
        sta platform_ptr
        lda platform_ppu_address+1
        cmp #$3f
        beq platform_palette_pointer
        cmp #$20
        jcc vm_bad_write
        cmp #$30
        jcs vm_bad_write
        clc
        adc #$a0
        sta platform_ptr+1
        rts
platform_palette_pointer
        lda #$d8
        sta platform_ptr+1
        rts
platform_ppu_write
        pha
        jsr platform_ppu_pointer
        pla
        ldy #0
        sta (platform_ptr),y
        inc platform_video_serial
platform_ppu_advance
        clc
        lda platform_ppu_address
        adc platform_increment
        sta platform_ppu_address
        bcc platform_ppu_done
        inc platform_ppu_address+1
        lda platform_ppu_address+1
        and #$3f
        sta platform_ppu_address+1
platform_ppu_done
        rts

platform_restore_ppu_control_from_a
platform_change_ppu_vblank_status
        lda vm_a
        sta $10ff
        rts
platform_augment_input
        lda platform_buttons
        sta $10f5
        lda platform_buttons+1
        sta $10f6
        lda #0
        sta $1000
        sta $1001
        sta vm_x
        jsr platform_result_a
        lda vm_p
        and #$fe
        sta vm_p
        rts
platform_set_vram_increment_based_on_a_and_store
        lda $1015
        and #4
        jmp platform_set_increment
platform_change_write_increment_based_on_carry_flag
        lda vm_p
        and #1
        asl
        asl
        jmp platform_set_increment
platform_set_vram_increment_to_32_no_store
        lda #32
        sta platform_increment
        lda $10ff
        ora #4
        jmp platform_result_a
platform_set_vram_increment_to_1_and_store
        lda #0
platform_set_increment
        sta platform_temp
        ldx #1
        cmp #0
        beq platform_increment_ready
        ldx #32
platform_increment_ready
        stx platform_increment
        lda $10ff
        and #$fb
        ora platform_temp
        sta $10ff
        jmp platform_result_a
platform_bankswitch_obj_chr_data
        lda vm_a
        sta platform_sprite_chr
        rts
platform_check_for_bg_chr_bankswap
        lda $1891
        sta platform_bg_chr
        rts
platform_store_vmaddh_to_proper_range
        lda vm_a
        and #63
        sta platform_ppu_address+1
        rts
platform_handle_mmc1_control_register
        lda $1108
        cmp #$1f
        jne vm_illegal
        rts
platform_dd_update_row_attributes
        lda #0
        sta $101c
        jmp platform_result_a
platform_dd_one_off_update
        jsr vm_pop
        sta $101f
        jsr vm_pop
        sta $101e
        jmp platform_result_a
platform_dd_update_column_attributes
        lda vm_x
        cmp #30
        bcc platform_column_ready
        lda #0
        sta vm_x
        inc $101f
platform_column_ready
        sta $101e
        dec $1008
        lda $1008
        jmp vm_set_nz
platform_clear_bg_vm_jsl
        lda #$c0
        sta platform_ptr+1
        lda #0
        sta platform_ptr
        ldy #0
        ldx #12
platform_clear_page
        sta (platform_ptr),y
        iny
        bne platform_clear_page
        inc platform_ptr+1
        dex
        bne platform_clear_page
        rts
platform_full_attribute_copy_from_0628
        ldx #63
platform_attribute_copy
        lda $1628,x
        sta $c3c0,x
        lda $1668,x
        sta $cbc0,x
        dex
        bpl platform_attribute_copy
        rts
platform_set_bottom_3_rows_of_attributes_to_55
        lda #$55
        ldx #23
platform_bottom_attributes
        sta $cbe8,x
        dex
        bpl platform_bottom_attributes
        rts
platform_write_palette_data
        lda $1002
        sta platform_source
        lda $1003
        sta platform_source+1
        lda $18a7
        sta platform_palette_offset
        lda $18a6
        sta platform_count
        beq platform_palette_done
platform_palette_loop
        jsr platform_source_read
        ldx platform_palette_offset
        sta $d800,x
        inc platform_palette_offset
        dec platform_count
        bne platform_palette_loop
platform_palette_done
        jmp platform_carry
platform_write_8_palette_entries_from_f1b6
        ldx #7
platform_eight_colors
        lda $71b6,x
        sta $d810,x
        dex
        bpl platform_eight_colors
        rts
platform_write_tile_and_attribute_rewrite
        lda vm_x
        sta vm_ea
        lda #$80
        sta vm_ea+1
        jsr vm_read
        sta platform_source
        inc vm_ea
        bne platform_stream_word
        inc vm_ea+1
platform_stream_word
        jsr vm_read
        sta platform_source+1
platform_stream_record
        jsr platform_source_read
        sta platform_count
        beq platform_stream_control
        jsr platform_source_read
        sta platform_length
        jeq vm_illegal
        lda platform_source
        sta platform_repeat
        lda platform_source+1
        sta platform_repeat+1
platform_repeat_record
        lda platform_repeat
        sta platform_source
        lda platform_repeat+1
        sta platform_source+1
        lda platform_length
        sta platform_left
platform_stream_pixels
        jsr platform_source_read
        jsr platform_ppu_write
        dec platform_left
        bne platform_stream_pixels
        dec platform_count
        bne platform_repeat_record
        jmp platform_stream_record
platform_stream_control
        jsr platform_source_read
        beq platform_stream_end
        and #63
        sta platform_ppu_address+1
        jsr platform_source_read
        sta platform_ppu_address
        jsr platform_source_read
        and #1
        beq platform_stream_horizontal
        lda #32
        bne platform_stream_increment
platform_stream_horizontal
        lda #1
platform_stream_increment
        sta platform_increment
        jmp platform_stream_record
platform_stream_end
        lda $1016
        cmp #5
        bcc platform_stream_done
        cmp #13
        bcs platform_stream_done
        clc
        adc #12
        sta $1016
        tax
        lda $4240,x
        jsr platform_select_bank
        ldx $1016
        lda $420d,x
        sta vm_ea
        lda #$80
        sta vm_ea+1
        jsr vm_read
        sta platform_source
        inc vm_ea
        jsr vm_read
        sta platform_source+1
        jmp platform_stream_record
platform_stream_done
        rts
platform_source_read
        lda platform_source
        sta vm_ea
        lda platform_source+1
        sta vm_ea+1
        jsr vm_read
        pha
        inc platform_source
        bne platform_source_done
        inc platform_source+1
platform_source_done
        pla
        rts

; These calls invalidate renderer state in place of SNES-specific DMA/caches.
; The native renderer must consume the state before displaying a frame.
platform_convert_nes_attributes_and_immediately_dma_them
platform_check_for_initial_obj_loads
platform_do_critical_snes_nmi_chores
        inc platform_video_serial
        rts
platform_reset_2a03_audio
        lda #0
        sta platform_effect
        rts
platform_convert_audio
        ; Source audio is intentionally intercepted at FBE1/FBF8. Accidentally
        ; entering its sequencer is an error, not an implemented audio backend.
        jmp vm_illegal

; Run to the original virtual frame boundary. Host speed is independent: this
; maintains source ordering, but makes no real-time Atari performance claim.
platform_run_frame
        jsr vm_step
        lda vm_fault
        bne platform_frame_done
        lda platform_frame_wait
        bne platform_barrier_frame
        sec
        lda platform_budget
        sbc vm_cycles
        sta platform_budget
        lda platform_budget+1
        sbc #0
        sta platform_budget+1
        bcc platform_timed_frame
        ora platform_budget
        bne platform_run_frame
platform_timed_frame
        clc
        lda platform_budget
        adc #<29780
        sta platform_budget
        lda platform_budget+1
        adc #>29780
        sta platform_budget+1
        lda $10ff
        bpl platform_count_frame
        jsr vm_nmi
        sec
        lda platform_budget
        sbc #7
        sta platform_budget
        lda platform_budget+1
        sbc #0
        sta platform_budget+1
        lda $1100
        and #$c0
        beq platform_bad_nmi
        ldx #$b1
        cmp #$40
        beq platform_dispatch_nmi
        ldx #$c5
        cmp #$80
        beq platform_dispatch_nmi
        ldx #$ff
platform_dispatch_nmi
        stx vm_pc
        lda #$e0
        sta vm_pc+1
        jmp platform_count_frame
platform_barrier_frame
        lda #0
        sta platform_frame_wait
        lda #<29780
        sta platform_budget
        lda #>29780
        sta platform_budget+1
platform_count_frame
        inc platform_frames
        bne platform_frame_done
        inc platform_frames+1
platform_frame_done
        rts
platform_bad_nmi
        lda #4
        sta vm_fault
        rts

platform_run_call
        lda vm_pc+1
        cmp #$0f
        bne platform_call_step
        lda vm_pc
        cmp #$ff
        beq platform_call_done
platform_call_step
        jsr vm_step
        lda vm_fault
        beq platform_run_call
platform_call_done
        rts

platform_bank dta 6
platform_buttons dta 0,0
platform_bg_chr dta 0
platform_sprite_chr dta 0
platform_effect dta 0
platform_effect_serial dta 0
platform_video_serial dta 0
platform_frame_wait dta 0
platform_ppu_address dta a(0)
platform_increment dta 1
platform_return dta a(0)
platform_source dta a(0)
platform_repeat dta a(0)
platform_count dta 0
platform_length dta 0
platform_left dta 0
platform_palette_offset dta 0
platform_temp dta 0
platform_budget dta a(29780)
platform_frames dta a(0)

        icl '../generated/source-engine/platform-tables.asm'
