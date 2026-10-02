; Four adjacent source rooms form a 1024x200 level. Camera movement is
; one-way and encounter-gated. CPU maps rebuild a single VRAM panorama cache.
; Cache: $30000..$61fff, pitch 1024. Tile atlases: $20000..$2ffff.
map_ptr = $d3
world_init
        lda #0
        sta camera
        sta camera+1
        sta travel
        lda stage
        cmp cached_stage
        jeq world_ready
        sta cached_stage
        tax
        lda map_lo,x
        sta map_ptr
        lda map_hi,x
        sta map_ptr+1
        lda atlas_hi,x
        sta atlas_base
        lda #0
        sta map_row
world_row
        lda #0
        sta map_col
world_tile
        ldy map_col
        lda (map_ptr),y
        tax
        lda tile_lo,x
        sta command
        lda tile_hi,x
        clc
        adc atlas_base
        sta command+1
        lda #2
        sta command+2
        lda #8
        sta command+3
        lda #0
        sta command+4
        lda #7
        sta command+12
        sta command+14
        lda #0
        sta command+13
        jsr opaque_defaults
        lda #0
        sta command+9
        lda #4
        sta command+10
        ; Tile column * 8, tile row * 8192, relative to VRAM $30000.
        lda map_col
        asl
        asl
        asl
        sta command+6
        lda map_col
        lsr
        lsr
        lsr
        lsr
        lsr
        sta command+7
        lda map_row
        and #7
        asl
        asl
        asl
        asl
        asl
        ora command+7
        sta command+7
        lda map_row
        lsr
        lsr
        lsr
        clc
        adc #3
        sta command+8
        jsr blit
        inc map_col
        lda map_col
        cmp #128
        jne world_tile
        clc
        lda map_ptr
        adc #128
        sta map_ptr
        bcc next_world_row
        inc map_ptr+1
next_world_row
        inc map_row
        lda map_row
        cmp #25
        jne world_row
        jsr wait_blit
world_ready
        rts

world_update
        lda remaining
        beq allow_travel
        rts
allow_travel
        lda #1
        sta travel
        ; Scroll only when walking right past the screen's middle.
        lda stick
        and #8
        bne world_done
        lda px
        cmp #138
        bcc world_done
        ldx wave
        lda camera+1
        cmp gate_hi,x
        bcc scroll_forward
        bne gate_reached
        lda camera
        cmp gate_lo,x
        bcs gate_reached
scroll_forward
        dec px
        dec px
        clc
        lda camera
        adc #2
        sta camera
        bcc world_done
        inc camera+1
world_done
        rts
gate_reached
        lda wave
        cmp #2
        beq last_gate
        inc wave
        lda #0
        sta travel
        jmp new_wave
last_gate
        lda px
        cmp #248
        bcc world_done
        inc stage
        lda stage
        cmp #4
        beq world_victory
        jmp new_stage
world_victory
        lda #3
        sta stage
        lda #WIN
        sta mode
        rts

camera dta a(0)
travel dta 0
cached_stage dta 0                ; first panorama is prebuilt in the XEX
map_row dta 0
map_col dta 0
atlas_base dta 0
atlas_hi dta $00,$40,$80,$c0
map_lo dta <world_map_0,<world_map_1,<world_map_2,<world_map_3
map_hi dta >world_map_0,>world_map_1,>world_map_2,>world_map_3
gate_lo dta <256,<512,<704
gate_hi dta >256,>512,>704
tile_lo :256 dta <(#*64)
tile_hi :256 dta >(#*64)
