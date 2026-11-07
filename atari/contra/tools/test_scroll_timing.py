"""Measure actual presentation gaps during a scripted rightward scrolling run.

Accepts an explicit snapshot/label pair to measure archived builds without
patching their code. Reports model timings; no claim of exact VBXE bus timing.
"""
from pathlib import Path
import argparse,pickle,json,hashlib
import numpy as np
from build import labels

def main():
 p=argparse.ArgumentParser();p.add_argument('snapshot',type=Path);p.add_argument('--labels',type=Path,default=Path('gen/runtime.lab'));p.add_argument('--output',type=Path,default=Path('gen/scroll-timing.json'));p.add_argument('--frames',type=int,default=180);args=p.parse_args()
 L=labels(args.labels);a=pickle.load(args.snapshot.open('rb'))
 events=[];ticks=0;last_tick=a.mem.ram[0x1a];last_flip=len(a.xdl_addr_log);start=a.frame
 for f in range(args.frames):
  a.set_input(stick=7,trig=1,stick1=7,trig1=1,shift=f%60<12);a.run_frames(1)
  tick=a.mem.ram[0x1a];ticks+=(tick-last_tick)&255;last_tick=tick
  if len(a.xdl_addr_log)!=last_flip:
   events.append({'frame':a.frame-start,'scroll_x':a.mem.ram[L['C_X']],'scroll_y':a.mem.ram[L['C_Y']]});last_flip=len(a.xdl_addr_log)
 gaps=np.diff([0]+[e['frame'] for e in events]+[args.frames]).tolist()
 report={'sha256':hashlib.sha256(a.xex).hexdigest(),'video_frames':args.frames,'pictures':len(events),'game_ticks':ticks,'max_gap_video_frames':max(gaps),'mean_gap_video_frames':float(np.mean(gaps)),'presentation_events':events}
 assert len(events)>0
 assert len({e['scroll_x'] for e in events})>4,'test did not exercise scrolling'
 args.output.write_text(json.dumps(report,indent=2)+'\n');print({k:v for k,v in report.items() if k!='presentation_events'},flush=True)
if __name__=='__main__':main()
