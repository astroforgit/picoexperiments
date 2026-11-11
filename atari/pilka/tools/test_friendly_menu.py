#!/usr/bin/env python3
"""Boot the XEX, navigate the league, and cross a real half-time/full-time path."""
import argparse
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools/reference"))
from atari_emu import Atari, load_labels

parser = argparse.ArgumentParser()
parser.add_argument("--page", type=lambda v: int(v, 16), default=0xd6)
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


def state(name, index=0):
    return int(atari.vram[0x74000 + league[name] + index])


def store_state(name, value):
    atari.vram[0x74000 + league[name]] = value


def schedule(name, index):
    return int(atari.vram[0x74000 + league[name] + index])


def press(stick=15, fire=False):
    atari.set_input(stick=stick, trig=fire)
    atari.run_frames(7)
    atari.set_input()
    atari.run_frames(7)


def check_page(page):
    assert ram[runtime["LEAGUE_SCREEN"]] and state("MENU_PAGE") == page, (
        hex(atari.cpu.pc), state("MENU_PAGE")
    )


atari.run_frames(24)
# Four main choices: moving up from New League lands on Credits.
press(stick=14)
assert state("SELECTION") == 3
press(stick=13)
press(fire=True)
press(fire=True)
check_page(8)
store_state("POINTS", 7)
atari.set_input(key=28)
atari.run_frames(20)
atari.set_input()
atari.run_frames(20)
check_page(0)
press(stick=13)
press(fire=True)
atari.run_frames(32)
assert not ram[runtime["LEAGUE_SCREEN"]]
assert ram[0x92b7] == 0 and ram[0x92c2] == 1
press(stick=14)
assert ram[0x92c2] == 10, "Up must wrap past hidden Mode"
press(stick=13)
assert ram[0x92c2] == 1, "Down must wrap to Pitch"
old_pitch=ram[0x92b8]
press(stick=7)
assert ram[0x92b8] != old_pitch and ram[0x92b7] == 0
atari.run_frames(24)
renderer=load_labels(ROOT / "gen/render.asm.lab")
assert ram[renderer["NFRONT"]] == 1, "Only the title bitmap belongs in the menu sprite list"
assert bytes(atari.vram[0x7c000+160:0x7c000+200]) == bytes([0xfd])*40
if args.preview:
    args.preview.mkdir(parents=True,exist_ok=True)
    atari.screenshot(args.preview / "friendly-settings.png")
atari.set_input(key=28)
atari.run_frames(30)
atari.set_input()
atari.run_frames(30)
check_page(0)
assert state("SELECTION") == 1 and state("POINTS") == 7
press(fire=True)
atari.run_frames(24)
press(fire=True)
atari.run_frames(40)
assert not ram[runtime["MENU_MODE"]] and not ram[runtime["LEAGUE_MATCH"]]
assert ram[0x92b7] == 0
atari.set_input(key=28)
atari.run_frames(40)
atari.set_input()
atari.run_frames(8)
press(fire=True)
atari.run_frames(30)
check_page(0)
assert state("POINTS") == 7
print(f"PASS ${args.page:02X}00: four main choices, Friendly-only settings, hidden mode skipped, no previews, return and match launch/cancel preserve league")
