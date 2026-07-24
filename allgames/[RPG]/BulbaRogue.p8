pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--bulbarogue
--by hacobjuelskamp

--function
function _init()
 t=0
 shake=0
 
-- dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}
 
-- dirx={-1,1,0,0,1,1,-1,-1}
-- diry={0,0,-1,1,-1,1,1,-1}
 
 dpal=explodeval("0,1,1,2,1,13,6,4,4,9,3,13,1,13,14")
 
 dirx=explodeval("-1,1,0,0,1,1,-1,-1")
 diry=explodeval("0,0,-1,1,-1,1,1,-1")
 
 
-- mob_ani={252,192,196,200,204,208,212,216,220}
-- mob_atk={1,1,1,1,1,1,1,1,3}
-- mob_hp={9,1,2,2,2,2,2,2,10}
-- mob_los={5,4,4,4,4,4,4,4,4}

 mob_name=explode("player,gastly,zubat,litwick,sandygast,drifloon,haunter,golbat,gengar")
 mob_ani=explodeval("252,192,196,200,204,208,212,216,220")
 mob_atk=explodeval("1,1,2,1,2,3,3,5,5")
 mob_hp=explodeval("5,1,1,3,3,4,5,8,10")
 mob_los=explodeval("4,2,4,4,4,4,4,3,4")
 mob_minf=explodeval("0,1,2,3,4,5,6,7,8")
 mob_maxf=explodeval("0,3,4,5,6,7,8,8,8")
 mob_spec=explode(",,,spawn?,fast?,stun,ghost,slow,")

 itm_name=explode("tackle,vine whip,solar blade,mega drain,giga drain,solar beam,harden,defense curl,bulk up,acid armor,flower shield,iron defense,potion,oran berry,super potion,hyper potion,‡ container ,hp up,energy ball,bullet seed,razor leaf,seed bomb")
 itm_type=explode("wep,wep,wep,wep,wep,wep,arm,arm,arm,arm,arm,arm,fud,fud,fud,fud,fud,fud,thr,thr,thr,thr")
 itm_stat1=explodeval("1,2,3,4,5,6,0,0,0,0,1,1,1,1,2,2,3,3,1,2,3,7")
 itm_stat2=explodeval("0,0,0,0,0,0,1,2,3,4,3,4,0,0,0,0,0,0,0,0,0,0")
 itm_minf=explodeval("1,2,3,4,5,6,1,2,3,4,5,6,1,1,1,1,1,1,1,2,3,4")
 itm_maxf=explodeval("3,4,5,6,7,8,3,4,5,6,7,8,8,8,8,8,8,8,4,6,7,8")
 itm_desc=explode(",,,,,,,,,,,, heals, heals, heals a lot, heals a lot, increases hp, increases hp ,,,,")  
   
-- itm_name={"vine whip","focus sash","oran berry","razor leaf"}
-- itm_type={"wep","arm","fud","thr"}
-- itm_stat1={1,0,1,4,5,6,0,0,0,0,1,2,1,2,3,4,5,6,1,2,3,4}
-- itm_stat2={0,2,0,0,0,0,1,2,3,4,3,3,0,0,0,0,0,0,0,0,0,0}
-- itm_minf={1,2,3,4,5,6,1,2,3,4,5,6,1,1,1,1,1,1,1,2,3,4}
-- itm_maxf={3,4,5,6,7,8,3,4,5,6,7,8,8,8,8,8,8,8,4,6,7,8}

-- crv_sig={0b11111111,0b11010110,0b01111100,0b10110011,0b11101001}
-- crv_msk={0,0b00001001,0b00000011,0b00001100,0b00000110}

 crv_sig=explodeval("255,214,124,179,233")
 crv_msk=explodeval("0,9,3,12,6")

 free_sig=explodeval("0,0,0,0,16,64,32,128,161,104,84,146")
 free_msk=explodeval("8,4,2,1,6,12,9,3,10,5,10,5")

 wall_sig=explodeval("251,233,253,84,146,80,16,144,112,208,241,248,210,177,225,120,179,0,124,104,161,64,240,128,224,176,242,244,116,232,178,212,247,214,254,192,48,96,32,160,245,250,243,249,246,252")
 wall_msk=explodeval("0,6,0,11,13,11,15,13,3,9,0,0,9,12,6,3,12,15,3,7,14,15,0,15,6,12,0,0,3,6,12,9,0,9,0,15,15,7,15,14,0,0,0,0,0,0")


 debug={}
 startgame()
end

function _update60()
 t+=1
 _upd()
 dofloats()
 dohpwind()
end

function _draw()
 doshake()
 _drw()
 drawind()
 --fadeperc=0
 checkfade()
 
 --’ remove debug
 cursor(4,4)
 color(8)
 for txt in all(debug) do
  print(txt)
 end
end

function startgame()
 poke(0x3101,194)
 music(0)
 tani=0
 fadeperc=1
 buttbuff=-1

 skipai=false
 win=false
 winfloor=9
 mob={}
 dmob={}
 p_mob=addmob(1,1,1)
 
-- for x=0,15 do
--  for y=0,15 do
--   if mget(x,y)==192 then
--    addmob(2,x,y)
--    mset(x,y,1)
--   elseif mget(x,y)==196 then
--    addmob(3,x,y)
--   mset(x,y,1)
--   elseif mget(x,y)==200 then
--    addmob(4,x,y)
--    mset(x,y,1)
--   elseif mget(x,y)==204 then
--    addmob(5,x,y)
--    mset(x,y,1)
--   elseif mget(x,y)==208 then
--    addmob(6,x,y)
--    mset(x,y,1)
--   elseif mget(x,y)==212 then
--    addmob(7,x,y)
--   mset(x,y,1)
--   if mget(x,y)==216 then
--    addmob(8,x,y)
--    mset(x,y,1)
--   elseif mget(x,y)==220 then
--    addmob(9,x,y)
--    mset(x,y,1)
--   end
--  end
-- end
 
 p_t=0
 
 inv,eqp={},{}
 makeipool()
 
 takeitem(1)
 takeitem(7) 
 takeitem(13)
 takeitem(19)
  
 wind={}
 float={}
 --fog=blankmap(0)
 talkwind=nil
 
 hpwind=addwind(5,5,28,13,{})
 
 thrdx,thrdy=0,-1
 
 _upd=update_game
 _drw=draw_game
 
 genfloor(0)
 --unfog()
 --calcdist(p_mob.x,p_mob.y)
end
-->8
--updates
function update_game()
 if talkwind then
  if getbutt()==5 then
   talkwind.dur=0
   talkwind=nil
  end
 else
  dobuttbuff()
  dobutt(buttbuff)
  buttbuff=-1
 end
end

function update_inv()
 --inventory
 move_mnu(curwind)
 if btnp(4) then
  sfx(53)
  if curwind==invwind then
   _upd=update_game
   invwind.dur=0
   statwind.dur=0
 --’
  elseif curwind==usewind then
   usewind.dur=0
   curwind=invwind
  end
 elseif btnp(5) then
  if curwind==invwind then
   showuse()
   --’
  elseif curwind==usewind then
   -- use window confirm
   triguse()
  end
 end
end

function update_throw()
 local b=getbutt()
 if b>=0 and  b<=3 then
  thrdx=dirx[b+1]
  thrdy=diry[b+1]
 end
 if b==4 then
  _upd=update_game
 elseif b==5 then
  throw()
 end
end

function move_mnu(wnd)
-- local moved=false
 if btnp(2) then
  sfx(56)
  wnd.cur-=1
