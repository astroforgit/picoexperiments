#!/usr/bin/env python3
"""Add observed instructions to original archive bytes; never recover unpacked code.

Existing game.asm/build.sh and recovery projects are never modified. A runtime
address is admitted only when all three captured bytes identify exactly one
original XEX segment. New instructions never displace static instruction ranges.
"""
from pathlib import Path
import argparse,collections,concurrent.futures,hashlib,json,os,shutil,subprocess,tempfile,time
from disasm import parse,analyse,instruction,dta
from opcodes import OPS,SIZE
from test_recovered import machine_for
ROOT=Path(__file__).resolve().parents[1]


def eligibility(game,excluded):
    if game.name in excluded:return 'excluded_inventory'
    if (game/'decompiled/reconstruction.json').exists():return 'curated_preserved'
    report=game/'decompiled/recovered-stages/recovery.json'
    if report.exists() and json.loads(report.read_text()).get('stages'):return 'verified_recovery_preserved'
    return None


def read_pcmap(raw):
    if len(raw)%5:raise ValueError('Malformed runtime PC map')
    return {int.from_bytes(raw[i:i+2],'little'):raw[i+2:i+5] for i in range(0,len(raw),5)}


def merge_runtime(parts,static,observed):
    """Return conservative merged original-file-offset instruction map + evidence."""
    segments=[p for p in parts if p['kind']=='segment'];proposed={};reject=collections.defaultdict(list);unique=0
    for address,seen_bytes in observed.items():
        covering=[p for p in segments if p['address']<=address and address+3<=p['address']+len(p['data'])]
        matches=[p for p in covering if p['data'][address-p['address']:address-p['address']+3]==seen_bytes]
        if not covering:reject['outside_complete_original_segment'].append(address);continue
        if not matches:reject['bytes_differ_from_original'].append(address);continue
        if len(matches)!=1:reject['ambiguous_original_overlay'].append(address);continue
        unique+=1
        if seen_bytes[0] not in OPS:reject['undocumented_opcode'].append(address);continue
        p=matches[0];off=p['offset']+4+address-p['address'];n=SIZE[OPS[seen_bytes[0]][1]]
        proposed[off]=(address,n)
    static_bytes={off+k:off for off,(_,n) in static.items() for k in range(n)};admitted={}
    for off,item in proposed.items():
        address,n=item
        if off in static and static[off]==item:admitted[off]=item;continue
        if any(off+k in static_bytes for k in range(n)):
            reject['conflicts_with_static_instruction'].append(address);continue
        admitted[off]=item
    occupied={};conflicts=set()
    for off,(_,n) in admitted.items():
        for k in range(n):
            if off+k in occupied:conflicts.update((off,occupied[off+k]))
            occupied[off+k]=off
    for off in conflicts:
        reject['conflicting_runtime_instruction_boundaries'].append(admitted[off][0]);del admitted[off]
    added={off:item for off,item in admitted.items() if off not in static};merged=dict(static);merged.update(added)
    evidence={'observed_execution_addresses':len(observed),'unique_three_byte_matches':unique,
              'admitted_runtime_instructions':len(admitted),'added_runtime_instructions':len(added),
              'added_code_bytes':sum(n for _,n in added.values()),'admitted_runtime_file_offsets':sorted(admitted),
              'unmatched_execution_addresses':{reason:sorted(addresses) for reason,addresses in sorted(reject.items())}}
    return merged,admitted,evidence


