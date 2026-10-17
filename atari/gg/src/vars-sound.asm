; sound variables
sv        .ds 1         ; voice being converted
env_lo    .ds 3         ; envelope level (8.8)
env_hi    .ds 3
est       .ds 3         ; 0 attack, 1 decay, 2 sustain, 3 release
pgate     .ds 3         ; gate at the end of the last frame
gor       .ds 32        ; OR of the values written this frame (per SID register)
gand      .ds 32        ; AND of them
sn_g      .ds 1
sn_t      .ds 2
sn_vol    .ds 1
sn_c      .ds 1
sn_f      .ds 2
sn_s      .ds 1
sn_r      .ds 2
sn_p      .ds 3
