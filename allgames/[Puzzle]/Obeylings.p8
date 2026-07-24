pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--obeylings 1.1
--by jeb

-- added hover
-- ladder prediction
-- crate on m3
-- m5 tweak
-- m9 tweak

debug=""
poke(0x5f2d, 1)
cartdata("jeb_obeylings")

--[[
 unpack logic, thanks brynolf brothers
]]
str_num={}
function tostr(v)
 return v..""
end
for i=-20,255 do
 str_num[tostr(i)] = i
end
for i=-200,2500,10 do
 str_num[tostr(i)] = i
end

function unp(data)
 local p,toks,tab = 1,{},{}
 --tokenize
 while #data > 0 do
  while p <= #data do
   local c = sub(data,p,p)
   if c == "," or (c == " " and p <= 1) then
    break
   end
   p += 1
  end

  if p > 1 then
   add(toks, sub(data,1,p-1))
  end
  data = sub(data,p+1)
  p = 1
 end
 --build
 for v in all(toks) do
  if v=="true" then
   add(tab,true)
  elseif v=="false" then
   add(tab,false)
  else
   add(tab, str_num[v] or v)
  end
 end
 return tab
end

function pcpy(vars, data, into)
 into=into or {}
 for i,var in pairs(data) do
  into[vars[i]] = var
 end
 return into
end

function delace(datastring)
 local data=unp(datastring)
 local into={}
 for i=1,#data,2 do
  into[data[i]]=data[i+1]
 end
 return into
end

copy_methods={
-- func_180up=function()
--  return (1+rnd())*.5
-- end,
 vfunc_rndbool=function()
  return rnd()<.5
 end,
 vfunc_m1to1=function()
  return 2*rnd()-1
 end,
 vfunc_boxoffx=function(d)
  return d.x+rnd(2)-1
 end,
 vfunc_boxoffy=function(d)
  return d.y-3
 end,
}

function tcopy(s,d)
 d=d or {}
 for k,v in pairs(s) do
  if copy_methods[v] then
   d[k]=copy_methods[v](d)
  else
   d[k]=v
  end
 end
 return d
end

--_  _ ___ _   ___ ___ ___   __ __ ___ _____ _  _  __  __    __  
--| || | __| | | _,\ __| _ \ |  v  | __|_   _| || |/__\| _\ /' _/ 
--| >< | _|| |_| v_/ _|| v / | \_/ | _|  | | | >< | \/ | v |`._`. 
--|_||_|___|___|_| |___|_|_\ |_| |_|___| |_| |_||_|\__/|__/ |___/ 
function sfxs(sfx_s)
 sfx(str_num[sfx_s])
end

function shadowtext(text,x,y,c)
 print(text,x+1,y,1)
 print(text,x,y+1,1)
 print(text,x+1,y+1,1)
 print(text,x,y,c)
end

function shadowtextc(text,x,y,c)
 local len=#text
 --rectfill(x-1-len*2,y-1,x+len*2,y+6,0)
 shadowtext(text,x-len*2,y,c)
end

function setpal(p)
 pal()
 palt(0,false)
 palt(14,true)

 if p<0 then
  for i=0,15 do
   pal(i,-p)
  end
 else
  local col=flr(p/8)*4
  local row=p%8
  pal(5,sget(col,row))
  pal(3,sget(col+1,row))
  pal(13,sget(col+2,row))
  pal(11,sget(col+3,row))
 end
end

function bresenham(x0,y0,x1,y1,f)
 x0=flr(x0+.5)
 x1=flr(x1+.5)
 y0=flr(y0+.5)
 y1=flr(y1+.5)
 local dx=abs(x1-x0)
 local sx=sgn(x1-x0)
 local dy=-abs(y1-y0)
 local sy=sgn(y1-y0)
 local err=dx+dy
 while true do
  f(x0,y0)
  if (x0==x1 and y0==y1) return
  local e2=err*2
  if e2>=dy then
   err+=dy
   x0+=sx
  end
  if e2<=dx then
   err+=dx
   y0+=sy
  end
 end
end

function testmappixel(x,y)
 local f=mflagpos(x,y)
 local modx,mody=x%8,y%8
 if f==1 or
  f==2 and modx+mody>7 or
  f==4 and modx-mody<0 or
  f==8 and mody>4 or
  f==16 and (mody==7 or mody==6 and (modx>0 and modx<7)) or
  f==32 and mody==7 then
  return f
 end
 return nil
end

function collisionraycast(x0,y0,x1,y1)
 _collision=nil
 _lastx,_lasty=x0,y0
 _tilehitx,_tilehity=nil,nil
 local function testcollision(x,y)
  if (_collision) return
  _collision=testmappixel(x,y)
  if not _collision then
   _lastx,_lasty=x,y
  else
   _tilehitx,_tilehity=flr(x/8),flr(y/8)
  end
 end
 bresenham(x0,y0,x1,y1,testcollision)
 return _collision
end

function moveraycast()
 return collisionraycast(_prevx,_prevy,_ao.x,_ao.y)
end

function manhattan(a,b)
  local dx,dy=abs(a.x-b.x),abs(a.y-b.y)
  if dx>dy then return dy*.4+dx end
  return dx*.4+dy
 end

function gravity()
 _ao.dy+=.2
end

function friction()
 _ao.dx*=.98
 _ao.dy*=.98
end

-- marines marines
-- marines marines
-- marines marines

function marinedie(marine,impactx,impacty)
 local restore=_ao
 _ao=marine or _ao
 dropflag()
 impactx=impactx or 0
 impacty=impacty or 0
 local fxs=unp "bloodarm,0,-7,bloodleg,0,-5,bloodhead,0,-8,blood,0,-12,blood,0,-4"
 for i=1,#fxs,3 do
  local gib=selfspawn(fxs[i],fxs[i+1],fxs[i+2])
  gib.dx+=impactx
  gib.dy+=impacty
  gib.pal=_ao.pal
 end
 _ao.dead=true
 sfxs "4"
 _ao=restore
end

function sentrydie(sentry)
 local restore=_ao
 _ao=sentry or _ao
 _ao.dead=true
 selfspawn("smallexp",0,-3)
 sfxs "19"
 _ao=restore
end

function killmarinesintile(x,y)
 forallmarines(function(m)
  if (m.x>=x*8 and m.x<8+x*8 and m.y>=y*8 and m.y<16+y*8) marinedie(m)
 end)
end

function dropflag()
 if _ao.flag then
  _ao.flag=false
  local f=selfspawn "flag"
  f.dy=-1
  f.dx=_ao.facing*-1
  f.hflip=_ao.hflip
 end
end

function forallmarines(f)
 for m in all(objects) do
  if (m.typename=="marine" and f(m)) return m
 end
 return nil
end

function findbox(tx,ty)
 for b in all(objects) do
  if (b.typename=="boxtracker" and b.tx==tx and b.ty==ty) return b
 end
 return {} -- token hack
end

function riflescan(steps)
 local sx,sy=_ao.x+2*_ao.facing,_ao.y-5
 local step=8*_ao.facing
 steps=steps or 15
 for i=0,steps do
  if collisionraycast(sx+i*step,sy,sx+(i+1)*step,sy) then
   break
  end
 end
 local ex=_lastx
 if ex<sx then
  sx,ex=ex,sx
 end
 local hit=nil
 for m in all(objects) do
  if (m.typename=="marine" or m.typename=="sentry") and
    (not m.dead and m.y>=sy and m.y<sy+10 and m.x>=sx and m.x<ex) and
    (not hit or abs(m.x-_ao.x)<abs(hit.x-_ao.x)) then
   hit=m
  end
 end
 return _lastx,_lasty,hit
end

function perform_rifle()
 sfxs "5"
 local ex,ey,hit=riflescan(32)
 if hit then
  if not hit.shielding or hit.hflip==_ao.hflip then
   _lastx,_lasty=hit.x,hit.y
   if hit.typename=="marine" then
    marinedie(hit,_ao.facing,0)
   else
    sentrydie(hit)
   end
  else
   _lastx,_lasty=hit.x+hit.facing*4,hit.y-4
   sfxs "9"
  end
 else
  if _tilehitx and mget(_tilehitx,_tilehity)==98 then
   local b=findbox(_tilehitx,_tilehity)
   if b then
    b.damaged=2
    sfxs "15"
   end
  end
 end
 add(objects,create_object("shot",_lastx,_lasty))
end

function bigexplosion(expx,expy)
 local expos={x=expx,y=expy}

 for m in all(objects) do
  if not m.dead and manhattan(expos,m)<16 then
   if m.typename=="marine" then
    local a=atan2(m.x-expx,m.y-expy)
    marinedie(m,cos(a),sin(a))
   elseif m.typename=="sentry" then
    sentrydie(m)
   end
  end
 end
 delladderp(expx,expy)
 delladderp(expx+8,expy)
 delladderp(expx-8,expy)
 delladderp(expx,expy-8)
 local tx,ty=flr(expx/8),flr(expy/8)
 for bx=-1,1 do
  for by=-1,1 do
   local vx,vy=tx+bx,ty+by
   findbox(vx,vy).damaged=10
   if mget(vx,vy)==190 then
    mset(vx,vy,0)
    add(objects,create_object("mineexploder",3+vx*8,7+vy*8))
   end
  end
 end
 add(objects,create_object("bigexp",expx,expy))
end

function locatemousemarine()
 local clickx=_mx+_camx
 return forallmarines(function(m)
  if (not m.enemy and m.ready and m.x>=clickx-3 and m.x<=clickx+3 and m.y>=_my and m.y<=_my+12) return true
 end)
end

function locatenextladderpos(startx,starty)
 local tx=startx or _ao.x+_ao.facing*8
 local ty=starty or _ao.y
 if mflagpos(tx,ty)~=0 then
  tx=_ao.x
 end
 while isladder(flr(tx/8),flr(ty/8)) do
  ty-=8
 end
 if mflagpos(tx,ty)==0 and mflagpos(tx,ty-8)==0 then
  return flr(tx/8),flr(ty/8)
 end
 return nil,nil
