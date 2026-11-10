; Runtime variables shared by the resident bridge (runtime.asm) and the
; renderer bank (render.asm). Plain RAM the C64 game never touches.
        org $dc10
frames    .ds 1         ; vertical blanks seen (NMI)
lastwait  .ds 1         ; last frame the game loop consumed
debt      .ds 1         ; frames the game loop is behind
skipn     .ds 1         ; consecutive pictures skipped to catch up
pending   .ds 1         ; framebuffer+1 waiting to be shown, or 0
front     .ds 1         ; framebuffer on screen
back      .ds 1         ; framebuffer being drawn
menu_mode .ds 1
ox        .ds 1         ; ring position of screen cell 0: column 0-39
oy        .ds 1         ; ... and row 0-24
first     .ds 1         ; nonzero until the first complete picture
palflag   .ds 1         ; palbuf must be loaded when the picture is shown
ballframe .ds 1         ; sprite pointer 7 of the pictured C64 screen
vbpage    .ds 1
expmx     .ds 1         ; map position the layer was drawn for
expmy     .ds 1
palbuf    .ds 30        ; RGB of palette entries 1-8,$20,$40
flipdx    .ds 1         ; net coarse scroll since the last picture, in
flipdy    .ds 1         ; characters (signed)
        org $dd80
irqvec    .ds 2
nmivec    .ds 2
        org $dd90
joy1      .ds 1
joy2      .ds 1
