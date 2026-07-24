pico-8 cartridge // http://www.pico-8.com
version 5
__lua__
-- by nathaniel nelson
-- global game jam 2016

her_name="claire"
debug_mode=false

function split(message)
 local lines={}
 local line_no=1
 local line_start=1
 for i=1,#message do
  if sub(message,i,i)=="\n" or i==#message then
   lines[line_no]=sub(message,line_start,i)
    
   line_no+=1
   line_start=i+1
  end
 end
 return lines
end

function distance(entity_a,entity_b)
 local a_x=entity_a.x+4
 local a_y=entity_a.y+4
 local b_x=entity_b.x+4
 local b_y=entity_b.y+4
 local dx=a_x-b_x
 local dy=a_y-b_y
 
 return sqrt(dx*dx+dy*dy)
end

function pt_distance(a_x,a_y,b_x,b_y)
 local dx=a_x-b_x
 local dy=a_y-b_y
 
 return sqrt(dx*dx+dy*dy)
end

function init_flags()
 flags={}
 for x=1,8 do
  flags[x]={}
  for y=1,8 do
   flags[x][y]=0
  end
 end
end

function set_flag(x,y,val)
 flags[x][y]=val
end

function get_flag(x,y)
 return flags[x][y]
end

function is_flag_set(x,y)
 return flags[x][y]~=0
end

function make_dialog(sprite,message)
 has_dialog=true
 
 dialogs={}
 dialogs[1]={}
 dialogs[1].sprite=sprite
 dialogs[1].message=message
 
 dialog_index=1
end

function chain_dialogs(new_dialogs)
 has_dialog=true
 
 dialogs={}
 
 for i=1,#new_dialogs do
  dialogs[i]=new_dialogs[i]
 end
 
 dialog_index=1
end

function set_viewport(vw,vh)
 viewport_width=vw
 viewport_height=vh
end

function set_map(cellx,celly,width,height,wall_tiles)
 has_map=true
 map_x=cellx
 map_y=celly
 map_width=width
 map_height=height
 map_wall_tiles=wall_tiles
 
 --lock the viewport to the map bounds
 set_viewport(width*8,height*8)
end

function one_time_dialog(x,y,sprite,message)
 if not is_flag_set(x,y) then
  make_dialog(sprite,message)
  set_flag(x,y,1)
 end
end

function one_time_chain_dialogs(x,y,dialogs)
 if not is_flag_set(x,y) then
  chain_dialogs(dialogs)
  set_flag(x,y,1)
 end
end

function entrance_event()
 local dialogs={}
 for i=1,4 do
  dialogs[i]={}
  dialogs[i].sprite=064
 end
 dialogs[1].message="phew!\n\nat last,i've arrived at\nthe great witch's tower."
 dialogs[2].message="if she accepts me as her\napprentice,i'll be the first\nfrom my village to practice\nmagic!"
 dialogs[3].message="how proud mother would be\nif she could see me now."
 dialogs[4].message="i just hope the witch will\nhonor my scroll from the\nvillage elder."
 one_time_chain_dialogs(1,1,dialogs)
end

function saw_witch_event()
 local dialogs={}
 for i=1,2 do
  dialogs[i]={}
  dialogs[i].sprite=064
 end
 dialogs[1].message="oh my god! it's the witch.\n\nthe stories are true!"
 dialogs[2].message="i just need to show her\nthe scroll and she might\ntake me on!"
 dialogs[3]={}
 dialogs[3].sprite=068
 dialogs[3].message="hm... it'll have to boil...\nneeds fire..."
 one_time_chain_dialogs(1,2,dialogs)
end

function map_to_screen(x,y)
 x-=level.map.cellx
 y-=level.map.celly
 x*=8
 y*=8
 
 return x,y
end

function witch_talk_event()
 sfx(01)
 local state=get_flag(1,3)
 if state==0 then
  --first time talking to witch
  make_dialog(068,"who are you? i've no time\nfor visitors until the\nritual is complete!")
 elseif state==1 then
  --already read the witch the first scroll
  make_dialog(065,"move along now! bring\nthe serpent's root.")
 elseif state==2 then
  --already gave root
  make_dialog(065,"what now? don't return\nagain without my knife.")
 elseif state==3 then
  make_dialog(065,"pfah! i need a goblin\npower crystal.")
 elseif is_flag_set(5,2) then
  make_dialog(067,"yes! yes! give me the\ncrystal!")
 elseif state==4 then
  make_dialog(067,"do not return without\nanother crystal.")
 end
end

function hopeful_tune()
 sfx(00)
end

function tower_create_entities()
 close_portal()
 
 local x,y=map_to_screen(17,21)
 witch=static_entity(010,x,y)
 witch.name="great witch"
 entity_set_direction(witch,"up")
 entity_set_use_event(witch,witch_talk_event,"talk")
 npcs[1]=witch
end

function give_root()
 if witch then
  --give witch the root
  if distance(witch,player)<40 then
   local dialogs={}
   for i=1,11 do
    dialogs[i]={}
   end
   dialogs[1].sprite=065
   dialogs[1].message="ah, there it is, good..."
   dialogs[2].sprite=064
   dialogs[2].message="hey, maybe it's weird to ask\nbut a bunch of rats died\nwhen i picked the root."
   dialogs[3].sprite=068
   dialogs[3].message="ah yes, another experiment\nof mine... forming\nirreversible biological\ndependencies of animals\non plant matter..."
   dialogs[4].sprite=064
   dialogs[4].message="oh... um... okay..."
   dialogs[5].sprite=064
   dialogs[5].message="..."
   dialogs[6].sprite=064
   dialogs[6].message="*ahem*"
   dialogs[7].sprite=064
   dialogs[7].message="i would like to become\nyour apprentice!"
   dialogs[7].event=hopeful_tune
   dialogs[8].sprite=068
   dialogs[8].message="hm...yes of course..."
   dialogs[9].sprite=068
   dialogs[9].message="to complete the ritual i'll\nneed my alchemical knife\nback."
   dialogs[10].sprite=068
   dialogs[10].message="a demon stole my knife.\nit's locked away in the\ndungeon. bring it to me."
   dialogs[10].event=open_portal
   dialogs[11].sprite=064
   dialogs[11].message="um... okay."
   
   chain_dialogs(dialogs)
   set_flag(1,3,2)
   take_item(1)
  --can't give the witch the root
  else
   make_dialog(064,"to whom?")
  end
 end
end

function pick_root()
 del(npcs,root)
 
 inventory[1].name="serpent's root"
 inventory[1].event=give_root
 inventory[1].action="give"
 inventory[1].sprite=111
 
 give_item(1)
 set_flag(2,1,1)
 
 make_dialog(064,"oh god! the rats won't stop\nscreeching! they're all\ndropping dead without the\nplant!")
 
 --make half the rats move very slowly
 for i=1,15 do
  if flr(rnd(2))~=0 then
   npcs[i].speed/=5
  else
   --and the other half stop
   npcs[i].speed=0
  end
 end
 
end

function rat_routine(rat)
 entity_set_state(rat,1)
 
 rat.elapsed_walk+=1
 if pt_distance(rat.x,rat.y,rat.start_x,rat.start_y)>100 or rat.elapsed_walk>rat.turn_time then
  rat.elapsed_walk=0
  if rat.direction=="left" then
   entity_set_direction(rat,"right")
  elseif rat.direction=="right" then
   entity_set_direction(rat,"left")
  elseif rat.direction=="up" then
   entity_set_direction(rat,"down")
  else
   entity_set_direction(rat,"up")
  end
 end 
end

function cave_create_entities()
 local x,y=map_to_screen(56,20)
 root=static_entity(111,x,y)
 root.name="serpent's root"
 entity_set_use_event(root,pick_root,"pick")
 npcs[1]=root
 
 --create 15 rats
 for i=1,15 do
  local x,y=map_to_screen(56,21)
  x+=rnd(24)-12
  y+=rnd(24)-12
  
  local speed=30
  speed+=rnd(8)-4
  local rat=init_entity(006,15,speed,x,y)
  entity_set_routine(rat,rat_routine)
  rat.start_x=x
  rat.start_y=y
  rat.elapsed_walk=0
  rat.turn_time=25+flr(rnd(20))-10
  
  local dirnum=flr(rnd(4))
  if dirnum==0 then
   entity_set_direction(rat,"left")
  elseif dirnum==1 then
   entity_set_direction(rat,"right")
  elseif dirnum==2 then
   entity_set_direction(rat,"up")
  else
   entity_set_direction(rat,"down")
  end
  
  add(npcs,rat)
 end
