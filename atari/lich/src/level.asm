; ------------------------------------------------------------------
; Level generator (generate_level and its helpers of the cart).
; ------------------------------------------------------------------
T_FLOOR = 1
T_WALL  = 48
T_DOORH = 4
T_DOORV = 5
RT_ENTRY = 1
RT_STORAGE = 2
RT_NA   = 3
RT_EXIT = 4
RT_BOSS = 5
RT_TREASURE = 6
RT_SHRINE = 7
RT_SMITHY = 8
RT_POOL = 9

; dirx/diry for directions 1..8 (index 0 unused)
dirx    dta 0,-1,1,0,0,-1,1,1,-1
diry    dta 0,0,0,-1,1,1,-1,1,-1

generate_level
        lda #0
        sta n_rooms
        sta n_pool
        sta dropped
        sta removed
        sta mobs_placed
        ; mobs_to_place = the floor's monster budget
        ldx pl_depth
        lda fl_budget,x
        sta mobs_to_place
        ; mobs_per_room = flr(0.5 + to_place/size) - 1 = (2a+b) div 2b - 1
        lda mobs_to_place
        asl
        clc
        adc num_rooms
        sta m_r
        lda #0
        rol
        sta m_r+1
        lda num_rooms
        asl
        sta tmp
        jsr div16_8         ; A = m_r / tmp
        sec
        sbc #1
        sta mobs_per_room   ; may be $ff (= no mobs)
        ; clear the map
        lda #0
        tay
gl_clr  sta TMAP,y
        sta TMAP+$100,y
        sta TMAP+$200,y
        sta TMAP+$300,y
        sta TMAP+$400,y
        sta TMAP+$500,y
        sta TMAP+$600,y
        sta TMAP+$700,y
        sta TMAP+$800,y
        sta TMAP+$900,y
        sta TMAP+$a00,y
        sta TMAP+$b00,y
        sta TMAP+$c00,y
        sta TMAP+$d00,y
        sta TMAP+$e00,y
        sta TMAP+$f00,y
        iny
        bne gl_clr
        ; a hand-made floor replaces the generator
        ldx pl_depth
        lda floor_plan,x
        cmp #$ff
        beq gl_gen
        jsr load_floor
        jmp gl_post
gl_gen  ; entry room
        lda #P_ENTRY_RND
        jsr intrnd
        clc
        adc #P_ENTRY_MIN
        sta u0
        lda #P_ENTRY_RND
        jsr intrnd
        clc
        adc #P_ENTRY_MIN
        sta u1
        lda #RT_ENTRY
        jsr make_room
        lda u0
        sta rm_w,x
        lda u1
        sta rm_h,x
        lda #RT_STORAGE
        jsr make_room
        ; for i=#rooms,size-1
        lda #2
        sta lp
gl_more lda lp
        cmp num_rooms
        bcs gl_rd
        lda #>P_STORAGE_CHANCE
        ldx #<P_STORAGE_CHANCE
        jsr chance
        lda #RT_NA
        bcc gl_na
        lda #RT_STORAGE
gl_na   jsr make_room
        inc lp
        jmp gl_more
gl_rd   ; room pool
        lda #RT_EXIT
        ldx pl_depth
        cpx #P_LAST_FLOOR
        bcc gl_ex
        lda #RT_BOSS
gl_ex   jsr pool_add
        ldx pl_depth
        lda fl_treasure,x
        sta lp
gl_tr   lda lp
        beq gl_tr_d
        lda #RT_TREASURE
        jsr pool_add
        dec lp
        jmp gl_tr
gl_tr_d lda pl_depth
        cmp #P_SHRINE_FROM
        bcc gl_sh
        lda #RT_SHRINE
        jsr pool_add
gl_sh   lda pl_depth
        cmp #P_SMITHY_FROM
        bcc gl_sm
        lda #RT_SMITHY
        jsr pool_add
gl_sm   lda pl_depth
        cmp #P_POOL_FROM
        bcc gl_place
        lda #RT_POOL
        jsr pool_add
        ; place rooms until both lists are empty
gl_place
        lda n_rooms
        bne gl_p1
        lda n_pool
        beq gl_placed
        lda rm_pool
        pha
        ldx #0
        jsr pool_del
        pla
        jsr make_room