--  moved=true
 elseif btnp(3) then
  sfx(56)
  wnd.cur+=1
--  moved=true
 end
  wnd.cur=(wnd.cur-1)%#wnd.txt+1
-- return moved
end

function update_pturn()
 dobuttbuff()
 p_t=min(p_t+0.2,1)
 
 if p_mob.mov then
  p_mob:mov()
 end
 
 if p_t==1 then
  _upd=update_game
  if trig_step() then return end
  
  if checkend() and not skipai then
   doai()
  end
  skipai=false
 end
end

function update_aiturn()
 dobuttbuff()
 p_t=min(p_t+0.2,1)
 for m in all(mob) do
  if m!=p_mob and m.mov then
    m:mov()
  end
 end
 if p_t==1 then
  _upd=update_game
  checkend()
 end
end

function update_gover()
 if btnp(—) then
  fadeout()
  startgame()
 end
end

function dobuttbuff()
 if buttbuff==-1 then
  buttbuff=getbutt()
 end
end

function getbutt()
 for i=0,5 do
  if btnp(i) then
   return i
  end
 end
 return -1
end

function dobutt(butt)
 if butt<0 then return end
 if butt<4 then
  moveplayer(dirx[butt+1],diry[butt+1])
 elseif butt==5 then
  showinv()
  sfx(54)
 --menu button
 end
end
-->8
--draws
function draw_game()
 cls(0)
 if fadeperc==1 then return end
 animap()
 map()
 for m in all(dmob) do
  if sin(time()*8)>0 or m==p_mob then
   drawmob(m)
  end
  m.dur-=1
  if m.dur<=0 and m!=p_mob then
   del(dmob,m)
  end
 end

 for i=#mob,1,-1 do
  drawmob(mob[i])
 end
 
 if _upd==update_throw then
  --’
  local tx,ty=throwtile()
  local lx1,ly1=p_mob.x*8+3+thrdx*5,p_mob.y*8+3+thrdy*4
  local lx2,ly2=mid(0,tx*8+3,127),mid(0,ty*8+3,127)
  rectfill(lx1+thrdy,ly1+thrdx,lx2-thrdy,ly2-thrdx,0)
  
  local thrani,mb=flr(t/9)%2==0,getmob(tx,ty)
  if thrani then
   fillp(0b1010010110100101)
  else
   fillp(0b0101101001011010)
  end
  line(lx1,ly1,lx2,ly2,7)
  fillp()
  oprint8("+",lx2-1,ly2-2,7,0)
  
  if mb and thrani then
   mb.flash=1
  end
 end
 
 for x=0,15 do
  for y=0,15 do
   if fog[x][y]==1 then
    rectfill2(x*8,y*8,8,8,0)
   end
  end
 end
 
 for f in all(float) do
  oprint8(f.txt,f.x,f.y,f.c,0)
 end
end



function drawmob(m)
 local col=10
 if m.flash>0 then
  m.flash-=1
  col=7
 end
 drawspr(getframe(m.ani),m.x*8+m.ox,m.y*8+m.oy,col,m.flp)
end

function draw_gover()
 cls(2)
 print("you were # 001",35,55,7)
end

function draw_win()
 cls(11)
 print("you are # 001",35,55,7)
end

function animap()
 tani+=1
 if (tani<15) return
 tani=0
 for x=0,15 do
  for y=0,15 do
   local tle=mget(x,y)
   if tle==64 or tle==66 then
    tle+=1
   elseif tle==65 or tle==67 then
    tle-=1
   end
   mset(x,y,tle)
  end
 end
end
-->8
--tools

