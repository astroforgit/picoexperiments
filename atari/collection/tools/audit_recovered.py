#!/usr/bin/env python3
"""Require each recovered image to be reproducible without unknown loader RAM.

Rejects backreferences outside bytes already produced by the same stream,
unloaded compressed input and input overwritten before consumption. Ambiguous
candidates are retained separately, excluded from normal builds and counts.
"""
from pathlib import Path
import argparse,concurrent.futures,hashlib,json,collections
from recover_common import unpack,SIGNATURE,is_core,has_foreign_decoder
from disasm import parse
from rebuild_stages import rebuild
from loader_contexts import load_contexts
ROOT=Path(__file__).resolve().parents[1]

def audit(folder):
    game=ROOT/folder;out=game/'decompiled/recovered-stages';file=out/'recovery.json';report=json.loads(file.read_text());result={'folder':folder}
    if (game/'decompiled/reconstruction.json').exists():result['status']='curated_preserved';return result
    if has_foreign_decoder(report):
        result['status']='foreign_decoder_preserved';result['note']='Use the decoder-family audit; the common depacker audit does not apply.';return result
    stages=report['stages'];original=(game/'original.xex').read_bytes();confirmed=set();issues={};seen=set()
    targets={(s['depacker_address'],s['compressed_source']) for s in stages}
    for index,ram,loaded,owners,copy_proofs in load_contexts(original):
        fingerprint=hashlib.sha256(ram).digest()
        for core,source in targets:
            key=(core,source,fingerprint)
            if key in seen or source not in loaded or not is_core(ram,core):continue
            seen.add(key)
            try:
                image,spans,literals,steps=unpack(ram,core,source,loaded)
                digest=hashlib.sha256(b''.join(image[lo:hi] for lo,hi in spans)).hexdigest()
                for stage in stages:
                    if (core,source)==(stage['depacker_address'],stage['compressed_source']) and spans==stage['spans'] and digest==stage['sha256']:
                        if stage.get('fixed_loader_copy_context',[])!=copy_proofs:continue
                        indexes={addr:i for i,addr in enumerate(addr for lo,hi in spans for addr in range(lo,hi))}
                        patches=[]
                        for src,dst in literals:
                            if src not in owners or original[owners[src]]!=image[dst]:raise ValueError('Literal input has no original-byte provenance')
                            patches.append([owners[src],indexes[dst]])
                        if patches!=stage['literal_patches']:raise ValueError('Literal provenance differs from saved stage')
                        confirmed.add(stage['source'])
            except Exception as e:issues.setdefault((core,source),set()).add(str(e))
    valid=[];excluded=[];quarantine=out/'needs-loader-context'
    for stage in stages:
        if stage['source'] in confirmed:
            stage['independent_compressed_stream_verified']=True;valid.append(stage)
        else:
            quarantine.mkdir(exist_ok=True);stage['exclusion_reason']=sorted(issues.get((stage['depacker_address'],stage['compressed_source']),{'No independently reproducible load stage'}));excluded.append(stage)
            for name in (stage['source'],stage['binary']):
                path=out/name
                if path.exists():path.replace(quarantine/name)
    report['stages']=valid
    if excluded:
        report.setdefault('excluded_candidates',[]).extend(excluded)
        (quarantine/'README.txt').write_text('Unverified automatic candidates. These images depend on missing loader state or an invalid stream selection. They are excluded from the normal build and verified-source counts. The original executable is unchanged.\n')
    report['status']='stages_recovered_and_mads_verified' if valid else 'recognized_loader_needs_manual_recovery'
    report['independent_stream_audit']={'verified_stages':len(valid),'excluded_candidates':len(report.get('excluded_candidates',[]))}
    file.write_text(json.dumps(report,indent=2)+'\n')
    if valid:
        (out/'build.sh').write_text('#!/bin/sh\nset -eu\ncd "$(dirname "$0")"\n'+''.join(f'mads {s["source"]} -o:{s["binary"]}\n' for s in valid)+'python3 ../../../../tools/rebuild_stages.py .\n')
        rebuild(out)
    else:
        for name in ('build.sh','rebuilt-packed.xex'):
            if (out/name).exists():(out/name).replace(quarantine/name)
    runtime=out/'verification/runtime-recovery.json'
    if runtime.exists():
        record=json.loads(runtime.read_text());record['code_bytes']=sum(s['code_bytes'] for s in valid);record['excluded_candidates']=len(excluded);runtime.write_text(json.dumps(record,indent=2)+'\n')
    result.update(status='independent_streams_verified' if valid else 'requires_loader_context',verified_stages=len(valid),excluded_candidates=len(excluded))
    return result

def main():
    p=argparse.ArgumentParser();p.add_argument('--jobs',type=int,default=8);args=p.parse_args();folders=[str(p.parent.parent.parent.relative_to(ROOT)) for p in (ROOT/'games').glob('*/decompiled/recovered-stages/recovery.json')];results=[]
    with concurrent.futures.ProcessPoolExecutor(max_workers=args.jobs) as pool:
        for result in pool.map(audit,folders):
            results.append(result)
            if len(results)%100==0:print(f'{len(results)}/{len(folders)} stage contexts audited; {sum(r.get("excluded_candidates",0) for r in results)} candidates excluded',flush=True)
    summary={'games':len(results),'verified_stages':sum(r.get('verified_stages',0) for r in results),'excluded_candidates':sum(r.get('excluded_candidates',0) for r in results),'statuses':dict(collections.Counter(r['status'] for r in results))}
    (ROOT/'recovery-audit.json').write_text(json.dumps({'summary':summary,'results':results},indent=2)+'\n');print(json.dumps(summary,indent=2))
if __name__=='__main__':main()
