#!/usr/bin/env python3
"""Independently execute each full remix SAP and compare every POKEY frame."""
import argparse
import json
import build_remixes as b

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--library',required=True)
    args=p.parse_args();lib=b.api(args.library)
    tracks=json.loads((b.ROOT/'remixes/catalog.json').read_text())['tracks']
    total=0
    for i,t in enumerate(tracks):
        folder=b.ROOT/t['directory']
        expected=(folder/'remix-registers.bin').read_bytes()
        frames=b.capture(lib,folder/'remix.sap',t['frames']+1)
        actual=b''.join(frames[:-1])
        if actual!=expected:
            mismatch=next(j for j in range(min(len(actual),len(expected))) if actual[j]!=expected[j])
            raise ValueError(f'{t["id"]}: POKEY mismatch at frame {mismatch//9}')
        if frames[-1]!=expected[:9]:raise ValueError(t['id']+': end-to-start transition differs')
        total+=t['frames']
        if (i+1)%10==0 or i+1==len(tracks):print(f'{i+1}/{len(tracks)} full remixes verified; {total} PAL frames',flush=True)
    report=dict(tracks=len(tracks),frames=total,failures=0,checks=['Every full remix SAP frame matches authored POKEY data','All final-to-first loop transitions match'],engine='ASAP')
    (b.ROOT/'remixes/full-validation.json').write_text(json.dumps(report,indent=2)+'\n')

if __name__=='__main__':main()
