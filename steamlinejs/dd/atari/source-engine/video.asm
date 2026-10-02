; Full source tile/OAM preview backend. 256x240, two VBXE framebuffers.
; Uses all original CHR sets and live nametable/attribute/palette/OAM state.
; CPU $2000-$2fff is copied after loader handoff. This is a development backend:
; split HUD, NES sprite priority/scanline limits and real-time speed remain open.
        opt h-
        org $2000
        icl '../generated/source-engine/runtime-symbols.asm'
v_src = $bc
v_dst = $be
v_ptr = $c0

video_start
        ldx #23
        lda #0
video_clear_cpu_state
        sta vm_pc,x
        dex
        bpl video_clear_cpu_state
        lda #0
        sta platform_reg
        lda $90fe                 ; loader's detected VBXE page
        sta platform_reg+1
        lda #$8a                  ; MEMAC-A 16 KB at $8000, CPU only
        ldy #$5e
        sta (platform_reg),y
        lda #$80
        ldy #$5f
        sta (platform_reg),y
        jsr video_map_control
        ldx #19
video_copy_xdl
        lda video_xdls,x
        sta $7000,x
        dex
        bpl video_copy_xdl
        ldy #$50
        lda #0
        sta (platform_reg),y
        iny
        lda #$f1
        sta (platform_reg),y
        iny
        lda #7
        sta (platform_reg),y
        ldy #$41
        lda #0
        sta (platform_reg),y
        iny
        lda #$f0
        sta (platform_reg),y
        iny
        lda #7
        sta (platform_reg),y
        ldy #$40
        lda #1
        sta (platform_reg),y
        lda #255
        sta video_old_bg
        sta video_old_sprites
        lda #7
        sta video_back
        lda #6
        jsr video_restore_bank
        lda #$65
        sta vm_pc
        lda #$e1
        sta vm_pc+1
        lda #255
        sta vm_sp
        lda #$30
        sta vm_p
        lda #$10
        sta $10ff
        lda #6
        sta $10fe
        lda #$c0
        sta $1100
        lda #$53                  ; original warm entry, skips demonstration
        sta $1103
video_loop
        jsr video_input
        jsr platform_run_frame
        lda vm_fault
        bne video_fault
        jsr video_render
        jmp video_loop
video_fault
        ; A failed source operation is visible and stops; never skip it.
        lda #$46
        sta $d01a
        jmp video_fault

video_input
        lda $d300
        eor #255
        and #15
        tax
        lda video_joy,x
        sta platform_buttons
        lda $d010
        bne video_key
        lda platform_buttons
        ora #$80
        sta platform_buttons
video_key
        lda $d20f
        and #4
        bne video_console
        lda $d209
        and #63
        cmp #33                   ; Space = NES B, independent of joystick A
        bne video_console
        lda platform_buttons
        ora #$40
        sta platform_buttons
video_console
        lda $d01f
        and #1
        bne video_select
        lda platform_buttons
        ora #$10
        sta platform_buttons
video_select
        lda $d01f
        and #2
        bne video_second
        lda platform_buttons
        ora #$20
        sta platform_buttons
video_second
        lda $d300
        eor #255
        lsr
        lsr
        lsr
        lsr
        tax
        lda video_joy,x
        sta platform_buttons+1
        lda $d011
        bne video_second_b
        lda platform_buttons+1
        ora #$80
        sta platform_buttons+1
video_second_b
        lda $d01f
        and #4
        bne video_input_done
        lda platform_buttons+1
        ora #$40
        sta platform_buttons+1
video_input_done
        rts

video_render
        lda platform_bg_chr
        and #31
        cmp video_old_bg
        beq video_check_sprites
        sta video_old_bg
        lda #16
        sta video_atlas_bank
        lda #1
        sta video_color_base
        lda video_old_bg
        jsr video_expand
video_check_sprites
        lda platform_sprite_chr
        and #31
        cmp video_old_sprites
        beq video_ready
        sta video_old_sprites
        lda #20
        sta video_atlas_bank
        lda #17
        sta video_color_base
        lda video_old_sprites
        jsr video_expand
video_ready
        jsr video_map_control
        jsr video_palette
        jsr video_command_defaults
        lda #0
        sta video_command+15
        sta video_command+6
        sta video_command+7
        lda #1
        sta video_command+16
        lda #255
        sta video_command+12
        lda #239
        sta video_command+14
        jsr video_blit
        lda #255
        sta video_command+15
        lda #0
        sta video_command+16
        lda $10fe
        and #8
        beq video_sprites
        jsr video_background
video_sprites
        lda $10fe
        and #16
        beq video_present
        jsr video_oam
video_present
        jsr video_wait
        ; Keep the completed framebuffer hidden until a new vertical blank.
video_leave_vblank
        lda $d40b
        cmp #120
        bcs video_leave_vblank
