pico-8 cartridge // http://www.pico-8.com
version 14
__lua__
-- tie hunt v1.0
-- by minsoft (2017)

function _init()
 hi=0
 credits=0
 d_cred=0
 d_gpio=0
 d_sfx=1
 d_y=0
 if cartdata("tie_hunt") then
  hi=dget(0)
  d_cred=dget(1)
  d_gpio=dget(2)
  d_sfx=dget(3) 
  d_y=dget(4)
 end
 if (d_cred==0) credits=9999

 gpio={}
 gpio_off(false)

 populate_menu()
 
 debug=false
  
 mode=0
 lives=0
 hits=0
 hits_d=0
 score=0
 
 tit_y=64
 tit_sz=0.001
 tit_f=20
 init_game()
end

function init_game()
 if mode==0 then
  tit_y=64
  tit_sz=0.001
  tit_f=20
  hits=flr(rnd(16))
 else
  lives=3
  hits=0
  score=0
  next_life=1000
 end
 
 dead=false
 new_hi=false
 
 init_tunnel() 
 init_life()
end

function init_tunnel()
 --tunnel 
 tun_ps=1+flr(rnd(4)) --scheme 1-4
 tun_pr=1 --repeat
 tun_sh=0 --shape
 
 tun_p={}
 tun_p[1]={0x10,0x01,0x51,0x05,0x51,0x01,0x10} 
 tun_p[2]={0x40,0x04,0x94,0x09,0x94,0x04,0x40}
 tun_p[3]={0x30,0x03,0xb3,0x0b,0xb3,0x03,0x30}
 tun_p[4]={0x20,0x02,0xe2,0x0e,0xe2,0x02,0x20} 
 
 px,py=64,64
 
 tun_m={}
 for i=1,100 do
  tun_m[i]={}
  tun_m[i].x=(0.5+rnd(0.5))*(0-flr(rnd(2)))
  tun_m[i].y=(0.5+rnd(0.5))*(0-flr(rnd(2)))
 end
 tun_m[1].x=0
 tun_m[1].y=0
end

function init_life()
 dead=false
 
 --tunnel
 rec={}
 
 tun_pc=1
 
 --timers
 tmr_rec=0
 tmr_tun=1
 tmr_sin=0
 
 tmr_tie=1
 tmr_sin2=0
 tmr_spwn=120+flr(rnd(200))
 if (mode==0) tmr_spwn=500
 tmr_bmb=-1
 
 tmr_exp=0
 tmr_spk=0
 tmr_smk=0
 
 tmr_spd=0
 tmr_shd=0
 tmr_scr=0
 tmr_hit=0
 tmr_die=0
 
 tmr_16=1
 tmr_236=1
 tmr_ovr=0
 tmr_stt=25
 tmr_col=120
 tmr_coin=0
 tmr_gpio=0
 tmr_32=1
 tmr_1up=0
  
 --inputs
 inp={}
 inp[1]=0
 inp[2]=0
 inp[3]=0
 inp[4]=0
 ax,ay=0,0
 cx,cy=0,0
 
 vx,vy=0,0
 
 --laser
 laser=0
 sht=0
 shtp=0 
  
 --shield
 shield=100
 shd=false
 
 --hull
 hull=0
 spk={}
 
 --warnings
 w={}
 w[1]=0 --laser
 w[2]=0 --hull
 w[3]=0 --proximity
 w[4]=0 --shield
 w_sfx=0
 
 --bonuses
 bon_shd=false
 bon_lif=false
 
 --tie
 tie={}
 tie.m=0
 tie.pt=0
 
 last=0
  
 exp={}
 smk={}
 
 tie_m={}
 
 bomb={}
 bomb.sz=0
 
 --start
 spd=0.5
 tone=0
 engine_sound()
end

function _update60()
 if not dead then
  update_tunnel()
  update_shot()
  update_tie()
  update_bomb()
  check_inputs()
  collisions()
 end
 check_title_inputs()
 warnings()
 update_particles(exp,tmr_exp)
 update_particles(spk,tmr_spk)
 update_smoke()
 update_gpio()
 update_title()
 timers()
end

function timers()
 --speed
 if (not dead) tmr_spd+=1
 if tmr_spd==200 then
  spd+=0.05
  tmr_spd=0
  engine_sound()
 end
 
 --tunnel
 tmr_sin+=spd/200
 if tmr_sin>=1 then
  tmr_sin=0
  tmr_tun+=1
  if (tmr_tun>100) tmr_tun=1
 end
 
 --tie
 if tie.m>0 and tie.sz>0.1 then
  tmr_sin2+=0.002+rnd(0.008)
  if tmr_sin2>=1 then
   tmr_sin2=0
   tmr_tie+=1
  end
 else
  tmr_sin2=0
  tmr_tie+=1
 end
 if (tmr_tie>100) tmr_tie=2
  
 tmr_16+=1
 if (tmr_16==17) tmr_16=1
 
 tmr_236+=1
 if (tmr_236==237) tmr_236=1
 
 if (tmr_hit>0) tmr_hit-=1
  
 if tmr_exp>0 then
  tmr_exp-=1
  if (tmr_exp==0) exp={}
 end
  
 if tmr_smk>0 then 
  tmr_spk-=1
  if (tmr_spk==0) spk={}
 end
 
 if (tmr_shd>0) tmr_shd-=1
  
 if tmr_scr>0 then
  tmr_scr-=1
  if (tmr_scr==0) last=0
 end
 
 tmr_die-=1
 if (tmr_die==0 and lives>0) init_life()
 if tmr_die>0 and tmr_die%25==0 and lives==0 then
  tie.x,tie.y=rnd(128),rnd(128)
  init_explosion(tie,true)
  init_smoke()
  play_sfx(6,1)
 end
  
 if tmr_ovr>0 then
  tmr_ovr-=1
  if tmr_ovr==0 then
   mode=0
   gpio_off(false)
   init_game()
  end
 end
 
 if (tmr_stt>0) tmr_stt-=1
 
 if (tmr_col>0) tmr_col-=1
 
 if (tmr_coin>0) tmr_coin-=1
 
 if tmr_gpio>0 then
  tmr_gpio-=1
  if tmr_gpio==0 then
   gpio[3]=0
   vx,vy=0,0
  end
  if tmr_gpio>35 and not dead then
   vx=-2+rnd(4)
   vy=-2+rnd(4)
  end
 end
 
 tmr_32+=0.5
 if (tmr_32>32) tmr_32=1
 
 if tmr_1up>0 then
  tmr_1up-=1
  if tmr_1up==0 then
   if (bon_lif) bon_lif=false
   if (bon_shd) bon_shd=false
  end
 end
  
