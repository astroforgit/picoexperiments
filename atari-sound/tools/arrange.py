"""Quiet, fixed-clock POKEY arrangements based on the workspace Porter player.

This is intentionally a musical arrangement, not PICO waveform emulation.
"""
import math
from statistics import median

CLOCK = 1773447
FPS = CLOCK / (114 * 312)
TICK = 183 / 22050
STYLE = 'porter-soft-v2'


def tonal_notes(s):
    return [n for n in s['notes'] if n[2] and n[1] != 6]


def make_arrangement(cart, title):
    channels = []
    for ch in range(4):
        ids = sorted({p['channels'][ch] for p in cart['music'] if p['channels'][ch] < 64})
        if not ids:
            ids = list(range(64))
        pitches = [n[0] for sid in ids for n in tonal_notes(cart['sfx'][sid])]
        channels.append(dict(channel=ch, median_pitch=median(pitches) if pitches else 24,
                             role='harmony', peak_volume=2, transpose={}))
    active = [c for c in channels if any(p['channels'][c['channel']] < 64 for p in cart['music'])]
    if not active:
        active = channels[:1]
    bass = min(active, key=lambda c: c['median_pitch'])
    lead = max(active, key=lambda c: c['median_pitch'])
    bass.update(role='bass', peak_volume=3)
    lead.update(role='lead', peak_volume=4)
    for ch in channels:
        for sid, s in enumerate(cart['sfx']):
            pitches = [n[0] for n in tonal_notes(s)]
            shift = 0
            if pitches:
                # One octave shift for the entire phrase, never clock or octave
                # changes chosen frame-by-frame. Keep its lowest tone above B2.
                while min(pitches)+shift < 36:
                    shift += 12
                target = 43 if ch['role'] == 'bass' else 51
                while median(pitches)+shift < target-6:
                    shift += 12
                while min(pitches)+shift >= 48 and median(pitches)+shift > target+6:
                    shift -= 12
            ch['transpose'][str(sid)] = shift
    return dict(style=STYLE, clock='fixed 64 kHz, AUDCTL=0', channels=channels,
                porter_reference=title.lower() == 'porterpatch1-1')


def note_at(s, seconds):
    offset = seconds / (max(1, s['speed'])*TICK)
    start, end = s['loop_start'], s['loop_end']
    if 0 <= start < end <= 32 and offset >= end:
        offset = start + (offset-start) % (end-start)
    if offset >= 32:
        return None
    row = int(offset)
    return row, offset-row, (offset-row)*s['speed']*TICK


def soft_voice(sid, seconds, sfx, channel):
    s = sfx[sid]
    point = note_at(s, seconds)
    if point is None:
        return 0, 0
    row, phase, age = point
    pitch, wave, volume, effect = s['notes'][row]
    if not volume:
        return 0, 0
    if wave == 6:
        # Brief, quiet percussion. Never hold a noise waveform for a long note.
        tick = int(age*FPS + 1e-7)
        if tick >= 3:
            return 0, 0
        return 12+tick*8, 0x80 | (2 if tick == 0 and volume >= 4 else 1)
    peak = min(channel['peak_volume'], math.ceil(volume/2))
    role = channel['role']
    if role == 'bass':
        level = peak if phase < .35 else max(0, peak-1)
        if phase > .84:
            level = max(0, peak-2)
    elif role == 'lead':
        level = peak if phase < .55 else max(0, peak-1)
    else:
        level = peak if phase < .28 else max(0, peak-1)
        if phase > .85:
            level = 0
    if effect == 4:
        level = min(level, math.ceil(peak*min(1, phase*3)))
    elif effect in (3, 5):
        # A drop becomes a pluck, not a long dive into POKEY's bass/noise range.
        level = min(level, max(0, math.ceil(peak*(1-phase))))
    if effect in (6, 7):
        step_seconds = max(3/FPS, (4 if effect == 6 else 8)*TICK)
        chord = s['notes'][(row & ~3) + int(age/step_seconds) % 4][0]
        pitch += max(-12, min(12, chord-pitch))
    pitch += channel['transpose'][str(sid)]
    frequency = 440 * 2**((pitch+12-69)/12)
    divider = max(0, min(255, round(CLOCK/(56*frequency)-1)))
    # Porter's lead moves by one divider; delay it slightly so attacks stay clear.
    if role == 'lead' and age >= 2/FPS and (int(seconds*FPS) & 2):
        divider = min(255, divider+1)
    return divider, (0xa0 | level) if level else 0


def porter_reference_frames(pattern, sfx):
    """Register-exact music voices from Porter music-player.asm for speed 16.

    The source player advances notes in 6,6,6,7 PAL frames and places its two
    music voices on POKEY 3/4. Sound effects on voices 1/2 are absent here.
    """
    for row in range(32):
        frames = 7 if row % 4 == 3 else 6
        for tick in range(frames-1, -1, -1):
            registers = [0]*9
            for channel, shift in enumerate((36, 12)):
                sid = pattern['channels'][channel]
                pitch, _, vol, _ = sfx[sid]['notes'][row] if sid < 64 else (0, 0, 0, 0)
                frequency = 440 * 2**((pitch+12+shift-69)/12)
                divider = max(0, min(255, round(CLOCK/(56*frequency)-1)))
                if sid >= 64:
                    divider = 0     # Porter's music_rest table contains zero bytes
                volume = min(3+channel, math.ceil(vol/2))
                if volume and tick < 3:
                    volume -= 1
                # Preserve even the original player's zero-volume AUDC=$A0.
                control = (0xa0 | volume) if vol else 0
                at = 4+channel*2
                registers[at] = (divider + (((tick & 2) >> 1) if channel else 0)) & 255
                registers[at+1] = control
            yield bytes(registers)


def render(pattern, sfx, frames, arrangement, pattern_id=None):
    if (arrangement['porter_reference'] and pattern_id is not None and pattern_id < 16
            and all(sid >= 64 or sfx[sid]['speed'] == 16 for sid in pattern['channels'])):
        yield from porter_reference_frames(pattern, sfx)
        return
    for frame in range(frames):
        registers = []
        for ch, sid in enumerate(pattern['channels']):
            registers.extend(soft_voice(sid, frame/FPS, sfx, arrangement['channels'][ch])
                             if sid < 64 else (0, 0))
        yield bytes(registers+[0])