gl_p1   lda #0
        sta lp
gl_iter lda lp
        cmp n_rooms
        bcs gl_place
        ldx lp
        lda #0
        sta pr_drop
        jsr place_room
        bcs gl_ok
        ; not placed: move it (a dropped room was already removed)
        lda pr_drop
        bne gl_iter
        ldx lp
        ; rnd_elem({1,2,2,2,3,4})
        jsr rnd16
        ldy #1
        cmp #P_MOVE_T1
        bcc gl_dir
        iny
        cmp #P_MOVE_T2
        bcc gl_dir
        iny
        cmp #P_MOVE_T3
        bcc gl_dir
        iny
gl_dir
        lda rm_x,x
        clc
        adc dirx,y
        sta rm_x,x
        lda rm_y,x
        clc
        adc diry,y
        sta rm_y,x
        inc lp
        jmp gl_iter
gl_ok   ldx lp
        jsr room_del
        jmp gl_iter
gl_placed
        ; mobs everywhere
gl_mob1 lda mobs_to_place
        cmp mobs_placed
        bcc gl_mob1d
        lda #128
        jsr intrnd
        tay
        lda #32
        jsr intrnd
        tax
        lda #0
        jsr place_mob
        jmp gl_mob1
gl_mob1d
        ; mimics: mobs_to_place = mobs_placed + depth - 3
        ldx pl_depth
        lda mobs_placed
        clc
        adc fl_mimic,x
        sta mobs_to_place
gl_mob2 lda mobs_to_place
        cmp mobs_placed
        bcc gl_mob2d
        lda #128
        jsr intrnd
        tay
        lda #32
        jsr intrnd
        sta tmp+7
        ldx #P_MIMIC_ID
        lda m_code,x
        ldx tmp+7
        jsr place_mob
        jmp gl_mob2
gl_mob2d
gl_post jsr auto_tile
        jsr make_entities
        jmp wall_fix

; A = m_r / tmp (8-bit quotient)
div16_8 lda #0
        ldx #16
dv_l    asl m_r
        rol m_r+1
        rol
        cmp tmp
        bcc dv_s
        sbc tmp
        inc m_r
dv_s    dex
        bne dv_l
        lda m_r
        rts

; add type A to room_pool
pool_add
        ldx n_pool
        sta rm_pool,x
        inc n_pool
        rts
; delete room_pool entry X
pool_del
pd_l    inx
        cpx n_pool
        bcs pd_d
        lda rm_pool,x
        sta rm_pool-1,x
        jmp pd_l
pd_d    dec n_pool
        rts

; make_room(type A) -> X = new room
make_room
        sta tmp+7
        ldx n_rooms
        stx tmp+6
        lda #12
        sta rm_x,x
        sta rm_y,x
        lda #P_ROOM_W_RND
        jsr intrnd
        clc
        adc #P_ROOM_W_MIN
        sta rm_w,x
        lda #P_ROOM_H_RND
        jsr intrnd
        clc
        adc #P_ROOM_H_MIN
        sta rm_h,x
        lda #0
        sta rm_oob,x
        lda tmp+7
        sta rm_typ,x
        lda #P_NFLOORW
        jsr intrnd
        tay
        lda floor_weights,y
        sta rm_flr,x
        lda tmp+7
        cmp #RT_BOSS
        bne mr_1
        lda #P_BOSS_W
        sta rm_w,x
        lda #P_BOSS_H
        sta rm_h,x
mr_1    inc n_rooms
        rts

; delete room X from the room list
room_del
rd_l    inx
        cpx n_rooms
        bcs rd_d
        lda rm_x,x
        sta rm_x-1,x
        lda rm_y,x
        sta rm_y-1,x
        lda rm_w,x
        sta rm_w-1,x
        lda rm_h,x
        sta rm_h-1,x
        lda rm_oob,x
        sta rm_oob-1,x
        lda rm_typ,x
        sta rm_typ-1,x
        lda rm_flr,x
        sta rm_flr-1,x
        jmp rd_l
rd_d    dec n_rooms
        rts

; mset_flr(Y, X, A): C=1 when the tile was floor and is now A
mset_flr
        sta mf_v
        jsr mget
        jsr is_floor
        bne mf_no
        lda mf_v
        jsr mset
        sec
        rts
