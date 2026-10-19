; Full-resolution standalone gallery picture test. Generated core/helpers come from the
; current game; no campaign runs and no reduced ending data is loaded.
        icl 'generated/outro-full-quality-symbols.inc'
        org $2000
        ins 'generated/outro-full-quality-core.bin'
        org $7000
.proc viewer_prepare
        mva #32 upload_index
        rts
.endp
.local full_outro
.proc start
        cld
        lda hardware_ok
        bne ready
        jmp main
ready   jsr setup_antic
        jsr setup_xdl
        jsr blit_init
        jsr load_city_palette
        mva #0 front_bank
        sta page
        sta render_bank
        mva #1 back_bank
        mva #2 background_bank
        jsr copy_background_cache
        jsr wait_blit
        jsr enable_display
next    jsr wait_action
        inc page
        lda page
        cmp #4
        bcc draw
        mva #0 page
draw    lda page
        clc
        adc #2
        sta background_bank
        mva back_bank render_bank
        jsr copy_background_cache
        jsr wait_blit
        jsr present_back_buffer
        jmp next
.endp
.proc wait_action
        ldx #2
release jsr wait_frame
        jsr pressed
        bne wait_action
        dex
        bne release
press   jsr wait_frame
        jsr pressed
        beq press
        ldx #2
finish  jsr wait_frame
        jsr pressed
        bne held
        dex
        bne finish
        mva #$FF ch
        rts
held    ldx #2
        bne finish
.endp
.proc pressed
        lda strig0
        and #1
        beq yes
        lda skstat
        and #4
        bne no
        lda kbcode
        and #$3f
        cmp #12
        beq yes
        cmp #33
        beq yes
no      lda #0
        rts
yes     lda #1
        rts
.endp
page dta 0
.endl
        ini loader_init
        ini viewer_prepare
        icl 'generated/outro-full-quality-uploads.inc'
        run full_outro.start
