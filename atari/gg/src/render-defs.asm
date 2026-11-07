; ==================================================================
; VBXE renderer
;
; Char layer (V_CL): the 40x25 character screen as 8-bit pixels. Row r is
; a ring: screen column c is drawn at ring column (c + row_off[r]) mod 40,
; so a coarse scroll only changes row_off and draws the new column. The
; main context keeps it up to date between frames (idle_step: compares
; screen RAM with a shadow and queues tile blits into the next list).
;
; Each frame (NMI) the blitter copies the char layer into the back
; framebuffer per raster region (with the region's fine scroll), fills
; borders and blank areas, and draws the sprite instances the IRQ chain
; produced. The framebuffer is shown when the blitter is done.
;
; Pixel values are palette indices chosen so that the colour registers
; only change the palette:
;   $10|c  sprite multicolour 0 ($D025)      $20|c  sprite colour c
;   $30|c  sprite multicolour 1 ($D026)
;   $40|c  char background ($D021)           $50|c  $D022
;   $60|c  $D023                             $70|c  colour RAM c (multicolour: c&7)
;   $80|c  colour c (hires characters)       $A0|c..$D0|c  ECM backgrounds
;   $E0|c  colour c (fills)
; Tiles and sprites are stored as $x F codes; the blitter's AND mask with
; $x0|c (c = cell or sprite colour) gives the index.
; ==================================================================

; ---- tile slots: (charset address, kind) -> 256 expanded tiles
KIND_MC = 0
KIND_HI = 1
KIND_ECM = 2
MD_HI   = 0
MD_MC   = 1
MD_ECM  = 2
MD_BLANK = 3
