# Original code-drawn roster

The active editor now uses `pixel-units.js`, embedded in `unit-editor.html` so the page remains portable and works offline. No image generator or external sprite art is used by the current previews. Previous generated atlases remain archived and are not loaded.

All 15 player tiers and 13 enemies have individual definitions. Differences include equipment, headgear, robes, armor, body size, wings, horns and body shape, as well as color. These are simplified original pixel-style designs inspired by the requested medieval fantasy sprites, not copies of the reference sheet.

The 96×82 canvas renderer uses seven pose indices:

- 0–3: walk; legs, free arm and cape move, weapons remain carried. Bat wings use four flap positions.
- 4: attack preparation.
- 5: attack release.
- 6: resting pose.

The table's movement animation can select only 0–3. Attack can select 4, 5 and then 6. Reduced motion uses a static pose. Walking, attacking and resting are available for every unit, including enemies. `pixel-roster.png` is a browser-rendered review sheet of every pose.

These animations are preview artwork and are not yet converted to Atari VBXE sprite data. No combat statistics were changed.

Validation: browser loaded all 28 designs without JavaScript errors; all 28 idle images were distinct; every unit had different opposite walking strides and distinct attack preparation/release images. Frame-selection checks cover all units in move, attack and idle modes.
