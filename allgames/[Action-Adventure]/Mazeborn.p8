pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--mazeborn
--by gymcrash.com

--game
menuitem(2,"gamejam edition", function() load("mazeborngamejam.p8") end)
menuitem(1,"mazeborn v1.02", function() load("rogueminute.p8") end)
f=0
gamestate=0
gamestatewait=0
plr={}
maze={x=3,y=3,size=9, state=0,timer=0, --3,3
timeroff=-flr(time()),key=nil,exit=nil,
numofitems=2,
numofpotions=2,
numofenemies=4,
permitems={},
level=1 --1
}
cam={x=0,y=0,tx=0,ty=0,xtmr=0,ytmr=0}

attacks={}
enemies={}
fxs={}
music(1)

function calculatemapxy(obj,i,j)
 local ax,ay,mod=(obj.mx*(maze.size-1)*8),
    (obj.my*(maze.size-1)*8),(maze.size*4)
  obj.x=ax+mod+i
  obj.y=ay+mod+j
end

function calculateplrcell()
  local xcell,ycell=flr(((plr.x+8)/8)/(maze.size-1)),flr(((plr.y+8)/8)/(maze.size-1))
  return {xcell, ycell}
end

function collision(a,b,hbx,hby)
  return (a.x < (b.x+hbx) and
    (a.x+hbx) > b.x and
    a.y < (b.y+hby) and
    (a.y+hbx) > b.y)
end

function blood(actor,factor,col,tileref)
  col=col or 8
  local mx,my=0,8
  if(actor.dirc==2)then my=-8
  elseif(actor.dirc==3)then 
    mx=8 
    my=0
  elseif(actor.dirc==4)then 
    mx=-8
    my=0
  end
  local dist=flr(rnd(3))+1*(3/factor)
  circfill(actor.x+mx+(dist),actor.y+my+(dist),factor/2,col)
end

function message(x,y,msg,col)
  local cl,length=col or 7,#msg*4
  rectfill(x,y,x+length+10,y+14,1)
  rect(x+2,y+2,x+length+8,y+12,13)
  print(msg,x+6,y+5,cl)
end

function init()
  maze={
    x=3,y=3,size=9, state=0,timer=0, --3,3
    timeroff=-flr(time()),key=nil,exit=nil,
    numofitems=2,
    numofpotions=2,
    numofenemies=4,
    permitems={},
    level=1 --1
  }
  cam={x=20,y=20,tx=0,ty=0}

  attacks={}
  enemies={}
  fxs={}
  plr=player()
  plr.x=20
  plr.y=20
  newmaze(maze.x,maze.y,maze.size)
  cam.x=plr.x
  cam.y=plr.y
  cam.xtmr=0
  cam.ytmr=0
  additems()
  addenemies()
end

function _update()
  if(gamestate==0)then
    updatetitle()
  elseif(gamestate==1)then
    updateintro()
  elseif(gamestate==2)then
    updatemaze()
    updateenemies()
    updateattacks()
    updatefxs()
    if(plr.state == 0) then gamecontrol() end
    plr.upd(plr)
    updateitems()
  elseif(gamestate==4)then
    updategameover()
  elseif(gamestate==9)then
    updateending()
  end
end

function updateending()
  if(btnp(5) or btnp(4))then
    gamestate=0
    gamestatewait=0
    music(1)
  end
end

function updatetitle()
  if(btnp(5))then
    gamestate=1
    gamestatewait=0
    music(0)
  end
end

function updateintro()
  if(gamestatewait>10)then
    if(btnp(5) or btnp(4))then
      gamestate=2
      init()
      music(-1)
      sfx(13)
    end
  end
  gamestatewait+=1
end

function updategameover()
  if(gamestatewait>10)then
    if(btnp(5) or btnp(4))then
      gamestate=0
      gamestatewait=0
      music(1)
    end
  end
  gamestatewait+=1
end

function gamecontrol()
    local x,y,s=0,0,1

    if(btn(3)) then
        plr.dirc=1
        y=s
     end 
    if(btn(2)) then
        plr.dirc=2
        y=-s
     end 
    if(btn(1)) then
        plr.dirc=3
        x=s
     end 
    if(btn(0)) then
        plr.dirc=4
        x=-s
     end
    if(x!=0 or y!=0)then
      plr.move(plr,x,y,0.2)
    end
     if(btnp(4) and btnp(5))then
       plr.usepotion(plr);
     elseif(btnp(4))then
       if(plr.stm>1)then
        plr.commanddash(plr)
        plr.stm-=10
       else
        sfx(18)
       end
     elseif(btnp(5)) then
       if(plr.stm>1)then
        plr.attack(plr)
         plr.stm-=5
       else
        sfx(18)
       end
    end

end
  
function updatestep()
      plr.stepanim=(plr.stepanim+1)%2
end

function updateitems()
  deleteobjs(maze.items)
  deleteobjs(maze.permitems)
  updateobjs(maze.items)
  updateobjs(maze.permitems)
 
end

function updateattacks()
  deleteobjs(attacks)
  updateobjs(attacks)
  foreach(attacks,function(a)
    if (collision(a,plr,8,8))then
      plr.hit(plr,a)
    else
      foreach(enemies, function(e)
        if(a.type!=e.type and collision(a,e,a.hbx,a.hby))then
          e.hit(e,a)
         end
      end)
    end
  end)
end

function updatefxs()
  deleteobjs(fxs)
  updateobjs(fxs)
end

function updateenemies()
  deleteobjs(enemies)
  updateobjs(enemies)
end

function updateobjs(t)
  foreach(t, function(a)
    a.upd(a)
  end)
end

function deleteobjs(t)
  foreach(t,function(a)
    if(a.active==false and a.anitmr and a.anitmr<1)then
      del(t, a)
    end
  end)
end

function _draw()
  cls(0)
  if(gamestate==0)then
    titlescreen()
  elseif(gamestate==1)then
    drawintro()
  elseif(gamestate==2)then
    starfield()
    focuscamera(plr)
    
    fillfloor(maze.x,maze.y,maze.size)
    drawfx()
    drawmaze(maze)
    drawitems()
    drawenemies()
    plr.drw(plr)
    drawattacks()
    drawfxs()
    camera()
    hud()
    message(88,112,"depth "..maze.level)
    local ploc=calculateplrcell()
    --message(5,112,ploc[1]..","..ploc[2])
     --message(50,112,plr.x..","..plr.y)
  elseif(gamestate==9) then
    drawending()
  end
  if(gamestate==4)then
    focuscamera(plr)
    fillfloor(maze.x,maze.y,maze.size)
    drawmaze(maze)
    drawitems()
    drawenemies()
    camera()
    hud()
    message(40,50,"you died",8)
    message(15,68,"insanity has taken you",6)
    message(25,85,"reclaim your mind",7)
  end
