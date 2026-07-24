pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--shifttrap v. 1.0
--by sol

cartdata"moe_foxie_sol_ninja"

--variable descriptions
--[[
--persistent vars
lv=current level
deaths=player deaths
scrolls=number scrolls collected
secs,mins=seconds/mins elapsed
ngp=newgame+ (aka hardmode)

--transient variables
mxlv=max/final level of game
flopy=y position of floppy glyph
camy=target y of camera scroll
bary=scrolling of level border
dcnt=count of frames before next
 dust cloud
sex=sensei x (for cinematic)
strtx/y player start x/y
 managed by tiles 1 and 2 being
 present in a level
nrg=hourglass energy
unlocking=timer for gate unlock
unlocking2=ditto,for green gates
slow_rad=radius of hourglass 
 ring effect
shouldclip=when drawing, should
 camera clip to 128x128 coords
frm=number of frames elapsed
lastime=timestamp of last frame
hey_you_are_finally_awake=
 is nina collapsed in level 0?

--implicit variables
elpsd=elapsed time 'tween frames
lfb=output of btn 4 last frame,
 used by btnpp
bdr_scrl=whether level borders
 are scrolling. see tog_bdr_scrl
show_hud=whether persistent
 variable display is shown. see
 tog_hud.
winning=timer for how long
 between winning and next level
dying=timer for how long between
 death and respawn
crack=table with xy of 
 screen crack, if any
g=which frame the gears/treads
 are on
smk=coroutine for smoke anim
]]
lv,mxlv=dget(0),32

deaths,scrolls,
secs,mins,ngp,
flopy,camy,bary,dcnt,
sex,strtx,strty,nrg,
unlocking,unlocking2,slow_rad,
shouldclip,frm,lastime,
hey_you_are_finally_awake=
 dget(1),dget(2),
 dget(3),dget(4),dget(5)==1,
 1,0,0,0,
 55,64,112,1,
 -1,-1,255,
 true,0,0,
 lv!=0
 
function _init()
--player variables
--[[
px/y=player xy
px/yvel=player velocity
cte=coyote time timer
wgrace=grace period for pushing
 away from wall and detachment
psdr=player direction (hflip)
idle=timer for player
 idle animation

--implcit variables
wcling=player is wall clinging
hglass=does player have hourglass
tweight=does player have
 training weight?
has_seen_hglass=has player seen
 hourglass cinematic?
has_seen_tweight=has player seen
 training weight cinematic?
 
--set these only via s_ani()!!!
pfrm=player sprite number
pfrmd=duration, affects speed
 of player animation progres
ps/efrm= start/end sprite of
 animation.
]]
 px,py,pxvel,pyvel,
 cte,wgrace,psdr,idle,
 pfrm,pfrmd,psfrm,pefrm=
  18,70,0,0,
  1,15,1,0,
  1,.2,1,4
 
 cine_intro,
 cine_outro,
 cine=
  m_tro_cine(intro_co),
  m_tro_cine(outro_co),
  cine_logo
 menuitem(
  2,"clear save data",
  function()
   memset(0x5e00,0,256)
   extcmd"reset"
  end
 )
 tog_hud()
end

function s_ani(sfrm,efrm,frmd)
 if (psfrm==sfrm and pefrm==efrm) return
  pfrm,psfrm,pefrm,pfrmd=
  sfrm,sfrm,
  efrm or sfrm,
  frmd or 1
end

function update_player()
 if (cine) return
 if wcling then
  if btn(‘)and not psdr then
   wgrace-=1
  elseif btn(‹) and psdr then
   wgrace-=1
  else
   wgrace=15
  end
  if btnpp(ƒ) or wgrace==0 then
   wcling=false
  end
 end
 
 idle=btn()==0 and idle+1 or 0
 if not wcling then
  pxvel=
   (btn(‹) and -2) or
   (btn(‘) and 2) or 0
  if (tweight) pxvel/=2
  if pxvel!=0 then
   if fget(celat(px,py+8),0)and
      pfrm==4 then
    sfx(tweight and 45 or 35)
   end
   psdr=pxvel>0
   s_ani(1,5,tweight and 
    .25 or .5)
  else
   s_ani(idle%360>240 and 9 or 1)
  end
  
  if not chk_grnd() then
   cte-=1
  else
   cte=1
   pyvel=0
  end   
 else
  pxvel=0
 end
 
 local w,wc=chk(px+pxvel,py)
 if (wc) wc=wc[1]
 if not btn(ƒ) and pyvel!=0 and 
    (btn(‹) or btn(‘)) and 
    w and not fget(wc,2) then
  for y=-2,2,4 do
   if not chk(px+pxvel,py+y) then
    py+=y
    goto slipy
   end
  end  
  wcling=true
  ::slipy::
 elseif cte<0 then
  s_ani(3)
 end
 if cte<=4 then
  pyvel=min(3,pyvel+.25)
 end
  
 --crit=criteria for wcling
 local crit
 if tweight then
  crit=wcling
 else
  crit=wcling or cte>=0
 end
 if crit and btnpp(Ž) then 
  pyvel=-3.5
  wcling=false
 end
 if wcling then
  s_ani(5)
  pyvel=0
 end
 
 if dcheck() then
  die(1)
  px+=pxvel
  py+=pyvel
  return
 end
 if pyvel<0 and chk(px,py+pyvel) then
  local y=py+pyvel
  if pxvel==0 then
   for x=-2,2,4 do
    if not chk(px+x,y) then
     px+=x
     goto slipx
    end
   end
  end
  pyvel=0
  ::slipx::
 end
 
 if not hey_you_are_finally_awake then
  s_ani(8)
  pxvel,psdr,px=
   0,true,
   btn(‘) and 25 or
   btn(‹) and 23 or 24
 end
 
 local c,cx,cy=
  celat(px+4,py+4)
 if c==32 then
  trans(32,33,
        34,35,
        36,37,
        35,34,
        37,36)
  sfx(36)
  unlocking=15
 elseif c==48 then
  trans(50,51,
        52,53,
        48,49,
        51,50,
        53,52)
  sfx(36)
  unlocking2=15
 elseif c==67 then
  scrolls+=1
  sfx(41)
  mset(cx,cy,0)
 elseif c==65 then
  hglass=true
  sfx(34)
  if not has_seen_hglass then
   cine,has_seen_hglass=
    m_itm_cine(65,hglass_txt),true
  end 
  mset(cx,cy,0)
 elseif c==66 then
  tweight=true 
  sfx(34)
  if not has_seen_tweight then
   cine,has_seen_tweight=
    m_itm_cine(66,tweight_txt),true
  end
  mset(cx,cy,0)
 elseif c==64 then
  sfx(34)
  flopy=0
  if (lv==mxlv) camy=-128
  winning=lv!=0 and 60 or 120
 end
 
 local hitwall
 px+=pxvel
 while chk(px,py) do
  px-=1*sgn(pxvel)
  hitwall=true
 end
 
 py+=pyvel
 while chk(px,py) do
  py-=1*sgn(pyvel)
 end
 
 if pxvel!=0 then
  dcnt=dcnt>3 and 0 or dcnt+1
  if dcnt==3  and not hitwall 
     and chk_grnd() then
   add(dusts,{px,py,12})
  end
 end
end

function u_dusts()
 for d in all(dusts) do
  if d[3]>=13.5 then
   del(dusts,d)
  end
  d[3]+=.1
 end
end

function dcheck()
 local _,cxs=
  chk(px+pxvel,py)
 local _,cys=
  chk(px,py+pyvel)
  
 for axis in all{cxs,cys} do
  for cz in all(axis) do
   if (fget(cz,1)) return true
  end
 end
end

function newgame()
 pal()
 cine=nil
 music(lv==0 and -1 or 0)
 if lv!=0 and not bdr_scrl then
  tog_bdr_scrl()
 end
 loadlevel(lv)
