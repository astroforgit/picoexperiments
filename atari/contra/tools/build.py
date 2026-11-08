#!/usr/bin/env python3
"""Build Contra's original 6502 game with Atari/VBXE hardware services."""
from pathlib import Path
import subprocess, os, re, hashlib, shutil, json
ROOT=Path(__file__).resolve().parents[1]; GEN=ROOT/'gen'; SRC=ROOT/'src'
CC=ROOT/'work/cc65/usr/bin'
CA65=os.environ.get('CA65',str(CC/'ca65') if (CC/'ca65').exists() else 'ca65')
LD65=os.environ.get('LD65',str(CC/'ld65') if (CC/'ld65').exists() else 'ld65')
MADS=os.environ.get('MADS','mads')
SERVICES=['ppu_w_a','ppu_w_x','ppu_w_y','ppu_r_a','ctrl_a','mask_a','addr_a','scroll_a','status_a','bank_a','controller_read','apu_length_x','apu_length_y','render_idle']
def run(args,cwd=ROOT):
 p=subprocess.run(list(map(str,args)),cwd=cwd,text=True,capture_output=True)
 if p.returncode or 'ERROR' in p.stdout: raise RuntimeError(p.stdout+p.stderr)
 return p.stdout
def seg(a,d):return a.to_bytes(2,'little')+(a+len(d)-1).to_bytes(2,'little')+bytes(d)
def segments(d):
 i=0
 while i<len(d):
  a=int.from_bytes(d[i:i+2],'little');i+=2
  if a==65535:continue
  b=int.from_bytes(d[i:i+2],'little');i+=2
  assert b>=a and i+b-a+1<=len(d)
  yield a,d[i:i+b-a+1];i+=b-a+1
 assert i==len(d)
def labels(p):
 out={}
 for l in p.read_text().splitlines():
  z=l.split()
  if len(z)==3:
   try:out[z[2].upper().lstrip('.')]=int(z[1],16)
   except ValueError:pass
 return out
# Contra's graphic data: PPU address (lo, hi), then $01-$7E n = repeat the next
# byte n times, $80+n = n literal bytes, $7F = new PPU address, $FF = end.
def gd_decode(d):
 blocks=[];addr=d[0]|d[1]<<8;cur=[];i=2
 while True:
  c=d[i]
  if c==0xff:blocks.append((addr,cur));return blocks
  if c==0x7f:blocks.append((addr,cur));addr=d[i+1]|d[i+2]<<8;cur=[];i+=3
  elif c<0x80:cur+=[d[i+1]]*c;i+=2
  else:cur+=list(d[i+1:i+1+(c&0x7f)]);i+=1+(c&0x7f)
def gd_encode(blocks):
 out=bytearray()
 for k,(addr,data) in enumerate(blocks):
  if k:out.append(0x7f)
  out+=bytes([addr&255,addr>>8]);lit=[];i=0
  def flush():
   while lit:part=lit[:0x7e];del lit[:0x7e];out.append(0x80|len(part));out.extend(part)
  while i<len(data):
   j=i
   while j<len(data) and data[j]==data[i] and j-i<0x7e:j+=1
   if j-i>=3:flush();out+=bytes([j-i,data[i]]);i=j
   else:lit.append(data[i]);i+=1
  flush()
 return bytes(out+b'\xff')
def gd_patch(path,fn):
 blocks=gd_decode(path.read_bytes());mem={}
 for a,d in blocks:
  for k,v in enumerate(d):mem[a+k]=v
 fn(mem)
 path.write_bytes(gd_encode([(a,[mem[a+k] for k in range(len(d))]) for a,d in blocks]))
