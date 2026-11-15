; Standalone Atari XL/XE + VBXE 512K illustrated slideshow.
        opt h+
vb = $80
src = $82
dst = $84
xptr = $86
        org $2000
main
        sei
        lda #0
        sta $d40e
        sta $d400
        sta $022f
        jsr detect
        bcs supported
        jmp unsupported
supported
        lda $d301
        and #$fe
        ora #$82
        sta $d301
        lda #0
        sta $d20e
        sta $d01a
        sta $d01b
        sta $d01d
        sta $d208
        sta $d201
        sta $d203
        sta $d205
        sta $d207
        lda #3
        sta $d20f
        lda #<nmi
        sta $fffa
        lda #>nmi
        sta $fffb
        lda #<irq
        sta $fffe
        lda #>irq
        sta $ffff
        lda #$98
        ldy #$5e
        sta (vb),y
        lda #$fe
        ldy #$5f
        sta (vb),y
        lda #1
        ldy #$45
        sta (vb),y
        lda #0
        ldy #$44
        sta (vb),y
        ldx #0
palette_loop
        ldy #$46
        lda palette_0,x
        sta (vb),y
        iny
        lda palette_1,x
        sta (vb),y
        iny
        lda palette_2,x
        sta (vb),y
        inx
        bne palette_loop
        lda #6
        sta scroll_delay
        lda $d014
        cmp #1
        beq timing_ready
        inc scroll_delay
timing_ready
        lda #0
        sta scene
        jsr scene_start
        lda #1
        ldy #$40
        sta (vb),y
        lda #$40
        sta $d40e
        cli
main_loop
        lda frame
wait_frame
        cmp frame
        beq wait_frame
        jsr input
        lda paused
        bne main_loop
        inc divider
        lda divider
        cmp scroll_delay
        bcc main_loop
        lda #0
        sta divider
        jsr advance_scroll
        jmp main_loop
advance_scroll
        inc scroll
        bne check_end
        inc scroll+1
check_end
        ldx scene
        lda scroll+1
        cmp scroll_hi,x
        bcc update_scroll
        bne scene_next
        lda scroll
        cmp scroll_lo,x
        bcc update_scroll
scene_next
        inc scene
        lda scene
        cmp #5
        bcc scene_start
        lda #0
        sta scene
scene_start
        lda #0
        sta scroll
        sta scroll+1
        sta divider
        lda scene
        asl
        asl
        asl
        asl
        asl
        clc
        adc #17
        sta xptr
        lda #$90
        sta xptr+1
        jsr update_scroll
        lda xptr
        sec
        sbc #17
        ldy #$41
        sta (vb),y
        iny
        lda #$e0
        sta (vb),y
        iny
        lda #7
        sta (vb),y
        rts
update_scroll
        ldx scene
        clc
        lda text_mid,x
        adc scroll
        ldy #0
        sta (xptr),y
        lda text_hi,x
        adc scroll+1
        iny
        sta (xptr),y
        rts
; Rising-edge controls: fire/Return next; Space/C pause.
input
        lda $d010
        beq key_next
        lda $d20f
        and #4
        bne key_none
        lda $d209
        and #$3f
        cmp #$0c
        beq key_next
        cmp #$21
        beq key_pause
        cmp #$12
        beq key_pause
key_none
        lda #0
        beq key_handle
key_next
        lda #1
        bne key_handle
key_pause
        lda #2
key_handle
        cmp last_key
        beq key_done
        sta last_key
        cmp #1
        bne key_not_next
        jmp scene_next
key_not_next
        cmp #2
        bne key_done
        lda paused
        eor #1
        sta paused
key_done
        rts
nmi
        pha
        lda #0
        sta $d40f
        inc frame
        pla
        rti
irq     rti
frame dta 0
scene dta 0
scroll dta a(0)
divider dta 0
scroll_delay dta 6
paused dta 0
last_key dta 0
load_bank dta 0
; XEX INI: each 4K staging segment is copied into one VRAM bank.
upload_bank
        jsr detect
        bcc upload_done
        lda #0
        sta $022f
        lda #$98
        ldy #$5e
        sta (vb),y
        lda load_bank
        ora #$80
        ldy #$5f
        sta (vb),y
        mwa #$a000 src
        mwa #$9000 dst
        ldx #16
        ldy #0
upload_byte
        lda (src),y
        sta (dst),y
        iny
        bne upload_byte
        inc src+1
        inc dst+1
        dex
        bne upload_byte
        inc load_bank
        lda #0
        ldy #$5f
        sta (vb),y
upload_done
        rts
detect
        lda #0
        sta vb
        lda #$d6
        sta vb+1
        ldy #$40
        lda (vb),y
        cmp #$10
        beq found
        inc vb+1
        lda (vb),y
        cmp #$10
        beq found
        clc
        rts
found   sec
        rts
unsupported
        cli
        lda #$22
        sta $022f
        ldx #0
        lda #9
        sta $0342,x
        mwa #error_text $0344,x
        mwa #error_length $0348,x
        jsr $e456
        jmp *
error_text dta $7d,c'DUSIOLEK INTRO requires Atari XL/XE + VBXE (512K).',$9b
error_length = *-error_text
basic_off
        lda $d301
        ora #2
        sta $d301
        lda #0
        sta $022f
        rts
        icl 'gen/tables.asm' 
        .if * > $9000
        .error "Intro code overlaps MEMAC window"
        .endif
        ini basic_off
        icl 'gen/loads.asm'
        run main
