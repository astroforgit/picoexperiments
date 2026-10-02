#!/usr/bin/env python3
"""Shared data model of the Lich King port.

`default_game()` builds the complete, editable description of the game
(the "game.json" format) from the PICO-8 cartridge.  Building the port from
this default gives exactly the original game; the web editor (editor/)
edits a copy of it, and tools/make_data.py turns any game.json into the
tables the assembler includes.

Pixel data is stored like the .p8 __gfx__ section: one hex digit per pixel,
rows of 128 characters.  Map tiles are rows of two-digit hex numbers.
"""
from pathlib import Path
import json
import re

HERE = Path(__file__).resolve().parent.parent
FORMAT = 'lich-game'
VERSION = 1

MAXFLOORS = 15          # floors the tables are built for
MAXENT_IDS = 40         # entity types (hero, monsters, props)
MAXITEMS = 31
SHEET2_ROWS = 64        # second sprite page: 128 x 64 pixels (sprites 256..383)
FLOOR_BYTES = 0x2000    # VRAM for hand-made floors (RLE)

# monster abilities, bit i of m_abil (8 per table byte); keep the order
ABILITIES = ['poison', 'paralyze', 'bolt', 'blink', 'flee', 'boss', 'treasure', 'stun',
             'curse', 'vampire', 'steal_item', 'steal_weapon', 'slow', 'still', 'pounce', 'summon',
             'hunter', 'blind', 'invisible']
ABILITY_DESC = {
    'poison': 'hits poison the hero', 'paralyze': 'hits may paralyze the hero',
    'bolt': 'confusion bolt at range', 'blink': 'teleports after attacking',
    'flee': 'runs away from the hero', 'boss': 'killing it wins the game',
    'treasure': 'drops blessed food when killed', 'stun': 'first hit stuns the hero instead of hurting',
    'curse': 'first hit makes the hero forget the map', 'vampire': 'heals itself when it hits',
    'steal_item': 'first hit steals a backpack item', 'steal_weapon': 'first hit steals the weapon',
    'slow': 'moves every other turn', 'still': 'never moves', 'pounce': 'leaps to the hero along a line',
    'summon': 'summons monsters, keeps away', 'hunter': 'always knows where the hero is',
    'blind': 'hits blind the hero', 'invisible': 'only seen when next to the hero',
}

# props keep their built-in behaviour (by entity id)
PROP_ROLES = {4: 'pot', 5: 'chest', 6: 'shelves', 7: 'door (horizontal)', 8: 'door (vertical)',
              9: 'altar', 10: 'gate', 11: 'lever', 12: 'gate', 13: 'spikes', 18: 'pot',
              20: 'anvil', 21: 'body', 25: 'well'}