end

--ladders ladders
--ladders ladders
--ladders ladders
function drawladders()
 for l in all(ladders) do
  spr(35,l.x*8-_camx,l.y*8)
 end
end

function isladder(lx,ly)
 return laddergrid[lx+ly*64]
end

function isladderp()
 return isladder(flr(_ao.x/8),flr(_ao.y/8))
end

function addladder(lx,ly)
 add(ladders,{x=lx,y=ly})
 laddergrid[lx+ly*64]=true
end

function delladderp(x,y)
 local lx,ly=flr(x/8),flr(y/8)
 laddergrid[lx+ly*64]=false
 for l in all(ladders) do
  if l.x==lx and l.y==ly then
   del(ladders,l)
   break
  end
 end
end

--  ####  #        ##    ####   ####     #####  ###### ######  ####  
-- #    # #       #  #  #      #         #    # #      #      #      
-- #      #      #    #  ####   ####     #    # #####  #####   ####  
-- #      #      ######      #      #    #    # #      #           # 
-- #    # #      #    # #    # #    #    #    # #      #      #    # 
--  ####  ###### #    #  ####   ####     #####  ###### #       ####  


function create_classes(variables,classtable)
 local classes,indices={},{}
 for i,c in pairs(classtable) do
  local name=c[1]
  local newclass={name=name}
  classes[name]=newclass
  indices[i]=newclass
  for j,v in pairs(variables) do
   newclass[v]=c[j+1]
  end
 end
 return classes,indices
end

-- objects
object_types,object_indices=create_classes(
 unp "sprite,ox,oy,w,h,shadow",
 {
  unp "heli,36,0,0,4,2,true",
  unp "marine,7,-4,-15,1,2,true",
  unp "flag,50,-7,-7,1,1,true",
  unp "homeflag,50,-7,-7,1,1,true",
  unp "grenade,34,-4,-4,1,1,true",
  unp "bigexp,100,0,0,2,2,false",
  unp "shrapnel,0,0,0,0,0,false",
  unp "shrapnelsmoke,92,-3,-3,1,1,false",
  unp "blood,89,-3,-3,1,1,false",
  unp "bloodtrail,0,0,0,0,0,false",
  unp "bloodtrailpart,0,0,0,0,0,false",
  unp "bloodhead,88,-3,-3,1,1,true",
  unp "bloodleg,87,-3,-3,1,1,true",
  unp "bloodarm,86,-3,-3,1,1,true",
  unp "shot,76,-3,-3,1,1,false",
  unp "boxtracker,98,-3,-7,1,1,false",
  unp "boxshrapnel1,188,-3,-3,1,1,true",
  unp "boxshrapnel2,189,-3,-3,1,1,true",
  unp "mineexploder,0,0,0,0,0,false",
  unp "sentry,204,-3,-7,1,1,true",
  unp "smallexp,73,-3,-3,1,1,false",
 }
)
init_data={
 marine=delace "enemy,false,shooting,0,facing,1,hold,0,jumping,0,onground,false,parachute,true,parachutedeployed,false,grenading,0,climbing,0,building,0,shielding,false",
 grenade=delace "dx,2,dy,-4",
 shrapnelsmoke=delace "hflip,vfunc_rndbool",
 blood=delace "hflip,vfunc_rndbool",
 bloodhead=delace "hflip,vfunc_rndbool,dx,vfunc_m1to1,dy,-1",
 bloodleg=delace "hflip,vfunc_rndbool,dx,vfunc_m1to1,dy,-1",
 bloodarm=delace "hflip,vfunc_rndbool,dx,vfunc_m1to1,dy,-1",
 shot=delace "hflip,vfunc_rndbool",
 flag=delace "pal,1",
 boxtracker=delace "active,false,damaged,0,health,4",
 boxshrapnel1=delace "hflip,vfunc_rndbool,dx,vfunc_m1to1,dy,-1,x,vfunc_boxoffx,y,vfunc_boxoffy",
 boxshrapnel2=delace "hflip,vfunc_rndbool,dx,vfunc_m1to1,dy,-1,x,vfunc_boxoffx,y,vfunc_boxoffy",
 sentry=delace "facing,1,shooting,0,shielding,true,enemy,true",
}

ticker=0

