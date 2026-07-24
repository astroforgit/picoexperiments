pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- tube runner v1.0
-- by minsoft (2018)

--init functions

function _init()
 d_hi,d_cred,d_gpio,d_unlock=0,0,0,0
 if cartdata("tube_runner") then
  d_hi,d_cred=dget(0),dget(1)
  d_gpio=dget(2)
  d_unlock=dget(3)
 end
 init_menu()
 
 credits=0
 if (d_cred==0) credits=9999

 init_gpio(false)
 
 --segment parameters
 s={}

 --tunnel segment colours
 scm={
  {2,2,14,15,14,2,2},   --pink  
  {1,13,13,12,13,13,1}, --blue
  {3,3,3,11,3,3,3},     --green
  {5,5,6,7,6,5,5},      --white
  {4,4,9,10,9,4,4},     --orng
  {5,5,5,7,5,5,5},      --safe
  {5,5,5,9,5,5,5}       --charge
 }
 
 --segment-player offset
 s_offset=28
 
 --timers
 tmr_16,tmr_rec,tmr_smk,tmr_eng=1,0,0,0
 tmr_g,tmr_hit,tmr_die=0,0,0
 tmr_coin,tmr_hud,tmr_txt=0,0,128
 
 --demo inputs
 demo={}
 
 --pitch
 demo[35],demo[39]=4,8
 demo[48],demo[59]=4,8
 demo[71],demo[83]=4,8
 demo[92]=0
 --yaw
 demo[110],demo[118]=16,32
 demo[133],demo[151]=16,32
 demo[165],demo[173]=16,0
 --roll
 demo[180],demo[200]=1,2
 demo[238]=0
 --brake
 demo[250],demo[275]=48,0
 --demo
 demo[310],demo[313]=4,17
 demo[322]=0
 demo[330],demo[334]=8,0
 demo[340],demo[344]=10,32
 demo[348],demo[355]=1,34
 demo[365],demo[370]=0,33
 
 txt=""
 
 init_ships()
 init_title()
end

function init_gpio(r)
 gpio={}
 if (d_gpio==0 and not r) return

 for i=1,3 do
  gpio[i]=0
  poke(0x5f80+i,gpio[i])
 end
end

function init_title()
 init_gpio(false)

 mode=0
 
 tmr_236,tmr_die,tmr_ovr=1,0,0
 tmr_demo,tmr_txt=0,128
 
 wait(25)
end

function init_demo()
 mode,p_ship,tmr_demo=3,2,0
 init_game()
end

function init_game()
 b={}

 --player
 lives,score=3,0

 new_hi,new_unlock=false,false
 tmr_door,txt=0,"powering up"
 
 --tunnel
 rec={}
 t_x,t_y=0,0
 t_zone,t_quad=1,1
 q_len,q_limit=0,0
 p_len,p_limit=0,0
 srand(rnd(100))
 
 --demo
 if mode==3 then
  lives,t_zone=1,10
  srand(1)
 end
 
 p_zone,p_quad=t_zone,t_quad
 
 init_quadrant(true)
 scopy=copy(s)
 init_life()
end

function init_quadrant(gen)
 --generate quadrant
 
 --length/time limit
 q_len=s_offset+210+(14*t_zone) --divisible by 7 (excl offset)
 if (p_len==0) p_len=q_len
 set_quad_limit()
 
 if (not gen) return

 --segment properties
 s.x,s.y={},{}   --relative pos
 s.sx,s.sy={},{} --size (abs)
 s.c,s.sc={},{}  --colour/score
 
 --colour scheme
 local cs=t_zone-(ceil(t_zone/5)-1)*5
 
 --safe sector
 for i=1,s_offset do
  s.x[i],s.y[i]=0,0
  s.sx[i],s.sy[i]=128,128
  s.sc[i]=0
 end
 local c=6
 if (mode==2 and t_zone>1 and t_quad==1) c=7
 gen_seg_col(1,s_offset,c)
 
 --main
 repeat
  gen_seg_pos(s.x)
 until #s.x==q_len
 repeat
  gen_seg_pos(s.y)
 until #s.y==q_len
 repeat
  gen_seg_size(s.sx,s.sy)
 until #s.sx==q_len
 gen_seg_col(s_offset+1,q_len,cs)
 for i=s_offset+1,q_len do
  s.sc[i]=0.25*p_ship
  if (mode==3 and i<300) s.x[i],s.y[i]=0,0
 end
 
 tmr_seg=1
end

function init_life()
 dead,time_over=false,false
 
 --warnings
 w,w_sfx={0,0},0
  
 --tunnel
 t_x,t_y=0,0
 rec={}
 elapsed=0
 tmr_seg=1
 s=copy(scopy)
    
 --inputs
 inp={false,false,false,false}
 ax,ay,rd=0,0,0
 
 --player
 p_shd,p_spd=sh[p_ship].shd,0.2
 p_x,p_y,p_r=0,0,0
 if (lives==3 or mode==3) p_y=50
 p_seg=-1 --current pos (segment)
 hitro=0
 ch={0,0,0,0}
 
 tmr_hit=0
 smk={}
 prx=false
 
 if (txt~="powering up") txt=""
 
 --necessary in case player
 -- died after new quad. init'd
 init_quadrant(false)
end

function init_menu()

 local cred="free"
 if (d_cred==1) cred="”"
 if (d_cred==2) cred="gpio"
 
 local gpio="off"
 if (d_gpio==1) gpio="on"
 
 menuitem(1,"reset progress",function() m_prog() end)
 menuitem(2,"credits:"..cred,function() m_cred() end)
 menuitem(3,"gpio outputs:"..gpio,function() m_gpio() end)
end

function m_prog()
 dset(0,0)
 dset(3,0)
 run()
end

function m_cred()
 d_cred+=1
 if (d_cred==3) d_cred=0
 dset(1,d_cred)
 run()
end

function m_gpio()
 d_gpio=1-d_gpio
 if (d_gpio==0) init_gpio(true)
 dset(2,d_gpio)
 run()
end

function init_ships()
 --ship properties
 sh={{},{},{},{}}
 
 sh[1].m="kite"    --model
 sh[1].r="novice"  --rating
 sh[1].w=38        --width
 sh[1].h=16        --height
 sh[1].shd=40      --shield
 sh[1].spd=0.7     --max speed
 sh[1].a=0.06      --agility
 sh[1].c={1,12}	   --hud colour
 
 sh[2].m="kestrel"
 sh[2].r="competent"
 sh[2].w=22
 sh[2].h=8
 sh[2].shd=60
 sh[2].spd=0.8
 sh[2].a=0.1
 sh[2].c={3,11}
 
 sh[3].m="buzzard"
 sh[3].r="expert"
 sh[3].w=30
 sh[3].h=16
 sh[3].shd=80
 sh[3].spd=0.9
 sh[3].a=0.0875
 sh[3].c={5,6}
 
 sh[4].m="kestrel mk2"
 sh[4].r="master"
 sh[4].w=22
 sh[4].h=8
 sh[4].shd=120
 sh[4].spd=1
 sh[4].a=0.1
 sh[4].c={4,9}
 
 --2d vectors
 sh[1].vx,sh[1].vy=
 {-6,-19,-13,  0, 13,19, 6,  0,-6, 6},
 {15, 19,-10,-19,-10,19,15,-19,15,15}
 
 sh[2].vx,sh[2].vy=
 {-5,-11,  0,11, 5,  0,-5, 5},
 {11,  5,-11, 5,11,-11,11,11}
 
 sh[3].vx,sh[3].vy=
 {-5,-15,  0,15, 5,  0,-5, 5},
 {17, 22,-22,22,17,-22,17,17}
   
 ss_a,ss_last=0,1
end

function init_smoke(offset)
 local c={5,6,7}
 
 for i=1,5 do
  local p={}
  p.x=rnd(128)
  p.y=119+rnd(20)+offset
  p.sz=12
  p.c=c[1+flr(rnd(3))]
  
  add(smk,p)
 end
 
 tmr_smk=500
end
-->8
--update functions

function _update60()
 --ship selection
 if (mode==1) update_ss()

 --game/demo
 if mode>=2 then
  update_tunnel()
  update_inputs()
  update_clock()
  update_collisions()
  update_warnings()
  update_smoke()
 end
 
 --demo
 if (mode==3) update_demo()
 
 --general
 update_title_inputs()
 update_gpio()
 update_timers()
end

function update_ss()
 --ship selection
 
 ss_a-=0.003
 if (ss_a<0) ss_a=1
 tmr_ss-=0.015
 
 --start game
 if btnp(4) or btnp(5) or tmr_ss<=0 then
  sfx(-2,0)
  mode=2
  init_game()
  wait(50)
  return
 end
 
 if (d_unlock==0) return
 
 --left/right/(down)
 if d_unlock==3 and btn(3) then
  p_ship=4
 else
  p_ship=ss_last
  local l=d_unlock+1
  if (l>3) l=3
  if (btnp(1)) p_ship+=1
  if (btnp(0)) p_ship-=1
  if (p_ship<1) p_ship=l
  if (p_ship>l) p_ship=1
  ss_last=p_ship
 end
end

