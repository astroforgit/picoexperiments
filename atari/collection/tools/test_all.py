#!/usr/bin/env python3
"""Run or reuse baseline comparisons for every archived MADS build."""
from pathlib import Path
import argparse,concurrent.futures,hashlib,json,collections,time
from test_recovered import test,machine_for
ROOT=Path(__file__).resolve().parents[1]

def run(job):
    rec,runner=job;folder=ROOT/rec['folder'];dec=folder/'decompiled'
    original=(folder/'original.xex').read_bytes()
    if hashlib.sha256(original).hexdigest()!=rec['sha256']:return {'folder':rec['folder'],'status':'original_hash_mismatch'}
    curated=dec/'reconstruction.json'
    if curated.exists():
        marker=json.loads(curated.read_text())
        if (dec/marker['packed_output']).read_bytes()!=original:return {'folder':rec['folder'],'status':'rebuilt_mismatch'}
        if marker.get('pal_ntsc_smoke_test'):return {'folder':rec['folder'],'status':marker.get('emulator_check_status','game_specific_pal_ntsc_smoke_passed'),'test_frames':marker['test_frames'],'emulator_errors':marker.get('emulator_errors',0)}
    stage=dec/'recovered-stages';out=stage if (stage/'rebuilt-packed.xex').exists() else dec
    rebuilt=out/('rebuilt-packed.xex' if out==stage else 'game.xex')
    if rebuilt.read_bytes()!=original:return {'folder':rec['folder'],'status':'rebuilt_mismatch'}
    machine=machine_for(rec['folder'])
    evidence=out/'verification/pal.json'
    if evidence.exists():
        prior=json.loads(evidence.read_text())
        if prior.get('machine','-xl')==machine and prior['status'] not in ('test_incomplete','comparison_needs_review'):return prior
        if prior.get('machine','-xl')!=machine:(out/'verification/pal-previous-machine.json').write_text(evidence.read_text())
    return test((rec['folder'],runner,'pal'))

def main():
    p=argparse.ArgumentParser();p.add_argument('--runner',required=True);p.add_argument('--jobs',type=int,default=8);args=p.parse_args()
    games=json.loads((ROOT/'manifest.json').read_text())['games'];results=[];start=time.time();runner=str(Path(args.runner).resolve())
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        for result in pool.map(run,[(r,runner) for r in games]):
            results.append(result)
            if len(results)%100==0:
                summary=dict(collections.Counter(r['status'] for r in results))
                print(f'{len(results)}/{len(games)} games checked: {summary}',flush=True)
                (ROOT/'emulator-all-live.json').write_text(json.dumps({'completed':len(results),'summary':summary},indent=2)+'\n')
    report={'games':len(results),'elapsed_seconds':round(time.time()-start,1),'summary':dict(collections.Counter(r['status'] for r in results)),'limitations':['PAL baseline comparisons use Altirra XL OS, BASIC disabled, 1200 scripted frames.','130 XE/128K-labelled releases use XE memory; 256/320 XE-labelled releases use 320 XE memory. VBXE and other requirements need manual review.','Screen activity and original agreement do not establish a complete gameplay test.','Individually reconstructed games have separate PAL/NTSC smoke tests; see progress.json.'],'results':results}
    (ROOT/'emulator-all.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report['summary'],indent=2))
if __name__=='__main__':main()
