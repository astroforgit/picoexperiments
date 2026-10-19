; The final Warlock victory runs the ending. O previews it without changing
; campaign state. Story pages stream from D1 into the hidden framebuffer.
.local outro
.proc check
        lda screen_mode
        cmp #2
        bne done
        lda battle.game_state
        cmp #1
        bne done
        lda battle.contract
        cmp #11
        bne done
        lda battle.reward_committed
        beq done
        jsr play
done    rts
.endp
.proc preview
        mva #1 preview_mode
        jsr play
        mva #0 preview_mode
        sta release_ticks
        mva #1 action_latched
        sta dirty
        mva #$FF key_temp
        sta CH
        rts
.endp
.proc play
        mva #0 page
next    jsr draw
        jsr wait_action
        inc page
        lda page
        cmp #3
        bcc next
        lda preview_mode
        bne done
        jmp new_city
done    rts
.endp
.proc draw
        mva back_bank render_bank
        lda page
        jsr story.load
        bcs ready
        jmp failed
ready   labeltext 67,190,s_next
        lda page
        cmp #2
        bne present
        rect 0,188,320,12,1
        lda preview_mode
        beq ending
        labeltext 100,190,s_return
        jmp present
ending  labeltext 85,190,s_end
present jsr wait_blit
        jmp present_back_buffer
failed  labeltext 76,190,s_retry
        jsr wait_blit
        jsr present_back_buffer
        jsr wait_action
        jmp draw
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
        mva #$FF CH
        rts
held    ldx #2
        bne finish
.endp
.proc pressed
        lda STRIG0
        and #1
        beq yes
        lda SKSTAT
        and #4
        bne no
        lda KBCODE
        and #$3F
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
preview_mode dta 0
s_next dta c'FIRE / ENTER / SPACE: NEXT PAGE',0
s_end dta c'THE END - FIRE: NEW CAMPAIGN',0
s_return dta c'FIRE: RETURN TO GAME',0
s_retry dta c'FIRE: RETRY STORY DISK',0
.endl

; Standard Atari OS SIO reads use only $8400..$84FF staging RAM. The two
; existing framebuffers are the destination; scenery and sprites stay intact.
.local story
.proc load
        tax
        mva sector_lo,x sector
        mva sector_hi,x sector+1
        jsr wait_blit
        lda #1
        sta read_sector
        lda #0
        sta read_sector+1
        lda #128
        sta read_size
        jsr read
        bcc error
        ldx #15
verify  lda $8400,x
        cmp signature,x
        bne error
        dex
        bpl verify
        mva sector read_sector
        mva sector+1 read_sector+1
        mva #0 read_size
        mva #250 remaining
        mva #$90 destination_hi
        lda render_bank
        asl
        asl
        asl
        asl
        ora #128
        sta destination_bank
next    jsr read
        bcc error
        lda destination_bank
        jsr upload_chunk.reg_restore
        mva #0 text_dst
        mva destination_hi text_dst+1
        ldy #0
copy    lda $8400,y
        sta (text_dst),y
        iny
        bne copy
        inc destination_hi
        lda destination_hi
        cmp #$A0
        bne count
        mva #$90 destination_hi
        inc destination_bank
count   inc read_sector
        bne low
        inc read_sector+1
low     dec remaining
        bne next
        sec
        rts
error   rect 0,0,320,200,1
        labeltext 61,76,s_missing
        labeltext 52,94,s_attach
        jsr wait_blit
        clc
        rts
.endp
.proc read
        mva #$31 $0300
        mva #1 $0301
        mva #$52 $0302
        mva #$40 $0303
        mwa #$8400 $0304
        mva #7 $0306
        mva read_size $0308
        lda #0
        ldx read_size
        bne short
        lda #1
short   sta $0309
        mva read_sector $030A
        mva read_sector+1 $030B
        jsr $E459
        tya
        bmi failed
        sec
        rts
failed  clc
        rts
.endp
sector dta a(0)
read_sector dta a(0)
read_size dta 0
remaining dta 0
destination_bank dta 0
destination_hi dta 0
s_missing dta c'MISSING OR WRONG STORY DISK',0
s_attach dta c'ATTACH HEROES-STORY.ATR TO D1:',0
        icl 'generated/story-content.inc'
.endl
