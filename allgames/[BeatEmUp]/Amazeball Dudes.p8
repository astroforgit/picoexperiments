pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
--amazeball dudes
--hickathrift games 2018
s_title=true
 logo=nil
 tit=1
s_intro=false
 cap=nil
 strn=1
 stick=1
 lit=1
 intsfx=20
s_nump=1
s_lvl=false
s_clear=false
s_boss=false
s_cont=false
s_gover=false
s_stp=0
p=8
bug="bug"
msg=nil
hero=nil
hero2=nil
score1=0
score2=0
up1=3
up2=3
conts=3
cgag=1
cx=50
cp=48

function _init()
 hero=_hero(0)
 hero2=_hero(1)
 logo=pstray(tfont)
 cap=pstray(cpic)
 menuitem(1, "music", function()_moff() sfx(5) end)
 music(2,360)
end

function _update()
 if(p>0)then
  p-=1
 elseif(msg)then
  music(-1,300)
  if(btn(4) or btn(5))then
   p=14
   if(introi<#msg[lit]+1)then
    introi=#msg[lit]+1
   elseif(lit<#msg)then
    lit+=1
    introi=1
    stick=1
    strn=1
   else
    music(0,300)
    msg=nil
    _sre()
   end
  end
 elseif(s_title)then
  if(btn(2) and tit>1)then
   tit-=1
   p=4
   sfx(0)
  elseif(btn(3) and tit<2)then 
   tit+=1
   p=4
   sfx(0)
  elseif(btn(4) or btn(5))then
   sfx(6)
   music(-1,90)
   p=8
   s_nump=tit
   cgag=1
   wofl=1
   s_boss=false
   s_title=false
   s_intro=true
   conts=3
   _hre()
   if(s_nump!=2)then
    hero2=nil
   end
  end
 elseif(s_intro)then
  if(btn(4) or btn(5))then
   p=8
   if(introi<#intro[lit])then
    introi=#intro[lit]+1
   elseif(lit<2)then
    _sre()
    lit=2
   else
    _ilvl()
    _sre()
    s_intro=false
    s_btn=false
   end
  end
 elseif(s_lvl)then
  music(-1)
  if(btn(4) or btn(5))then
   p=8
   lvl+=1
   s_lvl=false
   if(lvl<8)then
    _ilvl()
   else
    s_clear=true
   end
  end
 elseif(s_cont)then
  music(-1)
  if(btn(4) or btn(5))then
   if(cgag==1)then
    cgag=2
    p=8
   else
    s_cont=false
    s_boss=false
    conts-=1
    cgag=3
    _hre()
    p=8
    hero=_hero(0)
    _ilvl()
   end
  end
 elseif(s_gover)then
  music(-1)
  if(btn(4) or btn(5))then
   p=8
   s_title=true
   s_gover=false
   hero2=_hero(1)
   hero=_hero(0)
  end
 elseif(s_clear)then
  music(-1)
  if(btn(4) or btn(5))then
   p=8
   if(introi<#clear[lit])then
    introi=#clear[lit]+1
   elseif(lit<1)then
    _sre()
   else
    s_clear=false
    s_title=true
    hero2=_hero(1)
    _sre()
   end
  end
 else
  if(hero)then
   _input(hero,hero.pnum)
  end
  if(hero2)then
   _input(hero2,hero2.pnum)
  end
  if(hero)then
   _uspr(hero)
  elseif(btn(4) or btn(5))then
   hero=_hero(0)
   hero.x=cx-32
  end
  if(hero and hero.dead)then
   up1-=1
   hero.die=4
   hero.x=cx-32
   hero.y=50
   if(lvl==4)then
    hero.y=19
   end
   hero.dead=false
  end
  if(hero2 and hero2.dead)then
   up2-=1
   hero2.die=4
   hero2.x=cx-32
   hero2.y=19
   hero2.dead=false
  end
  if(hero2)then
   _uspr(hero2)
  elseif(btn(4,1) or btn(5,1))then
   hero2=_hero(1)
   hero2.x=cx-32
   hero2.y=19
  end
  _ues()
  _umap()
  _udrops()
  _ubt()
  _ufx()
  if(up1==-1)then
   hero=nil
  end
  if(up2==-1)then
   hero2=nil
  end 
  if(not hero and not hero2)then
   p=8
   if(conts>0)then
    s_cont=true
   else
    s_gover=true
   end
  end 
 end
end

function _draw()
 palt(0,false)
 palt(1,true)
 if(s_title)then
  _dtitle()
 elseif(s_intro)then
  _dintro(intro[lit])
 elseif(msg)then
  rectfill(0,104,127,127,0)
  rect(0,104,127,127,7)
  _dmsg(msg[lit])
 elseif(s_clear)then
  _dintro(clear[lit])
 elseif(s_lvl)then
  if(p==0)then
   cls(0)
   print("stage "..lvl,45,53,7)
   print("clear",49,60,7)
  end
 elseif(s_cont)then
  cls(0)
  print("continue?",45,53,7)
  print(contgag[cgag],34,60,7)
  print(conts.." left",50,112)
 elseif(s_gover)then
  unp("game over",45,53,0,7)
 else
  cls()
  if(lvl==4)then
   if(bg2>-127)then
    bg2-=3
   else
    bg2=0
   end
   camera(0,-24)
   map(8,4,bg2,40,8,4)
   map(8,4,64+bg2,40,8,4)
   map(8,4,128+bg2,40,8,4)
   map(8,4,192+bg2,40,8,4)
   camera()
  end
  _dbg()
  if(scrl)then
   if(hero)then
    ch=hero
   elseif(hero2)then
    ch=hero2
   end
   if(hero2 and hero and hero.x>hero2.x)then
    ch=hero2
   end
   if(lvl==4)then
    cx=cx+0.2
   elseif(cx>=s_stp)then
    if(#es==0)then
     s_stp+=140
    end
   elseif(cx<ch.x)then
    cx+=1--ch.x
   end
   if(cx>944)then
     cx=944
    end
   camera(cx-cp,-24)
  end
  _dmap()
  _ddrops()
  if(lvl==3)then
   _dwofb()
  end
  _des()
  _dbt()
  if(hero)then
  _dspr(hero)
  end
  if(hero2)then
   _dspr(hero2)
  end
  _dfx()
  camera()
  if(hero)then
   print("1up",0,6,7)
   print(score1,0,12,7)
   print("hp",0,105,7)
   rectfill(8,105,8+(8*hero.die),109,8)
   rect(8,105,40,109,7)
   for i=1,up1 do
    spr(127,0+(i*8),110)
   end
  elseif(conts>0)then
   print("press — to join",0,105,7)
  end
  if(hero2)then
   print("2up",87,6,7)
   print(score2,87,12,7)
   print("hp",87,105,7)
   rectfill(95,105,95+(8*hero2.die),109,8)
   rect(95,105,127,109,7)
   for i=1,up2 do
    spr(127,87+(i*8),110)
   end
  elseif(conts>0)then
   print("press — to join",64,105,7)
  end
  print("hi 963687102",34,0)
  if(s_boss)then
   print("boss",8,18,7)
   rectfill(28,18,28+(8*boss.die),22,8)
   rect(28,18,28+boss.hb,22,7)
  end
 -- bug=stat(7)
 -- print(bug,0,112,7) 
 end
end

function _dintro(say)
 cls(3)
 _dpic(77,92,cap)
 if(introi<=#say)then
  ym=introi*8
  if(_type(say[introi],12,16+ym,7,0))then
   introi+=1
  end
 end
 for i=1,introi-1 do
  ym=i*8
  unp(say[i],12,16+ym,0,7)
 end
end

function _dtitle()
 cls()
 rectfill(0,24,127,95,12)
 line(0,36,127,36,7)
 rectfill(0,38,127,40,7)
 rectfill(0,42,127,95,7)
 camera(0,-24)
 map(0,0,0,8,8,4)
 map(0,0,64,8,8,4)
 for x=0,15 do
  spr(192,x*8,40)
  spr(204,x*8,48)
  spr(204,x*8,56)
  spr(193,x*8,64)
 end
 hero.x=46
 hero.y=56
 hero.h=true
 _dspr(hero)
 hero2.x=60
 hero2.y=56
 hero2.h=false
 _dspr(hero2)
 _dpic(18,2,logo,13)
 unp("1 player",46,28,0,8)
 unp("2 player",46,36,0,8)
 unp(">",40,28+((tit-1)*8),0,8)
 camera()
 pal()
end

function _dmsg(say)
 if(introi<=#say)then
  ym=introi*8
  if(_type(say[introi],4,100+ym,7,0))then
   introi+=1
  end
 end
 for i=1,introi-1 do
  ym=i*8
  print(say[i],4,100+ym,7)
 end
end

function _type(str,x,y,c,c2)
 unp(sub(str,1,flr(stick)),x,y,c2,c)
 stick+=0.4
 sfx(0)
 if(stick>#str+1)then
   stick=1
  return true
 end
  return false
end

function unp(str,x,y,c1,c2)
 print(str,x-1,y,c1)
 print(str,x,y,c2)
end

function _sre()
 lit=1
 introi=1
 stick=1
 strn=1
end

function _hre()
 up1=3
 up2=3
 score1=0
 score2=0
end

function _moff()
 music(-1)
end
-->8
	--sprites
function _hero(pnum)
 s=_imen(0,16,55,2,2)
 s.inv=0
 s.pc=true
 s.die=4
 s.fall=_ianim({18},6,false)
 s.hit=_ianim({14},3,true)
 s.hits=0
 s.anim=nil
 s.state=s_idle
 s.heads={{0,16,1,1,2},
          {12,16,2,0,0},
          {24,16,2,1,0},
          {36,16,0,1,4}}
 s.pnum=pnum
 if(pnum==1)then
  s.alt={12,8,}
  s.halt={9,4}
 end
 return s
end

function _enemy(x,y)
 s=_imen(0,x,y,2,2)
 s.die=2
 s.fall=_ianim({16},6,false)
 s.lup=_ianim({20},6,true)
 s.knl=_ianim({26},6,true)
 s.hits=0
 s.anim=nil
 s.state=s_idle
 s.heads={{48,16,2,1,0},
          {59,16,2,1,0},
          {70,16,2,2,0},
          {82,16,2,1,0}}
 s.alt={12,2,6,13}
 s.helm=false
 return s
end

function _ron(x,y)
 s=_imen(64,x,y,3,3)
 s.hits=0
 s.die=6
 s.anim=nil
 s.walk=_ianim({64,70},8)
 s.shoot=_ianim({64,107},10,true)
 s.rec=_ianim({67,64},8)
 s.pnch1=_ianim({64,{73,{123,24,4,6,18,11,6}}},4,true)
 s.state=s_idle
 s.heads={{93,16,8,0,-4},
          {104,16,8,0,-4}}
 s.alt={12,2,6,13}
 s.h=true
 s.boss=true
 s.hb=6*8
 s.ronai=true
 return s
end

function _osama(x,y)
 s=_imen(64,x,y,3,3)
 s.hits=0
 s.die=8
 s.hb=8*8
 s.anim=nil
 s.walk=_ianim({64,70},8)
 s.shoot=_ianim({64,107},10,true)
 s.rec=_ianim({67,64},8)
 s.pnch1=_ianim({64,{73,{123,24,4,6,18,11,6}}},4,true)
 s.state=s_idle
 s.heads={{22,48,7,0,-2},
          {35,48,7,0,-2}}
 s.h=true
 s.boss=true
 s.ronai=true
 return s
end

function _imen(snum,x,y,hgt,wdt)
 s=_ispr(snum,x,y,hgt,wdt,false,false)
 s.walk=_ianim({2,4,2,6},6)
 s.pnch1=_ianim({0,8,{10,{120,24,2,4,16,8,0}}},1,true)
 s.pnch2=_ianim({0,2,12},2,true)
 s.pnch3=_ianim({0,8,30},2,true)
 s.lup=_ianim({20},6,false)
 s.jup=_ianim({22},8,true)
 s.knl=_ianim({26},1,false)
 s.jmp=_ianim({24},8,false)
 s.kck=_ianim({28},8,false)
 s.hit=_ianim({14,0},8,true)
 s.low=false
 s.back=false
 s.dodge=false
 s.dmg=0
 s.p=0
 s.dead=false
 return s
end

function _ispr(snum,x,y,hgt,wdt,h,v)
 s={}
 s.snum=snum
 s.wdt=wdt
 s.hgt=hgt
 s.x=x
 s.y=y
 s.h=h
 s.v=v
 s.tick=0
 return s
end

function _uspr(s)
 if(s.inv and s.inv>0)then s.inv-=1 end
 if(lvl==4)then
  if(s.x<cx-cp)then
   s.x=cx-cp
  end
 end
 if(s.anim)then
  _uanim(s.anim)
  if(s.anim.dead)then
   s.anim.dead=false
   _sanim(s,nil)
  end
 end
 if(s.state==s_fall)then
  _fall(s)
 elseif(s.state==s_rec)then
  _rec(s)
 elseif(s.state==s_jup)then
  _jup(s)
 elseif(s.state==s_jmp)then
  _jmp(s)
 elseif(s.state==s_kck)then
  _kck(s)
 end
 if(s.dmg>3 or s.die<=0 and s.state != s_rec and s.state != s_fall and not s.dead)then
  s.dmg=0
  if(s.boss)then
   s.state=s_rec
   _sanim(s,s.rec)
   s.tick=60
  else
   sfx(2)
   _sanim(s,s.fall)
   s.state=s_fall
   s.tick=9
   s.traj=0.85
  end
 end
 _grav(s)
end

function _dspr(s)
 if(not s.inv or s.inv%5==0)then
  if(s.alt)then
   for i=1,#s.alt-1,2 do
    pal(s.alt[i],s.alt[i+1])
   end
  end
  if(s.anim)then
   snum=_gfrm(s) 
  else
   snum=s.snum
  end
  hx=s.x
  hy=s.y
  if(fget(snum,4))then
   hy+=1
  end
  if(fget(snum,5))then
   hx+=1
  end
  for i=0,#s.heads-1 do
   if(fget(snum,i))then
    if(s.halt)then
     pal(s.halt[1],s.halt[2])
    end
    _dhead(s.heads[i+1],hx,hy,s.h,s.helm)
    if(s.halt)then
     pal()
     palt(0,false)
     palt(1,true)
     pal(s.alt[1],s.alt[2])
    end
    break
   end
  end
  spr(snum,s.x,s.y+8,s.wdt,s.hgt-1,s.h,s.f)
  if(s.alt)then
   pal()
   palt(0,false)
   palt(1,true)
  end
 end
end

function _dhead(h,x,y,hh,helm)
 if(hh)then x+=h[5] end
 sspr(h[1],h[2],12,12,x+h[3],y+h[4],
      12,12,hh,false)
 if(helm)then
  sspr(116,32,12,10,x+h[3],y+h[4]-5,
      12,10,hh,false)
 end
end

function _ianim(fr,spd,kill)
 a={}
 a.fr=fr
 a.tick=spd
 a.spd=spd
 a.f=1
 a.kill=kill
 a.dead=false
 return a
end

function _sanim(s,a)
 if(s.anim)then
  s.anim.f=1
  s.anim.tick=s.anim.spd
  s.anim.dead=false
 end
 s.anim=a
end

function _gfrm(s)
 fr=s.anim.fr[s.anim.f]
 if(type(fr)!="number")then
  don=fr[2]
  if(s.h)then
   donx=s.x-(don[5]-14)
  else
   donx=s.x+don[5]+don[7]
  end
  sspr(don[1],don[2],don[3],don[4],
       donx,s.y+don[6],don[3],don[4],
       s.h,s.v)
  fr=fr[1]
 end
 return fr
end

function _uanim(a)
 if(not a.dead)then
  if(a.tick==0)then
   a.tick=a.spd
   a.f+=1
   if(a.f>#a.fr)then
    a.f=1
    if(a.kill)then
     a.dead=true
    end
   end
  else
   a.tick-=1
  end
 end
end

function _grav(s)
 s.y+=3
 sq=_gsq(s.x,s.y+(s.hgt*7))
 if(not fget(sq,0))then
  sq=_gsq(s.x+15,s.y+(s.hgt*7))
 end
 if(not s.pc and fget(sq,5) and not s.h)then
  s.state=s_jmp
  s.anim=s.jmp
  s.th=not s.h
  s.traj=0.84
  s.tick=9
 elseif(fget(sq,7) and s.state != s_rec)then
  if(s.die)then
   sfx(1)
   s.die-=4
  else
   return true
  end
 elseif(fget(sq,0))then
  s.y=flr(s.y/8)*8
  if(s.state==s_drop or s.state==s_kck)then
   s.state=s_idle
  end
 elseif(s.state!=s_jmp and s.state!=s_fall and s.state!=s_rec and s.state!=s_kck and s.state!=s_jup)then
  s.state=s_drop
 end
end

function _drop(s,d)
 sq=_gsq(s.x,s.y+(s.hgt*8))
 if(fget(sq,d))then
  s.y+=7
  s.state=s_drop
  if(s.pc)then
   sfx(3)
  end
 end
end

function _xdir(s,h,mod)
 if(h)then
  return s.x+mod
 else
  return (s.x+(s.wdt*8))-mod
 end
end

function _hit(e,s)
 if((not e.inv or e.inv<=0) and e.state!=s_rec and e.state!=s_fall)then
  e.thero=nil
  if(e.boss)then
   sfx(5)
  elseif(s.back)then
   sfx(1)
   e.state=s_hit
   _sanim(e,e.hit)
   e.dmg+=4
   e.die-=0.5
   e.th=s.h
  elseif(e.dodge and flr(rnd(4))==0)then
   sfx(5)
   e.state=s_jmp
   _sanim(e,e.jmp)
   e.th=not s.h
   e.traj=0.91
   e.tick=9
  else
   sfx(1)
   e.state=s_hit
   _sanim(e,e.hit)
   e.dmg+=1
   e.die-=0.5
   e.th=not s.h
  end
 end
 if(e.die<0)then
  e.die=0
 end
 if(e.state==s_hit)then
  x=flr(rnd(4))
  y=flr(rnd(4))+5
  _ifx(x+(_xdir(e,e.h,5)-4),e.y+y)
  if(s.pnum==0)then
   if(e.die<=0)then
    score1+=100
   elseif(e.dmg>3)then
    score1+=50
   else
    score1+=10
   end
  elseif(s.pnum==1)then
   if(e.die<=0)then
    score2+=100
   elseif(e.dmg>3)then
    score2+=50
   else
    score2+=10
   end
  end
 end
end

function _khit(e,s)
 if((not e.inv or e.inv<=0) and e.state!=s_rec and e.state!=s_fall)then
  e.thero=nil
  if(e.helm)then
   s.dmg+=4
   s.die-=1
   s.th=s.h
   sfx(1)
  elseif(e.dodge and flr(rnd(4))!=0)then
   e.state=s_jmp
   sfx(5)
   _sanim(e,e.jmp)
   e.th=not s.h
   e.traj=0.91
   e.tick=9
  elseif(e.boss)then
   if(e.state != s_rec and e.state != s_shoot)then
    if(s.y+4<e.y)then
     sfx(2)
     e.dmg+=4
     e.die-=1
     e.state=s_hit
    end
   end
  else
   sfx(1)
   e.dmg+=4
   e.die-=1
   e.state=s_hit
  end
 end
 if(e.die<0)then
  e.die=0
 end
 if(s and e.state==s_hit)then
  x=flr(rnd(4))
  y=flr(rnd(4))
  _ifx(x+(_xdir(e,e.h,5)-4),e.y-y)
  if(s.pnum==0)then
   if(e.die<=0)then
    score1+=100
   elseif(e.dmg>3)then
    score1+=50
   end
  elseif(s.pnum==1)then
   if(e.die<=0)then
    score2+=100
   elseif(e.dmg>3)then
    score2+=50
   end
  end
 end
end

function _fall(s)
 _traj(s,s.th)
 if(s.tick==0)then
  s.state=s_rec
  s.tick=10
 else
  s.tick-=1
 end
end

function _traj(s,h)
 if(h)then 
  s.x += cos(s.traj) * s.tick
  if(s.x>cx+64)then
   s.x=cx+64
  end
 else
  s.x -= cos(s.traj) * s.tick
  if(s.x<cx-cp)then
   s.x=cx-cp
  end
 end
 s.y -= sin(s.traj) * s.tick
end

function _jmp(s)
 _traj(s,(s.th))
 if(s.tick==0)then
  s.state=s_drop
  s.tick=10
  if(s.dodge)then
   s.state=s_shoot
   _sanim(s,s.pnch2)
  end
 else
  s.tick-=1
 end
end

function _kck(s)
 e=_gay(_xdir(s,s.h,6),s.y+14,es)
 if(e and e.state!=s_fall)then
  _khit(e,s)
 end
 if(s.tick>0)then
  s.tick-=1
  _traj(s,(not s.h))
 end
end

function _jup(s)
 s.y-=7
end

function _rec(s)
 if(s.tick==0)then
  s.state=s_idle
  _sanim(s,nil)
  if(s.inv)then
   if(s.pc)then
    s.inv=60
   elseif(not s.boss)then
    s.inv=30
   end
  end
  if(s.die<=0)then
   s.dead=true
  elseif(s.ronai)then
   s.state=s_shoot
   _sanim(s,s.shoot)
  end
 else
  s.tick-=1
 end
end
-->8
--map
lvl=1
mp={}
bg={}
dc={}
bg2=0
lv3t=30
boss=nil
endboss=true
bossmsg=nil
ml=-8
mr=135
scrl=true
tick=6
frame=0
ninjalvl=0

function _ilvl()
 mp={}
 bg={}
 drops={}
 cx=50
 es={}
 estick=64
 esright=false
 s_stp=0
 if(hero)then
  hero=_hero(0)
  if(lvl==4)then
   hero.y=24
   hero.x+=24
  end
 end
 if(hero2)then
  hero2=_hero(1)
  hero2.y=24
 else
  hero2=nil
 end
 for x=ml,mr do
  mp[x]={}
  for y=0,9 do
   if(y==9)then
    mp[x][y]=192
   else
    mp[x][y]=194
   end
  end
 end
 if(lvl==1)then
  _icity()
  music(1)
  scrl=true
  bg.on=true
  endboss=true
  ninjalvl=1
 elseif(lvl==2)then
  _iind()
  music(1)
  ninjalvl=2
  bg.on=true
  endboss=true
 elseif(lvl==3)then
  _igme()
  wofl=1
  music(1)
  scrl=false
  bg.on=false
  endboss=false
  ninjalvl=2
 elseif(lvl==4)then
  _ivec()
  scrl=true
  music(1)
  bg.on=true
  endboss=true
  ninjalvl=2
 elseif(lvl==5)then
  _iwall()
  ninjalvl=3
  music(1)
  endboss=true
  bg.on=true
 elseif(lvl==6)then
  _icas()
  music(1)
  endboss=true
  bg.on=true
 elseif(lvl==7)then
  _iphs()
  music(1)
  endboss=true
  bg.on=false
 end
end

function _icity()
 _ibg(0,0,24,0,13)
 boss=_enemy(1024,48)
 boss.alt={12,14,6,7,2,14,13,7}
 boss.dodge=true
 boss.die=8
 boss.hb=8*8
 boss.inv=8
 bossmsg={
          {"you wanna save the president",
           "huh? wwwelll..."},
          {"the hilary for president",
           "ninjas have a prob with that!"}
         }
 for x=ml,mr do
  for y=0,8 do
   if(y==3)then
    mp[x][y]=200+flr(rnd(3))
   elseif(y==4)then
    mp[x][y]=200+flr(rnd(2))
   elseif(y>5)then
    mp[x][y]=199
   elseif(y==5)then
    mp[x][y]=193
   end
  end
 end
 _smad(192,0,0)
 _truck(48,true)
end

function _smad(snum,y,sx)
 _mad(0,y,snum,sx,120,7,7)
 for i=0,16,8 do
 _mad(31+i,y,snum,sx,120,7,7)
 _mad(64+i,y,snum,sx,120,7,7)
 end
 _mad(88,y,snum,sx,120,7,7)
 _mad(120,y,snum,sx,120,7,7)
end

function _iind()
 _ibg(8,0,24,8,13)
 boss=_ron(1000,48)
 boss.inv=8
 bossmsg={
 {"making a cheap parody game of",
  "bad dudes and not even giving"},
 {"ol' ron a call? i was the star",
  "of that game!"},
 {"well i'm back anyway! and i got",
  "an upgrade! ron-bot go!!!"}
 }
 for x=ml,mr do
  for y=0,8 do
   if(y==0)then
    mp[x][y]=233
   elseif(y==4)then
    mp[x][y]=227+(flr(rnd(2))*7)
   elseif(y==7)then
    mp[x][y]=231+flr(rnd(2))
   elseif(y>5)then
    mp[x][y]=226
   elseif(y==5)then
    mp[x][y]=224
   end
  end
 end
 _smad(223,1,16)
end

function _iwall()
 _ibg(0,4,24,0,13)
 boss=_ron(1000,48)
 boss.inv=8
 bossmsg={
 {"back again! well actualy..",
  "i'm just a placeholder until"},
 {"the devs sort out the real",
  "boss!"},
 {"its kinda demeaning really!",
  "ron-bot go!!!"}
 }
 for x=ml,mr do
  for y=0,8 do
   if(y==1)then
    mp[x][y]=182
   elseif(y==5)then
    mp[x][y]=183
   elseif(y>0)then
    if(flr(rnd(3))!=0 or y>3)then
     mp[x][y]=flr(rnd(6))+176
    end
   end
  end
 end
 _smad(175,1,24)
end

function _igme()
 _ibg(0,0,48,0,13)
 boss=_ron(1000,48)
 boss.inv=8
 bossmsg=nil
 for x=ml,mr do
  for y=0,9 do
   mp[x][y]=194
   if(y==9)then
    mp[x][y]=160
   elseif(y==0)then
    mp[x][y]=224
   elseif(y==1 and x%4==0)then
    mp[x][y]=165
   elseif(y==8)then
    mp[x][y]=161
   elseif(y==5)then
    mp[x][y]=163
   elseif(y>5)then
    mp[x][y]=162
   end
  end
 end
 _wofboard(3,3)
end

function _ivec()
 _ibg(0,4,40,8,13)
 boss=_enemy(970,0)
 boss.alt={12,5,2,5}
 boss.inv=8
 boss.dodge=true
 boss.die=12
 boss.hb=12*8
 boss.h=true
 bossmsg={
 {"you wanna save the president",
 "huh? wwwelll..."},
 {"ain't payin for no steenking",
  "wall ninjas ain't havin' that!"}
 }
 for x=ml,mr do
  mp[x][9]=222
 end
 for i=0,9 do
 _truck(i*14)
 end
end

function _icas()
 _ibg(0,0,24,0,13)
 boss=_ron(1000,48)
 boss.inv=8
 bossmsg={
 {"and again! actualy this whole",
  "level is a placeholder!"},
 {"its supposed to be a casino",
  "level!"},
 {"get of your keisters devs!",
  "ron-bot go!!!"}
 }
 for x=ml,mr do
  for y=0,9 do
   if(y==3)then
    mp[x][y]=200+flr(rnd(3))
   elseif(y==4)then
    mp[x][y]=200+flr(rnd(2))
   elseif(y>5)then
    mp[x][y]=199
   elseif(y==5)then
    mp[x][y]=193
   end
  end
 end
 _smad(192,0,0)
 _truck(48)
end

function _iphs()
 _ibg(0,0,74,0,2)
 boss=_osama(1000,48)
 boss.inv=8
 bossmsg={
 {"pres. trump: help!","help!"},
 {"its worser than anyone",
  "thought!"},
 {"they saved bin ladens brain!"}
 }
 add(dc,_ispr(104,990,56))
 for x=ml,mr do
  for y=0,9 do
   if(y==9)then
    mp[x][y]=144
   elseif(y==0)then
    mp[x][y]=151
   end
  end
 end
 for i=0,127,16 do
  _mad(i,1,144,32,120,7,7)
  _mad(i+8,1,144,40,120,7,7)
 end
end

function _ibg(x,y,ry,yo,c)
 bg={}
 bg.c=c
 bg.x=x
 bg.y=y
 bg.ry=ry
 bg.yo=yo
end

function _dbg()
 rectfill(0,24,127,bg.ry+24,bg.c)
 camera((cx-cp)/6,-24)
 if(bg.on)then
  for i=0,256,64 do
   map(bg.x,bg.y,i,bg.yo,8,4)
  end
 end
end

function _mad(bx,by,snum,sx,sy,w,h)
 for x=0,w do
  for y=0,h do
   if(bx+x<128)then
    c=sget(sx+x,sy+y)
    if(c!=0)then
     mp[bx+x][by+y]=snum+c
    end
   end
  end
 end
end

function _truck(bx,jmp)
 _mad(bx,5,207,8,120,8,3)
 _mad(bx+8,5,207,8,124,4,3)
 mp[bx+8][6]=235
 mp[bx+8][7]=235
 mp[bx+9][6]=236
 mp[bx+9][7]=236
 if(jmp)then
  mp[bx+12][6]=237
  mp[bx+11][5]=200
  mp[bx+12][5]=200
 end
end

function _umap()
 if(cx<944)then
  _spawn()
 end
 if(boss)then
  if(endboss and cx==944 and #es==0)then
   _aboss()
   endboss=false
  end
 end
 if(tick==0)then
  tick=6
  if(frame==0)then
   frame=1
  else
   frame=0
  end
 else
  tick-=1
 end
end

function _dmap()
 for x=0,mr-8 do
  for y=0,9 do
   if(frame==1)then
    if(fget(mp[x][y],4))then
     pal(12,7)
     pal(7,12)
    end
   end
   if(fget(mp[x][y],6))then
    spr(mp[x][y]+frame,x*8,y*8)
   else
    spr(mp[x][y],x*8,y*8)
   end
   if(frame==1 and fget(mp[x][y],4))then
    pal()
    palt(0,false)
    palt(1,true)
   end
  end
 end
 for i in all(dc) do
  spr(i.snum,i.x,i.y,2,2)
 end
end

function _gsq(x,y)
 return mp[flr(x/8)][flr(y/8)]
end


-->8
s_idle=0
s_lup=3
s_jup=4
s_drop=5
s_knl=6
s_jmp=7
s_kck=8
s_pnch=9
s_hit=10
s_fall=11
s_rec=12
s_shoot=13
s_btn=true

--input
function _input(s,pnum)
 if(not btn(5,pnum) and not btn(4,pnum))then
  s_btn=true
 end
 if(s.state==s_idle)then
  s.anim=nil 
  if(btn(4,pnum) and s_btn)then
   s_btn=false
   s.state=s_jmp
   s.anim=s.jmp
   s.th=not s.h
   sfx(3)
   if(btn(0,pnum) or btn(1,pnum))then
    s.traj=0.84
    s.tick=9
   else
    s.traj=0.75
    s.tick=9
   end
  elseif(btn(5,pnum) and s_btn)then
   s.state=s_pnch
   s_btn=false
   if(s.hits==3)then
    s.hits=0
    s.low=true
    s.anim=s.pnch2
   elseif((btn(0,pnum) and not s.h) or (btn(1,pnum) and s.h))then
    s.hits=0
    s.anim=s.pnch3
    s.back=true
   else
    s.anim=s.pnch1
   end
  elseif(btn(5,pnum) and ((btn(0) and not s.h) or (btn(1,pnum) and s.h)))then
    s.state=s_pnch
    s.hits=0
    s.anim=s.pnch3
    s.back=true
  elseif(btn(0,pnum) and s.x>cx-cp)then
   s.anim=s.walk
   s.x-=1
   s.h=true
  elseif(btn(1,pnum) and s.x<cx+64)then
   s.anim=s.walk
   s.x+=1
   s.h=false
  elseif(btn(2,pnum))then
   s.state=s_lup
   s.anim=s.lup
  elseif(btn(3,pnum))then
   s.state=s_knl
   s.anim=s.knl
  end
 elseif(s.state==s_lup)then
  if(not btn(2,pnum))then
   s.state=s_idle
   s.anim=nil
  elseif(btn(4,pnum))then
   s.state=s_jup
   s.anim=s.jup
   sfx(3)
  end
 elseif(s.state==s_jmp)then
  if(btn(5,pnum))then
   s.state=s_kck
   s.anim=s.kck
  end
 elseif(s.state==s_jup)then
  if(not s.anim)then
   s.state=s_drop
  end
 elseif(s.state==s_knl)then
  d=_gay(s.x+7,s.y+14,drops)
  if(d)then
   if(d.snum==96 or d.snum==97)then
    if(s.die<4)then
     if(d.snum==96)then
      s.die=4
     else
      s.die+=1
     end
     if(s.die>4)then
      s.die=4
     end
     sfx(6)
    else
     sfx(5)
    end
   elseif(d.snum==127)then
    if(pnum==0 and up1<5)then
     up1+=1
     sfx(6)
    elseif(pnum==1 and up2<5)then
     up2+=1
     sfx(6)
    else
     sfx(5)
    end
   elseif(d.snum==166)then
    _uwofb()
    sfx(6)
   end
   del(drops,d)
   d=nil
  end
  if(not btn(3,pnum))then
   s.state=s_idle
  elseif(btn(4,pnum))then
   _drop(s,1)
  end
 elseif(s.state==s_pnch)then
  if(not s.anim)then
   if(s.back)then
    e=_gay(_xdir(s,not s.h,-4),s.y+8,es)
   else
    e=_gay(_xdir(s,s.h,2),s.y+8,es)
   end
   if(e)then
    s.hits+=1
    _hit(e,s)
   else
    s.hits=0
    sfx(4)
   end
   s.low=false
   s.back=false
   s.state=s_idle
  end
 elseif(s.state==s_hit)then
  if(not s.anim)then
		 s.state=s_idle
  end
 end
end
-->8
--evil
drops={}
bt={}
es={}
fx={}
estick=64
esright=false

function _spawn()
 if(lv3t<=0)then
  lv3t=30
 else
  lv3t-=1
 end
 if(#es<2 and (cx>=estick or (lvl==3 and lv3t<=0 and #drops<2)))then
  estick+=24
  if(lvl==4)then
   y=16
  else
   y=24+(flr(rnd(2))*31)
  end
  if(esright and flr(rnd(3))==0)then
   _ades(cx-64,y)
   esright=false
  else
   _ades(cx+80,y)
   esright=true
  end
 end
end

function _abt(snum,x,y,h)
 b={}
 b.snum=snum
 b.x=x
 b.y=y
 b.h=h
 b.tick=128
 add(bt,b)
end

function _ubt(x,y)
 for i in all(bt) do
  if(i.h)then
   i.x-=2
  else
   i.x+=2
  end
  if(hero and _inside(i.x+3,i.y+3,hero))then
   _khit(hero)
   del(bt,i)
  elseif(hero2 and _inside(i.x+3,i.y+3,hero2))then
   _khit(hero2)
   del(bt,i)
  end
  i.tick-=2
  if(i.tick<0)then
   del(bt,i)
  end
 end
end

function _ifx(x,y)
 s=_ianim({112,113},2,true)
 s.x=x
 s.y=y
 add(fx,s)  
end

function _ufx()
 for i in all(fx) do
  _uanim(i)
  if(i.dead)then
   del(fx,i)
  end
 end
end

function _dfx()
 for i in all(fx) do
  snum=i.fr[i.f]
  spr(snum,i.x,i.y)
 end
end

function _dbt()
 for i in all(bt) do
  spr(i.snum,i.x,i.y,1,1,i.h,false)
 end
end

function _ades(x,y)
 e=_enemy(x,y)
 if(flr(rnd(4))==0)then
  e.helm=true
 end
 if(flr(rnd(4))==0)then
  e.alt={12,3,6,11,2,3,13,11}
  e.die=3
 elseif(ninjalvl>1 and flr(rnd(3))==0)then
  e.alt={12,14,6,7,2,14,13,7}
  e.dodge=true
 elseif(ninjalvl>2 and flr(rnd(3))==0)then
  e.alt={12,5,2,5}
  e.dodge=true
  e.die=3
 end
 add(es,e)
end

function _aboss()
 if(not s_boss)then
  add(es,boss)
  s_boss=true
  msg=bossmsg
  p=8
 end
end

function _udrops()
 for i in all(drops) do
  if(_grav(i))then
   del(drops,i)
  end
 end 
end

function _ddrops()
 for i in all(drops) do
  spr(i.snum,i.x,i.y)
 end 
end

function _ues()
 for i in all(es)do
  _uspr(i)
  if(i.dead or i.x<cx-128)then
   if(s_boss)then
    s_lvl=true
    s_boss=false
    p=30
   elseif(lvl==3)then
    _drops(i,166)
   else
    _drops(i)
   end
   del(es,i)
  else
   if(i.p>0)then
    i.p-=1
   elseif(i.ronai)then
    _ronai(i)
   else
    _ai(i)
   end
  end
 end
end

function _des()
 for i in all(es)do
  _dspr(i)
 end
end

function _ai(s)
 if(not s.thero)then
  if(hero)then
   s.thero=hero
  elseif(hero2)then
   s.thero=hero2
  end
  if(hero2 and hero)then
   if(abs(hero2.x-s.x) < abs(hero.x-s.x))then
     s.thero=hero2
   end
  end
 end
 if(not s.thero and s.thero.state==s_fall or s.thero.state==s_rec)then
  s.thero=nil 
 else
  if(s.state==s_idle)then
   s.anim=nil
   e=_gay(_xdir(s,s.h,0),s.y+8,es,s)
   if(e)then
    if(e.x==s.x)then
     s.x+=2
     e=nil
    end
   end
   if(s.thero.y-8>s.y)then
    s.state=s_knl
    s.anim=s.knl
   elseif(s.thero.y+24<s.y)then
    s.state=s_lup
    s.anim=s.lup
   elseif(lvl==4 and s.thero.y<s.y and s.thero.state!=s_jmp and s.thero.state!=s_drop)then
    s.state=s_jmp
    s.anim=s.jmp
    s.th=not s.h
    s.traj=0.84
    s.tick=9
   elseif(s.thero.x+10<s.x)then
    s.h=true
    if(not e)then
     s.x-=1.2
     s.anim=s.walk
    end
   elseif(s.thero.x>s.x+10)then
    s.h=false
    if(not e)then
     s.x+=1.2
     s.anim=s.walk
    end
   end  
   if(_inside(_xdir(s,s.h,6),s.y+7,s.thero))then
    s.state=s_pnch
    s.p=4
    if(s.hits==3)then
     s.hits=0
     s.low=true
     s.anim=s.pnch2
    else
     s.anim=s.pnch1
    end
   end
  elseif(s.state==s_hit)then
   if(not s.anim)then
    s.p=4
    s.state=s_idle
   end
  elseif(s.state==s_pnch)then
   if(not s.anim)then
    s.p=8
    if(_inside(_xdir(s,s.h,6),s.y+7,s.thero))then
     s.hits+=1
     _hit(s.thero,s)
    else
     s.hits=0
    end
    s.low=false
    s.state=s_idle
   end
  elseif(s.state == s_shoot)then
   if(not s.anim)then
    _abt(111,s.x,s.y+7,s.h)
    s.state=s_idle
   end
  elseif(s.state==s_knl)then
   if(not s.anim)then
    _drop(s,0)
   end
  elseif(s.state==s_lup)then
   if(not s.anim)then
    s.state=s_jup
    s.anim=s.jup
   end
  elseif(s.state==s_jup)then
   if(not s.anim)then
    s.state=s_drop
   end
  end
 end
end

function _ronai(s)
 if(hero)then
  thero=hero
 elseif(hero2)then
  thero=hero2
 end
 if(hero2 and hero)then
  if(abs(hero2.x-s.x) < abs(hero.x-s.x))then
   thero=hero2
  end
 end
 if(s.state==s_rec and tick==0)then
  sfx(2)
  x=flr(rnd(16))
  y=flr(rnd(16))
  _ifx(s.x+x,s.y+y)
 else
  if(thero.x+8>s.x and thero.x+8<s.x+24 and
    thero.y+8>s.y and thero.y+8<s.y+24)then
   if(thero.h)then
    thero.x=s.x+16
   else
    thero.x=s.x-8
   end
  end
 end
 if(s.state==s_idle)then
  s.anim=nil
  if(thero.x+8<s.x)then
   s.h=true
   s.x-=0.6
   s.anim=s.walk
  elseif(thero.x-8>s.x)then
   s.h=false
   s.x+=0.6
   s.anim=s.walk
  end
  if(_inside(_xdir(s,s.h,-2),s.y+15,thero))then
   s.state=s_pnch
   s.anim=s.pnch1
  end
 elseif(s.state==s_pnch)then
  if(not s.anim)then
   if(_inside(_xdir(s,s.h,-2),s.y+15,thero))then
    _khit(thero,s)
   end
   s.state=s_idle   
  end
 elseif(s.state==s_shoot)then
  if(thero.x<s.x)then
   s.h=true
  else
   s.h=false
  end
  if(not s.anim)then
   _abt(77,_xdir(s,s.h,0),s.y+13,s.h)
   s.state=s_idle
   sfx(9)
  end
 end
end

function _gay(x,y,ay,s)
 for i in all(ay)do
  if(_inside(x,y,i))then
   if(i!=s)then
    return i
   end
  end
 end
end

function _inside(x,y,i)
 if(x>=i.x and x<=i.x+i.wdt*8 and
     y>=i.y and y<=i.y+i.hgt*8)then
   return true
  end
end

function _drops(s,snum)
 if(flr(rnd(3))==0 or snum)then
  d={}
  if(snum)then
   d.snum=snum
  elseif(flr(rnd(4))==0)then
   d.snum=96
  elseif(flr(rnd(10))==0)then
   d.snum=127
  else
   d.snum=97
  end
  d.x=s.x+7
  d.y=s.y
  d.hgt=1
  d.wdt=1
  add(drops,d)
 end
end
-->8
wofb={}
wofl=1
phrase="grab em  by the  pussy"
--extras
function _wofboard(bx,by)
 mp[bx][by]=169
 mp[bx+9][by]=170
 mp[bx][by+4]=171
 mp[bx+9][by+4]=172
 for x=bx+1,bx+8 do
  mp[x][by]=168
  mp[x][by+4]=173
 end
 for y=by+1,by+3 do
  mp[bx][y]=167
  mp[bx+9][y]=174
 end
 for y=by+1,by+3 do
 for x=bx+1,bx+8 do
   mp[x][y]=166
   add(wofb,{x,y})
  end
 end
end

function _uwofb()
 mp[wofb[wofl][1]][wofb[wofl][2]]=175
 if(wofl<24)then
  wofl+=1
 else
  s_lvl=true
  p=30
 end
end

function _dwofb()
 al=1
 for i in all(wofb) do
  if(mp[i[1]][i[2]]==175)then
   print(sub(phrase,al,al),(i[1]*8)+3,(i[2]*8)+2,0)
  end
  al+=1
 end
end
-->8
cpic="18,3,2,4,3,3,1,5,2,4,24,3,-1,0,16,3,1,15,4,4,1,15,1,4,1,7,1,4,1,7,2,4,1,5,21,3,-1,0,15,3,1,15,2,4,3,15,1,4,1,15,1,4,1,7,1,4,1,7,2,4,1,5,20,3,-1,0,15,3,14,4,1,5,20,3,-1,0,15,3,2,4,1,15,6,4,2,15,3,4,1,5,20,3,-1,0,15,3,2,4,9,15,1,4,1,15,1,4,1,5,20,3,-1,0,15,3,2,4,8,15,2,4,1,15,1,4,1,5,1,0,19,3,-1,0,15,3,2,4,2,15,1,4,2,15,1,4,3,15,3,4,1,5,3,0,17,3,-1,0,15,3,2,4,3,15,2,4,6,15,1,4,4,0,17,3,-1,0,15,3,1,4,1,2,3,4,2,2,3,4,2,2,1,4,1,15,1,4,3,0,17,3,-1,0,14,3,1,4,2,0,1,7,5,0,1,7,4,0,2,4,3,0,17,3,-1,0,14,3,3,0,1,7,1,0,1,4,1,15,1,4,1,0,1,7,3,0,1,5,1,0,1,7,1,5,2,0,17,3,-1,0,15,3,2,0,1,5,1,0,1,4,1,7,2,4,4,0,1,4,1,2,1,15,1,5,2,0,17,3,-1,0,15,3,1,5,2,0,1,2,1,15,1,7,2,4,1,13,1,5,1,2,2,4,1,15,1,4,2,0,18,3,-1,0,16,3,1,4,1,15,5,4,1,15,1,7,1,4,1,15,1,4,1,7,1,15,2,0,18,3,-1,0,16,3,1,4,1,7,1,15,3,4,5,15,2,4,3,0,18,3,-1,0,16,3,1,4,2,15,4,4,4,15,1,4,1,5,4,0,17,3,-1,0,16,3,1,4,5,15,2,4,1,15,1,7,2,4,1,5,5,0,16,3,-1,0,16,3,2,4,1,15,3,4,4,15,1,4,1,5,1,0,1,4,1,5,3,0,16,3,-1,0,16,3,1,2,1,4,6,15,2,4,2,5,1,0,1,4,1,15,1,4,3,0,15,3,-1,0,15,3,1,4,2,0,1,4,1,15,1,7,2,15,3,4,1,0,1,9,1,0,1,4,1,15,1,4,4,0,14,3,-1,0,14,3,1,4,1,15,1,0,1,4,1,0,5,4,2,0,2,4,1,0,1,4,1,15,2,4,4,0,13,3,-1,0,13,3,2,4,1,7,1,0,1,4,7,0,1,4,1,15,1,4,1,0,1,4,2,15,1,4,4,0,13,3,-1,0,12,3,1,5,1,4,1,7,1,15,1,5,2,4,6,0,1,4,1,15,1,4,1,0,3,15,1,4,1,5,5,0,11,3,-1,0,12,3,1,5,1,15,1,4,1,7,1,4,1,0,1,9,1,0,2,14,2,4,1,0,1,4,1,15,1,4,1,0,4,15,1,4,1,0,1,4,1,5,1,3,3,0,9,3,-1,0,11,3,2,4,2,15,1,4,1,15,1,0,1,9,1,2,1,15,1,7,1,14,1,4,1,0,1,4,1,7,1,4,1,0,1,4,1,15,1,4,1,15,1,4,4,0,2,5,4,0,6,3,-1,0,9,3,1,5,2,0,1,7,4,15,1,2,1,0,2,4,3,15,1,0,1,4,1,15,1,4,1,0,1,4,3,15,1,4,1,5,1,4,1,5,1,0,1,5,1,0,2,4,4,0,4,3,-1,0,7,3,1,5,3,0,1,4,1,15,1,4,1,7,1,4,2,15,1,4,1,0,4,4,1,0,2,15,1,0,1,4,1,15,1,4,3,15,1,5,1,0,2,5,1,0,1,4,2,5,1,4,1,0,1,4,2,0,3,3,-1,0,4,3,1,5,3,0,1,4,2,0,1,4,2,15,1,4,2,15,3,4,1,0,1,15,2,4,1,0,1,4,1,15,1,0,1,4,1,15,1,7,1,4,2,15,1,5,2,0,1,5,1,4,1,5,1,0,1,5,1,0,1,4,4,0,2,3,-1,0,3,3,1,5,1,0,1,5,1,4,1,5,3,0,1,15,1,4,1,15,1,4,1,15,4,4,1,15,1,0,2,15,1,4,1,15,2,4,1,0,1,2,3,15,1,4,1,5,2,0,1,4,1,5,1,0,1,4,1,0,1,5,1,4,1,5,1,0,1,3,2,0,1,3,-1,0,1,3,2,0,2,5,2,0,1,5,2,4,1,0,1,2,3,15,2,4,3,0,2,4,1,0,2,4,1,15,1,0,1,4,3,0,3,4,1,13,1,0,2,5,1,0,2,5,1,0,1,5,1,4,1,5,4,0,1,3,-1,0,1,0,1,5,2,0,2,5,1,3,2,4,1,5,1,9,1,0,4,4,5,0,1,4,1,15,1,7,1,4,1,15,1,0,1,4,4,0,1,4,1,9,1,5,2,0,1,5,1,0,1,4,1,0,1,3,1,4,2,5,4,0,1,3,-1,0,2,0,1,4,1,0,1,5,1,3,1,5,1,3,1,5,1,3,2,4,6,0,2,5,5,0,1,3,1,0,1,5,1,0,1,5,6,0,1,4,1,0,1,4,4,0,2,4,5,0,-1,0,2,0,1,4,1,5,1,4,2,0,5,3,1,4,2,0,2,5,2,0,1,4,1,5,2,0,1,5,1,4,2,5,1,0,1,5,2,4,5,0,1,5,1,0,1,5,3,0,1,4,1,5,1,4,5,0,-1,0,2,0,1,5,1,4,2,0,1,3,1,0,5,3,2,4,1,5,1,3,2,0,1,4,1,3,1,5,1,0,2,3,2,5,1,0,2,4,1,5,1,0,1,5,2,0,1,4,6,0,2,5,1,4,5,0,-1,0,1,0,2,4,1,3,2,0,1,3,1,0,5,3,1,5,1,4,1,5,1,3,2,0,1,4,1,3,1,4,1,0,2,3,1,0,1,3,1,0,2,4,1,0,1,5,1,3,1,5,1,0,1,4,5,0,1,5,1,4,1,5,1,4,4,0,"
tfont="1,13,1,0,3,9,1,13,1,0,3,9,1,13,1,0,3,9,1,13,1,0,3,9,1,13,1,0,4,9,1,0,4,9,1,0,5,9,2,13,1,0,3,9,1,13,1,0,3,9,1,13,1,0,3,9,3,13,1,0,5,9,1,13,1,0,2,9,1,13,1,0,2,9,1,0,5,9,1,13,1,0,4,9,1,13,1,0,4,9,1,13,-1,0,1,13,1,0,3,9,1,13,1,0,3,9,1,13,1,0,3,9,1,13,1,0,3,9,3,13,1,0,2,9,1,0,2,9,3,0,2,9,1,0,3,9,1,13,1,0,3,9,1,13,1,0,3,9,1,13,1,0,3,9,3,13,1,0,2,9,1,0,3,9,1,0,2,9,1,13,1,0,2,9,1,0,2,9,1,0,3,9,1,0,2,9,3,0,2,9,2,0,2,9,-1,0,1,0,4,9,1,13,1,0,3,9,1,0,4,9,1,0,4,9,2,13,1,0,3,9,1,0,2,9,2,13,1,0,2,9,1,13,1,0,2,9,1,0,4,9,1,13,1,0,3,9,1,13,1,0,3,9,3,13,1,0,2,9,1,13,1,0,2,9,1,0,2,9,1,13,1,0,2,9,1,0,2,9,1,13,1,0,2,9,1,0,2,9,2,13,1,0,2,9,1,13,1,0,2,9,-1,0,1,0,2,9,1,0,1,9,1,13,1,0,3,9,1,0,4,9,1,0,2,9,1,0,1,9,2,13,1,0,3,9,1,0,2,9,2,13,1,0,2,9,1,0,3,9,1,0,2,9,1,0,1,9,1,13,1,0,3,9,1,13,1,0,3,9,3,13,1,0,2,9,1,13,1,0,2,9,1,0,2,9,1,13,1,0,2,9,1,0,2,9,1,13,1,0,2,9,1,0,2,9,2,13,1,0,2,9,4,13,-1,0,1,0,2,9,1,0,1,9,1,13,1,0,3,9,1,0,1,9,1,0,2,9,1,0,2,9,1,0,1,9,2,13,1,0,2,9,2,0,4,9,1,0,4,9,3,0,2,9,1,0,1,9,1,13,1,0,3,9,1,13,1,0,3,9,3,13,1,0,2,9,1,13,1,0,2,9,1,0,2,9,1,13,1,0,2,9,1,0,2,9,1,13,1,0,2,9,1,0,4,9,1,0,5,9,1,13,-1,0,1,0,2,9,1,0,1,9,1,13,1,0,2,9,1,0,2,9,1,0,2,9,1,0,2,9,1,0,1,9,2,13,1,0,2,9,1,13,1,0,2,9,3,0,2,9,1,0,3,9,1,0,2,9,1,0,1,9,1,13,1,0,3,9,1,13,1,0,3,9,3,13,1,0,2,9,1,13,1,0,2,9,1,0,2,9,1,13,1,0,2,9,1,0,2,9,1,13,1,0,2,9,1,0,2,9,2,0,2,13,1,0,4,9,-1,0,1,0,2,9,1,0,1,9,1,13,1,0,2,9,1,0,2,9,1,0,2,9,1,0,2,9,1,0,1,9,1,13,1,0,3,9,1,13,1,0,2,9,2,13,1,0,2,9,1,13,1,0,2,9,1,0,2,9,1,0,1,9,1,13,1,0,3,9,1,13,1,0,3,9,3,13,1,0,2,9,1,13,1,0,2,9,1,0,2,9,1,13,1,0,2,9,1,0,2,9,1,13,1,0,2,9,1,0,2,9,6,13,1,0,2,9,-1,0,1,0,5,9,1,0,2,9,1,0,2,9,1,0,2,9,1,0,5,9,1,0,2,9,1,0,1,13,1,0,2,9,2,13,1,0,2,9,1,13,1,0,2,9,1,0,5,9,1,0,3,9,1,13,1,0,3,9,3,13,1,0,2,9,1,13,1,0,2,9,1,0,2,9,1,13,1,0,2,9,1,0,2,9,1,13,1,0,2,9,1,0,2,9,2,13,1,0,2,9,1,13,1,0,2,9,-1,0,1,0,2,9,1,0,2,9,1,0,2,9,1,0,2,9,1,0,2,9,1,0,2,9,1,0,2,9,1,0,2,9,2,13,1,0,2,9,2,13,1,0,2,9,1,0,3,9,1,0,2,9,1,0,2,9,1,0,3,9,1,13,1,0,3,9,3,13,1,0,2,9,1,0,3,9,1,0,2,9,1,0,3,9,1,0,2,9,1,0,3,9,1,0,2,9,2,13,1,0,2,9,1,13,1,0,2,9,-1,0,1,0,2,9,1,0,2,9,1,0,2,9,1,0,2,9,1,0,2,9,1,0,2,9,1,0,2,9,1,0,4,9,1,0,4,9,1,0,5,9,1,13,1,0,2,9,1,0,2,9,1,0,4,9,1,0,4,9,2,13,1,0,5,9,2,13,1,5,4,9,1,13,1,0,5,9,1,13,1,0,4,9,1,13,1,0,4,9,"

introi=1
intro=
{
{"the president has been ",
 "kidnapped by isis ninjas.",
 "     ",
 "are you an amazeballs dude",
 "enough to rescue the",
 "president?"},
{"are you sure? it's been",
 "nice and quiet around here",
 "since he's been gone.",
 "    ",
 "i've taken up knitting..",
 "yeah, guys can knit too",
 "bud. welcome to the 21st",
 "century!"}
}

clear=
{
 {"well done dudes! you've",
  "saved the pres. that was",
  "truly amazeballs!",
  "     ",
  "president trump says you",
  "guys are really, great",
  "almost as great as he is!",
  "     ",
  "he's taking you both out",
  "for burgers!"}
}

contgag={"press a button",
         "no the other one",
         "press the button"}

function pstray(s)
 ay={}
 i=1
 num=""
 while(i<=#s) do
  z=sub(s,i,i)
  if(z==",")then
   if(num=="-1")then
    add(ay,-1)
   else
    add(ay,(num+0))
   end
    num=""
  else
   num=num..z
  end
  i+=1
 end
 return ay
end

function _dpic(sx,sy,pic,pnum)
 x=sx
 y=sy
 for i=1,#pic,2 do
  if(pic[i]==-1)then
   y+=1
   x=sx
  else
   for j=x,x+pic[i]-1 do
    if(pnum and pnum==pic[i+1])then
    else
     pset(j,y,pic[i+1])
    end
   end
   x+=pic[i]
  end
 end
end
__gfx__
11000111111000111111100111111111111111111111111111111111111111111100111111111001110011111111000011111111111111111110111111111111
109f00011100c601111109f000011111111100111111111111111000111111111090011111110c601090011111109f0611111100010011111109011111111111
09ff0c600000c60111109ff0c901111111109f0000001111111110f900001111090c600111000c60090c601111009f0c1111110cc090000110f9900101100111
09f00c609c00001111109f00060111111109ff0c96000111111110fff0c601110f0c6000000990010f0c6000000000001111110c09ff0c6010f9900090009011
09fff00c6009f011111100c6001111111109f000c60601111111100ff0c6011109f000cc6000011109f000cc6001111111111000009f0c601000000c0c60c011
109f0c000c000111111110c60011111111100c60006c0111111100c0000011111000cc000c0111111000cc000c011111111100cc0000100110cc0c000c000111
11000000000111111111110001111111110c0c60000011111110c00000001111111000000001111111100000000111111110c000100011111066000000001111
11106c010c6011111111110c601111111110c0010cc0111111110c0110c6011111106c010c60111111106c010c60111111110c0110c6011111006c010c601111
1000d0011011111109990001101111111100111110001111111111111110c6011111111111110011111111111111111111001111110011111001111111100011
022772200900111190f707f009001111109f011110c60111110000011110c601110000011110c60111000111111000111090011110c6011106c000011100c601
022702080d0d011190f777f00606011109ff000900c60111109f0c6000000011109f0c600000c601109f00011100c601090c600110c6011106c00c000000c601
022292080d02201190f77700060cc01109f00c60c000011109f90ccc9c09901109f90ccc9c09001109ff0c600000c6010f0c60000000101110090ccc9c000011
022702220000011190f707f00000011109ff0c60c009011109f000cc6c00011109f000cc6c00111109f00c609c00001109f000cc600006011100000c6009f011
0d277220dd001111f0ff77f066001111109ff0000c00011110c600000000111110c600000000111109fff00c6009f0111000cc000ccc0c0111110c000c000111
0d22d220220d01119f099ff0cc060111110000000001111110c60c00000c011110c60c00000d0111109f000000000111111100c6000000111111000000011111
10dd2200f902201100009001f90cc0111106c010c6011111110010c010c0111111000d0110c0111111006c010c601111111111001111111111106c010c601111
11110001001111110000111110110101110111110000f00111100000011111000000111110000001111111111111111100000011111000000111111111111111
1110ff900f01111009ff011109009090009011109fff9900110dd2222011102d222d01110dd22220111100000011111005556501110055565011111111111111
1109999999901109f999f0010999f9999901110f0099900110d22222201102d222220110d22222201110d2222201110500555601105000000011111111111111
109f00099901109f0099999009ff0000090110f09f000f0110d222222011022222220110d27727701110d20202011100ff0000011009ffff9011111111111111
10909ff0000110909f0009010909fffff0011090ff0f0f01102d90909d110222970901102d70907d110d290909d1110099fff901100977f77011111111111111
1090ff0f0f011090ff709011090ff7777f011090ff0f0f0110222222201110222222011022222220110d222222011109ff090f01109f70f07011111111111111
110fff0f0f011109ff70f011109f707707011109ffffff0110022222201111022222011002220020110d222222011109f99f9901109f99f99011111111111111
1100ffffff011110fffff011110f777777011110fffff011110002220011110022201111000288011110222222011110f9fff901110f9fff9011111111111111
111000fff001111000ff0011110fff0ff01111110000001111111000011111110001111111100001111100000011111109f0f01111109f0f0111111101100001
1111110000111111110011111110ffff0111111111111111111111111111111111111111111111111111111111111111109f901111110989011111116010d701
1111111111111111111111111111000011111111111111111111111111111111111111111111111111111111111111111100011111111000111111116010d701
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110110d701
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110d701
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100001
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1110000000d011110000011111111111111111111111111111111111111111111111111111111111111111111111111111111111118188811111111110111111
110778d07d0d01110d8770111110000000d01111000001111110000000d01111000001111110000000d011110000011111111111111899981111111107011111
110780d07dd0d00000087011110778d07d0d01110d877011110778d07d0d01110d877011110778d07d0d01110d877011111111118189aaa98111111077601111
11007d00dd700000dd000000110788d07dd0d00000087011110780d07dd0d00000087011110780d07dd0d00000087011000011111189a7a98111111000001111
11100000dd07080b0d000d7011007d00dd700000dd00001111007d00dd700000dd00000011007d00dd700000dd0000000d7011111189aaa98111110bbb330111
11100000dd0000000d0d0d7011100000dd0808080d0001111110000000080b070d000d701100000000080b070d00777d0d70111188889998111110bbbbb33011
110dd0000077d7ddd0000d7011077dd0dd0000000d0d01111107d077777000000d0d0d70107d0777770000000d00dddd0d701111111188811111100000000011
107d07777700d7dd00000d701107dd00000707ddd00d0000110d077dddd707ddd0000d7010d077dddd7067ddd00000000d701111111811111111077767666601
10d077dddd700000000100001107d077777007dd000d0d70110707d7070d07dd00000d7010707d7070d067dd0000111100001111111111111111100000000011
10707d7070d00220d00111111100077dddd70000000d0d70110007dddddd00000001000010007dddddd000000001111111111111111111111111111111111111
10007dddddd00880d001111110d007d7070d0880d0000d7010d007d7070d0880d00111110d007d7070d00880d001111111111111111111111111111111111111
0d007d7070d07ddd00001111110707dddddd0ddd00000d701107d07dddd0dddd00011111107d07dddd0ddddd0000111111111111111111111111111111111111
107d07dddd0000007dd01111110d07d7070d00007dd0000011100000000000000011111111000000000000007dd0111111111111111111111111111111111111
11000100000111107dd011111110d07dddd011107dd01111111111110d70d7d0111111111111110d7d0111107dd0111111111111111111111111111111111111
11111070000011070000011111110000000011070000011111111110700700000111111111111070000011070000011111111111111111111111111111111111
1111107d77d01107d77d01111111107d77d01107d77d0111111111107d07d77d011111111111107d77d01107d77d011111111111111111111111111111111111
099ff9f017676551111111111dddddd111111dddddd1111111111111111111111111100000001111111111111110000000d01111000001111111111111111111
9fff9ff91888822111111111d771111d1111d771111d111111111111111111111111009afaa9011111111111110aa8d0ad0d01110d8aa0111111111100500000
ff9f9f9f187776611111111d71111711d11d7d1117d1d1111111111111111111111109a0000a901111111111110a80d0add0d0000008a0111111111166577777
4ffffff4188782211111111d11000711d11d1100071dd111111111111111111111110a099940af01111111111100ad00a00000d0dd0000001111111155566660
48b8bb84187876211111111d10e8e701d11d10d887d1d11111111111111111111111104090f4090111111111111000000aaaaa0b0d000da01111111100500001
94444449187772211111111d1eee8e81d11d18d88881d111111111111111111111111099ff9409011111111111100000aad888a00d0d0da01111111111111111
f999999f188882211111111dcdd2d72cd11dcd2d27dcd111111111111111111111001099fff9f001111111111110a550ad8aaa80d0000da01111111111111111
0ffffff0176765511111111dcc2dd7ccd11ddc222ddcd111111111111111111110ff009070f90901111111111110add0ad8a7a8000000da01111111111111111
11111111111711111111111dccccccccd11dcccccccdd11111111111111111111100009080f900011111111111100aa0ad8aaa80000100001111111111111111
11171111171717111111111d55555655d11d55555655d1111111111111111111110d09099990040111111111111110000ad88800d001111111111111b12a21b1
117771111171711111111111111111111111111111111111111111111111111111100000000000a0111111111111110000000000d001111111111111baaaaab1
17717711771117711111111111111111111111111111111111111111111111111111049494949a0111111111111111000000a88800001111111111111aaaaa11
117771111171711111111111111111111111111111111111111111111111111111109000000000a01111111111111107dd000000add01111111111111aaaaa11
11171111171717111111111111111111111111111111111111111111111111111104049499449a011111111111111107dd011110add0111111111111bbaaabb1
1111111111171111111111111111111111111111111111111111111111111111110900000000011111111111111110700000110a0000011111111111b11111b1
11111111111111111111111111111111111111111111111111111111111111111110406501056011111111111111107daad0110adaad011111111111b11111b1
55555555000055550005555555555555111110005555111151111111202222225555555522222222555555502222222011111114444222224111111122224444
56655665000056650006565656565656111100065656111151111111202e22222e2522522222222255252e502222222011111144442222224411111122222244
55555555000055550005555555555555111000000000011151111111202022222025222222222222252520202222222011111444222224224441111122422222
56655665000056650006565656565656110005555555511151111111202222222225222222222222222522202222222011114422222242222244111122242222
5555555500005555000555555555555511000556565655115111111120222222222222222e2222222222222022222e2011144222222222222224411122222222
56655665000056650006565656565656100055555555555151111111202222222222222220222222222222202222202011444222222422222224441122224222
55555555000055550005555555555555000556565656565555111111202222222222222222222222222222202222222014442222224222222222444122222422
56655665000056650006565656565656000000000000000000111111202222222222222200000000222222200000000044422222222222422222244424222222
0000000000a9044a90449400aaaaa9977994444400a9044a90449400aaaaaaaa028e8882028e2028e82202828282828299999999000000000000000000000000
9999999900a9044a90449400aaaaa9977994444400aa909a9909440044000004028e8882028e2028e82202828282828299999999000000000000000000000000
4444444400a9044a90449400000000000000000000aaa99a9994440090444440028e8882028e2028e82202828282828299999999000000000000000000000000
4444444400a9044a904494000aaaa99799944440000000000000000090900990028e8882028e2028e82202828282828299999999000000000000000000000000
0000000000a9044a9044940000000000000000000aaaa9979994444090900000028e8882028e2028e82202828282828299999999000000000000000000000000
9999999900a9044a9044940000aaa99a999444000000000000000000909aaaaa028e8882028e2028e82202828888888899999999000000000000000000000000
4444444400a9044a9044940000aa909a99094400aaaaa997799444440a000000028e8882028e2028e82202829292929299999999000000000000000000000000
4444444400a9044a9044940000a9044a90449400aaaaa9977994444444444444028e8882028e2028e82202829292929299999999000000000000000000000000
00000000999999990a900990999999998888888805100150000000000c70c7c00000000000000000000000000c70c7c00c7c07c0000000000c7c07c000000000
aaaaaaaa000000000a900a90aaaaaaaa2222222206055060033333330c70c7c0cccccccc0cccccccccccccc00c70c7cccc7c07c0cccccccc0c7c07c00ddddddd
99999999dddddddd0990099099999999000880000555555003b777b30c70c7c0777777770c777777777777c00c70c777777c07c0777777770c7c07c00d77777d
99999999dcd7dcd70a900a900009900000822800106aa60103bbb7b30c70c7c0000000000c700000000007c00c70cccccccc07c0cccccccc0c7c07c00d77777d
00000000dddddddd0a900a90aaaaaaaa0820028006a7796003bb77b30c70c7c0cccccccc0c70cccccccc07c00c700000000007c0000000000c7c07c00d77777d
aaaaaaaa0000000009900990999999998200002806a7796003bbbbb30c70c7c0777777770c70c777777c07c00c777777777777c0777777770c7c07c00d77777d
99999999aaaaaaaa0a900a9009400940222222221069960103bb7bb30c70c7c0cccccccc0c70c7cccc7c07c00cccccccccccccc0cccccccc0c7c07c00d77777d
999999999999999909900990094009408888888811000011033333330c70c7c0000000000c70c7c00c7c07c00000000000000000000000000c7c07c00ddddddd
00000000000000000000000000000000000000000000000011711171cccc07cc0000000000000000000000000000000000000000000000000000000000000000
0aaaaaa0077788800777fff0022222200bbbbbb00909999061656165dddddddd0000000000000000000000000000000000000000000000000000000000000000
0a0000a00788888007fffff0020000200b7770b00999909017111711000000000000000000000000000000000000000000000000000000000000000000000000
0a0000a00788888007f00ff0020770200b7bb0b00909999061116171dd07dd070000000000000000000000000000000000000000000000000000000000000000
0a0000a0088888800ff00ff0020770200b7bb0b00990990061116111dd0ddd0b0000000000000000000000000000000000000000000000000000000000000000
0a0000a0088888800ffffff0020000200b0000b00999999035563556000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaa0088888800ffffff0022222200bbbbbb000999090b6bbbb6b07dd07dd0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000333333330ddd0ddd0000000000000000000000000000000000000000000000000000000000000000
00000000666666661111111100000000000000000000000000b300b300b300b30000000000000000111111110000000033333333000000000000000000000000
55555555bbbbbbbb11111111056565500dddddd00dddddd000b300b30db30db3094409440044094411111111ffffffff36336333000000000000000000000000
666666663333333311111111055566500dc777d00dc707d000b300b300b300b30000000000000000111111114444444433333333000000000000000000000000
777777770005500011111111066565600dccc7d00d0000d000b300b355b355b34409440940094400010441090000000033333333000000000000000000000000
666666666666666611111111056656500dccccd00dc000d000b300b300b300b30000000000000000400000000f40440433333333000000000000000000000000
666666663333333311111111050566600dccccd00d0c07d000b300b30db30db30944094409440904094409440f404f0433333333000000000000000000000000
065006500035003511111111000650500dddddd00dddddd000b300b300b300b30000000000000000000000000f404f0433633363000000000000000000000000
00000000003500351111111100000000000000000000000000b300b355b355b34409440944094409440944090f40440433333333000000000000000000000000
000000001111111100000000065033b011111111033bbbbb0333333333b0bbbbbbbb0576b1111111111111115555555533333333000000000000000000000000
5555555500000000000b3333065033b0bbbb111103b000000366533333b03333333b0576b11111111111111166666666bbbbbbbb666666665055550505555055
600000065505555000000000065033b03333bb1103b000000300036666706766773b05763b111111111111115555555533333333555555557667666666766667
0006600077007770000b3333065033b0333333bb03b000000333333333b03333333b05760b111111111111116666666666666666666666667767776776777677
006665006606666000000000065033b00003333b03b000000366336363663366633b057603b11111111111615555555533333333555555550000000000000000
0066550055055550000b3333065033b0bbb0333b03b000000363636363606366333b057600bbbbbbbbbb057666666666bbbbbbbb666666660000000000000000
000550000000000000000000065033b030b0333b03b000000366333633663366603b057603b333333333057655555555bbbbbbbb555555550000000000000000
1000000111111111000b3333065033b00000000003bbbbbb0bbbbbbbbbb0333300000576bbb00000000005766666666633333333666666660000000000000000
8888888882000828055505558888888828888820555555000567665000000000000000005555aaaa8888888800000000065033b0111111110000000000000000
2222222282008228500050002222222220000020562226500567665055555555555555550000999922222222000b3333065033b0111111110000000000000000
000880008208202850e25200550055002888882050d2d050056766506333663366336336000099995500550000000000065033b0111111110000000000000000
00822800828200285000500055115511200000205dddd250056766507b777777777777b70000999955115511000b3333065033b0111111110000000000000000
082002808282002805550555561156112888882056ddd650056766506666666666666666000099995611561100000000065033b0111111610000000000000000
820000288208202850005000561156112000002050ddd0500567665066666666666666660000999956115611000b3333065033b0bbbb05760000000000000000
2222222282008228500252e0561156112888882055555550056766505555555555555555000055555611561100000000065033b0333305760000000000000000
8888888882000828500050005611561120000020000000000567665000000000000000000000000056115611000b3333065033b0000005760000000000000000
89888899eeeeeeee656556567777777734bbbbbbbbbbbb3400000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbdddddddd65655656566662221289a89a89a89a1200000000000000000000000000000000000000000000000000000000000000000000000000000000
93445438cccccccc65655656554452111289a89a89a89a1200000000000000000000000000000000000000000000000000000000000000000000000000000000
835444391122112265655656544555111289a89a89a89a1200000000000000000000000000000000000000000000000000000000000000000000000000000000
934445383450000011111111888888881289a89a89a89a1200000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111346ab00023733733666364221289a89a89a89a1200000000000000000000000000000000000000000000000000000000000000000000000000000000
766666673478900028698699113354421289a89a89a89a1200000000000000000000000000000000000000000000000000000000000000000000000000000000
766666671122100023733733113555425689a89a89a89a5600000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0100020012001200110011003200040000000000080008000100110001000100000000000000000000000000000000000000000000000000000000000000000001000012000011000011000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000
00000000000000000000000000000000010000000000000000000000000000000110000000000010101010101010100000000000000000030000000000000000010300000000000000000000000000000000010101000000000121000003c1810300000000000000000000000000000000000000000000000000000000000000
__map__
c2c2c286c2c2c2c2888a898b888a898bc2c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c28485c281c282898b888a898b888ac2820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8180828381818283888a898b888a898b82830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8180828381808283898b888a898b888a82830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c28c8ec2c2c2b6b6b6b6b6b6b6b682830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c28c8d8f8ec2c2b0b1b1b3b3b2b0b400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8e8c8d8d8f8f8e8cb0b0b3b3b2b2b0b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8d8d8d8d8d8f8f8fb4b4b4b4b2b0b0b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010100002455000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600002915300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00003065326653104530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400003063300000266412865100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001863018621000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002405124041240312402124011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000180211a031280412905137051000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600003063326623104130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001305300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001735023350233530c6500c6410c6310c62100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00001003300000286230000010033100332862300000100330000028623000001003310033286230000010033000002862300000100331003328623000001003300000286230000010033100332862300000
010e00001504515035150251501521045210352102521015130451303513025130151f0451f0351f0251f0150c0450c0350c0250c015180451803518025180151504515035150251501521045210352102521015
010e0000157400000015740000000000000000000000000013740000001374000000000000000000000000000c740000000c74000000000000000000000000001574000000157400000000000000000000000000
010e000021530215211f511215112d5302d5212b5112d5111f5301f5211d5111f5112b5302b521295112b511185301852115511185112453024521215112451121530215211f511215112d5302d5212b5112d511
010e0000157400000015730000001574000000157300000013740000001373000000137400000013730000000c740000000c730000000c740000000c740000001574000000157300000015740000001573000000
010e00001003300000286230000010033100332862300000100330000028623000001003310033286230000010033000002862300000100331003328623000001003300000286232862328623286232862328623
011800002855500000235552455526555000002455523555215550000021555245552855500000265552455523555235550000024555265550000028555000002455500000215550000021555000000000000000
012000001c5501c54018550185501a5501a550175501755018550185501555015550175501755000000000001c5501c55018550185501a5501a550175501755018550185501c5501c55021550215502055620556
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
01 41 0b 0c 44
00 41 0b 0c 44
01 0a 0b 0c 44
00 0f 0b 0c 44
00 0a 0b 0c 44
00 0f 42 0c 0d
00 0f 42 0c 0d
00 41 42 0e 44
00 41 42 0e 44
00 0a 0b 0e 44
00 0f 0b 0e 44
00 0f 0b 0c 44
00 0a 0d 0e 44
02 0f 0d 0e 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
