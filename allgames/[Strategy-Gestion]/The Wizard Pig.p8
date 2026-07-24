pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- the wizard pig
-- by @powersaurus

--f_update=nil
--f_draw=nil

sounds_on=true
width=512
height=128

landscape_data={}

num_subjects=32
happiness={}
scores={}
subjects={}
max_mana=20
mana_balls={}
foods={}
num_foliage=32

--henry={}
--megacow={}
--omnichicken={}
target_none=0
target_enemy=1
target_land=2
target_mana=3
target_follower=4
target_build=5
target_plant=6
castles={}
max_speed=3.5
num_bullets=50
bullets={}
bullet_ptr=1
bullet_flip=false
bullet_cooldown=0

num_explosions=100
explosions={}
explosion_ptr=1

red_mana=1
green_mana=2
yellow_mana=3
blue_mana=4
powers={
 {
  name="raise",
  light=1,
  dark=2,
  icon=1,
  mana=yellow_mana,
  sound=1,
  tip="raise creates hills"
 },
 {
  name="lower",
  light=8,
  dark=2,
  icon=2,
  mana=yellow_mana,
  sound=4,
  tip="lower digs valleys"
 },
 {
  name="fire",
  light=9,
  dark=8,
  icon=17,
  mana=red_mana,
  tip="fire destroys land and foliage"
 },
 {
  name="forest",
  light=11,
  dark=3,
  icon=18,
  mana=green_mana,
  sound=1,
  tip="forest plants grass and plants"
 },
 {
  name="rain",
  light=13,
  dark=12,
  icon=219,
  mana=blue_mana,
  sound=5,
  tip="rain puts out fires, grows crops"
 }
}
num_powers=5
raise_power=0
lower_power=1
fire_power=2
forest_power=3
rain_power=4
timer=0
anim_timer=0

lower=false
raise=false

bg={}
num_particles=128
particles={}
particle_ptr=1

damage=1
stuck=2
fire=3

pregame=false

wizard_templates={
{
"henry",147,0
},
{
"megacow",163,32
},
{
"omnichicken",179,64
},
{
"celestial kitten",183,96
}
}

function rand(x)
 return flr(rnd(x))
end

function clamp(v,minval,maxval)
 return min(maxval,max(minval,v))
end

function mus(id,chan)
 chan=chan or 0
 if sounds_on then
  music(id,chan)
 end
end

function sound(id,chan)
 chan=chan or 1
 if stat(16+chan)==-1 and sounds_on then
  sfx(id,chan)
 end
end

function position_sound(id,x,chan)
 if x>=cx and x<cx+128 then
  sound(id,chan)
 end
end

function player_sound(id,team)
 if team==1 then sound(id) end
end

--[[function _init()
 init_explosions()
 for y=0,7 do
  for x=0,7 do     
   local b={}
   b.x=4+x*16
   b.y=4+y*16
   b.frame=0
   b.frames=5
   b.delay=0
   b.life=18000
   b.typ=171
   add(explosions,b)
  end
 end
end

function _draw()
 cls(0)
 
 draw_explosions(explosions)
end

function _update()
 timer+=1
 if timer%4==0 then
  anim_timer+=1
 end
 
 update_explosions(explosions)
end]]

function _init()
 mus(0,0)
 for i=1,#title_heights do
  title_heights[i]+=rnd(1)-0.5
 end
 title_bg={}
 for i=0,128 do
  title_bg[i+1]=30
 end
 heightmap(title_bg,128,70)
 selected_character=false
 
 _update=update_title
 _draw=draw_title
end

function init_level()
 local pick=1+selection[1]+selection[2]*2
 local template=
  wizard_templates[pick]
 local opponent_pick=1+rand(4)
 while opponent_pick==pick do
  opponent_pick=1+rand(4)
 end
 local opponent_template=
  wizard_templates[opponent_pick]
 
 henry=make_wizard(
  width/5,
  1,
  true,
  template[1],
  template[2],template[3]
 )
 henry.update=update_henry
 henry.y=-128

 megacow=make_ai_wizard(
  width/5*4,
  2,
  false,
  opponent_template[1],
  opponent_template[2],opponent_template[3]
 )
 megacow.update=update_megacow
 
 wizards={henry,megacow}

 castles[1]={
  x=width/5,
  flag=142
 }
 castles[2]={
  x=width/5*4,
  flag=158
 }
 cx=henry.x
 cy=henry.y
 
 build_landscape()
 init_subjects()
 init_particles()
 init_bullets()
 init_explosions()
  
 happiness[1]={0,1}
 happiness[2]={0,1}
 scores={{
  score=5,
  anim_timer=0,
  up=false
 },
 {
  score=5,
  anim_timer=0,
  up=false
  }
 }
 used_power=false
 changed_power=false
 help_msg="make your followers happy to win!"
 help_msg="make followers happy to win!"
 help_msg_timer=90
 game_end_timer=-1
 game_end_message=nil
 game_end_result=0
 
 belief_lines={{},{}}
 issues={{0,0,0},{0,0,0}}
 
 explode(henry,176,100,50,6)
 timer=0
 mus(7)
end

function make_entity(x,y,vx,vy,frame,frames)
 return {
  x=x,
  y=y,
  vx=vx,
  vy=vy,
  frame=frame,
  frames=frames
 }
end

function init_bullets()
 for i=1,num_bullets do
  local b=make_entity(-16,-16,0,0,0,4)
  b.life=0
  bullets[i]=b
 end
end
 
function init_particles()
 for i=1,num_particles do
  local p=make_entity(-1,-1,0,0,0,4)
  p.life=0
  p.colour=0
  particles[i]=p
 end
end
 
function init_explosions()
 for i=1,num_explosions do
  local e=make_entity(-1,-1,0,0,0,4)
  e.life=0
  explosions[i]=e
 end
end

function make_ai_wizard(
 x,team,face_right,name,
 small_sprite,big_sprite)
 
 local wizard=make_wizard(
  x,team,face_right,name,
  small_sprite,big_sprite)
 
 wizard.target_x=henry.x
 wizard.target_y=henry.y
 wizard.target=target_none
 wizard.next_target=1
 wizard.basex=wizard.x
 
 return wizard
end

function make_wizard(x,team,face_right,name,small_sprite,big_sprite)
-- local ent=make_entity(x,16,0,0,0,4)
 return {
  x=x,
  y=16,
  vx=0,
  vy=0,
  frame=0,
  frames=4,
  face_right=face_right,
  team=team,
  power_on=false,
  power=0,
  laser_timer=0,
  god_mode=false,
  belief=0,
  mana={5,5,5,5},
  name=name,
  small_sprite=small_sprite,
  big_sprite=big_sprite
 }
end

function heightmap(landscape,h_width,var) 
 step=flr(h_width/2)
 while(step>=1) do
  t=1
  while(t<=h_width) do
   left=t
   right=t+step
   if right>h_width then right-=h_width end
 	 landscape[flr(t+step/2)]=
 	  ((landscape[left]+
 	    landscape[right])/2)
 	    +(rnd(var)-(var/2)) 
   t+=step
  end
  var/=2
  step/=2
 end 
end

function build_landscape()
 local landscape={}
 local seg_height=rnd(128)+32
 for i=1,width do
  if i%32==0 then seg_height=rnd(128)+32 end
  landscape[i]=seg_height
 end
 for i=1,20 do
  landscape[i]+=50
  landscape[width-i]+=50
 end

 var=120
 step=flr(width/2)
 while(step>=1) do
  t=1
  while(t<=width) do
   left=t
   right=t+step
   if right>width then right-=width end
 	 landscape[flr(t+step/2)]=
 	  ((landscape[left]+
 	    landscape[right])/2)
 	    +(rnd(var)-(var/2)) 
   t+=step
  end
  var/=2
  step/=2
 end
  
 for i=1,width do
  bg[i]=landscape[i]-16
  
  landscape_data[i]={
   x=i,
   height=landscape[i],
   original_height=landscape[i],
   damage=0,
   team=0,
   timer=-1
  }
 end
  
 for i=1,num_foliage do
  local x=rand(width)+1
  
  add_foliage(landscape_data[x],20)
 end
end

function init_subjects()
 for i=1,num_subjects do
  local x=rnd(width/4)
  local team=henry.team
  if i%2==1 then
   team=megacow.team
   x=width-rnd(width/4)
  end
  subjects[i]={
   x=x,
   y=floor_for(x),
   vx=rand(2)*2-1,
   vy=0,
   frame=0,
   frames=3,
   team=team,
   happiness=50,
   dist_travelled=0,
   happiness_timer=rand(60),
   range=100
  }
 end
end

--[[function _update()
 f_update()
end]]

