#!/usr/bin/env python3
"""Add explicitly scored compositions without replacing earlier versions."""
import argparse
import importlib
import json
import re
from pathlib import Path
import shutil
import tempfile
import build_remixes as b
import build_collection as collection
import long_music


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--library',required=True)
    parser.add_argument('modules',nargs='+')
    args=parser.parse_args()
    lib=b.api(args.library);player,labels=long_music.build_player()
    catalog_path=b.ROOT/'remixes/catalog.json'
    catalog=json.loads(catalog_path.read_text())
    for name in args.modules:
        module=importlib.import_module(name)
        source=b.ROOT/module.SOURCE
        meta=collection.metadata(source)
        if hasattr(module,'SOURCE_SONG'):
            meta['song']=module.SOURCE_SONG
            header=source.read_bytes().split(b'\xff\xff')[0].decode('ascii')
            times=re.findall(r'^TIME (\d+):([\d.]+)',header,re.M)
            if meta['song']<len(times):
                minutes,seconds=times[meta['song']];meta['duration']=int(minutes)*60+float(seconds)
        frames,score,sections=module.compose(lib)
        original=b.capture(lib,source,len(frames),meta['song'])
        destination=b.ROOT/'remixes'/module.ID
        if destination.exists():
            # Rebuilding this dedicated composition is allowed; never overwrite a different piece.
            prior=json.loads((destination/'manifest.json').read_text())
            assert prior.get('composition_module')==name
        with tempfile.TemporaryDirectory(dir=str(b.ROOT),prefix='.individual-build-') as temp:
            folder=Path(temp)
            author=b.native_original(source,folder,module.TITLE,meta['song'])
            collection.validate_original(folder,meta,original)
            size=long_music.export(folder,module.REMIX_TITLE,frames,sections,player,labels)
            duration=len(frames)/b.convert.FPS
            actual=b.capture(lib,folder/'remix.sap',len(frames)+1)
            assert actual[:-1]==frames and actual[-1]==frames[0], 'Independent SAP playback differs'
            changed=sum(a[module.LEAD*2]!=z[module.LEAD*2] for a,z in zip(original,frames))
            item=dict(id=module.ID,title=module.TITLE,remix=module.REMIX_TITLE,author=author,
                      directory='remixes/'+module.ID,source=module.SOURCE,original_subsong=meta['song'],
                      source_duration_seconds=meta['duration'],duration_seconds=duration,frames=len(frames),
                      lead_channel=module.LEAD+1,changed_lead_frames=changed,
                      allowed_changed_registers=score.get('allowed_changed_registers',list(range(8))),
                      format='PMZ1',sections=sections,arrangement='New composition' if name.endswith('_new_song') else 'Individual composition',
                      composition_module=name,compressed_bytes=size,
                      description=score.get('short_description',score['description']),preservation=score.get('preservation','Original instruments with explicitly arranged source phrases and newly scored melody.'),
                      validation='Native original startup and every full remix frame/loop checked.')
            (folder/'manifest.json').write_text(json.dumps(item,indent=2)+'\n')
            (folder/'score.json').write_text(json.dumps(score,indent=2)+'\n')
            (folder/'original-registers.bin').write_bytes(b''.join(original))
            (folder/'remix-registers.bin').write_bytes(b''.join(frames))
            if destination.exists():
                for path in folder.iterdir():shutil.copy2(path,destination/path.name)
            else: shutil.copytree(folder,destination)
        catalog['tracks']=[t for t in catalog['tracks'] if t['id']!=module.ID]+[item]
        temp=catalog_path.with_suffix('.json.tmp');temp.write_text(json.dumps(catalog,indent=2)+'\n');temp.replace(catalog_path)
        print(f'{module.REMIX_TITLE}: {duration:.1f}s, {len(sections)} sections, {size} bytes; verified',flush=True)


if __name__=='__main__':main()
