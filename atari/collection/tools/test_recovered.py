#!/usr/bin/env python3
"""Compare rebuilt releases with their originals; report limitations explicitly."""
import argparse,concurrent.futures,json,subprocess,tempfile,shutil,os
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]

def machine_for(folder):
    if '320-xe' in folder or '256-xe' in folder:return '-320xe'
    if '130-xe' in folder or '128k' in folder:return '-xe'
    return os.environ.get('ATARI800_TEST_MACHINE','-xl')

def test(job):
    folder,runner,tv=job;game=ROOT/folder;out=game/'decompiled/recovered-stages'
    if not (out/'rebuilt-packed.xex').exists():out=game/'decompiled'
    rebuilt=out/('rebuilt-packed.xex' if out.name=='recovered-stages' else 'game.xex')
    evidence=out/'verification';evidence.mkdir(exist_ok=True)
    machine=machine_for(folder)
    result={'folder':folder,'tv':tv,'machine':machine}
    if 'vbxe' in folder:result['configuration_note']='VBXE is not emulated by this core; its enhanced display/gameplay is not validated.'
    try:
        with tempfile.TemporaryDirectory(prefix='atari-smoke-') as temp:
            temp=Path(temp);config=temp/'atari800.cfg';config.write_text('Atari 800 Emulator configuration file\n')
            records={}
            for variant,path in [('original',game/'original.xex'),('rebuilt',rebuilt)]:
                prefix=temp/variant
                p=subprocess.run([runner,str(path),str(prefix),str(config),tv],capture_output=True,text=True,timeout=45,env={**os.environ,"ATARI800_TEST_MACHINE":machine})
                if p.returncode:raise ValueError(p.stdout[-1000:]+p.stderr[-1000:])
                records[variant]=json.loads(prefix.with_suffix('.json').read_text())
                Image.open(prefix.with_suffix('.ppm')).save(evidence/f'{variant}-{tv}.png')
            result.update(records)
            result['frame_trace_matches']=records['original']==records['rebuilt']
            result['final_screen_matches']=(temp/'original.ppm').read_bytes()==(temp/'rebuilt.ppm').read_bytes()
            if not result['frame_trace_matches'] or not result['final_screen_matches']:result['status']='comparison_needs_review'
            elif records['rebuilt']['errors_after_boot']:result['status']='matches_original_with_emulator_errors'
            elif records['rebuilt']['screen_changes_after_400']<10:result['status']='matches_original_but_little_screen_activity'
            else:result['status']='regression_smoke_matches_original'
            result['limitations']='Generic boot/input regression only; does not establish correct gameplay, sound or complete decompilation.'
    except Exception as e:result.update(status='test_incomplete',error=str(e))
    (evidence/f'{tv}.json').write_text(json.dumps(result,indent=2)+'\n')
    return result

def main():
    p=argparse.ArgumentParser();p.add_argument('--runner',required=True);p.add_argument('--jobs',type=int,default=4);p.add_argument('--game');p.add_argument('--ntsc',action='store_true');args=p.parse_args()
    games=[str(f.parent.parent.parent.relative_to(ROOT)) for f in (ROOT/'games').glob('*/decompiled/recovered-stages/rebuilt-packed.xex')]
    if args.game:games=[g for g in games if g=='games/'+args.game]
    runner=str(Path(args.runner).resolve());jobs=[(g,runner,tv) for g in sorted(games) for tv in (('pal','ntsc') if args.ntsc else ('pal',))];results=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        for result in pool.map(test,jobs):
            results.append(result)
            if len(results)%100==0:print(f'{len(results)}/{len(jobs)} emulator comparisons completed',flush=True)
    from collections import Counter
    summary=dict(Counter(r['status'] for r in results));report=ROOT/('emulator-'+args.game+'.json' if args.game else 'emulator-recovery-progress.json')
    report.write_text(json.dumps(dict(summary=summary,results=results),indent=2)+'\n');print(json.dumps(summary,indent=2))
if __name__=='__main__':main()
