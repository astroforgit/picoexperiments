#!/usr/bin/env python3
"""Execute the built 6502 XEX with py65 and a bounds-checking VBXE model.

This checks CPU instructions, bank uploads, blits and gameplay. It does not
emulate ANTIC, raster timing, POKEY synthesis, or VBXE bus contention.
"""
from pathlib import Path
import json
from PIL import Image
from py65.devices.mpu6502 import MPU

ROOT = Path(__file__).resolve().parents[1]
LABELS = {p[2].lower(): int(p[1],16) for line in
          (ROOT/'generated/double-dragon-vbxe.lab').read_text().splitlines()
          if len(p := line.split()) == 3}
XEX = (ROOT/'double-dragon-vbxe.xex').read_bytes()
MANIFEST = json.loads((ROOT/'generated/manifest.json').read_text())

class Memory:
    def __init__(self, page, rate, revision=0x26, core=0x10):
        self.ram=bytearray(65536)
        self.vram=bytearray(0x80000)
        self.page=page
        self.bank=0
        self.memc=0
        self.memb=0
        self.revision=revision
        self.core=core
        self.ram[0xd301]=255
        self.key=None
        self.color=0
        self.palette=bytearray(768)
        self.blits=0
        self.hardware_writes=[]
        self.ram[0xd014]=1 if rate == 50 else 14
        self.ram[0xd300]=255
        self.ram[0xd010]=1
        self.ram[0xd01f]=7
        # Minimal OS NMI prologue and immediate-VBI epilogue. This models the
        # vector contract, not the full Atari OS or ANTIC raster.
        self.ram[0xfffa:0xfffc]=bytes((0x00,0xe4))
        self.ram[0x222:0x224]=bytes((0x5f,0xe4))
        self.ram[0xe400:0xe408]=bytes((0x48,0x8a,0x48,0x98,0x48,0x6c,0x22,0x02))
        self.ram[0xe45f:0xe467]=bytes((0xe6,0x14,0x68,0xa8,0x68,0xaa,0x68,0x40))
        self.ram[0xd40e]=0x40
    def mapped(self,a):
        # CPU mapping follows FX 1.2x MEMAC, including size/alignment and ROM priority.
        if 0xd000 <= a < 0xd800: return None
        if self.ram[0xd301]&1 and (0xc000 <= a < 0xd000 or a >= 0xd800): return None
        if not self.ram[0xd301]&2 and 0xa000 <= a < 0xc000: return None
        if self.page and self.bank&128 and self.memc&8:
            shift=self.memc&3
            base=(self.memc&0xf0)<<8
            if base <= a < min(65536,base+(4096<<shift)):
                return ((self.bank&127)&~((1<<shift)-1))*4096+a-base
        if self.page and self.memb&128 and 0x4000 <= a < 0x8000:
            return (self.memb&31)*16384+a-0x4000
        if self.page and self.revision&128 and not self.ram[0xd301]&16 and 0x4000 <= a < 0x8000:
            port=self.ram[0xd301]
            bank=((port>>2)&3)|((port>>3)&12)
            return 0x40000+bank*16384+a-0x4000
        return None
    def __getitem__(self,a):
        if a == 0xd20f: return 255 if self.key is None else 251
        if a == 0xd209: return self.key or 0
        if self.page and a == self.page+0x40: return self.core
        if self.page and a == self.page+0x41: return self.revision
        if self.page and a == self.page+0x5e: return self.memc
        if self.page and a == self.page+0x5f: return self.bank
        if self.page and a == self.page+0x53: return 0
        mapped=self.mapped(a)
        if mapped is not None: return self.vram[mapped]
        return self.ram[a]
    def __setitem__(self,a,v):
        mapped=self.mapped(a)
        if mapped is not None:
            self.vram[mapped]=v
            return
        self.ram[a]=v
        if self.page is None: return
        if self.page+0x40 <= a <= self.page+0x5f: self.hardware_writes.append((a,v))
        if a == self.page+0x5d: self.memb=v
        if a == self.page+0x5e: self.memc=v
        if a == self.page+0x5f: self.bank=v
        if a == self.page+0x44: self.color=v
        if self.page+0x46 <= a <= self.page+0x48:
            self.palette[self.color*3+a-self.page-0x46]=v
            if a == self.page+0x48: self.color=(self.color+1)&255
        if a == self.page+0x53 and v == 1: self.blit()
    def blit(self):
        p=int.from_bytes(self.ram[self.page+0x50:self.page+0x53],'little')
        assert p == 0x7f100
        b=self.vram[p:p+21]
        source=int.from_bytes(b[:3],'little')
        dest=int.from_bytes(b[6:9],'little')
        sp=int.from_bytes(b[3:5],'little')
        dp=int.from_bytes(b[9:11],'little')
        w=int.from_bytes(b[12:14],'little')+1
        h=b[14]+1
        assert b[5] == b[11] == 1 and b[20] in (0,1)
        assert not any(b[17:20])
        if dp == 320:
            assert dest//65536 in (0,1)
            assert dest%65536//320+h <= 200, (dest,w,h)
            assert dest%65536%320+w <= 320, (dest,w,h)
        else:
            assert dp == 1024 and w == h == 8
            assert 0x30000 <= dest and dest+7*1024+8 <= 0x62000
            assert (dest-0x30000)%1024+8 <= 1024
            assert 0x20000 <= source and source+64 <= 0x30000
        assert source+(h-1)*sp+w <= 0x80000
        if dp == 320 and self.ram[self.page+0x40]&1:
            assert dest//65536 != self.ram[self.page+0x41]//20, 'visible framebuffer overwritten'
        for y in range(h):
            if b[15] == 0:
                row=bytes([b[16]])*w
            else:
                row=self.vram[source+y*sp:source+y*sp+w]
                if b[15] != 255 or b[16]: row=bytes((v&b[15])^b[16] for v in row)
            d=dest+y*dp
            if b[20] == 0: self.vram[d:d+w]=row
            else:
                for x,v in enumerate(row):
                    if v: self.vram[d+x]=v
        self.blits+=1