end

function drawobjs(t)
  foreach(t, function(i)
    if(i.drw)then i.drw(i) else  
      i.draw(i)
    end
  end)
end

function drawfxs()
  drawobjs(fxs)
end

function drawitems()
  drawobjs(maze.items)
  drawobjs(maze.permitems)
end

function drawattacks()
  drawobjs(attacks)
end

function drawenemies()
  drawobjs(enemies)
end

function focuscamera(actor)
  pancam2("x")
  pancam2("y")
  camera(cam.x-60,cam.y-70)
end

function pancam2(coord)
  local limit=14
  if(abs(plr[coord]-cam[coord])>limit) then
    cam["t"..coord]=plr[coord]
    cam[coord.."tmr"]=14
  end
  if(cam[coord.."tmr"]>0)then
    local v=(abs(cam["t"..coord]-cam[coord])/cam[coord.."tmr"])
    if(cam["t"..coord]!=cam[coord])then
      if(cam[coord]>cam["t"..coord])then
        cam[coord]-=v
      else
        cam[coord]+=v
      end
    end
    cam[coord.."tmr"]-=1
  else
    cam[coord]=cam["t"..coord]
  end
end

function hud() --hud
  rectfill(0,0,128,16,0)
  rect(1,1,126,17,6)
  
  rectfill(2,3,52,7,13)
  rectfill(2,4,max(flr((plr.hp/50)*50)+2,3),7,8)
  
  rectfill(2,9,min(plr.stmax,50),13,13)
  rectfill(2,10,max(min(plr.stm,50),2),13,3)
  
  local timemod=maze.timer%2
  circfill(65,9,8+timemod,maze.timer>55 and 14 or 2)
  circfill(65,9,7,8)
  circ(65,9,7,0)
  print((maze.timer<10 and "0" or "")..maze.timer,62,7,maze.timer>55 and 10 or 7)
  
  spr(8,76,4)
  print(""..plr.potions, 85,6,7)
  
  
  spr(7,92,7)
  spr(23,89,4)
  if(plr.treasure != -1) then
    print(""..plr.treasure.."/"..maze.numofitems, 101,6,7)
  else
    print(maze.numofitems.."/"..maze.numofitems, 101,6,7)
  end
  
  spr(21,116,4)
  if(maze.plrkey) then
    spr(5,116,4)
  end
  
end

function drawintro()
  print("navigate your insanity.",7,10,7)
  print("unlock your mind's potential.",7,18,7)
  print("fight your inner demons.",7,26,7)
  print("increase your stamina by",7,34,7)
  print("finding treasured memories.",7,42,7)
  
  print("crawl back to us from the",7,60,8)
  print("horrors of the mind, and be",7,68,8)
  print("reborn...",7,76,8)
  
  print("\x97 - attack   \x8e - dash ",13,90,11)
  print("\x97+\x8e - heal",13,98,11)
  print("press \x97 or \x8e to start",15,120,10)
end

function drawending()
  fillfloor(maze.x,maze.y,maze.size)
  print("you have reached the limits of",7,10,7)
  print("your mind and escaped madness!",7,18,7)
  print("you have left scars deep",7,26,7)
  print("in your psyche...",7,34,7)
  
  if(plr.stmax>49)then
    print("\x92\x92\x92 good ending \x92\x92\x92",15,1,10)
    print("...but you drew strength from",7,60,10)
    print("your treasured memories and",7,68,10)
    print("overcame your evil. well done!",7,76,10)
  else
    print("\x82\x82\x82 bad ending \x82\x82\x82",17,1,8)
    print("...you are a twisted shell of",7,60,8)
    print("your former self...tell me...",7,68,8)
    print("...are you truly reborn?",7,76,8)
  end
  
  print("game over",45,90,11)
  print("thanks for playing!",25,98,11)
  print("press \x97 or \x8e to end",20,120,10)
end

function titlescreen()
  local modbool=flr(time())%2==0
  print("gymcrash presents",32,14,1)
  print("gymcrash presents",31,14,6)
  rect(23,21,105,32,6)
  spr(97,24,20,10,2)
  for i=0,6,1 do
    local mod=modbool and 2 or 0
    drawskel(36+i*4,mod+54+(i%2)*2,true,modbool)
  end
  for i=0,14,1 do
     local mod=modbool and 0 or -1
    drawskel(22+i*4,mod+60+(i%2)*2,true,not modbool)
  end
  drawskel(52,68,false,modbool)
  spr(12,58,84)
  spr(9,50,84)
  spr(11,66,84)
  spr(26,58,92,1,1,modbool)
  print("press \x97 to start", 30,100, 7)
  spr(70,44,108,5,2)
  print("(c) 2018 gymcrash.com", 22,122,5)
end

function drawskel(x,y,sil,walk)
  if(sil)then
    pal(7,1)
    pal(8,1)
    pal(6,1)
    pal(13,1)
  end
  spr(41,x,y,3,1)
  spr(58,x+8+(walk and -1 or 0),y+8,1,1,walk)
  pal()
end

function starfield()
  local mod=(time()+30)/500
  for i=0,100,1 do
    circfill((cos(i*mod)*i)+60,(sin(i*mod)*i)+60,1,2)
    circfill((sin(i*mod/2)*i)+64,(sin(i*mod/3)*i)+64,1,1)
  end
end


--entity
actor={}
actor.v=1
actor.x=1
actor.y=1
actor.ox=1
actor.oy=1
actor.tx=1
actor.ty=1
actor.active=true
actor.anitmr=0
actor.hp=10
actor.hpmax=10
actor.stm=20
actor.stmax=20
actor.sprite={}
actor.hittmr=0
actor.dirc=1
actor.stepanim=0
actor.idle=0
actor.blood=8
actor.type=1 --1=normal,2==imp
actor.state=0 --0=normal,1-attack,2-hit,3-dash,9-dead
actor.stain=20
actor.deathsprite=18