PARAMS = [
    # key, default, kind, description
    ('last_floor', 8, 'int', 'Floor of Raq\'zul (the boss room replaces the exit)'),
    ('rooms_base', 2, 'int', 'Rooms per floor = base + per_floor * floor'),
    ('rooms_per_floor', 2, 'int', 'Extra rooms per floor'),
    ('room_w_min', 5, 'int', 'Room width: min'),
    ('room_w_rnd', 7, 'int', 'Room width: + random 0..n-1'),
    ('room_h_min', 5, 'int', 'Room height: min'),
    ('room_h_rnd', 5, 'int', 'Room height: + random 0..n-1'),
    ('entry_min', 5, 'int', 'Entry room size: min'),
    ('entry_rnd', 3, 'int', 'Entry room size: + random 0..n-1'),
    ('boss_w', 11, 'int', 'Boss room width'),
    ('boss_h', 8, 'int', 'Boss room height'),
    ('storage_chance', 0.1, 'chance', 'Chance an ordinary room is a storage room'),
    ('shelf_chance', 0.5, 'chance', 'Storage room: chance of shelves on each top-wall tile'),
    ('floor_plain_chance', 0.2, 'chance', 'Styled room: chance a tile is plain floor'),
    ('shrine_from', 3, 'int', 'Shrine (altar) room from floor'),
    ('smithy_from', 4, 'int', 'Smithy (anvil) room from floor'),
    ('pool_from', 4, 'int', 'Pool (well) room from floor'),
    ('deco_chance', 0.4, 'chance', 'Room gets up to w/2 pots'),
    ('body_chance', 0.1, 'chance', 'A pot is a body instead'),
    ('spikes_from', 3, 'int', 'Spike traps from floor'),
    ('spikes_chance', 0.2, 'chance', 'Room gets 1..w/2 spike traps'),
    ('door_chance', 0.7, 'chance', 'A door spot gets a door (else an opening)'),
    ('piece_step', 2, 'int', 'Furniture piece = step*(floor-1) + random 0..n-1'),
    ('piece_rnd', 14, 'int', 'Furniture piece random range'),
    ('pot_mob_chance', 0.1, 'chance', 'Empty pot/body: chance a monster jumps out'),
    ('pot_mob_a', 2, 'int', 'Monster from a pot (entity id)'),
    ('pot_mob_b', 22, 'int', 'Alternative monster from a pot (entity id)'),
    ('pot_mob_a_chance', 0.7, 'chance', 'Chance of the first pot monster'),
    ('bless_chance', 0.1, 'chance', 'Item is blessed'),
    ('bless_from', 4, 'int', 'Blessed items from floor'),
    ('curse_chance', 0.4, 'chance', 'Item is cursed'),
    ('curse_from', 2, 'int', 'Cursed items from floor'),
    ('enchant_from', 4, 'int', 'Enchanted weapons from floor'),
    ('enchant_cursed', 0.3, 'chance', 'Enchant chance of a cursed weapon'),
    ('enchant_other', 0.1, 'chance', 'Enchant chance of other weapons'),
    ('ident_upto', 2, 'int', 'Items are identified up to floor'),
    ('ident_chance', 0.2, 'chance', 'Deeper: chance an item is identified'),
    ('lvl_atk', 1, 'int', 'Level up: attack +'),
    ('lvl_hp', 3, 'int', 'Level up: max hp +'),
    ('poison_turns', 3, 'int', 'Poison ability: turns added'),
    ('paralyze_chance', 0.5, 'chance', 'Paralyze ability: chance per hit'),
    ('paralyze_turns', 2, 'int', 'Paralyze ability: turns'),
    ('confuse_turns', 2, 'int', 'Bolt ability: confusion turns'),
    ('stun_turns', 1, 'int', 'Stun ability: turns the hero cannot act'),
    ('vampire_chance', 0.3, 'chance', 'Vampire ability: chance to heal by its attack'),
    ('blind_turns', 5, 'int', 'Blind ability: turns'),
    ('blind_sight', 1, 'int', 'Blind ability: sight of the blinded hero'),
    ('summon_id', 2, 'int', 'Summon ability: entity id summoned'),
    ('summon_wait', 2, 'int', 'Summon ability: turns between summons'),
    ('boss_id', 24, 'int', 'Boss entity id (killing it wins)'),
    ('mimic_id', 16, 'int', 'Mimic entity id (extra monsters per floor)'),
    ('boss_near_atk', 5, 'int', 'Boss attack when adjacent'),
    ('boss_far_atk', 1, 'int', 'Boss attack from range'),
    ('boss_heal', 2, 'int', 'Boss heals itself when adjacent'),
    ('death_sprite', 232, 'int', 'Hero death animation: first sprite'),
    ('boss_dead_sprite', 252, 'int', 'Sprite of the defeated boss'),
    ('tile_start', 17, 'int', 'Tile: hero start (up stairs)'),
    ('tile_exit', 16, 'int', 'Tile: stairs down'),
    ('tile_anvil_deco', 23, 'int', 'Tile next to the anvil'),
    ('tile_altar_deco', 71, 'int', 'Tile next to the altar'),
]


def chance16(x):
    """chance(x) threshold as the port compares it (16 bit)."""
    return max(0, min(65535, round(x * 65536)))


# ---------------------------------------------------------------- cart
def cart_bytes():
    return (HERE / 'pico' / 'cart.bin').read_bytes()


def lua_source():
    return (HERE / 'pico' / 'lich.lua').read_bytes().decode('latin-1')


def explodeval(s):
    return [int(v) for v in s.split(',')]


