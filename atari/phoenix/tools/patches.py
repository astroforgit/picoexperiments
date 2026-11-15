"""Changes to the arcade code made while translating it (see translate.py).

REPLACE: start -> (end, lines, mode): the 8080 code in [start, end) becomes
`lines`. mode "fall": the patch continues at `end`; "ret": it returns;
"keep": the original instructions stay in the analysis.
BEFORE / AFTER: addr -> lines emitted before / after the instruction.
"""

REPLACE = {
    # wait for the vertical blank (polls DSW0 bit 7) -> compose and wait
    0x0080: (0x008E, ["jsr rt_frame"], "fall"),
    # copy the shared variables to the other player's RAM bank, then switch:
    # the RAM banks are swapped by the runtime; the stack copy is not needed
    0x0460: (0x049E, ["jsr rt_switch_bank", "rts"], "ret"),
    # POP HL / POP HL / JP (HL): return to the caller's caller
    0x0EE3: (0x0EE6, ["pla", "pla", "rts"], "keep"),
    # copyright check (the Amiga ROM image has the HALT removed): return
    0x1DF0: (0x1DF9, ["rts"], "ret"),
}

BEFORE = {}
AFTER = {}
EXTRA_ENTRIES = []

# JP (HL) sites: pc -> (table format, table address, entries)
# "be": 16-bit big-endian addresses; "lo07": low bytes of $07xx addresses
JUMP_TABLES = {
    0x040D: ("be", 0x040E, 8),
    0x080F: ("be", 0x0814, 16),
    0x3011: ("be", 0x3018, 8),
    0x0734: ("lo07", 0x0738, 8),
    0x0758: ("lo07", 0x075B, 8),
}

# ---------------------------------------------------------------- Amiga port
# Sound: the Amiga port (jotd) replaced the arcade's analogue sound with
# samples started at these places; here they start POKEY effects.
def _snd(sid):
    return [f"jsr hk_snd", f"dta {sid}"]


SND = {name: i for i, name in enumerate([
    "SHOT", "SHOT_BOUNCES_1", "SHOT_BOUNCES_2", "SHIELD", "EXPLOSION", "BIRD_SHOT",
    "ATTACK_LOOP", "VULTURE_SHOT", "VULTURE_BACK_1", "VULTURE_BACK_2", "BOSS",
    "BOSS_SHIELD_SHOT_1", "BOSS_SHIELD_SHOT_2", "START_MUSIC", "BOSS_END_MUSIC", "EXTRA_LIFE"])}

BEFORE.update({
    0x02C7: ["jsr hk_start"],                  # new game: Jeux Interdits
    0x08E6: _snd(SND["SHIELD"]),
    0x0961: _snd(SND["SHOT"]),                       # player shot
    0x0CC4: ["jsr hk_stop"] + _snd(SND["EXPLOSION"]),   # player hit
    0x0EC1: _snd(SND["BIRD_SHOT"]),                  # bird shot
    0x2384: ["jsr hk_bshield"],                 # shot hits the mothership's shield
    0x23C7: ["jsr hk_stop"] + _snd(SND["EXPLOSION"]),   # mothership destroyed
    0x2520: _snd(SND["BOSS_END_MUSIC"]),             # Fur Elise
    0x386B: _snd(SND["VULTURE_SHOT"]),               # vulture killed
    0x389C: _snd(SND["BIRD_SHOT"]),
    0x38F1: _snd(SND["SHOT_BOUNCES_1"]),             # wing hit
    0x3AB5: ["jsr hk_attack"],                      # attack loop on/off (C = attackers)
    0x3AF4: ["jsr hk_vback"],                # wing grows back
    0x3B13: ["jsr hk_boss"],                   # mothership hum, every 6th call
    0x3B3A: ["jsr hk_xlife"],                  # extra life beep, every 16th call
})

# Gameplay changes of the Amiga port (left out of the "arcade" test build)
import os  # noqa: E402
if os.environ.get("PHOENIX_VARIANT") != "arcade":
    # Don Hodges' fix: the explosion slot search can run into the score at
    # $4380 (the "204K score bug"); wrap to the first slot instead
    BEFORE[0x0ED5] = ["jsr hook_hodges"]
    # update the high score as soon as the score changes, not at game over
    BEFORE[0x0232] = ["jsr hook_hiscore"]

# PUSH BC of a code address, later reached by RET (threaded code):
# push site -> (continuation addresses, the RET that consumes it directly or None)
# $350E/$3519: a computed jump into the unrolled copy loop at $3520.
# $35D9/$35DB and $35D4: per-state handlers from the table at $3F00
# (entries 1-15, words 3 and 4); the handlers' RETs go to the $35D4 one.
CODE_PUSH = {
    0x350E: ([0x3520, 0x3528, 0x3530, 0x3538, 0x3540, 0x3548, 0x3550, 0x3558], 0x3519),
    0x35D9: ([0x35E0, 0x36C0], 0x35DB),
    0x35D4: ([0x36CC, 0x36D2, 0x36EA, 0x370A], None),
}
# RETs of the handlers pushed at HANDLERS_OF go to the continuations pushed at the key
CONTINUE_AFTER = {0x35D4: 0x35D9}
