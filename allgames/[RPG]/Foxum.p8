pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--foxum
--by jeffpack

function _init()
 zeroxy={0,0}
 omap={
  ["bat"]={bat,0},
  ["bee"]={bee,0},
  ["can"]={cannon,4},
 	["d"]={door,10},
  ["ftn"]={fountain,2},
  ["gem"]={gempile,5},
  ["gst"]={ghost,0},
		["key"]={key,4},
		["liz"]={lizard,0},
  ["mat"]={merch_attack,2},
  ["mhl"]={merch_health,2},
  ["msp"]={merch_speed,2},
		["p"]={portal,1},
		["sco"]={scorpion,0},
		["shr"]={shroom,0},
		["ske"]={skeleton,0},
		["slm"]={slime,0},
		["sls"]={slime_small,0},
		["snk"]={snake,0},
		["snb"]={snow_beast,0},
		["sdr"]={spider,0},
		["spk"]={spikes,3},
		["t"]={torch,2},
		["war"]={make_warp,13},
		["wol"]={wolf,0},
		["zar"]={zard,0},
 }
 speed_prices={50,125,200,275}
 attack_prices={50,125,200,275,350,425,500}
 health_prices={50,125,200,275,350,425,500,575,650}
 dir_u,dir_r,dir_d,dir_l=1,2,3,4
 idle,moving,shooting=1,2,3
 init_anims()
 init_rooms()
 home=make_warp({0,0,0,0,0,0,6,3,60,68,dir_u,false,"home"})
 color_fade={0,0,1,5,5,1,5,6,2,4,9,3,1,1,2,4}
 init_title_screen() 
end

function start_game()
 make_player()
 make_xhint()
 roomlvl,roomx,roomy=0,6,3
 load_room()
 hud={}
 hud.gems=p.gems 
 c_trans,c_death,c_power_attack=nil,nil,nil
 portal=nil
 warp=nil
 update_function,draw_function=update_main,draw_main
 start_time=time()
 monsters_killed,deaths,gems_collected=0,0,0
 play_spike=false
end

function _update()
 update_function()
end

function _draw()
 draw_function()
end

function update_main()
 update_hud()
 if (c_trans and costatus(c_trans)!="dead") then
  coresume(c_trans)
 elseif (c_power_attack and costatus(c_power_attack)!="dead") then
  coresume(c_power_attack)
 else
  c_trans,c_power_attack=nil,nil
  if (c_death and costatus(c_death)!="dead") coresume(c_death)
  update_room()
	 for obj in all(objects) do
   obj.update(obj)
	 end
 end
 if play_spike then
  sfx(59)
  play_spike=false
 end
end

function update_hud()
 if (hud.gems>p.gems) hud.gems-=1
 if (hud.gems<p.gems) hud.gems+=1
end

function update_arrow(arr)
 arr.x+=arr.dx
 arr.y+=arr.dy
 if arr.x<-8 or arr.y<8 or arr.x>136 or arr.y>136 then
  del(objects, arr)
 end
 if arr.x>0 and arr.x+7<127 and arr.y>15 and arr.y+7<127 then
   if (check_solid_collide(arr.x,arr.y,1,1)) del(objects,arr)
 end
 for obj in all(objects) do
  if (obj.tag=="enemy") then
	  if (check_collide(arr.x,arr.y,1,1,obj.x,obj.y,obj.w,obj.h)) then
	   sfx(6)
	   local attack = p.atk
	   if (arr.power) attack+=flr(attack*0.5)
	   if (obj.hit(obj,attack)) del(objects, arr)
	   break
	  end
	 end
 end
end

function update_interact(i)
 local t=i.check1
 i.check1=false
 if i.hidden then
 	for o in all(objects) do
 	 if (o.tag=="enemy") return
 	end
 	i.hidden=false
 	if (not(t)) sfx(17)
 	if (i.tag) then
  	for o in all(room.objects) do
  	 if (i.tag==o.tag) then 
  	  o.hidden=false
  	  break
  	 end
  	end
  end
 end
 if (not(p.dead) and check_collide(p.x,p.y,p.w,p.h,i.x,i.y,i.w,i.h)) then
		i.interact(i)   
 end
 if (i.frame) update_frame(i)
end

function draw_main()
 if (c_trans or c_power_attack) return
 cls()
 draw_room()
 for obj in all(objects) do
  if (obj.bg) obj.draw(obj)
 end
 for obj in all(objects) do
  if (not(obj.bg) and not(obj.effect)) obj.draw(obj)
 end
 for obj in all(objects) do
  if (obj.effect) obj.draw(obj)
 end
 draw_hud()
end

function draw_image(obj)
 if (obj.hidden) return
 spr(obj.sprite,obj.x,obj.y,obj.w,obj.h,false,false)
end

function draw_sprite(obj)
 if (obj.hidden) return
 local frame,rendx,rendy=obj.anim[obj.frame],flr(obj.x+0.5),flr(obj.y+0.5)
 local img=frame[sprite]
 spr(img,rendx,rendy,obj.w,obj.h,frame[flipx],frame[flipy])
 check_flash(obj,frame,img,rendx,rendy)
end

function draw_arrow(arr)
 draw_sprite(arr)
 local rendx,rendy=flr(arr.x+0.5),flr(arr.y+0.5)
 if arr.power then
  if (arr.dx>0) line(rendx+1,rendy+3,rendx-8,rendy+3,12)
  if (arr.dx<0) line(rendx+6,rendy+3,rendx+16,rendy+3,12)
  if (arr.dy<0) line(rendx+3,rendy+6,rendx+3,rendy+16,12)
  if (arr.dy>0) line(rendx+3,rendy+1,rendx+3,rendy-8,12)
 end
end

function check_flash(obj,frame,img,rendx,rendy)
 if obj.flash then
  if obj.flash_tick%4>1 then
   local sheetx=(img%16)*8
   local sheety=(flr(img/16))*8
   local locx,locy=0,0
   for x=0,(obj.w*8)-1 do
    for y=0,(obj.h*8)-1 do
     if (sget(sheetx+x,sheety+y)>0) then
      if frame[flipx] then
       pset(rendx+abs(x-(obj.w*8)+1),rendy+y,obj.flash_color)
      else
       pset(rendx+x,rendy+y,obj.flash_color)
      end      
     end
    end
   end
  end
  obj.flash_tick+=1
  if (obj.flash_tick>=16) obj.flash=false
 end
end

function draw_hud()
 rectfill(0,0,127,15,0)
 for i=1,p.mhp do
  local y=0
  if (i>5) y=8
  if (p.hp>=i) then
   spr(16,(8*i-8)%40,y)
  else
   spr(36,(8*i-8)%40,y)
  end
 end
 spr(37,80,0)
 print(p.atk,90,1,7)
 spr(19,80,8)
 print((p.speed-0.75)/0.25,90,9,7)
 rectfill(56,0,71,15,1)
 rectfill(57,1,70,3,7)
 rectfill(60,4,70,11,11)
 rectfill(62,1,63,7,13)
 rectfill(57,4,61,7,4)
 rectfill(57,8,59,14,3)
 rectfill(60,10,61,14,3) 
 rectfill(62,12,63,14,3)
 rectfill(64,10,70,14,15)
 rectfill(68,12,70,14,9)
 rectfill(68,6,69,7,12)
 local co1,co2=56+(roomx*2),roomy*2
 rectfill(co1,co2,co1+1,co2+1,8)
 spr(32,104,0)
 local gemstr=""
 if (hud.gems<1000) gemstr=gemstr.."0"
 if (hud.gems<100) gemstr=gemstr.."0"
 if (hud.gems<10) gemstr=gemstr.."0"
 gemstr=gemstr..tostring(hud.gems)
 print(gemstr,112,1,7)
 spr(38,104,8)
 print(p.keys,112,9,7)
end

function get_dir(dx,dy,cur_dir)
 if (cur_dir==dir_u and dy<0) return dir_u
 if (cur_dir==dir_d and dy>0) return dir_d
 if (cur_dir==dir_l and dx<0) return dir_l
 if (cur_dir==dir_r and dx>0) return dir_r
 if (dx>0) return dir_r
 if (dx<0) return dir_l
 if (dy>0) return dir_d
 if (dy<0) return dir_u
end

function new(obj)
 local new={}
 for key, value in pairs(obj) do
   new[key] = value
 end
 return new
end

function get_projectile_vector(obj,speed)
 local angle=atan2(obj.dx,obj.dy)
 obj.dx,obj.dy=cos(angle)*speed,sin(angle)*speed 
end

function collide_solids(obj)
	while(not(obj.dx==0) and check_solid_collide(obj.x+obj.dx,obj.y,obj.w,obj.h)) do
		if(obj.dx>0) then
		 obj.dx-=0.25
		else
		 obj.dx+=0.25
		end
 end
 obj.x+=obj.dx
 while(not(obj.dy==0) and check_solid_collide(obj.x,obj.y+obj.dy,obj.w,obj.h)) do
  if (obj.dy>0) then
   obj.dy-=0.25
  else
   obj.dy+=0.25
  end
 end
 obj.y+=obj.dy
end

function check_solid_collide(x,y,w,h)
 x,y=flr(x),flr(y)
 local x1,x2,y1,y2=flr(x/8),flr((x+7)/8),flr(y/8)-2,flr((y+7)/8)-2
 local coords={{x1,y1},{x2,y1},{x1,y2},{x2,y2}}
 for i=1,4 do
  if coords[i][1]>=0 and coords[i][1]<=15 and coords[i][2]>=0 and coords[i][2]<=13 then
   local tilex,tiley=room.map[1]+(coords[i][1]),room.map[2]+(coords[i][2])
   if (fget(mget(tilex,tiley),0)) return true
  end
 end 
 for sol in all(room.solid) do
  if (check_collide(x,y,w,h,sol[2],sol[3],sol[4],sol[5])) return true
 end
 return false
end

function check_collide(x,y,w,h,x1,y1,w1,h1)
 return (x<(x1+w1*8) and (x+w*8)>x1 and y<(y1+h1*8) and (y+h*8)>y1)
end

function warp_collide(w)
 warp,c_trans=w,cocreate(warp_to_room)
end