end

function update_tunnel()
 tmr_rec+=1

 --add rectangle
 if tmr_rec>=5/spd then
  local r={}
  r.x,r.y,r.sz,r.c=px,py,1,tun_p[tun_ps][tun_pc]
  r.sh=tun_sh
  add(rec,r)
  --colour
  tun_pc+=1
  if tun_pc==8 then
   tun_pc=2
   --repeats
   tun_pr+=1
   if tun_pr==8 then
    tun_pc=1
    tun_pr=1
    --scheme
    tun_ps=1+flr(rnd(4))
   end
  end
  tmr_rec=0
 end
 
 --increase size of rectangles
 tie.h=false
 local i=1
 for r in all(rec) do
  r.sz=r.sz*(1+spd/10)
  r.x1=r.x-(r.sz/2)
  r.x2=r.x+(r.sz/2)
  r.y1=r.y-(r.sz/2)
  r.y2=r.y+(r.sz/2)
  r.h=false
  
  local l=i-1
  if (l<1) l=#rec
  if l~=i and rec[l].sz>r.sz then
   --crop rect if behind previous 
   if (r.x1<rec[l].x1) r.x1=rec[l].x1
   if (r.x2>rec[l].x2) r.x2=rec[l].x2
   if (r.y1<rec[l].y1) r.y1=rec[l].y1
   if (r.y2>rec[l].y2) r.y2=rec[l].y2
   
 		--hide rect completely obscured
   if (r.x2<rec[l].x1 or r.x1>rec[l].x2) r.h=true
   if (r.y2<rec[l].y1 or r.y1>rec[l].y2) r.h=true
   
   --hide tie
   if tie.m>0 and tie.sz<0.25 and r.h then
    if tie.x<=r.x2 or tie.x>=r.x1 or tie.y<=r.y2 or tie.y>=r.y1 then
     local f=r.sz/tie.sz
     if (f>5) tie.h=true
    end
   end
  end
  
  if r.sz>448 then
   del(rec,r)
  else
   i+=1
  end
 end
 
 --bends  
 local s=sin(tmr_sin)

 px=64+(14*s*tun_m[tmr_tun].x)
 cx+=1.75*spd*s*tun_m[tmr_tun].x
 
 py=64+(14*s*tun_m[tmr_tun].y)
 cy+=1.75*spd*s*tun_m[tmr_tun].y 
end

function update_shot()
 if (sht==0) return
 
 sht-=5
 if sht<64 then
  sht=0
  shtp+=1
  if (shtp==4) shtp=0
 end
end

function init_tie()
 --model
 tie.m=1
 if (hits/100>rnd(0.75)) tie.m=2
 if ((hits+1)%10==0) tie.m=3
 if ((hits+1)%25==0) tie.m=4
 local h=hits
 h=h-(100*flr(h/100))
 if (h>=50 and h<60) tie.m=3
 if (hits>=100 and h>=0 and h<10) tie.m=4

 --energy
 tie.e=1
 if (tie.m==2) tie.e=2
 if (tie.m==3) tie.e=5
 if (tie.m==4) tie.e=10
 
 --position/size
 tie.x,tie.y=px,py
 tie.sz,tie.h=0.06,false
 
 --pts
 tie.pt=(tie.e+flr(hits/20))*10
 
 --about to fire
 tie.bi=false
 tmr_bmb=get_bomb_delay()
 
 --occasional tie from rear
 local b=false
 if tie.m<3 and rnd(10)<3 then
  b,tie.sz=true,3
  tie.x,tie.y=112,112
  if (cx>0) tie.x=16
  if (cy>0) tie.y=16
  tmr_bmb=100+flr(rnd(50))
 end  
 
 --movements
 for i=1,100 do
  tie_m[i]={}
  tie_m[i].x=-1.5+rnd(3)
  tie_m[i].y=-1.5+rnd(3)
  tie_m[i].z=-1.5+rnd(3)
 end
 --(initial behaviour)
 tie_m[1].z=abs(tie_m[1].z)
 if b then
  tie_m[1].x=0
  tie_m[1].y=0
  tie_m[1].z=-3-rnd(0.5)
  --zoomer
  if (rnd(2)<1) tie_m[1].z=-9
 end
 tmr_tie=1
 tmr_sin2=0
end

function update_tie()
 --spawn tie
 if tie.m==0 then
  tmr_spwn-=1
  if (tmr_spwn>0) return
  init_tie()
 end
 
 local b=false
 if (tmr_tie==1 and tie_m[tmr_tie].z<0) b=true 
 
 --move x/y 
 if not b then
  local o=tie.sz*16*sin(tmr_sin2)
  local ox,oy=px,py
  ox+=(64-px)*tie.sz*0.5
  oy+=(64-py)*tie.sz*0.5
  tie.x=ox+(o*tie_m[tmr_tie].x)
  tie.y=oy+(o*tie_m[tmr_tie].y)
  
  --move closer/further
  if (tie_m[tmr_tie].z>0 or rnd(3)<1) tie.sz+=0.005*tie_m[tmr_tie].z
 end
 
 --starting from behind
 if b then
  local i=0.48
  if tie_m[tmr_tie].z~=-9 then
	  --normal
	  tie.sz+=0.005*tie_m[tmr_tie].z
  else
   --zoomer
   tie.sz=tie.sz*0.97
   if (tie.sz<0.2) tie.sz=0.2
   i=0.92
  end
  
  if tie.x<px then
   tie.x+=i
   if (tie.x>px) tie.x=px
  end
  if tie.x>px then
   tie.x-=i
   if (tie.x<px) tie.x=px
  end
  if tie.y<py then
   tie.y+=i
   if (tie.y>py) tie.y=py
  end
  if tie.y>py then
   tie.y-=i
   if (tie.y<py) tie.y=py
  end
  
 end
 if (tie.sz<0.06) tie.sz=0.06
 
 --launch bomb 
 tmr_bmb-=1
 tie.bi=false
 if (tmr_bmb>0 and tmr_bmb<50 and tie.sz>0.1 and tie.sz<1.5) tie.bi=true 
 if tmr_bmb==0 then
  if tie.sz>0.1 and tie.sz<1.5 then
   init_bomb()   
  else
   tmr_bmb=get_bomb_delay()
  end
 end
 
 --reduce points
 if (tie.m<3 and tmr_16==16 and tie.sz>0.25) tie.pt-=1
 if (tie.pt<tie.e) tie.pt=tie.e

