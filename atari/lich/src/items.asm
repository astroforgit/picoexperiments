; ------------------------------------------------------------------
; Items, the backpack and interacting with props (interact()).
; Items live in the 8 backpack slots; slot 8 holds a new item until
; give_item() moves it into a free slot.
; ------------------------------------------------------------------
NEWIT   = 8

; make_item(A = id, X = trait or 0) -> X = NEWIT
make_item
        sta mi_id
        stx mi_tr
        ldx #NEWIT
        ldy mi_id
        tya
        sta it_id,x
        lda #1
        sta it_on,x
        sta it_trait,x
        sta it_stat,x
        lda #0
        sta it_eq,x
        lda i_type,y
        sta it_type,x
        lda i_spr,y
        sta it_spr,x
        lda i_heal,y
        sta it_heal,x
        lda i_hpmax,y
        sta it_hpmax,x
        ; atk = flr(atk + rnd(0.2*atk))
        jsr rnd16
        lda rnd_hi
        sta m_a
        lda i_atk,y
        sta m_b
        jsr mul8            ; rnd*atk*256
        ldy mi_id
        lda i_atk,y
        ldx m_r+1
        cpx #5              ; >= 1280 / 256: 0.2*atk*rnd >= 1
        bcc mi_a
        clc
        adc #1
mi_a    ldx #NEWIT
        sta it_atk,x
        ; identified = depth <= 2 or chance(0.2)
        lda #1
        sta it_idf,x
        lda pl_depth
        cmp #3
        bcc mi_id1
        lda #$33
        ldx #$33
        jsr chance
        lda #0
        rol
        ldx #NEWIT
        sta it_idf,x
mi_id1  ; trait
        lda mi_tr
        bne mi_tr1
        lda #$19            ; chance 0.1
        ldx #$9a
        jsr chance
        bcc mi_c1
        lda pl_depth
        cmp #4
        bcc mi_c1
        lda #3
        sta mi_tr
        jmp mi_tr1
mi_c1   lda #$66            ; chance 0.4
        ldx #$66
        jsr chance
        bcc mi_tr1
        lda pl_depth
        cmp #2
        bcc mi_tr1
        lda #2
        sta mi_tr
mi_tr1  ldx #NEWIT
        lda mi_tr
        cmp #3
        bne mi_cu
        jsr bless_item
        jmp mi_en
mi_cu   cmp #2
        bne mi_en
        jsr curse_item
mi_en   ; enchanted weapons below floor 3
        lda pl_depth
        cmp #4
        bcc mi_r
        lda it_type+NEWIT
        cmp #1
        bne mi_r
        lda #$19            ; 0.1
        ldx #$9a
        ldy mi_tr
        cpy #2
        bne mi_e1
        lda #$4c            ; 0.3
        ldx #$cd
mi_e1   jsr chance
        bcc mi_r
        ldx #NEWIT
        jsr enchant_item
mi_r    ldx #NEWIT
        rts
mi_id   dta 0
mi_tr   dta 0

; X = item
bless_item
        lda #3
        sta it_trait,x
        lda it_heal,x
        jsr bl_inc
        sta it_heal,x
        lda it_hpmax,x
        jsr bl_inc
        sta it_hpmax,x
        lda it_atk,x
        jsr bl_inc
        sta it_atk,x
        rts
; v > 0: v + 1 + flr(v*rnd(0.5))
bl_inc  beq bi_r
        sta bi_v
        jsr intrnd
        lsr
        sec
        adc bi_v
bi_r    rts
bi_v    dta 0

curse_item
        lda #2
        sta it_trait,x
        lda #0
        sta it_heal,x
        sta it_hpmax,x
        rts

enchant_item
        lda #4
        jsr intrnd
        clc
        adc #2
        sta it_stat,x
        ldy it_atk,x
        lda mul07,y
        sta it_atk,x
        rts

; copy item X into slot Y
item_copy
        lda it_on,x
        sta it_on,y
        lda it_id,x
        sta it_id,y
        lda it_type,x
        sta it_type,y
        lda it_spr,x
        sta it_spr,y
        lda it_atk,x
        sta it_atk,y
        lda it_heal,x
        sta it_heal,y
        lda it_hpmax,x
        sta it_hpmax,y
        lda it_trait,x
        sta it_trait,y
        lda it_stat,x
        sta it_stat,y
        lda it_idf,x
        sta it_idf,y
        lda it_eq,x
        sta it_eq,y
        rts

; give_item(NEWIT, A = 1 to hide the message): C=1 when given
give_item
        sta gi_hide
        ldy #0
