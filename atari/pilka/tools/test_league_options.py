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
press(stick=14)
assert state("SELECTION")==3
press(stick=13)
press(fire=True)
press(fire=True)
check_page(8)
for _ in range(5): press(stick=13)
press(fire=True)
check_page(7)
assert state("PITCH_CHOICE")==0 and state("LENGTH_CHOICE")==0
press(fire=True)
check_page(8)
press(stick=13)
press(fire=True)
check_page(10)
assert state("DIFFICULTY")==4
for expected in (3,2,1,0,0):
    press(stick=11)
    assert state("DIFFICULTY")==expected
for expected in (1,2,3,4,5,6,7,8,9,9):
    press(stick=7)
    assert state("DIFFICULTY")==expected
if args.preview:
    args.preview.mkdir(parents=True,exist_ok=True)
    atari.screenshot(args.preview / "difficulty.png")
for _ in range(9): press(stick=11)
atari.set_input(key=28)
atari.run_frames(20)
atari.set_input()
atari.run_frames(20)
check_page(8)
press(stick=13)
press(stick=13)
press(fire=True)
atari.run_frames(30)
assert ram[0xe288]==9 and ram[0xe289]==state("TEAM_STRENGTH", state("AWAY_TEAM"))-1, (ram[0xe288],ram[0xe289])
assert ram[0x9751]==0
ram[0x010e]=0
ram[0x010f]=0
atari.cpu.pc=runtime["LEAGUE_MATCH_END"]
atari.run_frames(30)
check_page(5)
press(fire=True)
check_page(8)
for _ in range(6): press(stick=13)
press(fire=True)
check_page(10)
for _ in range(9): press(stick=7)
press(fire=True)
press(stick=13)
press(stick=13)
press(fire=True)
atari.run_frames(30)
assert state("AWAY_TEAM")==state("SEASON_TEAM")
assert ram[0xe288]==state("TEAM_STRENGTH", state("HOME_TEAM"))-1 and ram[0xe289]==0, (ram[0xe288],ram[0xe289])
print("PASS: four main choices, league options defaults, ten difficulty steps, clamps, parent return, home/away strength and assigned CPU strength")