function actor:new(o)
 o = o or {}
 setmetatable(o, self)
 self.__index=self
 return o
end

function actor:upd()
  if(self.anitmr > 0) then self.anitmr-=1 end
  self.idle = (self.idle+1)%60
  if(self.state==3) then self.dashto(self,self.tx,self.ty) end
  if(self.state !=9 and self.anitmr==0)then
    self.state=0
  end
  if(self.state !=9)then
    if(self.hp<0)then
      sfx(6)
      self.state=9
    else   
      if(self.stm<self.stmax)then
        self.stm+=0.25
      end
      self.update(self)
    end
  end
  if(self.state==9)then
    self.updatedead(self)
  end
end

function actor:update()
end

function actor:updatedead()
  local xmap,ymap=flr(self.x/8),flr(self.y/8)
  mset(xmap,ymap,self.deathsprite)
  self.active=false
  self.anitmr=0
  add(fxs,spark(self.x,self.y,self.blood))
end

function actor:drw()

  if(self.state==3)then
    pal(7,0)
    local xm,ym,mod=0,0,self.anitmr/4
    if(self.dirc==1)then ym=-1 
    elseif(self.dirc==2)then ym=1
    elseif(self.dirc==3)then xm=-1
    elseif(self.dirc==4)then xm=1 end
    self.draw(self,self.ox+xm*(self.anitmr),self.oy+ym*(self.anitmr))
    self.draw(self,self.ox+xm*4*mod,self.oy+ym*4*mod)
    self.draw(self,self.ox+xm*2*mod,self.oy+ym*2*mod)
    self.draw(self,self.ox+xm,self.oy+ym)
  end
  pal()
  self.draw(self,self.x,self.y)
  
  if(self.state==2)then
    blood(self,self.anitmr,self.blood)
  end
  self.nrgbar(self)
end

function actor:nrgbar()
end

function actor:move(x,y,step)
  if(x==0 and y==0) then return end
  local nx,ny=self.x+x,self.y+y
  if((mget(flr((nx+8)/8),flr((ny+8)/8)) != 1 and 
     mget(flr((nx-2)/8),flr(ny/8)) !=1
     and not self.collisionwithitem(self,flr(nx),flr(ny))))then
    self.ox=self.x
    self.oy=self.y
    self.x=flr(nx)
    self.y=flr(ny)
    if(step) then
      self.stepanim=(self.stepanim+step)%2
    else
      self.stepanim=(self.stepanim+1)%2
    end
  else
    self.x=self.ox
    self.y=self.oy
    self.tx=self.x
    self.ty=self.y
  end
end

function actor:collisionwithitem(nx,ny) 
  foreach(maze.items, function(i)
    if(i.collide==0)then
        if(((nx+8>i.x-4 and nx<i.x+4)
          or (nx-8>i.x-4 and nx-8<i.x+4)) and
          ((ny-8>i.y-4 and ny-8<i.y+4) 
          or (ny+8>i.y-4 and ny+8<i.y+4))) then
          return true
        end
    end
  end)
  return false
end

function actor:dashto(x,y)
  if(self.state==0) then
    self.state=3
    self.anitmr=9
    self.tx=flr(x)
    self.ty=flr(y)
  elseif(self.state==3) then
    if(self.anitmr==0)then
      self.x=self.tx
      self.y=self.ty
      self.ox=self.x
      self.oy=self.y
      self.v=2
      self.state=0
    else
      self.movetowards(self,self.tx,self.ty, true)
      self.stepanim=1
    end
  end
end

function actor:movetowards(x,y,dash)
  local nx,ny,vx,vy=0,0,self.v,self.v
  if(dash) then
    vx = abs(x-self.x)/self.anitmr
    vy = abs(y-self.y)/self.anitmr
  end
  
  if(self.x > x) then 
    nx=-vx 
    self.dirc=4 
  end
  if(self.x < x) then 
    nx=vx  
    self.dirc=3 
  end
  if(self.y > y) then 
    ny=-vy 
    self.dirc=2 
  end
  if(self.y < y) then 
    ny=vy  
    self.dirc=1 
  end
  self.ox=self.x
  self.oy=self.y
  self.move(self,nx,ny)
end

function actor:hit(other)
  if(self.state!=3 and self.state!=2 and self.state!=9) then
    self.state=2
    self.anitmr=9
    local xm,ym,oy,ox=0,0,0,0
    if(not other.move)then other.v=0 end
    
    if(self.dirc==4)then
      xm=self.v
      ox=-other.v
    elseif(self.dirc==2)then
      ym=self.v
      oy=-other.v
    elseif(self.dirc==3)then
      xm=-self.v
      ox=-other.v
    elseif(self.dirc==1)then
      ym=-self.v
      oy=other.v
    end
    self.move(self,xm*3,ym*3)
    if(other.move)then
      other.move(other,ox*3,oy*3)
      self.hp-=5
    else
      other.active=false
      self.hp-=other.dmg
    end
    local xmap,ymap=flr(self.x/8),flr(self.y/8)
    local tile=mget(xmap,ymap)
    if(tile>4 and tile !=17)then
      mset(xmap,ymap,self.stain)  
    end
    sfx(1)
  end
end

function actor:commanddash()
    local x,y,v=self.x,self.y,22
    if(self.dirc==1)then
      y+=v
    elseif(self.dirc==2)then
      y-=v
    elseif(self.dirc==3)then
      x+=v
    elseif(self.dirc==4)then
      x-=v
    end
    sfx(2)
    self.dashto(self,x,y);
end

function actor:drawhumanoid(x,y)
    local top,lhand,rhand,idle=self.sprite[self.dirc],-8,8,0
    local dirc=self.dirc
    if(dirc==2)then
      lhand,rhand=8,-8
    elseif(dirc==3)then
      lhand,rhand=-5,8
    elseif(dirc==4)then
      lhand,rhand=5,-8
    end
    idle=self.idle>30 and 1 or 0
    if(self.idle%5==0)then 
      pal(9,10)
      pal(10,9)
    end
    if(dirc==2)then
       self.drawswordhand(self,x,y,rhand,idle)
    end
    spr(self.sprite[5],x+lhand,y-idle,1,1,dirc==2 or dirc==4)
    pal(9,9)
    pal(10,10)
    spr(top,x,y,1,1,self.dirc==4)
    if(dirc != 2)then
      self.drawswordhand(self,x,y,rhand,idle)
    end
    spr(self.sprite[7],x,y+8,1,1,self.stepanim<1)
