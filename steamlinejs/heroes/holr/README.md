# Heroes of Lowrez recovered Lua source

These 17 Lua files were extracted from the local Heroes of Lowrez web bundle.
They contain the source text embedded in the shipped resources, unchanged;
they are not a reconstruction of the gameplay. Comments or formatting removed
when the original game was built cannot be recovered.

Start with:

- [Unit stats, prices and encounters](lua_modules/globals.lua)
- [Battle rules](lua_modules/tactic.lua)
- [Battle screen](battle/battle.script.lua)
- [Unit movement and animation](battle/unit.script.lua)
- [Town recruitment and army capacity](town/town.gui_script.lua)
- [Unit upgrades](upgrade/upgrade.gui_script.lua)
- [Building purchases](builder/builder.gui_script.lua)

The original directories are preserved. Defold `.script`, `.gui_script`, and
`.render_script` resources have an additional `.lua` extension for convenient
editing. `manifest.json` records their original filenames, archive indexes and
SHA-256 fingerprints, together with the input archive fingerprints.

This is a source export, not a complete runnable Defold project. Scripts depend
on Defold APIs and game resources such as collections, GUI scenes and atlases.
Use the original web bundle to play the original game. Source and assets remain
the work of their original authors; this export does not grant a new license.

To regenerate from the local archive (Python 3 and system liblz4 required):

```sh
python3 steamlinejs/heroes/holr/export.py
```

The exporter reuses `../design/lowrez/recover.py`, which also writes decoded
resources to `/tmp/lowrez-extracted`. It never executes the recovered Lua.
