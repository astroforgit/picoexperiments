; ------------------------------------------------------------------
; Object system: a line-by-line port of init_object / move / collide.
; Objects live in parallel arrays indexed by X.  New objects are
; appended; destroyed ones are marked (o_type=0) and squeezed out
; after each update/draw pass, which keeps PICO-8's table order.
; ------------------------------------------------------------------

jv      = $fc               ; indirect jump vector (zero page)

; A = type, io_x/io_y = position.  On return X = self again,
; C=0 and Y = new object, or C=1 when nothing was created.
init_object
        pha
        tay
        lda type_nofruit,y
        beq io_ok
        ldy lvl
        lda got_fruit,y
        beq io_ok
        pla
        ldx self
        sec
        rts
io_ok   ldy obj_count
        cpy #MAXOBJ
        bcc io_room
        pla
        ldx self
        sec
        rts
io_room inc obj_count
        pla
        sta o_type,y
        tax
        lda type_tile,x
        sta o_spr,y
        lda #0
        sta o_sprf,y
        sta o_flx,y
        sta o_fly,y
        sta o_sxl,y
        sta o_sxh,y
        sta o_syl,y
        sta o_syh,y
        sta o_rxl,y
        sta o_rxh,y
        sta o_ryl,y
        sta o_ryh,y
        sta o_hbx,y
        sta o_hby,y
        sta o_v0,y
        sta o_v1,y
        sta o_v2,y
        sta o_v3,y
        sta o_v4,y
        sta o_sxf,y
        sta o_syf,y
        sta o_rxf,y
        sta o_ryf,y
        lda #8
        sta o_hbw,y
        sta o_hbh,y
        lda #1
        sta o_coll,y
        sta o_sol,y
        lda io_x
        sta o_x,y
        lda io_y
        sta o_y,y
        lda o_type,y
        cmp #T_PLAYER
        bne io_np
        sty pl_idx
io_np   jsr list_add
        lda self
        pha
        sty self
        tya
        tax
        lda o_type,x
        asl
        tay
        lda init_tab,y
        sta jv
        lda init_tab+1,y
        sta jv+1
        jsr jump_jv
        ldy self
        pla
        sta self
        tax
        clc
        rts
jump_jv jmp (jv)

destroy_object
        lda o_type,x
        cmp #T_PLAYER
        bne do_np
        lda #$fe
        sta pl_idx
do_np   lda #0
        sta o_type,x
        lda #1
        sta need_compact
        rts

; append object Y to its type list (if any).  Y preserved.
list_add
        lda o_type,y
        tax
        lda type_listed,x
        beq la_done
        tax
        lda list_n-1,x
        inc list_n-1,x
        clc
        adc list_base,x
        tax
        tya
        sta type_lists,x
la_done rts

; rebuild the type lists and the player index after compaction
rebuild_lists
        lda #0
        sta list_n
        sta list_n+1
        sta list_n+2
        sta list_n+3
        lda #$fe
        sta pl_idx
        ldy #0
rl_loop cpy obj_count
        bcs rl_done
        lda o_type,y
        cmp #T_PLAYER
        bne rl_np
        sty pl_idx
rl_np   jsr list_add
        iny
        bne rl_loop
rl_done rts

; squeeze out destroyed objects, keeping the order
compact
        lda need_compact
        jeq cp_done
        lda #0
        sta need_compact
        ldx #0
        ldy #0
cp_loop cpx obj_count
        jcs cp_end
        lda o_type,x
        jeq cp_skip
        stx compact_w
        cpy compact_w
        jeq cp_same
        .rept NFIELDS
        lda o_type+#*MAXOBJ,x
        sta o_type+#*MAXOBJ,y
        .endr
cp_same iny
cp_skip inx
        jmp cp_loop
cp_end  sty obj_count
        jmp rebuild_lists
cp_done rts

; ---------------------------------------------------------- collision
; collide: A = type, col_ox/col_oy offsets, X = object.
; C=1 and Y = first colliding object of that type.  X preserved.
collide
        sta col_ty
        jsr collide_box
        stx tmp+6
        lda col_ty
        cmp #T_PLAYER
        beq cl_player
        tay
        lda type_listed,y
        bne cl_list
        ldy #0
        jmp cl_loop
