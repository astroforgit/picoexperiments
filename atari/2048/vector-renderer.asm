; The PICO-8 vector track is compiled into clipped line lists for every
; original road segment. Render the selected list into the hidden VBXE page.
view_buffer=$7800
line_ptr=$d3

load_view
        ; Resolve course index entry at track_ptr + seg*3.
        lda seg
        asl
        sta index_offset
        lda seg+1
        rol
        sta index_offset+1
        clc
        lda index_offset
        adc seg
        sta index_offset
        lda index_offset+1
        adc seg+1
        sta index_offset+1
        clc
        lda track_ptr
        adc index_offset
        sta ptr
        lda track_ptr+1
        adc index_offset+1
        sta ptr+1
        ldy #0
        lda (ptr),y
reg_view_bank sta BANKSEL
        iny
        lda (ptr),y
        sta zp2
        iny
        lda (ptr),y
        sta zp2+1
        ldy #0
view_copy
        lda (zp2),y
        sta view_buffer,y
        iny
        bne view_copy
        rts
index_offset dta a(0)

draw_game
        mwa #0 fx
        lda #0
        sta fy
        mwa #320 fw
        lda #200
        sta fh
        lda #0
        sta fc
        jsr fill
        lda #80
        sta pixel_x_base
        jsr load_view
        jsr curve_drift
        jsr camera_phase
        lda framebuffer_bank
        asl
        asl
        asl
        asl
        sta pixel_base
        jsr draw_vectors
        jsr draw_ai
        jsr draw_player
        jsr draw_hud
        rts

curve_drift
        lda view_buffer
        sta new_heading
        sec
        sbc old_heading
        and #15
        sta turn_delta
        lda new_heading
        sta old_heading
        lda turn_delta
        cmp #8
        bcc drift_positive
        ora #$f0
        clc
        adc lane
        sta lane
        rts
drift_positive
        clc
        adc lane
        sta lane
        rts
turn_delta dta 0
new_heading dta 0

camera_phase
        ; Index the 16-heading by 12-substep translation table.
        lda view_buffer
        asl
        asl
        asl
        sta phase_offset
        lda view_buffer
        asl
        asl
        asl
        asl
        clc
        adc phase_offset
        sta phase_offset
        lda #0
        adc #0
        sta phase_offset+1
        lda move_count
        asl
        clc
        adc phase_offset
        sta phase_offset
        bcc phase_no_carry
        inc phase_offset+1
phase_no_carry
        clc
        lda #<phase_table
        adc phase_offset
        sta ptr
        lda #>phase_table
        adc phase_offset+1
        sta ptr+1
        ldy #0
        lda (ptr),y
        sta shift_x
        iny
        lda (ptr),y
        sta shift_y
        rts
phase_offset dta a(0)
shift_x dta 0
shift_y dta 0

draw_vectors
        mwa #view_buffer+30 line_ptr
        lda view_buffer+1
        sta line_color
        lda view_buffer+2
        sta line_count
        jsr draw_group
        lda #13
        sta line_color
        lda view_buffer+3
        sta line_count
        jsr draw_group
        lda #1
        sta line_color
        lda view_buffer+4
        sta line_count
        jsr draw_group
        lda #11
        sta line_color
        lda view_buffer+5
        sta line_count
        jmp draw_group

draw_group
        lda line_count
        beq group_done
line_next
        ldy #0
        lda (line_ptr),y
        sec
        sbc shift_x
        sta x0
        iny
        lda (line_ptr),y
        sec
        sbc shift_y
        sta y0
        iny
        lda (line_ptr),y
        sec
        sbc shift_x
        sta x1
        iny
        lda (line_ptr),y
        sec
        sbc shift_y
        sta y1
        jsr draw_line
        clc
        lda line_ptr
        adc #4
        sta line_ptr
        bcc line_ptr_ok
        inc line_ptr+1
line_ptr_ok
        dec line_count
        bne line_next
group_done rts
line_color dta 8
line_count dta 0

; 8-bit Bresenham. Endpoints may wrap through zero after camera translation;
; the original source segments are shorter than 128 pixels on either axis.
draw_line
        lda x1
        sec
        sbc x0
        cmp #128
        bcc x_forward
        eor #$ff
        clc
        adc #1
        sta delta_x
        lda #$ff
        sta step_x
        jmp y_delta
x_forward
        sta delta_x
        lda #1
        sta step_x
y_delta
        lda y1
        sec
        sbc y0
        cmp #128
        bcc y_forward
        eor #$ff
        clc
        adc #1
        sta delta_y
        lda #$ff
        sta step_y
        jmp choose_axis
y_forward
        sta delta_y
        lda #1
        sta step_y
choose_axis
        lda delta_x
        cmp delta_y
        bcc line_y_major
        lsr
        sta line_error
line_x_loop
        jsr plot_pixel
        lda x0
        cmp x1
        beq line_done
        clc
        adc step_x
        sta x0
        lda line_error
        sec
        sbc delta_y
        sta line_error
        bcs line_x_loop
        lda y0
        clc
        adc step_y
        sta y0
        lda line_error
        clc
        adc delta_x
        sta line_error
        jmp line_x_loop
line_y_major
        lda delta_y
        lsr
        sta line_error
