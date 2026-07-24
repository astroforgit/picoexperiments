pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--rpgs done quick
--by connor halford

place_town={x=0,y=0,
 back_tile=64,name="tiny town"}
place_meadow={x=16,y=0,
 back_tile=80,name="magnificent meadow"}
place_haunted={x=32,y=0,
 back_tile=96,name="witching woods"}
place_graveyard={x=48,y=0,
 back_tile=112,name="gladiator graveyard"}
place_castle={x=64,y=0,
 back_tile=66,name="climactic castle"}
place_boss={x=80,y=0,
 back_tile=66,name="boss"}
places={place_town,place_meadow,
 place_haunted,place_graveyard,
 place_castle,place_boss}
current_place=1

enemy_rat={place=2,level=5,
 attack=1,xp=1,health=10,
 s=2,w=8,h=4,name="rat",
 spawns={ {x=80,y=16},
  {x=24,y=64},{x=88,y=88}
 }}
enemy_ghost={place=3,level=37,
 attack=150,xp=84,health=42,
 s=3,w=5,h=6,name="ghost",
 spawns={ {x=96,y=24},
  {x=24,y=42},{x=96,y=104}
 }}
enemy_skele={place=4,level=73,
 attack=300,xp=200,health=80,
 s=1,w=7,h=8,name="skeleton",
 spawns={ {x=96,y=16},
  {x=16,y=104},{x=96,y=96}
 }}
enemy_boss={place=6,level=99,
 attack=500,xp=2000,health=300,
 s=47,w=16,h=16,name="troll",
 spawns={{x=8,y=8}}
 }
enemy_data={
 enemy_rat,
 enemy_ghost,
 enemy_skele,
 enemy_boss
}

dl_height=33
line_height=9
t_offset=5
dl_time_per_char=2
dl_options=false

npc_guard1={id="npc_guard1",
 enabled=false,dl_offset=74,
 name="guard",place=1,
 s=4,x=60,y=120,w=8,h=8,
 c1=7,c2=9,c3=6,c4=5,pages={
 {"why would you want to leave",
 "the city without a quest?"},
 {"that just seems really",
 "inefficient to me."},
 {"you should probably go and",
 "speak to the mayor,"},
 {"they usually have some super",
 "interesting quests to give."}}
}
npc_guard2={id="npc_guard2",
 enabled=false,dl_offset=64,
 name="guard",place=-1,
 s=4,x=72,y=112,w=8,h=8,
 c1=7,c2=9,c3=6,c4=5,pages={
 {"i once knew a guy who claimed",
 "that witches are really"},
 {"good teachers and that",
 "gladiators take their"},
 {"weapons to the grave with",
 "them! if you ask me he was"},
 {"talking nonsense. teachers!",
 "imagine learning magic! pah!"},
 {"anyway good luck with that",
 "quest, you're pretty brave."}}
}
npc_mayor1={id="npc_mayor1",
 enabled=false,dl_offset=40,
 name="mayor",place=1,
 s=5,x=104,y=16,w=7,h=8,
 c1=7,c2=3,c3=9,c4=5,pages={
  {"hello there adventurer!",
  "it's lucky that you're here."},
  {"i've got a really fun and",
  "interesting task with your"},
  {"name on it, whatever that is.",
  "want to help me out?"},
  {"  actually i'm kinda busy",
  "  sure that sounds great!",
  results={5,6}},
  {"oh, that's a shame. well",
  "if you change your mind...",
  done=true},
  {"fantastic! what i need you",
  "to do is head over to the"},
  {"magnificent meadow and kill",
  "10 rats for me... kthxbye!",
  toggle_npcs={"npc_guard1",
   "npc_guard2","npc_mayor1",
   "npc_mayor2"},quest="rat"}
  }
}
npc_mayor2={id="npc_mayor2",
 enabled=false,dl_offset=40,
 name="mayor",place=-1,
 s=5,x=104,y=16,w=7,h=8,
 c1=7,c2=3,c3=9,c4=5,pages={
  {"how's the hunting going?",
  "the meadow is north of here."}}
}
npc_battle1={id="npc_battle1",
 enabled=false,dl_offset=128-dl_height,
 name="battle",place=-1,
 s=0,x=-200,y=-200,w=8,h=8,
 c1=7,c2=9,c3=6,c4=5,pages={
 {"  punch ineffectively",
 results={1},attack={"punch"}}}
}
npc_battle2={id="npc_battle2",
 enabled=false,dl_offset=128-dl_height,
 name="battle",place=-1,
 s=0,x=-200,y=-200,w=8,h=8,
 c1=7,c2=9,c3=6,c4=5,pages={
 {"  punch ineffectively",
 "  swing best sword in the game",
 results={1,1},attack={"punch","sword"}}}
}
npc_sword={id="npc_sword",
 enabled=false,dl_offset=128-dl_height,
 name="you found the best sword!!",place=4,
 s=7,x=61,y=53,w=6,h=6,
 c1=7,c2=2,c3=6,c4=2,pages={
  {"there is a note attached...",
  "\"punching is for losers!\""},
  {"  no, fists are clearly better",
  "  oooh so shiny!",
  results={2,2},done=true}}
}
npc_witch={id="npc_witch",
 enabled=false,dl_offset=40,
 name="witch",place=3,
 s=6,x=16,y=16,w=7,h=8,
 c1=7,c2=14,c3=2,c4=12,pages={
  {"hail adventurer! you must be",
  "here to listen to my famous"},
  {"tales of magic! i could talk",
  "for hours about this stuff..."},
  {"well, the first thing you",
  "should know about magic is"},
  {"that it takes years to learn",
  "even the most basic spells."},
  {"nevermind flyin' about on a",
  "broomstick like you own the"},
  {"sky, it took me a decade just",
  "to levitate a twig. with me?"},
  {"  hang on, start again",
  "  with you so far",
  results={3,8}},
  {"people think they can just",
  "say the magic words and"},
  {"get what they want. well",
  "\"please\" ain't good enough."},
  {"half the time it's like",
  "people aren't even payin'"},
  {"attention to what i'm sayin'.",
  "rude ain't it?"},
  {"  mm-hmm... wait what?",
  "  yes. about illumination...",
  results={8,13}},
  {"don't get me started on",
  "pronunciation. if you get"},
  {"that wrong who knows what'll",
  "'appen! for example take"},
  {"the spell of illumination.",
  "first time i tried it i went"},
  {"blonde for a week. not a bad",
  "look actually... i mean good"},
  {"luck sayin' \"et erit lux\" if",
  "you ain't 'eard someone else"},
  {"say it first. maybe i should",
  "try blonde again actually..."},
  {"  you lost me. from the top.",
  "  i, err, left the fire on",
  results={3,99}}
  }
}
npc_boss={id="npc_boss",
 enabled=false,dl_offset=70,
 name="club troll",place=6,
 s=21,x=56,y=32,w=16,h=16,
 c1=15,c2=8,c3=15,c4=4,pages={
  {"have you come to challenge",
  "me? hahaha, you're so small"},
  {"i can barely see you! tell",
  "you what, i'll give you a"},
  {"couple of free hits on me",
  "since i don't usually get"},
  {"food delivered like this.",
  "go ahead. do your worst.",
  boss=true}}
}
npc_dark={id="npc_dark",
 enabled=false,dl_offset=64-dl_height/2,
 name="you",place=5,
 s=47,x=-8,y=-8,w=8,h=8,
 c1=7,c2=2,c3=6,c4=2,pages={
  {"wow it's dark in here...",
  "wish i new some magic."}}
}
npc_light={id="npc_light",
 enabled=false,dl_offset=64-dl_height/2,
 name="you",place=-1,
 s=47,x=-8,y=-8,w=8,h=8,
 c1=7,c2=2,c3=6,c4=2,pages={
  {"now what was the spell of",
  "illumination again..."},
  {"  lumos",
  "  et erit lux",
  results={3,99}},
  {"hmm nothing happened... maybe",
  "i should see the witch again.",
  done=true}}
}
npcs={
 npc_guard1,
 npc_guard2,
 npc_mayor1,
 npc_mayor2,
 npc_battle1,
 npc_battle2,
 npc_sword,
 npc_witch,
 npc_boss,
 npc_dark,
 npc_light
}