# The title's four copyright lines under "2 PLAYERS" become the port's credit.
# The font has no colon: the copyright sign's tile, used only on that line,
# is redrawn as one.
TITLE_CREDIT='ATARI VBXE VERSION : ASTROFOR'
# A third title entry under "2 PLAYERS": a one-player game in which the
# runtime adds random jumps to the player's own input (render.asm, bunny).
BUNNY_TEXT='BAX BUNNY'
BUNNY_MODE=0x09FC
BUNNY_TEXT_INDEX=0x19        # appended to short_text_pointer_table
BUNNY_PATCHES={6:[
 ('    .addr text_alien_lair            ; CPU address $b3a5 - ALIEN\'S LAIR\n',
  '    .addr text_alien_lair            ; CPU address $b3a5 - ALIEN\'S LAIR\n    .addr text_bax_bunny\n'),
 ('    .byte $32,$00,$50,$4c,$41,$59,$45,$52,$53,$fe\n',
  '    .byte $32,$00,$50,$4c,$41,$59,$45,$52,$53,$fe\n\ntext_bax_bunny:\n    .byte $23,$07\n    .byte '
  +','.join(f'${0 if c==" " else ord(c):02x}' for c in BUNNY_TEXT)+',$fe\n'),
],7:[
 # cursor rows: 1 PLAYER, 2 PLAYERS, BAX BUNNY (CONTINUE/END use the first two)
 ('.else\n    .byte $a2,$b2\n.endif\n','.else\n    .byte $a2,$b2,$c2\n.endif\n'),
 ('    ldx PLAYER_MODE                ; number of players (0 = 1 player)\n    lda player_select_cursor_pos,x',
  '    lda BUNNY_MODE\n    asl\n    ora PLAYER_MODE\n    tax\n    lda player_select_cursor_pos,x'),
 # the chosen entry flashes once Start is pressed
 ('    lda #$01                                  ; a = #$01 (text_1_player)\n    clc',
  f'    lda #$01\n    ldx BUNNY_MODE\n    beq @flash_players\n    lda #${BUNNY_TEXT_INDEX:02x}\n@flash_players:\n    clc'),
 # SELECT cycles 1 PLAYER -> 2 PLAYERS -> BAX BUNNY (one player) -> 1 PLAYER
 ('''player_mode_change:
    inc PLAYER_MODE ; add one to number of players (will correct if more than #$02 players below)
    lda #$02
    sec             ; set the carry flag for the next subtract statement
    sbc PLAYER_MODE ; subtract player mode from #$02
    bne timer_exit  ; player mode was #$00 and now is #$01, simply exit
    sta PLAYER_MODE ; player mode was #$02, set PLAYER_MODE so it is #$00 (#$01 player)
''','''player_mode_change:
    lda BUNNY_MODE
    beq @next_players
    lda #$00
    sta BUNNY_MODE
    sta PLAYER_MODE
    rts
@next_players:
    inc PLAYER_MODE
    lda PLAYER_MODE
    cmp #$02
    bcc timer_exit
    lda #$00
    sta PLAYER_MODE
    lda #$01
    sta BUNNY_MODE
'''),
]}
COLON_TILE=0xc3
def title_credit(gs):
 assets=gs/'assets/graphic_data'
 def nametable(mem):
  assert bytes(mem[0x2000+24*32+c] for c in range(10,16))==b'TM\0AND',"title copyright moved"
  for row in range(24,28):
   for col in range(32):mem[0x2000+row*32+col]=0
  for k,ch in enumerate(BUNNY_TEXT):mem[0x2000+24*32+7+k]=0 if ch==' ' else ord(ch)
  col=(32-len(TITLE_CREDIT)+1)//2
  for k,ch in enumerate(TITLE_CREDIT):mem[0x2000+26*32+col+k]={' ':0,':':COLON_TILE}.get(ch,ord(ch))
 def patterns(mem):
  t=0x1000+COLON_TILE*16
  for k,v in enumerate([0,0x18,0x18,0,0x18,0x18,0,0]+[0]*8):mem[t+k]=v
 gd_patch(assets/'graphic_data_02.bin',nametable)
 gd_patch(assets/'graphic_data_01.bin',patterns)
