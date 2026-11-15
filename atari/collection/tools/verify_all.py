#!/usr/bin/env python3
"""Assemble every game and compare with originals; verify extraction hashes."""
import argparse,concurrent.futures,hashlib,json,os,subprocess,time,zipfile
from pathlib import Path
from atr import files
ROOT=Path(__file__).resolve().parents[1]

def verify(rec):
    folder=ROOT/rec['folder'];out=folder/'decompiled';original=(folder/'original.xex').read_bytes()
    result=dict(folder=rec['folder'],title=rec['title'],original_sha256=hashlib.sha256(original).hexdigest())
    try:
        if result['original_sha256']!=rec['sha256']:raise ValueError('Original SHA-256 mismatch')
        marker=out/'reconstruction.json'
        curated=json.loads(marker.read_text()) if marker.exists() else None
        has_stages=(out/'recovered-stages/recovery.json').exists()
        has_relocations=not curated and (out/'relocated-runtime/recovery.json').exists()
        has_runtime_view=not curated and (out/'runtime-archive.json').exists()
        command=['sh','build.sh'] if curated or has_stages or has_runtime_view or has_relocations else [os.environ.get('MADS','mads'),'game.asm','-o:game.xex']
        if has_stages:result['recovered_stages']=len(json.loads((out/'recovered-stages/recovery.json').read_text())['stages'])
        if curated and 'recovered_stage_count' in curated:result['recovered_stages']=curated['recovered_stage_count']
        proc=subprocess.run(command,cwd=out,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=60)
        if proc.returncode:raise ValueError(proc.stdout[-4000:])
        rebuilt=(out/(curated['packed_output'] if curated else 'game.xex')).read_bytes();result['rebuilt_sha256']=hashlib.sha256(rebuilt).hexdigest()
        if rebuilt!=original:
            mismatch=next((i for i,(a,b) in enumerate(zip(original,rebuilt)) if a!=b),min(len(original),len(rebuilt)))
            raise ValueError(f'Byte mismatch at {mismatch}; lengths {len(original)}/{len(rebuilt)}')
        if has_runtime_view:
            runtime_rebuilt=(out/'runtime-archive.xex').read_bytes()
            if runtime_rebuilt!=original:raise ValueError('Runtime archive view differs from original executable')
            result['runtime_archive_status']='pass'
            result['runtime_archive_sha256']=hashlib.sha256(runtime_rebuilt).hexdigest()
        if has_relocations:
            if 'relocated-runtime/build.sh' not in (out/'build.sh').read_text():
                relocation_proc=subprocess.run(['sh','relocated-runtime/build.sh'],cwd=out,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=60)
                if relocation_proc.returncode:raise ValueError(relocation_proc.stdout[-4000:])
            if (out/'relocated-runtime/rebuilt-packed.xex').read_bytes()!=original:raise ValueError('Relocation view differs from original executable')
            result['relocated_runtime_status']='pass'
        result['status']='pass'
    except Exception as e:result.update(status='fail',error=str(e))
    return result

def main():
    p=argparse.ArgumentParser();p.add_argument('--jobs',type=int,default=4);p.add_argument('--sources-only',action='store_true',help='Build all sources without the separate original ZIP/ATR extraction check');a=p.parse_args()
    manifest=json.loads((ROOT/'manifest.json').read_text());start=time.time();results=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:
        for result in pool.map(verify,manifest['games']):
            results.append(result)
            if result['status']=='fail':print('FAIL',result['folder'],result['error'],flush=True)
            if len(results)%250==0:print(f'{len(results)}/{len(manifest["games"])} checked',flush=True)
    # Independently re-extract every DOS file and account for it exactly once.
    extraction=[]
    if not a.sources_only:
        with zipfile.ZipFile(ROOT/'Homesoft Collection (Images).zip') as z:
            assert hashlib.sha256((ROOT/'Homesoft Collection (Images).zip').read_bytes()).hexdigest()==manifest['archive_sha256']
            for disk in manifest['disks']:
                dn=disk['disk'];raw=z.read(f'Homesoft Collection/GAMES{dn:03d}.ATR')
                assert (ROOT/disk['path']).read_bytes()==raw
                expected={}
                for r in manifest['games']:
                    if r['disk']!=dn:continue
                    expected[r['disk_filename']]=ROOT/r['folder']/'original.xex'
                    for x in r['supporting_files']:expected[x['filename']]=ROOT/x['path']
                for x in manifest['supplemental']:
                    if x['disk']==dn:expected[x['filename']]=ROOT/x['path']
                extracted=list(files(raw));assert len(extracted)==len(expected)
                for name,b,_,_ in extracted:assert expected[name].read_bytes()==b,(dn,name)
                extraction.append(dict(disk=dn,files=len(extracted),status='pass'))
    report=dict(games=len(results),passed=sum(x['status']=='pass' for x in results),failed=sum(x['status']=='fail' for x in results),extracted_files=sum(x['files'] for x in extraction),disks=len(extraction),elapsed_seconds=round(time.time()-start,1),results=results,extraction=extraction)
    report['extraction_check']='not_run_sources_only' if a.sources_only else 'passed'
    (ROOT/('verification-sources-only.json' if a.sources_only else 'verification.json')).write_text(json.dumps(report,indent=2)+'\n')
    print({k:v for k,v in report.items() if k not in ('results','extraction')},flush=True)
    raise SystemExit(bool(report['failed']))

if __name__=='__main__':main()