function getframe(ani)
 return ani[flr(t/14)%#ani+1]
end

function drawspr(_spr,_x,_y,_c,_flip)
 palt(0,false)
 --pal(6,_c)
 --‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡ not dichromatic system
 spr(_spr,_x,_y,1,1,_flip)
 pal()
end

function rectfill2(_x,_y,_w,_h,_c)
 --’
 rectfill(_x,_y,_x+max(_w-1,0),_y+max(_h-1,0),_c)
end

function oprint8(_t,_x,_y,_c,_c2)
 for i=1,8 do
  print(_t,_x+dirx[i],_y+diry[i],_c2)
 end 
 print(_t,_x,_y,_c)
end

function dist(fx,fy,tx,ty)
 local dx,dy=fx-tx,fy-ty
 return sqrt(dx*dx+dy*dy)
end

function dofade()
 local p,kmax,col,k=flr(mid(0,fadeperc,1)*100)
 for j=1,15 do
  col = j
  kmax=flr((p+j*1.46)/22)
  for k=1,kmax do
   col=dpal[col]
  end
  pal(j,col,1)
 end
end

function checkfade()
 if fadeperc>0 then
  fadeperc=max(fadeperc-0.04,0)
  dofade()
 end
end

function wait(_wait)
 repeat
  _wait-=1
  flip()
 until _wait<0
end

function fadeout(spd,_wait)
 if (spd==nil) spd=0.04
 if (_wait==nil) _wait=0
 repeat
  fadeperc=min(fadeperc+spd,1)
  dofade()
  flip()
 until fadeperc==1
 wait(_wait)
end

function blankmap(_dflt)
 local ret={} 
 if (_dflt==nil) _dflt=0
 
 for x=0,15 do
  ret[x]={}
  for y=0,15 do
   ret[x][y]=_dflt
  end
 end
 return ret
end


function getrnd(arr)
 return arr[1+flr(rnd(#arr))]
end

function copymap(x,y)
 local tle
 for _x=0,15 do
  for _y=0,15 do
   tle=mget(_x+x,_y+y)
   mset(_x,_y,tle)
   if tle==15 then
    p_mob.x,p_mob.y=_x,_y
   end
  end
 end
end

function explode(s)
 local retval,lastpos={},1
 for i=1,#s do
  if sub(s,i,i)=="," then
   add(retval,sub(s, lastpos, i-1))
   i+=1
   lastpos=i
  end
 end
 add(retval,sub(s,lastpos,#s))
 return retval
end

function explodeval(_arr)
 return toval(explode(_arr))
end

function toval(_arr)
 local _retarr={}
 for _i in all(_arr) do
  add(_retarr,flr(tonum(_i)))
 end
 return _retarr
end

function doshake()
 local shakex,shakey=16-rnd(32),16-rnd(32)
 camera(shakex*shake,shakey*shake)
 shake*=0.95
 if (shake<0.05) shake=0
end
-->8
--gameplay

function moveplayer(dx,dy)
 local destx,desty=p_mob.x+dx,p_mob.y+dy
 local tle=mget(destx,desty)
 
 if iswalkable(destx,desty,"checkmobs") then
  sfx(63)
  mobwalk(p_mob,dx,dy)
  p_t=0
  _upd=update_pturn
 else
  --not walkable
  mobbump(p_mob,dx,dy)
  p_t=0
  _upd=update_pturn  
  local mob=getmob(destx,desty)
  if mob then  
   sfx(58)
   hitmob(p_mob,mob)
  else
   if fget(tle,1) then
    trig_bump(tle,destx,desty)
   else
    skipai=true
    --dig mode baybeee
    --mset(destx,desty,1)
    --mazeworm()
   end
  end
 end
 unfog()
end

function trig_bump(tle,destx,desty)
 if tle==10 or tle==12 then
  --graves
--  sfx(61)
--  mset(destx,desty,tle-1)
--  if rnd(7)<1 then
--   local itm=flr(rnd(#itm_name))+1
--   takeitem(itm)
--   showmsg(itm_name[itm],45)
--  end

  sfx(61)
  mset(destx,desty,tle-1)
  if rnd(3)<1 and floor>0 then
   if rnd(5)<1 then
    addmob(getrnd(mobpool),destx,desty)
    sfx(60)
   else
    if freeinvslot()==0 then
     showmsg("inventory full",120)
     sfx(60)
    else
     sfx(61)
     local itm=getrnd(fipool_com)
     takeitem(itm)
     showmsg(itm_name[itm].."!",60)
    end
   end
  end


 elseif tle==25 or tle==27 or tle==29 or tle==31 then
  --pokeballs
--  sfx(59)
--  mset(destx,desty,tle-1)
--  local itm=flr(rnd(#itm_name))+1
--  takeitem(itm)
--  showmsg(itm_name[itm],45)
 
  if freeinvslot()==0 then
   showmsg("inventory full",120)
   skipai=true
   sfx(60)
  else
   local itm=getrnd(fipool_com)
   if tle==25 or tle==27 then
    itm=getitm_rar()  
   end
   sfx(61)
   mset(destx,desty,tle-1)
   takeitem(itm)
   showmsg(itm_name[itm].."!",60)
  end
 elseif tle==13 then
  --door
  sfx(62)
  mset(destx,desty,1)
 elseif tle==8 then
  --intro sign
  if floor==0 then
   showtalk({" "," the pokemon ","    tower    ","  "," may the souls  ","  of pokemon ","   rest easy  "," ","      f    "," "})
  --save charmander
  end
 elseif tle==110 then
  win=true
 end
end

function trig_step()
 local tle=mget(p_mob.x,p_mob.y)

 if tle==14 then
  sfx(55)
  p_mob.bless=0
  fadeout()
  genfloor(floor+1)
  floormsg()
  return true
 end
 return false
end

function getmob(x,y)
 for m in all(mob) do
  if m.x==x and m.y==y then
   return m
  end 
 end
 return false
end

function iswalkable(x,y,mode)
 local mode = mode or ""
 
 --sight mode
 if inbounds (x,y) then
  local tle=mget(x,y)
  if mode=="sight" then
   return not fget(tle,2)
  else
   if not fget(tle,0) then
    if mode=="checkmobs" then
     return not getmob(x,y)
    end
    return true
   end
  end
 end
 return false
end

function inbounds(x,y)
 return not (x<0 or y<0 or x>15 or y>15)
end


---old code
--function hitmob(atkm,defm)
-- local dmg=atkm.atk
 
function hitmob(atkm,defm,rawdmg)
 local dmg= atkm and atkm.atk or rawdmg

 --add curse/bless
-- if defm.bless<0 then
--  dmg*=2
-- elseif defm.bless>0 then
--  dmg=flr(dmg/2)
-- end
-- defm.bless=0
 
 
 local def=defm.defmin+flr(rnd(defm.defmax-defm.defmin+1))
 dmg-=min(def,dmg)
 --dmg=max(0,dmg)
 
 defm.hp-=dmg
 defm.flash=30
 addfloat("-"..dmg,defm.x*8,defm.y*8,9)
 
 if defm.hp<=0 then
  add(dmob,defm)
  del(mob,defm)
  defm.dur=20
 end
end

function healmob(mb,hp)
 hp=min(mb.hpmax-mb.hp,hp)
 mb.hp+=hp
 mb.flash=20
 
 addfloat("+"..hp,mb.x*8,mb.y*8,11)
 sfx(51)
end

--function stunmob(mb)
-- mb.stun=true
-- mb.flash=10
-- addfloat("stun",mb.x*8-3,mb.y*8,7)
-- sfx(51)
--end

--function blessmob(mb,val)
-- mb.bless=mid(-1,1,mb.bless+val)
-- mb.flash=10
 
-- local txt="bless"
-- if val<0 then txt="curse" end
 
-- addfloat(txt,mb.x*8-6,mb.y*8,7)
 
-- if mb.spec=="ghost" and val>0 then
--  add(dmob,mb)
--  del(mob,mb)
--  mb.dur=10 
-- end
--end


function checkend()
 --’
 if win then
  music(24)
  wind={}
  _upd=update_gover
  _drw=draw_win
  wait(10)
  fadeout(0.02)
  return false
 elseif p_mob.hp<=0 then
  music(22)
  _upd=update_gover
  _drw=draw_gover
  wind={}
  wait(10)
  fadeout(0.02)
  return false
 end
 return true
end

function los(x1,y1,x2,y2)
 local frst,sx,sy,dx,dy=true
 --’
 if dist(x1,y1,x2,y2)==1 then return true end
 if y1>y2 then
  x1,x2,y1,y2=x2,x1,y2,y1
 end
 sy,dy=1,y2-y1

 if x1<x2 then
  sx,dx=1,x2-x1
 else
  sx,dx=-1,x1-x2
 end
 
 local err,e2=dx-dy
 
 while not(x1==x2 and y1==y2) do
  if not frst and iswalkable(x1,y1,"sight")==false then return false end
  e2,frst=err+err,false
  if e2>-dy then
   err-=dy
   x1+=sx
  end
  if e2<dx then 
   err+=dx
   y1+=sy
  end
 end
 return true 
end

function unfog()
 local px,py=p_mob.x,p_mob.y
 for x=0,15 do
  for y=0,15 do 
   --’
   if fog[x][y]==1 and dist(px,py,x,y)<=p_mob.los and los(px,py,x,y) then
    unfogtile(x,y)
   end
  end
 end
end

function unfogtile(x,y)
 fog[x][y]=0
 if iswalkable(x,y,"sight") then
  for i=1,4 do
   local tx,ty=x+dirx[i],y+diry[i]
   if inbounds(tx,ty) and not iswalkable(tx,ty,"sight") then
    fog[tx][ty]=0
   end
  end  
 end
end

function calcdist(tx,ty)
 local cand,step,candnew={},0
 distmap=blankmap(-1)
 add(cand,{x=tx,y=ty})
 distmap[tx][ty]=0
 repeat
  step+=1
  candnew={} 
  for c in all(cand) do
   for d=1,4 do
    local dx=c.x+dirx[d]
    local dy=c.y+diry[d]
    if inbounds(dx,dy) and distmap[dx][dy]==-1 then
     distmap[dx][dy]=step
     if iswalkable(dx,dy) then
      add(candnew,{x=dx,y=dy})
     end
    end
   end
  end
  cand=candnew
 until #cand==0
end

function updatestats()
 local atk,dmin,dmax=1,0,0
 
 if eqp[1] then
  atk+=itm_stat1[eqp[1]]
 end
 
 if eqp[2] then
  dmin+=itm_stat1[eqp[2]]
  dmax+=itm_stat2[eqp[2]]
 end

 p_mob.atk=atk
 p_mob.defmin=dmin
 p_mob.defmax=dmax 
end

function eat(itm,mb)
 local effect=itm_stat1[itm]
 
-- if not itm_known[itm] then
--  showmsg(itm_name[itm]..itm_desc[itm],120)
--  itm_known[itm]=true
-- end  
 
-- if mb==p_mob then st_meals+=1 end
 
 if effect==1 then
  --heal
  healmob(mb,1)
 elseif effect==2 then
  --heal a lot
  healmob(mb,3)
 elseif effect==3 then
  --plus maxhp
  mb.hpmax+=1
  healmob(mb,1)
  del(wind,hpwind)
  hpwind=addwind(5,5,36,13,{})
-- elseif effect==4 then
  --stun
--  stunmob(mb)
-- elseif effect==5 then
  --curse
--  blessmob(mb,-1)
-- elseif effect==6 then  
  --bless
--  blessmob(mb,1)
 end
end

function throw()
 local itm,tx,ty=inv[thrslt],throwtile()
 sfx(52)
 if inbounds(tx,ty) then
  local mb=getmob(tx,ty)
  if mb then
   if itm_type[itm]=="fud" then
    eat(itm,mb)
   else
    hitmob(nil,mb,itm_stat1[itm])
    addfloat("oof!",tx*8-2,ty*8-7,9)
    sfx(58)
   end
  end
 end
 mobbump(p_mob,thrdx,thrdy)
 
 inv[thrslt]=nil
 p_t=0
 _upd=update_pturn
end

function throwtile()
 local tx,ty=p_mob.x,p_mob.y
 repeat
  tx+=thrdx
  ty+=thrdy
 until not iswalkable(tx,ty,"checkmobs")
 return tx,ty
end
-->8
--ui

function addwind(_x,_y,_w,_h,_txt)
 local w={x=_x,
          y=_y,
          w=_w,
          h=_h,
          txt=_txt}
 add(wind,w)
 return w
end

function drawind()
 for w in all(wind) do
  local wx,wy,ww,wh=w.x,w.y,w.w,w.h
  rectfill2(wx,wy,ww,wh,0)
  rect(wx+1,wy+1,wx+ww-2,wy+wh-2,6)
  wx+=4
  wy+=4
  clip(wx,wy,ww-8,wh-8)
  if w.cur then
   wx+=6
  end
  for i=1,#w.txt do
   local txt,c=w.txt[i],6
   if w.col and w.col[i] then
    c=w.col[i]
   end
   print(txt,wx,wy,c)
   if i==w.cur then
    spr(249,wx-5+sin(time()),wy)
   end
   wy+=6
  end
  clip()
 
  if w.dur then
   w.dur-=1
   if w.dur<=0 then
    local dif=w.h/4
    w.y+=dif/2
    w.h-=dif
    if w.h<3 then
     del(wind,w)
    end
   end
  else
   if w.butt then
    oprint8("—",wx+ww-15,wy-1+sin(time()),6,0)
   end
  end
 end
end

function showmsg(txt,dur)
 local wid=(#txt+2)*4+7
 local w=addwind(63-wid/2,50,wid,13,{" "..txt})
 w.dur=dur 
end

function showtalk(txt)
 talkwind=addwind(32,50,64,#txt*6+7,txt)
 talkwind.butt=true 
end

function addfloat(_txt,_x,_y,_c)
 add(float,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0})
end

function dofloats()
 for f in all(float) do
  f.y+=(f.ty-f.y)/10
  f.t+=1
  if f.t>35 then
   del(float,f)
  end
 end
end

function dohpwind()
 hpwind.txt[1]="‡"..p_mob.hp.."/"..p_mob.hpmax
 local hpy=5
 if p_mob.y<8 then
  hpy=110
 end
 hpwind.y+=(hpy-hpwind.y)/5
end

function showinv()
 local txt,col,itm,eqt={},{}
 _upd=update_inv
 for i=1,2 do
  itm=eqp[i]
  if itm then
   eqt=itm_name[itm]
   add(col,6)
  else
   eqt= i==1 and "[weapon]" or "[armor]"
   add(col,5)
  end
  add(txt,eqt)
 end
 add(txt,"")
 add(col,6)
 for i=1,6 do
  itm=inv[i]
  if itm then
   add(txt,itm_name[itm])
   add(col,6)
  else
   add(txt,"...")
   add(col,5)
  end
 end
 

 invwind=addwind(5,17,84,62,txt)
 invwind.cur=3
 invwind.col=col

-- txt="ok    "
-- if p_mob.bless<0 then
--  txt="curse "
-- elseif p_mob.bless>0 then
--  txt="bless "
-- end
   
 statwind=addwind(5,5,84,13,{"atk:"..p_mob.atk.." def:"..p_mob.defmin.."-"..p_mob.defmax})

 curwind=invwind
end

function showuse()
 local itm=invwind.cur<3 and eqp[invwind.cur] or inv[invwind.cur-3]
 if itm==nil then return end
 local typ,txt=itm_type[itm],{}
 if (typ=="wep" or typ=="arm") and invwind.cur>3 then
  add(txt,"equip")
 end
 if typ=="fud" then
  add(txt,"eat")
 end
 if typ=="thr" or typ=="fud" then
  add(txt,"throw")
 end
 add(txt,"trash")

 usewind=addwind(84,invwind.cur*6+11,36,7+#txt*6,txt)
 usewind.cur=1
 curwind=usewind 
end

function triguse()
 local verb,i,back=usewind.txt[usewind.cur],invwind.cur,true
 local itm=i<3 and eqp[i] or inv[i-3]
 
 if verb=="trash" then
  if i<3 then
   eqp[i]=nil
  else
   inv[i-3]=nil
  end
 elseif verb=="equip" then
  local slot=2
  if itm_type[itm]=="wep" then
   slot=1
  end
  inv[i-3]=eqp[slot]
  eqp[slot]=itm
 elseif verb=="eat" then
  eat(itm,p_mob) 
  _upd,inv[i-3],p_mob.mov,p_t,back=update_pturn,nil,nil,0,false
 elseif verb=="throw" then
  _upd,thrslt,back=update_throw,i-3,false
 end
 
 updatestats()
 usewind.dur=0
 
 if back then
  del(wind,invwind)
  del(wind,statwind)
  showinv()
  invwind.cur=i
--  showhint()
 else
  invwind.dur=0
  statwind.dur=0
--  if hintwind then
--   hintwind.dur=0
--  end
 end
end

function floormsg()
 showmsg("floor "..floor,120)
end

--function showhint()
-- if hintwind then
--  hintwind.dur=0
--  hintwind=nil
-- end
 
-- if invwind.cur>3 then
--  local itm=inv[invwind.cur-3]
  
--  if itm and itm_type[itm]=="fud" then
--   local txt=itm_known[itm] and itm_name[itm]..itm_desc[itm] or "???"
--   hintwind=addwind(5,78,#txt*4+7,13,{txt})
--  end
 
-- end
 
--end
-->8
--mobs and items

function addmob(typ,mx,my)
 local m={
  x=mx,
  y=my,
  ox=0,
  oy=0,
  flp=false,
  ani={},
  flash=0,
  hp=mob_hp[typ],
  hpmax=mob_hp[typ],
  atk=mob_atk[typ],
  defmin=0,
  defmax=0,
  los=mob_los[typ],
  task=ai_wait
 }
 for i=0,3 do
  add(m.ani,mob_ani[typ]+i)
 end
 add(mob,m)
 return m
end

function mobwalk(mb,dx,dy)
 mb.x+=dx --?
 mb.y+=dy
 
 mobflip(mb,dx)
 mb.sox,mb.soy=-dx*8,-dy*8
 mb.ox,mb.oy=mb.sox,mb.soy
 mb.mov=mov_walk
end

function mobbump(mb,dx,dy)
 mobflip(mb,dx)
 mb.sox,mb.soy=dx*8,dy*8
 mb.ox,mb.oy=0,0
 mb.mov=mov_bump
end

function mobflip(mb,dx)
 mb.flp = dx==0 and mb.flp or dx<0
end

function mov_walk(self)
 local tme=1-p_t 
 self.ox=self.sox*tme
 self.oy=self.soy*tme
end

function mov_bump(self)
 --’ 
 local tme= p_t>0.5 and 1-p_t or p_t
 self.ox=self.sox*tme
 self.oy=self.soy*tme
end

function doai()
 local moving=false
 for m in all(mob) do
  if m!=p_mob then
   m.mov=nil
   moving=m.task(m) or moving 
  end
  if moving then
   _upd=update_aiturn
   p_t=0
  end
 end
end


function ai_wait(m)
 if cansee(m,p_mob) then
  --aggro
  m.task=ai_attac
  m.tx,m.ty=p_mob.x,p_mob.y
  addfloat("!",m.x*8+2,m.y*8,8)
  return true
 end
 return false
end

function ai_attac(m)  
 if dist(m.x,m.y,p_mob.x,p_mob.y)==1 then
  --attack player
  local dx,dy=p_mob.x-m.x,p_mob.y-m.y
  mobbump(m,dx,dy)
  hitmob(m,p_mob)
  _upd=update_aiturn  
  sfx(57)
  return true
 else
  --move to player
  if cansee(m,p_mob) then 
   m.tx,m.ty=p_mob.x,p_mob.y
  end
  if m.x==m.tx and m.y==m.ty then
   --de aggro
   m.task=ai_wait
   addfloat("?",m.x*8+2,m.y*8,8)
  else 
   local bdst,cand=999,{}
   calcdist(m.tx,m.ty)  
   for i=1,4 do
    local dx,dy=dirx[i],diry[i]
    local tx,ty=m.x+dx,m.y+dy
    if iswalkable(tx,ty,"checkmobs") then
     local dst=distmap[tx][ty]
     if dst<bdst then
      cand={}
      bdst=dst
     end
     if dst==bdst then
      add(cand,i)
     end
    end
   end
   if #cand>0 then
    local c=getrnd(cand)
    mobwalk(m,dirx[c],diry[c])
    return true
   end
  end
 end
 return false
end

function cansee(m1,m2)
 return dist(m1.x,m1.y,m2.x,m2.y)<=m1.los and los(m1.x,m1.y,m2.x,m2.y)
end

--function spawnmobs()
-- local minmons=6
-- local placed,rpot=0,{}
 
-- for r in all(rooms) do
--  add(rpot,r)
-- end
 
-- repeat
--  local r=getrnd(rpot)
--  placed+=infestroom(r)
--  del(rpot,r)
-- until #rpot==0 or placed>minmons
--end

function spawnmobs()
 
 mobpool={}
 for i=2,#mob_name do
  if mob_minf[i]<=floor and mob_maxf[i]>=floor then
   add(mobpool,i)
  end
 end
 
 if #mobpool==0 then return end
 
 local minmons=explodeval("3,5,7,9,10,11,12,13")
 local maxmons=explodeval("6,10,14,18,20,22,24,26")
 
 local placed,rpot=0,{}
 
 for r in all(rooms) do
  add(rpot,r)
 end
 
 repeat
  local r=getrnd(rpot)
  placed+=infestroom(r)
  del(rpot,r)
 until #rpot==0 or placed>maxmons[floor]
 
 if placed<minmons[floor] then
  repeat
   local x,y
   repeat
    x,y=flr(rnd(16)),flr(rnd(16))
   until iswalkable(x,y,"checkmobs") and (mget(x,y)==1 or mget(x,y)==4)
   addmob(getrnd(mobpool),x,y)
   placed+=1
  until placed>=minmons[floor]
 end
end

--function spawnmobs()
 
-- mobpool={}
-- for i=2,#mob_name do
--  if mob_minf[i]<=floor and mob_maxf[i]>=floor then
--   add(mobpool,i)
--  end
-- end
 
-- if #mobpool==0 then return end
 
-- local minmons=explodeval("3,5,7,9,10,11,12,13")
-- local maxmons=explodeval("6,10,14,18,20,22,24,26")
 
-- local placed,rpot=0,{}
 
-- for r in all(rooms) do
--  add(rpot,r)
-- end
 
-- repeat
--  local r=getrnd(rpot)
--  placed+=infestroom(r)
--  del(rpot,r)
-- until #rpot==0 or placed>maxmons[floor]
 
-- if placed<minmons[floor] then
--  repeat
--   local x,y
--   repeat
--    x,y=flr(rnd(16)),flr(rnd(16))
--   until iswalkable(x,y,"checkmobs") and (mget(x,y)==1 or mget(x,y)==4)
--   addmob(getrnd(mobpool),x,y)
--   placed+=1
--  until placed>=minmons[floor]
-- end
--end

function infestroom(r)
 local target=2+flr(rnd(3))
 local x,y
 
 for i=1,target do
  repeat
   x=r.x+flr(rnd(r.w))
   y=r.y+flr(rnd(r.h))
  until iswalkable(x,y,"checkmobs")
  addmob(getrnd(mobpool),x,y)
 end
 
 return target
end

-------------------------------
--items
-------------------------------

function takeitem(itm)
 local i=freeinvslot()
 if i==0 then return false end
 inv[i]=itm
 return true
end

function freeinvslot()
 for i=1,6 do
  if not inv[i] then
   return i
  end
 end
 return 0
end

--function foodnames()
-- local fud,fu=explode("jerky,schnitzel,steak,gyros,fricassee,haggis,mett,kebab,burger,meatball,pizza,calzone,pasticio,chops,hams,ribs,roast,meatloaf,chili,stew,pie,wrap,taco,burrito,rolls,filet,salami,sandwich,casserole,spam,souvlaki")
-- local adj,ad=explode("yellow,green,blue,purple,black,sweet,salty,spicy,strange,old,dry,wet,smooth,soft,crusty,pickled,sour,leftover,mom's,steamed,hairy,smoked,mini,stuffed,classic,marinated,bbq,savory,baked,juicy,sloppy,cheesy,hot,cold,zesty") 


----- –––––––––––

function makeipool()
 ipool_rar={}
 ipool_com={}
 
 for i=1,#itm_name do
  local t=itm_type[i]
  if t=="wep" or t=="arm" then
   add(ipool_rar,i)
  else
   add(ipool_com,i)  
  end
 end
end

function makefipool()
 fipool_rar={}
 fipool_com={}
 
 for i in all(ipool_rar) do
  if itm_minf[i]<=floor 
   and itm_maxf[i]>=floor then
   add(fipool_rar,i)
  end
 end
 for i in all(ipool_com) do
  if itm_minf[i]<=floor 
   and itm_maxf[i]>=floor then
   add(fipool_com,i)
  end
 end
end

function getitm_rar()
 if #fipool_rar>0 then
  local itm=getrnd(fipool_rar)
  del(fipool_rar,itm)
  del(ipool_rar,itm)
  return itm
 else
  return getrnd(fipool_com)
 end
end


----- –––––––––––

function foodnames()
 local fud,fu=explode("jerky,schnitzel,steak,gyros,fricassee,haggis,mett,kebab,burger,meatball,pizza,calzone,pasticio,chops,hams,ribs,roast,meatloaf,chili,stew,pie,wrap,taco,burrito,rolls,filet,salami,sandwich,casserole,spam,souvlaki")
 local adj,ad=explode("yellow,green,blue,purple,black,sweet,salty,spicy,strange,old,dry,wet,smooth,soft,crusty,pickled,sour,leftover,mom's,steamed,hairy,smoked,mini,stuffed,classic,marinated,bbq,savory,baked,juicy,sloppy,cheesy,hot,cold,zesty") 

 itm_known={}

 for i=1,#itm_name do
  if itm_type[i]=="fud" then
   fu,ad=getrnd(fud),getrnd(adj)
   del(fud,fu)
   del(adj,ad)
   itm_name[i]=ad.." "..fu
   itm_known[i]=false
  end
 end
end
-->8
--level generation

function genfloor(f)
 floor=f
 makefipool()
 mob={}
 add(mob,p_mob)
 fog=blankmap(0)
 if floor==1 then 
  st_steps=0
  poke(0x3101,66)
 end
 if floor==0 then  
  copymap(16,0)
 elseif floor==winfloor then
  copymap(32,0)
  if mget(x,y)==212 then
   addmob(8,x,y)
   mset(x,y,1)
  elseif mget(x,y)==220 then
   addmob(9,x,y)
   mset(x,y,1)
  end
 else
  fog=blankmap(1)
  mapgen()
  unfog()
	end
end
  
-------””””” map reveal


function mapgen()

 repeat
  copymap(48,0)
  rooms={}
  roomap=blankmap(0)
  doors={}
  genrooms()
  mazeworm() 
  placeflags()
  carvedoors()
 until #flaglib==1
 
 carvescuts()
 startend()
 fillends()
-- prettywalls()

 installdoors()
 
 spawnchests()
 spawnmobs()
 decorooms()
end

----------------
-- rooms
----------------

function genrooms()

--tweak if you want

 local fmax,rmax=5,4 --5,4?
 local mw,mh=10,10 --5,5?
 
 repeat
  local r=rndroom(mw,mh)
  if placeroom(r) then
   if #rooms==1 then
    mw/=2
    mh/=2
   end
   rmax-=1
  else
   fmax-=1
   --’
   if r.w>r.h then
    mw=max(mw-1,3)
   else
    mh=max(mh-1,3)
   end
  end
 until fmax<=0 or rmax<=0
end

function rndroom(mw,mh)
 --clamp max area
 local _w=3+flr(rnd(mw-2))
 mh=mid(35/_w,3,mh)
 local _h=3+flr(rnd(mh-2))
 return {
  x=0,
  y=0,
  w=_w,
  h=_h
 }
end

function placeroom(r)
 local cand,c={}
 
 for _x=0,16-r.w do
  for _y=0,16-r.h do
   if doesroomfit(r,_x,_y) then
    add(cand,{x=_x,y=_y})
   end
  end
 end
 
 if #cand==0 then return false end
 
 c=getrnd(cand)
 r.x=c.x
 r.y=c.y
 add(rooms,r) 
 for _x=0,r.w-1 do
  for _y=0,r.h-1 do
   mset(_x+r.x,_y+r.y,1)
   roomap[_x+r.x][_y+r.y]=#rooms
  end
 end
 return true
end

function doesroomfit(r,x,y)
 for _x=-1,r.w do
  for _y=-1,r.h do
   if iswalkable(_x+x,_y+y) then
    return false
   end
  end
 end
 
 return true
end

----------------
-- maze
----------------

function mazeworm()
 repeat
  local cand={}
  for _x=0,15 do
   for _y=0,15 do
    if cancarve(_x,_y,false) and not nexttoroom(_x,_y) then
     add(cand,{x=_x,y=_y})
    end
   end
  end
 
  if #cand>0 then
   local c=getrnd(cand)
   digworm(c.x,c.y)
  end
 until #cand<=1
end

function digworm(x,y)
 local dr,stp=1+flr(rnd(4)),0
 
 repeat
  mset(x,y,1)
  if not cancarve(x+dirx[dr],y+diry[dr],false) or (rnd()<0.5 and stp>2) then
   stp=0
   local cand={}
   for i=1,4 do
    if cancarve(x+dirx[i],y+diry[i],false) then
     add(cand,i)
    end
   end
   if #cand==0 then
    dr=8
   else
    dr=getrnd(cand)
   end
  end
  x+=dirx[dr]
  y+=diry[dr]
  stp+=1
 until dr==8 
end

function cancarve(x,y,walk)
 if not inbounds(x,y) then return false end
 local walk= walk==nil and iswalkable(x,y) or walk
 
 if iswalkable(x,y)==walk then
  local sig=getsig(x,y)
  for i=1,#crv_sig do
   if bcomp(sig,crv_sig[i],crv_msk[i]) then 
    return true 
   end
  end
 end
 return false
end

function bcomp(sig,match,mask)
 local mask=mask and mask or 0
 return bor(sig,mask)==bor(match,mask)
end

function getsig(x,y)
 local sig,digit=0
 for i=1,8 do
  local dx,dy=x+dirx[i],y+diry[i]
  --’
  if iswalkable(dx,dy) then
   digit=0
  else
   digit=1
  end
  sig=bor(sig,shl(digit,8-i))
 end
 return sig
end

--function sigarray(sig,arr,marr)
-- for i=1,#arr do
--  if bcomp(sig,arr[i],marr[i]) then 
--   return i
--  end
-- end
-- return 0
--end


----------------
-- doorways
----------------

function placeflags()
 local curf=1
 flags,flaglib=blankmap(0),{}
 for _x=0,15 do
  for _y=0,15 do
   if iswalkable(_x,_y) and flags[_x][_y]==0 then
    growflag(_x,_y,curf)
    add(flaglib,curf)
    curf+=1
   end
  end
 end
end

function growflag(_x,_y,flg)
 local cand,candnew={{x=_x,y=_y}}
 flags[_x][_y]=flg
 repeat
  candnew={}
  for c in all(cand) do
   for d=1,4 do
    local dx,dy=c.x+dirx[d],c.y+diry[d]
    if iswalkable(dx,dy) and flags[dx][dy]!=flg then
     flags[dx][dy]=flg
     add(candnew,{x=dx,y=dy})
    end
   end
  end
  cand=candnew
 until #cand==0
end

function carvedoors()
 local x1,y1,x2,y2,found,_f1,_f2,drs=1,1,1,1
 repeat
  drs={}
  for _x=0,15 do
   for _y=0,15 do
    if not iswalkable(_x,_y) then
     local sig=getsig(_x,_y)
     found=false
     if bcomp(sig,0b11000000,0b00001111) then
      x1,y1,x2,y2,found=_x,_y-1,_x,_y+1,true
     elseif bcomp(sig,0b00110000,0b00001111) then
      x1,y1,x2,y2,found=_x+1,_y,_x-1,_y,true
     end
     _f1=flags[x1][y1]
     _f2=flags[x2][y2]
     if found and _f1!=_f2 then
      add(drs,{x=_x,y=_y,f1=_f1,f2=_f2})
     end
    end
   end
  end
  
  if #drs>0 then
   local d=getrnd(drs)
   --’
   add(doors,d)
   mset(d.x,d.y,1)
   growflag(d.x,d.y,d.f1)
   del(flaglib,d.f2)
  end
 until #drs==0
end

function carvescuts()
 local x1,y1,x2,y2,cut,found,drs=1,1,1,1,0
 repeat
  drs={}
  for _x=0,15 do
   for _y=0,15 do
    if not iswalkable(_x,_y) then
     local sig=getsig(_x,_y)
     found=false
     if bcomp(sig,0b11000000,0b00001111) then
      x1,y1,x2,y2,found=_x,_y-1,_x,_y+1,true
     elseif bcomp(sig,0b00110000,0b00001111) then
      x1,y1,x2,y2,found=_x+1,_y,_x-1,_y,true
     end
     if found then
      calcdist(x1,y1)
      if distmap[x2][y2]>20 then
       add(drs,{x=_x,y=_y})
      end
     end
    end
   end
  end
  
  if #drs>0 then
   local d=getrnd(drs)
   add(doors,d)
   mset(d.x,d.y,1)
   cut+=1
  end
 until #drs==0 or cut>=3
end

function fillends()
 local filled,tle
 repeat
  filled=false
  for _x=0,15 do
   for _y=0,15 do
    tle=mget(_x,_y)
    --’
    if cancarve(_x,_y,true) and tle!=14 and tle!=15 then
     filled=true
     mset(_x,_y,2)
    end
   end
  end
 until not filled
end

function isdoor(x,y)
 local sig=getsig(x,y)
 if bcomp(sig,0b11000000,0b00001111) or bcomp(sig,0b00110000,0b00001111) then
  return nexttoroom(x,y)
 end
 return false
end

function nexttoroom(x,y,dirs)
 local dirs = dirs or 4
 for i=1,dirs do
  if inbounds(x+dirx[i],y+diry[i]) and 
     roomap[x+dirx[i]][y+diry[i]]!=0 then
   return true
  end
 end
 return false
end

function installdoors()
 for d in all(doors) do
  if mget(d.x,d.y)==1 and isdoor(d.x,d.y) then
   mset(d.x,d.y,13)
  end
 end
end

--function installdoors()
-- for d in all(doors) do
--  local dx,dy=d.x,d.y
--  if (mget(dx,dy)==1 
--   or mget(dx,dy)==4)
--   and isdoor(dx,dy) 
--   and not next2tile(dx,dy,13) then
   
--   mset(dx,dy,13)
--  end
-- end
--end

----------------
-- decoration
----------------

--function startend()
-- local high,low,px,py,ex,ey=0,9999
-- repeat
--  px,py=flr(rnd(16)),flr(rnd(16))
-- until iswalkable(px,py)
-- calcdist(px,py)
-- --’
-- for x=0,15 do
--  for y=0,15 do
--   local tmp=distmap[x][y]
--   if iswalkable(x,y) and tmp>high then
--    px,py,high=x,y,tmp
--   end
--  end
-- end 
-- calcdist(px,py)
-- high=0
-- for x=0,15 do
--  for y=0,15 do
--   local tmp=distmap[x][y]
--   if tmp>high and cancarve(x,y) then
--    ex,ey,high=x,y,tmp
--   end
--  end
-- end
-- mset(ex,ey,14)
-- 
-- for x=0,15 do
--  for y=0,15 do
--   local tmp=distmap[x][y]
--   if tmp>=0 and tmp<low and cancarve(x,y) then
--    px,py,low=x,y,tmp
--   end
--  end
-- end  
-- --’
-- mset(px,py,15)
-- p_mob.x=px
-- p_mob.y=py
--end

function startend()
 local high,low,px,py,ex,ey=0,9999
 repeat
  px,py=flr(rnd(16)),flr(rnd(16))
 until iswalkable(px,py)
 calcdist(px,py)
 --’
 for x=0,15 do
  for y=0,15 do
  
   local tmp=distmap[x][y]
   if iswalkable(x,y) and tmp>high then
    px,py,high=x,y,tmp

   end
  end
 end 
 calcdist(px,py)
 high=0
 for x=0,15 do
  for y=0,15 do
   local tmp=distmap[x][y]
   if tmp>high and cancarve(x,y) then
    ex,ey,high=x,y,tmp
   end
  end
 end
 mset(ex,ey,14)
 
 for x=0,15 do
  for y=0,15 do

   local tmp=distmap[x][y]
   if tmp>=0 and tmp<low and cancarve(x,y) then
    px,py,low=x,y,tmp
   end
  end
 end
 
 if roomap[px][py]>0 then
  rooms[roomap[px][py]].nospawn=true
 end
 mset(px,py,15)
 p_mob.x,p_mob.y=px,py
end

--decorations suck


--necessary decorations

function decorooms()


 tarr_vase=explodeval("1,1,10,12")
 local funcs,func,rpot={
  deco_torch,
  deco_vase
 },deco_vase,{}

 for r in all(rooms) do
  add(rpot,r)
 end

 repeat
  local r=getrnd(rpot)
  del(rpot,r)
  for x=0,r.w-1 do
   for y=r.h-1,1,-1 do
    if mget(r.x+x,r.y+y)==1 then
     func(r,r.x+x,r.y+y,x,y)
    end
   end
  end
  func=getrnd(funcs)
 until #rpot==0
end

function next2tile(_x,_y,tle)
 for i=1,4 do
  if inbounds(_x+dirx[i],_y+diry[i]) and mget(_x+dirx[i],_y+diry[i])==tle then
   return true
  end
 end
 return false
end

function deco_torch(r,tx,ty,x,y)
 if rnd(3)>1 and y%2==1 and not next2tile(tx,ty,13) then
  if x==0 then
   mset(tx,ty,64)
  elseif x==r.w-1 then
   mset(tx,ty,66)
  end
 end
end

function deco_vase(r,tx,ty,x,y)
 if iswalkable(tx,ty,"checkmobs") and 
    not next2tile(tx,ty,13) and
    not bcomp(getsig(tx,ty),0,0b00001111) then
   
  mset(tx,ty,getrnd(tarr_vase))
 end
end

function spawnchests()
 local chestdice,rpot,rare,place=explodeval("0,1,1,1,2,3"),{},true
 place=getrnd(chestdice)
 
 for r in all(rooms) do
  add(rpot,r)
 end
 
 while place>0 and #rpot>0 do
  local r=getrnd(rpot)
  placechest(r,rare)
  rare=false
  place-=1
  del(rpot,r)
 end
end

function placechest(r,rare)
 local x,y
 repeat
  x=r.x+flr(rnd(r.w-2))+1
  y=r.y+flr(rnd(r.h-2))+1
 until mget(x,y)==1
 mset(x,y,rare and 25 or 27 or 29)
end
__gfx__
0000000000000000ddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000044444000000000055555550
00000000000000000d0000000000000000000000000000000000000000000000444444440000000000000000000000000000000040000040a000000000000050
0070070000000000ddddddd00000000000000000000000000000000000000000400040040000000000555000000000000004000040444040a000000050000050
0007700000000000000d00000000000000000000000000000000000000000000444444440000000005555500000000000044400040404040a0a0000055000050
0007700000005000ddddddd00000000000000000000000000000000000000000400404440000000005555500000000000004000040404040a0aa000055050050
007007000005000000000d000000000000000000000000000000000000000000444444440005550005555500000400000004000040404040a0aa0a0055055050
0000000000000000ddddddd00000000000000000000000000000000000000000000440005055555005555500044440400004000040404040a0aa0aa055055050
00000000000000000000000000000000000000000000000000000000000000000004400000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000008888000000000000cccc000000000000a55a000000000000822800
000000000000000000000000000000000000000000000000000000000000000000000000088888800000000008cccc800000000005a55a500000000008822880
0000000000000000000000000000000000000000000000000000000000000000000000008888888800000000cc8cc8cc0000000055a55a550000000088222288
0000000000000000000000000000000000000000000000000000000000000000000660008886688800066000ccc66ccc0006600055a66a550006600022266222
00000000000000000000000000000000000000000000000000000000000000007776677777766777777667777776677777766777777667777776677777766777
00000000000000000000000000000000000000000000000000000000000000007777777777777777777777777777777777777777777777777777777777777777
00000000000000000000000000000000000000000000000000000000000000000777777007777770077777700777777007777770077777700777777007777770
00000000000000000000000000000000000000000000000000000000000000000077770000777700007777000077770000777700007777000077770000777700
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
0a0000000000000000000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a00000000a000000000000a000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99000000a900000000000990000009a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44000000440000000000044000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000000500000005000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40000000400000000000004000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0088880a0888800
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a087788aa877880
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900870889a870880
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800888888088e800
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000880080088008
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008808880880888000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888880088888000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088088008808800
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0088880a0888800
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a087788aa877880
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900870889a870880
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800888888088e800
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000880080088008
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008808880880888000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888880088888000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088088008808800
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000822800000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008822880000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088222288000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022266222000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077766777000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777777000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007777770000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777700000000000000000000000000
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
d00dd0000d0dd0d000d00d000d000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d0d0111d00d00d0000d00d000000000000000000000000000000000000000d0000000d00000000d000000dd00000ff00ff000f000f00ff00ff0f000f00
0d111d00017111d00d111d000dd00dd001d0d1000110110001d0d100000000000d0ddd0000dd0d000d0ddd000d0ddd000f000f0000f000f00f000f000f0f0f0f
d17171d0d10171d0d11171d0d11111101d000d10111111101d000d10101110100666660006666600066666000666660000fff0f000fff0f000fff0f000fff0f0
1101011001110100117101101171711111111110d11111d011111110111111106666a660666a66606666a66066666a600f1fff0f0fffff0f0fff1f0f0f1f1f0f
11111110011111d01101111011010111101110100d717d0010111010d17171d066a6a6606a6a666066a6a660666a6a600fff1f0f0f1f1f0f0f1fff0f0ff0ff0f
011111d000111000011111d0011111100071700000000000007170000d101d00066666000666660006666600066666000f0ffff00ff0fff00fff0ff00ffffff0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000066000000000000000000010001001000001001000100100000100000011001100000000001100000111001000100000000001111111010010010
00066000000ddd000006600000000000111111101111111011111110110001100110110017110000011011000111110011111110110101100181810011111110
000ddd0000daddd0000ddd0000066000017171001111111001717100111111101711111011111110171111101711111001111100111111100111110001111100
00daddd000ddddd000daddd0000ddd000101010001717100010101000171710011111000001111001111100011111000018181100111110001eee11011818100
00ddddd0000d0d0000ddddd000daddd00011100101010100001110010181810000111000081011100011100000110100111111101181810011eee11011111110
000d0d0000d0d0d0000d0d0000ddddd00000001000111001100000100011100008100100111000000010010008100000111111001111111011ee110001111110
00d0d0d00000000000d0d0d0000d0d00100000001000001001000000100000011110000000000000081000001110000001111100011111100111110001111100
00000000000000000000000000d0d0d0010000000100000000000000010000100000000000000000111000000000000001000100010001000010100001000100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb03330000000000bb03330
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb03330bbbb37330bb03330bbbb3733
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbb3733bbbb3833bbbb3333bbbb3833
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbb3833bbbb3333bbbb3333bbbb3333
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb333333bb333000bb333333bb333000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333000033330000333300003303000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003300300033033000300330003303300
00000000000000000000000000000000000000000000000000000000000000000000000008880000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000087888000000080000080000000000000000033300000000000003330
000000000000000000000000000000000000000000000000000000000000000000000000888880008000000000000800000033300bb03733000033300bb03733
0000000000000000000000000000000000000000000000000000000000000000000000007888800008000080000000000bb03733bbbb38330bb03733bbbb3833
000000000000000000000000000000000000000000000000000000000000000000000000777770000000080000000000bbbb3833bbbb3333bbbb3833bbbb3333
000000000000000000000000000000000000000000000000000000000000000000000000077700000008000000000000bbbb3333bbbb3000bbbb3333bbbb3000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333000033330000333300003303000
00000000000000000000000000000000000000000000000000000000000000000000000000000000080000800000000003300300033033000300330003303300
__gff__
0000050000000000030003000307020000000000000000000103010301030103000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030000000000000000000000000000030300000000000000000000000003000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020f0101010d01010a0a020c01c00e0200000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020101010c0201010a0a020101c0c00200000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020101010c020c01010102010101010200000000000002020200000000000000000000000000020202000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020101010a020c01010c020c0c010102000000020202020e0202020200000000000000020202026e02020202000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020101010102020d0202020202020d0200000002010101010101010200000000000000020101010101010102000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020c01010a0201010102010d0101010200000002010101010101010200000000000000020101010101010102000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020c010c0a020101010201020d02020200000002010101080101010200000000000000020201010101010202000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020d02020201c001020102c0c00a0200000002010101010101010200000000000000020201010101010202000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010d01010102010201010102000000020c01010101010c0200000000000000020201010101010202000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d020202020201010102010201010102000000020c0c0101010c0c0200000000000000020202010101020202000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101010202020d020201020101010200000002020202010202020200000000000000000002010f01020000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101020101010102010d01190102000000000000020f0200000000000000000000000002020202020000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010102011f01c0020102c001010200000000000002020200000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101010d01c001010d010201010c0200000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010200000c40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010010130510005003c50037500375101f0003b5003c5003b51036500000001e0003651000000000000000030510005003c50037500375101f0003b5003c5003b51036500000001e00036510000000000000000
00100000297202873026720267402f7402d7302972021730267302673026730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000e1100d120161300e1300d1300010016120151300e1200e1200e130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001e0201e0201e030210401a0401e0401f0301f0301f0301f0301e0201e0201f0201f020210302103022030290202902029020290202902028020280202602026020260200000000000000000000000000
001000001303013030130301303013030130301303013030130301303013030130301303013030130301303012030120301203012030120301203012030120301203012030120301203012030120301203012030
00100000100301003010030100301003010030100301003013030130301303013030130301303013030130300e0300e0300e0300e0300e0300e0300e0300e0301203012030120301203012030120301203012030
000f00001c7001c7001c7001c7001e7001e7001e7001e7001c7001c7001c7001c700237002370023700237001c7001c7001c7001c70018700187001870018700197001970019700197001c7001c7001c7001c700
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
01020000255302553000000000002f5302f5300000000000317003170031720317203172031720317203172031700317003170031700317003170000000000000000000000000000000000000000000000000000
01010000305402f5402e5402c5402b540285402554023540205401e5401b540195401954019540175401654015540115400d5400d540005000050000500005000050000500005000060000500005000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000024510330203302033020270103a0103a71000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000009620056300562005610006000060000600006000060000600006000060001620006200a6100060000600006000060000600006000060000600026100261000600006000060000600006000060000000
01010000145201b520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001c1301c13011130261300e7100e71018710107100c6000a60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000b6200b6500b6500000011610106101160010600317003170031700317000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000230102601028010290102370032500395002750027500285002a500005000050000500275002950029500005000050000500005002450024500245002750029500005000050000500005000050000500
0101000027030270301b0301b0302d2102c2102a2102921025210202101821013210112100f2100f2100e2100e2100e2100e2100e2100e2100d2100d2100c2100b2100b210000000000000000000000000000000
010600001d7301f730217001160039000390003a0003000030000300002d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000210302703025000230001a000190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000d710137100d7100c40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 01 42 43 44
03 01 05 06 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 02 03 44
00 41 42 43 44
00 04 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