end

function actor:drawswordhand(x,y,rhand,idle)
    local s=self
    if(s.state==1)then
      local xmod,ymod=(s.dirc==4) and 2 or -2,4
      local xmirr,ymirr=s.dirc==2 or s.dirc==4,s.dirc==4 or s.dirc==3
      if(s.dirc==1 or s.dirc==2)then
        xmod=s.dirc==1 and -8 or 8
        ymod=s.dirc==1 and 5 or -1
        ymirr=s.dirc==1
        xmirr=s.dirc==1
      end
      spr(s.sprite[6],x+rhand+xmod,y-idle+ymod,1,1,xmirr, ymirr)
    else
      local ymod=(s.dirc==1) and 4 or 0
      spr(s.sprite[6],x+rhand,y-idle+ymod,1,1,s.dirc==2 or s.dirc==4, s.dirc==1)
    end
end

function actor:attack()
  local s=self
  if(s.state==0)then
    s.state=1
    s.anitmr=9
    s.addattack(s)
  end
end

function actor:addattack()
  sfx(0)
  add(attacks, swordattack(self))
end
  
function player(x,y)
  local p=actor:new()
  p.hp=50
  p.hpmax=50
  p.stmax=20
  p.treasure=0
  p.potions=0
  p.sprite={10,12,13,13,9,11,26}
  p.draw=function(s,x,y)
   s.drawhumanoid(s,x,y)
  end
  p.usepotion=function(s)
    if(s.potions>0)then
      s.potions-=1
      s.hp+=20
      s.hp=min(s.hp,s.hpmax)
      add(fxs,spark2(s.x,s.y-16,14))
      add(fxs,spark2(s.x-4,s.y-14,14))
      add(fxs,spark2(s.x+4,s.y-14,14))
      sfx(9)
    end
  end
  p.update=function(s)
    if(s.treasure==maze.numofitems)then
      s.treasure=-1
      s.stmax+=5
      s.stmax=min(s.stmax,50)
      add(fxs,spark2(s.x,s.y-16,3))
      add(fxs,spark2(s.x-4,s.y-14,3))
      add(fxs,spark2(s.x+4,s.y-14,3))
      sfx(8)
    end
  end
  
  p.updatedead=function()
    gamestatewait=0
    gamestate=4
    music(0)
  end
  return p;
end

function enemy(x,y)
  local e=actor:new()
  e.maxanitmr=9
  e.nmestate=0
  e.mx=x
  e.my=y
  e.range=40
  calculatemapxy(e,0,0)
  e.plrinrange=function(s,range)
      return(plr.x > s.x-range and plr.x < s.x+range
        and plr.y > s.y-range and plr.y < s.y+range)
  end
  e.update=function(s)
    if(s.anitmr==0)then
      if(s.plrinrange(s,s.range)) then
        s.behave(s)
      end
      s.anitmr=s.maxanitmr
    end
  end
  e.behave=function(s)
    if(s.nmestate==0)then
        s.movetowards(s,plr.x,plr.y)
        if(s.collideswith(s)==true)then
            plr.hit(plr,s)
            s.nmestate=3
            s.anitmr=9
        end
    elseif(s.nmestate>0)then
        s.movetowards(s,-plr.x,-plr.y)
        s.nmestate-=1
    end
  end
  e.collideswith=function(s)
    return collision(s,plr,8,8)
  end
  e.nrgbar=function(s)
    rectfill(s.x-2,s.y-8,s.x+8,s.y-6,5)
    rectfill(s.x-2,s.y-8,max(flr(s.x+8*(s.hp/s.hpmax)),s.x-1),s.y-6,8)
  end
  return e
end

function slime(x,y)
  local sl=enemy(x,y)
  sl.sprite={14,15,30}
  sl.blood=11
  sl.stain=38
  sl.deathsprite=38
  sl.maxanitmr=6
  sl.draw=function(s)
    local sprite=s.dirc==2 and s.sprite[2] or s.sprite[1]
    spr(sprite,s.x,s.y,1,1,s.dirc==3)
  end
  return sl
end

function skellington(x,y)
  local sk=enemy(x,y)
  sk.hpmax=35
  sk.hp=35
  sk.range=50
  sk.blood=6
  sk.sprite={42,44,45,45,41,43,58}
  sk.stain=33
  sk.deathsprite=19
  sk.draw=function(s,x,y)
    s.drawhumanoid(s,x,y)
  end
  sk.behave=function(s)
    if(s.nmestate==0 and s.plrinrange(s,s.range/2.7))then
        s.nmestate=4
    end
    if(s.nmestate==0)then
          s.movetowards(s,plr.x,plr.y)
    elseif(s.nmestate>0)then
        if(s.plrinrange(s,16) and (s.nmestate==0 or s.nmestate==2) )then
          s.nmestate=4
        elseif(s.nmestate==4)then
          s.movetowards(s,plr.x,plr.y)
          s.attack(s)
          s.nmestate=3
        elseif(s.nmestate==3)then
          s.dirc=flr(rnd(4))+1
          s.commanddash(s)
          s.nmestate=2
        elseif(s.nmestate==2)then
          local action=flr(rnd(3))
          if(action==0)then 
            s.dirc=flr(rnd(4))+1
            s.commanddash(s)
          elseif(action==1)then
            s.movetowards(s,plr.x,plr.y)
            s.attack(s)
          end
          s.nmestate=1
        else
          s.movetowards(s,-plr.x,-plr.y)
          s.nmestate=0
        end
    end
  end
  return sk
end

function superskellington(x,y)
  local ssk = skellington(x,y)
  ssk.maxanitmr=5
   ssk.draw=function(s,x,y)
    pal(7,10)
    s.drawhumanoid(s,x,y)
    pal()
  end
  return ssk;
end