line_y_loop
        jsr plot_pixel
        lda y0
        cmp y1
        beq line_done
        clc
        adc step_y
        sta y0
        lda line_error
        sec
        sbc delta_x
        sta line_error
        bcs line_y_loop
        lda x0
        clc
        adc step_x
        sta x0
        lda line_error
        clc
        adc delta_y
        sta line_error
        jmp line_y_loop
line_done rts
x0 dta 0
y0 dta 0
x1 dta 0
y1 dta 0
delta_x dta 0
delta_y dta 0
step_x dta 0
step_y dta 0
line_error dta 0

plot_pixel
        lda x0
        cmp #160
        bcs pixel_done
        lda y0
        cmp #160
        bcs pixel_done
        tay
        lda x0
        clc
        adc pixel_x_base
        sta pixel_x
        lda row_low,y
        clc
        adc pixel_x
        sta pixel_store+1
        lda row_high,y
        adc #0
        sta pixel_high
        and #15
        clc
        adc #$90
        sta pixel_store+2
        lda pixel_high
        lsr
        lsr
        lsr
        lsr
        clc
        adc pixel_base
        ora #$80
reg_plot_bank sta BANKSEL
        lda line_color
pixel_store sta MEMW
pixel_done rts
pixel_high dta 0
pixel_base dta 0
pixel_x_base dta 80
pixel_x dta 0

; Rotate the original three-point car outline through sixteen headings.
draw_player
        lda #80
        sta car_x
        sta car_y
        lda lane
        beq player_triangle
        bpl lane_positive
        eor #$ff
        clc
        adc #1
        tax
lane_neg_loop
        lda car_x
        sec
        sbc view_buffer+6
        sta car_x
        lda car_y
        sec
        sbc view_buffer+7
        sta car_y
        dex
        bne lane_neg_loop
        jmp player_triangle
lane_positive
        tax
lane_pos_loop
        lda car_x
        clc
        adc view_buffer+6
        sta car_x
        lda car_y
        clc
        adc view_buffer+7
        sta car_y
        dex
        bne lane_pos_loop
player_triangle
        lda #8
        sta line_color
        lda view_buffer
        jmp draw_triangle

; A rival appears at its actual nearby centerline segment.
draw_ai
        lda game_type
        bne ai_done
        lda ai_lap
        cmp lap
        bne ai_done
        lda ai_seg+1
        cmp seg+1
        bne ai_done
        lda ai_seg
        sec
        sbc seg
        bcc ai_behind
        cmp #6
        bcs ai_done
        clc
        adc #5
        jmp ai_index
ai_behind
        lda seg
        sec
        sbc ai_seg
        cmp #6
        bcs ai_done
        sta ai_distance
        lda #5
        sec
        sbc ai_distance
ai_index
        asl
        tax
        lda view_buffer+8,x
        cmp #160
        bcs ai_done
        sec
        sbc shift_x
        sta car_x
        lda view_buffer+9,x
        cmp #160
        bcs ai_done
        sec
        sbc shift_y
        sta car_y
        lda #9
        sta line_color
        lda view_buffer
        jmp draw_triangle
ai_done rts
ai_distance dta 0

; A = heading; line_color and car_x/car_y are already set.
draw_triangle
        asl
        sta vertex_offset
        asl
        clc
        adc vertex_offset
        tax
        lda car_vertices,x
        clc
        adc car_x
        sta tri_x0
        inx
        lda car_vertices,x
        clc
        adc car_y
        sta tri_y0
        inx
        lda car_vertices,x
        clc
        adc car_x
        sta tri_x1
        inx
        lda car_vertices,x
        clc
        adc car_y
        sta tri_y1
        inx
        lda car_vertices,x
        clc
        adc car_x
        sta tri_x2
        inx
        lda car_vertices,x
        clc
        adc car_y
        sta tri_y2
        lda tri_x0
        sta x0
        lda tri_y0
        sta y0
        lda tri_x1
        sta x1
        lda tri_y1
        sta y1
        jsr draw_line
        lda tri_x1
        sta x0
        lda tri_y1
        sta y0
        lda tri_x2
        sta x1
        lda tri_y2
        sta y1
        jsr draw_line
        lda tri_x2
        sta x0
        lda tri_y2
        sta y0
        lda tri_x0
        sta x1
        lda tri_y0
        sta y1
        jmp draw_line
vertex_offset dta 0
car_x dta 80
car_y dta 80
tri_x0 dta 0
tri_y0 dta 0
tri_x1 dta 0
tri_y1 dta 0
tri_x2 dta 0
tri_y2 dta 0

draw_minimap
        lda course
        asl
        tax
        lda minimap_ptrs,x
        sta line_ptr
        lda minimap_ptrs+1,x
        sta line_ptr+1
        ldy #0
        lda (line_ptr),y
        sec
        sbc #1
        sta mini_count
        lda #1
        sta mini_pos
        lda #6
        sta line_color
mini_next
        ldy mini_pos
        lda (line_ptr),y
        sta x0
        iny
        lda (line_ptr),y
        sta y0
        iny
        lda (line_ptr),y
        sta x1
        iny
        lda (line_ptr),y
        sta y1
        jsr draw_line
        clc
        lda mini_pos
        adc #2
        sta mini_pos
        dec mini_count
        bne mini_next
        rts
mini_count dta 0
mini_pos dta 0
