pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--galaxy castle
--by flyingsmog

cls()
cartdata("galaxy_castle")
--poke(0x5f2c, 3)-- 1/4 size screen
function _init()

 oi="eles estao nesse calabouco"
	music(0)
	_init_stars()
 game={
  upd=_menu,
  drw=d_menu,
--  upd=_loadgame,
--  drw=d_loadgame,
  loadmap=true,
  nextlevel=true,
  world=0,
  level=0,
  ison=true,
  hasportal=false,
  haskey=false,
  hasbis=false,
  hasonoff=false,
  hasswitch=false,
  hasdisps=false,
  hastramps=false,
  haspointer=false,
  hassticker=false,
  hastportal=false,
  hasphys=true,
  powers={"jetpack","impulso","chapeu","teletransporte","traje"},
  g=0.2,
  finalbis=false,
 }
 
 menua=0
 
 physicist={
 	q=0,
  x=96,
  y=80,
  spawnx=0,
  spawny=0,
  w=8,
  h=8,
  a=0,
  sprite=80,
 }
 
 pspeech={
  {"ranger!","i am wisgarion,","king of the planet avalon!","i need your help!","my daughters were captured!","lord nimbus kidnapped them!","they're in that castle!","take this jetpack...","and save the four princesses!"},
  {"wow! you saved me!","i am princess murron!","hey! my jetpack!","i'll need it to leave.","but, as a reward,","take this impulse jumper","and defeat nimbus!"},
  {"wow! you saved me!","i am princess helisent!","hey! my impulse jumper!","i'll need it to leave.","but, as a reward,","take this hat","and defeat nimbus!"},
  {"wow! you saved me!","i am princess emonie!","hey! my hat!","i'll need it to leave.","but, as a reward,","take this teleport ray","and defeat nimbus!"},
  {"wow! you saved me!","i am princess helewyse!","hey! my teleport ray!","i'll need it to leave.","but, as a reward,","take this mech suit","and defeat nimbus!"},
  {"wow! you saved... what?","yeah, i'm nimbus...","what? wisgarion? captured?!","... haha... hahahaha!!!!","all that just to defeat me?","... they fell for it! hahaha!","i was only joking! hahahaha!","hey, but since you're here,","wanna party with us?"},
  t=1,
 }
 
 cspeech={
 	{7,12,7,10,10,8,7,12,12},
 	{12,7,10,9,7,12,8},
 	{12,7,10,9,7,12,8},
 	{12,7,10,9,7,12,8},
 	{12,7,10,9,7,12,8},
 	{12,7,10,9,8,7,12,13,12},	
 }
 
 tportal={
  x=96,
  y=78,
  w=8,
  h=8,
  sprite=43,
  timer=1,
  maxtimer=1,
  clr=1,
  highlight=13,
  base=13,
  uia=0,
 }

 player={
  power=game.powers[game.world],
  x=20,
  y=80,
  spawnx=0,
  spawny=0,
  w=7,
  h=8,
  vx=0,
  vy=0,
  maxvx=2,
  maxvy=3,
  a=0.4,
  da=0.4,
  isgrounded=true,
  havekey=false,
  sprite=1,
  flipspr=false,
  timer=12,
  bis=0,
  there=false,
 }
 
 jet={
  x=0,
  y=0,
  maxfuel=100,
  fuel=100,
  consume=4,
  refill=5,
  v=-0.5,
  sprite=35,
  flipspr=false
 }
 smokes={}
 
 imp={
 	x=0,
 	y=0,
 	can=true,
 	v=-4,
 	sprite=36,
 	flipspr=false,
 }
 trails={}
 tr={
 	ct=0,
 	ctmax=1,
 }
 
 hat={}
 tassels={}
 
 tp={ }
 tpballs={}
 tptrails={}
 tpt={
  ct=0,
  ctm=1,
 }
  
 portal={
  x=0,
  y=0,
  w=16,
  h=16,
  sprite=33,
  timer=1,
  maxtimer=1,
  clr=1,
  highlight=13,
  base=13,
  uia=0,
 }
 
 key={
  x=0,
  y=0,
  spawnx=0,
  spawny=0,
  w=8,
  h=8,
  a=0,
  aa=0,
  sprite=32,
 }
 
 locks={}
 onoffs={}
 switches={}
 disps={}
 saws={}
 tramps={}
 traps={}
 ps={}
 stickers={}
 
 bis={
  x=0,
  y=0,
  spawnx=0,
  spawny=0,
  w=4,
  h=4,
  a=0,
  sprite=48,
 }
 
 circles={}
 c={
  ct=0,
  ctmax=15,
  c=8,
 }
 
 endgame={
  yoffset=0,
  physt=0,
  physy=170,
  textotmax=120,
  textot=180,
  textoq=1,
  creditos={"you did it!","and you got "..player.bis.. "/12 diamonds!","thanks for playing!","galaxy castle ii","made by flyingsmog","additional code by:","osmstudios","24appnet","dr4ig","liquidream","and zep","musics based on:","world 1: pi","world 2: fibonacci sequence","world 3: mersenne primes", "world 4: recaman's sequence","inspired by:","super meat boy","vvvvvv","out there somewhere","a grim chase","spaceman 8","celeste","and many others!","2018-2020",},
  continuet=0,
  finaly=130,
 }
 texto={}
 
 sound={
  jet=1,
  getkey=2,
  portalno=3,
  spikes=4,
  bis=5,
  portalyes=6,
  refill=7,
  maxrefill=8,
  text=9,
  imp=10,
  switch=11,
  saw=12,
  tramp=13,
  trap=14,
  tpball=15,
 }
 
 objects={
  {sprite=1,func=c_player,}, --player
  {sprite=key.sprite,func=c_key,}, --key
  {sprite=portal.sprite,func=c_portal,}, --portal
  {sprite=16,func=c_lock,}, --lock
  {sprite=bis.sprite,func=c_bis,}, --bis
  {sprite=41,func=c_onoff_red,}, --onoff red
  {sprite=57,func=c_onoff_blue,}, --onoff blue
  {sprite=59,func=c_onoff_trap,}, --onoff trap
  {sprite=11,func=c_switch,}, --switch
  {sprite=70,func=c_physicist,}, --physicist
  {sprite=37,func=c_disps_up,}, --disps up
  {sprite=38,func=c_disps_down,}, --disps down
  {sprite=39,func=c_disps_right,}, --disps right
  {sprite=40,func=c_disps_left,}, --disps left
  {sprite=24,func=c_tramps_pulse,}, --tramps pulse
  {sprite=27,func=c_tramps_momentum,}, --tramps momentum
  {sprite=53,func=c_pointer_up,}, --pointer up
  {sprite=54,func=c_pointer_down,}, --pointer down
  {sprite=55,func=c_pointer_left,}, --pointer left
  {sprite=56,func=c_pointer_right,}, --pointer right
  {sprite=29,func=c_sticker,}, --sticker
 }
 
 finalbis={
  a=0,
  c=0,
 }

end

function _update()
 game.upd()
 _save()
end

function _draw()
 game.drw()
 --d_save()
-- print(ceil(key.a),10,40,3)
end
-->8
--update

function _save()
	menuitem(1,"*save game*",_gamesave)
	menuitem(2,"*reset data*",_resetdata)
end

function _gamesave()
	dset(0,game.world)
	dset(1,game.level)
	dset(2,player.bis)
end

function _resetdata()
	dset(0,0)
	dset(1,0)
	dset(2,0)
end

function _tinyportal()
	local p_collide=ccol(player.x,player.y,player.w,player.h,tportal.x,tportal.y,tportal.w,tportal.h)
	
	if p_collide
	and btnp(2) then
	 music(-1)
 	
	 game.world=dget(0)
	 game.level=dget(1)-1
	 player.bis=dget(2)
 	game.nextlevel=true
 	game.upd=_loadgame
 	game.drw=d_loadgame
 	music(18+game.world)
	end
	
end

function _loadgame()
 
 if game.nextlevel then
  
   game.loadmap=true
   
   game.level+=1
      
   game.hasportal=false
   game.haskey=false
   game.hasbis=false
   game.haslock=false
   game.hasphys=false
   game.hasonoff=false
   game.hasswitch=false
   game.hasdisps=false
   game.hastramps=false
   game.haspointer=false
   game.hasclicker=false
   
   for i,lock in pairs(locks) do
    locks[i]=nil
   end
   
   for i,onoff in pairs(onoffs) do
   	onoffs[i]=nil
   end
   
   for i,switch in pairs(switches) do
   	switches[i]=nil
   end
   
   for i,disp in pairs(disps) do
   	disps[i]=nil
   end
   
   for i,saw in pairs(saws) do
    saws[i]=nil
   end
   
   for i,tramp in pairs(tramps) do
    tramps[i]=nil
   end
   
   for i,pointer in pairs(ps) do
    ps[i]=nil
   end
   
   for i=1,#stickers do
    stickers[i]=nil
   end
   
   if player.havebis then
    player.bis+=1
   end
 
  game.nextlevel=false
 end
 
  _scanmap()
  
  if player.power=="jetpack" then
   for i,smoke in pairs(smokes) do
   	smokes[i]=nil
   end
  elseif player.power=="impulso" then
  	for i,trail in pairs(trails) do
  	 trails[i]=nil
  	end
  end
  
  
  player.x,player.y=player.spawnx,player.spawny
  player.vx,player.vy=0,0
  player.havekey=false
  player.havebis=false
  game.ison=true
  jet.fuel=jet.maxfuel
  
  if game.haskey then
   key.x,key.y,key.a=key.spawnx,key.spawny,0
  end
  
  if game.hasbis then
   bis.x,bis.y,bis.a=bis.spawnx,bis.spawny,0
  end
  
  if game.haslock then
   for i,lock in pairs(locks) do
    mset(lock.x+16*(game.level-1),lock.y+14*(game.world-1),0)
   end
  end
  
  if game.hasonoff then
   for i,onoff in pairs(onoffs) do
    mset(onoff.x+16*(game.level-1),onoff.y+14*(game.world-1),0)
   end
  end
  
  if game.hasdisps then
   for i,saw in pairs(saws) do
    saws[i]=nil
   end
  end
  
  if #tassels>1 then
   for i,tassel in pairs(tassels) do
    tassels[i]=nil
   end
  end
  
  for i=1,#tpballs do
   tpballs[i]=nil
  end
  
  
  if game.hasphys then
  	physicist.x,physicist.y=physicist.spawnx,physicist.spawny
  end
  
  game.upd=_play
  game.drw=d_play

