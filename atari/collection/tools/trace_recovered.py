#!/usr/bin/env python3
"""Augment recovered-stage assembly with instruction evidence from Atari800.

Only observed addresses whose three captured instruction bytes equal the stage
image are admitted. This is code discovery, not semantic annotation. Overlays,
self-modification and unvisited game paths still require manual investigation.
"""
from pathlib import Path
import argparse,concurrent.futures,hashlib,json,os,subprocess,tempfile
from PIL import Image
from recover_common import trace
from disasm import instruction,dta
from test_recovered import machine_for
ROOT=Path(__file__).resolve().parents[1]

def augment(out,pcmap,sources=None):
    out=Path(out);report=json.loads((out/'recovery.json').read_text());records={}
    raw=Path(pcmap).read_bytes()
    if len(raw)%5:raise ValueError('Malformed PC map')
    for i in range(0,len(raw),5):records[int.from_bytes(raw[i:i+2],'little')]=raw[i+2:i+5]
    for stage in report['stages']:
        if sources is not None and stage['source'] not in sources:continue
        expected=(out/stage['binary']).read_bytes()
        if hashlib.sha256(expected).hexdigest()!=stage['sha256']:raise ValueError('Recovered image changed')
        ram=bytearray(65536);offset=0
        for lo,hi in stage['spans']:ram[lo:hi]=expected[offset:offset+hi-lo];offset+=hi-lo
        if offset!=len(expected):raise ValueError('Incorrect span lengths')
        observed=[a for a,b in records.items() if any(lo<=a and a+3<=hi for lo,hi in stage['spans']) and ram[a:a+3]==b]
        seeds=sorted(set(stage['entry_seeds']+observed));code,conflicts=trace(ram,stage['spans'],seeds)
        lines=[f'; {report["title"]}: recovered stage with runtime code evidence.',
            '; Atari800 instruction addresses are accepted only when all three bytes match this image.',
            '; Static continuation can still be ambiguous; overlays and semantics need manual review.',
            '    opt h-']
        for lo,hi in stage['spans']:
            lines.append(f'    org ${lo:04X}');a=lo
            while a<hi:
                if a in code:
                    n=code[a];lines.append(f'L{a:04X}: {instruction(ram[a:a+n],a)}');a+=n
                else:
                    n=1
                    while n<16 and a+n<hi and a+n not in code:n+=1
                    lines.append(dta(ram[a:a+n])+f' ; ${a:04X}');a+=n
        temp=out/(stage['source']+'.runtime.asm');binary=out/(stage['binary']+'.runtime.bin');temp.write_text('\n'.join(lines)+'\n')
        p=subprocess.run([os.environ.get('MADS','mads'),str(temp),'-o:'+str(binary)],capture_output=True,text=True,timeout=30)
        if p.returncode:raise ValueError(p.stdout[-2000:]+p.stderr[-2000:])
        if binary.read_bytes()!=expected:raise ValueError('Runtime-augmented source does not match stage bytes')
        temp.replace(out/stage['source']);binary.unlink()
        stage['static_code_bytes']=stage.get('static_code_bytes',stage['code_bytes']);stage['code_bytes']=sum(code.values());stage['instructions']=len(code);stage['runtime_matching_entries']=len(observed);stage['overlapping_decodes_discarded']=conflicts
    report['runtime_code_evidence']='verification/runtime.pcmap: last observed instruction bytes per address, PAL, 1200 frames'
    (out/'recovery.json').write_text(json.dumps(report,indent=2)+'\n')
    return sum(s['code_bytes'] for s in report['stages'])

def run(job):
    folder,runner=job;game=ROOT/folder;out=game/'decompiled/recovered-stages';v=out/'verification';v.mkdir(exist_ok=True)
    machine=machine_for(folder)
    result={'folder':folder,'machine':machine}
    if (game/'decompiled/reconstruction.json').exists():result['status']='curated_preserved';return result
    if not json.loads((out/'recovery.json').read_text())['stages']:result['status']='requires_loader_context';return result
    try:
        with tempfile.TemporaryDirectory(prefix='atari-code-trace-') as temp:
            temp=Path(temp);config=temp/'atari800.cfg';config.write_text('Atari 800 Emulator configuration file\n');prefix=temp/'runtime'
            p=subprocess.run([runner,str(game/'original.xex'),str(prefix),str(config),'pal'],capture_output=True,text=True,timeout=45,env={**os.environ,"ATARI800_TEST_MACHINE":machine})
            if p.returncode:raise ValueError(p.stdout[-1000:]+p.stderr[-1000:])
            (v/'runtime.pcmap').write_bytes(prefix.with_suffix('.pcmap').read_bytes())
            (v/'runtime.json').write_bytes(prefix.with_suffix('.json').read_bytes())
            result['code_bytes']=augment(out,v/'runtime.pcmap');result['status']='runtime_code_added_and_mads_verified'
    except Exception as e:result.update(status='needs_review',error=str(e))
    (v/'runtime-recovery.json').write_text(json.dumps(result,indent=2)+'\n');return result

def main():
    p=argparse.ArgumentParser();p.add_argument('--runner',required=True);p.add_argument('--jobs',type=int,default=4);p.add_argument('--game');args=p.parse_args()
    paths=list((ROOT/'games').glob('*/decompiled/recovered-stages/rebuilt-packed.xex'));folders=[str(p.parent.parent.parent.relative_to(ROOT)) for p in paths]
    if args.game:folders=[f for f in folders if f=='games/'+args.game]
    results=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        for result in pool.map(run,[(f,str(Path(args.runner).resolve())) for f in folders]):
            results.append(result)
            if len(results)%100==0:print(f'{len(results)}/{len(folders)} runtime traces processed',flush=True)
    output=ROOT/('runtime-'+args.game+'.json' if args.game else 'runtime-recovery-progress.json');output.write_text(json.dumps(results,indent=2)+'\n')
    from collections import Counter
    print(dict(Counter(r['status'] for r in results)))
if __name__=='__main__':main()
