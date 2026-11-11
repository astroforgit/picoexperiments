#!/usr/bin/env python3
"""Exercise the league's illustrated menus, classic return and plain match sprites."""
import argparse
from pathlib import Path
import sys

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools/reference"))
from atari_emu import Atari, load_labels
from league_art import ART_PAGES, ART_WIDTH, ART_HEIGHT

parser = argparse.ArgumentParser()
parser.add_argument("--page", type=lambda value: int(value, 16), default=0xd6)
parser.add_argument("--preview", type=Path)
args = parser.parse_args()

runtime = load_labels(ROOT / "gen/runtime.asm.lab")
league = load_labels(ROOT / "gen/league.asm.lab")
atari = Atari(ROOT / "pilka.xex", vbxe_page=args.page)
atari.boot()
ram = atari.mem.ram
for _ in range(2_000_000):
    if atari.cpu.pc == 0x975b:
        break
    atari.cpu.step()
else:
    raise AssertionError("Boot did not enter the C64 startup routine")
atari.next_frame = atari.cpu.processorCycles + atari.frame_cycles


def press(stick=15, fire=False, consol=7):
    atari.set_input(stick=stick, trig=fire, consol=consol)
    atari.run_frames(20)
    atari.set_input()
    atari.run_frames(20)


def state(name):
    return int(atari.vram[0x74000 + league[name]])


def check_art(index):
    assert ram[runtime["LEAGUE_ART_ID"]] == index
    front = ram[runtime["FRONT"]] << 16
    frame = atari.vram[front:front+64000].reshape(200, 320)
    assert {0xc0, 0xc1, 0xc4}.issubset(set(frame.flat)), "Menu font or theme did not render"
    title = frame[4:20, 24:296]
    assert {0xd0, 0xd2, 0xd4, 0xd6}.issubset(set(title.flat)), "Neon title missing"
    assert not np.any(title == 0xc2), "Old red title strip remains"
    start = ART_PAGES[index]
    expected = atari.vram[start:start+ART_WIDTH*ART_HEIGHT].reshape(ART_HEIGHT, ART_WIDTH)
    assert np.unique(expected).size > 8
    assert np.array_equal(frame[40:160, 176:304], expected.repeat(2, 0).repeat(2, 1))


def preview(name):
    if args.preview:
        args.preview.mkdir(parents=True, exist_ok=True)
        atari.screenshot(args.preview / f"{name}.png")


atari.run_frames(24)
for index in range(3):
    check_art(index)
    if index in (0, 1, 3):
        preview(f"menu-{index}")
    if index < 2:
        press(stick=13)
press(stick=14)
check_art(1)
front = ram[runtime["FRONT"]] << 16
expected_main = atari.vram[front:front+64000].copy()

press(fire=True)
assert not ram[runtime["LEAGUE_SCREEN"]] and not ram[runtime["LEAGUE_MATCH"]]
assert ram[runtime["MENU_MODE"]] == 1
atari.run_frames(32)
original_pitch = ram[0x92b8]
press(stick=7)
assert ram[0x92b8] != original_pitch and ram[0x92b7] == 0
classic_mode = ram[0x92b7]
front = ram[runtime["FRONT"]] << 16
preview("classic-transition")
assert not np.any((atari.vram[front:front+64000] & 0xf0) == 0xb0)
hint = "ESC BACK  LEFT RIGHT CHANGE"
glyphs = bytes(ord(c)+0x98 if c != " " else 0xfd for c in hint)
assert bytes(atari.vram[0x7c000+922:0x7c000+922+len(glyphs)]) == glyphs
frame = atari.vram[front:front+64000].reshape(200, 320)
assert {0xc0, 0xc1, 0xd0, 0xd4}.issubset(set(frame.flat)), "Classic menu theme missing"
preview("classic")
press(stick=11, fire=True)
check_art(1)
front = ram[runtime["FRONT"]] << 16
assert np.array_equal(atari.vram[front:front+64000], expected_main), "Classic return corrupted main menu"
assert ram[0x92b7] == classic_mode, "Return chord changed the Classic mode"
press(fire=True)
assert not ram[runtime["LEAGUE_SCREEN"]]
press(consol=5)  # SELECT remains available
check_art(1)
press(stick=14)
press(fire=True)
press(fire=True)
for _ in range(5): press(stick=13)
press(fire=True)
assert state("MENU_PAGE") == 7
check_art(5)
press(stick=7)  # Random -> Frozen
press(stick=13)
press(stick=7)  # 3 -> 5 minutes
assert state("PITCH_CHOICE") == 1 and state("LENGTH_CHOICE") == 1
preview("options")
press(fire=True)
for _ in range(3): press(stick=13)
press(fire=True)  # Play next match
assert ram[runtime["LEAGUE_MATCH"]] == 1
assert ram[0x9757] == 0 and ram[0x9751] == 1, "Engine did not receive pitch/duration"
# Check a populated match display list. Its visible sprite entries must all
# draw from the original sprite atlas, including when league mode is active.
for attempt in range(30):
    atari.set_input(trig=(attempt % 3) == 0)
    atari.run_frames(20)
    active_sprites = 0
    for address in range(0x701f8, 0x701f8+26*21, 21):
        block = atari.vram[address:address+21]
        if int(block[15]):
            source = int(block[0]) | int(block[1]) << 8 | int(block[2]) << 16
            assert 0x60000 <= source < 0x6c000, hex(source)
            active_sprites += 1
        if not int(block[20]) & 8:
            break
    if active_sprites >= 3:
        break
else:
    raise AssertionError("The named match did not draw players")
preview("match")

atari.cpu.pc = runtime["LEAGUE_MATCH_END"]
atari.run_frames(20)
assert ram[runtime["LEAGUE_SCREEN"]] and ram[0x92b7] == classic_mode, (
    ram[runtime["LEAGUE_SCREEN"]], ram[0x92b7], classic_mode
)

print(f"PASS at ${args.page:02X}00: menu pictures, both Friendly return controls, options applied, original player sprites")
