; A final-ruins victory ends the campaign. Pictures occupy only unused asset
; tails and BASIC-off RAM; all existing scenery and hero poses remain intact.
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
.proc play
        mva #0 page
next    jsr draw
        jsr wait_action
        inc page
        lda page
        cmp #3
        bcc next
        jsr new_city
        rts
.endp
.proc draw
        mva back_bank render_bank
        rect 0,0,320,200,1
        jsr wait_blit
        ldx page
        mva first_chunk,x chunk
        mwa #0 remaining
        txa
        asl
        asl
        asl
        asl
        sta palette_offset
        lda render_bank
        asl
        asl
        asl
        asl
        ora #128
        sta destination_bank
        mwa #$9000 text_dst
        mva #72 rows
row     mwa #$8400 work_ptr
        mva #80 pairs
pair    jsr read_byte
        pha
        lsr
        lsr
        lsr
        lsr
        jsr pixel
        pla
        and #15
        jsr pixel
        dec pairs
        bne pair
        jsr write_row
        jsr write_row
        dec rows
        bne row
        rect 0,144,320,1,2
        ldx page
        mva first_line,x line
        mva line_count,x lines_left
        mva #149 text_y
text    ldx line
        mva caption_lo,x text_src
        mva caption_hi,x text_src+1
        mwa #10 text_x
        jsr draw_text
        inc line
        lda text_y
        clc
        adc #9
        sta text_y
        dec lines_left
        bne text
        labeltext 67,190,s_next
        lda page
        cmp #2
        bne present
        rect 0,188,320,12,1
        labeltext 85,190,s_end
present jsr wait_blit
        jmp present_back_buffer
.endp
.proc pixel
        clc
        adc palette_offset
        tay
        lda picture_palette,y
        ldy #0
        sta (work_ptr),y
        iny
        sta (work_ptr),y
        clc
        lda work_ptr
        adc #2
        sta work_ptr
        bcc done
        inc work_ptr+1
done    rts
.endp
.proc read_byte
        lda remaining
        ora remaining+1
        bne ready
        ldx chunk
        mva chunk_bank,x source_bank
        mva chunk_lo,x data_ptr
        mva chunk_hi,x data_ptr+1
        mva chunk_len_lo,x remaining
        mva chunk_len_hi,x remaining+1
        inc chunk
ready   lda source_bank
        beq cpu
        jsr select_bank
cpu     ldy #0
        lda (data_ptr),y
        pha
        inc data_ptr
        bne count
        inc data_ptr+1
count   lda remaining
        bne low
        dec remaining+1
low     dec remaining
        pla
        rts
.endp
.proc write_row
        mwa #$8400 work_ptr
        mwa #320 copy_count
        lda destination_bank
        jsr select_bank
next    ldy #0
        lda (work_ptr),y
        sta (text_dst),y
        inc work_ptr
        bne dst
        inc work_ptr+1
dst     inc text_dst
        bne count
        inc text_dst+1
        lda text_dst+1
        cmp #$A0
        bne count
        mva #$90 text_dst+1
        inc destination_bank
        lda destination_bank
        jsr select_bank
count   lda copy_count
        bne low
        dec copy_count+1
low     dec copy_count
        lda copy_count
        ora copy_count+1
        bne next
        rts
.endp
.proc select_bank
        ; This existing STA/RTS was relocated before asset loading. The outro
        ; itself is loaded afterwards, so it must not own a relocated register.
        jmp upload_chunk.reg_restore
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
chunk dta 0
source_bank dta 0
destination_bank dta 0
remaining dta a(0)
copy_count dta a(0)
palette_offset dta 0
pairs dta 0
rows dta 0
line dta 0
lines_left dta 0
first_line dta 0,4,6
line_count dta 4,2,3
caption_lo dta <s_0,<s_1,<s_2,<s_3,<s_4,<s_5,<s_6,<s_7,<s_8
caption_hi dta >s_0,>s_1,>s_2,>s_3,>s_4,>s_5,>s_6,>s_7,>s_8
s_0 dta c'NYMPH: WAIT! HE IS MY FATHER!',0
s_1 dta c'SPARE HIM AND I WILL MARRY YOU!',0
s_2 dta c'PRINCE: OK. NO PROBLEM.',0
s_3 dta c'I HAVE NOTHING AGAINST HIM.',0
s_4 dta c'THE NECROMANCER WALKS HIS DAUGHTER',0
s_5 dta c'DOWN THE AISLE. THE PRINCE SAYS: I DO.',0
s_6 dta c'THE BRIDE DANCES. THE PRINCE WATCHES.',0
s_7 dta c'HER FATHER REGRETS THE FREE BAR.',0
s_8 dta c'AND THEY LIVED... MORE OR LESS HAPPILY.',0
s_next dta c'FIRE / ENTER / SPACE: NEXT PAGE',0
s_end dta c'THE END - FIRE: NEW CAMPAIGN',0
        icl 'generated/outro-content.inc'
.endl
