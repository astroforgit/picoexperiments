; Source-address bridge, NMOS 6502. No ROM data/pointer guessing.
; Guest $0000-$0fff -> host $1000-$1fff; source stack -> $1100-$11ff.
; Guest $8000-$bfff -> host $8000-$bfff (native bank window).
; Guest $c000-$ffff -> host $4000-$7fff, avoiding Atari hardware.
; Host owns ZP $a0-$b7, its hardware stack and $2000-$3fff.
; A/X/Y/P/SP/PC below are the source CPU state, not host registers.
; The caller owns interrupts; guest CLI/SEI never change host IRQ state.
; Unsupported IO/opcodes report an explicit fault and return to the caller.
vm_pc = $a0
vm_ea = $a2
vm_ptr = $a4
vm_a = $a6
vm_x = $a7
vm_y = $a8
vm_p = $a9
vm_sp = $aa
vm_opcode = $ab
vm_temp = $ac
vm_temp_hi = $ad
vm_operand = $ae
vm_mode = $af
vm_cycles = $b0
vm_fault = $b1
vm_fault_pc = $b2
vm_host_sp = $b4
vm_result_p = $b5
vm_branch_mask = $b6
vm_branch_value = $b7
        .ifndef SOURCE_PLATFORM
SOURCE_PLATFORM = 0
        .endif
        .ifndef CPU_BASE
CPU_BASE = $2000
        .endif

        opt h-
        org CPU_BASE
vm_step
        tsx
        stx vm_host_sp
        lda #0
        sta vm_fault
        lda vm_pc
        sta vm_fault_pc
        lda vm_pc+1
        sta vm_fault_pc+1
        .if SOURCE_PLATFORM
        lda #0
        sta vm_cycles
        jsr platform_trap
        bcc vm_regular_instruction
        rts
vm_regular_instruction
        .endif
        jsr vm_fetch
        tax
        stx vm_opcode
        lda vm_cycle_table,x
        sta vm_cycles
        lda vm_mode_table,x
        sta vm_mode
        tax
        lda vm_address_lo,x
        sta vm_address_call+1
        lda vm_address_hi,x
        sta vm_address_call+2
vm_address_call
        jsr $ffff
        ldx vm_opcode
        lda vm_handler_lo,x
        sta vm_operation_jump+1
        lda vm_handler_hi,x
        sta vm_operation_jump+2
vm_operation_jump
        jmp $ffff

vm_fetch
        lda vm_pc
        sta vm_ea
        lda vm_pc+1
        sta vm_ea+1
        jsr vm_read
        inc vm_pc
        bne vm_fetch_done
        inc vm_pc+1
vm_fetch_done
        rts

vm_read
        .if SOURCE_PLATFORM
        lda vm_ea+1
        cmp #$10
        bcc vm_read_mapped
        cmp #$80
        bcs vm_read_mapped
        jmp platform_io_read
vm_read_mapped
        .endif
        jsr vm_translate
        ldy #0
        lda (vm_ptr),y
        rts
vm_write
        pha
        lda vm_ea+1
        cmp #$10
        .if SOURCE_PLATFORM
        bcc vm_write_mapped
        cmp #$80
        bcs vm_bad_write
        pla
        jmp platform_io_write
vm_write_mapped
        .else
        bcs vm_bad_write
        .endif
        jsr vm_translate
        pla
        ldy #0
        sta (vm_ptr),y
        rts
vm_translate
        lda vm_ea
        sta vm_ptr
        lda vm_ea+1
        cmp #$10
        bcc vm_ram
        cmp #$80
        bcc vm_bad_read
        cmp #$c0
        bcc vm_pointer_ready
        sec
        sbc #$80
        bne vm_pointer_ready
vm_ram
        clc
        adc #$10
vm_pointer_ready
        sta vm_ptr+1
        rts
vm_bad_read
        lda #2
        bne vm_fail
vm_bad_write
        lda #3
        bne vm_fail
vm_illegal
        lda #1
