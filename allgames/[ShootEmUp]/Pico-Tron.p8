pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--pico-tron v1.1
--2020 @exquisite_bytes

function _init()
 --1=menu,2=ingame,3=gameover,
 --4=ending
 cartdata("pico-tron")
 saved_score=dget(0)
 hiscore,score,shake=0,0,0
 if(saved_score!=nil) hiscore=saved_score
 gamestate=1
 init_keys()
 stg_init()
 pl_init()
 mons_init()
 en_init()
 sf_init()
 pr_init()
 sc_init()
 ed_init()
 bg_init()
 dust,life1,life2,life3={},"‡","‡‡","‡‡‡"
end

function _update60()
 flash_col=rand(5,13)
 if gamestate==1 then
  me_update()
 elseif gamestate==2 then
  upd_keys()
  if(shadows_alive>0) sh_update()
  stg_update()
  pl_update()
  en_update()
  mons_update()
  pr_update()
  sc_update()
  for _,d in pairs(dust) do
   d:update()
  end
 elseif gamestate==3 then
  go_update()
 else
  ed_update()
 end
end

bg_tick,b_col=0,0
--test=""

function _draw()
	if gamestate==1 then
	 if rx0<1 then
	  cls(9)
	 else
	  cls(0)
	 end
	 me_draw()
	elseif gamestate==2 then
	 if current_stage==21 then
	  bg_tick+=1
	  if bg_tick==3 then
	   b_col=rand(3,15)
 	  bg_tick=0
 	 end
 	 cls(b_col)
	 else
	  cls(bg_cols[current_stage])
	 end
  if(shake>0)	doshake()
 	pr_draw()
 	pl_draw()
 	mons_draw()
 	en_draw()
 	sc_draw()
 	--print(test,0,110,7)
 	for _,d in pairs(dust) do
   d:draw()
  end
 	--outline(str,x,y,font-color,outline-color)
 	if pl.lives==1 then
 	 outline(life1,-1,0,1,7)
 	elseif pl.lives==2 then
 	 outline(life2,-1,0,1,7)
 	elseif pl.lives==3 then
 	 outline(life3,-1,0,1,7)
 	end
 	outline("stg "..current_stage,31,0,1,7)
  outline("sc "..score,63,0,1,7)
  outline("hi "..hiscore,99,0,1,7)
  --print('mem:'..stat(0),0,120)
  --print('cpu:'..stat(1),53,120)
  --print('fps:'..stat(9),100,120)
 elseif gamestate==3 then
  cls(0)
  go_draw()
 else
  cls(0)
  ed_draw()
 end
end

function update_score(s)
 score+=s
 if(score>hiscore) hiscore=score
end

function rand(a,b)
 if (a>b) a,b=b,a
 return a+flr(rnd(b-a+1))
end