selection={0,0}
function update_title()
 if btnp(5) then
  if character_select then
   sound(2)
   init_level()
   _update=update_level
   _draw=draw_level
  else
   sound(3)
   character_select=true
  end
 end
 if character_select then
  t_cam_y=clamp(t_cam_y-10,-128,0)
  
  if btnp(0) then
   selection[1]=max(selection[1]-1,0)
   sound(0)
  end
  if btnp(1) then
   selection[1]=min(selection[1]+1,1)
   sound(0)
  end
  if btnp(2) then
   selection[2]=max(selection[2]-1,0)  
   sound(0)
  end
  if btnp(3) then
   selection[2]=min(selection[2]+1,1)    
   sound(0)
  end
 end
end

function update_level()
-- msg=nil

 timer+=1
 if timer%4==0 then
  anim_timer+=1
 end
 help_msg_timer-=1
 if help_msg_timer==0 then
  help_msg_timer=60
 end
 
 if game_end_timer>0 then
  game_end_timer-=1
 elseif game_end_timer==0 then
  init_level()
  return
 end
 
 update_input()
 
 -- this is the apocalypse
 if game_end_result==2 then
  spawn_bullet(rnd(width),-200,0,1,14)
 elseif game_end_result==1 then
  local winner_rays={}
  for i=1,15 do
   local a=(timer%360+i*24)/360
   winner_rays[i]={
    wizards[game_winner].x+16-sin(a)*100,
    wizards[game_winner].y+16-cos(a)*100,
   }
  end
  belief_lines[game_winner]=winner_rays
 end

 local oh={
  happiness[1][1]/happiness[1][2],
  happiness[2][1]/happiness[2][2]
 }
 happiness[1]={0,1}
 happiness[2]={0,1}
 
 for z=1,2 do
  issues[z][stuck]=0
  issues[z][damage]=0
  issues[z][fire]=0
 end
 
 for i=1,num_subjects do
  local subject=subjects[i]  
  update_subject(subject)
  
  happiness[subject.team][1]+=subject.happiness
  happiness[subject.team][2]+=1
 end
 
 for w in all(wizards) do
  w:update()
  fire_bullets(w)
  laser_powers(w)
  check_scores(w,oh)
 end
  
 for i=1,num_particles do
  local particle=particles[i]
  
  if particle.life>0 then  
   particle.life-=1
   particle.vy+=0.9
   particle.x+=particle.vx
   particle.y+=particle.vy
   if particle.col then
    if particle.y>floor_for(particle.x) then
     particle.life=0
     particle.vy=0
    end
   end
  end
 end
  
 for mb in all(mana_balls) do
  update_mana_ball(mb,mana_balls)
  for w in all(wizards) do
   collect_mana(w,mb)  
  end
 end
 
 for f in all(foods) do
  update_mana_ball(f,foods)
  for s in all(subjects) do
   collect_food(s,f)
  end
 end

 for b in all(bullets) do
  update_bullet(b)
 end
 
 update_explosions(explosions)
 
 for ld in all(landscape_data) do
  if ld.timer>0 then
   ld.timer-=1
  end
  
  local min_diff=0.3
  if ld.height-ld.original_height>min_diff then
   ld.height-=0.05
  elseif ld.height-ld.original_height<-min_diff then
   ld.height+=0.05
  end
  if ld.damage<-4 and ld.damage>-35 and ld.timer==0 then
   ld.timer=120+rand(120)
   spawn_food(ld.x,height-ld.height)
  end
  if ld.damage<0 then
   ld.damage+=0.01
  end
 end
end

function update_explosions(explosions)
 for e in all(explosions) do
  if e.life>0 then
   if e.delay>0 then
    e.delay-=1
   else
    if timer%2==0 then
     e.frame=(e.frame+1)%e.frames
    end
    e.life=e.life-1
   end
  end
 end
end

function check_scores(user,oh)
 if game_end_timer>=0 then
  return
 end
 
 check_should_increase_score(user.team,oh)
 check_should_decrease_score(user.team,oh)
 
 if scores[user.team].score==10 then
  game_end_timer=150
  game_end_message=user.name.." is victorious!"
  game_end_result=1
  game_winner=user.team
  mus(15)
 elseif scores[user.team].score==0 then
  user.god_mode=false
  sound(6)
  user.power_on=false
  user.belief=0
  belief_lines[1]={}
  belief_lines[2]={}
  explode(user,176,80,25,12)
  power_off(user)
  game_end_result=2
  game_end_timer=150
  game_end_message=user.name.." is vanquished!"
  mus(14)
 end
end

function update_mana_ball(mb,col)
 local of=floor_for(mb.x)
 local oy=mb.y

 mb.life-=1  
 mb.vy+=0.9
 mb.x+=mb.vx
 mb.y+=mb.vy
  
 local floor=floor_for(mb.x)

 mb.y=min(floor,mb.y)
 if floor==mb.y then   
  mb.vy*=-0.9
  if of==oy and floor<of then
   mb.vx*=0.8
  elseif floor>of then
   mb.vx*=1.2
  else
   mb.vx*=0.9
  end
 end
 
 if mb.life==0 then
  explode(mb,176,4,10,12)
  position_sound(8,mb.x)
  del(col,mb)
 end
end

function check_should_increase_score(team,oh)
 if oh[team]<90 and happiness_for_team(team)>=90 then
  scores[team].score=scores[team].score+1
  scores[team].anim_timer=60
  scores[team].up=true
  reset_happiness(team)
  explode({x=castles[team].x,y=height-floor_for(castles[team].x)},176,4,10,12)
  player_sound(10,team)
  if scores[2].score==9 then
   mus(13)
  end
  if team==1 and scores[team].score==2 then
   mus(7)
  end
 end
end

function check_should_decrease_score(team,oh)
 if oh[team]>=10 and happiness_for_team(team)<10 then
  scores[team].score=scores[team].score-1
  scores[team].anim_timer=60
  scores[team].up=false
  reset_happiness(team)
  player_sound(11,team)
  if scores[1].score==1 then
   mus(13)
  end
  if team==2 and scores[team].score==8 then
   mus(7)
  end
 end
end

function reset_happiness(team)
 for s in all(subjects) do
  if s.team==team then s.happiness=50 end
 end
end

function collect_mana(user,mb)
 local xmod=4
 local ymod=8
 
 if user.god_mode then
  xmod=16
  ymod=16
 end
 
 if abs(mb.x-user.x)<xmod
 and abs(mb.y-user.y)<ymod
 and user.mana[mb.typ+1]<max_mana
 then
  user.mana[mb.typ+1]+=5
  del(mana_balls,mb)  
  player_sound(3,user.team)
 end
end

function collect_food(user,f)
 local xmod=4
 local ymod=8
 
 if abs(f.x-user.x)<xmod
 and abs(f.y-user.y)<ymod
 then
  user.happiness+=1
  del(foods,f)
 end
end


function spawn_mana(x,y)
 local mb={}
 
 mb.x=x
 mb.y=y
 mb.vy=-8
 mb.vx=rnd(6)-3
 mb.typ=rand(4)
 mb.life=60
 
 add(mana_balls,mb)
end

function spawn_food(x,y)
 if #foods>80 then
  return
 end

 local f={}
 
 f.x=x
 f.y=y
 f.vy=-4
 f.vx=rnd(4)-2
 f.life=60
 

 add(foods,f)
end

function update_henry(henry)
 if henry.god_mode then
  update_god_henry()
 else
  update_walker(henry,-10)
  henry.vx*=0.9
 end
 calculate_belief(henry)
 
 if help_msg_timer==30 then
  if timer<120 then
   help_msg="defend them from your rival..."
  elseif timer<180 then
   help_msg="grow trees and crops for them..."
  elseif timer<240 then
   help_msg="this will keep them happy!"
  elseif timer<320 then
   help_msg="go for it "..henry.name.."!"
  elseif henry.belief<140 then
   help_msg="find followers to gain power!"
  elseif need_mana(henry) then
   help_msg="find mana balls!"
  else
   help_msg=biggest_issue(henry)
  end
 end
end

function biggest_issue(user)
 local issue_stuck=issues[user.team][stuck]
 local issue_fire=issues[user.team][fire]
 local issue_damage=issues[user.team][damage]
 
 if issue_stuck>0 or issue_fire>0 or issue_damage>0 then
  if issue_stuck>=issue_fire and issue_stuck>=issue_damage then
   return "your followers are stuck!"
  elseif issue_fire>=issue_damage and issue_fire>=issue_stuck then
   return "put out the fires with rain!"
  else
   return "plant some trees!"
  end
 else
  if not used_power then
   return "press Ž to use power"
  elseif not changed_power then
   return "press — to change power"
  end
  return powers[1+user.power].tip -- "use your powers!"
 end
end