end

function _scanmap()
if game.loadmap then

 for y=0,13 do
  for x=0,15 do
   local sprite=mget(x+16*(game.level-1),y+14*(game.world-1))
   for i=1,#objects do
    if sprite==objects[i].sprite then
     objects[i].func(x*8,y*8)     
     mset(x+16*(game.level-1),y+14*(game.world-1),0)
    end   
   end
  end
 end
 game.loadmap=false

end
end

function m_player()
 
 if btn(0)
 and player.x>8
 and player.vx>-player.maxvx then
  player.vx-=player.a
 elseif btn(1)
 and player.x+player.w<120
 and player.vx<player.maxvx then
  player.vx+=player.a
 else
  if player.vx<0 then
   player.vx+=player.da
  elseif player.vx>0 then
   player.vx-=player.da
  end
 end
 player.x+=player.vx
 
end

function _physicist()
 
 if game.hasphys then
 
  local p_collide=ccol(player.x,player.y,player.w,player.h,physicist.x-8,physicist.y,physicist.w,physicist.h)
 
 	physicist.q=game.world
 
 
 	if p_collide
 	and btnp(2) then
 		sfx(sound.text)
 	 game.upd=_text
 	 game.drw=d_text
 	end
 
 end
 
end

function _speech()

 if pspeech.t<#pspeech[physicist.q+1] then
 	if btnp(4) then
 		pspeech.t+=1
 		sfx(sound.text)
 	elseif btnp(5) then
 		pspeech.t=#pspeech[physicist.q+1]
 	end
 else
 	if btnp(5) then
 		pspeech.t=1
 		music(-1)
 		music(4)
 		if physicist.q==0 then
 			game.world+=1
 			game.nextlevel=true
 		 game.upd=_loadgame
 		 game.drw=d_loadgame
 		elseif physicist.q==5 then
 		 game.upd=_endgame
 		 game.drw=d_endgame
 		else
 	 	game.upd=_endworld
 	 	game.drw=d_endworld
 	 end
 	 
 	end
 end

end

function _player()

if not game.loadmap then

 local startx=player.x

	player.power=game.powers[game.world]

 
 if btn(0)
 and player.vx>-player.maxvx then
  player.vx-=player.a
 elseif btn(1)
 and player.vx<player.maxvx then
  player.vx+=player.a
 else
  if player.vx<0 then
   player.vx+=player.da
  elseif player.vx>0 then
   player.vx-=player.da
  end
 end
 
 
 
 player.x+=player.vx
 
 
 local xoffset=0
 local voffset=0
 
 if player.vx>0 then
  xoffset=7
 end
 
 if player.flipspr then
  voffset=3
 end
 
 local h=mget(((player.x+xoffset)/8)+16*(game.level-1),((player.y+7)/8)+14*(game.world-1))

 if fget(h,0) then
  player.x=startx
 elseif fget(h,1) then
  game.upd=_loadgame
  game.drw=d_loadgame
  sfx(sound.spikes)
 end
 
 player.vy+=game.g
 player.y+=player.vy
 
 local v=mget(((player.x+3+voffset)/8)+16*(game.level-1),((player.y+player.h)/8)+14*(game.world-1))
 
 
 player.isgrounded=false
 
 if player.vy>=0 then
  if fget(v,0) then
   player.y=flr(player.y/8)*8
   player.vy=0
   player.isgrounded=true
  elseif fget(v,1) or player.y>96 then
   game.upd=_loadgame
   game.drw=d_loadgame
   sfx(sound.spikes)
  end
 end
 
 v=mget(((player.x+3+voffset)/8)+16*(game.level-1),(player.y/8)+14*(game.world-1))
 print(v,10,30,7)
 if player.vy<=0 then
  if fget(v,0) then
   player.y=flr((player.y+player.h)/8)*8
   player.vy=0
  elseif fget(v,1) then
   game.upd=_loadgame
   game.drw=d_loadgame
   sfx(sound.spikes)
  end
 end

end

end

function _jet()

 jet.x=player.x
 jet.y=player.y+1

 if btn(4)
 and jet.fuel>0
 and player.vy>-player.maxvy then
  player.vy+=jet.v
  jet.fuel-=jet.consume
  
  local xoffset=0
  if player.flipspr then xoffset=6 end
  sfx(sound.jet)
  newsmoke={x=player.x+1+xoffset,y=player.y+5,r=1,vy=0,vx=(rnd(1.5)-0.5),clr=7}
		add(smokes,newsmoke)
 end
 
 if player.isgrounded then
  if jet.fuel<jet.maxfuel then
   jet.fuel+=jet.refill
   if jet.fuel<90 then
    sfx(sound.refill)
   elseif jet.fuel<95 then
    sfx(sound.maxrefill)
   end
  end
 end

end

function _impulso()

	imp.x=player.x
 imp.y=player.y+1
 
 if player.isgrounded then
 	imp.can=true
 end
 
 if btnp(4)
 and imp.can then
  imp.can=false
 	player.vy+=imp.v
 	sfx(sound.imp)
-- elseif btn(5)
-- and imp.can then
-- 	if player.flipspr then
-- 		player.vx+=imp.v
-- 	else
-- 		player.vx-=imp.v
-- 	end
-- 	imp.can=false
 end
 
 if imp.can==false then
  a_p_trail()
 end
 
 


end

function _hat()

 a_p_tassel()

end

function _teletransporter()

 local xoffset=0

 if btnp(4) then
 
  if #tpballs==0 then
  	if player.flipspr then
  	 xoffset=-1
  	else
  	 xoffset=1
  	end
  	newtpball={x=player.x,y=player.y,w=4,h=4,v=2*xoffset,vx=2*xoffset,vy=0,a=0}
	  add(tpballs,newtpball)
	  sfx(sound.tpball)
	 else
	  
	  for i,tpball in pairs(tpballs) do
	   del(tpballs,newtpball)
	   player.x,player.y=(tpball.x/8)*8,(tpball.y/8)*8
	  end	
	   
	 end
	 
	 
 end
 
 _tpball()
 p_tptrail()

end

function _tpball()
 
 for i,tpball in pairs(tpballs) do
  tpball.x+=tpball.vx
  tpball.y+=tpball.vy
  
  local c=mget(((tpball.x+4)/8)+16*(game.level-1),((tpball.y+4)/8)+14*(game.world-1))
 
  if fget(c,0)
  and c!=44 then
   del(tpballs,tpballs[i])
   sfx(sound.tpball)
  elseif fget(c,2) then
   _pointer()
  end
 end

end

function _power()

	if player.power=="jetpack" then
	 _jet()
 elseif player.power=="impulso" then
	 _impulso()
	elseif player.power=="chapeu" then
		_hat()
	elseif player.power=="teletransporte" then
	 _teletransporter()
	end
	

end

function _portal()
 
 local p_collide=ccol(player.x,player.y,player.w,player.h,portal.x,portal.y,portal.w,portal.h)
 
 if game.hasportal then
  if p_collide
  and player.havekey
  and btnp(2) then
   player.vx,player.vy=0,0
   game.nextlevel=true
   game.upd=_loadgame
   game.drw=d_loadgame
   sfx(sound.portalyes)
  elseif p_collide
  and btnp(2)
  and not player.havekey then
   sfx(sound.portalno)
  end
 end
 
end

function _key()

 local p_collide=ccol(player.x,player.y,player.w,player.h,key.x,key.y,key.w,key.h)
 
 if game.haskey
 and p_collide then
  if not player.havekey then
   sfx(sound.getkey)
  end
  player.havekey=true
  _lock()
 end

end

function _bis()
 
 local p_collide=ccol(player.x,player.y,player.w,player.h,bis.x,bis.y,bis.w,bis.h)
 
 if game.hasbis
 and p_collide then
  if not player.havebis then
   sfx(sound.bis)
  end
  player.havebis=true
 end
 
end



function _lock()

 if player.havekey then 
  for i,lock in pairs(locks) do
   mset(lock.x+16*(game.level-1),lock.y+14*(game.world-1),0)
  end
 end

end

function _onoff()

 if game.hasonoff then

	 if not game.hasswitch then
	  if t()%1.5==0 then
	  	if game.ison then
	  	 game.ison=false
	  	else
	  	 game.ison=true
	  	end
	  	sfx(sound.switch)
	  end
	 end

	 for i,onoff in pairs(onoffs) do
	  
	  if game.ison then
	  
	  	if onoff.group=="on" then
	  		onoff.on=true
	  		onoff.sprite=41
	  	elseif onoff.group=="off" then
	  		onoff.on=false
	  		onoff.sprite=58
	  	elseif onoff.group=="trap" then
	  	 onoff.on=false
	  	 onoff.sprite=60
	  	end
	  
	  else
	  	
	  	if onoff.group=="off" then
	  		onoff.on=true
	  		onoff.sprite=57
	  	elseif onoff.group=="on" then
	  		onoff.on=false
	  		onoff.sprite=42
	  	elseif onoff.group=="trap" then
	  	 onoff.on=true
	  	 onoff.sprite=59
	  	end
	  
	  end
	  
	 end

 end

end

function _switch()
	
	if game.hasswitch then
	
	 for i,switch in pairs(switches) do
		 local p_collide=ccol(player.x,player.y,player.w,player.h,switch.x-4,switch.y-4,switch.w+8,switch.h+8)
	
 		if p_collide
 		and btnp(4) then
 			if game.ison then
 				game.ison=false
 			else
 			 game.ison=true
 			end
 			sfx(sound.switch)
 		end
		
 	end
	
	end
	