end

function portal_from_cave()
 sfx(06)
 if is_flag_set(2,1) then
  levels.tower.map.playerx=17
  levels.tower.map.playery=18
  set_level("tower")
 else
  --can't leave
  make_dialog(064,"weird...the portal won't let\nme go back without the\n\"serpent's root.\"")
  set_level("cave")
 end
end

function see_rats()
 local dialogs={}
 for i=1,3 do
  dialogs[i]={}
  dialogs[i].sprite=064
 end
 dialogs[1].message="ick! this cave is full of\nrats!"
 dialogs[2].message="i think i see the\nserpent's root!"
 dialogs[3].message="are they eating it? gross!"
 one_time_chain_dialogs(2,2,dialogs)
end

function give_knife()
 if witch and distance(player,witch)<40 then
  --give the knife to the witch
  take_item(1)
  set_flag(1,3,3)
  
  local dialogs={}
  for i=1,6 do
   dialogs[i]={}
  end
  dialogs[1].sprite=065
  dialogs[1].message="yes! my very special very\nimportant alchemical knife!"
  dialogs[2].sprite=068
  dialogs[2].message="the ritual is almost\ncomplete... yes..."
  dialogs[3].sprite=064
  dialogs[3].message="um... i just released a\nmurderous demon. we're sworn\nto protect the land. should\nwe do something about that?"
  dialogs[4].sprite=067
  dialogs[4].message="what would you know about\nsuch matters? the ritual\nmust be completed for the\ncontinued survival of the\nrealm!"
  dialogs[5].sprite=068
  dialogs[5].message="i need a goblin-forged\npower crystal for the final\nstep."
  dialogs[6].sprite=065
  dialogs[6].message="take this wand. the\ngoblins will not surrender\nthe crystal easily. give them\na little... scare...\nif you must."
  dialogs[6].event=open_portal
  
  give_item(2)
  chain_dialogs(dialogs)
 else
  make_dialog(064,"to whom?")
 end
end

function approach_demon()
 local dialogs={}
 for i=1,10 do
  dialogs[i]={}
 end
 dialogs[1].sprite=015
 dialogs[1].message="..."
 dialogs[2].sprite=064
 dialogs[2].message="i don't see any demon."
 dialogs[3].sprite=081
 dialogs[3].message="oh. another human."
 dialogs[4].sprite=081
 dialogs[4].message="here to taunt me more?\ni know i cannot defeat\nthe witch. i'm only alive\nbecause i have this dagger\nhere."
 dialogs[5].sprite=064
 dialogs[5].message="am i here to *taunt* you?\n\nwhat? why did the witch\nimprison you here?"
 dialogs[6].sprite=081
 dialogs[6].message="ha. she was lonely. too\npowerful to enjoy the\ncompany of other humans."
 dialogs[7].sprite=081
 dialogs[7].message="she summoned me, the most\nknowledgeable spirit of this\nrealm, for the sake of\nsimple conversation."
 dialogs[8].sprite=081
 dialogs[8].message="when i suggested she\ngo outside the tower and\nmake friends every once in\na while, she tried to kill\nme."
 dialogs[9].sprite=081
 dialogs[9].message="she spared my life when i\nthreatened to destroy this\nworthless cooking knife."
 dialogs[10].sprite=081
 dialogs[10].message="let me out and you can have\nit. i won't even kill you.\nplenty of nearby villages to\nquench my thirst, anyway."
 one_time_chain_dialogs(3,2,dialogs)
end

ticks_per_move=1
demon_pause=15
function update_cell_screen()
 screen.t+=1
 
 if screen.t==demon_pause then
  sfx(05,3)
 end
 
 local ticks_to_open=112*ticks_per_move
 if screen.t-demon_pause==ticks_to_open then
  sfx(-1,3)
 end
 
 if screen.t>=112*ticks_per_move+demon_pause*5 then
  --return to game
  screen=temp_screen
 end
end

function draw_cell_screen()
 --draw the two red eyes center
 local y=48
 local sz=14
 rectfill(64-sz*2,y-sz/2,64-sz,y+sz/2,8)
 rectfill(64+sz,y-sz/2,64+sz*2,y+sz/2,8)

 local pause=demon_pause
 local x=0
 if screen.t>pause then
  x+=(screen.t-pause)/ticks_per_move
  x=min(x,112)
 end
 
 --draw bars
 local thickness=10
 local lock_height=24
 local lock_width=thickness*3
 --vertical bars
 for i=0,4 do
  rectfill(x+i*thickness*3,0,(x+thickness+i*thickness*3),127,13)
 end
 --gold lock
 local lock_y=72
 rectfill(x+thickness,lock_y-lock_height/2,x+lock_width,lock_y+lock_height/2,9)
 rectfill(x+thickness+6,lock_y-lock_height/2+4,x+lock_width-6,lock_y+lock_height/2-12,4)
 rectfill(x+thickness+8,lock_y-lock_height/2+4,x+lock_width-8,lock_y+lock_height/2-4,4)
 --top
 rectfill(x,0,x+127,thickness,13)
 --bottom
 rectfill(x,127-thickness,x+127,127,13)
end

function new_cell_screen()
 local cell_screen={}
 cell_screen.update=update_cell_screen
 cell_screen.draw=draw_cell_screen
 cell_screen.t=0
 return cell_screen
end

function later_talk_demon()
 --i just loooove killin'
 local dialogs={}
 for i=1,3 do
  dialogs[i]={}
 end
 
 dialogs[1].sprite=082
 dialogs[1].message="soon as night falls outside\nthe tower, i'll get back to\nkilling innocents and\ntorturing their eternal souls."
 dialogs[2].sprite=083
 dialogs[2].message=":d"
 dialogs[3].sprite=069
 dialogs[3].message="..."
 chain_dialogs(dialogs)
end

function open_bars()
 mset(38,52,090)
 --create the animated demon with trickery
 local demon=init_entity(065,15,0,map_to_screen(39.5,52))
 entity_set_direction(demon,"up")
 entity_set_state(demon,1)
 entity_set_use_event(demon,later_talk_demon,"talk")
 demon.name="demon"
 demon.use_distance=24
 add(npcs,demon)
 
 temp_screen=screen
 screen=new_cell_screen()
end

function get_knife()
 give_item(1)
end

function release_demon()
 local dialogs={}
 for i=1,4 do
  dialogs[i]={}
  dialogs[i].sprite=081
  if i>=2 then
   dialogs[i].sprite=082
  end
 end
 dialogs[1].sprite=064
 dialogs[1].message="looks like i have no\nother choice...\n\nhere goes."
 
 dialogs[2].event=open_bars
 dialogs[2].message="ahhh. thank you."
 dialogs[3].message="i'm a demon of my word.\nhere's the knife."
 dialogs[3].event=get_knife
 dialogs[4].message="give my best to the witch.\nmay she rot forever in\nhell."
 
 chain_dialogs(dialogs)
 
 --give the knife
 inventory[1].name="alchemical knife"
 inventory[1].action="give"
 inventory[1].event=give_knife
 inventory[1].sprite=095
 set_flag(3,3,1)
 
 --remove the demon
 del(npcs,demon)
end

function dungeon_create_entities()
 local x,y=map_to_screen(38,52)
 demon=static_entity(015,x,y)
 demon.name="demon"
 entity_set_use_event(demon,release_demon,"release")
 npcs[1]=demon
end

function enter_dungeon()
 one_time_dialog(3,1,064,"i wonder why the great witch\nhas a dungeon. good thing\nmost of the cells are empty.")
end

