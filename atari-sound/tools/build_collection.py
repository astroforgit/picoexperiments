#!/usr/bin/env python3
"""Curate 100 ASMA original/remix pairs with developing PAL arrangements."""
import argparse
from concurrent.futures import ProcessPoolExecutor
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import re
import shutil
import statistics
import tempfile
import build_remixes as b
import long_music
from expand_remixes import NAMES

PREFERRED = '''Zybex|International Karate|Jet Set Willy|Extirpator|Fred|Misja|Lasermania|Hans Kloss|Robbo|The Last V8|Black Lamp|Black Lamp Ingame|Ninja Commando|Blinky|Mountain Bike|Rebound|Plastron|Project Xanthien|Space Lobsters|Crumbles Crisis|Tagalon|Tube Baddies|Zero War|V8|Heart Break|Filthy Rich|Captain Gather|Dagobar|Enola|Trix|Blue Monday|Boulder Dash|Bruce Lee|Conan|Spy Hunter|Gyruss|Pitfall|Ghostbusters|Starquake|Action Biker|Chimera|One Man and His Droid|Milk Race|Loco|Trailblazer|Feud|Druid|Airball|The Goonies|Montezuma|Mountain King|MULE|Archon|Karateka|Alley Cat|Cavelord|Blue Max|Zorro|Gremlins|Spelunker|Frogger|Donkey Kong|Mario Bros|Moon Patrol|Popeye|Pengo|Q Bert|Bristles|Jumpman|Jet Boot Jack|Tapper|Kangaroo|Mr Do|Puzzlito|Bertyx|Mythos|Inny Swiat|Dziedzictwo Gigantow|Klony|Technus|Miecze Valdgira|Smus|The Last Guardian|Frank and Mark|Heartbreaker|Universal Hero|The Great American Cross Country Road Race|Electrician|Drol|Drelbs|Whistlers Brothers|Seven Cities of Gold|Realm of Impossibility|Ballblazer|Rescue on Fractalus|Star Raiders|Ali Baba|Return of Heracles|Phantasie|Questron|Desert Falcon|Dark Chambers|Into the Eagles Nest|Ninja|The Living Daylights|Panther|Amaurote|Red Max|BMX Simulator|Grand Prix Simulator|Storm|Trans Muter|Colony|Turrican|Monty on the Run|Last Ninja|Sanxion|Axel F|Great Giana Sisters|Commando|Arkanoid|R Type|Cybernoid|Green Beret|Target Renegade|Auf Wiedersehen Monty|Out Run|Saboteur|Ocean Loader|Crazy Comets|Delta|Lightforce|Dizzy|Bomb Jack|Yie Ar Kung Fu|Agent USA|Henry's House|Humpty Dumpty|Who Dares Wins|Hover Bovver|Protector|Zeppelin|Olympic Skier|Domain of the Undead|Zombies|Spy Games|Saracen|Quasimodo|Skateboard|Pogoman|Screaming Wings|Flak|Fidget|Bomb Fusion|Super Cobra|H.E.R.O.|River Raid|Floyd of the Jungle|Pooyan|Mr Bear|Keystone Kapers|Balloon|Preppie|Flip and Flop|Spare Change|Mouse Trap|Jawbreaker|Canyon Climber|O'Riley|Kissin Kousins|Clowns and Balloons|The Spy's Demise|Getaway|Shamus|Dimension X|Choplifter|Fort Apocalypse|Dan Strikes Back|Jumping Jack|Heathcliff|Hickory Dickory|Mickey|Master of the Lamps|Master of Time|Cosmic Pirate|Alf in the Color Caves|Dark Star|Creep|Inferno|Ghost Chaser|Nadral|Saper|Hydraulik|Duch|Atomia|Perly Szeherezady|Eureka|Czaszki|Global War|King of Killers|Fire Power|Technoid|Culmins|Jet Action|Wyspa|Zamek Londyn|Muminki|Sex Versi|Snake|Robal|Smasher|Silicon|Stroq|Mad Marbles|Immobilo|Gemy|Kaiser'''.split('|')

