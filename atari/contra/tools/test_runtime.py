"""Hardware-service tests against independently decoded NES patterns."""
from pathlib import Path
import numpy as np
from atari_emu import Atari
from build import labels
R=Path(__file__).resolve().parents[1];L=labels(R/'gen/runtime.lab')
def initialized(page=0xd6,pal=True):
 a=Atari(R/'contra.xex',pal=pal,vbxe_page=page);a.boot()
 for _ in range(2000000):
  if a.cpu.pc==L['NES_RESET']:return a
  a.cpu.step()
 raise AssertionError('runtime did not reach NES reset')
def sample_now(a):
 """Pictures are sampled every PACE game ticks: let the next compose sample one."""
 a.mem.ram[0x1a]=(a.mem.ram[L['SNAPSHOT_TICK']]+a.mem.ram[L['PACE']])&255
def decode(raw,tile):
 d=raw[tile*16:tile*16+16];return np.array([[(int(d[y])>>(7-x)&1)|((int(d[y+8])>>(7-x)&1)<<1) for x in range(8)] for y in range(8)],dtype=np.uint8)
def main():
 for page in [0xd6,0xd7]:
  a=initialized(page);raw=np.random.default_rng(32).integers(0,256,8192,dtype=np.uint8);a.vram[0x60000:0x62000]=raw
  for t in range(256):
   for sprite in [False,True]:
    a.cpu.x=t;a.cpu.a=1;a.cpu.y=L['MEMB_SOBJ' if sprite else 'MEMB_SBG'];a.call(L['EXPAND'])
    if sprite:
     tile=(t&1)*256+(t&254);expected=np.vstack([decode(raw,tile),decode(raw,tile+1)]);addr=0x78000+t*128
    else:expected=decode(raw,256+t);addr=0x1c000+t*64
    expected=np.where(expected==0,0,expected|252).astype(np.uint8).ravel()
    assert np.array_equal(a.vram[addr:addr+len(expected)],expected),(hex(page),t,sprite)
  # Every CHR upload must invalidate the correct 8x16 cache entry.
  a.memb=0;a.mem.ram[L['MEMB_SH']]=0
  for bank in range(2):
   for tile in range(256):
    i=(tile&254)|bank;a.mem.ram[L['EXPF_OBJ']+i]=1
    a.mem.ram[L['VMADDL']]=(tile*16)&255;a.mem.ram[L['VMADDH']]=bank*16+(tile>>4)
    a.vram[0x60000+bank*4096+tile*16]=0xa5
    a.cpu.a=0x5a;a.cpu.x=0x6b;a.cpu.y=0x7c;a.cpu.p=0xe5;a.call(L['PPU_W_A'])
    assert (a.cpu.a,a.cpu.x,a.cpu.y,a.cpu.p&0xcf)==(0x5a,0x6b,0x7c,0xe5&0xcf)
    assert a.mem.ram[L['EXPF_OBJ']+i]==0
    assert a.vram[0x60000+bank*4096+tile*16]==0x5a
  print(f'VBXE ${page:02X}00: all 256 background tiles, 256 8x16 sprites and 512 CHR invalidations pass',flush=True)

