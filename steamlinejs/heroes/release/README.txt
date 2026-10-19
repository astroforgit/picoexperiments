PRINCE AND THE NIMF
Everything by astrofor

A humorous fantasy strategy game for Atari XL/XE with VBXE FX 1.2x.
Recruit an army in Greenhaven, clear the four lairs, defeat the necromancer,
and rescue the nimf. The story continues through a three-picture wedding ending.

START
Windows: extract the complete package, then run run-prince-and-the-nimf.cmd.
WSL: run ./run-prince-and-the-nimf.sh from the extracted directory.
The launcher finds an existing Altirra installation and uses its persistent
hardware profile. Enable VBXE in that profile. Set ALTIRRA_PATH if necessary.
It mounts prince-and-the-nimf.atr in D1: and starts prince-and-the-nimf.xex.

Manual loading / real Atari: use an XL/XE with 64 KB and VBXE FX 1.2x,
load prince-and-the-nimf.xex with BASIC disabled and mount the companion
prince-and-the-nimf.atr as D1:. The disk has 256-byte sectors; the drive or
SIO peripheral must support the supplied 1 MB ATR. The full-quality ending
and game-over artwork need this disk. Additional extended CPU RAM is not needed.
The introduction reclaims its picture/code memory after loading.

MENU AND CONTROLS
After the picture introduction, choose Start Game, How to Play, or Credits.
Joystick, WASD or arrow keys navigate. Fire, Enter or Space chooses an action.
Release between presses. Escape or SELECT goes back or opens the retreat menu.
At the palace, inspect buildings to build/upgrade or recruit. Select soldiers
in the lower army row to upgrade or dismiss them. The wall gate opens the map.
In battle, select a soldier, then a highlighted destination or valid enemy.
Attacking ends that soldier's turn. Double-press Fire on the selected soldier,
or choose Skip, to finish its turn. After all soldiers finish, enemies act.

CAMPAIGN
Start: 50 gold, two Spearmen, level-2 Barracks and three army slots.
Three victories in each lair unlock the next. Cleared lairs remain available,
but further victories make encounters stronger. Chapel upgrades unlock the
fourth/fifth army slots and eventually reduce recruitment costs.
Survivors recover HP; dead soldiers stay dead and replacements cost gold.
Keep money for replacements, and avoid buying buildings you cannot afford
soldiers for. Different purchasing routes carry different risks.
Killing the final Warlock wins immediately and plays the wedding ending.
Losing every soldier without enough gold for any available recruit is game over.
Fire starts a fresh campaign after defeat or after the final ending page.
There are no saves; restarting starts over. The Chapel has a free ART GALLERY action after it is built. After two
victories, scouts find the notes of goblin master painter Grubbrush, whose
portraits of the nimf were scattered by bandits. Later victories recover eight
unique paintings, two hidden in each lair, with locations shuffled each campaign.
The Forest yields its paintings on the third and fourth wins; each other lair
yields one on its first win and another on its second. Revisit the Forest once
for the full collection. All eight can be recovered before the final boss. Viewing the
collection changes no gold or troops. A new campaign clears the collection;
there are still no saves. Short sound effects are included,
without music. The development O shortcut is removed from the release game.
For direct picture inspection, the separate story-test XEX now shows ONLY
the eight new gallery paintings. It now also streams from the companion ATR; its runner mounts the disk
automatically. It remains in the source repository and is not needed to play.

CREDITS
Everything by astrofor.
Game, code, art, story, design and balance: astrofor.

VALIDATION
Automated tests execute the assembled 6502 program on both D600/D700 VBXE
mappings. A complete 12-victory campaign replays legal purchases, upgrades,
movement and combat with real economy/AI/casualty code, no free gold/troops,
and no forced victories. Menu, input, sound-register writes, defeat, final
victory, intro reclamation, exact disk-streamed pictures and missing media
are checked separately. SHA256SUMS verifies the package files.
The model substitutes the OS SIO call and VBXE device behavior. Live Altirra
playback and physical VBXE/disk timing remain unverified: the desktop-control
connection was unavailable. The stats-bot completion rates are not human win
probabilities. See the release-check report beside the downloadable package.