update_methods={
 heli=function()
  _ao.fx=cos(_ao.ticks/150)*1.5
  _ao.fy=sin(_ao.ticks/150)*1.5

  if (_ao.ticks==5) sfxs "11"

  if _marinecount>0 then
   _ao.x+=(10-_ao.x)*.1
   _ao.y+=(10-_ao.y)*.1
 
   if _ao.x>5 and _ao.ticks%_level.marinespeed==0 then
    add(objects,create_object("marine",21+_ao.x+_ao.fx,13+_ao.y+_ao.fy))
    _marinecount-=1
    sfxs "6"
    if (_marinecount==0) sfxs "11"
   end
  else
   _ao.dx+=.05
   _ao.dy-=.025
   if (_ao.y<-60) return true
  end
 end,
-- marine
-- marine
-- marine
 marine=function()
  if _ao.dead then
   return true
  end

  _ao.hflip=_ao.facing<0

  if not _ao.onground and _ao.climbing<=0 then
   if moveraycast() then
    _ao.x,_ao.y=_lastx,_lasty
    _ao.dx=0
    if _ao.dy>3.6 then
     marinedie()
    end
    _ao.dy=0
   else
    local ex,ey,hit=riflescan(1)
    if abs(ex-_ao.x)<3 then
     _ao.facing*=-1
     _ao.dx=0
    end
   end
  elseif _ao.enemy and _ao.ticks%30==0 and _ao.ready then
   local ex,ey,hit=riflescan()
   if hit and not hit.enemy then
    dropflag()
    _ao.hold=45
    _ao.shooting=60
    sfxs "2"
   end
  end
  if _ao.enemy and _ao.grenadier and _ao.ready then
   dropflag()
   _ao.grenading=180+flr(rnd(60))
  end
  _ao.ready=false

  local aj=_ao.jumping
  if _ao.onground then
   _ao.dx=0
  else
   _ao.ignoreladders=true
  end

  if _ao.climbing>0 then
   _ao.onground=false
   _ao.climbing-=1
   _ao.sprite=13
   _ao.hflip=flr(_ao.climbing/8)%2==0
   _ao.dy=-.25
   _ao.dx=0
   if not isladderp() then
    if (mflagpos(_ao.x+_ao.facing*8,_ao.y)>=1) _ao.facing*=-1
    _ao.climbing=0
    _ao.sprite=11
    _ao.jumping=14
    _ao.dx=1.1*_ao.facing
    _ao.dy=-.5
    sfxs "6"
    _ao.safeladder=isladder(flr(_ao.x/8)+_ao.facing,flr(_ao.y/8))
   end
   return
  elseif _ao.hold>0 then
   _ao.sprite=7
   _ao.hold-=1
  elseif _ao.shielding then
   _ao.sprite=14
   _ao.ready=not _ao.enemy
  elseif aj>0 then
   _ao.sprite=12
   if aj>15 then
    _ao.sprite=11
   elseif aj==15 then
    _ao.dy=-2
    _ao.dx=1.2*_ao.facing
    sfxs "6"
   end 
   aj-=1
   _ao.jumping=aj
  elseif _ao.shooting>0 then
   _ao.shooting-=1
   _ao.sprite=5+flr(_ao.shooting/3)%2
   if _ao.shooting%6==0 then
    perform_rifle()
   end
  elseif _ao.grenading>0 then
   _ao.grenading-=1
   --_ao.sprite=5+(flr(ticker/3)%2)*1
   if _ao.grenading>9 then
    _ao.sprite=8
   elseif _ao.grenading>6 then
    _ao.sprite=9
   else
    _ao.sprite=10
   end
   if _ao.grenading==6 then
    if _ao.grenadier then
     local g=selfspawn("grenade",10*_ao.facing,-7)
     g.dx*=_ao.facing*(1.1+rnd())
     g.dy*=1.1+rnd()*.15
     g.impact=true
     sfxs "16"
     selfspawn("shot",10*_ao.facing,-7)
     local p=selfspawn("shrapnelsmoke",10*_ao.facing,-7)
     p.dx+=_ao.facing*.25
    else
     local g=selfspawn("grenade",2*_ao.facing,-10)
     g.dx*=_ao.facing
     sfxs "3"
    end
   end
  elseif _ao.building>0 then
   _ao.building-=1
   _ao.sprite=9+flr(_ao.building/15)%2
   if _ao.building%30==0 then
    sfxs "8"
   end
   if _ao.building%60==1 then
    local tx,ty=locatenextladderpos()
    if tx and ty then
     addladder(tx,ty)
    end
   end
  elseif _ao.onground then
   _ao.sprite=1+flr(_ao.ticks/3)%4
   -- look for walls
   local ex,ey,hit=riflescan(1)
   if abs(ex-_ao.x)<2 or
    hit and hit.shielding and abs(hit.x-_ao.x)<3 or
    _ao.enemy and mflagpos(_ao.x,_ao.y)==0 and mflagpos(_ao.x,_ao.y+1)==1 and mflagpos(_ao.x+_ao.facing,_ao.y+1)==0
    then
    _ao.facing*=-1
    _ao.dx=0
    return
   elseif flr(_ao.x)%8==4 then
    if (not _ao.ignoreladders or _ao.safeladder) and isladderp() then
     _ao.climbing=600
     return
    elseif mflagpos(_ao.x,_ao.y)==16 then
     local tx,ty=flr(_ao.x/8),flr(_ao.y/8)
     local tile=mget(tx,ty)
     if tile==83 then
      flipmapswitches()
      sfxs "10"
     elseif tile==190 then
      mset(tx,ty,0)
      bigexplosion(_ao.x,_ao.y)
     end
    end
   elseif flr(_ao.x)%8==0 then
    _ao.ignoreladders=false
    _ao.safeladder=false
   end
   _ao.dx=.25*_ao.facing
   _ao.ready=true
  end
  gravity()
  if (_ao.parachute and _ao.dy>2.5) _ao.parachutedeployed=true
  if (_ao.parachutedeployed and _ao.dy>0) _ao.dy+=(.1-_ao.dy)*.3
  _ao.onground=false
  if _ao.dy>=0 and _ao.dy<1  then
   collisionraycast(_ao.x,_ao.y-2,_ao.x,_ao.y+1.5)
   if _collision then
    _ao.y=_lasty
    _ao.dy=0
    _ao.onground=true
    _ao.parachute=false
    _ao.parachutedeployed=false

    if _collision==8 then
     marinedie()
    end
   end
  end
  return _ao.dead
 end,
-- grenade 
-- grenade 
-- grenade 
 grenade=function()
  friction()
  _ao.hflip=not _ao.hflip

  moveraycast()
 
  if _collision then
   _ao.x,_ao.y=_lastx,_lasty
   if _ao.dy>=0 and (_collision==2 and _ao.dx>=0 or _collision==4 and _ao.dx<=0) then
    _ao.dx*=-.7
    _ao.dy*=-.7
   elseif (mflagpos(_lastx,_lasty+1)~=0 or mflagpos(_lastx,_lasty-1)~=0) then
    _ao.dx*=.8
    _ao.dy*=-.7
   else
    _ao.dx*=-.7
    _ao.dy*=.8
   end
  end
  --elseif mflagpos(_ao.x,_ao.y+1)==0 then
   gravity()
  --end
  if _ao.ticks>90 or _ao.impact and _collision then
   bigexplosion(_lastx,_lasty)
   return true
  end
 end,
 mineexploder=function()
  if rnd()<.1 or _ao.ticks>3 then
   bigexplosion(_ao.x,_ao.y)
   return true
  end
 end,
-- particles
-- particles
-- particles
 bigexp=function()
  if _ao.ticks==0 then
   sfxs "0"
   selfspawn "shrapnel"
   selfspawn "shrapnel"
   selfspawn "shrapnel"
  end
  _ao.sprite=100+flr(_ao.ticks/4)*2
  return _ao.ticks>=20
 end,
 shrapnel=function()
  if _ao.ticks==0 then
   local a=.125+rnd()*.25
   _ao.dx=cos(a)*3
   _ao.dy=sin(a)*4
  end
  gravity()
  moveraycast()
  if _collision then
    sfxs "1"
  elseif rnd()<.2 then
   selfspawn "shrapnelsmoke"
  end
  return _collision
 end,
 shrapnelsmoke=function()
  if (rnd()<.2) _ao.y-=1
  _ao.sprite=92+flr(_ao.ticks/8)
  return _ao.ticks>=24
 end,
 blood=function()
  gravity()
  if _ao.ticks==0 then
   for i=1,5 do
    selfspawn "bloodtrail"
   end
  end
  _ao.sprite=89+flr(_ao.ticks/4)
  return _ao.ticks>=12
 end,
 bloodtrail=function()
  if _ao.ticks==0 then
   local a=rnd()
   _ao.dx=cos(a)*3
   _ao.dy=sin(a)*3
  end
  gravity()
  if (moveraycast()) return true
  if (rnd()<.2) selfspawn "bloodtrailpart"
  return false
 end,
 bloodtrailpart=function()
  return _ao.ticks>5
 end,
 bloodhead=function()
  gravity()
  return moveraycast()
 end,
 bloodleg=function()
  gravity()
  if (rnd()<.2) _ao.hflip=not _ao.hflip
  return moveraycast()
 end,
 shot=function()
  if (_ao.ticks==3) _ao.sprite=77
  return _ao.ticks>5
 end,
 smallexp=function()
  _ao.sprite=73+flr(_ao.ticks/4)
  return _ao.ticks>11
 end,
-- flag
-- flag
-- flag
 flag=function()
  _ao.sprite=50+flr(_ao.ticks/4)%2
  gravity()
  if moveraycast() then
   _ao.x,_ao.y=_lastx,_lasty

   local m=forallmarines(function(m)
    if (m.ready and not m.shielding and manhattan(_ao,m)<3) return true
   end)
   if m then
    sfxs "7"
    m.flag=true
    return true
   end
  end
 end,
 homeflag=function()
  _ao.sprite=50+flr(_ao.ticks/4)%2

  gravity()
  if moveraycast() then
   _ao.x,_ao.y=_lastx,_lasty

   local m=forallmarines(function(m)
    if (m.flag and not m.enemy and manhattan(_ao,m)<3) return true
   end)
   if m then
    music(0)
    _missionaccomplished=true
    -- check perfect
    local count=0
    forallmarines(function(m)
     if (not m.enemy) count+=1
    end)
    count+=_marinecount
    if count>=_level.marinecount then
     _level.savestatus=2
     dset(_current_level,2)
    end
    _current_level+=1
    return true
   end

  end
 end,
-- boxes
-- boxes
-- boxes
 boxtracker=function()
  if _ao.ticks==0 then
   _ao.tx,_ao.ty=flr(_ao.x/8),flr(_ao.y/8)
   mset(_ao.tx,_ao.ty,98)
  elseif _ao.active then
   gravity()
   if moveraycast() then
    _ao.active=false
    _ao.x,_ao.y=_lastx,7+flr(_lasty/8)*8
    _ao.tx,_ao.ty=flr(_ao.x/8),flr(_ao.y/8)
    if mget(_ao.tx,_ao.ty)==190 then
     add(objects,create_object("mineexploder",3+_ao.tx*8,7+_ao.ty*8))
    end
    mset(_ao.tx,_ao.ty,98)
    killmarinesintile(_ao.tx,_ao.ty)
    _ao.dy=0
   end
  else
   _ao.dy=0
   if not testmappixel(_ao.x,_ao.y+1) then
    mset(_ao.tx,_ao.ty,0)
    _ao.active=true
    _ao.tx,_ao.ty=-1,-1
   end
   if _ao.damaged>0 then
    _ao.damaged-=1
    _ao.health-=1
    if rnd()<.05 or _ao.health<=0 then
     mset(_ao.tx,_ao.ty,0)
     selfspawn "boxshrapnel2"
     selfspawn "boxshrapnel1"
     selfspawn "boxshrapnel2"
     return true
    end
   end
  end
 end,
-- sentry
-- sentry
-- sentry
 sentry=function()
  if _ao.dead then
   return true
  end

  _ao.hflip=_ao.facing<0
  _ao.sprite=204

  if _ao.shooting>0 then
   if _ao.shooting==120 then
    sfxs "18"
   elseif _ao.shooting==90 then
    sfxs "18"
   elseif _ao.shooting==60 then
    sfxs "18"
   elseif _ao.shooting<=30 then
    _ao.sprite=205+flr(_ao.shooting/3)%2
    if _ao.shooting%6==0 then
     perform_rifle()
    end
   end
   _ao.shooting-=1
  elseif _ao.ticks%30==0 then
   local ex,ey,hit=riflescan()
   if hit and not hit.enemy then
    _ao.shooting=150
    sfxs "17"
   end
  end
 end,
}
update_methods.bloodarm=update_methods.bloodleg
update_methods.boxshrapnel1=update_methods.bloodleg
update_methods.boxshrapnel2=update_methods.bloodleg

function std_object_draw(o,ox,oy)
 spr(o.sprite,o.x+o.ox+ox,o.y+o.oy+oy,o.w,o.h,o.hflip,o.vflip)
end

draw_methods={
 bigexp=function(ox,oy)
  spr(_ao.sprite,_ao.x-16+ox,_ao.y-15,2,2)
  spr(_ao.sprite,_ao.x+ox,_ao.y-15,2,2,true)
 end,
 shrapnel=function(ox,oy)
  pset(_ao.x+ox,_ao.y,7)
 end,
 marine=function(ox,oy)
  if _ao.parachutedeployed then
   spr(32,_ao.x-8+ox+(_ao.ticks/5)%2,_ao.y-20+oy,2,2)
  end
  std_object_draw(_ao,ox,oy)
  --spr(50+flr(ticker/4)%2,_ao.x+ox-9,_ao.y+oy-12)
  if _ao.flag then
   if (not _shadowdrawing) setpal(1)
   local flagsprite=50+flr(ticker/4)%2
   if _ao.climbing<=0 then
    spr(flagsprite,_ao.x+ox-4-_ao.facing*5,_ao.y+oy-12,1,1,_ao.hflip)
   else
    spr(flagsprite,_ao.x+ox-9,_ao.y+oy-13)
   end
  end
 end,
 bloodtrail=function(ox,oy)
  pset(_ao.x+ox,_ao.y,8)
 end,
 bloodtrailpart=function(ox,oy)
  pset(_ao.x+ox,_ao.y,2)
 end,
 heli=function(ox,oy)
  ox+=_ao.fx
  oy+=_ao.fy
  std_object_draw(_ao,ox,oy)
  if not _shadowdrawing then
   local x=_ao.x+_ao.ox+ox
   local y=_ao.y+_ao.oy+oy
   if (_ao.ticks%2==0) x+=9
   line(x-3,y+1,x+5,y+1,7)
   line(x+17,y+2,x+25,y+2,7)
  end
 end,
 boxtracker=function(ox,oy)
  if _ao.active or _ao.damaged>0 then
   if _ao.damaged>0 then
    setpal(-7)
   end
   std_object_draw(_ao,ox,oy)
  end
 end,
 mineexploder=function() end,
}

function create_object(typename,x,y)
 local o=delace "ticks,-1,pal,0,dx,0,dy,0,hflip,false,vflip,false,dead,false"
 o.x=x
 o.y=y
 tcopy(object_types[typename],o)
 if(init_data[typename]) tcopy(init_data[typename],o)
 o.class=classtype
 o.typename=typename
 o.update=update_methods[typename]
 o.draw=draw_methods[typename]
 return o
end

function selfspawn(typename,ox,oy)
 ox=ox or 0
 oy=oy or 0
 return add(objects,create_object(typename,_ao.x+ox,_ao.y+oy))
