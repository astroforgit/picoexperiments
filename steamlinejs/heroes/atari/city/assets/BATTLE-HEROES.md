# Full-body battle troops

The battle hero frames are converted from the local King's Bounty asset pack at
`../../../openbounty-main/openbounty-main/assets/kings-bounty/art/troops/`.
They are existing third-party artwork, not newly generated illustrations.
OpenBounty's source license does not by itself establish the rights to the
original King's Bounty artwork; keep this provenance with the prototype assets.

Each `battle-hero-<troop>-0.png` through `-3.png` is a complete 32×28 transparent
frame, converted from the complete 48×34 source with nearest-neighbor sampling.
No body crop is performed. Existing exported PNGs are preserved on rebuild.

The pack supplies a four-pose troop animation, not separately named walk and
attack sheets. Movement cycles these poses; melee combines a pose sequence with
an attacker lunge; ranged attacks combine poses with a traveling projectile.
City army portraits remain independent and are never used as battle bodies.

| City line | Battle artwork, tiers 1 / 2 / 3 |
|---|---|
| Barracks | militia / pikemen / knights |
| Archery | archers / archers / elves |
| Lodge | nomads / nomads / nomads |
| Chapel | druids / druids / druids |
| Tower | archmages / archmages / archmages |

These mappings select artwork only. Names, prices, statistics and the independent
state of duplicate fighters are unchanged. Shared art across some tiers keeps
this version inside the available VBXE memory; city portraits still distinguish
the upgrade tiers.

The exporter uses a local 15-color palette per source troop and compresses pairs
of pixels into unused VRAM gaps. At runtime one frame is decoded through CPU
scratch `$8400..$87FF` into VBXE `$7E000..$7E37F`. A pose cache avoids decoding
identical consecutive sprites. The build verifies every allocation and ensures
compressed frames never cross a 4K aperture boundary.