; the only player: cached index
cl_player
        ldy pl_idx
        jmi cl_none
        cpy tmp+6
        jeq cl_none
        jmp cl_test
; springs / fall floors / fake walls / platforms: the type's list
cl_list tax
        lda list_base,x
        sta tmp+7
        clc
        adc list_n-1,x
        sta tmp+5
cl_ll   ldx tmp+7
        cpx tmp+5
        bcs cl_nonex
        inc tmp+7
        ldy type_lists,x
        lda o_type,y
        cmp col_ty
        bne cl_ll
        cpy tmp+6
        beq cl_ll
        jsr cl_box
        bcc cl_ll
        ldx tmp+6
        rts
cl_nonex
        ldx tmp+6
        clc
        rts
cl_test jsr cl_box
        rts
; C=1 when object Y is collideable and overlaps the box
cl_box  lda o_coll,y
        beq cl_bno
        lda o_x,y
        clc
        adc o_hbx,y
        cmp c_r
        bcs cl_bno
        clc
        adc o_hbw,y
        cmp c_l
        beq cl_bno
        bcc cl_bno
        lda o_y,y
        clc
        adc o_hby,y
        cmp c_b
        bcs cl_bno
        clc
        adc o_hbh,y
        cmp c_t
        beq cl_bno
        bcc cl_bno
        sec
        rts
cl_bno  clc
        rts

; box of object X moved by col_ox/col_oy -> c_l,c_r,c_t,c_b
collide_box
        lda o_x,x
        clc
        adc o_hbx,x
        clc
        adc col_ox
        sta c_l
        clc
        adc o_hbw,x
        sta c_r
        lda o_y,x
        clc
        adc o_hby,x
        clc
        adc col_oy
        sta c_t
        clc
        adc o_hbh,x
        sta c_b
        rts
cl_loop cpy obj_count
        bcs cl_none
        lda o_type,y
        cmp col_ty
        bne cl_next
        cpy tmp+6
        beq cl_next
        lda o_coll,y
        beq cl_next
        lda o_x,y
        clc
        adc o_hbx,y
        cmp c_r
        bcs cl_next
        clc
        adc o_hbw,y
        cmp c_l
        beq cl_next
        bcc cl_next
        lda o_y,y
        clc
        adc o_hby,y
        cmp c_b
        bcs cl_next
        clc
        adc o_hbh,y
        cmp c_t
        beq cl_next
        bcc cl_next
        sec
        rts
cl_next iny
        bne cl_loop
cl_none clc
        rts

; check(player,ox,oy) shortcut: A = ox, Y = oy
check_player
        sta col_ox
        sty col_oy
        lda #T_PLAYER
        jmp collide

; is_solid(col_ox,col_oy) for object X -> C
is_solid
        lda col_oy
        beq is_nopl
        bmi is_nopl
        pha
        lda #0
        sta col_oy
        lda #T_PLATFORM
        jsr collide
        pla
        sta col_oy
        bcs is_nopl
        lda #T_PLATFORM
        jsr collide
        bcc is_nopl
        rts
is_nopl lda #1
        jsr hit_tiles
        bcs is_yes
        lda #T_FALLFLOOR
        jsr collide
        bcs is_yes
        lda #T_FAKEWALL
        jmp collide
is_yes  rts

; is_ice(col_ox,col_oy) -> C
is_ice  lda #$10
; tile flag test over the object's hitbox moved by col_ox/col_oy
hit_tiles
        sta sa_f
        lda o_x,x
        clc
        adc o_hbx,x
        clc
        adc col_ox
        sta sa_x
        lda o_y,x
        clc
        adc o_hby,x
        clc
        adc col_oy
        sta sa_y
        lda o_hbw,x
        sta sa_w
        lda o_hbh,x
        sta sa_h
; tile_flag_at(sa_x,sa_y,sa_w,sa_h,sa_f) -> C.  X preserved.
tile_flag_at
        jsr tile_range
        bcs tf_no
        stx tmp+6
        lda sa_j0
        sta sa_j
tf_row  lda sa_j
        asl
        asl
        asl
        asl
        clc
        adc sa_i0
        tay
        lda sa_i0
        sta tmp+5
tf_col  lda room_tiles,y
        tax
        lda tile_flags,x
        and sa_f
        bne tf_yes
        iny
        lda tmp+5
        cmp sa_i1
        inc tmp+5
        bcc tf_col
        lda sa_j
        cmp sa_j1
        inc sa_j
        bcc tf_row
        ldx tmp+6
