"""Convert all enemy entries in the two local cartridges, excluding their heroes."""
import re
from pathlib import Path

def expand(entries, root):
 configs={
 'BulbaRogue':[(2,1,1,[]),(4,1,2,[]),(7,1,3,[]),(10,2,4,[]),(12,2,5,['stun']),(11,1,6,['paralyze']),(20,3,7,['slow']),(28,3,8,['curse'])],
 'Crocolike':[(2,1,1,[]),(9,1,4,['curse']),(5,1,3,['stun']),(5,1,2,['poison']),(19,3,6,['slow']),(12,2,5,['flee']),(8,1,3,['vampire']),(13,2,5,['steal_item']),(20,2,7,['steal_weapon']),(10,2,4,[]),(26,3,8,['hunter']),(25,3,8,[])]}
 # Preserve catalog keys/slots for the five creatures already included.
 existing={('BulbaRogue',7):'guest-8',('Crocolike',2):'guest-0',('Crocolike',4):'guest-7',('Crocolike',11):'guest-6',('Crocolike',12):'guest-9'}
 palettes=[('3','b','a'),('d','7','c'),('4','9','a'),('3','b','9'),('1','3','b'),('2','c','7'),('1','d','e'),('1','c','6'),('4','f','9'),('5','6','7'),('1','d','8'),('3','b','a')]
 for cart,stats in configs.items():
  text=(root/'allgames'/'[RPG]'/(cart+'.p8')).read_bytes().decode('latin-1')
  names=re.search(r'mob_name=explode\("([^"]+)"',text)[1].split(',')
  bases=list(map(int,re.search(r'mob_ani=explodeval\("([^"]+)"',text)[1].split(',')))
  sheet=text.split('__gfx__\n')[1].split('__')[0].strip().splitlines()
  assert len(names)-1==len(stats)
  for i,(hp,atk,depth,abilities) in enumerate(stats,1):
   key=existing.get((cart,i+1),cart.lower()+'-'+str(i+1))
   frames=[]
   for n in range(bases[i],bases[i]+4):
    x,y=n%16*8,n//16*8
    rows=[r[x:x+8] for r in sheet[y:y+8]]
    if cart=='Crocolike':
     shadow,body,highlight=palettes[i-1]
     rows=[''.join(shadow if c=='2' else (highlight if (x+y)%5==0 else body) if c=='8' else c for x,c in enumerate(r)) for y,r in enumerate(rows)]
    frames.append(rows)
   entry=dict(key=key,name=names[i],hp=hp,atk=atk,depth=depth,abilities=abilities,range=1,sight=4,col=int(palettes[i-1][1],16) if cart=='Crocolike' else 13,from_source=cart+' / '+names[i],source_index=i+1,frames=frames)
   idx=next((k for k,e in enumerate(entries) if e['key']==key),None)
   if idx is None:entries.append(entry)
   else:entries[idx]=entry
 return entries