function calculate_belief(user) 
 if pregame or game_end_timer>0 then
  return
 end
 local ob=user.belief
 user.belief=clamp(user.belief-1,0,1000)
 local dist_from_subject=1000
 
 local hx=user.x+4
 if user.god_mode then hx+=12 end
 
 local extra_belief=0
 belief_lines[user.team]={}
 for s in all(subjects) do
  local d=abs(s.x-hx)
  if s.team==user.team and d<10 then
   if s.happiness<40 then
    extra_belief+=0.5
   else
    extra_belief+=2
   end
   add(belief_lines[user.team],{s.x,s.y})
  end
 end
 user.belief+=extra_belief
  
 if ob<100
 and user.belief>=100 then
  user.god_mode=true
  sound(2)
  user.belief+=150
  explode(user,176,80,25,12)
 elseif ob>=100
 and user.belief<100 then
  user.god_mode=false
  sound(6)
  user.power_on=false
  user.belief=0
  explode(user,176,80,25,12)
  power_off(user)
 end
 
 user.belief=clamp(user.belief,0,350)
 --msg="b:"..henry.belief
end

function happiness_for_team(team)
 return happiness[team][1]/happiness[team][2]
end

function need_mana(user)
 return user.mana[powers[user.power+1].mana]==0
end

function update_god_henry()
 local oldy=henry.y

 local newx=henry.x+henry.vx
 if newx<-24 or newx>width-24 then
  henry.vx*=-1
 end
  
 henry.vx*=0.99
 henry.x+=henry.vx
 henry.y+=henry.vy
 
 local floor=floor_for(henry.x+16)-24
 
 henry.y=min(floor,henry.y)
 
 if henry.y==floor then henry.vy=0 end
 
 if henry.mana[powers[henry.power+1].mana]<=0 and henry.power_on then
  henry.power_on=false
  for i=0,5 do
   spawn_particle(henry.x+rnd(32),henry.y+24,72,112)
  end
 end
end

function power_on(user)
 user.power_on=true
 user.laser_timer=0
end

function power_off(user)
 user.power_on=false
end

function update_megacow(user,user_mana)
 -- next move
 user.next_target=user.next_target-1
 
 if user.next_target==0 then
  user.dist_travelled=0
  pick_target(user,user_mana)
 end

 pick_power(user)
 
 if user.god_mode then
  local oldy=user.y
 
  user.vx*=0.99
 
  local newx=user.x+user.vx
  if newx<1 or newx>width then
   user.vx*=-1
  end
  user.x+=user.vx
  user.y+=user.vy
 
  local floor=floor_for(user.x+16)-24
 
  user.y=min(floor,user.y)
 
  if user.y==floor then user.vy=0 end
 
  if user.mana[powers[user.power+1].mana]<=0 then user.power_on=false end
 else
  local ox=user.x
  
  power_off(user)
  update_walker(user,-10)
  user.vx*=0.9
  
  user.dist_travelled+=abs(user.x-ox)
  if user.y==floor_for(user.x) then
   if rand(20)==0
   or user.dist_travelled<1
   then user.vy-=8 end
  end
 end
 
 calculate_belief(user)
--[[ msg="mcb:"..
  megacow_mana[1]..","..
  megacow_mana[2]..","..
  megacow_mana[3]..","..
  megacow_mana[4] ]]
end

function pick_target(user,user_mana)
-- power_off(megacow)
 if game_end_timer>0 then
  user.target_x=henry.x
  user.target_y=henry.y
  user.target=target_land
  user.next_target=120
  return
 end
 
 local otx=user.target_x
 
 if user.god_mode then
  if user.mana[powers[user.power+1].mana]==0 then
   local dist_from_mana=1000
   local typ=0
   for mb in all(mana_balls) do
    local d=abs(mb.x-user.x)
    if d<dist_from_mana
    and mb.typ==user.power
    then
     typ=mb.typ
     dist_from_mana=d
     user.target_x=mb.x
     user.target_y=128
     user.target=target_mana
    end
   end
   user.next_target=30
   msg="getting mana "..typ
  else
   local newtarget=false
   for i=200,50,-1 do
    local left=landscape_data[min(width,max(1,flr(user.x-i)))]
    local right=landscape_data[min(width,max(1,flr(user.x+i)))]
  
    if left.team==1 then
     user.target_x=user.x-i
     user.target_y=-40 --left.height-64
     user.target=target_land
     newtarget=true
     user.next_target=120
     break
    elseif right.team==1 then
     user.target_x=user.x+i
     user.target_y=-40 --right.height-64
     user.target=target_land
     newtarget=true
     user.next_target=120
     break
    end
   end
   
   if not newtarget then
    if happiness_for_team(2)<40 then
     user.target_x=width/4*3+rnd(100)
     user.target_y=user.y-32
     user.target=target_plant
     user.power=forest_power
     newtarget=true
     user.next_target=45
     msg="trying to cheer..."
    elseif happiness_for_team(1)<50 then
     user.target_x=width/4
     user.target=target_enemy
     newtarget=true
     user.next_target=90
    end
   end
   if not newtarget then
    local amb_choice=rand(3)
    msg="need a target"
    if amb_choice==0 then
     user.target_x=henry.x
     user.target_y=henry.y
     user.target=target_enemy
     user.power=fire_power
     user.next_target=50
    elseif amb_choice==1 then
     user.target_x=user.basex
     user.target_y=user.y+50
     user.target=target_build
     user.power=forest_power
     user.next_target=30
    else
     user.target_x=width+100
     user.target_y=henry.y
     user.target=target_build
     user.power=raise_power
     user.next_target=30
     msg="trying to build..."
    end
   end
  end
   
  if abs(otx-user.target_x)<20 then
   user.target_x=clamp(user.target_x+rnd(50)-25,1,width)
  end
 else
  local dist_from_subject=1000
  local hx=user.x
  for s in all(subjects) do
   local d=abs(s.x-hx)
   if s.team==user.team and d<dist_from_subject then
    dist_from_subject=d
    user.target_x=s.x
    user.target=target_follower
   end
  end

  user.next_target=4
  msg="finding follower"
 end
 
end

function pick_power(user) 
 local hx=user.target_x
 local hy=user.target_y
 local target_proximity=4
 if user.god_mode then
  target_proximity=24
  if hy>user.y and user.vy<max_speed then
   user.vy+=0.3
  elseif hy<user.y and user.vy>-max_speed then
   user.vy-=0.3  
  end
 end
 
	if hx-target_proximity>user.x then
	 if user.vx<max_speed then
   user.vx+=0.3 
   user.face_right=true
  end
 elseif hx+target_proximity<user.x then
  if user.vx>-max_speed then
   user.vx-=0.3
   user.face_right=false
  end
 else
  if user.target==target_land then
   local ld=landscape_data[max(1,min(width,flr(user.target_x)))]

   if ld.team==1 
   and (ld.foliage or ld.damage<0) then
    user.power=fire_power
    power_on(user)
    msg="setting fire"
   elseif ld.team==1 and ld.damage>0 then
    if flr(rnd(2))	==0 then
     user.power=rain_power --forest_power
    else
     user.power=forest_power
    end
    power_on(user)
    msg="planting forest"
   elseif ld.team==1 and ld.height>ld.original_height then
    user.power=lower_power
    power_on(user)
    msg="lowering land"
   elseif ld.team==1 and ld.height<ld.original_height then
    user.power=raise_power
    power_on(user)
    msg="raising land"
   end
  elseif user.target==target_enemy then
   user.power=fire_power
   power_on(user)
   msg="setting fire - enemy"
  elseif user.target==target_build then
   power_on(user)
   msg="building base"
  elseif user.target==target_plant then
   power_on(user)
   msg="planting base"
  end
  
 end
end
  
function fire_bullets(user)
 bullet_cooldown-=1
 if user.power_on 
 and user.power==fire_power 
 and bullet_cooldown<0 then
  user.mana[powers[user.power+1].mana]=
   max(0,user.mana[powers[user.power+1].mana]-0.066)
  
  local bx=user.x+6
  local by=user.y+17
  local bvx=-7
  if bullet_flip then
   bx=user.x+26
  end
  bullet_flip=not bullet_flip
  if user.face_right then
   bvx=7
  end

  spawn_bullet(bx,by,bvx,user.team,5)
  bullet_cooldown=4
 end
end

function spawn_bullet(bx,by,bvx,team,damage)
 bullet_ptr=((bullet_ptr+1)%num_bullets)+1
  
 local b=bullets[bullet_ptr]
  
 b.x=bx
 b.y=by
 b.vy=rnd(1.5)-0.75
 b.vx=bvx
 b.life=40
 b.team=team
 b.damage=damage
end

function add_foliage(ld,range)
 local pick=rand(7)
 if pick==6 and rand(3)==0 then
  pick=6
 end
 ld.foliage={
   y=0, --rnd(7),
   typ=pick
  }
end