tf_no   clc
        rts
tf_yes  ldx tmp+6
        sec
        rts

; tile index ranges of the box: sa_i0..sa_i1, sa_j0..sa_j1; C=1 if empty
tile_range
        lda sa_x
        jsr tr_lo
        sta sa_i0
        lda sa_x
        clc
        adc sa_w
        sec
        sbc #1
        jsr tr_hi
        bcs tr_empty
        sta sa_i1
        cmp sa_i0
        bcc tr_empty
        lda sa_y
        jsr tr_lo
        sta sa_j0
        lda sa_y
        clc
        adc sa_h
        sec
        sbc #1
        jsr tr_hi
        bcs tr_empty
        sta sa_j1
        cmp sa_j0
        bcc tr_empty
        clc
        rts
tr_empty sec
        rts
; max(0, flr(v/8)) for biased v
tr_lo   sec
        sbc #BIAS
        bcs tr_lo1
        lda #0
        rts
tr_lo1  lsr
        lsr
        lsr
        rts
; min(15, flr(v/8)); C=1 when v<0 (no tiles)
tr_hi   sec
        sbc #BIAS
        bcc tr_hi_neg
        lsr
        lsr
        lsr
        cmp #16
        bcc tr_hi1
        lda #15
tr_hi1  clc
        rts
tr_hi_neg sec
        rts

; spikes_at(sa_x,sa_y,sa_w,sa_h) with speed signs sp_xs/sp_ys -> C
sp_xs   dta 0
sp_ys   dta 0
spikes_at
        jsr tile_range
        bcc sp_go
        clc
        rts
sp_go   stx tmp+6
        lda sa_j0
        sta sa_j
sp_row  lda sa_i0
        sta tmp+5
sp_col  lda sa_j
        asl
        asl
        asl
        asl
        ora tmp+5
        tay
        lda room_tiles,y
        cmp #17
        beq sp_17
        cmp #27
        beq sp_27
        cmp #43
        beq sp_43
        cmp #59
        beq sp_59
sp_next lda tmp+5
        cmp sa_i1
        inc tmp+5
        bcc sp_col
        lda sa_j
        cmp sa_j1
        inc sa_j
        bcc sp_row
        ldx tmp+6
        clc
        rts
sp_yes  ldx tmp+6
        sec
        rts
; up-facing spikes: ((y+h-1)%8>=6 or y+h==j*8+8) and yspd>=0
sp_17   lda sp_ys
        bmi sp_next
        lda sa_y
        clc
        adc sa_h
        sta tmp+4
        sec
        sbc #1
        and #7
        cmp #6
        bcs sp_yes
        lda sa_j
        asl
        asl
        asl
        clc
        adc #8+BIAS
        cmp tmp+4
        beq sp_yes
        bne sp_next
; down-facing: y%8<=2 and yspd<=0
sp_27   lda sp_ys
        beq sp_27a
        bpl sp_next
sp_27a  lda sa_y
        and #7
        cmp #3
        bcc sp_yes
        bcs sp_next
; right-facing: x%8<=2 and xspd<=0
sp_43   lda sp_xs
        beq sp_43a
        bpl sp_next
sp_43a  lda sa_x
        and #7
        cmp #3
        bcc sp_yes
        bcs sp_next
; left-facing: ((x+w-1)%8>=6 or x+w==i*8+8) and xspd>=0
sp_59   lda sp_xs
        bmi sp_next
        lda sa_x
        clc
        adc sa_w
        sta tmp+4
        sec
        sbc #1
        and #7
        cmp #6
        bcs sp_yes
        lda tmp+5
        asl
        asl
        asl
        clc
        adc #8+BIAS
        cmp tmp+4
        beq sp_yes
        jmp sp_next

