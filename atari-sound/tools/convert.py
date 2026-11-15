#!/usr/bin/env python3
"""Inventory PICO-8 carts and arrange their static audio for one Atari POKEY."""
from __future__ import annotations
import argparse
from collections import Counter
import hashlib
import json
import math
import os
from pathlib import Path
import re
import struct
import subprocess
import unicodedata

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parent
CLOCK = 1773447
FPS = CLOCK / (114 * 312)
TICK = 183 / 22050
BASE = 0x4000
HEADER = 0x140
MAX_BANK = 0x7000  # ends before BASIC ROM / screen RAM is in player segment


def blank_sfx():
    return dict(filters=0, speed=1, loop_start=0, loop_end=0,
                notes=[[0, 0, 0, 0] for _ in range(32)])


def parse_cart(path):
    sfx = [blank_sfx() for _ in range(64)]
    music = [dict(flags=0, channels=[64]*4) for _ in range(64)]
    code = ''
    repairs = []
    if path.name.lower().endswith(('.p8.png', '.p8.rom')):
        if path.suffix.lower() == '.png':
            from PIL import Image
            with Image.open(path) as im:
                if im.size != (160, 205):
                    raise ValueError(f'not a 160x205 PICO cartridge: {im.size}')
                raw = bytes((a & 3) << 6 | (r & 3) << 4 | (g & 3) << 2 | (b & 3)
                            for r, g, b, a in im.convert('RGBA').getdata())
        else:
            raw = path.read_bytes()
        if len(raw) < 0x4300:
            raise ValueError('truncated cartridge audio memory')
        for i in range(64):
            b = raw[0x3200+i*68:0x3200+(i+1)*68]
            sfx[i] = dict(filters=b[64], speed=max(1, b[65]), loop_start=b[66], loop_end=b[67],
                          notes=[[lo & 63, (lo >> 6) | ((hi & 1) << 2) | ((hi >> 7) << 3),
                                  (hi >> 1) & 7, (hi >> 4) & 7]
                                 for lo, hi in zip(b[:64:2], b[1:64:2])])
            c = raw[0x3100+i*4:0x3104+i*4]
            music[i] = dict(flags=(c[0] >> 7) | ((c[1] >> 7) << 1) | ((c[2] >> 7) << 2),
                            channels=[v & 127 for v in c])
    else:
        text = path.read_bytes().decode('utf-8', 'replace')
        if not text.startswith('pico-8 cartridge'):
            raise ValueError('missing PICO-8 header')
        parts = re.split(r'^__(\w+)__\s*$', text, flags=re.M)
        sections = dict(zip(parts[1::2], parts[2::2]))
        code = sections.get('lua', '')
        rows = [s.strip() for s in sections.get('sfx', '').splitlines() if s.strip()]
        if len(rows) > 64:
            raise ValueError('more than 64 SFX')
        for i, row in enumerate(rows):
            if re.fullmatch('[0-9a-fA-F]+', row) and 164 <= len(row) <= 172 and len(row) != 168:
                if (len(row) > 168 and not row[168:].strip('0')) or (len(row) < 168 and row.endswith('0000')):
                    repairs.append(f'SFX {i}: normalized trailing zero padding from {len(row)} to 168 hex digits.')
                    row = row[:168].ljust(168, '0')
            if not re.fullmatch('[0-9a-fA-F]{168}', row):
                raise ValueError(f'invalid SFX row {i}')
            b = bytes.fromhex(row[:8])
            notes = [[int(row[j:j+2], 16), *[int(v, 16) for v in row[j+2:j+5]]]
                     for j in range(8, 168, 5)]
            if any(p > 63 or w > 15 or v > 7 or f > 7 for p, w, v, f in notes):
                raise ValueError(f'out-of-range note in SFX {i}')
            sfx[i] = dict(filters=b[0], speed=max(1, b[1]), loop_start=b[2], loop_end=b[3], notes=notes)
        rows = [s.strip() for s in sections.get('music', '').splitlines() if s.strip()]
        if len(rows) > 64:
            raise ValueError('more than 64 music patterns')
        for i, row in enumerate(rows):
            b = bytes.fromhex(row)
            if len(b) != 5 or b[0] > 7 or any(v > 127 for v in b[1:]):
                raise ValueError(f'invalid music row {i}')
            music[i] = dict(flags=b[0], channels=list(b[1:]))
    # Canonicalize disabled channels so PNG/text copies compare equal.
    for p in music:
        p['channels'] = [64 if c & 64 else c for c in p['channels']]
    cart = dict(sfx=sfx, music=music)
    if repairs:
        cart['source_repairs'] = repairs
    return cart, code


