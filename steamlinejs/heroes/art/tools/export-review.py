#!/usr/bin/env python3
"""Decode built native indexed VRAM/pose data and capture real 6502-rendered screens."""
from pathlib import Path
import argparse,json,importlib.util,base64,shutil,hashlib
from PIL import Image
p=argparse.ArgumentParser();p.add_argument('--classic',type=Path,required=True);p.add_argument('--new',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
root=Path(__file__).resolve().parents[2];heroNames=['militia','spearman','swordsman','archer','wizard','minibeast','wolf','bat','skeleton','zombie','bone-archer','ogre','warlock','imp','beast','dark','demon','sniper','mounted-scout','mounted-ranger','mounted-cavalry']
items=[];profiles={}
def image(name,size,raw,palette,folder,alpha=False):
 im=Image.frombytes('P',size,bytes(raw));im.putpalette(palette);target=folder/(name+'.png');target.parent.mkdir(parents=True,exist_ok=True);im.save(target,**({'transparency':0} if alpha else {}));return str(target)
def add(id,name,category,paths,size,frames=1):items.append({'id':id,'name':name,'category':category,'paths':paths,'size':size,'frames':frames})
for key,build in [('classic',a.classic),('vbxe-v2',a.new)]:
 folder=a.output/key;folder.mkdir(exist_ok=True);vram=(build/'generated/vram.bin').read_bytes();palette=(build/'generated/palette.bin').read_bytes();layout=json.loads((build/'generated/hero-animation-layout.json').read_text());profile=json.loads((build/'generated/asset-profile.json').read_text());profiles[key]=profile
 def export(name,w,h,address,alpha=False):return image(name,(w,h),vram[address-0x20000:address-0x20000+w*h],palette,folder,alpha)
 export('city-background',320,200,0x20000);export('encounters-background',320,200,0x50000)
 for i,name in enumerate(['forest','catacombs','caves','ruins']):export('battle-'+name,320,128,[0x44000,0x60000,0x6a000,0x74000][i])
 for familyIndex,family in enumerate(['barracks','archery','lodge','chapel','tower']):
  for tier in range(3):
   index=familyIndex*3+tier;g=profile.get('buildingGeometry',[{'x':0,'y':0,'w':56,'h':64}]*15)[index];offset=profile.get('buildingOffsets',[i*3584 for i in range(15)])[index];full=bytearray(56*64)
   for y in range(g['h']):
    start=0x10000+offset+y*g['w'];full[(g['y']+y)*56+g['x']:(g['y']+y)*56+g['x']+g['w']]=vram[start:start+g['w']]
   image(f'{family}-{tier+1}',(56,64),full,palette,folder,True)
 for i,name in enumerate(['tree','pillar','rock']):export('battle-'+name,32,28,0x3f300+i*896,True)
 defs=(build/'generated/hero-animation.inc').read_text();line=next(l for l in defs.splitlines() if l.startswith('hero_palette dta '));palettes=list(map(int,line.split(' dta ')[1].split(',')))
 for i,name in enumerate(heroNames):
  for f in range(6):
   index=i*6+f;start=layout['addresses'][index]-0x20000;packed=vram[start:start+layout['lengths'][index]];pairs=[];j=0
   while packed[j]:
    token=packed[j];j+=1
    if token<128:pairs.extend(packed[j:j+token]);j+=token
    elif token<192:pairs.extend([0]*((token&63)+1))
    else:pairs.extend([packed[j]]*((token&63)+1));j+=1
   assert len(pairs)==448
   indices=bytes(palettes[i*16+n] for byte in pairs for n in (byte>>4,byte&15));image(f'medieval/{name}-{f}',(32,28),indices,palette,folder,True)
 # Capture the assembled program through the existing functional VBXE emulator.
 spec=importlib.util.spec_from_file_location('capture_'+key,build/'tools/test-runtime.py');r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r);m=r.Machine(0xd600)
 def capture(name):m.put('dirty',1);m.screenshot(name+'.png');shutil.copy2(build/'generated'/(name+'.png'),folder/(name+'.png'))
 capture('screen-city-start')
 for tier in [1,2,3]:
  m.mem.ram[r.LABELS['building_levels']:r.LABELS['building_levels']+5]=bytes([tier]*5);m.put('selected_plot',5);capture('screen-city-tier'+str(tier))
 m.call('show_map');capture('screen-map')
 m.mem.ram[r.LABELS['army_units']:r.LABELS['army_units']+5]=bytes([1,4,7,14,2]);m.put('army_count',5);m.mem.ram[r.LABELS['building_levels']+3]=2;m.call('capacity')
 m.mem.ram[r.LABELS['region_wins']:r.LABELS['region_wins']+4]=bytes([3,3,3,3])
 for region,location in enumerate([0,1,2,4]):
  m.put('selected_location',location);m.call('battle.start');capture('screen-battle-'+['forest','catacombs','caves','ruins'][region])
 shutil.copy2(build/'city-vbxe.xex',a.output/('heroes-'+key+'.xex'))
 print('Decoded and captured',key,profile,flush=True)
# Pair matching images for browser A/B review.
for name,title in [('screen-city-start','Town — actual native start'),('screen-city-tier1','Town — all buildings level 1'),('screen-city-tier2','Town — all buildings level 2'),('screen-city-tier3','Town — all buildings level 3'),('screen-map','Encounter map — actual native UI')]+[('screen-battle-'+n,'Battle — '+n) for n in ['forest','catacombs','caves','ruins']]:add(name,title,'Game screens',None,[320,200])
for name,size in [('city-background',[320,200]),('encounters-background',[320,200])]+[('battle-'+n,[320,128]) for n in ['forest','catacombs','caves','ruins']]:add(name,name.replace('-',' ').title(),'Scenery',None,size)
for family in ['barracks','archery','lodge','chapel','tower']:
 for tier in [1,2,3]:add(f'{family}-{tier}',f'{family.title()} level {tier}','Buildings',None,[56,64])
for name in heroNames:add('medieval/'+name,name.replace('-',' ').title(),'Animated fighters',None,[32,28],6)
for name in ['tree','pillar','rock']:add('battle-'+name,name.title(),'Obstacles',None,[32,28])
for item in items:
 item['images']={}
 for key in profiles:
  files=[a.output/key/(item['id']+(f'-{f}' if item['frames']>1 else '')+'.png') for f in range(item['frames'])]
  item['images'][key]=['data:image/png;base64,'+base64.b64encode(file.read_bytes()).decode() for file in files]
(a.output/'comparison-data.json').write_text(json.dumps({'profiles':profiles,'items':items},separators=(',',':')))