gi_f    lda it_on,y
        beq gi_ok
        iny
        cpy #8
        bne gi_f
        clc
        rts
gi_ok   ldx #NEWIT
        sty gi_s
        jsr item_copy
        inc inv_n
        lda gi_hide
        bne gi_r
        jsr sb_clear
        ldy gi_s
        jsr sb_item_name
        lda #5
        ldx #60
        jsr show_alert_sb
gi_r    ldy gi_s
        sec
        rts
gi_hide dta 0
gi_s    dta 0

; builder += item_name(item Y)
sb_item_name
        sty sin_y
        lda it_idf,y
        bne sin_id
        mwa #s_mysterious sp
        jsr sb_str
        ldy sin_y
        jmp sb_item_base
sin_id  ldx it_trait,y
        lda trait_lo,x
        sta sp
        lda trait_hi,x
        sta sp+1
        jsr sb_str
        ldy sin_y
        jsr sb_item_base
        ldy sin_y
        ldx it_stat,y
        lda status_lo,x
        sta sp
        lda status_hi,x
        sta sp+1
        jmp sb_str
sin_y   dta 0
; builder += name of item Y
sb_item_base
        ldx it_id,y
        lda iname_lo,x
        sta sp
        lda iname_hi,x
        sta sp+1
        jmp sb_str

; inventory lines (get_inventory_text) -> inv_text
inv_text_build
        jsr memo_flush
        ldy #0
itb_l   sty itb_i
        jsr sb_clear
        ldy itb_i
        lda it_on,y
        bne itb_it
        mwa #s_empty sp
        jsr sb_str
        jmp itb_c
itb_it  lda it_eq,y
        beq itb_ne
        mwa #s_equipmark sp
        jsr sb_str
itb_ne  ldy itb_i
        jsr sb_item_name
        ldy itb_i
        lda it_eq,y
        beq itb_c
        lda #G_SPACE
        jsr sb_glyph
itb_c   ldy itb_i
        lda invt_lo,y
        sta ptr2
        lda invt_hi,y
        sta ptr2+1
        jsr sb_copy
        ldy itb_i
        iny
        cpy #8
        bne itb_l
        rts
