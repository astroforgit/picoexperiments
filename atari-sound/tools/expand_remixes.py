#!/usr/bin/env python3
"""Expand the three audition arrangements into developing, sectioned songs."""
import argparse
from collections import Counter
import json
import math
from pathlib import Path
import shutil
import build_remixes as b
import long_music

NAMES = ['Opening', 'Main theme', 'Second theme', 'Answer',
         'Quiet passage', 'Development', 'Main theme returns', 'Finale']
LENGTHS = {'draconus': 8960, 'commando': 6912, 'warhawk': 10840}

def arrange(track, original):
    count, step, lead = len(original), track['step'], track['lead']
    phrase_count = math.ceil(count/(step*16))
    sections = [dict(name=name, frame=round((phrase_count*i//8)*step*16)) for i,name in enumerate(NAMES)]
    frames, score = [], []
    source_roots = {}
    for phrase in range(phrase_count):
        if track['id'] == 'draconus':
            sample = original[round(phrase*step*16):round((phrase+1)*step*16)]
            roots = [round(b.pitch(f[6])) % 12 for f in sample if b.tonal(f, 3)]
            source_roots[phrase] = Counter(roots).most_common(1)[0][0] if roots else 0
        elif track['id'] == 'commando':
            source_roots[phrase] = [9,9,0,0,9,2,9,9,9][phrase % 9]
        else:
            source_roots[phrase] = 7
    previous_beat = -1
    for i, old in enumerate(original):
        section = max(j for j,s in enumerate(sections) if s['frame'] <= i)
        beat = int(i/step)
        phrase, position = divmod(beat, 16)
        # A recognizable A theme returns, while B/answer/development have their
        # own contours. Phrase variation continues across the entire song.
        theme = track['motifs'][(phrase + [0,0,2,1,3,2,0,3][section]) % 4]
        if section == 0: index = (position//2)*2  # broader opening melody
        elif section == 2: index = (position*3+4) % 16
        elif section == 3: index = 15-position  # answering contour
        elif section == 4: index = (position//4)*4
        elif section == 5: index = (position+phrase*3) % 16
        else: index = position
        interval = theme[index]
        if section == 7 and position >= 12: interval = [12,10,7,0][position-12]
        note = 60+source_roots[phrase]+interval
        while note > 86: note -= 12
        if section in (0,4): note -= 12
        elif section == 5 and phrase % 2: note = min(86,note+12)
        new = bytearray(old)
        if b.tonal(old, lead):
            detune = b.pitch(old[lead*2])-round(b.pitch(old[lead*2]))
            frequency = 440*2**((note+detune-69)/12)
            new[lead*2] = max(0,min(255,round(b.convert.CLOCK/(56*frequency)-1)))
            # A quieter lead reveals the original bass and rhythm during the
            # breakdown, without replacing their instruments or changing tempo.
            if section in (0,4):
                volume = old[lead*2+1] & 15
                new[lead*2+1] = (old[lead*2+1] & 240)+max(1,round(volume*0.6))
        frames.append(bytes(new))
        if beat != previous_beat:
            score.append(dict(frame=i,midi=note,section=section,phrase=phrase,step=position))
            previous_beat = beat
    return frames, score, sections

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--library', required=True)
    args = parser.parse_args()
    lib = b.api(args.library)
    player, labels = long_music.build_player()
    catalog_path = b.ROOT/'remixes/catalog.json'
    catalog = json.loads(catalog_path.read_text())
    for track in b.TRACKS:
        folder = b.ROOT/'remixes'/track['id']
        backup = b.ROOT/'remixes-short'/track['id']
        if not backup.exists(): shutil.copytree(folder, backup)
        original = b.capture(lib,b.ROOT/'asma/asma'/track['source'],LENGTHS[track['id']])
        remix,score,sections = arrange(track, original)
        size = long_music.export(folder,track['remix'],remix,sections,player,labels)
        duration = len(remix)/b.convert.FPS
        item = next(t for t in catalog['tracks'] if t['id'] == track['id'])
        item.update(duration_seconds=duration,frames=len(remix),sections=sections,
                    format='PMZ1',arrangement='Full arrangement',
                    changed_lead_frames=sum(a[track['lead']*2]!=c[track['lead']*2] for a,c in zip(original,remix)),
                    allowed_changed_registers=[track['lead']*2,track['lead']*2+1],
                    preservation='Original backing, drums, clock and lead distortion; new evolving melody with opening/breakdown dynamics.',
                    compressed_bytes=size)
        (folder/'manifest.json').write_text(json.dumps(item,indent=2)+'\n')
        (folder/'score.json').write_text(json.dumps(dict(track=track,notes=score,sections=sections),indent=2)+'\n')
        (folder/'original-registers.bin').write_bytes(b''.join(original))
        (folder/'remix-registers.bin').write_bytes(b''.join(remix))
        # The old PMS is kept only with the short audition backup, to avoid
        # presenting it as the full-length Atari music file.
        if (folder/'REMIX.PMS').exists(): (folder/'REMIX.PMS').unlink()
        print(f'{track["remix"]}: {duration:.1f}s, {len(sections)} sections, {size} compressed bytes',flush=True)
    catalog_path.write_text(json.dumps(catalog,indent=2)+'\n')

if __name__ == '__main__': main()