end

function _disp()

if game.hasdisps then
 
 local d_dir={"up","down","left","right"}
 local d_vx={0,0,-2,2}
 local d_vy={-2,2,0,0}
	local d_a=0
	local d_b=0
	local tmax=30

	for i,disp in pairs(disps) do
	 disp.t-=1
	 if disp.t<0 then
	  disp.t=tmax
	  
	  for i=1,#d_dir do
	
	   if disp.way==d_dir[i] then
	    d_a=d_vx[i] 
	    d_b=d_vy[i]
	   end
	 	
	  end
	  
		 newsaw={x=disp.x*8,y=disp.y*8,w=7,h=7,vx=d_a,vy=d_b,a=0}
	  add(saws,newsaw)
	  sfx(sound.saw)
	 end
	 
	end
	
end

end

function _saw()

if game.hasdisps then
 
 for i,saw in pairs(saws) do
  
  local p_collide=ccol(player.x,player.y,player.w,player.h,saw.x,saw.y,saw.w,saw.h)
 
 
  saw.x+=saw.vx
  saw.y+=saw.vy
 
  local c=mget(((saw.x+4)/8)+16*(game.level-1),((saw.y+4)/8)+14*(game.world-1))
 
  if fget(c,0)
  or fget(c,1) then
   if c<37 or c>40 then
    del(saws,saws[i])
    sfx(sound.saws)
   end 
  end
  
  if p_collide then
   sfx(sound.spikes)
   game.upd=_loadgame
   game.drw=d_loadgame
   del(saws,saws[i])
  end
 
 
 end
 
end
 
end

function _trampoline()
 
 local tmax=30
 
 for i,tramp in pairs(tramps) do 
  local p_collide=ccol(player.x,player.y,player.w,player.h,tramp.x,tramp.y,tramp.w,tramp.h)
  
  if p_collide
  and tramp.can then
   if tramp.group=="momentum" then
    tramp.v=-(.95*player.vy)
   end
   player.vy=0
   player.vy+=tramp.v
   tramp.can=false
   
   if tramp.v!=0 then
    sfx(sound.tramp)
   end
 
  end
  
  if not tramp.can then
   tramp.t-=1
   if tramp.group=="pulse" then
    tramp.sprite=25
   elseif abs(player.vy)>0 then
    tramp.sprite=28
   end
  end
  
  if tramp.t<0 then
   tramp.t=tmax
   tramp.can=true
   if tramp.group=="pulse" then
    tramp.sprite=24
   else
    tramp.sprite=27
   end
  end 
  
 
 end

end

function _pointer()

if game.haspointer then
 local p_dir={"up","down","left","right"}
 local p_vx={0,0,-2,2}
 local p_vy={-2,2,0,0}
	local p_a=0
	local p_b=0
	
	
	for i,pointer in pairs(ps) do
	 
	 for j,tpball in pairs(tpballs) do
	 
	  local b_collide=ccol(tpball.x,tpball.y,tpball.w,tpball.h,pointer.x,pointer.y,pointer.w,pointer.h)
	 
	  if b_collide then
	  
	   --tpball.x,tpball.y=pointer.x,pointer.y
 	  
 	  for k=1,#p_dir do
	
	    if pointer.way==p_dir[k] then
	     p_a=p_vx[k] 
	     p_b=p_vy[k]
	    end

	   end
	   --tpball.x,tpball.y=pointer.x+4,pointer.y+4
		  tpball.vx,tpball.vy=p_a,p_b
	   sfx(sound.pointer)
	  end
	 end
	end	
	
end

end

function _sticker()

if game.hassticker then

 for i,sticker in pairs(stickers) do
  for j,tpball in pairs(tpballs) do
  
   local collide=ccol(sticker.x,sticker.y,sticker.w,sticker.h,tpball.x,tpball.y,tpball.w,tpball.h)
   
   if collide then
    tpball.x,tpball.y=sticker.x+2,sticker.y+2
   end
   
  end
 end

end

end

function _mech()

 player.a,player.da,player.maxvx=0.1,0.1,0.5
 player.power="traje"
 if btn(0)
 and player.x>8
 and player.vx>-player.maxvx then
  player.vx-=player.a
 elseif btn(1)
 and player.x+player.w<120
 and player.vx<player.maxvx then
  player.vx+=player.a
 else
  if player.vx<0 then
   player.vx+=player.da
  elseif player.vx>0 then
   player.vx-=player.da
  end
 end
 player.x+=player.vx
 
end

function _texto()

 endgame.textot-=1
 
 
 if endgame.textot<0
 and endgame.textoq<=#endgame.creditos then
  
  newtexto={
   x=64-#endgame.creditos[endgame.textoq]*2,
   y=130,
   q=endgame.creditos[endgame.textoq],
  }
  add(texto,newtexto)
  endgame.textoq+=1
  endgame.textot=endgame.textotmax
 end
 
 
 if endgame.continuet<1200 then
  endgame.continuet+=1
 end
 
end

function p_smoke()

 for i, smoke in pairs(smokes) do
  
  smoke.vy+=0.2
  smoke.x+=smoke.vx
  smoke.y+=smoke.vy
  
  if smoke.vy>1 then
   smoke.r-=1
  end
  
  if smoke.r<0 then
   del(smokes,smokes[i])
  end
 
 end

end

function p_circles()

	c.ct-=1
	
	if c.ct<0 then
	
		newcircle={	
		 x=player.x+4,
			y=player.y+5,
			r=1,
			clr=c.c}
		add(circles,newcircle)
		c.ct=c.ctmax
		if c.c<14 then
	  c.c+=1
	 else
	 	c.c=8
	 end
	
	end

 for i,circle in pairs(circles) do
 	
 	circle.r+=1
 	
 	if circle.r>128 then
 	 del(circles,circle)
 	end
 end

end

function a_p_trail()

	
	 newtrail={
	  x=player.x,
	  y=player.y,
	  t=0,
	  clr=12}
	 add(trails,newtrail)

end

function p_trail()

	for i, trail in pairs(trails) do
		trail.t+=1
		
		if trail.t>8 then
			del(trails,trails[i])
		elseif trail.t>6 then
			trail.clr=1
		elseif trail.t>4 then
			trail.clr=13
		end
	end

	

end

function a_p_tassel()

 local x=hat.x
 local y=hat.y
 
 if player.vx==0
 and player.vy==0 then
  if player.flipspr then
   x+=8
  else 
   x-=1
  end
  y+=1
 elseif player.flipspr then
  x+=7
 end

 newtassel={
  x=x,
  y=y,
  t=0,
  clr=10,
 }
 add(tassels,newtassel)

end

function p_tassel()

 for i,tassel in pairs(tassels) do
  if #tassels>1 then
   del(tassels,tassels[i])
  end
 end

end

function p_tptrail()
 
 tpt.ct-=1
 
 if tpt.ct<0 then
  
  for i,tpball in pairs(tpballs) do
   for i=1,2 do
   local rand=rnd(tpball.h*0.75)-tpball.h/4
   
    newp={x=tpball.x,y=tpball.y+rand,t=0,}
    add(tptrails,newp)
   end
  end
  tpt.ct=tpt.ctm
 end
 
end
-->8
--draw

function d_save()
 print(dget(0),10,10,7)
 print(dget(1),10,20,7)
 print(dget(2),10,30,7)
end