video_wait_vblank
        lda $d40b
        cmp #120
        bcc video_wait_vblank
        lda video_back
        sec
        sbc #6
        beq video_xdl_zero
        lda #10
video_xdl_zero
        ldy #$41
        sta (platform_reg),y
        lda video_back
        eor #1
        sta video_back
        lda platform_bank
video_restore_bank
        pha
        lda #0
        ldy #$5d
        sta (platform_reg),y       ; expose fixed source bank in CPU RAM
        pla
        jmp platform_select_bank

video_map_control
        ldy #$5d
        lda #$9f                  ; MEMAC-B: VRAM $7c000 at CPU $4000
        sta (platform_reg),y
        rts
video_wait
        ldy #$53
video_busy
        lda (platform_reg),y
        bne video_busy
        rts
video_blit
        jsr video_wait
        lda video_back
        sta video_command+8
        ldx #20
video_copy_command
        lda video_command,x
        sta $7100,x
        dex
        bpl video_copy_command
        ldy #$53
        lda #1
        sta (platform_reg),y
        rts
video_command_defaults
        ldx #20
        lda #0
video_zero_command
        sta video_command,x
        dex
        bpl video_zero_command
        lda #8
        sta video_command+3
        lda #1
        sta video_command+5
        sta video_command+10
        sta video_command+11
        lda #255
        sta video_command+15
        rts

; Expand a raw two-plane CHR set into four palette variants. Input A=CHR set.
; Raw CHR lives at VRAM $20000; atlas destinations are $40000/$50000.
video_expand
        clc
        adc #32
        sta video_chr_bank
        and #$7c
        ora #$80
        ldy #$5f
        sta (platform_reg),y
        lda video_chr_bank
        and #3
        asl
        asl
        asl
        asl
        clc
        adc #$80
        sta video_chr_page
        lda #0
        sta video_variant
video_expand_variant
        lda video_atlas_bank
        clc
        adc video_variant
        ora #$80
        ldy #$5d
        sta (platform_reg),y
        lda #0
        sta v_src
        sta v_dst
        sta video_tile_count
        lda video_chr_page
        sta v_src+1
        lda #$40
        sta v_dst+1
        lda video_variant
        asl
        asl
        clc
        adc video_color_base
        sta video_pixel_base
video_expand_tile
        lda #0
        sta video_tile_row
video_expand_row
        ldy video_tile_row
        lda (v_src),y
        sta video_plane0
        tya
        ora #8
        tay
        lda (v_src),y
        sta video_plane1
        lda video_tile_row
        asl
        asl
        asl
        tay
        ldx #8
video_expand_pixel
        lda #0
        asl video_plane1
        rol
        asl video_plane0
        rol
        beq video_zero_pixel
        clc
        adc video_pixel_base
        jmp video_store_pixel
video_zero_pixel
        lda video_color_base
        cmp #17
        beq video_transparent
        lda #1                    ; universal background color
        bne video_store_pixel
video_transparent
        lda #0
video_store_pixel
        sta (v_dst),y
        iny
        dex
        bne video_expand_pixel
        inc video_tile_row
        lda video_tile_row
        cmp #8
        bne video_expand_row
        clc
        lda v_src
        adc #16
        sta v_src
        bcc video_expand_next_dst
        inc v_src+1
video_expand_next_dst
        clc
        lda v_dst
        adc #64
        sta v_dst
        bcc video_expand_next_tile
        inc v_dst+1
video_expand_next_tile
        inc video_tile_count
        bne video_expand_tile
        inc video_variant
        lda video_variant
        cmp #4
        jne video_expand_variant
        rts

video_palette
        ldy #$45
        lda #1
        sta (platform_reg),y
        ldy #$44
        lda #1
        sta (platform_reg),y
        lda #0
        sta video_palette_index
video_palette_color
        ldx video_palette_index
        lda $d800,x
        and #63
        tax
        lda video_red,x
        ldy #$46
        sta (platform_reg),y
        lda video_green,x
        iny
        sta (platform_reg),y
        lda video_blue,x
        iny
        sta (platform_reg),y
        inc video_palette_index
        lda video_palette_index
        cmp #32
        bne video_palette_color
        rts

video_background
        lda #0
        sta video_screen_y
video_bg_row
        lda #0
        sta video_screen_x
video_bg_tile
        lda $10ff
        and #3
        sta video_nt
        clc
        lda video_screen_x
        adc $10fd
        sta video_world_x
        bcc video_bg_x_ready
        lda video_nt
        eor #1
        sta video_nt
video_bg_x_ready
        clc
        lda video_screen_y
        adc $10fc
        sta video_world_y
        bcs video_bg_y_wrap
        cmp #240
        bcc video_bg_y_ready
video_bg_y_wrap
        sec
        sbc #240
        sta video_world_y
        lda video_nt
        eor #2
        sta video_nt
        lda video_world_y
        cmp #240
        bcs video_bg_y_wrap