end

function trans(...)
 local t={...}
 local omits={}
 for i=1,#t,2 do
  for x=0,14 do
   for y=0,14 do
    for omit in all(omits) do
     if omit[1]==x and 
        omit[2]==y then
      goto nxt
     end
    end
    if mget(x,y)==t[i] then
     mset(x,y,t[i+1])
     add(omits,{x,y})
    end
    ::nxt::
   end
  end
 end
end

function shift(x,y,ex,ey)
 x,y,ex,ey=
  x or 0, y or 0,
  ex or 16, ey or 16
 for x=x,ex do
  for y=y,ey do
   if mget(x,y)==17 then
    mset(x,y,16)
   elseif mget(x,y)==16 then
    mset(x,y,17)
   end
  end
 end
end

function celat(x,y)
 local x,y=x/8-2,y/8
 return mget(x,y),x,y
end

function chk(x,y)
 local y1,x7,y7=y+1,x+7,y+7

 if x<16 or x>104 then
  return true,{}
 end
 
 local cels={}
 for cel in all
  {celat(x,y1),celat(x7,y1),
   celat(x,y7),celat(x7,y7)} do
  if fget(cel,0) then
   add(cels,cel)
  end
 end
 if #cels>0 then
  return true,cels
 end
end

function chk_grnd()
 return (fget(celat(px,py+8),0)or 
      fget(celat(px+7,py+8),0))
end

function machine_hum()
 poke(15517,32-lv)
 poke(0x5f43,0b00001000)
 if started and stat(19)==-1 then
  sfx(39,3)
 end
end

function _update60()
 frm+=1
 elpsd=time()-lastime
 lastime=time()
 
 slow_rad=min(slow_rad+5,164)
 
 //update camera
 _camy=peek2(0x5f2a)
 if camy!=_camy then
  local shft=
   camy>_camy and 1 or -1
  camera(0,_camy+shft)
 end
 
 if (flopy<1) flopy+=0.0084 
 if (bdr_scrl) bary+=lv*.05+.05
 if (bary>8) bary=0
 g=started and frm%30>15//used by draw_gear, etc.
 
 ::top::
 if (cine) goto cn
 if (not cine) machine_hum()
 if winning and lv==mxlv then
  if peek2(0x5f2a)<-127 then
   cine=cine_outro
  end
  return
 elseif winning and winning>0 then
  if winning<60 then
   if not started then
    started=true
    sfx(32)
    tog_bdr_scrl()
    frm=45 //ensure gears start at same position
   end
  end
  s_ani(7)
  winning-=1
  u_dusts()
  return
 elseif winning then
  winning=false
  crack=nil
  lv+=1
  save_game()
  if lv==1 and stat(24)==-1 then
   music(0)
  end
  if (lv>mxlv) then
   music(14)
  end
  loadlevel(lv)
 elseif dying and dying>0 then
  s_ani(6)
  dying-=1
  u_dusts()
  return
 elseif dying then
  dying,crack,idle=false,nil,0
  loadlevel(lv)
 end
 if unlocking>-1 then
  unlocking-=1
 end
 if unlocking2>-1 then
  unlocking2-=1
 end
 if unlocking==0 then
  trans(35,0,37,0)
 end
 if unlocking2==0 then
  trans(51,0,53,0)
 end
 
 ::cn::
 if cine then
  if btnpp(Ž) then
   if cine==cine_intro then
    camera(0,0)
    camy=0
    newgame()
   elseif cine==cine_outro then
    camera(0,127)
    camy=0
    cine=cine_end
   end
  end
 else
  if secs!=0 then
   secs+=elpsd
   while secs>60 do
    mins=min(999,mins+1)
    secs-=60
   end
  end
  if hglass and nrg>0 and 
     btn(—) then
   if btnpp(—) then
    slow_rad=0
    sfx(40)
    poke(0x5f40,255)
   end
   if frm%4<3 then
    nrg-=0.008
    return
   end
  else
   poke(0x5f40,0)
   sfx(40,-2)
  end
  
  if btnpp(Ž) then
   hey_you_are_finally_awake=true
   shift()
   sfx(32)
  end
  
  if chk(px,py) then
   //nudge in player's favor
   for padx in all{2,-2} do
    if not chk(px+padx,py) then
     px+=padx 
     goto safe
    end
   end
   for pady in all{2,-2} do
    if not chk(px,py+pady) then
     py+=pady
     goto safe
    end
   end
   die()
   return
  end
  ::safe::

  update_player()
  u_frm()
  u_dusts()
  
  reload(0x0800,
   0x0800+64*flr(time()%2),446)
 end
 lfb=btn()
end

function die(cod)
 dying,crack,pxvel=
  30,{px-3,py-4},0
 if cod==1 then
  crack=nil
 end
 deaths=min(deaths+1,9999)
 scrolls=dget(2)
 sfx(33)
 
 flopy=0
 save_game()
end

function save_game()
 dset(0,lv) 
 dset(1,deaths) 
 dset(2,scrolls)
 dset(3,secs)
 dset(4,mins)
 dset(5,ngp and 1 or 0)
end

function u_frm()
 pfrm+=pfrmd
 if (pfrm>=pefrm) pfrm=psfrm
end

function loadlevel(n)
 --add small amount to secs
 --as signal to start counting
 if (started) secs+=.0001
 
 hglass,tweight=lv>4,lv>34
 hglass=hglass or ngp
 unlocking,unlocking2=-1,-1
 dusts={}
 
 reload(0x1000,0x1000,0x2000)
 for x=0,11 do
  for y=0,16 do
   local nx=n*12
   local ny=flr(lv/10)*16
   nx=nx%120
   local t=mget(nx+x,ny+y)
   if t==1 or t==2 then
    strtx,strty,ssdr,t=
     x*8+16,y*8,t==1,0
   end
   if not ngp then
    if (t==67) t=17
    if (t==28) t=16
    if (t==29) t=17
    if t==35 or t==37 or
       t==51 or t==53 then
     t=0
    end
   else
    if (t==65) t=0
    if (t==29) t=28
   end
   
   mset(x,y,t)
  end
 end
 if hey_you_are_finally_awake then
  sfx(38)
  smk=m_smokeco(strtx+3,strty+7)
 end
 px,py,psdr,pxvel,pyvel,wcling,winning,dying,nrg=
  strtx,strty,ssdr,0,0,false,false,false,1
end

function d_obj(x,y)
 pal() --[[guard against
           rare bug where 
           nina's green 
           hairbead turned 
           white??]]
           
 //palette cycling for
 //nina's eyes
 if wgrace!=15 then
  pal(3,15)
  pal(14,1)
 else
  pal(3,1)
  pal(14,15)
 end
 if not tweight or cine then
  //hide training weight if
  //not equipped
  palt(5,true) 
  palt(6,true)
 end
 
 if (ngp) pal(8,13)pal(2,5)
 spr(pfrm,x or px,
     y or py,1,1,psdr)
 palt()
 pal()
end
function _draw()
 
 cls()
 if shouldclip then
  clip(0,0-peek2(0x5f2a),128,128)
 end
 if cine then
  cine()
 else
  draw_bg()
  map(0,0,16,0,16,16)
  for u=0,1 do
   for x=0,8,8 do
    for y=0,128,8 do
     spr(18,x+112*u,y-bary,1,1,x==8)
    end
   end
  end
  
  if not tweight then
   for d in all(dusts) do
    spr(d[3],d[1],d[2])
   end
  end
  
  d_obj()
  
  if (smk) coresume(smk)
  
  if crack then
   spr(10,crack[1],crack[2],2,2)
  end
  
  if (hglass) draw_hglass()
  spr(106,116,130+12*sin(flopy))
  if (show_hud) draw_hud()
 end
end

