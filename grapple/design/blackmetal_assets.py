"""Original black-metal companion shapes for the native Grapple sprite grid."""
from PIL import Image,ImageDraw

W,B,R='#ffffff','#000000','#ff0000'

def blackmetal_cell(asset,state=0):
    im=Image.new('RGBA',(10,10) if asset=='cannonball' else (16,16))
    d=ImageDraw.Draw(im)
    if asset=='cannonball':
        d.ellipse((2,2,7,7),fill=B,outline=W)
        for points in (((4,0),(3,2),(5,2)),((9,4),(7,3),(7,5)),
                       ((5,9),(4,7),(6,7)),((0,5),(2,4),(2,6))):
            d.polygon(points,fill=W)
        d.line((3,3,6,3),fill=W)
        d.point((3,4),fill=W);d.point((6,4),fill=W)
        d.line((4,6,5,6),fill=W)
    elif asset=='cannon':
        # Horned iron housing, with a diagonal muzzle matching cannon aim.
        d.polygon(((3,5),(8,4),(14,8),(13,14),(7,15),(4,12)),fill=B,outline=W)
        d.line(((4,7),(1,7),(0,4)),fill=W)
        d.line(((11,6),(13,4),(15,4)),fill=W)
        d.polygon(((0,1),(2,0),(9,7),(7,9)),fill=W)
        d.line((2,2,7,7),fill=B)
        d.line((7,10,10,9),fill=W)
        d.point((11,12),fill=W)
        d.line((8,14,11,14),fill=W)
    elif asset=='mover':
        d.rectangle((0,0,15,15),fill=B,outline=W)
        # Branching, thorn-like emblem, kept legible without thin grey pixels.
        d.line(((7,2),(8,7),(7,13)),fill=W)
        d.line(((3,4),(7,7),(12,3)),fill=W)
        d.line(((2,10),(7,8),(13,11)),fill=W)
        d.line((3,4,3,2),fill=W);d.line((12,3,14,3),fill=W)
        d.line((2,10,2,13),fill=W);d.line((13,11,13,14),fill=W)
        for p in ((1,1),(14,1),(1,14),(14,14)):d.point(p,fill=W)
    elif asset=='spikes':
        d.line((0,15,15,15),fill=W)
        for points in (((1,14),(3,7),(2,2)),((5,15),(7,9),(6,0)),
                       ((9,15),(11,8),(13,1)),((13,15),(14,9),(15,5))):
            d.line(points,fill=W,width=2)
        d.line((3,8,0,6),fill=W)
        d.line((7,10,9,5),fill=W)
        d.line((11,8,14,7),fill=W)
    elif asset=='thwomp':
        # Corpse-paint mask framed by antlers; three distinct actor states.
        d.polygon(((3,3),(12,3),(14,7),(13,12),(10,15),(5,15),(2,12),(1,7)),fill=W)
        d.line(((3,4),(1,2),(1,0)),fill=W)
        d.line(((12,4),(14,2),(14,0)),fill=W)
        d.line((1,2,0,3),fill=W);d.line((14,2,15,3),fill=W)
        d.polygon(((4,5),(6,6),(5,11),(3,9)),fill=B)
        d.polygon(((11,5),(9,6),(10,11),(12,9)),fill=B)
        if state==0:
            d.line((4,7,5,7),fill=W);d.line((10,7,11,7),fill=W)
        else:
            d.point((5,7),fill=R);d.point((10,7),fill=R)
        d.line((7,9,8,10),fill=B)
        d.line((5,13,10,13),fill=B)
        if state==2:
            d.rectangle((5,11,10,13),fill=B)
            for x in (6,8,10):d.point((x,11),fill=W)
    elif asset=='checkpoint':
        # Ritual candle: unlit before activation, a bright flame afterwards.
        d.line((7,9,7,14),fill=W,width=2)
        d.line((3,15,12,15),fill=W)
        d.line(((3,10),(4,13),(10,13),(12,10)),fill=W)
        d.point((7,7),fill=W)
        if state:
            d.polygon(((7,1),(5,5),(7,7),(9,5)),fill=W)
            d.point((2,4),fill=W);d.point((12,4),fill=W)
        else:d.line((6,9,8,9),fill=W)
    else:raise ValueError(asset)
    return im
