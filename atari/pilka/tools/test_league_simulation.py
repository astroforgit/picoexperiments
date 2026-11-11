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
atari.io_write((args.page << 8) | 0x5f, 0xf1)
atari.io_write((args.page << 8) | 0x5d, 0x9e)
from collections import Counter
counts=Counter()
teams=[]
for _ in range(128):
    atari.call(league["NEW_SEASON"])
    strengths=tuple(state("TEAM_STRENGTH", i) for i in range(8))
    assert all(1<=v<=10 for v in strengths)
    teams.append(strengths)
    counts.update(strengths)
assert len(set(teams))>16
assert sum(counts[v] for v in (4,5,6))>sum(counts.values())/2
assert counts[5]>counts[1] and counts[5]>counts[10]

def goals(attack, defence):
    store_state("TEAM_STRENGTH", attack)
    store_state("SIM_DEFENCE", defence)
    atari.cpu.y=0
    atari.call(league["SIMULATED_GOALS"])
    assert 0<=atari.cpu.a<=5
    return atari.cpu.a

for attack,defence in ((5,5),(10,1),(8,3)):
    outcomes=Counter()
    for seed in range(1,256):
        store_state("RANDOM_SEED", seed)
        a=goals(attack,defence)
        b=goals(defence,attack)
        outcomes[(a>b)-(a<b)]+=1
    assert all(outcomes[v]>0 for v in (-1,0,1)), outcomes
    if attack>defence: assert outcomes[1]>outcomes[-1]*2, outcomes
    print(f"Strength {attack} vs {defence}: wins/draws/losses {outcomes[1]}/{outcomes[0]}/{outcomes[-1]}")
# Same noise: raising attack cannot reduce goals; raising defence cannot add goals.
for seed in range(1,256):
    attack_scores=[]
    defence_scores=[]
    for rating in range(1,11):
        store_state("RANDOM_SEED",seed)
        attack_scores.append(goals(rating,5))
        store_state("RANDOM_SEED",seed)
        defence_scores.append(goals(5,rating))
    assert attack_scores==sorted(attack_scores)
    assert defence_scores==sorted(defence_scores,reverse=True)
print("PASS: season ratings centred near 5, varied seasons, bounded scores, strength advantage, draws and upsets")

atari.call(league["NEW_SEASON"])
ratings=tuple(state("TEAM_STRENGTH", i) for i in range(8))
for round_no in range(14):
    atari.call(league["FIND_FIXTURE"])
    store_state("HOME_SCORE", round_no % 3)
    store_state("AWAY_SCORE", 1)
    atari.call(league["COMPLETE_ROUND"])
assert state("SEASON_ROUND")==14
assert ratings==tuple(state("TEAM_STRENGTH", i) for i in range(8))
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
print("PASS: season strengths persist and all 56 results produce the expected table")
