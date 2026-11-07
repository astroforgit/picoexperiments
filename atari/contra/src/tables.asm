; NES RGB palette and planar expansion tables, adapted from the local Double Dragon port.
nes_r
        dta $62,$00,$10,$39,$5a,$6a,$6a,$52,$31,$08,$00,$00,$00,$00,$00,$00
        dta $ac,$10,$41,$73,$a4,$b4,$b4,$9c,$6a,$39,$08,$00,$00,$00,$00,$00
        dta $ff,$62,$94,$c5,$f6,$ff,$ff,$ee,$bd,$8b,$5a,$41,$4a,$4a,$00,$00
        dta $ff,$c5,$d5,$ee,$ff,$ff,$ff,$f6,$e6,$cd,$bd,$b4,$b4,$00,$00,$00
nes_g
        dta $62,$29,$10,$00,$00,$00,$00,$18,$31,$4a,$52,$4a,$41,$00,$00,$00
        dta $ac,$5a,$41,$20,$18,$18,$31,$4a,$6a,$83,$94,$8b,$7b,$00,$00,$00
        dta $ff,$b4,$94,$73,$6a,$6a,$83,$9c,$bd,$de,$e6,$e6,$cd,$4a,$00,$00
        dta $ff,$de,$d5,$cd,$c5,$c5,$cd,$de,$e6,$ee,$f6,$f6,$ee,$00,$00,$00
nes_b
        dta $62,$8b,$a4,$a4,$7b,$41,$00,$00,$00,$00,$00,$08,$4a,$00,$00,$00
        dta $ac,$de,$ff,$ff,$cd,$7b,$20,$00,$00,$00,$00,$31,$8b,$00,$00,$00
        dta $ff,$ff,$ff,$ff,$ff,$cd,$73,$20,$00,$00,$31,$83,$de,$4a,$00,$00
        dta $ff,$ff,$ff,$ff,$ff,$ee,$c5,$a4,$94,$94,$ac,$cd,$f6,$00,$00,$00
        .align $100
xt0
        dta $00,$00,$00,$00,$00,$00,$00,$00,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd
        dta $00,$00,$00,$00,$00,$00,$00,$00,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd
        dta $00,$00,$00,$00,$00,$00,$00,$00,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd
        dta $00,$00,$00,$00,$00,$00,$00,$00,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd
        dta $00,$00,$00,$00,$00,$00,$00,$00,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd
        dta $00,$00,$00,$00,$00,$00,$00,$00,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd
        dta $00,$00,$00,$00,$00,$00,$00,$00,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd
        dta $00,$00,$00,$00,$00,$00,$00,$00,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd
        dta $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
        dta $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
        dta $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
        dta $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
        dta $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
        dta $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
        dta $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
        dta $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
xt1
        dta $00,$00,$00,$00,$fd,$fd,$fd,$fd,$00,$00,$00,$00,$fd,$fd,$fd,$fd
        dta $00,$00,$00,$00,$fd,$fd,$fd,$fd,$00,$00,$00,$00,$fd,$fd,$fd,$fd
        dta $00,$00,$00,$00,$fd,$fd,$fd,$fd,$00,$00,$00,$00,$fd,$fd,$fd,$fd
        dta $00,$00,$00,$00,$fd,$fd,$fd,$fd,$00,$00,$00,$00,$fd,$fd,$fd,$fd
        dta $fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff
        dta $fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff
        dta $fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff
        dta $fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff
        dta $00,$00,$00,$00,$fd,$fd,$fd,$fd,$00,$00,$00,$00,$fd,$fd,$fd,$fd
        dta $00,$00,$00,$00,$fd,$fd,$fd,$fd,$00,$00,$00,$00,$fd,$fd,$fd,$fd
        dta $00,$00,$00,$00,$fd,$fd,$fd,$fd,$00,$00,$00,$00,$fd,$fd,$fd,$fd
        dta $00,$00,$00,$00,$fd,$fd,$fd,$fd,$00,$00,$00,$00,$fd,$fd,$fd,$fd
        dta $fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff
        dta $fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff
        dta $fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff
        dta $fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff
xt2
        dta $00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd
        dta $00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd
        dta $fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff
        dta $fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff
        dta $00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd
        dta $00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd
        dta $fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff
        dta $fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff
        dta $00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd
        dta $00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd
        dta $fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff
        dta $fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff
        dta $00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd
        dta $00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd,$00,$00,$fd,$fd
        dta $fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff
        dta $fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff
xt3
        dta $00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd
        dta $fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff
        dta $00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd
        dta $fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff
        dta $00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd
        dta $fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff
        dta $00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd
        dta $fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff
        dta $00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd
        dta $fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff
        dta $00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd
        dta $fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff
        dta $00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd
        dta $fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff
        dta $00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd,$00,$fd
        dta $fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe,$ff