function portal_from_dungeon()
 sfx(06)
 if is_flag_set(3,3) then
  set_level("tower")
 else
  set_level("dungeon")
  make_dialog(064,"the portal won't let me\nenter without the knife.")
 end
end

function portal_from_goblins()
 sfx(06)
 if get_flag(1,3)~=4 then
  if is_flag_set(4,1) then
   goblin=nil
   set_level("tower")
  else
   make_dialog(064,"of course. i literally\ncannot go back without the\ncrystal the witch wants.")
   set_level("goblins")
  end
 else
  if is_flag_set(5,2) then
   set_level("tower")
  else
   make_dialog(067,"do not return without a\nnew crystal!")
   set_level("goblins")
  end
 end
end

function talk_to_goblin()
 local dialogs={}
 for i=1,6 do
  dialogs[i]={}
  dialogs[i].sprite=080
 end
 
 dialogs[1].message="how the hell did you get\nin here?!"
 dialogs[2].message="the witch sent you? for a\npower crystal?"
 dialogs[3].message="i can't let you have it.\nthese crystals power the\nmagic shields which defend our\ncamp from the dismemberment\nworms."
 dialogs[4].message="without these crystals my\nentire family would be\nbrutally devoured."
 dialogs[5].message="the colony only has 2 left\nand i've been trusted to\ndefend this one with my life."
 dialogs[6].message="you seem reasonable. i'm\nsure you understand."
 
 chain_dialogs(dialogs)
 set_flag(4,2,1)
end

function goblin_mob()
 if not is_flag_set(5,1) then
  --mob repel dialog
  make_dialog(097,"we will not let you take\nour last crystal!!")
 
  sfx(01)
  set_level("goblins")
 end
end

function init_crystal(x,y)
 local e=static_entity(017,x,y)
 e.name="power crystal"
 entity_set_use_event(e,take_crystal,"take")
 return e
end

function goblins_create_entities()
 if is_flag_set(4,1) then
  --second visit
  --create goblin mob
  for i=1,15 do
   local sprindex=000
   sprindex+=flr(rnd(2))
   local x,y=map_to_screen(71,53)
   x+=rnd(60)-30
   y+=rnd(60)-30
   npcs[i+1]=static_entity(sprindex,x,y)
  end
  --put a crystal at the center
  crystal=init_crystal(map_to_screen(71,53))
  npcs[1]=crystal
  --add goblin mob encounter zone
  local zone={}
  zone.x=67
  zone.y=51
  zone.width=7
  zone.height=5
  zone.event=goblin_mob
  level.event_zones[2]=zone
 else
  --first visit
  local x,y=map_to_screen(69,53)
  goblin=static_entity(001,x,y)
  goblin.name="goblin"
  entity_set_use_event(goblin,talk_to_goblin,"talk")
  npcs[1]=goblin
 end
end

function leave_tower()
 if is_flag_set(1,3,5) then
  one_time_dialog(6,1,064,"nothing to do now but to\ngo home.")
  player=nil
  game_over=true
 end
end

function init_levels()
 local tower_wall_tiles={43,44,45,46,29,59,60,61,62,30,14,11,12,27,28}

 --tower level
 local tower={}
 
  --map
  tower.map={}
  tower.map.cellx=7
  tower.map.celly=5
  tower.map.width=20
  tower.map.height=36
  tower.map.wall_tiles=tower_wall_tiles
  tower.map.playerx=17
  tower.map.playery=36
  
  tower.create_entities=tower_create_entities
 
  --hot zones
  tower.event_zones={}
  --tower arrival
  local zone={}
  zone.x=16
  zone.y=35
  zone.width=3
  zone.height=1
  zone.event=entrance_event
  tower.event_zones[1]=zone
  --see the witch
  zone={}
  zone.x=15
  zone.y=26
  zone.width=5
  zone.height=1
  zone.event=saw_witch_event
  tower.event_zones[2]=zone
  --leave the tower
  zone={}
  zone.x=16
  zone.y=36
  zone.width=3
  zone.height=1
  zone.event=leave_tower
  add(tower.event_zones,zone)
 
 --cave level
 local cave={}
 
 local cave_wall_tiles={115}
  --map
  cave.map={}
  cave.map.cellx=41
  cave.map.celly=8
  cave.map.width=33
  cave.map.height=27
  cave.map.playerx=54
  cave.map.playery=25
  cave.map.wall_tiles=cave_wall_tiles
 
  cave.create_entities=cave_create_entities
  
  cave.event_zones={}
  --portal
  zone={}
  zone.x=54
  zone.y=26
  zone.width=1
  zone.height=1
  zone.event=portal_from_cave
  cave.event_zones[1]=zone
  --scurrying rats and see the weed
  zone={}
  zone.x=54
  zone.y=20
  zone.width=6
  zone.height=4
  zone.event=see_rats
  cave.event_zones[2]=zone
 
 --dungeon level
 local dungeon={}
  local dungeon_wall_tiles={119,121,073,105,104,089,088,090}
  dungeon.map={}
  dungeon.map.cellx=24
  dungeon.map.celly=40
  dungeon.map.width=24
  dungeon.map.height=24 
  dungeon.map.playerx=36
  dungeon.map.playery=59
  dungeon.map.wall_tiles=dungeon_wall_tiles
  dungeon.create_entities=dungeon_create_entities
  dungeon.event_zones={}
  --portal
  zone={}
  zone.x=36
  zone.y=60
  zone.width=1
  zone.height=1
  zone.event=portal_from_dungeon
  dungeon.event_zones[1]=zone
  --look in another cell
  zone={}
  zone.x=36
  zone.y=58
  zone.width=2
  zone.height=1
  zone.event=enter_dungeon
  dungeon.event_zones[2]=zone
  --demon calls out to you
  zone={}
  zone.x=36
  zone.y=54
  zone.width=2
  zone.height=1
  zone.event=approach_demon
  dungeon.event_zones[3]=zone
  
 local goblins={}
  goblins.map={}
  goblins.map.cellx=58
  goblins.map.celly=47
  goblins.map.width=24
  goblins.map.height=16
  goblins.map.playerx=61
  goblins.map.playery=50
  goblins.map.wall_tiles=cave_wall_tiles
 
  goblins.create_entities=goblins_create_entities
  goblins.event_zones={}
  --portal
  zone={}
  zone.x=60
  zone.y=49
  zone.width=1
  zone.height=1
  zone.event=portal_from_goblins
  goblins.event_zones[1]=zone
 
 levels={}
 levels.tower=tower
 levels.cave=cave
 levels.dungeon=dungeon
 levels.goblins=goblins
end

function set_level(level_name)
 level=levels[level_name]
 
 local m=level.map
 set_map(m.cellx,m.celly,m.width,m.height,m.wall_tiles)
 
 player.x,player.y=map_to_screen(m.playerx,m.playery)
 camera_set_position(player.x+4,player.y+4)
 
 if level==levels.goblins and is_flag_set(5,1) then
  --don't create new entities in the goblin cave if they've been genocided
 else
  npcs={}
  --in case of debug trickery
  witch=nil
  goblin=nil
  level.create_entities()
 end
end

function camera_set_position(x,y)
 x=max(x,64)
 y=max(y,64)
 x=min(x,viewport_width-64)
 y=min(y,viewport_height-64)
 camera_x=x
 camera_y=y
end

function entity_reset_animation(entity,ticks_per_frame)
 entity.elapsed_ticks=0
 entity.current_frame=0
end

function entity_set_direction(entity,direction)
 entity.direction=direction
end

function entity_set_state(entity,state)
 entity.state=state
end

function entity_set_routine(entity,routine)
 entity.has_routine=true
 entity.routine=routine
end

function entity_set_use_event(entity,event,name)
 entity.has_use_event=true
 entity.use_event=event
 entity.use_event_name=name
end

function map_get_tile(x,y)
 local px=flr(x)
 local py=flr(y)
 local cx=flr(px/8)
 local cy=flr(py/8)
 
 return mget(map_x+cx,map_y+cy)
end

function is_wall(x,y)
 tile=map_get_tile(x,y)

 for i=1,#map_wall_tiles do
  if map_wall_tiles[i]==tile then
   return true
  end
 end
 
 return false
