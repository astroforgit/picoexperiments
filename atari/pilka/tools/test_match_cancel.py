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
press(fire=True)
press(fire=True)
check_page(8)
press(fire=True)

def popup():
    for _ in range(80):
        atari.run_frames(2)
        if ram[runtime["MENU_MODE"]] == 0:
            break
    atari.set_input(key=28)
    atari.run_frames(40)
    assert ram[runtime["LEAGUE_SCREEN"]]
    atari.set_input()
    atari.run_frames(4)

popup()
clock = bytes(ram[0xe7f4:0xe7f9])
atari.run_frames(30)
assert bytes(ram[0xe7f4:0xe7f9]) == clock
if args.preview:
    args.preview.mkdir(parents=True, exist_ok=True)
    atari.screenshot(args.preview / "abort-match.png")
atari.set_input(key=28)
atari.run_frames(24)
assert not ram[runtime["LEAGUE_SCREEN"]]
atari.set_input()
atari.run_frames(24)
assert state("SEASON_ROUND") == 0
popup()
press(fire=True)
atari.run_frames(24)
check_page(0)
assert state("SEASON_ROUND") == 1
fixture=state("NEXT_FIXTURE")
assert state("RESULT_HOME", fixture) == 0 and state("RESULT_AWAY", fixture) == 3
assert state("POINTS") == 0 and state("LOSSES") == 1
# Next fixture puts our club away. The opponent still gets the three goals.
press(stick=13)
press(stick=13)
press(fire=True)
press(fire=True)
popup()
press(fire=True)
atari.run_frames(24)
check_page(0)
fixture=state("NEXT_FIXTURE")
assert state("RESULT_HOME", fixture) == 3 and state("RESULT_AWAY", fixture) == 0, (fixture, state("SEASON_ROUND"), state("HOME_TEAM"), state("AWAY_TEAM"), state("RESULT_HOME", fixture), state("RESULT_AWAY", fixture))
assert state("LOSSES") == 2
# Friendly abandonment must not change the season.
press(stick=13)
press(fire=True)
atari.run_frames(32)
press(fire=True)
popup()
press(fire=True)
atari.run_frames(24)
check_page(0)
assert state("SEASON_ROUND") == 2 and state("LOSSES") == 2
print(f"PASS ${args.page:02X}00: pause freezes clock, resume, home/away forfeits and friendly cancellation")