function imp(x,y)
  local i=enemy(x,y)
  i.type=2
  i.hpmax=40
  i.hp=10
  i.hpmax=10
  i.range=60
  i.blood=8
  i.maxanitmr=11
  i.sprite={65,66,67,67,64,68,81}
  i.draw=function(s,x,y)
    s.drawhumanoid(s,x,y)
  end
  i.addattack=function(s)
    add(attacks,fireball(s,plr.x,plr.y,true))
  end
  i.behave=function(s)
    if(s.nmestate==0 and not s.plrinrange(s,s.range/2))then
      s.movetowards(s,plr.x,plr.y)
    end
    if(s.nmestate==0 and (s.plrinrange(s,s.range/1.2)
      and not s.plrinrange(s,20)))then
        s.nmestate=2
    elseif(s.nmestate==0 and s.plrinrange(s,20))then
        s.movetowards(s,-plr.x,-plr.y)
        if(flr(rnd(3))==0) then  s.commanddash(s) end
        s.nmestate=1
    elseif(s.nmestate==2)then
        if(flr(rnd(3))>0)then
          s.sprite[6]=69
          s.movetowards(s,plr.x,plr.y)
          s.attack(s)
        end
        s.nmestate=1
    elseif(s.nmestate==1)then
      s.sprite[6]=68
      s.movetowards(s,-plr.x,-plr.y)
      s.nmestate=0
    end
  end
  return i
end

function nextlevel()
  if(maze.y<7)then
    maze.y+=1
  end
  if(maze.level<8)then  
    maze.x+=1
    maze.plrkey=false
    maze.items={}
    maze.permitems={}
    maze.numofitems+=1
    maze.numofpotions+=1
    maze.level+=1
    plr.x=20
    plr.y=20
    plr.ox=20
    plr.oy=20
    plr.tx=20
    plr.ty=20
    plr.treasure=0
    maze.timer=0
    maze.timeroff=-flr(time())
    maze.state=3
    maze.key=nil
    maze.exit=nil
    maze.numofenemies=flr((maze.x*maze.y)*0.6)
    enemies={}
    additems()
    updatemaze()
    addenemies()
  else
    music(0)
    gamestate=9
    gamestatewait=0
  end
end



function updatemaze()
  local max=60
  
  if(maze.timer==0 and maze.state != 0)then
    sfx(11)
    local xycell=calculateplrcell()
    centeractor(plr, xycell[1], xycell[2])
    maze.state=0
    newmaze(maze.x,maze.y,maze.size)
    
    disappearenemies()
    enemies={}
    addenemies()   
  end
  if(maze.timer==1)then
    maze.state=1
    randomwalkmaze(0,0);
  end
  if(maze.timer==2)then
    maze.state=2
  end
  if(maze.timer==max-3)then
    maze.state=3
  end

  maze.timer=(flr(time())+maze.timeroff)%max
end

function disappearenemies()
  foreach(enemies, function(e)
    add(fxs, spark(e.x,e.y))
  end)
end

function centeractor(actor,mx,my)
  actor.state=0
  plr.mx=mx
  plr.my=my
   if(actor.state==0) then
      add(fxs,spark2(actor.x,actor.y,7))     
      calculatemapxy(plr,0,0)
      add(fxs,spark2(actor.x+6,actor.y,7))
      add(fxs,spark2(actor.x-6,actor.y,7))
      add(fxs,spark2(actor.x,actor.y+6,7))
      add(fxs,spark2(actor.x,actor.y-6,7))
   end
end

function drawmaze(maze)
  if(maze.state==0)then
    pal(1,8)
    pal(6,1)
    pal(13,2)
    pal(5,2)
  end
  if(maze.state==1 or maze.state==3)then
    pal(13,8)
    pal(5,8)
  end
  map(0,0,0,0,maze.x*maze.size,maze.y*maze.size)
  pal()
end

function newmaze(x,y,size)
  for i=0,y-1,1 do
    for j=0,x-1,1 do
      local modx,mody = j>0 and -1 or 0,i>0 and -1 or 0
      drawroom(j*(size+modx), i*(size+mody), size)
    end
  end 
  initmazeroomstate(x-1,y-1)
end

function initmazeroomstate(x,y)
  maze.rooms={}
  maze.items={}
  for i=0,y,1 do
    local row = {}
    for j=0,x,1 do
      add(row,{visited=0})
      adddecoration(j,i)
    end
    add(maze.rooms,row)
  end
  addkey()
  addexit()
  add(maze.items, maze.key)
  add(maze.items, maze.exit)
end


function adddecoration(x,y)
  local deco={0,1,2,3,0}
  local dec=deco[flr(rnd(5))+1]
  if(dec==1)then
    add(maze.items, barrels(x,y))
  elseif(dec==2)then 
    add(maze.items, chains(x,y))
  elseif(dec==3)then 
    add(maze.items, rocks(x,y))
  end
end

function addkey()
  if(maze.key==nil)then
    local x,y=flr(rnd(3))+1,flr(rnd(3))+1
    local locsx,locsy={0,1,0},{maze.y-1,maze.y-2,maze.y-1}
    maze.key=doorkey(locsx[x],locsy[y])
  end
end

function addexit()
  if(maze.exit==nil)then
    local x,y=flr(rnd(3))+1,flr(rnd(5))+1
    local locsx,locsy={maze.x-1,maze.x-1,maze.x-1},{0,1,maze.y-1,maze.y-2,maze.y-3}
    maze.exit=exitdoor(locsx[x],locsy[y])
  end
end

