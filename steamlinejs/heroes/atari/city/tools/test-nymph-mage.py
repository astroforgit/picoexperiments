"""Exercise enchantment directly in the assembled 6502 game on both VBXE mappings."""
import importlib.util
from pathlib import Path
sp=importlib.util.spec_from_file_location('runtime',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
for page in (0xd600,0xd700):
 m=r.Machine(page)
 def put(name,i,value):m.mem.ram[r.LABELS['battle.'+name]+i]=value
 def get(name,i):return m.mem.ram[r.LABELS['battle.'+name]+i]
 def attack(a,b):
  m.put('battle.attacker_unit',a);m.put('battle.defender_unit',b);m.put('battle.attack_bonus',0);m.call('battle.attack_units')
 m.put('battle.unit_count',4);m.put('battle.hero_count',2);m.put('battle.turn_number',1)
 for i in range(4):
  put('unit_type',i,0 if i<2 else 28);put('unit_team',i,0 if i<2 else 1);put('unit_hp',i,4);put('unit_charmed',i,0);put('unit_cell',i,i)
 for i in range(2):put('hero_army_slot',i,i)
 attack(2,0);assert get('unit_hp',0)==4 and get('unit_team',0)==1 and get('unit_charmed',0)==3
 assert get('unit_spawned',0)==1 and get('unit_move_left',0)==0
 attack(2,1);assert get('unit_team',1)==0 and get('unit_hp',1)==4 and get('unit_charmed',1)==0
 attack(3,1);assert get('unit_charmed',1)==4
 put('unit_hp',2,1);attack(1,2)
 assert get('unit_hp',0)==4 and get('unit_team',0)==0 and get('unit_charmed',0)==0
 assert get('unit_team',1)==1 and get('unit_charmed',1)==4
 assert get('unit_acted',0)==1 and get('unit_move_left',0)==0
 put('unit_hp',3,1);attack(0,3);assert get('unit_team',1)==0 and get('unit_charmed',1)==0
 # Charmed deaths still remove the real soldier from the campaign army.
 put('unit_hp',2,4);attack(2,0);put('unit_hp',0,1);put('unit_type',3,29);put('unit_hp',3,6);attack(3,0)
 assert get('unit_hp',0)==0 and m.mem.ram[r.LABELS['army_units']]==255
 # A dead enchanted fighter frees the owner's capacity.
 put('unit_type',2,28);attack(2,1);assert get('unit_charmed',1)==3
 # Ogre Mage is ordinary magic, not Ogre windup or enchantment.
 assert m.mem.ram[r.LABELS['battle.type_shoot_range']+29]==3
 assert m.mem.ram[r.LABELS['battle.type_ability']+29]==0
 assert m.mem.ram[r.LABELS['battle.type_ability']+28]==7
 print(f'PASS ${page:04X}: zero-damage charm, per-Nymph release, delayed actions, permanent charmed casualty, Ogre Mage type/range.')
 # Check actual enemy movement/action routines over two consecutive turns.
 m.put('battle.unit_count',3);m.put('battle.hero_count',2);m.put('battle.turn_number',1)
 for i,c in enumerate((0,28,6)):
  put('unit_type',i,0 if i<2 else 28);put('unit_team',i,0 if i<2 else 1);put('unit_hp',i,4);put('unit_charmed',i,0);put('unit_mark',i,0);put('unit_charge',i,0);put('unit_cell',i,c)
 def nymph_turn():
  m.put('battle.enemy_id',2);m.put('battle.enemy_actions',5);m.put('battle.enemy_attacked',0)
  m.cpu.x=2;m.cpu.y=28;m.call('battle.nymph_actions')
  for _ in range(m.get('battle.enemy_actions')):
   m.call('battle.enemy_act')
   if m.get('battle.enemy_attacked'):break
 nymph_turn();assert get('unit_cell',2)==3 and get('unit_team',0)==0
 m.put('battle.turn_number',2);nymph_turn()
 assert get('unit_cell',2)==1 and get('unit_charmed',0)==3
 print(f'PASS ${page:04X}: halfway approach then movement and enchantment next turn.')