map_text={
 {x=35,y=45,c1=15,c2=1,c3=6,
  tile_x=100,tile_y=11,
  t1="tiny town",
  t2="level 1+",
  t3="population:",
  t4="basically none"},
 {x=75,y=55,c1=10,c2=3,c3=15,
  tile_x=105,tile_y=3,
  t1="magnificent meadow",
  t2="level 5+",
  t3="first named before",
  t4="the rats arrived"},
 {x=115,y=97,c1=14,c2=2,c3=6,
  tile_x=113,tile_y=10,
  t1="witching woods",
  t2="level 32+",
  t3="confusingly not where",
  t4="witchwood comes from"},
 {x=187,y=43,c1=15,c2=1,c3=13,
  tile_x=119,tile_y=2,
  t1="gladiator graveyard",
  t2="level 70+",
  t3="ex-gladiator to",
  t4="be precise"},
 {x=204,y=97,c1=7,c2=0,c3=6,
  tile_x=125,tile_y=9,
  t1="climactic castle",
  t2="level 99+",
  t3="home sweet home for",
  t4="evildoers of all ages"},
 {x=-10000,y=-10000,c1=7,c2=0,c3=6,
  tile_x=125,tile_y=9,
  t1="this",
  t2="shouldn't",
  t3="be",
  t4="visible"}
}

mode_map=0
mode_place=1
mode_dialog=2
mode_battle=3
mode_title=4
mode_ending=5
current_mode=-1

--battle states
bs_your_turn=0
bs_your_anim=1
bs_their_turn=2
bs_their_anim=3
bs_victory=4
bs_loss=5
current_bs=-1
bs_timer=0
bs_anim_length=6
bs_anim_size=10
bs_think_length=15
battle_numbers={}

function load_place(p)
 current_place=p
 local p=places[current_place]
 
 --level bounds
 bounds={}
 for x=0,15 do
  for y=0,15 do
   local t=mget(x+p.x,y+p.y)
   if fget(t,0) then
    local dx,dy,w,h=0,0,8,8
    if(t==81)dx,dy,w,h=1,1,6,6
    if(t==97)dx,dy,w,h=1,2,6,5
    if(t==113)dx,dy,w,h=1,1,6,6
    bounds[#bounds+1]={
     x=x*8+dx,y=y*8+dy,w=w,h=h}
   end
  end
 end
 
 --npcs
 for i=1,#npcs do
  npcs[i].enabled=(npcs[i].place==current_place)
 end
 
 --enemies
 enemies={}
 for i=1,#enemy_data do
  if enemy_data[i].place==current_place then
   for j=1,#enemy_data[i].spawns do
    local d=enemy_data[i]
    enemies[#enemies+1]={
     data_index=i,w=d.w,h=d.h,
     x=d.spawns[j].x,
     y=d.spawns[j].y,
     health=d.health,turn=0
    }
   end
  end
 end
end

function refill_health()
 player.max_health=5*(1+player.level)
 player.health=player.max_health
end

function respawn()
 refill_health()
 player.x=40
 player.y=96
 load_place(1)
end

function start_game()
 darkness_removed=false
 met_witch=false
 
 player={x=0,y=0,w=7,h=8,s=16,
  sword=0,c1=7,c2=2,c3=6,c4=2,
  level=1,xp=0}
 respawn()
 
 quest=nil
 quest_counter=0
 quests_completed=0
 quest_max=10*(quests_completed+1)
 minutes=0
 seconds=0
 
 debug=false
 --debug=true
 --current_mode=mode_map
 --quest="troll"
 --load_place(6)
 --player.x=60
 --player.y=80
 --player.sword=1
 --quest="rat"
 --minutes=5
 --seconds=18
 --current_mode=mode_title
end

--transitions
trans_none=0
trans_in=1
trans_out=2
trans_mode=trans_none
trans_timer=0
trans_length=10
trans_col=2
trans={}
function start_trans(next)
 trans_mode=trans_in
 trans_timer=0
 next_mode=next
 trans={}
 for i=1,16 do
  trans[i]={x1=120+8*i,x2=120+8*i}
 end
end

function _init()
 current_mode=mode_title
 frame=1
 title_y=0
end

function overlap(b1,b2)
 if(b1.x+b1.w-1<b2.x)return false
 if(b1.x>b2.x+b2.w-1)return false
 if(b1.y+b1.h-1<b2.y)return false
 if(b1.y>b2.y+b2.h-1)return false
 return true