def audible(s):
    return any(n[2] for n in s['notes'])


def looping(s):
    return 0 <= s['loop_start'] < s['loop_end'] <= 32


def duration_ticks(pattern, sfx):
    slowest = 0
    for c in pattern['channels']:
        if c & 64:
            continue
        s = sfx[c]
        if not looping(s):
            length = s['loop_start'] if s['loop_end'] == 0 and 0 < s['loop_start'] <= 32 else 32
            return length * s['speed']
        slowest = max(slowest, 32*s['speed'])
    return slowest or 32


def voice(sid, seconds, sfx, depth=0):
    """Sample note/envelope state; custom instruments are nested note sequences."""
    s = sfx[sid]
    offset = seconds / (s['speed'] * TICK)
    if looping(s) and offset >= s['loop_end']:
        offset = s['loop_start'] + (offset-s['loop_start']) % (s['loop_end']-s['loop_start'])
    if offset >= 32:
        return 0., 0., 0
    row = int(offset)
    phase = offset-row
    pitch, wave, vol, fx = s['notes'][row]
    freq = 440 * 2 ** ((pitch+12-69)/12)
    volume = vol / 7
    if fx == 1:
        previous = s['notes'][row-1] if row else [24, 0, 0, 0]
        old = 440 * 2 ** ((previous[0]+12-69)/12)
        freq = old + (freq-old)*phase
        if previous[2]:
            volume = previous[2]/7 + (volume-previous[2]/7)*phase
    elif fx == 2:
        freq *= 2 ** (0.25*math.sin(seconds*2*math.pi*7.5)/12)
    elif fx == 3:
        freq *= max(0.01, 1-phase)
    elif fx == 4:
        volume *= phase
    elif fx == 5:
        volume *= 1-phase
    elif fx in (6, 7):
        steps = (2 if s['speed'] <= 8 else 4) * (2 if fx == 7 else 1)
        p = s['notes'][(row & ~3) + int(seconds/(steps*TICK)) % 4][0]
        freq = 440 * 2 ** ((p+12-69)/12)
    if wave >= 8:
        if depth >= 2:  # malformed/recursive custom instruments cannot recurse forever
            return freq, volume, 0
        f, v, w = voice(wave & 7, phase*s['speed']*TICK, sfx, depth+1)
        return f * freq / (440*2**((36-69)/12)), volume*v, w
    return freq, volume, wave


def pokey_frame(voices):
    """Choose shared 15/64 kHz clock by weighted pitch error; retain four voices."""
    candidates = []
    for audctl, divisor in ((0, 28), (1, 114)):
        regs, error = [], 0.
        for frequency, volume, wave in voices:
            if volume <= 0 or frequency <= 0:
                regs.extend((0, 0))
                continue
            f = frequency
            folds = 0
            while f < CLOCK/(2*divisor*256):
                f *= 2
                folds += 1
            divider = max(0, min(255, round(CLOCK/(2*divisor*f)-1)))
            actual = CLOCK/(2*divisor*(divider+1))
            error += volume * (abs(1200*math.log2(actual/f)) + folds*300)
            # Pure tones preserve melody; triangle/sine/organ have softer gain.
            gain = (0.65, 0.65, 0.85, 1., 0.85, 0.7, 0.8, 0.75)[wave]
            v = max(1, min(12, round(volume*12*gain)))
            regs.extend((divider, (0x80 if wave == 6 else 0xa0) | v))
        candidates.append((error, bytes(regs+[audctl])))
    return min(candidates, key=lambda v: v[0])[1]


def render(pattern, sfx):
    frames = max(1, round(duration_ticks(pattern, sfx)*TICK*FPS))
    for frame in range(frames):
        yield pokey_frame([voice(c, frame/FPS, sfx) if c < 64 else (0, 0, 0)
                           for c in pattern['channels']])


def encode(frames):
    """Duration + 9-bit register-change mask + changed bytes; zero terminates."""
    output = bytearray()
    previous = None
    run = 0
    state = None

    def flush():
        nonlocal previous
        mask = sum(1 << i for i in range(9) if previous is None or state[i] != previous[i])
        output.extend(struct.pack('<BH', run, mask))
        output.extend(state[i] for i in range(9) if mask & (1 << i))
        previous = state

    for regs in frames:
        if regs == state and run < 255:
            run += 1
        else:
            if run:
                flush()
            state, run = regs, 1
    if run:
        flush()
    return bytes(output) + b'\0'


