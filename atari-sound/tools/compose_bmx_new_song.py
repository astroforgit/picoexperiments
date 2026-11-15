"""After the Rain: a new 6/8 composition using BMX's instrument palette only.

No source melody, bass phrase, chord sequence, drum placement or song structure
is reused. Only short instrument envelopes and three single noise hits are read.
"""
import math
import build_remixes as b

SOURCE='asma/asma/Composers/Whittaker_David/BMX_Simulator.sap'
ID='bmx-instruments-after-the-rain'
TITLE='BMX Simulator'
REMIX_TITLE='After the Rain'
LEAD=2
UNIT=5
BAR=60
# Sixteenth-note units; twelve per 6/8 bar.
THEME=[
 [(3,66),(1,69),(2,74),(3,73),(1,69),(2,66)],
 [(4,64),(2,66),(4,62),(2,None)],
 [(3,66),(1,69),(2,71),(3,74),(1,73),(2,71)],
 [(4,69),(2,66),(4,62),(2,None)],
 [(3,67),(1,71),(2,74),(3,78),(1,76),(2,74)],
 [(4,71),(2,69),(4,67),(2,None)],
 [(3,69),(1,73),(2,76),(3,74),(1,73),(2,71)],
 [(2,69),(2,66),(2,64),(4,62),(2,None)],
]
ANSWER=[
 [(6,78),(2,76),(2,74),(2,69)],
 [(3,73),(1,74),(2,76),(4,74),(2,None)],
 [(4,78),(2,76),(3,74),(1,73),(2,71)],
 [(6,69),(2,66),(2,69),(2,None)],
 [(3,79),(1,78),(2,76),(3,74),(1,71),(2,67)],
 [(4,71),(2,74),(4,79),(2,None)],
 [(3,81),(1,79),(2,78),(3,76),(1,74),(2,73)],
 [(4,76),(2,73),(4,69),(2,None)],
]
RIVER=[
 [(4,71),(2,74),(4,78),(2,None)],
 [(3,76),(1,74),(2,73),(4,71),(2,None)],
 [(4,67),(2,71),(4,74),(2,None)],
 [(6,78),(2,76),(2,74),(2,71)],
 [(3,67),(1,66),(2,64),(4,71),(2,None)],
 [(4,76),(2,74),(4,71),(2,None)],
 [(3,73),(1,74),(2,76),(3,74),(1,73),(2,69)],
 [(6,73),(2,71),(2,69),(2,None)],
]
BRIDGE=[
 [(2,64),(2,67),(2,71),(4,76),(2,None)],
 [(3,74),(1,71),(2,67),(4,64),(2,None)],
 [(2,69),(2,73),(2,76),(4,81),(2,None)],
 [(3,79),(1,78),(2,76),(4,73),(2,None)],
 [(2,66),(2,69),(2,74),(3,78),(1,76),(2,74)],
 [(4,76),(2,74),(4,71),(2,69)],
 [(3,67),(1,71),(2,74),(3,76),(1,74),(2,71)],
 [(3,73),(1,74),(2,76),(4,69),(2,None)],
]
UPPER_SOLO=[
 [(2,76),(2,79),(2,83),(3,86),(1,83),(2,79)],
 [(3,83),(1,81),(2,79),(4,76),(2,None)],
 [(2,81),(2,85),(2,83),(4,81),(2,76)],
 [(3,85),(1,83),(2,81),(3,79),(1,78),(2,76)],
 [(2,78),(2,81),(2,86),(3,85),(1,81),(2,78)],
 [(4,83),(2,81),(4,78),(2,74)],
 [(3,79),(1,83),(2,86),(3,83),(1,81),(2,79)],
 [(3,85),(1,83),(2,81),(4,76),(2,None)],
]
CHORDS={
 'D':(38,42,45), 'Bm':(35,38,42), 'G':(43,47,50),
 'A':(45,49,52), 'Em':(40,43,47), 'F#m':(42,45,49),
}
A_HARMONY=['D','D','Bm','Bm','G','G','A','A']
B_HARMONY=['Bm','Bm','G','G','Em','Em','A','A']
C_HARMONY=['Em','Em','A','A','D','Bm','G','A']
FORM=[('First light',16,'intro'),('After the Rain - theme',16,'theme'),
      ('Windows opening',16,'answer'),('River reflections',16,'river'),
      ('Still water',16,'quiet'),('Crossing the bridge',16,'bridge'),
      ('Sun through clouds',16,'solo'),('After the Rain - homecoming',16,'return'),
      ('Clear sky',16,'coda')]