mf_no   clc
        rts
mf_v    dta 0

; place_mob(Y = x, X = y, A = sprite or 0 for a random mob)
place_mob
        sta pm_id
        stx pm_x
        sty pm_y
        ; mobs = m_anim of non-props available at this depth (rnd consumed always)
        ldx #0
        ldy #2
pm_l    lda m_prop,y
        bne pm_n
        lda m_depth,y
        cmp pl_depth
        beq pm_a
        bcs pm_n
pm_a    lda m_code,y
        sta pm_list,x
        inx
pm_n    iny
        cpy #NENT+1
        bne pm_l
        lda pm_id
        bne pm_go
        txa
        jsr intrnd
        tax
        lda pm_list,x
        sta pm_id
pm_go   ldx pm_x
        ldy pm_y
        lda pm_id
        jsr mset_flr
        bcc pm_d
        inc mobs_placed
pm_d    rts
pm_id   dta 0
pm_x    dta 0
pm_y    dta 0
pm_list :40 dta 0

; x, y = get_rnd_pos(room u7) -> Y, X
get_rnd_pos
        ldx u7
        lda rm_w,x
        sec
        sbc #2
        jsr intrnd
        clc
        adc rm_x,x
        adc #1
        pha
        lda rm_h,x
        sec
        sbc #2
        jsr intrnd
        clc
        adc rm_y,x
        adc #1
        tax
        pla
        tay
        rts

; place_room(room X): C=1 when the room is done (placed or given up)
place_room
        stx u7
        lda rm_x,x
        sta u0              ; rx
        lda rm_y,x
        sta u1              ; ry
        lda rm_w,x
        sta u2              ; rw
        lda rm_h,x
        sta u3              ; rh
        ; bounds: ry<0 or ry+rh>31 or rx<0 or rx+rw>127
        lda u1
        bmi pr_oob
        clc
        adc u3
        cmp #32
        bcs pr_oob
        lda u0
        bmi pr_oob
        clc
        adc u2
        cmp #128
        bcc pr_in
pr_oob  ldx u7
        inc rm_oob,x
        lda rm_oob,x
        cmp #6
        bcc pr_fail
        lda rm_typ,x
        jsr pool_add
        ldx u7
        jsr room_del
        inc dropped
        inc pr_drop
pr_fail clc
        rts
pr_drop dta 0
pr_in   ldx u7
        lda #0
        sta rm_oob,x
        ; interior must be empty
        lda u1
        clc
        adc #1
        sta u5              ; ty
        lda u1
        clc
        adc u3
        sec
        sbc #1
        sta u6              ; last row + 1
        lda u0
        clc
        adc u2
        sec
        sbc #1
        sta u4              ; last column + 1
pr_ic_y lda u5
        cmp u6
        bcs pr_ic_ok
        tax
        lda row_lo,x
        sta ptr
        lda row_hi,x
        sta ptr+1
        ldy u0
        iny
pr_ic_x cpy u4
        bcs pr_ic_nx
        lda (ptr),y
        bne pr_fail2
        iny
        bne pr_ic_x
pr_ic_nx inc u5
        jmp pr_ic_y
pr_fail2 clc
        rts
pr_ic_ok
        ; save the background and draw the room
        lda #0
        sta u6              ; bg index
        lda u1
        sta u5
pr_dy   ldy u0
        sty u4
pr_dx   ldy u4
        ldx u5
        jsr mget
        ldx u6
        sta room_bg,x
        inc u6
        ; tile
        lda #T_FLOOR
        sta tmp+7
        ldx u7
        lda rm_flr,x
        beq pr_fl
        asl
        asl
        adc #28
        jsr get_floor
        sta tmp+7
pr_fl   lda u4
        cmp u0
        beq pr_wall
        lda u5
        cmp u1
        beq pr_wall
        lda u0
        clc
        adc u2
        sec
        sbc #1
        cmp u4
        beq pr_wall
        lda u1
        clc
        adc u3
        sec
        sbc #1
        cmp u5
        bne pr_set
pr_wall lda #T_WALL
        sta tmp+7