def normalized(text): return re.sub('[^a-z0-9]','',text.lower())

def metadata(path):
    raw=path.read_bytes()
    if not raw.startswith(b'SAP\r\n'): raise ValueError('Empty or non-SAP file')
    header=raw.split(b'\xff\xff')[0].decode('ascii')
    tags={m[1]:m[2].strip().strip('"') for m in re.finditer(r'^(\w+) (.+)$',header,re.M)}
    if tags.get('TYPE') not in ('B','C') or tags.get('FASTPLAY','312')!='312' or '\nNTSC' in header or '\nSTEREO' in header:
        raise ValueError('Requires another hardware/timing format')
    times=[]
    for minutes,seconds,loop in re.findall(r'^TIME (\d+):([\d.]+)( LOOP)?',header,re.M):
        times.append((int(minutes)*60+float(seconds),bool(loop)))
    song=int(tags.get('DEFSONG','0'))
    if times and times[song][0]<25:
        song=max(range(len(times)),key=lambda i:times[i][0]*(1.3 if times[i][1] else 1))
    duration=times[song][0] if times else 150
    if duration<25: raise ValueError('Short jingle')
    title=tags.get('NAME',path.stem)
    if title in ('<?>',''):
        title=path.stem.replace('_',' ')+' (untitled)'
    return dict(tags=tags,song=song,duration=duration,title=title)

def note(frame,ch):
    control,clock=frame[ch*2+1],frame[8]
    if not (control&15) or control&0xb0!=0xa0: return None
    if ch in (0,1) and clock&16 or ch in (2,3) and clock&8: return None
    if ch==2 and clock&4 or ch==3 and clock&2: return None
    divider=frame[ch*2]
    high=(ch==0 and clock&64) or (ch==2 and clock&32)
    frequency=b.convert.CLOCK/(2*(divider+4)) if high else b.convert.CLOCK/(2*(114 if clock&1 else 28)*(divider+1))
    midi=69+12*math.log2(frequency/440)
    return midi if 38<=midi<=96 else None

def choose_lead(frames):
    scores=[]
    for ch in range(4):
        notes=[note(f,ch) for f in frames]
        audible=[n for n in notes if n is not None]
        unique=len(set(round(n) for n in audible))
        changes=sum(a is not None and z is not None and abs(a-z)>0.8 for a,z in zip(notes,notes[1:]))
        if len(audible)<len(frames)*0.23 or unique<5: scores.append(-1);continue
        # Prefer sustained melodic voices over high-speed arpeggio or drum channels.
        scores.append(len(audible)*(0.5+statistics.median(audible)/100)*min(unique,18)/(1+changes/len(audible)*8))
    lead=max(range(4),key=lambda i:scores[i])
    if scores[lead]<0: raise ValueError('No sustained independent melodic voice')
    return lead

THEMES = [[0,2,4,1,3,5,4,2,0,4,3,1,2,1,0,-1],
          [4,2,0,1,3,2,5,4,6,5,3,2,4,1,2,0],
          [0,1,3,4,2,0,5,3,2,4,6,5,3,1,2,0],
          [2,4,5,3,1,2,0,-1,0,3,2,4,5,2,1,0],
          [0,4,2,5,3,1,4,2,6,4,5,3,2,0,1,0],
          [4,5,3,2,0,1,4,3,5,6,4,2,3,1,-1,0],
          [0,2,1,4,3,5,2,4,1,0,3,2,5,4,2,0],
          [2,0,4,3,5,2,6,4,3,1,2,0,1,3,2,0]]

