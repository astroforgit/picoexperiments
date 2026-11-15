#!/usr/bin/env python3
"""Package the Windows comparison collection; no Python or WSL needed to run it."""
from pathlib import Path
import json
import zipfile

root = Path(__file__).resolve().parents[1]
destination = root/'Atari-Sound-Windows.zip'
temporary = destination.with_suffix('.zip.tmp')
with zipfile.ZipFile(temporary, 'w', zipfile.ZIP_DEFLATED) as archive:
    files = ['START-WINDOWS.cmd', 'START-PICO-WINDOWS.cmd', 'tools/compare-music.ps1', 'tools/music-library.ps1',
             'player/music-profile.ini',
             'remixes/catalog.json', 'remixes/README.md', 'remixes/CATALOG.md',
             'remixes/full-validation.json', 'catalog.json', 'auditions/catalog.json', 'auditions/README.md',
             'rmt-variations/catalog.json', 'rmt-variations/README.md',
             'rmt-variations/instrument-bank.json', 'rmt-variations/validation.json',
             'rmt-variations/audio-validation.json']
    for track in json.loads((root/'remixes/catalog.json').read_text())['tracks']:
        for name in ['original.sap', 'remix.sap', 'ORIGINAL.XEX', 'REMIX.XEX',
                     'manifest.json']:
            files.append(track['directory']+'/'+name)
        for name in ['REMIX.PMZ','REMIX.PMS','score.json']:
            if (root/track['directory']/name).exists(): files.append(track['directory']+'/'+name)
    for catalog_name in ['catalog.json','auditions/catalog.json','rmt-variations/catalog.json']:
        for game in json.loads((root/catalog_name).read_text())['games']:
            folder=root/game['directory']
            files.append(game['directory']+'/manifest.json')
            if (folder/'arrangement.json').exists():
                files.append(game['directory']+'/arrangement.json')
            manifest=json.loads((folder/'manifest.json').read_text())
            for bank in manifest['banks']:
                for extension in ['.XEX','.PMS','.sap','-extra.sap']:
                    name=game['directory']+'/'+bank['file']+extension
                    if (root/name).exists(): files.append(name)
    for i,name in enumerate(files):
        archive.write(root/name, 'Atari-Sound/'+name)
        if (i+1)%100==0: print(f'Packaged {i+1}/{len(files)} files',flush=True)
    archive.write(root.parent/'atari-vbxe-toolkit/scripts/AltirraTools.psm1',
                  'Atari-Sound/tools/AltirraTools.psm1')
    archive.writestr('Atari-Sound/READ-ME.txt', '''Atari Sound for Windows

Extract this whole folder to a local Windows drive, then double-click
START-WINDOWS.cmd. No WSL, Python, or compiler is required.

Choose a track and a side to play it in the Atari emulator.
Playback uses native Atari music files; no audio previews are included.
Play original/remix in Atari opens the supplied XEX in Altirra.
If Altirra is not found, select your Altirra64.exe when prompted.

Original on the left, new remix on the right. N/P change music;
Left/Right switch sides. Stop stops playback. In Atari: Space pauses,
N/P change subsongs or sections in the expanded remixes.

The separate PAL emulator profile uses WaveOut and larger audio buffers.
It does not change your usual Altirra configuration.
Delete player/music-runtime.ini to reset this player's emulator settings.

PICO music: click PICO music or run START-PICO-WINDOWS.cmd.
Original PICO conversions are on the left; experimental RMT versions on the right.
Double-click a column or use its Play button. Each side has its own bank selector.
721 music pairs, plus 140 optional SFX pairs. Search by game or RMT donor name.
The original conversions and earlier four auditions are retained.
Experimental RMT versions use Space to pause, N for next pattern, P for previous.
''')
temporary.replace(destination)
print(destination)