itb_i   dta 0
invt_lo
        .rept 8
        dta <(inv_text+#*48)
        .endr
invt_hi
        .rept 8
        dta >(inv_text+#*48)
        .endr

; unequip_item(X = slot, A = skip sound): C=1 when unequipped
unequip_item
        cpx #$ff
        beq ui_ok
        sta ui_skip
        lda it_trait,x
        cmp #2
        bne ui_1
        stx ui_x
        lda #42
        jsr sfx
        jsr sb_clear
        ldy ui_x
        jsr sb_item_base
        mwa #s_a_stuck sp
        jsr sb_str
        lda #0
        ldx #60
        jsr show_alert_sb
        clc
        rts
ui_1    lda ui_skip
        bne ui_2
        lda #39
        jsr sfx
ui_2    ldy pl
        lda e_hpmax,y
        sec
        sbc it_hpmax,x
        sta e_hpmax,y
        lda #0
        sta it_eq,x
        lda #$ff
        sta pl_wpn
ui_ok   sec
        rts
ui_skip dta 0
ui_x    dta 0

; discard_item(X = slot, A = skip sound)
discard_item
        sta di_skip
        stx di_x
        lda it_eq,x
        beq di_1
        lda #0
        jsr unequip_item
        bcc di_r
di_1    lda di_skip
        bne di_2
        lda #41
        jsr sfx
di_2    dec inv_n
        ldx di_x
        lda #0
        sta it_on,x
di_r    rts
di_skip dta 0
di_x    dta 0

; use_item(hero, X = slot)
use_item
        stx ux_s
        lda it_type,x
        beq ux_food
        ; weapon
        ldx pl_wpn
        lda #0
        jsr unequip_item
        bcc ux_r
        ldx ux_s
        stx pl_wpn
        lda #1
        sta it_eq,x
        sta it_idf,x
        lda #40
        jmp sfx
ux_r    rts
ux_food lda floater_delay
        clc
        adc #20
        sta floater_delay
        lda #30
        sta sleep
        lda it_hpmax,x
        beq ux_f1
        jsr sb_clear
        mwa #s_heartplus sp
        jsr sb_str
        ldx ux_s
        lda it_hpmax,x
        jsr sb_num
        jsr sb_end
        lda #11
        ldy #$ff
        ldx pl
        jsr add_floater
        ldx ux_s
        ldy pl
        lda e_hpmax,y
        clc
        adc it_hpmax,x
        sta e_hpmax,y
ux_f1   ldx ux_s
        lda it_trait,x
        clc
        adc #42
        jsr sfx
        ; the item's name is what hurts the hero
        ldx ux_s
        ldy it_id,x
        lda iname_lo,y
        sta hit_name
        lda iname_hi,y
        sta hit_name+1
        lda it_trait,x
        cmp #2
        jne ux_heal
        ; cursed food
        jsr rnd16
        lda rnd_hi
        ldx ux_s
        cmp #$33            ; < 0.2
        bcs ux_c2
        lda #5
        sta it_heal,x
        jmp ux_heal
ux_c2   cmp #$66            ; < 0.4
        bcs ux_c3
        ldy pl
        lda e_pois,y
        clc
        adc #3
        sta e_pois,y
        mwa #s_a_poison sp
        jmp ux_alert
ux_c3   cmp #$99            ; < 0.6
        bcs ux_c4
        ldy pl
        lda e_conf,y
        clc
        adc #4
        sta e_conf,y
        mwa #s_a_dizzy sp
        jmp ux_alert
ux_c4   cmp #$cc            ; < 0.8
        bcs ux_c5
        ldy pl
        lda e_para,y
        clc
        adc #3
        sta e_para,y
        mwa #s_a_glup sp
        jmp ux_alert
ux_c5   mwa #s_a_rotten sp
        lda #$ff
        sta it_heal,x
ux_alert
        lda #0
        ldx #60
        jsr show_alert_str
        ldx w_i
        lda #20
        sta wn_dly,x
ux_heal ldx ux_s
        lda pl
        sta chp_de
        lda #$ff
        sta chp_se
        lda it_heal,x
        jmp change_hp
ux_s    dta 0

; ---------------------------------------------------------- menus
show_inventory
        lda #36
        jsr sfx
        jsr inv_text_build
        lda #16
        ldx #12
        jsr win_new
        ldy #0
si_l    lda invt_lo,y
        sta sp
        lda invt_hi,y
        sta sp+1
        sty si_y
        jsr win_line
        ldy si_y
        iny
        cpy #8
        bne si_l
        lda #96
        jsr win_finish
        lda #0
        jsr add_modal
        ldx w_i
        lda #1
        sta wn_cur,x
        sta wn_sel,x
        stx si_w
        ; header window
        lda wn_x,x
        pha
        lda wn_yh,x
        sec
        sbc #10
        tax
        pla
        jsr win_new
        mwa #s_backpack sp
        jsr win_line
        lda #0
        jsr win_finish
        ldx si_w
        lda w_i
        sta wn_head,x
        rts
si_y    dta 0
si_w    dta 0

on_inv_select
        ldx modal_top
        ldy wn_cur,x
        dey
        sty oi_s
        lda it_on,y
        beq oi_r
        lda #33
        jsr sfx
        ldx modal_top
        lda wn_x,x
        clc
        adc #8
        pha
        lda oi_s
        clc
        adc #1
        asl
        sta tmp
        asl
        adc tmp             ; cursor*6
        adc #3
        adc wn_yh,x
        tax
        pla
        jsr win_new
        mwa #s_use sp
        ldy oi_s
        lda it_type,y
        beq oi_1
        mwa #s_equip sp
        lda it_eq,y
        beq oi_1
        mwa #s_unequip sp
oi_1    jsr win_line
        mwa #s_discard sp
        jsr win_line
        lda #50
        jsr win_finish
        lda #0
        jsr add_modal
        ldx w_i
        lda #2
        sta wn_sel,x
        lda #0
        sta wn_btn,x
        lda #1              ; (the cart never sets this cursor)
        sta wn_cur,x
oi_r    rts
oi_s    dta 0

on_item_select
        ldx modal_stack
        ldy wn_cur,x
        dey
        sty os_s
        lda #0
        sta os_turn
        ; line pointer of the selected command
        ldx modal_top
        ldy wn_cur,x
        dey
        tya
        clc
        adc wl_base,x
        tay
        lda wn_lo,y
        sta os_p
        lda wn_hi,y
        sta os_p+1
        ldx os_s
        lda os_p
        cmp #<s_discard
        bne os_1
        lda os_p+1
        cmp #>s_discard
        bne os_1
        lda #0
        jsr discard_item
        jmp os_close
os_1    lda os_p
        cmp #<s_use
        bne os_2
        lda os_p+1
        cmp #>s_use
        bne os_2
        jsr use_item
        ldx os_s
        lda #1
        jsr discard_item
        lda #1
        sta os_turn
        jmp os_close
os_2    lda os_p
        cmp #<s_equip
        bne os_3
        lda os_p+1
        cmp #>s_equip
        bne os_3
        jsr use_item
        jmp os_close
os_3    lda #0
        jsr unequip_item
os_close
        jsr close_modal_top
        jsr inv_text_build
        lda os_turn
        beq os_r
        jsr close_modal_top
        inc phase
        ldx pl
        lda #0
        sta a4
        sta a5
        sta a6
        jsr move_anim
os_r    rts
os_s    dta 0
os_p    dta a(0)
os_turn dta 0

; ---------------------------------------------------------- props
; get_depth_item(list at (sp), count A) -> A = item id, 0 = none
get_depth_item
        sta gd_n
        ldx #0
        ldy #0
gdi_l   lda (sp),y
        sty gd_y
        tay
        lda i_depth,y
        cmp pl_depth
        beq gdi_a
        bcs gdi_n
gdi_a   tya
        sta gd_pool,x
        inx
gdi_n   ldy gd_y
        iny
        cpy gd_n
        bne gdi_l
        txa
        beq gdi_none
        jsr intrnd
        tax
        lda gd_pool,x
        rts
gdi_none
        lda #0
        rts
gd_n    dta 0
gd_y    dta 0
gd_pool :8 dta 0
list_weapons dta 8,9,10,11,12,13,14,15
list_drinks  dta 6,7
list_food    dta 1,2,3,4,5

; interact(hero, a0 = tx, a1 = ty): C=1 when the turn is spent
interact
        ldy a0
        ldx a1
        lda #F_MOB
        jsr get_entity
        cpx #$ff
        beq in_1
        txa
        tay
        ldx pl
        jmp attack_entity
in_1    ldy a0
        ldx a1
        lda #0
        jsr get_entity
        cpx #$ff
        bne in_2
in_no   clc
        rts
in_2    stx in_e
        lda e_fl,x
        and #F_USED
        bne in_no
        lda e_id,x
        cmp #ID_ANVIL
        jne in_well
        ; ---- anvil
        lda tried_anvil
        bne in_a1
        inc tried_anvil
        mwa #ml_anvil sp
        jmp in_modal
in_a1   ldx pl_wpn
        bpl in_a2
        mwa #s_a_equip sp
        jmp in_alert_no
in_a2   lda it_trait,x
        cmp #1
        bne in_a3
        lda it_stat,x
        cmp #1
        beq in_a4
in_a3   mwa #s_a_untampered sp
        jmp in_alert_no
in_a4   ; cursed food in the backpack
        ldx #0
        ldy #0
in_af   lda it_on,y
        beq in_afn
        lda it_type,y
        bne in_afn
        lda it_trait,y
        cmp #2
        bne in_afn
        tya
        sta gd_pool,x
        inx
in_afn  iny
        cpy #8
        bne in_af
        txa
        bne in_a5
        mwa #s_a_food sp
        jmp in_alert_no
in_a5   jsr intrnd
        tax
        lda gd_pool,x
        tax
        lda #1
        jsr discard_item
        ; chance(1 - 0.05*atk), 0.05 = $0ccd
        ldx pl_wpn
        lda it_atk,x
        beq in_a7           ; certain
        sta an_atk
        cmp #20
        bcs in_a6           ; never
        sta m_a
        lda #$cd
        sta m_b
        jsr mul8
        lda m_r
        sta an_lo
        lda m_r+1
        sta an_hi
        lda an_atk
        sta m_a
        lda #$0c
        sta m_b
        jsr mul8
        lda m_r
        clc
        adc an_hi
        sta an_hi
        lda #0
        sec
        sbc an_lo
        tax
        lda #0
        sbc an_hi
        jsr chance
        bcc in_a6
in_a7
        lda #32
        jsr sfx
        lda #24
        sta sleep
        ldx pl_wpn
        jsr enchant_item
        jsr sb_clear
        ldy pl_wpn
        jsr sb_item_name
        lda #1
        ldx #60
        jsr show_alert_sb
        ldx w_i
        lda #30
        sta wn_dly,x
        jmp in_rest
in_a6   lda #38
        jsr sfx
        lda #10
        sta sleep
        jsr sb_clear
        ldy pl_wpn
        jsr sb_item_base
        mwa #s_a_shattererd sp
        jsr sb_str
        lda #0
        ldx #60
        jsr show_alert_sb
        ldx pl_wpn
        lda #1
        jsr discard_item
        jmp in_rest
in_well cmp #ID_WELL
        bne in_altar
        lda tried_well
        bne in_w1
        inc tried_well
        mwa #ml_well sp
        jmp in_modal
in_w1   ldx pl_wpn
        bmi in_w2
        lda it_trait,x
        cmp #2
        beq in_w3
in_w2   mwa #s_a_dip sp
        jmp in_alert_no
in_w3   ; "^<name> is no longer cursed!"
        jsr sb_clear
        ldy pl_wpn
        jsr sb_item_base
        ldx strbuf
        lda cap_glyph,x
        sta strbuf
        mwa #s_a_nocurse sp
        jsr sb_str
        lda #0
        ldx #60
        jsr show_alert_sb
        lda #10
        sta sleep
        ldx in_e
        lda #21
        sta e_fbase,x
        lda e_fl,x
        ora #F_USED
        sta e_fl,x
        ldx pl_wpn
        lda #1
        sta it_trait,x
        lda #46
        jsr sfx
        jmp in_rest
in_altar
        cmp #ID_ALTAR
        bne in_rest
        lda tried_altar
        bne in_al1
        inc tried_altar
        mwa #ml_altar sp
        jmp in_modal
in_al1  ldx #0
        ldy #0
in_alf  lda it_on,y
        beq in_aln
        lda it_idf,y
        bne in_aln
        tya
        sta gd_pool,x
        inx
in_aln  iny
        cpy #8
        bne in_alf
        txa
        bne in_al2
        mwa #s_a_noident sp
        jmp in_alert_no
in_al2  jsr intrnd
        tax
        lda gd_pool,x
        sta in_it
        tax
        lda it_trait,x
        clc
        adc #45
        jsr sfx
        lda #10
        sta sleep
        ldx in_it
        lda #1
        sta it_idf,x
        jsr sb_clear
        ldy in_it
        jsr sb_item_name
        lda #3
        ldx #60
        jsr show_alert_sb
        ; falls through to the generic checks
in_rest ldx in_e
        lda e_id,x
        cmp #ID_DOORH
        beq in_door
        cmp #ID_DOORV
        bne in_cont
in_door lda #61
        jsr sfx
        ldx in_e
        jsr delhash
        jsr ent_del
in_cont ldx in_e
        lda e_fl,x
        and #F_USED
        bne in_yes
        lda e_id,x
        cmp #5
        beq in_chest
        cmp #6
        beq in_shelf
        cmp #4
        beq in_pot
        cmp #18
        beq in_pot
        cmp #21
        beq in_pot
in_yes  sec
        rts
in_chest
        lda #49
        sta in_snd
        mwa #list_weapons sp
        lda #8
        jsr get_depth_item
        jmp in_got
in_shelf
        lda #60
        sta in_snd
        lda e_fl,x
        and #F_ITEM
        beq in_got
        mwa #list_drinks sp
        lda #2
        jsr get_depth_item
        jmp in_got
in_pot  ldy #50
        cmp #21
        bne in_p1
        ldy #60
in_p1   sty in_snd
        lda e_fl,x
        and #F_ITEM
        beq in_p2
        mwa #list_food sp
        lda #5
        jsr get_depth_item
        jmp in_got
in_p2   lda #$19            ; chance 0.1: a rat jumps out
        ldx #$9a
        jsr chance
        bcc in_p3
        lda #$b3            ; chance 0.7: rat, else toxic rat
        ldx #$33
        jsr chance
        lda #ID_RAT
        bcs in_p4
        lda #ID_TOXIC
in_p4   jsr make_mob
        bcs in_p3
        jsr addhash
in_p3   lda #0
in_got  sta in_it
        beq in_used
        lda inv_n
        cmp #8
        bcc in_give
        mwa #s_a_carry sp
        lda #0
        ldx #60
        jsr show_alert_str
        lda #37
        jsr sfx
        clc
        rts
in_give lda in_it
        ldx #0
        jsr make_item
        lda #0
        jsr give_item
in_used ldx in_e
        lda e_fl,x
        ora #F_USED
        sta e_fl,x
        lda in_snd
        jsr sfx
        ldx in_e
        dec e_fbase,x
        lda e_id,x
        cmp #4
        beq in_walk
        cmp #18
        beq in_walk
        cmp #21
        bne in_yes2
in_walk lda e_fl,x
        ora #F_WALK
        sta e_fl,x
in_yes2 sec
        rts
in_modal
        lda #22
        ldx #28
        jsr win_new
        jsr win_lines
        lda #0
        jsr win_finish
        lda #0
        jsr add_modal
        clc
        rts
in_alert_no
        lda #0
        ldx #60
        jsr show_alert_str
        clc
        rts
in_e    dta 0
in_it   dta 0
an_atk  dta 0
an_lo   dta 0
an_hi   dta 0
in_snd  dta 0