function rcontains(t,val)
  local plrcell=calculateplrcell()
  local vx,vy=val[1],val[2]
  if((vx==0 and vy==0) or 
    (vx==plrcell[1] and vy==plrcell[2]))then
    return true
  end
  if(#t>0)then
    for i=1,#t,1 do
       local tx,ty=t[i][1],t[i][2]
      if(tx==vx and ty==vy)then 
        return true 
      end
    end
  end
  return false
end

function chooserooms(num)
  local rooms={}
  while(#rooms != num) do
    local a=flr(rnd(maze.x))
    local b=flr(rnd(maze.y))
    if(rcontains(rooms,{a,b})==false) then
      add(rooms,{a,b})
    end
  end
  return rooms
end

function addenemies()
  enemies={}
  local rooms=chooserooms(maze.numofenemies)
  local nmelist={1,2,2,3,3,1}
  
  if(maze.level==1)then nmelist={1,1,1,1,1,1}
  elseif(maze.level==2)then nmelist={1,2,1,2,1,1}
  elseif(maze.level==3)then nmelist={1,1,2,3,1,2}
  elseif(maze.level==6)then nmelist={1,1,2,3,2,4}
  elseif(maze.level==7)then nmelist={2,2,3,3,1,4}
  elseif(maze.level==8)then nmelist={3,3,3,3,4,4}
  end
  
  for i=1,#rooms,1 do
    local nme,x,y=nmelist[flr(rnd(6))+1],rooms[i][1],rooms[i][2]
    if(nme==1)then add(enemies, slime(x,y)) 
    elseif(nme==2)then add(enemies, skellington(x,y))
    elseif(nme==4)then add(enemies, superskellington(x,y))
    elseif(nme==3)then add(enemies, imp(x,y)) end
  end
end

function additems()
  local rooms=chooserooms(maze.numofitems)
  for i=1,#rooms,1 do
    local x,y=rooms[i][1],rooms[i][2]
    add(maze.permitems,treasure(x,y))
   end
  local prooms=chooserooms(maze.numofpotions)
  for j=1,#prooms,1 do
    local x,y=prooms[j][1],prooms[j][2]
    add(maze.permitems,health(x,y))
   end
end

function drawroom(x,y,s)
  local size = s-1
  for i=0,size,1 do --west
    mset(x,y+i,1)
    mset(x+1,y+i,2)
  end
  for i=0,size,1 do --north
    mset(x+i,y,1)
    mset(x+i,y+1,4)
  end
  mset(x,y+1,1)
  mset(x+1,y+1,3)
  for i=0,size,1 do --south
    mset(x+i,y+size,1)
  end
  for i=0,size,1 do --east
    mset(x+size,y+i,1)
  end
end

function randomwalkmaze(x,y)
    local dirs = randomizedirs()
    maze.rooms[y+1][x+1].visited=1
    foreach(dirs, function(d)
        if     (d=="n") then
          walkdir(x,y-1,"s")
        elseif (d=="s") then
          walkdir(x,y+1,"n")
        elseif (d=="e") then
          walkdir(x+1,y,"w")
        elseif (d=="w") then
          walkdir(x-1,y,"e")
        end
      end)
end
  
function walkdir(x,y,oppositedir)
  if(x>-1 and y>-1 and y<maze.y and x<maze.x 
    and maze.rooms[y+1][x+1].visited==0) then
    removewall(x,y,oppositedir)
    randomwalkmaze(x,y)
    return true
  end
  return false
end
    
function removewall(x,y,dir)
  local size=maze.size-1
  x=x*size
  y=y*size
  if(dir=="n") then
    for i=2,size-2,1 do --north
        mset(x+i,y,17)
        mset(x+i,y+1,16)
    end
  elseif(dir=="s") then
     for i=2,size-2,1 do --south
      mset(x+i,y+size,17)
      mset(x+i,y+size+1,16)
    end
  elseif(dir=="e") then
     for i=2,size-2,1 do --east
      mset(x+size,y+i,17)
      mset(x+size+1,y+i,16)
    end
  elseif(dir=="w") then
     for i=2,size-2,1 do --west
      mset(x,y+i,17)
      mset(x+1,y+i,16)
     end
  end
end

function randomizedirs()
   local d={"n","s","e","w"}
   local r={}
   while #r !=4 do
    local i = flr(rnd(4-#r))+1
    add(r,d[i])
    del(d,d[i])
   end
  return r
end

function fillfloor(x,y,size)
  palt(0,false)
  if(maze.level%2==0) then
    pal(1,2)
  end
  for m=0, y*(size-1), 1 do
    for n=0,x*(size-1), 1 do
      spr(55, n*8, m*8,1,1,m%3==0,n%6==0)
    end
  end
    pal()
    palt()
end

function drawfx()
  drawplrflamelight()
end

function drawplrflamelight()
  local x,y=plr.x,plr.y
  x=plr.dirc==1 and x-12 or x
  x=plr.dirc==2 and x+6 or x
  x=plr.dirc==3 and x-12 or x
  x=plr.dirc==4 and x+4 or x
  if(maze.level%2==0)then
    pal(1,2)
  end
  if plr.idle%5==0 then
    pal(1,0)
    pal(13,1)
  end
  y=plr.idle>30 and y-1 or y
  spr(36,x,y,2,2)
  pal()
end

gameitem={}
gameitem.mx=0
gameitem.my=0
gameitem.x=0
gameitem.y=0
gameitem.active=true
gameitem.collide=1

function gameitem:new(o)
 o = {}
 setmetatable(o, self)
 self.__index=self
 return o
end

function gameitem:draw()
end 

function gameitem:update()
end 

function gameitem:upd()
  self:update()
end

function gameitem:collision(actor)
  return collision(self,actor,10,10)
end

function gameitem:calculatexy(i,j)
  calculatemapxy(self,i,j)
end

function doorkey(mx,my)
  local k=gameitem:new()
  k.mx=mx
  k.my=my
  k.calculatexy(k,0,16)
  k.draw=function(s)
    if(s.active) then spr(5,s.x,s.y) end
  end
  k.update=function(s)
    if(s.active and s.collision(s,plr))then
      s.active=false
      maze.plrkey=true
      sfx(5)
    end
  end
  return k
end

function exitdoor(mx,my)
  local d=gameitem:new()
  d.mx=mx
  d.my=my
  d.calculatexy(d,0,-16)
  d.draw=function(s)
    spr(6,s.x,s.y)
    spr(22, s.x,s.y+8)
  end
  d.update=function(s)
    if(s.collision(s,plr)) then
      if(maze.plrkey)then
        sfx(13)
        nextlevel()
      end
    end
  end
  return d
end

function barrels(mx,my)
  local b=gameitem:new()
  b.mx=mx
  b.my=my
  b.num=flr(rnd(3))+1
  local xoff,yoff={18,-18},{18,-18}
  b.calculatexy(b,xoff[flr(rnd(2))+1],yoff[flr(rnd(2))+1])
  b.collide=0
  b.update=function(s)
    --destorying this should blow it up innit
  end
  b.draw=function(s)
    spr(49,s.x-4,s.y-2)
    if(s.num==3)then spr(49,s.x+4,s.y-3) end
    if(s.num>1)then spr(49,s.x,s.y) end
    
  end
  return b
end

function simpleitem(mx,my)
  local si=gameitem:new()
  si.mx=mx
  si.my=my
  local xoff,yoff={18,-18},{18,-18}
  si.calculatexy(si,xoff[flr(rnd(2))+1],yoff[flr(rnd(2))+1])
  si.sprite=0
  si.draw=function(s)
  if(s.active)then spr(s.sprite,s.x,s.y) end 
  end
  return si
end


function chains(mx,my)
  local c=simpleitem(mx,my)
  c.sprite=50
  return c
end


function rocks(mx,my)
 local r=simpleitem(mx,my)
  r.collide=0
  r.sprite=35
  return r
end

function treasure(mx,my)
  local t=simpleitem(mx,my)
  local sprt={7,23}
  t.offx=18
  t.calculatexy(t,t.offx,0)
  t.sprite=sprt[flr(rnd(2))+1]
  t.effect=function(s)
    sfx(3)
    plr.treasure+=1
  end
  t.update=function(s)
    if(s.active and s.collision(s,plr))then
      s.active=false
      s.effect(s)
    end
  end
  return t
end

function health(mx,my)
  local h=treasure(mx,my)
  h.offx=-18
  h.calculatexy(h,h.offx,0)
  h.sprite=8
  h.effect=function(s)
    sfx(4)
    plr.potions+=1
    plr.potions=min(plr.potions,9)
  end
  return h
end

function poison(mx,my)
  local p = health(mx,my)
  p.offx=12
  p.calculatexy(p,p.offx,0)
  p.sprite=34
  p.effect=function(s)
    plr.hp-=1
  end
end

attack={}
attack.anitmr=7
attack.active=true
attack.sprite={}
attack.mirrorx=false
attack.mirrory=false
attack.x=0
attack.y=0
attack.dmg=10
attack.type=0
attack.hbx=8
attack.hby=8
function attack:new(o)
 o = {}
 setmetatable(o, self)
 self.__index=self
 return o
end

function attack:upd()
  self.anitmr-=1
  if(self.anitmr<1)then
    self.active=false
  end
  self.update(self)
end

function attack:update()
end

function attack:predraw()
end
function attack:postdraw()
  pal()
end

function attack:draw()
  self.predraw(self)
  local sprite=self.sprite[3]
  if(self.anitmr>5)then
    sprite=self.sprite[1]
  elseif(self.anitmr>3)then
    sprite=self.sprite[2]
  end
  spr(sprite,self.x,self.y,1,1,self.mirrorx,self.mirrory)
  self.postdraw(self)
end

function spark(x,y,col)
  local sp=attack:new()
  sp.col=col and col or 12
  sp.x=x+4
  sp.y=y+4
  sp.sprite={40,56,57}
  sp.anitmr=9
  sp.predraw=function(s)
    pal(12,s.col)
  end
  return sp
end

function spark2(x,y,col)
  local sp=attack:new()
  sp.col=col and col or 12
  sp.x=x
  sp.y=y
  sp.sprite={80,96,112}
  sp.anitmr=9
  sp.predraw=function(s)
    pal(12,s.col)
  end
  return sp
end

function fireball(actor,x,y,r)
  local f=attack:new()
  f.type=2
  f.tx=x
  f.ty=y
  f.x=actor.x
  f.y=actor.y
  f.dmg=5
  f.source=r
  f.anitmr=60
  f.actor=actor
  f.update=function(s)
    local nx,ny=0,0
    if(s.x<s.tx)then nx=1 end
    if(s.x>s.tx)then nx=-1 end
    if(s.y>s.ty)then ny=-1 end
    if(s.y<s.ty)then ny=1 end
    s.x+=nx
    s.y+=ny
    
    if((s.x==s.tx and s.y==s.ty) or s.anitmr<1)then
      s.anitmr=0
      s.active=false
    end
  end
  f.draw=function(s)
    circfill(s.x,s.y,3+s.anitmr%2,10)
    circfill(s.x,s.y,1+s.anitmr%2,9)
    if(s.anitmr%3==0)then sfx(10) end
  end
  return f
end

function swordattack(actor)
  local a=attack:new()
  if(actor.dirc==1 or actor.dirc==2)then
    a.actor=actor
    a.mirrory=true
    a.x=actor.x
    a.hby=12
    a.hbx=12
    a.y=actor.y+12
    if(actor.dirc==2)then 
      a.y=actor.y-12
      a.mirrory=false 
    else
      a.mirrorx=true
    end
    a.sprite={46,47,62}
  else
    a.sprite={59,60,61}
    a.mirrorx=false
    a.x=actor.x+14
    a.y=actor.y
    if(actor.dirc==4)then
      a.mirrorx=true
      a.x=actor.x-14
    end
  end
  return a
end
__gfx__
000000001555555dd110000051111111d11111110000000000055500000000000000200000a00000007777000000007700777700007777000000000000000000
00000000166666651d100000151111111d111111000000000052445000000000000f4f0000990000075555700000076707155570075555700088880000888800
0070070016666665115000001151111111511111000000000524444500097000000606000004000075ffff5700007570715555577555ff5708133b8008133b80
000770001d66666511100000111000000000000049a000000d24444d04a09a000007e70000004770751ff15709075700715555577555f15781e3e3b8811e3eb8
000770001d66666511100000111000000000000040a499aa062444464909a0a700688e7000007ff707cccc700795700007ddcc7007dddc70813333b8811333b8
0070070011d6d6651110000011100000000000009a70090709a4444611111111062888e600007ff707cccc707f99000007dddc7007dddc7088b33b8888113388
00000000111d1d65111000001110000000000000111111110d2444ad011111000d22888600000774074442707ff7900007224e70074222700088880000888800
000000001111111d11100000111000000000000001110011052449070011000011ddd66000000000007777000770000000777700007777000000000000000000
00000000011111100000080000777000000000000000000009a44495000000000000000000000000061671700000000000000000000000000000000000000000
000000001000000100280000066666000800000000000000052244450008e000000000000000000007777d700000000000000000000000000088880000000000
00000000100000010228800807060700000008e00000000005222445000970000000000000000000000077700000000000000000000000000811138000000000
0000000010000001228888000070700000000000111000000111111100900700000000000000000000000000000000000000000000000000811133b800000000
0000000010000001288888800076700000800000101111110011111000400a00000000000000000000000000000000000000000000000000811333b800000000
000000001000000128888800111110000000000011100101001111100014900000000000000000000000000000000000000000000000000088133b8800000000
00000000100000010228800001110000800028000000000000011100010110000000000000000000000000000000000000000000000000000088880000000000
00000000011111100000002000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000200000000000000000000000000000000000000000000000000000000000087778000000022008777800087778000000000000000000
0000000000000000000f4f0000000000000000000000000003000000000000000000000000000000876777800000262087dd6780876678000000000000cc0000
000000000000060000060600005d50000000010110100000000003b000000000000000000000000087e6e7800002620087d667808766e780000000000c66c000
0000000000000770000767000d56d5000000101001010000000000000000000000c00c000000008808707800d026200008d668000877678000cc0000c6006c00
00000000000070000065bb70556dd650000101011010100000300000000000000007700000000876007770008d52000000777000008778000c60000070000060
0000000000070000063bbbb601111110000010d00d010000000000000000000000c00c00000008670086800076500000008680000086800007000000000000c0
00000000066000000d33bbb6000111100001010dd010100030003b00000000000000000000000088007770006785000000677000008770000000000000000006
000000000070000011ddd66000000000001010dddd01010000000000000000000000000000000000008680008800000000868000008680000000000000000000
0000000000555000000d000000000000001010dddd010100dddddddd0000000000000000c000000c005060000000760000700000000000000000000000000000
00000000051115000060d000000005500001010dd0101000d1ddddd10000000000000000070000600060700000000c60000c0000000000000000000000000000
00000000025554000d00060000004500000010d00d0100000d1d1d1d010001000c0000c00000000000007000000000c00006c000000000000000000000000000
0000000002444d0000d0506000042200000101011010100010d0d0d0000000000000600000000000000000000000000000006c00000000000000000000000000
0000000005d664000600050000020000000010100101000001010101010000000070070000000000000000000000000000006c000000600000006c0000000000
0000000002444400506000000040000000000101101000001010101000000000000600000000000000000000000000000006c00000000c00000000c000000000
00000000024442000500000004000000000000000000000001010100010101000c0000c0060000700000000000000000006c00000000c0000000000700000000
0000000000222000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000700000000000000000000
000000000888888008888880000888000000000000000a0a00000000000000000000000000000000001110000000000000000000000000000000000000000000
00000000814444188144441800821180000000a00000000000011110000000000000000000000000001610000000000000000000000000000000000000000000
0008800084544548822442280824454800089a0000089a0a00016610111111100011000011111111111610000000000000000000000000000000000000000000
0084480084e44e4882222228084444e8008499000084990001161610161161611166100166166116611611100000000000000000000000000000000000000000
00844800082222800822228008222228008448000084480011611111161616161611611611116161161616110000000000000000000000000000000000000000
00088000082224800822248008224480000880000008800016111161161616161611116111666161111661610000000000000000000000000000000000000000
00000000082244800822448008222480000000000000000016111116161616161611116116116116111611610000000000000000000000000000000000000000
00000000008888000088880000888800000000000000000016166616161616161611616116116111611611610000000000000000000000000000000000000000
00000000002002000000000000000000000000000000000016111611611110161166116111661111161611610000000000000000000000000000000000000000
00000000000004000000000000000000000000000000000011666116110000161111111111111111161111110000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000001111116100000161000001111111166610000000000000000000000000000000000000000000000
000c0000000000000000000000000000000000000000000000016661100000161000001666666611110000000000000000000000000000000000000000000000
00c7c000000000000000000000000000000000000000000000011111000000111000000111111100000000000000000000000000000000000000000000000000
000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000008888888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0000000000000000000008888222222222288888888888000000000000000000000000000000000000000000000000000000000000000000000000000000
0c000c00000000000000000888222000000000022222222228888000000000000000000000000000000000000000000000000000000000000000000000000000
00060000000000000000888820000000000000000000000002228880000000000000000000000000000000000000000000000000000000000000000000000000
0c000c00666100006665520610000066666666556666666556666618000066661000666666666106666100660000000000000000000000000000000000000000
000c0000666100066610000661000061000610006610006106610066800661006610006610006610066610060000000000000000000000000000000000000000
00000000616610666610006161000000006600006610610006610066686610000661006610006610061661060000000000000000000000000000000000000000
00000000717718707710007177100000071000007777710007777710287710000771007777771000071077170000000000000000000000000000000000000000
000c0000618666116610066666100000661006106610616106610061026610000661006610610000061006660000000000000000000000000000000000000000
c00000c8712071117710760007710007710007107710007107710077100771007710007710077600071000770000000000000000000000000000000000000000
05000508666161666655666666661066666666556666666556666661000066666100666661006655666100060000000000000000000000000000000000000000
00000002000000000000000000000000000000000000000000000000000000028880000000000000000000080000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002288880000000000000088820000000000000000000000000000000000000000
05000500000000000000000000000000000000000000000000000000000000000222288888888888888882220000000000000000000000000000000000000000
c00000c0000000000000000000000000000000000000000000000000000000000000222222222222222222000000000000000000000000000000000000000000
000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010101010101010000010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010101010101010100000101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010101010101010001000101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010101010101010001000101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010101010101010000000101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01070000246242862528604266042d700307000c00503005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c3230e3232740324403244030c4031040311403134030370703707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011b00000a6141b503196030160600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028002
0110000026435294351d4020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002855526555245551940400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002855524555305552d55518704187040c70400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00001151313513155130b51307513000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300000071300703107041550700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000e5421054218542185421d700187020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300000c73111731137311573115731000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000472605726027060470605706070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000180550c00318005180550c0030c003180550c0030c003180550c0030c0032405518003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0114000002022240021c0020202207002030020202200002020020202202002000020202202002000020202204002010020202200002070020202200002000020202200002000020202207002000020202200002
0110000004051050510505118051180510c0510c05105051050510005100051000510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000d7550f7550e755107550e7551175510604000050d7550f7550e755107550e755117550c705105050d7550d7550f7550f7550e7550e7550e755000050d7550d7550f7550f7550e7550e7550e75500005
011600000e5520c5020d552105020e5520d5520d5020e5520d552105521155213552135521550200502005020e5520d5020d552005020e5520d552005020e5520d55210552115520c5520c552005020050200502
011600000d5531750315503135030d5530c503000030d5030d5531450300003000030e5030000300003000030d5530000300003000030d5530000300003000030d5530000300003000030c503000030000300003
011600001a0211a021190001902119021190001a0211a021000001902119021000001a0211a0211a000190001a0211a0211a0001902119021190001a0211a0211a0001902119021190001802118021180001d000
011000000e72300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
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
03 0e 0c 43 44
01 0f 10 43 44
02 0f 10 11 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
