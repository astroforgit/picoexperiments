"""Original XEX contexts plus three explicitly validated fixed loader copies.

No arbitrary loader instructions are executed. Copied bytes retain their original
file offsets; unknown source bytes remain unavailable to guarded stream replay.
The derived view models copies only, not prior decompressed outputs, OS services,
ROM contents or a complete execution history.
"""
from disasm import parse

FIXED_COPIES=(
 dict(kind='colony7-input-pages-v1',entry=0x1f3b,source=0x2000,destination=0x0700,length=0x1800,direction='ascending',
      bodies=((0x1f3b,bytes.fromhex('20 9a 1f a0 17 bd 00 20 9d 00 07 e8 d0 f7 ee 42 1f ee 45 1f 88 10 ee')),
              (0x1f9a,bytes.fromhex('a2 00 8e 2f 02 a5 14 c5 14 f0 fc 60'))),
      modified=((0x1f42,0x38),(0x1f45,0x1f),(0x022f,0))),
 dict(kind='runfast-code-copy-v1',entry=0x216c,source=0x20eb,destination=0x0400,length=129,direction='descending',
      bodies=((0x216c,bytes.fromhex('a2 80 bd eb 20 9d 00 04 ca 10 f7 4c 5a 04')),),modified=()),
 dict(kind='rgb-code-copy-v1',entry=0x2000,source=0x205a,destination=0xbf02,length=118,direction='descending',
      bodies=((0x2000,bytes.fromhex('a2 00 8e 2f 02 8e c8 02 8e c6 02 8e c5 02 a5 14 c5 14 f0 fc ca 8e 01 d3 a2 75 bd 5a 20 9d 02 bf ca 10 f7 a2 d0 a0 20 20 02 bf')),),
      modified=((0x022f,0),(0x02c8,0),(0x02c6,0),(0x02c5,0),(0xd301,255))),
)

def apply_fixed_init(ram,loaded,owners,original,part_index):
    if 0x2e2 not in loaded or 0x2e3 not in loaded:return None
    entry=ram[0x2e2]|ram[0x2e3]<<8
    for spec in FIXED_COPIES:
        if entry!=spec['entry']:continue
        if any(bytes(ram[a:a+len(body)])!=body or any(k not in loaded for k in range(a,a+len(body))) for a,body in spec['bodies']):continue
        source,dest,length=(spec[k] for k in ('source','destination','length'))
        assert source+length<=65536 and dest+length<=65536
        assert source+length<=dest or dest+length<=source  # no overlap semantics inferred
        known=0
        for offset in range(length):
            src=source+offset;dst=dest+offset;owner=owners.get(src)
            if src in loaded and owner is not None and 0<=owner<len(original) and original[owner]==ram[src]:
                ram[dst]=ram[src];loaded.add(dst);owners[dst]=owner;known+=1
            else:
                # Placeholder has no provenance and cannot become compressed input.
                ram[dst]=0;loaded.discard(dst);owners.pop(dst,None)
        for address,value in spec['modified']:
            ram[address]=value;loaded.discard(address);owners.pop(address,None)
        return dict({k:spec[k] for k in ('kind','entry','source','destination','length','direction')},load_context_part=part_index,known_original_bytes=known,unknown_bytes=length-known)
    return None

def load_contexts(original):
    """Yield (part, ram, original-backed addresses, owners, copy proofs).

    Both raw and derived contexts are candidates. Yielded memory must not be
    mutated by the caller. Derived copies persist across later file segments;
    decoder outputs are deliberately not applied to subsequent contexts.
    """
    parts,_=parse(original);ram=bytearray(65536);loaded=set();owners={}
    copied=bytearray(65536);copy_loaded=set();copy_owners={};proofs=[]
    for index,part in enumerate(parts):
        if part['kind']!='segment':continue
        a=part['address'];b=part['data'];addresses=range(a,a+len(b));mapping={a+i:part['offset']+4+i for i in range(len(b))}
        for memory,valid,provenance in ((ram,loaded,owners),(copied,copy_loaded,copy_owners)):
            memory[a:a+len(b)]=b;valid.update(addresses);provenance.update(mapping)
        if not (a<=0x2e3<a+len(b) or part is parts[-1]):continue
        yield index,ram,loaded,owners,[]
        proof=apply_fixed_init(copied,copy_loaded,copy_owners,original,index)
        if proof:proofs.append(proof)
        if proofs:yield index,copied,copy_loaded,copy_owners,list(proofs)