pr_set  ldy u4
        ldx u5
        lda tmp+7
        jsr mset
        inc u4
        lda u0
        clc
        adc u2
        cmp u4
        bne pr_dx
        inc u5
        lda u1
        clc
        adc u3
        cmp u5
        bne pr_dy
        ; decorations: chance 0.4 -> rnd(w/2) pots/boxes
        lda #>P_DECO_CHANCE
        ldx #<P_DECO_CHANCE
        jsr chance
        bcc pr_nodec
        lda u2
        jsr intrnd
        lsr
        sta lp2
pr_dec  lda lp2
        beq pr_nodec
        jsr get_rnd_pos
        sty tmp+5
        stx tmp+6
        jsr pot_code
        sta tmp+4
        lda #>P_BODY_CHANCE
        ldx #<P_BODY_CHANCE
        jsr chance
        bcc pr_d1
        ldx #21             ; body
        lda m_code,x
        sta tmp+4
pr_d1   ldy tmp+5
        ldx tmp+6
        lda tmp+4
        jsr mset_flr
        dec lp2
        jmp pr_dec
pr_nodec
        ; spikes from depth 3: chance 0.2 -> 1+rnd(w/2)
        lda pl_depth
        cmp #P_SPIKES_FROM
        bcc pr_nosp
        lda #>P_SPIKES_CHANCE
        ldx #<P_SPIKES_CHANCE
        jsr chance
        bcc pr_nosp
        lda u2
        jsr intrnd
        lsr
        clc
        adc #1
        sta lp2
pr_sp   jsr get_rnd_pos
        lda m_code+13       ; spikes
        jsr mset_flr
        dec lp2
        bne pr_sp
pr_nosp
        ; room centre
        lda u2
        lsr
        clc
        adc u0
        sta rcx
        lda u3
        lsr
        clc
        adc u1
        sta rcy
        ldx u7
        lda rm_typ,x
        cmp #RT_ENTRY
        bne pr_t1
        lda #P_TILE_START
        jsr rset
        ldy rcx
        dey
        ldx rcy
        dex
        lda #T_WALL
        jsr mset
        inx
        jsr mset
        jmp pr_mobs
pr_t1   cmp #RT_BOSS
        bne pr_t2
        lda #27
        ldy u0
        iny
        iny
        ldx u1
        inx
        inx
        jsr place_piece
        lda u0
        clc
        adc #6
        tay
        lda u1
        clc
        adc #3
        tax
        lda #0
        jsr place_piece
        lda m_code+P_BOSS_ID
        jsr rset
        jmp pr_mobs
pr_t2   cmp #RT_EXIT
        bne pr_t3
        lda #P_TILE_EXIT
        jsr rset
        jmp pr_mobs
pr_t3   cmp #RT_POOL
        bne pr_t4
        lda m_code+25       ; well
        jsr rset
        jmp pr_mobs
pr_t4   cmp #RT_SMITHY
        bne pr_t5
        lda m_code+20       ; anvil
        jsr rset
        ldy rcx
        dey
        ldx rcy
        lda #P_TILE_ANVIL_DECO
        jsr mset
        jmp pr_mobs
pr_t5   cmp #RT_SHRINE
        bne pr_t6
        lda m_code+9        ; altar
        jsr rset
        ldy rcx
        iny
        ldx rcy
        lda #P_TILE_ALTAR_DECO
        jsr mset
        jmp pr_mobs
pr_t6   cmp #RT_STORAGE
        bne pr_t7
        lda u2
        jsr intrnd
        sta lp2
pr_st1  lda lp2
        beq pr_st2
        jsr get_rnd_pos
        sty tmp+5
        stx tmp+6
        jsr pot_code
        ldy tmp+5
        ldx tmp+6
        jsr mset
        dec lp2
        jmp pr_st1
pr_st2  lda #1
        sta lp2
pr_st3  lda u2
        sec
        sbc #2
        cmp lp2
        jcc pr_mobs
        lda #>P_SHELF_CHANCE
        ldx #<P_SHELF_CHANCE
        jsr chance
        bcc pr_st4
        lda u0
        clc
        adc lp2
        tay
        ldx #6              ; shelves
        lda m_code,x
        ldx u1
        inx
        jsr mset
pr_st4  inc lp2
        jmp pr_st3
pr_t7   cmp #RT_TREASURE
        bne pr_t8
        lda u2
        jsr intrnd
        clc
        adc #1
        sta lp2