end

function map_wall_collision(entity)
 if entity.static then return false end
 
 if is_wall(entity.x,entity.y) then
  return true
 end
 if is_wall(entity.x+7,entity.y) then
  return true
 end
 if is_wall(entity.x,entity.y+7) then
  return true
 end
 if is_wall(entity.x+7,entity.y+7) then
  return true
 end
 
 return false
end

function static_entity(sprite,x,y)
 local entity={}
 
 --same value for *most* entities
 entity.use_distance=12
 
  entity.static=true
  entity.x=x
  entity.y=y
  entity.sprite=sprite
 
 return entity
end

function init_entity(first_sprite,ticks_per_frame,speed,x,y)
 local entity={}
 
 --same value for *most* entities
 entity.use_distance=12
 
  --first column of sprites for reference
 local l=first_sprite
 local u=l+16
 local r=u+16
 local d=r+16
 
 --stationary sprite indices
 entity.sprites={}
 
 entity.sprites.left=l
 entity.sprites.up=u
 entity.sprites.right=r
 entity.sprites.down=d

 --movement animation sprite indices
 entity.animations={}
 
 entity.animations.left={}
 entity.animations.left[0]=l+1
 entity.animations.left[1]=l+2
 
 entity.animations.up={}
 entity.animations.up[0]=u+1
 entity.animations.up[1]=u+2
 
 entity.animations.right={}
 entity.animations.right[0]=r+1
 entity.animations.right[1]=r+2
 
 entity.animations.down={}
 entity.animations.down[0]=d+1
 entity.animations.down[1]=d+2
  
 --animation state
 entity_reset_animation(entity)
 entity.ticks_per_frame=ticks_per_frame
 entity.frames=2
 
 --position
 entity.speed=speed
 entity.x=x
 entity.y=y
 
 --initial state: standing
 entity.state=0
 entity.direction="left"
 
 entity.has_use_event=false
 entity.has_routine=false

 return entity
end

function update_entity(entity)
 if entity.state==1 then 
  --update the animation
  entity.elapsed_ticks+=1
  if entity.elapsed_ticks>=entity.ticks_per_frame then
   entity.current_frame+=1
   entity.current_frame%=entity.frames
   entity.elapsed_ticks=0
  end
  
  --update movement
  local oldx=flr(entity.x)
  local oldy=flr(entity.y)
  local dx=0
  local dy=0
  
  if entity.direction=="left" then
   dx=-1
  elseif entity.direction=="right" then
   dx=1
  elseif entity.direction=="up" then
   dy=-1
  elseif entity.direction=="down" then
   dy=1
  end
  dx*=entity.speed/30
  dy*=entity.speed/30
  
  entity.x+=dx
  entity.y+=dy
  
  --collide entity with walls
  if map_wall_collision(entity) then
   entity.x=oldx
   entity.y=oldy
  end
  
  if entity.x<0 or entity.y<0 or entity.x+8>level.map.width*8 or entity.y+8>level.map.height*8 then
   entity.x=oldx
   entity.y=oldy
  end
 end
 --run the entity's routine
 if entity.has_routine then
  entity.routine(entity)
 end
end

function draw_entity(entity)
 local sprite_index=000
 
 --static entity
 if entity.static then
  sprite_index=entity.sprite
 --animated entity
 else
  --state 0: standing
  if entity.state==0 then
   --draw stationary sprite
   sprite_index=entity.sprites[entity.direction]
  --state 1: moving
  elseif entity.state==1 then
   --draw movement animation
   sprite_index=entity.animations[entity.direction][entity.current_frame]
  end
 end
 
 spr(sprite_index,entity.x,entity.y)
end

function player_routine(player)
 entity_set_state(player,1)
 local d=player.direction
 if btn(0) then
  d="left"
 elseif btn(1) then
  d="right"
 elseif btn(2) then
  d="up"
 elseif btn(3) then
  d="down"
 else
  entity_set_state(player,0)
  entity_reset_animation(player)
 end
 
 entity_set_direction(player,d)
 
 --check overlap with event zones
 if has_map then
  local first_level=level
  for i=1,#level.event_zones do
   if level~=first_level then
    break
   end
   local zone=level.event_zones[i]
   local tile_x=(player.x+4)/8
   local tile_y=(player.y+4)/8
   
   local x=zone.x-level.map.cellx
   local y=zone.y-level.map.celly
   
   if tile_x>x and tile_x<x+zone.width and tile_y>y and tile_y<y+zone.height then
    zone.event()
   end
   
  end
 end
 
 camera_set_position(player.x+4,player.y+4)
end

function init_player()
 player=init_entity(003,15,40,64,64)
 entity_set_routine(player,player_routine)
end

function portal_from_tower()
 sfx(06)
 witch=nil
 local state=get_flag(1,3)
 if state==1 then
  set_level("cave")
 elseif state==2 then
  set_level("dungeon")
 else
  set_level("goblins")
 end
end

function light_fire()
 mset(17,20,014)
 mset(17,19,013)
 sfx(02)
end

function open_portal()
 sfx(03)
 mset(17,17,058)
  
 local zone={}
 zone.x=17
 zone.y=17
 zone.width=1
 zone.height=1
 zone.event=portal_from_tower
 add(level.event_zones,zone)
 tower_portal_zone=zone
end

function close_portal()
 if tower_portal_zone then
  mset(17,17,063)
  del(level.event_zones,tower_portal_zone)
  tower_portal_zone=nil
 end
end

function read_letter()
 if witch and distance(player,witch)<40 then
  --show the letter to the witch
  set_flag(1,3,1)
  local dialogs={}
  for i=1,6 do
   dialogs[i]={}
  end
  dialogs[1].sprite=068
  dialogs[1].message="nothing flammable...\n\nburned it all..."
  dialogs[2].sprite=064
  dialogs[2].message="o great witch! i bear you\nthis scroll--"
  dialogs[3].sprite=065
  dialogs[3].message="a scroll? this should light!"
  dialogs[4].sprite=068
  dialogs[4].message="aha!"
  dialogs[4].event=light_fire
  dialogs[5].sprite=065
  dialogs[5].message="thanks. now be a dear and\nbring me serpent's root\nfrom the cave."
  dialogs[6].sprite=065
  dialogs[6].message="take the portal."
  dialogs[6].event=open_portal
  chain_dialogs(dialogs)
  
  take_item(1)
 else
  --read it to yourself
  local dialogs={}
  for i=1,5 do
  	dialogs[i]={}
  	dialogs[i].sprite=064
  end
  dialogs[1].message="it says:\n\n\""..her_name.." is a dedicated,\nbright, hopeful young soul."
  dialogs[2].message="day and night she reads\nbooks of history and tales\nof magic. she would like\nnothing more than to"
  dialogs[3].message="study under the greatest\nwitch of the land. she\npledges to use her power for\ngood and the defense of\nour poor village."
  dialogs[4].message="o great witch,\ncould you extend your\nlegendary charity to the\ntraining of young claire?\""
  dialogs[5].message="how nice. :)"
  chain_dialogs(dialogs)
 end
end

function touch_ashes()
 make_dialog(016,"it's a smoldering heap of\nash with steaming chunks\nlittered around.")
end

function fill_cauldron()
 --fill the cauldron w/ fundrink
 mset(17,19,063)
 mset(17,20,026)
 
 local cauldron=static_entity(026,map_to_screen(17,20))
 cauldron.name="\"ritual\" potion"
 entity_set_use_event(cauldron,drink_potion,"drink")
 add(npcs,cauldron)
end

function witch_collapse()
 sfx(11)
 del(npcs,witch)
 witch=static_entity(009,witch.x,witch.y)
 add(npcs,witch)
end