vm_fail
        sta vm_fault
        ; Unwind only the host calls belonging to this instruction. Keep
        ; the caller's actual return address, independent of guest SP.
        ldx vm_host_sp
        txs
        rts

vm_mode_imp
        rts
vm_mode_acc
        lda vm_a
        sta vm_operand
        rts
vm_mode_imm
vm_mode_rel
        jsr vm_fetch
        sta vm_operand
        rts
vm_mode_zpg
        jsr vm_fetch
        sta vm_ea
        lda #0
        sta vm_ea+1
        rts
vm_mode_zpx
        jsr vm_mode_zpg
        clc
        lda vm_ea
        adc vm_x
        sta vm_ea
        rts
vm_mode_zpy
        jsr vm_mode_zpg
        clc
        lda vm_ea
        adc vm_y
        sta vm_ea
        rts
vm_mode_abs
        jsr vm_fetch
        sta vm_temp
        jsr vm_fetch
        sta vm_ea+1
        lda vm_temp
        sta vm_ea
        rts
vm_mode_abx
        jsr vm_mode_abs
        lda vm_x
        jmp vm_add_index
vm_mode_aby
        jsr vm_mode_abs
        lda vm_y
vm_add_index
        clc
        adc vm_ea
        sta vm_ea
        bcc vm_index_done
        inc vm_ea+1
        ldx vm_opcode
        lda vm_extra_table,x
        clc
        adc vm_cycles
        sta vm_cycles
vm_index_done
        rts
vm_mode_inx
        jsr vm_mode_zpx
        jmp vm_indirect_zp
vm_mode_iny
        jsr vm_mode_zpg
        jsr vm_indirect_zp
        lda vm_y
        jmp vm_add_index
vm_indirect_zp
        jsr vm_read
        sta vm_temp
        inc vm_ea               ; source ZP pointer wraps within page zero
        jsr vm_read
        sta vm_ea+1
        lda vm_temp
        sta vm_ea
        rts
vm_mode_ind
        jsr vm_mode_abs
        ; NMOS JMP ($xxff) reads its high byte from $xx00.
        jmp vm_indirect_zp

vm_native_operation
        ldx vm_opcode
        lda vm_access_table,x
        and #1
        beq vm_run_native
        lda vm_mode
        cmp #3                 ; imp/acc/imm have no memory read here
        bcc vm_run_native
        jsr vm_read
        sta vm_operand
vm_run_native
        ldx vm_opcode
        lda vm_native_table,x
        sta vm_native_thunk
        ; Implied instructions occupy one byte; the remaining bytes must be
        ; NOPs, not the operand address interpreted as accidental opcodes.
        lda vm_mode
        bne vm_native_absolute
        lda #$ea
        sta vm_native_thunk+1
        sta vm_native_thunk+2
        bne vm_native_ready
vm_native_absolute
        lda #<vm_operand
        sta vm_native_thunk+1
        lda #>vm_operand
        sta vm_native_thunk+2
vm_native_ready
        lda vm_p
        and #$e3               ; NES arithmetic ignores decimal mode
        ora #$24               ; keep host IRQ masked, U set
        pha
        lda vm_a
        ldx vm_x
        ldy vm_y
        plp
vm_native_thunk
        lda vm_operand
        nop                    ; thunk is patched to exactly three bytes
        sta vm_a
        stx vm_x
        sty vm_y
        php
        pla
        and #$c3
        sta vm_result_p
        lda vm_p
        and #$3c
        ora vm_result_p
        sta vm_p
        ldx vm_opcode
        lda vm_access_table,x
        and #2
        beq vm_native_done
        lda vm_mode
        cmp #1
        bne vm_store_memory
        lda vm_operand
        sta vm_a
        rts
vm_store_memory
        lda vm_operand
        jsr vm_write
vm_native_done
        rts

vm_push
        ldx vm_sp
        sta $1100,x
        dec vm_sp
        rts
