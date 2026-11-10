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
check_page(0)
press(fire=True)
check_page(1)
press(fire=True)
check_page(8)
press(stick=13)
press(fire=True)
check_page(2)
assert state("SEASON_LIVE") and state("SEASON_ROUND") == 0
press(stick=7)
check_page(3)
if args.preview:
    args.preview.mkdir(parents=True, exist_ok=True)
    atari.screenshot(args.preview / "league-squad.png")
press(fire=True)
check_page(2)
press(stick=14)
check_page(4)
press(stick=7)
assert state("FIXTURE_ROUND") == 1
press(fire=True)
check_page(2)

# Accelerate the match clock at its normal update point. The engine still
# performs its own kick-offs, half-time change of ends and full-time exit.
original_step = atari.cpu.step
periods = []
accelerated = set()
kickoff_states = set()


def checked_step():
    pc = atari.cpu.pc
    if pc == 0x84bc and ram[0x974c] == 0x64 and not ram[0x0100]:
        period = len(periods)
        if period not in accelerated and period < 2:
            ram[0xe7f4] = 0
            ram[0xe7f5] = 59
            ram[0xe7f6] = (44, 89)[period]
            if period == 0:
                ram[0x010e] = 2
                ram[0x010f] = 1
            accelerated.add(period)
    elif pc in (0x8c8b, 0x8c94):
        periods.append(pc)
        assert ram[0x010e:0x0110] == bytes((2, 1))
    elif pc == 0x84bc:
        kickoff_states.add((ram[0x974c], ram[0x974d]))
    op = atari.mem[pc]
    assert op != 0 and atari.cpu.disassemble[op][0] != "???", (hex(pc), hex(op))
    return original_step()


atari.cpu.step = checked_step

# The model delivers VBI at the frame boundary. Skip repeated comparisons
# against an unchanged frame counter while the CPU is waiting for that VBI.
def run_until(target):
    cpu = atari.cpu
    while cpu.processorCycles < target:
        waiting = (
            cpu.pc == runtime["FW_IDLE"] and atari.mems == 0xfc
            or cpu.pc == league["MENU_VBI"] and atari.mems == 0xf1
        )
        if waiting and cpu.a == ram[runtime["FRAMES"]]:
            cpu.processorCycles = target
            break
        cpu.step()

atari.run_until = run_until
press(fire=True)
assert ram[runtime["LEAGUE_MATCH"]] == 1
assert (ram[0xe282], ram[0xe283]) == (1, 255), "Home club is not on joystick 1"

for frame in range(2600):
    atari.set_input(stick=(15, 7, 14, 11)[(frame // 60) % 4], trig=(frame % 12) < 4)
    atari.run_frames(1)
    if state("SEASON_ROUND") == 1:
        break
else:
    raise AssertionError((hex(atari.cpu.pc), periods, kickoff_states,
                          bytes(ram[0xe7f4:0xe7f9]).hex(), bytes(ram[0x974c:0x975b]).hex()))
atari.cpu.step = original_step
atari.set_input()
atari.run_frames(14)
assert periods == [0x8c8b, 0x8c94]
check_page(5)
first = state("NEXT_FIXTURE")
assert int(atari.vram[0x74000 + league["RESULT_HOME"] + first]) == 2
assert int(atari.vram[0x74000 + league["RESULT_AWAY"] + first]) == 1
assert state("POINTS") == 3
press(fire=True)
check_page(2)
if args.preview:
    atari.screenshot(args.preview / "league-table.png")
press(stick=11)
check_page(5)
press(fire=True)
assert state("POINTS") == 3, "Reopening results duplicated points"
press(stick=13)
check_page(0)
press(stick=13)
press(fire=True)
check_page(1)
press(fire=True)
check_page(1)
assert state("PICK_MODE") == 2
press(fire=True)
assert ram[runtime["LEAGUE_MATCH"]] == 2
assert state("HOME_TEAM") != state("AWAY_TEAM")
# Exercise the same full-time bridge for a friendly after selecting two
# clubs through the menu. League points and the round must stay intact.
ram[0x010e] = 1
ram[0x010f] = 0
atari.cpu.pc = runtime["LEAGUE_MATCH_END"]
atari.run_frames(16)
check_page(6)
assert state("SEASON_ROUND") == 1 and state("POINTS") == 3
press(fire=True)
press(stick=13)
press(stick=13)
press(fire=True)
check_page(8)
press(stick=14)  # Play next match
press(fire=True)
assert ram[runtime["LEAGUE_MATCH"]] == 1
assert state("AWAY_TEAM") == state("SEASON_TEAM")
assert (ram[0xe282], ram[0xe283]) == (255, 1), "Away club is not on joystick 1"

# Run the engine's scoring hook for an away goal and an own goal.
scorers = 0x7b600
atari.io_write((args.page << 8) | 0x5f, 0xfc)
atari.io_write((args.page << 8) | 0x5d, 0)
ram[0x10] = 1
ram[0x0121] = 1
ram[0x0122] = 14
atari.call(runtime["LEAGUE_GOAL"])
assert ram[0x010f] == 1 and atari.vram[scorers + 14] == 1
ram[0x0121] = 0
ram[0x0122] = 3
atari.call(runtime["LEAGUE_GOAL"])
assert ram[0x010f] == 2 and atari.vram[scorers + 3] == 0

# Exercise the actual 6502 season routines through the remaining 13 rounds.
atari.io_write((args.page << 8) | 0x5f, 0xf1)
atari.io_write((args.page << 8) | 0x5d, 0x9e)
atari.call(league["CREDIT_PLAYED_GOALS"])
assert state("PLAYER_GOALS_LO", state("AWAY_TEAM") * 16 + 3) == 1
for round_no in range(1, 14):
    assert state("SEASON_ROUND") == round_no
    atari.call(league["FIND_FIXTURE"])
    store_state("HOME_SCORE", round_no % 3)
    store_state("AWAY_SCORE", 1)
    atari.call(league["COMPLETE_ROUND"])
assert state("SEASON_ROUND") == 14
atari.call(league["SORT_TABLE"])

expected = [[0, 0, 0, 0, 0, 0] for _ in range(8)]
for fixture in range(56):
    home, away = (schedule("FIXTURE_HOME", fixture), schedule("FIXTURE_AWAY", fixture))
    home_goals, away_goals = (state("RESULT_HOME", fixture), state("RESULT_AWAY", fixture))
    for club, goals, conceded in ((home, home_goals, away_goals), (away, away_goals, home_goals)):
        record = expected[club]
        if goals > conceded:
            record[1] += 1
        elif goals == conceded:
            record[2] += 1
        else:
            record[3] += 1
        record[0] += 3 if goals > conceded else int(goals == conceded)
        record[4] += goals - conceded
        record[5] += goals

for club, record in enumerate(expected):
    gd = state("GD_LO", club) + (state("GD_HI", club) << 8)
    if gd >= 32768:
        gd -= 65536
    gf = state("GF_LO", club) + (state("GF_HI", club) << 8)
    assert [state(name, club) for name in ("POINTS", "WINS", "DRAWS", "LOSSES")] + [gd, gf] == record
order = sorted(range(8), key=lambda club: (expected[club][0], *expected[club][4:]), reverse=True)
assert [state("RANKING", index) for index in range(8)] == order
print(f"PASS at ${args.page:02X}00: league menus, both controllers, half-time, full-time, scorers, friendly and all 56 results")