class Machine:
    def __init__(self,page=0xd600,rate=50,memory=None,after_init=None,before_init=None):
        self.mem=memory or Memory(page,rate)
        supported=page and self.mem.core==0x10 and self.mem.revision&0x70==0x20
        self.cpu=MPU(memory=self.mem)
        data=XEX
        p=0
        self.uploads=0
        while p < len(data):
            start=int.from_bytes(data[p:p+2],'little'); p+=2
            if start == 65535: continue
            end=int.from_bytes(data[p:p+2],'little'); p+=2
            n=end-start+1
            assert n > 0 and p+n <= len(data)
            for address,value in enumerate(data[p:p+n],start): self.mem[address]=value
            p+=n
            if start <= 0x2e2 <= end:
                init=int.from_bytes(self.mem.ram[0x2e2:0x2e4],'little')
                if before_init: before_init(self)
                self.call(init)
                if init != LABELS['upload_bank']: continue
                if supported:
                    bank=MANIFEST['upload_banks'][self.uploads]
                    assert self.mem.vram[bank*4096:(bank+1)*4096] == self.mem.ram[0x8000:0x9000]
                self.uploads+=1
                if after_init: after_init(self)
        self.cpu.pc=int.from_bytes(self.mem.ram[0x2e0:0x2e2],'little')
        assert self.cpu.pc == LABELS['main']
        self.until(LABELS['loop' if supported else 'no_vbxe'])
    def get(self,name,i=0): return self.mem.ram[LABELS[name]+i]
    def set(self,name,v,i=0): self.mem.ram[LABELS[name]+i]=v
    def until(self,pc,limit=2000000):
        for _ in range(limit):
            if self.cpu.pc == pc: return
            if self.cpu.pc == LABELS['wait_frame']:
                self.vblank()
            self.cpu.step()
        raise AssertionError(f'CPU stuck at {self.cpu.pc:04x}; expected {pc:04x}')
    def vblank(self):
        if not self.mem.ram[0xd40e]&0x40: return
        pc=self.cpu.pc
        self.cpu.nmi()
        self.until(pc)
    def call(self,proc):
        old=self.cpu.pc
        self.cpu.stPushWord(0x5fe)
        self.cpu.pc=LABELS[proc] if isinstance(proc,str) else proc
        self.until(0x5ff)
        self.cpu.pc=old
    def frame(self,stick=15,fire=False,key=None):
        self.mem.ram[0xd300]=240|stick
        self.mem.ram[0xd010]=0 if fire else 1
        self.mem.key=key
        self.cpu.step()
        self.until(LABELS['loop'])
    def snapshot(self,name):
        bank=self.mem.ram[self.mem.page+0x41]//20
        im=Image.frombytes('P',(320,200),bytes(self.mem.vram[bank*65536:bank*65536+64000]))
        im.putpalette(self.mem.palette)
        im.resize((960,600),Image.Resampling.NEAREST).save(ROOT/'generated'/name)