def decode(stream):
    regs, pos = bytearray(9), 0
    while True:
        duration = stream[pos]
        pos += 1
        if not duration:
            return
        mask = int.from_bytes(stream[pos:pos+2], 'little')
        pos += 2
        if mask > 511:
            raise ValueError('invalid mask')
        for i in range(9):
            if mask & (1 << i):
                regs[i] = stream[pos]
                pos += 1
        for _ in range(duration):
            yield bytes(regs)


def screen_text(text):
    text = unicodedata.normalize('NFKD', text).encode('ascii', 'replace').decode().upper()
    return bytes((ord(c)-32 if 32 <= ord(c) < 96 else 31) for c in text[:40].ljust(40))


def segment(address, data):
    if not data or address + len(data) > 65536:
        raise ValueError('invalid XEX segment')
    return struct.pack('<HH', address, address+len(data)-1) + data


def build_player(mads):
    out = ROOT/'player'
    result = subprocess.run([mads, str(out/'player.asm'), '-s', f'-o:{out}/player.obx',
                             f'-t:{out}/player.lab'], capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)
    loader = subprocess.run([mads, str(out/'loader.asm'), '-s', f'-o:{ROOT}/PLAYER.XEX', f'-t:{out}/loader.lab'],
                            capture_output=True, text=True)
    if loader.returncode:
        raise RuntimeError(loader.stdout + loader.stderr)
    labels = {p[2].lower(): int(p[1], 16) for line in (out/'player.lab').read_text().splitlines()
              if len(p := line.split()) == 3}
    return (out/'player.obx').read_bytes(), labels


def successor(pid, music):
    p = music[pid]
    if p['flags'] & 4:
        return None
    if p['flags'] & 2:
        return next((i for i in range(pid, -1, -1) if music[i]['flags'] & 1), 0)
    if pid == 63 or all(c & 64 for c in music[pid+1]['channels']):
        return None
    return pid+1


def make_entries(cart, renderer=None):
    sfx, music = cart['sfx'], cart['music']
    audible_ids = [i for i, p in enumerate(music)
                   if any(c < 64 and audible(sfx[c]) for c in p['channels'])]
    # Include silent timing patterns along every audible entry's playback path.
    wanted = set(audible_ids)
    for pid in audible_ids:
        seen = set()
        while pid is not None and pid not in seen:
            seen.add(pid)
            wanted.add(pid)
            pid = successor(pid, music)
    kind = 'music'
    if not wanted:
        # SFX can be music played by Lua; preserve all as auditionable material.
        kind = 'sfx-audition'
        wanted = {i for i, s in enumerate(sfx) if audible(s)}
        music = [dict(flags=4, channels=[i, 64, 64, 64]) for i in range(64)]
    entries = []
    for pid in sorted(wanted):
        frames = list(render(music[pid], sfx) if renderer is None else renderer(pid, music[pid], sfx))
        # Split pathological huge effects at frame boundaries, never drop frames.
        offset = 0
        while offset < len(frames):
            end = len(frames)
            data = encode(frames[offset:end])
            while len(data) + HEADER > MAX_BANK:
                end = offset + (end-offset)//2
                data = encode(frames[offset:end])
            entries.append(dict(id=pid, part=offset, frames=end-offset, data=data,
                                next_id=pid if end < len(frames) else successor(pid, music),
                                next_part=end if end < len(frames) else 0))
            offset = end
    return kind, entries