end

function init_bomb()
 if (tie.m==0) return
 
 bomb.x=tie.x-1
 bomb.y=tie.y+tie.sz*5
 bomb.sz=tie.sz/2
 
 play_sfx(5,1)
end

function get_bomb_delay()
 return 50+flr((1000/hits/tie.m)*(1+rnd(5)))
end

function update_bomb()
 if (bomb.sz==0) return
 
 bomb.sz=bomb.sz*1.03
 if (bomb.x-64<cx) bomb.x+=0.25
 if (bomb.x-64>cx) bomb.x-=0.25
 if (bomb.y-64<cy) bomb.y+=0.25
 if (bomb.y-64>cx) bomb.y-=0.25
end

function death()
 dead=true
 tmr_die=230
 tmr_gpio=100
 
 for i=1,4 do
  w[i]=0
 end
 
 play_sfx(-1,0)
 play_sfx(-1,3)
 play_sfx(6,1)
 
 if mode==0 then
  play_sfx(8,2)
  tmr_ovr=500
  tmr_236=0
  return
 end
 
 local m=8
 lives-=1
 if lives==0 then
  tmr_ovr=500
  tmr_236=0
  tmr_gpio=275
  if score==hi then
   dset(0,hi)
   m=9
  end
 end
 play_sfx(m,2)
 
end

function hit()
 tie.e-=1
 if (tie.e==0) kill(true,false) return
 
 play_sfx(3,1)
 init_explosion(tie,false)
 init_smoke()

 --knock back a bit
 if (tie.sz>1) tie.sz=tie.sz*0.9
 
 --retreat tie if hit close 
 if tie.sz>1.5 then 
  local i=tmr_tie+1
  if (i>100) i=1
  tie_m[tmr_tie].z=0-abs(tie_m[tmr_tie].z)
  tie_m[i].z=0-abs(tie_m[i].z)
 end
end

function add_score(s)
 if (mode==0) return
 
 last=s
 score+=last
 tmr_scr=100
 
 if score>=next_life then
  lives+=1
  next_life+=3000
  play_sfx(7,3)
  tmr_1up=140
  bon_lif=true
 end
 
 if score>hi then 
  hi=score
  new_hi=true
 end
end

function kill(pts,died)
 play_sfx(6,1)
 if (pts) add_score(flr(tie.pt))
 if not died then
  hits+=1 
  if (hits%10==0) tun_sh=abs(tun_sh-1)
  if hits%25==0 then
   play_sfx(7,3)
   shield=100
   bon_shd=true
   tmr_1up=140
  end
 end
 if (mode==1) hits_d=hits
 tie.m=0
 tmr_spwn=120+flr(rnd(300))
 
 init_explosion(tie,true)
 init_smoke()
end

function kill_bomb(pts)
 play_sfx(4,1)
 bomb.sz=0
 tmr_bmb=get_bomb_delay()
 if pts then
  add_score(5)
  shield+=2.5
  if (shield>100) shield=100
 end
 init_explosion(bomb,true)
end

function init_explosion(typ,kill)
 tmr_exp=50
 local j=10
 local sz=1.5
 if kill then 
  j=100*typ.sz
  if (j<10) j=10
  sz=3
 end
 for i=1,j do
  local p={}
  p.x,p.y,p.sz,p.c=typ.x,typ.y,rnd(sz),10
  add(exp,p)
 end
end

function init_sparks(axis)
 tmr_spk=50
 for i=1,10 do
  local p={}
  p.sz=rnd(2)
  p.x=64+cx+(0-(cx/abs(cx)))*rnd(32)
  p.y=64+cy+(0-(cy/abs(cy)))*rnd(32)  
  if (axis==1) p.y=32+rnd(64)
  if (axis==2) p.x=32+rnd(64)
  
  add(spk,p)
 end
end

function init_smoke()
 tmr_smk=50
 
 for i=1,10 do
  local p={}
  p.sz=rnd(tie.sz*2)
  if (p.sz>3) p.sz=3
  p.x,p.y=tie.x,tie.y
  
  add(smk,p)
 end
end

