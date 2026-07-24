pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--luccica the witch
--presented by nylon-1919
--general
version=1.1

function _init()
 cartdata("luccicathewitch")
 if version==dget(1) then
  hscore=dget(0)
 else
  hscore=0
 end
 dset(1,version)
 score=0
 curs=0
 resetscore=false
 init_menu()
 if dget(2)==0 then
  auto=true
 else
  auto=false
 end
 music(48)
 menuitem(1,"back to menu", init_menu)
 menuitem(2,"reset score", reset_score)
end

function _update60()
 if resetscore then
  if btnp(Ž) then
   resetscore=false
   sfx(10)
  elseif btnp(—) then
   dset(0,0)
   hscore=0
   resetscore=false
   sfx(1)
   shake=2
  end
 elseif game==0 then
  update_menu()
 elseif game==2 then
  update_prc()
 else
  if gameclear then
   game_clear()
  elseif pl.life>0 then
   update_game()
   if (pl.life<=0) new_score()
  else
   game_over()
  end
  foreach(ptcl,update_ptcl)
  foreach(smoke,update_smoke)
  foreach(wind,update_wind)
  foreach(spore,update_spore)
  foreach(denemy,update_dheri)
  if pl.slow>30 then
   wt+=0.125
  else
   if (wt%1>0) wt=flr(wt)+1
   wt+=1
  end
  wt%=3072
  gt+=1
  gt%=8
 end
end

function _draw()
 if game==0 then
  draw_menu()
 elseif game==1 then
	 draw_game()
 else
	 draw_prc()
	end
	if resetscore then
	 rect(16,48,111,79,1)
	 rectfill(17,49,110,78,0)
	 print("++if you accept reset++",18,50,7)
	 print("++you lose score data++",18,56,7)
	 print("cancel(back to game):Ž",18,64,12)
	 print("reset score:—",18,72,8)
	end
end

function init_menu()
 if (game==1) music(48)
 new_score()
 score=0
 game=0
 shake=0
 t=0
 title=-56
end

function update_menu()
 if (btnp(”)) curs-=1 sfx(10)
 if (btnp(ƒ)) curs+=1 sfx(10)
 if (btnp(‹) or btnp(‘)) auto=not auto dset(2,1-dget(2)) sfx(2)
 if title<16 then
  title+=(16-title)/4
  if (abs(title-16)<1) title=16 shake=2 sfx(1)
 end
 curs%=2
 t+=1
 t%=16
 if btnp(Ž) then
  if curs==0 then
   pl_small_init()
   init_game(1)
  elseif curs==1 then
   init_prc()
  end
  game=curs+1
  sfx(0)
 end
end

function draw_menu()
 cls()
 shake_cam()
 spr(73,title,16,7,4)
 local col={}
 for i=1,2 do
  col[i]=7
 end
 col[curs+1]=8
 spr(flr(t/4)*2,28,72,2,2)
 rect(62,62,104,78,1)
 print("game start",64,64,col[1])
 print("practice",64,72,col[2])
 print("press Ž or z",64,96,13)
 if auto then
  print("‹  auto  ‘",64,120,13)
 else
  print("‹ manual ‘",64,120,13)
 end
 print("score: "..hscore.."0",64,108,7)
end

function reset_score()
 resetscore=true
 shake=2
 sfx(1)
end
-->8
--game


function init_game(k)
 stg=k
 init_obj()
 if k==2 then
  table={}
  for i=0,27 do
   table[i+1]=i
  end
 end
 esp=0
 got=0
 bwe=0
 alldeath=true
 bonus=0
 music((stg-1)*8)
end

function init_obj()
 init_pl()
 shot={}
 eshot={}
 ptcl={}
 enemy={}
 denemy={}
 mp={}
 smoke={}
 wind={}
 spore={}
 ebeam={}
 boss={}
 shake=0
 t,wt,gt=0,0,0
 gameclear=false
end

function update_game()
 update_pl()
 stage()
 foreach(mp,update_mp)
 update_attack()
 pl.x=limit(pl.x,8,119)
 pl.y=limit(pl.y,16,119)
 t+=1
end

function update_attack()
 foreach(shot,update_shot)
 foreach(eshot,update_eshot)
 foreach(fire,update_fire)
 foreach(bomb,update_bomb)
 foreach(sword,update_sword)
 foreach(beam,update_beam)
 foreach(ebeam,update_ebeam)
end

function draw_game()
 cls()
 draw_back(stg)
 shake_cam()
 if stg==1 and t<180 then
  local c=t%8+8
  line(48,0,48,135,c)
  print("auto mp line",50,112,c)
 end
 foreach(wind,draw_wind)
 foreach(boss,draw_boss)
 draw_obj()
 draw_ui()
end

function game_over()
 pl_flag()
 pl.s=10
 slow=1
 if (pl.x>-8) pl.x-=2
 if (pl.y<135) pl.y+=1
 update_attack()
 foreach(enemy,e_move)
 all_del(fire)
 all_del(bomb)
 all_del(beam)
 all_del(sword)
 all_del(mp)
 if got<60 then
  got+=1
 elseif btnp(—) then
  init_menu()
 elseif btnp(Ž) then
  score=0
  pl_small_init()
  init_game(1)
 end
 foreach(boss,boss_mot)
end

function game_clear()
 pl.vmax=2
 pl_flag()
 pl_mot()
 pl_movex()
 pl_movey()
 foreach(mp,update_mp)
 foreach(shot,update_shot)
 all_del(enemy)
 all_del(fire)
 all_del(bomb)
 all_del(beam)
 all_del(sword)
 all_del(denemy)
 all_del(eshot)
 all_del(ebeam)
 foreach(boss,clear_boss)
end

function dist(a,b)
 return sqrt((a.x-b.x)^2+(a.y-b.y)^2)
end

function draw_back(n)
 circfill(24,24,8,9)
 circfill(22,22,6,10)
 if n==1 then
  for i=0,4 do
   for j=0,8 do
    sspr(64,32,8,16,i*32-(wt%32),j*16,8,16)
    sspr(64,32,8,16,i*32-(wt%32)+8,j*16,10,16,true,true)
   end
  end
  pal(1,2)
  for i=0,2 do
   for j=0,8 do
    sspr(64,32,8,16,i*64-2*(wt%32),j*16,12,16)
    sspr(64,32,8,16,i*64-2*(wt%32)+12,j*16,14,16,true,true)
   end
  end
  pal()
 elseif n==2 then
  cls(12)
  for i=0,5 do
   sspr(32,64,32,64,i*32-2*(wt%32),52,32,80)
  end
 else
  rectfill(0,70,127,127,1)
  for j=0,2 do
   local w,y=4*2^j,72+8*(2^j-1)
   local term=(2+j)*(wt%(3*w))
   for i=0,13-4*j do
    local x=i*3*w-term
    sspr(48,48,16,8,x,y,2*w+1,w)
    rectfill(x,y+w,x+2*w,128,13)
    fillp(„)
    if (gt%2==0) rectfill(x,y+w,x+2*w-1,127,10)
    fillp()
    rect(x,y+w,x+2*w,128,6)
   end
  end
 end
end

function draw_obj()
 foreach(bomb,draw_bomb)
 foreach(sword,draw_sword)
 foreach(shot,draw_shot)
 foreach(eshot,draw_eshot)
 foreach(ebeam,draw_ebeam)
 foreach(fire,draw_fire)
 foreach(enemy,draw_enemy)
 foreach(denemy,draw_denemy)
 foreach(mp,draw_mp)
 draw_pl()
 foreach(beam,draw_beam)
 foreach(smoke,draw_smoke)
 foreach(ptcl,draw_ptcl)
end