; ---------------------------------------------------------- movement
; obj.move(spd.x, spd.y) for object X (16.16 remainders)
obj_move
        lda o_rxf,x
        clc
        adc o_sxf,x
        sta o_rxf,x
        lda o_rxl,x
        adc o_sxl,x
        sta o_rxl,x
        lda o_rxh,x
        adc o_sxh,x
        sta o_rxh,x
        ; amount = flr(rem.x + 0.5)
        lda o_rxl,x
        clc
        adc #$80
        lda o_rxh,x
        adc #0
        sta amount
        lda o_rxh,x
        sec
        sbc amount
        sta o_rxh,x
        lda #0
        jsr move_x
        lda o_ryf,x
        clc
        adc o_syf,x
        sta o_ryf,x
        lda o_ryl,x
        adc o_syl,x
        sta o_ryl,x
        lda o_ryh,x
        adc o_syh,x
        sta o_ryh,x
        lda o_ryl,x
        clc
        adc #$80
        lda o_ryh,x
        adc #0
        sta amount
        lda o_ryh,x
        sec
        sbc amount
        sta o_ryh,x
        jmp move_y

; move_x(amount, start=A) for object X.  PICO-8's loop runs
; for i=start,abs(amount), i.e. abs(amount)-start+1 steps.
move_x
        sta tmp+7
        lda o_sol,x
        bne mx_sol
        lda o_x,x
        clc
        adc amount
        sta o_x,x
        rts
mx_sol  lda amount            ; a zero move of a resting object can
        bne mx_go               ; only zero what is zero already
        lda o_sxf,x
        ora o_sxl,x
        ora o_sxh,x
        ora o_rxf,x
        ora o_rxl,x
        ora o_rxh,x
        beq mx_done
        lda #0
mx_go   jsr amount_steps
        beq mx_done
mx_loop lda step
        sta col_ox
        lda #0
        sta col_oy
        jsr is_solid
        bcs mx_hit
        lda o_x,x
        clc
        adc step
        sta o_x,x
        dec cnt
        bne mx_loop
mx_done rts
mx_hit  lda #0
        sta o_sxf,x
        sta o_sxl,x
        sta o_sxh,x
        sta o_rxf,x
        sta o_rxl,x
        sta o_rxh,x
        rts

move_y
        lda #0
        sta tmp+7
        lda o_sol,x
        bne my_sol
        lda o_y,x
        clc
        adc amount
        sta o_y,x
        rts
my_sol  lda amount
        bne my_go
        lda o_syf,x
        ora o_syl,x
        ora o_syh,x
        ora o_ryf,x
        ora o_ryl,x
        ora o_ryh,x
        beq my_done
        lda #0
my_go   jsr amount_steps
        beq my_done
my_loop lda #0
        sta col_ox
        lda step
        sta col_oy
        jsr is_solid
        bcs my_hit
        lda o_y,x
        clc
        adc step
        sta o_y,x
        dec cnt
        bne my_loop
my_done rts
my_hit  lda #0
        sta o_syf,x
        sta o_syl,x
        sta o_syh,x
        sta o_ryf,x
        sta o_ryl,x
        sta o_ryh,x
        rts

; step = sign(amount), cnt = abs(amount)-start+1 (Z=1 when none)
amount_steps
        lda amount
        beq as_zero
        bmi as_neg
        lda #1
        sta step
        lda amount
        jmp as_cnt
as_neg  lda #$ff
        sta step
        lda #0
        sec
        sbc amount
        jmp as_cnt
as_zero lda #0
        sta step
as_cnt  sec
        sbc tmp+7
        bcc as_none
        clc
        adc #1
        sta cnt
        rts
as_none lda #0
        sta cnt
        rts

; ---------------------------------------------------------- math
; za = appr(za, zt, zm)   (16.16 in 3 bytes, zm >= 0)
appr24
        sec
        lda za
        sbc zt
        sta tmp
        lda za+1
        sbc zt+1
        sta tmp+1
        lda za+2
        sbc zt+2
        bmi ap_up
        ora tmp
        ora tmp+1
        beq ap_up
        ; za > zt: za = max(za - zm, zt)
        sec
        lda za
        sbc zm
        sta za
        lda za+1
        sbc zm+1
        sta za+1
        lda za+2
        sbc zm+2
        sta za+2
        sec
        lda za
        sbc zt
        lda za+1
        sbc zt+1
        lda za+2
        sbc zt+2
        bpl ap_ok
ap_tgt  lda zt
        sta za
        lda zt+1
        sta za+1
        lda zt+2
        sta za+2