function give_crystal()
 if witch and distance(player,witch)<40 then
  if not is_flag_set(5,1) then
   local dialogs={}
   for i=1,9 do
    dialogs[i]={}
   end
   dialogs[1].sprite=064
   dialogs[1].message="hey! you told me that wand\nwould give the guard a\n*scare*!! i killed him!\nhe had a family!"
   dialogs[2].sprite=065
   dialogs[2].message="yes! this is the crystal\ni seek."
   dialogs[3].sprite=068
   dialogs[3].message="yes... yesss..."
   dialogs[4].sprite=068
   dialogs[4].message="oops--shit."
   dialogs[5].sprite=066
   dialogs[5].message="i broke the crystal.\n\ni need you to get another one."
   dialogs[6].sprite=064
   dialogs[6].message="are you kidding, witch?"
   if is_flag_set(4,2) then
    dialogs[6].message=dialogs[6].message.."\n\nthose crystals are the goblins'\nlast line of defense!"
   end
   dialogs[7].sprite=064
   dialogs[7].message="i'm not killing any more\ngoblins for you."
   dialogs[8].sprite=067
   dialogs[8].message="..."
   dialogs[9].sprite=065
   dialogs[9].message="fine. take this scroll.\nit will charm the goblins\nso they will not fight you."
   dialogs[9].event=open_portal
  
   chain_dialogs(dialogs)
   
   give_item(3)
  	set_flag(1,3,4)
  else
   --second crystal giving
   local dialogs={}
   for i=1,15 do
    dialogs[i]={}
   end
   dialogs[1].sprite=065
   dialogs[1].message="yes! yes! at last!\nthe last ingredient!"
   dialogs[2].sprite=069
   dialogs[2].message="..."
   dialogs[3].sprite=068
   dialogs[3].message="that should do it."
   dialogs[3].event=fill_cauldron
   dialogs[4].sprite=067
   dialogs[4].message="it is done.\n\nyou may go now."
   dialogs[5].sprite=064
   dialogs[5].message="what?!?!"
   dialogs[6].sprite=064
   dialogs[6].message="that's it?!\n\nwhat about the ritual?"
   dialogs[7].sprite=068
   dialogs[7].message="*gulp*\n*gulp*\n*gulp*\n*gulp*\n*gulp*"
   dialogs[8].sprite=084
   dialogs[8].message="yes yes yes yes yes"
   dialogs[9].sprite=085
   dialogs[9].message="yes, that's the stuff"
   dialogs[10].sprite=084
   dialogs[10].message="ahhhhhhh"
   dialogs[11].sprite=064
   dialogs[11].message="...?"
   dialogs[12].sprite=100
   dialogs[12].message="yessssssssss"
   dialogs[13].sprite=101
   dialogs[13].message="..."
   dialogs[14].sprite=015
   dialogs[14].message=""
   dialogs[14].event=witch_collapse
   dialogs[15].sprite=064
   dialogs[15].message="she fainted."
   chain_dialogs(dialogs)
   
   set_flag(1,3,5)
  end
  
  take_item(1)

 else
  make_dialog(064,"i have no one to give\nthis to.")
 end
end

function take_crystal()
 --take the first crystal
 if not is_flag_set(5,1) then
 	local dialogs={}
 
 	for i=1,3 do
   dialogs[i]={}
   dialogs[i].sprite=064
  end
  dialogs[1].message="jesus. i didn't think it\nwould *kill him* like that."
  dialogs[2].message="i hope the rest of the\ngoblins here will be okay\nwithout this crystal."
  dialogs[3].message="but the great witch promised\nme this ritual is important."
 
  if not is_flag_set(4,2) then
   --she doesn't know the crystal is important
   del(dialogs,dialogs[2])
  end
 
  chain_dialogs(dialogs)
  
  set_flag(4,1,1)

 --take the second crystal
 else
  make_dialog(069,"...")
  set_flag(5,2,1)
 end
 
 inventory[1].name="power crystal"
 inventory[1].sprite=017
 inventory[1].action="give"
 inventory[1].event=give_crystal
 give_item(1)
 if crystal then
  del(npcs,crystal)
 end
 
end

function drink_potion()
 local dialogs={}
 
 for i=1,6 do
  dialogs[i]={}
 end
 
 dialogs[1].sprite=069
 dialogs[1].message="all those atrocities, just\nfor this..."
 dialogs[2].sprite=064
 dialogs[2].message="might as well take a sip,\nhuh?."
 dialogs[3].sprite=064
 dialogs[3].message="*gulp*"
 dialogs[4].sprite=116
 dialogs[4].message="hooooly shiiiiiit"
 dialogs[5].sprite=118
 dialogs[5].message="this is insane"
 dialogs[6].sprite=117
 dialogs[6].message="so worth"
 
 chain_dialogs(dialogs)
end

function kill_witch()
 del(npcs,witch)
 local corpse=static_entity(016,witch.x,witch.y)
 corpse.name="pile of ash"
 entity_set_use_event(corpse,touch_ashes,"poke")
 add(npcs,corpse)
 local fire_effect={}
 fire_effect.x=witch.x
 fire_effect.y=witch.y
 fire_effect.sprite=098
 fire_effect.ticks=20
 add(effects,fire_effect)
 
 witch=nil
end

function cast_wand()
 if goblin and distance(player,goblin)<40 then
  make_dialog(098,"eeeaaaggghhhhh!")
  
  inventory[2].name="wand of fire"
  inventory[2].action="burn"
  
  --kill the goblin
  sfx(02)
  del(npcs,goblin)
  local x,y=map_to_screen(69,53)
  local ashes=static_entity(016,x,y)
  ashes.name="pile of ash"
  entity_set_use_event(ashes,touch_ashes,"poke")
  npcs[1]=ashes
  goblin=nil
  x+=8
  crystal=init_crystal(x,y)
  npcs[2]=crystal
  local fire_effect={}
  fire_effect.x=x-8
  fire_effect.y=y
  fire_effect.sprite=098
  fire_effect.ticks=20
  add(effects,fire_effect)
  
  set_flag(4,3,1)
 elseif witch and distance(player,witch)<40 then
  --tried to burn the witch
  if get_flag(1,3)==5 then
   --witch is unconscious and you *kill her*!!
   local dialogs={}
   for i=1,3 do
    dialogs[i]={}
   end
   
   kill_witch()
   sfx(02)
   
   dialogs[1].sprite=098
   dialogs[1].message=""
   dialogs[2].sprite=069
   dialogs[2].message="i thought you were a hero."
   dialogs[3].sprite=069
   dialogs[3].message="you didn't even know my\nname."
   chain_dialogs(dialogs)
  
  else
   --witch is conscious and deflects the spell
   make_dialog(068,"take your toy elsewhere.\nit will have no effect on\nme.")  
  end
 elseif get_flag(1,3)==4 and level==levels.goblins then
  make_dialog(064,"i won't harm another goblin.\n\ni'm hopelessly outnumbered,\nanyway.")
 elseif is_flag_set(4,3) then
  make_dialog(064,"i've nothing to burn.")
 else
  make_dialog(064,"i've no one to scare.")
 end
end

function throw_orb()
end

function genocide()
 sfx(07,3)
 playing_genocide=true
 if level==levels.goblins then
  make_dialog(126,"used item: scroll of\ngenocide")
  take_item(3)
  set_flag(5,1,1)
  for i=16,2,-1 do
   local gob=npcs[i]
   del(npcs,gob)
   add(npcs,static_entity(016,gob.x,gob.y))
   gob=nil
  end
 else
  make_dialog(064,"i'll save this for charming\nthe goblins.")
 end
end

function init_inventory()
 inventory={}
 
 local rec_letter={}
 rec_letter.owned=true
 rec_letter.sprite=127
 rec_letter.name="scroll of recommendation"
 rec_letter.action="read"
 rec_letter.event=read_letter
 
 local fire_wand={}
 fire_wand.owned=cheat_items
 fire_wand.sprite=125
 fire_wand.name="spooky wand"
 fire_wand.action="scare"
 fire_wand.event=cast_wand
 
 local dark_scroll={}
 dark_scroll.owned=cheat_items
 dark_scroll.sprite=126
 dark_scroll.name="scroll labeled \"wubba lubba\ndub dub\""
 dark_scroll.action="read"
 dark_scroll.event=genocide
 
 inventory[1]=rec_letter
 inventory[2]=fire_wand
 inventory[3]=dark_scroll
 
 --player starts with the letter
 selected_item=1
end

