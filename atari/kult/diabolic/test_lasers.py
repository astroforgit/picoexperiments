"""Laser display-frame timing, drawing, collision and native movement routes."""
import json,unittest
from pathlib import Path
from py65.devices.mpu6502 import MPU
from build import create_runtime,package,kult
from boss_lab import call,move
DATA=json.loads((Path(__file__).parents[1]/'editor/laser-patterns.json').read_text())
ROWS=[8,24,40,56,72,88,104,120]
SEQUENCE=[step for route in DATA['routes'] for step in route['steps']]
MASKS=[DATA['shapes'][i]['mask'] for i in SEQUENCE]
TYPES=[DATA['shapes'][i]['type'] for i in SEQUENCE]
UNIQUE=[SEQUENCE.index(i) for i in sorted(set(SEQUENCE))]
def beams(pattern,x):
 for i,row in enumerate(ROWS):
  if MASKS[pattern]&(1<<i):
   slope=0 if not TYPES[pattern] else -1 if TYPES[pattern]==2 and i&1 else 1
   for col in range(x//4,(x+19)//4+1):
    y=row+slope*(col-16)
    if 0<=y<125:yield y
class Lasers(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.original,cls.ram,_,_=create_runtime()
 def scene(self,variant=0):
  c=MPU(memory=list(self.ram));m=c.memory;m[0x4e75]=0;m[0xd20f]=0;m[0xd209]=0x35;m[0xfd04]=0;m[0x2dfc]=variant*15
  call(c,0x3f50)
  self.assertEqual(m[0x2d20],8)
  m[0xf398]=m[0xf0bf]=m[0x2d61]=m[0x7460]=0
  m[0xe957:0xe959]=[12,56]
  return c
 def screen(self,c,buffer=0,offset=0):
  m=c.memory;m[0x7439]=buffer;m[0x7446]=0;m[0x7e:0x80]=[0,0x60]
  # Isolate laser rendering from the independently tested boss cache renderer.
  m[0x1783]=m[0x0480]=0x60
  base=0x8000+buffer*8192
  for y in range(128):m[0x6000+3*y:0x6002+3*y]=list((base+y*64+offset).to_bytes(2,'little'))
  return base
 def test_shortcut_and_extended_record_encoding(self):
  for sector in range(8):
   c=MPU(memory=list(self.ram));m=c.memory;m[0x4e75]=sector;m[0xd20f]=0;m[0xd209]=0x35
   call(c,0x3f50);self.assertEqual(m[0x2d20],8);self.assertEqual(m[0xfb8a],21)
   self.assertFalse(any(m[0x74e0:0x74e8]));self.assertFalse(any(m[0x7482:0x748a]))
  replay=kult(package(self.original,self.ram))[0]
  self.assertEqual(replay[0xdf00:0xe460],self.ram[0xdf00:0xe460])
 def test_warning_duration_pause_and_contact_protections(self):
  c=self.scene();m=c.memory;m[0xe958]=8
  for _ in range(40):call(c,0x2e0c)
  self.assertEqual(m[0x2de9],50,'Timer must wait until warning is drawn')
  m[0x2deb]=2
  for _ in range(49):call(c,0x2e0c);call(c,0xdf09);self.assertEqual(m[0xf398],0)
  self.assertEqual(m[0x2de8],1);self.assertEqual(m[0x2de9],1)
  m[0x7460]=255
  for _ in range(20):call(c,0x2e0c)
  self.assertEqual(m[0x2de9],1)
  m[0x7460]=0;call(c,0x2e0c);call(c,0xdf09)
  self.assertEqual(m[0x2de8],2);self.assertEqual(m[0xf398],0)
  m[0x2deb]=2;m[0x2d61]=1;call(c,0xdf09);self.assertEqual(m[0xf398],0)
  m[0x2d61]=0;m[0xf0bf]=1;call(c,0xdf09);self.assertEqual(m[0xf398],0)
  call(c,0xdf09);self.assertEqual(m[0xf398],3)
  call(c,0xdf09);self.assertEqual(m[0x2de8],1);self.assertEqual(m[0x2deb],0)
 def test_death_keeps_selected_route_and_current_pattern(self):
  c=self.scene(2);m=c.memory;m[0x2dea]=37;m[0x2de8]=2;m[0x2deb]=2;m[0xf398]=3
  call(c,0xdf09)
  self.assertEqual((m[0x2dea],m[0x2ddd],m[0x2dfc]),(37,45,0))
  self.assertEqual((m[0x2de8],m[0x2de9],m[0x2deb]),(1,50,0))
 def test_exact_live_contact_and_warning_never_hits(self):
  for pattern in UNIQUE:
   for x in (0,12,51,102):
    for phase in (1,2):
     c=self.scene();m=c.memory;m[0x2de8]=phase;m[0x2dea]=pattern;m[0x2deb]=2;m[0xe957]=x
     for y in range(113):
      m[0xe958]=y;m[0xf398]=0
      call(c,0xdf09)
      hit=phase==2 and any(y<row+4 and y+16>row for row in beams(pattern,x))
      self.assertEqual(bool(m[0xf398]),hit,(phase,pattern,x,y))
 def test_both_buffers_clear_old_patterns_and_leave_hud_intact(self):
  for buffer in (0,1):
   for offset in (0,31):
    c=self.scene();m=c.memory;base=self.screen(c,buffer,offset);m[base:base+8192]=[0]*8192
    m[0x6684:0x6a84]=[0x55]*1024
    for pattern in UNIQUE:
     for phase,timer in ((1,25),(2,20),(2,16)):
      call(c,0xdf12);m[0x2de8]=phase;m[0x2dea]=pattern;m[0x2de9]=timer
      call(c,0xdf0c);expected=[0]*8192
      for i,row in enumerate(ROWS):
       if not MASKS[pattern]&(1<<i):continue
       slope=0 if not TYPES[pattern] else -1 if TYPES[pattern]==2 and i&1 else 1
       for col in range(32):
        y=row+slope*(col-16)
        if not 0<=y<128:continue
        edge=255 if phase==1 else 0xaa if timer&4 else 255
        expected[y*64+offset+col]=edge
        if phase==2 and y<125:
         for n in (1,2,3):expected[(y+n)*64+offset+col]=edge if n==3 else 255
      self.assertEqual(m[base:base+8192],expected,(buffer,offset,pattern,phase,timer))
    m[0x2d20]=0;call(c,0xdf12)
    self.assertFalse(any(m[base:base+8192]));self.assertEqual(m[0x6684:0x6a84],[0x55]*1024)
 def test_erases_original_addresses_after_scroll_or_respawn(self):
  for buffer in (0,1):
   for offset in (0,31):
    c=self.scene();m=c.memory;base=self.screen(c,buffer,offset);m[base:base+8192]=[0]*8192
    m[0x2dea]=6;m[0x2de8]=2;call(c,0xdf0c)
    self.assertTrue(any(m[base:base+8192]))
    # Dying resumes coarse/fine scrolling before the saved beam is erased.
    for row in range(128):m[0x6000+row*3:0x6002+row*3]=list((base+row*64+(offset+5)%32).to_bytes(2,'little'))
    m[0x7446]=4;m[0xf398]=3
    call(c,0xdf12)
    self.assertFalse(any(m[base:base+8192]),(buffer,offset,'stale beam after scroll'))
 def test_laser_frames_do_not_copy_terrain_pixels(self):
  c=self.scene();m=c.memory;m[0x758e]=2;m[0x758f]=0;m[0x7438]=0
  m[0x8000:0xa000]=[i%251 for i in range(8192)]
  m[0x7428:0x7430]=[0]*8;m[0x7430:0x7438]=[0x24]*8
  before=m[0x8000:0xa000].copy();call(c,0xdea0)
  self.assertEqual(m[0x8000:0xa000],before)
 def test_full_sequences_restore_ship_and_beams_without_trails(self):
  c=self.scene();m=c.memory;m[0x8000:0xc000]=[0]*16384;m[0x745c:0x7460]=[0]*4
  m[0x6684:0x6a84]=[0x55]*1024
  for tick in range(45*4+2):
   base=self.screen(c,tick%2,(tick*3)%32);m[0x7446]=tick%5
   # Real player-background restore, then laser erase, then terrain hook:
   # the original tests only exercised isolated beam drawing on a fixed view.
   call(c,0xec4b);call(c,0xec61);call(c,0xdf12);call(c,0xdea0)
   self.assertFalse(any(m[base:base+8192]),('stale pixels before drawing',tick))
   if tick<45*4:
    m[0x2dea]=tick//4;m[0x2de8]=1+(tick//2)%2;m[0xe958]=(tick*4)%112
    call(c,0xdf0c);call(c,0xec2d)
  self.assertFalse(any(m[0x8000:0xc000]))
  self.assertEqual(m[0x6684:0x6a84],[0x55]*1024)
 def timeline(self,period,variant):
  c=self.scene(variant);m=c.memory;m[0xf0bf]=255;self.screen(c)
  frames=[];warn_started=None;durations=[]
  for frame in range(2000):
   if frame%period==0:
    old_phase=m[0x2de8];m[0xf0bf]=255;call(c,0xdf09)
    if m[0x2de8]==2 and old_phase==1:durations.append(frame-warn_started)
    if m[0x2de8]==3:break
    if m[0x2de8]==1 and (warn_started is None or old_phase==2):warn_started=frame
    frames.append(dict(frame=frame,phase=m[0x2de8],pattern=m[0x2dea]))
    call(c,0xdf12);call(c,0xdf0c)
   call(c,0x2e0c)
  else:self.fail('Laser wave never finished')
  self.assertEqual(len(durations),15)
  self.assertTrue(all(50<=n<50+period for n in durations),durations)
  return frames
 def test_three_routes_rotate_and_require_longer_dodges(self):
  c=self.scene();m=c.memory
  for variant in (1,2,0,1):
   m[0xd20f]=255;call(c,0x3f50);m[0xd20f]=0;call(c,0x3f50)
   self.assertEqual(m[0x2dea],variant*15);self.assertEqual(m[0x2ddd],(variant+1)*15)
  for variant in range(3):
   bands=[{y for y in range(0,113,2) if not any(y<b+5 and y+17>b for b in beams(i,12))} for i in range(variant*15,(variant+1)*15)]
   minimum=[min(abs(a-b) for a in old for b in new) for old,new in zip(bands[2:],bands[3:])]
   self.assertGreaterEqual(sum(d>=24 for d in minimum),7,(variant,minimum))
   # The longest required move fits the shorter warning after reaction.
   self.assertLessEqual(max((d+5)//6+2 for d in minimum),10)
 def test_routes_all_heights_with_reaction_delay_and_slow_update_budget(self):
  reports=[];pilot=MPU(memory=list(self.ram));commands={}
  graph={}
  for y in range(0,113,2):
   graph[y]=set()
   for d in (-1,0,1):
    target=move(pilot,12,y,0,d)[1];graph[y].add(target);commands[y,target]=d
  safe_by_pattern={i:{y for y in graph if not any(y<b+5 and y+17>b for b in beams(i,12))} for i in range(45)}
  for variant in range(3):
   for period in (3,4,5):
    frames=self.timeline(period,variant);pauses=set();previous=None
    for tick,f in enumerate(frames):
     if f['phase']==1 and f['pattern']!=previous:pauses.update((tick,tick+1))
     previous=f['pattern']
    routes=[]
    for start in graph:
     current={start};history=[]
     for tick,f in enumerate(frames):
      parents={};safe=graph.keys() if f['phase']==1 else safe_by_pattern[f['pattern']]
      for old in sorted(current):
       for y in sorted(({old} if tick in pauses else graph[old]),key=lambda y:(y!=old,y)):
        if y in safe:parents.setdefault(y,old)
      self.assertTrue(parents,(variant,period,start,tick,f));history.append(parents);current=set(parents)
     end=min(current,key=lambda y:abs(y-start));route=[]
     for parents in reversed(history):route.append(end);end=parents[end]
     route.reverse();c=self.scene(variant);m=c.memory;m[0xe958]=start
     last=start
     for tick,f in enumerate(frames):
      y=route[tick];move(c,12,last,0,commands[last,y]);call(c,0xdf09)
      self.assertEqual(m[0xf398],0,(variant,period,start,tick,'native collision'))
      self.assertEqual((m[0x2de8],m[0x2dea]),(f['phase'],f['pattern']))
      m[0x2deb]=min(2,m[0x2deb]+1)
      # Display timing and raster gating run natively in timeline(); here
      # replay the same timer decrement, native joystick and native collision.
      m[0x2de9]=max(0,m[0x2de9]-period);last=y
     routes.append(dict(start=start,ys=route))
    stationary=set(graph)
    for f in frames:
     if f['phase']==2:stationary &= safe_by_pattern[f['pattern']]
    self.assertFalse(stationary)
    reports.append(dict(variant=variant,period=period,frames=frames,routes=routes))
  Path('/tmp/kult-laser-safety.json').write_text(json.dumps(dict(rows=ROWS,masks=MASKS,reactionUpdates=2,reports=reports)))
  print('Laser safety: 513 native routes across 3 options; 2-update reaction delay; 10/12.5/16.7 updates/s; at least 7 long dodges per option.')
if __name__=='__main__':unittest.main()
