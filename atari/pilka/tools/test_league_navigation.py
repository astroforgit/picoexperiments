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
    return int(atari.vram[0x65000 + league[name] + index])


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

def escape():
    atari.set_input(key=28)
    atari.run_frames(20)
    atari.set_input()
    atari.run_frames(8)

press(fire=True)
check_page(1)
escape()
check_page(0)
press(fire=True)
press(fire=True)
check_page(8)
if args.preview:
    args.preview.mkdir(parents=True, exist_ok=True)
    atari.screenshot(args.preview / "league-hub.png")
# Every read-only league view returns to the hub, even with Escape held.
for choice, page in ((1, 2), (2, 3), (3, 4), (4, 4)):
    press(stick=13)
    assert state("HUB_CHOICE") == choice
    press(fire=True)
    check_page(page)
    escape()
    check_page(8)
escape()
check_page(0)
# Friendly opponent selection goes back one level, preserving the home club.
press(stick=13)
press(fire=True)
press(fire=True)
assert state("PICK_MODE") == 2
escape()
check_page(1)
assert state("PICK_MODE") == 1 and state("SELECTION") == state("HOME_TEAM")
escape()
check_page(0)
for _ in range(3):
    press(stick=13)
press(fire=True)
check_page(7)
escape()
check_page(0)
for _ in range(4):
    press(stick=13)
press(fire=True)
assert not ram[runtime["LEAGUE_SCREEN"]]
escape()
check_page(0)
print(f"PASS at ${args.page:02X}00: Escape parents, held key, league hub, friendly picker, options and Classic")