ap_ok   rts
ap_up   ; za <= zt: za = min(za + zm, zt)
        clc
        lda za
        adc zm
        sta za
        lda za+1
        adc zm+1
        sta za+1
        lda za+2
        adc zm+2
        sta za+2
        sec
        lda zt
        sbc za
        lda zt+1
        sbc za+1
        lda zt+2
        sbc za+2
        bmi ap_tgt
        rts

; A = sign(za) as -1/0/1
sign24  lda za+2
        bmi s24_neg
        ora za+1
        ora za
        beq s24_z
        lda #1
        rts
s24_neg lda #$ff
s24_z   rts

; za = -za
neg24   sec
        lda #0
        sbc za
        sta za
        lda #0
        sbc za+1
        sta za+1
        lda #0
        sbc za+2
        sta za+2
        rts

; za <- spd.x / spd.y of object X, and back
get_sx  lda o_sxf,x
        sta za
        lda o_sxl,x
        sta za+1
        lda o_sxh,x
        sta za+2
        rts
put_sx  lda za
        sta o_sxf,x
        lda za+1
        sta o_sxl,x
        lda za+2
        sta o_sxh,x
        rts
get_sy  lda o_syf,x
        sta za
        lda o_syl,x
        sta za+1
        lda o_syh,x
        sta za+2
        rts
put_sy  lda za
        sta o_syf,x
        lda za+1
        sta o_syl,x
        lda za+2
        sta o_syh,x
        rts

; za = za * (zm+1:zm) / 65536, floored like PICO-8's fixed point multiply
mul24   lda za+2
        sta mu_sign
        bpl mu_pos
        jsr neg24
mu_pos  lda zm
        sta mu_f
        lda zm+1
        sta mu_f+1
        lda #0
        sta mu_r
        sta mu_r+1
        sta mu_r+2
        ldy #16
mu_loop lda mu_f
        lsr
        bcc mu_sh
        clc
        lda mu_r
        adc za
        sta mu_r
        lda mu_r+1
        adc za+1
        sta mu_r+1
        lda mu_r+2
        adc za+2
        sta mu_r+2
mu_sh   ror mu_r+2
        ror mu_r+1
        ror mu_r
        ror mu_f+1
        ror mu_f
        dey
        bne mu_loop
        lda mu_r
        sta za
        lda mu_r+1
        sta za+1
        lda mu_r+2
        sta za+2
        lda mu_sign
        bpl mu_done
        jsr neg24
        lda mu_f
        ora mu_f+1
        beq mu_done
        lda za              ; floor: one step further down
        sec
        sbc #1
        sta za
        bcs mu_done
        lda za+1
        sbc #0
        sta za+1
        lda za+2
        sbc #0
        sta za+2
mu_done rts
mu_sign dta 0
mu_f    dta 0,0
mu_r    dta 0,0,0

; z16 = z16 * A / 256 (signed 8.8, unsigned A) - hair only
mulfrac16
        sta mul_b
        lda z16+1
        php
        bpl mf_pos
        jsr neg_z16
mf_pos  lda z16
        sta mul_a
        jsr mul8            ; lo*f
        lda mul_r+1
        sta tmp+2
        lda z16+1
        sta mul_a
        jsr mul8            ; hi*f
        lda mul_r
        clc
        adc tmp+2
        sta z16
        lda mul_r+1
        adc #0
        sta z16+1
        plp
        bpl mf_done
        jsr neg_z16
mf_done rts
neg_z16 sec
        lda #0
        sbc z16
        sta z16
        lda #0
        sbc z16+1
        sta z16+1
        rts

; mul_r = mul_a * mul_b (unsigned).  Y clobbered.
mul8    lda #0
        ldy #8
        lsr mul_a
ml_loop bcc ml_skip
        clc
        adc mul_b
ml_skip ror
        ror mul_a
        dey
        bne ml_loop
        sta mul_r+1
        lda mul_a
        sta mul_r
        rts

; xorshift16 -> A
rnd8    lda rng+1
        lsr
        lda rng
        ror
        eor rng+1
        sta rng+1
        ror
        eor rng
        sta rng
        eor rng+1
        sta rng+1
        rts

; A = flr(rnd(A))  (0..A-1).  Y clobbered.
rnd_n   sta mul_b
        jsr rnd8
        sta mul_a
        jsr mul8
        lda mul_r+1
        rts

; A = 0/1
maybe   jsr rnd8
        and #1
        rts