vm_pop
        inc vm_sp
        ldx vm_sp
        lda $1100,x
        rts
vm_push_pc
        lda vm_pc+1
        jsr vm_push
        lda vm_pc
        jmp vm_push
vm_pop_pc
        jsr vm_pop
        sta vm_pc
        jsr vm_pop
        sta vm_pc+1
        rts
vm_inc_pc
        inc vm_pc
        bne vm_pc_ready
        inc vm_pc+1
vm_pc_ready
        rts
vm_jsr
        lda vm_pc
        bne vm_return_low
        dec vm_pc+1
vm_return_low
        dec vm_pc
        jsr vm_push_pc
vm_jmp
        lda vm_ea
        sta vm_pc
        lda vm_ea+1
        sta vm_pc+1
        rts
vm_rts
        jsr vm_pop_pc
        jmp vm_inc_pc
vm_rti
        jsr vm_plp
        jmp vm_pop_pc
vm_pha
        lda vm_a
        jmp vm_push
vm_php
        lda vm_p
        ora #$30
        jmp vm_push
vm_pla
        jsr vm_pop
        sta vm_a
        jmp vm_set_nz
vm_plp
        jsr vm_pop
        ora #$30
        sta vm_p
        rts
vm_tsx
        lda vm_sp
        sta vm_x
        jmp vm_set_nz
vm_txs
        lda vm_x
        sta vm_sp
        rts
vm_set_nz
        sta vm_temp
        lda vm_p
        and #$7d
        sta vm_p
        lda vm_temp
        beq vm_set_zero
        and #$80
        ora vm_p
        sta vm_p
        rts
vm_set_zero
        lda vm_p
        ora #2
        sta vm_p
        rts
vm_cli
        lda vm_p
        and #$fb
        sta vm_p
        rts
vm_sei
        lda vm_p
        ora #4
        sta vm_p
        rts
vm_cld
        lda vm_p
        and #$f7
        sta vm_p
        rts
vm_sed
        lda vm_p
        ora #8
        sta vm_p
        rts

vm_brk
        jsr vm_inc_pc
        jsr vm_push_pc
        lda vm_p
        ora #$10
        sta vm_p
        jsr vm_php
        jsr vm_sei
        lda #$fe
        bne vm_vector
; Callable asynchronous source NMI: A/X/Y unchanged, original stack used.
vm_nmi
        jsr vm_push_pc
        lda vm_p
        and #$ef
        sta vm_p
        ora #$20
        jsr vm_push
        jsr vm_sei
        lda #$fa
vm_vector
        sta vm_ea
        lda #$ff
        sta vm_ea+1
        jsr vm_indirect_zp
        lda #7
        sta vm_cycles
        jmp vm_jmp

vm_bcc
        lda #1
        ldx #0
        beq vm_branch
vm_bcs
        lda #1
        tax
        bne vm_branch
vm_beq
        lda #2
        tax
        bne vm_branch
vm_bne
        lda #2
        ldx #0
        beq vm_branch
vm_bmi
        lda #$80
        tax
        bne vm_branch
vm_bpl
        lda #$80
        ldx #0
        beq vm_branch
vm_bvs
        lda #$40
        tax
        bne vm_branch
vm_bvc
        lda #$40
        ldx #0
vm_branch
        sta vm_branch_mask
        stx vm_branch_value
        and vm_p
        cmp vm_branch_value
        bne vm_branch_done
        inc vm_cycles
        lda vm_pc+1
        sta vm_temp_hi
        ldx #0
        lda vm_operand
        bpl vm_branch_positive
        dex
vm_branch_positive
        clc
        adc vm_pc
        sta vm_pc
        txa
        adc vm_pc+1
        sta vm_pc+1
        cmp vm_temp_hi
        beq vm_branch_done
        inc vm_cycles
vm_branch_done
        rts

        icl '../generated/source-engine/cpu-tables.asm'
        .if SOURCE_PLATFORM
        icl 'platform.asm'
        .endif
vm_end
        ert * > $4000