def export_game(folder, title, cart, sources, code, player, labels, renderer=None):
    folder.mkdir(parents=True, exist_ok=True)
    old_files = set()
    if (folder/'manifest.json').exists():
        old_manifest = json.loads((folder/'manifest.json').read_text())
        for b in old_manifest['banks']:
            if re.fullmatch(r'MUSIC(?:\d+)?', b['file']):
                old_files.update(b['file']+ext for ext in ('.PMS', '.XEX', '.sap', '-extra.sap'))
    kind, entries = make_entries(cart, renderer)
    # Keep each connected song together whenever it fits in Atari RAM.
    components = []
    remaining = set(e['id'] for e in entries)
    while remaining:
        component = {min(remaining)}
        while True:
            expanded = component | {e['next_id'] for e in entries if e['id'] in component and e['next_id'] in remaining}
            expanded |= {e['id'] for e in entries if e['next_id'] in expanded}
            if expanded == component:
                break
            component = expanded
        remaining -= component
        components.append([e for e in entries if e['id'] in component])
    banks, bank, size = [], [], HEADER
    for component in components:
        if bank and (size+sum(len(e['data']) for e in component) > MAX_BANK or len(bank)+len(component) > 64):
            banks.append(bank)
            bank, size = [], HEADER
        for e in component:
            if bank and (size+len(e['data']) > MAX_BANK or len(bank) == 64):
                banks.append(bank)
                bank, size = [], HEADER
            bank.append(e)
            size += len(e['data'])
    if bank:
        banks.append(bank)
    exported = []
    for number, bank in enumerate(banks, 1):
        data = bytearray(HEADER)
        data[:8] = b'PMS1' + bytes([1, len(bank), 0, 0])
        data[8:48] = screen_text(title)
        crossings = []
        details = []
        for i, e in enumerate(bank):
            address = BASE+len(data)
            data[0x40+i] = e['id']
            target = next((j for j, b in enumerate(bank)
                           if b['id'] == e['next_id'] and b['part'] == e['next_part']), 255)
            if e['next_id'] is not None and target == 255:
                target_bank = next(n for n, other in enumerate(banks, 1)
                                   if any(b['id'] == e['next_id'] and b['part'] == e['next_part'] for b in other))
                crossings.append(dict(from_pattern=e['id'], from_frame=e['part'], to_pattern=e['next_id'],
                                      to_frame=e['next_part'], to_file=f'MUSIC{target_bank:02}.XEX'))
            data[0x80+i] = target
            data[0xc0+i], data[0x100+i] = address & 255, address >> 8
            data.extend(e['data'])
            details.append(dict({k: v for k, v in e.items() if k != 'data'}, next_local=target))
        stem = 'MUSIC' if len(banks) == 1 else f'MUSIC{number:02}'
        (folder/f'{stem}.PMS').write_bytes(data)
        binary = player + segment(BASE, data)
        (folder/f'{stem}.XEX').write_bytes(binary + segment(0x2e0, struct.pack('<H', labels['start'])))
        safe_title = ''.join(c if c.isascii() and (32 <= ord(c) <= 95 or c.isalpha() or c == '|')
                             and c != '"' else '?' for c in title)[:100]
        times = []
        for i in range(len(bank)):
            j, visited, total = i, set(), 0
            while j != 255 and j not in visited:
                visited.add(j)
                total += bank[j]['frames']
                j = data[0x80+j]
            duration = total/FPS
            times.append(f'TIME {int(duration)//60:02}:{duration%60:06.3f}' + (' LOOP' if j != 255 else '') + '\r\n')
        for offset in range(0, len(bank), 32):
            # ASAP supports 32 subsongs; extra SAP indexes share the entire bank.
            shim = bytes([0x18, 0x69, offset, 0x4c])+struct.pack('<H', labels['init'])
            header = (f'SAP\r\nAUTHOR "<?>"\r\nNAME "{safe_title}"\r\nDATE "<?>"\r\n'
                      f'SONGS {min(32, len(bank)-offset)}\r\nTYPE B\r\nINIT 2F00\r\n'
                      f'PLAYER {labels["tick"]:04X}\r\n') + ''.join(times[offset:offset+32])
            suffix = '' if offset == 0 else '-extra'
            (folder/f'{stem}{suffix}.sap').write_bytes(header.encode('ascii')+binary+segment(0x2f00, shim))
        exported.append(dict(file=stem, bytes=len(data), entries=details, bank_boundary_stops=crossings))
    warnings = list(cart.get('source_repairs', []))
    if kind == 'sfx-audition':
        warnings.append('No audible static music patterns. SFX exported for audition; Lua sequencing is not reconstructed.')
    used = {c for p in cart['music'] for c in p['channels'] if c < 64}
    if kind == 'sfx-audition':
        used = {i for i, s in enumerate(cart['sfx']) if audible(s)}
    if any(cart['sfx'][i]['filters'] & 0xfe for i in used):
        warnings.append('PICO filter flags (including detune/reverb/damping) are not emulated.')
    if any(n[1] >= 8 and n[2] for i in used for n in cart['sfx'][i]['notes']):
        warnings.append('Custom instruments approximated as nested note sequences; phase/timbre can differ.')
    if any(b['bank_boundary_stops'] for b in exported):
        warnings.append('Memory bank boundaries stop playback. Load the next numbered XEX; see bank_boundary_stops.')
    if re.search(r'\b(poke|poke2|poke4|memcpy|reload|sfx)\s*\(', code):
        warnings.append('Lua audio/SFX calls or memory writes detected; gameplay-driven changes are not executed.')
    manifest = dict(title=title, kind=kind, sources=sources, banks=exported, warnings=warnings,
                    literal_music_calls=sorted({int(v) for v in re.findall(r'\bmusic\s*\(\s*(\d+)', code)}))
    (folder/'source-music.json').write_text(json.dumps(cart, separators=(',', ':'))+'\n')
    (folder/'manifest.json').write_text(json.dumps(manifest, indent=2, ensure_ascii=False)+'\n')
    new_files = {b['file']+ext for b in exported for ext in ('.PMS', '.XEX', '.sap')}
    new_files.update(b['file']+'-extra.sap' for b in exported if len(b['entries']) > 32)
    for obsolete in old_files-new_files:
        if (folder/obsolete).exists():
            (folder/obsolete).unlink()
    return manifest


