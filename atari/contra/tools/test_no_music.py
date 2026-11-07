"""Prove music requests stay silent, effects remain, and scroll is sampled late."""
import json
from test_runtime import initialized,sample_now,L,R
from build import labels
N=labels(R/'gen/nes.lab')
a=initialized()
MUSIC=[*range(0x26,0x52),0x54,0x57,0x58,0x59]
for code in MUSIC:
 a.cpu.a=code;a.call(N['PLAY_SOUND'])
 assert not any(a.mem.ram[N['SOUND_CODE']:N['SOUND_CODE']+6]),hex(code)
a.cpu.a=0x0a;a.call(N['PLAY_SOUND'])
assert any(a.mem.ram[N['SOUND_CODE']+4:N['SOUND_CODE']+6]),'shooting effect was suppressed'
# Simulate a game update occurring while compose handles dirty tiles.
a=initialized();a.mem.ram[L['LAT_X']]=12;a.mem.ram[L['ANY_DIRTY']]=1
a.mem.ram[L['DIRTY']:L['DIRTY']+256]=bytes(256)
a.mem.ram[L['ROWDIRTY']:L['ROWDIRTY']+64]=bytes(64)
step=a.cpu.step;seen=[]
def inject():
 if a.cpu.pc==L['EMIT_TILES']:
  a.mem.ram[L['LAT_X']]=99;a.mem.ram[0x200]=17;seen.append(1)
 step()
a.cpu.step=inject;sample_now(a);a.call(L['COMPOSE']);a.cpu.step=step
assert seen and a.mem.ram[L['C_X']]==99 and a.mem.ram[0x800]==17,(seen,a.mem.ram[L['C_X']],a.mem.ram[0x800],a.mem.ram[L['ANY_DIRTY']])
# Force one update halfway through OAM copying. The snapshot must retry.
a=initialized();step=a.cpu.step;changed=[]
def interrupt_copy():
 if a.cpu.pc==L['CO_OAM'] and a.cpu.x==16 and not changed:
  a.mem.ram[0x200:0x300]=bytes([17])*256
  a.mem.ram[0x1a]=(a.mem.ram[0x1a]+1)&255
  a.mem.ram[L['LAT_X']]=123;changed.append(1)
 step()
a.cpu.step=interrupt_copy;a.call(L['SNAPSHOT_FRAME']);a.cpu.step=step
assert changed and a.mem.ram[0x800:0x900]==bytes([17])*256
assert a.mem.ram[L['C_X']]==123
# Idle channels are cheap, but a timer strobe must still start an effect.
a=initialized();a.mem.ram[0x0a15]=15
for channel in range(4):
 a.cpu.x=channel;a.call(L['EFFECT_ACTIVE']);assert not a.cpu.p&1
 a.mem.ram[L['S_TRIGGER']+channel]=1
 a.cpu.x=channel;a.call(L['EFFECT_ACTIVE']);assert a.cpu.p&1
 a.mem.ram[L['S_TRIGGER']+channel]=0
# A completed frame that is due must flip at VBI even if the previous game
# NMI is busy. DLI, an unfinished blit and a frame not yet due (pacing:
# shown PACE game ticks after its sample) must never trigger this path.
for dli,busy,due,expected in [(False,False,True,True),(True,False,True,False),(False,True,True,False),(False,False,False,False)]:
 a=initialized();a.mem.ram[L['IN_VBI']]=1;a.mem.ram[L['PENDING']]=1
 a.mem.ram[0x1a]=(a.mem.ram[L['SNAPSHOT_TICK']]+(a.mem.ram[L['PACE']]-1 if due else 0))&255
 a.mem.ram[L['SNAP_VFRAME']]=a.mem.ram[L['VFRAME']]
 a.mem.ram[L['SNAP_DIRTY']]=1;back=a.mem.ram[L['BACK']]
 zp=bytes(a.mem.ram[L['ZP']:L['ZP']+8]);windows=(a.mems,a.memb)
 a.blit_busy_until=a.cpu.processorCycles+(100000 if busy else 0)
 a.nmist=0x80 if dli else 0x40;a.cpu.pc=0x3456;a.cpu.nmi()
 for _ in range(10000):
  if a.cpu.pc==0x3456:break
  a.cpu.step()
 else:raise AssertionError('nested NMI failed to return')
 assert a.mem.ram[L['PENDING']]==int(not expected)
 assert a.mem.ram[L['BACK']]==(back^int(expected))
 assert a.mem.ram[L['IN_VBI']]==1
 assert bytes(a.mem.ram[L['ZP']:L['ZP']+8])==zp
 assert (a.mems,a.memb)==windows
report={'suppressed_music_codes':len(MUSIC),'shooting_effect_retained':True,'scroll_and_oam_sampled_after_tile_work':True,'interrupted_snapshot_retries':True,'idle_audio_fast_path_preserves_triggers':True,'nested_vbi_flips_finished_frames_only':True}
(R/'gen/no-music-test.json').write_text(json.dumps(report,indent=2)+'\n');print('PASS',report)