end

function update_place(direction)
 --movement
 local prev,moved=0,false
 local move_speed=1
 if direction==0 then --horiz
  prev=player.x
  if(btn(0))player.x-=move_speed moved=true
  if(btn(1))player.x+=move_speed moved=true
 elseif direction==1 then --vert
  prev=player.y
  if(btn(2))player.y-=move_speed moved=true
  if(btn(3))player.y+=move_speed moved=true
 end
 if moved then
  --level bounds
  for i=1,#bounds do
   if overlap(player,bounds[i]) then
    if(direction==0)player.x=prev
    if(direction==1)player.y=prev
    break
   end
  end
  --npc bounds
  for i=1,#npcs do
   if npcs[i].enabled and overlap(player,npcs[i]) then
    if(direction==0)player.x=prev
    if(direction==1)player.y=prev
    --transition to dialog
    current_mode=mode_dialog
    dl_npc=npcs[i]
    dl_page=1
    dl_line=1
    dl_char=1
    dl_timer=dl_time_per_char
    dl_printing=true
    dl_options=false
    break
   end
  end
 end
end

function try_move_enemy(e,direction)
 local prev_x,prev_y=e.x,e.y
 if(direction==0)e.x-=1
 if(direction==1)e.x+=1
 if(direction==2)e.y-=1
 if(direction==3)e.y+=1
 for i=1,#bounds do
  if overlap(e,bounds[i]) then
   if(direction==0 or direction==1)e.x=prev_x
   if(direction==2 or direction==3)e.y=prev_y
   break
  end
  e.y+=e.h
  e.y=min(e.y,120)
  e.y-=e.h
 end
end

function xp_to_reach(level)
 return 5*level
end

battle_number_gravity=0.2
function new_battle_number(amount,x,y)
 local c1,c2=8,14
 if(amount==0)amount,c1,c2="miss",6,1 x-=8 y+=8
 battle_numbers[#battle_numbers+1]={
  x=x,y=y,amount=amount,life=35,
  x_vel=(flr(rnd(21))-10)/12,
  y_vel=-3.5+rnd(1),c1=c1,c2=c2
 }
end

function enter_battle(enemy)
 --transition to battle
 start_trans(mode_battle)
 current_bs=bs_your_turn
 bs_timer=0
 refill_health()
 battle_e=enemy
 dl_npc=npc_battle1
 if(player.sword==1)dl_npc=npc_battle2
 dl_printing=false
 dl_options=true
 dl_choice=1
 dl_page=1
 dl_char=1
 dl_line=1
 dl_timer=0
end