def emit(parts,code,runtime,title):
    lines=['; '+title.replace('\n',' '),'; Runtime-enhanced ORIGINAL FILE disassembly; partial code discovery only.',
           '; Observed instructions require a unique segment/address/three-byte match.',
           '; Unmatched relocated/decompressed execution is NOT recovered here.',
           '; Existing static instruction ranges remain unchanged; unidentified bytes stay DTA.',
           '    opt h-','    org $0000'];segments=[]
    for idx,p in enumerate(parts):
        b=p['data'];offset=p['offset']
        if p['kind']!='segment':
            lines.extend([f'; {p["kind"]} at file offset ${offset:06X}','    org $0000'])
            for i in range(0,len(b),16):
                if i and i%32768==0:lines.append('    org $0000')
                lines.append(dta(b[i:i+16]))
            continue
        a=p['address'];end=a+len(b)-1
        lines.extend(['',f'; Segment {idx}: ${a:04X}-${end:04X}; file offset ${offset:06X}',
                      '    org $0000',f'    dta a(${a:04X}),a(${end:04X})',f'    org ${a:04X}'])
        i=0;count=0
        while i<len(b):
            off=offset+4+i;at=a+i
            if off in code:
                address,n=code[off];assert address==at and i+n<=len(b)
                tag='observed original bytes' if off in runtime else 'static control flow'
                lines.append(f'S{idx:03d}_{at:04X}: {instruction(b[i:i+n],at):24s} ; {tag}')
                i+=n;count+=n
            else:
                n=1
                while n<16 and i+n<len(b) and off+n not in code:n+=1
                lines.append(dta(b[i:i+n])+f' ; ${at:04X} unidentified data/code');i+=n
        segments.append({'index':idx,'start':a,'end':end,'file_offset':offset,'bytes':len(b),'code_bytes':count})
    return '\n'.join(lines)+'\n',segments


def process(job):
    rec,root,runner,excluded,min_added=job;game=Path(root)/rec['folder'];out=game/'decompiled';result={'folder':rec['folder']}
    why=eligibility(game,excluded)
    if why:result['status']=why;return result
    try:
        original=(game/'original.xex').read_bytes();parts,warning=parse(original);static,entries,stops,conflicts=analyse(parts)
        machine=machine_for(rec['folder'])
        with tempfile.TemporaryDirectory(prefix='archive-runtime-') as tmp:
            tmp=Path(tmp);config=tmp/'config';config.write_text('Atari 800 Emulator configuration file\n');prefix=tmp/'archive-runtime'
            proc=subprocess.run([runner,str(game/'original.xex'),str(prefix),str(config),'pal'],capture_output=True,text=True,timeout=60,env={**os.environ,'ATARI800_TEST_MACHINE':machine})
            if proc.returncode:raise ValueError('Trace runner failed: '+proc.stderr[-1000:])
            baseline=json.loads(prefix.with_suffix('.json').read_text());observed=read_pcmap(prefix.with_suffix('.pcmap').read_bytes())
            code,runtime,evidence=merge_runtime(parts,static,observed)
            result.update(machine=machine,baseline=baseline,static_code_bytes=sum(n for _,n in static.values()),
                          added_code_bytes=evidence['added_code_bytes'],added_instructions=evidence['added_runtime_instructions'],
                          unique_three_byte_matches=evidence['unique_three_byte_matches'],observed_execution_addresses=len(observed))
            if evidence['added_code_bytes']<min_added:
                result['status']='insufficient_new_original_code';return result
            assembly,segments=emit(parts,code,runtime,rec['title']);source=tmp/'runtime-archive.asm';source.write_text(assembly);binary=tmp/'runtime-archive.xex'
            proc=subprocess.run([os.environ.get('MADS','mads'),str(source),'-o:'+str(binary)],capture_output=True,text=True,timeout=45)
            if proc.returncode:raise ValueError('MADS failed: '+proc.stdout[-1500:]+proc.stderr[-500:])
            if binary.read_bytes()!=original:raise ValueError('MADS archive rebuild differs from original')
            report={'status':'runtime_enhanced_original_archive_verified','original_sha256':hashlib.sha256(original).hexdigest(),
                    'source':'runtime-archive.asm','output':'runtime-archive.xex','build_script':'build-runtime-archive.sh',
                    'source_bytes':len(original),'static_code_bytes':result['static_code_bytes'],'merged_code_bytes':sum(n for _,n in code.values()),
                    'merged_instructions':len(code),'byte_exact_rebuild':True,'parse_warning':warning,'static_conflicts_discarded':conflicts,
                    'entry_points':entries,'static_unresolved_flow':stops,'segments':segments,'runtime_evidence':evidence,
                    'baseline':baseline,'machine':machine,'tv':'pal','baseline_quiet':baseline.get('screen_changes_after_400',0)<10,
                    'baseline_has_errors':bool(baseline.get('errors_after_boot')),
                    'limitations':['Original file bytes only; this is not decompression or relocated-memory recovery.',
                                   'Only unique address/three-byte segment matches are admitted; ambiguous overlays are rejected.',
                                   'Last observed bytes per PC in a scripted 1200-frame PAL trace; self-modification and unvisited paths remain incomplete.',
                                   'Partial code discovery, without semantic annotation or a full-playability claim.',
                                   'No physical-hardware or audible sound validation.']}
            if 'vbxe' in rec['folder']:report['limitations'].append('VBXE hardware is not emulated by this core.')
            why=eligibility(game,excluded)
            if why:result['status']=why;return result
            # Publish only new dedicated files, never the original project sources.
            out.mkdir(exist_ok=True);verification=out/'verification';verification.mkdir(exist_ok=True)
            shutil.copy2(source,out/'runtime-archive.asm')
            (out/'runtime-archive.json').write_text(json.dumps(report,indent=2)+'\n')
            build=out/'build-runtime-archive.sh';build.write_text('#!/bin/sh\nset -eu\ncd "$(dirname "$0")"\n"${MADS:-mads}" runtime-archive.asm -o:runtime-archive.xex\ncmp runtime-archive.xex ../original.xex\necho "PASS: original archive rebuilt byte for byte; runtime mapping is partial."\n');build.chmod(0o755)
            for suffix in ('.json','.pcmap'):shutil.copy2(prefix.with_suffix(suffix),verification/('archive-runtime'+suffix))
            from PIL import Image
            Image.open(prefix.with_suffix('.ppm')).save(verification/'archive-runtime.png')
            result.update(status=report['status'],merged_code_bytes=report['merged_code_bytes'],source_sha256=hashlib.sha256(assembly.encode()).hexdigest())
    except Exception as exc:result.update(status='needs_review',error=str(exc))
    return result


