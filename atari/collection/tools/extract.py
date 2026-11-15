#!/usr/bin/env python3
"""Extract the Homesoft archive, mapping catalogue titles through menu sectors."""
import argparse,hashlib,json,re,unicodedata,zipfile
from pathlib import Path
from atr import files,sector
from disasm import generate
ROOT=Path(__file__).resolve().parents[1]

def slug(s):
    s=unicodedata.normalize('NFKD',s).encode('ascii','ignore').decode().lower()
    return re.sub('[^a-z0-9]+','-',s).strip('-') or 'untitled'

def main():
    p=argparse.ArgumentParser();p.add_argument('--limit',type=int);a=p.parse_args()
    z=zipfile.ZipFile(ROOT/'Homesoft Collection (Images).zip')
    catalogue=z.read('Homesoft Collection/GAMES.TXT');(ROOT/'GAMES.TXT').write_bytes(catalogue)
    titles={};disk=None
    for line in catalogue.decode('latin1').splitlines():
        m=re.match(r'^\s*(\d+)\t(.*)',line)
        if m:disk=int(m[1]);titles[disk]=[m[2]]
        elif line.startswith('\t') and disk:titles[disk].append(line.strip())
    records=[];extras=[];used=set();disk_records=[]
    for name in z.namelist():
        if not name.endswith('.ATR'):continue
        dn=int(re.search(r'(\d+)\.ATR',name)[1]);data=z.read(name)
        fs=list(files(data));menu=b''.join(sector(data,n) for n in (366,367,368))
        starts=[int.from_bytes(menu[i:i+2],'big') for i in range(24,len(menu)-23,24) if 0<int.from_bytes(menu[i:i+2],'big')<1024]
        assert len(starts)==len(titles[dn]),(dn,len(starts),len(titles[dn]))
        assert len(set(starts))==len(starts)
        assert set(starts).issubset({f[2] for f in fs})
        named=dict(zip(starts,titles[dn]));owners={};pending=[]
        for fn,b,start,count in fs:
            if start not in named:pending.append((fn,b,start,count));continue
            title=named[start];folder=slug(title)
            if folder in used:folder+=f'--disk-{dn:03d}-{starts.index(start)+1:02d}'
            used.add(folder);game=ROOT/'games'/folder;game.mkdir(parents=True,exist_ok=True)
            (game/'original.xex').write_bytes(b)
            curated=(game/'decompiled'/'reconstruction.json').exists()
            analysis=json.loads((game/'decompiled'/'analysis.json').read_text()) if curated else generate(game/'original.xex',game/'decompiled',title)
            record=dict(title=title,folder=f'games/{folder}',disk=dn,archive_member=name,disk_filename=fn,start_sector=start,sectors=count,sha256=hashlib.sha256(b).hexdigest(),bytes=len(b),traced_code_bytes=analysis['traced_code_bytes'],parse_warning=analysis['parse_warning'],supporting_files=[])
            if curated:record['reconstruction']=json.loads((game/'decompiled'/'reconstruction.json').read_text())
            records.append(record);owners[fn.split('.')[0]]=record
            if not curated:
                (game/'decompiled'/'build.sh').write_text('#!/bin/sh\nset -eu\ncd "$(dirname "$0")"\nif [ "${1:-}" = regen ]; then\n  python3 ../../../tools/disasm.py ../original.xex .\nfi\n"${MADS:-mads}" game.asm -o:game.xex -l:game.lst\ncmp game.xex ../original.xex\necho "OK: byte-identical to original.xex"\nif [ -f recovered-stages/build.sh ]; then sh recovered-stages/build.sh; fi\n')
                (game/'decompiled'/'build.sh').chmod(0o755)
        for fn,b,start,count in pending:
            rec=owners.get(fn.split('.')[0]);dest=(ROOT/rec['folder']/'supporting') if rec else ROOT/'supplemental'/f'disk-{dn:03d}'
            dest.mkdir(parents=True,exist_ok=True);(dest/fn).write_bytes(b)
            extra=dict(filename=fn,path=str((dest/fn).relative_to(ROOT)),disk=dn,sha256=hashlib.sha256(b).hexdigest(),bytes=len(b),start_sector=start,sectors=count)
            if rec:rec['supporting_files'].append(extra)
            else:extras.append(extra)
        # Keep exact ATRs: some games use sector-level disk I/O and need the menu disk.
        diskdir=ROOT/'disks';diskdir.mkdir(exist_ok=True);(diskdir/f'GAMES{dn:03d}.ATR').write_bytes(data)
        disk_records.append(dict(disk=dn,path=f'disks/GAMES{dn:03d}.ATR',sha256=hashlib.sha256(data).hexdigest(),files=len(fs),games=len(starts)))
        if dn%25==0:print(f'{dn} disks, {len(records)} games',flush=True)
        if a.limit and len(records)>=a.limit:break
    for rec in records:
        game=ROOT/rec['folder'];support='\n'.join('- `'+e['filename']+'`' for e in rec['supporting_files']) or 'None.'
        if (game/'decompiled'/'reconstruction.json').exists():
            (game/'metadata.json').write_text(json.dumps(rec,indent=2)+'\n')
            continue
        (game/'README.md').write_text(f'''# {rec['title']}

Extracted from `GAMES{rec['disk']:03d}.ATR`, DOS file `{rec['disk_filename']}`.
Original SHA-256: `{rec['sha256']}`.

## Build

```sh
cd decompiled
./build.sh
```

Needs MADS and `cmp`. The build assembles `game.asm`, writes `game.xex` and
`game.lst`, then compares every byte with `../original.xex`.
`./build.sh regen` replaces the generated source; save manual edits first.

## Analysis status

This is an automated **static disassembly**, not the original source and not a
hand-annotated reconstruction like the Agent USA or Zorro examples.
{rec['traced_code_bytes']:,} bytes were identified by following documented 6502
instructions from load-time INIT and RUN vectors. Remaining bytes are explicit
`dta` data, including any packed code. Loaders are not executed, relocation,
self-modifying code, bank switching and runtime indirect calls are unresolved.
Generated labels give segment and address; they do not assert gameplay roles.
`decompiled/analysis.json` contains segment ranges, entries and unresolved jumps.
A byte-identical rebuild proves preservation, not complete code identification.
Parse note: {rec['parse_warning'] or 'All file bytes parsed as XEX segments/markers.'}

## Playing and supporting files

`original.xex` is the unchanged extracted executable. For games that read disk
sectors or auxiliary files, mount `../../disks/GAMES{rec['disk']:03d}.ATR` and use
its original menu. Standalone XEX operation is not guaranteed or emulator-tested.
Supporting files retain their DOS names in `supporting/`:

{support}
''')
        (game/'metadata.json').write_text(json.dumps(rec,indent=2)+'\n')
    manifest=dict(games=records,supplemental=extras,disks=disk_records,archive_sha256=hashlib.sha256((ROOT/'Homesoft Collection (Images).zip').read_bytes()).hexdigest())
    (ROOT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    import csv
    with (ROOT/'catalogue.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=['title','folder','disk','disk_filename','bytes','traced_code_bytes','sha256']);w.writeheader()
        for r in records:w.writerow({k:r[k] for k in w.fieldnames})
    print(f'Done: {len(records)} games; {sum(len(r["supporting_files"]) for r in records)} supporting files; {len(extras)} supplemental files.',flush=True)

if __name__=='__main__':main()