function draw_ui()
 camera()
 rectfill(0,0,127,6,1)
 line(0,7,127,7,13)
 fillp(™)
 line(0,7,127,7,5)
 fillp()
 print("score:"..score.."0",2,1,7)
 print("hp",76,1,7)
 rectfill(84,1,93,5,0)
 local hpc=11
 if (pl.life<=20) hpc=8
 if pl.life>0 then
  rectfill(84,1,83+pl.life/10,5,hpc)
 end
 print("mp",98,1,7)
 rectfill(106,1,125,5,0)
 if abs(pl.mp-50)<50 then
  rectfill(106,1,106+pl.mp/5,5,14)
 elseif pl.mp==0 then
  print("NOMP",108,1,7)
 elseif pl.mp==100 then
  rectfill(106,1,125,5,8+wt%8)
  print("MAX",110,1,7)
 end
 if gameclear then
  print("stage clear",44,57,7)
  print("next:Ž",50,65,7)
  print("clear bonus +"..bonus.."0",30,75,6)
  if (alldeath) print("all death +500",36,83,6)
 elseif pl.life<=0 then
  print("game over",46,57,8)
  print("restart:Ž",44,65,8)
  print("back to menu:—",34,73,8)
 end
 foreach(boss,draw_boss_gauge)
end

function all_del(table)
 for a in all(table) do
  add_ptcl_8(a)
  del(table,a)
 end
end

function new_score()
 if (score>hscore) hscore=score
 dset(0,hscore)
end

function shake_cam()
 if shake>0 then
  local x,y=myrnd(shake),myrnd(shake)
  camera(x,y)
  shake*=0.95
  if (shake<0.5) shake=0
 end
end

function move(a,b)
 if b then
  a.x+=a.vx/slow
  a.y+=a.vy/slow
 else
  a.x+=a.vx
  a.y+=a.vy
 end
end

function limit(x,a,b)
 return max(a,min(x,b))
end

function myrnd(x)
	return rnd(2*x)-x
end

function frnd(x)
	return flr(rnd(x))
end
-->8
--player


function init_pl()
 pl.x,pl.y,pl.s,pl.mt=36,80,0,0
 pl.vx,pl.vy,pl.vmax=0,0,2
 pl.sf,pl.df,pl.spf,pl.birdf=0,0,0,0
 pl.slow,pl.miss=0,0
 bomb={}
 beam={}
 fire={}
 sword={}
 slow=1
end

function pl_small_init(x)
 if (x==nil) x=0
 pl={} 
 pl.life,pl.mp=100,x
end

function update_pl()
 pl_flag()
 if pl.slow>30 then
  slow=8
 else
  slow=1
 end
 if abs(pl.birdf-90)<90 then
  pl.vmax=4
 elseif #beam==0 then
  pl.vmax=2
 else
  pl.vmax=0.75
 end
 for s in all(spore) do
  if abs(s.x-pl.x)+abs(s.y-pl.y)<14 then
   pl.vmax=max(0.5,pl.vmax/4)
  end
 end
 if pl.miss<30 then
  pl_movex()
  pl_movey()
 end
 pl_shot()
 pl_spe()
 pl_mot()
end

function pl_movex()
 if pl.vx<pl.vmax and btn(‘) then
  pl.vx+=0.5
 end
 if pl.vx>-pl.vmax and btn(‹) then
  pl.vx-=0.5
 end
 if abs(pl.vx)>pl.vmax then
  pl.vx=pl.vmax*(pl.vx/abs(pl.vx))
 elseif abs(pl.vx)>0.25 then
  if not(btn(‹) or btn(‘)) then
   pl.vx*=0.7
  end
 else
  pl.vx=0
 end
 pl.x+=pl.vx
 pl.x=limit(pl.x,8,119)
end

function pl_movey()
 if pl.vy<pl.vmax and btn(ƒ) then
  pl.vy+=0.5
 end
 if pl.vy>-pl.vmax and btn(”) then
  pl.vy-=0.5
 end
 if abs(pl.vy)>pl.vmax then
  pl.vy=pl.vmax*(pl.vy/abs(pl.vy))
 elseif abs(pl.vy)>0.25 then
  if not(btn(”) or btn(ƒ)) then
   pl.vy*=0.7
  end
 else
  pl.vy=0
 end
 pl.y+=pl.vy
 pl.y=limit(pl.y,16,119)
end

