; Sven workshop adaptation, MADS / Atari XL/XE + VBXE FX.
; VRAM: 00000/10000 framebuffers, 20000 meadow, 2FA00 sprites,
; Sprites are 56x32 at a common 40% scale.
; 7F000 XDLs, 7F100 blitter command. CPU window: 9000-9FFF.
reg = $cb
src = $cd
dst = $cf
MODE_READY = 0
MODE_PLAY = 1
MODE_WIN = 2
MODE_LOSE = 3
MODE_PAUSE = 4
SPRITE_W = 56
SPRITE_H = 32
SPRITE_SIZE = SPRITE_W*SPRITE_H
SPRITE_COUNT = 38
        org $2000
upload_bank
        cld
        lda #0
        sta reg
        sta reg+1
        lda $d640
        cmp #$10
        beq detected6
        lda $d740
        cmp #$10
        bne upload_done
        lda #$d7
        bne detected
detected6
        lda #$d6
detected
        sta reg+1
        sta detected_page
        ldy #$5e
        lda #$98
        sta (reg),y
        ldy #$5f
        lda upload_index
        ora #$80
        sta (reg),y
        mwa #$8000 src
        mwa #$9000 dst
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
upload_done
        rts
upload_index dta 32
detected_page dta 0
        icl 'generated/assets.asm'

        org $3000
main
        cld
        lda $d301
        ora #2
        sta $d301
        lda #0
        sta $22f
        sta $d400
        sta $2c8
        sta $2c6
        lda #14
        sta $2c5
        mwa #display_list $230
        lda #$e0
        sta $2f4
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
        mwa #missing src
        jsr message
no_vbxe
        jmp no_vbxe
hardware_ready
        ldy #$5e
        lda #$98
        sta (reg),y
        ldy #$40
        lda #0
        sta (reg),y
        jsr map_control
        ldx #39
copy_xdl
        lda xdls,x
        sta $9000,x
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
        ldy #$44
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
        and #$0e                   ; GTIA PAL=$01, NTSC=$0E/$0F; ignore bit zero
        beq pal
        lda #60
        bne rate_ready
pal     lda #50
rate_ready
        sta rate
        lda #1
        sta sound_enabled
        lda #7
        sta old_console
        lda #255
        sta old_key
        lda #0
        sta $d208
        sta $d201
        sta $d203
        sta $d205
        sta $d207
        lda #3
        sta $d20f
        jsr restart
        lda #MODE_READY
        sta mode
        jsr refresh_message
        jsr render
        ldy #$40
        lda #3
        sta (reg),y
loop
        jsr poll_input
        jsr advance_time
        jsr render
        jmp loop

        icl 'game.asm'
        icl 'renderer.asm'
        ert * > $8000
        ert $2fa00+SPRITE_COUNT*SPRITE_SIZE > $7f000
        run main
