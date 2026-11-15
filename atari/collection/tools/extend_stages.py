#!/usr/bin/env python3
"""Add independently validated streams missed by older caller discovery.

Existing sources and metadata are preserved. Only new unique span/image hashes
are appended; every new image must assemble exactly and replay original literals.
"""
from pathlib import Path
import json,hashlib,subprocess,tempfile,shutil,concurrent.futures,argparse,collections,time,os
from recover_common import core_offsets,candidates,unpack,trace,word,has_foreign_decoder
from disasm import parse,instruction,dta
from rebuild_stages import reconstruct
from loader_contexts import load_contexts
ROOT=Path(__file__).resolve().parents[1]

def extend(rec):
    game=ROOT/rec['folder'];out=game/'decompiled/recovered-stages';result={'folder':rec['folder'],'added':[],'errors':[]}
    if (game/'decompiled/reconstruction.json').exists():result['status']='curated_preserved';return result
    existing=out/'recovery.json'
    if existing.exists() and has_foreign_decoder(json.loads(existing.read_text())):
        result['status']='foreign_decoder_preserved';return result
    raw=(game/'original.xex').read_bytes()
    if next(core_offsets(raw),None) is None:result['status']='no_recognized_core';return result
    report_path=out/'recovery.json';report=json.loads(report_path.read_text()) if report_path.exists() else {'folder':rec['folder'],'title':rec['title'],'stages':[],'limitations':['Automatic independent stream recovery; partial code discovery and no semantic annotation.']}
    known={(tuple(map(tuple,s['spans'])),s['sha256']) for s in report['stages']};known_pairs={(s['depacker_address'],s['compressed_source']) for s in report['stages']}
    seen=set();pending=[]
    for index,ram,loaded,owners,copy_proofs in load_contexts(raw):
        fingerprint=hashlib.sha256(ram).digest()
        for core in core_offsets(ram):
            if core<0x200:continue
            for source,calls in candidates(ram,loaded,core):
                key=(core,source,fingerprint)
                if key in seen:continue
                seen.add(key)
                # Replaying known pointer pairs is intentional: one input address
                # can hold different streams at successive INIT stages.
                try:
                    image,spans,literals,steps=unpack(ram,core,source,loaded)
                    expected=b''.join(image[lo:hi] for lo,hi in spans);digest=hashlib.sha256(expected).hexdigest();identity=(tuple(map(tuple,spans)),digest)
                    if identity in known:continue
                    indexes={addr:i for i,addr in enumerate(addr for lo,hi in spans for addr in range(lo,hi))}
                    patches=[]
                    for src,dst in literals:
                        if src not in owners or raw[owners[src]]!=image[dst]:raise ValueError('Literal input is not original loaded data')
                        patches.append([owners[src],indexes[dst]])
                    seeds=[]
                    for call in calls:
                        if ram[call]!=0x20:continue
                        pc=call+3
                        if pc+2 in loaded and ram[pc] in (0x20,0x4c):
                            target=word(ram,pc+1)
                            if any(lo<=target<hi for lo,hi in spans):seeds.append(target)
                    code,conflicts=trace(image,spans,seeds);lines=[f'; {rec["title"]}: additional independently recovered stream','; Address labels only; unclassified bytes remain DTA.','    opt h-']
                    for lo,hi in spans:
                        lines.append(f'    org ${lo:04X}');at=lo
                        while at<hi:
                            if at in code:n=code[at];lines.append(f'L{at:04X}: '+instruction(image[at:at+n],at))
                            else:
                                n=1
                                while n<16 and at+n<hi and at+n not in code:n+=1
                                lines.append(dta(image[at:at+n])+f' ; ${at:04X}')
                            at+=n
                    stage={'depacker_address':core,'compressed_source':source,'load_context_part':index,'spans':spans,'bytes':len(expected),'sha256':digest,'code_bytes':sum(code.values()),'instructions':len(code),'entry_seeds':seeds,'overlapping_decodes_discarded':conflicts,'depacker_steps':steps,'literal_patches':patches,'mads_byte_exact':True,'independent_compressed_stream_verified':True,'destination_initialized_from_stream':True,'strict_decoder_body_verified':True}
                    if copy_proofs:stage['fixed_loader_copy_context']=copy_proofs
                    pending.append((stage,'\n'.join(lines)+'\n',expected));known.add(identity)
                except Exception as e:result['errors'].append({'core':core,'source':source,'load_context_part':index,'error':str(e)})
    if not pending:result['status']='no_new_images';return result
    original_hash=hashlib.sha256(raw).hexdigest()
    if report.get('original_sha256',original_hash)!=original_hash:
        raise ValueError('Original input hash changed')
    with tempfile.TemporaryDirectory(prefix='atari-extra-stages-') as tmp:
        tmp=Path(tmp);nextnum=1;prepared=[];images={};missing_existing=[]
        reserved={s[field] for s in report['stages'] for field in ('source','binary')}
        for stage,assembly,expected in pending:
            while (f'extension-{nextnum:02d}.asm' in reserved
                   or f'extension-{nextnum:02d}.bin' in reserved
                   or (out/f'extension-{nextnum:02d}.asm').exists()
                   or (out/f'extension-{nextnum:02d}.bin').exists()):nextnum+=1
            name=f'extension-{nextnum:02d}';nextnum+=1;stage.update(source=name+'.asm',binary=name+'.bin')
            (tmp/stage['source']).write_text(assembly)
            p=subprocess.run([os.environ.get('MADS','mads'),stage['source'],'-o:'+stage['binary']],cwd=tmp,capture_output=True,text=True,timeout=30)
            if p.returncode or (tmp/stage['binary']).read_bytes()!=expected:raise ValueError('MADS verification failed: '+p.stdout[-1000:])
            prepared.append(stage);images[stage['binary']]=tmp/stage['binary']
        # Source-only projects may have no existing .bin files. Assemble those
        # into temporary storage without changing their source or published files.
        for stage in report['stages']:
            binary=out/stage['binary']
            if not binary.exists():
                binary=tmp/stage['binary']
                p=subprocess.run([os.environ.get('MADS','mads'),str((out/stage['source']).resolve()),'-o:'+str(binary)],cwd=out,capture_output=True,text=True,timeout=30)
                if p.returncode or not binary.exists():raise ValueError('Existing-stage MADS verification failed: '+p.stdout[-1000:])
                missing_existing.append(stage['binary'])
            images[stage['binary']]=binary
        combined=dict(report)
        combined.update(stages=report['stages']+prepared,status='stages_recovered_and_mads_verified',original_sha256=original_hash)
        if any(s.get('fixed_loader_copy_context') for s in combined['stages']):
            note='Fixed loader-copy contexts preserve original file-byte provenance only. Unknown copied bytes remain unavailable; prior decompressed outputs, OS/ROM state and complete loader execution are not modeled.'
            combined['limitations']=list(dict.fromkeys(report.get('limitations',[])+[note]))
        packed=reconstruct(combined,raw,lambda name:images[name].read_bytes())
        build='#!/bin/sh\nset -eu\ncd "$(dirname "$0")"\n'+''.join('"${MADS:-mads}" '+stage['source']+' -o:'+stage['binary']+'\n' for stage in combined['stages'])+'python3 ../../../../tools/rebuild_stages.py .\n'
        report_text=json.dumps(combined,indent=2)+'\n'
        # This second check prevents publication when curation began while the
        # potentially expensive stream/MADS preparation was running.
        if (game/'decompiled/reconstruction.json').exists():
            result['status']='curated_preserved';return result
        out.mkdir(exist_ok=True)
        for stage in prepared:
            for name in (stage['source'],stage['binary']):shutil.copy2(tmp/name,out/name)
        for name in missing_existing:shutil.copy2(images[name],out/name)
        def publish(name,data,mode=None):
            # Create the replacement beside its destination: os.replace remains
            # atomic even when the preparation directory is on another filesystem.
            if mode is None:mode=(out/name).stat().st_mode&0o777 if (out/name).exists() else 0o644
            with tempfile.NamedTemporaryFile(prefix='.'+name+'-',dir=out,delete=False) as f:
                replacement=Path(f.name)
                try:
                    f.write(data);f.flush()
                    if mode is not None:os.fchmod(f.fileno(),mode)
                except BaseException:
                    replacement.unlink(missing_ok=True);raise
            try:os.replace(replacement,out/name)
            finally:replacement.unlink(missing_ok=True)
        build_mode=(out/'build.sh').stat().st_mode&0o777 if (out/'build.sh').exists() else 0o755
        publish('rebuilt-packed.xex',packed)
        publish('build.sh',build.encode(),build_mode)
        # Commit the combined manifest last, after every referenced file and its
        # build recipe exists. Preflight failures have published nothing.
        publish('recovery.json',report_text.encode())
        result['added']=[{k:v for k,v in stage.items() if k!='literal_patches'} for stage in prepared]
    result['status']='new_images_mads_and_packed_verified';return result