function rand_from_list(list)
 return list[rand(1,#list)]
end

function hcenter(s)
 return 64-#s*2
end

function lerp(target,pos,perc)
 return (1-perc)*target+perc*pos
end

function doshake()
 --how many pixels in each 
 --direction that screen will
 --shake (between -6 and +6)
 local shakex=6-rnd(6)
 local shakey=6-rnd(6)
 --apply shake strength
 shakex*=shake
 shakey*=shake
 camera(shakex,shakey)
 --gradually diminish
 shake=shake*0.95
 if (shake<0.05) shake=0
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

function intersect(rect1,rect2)
 if (rect1.x < rect2.x + rect2.w and
  rect1.x + rect1.w > rect2.x and
  rect1.y < rect2.y + rect2.h and
  rect1.y + rect1.h > rect2.y) then
   return true
 else
  return false
 end
end

--line/rect intersect by aek
function line_rect_intsect(x0,y0,x1,y1,l,t,r,b)
 local tl,tr,tt,tb=
  (l-x0)/(x1-x0),
  (r-x0)/(x1-x0),
  (t-y0)/(y1-y0),
  (b-y0)/(y1-y0)
 return max(0,max(min(tl,tr),min(tt,tb)))<
        min(1,min(max(tl,tr),max(tt,tb)))
end

--draws a sprite to the screen with an outline of the specified colour
function ospr(n,col_outline,x,y,w,h,flip_x,flip_y,c1,c2)
 --reset palette to black
 for c=1,15 do
  pal(c,col_outline)
 end
 --draw outline
 for xx=-1,1 do
  for yy=-1,1 do
   spr(n,x+xx,y+yy,w,h,flip_x,flip_y)
  end
 end
 --reset palette
 pal()
 --draw final sprite
 if c1==nil then
  spr(n,x,y,w,h,flip_x,flip_y)
 else
  pal(c1,c2)
  spr(n,x,y,w,h,flip_x,flip_y)
  pal()
 end
end
-->8
--player
pl={
 x=0,
 y=0,
 state=1,
 sprite=0,
 anim_time=0,
 move_dir=ƒ,
 crect={x=0,y=0,w=3,h=3},
 crect2={x=0,y=0,w=7,h=8},
 lives=0,
 invincible=false,
 col=0, --colour
 bdir=1
}
--shot_dir:
--1=left
--2=up+left
--3=up
--4=up+right
--5=right
--6=down+right
--7=down
--8=down+left

function pl_init()
 timer,tick,shot_timer=0,0,0
 alt_sprites={119,120,121,122,123,124,125}
end

function pl_setup()
 pl.x=60
 pl.y=-10--60
 pl.state,pl.tick,pl.sprite=0,0,0
 pl.alive=true
 pl.invincible=false
 pl.shot_dir=2
end

function pl_hit(o)
 if pl.invincible then
  explo2(o)
 else
  explo1(o)
  pl_destroy()
 end
end

function pl_destroy()
 sfx(8)
 shake+=1
 explo1(pl)
 pl.alive=false
 pl.lives-=1
 pl.state=1
 pl.x=0
 pl.y=-9
 if pl.lives<0 then
  pl.alive=false
  music(-1,2724)
  stg_state=5
 else
  pl.invincible=true
  timer=time()
  pl.state=2
 end
end

function pl_update()
 if pl.state==2 then
  --waiting to respawn...
  if time()-timer>1.02 then
   pl.state=1
   pl.alive=true
   pl.x,pl.y=60,66
   timer=time()
  end
  return
 end
 
 if pl.invincible then
  --player invincible
  pl.col=rand(0,15)
  if time()-timer>1.99 then
   pl.state=1
   pl.invincible=false
  end
 end
 
 if(not pl.alive or stg_state==2) return

 pl.tick+=1
 if pl.tick==6 then
  pl.tick=0
  pr_spawn_pl_bullet(pl.x-2,pl.y,pl.bdir)
 end
 
 if is_pressed(Ž) then
  pl.bdir-=1
  if(pl.bdir<1) pl.bdir=8
 elseif is_pressed(—) then
  pl.bdir+=1
  if(pl.bdir>8) pl.bdir=1
 end
 
 if btn(”) and btn(‹) then
  pl.x-=1
  pl.y-=1
  pl_anim(1)
  if(pl.x<1) pl.x=0
  if(pl.y<8) pl.y=8
 elseif btn(”) and btn(‘) then
  pl.x+=1
  pl.y-=1
  pl_anim(1)
  if(pl.x>120) pl.x=120
  if(pl.y<8) pl.y=8
 elseif btn(ƒ) and btn(‹) then
  pl.x-=1
  pl.y+=1
  pl_anim(2)
  if(pl.x<1) pl.x=0
  if(pl.y>120) pl.y=120
 elseif btn(ƒ) and btn(‘) then
  pl.x+=1
  pl.y+=1
  pl_anim(2)
  if(pl.x>120) pl.x=120
  if(pl.y>120) pl.y=120
 elseif btn(‹) then
  pl.x-=1
  pl_anim(3)
  if(pl.x<1) pl.x=0
 elseif btn(‘) then
  pl.x+=1
  pl_anim(4)
  if(pl.x>120) pl.x=120
 elseif btn(”) then
  pl.y-=1
  pl_anim(1)
  if(pl.y<8) pl.y=8
 elseif btn(ƒ) then
  pl.y+=1
  pl_anim(2)
  if(pl.y>120) pl.y=120
 end
 pl.crect.x=pl.x+2
 pl.crect.y=pl.y+1
 pl.crect2.x=pl.x
 pl.crect2.y=pl.y-1
end

--anim dirs
--1=up+left/up/up+right
--2=down+left/down/down+right
--3=left
--4=right
function pl_anim(d)
 if d==1 then
  if time()-pl.anim_time>.14 then
   pl.anim_time=time()
   if pl.sprite!=3 and pl.sprite!=4 then
    pl.sprite=3
    return
   end
   if pl.sprite==3 then
    pl.sprite=4
   else
    pl.sprite=3
   end
  end
 elseif d==2 then
  if time()-pl.anim_time>.14 then
   pl.anim_time=time()
   if pl.sprite==1 then
    pl.sprite=2
   else
    pl.sprite=1
   end
  end
 elseif d==3 or d==4 then
  if time()-pl.anim_time>.14 then
   pl.anim_time=time()
   if pl.sprite==5 then
    pl.sprite=6
   else
    pl.sprite=5
   end
  end
 end
end

function pl_draw()
 if pl.alive then
  if pl.invincible then
   ospr(alt_sprites[pl.sprite+1],0,pl.x,pl.y,1,1,false,false,7,pl.col)
  else
   ospr(pl.sprite,0,pl.x,pl.y,1,1,false,false)
  end
 end
-- rect(pl.crect.x,pl.crect.y,
--      pl.crect.x+pl.crect.w,
--      pl.crect.y+pl.crect.h,
--      7)
-- rect(pl.crect2.x,pl.crect2.y,
--      pl.crect2.x+pl.crect2.w,
--      pl.crect2.y+pl.crect2.h,
--      7)
 --print('pl.bdir:'..pl.bdir,0,10,8)
end
-->8
--stages

--stg bg colours
st_timer,bg_cols,bg_col_defs=0,{},"090610120809071206090806121108120609071009"

--mons spawns for each stg
mon_spawns="656664656796598343960"
--wave defs (etype/qty)
stages={
 "w0106", --stg1
 "w0205", --stg2
 "w0103w0203", --stg3
 "w0403", --stg4
 "w0402w0106", --stg5
 "w0601w0106", --stg6
 "w0701w0104w0201", --stg7
 "w0701w0204w0108", --stg8
 "w0702w0207", --stg9
 "w1004w1401", --stg10
 "w1509w0104w1401", --stg11
 "w1201w0304w1504w1401", --stg12
 "w1208w0202w0701", --stg13
 "w0601ww0702w0902w1401", --stg14
 "w0701w0801w0302", --stg15
 "w0601w0904w0104w0202", --stg16
 "w0906w0801w0302", --stg17
 "w1101w1509", --stg18
 "w1102", --stg19
 "w0301w1101w0201w0401w0601w0701", --stg20
 "w1301" --stg21
}

function stg_init()
 current_stage,stg_timer=0,0
 for i=1,#bg_col_defs,2 do
  --test=test..sub(bg_col_defs,i,i+1)..","
  add(bg_cols,tonum(sub(bg_col_defs,i,i+1)))
 end
end

--must set current_stage
--before calling this
function stg_setup()
 en_setup()
 pr_setup()
 pl_setup()
 sc_setup()
 mons_setup()
 --spawn mons
 mons_to_spawn=tonum(sub(mon_spawns,current_stage,current_stage))
 spwn=1
 for i=1,mons_to_spawn do
  mon_spawn(spwn)
  spwn+=1
  if(spwn>4) spwn=1
 end
 --spawn enemies
 stg=stages[current_stage]
 for i=1,#stg do
  if sub(stg,i,i)=="w" then
   en=tonum(sub(stg,i+1,i+2))
   qty=tonum(sub(stg,i+3,i+4))
   for j=1,qty do
    en_spawn(en)
   end
  end
 end
 set_en_pos()
 stg_state,st_timer=0,time()
end

function stg_update()
 if stg_state==0 then
  --intro: spawn enemies onto
  --screen
  for egroup in all(enemies) do
   for e in all(egroup) do
    if e.alive then
     if(e.y<e.intro_dest_y) e.y+=4.98
     if e.etype==8 then
      --clone
      if(e.clone.y<e.clone_intro_dest_y) e.clone.y+=4.98
     end
    end
   end
  end
  --spawn mons onto screen
  for m in all(mons) do
   if m.alive then
    if(m.y<m.intro_dest_y) m.y+=4.98
   end
  end
  --spawn player onto screen
  if(pl.y<66) pl.y+=5.19
  --set state 1 when all spawned
  if(time()-st_timer>.41) stg_state=1
 elseif stg_state==1 then
  --enemies spawned
  --wait for all enemies to be
  --destroyed
  if enemies_alive==0 then
   stg_state,stg_timer=2,time()
   pr_setup()
  end
 elseif stg_state==2 then
  --despawn player
  pl.y-=2.98
  --despawn mons
  for m in all(mons) do
   if(m.alive) m.y-=4.22
  end
  if(time()-stg_timer>1.17) stg_state=3
 elseif stg_state==3 then
  --next stage
  if current_stage==21 then
   --goto end screen
   dset(0,hiscore)
   gamestate=4
  else
   current_stage+=1
   stg_setup()
   pl_setup()
  end
 elseif stg_state==5 then
  --all lives lost
  stg_timer,stg_state=time(),6
 elseif stg_state==6 then
  --goto game over screen
  if time()-stg_timer>2.92 then
   gamestate=3
   sfx(-1,2)
   sfx(-1,3)
   sfx(12)
  end
 end
end
-->8
--starfield
function sf_init()
 entitylist,star_count={},0
end

function sf_update()
 if star_count<85 then
  add(entitylist,{x=8+rnd(124),y=0,v=0.27+rnd(1.01),s=rand(245,246)})
  star_count+=1
 end
 for _,i in pairs(entitylist) do
  i.y=i.y+i.v
  if i.y>=128 then
   del(entitylist,i)
   star_count-=1
  end
 end
end

function sf_draw()
 for i in all(entitylist) do
  --pal(7,rand(1,15))
  pal(7,rand_from_list({5,8,10,11,12}))
  spr(i.s,i.x,i.y)
  pal()
 end
end
-->8
--ending
function ed_init()
 je_msg="well done!"
end

function ed_update()
 sf_update()
end

function ed_draw()
 sf_draw()
 --spr(ple.sprites[ple.spr_idx],ple.tween.value,ple.y)
 outline(je_msg,hcenter(je_msg),60,1,1+rnd(16))
 sc="score:"..score
 outline(sc,hcenter(sc),75,1,9)
 hi="new high score!"
 if oldhiscore!=hiscore then  
  outline(hi,hcenter(hi),90,1,12)
 end
end
-->8
--projectiles
bullets={}

function pr_init()
 for i=1,58 do
  bullet={
   alive=false,
   --x,y,btype,timer,col,vel,sprite,destx,desty=0,0,0,0,0,0,0,0,0,
   crect={x=0,y=0,w=2,h=2},
   bdir=1,
  }
  add(bullets,bullet)
 end
end

function pr_setup()
 for b in all(bullets) do
  if(b.alive) explo2(b)
  b.alive=false
 end
end

--btype=1 (player bullet)
function pr_spawn_pl_bullet(x,y,bdir)
 for _,b in pairs(bullets) do
  if not b.alive then
   b.alive=true
   b.x=x
   b.y=y
   b.btype=1
   b.bdir=bdir
   b.vel=4
   if bdir==1 then
    --left
    b.sprite=240
   elseif bdir==2 then
    --up+left
    b.y-=1
    b.sprite=241
   elseif bdir==3 then
    --up
    b.x+=1
    b.sprite=242
   elseif bdir==4 then
    --up+right
    b.x+=3
    b.sprite=243
   elseif bdir==5 then
    --right
    b.sprite=240
   elseif bdir==6 then
    --down+right
    b.x+=3
    b.sprite=241
   elseif bdir==7 then
    --down
    b.x+=1
    b.sprite=242
   elseif bdir==8 then
    --down+left
    b.sprite=243
   end
   return
  end
 end
end

--enemy bullets
function pr_spawn_shot(x,y,bdir,vel)
 for _,b in pairs(bullets) do
  if not b.alive then
   b.alive=true
   b.x=x
   b.y=y
   b.vel=vel
   b.btype,b.bdir=3,bdir
   if bdir==1 then
    --left
    b.sprite=229
   elseif bdir==3 then
    --up
    b.sprite=226
   elseif bdir==5 then
    --right
    b.sprite=227
   elseif bdir==7 then
    --down
    b.sprite=228
   end
   return
  end
 end
end

--enemy seeking bullets
function pr_spawn(x,y,destx,desty,vel)
 for _,b in pairs(bullets) do
  if not b.alive then
   b.alive=true
   b.x=x
   b.y=y
   b.destx=destx
   b.desty=desty
   b.btype=2
   b.vel=vel
   b.sprite=244
   b.timer=time()
   b.crect.w,b.crect.h=4,4
   return
  end
 end
end

function pr_update()
 for _,b in pairs(bullets) do
  if b.alive then
   if b.btype==3 then
    --enemy border shot
    proc_dirs(b)
   elseif b.btype==2 then
    --enemy seek bullet
    b.x=lerp(b.destx,b.x,b.vel)
    b.y=lerp(b.desty,b.y,b.vel)
    b.col=rand(4,13)
    if time()-b.timer>3.991 then
     pr_kill_bullet(b)
    elseif b.x<-8 or b.x>128 or b.y<5 or b.y>128 then
     pr_kill_bullet(b)
    end
   elseif b.btype==1 then
    --player bullet
    b.col=rand(6,8)--6+rnd(8)
    proc_dirs(b)
   end
   pr_collisions(b)
  end
 end
end

function proc_dirs(b)
 if b.bdir==1 then
  --left
  b.x-=b.vel
  if b.btype==1 then
   b.crect.x=b.x+2
   b.crect.y=b.y+3
  elseif b.btype==3 then
   b.crect.x=b.x+1
   b.crect.y=b.y+1
  end
 elseif b.bdir==2 then
  --up+left
  if b.btype==1 then
   b.crect.x=b.x-2
   b.crect.y=b.y-2
  end
  b.x-=b.vel
  b.y-=b.vel
 elseif b.bdir==3 then
  --up
  b.y-=b.vel
  if b.btype==1 then
   b.crect.x=b.x+3
   b.crect.y=b.y+2
  elseif b.btype==3 then
   b.crect.x=b.x+4
   b.crect.y=b.y+3
  end
 elseif b.bdir==4 then
  --up+right
  if b.btype==1 then
   b.crect.x=b.x+7
   b.crect.y=b.y-2
  end
  b.x+=b.vel
  b.y-=b.vel
 elseif b.bdir==5 then
  --right
  b.x+=b.vel
  if b.btype==1 then
   b.crect.x=b.x+2
   b.crect.y=b.y+3
  elseif b.btype==3 then
   b.crect.x=b.x+1
   b.crect.y=b.y+5
  end
 elseif b.bdir==6 then
  --down+right
  if b.btype==1 then
   b.crect.x=b.x+6
   b.crect.y=b.y+6
  end
  b.x+=b.vel
  b.y+=b.vel
 elseif b.bdir==7 then
  --down
  b.y+=b.vel
  if b.btype==1 then
   b.crect.x=b.x+3
   b.crect.y=b.y+2
  elseif b.btype==3 then
   b.crect.x=b.x+1
   b.crect.y=b.y+3
  end
 elseif b.bdir==8 then
  --down+left
  if b.btype==1 then
   b.crect.x=b.x-1
   b.crect.y=b.y+6
  end
  b.x-=b.vel
  b.y+=b.vel
 end
 if b.x<-8 or b.x>128 or b.y<5 or b.y>128 then
  pr_kill_bullet(b)
 end
end

--check collisions for single
--bullet
function pr_collisions(b)
 if b.btype==1 then
  --test plyr bullet collisions
  for _,egroup in pairs(enemies) do
   for _,e in pairs(egroup) do
        
    if e.alive and e.etype==8 then
     --check etype 8 clone hit
     en_crect.x=e.clone.x
     en_crect.y=e.clone.y
     en_crect.w,en_crect.h=9,9
     if intersect(en_crect,b.crect) then
      pl_bullet_hit(e,b,e.clone)
      --sfx(7)
      return
     end
    end
    
    if e.alive then
     set_en_crect(e)
     if intersect(en_crect,b.crect) then
      --player bullet hits enemy
      pl_bullet_hit(e,b)
      --if(stg_state!=0) sfx(7)
      return
     end
    end
   end
  end
 elseif b.btype==2 then
  --enemy seeking bullet
  b.crect.x=b.x+1
  b.crect.y=b.y+1
  pl_test(b)
 elseif b.btype==3 then
  --border enemy shot
  pl_test(b)
 end
end

function enemy_dest_shake()
 shake+=.27
end

function explode_clone(e)
 sfx(-1,3)
 explo1(e.clone)
end

function pl_bullet_hit(e,b,clone)
 e.curr_energy-=1
 b.alive=false
 if e.curr_energy==0 then
  if(e.etype!=5) enemies_destroyed+=1
  mon_zap_bonus(e)
  enemy_dest_shake()
  if(e.etype==5) flashers_alive-=1
  e.alive=false
  enemies_alive-=1
  update_score(e.score_val)
  explo1(e)
  sc_spawn(e)
  if e.etype==8 then
   explode_clone(e)
  elseif e.etype==7 then
   sfx(-1,2)
  elseif e.etype==11 then
   sfx(-1,3)
  end
  sfx(10,2)  
 else
  if clone==nil then
   explo2(e)
  else
   explo2(e.clone)
  end
 end
end

function pl_test(b)
 if stg_state!=2 and not pl.invincible and pl.alive and intersect(b.crect,pl.crect) then
  --enemy bullet hits player
  b.alive=false
  pl_destroy()
  explo1(b)
 end
end

function pr_kill_bullet(b)
 b.alive=false
end

function pr_draw()
 for _,b in pairs(bullets) do
  if b.alive then
   if b.btype==3 then
    spr(b.sprite,b.x,b.y)
   else
    --pal(7,b.col)
    ospr(b.sprite,0,b.x,b.y,1,1,false,false,7,b.col)
    --spr(b.sprite,b.x,b.y)
    --pal()
   end
   --rect(
   -- b.crect.x,b.crect.y,
   -- b.crect.x+b.crect.w,
   -- b.crect.y+b.crect.h,
   -- 7)
  end
 end
end
-->8
--enemies
enemies,max_enemies,max_group_enemies,dirs1={},16,16,{1,3,5,7} --‹”‘ƒ
--n=energy
--s=score value
--d=down sprites
--u=up sprites
--h=horizontal sprites (999=none)
--b=behav func
--a=anim func
--m=anim interval
--k=atk func
--v=velocity
--particle_fade={11,11,11,11,7,7,7,6,6,6,5,5,8,8,9,9,10,10,10,10,10,8,8,11,11,11,11}
particle_fade,en_crect,rect1={15,15,14,14,13,13,12,13,1,1,1,12,2,3,8,7,6,5,4,3,2,1,2,3,4,5,11,12,13,14},{x=0,y=0,w=9,h=9},{x=0,y=0,w=0,h=0}
edefs={
 "n05s05d016017u018019h999999b01a01m00.22k99v00.140",
 "n07s10d007008u009999h999999b01a02m00.21k01v00.120",
 "n09s15d000000u000000h000000b03a02m00.20k99v00.000",
 "n15s20d053054u055056h051052b04a01m00.20k99v00.130",
 "n10s00d063063u063063h063063b05a00m00.20k99v00.611",
 "n35s25d117117u117117h117117b06a00m00.20k99v00.601",
 "n20s20d000000u000000h000000b07a02m00.22k99v00.212",
 "n30s40d000000u000000h000000b08a00m00.21k99v00.588",
 "n20s15d035036u037038h999999b09a01m00.26k99v00.350",
 "n15s15d022023u024025h999999b09a01m00.26k99v00.689",
 "n35s15d039040u041042h999999b10a01m00.15k99v00.369",
 "n25s40d059060u061062h057058b01a01m00.14k99v00.410",
 "n99s99d011012u013014h999999b12a01m00.16k99v00.901",
 "n15s15d231232u233234h999999b13a01m00.18k99v00.618",
 "n05s05d248249u250251h999999b09a01m00.19k99v00.330"
}

function en_init()
 shadows,enemies_alive,max_shadows={},0,100
 max_flashers=6
 sh_init()
 for i=1,#edefs do --enemy groups
  enemies[i]={}
 end
 --decode enemy defs
 i=1 --enemy group
 for edef in all(edefs) do
  local sprites=nil
  if(i==2) sprites={7,8,9}
  if(i==3) sprites={112,113,114,115,116}
  if(i==7) sprites={43,44,45}
  local behav=tonum(sub(edef,29,30))
  if(behav==1) behav=wander1
  if(behav==2) behav=wander2
  if(behav==3) behav=mix
  if(behav==4) behav=spawner
  if(behav==5) behav=flasher
  if(behav==6) behav=border
  if(behav==7) behav=circ_las
  if(behav==8) behav=border2
  if(behav==9) behav=wander4
  if(behav==10) behav=cross
  if(behav==11) behav=spawner2
  if(behav==12) behav=eugene
  --if(behav==13) behav=wander1
  if(behav==13) behav=mon_zapper
  local atk=tonum(sub(edef,41,42))
  if atk==1 then
   atk=en_shoot
  else
   atk=nil
  end
  local anim=tonum(sub(edef,32,33))
  if anim==1 then
   anim=en_anim_flip
  elseif anim==2 then
   anim=en_anim_loop
  else
   anim=nil
  end
  for j=1,max_group_enemies do
   add(enemies[i],
    {
     alive=false,
     etype=i,
     clone_intro_dest_y=0,
     laserx=0,
     lasery=0,
     x=0,
     y=0,
     timer=0,
     atk_timer=0,
     atk_interval=0,
     interval=0,
     destx=0,
     desty=0,
     col=0,
     intro_dest_y=0,
     laser_timer=0,
     rads=0,
     anim_elapsed=0,
     atk=atk,
     behav=behav,
     anim=anim,
     energy=tonum(sub(edef,2,3)),
     score_val=tonum(sub(edef,5,6)),
     down_spr={tonum(sub(edef,8,10)),tonum(sub(edef,11,13))},
     up_spr={tonum(sub(edef,15,17)),tonum(sub(edef,18,20))},
     hori_spr={tonum(sub(edef,22,24)),tonum(sub(edef,25,27))},     
     anim_interval=tonum(sub(edef,35,39)),
     vel=tonum(sub(edef,44,49)),
     state=1,
     mdir=1,
     spr_idx=1,
     anim_elapsed=0,
     curr_spr=0,
     curr_energy=0,
     sprites=sprites,
     laser_col=4,
     laser_active=false,
     laser1_alive=false,
     laser2_alive=false,
     clone={x=0,y=0,mdir=0,score_val=40} --enemy 8 clone
    }
   )
  end
  i+=1
 end
end

function en_setup()
 enemies_alive,shadows_alive,flashers_alive=0,0,0
 for egroup in all(enemies) do
  for e in all(egroup) do
   e.alive=false
  end
 end
 for s in all(shadows) do
  s.alive=false
 end
 enemies_destroyed=0
end

--set enemy positions
--ensure all enemies for curr
--stage are equally divided
--between all 4 areas of screen
function set_en_pos()
 --cycle through counter 1-4
 --to divide between 4 parts
 --of screen
 pos_cnt=3
 for egroup in all(enemies) do
  for e in all(egroup) do
   if e.alive and e.etype!=8 then
    if(e.etype!=6) set_spawn_pos(e,pos_cnt)
    --test=test..pos_cnt
    pos_cnt+=1
    e.intro_dest_y=e.y
    e.y=-18
   elseif e.alive and e.etype==8 then
    e.intro_dest_y=e.y
    e.y=-18
    e.clone_intro_dest_y=e.clone.y
    e.clone.y=-18
   end
   if(pos_cnt==5) pos_cnt=1
  end
 end
end

function set_spawn_pos(o,area)
 if area==1 then
  --top screen area
  o.x=rand(15,85)
  o.y=rand(12,20)
 elseif area==2 then
  --left screen area
  o.x=rand(5,15)
  o.y=rand(12,85)
 elseif area==3 then
  --right screen area
  o.x=rand(100,115)
  o.y=rand(12,85)
 elseif area==4 then
  --bottom screen area
  o.x=rand(20,82)
  o.y=rand(100,115)
 end
end

function en_spawn(etype)
 for _,e in pairs(enemies[etype]) do
  if not e.alive then
   e.alive=true
   enemies_alive+=1
   e.curr_energy=e.energy
   e.spr_idx=1
   e.intro_y=-18
   if e.etype==2 then
    e.timer=time()
   elseif e.etype==8 then
    e.x=1
    e.y=10
    e.mdir=7
    e.laser_active=false
    --setup clone
    e.clone.x=119
    e.clone.y=120
    e.clone.mdir=3
   elseif e.etype==11 or e.etype==14 then
    e.atk_timer=time()
    e.atk_interval=2.45
   elseif e.etype==7 then
    e.atk_timer=time()
    e.rads=rand(1,6)
   elseif e.etype==6 then
    e.x=1
    e.y=78
    e.mdir=7
    e.timer=time()
   elseif e.etype==3 then
    e.state=rand(1,2)
    e.mdir=rand(1,8)
   elseif e.etype==4 or e.etype==12 then
    e.atk_timer=time()
    e.mdir=rand_from_list(dirs1)
   else
    e.mdir=rand(1,8)
   end
   e.state=1
   if(e.etype==5) flashers_alive+=1
   return e
  end
 end
end

function en_update()
 for _,egroup in pairs(enemies) do
  for _,e in pairs(egroup) do
   if e.alive then
    e:behav()
	   if(e.atk!=nil) e:atk()
	   if(e.anim!=nil) e:anim()
--	   e.crect={
--	    x=en_crect.x,
--	    y=en_crect.y,
--	    w=en_crect.w,
--	    h=en_crect.h
--	   }
    if e.etype==3 then
     e.curr_spr=e.sprites[e.spr_idx]
	   elseif e.etype==2 or e.etype==7 then
     e.curr_spr=e.sprites[e.spr_idx]
	   elseif e.mdir==1 then
     --left
     if e.etype==4 or e.etype==12 then
      e.curr_spr=e.hori_spr[e.spr_idx]
     else
      e.curr_spr=e.down_spr[e.spr_idx]
     end
    elseif e.mdir==2 then
     --up+left
     e.curr_spr=e.up_spr[e.spr_idx]
    elseif e.mdir==3 then
     --up
     e.curr_spr=e.up_spr[e.spr_idx]
    elseif e.mdir==4 then
     --up+right
     e.curr_spr=e.up_spr[e.spr_idx]
    elseif e.mdir==5 then
     --right
     if e.etype==4 or e.etype==12 then
      e.curr_spr=e.hori_spr[e.spr_idx]
     else
      e.curr_spr=e.down_spr[e.spr_idx]
     end
    elseif e.mdir==6 then
     --down+right
     e.curr_spr=e.down_spr[e.spr_idx]
    elseif e.mdir==7 then
     --down
     e.curr_spr=e.down_spr[e.spr_idx]
    elseif e.mdir==8 then
     --down+left
     e.curr_spr=e.down_spr[e.spr_idx]
    end
    
    set_en_crect(e)
    
	   if pl.alive and stg_state!=0 and intersect(en_crect,pl.crect) then
	    --enemy hits player
	    e.curr_energy-=1
	    if e.curr_energy==0 then
	     if(e.etype!=5) enemies_destroyed+=1
      mon_zap_bonus(e)
      enemy_dest_shake()
	     update_score(e.score_val)
	     sc_spawn(e)
	     if e.etype==8 then
	      explode_clone(e)
	     elseif e.etype==11 then
	      sfx(-1,3)
	     end
	     explo1(e)
	     sfx(10,2)
	     e.alive=false
	     enemies_alive-=1
	    end
	    pl_hit(e)
	   end
	  end
  end 
 end
end

function set_en_crect(e)
 if e.etype==5 then
  en_crect.x=e.x+1
  en_crect.y=e.y+1
  en_crect.w,en_crect.h=5,5
 else
  en_crect.x=e.x-1
  en_crect.y=e.y-1
  en_crect.w,en_crect.h=9,9
 end
end

function en_draw()
 --print(enemies[2][1].energy,0,120)
 --print(test,50,120)
 if shadows_alive>0 then
  for _,s in pairs(shadows) do
   if s.alive then
    pal(7,s.col)
    spr(s.sprite,s.x,s.y)
    pal()
   end
  end
 end
 for _,egroup in pairs(enemies) do
  for _,e in pairs(egroup) do
   if e.alive then
    if e.etype==14 and e.laser_active then
     line(e.x+4,e.y+3,e.destx,e.desty,e.laser_col)
    elseif e.etype==11 and e.state==2 then
     --draw vert laser
     rectfill(e.x+2,0,e.x+5,128,e.col)
     --draw hori laser
     rectfill(0,e.y+2,128,e.y+5,e.laser_col)
    end
    if e.etype==5 then
     ospr(e.curr_spr,0,e.x,e.y,1,1,false,false,7,e.col)
    elseif e.etype==8 then
     ospr(118,0,e.x,e.y,1,1,false,false,10,e.col)
     ospr(118,0,e.clone.x,e.clone.y,1,1,false,false,10,e.col)
     line(e.x+4,e.y+3,e.clone.x+4,e.clone.y+3,e.col)
    elseif e.etype==7 then
     ospr(e.curr_spr,0,e.x,e.y,1,1,false,false)
     if e.state==2 then
      line(e.x+4,e.y+3,e.laserx,e.lasery,e.laser_col)
     end
    elseif e.etype==6 or e.etype==13 then
     ospr(e.curr_spr,0,e.x,e.y,1,1,false,false,10,e.col)
    elseif e.etype==5 then
     ospr(e.curr_spr,0,e.x,e.y,1,1,false,false,7,e.laser_col)
    elseif e.mdir==5 then
     if e.etype==4 or e.etype==12 then
      ospr(e.curr_spr,0,e.x,e.y,1,1,true,false)
     else
      ospr(e.curr_spr,0,e.x,e.y,1,1,false,false)
     end
    else
     ospr(e.curr_spr,0,e.x,e.y,1,1,false,false)
     --spr(e.curr_spr,e.x,e.y)
    end
    --draw collision boxes
--    if e.etype==5 then
--	    en_crect.x=e.x+1
--	    en_crect.y=e.y+1
--	    en_crect.w=5
--	    en_crect.h=5
--	   end
--	   else
-- 	   en_crect.x=e.x-1
--	    en_crect.y=e.y-1
--	    en_crect.w=9
--	    en_crect.h=9
--	   end
--    if e.crect!=nil then
--     rect(
--      e.crect.x,e.crect.y,
--      e.crect.x+e.crect.w,
--      e.crect.y+e.crect.h,
--      7)
--    end
   end
  end
 end
end

--shoot towards player
function en_shoot(e)
 if(not pl.alive) return
 if time()-e.timer>3.14 then
  sfx(1)
  pr_spawn(e.x,e.y,pl.x,pl.y,.965)
  e.timer=time()
 end
end

--function en_laser(e)
-- if time()-e.beam_timer>0.75 then
--  pr_spawn_laser(e)
-- end
--end

--1=left
--2=up+left
--3=up
--4=up+right
--5=right
--6=down+right
--7=down
--8=down+left

--mix of wander1 and seek
function mix(e)
 if(stg_state==0) return
 if e.state==1 then
  wander1(e)
 else
  if not pl.alive then
   e.state=1
   e.vel=.17
   return
  end
  seek(e)
 end
 if time()-e.timer>e.interval then
  e.state=rand(1,2)
  if e.state==2 then
   e.vel=.991
  else
   e.vel=.17
  end
  e.interval=3+rnd(5)
  e.timer=time()
 end
end

--wander around screen randomly
--in all 8 directions
function wander1(e)
 --call wander2 func when
 --walking diagonally
 if e.mdir==1 then
  --left
  e.x-=e.vel
  if(e.x<2) e.mdir=rand(4,6)
 elseif e.mdir==5 then
  --right
  e.x+=e.vel
  if(e.x>118) e.mdir=rand_from_list({1,2,8})
 elseif e.mdir==3 then
  --up
  e.y-=e.vel
  if(e.y<10) e.mdir=rand(6,8)
 elseif e.mdir==7 then
  --down
  e.y+=e.vel
  if(e.y>118) e.mdir=rand(2,4)
 else
  wander2(e)
 end
end

--wander around screen randomly
--move only in diagonals
function wander2(e)
 if e.mdir==2 then
  --up+left
  e.x-=e.vel
  e.y-=e.vel
  if e.x<2 or e.y<10 then
   --at wall, set new direction
   e.mdir=rand_from_list({4,6})
  end
 elseif e.mdir==4 then
  --up+right
  e.x+=e.vel
  e.y-=e.vel
  if e.x>118 or e.y<10 then
   --at wall, set new direction
   if rand(1,2)==2 then
    e.mdir=2
   else
    e.mdir=8
   end
  end
 elseif e.mdir==6 then
  --down+right
  e.x+=e.vel
  e.y+=e.vel
  if e.x>118 or e.y>118 then
   --at wall, set new direction
   if rand(1,2)==2 then
    e.mdir=2
   else
    e.mdir=8
   end
  end
 elseif e.mdir==8 then
  --down+left
  e.x-=e.vel
  e.y+=e.vel
  if e.x<2 or e.y>118 then
   --at wall, set new direction
   e.mdir=rand(2,4)
  end
 end
end

--wander around screen randomly
--in 4 directions (”,ƒ,‹,‘)
--can randomly change dir before
--hitting edge of screen.
function wander3(e)
 if time()-e.timer>e.interval then
  e.interval=1+rnd(5)
  e.mdir=rand_from_list(dirs1)
  e.timer=time()
 end
 if e.mdir==1 then
  --left
  e.x-=e.vel
  if(e.x<2) e.mdir=rand_from_list({3,5,7})
 elseif e.mdir==5 then
  --right
  e.x+=e.vel
  if(e.x>118) e.mdir=rand_from_list({1,3,7})
 elseif e.mdir==3 then
  --up
  e.y-=e.vel
  if(e.y<10) e.mdir=rand_from_list({1,5,7})
 elseif e.mdir==7 then
  --down
  e.y+=e.vel
  if(e.y>118) e.mdir=rand_from_list({1,3,5})
 end
end

--wander around screen randomly
--in all 8 directions
--can randomly change dir before
--hitting edge of screen.
function wander4(e)
 if time()-e.timer>e.interval then
  e.interval=rand(1,4)
  e.mdir=rand_from_list(dirs1)
  e.timer=time()
 end
 wander1(e)
end

rec={x=0,y=0,w=0,h=0}

function cross(e)
 wander4(e)
 if e.state==1 then
  if (pl.lives<0) return
  if time()-e.atk_timer>e.atk_interval then
   e.laser1_alive=true
   e.laser2_alive=true
   e.atk_timer=time()
   e.atk_interval=1.28
   e.state=2
   sfx(5,3)
  end
 elseif e.state==2 then
  --lasers active
  e.laser_col=rand(0,6)
  e.col=rand(0,6)
  --vert laser hit player?
  rec.x=e.x+2
  rec.y=0
  rec.w=4
  rec.h=128
  if stg_state!=2 and pl.alive and intersect(pl.crect,rec) then
   pl_hit(pl)
  end
  --hori laser hit player?
  rec.x=0
  rec.y=e.y+2
  rec.w=128
  rec.h=4
  if stg_state!=2 and pl.alive and intersect(pl.crect,rec) then
   pl_hit(pl)
  end
  if time()-e.atk_timer>e.atk_interval then
   e.laser1_alive=false
   e.laser2_alive=false
   e.atk_timer=time()
   e.atk_interval=2.89
   e.state=1
  end
 end
end

function seek(e)
 e.destx=pl.x
 e.desty=pl.y
	e.x=lerp(e.destx,e.x,e.vel)
 e.y=lerp(e.desty,e.y,e.vel)
end

--enemy spawns random moving
--square enemy
function spawner(e)
 wander3(e)
 if time()-e.atk_timer>4 then
  if flashers_alive!=max_flashers then
   sfx(2)
   se=en_spawn(5)
   if se!=nil then
    se.x=e.x-1
    se.y=e.y+1
   end
  end
  e.atk_timer=time()
 end
end

function spawner2(e)
 wander4(e)
 if time()-e.atk_timer>4 then
  if flashers_alive!=max_flashers then
   se=en_spawn(5)
   if se!=nil then
    se.x=e.x-1
    se.y=e.y+1
   end
  end
  e.atk_timer=time()
 end
end

function eugene(e)
 wander4(e)
 e.col=rand(0,13)
 if stg_state!=0 and time()-e.atk_timer>1.12 then
  --fire ”ƒ‹‘
  pr_spawn_shot(e.x,e.y,3,.39)
  pr_spawn_shot(e.x,e.y,7,.39)
  pr_spawn_shot(e.x,e.y,1,.39)
  pr_spawn_shot(e.x,e.y,5,.39)
  e.atk_timer=time()
  sfx(6)
 end
end

--flashing square enemy
function flasher(e)
 wander4(e)
 e.laser_col=rand_from_list({12,2,1,5,7,11})
 e.col=e.laser_col
 if time()-e.atk_timer>.04 then
  sh_spawn(e.x,e.y,63)
  e.atk_timer=time()
 end
end

function border(e)
 border_move(e,e.vel)
end

function border2(e)
 e.col=rand(0,14)
 if(stg_state==0) return
 if time()-e.timer>1.87 then
  e.laser_active=true
  e.timer=time()
  sfx(11,3)
 end
 border_move(e,e.vel)
 border_move(e.clone,e.vel)
 en_crect.x=e.clone.x
 en_crect.y=e.clone.y
 if pl.alive then
  if intersect(en_crect,pl.crect) then
   --clone hits player
   pl_hit(e.clone)
	 elseif line_rect_intsect(
	  e.x+4,
	  e.y+3,
	  e.clone.x+4,
	  e.clone.y+3,
	  pl.crect.x,
	  pl.crect.y,
	  pl.crect.x+pl.crect.w,
	  pl.crect.y+pl.crect.h) then
	   --laser  player
	   pl_hit(pl)
	 end
 end
end

function border_move(e,vel)
 if e.mdir==1 then
  --left
  e.x-=vel
  fire_dir=7
  if(e.x<2) e.mdir=7
 elseif e.mdir==7 then
  --down
  e.y+=vel
  fire_dir=5
  if(e.y>119) e.mdir=5
 elseif e.mdir==5 then
  --right
  e.x+=vel
  fire_dir=3
  if(e.x>119) e.mdir=3
 elseif e.mdir==3 then
  --up
  e.y-=vel
  fire_dir=1
  if(e.y<9) e.mdir=1
 end
 if e.etype==6 then
  e.col=rand(0,6)
  if(pl.lives<0) return
  if time()-e.timer>1.02 then
   sfx(3)
   pr_spawn_shot(e.x,e.y,fire_dir,.965)
   e.timer=time()
  end
 end
end

function circ_las(e)
 wander4(e)
 if e.state==1 then
  if time()-e.atk_timer>2.41 then
   if (pl.lives<0) return
   --spawn laser
   e.state=2
   e.laser_timer=time()
   if(e.rads>6.28) e.rads=0
   sfx(4,2)
  end
 end
 if e.state==2 then
  --circle laser around enemy
  e.laser_col=rand_from_list({3,9,8,0,11,12})
  e.rads+=.019
  --26=radius
  e.laserx=e.x+1+26*cos(e.rads)
  e.lasery=e.y+1+26*sin(e.rads)
  sh_spawn(e.laserx,e.lasery,47)
  if time()-e.laser_timer>1.89 then
   e.atk_timer=time()
   e.state=1
  end
  --line hits player?
  if pl.alive then
	  if line_rect_intsect(
	   e.x+4,
	   e.y+3,
	   e.laserx,
	   e.lasery,
	   pl.crect.x,
	   pl.crect.y,
	   pl.crect.x+pl.crect.w,
	   pl.crect.y+pl.crect.h) then
	    --laser hits player
	    pl_hit(pl)
	  end
	 end
 end
end

--zap a mon every 2 seconds
function mon_zapper(e)
 wander4(e)
 if e.laser_active then
  e.laser_col=rand(1,8)
  if time()-e.atk_interval>.11 then
   e.laser_active=false
  end
 end
 if(e.energy<6) return
 if time()-e.atk_timer>2.18 then
  --zap a mon
  e.atk_timer=time()
  for _,m in pairs(mons) do
   if m.alive then
    mon_zapped=true
    m.alive=false
    explo1(m)
    e.laser_active=true
    e.destx=m.x+3
    e.desty=m.y+3
    --repurpose atk_interval as
    --a timer for laser
    e.atk_interval=time()
    sfx(46)
    return
   end
  end
 end 
end

--function vampire(e)
-- wander1(e)
-- for _,m in pairs(mons) do
--  if(m.alive and intersect(e.crect,m.crect)) m.state=2
-- end
--end

function sh_init()
 for i=1,max_shadows do
  add(shadows,{
   alive=false,
   x=0,
   y=0,
   timer=0,
   sprite=0,
   col=0
  })
 end
end

function sh_spawn(x,y,sprite)
 for _,s in pairs(shadows) do
  if not s.alive then
   shadows_alive+=1
   s.alive=true
   s.x=x
   s.y=y
   s.timer=time()
   s.sprite=sprite
   return
  end
 end
end

function sh_update()
 for _,s in pairs(shadows) do
  if s.alive then
   s.col=rand_from_list({3,9,8,0,11,12})
   if time()-s.timer>.24 then
    s.alive=false
    shadows_alive-=1
   end
  end
 end
end

--anim 2 frames
function en_anim_flip(e)
 if time()-e.anim_elapsed>e.anim_interval then
  if e.spr_idx==1 then
   e.spr_idx=2
  else
   e.spr_idx=1
  end
  e.anim_elapsed=time()
 end
end

--anim for 2 or more frames
function en_anim_loop(e)
 if time()-e.anim_elapsed>e.anim_interval then
  if e.spr_idx!=#e.sprites then
   e.spr_idx+=1
  else
   e.spr_idx=1
  end
  e.anim_elapsed=time()
 end
end 

function explo1(e)
 for i=1,125 do
  add_new_dust(
   e.x+4,
   e.y+4,
   rnd(4)-2,    --grav x
   rnd(4)-2,    --grav y
   32+rnd(144), --life
   1+rnd(5),    --radius
   0,           --grav level
   particle_fade
  )
 end
end

function explo2(e)
 for i=1,25 do
  add_new_dust(
   e.x+4,
   e.y+4,
   rnd(4)-2,  --grav x
   rnd(4)-2,  --grav y
   8+rnd(22), --life
   1,         --radius
   0,         --grav level
   particle_fade
  )
 end
end
-->8
--menu
local start="press — to start"
local eb_txt="2020 exquisite bytes"
oldhiscore,menu_state=0,0
function init_scaling_rect()
 rx0,ry0,rx1,ry1=64,64,64,64
end

function me_update()
 if menu_state==0 then
  init_scaling_rect()
  menu_state=1
 elseif menu_state==1 and btn(—) then
  music(-1, 1222)
  menu_state=2
 elseif menu_state==2 then
  --update scaling rect
  rx0-=.79
  ry0-=.79
  rx1+=.79
  ry1+=.79
  --retract tiles
  for t in all(bgtiles) do
   logoy+=.003
   startx+=.006
   hiscorex-=.006
   ebytesy+=.0014
   if t.flipx then
    t.x+=.94
   else
    t.x-=.94
   end
   if t.flipx and t.x>200 then
    menu_state=3
    return
   end
  end
 elseif menu_state==3 then
  current_stage,pl.lives,gamestate,score,menu_state=1,3,2,0,1
  pl_setup()
  stg_setup()
  oldhiscore=hiscore
  music(26,0,3)
 end
 bg_update()
end

c1=8
c2=9
c3=10
col_cyc_tick=0

--function draw_label()
 --   x0 y0  spr_w spr_h x  y
 --cls(10)
 --sspr(0, 96, 53,   16,   14, 30, 100, 24)
 --sspr(62,96, 54,   16,   14, 60, 100, 24)
--end

function me_draw()
 --draw_label()
 --if(1==1) return

 --r=rand(1,15) 
 if menu_state==2 then
  rectfill(rx0,ry0,rx1,ry1,9)
 end
 
 for t in all(bgtiles) do
  if t.alive then
   spr(66,t.x,t.y,1,1,t.flipx,false)
  end
 end
 --sspr(0,96,116,16,6,40)
 --colour cycle backwards
 col_cyc_tick+=1
 if col_cyc_tick==5 then
  c3-=1
  if(c3<8) c3=10
  c2-=1
  if(c2<8) c2=10
  c1-=1
  if(c1<8) c1=10
  col_cyc_tick=0
 end
 
 --colour cycle forwards
-- col_cyc_tick+=1
-- if col_cyc_tick==13 then
--  white+=1
--  if(white>7) white=5
--  light_grey+=1
--  if(light_grey>7) light_grey=5
--  dark_grey+=1
--  if(dark_grey>7) dark_grey=5
--  col_cyc_tick=0
-- end
 
 pal(7,c3)
 pal(6,c2)
 pal(5,c1)
 sspr(0,96,116,16,6,40-logoy)
 pal()
 
 outline(start,hcenter(start)-3+startx,70,1,1+rnd(16))
 hi="high score:"..hiscore
 outline(hi,hcenter(hi)+hiscorex,90,1,12)
 outline(eb_txt,hcenter(eb_txt),107+ebytesy,1,9)
end

function bg_init()
 music(0)
 logoy,startx,hiscorex,ebytesy=0,0,0,0
 bgtiles={}
 for i=1,272 do
  add(bgtiles,{
   alive=false,
   x=0,
   y=0,
   flipx=false
  })
 end
 local y=-8
 for i=1,17 do
  --left tiles
  bg_spawn(0,y,1.31,false)
  bg_spawn(8,y,1.31,false)
  bg_spawn(16,y,.94,false)
  bg_spawn(24,y,.94,false)
  bg_spawn(32,y,.70,false)
  bg_spawn(40,y,.70,false)
  bg_spawn(48,y,.55,false)
  bg_spawn(56,y,.55,false)
  --right tiles
  bg_spawn(120,y,1.31,true)
  bg_spawn(112,y,1.31,true)
  bg_spawn(104,y,.94,true)
  bg_spawn(96,y,.94,true)
  bg_spawn(88,y,.70,true)
  bg_spawn(80,y,.70,true)
  bg_spawn(72,y,.55,true)
  bg_spawn(64,y,.55,true)
  y+=8
 end
end

function bg_spawn(x,y,vel,flipx)
 for t in all(bgtiles) do
  if not t.alive then
   t.alive=true
   t.x=x
   t.y=y
   t.vel=vel
   t.flipx=flipx
   return
  end
 end
end

function bg_update()
 for t in all(bgtiles) do
  if t.alive then
   t.y=((t.y+t.vel+136)%136)-8
  end
 end
end
-->8
--particles
--dust_alive=0
function add_new_dust(_x,_y,_dx,_dy,_l,_s,_g,_f)
	--if(dust_alive>350) return
	--dust_alive+=1
	add(dust,{
		fade=_f,
 	x=_x,
 	y=_y,
 	dx=_dx,  --gravity x
 	dy=_dy,  --gravity y
 	life=_l, --duration
 	orig_life=_l,
 	rad=_s,
		col=0,   --set to colour
 	grav=_g,
 	draw=function(self)
 		--this function takes care
 		--of drawing the particle
 		
 		--clear the palette
 		pal()
 		palt()
 		
 		--draw the particle
 		circfill(self.x,self.y,self.rad,self.col)
 	end,
 	update=function(self)
 		--this is the update function
 		
 		--move the particle based on
 		--the speed
 		self.x+=self.dx
 		self.y+=self.dy
 		--and gravity
 		self.dy+=self.grav
 		
 		--reduce the radius
 		--this is set to 90%, but
 		--could be altered
 		self.rad*=0.9
 		
 		--reduce the life
 		self.life-=1
 		
 		--set the color
 		if type(self.fade)=="table" then
 			--assign color from fade
 			--this code works out how
 			--far through the lifespan
 			--the particle is and then
 			--selects the color from the
 			--table
		 	self.col=self.fade[flr(#self.fade*(self.life/self.orig_life))+1]
			else
				--just use a fixed color
				self.col=self.fade		 	
		 end
		 
		 --if the dust has exceeded
		 --its lifespan, delete it
		 --from the table
	 	if self.life<0 then
 			del(dust,self)
 			--dust_alive-=1
 		end
 	end
 })
end
-->8
--game over
go_txt="game over"
go_state=1

function go_update()
 if go_state==1 then
  go_state,go_elapsed=2,time()
  dset(0,hiscore)
 else
  if time()-go_elapsed>3.92 then
   bg_init()
   menu_state,gamestate,go_state=0,1,1
  end
 end
end

function go_draw()
 outline(go_txt,hcenter(go_txt),56,1,9)
end
-->8
--mons
mons={}
mon_crect={x=0,y=0,w=8,h=8}
mon_sprites={}

function mons_init()
 --create sprites table
 c,mspr=1,{}
 for i=128,192 do
  add(mspr,i)
  c+=1
  if c==9 then
   add(mon_sprites,mspr)
   c,mspr=1,{}
  end
 end
 --create mon objects
 for i=1,10 do
  add(mons,{
   alive=false,
   x=0,
   y=0,
   vel=0,
   sprites={},
   spr_idx=1,
   face_sprite=3,
   walk_timer=0,--walk anim timer
   walk_interval=0,--walk anim interval
   face_timer=0,--face change timer
   face_interval=0,--face change interval
   mdir=1,
   score_val=25,
   intro_dest_y=0
  })
 end
end

function mon_zap_bonus(e)
 if(mon_zapped) return
 --test=test..mons_spawned.." "..mons_saved.." "..enemies_destroyed..(mon_zapped and ' true' or ' false')
 if enemies_destroyed==1 and mons_spawned==mons_saved then
  mon_zapped=true
  for i=1,8 do
   sc_spawn(e)
  end
 end
end

function mons_setup()
 for m in all(mons) do
  m.alive=false
 end
 mons_spawned,mons_saved=0,0
 mon_zapped=false
end

function mon_spawn(area)
 for _,m in pairs(mons) do
  if not m.alive then
   mons_spawned+=1
   m.alive=true
   m.walk_interval=.18+rnd(.22)
   m.face_interval=1.11+rnd(2.68)
   m.mdir=rand(1,8)
   m.sprites=mon_sprites[rand(1,8)]
   m.vel=.04+rnd(.08)
   set_spawn_pos(m,area)
   m.timer=time()
   m.intro_dest_y=m.y
   m.y=-18
   return
  end
 end
end

function mons_update()
 if(stg_state==0) return
 for _,m in pairs(mons) do
  if m.alive then
   mon_crect.x=m.x
   mon_crect.y=m.y
   wander1(m)
   if time()-m.face_timer>m.face_interval then
    m.face_sprite=rand(3,8)
    m.face_timer=time()
    m.face_interval=1.11+rnd(2.68)
   end
   if time()-m.walk_timer>m.walk_interval then
    if m.spr_idx==1 then
     m.spr_idx=2
    else
     m.spr_idx=1
    end
    m.walk_timer=time()
   end
   
   --if m.mdir==1 or m.mdir==2 or m.mdir==3 or m.mdir==8 then
   -- m.flip_spr=false
   --else
   -- m.flip_spr=true
   --end
   
   if time()-m.timer>.66 then
    m.timer=time()
   end
   
   --intersects player
   if intersect(mon_crect,pl.crect2) then
    update_score(m.score_val)
    sc_spawn(m)
    m.alive=false
    mons_saved+=1
    sfx(0)
   end
   
   --intersects enemy?
   --if intersect(mon_crect,en_crect) then
   -- update_score(20)
   -- sc_spawn(m)
   -- m.alive=false
   --end   
  end
 end
end

function mons_draw()
 for _,m in pairs(mons) do
  if m.alive then
   --ospr(m.sprites[m.face_sprite],0,m.x,m.y,1,1,false,false)
   ospr(m.sprites[m.spr_idx],0,m.x,m.y,1,1,false,false)
   spr(m.sprites[m.face_sprite],m.x,m.y)
   --spr(m.sprites[m.spr_idx],m.x,m.y)
   --spr(m.sprites[m.face_sprite],m.x,m.y)
   --mon_crect.x=m.x
   --mon_crect.y=m.y
--   mon_crect.x=m.x
--   mon_crect.y=m.y
--   rect(
--    mon_crect.x,mon_crect.y,
--    mon_crect.x+mon_crect.w,
--    mon_crect.y+mon_crect.h,
--    7)
  end
 end
end
-->8
--scores
function sc_init()
 scores={}
 for i=1,50 do
  add(scores,{
   alive=false,
   val="",
   mdir=2
  })
 end
end

function sc_setup()
 for sc in all(scores) do
  sc.alive=false
 end
end

function sc_spawn(o)
 if(o.score_val==0) return
 for _,sc in pairs(scores) do
  if not sc.alive then
   sc.alive=true
   sc.x=o.x
   sc.y=o.y
   sc.val=o.score_val
   sc.vel=0.21+rnd(0.33)
   sc.mdir=rand_from_list({2,4,6,8})
   return
  end
 end
end

function sc_update()
 for _,sc in pairs(scores) do
  if sc.alive then
   sc.col=rand(0,15)
   
   if sc.mdir==2 then
    --up+left
    sc.x-=sc.vel
    sc.y-=sc.vel
   elseif sc.mdir==4 then
    --up+right
    sc.x+=sc.vel
    sc.y-=sc.vel
   elseif sc.mdir==6 then
    --down+right
    sc.x+=sc.vel
    sc.y+=sc.vel
   elseif sc.mdir==8 then
    --down+left
    sc.x-=sc.vel
    sc.y+=sc.vel
   end
   
   if sc.x>128 or sc.x<0 or sc.y<-8 or sc.y>128 then
    sc.alive=false
   end
  end
 end
end

function sc_draw()
 for _,sc in pairs(scores) do
  if(sc.alive) outline(sc.val,sc.x,sc.y,0,sc.col)
 end
end
-->8
--keys
keys={}

function is_pressed(k) return band(keys[k],2)==2 end

function upd_key(k)
 if keys[k]==0 then
  if btn(k) then keys[k]=3 end
 elseif keys[k]==1 then
  if btn(k)==false then keys[k]=4 end
 elseif keys[k]==3 then
 if btn(k) then keys[k]=1
 else keys[k]=4 end
 elseif keys[k]==4 then
  if btn(k) then keys[k]=3
  else keys[k]=0 end
 end
end

function init_keys()
 for a=0,5 do keys[a]=0 end
end

function upd_keys()
 for a=0,5 do upd_key(a) end
end
__gfx__
007ccd00007ccd00007ccd00007ccd00007ccd000007d0000007d000000000000000000000000000000888000008880000088800000888000008880000000000
0c0c0cd00c0c0cd00c0c0cd00cccccd00cccccd000cccd0000cccd000000000000000000000000000aaa8aaa0aaa8aaa0aaa8aaa0aa888aa0aa888aa00000000
0cccccd00cccccd00cccccd00cccccd00cccccd000cccd0000cccd000077770000777700007777000a1a8a1a0a1a8a1a0a1a8a1a0a88888a0a88888a00000000
0000000000000000000000000000000000000000000000000000000006777770067777700677777000a888a000a888a000a888a0000888000008880000000000
00776500007765000077650000776500007765000077650000776500067686700676867006768670000070000000700000007000000070000000700000000000
00075000006750000007560000075600006750000067500000075600656777500567775605677750087727780877277808772778087727780877277800000000
00600600000006000060000000600000000006000000060000600000500560066005600560056006080727080807277000772708087727000007277800000000
00000000000000000000000000000000000000000000000000000000000050055000500050000005007707700077000000000770000007700077000000000000
007bb300007bb300007bb300007bb30007dddd1007dddd1070000009700000097000000970000009000790000007900000079000000790000000000000000000
06bbbb3006bbbb3006bbbb3006bbbb30ddddddd1ddddddd1aa7aa999aa7aa999aa7aaa99aa7aaa9900aaa90000aaa90000aaa90000aaa9000000000000000000
065b5b30065b5b3006bbbb3006bbbb30d7d7ddd1d7d7ddd19a9191989a9191989aaaaa989aaaaa98002929007029290000aaa90070aaa9000000000000000000
3b565b300b565b333bbbbb300bbbbb33ddddddd1ddddddd10aaaaa900aaaaa900aaaaa900aaaaa9007aaa90407aaa90007aaa90407aaa9000000000000000000
0bbbb6333bbbb6300bbbbb333bbbbb300000200000002000000a9000000a9000000a9000000a900070aaa94000aaa94070aaa94000aaa9400000000000000000
0bbdbb300bbdbb300bbbbb300bbbbb30006dd1000000200000aaa99007aaa90007aaa90000aaa9900091a9000091a90400aaa90000aaa9040000000000000000
00bbb30000bbb30000bbb30000bbb30000ddd100006dd10007ad9a0000ad9a9000aa9a9007aa9a0009aaa90000aaa99009aaa90000aaa9900000000000000000
003000000000050000300000000005000000000000ddd10000000000000000000000000000000000000aa090090aa000000aa090090aa0000000000000000000
007770000077700000777000008c8000009c9000008c8000009c9000080000900900008009000080080000900003b0000003b0000003b0000000000077000000
06778700067a870006778700000d0000000d0000000d0000000d000000766d0000766d0000766d0000766d00007bbb00007bbb00007bbb000000000077000000
00677000006770000067700007aaaa9007aaaa9007aaaa9007aaaa90077777d0077777d0066666d0066666d003bbbbb003bbbbb003bbbbb00000000000000000
000600000006000000060000a7777aa9a7777aa9aaaaaaa9aaaaaaa9078787d0074747d0066666d0066666d003b787b003b787b003b787b00000000000000000
000777700007777000077770a2727aa9a2727aa9aaaaaaa9aaaaaaa9977777d9877777d8866666d8966666d903bbbbb003bbbbb003bbbbb00000000000000000
00677777006777770067777707777a9007777a900aaaaa900aaaaa90066d66d0066d66d0066666d0066666d03d3bbbd00d3bbbd30d3bbbd00000000000000000
00676d570067d56700675d6700900900009009000090090000900900006666000066660000666d0000666d00d00d3003300d300d300d30030000000000000000
00067770000677700006777000900000000009000090000000000900090000800800009008000090090000800000d00dd000d000d000000d0000000000000000
0d1d1d000d1d1d000d1d1d0007999800079998000799980007999800079998000799980007665000076650000766650007666500076665000766650000000000
1ffffff01ffffff01ffffff001119980011199809111118091111180999999809999998001111500011115006111115061111150666666506666665000000000
d71ff710d71ff710d71ff71071711980717119809171718091717180999999809999998071711500717115006171715061717150666666506666665000777700
1ffffff01ffffff01ffffff001111980011119809111118091111180999999809999998001111500011115006111115061111150666666506666665000777700
0222000002220000dffff0000999980009999800099998000999980009999800099998000666500006665b00066665b0b6666500066665b0b666650000777700
08880000dffff0000ffff0000000000000000000000000000000000000000000000000000000b00000300000b0000000000000b0b0000000000000b000777700
dffff0000ffff0000000000007b3000000b3600000b0360007b0300000b0360007b0300007000000000006000000060007000000000006000700000000000000
0ffff000000000000000000000766000077600000770600000706600077060000070660000706600077060000770600000706600077060000070660000000000
00000000000000007666ddd000d6d000777777777ddd11107ddd1110dddd11107ddd100007ddd1107dddddd07777777777777777777777770080020000c00100
00000050505050507666d6d000d6d0006666666649a9444428e822203bab333359a9440007ddd1101c6cddd06666666666666666611111161089420100c00100
00000010101010107666d1d06d676d606667d66649a9444428e822203bab333349a9444402ddd1101c6c111066666666611111166177771680800202c0c00101
0007d6606060606076d6d1d06d676d606666666649a9444428e822203bab333349a9444452e255551c6c111166666666615cc7166178971680894202c0c65101
000d0010101010107676d1d06d676d60dddddddd9a7a99998e7e8880ba7abbbb5a7a99902e7e2222c676ccccddddddddd155551dd177771d80800202c0c65101
00060000505050507666d1d06d676d60d011116d76d6ddd076d6ddd066d6ddd07666d0002ede6dd076d66660ddddddddd111111dd111111d10894201c0c00101
15161000101010107666d0d000d6d000dddddddd7676ddd07676ddd06676ddd076d6d00007666dd076766660dddddddddddddddddddddddd0080020000c00100
00000000000000007666ddd000d6d000000000007666ddd07666ddd06666ddd07676d00007666dd07666ddd00000000000000000000000000080020000c00100
15161500666666666666666666666d66055555500555555000000000777822270d0d0dd09aaaaaa7d6666667d6600667c770077766d667770020080000c00100
00050000111111111111111111111111576666c557bbbb3500000000666e888d12d2111199aaaa7a5d6666765d6666765c77777766d667771024980100c00100
15161500dddddddddddddddddddddddd5ccccc155b3333150007700007d7eee012d21111999aa7aa55dddd6655dddd6655cccc7766d6677720200808c0c00101
00050000dddddddddddddddddddddddd055555500555555000000000666e888d12d21111999ffaaa55dddd6605dddd6005c15c7066d6677720249808c0c65101
15161500ddddddddddddd5dddddddddd000000000000000000000000000822202d7d2222999ffaaa55dddd6605dddd6005c15c700667777020200808c0c65101
000500006666666666665d66666666660000000000000000000000000008222006d60dd099e449aa55dddd6655dddd6655c15c770667777010249801c0c00101
15161500000000000000000000000000000000000000000000000000ddd8222106760dd09e44449a55dddd6655dddd6655cccc77000000000020080000c00100
000500000000000000000000000000000000000000000000000000000008222006060dd0e4444449555dd6665550066655500777000000000020080000c00100
151615000000000000000000000100000020080001516150061d6000766666650666666660000066400000a40000100000000000000000000020080000c00100
000000000000000000010000000100001024980100000000761d6600666666656000000006000600440009990000100000000000000000001024980100c00100
15161500000d0000000d0000000d00002020080801516150651dc600666666656070000006111607440009790000d000000000000000000020200808c0c00101
0000000000d6d00001d6d10011d6d1102024980800000000651dc60055555555600000000651560044655999111d6d11000000000000000020249808c0c65101
15161500000d0000000d0000000d00002020080801516150651dc600060000606000000006111600440009990000d000000000000000000020200808c0c65101
000000000000000000010000000100001024980100000000651dc6000607006060000000060006004000009400001000000000000000000010249801c0c00101
151615000000000000000000000100000020080001516150561d6600006006000666666660000066060005000000100000000000000000000020080000c00100
000000000000000000000000000000000020080000000000061d6000000660000000000000000000006650000000000000000000000000000020080000c00100
006665000066650000666500006665000066650011000011aa0000aa007777000077770000777700007777000077770000077000000770000020080000c00100
071111500711115007111150071111500711115017aaaa81a7aaaaba070707700707077007070770077777700777777000777700007777001024980100c00100
61171115611711156117111561171115611711150a7882a00a7bb3a00777777007777770077777700777777007777770007777000077770020200808c0c00101
61111115611111156111111561111115611111150a8aa2a00abaa3a00000000000000000000000000000000000000000000000000000000020249808c0c65101
06666650066666500666665006666650066666500a8aa2a00abaa3a00077770000777700007777000077770000777700007777000077770020200808c0c65101
00000000000000000000000000000000000000000a2222a00a3333a00007700000777000000777000007770000777000007770000007770010249801c0c00101
0b6665b000666b000066b500006b650000b6650018aaaa81abaaaaba007007000000070000700000007000000000070000000700007000000020080000c00100
000650000006500000065000000650000006500011000011aa0000aa000000000000000000000000000000000000000000000000000000000020080000c00100
00000000000000000000000000000000000000000000000000000000000000000003000000030000000300000003000000030000000300000003000000030000
007ff900007ff900007ff900007ff900007ff900007ff900007ff900007ff90000bb330000bb330000bb330000bb330000bb330000bb330000bb330000bb3300
0f1f1f900f1f1f900f1f1f900fffff900fffff900f1f1f900fffff900fffff90007ff900007ff900007ff900007ff900007ff900007ff900007ff900007ff900
9f1f1f900f1f1f990f1f1f900f1f1ff00f1f1f900ffffff00f1f1f900fffff900ff1f1900ff1f1900ff1f1900fffff900f1f1f900fffff900ff1f1900f1f1f90
0ff1fff99ff1fff00ff1fff00ff1ff900ff1fff00ff1ff900ffffff00ff1f1f00fffff900fffff900fffff900ff1f1900fffff900f1f1f900fff1f900ff1ff90
0fffff900fffff900fffff900fffff900ff1ff900fffff900fff1f900fff1f9000fff90000fff90000fff90000fff90000fff90000fff90000fff90000fff900
00ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff000040010000100400000000000000000000000000000000000000000000000000
00900000000009000000000000000000000000000000000000000000000000000000040000400000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f0000000f0000000f0000000f0000000f0000000f0000000f0000000f00000000000900000009000000090000000900000009000000090000000900000009
007ff900007ff900007ff900007ff900007ff900007ff900007ff900007ff90007ffff9007ffff9007ffff9007ffff9007ffff9007ffff9007ffff9007ffff90
0f1f1f900f1f1f900f1f1f900ff1f1900f1f1f900f1f1f900ff1f1900fffff900f1f1f900f1f1f900f1f1f900fffff900f1f1f900ff1f1900f1f1f900f1f1f90
0fffff900fffff900fffff900fffff900fffff900f1f1f900fffff90011f11900ffff7900ffff7900ffff7900f1f17900ffff7900ffff7900ffff7900ffff790
0f111f900f111f900f111f900f111f900ff1ff900fffff900f11ff900ff1ff900ff1ff900ff1ff900ff1ff900ff1ff900fff1f900f11ff900fff11900f1fff90
0fffff900fffff900fffff900fffff900fffff900fffff900fffff900fffff9000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff00
00600000000006000000000000000000000000000000000000000000000000000090000000000a00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07fff90007fff90007fff90007fff90007fff90007fff90007fff90007fff90000f0f00000f0f00000f0f00000f0f00000f0f00000f0f00000f0f00000f0f000
f1ff1f90f1ff1f90f1ff1f90ffffff90f1ff1f90f1ff1f90f1ff1f90fff1f190007ff900007ff900007ff900007ff900007fff00007ff900007ff900007ff900
ffffff90ffffff90ffffff90f1ff1f90ffffff90f1ff1f90ffffff90ffffff900f1f1f900f1f1f900f1f1f900ff1f1900fffff900f1f1f900f1f1f900f1f1f90
ff11ff90ff11ff90ff11ff90ff11ff90ff11ff90ff11ff90ffffff90ffffff900fffff900fffff900fffff900fffff900ff1f1900fffff900fffff900fffff90
ff11ff90ff11ff90ff11ff90ffffff90ffffff90ffffff90ff11ff90ff1fff900ff11f900ff11f900ff11f900ff11f900fff1f900ff1ff900fff1f900f1fff90
0ffff9000ffff9000ffff9000ffff9000ffff9000ffff9000ffff9000ffff90000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff00
00d0000000000d000000000000000000000000000000000000000000000000000060000000000600000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090000000900000009000000090000000900000009000000090000000900000f0000f00f0000f00f0000f00f0000f00f0000f00f0000f00f0000f00f0000f0
07fff90007fff90007fff90007fff90007fff90007fff90007fff90007fff900007fff00007fff00007fff00007fff00007fff00007fff00007fff00007fff00
0f1f19000f1f19000f1f19000f1f19000ffff9000ffff90001f1f9000ffff9000f1f1fa00f1f1fa00f1f1fa00f1f1fa00ff1f1a00f1f1fa00fffffa00ff1f1a0
0ffff9000ffff9000ffff9000f1f19000f1f190001f1f9000ffff9000f1f19009fffff999fffff999fffff999fffff999ff1f1999fffff999f1f1f999fffff99
0f11f9000f11f9000f11f9000ff1f9000ff1f9000f1ff9000ffff9000ffff9000ff22f900ff22f900ff22f900fff2f900fffff900ff2ff900ff2ff900ff22f90
03ff9d000dff930000ff900000ff900000ff900000ff900000ff900000ff900000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff00
0d00000000000d000000000000000000000000000000000000000000000000000030000000000300000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111111111111111111111111001111111111100111111111111000000000111111111111001111111111110011111111111111111111111100000000000000
00111111111111111111111111001111111111100111111111111000000000111111111111001111111111110011111111111111111111111100000000000000
11117777777711117777777711111177777771111117777777711000000000117777777711111177777777111111777777771111777777771111000000000000
11117777777711117777777711111177777771111117777777711000000000117777777711111177777777111111777777771111777777771111000000000000
11666611666611111166661111116666111111111666611666611111111111111166661111116666116666111166661166661111666611666611000000000000
11666611666611111166661111116666111111111666611666611111111111111166661111116666116666111166661166661111666611666611000000000000
11555555555511001155551100115555110000011555511555511115555511001155551100115555555511111155551155551111555511555511000000000000
11555555555511001155551100115555110000011555511555511115555511001155551100115555555511111155551155551111555511555511000000000000
11666611111111111166661111116666111111111666611666611111111111001166661100116666116666111166661166661111666611666611000000000000
11666611111111111166661111116666111111111666611666611111111111001166661100116666116666111166661166661111666611666611000000000000
11777711000000117777777711117777777771111777777771111000000000001177771100117777117777111177777777111111777711777711000000000000
11777711000000117777777711117777777771111777777771111000000000001177771100117777117777111177777777111111777711777711000000000000
11111111000000111111111111111111111111111111111111100000000000001111111100111111111111111111111111110011111111111111000000000000
11111111000000111111111111111111111111111111111111100000000000001111111100111111111111111111111111110011111111111111000000000000
000000000000000000000000000000000000000000000000000000000c0000c00b0000b00a0000a0080000807000000970000009700000097000000900000000
000000000000000000000000000000000000000000cd10000000000000aaa90000aaa90000aaa90000aaa900aa7aa999aa7aa999aa7aaa99aa7aaa9900000000
0000700000700070000007000000000000100000077cd10000070000077777700777777007777770077777709a9191989a9191989aaaaa989aaaaa9800000000
00007000000707000000c7c00000000001d1000000cd100000c7c000077878700787877007878770078787700aaaaa900aaaaa900aaaaa900aaaaa9000000000
00777770000070000000dcd0000000000dcd000000000000000cd100c777777cb777777ba777777a87777778000a9000000a9000000a9000000a900000000000
000070000007070000001d10001dc0000c7c000000000000000010000aaaaa900aaaaa900aaaaa900aaaaa9007aaa90000aaa9900aaaa9900aaaa99000000000
00007000007000700000010001dc770000700000000000000000000000aaa90000aaa90000aaa90000aaa90000ad9a9007ad9a0007aa9a9007aa9a9000000000
000000000000000000000000001dc0000000000000000000000000000c0000c00b0000b00a0000a0080000800000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000807ee800007ee808807ee800007ee80800000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000e6eeee8886eeee8ee6eeee8886eeee8e00000000000000000000000000000000
000000000070000000007000000007000007000000000000000000000007000006eeee8ee6eeee8006eeee8ee6eeee8000000000000000000000000000000000
00000000000700000000700000007000007770000007000000077000000700000e7e7e800e7e7e800eeeee800eeeee8000000000000000000000000000000000
00777700000070000000700000070000000700000000000000077000000700000eeeee800eeeee800eeeee800eeeee8000000000000000000000000000000000
000000000000000000007000000000000000000000000000000000000000000000eee80000eee80000eee80000eee80000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000050000800000000005000080000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000080000000000500008000000000050000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
e9e9e9e9e9e9e9e9e9e9e9e90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9e9e9e9e9fbfbfbe9e9e9e9e9e9e9e900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50e9e9e9e9e9e9e9e9e9e900e9e9e9e900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5000000000000000000000e9e9e9e9e900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0101000030500315303453032532395323553234532335323253231532365323153033530315303a5313b5313b5313a53133532395313b5313653131530385303953038530335303b530375303b5303253030500
0003000022750207501c7501775014750107500a75005750007500075000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400003414032140301402b14024140201400110010100081000310000100001000920004200012002f3002f3002e3002e30000400150000040000000000000c00000000110000000015000110000000000000
000100003d0403c0403b0403b0403a0403a040390403904036040330402e040270401f0400c04002040000400003000020000100000000000227002070020700207001d7001d7001d7001d7001d7001d7001d700
001100000675006750067500675006750067500675006750067500675006750067500675006750067000670006700067000670006700067000670020000200001d0001d0001d0001800018000180001800018000
000500003f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f7203f720
0001000037530385303b5303d5303f5303e5303d5303a530395303653033530305302b5302453019530125300d530045300070036700347002e7002a70023700187000c700037000070000000000000000000000
000200000555031400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003e1403b24034230302302b2302723024230212301e230311202d15028150211500e2500a25007250072502a1502815021150161301445014450114500e4500a450044500245036300363003630037300
000300003f45037450314501f450314503745031450374503145031450324502f4502c4502b4502545024450264401b4301942015410000000740000000000000840006400054000440003400024000140000400
000200000a15015450104500b450054501b430144201c42023450164500f4500d4500f4500a4500c4500e45006450034400243002430024300242002420024100241017300103000730002300003000000000000
0010001f3f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f7103f710
011c000021770217712177122771227712277121771217711d7711d7711d7611d7511d7411d7311d7211d71120700207012270122701227012070120701207011d7011d7011d7011d7011d7011d7011d70100000
011900000c055110051105511005150551105517005110050c05511005110551100514055110550c005000050c055000051105500005150551105500005000050c05500005110550000515055110550000500005
011900000c235003351123505335152351133509235053350c235003351123505335142351133508235053350c555007551155505755155551175509555057550c55500755115550575515555117550955505755
011900002153021530215301f5301f5311f53221531215321d5301d5301d5301d5301d5301d5301d5301d53020530205302053022531225322253120532205301d5301d5301d5301d5301d5301d5301d5301d530
011900002175021751217511f7511f7511f75121751217511d7511d7511d7511d7511875118751187511875120751207512075122751227512275120751207511d7521d7521d7521d75218752187521875218752
0119000021055210552105522055220552205521055210551d0551d0551d055180551805518055180551805520055200552005522055220552205520055200551d0551d0551d0551805518055180551805518055
011900001d7551d7551d755217552175521755247552475525755257552575525755257552575525755257551d7551d7551d75521755217552175524755247552675526755267552675526755267552675526755
0119000005573055030b573055730050305503005730850305573005030b573055730050305503005730050305573055030b573055730050305503005730850305573055030b5730557300503055030057308503
001900000c555001551155505155155551115509555051550c555000551155505055145551105508555050550c555001551155505155155551115509555051550c55500055115550505515555110550955505055
001900001850518500000050000500005000000000000000097450a745097450074500745007450074500745397353a7353973530735307353073530735307353070530705307050030500105000000000000000
001900000c555001551155505155155551115509555051550c555000551155505055145551105508555050550c545001451154505135155351113509535051250c52500025115250501515515110150951505015
00190000055730c5000b573055730e5003b605005730850305573005030b573055730050305503005730050305573055030b573055730050305503005730850305573055030b5730557300503055030057308503
011900000577205772057720977209772097720077200772017720177201772017720177201772017720177205772057720577209772097720977200772007720277202772027720277202772027720277202772
01190000117731170317773117730c7030c7210c77314703117730c70317773117730c7030c7210c7730c703117731170317773117730c7030c0210c77314703117731170317773117730c7030c0030c77314703
011100000c0530c6000c770246050c0532460530615000000c0530000000000000000c0530000000000000000c053000000f770000000c0530000030615000000c0530000000000000000c053000000000000000
011100000c0530c6000c770246050c0532460530615000000c05300000000000c7750c0530000000775000000c053000000f770000000c0530000030615000000c0530000000000007750c053007750000000775
011100000c0533f2130c7700c3250c0530c325306150c3250c0530c3253f7150c7750c0533f21300775000000c0530c3250f770004250c0533f71530615000000c053000003f213007750c053007753f71500775
011100000c1533f2130c7700c3250c1530c325306150c3250c0530c3253f7150c7750c0533f21300775000000c0530c3250f770004250c0533f71530615000000c053000003f213002750c053007753f21500000
011100000c3553f2130c7700c3250c1550c325306150c325181200c3253f7150c7750c0533f213007750f1250c0530c3250f770004250c0533f715306150f1250c0530f1223f213241210c153007753f21524221
01110000307300c7000c700307300c700307300f7000f7000f7000f7000f7000f7000f700197001a7001b70031730187001870033730187001870021700187001870018700187001870021700187001870000000
01110000227501a7000c700187500c700187500f7000f7000f7000f7000f7000f7000f700197001a7001b7002175018700187001b550187001b75021700187001b42218700187001870021700187001870000000
011100001b4311a7000c700187600c7001b4320f7000f7000f7000f7000f7000f7000f700197001a7001b7001b43218700187001b550187001b43221700187002243218700187001870021700187001870000000
011100001b4211a7001c750183300c7001b4220f7000f7000f7000f7000f7000f7000f700197001a7001b7001b42218700197501b550187001b422217001870022422187001c2350c75021700187001870000000
0111000024320287500c700303200c7001b4220f7000f700284200f7001b7500f7500f700197001a7001b7001b42218700187001b550187001b42221700187002242218700337302773021700187001870000000
0111000028222305222d22234722242223972228222307223932228722303222d72234322247223932228722245223972228522307222d52234722245223972228322307222d3223452224322395222832230722
011100001f5651b762185651f7651b565187621f5621b765185651f7651b565187651f5621b762185651b7651d5651b762185651d7651b565187621d5651b765185621d7651b565187621d5651b765185651d765
0111000018545183550056018565255000c552182651855525500185551d500215001d50025500215001e5001b2451b545005551b24521500187551b2551a5451d5051a255215000000000000000000000000000
011100000036500365083000530000365003650530024300033650336507305003050336503365003050230507365073650230507305073650736507305003050236502365003050030502365023650030500305
0111000024552005350c700305520c700305523f7000f7000f7000f7000f7000f7000f700197001a7001b7001945218700187000f452187001870021700187001870018700187001870021700187001870000000
0119000005573041650b573055730404304043005730400305573041650b573055730404304043005730400305573041650b573055730404304043005730850305573041650b5730557304043040430057308503
011900001532015320153201332013321133221532115322113201132011320113201132011320113201132014320143201432016321163221632114322143201132011320113201132011320113201132011320
011900002134021341213411f3411f3411f34121341213411d3411d3411d3411d3411834118341183411834120341203412034122341223412234120341203411d3421d3421d3421d34218342183421834218342
011900002d4252d4252d4252e4252e4252e4252d4252d42529425294252942524425244252442524425244252c4252c4252c4252e4252e4252e4352c4252c4252942529425294252442524425244252442524425
011900001d2251d2251d225212252122521225242252422525225252252522525225252252522525225252251d2251d2251d22521225212252122524225242252622526225262252622526225262252622526225
000200003275032750327503275032750327501c750327503175010750317503175031750317503175030750307502f750107500d7500b7500975007750067500475002750007500000000000000000000000000
011900000c15518555111551d555151551d555151551d555005550c1550555511155085551115508555111550c155005551115505555151551155509155055550c15500555111550555515155115550915505555
0119000018755117551575222755157551175218755117550c7521d7551575216755217551675215755227550c752117552175516752157551d7550c752117552175516752157552275515752167551d7550d752
011900000977509775097750a7750a7750a775097750977505775057750577500775007750077500775007750877508775087750a7750a7750a77508775087750577505775057750077500775007750077500775
011900002075520755207551b7551b7551b7551b755207551e7551e7551e755187551875518755197551b7552075520755207551b7551b7551b7551b755207551e7551e7551e755187551875518755197551b755
01190000111431110317143111430c7030c1210c14323743111430c70317143111430c7030c1210c14323743111431170317143111430c7030c1210c14323743111431170317143111430c703237430c14323743
00190000112031110317425111030c7030c1010c1030b345111030c70317775111030c7030c1010c10317775111031170317775111030c7030c1010c10317775111031170317775111030c703177750c10317775
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
01 0d 42 43 44
01 0e 13 43 44
00 14 13 43 44
00 14 42 43 44
00 14 13 15 44
00 41 16 13 44
00 0f 31 43 44
00 14 13 0f 44
00 14 17 0e 44
00 30 19 43 44
00 11 19 43 44
00 12 42 43 44
00 41 19 43 44
00 31 33 31 44
00 0f 33 43 44
00 12 13 43 44
00 18 42 43 44
00 18 2f 43 44
00 18 2f 17 44
00 18 14 43 2a
00 41 14 13 44
00 41 14 19 2c
00 41 14 43 2d
00 18 42 13 44
00 41 30 13 44
02 19 42 30 44
00 1a 42 43 44
01 1b 42 43 44
01 1c 42 43 44
00 1c 42 43 44
00 1d 42 43 44
00 1d 1e 43 44
00 1e 1c 43 44
00 1e 1f 43 44
00 1e 1f 43 44
00 1d 20 43 44
00 1c 21 43 44
00 1e 21 43 44
00 1d 22 43 44
00 1a 23 43 44
00 1b 23 43 44
00 1e 42 43 44
00 1d 42 43 44
00 1e 42 43 44
00 1d 24 43 44
00 1c 24 43 44
00 1d 42 43 44
00 1e 42 43 44
00 1e 24 43 44
00 1e 25 43 44
00 1e 25 43 44
00 1e 26 43 44
00 1e 26 43 44
00 1d 42 43 44
00 1c 27 43 44
00 1d 27 43 44
00 1e 25 43 44
00 1d 25 43 44
00 1c 1f 43 44
00 1c 1f 43 44
00 1d 21 43 44
00 1c 21 43 44
00 1e 23 43 44
02 1d 23 43 44