def plan(frames,lead):
    notes=[note(f,lead) for f in frames]
    audible=[n for n in notes if n is not None]
    histogram=Counter(round(n)%12 for n in audible)
    options=[]
    for tonic in range(12):
        for mode,scale in [('minor',[0,2,3,5,7,8,10]),('major',[0,2,4,5,7,9,11])]:
            fit=sum(histogram[(tonic+i)%12] for i in scale)+0.08*histogram[tonic]
            options.append((fit,tonic,mode,scale))
    _,tonic,mode,scale=max(options)
    onsets=[i for i in range(1,len(notes)) if notes[i] is not None and (notes[i-1] is None or abs(notes[i]-notes[i-1])>0.8)]
    lengths=Counter(z-a for a,z in zip(onsets,onsets[1:]) if 5<=z-a<=16)
    step=lengths.most_common(1)[0][0] if lengths else 8
    return dict(tonic=tonic,mode=mode,scale=scale,step=step,center=statistics.median(audible))

def compose(frames,lead,settings,seed,style):
    step=settings['step']; phrase_length=step*16
    phrases=math.ceil(len(frames)/phrase_length)
    sections=[dict(name=name,frame=(phrases*i//8)*phrase_length) for i,name in enumerate(NAMES)]
    scale=[n for n in range(36,101) if (n-settings['tonic'])%12 in settings['scale']]
    roots=[]
    for start in range(0,len(frames),phrase_length):
        backing=[note(f,ch) for f in frames[start:start+phrase_length:3] for ch in range(4) if ch!=lead]
        backing=[round(n) for n in backing if n is not None and n<settings['center']]
        root=Counter(n%12 for n in backing).most_common(1)[0][0] if backing else settings['tonic']
        anchor=min(scale,key=lambda n:abs(n-(settings['center']-5))+ (0 if n%12==root else 6))
        roots.append(scale.index(anchor))
    output,score=[],[]
    previous=-1
    for i,old in enumerate(frames):
        section=max(j for j,s in enumerate(sections) if s['frame']<=i)
        beat=i//step; phrase,position=divmod(beat,16)
        theme=THEMES[(seed+[0,0,3,5,2,6,0,1][section]+(phrase//4 if section==5 else 0))%len(THEMES)]
        index=position
        if section in (0,4): index=position//2*2
        if section==3: index=15-position
        if section==5: index=(position+phrase*3)%16
        degree=theme[index]
        if phrase%2 and position in (7,11): degree+=1
        if section==7 and position>=12: degree=[4,2,1,0][position-12]
        target=scale[max(0,min(len(scale)-1,roots[phrase]+degree-(7 if section==4 else 0)))]
        old_note=note(old,lead)
        new=bytearray(old)
        if old_note is not None:
            detune=old_note-round(old_note)
            if style=='Soft flute': detune+=0.13*math.sin(i*math.tau/15)
            if style=='Octave echo' and section in (2,5) and i%step>=step*0.65: target=min(94,target+12)
            frequency=440*2**((target+detune-69)/12)
            clock=old[8]
            high=(lead==0 and clock&64) or (lead==2 and clock&32)
            divider=b.convert.CLOCK/(2*frequency)-4 if high else b.convert.CLOCK/(2*(114 if clock&1 else 28)*frequency)-1
            new[lead*2]=max(0,min(255,round(divider)))
            gain=0.58 if section==4 else (0.78 if section==0 else 1.0)
            if style=='Glass pluck': gain*=0.35+0.65*math.exp(-3*(i%step)/step)
            if style=='Soft flute': gain*=0.65+0.35*min(1,(i%step+1)/(step*0.35))
            volume=max(1,round((old[lead*2+1]&15)*gain))
            new[lead*2+1]=(old[lead*2+1]&240)+volume
        output.append(bytes(new))
        if beat!=previous:
            score.append(dict(frame=i,midi=target,section=section,phrase=phrase,step=position))
            previous=beat
    return output,score,sections

def load_xex(raw):
    memory=bytearray(65536);p=0
    while p<len(raw):
        start=int.from_bytes(raw[p:p+2],'little');p+=2
        if start==65535:continue
        end=int.from_bytes(raw[p:p+2],'little');p+=2
        memory[start:end+1]=raw[p:p+end-start+1];p+=end-start+1
    return memory

def validate_original(folder,meta,frames):
    from py65.devices.mpu6502 import MPU
    raw=load_xex((folder/'ORIGINAL.XEX').read_bytes())
    raw[0xd200:0xd209]=bytes([255]*8+[0x28])
    tags=meta['tags'];player=int(tags['PLAYER'],16)+(6 if tags['TYPE']=='C' else 0)
    class Bus:
        def __getitem__(self,address):
            if address==0xd40b:return (cpu.processorCycles//114%312)//2
            if address==0xd20f:return 255
            return raw[address]
        def __setitem__(self,address,value):raw[address]=value
    cpu=MPU(memory=Bus(),pc=int.from_bytes(raw[0x2e0:0x2e2],'little'));cpu.sp=255
    returning=None;frame=0
    for _ in range(1800000):
        if cpu.pc==player:
            returning=(raw[0x101+cpu.sp]|raw[0x102+cpu.sp]<<8)+1
        if cpu.pc==returning:
            if bytes(raw[0xd200:0xd209])!=frames[frame]:raise ValueError(f'Native original mismatch at frame {frame}')
            frame+=1;returning=None
            if frame==40:return
        cpu.step()
    raise ValueError('Native original did not complete 40 frames')

def candidates():
    items=[]
    for path in (b.ROOT/'asma/asma').rglob('*.sap'):
        try: meta=metadata(path)
        except (ValueError,IndexError,UnicodeError): continue
        title=normalized(meta['title'])
        ranks=[i for i,name in enumerate(PREFERRED) if normalized(name) in title or normalized(name) in normalized(path.stem)]
        if not ranks and meta['duration'] < 60: continue
        # Broaden beyond the first game-title shortlist, reproducibly mixing authors.
        rank=min(ranks) if ranks else len(PREFERRED)+int(hashlib.sha256(str(path).encode()).hexdigest()[:8],16)
        # Prefer the original game rip and period composers over later covers.
        preference=0 if path.parent.name=='Games' else 1
        if path.parent.name in ('Gilmore_Adam','Hubbard_Rob','Pelc_Janusz','Munns_Richard'):preference=-1
        items.append((rank,preference,len(meta['title']),str(path),meta))
    return sorted(items,key=lambda x:x[:4])

def build_candidate(task):
    path_string, meta, library, player, labels, ordinal = task
    path = Path(path_string); title = meta['title']; lib = b.api(library)
    try:
        probe=b.capture(lib,path,1200,meta['song'])
        lead=choose_lead(probe);settings=plan(probe,lead)
        phrase=settings['step']*16
        count=math.ceil(min(210,max(105,meta['duration']))*b.convert.FPS/phrase)*phrase
        original=b.capture(lib,path,count,meta['song'])
        seed=int(hashlib.sha256(str(path.relative_to(b.ROOT)).encode()).hexdigest()[:8],16)
        style=['Original voices','Original voices','Original voices','Glass pluck','Soft flute','Octave echo'][ordinal%6]
        remix,score,sections=compose(original,lead,settings,seed,style)
        changed=sum(a[lead*2]!=z[lead*2] for a,z in zip(original,remix))
        if changed<count*0.23:raise ValueError('Too little sustained new melody')
        slug=re.sub('[^a-z0-9]+','-',title.lower()).strip('-')
        if (b.ROOT/'remixes'/slug).exists():slug+='-'+str(seed%10000)
        suffix={'Original voices':'New Horizons','Glass pluck':'Glass Trails','Soft flute':'Soft Skies','Octave echo':'Echo Flight'}[style]
        remix_title=title+' / '+suffix
        with tempfile.TemporaryDirectory(dir=str(b.ROOT),prefix='.remix-build-') as directory:
            folder=Path(directory)
            author=b.native_original(path,folder,title,meta['song'])
            validate_original(folder,meta,original)
            size=long_music.export(folder,remix_title,remix,sections,player,labels)
            seconds=count/b.convert.FPS
            item=dict(id=slug,title=title,remix=remix_title,author=author,directory='remixes/'+slug,
                      source=str(path.relative_to(b.ROOT)),original_subsong=meta['song'],
                      source_duration_seconds=meta['duration'],duration_seconds=seconds,frames=count,
                      lead_channel=lead+1,changed_lead_frames=changed,allowed_changed_registers=[lead*2,lead*2+1],
                      format='PMZ1',sections=sections,arrangement=style,compressed_bytes=size,
                      preservation='Original bass, percussion, clock and lead distortion; new sectioned melody and lead envelopes.',
                      validation='Native wrapper: 40 frames match ASAP from dirty POKEY state; compression checks passed.')
            (folder/'manifest.json').write_text(json.dumps(item,indent=2)+'\n')
            (folder/'score.json').write_text(json.dumps(dict(settings=settings,seed=seed,style=style,sections=sections,notes=score),indent=2)+'\n')
            (folder/'original-registers.bin').write_bytes(b''.join(original))
            (folder/'remix-registers.bin').write_bytes(b''.join(remix))
            shutil.copytree(folder,b.ROOT/'remixes'/slug)
        return item, None
    except (ValueError, AssertionError) as exc:
        return None, dict(source=str(path.relative_to(b.ROOT)), title=title, reason=str(exc))

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--library',required=True)
    parser.add_argument('--count',type=int,default=300)
    parser.add_argument('--workers',type=int,default=4)
    parser.add_argument('--skip-log',type=Path)
    args=parser.parse_args()
    player,labels=long_music.build_player()
    catalog_path=b.ROOT/'remixes/catalog.json'
    catalog=json.loads(catalog_path.read_text())
    titles={normalized(t['title']) for t in catalog['tracks']}
    skipped=set()
    if args.skip_log:
        skipped={line[5:].split(': ',1)[0] for line in args.skip_log.read_text().splitlines() if line.startswith('SKIP ')}
    pending=iter(candidates()); rejected=[]; exhausted=False
    with ProcessPoolExecutor(max_workers=args.workers) as pool:
        while len(catalog['tracks']) < args.count and not exhausted:
            batch=[]; reserved=set()
            while len(batch)<min(args.workers,args.count-len(catalog['tracks'])):
                try: rank,preference,_,path,meta=next(pending)
                except StopIteration: exhausted=True; break
                key=normalized(meta['title'])
                if key in titles or key in reserved or meta['title'] in skipped: continue
                reserved.add(key)
                batch.append((path,meta,args.library,player,labels,len(catalog['tracks'])+len(batch)))
            for item,error in pool.map(build_candidate,batch):
                if error:
                    rejected.append(error); print('SKIP '+error['title']+': '+error['reason'],flush=True); continue
                catalog['tracks'].append(item); titles.add(normalized(item['title']))
                temporary=catalog_path.with_suffix('.json.tmp')
                temporary.write_text(json.dumps(catalog,indent=2)+'\n'); temporary.replace(catalog_path)
                print(f"{len(catalog['tracks'])}: {item['title']} -> {item['arrangement']}",flush=True)
    report=dict(requested=args.count,accepted=len(catalog['tracks']),rejected=rejected,
                selection='Game shortlist followed by a deterministic mix of compatible ASMA music; not a popularity chart.')
    (b.ROOT/'remixes/selection-report.json').write_text(json.dumps(report,indent=2)+'\n')
    if len(catalog['tracks'])<args.count: raise SystemExit('Not enough compatible tracks')

if __name__=='__main__':main()