end

function update_object(o)
 _ao=o
 o.ticks+=1
 _prevx=o.x
 _prevy=o.y
 o.x+=o.dx
 o.y+=o.dy
 o.dx*=.99
 o.dy*=.99
 return not o.update or o.update()
end

function draw_object_base(ox,oy)
 if _ao.draw then
  _ao.draw(ox,oy)
 else
  std_object_draw(_ao,ox,oy)
 end
end

function draw_objects()
 _shadowdrawing=false
 for o in all(objects) do
  _ao=o
  setpal(o.pal)
  draw_object_base(-_camx,0)
 end
end

function draw_object_shadows()
 _shadowdrawing=true
 setpal(-1)
 for o in all(objects) do
  _ao=o
  if o.shadow then
   draw_object_base(1-_camx,0)
  end
 end
end

function animate_spritesheet()

 if ticker%3==0 then
  sset(42,42,8+flr(rnd(4)))
  sset(45,42,8+flr(rnd(4)))
  sset(42,45,8+flr(rnd(4)))
  sset(45,45,8+flr(rnd(4)))
 end
 local lamp=flr(ticker/5)%4
 if lamp==0 then
  -- small
  sset(51,36,7)
  sset(53,38,10)
  sset(49,38,10)
  -- large
  sset(121,84,5)
  sset(123,84,14)
  sset(124,84,14)
  sset(126,84,13)
  sset(122,86,14)
  sset(125,86,14)
 elseif lamp==2 then
  -- small
  sset(51,36,9)
  sset(54,36,10)
  sset(48,36,10)
  sset(51,39,10)
  -- large
  sset(121,84,10)
  sset(123,84,14)
  sset(124,84,14)
  sset(126,84,10)
  sset(122,86,10)
  sset(125,86,10)
 else
  -- small
  sset(51,36,10)
  sset(53,38,14)
  sset(49,38,14)
  sset(54,36,14)
  sset(48,36,14)
  sset(51,39,14)
  -- large
  sset(123,84,10)
  sset(124,84,10)
 end
 local mine=flr(ticker/8)%2
 if mine==0 then
  sset(115,93,2)
 else
  sset(115,93,8)
 end
 local sentry=flr(ticker/15)%2
 sset(99,97,7+sentry)
end

-- map     map     map     map map
-- map map map map     map map     map
-- map     map map map map map map
-- map     map map     map map
-- map     map map     map map

-- map     map     map     map map
-- map map map map     map map     map
-- map     map map map map map map
-- map     map map     map map
-- map     map map     map map

levels,level_indices=create_classes(
 unp "title,orders,marinecount,marinespeed,survivaltarget,mx,my,mw,mh,weather,sunx,suny,suna",
 {
  unp "t,obeylings,1234,0,90,1,0,0,16,16,day,95,30,17",
  unp "a,1 - cliffside,5,10,90,1,32,0,16,16,day,95,30,17",
  unp "b,2 - hazard pay,15,10,90,1,48,0,16,16,day,75,20,19",
  unp "c,3 - whiskey tango foxtrot,2,10,120,1,64,0,16,16,day,35,30,21",
  unp "d,4 - fire in the hall,1235,10,90,1,80,0,16,16,day,15,40,23",
  unp "e,5 - covert operations,12345,10,90,1,96,0,16,16,night,95,30,25",
  unp "f,6 - loading bay,12345,10,90,1,112,0,16,16,night,75,20,19",
  unp "g,7 - tower of babel,12345,10,90,1,0,32,16,16,night,35,30,21",
  unp "h,8 - snowy peak,12345,10,90,1,16,32,32,16,winter,35,30,21",
  unp "i,9 - the fortress,12345,10,90,1,64,32,32,16,winter,35,30,21",
 }
)
load_functions={}

function add_enemy(px,py)
 local e=add(objects,create_object("marine",px,py))
 e.enemy=true
 e.pal=1
 return e
end

function setup_level()
 if _current_level>#level_indices then
  _isvictory=true
  return
 end
 _level=level_indices[_current_level]
 _mapw,_maph=_level.mw,_level.mh
 _camx=0
 stars={}
 local sw,sh=128,70
 if _level.weather=="winter" then
  sw,sh=_mapw*8,128
 end
 for i=1,100 do
  stars[i]={x=flr(rnd(sw)),y=flr(rnd(sh))}
 end

 _selected_order=1
 _marinecount=_level.marinecount
 _missionaccomplished=false
 _istitle=false
 palanimtick=0
 palanim=1
 if _level.savestatus==0 then
  _level.savestatus=1
 end
 dset(_current_level,_level.savestatus)

 if _current_level==1 then
  _istitle=true
  _current_level=2
 end

 objects={}
 ladders={}
 laddergrid={}

 local sx,sy=_level.mx,_level.my
 for y=0,_maph-1 do
  for x=0,_mapw-1 do
   local srctile=mget(x+sx,y+sy)
   local dsttile=0
   local px,py=4+x*8,4+y*8
   if srctile==50 then
    add(objects,create_object("flag",px,py))
   elseif srctile==51 then
    add(objects,create_object("homeflag",px,py))
   elseif srctile==17 then
    add_enemy(px,py)
   elseif srctile==30 or srctile==14 then
    local e=add_enemy(px,py)
    e.shielding=true
    if (srctile==14) then 
      e.facing=-1
      e.x+=1
    end
   elseif srctile==10 or srctile==26 then
    local e=add_enemy(px,py)
    e.grenadier=true
    if (srctile==10) then 
      e.facing=-1
    end
   elseif srctile==204 or srctile==205 then
    local e=add(objects,create_object("sentry",px-1,py+3))
    if (srctile==205) then 
      e.facing=-1
    end
   elseif srctile==35 then
    addladder(x,y)
   elseif srctile==98 then
    add(objects,create_object("boxtracker",px-1,py+3))
   else
    dsttile=srctile
   end
   mset(x,y,dsttile)
   mset(x,y+16,mget(x+sx,y+sy+16))
  end

  _restart=-90
 end

 for o=1,#order_indices do
  order_indices[o].enabled=false
 end
 local orderstring=tostr(_level.orders)
 for p=1,#orderstring do
  order_indices[str_num[sub(orderstring,p,p)]].enabled=true
 end

 if not _istitle then
  add(objects,create_object("heli",-40,-10))
 end
end

function mflagpos(x,y)
 if (x<0 or y<0 or y>=_maph*8 or x>=_mapw*8) return 1
 return fget(mget(x/8,y/8))
end

function flipmapswitches()
 for y=0,_maph-1 do
  for x=0,_mapw-1 do
   local tile=mget(x,y)
   local new=nil
   if tile==83 then
    new=84
   elseif tile==84 then
    new=83
   elseif tile==67 then
    new=68
    killmarinesintile(x,y)
   elseif tile==68 then
    new=67
   end
   if (new) mset(x,y,new)
  end
 end
end

--   ssss    yy    yy    ssss
-- ss    ss  yy    yy  ss    ss
-- ss        yy    yy  ss
--   ssss      yyyy      ssss
--       ss      yy          ss
-- ss    ss      yy    ss    ss
--   ssss        yy      ssss

function _init()

 _current_level=1
 for i=2,#level_indices do
  level_indices[i].savestatus=dget(i)
 end
 if level_indices[2].savestatus==0 then
  level_indices[2].savestatus=1
 end

 setup_level()

 _mb=0
 _mx,_my=64,64
 _movespeed=1
 _usemouse=true
 _prevmx=stat(32) -- used to detect mouse movement
 
end