function draw_hud()
  local hx=32
  if not ngp then
   clip(hx+17,0,127,7)
  end
  rectfill(hx,0,127,6,2)
  local dx=hx+36
  spr(83,dx,1)
  print(flenstr(deaths,4),
   dx+9,1,7
  )
  local lx=hx+19
  spr(85,lx,1)
  
  print(flenstr(lv,2),
   lx+8,1
  )
  local sx=hx+2
  spr(84,sx,1)
  print(flenstr(scrolls,2),
   sx+8,1
  )
  local tx=hx+62
  spr(86,tx,1)
  print(flenstr(mins,3)..":"..
   flenstr(secs,2),tx+9,1)
end

function draw_gear(x,y,frm)
 local v=g
 if (frm) v=not v
 local s=v and 96 or 98
 local y16=y+16
 for i=y,y16,16 do
  spr(s,x,i,2,2,false,i==y16)
  spr(s,x+16,i,2,2,true,i==y16)
 end
end

function draw_corners()
 pal(1,7)
 sspr(96,48,16,16,95,0,32,32)
 sspr(96,48,16,16,0,0,32,32,1)
 sspr(96,48,16,16,0,95,32,32,1,1)
 sspr(96,48,16,16,95,95,32,32,false,1)
 pal()
end

function draw_tread(x,y,l)
 s=g and 104 or 105
 spr(s,x,y)
 for i=1,l do
  spr(s+16,x,y+8*i)
 end
 spr(s,x,y+8+8*l,1,1,false,true)
end

function draw_bg()
 draw_tread(20,64,1)
 draw_tread(32,40,2)
  
 draw_tread(72,0,3)
  
 draw_gear(20,-10,1)
 draw_gear(100,-10)
  
 draw_gear(0,104,1)
 draw_gear(29,104)
  
 draw_gear(77,68)
 draw_gear(77,97,1)
 draw_gear(50,56,1)
 
 map(112,48,0,0,16,16,128)
end

function draw_hglass()
 rect(2,3,13,30,2)
 line(13,3,13,29,9)
 line(3,3,13,3)
 rectfill(3,4,12,29,4)
 pal(3,7)
 spr(81,4,5)
 spr(82,4,13)
 pal(3,1)
 spr(81,4,21,1,1,false,true)
 pal()
 
 for x=4,12 do
  for y=0,27 do
   local c=pget(x,y)
   if y>=27-20*(nrg) then
    if c==1 then
     pset(x,y,15)
    elseif c==13 then
     pset(x,y,9)
    end
   else
    if (c==1) pset(x,y,4)
   end
  end
 end
 
 slow_ring()
end

function m_tro_cine(co)
 return function()
  u_frm()
  if shake then
   camera(rnd(2),rnd(2))
  end
  coresume(co)
  
  local seq=flr(frm%30/10)+1
  set_pal(({
   {14,8,3,11,11,3,15,7,2,8},
   {14,8,9,14,15,8,2,7},
   {15,7,2,8,15,7,2,8}
  })[seq])
  for i=1,2 do
   map(119,56,28,46,9,4,i)
   pal()
  end
  pal(7,13)
  spr(95,92,54,1,1,1)
  spr(75,92,62,1,2,1)
  pal()
  local qspr
  if ngp then
   //load joke sprites
   qspr=qangry and 70 or 68
  else
   qspr=qangry and 30 or 14
  end
  if (qtalk) qspr+=frm%24/12
  spr(qspr,64,70,1,1,qdr)
  
  local sespr
  //spaghetti code at its finest
  if (co==outro_co) then
   sespr=46
   if (ngp) sespr=62 //joke spr
  end

  if sespr then
   if (setalk) sespr+=frm%24/12
   clip(28,0,127,127)
   spr(sespr,sex,70,1,1,sedr)
  end
  
  clip(28,46,127,127)
  d_obj()
  clip()
  
  if (white) rectfill(28,46,100,78,7)
  if (flr(frm%8)==0) pal(11,7)
  if (green) rectfill(84,60,91,77,11)
 end
end

function m_itm_cine(itm,txt)
 local show=function(s)
  print(s)
  wait(60)
 end
 return 
  function()
   poke(0x5f2f,1) //pause music
   s_ani(7)
   d_obj(60,80)
   spr(itm,60,72)
   draw_corners()
   cursor(5,40)
   for t in all(txt) do
    if type(t)=="number" then
     color(t)
    else //if string
     print(t)
     for _=0,60 do
      flip()
      if (btnpp(Ž)) goto skip
      lfb=btn()
     end
    end
   end
   wait(60)
   ::skip::
   poke(0x5f2f,0)//resume music
   cine=nil
  end
end

function wait(dur)
 for i=1,dur do
  flip()
 end
end

function tog_bdr_scrl()
 bdr_scrl=not bdr_scrl
 menuitem(5,
  (bdr_scrl and "pause" 
   or "resume").." border",
  tog_bdr_scrl)
end
function tog_hud()
 show_hud=not show_hud
 menuitem(4,
  (show_hud and 
   "hide" or "show").." hud",
  tog_hud)
end

function set_pal(p)
 pal()
 p=p or {}
 for i=1,#p-1,2 do
  pal(p[i],p[i+1])
 end
end

function m_smokeco(x,y)
 return cocreate(
  function()
    smokes={}
   for i=1,12 do
    add(smokes,{
     x=x,
     y=y,
     xdir=rnd(.5)-.25,
     ydir=-.5-rnd(.5),
     l=100+rnd(20),//life
     d=rnd(10),    //delay
     c=5+rnd(3)}   //color
    )  
   end
   
   while true do
    for s in all(smokes) do
     s.d-=1
     if s.d<0 then
      s.x+=s.xdir
      s.y+=s.ydir
      s.l-=1
      if s.l>=0 then
       color(s.c)
       circfill(
        s.x+sin(s.l/60)*5,
        s.y,(s.l-50)/10
       )
      end
     end
    end
    yield()
   end
  end)
end

function slow_ring()
 for x=-slow_rad,slow_rad do
  local y=sqrt(slow_rad^2-x^2)
  local offx,offy=10,18
  x=offx+x
  pset(
   x-1,offy+y-1,
   pget(x,y+offy)
  )
  pset(
   x+1,-y+1+offy,
   pget(x,-y+offy)
  )
 end
end

function btnpp(b)
 return btn(b) and 
  band(shl(1,b),lfb)==0
end
?true and band(shl(1,Ž),lfb)==0
//fixed length string
function flenstr(n,l)
 local s=
   sub(tostr(flr(n)),1,l)
 while #s<l do
  s="0"..s
 end
 return s
end

function cif(f,...)
 if is(f,"function") then
  return f(...)
 end
end
function whilst(dur,fun,...)
 dur=tonum(dur)
 for i=1,dur do
  cif(fun,...) yield()
 end
end
function is(v,t)
 return type(v)==t
end
-->8
--cine
function say(s)
 whilst(120,print,s,28,80,7) 
