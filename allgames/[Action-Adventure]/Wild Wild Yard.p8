pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
local dr={1,0,0,1,-1,0,0,-1}

start_scraps=0
start_inv={}

function _init()
 
 t=0
 logs={}
 ents={}
 
 lp=16
 wfr=0
 scx=0

 init_menu()
 --init_game()
 --init_credits()
 
end

function setup_hero(x)
 hero=mke(60,x,108)
 hero.dr=dr_hero
 hero.flx=true 
 hero.cc=32
 hero.pdr=function(e,x,y)
  if fget(e.fr,0) then y+=1 end
  spr(166,x,y+4)
 end
end

function init_credits()

 music(3)
 cfd=nil
 t=0
 ents={}
 
 setup_hero(60)
 inventory={2}
 body=60
 suit=true 
 
 _update=function()
  t+=1
  if t==100 and fail<8 then
   body=3
   remove_suit()
   sfx(5)
  elseif t==280 and fail<3 then
   inventory={}
   throw_cloth(8,2)
   sfx(5)
  end
 
 

  hero.x=60+cos(t/220)*12
  scx+=1
  wfr+=.4-sin(t/220)*.25
  hero.fr=body+wfr%4
 
  
  foreach(ents,upe)
  
  if t>16 and btnp(4) or btnp(5) then
   init_menu()
   music(-1)
  end
  
  
 end 
 _draw=function()
  
  draw_scene()
  
  local str="congratulations"
  
  for i=1,#str do
   local x=12+i*6
   local y=32.5+cos(i/8+t/32)*3
   local c=hero.cc and max((hero.cc+i-16)/32,0) or 0
   x+=cos(c)*c*64
   y+=sin(c)*c*64
   
   circfill(x+1,y+2,4,7)
   print(sub(str,i,i),x,y,8+(i+t/4)%8)
  
  end
  
  if t>40 then
   local str="you died "..fail.." time(s)"
   print(str,64-#str*2,58,7)
  end
  
  
 end
 
end

function draw_scene()
 cls(1)
 clip(8,8,112,112)
 rectfill(8,8,119,119,12)
 
 
 for i=0,1 do
  dx=(scx/2)%256+i*256-256
  map(32,22,dx,88,32,2)
 end
 for i=0,1 do
  dx=scx%256+i*256-256
  map(32,16,dx,72,32,6)
 end
 
 -- ray

 -- ents
 dp=1
 foreach(ents,dre)
end


function init_menu()
 ents={} 
 go=nil
 intro=true
 ray=nil
 tct=nil
 lp=16
 
 wfr=0
 
 m=mke(141,16,90)
 m.ww=24
 m.hh=24
 m.dr=function(e)
  if not ray then
   return
  end
  local cl=7+3*(t%2)
  for dx=0,3 do for dy=0,3 do
   local x=37+dx
   local y=96+dy
   line(x,y,x+32,y+14,cl)
  end end
 end
 
 setup_hero(120)
 
 _update=function() 
  t=t+1
  
  if not hero.dead then  
   if t%12==0 then
    sfx(27)
   end
	  hero.x-=1
	  wfr+=.25
	  hero.fr=60+wfr%4
	  if hero.x<64 then 
	   ray=0
	   sfx(18)
	   kl(hero)
	  end
	  return	
  elseif ray then  
	  ray+=1
	  if ray==40 then
	   ray=nil
	   tct=0
	  end
	 end
	 
	 if tct then
	  tct+=1
	  if tct==16 then music(2) end
	  if not go and btnp(5) then
	   go=0
	   music(-1)
	   sfx(19)
	  end	  
	  if go then
				go=go+1	
				
				if go==32 then
				 init_game()
				 music(0)
				 
				end 
	  end
	 end
 
  
 end
 
 _draw=function()
		draw_scene()
  
  -- ray
  if ray then
   local c=max(1-ray/40,0)
   local dx=((1-c)*10)
   local dy=(1-c)*14
   sspr(94,64,10,12,63+dx,102+dy,10*c,12*c)
  end
  
  -- title
  if tct then   
   local c=min((tct-8)/8,1)
			if c>0 then
	   for i=0,1 do
	    if tct>2 and i<2 then
	     local y=22+i*11
	     y+=(i*2-1)*(1-c)*16
	     line(0,y,127,y,7)
	    end   
	   end 
   end 
   
   function f()
	   for i=0,2 do
	    local y=min(tct*4-i*16,32)-16  
	    map(32+i*3,29,20+i*28,y,3+i/2,2)
	   end
   end
   aura(f,12,c<1 and 10 or 7 )
   
   if c==1 and t%12<8 and not go then
    print("press — to start",32,64,7)
   end
   print("2019 benjamin soule",44,114)
  end
  
  if go then
   
   fade(go/32)
   
  end
    
  
	 -- log
	 clip()
	 cursor(0,0,7)
	 for l in all(logs) do
	  print(l)
	 end  
  
 end

end

function aura(f,cl,fcl)
 apal(cl)
 camera(0,1)
 f()
 camera(1,0)
 f() 
 camera(0,-1)
 f()
 camera(-1,0)
 f() 
 camera()
 if fcl then
  apal(fcl)
 else
  pal()
 end
 f()
 pal()
end

function init_game()

 _update=upd_game
 _draw=dr_game

 -- clean
 intro=nil
 
 --
 scraps=start_scraps
 ents={}
 monsters={}
 inventory=start_inv
 pool={0,1,2}
 fail=0
 peace=0
 tiles={}
 lp=24
 tlp=lp
 dism=true
 --lp+=47*2
 hbx=0


 -- remocon
 rem={}
 local a={}
 for x=0,5 do for y=0,7 do
  add(a,{x=x*4,y=y*4})
 end end
 while #a>0 do
  local n=arand(a)
  del(a,n)
  add(rem,n)
 end
 
 -- paralax
 herbs={
  cx=0,my=16,y=96,w=32,h=4,
  mult=2
 }
 a={
  cx=0,my=20,y=64,w=32,h=4,
  mult=.25,col=13,mach=true
 }
 b={
  cx=0,my=20,y=90,w=32,h=4,
  mult=.4,
 } 
 c={
  cx=0,my=24,y=90,w=32,h=3,
  mult=.5
 } 
 paralax={a,b,c}
 
 --hero
	hero_spawn()
	
	--target
	tan=0
	target=mke(38)
 target.upd=function(e)
  e.vis=hasgun() and not grab
  local td=16
	 e.x=hero.x+cos(tan)*td
	 e.y=hero.y+sin(tan)*td 
 end
 
 --
 pop_scrap()
 
 -- dev
 --spawn_bomber()
 --spawn_crawler(33)
 
end



function hasgun()
 return has(0) or has(11)
end


function spawn_bomber()
 spos=get_spawn_pos(4)
 local e=mke(64)
 e.ww=24
 e.hh=16
 e.aws=1
 e.bomb=true
 mk_mons(e,20,5)
 pos(e,spos.x,spos.y)
 e.upd=function()
  local hdx=hmod(e.x+e.ww/2-hero.x)
  if e.bomb and (hdx>0 != e.flx) then
   e.flx= not e.flx
  end
 
  e.vx=e.bomb and .5 or 1
  if e.flx then
   e.vx*=-1
  end
  
  e.vy=cos(t/80)*.5
  if e.bomb and near(e,12) then
   e.bomb=false
		 local b=mke(48)
		 mk_mons(b,20,0)
		 pos(b,1+e.x/8,1+e.y/8)
		 b.spd=3
		 b.cdanger=100
		 run_bomb(b)
		 sfx(7)
		elseif not e.bomb and not near(e,96) then
		 e.bomb=true 
  end
 end
 
 e.pdr=function(e,x,y)
  if e.bomb then
   spr(48,x+10,y+10)
  end
 end 
 
end

function run_bomb(e)
 if mcol(e.px,e.py,1) then
  mset(e.px,e.py,e.fr)
  kl(e)
  sfx(11)
  hero.cshk=8
  pop_dirt(e.px*8+4,e.py*8+7,4)
 else
  slide(e,{1},function() run_bomb(e) end)
 end
 
 
end


function pop_scrap()
 if scraps==48 then
  return
 end

 spos = get_spawn_pos()
 local e=mke(56+rand(3))
 pos(e,spos.x,spos.y)
 
 e.float=true
 e.upd=function(e)
  e.aura=8+(t/2)%8
  if ecol(e) then
   e.y-=1
  end  
  if abcol(hero,e) then
   kl(e)   
   grab_scraps()
   pop_scrap()
  end
 end
 scr=e
end

function grab_scraps()
 scraps+=1
 hero.chappy=16
 tlp=ceil(4+scraps/4)*8
 sfx(6)
 
 if scraps==48 then
		success()
 end
end

function success()
 sfx(-1)
 for m in all(monsters) do
  kl(m)
 end
 for e in all(ents) do
  if e.shot then
   kl(e)
  end
 end
 hero.c=60
 

 function ending(e)
  if e.t==60 then
   hero.cfing=32
  end
  if e.t==92 then
   hero.cpress=40
   sfx(23)
   hero.cstill=120

  end
  
  if e.t==110 then
   hero.dr=supersize
   hero.t=0
  end
    
  if e.t==132 then
   hero.cfing=32
   hero.frev=true
  end
  
  local c=min((e.t-150)/32,1)
  if c>0 then cfd=c end
  if cfd==1 then
   init_credits()
  end

 end
 loop(ending)
 
end

function supersize(e,x,y)
	local c=1+e.t/4
	local dx=((1-c)*10)/2
	local dy=(1-c)*11
	sspr(94,64,10,12,x+dx,y+dy,10*c,12*c)
 
end



function loop(f,t,nxt)
 local e=mke(0)
 e.upd=f
 e.life=t
 e.nxt=nxt
 return e
end


function swarm(spf,n,t)
 local p = get_spawn_pos(4)
 local count=0
 local function f()  
  spf(count/n,p.x,p.y)
  count+=1
  if count<n then 
   wt(t,f)
  end  
 end 
 f()
end


function spawn_bee(c,x,y)
 
 local st=t
 
 local e=mke(49)
 pos(e,x,y) 
 mk_mons(e,2,2)
 e.aws=1
 e.upd=function()
  local s=e.flx and -1 or 1
  e.fr=49
  e.vy=cos(t/32+c)
  e.vx=s+sin(t/77+c)
  if (t-st)%400==300 then
   s=-s
   e.flx=s==-1
  end
  
  if near(e,32,48) and not e.cd and not hero.cbee then
   
   hero.cbee=8
			e.fr=51
			e.flx=hmod(hero.x-e.x)<0			
   function sting()
    sfx(4,nil,4,8)
	   moveto(e,hero.x,hero.y,-2)
	   e.twcv=function(c)
	    local c=abs(sin(c/2-.25))
	    return 1-c
	   end
	   e.cbusy=e.tws
	   e.cdanger=e.tws/2+2
	   e.cd=e.cbusy+80
   end
   warn(e,sting)   
  end  
 end


end

function warn(e,f,a,b,c)
 sfx(22)
 e.vx=0
 e.vy=0
 e.cbusy=32
 e.cfocus=32
 local chk=function ()
  if not e.dead then
   f(a,b,c)
  end
 end 
 
 wt(32,chk) 
end


function get_drop_pos(px)
 for py=0,15 do
  if mcol(px,py) then
   return py-1
  end
 end
 return 15
end

function get_spawn_pos(py)

 local a={}
 for px=0,lp-1 do 
 
  local ok=false
  for py=0,15 do
   if fmget(px,py,0) then ok=true end
  end
  

  local hdx=hmod(hero.x-px*8)
  if abs(hdx)>64 and ok then
   add(a,px)
  end
 end
 
 local px=arand(a)
 if not py then
  py=get_drop_pos(px)
 end
 return {x=px,y=py}
end

function spawn_crawler(fr)

 local e=mke(fr)
 mk_mons(e,6,3)
 
end

function arand(a)
 return a[1+rand(#a)]
end

function rand(n)
 return flr(rnd(n))
end




function mcol(x,y,a,b,c) 
 local al={a,b,c}
 for n in all(al) do
  local di=n%4
  x+=dr[di*2+1]
  y+=dr[di*2+2]
 end
 x=x%lp 
 if y>=16 then return true end
 return fget(mget(x,y),0)
end



function near(e,dx,dy)
 dx=dx or 48
 dy=dy or 128
 return abs(hmod(hero.x-e.x-e.ww/2))<dx and abs(hero.y-e.y-e.hh/2)<dy
end

function cend(a,b)
 local dx=(a.x+a.ww/2)-(b.x+b.ww/2)
 local dy=(a.y+a.hh/2)-(b.y+b.hh/2)
 return sqrt(dx*dx+dy*dy)
end

function bad_fire(from,nxt)
 if from.dead then
  return
 end

 sfx(20)
 local e=mke(35,from.x,from.y)
 local dx=hmod(hero.x-e.x)
 local dy=hero.y-e.y
 local an=atan2(dx,dy)
 impulse(e,an,1)
 e.phys=true
 e.wcol=function(h)
  kl(e)
 end
 e.upd=function()
  if fld then
   if cend(hero,e)<9 then
    sfx(13)
    kl(e)
    hero.cfld=8
   end
  elseif abcol(hero,e) then
   hit()
  end
 end 
 e.grad={8,10,7}
 e.life=80
 e.ww=4
 e.hh=4
 e.shot=true
 if nxt then 
  wt(16,nxt)
 end
 return e
end

function impulse(e,an,spd)
 e.vx=cos(an)*spd
 e.vy=sin(an)*spd
end


function ladyjump(e,nxt)

 sfx(21)
 local hpx=flr(hero.x/8)
 local dx=hmod(e.px-hpx)
 
 e.flx=dx>0
 e.px=hmod(hpx-dx)
 e.py=get_drop_pos(e.px)
 e.rot=0
	 
	function f()
	 e.jfr=nil
	 nxt()
	end
	 
 moveto(e,e.px*8,e.py*8,-3,f)
 e.jmp=32
 e.tws+=e.jmp
 e.cdanger=e.tws
 
 local fir=function()
  bad_fire(e)
 end
 
 for i=0,2 do
 
 	wt(e.tws/2+i*8-8,fir)

 end
 
end

function run_crawler(e)
 local ag=function() run_crawler(e) end
 local s=e.flx and -1 or 1
 
 -- check ground
 local fall=false
 local gdi=e.di-s
 if not mcol(e.px,e.py,gdi) then
  fall=true
  for i=0,3 do
   if mcol(e.px,e.py,i) then
    e.di=(i-1)%4
    e.rot=e.di
    fall=false
   end  
  end  
 end

 -- fall
 if fall then
  slide(e,{1},ag)
  return
 end
 
 -- action
 if near(e,48) and e.wlk>=6 then
  e.wlk=0
  local act=nil
	 if e.fr==33 then
	 	act=circ_fire
	 else
	 	act=ladyjump
	 	e.jfr=2
	 end  
  warn(e,act,e,ag) 
  return
 end

 -- move
 e.wlk+=1 
 local fdi=e.di+s-1 
 if mcol(e.px,e.py,fdi) then
  e.di=(e.di-s)%4
  wt(2,ag)
 else
  if mcol(e.px,e.py,fdi,fdi+s) then
   slide(e,{fdi},ag)
  else
   e.di=(e.di+s)%4
   slide(e,{fdi,fdi+s},ag)   
  end  
 end 
 if e.di then
  e.rot=e.di
 end
 
end


function circ_fire(e,nxt)
 for i=1,8 do
  local an=i/8
  local e=bad_fire(e)
  impulse(e,an,1)
 end
 wt(16,nxt)
end


function slide(e,adi,nxt)

 for di in all(adi) do
  di=di%4
  e.px=(e.px+dr[di*2+1])%lp
  e.py+=dr[di*2+2]
 end
 moveto(e,e.px*8,e.py*8,8/e.spd,nxt)
 --e.jmp=#adi>1 and 4 or 0
end




function pos(e,px,py)
 e.px=flr(px)
 e.py=flr(py)
 e.x=px*8
 e.y=py*8
end

function move(e,dx,dy,n,f)
 moveto(e,e.x+dx,e.y+dy,n,f)
end




function moveto(e,tx,ty,n,f)
 e.sx=e.x
 e.sy=e.y
 e.ex=tx
 e.ey=ty
 e.twc=0
 e.tws=n
 e.twf=f 
 if n<0 then
  local dx=hmod(e.ex-e.sx)
  local dy=e.ey-e.sy
  local dd=sqrt(dx^2+dy^2)
  e.tws=-dd/n
 end

end

function has(n)
 for it in all(inventory) do
  if it==n then
   return true
  end
 end
 return false
end

function mk_mons(e,hp,dif)
 add(monsters,e)
 e.hp=hp
 e.dif=dif

 -- crawlers
 if fget(e.fr,6) then
	 local p=get_spawn_pos()
	 pos(e,p.x,p.y)
	 e.di=0
	 e.spd=.5
	 e.rot=0
	 e.flx=rnd()<.5 
  e.flx=true
  run_crawler(e)
  
 end
 
end

function toggle_jp()
 jp=not jp
 
 if jp then
  sfx(15)
 else
  sfx(-1)
 end
 hero.we= jp and 0 or .25 
end

function retry()
 fail+=1
 kl(hero)	      
	hero_spawn() 
	peace=0
end


function upd_hero(e)
 
 if e.cstill then
	 e.vx=0
	 e.vy=0
  return
 end

 hgr=ecol(e,0,1)
 
 -- eq
 if e.vy<0 then
  e.pcol=pcol
 elseif not e.ceq and e.pcol==pcol then
	 e.pcol=eqcol
	 if ecol(e) then
	  e.pcol=pcol
	 end
 end 
 
 -- autoland
 if jp and (hgr or en<=0)then
  toggle_jp()
 end
 
 -- fade forcefield
 if e.cfld==1 then
  fld=nil
 end
 
 -- choose new item
 if e.hurt then
  if #pool==0 and e.churt==1 then
		  retry() 
	  end 
  if e.csel then
   if e.csel==1 then
			 add(inventory,’)
				del(pool,’)
				for i=0,1 do
				 local Œ=dit[’*3+i+2]
				 if Œ>0 then
				  add(pool,Œ)
				 end
				end				
	   retry()
   end
  elseif not e.churt then
  
	
    
  
	  if btnp(2) then
	   sel=(sel-1)%#pool
	   sfx(24)
	  elseif btnp(3) then
	   sel=(sel+1)%#pool
	   sfx(24)
	  end
	  if btnp(4) or btnp(5) then
	   ’=pool[1+sel]
	   e.csel=32
	   sfx(25)
	  end  
  end  

  
  return 
 end
 
 
 -- walk
 function hmov(n)
  e.vx=n*1.5
  e.flx=e.vx<0
  if hgr then 
   wfr = (wfr+.25*n)%4
	  if not btn(5) then
	   local k=.05
		  if n==-1 then
		   tan = min(tan+k,.5)
		  else
		   tan = max(tan-k,0)
		  end   
	  end
  end
  if jp and not btn(5) then
   tan = .25-n*.25
  end
  
 end
 
 if btn(0) then hmov(-1)
 elseif btn(1) then hmov(1)
 else
  e.vx=0
  wfr=0
 end
 
 -- boost jump
 if e.cjmp then
  if btn(4) then
   e.vy-=1*e.cjmp/16
  end
 end
 
 -- jump
 if btn(4) then
  
  if jump_ready then
   jump_ready=false
	  if hgr then	
	   e.pcol=pcol	  
		  e.vy=-3
		  sfx(5)
		  e.cjmp=6		  
	  elseif has(1) and en>1 then
	   toggle_jp()
	  end
  end
  --if btn(3) then hit() end
 else
  jump_ready=true
 end 
 
 -- climbdown
 if hgr and btnp(3) then
  e.pcol=pcol
  e.ceq=16
  e.vy=-1.5
  sfx(5)
 end
 
 
 if not hgr then 
  wfr= e.vy<0 and 2 or 3 
 end
 
 -- frame
 e.fr=suit and 60 or 3
 e.fr+=wfr
 
 -- jetpack
 e.float=false
 if jp then
  e.float=true
  if t%20==0 and not has(6) then
   en-=1
  end
  e.vy=0
	 function hmov(n)
	  e.vy=n*1.5
	 end
	 if btn(2) then hmov(-1)
	 elseif btn(3) then hmov(1) end
 end
 
 -- hero fire
 if btn(5) and not e.cd and not grab and hasgun() and en>0 then
  en-=1
  e.cd=6
  local fd=4
  local p=mke(54,e.x+cos(tan)*fd,e.y+sin(tan)*fd)
  impulse(p,tan,5)
  p.phys=true
  p.wcol=function()
   kl(p)
   if fget(ctl,5) then
    pop_dirt(p.x,p.y,1)
   end
   if fget(ctl,2) then
    hit_ctl(p.dmg)
   end
  end
  p.shot=true
  p.dmg=1
  p.ww=6
  p.hh=6
  if has(10) then
   en-=1
   p.dmg=3
   p.fr=112
   p.ww=6
   p.hh=6
   sfx(14)
  else
   sfx(1)
  end
 end
 
 -- reload
 if hgr and t%4==0 and not e.cd and en<pow*8then
  en+=1
  if e.vx!=0 then
   en+=2
   if en>pow*8 then en=pow*8 end
  end
 end
 
 -- fall
 if e.y>136 then
  suit=nil
  hit()
 end
 
 
 -- launch and grab
 if grab then
  if btnp(5) then
   launch()
  end 
 else
  for m in all(monsters) do
   if abcol(e,m) then
    if m.cdanger or e.ww>8 then
     hit()  
    else
    	kl(m)
    	grab=m
    	sfx(12)
    end    
    break
   end
  end
 end 
end

function hit_ctl(n)
 local k=ctlx..","..ctly
 local o=tiles[k]
 if not o then
  o={hp=16}
  tiles[k]=o
 end
 o.hp-=1
 drt=fget(ctl,5)
 plt=fget(ctl,1)
 if o.hp<=0 then
  local rep=drt and 59 or 0
  if plt then
   rep=43
  end
  mset(ctlx,ctly,rep)
 
 else
  if drt and o.hp<8 then
   mset(ctlx,ctly,plt and 37 or 26)
  end 
  local e=mke(ctl,ctlx*8,ctly*8+1)
  e.cbright=4
  e.life=4
 end
 
 
end

function hit()
 if hero.cinv and hero.y<132 then
  return
 end
 sfx(-1)

 
 sfx(10)
 hero.hurt=true
 hero.churt=40
 if jp then
  toggle_jp()
 end
 
 if not suit then
	 sel=0
	 hero.frict=.96
	 hero.phys=false 
	 hero.vy=min(hero.vy,-3)
 end
 _draw()
 frz=16
 
end
function hero_spawn()
 wfr=0
 suit=has(3)
 fld=has(8)
 pow=has(5) and 8 or 4
 en=pow*8
 
 hero=mke(3,96,80)
 hero.we=.25
 hero.phys=true
 hero.upd=upd_hero
 hero.pdr=pdr_hero
 hero.dr=dr_hero
 hero.cinv=80
 hero.cspawn=40
 hero.–w=-2
 hero.–x=1


 -- dismantle
 if has(7) and dism then
  dism=false
  local n=5
  function f()
   if n==0 or scraps==48 then
    return
   end
   grab_scraps()
   wt(16,f)
   n-=1
  end
  f()
 end
 
 -- clean
 for m in all(monsters) do
  kl(m)
 end
 
end


function launch()
 sfx(7)
 local g=grab
 grab=nil
 hero.cd=8
 local p=mke(g.fr,hero.x,hero.y-8)
 p.vx=hero.flx and -1 or 1
 p.vy=-1
 if btn(2) then
  p.vy-=4
 else
  p.vx*=6
 end 
 p.we=.25 
 p.phys=true
 p.crot=16
 p.rot=2
 p.wcol=function()
  kl(p)
  sfx(14)
  g.x=p.x
  g.y=p.y
  g.dead=false
  relocate(g)
  hero.cshkb=4
 end
 p.upd=function(e)
  
  if t%2==0 then
	  local sh=mke(e.fr,e.x,e.y)
	  sh.rot=e.rot
	  sh.life=7
	  sh.queue=true
	  sh.dp=0
  end
  for m in all(monsters) do
   if abcol(m,e) then
    discard(m)
    discard(e)
    sfx(14)
    return
   end
  end 
 end
end

function discard(e)
 kl(e)
 local p=mke(e.fr,e.x,e.y)
 
 if e.ww>8 then
  p.ww=e.ww
  p.hh=e.hh
 else
  p.crot=999
 end
 p.vx=rnd(3)-1
 p.vy=-2-rnd(2)
 p.we=.25
 p.blu=true
 p.upd=function(p)
  if p.y>128 then
   kl(p)
  end
 end

end



function relocate(e)

 if e.fr !=33 then
  discard(e)
  return
 end
 

 e.dead=false
 e.px=flr(e.x/8)
 e.py=flr(e.y/8)
 add(ents,e)
 add(monsters,e)
 
 e.wlk=0
 run_crawler(e)
 
end

function abcol(a,b)
 local dx=hmod(a.x+a.ww/2-b.x-b.ww/2)
 local dy=a.y+a.hh/2-b.y-b.hh/2 
 return abs(dx)<(a.ww+b.ww)/2 and abs(dy)<(a.hh+b.hh)/2
 
end


function pdr_hero(e,x,y)
 if has(1) then
  
  if jp then
   local r=1+t%3
   local s=e.flx and -1 or 1
	  for i=0,1 do for k=0,1 do
	   local px=x+i*4-s*2+1
	   local py=y+6
	   circfill(px,py,r-k,15-k*8)
	  end end  
  end
  spr(9,x,y,1,1,e.flx)
  
 end
end

function dr_hero(e,x,y)
 
 local n=e.flx and -1 or 1
 
 -- underwear
 if has(2) and not suit then
  spr(8,x,y,1,1,e.flx)
 end

 -- arms and head
 for i=0,2 do
  local cx=x+3
  local cy=y+2
 	local s=(1-i)*n
 	
 	-- head
 	if s==0 then
 	 local hfr=12
 	 if not gr then
 	  if e.vy<0 then
 	   hfr=11
 	  elseif e.vy>1 then
 	   hfr=13
 	  end
 	 end
 	 hfr=hero.hurt and 21 or hfr

 	 --
 	 local flx=e.flx
 	 if hasgun() then
 	  flx=hmod(hero.x-target.x)>0
 	 end
 	 local hx=x+n*0.5+.5
 	 local hy=y-5
 	 spr(hfr,hx,hy,1,1,flx)
 	
 	 --glasses
 	 if has(9) then
 	  spr(14,hx,hy+hfr-12,1,1,flx)
 	 end
 	
 	else
 	 -- arms
 	 local sx=cx+s*2.5+.5
 	 local dy=-sin(wfr/4)*2 
 	 
 	 if hasgun() and not grab then
 	   
 	   local dx=flr(cos(tan)*4)
 	   local dy=flr(sin(tan)*4)
 	   
 	   local cx+=dx
 	   local cy+=dy
 	   
 	   line(cx,cy,cx+dx,cy+dy,6)
 	   line(cx+1,cy+1,cx+dx+1,cy+dy+1,13)
 	  
 	 else
	   
	    
	   local cl=12-s*n*3
	   if grab then
	    line(sx,cy,sx,cy-4,cl)
	   else   
	    line(sx,cy,cx+s*4.5+.5,cy+dy,cl)
	   end
   end
  end
 end
 
 -- grab
 if grab then
  rspr(grab.fr,x,y-8,2)
 end
 
 -- fld
 if fld then
  local r=8+t%3
  if hero.cfld then
   r=16-e.cfld
  end
  
  circ(x+4,y+2,r,7+(t%2)*5)
 end
 
 
 
 
 

end


function pmov(e)
 
 if ecol(e) then
 
  if e==hero then
   while ecol(e) and e.y>0 do
    e.y-=1
   end
  else
   kl(e)
  end
  return
 end
 
 local vx=e.vx
 local vy=e.vy
 local col=nil

 -- x
 hcp=0
 e.x+=vx
 while ecol(e) do
  e.x-=sgn(vx)
  e.vx=0
  col=e.wcol
 end
 
 -- y
 hcp=1
 e.y+=vy
 while ecol(e) do
  e.y-=sgn(vy)
  e.vy=0
  col=e.wcol
 end

 if col then col() end
 ctl=nil
end


function ecol(e,dx,dy)
 local dx=dx or 0
 local dy=dy or 0
 local a={0,0,1,0,1,1,0,1}
 for i=0,3 do
  local x=e.x+dx+a[i*2+1]*(e.ww+e.–w-1)+e.–x
  local y=e.y+dy+a[i*2+2]*(e.hh+e.–h-1)+e.–y
  if e.pcol(x,y) then
   return true
  end
 end
 return false
end


function eqcol(x,y)
 if y<0 then return true end
 local px=flr((x/8)%lp)
 local py=flr(y/8) 
 return fmget(px,py,0) or ( fmget(px,py,1) and hcp==1)
end

function fmget(x,y,n)
 return fget(mget(x,y),n)
end

function mpcol(x,y)

 local px=flr((x/8)%lp)
 local py=flr(y/8) 
 if py>=15 then return true end
 return fmget(px,py,0)
end

function pcol(x,y)
 if y<0 then return true end
 local px=flr((x/8)%lp)
 local py=flr(y/8) 
 local tl=mget(px,py)
 if fget(tl,0) then
  ctl=tl
  ctlx=px
  ctly=py
  return true
 end
 return false
end


function mke(fr,x,y)
 local e={
  fr=fr or 0,
  x=x or 0,
  y=y or 0,
  vx=0,vy=0,frict=1,we=0,
  ww=8,hh=8,rot=0,t=0,
  wlk=0,aws=4,hdx=0,
  flx=false,vis=true,
  dp=1,pcol=pcol,
  –x=0,–y=0,–w=0,–h=0,
 }
 add(ents,e)
 return e
end

function upe(e)
 e.t+=1
 

 if e.upd and not e.cbusy then 
  e.upd(e)
 end
 

 e.vy+=e.we
 e.vx*=e.frict
 e.vy*=e.frict
 
 if e.ghost and not ecol(e) then
  e.ghost=false
  e.phys=true
 end
 
 if e.phys then
  pmov(e)
  
 else
  e.x+=e.vx
  e.y+=e.vy
 end
 
 -- check outside
 if e.shot then
  local hdx=hmod(hero.x-e.x)
  if abs(hdx)>72 or e.y<-8 or e.y>136 then
   kl(e)
  end
 end
 
 -- shoot monsters
 if e.dmg then
  for m in all(monsters) do
   if abcol(m,e) then
    kl(e)
    hit_mon(m,e.dmg)
    return
   end
  end
 end
 
 -- counters
 for v,n in pairs(e) do
  if sub(v,1,1)=="c" then
   n-=1
   if n<=0 then
    e[v]=nil
   else
    e[v]=n
   end
  end
 end 

 --  tweens
 if e.twc then
  local c=min(e.twc+1/e.tws,1)
  cc=e.twcv and e.twcv(c) or c
  e.x=e.sx+hmod(e.ex-e.sx)*cc
  e.y=e.sy+(e.ey-e.sy)*cc
  if e.jmp then   
   e.y+=sin(c/2)*e.jmp
  end  
  e.twc=c  
  if c==1 then
   e.twc=nil
   e.jmp=nil
   e.twcv=nil
   local f=e.twf
   if f then
    e.twf=nil
    f()
   end
  end
 end
 
 -- rotate
 if e.crot and t%2==0 then
  e.rot=(e.rot+1)%4
 end
 
 -- life
 if e.life then
  e.life-=1
  if e.life<16 and e.blk then
   e.vis=t%2==0
  end
  
  if e.life<=0 then
   kl(e)
   if e.nxt then
    local f=e.nxt
    e.nxt=nil
    f()
   end
  end
 end 
 
 
 -- modulo pos
 e.x= e.x%(lp*8) 
 e.hdx=hmod(e.x-hero.x)
 
 
 
end

function hit_mon(e,dmg)
 hero.cshk=2
 e.hp-=dmg
 e.cdmg=2
 if e.hp<=0 then
  discard(e)
  sfx(3)
 else
  sfx(2)
 end
end


function wt(t,f,a,b,c)
 local e=mke()
 e.life=t
 e.nxt=function() f(a,b,c) end
end

function kl(e)
 e.dead=true
 del(ents,e)
 del(monsters,e)
 if e.dif then
  peace+=e.dif
 end
end

function hmod(n)
 n+=lp*4
 n=n%(lp*8)
 n-=lp*4
 return n 
 
end

function dre(e)
 
 local x=e.x
 local y=e.y
 local fr=e.fr
 
 if fr==0 or not e.vis or e.dp!=dp then
  return
 end
 
 -- hero center
 if not intro then
  x=hero.x+hmod(x-hero.x)
 end
 -- jump fr
 if e.jfr then fr+=e.jfr end

 -- autowalk
 if fget(fr,1) and (t/e.aws)%2<1 then
  fr+=max(1,e.ww/8)
 end
 
 --
 if e.float then
  y+=.5+cos(t/32)*2
 end
 

 -- 1px jump
 if fget(fr,0) then
  y-=1 
 end
 
 -- aura
 if e.aura then 
  dr_aura(e,fr,x,y,e.aura) 
 end
 
 -- pal stuff
 if e.cdmg then
  local r=max(e.ww,e.hh)/2+6-e.cdmg*2
  local cl=8+e.cdmg
  circfill(x+e.ww/2,y+e.hh/2,r,cl)
  apal(7)
 end
 if e.grad then
  apal(e.grad[1+t%#e.grad])
 end
 if e.blu then
  spal(4)
 end 
 if e.cbright then
  for i=0,15 do
   pal(i,sget(64+i,8+e.cbright))
  end
 end
 if e.queue then
  apal(sget(64+e.life,13))
 end
 
 if not hero.hurt then
	 if e.cfocus then
	  spal(t%2)
	 end 
	 if e.cdanger and t%2==0 then
	  dr_aura(e,fr,x,y,8) 
	  --apal(8)
	 end
 end
  
 
 --
 if e.pdr then e.pdr(e,x,y) end
 
 if e.rot>0 then
  rspr(fr,x,y,e.rot,e.flx)
 elseif e.ssx then
  sspr(e.ssx,e.ssy,e.ww,e.hh,x,y)
 else   
  spr(fr,x,y,e.ww/8,e.hh/8,e.flx)
 end
 if e.dr then e.dr(e,x,y) end
 pal()
 
end

function dr_aura(e,fr,x,y,cl)
 apal(cl)
 for i=0,3 do
  spr(fr,x+dr[i*2+1],y+dr[i*2+2],1,1,e.flx)
 end 
 pal()
end

function pop_dirt(x,y,n)
 for i=1,n do
  local e=dirt(x,y)
  impulse(e,rnd(.5),3)
  e.frict=.95
  e.life=80+rand(80)
 end
 
end

function dirt(x,y)
 local e=mke(23)
 local a={
  56,8,4,4,
  60,8,2,3,
  60,10,2,2,
  62,10,2,2,
 }
 local n=rand(4)*4
 e.ssx=a[n+1]
 e.ssy=a[n+2]
 e.ww=a[n+3]
 e.hh=a[n+4]
 e.x=x
 e.y=y
 e.we=.1+rnd(.2)
 e.ghost=true
 return e
end


function apal(n)
 for i=0,15 do pal(i,n) end
end

function rspr(fr,x,y,rot,flx)
 for gx=0,7 do for gy=0,7 do
  px=(fr%16)*8
  py=flr(fr/16)*8	 
  local ggx=flx and 7-gx or gx
  
  p=sget(px+ggx,py+gy)
  if p>0 then
   dx=gx
   dy=gy	 
   for i=1,rot do
    dx,dy=7-dy,dx
   end
   pset(x+dx,y+dy,p)
  end
 end	end

end

function spal(n)
 for i=0,15 do
  pal(i,sget(i,n))
 end
end


function remove_suit()
 hero.hurt=false
 hero.churt=nil
 suit=nil
 hero.cinv=80
 for i=0,2 do
		throw_cloth(44+i,i)
 end
end

function throw_cloth(fr,i)
 local e=mke(fr,hero.x,hero.y)
 impulse(e,.25+rnd(.1),1+i)
 e.we=.1
 e.frict=.95
 e.life=24+rand(8)
 e.blk=true
end

function upd_game()
 
 if frz then
  frz-=1
  if frz==0 then
   frz=nil 
   if suit and hero.hurt then
    remove_suit()
   end 
  end
  return
 end
 t+=1


 
 -- choose item
 if hero.hurt then
  upe(hero)
  return
 end
 
 -- increase island
 if tlp>lp and t%4==0 then
  lp+=1
 end
 
 -- stykades
 if t%80==0 and scraps<48 then
  if peace>0 then
   peace-=1
  end

	 spawn_monster()  
 end
 
 -- game
 foreach(ents,upe)
 
 
 
end

function spawn_monster()

 --local mdif=lp/2-7-peace
 --lp=ceil(3+scraps/4)*8
 local mdif=3+scraps/2

 
 for m in all(monsters) do
  mdif-=m.dif
 end 

 if mdif<=0 then
  return
 end
 
 if scraps>=16 and rand(4)==0 then
  spawn_bomber()
  
 elseif rand(2)==0 then
  local fr=33
  if scraps>8 and rand(2)==0 then
   fr=27
  end
  spawn_crawler(fr)
 else
  swarm(spawn_bee,1+rand(3),8)
 end 
 spawn_monster()
 
 
end  
  


function cen(str,cl)
 cl=cl or 15
 print(str,64-#str*2,cy,cl)
 cy+=8
end

function dr_new_item()
 cl=15
 cy=8
 if hero.csel then
  cy-=(1-hero.csel/32)*64
 else
	 local d=desc[pool[sel+1]+1]
	 d=d.." --- "
	 local ln= #d*4
	 for i=0,4 do
	  print(d,ln*i-t%ln,100,14)
	 end 
 end

 cen("shrink a new toy")
 cen("to improve your surival")
 cen("chances")
 cy=64-#pool*4 
 for i=1,#pool do
  local n=pool[i]
  local cl=7
  if sel==i-1 then
   cl=10
   if hero.csel then
    cl=7+t%4
   else
	   spr(53,12.5+cos(t/20)*2,cy-2)
   end
  end
  
  
  if not hero.csel or sel==i-1 then
   cen( dit[1+n*3] ,cl)
   spr(102+n%7+flr(n/7)*16,30,cy-9)
  else
   cen("",cl)
  end
  
  
 end
 

 
 
 
 
end

function dr_par(p)
 if p.col then
  apal(p.col)
 end
 if hero.hurt then
  apal(2)
 end

 p.cx+=hero.vx*p.mult/256 
 for i=0,1 do
  local x=(i-p.cx%1)*256
 	map(0,p.my,x,p.y,p.w,p.h) 
	 if p.mach then
	  for k=0,2 do
	   sspr(104,64,24,22,x+k,32+k,72,66)
	  end
	 end
 end
 

 
 
 pal()
end




function dr_game()
 if frz then return end
 cls(8)
 camera()
 
 -- sky
 sspr(hero.hurt and 32 or 0,16,8,8,0,0,128,128)

 
 -- camera
 cmx=hero.x-64
 cmy=0 
 
 -- paralax
 camera(0,cmy)
 for p in all(paralax) do
  dr_par(p)
 end

 -- inter
  dr_inter()

 
 --
 local s=(t%4<2 and -1 or 1)
 if hero.cshk then
  cmy=hero.cshk*s
 end
 if hero.cshkb then
  cmx+=hero.cshkb*s
 end 
 camera(cmx,cmy)
 k=hero.x<lp*4 and -1 or 0
 
 dp=0
 foreach(ents,dre) 
 for i=0,1 do  
  map(0,0,(k+i)*lp*8,0,lp,16)
 end
 dp=1
 foreach(ents,dre)
 camera(0,cmy)
 
 -- herb
 dr_par(herbs)
 --hbx+=hero.vx/128 
 --for i=0,1 do
 --	map(0,16,(i-hbx%1)*256,96,32,4) 
 --end
 



 --print("scraps:"..scraps.."/50",1,1,15)

 

 -- hurt screen
 if hero.hurt then 
  if hero.churt then
   fade(1-hero.churt/40)
  else
   fade(1)
   dr_new_item()
  end
 end 
 if hero.cspawn then
  fade(hero.cspawn/40)
 end 
 
 --
 if cfd then
  fade(cfd)
 end
 
 

 -- log
 cursor(0,0,7)
 for l in all(logs) do
  print(l)
 end
 
end

function dr_inter()

 for i=0,fail-1 do
  local x=1+(i%4)*6
  local y=1+flr(i/4)*6
  spr(132,x,y)
 end

	-- scanner
	if has(4) then
	 local llp=min(lp,70)
	 local bx=(128-llp)/2
	 local by=16
	 rect(bx-2,by-2,bx+llp+1,by+18,7)
	 rect(bx-1,by-1,bx+llp,by+17,13)
	 clip(bx,by,llp,17)
	 map(32,26,(-hero.x/8)%8,by,16,3)
	 function show(e,py)
	  local x=64+e.hdx/8
	  local y=by+e.y/8
	  sspr(29,py,3,3,x,y)
	 end
	 for m in all(monsters) do
			show(m,16)
	 end
	 show(scr,19)
	 show(hero,21)
	 clip()	 
	end
 
 -- energy
 if hasgun() or has(1) then
  local mx=32+(16-pow)/2
  for i=32,47 do mset(i,24,0) end
  mset(mx,24,96)
  mset(mx+pow-1,24,98)
  for i=1,pow-2 do
   mset(mx+i,24,97)
  end 
	 map(32,24,0,3,16,1)	 
	 clip((mx-32)*8+1,0,en-2,16)
	 map(32,25,0,3,16,1)
	 clip()	 
	end 
	
 -- remote control
 apal(2)
 sspr(104,32,24,32,103,1)
 pal()
 for k=0,1 do
  if k==0 then apal(1) end
  if k==1 and scraps==48 and t%8<4 and not hero.chappy and hero.c then
   apal(7) 
  end
	 for i=1,scraps do 
	  local p=rem[i]
	  local x=104+p.x-k
	  local y=2+p.y-k
	  if hero.chappy and i==scraps then
	   x-=hero.chappy
	   y+=hero.chappy
	  end
	  sspr(104+p.x,32+p.y,4,4,x,y)
	 end
	 pal()
 end	
 
 if hero.cpress then
  spr(115,111,17)
 end
  
 if hero.cfing or hero.cpress then 
  local c=hero.cfing and hero.cfing/32 or 0
  if hero.frev then
   c=1-c
  end
  local fy=20+c*c*32
  if hero.cpress then
   fy+=1
  end
  sspr(32,48,11,16,107,fy)
 end
 
 

	
end



function fade(c)
 local hy=mid(0,cfd and 0 or hero.y,128) 
	for x=0,15 do for y=0,15 do
	 local dx=x-7.5
	 local dy=y-hy/8
	 local dd=sqrt(dx*dx+dy*dy)
		n=mid(0,1+dd/7-(1-c)*4,1)				
	 mset(112+x,16+y,flr(247-sqrt(n)*6)  )
	end end		
 map(112,16,0,0)
 srand(2)
 
 for i=0,20 do
  local dd=48+rand(32)
  local an=rnd()
  local Œ=2+rnd(2)
  local an+=(i/100)*c
  local x=64+cos(an)*dd*(1-c)*Œ
  local y=hy+sin(an)*dd*(1-c)*Œ
  local cl=max(c-rnd()/4,0)
  print("’",x,y,sget(71-cl*7,14))
 end
 
end


function log(n)
 add(logs,n)
 if #logs>20 then
  del(logs,logs[1])
 end
end

dit={
 	"blaster",11,0,		--0
 	"jetpack",5,0,			--1
 	"underwear",3,4, --2
 	
 	"suit",7,9,						--3
 	"scanner",6,8,			--4
 	"battery",0,0,			--5
 	
 	"gasoline",0,0,	 --6
 	"old radio",0,0,	--7
 	"forcefield",0,0,--8
 	
 	"glasses",10,0,	 --9
 	"plasmagun",0,0,--10
 	"dynamo",0,0,			--11
 	
 	

}
desc={
 "kill bugs before they kill you",
 "fly like a ladybug",
 "increase your self esteem",
  
 "makes you invulnerable... until it's thorn apart.",
 "track monsters and scraps",
 "more energy for your contraptions",

	"jetpack don't use energy anymore",
 "you can dismantle it for 3x scraps of metal",
 "protect you from missiles",

 "don't let these bugs read your next move.",
 "well that escalated quickly",
 "refill your energy faster when you run"

}
__gfx__
0123456789abcdefffffffff0000000000000000000000000000000011112211000000006d06d0006d06d0000077700000777700007777000000000000012210
1d8b9d77ea7a66f7f000000000fff99000fff99000fff99000fff99011122211000000007dd7d0007dd7d00007fcffc007777700077777700000000000122221
dddd6d6ccc7cccccf000000000fff99000fff99000fff99000fff99001222211000000006d16d0006d16d00007ff770007fcffc0076777700005555511222211
3333b3bbbbabbbbbf000000000ff999000ff999000ff999000ff999001122211000000006dd6d0006dd6d000f7f7ff70f7ff7700f7fcffc00005505511122211
111111c6cc6cccc6f000000000f9f99000f9f99000f9f99900f9ff900011111100777660dd1dd000dd1dd000077777770777ff770777ff770000000022111111
222224df28e9d28ef000000000f0f09000f0f0900ff00f00fff0009000001221000d6d00dd0dd000aa0aa0000077777700777777007777770000000022221221
2222222e22882228f000000000f000900f000009f000000000000009000012210000000000000000aa0aa0000000777000007770000077700000000022221221
2222222822222222f000000000f00090f00000090000000000000000000001110000000000000000990990000000000000000000000000000000000011111221
29444442bbb3bbb30000000000000000000000000077770022222222044249201d8b9477ea7a66f7249442420000000000000000008818000088180011000000
24444442bb242bb300000000000000000000000007777770222222224944444056eaa977f7777777224444220000000000000000dd8888100088881022100000
44422222b44222b2b0000000000000000000000007cffc702222222244442494d7f77a77777777774421221200818800008188000ddd88800000888022100000
4429442444294424b00000000000000000300000f6f77f6f222222222440424267777777777777774412442408f8888008f88880000d81800ddd818011100000
4424442444244424bb0000000b00000000300000067227602222222200000000777777777777777744294424818818668188186601116866d666686622211110
4422224444222244bb0000000bb000b000330000077887702222222200000000ddeeff7700000000222442448888861188888611111116116666161122221221
4222444442224444bbb000000bbb0bb0033330000077770022222222000000002eeeff7700000000412244241111111111111111111111111111111122221221
2222244422222444bbb000000bbbbbb0033330000000000022222222000000000000000000000000221224241d0d1d01d011d0d00d0d1d100d0d1d1011111221
dddddddd00000000000000000770088088888888bbb3bbb3000700000000ddddd00000000000000000000000bb33bbb300000110000000000000000000000001
eeeeeeee00000d0100000d017777088088888888bb442bb3007770000000d7777010100000000ddd10101000b32223b311000011000000000000000000001221
ffffffff00000d0100000d017777000088888888b42122b207000700000d67777d110000000d66d11d1100003244223201110111000111000000a00000012211
6666666600dd1d0100dd1d0107700bb088888888441244247707077000dddd7771a1900000dddd7771a190002244422200111110001111100099000000122211
cccccccc0d6d1a140d6d1a1400000bb0888888884429442407000700001111114111100000111177711110002244222201111110011001100000000001111111
ccccccccdddd1111dddd11110000000088888888222442440077700000044d4d1001010000044d77700101002222212211111100110011000000000002221221
dddddddd111111111111111100000aa022222222412244240007000000001010010000000000106dd60000001222211200000000100110000000000002221221
333333331d0d1d01d011d0d000000aa02222222222122424000000000000010100000000000001d6dd0000001122111200000000000100000000000011111221
4049490000007700000000000000055000000550000000000000000000ee00000000d6600000000000dd00001111221100000000000000000000000000000000
0494944000007700000000007770555000005550077000000eeee0000effe000000d6d66006670000dd000001112221100dd761000dd761000dd761000dd7610
444449f0005ad700005a5000777f50500005f75007777000ef77fe000e77e000000d66d60667dd00006766001122221100dda61000dda61000dda61000dda110
44449ff90a5adf050a5a5a05007d50000005d77707777770ef77fe000e77e000000dd66d667dd6d0000dd0001112221100dd911000dd911000dd911000ddd990
4449ffff5a5adf555a5adf55000aa5a0000aadf7077777710eeee0000effe000006dddd00ddd67dd00dd00002211111100dd911000d9d11001ddd91551ddd110
44999fff000000550000775500055a5000055a50077771110000000000ee000006dd000000dd7dd00dd000602222122100ddd11000ddd1105dd1111151111110
049999ff00000000000077000000a5a00000a5a00771110000000000000000006dd00000000ddd00006766002222122100d000105dd000015000000000000051
0009999900000000000077000000000500000005001100000000000000000000dd00000000000000000000001111112100550055500000050000000000000005
00001111100000000000000000001111100000000000000000000000000000000000000000000000000000000000000000000000000000766666000000000000
666611d6d100000000000000000011d6d100000000000000000000000000000000000000000000000000000000000000000000000028886dddddd000676d0000
666611dd6d10000000000000000011dd6d10000000000000000000000000000000000000000000000000000000000000000000000080006d1111d000676d0000
0666611dddd10000110000000000011dddd1000011000000000000000000000000000000000000000000000000000000000000000080286d1dddd00544455000
00666611ddd100001001100000000011ddd1000010011000000000000000000000000000000000000000000000000000000000000080806d1dddd00544455000
0006661111111d16d10100000000001111111d16d1010000000000000000000000000000000000000000000000000000000000000087677d77d7777777777700
0004aa9111111d1d111100000004922111111d1d11110000000000000000000000000000000000000000000000000000000000000077d77d77d7777777777660
00949aa911111111a91140000094949911111111a9114000000000000000000000000000000000000000000000000000000000000777666666666666666666d0
0494444a911111119911400004949aa991111111991140000000000000000000000000000000000000000000000000000000000007766dddddd66b366b366dd0
0444444442221d1d11d11000044aaaaa92221d1d11d11000000000000000000000000000000000000000000000000000000000000776dd666666633d633d6dd0
00244444422d1d0ddd001110009aaaaa422d1d0ddd001110000000000000000000000000000000000000000000000000000000000776d6d6d6d666dd66dd6dd0
000222222d0d01d01d000010066999922d0d01d01d000010000000000000000000000000000000000000000000000000000000000776d6666666666666666dd0
00000000d001001001dd000066666600d001001001dd0000000000000000000000000000000000000000000000000000000000000776dd6d6d666dddddddd1d0
000000001001010000000000666600001001010000000000000000000000000000000000000000000000000000000000000000000776d66666666d5955599410
000000000100000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000776d6d6d6d66d5999555140
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000776d66666666d5559999410
000000000000000000000000000000000000000ff00000000000000000000000000000000000000000600600060006000000d10007766d6d6288882959555140
000000000000000000000000000000000000000ff10000000d66666006d06d00000000000dd6611006777760aa90aa9000999400077666662888888259599410
077777777777777777777770000000000000000ff1000000d666666007dd7d0000000000dddd111167733776aa90aa90090a940007766a968888888859595140
721212121212121212121216eeeeeeee0000000ff100000066600d0006d16d0006666600d0dd11010733bb705510551090a9940000dd699d888888e819595140
742424242424242424242426efefefef0000000ff10000006600600006dd6d0007776600d0dd1101073bbb705510551099999400006d66dd888888e819595140
742424242424242424242426efefefef0000ff0ff1000000666600000dd1dd0000d6d000d0dd1101077bb77055105510999994000076666688888ef81dddd140
0666666666666666666666600000000000f9fffff1000000000000000dd0dd000000000000dd11000077770066d066d04444440000776a96288eef82d7777d10
00000000000000000000000000000000f9fffffff1000000000000000000000000000000000000000000000000000000000000000077699d22888822d6666dd0
0bbbb0000cccc000111122116d666d59fffffffff90000000006000000cccc000000000000000000000d77700000000000000000007766dd22222222ddddd1d0
ba77ab00cc77cc001112221162888829fffffffff99000000000d0000c0000c0000000000d77677d000d77770000000000000000007766666222222dd7777d10
b7777b00c7777c001122221028888882fffffffffff1000000000d00c0d66d0c00555550d67677d6000d777700000000000000000077677677d77ddd66666dd0
b7777b00c7777c0011122210888888889ffffffffff100001dd11110c066660c05550550666d66d6dd9dd777000000000000000000776776776776666dddd1d0
ba77ab00cc77cc0022111000888888e80fffffffff110000dddd1610c066660c510011006666d66dd994dddd000000000000000007766dd6dd6dd66667777d10
0bbbb0000cccc00022220000888888e80ffffffff1100000dddd1110c0d66d0c1000100066dd0000d44440000000000000000000076666666666666666666dd0
00000000000000002221000088888ef809ffffff110000001dd116100c0000c00000000066000000dd44d00000000000000000000666ddddddddddddddddddd0
000000000000000011000000288eef8200011111100000000000000000cccc0000000000000000000dddd0000000000000000000006ddddddddddddddddddd00
00bb3333000033bbbbbbbbbbbbbb300007770000000d6666d999999d6666d0000033bbb888220000077700000000000007777000d66600000000000000000000
00bb3333033bbbbbbbbbbbbbbbbbbb307d7d700000dd66699aaa99999666dd00033bb888888822007d7d70000000000007777700ddd666660000000000000000
03bb33333bbbbbbbbbbbbbbbbbbbbbb37d7d71006666dda99aaaa9999add666633bbbbbb888f22207d7d700000000000cffcf700ddddddd66666000000000000
00bb3333bbbbbb333333333333bbbbbb07771100666666aaaaaaa999aa666666bbb38888888288200777000000000000077ff7f00000ddddddd6666600000000
00bb3333bb33333333333333333333bb07171000666666aaaaaa9999aa666666b2b88f8f8f88e82207070000000000077ff7770000000055ddddddd666550000
00bb333333333333000000000000003b0010100066777776667777666777776622b8888888888882000000000000000777777000000000555555dddddd5d5650
00bb3333333300000000000000000003000000000777777667777776677777702288f8f8f888228200000000000000907776d00f00000dd05555000ddd5d65d0
00bb3333300000000000000000000000000000000066666d77777777d6666600222888888882f222000000000000000916addff000000dd0dd0dd00000005d50
0bb333300003bbbbbb330000294444428800088000000000677777760000000028288f8f8f8228820000000000000000119dd0000000ddd0dd0dd00000000000
0bb3333003bbbbbbbbbbb33024444442888088810000000006666660000000002222888888828ee2000000000000000519ddd1000000dd00dd00dd0000000000
0bb333303bbbbbbbbbbbbbb32442222208888811000000000033330000000000228288888888ef8200000000000000011111dd500006666666666d0000000000
0bb33333bbbbbb3333bbbbbb12294424008881100000000000b3333000000000022222822288882200000000000000000000005000c6ddddddddddd000000000
0bb33330bb333333333333bb11244424088888000000000000b33300000000000228282f2288882200000000000000000000000000c6ddddddddddd200000000
0bb33330b3000000333333331112224488818880000000000bb3330000000000002222228822222200000000000000000000000000c6ddddddddddd200000000
3bb3333030000000000033331111124488110881000000000bb3330000000000000222228e2222200000000000000000000000000c3555000030d55200000000
0bb3333000000000000000031111112201100011000000000bb333000000000000000222222222000000000000000000000000000c0d555d00ccdd5200000000
bb3333000bb3bb3000b3330029444442000000000000000000000000000000000000000000000000000000000000000000000000c30650dd6ddcc65220000000
bb333300b331333300b3330024444442000000000000000000000000000000000000000000000000000000000000000000000000c00d506ddd550d5222000000
bb3333303bb31bb300b3330042442221000000000000000000000000000000000000000000000000000000000000000000000000c0065ddd005dd65022288000
bb333300bbb33bb300b3333044222111077000077000000003333330077000077000000000000000000000000000000000000000cc0d5d000000dd5002222880
bb333300bb3bb3b300b333004421111177700007770000003333333377700007770000000000000000000000000000000000000003c650000000065000008282
bb33330033bbbb3300b3330044211221777000077700000003333330777000077700000000000000000000000000000000000000000d500000000d5000000828
bb3333003333333300b3330042211221777000077700000000000000077000077000000000000000000000000000000000000000000650000988888888888828
bb3333000333333000b3330011111121777000077700000000000000077700777000000000000000000000000000000000000000000d50044422222222222220
0000000000b333000b33300011112211077000077000077007777700007700770077770777770077777000000000000000000000000000000000000000000000
0000000000b333000b33300011122211077000077077077000770770000777700770077077077007707700000000000000000000000000000000000000000000
0000000000b333000b33300011222211077077077077077000770077000777700770077077007707700770000000000000000000000000000000000000000000
0000000000b33330bb33300011122211077077077000077000770077000077000777777077007707700770000000000000000000000000000000000000000000
0000000000b333000b33300022111111077777777077077000770077000077000770077077077007700770000000000000000000000000000000000000000000
000000000bb333000b33300022221221077777770077077000770077000077000770077077770007700770000000000000000000000000000000000000000000
000000000bb333000b33300022221221007700770077077000770770000777700770077077077007707700000000000000000000000000000000000000000000
000000000bb333000b33300011111121007700770077077777077700007777770770077077007707777000000000000000000000000000000000000000000000
b0000000bbbbb000bbbbb000bbbbbbbb0000bbbbbbbb0000bbbbbbbb000bbbbb0000000b00000000000000300300000000000000000000000000000dd0000000
b0000000bbbbb000bbbbb000bbbbbbbb0000bbbbbbbb0000bbbbbbbb000bbbbb0000000b0000000000000030033000000000000000000000000000dddd000000
bb000000bbbbbb000bbbbb000bbbbbbb00000bbbbbb00000bbbbbbb000bbbbbb000000bb000000000000003000330000000000000000000000000dddddd00000
bb000000bbbbbb000bbbbb000bbbbbbb00000bbbbbb00000bbbbbbb000bbbbbb000000bb00000000000003300033300000000000000440000000dddddddd0000
bbb00000bbbbbbb000bbbbb000bbbbbb000000bbbb000000bbbbbb000bbbbbbb00000bbb0000000000000330000333000000000044444244000dddddddddd000
bbb00000bbbbbbb000bbbbb000bbbbbb000000bbbb000000bbbbbb000bbbbbbb00000bbb000000000000333000033300000000004444424400dddddddddddd00
bbbb0000bbbbbbbb000bbbbb000bbbbb0000000bb0000000bbbbb000bbbbbbbb0000bbbb00000000000033000003333000000000000440000dddddddddddddd0
bbbb0000bbbbbbbb000bbbbb000bbbbb0000000bb0000000bbbbb000bbbbbbbb0000bbbb0000000000003300000033300000000000044000dddddddddddddddd
bbbbbbbb3333333333000000000003300000000000effe0033333333000000000000030030000000000033000000333300000000000000000000000000000000
bbbbbbbb333333333330000000000330000030000efeefe033333300000000000000033030003330000333000000333300000000000000000000000000000000
bbbbbbbb333333333330000000003300000030000feeeef033333300000000000330033030033300000333000000033330000000000000000000000000000000
bbbbbbbb333333330333000000003300000330000ffeeff033333000000330000033033333333300000330000000033330000000000088888888888888820000
bbbbbbbb333333330333300000033000000300000effffe033003000000330000033033333333300003330000000033330000000000ee8e8e8e8e8e888822000
bbbbbbbb333333330333300000033000003300000eeeee003300000300333003000333333333300000333000000000333300000000ee88888888888888822200
bbbbbbbb3333333300333300003330000033000000ee0000333003330033333300033333333333330033300000000033330000000eee8e8e8e8e8e8e88822220
bbbbbbbb333333330033330000330000003000000030000033333333033333303333333333333333003330000000003333000000eeee88888888888888822222
0000000b0000000b003333000033000003300000000000000000000000000000333333333333333303333000000000333330000099999999ffffffffffffffff
000000bb000000bb0033333003330000033000000000000000000000000000000003333333333300033300000000003333300000fffffffff9999999ffffffff
00000bbb00000bb00033333003330000033000000000000000000000000dd0000033333333333000033300000000003333300000fffffffff922c229ffffffff
0000bbbb0000bbb0000333300333000003300000000000000000000000dddd000333333333333300033300000000000333330000fffffffff928c889ffffffff
000bbbbb000bbb0000033333333300003300000000000000000000000dddddd00000003333303330333300000000000333330000fffffffff98ccc89ffffffff
00bbbbbb00bbbb000003333333300000330000000000000000000000dddddddd0000033333300030333300000000000333330000fffffffff9ccccc9ffffffff
0bbbbbbb0bbbb00000033333333000003300000000000000000000000dddddd00000333333300000333300000000000333333000fffffffff9999999ffffffff
bbbbbbbbbbbbb00000033333333000003300000000000000000000000dddddd00000000303300000333300000000000333333000ffffffffffffffffffffffff
b000000022222222022222200022220000000000000000000000000000000000000000000000000000000000bbbbbbbb3333333399999999ddddddddbbbb33bb
b0000000222222222222222202222220000220000000000000000000000000000000000000000000000000003bbbbbbbb3333333ffffff99dddddddd33333333
bb0000002222222222222222222222220022220000000000000000000000000000000000000000000000000033bbbbbbbb333333ffffff99ddddddddbbbbb33b
bb00000022222222222222222222222202222220000220000000000000000000000000000000000000000000333bbbbbbbb33333ffffff99ddddddddbbbbbbbb
0bb00000222222222222222222222222022222200002200000002000000000000000000000000000000000003333bbbbbbbb3333ffffff99ddddddddbbbbbbbb
0bb000002222222222222222222222220022220000000000000000000000000000499420044200000000000033333bbbbbbbb333ffffff99ddddddddbbbbbbbb
0bbb000022222222222222220222222000022000000000000000000000000000024444200442004200000000333333bbbbbbbb33ffffff99ddddddddbbbbbbbb
0bbb0000222222220222222000222200000000000000000000000000000000000222222002220222000000003333333bbbbbbbb3ffffff99ddddddddbbbbbbbb
__gff__
0000000000010100000000000000000025a70000000000000000254200424200004200000027000200000002000000000502000202000200010101000000010102020000020000000000000000000000020200000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000
0002020200020202020200000000000000020225002500000000000000000000000000250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900000000000000000000000000000918292a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000009000000000000000000000000000000000000000a1000000000000000000000000000000000000000000000000000000000000000081828292a00000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000008000000000000000000000000000000000000000a2000000000000000000000000000000000000000000000000000000000000000000000000900000000000000000
0000000000000000000000000000000000008586870000000000000000000000000000000000000000000000a000000000000000000000000000000000008000000000000000000000000000000000000000b1000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000
0000000000000000000000000000000000000096000000000000000000000000000000000000000000009192a0000000000000000000000000000000000080830000000000000000000000000000000000008081830000000000000000000000000000000088890000002b2b1111000000000000000000808182830000000000
00000000141300000000000000000000000000b20000000000000000000000000000000000000000000000009000000000000000000000000000000000008000000000000000000000000000000000000091a000000000000000000000000000000000000098990000003b3b1010d90000000000000000800000000000000000
00000000111100000000000000000000000000b100000000000000000000000000000000000000000000000080000000000000000000000000000000000090000000000000000000000000000000000000009000000000000000000000140000000000d81111110000d83b3b1010111100000000000000900000000000000000
000000d8101000000000000000000000000000900000000000000000000000000000000000000000000000008081828300000000000000000000000000009000000088890000000000000000000000002b2b2b2b2b0000000000000000111100001111111010112b2b2b111110101010d900d8d9009192a00000000000000000
000000111010110000000000000000000000008081828300000000001400130000000000001413000000000090000000000000002b2b2b00000000009192a000d8d99899000000000000000000000000073b3b3b3b000000000000131410101400101010a33b3b3b3b3b3b3b931010101100e82b2b2b2b2b0000000000000000
000000101010101400000000000000000000009000000000000000002b2b2b2b00000000002b2b0000918292a0000000000000003b3b3b0000008889000090d81111111100000000000000000000000000073b3b3b1f000000002b11111011111110a33b3b3b3b3b3b3b3b3b3b93101010d900073b3b3b3b1f0000d8d9000000
0000d8101010102b2b00000000000000918292a000d71200000000003b3b3b3b00000000003b3b0000000000a014130000d8d900073b72001314989900d890d1101010d60000000000002b2b0000000000003b2b2b2b00000000079310a33b3b3b3b3b3b3b3b3b3b2b2b2b3b3b3b10101011000f3b3b111111112b2b2b000000
001111111010103b3bd9000000000000000000a013111100000000003b3b3b3b0000130011111100d7141311111111111111e9002f72002f1111111111101010101010d1d900000000003b3b1f000000002f3b3b3b3b0f00000000073b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b101010100f3b3b3b101010103b3bd1d90000
001010101010103b3bd1d90000f8f9001200111111101000000014133b3b3b3b1111111110101011111111111110101010101f003b1f2f3b101010101010101010101111111100f800f93b3b3b1ff8000f3b3b3b3b3b3b1f0013f92f3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b101010101111111111111010103b3bd1d1d900
11111111111111111111111110101011111110101010111111111111101010101010101010101010101010101010101010103b0f3b3b3b3b101010101010101010101010101010101010101010101010101010101010101111111111111111101010101010101010101010101010101010101010101010101111111111111111
000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000dddedededededf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c10000000000000000000000c800000000000000000000000000000000000000000000000000000000ededededededed0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d0c00000e100000000000000c70000000000e10000000000e10000000000000000000000000000dddeefefefefefefef0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c3c100e0c500c200c000e1c8d000c00000e0c500000000e0c500000000cdcdcdcdcdcdcdcdcdcdedfdefefefefefefefcdcdcdcdcdcdcdcdcdcdcdcdcd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000d8d9d8d90000000000000000fffffffffffffffffffffcd1d1d1d1d1d1d1d1fbffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d700000000000000d8d9000000000000000000d8d1d1d1d60000000000000000d0d0d0d0d0d0d0d0d0d0d0d0fcd1d1d1d1d1d1d1fbd0d0d0d0d0d0d0d0d0d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d6d8d900000000d8d1d6d7d9d70000d8d1d9d8d1d600e8d1d9000000000000d8cf000000000000cecf0000000000000000000000cecf00e700e70000000000ce00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d1d1d1d900d7d8d1d1d1d1d1d1d9d8d1d1d1d1d1d1d9d8d1d1d900d8d900d8d1fecf00cecf00cefefecf00000000000000cecfcefefefefefefefecf0000cefe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cb000000ca00000000ca00000000ca00ca000000cb00000000000000000000ca636363636363636363636363636363630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dbdcd4d3da00d200cbdad500d2d3da00da00d200dbdc000000d2d500cb0000da636363636363636363636363636363630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ebece4e3eacae2cadbeae4cae2e3eaeceacae2cbebeccacbd3e2e4d4dbdcd4ea020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000a4a500a4a500a7a800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b4b5b6b4b5b6b7b8b9ba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002b74313025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002b52100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002b0731f033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002722537515272003750027221375111f00033000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00003703100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002b1551f2252b5250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002b05100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001f0701f012260502602226012260121f0701f012260502602226012260121f0701f01226050260222601226012260122601226012260122601226012260121f0501f0122605026012280502805225050
010c00002502225012250122501225012210702103221022210122101221012230702303223022230122301223012230122301223012000000000000000000000000000000000000000000000000000000000000
011000002b17113521135051350500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001373300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00000715413055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00003702500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001f02300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000213614076151f6251361500600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000001d05518055000001d0551f0551d0051d0550000021055000001805515055160551f0551f005170051d05518055000001d0551f0551d0051d0550000021055000002405522055210551d0551f0551f000
01200000185551d55521555185551d555215551855515555165551d55522555165551d55522555165551f555185551d55521555185551d55521555185551d5552455522555215551d5551f555185551d5551c555
014000003705413051130530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f275131321f245131121f235131151f21513105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000370242b051000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001f0141f0351f0141f0351f0141f0351f0141f0351f0141f0251f0141f0251f0141f0251f0141f0251f0141f0051f0141f0051f0141f0051f0141f0051f0041f0051f0041f0051f0041f5051f5041f505
01100000131541f2242b1140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f2531f6021f6021f6021f602000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001f05500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001f25523155260550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002b1551c0522f052211252d0122d0050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000715407155131541315500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 08 42 43 44
05 09 42 43 44
03 41 11 43 44
03 10 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
