			icl 'data/palette.inc.asm'

			org $6000
levels_data	ins 'data/levels.dat'
level_meta	ins 'data/level_meta.dat'
tile_flags	ins 'data/tile_flags.dat'

			org $8000
shapes_raw	ins 'data/shapes.spr'