def main():
    p=argparse.ArgumentParser();p.add_argument('--jobs',type=int,default=4);p.add_argument('--game');p.add_argument('--exclude',nargs='*',default=[]);a=p.parse_args()
    games=json.loads((ROOT/'manifest.json').read_text())['games'];games=[g for g in games if g['folder'].split('/')[-1] not in a.exclude]
    if a.game:games=[g for g in games if g['folder']=='games/'+a.game]
    results=[];start=time.time()
    with concurrent.futures.ProcessPoolExecutor(max_workers=a.jobs) as pool:
        for result in pool.map(extend,games):
            results.append(result)
            if result['added']:print(result['folder'],'added',len(result['added']),flush=True)
            if len(results)%100==0:print(len(results),'/',len(games),'examined',flush=True)
    summary={'examined':len(results),'extended_projects':sum(bool(x['added']) for x in results),'new_images':sum(len(x['added']) for x in results),'elapsed_seconds':round(time.time()-start,1),'statuses':dict(collections.Counter(x['status'] for x in results))}
    dest=ROOT/('recovery-extension-'+a.game+'.json' if a.game else 'recovery-extensions.json');dest.write_text(json.dumps({'summary':summary,'games':results},indent=2)+'\n');print(summary,flush=True)
if __name__=='__main__':main()
