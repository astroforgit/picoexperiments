; per-row state shared by the banks
; ---- per char row
row_off   .ds 25
row_scr_lo .ds 25               ; screen line it shows (frame state)
row_scr_hi .ds 25
row_cs    .ds 25                ; charset high byte
row_md    .ds 25
row40_lo :25 dta <(#*40)
row40_hi :25 dta >(#*40)
bit8r   dta 1,2,4,8,16,32,64,128