def check():
    report=[]
    m=Machine()
    assert m.uploads == 97
    assert MANIFEST['sprites'] == 32
    world=Image.open(ROOT/'generated/world-1.png').tobytes()
    assert m.mem.vram[0x30000:0x62000] == world
    font_tails=[bytes(m.mem.vram[p:p+1536]) for p in (0xfa00,0x1fa00)]
    m.snapshot('runtime-title.png')
    assert m.get('mode') == 0
    m.frame(fire=True)
    assert m.get('mode') == 1
    x=m.get('px')
    for _ in range(20): m.frame(stick=7)
    assert m.get('px') > x
    m.snapshot('runtime-game.png')
    m.frame(key=10)
    assert m.get('mode') == 2
    x=m.get('px'); timer=m.get('seconds')
    for _ in range(10): m.frame(stick=7)
    assert m.get('px') == x and m.get('seconds') == timer
    m.frame(key=10)
    assert m.get('mode') == 1
    report.append('XEX segments, all VRAM uploads, title/start, movement, pause/resume, bounded double buffering: PASS')
    for camera in (0,254,256,510,512,704):
        m.set('camera',camera&255); m.set('camera',camera>>8,1)
        m.call('render')
        fb=m.mem.ram[m.mem.page+0x41]//20*65536
        for y in (19,192,193,199):
            assert m.mem.vram[fb+y*320:fb+(y+1)*320] == world[y*1024+camera:y*1024+camera+320], (camera,y)
    assert font_tails == [bytes(m.mem.vram[p:p+1536]) for p in (0xfa00,0x1fa00)]
    m.call('restart'); m.set('px',200)
    m.mem.ram[0xd300]=247; m.call('input'); m.call('update')
    assert m.get('camera') == m.get('camera',1) == 0, 'encounter must lock camera'
    m.set('remaining',0)
    for i in range(3): m.set('enemy_hp',0,i)
    m.call('world_update')
    assert m.get('camera') == 2 and m.get('wave') == 0
    report.append('Pixel-exact panorama scrolling across 256-pixel boundaries, encounter camera locks, font padding preservation: PASS')
    m.call('restart'); m.set('px',100)
    m.set('stick',7); m.set('fire',1)
    m.call('update')
    assert m.get('px') == 100 and m.get('facing') == 0 and m.get('attack') == 16
    m.set('jump',10); m.call('update')
    assert m.get('px') == 102, 'airborne direction should still move Billy'
    report.append('Grounded directional attacks turn without stepping through enemies; jumping attacks retain movement: PASS')
    # Unit scenarios exercise real assembled routines, including hit direction.
    m.call('restart')
    m.set('px',100); m.set('py',170); m.set('facing',0); m.set('attack_kind',0)
    for i,x in enumerate((125,80,130)):
        m.set('enemy_x',x,i); m.set('enemy_y',170 if i<2 else 140,i)
        m.set('enemy_hp',3,i)
    m.call('player_hit')
    assert [m.get('enemy_hp',i) for i in range(3)] == [2,3,3]
    m.call('player_hit')
    assert m.get('enemy_hp') == 2, 'stun must prevent repeated hit'
    m.set('enemy_stun',0); m.set('attack_kind',1)
    m.call('player_hit')
    assert m.get('enemy_hp') == 0 and m.get('points') == 1 and m.get('remaining') == 2
    m.set('jump',10); m.set('immune',0)
    m.set('enemy_x',120,1); m.set('enemy_cool',0,1)
    hp=m.get('health'); m.call('update')
    assert m.get('health') == hp, 'jump should evade attacks'
    m.set('health',1); m.set('jump',0); m.set('immune',0)
    m.set('enemy_state',1,1); m.set('enemy_cool',1,1); m.set('enemy_face',4,1)
    m.call('update')
    assert m.get('lives') == 2 and m.get('health') == 12
    report.append('Directional/depth hit boxes, kick damage, hit stun, jump evasion, death and respawn: PASS')
    m.set('fx_ticks',3)
    m.call('sound')
    assert m.mem.ram[0xd201] == 0 and m.mem.ram[0xd203] != 0
    for _ in range(5): m.call('sound')
    assert m.get('fx_ticks') == 0
    assert m.mem.ram[0xd201] == m.mem.ram[0xd203] == 0
    m.set('muted',1); m.set('fx_ticks',3); m.call('sound')
    m.vblank()
    assert m.mem.ram[0xd201] == m.mem.ram[0xd203] == 0
    assert m.mem.ram[0xd205] == m.mem.ram[0xd207] == 0
    assert 'music_vbi' not in LABELS and 'music_frame' not in LABELS
    assert m.mem.ram[0x222:0x224] == bytes((0x5f,0xe4)), 'music interrupt still installed'
    report.append('No music or music interrupt; combat effects stop and mute correctly: PASS')
    # Compare PAL and NTSC simulation time using the real accumulator.
    for rate in (50,60):
        n=Machine(0xd700,rate)
        n.call('restart')
        for i in range(rate*2):
            n.mem.ram[0x14]=(n.mem.ram[0x14]+1)&255
            n.call('frame_time')
        assert n.get('seconds') == 88, (rate,n.get('seconds'))
        assert n.get('tick') == 60
    n=Machine(None)
    assert n.mem.blits == 0
    report.append('D600/D700 detection, absent-VBXE fallback, PAL/NTSC 30 Hz simulation: PASS')
    from test_combat import check as combat_check
    report.extend(combat_check())
    campaign(report)
    print('\n'.join(report))
    (ROOT/'generated/test-results.txt').write_text('\n'.join(report)+'\n')

