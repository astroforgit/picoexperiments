"""Build the Retro Fans League's roster and double round-robin schedule."""
from pathlib import Path

# First eleven are the starting XI in engine slot order. Last five are reserves.
CLUBS = [
    ("ATARI FUJI FC", 5, 0, "Joe Decuir|Al Alcorn|Ted Dabney|Julius Caesar|Leonardo da Vinci|Nolan Bushnell|Ed Logg|Hedy Lamarr|Benjamin Franklin|Annie Oakley|Harriet Tubman|David Crane|Owen Rubin|Sacagawea|John Adams|Amelia Earhart"),
    ("C64 SID UNITED", 4, 1, "Al Charpentier|Jack Tramiel|David Ziembicki|Isaac Newton|Galileo Galilei|Bob Yannes|Bruce Crockett|Mary Shelley|Blaise Pascal|Napoleon Bonaparte|Joan of Arc|Robert Russell|Sophie Germain|Louis Pasteur|Mary Anning|Antoine Lavoisier"),
    ("AMIGA BOING ATHLETIC", 0, 2, "Dale Luck|Dave Needle|Andy Finkel|Cleopatra|Nikola Tesla|Jay Miner|RJ Mical|Grace Hopper|Michael Faraday|Wolfgang Mozart|Nefertiti|Carl Sassenrath|Johannes Kepler|Frida Kahlo|Antonio Vivaldi|Catherine the Great"),
    ("ZX SPECTRUM RAINBOW", 6, 3, "Steve Vickers|John Grant|Rick Dickinson|Alexander the Great|Pythagoras|Clive Sinclair|Richard Altwasser|Ada Lovelace|Jane Austen|William Shakespeare|Boudica|Jim Westwood|Charles Dickens|Mary Seacole|Florence Nightingale|James Watt"),
    ("AMSTRAD CPC CITY", 7, 4, "Roland Perry|Bob Watkins|William Poel|Hannibal|Marie Curie|Alan Sugar|Cliff Lawson|Louis Braille|Victor Hugo|Simon Bolivar|Toussaint Louverture|Gary Kildall|Coco Chanel|Auguste Rodin|Claude Monet|Camille Claudel"),
    ("BBC MICRO OWLS", 3, 5, "Steve Furber|Hermann Hauser|Chris Curry|Archimedes|Socrates|Sophie Wilson|David Braben|Elizabeth I|Plato|Homer|Sappho|Ian Bell|Aristotle|Euclid|Aesop|Herodotus"),
    ("APPLE II ORCHARD", 10, 0, "Steve Wozniak|Rod Holt|Mike Markkula|Hypatia|Rachel Carson|Steve Jobs|Bill Budge|Beatrix Potter|Albert Einstein|Katherine Johnson|George Washington|Dan Bricklin|Susan B Anthony|Mark Twain|Emily Dickinson|Henry David Thoreau"),
    ("IBM PC UNITED", 2, 1, "David Bradley|Philip Estridge|Jack Sams|Genghis Khan|Al Khwarizmi|Mark Dean|Bill Gates|Alan Turing|George Boole|Sun Tzu|Ibn Sina|Paul Allen|Murasaki Shikibu|Zheng He|Ban Zhao|Ibn Battuta"),
]


def build(gen: Path):
    def table(name, entries):
        return name + "\n" + "".join(
            "        dta " + ",".join(str(byte) for byte in entry) + "\n"
            for entry in entries
        )

    order = list(range(8))
    first_leg = []
    for round_no in range(7):
        for slot in range(4):
            pair = (order[slot], order[-1-slot])
            first_leg.append(pair[::-1] if (round_no + slot) % 2 else pair)
        order = [order[0], order[-1], *order[1:-1]]
    fixtures = first_leg + [(away, home) for home, away in first_leg]
    assert len(set(fixtures)) == 56
    for start in range(0, 56, 4):
        assert sorted(team for pair in fixtures[start:start+4] for team in pair) == list(range(8))

    roster = bytearray()
    seen = set()
    for club, _, _, names in CLUBS:
        roster.extend(club.encode("ascii").ljust(24))
        players = names.upper().split("|")
        assert len(players) == 16 and len(club) <= 24
        for player in players:
            assert len(player) <= 24 and player not in seen, player
            seen.add(player)
            roster.extend(player.encode("ascii").ljust(24))
    assert len(roster) == 8 * 17 * 24
    # Keep immutable tables alongside the roster, freeing league code space.
    tables = {
        "fixture_home": [h for h, _ in fixtures],
        "fixture_away": [a for _, a in fixtures],
        "club_shirt": [shirt for _, shirt, _, _ in CLUBS],
        "club_formation": [formation for _, _, formation, _ in CLUBS],
        "roster_lo": [(team * 408) & 255 for team in range(8)],
        "roster_hi": [0x50 + (team * 408 >> 8) for team in range(8)],
    }
    labels=[]
    for name,data in tables.items():
        labels.append(f"{name} = ${0x5000+len(roster):04x}")
        roster.extend(data)
    assert len(roster)<=4096
    (gen / "league-rosters.bin").write_bytes(roster)
    (gen / "league-tables.asm").write_text("\n".join(labels)+"\n")