end
function lines(s)
 res={}
 local idx=1
 for c=1,#s do
  if sub(s,c,c)=="\n" then
   add(res,sub(s,idx,c))
   idx=c
  end
 end
 add(res,sub(s,idx,#s))
 return res
end
function cam_wait(cy,inter)
 camy=cy
 while peek2(0x5f2a)!=camy do
  if cif(inter) then break end
  yield()
 end
end

function end_card()
 draw_corners()
 print("a game by sol",36,14,9)
 print("thank you for playing!",
  20,20
 )
 cursor(36,41)
 color(7)
 print("statistics:\n")
 print("time:    "..
  flenstr(mins,3)..":"..
  flenstr(secs,2)
 )
 print("deaths:  "..
  flenstr(deaths,4)
 )
 if ngp then
  print("scrolls: "..
   flenstr(scrolls,2)
   .."/30"
  )
  if scrolls==30 then
   cursor(20,72,10)
   print
[[incredible! you found 
all 30 secret scrolls!
you're a true shinobi!!]]
  end
 elseif teaser then
  local msg=
"o patient one! a 2\78\68 quest is\n"..
[[presented to you. reset the
game & find the secret scrolls
to become a true shinobi!!]]
  print(msg,6,67,8)
  color(7)
 end
 palt(4,true)
 pal(1,7)
 sspr(112,48,16,16,40,88,48,32)
 cursor(0,0)
end

//scene control variables
//(bool unless otherwise noted)
--[[
shouldclip=clip to 128 frame
green=is portal active
white=flash/expolosion
qtalk,qdr=for dr. quail
setalk,sedr,sex=for sensei
]]
intro_co=cocreate(
 function()
  shouldclip=true
  qtalk=false
  camera(0,-127)
  cam_wait(0)
  
  music(7)
  qtalk=true
  say
[[at last, my research
is complete!!!]]

  say
[[ze "coplanar gate" 
is fully operational!]]

  say
[[soon, ze whole world 
vill know ze name--]]

  qtalk=false

  say
[[dr von quail!
dr von quail!!]]

  qdr,qtalk=false,true

  say
"vat? who is it?"

  qtalk=false
  while px<28 do
   px+=.5 yield()
  end
   s_ani(0,2,.1)
  say
[[it's just me, nina!
sensei sent me to--]]
 
  s_ani(1) 
  whilst"20"
  s_ani(0,2,.1)
  say
[[ooh, what is that?!]]
  s_ani(1,5,.6)
  while px<84 do
   px+=1
   if (px>64) qdr=true
   yield()
  end
  s_ani(1)
  qtalk=true
  say
[[no! do not touch zat!!]]
  s_ani(6)
  qtalk=false
  white=true
  whilst"5"
  sfx(21)
  say
[[waaaugh!!!]] 
  whilst"30"
  green=true
  px=1000
  white=false
  say"..."
  say"......"
  say"........."
  qtalk=true
  say
[[welp, she's dead]]
  qtalk=false
  cam_wait(160)
  camy=0
  camera(0,-127)
  newgame()
 end
)

outro_co=cocreate(
 function()
  //reset row if "bobbing"
  reload(0x0800,0x0800,512)
  px,py=0,0
  music(-1)
  sfx(-1)
  s_ani(6)
  qdr,qtalk=false,false
  green=true
  
  camera(0,-127)
  cam_wait(0)
  qtalk=true
  say
[[i-i have not seen 
ze girl today!!]]
  qtalk,setalk=false,true
  say
[[what? all i asked was
if the videogame i ]]
  say
[[ordered had arrived??
i had it sent here...]]
  setalk=false
  whilst"15"
  px,py=84,65
  s_ani(6)
  while py>24 do
   px-=4
   py-=1.5
   yield()
  end
  sfx(21)
  sedr=true
  for _=0,90 do
   shake=true
   print("waaaugh!!",28,80,7)
   yield()
  end
  sedr=false
  shake=false
  camera(0,0)
  whilst"60"
  setalk=true
  say
[[so, anyway...]]
  setalk=false
  px,py,psdr=16,70,true
  s_ani(1,4,.5)
  while px<28 do
   px+=.5 yield()
  end
  s_ani(0,2,.1)
  sedr=true
  say
[[i'm back!!!]]
  s_ani(1)
  setalk=true
  say
[[nina, there you are!]]
  say
[[i see you have passed 
my little test!]]
  setalk,qtalk=false,true
  say
[[e-excuse me, vat 
is going on?!]]
  sedr,setalk,qtalk=
   false,true,false
  say
[[forgive me doctor, 
i foresaw all of this...]]
  setalk=false
  whilst"15"
  s_ani(0,2,.1)
  say
[[sensei! ...i see!
you even knew]]
  sedr=true
  say
[[i'd make it 
outta there alive!]]
  s_ani(1)
  say
[[...]]
  setalk=true
  say
[[...sure]]
  setalk,qtalk=false,true
  say
[[vait! zis is not okay! 
you can't just valtz in--]]
  sedr,setalk,qtalk=
   false,true,false
  say
[[anyway, doctor,]]
  say
[[about that copy of 
oolongwatch...]]
  setalk,qtalk=false,true
  say
[[no! your game 
has not arrived!]]
  qangry=true
  say
[[and furthermore, 
get out!!]]
  say
[[i am done dealing 
vith you two today!]]
  setalk=true
  say
[[but i--]]
  psdr,sedr=false,true
  s_ani(1,4,.5)
  while sex>-30 do
   print("out, i say!",28,80,7)
   px-=1
   sex-=1
   yield()
  end
  qtalk,qangry=false,false
  whilst"60"
  qtalk=true
  say
[[vat a headache 
zis has been...]]
  qtalk=false
  cam_wait(-127)
  cine=cine_end
 end
)

cine_logoco=cocreate(
 function()
  decode(3072,512,0)
  music(20)
  whilst(120,draw_ss_logo,10,48)
  reload(0,0,0x800)
  decode(3072+512,256,64)
  memcpy(3072,4096,1024)
  cine=cine_title
 end
)

cine_logo=
 function()
  coresume(cine_logoco)
 end

cine_titleco=cocreate(
 function()
  while true do
   --[[
    note: 
    because this code runs in
    _draw, after lfb is set,
    btnpp will always be false.
    use btnp instead.
   ]]
   if btnp(Ž) then
    yield()
    shouldclip=false
    cam_wait(148,
     function()return btnp(Ž)end
    )
    cine=cine_intro
    started=lv!=0
   end
   yield()
  end
 end
)
cine_title=function()
 started=true
 draw_bg()
 //rectfill(0,0,127,147,1)
 coresume(cine_titleco)
 pal(1,6)
 for x=-48,127,48 do
  draw_gear(x,115)
  draw_gear(x+24,98)
 end
 pal()
 if time()%1==0 then
  shift(96,53,110,62)
  sfx(32)
 end
 map(96,53,4,4,16,10)

 //shouldclip happens to
 //get set when Ž is pressed
 if time()%2>1 and shouldclip then
  print("press Ž to start",30,88,7)
 end
end
function draw_old_logo()
 pal(10,9)
 for i=0,1 do
  sspr(96,16,16,16,0,15-i,30,50)
  sspr(96,16,16,16,130,65-i,-30,-50)
  rectfill(30,14,99,64-i,10)
  pal()
 end
 palt()
 pal(8,2)
 for i=0,1 do
  sspr(48,16,48,8,13-i,20,96,16)
  sspr(48,24,39,8,26+i,40,78,16)
  pal()
 end
 pal()
end

cine_endco=cocreate(
 function()
  camera(0,127)
  dset(0,0)
  dset(2,0) 
  whilst"3600"
  //secret secrets
  if scrolls==30 then
   music(15)
  elseif not ngp then
   music(14)
  end
  dset(5,1)
  teaser=true
 end
)
cine_end=function()
 camy=0
 end_card()
 coresume(cine_endco)
end

hglass_txt={
 7,
 "you got the hourglass!",
 11,
 "by holding — you can briefly",
 "slow time itself!",
 7,
 "time is on your side now and",
 "god can't do a thing about it!"
}

tweight_txt={
 7,
 "you got the training weight!",
 "now you can no longer jump!",
 11,
 "(except for wall jumps!!)",
 6,
 "wait, is this even an upgrade??"
}
 

katrinka=
[[meow!!! who's there?
...oh thank god, i've been
lost in these mazes for hours!
my name is katrinka, i'm dr.
quail's assistant.
you're some kinda ninja, huh?
then please, collect all those
cogs with the green gems.
they seem to cause things here
to shift around. if i may 
venture a hypawthesis,
collecting enough should shift
us right meowtta here! probably.
if you really are a ninja, you
should be able to cling to walls
by jumping towards them!
in addition to jumping off 
of walls, you can press ƒ to
let go. i can't do it meowself!
so please, get us meowt of here!]]
-->8
--1bitlib
function encode(dest,y,rows)
 bidx=dest
 for y=y,y+rows do
  for x=0,127,8 do
   local data=0
   for i=0,7 do
    data=
     bor(data,
      shl(sget(x+i,y),i)
     )
   end
   poke(bidx,data)
   bidx+=1
  end
 end
 cstore()
end

function decode(strt,len,desty)
 for idx=0,len do
  local bidx=idx+strt
  local cpix=peek(bidx)
  for i=0,7 do
   local dpix=
    shr(band(cpix,shl(1,i)),i)
    sset(
     ((idx%16)*8)+i,
     desty+flr(idx/16),dpix
    )
  end
 end
end

--ss_logo_draw
function draw_ss_logo(x,y)
 sslx=sslx or x-38
 pal(1,9)
 print(
  "\80\82\69\83\69\78\84\69\68\32\66\89",
  x,y-7,9
 )
 spr(0,x,y,14,4)
 pal(1,7)
 spr(14,x+98,y+19,2,2)
 sslx+=4
 pal(1,1+rnd(15))
 clip(sslx,y,16,33)
 spr(0,x,y,14,4)
 spr(14,x+98,y+19,2,2)
 pal()
 clip()
end

__gfx__
00000000a0aa9000a0aa900000000000a0aa90000aaa900000a00a00009aa0a00000000000aaa000077000077700007000000000000000000000b00000000000
00aa90000aaaa9000aaaa90000aa90000aaaa9000aaaa9000a99990a09aaaa00000000000aaaaa0000070070007707700000000000000000006b0000000b0000
aaaaa900a1f1f9b0a1f1f9b0aaaaa900a1f1f9b0a3e3e9b0a1fff1909f1f1fa000000000af1f1a900070000700077700000000000000000000444000006b0000
a1f1f9b091f1f89091f1f89091f1f9b091f1f89093e3e890ff1f1ff09f1f18a000000000af1f18900070007700077000000000000000000000b1b70000444000
91f1f890088888900888889001f1f8990888880908888890f88888f008888f0009b9000008888800070777777777000000000000000000000aab700000b1b700
0888889000218090002180900888880000218f50f88880900021100000211000aaa899000021890077007000007070070000000070000007000677b00aab77b0
0012f0900012f0000042f600041224650012460002126000001220000f122600aa9882100012f000700700000007777007007000007000000000670000e06700
004046500040465000000450000000000400000040005000040004000040046599998f140040450077070000000700007070770700000070000a00a0000a00a0
77777777000000005d76dddd77777777d1aaaaa77777777777777777777777777777777e0777777007770000000700000eeeeee0077777700000b00770000b00
567665670dddddd05d76d777aa6aa111d11aaaa7d6666666666666666666666d66666668d77cccc70007000000070000e88888827dddddd1006b00000006b070
55755557015d15d05dddd766aaaa111ad111aa67d66dd666666dd666666dd66d66666888dc77ccc70007000000077707e188881272dddd217044400000044400
56787567011111105d777766aaa111aada111aa7d67b7d66667b7d66667b7d6d66666866dcc77cc70077700000707777e81881827d2dd2d10081870000081870
567285670dddddd05d766666aa111aaadaa111a7d673bd666673bd666673bd6d66666866d7cc77c70070777777700070e88888827dddddd10aa870b000aa8700
57777777015d15d05d766666a111aaaad6aa1117d6677666666776666667766d66622266dc7cc7770770007077000070e88118827dd22dd100b677000b7e77b0
56766567011111105d766666111aa6aadaaaa117d6666666666666666666666d66626666dcc7cc777777007007000770e81881827d2dd2d1000a6700000067a0
55555555000000005d766666dddddddddaaaaa17ddddddddddddddddddddddddddd1dddd0dddddd070007700070007000222222001111110000000a0000a0000
0000700000000000aaaa2aaaaa00002a4999999a4999999a008888008000800080008000080000088800008880080000aaaaaaaaaaaaaaaa009ff70000000000
000d670000d7777099992999990000294999999a4900009a0888888008000800080008000080008888800880880080000aaaaaaaaaaaaaaa0966f6600066f660
00d6a67000d6e67099222999900022294922229a0000000008800008088008800880088800880088088008808800880000aaaaaaaaaaaaaa09f1f1f009f1f1f0
0d649a6700d28e7099299999900029994929929a00000000088888000888888008800888808800880880088880008800000aaaaaaaaaaaaa0677777009f1f1f0
00d646d000d62670992999999000299922299222002222000088888008888880088008808888008808800888800088000000aaaaaaaaaaaa0067770006777770
000d6d0000ddddd099222999900022294999999a0029920080000880088008800880088008880088088008808800880000000aaaaaaaaaaa00367f00006777f0
0000d0000000000099992999990000294999999a22299222088888800080008000800080000800888880088088000800000000aaaaaaaaaa00f3b4000f367040
000000000000000044442444440000244999999a4999999a0088880000080008000800080000800888000088800000800000000aaaaaaaaa0333b4000333b040
000070000000000077775777770000573bbbbbb73bbbbbb700888800000800080008000000080000000800000d77000000000000aaaaaaaa009ff70000000000
000d670000d77770bbbb5bbbbb00005b3bbbbbb73b0000b708888880008000800080008888800088888000000dd700000d7700000aaaaaaa0966f6600096f600
00d6767000d6e670bb555bbbb000555b3b5555b70000000008800008088008800880088888000888880000000dd600000dd7000000aaaaaa09f1f1f00961f160
0d63b76700d28e70bb5bbbbbb0005bbb3b5bb5b7000000000888880008888880088008800000800880000000ababa000add6a000000aaaaa09fffeee09f1f1f0
00d636d000d62670bb5bbbbbb0005bbb555bb55500555500008888800888888008800888880000088000000007e7000a0bab00000000aaaa00f111f00ffffeee
000d6d0000ddddd0bb555bbbb000555b3bbbbbb7005bb500800008800880088008800880000000088000000000aaaae007e7aaea00000aaa003fff0000f111f0
0000d00000000000bbbb5bbbbb00005b3bbbbbb7555bb555088888800800080008000800000000080000000000a77a0e00a77ae0000000aa00f3b4000f311140
000000000000000033335333330000533bbbbbb73bbbbbb7008888008000800080008000000000800000000000a09a0000a09a000000000a0333b4000333b040
000000000000000000000000000000000000b000000000000000b00770000b005555555555555555555555555576656155555555555555555555555577777777
0d077070028887000000000008777780006b0000000b0000006b00000006b0705555555555566555577877555576666157777666666666655566665566666666
00d6670000ccc000000057004877778400444000006b0000704440000004440055555555556776555711175555766661717111111111111d5616616566988966
0d6b7670000c000000055570025565200cc6b000004440000cc6800000cc680055555555567f27655777775555766661771111111111111d5666666566988966
0d63b67000cfc00000615550026666200aabb0000cc6b0000aa880b000aa880055555555567787655711175555766661711b11b11111b11d5666666566666666
00d66d0000fff0001d001500025655200003bbb00aabbbb000b3bb000bbebbb056ddd1555166661557777755557665617bb1bb1bbbbb1bbd5616616511111111
0d0dd0d002888e00000000000266662000003b0000e03b00000a3b0000003ba055ddd555551111555777775555766661711111111111111d5166661555555555
00000000000000000000000000000000000a00a0000a00a0000000a0000a000055ddd555555555555111115555766661566666666666ddd55511115555555555
000000002888888e0d111170077700700777007070000070077700700000000056ddd15555555555557555555576666155555555577666655555555555555557
000a00002888888e0d11117070707000777770007000000077077000000000005544455555558ca55575555555766aa155555555799ee9915555555555555576
0088e00000d1170000d1170070707000077700007770700077007000000000005f44425577658caa57b757575576a1a155555555799ee9916666666655555766
08c9be000d113170000d700077777000077700000077700077777000000000005544455557658c5a57375757577aa1a1555555557ee99ee1b3b3b3b355557666
08717800d1111317000d7000070700700777007000070070077700700000000055777555dddddddddddddddd57aaaaa1555555556ee99ee1b3b3b3b355576656
08777800d111131700d11700000000000000000000000000000000000000000055767555144444444444444157aaa1a155555555699ee9917777777755766666
00888000d11111170d1111700000000000000000000000000000000000000000557175551444444444444441766aaaa155555555699ee9915555555555766661
00000000d11111170d11117000000000000000000000000000000000000000005577755514444444444444417666666155555555511111155555555555766661
0000000000cffffff700000000000000000000000ffffffffff30000000014000000000effffffffffff700000002c00000008fffffffffffffff70000006c10
00008ffffff700000cffff300000ee300008fffff1000000000efff00000cf30000ffff0000000000000fff30000cf3000cff7000000000000000eff0000cf30
08ff300000000000000000ff30008f300ef1000000000000000000ef70008f308f100000000000000000008ff0000f10c1000000000000000000000ff1000e10
60000000000000000000000ef3000c0000000000000000000000000cf7000800000000000000000000000008ff000000000000000000000000000000ff000000
ff300300f00ff3ef7cf7cff3ff100000ff3c03c0f00ff3ef7cf7cff3ef100000ff3c13e0f00ff3ef7cf7cff3ef300000ff381060f00ff3ef7cf7cff3cf300000
f100ef10f00f10e97c300c30cf700000f100ef10f00f10e97c300c308f700000f1006810f00f10e97c300c308ff00000ff3e68d1f00ff3e97cf70c300ff00000
ff3e68d1f00ff3e97cf70c300ff000000e306810f000e3e97cf70c300ff000000e30ef10f000e3e97cf70c300ff000000e30ef10f000e3e97c300c300ef00000
ff381060ff1ff3ef7c300c300ef00000ff3c13e0ff1ff3ef7c300c300c700000ff3c03c0ff1ff3ef7c300c3008700000ff300300ff1ff3ef7c300c3000200000
000c00f0c2c2000081c2960000000000000e08f1c2c2000024009e00c7020000030e08f1c2cacff381991e006c870800870e08f3c2ce4242dbc3ffee68f7e700
cf0e00ffc2ca4e72dbdbff11c1035000cf9100f1c2c2cff381991cee000240038f7e006ec2c2c2c218101c000002c5a60fbfc0afc2c2c2c218081c0000064064
0edfe1d783c2c2001818c2c2000644240ceffbe301c2c2000018c2c200044424047ef7f3fff3ffff1800c2c200c444240a3cebf7004242001818cee200644424
0a3ccbffff727eff0018c2d200664412eb7e8bfffff3ffff1800cee200c32000fdf70d97000000001818c2c200000000fdf30d03000000000018c2c200000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
51616161616161616161617151616161616161616161617151616161616161616161617151616161616161616161617151616161616161616161617151616161
61616161616161715161616161616161616161715161616161616161616161715161616161616161616161715161616161616161616161710000000000000000
00000042000000000001000091000000000000001100009191d1d100000000420000000091039100000001119102001100000000000000000000000000010143
53113491111100000000439100000000110000910004910101913411910000000052000041000041000053001111000200111142034211110000000000000000
03000042000000000001000091000000000000001100009191d1d100000000420000000491009100000001119100001100000000000000000000000004010043
53333391001120000400439100000000110000912323910000913333910000003452000041000441000053340111000000111122222211010000000000000000
11110042000000000001000091000000000000001100009191010100009191919101019191009100000001119100001100000000000091111111111191232343
110000910131313101c1439100919101010100910000420000000000000000001111110041232341001111110101111111000011111101010000000000000000
31313131010101c1c101010191000000000000001100009191010100000000000052329191001100000001110100009100000000000091000000000091000011
11000091010100001111000000919101010100910000420000000000000000001111000042000042000011110100001100000000110000010000000000000000
00001100000000011100000091000000000000001100009191000000000000000052349191010191222201110100009100000000000091d1d101000091000000
00009191111111110000000000919100000101010000910000910000910000011111000042000042000011110000000011000011000000000000000000000000
00001100000000011102000091000000000091313101019191000000000000000052329191011191010101110101019111110000000091010101000091000001
01010191010100110000002000919100000101010000910000910000910000010101019191919191910101010000000000d1d100000000000000000000000000
00001101010101010101010111d11100000091000000009191111191000000111111d191910111910000000000000191c1c1c1c1000091000001000091222201
11001191019191910101919191919191919123230101911111910101910000010101009191919191910001010000000000000000000000000000000000000000
11111111113131313131313111d11100000091000000009191410091001111111101019191011191000000000000019111111111111191000011113491000011
01030191019191910001919191919191919123239191919191919191912222220100009102010103910000010000000000000000000000000000000000000000
0000000000413400111100041100000000009100000000919141009100010101010100919101010101c1010101010191001000000000910091d1d1d191000001
11011111010100000011111111919100000100910000910200910003910000010000001100010100110000000000000000010100000000000000000000000000
00000000004100001111000011000000c1c191000091119191410191000101010101009191010134019100009123239131313131313191009191919191000001
01110100111111110101010101919100000100910000910000910000910000010000111111010111111100000000000001000001000000000000000000000000
111111000041c1c10000111111000000c1c191000091000091000191313131111111009191010101119100009100009191000101000091000000009101c10000
00000000010101011111110000919111313100910000910000910000910000010001001100010100110001001100000100000000010000110000000000000000
010101010141c1c10000111111000000c1c191000091000091000191000001000011009191011111119101019111119191009191000091019191111111010000
000000000111110211021100004141000011010101010111d111c101011111110101011100010100110101011111010101000001010111110000000000000000
000001000043000011110000110000000000000000910000911111910000010000110091000000111191000091000000910001d1000091919191110011110000
0001010101111100d1111111114242000001110100000100001100000100001100010000c10101c1000001001101232323110100000001110000000000000000
10000100004300001111000011000000000000002091d104911102421000010101010191000010111111000091c10004910401d1000001010101010111110000
001100c1001100010041010101424200111143031000010000110000010000111001110000010100001101000101430443110100100001010000000000000000
51616161616161616161617151616161616161616161617151616161616161616161617151616161616161616161617151616161616161616161617151616161
61616161616161715161616161616161616161715161616161616161616161715161616161616161616161715161616161616161616161710000000000000000
51616161616161616161617151616161616161616161617151616161616161616161617151616161616161616161617151616161616161616161617151616161
61616161616161715161616161616161616161715161616161616161616161715161616161616161616161710000000000000000000000000000004600000000
91000001010100001100049100000000000001000042049191000000004141000000009100000000000000000000000000000000000000000000000000000000
00000000110000000000000000004100000000019100000001004143000000910000000000000000000000000000000000000000000000000000004600000000
91000000010000111111009111111100000001000022229191000000004141000000009100000000000000000000000000000000000000000000000000000000
00000000110000000000000000004100000000019100000001004143000000910000000000000000000000000000000000000000000000000000005600000000
910100000300000011000091340000d1000001000000119191000000344141040000009100000000000000000000000000000000000000000000000000000000
00000000110000000010000000004102000000019134000001004143000004910000000000000000000000000000000077774777777777760000004600000000
91010100313131313131319100000000d10000c10011009191232331314141313122229100000000000000000000000000000000000000000000000000001000
000000001100000231313101010141313100000191010101010041232323239100000000000000000000000000000000b6b6b6b6b6b6b6b7000000a7b6b6b6b6
9101000041344300000000910000010101000000c101019191000001110000011100009100000000000000000000000000000000000000000000000031313131
00000000313131311111110000000000000000019111111111111111111111910101000100010001000101000101010000000000000000a7b6b6b6b700000000
91001100412323001100009100010000110100000011009191000001110000011100009100000000000000000000000004000000000000000000000031313131
00000000313131311111110000000000000000019103000000000001010100910100000100010001000100000001000000000000006647677777776777777777
91111111010000111111009101000011000001000000119191111111110000010101019100000000000000000000000031313131310000000000000031313131
01010101313131311111110000000000000000009152323232323333333333910101000101010001000101000001000000000000004600000000000000000000
91001101c10100011100009101111100000011111101019191110000110000010000019100000000000000000000000000004100000000001111111131313131
22222222313131310101010101013131310000009152000000525300000053910001000100010001000100000001000000000000004600e5d5e5e5d5e5e5d5e5
9122222201110101c100009101000000001101000111009191110200110000010000019100000000000000000000000000004100000000001111111100000000
00000000430000011111111111113131310000009152000000525300000053910101000100010001000100000001000000000000004600e4e4c4d4e4e4f5f4c5
91000001111102011100009100010000110100010000119191111111110000012222019100000000000000000000000010002400000000001111111100000000
00000000430000014100000411113131311111119152000000525300000053911111110011110000001100001111110000000000004600c584a4a49494b4c5c5
91000101011101111111009100000101114100010000119191010101010101011111019100000000000000000000000031313131310000003131313100000041
010101014100000141222222222222222222222291010101010111111111119100110000110011001100110011001100b6b6b6b6b6b700c58595a5c5c5b5c5c5
91001101000101011100009100000001010100010000119191010000000101110000119100000000000000000000000031313131310000003131313100000341
11111111410000014100000000000000000000009101000000011100000011910011000011110000111111001111110077774777776777777600000000000000
91111111000001110000009100000100001101020111009191011000000101110003119100000000000000000000000031313131310000003131313100000041
11111111410004014100000101010100001111119101100000011103000211910011000011001100110011001100000000000000000000004600000000000000
9100110010001111110000910001001000001111110101919101010101010101d1d1019100000000000000000000000031313131311111113131313111111141
11111111411111014100000101010100001111119101010101011111111111910011000011001100110011001100000000000000000000004600000000000000
51616161616161616161617151616161616161616161617151616161616161616161617151616161616161616161617151616161616161616161617151616161
61616161616161715161616161616161616161715161616161616161616161715161616161616161616161710000000000000000000000004600000000000000
__gff__
0000000000000000000000000000000001000101010101010105000003030000000001000100000000000000000000000000010001000000000000000000000000000000000000000201020201010202000000000000000202020102020101020000000080808080000000800000000000000000808080800000808000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616170000000000000000
1313131313131313131313130000000000000000000000000000000000000000000000000000000000000000000000000000000010110000000000000000000000101010100000000000110000001000000000000000001011000000000000000000001010100000000000000000000000110000001100000000000000000000
1313131313131313131313130000000000000000000000400000000000000000000000000000000000000000000000000000004010114300000000000000000000101010100000000000110000001000000000000001001011000000000000430000001010100000000000000000000000110000001143000000000000000000
1313131313131313131313130000000000000000000011110000000000000000000000401111100011111d000000004000001111101111110011111100000000001313131300000010001111111110000000000010101010101c1c1010101010000100101010000000000000101010101010101c101011110000000000000000
0000001c00001100000000000000000000000000101010100000000000001010101010100011100000000000001010100000000010000000000000100000000000101010100040004000111010101010101010100000000000000000001011111010100000001010101111111000000000111111111111110000000000000000
0000001c00001100000000001111110000001010111111114300000000001111111111110011100000000000001111110000000010000000000000101111111111101010431111110000111000000000000000101111111111111100001011111010100000001010101111111000000000110000001111110000000000000000
0000001c00001100000000401111110000000000000000001c1c1c0000000000000000004311100000000000000000000000000010000000000000101111110000111111111010101d11111000000000000000101c1c1c1c1c1c1c00001011111010101d1d1d1c1c1c0000001000000000110000001100000000000000000000
0000001000001d00001313131111110000000000000000001010100000000000000000001111111100000000000000001111111110101010101010101111110000111111110000001111111000001d1d111111110000000010110000000000001111111010101111111010101000000000110001001100000000000000000000
0000001000001d000013131310101000000000000000000000000000000000000000000010101010000000000000000010101010111111110000001011111c0000111111110000001111111010101010101010104000000010110000000000001111111010101d431000000010101010101d1010101110100000000000000000
0000001000001d000013131300000000001000000000000000000000001111111111111111111110000000000000000000000000000000110000001011111c0000111d1d1100000043111d1000000000000000101110101010111010101c000011111110101011111111111110100011111d1111111100000000000000000000
0000001000001d000013131300000000001000000000000000000000001010101010101011111110000000000011111100000000000000110000001010101c1c1c1d1d1d1111111111111110000000000000001011101010101110101010000000000000000010101000000013131111111d0000001100000000000000000000
0001001000001d00001313130000000000000000000000001d1d0000000000000000000011111110000000000010101000000000000000110000001000000000000000000011111111111110101010101000001000000000101111111111111100000000000010101100000011111111111d0000001100000000000000000000
131313131313131313131313000000000000000000000000101000000000000000000000000000000000000000000000000000000000001d1d1d1d1d0001000000000000001111111d11111111111111101111101111000010000000000000000000000000401011110000001010101010131310101100000000000000000000
131313131313131313131313000000000000001d1d1d1d111010000000000000000000000000000000001d000000000000000010101010101010101010101010101010101011111100000000000000001000001011110000100000000000000000001d1d1d1d1111111010100000000000000010101100000000000000000000
131313131313131313131313000000000001001d0000004300000000000000000002000000010000001d1d0000000000000000000000004100020000111111111111111111111111000100000000000010000010111100001000000000001c1c000000000000111111000000004000000000001010111c1c0000000000000000
1516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616170000000000000000
1516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616170000000000000000
0000000000000024000000000000111000000000000011110011250000001100000000000000001000001000000000001010101010000000000024000000001010100000001011111111111111111111111124431010102400000010110000000000110000110000000000000034000011000011101c1c100000000000000000
0000000000000024000000004300111000000000000011114311250000001100000000000000001000001000000000001000000010000000000024430000001010100000001011110000000000000000000024220000002400000010110043000000110000110000000000004334200011000011100000100000000000000000
0001000000000024000000431000111000000000000011111313130000001100000000000000001000001000000000001000000010000000000022220000001010100000001011112000000000000000000000114000002400000010110000000040110000110000000000001113131311111111100030100000000000000000
1010101010101010101010101010000000001010111d1d1100000000001c1100000000000000001c1c1c1c0000000000100001001011000000001c1c0000001d11111111111111111111111d1d11111110000011101010100000003410101c101111111d1d111313130000001100000011000011101111110000000000000000
11111111111000111111111110001000000010100000001000000000001c1100000000200020001010101000000000001313131313110000000011110000001d11111010101011112222131313131310000000111111111c00000034000000001313131313131313132222221100000011000011101100110000000000000000
000000001110001100000000100000101d1d10100000001000000000001c1d1d111111111010101010101010101111110000000000101010101000001010101010111010101011110000001100001110000000101111111c00000034000020001000000010100000001111111100001010101010101100110000000000000000
0000000011101c110000000010000011141313131400001000001111111d1d1d111111111d11111111111111111111110000000000100000001000000000000020111010101011110000001100401110000000101010100000000010101010101000000010100000001111111d00001011222222220000110000000000000000
0000200011101c1100000000100000111400000014000010101010101010101010101010000000001000000000000000000000000010000000100000000000111111101010102222111111111111111110000010000000000000001c11111111100000001c100000001100001d00001011000000000000100000000000000000
001111111100001100000000100000001400000014000010000011111111111100000000000000001000000000000000000000001d100000001000001010100000111040001111111010101c1c10101c1c000011300000000000001c11111111101c000011131313131310101d01001011000000000010100000000000000000
131313131313131313131010100000001400000014111111000011111111111100000000000100001000000000000000000000000011101010101010111111000011100000110000001010000010100000000011101010100000000010101010101c000011343543113510101010101010101010101010100000000000000000
00000000101000240000000010000000141c401c14000010131313131310101100001d1d0013131313101010131322221010101c10131313131322220000000000111000001100000000000000000000000000111111111c0000000000000000101c000011343333333310100000131313133232323211110000000000000000
004000001010002400000000000000001422222214200010000000002400001100001d1d0013131313101c1013130000100000001013131313130000000000000011101d1d1100000000000000000000000000111111111c00000000000002001000000011340000000010101313131313131313131311110000000000000000
1c1c00001010002410100000000000111100000010111111000000002400001100001010001313131310101013131010100020001013131313130000000000000011101111111d1d0110100000101000001010100000243400000010101010101000001111342030000010100000101000001111000011110000000000000000
1c1c1c1c1010002410101000010011110000000010111111004000002400011100001010001111111100430013130040101c101010131313131300400001000000111011111111111010101010101010101010104300243400000010111111111000011111101010101010104000101000001111000011110000000000000000
1516161616161616161616161516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616171516161616161616161616170000000000000000
__sfx__
010100002004520045200051d0451d045000051804518045180051d0451d045000051f0451f045000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001f040050001f04007000240400c0001f040130001d0401f00024040050001f040000001b0400f00024040200001f04000000240400000027040000002204000000240400000024040000002704000000
010a00002013520135201051d1351d135001051813518135181051d1351d135001051f1351f13500105001052013520135201051d1351d135001051813518135181051d1351d135001051f1351f1350010500105
010a00001f0402200024040290002704024000220402000027040290002904024000270401f000290401f00024040270002904029000240402400027040000002904000000270400000025040000002204000000
010a00001d1351d135221051f1351f1352210522135221351b1052413524135161052713527135111051d10527135271352213522135241352213522135241352513525135000002710522135221350010500000
010a00001f0402200029040290002b04024000290402000027040290002904024000270401f000240401f00024040270002204029000240402400027040000002b04000000270400000025040000002204000000
000a00002200022040220002404024000270402700029040290002704022000290402400029040270002b04027000270402200024040240002404027000270402700029040220002b04029000290402900027040
000a00001b1351b1351b1051d1351d1351d1051f1351f1351f1052213522135221052213522135221051f1351d1351d1051b1351b1351d1051813518135181051d1351d1351d1351d1351d1351d1351d1351d135
010a000022040220502204024000270402705027040290002704022000290402905029040270002b0402700027040270502704024000240402700027040270002904029050290402905029040290002700000000
010c00001c520005001a520005001d520005001c5201c52000500005001c5201c520005001f5201f520005001d5201d520005001f5201f520005001c520245001d520245001f5202450021520245001d52000500
011000000c0320c0320c0320c0020c00213032130321303215032150320c0020c0021103211032110320c002000000c0320c0320c0320c0020c00210032100321003200002000020000200002000020000200002
0110000013032130321303200000000001103211032110221503215032150320c000000000e0220e0220e02200002000000c0220c0220c0220000000000000000000000000000000000000000000000000000000
011800000c55000500185500050018550005000c550005000c550185500d55000500115501c55010550005000c55018550005000c5500d55018550005000c5500c550005000c5500c5500d550005000c55000500
011800000c55000500245500050011550005000c550005000c5500f5500d55000500115501c55010550005000c55024550005000c5500d550005000c5500c550005000c5500c5501955000500000000c55000000
011000000c1200c12010120101201312013120111201112015120151201812018120131201312017120171201a1201a1201812018120101201012013120131200c1200c120101201012013120131201112011120
0110000015120151201812018120131201312017120171201a1201a1201812018120101201012013120131201112011120151201512018120181201012010120131201312017120171200e1200e1201112011120
0110000015120151200c1200c12010120101201312013120111201112015120151201812018120131201312017120171201a1201a120111201112015120151201812018120101201012013120131201712017120
001000002135021350003001a350003001a350003001d3501d350003001a350003001c3501c350003001835018350003001a35000300213502135021350003000030000300003000030000300003000030000300
001000001835018350003001d350003001d350003002135021350003001d350003001f3501f350003001c3501c350003001d35000300183501835018350003000030000300003000030000300003000030000300
001000001c3501c350003002135000300213500030018350183500030021350003002335023350003001f3501f3500030021350003001c3501c3501c350003000030000300003000030000300003000030000300
011000000e1200e120111201112015120151200c1200c120101201012013120131201512015120111201112015120151201812018120000000000000000000000000000000000000000000000000000000000000
0006000038626366263562634626326262f6262c62629626246261f6261c62618626136262e626306261c6261b6261862614626106260e6260d62606626056260060600606006060060600606006060060600606
011000001f020230201a0201f020230201a0201f020230201a0201f020230201a0201f020230201a0201f020230201a0201d02021020180201c0201d02021020180201c0201d02021020180201c0201d02021020
011000000000018330003002833000300003001f33000300183001c330003001d33021330003001c3300030000300003000030029330003000030021330003000030018330003001c330003002d3300030000000
01100000003001f340003002f34000300003002634000300003001c340003002b34000000003002334000000000001d3402134000300000001c3400030000000000001834000000000002b340000001d34000000
01100000000001f3402b3400000000000233400000000000000001a340000000000029340000002134000000000001d340000002d340000001834000000000000000018340183400000028340000001c34000000
01100000003001f340003002f34000300003002634000300003001c340003002b34000300233400000000000003002934000000213400030018340003001a340000001c340000002b34000000233400000000000
000600002735027350223502235029350293502e3502e350293502935033350333502730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006000022350223501d3501d3502435024350293502935024350243502e3502e3502730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002b6501f650156501560000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000200003d3503d3503b350396503a650303502a350276002c6002c6003e6003d600093000e300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000600001e3502035024350273502b3502e3502c3502e3502c3502c3502d300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000100002e02000000000001700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001f05022050270503165031650316503165035050370503805037050370500060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200000a1500c6500c1500c1500d1500e6500e1500f1500e6501015011150111501065012150136501315012650141501465016600176001810018100191001a1001b1001a1001b1001b1001c1001c1001c100
0001000019650196501965019650186501665014650106500e6500d6500a650086500565003650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000001664316643166431664316643166431664316643166431664316643166431664316643166431664316643166431664316643166431664316643166431664316643166431664316643166431664316643
0102000036050350503405032050310502e0502b0502905027050250502405021050200501e0501d0501d0501b050190501905018050170501705016050120501405013050120501105011050110501205011050
000200003e3503d3503b3503735037350343003a3003a3003a300353002c300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000100000b3000b3000d3000d30000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001e32019320183200832000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
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
00 01 08 43 44
01 01 02 43 44
00 03 04 43 44
00 05 02 43 44
02 05 07 43 44
01 09 0a 43 44
02 09 0b 43 44
01 0e 42 43 44
00 0f 42 43 44
00 10 42 43 44
04 14 42 43 44
00 41 42 43 44
01 0c 42 43 44
02 0d 42 43 44
04 11 12 13 44
01 16 17 43 44
00 16 19 43 44
00 16 18 43 44
00 16 19 43 44
02 16 1a 43 44
04 1b 1c 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