function d_menu()
 cls()
 _draw_stars()
 menua+=.02
 local a="galaxy castle ii"
 local b="DUNGEONS OF NIMBUS"
 
 pr(a,64-#a*3,51,2)
 pr(a,64-#a*3,50,7)
 outline(b,64-(#b+.5)*2,58,2,7)
 
 map(67,57,48,4+1.5*sin(menua),4,5)
 
 map(112,56,0,32,16,16)
 
 rectfill(0,96,127,128,0)
 fillp(„)
 rectfill(0,96,127,128,1)
 fillp()
 
 
 if dget(0)!=0
 and dget(1)!=0 then
  d_tinyportal()
 else
  d_physicist()
 end
 d_player()

end

function d_tinyportal()

 local p_collide=ccol(player.x,player.y,player.w,player.h,tportal.x,tportal.y,tportal.w,tportal.h)
 
 tportal.uia+=0.1

 if p_collide then
  outline("” to ".. dget(0) .. "-" .. dget(1),tportal.x-18,tportal.y-8+1*sin(0.5*tportal.uia),5,0)
 end
 
 tportal.timer-=1

 if tportal.timer<=0 then
  tportal.timer=tportal.maxtimer
  tportal.clr+=1
  tportal.clr%=15
 end
 
 if tportal.base>15 then
  tportal.base=8
 end
 
 for i=1,9 do
  if i==tportal.clr then
   pal(i,tportal.highlight)
  elseif i!=tportal.highlight then
   pal(i,tportal.base)
  end
 end
 
 tportal.highlight=7
 tportal.base=11
 spr(tportal.sprite,tportal.x,tportal.y+1*sin(0.5*tportal.uia))  
 pal()
 
end

function d_text()
 cls(0)
 d_speech()
 
 local a="Ž to continue"
 local b="— to skip"
 local c="— to continue"
 
 if pspeech.t<#pspeech[physicist.q+1] then
  outline(a,54-#a*2,100,5,0)
  outline(b,54-#b*2,110,5,0)
 else
  outline(c,54-#c*2,105,5,0)
 end
 local yoffset=0
 local sx={72,120,120,120,120,48}
 local sy={0,24,24,24,24,8}
 
 if physicist.q>0 then
  yoffset=3
 end
 
 sspr(80,0,8,16,8,78,24,48)
 sspr(physicist.q*8,(physicist.sprite+16)/2,8,16,96,78,24,48)
 sspr(sx[physicist.q+1],sy[physicist.q+1],8,8,99,69+yoffset,24,24)
end

function d_loadgame()
 cls(7)
end

function d_play()
  cls()
   d_map()
  if game.world!=5 then
   d_gui()
  else
   _draw_stars()
   rectfill(0,64,127,128,0)
   fillp(„)
   rectfill(0,64,127,128,1)
   fillp()
   map(16*(game.level-1),14*(game.world-1),0,0,16,14)
  end
  d_portal()
  d_lock()
  
  d_onoff()
  d_switch()
  d_disp()
  d_saw()
  d_trampoline()
  d_pointer()
  d_sticker()
  
  d_key()
  d_bis()
  d_physicist()
  d_p_smoke()
  d_p_trail()
  d_p_tptrail()
  
  if game.world!=5 then 
   d_player()
  else
   d_mech()
  end
  d_power()
  d_p_tassel()
    
end

function d_endworld()
	
	local a=atan2(60-player.x,30-player.y)
	local s1="you rescued a princess!"
	local s2="keep going!"
	local s3="— to continue"
	
	if abs(60-player.x)>0.2
	and abs(30-player.y)>0.2 then
		cls()
		player.x+=0.5*cos(a)
		player.y+=0.5*sin(a)
		player.sprite=6
		music(3)
	else
		player.sprite=7
		p_circles()
		d_circles()
		ospr(player.sprite,0,player.x,player.y,1,1,player.flipspr)
		outline(s1,64-#s1*2,70,0,12)
		outline(s2,64-#s2*2,80,0,7)
		outline(s3,64-#s3*2,100,0,13)
	end
	
	ospr(player.sprite,rnd(14)+1,player.x,player.y,1,1,player.flipspr)

end

function d_endgame()

 cls()
 local a=atan2(62-player.x,90-player.y)
	_draw_stars()
	if abs(62-player.x)>0.2
	and abs(90-player.y)>0.2
	and player.there==false then
		player.x+=0.5*cos(a)
		player.y+=0.5*sin(a)
		player.sprite=6
		music(5)
	else
	 player.there=true
		player.sprite=7
		if player.y>30 then
		 player.y-=1
		end
		
		
		d_rainbows()
		d_physfly()
		
		--ospr(player.sprite,0,player.x,player.y,1,1,player.flipspr)
	end
	
	--ospr(player.sprite,rnd(14)+1,player.x,player.y,1,1,player.flipspr)
 spr(player.sprite,player.x,player.y)
 d_texto()
 
end

function d_physicist()
 if game.hasphys then
  local p_collide=ccol(player.x,player.y,player.w,player.h,physicist.x-8,physicist.y,physicist.w,physicist.h)
  physicist.a+=0.1
  if physicist.a>10 then
   physicist.a=0
  end
  local c={31,47,47,47,47,22}
  local cx={0,2,2,2,2,0}
  local cy={-2,-2,-2,-2,-2,0}
  spr(physicist.sprite+physicist.q,physicist.x,physicist.y+cos(physicist.a))
  spr(c[physicist.q+1],physicist.x+cx[physicist.q+1],physicist.y+cy[physicist.q+1]+cos(physicist.a))
		
		if physicist.a%2<1 then
		 spr(72,physicist.x-7,physicist.y-2)
		end
		if p_collide then
   outline("”",physicist.x-2,physicist.y-10,5,0)
  end
	
	end
end

function d_speech()

	for i=1,pspeech.t do
	
		print(pspeech[physicist.q+1][i],64-#pspeech[physicist.q+1][i]*2,2+8*(i-1),cspeech[physicist.q+1][i])
	
	end

end

function d_gui()

 local clr=11

 rectfill(0,112,127,127,1)
 
 outline("level "..game.world.."-"..game.level,90,120,13,7)
 
 if player.power=="jetpack" then
 
  for i=1,10 do
   spr(15,1+4*(i-1),114)
  end
 
  outline("fuel",1,120,13,7)
 
  for i=1,flr(jet.fuel/10) do
 
   if i<=2 then
    clr=8
   elseif i<=4 then
    clr=9
   elseif i<=5 then
    clr=10
   else
    clr=11
   end
 
   rectfill(2+4*(i-1),115,2+2+4*(i-1),117,clr)
 
  end

 end

end

function d_player()
 
 if player.vx<0 then
  player.flipspr=true
 elseif player.vx>0 then
  player.flipspr=false
 end
 
 if player.vx!=0
 and player.isgrounded then
  player.timer-=1
  if player.timer%4==0 then
   player.sprite+=1
  end
  
  if player.timer<0 then
   player.timer=12
  end
  
  if player.sprite>5 then
   player.sprite=2
  end
 elseif player.isgrounded==false then
  if player.power=="jetpack" then
  	player.sprite=6
  else
   player.sprite=8
  end
 else
  player.sprite=1
 end

  spr(player.sprite,player.x,player.y,1,1,player.flipspr)
  --spr(13,player.x,player.y,1,1,player.flipspr)

end

function d_jet()

 if player.flipspr==true then
  jet.flipspr=true
 else
  jet.flipspr=false
 end

 spr(jet.sprite,jet.x,jet.y,1,1,jet.flipspr)
 
end

function d_impulso()

	if player.flipspr==true then
  imp.flipspr=true
 else
  imp.flipspr=false
 end
 
 if imp.can then
 	spr(imp.sprite,imp.x,imp.y,1,1,imp.flipspr)
	else
	 pal(11,8)
	 spr(imp.sprite,imp.x,imp.y,1,1,imp.flipspr)
	 pal()
	end
end

function d_hat()
 
 local xoffset=2
 local yoffset=0
 
 if player.sprite==5 then
  yoffset=1
 end
 
 if player.flipspr then
  xoffset=-2
 else
 end
 
 hat.x=player.x+xoffset
 hat.y=player.y-2+yoffset
 
	spr(51,hat.x,hat.y,1,1,player.flipspr)

end

function d_tpball()
 for i,tpball in pairs(tpballs) do
  spr(13,tpball.x,tpball.y)
 end
 
end

function d_teletransporter()
 local yoffset=0
 if player.sprite==5 then
  yoffset=1
 end
 if #tpballs==0 then
  spr(52,player.x,player.y+yoffset,1,1,player.flipspr)
 else
  pal(12,8)
  spr(52,player.x,player.y+yoffset,1,1,player.flipspr)
  pal()
 end
 d_tpball()

end

function d_power()
 if player.power=="jetpack" then
  d_jet()
 elseif player.power=="impulso" then
 	d_impulso()
 elseif player.power=="chapeu" then
 	d_hat()
 elseif player.power=="teletransporte" then
  d_teletransporter()
 end
end

function d_portal()
 local p_collide=ccol(player.x,player.y,player.w,player.h,portal.x,portal.y,portal.w,portal.h)

 if game.hasportal then 
  portal.uia+=0.1
 
  if p_collide then
   outline("”",portal.x+3,portal.y-8+sin(portal.uia),5,0)
  end
  
  portal.timer-=1
 
  if portal.timer<=0 then
   portal.timer=portal.maxtimer
   portal.clr+=1
   portal.clr%=15
   if player.havekey then
    portal.base+=0.25
   end
  end
  
  if portal.base>15 then
   portal.base=8
  end

 
  for i=3,15 do
   if i==portal.clr then
    pal(i,portal.highlight)
   elseif i!=portal.highlight then
    pal(i,portal.base)
   end
  end
 
 
  if player.havekey then
   portal.highlight=7
   pal(2,1)
   spr(portal.sprite,portal.x,portal.y,2,2)  
  else
   portal.highlight=5
   portal.base=13
   spr(portal.sprite,portal.x,portal.y,2,2)  
  end
  pal()
 end
 
end

function d_key()

 local s={45,46,61,46,45,46,61,46,45,45}
 local f={false,false,false,true,true,true,false,false,false,false}
 local t={0,0,0,-1,-1,-1,0,0,0}
 if game.haskey
 and not player.havekey then
  
  if key.a<8.99 then
   key.a+=.25
  else
   key.a=1
  end 
  
  if key.aa<.9 then
   key.aa+=.025
  else
   key.aa=0
  end
  
  --ospr(s[ceil(key.a)],2,key.x+t[ceil(key.a)],key.y+1.5*sin(key.aa),1,1,f[ceil(key.a)],false)
  spr(s[ceil(key.a)],key.x+t[ceil(key.a)],key.y+1.5*sin(key.aa),1,1,f[ceil(key.a)],false)
 
 end

end

function d_bis()

 if game.hasbis
 and not player.havebis then
  bis.a+=0.05
  ospr(bis.sprite,flr(100*bis.a),bis.x,bis.y+1.1*sin(1.1*bis.a),1,1)
 end
 
end


function d_lock()

 if not player.havekey then
  for i,lock in pairs(locks) do
   mset(lock.x+16*(game.level-1),lock.y+14*(game.world-1),lock.sprite)
  end
 end

end

function d_onoff()
	
	if game.hasonoff then
	 for i,onoff in pairs(onoffs) do
	  
	  if onoff.group=="trap"
	  and onoff.on then
	    local f=1.25
     if onoff.px<5
     and onoff.py<5 then
      onoff.px+=f
      onoff.py+=f
     elseif onoff.pa<5
     and onoff.pb<5 then
      onoff.pa+=f
      onoff.pb+=f
     else
      onoff.px,onoff.py,onoff.pa,onoff.pb=0,0,0,0
     end

     line(onoff.x*8+1+onoff.px,onoff.y*8+1+onoff.pa,onoff.x*8+1+onoff.pb,onoff.y*8+1+onoff.py,7)
	    sfx(sound.trap)
	  end
	 
	 	mset(onoff.x+16*(game.level-1),onoff.y+14*(game.world-1),onoff.sprite)
	 
	 end
	end
	
end

function d_switch()

 if game.hasswitch then
 

 
  for i,switch in pairs(switches) do
   
   if game.ison then
    switch.sprite=11
   else
    switch.sprite=12
   end
  	
  	spr(switch.sprite,switch.x,switch.y)
  end
 
 end

end

function d_disp()

 for i,disp in pairs(disps) do
  mset(disp.x+16*(game.level-1),disp.y+14*(game.world-1),disp.sprite)
 end

end

function d_saw()
 
 local sprites={14,30}
 local flips={false,false,true,true}
 
 for i,saw in pairs(saws) do
  saw.a+=.75
  
   spr(sprites[(flr(saw.a)%2)+1],saw.x,saw.y,1,1,flips[flr(saw.a)+1],false)
  
  if saw.a>=4 then
   saw.a=0
  end
  
 end
 
end

function d_trampoline()

 for i,tramp in pairs(tramps) do
  spr(tramp.sprite,tramp.x,tramp.y)
 end 

end

function d_pointer()
 for i,pointer in pairs(ps) do
  spr(pointer.sprite,pointer.x,pointer.y)
 end
end

function d_sticker()
 for i,sticker in pairs(stickers) do
  spr(sticker.sprite,sticker.x,sticker.y)
 end
end


function d_mech()

 if player.vx<0 then
  player.flipspr=true
 elseif player.vx>0 then
  player.flipspr=false
 end
 
 if player.vx!=0 then
  player.timer-=1
  if player.timer%4==0 then
   player.sprite+=2
  end
  
  if player.timer<0 then
   player.timer=12
  end
  
  if player.sprite>110 then
   player.sprite=102
  end
 else
  player.sprite=102
 end

  spr(player.sprite,player.x,player.y-4,2,2,player.flipspr)

end

function d_physfly()

 if endgame.physt<90 then
  endgame.physt+=1
 else
  if endgame.physy>100 then
   endgame.physy-=1
  end
  
  for i=0,2 do
   --ospr(player.sprite,rnd(14)+1,player.x,player.y,1,1,player.flipspr)
   spr(90+i,10*(i+1),endgame.physy-20*i)
   spr(93+i,90+10*(i),endgame.physy+20*i-40)
  end
 end
 
end

function d_rainbows()

 if 90+endgame.yoffset<130 then
  endgame.yoffset+=1
 end
  
 for i=0,4 do
  line(player.x+i,90+endgame.yoffset,player.x+i,player.y+7,8+i)
 end
 
 for j=0,2 do
  for k=0,4 do
   line(10*(j+1)+k,130,10*(j+1)+k,endgame.physy-20*j+7,8+k)
   line(93+10*(j)+k,130,93+10*(j)+k,endgame.physy+20*j+7-40,8+k)
  end
 end
 
end

function d_texto()

 for i,text in pairs(texto) do
  text.y-=.2
  outline(text.q,text.x,text.y,0,7)
  
 
  if text.y<-10 then
   del(texto,texto[i])
  end
 
 end
 
 if endgame.continuet>=1200
 and #texto==0 then
  if endgame.finaly>40 then
   endgame.finaly-=1
  end
  local a="galaxy castle ii"
  local b="DUNGEONS OF NIMBUS"

  pr(a,64-#a*3,endgame.finaly+1,2)
  pr(a,64-#a*3,endgame.finaly,7)
  outline(b,64-(#b+.5)*2,endgame.finaly+8,2,7)

 end
 
end

function d_map()
 rectfill(0,0,128,128,0)
 --pal(6,13)
 --pal(5,1)
 map(16*(game.level-1),14*(game.world-1),0,0,16,14)
 --pal()
end

function d_p_smoke()
 for i, smoke in pairs(smokes) do
  circfill(smoke.x,smoke.y,smoke.r,smoke.clr)
 end
end

function d_circles()

	for i,circle in pairs(circles) do
		circfill(circle.x,circle.y,circle.r,circle.clr)
	end

end

function d_p_trail()
	

	for i,trail in pairs(trails) do
		pal(1,trail.clr)
		pal(5,trail.clr)
		pal(7,trail.clr)
		pal(9,trail.clr)
		pal(10,trail.clr)
		pal(12,trail.clr)
		spr(player.sprite,trail.x,trail.y,1,1,player.flipspr)
		pal()
	end

end

function d_p_tassel()


 if player.power=="chapeu" then
  for i,tassel in pairs(tassels) do
   line(tassel.x,tassel.y,tassel.x,tassel.y,tassel.clr)
  end
 end

end

function d_p_tptrail()
 for i,tptrail in pairs(tptrails) do
  tptrail.t+=1
--  pal(3,13)
--  pal(11,3)
--  pal(7,6)
--  spr(14,tptrail.x,tptrail.y)
--  pal()
  
  if tptrail.t>4 then
   del(tptrails,tptrails[i])
  end
 end
end

-->8

-->8
--premade functions

function ccol(x1,y1,w1,h1,x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function outline(s,x,y,c1,c2)
	for i=0,2 do
	 for j=0,2 do
	  if not(i==1 and j==1) then
	   print(s,x+i,y+j,c1)
	  end
	 end
	end
	print(s,x+1,y+1,c2)
end

fdat = [[  0000.0000! 739c.e038" 5280.0000# 02be.afa8$ 23e8.e2f8% 0674.45cc& 6414.c934' 2100.0000( 3318.c618) 618c.6330* 012a.ea90+ 0109.f210, 0000.0230- 0000.e000. 0000.0030/ 3198.cc600 fef7.bdfc1 f18c.637c2 f8ff.8c7c3 f8de.31fc4 defe.318c5 fe3e.31fc6 fe3f.bdfc7 f8cc.c6308 feff.bdfc9 fefe.31fc: 0300.0600; 0300.0660< 0199.8618= 001c.0700> 030c.3330? f0c6.e030@ 746f.783ca 76f7.fdecb f6fd.bdf8c 76f1.8db8d f6f7.bdf8e 7e3d.8c3cf 7e3d.8c60g 7e31.bdbch deff.bdeci f318.c678j f98c.6370k def9.bdecl c631.8c7cm dfff.bdecn f6f7.bdeco 76f7.bdb8p f6f7.ec60q 76f7.bf3cr f6f7.cdecs 7e1c.31f8t fb18.c630u def7.bdb8v def7.b710w def7.ffecx dec9.bdecy defe.31f8z f8cc.cc7c[ 7318.c638\ 630c.618c] 718c.6338^ 2280.0000_ 0000.007c``4100.0000`a001f.bdf4`bc63d.bdfc`c001f.8c3c`d18df.bdbc`e001d.be3c`f3b19.f630`g7ef6.f1fa`hc63d.bdec`i6018.c618`j318c.6372`kc6f5.cd6c`l6318.c618`m0015.fdec`n003d.bdec`o001f.bdf8`pf6f7.ec62`q7ef6.f18e`r001d.bc60`s001f.c3f8`t633c.c618`u0037.bdbc`v0037.b510`w0037.bfa8`x0036.edec`ydef6.f1ba`z003e.667c{ 0188.c218| 0108.4210} 0184.3118~ 02a8.0000`*013e.e500]]
cmap={}
for i=0,#fdat/11 do
 local p=1+i*11
 cmap[sub(fdat,p,p+1)]=
  tonum("0x"..sub(fdat,p+2,p+10))
end

function pr(str,sx,sy,col)
 local sx0=sx
 local p=1
 while (p <= #str) do
  local c=sub(str,p,p)
  local v 

  if (c=="\n") then
   -- linebreak
   sy+=9 sx=sx0 
  else
      -- single (a)
      v = cmap[c.." "] 
      if not v then 
       -- double (`a)
       v= cmap[sub(str,p,p+1)]
       p+=1
      end

   --adjust height
   local sy1=sy
   if (band(v,0x0.0002)>0)sy1+=2

   -- draw pixels
   for y=sy1,sy1+5 do
       for x=sx,sx+4 do
        if (band(v,0x8000)<0) pset(x,y,col)
        v=rotl(v,1)
       end
      end
      sx+=6
  end
  p+=1
 end
end

function ospr(n,col_outline,x,y,w,h,flip_x,flip_y)
  -- reset palette to black
  for c=1,15 do
    pal(c,col_outline)
  end
  -- draw outline
  for xx=-1,1 do
    for yy=-1,1 do
      spr(n,x+xx,y+yy,w,h,flip_x,flip_y)
    end
  end
  -- reset palette
  pal()
  -- draw final sprite
  spr(n,x,y,w,h,flip_x,flip_y)	
end

function _init_stars()
 
 stars={}

 warp=1
 starminx,starminy=0,0
 starmaxx,starmaxy=127,127
 
 metal={13,6,7}
 cool={1,12,7}
 
 local totstars=200

 for i=1,totstars do
 
  local rndspd=rnd(3)

  add(stars,{
   x=rnd(128),
   y=rnd(128),
   spd=rndspd
  })

 end
 
end

function _update_stars(_warp)
 
 --if _warp<=2 then
  warp=_warp
 --else
  --warp=2
 --end
 
  for st in all(stars) do

   if warp>0 then
    st.y+=st.spd+3*(warp-1)
   end

   if (st.y>=starmaxy) then
    st.y=starminy
    st.x=(flr(rnd(128)))
    st.spd=rnd(4)
   end
  end

end 

function _draw_stars()

 for st in all(stars) do

  if warp==2 then

   if st.spd>=2 then

    line(st.x, st.y-6, st.x, st.y-10, cool[1])
    line(st.x, st.y-1, st.x, st.y-5, cool[2])
    pset(st.x, st.y, cool[3])
   elseif st.spd>=.5 then
    line(st.x, st.y-1, st.x, st.y-2, cool[1])
    pset(st.x, st.y, cool[2])
   elseif st.spd>0 then
   -- ..just draw a lonely dark
   -- blue star!
    pset(st.x, st.y, cool[1])
   end
   
  else 
  
   pset(st.x, st.y, metal[flr(st.spd)+1])
  
  end
 end
end

-->8
--create objects

function c_player(_x,_y)
 player.spawnx,player.spawny=_x,_y-4
end

function c_key(_x,_y)
 game.haskey=true
 key.spawnx,key.spawny=_x,_y-2
end

function c_portal(_x,_y)
 game.hasportal=true
 portal.x,portal.y=_x,_y-2
end

function c_lock(_x,_y)
 game.haslock=true
 newlock={x=_x/8,y=_y/8,w=8,h=8,sprite=16}
 add(locks,newlock)
end

function c_bis(_x,_y)
 game.hasbis=true
 bis.spawnx,bis.spawny=_x,_y-2
end

function c_onoff_red(_x,_y)
 game.hasonoff=true
 newonoff={group="on",x=_x/8,y=_y/8,w=8,h=8,sprite=41,on=true}
 add(onoffs,newonoff)
end

function c_onoff_blue(_x,_y)
 game.hasonoff=true
 newonoff={group="off",x=_x/8,y=_y/8,w=8,h=8,sprite=57,on=false}
 add(onoffs,newonoff)
end

function c_onoff_trap(_x,_y)
 game.hasonoff=true
 newonoff={group="trap",x=_x/8,y=_y/8,w=8,h=8,sprite=59,on=false,px=0,py=0,pa=0,pb=0}
 add(onoffs,newonoff)
end

function c_switch(_x,_y)
 game.hasswitch=true
 newswitch={x=_x,y=_y,w=8,h=8,sprite=11}
 add(switches,newswitch)
end

function c_physicist(_x,_y)
 game.hasphys=true
	physicist.spawnx,physicist.spawny=_x,_y
end

function c_disps_up(_x,_y)
 game.hasdisps=true
 newdisp={sprite=37,x=_x/8,y=_y/8,way="up",t=10}
 add(disps,newdisp)
end

function c_disps_down(_x,_y)
 game.hasdisps=true
 newdisp={sprite=38,x=_x/8,y=_y/8,way="down",t=10}
 add(disps,newdisp)
end

function c_disps_right(_x,_y)
 game.hasdisps=true
 newdisp={sprite=39,x=_x/8,y=_y/8,way="right",t=10}
 add(disps,newdisp)
end

function c_disps_left(_x,_y)
 game.hasdisps=true
 newdisp={sprite=40,x=_x/8,y=_y/8,way="left",t=10}
 add(disps,newdisp)
end

function c_tramps_pulse(_x,_y)
 newtramp={group="pulse",sprite=24,v=-4.4,x=_x,y=_y,w=8,h=8,can=true,t=30,}
 add(tramps,newtramp)
end

function c_tramps_momentum(_x,_y)
 newtramp={group="momentum",sprite=27,v=0,x=_x,y=_y,w=8,h=8,can=true,t=30,}
 add(tramps,newtramp)
end

function c_pointer_up(_x,_y)
 game.haspointer=true
 newpointer={sprite=53,x=_x,y=_y,way="up",w=8,h=8}
 add(ps,newpointer)
end

function c_pointer_down(_x,_y)
 game.haspointer=true
 newpointer={sprite=54,x=_x,y=_y,way="down",w=8,h=8}
 add(ps,newpointer)
end

function c_pointer_left(_x,_y)
 game.haspointer=true
 newpointer={sprite=55,x=_x,y=_y,way="left",w=8,h=8}
 add(ps,newpointer)
end

function c_pointer_right(_x,_y)
 game.haspointer=true
 newpointer={sprite=56,x=_x,y=_y,way="right",w=8,h=8}
 add(ps,newpointer)
end

function c_sticker(_x,_y)
 game.hassticker=true
 newsticker={x=_x,y=_y,sprite=29,w=8,h=8,}
 add(stickers,newsticker)
end

-->8
--game states

function _menu()
 _update_stars(0,96)
 m_player()
 
 if dget(0)!=0
 and dget(1)!=0 then
  _tinyportal()
 else
  _physicist()
 end
 
end

function _text()
 _speech()
end

function _play()
 _portal()
 if game.world!=5 then
  _player()
 else
  _mech()
  _update_stars(0,96)
 end
 _power()
 _key()
 _bis()
 _lock()
 
 _onoff()
 _switch()
 _disp()
 _saw()
 _trampoline()
 _pointer()
 _sticker()
 
 _physicist()

 p_smoke()
 p_trail()
 p_tassel()
end

function _endworld()
 player.flipspr=false
 if player.sprite==7 then
  if btnp(5)  then
  	music(-1)
  	
  	for i,circle in pairs(circles) do
    circles[i]=nil
   end
   
   game.world+=1
   game.level=0
   game.nextlevel=true
   game.upd=_loadgame
   game.drw=d_loadgame
   
   music(18+game.world)
  end
 end
	
end

function _endgame()

 player.flipspr=false
 endgame.creditos[2]="and got "..player.bis.."/12 diamonds!"
 _texto()
 _resetdata()
 if player.there then
  _update_stars(1)
 else
  _update_stars(0)
 end
end
__gfx__
0000000000999900009999000099990000999900000000000099990000999900009999000000000099990000000e000000000000033000000060000055550000
000000000009acc00009acc00009acc00009acc0009999000009acc00709acc00009acc0a0aa0a0009acc00005515500055555003b730000006776605ddd5000
007007000009aac00009aac00009aac00009aac00009acc00009aac00109aac00009aac00a77a00009aac00005617500056675003bb30000007667005ddd5000
0007700001119ac001119ac001119ac001119ac00119aac001119ac001119ac001119ac000000000099ac000056175000561750003300000007667005ddd5000
000770000111100001111000011110000111100001119ac001111000011110000111100000000000111100000576650005716500000000000667760055550000
00700700075a5000075a5000075a5000075a5000075a5000057a5700055a5700057a500000000000111100000555550005515500000000000000060000000000
000000000111100001111000011110000111100001111000011110000111700001117000000000001111000000000000000c0000000000000000000000000000
00000000070070000707000007007000007070000700700000700700700000007000000000000000111100000000000000000000000000000000000000000000
6677777755555555060006006770677066770000000066770000000011111111000000000000000015a5000000000000000000000000000000006000a0a0a000
6060060756777775060006006670667066676666666666670000000017666661000000000000000071110000000000000000000000222200000770000a7a0000
606006075666667506000600666066606666000000006666000000001777dd6100000000009999001001000009aaaa9000000000022552200676670000000000
606cd6075666667506000600666066600000000000000000000000001777dd610000000009aaaa901001000000d00d00000000000253d5200076676000000000
606dc6075666667567706770060006006677000000006677000000001ddd77610000000000d00d00100100000005500000000000025335200007700000000000
6060060757666675667066700600060066676666666666670000000016dd77610000000000055000700700000005500009aaaa90022552200006000000000000
70600607577666656660666006000600666600000000666600000000166d77710099990000d00d007007000000d00d00000dd000002222000000000000000000
776666665555555566606660060006000000000000000000000000001111111109aaaa90000550007707700009aaaa9009aaaa90000000000000000000000000
00000000000000222000000050000000b0000000100000011111111111111111111111110022220000444400000dd000003333000009aaa00009aa00a0000000
00000000000022bbb2200000555000007770000011000011166dd771166677100166677102e77720042ddd4000d89d0003077730000a9000000a90007aa00000
000000000002bbaaabb20000505000007070000016222271166dd67116661200002166712eeeee72422222d40d5689d030000073000aaa00000aa00000000000
000cd000002baa999aab2000500000007000000016122171166116611dd1220000221dd12eeeee72422222d40d4568d030000073000a0000000a000000000000
000dc000002ba98889ab200060000000c000000016611661161221611dd1220000221dd12eeeee72422222d40d2456d030000073000a0000000a000000000000
0000000002ba9866689ab2000000000000000000166dd66117222261166612000021666127eeeee24d2222240d1245d03700000300a0a000000aa00000000000
0000000002ba9864689ab2000000000000000000176dd661110000111766661001766661027eee2004d2224000d12d000370003000a0a000000aa00000000000
0000000002ba9863689ab2000000000000000000111111111000000111111111111111110022220000444400000dd00000333300009a9000000aa00000000000
0000000002ba9863689ab200a800000000cc555000000000000000000000000000000000001111000055550000999900001111000009000000000000a0000000
00cc700002ba9864689ab2008800000000055bb0000d00000003000000d0030000300d0001c77710051ddd5009aa579001445d10000a000000000000aa000000
0cccc70002ba9866689ab20000000000000000b000ddd000003b30000dd03b3003b30dd01ccccc71511111d59aa55a79144554d1000a0000000000007aaa0000
006cc000002ba98889ab200000000000000000b0000000000003000000d0030000300d001ccccc71511111d59a55aa5914554451000a00000000000000000000
00060000002baa999aab20000000000000000000000300000000000000000000000000001ccccc71511111d5955aa55915544551000a00000000000000000000
000000000002bbaaabb200000000000000000000003b300000ddd000000000000000000017ccccc15d11111595aa55a915445541000a00000000000000000000
00000000000022bbb2200000000000000000000000030000000d00000000000000000000017ccc1005d1115009755a9001d55410000a00000000000000000000
00000000000000222000000000000000000000000000000000000000000000000000000000111100005555000099990000111100000a00000000000000000000
000900000020000000000000000000000dad00000000000005555000002222227070700020dadadad111d2222222000005555555555555555555555555555550
0009999000200000000000000002020202d202000000000005555000000111117070700000ddddddd111dd1111100000527d6d6676662766d662777d77276d75
0009acc90222000000002000000222222222220000000000055550000001a11100000000202d2d2d21212d212120200057d5226627d25dd66665265267526dd5
0449aac9022200000000200000002222222220002000000005555550000111117070700022222222222222222222200005dd552227666666627667526752d750
04499999222220000002220000000ddddddd000020000000000555500001a111000000002222222222222222222200000056dd55d27d66dd2276677526d52500
094440000ddd00000002220000000dadadad0002220000000005555000011111000000001111111111111111111000000005556d66d6665227d6d66766555000
011110000dad00000022222000000dd2d2d2020222000000000555500001111100000000111111111111111111100000000000555d66d6557662756555000000
070070000ddd00000001110000000da2222222222220000000050050000111110000000011111111111111111110000000000000055555555555555000000000
0444400000aaa000004440000011100000999000507750000001a10000000ddd22222001110000000044400000aaa0000b044440507750000001110000099900
4bbb440000bbaa0000cc44000088110000aa990003337000000111000000222221112221a1000000044cc0000aabb0000244bbb40333703000088110000aa990
0bbb400000bbba0000ccc4000088810000aaa900033370000001a1000002222221a1222111000000c4ccc000babbb0000204bbb00333702000088818000aaa9a
044442200aa7daa004473440011751100997e99007777660000111000022222221112221a10000004c374400abd7aa0002244440077776200011758100997ea9
00287820000db0000003c00000058000000ea00007772220000111000222222221a12221110000000033c00000ddb000028780000777222000085500000aee00
002888b000ddbd000033c3000055850000eeae00000222300001110000ddddddd111ddd111000000033330000dddd00002888b000032222000055550000eeee0
000dddd000ddddd0003333300055555000eeeee0000222200202120202dadadad111ddd11100000033337300dddd7d000ddd7000000722200057555500e7eeee
000700700ddddddd03333333055555550eeeeeee000500500222222222ddddddd111d2d21202000079abc00079abc00079abc00000089ab700089ab700089ab7
00444400000000000000000000000000000000000507705000000999900000000000099990000000000009999000000000000999900000000000000000000000
04bbb4400aaaa000044440000111100009999000055335500000009acc0000000000009acc0000000000009acc0000000000009acc0000000000099990000000
00bbb4400bbaa0000cc44000088110000aa99000003333700000009aac0000000000009aac0000000000009aac0000000000009aac0000000000009acc000000
0044b4000bbbaa000ccc4400088811000aaa99000077337000000099ac00000000000099ac00000000000099ac00000000000099ac0000000000009aac000000
004444000a7dda000473340001755100097ee90007777300117111111111711011711111111171101171111111117110117111111111711011711199ac117110
00287822aa7ddaa04473344011755110997ee9900777766011777a7a7a77711011777a7a7a77711011777a7a7a77711011777a7a7a77711011777a7a7a777110
0028782200ddb0000033c0000055800000eea00000776222111777aaa7771110111777aaa7771110111777aaa7771110111777aaa7771110111777aaa7771110
0028782200ddb0000033c0000055800000eea0000002222211171111111711101117111111171110111711111117111011171111111711101117111111171110
002888220dddbd000333c300055585000eeeae000002222211000777770001101100077777000110110007777700011011000777770001101100077777000110
002888770dddbdd00333c330055585500eeeaee00002226611000171710001101100017171000110110001717100011011000171710001101100017171000110
002dddb2ddddddd03333333055555550eeeeeee00002223217017177717101701701717771710170170171777171017017017177717101701701717771710170
002d0022dddddddd3333333355555555eeeeeeee0002222277011711171107707701171117110770770117111711077077011711171107707701171117110770
002d0022007070000060600000d0d000007070000006002200001100011000000000110011000000000011000110000000000110011000000000110001100000
000d0022007070000060600000d0d000007070000006006200007100017000000000710017000000000071000170000000000710017000000000710001700000
000700700090900000d0d00000707000008080000006006000001700071000000000170071000000000017000710000000000170071000000000170007100000
007707700090900000d0d00000707000008080000055055000067760677600000006776677600000000677606776000000006777677600000006776067760000
11000000000000000000000000000011000011001000000000000000001100001111111121212121212111110000001111000000313100000000000000000011
11000000000000010100000000000011110000010000000000002100000051117200000000000000000000001112001111000000000000000000000000000011
11000000000000000000000000000011000011111111000000000000001100001111111111111111111111110000001111000000000000000000000000000011
11b3b3b3000000010100000000000011110003010000000000511141000051111100000000000000810000001100001111000000000000000000000000000011
11000000000000000000000012000011000011000001000000000002001100001111000000000000000000010000001111000000000000000000000000000011
11111111000200111100000000000011110000010000000000511141000051111100000011111111111111111111111111000000210000000000000000000011
11000002000000000000000000000011000011120001000000000011111100001111000000000000000000010000001111000000000000000000000000000011
11111111000000111100000000000011110081010000000000511141000051111100000011111111111111111111111111000000110000000081000000000011
1100000000000000000000000000001100001100000100000000001111110000111100000000b000000000010000001111000000000000000000000000000011
1111111100b100111100000000810011110111010000000000511141000051111100000000000000000000000000001111000000110000000011000000000011
11000000000000000000000000000011000011111111000000000011111100001111000000000000000051110002001111000000212100000021210000000011
11111111211121111100000021112111110000000002000000511141000051111100810000000000000000000000001111000200110000000000000000000011
11000000000000000000000000000011000011111111000000000011111100001111000000002100000000310000001111000000111100020011110000000011
11111111111111111100000011111111110000000000000000511141000051111101116262525262625252626200001111000000110000000000000000000011
11000000000000000000000000000011000011111111000000000011111100007292001200001100000000000000001111000000111100000011110012000011
11000000010000000000000011111111110000000000000000511141120051110001000000000000000000000000001111000000110000000000000000000011
110000001000008100000000000000110000111111110000b1000011111100007292000000001100b10000000081001111008100111100810011110000000011
110003000100100000008100111111111100000000b100000051114100005111030110000000000000000000000081111100b100110000000000001000810011
1111111111111111111111111111111100001111111121211121211111110000111111111111112111111111111121111121112111112111211111b3b3b3b311
11b3b3b3111111111111111111111111112121212111212121211111111111111111111111111111111111111111111111211121112121212121111111111111
11111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111000000
00111111111111111111111111111100111111111111111111111111111111111111111111111111111111111111111100000000111111111111111100000000
11000000000000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000011000000000000000011000000
0011000000c200000000c20000001100118300000001000001000000000063111100000000000051410000000000001100000000110000000000001100000000
11000000000000000000000000000011000000000000000000000000000000001111111111111111111111111111111100000011000000120000000011000000
0011000000c200000000c20000001100110000000001000001000000000000111100100000000051410000000012001100000000110000000000641100000000
1100000000000000000000000000001100000000000000000000000000000000111111111111000000c200000000001100000011000000000010d10011000000
0011000000c200020000c20063001100110000000001120001000000000000111111111100000051410000000000001100000000110000000011111100000000
1100000000000000000000000000001111111111111111111111111111111111111111111111000000c200000000001100000011000000111111111111000000
00110000001111111111112121211100115300000001000001000000000200111111111100000051410000000011111100000000111000d10011111100000000
1100000000000000000000000000001111000000c20000000051410000000011111111111111000200c200006300001100000011000000111111111111000000
0011000000c20000000011313131110011000000001111111100000011c2c2111111111100000051410000000011111100000000111100000011111100000000
1100000000000000000000000012001111000000c20000000051410000000011111111111111c2c2c211c2c2c2c2c21100000011000000111111111111000000
0011005300c200100000110000001100110000000000000011000000110000111111111100000051410002000011111100000000111100000011111100000000
1100100000000000020000000000001111000000c200000000514100120000111100000000c20000001100000000001100000011000200111111111111000000
00110000001111111111110000001100118100000000000011000000110000111111111100000051410000000011111100000000111100000011111100000000
1111110000000011110000000011111111001000c200000200514100000000111100000000c20000001100000000001100000011000000111111111111000000
00110000001100000000c20000001100111100000000000011000000110000111111111100000051410000000011111100000000111100000011111100000000
11111100000000111100000000111111111111111111111111111111111111111100000000c20000001100001200001100000011000000111111111111000000
00110003001100000000c20000001100111100000000000011000000110000111111111100000051410000000011111100000000111100000011111100000000
11111100000000111100000000111111000000000000000000000000000000001100100000c20053001100000000001100000011000000111111111111000000
00110000001100000000c200000011001111000000000000c2000000110000111111111100000051410000000011111100000000111100000011111100000000
11111100000000111100000000111111000000000000000000000000000000001111111111111111111111111111111100000011000000111111111111000000
00110000001100120000c200000011001111000000811000c200d100115303111111111100000051410000000011111100000000111100000011111100000000
11111100000000111100000000111111000000000000000000000000000000000000000000000000000000000000000000000011000000111111111111000000
00110000001100000000c20081001100111100b100111111110000001111111111111111000300514100b1000011111100000000111100b10011111100000000
11111121212121111121212121111111000000000000000000000000000000000000000000000000000000000000000000000011212121111111111111000000
00112121211111111111112111211100111121112111111111212121111111111111111121212111112111212111111100000000111121112111111100000000
00000000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
00000000001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
00000024344454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
00000065758595000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
0000007494a4b4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
000000c4d4e4f4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000010000000000000000064000000110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
71717171717171717171717171717171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000071717171717171717171717171717171
__gff__
0000000000000000000000000000000001010202020200010000000000000000000000000001010101010000010000000000000000000000000100020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111313131313131311111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1100000000000000000000000000001111000000000000111100000000000011110000000000000000000000000000111100000000000000000000000015111111131313131313110000000000000011110000000000000000000000000000111100000000111113131313131313131111000000000000000000000000000011
1100000000000000000000000000001111000000000000111100000000000011110000000000000000000000210000111100000000000000000000000000131111000000000000100000003000000011110000000000000000000000010000111100000000111100000000000000001111000000000000000000000001000011
1100000000000000000000000000001111000000000000111100002100000011110020000000000000000000000000111100010000121212120000000030001111000000000000100000001200000011110000000000000000000011110000111101000000111100000000000000001111000000001200000012000011000011
1100000020000000000000000000001111000020000000111100000000000011110010100000000000000000111100111111111111111111111111110000001111000000000000100000001114000011110000003000000000000000000000111110000000111100000011140000001111000000001100110011000000000011
1100001111110000000000000000001111000011110000111100001111000011110000000000000000000000000000111111140013130000000000000000001111000012120000111112121114000011110000000000000000000000000000111100000000111100000011000000001111000000001112111211121212121211
1100000000000000000000000000001111000000000000111100000000000011110000000000000000000000000000111113000000000000000000000000001111000011110000111111111114000011110000000000000000000000000000111100000000111100000011000000121111140000151111111111111111111111
1100000000000000000000000000001111000000000000111100000000000011110000000000000000000000000000111100000000000000000000000000001111000011110000131313131300000011110000000000000000000000000000111100000000131300000011000015111111000000001313131311131313131311
1100000000000000000000000000001111000000000000111100000000000011110000000000000000000000000000111100200000000000121212120000001111000011110000000000000000000011110000000000200000000000121212111100000000000000000011000000001111000000000000000011000000000011
1100000000000000000000000000001111000000000000111100000000000011110000000000000000000000000000111100001511111111111111111111111111000011110000000000002000000011110000000000000000000015111111111100000000000000000011000021001111000000000000000013000000000011
1100000000000000000000000000001111000000000000111100000000000011110000000000000000000000000100111100000000000000000000131300001111000011111010101010111110101011110000000000000000000015110000111100000000200000000011120000001111000000000000000000000000004611
1100000000000000000000002100001111000000000000000000000000000011110011110000000000000000101000111100000000000000000000000021001111210011110000000000000000000011110000000000000000000000102100111100000000000000000011110011111111000000001100000000000015111111
1100010000000000000000000000001111000100000000000000000000000011110000000000000000000000000000111100000000001212121200000000001111000111111212121212121212121211110000000000000000000000100000111112121212121212121211000000001111000000001100000000000000000011
1111111111111111111111111111111111111111111111111111111111111111111212121212121212121212121212111112121111111111111111111111111111111111111111111111111111111111111212121212121212121212111111111111111111111111111111121212121111121212121112121212121212121211
1111111111111111111111111111111100000000111111111111111100000000111111111111111111111111111111111111111111111111111111111111111111261111111126111111111111111111111111111111111126111111111111111126111111111111261111111111261111111111111111111111111111111111
1100000000000000000000000000001100000000110000000000001100000000110000000039000000002900000000151100000000000000000000000000001111000000000000101000000000000011110000000000000000000000000000111100000000100000000000000000100011000000000000000000000000000011
1100000000000000000000000000001100000000112100000000001100000000110000000039000000002900000000151100010000000000000000000000301111000000200000101000000000000011110000000000000000000000000000111100000000100000000000000000100027000000000000000000000000000011
1100000000000000000000000000001100000000110000000000001100000000110000000039000020002900000000151110101010111010100000000000281111000011110000111100000000000011110000000000000020000000000000111100002000100000001111000000103011000000000000000000000000004611
1100000000000020000000000000001100000000113939000000001100000000110000000039000000002900000000151100000000110000111400000000151111000000000000111100000000000011110000000000000000000000000000111100000000111100002729000000111111000000000000000000000015111111
1100000000000000000000000000001100000000110000000020001100000000113939391111292929291111393939111100002929112100111400000000151111000000000000111100000000000011111100002511111111111111250000111100001111112600002729000011111111000000000000000000000000000011
1100000000000000000000000000001100000000110000000029291100000000110000001111000000001111000000151100000000110000110000000000151111000011110000111100000000000011270000001100000000000000000000281100000000110000002729000000111111000000003939000000000000000011
1100000000000000000000000021001100000000110000000000001100000000110000001111000000001111000000151100200000111111110000000000151111000000000000111100000000000011110000001100112611112611111126111100000000110000111111000000111127000000000000000000000000000011
1100010000000000000000000000001100000000113939000000001100000000110000001111121212121111000000151100000000000000000000292900151111000000000000111100000000121211110000001100000000000000000000111100000000110000261111000000392811000000000000000000000000000011
1111110000000000000000001111111100000000110000000000001100000000112929291111111111111111292929111139390000000000000000000000151111000011110000111100000015111111110000111111111111111111111100111111110000110000001111110000392811000000000000000000000000292911
1100000000000000000000000000001100000000110000000029291100000000110000001111000029000000000000151100000000000000000000000000151111000000000000111100000000000011110000002800000000000000000000111114000000111100001010000000392811000000000000000000000000000011
1100000000000000000000000000001100000000110000000000001100000000110000001111210029000000000030151100000000000000000000000000151111000001000000111100000000210011110000001100210000000000000000111114000000000000001010002100111111000000000000003939000000000011
1100000000000000000000000000001100000000110000010000001100000000110001001111000029000000000000151100000000292900000000393900151111000011110000111100000000000011110001001100000000000000000000111114000000000000001010000100111111010000000000000000000000000011
1112121212121212121212121212121100000000111111111111111100000000111111111111111111121212111111111112121212121212121212121212111111121211111212111112121212111111111111111111111111252525111111111111111125111111111111111111111111111112121212121212121212121211
1111111111111111111111111111111100001111111111111111111111110000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000015111111111111111111111111111111111111111111111111111111111111111111
1100000000000000000000000000001100001100000000000000000000110000110000000000000000000000000000111100000000000000000000000000001111000000000000000000000000000011110001000000000000000000000015111100000000000000000000000000001111000000000000000000000010000011
11000000000000000000000000000011000011000000000000000000001100001100010b0000000000000000000000111100000000000000000000000000011111000000000000000000000000000011111010100000000000000000000015111100000020000000000000000000001111000000000000000000000010004611
1100000000000000000000000000001100001100000000000000000000110000111111113939393939391111000000111100000011113b3b3b3b3b3b111111111121000000000011111111110000001111000010000000000000000000001511111011111111110000003b3b3b00001111000000000000000000001511111111
__sfx__
010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c62100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
010800002a5502f550335501850000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
011000000c43600406004060040600406004060040600406004060040600406004060040600406004060040600406004060040600406004060040600406004060040600406004060040600406004060040600406
010800000035100353003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303
010c00001c155181551c1551f15500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
01100000181511815124151241510c151000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
011000000c05500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
011800003005500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
010600000c0550c0550c0550c05500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000100000e7521475218755177521675213752117520d752087520475202752027520075202752017520175201752017520175201752017520175200752007520075200752007520075200752007520075200702
011000001525500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205
010c00003054300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
0101000010773117731177313773157731a7731c7731c7731c7731170313703237031d7030f7030c7030870306703067030470303703037030070300703007030070300703007030070300000000000000000000
010200001842010400154001b40021400004002a4000040031400394003b400004003940034400004002d400254003a4001d40017400114000540000400004000040000400004000040000400004000040000000
0102000026751267511f7511f751207511d7511b751187510c75103751007510a75108751007511670113701107010c7010870105701037010270102701017010070100701007010070100701007010070100701
0128002029765267652b765267652d76528765287652f7652d765297652d76526765287652476528765297652876529765267652b7652f765287652f7652b765297652976526765297652876524765287652d765
01140010000000e0000c63500605006050c635006050c63500605006050c6350060500605006050c6350060500605006050060500605006050060500605006050060500605006050060500605006050060500605
012800200e0550e055000000000000000000000e055000000000000000000000000000000000000a000000000c0550c055000000a0000a0000b0000b05500000000000000000000000000a0550a0550800009055
011000040c05010050130501805000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000012475224702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702
01100004180501c0501f0502405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00200556500635246350256207565006352463502562095620456524635045620b56209565246350556209565006352463502562045650063524635005620456500635246350556204562055620256207562
01100003185201f520245200050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
012000080c05000000000000c050000000d0500e0500f050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000100c6230060300603006033062300603006030c6230c603006030c623006033062300603306230060300603006030060300603006030060300603006030060300603006030060300603006030060300603
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003062300000306230000030623306233062330623
01100000000000000000000000000000000000300653006530005300653006530005180621806518062180651800518005180001800018000180003006530065300053006530065300052b0622b0622a0622a065
01100000000000000100001000010000100001300622f062300622f062300622f062300622f062300622f062300622f06223000000010000100001300622f062300622f0623000024001300622f0623406134065
011000000000000000000000000000000000002e062240002e062240002e062240002e062240002e062240002e0652e0002e06530061300613006130061300650000000000000000000000000000000000000000
01100000000020000200002000020000200002280622806529062290652b0622b065280622806529062290652b0622b0652806228065290622906530062300623006230062300623006500005000050000200002
0120000000055040550705500055040550705500055040550705500055040550c0520c0520c0550c0520e0520e0520c0520e05210052100521005210052100521005210052100521005210052100522b00510055
012000000005504055070550005504055070550005504055070550005504055180521805218055180521a0521a052180521a0521c0521c0521c0521c0521c0521c0521c0521c0521c0521c0521c0521f0051c055
012000000005504055070550005504055070550005504055070550005504055240522405224055240522605226052240522605228052280522805228052280522805228052280522805228052280522b00528055
011e002000565025650256504565055650063524635095650e56524635246350556504565025652463505565075650956524635095650e5651056500635246350256507565075650456505565055650456505565
011c00200455505555095550c555186350255505555025550c55502555105551863505555025550b555025550e555105551863502555005550c55502555045550c55500635246350955504555025550b55509555
011c00200055502555055550b555045550c5552463502555055550455500555246352463502555045550455502555025550255504555045550255500555246352463504555055551055507635045550755505555
011c00010005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 11 42 12 44
03 11 10 12 44
02 13 42 43 44
03 13 14 15 44
03 16 42 43 44
00 17 42 43 44
00 17 18 1a 44
00 17 18 19 44
00 17 18 19 1b
00 17 18 19 1b
01 17 18 19 1b
00 17 18 19 1b
00 17 18 19 1c
00 17 18 19 1d
00 17 18 19 1b
00 17 18 19 1b
00 17 18 19 1e
02 17 18 19 1d
04 1f 20 21 44
03 16 42 43 44
03 22 42 43 44
03 23 42 43 44
03 24 42 43 44
03 25 42 43 44
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
00 41 00 00 00
00 00 00 00 00
00 00 00 00 44
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