pr_tr   jsr get_rnd_pos
        lda m_code+13       ; spikes
        jsr mset
        dec lp2
        bne pr_tr
        lda m_code+5        ; chest
        jsr rset
        jmp pr_mobs
pr_t8   ; ordinary room: furniture pieces when at least 6x6
        lda u2
        cmp #6
        bcc pr_mobs
        lda u3
        cmp #6
        bcc pr_mobs
        lda u2
        sec
        sbc #2
        ldx #0
pr_am   cmp #5
        bcc pr_am_d
        sbc #5
        inx
        jmp pr_am
pr_am_d stx lp2             ; amnt
        lda #0
        sta tmp+3           ; ix
pr_pc   lda tmp+3
        cmp lp2
        bcs pr_mobs
        ; piece step*(depth-1)+intrnd(n) at rx+1+intrnd(2)+ix*4, ry+2+intrnd(h-7)
        lda #P_PIECE_RND
        jsr intrnd
        ldx pl_depth
pr_ps   dex
        beq pr_ps2
        clc
        adc #P_PIECE_STEP
        jmp pr_ps
pr_ps2  cmp #P_NPIECES
        bcc pr_ps3
        lda #P_NPIECES-1
pr_ps3  sta tmp+4
        lda #2
        jsr intrnd
        sta tmp+5
        lda tmp+3
        asl
        asl
        clc
        adc tmp+5
        adc u0
        adc #1
        sta tmp+5
        lda u3
        sec
        sbc #7
        bcs pr_pc1
        lda #0
pr_pc1  jsr intrnd
        clc
        adc u1
        adc #2
        tax
        ldy tmp+5
        lda tmp+3
        pha
        lda tmp+4
        jsr place_piece
        pla
        sta tmp+3
        inc tmp+3
        jmp pr_pc
pr_mobs
        lda mobs_placed
        sta u6              ; prev_mobs_placed
        ldx u7
        lda rm_typ,x
        cmp #RT_ENTRY
        beq pr_doors
        lda mobs_per_room
        bmi pr_doors
        beq pr_doors
        sta lp2
pr_mb   jsr get_rnd_pos
        lda #0
        jsr place_mob
        dec lp2
        bne pr_mb
pr_doors
        lda #0
        sta dc
        ; right wall
        lda u0
        clc
        adc u2
        sec
        sbc #1
        sta a0
        sta a2
        lda u1
        sta a1
        clc
        adc u3
        sec
        sbc #1
        sta a3
        jsr door_side
        ; left wall
        lda u0
        sta a0
        sta a2
        lda u1
        sta a1
        clc
        adc u3
        sec
        sbc #1
        sta a3
        jsr door_side
        ; bottom wall
        lda u0
        sta a0
        clc
        adc u2
        sec
        sbc #1
        sta a2
        lda u1
        clc
        adc u3
        sec
        sbc #1
        sta a1
        sta a3
        jsr door_side
        ; top wall
        lda u0
        sta a0
        clc
        adc u2
        sec
        sbc #1
        sta a2
        lda u1
        sta a1
        sta a3
        jsr door_side
        lda dc
        bne pr_done
        ldx u7
        lda rm_typ,x
        cmp #RT_ENTRY
        beq pr_done
        ; no doors: undo the room
        lda #0
        sta lp2
        lda u1
        sta u5
pr_uy   lda u0
        sta u4
pr_ux   ldx lp2
        lda room_bg,x
        inc lp2
        ldy u4
        ldx u5
        jsr mset
        inc u4
        lda u0
        clc
        adc u2
        cmp u4
        bne pr_ux
        inc u5
        lda u1
        clc
        adc u3
        cmp u5
        bne pr_uy
        ldx u7
        lda rm_typ,x
        jsr pool_add
        lda u6
        sta mobs_placed
        inc removed
pr_done sec
        rts

; A = map code of a pot: the two pot kinds alternate (rnd)
pot_code
        lda #2
        jsr intrnd
        tax
        lda m_code+18
        cpx #0
        beq pc_r
        lda m_code+4
pc_r    rts

; rset(A): mset(rcx, rcy, A)
rset    ldy rcx
        ldx rcy
        jmp mset