function pl_shot()
 if btn(Ž) or auto then
  if (pl.sf==0 and #beam==0) add_shot()
  add_ptcl_shot()
 end
end

function pl_spe()
 if btn(—) and pl.spf>=0 then
  pl.spf+=1
  local success,unsuccess=false,false
  if btn(‘) then
   if (pl.mp>=60) pl.birdf=210 sfx(6)
   use_mp(60,240)
  end
  if btn(‹) then
   if (pl.mp>=40) add_beam()
   use_mp(40,150)
  end
  if btn(ƒ) then
   if (pl.mp>=30 and pl.slow==0) pl.slow=150 sfx(9)
   use_mp(30,15)
  end
  if btn(”) then
   if (pl.mp>=20) add_sword()
   use_mp(20,60)
  end
  if pl.spf==5 then
   if (pl.mp>=20) add_bomb()
   use_mp(20,60)
  end
  if unsuccess and not success then
   pl_miss()
  end
 elseif pl.spf>0 then
  if pl.mp>=20 then
   add_bomb()
   pl.mp-=20
   pl.spf=-60
  else
   pl_miss()
  end
 end
end

function pl_miss()
 pl.spf=-60
 pl.miss=60
 add_ptcl_damage()
 add_smoke()
 sfx(1)
end

function use_mp(a,b)
 if pl.mp>=a then
  pl.mp-=a
  pl.spf=-b
  success=true
 else
  unsuccess=true
 end
end

function pl_flag()
 if (pl.sf>0) pl.sf-=1
 if (pl.df>0) pl.df-=1
 if (pl.spf<0) pl.spf+=1
 if (pl.slow>0) pl.slow-=1
 if (pl.miss>0) pl.miss-=1
 if pl.birdf>0 then
  if (pl.birdf==181) pl.df=0 add_fire()
  pl.birdf-=1
  if pl.birdf==0 then
   sfx(7)
   shake=1
   pl.df=20
   add_fire()
  end
 end
end

function pl_mot()
 pl.mt+=1
 if #beam>0 then
  if (beam[1].t>0) pl.mt+=1
 end
 pl.mt%=16
 pl.s=2*flr(pl.mt/4)
 if pl.df>32 then
  pl.s=10
 elseif pl.df>30 then
  pl.s=8
 end
 if abs(pl.birdf-90)<90 then
  if abs(pl.vx)>1 then
   pl.s=32+flr(pl.birdf%8/4)*2
  else
   pl.s=32+flr(pl.birdf%20/10)*2
  end
 end
 if pl.miss>30 then
  pl.s=min(14,8+2*flr((pl.miss-31)/4))
 end
end

function pl_damage(a)
 sfx(1)
 if abs(pl.birdf-91)<91 then
  shake=1
  pl.df=20
  add_fire()
 elseif #beam==0 then
  pl.life-=a
  pl.df=90
  shake=3
  add_ptcl_damage()
 end
end

function add_ptcl_damage()
 for i=0,7 do
  local p={}
  p.x=pl.x+4*cos(i/8)
  p.y=pl.y+4*sin(i/8)
  p.vx=cos(i/8)
  p.vy=sin(i/8)
  p.t=20
  p.col=7+3*(i%2)
  p.r=i/2
  add(ptcl,p)
 end
end

function draw_pl()
 if #beam>0 then
  if (beam[1].t%2==1) pal(8,9)
 end
 local bird=min(abs(pl.birdf-190)/2,abs(pl.birdf-5))
 if bird<5 then
  circfill(pl.x,pl.y,bird+2,pl.birdf%8+8)
 else
  if (pl.df%2==0) spr(pl.s,pl.x-8,pl.y-8,2,2)
 end
 pal()
end
-->8
--shot


function add_shot()
 pl.sf=4
 local l=2
 if (pl.slow>30) pl.sf=2 l=4
 local s={}
 s.x=pl.x+4
 s.y=pl.y+l*sin(t%30/30)
 add(shot,s)
 sfx(0)
end

function add_eshot(e)
 local s={}
 s.x=e.x-4
 s.y=e.y-2
 local d=dist(s,pl)
 s.vx=0.5*(pl.x-s.x)/d
 s.vy=0.5*(pl.y-s.y)/d
 add(eshot,s)
end

function add_ptcl_shot()
 local p={}
 p.x=pl.x+8
 p.y=pl.y
 p.r=0
 p.col=7
 p.t=6
 p.vx=rnd(1)-0.5
 p.vy=rnd(1)-0.5
 add(ptcl,p)
end

function update_shot(s)
 s.x+=4
 for e in all(enemy) do
  if dist(s,e)<10 then
   e_damage(e,25)
   del(shot,s)
  end
 end
 if s.x>131 or pl.life<=0 then
  del(shot,s)
 end
end

function update_eshot(s)
 move(s,true)
 if abs(dist(pl,s))<8 and not gameclear then
  if (pl.df==0) pl_damage(15)
  del(eshot,s)
 end
 if max(abs(s.x-64),abs(s.y-64))>64 or pl.life<=0 or gameclear then
  del(eshot,s)
 end
end

function update_ptcl(p)
 move(p,false)
 p.t-=1
 if (p.t<=0) del(ptcl,p)
end

function draw_shot(s)
 circfill(s.x,s.y,1,12)
 pset(s.x,s.y,7)
end

function draw_eshot(s)
 circfill(s.x,s.y,2,9)
 circfill(s.x,s.y,1,10)
 for i=1,6 do
  local x=s.x+myrnd(3)
  local y=s.y-myrnd(3-abs(x-s.x))
  local c=2+6*frnd(3)
  pset(x,y,c)
 end
end

function draw_ptcl(p)
 circfill(p.x,p.y,p.r,p.col)
end
-->8
--enemy


function add_enemy(y)
 local e={}
 e.x,e.t,e.mpn,e.life=135,0,3,100
 e.blue=false
 e.bbf=t<4800
 if stg==1 then
  if y==nil then
   e.y=rnd(104)+24
   if t>=2400 and rnd(10)<1 then
    e.blue=true
    e.life,e.mpn=250,10
   end
  else
   e.y=y
  end
 elseif stg==2 then
  e.sf=0
  if y==nil then
   local n=frnd(#table)+1
   e.dp=table[n]
   del(table,table[n])
   e.y=16+flr(e.dp/4)*16+myrnd(4)
   e.dx=64+(e.dp%4)*16+myrnd(4)
   if t>2400 then
    if rnd(10)<1 then
     e.blue=true
     e.life,e.mpn=250,8
    end
   end
  else
   e.dp=y%28
   e.y=16+flr(e.dp/4)*16+(e.dp%4)*2
   e.dx=64+(e.dp%4)*16
   if t>4800 then
    e.blue=true
    e.life,e.mpn=250,5
   end
  end
 else
  e.mpn,e.y=5,y
 end
 add(enemy,e)
end

function add_heri()
 local nsp=1+frnd(4)
 for i=0,6 do
  if (abs(i-nsp)>1) add_enemy(16*i+20)
 end
 esp=50
end

function add_dheri(a)
 local e={}
 e.x,e.y,e.t=a.x,a.y,a.t
 add(denemy,e)
end

function add_ptcl_8(a)
 for i=0,7 do
  local p={}
  p.x,p.y,p.r,p.col,p.t=a.x,a.y,2,7,10
  p.vx,p.vy=cos(i/8),sin(i/8)
  add(ptcl,p)
 end
end

function update_enemy(e)
 if e.life<=0 then
  death_enemy(e)
 else
  e_move(e)
  e_attack(e,20)
 end
end

function update_dragon(e)
 if e.life<=0 then
  add(table,e.dp)
  death_enemy(e)
 else
  if e.t>300 then
   e.x-=(1-0.5*sin(e.t/50))/slow
   if (e.x<-8) del(enemy,e)
  elseif e.x>e.dx then
   e.x-=1/slow
  else
   e.sf+=1/slow
   if e.sf>=60 then
    e.sf=0
    add_eshot(e)
   end
  end
  e_attack(e,20)
  e.t+=1/slow
 end
end

function update_dheri(e)
 if (e.x<-8) del(denemy,e)
 e.x-=0.5/slow
 e.y+=0.125/slow
 e_attack(e,15,2)
 e.t+=1/slow
end

function e_move(e)
 if stg==1 then
  local vx,vy=1,0.5
  if (e.blue) vx/=4 vy/=4
  e.x-=vx/slow
  e.y+=vy*sin(e.t/120)/slow
 elseif stg==2 then
  e.x-=2-sin(e.t/50)
 else
  e.x-=1.5/slow
  if (e.t>30) e.y-=(e.t-20)/(16*slow)
  if (e.y<0) del(enemy,e)
 end
 e.t+=1/slow
 if e.x<-8 then
  if (e.bbf) alldeath=false
  del(enemy,e)
 end
end

function e_attack(e,a,r)
 if (r==nil) r=1
 if max(abs(pl.x+2-e.x)*2,abs(pl.y-e.y)*r)<14 then
  if (r==1) pl.x+=(pl.x-e.x)/2
  if (pl.df==0) pl_damage(a)
 end
end

function e_damage(e,a)
 e.life-=a
 sfx(2)
end

function death_enemy(e)
 add_ptcl_8(e)
 if (bwe<50) score+=1
 if (not e.bbf) bwe+=1
 for i=1,e.mpn do
  add_mp(e.x+myrnd(4),e.y+myrnd(4))
 end
 if (stg==3) add_dheri(e)
 del(enemy,e)
end

function draw_enemy(e)
 local k=flr(e.t%30/15)
 if stg==1 then
  if e.blue then
   pal(8,12)
   pal(14,7)
   pal(2,1)
  end
  spr(36+2*k,e.x-8,e.y-8,2,2)
 elseif stg==2 then
  if e.blue then
   pal(8,3)
   pal(2,1)
   pal(14,11)
  end
  local s=0
  if (abs(e.sf-30)>24) s=4
  spr(40+2*k+s,e.x-8,e.y-8,2,2)
 elseif stg==3 then
  k=flr(e.t%4/2)
  spr(64+2*k,e.x-8,e.y-8,2,2)
 end
 pal()
end

function draw_denemy(e)
 k=flr(e.t%4/2)
 spr(70+16*k,e.x-8,e.y-4,2,1)
end
-->8
--special


function add_bomb()
 local b={}
 b.x,b.y,b.t=min(pl.x+32,127),128,0
 add(bomb,b)
 pl.spf=-60
 shake=6
 sfx(3)
end

function add_beam()
 local b={}
 b.x,b.y,b.r,b.t=pl.x+8,pl.y,0,0
 add(beam,b)
end

function add_fire()
 for i=0,15 do
  local f={}
  f.x,f.y,f.t=pl.x,pl.y,0
  f.vx,f.vy=6*cos(i/16),6*sin(i/16)
  add(fire,f)
 end
end

function add_sword()
 for i=1,4 do
  local s={}
  s.x,s.y,s.t=pl.x+((128-pl.x)/5)*i,-8,-8*i
  add(sword,s)
 end
end

function update_bomb(b)
 if b.t<4 then
  b.y-=32
 elseif b.t>26 then
  b.y+=32
 end
 if (b.y>128) del(bomb,b)
 for e in all(enemy) do
  if abs(e.x-b.x)<16 and e.y>=b.y then
   e_damage(e,50)
  end
 end
 for e in all(denemy) do
  if abs(e.x-b.x)<16 and e.y>=b.y then
   add_ptcl_8(e)
   del(denemy,e)
  end
 end
 for e in all(eshot) do
  if abs(e.x-b.x)<11 and e.y>=b.y then
   del(eshot,e)
  end
 end
 b.t+=1
end

function update_beam(b)
 b.x,b.y=pl.x+8,pl.y
 if b.r<8 then
  b.r+=0.125
  sfx(4)
 else
  b.t+=1
  shake=1
  if (b.t==60) del(beam,b)
  sfx(5)
 end
 for e in all(enemy) do
  if dist(b,e)<b.r+8 or (b.t>0 and b.x<e.x and abs(b.y-e.y)<min(b.t/2,7)+6) then
   e_damage(e,200)
  end
 end
 for e in all(denemy) do
  if dist(b,e)<b.r+8 or (b.t>0 and b.x<e.x and abs(b.y-e.y)<min(b.t/2,7)+6) then
   add_ptcl_8(e)
   del(denemy,e)
  end
 end
 for e in all(eshot) do
  if dist(b,e)<b.r+2 or (b.t>0 and b.x<e.x and abs(b.y-e.y)<min(b.t/2,7)+2) then
   del(eshot,e)
  end
 end
end

function update_fire(f)
 move(f,false)
 for e in all(enemy) do
  if abs(f.x-e.x)+abs(f.y-e.y)<14 then
   e_damage(e,25)
  end
 end
 if max(abs(f.x-64),abs(f.y-64))>66 then
  del(fire,f)
 end
end

function update_sword(s)
 s.t+=1
 if s.t>30 then
  s.y+=6
 elseif s.t>0 then
  if (s.y<16) s.y+=2
 end
 if (s.t==0) sfx(8)
 if s.t>0 then
  for e in all(enemy) do
   if max(abs(e.x-s.x)*2,abs(e.y-s.y))<16 then
    e_damage(e,35)
   end
  end
 end
 if (s.y>143) del(sword,s) shake=1
end

function draw_bomb(b)
 rectfill(b.x-9,b.y+4,b.x+9,135,4)
 fillp()
 rectfill(b.x-8,b.y+4,b.x+3,135,5)
 fillp(™)
 rectfill(b.x-8,b.y+4,b.x-2,135,5)
	fillp()
	sspr(0,48,16,16,b.x-12,b.y,24,20)
end

function draw_beam(b)
 circfill(b.x,b.y,b.r,10+b.t%5)
 circfill(b.x,b.y,b.r-1,7)
 if b.t>0 then
  rectfill(b.x,b.y-min(b.t/2,7),130,b.y+min(b.t/2,7),10+b.t%5)
  rectfill(b.x,b.y-min(b.t/2,6),130,b.y+min(b.t/2,6),7)
 end
end

function draw_fire(f)
 for i=1,12+rnd(4) do
  local x,y=f.x+myrnd(8),f.y+myrnd(8-abs(x))
  local w,h,r=rnd(2),rnd(2),rnd(100)
  local c
  if r<50 then c=8
  elseif r<70 then c=2
  elseif r<90 then c=14
  else c=6 end
  rectfill(x-w/2,y-h/2,x+w/2,y+h/2,c)
 end
end

function draw_sword(s)
 if (s.t>0) spr(104,s.x-4,s.y-8,1,2)
end
-->8
--item


function add_mp(x,y)
 local m={}
 m.x,m.y,m.t=x,y,0
 m.f=false
 add(mp,m)
end

function update_mp(m)
 if (pl.x>=48 or pl.miss>0 or #beam>0) m.f=true
 local d=dist(pl,m)
 if d<10 then
  pl.mp+=1
  pl.mp=min(pl.mp,100)
  del(mp,m)
  sfx(10)
 elseif m.f then
  m.x+=4*(pl.x-m.x)/d
  m.y+=4*(pl.y-m.y)/d
 else
  m.x-=4
  if (m.x<-32) del(mp,m)
 end
 m.t+=1
end

function draw_mp(m)
 if m.t%8<6 then
  circfill(m.x,m.y,1,14)
 else
  circfill(m.x,m.y,1,7)
 end
end
-->8
--effect


function add_smoke()
 for i=1,32 do
  local s={}
  s.x=pl.x+myrnd(9)
  s.y=pl.y+10-abs(pl.x-s.x)/2-rnd(8)
  s.t,s.w,s.h,s.col=30-rnd(6),rnd(3),rnd(2),6
  add(smoke,s)
 end
end

function add_wind()
 local w={}
 w.x1,w.x2,w.y,w.t,w.col=128,128,16+rnd(104),0,6*frnd(3)+1
 add(wind,w)
end

function add_ebeam(x,y)
 local b={}
 b.x,b.y,b.r=x,y,1
 local d=dist(b,pl)
 b.vx,b.vy=(pl.x-b.x)/d,(pl.y-b.y)/d
 add(ebeam,b)
end

function update_smoke(s)
 local v=120
 if (s.col==10) v=900
 s.t-=1
 s.y-=s.t/v
 if (s.t<=0) del(smoke,s)
end

function update_wind(w)
 local v=2
 if (pl.slow>=30) v=0.25
 w.x1-=v
 w.x2-=2*v/3
 if (w.x2<=-8) del(wind,w)
end

function update_ebeam(b)
 if b.r<4 then
  b.r+=0.125
  sfx(4)
 else
  move(b,true)
 end
 if dist(pl,b)<6+b.r then
  pl_damage(15)
  add_ptcl_8(b)
  del(ebeam,b)
 end
 if (abs(b.x-64)>64 or abs(b.x-64)>64) del(ebeam,b)
end

function draw_smoke(s)
 if flr(s.t)%2==0 then
  rectfill(s.x-s.w/2,s.y-s.h/2,s.x+s.w/2,s.y+s.h/2,s.col)
 end
end

function draw_wind(w)
	rectfill(w.x1,w.y,w.x2,w.y+2,w.col)
end

function draw_ebeam(b)
 circfill(b.x,b.y,b.r,12)
 circfill(b.x,b.y,b.r-1,7)
end
-->8
--stage


function stage()
 if stg==2 then
  foreach(enemy,update_dragon)
 else
  foreach(enemy,update_enemy)
 end
 foreach(denemy,update_dheri)
 if t<4800 then
  if t%1200<600 then
   if t%300<150 and t<2400 then
    esp=1
   else
    if (esp==0) enemy_spawn()
   end
  else
   if esp==0 then
    if stg==1 then
     add_enemy()
     esp=30
     if (t>=2400) esp=20
    elseif stg==2 then
     if #enemy<21 then
      add_enemy()
     else
      alldeath=false
     end
     esp=20
    else
     add_heri()
     if (t>=2400) esp=30
    end
   end
  end
  if (t==4799) init_boss()
 else
  foreach(boss,update_boss)
  if stg==1 then
   if esp==0 then
    add_enemy()
    esp=30
   end
  elseif stg==2 then
   if esp==0 then
    if t%300<180 then
     esp=1
    elseif t%300<240 and #enemy<8 then
     local k=(t%300-180)/15
     add_enemy(k)
     esp=15
    elseif #enemy<8 then
     local k=(t%300-240)/15
     add_enemy(k+24)
     esp=15
    else
     esp=1
    end
   end
  else
   if (esp==0) add_heri()
  end
 end
 esp-=1
end

function enemy_spawn()
 esp=15
 if stg==2 then
  if t>=2400 or (t<2400 and t%300>179) then
   add_enemy(t/15+8*flr(t/60))
  end
 else
  add_enemy(24+(16+48*flr(t%150/75)+flr(t/300)*42)%104)
  if (stg==3) esp=20
 end
end
-->8
--boss


function init_boss()
 local b={}
 b.x,b.hp=160,20000
 b.df,b.t,b.movep=0,0,0
 if stg==1 then
  b.y,b.h,b.w=129,104,32
 elseif stg==2 then
  b.y=24
 else
  b.x,b.y=-64,32
  b.ax1,b.ay1,b.ax2,b.ay2=-48,72,-56,80
 end
 add(boss,b)
end

function update_boss(b)
 boss_mot(b)
 for s in all(shot) do
  if boss_atari(s,b,1) then
   del(shot,s)
   b.hp-=25
   sfx(12)
  end
 end
 if stg==3 then
  for d in all(denemy) do
   if boss_atari(d,b,4) then
    add_ptcl_8(d)
    del(denemy,d)
    b.hp-=100
    sfx(12)
   end
  end
 end
 if (b.t%840==720) b.movep=frnd(2)
 if b.t%420>=300 then
  if b.movep==0 then
   if (b.t%5==0 and stg==1) add_spore()
   if (b.t%20==0 and stg==2) add_bossfire(b)
   if stg==3 then
    if b.t%420<360 then
     b.ax1-=2*sin(b.t/60)/slow
    else
     b.ax2-=2*sin(b.t/60)/slow
    end
   end
  else
   if b.t%15==0 then
    if (stg<3) add_enemy()
   end
   if (b.t%60==0 and stg==3) add_ebeam(b.x+12,b.y+28)
  end
  if stg==2 then
   pl.x-=0.5
   if (b.t%420<360) add_wind()
  end
 end
 if b.df==0 then
  boss_spe(b)
 else
  b.df-=1
 end
 if b.hp>0 then
  if boss_atari(pl,b,6) then
   if (pl.df==0) pl_damage(25)
  end
 else
  if (alldeath) score+=50
  bonus=(100+flr(100*0.99^flr((t-5400)/60)))
  score+=bonus
  gameclear=true
  new_score()
  b.hp=0
  if stg<3 then
   for i=1,30 do
    add_mp(b.x,b.y)
   end
  end
 end
end

function clear_boss(b)
 local a={}
 if stg==1 then
  if b.h>1 then
   b.h-=1
   b.w+=1
   b.y+=1
   a.x=128-rnd(b.w)
   a.y=128-rnd(b.h)+b.y/8
   add_ptcl_8(a)
   sfx(11)
  else
   b.h=0
   if (btn(Ž)) init_game(2)
  end
 elseif stg==2 then
  if b.y<128 then
   a.x=128-rnd(32)
   a.y=b.y+rnd(128-b.y)
   add_ptcl_8(a)
   sfx(11)
   b.y+=2
  else
   if (btn(Ž)) init_game(3)
  end
 else
  if b.y<128 then
   a.x=b.x+rnd(32)
   a.y=128-rnd(128-b.y)
   add_ptcl_8(a)
   b.x-=1
   b.y+=2
   b.ay1+=2
   b.ay2+=2
   sfx(11)
  else
   if (btn(Ž)) init_menu()
  end
 end
 b.df=0
end

function boss_atari(a,b,r)
 local tf=false
 if stg==1 then
  tf=(a.x+r>b.x-32+0.125*min(abs(a.y-127-b.h/6),abs(a.y-127-b.h/6)) and a.y>127-b.h-r)
 elseif stg==2 then
  tf=(abs(b.x-a.x)<32-abs(a.y-b.y-48)/8+r and abs(a.y-(b.y+48))<48+r)
 else
  tf=((abs(b.x-a.x)<20+max(0,min(a.y-78,6))+r and a.y+r>b.y) or (a.x<b.ax1+r and abs(a.y-b.ay1)<r+8) or (a.x<r+8 and abs(a.y-b.ay2)<r+8))
 end
 return tf
end

function boss_spe(b)
 for bb in all(beam) do
  local atari=false
  if bb.t>0 then
   if stg==1 then
    atari=(bb.y+min(bb.t/2,7)>127-b.h)
   elseif stg==2 then
    atari=(abs(bb.y-b.y-48)<min(bb.t/2,7)+48)
   elseif stg==3 then
    atari=(bb.y+min(bb.t/2,7)>b.y and bb.x<b.x+32)
   end
  end
  if boss_atari(bb,b,bb.r) or atari then
   boss_damage(b,200,2)
  end
 end
 for bb in all(bomb) do
  if abs(bb.x-b.x)<40 and b.y>=bb.y then
   boss_damage(b,50,4)
  end
 end
 for s in all(sword) do
  if boss_atari(s,b,4) then
   boss_damage(b,35,4)
  end
 end
 for f in all(fire) do
  if boss_atari(f,b,4) then
   boss_damage(b,25,4)
  end
 end
end

function boss_damage(b,d,df)
 b.hp-=d
 b.df,shake=df,2
 if (d>35) shake=5
 sfx(12)
end

function boss_mot(b)
 if b.x>128 then
  b.x-=1/slow
  if (b.x<=128) b.x=128
 elseif b.x<0 then
  b.x+=0.5/slow
  if (b.x>=0) b.x=0
 end
 if stg==1 then
  if (t%420>=300 and pl.life>0) v=2
  b.h=104-abs(8*sin(b.t/60))
 elseif stg==2 then
  b.y+=0.5*cos(b.t/120)
 else
  if b.t%420<300 then
   b.ax1=b.x+16*cos(b.t/120+0.25)+40
   b.ay1=b.y+16*sin(b.t/120+0.25)+72
   b.ax2=b.x+16*cos(b.t/120+0.75)+32
   b.ay2=b.y+16*sin(b.t/120+0.75)+80
  end
 end
 b.t+=1/slow
 if (pl.slow<=30 and b.t!=flr(b.t)) b.t=flr(b.t)+1
 if (gameover) b.df=0
end

function add_spore()
 local s={}
 s.x,s.y,s.t=rnd(128),rnd(128),90
 add(spore,s)
end

function add_bossfire(b)
 local s={}
 s.x,s.y=100,b.y+16
 local d=dist(s,pl)
 s.vx,s.vy=0.5*(pl.x-s.x)/d,0.5*(pl.y-s.y)/d
 add(eshot,s)
end

function update_spore(s)
 s.t-=1
 if s.t>80 then
  for i=1,4 do
   local ss={}
   local x=myrnd(8)
   ss.x,ss.y=s.x+x,s.y+myrnd(8-x)
   ss.t=max(40+(i%2)*40,rnd(80))
   ss.w,ss.h,ss.col=rnd(3),rnd(2),10
   add(smoke,ss)
  end
 end
 if (s.t<=0) del(spore,s)
end

function draw_boss(b)
 if stg==1 then
  local k=flr((b.t%30)/15)
  palt(12-k,true)
  pal(11+k,9)
  if (gt%2==0) pal(8,12)
  if (b.df%2==1) pal(15,8) pal(9,2)
  if gameclear and b.h<96 then
   pal(15,7)
   pal(11,6)
   pal(12,6)
   pal(9,6)
   pal(8,7)
   pal(1,6)
  end
  sspr(64,64,32,64,b.x-b.w,b.y-b.h,b.w,b.h)
  palt()
 elseif stg==2 then
  local k=0
  if (b.t%420>=300) k=1
  local l=flr((b.t%30)/15)
  if (b.t%420>=300) l=flr((b.t%8)/4)
  pal(10+k,9)
  palt(11-k,true)
  pal(12+l,2)
  palt(13-l,true)
  if l==0 then
   pal(5,8)
   palt(3,true)
  else
   pal(5,2)
   pal(3,8)
  end
  if (gameclear) pal(7,2) pal(1,2)
  if (b.df%2==1) pal(8,1)
  sspr(96,64,32,64,b.x-32,b.y,32,96)
 else
  rectfill(-8,b.ay1-4,b.ax1-6,b.ay1+3,13)
  rectfill(-8,b.ay1+4,b.ax1-6,b.ay1+5,5)
  spr(98,b.ax1-8,b.ay1-8,2,2)
  local k=flr((b.t%60)/30)
  pal(11+k,8)
  pal(12-k,7)
  sspr(0,64,32,64,b.x-4,b.y+2*sin(b.t/60),32,108)
  rectfill(-8,b.ay2-4,b.ax2-6,b.ay2+3,13)
  rectfill(-8,b.ay2+4,b.ax2-6,b.ay2+5,5)
  spr(98,b.ax2-8,b.ay2-8,2,2)
 end
 pal()
end

function draw_boss_gauge(b)
 rectfill(107,124,126,126,0)
 if abs(b.x-64)>64 and b.hp>0 then
  if b.x>0 then
   rectfill(107,124,126-0.625*(b.x-128),126,3)
  else
   rectfill(107,124,126+b.x*0.3125,126,3)
  end
 elseif b.hp>0 then
  rectfill(107,124,107+(b.hp-1)/1000,126,3)
 end
end
-->8
--practice


function init_prc()
 pl_small_init(100)
 init_obj()
 dmato={}
 howto={}
 stg=0
 for i=0,2 do
  add_mato(i)
 end
 add_howto(0)
end

function update_prc()
 if (pl.mp<100) pl.mp+=1
 update_pl()
 foreach(enemy,update_mato)
 foreach(howto,update_howto)
 foreach(dmato,update_dmato)
 update_attack()
 foreach(ptcl,update_ptcl)
 foreach(smoke,update_smoke)
 if (pl.x<12) init_menu()
 wt+=1
 wt%=8
 t+=1
end

function draw_prc()
 cls(7)
 line(0,0,127,127,6)
 line(127,0,0,127,6)
 for i=2,7 do
  rect(63-i^2,63-i^2,64+i^2,64+i^2,6)
  rect(64-i^2,64-i^2,63+i^2,63+i^2,6)
 end
 rectfill(61,61,66,66,7)
 foreach(howto,draw_howto)
 shake_cam()
 foreach(dmato,draw_dmato)
 foreach(enemy,draw_mato)
 draw_obj()
 draw_ui()
 if (pl.x<=48) print("‹exit",2,120,1)
end

function add_mato(n)
 local e={}
 e.n,e.x,e.y,e.t,e.life=n,64+24*n,64,0,100*(n+1)
 add(enemy,e)
end

function add_dmato(n)
 local e={}
 e.n,e.x,e.y,e.r=n,64+24*n,64,0
 add(dmato,e)
end

function update_mato(e)
 if e.life<=0 then
  add_ptcl_8(e)
  add_dmato(e.n)
  del(enemy,e)
 else
  local v=(2.5-e.n)
  e.t+=1/slow
  e.y+=v*cos(e.t/120)*(-1)^(e.n+1)/slow
  if max(abs(pl.x+2-e.x)*2,abs(pl.y-e.y))<14 then
   if (pl.df==0) pl_damage(0)
   pl.x+=(pl.x-e.x)/2
   pl.vx=-pl.vx
  end
 end
end

function update_dmato(e)
 e.r+=0.25
 if (e.r==4) add_mato(e.n) del(dmato,e)
end

function draw_mato(e)
 ovalfill(e.x-4,e.y-8,e.x+4,e.y+8,8+e.n)
 for i=1,2 do
  oval(e.x-i*1.5,e.y-i*3,e.x+i*1.5,e.y+i*3,5+i)
 end
 print(e.life,e.x,e.y-4,1)
end

function draw_dmato(e)
 ovalfill(e.x-e.r,e.y-e.r*2,e.x+e.r,e.y+e.r*2,8+e.n)
end

function add_howto(n)
 local h={}
 h.x,h.n=128,n
 h.f=true
 if n==0 then
  h.txt="shot:Ž,move:”ƒ‹‘"
 elseif n==1 then
  h.txt="special:—+”ƒ‹‘ or —"
 elseif n==2 then
  h.txt="—:fist of titan 20%"
 elseif n==3 then
  h.txt="—+”:icicle arrow 20%"
 elseif n==4 then
  h.txt="—+‹:magical blaster 40%"
 elseif n==5 then
  h.txt="—+‘:burning phoenix 60%"
 elseif n==6 then
  h.txt="—+ƒ:short brake 30%"
 end
 add(howto,h)
end

function update_howto(h)
 if btn(Ž) then
  h.x-=1
 else
  h.x-=0.5
 end
 if h.f and h.x<0 then
  add_howto((h.n+1)%7)
  h.f=false
 end
 if (h.x<-128) del(howto,h)
end

function draw_howto(h)
 print(h.txt,h.x,12,5)
end
__gfx__
00000001100000000000001100000000000000110000000000000011000000000000000000000000000000000000000000000000000000000000001100000000
00111111111110000011111111110000001111111111000000111111111100000000000000000000000000000000000000000000000000000011111111110000
00111188881110000011118888111000011111888811100001111188881100000000011000000000000000000000000000000110000000002211112222111000
00011889988110000011188998811000881118899881000081111889988100000001111111000000000000000000000000011111110000000022222442211000
0008888fff2000000008888fff2000002888888fff2000002888882fff2000000111111111100000000011000000000001111111111000000002222999200000
08888882911000008888882291100000022288229110000002288222911000001118888881100000001111111000000011122222211000002222222241100000
82222221111110002222222111111000000022211111000000022221111100001888899f21000000111111111100000012222449210000002222222111111000
80000011111111000000001111111000000000111111100000000011111110008888829110000000118888881110000022222241100000000000001111111000
00001111111011440000011111111144000001111111114400000111111111448222211111101044088889f21111104422222111111010440000011111111144
000f11011100f400000f11111100f400000f11111100f400000f11111100f400200f11111111f400888822111111f40020091111111194000009111111009400
00001011114400000000111111440000000011111144000000001111114400000000111111440000882211111144000000001111114400000000111111440000
0000001114000000000000111400000000001011140000000000001114000000000011111400000082f111111100000000001111140000000000001114000000
55000011100000005000011110000000500001111000000050000111100000005500101110000000500011111000000055001011100000005000011110000000
55554111110000005555411110000000555541111000000055551111100000005555411111000000555211211000000055554111110000005555411110000000
05550111110000005555011111000000555011111000000055500111100000000555121121000000555111110000000005551211210000005555011111000000
05500200200000000550020020000000555002002000000055500200200000000550000000000000555000000000000005500000000000000550020020000000
0080000000000000000000000000000000000e8888e0000000000e8888e000000000000e806800000000000e800000000000000e805800000000000e80000000
228800000000000000000000000000000000e778778e00000000e778778e0000000000e800088800000000e800000000000000e800088800000000e800000000
0888800000000000000000000000000000ee88888888ee0000ee88888888ee0000000e800008888000000e800000000000000e800008888000000e8000000000
08888800000000000000000000000000e77877877877877ee77877877877877e0000088ee00888880000088ee00000000000088ee00888880000088ee0000000
0028880000000000000000000000000028888888888888822888888888888882000088888e088888000088888e000000000088888e088888000088888e000000
00888880000800008000000000088800022222222222222002222222222222200088228888e888800088228888e000000088228888e888800088228888e00000
020888880000880028800000000008800000099999900000000009999990000088881788888e888088881788888e000088881788888e888088881788888e0000
0000288880000880028888888888289900900ffffff00f0000000ffffff000008888888888888880888888888888888088888888888888808888888888888880
00020828888828990028828888200000099991f11ffffff0000001f11ff000000999999888888000099999988888888800009998888880000000999888888888
2888828888200000000222888200000000999fffffffff0000009fffffff00000009999888880000000999988888888800099998888800000009999888888888
028209222200000000008888800000000009f22ffffff0000009f22ffffff0000000099e888800000000099e888888880099999e888800000099999e88888888
0020900000000000000028880000000000002ff2ffff000000992ff2ffffff0000009ee88888000000009ee88888888800009ee88888000000009ee888888888
000090000000000000028880000000000000fffffff900000999fffffff9fff00000e888888200000000e888888288800000e888888200000000e88888828880
000000000000000000082880000000000000fffffff900000090fffffff90f000000e888822200000000e888822260000000e888822200000000e88882226000
0000000000000000000288800000000000009ffffff9000000009ffffff900000000088820222020000008882022202000000888202220200000088820222020
00000000000000000000228000000000000009999990000000000999999000000000788000022200000078800002220000007880000222000000788000022200
00000000000000000000000000000000000000000000000000000000000000001511151500002222222000000000000000000000000022220000000000000000
00000000000000000000000000000000000000000000000000000000000000001511151500022aaaaa220000000000000000000000022aa22000000000000000
000990888000000000000088800000000000000000000000000000000000000015111515000222aaa9922000222222202222202222222aa92222220222220000
000009960000000000000006000000000000000000000000099999969999990015111511000022aaa92222222aa2aa222aaa222aaa22229922aaa222aaa22000
000000060000000009999996999999000000000000000000000000000000000051511511000002aaa92222222aa9aa92aa9aa2aa9aa2aaa22aa9aa2aaaaa2200
000000069900000000000006000000000000000000000000000000000000000051511151000002aaa92222222aa9aa92aa9299aa92992aa92aa9299299aa9200
000000060099000000000006000000000000000000000000000000000000000051151151000002aaa92222222aa9aa92aa9222aa92222aa92aa92222aaaa9200
000088888000000000008888800000000000000000000000000000000000000051115511000002aaa922222a2aa9aa92aa9aa2aa9aa22aa92aa9aa2aa9aa9200
00d118888800000000d11888880000000000000000000000000000000000000051551151000002aaa922222a9aaaaa92aaaaa9aaaaa9aaaa2aaaaa9aaaaa9200
0d111888888000080d111888888000080000000000000000000990000000000051515151000022aaa92222aa92aaaaa22aaa992aaa99aaaa92aaa992aaaaa220
d111888888888888d111888888888888000000000000000000000990000000001551515100002aaaaaaaaaaa9229999922999222999229999229992229999922
22285555555500002228555555550000000000000000000000000006000000001511515100002aaaaaaaaaaa9222222222666222222222222222222222222222
22221d1d1d1d000022221d1d1d1d0000000000000000000000000000990000001511515100002299999999999222226622266522222222222222222222222220
00222222110000000022222211000000000000000000000000000000009900001511515100002222222222222222226652266522226662222222222222222000
50000050010500005000005001050000000000000000000000000000000000001511551100000222282288822222666666266662866566228882222288820000
05555555555000000555555555500000000000000000000000000000000000001511151500000088828822288288226655566566266666582228828822280000
000444444444440000000999999444000000000000000000000dddddddddd0001111111100000002222288822822886652266566566555528882282288820000
004444444444444000099999999944400000000000000000000dddddddddd0007cccccdd00000022211222222222226652266566626666222222222221222000
04444444444444400099999999999444000000000000000000dddddddddddd007cccccdd00000221111122222222222511225525552555522222222211d22000
44444444444444400999999999999944000000000000000000dddddddddddd007cccccdd000022111111d222222222211dd22222222222222222222211d22000
4444444444445440099999444099994400000000000000000dddddddddddddd007cccdd00000211ddd11d22212222211dd222222222222222222222111d22000
4454454445445440999994440009994400000000000000000dddddddddddddd007cccdd0000022dd2211d2211d22211dd222222222222222222222211dd22000
445445444544544499994440000000000000000000000000dddddddddddddddd07cccdd0000002222211d2111d2211dd2112222222222222222222211d222000
445445444544544499994440000000000000000000000000dddddddddddddddd07cccdd000000022211dd1111d2111d221112222112222211122221111122000
4454454445445444999944400000000000000000000000000000000000000000007ccd0000000002211d11111d111dd222ddd2221111221111d222111d112200
4454454445445444999944400000000000000000000000000000000000000000007ccd0000000002211111d11111dd222112211111ddd111ddd22211d211d220
4454454445454445999994440009994400000000000000000000000000000000007ccd000000000211111d211111d22211dd22d11d22211dd2222111d111d220
4454454445544450099999444099994400000000000000000000000000000000007ccd00000000221111d221111dd22211d22211dd21211d2221211dd11dd222
05544544555445400999999999999944000000000000000000000000000000000007c00000000022111d2222111d22211d222111d212d2112212d11d211d2122
04555555555554000099999999999444000000000000000000000000000000000007c0000000002211d2222211dd211d111211d1112d2211112d211d221112d2
00455555554444000009999999994440000000000000000000000000000000000007c000000000222d2222222dd222dd2ddd2dd2ddd2222dddd222dd222ddd22
00445555544440000000099999944400000000000000000000000000000000000007c00000000002222000002222022222222222222200222222022222222220
00000000dddddd000000000000000000000000ddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000ddd999dddddd000000000000000000000d5665555ddd00000000000000000000000000000000000000000000000000000000000000eeeeeee00000000000
dddddd99b99ddddddd000000000000000000d55665556555dd0000000000000000000000000000000000000008888888000000000000e8888888888e0000ee00
dddddd9b4b9ddddddddd00000000000000dd55655555565555ddd000000000000000000000000000000000888888888800000000000e888888888888eeee8800
ddddd7944497dddddddddd00000000000d5555655555556555555dddd00000000000000000000000000088888888888800000000eee822222888888888880000
dddddd77777ddddddddddddd00000000d655555655555556555655555d00000000000000000000000888888888888888000000ee888811778888888888000000
dddddddddddddddddddddddd5000000065556555655555556555555665d0000d000000000000000088888888888888880eeeee88888811778888880000000000
dddddddddddddddddddddd5555000000555556555655555555555555565d00d60000000000000088888888888888888808888888888888888888880000000000
dddddddddddddddddd555555550000005555561155556555556655555565dd650000000000088878888888888888888800aaaaaaaaaa99988888880000000000
dddddddddddddd555555555555000000b35551dd115555b5353565555556555500000000008888877888888888888888000000aaaaa999998888888000000000
dddddddddd555555555555555500000031111d11dd15531111115555555555530000000008888888888888888888888800000000000bbb998888888000000000
dddddd555555555555557775550000001ddddddd11d111dddddd111335553531000000007888888888888887888888880000000000bbbb498888888000000000
77555555555555555557999755000000d5555555dddddd555555ddd11155111d00000088877888888888888877777778000000000bbb00498888888000000000
dd5555555555555555799c997500000055556655555555556655555ddd11ddd50000088888878888888888888888888800000000bb0000488888888000000000
dd555555555555555579ccc97500000055555565556555556656655555dd5556000088888888887888888888888888880000000bb00004e88888888800000000
dd555557775555555579ccc97500000055555555555665555555566555555565000088888888888777788888888888880000000000000e888888888800000000
dd5555799975555555799c997500000055555555555556555555555655555655000788888888888888877888888888880000000000000e888888888800000000
dd555799c997555555579997550000005556555555555511115555556555555500087788888888888888888887888888000000000000e8888888888000000000
dd55579ccc975555555577755500000055556555555111dddd1555555655555500888877788888888888888888777777000000000000e8888888888000000000
dd55579ccc975555555555555500000055556555111ddd1111d15555555555550011888887888888888888888888888800000000000e88888888888000000000
dd555799c9975555555555555500000055555551ddd11155551d155555655555001118888888887788888888888888880000000000e888888888880000000003
dd5555799975555555555555650000005555551d11155555551d15555666555500111111188888887777888888888888000000000e8888888888880000003333
dd555557775555555555556565000000331111d11133b535551d1555556555550011111111888888888888888877777700000000e8888888888ee8333333333d
dd55555555555555556565656500000011ddddddd11113b55551d1555555531100111111111118888888888888888888000000088888888888e88883333333dd
dd555555555555656565656565000000dd5555555ddd11133311d155555531dd0001111111111111888888888888888800000088888888888888888833333ddd
dd555555556565656565656565000000555566555555dd1111111d1555531d5500001111111111111111111888888888000008888888888888888888555ddddd
dd55556565656565656565656500000055555565555555dddd1111155351d5550000001111111111111111111111111100000888888888888888885555555ddd
dd555565656565656565656565000000565555566555555555dddd11111d55560000000011111111111111111111111100008888888888888888822255555555
dd5555656565656565656565557700005655555556655555555555d1111d55560000000000011111111111111111111100008888888888888888822222255555
dd555565656565656565655555dd770055655555555555556655555d11dd55650000000000000111111111111111111100009888888888888888882222222255
dd5555656565656565555555dddddd7755565555555565555566555d1dd555550000000000000099991111111111111100099888888888888888882222222222
dd55556565656555555555dddddddd775555556655566655555565561d5555550000000000000099999999991111111100099988888888888888882222222222
dd5555656555555555dddddddd777755555555665555655555665551dd55555500000000000000ff99999999999999990099998888888888888888822222222c
dd555555555555dddddddd77775555553b5555555555555555565551d665555500000000000000ffffff999999999999009999888888888888888882222222cc
5d55555555dddddddd7777555555555533b555535555555555555551d555555300000000000000fffffffff99999999900999998888888888888888222222ccc
555555dddddddd777755555555555555111111111113b555555555513553531100000000000000ffffffff57ffffffff009999998888888888888888222ccccc
dddddddddd7777555555555555555555ddddddddddd1153555355533133111ddcccccccc000000fffffff5777fffffff009999999888888888888888cccccccc
dddddd7777555555555555555555555555555555555dd11333111111111ddd550ccccccccc0000fffff557777fffffff099999999888888888888888800ccccc
dd7777555555555555555555554445555555555555555dd111ddddddddd55555cccccccccccc00ffff5117777fffffff0999999999888888888888888000cccc
77555555555555555555555554777455556555555566555ddd1d555555555555ccccccccccccccffff711777ffffffff09999999998888888888888880000ccc
55555555555555555555555547c7b745555655555555665555d1d555555566650ccccccccccccfffff711777ffffffff049999999988888888888888800000cc
55555555555555555555555547cb77455555665555555555555d1d5555555556000000ccccccfffffff7777fffffffff0499999999988888888888888000000c
55555555555555555555555547cb77455555556555555556655d1d55565555550000000cccccffffffffffffffffffff044999999999eeee8888888880000000
555555555555555555555555478777455555555655555555665d1d556555555500000000cccc222fffffffffffffffff0444999999ee8888e888888880000000
5555555555555555555555554777774555555555655555555651115655555555000000000c9f2ff22fffffffffffffff044444999e8888888888888880000000
55555444455555555555555547777445555555555665555555111115555555550000000bbb9f2fff2222ffffffffffff00444444e88888888888888880000000
5555477774555555555555555477745555555555555665511115551115555555000bbbbbbbff2fff2fff22ffffffffff00444444e88888888888888880000000
555447c7b745555555555555554445555555555535555111333b55551155555500bbbbbbbfff2fff2fff2f2fffffffff0004444e888888888888888880000000
555477cb7745555555555555555555553535553111111111111333b3511155550bbbbbbbbfff2fff2fff2ff2ffffffff0000444e888888888888888882000000
555477cb7745555555555555555555551111111ddddddddddd111113331113110bbbbbbbffffffff2fff2fff2fffffff0000444e888888888888888882200000
55547787774555555555555555555555ddddddd55555555555dddd11311111ddbbbbbbbbffffffffffff2ffff2ffffff0000044e88888888888888882222d000
555477777745555555555555555555555555555555555555555555d111dddd55bbbbbbb0ffffffffffff2ffff2ffffff0000000e888888888888888822222dd0
5554477774455555555555555555555566555555555555555555555ddd5555550bbb0000fffffffffffffffff2ffffff0000000e8888888888888882222222dd
55554777745555555555666655555555655555666555555555555555555555550000000ffffffffffffffffff2ffffff0000000e88888888888888822222222d
555554444555555566666d6d65555555555555555665555555555555555665550000000fffffffffffffffffffffffff00000000288888888888882222222222
55555555555566666d6d6d6d65555555555555555556555566555555556555550000000fffffffffffffffffffffffff00000000028888888888822222222222
5555555555556d6d6d6d6d6d65555555355555555556555555655555565555530000000fffffffffffffffffffffffff00000000028888888888002222222222
5555555555556d6d6d6d6d6d6555555513b555555555555555566555555553110000000fffffffffffffffffffffffff00000000002888888800000222222222
5555555555556d6d6d6d6d6d65555555d11135555555555555555655555311dd00000009ffffffffffffffffffffffff000000000002888888800000c2222222
5555555555556d6d6d6d6d6d655555555ddd111335555555555555555511dd5500000009ffffffffffffffffffffffff0000000000002288888800000cc22222
5555555555556d6d6d6d6d6d655555555555ddd1111555555555555531dd5555000000099fffffffffffffffffffffff000000000000002288888000000cc222
5555555555556d6d6d6d6d6d655555555655555dddd11355556655551d5555650000000099ffffffffffffffffffffff00000000000000002288800000000cc2
5555555555556d6d6d6d6d6d6555555555655555555dd15555555531d5556655000000009999ffffffffffffffffffff0000000000000000002880000000000c
5555555555556d6d6d6d6d6d655555555566555555555d155555551d5556666500000000099999ffffffffffffffffff00000000000000000007700000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002e4502e450234402e4402e440294402e4302e430244202242022400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000025250272502525024250202501f2401b2301722017220112100b210212002520027200292002b2002d2002f2003220033200352000000000000000000000000000000000000000000000000000000000
0002000022150251402a1302f62030630316203362000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000131501715015100161501a1401f1003663036630376303762036610366100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002345023450213002245021450233001f4501f4501a3001830016300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000022250000000000026250000002b25000000000002f2500000032250332503525000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200002445026450284502a4502c4502e4503045000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300002445022450204501e4501c4501a4501845000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000022450244502665027450345502e6503b53037520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000c4560e456104560c45611456104560e456114561345611456104561345611456154561745613456184561a4561c456184561d4561c4561a4561d4561f4561d4561c4561f4561d45621456234561f456
00020000253502e340363303632000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001a6501a640196301862000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001315016140171301f62020630256202662000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e000026432264302c4322c43029432294302c4322c432294322943029432264322643024431264302643229432294320000029432294322843126432264322943229432000002943229432284312543225432
010e00000c3330000024633246330c3330000024633246330c3330000024633246330c3330000024633246330c3330000024633246330c3330000024633246330c3330000024633246330c333000002463324633
010e00000e330113300e330143300e330113300e330143300e330113300e330143300e330113300e3301433010330133301033016330103301333010330163301033013330103301633010330133301033016330
010e000026432264302c4322c43030432304302c4322c43229432294302943026432264302443126430264322b4322b432000002b4322b4322943128432284322b4322b432000002c4322c4322b4312c4322c452
010e00000e330113300e330143300e330113300e330143300e330113300e330143300e330113300e330143300d330103300d330143300d330103300d330143300b3300e3300b330113300d330103300d33013330
010e00002a5522a55500500005002a5522a55500500005002a5522a5550050028552285502855025552255502855228550285502a5522a5502a5502c5522c5502c5502c5502a5522a5522a5522a5522855228555
010e0000123551235100005000051235512351000050000510355103510000500005103551035100005000050d3550d35100005000050d3550d35100005000051435514351000050000514355143510000500005
010e000012355123510000500005123551235100005000050d3550d35100005000050d3550d35100005000050e3550e35100005000050e3550e35100005000051035510351000050000510355103510000500005
010e00002a5522a55500500005002a5522a55500500005002a5522a555005002855228550285502555225550235522355523552235552555028550285522855025552255552555225555285502c5502c5522c550
010e00001b44227441274422544124442000021f4421f442204421a4411d4421f4411f4421f4421f4421f445204421a4411d4421f4411f4421f4421f4421f445204421a4411d4421f4411f4421f4421f4421f445
010e00000f3550f3550f355000000f3550f3550f35500000143551435514355000001435514355143550000011355113551135500000113551135511355000000d3550d3550d355000000d3550d3550d35500000
011400002154221545215422154221542215451d5421d5451f5421f545215451d5451d5421d5451f5421f5452154221545215422154221542215451d5421d5451f5421f545215451d5451d5421d5451f5421f545
011400002154221545215422154221542215451d5421d5451f5421f545215451d5451d5421d5451c5421c5451a5421a5421a5421a5421a5421a5421a5421a5421a5421a5421a5421a5451a5421a5451c5451d545
011400000c333000001f63300000000000c3331f633000000c333000001f63300000000000c3331f633000000c333000001f63300000000000c3331f633000000c333000001f63300000000000c3331f63300000
011400001a1251d125211251f1251a1251d125211251f1251a1251d125211251f1251a1251d125211251f125181251d1251f1251a125181251d1251f1251a125181251d1251f1251a125181251d1251f1251a125
01140000171251c1251d1251a125171251c1251d1251a125171251c1251d1251a125171251c1251d1251a125151251a1251c12518125151251a1251c1251812513125181251a1251712513125181251a12517125
010e00002d0422d0422d0422d0452d0452d0422d0452d0452d0422d0422d0422d0452a0422a0452a0452a0452b0422b0452b0452b0452b0452b0422b0452b0452804228045280452804528045280422804528045
010e00002a0422a0452a0452a0452a0452a0422a0452a0452a0422a0452a0452a0452a0452a0422a0452a0452c0422c0452c0452c0452c0452c0422c0452c0452c0422c0452c0452c0452c0452c0422f0452f045
010e00001513519135151351e1351513519135151351e1351513519135151351e1351513519135151351e1351313517135131351c1351313517135131351c1351313517135131351c1351313517135131351c135
010e00001213515135121351a1351213515135121351a1351213515135121351a1351213515135121351a1351413517135141351c1351413517135141351c1351413517135141351c1351413517135141351c135
010e00000c3330000024600246000c3330000024600246000c3330000024600246000c3330000024600246000c3330000024600246000c3330000024600246000c3330000024600246000c333000002460024600
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
01 11 12 10 44
00 11 14 13 44
00 11 12 10 44
00 11 14 13 44
00 11 22 20 44
00 11 23 21 44
00 24 22 20 44
02 24 23 21 44
01 11 16 15 44
00 11 17 18 44
00 11 16 15 44
02 11 17 18 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 11 1a 19 44
02 11 1a 19 44
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
01 1b 1e 1d 44
02 1c 1f 1d 44
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
