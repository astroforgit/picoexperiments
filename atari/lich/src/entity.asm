; ------------------------------------------------------------------
; Entities: creation, the tile occupancy lists (the cart's "hash"),
; movement, line of sight, fog, monster logic and combat.
; X = entity index unless noted.  Signed values are two's complement.
; ------------------------------------------------------------------
ID_HERO = 1
ID_RAT  = 2
ID_DOORH = 7
ID_DOORV = 8
ID_ALTAR = 9
ID_SPIKES = 13
; monster abilities (m_abil bits, editable)
AB_POISON = 1
AB_PARA = 2
AB_BOLT = 4
AB_BLINK = 8
AB_FLEE = 16
AB_BOSS = 32
AB_TREASURE = 64
AB_STUN = 128
AB2_CURSE = 1           ; m_abil2
AB2_VAMP = 2
AB2_STEALI = 4
AB2_STEALW = 8
AB2_SLOW = 16
AB2_STILL = 32
AB2_POUNCE = 64
AB2_SUMMON = 128
AB3_HUNTER = 1          ; m_abil3
AB3_BLIND = 2
AB3_INVIS = 4
CH_USED = 1             ; e_chg: the once-only special was used
CH_MOVED = 2            ; slow: moved last turn
ID_ANVIL = 20
ID_WELL = 25

; particle colour lists
PC_RISE = 0         ; 5,6,13,7,12
PC_BOLT = 1         ; 8,9,10,7
PC_BLINK = 2        ; 15,15,14,7
PC_POISON = 3       ; 3,11,10,5
PC_SINGLE = 16      ; 16+c: just colour c
pcol_n  dta 5,4,4,4
pcol_o  dta 0,5,9,13
pcol_c  dta 5,6,13,7,12, 8,9,10,7, 15,15,14,7, 3,11,10,5

; ---------------------------------------------------------- allocation
; X = free entity slot, C=1 when full
ent_alloc
        ldx alloc_e
        ldy #MAXENT
ea_l    inx
        cpx #MAXENT
        bcc ea_1
        ldx #0
ea_1    lda e_id,x
        beq ea_ok
        dey
        bne ea_l
        sec
        rts
ea_ok   stx alloc_e
        clc
        rts

; make_e(A = id) -> X (C=1: no room).  Position from a0 (tx), a1 (ty).
make_e  sta me_id
        jsr ent_alloc
        bcc me_ok
        rts
me_ok   ldy me_id
        tya
        sta e_id,x
        lda a0
        sta e_tx,x
        lda a1
        sta e_ty,x
        lda m_hp,y
        sta e_hp,x
        sta e_hpmax,x
        lda m_atk,y
        sta e_atk,x
        lda m_anim,y
        sta e_fbase,x
        lda m_page,y
        sta e_pg,x
        lda #0
        sta e_chg,x
        sta e_oxl,x
        sta e_oxh,x
        sta e_oyl,x
        sta e_oyh,x
        sta e_fl,x
        sta e_pois,x
        sta e_conf,x
        sta e_para,x
        sta e_t,x
        sta e_mt,x
        sta e_dx,x
        sta e_dy,x
        sta e_odist,x
        sta e_hitc,x
        sta e_fc,x
        sta e_fs,x
        sta e_frame,x
        sta e_fmode,x
        sta e_logic,x
        sta e_gx,x
        sta e_gy,x
        lda #$ff
        sta e_next,x
        lda #1
        sta e_dir,x
        sta e_nfr,x
        ; hasitem = chance(itemchance/10)
        lda m_itemchance,y
        beq me_noitem
        cmp #10
        bcs me_item
        stx me_x
        lda m_item_lo,y
        tax
        lda m_item_hi,y
        jsr chance
        ldx me_x
        bcc me_noitem
me_item lda #F_ITEM
        sta e_fl,x
me_noitem
        jsr ent_add
        clc
        rts
me_id   dta 0
me_x    dta 0

; add X to the entity list
ent_add ldy ent_n
        txa
        sta ent_list,y
        inc ent_n
        rts

; remove X from the entity list (the slot is freed unless it is the hero)
ent_del stx ed_x
        ldy #0
ed_f    cpy ent_n
        bcs ed_d
        lda ent_list,y
        cmp ed_x
        beq ed_sh
        iny
        bne ed_f
ed_sh   iny
        cpy ent_n
        bcs ed_e
        lda ent_list,y
        sta ent_list-1,y
        jmp ed_sh
ed_e    dec ent_n
ed_d    ldx ed_x
        cpx pl
        beq ed_r
        lda #0
        sta e_id,x
ed_r    rts
ed_x    dta 0

; mobs get 4 animation frames
set_mob_frames
        lda #4
        sta e_nfr,x
        lda e_fl,x
        ora #F_MOB
        sta e_fl,x
        rts

make_player
        lda #ID_HERO
        jsr make_e
        stx pl
        jsr set_mob_frames
        lda #2
        sta e_fs,x
        lda #L_PLAYER
        sta e_logic,x
        rts

; make_prop(A = id) at a0, a1 -> X
make_prop
        sta mp_id
        jsr make_e
        bcs mp_r
        lda e_fl,x
        ora #F_PROP
        ldy mp_id
        cpy #ID_DOORH
        beq mp_blos
        cpy #ID_DOORV
        bne mp_1
mp_blos ora #F_BLOS
mp_1    cpy #ID_SPIKES
        bne mp_2
        ora #F_TRAP|F_WALK
        pha
        lda #L_TRAP
        sta e_logic,x
        pla
mp_2    sta e_fl,x
        lda #9              ; props never move: their move timer is done
        sta e_mt,x
        clc
mp_r    rts
mp_id   dta 0

; make_mob(A = id) at a0, a1 -> X
make_mob
        jsr make_e
        bcs mm_r
        jsr set_mob_frames
        lda #4
        sta e_fs,x
        lda #L_WAIT
        sta e_logic,x
        stx mm_x
        lda #$80
        ldx #0
        jsr chance
        ldx mm_x
        lda #1
        bcs mm_d
        lda #$ff
mm_d    sta e_dir,x
        clc
mm_r    rts
mm_x    dta 0

; make_entities: hero start and the entities drawn into the map
make_entities
        lda #0
        sta a0
me_x_l  lda #0
        sta a1
me_y_l  ldy a0
        ldx a1
        jsr mget
        cmp #17
        bne me_e
        ldx pl
        lda a0
        sta e_tx,x
        lda a1
        sta e_ty,x
        jsr ent_add
        jsr addhash
        jmp me_n
me_e    tax
        lda anim_id,x
        beq me_n
        sta tmp+3
        tay
        lda m_prop,y
        beq me_mob
        lda tmp+3
        jsr make_prop
        jmp me_set
me_mob  lda tmp+3
        jsr make_mob
me_set  bcs me_n
        jsr addhash
        ldy a0
        ldx a1
        lda #1
        jsr mset
me_n    inc a1
        lda a1
        cmp #32
        bne me_y_l
        inc a0
        bpl me_x_l
        rts

; ---------------------------------------------------------- occupancy
; ptr = OCC + ty*128, Y = tx for entity X
occ_ptr lda e_ty,x
        lsr
        sta ptr+1
        lda #0
        ror
        sta ptr
        lda ptr+1
        clc
        adc #>OCC
        sta ptr+1
        ldy e_tx,x
        rts

addhash jsr occ_ptr
        lda (ptr),y
        sta e_next,x
        txa
        sta (ptr),y
        rts

delhash jsr occ_ptr
        lda (ptr),y
        cmp #$ff
        beq dh_r
        stx dh_e
        cmp dh_e
        bne dh_walk
        lda e_next,x
        sta (ptr),y
        rts
dh_walk tay                 ; Y = previous
dh_l    lda e_next,y
        cmp #$ff
        beq dh_r
        cmp dh_e
        beq dh_un
        tay
        jmp dh_l
dh_un   lda e_next,x
        sta e_next,y
dh_r    rts
dh_e    dta 0

; fill the occupancy grid with $ff
occ_clear
        lda #$ff
        ldx #0
oc_l    sta OCC,x
        sta OCC+$100,x
        sta OCC+$200,x
        sta OCC+$300,x
        sta OCC+$400,x
        sta OCC+$500,x
        sta OCC+$600,x
        sta OCC+$700,x
        sta OCC+$800,x
        sta OCC+$900,x
        sta OCC+$a00,x
        sta OCC+$b00,x
        sta OCC+$c00,x
        sta OCC+$d00,x
        sta OCC+$e00,x
        sta OCC+$f00,x
        inx
        bne oc_l
        rts

; get_entity(Y = tx, X = ty, A = 0 any / F_MOB) -> X (N=1 when none)
; living entities only.
get_entity
        sta ge_typ
        cpy #128
        bcs ge_none
        cpx #32
        bcs ge_none
        txa
        lsr
        sta ptr2+1
        lda #0
        ror
        sta ptr2
        lda ptr2+1
        clc
        adc #>OCC
        sta ptr2+1
        lda (ptr2),y
ge_l    cmp #$ff
        beq ge_none
        tax
        lda e_hp,x
        beq ge_n
        bmi ge_n
        lda ge_typ
        beq ge_yes
        and e_fl,x
        bne ge_yes
ge_n    lda e_next,x
        jmp ge_l
ge_yes  txa
        rts
ge_none ldx #$ff
ge_r    rts
ge_typ  dta 0

; ---------------------------------------------------------- walkability
; is_walkable_move(Y = tx, X = ty): C=1 walkable
walk_move
        sty wm_x
        stx wm_y
        jsr mget
        tax
        lda tile_flags,x
        and #1
        bne wm_no
        ldy wm_x
        ldx wm_y
        lda #F_MOB
        jsr get_entity
        cpx #$ff
        bne wm_no
        ldy wm_x
        ldx wm_y
        lda #0
        jsr get_entity
        cpx #$ff
        beq wm_yes
        lda e_fl,x
        and #F_WALK
        bne wm_yes
wm_no   clc
        rts
wm_yes  sec
        rts
wm_x    dta 0
wm_y    dta 0

; is_walkable_los(Y = tx, X = ty): C=1 when sight passes
walk_los
        sty wm_x
        stx wm_y
        jsr mget
        tax
        lda tile_flags,x
        and #2
        bne wm_no
        ldy wm_x
        ldx wm_y
        lda #0
        jsr get_entity
        cpx #$ff
        beq wm_yes
        lda e_fl,x
        and #F_BLOS
        bne wm_no
        sec
        rts

; ---------------------------------------------------------- line of sight
; los(a0,a1 -> a2,a3, sight A): C=1 visible
los     sta ls_sight
        lda a0
        sta ls_x
        lda a1
        sta ls_y
        ; dist^2
        lda a0
        sec
        sbc a2
        pha
        lda a1
        sec
        sbc a3
        tax
        pla
        jsr dist2
        ldx ls_sight
        lda sq_lo,x
        cmp m_r
        lda sq_hi,x
        sbc m_r+1
        jcc ls_no           ; dist > sight
        lda m_r+1
        bne ls_go
        lda m_r
        cmp #1
        jeq ls_yes          ; dist == 1
ls_go   ; Bresenham
        lda a2
        sec
        sbc ls_x
        bcs ls_sx1
        eor #$ff
        adc #1
        sta ls_dx
        lda #$ff
        sta ls_sx
        jmp ls_sxd
ls_sx1  sta ls_dx
        lda #1
        sta ls_sx
ls_sxd  lda a3
        sec
        sbc ls_y
        bcs ls_sy1
        eor #$ff
        adc #1
        sta ls_dy
        lda #$ff
        sta ls_sy
        jmp ls_syd
ls_sy1  sta ls_dy
        lda #1
        sta ls_sy
ls_syd  ; err = dx - dy (signed 16 not needed: |d| <= 5)
        lda ls_dx
        sec
        sbc ls_dy
        sta ls_err
        lda #1
        sta ls_first
ls_loop lda ls_x
        cmp a2
        bne ls_step
        lda ls_y
        cmp a3
        beq ls_yes
ls_step lda ls_first
        bne ls_nf
        ldy ls_x
        ldx ls_y
        jsr walk_los
        bcc ls_no
ls_nf   lda #0
        sta ls_first
        lda ls_err
        asl
        sta ls_e2           ; e2 = 2*err
        ; if e2 > -dy: err -= dy, x += sx
        lda #0
        sec
        sbc ls_dy
        sta tmp
        lda ls_e2
        sec
        sbc tmp             ; e2 - (-dy) > 0 ?
        beq ls_c2
        bvc ls_v1
        eor #$80
ls_v1   bmi ls_c2
        lda ls_err
        sec
        sbc ls_dy
        sta ls_err
        lda ls_x
        clc
        adc ls_sx
        sta ls_x
ls_c2   ; if e2 < dx: err += dx, y += sy
        lda ls_e2
        sec
        sbc ls_dx
        bvc ls_v2
        eor #$80
ls_v2   bpl ls_loop
        lda ls_err
        clc
        adc ls_dx
        sta ls_err
        lda ls_y
        clc
        adc ls_sy
        sta ls_y
        jmp ls_loop
ls_yes  sec
        rts
ls_no   clc
        rts
ls_sight dta 0
ls_x    dta 0
ls_y    dta 0
ls_dx   dta 0
ls_dy   dta 0
ls_sx   dta 0
ls_sy   dta 0
ls_err  dta 0
ls_e2   dta 0
ls_first dta 0

; los from entity X to the hero with the entity's sight: C=1 visible
los_to_pl
        lda e_tx,x
        sta a0
        lda e_ty,x
        sta a1
        ldy pl
        lda e_tx,y
        sta a2
        lda e_ty,y
        sta a3
        ldy e_id,x
        lda m_sight,y
        jmp los

; m_r = distance^2 from entity X to the hero
dist_to_pl
        ldy pl
        lda e_tx,x
        sec
        sbc e_tx,y
        pha
        lda e_ty,x
        sec
        sbc e_ty,y
        stx dp_x
        tax
        pla
        jsr dist2
        ldx dp_x
        rts
dp_x    dta 0

; C=1 when m_r (dist^2) > A^2
dist_gt sta tmp
        tay
        lda sq_lo,y
        cmp m_r
        lda sq_hi,y
        sbc m_r+1
        ; C=0 when sq < m_r
        bcc dg_yes
        clc
        rts
dg_yes  sec
        rts

; ---------------------------------------------------------- fog
; update_fog around the hero; changed tiles are re-baked
update_fog
        ldx pl
        lda e_tx,x
        sta uf_px
        lda e_ty,x
        sta uf_py
        ldy e_id,x
        lda m_sight,y
        ldy pl_blind
        beq uf_nb
        lda #P_BLIND_SIGHT
uf_nb   sta uf_s
        clc
        adc #1
        sta uf_r
        ; ty = py-r .. py+r
        lda uf_py
        sec
        sbc uf_r
        sta uf_ty
uf_yl   lda uf_px
        sec
        sbc uf_r
        sta uf_tx
uf_xl   ; inbounds: 0 <= tx < 127, 0 <= ty < 31
        lda uf_tx
        jmi uf_n
        cmp #127
        jcs uf_n
        lda uf_ty
        jmi uf_n
        cmp #31
        jcs uf_n
        ldy uf_tx
        ldx uf_ty
        jsr fog_get
        sta uf_old
        sta uf_new
        cmp #0
        bne uf_1
        ; within r+1: fog = 1
        lda uf_tx
        sec
        sbc uf_px
        pha
        lda uf_ty
        sec
        sbc uf_py
        tax
        pla
        jsr dist2
        ldx uf_r
        inx
        lda sq_lo,x         ; d < r+1  <=>  d^2 < (r+1)^2
        sta tmp
        lda m_r
        cmp tmp
        lda m_r+1
        sbc sq_hi,x
        bcs uf_1
        lda #1
        sta uf_new
uf_1    lda uf_px
        sta a0
        lda uf_py
        sta a1
        lda uf_tx
        sta a2
        lda uf_ty
        sta a3
        lda uf_s
        jsr los
        bcc uf_2
        lda #0
        sta uf_new
uf_2    lda uf_new
        cmp uf_old
        beq uf_n
        ldy uf_tx
        ldx uf_ty
        jsr tile_ofs
        lda ptr+1
        clc
        adc #>(FOG-TMAP)
        sta ptr+1
        lda uf_new
        sta (ptr),y
        lda uf_tx
        sta a0
        lda uf_ty
        sta a1
        jsr bake_tile
uf_n    inc uf_tx
        lda uf_px
        clc
        adc uf_r
        cmp uf_tx
        jpl uf_xl
        inc uf_ty
        lda uf_py
        clc
        adc uf_r
        cmp uf_ty
        jpl uf_yl
        rts
uf_px   dta 0
uf_py   dta 0
uf_r    dta 0
uf_s    dta 0
uf_tx   dta 0
uf_ty   dta 0
uf_old  dta 0
uf_new  dta 0

; ---------------------------------------------------------- movement
; move_anim(X, dx = a4, dy = a5, dist = a6)
move_anim
        lda #0
        sta e_mt,x
        lda a6
        sta e_odist,x
        lda a4
        sta e_dx,x
        lda a5
        sta e_dy,x
        ; ox = dist*dx, oy = dist*dy (integer)
        lda #0
        sta e_oxl,x
        sta e_oyl,x
        lda a4
        jsr ma_mul
        sta e_oxh,x
        lda a5
        jsr ma_mul
        sta e_oyh,x
        lda a6
        beq ma_1
        lda #0
        sta e_fc,x
        sta e_frame,x
ma_1    lda e_conf,x
        beq ma_2
        stx ma_x
        lda #2
        jsr intrnd
        ldx ma_x
        tay
        lda ma_dirs,y
        sta e_dir,x
        rts
ma_2    lda a5
        bne ma_r
        lda a4
        bmi ma_l
        lda #1
        sta e_dir,x
        rts
ma_l    lda #$ff
        sta e_dir,x
ma_r    rts
; A = dir (-1/0/1) * a6
ma_mul  cmp #0
        beq mam_0
        bmi mam_n
        lda a6
        rts
mam_n   lda #0
        sec
        sbc a6
mam_0   rts
ma_dirs dta 1,$ff
ma_x    dta 0

; move_entity(X, dx = a4, dy = a5): C=1 when the move (or action) happened
move_entity
        stx mv_e
        lda a4
        sta mv_dx
        lda a5
        sta mv_dy
        lda e_tx,x
        clc
        adc a4
        sta mv_tx
        lda e_ty,x
        clc
        adc a5
        sta mv_ty
        ldy mv_tx
        ldx mv_ty
        jsr walk_move
        bcc mv_blocked
        ldx mv_e
        jsr delhash
        lda mv_tx
        sta e_tx,x
        lda mv_ty
        sta e_ty,x
        jsr addhash
        lda mv_dx
        sta a4
        lda mv_dy
        sta a5
        lda #$f8            ; -8
        sta a6
        jsr move_anim
        lda e_t,x
        and #1
        clc
        adc #62
        jsr sfx
        ldx mv_e
        sec
        rts
mv_blocked
        ldx mv_e
        cpx pl
        bne mv_no
        lda mv_dx
        sta a4
        lda mv_dy
        sta a5
        lda #3
        sta a6
        jsr move_anim
        lda mv_tx
        sta a0
        lda mv_ty
        sta a1
        jsr interact
        bcs mv_yes
        lda #37
        jsr sfx
mv_no   ldx mv_e
        clc
        rts
mv_yes  ldx mv_e
        sec
        rts
mv_e    dta 0
mv_dx   dta 0
mv_dy   dta 0
mv_tx   dta 0
mv_ty   dta 0

; ---------------------------------------------------------- monster logic
run_logic
        lda e_logic,x
        asl
        tay
        lda logic_tab,y
        sta rl_j
        lda logic_tab+1,y
        sta rl_j+1
        jmp (rl_j)
rl_j    dta a(0)
logic_tab
        dta a(rl_none,player_logic,wait_logic,chase_logic,flee_logic,confused_logic,paralyzed_logic,trap_logic)
rl_none rts

; four-way options: dirs 1..4 where the tile is floor
confused_logic
        stx cl_e
        lda #0
        sta cl_n
        ldy #1
cl_l    sty cl_d
        ldx cl_e
        lda e_tx,x
        clc
        adc dirx,y
        pha
        lda e_ty,x
        clc
        adc diry,y
        tax
        pla
        tay
        jsr mget
        jsr is_floor
        bne cl_n1
        ldx cl_n
        lda cl_d
        sta cl_opt,x
        inc cl_n
cl_n1   ldy cl_d
        iny
        cpy #5
        bne cl_l
        lda cl_n
        beq cl_end
        jsr intrnd
        tax
        ldy cl_opt,x
        lda dirx,y
        sta a4
        lda diry,y
        sta a5
        ldx cl_e
        jsr move_entity
        lda #0
        sta e_fc,x
        sta e_frame,x
cl_end  ldx cl_e
        lda e_conf,x
        bne cl_r
        lda #L_CHASE
        sta e_logic,x
cl_r    rts
cl_e    dta 0
cl_n    dta 0
cl_d    dta 0
cl_opt  :4 dta 0

paralyzed_logic
        lda e_para,x
        bne pl_r
        lda #L_CHASE
        sta e_logic,x
        jmp wait_logic
pl_r    rts

; move away from the hero
flee_logic
        stx fle_e
        lda #0
        sta fl_bd
        sta fl_bd+1
        sta fl_dir
        ldy #1
fl_l    sty fl_d
        ldx fle_e
        lda e_tx,x
        clc
        adc dirx,y
        sta fl_tx
        lda e_ty,x
        clc
        adc diry,y
        sta fl_ty
        ldy fl_tx
        ldx fl_ty
        jsr walk_move
        bcc fl_n
        ldy pl
        lda e_tx,y
        sec
        sbc fl_tx
        pha
        lda e_ty,y
        sec
        sbc fl_ty
        tax
        pla
        jsr dist2
        ; dist > bdist
        lda fl_bd
        cmp m_r
        lda fl_bd+1
        sbc m_r+1
        bcs fl_n
        lda m_r
        sta fl_bd
        lda m_r+1
        sta fl_bd+1
        lda fl_d
        sta fl_dir
fl_n    ldy fl_d
        iny
        cpy #5
        bne fl_l
        ldx fle_e
        ldy fl_dir
        beq fle_c
        lda dirx,y
        sta a4
        lda diry,y
        sta a5
        jsr move_entity
        lda #0
        sta e_fc,x
        sta e_frame,x
fle_c    jsr dist_to_pl
        ldy e_id,x
        lda m_sight,y
        jsr dist_gt
        bcc fl_r
        lda #L_WAIT
        sta e_logic,x
fl_r    rts
fle_e    dta 0
fl_d    dta 0
fl_dir  dta 0
fl_tx   dta 0
fl_ty   dta 0
fl_bd   dta 0,0

chase_logic
        ldy e_id,x
        lda m_abil2,y
        and #AB2_SUMMON
        beq cl_go
        jmp summon_logic
cl_go   stx cs_e
        lda e_fl,x
        and #$ff^F_ATKD
        sta e_fl,x
        lda #0
        sta cs_see
        jsr los_to_pl
        bcc cs_1
        ldx cs_e
        ldy pl
        lda e_tx,y
        sta e_gx,x
        lda e_ty,y
        sta e_gy,x
        inc cs_see
cs_1    ldx cs_e
        ldy e_id,x
        lda m_abil3,y
        and #AB3_HUNTER
        beq cs_1b
        ldy pl
        lda e_tx,y
        sta e_gx,x
        lda e_ty,y
        sta e_gy,x
        lda #1
        sta cs_see
cs_1b   jsr dist_to_pl
        lda m_r
        sta cs_d2
        lda m_r+1
        sta cs_d2+1
        ; perp = same column or row
        ldy pl
        lda #0
        sta cs_perp
        lda e_tx,x
        cmp e_tx,y
        beq cs_p
        lda e_ty,x
        cmp e_ty,y
        bne cs_np
cs_p    inc cs_perp
cs_np   ; dist <= range and perp and cansee
        ldy e_id,x
        lda m_range,y
        jsr dist_gt
        jcs cs_move
        lda cs_perp
        jeq cs_move
        lda cs_see
        jeq cs_move
        ; ---- attack
        ldy e_id,x
        lda m_abil,y
        and #AB_BOSS
        beq cs_a1
        lda cs_d2+1
        bne cs_far
        lda cs_d2
        cmp #1
        bne cs_far
        lda #P_BOSS_NEAR_ATK
        sta e_atk,x
        stx chp_de
        stx chp_se
        lda #P_BOSS_HEAL
        jsr change_hp
        jmp cs_a1
cs_far  lda #P_BOSS_FAR_ATK
        ldx cs_e
        sta e_atk,x
cs_a1   ; once-only specials replace the hit
        ldx cs_e
        ldy e_id,x
        lda e_chg,x
        and #CH_USED
        bne cs_hit
        lda m_abil,y
        and #AB_STUN
        beq cs_s2
        ldy pl
        lda #P_STUN_TURNS
        cmp e_para,y
        bcc cs_s1
        sta e_para,y
cs_s1   mwa #s_stun sp
        jmp cs_sdone
cs_s2   lda m_abil2,y
        and #AB2_CURSE
        beq cs_s3
        jsr forget_map
        mwa #s_curse sp
        jmp cs_sdone
cs_s3   lda m_abil2,y
        and #AB2_STEALI
        beq cs_s4
        jsr steal_item
        mwa #s_steal sp
        jmp cs_sdone
cs_s4   lda m_abil2,y
        and #AB2_STEALW
        beq cs_hit
        lda pl_wpn
        bmi cs_hit
        jsr steal_weapon
        mwa #s_steal sp
cs_sdone
        ldx cs_e
        lda e_chg,x
        ora #CH_USED
        sta e_chg,x
        lda #42
        jsr sfx
        lda #11
        ldy #$ff
        ldx pl
        jsr add_floater
        jmp cs_after
cs_hit  ldx cs_e
        ldy pl
        jsr attack_entity
        ; vampire: heals itself by its attack
        ldx cs_e
        ldy e_id,x
        lda m_abil2,y
        and #AB2_VAMP
        beq cs_h2
        lda #>P_VAMPIRE_CHANCE
        ldx #<P_VAMPIRE_CHANCE
        jsr chance
        bcc cs_h2
        ldx cs_e
        stx chp_de
        stx chp_se
        lda e_atk,x
        jsr change_hp
cs_h2   ldx cs_e
        ldy e_id,x
        lda m_abil3,y
        and #AB3_BLIND
        beq cs_after
        lda #P_BLIND_TURNS
        sta pl_blind
cs_after
        ldx cs_e
        lda e_fl,x
        ora #F_ATKD
        sta e_fl,x
        ldy pl
        lda e_tx,y
        sec
        sbc e_tx,x
        jsr ssgn
        sta a4
        sta cs_dx
        lda e_ty,y
        sec
        sbc e_ty,x
        jsr ssgn
        sta a5
        sta cs_dy
        lda #4
        sta a6
        jsr move_anim
        ldy e_id,x
        lda m_abil,y
        and #AB_POISON
        beq cs_a2
        ldy pl
        lda e_pois,y
        clc
        adc #P_POISON_TURNS
        sta e_pois,y
cs_a2   ldy e_id,x
        lda m_abil,y
        and #AB_PARA
        beq cs_a3
        lda #>P_PARALYZE_CHANCE
        ldx #<P_PARALYZE_CHANCE
        jsr chance
        ldx cs_e
        bcc cs_a3
        ldy pl
        lda #P_PARALYZE_TURNS
        sta e_para,y
cs_a3   ldy e_id,x
        lda m_range,y
        cmp #2
        jcc cs_r
        lda m_abil,y
        and #AB_BOLT
        jeq cs_r
        lda m_abil,y        ; the boss bolts only from a distance
        and #AB_BOSS
        beq cs_bolt
        lda cs_d2+1
        bne cs_bolt
        lda cs_d2
        cmp #1
        jeq cs_r
cs_bolt ; confusion bolt
        ldy pl
        lda e_conf,y
        clc
        adc #P_CONFUSE_TURNS
        sta e_conf,y
        lda #55
        jsr sfx
        ; particles along the line: i = 0 .. dist step 1/8
        lda cs_d2
        sta m_r
        lda cs_d2+1
        sta m_r+1
        jsr isqrt_d2        ; A = dist (perpendicular: exact)
        asl
        asl
        asl
        sta cs_n            ; steps (dist*8), inclusive
        lda #0
        sta cs_i
cs_pl   ldx cs_e
        ; x = (tx + i*dx)*8 + 3 : i in eighths -> tx*8 + i8*dx + 3
        lda e_tx,x
        jsr times8
        lda cs_dx
        jsr cs_off
        clc
        adc #3
        sta pt_x
        bcc cs_px
        inc pt_x+1
cs_px   lda e_ty,x
        asl
        asl
        asl
        ldy cs_dy
        beq cs_py
        bmi cs_pyn
        clc
        adc cs_i
        jmp cs_py
cs_pyn  sec
        sbc cs_i
cs_py   clc
        adc #3
        sta pt_y
        lda #0
        sta pt_dx
        sta pt_dx+1
        sta pt_dy
        sta pt_dy+1
        lda #5
        jsr intrnd
        clc
        adc #2
        sta pt_life
        lda #PC_BOLT
        sta pt_c
        lda #0
        sta pt_uf
        jsr add_particle
        inc cs_i
        lda cs_i
        cmp cs_n
        beq cs_pl
        bcc cs_pl
        lda #20
        sta sleep
cs_r    rts
        ; ---- move towards the goal
cs_move ldx cs_e
        ldy e_id,x
        lda m_abil2,y
        and #AB2_STILL
        jne cs_mr           ; never moves
        lda m_abil2,y
        and #AB2_SLOW
        beq cs_mv1
        lda e_chg,x         ; rests every other turn
        eor #CH_MOVED
        sta e_chg,x
        and #CH_MOVED
        jeq cs_mr
cs_mv1  lda m_abil2,y
        and #AB2_POUNCE
        beq cs_mv2
        lda cs_see
        beq cs_mv2
        jsr try_pounce
        bcc cs_mv2
        rts
cs_mv2  lda #$ff            ; bdist = 999 (dist^2: $ffff)
        sta cs_bd
        sta cs_bd+1
        lda #4
        jsr intrnd
        clc
        adc #1
        sta cs_dir
        ldy #1
cs_ml   sty cs_k
        ldx cs_e
        lda e_tx,x
        clc
        adc dirx,y
        sta fl_tx
        lda e_ty,x
        clc
        adc diry,y
        sta fl_ty
        ldy fl_tx
        ldx fl_ty
        jsr walk_move
        bcc cs_mn
        ldx cs_e
        lda e_gx,x
        sec
        sbc fl_tx
        pha
        lda e_gy,x
        sec
        sbc fl_ty
        tax
        pla
        jsr dist2
        lda m_r
        cmp cs_bd
        lda m_r+1
        sbc cs_bd+1
        bcs cs_mn
        lda m_r
        sta cs_bd
        lda m_r+1
        sta cs_bd+1
        lda cs_k
        sta cs_dir
cs_mn   ldy cs_k
        iny
        cpy #5
        bne cs_ml
        ldy cs_dir
        lda dirx,y
        sta a4
        lda diry,y
        sta a5
        ldx cs_e
        jsr move_entity
        lda #0
        sta e_fc,x
        sta e_frame,x
        lda e_tx,x
        cmp e_gx,x
        bne cs_mr
        lda e_ty,x
        cmp e_gy,x
        bne cs_mr
        ldy e_id,x          ; a hunter never gives up
        lda m_abil3,y
        and #AB3_HUNTER
        bne cs_mr
        lda #56
        jsr sfx
        mwa #s_quest sp
        lda #10
        ldy #$ff
        jsr add_floater
        ldx cs_e
        lda #L_WAIT
        sta e_logic,x
cs_mr   rts
cs_e    dta 0
cs_see  dta 0
cs_perp dta 0
cs_d2   dta 0,0
cs_dx   dta 0
cs_dy   dta 0
cs_n    dta 0
cs_i    dta 0
cs_bd   dta 0,0
cs_dir  dta 0
cs_k    dta 0

; A*8 -> pt_x (16 bit), keeps X
times8  sta pt_x
        lda #0
        sta pt_x+1
        asl pt_x
        rol pt_x+1
        asl pt_x
        rol pt_x+1
        asl pt_x
        rol pt_x+1
        lda pt_x
        rts
; pt_x += cs_i * dir (dir = A: -1/0/1) -> returns A = pt_x low (pt_x updated)
cs_off  cmp #0
        beq co_z
        bmi co_n
        lda pt_x
        clc
        adc cs_i
        sta pt_x
        bcc co_z
        inc pt_x+1
        jmp co_z
co_n    lda pt_x
        sec
        sbc cs_i
        sta pt_x
        bcs co_z
        dec pt_x+1
co_z    lda pt_x
        rts

; A = sqrt(m_r) for a perfect square up to 16
isqrt_d2
        ldy #0
is_l    lda sq_lo,y
        cmp m_r
        bne is_n
        lda sq_hi,y
        cmp m_r+1
        beq is_d
is_n    iny
        cpy #17
        bne is_l
is_d    tya
        rts

wait_logic
        stx wl_e
        ldy e_id,x
        lda m_abil3,y
        and #AB3_HUNTER
        beq wl_0
        ldy pl
        lda e_tx,y
        sta e_gx,x
        lda e_ty,y
        sta e_gy,x
        lda #L_CHASE
        sta e_logic,x
        rts
wl_0    jsr dist_to_pl
        ldy e_id,x
        lda m_sight,y
        jsr dist_gt
        bcs wl_r
        ldx wl_e
        jsr los_to_pl
        bcc wl_r
        lda #57
        jsr sfx
        ldx wl_e
        mwa #s_excl sp
        lda #10
        ldy #$ff
        jsr add_floater
        ldx wl_e
        ldy pl
        lda e_tx,y
        sta e_gx,x
        lda e_ty,y
        sta e_gy,x
        ldy e_id,x
        lda m_abil,y
        and #AB_FLEE
        php
        lda #L_CHASE
        plp
        beq wl_1
        lda #L_FLEE
wl_1    sta e_logic,x
wl_r    ldx wl_e
        rts
wl_e    dta 0

; spikes: hurt the mob standing on them, once
trap_logic
        stx tl_e
        ldy e_tx,x
        lda e_ty,x
        tax
        lda #F_MOB
        jsr get_entity
        cpx #$ff
        beq tl_r
        stx chp_de
        ldx tl_e
        stx chp_se
        lda e_atk,x
        eor #$ff
        clc
        adc #1
        jsr change_hp
        ldx tl_e
        lda #L_NONE
        sta e_logic,x
        dec e_fbase,x
        lda #54
        jsr sfx
tl_r    ldx tl_e
        rts
tl_e    dta 0

; blink (imp, lich): teleport after attacking
blink   lda e_hp,x
        beq bl_r
        bmi bl_r
        stx bl_e
        ldy #8
bl_p    sty bl_i
        ldx bl_e
        lda #PC_BLINK
        jsr add_rising_particle
        ldy bl_i
        dey
        bne bl_p
        ldx bl_e
        jsr delhash
bl_try  lda #7
        jsr intrnd
        sec
        sbc #3
        sta bl_dx
        lda #7
        jsr intrnd
        sec
        sbc #3
        sta bl_dy
        ldx bl_e
        lda e_tx,x
        clc
        adc bl_dx
        sta bl_tx
        lda e_ty,x
        clc
        adc bl_dy
        sta bl_ty
        ldy bl_tx
        ldx bl_ty
        jsr mget
        jsr is_floor
        bne bl_try
        ldy bl_tx
        ldx bl_ty
        jsr walk_move
        bcc bl_try
        ldx bl_e
        lda bl_tx
        sta e_tx,x
        lda bl_ty
        sta e_ty,x
        lda #L_CHASE
        sta e_logic,x
        jsr addhash
bl_r    rts
bl_e    dta 0
bl_i    dta 0
bl_dx   dta 0
bl_dy   dta 0
bl_tx   dta 0
bl_ty   dta 0

; ---------------------------------------------------------- status
update_status
        lda e_pois,x
        beq us_1
        dec e_pois,x
        stx chp_de
        stx chp_se
        lda #$ff
        jsr change_hp
        ldx chp_de
        cpx pl
        bne us_1
        mwa #s_poison hit_name
us_1    lda e_para,x
        beq us_2
        dec e_para,x
us_2    lda e_conf,x
        beq us_3
        dec e_conf,x
us_3    cpx pl
        bne us_4
        lda pl_blind
        beq us_4
        dec pl_blind
us_4    rts

; ---------------------------------------------------------- combat
; damage of entity X -> A
get_dmg lda e_atk,x
        cpx pl
        bne gd_r
        ldy pl_wpn
        bmi gd_r
        clc
        adc it_atk,y
gd_r    rts

; attack_entity(a = X, d = Y)
attack_entity
        stx ae_a
        sty ae_d
        jsr get_dmg
        eor #$ff
        clc
        adc #1
        ldy ae_d
        sty chp_de
        ldx ae_a
        stx chp_se
        jsr change_hp
        bcc ae_alive
        ldx ae_a
        cpx pl
        bne ae_k
        lda #1
        jsr give_xp
        ldy ae_d
        ldx e_id,y
        lda m_abil,x
        and #AB_TREASURE
        beq ae_k1
        lda #list_food_n    ; blessed food from the food list
        jsr intrnd
        tax
        lda list_food,x
        ldx #3
        jsr make_item
        lda #1
        sta it_idf,x
        jsr give_item
        jmp ae_k
ae_k1   lda m_abil,x
        and #AB_BOSS
        beq ae_k
        lda #1
        sta pl_win
        ldy ae_d
        lda #0
        sta e_pg,y
        lda #<P_BOSS_DEAD_SPRITE
        sta e_fbase,y
        lda #2
        sta e_fmode,y
        lda #1
        sta e_nfr,y
        lda #0
        sta e_fc,y
        sta e_frame,y
ae_k    lda #58
        jsr sfx
        jmp ae_w
ae_alive
        lda #59
        jsr sfx
ae_w    ldx ae_a
        cpx pl
        jne ae_r
        ldy pl_wpn
        jmi ae_r
        ldx ae_d
        lda it_stat,y
        cmp #2
        bne ae_s3
        lda e_pois,x
        clc
        adc #3
        sta e_pois,x
        jmp ae_cur
ae_s3   sta ae_st
        lda #$80
        ldx #0
        jsr chance
        ldx ae_d
        bcc ae_s4
        lda ae_st
        cmp #3
        bne ae_s4
        ldy e_id,x
        lda m_abil,y
        and #AB_BOSS
        bne ae_s4
        lda e_conf,x
        clc
        adc #5
        sta e_conf,x
        lda #L_CONF
        sta e_logic,x
        jmp ae_cur
ae_s4   lda #$4c            ; chance 0.3
        ldx #$cd
        jsr chance
        ldx ae_d
        bcc ae_s5
        lda ae_st
        cmp #4
        bne ae_s5
        ldy e_id,x
        lda m_abil,y
        and #AB_BOSS
        bne ae_s5
        lda e_para,x
        clc
        adc #2
        sta e_para,x
        lda #L_PARA
        sta e_logic,x
        jmp ae_cur
ae_s5   lda #$4c
        ldx #$cd
        jsr chance
        bcc ae_cur
        lda ae_st
        cmp #5
        bne ae_cur
        lda pl
        sta chp_de
        sta chp_se
        lda #1
        jsr change_hp
ae_cur  ; cursed weapons wear out
        ldy pl_wpn
        bmi ae_r
        lda it_trait,y
        cmp #2
        bne ae_r
        lda it_atk,y
        sec
        sbc #1
        sta it_atk,y
        beq ae_shat
        bpl ae_r
ae_shat sty ae_st
        jsr sb_clear
        ldy ae_st
        jsr sb_item_base
        mwa #s_a_shattered sp
        jsr sb_str
        lda #0
        ldx #60
        jsr show_alert_sb
        ldy ae_st
        lda #1
        sta it_trait,y
        ldx ae_st
        lda #1
        jsr unequip_item
        ldx ae_st
        lda #1
        jsr discard_item
        lda #38
        jsr sfx
ae_r    sec
        rts
ae_a    dta 0
ae_d    dta 0
ae_st   dta 0

; change_entity_hp(de = chp_de, se = chp_se, dmg = A signed): C=1 when dead
chp_de  dta 0
chp_se  dta 0           ; entity index, $ff = an item (hit_name already set)
chp_dmg dta 0
change_hp
        sta chp_dmg
        ldx chp_de
        clc
        adc e_hp,x
        bvc ch_1
        lda #$80            ; underflow: very dead
ch_1    sta tmp
        ; min(hp+dmg, hpmax)
        sec
        sbc e_hpmax,x
        bvc ch_2
        eor #$80
ch_2    bmi ch_3
        lda e_hpmax,x
        sta tmp
ch_3    lda tmp
        sta e_hp,x
        lda #10
        sta e_hitc,x
        ; hit_by: remember a name for the hero's epitaph
        cpx pl
        bne ch_nm
        ldy chp_se
        cpy #$ff
        beq ch_nm
        lda e_id,y
        tay
        lda mname_lo,y
        sta hit_name
        lda mname_hi,y
        sta hit_name+1
ch_nm   lda chp_dmg
        jeq ch_part
        bmi ch_neg
        ; "+dmg", colour 11, delay 10
        jsr sb_clear
        lda #G_PLUS
        jsr sb_glyph
        lda chp_dmg
        jsr sb_num
        jsr sb_end
        lda #11
        ldy #10
        ldx chp_de
        jsr add_floater
        jmp ch_part
ch_neg  jsr sb_clear
        lda chp_dmg
        jsr sb_snum
        jsr sb_end
        lda #8
        ldy #$ff
        ldx chp_de
        jsr add_floater
        ; particles flying away from the source
        ldy chp_se
        cpy #$ff
        jeq ch_part
        lda #8
        sta ch_i
chh_pl   ldx chp_de
        ldy chp_se
        ; x = de.tx*8+2+rnd(4)
        lda e_tx,x
        jsr times8
        lda #4
        jsr rnd_frac        ; A = int, X... -> pt_xf
        clc
        adc #2
        adc pt_x
        sta pt_x
        bcc ch_p1
        inc pt_x+1
ch_p1   ldx chp_de
        lda e_ty,x
        asl
        asl
        asl
        sta pt_y
        lda #2
        jsr rnd_frac
        clc
        adc #3
        adc pt_y
        sta pt_y
        ; dx = ssgn(de.tx-se.tx)*(1+rnd(1))
        ldx chp_de
        ldy chp_se
        lda e_tx,x
        sec
        sbc e_tx,y
        jsr ssgn
        sta ch_sx
        jsr rnd16
        lda rnd_hi
        sta pt_dx
        lda #1
        sta pt_dx+1         ; 1 + rnd(1) in 8.8
        lda ch_sx
        jsr neg_dx
        ; dy = ssgn(de.ty-se.ty)*(0.3+rnd(0.3))
        ldx chp_de
        ldy chp_se
        lda e_ty,x
        sec
        sbc e_ty,y
        jsr ssgn
        sta ch_sx
        jsr rnd16
        lda rnd_hi
        sta m_a
        lda #77             ; 0.3 * 256
        sta m_b
        jsr mul8
        lda m_r+1
        clc
        adc #77
        sta pt_dy
        lda #0
        sta pt_dy+1
        lda ch_sx
        jsr neg_dy
        lda #5
        jsr intrnd
        clc
        adc #5
        sta pt_life
        ldx chp_de
        ldy e_id,x
        lda m_col,y
        ora #PC_SINGLE
        sta pt_c
        lda #1
        sta pt_uf
        jsr add_particle
        dec ch_i
        jne chh_pl
ch_part ; the hero dies
        ldx chp_de
        cpx pl
        bne ch_ret
        lda e_hp,x
        beq ch_die
        bpl ch_ret
ch_die  lda e_fmode,x
        bne ch_ret          ; already dying
        lda #51
        jsr sfx
        lda #24
        jsr music
        ldx pl
        lda #100
        sta e_hitc,x
        lda #5
        sta e_fs,x
        lda #1
        sta e_fmode,x
        lda #11
        sta e_nfr,x
ch_ret  ldx chp_de
        lda e_hp,x
        beq ch_dead
        bmi ch_dead
        clc
        rts
ch_dead sec
        rts
ch_i    dta 0
ch_sx   dta 0

; A = flr(rnd(A)) and pt_xf/pt_yf get the fraction (for the particle)
rnd_frac
        jsr intrnd
        pha
        lda rnd_lo
        sta pt_xf
        pla
        rts

; pt_dx/pt_dy *= sign A (A = -1/0/1)
neg_dx  cmp #0
        bne nd_1
        sta pt_dx
        sta pt_dx+1
        rts
nd_1    bpl nd_r
        lda #0
        sec
        sbc pt_dx
        sta pt_dx
        lda #0
        sbc pt_dx+1
        sta pt_dx+1
nd_r    rts
neg_dy  cmp #0
        bne ny_1
        sta pt_dy
        sta pt_dy+1
        rts
ny_1    bpl ny_r
        lda #0
        sec
        sbc pt_dy
        sta pt_dy
        lda #0
        sbc pt_dy+1
        sta pt_dy+1
ny_r    rts

; give_xp(A) to the hero
give_xp sta gx_n
        lda pl_xp
        clc
        adc gx_n
        sta pl_xp
        bcc gx_1
        inc pl_xp+1
gx_1    lda floater_delay
        clc
        adc #10
        sta floater_delay
        jsr sb_clear
        lda #G_PLUS
        jsr sb_glyph
        lda gx_n
        jsr sb_num
        jsr sb_end
        lda #12
        ldy #$ff
        ldx pl
        jsr add_floater
gx_lu   ldy pl_lvl
        iny
        lda pl_xp
        cmp xpreq_lo,y
        lda pl_xp+1
        sbc xpreq_hi,y
        bcc gx_r
        jsr level_up
        jmp gx_lu
gx_r    rts
gx_n    dta 0

level_up
        lda #52
        jsr sfx
        inc pl_lvl
        ldx pl
        lda e_atk,x
        clc
        adc #P_LVL_ATK
        sta e_atk,x
        lda e_hpmax,x
        clc
        adc #P_LVL_HP
        sta e_hpmax,x
        sta e_hp,x
        lda floater_delay
        clc
        adc #10
        sta floater_delay
        mwa #s_lvlup sp
        lda #12
        ldy #5
        ldx pl
        jsr add_floater
        mwa #s_atkup sp
        lda #12
        ldy #25
        ldx pl
        jsr add_floater
        mwa #s_hpup sp
        lda #12
        ldy #25
        ldx pl
        jsr add_floater
        mwa #s_refill sp
        lda #12
        ldy #25
        ldx pl
        jmp add_floater

; ---------------------------------------------------------- per frame
; update_entity: returns C=1 when the move animation is done
update_entity
        ; idle fast path: nothing moves, animates or counts down
        lda e_mt,x
        cmp #9
        bcc ue_full
        lda e_hitc,x
        ora e_pois,x
        ora e_oxl,x
        ora e_oxh,x
        ora e_oyl,x
        ora e_oyh,x
        bne ue_full
        lda e_hp,x
        beq ue_full
        bmi ue_full
        lda e_fl,x
        and #F_ATKD
        bne ue_full
        ldy e_frame,x
        iny
        tya
        cmp e_nfr,x
        bne ue_full
        inc e_t,x
        sec
        rts
ue_full lda e_mt,x
        cmp #9
        bcs ue_1
        inc e_mt,x
ue_1    cpx pl
        bne ue_mob
        lda e_mt,x
        cmp #9
        jcs ue_hit
        ; ox = dx*odist*(8-mt)/8 in 8.8
        lda #8
        sec
        sbc e_mt,x
        sta ue_k
        lda e_dx,x
        jsr ue_off
        sta e_oxl,x
        lda ue_hi
        sta e_oxh,x
        lda e_dy,x
        jsr ue_off
        sta e_oyl,x
        lda ue_hi
        sta e_oyh,x
        jmp ue_hit
ue_mob  ; ox *= 0.5, rounding towards 0
        lda e_oxh,x
        ora e_oxl,x
        beq ue_m2
        lda e_oxh,x
        cmp #$80
        ror e_oxh,x
        ror e_oxl,x
        lda e_oxh,x
        bpl ue_m2
        cmp #$ff
        bne ue_m2
        lda e_oxl,x
        cmp #$ff
        bne ue_m2
        lda #0
        sta e_oxh,x
        sta e_oxl,x
ue_m2   lda e_oyh,x
        ora e_oyl,x
        beq ue_hit
        lda e_oyh,x
        cmp #$80
        ror e_oyh,x
        ror e_oyl,x
        lda e_oyh,x
        bpl ue_hit
        cmp #$ff
        bne ue_hit
        lda e_oyl,x
        cmp #$ff
        bne ue_hit
        lda #0
        sta e_oyh,x
        sta e_oyl,x
ue_hit  lda e_hitc,x
        beq ue_h0
        bmi ue_h0
        dec e_hitc,x
        jmp ue_p
ue_h0   lda e_hp,x
        beq ue_del
        bpl ue_p
ue_del  jsr delhash
        jsr ent_del
        ldx ed_x
ue_p    ; poison bubbles
        lda e_t,x
        and #7
        bne ue_aa
        lda e_pois,x
        beq ue_aa
        stx ue_e
        lda #PC_POISON
        jsr add_rising_particle
        ldx ue_e
ue_aa   ; after_attack (imp, lich): blink
        lda e_mt,x
        cmp #8
        bcc ue_an
        lda e_fl,x
        and #F_ATKD
        beq ue_an
        ldy e_id,x
        lda m_abil,y
        and #AB_BLINK
        beq ue_an
        stx ue_e
        jsr blink
        ldx ue_e
        lda e_fl,x
        and #$ff^F_ATKD
        sta e_fl,x
ue_an   ; animation
        inc e_t,x
        inc e_fc,x
        lda e_fs,x
        cmp e_fc,x
        bcs ue_ret
        lda #0
        sta e_fc,x
        inc e_frame,x
        lda e_frame,x
        cmp e_nfr,x
        bcc ue_ret
        dec e_frame,x
ue_ret  lda e_mt,x
        cmp #8
        rts
ue_k    dta 0
ue_hi   dta 0
ue_e    dta 0
; A = dir (-1/0/1): returns 8.8 of dir*odist*ue_k/8 (A = low, ue_hi = high)
ue_off  stx ue_e
        sta ue_s
        lda e_odist,x
        bpl uo_1
        eor #$ff
        clc
        adc #1
uo_1    sta m_a
        lda ue_k
        sta m_b
        jsr mul8            ; |odist| * k  (<= 64)
        ; * 32 (= /8 * 256)
        lda m_r
        sta ue_lo
        lda #0
        sta ue_hi
        ldy #5
uo_s    asl ue_lo
        rol ue_hi
        dey
        bne uo_s
        ; sign = sgn(dir) * sgn(odist)
        ldx ue_e
        lda ue_s
        beq uo_zero
        eor e_odist,x
        bpl uo_pos
        lda #0
        sec
        sbc ue_lo
        sta ue_lo
        lda #0
        sbc ue_hi
        sta ue_hi
uo_pos  lda ue_lo
        rts
uo_zero lda #0
        sta ue_hi
        rts
ue_s    dta 0
ue_lo   dta 0

; prop update (altar, chest, anvil, well): sparkles
update_prop
        lda e_id,x
        cmp #5
        beq up_sp
        cmp #ID_ALTAR
        beq up_sp
        cmp #ID_ANVIL
        beq up_sp
        cmp #ID_WELL
        bne up_n
up_sp   stx up_e
        lda #7              ; chance 0.03 (1966 = $07ae)
        ldx #$ae
        jsr chance
        ldx up_e
        bcc up_n
        lda e_fl,x
        and #F_USED
        bne up_n
        lda #PC_RISE
        jsr add_rising_particle
        ldx up_e
up_n    jsr update_entity
        clc
        rts
up_e    dta 0

; ---------------------------------------------------------- particles
pt_xf   dta 0
pt_x    dta 0,0
pt_y    dta 0           ; integer part (fraction from pt_yf)
pt_yf   dta 0
pt_dx   dta 0,0
pt_dy   dta 0,0
pt_life dta 0
pt_c    dta 0
pt_uf   dta 0
add_particle
        ldx #0
ap_f    lda pa_life,x
        beq ap_ok
        inx
        cpx #MAXPART
        bne ap_f
        rts                 ; full: dropped
ap_ok   lda pt_xf
        sta pa_xf,x
        lda pt_x
        sta pa_xl,x
        lda pt_x+1
        sta pa_xh,x
        lda pt_yf
        sta pa_yf,x
        lda pt_y
        sta pa_yl,x
        lda pt_dx
        sta pa_dxl,x
        lda pt_dx+1
        sta pa_dxh,x
        lda pt_dy
        sta pa_dyl,x
        lda pt_dy+1
        sta pa_dyh,x
        lda pt_life
        bne ap_1
        lda #1
ap_1    sta pa_life,x
        lda pt_c
        sta pa_c,x
        lda pt_uf
        sta pa_uf,x
        lda #0
        sta pt_xf
        sta pt_yf
        rts

; rising particle on entity X with colour list A
add_rising_particle
        sta pt_c
        stx ar_e
        ; x = tx*8+1+rnd(6)+ox
        lda e_tx,x
        jsr times8
        lda #6
        jsr intrnd
        clc
        adc #1
        adc pt_x
        sta pt_x
        bcc ar_1
        inc pt_x+1
ar_1    ldx ar_e
        lda pt_x
        clc
        adc e_oxh,x
        sta pt_x
        lda e_oxh,x
        and #$80
        beq ar_2
        lda #$ff
ar_2    adc pt_x+1
        sta pt_x+1
        lda rnd_lo
        sta pt_xf
        ; y = ty*8+rnd(6)+oy
        lda e_ty,x
        asl
        asl
        asl
        sta pt_y
        lda #6
        jsr intrnd
        clc
        adc pt_y
        ldx ar_e
        clc
        adc e_oyh,x
        sta pt_y
        lda rnd_lo
        sta pt_yf
        ; dy = -0.1-rnd(0.2)
        jsr rnd16
        lda rnd_hi
        sta m_a
        lda #51             ; 0.2*256
        sta m_b
        jsr mul8
        lda m_r+1
        clc
        adc #26             ; 0.1*256
        eor #$ff
        clc
        adc #1
        sta pt_dy
        lda #$ff
        sta pt_dy+1
        lda #0
        sta pt_dx
        sta pt_dx+1
        lda #20
        jsr intrnd
        clc
        adc #30
        sta pt_life
        lda #2
        sta pt_uf
        jsr add_particle
        ldx ar_e
        rts
ar_e    dta 0

update_particles
        ldx #MAXPART-1
upa_l   lda pa_life,x
        beq upa_n
        lda pa_uf,x
        beq upa_life
        cmp #2
        beq upa_rise
        ; gravity: x+=dx, dx*=0.8, y+=dy, dy+=0.1
        lda pa_xf,x
        clc
        adc pa_dxl,x
        sta pa_xf,x
        lda pa_xl,x
        adc pa_dxh,x
        sta pa_xl,x
        lda pa_dxh,x
        and #$80
        beq upa_g1
        lda #$ff
upa_g1  adc pa_xh,x
        sta pa_xh,x
        ; dx *= 0.8  (dx - dx/4 + dx/16 ~ 0.8125; use 205/256)
        lda pa_dxl,x
        sta m_a
        lda pa_dxh,x
        sta tmp+2
        jsr scale08
        sta pa_dxl,x
        lda tmp+3
        sta pa_dxh,x
        lda #26             ; dy += 0.1
        clc
        adc pa_dyl,x
        sta pa_dyl,x
        bcc upa_rise
        inc pa_dyh,x
upa_rise
        lda pa_yf,x
        clc
        adc pa_dyl,x
        sta pa_yf,x
        lda pa_yl,x
        adc pa_dyh,x
        sta pa_yl,x
upa_life
        dec pa_life,x
upa_n   dex
        bpl upa_l
        rts

; (m_a lo, tmp+2 hi) signed 8.8 * 0.8 -> A lo, tmp+3 hi.  Keeps X.
scale08 stx sc_x
        lda tmp+2
        sta sc_neg
        bpl sc_1
        lda #0
        sec
        sbc m_a
        sta m_a
        lda #0
        sbc tmp+2
        sta tmp+2
sc_1    ; v * 205 / 256 = hi*205 + lo*205/256
        lda m_a
        sta sc_lo
        lda #205
        sta m_b
        jsr mul8
        lda m_r+1
        sta sc_r
        lda #0
        sta sc_r+1
        lda tmp+2
        sta m_a
        lda #205
        sta m_b
        jsr mul8
        lda m_r
        clc
        adc sc_r
        sta sc_r
        lda m_r+1
        adc #0
        sta sc_r+1
        lda sc_neg
        bpl sc_p
        lda #0
        sec
        sbc sc_r
        sta sc_r
        lda #0
        sbc sc_r+1
        sta sc_r+1
sc_p    lda sc_r+1
        sta tmp+3
        lda sc_r
        ldx sc_x
        rts
sc_x    dta 0
sc_neg  dta 0
sc_lo   dta 0
sc_r    dta 0,0

; ---------------------------------------------------------- floaters
; add_floater(sp = text, X = entity, A = colour, Y = delay or $ff)
add_floater
        sta af_c
        stx af_e
        cpy #$ff
        beq af_1
        tya
        clc
        adc floater_delay
        sta floater_delay
af_1    sty af_d
        ldx #0
af_f    lda fl_on,x
        beq af_ok
        inx
        cpx #MAXFLT
        bne af_f
        ; full: reuse the oldest (lowest life)
        ldx #0
af_ok   lda #1
        sta fl_on,x
        lda af_e
        sta fl_e,x
        lda #0
        sta fl_dyl,x
        sta fl_oyl,x
        sta fl_oyh,x
        lda #1
        sta fl_dyh,x
        lda af_c
        sta fl_c,x
        lda #25
        sta fl_life,x
        lda floater_delay
        sta fl_dly,x
        ; copy the text (max 15 glyphs)
        txa
        asl
        asl
        asl
        asl
        sta af_y
        ldy #0
af_cp   lda (sp),y
        sty af_i
        ldy af_y
        sta fl_str,y
        inc af_y
        ldy af_i
        cmp #$ff
        beq af_cd
        iny
        cpy #15
        bne af_cp
        lda #$ff
        ldy af_y
        sta fl_str,y
af_cd   lda af_d
        cmp #$ff
        bne af_r
        lda floater_delay
        clc
        adc #2
        sta floater_delay
af_r    rts
af_c    dta 0
af_e    dta 0
af_d    dta 0
af_i    dta 0
af_y    dta 0

update_floaters
        lda floater_delay
        beq ufl_0
        dec floater_delay
ufl_0   ldx #MAXFLT-1
ufl_l   lda fl_on,x
        beq ufl_n
        lda fl_dly,x
        beq ufl_go
        dec fl_dly,x
        jmp ufl_n
ufl_go  ; oy -= dy; dy *= 0.8; life--
        lda fl_oyl,x
        sec
        sbc fl_dyl,x
        sta fl_oyl,x
        lda fl_oyh,x
        sbc fl_dyh,x
        sta fl_oyh,x
        lda fl_dyl,x
        sta m_a
        lda fl_dyh,x
        sta tmp+2
        jsr scale08
        sta fl_dyl,x
        lda tmp+3
        sta fl_dyh,x
        dec fl_life,x
        bne ufl_n
        lda #0
        sta fl_on,x
ufl_n   dex
        bpl ufl_l
        rts

; ---------------------------------------------------------- abilities
; summon: keeps away from the hero and summons a monster every few turns
summon_logic
        stx sm_e
        jsr los_to_pl
        bcs sm_see
        ldx sm_e
        lda #L_WAIT
        sta e_logic,x
        mwa #s_quest sp
        lda #10
        ldy #$ff
        jmp add_floater
sm_see  ldx sm_e
        lda e_chg,x
        and #$30
        beq sm_spawn
        lda e_chg,x
        sec
        sbc #$10
        sta e_chg,x
        jsr flee_logic
        ldx sm_e
        lda #L_CHASE
        sta e_logic,x
        rts
sm_spawn
        ldy #1
sm_d    sty sm_k
        lda e_tx,x
        clc
        adc dirx,y
        sta a0
        lda e_ty,x
        clc
        adc diry,y
        sta a1
        ldy a0
        ldx a1
        jsr walk_move
        bcs sm_put
        ldx sm_e
        ldy sm_k
        iny
        cpy #5
        bne sm_d
        rts
sm_put  lda #P_SUMMON_ID
        jsr make_mob
        bcs sm_full
        jsr addhash
        lda #57
        jsr sfx
sm_full ldx sm_e
        lda e_chg,x
        and #$cf
        ora #P_SUMMON_WAIT*16
        sta e_chg,x
        rts
sm_e    dta 0
sm_k    dta 0

; pounce: leap along a free row/column to the tile next to the hero.
; C=1 when it leapt
try_pounce
        stx tp_e
        ldy pl
        lda #0
        sta tp_dx
        sta tp_dy
        lda e_tx,x
        cmp e_tx,y
        bne tp_row
        lda e_ty,y
        sec
        sbc e_ty,x
        jsr ssgn
        sta tp_dy
        jmp tp_go
tp_row  lda e_ty,x
        cmp e_ty,y
        bne tp_no
        lda e_tx,y
        sec
        sbc e_tx,x
        jsr ssgn
        sta tp_dx
tp_go   lda e_tx,x
        sta tp_x
        lda e_ty,x
        sta tp_y
        lda #0
        sta tp_n
tp_l    lda tp_x
        clc
        adc tp_dx
        sta tp_nx
        lda tp_y
        clc
        adc tp_dy
        sta tp_ny
        ldy pl
        lda tp_nx
        cmp e_tx,y
        bne tp_c
        lda tp_ny
        cmp e_ty,y
        beq tp_end
tp_c    ldy tp_nx
        ldx tp_ny
        jsr walk_move
        bcc tp_no
        lda tp_nx
        sta tp_x
        lda tp_ny
        sta tp_y
        inc tp_n
        lda tp_n
        cmp #9
        bcc tp_l
tp_no   ldx tp_e
        clc
        rts
tp_end  lda tp_n
        cmp #2
        bcc tp_no           ; a single step is no leap
        ldx tp_e
        jsr delhash
        lda tp_x
        sta e_tx,x
        lda tp_y
        sta e_ty,x
        jsr addhash
        lda tp_dx
        sta a4
        lda tp_dy
        sta a5
        lda tp_n
        asl
        asl
        asl
        eor #$ff
        clc
        adc #1
        sta a6              ; -(steps * 8)
        jsr move_anim
        lda #0
        sta e_fc,x
        sta e_frame,x
        lda #63
        jsr sfx
        ldx tp_e
        sec
        rts
tp_e    dta 0
tp_dx   dta 0
tp_dy   dta 0
tp_x    dta 0
tp_y    dta 0
tp_nx   dta 0
tp_ny   dta 0
tp_n    dta 0

; curse: the hero forgets the explored map
forget_map
        jsr fog_reset
        jsr clear_map
        jmp update_fog

; steal a random backpack item (not the weapon in hand)
steal_item
        ldx #0
        ldy #0
si_f    lda it_on,y
        beq si_n
        lda it_eq,y
        bne si_n
        tya
        sta gd_pool,x
        inx
si_n    iny
        cpy #8
        bne si_f
        txa
        beq si_r
        jsr intrnd
        tax
        ldy gd_pool,x
        lda #0
        sta it_on,y
        dec inv_n
si_r    rts

; steal the weapon in hand (even a cursed one)
steal_weapon
        ldx pl_wpn
        ldy pl
        lda e_hpmax,y
        sec
        sbc it_hpmax,x
        sta e_hpmax,y
        lda #0
        sta it_eq,x
        sta it_on,x
        dec inv_n
        lda #$ff
        sta pl_wpn
        rts