function laser_powers(user)
 local power=user.power
 local powerdeets=powers[user.power+1]
 local team=user.team
 if user.power_on 
 and (power==raise_power 
   or power==lower_power
   or power==forest_power
   or power==rain_power) then
  user.laser_timer+=1
  user.mana[powerdeets.mana]=
   max(0,user.mana[powerdeets.mana]-0.033)
  
  local laser_max=25+(user.laser_timer/4)
  local hx=user.x+16
  local rlamount=0.05
  if stat(17)==-1 then
   position_sound(powerdeets.sound,user.x,1)
  end
  
  for i=clamp(hx-laser_max,1,width),clamp(hx+laser_max,1,width) do
    local x=flr(i%width)+1  
    local ld=landscape_data[x]
    ld.team=team
    if power==forest_power then
     local min_diff=0.3
     if ld.height-ld.original_height>min_diff then
      ld.height-=0.05
     elseif ld.height-ld.original_height<-min_diff then
      ld.height+=0.05
     end

     if ld.damage<=-35 then
      ld.damage+=(0.03*(laser_max-abs(i-hx)))
     elseif ld.damage<=0 then
      --ld.on_fire=false
      if not ld.on_fire and ld.foliage==nil and x%12==0 then
       add_foliage(ld,20)
       explode({x=x,y=height-ld.height},176,4,10,12)
      end
     else
      ld.damage=clamp(ld.damage-(0.03*(laser_max-abs(i-hx))),0,100)
     end
    elseif power==rain_power then
     ld.on_fire=false
     if ld.damage<=0 then
      if ld.x%8==0 then
       ld.timer=60+rand(120)
      end
      ld.damage=clamp(ld.damage-(0.03*(laser_max-abs(i-hx))),-40,100)
     end
    elseif power==lower_power then
     ld.height=clamp(ld.height-(rlamount*(laser_max-abs(i-hx))),3,20000)
    else
     ld.height=clamp(ld.height+(rlamount*(laser_max-abs(i-hx))),3,20000)
    end
  end
  
  if power~=rain_power then
   for i=1,2 do
    local px=hx+rnd(32)-16
    spawn_particle(px,floor_for(px))
   end
  else
   for i=1,2 do
    local px=user.x+16+rnd(24)-12
    spawn_particle(px,user.y+32,32,112,4,true)
   end
  end
 end
end

function spawn_particle(x,y,texx,texy,vy,col)
 texx=texx or 64 
 texy=texy or 112
 vy=vy or -rnd(6)
 col=col or false
 local particle=particles[particle_ptr]
     
 if particle.life<=0 then
  particle.x=x
  particle.y=y
  particle.vx=rnd(2)-1
  particle.vy=vy
  particle.life=1+rand(30)
  particle.colour=colour
  particle.texx=texx
  particle.texy=texy
  particle.col=col
 end
 particle_ptr=(particle_ptr+1)%num_particles+1
 return particle
end

function update_enemy(enemy)
 local ox=enemy.x
 local oy=enemy.y
 local of=floor_for(enemy.x)

 local hx=henry.x-40
 if hx-ox>-80 and enemy.vx<max_speed then
  enemy.vx+=0.3 
 elseif hx-ox<80 and enemy.vx>-max_speed then
  enemy.vx-=0.3 
 end
 
 if timer%60==0 then
  enemy.vy+=(rnd(20)-10)/10
 end
 
 enemy.x+=enemy.vx
 enemy.y+=enemy.vy
 
 enemy.y=min(enemy.y,floor_for(enemy.x))
 
 if (timer%4==0) enemy.frame=(enemy.frame+1)%3
end

function update_subject(subject)
 local ox=subject.x
 
 update_walker(subject)

 if subject.y==floor_for(subject.x) then
  if rand(20)==0 then subject.vy-=4 end
 end

 subject.dist_travelled+=abs(subject.x-ox)
 if subject.dist_travelled>subject.range then
  subject.vx*=-1
  subject.dist_travelled=0
 end
 -- calculate happiness
 subject.happiness_timer-=1
 local cur_space=what_is_at(subject.x)
 if cur_space.foliage then
  subject.happiness+=5
 elseif cur_space.on_fire then
  subject.happiness-=2
  issues[subject.team][fire]+=1
 elseif cur_space.damage<=-35 then
  subject.happiness-=1
  issues[subject.team][damage]+=1
 end
 if subject.happiness_timer==0
 and subject.dist_travelled<5 then
  subject.happiness-=1
  issues[subject.team][stuck]+=1
 end
 
 local dhx=abs(subject.x-henry.x)
 local dhy=abs(subject.y-henry.y)
 
 if subject.happiness_timer==0 then
  subject.happiness_timer=60
  subject.happiness-=14
 end
 
 subject.happiness=clamp(subject.happiness,0,100)
 
 if rand(300)==0 then
  spawn_mana(subject.x,subject.y)
 end
end

function update_walker(subject,max_incline)
 max_incline=max_incline or -2
 local ox=subject.x
 local oy=subject.y
 local of=floor_for(subject.x)
 
 subject.x+=subject.vx
 subject.y+=subject.vy

 local floor=floor_for(subject.x)
 local uphill=floor>of
 
 local mod=0.5
 if subject.vx>0 then
  mod=-0.5
 end
  
 local y=min(floor, subject.y)  

 subject.y=y
  
 if subject.y==floor then
  subject.vy=0
 else
   subject.vy+=0.7
 end
 
 if subject.y==floor 
 and floor-of<max_incline then
  subject.x-=subject.vx
  subject.vx*=-1
  subject.dist_travelled=0
  floor=of 
 elseif uphill then
  subject.x-=mod
 else
  subject.x+=(mod/2)
 end
 
 if subject.x<1 or subject.x>width then
  subject.x=clamp(subject.x,1,width)
  subject.vx*=-1
 end

 -- update animation
 if (timer%4==0) subject.frame=(subject.frame+1)%subject.frames
end

function update_bullet(bullet)
 if bullet.life>0 then
  bullet.life-=1
  bullet.vy+=0.9
  bullet.x+=bullet.vx
  bullet.y+=bullet.vy
   
  if floor_for(bullet.x%width)<bullet.y then
   bullet.life=0
   
   explode(bullet,171,10,10,10,5)
   if abs(henry.x-bullet.x)<64 then
    sound(0)
   end

   --if bullet.x>=1 and bullet.x<=128 then
    local exp_radius=bullet.damage
    local minx=bullet.x-exp_radius
    local maxx=bullet.x+exp_radius
    
    for s in all(subjects) do
     if s.x>minx-5 and s.x<maxx+5
     and abs(s.y-bullet.y)<10 then
--[[      if s.x<bullet.x then s.vx-=3
      else s.vx+=3 end]]
      s.vy-=4
     end
    end
    
    for i=minx,maxx do
     local ld=landscape_data[(flr(i)%width)+1]
     ld.team=bullet.team
     if abs(ld.height-(height-bullet.y))<exp_radius*2 then
      local hyp=exp_radius*exp_radius
      local o=abs(bullet.x-i)*abs(bullet.x-i)
      local a=sqrt(hyp-o)
      ld.height=
       min(
        ld.height,
        (height-bullet.y)-a
       	)
     else
      local hyp=exp_radius*exp_radius
      local o=abs(bullet.x-i)*abs(bullet.x-i)
      local a=sqrt(hyp-o)
      ld.height-=exp_radius
--[[       min(
        ld.height-radius,
       	)      ]]
     end
     
     ld.damage=
      ld.damage+5
      
     if ld.damage>5 then
      ld.foliage=nil
     end 
     if ld.foliage then
      ld.on_fire=true
     end
    end
   --end
  end
 end
end

function explode(thing,typ,num,radius,max_delay,frames)
 typ=typ or 171
 num=num or 10
 radius=radius or 7
 max_delay=max_delay or 8
 frames=frames or 3
 
 for e=0,num do
  explosion_ptr=((explosion_ptr+1)%num_explosions)+1
  
  local b=explosions[explosion_ptr]
  local r=rnd(radius)
  local a=rnd(360)/360
     
  b.x=thing.x-sin(a)*r
  b.y=thing.y-cos(a)*r
  b.frame=rand(3)
  b.frames=frames
  b.delay=rand(max_delay)
  b.life=frames
  b.typ=typ
 end
end

function update_input()
 if btn(0) then
  if henry.vx>-max_speed then henry.vx-=0.3 end
  henry.face_right=false
 end
 if btn(1) then
  if henry.vx<max_speed then henry.vx+=0.3 end
  henry.face_right=true
 end
 if btn(2) then
  if henry.god_mode
  and henry.vy>-max_speed then
   henry.vy-=0.3
  end
 end
 if btn(3) then
  if henry.god_mode
  and henry.vy<max_speed then
   henry.vy+=0.3
  end
 end
 
 if btnp(5) then
  sound(-1,1)
  changed_power=true
  henry.power=(henry.power+1)%num_powers
  henry.laser_timer=0
 end
 if henry.god_mode then
  if btnp(4) then
   used_power=true
   henry.power_on=not henry.power_on
   henry.laser_timer=0
   if not henry.power_on then sound(-1,1) end
  end
 else
  if btn(4) then
   if abs(floor_for(henry.x)-henry.y)<0.2 then
    henry.vy-=8
   end
  end
 end