; get_floor(A = offset): 20% plain floor, else offset+0..2
get_floor
        sta tmp+6
        lda #>P_FLOOR_PLAIN_CHANCE
        ldx #<P_FLOOR_PLAIN_CHANCE
        jsr chance
        bcc gf_1
        lda #T_FLOOR
        rts
gf_1    lda #3
        jsr intrnd
        clc
        adc tmp+6
        rts

; place_piece(A = piece, Y = tx, X = ty)
place_piece
        sta tmp+2
        sty tmp+3
        stx tmp+4
        ; pieces index = p*9, (x*3+y)
        lda tmp+2
        asl
        asl
        asl
        clc
        adc tmp+2
        sta tmp+5
        lda #0
        sta tmp+6           ; x
pp_x    lda #0
        sta tmp+7           ; y
pp_y    ldx tmp+5
        lda pieces,x
        inc tmp+5
        sta pp_op
        cmp #15
        bne pp_1
        lda #T_WALL
        jmp pp_2
pp_1    clc
        adc #63
        sta pp_np
        ; chance(depth/10): +16
        ldx pl_depth
        lda d10_lo,x
        pha
        lda d10_hi,x
        tax
        pla
        jsr chance_xa
        lda pp_np
        bcc pp_2
        adc #15             ; C=1: +16
pp_2    sta pp_np
        lda pp_op
        beq pp_n
        lda tmp+3
        clc
        adc tmp+6
        tay
        lda tmp+4
        clc
        adc tmp+7
        tax
        lda pp_np
        jsr mset
pp_n    inc tmp+7
        lda tmp+7
        cmp #3
        bne pp_y
        inc tmp+6
        lda tmp+6
        cmp #3
        bne pp_x
        rts
