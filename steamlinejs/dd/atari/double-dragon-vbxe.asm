; Double Dragon Atari adaptation. MADS, 6502, Atari XL/XE + VBXE FX 1.2x.
; CPU: loader $9000, runtime $3000-$7FFF, upload staging $8000,
;      MEMAC window $B000 (BASIC disabled while mapped). OS VBI retained, BASIC disabled.
; VRAM: framebuffers $00000/$10000; tile atlases $20000..$2ffff;
; panorama $30000..$61fff; fighters $62000..$7dfff;
; font $7e000 plus framebuffer padding; XDL/BCB $7f000/$7f100.
reg = $cb
src = $cd
dst = $cf
str = $d1
TITLE = 0
PLAY = 1
PAUSE = 2
OVER = 3
WIN = 4
MEMAC_WINDOW = $b000
MEMAC_CONFIG = $b8           ; 4K, CPU only, base $B000
        org $9000
upload_bank
        ; INIT returns to a disk/XEX loader. Preserve its scratch pointers and
        ; registers; never leave a MEMAC window over its buffers after returning.
        php
        pha
        txa
        pha
        tya
        pha
        ldx #5
upload_save_zp
        lda reg,x
        pha
        dex
        bpl upload_save_zp
        lda $d301
        pha
        cld
        jsr detect_vbxe
        bcc upload_restore
        lda $d301
        ora #2               ; BASIC ROM has priority over MEMAC at $B000
        sta $d301
        jsr disable_windows
        ; Quiesce an overlay/blitter left by a previous program.
        ldy #$40
        lda #0
        sta (reg),y
        ldy #$53
        sta (reg),y
        iny
        sta (reg),y
        ldy #$5e
        lda #MEMAC_CONFIG
        sta (reg),y
        iny
        lda upload_index
        ora #$80
        sta (reg),y
        mwa #$8000 src
        mwa #MEMAC_WINDOW dst
        ldx #16
        ldy #0
upload_page
        lda (src),y
        sta (dst),y
        iny
        bne upload_page
        inc src+1
        inc dst+1
        dex
        bne upload_page
        inc upload_index
        jsr disable_windows
upload_restore
        pla
        sta $d301            ; restore the loader's ROM/extended-RAM selection
        ldx #0
upload_restore_zp
        pla
        sta reg,x
        inx
        cpx #6
        bne upload_restore_zp
        pla
        tay
        pla
        tax
        pla
        plp
upload_done
        rts
upload_index dta 32
detected_page dta 0

; The FX manual defines compatible cores by CORE_VERSION=$10 and
; MINOR_REVISION bits 6..4=$20. Bit 7 denotes RAMBO, not a newer revision.
; Do not mistake a GTIA-only/old core at D600 for a compatible FX at D700.
detect_vbxe
        lda #0
        sta reg
        sta detected_page
        lda #$d6
        sta reg+1
        jsr check_fx_core
        bcs detected
        inc reg+1
        jsr check_fx_core
        bcc detection_done
detected
        lda reg+1
        sta detected_page
        sec
detection_done
        rts
check_fx_core
        ldy #$40
        lda (reg),y
        cmp #$10
        bne incompatible_core
        iny
        lda (reg),y
        and #$70
        cmp #$20
        beq compatible_core
incompatible_core
        clc
        rts
compatible_core
        sec
        rts

disable_windows
        lda #0
        ldy #$5f
        sta (reg),y          ; global MEMAC-A enable off before moving it
        dey
        sta (reg),y
        dey
        sta (reg),y          ; MEMAC-B must not shadow runtime $4000-$7fff
        rts

; Runs before the runtime segments are loaded, not after they have already
; been written into an inherited extended-RAM bank. The game owns all VRAM.
prepare_runtime
        php
        pha
        txa
        pha
        tya
        pha
        lda reg
        pha
        lda reg+1
        pha
        cld
        jsr detect_vbxe
        bcc prepare_ram
        jsr disable_windows
prepare_ram
        lda #$ff             ; OS on, BASIC/self-test/CPU+ANTIC expansion off
        sta $d301
        pla
        sta reg+1
        pla
        sta reg
        pla
        tay
        pla
        tax
        pla
        plp
        rts
        ert * > $9100
        icl 'generated/assets.asm'
        ini prepare_runtime

        org $3000
main
        cld
        lda #$ff
        sta $d301
        lda #0
        sta $22f
        sta $d400
        sta $2c8
        sta $2c6
        lda #14
        sta $2c5
        lda #$e0
        sta $2f4
        mwa #display_list $230
        lda #$22
        sta $22f
        lda #0
        sta reg
        lda detected_page
        sta reg+1
        cmp #$d6
        beq hardware_ready
        cmp #$d7
        beq hardware_ready
        ldx #39
missing_copy
        lda missing,x
        sta status,x
        dex
        bpl missing_copy
no_vbxe
        jmp no_vbxe
hardware_ready
        jsr disable_windows
        ldy #$54
        lda #0
        sta (reg),y          ; polling blitter; no inherited IRQ enable
        ldy #$40
        lda #0
        sta (reg),y
        jsr map_control
        ldx #39
copy_xdl
        lda xdls,x
        sta MEMAC_WINDOW,x
        dex
        bpl copy_xdl
        ldy #$50
        lda #0
        sta (reg),y
        iny
        lda #$f1
        sta (reg),y
        iny
        lda #7
        sta (reg),y
        ldy #$45
        lda #1
        sta (reg),y
        dey
        lda #0
        sta (reg),y
        mwa #palette src
        ldx #0
palette_loop
        ldy #0
        lda (src),y
        ldy #$46
        sta (reg),y
        ldy #1
        lda (src),y
        ldy #$47
        sta (reg),y
        ldy #2
        lda (src),y
        ldy #$48
        sta (reg),y
        clc
        lda src
        adc #3
        sta src
        bcc palette_next
        inc src+1
palette_next
        inx
        bne palette_loop
        ldy #$41
        lda #0
        sta (reg),y
        iny
        lda #$f0
        sta (reg),y
        iny
        lda #7
        sta (reg),y
        lda $d014
        and #14
        beq pal
        lda #60
        bne set_rate
pal     lda #50
set_rate
        sta rate
        lda #3
        sta $d20f
        lda #0
        sta $d208
        sta $d201
        sta $d203
        sta $d205
        sta $d207
        lda #255
        sta old_key
        lda #7
        sta old_console
        jsr restart
        lda #TITLE
        sta mode
        jsr render
        ldy #$40
        lda #3
        sta (reg),y
loop
        jsr input
        jsr frame_time
        jsr render
        jmp loop

        icl 'game.asm'
        icl 'world.asm'
        icl 'renderer.asm'
        icl 'generated/maps.asm'
        ert * > $8000
        run main