function give_item(id)
 if id==1 then
  local fx=13
  
  if is_flag_set(5,1) then
   fx=14
  end
  
  sfx(fx)
 end
 
 inventory[id].owned=true
 selected_item=id
end

function take_item(id)
 inventory[id].owned=false
 if selected_item==id then
  if num_items_owned()>0 then
   select_next_item()
  else
   selected_item=0
  end
 end
end

function use_item()
 inventory[selected_item].event()
end

function is_selected_item_valid()
 if selected_item>#inventory then
  return false
 end
 
 if not inventory[selected_item].owned then
  return false
 end
 
 return true
end

function select_next_item()
 selected_item+=1
 if selected_item>#inventory then
  selected_item=1
 end
 
 while not is_selected_item_valid() do
  selected_item+=1
  if selected_item>#inventory then
   selected_item=1
  end
 end
end

function num_items_owned()
 local num=0
 
 for i=1,#inventory do
  local item=inventory[i]
  if item.owned then num+=1 end
 end
 return num
end

function update_intro_screen()
 screen.t+=1
 
 if debug_mode then
  --z can skip
  if btnp(4) then
   screen.t=136
  end
 end
 
 --after screen is over start gameplay
 if screen.t>135 then
  screen=new_game_screen()
 end
end

function draw_intro_screen()
 print("apprentice quest",32,62,7)

 if screen.t==20 then
  sfx(00)
 end

 if screen.t>15 then
  local progress=(screen.t-15)*1.75
  local tail_progress=(screen.t-15)*0.5
  local frame=flr(screen.t/15)%2
  --draw claire's path
  for i=0,7 do
   local col=7
   if i%2==1 then col=6 end
   line(tail_progress+i,69+i,progress+4,69+i,col)
  end
  spr(036+frame,progress,69)
  --draw witch's path
  for i=0,7 do
   local col=50
   if i%2==1 then col=49 end
   line(128-tail_progress-(7-i),53+i,127-progress,53+i,col)
  end
  spr(041+frame,127-progress-4,53)
 end
end

function new_intro_screen()
 local intro_screen={}
 intro_screen.update=update_intro_screen
 intro_screen.draw=draw_intro_screen
 
 intro_screen.t=0
 
 return intro_screen
end

function draw_outro_screen()
 print("game over",0,0,7)
end

function update_outro_screen()
 screen.t+=1
end

function draw_outro_screen()
 print("game over",45,62,7)
 
 if screen.t==60 then
  sfx(00)
 end
 if screen.t>60 then
  local progress=(screen.t-60)*1.75
  local tail_progress=(screen.t-60)*0.5
  local frame=flr(screen.t/15)%2
  --draw claire's path
  for i=0,7 do
   local col=50
   if i%2==1 then col=49 end
   line(tail_progress+i,61+i,progress+4,61+i,col)
  end
  spr(036+frame,progress,61)
 end
 
end

function new_outro_screen()
 local outro_screen={}
 outro_screen.update=update_outro_screen
 outro_screen.draw=draw_outro_screen
 
 outro_screen.t=0
 
 return outro_screen
end

function _init()
 screen=new_intro_screen() 
end

playing_fire_ambience=false
playing_potion_ambience=false

t=0
c_tile=30
function update_game_screen()
 t+=1
 t%=1024
 
 c_tile=mget(17,20)
 
 if level==levels.cave then
  if is_flag_set(2,1) then
   --play rat screeching
   if rnd()<0.03 then
    sfx(09)
   end
  else
   --play rat pitter patter
   if t%5==00 then
    sfx(08)
   end
  end
 end
 --play ambient fire sound if
 --player is in the tower with fire lit
 if level==levels.tower and c_tile==014 then
  if not playing_fire_ambience then
   sfx(04,3)
   playing_fire_ambience=true
  end
 else
  if playing_fire_ambience then
   sfx(-1,3)
   playing_fire_ambience=false
  end
 end
   
 if level==levels.tower and c_tile==026 then
  if not playing_potion_ambience then
   sfx(12,3)
   playing_potion_ambience=true
  end
 else
  if playing_potion_ambience then
   sfx(-1,3)
   playing_potion_ambience=false
  end
 end

 for i=#effects,1,-1 do
  effects[i].ticks-=1
  if effects[i].ticks==0 then
   del(effects,effects[i])
  end
 end
 
 if has_dialog then
  --dismiss dialog with "z"
  if btnp(4) then
   dialog_index+=1
   sfx(10)
   local dialog=dialogs[dialog_index]
   --some dialogs run an event after being dismissed
   if dialog and dialog.event then
    dialog.event()
   end

   if dialog_index>#dialogs then
    has_dialog=false
   end
  end
 elseif not game_over then
  --update player
  if player then
   update_entity(player)
  end
  --update friendly npcs
  for i=1,#npcs do
   update_entity(npcs[i])
  end
  
  --game might have ended inside update_entity()
  if not player then
   return
  end
  
  --check if close enough to talk to anyone
  use_range=false
  use_entity=nil
  for i=1,#npcs do
   local npc = npcs[i]
   
   if npc.has_use_event and distance(npc,player)<npc.use_distance then
    use_range=true
    use_entity=npc
   end
  end
  
  if use_range then
   if btnp(4) then
    use_entity.use_event()
   end
  elseif num_items_owned()>0 then
  
   --x to switch items
   if btnp(5) then
    select_next_item()
   --z to use items
   elseif btnp(4) then
    use_item()
   end
  end
 elseif game_over then
  screen.t+=1
  if screen.t>=30 then
   screen=new_outro_screen()
  end
 end
end

function draw_inventory()
 rectfill(0,115,127,127,0)
 
 local x=1
 local y=117

 for i=1,#inventory do
  local col=7
  if selected_item==i then
   col=9
  end
  
  rect(x,y,x+9,y+9,col)

  if inventory[i].owned then
   spr(inventory[i].sprite,x+1,y+1)
  end
  
  x+=11
  
 end
 
 if selected_item>0 then
  local curr_item=inventory[selected_item]
  local item_name=curr_item.name
  local item_action=curr_item.action
 
  --draw action/controls at bottom
  local action_width=4*#item_action
  x=127-action_width
  print("[z]",x-16,120,7)
  if num_items_owned()>1 then
   print("[x] switch",x-16-40-4,120,7)
  end
  print(item_action,x,120,7)
  
  local lines=split(item_name)

  --draw name at top
  local y=7
  if #lines==2 then y+=7 end
  rectfill(0,0,127,y,0)
  y=2
  for i=1,#lines do
   print(lines[i],2,y,7)
   y+=7
  end
 end
end

