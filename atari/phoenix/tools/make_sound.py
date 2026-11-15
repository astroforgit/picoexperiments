#!/usr/bin/env python3
"""POKEY sound data from the Amiga port's sounds (assets/sounds).

Sound effects: each WAV is cut into 1/50 s frames; every frame becomes one
POKEY channel setting (AUDF, AUDC): the volume follows the frame's RMS level,
a tonal frame plays its strongest frequency as a pure tone, a noisy frame
(flat spectrum) plays POKEY noise at a rate taken from the spectral centroid.

Music: the two tunes of phoenix_conv.mod (patterns 0-1 Fur Elise, played
when the mothership is destroyed; patterns 2-4 Jeux Interdits, at the start
of a game) are played by a small ProTracker model (speed/tempo, volume
slides, pattern break) and sampled at 50 Hz into two POKEY channels.

Writes gen/sound.asm.
"""
import math
import wave
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parent.parent
SND = ROOT / "src" / "phoenix-main" / "assets" / "sounds"
GEN = ROOT / "gen"
FBASE = 63921.0          # POKEY 64 kHz clock (PAL; NTSC is within 0.1%)
FPS = 50

# id: (name, wav, channel, priority, loop) -- channels as the Amiga port:
# 0 "other", 1 "kills", 2 "noise", 3 "loop"
SOUNDS = [
    ("SHOT", "shot", 2, 1, 0),
    ("SHOT_BOUNCES_1", "shot_bounces_1", 1, 1, 0),
    ("SHOT_BOUNCES_2", "shot_bounces_2", 1, 1, 0),
    ("SHIELD", "shield", 0, 1, 0),
    ("EXPLOSION", "explosion", 0, 1, 0),
    ("BIRD_SHOT", "bird_shot", 1, 2, 0),
    ("ATTACK_LOOP", "attack_loop", 3, 1, 1),
    ("VULTURE_SHOT", "vulture_shot", 1, 2, 0),
    ("VULTURE_BACK_1", "vulture_back_1", 3, 1, 0),
    ("VULTURE_BACK_2", "vulture_back_2", 3, 1, 0),
    ("BOSS", "boss", 3, 1, 0),
    ("BOSS_SHIELD_SHOT_1", "boss_shield_shot_1", 2, 1, 0),
    ("BOSS_SHIELD_SHOT_2", "boss_shield_shot_2", 2, 1, 0),
    ("START_MUSIC", None, 0, 0, 0),
    ("BOSS_END_MUSIC", None, 0, 0, 0),
    ("EXTRA_LIFE", "extra_life", 1, 1, 0),
]


def audf(freq):
    """AUDF for a pure tone (distortion A), moved into POKEY's range."""
    while freq < FBASE / 512:
        freq *= 2
    while freq > FBASE / 4:
        freq /= 2
    return max(0, min(255, round(FBASE / (2 * freq) - 1)))


def read_wav(name):
    w = wave.open(str(SND / f"{name}.wav"))
    x = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(float)
    return x / 32768.0, w.getframerate()


def sfx(name, mode="auto"):
    x, rate = read_wav(name)
    hop = rate // FPS
    win = 2048
    frames = []
    peak = 0
    data = []
    for i in range(0, len(x), hop):
        seg = x[i:i + win]
        if len(seg) < 256:
            break
        rms = math.sqrt(float(np.mean(seg[:hop] ** 2))) if len(seg) >= hop else math.sqrt(float(np.mean(seg ** 2)))
        seg = np.pad(seg, (0, win - len(seg)))
        sp = np.abs(np.fft.rfft(seg * np.hanning(win)))
        fr = np.fft.rfftfreq(win, 1 / rate)
        band = (fr > 60) & (fr < 8000)
        s = sp[band] + 1e-9
        flat = math.exp(float(np.mean(np.log(s)))) / float(np.mean(s))
        k = int(np.argmax(s))
        f0 = float(fr[band][k])
        centroid = float(np.sum(fr[band] * s) / np.sum(s))
        data.append((rms, flat, f0, centroid))
        peak = max(peak, rms)
    for rms, flat, f0, centroid in data:
        vol = 0 if peak == 0 else min(15, round(15 * (rms / peak) ** 0.7))
        if vol == 0:
            frames.append((0, 0))
            continue
        if mode == "noise" or (mode == "auto" and flat > 0.35):
            # noise: higher centroid -> faster noise clock
            f = min(30000, max(400, centroid * 2))
            frames.append((max(0, min(255, round(FBASE / (2 * f) - 1))), 0x80 | vol))
        else:
            frames.append((audf(f0), 0xA0 | vol))
    while frames and frames[-1][1] & 15 == 0:
        frames.pop()
    return frames