end

function floor_for(x,vx)
-- if x<1 or x>128 then
--  return 20
-- else
  local target_x=flr(x%(width-1))+1
  if (vx>0)target_x=flr((x+1)%(width-1))+1
  return height-landscape_data[target_x].height
-- end
end

function floor_for(x)
 return height-landscape_data[flr(x%(width-1))+1].height
end

function what_is_at(x)
 return landscape_data[flr(x%(width-1))+1]
end

last_time=0
fps=0
frames=0

function to_target(cur,tar,amt)
 if cur>tar then cur=max(tar,cur-amt)
 elseif cur<tar then cur=min(tar,cur+amt)
 end
 return cur
end

--[[function _draw()
 f_draw()
end]]

title_heights={
 0,0,32,32,32,32,28,24,20,16,
 16,20,24,28,32,32,28,24,20,16,
 16,20,24,28,32,32,32,32,0,0,
 0,0,32,32,32,32,32,32,32,32,
 0,0,0,0,2,4,6,8,10,12,
 14,16,18,20,22,24,26,28,30,32,
 32,0,0,0,0,4,8,12,16,20,
 24,28,32,32,32,28,24,20,16,12,
 8,4,0,0,0,0,32,32,32,32,
 32,32,32,32,32,32,31,30,28,24,
 16,12,8,4,2,0,0,0,0,32,
 32,32,32,32,32,32,32,32,32,32,
 32,32,31,30,28,24,0,0
}

t_cam_x=0
t_cam_y=0
function draw_title()
 frames=frames+1
 cls(12)
 camera(t_cam_x,t_cam_y)

 for i=0,127 do
  local lh=50-title_bg[i+1]

  line(i,128,i,lh,5)
      
  sspr(i%24,16,1,16,i,lh,1,16)
 end
 
 for i=0,127 do
  local lh=sin(frames/100)/4+64-(title_heights[i+1] or 0)

  line(i,128,i,lh,1)
       
  sspr(24+i%24,0,1,32,i,lh,1,32)
 end
	
	if not character_select then
  print("the",58,24,7)
  print("pig",58,98,7)
  print("press —",50,118,7)
 else
  camera()

  swing=10*sin(frames*20%360/360)/4
  swings={0,0,0,0}
  swings[
   1+selection[1]+selection[2]*2
   ]=swing

  colour_print("select your wizard",30,2,7,1)
  colour_print("press — to select",32,120,7,1)
  spr(64,16,10+swings[1],4,4)
  colour_print("henry, wizard pig",2,52-swings[1],7,1)
  spr(68,80,10+swings[2],4,4)
  colour_print("megacow",84,52-swings[2],7,1)
  spr(72,16,70+swings[3],4,4)
  colour_print("omnichicken",10,108-swings[3],7,1)
  spr(76,80,70+swings[4],4,4)
  colour_print("celestial kitten",62,108-swings[4],7,1)
 end
end

function apocalypse_pal()
 pal(3,4)
 pal(5,4)
 pal(11,10)
 pal(12,10)
 pal(13,9)
end

function reset_palette()
 for i=0,15 do
  pal(i,i)
 end
end

