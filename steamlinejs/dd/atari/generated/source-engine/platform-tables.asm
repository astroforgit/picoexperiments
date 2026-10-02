; Generated from the assembled source service and symbol manifest.
SOURCE_LOCAL_EXIT_FROM_INTERRUPT = $ffcb
SOURCE_LOCAL_SET_STACK_TO_1FF = $ffbb
SOURCE_LOCAL_RETURN_FROM_STACK_SHENANIGANS = $e0e8
PLATFORM_SERVICE_COUNT = 33
platform_services_lo
        dta <platform_convert_audio
        dta <platform_write_tile_and_attribute_rewrite
        dta <platform_convert_nes_attributes_and_immediately_dma_them
        dta <platform_set_vram_increment_based_on_a_and_store
        dta <platform_set_vram_increment_to_1_and_store
        dta <platform_full_attribute_copy_from_0628
        dta <platform_dd_update_row_attributes
        dta <platform_dd_one_off_update
        dta <platform_dd_update_column_attributes
        dta <platform_change_write_increment_based_on_carry_flag
        dta <platform_set_vram_increment_to_32_no_store
        dta <platform_set_bottom_3_rows_of_attributes_to_55
        dta <platform_clear_bg_vm_jsl
        dta <platform_restore_ppu_control_from_a
        dta <platform_write_palette_data
        dta <platform_write_8_palette_entries_from_f1b6
        dta <platform_do_critical_snes_nmi_chores
        dta <platform_enable_nmi_and_store
        dta <platform_reset_2a03_audio
        dta <platform_disable_sprites_and_bg_and_store
        dta <platform_enable_bg_and_sprites_and_store
        dta <platform_disable_sprites_and_store
        dta <platform_enable_sprites_and_store
        dta <platform_disable_bg_and_store
        dta <platform_enable_bg_and_store
        dta <platform_augment_input
        dta <platform_disable_nmi_and_store
        dta <platform_handle_mmc1_control_register
        dta <platform_bankswitch_obj_chr_data
        dta <platform_change_ppu_vblank_status
        dta <platform_check_for_bg_chr_bankswap
        dta <platform_check_for_initial_obj_loads
        dta <platform_store_vmaddh_to_proper_range
platform_services_hi
        dta >platform_convert_audio
        dta >platform_write_tile_and_attribute_rewrite
        dta >platform_convert_nes_attributes_and_immediately_dma_them
        dta >platform_set_vram_increment_based_on_a_and_store
        dta >platform_set_vram_increment_to_1_and_store
        dta >platform_full_attribute_copy_from_0628
        dta >platform_dd_update_row_attributes
        dta >platform_dd_one_off_update
        dta >platform_dd_update_column_attributes
        dta >platform_change_write_increment_based_on_carry_flag
        dta >platform_set_vram_increment_to_32_no_store
        dta >platform_set_bottom_3_rows_of_attributes_to_55
        dta >platform_clear_bg_vm_jsl
        dta >platform_restore_ppu_control_from_a
        dta >platform_write_palette_data
        dta >platform_write_8_palette_entries_from_f1b6
        dta >platform_do_critical_snes_nmi_chores
        dta >platform_enable_nmi_and_store
        dta >platform_reset_2a03_audio
        dta >platform_disable_sprites_and_bg_and_store
        dta >platform_enable_bg_and_sprites_and_store
        dta >platform_disable_sprites_and_store
        dta >platform_enable_sprites_and_store
        dta >platform_disable_bg_and_store
        dta >platform_enable_bg_and_store
        dta >platform_augment_input
        dta >platform_disable_nmi_and_store
        dta >platform_handle_mmc1_control_register
        dta >platform_bankswitch_obj_chr_data
        dta >platform_change_ppu_vblank_status
        dta >platform_check_for_bg_chr_bankswap
        dta >platform_check_for_initial_obj_loads
        dta >platform_store_vmaddh_to_proper_range
platform_enable_nmi_and_store
        lda $10ff
        ora #128
        sta $10ff
        jmp platform_result_a
platform_disable_sprites_and_bg_and_store
        lda $10fe
        and #231
        sta $10fe
        jmp platform_result_a
platform_enable_bg_and_sprites_and_store
        lda $10fe
        ora #24
        sta $10fe
        jmp platform_result_a
platform_disable_sprites_and_store
        lda $10fe
        and #231
        sta $10fe
        jmp platform_result_a
platform_enable_sprites_and_store
        lda $10fe
        ora #24
        sta $10fe
        jmp platform_result_a
platform_disable_bg_and_store
        lda $10fe
        and #247
        sta $10fe
        jmp platform_result_a
platform_enable_bg_and_store
        lda $10fe
        ora #8
        sta $10fe
        jmp platform_result_a
platform_disable_nmi_and_store
        lda $10ff
        and #127
        sta $10ff
        jmp platform_result_a
