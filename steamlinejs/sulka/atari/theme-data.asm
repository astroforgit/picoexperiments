; Compact theme data in otherwise unused low RAM.
        org $0800
        icl 'generated/sojka-galaxy.inc'

palette
        dta 0,   0,  0,  0
        dta 1,   0,  0,  0
        dta 2,   0,  0,  0
        dta 3,   5, 31, 57
        dta 4,   7,111,145
        dta 5, 226,243,228
        dta 6,  70,135,143
        dta 7,   0,  0,  0
        dta 8, 148,227, 68
        dta 9, 239,255,158
        dta 10,148,227, 68
        dta 11,245, 79,119
        dta 12,  38,177,218
        dta 13,150,236,255
        dta 14, 70,135,143
        dta 15,255,255,255
        dta 16,  3,  1, 10
        dta 17,  0, 57,166
        dta 18,213, 43, 30
        icl 'generated/sojka-ruins-palette.inc'
        icl 'generated/sojka-platform-palette.inc'
        icl 'generated/sojka-galaxy-palette.inc'
        dta $FF

        icl 'generated/sojka-neon-platforms.inc'
        ert * > $1000