function draw_game_screen()
 --show border for debug
 --rect(0,0,127,127,15)
  
 --draw all sprites relative to camera
 camera(camera_x-64,camera_y-64)
 
 --draw the map
 if has_map then
  map(map_x,map_y,0,0,map_width,map_height)
 end
 --draw special animations
 if level==levels.tower then
  if c_tile==14 then
   if flr(t/15)%2==1 then
    mset(17,19,57)
   else
    mset(17,19,13)
   end
  elseif c_tile==26 then
   mset(17,19,63)
   local x,y=map_to_screen(17,20)
   local x_locs={x+1,x+6,x+3}
   for i=1,#x_locs do
    local bub_x=x_locs[i]
    local bub_y=flr(t/2)+3*(i-1)
    bub_y%=8
    line(bub_x,y-bub_y,bub_x,y-bub_y-2,11)
   end
  end
 end
 --draw npcs
 for i=1,#npcs do
  draw_entity(npcs[i])
 end
 
 --draw player
 if player then
  draw_entity(player)
 end
 
 --draw effects
 for i=1,#effects do
  local fx=effects[i]
  spr(fx.sprite,fx.x,fx.y)
 end
 
 --draw hud
 camera(0,0)
 if has_dialog then
  --dialog box appearance
  local bg_col=15
  local bdr_col=4
  local tx_col=0
  
  local dialog=dialogs[dialog_index]
 
  --draw background
  local by=93
  rectfill(0,by,127,127,bg_col)
  rect(0,by,127,127,bdr_col)
  
  --draw character portrait
  local px=2
  local py=by+2
  rect(px,py,px+9,py+10,bdr_col)
  rectfill(px+1,py+1,px+8,py+9,0)
  spr(dialog.sprite,px+1,py+2)
  
  --draw the message
  local mx=14
  local my=by+3
  local lines=split(dialog.message)
  
  local tabbed=true
  for i=1,#lines do
   if my>py+10 and tabbed then
    mx-=10
    tabbed=false
   end
   print(lines[i],mx,my,tx_col)
   my+=6
  end
  --print(dialog.message,mx,my,0)
  --draw controls
  print("[z]",114,120,tx_col)
 elseif use_range then
 
  rectfill(0,115,127,127,0)
  local use_action_width=4*(#use_entity.use_event_name + 4)
  print("[z] "..use_entity.use_event_name,127-use_action_width,117,7)
  --draw name at top
  rectfill(0,0,127,7,0)
  print(use_entity.name,2,2,7)
 else
  draw_inventory()
 end
end

function new_game_screen()
 game_over=false
 init_levels()

 init_flags()

 has_dialog=false
 has_map=false

 init_player()
 
 effects={}
 
 ----start the game
 set_level("tower")
 

 ----skip to genocide scene
 --set_flag(4,1,1)
 --set_flag(4,3,1)
 --set_flag(1,3,4)
 --set_level("goblins")
 --cheat_items=true 

 init_inventory()
 
 
 ----debug skip to the very end
 --player.x,player.y=map_to_screen(17,23)
 --set_flag(5,1,1)
 --set_flag(5,2,1)
 --entity_set_use_event(witch,take_crystal,"cheat")
 
 local game_screen={}
 game_screen.update=update_game_screen
 game_screen.draw=draw_game_screen
 game_screen.t=0
 return game_screen
end

function _update()
 screen.update()
end

function _draw()
 --clear screen background
 camera(0,0)
 rectfill(0,0,127,127,000)
 
 screen.draw()
end
__gfx__
00000000000000000000000000033000000330000003300000000000000000000000000000000000000000001ddd66611666ddd166dd66dd669889dd00000000
0008000000008000000000000034430000344300003443000000000000000000000000000000000000055000dddd66611666dddddd66dd66d599995600000000
0008800000088000000000000004430000044300000443000000000000000000000000000000000000555500dddd66611666dddd66dd66dd6559955d00000000
0008000770008000000000000002230000022300000223000000000000000000000000000000000000555500dddd66611666dddddd69dd66d555555600000000
0088807007088800000000000002230000022300000223000004400000044000000440000000000000555500666666611666666666d966dd665555dd00000000
08080800008080800000000000022300003223000002233000044400000440000004440000005550005555006666666116666666dd699d66dee55ee600000000
008080000008080000000000000bb000000bb000000bb00000000000000000000000000000555555005555006666666116666666669889dde252252e00000000
008080000008080000000000000bb000000b0b0000b0b00000000000000000000000000055555555005555001111111111111111dd988966deeeeee600000000
000000000000000000000000000330000003300000033000000000000000000000000000000000006d5555dd1111111111111111111111116d5555ddbbbbbbbb
00000000000110000000000000333300003333000033330000000000000000000000000000000000d5bbbb56666666611666666666222266d5111156bbbbbbbb
00000000001c61000000000000333300003333000033330000000000000000000000000000000000655bb55d6666666116666666624444266551155dbbbbbbbb
00000000001c61000000000000333300003333000033330000000000000000000000000000000000d5555556666666611666666662444426d5555556bbbbbbbb
00000000001cc1000000000000333300003333000033330000044000000440000004400000000000665555dddddd66611666ddddd244492d665555ddbbbbbbbb
00000000001cc1000000000003333330003333300333330000044000000440000004400000000000dee55ee6dddd66611666ddddd244442ddee55ee6bbbbbbbb
002882000001100000000000000bb000000bb000000bb00000000000000440000000000000000000e252252edddd66611666ddddd244442de252252ebbbbbbbb
088828200000000000000000000bb0000000b000000b000000000000000000000000000000000000deeeeee61ddd66611666ddd111111111deeeeee6bbbbbbbb
00000000000000000000000000003300000033000000330000000000000000000000000000055000000550001111111111111111111111111111111122222222
0000000000000000000000000003443000034430000344300000000000000000000000000055550000555500ddddddd11ddddddd66666666dddddddd2ffffff2
0000000000000000000000000003440000034400000344000000000000000000000000000015550000155500ddddddd11ddddddd66666666dddddddd2feeeef2
0000000000000000000000000003220000032200000322000000000000000000000000000015550000155500ddddddd11ddddddd66666666dddddddd2feeeef2
00000000000000000000000000032200000322000003220000044000000440000004400000555500005555006666ddd11ddd6666dddddddd666666662feeeef2
000000000000000000000000003322000033220000032230004440000004400000444000005d550000d555006666ddd11ddd6666dddddddd666666662feeeef2
0000000000000000000000000000bb000000bb000000bb0000000000000000000000000000545500004555006666ddd11ddd6666dddddddd666666662ffffff2
0000000000000000000000000000bb00000b0b000000b0b000000000000000000000000000545550004555001666ddd11ddd6661111111111111111122222222
00000000000000000000000000033000000330000003300000000000000000000000000066dd66dd66d116dd1666ddd11ddd66611ddd66611666ddd166dd66dd
000000000000000000000000003443000034430000344300000000000000000000000000dd66dd66dd1281666666ddd11ddd66661ddd66611666ddd1dd66dd66
00000000000000000000000000344300003443000034430000000000000000000000000066dd66dd6122281d6666ddd11ddd66661ddd66611666ddd166dd66dd
000000000000000000000000003223000032230000322300000000000004400000000000dd669d66d18ee8166666ddd11ddd66661ddd66611666ddd1dd66dd66
00000000000000000000000000322300003223000032230000044000000440000004400066dd96dd618ee81dddddddd11ddddddd1ddd66611666ddd166dd66dd
000000000000000000000000033223300332230000322330000440000004400000044000dd699d66d1822216ddddddd11ddddddd1ddd66611666ddd1dd66dd66
000000000000000000000000000bb000000bb000000bb000000000000000000000000000669889dd661821ddddddddd11ddddddd1ddd66611666ddd166dd66dd
000000000000000000000000000bb000000b00000000b000000000000000000000000000dd988966dd611d6611111111111111111ddd66611666ddd1dd66dd66
003bbb00005555000055550000555500005555000033330000000000222222222222222221115552000000000000000000000000000000000000000000000000
0333bbb0005555000055550000555500005555000333333000000000255555555555555221115552000000000000000000000000000000000000000000000000
33444bbb551111555511115555111155555555553344333300000000255555555555555221115552000000000000000000000000000000000000000000000000
344c4cbb551dd1555511115555188155555555553444433300000000255555555555555221115552000000000000000000000000000000000000000000000000
344444bb551dd155551dd15555188155555555553444433300000000255511111111555221115552000000000000000000000000000000000000000000000000
334884bb55111155551dd15555111155555555553344433300000000255511111111555221115552000000000000000000000000000000000000000000000000
332222bb551111555511115555111155555555553322233300000000255511111111555221115552000000000000000000000000000000000000000000000000
332222bb555555555555555555555555555555553322233300000000255511122111555222222222000000000000000000000000000000000000000000000000
800000080000000000000200000002000055550000555500000000002111555222222222dddddddd115000000000000000000000000000000000000000000000
808888080000000000222200002222000055550000555500000000001111555211111111d519a00d551100000000000000000000000000000000000000000000
888800080000000002222200022222005511115555111155000000001111555211111111dddddddd115000000000000000000000000000000000000000007000
88980088008008000282822002828220551e8155551ca155000000001111555211111111d511000d551100000000000000000000000000000000000000007000
08888880000000000222222002222220551b2155551e9155000000005555555255555555dddddddd115000000000000000000000000000000000000000007000
08aaaa800000000022222020222220205511115555111155000000005555555255555555d511000d551100000000000000000000000000000000000000009000
08a88a800000000000222000202220205511115555111155000000005555555255555555dddddddddddddddd0000000000000000000000000000000000004000
008888000000000000022000002000005555555555555555000000002222222222222222d511000dd51a900d0000000000000000000000000000000000000000
56665655800000080000a00000000000005555000055550000000000255511122222222222222222000000000000000000000000000000000000000000008000
6656656680488808000990000000000000555500005555000000000025551111555555552111555200000000000000000000000000000000000000000008b000
6555556688840008090a00000000000055111155551111550000000025551111555555552111555200000000000000000000000000000000000000000003bb00
6566656588980088a99a09a00000000055111155551111550000000025551111555555552111555200000000000000000000000000000000000000000bbb3000
666565560888888009999900000000005513b1555510015500000000255555551111111121115552000000000000000000000000000000000000000000333000
6656656508aaaa8000a8a999000000005513315555100155000000002555555511111111211155520000000000000000000000000000000000000000003b0000
6666566608a88a80099889a00000000055111155551111550000000025555555111111112111555200000000000000000000000000000000000000000b3bb000
55656556008888000099a90000000000555555555555555500000000222222222222222221115552000000000000000000000000000000000000000000330000
55655655656556566561156655555555003bbb00003bbb00003bbb00255511121155115521115552115111550000000000000000000000000004444004444000
665665655656555666128155555555550333bbb00333bbb00333bbb0255511125511551121115552551281110000000000000000008808800077770000777700
6555556555655565512228165555555533444bbb33444bbb33444bbb255511121155115521115552112228150000000000000000008080800078870000755700
6565656565656555618ee81555555555344a43bb344149bb34484ebb255511125511551121115552518ee8110000000000000000000040000072270000755700
5565655655666556618ee81655555555344444bb344444bb344444bb255511121155115521115552118ee8150000000000000000000040000078870000755700
55565565665555656182221655555555334884bb334884bb334884bb255511125511551121115552518222110000000000000000000040000072270000755700
56665665665656555618216555555555332222bb332222bb332222bb2555111211551155211155521118215500000000000000000000a0000077770000777700
55556555555565566561166655555555332222bb332222bb332222bb255511125511551121115552551115110000000000000000000000000444400000044440
000000000000000000000000000000d3f3f2f3e3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000d3f3f2f3e3f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000d3f3f2f3e3f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000d3f3f2f3e3f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000d3f3f2f3e3f0f000000000000000000000000000000000000000f000000000000000000000000000000000000000000000
0000000000f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000c3d2d1d2b30000000000000000000000000000000000000000f0f000000000000000000000000000000000000000000000
0000000000f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000f0f00000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000f0f0f000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000f0f0f0f0f0f00000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000f0f0000000000000000000000000000000000000f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000f0f0f0f0000000000000000000000000000000f0f00000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000f0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006373700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000606063737000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000606060637370000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000606060606373737
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003737060707060637
37373737373737373700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007486868400000000000000000000000000000000000037370627070606
06070606170606063737373700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007787879700000000000000000000000000000000000000370606060706
06071717060606060606063700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007787879400000000000000000000000000000000000000373706060617
06070607070707171706063737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007787879500000000000000000000000000000000000000003737060617
17060607060606071717060637000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007787879600000000000000000000000000000000000000000037373706
17061717060606070617060637000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007787879400000000000000000000000000000000000000000000003707
06060706060607060707070637000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007787879500000000000000000000000000000000000000000000003707
06060706070617070707060637000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007787879600000000000000000000000000000000000000000000003737
37370606060617060606063737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007787879400000000000000000000000000000000000000000000000000
00373706060617170606373700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007787879500000000000000000000000000000000000000000000000000
00003737061706063737370000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007787879600000000000000000000000000000000000000000000000000
00000037373737373700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000077a7879700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007685857500000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
d5d5d5d5d5000f00000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5d5d5d5d5000f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5d5d5d5d5000f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5d5d5d5d5000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5d50f0f0f0f0f0f0f0f0f0000000000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5d5d5000f0f0f0f0f0f0f0f0f0f000f0f0f000000000f00000f0f0f0f0f000f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d50000000f0f0f0f0f0f0f0f0f0f000f0f0f000f000000000000000000000000000f0f000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000f0f0f0000000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000f0f0f0f2c2e2e2e2e2e2e2e2e2e2b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000f0f0f0f0f3d2f2f2f2f2f2f2f2f2f3e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000002c2e0b2f3f3f3f3f3f3f3f2f0c2e2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000003d2f2f2f3f3f3f3f3f3f3f2f2f2f3e00000000000000000000000000000000000000000000000000000000000000737373000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000003d2f3f3f3f3f3f3f3f3f3f3f3f2f3e00000000000000000000000000000000000000000000000000000073737373737173000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000003d2f3f3f3f3f3f3f3f3f3f3f3f2f3e0000000000000f000000000000000000000000000000000000737373717171717173730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000003d2f3f3f3f3f3f3f3f3f3f3f3f2f3e00000000000000000000000000000000000000000000000073737160607070707170737300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000003d2f3f3f3f3f3f1e3f3f3f3f3f2f3e00000000000000000000000000000000000000000000000073707060717070607070717300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000003d2f3f3f3f3f3f3f3f3f3f3f3f2f3e00000000000000000000000000000000000000000000000073707070707060717060707300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000003d2f3f3f3f3f3f3f3f3f3f3f3f2f3e00000000000000000000000000000000000000000000000073716060606071717070717300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000003d2f2f2f3f3f3f3f3f3f3f2f2f2f3e00000000000000000000000000000000000000000000007373717070706071717060607300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000003c2d1b2f3f3f3f3f3f3f3f2f1c2d3b00000000000000000000000000000000000000000000007371716071707060707160717373000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000003d2f2f2f2f2f2f2f2f2f3e000000000000000000000000000000000000000000000000007371717070707071707070717173000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000003c2d2d1b3f2f3f1c2d2d3b000000000000000000000000000000000000000000000000007373706070717271716060717173000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000003d3f2f3f3e000000000000000000000000000000000000000000000000000000000073707070717071717170717373000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000003d3f2f3f3e000000000000000000000000000000000000000000000000000000000073717160607171717173737300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000003d3f2f3f3e000000000000000000000000000000000000000000000000000000000073737171717173737373000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000003d3f2f3f3e000000000000000000000000000000000000000000000000000000000000737373737373000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000003d3f2f3f3e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010e0000244302640029430114002d4300c40024430294302b4301140024430114002443013400154000c4000c4000e400124001040015400164001840019400194001a4001a4001a4001a4001a4001a4001a400
000200000c4700c4700c4700c47007400034700347003470034700347003400034000340000400004000040014400004000040000400144000040014400004001440000400004000040000400004000040000400
010200000167005670096700f6701c6701160018600236001a600236002060029600246002e6001f6000b60006600036000260002600026000060000600006000060000600006000060000600006000060000600
0003000000700027700277002770037700577005770087700f77018770137700a7700377003770017700177038700377003770035700007000070000700007000070000700007000070000700007000070000700
000c0020136101761017610156101461012610106100e6100c6100b6100b6100b6101061013610166101661013610126100f610166101b6101c6101c6101661013610106100e6100e6100e6100b610096100c610
001b00011a6731a6031a6031a6031a6031a6031a6031f1731a6031a6031a6031a6031a6031a6031a6031a6031a6031a6031a6031a6031a6031a6031a6031a6031a6031a6031a6031a6031a6031a6031a6031a603
0103000018573185731f5731f5731f573185731857318573185731857318573005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
011f0000096710765105631046110260105601056010c601006010560100601006010060105601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
01040000241131810318113241030e103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103
010200003016232162341623516239162391623916239162391623916239162391623a1623a1623a1620000200002000020000200002000020000200002000020000200002000020000200002000020000200002
010400000c3330c0300c0300c03000003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
011700002404318043000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
010c00090011307113041130511302113071130011309113001132804300100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
011000002457026570285702857029570295702b57028570265701d5001a570005001857000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
011000000457004570045700457004570045700457004570025700257002570025700257002570025700257013570105700e57000500025700050000570005000050000500005000050000500005000050000500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