function update_tunnel()
 if (#rec==0) add_rect(1)
 
 if (p_seg==1 and tmr_door<65) return

 --increase size of rectangles
 local i=1
 local spd=p_spd
 if (p_seg<=0) spd=1
 if (tmr_g>0) spd=0
 for r in all(rec) do
  r.sz=r.sz*(1+(spd/10))
  r.sx=r.osx*r.sz
  r.sy=r.osy*r.sz
  r.x1=r.x-r.sx
  r.x2=r.x+r.sx
  r.y1=r.y-r.sy
  r.y2=r.y+r.sy
  r.h=false
  
  --perspective
  local dx=r.sx/(60+r.sz*40)
  local dy=r.sy/(60+r.sz*40)
  r.x1=r.x1-((p_x-r.x)*dx)
  r.x2=r.x2-((p_x-r.x)*dx)
  r.y1=r.y1-((p_y-r.y)*dy)
  r.y2=r.y2-((p_y-r.y)*dy)
      
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
  end
      
  --rotate
  r.pt[1].x,r.pt[1].y=rotate(r.x1,r.y1,p_x,p_y,p_r)
  r.pt[2].x,r.pt[2].y=rotate(r.x2,r.y1,p_x,p_y,p_r)
  r.pt[3].x,r.pt[3].y=rotate(r.x2,r.y2,p_x,p_y,p_r)
  r.pt[4].x,r.pt[4].y=rotate(r.x1,r.y2,p_x,p_y,p_r)
  
  --player 'camera'
	 for i=1,4 do
	  r.pt[i].x-=p_x
	  r.pt[i].y-=p_y
	 end  
  
  --delete offscreen rects
  if r.sz>30 then
   del(rec,r)
  else
   i+=1
  end
 end
 
 --add rectangle
 local i=get_smallest_rect()
 if rec[i].sx>0.175 or rec[i].sy>0.175 then
  add_rect(tmr_seg)
  
  tmr_seg+=1
  if tmr_seg==q_len+1 then
   t_quad+=1
   if t_quad==5 then
    t_zone+=1
    if (t_zone>15) t_zone=1
    t_quad=1
   end
   
   --generate next quadrant
   init_quadrant(true)
  end
 
  --bends
  t_x+=s.x[tmr_seg]
  t_y+=s.y[tmr_seg]
 end
 
end

function update_inputs()
 if (dead or time_over or tmr_door<65 or tmr_g>0) return

 --get dpad state
 if mode==3 then
  update_demo_inputs()
 else
  for i=1,6 do
   b[i]=btn(i-1)
  end
  --invert y-axis (un-rem)
  --local t=b[4]
  --b[4]=b[3]
  --b[3]=t
 end
 
 --braking
 local br=b[5] and b[6]
 
 --increase travel when held
 local ah=sh[p_ship].a
 local ah2,ah3=ah/2,ah/3
 
 --roll
 if (inp[1] and b[1]) ax-=ah
 if (inp[2] and b[2]) ax+=ah
  
 --pitch
 if (inp[3] and b[3]) ay+=ah
 if (inp[4] and b[4]) ay-=ah
 
 --yaw
 if (inp[5] and b[5]) rd+=ah3
 if (inp[6] and b[6]) rd-=ah3
  
 --limit travel
 if (ax<-5) ax=-5
 if (ax>5) ax=5
 if (ay<-5) ay=-5
 if (ay>5) ay=5
 if (rd<-5) rd=-5
 if (rd>5) rd=5
 
 --return to centre when released
 --roll
 if (not b[1] and ax<=-ah2) ax+=ah2
 if (not b[2] and ax>=ah2) ax-=ah2
 --pitch
 if (not b[3] and ay>=ah2) ay-=ah2
 if (not b[4] and ay<=-ah2) ay+=ah2
 --yaw
 if ((not b[5] or br) and rd>=ah3) rd-=ah3
 if ((not b[6] or br) and rd<=-ah3) rd+=ah3
  
 --record direction(s) pressed
 for i=1,6 do
  inp[i]=b[i]
 end
 
 --rotate (roll)
 p_r+=ax/600
 if (p_r<0) p_r=1
 if (p_r>1) p_r=0

 --pitch
 local bx,by=0,0
 if ay~=0 then
  bx,by=rotate(0,ay,0,0,p_r)
  p_x-=bx
  p_y+=by
 end
 
 --rudder (yaw)
 bx,by=rotate(rd,0,0,0,p_r)
 p_x-=bx
 p_y+=by
 
 --brake
 if br then
  p_spd-=sh[p_ship].spd*0.003 --0.3%
  fix_speed()
 else
  --accelerate
  if tmr_hit<15 then
   p_spd+=((0.001*sh[p_ship].spd)/p_spd)
   fix_speed()
  end
 end
end

function update_demo_inputs()
 local d=demo[p_seg]
 
 if (not d) return
 
 for i=1,6 do
  b[i]=false
 end
 
 if (band(d,1)==1) b[1]=true
 if (band(d,2)==2) b[2]=true
 if (band(d,4)==4) b[3]=true
 if (band(d,8)==8) b[4]=true
 if (band(d,16)==16) b[5]=true
 if (band(d,32)==32) b[6]=true
end

function update_clock()
 if (tmr_door<65 or tmr_g>0) return

 --calc elapsed time
 if not q_comp and p_seg>s_offset then
  elapsed=time()-q_time
  if (not dead and not time_over) txt=""
 end
 
 if (dead) return
  
 --quadrant complete
 if not q_comp and p_seg==p_len then
  q_comp=true
  if time_over then
   tmr_eng=75
   txt="engine restored"
   sfx(4,2)
  end
    
  bonus=10+ceil((p_zone*5)+(p_quad*2.5))
  if (bonus<0 or time_over) bonus=0
  if (bonus>99) bonus=99
  add_score(bonus)
  
  time_over=false
  
  --keep copy of info
  -- (quad not yet complete)
  p_zone=t_zone
  p_quad=t_quad
  p_len=q_len
  p_limit=q_limit
  scopy=copy(s)
    
  if (txt~="engine restored") txt="zone "..get_hex(p_zone)..":"..p_quad
 end
 
 w[2]=0
 --charge shield
 if q_comp and p_quad==1 then
  w[2]=4
  local ps=sh[p_ship].shd
  p_shd+=ps*0.001 --+0.1%
  if (p_shd>ps) p_shd=ps w[2]=0
  if (p_shd>ps/2) w[1]=0
 end
 
 --time low/over warnings
 if not q_comp and p_spd>0.05 then
  if (elapsed+10>p_limit) w[2]=1
  if (elapsed+3>p_limit) w[2]=2
  if (elapsed>p_limit) w[2]=3
 end
 
 --time over
 if not time_over and not q_comp and elapsed>p_limit then
  time_over=true
  txt="t+ engine shut-off"
  sfx(03,2)
 end
end

function update_collisions()
 --hit wall...
 
 local cl={}
 for i=1,3 do
  cl[i]={}
 end
 
 --rotate line (ship!)
 cl[1].x1,cl[1].y1=rotate(64-(sh[p_ship].w/2),64,64,64,-p_r)
 cl[1].x2,cl[1].y2=rotate(64+(sh[p_ship].w/2),64,64,64,-p_r)
 cl[2].x1,cl[2].y1=rotate(64-(sh[p_ship].w/6),64-(sh[p_ship].h/2),64,64,-p_r)
 cl[2].x2,cl[2].y2=rotate(64+(sh[p_ship].w/6),64-(sh[p_ship].h/2),64,64,-p_r)
 cl[3].x1,cl[3].y1=rotate(64-(sh[p_ship].w/6),64+(sh[p_ship].h/2),64,64,-p_r)
 cl[3].x2,cl[3].y2=rotate(64+(sh[p_ship].w/6),64+(sh[p_ship].h/2),64,64,-p_r)

 --check intersection with rect
 local col=0
 local cr=get_col_rect(1)
 
 if cr then
  local crr=copy(cr)
  crr.x1=64-p_x+crr.x-(crr.osx/2)
  crr.y1=64-p_y+crr.y-(crr.osy/2)
  crr.x2=64-p_x+crr.x+(crr.osx/2)
  crr.y2=64-p_y+crr.y+(crr.osy/2)
  col=intersect(crr,cl[1])
  if (col==0) col=intersect(crr,cl[2])
  if (col==0) col=intersect(crr,cl[3])

  p_seg=cr.pos
  if (p_seg==s_offset+1) q_time,q_comp=time(),false
  add_score(cr.sc)
  cr.sc=0
    
  --proximity display
  -- (scale down/rotate/offset)
  prx=copy(cr)
  prx.x1=(-p_x+prx.x-(prx.osx/2))/4
  prx.y1=(-p_y+prx.y-(prx.osy/2))/4
  prx.x2=(-p_x+prx.x+(prx.osx/2))/4
  prx.y2=(-p_y+prx.y+(prx.osy/2))/4 
  prx.pt[1].x,prx.pt[1].y=rotate(prx.x1,prx.y1,0,0,p_r)
  prx.pt[2].x,prx.pt[2].y=rotate(prx.x2,prx.y1,0,0,p_r)
  prx.pt[3].x,prx.pt[3].y=rotate(prx.x2,prx.y2,0,0,p_r)
  prx.pt[4].x,prx.pt[4].y=rotate(prx.x1,prx.y2,0,0,p_r)
  for i=1,4 do
   prx.pt[i].x-=37
   prx.pt[i].y+=37
  end
  
 end
 
 --stop moving through wall
 cr=get_col_rect(1)
 if cr then
  local sp=false
  local hh=sh[p_ship].h/2
  if (p_x-hh<cr.x-(cr.osx/2)) p_x=cr.x+hh-(cr.osx/2) ay,rd=0,0 sp=true
  if (p_x+hh>cr.x+(cr.osx/2)) p_x=cr.x-hh+(cr.osx/2) ay,rd=0,0 sp=true
  if (p_y-hh<cr.y-(cr.osy/2)) p_y=cr.y+hh-(cr.osy/2) ay,rd=0,0 sp=true
  if (p_y+hh>cr.y+(cr.osy/2)) p_y=cr.y-hh+(cr.osy/2) ay,rd=0,0 sp=true
  if sp then
   if dead or time_over then
    if (tmr_16%4==0) init_smoke(1/p_spd)
    if (p_spd>0 and tmr_236%flr(5*(1/p_spd))==0) sfx(1,2)
   end
  end
 end
 
 --hit
 if col>0 and tmr_hit==0 then
  ch[col]=1
  hit(col)
 end
 
end

function update_warnings() 
 --sfx 
 local new_sfx=-2

 local fx={}
 fx[1],fx[2]={63},{62,61,60,05}

 for i=1,2 do
  if w[i]>0 then
   new_sfx=fx[i][w[i]]
  end
 end

 if (new_sfx==w_sfx) return

 w_sfx=new_sfx
 sfx(new_sfx,3)
end

function update_smoke()
 if (tmr_smk==0) return
 
 for p in all(smk) do
  p.x=p.x-2+rnd(4)
  p.y=p.y-rnd(1)
  if (draw) p.sz-=rnd(1) 
  if (p.sz<1) del(smk,p)
 end
end

function update_demo()
 if (dead) return
 
 if (p_seg>=3) txt="auto accelerate"
 if (p_seg>=30) txt="” ƒ = pitch  "
 if (p_seg>=95) txt="Ž — = yaw  "
 if (p_seg>=175) txt="‹ ‘ = roll  "
 if (p_seg>=245) txt="Ž+— = brake  " 
 if (p_seg>=275) txt=""
end

function update_title_inputs()
 --credit
 if check_coin() then
  sfx(59,2)
  tmr_demo=0
  if (mode==3) init_title()
 end
 
 if (mode==2 or credits==0) return
  
 --start
 if btnp(4) or btnp(5) then
  if mode==3 then
   sfx(-1)
   init_title()
   return
  end
  credits-=1
  mode,p_ship,tmr_ss=1,1,15
  sfx(58,0)
 end
end

function update_timers()
 tmr_16+=1
 if (tmr_16==17) tmr_16=1
 draw=tmr_16%2==0
 
 tmr_236+=1
 if tmr_236==237 then
  tmr_236=1
  tmr_demo+=1
 end
 if (mode==0 and tmr_demo>=4 and tmr_txt==128) init_demo()

 if tmr_hit>0 then
  p_r-=(hitro/75)*p_spd
  hitro=hitro*0.95
  tmr_hit-=1
  
  if not dead then 
   if (ch[1]==1) p_y+=tmr_hit*p_spd*0.025
   if (ch[2]==1) p_x-=tmr_hit*p_spd*0.025
   if (ch[3]==1) p_y-=tmr_hit*p_spd*0.025
   if (ch[4]==1) p_x+=tmr_hit*p_spd*0.025
  end 
  if tmr_hit==0 then
   hitro=0
   ch={0,0,0,0}
   gpio[3]=0
  end
 end
 
 if tmr_smk>0 then 
  tmr_smk-=1
  if (tmr_smk==0) smk={}
 end
  
 if dead or time_over then
  if (tmr_16==16) p_spd=p_spd*0.9
  if p_spd>0 and p_spd<0.05 then
   p_spd,tmr_die,dead=0,50,true
   w={0,0}
  end
 
  if p_spd>0 then 
   local bx,by=rotate(0,0.25/p_spd,0,0,p_r)
   p_x-=bx
   p_y+=by
  end
 end
 
 if tmr_eng>0 then 
  local bx,by=rotate(0,-0.15/p_spd,0,0,p_r)
  p_x-=bx
  p_y+=by
  tmr_eng-=1
 end
  
 if tmr_die>0 then 
  tmr_die-=1
  if tmr_die==0 then
   life_lost()
   if (lives>0) init_life()
  end
 end
  
 if tmr_ovr>0 then
  tmr_ovr-=1
  if (tmr_ovr==0) init_title()
 end

 if (tmr_coin>0) tmr_coin-=1
 
 tmr_hud+=rnd(2)
 if (tmr_hud>=128) tmr_hud=0
 
 --scrolling text
 if tmr_16%2==0 then
  tmr_txt-=1
  if (tmr_txt<=-#txt*4) tmr_txt=128
 end
 
 if mode>=2 then
  if (p_seg>=0 and tmr_door<64) tmr_door+=0.5
  if tmr_door>0 and tmr_door<64 then
   sfx(57,0) --door slam
   gpio[3]=255
  end
  if tmr_door==64 then
   tmr_door,tmr_g=65,50
   txt="systems enabled"
   sfx(4,1) --ship
  end
 
  if tmr_g>0 then
   init_smoke(abs(50-tmr_g))
   tmr_g-=0.5
   if tmr_door==65 and p_seg==1 then
    p_y=tmr_g
    p_r=-0.005+rnd(0.01)
    if p_y==0 then
     p_r=0 
     txt="go!"
     gpio[3]=0
     if (mode==2) music(1,0,7)
    end
   end
  end
 end
end

function update_gpio()
 if (d_gpio==0) return
 
 update_gpio12()

 if (mode~=2) gpio[3]=0
 for i=1,3 do
  poke(0x5f80+i,gpio[i])
 end
 
 --debug=(gpio[1]/255)..(gpio[2]/255)..(gpio[3]/255)
end

function update_gpio12() 
 --press start
 gpio[1],gpio[2]=0,0
 if tmr_16<9 then
  if credits>=1 and (mode==0 or mode==3) then
   gpio[1]=255
   gpio[2]=255
  end
 end
 
 --warning
 if (mode~=2) return
 if ((w[1]==1 and tmr_16>8) or w[2]==3) gpio[1],gpio[2]=255,255
end

function update_unlock()
 if (d_unlock==3) return
 
 local u=0
 
 --unlock ship 2=ship 1 zone 3
 if (d_unlock==0 and p_zone>3) u=1
 --unlock ship 3=ship 2 zone 5
 if (d_unlock==1 and p_zone>5 and p_ship==2) u=2
 --unlock ship 4=6000 pts
 if ((d_unlock==2 or u==2) and d_hi>=6000) u=3
 
 if u>0 then
  d_unlock=u
  dset(3,d_unlock)
  new_unlock=true
 end
end
-->8
--draw functions

function _draw()
 cls()
 
 if (mode==0) draw_title()
 if (mode==1) draw_ss()
 
 if mode>=2 and (p_seg>0 or tmr_door<65) then
  draw_tunnel()
  draw_smoke()
  draw_door()
  draw_hud()
  draw_cockpit()
 end
 
 draw_message()

 --credits (show when added) 
 if (tmr_coin>0) draw_credits()
 
 if (debug) print(debug,15,3,7)
end

function draw_title()
 local c=12
 if (tmr_16>8) c=7

 --hiscore
 local h="hiscore "..d_hi
 print(h,abs(tmr_txt-128)-(#h*4),1,c)
 
 --main image
	rectfill(0,9,127,11,2)
	rectfill(0,10,127,10,14)
 sspr(0,48,128,80,0,15)
 rectfill(0,98,127,100,2)
 rectfill(0,99,127,99,14) 
 
 --minsoft logo
 local p={2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,5,5,5,5,4,4,4,4,3,3,3,3,2,2,2,2}
 pal(2,4)
 pal(3,9)
 pal(4,10)
 pal(5,9)
 pal(6,4)
 if (tmr_236>200) pal(p[(tmr_236-200)],7)
 spr(1,48,120,5,1)
 pal()
 
 --credits
 if (d_cred>0 and credits>0) draw_credits()
 
 --text
 txt=" insert coin "
 if (credits>0) txt="press Ž or — to start"
 print(txt,tmr_txt,109,c) 
end

function draw_credits()
 local cr=credits-1
 if (cr>4) cr=4
 for x=122,122-(cr*5),-5 do
  spr(13,x,122)
 end
end

function draw_ss()
 --ship selection screen 
 cls()
 
 if (tmr_236%40==0 and rnd(2)<0.5) camera(rnd(3),rnd(3))
 
 fillp(flr(rnd(65536)))
 local c,dr
 for i=1,3 do
  c=0x35
  dr=draw
  if (i==p_ship or (i==2 and p_ship==4)) c=0x3b dr=true
  if (not dr) break
  if (d_unlock+1)>=i then
   draw_ss_ship(i,i*32,56,c,ss_a,0.60)
  else
   print("?",(i*32)-2,50,3)
  end
 end
 fillp()
 
 draw_ss_text() 
 draw_ss_attrib(62,80,ceil((sh[p_ship].w*sh[p_ship].h)/60.8))
 draw_ss_attrib(62,90,ceil((sh[p_ship].shd/(30*sh[p_ship].spd))*3))
 draw_ss_attrib(62,100,flr(sh[p_ship].spd/0.1))
 draw_ss_attrib(62,110,flr(sh[p_ship].a/0.01))
 
 if (rnd(2)<0.5) draw_glitches({0,3,11})
 
 camera()
end

function draw_ss_ship(n,x,y,c,a,s)
 --draw 2d ship from vectors
 for i=2,#sh[n].vx do
  local x1,y1=sh[n].vx[i-1]*s,sh[n].vy[i-1]*s
  local x2,y2=sh[n].vx[i]*s,sh[n].vy[i]*s
  x1,y1=rotate(x1+x,y1+y,x,y,a)
  x2,y2=rotate(x2+x,y2+y,x,y,a)
  line(x1,y1,x2,y2,c)
 end
end

function draw_ss_text()
 --ship selection text
 
 local c=3
 if (tmr_16>12) c=11
 
 if draw then
  rectfill(0,0,127,6,3)
  print(" model: "..sh[p_ship].m,30,20,3)
  print("rating: "..sh[p_ship].r,30,30,3) 
  print("  mass:",30,80,3)
  print("energy:",30,90,3)
  print(" speed:",30,100,3)
  print("agility:",26,110,3)
 
  --countdown
  local t=ceil(tmr_ss)
  if (#(""..t)==1) t="0"..t
  print(t,4,121,c)
 end
 
 print("ship selection",36,1,11)
 if d_unlock>0 then
  print("‹",2,54,c)
  print("‘",119,54,c)
 end
 if (d_unlock==3) print("ƒ",60,69,c) 
end

function draw_ss_attrib(x,y,val)
 for i=1,10 do  
  if (draw) spr(10,x,y)
  if i<=val then
   pal(3,11)
   spr(10,x,y)
   pal()
  end
  x+=4
 end
end

function draw_tunnel()
 --draw tunnel
 
 if tmr_hit>15 and p_spd>0 then
  local s=p_spd*2
  camera(rnd(s*2)-s,rnd(s*2)-s)
 end
 
 local i=1
 for r in all(rec) do
  if not r.h then
   mline(r.pt[1].x,r.pt[1].y,r.pt[2].x,r.pt[2].y,r.c)
   mline(r.pt[2].x,r.pt[2].y,r.pt[3].x,r.pt[3].y,r.c)
   mline(r.pt[3].x,r.pt[3].y,r.pt[4].x,r.pt[4].y,r.c)
   mline(r.pt[4].x,r.pt[4].y,r.pt[1].x,r.pt[1].y,r.c)
   
   l=get_prev_rect(i)
   if l then
    mline(r.pt[1].x,r.pt[1].y,rec[l].pt[1].x,rec[l].pt[1].y,r.c)
    mline(r.pt[2].x,r.pt[2].y,rec[l].pt[2].x,rec[l].pt[2].y,r.c)
    mline(r.pt[3].x,r.pt[3].y,rec[l].pt[3].x,rec[l].pt[3].y,r.c)
    mline(r.pt[4].x,r.pt[4].y,rec[l].pt[4].x,rec[l].pt[4].y,r.c)
   end
  end
  i+=1
 end
 
 camera()  
end

function draw_smoke()
 for p in all(smk) do
  circfill(p.x,p.y,p.sz,p.c)
 end
end

function draw_door()
 if (p_seg>4) return

 palt(0,false)
 map(0,0,0,0-tmr_door,16,8)
 map(0,8,0,64+tmr_door,16,8)
 palt()
 
 local t="zone 1"
 if (mode==3) t="demonstration"
 printc(t,64,53-tmr_door,9,5)
 printc("quadrant 1",64,69+tmr_door,9,5)
end

function draw_hud()
 local dr,dr2=draw,true
 local c=sh[p_ship].c
 local g=dead and not time_over
 
 --glitches
 if g or tmr_hit>15 then
  --flick off
  if (rnd(1)<0.2) dr,dr2=false,false
  --corrupt proximity data
  if prx then
   local p=1+flr(rnd(4))
   prx.pt[p].x+=rnd(5)
   prx.pt[p].y=prx.pt[p].y-2.5+rnd(5)
  end
 end
 
 if g then
  --wobble
  if (tmr_16==8) camera(rnd(3),rnd(3))
  
  --iffy shield value
  p_shd=0
  if (rnd(1)<0.1) p_shd=rnd(sh[p_ship].shd)
 end
 
 --messages
 if txt~="" then
  if (dr and dr2) rectfill(9,2,118,8,c[1])
  if (dr2) printc(txt,64,3,c[2],-1)
 end
 
 --icons
 if dr then
  pal(3,c[1])
  pal(11,c[2])
  spr(12,1,103)
  spr(11,124,103)
  pal()
 end
 
 if (tmr_door<10) camera() return
 
 --shield
 fillp(0b1111000011110000.1)
 if (dr) rectfill(1,24,3,100,c[1])
 local ds=(p_shd/sh[p_ship].shd)*38
 if p_shd>0 and dr2 and (p_quad>1 or not q_comp or p_shd==sh[p_ship].shd or (q_comp and tmr_16<=8 and p_shd<sh[p_ship].shd)) then
  rectfill(1,62-ds,3,62+ds,c[2])
 end
 fillp()
 
 if (tmr_door<35) return
  
 --progress
 fillp(0b1111000011110000.1)
 if (dr) rectfill(124,24,126,100,c[1])
 local pr=p_seg-s_offset
 if (pr<=0) pr=0
 if (q_comp) pr=p_len-s_offset
 if (pr>0 and dr2 and (not q_comp or q_comp and tmr_16<=8)) rectfill(124,100,126,101-((pr/(p_len-s_offset))*76),c[2])
 fillp()

 if (tmr_door<60) return
 
 --proximity gauge
 if (tmr_hit<20) or (tmr_hit>20 and tmr_16%4==0) then
  line(27-(sh[p_ship].w/8),101,27+(sh[p_ship].w/8),101,c[2])
  line(27-(sh[p_ship].w/24),101-(sh[p_ship].h/8),27+(sh[p_ship].w/24),101-(sh[p_ship].h/8),c[2])
  line(27-(sh[p_ship].w/24),101+(sh[p_ship].h/8),27+(sh[p_ship].w/24),101+(sh[p_ship].h/8),c[2])
 end
 if dr and prx then
  local pc=c[2]
  fillp(flr(rnd(65536)))
  mline(prx.pt[1].x,prx.pt[1].y,prx.pt[2].x,prx.pt[2].y,pc)
  mline(prx.pt[2].x,prx.pt[2].y,prx.pt[3].x,prx.pt[3].y,pc)
  mline(prx.pt[3].x,prx.pt[3].y,prx.pt[4].x,prx.pt[4].y,pc)
  mline(prx.pt[4].x,prx.pt[4].y,prx.pt[1].x,prx.pt[1].y,pc)
  fillp()
 end
 
 --dead - glitches
 if (g) draw_glitches(c)
 
 if (mode==3) draw_demo()
  
 fillp()
 camera()
end

function draw_cockpit()
 local c=sh[p_ship].c
 local dr2=true
 local g=dead and not time_over
 
 if (g and rnd(2)<0.1) dr2=false 
 if (tmr_door<25) dr2=false
 if (tmr_door<50 and rnd(2)<1) dr2=false
 
 --cockpit/dash gfx
 palt(0,false)
 palt(14,true)
 if ((w[1]==1 and tmr_16>8) or w[2]==3) pal(2,8)
 sspr(0,8,16,24,0,0)
 sspr(0,8,16,24,112,0,16,24,true)
 line(16,0,111,0,1)
 line(16,1,111,1,5)
 pal(2,2)
 sspr(0,32,128,16,0,112)
 palt()
 
 --displays 'off'
 if draw then
  print("88888",18,121,c[1])
  print("8888888",66,121,c[1])
  print("8",109,121,2)
 end
 
 --hiscore light
 if (new_hi) spr(8,40,122)
 
 --time low lights
 if w[2]>0 and w[2]<4 and tmr_16>8 then
  spr(9,59,121)
  spr(9,96,121)
 end
 
 --pointless lights
 local lc={8,11}
 if (not dr2) lc={2,2}
 for i=46,54,2 do
  if (tmr_door<i) break
  pset(i,123,lc[1+flr(rnd(2))])
 end
 pset(104,122,lc[1+flr(rnd(2))])
 pset(104,124,lc[1+flr(rnd(2))])
   
 --timer stuff (prob shouldn't be in _draw)
 local e=p_limit-elapsed
 local tl="-"
 if (e<0) tl="+"
 tl=tl..dp(abs(e))
 if g and rnd(1)<0.05 then
  tl=flr(rnd(10))
  tl=tl..tl..tl..tl..tl..tl..tl
 end
 if q_comp then 
  local b=""..bonus
  if (#b==1) b="0"..bonus
  tl="+ "..b.." pt"
 end
 
 if dr2 then
  --lives
  if (lives>=1) spr(6,7,123)
  if (lives>=2) spr(6,10,123)
  if (lives>=3) spr(6,13,123)
  --score
  print(pad_score(flr(score)),18,121,c[2])
  --timer
  print(tl,66,121,c[2])
  --zone
  print(""..get_hex(p_zone),109,121,8)  
  --quadrant
  if (p_quad>=1) spr(7,115,123)
  if (p_quad>=2) spr(7,117,123)
  if (p_quad>=3) spr(7,119,123)
  if (p_quad==4) spr(7,121,123)
 end
  
 --speedo
 local ds=p_spd-0.2
 if (tmr_door<65 or tmr_g>0 or ds<0) ds=0
 fillp(0b1010101010101010)
 if (draw) rectfill(67,115,107,117,c[1]) 
 if (dr2 and ds>0) rectfill(67,116,67+(ds/(sh[p_ship].spd-0.2))*40,116,c[2])
 fillp() 
 
end

function draw_glitches(c)
 line(0,tmr_hud,127,tmr_hud,c[flr(1+rnd(1.1))])
  
 if tmr_16%16==0 then
  for i=1,200 do
   pset(rnd(128),rnd(128),c[flr(1+rnd(1.1))])
  end
 end
  
 if tmr_236%40==0 then
  fillp(0b1111000011110000)
  rectfill(0,0,127,127,c[flr(1+rnd(1.1))])
 end
end

function draw_message()
 if (mode<2) return

 local t,t2
 local c=12
 if (tmr_16>8) c=7
 
 if mode==3 then
  t="insert coin"
  if (credits>0) t="press Ž or —  "
  printc(t,64,34,c,0)
  return
 end
 
 if (tmr_ovr==0) return
 
 if (tmr_ovr>0) t="game over"
 if (new_hi) t="new high score!"
 if (new_unlock) t2="ship unlocked!"
  
 if (not t) return
  
 printc(t,64,34,c,0)
 if (t2) printc(t2,64,44,c,0)
end

function draw_demo()
 if (dead or not draw) return

 local c=sh[p_ship].c
 local bc={}
 
 for i=1,6 do
  bc[i]=c[1]
  if (b[i]) bc[i]=c[2]
 end
 
 --inverted y-axis
 --local t=bc[4]
 --bc[4]=bc[3]
 --bc[3]=t
 
 print("”",73,95,bc[3])
 print("ƒ",73,105,bc[4])
 print("‹",65,100,bc[1])
 print("‘",81,100,bc[2])
 
 print("Ž",92,100,bc[5])
 print("—",101,100,bc[6])
 
 if p_seg>5 and p_seg<30 then
  print("‹ energy",10,64,11)
  print("progress ‘",75,64,11)
 end
end
-->8
--misc functions

function check_coin()
 --no point for free play
 -- or 'up' when playing
 if (d_cred==0 or (d_cred==1 and mode==2)) return false
 
 --coin up (with up or gpio pin 0)
 if (d_cred==1 and btnp(2,0)) or (d_cred==2 and tmr_coin==0 and peek(0x5f80)==0) then
  credits+=1
  tmr_coin=15
  return true
 end
 
 return false
end

function fix_speed()
 if time_over then
  if (p_spd<0) p_spd=0
  return
 end
 if (p_spd<0.2) p_spd=0.2
 if (p_spd>sh[p_ship].spd) p_spd=sh[p_ship].spd
end

function add_score(s)
 if (dead) return
 score+=s 
 
 if (mode==2 and flr(score)>d_hi) d_hi,new_hi=flr(score),true
end

function hit(side)
 --ship hit wall
 if (p_spd>0 and #smk==0) sfx(0,2)
 
 --collision roll direction
 local a=p_r
 if side==2 or side==4 then
  a-=0.25 
  if (a<0) a+=1
 end
 hitro=sin(a)
 if (a<0.25 or a>0.75) hitro=-hitro
 if (p_r>0.95 or p_r<0.05) hitro=0
 if (p_r>0.2 and p_r<0.3) hitro=0
 if (p_r>0.45 and p_r<0.55) hitro=0
 if (p_r>0.7 and p_r<0.8) hitro=0

 if (p_spd>0) gpio[3]=255
 
 if (not dead) then
  tmr_hit=35
  p_spd=p_spd*0.85
  fix_speed()
  p_shd-=30*p_spd
  if (p_shd<=sh[p_ship].shd/2 and tmr_die==0) w[1]=1
  --dead
  if p_shd<=0 then
   p_shd,dead,tmr_die=0,true,230
   txt="system failure"
   sfx(2,3)
  end
 else
  tmr_hit=500
 end
end

function life_lost()
 --restart on incomplete quad
 t_zone,t_quad=p_zone,p_quad
  
 gpio[3]=0
 lives-=1
 if lives==0 then
  tmr_236,tmr_ovr=1,500
  if (mode==3) return
  if (new_hi) dset(0,d_hi)
  update_unlock()
  music(-1,7500)
 end
end

function set_quad_limit()
 local m
  
 if (p_ship==1) m=0.235
 if (p_ship==2) m=0.2025
 if (p_ship==3) m=0.2
 if (p_ship==4) m=0.17
 
 --compensate for longer zone/quads
 m-=(t_zone-1)*0.0012
 
 --quad limits progressively tighter
 m2=t_zone/(t_zone*(100+((t_zone-1)*((t_zone-1)/2))))
 m-=(t_quad-1)*m2 --z1=0.01,z15=0.005
  
 q_limit=(q_len-s_offset)*m
 if (p_limit==0) p_limit=q_limit
end

function gen_seg_pos(axis)
 --generate relative x/y
 -- positions for section of
 -- segments
 
 --start/end segment
 local s=#axis+1
 local sh=15+flr(rnd(40))
 local e=s+sh
 if (e>q_len) e=q_len
 
 --ultimate travel
 local mo=rnd(t_zone*7)-(t_zone*3.5)
 
 --limit sharpness of corner
 -- (avoid being unfair)
 local sf=0.1+(t_zone/300)
 if (abs(mo)/(e-s)>sf) mo=(mo/mo)*sf*(e-s)

 --apply travel over segments
 local j=0.5
 for i=s,e do
  axis[i]=mo*sin(j)
  j+=0.5/(e-s)
 end
end

function gen_seg_size(ax,ay)
 --generate x/y size for 
 -- section of segments
 
 --start/end segment
 local s=#ax+1
 local e=s+15+flr(rnd(40))
 if (e>q_len) e=q_len
 
 --more narrow parts as zones progress
 local p=0.25+(t_zone*0.033)
 local r=20

 --size (128-mo) 
 local mo=rnd(30)
 if (rnd(1)<0.75) mo=30+rnd(20)
 if (rnd(1)<p)    mo=50+rnd(r)
  
 --sudden change (50/50)
 local sc=rnd(1)<0.5
 
 --apply change to one axis only
 local axis1,axis2=ax,ay
 if (rnd(2)<1) axis1,axis2=ay,ax
 
 --gradual in/out
 local k=0.5
 if (rnd(1)<0.5) k=0.25
 
 --apply change over segments
 local j=0.5
 for i=s,e do
  axis1[i]=128-mo*sin(j)
  axis2[i]=128
  if (sc) axis1[i]=128-mo
  j+=(k/(e-s))
 end
end

function gen_seg_col(f,t,cs)
 --set segment colour for
 -- section of segments
 
 local j=1
 for i=f,t do
  s.c[i]=scm[cs][j]
  j+=1
  if (j==8) j=1
 end
end

function add_rect(i)
 local r={}
 r.x,r.y=t_x,t_y --relative pos
 r.osx=s.sx[i]   --orig. size x
 r.osy=s.sy[i]   --orig. size y
 r.sz=0.001      --size %
 r.sx=r.osx*r.sz --size x
 r.sy=r.osy*r.sz --size y
 r.c=s.c[i]      --colour
 r.sc=s.sc[i]    --score (bool)
 r.pos=i         --segment
 
 r.pt={}
 r.pt[1],r.pt[2],r.pt[3],r.pt[4]={},{},{},{}
 r.pt[1].x,r.pt[1].y=0,0
 r.pt[2].x,r.pt[2].y=0,0
 r.pt[3].x,r.pt[3].y=0,0
 r.pt[4].x,r.pt[4].y=0,0
 r.h=true
  
 add(rec,r)
end

function rotate(x,y,ox,oy,a)
	local sa=sin(a)
	local ca=cos(a)
	
	x-=ox
	y-=oy
	
	local rx=(ca*x)-(sa*y)+ox
	local ry=(sa*x)+(ca*y)+oy
	
	return rx,ry
end

function intersect(r,l)
 --r = rectangle, must be axis-aligned!
 --l = line, any rotation

 if (l.x1<r.x1 or l.x2<r.x1) return 4
 if (l.x1>r.x2 or l.x2>r.x2) return 2
 if (l.y1<r.y1 or l.y2<r.y1) return 1
 if (l.y1>r.y2 or l.y2>r.y2) return 3

 return 0
end

function mline(x1,y1,x2,y2,c)
 x1+=64
 y1+=64
 x2+=64
 y2+=64
 
 --completely off-sreen
 if (x1<0 and x2<0) return
 if (x1>127 and x2>127) return
 if (y1<0 and y2<0) return
 if (y1>127 and y2>127) return
 
 -- (pico8 is forgiving
 --  about drawing offscreen) 
 line(x1,y1,x2,y2,c)
end

function get_prev_rect(i)
 local l=i-1
 if (l<1) l=#rec
 if (l~=i and rec[l].sz>rec[i].sz) return l
 return false
end

function get_smallest_rect()
 local i,b,n=1,99,1
 for r in all(rec) do
  if (r.sz<b) b,n=r.sz,i
  i+=1
 end
 return n
end

function get_col_rect(s)
 local i,b,n=1,99,0
 for r in all(rec) do
  if (abs(s-r.sz)<b) b,n=abs(s-r.sz),i
  i+=1
 end
 if (n>0 and rec[n].sz>=s*0.5) return rec[n]
 
 return false
end

function get_hex(n)
 if (n==10) n="a"
 if (n==11) n="b"
 if (n==12) n="c"
 if (n==13) n="d"
 if (n==14) n="e"
 if (n==15) n="f"

 return n
end

function pad_score(s)
 local l=#(""..s)
 local r=""..s
 
 if (l==1) r="    "..s
 if (l==2) r="   "..s
 if (l==3) r="  "..s
 if (l==4) r=" "..s
 
 return r
end

function dp(t)
 local w=flr(t)
 local d=flr((t-w)*100)
 if (#(""..d)==1) d="0"..d
 
 if (#(""..w)==1) w="  "..w
 if (#(""..w)==2) w=" "..w
  
 return w.."."..d
end

function printc(s,x,y,c,o)
 local sx,sy
 local	len=#s
	
	--align centre
	local xp=x-len*2
	if (xp<2) xp=2
	  	
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

function copy(o)
 local c
 if type(o)=='table' then
  c={}
  for k,v in pairs(o) do
   c[k]=copy(v)
  end
 else
  c=o
 end
 return c
end

function wait(d)
 cls() 
 for i=1,d do
  flip()
 end
end
__gfx__
0000000000000000000000000000000000000000000000008800000080000000b0b00000bbbb000033300000b3b0000003000000099000000000000000000000
0000000000000000000000000000000000000000000000008800000080000000bbb0000000000000333000003b300000333000009aa900000000000000000000
0070070000220220020022000222002200222022200000008800000080000000b0b00000bbbb000033300000b3b000003b3000009aa900000000000000000000
0007700003003003030300303000030030300003000000000000000000000000000000000000000033300000003000003b300000099000000000000000000000
000770000400400404040040044004004044000400000000000000000000000000000000bbbb0000333000000030000033300000000000000000000000000000
00700700050050050505005000050500505000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000060060060606006066600066006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111115666666666666666666666666666666666666666000000000000000000000000666666666666666666666666000000000000000000000000
15555555555111551d6d6d6d6d6d6d6d6d6d6d666d6d6d6d6d6d6d6d0000000000000000000000006d6d6d6d6d6d6d6d6d6d6d6d000000000000000000000000
11111111111155ee11ddddddddddddddddddddd6dddddddddddddddd000000000000000000000000dddddddddddddddddddddddd000000000000000000000000
152222225115eeee1ddddddddddddddddddddd66dddd5ddddddd5ddd000000000000000000000000dddddddddddddddddddddddd000000000000000000000000
11111111115eeeee11ddddddddddddddddddddd6ddd565ddddd565dd000000000000000000000000dddddddddd5dddddddddd555000000000000000000000000
15222225115eeeee1ddddddddddddddddddddd66dddd5ddddddd5ddd000000000000000000000000dddddd5dd5dddddddd555ddd000000000000000000000000
1111111115eeeeee11ddddddddddddddddddddd6dddddddddddd4ddd000000000000000000000000ddddd5dd5dddddddd55ddddd000000000000000000000000
1522225115eeeeee1ddddddddddddddddddddd66dddddddddddddddd000000000000000000000000dddd5dd5dd5ddddddddddddd000000000000000000000000
111111115eeeeeee11ddddddddddddddddddddd6dddddddddddddddddddddddddddddddddddddddddddddd5dd5ddddddddd555ddddd5dddd0000000000000000
152225115eeeeeee1ddddddddddddddddddddd66dddddddddddddddddddddddddddddddddddddddddddddddd5ddddddddd50005dddd55ddd0000000000000000
11111115eeeeeeee11ddddddddddddddddddddd6dddd5ddddddd5ddddddddddddddddddddddddddddddd5dddddddddddd500005dd55d5ddd0000000000000000
15225115eeeeeeee1ddddddddddddddddddddd66ddd565ddddd565dd5555555555355555d5555555ddd5dddddddddddddd5005ddddddd5dd0000000000000000
1111115eeeeeeeee11ddddddddddddddddddddd6dddd5ddddddd5ddddd53dddddd5553dddd53553dddddddddddddddddddd55ddddddddddd0000000000000000
1525115eeeeeeeee1ddddddddddddddddddddd66dddddddddddd4dddddddddddddd3ddddddd5d3dddddddddddddddddddddddddddddddddd0000000000000000
111115eeeeeeeeee11d1d1d1d1d1d1d1d1d1d1d6d1d1d1d1d1d141d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d10000000000000000
155115eeeeeeeeee5111111111111111111111151111111111111111111111111111111111111111111111111111111111111111111111110000000000000000
11115eeeeeeeeeee0aaa00000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15115eeeeeeeeeeeaaa0000000000aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1115eeeeeeeeeeeeaa00000aa00000aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1115eeeeeeeeeeeea00000aaaa00000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
115eeeeeeeeeeeee00000aaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55eeeeeeeeeeeeee0000aaa00aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee000aaa0000aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee00aaa000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55
1155eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee555555555555555555555555555555555555555555555eeeeeeeeeeeeee5511
111155eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee51111111111111111111111111111111111111111111115eeeeeeeeeee551111
51111155eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee51000000000000000000000000000000000000000000015eeeeeeeee55111115
1551111155eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5110000000000000000000000000000000000000000000115eeeeee5511111551
11155111115555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5110000000000000000000000000000000000000000000115eee5551111155111
55111551111111555555555555555555555555555555555555555555555555511111111111111111111111111111111111111111111111115551111115511155
11551111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111115511
5111111d51d51d511000000000000000000000111111111111111111111111111000000000000000000000000000001111111111111100000115151515111115
11111111111111111000000000000000000000115151155555555555115333351000000000000000000000000000001533335151115100000111111111111111
11111100000000001000000000000000000000113131111111111111111111111000000000000000000000000000001111111151215100000100000000011111
11111102202202201000000000000000000000113331112121212121115333351000000000000000000000000000001533335151115100000102020202011111
11111102202202201000000000000000000000113131111111111111111111111000000000000000000000000000001111111151215100000102020202011111
11111102202202201000000000000000000000115151155555555555115333351000000000000000000000000000001533335151115100000102020202011111
11111100000000001000000000000000000000111111111111111111111111111000000000000000000000000000001111111111111100000100000000011111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
eeee0000000000000000000000ee000000000000000000000000000000000000000ee0000000000000000000002200220000000000000e000000000000000000
0000eee00000000000000000ee000000000000000000000000000000000000000ee000000000000000000000020000202000000000000e000000000000000000
000000000000000000000000000000000000000000000000000000000000000ee000000000000000000000022000002020000000000000e00000000000000000
000000ddddddddddd000ddd0000ddd000dddddddddd0000dddddddd0000000e00000000000000000000002200000020002000000000000e00000000000000000
00000dd666666666dd0dd6dd00dd6dd0dd66666666dd00dd666666dd0000ee0000000000000000000000200000000200002000000000000e0000000000000000
00000d66777777766d0d666d00d666d0d6677777766d00d66777766d00ee0000000000000000000000220000000002000020000000000000e000000000000000
00000dd666777666dd0d676d00d676d0d6776666776d00d6776666dd0e000000000000000000000022000000000002000002000000000000e000000000000000
000000ddd66766ddd00d676d00d676d0d6766dd6676d00d6766dddd0e00000000000000000000022000000000000020000020000000000000e00000000000000
000000000d676d00000d676d00d676d0d676d00d676d00d676d000000000000000000000000002000000000000000e0000002000000000000e00000000000000
000000000d676d00000d676d00d676d0d676d00d676d00d676d000000000000000000000000220000000000000022e20000002000000000000e0000000000000
000000000d676d00000d676d00d676d0d676d00d676d00d676d000000000000000000000022000000000000002200e200000020000000000000e000000000000
000000000d676d00000d676d00d676d0d6766dd66766d0d6766dd0000000000000000000200000000000000220000e020000002000000000000e000000000000
000000000d676d00000d676d00d676d0d67766667776d0d67766dd000000000000000022000000000000002000000e0200000020000000000000e00000000000
000000000d676d00000d676d00d676d0d67777777776d0d677766d0000000000000022000000000000002200000ee0e020000002000000000000e00000000000
000000000d676d00000d676d00d676d0d67766666776d0d67766dd00000000000002000000000000002200000ee00ee0020000002000000000000e0000000000
000000000d676d00000d676d00d676d0d6766ddd6676d0d6766dd00200000000022000000000000002000000e00efeee020000002000000000000e0000000000
000000000d676d00000d676d00d676d0d676d000d676d0d676d00000222200022000000000000002200000ee0eeee00e0020000002000000000000e000000000
000000000d676d00000d676d00d676d0d676d000d676d0d676d000000000222220000000000002200000ee0effe00000e0020000020000000000000e00000000
000000000d676d00000d676d00d676d0d676d000d676d0d676d0000000000002022222200002200000eeeeff000f000efe020000002000000000000e00000000
000000000d676d00000d6766dd6676d0d6766ddd6676d0d6766dddd0000000020000000222eeeeeeeeee000e0000f00efe0020000002000000000000e0000000
000000000d676d00000d6776666776d0d67766666776d0d6776666dd00000000200000000002000000e0000e0000f0ef0fe020000002000000000000e0000000
000000000d666d00000d6677777766d0d66777777766d0d66777766d00000000200000000002000000e00000e0000e0000fe020000002000000000000e000000
000000000dd6dd00000dd66666666dd0dd666666666dd0dd666666dd000000000200000000002000000e00000e001f0000fe0020000020000000000000e00000
0000000000ddd0000000dddddddddd000ddddddddddd000dddddddd0000000000020000000002000000e00000e00f100ee0ee020000002000000000000e00000
000000000000000000000000000000000000000000000000000000000000000000200000000002000000e00000e0f0ee0000e0020000002000000000000e0000
000000000000000000000000000000e000000000000000000000e00000000000000200000000555500000e0000efee0000000e002000002000000000000e0000
0000000000000000000000000000000e000000000000000000000e0000000000000205555555555000000e00000f0000000ee0e020000002000000000000e000
0000000000000000000000000000000e0000000000000000000000e00000055555555ddd55555552000000e0000e00000ee0000ee20000020000000000000e00
00000000000000000000000000000000e0000000000000000000005555555ddddddd5555dd5dd5020000000e00e00000e00000000e0000002000000000000e00
00000000000000000000000000000000e000000000000005555555ddddddddddd555ddddd5dd50002000000e00e000ee0000000000e2000002000000000000e0
000000000000000000000000000000000e0000055555555ddddddd666dddd5555dddddd55dd5000020000000e0e0ee00000000002200220002000000000000e0
000000000000000000000000000000005555555dddddddddd6666dddd5555ddddd66dd5dddd5000002000000eeee00000000002200000022002000000000000e
00000000000000000000000055555555ddddddddd666666666dddd555dddd66666ddd5d66d500000020000000e0000000000220000000000222000000000000e
000000000000000000000055555555555ddddddddddddddddd5555dddd666d666dd55d66d5000000002000000e00000000220000000000000022200000000000
00000000000000000066000055ddd766655555555555dd5555ddddd666655666dd5dd66dd500000000020000e000000002000000000000000220022200000000
00000000000000000600000000557666766767676ddd55ddddd66666555666ddd5d666dd5200000000020000e000000220000000000000022000000022220000
0000000000000000d0000000000056676676767776d5dd5dd6666655d6666dd55d6666d50200000000002000e000022000000000000000200000000000002220
0000000000000000600000000000055667676777765d66d5d66665d66666dd5dd6666dd5002000000000200e0002200000000000000022000000000000000002
f00000000000000d000000000000000566767777656666665d66666666ddd5d66d66dd50000200000000020e0220000000000000002200000000000000000000
f000000000000005000000000000000055667766566dddd665d666666dd55d665666d50000020000000002e22000000000000000020000000000000000000000
0f000000000000d00000090000000000005666d566d9aa7d665d6666dd5dd665d66dd50000002000000000e0000000000000000220000000000000000000000e
00f000000000005000000000000000000005dd5d6d9aa777d6d5dd6dd5d6665d66dd5000000020000000002000000000000002200000000000000000000000e0
00f10000000005000000000000000000000055d66daaaa7ad66d5dd55d6665d66dd500000000020000000020000000000002200000000000000000000000ee00
001f0000000500000000000000000900a00005d6ad9aaaaad66dd55dd6665d66ddd5000000000020000002000000000000200000000000000000000000ee0000
000f0000550000000000000000000000000000ad6d99aaa9d66d55dd6665d666dd5000000000002000000200000000002200000000000000000000000e000000
0000f000000000000000000000000000000000056ada999d66d5d5dd665d666dd500000000000002000002000000002200000000000000000000000ee0000000
00000f000000000000000000000000008000a0a0a66ddad6665dd5d666d666ddd5000000000000020000020000000200000000000000000000000ee000000000
00000f0000000000000000000a000000000000000566a6666566d5d666666ddd50e0000000000000200020000002200000000000000000000000e00000000000
000000f0000000000000000000000a0000900090a0ad666d567765d66666ddd500e00000000000000200200002200000000000000000000000ee000000000000
000000f000000000000000000000000a0a090a000005ddd5677775d66666ddd5000e00000000000002002000200000000000000000000000ee00000000000000
0000000f00000008000000000000000000000000a0005d5d677775d6666ddd50000e0000000000000020202200000000000000000000000e0000000000000000
00000000f0000000000000080009000090a00a00000005d6777765d666ddd5000000e0000000000000222200000000000000000000000ee00000000000000000
00000000f1000000000000000000008000000000000005d6777675dd6dddd50000000e0000000000000200000000000000000000000ee0000000000000000000
000000001f00000000000000000000000009000090000056776765dddddd500000000e000000000000020000000000000000000000e000000000000000000000
000000000f00000000000000000a0009000000a000000056667675dddddd5000000000e000000000000200000000000000000000ee0000000000000000000000
0000000000f0000000000000800000000a00000000000005676765ddddd500000000000e000000000020000000000000000000ee000000000000000000000000
0000000000f1000000000000000000900000800a00000005667665dddd5000000000000e0000000000200000000000000000ee00000000000000000000000000
00000000001f000000090000000000000000000000000000566675dddd50000000000000e00000000020000000000000000e0000000000000000000000000000
000000000000f00000000000000000000000000000000000566765ddd500000000000000e000000000200000000000000ee00000000000000000000000000000
000000000000f0000000000000090000090a000000a00000057665dd500000000000000000000000000000000000000000000000000000000000000000000000
0000000000000f000000000000000000000000000000000005665ddd5000000000ddddddd000ddd00ddd00dd000ddd00dd000ddd00dddddddd00dddddd000000
0000000000000f000000000000000080000000000000000005665dd50000000000d666666d00d6d00d6d00dd000d6d00dd000d6d00d666666d00d66666d00000
00000000000000f10000000000000000000000000000000000575d50000000000d6666666d0d6d00d6d00d6d00d6d00d6d00d6d00d666666d00d666666d00000
000000000000001f00000000000000000000000000000000005d5d50000000000d6dddd6d00d6d00d6d00d6d00d6d00d6d00d6d00d6dddddd00d6dddd6d00000
000000000000000f000800000000000000000800000090000005550000000000d6d000d6d0d6d00d6d00d66d0d6d00d66d0d6d00d6d0000000d6d000d6d00000
0000000000000000f0000000000000000000000000000000000550e000000000d6dddd6d00d6d00d6d00d66d0d6d00d66d0d6d00d6ddd00000d6dddd6d00000e
0000000000000000f1000000008000000000000000000000000050e00000000d666666d00d6d00d6d00d6d66d6d00d6d66d6d00d6666d0000d666666d0000ee0
00000000000000001f0000000000000000550555000000000000500e0000000d6666dd000d6d00d6d00d6d66d6d00d6d66d6d00d666d00000d6666dd000ee000
000000000000000000f0000000000000500000005d5d000006600000e00000d6666d0000d6d00d6d00d6d0d66d00d6d0d66d00d6dddd0000d6666d0000e00000
000000000000000000f00000000000050000000000005d66d0000000e00000d6ddd6d000d6d0d66d00d6d0d66d00d6d0d66d00d6d0000000d6ddd6d0ee000000
0000000000000000000f0000000000000000000000000000000000000e000d6d00d6d00d66dd66d00d6d00d6d00d6d00d6d00d6dddddd00d6d00d6d000000000
0000000000000000000f0000000000000000000000000000000000000e000d6d000d6d0d666666d00d6d00d6d00d6d00d6d00d666666d00d6d000d6d00000000
00000000000000000000f1000000000000000000000000000000000000e0d6d0000d6d00d666dd00d6d00d6d00d6d00d6d00d666666d00d6d0000d6d00000000
000000000000000000001f00000000000000000000000000000000000000ddd00000dd000ddd0000ddd00ddd00ddd00ddd00dddddddd00ddd00000dd00000000
000000000000000000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0555055505055500000000f0000000000000000000000000000000000000e00000000000000000e0000000000000000000000000000000e00000000000000000
000d0d0d0d0d0d00000000f1000000000000000000000000000000000000e0000000000000000e000000000000000000000000000000ee000000000000000000
06660606060666000000001f0000000000090000000000000000000000000e000000000000000e0000000000000000000000000000ee00000000000000000000
0d000d0d0d0d0d0000000000f0000000000000000000000000000000000000e00000000000000e000000000000000000000000000e0000000000000000000000
055505550505550000000000f0000000000000000000000000000000000000e00000000000000e0000000000000000000000000ee00000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1215131313131313131313131313151400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2225232323232323232323232323252400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
32321215131a1b13131313131514333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
32322225232a2b23232323232624333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232121513131313131313131614333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
323222252323232323232d232524333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1216131313131313131313131313151400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2225232323232327232323232323252400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1215131313131313131313131313161400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22252323232328272923232c2323252400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333121513131313131313131614323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333222623232323232323232524323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33331215131313131c1313131514323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333222523232323232323232524323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1215131313131313131313131313151400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2225232323232323232323232323252400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010700003c623296201c6201a61000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600003e614306112e611206112b615003001920014200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01120000143731435314333164411525114561134611226111561104610f2610e5510d4410c2310b5210a11100000000000000000000000000000000000000000000000000000000000000000000000000000000
01120000161411515114161131611216111161101610f1610e1510d1410c1310b1210a11100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200000c1740d1710e1710f16110161111611215113151141511514116141143431432314313143031430300000000000000000000000000000000000000000000000000000000000000000000000000000000
010600082b0310c5512b0510c5552b0510c5512b0510c535000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000210000000000000
010200081802118131302413035130451303411823118121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011600002213021131201311f1311e2311d1311c2311b1311a231192311823117131162311513114231131311224111231102410f2310e2410d1310c2410b1310a24107241062410524104241032410224101241
011000040045500455024550345500000000000000000000000000000000000000000000000000000000000000000000000000000000000002100000000000000000000000000000000000000000000000000000
011000040745507455094550a45500000000000000000000000000000000000000000000000000000000000000000000000000000000000002100000000000000000000000000000000000000000000000000000
011000040245502455044550545500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000040545505455074550845500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002421424210242212422024231242302424124240242512425024250242412423124221242112421522224222312225122250222502223122211222152022420231202512025020250202312021120215
011000001f2141f2211f2201f2311f2411f2401f2511f2501f2501f2501f2501f2501f2501f2501f2501f2501f2411f2401f2401f2401f2311f2301f2301f2301f2211f2201f2201f2201f2111f2101f2101f215
011000002221422210222212222022231222302224122240222512225022250222412223122221222112221521224212312125121250212502123121211212151f2241f2311f2511f2501f2501f2311f2111f215
011000001d2141d2211d2201d2311d2411d2401d2511d2501d2501d2501d2501d2501d2501d2501d2501d2501d2411d2401d2401d2401d2311d2301d2301d2301d2211d2201d2201d2201d2111d2101d2101d215
01100000202142021020221202202023120230202412024020251202502025020241202312022120210202151f2241f2311f2511f2501f2501f2311f2111f2151d2241d2311d2511d2501d2501d2311d2111d215
011000001821418221182201823118241182401825118250182501825018250182411823118221182101821516224162311625116250162501623116211162151b2241b2311b2511b2501b2501b2311b2111b215
011000001821418221182201823118241182401825118250182501825018250182501825018250182501825018241182401824018240182311823018230182301822118220182201822018211182101821018215
011000000e6250e6251a6451764515635136250e625000000e6151a6350e6250e6450e6351a6250e6150e61518173181231315313123181731812313153131231817318123131531312318173181231315313123
011000000e6250e6251a6451764515635136250e625000000e6151a6350e6250e6450e6351a6250e6150e6150e6250e6251a6451764515635136250e625000000e6151a6350e6250e6450e6351a6250e6150e615
01100000000001c3000c3001800018300183000c3000000018300183000c3001800018300183000c3000000018143181231315313123181531812313153131231816318123131531312318173181231315313123
011000000000000000000000000000000000000000000000000000000000000000000000000000000002d2113a2213822137211352113421132211302112f2112d2112b211292112821126211242112321121211
011000001813418141181511815018150181501815018150181501815018150181411813118121181111811516134161411615016150161501613116111161151411414131141501415014150141311411114115
01100000131341314113151131501315013150131501315013150131501315013150131501315013150131313c4103742033420304202b32027320243201f3201b22018220132200f2200c130071300313000135
011000001613416141161511615016150161501615016150161501615016150161411613116121161111611515134151411515115150151501513115111151151313413141131511315013150131311311113115
01100000111341114111151111501115011150111501115011150111501115011150111501115011150111313841035420304202c4202932024320203201d3201822014220112200c22008130051300013508300
011000001413414141141511415014150141501415014150141501415014150141411413114121141101411513134131411315113150131501313113111131151113411141111511115011150111311111111115
011000000c1340c1410c1510c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1410c1310c1210c1150a1340a1510a1500a1500f1500f1500f1500f141
011000000c1340c1410c1510c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c150
0110000018f3418f4118f5118f5018f5018f5018f5018f5018f5018f5018f5018f4118f3118f2118f1118f1516f3416f4116f5016f5016f5016f3116f1116f1514f1414f3114f5014f5014f5014f3114f1114f15
0110000013f3413f3013f4113f4013f5013f5013f5013f5013f5013f5013f5013f5013f5013f5013f5013f5013f4113f4013f4013f4013f3113f3013f3013f3013f2113f2013f2013f2013f1113f1013f1013f15
0110000016f3416f4116f5116f5016f5016f5016f5016f5016f5016f5016f5016f4116f3116f2116f1116f1515f3415f4115f5115f5015f5015f3115f1115f1513f3413f4113f5113f5013f5013f3113f1113f15
0110000011f3411f3011f4111f4011f5011f5011f5011f5011f5011f5011f5011f5011f5011f5011f5011f5011f4111f4011f4011f4011f3111f3011f3011f3011f2111f2011f2011f2011f1111f1011f1011f15
0110000014f3414f4114f5114f5014f5014f5014f5014f5014f5014f5014f5014f4114f3114f2114f1014f1513f3413f4113f5113f5013f5013f3113f1113f1511f3411f4111f5111f5011f5011f3111f1111f15
011000000cf440cf410cf510cf500cf500cf500cf500cf500cf410cf400cf400cf400cf400cf400cf400cf400cf310cf300cf300cf300cf300cf300cf210cf200af400af510af500af500af500af500af500af41
011000000cf400cf510cf500cf500cf500cf500cf500cf500cf500cf500cf500cf500cf500cf500cf500cf500cf410cf400cf400cf400cf400cf400cf400cf400cf310cf300cf300cf300cf300cf300cf300cf35
011000000c236182560c256182350c236182360c236182350c226182260c226182250c216182160c216182150a236162560a256162350a216162160a216162150823614256082561423508216142160821614215
01100000072361325607256132350723613236072361323516426224361643622425164162241616416224151441620426144262041514416204161441620415134161f426134261f415134161f416134161f415
011000000a236162560a256162350a236162360a236162350a226162260a226162250a216162160a2161621509236152560925615235092161521609216152150723613256072561323507216132160721613215
0110000005236112560525611235052361123605236112351442620436144362042514426204261442620425134161f426134261f415134161f416134161f415114161d426114261d415114161d416114161d415
011000000823614256082561423508236142360823614235082261422608226142250821614216082161421507236132560725613235072161321607216132150523611256052561123505216112160521611215
01100000002360c256002560c235002360c236002360c235002260c226002260c225002160c216002160c2150a236162560a256162350a216162160a216162150f2361b2560f2561b2350f2161b2160f2161b215
011000000c236182560c256182350c236182360c236182350c226182360c236182250c216182160c216182150c216182260c226182150c216182160c216182150c216182160c216182150c216182160c21618215
011000000e6250e6251a6451764515635136250e625000000e6151a6350e6250e6450e6351a6250e6150e6150e6250e6251a6451764515635136250e625000000e6150e6350e6350e6450e6351f0730e6150e615
011000000c1400c1400c1400c1400c1400c1400c1400c1400c1310c1300c1300c1300c1300c1300c1300c1300c1210c1200c1200c1200c1200c1200c1200c1200c1110c1100c1100c1100c1100c1100c1100c115
011000000cf200cf200cf200cf200cf200cf200cf200cf200cf200cf200cf200cf200cf200cf200cf200cf200cf110cf100cf100cf100cf100cf100cf100cf100cf110cf100cf100cf100cf100cf100cf100cf15
010e08203cf003bf003ef0039f0028f1037f001df1037f0034f100ff201af103bf102af102ff103ef2016f1034f101ef1035f2015f100df103bf103cf1039f103ef1037f101cf2038f1034f1015f2016f103bf10
0110000000000000000000000000000000000000000000000000000000000000000000000000000000016f1034f101ef1035f2015f100df103bf103cf1039f103ef1037f101cf2038f1034f1015f2016f103bf10
0110000000000000000000000000000000000000000000000000000000000000000000000000000000039f2034f3037f3035f3039f3034f303bf303cf3039f303ef4037f4034f4037f4034f4015f403cf403bf40
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000015008670086700865008650086300863008610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011100080304002151022500235002450025300212002010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000
010e082034f100ff301af303bf302af302ff303ef3016f3034f301ef3035f3015f300df303bf303cf3039f1000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00012105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000
010b00022105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000
010b00062105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000
011000200745007450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000
__music__
00 09 31 43 44
00 0a 18 43 44
00 0a 42 17 44
00 0a 18 43 44
00 0a 42 17 44
00 0a 0e 43 44
00 0a 0f 43 44
00 0b 10 43 44
00 0c 11 43 44
00 0d 12 43 44
00 0d 13 43 44
00 0a 14 43 44
00 0a 42 17 44
01 0a 0e 16 44
00 0a 0f 16 44
00 0b 10 16 44
00 0c 11 16 44
00 0d 12 16 44
00 0d 13 2e 44
00 0a 14 16 44
00 0a 42 15 44
00 0a 19 16 44
00 0a 1a 16 44
00 0b 1b 16 44
00 0c 1c 16 44
00 0d 1d 16 44
00 0d 1e 2e 44
00 0a 1f 16 44
00 0a 2f 15 44
00 0a 18 16 44
00 0a 42 15 44
00 0a 32 16 44
00 0a 42 15 44
00 0a 20 16 44
00 0a 21 16 44
00 0b 22 16 44
00 0c 23 16 44
00 0d 24 16 44
00 0d 25 2e 44
00 0a 26 16 44
00 0a 30 15 44
00 0a 27 16 44
00 0a 28 16 44
00 0b 29 16 44
00 0c 2a 16 44
00 0d 2b 16 44
00 0d 2c 2e 44
00 0a 2d 16 44
02 0a 42 15 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