def parse_font(lua):
    fdat = re.search(r'fdat=.*?\[\[(.*?)\]\]', lua, re.S).group(1)
    glyphs = []
    for i in range(0, len(fdat) // 11 + 1):
        chunk = fdat[i * 11:i * 11 + 11]
        if len(chunk) < 11:
            break
        key, hexv = chunk[:2], chunk[2:].replace('.', '')
        v = int(hexv, 16)
        k = 4
        v >>= 1
        if v & 1:
            k -= 1
        v >>= 1
        if v & 1:
            k -= 2
        px = []
        for _ in range(18):
            v >>= 1
            px.append(v & 1)
        glyphs.append((key, px, k))
    return glyphs


def sheet_rows(gfx):
    """8K packed sheet -> 128 rows of 128 hex digits."""
    rows = []
    for y in range(len(gfx) // 64):
        r = ''
        for x in range(64):
            b = gfx[y * 64 + x]
            r += f'{b & 15:x}{b >> 4:x}'
        rows.append(r)
    return rows


def rows_to_packed(rows):
    out = bytearray()
    for r in rows:
        for x in range(0, 128, 2):
            out.append(int(r[x], 16) | (int(r[x + 1], 16) << 4))
    return bytes(out)


def default_game():
    cart = cart_bytes()
    lua = lua_source()
    m = re.search(r'm_name, m_anim.*?= explode\("(.*?)"\),(.*)', lua)
    names = m.group(1).split(',')
    vals = re.findall(r'explodeval\("([^"]*)"\)', m.group(2))
    cols = ['anim', 'col', 'prop', 'hp', 'atk', 'range', 'sight', 'depth', 'itemchance']
    M = {c: explodeval(v) for c, v in zip(cols, vals)}
    abil = {14: ['bolt'], 15: ['blink'], 16: ['flee', 'treasure'], 22: ['poison'], 23: ['paralyze'],
            24: ['boss', 'bolt', 'blink']}
    monsters = []
    for i, n in enumerate(names):
        eid = i + 1
        mon = dict(name=n, anim=M['anim'][i], code=M['anim'][i], col=M['col'][i],
                   prop=bool(M['prop'][i]), hp=M['hp'][i], atk=M['atk'][i], range=M['range'][i],
                   sight=M['sight'][i], depth=M['depth'][i], itemchance=M['itemchance'][i],
                   abilities=abil.get(eid, []))
        if eid in PROP_ROLES:
            mon['role'] = PROP_ROLES[eid]
        if eid == 1:
            mon['role'] = 'hero'
        monsters.append(mon)

    m = re.search(r'i_name, i_type.*?= explode\("(.*?)"\),(.*)', lua)
    inames = m.group(1).split(',')
    ivals = re.findall(r'explodeval\("([^"]*)"\)', m.group(2))
    icols = ['type', 'spr', 'atk', 'heal', 'hpmax', 'depth']
    I = {c: explodeval(v) for c, v in zip(icols, ivals)}
    items = []
    for i, n in enumerate(inames):
        it = {c: I[c][i] for c in icols}
        it['name'] = n
        it['found'] = 'chest' if it['type'] == 1 else ('shelves' if it['hpmax'] else 'pot')
        items.append(it)

    def sget(x, y):
        b = cart[y * 64 + x // 2]
        return b >> 4 if x & 1 else b & 15
    pieces = []
    for p in range(30):
        pieces.append([sget(p * 3 + x, 64 + y) for x in range(3) for y in range(3)])

    xp = [min(65535, sum((i + 1) ** 2 - 4 for i in range(1, lvl + 1))) for lvl in range(64)]
    floors = list(range(1, MAXFLOORS + 1))

    texts, windows = default_texts()
    return {
        'format': FORMAT,
        'version': VERSION,
        'name': 'Curse of the Lich King',
        'params': {k: v for k, v, _, _ in PARAMS},
        'monsters': monsters,
        'items': items,
        'start_items': [8, 1],
        'xp_req': xp,
        'budget': [xp[d + 1] - xp[d] for d in floors],
        'mimic_offset': [d - 3 for d in floors],
        'treasure_rooms': [d // 2 for d in floors],
        'floor_weights': [0, 0, 0, 1, 2, 2, 3, 3, 3],
        'move_weights': [1, 3, 1, 1],
        'pieces': pieces,
        'sheet': sheet_rows(cart[0:0x2000]),
        'sheet2': ['0' * 128] * SHEET2_ROWS,
        'flags': list(cart[0x3000:0x3100]),
        'texts': texts,
        'windows': windows,
        'floors': [],
        'floor_plan': [-1] * MAXFLOORS,
    }


def default_texts():
    S = dict(tr_1='', tr_2='cursed ', tr_3='holy ',
             st_1='', st_2=' of blight', st_3=' of confusion', st_4=' of the basilisk',
             st_5=' of the leech')
    S.update(
        s_embark='(*) ^embark',
        s_credit1='^created by @^johan^peitz',
        s_credit2='^audio by @^gruber_^music      v1.2',
        s_btn='[*]', s_close='^close (c)', s_backpack='^b^a^c^k^p^a^c^k',
        s_empty='###', s_equipmark='$ ', s_mysterious='mysterious ',
        s_use='use', s_discard='discard', s_equip='equip', s_unequip='unequip',
        s_space=' ', s_none='', s_quest='?', s_excl='!', s_dots='...',
        s_floor='^floor ', s_killedby='^killed by ', s_onfloor='on floor ', s_poison='poison',
        s_lvlup='^level up', s_atkup='^a^t^k +1', s_hpup='^max ^h^p &+3', s_refill='^h^p refilled!',
        s_heartplus='&+',
        s_a_equip='^equip weapon to alter...',
        s_a_untampered='^weapon must be untampered...',
        s_a_food='^cursed food required...',
        s_a_shattererd=' shattererd!',
        s_a_shattered=' shattered!',
        s_a_dip='^dip a cursed weapon in the pool...',
        s_a_nocurse=' is no longer cursed!',
        s_a_noident='^nothing to identify...',
        s_a_carry="^can't carry any more...",
        s_a_poison='^b^l^e^h! ^poisonous!',
        s_a_dizzy='^feeling dizzy...',
        s_a_glup="^g^l^u^p! ^can't move!",
        s_a_rotten="^ouf... ^it's rotten!",
        s_a_stuck=' is stuck!',
        s_stun='stun', s_curse='curse', s_steal='steal', s_blind='blind',
    )
    L = {}
    L['ml_intro'] = "^chills run down your spine as,you enter the ^lich ^king's lair.,,^you have travelled light but,hopefully you will find more,supplies hidden down here.,,^rumor has it ^raq'zul resides on,the 8th floor. ^descend his lair,and destroy him!".split(',')
    L['ml_anvil'] = "^a mighty anvil...,,^spend a turn on this,hefty piece to bestow,a wepaon with special,powers - if you have,the right items.".split(',')
    L['ml_well'] = "^a shallow pool...,,^the strangely clear water,has the power to free,a weapon from its curse.,^it only costs a turn".split(',')
    L['ml_altar'] = "^a holy altar...,,^the book on the table has,the answers you need.,^spend a turn here to,identify a mysterious item.".split(',')
    L['ml_win'] = "^as the ^lich king lets out a final;scream, something shifts in the;air. ^you feel lighter, as if an;invisible burden has lifted.;;^raq'zul is defeated and you;return to the surface knowing;that the world has become;a better place.".split(';')
    story = ("  ^to become immortal, the lich\n king ^raq'zul casts a powerful\n   spell. ^draining the world\n     of life and happiness.\n\n"
             "  ^brave souls descend into his\n     lair, but none return.\n\n  ^now it is your turn. ^defeat\n ^raq'zul, break the curse, and\n       end the suffering!")
    L['ml_story'] = story.split('\n')
    L['ml_submenu'] = ['use', 'discard']
    return S, L


def load_game(path=None):
    """data/game.json if present, else the cart default (written there)."""
    path = Path(path) if path else HERE / 'data' / 'game.json'
    if path.exists():
        g = json.loads(path.read_text())
        if g.get('format') != FORMAT:
            raise SystemExit(f'{path}: not a {FORMAT} file')
        d = default_game()
        for k, v in d.items():          # fill keys added in later versions
            g.setdefault(k, v)
        for k, v in d['params'].items():
            g['params'].setdefault(k, v)
        return g
    g = default_game()
    path.parent.mkdir(exist_ok=True)
    path.write_text(json.dumps(g, indent=1))
    return g