def slug(title):
    title = unicodedata.normalize('NFKD', title).encode('ascii', 'ignore').decode()
    return re.sub('[^a-zA-Z0-9]+', '-', title).strip('-').lower()[:85] or 'game'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=REPO)
    parser.add_argument('--output', type=Path, default=ROOT)
    parser.add_argument('--mads', default='mads')
    parser.add_argument('--limit', type=int, help='development: export first N audio groups only')
    args = parser.parse_args()
    player, labels = build_player(args.mads)
    source, output = args.source.resolve(), args.output.resolve()
    paths = []
    for directory, dirs, files in os.walk(source):
        dirs[:] = [d for d in dirs if d not in ('.git', 'node_modules', 'atari-sound')
                   and (Path(directory)/d).resolve() != output]
        paths.extend(Path(directory)/f for f in files if f.lower().endswith(('.p8', '.p8.png', '.p8.rom')))
    paths.sort()
    groups, inventory = {}, []
    for p in paths:
        rel = str(p.relative_to(source))
        try:
            cart, code = parse_cart(p)
            title = re.sub(r'\.p8(?:\.png|\.rom)?$', '', p.name, flags=re.I)
            digest = hashlib.sha256(json.dumps(cart, sort_keys=True).encode()).hexdigest()
            # Same title + same audio merges text/PNG copies, never different games.
            key = (slug(title), digest)
            row = dict(source=rel, audio_sha256=digest)
            if not any(audible(s) for s in cart['sfx']):
                row['status'] = 'no-audio'
            else:
                row['status'] = 'audio'
                g = groups.setdefault(key, dict(title=title, cart=cart, sources=[], code=''))
                g['sources'].append(rel)
                if code:
                    g['code'] = code
            inventory.append(row)
        except Exception as exc:
            inventory.append(dict(source=rel, status='error', error=str(exc)))
    names = Counter(k[0] for k in groups)
    results = []
    output.mkdir(parents=True, exist_ok=True)
    if output != ROOT:
        (output/'PLAYER.XEX').write_bytes((ROOT/'PLAYER.XEX').read_bytes())
    for index, ((name, digest), group) in enumerate(sorted(groups.items())):
        if args.limit is not None and index >= args.limit:
            break
        name += '-'+digest[:8] if names[name] > 1 else ''
        result = export_game(output/'mscsrc'/name, **group, player=player, labels=labels)
        results.append(dict(directory=f'mscsrc/{name}', title=result['title'], kind=result['kind'],
                            banks=len(result['banks']), warnings=result['warnings']))
        if (index+1) % 50 == 0:
            print(f'Converted {index+1}/{len(groups)} games', flush=True)
    stats = dict(cartridges=len(paths), no_audio=sum(r['status'] == 'no-audio' for r in inventory),
                 errors=sum(r['status'] == 'error' for r in inventory), audio_groups=len(groups),
                 exported=len(results), music_games=sum(r['kind'] == 'music' for r in results),
                 sfx_auditions=sum(r['kind'] == 'sfx-audition' for r in results),
                 banks=sum(r['banks'] for r in results))
    (output/'catalog.json').write_text(json.dumps(dict(summary=stats, games=results, cartridges=inventory),
                                                  indent=2, ensure_ascii=False)+'\n')
    rows = ['# Converted music catalog', '', 'Open a game folder and load its MUSIC.XEX (or MUSIC01.XEX).', '',
            '| Game | Export | Banks |', '| --- | --- | --- |']
    rows += [f'| [{r["title"].replace("|", " ")}]({r["directory"]}/) | {r["kind"]} | {r["banks"]} |' for r in results]
    (output/'CATALOG.md').write_text('\n'.join(rows)+'\n')
    print(json.dumps(stats, indent=2))
    if stats['errors']:
        raise SystemExit('Some cartridges failed: inspect catalog.json errors.')


if __name__ == '__main__':
    main()
