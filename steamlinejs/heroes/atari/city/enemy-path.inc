; Enemy targeting and path search. Loaded with the battle tables (RAM $6000+),
; outside the full main code area; scratch tables live in page 6.
        .local battle
path_seen  = $0600           ; page 6 is free; 42 bytes each
path_first = $0630
path_queue = $0660
path_head  = $0690
path_tail  = $0691
path_cell  = $0692
path_start = $0693
path_dir   = $0694
; A cell -> C set and enemy_target/enemy_best_dist when the acting enemy could
; hit a living hero from that cell: within range (melee 1) and clear sight.
; The nearest such hero wins; ties go to the lower unit index.
.proc target_from
        sta hunt_cell
        ldx enemy_id
        ldy unit_type,x
        lda type_shoot_range,y
        bne ?range
        lda #1
?range  sta hunt_range
        lda #$FF
        sta enemy_target
        lda #$7F
        sta enemy_best_dist
        ldx #0
?hero   cpx hero_count
        bcs ?done
        lda unit_hp,x
        beq ?next
        lda unit_team,x
        bne ?next
        stx scan_id
        lda unit_cell,x
        tax
        lda hunt_cell
        jsr distance_cells
        cmp hunt_range
        beq ?near
        bcs ?restore
?near   cmp enemy_best_dist
        bcs ?restore
        sta hunt_dist
        lda (work_ptr),y        ; bit 7: a tree blocks the line
        bmi ?restore
        mva hunt_dist enemy_best_dist
        mva scan_id enemy_target
?restore
        ldx scan_id
?next   inx
        jmp ?hero
?done   lda enemy_target
        cmp #$FF
        beq ?none
        sec
        rts
?none   clc
        rts
.endp
hunt_cell  dta 0
hunt_range dta 0
hunt_dist  dta 0

; Breadth-first search from the acting enemy over open cells (no tree, no
; living fighter), in neighbour order. Returns in A the first step towards the
; nearest cell from which target_from succeeds, or FF. Keeps enemy_target.
.proc path_step
        ldx #CELLS-1
?clear  lda terrain,x
        sta path_seen,x         ; trees count as already visited
        dex
        bpl ?clear
        ldx #0
?units  cpx unit_count
        bcs ?seeded
        lda unit_hp,x
        beq ?un
        ldy unit_cell,x
        lda #1
        sta path_seen,y
?un     inx
        bne ?units
?seeded ldx enemy_id
        lda unit_cell,x
        sta path_start
        sta path_queue
        mva #0 path_head
        mva #1 path_tail
?pop    ldx path_head
        cpx path_tail
        bcs ?none
        lda path_queue,x
        sta path_cell
        inc path_head
        cmp path_start
        beq ?expand
        jsr target_from
        bcc ?expand
        ldx path_cell
        lda path_first,x
        rts
?expand mva #0 path_dir
?dir    lda path_cell
        ldx path_dir
        jsr get_neighbour
        cmp #$FF
        beq ?skip
        tax
        lda path_seen,x
        bne ?skip
        lda #1
        sta path_seen,x
        txa
        ldy path_tail
        sta path_queue,y
        inc path_tail
        lda path_cell
        cmp path_start
        bne ?inherit
        txa                     ; a neighbour of the start is its own first step
        sta path_first,x
        jmp ?skip
?inherit
        ldy path_cell
        lda path_first,y
        sta path_first,x
?skip   inc path_dir
        lda path_dir
        cmp #6
        bcc ?dir
        jmp ?pop
?none   lda #$FF
        rts
.endp

        .endl