def campaign(report):
    # Preserve the old input-only jump-kick bot as an exploit regression.
    # This policy must no longer clear the campaign by staying invulnerable.
    m=Machine()
    font_tails=[bytes(m.mem.vram[p:p+1536]) for p in (0xfa00,0x1fa00)]
    m.frame(fire=True)
    stages_seen={0}
    cameras_seen=set()
    for step in range(24000):
        if m.get('mode') != 1: break
        candidates=[i for i in range(3) if m.get('enemy_hp',i)]
        stick=15; fire=False
        if candidates:
            i=min(candidates,key=lambda i:abs(m.get('enemy_x',i)-m.get('px'))+2*abs(m.get('enemy_y',i)-m.get('py')))
            dx=m.get('enemy_x',i)-m.get('px')
            dy=m.get('enemy_y',i)-m.get('py')
            if abs(dy)>6:
                stick &= 13 if dy>0 else 14
            elif abs(dx)<18 and not m.get('attack'):
                # Restore enough distance for the next kick instead of
                # crossing through a target that is directly under Billy.
                stick &= 11 if dx>=0 else 7
            elif abs(dx)<44:
                # Face the target when beginning a kick, but stop drifting
                # through it once the airborne attack is already underway.
                if not m.get('attack') or abs(dx)>34:
                    stick &= 7 if dx>=0 else 11
                stick &= 14       # former full-jump-immunity exploit
                fire=True
            else:
                stick &= 7 if dx>=0 else 11
        else:
            stick=7
        m.mem.ram[0xd300]=240|stick
        m.mem.ram[0xd010]=0 if fire else 1
        m.call('input')
        m.call('update')
        camera=m.get('camera')+256*m.get('camera',1)
        assert 0 <= camera <= 704
        if camera in (256,512,704): cameras_seen.add((m.get('stage'),camera))
        if m.get('stage') not in stages_seen:
            stages_seen.add(m.get('stage'))
            expected=Image.open(ROOT/f'generated/world-{m.get("stage")+1}.png').tobytes()
            assert m.mem.vram[0x30000:0x62000] == expected, 'runtime cache differs from source panorama'
            m.call('render')
            m.snapshot(f'runtime-stage-{m.get("stage")+1}.png')
    assert m.get('mode') == 3, {
        **{k:m.get(k) for k in ('mode','stage','wave','points','lives','health','seconds','px','py','attack','facing','jump')},
        'enemies':[(m.get('enemy_x',i),m.get('enemy_y',i),m.get('enemy_hp',i)) for i in range(3)]}
    report.append(f'Old input-only jump-kick exploit defeated after {m.get("points")} enemies, {step} ticks: PASS')

    # Separately verify all world exits/caches using explicit combat fixtures.
    # This is progression coverage, not evidence of a human/bot playthrough.
    m=Machine(); m.frame(fire=True)
    stages_seen={0}; cameras_seen=set()
    for step in range(10000):
        if m.get('mode') != 1: break
        for i in range(3):
            m.set('enemy_x',min(252,m.get('px')+10),i)
            m.set('enemy_y',m.get('py'),i)
        m.set('facing',0); m.set('attack_kind',1)
        while m.get('remaining'):
            for i in range(3): m.set('enemy_stun',0,i)
            before=m.get('remaining')
            hp=sum(m.get('enemy_hp',i) for i in range(3))
            m.call('player_hit')
            assert sum(m.get('enemy_hp',i) for i in range(3)) < hp or m.get('remaining') < before
        m.set('stick',7); m.set('fire',0); m.call('update')
        camera=m.get('camera')+256*m.get('camera',1)
        assert 0 <= camera <= 704
        if camera in (256,512,704): cameras_seen.add((m.get('stage'),camera))
        if m.get('stage') not in stages_seen:
            stages_seen.add(m.get('stage'))
            expected=Image.open(ROOT/f'generated/world-{m.get("stage")+1}.png').tobytes()
            assert m.mem.vram[0x30000:0x62000] == expected
            m.call('render'); m.snapshot(f'runtime-stage-{m.get("stage")+1}.png')
    assert m.get('mode') == 4
    assert m.get('points') == 36 and stages_seen == {0,1,2,3}
    assert len(cameras_seen) == 12, cameras_seen
    assert font_tails == [bytes(m.mem.vram[p:p+1536]) for p in (0xfa00,0x1fa00)]
    m.call('render'); m.snapshot('runtime-win.png')
    report.append('Explicit combat fixtures: 36 defeats, 12 waves, all 4 scrolling stages/exits, caches and victory: PASS')
    m.frame(fire=False); m.frame(fire=True)
    assert m.get('mode') == 1 and m.get('points') == 0 and m.get('stage') == 0
    m.call('lose_life'); m.call('lose_life'); m.call('lose_life')
    assert m.get('mode') == 3
    m.frame(fire=False); m.frame(fire=True)
    assert m.get('mode') == 1 and m.get('lives') == 3
    report.append('Victory/game-over restart: PASS')
if __name__ == '__main__':
    import sys
    if '--campaign-only' in sys.argv:
        report=[]; campaign(report); print('\n'.join(report))
    else: check()