def check_renderer():
 a=initialized();raw=np.random.default_rng(7).integers(0,256,8192,dtype=np.uint8);raw[:16]=0;a.vram[0x60000:0x62000]=raw
 nts=np.random.default_rng(9).integers(0,256,(2,1024),dtype=np.uint8)
 for p in range(2):a.mem.ram[0x2800+1024*p:0x2c00+1024*p]=bytes(nts[p])
 a.mem.ram[L['PPU_MASK_STATE']]=8;a.mem.ram[L['LAT_CTRL']]=16
 a.call(L['MARK_ALL_DIRTY'])
 for _ in range(100):
  a.cpu.processorCycles=max(a.cpu.processorCycles,a.blit_busy_until)
  if a.mem.ram[L['PENDING']]:a.call(L['FLIP'])
  sample_now(a);a.call(L['COMPOSE'])
  if not a.mem.ram[L['ANY_DIRTY']]:break
 else:raise AssertionError('background renderer did not finish')
 for p in range(2):
  expected=np.zeros((240,256),dtype=np.uint8)
  for y in range(30):
   for x in range(32):
    c=decode(raw,256+int(nts[p,y*32+x]));at=int(nts[p,960+(y//4)*8+x//4]);pal=(at>>((y&2)*2+(x&2)))&3
    expected[y*8:y*8+8,x*8:x*8+8]=32+np.where(c==0,0,pal*4+c)
  actual=a.vram[0x20000+p*65536:0x20000+p*65536+61440].reshape(240,256)
  assert np.array_equal(actual,expected),('nametable',p,int(np.count_nonzero(actual!=expected)))
 print('Both full nametable bitmaps match independent NES decode (122880 pixels)',flush=True)
 # Synthetic OAM exercises both banks, flips, transparency and right/bottom clipping.
 a.mem.ram[0x200:0x300]=bytes([248,0,0,0])*64
 sprites=[(20,24,2,0),(40,64,3,0x40),(60,104,16,0x80),(80,144,17,0xc3),(225,252,254,2),(230,248,255,0xc1)]
 for i,(y,x,t,at) in enumerate(sprites):a.mem.ram[0x200+i*4:0x204+i*4]=bytes([y,t,at,x])
 a.mem.ram[L['PPU_MASK_STATE']]=16
 for _ in range(40):
  a.cpu.processorCycles=max(a.cpu.processorCycles,a.blit_busy_until)
  if a.mem.ram[L['PENDING']]:a.call(L['FLIP'])
  sample_now(a);a.call(L['COMPOSE'])
  if a.mem.ram[L['PENDING']]:break
 else:raise AssertionError('sprite renderer did not finish')
 expected=np.full((240,256),32,dtype=np.uint8)
 for y,x,t,at in reversed(sprites):
  tile=(t&1)*256+(t&254);c=np.vstack([decode(raw,tile),decode(raw,tile+1)])
  if at&128:c=c[::-1]
  if at&64:c=c[:,::-1]
  c=c[:239-y,:256-x];dest=expected[y+1:y+1+c.shape[0],x:x+c.shape[1]];dest[c!=0]=16+(at&3)*4+c[c!=0]
 fb=0x40000+a.mem.ram[L['BACK']]*65536;actual=a.vram[fb:fb+61440].reshape(240,256)
 assert np.array_equal(actual,expected),('sprites',int(np.count_nonzero(actual!=expected)))
 print('8x16 sprite composition matches independent NES decode, including flips and clipping',flush=True)


def check_row_index():
 a=initialized();a.mem.ram[L['VMADDH']]=0x20;a.mem.ram[L['VMADDL']]=70;a.cpu.a=3;a.call(L['PPU_W_A'])
 a.mem.ram[0xc00:0xd40]=bytes(320);a.mem.ram[L['EXPF_BG']:L['EXPF_BG']+256]=bytes([1])*256
 a.mem.ram[L['VMADDH']]=0x10;a.mem.ram[L['VMADDL']]=48;a.cpu.a=0x81;a.call(L['PPU_W_A']);a.call(L['MARK_CHR_DIRTY'])
 actual=bytes(a.mem.ram[0xc00:0xd00]);expected=bytearray(256);expected[70//8]=1<<(70&7)
 assert actual==expected,'CHR row index dirtied unrelated cells or missed the changed tile'
 assert a.mem.ram[0xd02]==1
 print('Animated CHR row index marks exactly the affected nametable cell',flush=True)


def check_chr_coalescing():
 a=initialized();tile=3
 a.mem.ram[L['EXPF_BG']+tile]=1
 def upload(offset,value):
  a.mem.ram[L['VMADDH']]=0x10
  a.mem.ram[L['VMADDL']]=tile*16+offset
  a.cpu.a=value;a.call(L['PPU_W_A'])
 upload(0,0x81)
 assert a.mem.ram[L['CHR_DIRTY']]==1
 a.call(L['MARK_CHR_DIRTY'])
 # Remaining bytes in the same invalid tile need no repeated row scan.
 for offset in range(1,16):upload(offset,0x81)
 assert a.mem.ram[L['CHR_DIRTY']]==0
 # Expansion marks the cache valid before reading it. A write interrupting
 # that expansion must queue a fresh scan, even for the same pattern.
 a.mem.ram[L['EXPF_BG']+tile]=1
 upload(0,0x42)
 assert a.mem.ram[L['CHR_DIRTY']]==1
 assert a.mem.ram[L['CHR_BITS']]&8
 assert a.mem.ram[L['EXPF_BG']+tile]==0
 print('CHR uploads coalesce while invalid and requeue after expansion begins',flush=True)

def check_dirty_packing():
 rng=np.random.default_rng(42)
 a=initialized()
 for trial in range(8):
  tiles=rng.integers(0,256,(2,1024),dtype=np.uint8)
  valid=rng.integers(0,2,256,dtype=np.uint8)
  # Force every row through the scanner; include previously dirty cells.
  a.mem.ram[L['ROW_USES']:L['ROW_USES']+2048]=bytes([255])*2048
  a.mem.ram[L['CHR_BITS']:L['CHR_BITS']+32]=bytes([255])*32
  a.mem.ram[L['EXPF_BG']:L['EXPF_BG']+256]=bytes(valid)
  dirty=bytearray(rng.integers(0,256,256,dtype=np.uint8));expected=bytearray(dirty)
  a.mem.ram[L['DIRTY']:L['DIRTY']+256]=dirty
  a.mem.ram[L['ROWDIRTY']:L['ROWDIRTY']+64]=bytes(64)
  for p in range(2):
   a.mem.ram[0x2800+p*1024:0x2c00+p*1024]=bytes(tiles[p])
   for cell in range(960):
    if not valid[tiles[p,cell]]:expected[p*128+cell//8]|=1<<(cell&7)
  a.mem.ram[L['MDC_VALID']]=0          # nametables written directly, not via the PPU
  a.call(L['MARK_CHR_DIRTY'])
  assert a.mem.ram[L['DIRTY']:L['DIRTY']+256]==expected,trial
  for p in range(2):
   for row in range(30):
    assert a.mem.ram[L['ROWDIRTY']+p*32+row]==int(any(expected[p*128+row*4:p*128+row*4+4]))
 print('Randomized dirty-bit packing preserves all affected and previously dirty cells',flush=True)

def check_chr_scan_cache():
 a=initialized();ram=a.mem.ram
 cells=[(0,3,7),(0,20,31),(1,0,0),(1,29,12)]   # (nametable, row, col) holding tile 252
 for p in range(2):ram[0x2800+p*1024:0x2800+p*1024+960]=bytes(960)
 for p,r,c in cells:ram[0x2800+p*1024+r*32+c]=252
 ram[L['ROW_USES']:L['ROW_USES']+2048]=bytes([255])*2048
 ram[L['MDC_VALID']]=0
 def scan(bits):
  ram[L['EXPF_BG']:L['EXPF_BG']+256]=bytes([1])*256
  for t in (252,253):ram[L['EXPF_BG']+t]=0
  ram[L['DIRTY']:L['DIRTY']+256]=bytes(256);ram[L['ROWDIRTY']:L['ROWDIRTY']+64]=bytes(64)
  ram[L['CHR_BITS']:L['CHR_BITS']+32]=bytes(31)+bytes([bits])
  start=a.cpu.processorCycles;a.call(L['MARK_CHR_DIRTY'])
  return bytes(ram[L['DIRTY']:L['DIRTY']+256]),a.cpu.processorCycles-start
 expected=bytearray(256)
 for p,r,c in cells:expected[p*128+r*4+c//8]|=1<<(c&7)
 full,c1=scan(0x30);assert full==expected and ram[L['MDC_VALID']]==1
 again,c2=scan(0x30);assert again==expected and c2*10<c1,(c1,c2)
 sub,_=scan(0x10);assert sub==expected     # subset: the cached marks cover it
 ram[L['VMADDH']]=0x20;ram[L['VMADDL']]=5;a.cpu.a=7;a.call(L['PPU_W_A'])
 assert ram[L['MDC_VALID']]==0,'nametable write must drop the cached scan'
 print(f'CHR scan cache replays a repeated change in {c2} cycles instead of {c1}',flush=True)

def check_audio_pitch():
 worst=0
 for pal,k in [(True,145),(False,146)]:
  a=initialized(pal=pal)
  assert a.mem.ram[L['PITCH_K']]==k
  for octave in (0,1):
   for timer in range(2048):
    a.mem.ram[L['S_T']]=timer&255;a.mem.ram[L['S_T']+1]=timer>>8
    a.mem.ram[L['S_OCT']]=octave;a.cpu.x=2
    start=a.cpu.processorCycles;a.call(L['TIMER_AUDF'])
    worst=max(worst,a.cpu.processorCycles-start)
    divider=(timer+1)*k//(512 if octave==0 else 256)
    while divider>256:divider//=2
    assert a.mem.ram[L['S_AUDF']]==max(0,divider-1),(pal,octave,timer)
    assert a.cpu.x==2
 print(f'All 8192 PAL/NTSC pulse/triangle timer conversions pass; at most {worst} modeled cycles',flush=True)


if __name__=='__main__':
 main()
 check_renderer()
 check_row_index()
 check_chr_coalescing()
 check_audio_pitch()
 check_dirty_packing()
 check_chr_scan_cache()
