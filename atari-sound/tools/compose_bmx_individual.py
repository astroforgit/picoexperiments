"""BMX Simulator / Golden Lap: an explicitly scored C-major racing anthem."""
import math
import build_remixes as b

SOURCE='asma/asma/Composers/Whittaker_David/BMX_Simulator.sap'
ID='bmx-simulator-golden-lap'
TITLE='BMX Simulator'
REMIX_TITLE='Golden Lap'
LEAD=2
UNIT=6
BAR=96
# Actual Whittaker bass/percussion bars: C, A, D and B (G/B harmony).
BACKING={'C':384, 'Am':1824, 'Dm':1248, 'G/B':1344, 'C/B':1632, 'C/Bb':1728, 'Ab':1920}
HARMONY=['C','C','Am','Am','Dm','Dm','G/B','G/B']
# Each row is a complete bar: (sixteenth-note duration, MIDI pitch), None = rest.
HOOK=[
 [(3,67),(1,64),(2,67),(2,72),(4,71),(2,67),(2,64)],
 [(2,67),(2,69),(4,67),(2,64),(2,62),(4,60)],
 [(3,69),(1,72),(2,71),(2,69),(4,76),(2,72),(2,69)],
 [(4,72),(2,71),(2,69),(4,67),(2,64),(2,None)],
 [(3,65),(1,69),(2,72),(2,74),(4,72),(2,69),(2,65)],
 [(2,69),(2,67),(4,65),(2,64),(2,62),(4,69)],
 [(3,74),(1,71),(2,67),(2,69),(4,71),(2,74),(2,79)],
 [(4,77),(2,74),(2,71),(4,67),(2,62),(2,None)],
]
ANSWER=[
 [(6,76),(2,74),(4,72),(2,67),(2,64)],
 [(4,67),(2,72),(2,71),(6,72),(2,None)],
 [(6,72),(2,71),(4,69),(2,67),(2,64)],
 [(4,76),(4,72),(6,69),(2,None)],
 [(6,77),(2,76),(4,74),(2,72),(2,69)],
 [(4,72),(4,69),(4,65),(4,62)],
 [(6,74),(2,72),(4,71),(2,69),(2,67)],
 [(4,71),(2,74),(2,77),(4,79),(4,None)],
]
MIDDLE=[
 [(6,69),(2,71),(6,72),(2,None)],
 [(4,76),(4,72),(6,69),(2,None)],
 [(6,67),(2,69),(4,72),(4,76)],
 [(8,74),(4,72),(4,None)],
 [(6,65),(2,67),(6,69),(2,None)],
 [(4,74),(4,72),(4,69),(4,65)],
 [(4,67),(4,71),(4,74),(4,72)],
 [(6,71),(2,69),(4,67),(4,None)],
]
BUILD=[
 [(2,60),(2,None),(2,64),(2,None),(2,67),(2,None),(4,72)],
 [(4,71),(2,67),(2,64),(4,62),(4,None)],
 [(2,64),(2,None),(2,69),(2,None),(2,72),(2,None),(4,76)],
 [(4,74),(2,72),(2,69),(4,67),(4,None)],
 [(2,62),(2,None),(2,65),(2,None),(2,69),(2,None),(4,74)],
 [(2,76),(2,74),(2,72),(2,69),(4,65),(4,None)],
 [(2,67),(2,69),(2,71),(2,74),(2,77),(2,79),(4,81)],
 [(2,79),(2,77),(2,74),(2,71),(4,67),(4,None)],
]
# 96 bars, 3:05: each section has its own phrasing and dynamic arc.
FORM=[('Starting gate',8,'intro'),('Golden Lap - main hook',16,'hook'),
      ('Open road - answer',16,'answer'),('Banked turns',8,'middle'),
      ('Dusk over the track',8,'quiet'),('Climb and chase',16,'build'),
      ('Golden Lap - final sprint',16,'return'),('Finish line',8,'finale')]


def compose(lib):
    source=b.capture(lib,b.ROOT/SOURCE,2112)
    frames=[];sections=[];events=[];spans=[]
    for section_index,(name,bars,kind) in enumerate(FORM):
        sections.append(dict(name=name,frame=len(frames)))
        for bar in range(bars):
            position=bar%8
            chord=HARMONY[position]
            melody=HOOK[position]
            if kind=='intro':
                melody=[(8,[60,64,69,72,62,65,67,71][position]),(4,None),(4,[67,72,76,69,69,74,74,79][position])]
            elif kind=='answer': melody=ANSWER[position] if bar<8 else HOOK[position]
            elif kind in ('middle','quiet'):
                melody=MIDDLE[position]; chord=['Am','Am','C','C','Dm','Dm','G/B','G/B'][position]
            elif kind=='build': melody=BUILD[position] if bar<8 else ANSWER[position]
            elif kind=='return' and bar>=8: melody=ANSWER[position] if position in (1,3,5) else HOOK[position]
            elif kind=='finale':
                chord='C' if position>=6 else HARMONY[position]
                if position==6: melody=[(2,67),(2,72),(2,76),(2,79),(4,76),(4,72)]
                elif position==7: melody=[(12,72),(4,None)]
            assert sum(length for length,note in melody)==16
            start=len(frames);source_start=BACKING[chord]
            spans.append(dict(frame=start,frames=BAR,source_frame=source_start,chord=chord))
            for units,pitch in melody:
                event_start=len(frames);length=units*UNIT
                events.append(dict(frame=event_start,frames=length,midi=pitch,section=section_index,chord=chord))
                for age in range(length):
                    within=len(frames)-start
                    old=source[source_start+within]; new=bytearray(old)
                    gain=.55 if kind in ('intro','quiet') else .8 if kind=='middle' else 1
                    if kind=='finale' and position==7: gain*=max(0,1-within/BAR)
                    # Only volume changes to genuine source bass and percussion.
                    for register in (3,7):
                        volume=old[register]&15
                        new[register]=(old[register]&240)|round(volume*gain)
                    if pitch is None:
                        new[5]=0
                    else:
                        midi=pitch-(12 if kind=='quiet' else 0)
                        # A small delayed vibrato on longer sung notes.
                        vibrato=.10*math.sin((age-6)*math.tau/12) if age>=6 and length>=18 else 0
                        frequency=440*2**((midi+vibrato-69)/12)
                        new[4]=max(0,min(255,round(b.convert.CLOCK/(56*frequency)-1)))
                        peak=5 if kind=='quiet' else 6 if kind in ('intro','middle') else 8
                        level=peak if age<3 else peak-1 if age<9 else max(2,peak-3)
                        if age>=length-2:level=max(1,level-2)
                        if kind=='finale' and position==7:level=round(level*gain)
                        new[5]=0xa0|level
                    frames.append(bytes(new))
    score=dict(description='A rising racing hook, lyrical answer, minor-key dusk passage and final sprint.',
               preservation='Whittaker bass and percussion bars are explicitly rearranged; new melody and section dynamics.',
               key='C major, with A minor and D minor contrast; G/B dominant return',
               tempo_bpm=60*b.convert.FPS/24,notes=events,source_spans=spans,sections=sections,
               form=FORM,allowed_changed_registers=list(range(8)),composition='Explicitly written note lengths, melodies, chord sequence and source-bar arrangement; no random motif generator.')
    return frames,score,sections