def compose(lib):
    source=b.capture(lib,b.ROOT/SOURCE,420)
    lead_envelope=[f[5]&15 for f in source[385:415]]
    bass_envelope=[f[3]&15 for f in source[:6]]
    hits=[[list(f[6:8]) for f in source[start:start+7]] for start in (0,24,48)]
    frames=[];sections=[];notes=[];bass_notes=[];percussion=[];bars=[]
    for section_index,(name,count,kind) in enumerate(FORM):
        sections.append(dict(name=name,frame=len(frames)))
        for number in range(count):
            pos=number%8
            harmony=B_HARMONY if kind in ('river','quiet') else C_HARMONY if kind in ('bridge','solo') else A_HARMONY
            chord=harmony[pos]
            melody=(RIVER if kind in ('river','quiet') else BRIDGE if kind=='bridge'
                    else ANSWER if kind in ('answer','solo') else THEME)[pos]
            if kind=='solo' and number>=8: melody=UPPER_SOLO[pos]
            if kind=='intro':
                melody=[(6,None),(4,[66,64,71,69,67,71,73,69][pos]),(2,None)] if number<8 else [(6,CHORDS[chord][1]+24),(4,CHORDS[chord][2]+24),(2,None)]
            if kind=='coda' and number>=8:
                chord=['G','G','A','A','D','Bm','G','D'][pos]
                melody=[(6,[67,71,73,76,78,74,71,74][pos]),(4,[74,79,76,73,74,71,69,74][pos]),(2,None)]
                if pos==7: melody=[(12,74)]
            assert sum(n for n,_ in melody)==12
            start=len(frames);root,third,fifth=CHORDS[chord]
            bass_line=[(3,root),(3,fifth),(3,third),(3,fifth)]
            if kind in ('intro','quiet'):bass_line=[(6,root),(6,fifth)]
            elif kind=='bridge':bass_line=[(2,root),(2,third),(2,fifth),(3,root+12),(3,fifth)]
            elif kind=='solo':bass_line=[(3,root),(1,third),(2,fifth),(3,third),(3,root)]
            beats=[]
            if kind not in ('intro','quiet') or number>=8:
                beats=[(0,0,1),(6,2,2)]
                if kind in ('theme','return','solo'):beats += [(4,1,1),(10,1,1)]
                if number in (7,15) and kind in ('bridge','solo','return'):beats += [(11,1,1)]
            gain=.6 if kind in ('intro','quiet') else .8 if kind=='river' else 1
            if kind=='coda' and number>=12:gain*=1-(number-12)/5
            melody_cells=[];cursor=0
            for length,pitch in melody:
                if kind=='quiet' and pitch is not None:pitch-=12
                notes.append(dict(frame=start+cursor*UNIT,frames=length*UNIT,midi=pitch,section=section_index,chord=chord))
                melody_cells.extend((pitch,age,length*UNIT) for age in range(length*UNIT));cursor+=length
            bass_cells=[];cursor=0
            for length,pitch in bass_line:
                bass_notes.append(dict(frame=start+cursor*UNIT,frames=length*UNIT,midi=pitch))
                bass_cells.extend((pitch,age,length*UNIT) for age in range(length*UNIT));cursor+=length
            for when,hit,peak in beats:percussion.append(dict(frame=start+when*UNIT,hit=hit,peak=peak))
            bars.append(dict(frame=start,chord=chord,meter='6/8',section=section_index))
            for tick in range(BAR):
                pitch,age,length=bass_cells[tick]
                frequency=440*2**((pitch-69)/12)
                divisor=max(0,min(65535,round(b.convert.CLOCK/(30*frequency)-7)))
                level=max(2,round(bass_envelope[min(age,5)]*gain*.75))
                if age>=length-2:level=1
                regs=[divisor&255,0,divisor>>8,0xc0|level,0,0,0,0,0x50]
                pitch,age,length=melody_cells[tick]
                if pitch is not None:
                    vibrato=.08*math.sin(age*math.tau/12) if age>=8 and length>=20 else 0
                    frequency=440*2**((pitch+vibrato-69)/12)
                    regs[4]=max(0,min(255,round(b.convert.CLOCK/(56*frequency)-1)))
                    level=max(1,round(lead_envelope[min(age,29)]*gain*.85))
                    if age>=length-2:level=max(1,level-2)
                    regs[5]=0xa0|level
                for when,hit,peak in sorted(beats,reverse=True):
                    at=tick-when*UNIT
                    if 0<=at<7:
                        frequency,control=hits[hit][at]
                        volume=round((control&15)*peak/10*gain)
                        regs[6],regs[7]=frequency,(control&240)|volume
                        break
                if kind=='coda' and number==15:
                    fade=max(0,1-tick/(BAR-1))
                    for control in (3,5,7):regs[control]=(regs[control]&240)|round((regs[control]&15)*fade)
                frames.append(bytes(regs))
    score=dict(short_description='A new D-major song in 6/8, with a lyrical hook, minor river theme and warm return.',
               description='Entirely new 6/8 composition in D major, changing to B minor and an Em-A bridge. New melodies, chord progressions, bass parts, drum placement and form. BMX supplies only short attack/decay shapes and three single noise hits.',
               preservation='Only instrument palette retained: native distortion-C joined bass, pure lead envelope and isolated noise hits. No source music phrases reused.',
               composition='standalone original score using borrowed instrument palette',meter='6/8',
               tempo_dotted_quarter_bpm=60*b.convert.FPS/30,notes=notes,bass_notes=bass_notes,percussion=percussion,
               bars=bars,sections=sections,allowed_changed_registers=list(range(8)),
               instrument_sources=dict(lead_frame=385,lead_frames=30,bass_frame=0,bass_frames=6,noise_frames=[0,24,48]),
               lead_envelope=lead_envelope,bass_envelope=bass_envelope,noise_hits=hits)
    return frames,score,sections