function _update()

 if (_isvictory) return

 if _restart>=30 then
  setup_level()
 end

 ticker+=1
 _prevmb=_mb
 _mb=stat(34)
 local mx,my=stat(32),stat(33)
 if _usemouse then
  _mx,_my=mx,my
 elseif abs(_prevmx-mx)>10 then
  _usemouse=true
 end
 _prevmx=mx

  _updatespeed=1

 if _istitle then
  if btnp(0) then
   _current_level-=1
   if _current_level==1 then
    _current_level=#level_indices
   end
  elseif btnp(1) then
   _current_level+=1
   if _current_level>#level_indices then
    _current_level=2
   end
  end
  if level_indices[_current_level].savestatus>0 and (_mb==1 and _prevmb==0 or btnp(4)) then
   _restart=30
   return
  end
 else
  if btnp(5) or not order_indices[_selected_order].enabled then
   repeat
    _selected_order=1+(_selected_order%#order_indices)
   until order_indices[_selected_order].enabled
  end
  local movex,movey=0,0
  if btn(0) then
   movex=-1
  elseif btn(1) then
   movex=1
  end
  if btn(2) then
   movey=-1
  elseif btn(3) then
   movey=1
  end
  if movex~=0 or movey~=0 then
   _usemouse=false
   _mx+=movex*_movespeed
   _my+=movey*_movespeed
   _movespeed=min(_movespeed+.25,4)
  else
   _movespeed=1
  end
  _mx=mid(0,_mx,127)
  _my=mid(0,_my,127)
 
  if _my<112 then
   _camx=flr(mid(0,_camx+min(0,(_mx-16)/4)+max(0,(_mx-112)/4),(_mapw-16)*8))
  end

  if _missionaccomplished then
   _updatespeed=0
   _restart+=.5
  elseif _mb==1 and _prevmb==0 or btnp(4) then
   if _my>112 and _mx<96 then
    local newindex=min(1+flr(_mx/16),#order_indices)
    if (order_indices[newindex].enabled) _selected_order=newindex
   else
    _ao=locatemousemarine()
    if _ao then
     _ao.hold=30
     --_ao=_selected_marine
     _ao.shielding=false
     dropflag()
     orders[order_indices[_selected_order].name]()
     sfxs "2"
    end
   end
  elseif (_mb==1 or btn(4)) and _my>112 then
   if _mx>96 and _mx<112 then
    _updatespeed=5
   elseif _mx>112 and _restart>=0 then
    _restart+=1
    _updatespeed=0
   end
  elseif _restart<0 then
   _restart+=1
  else
   _restart=0
  end
 end
 
 for i=1,_updatespeed do
  for g in all(objects) do
   if update_object(g) then
    del(objects,g)
   end
  end
 end

 --if not _selected_marine or _selected_marine.dead then
 -- _selected_marine=select_marine(1)
 --end
end

palanim=1
palanimtick=0
palanims={
 { 0, 0, 1, 5, 0, 0, 1, 5, 5, 5, 5, 5, 1, 1, 1, 5},
 { 0, 1, 1, 3, 5, 0, 5, 6, 5, 4, 4, 3, 2, 1, 2, 4},
 { 0, 1, 2, 3, 4, 5, 5, 6, 4, 4, 9, 3,13, 2, 2, 9},
 { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15},
}
function _draw()

 if _isvictory then
  cls(0)
  shadowtextc("victory!",64,40,7)
  shadowtextc("thank you for playing",64,50,15)
  shadowtextc("// jeb_",64,58,15)
  return
 end

 animate_spritesheet()

 local sunx,suny=_level.sunx,_level.suny
 if _level.weather=="day" then
  cls(12)

  for i=0,8 do
   local a=(_level.suna+i*12)*.01
   line(sunx,suny,sunx+cos(a)*120,suny+sin(a)*120,10)
  end
  circfill(sunx,suny,7,7)
  circ(sunx,suny,7,10)
 elseif _level.weather=="night" then
  cls(1)

  local y=70
  while y>0 do
   line(0,y,127,y,0)
   y-=(71-y)*.5
  end
  rectfill(0,70,128,128,0)
  circfill(sunx,suny,7,7)
  circfill(sunx+5,suny,5,1)

  for s in all(stars) do
   pset(s.x,s.y,7)
  end

 elseif _level.weather=="winter" then
  cls(6)

  local y=70
  while y>0 do
   line(0,y,127,y,12)
   y-=(71-y)*.5
  end
  rectfill(0,70,128,128,12)

  for s in all(stars) do
   if (rnd()<.2) s.x+=1
   if (rnd()<.4) s.y+=1
   if (s.x>(_mapw*8)) s.x=0
   if (s.y>120) s.y=0
   pset(s.x-_camx,s.y,7)
  end

 end
 
 pal()
 palt(0,false)
 palt(14,true)
 
 map(0,16,-_camx,0,_mapw,_maph)
 map(0,0,-_camx,0,_mapw,_maph)
 
 draw_object_shadows()
 setpal(0)
 drawladders()
 draw_objects()
 setpal(0)

 --if _selected_marine then
 -- spr(40,_selected_marine.x-4,_selected_marine.y+1)
 --end

 if _marinecount>0 then
  spr(56,102,2,3,1)
  local ct="".._marinecount
  shadowtext(ct,124-#ct*4,4,7)
 end

 if not _istitle then
  rectfill(0,112,128,128,0)
  for i=1,#order_indices do
   local x=4+(i-1)*16
   local y=116
   if (i==_selected_order) y-=2
   local order=order_indices[i].icon
   setpal(2)
   spr(46,x-4,y-4,2,2)
   setpal(-1)
   if (i==_selected_order) setpal(-7)
   spr(order,x-1,y)
   spr(order,x,y-1)
   spr(order,x+1,y)
   spr(order,x,y+1)
   setpal(0)
   if (order_indices[i].enabled) spr(order,x,y)
  end
  setpal(3)
  spr(46,96,112,2,2)
  spr(46,112,112,2,2)
  setpal(-1)
  spr(15,99,116)
  spr(15,100,115)
  spr(15,101,116)
  spr(15,100,117)
  spr(31,115,116)
  spr(31,116,115)
  spr(31,117,116)
  spr(31,116,117)
  setpal(0)
  spr(15,100,116)
  spr(31,116,116)

  _ao=locatemousemarine()
  if _ao then
   setpal(4)
   std_object_draw(_ao,-_camx,0)
   if _selected_order==4 then
    setpal(0)
    local tx,ty=locatenextladderpos()
    for i=0,2 do
     if tx and ty then
      spr(16,tx*8-_camx,ty*8)
      tx,ty=locatenextladderpos(tx*8,(ty-1)*8)
     else
      break   
     end
    end
   end
   setpal(0)
  end
 end

 if _istitle then
  shadowtextc("obeylings",64,30,7)
  shadowtextc("obey and bring back the flag!",64,40,15)
  shadowtextc("use mouse or keyboard!",64,48,15)
  shadowtextc("click or z to command!",64,56,15)
  shadowtextc("x to cycle commands!",64,64,15)

  local level=level_indices[_current_level]
  shadowtextc("select starting mission:",64,80,7)
  shadowtextc(level.title,64,88,15)
  if level.savestatus==0 then
   shadowtextc("locked",64,96,8)
  elseif level.savestatus==2 then
   shadowtextc("perfect!",64,96,10)
  end
 elseif _missionaccomplished then
  rectfill(17,47,107,57,0)
  local scale=-sin(_restart/120)*88
  rectfill(18,48,18+scale,56,3)
  shadowtext("mission accomplished!",20,50,11)
 elseif _restart>0 then
  rectfill(31,47,97,57,0)
  local scale=-sin(_restart/120)*64
  rectfill(32,48,32+scale,56,8)
  shadowtext("restarting...",34,50,7)
 elseif _restart>-70 and _restart<-10 then
  shadowtextc(_level.title,64,50,7)
 end

 spr(40,_mx-2,_my-2)

 print(debug,0,7,7)
 --print(stat(1),0,0,7)

 palanimtick+=1
 if palanimtick>=4 then
  palanimtick=0
  palanim+=1
 end
 if palanim<=4 and palanim>0 then
  for i=0,15 do
   pal(i,palanims[palanim][i+1],1)
  end
 end
end

order_types,order_indices=create_classes(
 unp "icon,desc",
 {
  unp "jump,44,jump!",
  unp "shoot,45,fire!",
  unp "grenade,61,grenade!",
  unp "ladder,35,ladder up!",
  unp "shield,59,shield up!",
 }
)
orders={
 jump=function()
  _ao.jumping=30
 end,
 shoot=function()
  _ao.shooting=60
 end,
 grenade=function()
  _ao.grenading=30
 end,
 ladder=function()
  _ao.building=164
 end,
 shield=function()
  _ao.shielding=true
 end,
}

-- intro junk
function intro()
 local c1,c2=7,7
 local t=0
 local open=-1
 palt(0,false)
 sfx(12)
 while not btnp(4) do
  cls(0)
  rectfill(54,38,73,65,1)
  t+=1
  if t==7 then
   if c1==c2 then
    if c2%2==0 then
     c1+=1
    else
     c2+=1
    end
   elseif c2>c1 then
    c1=c2
   else
    c2=c1
   end
   t=0
  end
  pal(9,c1%16)
  pal(10,c2%16)
  spr(238,56,40,2,2)
  print("jeb_",57,58,7)
  
  if open<20 then
   rectfill(0,0,64-open,128,0)
   rectfill(64+open,0,128,128,0)
  elseif open>40 then
   rectfill(0,0,10+open,128,0)
   rectfill(118-open,0,128,128,0)
   if open>60 then
    break
   end
  end
  open+=.5
  flip()
 end
 pal()
end
intro()
__gfx__
53db0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
62d80000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eee7ee
124f0700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77ee77e
15677000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777e777
6bd77000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777e777
00700700eebb3eeeeebb3eeeeebb3eeeeebb3eeeeebb3eeeeebb3eeeeeebbeeeeebb3eeeeebb3eeeeeeeee7eeeeeeeeeeebb3eeee7eeeeeeeeeeeeeee77ee77e
00000000eb3333eeeb333eeeeb3333eeeb333eeeeb3339eeeb3334eeee733beeeb3333ee7b3333eeeebb35eeeeebb3eeeb3333eee5bbbeeeeeebb3eee7eee7ee
00000000eb300eeeeb3003eeeb300eeeeb3003eeeb304eeeeb309eeee5300beeeb300eee53300eeeeb3353eeeeb3333eeb300eeee5b33eeeeeb3333eeeeeeeee
ee9ee9eee33ffeeee33ffeeee33ffeeee33ffeeee33f9eeee33f4eee5e3ff3eee33ffeeee53ffeeee3350eeeee3300eee33ffeeee53337ee7e3300edeeeeeeee
eee44eeee5555eeeee555eeeee555e00e5555eeee5556eeee5555ee9555555eeee555e00e5555e00ee55feeeeee5ffeeee555eeeee5555ee5e55ffe0ee7777ee
ee9ee9eee5500000e55000eee555007ee55000eee55000985500099aee500000e555007eee55007eee500000ee5000eee5500000ee5555ee555555ede777777e
eee44eeee570557eee705700e57005eeee705700e570557e570557e9ee50557ee55005eeee5005eeee55057ee5550500e550557eee3555eee555557d7ee77ee7
ee9ee9eeee555eeeee3b5eeee550beeeee3b5eeeee555eeeee555eeeee3553ee7e555eeeee555eeeee5555ee7e5555ee7e555eeeeeb553eeee5000ed7ee77ee7
eee44eeee3be3beee4b3beeeeebb4eeeeeb3beeee3be3beee3be39eeeeb33beee3be3beee3be3beee3bee3beee3b3beee3b3beeeee443beeee30300de77ee77e
ee9ee9ee3beebeeee43beeeeee3b4eeee3be44ee3beebbee3beebbeeeb3ee3be3beebbee3beebbee3beeebbeeebbbeee3b3beeeeeeee3beeee33beedeeeeeeee
eee44eee44ee44eeeee44eeeee44eeeee44eeeee44eee44e44eee49ee44ee44e44eee44e44eee44e44eeee44ee4444ee44e44eeeeeee44eeee4444edee7777ee
eeeee66666eeeeeeeeeeeeeeee91e91eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee771771ee5dddddddeeeeeeeee3eb33beeeeeeeeeeeeeeeeeeee3333333335eee
eee666777666eeeeeeeeeeeeee94491eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee71ee71ee5dddddddeeeeeeeeebebee3eeeecceee6eeeeeeeee3bbbbbbbbb35ee
ee67667776676eeeeeee5eeeee91e91eeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeee71eeee5dddddddeee8eeeeeee33eeeeeceecee56666666e3bbddddddddd35e
e6777667667776eeeeeb3eeeee94491eeeeebbbeeeeeeeeeeeeeeeeee0eeeeee71ee71ee5dddddddee8a8eeeee3eeeeeeceeecee565555553bbddddddddddd35
e6677777777766eeeee3beeeee91e91eeeeb3335eeeeeeeeeeeeeeeebbbeeeee771771ee5dddddddee58b5eeeee3eeeeeceeecee65e5eeee3bdddddddddddd35
676677666776676eeeeeeeeeee94491eeeb33335eeeeeeeeeeeeeeeb3335eeeeeeeeeeee5dddddddee656b55eeeebeeeceececec655eeeee3bdddddddddddd35
677666eee666776eeeeeeeeeee91e91eeb33333bb333bb333bb333b3bb35eeeeeeeeeeee5ddddddde3366b36eeee3eeeceeeccce65eeeeee3bdddddddddddd35
666eeeeeeeee666eeeeeeeeeee94491eeb30bb533333b3333b333333b3000eeeeeeeeeee5555555511111111eeeeeeeeceeeeceeeeeeeeee3bdddddddddddd35
e6eeeeeeeeeee6eeeeeeeeeeeeeeeeeeeb3055533003330033355553301cceeeaaa9aa99aaa9aa99aaa99999eeeeeeee00000000e8ee88ee3bdddddddddddd35
ee6eeeeeeeee6eeee33ee336eee33ee6eb333333b0133b0133b5005b30111ceea44444444444444444444441e555555e000000008a89aa8e3bdddddddddddd35
eee6eeeeeee6eeeeebb33bb6e33bb336eb33bbbbbbbbbbbbbbb0000b30111cee94444bb14444444444444441e566665e00000000e8a9a99e3bdddddddddddd35
eeee6eeeee6eeeeeebbbbbb6ebbbbbb6ee553333333333333335005b330000ee9444733b1444444444444441e500005e00000000899a7aa83bdddddddddddd35
eeeee6eee6eeeeeeebbbbbb6ebbbbbb6eeee55bb33bb33bb33b5005bbb3555eea445300b1444444444444441e566665e000000008aa77a9e53ddddddddddd335
eeeeee6e6eeeeeeee33bb336ebb33bb6eeeee0550055005500555555005eeeee94513ff31444444444444441e566665e00000000e8aaa98ee53ddddddddd335e
eeeeeee6eeeeeeeeeee33ee6e33ee336eeee050eeeeeeeeeeee050eeeeeeeeee945555551444444444444441ee5665ee00000000ee9a8eeeee533333333335ee
eeeeeeeeeeeeeeeeeeeeeee6eeeeeee6eeeee0eeeeeeeeeeeeee0eeeeeeeeeee911111111111111111111111eee55eee00000000eee8eeeeeee5555555555eee
eeeeeeeeb331eeee02000200004400440aa00aa001555511eee0eeeed5eeeed522222255eeeeeeeeee0e004e0e08294eeeeeeeeeeeeaeeee00eeeeeeeeeeeeee
eebb1ebbb3bb1eee2552255204400440aa00aa00055dd550eee0eeeed5eeeed549242994eee084eee09aaa84e9924094eeeeeeeeeeeeeeee2200eeee0eeeee00
e3333bb33b3bb1ee020002005ddddddd7776666d15000051ee765eeed5eeeed525552222ee0aa98e48a99a900a8eeee9eeeeeeeeeeaeeeee442200ee100e0051
eee3b333bbb3bb1e555255525ddddddd7666666d15011050e76665eed5eeeed544499442e0a77aa00a948aa99aeeee04eee78eeeeeeeee8e2244220e10505550
eeebbb343b1ee3b1020002005ddddddd6666677d055dd550aee7eeaed5eeeed522225552e0a777a00aa289a890e0eee9eeea7eeeeeeeeeee002200ee01501505
eeeb3334491eee31255225525ddddddd6667776505011050eeeeeeeed5eeeed599422944e4aa7aa089a99a90442ee8a0eeeeeeeee8eeeeee2200eeee55010010
eebbb1e99421eeee020002005ddddddd6777766515000051eaeeeaeed5eeeed525555222ee48a90e449aaa9ee098aa9eeeeeeeeeeeeeaeee442200ee10551551
eeb31ebb3491eeee5552555255555555d5555555015dd510eeeaeeeed5eeeed594429442eee000eeee8008eeee40940eeeeeeeeeeeeeeeee2200eeee15010111
eb31eeb399441eeeeeeeeeeeeeeeeeeeeeeeeeee01555511eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5eee5e00224422
eb31ebb314991eeeeeeeeeeeeeeeeeeeeeeeeeee055dd550eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8eeeeeee22e8eeeeeeeeeeeeeeeee5ee55eee22002200
e31eeb31e94491eeeeeeeeeeeeeeeeeeeeeeeeee15800a51eee8eeeeeeeeeeeeeeeb35eeeee28eeeee88822eeeeee28eeeeeeeeee55eeeeeeeeeeee544220022
eeeee315519941eeeeeeeeeeeeeeeeeeeeeeeeee15011050ee825eeeeee82eeeeeb553eeee288eeeeee2e2eeee8eeee2ee5e00eeee505e0eeee55eee22442200
5e55655b35442155555e55eeeeeeeeeeeeeeeeee055dd550ee2585eeeee238eeeeb3003eeee82eeee88e28eee2ee2e2eeee005eeee0e5e5eeeeee5e500220022
b56666b3339941653b656b55e111111eeeeeeeee05a11850eeee25eeeeee3beeee338feeeeeeeeeeee28e8eee2ee22e2eee0eeeeee00e5eee5eeeeee22002244
3336b3333949421bb3366336157cc501eeeeeeee15000051eeeee7eeeeeee44eeee82eeeeeeeeeeeeeee82eeee8e8e2eeeeeeeeee5ee55eeeeeeeeee44220022
1111111139942221111111116766666567666665015dd510eeeeeeeeeeeeeeeeeee2eeeeeeeeeeeeeeeeeeeeeee2ee2eeeeeeeeeeeeeeeeee5eeeeee22002200
5dd55665bbb3b3bbaaa99999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77777776
6665d6656b333333a4444441eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77666666
665dd5656653336594aa9919eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee002eeeeeeeee0022eeeeeea8eeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeee76666666
555665555556655594a44191eeeeeeeeeeeeeeeeeeeeeeeeeeee0e0008200ee8eee028a800e0ee8eeeee00eeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeee76666666
d6666656dbb66656a4941941eeee7eeeeeeeeeeeeeeeeeeeeeeee28aa9880e8aeee08aaaaa0eeeeeeee022000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee76666666
55dd565d3333565d94919441eee765eeeeeeeeeeeeeeeee0eeee09aaaa949849ee02a998aaa000eee008980220eeeeeeeeeeeeeeeeeeeeeee1e1e1e176666666
665d6666663d666694194441ee77665eeeeeeeeeeeee88e8eeee89aaaaa9aae8ee08a9899aa980eee089aaa0e20eeeeeeee00eeeeeeeeeee1e1e1e1e6666666d
655555566555555691411111e7766665eeeeeeeeeee4998eeeee888aaaaaaa0eee00088220aa928ee08aa2880e20eeeeeeeeeeeeeeeeeeee010101016ddddddd
eeeeeeeeeeeeeeee501155015011550eeeeeeeeeee88aa98eeee0088999aaa8eeeeee008220eee8ee0082222eeeeeeeee020e00eeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee66eeeeeee0155110001551100eeeeeeeee49aaaaaeeeeee00889aaaaee0eeeee8820ee80eeee000222e0ee0ee000200e20eeeeeeeeeeeeee77eeeeeee
eeeeee6556eeeeee15000051150000eeeeeeeeeee89aaaa7eeeee020028aa77ae00e000eee00eee00eee000eeeeeeeeee0eeee0ee0eeeeeeeeeeee7677eeeeee
eeeee655556eeeee1051555010515550eeeeeeeee48aaa77eeeeee00988a777eee2089a88e080eeeeee0eee80ee0eeee0ee0eeeeeeee0eeeeeeee766767eeeee
eeee66566566eeee015015050150150eeeeeeeee08aae777eeeee08aa998e77eee089aa98a098eeeee08088e02ee0eeeee0eeeee0eeeeeeeeeee76667667eeee
eeed565dd565deee55010010550100eeeeeeeeee8aa7e777eeeee09aaaa8eee0ee09aa88aa808e0ee009aa00e00e0eeee20eee0eeeeeeeeeeee7666676667eee
ee6d66666666d6ee105515511055155eeeeeeeeee9a7ee77eeeee8aa988eee0eeee02200080eeeeee02880e0eeeeeeee00222eee20e0eeeeee76666d666667ee
e65555566555556e1501011115010eeeeeeeeeeeeeeeeee7eeeeeeee00eeeeeeeeee00eee0ee0eeeee0800eeeeeeeeeee00000e0eeeeeeeee766dddddddddd6e
000000000000e7f6f6f6f6f6f6f6f6f6000000000000000000000000000000000000000000000000000000000000000077777777eeeeeeeeeeeee66e94eeee94
00000000000000f6f6f6f6f6f6f6f6f600000000000000000000000000000000f6f6f6f6f6f6f6f6f600000000000008eeeeeeeeeeeeeeeeeeeeeae694eeee94
000000000000370000b27474000000ea0000000000000000000000000000000000000000000000000000000000000000eeeeeeeeee9eeeeee777ee6e94eeee94
00000000000000fa00000000c500faf60000000000000000000000000000000000000000000000f60000000000000008eeeeeeeeee9eeeee9999999494eeee94
000000000000370000007474006400ea0000000000000000000000000000000000000000000000000000000000000000eeeeeeeeee9eeeee94eeee9494eeee94
00000000000000740000d500000074f60000000000000000000000000000000008000000000000f60000000000000008eeeeeeeeee99999e94eeee9494eeee94
00000000000037e7f6f6747400d8e8ea0000000000000000000000000000000000000000000000000000000000000000eeeeeeeeee94e94e94eeee9494eeee94
00000000000000fb3636f63636f674f60000000011000011000000000000000000000000000000000000000000000008eeeeeeeeee94e94e94eeee9494eeee94
000000000000f6f6f4f47474f6f6f6f600000000000000000000000000000000000000000000000000000000000000cebbb3b3bb3bb54433eeeeeeeeeeeeeeee
ce003300000000f6f6f6f6f6f6f674f6000000fbfbfbeaeafb00000000000000f6f6f6f60000000000000000000008083b33333333443344eeeeeeebbeeeeeee
000000000000ea00000074740000b2ea000000000000000000000000000000000000000000000000000000000023cecf4453334554543544eeeeeeb44beeeeee
cf17cececececef600007400740074f6000000f864000000f8000000000000000800000000000000000000000000080855534555545bb555eeeee355553eeeee
000000000000eaf400007474000000ea0000000000000000000000000000000000000000000000000000000000cecfcfdbb443544434443deeee333dd333eeee
cffbfb06fb44fbf635007400740074f6000000f8e6e6e6dcf80000000000230008000000000000000000000000000808b333545dd54555bbeee3354bb4533eee
000000000000f6f6f6f67474000000ea00000000000000000000000000000000000000f6f60000000000dfa0cecfcfcf443d4bb44b44d544eeb4d544445d4bee
f6f6fbfbf600f6f6f6f6f6f6f6f6f6f6000000f600f6eaeaea0000000000fbfb08000000000000f6f6f6f6f6f6f6f6f64555553333554454eb554454454455be
000000000000440000007474000000ea0033000000000000000000000000000000000000000000dfa0cecfcfcfcfcfcf5000000555515551776566d5ee6666ee
f6fa000000c5007400d500f6fa0000f6000000ead5000064ea00ebfbfbfbcfcf080000000000000000000000000000f650eeee01510051107665d555d6dddd65
00000000000044f4f4f474740035f4ea32fbfb0000cecececece000000000000000000dfa0cecefbdecfcfcfdecfcfcf507eee055551551166d57765d5a77a55
f674e6d5e6e6e674e6e6dcf6740045f600fa00eae6e6e6e6f6fbfbfbce00cefb080000000000000000000000000000f610eeee0551105110d5557665d5eeeed5
000000000000f6f6f6f67474f6f6f6f63200000000c8c8fbc8fb00000000cececececefbfbfbfbfbcfcfcfdecfcfcfcf10eee70555515551776566d5daeaaea5
f6740000f6f6f6f6f6f6f6f674f6f6f6007400eaeaeaf600f6ce0000fb00fbfb080000000000000000000000000000f650ee7e01511051007665d555d5eeeed5
00330000000037b200447474440023ea3200000000f8c764d5f800cececefbdefbdefbfbce00cecfcfcfcfcfcfcfcfcf50eeee015511555166657665d5aeead5
f674c50000000074d500000074340074007400f800000000f6fb00ce00cefb00080000000000000000000000000000f61000000551105110d55566d5d5eeeed5
06161700000037f4f444ebeb44f4f4ea32cecececef8e6e6e6f8cefbfbfb16cece00cecfdecfdecfcfcfcfcfcfcfcfcfeeeeeeeeeeeeeeeeeeeeeeee76777766
f67400000000d574000000007434dc74007400f8e6e6e6e6f600cefb00cf0000080000000000000000000000000000f6eeeeeeeeeeeeeeeeeeeeeeee77777677
060606061606eaeaeac8c8c8c8eaeaeacfcfcfcfcfeaeaeaeaeafbfbcfcfcfcfdecfcfcfcfcfcfcfcfcfcfcfcfcfcfcfeeeeaeeeeea99aeeeeeeeeee7767e7ee
f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6fbfbfbfbeaeaeaeaf600000000fb0000f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6ee9a4aeeeee944eeeeeeeeeee777e6ee
747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474ee94949eeeea94eeeeeeeeeeeeeeeeee
747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474ee94eee9ee9e9eeeeee81eeeeeee77ee
747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474eaeeeeeeeeee94eee776651eeeeeeeee
747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474eeeeeeeeeeeeeeee76666d51eeeeeeee
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeee55555555
000000000000000000000008080808080000000000000000000000000000000008080808080808080808080808080808eee8eedeeeee8edee8eeeededddddddd
000000000000cdcddadacdcddadacd000000000000000000000000000000000000000000000000000000000000000000ee5deedeee5dee9ee5deeed9111d1111
00000000000000dafcfcfcfcfcfcda080000000000000000000000000000000008f4f400000000000000000000000008e0050000e00509a80050098e42d14242
000000000000cdcddadacdcddadacd000000000000000000000000000000000000000000000000000000000000000000ee50eedeee50ee9ee50eeed99d149494
00000000000000dafdfdfdfdfdfdda080000000000000000000000000000000008f4f400000000000000000000000008e5ee0edee5ee9edee5e4eeded1494949
000000000000cdcddadacdcdcacacd0000000000000000000000000000000000000000000000000000000000000000005eee0ede5eee4ede5eee9ede1444444d
00000000000000f6dada00dada00da08000000cececececece00000000000000080000000000000000000000000000085eee0ede5eee0ede5eee0ede242424d1
000000000000cdcdcdcdcdcddadacd000000000000000000000000000000000000000000000000000000000000000000dd505510000000000000000042424d12
0000000000000000000000000000da08000000eaeaeaeaeaea0000000000000008000000000000000000000000000808d550100000000000000000004444d144
000000000000cdcddadacdcddadacd0000000000000000000000000000000000000000000000000000000000000000005510dd500000000000000000949d1494
000000000000000055cadacadacada08000000f5cacacacaf500000000000000080000000000000000000000000008081000d550000000000000000049d14949
000000000000cdcdcacacdcdcacacd000000000000000000000000000000000000000000000000000000000000000000dd50551000000000000000002d142424
000606161600160054cadacadacada08000000f524242424f50000000000cece08000000000000000000000000000808d55010000000000000000000dddddddd
000000000000cdcddadacdcdcdcdcd000000000000000000000000000000000000000000000000000000cece000000005550d550000000000000000011111111
00daf6f6f6dada000000000000000808000000f527000000000000cecece16160800000000000000000000000000080810005510000000000000000055555555
000000000000cdcdcacacdcd5554cd00cecece0000000000000000000000000000000000000000cece0016d900000000eeeeeeeee76c67c611a9a9a9a9a9a9a9
08da2424242424da24242400da5455080000000024cacaca00cece160606160608000000000000000000000000000008eeeeeeeee76c67c6111111111aaaaaaa
000000000000cdcddadacdcd5454cd00f5eaea00000000000000000000000000000000cece00000616d9cfcfcfcfcfcfeeeeeeeee76767c6a9a9a9a919a9a9a9
08da2424242424da24242400da5454080000000024242424000616060606061608000000000000000000000000000008eeeeeeeeee7767769ffffffa1aaaaaaa
041400000000cdcddadacdcddadacd00f5f5e40000eaeaeaeaea000000000000000000060616d9d9cfcfcfcfcfcfcfcfeeeee77eee766e7ea07ff70919a9a9a9
08da5454da00000000000000da00000800000000000000270006cf16cfcf161608000000000000000000000000000008ee776776ee767e7e9ffffffa1aaaaaaa
051500041400cdcddadacdcddadacd00f5e4000000dadadadada00000000d9061616060606d9d9cfcfcfcfcfcfcfcfcf77677677eee7eeeea9feefa919a9a9a9
08dafcfcfcfcfcdafcfcfcfcda2424da000000f5cacaca2400cfcfcfcf06cfcf08000000000000000000000000000008ddddddddeee7eeee9a922a9a1aaaaaaa
000025051525cdcddada2727dadacd00f5e4000000dadadadada0006060606d9060606d9cfcfcfcfcfcfcfcfcfcfcfcf77777677eeeeeeee1111111119a9a9a9
08dafdfdfdfdfddafdfdfdfdda2424dacececef52424242400cf060606cf16cf0800000000000000000000000000000876766777e56eeeee1a9a19a911111111
000000000000000000eaeaeaea000000cfcfcfcfcfcfcfcfcfcf06cfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcf67777676e666eeee19a91a9a1a9a19a9
08f40000000000000000000000000008060606ea000000000006cfcfcf16cfcf08f4000000000000000000000000000877777777eed56eee1fff1fff1fff1fff
27272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272777667766edee56ee3333333333333333
27272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272776777677edeee56e4333433433344333
27272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272777777776deeeee564344434443444434
27272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272766677777deeeeee54444444444444444
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000102000000000000000000000000101010800000000000000000000000102040000000000000000000000000204
0000000000000000000000000100000000000000000000000000000001010204000000000000000000000000000001000000000000000000000000000000100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000001000000
__map__
00000000000000000000000000000000004f000000000000000000000000000000000000000000000000000000000000000000000000000000710000000000000000000000000000000000007e6f6f6f00000000000000000000007e6f2929290000000000000000000000000000000000000000000000000000000000000000
00000000000000000000330000000000004f00000000000000000000000000000000000000000000000000000000002a0000000000000000006061607100000000000000000000000000007e6f6f6f2b000000000000000000007e6f296f6f6f000000000000000000000000ae00000000000000000000000000000000000000
00006f000000000000006f00006f0000004f00000000000000000000000000000000000000000000000000000000006100000000000000000000006060616060000000000000000000007e6f6f2b6f6f000000000000000000006f6f706060600000000000007e6f6f6f6f6f7e6f7f000000000000af00000000000000000000
aeae6f000000000000000000006faeae000000000000000000000000000000000000000000004041000000003200006061000000000000000000004600606060000000000000000000006f6f6f6f6f6f000033000000000000008f00005d4f5d00000000007eae2b004700000046ae7f00000000004700000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000002a5252505100000044444423606000003300000000000000547060606100000000000000006300622b2b006f6f000052000000000000008f005d004600000000000000ae00004700000032ae00003300000047000000000000af000000
000000000000000000000000000000000000000000000000000062000000000000000061606160600000002b004623607f236061616071000070616f6060607e000000000000007e6f2b6f000000716f619c9d9f0000000000008f0e00115400000000000000ae005c8c8c8c8c8c6f0061617147474700000000000047000000
0000000000002b000000000000000000000000006200000000000000000000000040418f002b2b8f0000006f000023606f236060606160714f6060606f4e006f00000000000000008f008f0000706047609d009d9c9f000000008c8c8c8c8c8c000000000000ae5d004600472b00ae006f6f6f6f6f6f00626262620047110000
0000000000000000000000000000000000000000006200000062000000000000002a518f0000008f0000006f236f6f616f2346007272727272734700004e006f00000000000000008f008f11000060479c6c7c7d9d9c9f0000008f000000005d000000000000ae118d8e2a47005dae002b6f0000000000626262620047474747
4100000000000000000073000000470000000000006200006200000000000000006160607100008f00000047236f60616f2353007272727272734700004e326f003300004041007060616171000061479d2a9d9d9c9d9d9f53008f005d0032000000000000006f8c8c8c8c8c0000ae007c6f000000000062626262008c8c8c8c
510000000000000000000000007347000000000000000062000000000000000000602b467300008f00000047236f7f606f236f6f7f72727e6f6f6f4343436f6f6160712a50517060616060617123604700002a00007d006f6f6f434343436f4f003300000000477273005b625d00ae527c6f00460000626f6f6f6f6247000047
9c000000000000000000000000709c9c00000000000000620000000000000000636000337300008f007e6f6f6f6f6f6f6f23474347727e6f6f6f6f6363636f6f60606061606160606060606060236147000000007c007e6f0000000000000000616061616071475b735a6262625cae615d6f0000000062626262626247000047
9d00000000000000000000006f60609d000000000000620000000000000000006f6f6f8c8c616061616f6f00620000006f234743477e6f6f00616f6f6f6f6f6f60612b3200002b11112b002b472360470000002b7e6f6f6f8d8e636363636363737c005d60606f6f6f6f6f6f6f6f6f605c6f0000000062626262626247003247
9d002b9d619d609d619c00002b5d609c000000006262000062000000000000006f6f6f7f6060602b606f6f00620062006f6f6f6f6f6f61007e7f60616160607e6f606e6e6e62008d8e1111114723604700587e6f6f6f6f6f6f6f6f6f6f6f6f6f73005d009d60606060606161616060606f6f6f6f6f6f6061616061606f6f6f6f
9d2b006000462b00004700005d00609d4f0000000000000000000000000000006f6f6f6f606061607e6f6f6f6f6f6f6f6061606f6f6f007e6f6f6f6f6f617e6f6f6f60616160606161606061606060607e6f6f6f6f6f6f6f9c61619d9d619d9d727300009d9d9d9d619d7c9d9d9d9d6060606060606060606060606f6f6f6f6f
9d9c60608d8e001132470070606161604f4f0000000000000062000000000000474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747
606060606060606060606060606060604f4f0000000000000000620000000000474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005250520047000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404750500000000000000000000000000000006f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004f4f4f4f4f4f4f4f00004f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000047727272000000000000000000000000000000006f00000000000000000000000000006f606000000000000000000000000000ae00000000000000000000000000000000000000
4f4f4fadadadadadadadad0000adad7200000000000000000000000000000000000000000000000000000000000000000000000040410000004772727200000000000000000000000000000000000000404100000000000000005f5f5f5f5f5f000000000000004242adacacacad000040410000000000000000000000000000
dcdcdcdcdcdcdcdcdcdcdc4f4fdcdc720000000000000000000000000000000000000000000000000000000000004f00000000005051000000477272720000600000000000000000006200424262000050510000000000000000424242454245000000000000004242adacacacad000050510000000000000000000000000000
dcdcdcdcdcdcdcdcdcdcdcdcdcdcdc720000000000000000000000620000000000000000000000000000006f72457200604200000000500000470000000000600000000000000000006f004242626f0000000000000000000000424242554255000000000000004242aeaeaeaeae0000000043434343000000af000000000000
dcdcdcdcdcdcaddcdcdcdcdcdcdcdc7200000000000062000000626200000000000000484848484800000000725572005f4272727272724f005f5f5f5f724560000000000000000042424242426f006f609d9d9d0000000000005f5f5f5f5f5f000000000000004242adacad42420000aeaeaeaeaeae00000047000000000000
dcdcdcdcdcdcaddcdcdcdcdcdcdcdc7200000000000000620000620000000000005000484848484800000000727200006f42424272727272725f5f5f5f7255604041000000000000424242424242006f9c9d9c619d9c41000000424242424242000000000000004242adacad42420000aeae7242427300000047000043434343
dcdcdcdcdcdcaddcdcdcdcdcdcdcdc7200000000000000000062000000000000000000484848484800000072725f5f5f6f42424272727272725f5f5f5f7245605051000000000000000042424242006f9d619d9d9c9d00000000424242424242000000000000aeaeaeaeaeae42420000aeae72424273000000470000ae6060ae
dcdcdcdcdcdcaddcdcdcdcdcdcdcdc7200000000000000620000006200000000007272724848484800404172725f605f6f42424272727272725f5f5f5f5f5f600000000000000000000000424242006f9c9d9d619d9d9c0000000000000000420000000000007272adadadad42420000aeae72acac7300aeaeaeae00ad7272ad
dcdcdcdcdcdcdcdcdcdcdcdcdcdcdc720000000000626200000000006200000052727272484848485250515f5f5f5f5f6f42424245727272725f5f2929295f600000000000000000000072727272006f9d9d9c609d619d0072722929292972720000000000007272adadadad42420000aeae72acac7300af4747af00ad7272ad
9ddcdcdcdcdcdcdcdcdcdcdcdc9c6060000000000000000000000000006200005f7272606072725f5f5f5f42424242425f4242425572727260605f5f5f5f5f600000727272ad7272727272727272006f9d619d609d9d610072722929292972729d9d9c9d000000000000000000000000aeae72424273004747474700ad7272ad
9d61619d609d609d609d72ad7272009c000000000000000000000000006200005f7272617272726060605f4242424242000000000060606060600000000060600000727272ad7272727272727272006f9d60619d6161600000000000000000009d9c9d9d000000000000000000000000aeaeaeaeaeaeaeaeaeaeaeaeaeaeaeae
9d61609dad45ad72adad72ad7272729d000000000000000000000000000000005f5f5f5f5f5f5f5f60605f5f5f5f5f5f00000000006060616060000000006060000000000000000000000000000000009c9d609d9d609d0000000000000000009d9d9d9d0000000000009d000000000000000000000000000000000000000000
9d9c609dad55ad72adad72ad60000060000000000000000000000000000000005f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f727272727272727272727272727272725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f727272727272727272727272727272725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f72727272727272727272727272727272
60606060606060606060606060606060000000000000000000000000000000005f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f727272727272727272727272727272725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f727272727272727272727272727272725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f72727272727272727272727272727272
__sfx__
01030000006000436306377096770c673143671a3631b660206632566327660276502765325640236401a64014630106300f63008630096300b6300b6300b6300b6300b62009620096200a610096100961000610
01030000102330e223002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
01030000101450f141101410f1410f041100410f04500100151611716115161171651516117161151611716117151151511715515151171511315500100001000010000100001000010000100001000010000100
010200000e73114731177311e7312174125741277412b741287412674123741207411d7311b731187311673114721127210f7110c7110b7110a7110a711097110971109711087110771107711087110771107711
000100001c1551a1511c1711a1511d0611f0611d0551f0751a161181511a151181551a151181411a1351813117141151411514117145111411313110135101310e1310c125001010010100101000000000000000
010700001c65300000136430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000007011075110751177511f751007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701
01040000110550700500005120551e0550000521055000052b0550000500005340550000534055000050000500005000050000500005000050000500005000050000500005140050000500005000050000500000
010800002115322623006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000000
01020000000000000000300003002d351373613233500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
010300000040000400123511145110355004001045300400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
001000001a6451d6451a6551d6551a6651d6651a6651d6651a6651d6651a6651d6651a6651d6651a6651d6651a6651d6651a6551d6451a6451d6351a6351d6351a6351d6251a6251d6251a6251d6151a6151d615
01040000135501b550185501b550185501b550185501b5501a5501d5501a5501d5501a5501d5501a5501d5501b5501f5501b5501f5501b5501f5501b5501f5502455020550245502055024550205502455020550
0108000000000000000000000000000000000000000000001a2541a255002001a2541a255002001e2541e255002002125421255002001e2542125421250212550020000200002000020000200002000020000200
0108000012030120301203012035120301203012030120350e0300e0300e0300e0350e0300e0300e0300e03512030120301203012035120301203012030120350000000000000000000000000000000000000000
010900000000026643283430020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030000000000000000000000000
000300000070000700257111c7311f743257511d7612433323313216251f6111e6011e60100700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
010700003175000700007001e75000700007000070029750007002975000700297500070000700007000070000700007000070000700007000070000700007000070000700007000070000000000000000000000
010700002d75028700000000000029750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000e6632b66310653276433175031750000000000000000007001e7501e7500070000000000000000029751297512875128751287512673126731267312573129731297212572125721247112471124715
010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000e643000000e643000000e643000000e643000000e643106430e643106430e643000000e643000000e643000000e643000000e643000000e643000000e643106430e643106430e643000000e64300000
010c00000c053000000c053000000c053000000c053000000c053000000c053000000c053000000c053000000c053000000c053000000c053000000c053000000c053000000c053000000c053000000c05300000
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
04 0d 0e 43 44
03 16 42 43 44
02 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