pp_op   dta 0
pp_np   dta 0
; depth/10 in 16.16 (0.1 = $199a)
d10_lo
        .rept 16
        dta <(#*$199a)
        .endr
d10_hi
        .rept 16
        dta >(#*$199a)
        .endr
; chance with X = high, A = low
chance_xa
        pha
        txa
        tay
        pla
        tax
        tya
        jmp chance

; doors on the wall a0,a1 .. a2,a3; dc += candidates, one door placed
door_side
        lda #0
        sta nd
        lda a0
        cmp a2
        bne ds_h
        ; vertical wall: neighbours left/right, door tile T_DOORV
        lda m_code+8        ; vertical door
        sta door_tile
ds_vl   ldy a0
        iny
        ldx a1
        jsr mget
        jsr is_floor
        bne ds_vn
        ldy a0
        dey
        ldx a1
        jsr mget
        jsr is_floor
        bne ds_vn
        ldx nd
        lda a0
        sta door_x,x
        lda a1
        sta door_y,x
        inc nd
ds_vn   lda a1
        cmp a3
        beq ds_done
        inc a1
        jmp ds_vl
ds_h    lda m_code+7    ; horizontal door
        sta door_tile
ds_hl   ldy a0
        ldx a1
        inx
        jsr mget
        jsr is_floor
        bne ds_hn
        ldy a0
        ldx a1
        dex
        jsr mget
        jsr is_floor
        bne ds_hn
        ldx nd
        lda a0
        sta door_x,x
        lda a1
        sta door_y,x
        inc nd
ds_hn   lda a0
        cmp a2
        beq ds_done
        inc a0
        jmp ds_hl
ds_done lda dc
        clc
        adc nd
        sta dc
        ; place_a_door
        lda nd
        beq ds_ret
        jsr intrnd
        tax
        lda door_x,x
        pha
        lda door_y,x
        pha
        lda #>P_DOOR_CHANCE
        ldx #<P_DOOR_CHANCE
        jsr chance
        lda door_tile
        bcs ds_t
        lda #T_FLOOR
ds_t    sta tmp+7
        pla
        tax
        pla
        tay
        lda tmp+7
        jmp mset
ds_ret  rts
nd      dta 0
door_tile dta 0
door_x  :16 dta 0
door_y  :16 dta 0

; auto_tile(48): walls take the shape of their wall neighbours
; (left 2, right 4, up 1, down 8)
auto_tile
        ldx #0
at_y    lda row_lo,x
        sta ptr
        lda row_hi,x
        sta ptr+1
        ; rows above / below (the map row itself when outside: no wall there)
        lda row_lo-1,x
        sta ptr2
        lda row_hi-1,x
        sta ptr2+1
        cpx #0
        bne at_1
        mwa #at_zero ptr2
at_1    lda row_lo+1,x
        sta sp2
        lda row_hi+1,x
        sta sp2+1
        cpx #31
        bne at_2
        mwa #at_zero sp2
at_2    ldy #0
at_x    lda (ptr),y
        cmp #T_WALL
        bne at_n
        lda #T_WALL
        sta at_nt
        cpy #0
        beq at_r
        dey
        lda (ptr),y
        iny
        jsr at_flag
        bcc at_r
        lda at_nt
        ora #2
        sta at_nt
at_r    cpy #127
        beq at_u
        iny
        lda (ptr),y
        dey
        jsr at_flag
        bcc at_u
        lda at_nt
        ora #4
        sta at_nt
at_u    lda (ptr2),y
        jsr at_flag
        bcc at_d
        lda at_nt
        ora #1
        sta at_nt
at_d    lda (sp2),y
        jsr at_flag
        bcc at_w
        lda at_nt
        ora #8
        sta at_nt
at_w    lda at_nt
        sta (ptr),y
at_n    iny
        bpl at_x
        inx
        cpx #32
        jne at_y
        rts
at_nt   dta 0
; C=1 when tile A has flag 7 (keeps X, Y)
at_flag stx af_x
        tax
        lda tile_flags,x
        asl
        ldx af_x
        rts
af_x    dta 0

; wall_fix: the tile below a wall shows the wall's shadow
wall_fix
        ldx #0
wf_y    lda row_lo,x
        sta ptr
        lda row_hi,x
        sta ptr+1
        lda row_lo+1,x
        sta ptr2
        lda row_hi+1,x
        sta ptr2+1
        ldy #0
wf_x    lda (ptr),y
        jsr at_flag
        bcc wf_n
        lda (ptr2),y
        cmp #1
        bne wf_1
        lda #2
        bne wf_set
wf_1    cmp #0
        bne wf_2
        lda #3
        bne wf_set
wf_2    cmp #32
        bcc wf_n
        cmp #43
        bcs wf_n
        sta tmp
        and #3
        cmp #3
        beq wf_n
        lda tmp
        ora #3
wf_set  sta (ptr2),y
wf_n    iny
        bpl wf_x
        inx
        cpx #31
        bne wf_y
        rts

; ---------------------------------------------------------- hand-made floors
; load_floor(A = floor map): RLE ($fe count value) from VRAM $3e000 into
; TMAP through the MEMAC window, then back to the blitter list bank.
load_floor
        tax
        lda floor_lo,x
        sta ptr2
        lda floor_hi,x
        lsr
        lsr
        lsr
        lsr
        clc
        adc #$3e
        sta lf_bank
        lda floor_hi,x
        and #$0f
        ora #>MEMW
        sta ptr2+1
        lda lf_bank
        jsr set_bank
        mwa #TMAP sp2
lf_loop jsr lf_byte
        cmp #$fe
        bne lf_one
        jsr lf_byte
        sta lf_n
        jsr lf_byte
        ldx lf_n
lf_run  jsr lf_put
        bcs lf_done
        dex
        bne lf_run
        beq lf_loop
lf_one  jsr lf_put
        bcc lf_loop
lf_done lda bcb_bank
        jmp set_bank
; next byte of the stream -> A (keeps X)
lf_byte ldy #0
        lda (ptr2),y
        inc ptr2
        bne lfb_r
        inc ptr2+1
        pha
        lda ptr2+1
        cmp #>(MEMW+$1000)
        bne lfb_p
        lda #>MEMW
        sta ptr2+1
        inc lf_bank
        lda lf_bank
        stx lf_x
        jsr set_bank
        ldx lf_x
lfb_p   pla
lfb_r   rts
; store A in the map; C=1 when the map is full (keeps X)
lf_put  ldy #0
        sta (sp2),y
        inc sp2
        bne lfp_c
        inc sp2+1
lfp_c   pha
        lda sp2+1
        cmp #>(TMAP+$1000)
        pla                 ; (keeps C)
        rts
lf_bank dta 0
lf_n    dta 0
lf_x    dta 0
