#!/usr/bin/env python3
"""Prove destination/register initialization before the first decoded byte.

Use the archived input segment identified by the first literal-token mapping.
Cross-segment or ambiguous cases fall back to the complete guarded stage audit.
"""
from pathlib import Path
import json,concurrent.futures,collections
from py65.devices.mpu6502 import MPU
from disasm import parse
from recover_common import SIGNATURE,word,has_foreign_decoder
from audit_recovered import audit
ROOT=Path(__file__).resolve().parents[1]

def check(folder):
    game=ROOT/folder;out=game/'decompiled/recovered-stages';report=json.loads((out/'recovery.json').read_text());data=(game/'original.xex').read_bytes();parts,_=parse(data)
    if (game/'decompiled/reconstruction.json').exists():return {'folder':folder,'status':'curated_preserved'}
    if has_foreign_decoder(report):return {'folder':folder,'status':'foreign_decoder_preserved'}
    checked=0
    for stage in report['stages']:
        try:
            core=stage['depacker_address'];source=stage['compressed_source'];first_offset,index=stage['literal_patches'][0]
            segment=next(p for p in parts if p['kind']=='segment' and p['offset']+4<=first_offset<p['offset']+4+len(p['data']))
            if not segment['address']<=source<segment['address']+len(segment['data']):raise ValueError('Prefix crosses load segments')
            code=next(p['data'][core-p['address']:core-p['address']+90] for p in parts if p['kind']=='segment' and p['address']<=core and core+90<=p['address']+len(p['data']) and p['data'][core-p['address']:core-p['address']+len(SIGNATURE)]==SIGNATURE)
            cpu=MPU();cpu.memory[segment['address']:segment['address']+len(segment['data'])]=segment['data'];cpu.memory[core:core+90]=code
            cpu.memory[core+79]=source&255;cpu.memory[core+80]=source>>8;cpu.pc=core+35;cpu.sp=0xfd;cpu.memory[0x1fe]=0xfe;cpu.memory[0x1ff]=2
            initialized=False;last_read=None
            for _ in range(1000):
                if not core<=cpu.pc<core+90:raise ValueError('Prefix escaped decoder')
                if cpu.pc==core+73:initialized=True
                if cpu.pc==core+78:last_read=word(cpu.memory,core+79)
                if cpu.pc==core+13:
                    dest=(word(cpu.memory,core+14)+cpu.y)&65535
                    offset=0;expected_dest=None
                    for lo,hi in stage['spans']:
                        if offset<=index<offset+hi-lo:expected_dest=lo+index-offset
                        offset+=hi-lo
                    if not initialized or dest!=expected_dest or last_read!=segment['address']+first_offset-segment['offset']-4 or cpu.a!=data[first_offset]:raise ValueError('First-byte context is not proved')
                    break
                cpu.step()
            else:raise ValueError('Prefix exceeded bound')
            stage['destination_initialized_from_stream']=True;checked+=1
        except Exception:
            result=audit(folder);result['prefix_check']='full_guarded_replay';return result
    (out/'recovery.json').write_text(json.dumps(report,indent=2)+'\n')
    return {'folder':folder,'status':'prefix_initialized','stages':checked}

if __name__=='__main__':
    folders=[str(p.parent.parent.parent.relative_to(ROOT)) for p in (ROOT/'games').glob('*/decompiled/recovered-stages/recovery.json')]
    with concurrent.futures.ProcessPoolExecutor(max_workers=8) as pool:results=list(pool.map(check,folders))
    report={'summary':dict(collections.Counter(r['status'] for r in results)),'results':results};(ROOT/'recovery-prefix-audit.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report['summary'],indent=2))