function update_smoke()
 if (tmr_smk==0) return
 
 for p in all(smk) do
  p.x=p.x-2+rnd(4)
  p.y=p.y-rnd(2)
  p.sz-=0.01
  p.c=5+flr(rnd(2))
  if p.x<0 or p.x>127 or p.y<0 or p.y>127 or p.sz<1 then
   if tie.m==0 or dead then
    del(smk,p)
   else 
    p.x=tie.x
    p.y=tie.y
    p.sz=rnd(tie.sz*2)
    if (p.sz>3) p.sz=3
   end
  end
 end
 
 tmr_smk-=1
 if (tmr_smk<=0 and #smk>0) tmr_smk=50    
end

function update_particles(typ,tmr)
 if (tmr==0) return
 
 local ep={7,10,9,8}
 
 for p in all(typ) do
  p.x=p.x-4+rnd(8)
  p.y=p.y-4+rnd(8)
  p.sz-=0.01
  p.c=ep[1+flr(rnd(4))]
  if (p.x<0 or p.x>127 or p.y<0 or p.y>127 or p.sz>3 or rnd(1)<0.05) del(typ,p)
 end
end

function check_title_inputs()
 --credit
 if (check_coin()) sfx(2,2)
 
 if (mode==1 or credits==0) return
  
 --start
 if btnp(5) then
  credits-=1
  mode=1
  init_game()
  play_sfx(7,3)
 end
end

function check_inputs()
 local b={}
 
 --get dpad state
 if mode==0 then
  b=demo_inputs()
 else
  for i=1,6 do
   b[i]=btn(i-1)
  end
  --invert y-axis
  if d_y==1 then
   local t=b[4]
   b[4]=b[3]
   b[3]=t
  end
 end
 
 --increase travel when held
 if (inp[1]==1 and b[1]) ax-=0.1
 if (inp[2]==1 and b[2]) ax+=0.1
 if (inp[3]==1 and b[3]) ay+=0.1
 if (inp[4]==1 and b[4]) ay-=0.1
 
 --limit travel
 if (ax<-5) ax=-5
 if (ax>5) ax=5
 if (ay<-5) ay=-5
 if (ay>5) ay=5
 
 --return to centre when released
 if (not b[1] and ax<=-0.05) ax+=0.05
 if (not b[1] and ax<=-0.05) ax+=0.05
 if (not b[2] and ax>=0.05) ax-=0.05
 if (not b[3] and ay>=0.05) ay-=0.05
 if (not b[4] and ay<=-0.05) ay+=0.05
  
 --record direction(s) pressed
 for i=1,4 do
  inp[i]=0
  if (b[i]) inp[i]=1
 end
  
 --move
 cx+=ax
 cy+=ay
   
 --prevent moving past walls
 if (cx<-60) cx=-60
 if (cx>60) cx=60
 if (cy<-60) cy=-60
 if (cy>60) cy=60
 
 --shoot
 if b[6] and tmr_stt==0 and sht==0 and w[1]<3 and not shd then
  play_sfx(2,2)
  sht=127
  laser+=8
  if (laser>100) laser=100
  if (laser>50) w[1]=1
  if (laser>75) w[1]=2
  if (laser>95) w[1]=3
 end
 
 --shield
 if b[5] then
  shield-=0.1
  if shield<=0 then 
   shd=false
   shield=0
   w[4]=1
   play_sfx(-2,2)
  end
  if not shd and shield>0 then
   shd=true
   play_sfx(1,2)
  end
 else
  shd=false
  play_sfx(-2,2)
  w[4]=0
 end
end

function demo_inputs()
 local s=sin(tmr_sin)
 local t=tmr_tun

 --reaction delay
 local d=3
 if (spd>1.2) d=0
 if (t>d) t-=d

 --tunnel path
 local tx=s*tun_m[t].x
 local ty=s*tun_m[t].y
 --deadzone
 local dx=(1/spd)*10
 local dy=(1/spd)*10

 local b={false,false,false,false,false,false}
 --u/d/l/r
 if (tx<cx-dx and rnd(2<1)) b[1]=true
 if (tx>cx+dx and rnd(2<1)) b[2]=true
 if (ty>cy+dy and rnd(2<1)) b[3]=true
 if (ty<cy-dy and rnd(2<1)) b[4]=true
 
 if (tie.m==0 and bomb.sz==0) return b
 
 --shield
 --if (bomb.sz>2) b[5]=true
 
 --fire
 if tie.sz>=0.5 then
  local ex=abs(tie.x-cx-64)
  local ey=abs(tie.y-cy-64)
  if (ex<(22*tie.sz) and ey<(16*tie.sz) and (tie.sz>1.5 or rnd(60)<5)) b[6]=true
 end
 
 if bomb.sz>0.5 then
  local ex=abs(bomb.x-cx-64)
  local ey=abs(bomb.y-cy-64)
  if (ex<(24*bomb.sz) and ey<(24*bomb.sz)) b[6]=true
 end
 
 return b
   
end

function collisions()
 --hit wall
 if tmr_col==0 and tmr_hit==0 and (abs(cx)>=60 or abs(cy)>=60) then
  spd-=0.1
  if (spd<0.5) spd=0.5
  engine_sound()
  play_sfx(0,1)
  
  if (abs(cx)>=60) init_sparks(1)
  if (abs(cy)>=60) init_sparks(2)
  
  tmr_hit=35
  gpio[3]=255
  tmr_gpio+=50
  
  hull+=15
  if (hull>=65) w[2]=1
  if (hull>=100) hull=100 death()
 end
  
 --hit tie
 w[3]=0
 if tie.m>0 then
  if tie.sz>=2.5 and tie_m[tmr_tie].z>0 then
   if shd then
    hit()
    shield-=30
    if (shield<0) shield=0 shd=false
    tmr_shd=50
    tmr_gpio+=100
   else 
    kill(false,true)
    death()
   end
   
   gpio[3]=255
  end
  
  if (tie.sz>1.95) w[3]=1
 end
 
 --hit bomb
 if bomb.sz>3 then
  if shd then
   shield-=20
   if (shield<0) shield=0 shd=false
   kill_bomb(false)
   tmr_shd=50
   tmr_gpio+=75
  else
   kill_bomb(false)
   death()
  end
  
  gpio[3]=255
 end
 
 --shot bomb
 if bomb.sz>0 and sht>0 and sht<80 then
  local ex=abs(bomb.x-cx-64)
  local ey=abs(bomb.y-cy-64)
  if ex<(12*bomb.sz) and ey<(12*bomb.sz) then
   sht=63
   kill_bomb(true)
   return
  end
 end
 
 --shot tie
 if tie.m>0 and tie.sz>0.1 and not tie.h and sht>0 and sht<70 then
  local ex=abs(tie.x-cx-64)
  local ey=abs(tie.y-cy-64)
  if ex<(11*tie.sz) and ey<(8*tie.sz) then
   sht=63
   hit()
  end
 end
end

function warnings() 
 if (dead) return
 
 --cool lasers/hull
 laser-=0.2
 if (laser<0) laser=0
 if (w[1]==1 and laser<50) w[1]=0
 if (w[1]==2 and laser<75) w[1]=1
 if (w[1]==3 and laser<50) w[1]=0
 
 hull-=0.1
 if (hull<0) hull=0
 if (w[2]==1 and hull<65) w[2]=0
 
 --sfx
 if (tmr_1up>0) return
 
 local new_sfx=-2

 local fx={}
 fx[1]={10,11,12}
 fx[2]={13}
 fx[3]={14}
 fx[4]={14}

 for i=1,4 do
  if (w[i]>0) new_sfx=fx[i][w[i]]
 end

 if (new_sfx==w_sfx) return

 w_sfx=new_sfx
 play_sfx(new_sfx,3)
end

function engine_sound()
 local t=25+flr(spd*10)
 if (t>50) t=50
 if t>tone then
  play_sfx(t,0) 
  tone=t
 end
 if t<tone then
  play_sfx(t,0,2)
  tone=t
 end
end

function update_title()
 --flicker logo in
 if dead then 
  if tit_f>1 then
   if (tmr_236==51) tit_f=16
   if (tmr_236==101) tit_f=8
   if (tmr_236==151) tit_f=4
   if (tmr_236==181) tit_f=2
   if (tmr_236==211) tit_f=1
  end
  return 
 end
 
 --zoom logo in
 if tmr_236>150 or tit_sz>0.001 then
  tit_sz=tit_sz*(1+spd/10)
  if (tit_sz>1) tit_sz=1
 end
  
 --move logo up
 if tmr_236>200 then
  if tit_sz==1 then
   tit_y-=1
   if (tit_y<30) tit_y=30
  end
 end
 
end

function _draw()
 draw_death() 
 draw_tunnel()
 draw_particles(smk,false)
 draw_tie()
 draw_particles(exp,false)
 draw_particles(spk,true)
 draw_bomb()
 draw_stuff()
 draw_hud()
 draw_title()
 if (debug) print(debug,0,10,7)
end

function draw_death()
 if (not dead) return
 
 camera()
 
 if tmr_die>75 then
  rectfill(0,0,127,127,rnd(16))
  return
 end

 rectfill(0,0,127,127,0)
 if mode==1 and lives==0 then
  printc("game over",64,54,0,7,"r",0)
  if (new_hi) printc("1up high score!",64,74,0,7,"y",0)
 end
 
end

function draw_tunnel()
 if (dead) return
 
 cls()
 camera(cx+vx,cy+vy)
  
 --draw tunnel
 local i=1
 for r in all(rec) do
  if not r.h then
   fillp()
   if (r.c>0xf) fillp(0b1010010110100101)
   if r.sh==0 then
    rectfill(r.x1,r.y1,r.x2,r.y2,r.c)
   else
    circfill(r.x,r.y,r.sz,r.c)
   end
  end
  i+=1
 end
 
 fillp()
end

function draw_tie()
 if (dead or tie.m==0 or tie.h) return
  
 camera(cx+vx,cy+vy)

 local sy,rx,ry=1+((tie.m-1)*32),tie.x-cx,tie.y-cy

 if (rx<=32 and ry<=32) sx,fx,fy=9,false,false
 if (rx>32 and rx<96 and ry<=32) sx,fx,fy=33,false,false
 if (rx>=96 and ry<=32) sx,fx,fy=9,true,false
 if (rx<32 and ry>32 and ry<96) sx,fx,fy=57,false,false
 if (rx>32 and rx<96 and ry>32 and ry<96) sx,fx,fy=81,false,false
 if (rx>=96 and ry>32 and ry<96) sx,fx,fy=57,true,false
 if (rx<32 and ry>=96) sx,fx,fy=9,false,true
 if (rx>32 and rx<96 and ry>=96) sx,fx,fy=33,false,true
 if (rx>=96 and ry>=96) sx,fx,fy=9,true,true
 
 --phantom
 local d=true
 if tie.m==4 then
  sx,sy,fx,fy=105,65,false,false
  pal(6,tun_p[tun_ps][tun_pc])
  pal(1,tun_p[tun_ps][tun_pc])
  if (tmr_16<(10-tie.e) and rnd(2)<1) pal()
  if (tmr_16%2!=0) d=false
 end
 
 --draw tie
 if (d) sspr(sx,sy,22,17,tie.x-(11*tie.sz),tie.y-(8*tie.sz),22*tie.sz,17*tie.sz,fx,fy)
 pal()
  
 --about to fire
 if (tie.bi) circfill(tie.x-1,tie.y+tie.sz*5,rnd(tie.sz*2),8)
end

function draw_bomb()
 if (bomb.sz==0 or dead) return
 
 camera(cx+vx,cy+vy)
 
 circfill(bomb.x,bomb.y,bomb.sz*8,12)
 
 local bp={7,12,13}
 local x1,y1=bomb.x,bomb.y
 local a,r=0,2
 for i=1,40 do
  a=rnd(1)
  x2=bomb.x+(cos(a)*r*bomb.sz)
  y2=bomb.y+(sin(a)*r*bomb.sz)
  line(x1,y1,x2,y2,bp[1+flr(rnd(3))])
  r+=1
  if (r==8) r=2
 end
 
 circfill(bomb.x,bomb.y,bomb.sz*2,7)
 
 --hit zone
 --rect(bomb.x-bomb.sz*6,bomb.y-bomb.sz*6,bomb.x+bomb.sz*6,bomb.y+bomb.sz*6,7)
end

function draw_particles(typ,rscam)
 if (rscam) camera()

 for x in all(typ) do
  if x.sz<=1.25 then 
   pset(x.x,x.y,x.c)
  else 
   circfill(x.x,x.y,x.sz,x.c)
  end
 end
end

function draw_stuff() 
 if (dead) return
 
 camera()
  
 --draw shot
 if sht>0 then
  local x,y
  if (shtp==3) x,y,i,j=0,0,1,1
  if (shtp==2) x,y,i,j=127,0,-1,1
  if (shtp==1) x,y,i,j=0,127,1,-1
  if (shtp==0) x,y,i,j=127,127,-1,-1
 
  local tx,ty,yo
  yo=0
  for x1=x,x+(5*i),i do
   yo+=j/2
   if x1==x then
    tx=x+(sht*i)-(3*i)
    ty=y+(sht*j)-(3*j)
   end
   line(x1+((sht+30)*i),y+yo+((sht+30)*j),tx,ty,8)
  end
 end
 
 --draw sight
 if mode==1 and not shd then
  line(64,61,64,67,7)
  line(61,64,67,64,7)
 end
 
 --draw shield
 if shd and tmr_16%2==0 then
  pal(1,0)
  if (tmr_shd>0) pal(1,8)
  for x=-0,127,8 do
   for y=0,127,8 do
    spr(48,x,y)
   end 
  end
  pal()
 end
 
 --credits (show when added) 
 if (d_cred==2 and tmr_coin>0) printc("credits "..credits,127,121,2,7,"",0)
end

function draw_hud()
 camera()
 
 if (mode==0) rectfill(0,0,127,8,0)
 
 --lives/score/hits
 pal(3,0)
 spr(49,1,1)
 spr(50,120,1)
 pal()
 
 printc(""..lives,10,2,1,7,"",0)
 printc("hi "..pad_score(hi),27,2,1,8,"",0)
 printc("1up "..pad_score(score),100,2,2,7,"",0)
 printc(""..hits_d,119,2,2,7,"",0)
 if (tmr_scr>0) printc(""..last*10,127,10,2,3,"g",0)
 
 if (dead or mode==0) return
 
 local lc,sc,hc=7,7,7
 if (w[1]==1) lc=10
 if (w[1]==2) lc=9
 if (w[1]==3) lc=8
 if (hull>=35) hc=9
 if (hull>=65) hc=8
 if (shield<75) sc=10
 if (shield<50) sc=9
 if (shield<25) sc=8
 
 --laser/shield/hull stuff...
 pal(3,0)
 spr(51,1,106)
 spr(52,1,113)
 spr(53,1,120)
 pal()
 
 if laser>0 then
  rectfill(9,107,9+(laser/100)*117,111,lc)
  rect(9,107,9+(laser/100)*117,111,0)
 end
 if shield>0 then
  rectfill(9,114,9+(shield/100)*117,118,sc)
  rect(9,114,9+(shield/100)*117,118,0)
 end
 if hull>0 then
  rectfill(9,121,9+(hull/100)*117,125,hc)
  rect(9,121,9+(hull/100)*117,125,0)
 end
 
 if (w[1]==2) printc("warning",64,107,0,7,"",0)
 if (w[1]==3) printc("overheat",64,107,0,7,"",0)
 if (w[4]==1) printc("no shield",64,114,0,7,"",0)
 if (w[2]==1) printc("warning",64,121,0,7,"",0)
 
 if w[3]==1 and tmr_16<9 then
  rectfill(1,9,17,17,8)
  rect(1,9,17,17,0)
  rectfill(110,9,126,17,8)
  rect(110,9,126,17,0)
 end
 
 if tmr_1up>0 then
  if (bon_shd) printc("shield recharge!",64,99,0,7,"g",0)
  if (bon_lif) printc("bonus life!",64,99,0,7,"g",0)
 end
 
end

function draw_title()
 if (mode==1) return
 
 --text
 rectfill(0,119,127,127,0)
 printc("-2017-",2,121,1,3,"",0)
 if (d_cred==0) printc("free play",127,121,2,7,"",-1)
 if (d_cred>0 and credits>0) printc("credits "..credits,127,121,2,7,"",-1)
 if credits==0 then
  printc("insert coin",64,96,0,10,"y",0)
 else
  printc("press — to start",62,96,0,10,"y",0)
 end
 
 --minsoft
 local p={2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,5,5,5,5,4,4,4,4,3,3,3,3,2,2,2,2}
 pal(2,4)
 pal(3,9)
 pal(4,10)
 pal(5,9)
 pal(6,4)
 if (tmr_236>200) pal(p[(tmr_236-200)],7)
 spr(58,48,119,5,1)
 pal()

	--title logo...
 pal(3,0)
 
 --during demo
 if not dead then
  if (tit_y==30 and tmr_16%2!=0) palt(3,true)
  sspr(0,96,101,30,64-(50*tit_sz),tit_y-(15*tit_sz),101*tit_sz,30*tit_sz)
  pal()
  palt()
  return
 end

 --after demo death
 if tmr_16%tit_f==0 then
  --logo (after demo)
  palt(3,true)
  sspr(0,96,101,30,14,15)
  palt()
  
  --rebel logo
  if tit_f<=4 then
   local r=tmr_32
   if (tmr_32>16) r=tmr_32-(tmr_32-16)*2
   local w=(24/16)*r
   if (w<1) w=1
   if (w<5) pal(7,1)
   if (w>=5 and w<12) pal(7,5)
   if (w>=12 and w<20) pal(7,6)
   sspr(104,96,24,24,64-(w/2),52,w,24)   
   pal()
  end
 end
 
end

function get_colour(t)
 --colour cycling
 local p
 if (t=="y") p={0,0,4,4,9,9,10,10,7,7,10,10,9,9,4,4}   
 if (t=="g") p={0,0,3,3,11,11,11,7,7,7,7,11,11,11,3,3}
 if (t=="b") p={0,0,12,12,12,12,15,15,7,7,15,15,12,12,12,12}
 if (t=="r") p={0,0,2,2,8,8,14,14,15,15,14,14,8,8,2,2}
 
 return p[tmr_16]
end

function printc(s,x,y,a,c,t,o)
 local sx,sy
 local	len=#s
	
	--align
	local xp=x-len*2     --centre
	if (a==1) xp=x       --left
	if (a==2) xp=x-len*4	--right
	if (xp<2) xp=2
	
	--cycled colours?
	if (t and t~="") c=get_colour(t)
  	
 --outline
 if o>-1 then
  for sx=xp-1,xp+1 do
   for sy=y-1,y+1 do
    if (not (sx==xp and sy==y)) print(s,sx,sy,o)
   end
  end
 end
 	
 --main
 print(s,xp,y,c)
end

function play_sfx(s,ch)
 if (d_sfx==0 and mode==0) return
 sfx(s,ch)
end

function pad_score(s)
 local l=#(""..s)
 local r=s
 
 if (l==1) r="000"..s
 if (l==2) r="00"..s
 if (l==3) r="0"..s
 --scores >99990 omit trailing 0
 if (l<5) r=r.."0"
 
 return r
end

function populate_menu()

 local cred="free"
 if (d_cred==1) cred="”"
 if (d_cred==2) cred="gpio"
 
 local gpio="off"
 if (d_gpio==1) gpio="on"
 
 local attr="off"
 if (d_sfx==1) attr="on"
 
 local yaxis="normal"
 if (d_y==1) yaxis="invert"
 
 menuitem(1,"reset hiscore",function() m_hi() end)
 menuitem(2,"credits:"..cred,function() m_cred() end)
 menuitem(3,"gpio outputs:"..gpio,function() m_gpio() end)
 menuitem(4,"attract sfx:"..attr,function() m_sfx() end)
 menuitem(5,"y-axis:"..yaxis,function() m_y() end)
end

function m_hi()
 hi=0
 dset(0,hi)
end

function m_cred()
 d_cred+=1
 if (d_cred==3) d_cred=0
 dset(1,d_cred)
 run()
end

function m_gpio()
 d_gpio=1-d_gpio
 if (d_gpio==0) gpio_off(true)
 dset(2,d_gpio)
 run()
end

function m_sfx()
 d_sfx=1-d_sfx
 dset(3,d_sfx)
 run()
end

function m_y()
 d_y=1-d_y
 dset(4,d_y)
end

function gpio_off(r)
 if (d_gpio==0 and not r) return
 
 for i=1,3 do
  gpio[i]=0
  poke(0x5f80+i,gpio[i])
 end
end

function update_gpio()
 if (d_gpio==0) return
 
 update_gpio12()

 if (mode==0) gpio[3]=0
 for i=1,3 do
  poke(0x5f80+i,gpio[i])
 end
 
 --debug=(gpio[1]/255)..(gpio[2]/255)..(gpio[3]/255)..(gpio[4]/255)
end
 
function update_gpio12() 
 --press start
 gpio[1],gpio[2]=0,0
 if tmr_16<9 then
  if credits>=1 and mode==0 then
   gpio[1]=255
   gpio[2]=255
  end
 end
 
 --warning
 if (mode==0) return
 if ((w[1]==3 or w[2]==1 or w[3]==1 or w[4]==1) and tmr_16<9) gpio[1],gpio[2]=255,255
 if (tmr_die>75 and tmr_16%2==0) gpio[1],gpio[2]=255,255
 
end

function check_coin()
 --no point for free play
 -- or 'up' when playing
 if (d_cred==0 or (d_cred==1 and mode==1)) return false
 
 --coin up (with up)
 if d_cred==1 and btnp(2,0) then
  credits+=1
  return true
 end
 
 --coin up (with gpio pin 0)
 if d_cred==2 and tmr_coin==0 and peek(0x5f80)==0 then
  credits+=1
  tmr_coin=15
  return true
 end
 
 return false
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006000000000000000060000006000000000000000000600006000000000000000060000006000000000000000000600000000000000000000000000
00700700006600000000000000060000006600000000000000006600006600000000000000060000006600000000000000006600000000000000000000000000
00077000006600000000000000616000006600000000000000006600006160000000000000616000006160000000000000061600000000000000000000000000
00077000006160000000000000616000006160000000000000061600006116000000000000616600006166000000000000661600000000000000000000000000
00700700061616000066660000661600061616000066660000616160061616600066660000661600061616000066660000616160000000000000000000000000
00000000061616000611666000661600061616000661166000616160061616600611666000661600061616000661166000616160000000000000000000000000
00000000061161606166166600616600061166006616616600661160061161606166166600616600061166006616616600661160000000000000000000000000
00000000061166661611616666616600061166666161161666661160061166661611616666616600061166666161161666661160000000000000000000000000
00000000066666661611616666666600066666666161161666666660066666661611616666666600066666666161161666666660000000000000000000000000
00000000061166666166166666616600061166666616616666661160061166666166166666616600061166666616616666661160000000000000000000000000
00000000061161606611666600616600061166006661166600661160061161606611666600616600061166006661166600661160000000000000000000000000
00000000061616600666666000661600061616000666666000616160061616600666666000661600061616000666666000616160000000000000000000000000
00000000061616600066660000661600061616000066660000616160061616600066660000661600061616000066660000616160000000000000000000000000
00000000006161600000000000616600066166000000000000661660006116000000000000616600006166000000000000661600000000000000000000000000
00000000006161600000000000616600066166000000000000661660006160000000000000616000006160000000000000061600000000000000000000000000
00000000006666000000000000066000006666000000000000666600006600000000000000060000006600000000000000006600000000000000000000000000
00000000006600000000000000060000006600000000000000006600006000000000000000060000006000000000000000000600000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000300000300030003000300333333300300030000000000000000000000000000000000000000000000000000000000000000000000000000000000
11000011003630003633363038303830366666303633363000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000001033633003636363003838300363636300366630000000000000000000000000000000000002202200200220002220022002220222000000000000000
10000001363636303666663000303000366666300036300000000000000000000000000000000000030030030303003030000300303000030000000000000000
10000001366666303636363003838300363636300366630000000000000000000000000000000000040040040404004004400400404400040000000000000000
10000001366366303633363038303830366666303633363000000000000000000000000000000000050050050505005000050500505000050000000000000000
11000011033033000300030003000300333333300300030000000000000000000000000000000000060060060606006066600066006000060000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000066600000060000000000000666000000666000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000006610600000066000000000066160000000061660000000000666000000060000000000000660000000066000000000000000000000000000000
00000000000661116000000061660000006611160000000061116600000066116000000066600000000066160000000061660000000000000000000000000000
00000000006111160000000006116000061111600000000006111160006611160000000006160000006611600000000006116600000000000000000000000000
00000000000611160066660006111600006111600066660006111600061111600066660000616600061116000066660000611160000000000000000000000000
00000000000061600611666000616000000616000661166000616000006611600611666000611600006116000661166000611600000000000000000000000000
00000000000006006166166600060000000060006616616600060000000066006166166600066000000660006616616600066000000000000000000000000000
00000000000006661611616666660000000060666161161666060000000006661611616666660000000060666161161666060000000000000000000000000000
00000000000006661611616666660000000066666161161666660000000006661611616666660000000066666161161666660000000000000000000000000000
00000000000006666166166666660000000060666616616666060000000006666166166666660000000060666616616666060000000000000000000000000000
00000000000066006611666600066000006660006661166600066600000066006611666600066000000660006661166600066000000000000000000000000000
00000000000611600666666000611600061116000666666000611160006611600666666000611600006116000666666000611600000000000000000000000000
00000000006111600066660000616000006611600066660006116600061111600066660000616600061116000066660000611160000000000000000000000000
00000000000661160000000006160000000066160000000061660000006611160000000006160000006611600000000006116600000000000000000000000000
00000000000006616000000066600000000000660000000066000000000066116000000066600000000066160000000061660000000000000000000000000000
00000000000000066000000060000000000000000000000000000000000000666000000060000000000000660000000066000000000000000000000000000000
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
00000000000006000000000006000000000066000000000000660000000006000000000006000000000006000000000000600000000000000006600000000000
00000000000661660000000061600000000611600000000006116000000061600000000061600000000061600000000006160000000000000006600000000000
00000000006111660000000066160000006116160000000061611600000616160000000066160000000616160000000061616000000000000006600000000000
00000000061116160000000061616000061161160000000061161160006161160000000061616000006161160000000061161600000000000066660000000000
00000000061161160066660006611600061611600066660006116160061161160066660006611600061161600066660006161160000000000061160000000000
00000000061611600611666006161600061616000661166000616160061161600611666006161600061616000661166000616160000000000061160000000000
00000000061611606166166606161600061616006616616600616160061611606166166606161600061616006616616600616160000000000066660000000000
00000000061666661611616666666600066666666161161666666660061666661611616666666600066666666161161666666660000000000661166000000000
00000000066666661611616666666600066666666161161666666660066666661611616666666600066666666161161666666660000000006616616600000000
00000000061666666166166666666600066666666616616666666660061666666166166666666600066666666616616666666660000000006161161600000000
00000000061611606611666606161600061616006661166600616160061611606611666606161600061616006661166600616160000000006161161600000000
00000000061161600666666006161600061616000666666000616160061161600666666006161600061616000666666000616160000006666616616666600000
00000000061161160066660006611600006161600066660006161600061161160066660006611600061161600066660006161160000061660661166066160000
00000000006161160000000061616000006161160000000061161600006161160000000061616000006161160000000061161600000611160066660061116000
00000000000616160000000066160000000616160000000061616000000616160000000066160000000616160000000061616000006116600000000006611600
00000000000616160000000066160000000061616000000616160000000616160000000066160000000061600000000006160000061666000000000000666160
00000000000061116000000061600000000006660000000066600000000061600000000061600000000006000000000000600000066000000000000000000660
00000000000006660000000006000000000000000000000000000000000006000000000006000000000000000000000000000000000000000000000000000000
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
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000000000
35555555555555555555555555555555555555553355555333555553355555555555555555555555555555555555555555553000000000000007700000000000
3566666666666666666666666666666666666665335ddd53335ddd5335ddddddddddddddddddddddddddddddddddddddddd53000000007000077770000700000
3566666666666666666666666666666666666665335ddd53335ddd5335ddddddddddddddddddddddddddddddddddddddddd53000000077000007700000770000
3566666666666666666666666666666666666665335ddd53335ddd5335ddddddddddddddddddddddddddddddddddddddddd53000000770000707707000077000
3555555555666555555555555555555555555555335ddd53335ddd5335555555555555555555555555555555ddd5555555553000007770000777777000077700
3333333335666533333333333333333333333333335ddd53335ddd5333333333333333333333333333333335ddd5333333333000007700000077770000007700
0000000035666533333333333333333333333333335ddd53335ddd5333333333333333333333333333333335ddd5300000000000077700000007700000007770
0000000035666533555553355555555553333333335ddd53335ddd5335555533355555335555555555555335ddd5300000000000077700000007700000007770
0000000035666533566653356666666653333333335ddd53335ddd5335ddd53335ddd5335ddddddddddd5335ddd5300000000000077700000007700000007770
0000000035666533566653356666666653333333335ddd53335ddd5335ddd53335ddd5335ddddddddddd5335ddd5300000000000777700000007700000007777
0000000035666533566653356666666653333333335ddd53335ddd5335ddd53335ddd5335ddddddddddd5335ddd5300000000000777700000007700000007777
0000000035666533566653356665555553333333335ddd53335ddd5335ddd53335ddd5335ddd55555ddd5335ddd5300000000000777770000077770000077777
0000000035666533566653356665333333333333335ddd53335ddd5335ddd53335ddd5335ddd53335ddd5335ddd5300000000000777770000077770000077777
0000000035666533566653356665333333333333335ddd53335ddd5335ddd53335ddd5335ddd53335ddd5335ddd5300000000000077777000777777000777770
0000000035666533566653356665333333333333335ddd53335ddd5335ddd53335ddd5335ddd53335ddd5335ddd5300000000000077777777777777777777770
0000000035666533566653356665553355555555335ddd55555ddd5335ddd53335ddd5335ddd53335ddd5335ddd5300000000000077777777777777777777770
0000000035666533566653356666653351111115335ddddddddddd5335ddd53335ddd5335ddd53335ddd5335ddd5300000000000007777777777777777777700
0000000035666533566653356666653351111115335ddddddddddd5335ddd53335ddd5335ddd53335ddd5335ddd5300000000000007777777777777777777700
0000000035666533566653356666653351111115335ddddddddddd5335ddd53335ddd5335ddd53335ddd5335ddd5300000000000000777777777777777777000
0000000035666533566653356665553355555555335ddd55555ddd5335ddd53335ddd5335ddd53335ddd5335ddd5300000000000000077777777777777770000
0000000035666533566653356665333333333333335ddd53335ddd5335ddd53335ddd5335ddd53335ddd5335ddd5300000000000000007777777777777700000
0000000035666533566653356665333333333333335ddd53335ddd5335ddd53335ddd5335ddd53335ddd5335ddd5300000000000000000077777777770000000
0000000035666533566653356665333333333333335ddd53335ddd5335ddd53335ddd5335ddd53335ddd5335ddd5300000000000000000000077770000000000
0000000035666533566653356665555553333333335ddd53335ddd5335ddd55555ddd5335ddd53335ddd5335ddd5300000000000000000000000000000000000
0000000035666533566653356666666653333333335ddd53335ddd5335ddddddddddd5335ddd53335ddd5335ddd5300000000000000000000000000000000000
0000000035666533566653356666666653333333335ddd53335ddd5335ddddddddddd5335ddd53335ddd5335ddd5300000000000000000000000000000000000
0000000035666533566653356666666653333333335ddd53335ddd5335ddddddddddd5335ddd53335ddd5335ddd5300000000000000000000000000000000000
00000000355555335555533555555555533333333355555333555553355555555555553355555333555553355555300000000000000000000000000000000000
00000000333333333333333333333333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
011400000062000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100001050401d0001c0001c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000021120201411f1411e1411d1411c1411b1411a1411914118141171411614115141131411214111141101410f1410e1410d141001411920014200000000000000000000000000000000000000000000000
010200003e6103c6113a6113861137611366113661128611003001920014200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500003e6103c2113a6113821137611362113661128211003001920014200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001503014051130511205111051100510f0510e0510d0510c0510b0510a0510905107051060510505104051030510205101051000511920014200000000000000000000000000000000000000000000000
010a00003e6103c6113a6113861137611366113661135611336112e61128611206111861111611096110461102611026110161100611003001920014200000000000000000000000000000000000000000000000
011000001a1401a1401a1422114021140211401f1401e1401c1402614026140261422114021140211422114500000000000000000000000000000000000000000000000000000000000000000000000030000000
011000000e1500e1500e155001000e1500e1500e155001000e1500e1500e15500100091500915009155111500e1500e1500e15500100091500915009155111500e1500e1520e1520e15500400000000000000000
0110000021140211452614026145211402114526140261452114026140261452114021142211422114500000211401f140211401f1401f145211401f1401f1451d1401d1421d1421a1401a1401a1450000000000
010800021c05000000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800022805019000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800023405019000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000041805000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000022105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002100000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002030577006771067700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002030677007771077700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002030777008771087700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002030877009771097700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01200203097700a7710a7700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002030a7700b7710b7700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002030b7700c7710c7700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002030c7700d7710d7700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002030d7700e7710e7700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002030e7700f7710f7700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002030f77010771107700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002031077011771117700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002031177012771127700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002031277013771137700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002031377014771147700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002031477015771157700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002031577016771167700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002031677017771177700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002031777018771187700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012002031877019771197700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01200203197701a7711a7700600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