# ---------------------------------------------------------------- music
def mod_tune(patterns, seconds):
    d = (SND / "phoenix_conv.mod").read_bytes()
    off = 1084 + 5 * 1024
    cyc = []
    for i in range(3):
        o = 20 + i * 30
        ln = int.from_bytes(d[o + 22:o + 24], "big") * 2
        rs = int.from_bytes(d[o + 26:o + 28], "big") * 2
        rl = int.from_bytes(d[o + 28:o + 30], "big") * 2
        s = np.frombuffer(d[off:off + ln], dtype=np.int8).astype(float)
        off += ln
        seg = s[rs:rs + rl] if rl > 2 else s
        seg = seg - seg.mean()
        ac = np.correlate(seg, seg, "full")[len(seg) - 1:]
        cyc.append(int(np.argmax(ac[8:len(seg) // 2]) + 8))   # samples per waveform cycle
    speed, bpm = 6, 125
    t = 0.0
    events = []     # (time, channel, freq or None, volume) and slides
    ch = [{"f": None, "vol": 0, "slide": 0} for _ in range(2)]
    timeline = []
    order = patterns
    for pat in order:
        base = 1084 + pat * 1024
        for row in range(64):
            brk = False
            for c in range(4):
                b = d[base + row * 16 + c * 4:base + row * 16 + c * 4 + 4]
                if b[2] & 0xF == 0xF:
                    v = b[3]
                    if v < 32:
                        speed = v
                    else:
                        bpm = v
            ticks = []
            for c in range(2):
                b = d[base + row * 16 + c * 4:base + row * 16 + c * 4 + 4]
                smp = (b[0] & 0xF0) | (b[2] >> 4)
                per = ((b[0] & 0xF) << 8) | b[1]
                eff, par = b[2] & 0xF, b[3]
                if per:
                    ch[c]["f"] = 7093789.2 / (2 * per) / cyc[(smp or 1) - 1]
                    ch[c]["vol"] = 64
                ch[c]["slide"] = -(par & 0xF) if eff == 0xA and par & 0xF else ((par >> 4) if eff == 0xA else 0)
                if eff == 0xD:
                    brk = True
            tick_len = 2.5 / bpm
            for k in range(speed):
                timeline.append((t, [(x["f"], x["vol"]) for x in ch]))
                if k:
                    for x in ch:
                        x["vol"] = max(0, min(64, x["vol"] + x["slide"]))
                t += tick_len
            # breaks in any of the 4 channels
            for c in range(4):
                b = d[base + row * 16 + c * 4:base + row * 16 + c * 4 + 4]
                if b[2] & 0xF == 0xD:
                    brk = True
            if brk:
                break
    # sample at FPS
    out = [[], []]
    n = int(seconds * FPS)
    j = 0
    for i in range(n):
        tt = i / FPS
        while j + 1 < len(timeline) and timeline[j + 1][0] <= tt:
            j += 1
        state = timeline[j][1] if j < len(timeline) else [(None, 0), (None, 0)]
        if tt > timeline[-1][0] + 0.2:
            state = [(None, 0), (None, 0)]
        for c in range(2):
            f, v = state[c]
            vol = round(v * 12 / 64)
            out[c].append((audf(f), 0xA0 | vol) if f and vol else (0, 0))
    for c in range(2):
        while out[c] and out[c][-1][1] & 15 == 0:
            out[c].pop()
    m = max(len(out[0]), len(out[1]))
    for c in range(2):
        out[c] += [(0, 0)] * (m - len(out[c]))
    return out


def table(name, frames):
    lines = [f"{name}"]
    flat = []
    for f, c in frames:
        flat += [f, c]
    flat += [0xFF, 0x00]                # end marker: AUDF $FF with AUDC $00
    for i in range(0, len(flat), 16):
        lines.append("        dta " + ",".join(f"${b:02X}" for b in flat[i:i + 16]))
    return lines


def main():
    lines = ["; generated by tools/make_sound.py -- do not edit"]
    for sid, (name, wav, chan, prio, loop) in enumerate(SOUNDS):
        lines.append(f"SND_{name} = {sid}")
    total = 0
    for name, wav, chan, prio, loop in SOUNDS:
        if wav:
            fr = sfx(wav, "noise" if name == "EXPLOSION" else "auto")
            for f, c in fr:
                assert not (f == 0xFF and c == 0)
            total += len(fr) * 2
            lines += table(f"sfx_{name.lower()}", fr)
    for tune, pats, secs in (("elise", [0, 1], 10.4), ("jeux", [2, 3, 4], 20.0)):
        a, b = mod_tune(pats, secs)
        total += (len(a) + len(b)) * 2
        lines += table(f"mus_{tune}_a", a)
        lines += table(f"mus_{tune}_b", b)
    # per sound: table address, channel, priority, loop
    lines.append("snd_lo")
    lines += [f"        dta <sfx_{n.lower()}" if w else "        dta 0" for n, w, *_ in SOUNDS]
    lines.append("snd_hi")
    lines += [f"        dta >sfx_{n.lower()}" if w else "        dta 0" for n, w, *_ in SOUNDS]
    lines.append("snd_ch")
    lines.append("        dta " + ",".join(str(c) for _, _, c, _, _ in SOUNDS))
    lines.append("snd_pri")
    lines.append("        dta " + ",".join(str(p) for _, _, _, p, _ in SOUNDS))
    lines.append("snd_loop")
    lines.append("        dta " + ",".join(str(lp) for *_, lp in SOUNDS))
    (GEN / "sound.asm").write_text("\n".join(lines) + "\n")
    print(f"sound data: {total} bytes")


if __name__ == "__main__":
    main()