function _update()
 --if btnp(3,1) then
 -- debug=not debug
 --end
 
 --update transition
 if trans_mode~=trans_none then
  trans_timer+=1
  local spd=256/trans_length
  if trans_mode==trans_in then
   for i=1,#trans do
    trans[i].x1-=spd
   end
  elseif trans_mode==trans_out then
   for i=1,#trans do
    trans[i].x2-=spd
   end
  end
  if trans_timer>=trans_length then
   if trans_mode==trans_in then
    trans_mode=trans_out
    trans_timer=0
    current_mode=next_mode
    
    --darkness dialog
    if current_mode==mode_place and current_place==5 then
     if not darkness_removed then
      if met_witch then
       dl_npc=npc_light
      else
       dl_npc=npc_dark
      end
      current_mode=mode_dialog
      dl_page=1
      dl_line=1
      dl_char=1
      dl_timer=dl_time_per_char
      dl_printing=true
      dl_options=false
     end
    end
   elseif trans_mode==trans_out then
    trans_mode=trans_none
   end
  end
  return
 end
 
 --update place
 if current_mode==mode_place then
  update_place(0)
  update_place(1)
  
  --move enemies
  for i=1,#enemies do
   if flr(rnd(3))==0 and enemies[i].health>0 then
    try_move_enemy(enemies[i],flr(rnd(4)))
    if overlap(player,enemies[i]) then
     enter_battle(enemies[i])
     break
    end
   end
  end
  
  if player.y>124 then
   --transition to map
   start_trans(mode_map)
   player.w=3+player.sword
   player.h=4+player.sword
   for i=1,#places do
    if map_text[i].t1==places[current_place].name then
     player.x=8*(map_text[i].tile_x-96)+1
     player.y=8*map_text[i].tile_y+10
     break
    end
   end
  end
  
  --stairs
  if current_place==5 then
   local b={x=17,y=16,w=6,h=6}
   if overlap(player,b) then
    load_place(6)
    player.x=60
    player.y=80
   end
  elseif current_place==6 then
   local b={x=61,y=96,w=6,h=7}
   if overlap(player,b) then
    load_place(5)
    player.x=16
    player.y=28
   end
  end
 end
 
 --update dialog
 if current_mode==mode_dialog
 or (current_mode==mode_battle and current_bs==bs_your_turn) then
  if dl_printing then
   if btnp(4) then
    dl_printing=false
   else
    dl_timer-=1
    if dl_timer<=0 then
     dl_timer=dl_time_per_char
     dl_char+=1
     if dl_char>#dl_npc.pages[dl_page][dl_line] then
      dl_char=0
      dl_line+=1
      if dl_line>#dl_npc.pages[dl_page] then
       dl_line=#dl_npc.pages[dl_page]
       dl_char=#dl_npc.pages[dl_page][dl_line]
       dl_printing=false
      end
     end
    end
   end
  else --not printing
   if dl_options then
    if btnp(2) then
     dl_choice-=1 if(dl_choice<1)dl_choice=#dl_npc.pages[dl_page]
    end
    if btnp(3) then
     dl_choice+=1 if(dl_choice>#dl_npc.pages[dl_page])dl_choice=1
    end
   end
   if btnp(4) then
    --move to next page
    local prev_page=dl_page
    local prev_npc=dl_npc
    local prev_choice=dl_choice
    if dl_options then
     dl_page=dl_npc.pages[dl_page].results[dl_choice]
     dl_options=false
    else
     dl_page+=1
    end
    if dl_page>#dl_npc.pages or dl_npc.pages[prev_page].done==true then
     current_mode=mode_place
     dl_options=false
     if dl_npc.id=="npc_boss" then
      enter_battle(enemies[1])
     else
      if(dl_npc.id=="npc_witch")met_witch=true
      if(dl_npc.id=="npc_light" and prev_choice==2)darkness_removed=true
      dl_npc=nil
     end
    else
     dl_char=1
     dl_line=1
     dl_printing=true
     if dl_npc.pages[dl_page].results~=nil then
      dl_options=true
      dl_choice=1
      dl_printing=false
     end
    end
    --toggle npcs
    local p=prev_npc.pages[prev_page]
    if p.toggle_npcs~=nil then
     for i=1,#p.toggle_npcs do
      for j=1,#npcs do
       if npcs[j].id==p.toggle_npcs[i] then
        if npcs[j].enabled then
         npcs[j].enabled=false
         npcs[j].place=-1
        else
         npcs[j].enabled=true
         npcs[j].place=current_place
        end
        break
       end
      end
     end
    end
    --get sword
    if prev_npc.id=="npc_sword" and p.done==true and prev_choice==2 then
     player.sword=1
     prev_npc.enabled=false
     prev_npc.place=-1
    end
    if(p.quest~=nil)quest=p.quest
    if p.attack~=nil then
     bs_player_choice=p.attack[prev_choice]
     current_bs=bs_your_anim
     bs_timer=0
    end
   end
  end
 end
 
 --update map overworld
 if current_mode==mode_map then
  local map_speed=2
  if(btnp(0))player.x-=map_speed
  if(btnp(1))player.x+=map_speed
  if(btnp(2))player.y-=map_speed
  if(btnp(3))player.y+=map_speed
  if(player.x<0)player.x=0
  if(player.x>250)player.x=250
  if(player.y<0)player.y=0
  if(player.y>123)player.y=123
  
  --transition to places
  for i=1,#places do
   local b={
    x=8*(map_text[i].tile_x-96),
    y=8*map_text[i].tile_y+1,
    w=6,h=7}
   if overlap(player,b) then
    start_trans(mode_place)
    load_place(i)
    player.x=60
    player.y=108
    if(i==5)player.y=118
    player.w=7+player.sword
    player.h=8
    break
   end
  end
 end
 
 --update battle
 if current_mode==mode_battle then
  bs_timer+=1
  if current_bs==bs_your_turn then
   --handled in dialog update
  elseif current_bs==bs_your_anim then
   if bs_timer>bs_anim_length then
    current_bs=bs_their_turn
    bs_timer=0
    
    --damage enemies
    local attack=0
    if(bs_player_choice=="punch")attack=player.level
    if(bs_player_choice=="sword")attack=100
    battle_e.health=max(0,battle_e.health-attack)
    new_battle_number(attack,100,40)
    
    if battle_e.health<=0 then
     current_bs=bs_victory
     bs_timer=0
     local d=enemy_data[battle_e.data_index]
     if(d.name==quest)quest_counter+=1
     if(d==enemy_boss)current_mode=mode_ending
     levelled_up=false
     player.xp+=enemy_data[battle_e.data_index].xp
     while player.xp>=xp_to_reach(player.level+1) do
      player.level+=1
      player.xp-=xp_to_reach(player.level)
      levelled_up=true
     end
    end
   end
  elseif current_bs==bs_their_turn then
   if bs_timer>=bs_think_length then
    current_bs=bs_their_anim
    bs_timer=0
   end
  elseif current_bs==bs_their_anim then
   if bs_timer>bs_anim_length then
    current_bs=bs_your_turn
    bs_timer=0
    local d=enemy_data[battle_e.data_index]
    local attack=d.attack
    if(d==enemy_boss and battle_e.turn<2)attack=0
    player.health=max(0,player.health-attack)
    new_battle_number(attack,24,70)
    battle_e.turn+=1
    if player.health<=0 then
     current_bs=bs_loss
     bs_timer=0
    end
   end
  elseif current_bs==bs_victory then
   --exit battle
   if bs_timer>1 and btnp(4) then
    start_trans(mode_place)
    battle_e=nil
   end
  elseif current_bs==bs_loss then
   if bs_timer>1 and btnp(4) then
    start_trans(mode_place)
    respawn()
   end
  end
 end
 
 --update battle numbers
 for n in all(battle_numbers) do
  n.x+=n.x_vel
  n.y+=n.y_vel
  n.y_vel+=battle_number_gravity
  n.life-=1
  if n.life<=0 then
   del(battle_numbers,n)
  end
 end
 
 if current_mode==mode_title then
  if btnp(4) then
   start_game()
   start_trans(mode_place)
  end
 end
end

function spr_outline(s,x,y,c)
 for i=1,16 do
  pal(i,c)
 end
 spr(s,x-1,y-1)
 spr(s,x,y-1)
 spr(s,x+1,y-1)
 spr(s,x-1,y)
 spr(s,x+1,y)
 spr(s,x-1,y+1)
 spr(s,x,y+1)
 spr(s,x+1,y+1)
 pal()
 spr(s,x,y)
end

function txt_outline(t,x,y,c1,c2)
 print(t,x-1,y-1,c2)
 print(t,x,y-1,c2)
 print(t,x+1,y-1,c2)
 print(t,x-1,y,c2)
 print(t,x+1,y,c2)
 print(t,x-1,y+1,c2)
 print(t,x,y+1,c2)
 print(t,x+1,y+1,c2)
 print(t,x,y,c1)
end

function print_name(offset)
 local n,c1,c2=dl_npc.name,dl_npc.c1,dl_npc.c2
 if(dl_options)n,c1,c2="you",player.c1,player.c2
 if current_mode==mode_battle or current_mode==mode_ending then
  n="actions"
  if current_bs~=bs_your_turn or current_mode==mode_ending then
   c1,c2=13,0
  end
 end
 txt_outline(n,t_offset,
  offset+t_offset,c1,c2)
end

function print_page(offset)
 local num_lines=not dl_printing and #dl_npc.pages[dl_page] or dl_line
 for i=1,num_lines do
  local char=(i<dl_line or not dl_printing) and #dl_npc.pages[dl_page][i] or dl_char
  local str=sub(dl_npc.pages[dl_page][i],1,char)
  local c1,c2=dl_npc.c3,dl_npc.c4
  local dx=0
  if(dl_options)dx,c1,c2=-1,player.c3,player.c4
  if (current_mode==mode_battle and current_bs~=bs_your_turn) or current_mode==mode_ending then
   c1,c2=5,0
  end
  txt_outline(str,t_offset+dx,
   offset+t_offset+i*line_height,
   c1,c2)
 end
end

function shade(x,y,w,h)
 for x=x,x+w-1 do
  for y=y,y+h-1 do
   pset(x,y,pget(x,y)<2 and 0 or 1)
  end
 end
end

function draw_map_text(x,y,c1,c2,c3,t1,t2,t3,t4)
 txt_outline(t1,x-2*#t1,y,c1,c2)
 txt_outline(t2,x-2*#t2,y+8,c1,c2)
 txt_outline(t3,x-2*#t3,y+16,c3,c2)
 txt_outline(t4,x-2*#t4,y+24,c3,c2)
end

function stretch(s,x,y,w,h,flip_x,flip_y)
 local sx=8*(s%16)
 local sy=8*flr(s/16)
 sspr(sx,sy,8,8,x,y,w,h,flip_x,flip_y)
end

function stretch_outline(outline_size,s,x,y,w,h,flip_x,flip_y)
 for i=1,16 do
  pal(i,0)
 end
 stretch(s,x-outline_size,y-outline_size,w,h,flip_x,flip_y)
 stretch(s,x,y-outline_size,w,h,flip_x,flip_y)
 stretch(s,x+outline_size,y-outline_size,w,h,flip_x,flip_y)
 stretch(s,x-outline_size,y,w,h,flip_x,flip_y)
 stretch(s,x+outline_size,y,w,h,flip_x,flip_y)
 stretch(s,x-outline_size,y+outline_size,w,h,flip_x,flip_y)
 stretch(s,x,y+outline_size,w,h,flip_x,flip_y)
 stretch(s,x+outline_size,y+outline_size,w,h,flip_x,flip_y)
 pal()
 stretch(s,x,y,w,h,flip_x,flip_y)
end

function healthbar(mid_x,top_y,w,h,health,max_health,flipped)
 rectfill(mid_x-w/2,top_y,
  mid_x+w/2,top_y+h,1)
 if health>0 then
  local percent=health/max_health
  local c=percent>0.34 and 3 or 8
  if flipped then
   rectfill(mid_x+w/2,top_y,
    mid_x+w/2-w*percent,
    top_y+h,c)
  else
   rectfill(mid_x-w/2,
    top_y,mid_x-w/2+w*percent,
    top_y+h,c)
  end
 end
 rect(mid_x-w/2,top_y,
  mid_x+w/2,top_y+h,0)
 local s=health.."/"..max_health
 txt_outline(s,mid_x-2*#s,top_y+3,7,0)
end

function sspr_outline(outline,sx,sy,sw,sh,dx,dy,dw,dh)
 for i=0,15 do
  pal(i,0)
 end
 sspr(sx,sy,sw,sh,dx-outline,dy-outline,dw,dh)
 sspr(sx,sy,sw,sh,dx,dy-outline,dw,dh)
 sspr(sx,sy,sw,sh,dx+outline,dy-outline,dw,dh)
 sspr(sx,sy,sw,sh,dx-outline,dy,dw,dh)
 sspr(sx,sy,sw,sh,dx+outline,dy,dw,dh)
 sspr(sx,sy,sw,sh,dx-outline,dy+outline,dw,dh)
 sspr(sx,sy,sw,sh,dx,dy+outline,dw,dh)
 sspr(sx,sy,sw,sh,dx+outline,dy+outline,dw,dh)
 pal()
 sspr(sx,sy,sw,sh,dx,dy,dw,dh)
end

function draw_npc(n)
 if n.id=="npc_boss" then
  sspr_outline(1,112,0,16,16,n.x,n.y,16,16)
 else
  spr_outline(n.s,n.x,n.y)
 end
end

function _draw()
 --draw transition
 if trans_mode==trans_in then
  for i=1,#trans do
   rectfill(trans[i].x1,127-8*(i-1),trans[i].x2,127-8*i,trans_col)
  end
  return
 end
 
 cls(0)
 
 --draw place
 if current_mode==mode_place or
    current_mode==mode_dialog
 then
  local p=places[current_place]
  map(p.x,p.y,0,0,16,16)
  
  --draw darkness
  local darkness=current_place==5 and not darkness_removed
  if darkness then
   cls(0)
   sspr(48,8,48,24,40,104)
  end
  
  --stairs
  if(current_place==6)palt(0,false)spr(69,60,96)palt()
  
  --draw enemies above player
  for i=1,#enemies do
   local e=enemies[i]
   if e.health>0 and e.y<=player.y then
    spr_outline(enemy_data[e.data_index].s,e.x,e.y)
   end
  end
  
  --draw npcs above player
  for i=1,#npcs do
   local n=npcs[i]
   if(n.enabled and n.y<=player.y)draw_npc(n)
  end
  
  --draw player
  if darkness then
   if player.x<56 or player.x>66 or player.y<112 then
    sspr(32,16,9,10,player.x-1,player.y-1)
   else
    spr_outline(player.s+player.sword,player.x,player.y)
   end
  else
   spr_outline(player.s+player.sword,player.x,player.y)
  end
  
  --draw enemies below player
  for i=1,#enemies do
   local e=enemies[i]
   if e.health>0 and e.y>player.y then
    spr_outline(enemy_data[e.data_index].s,e.x,e.y)
   end
  end
  
  --draw npcs below player
  for i=1,#npcs do
   local n=npcs[i]
   if(n.enabled and n.y>player.y)draw_npc(n)
  end
 end
 
 --draw overworld
 if current_mode==mode_map then
  local mx=max(-player.x+62,-128)
  local px=64
  if(player.x<64)px=player.x mx=-1
  if(player.x>190)px=player.x-126
  map(96,0,mx,0,32,16)
  
  local best,best_dist=-1,32760
  for i=1,#map_text do
   local dx=8*(map_text[i].tile_x-96)-player.x
   local dy=8*(map_text[i].tile_y)-player.y
   local dist=abs(dx)+abs(dy)
   if(dist<best_dist)best,best_dist=i,dist
  end
  local t=map_text[best]
  draw_map_text(mx+t.x,t.y,t.c1,
   t.c2,t.c3,t.t1,t.t2,t.t3,t.t4)
  
  spr_outline(18+player.sword,px,player.y)
 end
 
 --draw battle
 if current_mode==mode_battle
 or current_mode==mode_ending
 then
  for x=0,15 do
   for y=0,15 do
    spr(places[current_place].back_tile,8*x,8*y)
   end
  end
  local scale=4
  local size=8*scale
  local outline=3
  local anim_percent=bs_timer/bs_anim_length
  local d=enemy_data[battle_e.data_index]
  
  --draw player
  local s=player.s+player.sword
  local sx,sy=10,55
  if current_bs==bs_your_anim then
   sx+=bs_anim_size*anim_percent
   sy-=bs_anim_size*anim_percent
  end
  if(d==enemy_boss)size/=2 outline=2 sy+=16
  stretch_outline(outline,s,
   sx,sy,size,size)
  
  --draw player ui
  local width,height=68,10
  local hx=86-4*(1-player.sword)
  local hy=79
  healthbar(hx,hy,width,height,player.health,player.max_health)
  s="you (level "..player.level..")"
  txt_outline(s,hx-width/2+1,
   hy-7,7,0)
  
  --draw enemy
  sx,sy=86,16+scale*(8-d.h)
  if current_bs==bs_their_anim then
   sx-=bs_anim_size*anim_percent
   sy+=bs_anim_size*anim_percent
  end
  if d==enemy_boss then
   sspr_outline(2,112,0,16,16,
    sx,sy+32,32,32)
  else
   stretch_outline(outline,d.s,
    sx,sy,size,size,true)
  end
  
  --draw enemy ui
  hx=41+4*(8-d.w) if(d==enemy_boss)hx+=32
  hy=13
  healthbar(hx,hy,width,height,battle_e.health,d.health,true)
  s=d.name.." (level "..d.level..")"
  txt_outline(s,
   hx+width/2-4*#s+1,
   hy+height+3,7,0)
  
  --draw battle numbers
  for n in all(battle_numbers) do
   txt_outline(n.amount,n.x,n.y,n.c1,n.c2)
  end
  
  if current_bs==bs_victory then
   shade(0,0,128,128-dl_height)
   
   --redraw battle numbers
   for n in all(battle_numbers) do
    txt_outline(n.amount,n.x,n.y,5,0)
   end
   
   if current_mode==mode_ending then
    --draw ending
    local s="congratulations!"
    txt_outline(s,64-2*#s,40,11,3)
    
    s=frame/30
    local tenths=flr(10*(s-flr(s)))
    s="" if(minutes<10)s="0"
    s=s..minutes..":"
    if(seconds<10)s=s.."0"
    s=s..seconds.."."..tenths
    s="you beat the game in "..s
    txt_outline(s,64-2*#s,55,6,2)
    s="and set a new world record!"
    txt_outline(s,64-2*#s,65,6,2)
    
    s="thanks for playing!"
    txt_outline(s,64-2*#s,80,7,0)
   else
    --draw victory
    local s,y="victory!",45
    txt_outline(s,64-2*#s,y,11,3)
    s="you earned "..enemy_data[battle_e.data_index].xp.." xp"
    y+=12
    txt_outline(s,64-2*#s,y,6,2)
    y+=12
    if levelled_up then
     s="levelled up to level "..player.level.."!"
     txt_outline(s,64-2*#s,y,9,2)
    else
     s="just "..(xp_to_reach(player.level+1)-player.xp).." xp more to level up"
     txt_outline(s,64-2*#s,y,6,2)
    end
   end
  end
  
  --draw loss
  if current_bs==bs_loss then
   shade(0,0,128,128-dl_height)
   
   --redraw battle numbers
   for n in all(battle_numbers) do
    txt_outline(n.amount,n.x,n.y,5,0)
   end
   
   local s="you have been defeated"
   txt_outline(s,64-2*#s,61,8,0)
  end
 end
 
 --draw title
 if current_mode==mode_title then
  map(0,16,0,0,16,16)
  for x=0,16 do
   for y=0,16 do
    if x==0 or x==16 or y==0 or y==16 then
     spr(65,-4+8*x,-4+8*y)
    end
   end
  end
  
  local y=12+2*sin(title_y)
  sspr(79,32,49,20,15,y,98,40)
  txt_outline("d o n e   q u i c k",
   25,y+42,15,1)
  
  local lines={
   "you are at a speedrun event.",
   "you're trying to complete an",
   "rpg as quickly as possible,",
   "skipping as much as you can."
  }
  for i=1,#lines do
   txt_outline(lines[i],64-2*#lines[i],
    60+9*i,6,0)
  end
  
  local s="press <z> to start"
  --txt_outline(s,66.5-2*#s+5*cos(title_y),110,12,1)
  txt_outline(s,64-2*#s,110,12,1)
 end
 
 --draw dialog
 if current_mode==mode_dialog
 or current_mode==mode_battle
 or current_mode==mode_ending
 then
  local offset=dl_npc.dl_offset
  shade(0,offset,128,dl_height)
  local c=dl_options and player.c2 or dl_npc.c2
  local darken=current_mode==mode_ending or (current_mode==mode_battle and current_bs~=bs_your_turn)
  if(darken)c=0
  rect(1,offset+1,126,offset+dl_height-2,c)
  --rect(0,offset,127,offset+dl_height-1,dl_options and player.c2 or dl_npc.c2)
  print_name(offset)
  print_page(offset)
  
  --draw dialog cursor
  local f=frame%20<10 and 0 or 1
  if(darken)f=0 pal(7,13)
  if dl_options then
   spr(11,t_offset+f,offset+t_offset+dl_choice*line_height)
  elseif not dl_printing then
   pal(7,dl_npc.c2)
   if dl_page<#dl_npc.pages and not dl_npc.pages[dl_page].done then
    spr(10,119,offset+dl_height-8+f)
   else
    spr(11,119+f,offset+dl_height-10)
   end
  end
  pal()
 end
 
 if current_mode~=mode_title
 and current_mode~=mode_ending
 then
  --draw timer
  shade(0,0,30,8)
  rect(-1,-1,29,7,0)
  if frame%30==0 then
   seconds+=1
   if seconds>=60 then
    seconds-=60
    minutes+=1
   end
  end
  local s=frame/30
  local tenths=flr(10*(s-flr(s)))
  s="" if(minutes<10)s="0"
  s=s..minutes..":"
  if(seconds<10)s=s.."0"
  s=s..seconds.."."..tenths
  print(s,1,1,7)
 
  --draw quest ui
  if quest~=nil then
   local s="kill "..quest.."s "
   if(quest_counter<10)s=s.."0"
   s=s..quest_counter.."/"
   if(quest_max<10)s=s.."0"
   s=s..quest_max
   local x=126-4*#s
   shade(x,0,127,8)
   rect(x,-1,128,7,0)
   print(s,x+2,1,7)
  end
 end
 
 --draw debug
 if debug and current_mode==mode_place then
  --draw level bounds
  for i=1,#bounds do
   local b=bounds[i]
   rect(b.x,b.y,b.x+b.w-1,b.y+b.h-1,0)
  end
  
  --draw npc bounds
  for i=1,#npcs do
   local n=npcs[i]
   if(n.enabled)rect(n.x,n.y,n.x+n.w-1,n.y+n.h-1,7)
  end
  
  --draw enemy bounds
  for i=1,#enemies do
   local e=enemies[i]
   if(e.health>0)rect(e.x,e.y,e.x+e.w-1,e.y+e.h-1,8)
  end
  
  --draw player bounds
  local p=player
  rect(p.x,p.y,p.x+p.w-1,p.y+p.h-1,14)
 end
 
 --draw transition
 if trans_mode==trans_out then
  for i=1,#trans do
   rectfill(trans[i].x1,127-8*(i-1),trans[i].x2,127-8*i,trans_col)
  end
 end
 
 if(current_mode~=mode_ending)frame+=1
 title_y+=0.014
end
__gfx__
0000000000666600400004000777000000055500000aaa000222200000006600000800000011223377777000700000000000000000000000000000d66d000000
0000000000656500040444607d7d70000051410000a1f1000022220000066600008e800000112233077700007700000000000000000000000000d633336d0000
007007000066660000444444777770000054440600afff000222222000666000008e8000445566770070000077700000000000000000000000dd633ff336dd00
0007700000060000000404007777700000040006000f000000f1f10026660000008e80004455667700000000770000000000000000000000066663f88f366660
00077000066666000000000077777000055555060eeeee0000ffff0002600000008e80008899aabb000000007000000000000000000000006666633ff3366666
0070070060666060000000007070700040555045f0eee0f00999990020200000008880008899aabb000000000000000000000000000000006666663333666666
0000000000606000000000000000000000d0d00000202000f09990f000000000008e8000ccddeeff00000000000000000000000000000000d66666311366666d
000000000600600000000000000000000d00d0000200200000e0e0000000000000080000ccddeeff00000000000000000000000000000000d66d66333366d66d
00044400000444000f0000000006000000000030bbbbbbbb0000000000000000010505050105050500000000000000000000000000000000666d66664446d666
0041f1000041f100888000000f06000000000333bbbbbbbb00000000000000005050f0505050f0500000000000000000000000000000000066606444f4440666
004fff00004fff06080000008882000000003233bbbbbbbb000000000000000005050505050505050000000000000000000000000000000033344f4444400333
000f0000000f0006101000000800000000333333bbbbbbbb00000000000000001050505010505050000000000000000000000000000000003333444f42000330
088888000888880600000000101000000a983333bbbbbbbb00000000000000000505050505050505000000000000000000000000000000004330022222200000
f08880f0f08880f20000000000000000a9930000bbbbbbbb000000000000000050505050505050500000000000000000000000000000000000000d2002d00000
001010000010100000000000000000000a000000bbbbbbbb00000000000000000505050505050505000000000000000000000000000000000000022002200000
0100100001001000000000000000000000000000bbbbbbbb00000000000000005050505050505050000000000000000000000000000000000000111001110000
0001110000011100000000000006000000011111000000000000000001050505515555155155551501050505000000000000000000000000bbbbbbbb00000000
001f4f00001f4f0004000000040600000011000100000000000000005050f0505555f5555555f5555050f050000000000000000000000000bbbbbbbb00000000
0014440000144406888000008882000000100001000000000000000005050505555555555555555505050505000000000000000000000000bbbbbbbb00000000
0004000000040006080000000800000000100001000000000000000010505050155555551555555510505050000000000000000000000000bbbbbbbb00000000
0888880008888806101000001010000001110111000000000000000005050505552515555525155505050505000000000000000000000000bbbbbbbb00000000
4088804040888042000000000000000011000001100000000000000050505050555555555555555550505050000000000000000000000000bbbbbbbb00000000
0010100000101000000000000000000010100010100000000000000005050505551555f5551555f505050505000000000000000000000000bbbbbbbb00000000
0100100001001000000000000000000011101011100000000000000050505050555555555555555550505050000000000000000000000000bbbbbbbb00000000
0000000000000000000000000000000001011010000000000606060666666656515555155155551566666656060606060000000000000000bbbbbbbbbbbbbbbb
00000000000000000000000000000000011111100000000050505050555555555555f5555555f55555555555505050500000000000000000bbbbbbbbbbbbbbbb
0000000000000000000000000000000000000000000000000606060666566666555555555555555566566666060606060000000000000000bbbbbbbbbbbbbbbb
0000000000000000000000000000000000000000000000005050505055555555155555551555555555555555505050500000000000000000bbbbbbbbbbbbbbbb
0000000000000000000000000000000000000000000000000606060666666656552515555525155566666656060606060000000000000000bbbbbbbbbbbbbbbb
0000000000000000000000000000000000000000000000005050505055555555555555555555555555555555505050500000000000000000bbbbbbbbbbbbbbbb
0000000000000000000000000000000000000000000000000606060666566666551555f5551555f566566666060606060000000000000000bbbbbbbbbbbbbbbb
0000000000000000000000000000000000000000000000005050505055555555555555555555555555555555505050500000000000000000bbbbbbbbbbbbbbbb
99999999ffffff1f51555515666666565dd555555000005500000000000000000000000000000000001111111000000011111110000000011111000000000000
95599999111111115555f555555555555dd225555dd0000000000000000000000000000000000000011111111100000111111111000000111111100000000000
99999559ff1fffff55555555665666665dd221155dd2200000000000000000000000000000000000111f11ff111000111f11ff1110001111fff1110000000000
999999991111111115555555555555555dd221155dd221100000000000000000000000000000000111ff1ffff1110111ff1ffff11101111fffff111000000000
99999999ffffff1f5525155566666656500221155dd22110000000000000000000000000000000011ffff111ff11111ffff111ff11111ff1111ff11100000000
9955999911111111555555555555555550000115555221100000000000000000000000000000000111ff11111ff11111ff11111ff1111f111111ff1100000000
99999999ff1fffff551555f56656666650000005555551100000000000000000000000000000000011ff11111ff11111ff11111ff111ff111111f11100000000
9999999911111111555555555555555555555555555555550000000000000000000000000000000011ff11111ff11111ff11111ff111ff11111f111110000000
b3bbbb3bbbbbbbbb99999999bbbbbbbb00000000000000000000000000000000000000000000000011ff1111ff111111ff1111ff111ff1111111111111111100
bbbbabbbbb3333bb99900999bbb00bbb00000000000000000000000000000000000000000000000011ff111ff1111111ff111ff1111ff1111111111111111110
bbbbbbbbb333333b99000099bb0000bb00000000000000000000000000000000000000000000000011ffffff11111111ffffff11111ff111fffff1111ffff111
3bbbbbbbb333333b99000099bb0000bb00000000000000000000000000000000000000000000000011fffff111111111fffff111011ff1111fffff11ff11ff11
bb9b3bbbbb3333bb90000009b000000b00000000000000000000000000000000000000000000000011ff11ff11111111ff111110011ff1111111ff11ff111f11
bbbbbbbbbbb44bbb90000009b000000b00000000000000000000000000000000000000000000000011ff111ff1111111ff1111000111ff111111ff111fff1111
bb3bbbabbb4444bb90000009b000000b00000000000000000000000000000000000000000000000011ff1111f1111111ff1100000011ff111111ff1111fff111
bbbbbbbbbbbbbbbb90000009b000000b00000000000000000000000000000000000000000000000111ff11111f111111ff11000000111ff1111ff1111111ff11
d2dddd2ddddddddddddddddd444444440000000000000000000000000000000000000000000000011fff11111ff1f11fff1110000001111fffff1111ff11ff11
dddd6dddddddddddddd00ddd4440044400000000000000000000000000000000000000000000000111fff11111ff1111fff1100000001111fff111111ffff111
ddddddddddd2dd2ddd0000dd44000044000000000000000000000000000000000000000000000000111111101111111111111000000000111111100111111110
2dddddddd2dd22dddd0000dd44000044000000000000000000000000000000000000000000000000011111000111100111110000000000011111000011111100
dd5d2ddddd222dddd000000d40000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddddd222ddd000000d40000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd2ddd6dddd22dddd000000d40000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddddddddddd000000d40000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45444454444444445555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44441444444554445550055500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444445555445500005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
54444444455555545500005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44d45444451515545000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444455151545000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44544414455555545000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444445000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000001010000000000010001202000000000000000000000000102040000000000000000000000000001081000000000000000000000000000012000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4141414141414141414141414141414151515151515151515151515151515151616161616161616161616161616161617171717171717171717171717171717143434343434343434343434343434343434343434343434343434343434343435051505050505050505050505051507070707071707070707070707070707170
4140404040404040404040414040404151505050505050505050505050505051616060606060606060606060606060617170707070707070707070707070707143424242424343434343424242424243434343434343434343434343434343435050505050515050505050505050505070707070707071717170707070707070
4140404040404040404040414040404151505050505050505050505050505051616060606060606060606060606060617170707070707070707070707070707143424442424243434342424242424243434343434343424242424343434343435050505050505050515151505150505070707070707071637170707070707070
4140404141404040404040414040404151505050505050505050505050505051616060606060616161606060606060617170707070717171717171707070707143424242424243434242424243424243434343434242424242424242434343435050515050505050515351505050505050707170707071707170707170707071
4140404041404040404040414040404151505050515150505050505050505051616061616161616061616060606060617170707071717070707071717070707143424242424343424242424343424243434342424242424242424242424243434050505050505050515051505050505050707070707070707070707070707070
4140404041414141404040404040404151505051515151505050505050505051616161606060606060616160606060617170707071707070707070717070707143424242434342424242434343424243434342424242424242424242424243434040405050515050505050515050515060606060607070717070704242424242
4140404041404041414140404040404151505050515150505050505151505051616060606060606060606160606060617170707071707070707070717070707143424243434242424343434342424243434242424242424242424242424242434040404050505050505050505050506060606160606070707042434242424342
4140404041404040404141414040404151505050505050505050515151515051616060606060606060606161606060617170707171707070707070717070707143424243424242434342424242424243434242424242424242424242424242434041404040405050505150505050606060606060606170424242424242424242
4140404040404040404040414140404151505050505050505050505151505051616060606061616160606061606060617170707171707070707071717070707143424242424242434242424242434343434242424242424242424242424242434040404040404050505050506060606060606060606060424242424243434342
4140404040404040404040404141404151505050505050505050505050505051616060606161606161606061616060617170707170707070707071707070707143424242424243434242434343434343434242424242424242424242424242434040404040404040505050606060606061616160606060424243424243724342
4140404141414141404040404041414151505050505151505050505050505051616060606160606061606060616060617170707170707070707171707070707143434343434343434242424243434343434342424242424242424242424243434040404141414040405050606061606061626160606042424242424243424342
4140404140404041414140404040404151505050515151515050505050505051616060616160606061616060606060617170707170707171717170707070707143434342424242434242424242424343434342424242424242424242424243434040404152414040415060606060606061606160606042424242424242424242
4140404140404040404040404040404151505050505151505050505050505051616060616060606060616060606060617170707070707171707070707070707143434242424242434343434242424343434343434242424242424242434343434040404140414040406060606060606060606060604243424242424242424242
4140414140404040404040404040404151505050505050505050505050505051616060606060606060616160606060617170707070707170707070707070707143434242434242424242424242434343434343434343424242424343434343434140404040404040406061606060606160606060604242424242434242424342
4140414040404040404040404040404151505050505050505050505050505051616060606060606060606160606061617170707070717170707070707070707143434242434242424242424243434343434343434343434343434343434343434040404040404040404060606060606060606060424242424242424242424242
4141414141414140404141414141414151515151515151505051515151515151616161616161616060616161616161617171717171717170707171717171717143434343434343424243434343434343434343434343434343434343434343434040404041404040404060606160606060606060424242434242424242424242
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
