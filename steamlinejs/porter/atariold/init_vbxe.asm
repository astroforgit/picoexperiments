// VBXE initialisation for Porter Patch (derived from gacek/init_vbxe.asm).
// One uniform shape size: 8x8 indexed-colour, 256 shapes contiguous at $00000.

vbxe_init
			jsr fx_detect
			beq vbxe_found
			jmp (10)				; no VBXE -> back to DOS
vbxe_found
			ldy #$40
			mva #0 (fx_ptr),y		; disable XDL while configuring

// 1. clear VBXE bitmap (via blitter)
			ldy #$5d
			mva #$80+[bcb_cls_vbxe>>14] (fx_ptr),y
			mwa #cls_bcb pom2
			ldy #cls_bcb_len-1
@			lda (pom2),y
			sta $4000+[bcb_cls_vbxe&$3fff],y
			dey
			bpl @-

			ldy #$50
			mva #bcb_cls_vbxe&$ff (fx_ptr),y+
			mva #[bcb_cls_vbxe>>8]&$ff (fx_ptr),y+
			mva #bcb_cls_vbxe>>16 (fx_ptr),y+
			mva #1 (fx_ptr),y		; BLITTER_START
			ldy #$53
@			lda (fx_ptr),y
			bne @-

// 2. upload all shape data ($4000 bytes = 256 shapes * 64).
			ldy #$5d
			mva #$80+[shape_vbxe>>14] (fx_ptr),y
			mwa #shapes_raw pom
			mwa #$4000 pom1
			ldx #$40			; 64 pages = $4000 bytes
upl_loop
			ldy #0
@			lda (pom),y
			sta (pom1),y
			iny
			bne @-
			inc pom+1
			inc pom1+1
			lda pom1+1
			cmp #$80			; reached $4000+$4000?
			bcc upl_skip
			ldy #$5d
			lda (fx_ptr),y
			clc
			adc #1				; next 16K bank in VBXE
			sta (fx_ptr),y
			mwa #$4000 pom1
upl_skip
			dex
			bne upl_loop

// 3. write XDL into VBXE
			ldy #$5d
			mva #$80+[xdl_vbxe>>14] (fx_ptr),y
			ldy #xdl_len-1
@			lda xdl,y
			sta $4000+[xdl_vbxe&$3fff],y
			dey
			bpl @-

			ldy #$40
			mva #1 (fx_ptr),y		; enable XDL
			iny
			mva #xdl_vbxe&$ff (fx_ptr),y
			iny
			mva #[xdl_vbxe>>8]&$ff (fx_ptr),y
			iny
			mva #xdl_vbxe>>16 (fx_ptr),y

// 4. upload tile + sprite BCB templates
			ldy #$5d
			mva #$80+[bcb_tile_vbxe>>14] (fx_ptr),y
			ldx #bcb_tile_len-1
@			lda bcb_tile_tpl,x
			sta $4000+[bcb_tile_vbxe&$3fff],x
			dex
			bpl @-
			ldx #bcb_spr_len-1
@			lda bcb_spr_tpl,x
			sta $4000+[bcb_spr_vbxe&$3fff],x
			dex
			bpl @-

// 5. palette upload (16 colours of PICO-8 starting at palette index 0)
			jsr set_palette

			ldy #$5d
			mva #0 (fx_ptr),y		; release VBXE memory window
			rts

set_palette
			ldy #$44
			mva #0 (fx_ptr),y+		; CSEL = 0
			mva #1 (fx_ptr),y		; PSEL = 1
			ldx #0
@			ldy #$46
			lda pico_palette,x
			sta (fx_ptr),y+			; R
			inx
			lda pico_palette,x
			sta (fx_ptr),y+			; G
			inx
			lda pico_palette,x
			sta (fx_ptr),y			; B; auto-increments CSEL
			inx
			cpx #16*3
			bcc @-
			rts

fx_detect
			mwa #$d600 fx_ptr
			jsr fx_detect_1
			beq fx_detect_exit
			inc fx_ptr+1
fx_detect_1
			ldy #$40			; CORE_VERSION
			lda (fx_ptr),y
			cmp #$10
			bne fx_detect_exit
			iny
			lda (fx_ptr),y
			and #$70
			cmp #$20
fx_detect_exit
			rts

//----- BCB templates (copy of static fields, dynamic fields patched per blit)
bcb_tile_tpl
			dta a(0),0			; src addr (3 bytes, patched)
			dta a(TILE_PX),1	; src pitch = 8
			dta a(scr_vbxe&$ffff),scr_vbxe>>16  ; dst addr (low 2 patched)
			dta a(SCR_W),1		; dst pitch = 256
			dta a(TILE_PX-1),TILE_PX-1	; size = 8x8
			dta $ff,0,0			; AND/XOR/COLDET masks
			dta 0,0,0			; zoom/fill/mode = copy
bcb_tile_len equ *-bcb_tile_tpl

bcb_spr_tpl
			dta a(0),0			; src addr (patched)
			dta a(TILE_PX),1
			dta a(scr_vbxe&$ffff),scr_vbxe>>16
			dta a(SCR_W),1
			dta a(TILE_PX-1),TILE_PX-1
			dta $ff,0,0
			dta 0,0,1			; mode=1 (skip-on-zero / transparent)
bcb_spr_len equ *-bcb_spr_tpl

cls_bcb
			dta 0,0,0			; src = colour 0 (constant)
			dta a(0),0			; src pitch = 0 (repeat)
			dta a(scr_vbxe&$ffff),scr_vbxe>>16
			dta a(SCR_W),1
			dta a(SCR_W-1),SCR_H-1
			dta 0,0,0
			dta 7,0,0			; pattern fill (X*8 broadcast)
cls_bcb_len equ *-cls_bcb

//----- XDL: 16 blank lines, then 192 lines hires bitmap from scr_vbxe -------
xdl
			dta a($24),b(15)			; XDLC_OVOFF | RPT: 16 blank lines
			dta a($8862),b(191+16)		; GMON|OVADR|END|ATT: 208 lines bitmap
			dta a(scr_vbxe&$ffff)
			dta b(scr_vbxe>>16),a(SCR_W)	; bank, line stride
			dta a($ff10)				; palette 1, width $10=256 bytes, prio
xdl_len	equ *-xdl
