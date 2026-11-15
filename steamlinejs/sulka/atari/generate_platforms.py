#!/usr/bin/env python3
"""Native 16x7 sprites: hollow architectural outlines and fluorescent plastic."""
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parent.parent
# Warm sketch contours and glossy pink plastic, distinct from green/cyan hazards.
PALETTE=[(66,59,47),(134,123,97),(207,193,153),(103,94,73),(172,158,122),(255,237,190)]
NEON_PALETTE=[(53,15,77),(125,24,133),(235,49,188),(255,148,227),(255,223,250),(168,51,201)]
DESIGNS=[
    ['.22522222252222.', '20...0....0...02', '20..0......0..02', '20.0........0.02', '200..........002', '14....0.......41', '.03333033333330.'],
    ['.22225222222522.', '20..0......0..02', '20...0....0...02', '20....0..0....02', '20.....00.....02', '14........0...41', '.03303333333030.'],
]
NEON_DESIGNS=[
    ['.33333333333333.', '3444443333333333', '2333333222222222', '2222222222222222', '2555555555555552', '1555555555555551', '.00000000000000.'],
    ['.33333333333333.', '3333333334444433', '2222222233333322', '2222222222222222', '2555555555555552', '1555555555555551', '.00000000000000.'],
]

def main():
    lines=['; Native theme platform runs: preserve the original 16x7 footprint.']
    for n,rows in enumerate(DESIGNS + NEON_DESIGNS):
        neon = n >= 2
        colours = NEON_PALETTE if neon else PALETTE
        base = 54 if neon else 48
        label = f"neon_platform_{n-2}" if neon else f"sketch_platform_{n}"
        assert len(rows)==7 and all(len(row)==16 for row in rows)
        lines.append(label)
        image=Image.new('RGB',(16,7),(0,0,0))
        for y,row in enumerate(rows):
            x=0
            while x<16:
                end=x+1
                while end<16 and row[end]==row[x]:end+=1
                colour=7 if row[x]=='.' else base+int(row[x])
                lines.append(f'        dta {x},{y},{end-x},{colour}')
                for px in range(x,end):image.putpixel((px,y),(0,0,0) if colour==7 else colours[colour-base])
                x=end
        lines.append('        dta $FF')
        image.save(ROOT/f'assets/platform-{"neon" if neon else "outline"}-{n-2 if neon else n}.png')
    split=lines.index('neon_platform_0')
    (ROOT/'atari/generated/sojka-platforms.inc').write_text('\n'.join(lines[:split])+'\n')
    (ROOT/'atari/generated/sojka-neon-platforms.inc').write_text('\n'.join(lines[split:])+'\n')
    (ROOT/'atari/generated/sojka-platform-palette.inc').write_text('\n'.join('        dta '+','.join(map(str,(48+i,*rgb))) for i,rgb in enumerate(PALETTE + NEON_PALETTE))+'\n')
    print('Generated outline and fluorescent plastic platform sprites.')

if __name__=='__main__': main()