function draw_level()
 local newnow=flr(time())
 if newnow!=last_time then
  last_time=newnow
  fps=frames
  frames=0
 end
 frames+=1

 local targetx=max(0,min(henry.x-48,width-128))
 local targety=min(0,henry.y-32)
  
 if not henry.god_mode then
  targetx=max(0,min(henry.x-64,width-128))
  targety=min(0,henry.y-100)
 end
  
 cx=flr(to_target(cx,targetx,abs((targetx-cx)/2)))
 cy=flr(to_target(cy,targety,abs((targety-cy)/2)))
  
 camera(cx,cy)  
 if game_end_result==2 then
  apocalypse_pal()
 end
 rectfill(cx,cy,cx+128,cy+128,12)   
  
 local zz=1
 for i=flr(cx),flr(cx)+128 do
  local z=zz
  local lx=(i+1)%128+1
  local lh=100-bg[#bg-z%width]

  line(i,128,i,lh,5)
       
  sspr(z%24,16,1,16,i,lh,1,16)
  zz=zz+1
 end
  
 draw_power(henry)
 draw_power(megacow)

 for ci=1,#castles do
  local c=castles[ci]
  local floors=max(0,scores[ci].score-5)
  local x=c.x
  local y=floor_for(x)
  
  spr(c.flag+anim_timer%2,x-4,y-28-floors*16)
  for i=0,floors do
   sspr(96,104,24,24,x-12,y-20-(i*16))
  end
 end
  
 for i=flr(cx),flr(cx)+128 do
  local lx=(i+1)%width+1
  local l=landscape_data[lx]
  local lh=height-l.height
  line(i,128,i,lh+32,1)
   
  set_shadow_palette(henry,i,cx)
  set_shadow_palette(megacow,i,cx)

  if l.foliage then
   draw_foliage(l.foliage,i)
  end
  if l.on_fire then
   spr(200+(i+anim_timer)%3,i+4,lh-5)  
  end
  if l.damage>3 then
   sspr(96+i%24,0,1,32,i,lh)
  elseif l.damage<-35 then
   sspr(120+i%8,0,1,32,i,lh)
  elseif l.damage<-4 then
   sspr(48+i%24,0,1,32,i,lh)
  else
   sspr(24+i%24,0,1,32,i,lh)
  end
 end  
  
 reset_palette()
 
 for w in all(wizards) do
  draw_belief(w)
 end
 for s in all(subjects) do
  if s.x>=cx and s.x<cx+128 then
   local flip_h=false
   if s.vx<0 then flip_h=true end
   local col=128
   if s.team==2 then
    col=131
   end
   spr(col+s.frame,s.x-4,s.y-8,1,1,flip_h,false)
   if s.happiness_timer>38 then
    local mood=249
    if s.happiness<40 then mood=248 end
    spr(mood,s.x-4,s.y-8-(60-s.happiness_timer))
   end
  end
 end
  
 for mb in all(mana_balls) do
  if mb.x>=cx and mb.x<cx+128 then
   spr(204+mb.typ,mb.x-4,mb.y-4)
  end
 end
 
 for f in all(foods) do
  if f.x>=cx and f.x<cx+128 then
   spr(246,f.x-4,f.y-4)
  end
 end
 
 for w in all(wizards) do
  draw_wizard(w,w.small_sprite,w.big_sprite)
 end
-- draw_wizard(omnichicken,163,64)
   
 for particle in all(particles) do
  if particle.life>0 then
   local px=4*(particle.life%2)
   local py=4*((particle.life+1)%2)
   sspr(particle.texx+px,particle.texy+py,4,4,particle.x-4,particle.y-4,4,4)
  end
 end
  
 for bullet in all(bullets) do
  if (bullet.life>0) spr(16,bullet.x-4,bullet.y-4)
 end

 draw_explosions(explosions)  
 
 local iconz={17,18,203,219}
 
 local belief=clamp((henry.belief/100)*37+2,0,39)
 local light=7
 local dark=10
 if henry.god_mode then
  belief=clamp(((henry.belief-100)/100)*37+2,0,40)
  light=9
  dark=8
 end

 local p=powers[henry.power+1]
 local p_level=clamp((flr(henry.mana[p.mana])/30)*37+2,0,39)
 spr(p.icon,cx+1,cy+1)
 rectfill(cx+10,cy+1,cx+50,cy+10,1)
 rectfill(cx+11,cy+2,cx+49,cy+9,p.dark)
 rectfill(cx+12,cy+2,cx+49,cy+8,p.light)

 rectfill(cx+10+p_level,cy+1,cx+50,cy+10,1)
 colour_print(p.name,cx+21,cy+3,7,1)
  
 local bx=cx+10
 local by=cy+13
 spr(wizards[1].small_sprite,cx+1,cy+13)
 if #belief_lines[1]>0 then
  bx+=rnd(2)
  by+=rnd(2)
  rectfill(bx-1,by-2,bx+41,by+9,9)
 end
  
 rectfill(bx,by-1,bx+40,by+8,1)

 rectfill(bx+1,by,bx+39,by+7,dark)
 rectfill(bx+2,by,bx+39,by+6,light)
 rectfill(bx+belief,by-1,bx+40,by+7,1)
 colour_print("power",bx+11,by+1,7,1)
 
 if game_end_message then
  colour_print(game_end_message,cx+64-(#game_end_message*4)/2,cy+60,7,1)  
  if game_end_timer<120 then
   local next_round_message="next round in "..flr(game_end_timer/30)
   colour_print(next_round_message,cx+64-(#next_round_message*4)/2,cy+70,7,1)    
  end
 end
-- print("cpu "..stat(1),cx+1,cy+40,7)
-- print("fps "..fps,cx+1,cy+9,1)
-- if msg then print("msg: "..msg,cx+1,cy+25,1)end
-- print("happiness: "..(happiness[1][1]/happiness[1][2]),cx+1,cy+17,1)
-- print("enemy happy: "..(happiness[2][1]/happiness[2][2]),cx+1,cy+31,1)
-- print("megac: "..megacow.next_target.." "..megacow.target_x,cx+1,cy+31,1)
-- print("pre-alpha build!",cx+64,cy+120,7)
-- print(henry.y,cx+64,cy+112,7)
 colour_print(help_msg,cx+64-(#help_msg*4)/2,cy+120,7,1)
  
 draw_score(1,8,1)
 draw_score(2,1,10)
 
-- line(megacow.target_x,0,megacow.target_x,128,8)
-- line(cx,megacow.target_x,cx+128,megacow.target_x,9)
end

function draw_explosions(explosions)
 for e in all(explosions) do
  if e.delay==0 and e.life>0 then
  spr(
   e.typ+e.frame,
   e.x-4,e.y-4)
  end
 end
end

function set_shadow_palette(user,i,cx)
 local current_height=height-landscape_data[(flr(user.x)%width)+1].height-user.y
 local hss=2*flr(10-current_height/16)
 if hss<1 then
  hss=1
 end
 if user.god_mode then
  local shadow_size=hss
  if i%width==flr(user.x-shadow_size)%width then
   pal(3,1)
   pal(10,13)
   pal(11,3)
  elseif i%width==flr(user.x+shadow_size)%width
  or i==flr(cx)+128 then
   pal(3,3)
   pal(10,10)
   pal(11,11)
  end
 end
end

function draw_score(team,col,yoff)
 colour_print(scores[team].score,cx+119,cy+yoff+1,7,col)
 if scores[team].anim_timer>0 then
  scores[team].anim_timer-=1
  local spr_idx=2
  if scores[team].up then spr_idx=1 end
  spr(spr_idx,cx+100,cy+yoff+sin(20*scores[team].anim_timer/360)*2)
 end
 spr(wizards[team].small_sprite,cx+109,cy+yoff)
end

belief_colours={7,10,9}
function draw_belief(user)
 local mod=0
 if user.god_mode then mod=16 end
 local belief=belief_lines[user.team]
 for b in all(belief) do
  for x=-2,2 do
   line(b[1]+x,b[2],user.x+mod,user.y+mod,belief_colours[abs(x)+1])
  end  
 end
 if #belief>0 and user.team==1 then
  for x=-2,2 do
   line(user.x+mod,user.y+mod,cx+x+30,cy+19,belief_colours[abs(x)+1])
  end
 end
end

function draw_wizard(user,small_spr,big_spr)
 if user.god_mode then
  sspr(big_spr,32,32,32,user.x,user.y,32,32,not user.face_right,false)
 else
  local frame=0
  if user.vx~=0 then frame=user.frame end
  spr(small_spr+frame,user.x-4,user.y-8,1,1,not user.face_right,false)
 end
end

function colour_print(s,x,y,light,dark)
 print(s,x-1,y,dark)
 print(s,x+1,y,dark)
 print(s,x,y-1,dark)
 print(s,x,y+1,dark)
 print(s,x,y,light)
end

function draw_power(user)
 if user.power_on 
 and (user.power==raise_power 
   or user.power==lower_power
   or user.power==forest_power
   or user.power==rain_power)
 and user.x>=cx and user.x<cx+128 then
  local x=user.x+16
  local y=user.y+16
  local pulse=sin(15*timer/360)*3+4

  rectfill(-pulse+x-7,y,pulse+x+7,128,powers[user.power+1].dark)
  rectfill(-pulse+x-6,y,pulse+x+6,128,powers[user.power+1].light)
  if user.power~=rain_power then
   rectfill(-pulse+x-3,y,pulse+x+3,128,7)
  end
 end
end

function draw_foliage(f,px)
 
 local x=px+2
 local y=floor_for(x%width)-4+f.y
 local typ=f.typ
 if typ==6 then
  sspr(56,96,8,8,x-4,y-42,8,16) 
  sspr(56,96,8,32,x-4,y-26)
   
  spr(229,x-8,y-42,2,1)
--  spr(230,x-1,y-42)
  spr(229,x-9,y-34,2,1)
--  spr(230,x+1,y-34)
  sspr(24,104,32,8,x-16,y-26)
  sspr(24,104,32,8,x-16,y-20)
  sspr(24,104,32,8,x-16,y-12)
 else
  spr(192+typ,x-4,y-4)
 end
end
__gfx__
001111000000000000000000333333333333333333333333333333333333333333333333333333333333333333333333115156151515d611dd6511d611111111
013333100009900022222222abbaabbabbbaabbbbbbababbabbaa9babbbaabbbabbababbb6bb76bbbbbb76bbbb76bbbb5dd65dd41d11515d1511d51521522512
13bbbb310097790049999994b3bbb3bbb33bb33bbb3b3bb3bb3bba33333bb33bbbbb3bb3bbb76bbbbb76bbb3b76bbbb311d4444515999d524544516955135155
13b77b3109aaaa909aaaaaa93b333b31311331133bb3b3b1b339bbb353bbaabbbb333bbb33bbbb3b376bbb3b3bbb3b315414424d1d44441144221d9431521532
13b77b319aaaaaa909aaaa90131113111111111113bb3b3133babb533dba9a33b353babd11333bb313bbb3bbbbb3b31124d142251424224142d1144425153123
13bbbb3149999994009779001111111111112111113bb3123ab33335dbbabbbb3333a9bb11113331133b3b33bb3b3311211d1511142522255115145d32153533
013333102222222200099000212212222222222222133124a9b33533bba9bdb3535a9bb311155511113333113bb331111522111511d2251111115522335353b5
00111100000000000000000022242111142442422421124233bb535dbabb35b333bb3b3315555551115555511333151125221d1d151d5112251111d153353533
022888200008800000001100424212221144244242424242b33533aabb3353333bd3335b156d6d5515d6dd511111551142421215154424424444544233333535
28899882000088000001ba1042991994212999422499994235333a9b3bbb3353abbb333b55d7665515d66d51155511664299199421559942245999d223532353
889aa9880089a800001b3bb1249414441129421429994221333bb33bb3bbd53a9bb335bb5d766d15115dd511111115dd24941444112942142959422135331232
89a77a980897798001b3bb31214111211121421249444421b39bb33533bd33db33b33bbb5d6ddd51111551155555155521411121112142124944442151325133
89a77a980897798001b3b3212121111112211111212222143bdba353bb3d3db33b353bbd15d6d5151111115776d5511121211111122111112122221435313125
289aa982089aa980001b32109211229a992444111111119413bbb33bbb3bbab3d3d3b33311515151155115d6665d11159211229a992444111111119431251312
2889988202299220000111109921299442142499922222241133bbbb33133dbbbbb3311151155115776d15ddddd1516699212994421424999222222425121531
02288220002222000bb31000222224942114449424444221111133331111133bd3311121d511111d666d5115551511dd22222494211444942444422113513115
dddddddddddddddddddddddd2444222221122224222222112221111111111113311122115516d51d66dd51111111111524442222211222242222221111121121
d5ddddd5d5ddddd5dddd55dd244214111124441111111112244212111122211111111112511d5515dddd51111111151124421411112444111111111221251211
d5ddddd5d5ddddd5dddd5dd512221111122224242499992412221111122224111199992411111115555551166d511d5112221111122224242499992412112112
d5d555555555ddd55d5d5dd52111444212999211212442142111444212999211212442141115111111111166dd51155121114442129992112124421412225115
d55dd555d55d5dd55d5d5d5d211122221194421111222114211122221194421111222114115d6dd51dd515ddd551111121112222119442111122211412151421
d55d5555d555ddd55d5d55d522121111219442111111112422121111219442111111112415d66d651d511555555156d122121111219442111111112451411152
55555d55555555555d5555d5422249412122214141122421422249412122214141122421156dd6d5111111111111ddd542224941212221414112242114421222
555555555555dd555d5555d521241114211111111112221221241114211111111112221251dddd51155551111111155521241114211111111112221211152221
55555d555555dd55555555d5421111114221114944111222421111114221114944111222551dd5515d66dd55515d115542111111422111494411122222111122
5555d5555555555555555555421494211211122442211444421494211211122442211444551555115ddddd5551d5511142149421121112244221144411994152
5555d5555555d5555555555522124421111122111112411122124421111122111112411151111111155555551111111122124421111122111112411191142211
5555d5555555d55555555555121222115211111224221242121222115211111224221242115151dd11111111111156d512122211521111122422124242511119
55555555555555555555555512111111122222211422122112111111122222211422122151111155111d51551151ddd512111111122222211422122121194144
55555555555555555555555512215551221111151142111112215551221111151142111151dd51111d5115665111155512215551221111151142111151444212
555555555555555555555555121111511211242211242511121111511211242211242511115551dd155115dd51d5111112111151121124221124251111222111
55555555555555555555555541215111112151111252225241215111112151111252225251155155111111151155155141215111112151111252225211111115
00000000000000000000000000000000000000000000000000000000000000000000000000222222220000000000000000011000000000000000000000000000
00eeee00000000000000000000000000000000001111111776777766000000000000000002888888822200000000000000011110000000000000000000001110
0eefffffe00000000000000000000ef0677777071111111176777766600077770000000002889988988220000000000000011f21000000000000000000015510
0222222ffe00000000000000000ef222766666771111116676677777677776660000022222888988998820000000000000011fe211000000000000000015fe10
02ee2222ffe000000000000000e22ee27fee66771111111166777777667766ef0002288888888888998820000000000000011fee2511100000000001115ffe10
02ee11122fee00000000000000f21e207ffee667111111117677777716766eef002288882222288889882dd00000000000011ffee21551111111111555fee210
02e2221122ee0000000000000e2122207ffeee67111111111777777111766eff002888822dddd222888827ddd000000000011feee2155111555115551fee2100
022e222122feeeeeeeeeee00ef212e200effef67111111111777777111776ffe0028882d77777dd222282277dd00000000011fee211115111555115551122100
002eee2222feeeeeeeeeeeeeef22e2000effff77111111111677777111176fe000228227d7777777dd22227d7dd0000000011e21111115511555115515512100
0022ee222fffeeeeeeeeeeeefef2e20000efff71111111111677777111117e00002222d7d777777777dd227777d0000000011111511115551555515515551100
0002e22ffeffffffffffffeeeeee2200000ef711111ddddd167777716666600002282d7777d777777777d27777d0000000011111115115555555551115555100
0002e2ffefeeffffffffffefefefee000000e11111d6777766777776677760000288277d777ddddd777777d7dddddd0000011111151111155555551111115100
00ee2feefeeeeffffffffefeeeeefe000000011111d7777776677776777766002288277777d7777d77777777d7777d00001111111111111155555511dddd5110
00efefefe7777efffffffeee7777efe00000011111d7777776677766777776002882dd777d777777d777777d777777000111111111999911555551119999d510
00eefefe777777effffffee777777fe00000011155d7771176677766771176002282dd777d777777d777777d777777000111111119aaaaad11555119aaaaa510
0eefeffe777777efeeeeffe777777fe00000011566d6771176777766771166000282dd7d7d777117d777777d777117000111111119aaaaad11551119aaaaa551
0eeefefe777117efffffefe777117ffe00000015666d677767777766d7776000022dddd77d777117d77777dd777117000151111119aa11ad11551d19aa11a551
0eefeffe777117efeeeeeee777117ffe000000156666dddd677777766ddd0000022dddd7ddd7777d777d999997777d000111111119aa11ad15551119aa11a551
2eeefeffed777efffffffffed777efee0000001566676666767777767666000000ddddd7ddddddd7777999aaa9ddd000011151111199991115551d119999d551
2eeeefeffeeeefffeeeeeeeeeeeefefe0000001556767777777777767676700000dddddddddddd7777d999aaaa90000001111111111111115555551111111551
2eeefefeeeeefef22eeeeeeeefffefee0000000156677777777777776777600000dddddddddd77777799499aaa90000001111111111511155511115111111551
22eeefeeeeeeefe22e11ee11effeeeee0000000156767777677777777767700000dddddd777777777d944999aaa9000000111111511111d55511115511d1d510
2222eeeef7eeeef22e12ee212fee7fee0000000156676777767ffffffff7700000ddddddd7d7d7d77d9444999aa900000011111111111111d551115d55d66670
022222eeefeeefee22222222fffefeee000000015656767777f111fff11f700000dddddddd7777777d99444999aa900000011111766dd551115555551ddd1510
022222222211122eeeeeeeeeffeeeeee000000015565676777efe1fff1ef700000dddddddd7d7d7d99aa9999959a9000000116d51111111155511155dddd5110
002222211111111111111111111ee222000000015556667777efffffffff7000000dddddddd777291177aaaa959a9000076d5111111d11111111111166651000
000222111188888188881111111e2220000000015565666666eeeeeeefff7000000dddddddddd28911177777aa99900000000111111116517777771111166000
000021111222228822288111222222000000000155177777711eeeeeeee700000000dddddddd22891288821111a9900000000111116d51112282115111157000
0000211177777777777dd222222222000000000051188881111111111117000000000dddddd2288944444499988a0000000000116d5111882282115555d10000
0000211d7777777777d22222222220000000000051288888888111155550000000000000dd2288899444499888820000000000061166677777777115d1100000
000002222222222222222222220000000000000015521112288155555550000000000000022888889999990288200000000000001d1111111111111110000000
00000002222222222222220000000000000000000155555555555550000000000000000000222222222000002200000000000000001111111111111000000000
0222888000000000022288800222ddd0000000000222ddd000000000000000000000000000000000000000000000000000000000000000000122000000012000
828899800222888082889980d2ddccd00222ddd0d2ddccd000000000000000000000000000000000000000000000000000000000000000000182002000012200
821441008288998082144100d2144100d2ddccd0d214410000000000000000000000000000000000000000000000000000000000000000000112222000018222
82ffff008214f10082ffff00d2ffff00d214f100d2ffff0000000000000000000000000000000000000000000000000000000000000000000018820000018820
dd44449082444490dd444490dd4444d0d24444d0dd4444d000000000000000000000000000000000000000000000000000000000000000000018220000012200
7499999fdd999990749f990074dddddfddddddd074dfdd0000000000000000000000000000000000000000000000000000000000000000000011000000012000
009aa90070faa900119aa91000dccd0070fccd0011dccd1000000000000000000000000000000000000000000000000000000000000000000001000000011000
00111100001110000000011000111100001110000000011000000000000000000000000000000000000000000000000000000000000000000001100000001000
00f77770000000000f7777002eeeee20e00000e002eeeee20e00000e000000000244442002444420022449900020000000000000000000000122000000012000
0f76676600f77770f7667660ef1ff1e00eeeee000eff1ff100eeeee000000000249aa942229aa9422249aaaa02000000000000000000000001d2000000012200
077176710f76676677176710eefeefe0ef1ff1e00eeffeee0eff1ff10024420049a77a9429a7724224a7777a240000000024420000000000011222000001d222
0f71171107717671f711711002eeee00eefeefe0002eeee00eeffeee004994004a7a77a4222494222977a007990000000049940000000000001dd2220001dd20
00f775750f7117110f775750002ef00002eeee000002ef00002eeee0004a74004a7777a4427949724aa000002a70a920004a740000000000001d222000012200
00f7777700f775750f1777700022f000002ee000002eef200002ee000024420049a7a79402aa2aa22a700000270a942000244200000000000011000000012000
000f666700f1777700f111700eddd000002dd00000eddde0002edd0000000000249aa942024929420249070022a9420000000000000000000001000000011000
0000fff0000f1660000f660000000e00000e0000000000000000e000000000000244442000222220002220000222200000000000000000000001100000001000
000000000000000000223200fdddddf0f00000f00fdddddf0f00000f000000000000000000000000000000000000000002444420022022000249000000942000
202232020000000003377730d71771d00ddddd000d71771d00ddddd0000000000000000000000000000000000024900029aa7a92299249202497700007a90000
2337273202232000013717b2dd7ff7d0d71771d00dd7ff7d0d71771d00000000000000000000000000000000022a72004a7777a422447a224a70000000040400
213717b2337273000227172205dddd00dd7ff7d0005dddd00dd7ff7d0000000000000000000000000007700004a77a40477777a4292a74920000400004000020
213717b213717b0001222230005d700005dddd000005d700005dddd000000000000000000000000000077000097a7a40477777942a7774920704007022000092
013bbb3023717b200011130000557000005dd000005dd7500005dd0000000000000000000000000000000000029aa9204a777a400444799497700479490407a4
0011130022bbb322000000000dddd0000055500000d555d0005d5500000000000000000000000000000000000024420029a7a920049a7aa04a770a949a000007
00000000021130020000000000000d00000d0000000000000000d000000000000000000000000000000000000000000002222200004044402490002007000400
0000000000022000022222200dd88d000008000000dd88d000000800f55555f0f00000f00f55555f0f00000f0000000000000000002442000222220000000000
00000000002dd2002d6666d2d71771d00dd88d000d71771d00dd88d05dadda500555550005ddadda005555500000000000499400029aa9202499942000000000
000220000266662026677662dd7a97d0d71771d00dd7a97d0d71771d55d5fd505dadda50055dd5f505ddadda0024200004a77a40297777922477a92000044000
002dd2002d6776d22677776205dda900dd7a97d0005dda900dd7a97d0155550055d5fd5000155550055dd5f5029a9200097777904a7777a42470074200499400
002dd2002d6776d2267777620058700005dda90000058700005dda90501d500001555500000155000015555004a7a400097777904a7777a402a0079200499400
00022000026666202667766200557000005d8000005dd7500005d80055115000001550000515d51050015500029a920004a77a402977779224a70a9200044000
00000000002dd2002d6666d20dddd0000055500000d555d0005d550005ddd000551dd000505ddd500515dd000024200000499400029aa920249aa94200000000
00000000000220000222222000000d00000d0000000000000000d000000005000005000000000000000050000000000000000000002442000222222000000000
00000e000aa00000000030000b003bb0000000000000000000003bbb00124000002000000002400000000022222222000088880000bbbb000099990000dddd00
00002ef0a7a00aa00b03b0b03003b01388ee08e80300000003333bb30012400000220000000490000004222049999400089988200baabb3009aa99400d66dd20
00e00f7099913a7a0b0b01b33a3b013b02811280bb3333333bbb333100124000000444000029a2000099940004aa400089779822ba77ab339a77a944d6776d22
02ef1e000133b999b313b13b1a3a13b0122332213bb3bbb33bb333110012400000004a40004a740004aa90000049790089779821ba77ab319a77a941d6776d21
00f72ef013baa3333b113b131b1b3b0013bb3bb11333333333311110001240000009aa900297790004a7a9400097779088998821bbaabb3199aa9941dd66cd21
01331f703ba7ab3113b113311b1b1b3011133111111311131133101100124000009a7a9004a7790004a77aa409aaaaa9288882213bbbb331499994412dddd221
13b3131113999b301111111131b113b0023133200101100110011100001240000097779009a77900004777740499999402222210033333100444441002222210
01b32b10013333101111111101111100001111000000100011000000001240000047740000974000004777400222222200211100003111000011110000211100
0aa0000000000000000000000000000000003bbb0000000000000000001240000000000000444400000000000000000000001111111111111111000001220000
a7a00aa0000000000aa000000300000003333bb3bb300000000000000012400000244200029aa920000000000d66d1100011155d5dd66767676d110001820000
99913a7a0aa13300a7a13aa0bb3333333bbb33313bb333300000000b001240000299992049a77a9400044000d7777c1101115155ddd76666677dd51001122200
0133b999a7a3baa09993ba7a3bb3bbb33bb333111bbbbab33333333b00124000049779404a7777a400499400677777d1111115155d667767777dd51100188222
13baa333999bba7a13bbb999133333333331111013bbabbbabbabbb300124000049779404a7777a40049940066776c11111111555dd66676666dd51100182220
3ba7ab313bbaa9993bbaab3111131113113310110313331133111130001290000299992049a77a9400044000ddcccd11111155555d667677767dd51100110000
13999b3013a7ab3013a7ab30010110011001110001001100011001100124900000244200029aa920000000001dddd11011111555111555ddddddd51100010000
01333310019993100199931000001000110000001001100111001100012490000000000000444400000000000011110011115111111111111111d51100011000
000030000000000000000000000000000010005000000003b0000000012440000900094007000000567676761111111111111155511111756655d51500012000
0b03b0b00000000000000000000000000c100050000003b33b333000012440009440042107a000701dddddd7156767611122151112121217576d111100012200
0b0b01b30000000000000000000000000d1000500003b33333babab301249000442102100a909a705515155515dddd71125151511111111d676d551500018222
b313b13b000000000000000000000000000000503bb3311111311130012494000210000009900990111111111555555111111511121212175d6dd55100018820
3b113b13000000000000000000000000050000000011b311131b30000124940000000990000000001dddddd11111111111111115111111156755d51500012200
13b1133100000000000000000000000005000111000b31101133bab301249400044244420700000715d6665115d715611122515112121217666d111100012000
111111110000000000000000000000000500cc1003b311000111311001249400942094217aa000aa155ddd5115561551125115151111111d676dd51500011000
111111110000000000000000000000000500dd000111000000111000012294000110011009900990111111112111111111115511515155565d6dd55100001000
0b003bb0000000000055550000000000000000000000bbbb00007a000122940000111100001111004444444412941294111111551d5676576655d51524942494
3003b0130000000000500050000000000000888000881330000ba930012244000177cc1001777a1041111114124412a41122155555d56576776d111124a424a4
3a3b013b000000000505550500000000000097900877988000b79b3012229400171cc1c11717a1a141a9412112a2129212515155111555dd766d5515249424a4
1a3a13b000000000055505050009800008880880889a98820039a3101222940017ccccd11aaaaa914194291112a412441111151155dd66765d6dd55124a42494
1b1b3b00000000000550550000a790009a798000888888810b7ab310124294001cc11dd111aa99114142a91112941292111111555dd666676755d515249424a4
1b1b1b300000000000505505000a0000897798002888882103a93110124294001c1cc1d11a11119141199411124212a4112255555dd76667766d111124a42494
31b113b00000000000500555000000000897a90022222221039b31001242240001dddd1001999910422111211294129212515155111555dd676d551524a424a4
011111000000000000500500000000000088800001111110042110001222240000111100001111001111111112a212441111151155dd66665d6dd55124942494
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000d40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0003000009720067200472006720067200472004720014001700018000190001b0001b0001c0001d0001e00002000010002000021000210002200022000230002400025000250002600027000280002900000000
000a000005750057500575005750057500575006750067500775007750077500875008750097500a7500b7500c7500e750107501175012750137501575016750187001a7001b7001d70020700237002670028700
000300001003010530100301003010000100001003010530100301003010000100301053010030100301003017030180301803018030180301803018030180301803018000180001800018000180001800018000
000100000a7700b7700c7700d7700f77012770177701b7701f77023770207002370025700237001e7001d70021700257002770000000000000000000000000000000000000000000000000000000000000000000
001000000c7700c7700b7700b7700a7700a7700977009770077700777006770067700577005770047700477003770037700277002770017700177001770017700170001700017000170003700037000270000000
001000000261002610026100261001610016100161001610016100261003610036100361002610046100661007610076100761007610066100561004610036100261001610016100161001610026100361003610
00030000217701e7701b7700f70014700127700f7700c7700c70014700067700477002770037000b1000c1000a7000d1000b700051000b100087000b1000c100087000c100087000a70000000000000000000000
0004000001020015200502008520090200c5200f020125201602018520090000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000160101d01021010210101f0101a010120100f0100f0101101015010190101e01021010210101e01019010150101200013000160001b0001e000200001e0001a0001300013000160001b0001b00013000
00100000064100d4101741017210174101641016210164100d4100d2100a4100a2100a4100d4100d210114101241012210084101241011210114100b4100b2100b4100b2101141011210114100b2100b41011210
000700000641006210074100a2100d41011210144101721019210192101240014200164001b2001a4001b20000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000230101d010140100d01007010030100101008200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000657006700087000657011620025000670008700015700670008700015701262000000067000870006570067000870008570116201410014100141000b57006700087000a57011620065000000006500
00100020015700000000000015701162000000000000000003570000000350003570116200000000000000000b570000000b5000b570126200000000000000000b57000000000000a57013620000000000000000
001000000d410012100d41001210054000540014410082101441008210144100820008400082001b4101b2101b400194101921019400164101621016400064100121006410054100121005410012100541001210
001000000d410012100d41001210054000540014410082101441008210144100820008400082001b4101b2101b400194101921019400164101621016400174100b2101741017410164100a210164100a21016410
001000000a530075300a620075300a530075300a620075300d5300a5300d6200a5300d5300a5300d6200a530105300d530106200d530105300d530106200d5301353010530136201053013530105301362010530
0010000012700127001270012740167401974012700127000000000000000001e7401b74019740197001970000000147001470014740117400d740000000000000000000000e7000d74011740167400000000000
00100000127001270012700087400d7400a74012700127000000000000000000a7400f7400d740197001970000000147001470014740117400d740000000000000000000000e7000d74011740167400000000000
001200000c530000000c530000000c530000000853007530085300753008530000001053000000105300000010530000000c5300b5300c5300b5300c5300b5300c5300c5300a5300853006530045300253001530
0012100e0953015530195302153021620215302430024300095301553019530255302562025530293002830010530155301953028530286202853000000285302850028530000002853028620285302853028530
001000002d070250702107000000000002d0002d0002d0002d0702507021070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 41 42 43 0c
01 41 42 09 0c
00 41 42 09 0c
00 41 42 09 0c
00 41 42 09 0c
00 41 42 0e 0d
02 41 42 0f 0d
01 41 42 11 0c
00 41 42 11 0c
00 41 42 11 0c
00 41 42 11 0c
00 41 42 12 0d
02 41 42 12 0d
03 41 42 43 10
03 41 42 43 13
03 41 42 43 14
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