function update_frame(obj)	 
 if (not (obj.ftime)) return
 if (obj.ftime>0) then
	 obj.ftime-=1
	end
	if (obj.ftime==0) then
	 if (#obj.anim > obj.frame) then
  	obj.frame+=1
  else
   if (obj.end_of_anim) obj.end_of_anim(obj)
   obj.frame=1
  end
  obj.ftime=obj.anim[obj.frame][ftime]
 end
end
-->8
function make_player()
 p={}
 p.dead,p.state,p.flash,p.dir,p.webbed,p.web_time=false,idle,false,dir_d,false,0
 p.x,p.y,p.dx,p.dy,p.h,p.w,p.frame=60,68,0,0,1,1,1
 p.anims=anims.p
 p.anim=p.anims[p.state][p.dir]
 p.ftime=p.anim[p.frame][ftime]
 p.attacktimer,p.holdtimer=0,0
 p.speed,p.atk,p.hp,p.mhp=1,1,3,3
 p.gems,p.keys,p.playing_charge,p.playing_danger,p.lock_dir=0,0,false,false,p.dir
 p.update,p.draw,p.kill=update_player,draw_player,player_kill
end

function update_player(obj)
 p.dx,p.dy=0,0
 local switch_anim=false
 
 if p.hp==1 and not p.playing_danger then
  sfx(14)
  p.playing_danger=true
 elseif p.hp>1 and p.playing_danger then
  sfx(14,-2)
  p.playing_danger=false
 end
 
 if p.webbed then
 
  stop_charging_sounds()
  check_move_input(p.speed*0.25)
  if (btnp(—)) p.web_time-=10
  p.web_time-=1
  if p.web_time<0 then 
   p.webbed=false
  else
   xhint.active=true
  end
 	collide_solids(p)
  switch_anim=update_player_anim()  
  
 elseif btn(Ž) and p.attacktimer==0 then
 
  if (not (p.state==shooting)) switch_anim=true
  p.state,p.lock_dir=shooting,p.dir
  p.holdtimer+=1
  if (p.holdtimer==41) stop_charging_sounds()
  if p.holdtimer>40 and not p.playing_charge then
   sfx(2)
   p.playing_charge=true
  elseif p.holdtimer>15 and not p.playing_charge then
   sfx(1)
   p.playing_charge=true
  end
  check_move_input(p.speed*0.75)
  collide_solids(p)
  
 else
 
  if (p.state==shooting) then
   stop_charging_sounds()
   if (p.holdtimer>40) then
    sfx(4)
    c_power_attack=cocreate(power_shot)
   else
    player_shoot(p.lock_dir,p.holdtimer)
   end
   p.attacktimer,p.holdtimer=10,0
  end
  if (p.attacktimer>0) p.attacktimer-=1 
  check_move_input(p.speed) 
 	collide_solids(p)
  switch_anim=update_player_anim()
  
 end
 
 if (switch_anim) then
  p.anim,p.frame=p.anims[p.state][p.dir],1
 	p.ftime=p.anim[p.frame][ftime]
	end
	
 update_frame(p) 
end

function stop_charging_sounds()
 sfx(1,-2)
 sfx(2,-2)
 p.playing_charge=false
end

function check_move_input(speed)
 if (btn(”)) p.dy=-speed
 if (btn(ƒ)) p.dy=speed
 if (btn(‹)) p.dx=-speed
 if (btn(‘)) p.dx=speed
end

function update_player_anim()
 local switch_anim=false
 if (not (p.dx==0 and p.dy==0)) then
  if (not (p.state==moving))	switch_anim=true
  p.state=moving
  local new_dir=get_dir(p.dx,p.dy,p.dir)
  if (not (p.dir==new_dir)) switch_anim=true
  p.dir=new_dir
 else
  if (not (p.state==idle)) switch_anim=true
  p.state=idle
 end
 return switch_anim
end

function player_shoot(direction,holdtimer)
 local a={}
 a.x,a.y,a.dx,a.dy,a.w,a.h,a.anim,a.frame,a.update,a.draw=p.x,p.y,0,0,1,1,anims.arrow[direction],1,update_arrow,draw_arrow
 a.ftime=a.anim[a.frame][ftime]
 if holdtimer>18 then
  stop_charging_sounds()
  sfx(3)
  a.power,a.speed=true,5
 else
  a.speed=3
  sfx(0)
 end
 if (direction==dir_u) then
  a.y,a.dy=p.y-8,-a.speed
 elseif (direction==dir_d) then
  a.y,a.dy=p.y+8,a.speed
 elseif (direction==dir_r) then
  a.x,a.dx=p.x+8,a.speed
 elseif (direction==dir_l) then
  a.x,a.dx=p.x-8,-a.speed
 end
 add(objects,a)
end

function draw_player(obj)
 draw_sprite(p)
 local rendx,rendy=flr(p.x+0.5),flr(p.y+0.5)
 if (p.webbed) spr(60,rendx,rendy+2)
 if (p.holdtimer>18) then
  local yoffset=0
  if (p.holdtimer>52) then 
   yoffset=((p.holdtimer-41)%6)
  else 
   yoffset=((p.holdtimer-19)%12)/2
  end
  spr(20,rendx,rendy-yoffset,1,1,false,false)
 end
end

function player_kill(obj)
 music(-1)
 rmusic=-1
 deaths+=1
 stop_charging_sounds()
 sfx(14,-2)
 p.playing_danger=false
 if (lootsack_room) delete_lootsack()
 lootsack_room=get_room_name()
 local loot=lootsack(p.x,p.y,p.gems)
 add(room.objects,loot)
 e=explosion(obj.x,obj.y,reward_drop,{loot})
 add(objects,e)
 del(objects,p)
 p.dead,p.webbed,p.gems,hud.gems=true,false,0,0
 c_death=cocreate(player_death)
end

function player_death()
 for i=0,100 do
  yield()
 end
 warp=home
 if (portal) warp=portal
 c_trans=cocreate(warp_to_room)
 while (c_trans and costatus(c_trans)!="dead") yield()
 p.dead,p.hp=false,p.mhp
end

function power_shot()
 for x=0,127 do
  for y=16,127 do
   pset(x,y,color_fade[pget(x,y)+1])
  end
 end
 yield()
 local x,y,col_info,trans_point,inc=0,0,{},0,0
 if p.lock_dir==dir_u then
  x,y,inc=p.x,p.y-8,-1
  col_info=get_col_point(y,x,0,inc,true)
  x,y=x+3,p.y
  trans_point=y
 elseif p.lock_dir==dir_d then
  x,y,inc=p.x,p.y+8,1
  col_info=get_col_point(y,x,127,inc,true)
  x=x+3
  trans_point=y
 elseif p.lock_dir==dir_l then
  x,y,inc=p.x-8,p.y,-1
  col_info=get_col_point(x,y,0,inc,false)
  x,y=p.x,y+3
  trans_point=x
 else
  x,y,inc=p.x+8,p.y,1
  col_info=get_col_point(x,y,127,1,false)
  y=y+3
  trans_point=x
 end
 local step_count=0
 for i=trans_point,col_info[1],inc do
  step_count+=1
  if p.lock_dir==dir_u or p.lock_dir==dir_d then
   pset(x,i,12)
  else
   pset(i,y,12)
  end
  if (step_count%10==0) yield()
 end
 yield()
 if (col_info[2]) col_info[2].hit(col_info[2],p.atk*2,true)
end

function get_col_point(move_point,fix_point,end_axis,increment,switch)
 local collision_point,enemy=0,nil
 for col_point=move_point,end_axis,increment do
  collision_point=col_point
  local x,y=col_point,fix_point
  if (switch) x,y=fix_point,col_point
  if (check_solid_collide(x,y,1,1)) break
  local col=false
  for obj in all(objects) do
   if (obj.tag=="enemy") then
    if check_collide(x,y,1,1,obj.x,obj.y,obj.w,obj.h) then
     enemy=obj
     col=true
     break
    end
   end
  end
  if (col) then
   break
  end
 end
 return {collision_point, enemy}
end
-->8
function get_room_name()
 return "lvl"..tostring(roomlvl).."x"..tostring(roomx).."y"..tostring(roomy)
end

function update_room()
 if (p.x<0) then
  roomx-=1
  p.x=119
  load_room()
 elseif (p.x>120) then
  roomx+=1
  p.x=1
  load_room()
 elseif (p.y<16) then
  roomy-=1
  p.y=119
  load_room()
 elseif (p.y>120) then
  roomy+=1
  p.y=17
  load_room()
 end
end

function check_room_clear()
 if roomlvl!=0 then
  for obj in all(objects) do
   if (obj.tag=="enemy") return
  end
  room.cleared=true
  if roomlvl==3 and roomx==3 and roomy==0 then
   music(7,500)
  	update_function,draw_function=update_end,draw_end
  end
 end
end

function load_room()
 room=rooms[get_room_name()]
 if room.music then
  if room.music!=rmusic then
   rmusic=room.music
   music(-1)
   music(room.music,1000)
  end
 else
  music(-1)
 end
 objects={xhint, p}
 if room.objects then
  for obj in all(room.objects) do
   if obj.tag!="enemy" or not room.cleared then
    new_obj = new(obj)
    add(objects,new_obj)
    if (new_obj.awake) new_obj.awake(new_obj)
   end
  end
 end
end

function draw_room()
 map(room.map[1],room.map[2],0,16,16,14)
 for sol in all(room.solid) do
  spr(sol[1],sol[2],sol[3],sol[4],sol[5],sol[6],sol[7])
 end
end

function warp_to_room()
 for i=1,50 do
  if i<16 and i%3==0 then
   for x=0,127 do
    for y=16,127 do
     pset(x,y,color_fade[pget(x,y)+1])
    end
   end
  end
  yield()
 end
 roomlvl=warp.roomlvl
 roomx=warp.roomx
 roomy=warp.roomy
 p.x=warp.px
 p.y=warp.py
 p.dir=warp.pdir
 load_room()
end

function delete_lootsack()
 room_objects=rooms[lootsack_room].objects
 for object in all(room_objects) do
  if (object.tag=="lootsack") del(room_objects,object)
 end
 lootsack_room=nil
end

function init_rooms()
 local rooms_string=[[
lvl0x0y0,32,28,3,s,98,56,16,1,1,s,98,64,16,1,1,s,98,0,64,1,1,s,98,0,72,1,1,e,2,wol,e,1,snb,%,
lvl0x1y0,16,28,3,s,98,56,16,1,1,s,98,64,16,1,1,s,98,56,120,1,1,s,98,64,120,1,1,e,3,wol,%,
lvl0x2y0,32,28,3,s,98,56,16,1,1,s,98,64,16,1,1,s,98,120,64,1,1,s,98,120,72,1,1,e,2,wol,%,
lvl0x4y0,48,0,3,s,100,0,64,2,2,s,100,48,16,2,2,s,100,64,16,2,2,e,3,wol,%,
lvl0x5y0,64,0,3,s,100,48,16,2,2,s,100,64,16,2,2,s,100,48,112,2,2,s,100,64,112,2,2,e,1,wol,%,
lvl0x6y0,48,0,3,s,100,48,16,2,2,s,100,64,16,2,2,e,1,wol,%,
lvl0x7y0,64,0,3,s,100,112,64,2,2,s,100,48,16,2,2,s,100,64,16,2,2,s,100,48,112,2,2,s,100,64,112,2,2,o,war,194,56,64,2,2,-1,7,0,56,96,1,true,wl0x7y0,e,1,wol,%,
lvl0x0y1,16,28,3,s,98,0,64,1,1,s,98,0,72,1,1,s,98,120,64,1,1,s,98,120,72,1,1,e,2,snb,%,
lvl0x1y1,32,28,3,s,98,56,16,1,1,s,98,64,16,1,1,s,98,56,120,1,1,s,98,64,120,1,1,s,98,0,64,1,1,s,98,0,72,1,1,o,war,194,56,24,2,2,-1,1,1,56,96,1,true,wl0x1y1,e,2,snb,%,
lvl0x2y1,16,28,3,s,98,120,64,1,1,s,98,120,72,1,1,%,
lvl0x4y1,48,0,3,s,100,0,64,2,2,s,100,112,64,2,2,s,100,48,112,2,2,s,100,64,112,2,2,s,122,80,40,1,1,s,122,80,48,1,1,e,2,wol,o,war,202,88,40,2,2,-1,4,1,96,96,1,f,wl0x4y1,%,
lvl0x5y1,48,0,3,s,100,0,64,2,2,s,100,48,16,2,2,s,100,64,16,2,2,%,
lvl0x6y1,64,0,3,s,100,48,112,2,2,s,100,64,112,2,2,e,2,wol,%,
lvl0x7y1,80,0,3,s,100,112,64,2,2,s,100,48,16,2,2,s,100,64,16,2,2,o,p,false,%,
lvl0x0y2,16,14,3,s,66,0,64,1,1,s,66,0,72,1,1,s,66,120,64,1,1,s,66,120,72,1,1,s,66,56,120,1,1,s,66,64,120,1,1,s,66,112,32,1,1,s,66,112,40,1,1,s,66,112,48,1,1,o,war,198,96,40,2,2,-1,0,2,96,96,1,f,wl0x4y1,e,1,liz,%,
lvl0x1y2,32,14,3,s,66,0,64,1,1,s,66,0,72,1,1,s,66,56,16,1,1,s,66,64,16,1,1,o,war,194,56,32,2,2,-1,1,2,56,96,1,true,wl0x1y2,e,1,sco,e,1,liz,%,
lvl0x2y2,16,14,3,s,66,120,64,1,1,s,66,120,72,1,1,s,66,56,120,1,1,s,66,64,120,1,1,s,224,56,72,2,1,o,ftn,56,64,%,
lvl0x4y2,0,0,3,s,68,48,16,2,2,s,68,64,16,2,2,s,68,0,64,2,2,o,war,194,16,64,2,2,-1,4,2,56,96,1,true,wl0x4y2,e,1,snk,e,2,bee,%,
lvl0x5y2,64,28,3,e,2,bee,%,
lvl0x6y2,0,0,3,s,68,48,16,2,2,s,68,64,16,2,2,s,68,48,112,2,2,s,68,64,112,2,2,s,224,56,72,2,1,o,ftn,56,64,%,
lvl0x7y2,64,28,3,s,68,112,64,2,2,e,3,bee,%,
lvl0x0y3,32,14,3,s,66,0,64,1,1,s,66,0,72,1,1,s,66,56,16,1,1,s,66,64,16,1,1,e,2,sco,e,1,liz,%,
lvl0x1y3,16,14,3,s,66,56,120,1,1,s,66,64,120,1,1,e,2,sco,%,
lvl0x2y3,32,14,3,s,66,56,16,1,1,s,66,64,16,1,1,s,66,120,64,1,1,s,66,120,72,1,1,o,p,f,%,
lvl0x3y3,32,0,32,s,105,56,16,1,1,s,105,64,16,1,1,s,72,56,24,1,1,s,72,64,24,1,1,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,32,24,o,t,64,24,o,t,96,24,o,p,f,o,war,88,60,40,1,1,1,3,3,60,96,1,f,wl0x3y3-1,o,war,127,60,124,1,1,0,3,4,60,32,3,f,wl0x3y3-2,%,
lvl0x4y3,0,14,3,s,67,0,64,1,1,s,67,0,72,1,1,s,67,120,64,1,1,s,67,120,72,1,1,e,2,snk,e,1,bee,%,
lvl0x5y3,0,14,3,s,67,0,64,1,1,s,67,0,72,1,1,o,gem,50,56,25,g0x5y3-1,true,o,gem,64,64,25,g0x5y3-2,true,e,1,bee,%,
lvl0x6y3,0,0,3,s,68,56,16,2,2,s,68,56,112,2,2,s,68,112,64,2,2,o,p,true,o,war,194,56,32,2,2,-1,6,3,56,96,1,f,wl0x6y3,%,
lvl0x7y3,0,0,3,s,68,0,64,2,2,s,68,112,64,2,2,o,war,194,96,64,2,2,-1,7,3,56,96,1,true,wl0x7y3,e,1,snk,e,2,bee,%,
lvl0x0y4,48,14,3,s,102,0,64,2,2,e,2,shr,%,
lvl0x1y4,64,14,3,s,102,48,16,2,2,s,102,64,16,2,2,%,
lvl0x2y4,0,0,3,s,68,48,112,2,2,s,68,64,112,2,2,o,war,194,56,96,2,2,-1,2,4,56,96,1,true,wl0x2y4,e,1,snk,e,2,bee,%,
lvl0x3y4,0,28,3,o,d,56,24,d0x3y4,0,3,3,60,112,1,w0x3y4,%,
lvl0x4y4,48,28,3,s,67,56,120,1,1,s,67,64,120,1,1,e,2,bee,e,1,snk,%,
lvl0x5y4,0,14,3,s,67,56,120,1,1,s,67,64,120,1,1,e,2,bee,%,
lvl0x6y4,48,28,3,s,67,56,120,1,1,s,67,64,120,1,1,s,67,56,16,1,1,s,67,64,16,1,1,s,67,120,64,1,1,s,67,120,72,1,1,e,4,bee,e,2,snk,o,gem,64,64,50,gx6y4,true,%,
lvl0x7y4,64,28,3,s,68,0,64,2,2,s,68,112,64,2,2,e,4,bee,%,
lvl0x0y5,64,14,3,s,102,0,64,2,2,s,102,112,64,2,2,s,102,48,112,2,2,s,102,64,112,2,2,e,1,shr,%,
lvl0x1y5,48,14,3,s,102,0,64,2,2,o,p,f,%,
lvl0x2y5,64,14,3,s,102,48,16,2,2,s,102,64,16,2,2,s,102,48,112,2,2,s,102,64,112,2,2,%,
lvl0x3y5,64,28,3,s,68,48,112,2,2,s,68,64,112,2,2,s,224,56,64,2,1,o,ftn,56,56,%,
lvl0x4y5,112,0,3,s,70,48,16,2,2,s,70,64,16,2,2,%,
lvl0x5y5,96,0,3,s,70,48,16,2,2,s,70,64,16,2,2,o,p,f,%,
lvl0x6y5,96,0,3,s,70,48,16,2,2,s,70,64,16,2,2,s,70,48,112,2,2,s,70,64,112,2,2,e,2,ske,%,
lvl0x7y5,112,0,3,s,70,112,64,2,2,s,70,48,112,2,2,s,70,64,112,2,2,%,
lvl0x0y6,48,14,3,s,102,48,16,2,2,s,102,64,16,2,2,s,102,48,112,2,2,s,102,64,112,2,2,s,102,0,64,2,2,o,war,194,56,64,2,2,-1,0,6,56,96,1,true,wl0x0y6,e,1,sdr,%,
lvl0x1y6,64,14,3,s,102,48,112,2,2,s,102,64,112,2,2,e,1,shr,%,
lvl0x2y6,48,14,3,s,102,48,16,2,2,s,102,64,16,2,2,s,224,56,72,2,1,o,ftn,56,64,%,
lvl0x3y6,64,14,3,s,102,48,16,2,2,s,102,64,16,2,2,s,102,48,112,2,2,s,102,64,112,2,2,s,102,112,64,2,2,o,war,194,56,32,2,2,-1,3,6,56,96,1,true,wl0x3y6,e,2,shr,%,
lvl0x4y6,112,0,3,s,70,0,64,2,2,e,2,snk,%,
lvl0x5y6,96,0,3,s,224,56,72,2,1,o,ftn,56,64,%,
lvl0x6y6,80,14,3,s,70,56,16,2,2,e,2,ske,%,
lvl0x7y6,80,14,3,s,107,56,16,1,1,s,107,64,16,1,1,s,107,120,64,1,1,s,107,120,72,1,1,e,1,gst,%,
lvl0x0y7,64,14,3,s,102,48,16,2,2,s,102,64,16,2,2,s,102,0,64,2,2,s,102,48,112,2,2,s,102,64,112,2,2,e,1,sdr,%,
lvl0x1y7,48,14,3,s,102,48,16,2,2,s,102,64,16,2,2,s,102,48,112,2,2,s,102,64,112,2,2,e,3,shr,%,
lvl0x2y7,64,14,3,s,102,48,112,2,2,s,102,64,112,2,2,e,1,shr,%,
lvl0x3y7,48,14,3,s,102,48,16,2,2,s,102,64,16,2,2,s,102,112,64,2,2,s,102,48,112,2,2,s,102,64,112,2,2,s,102,40,32,2,2,s,102,72,32,2,2,s,113,32,32,1,1,s,113,88,32,1,1,o,war,200,56,32,2,2,-1,3,7,96,96,1,f,wl0x3y7,%,
lvl0x4y7,112,0,3,s,70,0,64,2,2,s,70,48,112,2,2,s,70,64,112,2,2,o,war,194,16,64,2,2,-1,4,7,56,96,1,true,wl0x4y7,e,1,ske,%,
lvl0x5y7,112,0,3,s,70,112,64,2,2,s,70,48,112,2,2,s,70,64,112,2,2,e,2,snk,%,
lvl0x6y7,80,14,3,s,70,0,64,2,2,s,107,56,120,1,1,s,107,64,120,1,1,o,war,194,56,64,2,2,-1,6,7,56,96,1,true,wl0x6y7,e,1,ske,e,1,gst,%,
lvl0x7y7,80,14,3,s,70,104,48,2,2,s,107,104,40,1,1,s,107,112,40,1,1,s,107,120,64,1,1,s,107,120,72,1,1,s,107,96,72,1,1,s,107,96,64,1,1,s,70,48,112,2,2,s,70,64,112,2,2,o,war,196,104,64,2,2,-1,7,7,96,96,1,f,wl0x7y7,e,2,gst,%,
lvl-1x0y0,112,14,32,s,94,56,16,1,1,s,94,64,16,1,1,s,110,56,24,1,1,s,110,64,24,1,1,s,94,0,56,1,1,s,94,0,64,1,1,s,94,0,72,1,1,o,t,32,24,o,t,96,24,o,can,60,24,40,39,o,spk,56,96,f,o,spk,64,96,true,e,3,bat,%,
lvl-1x1y0,112,14,32,s,94,56,120,1,1,s,94,64,120,1,1,s,94,56,16,1,1,s,94,64,16,1,1,s,110,56,24,1,1,s,110,64,24,1,1,s,94,120,56,1,1,s,94,120,64,1,1,s,94,120,72,1,1,o,t,32,24,o,t,64,24,o,t,96,24,o,gem,112,32,50,g-1x1y0,true,o,gem,112,68,50,g-1x1y0,true,o,gem,112,112,50,g-1x1y0,true,e,5,bat,e,2,sco,%,
lvl-1x2y0,96,14,32,s,77,56,16,1,1,s,93,56,24,1,1,s,77,64,16,1,1,s,93,64,24,1,1,s,77,0,48,1,1,s,77,0,56,1,1,s,77,0,64,1,1,s,77,0,72,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,4,sls,%,
lvl-1x3y0,96,14,32,s,77,56,16,1,1,s,93,56,24,1,1,s,77,64,16,1,1,s,93,64,24,1,1,s,77,120,48,1,1,s,77,120,56,1,1,s,77,120,64,1,1,s,77,120,72,1,1,s,77,56,120,1,1,s,77,64,120,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,2,slm,e,3,sls,o,spk,16,32,f,o,spk,16,40,f,o,spk,8,40,f,o,gem,8,32,25,g-1x3y0-1,true,o,spk,104,32,f,o,spk,104,40,f,o,spk,112,40,f,o,gem,112,32,25,g-1x3y0-2,true,o,spk,104,112,f,o,spk,104,104,f,o,spk,112,104,f,o,gem,112,112,25,g-1x3y0-3,true,o,spk,8,104,f,o,spk,16,104,f,o,spk,16,112,f,o,gem,8,112,25,g-1x3y0-4,true,o,gem,60,68,25,g-1x3y0-5,true,%,
lvl-1x4y0,96,14,32,s,77,56,16,1,1,s,93,56,24,1,1,s,77,64,16,1,1,s,93,64,24,1,1,s,77,0,56,1,1,s,77,0,64,1,1,s,77,0,72,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,3,bat,%,
lvl-1x5y0,96,14,32,s,77,56,120,1,1,s,77,64,120,1,1,s,77,56,16,1,1,s,93,56,24,1,1,s,77,64,16,1,1,s,93,64,24,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,2,wol,e,2,bat,o,gem,60,68,50,g-1x5y0,true,%,
lvl-1x6y0,96,14,32,s,77,56,16,1,1,s,93,56,24,1,1,s,77,64,16,1,1,s,93,64,24,1,1,s,77,120,56,1,1,s,77,120,64,1,1,s,77,120,72,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,3,sls,%,
lvl-1x7y0,16,0,2,o,war,88,56,104,1,1,0,7,0,48,68,2,f,wl-1x7y0,e,5,bat,e,3,sls,o,gem,64,72,25,g-1x4y2-1,true,o,gem,48,64,25,g-1x4y2-2,true,o,gem,56,56,25,g-1x4y2-3,true,%,
lvl-1x0y1,112,14,32,s,94,0,56,1,1,s,94,0,64,1,1,s,94,0,72,1,1,s,94,120,56,1,1,s,94,120,64,1,1,s,94,120,72,1,1,o,t,40,24,o,t,80,24,e,2,slm,%,
lvl-1x1y1,16,0,2,o,war,88,56,104,1,1,0,1,1,60,40,3,f,wl-1x1y1,e,1,snb,o,gem,16,40,50,g-1x1y1-1,true,o,gem,24,24,50,g-1x1y1-2,true,o,gem,64,24,50,g-1x1y1-3,true,o,gem,88,32,50,g-1x1y1-4,true,%,
lvl-1x2y1,96,14,32,s,77,0,56,1,1,s,77,0,64,1,1,s,77,0,72,1,1,s,77,56,120,1,1,s,77,64,120,1,1,o,t,40,24,o,t,80,24,o,spk,56,32,f,o,spk,64,32,f,e,2,bat,e,2,sls,o,gem,60,64,50,g-1x2y1,true,%,
lvl-1x3y1,96,14,32,s,77,56,16,1,1,s,93,56,24,1,1,s,77,64,16,1,1,s,93,64,24,1,1,s,77,56,120,1,1,s,77,64,120,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,3,bat,%,
lvl-1x4y1,96,14,32,s,77,56,120,1,1,s,77,64,120,1,1,o,t,40,24,o,t,80,24,o,p,f,o,war,88,96,104,1,1,0,4,1,92,56,3,f,wl-1x4y1,%,
lvl-1x5y1,96,14,32,s,77,56,120,1,1,s,77,64,120,1,1,s,77,56,16,1,1,s,93,56,24,1,1,s,77,64,16,1,1,s,93,64,24,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,2,sls,e,2,bat,%,
lvl-1x6y1,96,14,32,o,t,40,24,o,t,80,24,e,1,wol,e,2,bat,%,
lvl-1x7y1,96,14,32,s,77,120,56,1,1,s,77,120,64,1,1,s,77,120,72,1,1,s,77,56,16,1,1,s,93,56,24,1,1,s,77,64,16,1,1,s,93,64,24,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,3,bat,%,
lvl-1x0y2,112,14,32,s,94,0,56,1,1,s,94,0,64,1,1,s,94,0,72,1,1,s,94,120,56,1,1,s,94,120,64,1,1,s,94,120,72,1,1,o,t,40,24,o,t,80,24,o,p,f,o,war,88,96,104,1,1,0,0,2,100,56,3,f,wl-1x0y2,%,
lvl-1x1y2,16,0,2,o,war,88,56,104,1,1,0,1,2,60,48,2,f,wl-1x1y2,e,3,bat,e,2,sco,o,gem,64,72,50,g-1x1y2-1,true,o,gem,48,64,50,g-1x1y2-2,true,o,gem,56,56,50,g-1x1y2-3,true,%,
lvl-1x2y2,112,14,32,s,94,56,16,1,1,s,94,64,16,1,1,s,110,56,24,1,1,s,110,64,24,1,1,s,94,0,56,1,1,s,94,0,64,1,1,s,94,0,72,1,1,o,t,32,24,o,t,64,24,o,t,96,24,o,can,88,24,30,15,o,can,104,24,30,0,e,1,sco,e,2,bat,%,
lvl-1x3y2,112,14,32,s,94,56,16,1,1,s,94,64,16,1,1,s,110,56,24,1,1,s,110,64,24,1,1,s,94,120,56,1,1,s,94,120,64,1,1,s,94,120,72,1,1,s,94,56,120,1,1,s,94,64,120,1,1,o,t,32,24,o,t,64,24,o,t,96,24,o,gem,60,68,100,g-1x3y2-1,true,o,gem,8,32,100,g-1x3y2-2,true,o,gem,112,32,100,g-1x3y2-3,true,e,1,sdr,%,
lvl-1x4y2,16,0,2,o,war,88,56,104,1,1,0,4,2,32,72,2,f,wl-1x4y2,e,5,bat,o,gem,64,72,25,g-1x4y2-1,true,o,gem,48,64,25,g-1x4y2-2,true,o,gem,56,56,25,g-1x4y2-3,true,%,
lvl-1x5y2,96,14,32,s,77,0,56,1,1,s,77,0,64,1,1,s,77,0,72,1,1,s,77,56,120,1,1,s,77,64,120,1,1,s,77,56,16,1,1,s,93,56,24,1,1,s,77,64,16,1,1,s,93,64,24,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,1,snb,o,key,60,68,kforest,true,%,
lvl-1x6y2,96,14,32,s,77,120,56,1,1,s,77,120,64,1,1,s,77,120,72,1,1,s,77,56,120,1,1,s,77,64,120,1,1,o,t,40,24,o,t,80,24,o,spk,8,64,f,o,spk,8,72,f,o,spk,32,32,true,o,spk,32,40,true,o,spk,32,48,true,o,spk,32,56,true,o,spk,32,64,true,o,spk,32,72,true,o,spk,32,80,true,o,spk,32,88,true,o,spk,32,96,true,o,spk,32,104,true,o,spk,32,112,true,%,
lvl-1x7y2,96,14,32,s,77,0,56,1,1,s,77,0,64,1,1,s,77,0,72,1,1,s,77,120,56,1,1,s,77,120,64,1,1,s,77,120,72,1,1,s,77,56,120,1,1,s,77,64,120,1,1,o,t,40,24,o,t,80,24,e,1,snb,o,gem,56,56,50,g-1x7y2-1,true,o,gem,64,64,50,g-1x7y2-2,true,o,gem,56,72,50,g-1x7y2-3,true,%,
lvl-1x0y3,112,14,32,s,94,0,56,1,1,s,94,0,64,1,1,s,94,0,72,1,1,s,94,120,56,1,1,s,94,120,64,1,1,s,94,120,72,1,1,o,t,40,24,o,t,80,24,e,2,slm,%,
lvl-1x1y3,112,14,32,s,94,56,16,1,1,s,94,64,16,1,1,s,110,56,24,1,1,s,110,64,24,1,1,s,94,0,56,1,1,s,94,0,64,1,1,s,94,0,72,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,2,liz,%,
lvl-1x2y3,112,14,32,s,94,56,120,1,1,s,94,64,120,1,1,o,t,40,24,o,t,80,24,o,spk,40,48,true,o,spk,80,48,f,o,spk,40,88,f,o,spk,80,88,true,o,spk,60,68,f,e,2,sco,e,2,liz,%,
lvl-1x3y3,112,14,32,s,94,56,16,1,1,s,94,64,16,1,1,s,110,56,24,1,1,s,110,64,24,1,1,s,94,120,56,1,1,s,94,120,64,1,1,s,94,120,72,1,1,o,t,32,24,o,t,64,24,o,t,96,24,o,p,f,%,
lvl-1x4y3,80,28,32,s,105,56,16,1,1,s,105,64,16,1,1,s,73,56,24,1,1,s,73,64,24,1,1,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,32,24,o,t,64,24,o,t,96,24,o,key,60,68,kswamp,true,e,2,zar,%,
lvl-1x5y3,32,0,32,s,105,56,16,1,1,s,105,64,16,1,1,s,72,56,24,1,1,s,72,64,24,1,1,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,32,24,o,t,64,24,o,t,96,24,o,can,48,24,40,0,o,can,80,24,40,20,o,gem,8,32,50,gl-1x5y3-1,true,o,gem,112,32,50,gl-1x5y3-2,true,o,gem,8,112,50,gl-1x5y3-3,true,o,gem,112,112,50,gl-1x5y3-4,true,e,2,ske,3,3,bat,%,
lvl-1x6y3,16,0,2,s,13,56,40,1,1,o,war,88,56,104,1,1,0,6,3,60,48,3,f,wl-1x6y3,o,mhl,35,52,o,mat,56,52,o,msp,77,52,%,
lvl-1x7y3,16,0,2,o,war,88,56,104,1,1,0,7,3,60,48,3,f,wl-1x6y3,e,1,slm,e,2,sls,o,gem,64,72,25,g-1x4y2-1,true,o,gem,48,64,25,g-1x4y2-2,true,o,gem,56,56,25,g-1x4y2-3,true,o,gem,48,40,25,g-1x4y2-4,true,o,gem,52,48,25,g-1x4y2-5,true,%,
lvl-1x0y4,112,14,32,s,94,0,56,1,1,s,94,0,64,1,1,s,94,0,72,1,1,s,94,56,120,1,1,s,94,64,120,1,1,o,t,40,24,o,t,80,24,e,2,sco,%,
lvl-1x1y4,112,14,32,s,94,120,56,1,1,s,94,120,64,1,1,s,94,120,72,1,1,s,94,56,120,1,1,s,94,64,120,1,1,o,t,40,24,o,t,80,24,e,1,sco,e,1,liz,%,
lvl-1x2y4,16,0,2,o,war,88,56,104,1,1,0,2,4,60,88,1,f,wl-1x2y4,e,2,slm,o,gem,64,72,50,g-1x2y4-1,true,o,gem,48,64,50,g-1x2y4-2,true,o,gem,56,56,50,g-1x2y4-3,true,%,
lvl-1x3y4,112,14,32,s,94,0,56,1,1,s,94,0,64,1,1,s,94,0,72,1,1,s,94,120,56,1,1,s,94,120,64,1,1,s,94,120,72,1,1,s,94,56,120,1,1,s,94,64,120,1,1,o,t,40,24,o,t,80,24,o,key,60,68,kcave,true,e,1,zar,%,
lvl-1x4y4,80,28,32,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,40,24,o,t,80,24,e,2,sdr,%,
lvl-1x5y4,32,0,32,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,o,t,40,24,o,t,80,24,o,spk,56,32,f,o,spk,64,32,f,o,spk,56,112,f,o,spk,64,112,f,e,3,bat,e,2,snk,%,
lvl-1x6y4,32,0,32,s,105,56,16,1,1,s,105,64,16,1,1,s,72,56,24,1,1,s,72,64,24,1,1,s,209,48,24,1,1,s,209,80,24,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,2,ske,%,
lvl-1x7y4,32,0,32,s,105,56,16,1,1,s,105,64,16,1,1,s,72,56,24,1,1,s,72,64,24,1,1,s,105,56,120,1,1,s,105,64,120,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,32,24,o,t,64,24,o,t,96,24,o,can,48,24,90,60,o,can,80,24,90,30,e,6,bat,o,gem,112,32,50,gl-1x7y4-1,true,o,gem,112,64,50,gl-1x7y4-2,true,o,gem,112,112,50,gl-1x7y4-3,true,%,
lvl-1x0y5,80,28,32,s,105,56,16,1,1,s,105,64,16,1,1,s,73,56,24,1,1,s,73,64,24,1,1,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,105,56,120,1,1,s,105,64,120,1,1,o,t,32,24,o,t,64,24,o,t,96,24,o,gem,8,32,100,g-1x0y5-1,true,o,gem,60,32,100,g-1x0y5-2,true,o,gem,112,32,100,g-1x0y5-3,true,e,2,sdr,e,3,bat,%,lvl-1x1y5,80,28,32,s,105,56,16,1,1,s,105,64,16,1,1,s,73,56,24,1,1,s,73,64,24,1,1,s,105,56,120,1,1,s,105,64,120,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,1,shr,e,6,sls,%,
lvl-1x2y5,80,28,32,s,105,56,16,1,1,s,105,64,16,1,1,s,73,56,24,1,1,s,73,64,24,1,1,o,t,32,24,o,t,64,24,o,t,96,24,o,gem,8,32,100,g-1x2y5-1,true,o,gem,60,32,100,g-1x2y5-2,true,o,gem,112,32,100,g-1x2y5-3,true,e,4,bat,e,2,shr,e,1,liz,%,
lvl-1x3y5,80,28,32,s,105,56,16,1,1,s,105,64,16,1,1,s,73,56,24,1,1,s,73,64,24,1,1,s,105,56,120,1,1,s,105,64,120,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,8,bat,%,
lvl-1x4y5,80,28,32,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,40,24,o,t,80,24,o,p,f,%,
lvl-1x5y5,32,0,32,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,s,105,56,120,1,1,s,105,64,120,1,1,o,t,40,24,o,t,80,24,o,spk,48,32,f,o,spk,48,40,f,o,spk,48,48,f,o,spk,48,56,f,o,spk,48,64,f,o,spk,48,72,f,o,spk,48,80,f,o,spk,48,88,f,o,spk,48,96,f,o,spk,48,104,f,o,spk,48,112,f,o,spk,72,32,f,o,spk,72,40,f,o,spk,72,48,f,o,spk,72,56,f,o,spk,72,64,f,o,spk,72,72,f,o,spk,72,80,f,o,spk,72,88,f,o,spk,72,96,f,o,spk,72,104,f,o,spk,72,112,f,o,gem,8,32,50,gl-1x5y5-1,true,o,gem,112,32,50,gl-1x5y5-2,true,o,gem,8,112,50,gl-1x5y5-3,true,o,gem,112,112,50,gl-1x5y5-4,true,e,2,slm,e,6,bat,%,
lvl-1x6y5,32,0,32,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,193,8,48,1,1,s,193,8,88,1,1,o,t,40,24,o,t,80,24,o,gem,8,32,50,gl-1x6y5-1,true,o,gem,8,64,50,gl-1x6y5-2,true,o,gem,8,112,50,gl-1x6y5-3,true,e,3,bat,e,2,snk,%,
lvl-1x7y5,32,0,32,s,105,56,16,1,1,s,105,64,16,1,1,s,72,56,24,1,1,s,72,64,24,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,s,209,48,24,1,1,s,209,80,24,1,1,s,193,8,32,1,1,s,193,112,32,1,1,s,193,112,64,1,1,s,193,112,112,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,2,ske,e,3,bat,%,
lvl-1x0y6,16,0,2,o,gem,60,68,100,g-1x0y6-1,true,o,gem,16,40,100,g-1x0y6-2,true,o,gem,80,32,100,g-1x0y6-3,true,o,war,88,56,104,1,1,0,0,6,72,68,2,f,wl-1x0y6,e,1,sdr,e,3,bat,%,
lvl-1x1y6,80,28,32,s,105,56,16,1,1,s,105,64,16,1,1,s,73,56,24,1,1,s,73,64,24,1,1,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,2,sco,e,2,shr,%,
lvl-1x2y6,80,28,32,s,105,56,120,1,1,s,105,64,120,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,40,24,o,t,80,24,e,2,slm,e,3,bat,e,1,sco,%,
lvl-1x3y6,16,0,2,o,war,88,56,104,1,1,0,3,6,60,48,2,f,wl-1x3y6,o,gem,60,68,100,g-1x3y6-1,true,o,gem,16,40,100,g-1x3y6-2,true,o,gem,80,32,100,g-1x3y6-3,true,e,1,sdr,%,
lvl-1x4y6,80,28,32,s,105,56,120,1,1,s,105,64,120,1,1,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,40,24,o,t,80,24,o,spk,40,48,true,o,spk,80,48,f,o,spk,40,88,f,o,spk,80,88,true,o,gem,8,32,100,g-1x4y6-1,true,o,gem,112,32,100,g-1x4y6-2,true,o,gem,8,112,100,g-1x4y6-3,true,o,gem,112,112,100,g-1x4y6-4,true,e,1,zar,%,
lvl-1x5y6,32,0,32,s,106,0,56,1,1,s,106,0,64,1,1,s,72,56,24,1,1,s,72,64,24,1,1,s,106,0,72,1,1,s,105,56,16,1,1,s,105,64,16,1,1,s,209,48,24,1,1,s,209,80,24,1,1,s,193,8,32,1,1,s,193,112,32,1,1,o,t,32,24,o,t,64,24,o,t,96,24,o,spk,8,80,f,o,spk,24,80,true,o,spk,40,80,f,o,spk,56,80,true,o,spk,72,80,f,o,spk,88,80,true,o,spk,104,80,f,o,gem,16,32,50,g-1x5y6-1,true,o,gem,104,32,50,g-1x5y6-2,true,e,1,gst,e,2,ske,%,
lvl-1x6y6,32,0,32,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,s,105,56,120,1,1,s,105,64,120,1,1,s,193,8,32,1,1,s,193,112,32,1,1,s,193,112,64,1,1,o,t,40,24,o,t,80,24,o,spk,8,64,f,o,spk,8,72,f,e,1,slm,e,2,ske,%,
lvl-1x7y6,32,0,32,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,s,193,8,32,1,1,s,193,112,32,1,1,s,193,112,64,1,1,o,t,40,24,o,t,80,24,e,1,gst,e,2,snk,%,
lvl-1x0y7,16,0,2,o,war,88,56,104,1,1,0,0,7,32,68,2,f,wl-1x0y6,%,
lvl-1x1y7,80,28,32,s,105,56,120,1,1,s,105,64,120,1,1,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,o,t,40,24,o,t,80,24,o,gem,8,32,100,g-1x1y7-1,true,o,gem,60,112,100,g-1x1y7-2,true,o,gem,112,32,100,g-1x1y7-3,true,e,3,bat,e,4,sls,e,1,slm,%,
lvl-1x2y7,80,28,32,s,105,56,16,1,1,s,105,64,16,1,1,s,73,56,24,1,1,s,73,64,24,1,1,s,105,56,120,1,1,s,105,64,120,1,1,o,t,32,24,o,t,64,24,o,t,96,24,e,5,bat,%,
lvl-1x3y7,80,28,32,s,105,56,16,1,1,s,105,64,16,1,1,s,73,56,24,1,1,s,73,64,24,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,s,105,56,120,1,1,s,105,64,120,1,1,o,t,32,24,o,t,64,24,o,t,96,24,o,p,f,o,war,88,96,104,1,1,0,3,7,100,56,3,f,wl-1x3y7,%,
lvl-1x4y7,16,0,2,o,war,88,56,104,1,1,0,4,7,32,68,2,f,wl-1x4y7,e,3,bat,e,1,ske,o,gem,64,72,50,g-1x4y7-1,true,o,gem,48,64,50,g-1x4y7-2,true,o,gem,56,56,50,g-1x4y7-3,true,%,
lvl-1x5y7,32,0,32,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,s,105,56,120,1,1,s,105,64,120,1,1,s,209,32,24,1,1,s,209,88,24,1,1,o,t,40,24,o,t,80,24,o,can,24,24,60,0,o,can,96,24,60,30,o,spk,16,40,f,o,spk,16,104,true,o,spk,104,40,f,o,spk,104,104,true,o,spk,60,60,true,o,spk,60,74,f,o,spk,52,68,true,o,spk,68,68,f,o,gem,8,32,50,g-1x5y7-1,true,o,gem,8,112,50,g-1x5y7-2,true,o,gem,112,32,50,g-1x5y7-3,true,o,gem,112,112,50,g-1x5y7-4,true,o,key,60,68,ktomb,true,e,1,gst,e,1,ske,e,3,bat,%,
lvl-1x6y7,16,0,2,s,193,16,40,1,1,s,193,8,48,1,1,s,193,96,40,1,1,s,193,96,56,1,1,s,193,96,72,1,1,o,war,88,56,104,1,1,0,6,7,72,68,2,f,wl-1x6y7,e,2,gst,o,gem,64,72,50,g-1x6y7-1,true,o,gem,48,64,50,g-1x6y7-2,true,o,gem,56,56,50,g-1x6y7-3,true,%,
lvl-1x7y7,32,0,32,s,105,56,120,1,1,s,105,64,120,1,1,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,40,24,o,t,80,24,o,p,f,o,war,88,96,104,1,1,0,7,7,108,80,3,f,wl-1x7y7,%,
lvl1x3y3,32,0,32,s,105,56,16,1,1,s,105,64,16,1,1,s,105,56,120,1,1,s,105,64,120,1,1,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,40,24,o,t,80,24,o,d,56,24,d1x3y3,1,3,2,60,112,1,w1x3y3-1,o,war,194,56,104,2,2,0,3,3,60,48,3,f,wl1x3y3-2,e,3,wol,e,2,snb,%,
lvl1x3y2,32,0,32,s,105,56,16,1,1,s,105,64,16,1,1,s,72,56,24,1,1,s,72,64,24,1,1,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,32,24,o,t,64,24,o,t,96,24,o,war,88,60,40,1,1,2,3,2,60,96,1,true,wl1x3y2-1,o,war,127,60,124,1,1,1,3,3,60,32,3,f,wl1x3y2-2,e,3,gst,e,3,ske,%,
lvl2x3y2,32,0,32,s,105,56,16,1,1,s,105,64,16,1,1,s,105,56,120,1,1,s,105,64,120,1,1,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,40,24,o,t,80,24,o,d,56,24,d1x3y3,2,3,1,60,112,1,w2x3y2-1,o,war,194,56,104,2,2,1,3,2,60,48,3,f,wl2x3y2-2,e,2,sco,e,3,liz,%,
lvl2x3y1,32,0,32,s,105,56,16,1,1,s,105,64,16,1,1,s,72,56,24,1,1,s,72,64,24,1,1,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,32,24,o,t,64,24,o,t,96,24,o,war,88,60,40,1,1,3,3,1,60,96,1,true,wl3x3y1-1,o,war,127,60,124,1,1,2,3,2,60,32,3,f,wl3x3y1-2,e,3,shr,e,2,sdr,%,
lvl3x3y1,32,0,32,s,105,56,16,1,1,s,105,64,16,1,1,s,105,56,120,1,1,s,105,64,120,1,1,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,40,24,o,t,80,24,o,p,f,o,d,56,24,d1x3y3,3,3,0,60,112,1,w2x3y2-1,o,war,194,56,104,2,2,2,3,1,60,48,3,f,wl2x3y2-2,%,
lvl3x3y0,32,0,32,s,105,56,16,1,1,s,105,64,16,1,1,s,72,56,24,1,1,s,79,64,24,1,1,s,95,64,32,1,1,s,111,56,32,1,1,s,111,72,32,1,1,s,183,48,32,1,1,s,183,80,32,1,1,s,106,0,56,1,1,s,106,0,64,1,1,s,106,0,72,1,1,s,106,120,56,1,1,s,106,120,64,1,1,s,106,120,72,1,1,o,t,32,24,o,t,96,24,o,war,127,60,124,1,1,2,3,2,60,32,3,f,wl3x3y1-2,e,3,zar,%
]]
 rooms={}
 rooms_string=remove_whitespace(rooms_string)
 local dat={nil,1,rooms_string}
 while dat[2]<#dat[3] do
  get_next_arg(dat)
  process_room(dat)
 end
end

function remove_whitespace(str)
 local i=0
 while i<#str do
  if sub(str,i,i)=="\n" or sub(str,i,i)==" " then
   str=sub(str,1,i-1)..sub(str,i+1)
   i-=1
  end
  i+=1
 end 
 return str
end

function get_next_arg(dat)
 local start_char,end_char=dat[2],dat[2]
 for i=start_char,#dat[3] do
  if sub(dat[3],i,i)=="," then
   end_char=i
   break
  end
 end
 dat[2]=end_char+1
 if end_char==start_char then
  dat[1]=sub(dat[3],start_char,end_char)
 else
  dat[1]=sub(dat[3],start_char,end_char-1)
 end
end

function process_room(dat)
 local room_name,new_room=dat[1],{}
 get_next_arg(dat)
 local mapx=dat[1]+0
 get_next_arg(dat)
 local mapy=dat[1]+0
 get_next_arg(dat)
 new_room.map,new_room.solid,new_room.objects,new_room.music={mapx,mapy},{},{},dat[1]+0
 get_next_arg(dat)
 while dat[1]!="%" do
  process_room_arg(new_room,dat)
  get_next_arg(dat)
 end
 rooms[room_name]=new_room
end

function process_room_arg(new_room,dat)
 if dat[1]=="s" then
  process_solid(new_room,dat)
 elseif dat[1]=="o" then
  process_object(new_room,dat,1)
 elseif dat[1]=="e" then
  get_next_arg(dat)
  local rpt=dat[1]
  process_object(new_room,dat,rpt)
 end
end

function process_solid(new_room,dat)
 --{sprite,x,y,width,height,flipx,flipy}
 local args=get_args(dat,5)
 add(new_room.solid, {args[1]+0,args[2]+0,args[3]+0,args[4]+0,args[5]+0,false,false})
end

function process_object(new_room,dat,rpt)
 get_next_arg(dat)
 local m=omap[dat[1]]
 if m then
  local args=get_args(dat,m[2])
  for i=1,rpt do
   add(new_room.objects,m[1](args))
  end
 end
end

function get_args(dat,num_args)
 local args={}
 for i=1,num_args do
  get_next_arg(dat)
  args[i]=dat[1]
 end
 return args
end
-->8
function portal(args)
 local o={}
 o.x,o.y,o.w,o.h,o.bg,o.sprite,o.home,o.update,o.draw=56,64,2,2,true,204,args[1]=="true",update_portal,draw_image
 if (o.home) o.sprite=206
 return o
end

function update_portal(o)
 if (portal and portal.roomlvl==roomlvl and portal.roomx==roomx and portal.roomy==roomy) o.sprite=206
 if check_collide(60,68,1,1,p.x,p.y,1,1) then
  if o.home then
   if portal then
    xhint.active=true
    if btnp(—) then
     sfx(19)
     warp_collide(portal)
    end
   end
  else
   if portal==nil or portal.roomlvl!=roomlvl or portal.roomx!=roomx or portal.roomy!=roomy then
    sfx(20)
    portal=make_warp({0,0,0,0,0,roomlvl,roomx,roomy,60,68,dir_d,false,nil})
   end
   xhint.active=true
   if btnp(—) then
    sfx(19)
    warp_collide(home)
   end
  end
 end
end

function make_warp(args)
 --{sprite,x,y,w,h,roomlvl,roomx,roomy,px,py,pdir,hidden,tag}
 local w={}
 w.sprite,w.bg,w.x,w.y,w.w,w.h,w.roomlvl,w.roomx,w.roomy,w.px,w.py,w.pdir,w.hidden,w.tag,w.update,w.draw,w.interact=args[1]+0,true,args[2]+0,args[3]+0,args[4]+0,args[5]+0,args[6]+0,args[7]+0,args[8]+0,args[9]+0,args[10]+0,args[11]+0,args[12]=="true",args[13],update_interact,draw_image,interact_warp
 return w
end

function interact_warp(w)
 if w.w==1 then
  sfx(16)
  warp_collide(w)
 else
  if check_collide(w.x+4,w.y+4,1,1,p.x,p.y,p.w,p.h) then
   sfx(16)
   warp_collide(w)
  end
 end
end

function diamondb(args)
 --args={x,y}
 return diamond(args[1]+0,args[2]+0,1,anims.diamondb,8)
end

function diamondg(args)
 --args={x,y}
 return diamond(args[1]+0,args[2]+0,5,anims.diamondg,9)
end

function diamondr(args)
 --args={x,y}
 return diamond(args[1]+0,args[2]+0,10,anims.diamondr,10)
end

function diamond(x,y,value,animset,sound)
 local d={}
 d.x,d.y,d.w,d.h,d.bg,d.value,d.anim,d.frame,d.update,d.draw,d.interact,d.sound=x,y,1,1,true,value,animset[1],1,update_interact,draw_sprite,pickup_diamond,sound
 d.ftime=d.anim[1][ftime]
 return d
end

function heart(args)
 --args={x,y}
 local h={}
 h.x,h.y,h.w,h.h,h.bg,h.sprite,h.update,h.draw,h.interact=args[1]+0,args[2]+0,1,1,true,40,update_interact,draw_image,pickup_heart
 return h
end

function collect_gems(value)
 p.gems+=value
 gems_collected+=value
 if (p.gems>9999) p.gems=9999
end

function pickup_diamond(obj)
 sfx(obj.sound)
 collect_gems(obj.value)
 del(objects, obj)
end

function pickup_heart(obj)
 sfx(12)
 p.hp+=1
 if (p.hp>p.mhp) p.hp=p.mhp
 del(objects,obj)
end

function merch_attack(args)
 --args={x,y}
 local s={}
 s.x,s.y,s.w,s.h,s.bg,s.sprite,s.label,s.awake,s.update,s.draw,s.interact,s.activate=args[1]+0,args[2]+0,1,1,true,37,"attack",awake_attack,update_interact,draw_merch,interact_merch,purchase_attack
 return s
end

function merch_health(args)
 --args={x,y}
 local s={}
 s.x,s.y,s.w,s.h,s.bg,s.sprite,s.label,s.awake,s.update,s.draw,s.interact,s.activate=args[1]+0,args[2]+0,1,1,true,16,"health",awake_health,update_interact,draw_merch,interact_merch,purchase_health
 return s
end

function merch_speed(args)
 --args={x,y}
 local s={}
 s.x,s.y,s.w,s.h,s.bg,s.sprite,s.label,s.awake,s.update,s.draw,s.interact,s.activate=args[1]+0,args[2]+0,1,1,true,19,"speed",awake_speed,update_interact,draw_merch,interact_merch,purchase_speed
 return s
end

function awake_speed(obj)
 if p.speed==2 then
  del(objects,obj)
 else
  obj.price=calc_speed_price()
 end
end

function awake_attack(obj)
 if p.atk==8 then
  del(objects,obj)
 else
  obj.price=calc_attack_price()
 end
end

function awake_health(obj)
 if p.mhp==10 then
  del(objects,obj)
 else
  obj.price=calc_health_price()
 end
end

function calc_attack_price()
 return attack_prices[p.atk]
end

function calc_health_price()
 return health_prices[p.mhp-2]
end

function calc_speed_price()
 return speed_prices[((p.speed-0.75)/0.25)]
end

function interact_merch(obj)
 if p.gems>=obj.price then
  xhint.active=true
  if btnp(—) then
   obj.activate(obj)
  end
 end
end

function draw_merch(obj)
 spr(obj.sprite,obj.x,obj.y,obj.w,obj.h,false,false)
 local pricestr=tostring(obj.price)
 print(pricestr,obj.x+4-(#pricestr*2),obj.y+8,6)
end

function purchase_merch(obj)
 sfx(18)
 p.gems-=obj.price
 hud.gems=p.gems
 obj.awake(obj)
end

function purchase_speed(obj)
 p.speed+=0.25
 purchase_merch(obj)
end

function purchase_attack(obj)
 p.atk+=1
 purchase_merch(obj)
end

function purchase_health(obj)
 p.mhp+=1
 p.hp=p.mhp
 purchase_merch(obj)
end

function lootsack(x,y,value)
 local l={}
 l.x,l.y,l.w,l.h,l.value,l.tag,l.bg,l.sprite,l.update,l.draw,l.interact=x,y,1,1,value,"lootsack",true,39,update_interact,draw_image,pickup_loot
 return l
end

function pickup_loot(obj)
 sfx(11)
 collect_gems(obj.value)
 del(objects,obj)
 delete_lootsack()
end

function key(args)
 local k={}
 k.hidden,k.check1,k.x,k.y,k.w,k.h,k.tag,k.bg,k.sprite,k.update,k.draw,k.interact=args[4]=="true",true,args[1]+0,args[2]+0,1,1,args[3],true,38,update_interact,draw_image,pickup_key
 return k
end

function pickup_key(obj)
 sfx(13)
 delete_obj(obj.tag)
 p.keys+=1
 del(objects,obj)
end

function door(args)
 --args={x,y,tag,roomlvl,roomx,roomy,px,py,pdir,warptag}
 local d,x,y={},args[1]+0,args[2]+0
 d.x,d.y,d.w,d.h,d.tag,d.bg,d.open,d.solid,d.warp,d.awake,d.update,d.draw,d.interact=x,y,2,1,args[3],true,false,{0,x,y-1,2,1,false,false},make_warp({127,x+4,y-4,1,1,args[4]+0,args[5]+0,args[6]+0,args[7]+0,args[8]+0,args[9]+0,false,args[10]}),awake_door,update_interact,draw_image,interact_door
 return d
end

function awake_door(obj)
 if obj.open then
  obj.sprite=75
 else
  obj.sprite=91
  local add_solid=true
  for o in all(room.solid) do
   if (o==obj.solid) add_solid=false
  end
  if (add_solid) add(room.solid,obj.solid)
 end
 add(objects,obj.warp)
end

function interact_door(obj)
 if not obj.open and p.keys>0 then
  sfx(15)
  obj.open,obj.sprite=true,75
  p.keys-=1
  for s in all(room.solid) do
   del(room.solid,obj.solid)
  end
  for o in all(room.objects) do
   if (obj.tag==o.tag) o.open=true
  end
 end
end

function gempile(args)
 --args{x,y,value,tag,hidden}
 local g={}
 g.hidden,g.check1,g.x,g.y,g.w,g.h,g.bg,g.value,g.anim,g.frame,g.update,g.draw,g.interact=args[5]=="true",true,args[1]+0,args[2]+0,1,1,true,args[3]+0,anims.gempile[1],1,update_interact,draw_sprite,pickup_gempile
 if (args[4]!="nil") g.tag=args[4]
 g.ftime=g.anim[g.frame][ftime]
 return g
end

function pickup_gempile(obj)
 sfx(11)
 collect_gems(obj.value)
 delete_obj(obj.tag)
 del(objects,obj)
end

function delete_obj(tag)
 for o in all(room.objects) do
  if (tag==o.tag) del(room.objects,o)
 end
end

function fountain(args)
 local f={}
 f.x,f.y,f.w,f.h,f.anim,f.frame,f.update,f.draw,f.tick,f.effect=args[1]+0,args[2]+0,2,2,anims.fountain[1],1,update_fountain,draw_sprite,0,true
 f.ftime=f.anim[1][ftime]
 return f
end

function update_fountain(f)
 if abs((f.x+8)-(p.x+4))<16 and abs((f.y+8)-(p.y+4))<16 then
  f.tick+=1
  if f.tick==15 then
   f.tick=0
   pickup_heart({})
  end
 end
 update_frame(f)
end

function spikes(args)
 local s={}
 s.x,s.y,s.w,s.h,s.up,s.dmg,s.bg,s.update,s.draw,s.wait,s.tick=args[1]+0,args[2]+0,1,1,args[3]=="true",1,true,update_spikes,draw_image,45,0
 return s
end

function update_spikes(s)
 s.sprite=233
 if (s.up) then
  s.sprite=234
  collide_player(s)
 end
 s.tick+=1
 if (s.tick==s.wait-5 and not s.up) play_spike=true
 if s.tick==s.wait then
  s.tick,s.up=0,not s.up
 end
end

function cannon(args)
 local c={}
 c.x,c.y,c.w,c.h,c.wait,c.tick,c.update,c.draw,c.anim,c.frame,c.ftime=args[1]+0,args[2]+0,1,1,args[3]+0,args[4]+0,update_cannon,draw_sprite,anims.cannon[1],1,-1
 return c
end

function update_cannon(c)
 c.tick+=1
 if c.tick==c.wait-8 then
  c.frame,c.ftime=2,8
 end
 if c.tick==c.wait then
  sfx(60)
  f=shoot_fireball(c)
  f.y,f.dx,f.dy=c.y+8,0,2
  c.tick=0
 end
 update_frame(c)
end

function shoot_fireball(e)
 local f=basic_projectile(e.x,e.y,2,3,anims.fireball)
 sfx(61)
 add(objects,f)
 return f
end

-->8
function base_enemy(anims,update,hp,speed,dmg,rewards,wait)
 local o={}
 o.tag,o.x,o.y,o.dx,o.dy,o.w,o.h,o.speed,o.dir,o.dmg,o.wait,o.anims,o.hp,o.mhp,o.rewards="enemy",0,0,0,0,1,1,speed,dir_r,dmg,wait,anims,hp,hp,rewards
 o.anim,o.frame=o.anims[o.dir],1
 o.ftime=o.anim[1][ftime]
 o.awake,o.update,o.draw,o.hit,o.kill=awake_enemy,update,draw_enemy,take_hit,kill_basic
 return o
end

function bat(args)
 local b=base_enemy(anims.bat,update_enemy_chase_and_stop,1,0.75,1,{diamondb(zeroxy),heart(zeroxy)},15)
 b.random=true
 return b
end

function bee(args)
 local b=base_enemy(anims.bee,update_enemy_chase_and_stop,2,0.75,1,{diamondb(zeroxy),diamondb(zeroxy),heart(zeroxy)},1)
 b.random=true
 return b
end

function snake(args)
 return base_enemy(anims.snake,update_enemy_chase_and_stop,5,1,1,{diamondb(zeroxy),diamondg(zeroxy),heart(zeroxy)},30)
end

function wolf(args)
 return base_enemy(anims.wolf,update_enemy_chase_and_stop,4,1.25,1,{diamondg(zeroxy),diamondg(zeroxy),heart(zeroxy)},10)
end

function scorpion(args)
 local s=base_enemy(anims.scorpion,update_enemy_chase_and_stop,12,0.75,1,{diamondg(zeroxy),diamondr(zeroxy),heart(zeroxy)},10)
 s.chase=true
 return s
end

function snow_beast(args)
 local s=base_enemy(anims.snow_beast,update_enemy_chase_and_stop,16,1,1,{diamondr(zeroxy),heart(zeroxy)},60)
 s.range=shoot_snow_ball
 return s
end

function lizard(args)
 local s=base_enemy(anims.lizard,update_enemy_chase_and_stop,16,1.25,1,{diamondr(zeroxy),diamondr(zeroxy),heart(zeroxy)},40)
 s.range=shoot_fireball
 return s
end

function ghost(args)
 local g=base_enemy(anims.ghost,update_enemy_chase_and_stop,12,0.5,1,{diamondg(zeroxy),diamondr(zeroxy),heart(zeroxy)},0)
 g.hit=ghost_take_hit
 g.chase=true
 return g
end

function shroom(args)
 local s=base_enemy(anims.shroom,update_enemy_chase_and_stop,24,0.75,1,{diamondr(zeroxy),diamondr(zeroxy),heart(zeroxy)},40)
 s.range=spore_poof
 return s
end

function spore_poof(e)
 sfx(61)
 add(objects, spore(e.x,e.y,0,-1.5))
 add(objects, spore(e.x,e.y,1,-1))
 add(objects, spore(e.x,e.y,1.5,0))
 add(objects, spore(e.x,e.y,1,1))
 add(objects, spore(e.x,e.y,0,1.5))
 add(objects, spore(e.x,e.y,-1,1))
 add(objects, spore(e.x,e.y,-1.5,0))
 add(objects, spore(e.x,e.y,-1,-1))
end

function spider(args)
 local s=base_enemy(anims.spider,update_enemy_chase_and_stop,30,1.75,2,{diamondr(zeroxy),diamondr(zeroxy),heart(zeroxy)},30)
 s.range=shoot_web
 return s
end

function basic_projectile(x,y,speed,dmg,anim)
 local t={}
 t.x,t.y,t.dx,t.dy,t.w,t.h,t.anim,t.frame,t.dmg,t.update,t.draw=x,y,p.x-x,p.y-y,1,1,anim[1],1,dmg,update_projectile,draw_sprite
 t.ftime=t.anim[1][ftime]
 get_projectile_vector(t,speed)
 return t
end

function shoot_web(e)
 local w=basic_projectile(e.x,e.y,2.75,0,anims.fireball)
 w.sprite,w.update,w.draw=60,update_web,draw_image
 sfx(0)
 add(objects,w)
end

function update_web(w)
 w.x+=w.dx
 w.y+=w.dy
 if collide_player(w) then
	 p.webbed,p.web_time,p.holdtimer,delete=true,75,0,true
	 del(objects,w)
 elseif check_solid_collide(w.x,w.y,w.w,w.h) or offscreen(w) then
  del(objects,w)
 end
end

function offscreen(obj)
 return obj.x<0 or obj.x>127 or obj.y<0 or obj.y>127
end

function skeleton(args)
 local s=base_enemy(anims.skeleton,update_enemy_chase_and_stop,10,1,2,{diamondg(zeroxy),diamondg(zeroxy),heart(zeroxy)},24)
 s.random,s.range=true,shoot_bone
 return s
end

function shoot_bone(e)
 local b=basic_projectile(e.x,e.y,2,2,anims.bone)
 sfx(0)
 add(objects,b)
end

function shoot_snow_ball(e)
 local b=basic_projectile(e.x,e.y,2,4,anims.snow_ball)
 sfx(0)
 add(objects,b)
end

function update_projectile(b)
 b.x+=b.dx
 b.y+=b.dy
 update_frame(b)
 if (collide_player(b) or check_solid_collide(b.x,b.y,b.w,b.h)) del(objects,b)
end

function slime(args)
 local s=base_enemy(anims.slime,update_enemy_chase_and_stop,20,0.25,1,{diamondg(zeroxy),heart(zeroxy)},0)
 s.chase,s.kill=true,kill_slime
 return s
end

function kill_slime(e)
	for i=1,4 do
  local s=slime_small({e.x,e.y})
  s.x,s.y=e.x,e.y
	 add(objects,s)
	end
 kill_basic(e)
end

function slime_small(args)
 local s=base_enemy(anims.slime_small,update_enemy_chase_and_stop,1,1,1,{diamondb(zeroxy),heart(zeroxy)},1)
 s.random=true
 return s
end

function zard(args)
 local z=base_enemy(anims.zard,update_enemy_teleport,30,0,1,{diamondr(zeroxy),heart(zeroxy)},60)
 z.tick,z.range=90,shoot_bolt
 return z
end

function shoot_bolt(e)
 local b=basic_projectile(e.x,e.y,2.75,5,anims.bolt)
 sfx(4)
 add(objects,b)
end

function update_enemy_teleport(e)
 if e.dest then
  e.x,e.y=e.dest[1],e.dest[2]
  e.dest=nil
 else
  if e.tick==0 then
   e.dest={abs(rnd(118)+1),abs(rnd(102)+17)}
   while check_solid_collide(e.dest[1],e.dest[2],e.w,e.h) do
    e.dest={abs(rnd(118)+1),abs(rnd(102)+17)}
   end
   e.tick=e.wait
  else
   if e.tick==flr(e.wait/2) then
    e.range(e)
   end
   e.tick-=1
  end
 end
 update_frame(e)
end

function update_enemy_chase_and_stop(e)
 e.dx,e.dy=0,0
 if (e.chase) e.dest={p.x,p.y}
 if (e.dest) then
	 local movex,movey=e.dest[1]-e.x,e.dest[2]-e.y
	 if (abs(movex)+abs(movey))>4 then
		 if (abs(movex)>2) e.dx=e.speed*sgn(movex)
		 if (abs(movey)>2) e.dy=e.speed*sgn(movey)
		 local update_anim=false
		 if (e.dx<0 and e.dir!=dir_l) e.dir,update_anim=dir_l,true
		 if (e.dx>0 and e.dir!=dir_r) e.dir,update_anim=dir_r,true
		 if update_anim then
			 e.anim=e.anims[e.dir]
		 end
		 collide_solids(e)
		 if (e.dx==0 and e.dy==0) e.dest=nil
		else
		 e.dest=nil
		end
 else
  if (e.tick==nil) e.tick=0
  e.tick+=1
  if (e.range and e.tick%(flr(e.wait/2)+1)==0) e.range(e)
  if e.tick==e.wait then 
  	e.tick=0
  	if e.random then
  	 e.dest={abs(rnd(118)+1),abs(rnd(102)+17)}
  	else
  	 e.dest={mid(1,p.x+rnd(14)-rnd(14),119),mid(17,p.y+rnd(16)-rnd(16),119)}
  	end
  end
 end
 collide_player(e)
 update_frame(e)
end

function collide_player(e)
 if not p.dead and not p.flash and check_collide(e.x,e.y,e.w,e.h,p.x,p.y,p.w,p.h) then
  sfx(5)
 	take_hit(p,e.dmg)
 	return true
 end
 return false
end

function ghost_take_hit(obj,dmg,supershot)
 if (supershot) then 
  return take_hit(obj,dmg)
 end
 return false
end

function take_hit(obj,dmg)
 obj.hp-=dmg
 obj.flash,obj.flash_tick,obj.flash_color=true,0,8
 if (obj.hp<=0) obj.kill(obj)
 return true
end

function kill_basic(obj)
 monsters_killed+=1
 e=explosion(obj.x,obj.y,reward_drop,obj.rewards)
 add(objects,e)
 del(objects,obj)
 check_room_clear()
end

function draw_enemy(obj)
 draw_sprite(obj)
 if (obj.hp<obj.mhp) then
  local hp_pixels = flr(((6/obj.mhp)*obj.hp)+0.5)
  for i=1,6 do
   if hp_pixels>=i then
    pset(obj.x+i,obj.y-2,8)
   else
    pset(obj.x+i,obj.y-2,2)
   end
  end
 end
end

function awake_enemy(e)
 if e.x==0 or e.y==0 then
  e.x,e.y=abs(rnd(88)+16),abs(rnd(72)+32)
  while check_solid_collide(e.x,e.y,e.w,e.h) or (abs(e.x-p.x)<40 and abs(e.y-p.y)<40) do
   e.x,e.y=abs(rnd(88)+16),abs(rnd(72)+32)
  end
 end
end
-->8
function explosion(x,y,animcb,cbinfo)
 local e={}
 e.effect,e.x,e.y,e.w,e.h,e.anim,e.frame=true,x,y,1,1,anims.explosion[1],1 
 e.ftime=e.anim[e.frame][ftime]
 e.update,e.draw,e.end_of_anim,e.end_of_anim_info=update_frame,draw_sprite,animcb,cbinfo
 sfx(7)
 return e
end

function make_xhint(x,y)
 xhint={}
 xhint.active,xhint.effect,xhint.x,xhint.y,xhint.w,xhint.h,xhint.anim,xhint.frame,xhint.update,xhint.draw=false,true,x,y,1,1,anims.buttonx[1],1,update_hint,draw_hint
 xhint.ftime=xhint.anim[xhint.frame][ftime]
end

function update_hint(h)
 if xhint.active then
  update_frame(h)
  xhint.active=false
 end
end

function draw_hint(h)
 if xhint.active then
  xhint.x,xhint.y=p.x,p.y-10
  draw_sprite(h)
 end
end

function spore(x,y,dx,dy)
 local s={}
 s.effect,s.tick,s.x,s.y,s.dx,s.dy,s.w,s.h,s.anim,s.frame,s.dmg,s.update,s.draw=true,0,x,y,dx,dy,1,1,anims.spore[1],1,2,update_spore,draw_sprite
 s.ftime=s.anim[s.frame][ftime]
 return s
end

function update_spore(s)
 s.tick+=1
 if (s.tick>50) del(objects,s)
 if (s.tick<30) then
  s.x+=s.dx
  s.y+=s.dy
 end
 collide_player(s)
 update_frame(s)
end

function reward_drop(obj)
 if(obj.end_of_anim_info) then
  local reward=rnd(obj.end_of_anim_info)
  if (reward) then
   reward.x,reward.y=obj.x,obj.y
   add(objects, reward)
  end
 end
 del(objects,obj)
end

function torch(args)
 local t={}
 t.bg,t.x,t.y,t.w,t.h,t.anim,t.frame,t.update,t.draw=true,args[1]+0,args[2]+0,1,1,anims.torch[1],1,update_frame,draw_sprite
 t.ftime=t.anim[1][ftime]
 return t
end
-->8
function init_anims()
 sprite,flipx,flipy,ftime=1,2,3,4
 anims={}
 local anims_string=[[arrow,a,f,17,f,f,-1,%,a,f,18,f,f,-1,%,a,f,17,f,true,-1,%,a,f,18,true,f,-1,%,%,bat,a,%,a,f,25,f,f,4,f,26,f,f,4,%,a,%,a,f,25,true,f,4,f,26,true,f,4,%,%,bee,a,%,a,f,41,f,f,2,f,42,f,f,2,%,a,%,a,f,41,true,f,2,f,42,true,f,2,%,%,bolt,a,f,247,f,f,3,f,247,true,f,3,f,246,f,f,3,f,246,true,f,3,%,%,bone,a,f,47,f,f,4,f,47,f,true,4,f,47,true,true,4,f,47,true,f,4,%,%,buttono,a,f,45,f,f,4,f,46,f,f,4,%,%,buttonx,a,f,61,f,f,4,f,62,f,f,4,%,%,cannon,a,f,230,f,f,-1,f,192,f,f,8,%,%,diamondb,a,f,32,f,f,120,f,33,f,f,3,f,34,f,f,3,f,35,f,f,6,f,34,f,f,3,%,%,diamondg,a,f,48,f,f,120,f,49,f,f,3,f,50,f,f,3,f,51,f,f,6,f,50,f,f,3,%,%,diamondr,a,f,52,f,f,120,f,53,f,f,3,f,54,f,f,3,f,55,f,f,6,f,54,f,f,3,%,%,explosion,a,f,21,f,f,4,f,22,f,f,4,f,24,f,f,4,%,%,fireball,a,f,231,f,f,3,f,232,f,f,3,f,231,true,true,3,f,232,true,true,3,%,%,fountain,a,f,226,f,f,3,f,226,true,f,3,f,228,f,f,3,f,228,true,f,3,%,%,gempile,a,f,255,f,f,60,f,254,f,f,4,f,253,f,f,3,f,254,f,f,4,f,252,f,f,4,f,251,f,f,3,f,252,f,f,4,%,%,ghost,a,%,a,f,56,f,f,6,f,57,f,f,6,%,a,%,a,f,56,true,f,6,f,57,true,f,6,%,%,lizard,a,%,a,f,188,f,f,6,f,187,f,f,6,f,188,f,f,6,f,186,f,f,6,%,a,%,a,f,188,true,f,6,f,187,true,f,6,f,188,true,f,6,f,186,true,f,6,%,%,p,s,a,f,1,f,f,-1,%,a,f,7,f,f,-1,%,a,f,4,f,f,-1,%,a,f,7,true,f,-1,%,%,s,a,f,2,f,f,6,f,1,f,f,6,f,3,f,f,6,f,1,f,f,6,%,a,f,8,f,f,6,f,7,f,f,6,f,9,f,f,6,f,7,f,f,6,%,a,f,5,f,f,6,f,4,f,f,6,f,6,f,f,6,f,4,f,f,6,%,a,f,8,true,f,6,f,7,true,f,6,f,9,true,f,6,f,7,true,f,6,%,%,s,a,f,10,f,f,-1,%,a,f,12,f,f,-1,%,a,f,11,f,f,-1,%,a,f,12,true,f,-1,%,%,%,scorpion,a,%,a,f,184,f,f,3,f,185,f,f,3,%,a,%,a,f,184,true,f,3,f,185,true,f,3,%,%,shroom,a,%,a,f,27,f,f,6,f,28,f,f,6,%,a,%,a,f,27,true,f,6,f,28,true,f,6,%,%,skeleton,a,%,a,f,30,f,f,6,f,31,f,f,6,f,30,f,f,6,f,63,f,f,6,%,a,%,a,f,30,true,f,6,f,31,true,f,6,f,30,true,f,6,f,63,true,f,6,%,%,slime,a,%,a,f,15,f,f,8,f,14,f,f,6,%,a,%,a,f,15,f,f,8,f,14,f,f,6,%,%,slime_small,a,%,a,f,44,f,f,4,f,43,f,f,3,%,a,%,a,f,44,f,f,4,f,43,f,f,3,%,%,snake,a,%,a,f,238,f,f,4,f,239,f,f,4,%,a,%,a,f,238,true,f,4,f,239,true,f,4,%,%,snow_ball,a,f,235,f,f,3,f,235,f,true,3,f,235,true,f,3,f,235,true,true,3,%,%,snow_beast,a,%,a,f,237,f,f,6,f,236,f,f,6,f,237,f,f,6,f,236,true,f,6,%,a,%,a,f,237,f,f,6,f,236,f,f,6,f,237,f,f,6,f,236,true,f,6,%,%,spider,a,%,a,f,58,f,f,6,f,59,f,f,6,%,a,%,a,f,58,true,f,6,f,59,true,f,6,%,%,spore,a,f,29,f,f,4,f,29,f,true,4,f,29,true,f,4,f,29,true,true,4,%,%,torch,a,f,120,f,f,2,f,121,f,f,2,%,%,wolf,a,%,a,f,191,f,f,6,f,190,f,f,6,f,191,f,f,6,f,189,f,f,6,%,a,%,a,f,191,true,f,6,f,190,true,f,6,f,191,true,f,6,f,189,true,f,6,%,%,zard,a,%,a,f,250,f,f,12,f,249,f,f,4,f,248,f,f,4,%,a,%,a,%,%]]
 anims_string=remove_whitespace(anims_string)
 local dat={nil,1,anims_string}
 while dat[2]<#dat[3] do
  get_next_arg(dat)
  process_anim_set(dat)
 end
end

function process_anim_set(dat)
 local set_name,set=dat[1],{}
 get_next_arg(dat)
 while dat[1]!="%" do
  if dat[1]=="s" then
   process_anim_state(dat,set)
  elseif dat[1]=="a" then
   process_anim(dat,set)
  end
  get_next_arg(dat)
 end
 anims[set_name]=set
end

function process_anim_state(dat,set)
 local state={}
 get_next_arg(dat)
 while(dat[1]!="%") do
  if dat[1]=="a" then
   process_anim(dat,state)
  end
  get_next_arg(dat)
 end
 add(set,state)
end

function process_anim(dat,set)
 local anim={}
 get_next_arg(dat)
 while(dat[1]!="%") do
  if dat[1]=="f" then
   process_frame(dat,anim)
  end
  get_next_arg(dat)
 end
 add(set,anim)
end

function process_frame(dat,set)
 local args=get_args(dat,4)
 add(set,{args[1]+0,args[2]=="true",args[3]=="true",args[4]+0})
end
-->8
function init_title_screen()
 local title_string=[[16,2081,0,16,9,5,16,118,0,5,16,9,2,5,16,117,0,5,16,9,2,5,16,116,0,5,16,4,2,16,7,13,16,116,0,5,16,4,2,16,19,0,16,2,5,16,6,0,16,2,5,16,4,0,16,3,5,16,4,0,16,3,5,16,5,0,16,2,5,16,6,0,16,2,5,16,65,0,5,16,3,2,5,16,18,0,5,16,2,2,5,16,4,0,5,16,2,2,5,16,2,0,5,16,3,2,5,16,2,0,5,16,3,2,5,16,3,0,5,16,2,2,5,16,4,0,5,16,2,2,5,16,64,0,5,16,3,2,16,4,5,16,15,0,5,16,3,2,5,16,2,0,5,16,3,2,5,16,2,0,5,16,3,2,5,16,2,0,5,16,3,2,5,16,3,0,5,16,3,2,5,16,2,0,5,16,4,2,5,16,62,0,5,16,8,2,5,16,3,0,16,9,5,16,3,0,5,16,3,2,16,2,5,16,3,2,5,16,3,0,5,16,3,2,5,16,2,0,5,16,3,2,5,16,2,0,5,16,4,2,5,16,2,0,5,16,4,2,5,16,62,0,5,16,8,2,5,16,3,0,5,16,7,2,5,16,4,0,5,16,6,2,5,16,4,0,5,16,3,2,5,16,2,0,5,16,3,2,5,16,2,0,5,16,12,2,5,16,61,0,5,16,8,2,5,16,3,0,5,16,7,2,5,16,6,0,5,16,4,2,5,16,5,0,5,16,3,2,5,16,2,0,5,16,3,2,5,16,2,0,5,16,12,2,5,16,61,0,5,16,4,2,16,4,13,16,4,0,5,2,5,16,3,13,5,2,5,16,6,0,5,16,4,2,5,16,5,0,5,16,3,2,5,16,2,0,5,16,3,2,5,16,2,0,5,16,12,2,5,16,61,0,5,16,3,2,5,16,8,0,5,2,5,16,3,0,5,2,5,16,5,0,5,16,6,2,5,16,4,0,5,16,4,2,16,2,5,16,4,2,5,16,2,0,5,16,3,2,13,16,4,2,13,16,3,2,5,16,60,0,5,16,4,2,5,16,7,0,5,16,2,2,5,16,2,0,5,2,5,16,5,0,5,16,3,2,5,16,4,2,5,16,3,0,13,16,10,2,13,16,2,0,5,16,2,2,5,0,13,16,2,2,13,0,16,3,2,5,16,60,0,5,16,3,2,5,16,8,0,5,16,3,2,16,2,5,16,2,2,5,16,4,0,5,16,3,2,5,0,5,16,4,2,5,16,3,0,13,16,8,2,13,16,2,0,5,16,3,2,5,16,2,0,16,2,2,16,2,0,5,16,3,2,5,16,58,0,5,16,4,2,5,16,7,0,5,16,7,2,5,16,4,0,5,16,3,2,5,16,3,0,5,16,4,2,5,16,3,0,13,16,6,2,13,16,3,0,5,16,2,2,5,16,3,0,16,2,13,16,3,0,5,16,2,2,5,16,58,0,16,5,13,16,8,0,16,9,13,16,3,0,16,5,13,16,5,0,16,5,13,16,4,0,16,6,13,16,4,0,16,4,13,16,8,0,16,4,13,16,187,0,16,12,15,16,44,0,16,6,6,16,66,0,16,11,9,16,3,15,16,43,0,16,5,5,16,4,6,16,62,0,16,15,15,16,43,0,16,8,5,6,16,61,0,16,58,4,16,9,5,6,16,60,0,16,15,15,16,43,0,16,8,5,6,16,61,0,16,11,9,16,3,15,16,43,0,16,5,5,16,4,6,16,62,0,16,12,15,16,44,0,16,6,6,16,11302,0,]]
 title_string,title_image,redraw,tick=remove_whitespace(title_string),{},true,0
 local dat={nil,1,title_string}
 while dat[2]<#dat[3] do
  get_next_arg(dat)
		add(title_image,dat[1]+0)
 end
 update_function,draw_function=update_title,draw_title
 music(0,500)
end

function draw_title_screen()
 local i,col,num,count=1,-1,0,1
 for y=0,127 do
  for x=0,127 do
   if count>num then
    if title_image[i]==16 then
     count,num,col=1,title_image[i+1],title_image[i+2]
     i+=3
    else
     count,num,col=1,0,title_image[i]
     i+=1
    end
   end
   pset(x,y,col)
   count+=1
  end
 end
end

function update_title()
 tick+=1
 if btnp(—) then
  start_game()
 end
 if (tick==30) print_msg=true
 if (tick==90) redraw,tick=true,0
end

function draw_title()
 if redraw then
  cls()
  draw_title_screen()
  redraw=false
 end
 if print_msg then
  print("press — to start",30,112,7)
  print_msg=false
 end
end

function update_end()
end

function draw_end()
 cls()
 print("and so foxum saved princess\nfoxy from the clutches of the\nevil zards and peace was\nrestored to the land",8,16,12)
 print("deaths\n\n\nenemies vanquished\n\n\ngems collected",8,48,13)
 print(tostr(deaths).."\n\n\n"..tostr(monsters_killed).."\n\n\n"..tostr(gems_collected),8,56,7)
end
__gfx__
00000000011111100111111001111110011111100111111001111110001110000011100000111000001111000011110000111000011111100001100000000000
0000000014bbb74114bbb74114bbb741147bbb41147bbb41147bbb410147b1000147b1000147b10001bb7410017b94100147b100142222410013310000111100
00700700144444411444444114444441144bb441144bb441144bb4911444411014444910144441100144441001b494100144491012144121013bb31001333310
0007700019444410014444411444441001444491144444910144444114444451144444511444445101444410014494100144559112444421013bb310013bb310
0007700014bb7b4119b7bb1019bb7b1014b55b4101b55b9101b55b9117bbb91017bbb41017bbb11001b7b44114554b101744b44112214221013bb310133bb331
0070070019bb4b1014b4bb1019bb4b4101bbbb9101bbbb4114bbbb9114b4b100044bb91014bb49100154b110015b9b1014bbb19114222241013333101333bb31
00000000193333100191331001331110013333100011331001331110013351000151331001315510001533100015931001335910122222210133331013333331
00000000011111000010110001110000001111000000110000110000001110000010110000101100000111000001110000111100011111100111111001111110
07707700000100000000000011111100000000000000000000000000000000000100001000000000000220000001100000011000000009000111110001111100
78878870001610000110010014444100000000000000000000100100000110001710017120000002022222000012910000129100020000001166611011666110
78887870016661001771161014444100000000000001100001711710001771000100001022022022222222200199921001999210009020901717171017171710
78888870001410000144466101111000000000000017710000177100017117100000000022222220222220021292992112929921000200000177710001777100
078887000014100017711610014411100000000000177100001771000171171000000000022222002000000201d77d1001177110000000901616161016161610
007870000174710001100100144144410cccccc00001100001711710001771000100001000220000000000000017710001d77d10000090001677761001777161
00070000017171000000000014444441777777770000000000100100000110001710017100000000000000000191191000199100090000200161610000116110
000000000010100000000000011111100cccccc00000000000000000000000000100001000220000002200000010010000011000000020000010100000001000
00010000000100000001000000010000066066000099000000011100001101000010100001111001000000010000000000000000011111000000000000000100
001c1000001c1000007c1000001c17006006006000109000001aa910014414100181810001666110000001100001100000000000166666100111110000001610
01c7c10001c7710001c7710001c77100600000600010090001a1119100199100188878100016a55100616551001bb10000011000665556601666661000001661
1ccc7c101cc77c101cc77c101cc77c106000006000100900001a9910014444101888881001a1655101a66551001bb100001bb100665656606655566000116110
01ccc10001ccc10001ccc700017cc1000600060000100900000191001444444101888100011a1110016a6110001331000133bb10665556606656566001661000
001c1000001c1000001c1000001c10000060600000109000001a9100144444410018100001a1000001a660000013310001333310566666506655566000161000
00010000000100000001000000010000000600000099000001aa9100014444100001000010100000101000000011110001111110155555101666661000010000
00000000000000000000000000000000000000000000000000111000001111000000000000011100000111000000000000000000011111000111110000000000
00010000000100000001000000010000000100000001000000010000000100000001100000011000011100000000000000000000011111000000000001111100
001b1000001b1000007b1000001b1700001810000018100000781000001817000017710001177100144410000111000000000000166666100111110011666110
01b7b10001b7710001b7710001b77100018781000187710001877100018771000171171017711710144441101444100000707000665656601666661017171710
1bbb7b101bb77b101bb77b101bb77b10188878101887781018877810188778101777777101777710149494411444411000070700666566606656566001777100
01bbb10001bbb10001bbb700017bb100018881000188810001888700017881000171771017717771149949411999994100707000665656606665666016161610
001b1000001b1000001b1000001b1000001810000018100000181000001810001777710017777110019919101944949100070700566666506656566016777100
00010000000100000001000000010000000100000001000000010000000100001711100001111000019919101911919100000000155555101666661001711000
00000000000000000000000000000000000000000000000000000000000000000100000000000000001101000100101000000000011111000111110000100000
3333333333333333444111443311113333333311133333339111911111111199555155555551555544111411551dddddddddd155cc111c111111111155515555
33333333333333334416651431333b13333331bbb133333314441444444444195dd0d555d33033dd4411444151d0000000000d157c11cc71001100005dd0d555
3b3b3333333333334165666131bbbb3133331bb3bb11333314444444441444191011111110111111444144411d000000000000d1777177c10011000010111111
33b33333333333331655665113b33bb13331333bb3331333914444144441115151555d1551ddd315144144111d000000000000d11c7177110111100051555d15
33333333333333331566555111bb3bb1333313bbb31133331415444454445441515555155155551511411114d00000000000000d11c111171111111151557715
33333b3333333333156566611b33bb3133331bbbbb1333331114444444441451101111011011110141111144d00000000000000d7111717c0001110010166771
333333b33333333316656551133b33313331bbb33bb133331144444114414441ddd00ddd3330033344111144d00000000000000dcc1177cc00001100ddd8e67d
33333333333333331111111111111111311b33bb33bb13331441444114444441555115555551155544411144d00000000000000dc771c77c000011005558e675
333333334444444446444444001111001bbbb33bbbbbb1139114454141144441010000100111011111111111551dddddddddd155ccc1cccc11111111118eee61
3888333344444444454444440199991031333bbbb3bbbb31914444444411544114111141000000001555555151d1111111111d15cdd0dccc15115d5119eeee91
38a8bb334444444444444644194444913311bbbbb333311314444155555554411444444110111011155555511d155551155551d1101111111d515d51199ee991
3888b333444444444444454414455441331bbbb3bbbbb13314114415155514411411114100000000155555511d154451154451d1c1cccd1c15d1551111999911
333b999344444444444444441551155131bb33bbbbbbbb139114111515511111141111411110111015555551d15445111154451dc1cccc1c1151111119e55e91
33bb9a934444444444446644199119911333bbbbb3333bb19991991515155199144444410000000015555551d15455111155451d101111011111115111eeee11
3333999344444444444455440199991031111144411111139911115555555519141111411011101115555551d14454511545441dddd00ddd1511115111888811
3333333344444444444444440011110033333311133333339155555555511551010000100000000011111111d15444411444451dccc11ccc1111111111111111
999999999999999977711177777777777777771117777777dddd111111111ddd7777777711111111155555519999119999911999cdddc555511115d511111111
939999999999999977177717777777777777717771777777ddd13331333331dd7677777755555555155555519191511999155199ccccccccd5115d5511111111
993999999999999971777771777777777777177377117777dd1333333333331d7777667755555555155555511511515191555519dc555cddd5115ddd11111111
999999999999999917711111777777777771333773331777d13333333333331d7776677755555555155555519151551915d5dd51cccccccc5111155555166155
99999999999999991771515177777777777717777711777713333333331333317777777755555555155555519915519915555551555cdddc1111111122522522
99993939999999991715666177777777777713337317777713331113333333317776777755555555155555519991519915dd5d51cccccccc5551115566155166
99999399999999991165655177777777777133333331777713335551313313317677776755555555155555519915551915555551dc555cddddd5115d11111111
99999999999999991111111177777777711733773333177713335551333313317777777711111111155555519991119911111111cccccccc55d5115d11111111
32333333ddd1dddd32333333c2dccddc177773377777711713131555331313315551455555646555771111779999999999911999011101110111011100000000
32333233dd151ddd3233323cc2ddd2dd713333373377773113133153311331315dd176555d707655717777172499499991155119000500000000000000000000
33233233ddd151dd332332ccdd2dd2cd771133333333311713113113355331311022922111292221717777719994299915555551101110111011101100000000
33333333d111151d33ccc2c3ddddd2dd7713333333333177131d1d13355531315269a725626a9726177777719924929915555551000000000000000000000000
323333231555555132cc3cc3dddddddd7177333333777717d1dddd133511311d516a86256268a626117177719999229491155119111011101110111000000000
3323232315115551cc232c23cd2d2d2c1333377733333771dddddd15351531dd102ee201112ee211171311719924494299155199000000000000000000000000
33333233155555513333323ccdddd2dd7111114441111117dd1111555555351dddd0edddddd0eddd113b33119999949999155199101115111011101100000000
333333331111111133333333dccccccc7777771117777777d1555555555115515551155555511555111111119429999999911999500000000000000000000000
44540414140534959534050414044454262626363686368636868636362626262626363636263636368636362636362634050434343414041514343434141434
44543405141414141414141414144454a5d7d7d7d7d7d7d7d7d7d7d7d7d7d7a50000000000000000000000000000000000000000000000000000000000000000
45551404041405959505140414144555262636368636863686368686363686262626868636363636368686863636362634051414141414142514141414040534
4555141414141414141414041414455594d7d7d7d7d7d7d7d7d7d7d7d7d7d7940000000000000000000000000000000000000000000000000000000000000000
25152525152515151525152525152525368686863686868636363686863636863686368636863686368636363636368614142525141414251515251404142515
14041414140414141404141414140414d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d70000000000000000000000000000000000000000000000000000000000000000
15252525152525151525151525251515863686363686368686363636363636368686863636363636863636868686363625150415251525150414152525151504
04141404141414141414141414041404d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d70000000000000000000000000000000000000000000000000000000000000000
44541404141414040404141414054454263636363686368686868686863686262626368686862686363636363686362634051414141404151404141405141434
44540414141444541404041444544454a5d7d7d7d7d7d7d7d7d7d7d7d7d7d7a50000000000000000000000000000000000000000000000000000000000000000
45551405041404142514040514144555268686863636363636868636368636262626363636363686363626363636362634141434343414152514343434041434
45550504140445551414141445554555a6d7d7d7d7d7d7d7d7d7d7d7d7d7d7a60000000000000000000000000000000000000000000000000000000000000000
44541414140514141514141404144454268636368686368686363636363626262626262636363636363636363686362634050434343414041514343434051434
44544454445404141414140544544454a6d7d7d7d7d7d7d7d7d7d7d7d7d7d7a60000000000000000000000000000000000000000000000000000000000000000
45550504041414152514140404044555262636363636363636363686362626262626268686863636363636363636262634141404141414251514041404140434
45554555455514140414143445554555a6d7d7d7d7d7d7d7d7d7d7d7d7d7d7a60000000000000000000000000000000000000000000000000000000000000000
44544454445414041404445444544454262626263636868636368636262626262626268686363636363636868636262634041414051404251514040504141434
44544454445404141414445444544454a6d7d7d7d7d7d7d7d7d7d7d7d7d7d7a60000000000000000000000000000000000000000000000000000000000000000
45554555455534251434455545554555262626262626263636262626262626262626262626262636862626262626262634343434343434042534343434343434
45554555455534041434455545554555a59696969696a5d7d7a59696969696a50000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000111111110000111000111100001100000011000000110000001000000010000000100000
0000000000000000000000000000000000000000000000000000000011122111001101100110110001bb100001bb100001bb1000015110000151100001511000
00000000000000000000000000000000000000000000000000000000112c721101000011010000101b3381101b3381101b338110166681101666811016668110
0000000000000000000000000000000000000000000000000000000012c2272111000000110000001b3333b11b3333b11b3333b1166666511666665116666651
0000000000000000000000000000000000000000000000000000000012c22c2111111100111111101b3331101b3331101b333110176661101766611017666110
00000000000000000000000000000000000000000000000000000000112cc21111118000111180011333bb101bb333101b3b3100156656101556651015656100
000000000000000000000000000000000000000000000000000000001112211101111001111110000131b10001b133100133b100015161000161551001665100
00000000000000000000000000000000000000000000000000000000111111111010111001011100001010000010110000111000001010000010110000111000
00111100014444100000000000000000000111111111100000000111100000000000000000000000000000000000000000000000000000000000000000000000
01d66d10144544200000000000000000001dddd1ddddd10000011555511100000000000000000000010000000000001000000000000000000000000000000000
15d66d5114555421000000000000000001d11dd1ddd11d100015666666551000000011111111000017100000000001c100000000000000000000000000000000
15d77d511445442100000000000000001dddd155551dddd11156665666665100000133333333100017c10000000017c100000000000000000000000000000000
157887511444442100000000000000001dddd511115dddd1155666565656510000133222322331001cc11111111117c100000000000000000000000000000000
1d6886d11444224100000011110000001ddd51111115ddd1156666555665651001333333332333101111711cc11c111100000011110000000000001111000000
01dddd100142241000001199991100001115111111115111156565111566655113333333113233311cc177c11ccc17c100001155551100000000115555110000
001111000014410000119a4444a911001dd5111111115dd1155551111156565113233133113232311771c111111c17c100115551155511000011555aa5551100
000000000001100001994aaaaaa499101dd5111111115dd1156611111111565113331131111333211c7c1111111177c101551555555155100155155555515510
00000000001dd10019444a5555a444911dd51a1111a15dd115651a1111a1655112231a3111a313311cc11a1111a11cc1151551111115515115a5511111155a51
0000000001d11d1019445999999544911dd51aaaaaa15dd115651aaaaaa1555112331a3aaaa313311cc11aaaaaa11cc111511555555151111a5a1aaaaaa15aa1
00000000151555d1195559555595559111511a5555a1151115661a5555a1655113311a5555a113211cc11a5555a11c71151551111115515115a5511111155a51
000000001d51515101991441144199101d515999999515d1155159999995155113315999999513211c71599999951c7101551551555155100155155a55515510
000000001d55155100119911119911001d515555555515d1155155555555155113315555555513211c71555555551c71001155551555110000115555a5551100
0000000015d555d10000119999110000155111555511155115511155551116511321115555111331171111555511117100001151551100000000115a55110000
00000000011111100000001111000000111111111111111111111111111111111111111111111111111111111111111100000011110000000000001111000000
00000000000000000000000000000000000000000000000000111100001111000001110055555555515555150001100001111110011111100000000000111000
0000000000000000000000cccc0000000000000000c0000001d66d10019899100018881051555515161551610015510014d66d4114d66d410001110001338100
000000000000000000000cccccc0000000000c000000000015d66d5118899a9100011891111551111d1551d10166651001adda1001adda100113381001333310
00000000000000000000c0c7c0c0000000000007c000000015d66d511811a7a10001198151555515515555151555655115dccd1001dccd101313333101bb1000
000000000000000000000c07c0000000000000cccc000000156116511811aaa1001aa991555555555155551516666561156dd610156dd6511b1bb11001133100
000000000000000000000007c0c0c000000000cc7c00000015d11d5101001110001a7a915155551516155161015656100166665115666651131133101311bb10
0000000000000000000c0c0cc00000000000000c700000000155551000000000001aa910111551111d1551d1001561000011dd5101dddd101b33bb101b3b3310
00000000000000000000000cc00c00000000c00c7000000000111100000000000001110051555515515555150001100000001110001111000111110001111100
00000000000000000011c11cc11111000011111cc1c1c10000000000010000000111111001111110011111100001100000011000000110000001100000011000
00000000000000000155555c755555100155555cc555551000100000171111001cccccc11cccccc11cccccc10018c1000018c1000018c1070018c1000018c100
0000000000000000155c7ccccc7c75511557c7ccc7c7c55101a1100001a7cc101c1111c11c1111c11c1111c171ccbc1001ccbc1001ccb77001ccb71001ccbc10
0000000000000000155cccc7ccccc551155c7cc7ccccc551001c710001cacc101c8118c11c8118c11c8118c107788c8101788c8101b8877101b8877101b88c81
000000000000000016555cccccc5556116555cccccc55561001ac10001ccac101cc11cc11cc11cc11cc11cc1177cbcb1177cbcb118cc7cb118ccbcb118ccbcb1
000000000000000001d5555555555d1001d5555555555d100001171001cc7a101cccccc11cccccc11dccccd11b878bc11b8c8bc11b8c8bc11b8c8bc11b8c8bc1
0000000000000000001d66dddd66d100001d66dddd66d10000000100001111711cdccdc11dccccd11cccccc11c8bc8811c8bc8811c8bc8811c8bc8811c8bc881
00000000000000000001111111111000000111111111100000000000000000100111111001111110011111101111111111111111111111111111111111111111
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010000010001000000000101010100000100000101000000010001010101000101010100010000010000010101010101010001000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
444544454445435152434445444544454a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a5a69696969695a59595a69696969695a6465646564657a68637a6465646564656465646564657a63687a6465646564656465646564657a63637a6465646564654647464746476b61616b4647464746474647464746476b7b606b464746474647
545554555455405141415455545554554a4a4a0000000000004a4a4a4a4a4a4a6a48484848484859594848484848486a7475747574756368686874757475747574757475747563686368747574757475747574757475636868637475747574755657565756577b60606156575657565756575657565760607b6b565756575657
444543414141415151414141434344454a4a4a0000000000000000004a4a4a4a6a59595959595959595959595959596a64657a636363686363637a7a7a63646564657a686868686368636868687a646564656465646563686363637a6465646546476b6161616161606161617b6b4647464746477b7b60614647464746474647
545541414141414152414141414354554a4a00000000000000000000004a4a4a6a59595959595959595959595959596a747563636863686363636363687a747574756840416863636368684168637475747574757475636368686863747574755657617b616061616161616160615657565756577b6061615657565756575657
444541414141404151404141414144454a0000000000000000000000004a4a4a5a59595959595959595959595959595a646568636368636363686363637a646564656868686868686868414068686465646564657a686868684068636465646546477b616161607b7b606161606146474647464746477b61617b46476b6b4647
545541414141415151414140414154554a0000000000000000000000004a4a4a4859595959595959595959595959594874756363686363636368686363637475747563686840684040686868686374757475747563684041404168637475747556577b616060616161616060617b56575657565756576160616156577b7b5657
514041414150415152515151525152514a0000000000000000000000004a4a4a595959595959595959595959595959596368636363636363636368636363636863686868684141414141684068686868636868636368686841686868636868686061616061616161607b7b606160617b617b617b61607b61617b7b617b607b61
515152515151515251525251515251524a0000000000000000000000004a4a4a59595959595959595959595959595959686363636363636368686863636368686868414140686840414140416868414168686363636840686841406863686363617b616060606060617b61616161617b616061616161616060607b616161617b
444541525152515141414141414144454a0000000000000000000000004a4a4a5a59595959595959595959595959595a64656368636863636363636363636465646568686868686868686840686364656465646564656841414068686363646546477b6161606061616161616061464746477b6046476061617b464746474647
545541414141415151404040414154554a4a4a0000000000000000004a4a4a4a6a59595959595959595959595959596a74757a7a636363636363636363637475747563686368686863636868686374757475747574756868686868636863747556577b7b7b61616161616161607b565756576b6b56577b616161565756575657
444541414141415252404050504144454a4a4a4a4a4a000000004a4a4a4a4a4a6a59595959595959595959595959596a646563687a63686363636363637a646564656368686868636368686863636465646564657a63636863636465636364654647606161606161606061616161464746474647464746476161607b46474647
545541414141415152504141414154554a4a4a4a4a4a0000004a4a4a4a4a4a4a6a59595959595959595959595959596a74757a7a7a636363686863637a7a747574757a636363686868686863637a7475747574756368686863687475637a747556576b7b61617b6160616160607b56575657565756575657617b616156575657
444544454445415241414445444544454a4a4a4a4a4a0000004a4a4a4a4a4a4a6a59595959595959595959595959596a6465646564656368636364656465646564656465646568404140646564656465646564656465636368636465646564654647464746476160617b4647464746474647464746476b7b6061464746474647
545554555455435252435455545554554a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a5a69696969695a59595a69696969695a7475747574757a63687a7475747574757475747574757a68417a7475747574757475747574757a68637a7475747574755657565756576b61606b5657565756575657565756576b617b6b565756575657
43434343434343515143434343434343424242424242425152424242424242424242424242424251514242424242424266676667666771414171666766676667666766676667714141716667666766676b6b6b6b6b6b6b61616b6b6b6b6b6b6b4d4d4d4d4d4d4d6d6d4d4d4d4d4d4d4d5e5e5e5e5e5e5e4e4e5e5e5e5e5e5e5e
43434141414143524143414141414343424242425151515151424242424242424242424252525151525151515142424276777677767772417072767776777677767776777677734170737677767776776b46476061616160616161616046476b4d5d5d5d5d5d5d6d6d5d5d5d5d5d5d4d5e6e6e6e6e6e6e4e4e6e6e6e6e6e6e5e
43414141414141514141414141414143424242525152515251424242424251424242515151515151515252525151424266677373727241704172737373736667666766676667737041726667666766676b56577b7b6160617b6161606156576b4d6d6d6d6d6d6d6d6d6d6d6d6d6d6d4d5e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e
43414141434141415241414143414143424251515151515142424242515151424251515151425151515151515252424276777373724141414170727373737677767776777677414141727677767776776b617b6161616161616061617b617b6b4d6d6d6d6d6d6d6d6d6d6d6d6d6d6d4d5e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e
43414141414141415141414141414143425151515251515242424242515251424251525151515152515151515252514266677272414141414141417272726667666766677372724141736667666766676b6160616c61617c61616c616161616b4d6d6d6d6d6d6d6d6d6d6d6d6d6d6d4d5e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e
43414141415152524141414141414143425151525151525151525251515151424251515152525151515152515151514276777241414141414141414170727677767776774141414141737677767776776b61616152616152616152617b60616b5d6d6d6d6d6d6d6d6d6d6d6d6d6d6d5d6e4e4e4e4e4e4e4e4e4e4e4e4e4e4e6e
5141525151524151414152515152514151515251425151515151515151525152515151515251515251515151515152514141414141414172414141414141417273737273414141414141727372727273616160616161616161616161616161616d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e
525152414141435152514152415241525152515151515251515252515151515151525151525151515151515142515151414141414141417072414141414141417372737273724172414141417373727360617b6160616161607b6161606160616d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e
43414141414141414141414141414143425151515251515151425151515251424251515151515151525151515151514266677241414141414141417041726667666766676667734141414173666766676b61606161617b616161616161617b6b4d6d6d6d6d6d6d6d6d6d6d6d6d6d6d4d5e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e
43414141414141414143414143414143425252515152515252515151514242424242525151525151515151515251514276777341704141414141414141737677767776777677734141414172767776776b6160617c61616c61617c616161616b4d6d6d6d6d6d6d6d6d6d6d6d6d6d6d4d5e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e
43414143414141414141414141414143424242515152524251515151514242424242525142515151514251515151424266677372414141414141414172736667666766676667724141414173666766676b61616152616152616152617b61606b4d6d6d6d6d6d6d6d6d6d6d6d6d6d6d4d5e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e
43414141414141524141414141414143424242425251515151525142424242424242425151515151525151515142424276777373727241414141727273737677767776777677724141417273767776776b7b7b616161616161616161607b616b4d6d6d6d6d6d6d6d6d6d6d6d6d6d6d4d5e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e
43434141414141514141414141414343424242424242515152515142424242424242424252515151515151524242424266676667666772414172666766676667666766676667734141726667666766676b6061607b616160616161616161606b4d6d6d6d6d6d6d6d6d6d6d6d6d6d6d4d5e4e4e4e4e4e4e4e4e4e4e4e4e4e4e5e
43434343434343414143434343434343424242424242425251424242424242424242424242424251524242424242424276777677767771414171767776777677767776777677714141717677767776776b6b6b6b6b6b6b7b616b6b6b6b6b6b6b4d4d4d4d4d4d4d6d6d4d4d4d4d4d4d4d5e5e5e5e5e5e5e4e4e5e5e5e5e5e5e5e
5a69696969696969696969696969695a626262626262626363626262626262626262626262626263686262626262626243434343434343514043434343434343444544454445434140434445444544455a69696969695a7d7d5a69696969695a0000000000000000000000000000000000000000000000000000000000000000
484848484848484b4c48484848484848626262626262626368636262626262626262626263636363636363636363626243504141505041524041404141505043545554555455504041415455545554556a4949494949497d7d4949494949496a0000000000000000000000000000000000000000000000000000000000000000
44454343434343595943434343434445626262626262636368636362626262626262626363636863636368636863636243414041504140525241414141405043444544454141414140414044454344456a7d7d7d7d7d7d7d7d7d7d7d7d7d7d6a0000000000000000000000000000000000000000000000000000000000000000
54555050505050595950505050505455626262626263686363686363686262626262636863636363686363636363636243414143434341415141434343414143545554554041404140414154555054556a7d7d7d7d7d7d7d7d7d7d7d7d7d7d6a0000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001656014560115600f5600b5000b5001250004500005000e5000c5000950006500025000150001500000001c3001b3001b3001a3001a3001a300000000000000000000000000000000000000000000000
01050000045600450004560045000556005500055600650007560095000a5600c5000d5600e5000e5600f50010560115001156019500125601e50014560000001556000000165600000000000000000000000000
0102000013560145001656017500185601a5001b5601c5001d56020500235602a5003156033500395603950039560395003956039500395603950039560395003956039500395603950039560395003956039500
010200002856027560265602456023560215601f5601d560175001050009500075000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000008050110503e650392503d650352503665030250326502c2502c65025250266502025022650194501b65013440156400b4300b6300642003620004100061000000000000000000000000000000000000
01010000000001306013060130601206011050100500f0400a0400803016000000001600016000000001600016000160001600017000160001400013000120001100010000100001000000000000000000000000
000100001366013660090600906009060090600906004060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000265601c530265601c530265601353021560105301b5600b530175600b530175600b530175000b50017500000000000000000000000000000000000000000000000000000000000000000000000000000
000200003376033760337603976039760397600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200003376033730397603973039760397303976039730397603973039760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200003376033730397603973039760397303976039730397603973039760397303976039730397603973039760397303976039730397600000000000000000000000000000000000000000000000000000000
01040000337603373039760397303f760397303f760397303f760397303f760397303f760397303f760397303f760397303f760397303f760397303f760397303f760397303f760397303f760397303f7603f730
00010000100601006010060100601006010060170601706017060170601c0601c0601c0601c0601c0602b00029000260002500000000000000000000000000000000000000000000000000000000000000000000
01080000390603c0603c0603c0503c0503c0403c0403c0303c0203b0003b0003c0003c0003c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003001d0f0500f0500f0500f05000000000000f0500f0500f0500f05012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400003761034f1034f100ae600de6017e6021e6022e600c6600b6600a6600a6400863005620046100261001610006100061001600016000060000600006000060000600006000060000600006000060000600
000600001f660116000b600156001365014600146000c6000b6400360004600036000063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000900002606026060270602706026060260602b0602b0602a0602a0602d0602d0600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300003f730109603f730129603f730169603f7301a9603f7301f9603f730239603f730269603f7302b9603f7302f9603f730329603f730359603f730379603f73000000000000000000000000000000000000
0002000006560095600b5600f56010560105600e5600d5600c560095600756007560085600b5600f56012560135601356012560105600b5600a5600956008560095600e560105601256015560175601856018560
000400003441034410344103442034420344203443034430344403444034450344603446034460344503444034410020000200001000010000400007000050000500007000080000c0000f0000f0000f0000f000
011400000902009020090200902009020090200902009020090200902009020090200902009020090200902007020070200702007020070200702007020070200702007020070200702007020070200702007020
011400001c5201c520215202152026520265202552026520255202552021520215201c5221c5221c5221e5201f5201f5201a5201a520245202452023522235222352223522235222352223522235222352223522
011400001553215532155321553215532155321a5321753219532195321c5321c532195321953219532175321a5321a53213532135321f5321f5321a5321a5321a5321a5321a5321a5321a5321a5321a5321a532
011400000502005020050200502005020050200c0200e020110201102011020110201102011020100201102013020130200e0200e020090200902007020070200702007020070200702007020070200702007020
01140000215221d5221a522185221d5221f52221522215222152221522215222152221522215221f52221522235222352221522215221f5221f5221a5221a5221a5221a5221a5221a5221a5221a5221a5221a522
01140000155321553215532155321553215532135321553218532185321853218532185321853217532185321a5321a5321353213532185321853217532175321753217532175321753217532175321753217532
011c00001f7351f7353b5151a7351d7351c7351f7353b5153b515217351c7351a735000053b5153b5153b515000053b515000053b5153b51520735187353b515237353b515237353b515217353b5153b5153b515
011c0000070320703207032130323b5150e03211032100320c0323b5150e0323b515070320000200002000020803200002140320803200002080320303208032080320000208032000020f03208032000000a032
011c00000c04300003000033c6153c6000c0430c043000030c0430000300003000030c0430000300003000030c04300003000033c6153c6000c0430c043000030c0430000300003000033c625000030000300003
01110000105301053010530105301053010530105301053010530005000d5301053015530155300d5300d530105301053010530105301053010530105301053010530005000d5301053015530155300d5300d530
011100000903000000090350903509035000040903509035090350000009035090350903500000090350900007035000000703507035070350000007035070350703500000070350703507035000000703507000
011100001053010530105300e5300e5300e5300d5300d5300b5300b5300b5300b530095300953009530095301153011530115301053010530105300e5300e5301353013530135301753017530175301a5301a530
011100000603500000060350603506035000000603506035060350000006035060350603500000060350600005035000000503505035050350000005035050350403500000040350403504035000000403504000
011100001553015530155301553015530155301553015530155302150013530155301753017530135301353015530155301553015530155301553015530155301553021500135301553017530175301353013530
011100000503500000050350503505035000000503505035050350000005035050350503500000050350000007035000000703507035070350000007035070350703500000070350703507035000000703500000
0111000024520245202452223520235202352021520215201f5201f5201f5221f5221a5201a5201a5221a52224520245202452223520235202352221520215202652026520265222452024520245222352023520
011100001c5201c5201c5201c5201c5201c5201c5221c5221c522005001c5201c5201a5201a52018520185221f52000500005001a5251a5201a5201a5201a5221a5221a5221a522005001a5201a5201c5201c520
011100001d5201d5201d5201d5201d5201d5221d5221d5221d5220050020520205201f5201f5201d5201d5222452000500005001f5251f5201f5221d5201d5201c5201c5221c5221c5251c5201c5201c5221c522
011100001d5201d5201d5201d5201d5201d5201d5221d5221d5220050020520205201f5201f5201d5201d5221c52000500005001d5201f5201f5201f5201f5201f5221f5221f522005001c5201c5201c5221c522
011100001e5201e5201e5201e5201e5201e5201e5221e5221e52200500215202152020520205201e5201e5221c52000500005001e520205202052020520205202052220522205222052220522205220050000500
011100000c035000000c0350c0350c035000000c0350c0350c035000000c0350c0350c035000000c0350000007035000000703507035070350000007035070350703500000070350703507035000000703500000
01110000050350e000050350503505035090000503505035050350e00005035050350503509000050350c0000c0350c0000c0350c0350c035070000c0350c0350c035000000c0350c0350c035000000c03500000
011100000b035000000b0350b0350b035000000b0350b0350b035000000b0350d0350f035000000b03500000100350000010035100350e035000000e0350e0350d035000000d0350d0350b035000000b03500000
0111000000700000001c5251c5251c52515525195251c520215202152021520215202152221522215222152200700007001c5251c5251c52515525195251c5202152021520215202152021522215222152221522
0111000000000217352173521735000001e7351e7351e735000001a7351a7351a73500000157351573515735000001d7351d7351d735000001a7351a7351a735000001f7351f7351f735000001a7351a7351a735
0111000000000000001d5251d5251d52515525185251d520215202152021520215202152221522215222152200500005001f5251f5251f5251a5251f525245202352023520235202352023522235222352223522
01110000217202172021720217202172021720217202172021720000001f72021720237201f7201a7201772015720157201572015720157200000015720177201372013720137201372013720137201372013720
0111000018520185200000013525135201352010520105200c5200c5200c52010520135201352013520135251752017520000001352513520135200e5200e5200b5200b5200b520000000b5200b5200c5200c520
01110000155201552000000115200c5200c520115201152009520095200b5200b5200c5200c5200c5200c5250c5200000018525185251852513520185201c5201f5201f5201f5201f5201f5201f5201f52000000
0111000017520000001752517525175201752517520195201b5201b52017520175201452015520175201752014520000000000015520175201752017520175201752217522175221752217522175221752217522
011a00000753007530075300753007520075200752007520075100751007510075100751007510035000000003530035300353003530035200352003520035200351003510035100351003510035100000000000
011a00000253002530025300253002520025200252002520025100251002510025100251002510133000250003530035300353003530035200352003520035200351003510035100351003510035101330000000
011a00001331513710133151371013315137101331513710133151371013315137101331513710133151371013315137101331513710133151371013315137101331513710133151371013315137101331513710
011a00001a3151a7001a3151a7001a3151a7001a3151a7001a3151a7001a3151a7001a3151a7001a3151a7001a3151a7001a3151a7001a3151a7001a3151a7001b3151b7001a3151a7001d3151d7001b3151b700
011a00001331513710133151371013315137101331513710123151271012315127101231512710123151271013315137101331513710153151571015315157101631516710163151671016315167101631516710
011a00001a315000001a315000001a315000001a315000001a315000001a315000001a315000001a315000001b315000001b315000001b315000001b315000001d315000001d315000001b315000001b31500000
011a00000c0230000000000396003960000000000000c0230c023000000000000000396000000000000000000c0230000000000000003960000000000000c0230c02300000000000000039600000000000000000
011a00000c0230000000000396002961500000000000c0230c023000000000000000296150000000000000000c0230000000000396002961500000000000c0230c02300000000000000029615000000000000000
000300000963009630096300963009630096300963009630306303063030630306303060030600306003060000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000001310013300f3000f3400c33007320023100a3000a3100632001310003100330006320033100031005300023000030000300003000030000300003000030000300003000030000300003000030000300
000700000761006620046300262001610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 15 16 17 44
02 18 19 1a 44
03 1c 1b 1d 44
01 1f 1e 2c 44
00 21 20 2d 44
00 23 22 2e 44
00 23 24 2f 44
00 29 25 30 44
00 2a 26 31 44
00 2a 27 31 44
00 2b 28 32 44
00 29 25 30 44
00 2a 26 31 44
00 2a 27 31 44
02 2b 28 32 44
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
00 33 35 43 39
00 33 35 43 39
00 34 37 43 39
00 34 37 43 39
01 33 35 36 3a
00 33 35 36 3a
00 34 37 38 3a
02 34 37 38 3a
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
