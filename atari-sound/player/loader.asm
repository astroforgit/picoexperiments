; DOS / emulator H: loader for the PMS music format. Playback is memory resident.
        icl 'player.asm'
        org $3000
loader  cld
        lda #<prompt
        ldy #>prompt
        jsr print
        lda #5
        sta $342
        lda #<filename
        sta $344
        lda #>filename
        sta $345
        lda #63
        sta $348
        lda #0
        sta $349
        tax
        jsr $e456
        tya
        bmi load_error
        ldx #$10
        lda #3
        sta $342,x
        lda #4
        sta $34a,x
        lda #0
        sta $34b,x
        lda #<filename
        sta $344,x
        lda #>filename
        sta $345,x
        jsr $e456
        tya
        bmi load_error
        ldx #$10
        lda #7
        sta $342,x
        lda #0
        sta $344,x
        sta $348,x
        lda #$40
        sta $345,x
        lda #$70
        sta $349,x
        jsr $e456
        sty io_status
        ldx #$10
        lda #12
        sta $342,x
        jsr $e456
        lda io_status
        cmp #136                    ; EOF is normal for a short bulk read
        beq validate
        cmp #128
        bcs load_error
validate
        ldx #3
check_magic
        lda music,x
        cmp magic,x
        bne load_error
        dex
        bpl check_magic
        lda music+4
        cmp #1
        bne load_error
        lda count
        beq load_error
        cmp #65
        bcs load_error
        jmp start
load_error
        lda #<error_text
        ldy #>error_text
        jsr print
        jmp loader
print   sta $344
        sty $345
        lda #9
        sta $342
        lda #0
        sta $349
        lda #255
        sta $348
        ldx #0
        jmp $e456
io_status dta 0
magic   dta c'PMS1'
prompt  dta c'PICO / POKEY - ENTER FILE (D:MUSIC.PMS)',155
error_text dta c'LOAD FAILED. USE A GENERATED PMS FILE.',155
filename :64 dta 155
        run loader