def main():
 GEN.mkdir(exist_ok=True); gs=GEN/'nes';shutil.copytree(ROOT/'upstream/src',gs,dirs_exist_ok=True)
 rom=(ROOT/'Contra/Contra (USA).nes').read_bytes()
 assert hashlib.sha256(rom).hexdigest()=='26541a5550ee22deeb3d5484e4a96130219b58cff74d068fb1eb6567fa5e5519','Unsupported ROM revision'
 for l in (ROOT/'upstream/assets.txt').read_text().splitlines():
  p,o,n=l.split();p=gs/Path(p.replace('\\','/')).relative_to('src');p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(rom[int(o):int(o)+int(n)])
 title_credit(gs)
 vector=lambda n:0x1000+3*SERVICES.index(n)
 (GEN/'vectors.asm').write_text('; services generated by build.py\n')
 (GEN/'vector-table.asm').write_text('        org $1000\n'+''.join(f'        jmp {n}\n' for n in SERVICES))
 constants=(gs/'constants.asm').read_text()
 constants+=f'\nBUNNY_MODE = ${BUNNY_MODE:04X}\n';constants=re.sub(r'(APU_\w+\s*=\s*)\$40([0-9a-f]{2})',r'\g<1>$0a\2',constants)
 constants=constants.replace('OAMADDR       = $2003','OAMADDR       = $09F2').replace('OAMDMA              = $4014','OAMDMA              = $09F3')
 (gs/'constants.asm').write_text(constants)
 regs={'PPUCTRL':'ctrl_a','PPUMASK':'mask_a','PPUADDR':'addr_a','PPUSCROLL':'scroll_a','PPUSTATUS':'status_a','PPUDATA':'ppu_w_a'}
 counts={}
 for bank in range(8):
  p=gs/f'bank{bank}.asm';t=p.read_text()
  for old,new in BUNNY_PATCHES.get(bank,[]):
   assert t.count(old)==1,(bank,old);t=t.replace(old,new)
  if bank==2:
   # Every-other-tick hiding aliases with the paced renderer. Keep the
   # player sprite present and signal spawn immunity with the existing
   # barrier palette pulse instead; collision/timer logic is untouched.
   a=t.index('    lda NEW_LIFE_INVINCIBILITY_TIMER,x',t.index('set_player_paused_sprite_attr:'))
   b=t.index('\n@continue:',a)
   assert 'lda FRAME_COUNTER' in t[a:b] and 'bcc @set_y_to_player_sprite' in t[a:b]
   t=t[:a]+'    jmp @set_y_to_player_sprite\n'+t[b:]
   old='    ldy INVINCIBILITY_TIMER,x\n    beq @set_player_recoil_and_bg_priority'
   new='    ldy INVINCIBILITY_TIMER,x\n    bne @native_protection_palette\n    ldy NEW_LIFE_INVINCIBILITY_TIMER,x\n    beq @set_player_recoil_and_bg_priority'
   assert t.count(old)==1
   t=t.replace(old,new)
   old='    lda #$04                               ; a = #$04 (sprite code palette override bit)'
   assert t.count(old)==1
   t=t.replace(old,'@native_protection_palette:\n'+old)
  if bank==7:
   # No music: tunes $26..$51, the pause jingle $54 and the boss-destroyed
   # fanfare $57..$59 are dropped; sound effects remain.
   t=t.replace('play_sound:\n', 'play_sound:\n    cmp #$26\n    bcc @native_sfx\n    cmp #$52\n    bcc @no_music\n    cmp #$54\n    beq @no_music\n    cmp #$57\n    bcc @native_sfx\n    cmp #$5a\n    bcs @native_sfx\n@no_music:\n    lda NMI_CHECK\n    and #$7f\n    rts\n@native_sfx:\n')
   t=t.replace('forever_loop:\n',f'forever_loop:\n    jsr ${vector("render_idle"):04x}\n')
   t=t.replace('sta prg_rom_banks,y',f'jsr ${vector("bank_a"):04x}')
   a=t.index('\nread_controller_state:');b=t.index('; decrements intro theme',a)
   t=t[:a]+f'\nread_controller_state:\n    jmp ${vector("controller_read"):04x}\n\n'+t[b:]
  # Some upstream sound writes use numeric operands instead of APU symbols.
  t=re.sub(r"^(\s*(?:sta|stx|sty|lda|ldx|ldy)\s+)\$40([01][0-9a-f])\b",r"\g<1>$0a\2",t,flags=re.M)
  def patch(m):
   op,reg=m.group(1),m.group(2)
   assert op in ('sta','lda','stx','sty'),(op,reg)
   name=regs[reg]
   if reg=='PPUDATA':name={'sta':'ppu_w_a','stx':'ppu_w_x','sty':'ppu_w_y','lda':'ppu_r_a'}[op]
   else:assert (op=='lda')==(reg=='PPUSTATUS'),(op,reg)
   counts[name]=counts.get(name,0)+1
   return f'    jsr ${vector(name):04x}'
  t=re.sub(r'^\s*(\w+)\s+(PPUCTRL|PPUMASK|PPUADDR|PPUSCROLL|PPUSTATUS|PPUDATA)\b',patch,t,flags=re.M)
  t=re.sub(r'\bsta APU_PULSE_LENGTH,([xy])',lambda m:f'jsr ${vector("apu_length_"+m[1]):04x}',t)
  p.write_text(t)
 cfg=(ROOT/'upstream/contra.cfg').read_text()
 for a,b in [('C000','4000'),('FC00','7C00'),('FFD0','7FD0'),('FFFA','7FFA')]:cfg=cfg.replace('$'+a,'$'+b)
 (GEN/'contra.cfg').write_text(cfg)
 names=['ram','constants','ines_header']+[f'bank{i}' for i in range(8)]
 for n in names:run([CA65,'-D','Contra','--debug-info','-o',GEN/f'{n}.o',gs/f'{n}.asm'])
 run([LD65,'-C',GEN/'contra.cfg','--dbgfile',GEN/'contra.dbg','-Ln',GEN/'nes.lab','-o',GEN/'contra.bin']+[GEN/f'{n}.o' for n in names])
 nl=labels(GEN/'nes.lab')
 (GEN/'nes-labels.asm').write_text(f'NES_NMI = ${nl["NMI_START"]:04x}\nNES_RESET = ${nl["RESET_VECTOR"]:04x}\n')
 # Label every actual VBXE operand for runtime D600/D700 relocation.
 sites=[]
 for n in ['runtime.asm','render.asm','services.asm']:
  p=SRC/n;t=p.read_text();lines=t.splitlines()
  for i,l in enumerate(lines):
   if re.search(r'\b(?:sta|lda|ldx|ldy|stx|sty) VBX\+',l):
    label=l.split()[0] if not l.startswith(' ') else f'vbauto_{len(sites)}'
    if l.startswith(' '):raise RuntimeError(f'{n}: label this VBXE operand before building: {l}')
    sites.append(label+'+2')

 assert len(sites)<127
 (GEN/'vbxe-sites.asm').write_text(''.join('        dta a('+','.join(sites[i:i+6])+')\n' for i in range(0,len(sites),6))+'        dta a(0)\n')
 # Precompute the 11-bit NES timer conversion for both video standards.
 pitch=bytearray()
 for k in (145,146):
  for octave in (0,1):
   for timer in range(2048):
    divider=((timer+1)*k) >> (9-octave)
    while divider>256:divider >>= 1
    pitch.append(max(0,divider-1))
 (GEN/'pitch.bin').write_bytes(pitch)
 print(run([MADS,'runtime.asm','-o:../gen/runtime.obx','-l:../gen/runtime.lst','-t:../gen/runtime.lab'],SRC))
 ram=bytearray(65536)
 for a,d in segments((GEN/'runtime.obx').read_bytes()):
  assert a>=0x0a00 and not (a<0xd800 and a+len(d)>0xd000)
  ram[a:a+len(d)]=d
 game=(GEN/'contra.bin').read_bytes();assert len(game)==131088,len(game)
 ram[0x4000:0x8000]=game[16+7*16384:]
 lab=labels(GEN/'runtime.lab');(GEN/'boot-defs.asm').write_text(f'RT_START = ${lab["START"]:04x}\n')
 run([MADS,'boot-main.asm','-o:../gen/boot.obx','-t:../gen/boot.lab'],SRC)
 bl=labels(GEN/'boot.lab');out=bytearray(b'\xff\xff')
 for a,d in segments((GEN/'boot.obx').read_bytes()):out+=seg(a,d)
 out+=seg(0x2e2,bl['DETECT'].to_bytes(2,'little'))
 payload=[(0,game[16:16+7*16384]),(0x40000,ram),(0x60000,bytes(8192))]
 for v,d in payload:
  for off in range(0,len(d),4096):
   out+=seg(0x7ffd,(v+off).to_bytes(3,'little')+d[off:off+4096].ljust(4096,b'\0'))
   out+=seg(0x2e2,bl['UPLOAD'].to_bytes(2,'little'))
 out+=seg(0x2e0,bl['STARTER'].to_bytes(2,'little'));(ROOT/'contra.xex').write_bytes(out)
 (ROOT/'contra.sha256').write_text(hashlib.sha256(out).hexdigest()+'  contra.xex\n')
 (GEN/'build-report.json').write_text(json.dumps({'register_calls':counts,'xex_bytes':len(out),'sha256':hashlib.sha256(out).hexdigest()},indent=2)+'\n')
 print('contra.xex:',len(out),'bytes; fixed NES bank relocated to $4000-$7FFF')
if __name__=='__main__':main()