video_bg_y_ready
        lda video_world_x
        and #7
        sta video_sub_x
        eor #7
        sta video_command+12
        lda video_screen_x
        eor #255
        cmp video_command+12
        bcs video_bg_width
        sta video_command+12
video_bg_width
        lda video_world_y
        and #7
        sta video_sub_y
        eor #7
        sta video_command+14
        lda #239
        sec
        sbc video_screen_y
        cmp video_command+14
        bcs video_bg_height
        sta video_command+14
video_bg_height
        lda video_world_x
        lsr
        lsr
        lsr
        sta video_col
        lda video_world_y
        lsr
        lsr
        lsr
        sta video_row
        and #7
        asl
        asl
        asl
        asl
        asl
        ora video_col
        sta v_ptr
        lda video_nt
        asl
        asl
        ora #$c0
        sta video_nt_page
        lda video_row
        lsr
        lsr
        lsr
        ora video_nt_page
        sta v_ptr+1
        ldy #0
        lda (v_ptr),y
        sta video_tile
        lda video_row
        lsr
        lsr
        asl
        asl
        asl
        sta video_temp
        lda video_col
        lsr
        lsr
        ora video_temp
        ora #$c0
        sta v_ptr
        lda video_nt_page
        ora #3
        sta v_ptr+1
        lda (v_ptr),y
        sta video_attr
        lda video_row
        and #2
        asl
        sta video_temp
        lda video_col
        and #2
        ora video_temp
        tax
        beq video_attr_ready
video_attr_shift
        lsr video_attr
        dex
        bne video_attr_shift
video_attr_ready
        lda video_attr
        and #3
        sta video_attr
        jsr video_tile_address
        lda #4
        sta video_command+2
        lda video_sub_y
        asl
        asl
        asl
        ora video_sub_x
        ora video_command
        sta video_command
        lda video_screen_x
        sta video_command+6
        lda video_screen_y
        sta video_command+7
        jsr video_blit
        sec
        lda video_screen_x
        adc video_command+12
        sta video_screen_x
        jcc video_bg_tile
        sec
        lda video_screen_y
        adc video_command+14
        sta video_screen_y
        cmp #240
        jcc video_bg_row
        rts

video_tile_address
        lda video_tile
        and #3
        ror
        ror
        ror
        and #$c0
        sta video_command
        lda video_tile
        lsr
        lsr
        sta video_command+1
        lda video_attr
        and #3
        asl
        asl
        asl
        asl
        asl
        asl
        ora video_command+1
        sta video_command+1
        rts

video_oam
        lda #1
        sta video_command+20
        lda #252
        sta video_oam_index
video_sprite
        ldx video_oam_index
        lda $1200,x
        clc
        adc #1
        jcs video_next_sprite
        cmp #240
        jcs video_next_sprite
        sta video_command+7
        lda #239
        sec
        sbc video_command+7
        cmp #8
        bcc video_sprite_height
        lda #7
video_sprite_height
        sta video_command+14
        lda $1203,x
        sta video_command+6
        eor #255
        cmp #8
        bcc video_sprite_width
        lda #7
video_sprite_width
        sta video_command+12
        lda $1201,x
        sta video_tile
        lda $1202,x
        sta video_attr
        jsr video_tile_address
        lda #5
        sta video_command+2
        lda #1
        sta video_command+5
        lda #8
        sta video_command+3
        lda #0
        sta video_command+4
        lda video_attr
        and #64
        beq video_sprite_vertical
        lda video_command
        ora #7
        sta video_command
        lda #255
        sta video_command+5
video_sprite_vertical
        lda video_attr
        and #128
        beq video_sprite_draw
        lda video_command
        ora #56
        sta video_command
        lda #$f8
        sta video_command+3
        lda #255
        sta video_command+4
video_sprite_draw
        jsr video_blit
video_next_sprite
        sec
        lda video_oam_index
        sbc #4
        sta video_oam_index
        jcs video_sprite
        rts

video_command :21 dta 0
video_xdls
        dta $62,$88,239,0,0,6,a(256),$10,$ff
        dta $62,$88,239,0,0,7,a(256),$10,$ff
video_joy dta 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
video_back dta 7
video_old_bg dta 255
video_old_sprites dta 255
video_chr_bank dta 0
video_chr_page dta 0
video_atlas_bank dta 0
video_color_base dta 0
video_pixel_base dta 0
video_variant dta 0
video_tile_count dta 0
video_tile_row dta 0
video_plane0 dta 0
video_plane1 dta 0
video_palette_index dta 0
video_screen_x dta 0
video_screen_y dta 0
video_world_x dta 0
video_world_y dta 0
video_nt dta 0
video_nt_page dta 0
video_col dta 0
video_row dta 0
video_sub_x dta 0
video_sub_y dta 0
video_tile dta 0
video_attr dta 0
video_temp dta 0
video_oam_index dta 0
        icl '../generated/source-engine/video-palette.asm'
video_end
        ert * > $3000
