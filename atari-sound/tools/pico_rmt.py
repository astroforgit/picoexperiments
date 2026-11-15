"""Play the PICO score with actual isolated RMT instruments; no added drum track."""
import hashlib
import math
from statistics import median
import arrange
import convert


def profile(cart, title, bank, kind='music'):
    base = arrange.make_arrangement(cart, title)
    seed = int.from_bytes(hashlib.sha256(title.encode()).digest()[:8], 'little')
    ids = {sid for p in cart['music'] for sid in p['channels'] if sid < 64}
    if kind == 'sfx-audition': ids = {i for i, s in enumerate(cart['sfx']) if convert.audible(s)}
    speed = median([cart['sfx'][i]['speed'] for i in ids]) if ids else 16
    sources = sorted({v['source'] for v in bank['voices']})
    source = sources[seed % len(sources)]
    pool = [v for v in bank['voices'] if v['source'] == source]
    # Long notes favor sustained instruments; all voices come from one donor.
    pool.sort(key=lambda v: abs(v['sustain']-(.6 if speed >= 16 else .35)))
    for ch in base['channels']:
        ch['instrument'] = pool[(seed+ch['channel']) % min(3, len(pool))]['id']
        ch['peak_volume'] = {'lead': 7, 'bass': 5, 'harmony': 4}[ch['role']]
    donor = bank['sources'][source]['title']
    return dict(style='rmt-instruments-v2', style_name='RMT: '+donor, donor=donor,
                channels=base['channels'], seed=seed, kind=kind,
                source_policy='Original PICO score and rhythm, isolated RMT instrument playback',
                clock='fixed 64 kHz, AUDCTL=0', added_percussion=False)


def voice(sid, seconds, sfx, channel, instrument):
    s = sfx[sid]
    point = arrange.note_at(s, seconds)
    if point is None: return 0, 0
    row, phase, age = point
    pitch, wave, volume, effect = s['notes'][row]
    if not volume: return 0, 0
    if wave == 6:
        # Only the percussion already written in the PICO score, kept quiet.
        return arrange.soft_voice(sid, seconds, sfx, channel)
    if effect in (6, 7):
        step = max(3/convert.FPS, (4 if effect == 6 else 8)*convert.TICK)
        pitch = s['notes'][(row & ~3)+int(age/step) % 4][0]
    pitch += channel['transpose'][str(sid)]
    available = instrument['decoded']
    chosen = min(available, key=lambda n: abs(n-pitch))
    data = available[chosen]
    tick = int(age*convert.FPS+1e-7)
    # Retain the donor attack, then its late vibrato; do not loop the attack.
    if tick >= len(data)//2: tick = len(data)//2-16+(tick-len(data)//2) % 16
    divider, control = data[tick*2:tick*2+2]
    # Correct out-of-range source pitch without substituting a different note.
    divider = max(0, min(255, round((divider+1)*2**((chosen-pitch)/12)-1)))
    peak = max(1, math.ceil(volume*channel['peak_volume']/7))
    # A decaying donor must not reduce an authored held note to an inaudible click.
    envelope = max(.4, (control&15)/max(1, instrument['peak']))
    if phase > .9: envelope *= 1-(phase-.9)*5
    if effect == 4: envelope *= min(1, phase*4)
    elif effect in (3, 5): envelope *= max(.2, 1-phase)
    level = max(1, min(peak, round(peak*envelope)))
    return divider, 0xa0 | level


def render(pattern, sfx, frames, arrangement, bank):
    instruments = {}
    for ch in arrangement['channels']:
        inst = next(v for v in bank['voices'] if v['id'] == ch['instrument'])
        instruments[ch['channel']] = dict(inst, decoded={int(k): bytes.fromhex(v) for k, v in inst['samples'].items()})
    for frame in range(frames):
        registers = [0]*9
        for ch, sid in enumerate(pattern['channels']):
            if sid < 64:
                registers[ch*2:ch*2+2] = voice(sid, frame/convert.FPS, sfx, arrangement['channels'][ch], instruments[ch])
        yield bytes(registers)
