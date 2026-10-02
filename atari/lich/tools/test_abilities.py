#!/usr/bin/env python3
"""Functional test of the monster abilities: builds a test game whose first
floor is a room with one monster per ability next to the hero, plays a few
turns and reports what happened.  Restores the default build afterwards.

    python3 tools/test_abilities.py ability [ability...]
"""
import json
import subprocess
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
import lichdata as LD
from emu import load_labels
import shot

HERE = LD.HERE
EQUIP = False
FREE_CODES = [18, 19, 20, 44, 45, 112, 113, 114, 115, 116, 117, 150, 176]


def build(game_path):
    subprocess.run([sys.executable, 'tools/make_data.py', str(game_path)], cwd=HERE, check=True,
                   capture_output=True)
    subprocess.run(['mads', 'lich.asm', '-o:lich.xex', '-t:lich.lab', '-l:lich.lst'], cwd=HERE,
                   check=True, capture_output=True)


def make_game(ability, extra=()):
    g = LD.default_game()
    ghoul = g['monsters'][2]
    m = dict(ghoul, name='test ' + ability[:10], code=FREE_CODES[0], abilities=[ability] + list(extra),
             depth=99, hp=20, sight=6)
    g['monsters'].append(m)
    rows = [[0] * 128 for _ in range(32)]
    for y in range(4, 15):
        for x in range(4, 24):
            rows[y][x] = 48 if y in (4, 14) or x in (4, 23) else 1
    rows[9][6] = g['params']['tile_start']          # hero at (6,9), against the west wall side
    rows[9][11] = m['code']                          # monster east of the hero, same row
    rows[12][20] = g['params']['tile_exit']
    g['floors'] = [{'name': 'test', 'tiles': [''.join(f'{v:02x}' for v in r) for r in rows]}]
    g['floor_plan'][0] = 0
    g['budget'] = [0] * 15
    g['mimic_offset'] = [-9] * 15
    return g


def run(ability):
    g = make_game(ability)
    p = HERE / 'data' / 'test_game.json'
    p.write_text(json.dumps(g))
    build(p)
    L = load_labels(HERE / 'lich.lab')
    a = shot.run('100,f,320,c,30' + (',f,10,f,10,f,30' if 'equip' in sys.argv[0:1] or EQUIP else ''))
    r = a.mem.ram
    pl = r[L['PL']]
    log = []

    def state(tag):
        mons = []
        for i in range(r[L['ENT_N']]):
            e = r[L['ENT_LIST'] + i]
            if r[L['E_ID'] + e] >= 26 or (r[L['E_ID'] + e] == 2):
                hp = r[L['E_HP'] + e]
                mons.append((r[L['E_ID'] + e], r[L['E_TX'] + e], r[L['E_TY'] + e], hp - 256 if hp > 127 else hp))
        fog_known = sum(1 for i in range(4096) if r[L['FOG'] + i] != 2)
        hp = r[L['E_HP'] + pl]
        log.append(f'{tag:8s} hero {r[L["E_TX"] + pl]},{r[L["E_TY"] + pl]} hp {hp - 256 if hp > 127 else hp} '
                   f'para {r[L["E_PARA"] + pl]} blind {r[L["PL_BLIND"]]} inv {r[L["INV_N"]]} wpn {r[L["PL_WPN"]]} '
                   f'known {fog_known} monsters {mons}')
    state('start')
    for t in range(10):
        shot.step(a, 'r' if t % 2 == 0 else 'l')   # step back and forth: a turn passes
        a.run_frames(25)
        state(f'turn {t + 1}')
        if t == 3:
            a.screenshot(HERE / 'shots' / f'ability_{ability}.png', scale=2)
    return log


if __name__ == '__main__':
    if sys.argv[1] == 'equip':
        EQUIP = True
        sys.argv.pop(1)
    try:
        for ab in sys.argv[1:]:
            print('==', ab)
            for line in run(ab):
                print(line)
    finally:
        (HERE / 'data' / 'test_game.json').unlink(missing_ok=True)
        build(HERE / 'data' / 'game.json')