def summary(results):
    good=[r for r in results if r['status']=='runtime_enhanced_original_archive_verified']
    return {'processed':len(results),'enhanced_projects':len(good),'added_code_bytes':sum(r['added_code_bytes'] for r in good),
            'added_instructions':sum(r['added_instructions'] for r in good),'statuses':dict(collections.Counter(r['status'] for r in results)),
            'enhanced_baseline_errors':sum(bool(r['baseline'].get('errors_after_boot')) for r in good),
            'enhanced_baseline_quiet':sum(r['baseline'].get('screen_changes_after_400',0)<10 for r in good)}


def main():
    p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--runner',type=Path,required=True)
    p.add_argument('--notes',type=Path,required=True);p.add_argument('--exclude-inventory',type=Path,action='append',default=[])
    p.add_argument('--report',type=Path,required=True);p.add_argument('--jobs',type=int,default=4);p.add_argument('--limit',type=int)
    p.add_argument('--min-added',type=int,default=64);p.add_argument('--resume',action='store_true');a=p.parse_args()
    excluded={r['slug'] for path in a.exclude_inventory for r in json.loads(path.read_text())}
    priority={r['slug']:i for i,r in enumerate(json.loads(a.notes.read_text())['high_code_candidates'])}
    games=json.loads((a.root/'manifest.json').read_text())['games'];games=[r for r in games if eligibility(a.root/r['folder'],excluded) is None]
    games.sort(key=lambda r:(priority.get(r['folder'].split('/')[-1],100000),r['folder']))
    results=json.loads(a.report.read_text())['results'] if a.resume and a.report.exists() else [];done={r['folder'] for r in results}
    jobs=[r for r in games if r['folder'] not in done]
    if a.limit is not None:jobs=jobs[:a.limit]
    start=time.time();a.report.parent.mkdir(parents=True,exist_ok=True)
    def save():
        data={'eligible_at_start':len(games),'excluded_inventory_count':len(excluded),'minimum_added_bytes':a.min_added,'summary':summary(results),'results':results}
        temp=a.report.with_suffix('.tmp');temp.write_text(json.dumps(data,indent=2)+'\n');temp.replace(a.report)
    print(json.dumps({'eligible':len(games),'scheduled':len(jobs),'already_processed':len(results)}),flush=True)
    with concurrent.futures.ProcessPoolExecutor(max_workers=a.jobs) as pool:
        for result in pool.map(process,[(r,str(a.root.resolve()),str(a.runner.resolve()),excluded,a.min_added) for r in jobs]):
            results.append(result)
            if len(results)%20==0 or result['status']=='needs_review':save();print(json.dumps({'processed':len(results),'enhanced':summary(results)['enhanced_projects'],'latest':result['folder'],'status':result['status'],'elapsed_seconds':round(time.time()-start,1)}),flush=True)
    save();print(json.dumps(summary(results)),flush=True)


if __name__=='__main__':main()
