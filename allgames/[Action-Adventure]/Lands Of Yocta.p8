pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--lands of yocta
--by trasevol_dog

function _init()
 cls()
-- draw_text("l  o  a  d  i  n  g  .  .  .",64,64)
 draw_text("l o a d i n g . . .",64,64)
 flip()
 
 vhei=12

 load_voxeldata()
 
 local midhei=flr(vhei/2)
 lorder={}
 for i=0,vhei-1 do
  local order={}
  for ll=0,i do
   if ll<midhei then
    order[ll]=ll
   else
    order[ll]=i-(ll-midhei)
   end
  end
  lorder[i]=order
 end
 
 cama=0.125
 camva=0
 
 posx=96.5*8
 posy=96.5*8
 vspd=0
 hspd=0
 
 bob=0
 
 t=0
 
 flrs={}
 for i=0,1023 do
  flrs[i]=flr(i/8)
 end
 
 mapw=128
 mapwm=mapw-1
 mapwt=mapw*8
 mapp=make_world()

 init_sky()

 drawdist=4
 hei=vhei/2
 
 shkx,shky=0,0
 
 debug=false

 modtiles={}--not used in this game
 
 lfrelease=1
 lfpress=false
 
 drk={[0]=0,0,1,1,2,1,13,13,2,4,9,3,1,1,2,5}
 light={[0]=1,13,4,11,9,6,7,7,14,10,7,7,7,6,7,7}
 whitescreen=false
 
 monos={{96,32},{32,32},{32,96}}
 monok=1
 monot=0
 monocols={0,1,2,4,9,10,7}
 monocolk=#monocols-1
 
 cubecols={0,1,13,6,7,6,13,1}
 cubecols={0,1,2,4,9,10,7,10,9,4,2,1}
 cubecolk=#cubecols
 
 endtrig=0
 
 flip()
 
 titlescreen=6
 sfx(20)
end

function _update()
 t+=0.01
 --cama+=0.004
 update_shake()
 reset_modtiles()
 gen_sounds()
 
 if titlescreen>0 then
  local dt=t*0.05+0.6
  posx=monox+42*cos(dt)
  posy=monoy+42*sin(dt)
  cama=dt+0.5
 
  if titlescreen>0 and titlescreen<2 or titlescreen>=2.05 then
   local k=flr((2-titlescreen)*5)
   fade(k,drk,true)
   titlescreen-=0.05
   
   if titlescreen>=2.5 and titlescreen<=2.55 then
    add_shake(8)
    sfx(18)
   end
   if titlescreen>=2 and titlescreen<=2.05 then
    add_shake(8)
    sfx(19)
   end
   
   if titlescreen<=0 then
    start_game()
    pal()
   end
  end
 
  if titlescreen>=2 and btnp(4) then
   titlescreen=2-0.05
   add_shake(8)
   sfx(9)
  end
  
  return
 end
 
 if (endtrig>0 and endtrig<53) or (endtrig>=54 and endtrig<91) then
  endtrig+=0.1
 end
 
 if endtrig>0 and btn(4) then
  endtrig+=1
  if endtrig>=54 then
   local rpx,rpy=posx-cabinx,posy-cabiny
   mapp={}
   mapp=make_world()
   posx,posy=cabinx+rpx,cabiny+rpy
   monok=5
   drawdist=40
   
   --remove cube frome table
   for y=2,5 do
    local lin=_vox[y]
    for x=2,5 do
     local clm=lin[x][75]
     for z=5,8 do
      clm[z]=nil
     end
    end
   end
   _vox[2][3][75][5]=6
   _vox[2][3][75][6]=10
  end
 end
 
 update_player()
 
 update_monolith()
 
 foreach(animate,update_animate)
-- foreach(actors,update_actor)
 
 if btnp(4,1) then
  add_shake(4)
  debug=not debug
 end
end

function _draw()
 if whitescreen then
  cls(7)
  whitescreen=false
  return
 end
 
 if endtrig>0 then
  local k=flr(endtrig)
  if endtrig<5 then
   fade(k,light,true)
  elseif endtrig<54 then
   pal()
   
   cls(7)
   camera()
   local strs={
    "hi!",
    "thank you for playing!",
    "this was pretty fun to make",
    "i wrote about it",
    "at trasevol.dog/voxelz",
    "thank you again!",
    "~ trasevol_dog ~",
    "press Ž to continue"
   }
   
   local kk=flr((endtrig-5)/6+1)
   local k=min(#strs,kk)
   local y=64-(#strs-0.5)*7
   for i=1,k do
    if i==kk then
     local kk=max(4-(endtrig-5)%6*2,0)
     fade(kk,light)
    end
    
    draw_text(strs[i],64,y)
    y+=14
   end
   
   return
  elseif endtrig<59 then
   local k=4-flr(endtrig-53)
   fade(k,light,true)
  else
   pal()
   endtrig=0
  end
 end

 do
  local y=hei/vhei*128+shky
  cls()
  rectfill(0,y,127,y,1)
 end

 draw_sky()

 camera(shkx,shky-4)
 draw_voxel(drawdist,hei)
 
-- if titlescreen>0 and titlescreen<=4.5 then
--  for y=32,79 do
--   fade(flr(-y/8-t/0.1)%5,light)
--   for x=48,79 do
--    pset(x,y,pget(x,y))
--   end
--  end
--  
--  for c=0,15 do
--   pal(c,c)
--  end
-- end
 
 if titlescreen>0 and titlescreen<=3 then
  if titlescreen>=2.05 then
   local dt=titlescreen-2
   local y=-max(dt-0.5,0)*128
   fade(flr(dt*7),drk)
      pal(1,0)
   pal(13,1)
   spr(128,0,y,16,8)
   for i=0,15 do
    pal(i,i)
   end
  else
   pal(1,0)
   --pal(13,1)
   spr(128,0,0,16,8)
   pal(1,1)
   --pal(13,13)
   
   draw_text("trasevol_dog presents",64,1,1,0,true)
   
   draw_text("z/Ž x/—:   ",70,70,2,0,true)
   draw_text("”‹‘ƒ:     ",70,79,2,0,true)
   draw_text("”+”:   ",70,88,2,0,true)
   
   draw_text("rotate",70,70,0,2,true)
   draw_text("walk",70,79,0,2,true)
   draw_text("run",70,88,0,2,true)
   
   if t%0.4<0.3 then
    draw_text("press z/Ž to start",64,112,1,0,true)
   end
  end
 end
 
 camera()
 if titlescreen<=0 then
  draw_compass(64,5,96)
 end
 
 if stat(1)<0.91 then
  drawdist+=1
 elseif stat(1)>0.95 then
  drawdist-=3
 elseif stat(1)>0.95 then
  drawdist-=1
 end
 
 if debug or btn(4,1) then
  rectfill(0,0,48,24,0)
  local y=1
  print("cpu:"..flr(stat(1)*100).."%",1,y,7) y+=8
  print("draw dist:"..drawdist,1,y,7) y+=8
  print("memory:"..flr(stat(0)/1024*100).."%",1,y,7) y+=8
 end
end



function update_player()
 camacc=0.2
 
 if endtrig==0 then
  if btn(4) then camva+=camacc end
  if btn(5) then camva-=camacc end
 end
 
 cama+=camva*0.01
 
 camva*=0.8
 
 if abs(camva)<0.05 then
  camva=0
 end
 
 local acc=0.04
 local facc
 if lfrelease<0.1 then
  facc=acc*2.5
 else
  facc=acc
 end
 
 if endtrig==0 then
  if btn(0) then hspd+=acc*1.5 end
  if btn(1) then hspd-=acc*1.5 end
  if btn(2) then vspd+=facc end
  if btn(3) then vspd-=acc end
 end
 
 if lfpress and not btn(2) then
  lfrelease=0.05
 elseif btn(2) and lfrelease<0.1 then
  lfrelease=0.08
 end
 lfpress=btn(2)

 lfrelease+=0.01
 
 nposx=posx+vspd*cos(cama)+hspd*cos(cama+0.25)
 nposy=posy+vspd*sin(cama)+hspd*sin(cama+0.25)
 
 --local ti=mapp[flrs[flr(nposx)%mapwt]][flrs[flr(nposy)%mapwt]]
 local ti=mapp[flr(nposy/8)%mapw][flr(nposx/8)%mapw]
 if walls[ti] then
  local tix=mapp[flr(posy/8)%mapw][flr(nposx/8)%mapw]
  
  if walls[tix] then
   nposx=posx
  end
  
  local tiy=mapp[flr(nposy/8)%mapw][flr(posx/8)%mapw]
  
  if walls[tiy] then
   nposy=posy
  end
 end
 
 posx=nposx
 posy=nposy
 
 vspd*=0.9
 hspd*=0.7
 
 if monok==4 and endtrig==0 and ti==74 then
  endtrig+=0.1
 end
 
 if abs(vspd)>0.05 or abs(hspd)>0.05 then
  bob=lerp(bob,2*cos(t*6),0.2)
  if bob<=-1.005 then
   if abs(vspd)>0.5 then
    sfx(14+flr(rnd(4)),3)
   else
    sfx(10+flr(rnd(4)),3)
   end
  end
  
  if bob>=1.005 and abs(vspd)>0.5 then
   sfx(14+flr(rnd(4)),3)
  end
 else
  bob=lerp(bob,0,0.2)
 end
end

function update_monolith()
 if monok==4 then
  local lit=flr(monot/0.02)
  local plit=max(lit-monocolk,0)
  
  for y=2,5 do
   local lin=_vox[y]
   for x=0,7 do
    local clm=lin[x][76]
    for zz=plit,lit do
     local z=zz%12
     local c=monocols[zz-plit+1]
     if clm[z] then
      clm[z]=c
     end
    end
   end
  end
 
  --put cube on table!!
  
  for y=2,5 do
   local lin=_vox[y]
   for x=2,5 do
    local clm=lin[x][75]
    local c=x+y+flr(monot/0.02)
    for z=5,8 do
     local c=(c+z)%cubecolk+1
     clm[z]=cubecols[c]
    end
   end
  end
 
  monot+=0.01
  return
 elseif monok>4 then
  return
 end

 local monod=sqrdist((posx-monox)*0.1,(posy-monoy)*0.1)
-- abs(posx-monox)+abs(posy-monoy)
 if monod<sqr(1.0) then
  whitescreen=true
  add_shake(32)
  sfx(9)
  
  if monok<3 then
   local x,y=monos[monok][1],monos[monok][2]
   
   for xx=-3,3 do
    local k=3-abs(xx)
    for yy=-k,k do
     if abs(yy)==k then
      mapp[y+yy][x+xx]=0
     else
      mapp[y+yy][x+xx]=flr(88+rnd(8))
     end
    end
   end
   
   monok+=1
   monox,monoy=monos[monok][1],monos[monok][2]
   mapp[monoy][monox]=76
   mapp[monoy-1][monox]=0
   mapp[monoy+1][monox]=0
   mapp[monoy][monox-1]=0
   mapp[monoy][monox+1]=0
   monox=monox*8+4
   monoy=monoy*8+4
  else
   for y=0,127 do
    local lin=mapp[y]
    for x=0,127 do
     local ti=lin[x]
     if ti<64 or ti>76 then
      local mx,my=flr(monox/8),flr(monoy/8)
      if (x-mx)%3<1 and (y-my)%3<1 then
       lin[x]=76
      else
       lin[x]=0
      end
     end
    end
   end
   animate={}
   
   for y=2,5 do
    local lin=_vox[y]
    for x=0,7 do
     local clm=lin[x][76]
     for z=0,11 do
      if clm[z] then
       clm[z]=5
      end
     end
    end
   end
   
   monok+=1
  end
 elseif monod<sqr(1.6) then
  add_shake(2)
  if rnd(4)<1 then sfx(0) end
 elseif monod<sqr(2.4) then
  add_shake(1)
  if rnd(8)<1 then sfx(0) end
 elseif monod<sqr(4.8) and rnd(8)<1 then
  add_shake(1)
  if rnd(2)<1 then sfx(0) end
 end
 
end

function update_actor(e)
 e.t+=0.01
 
 e.x=lerp(e.x,posx+32*cos(e.t/4),0.1)
 e.y=lerp(e.y,posy+32*sin(e.t/4),0.1)
 
 --put into the voxel data
 
 local dx,dy=flr(e.x-4)%mapwt,flr(e.y-4)%mapwt
 local tix=flrs[dx]
 local tiy=flrs[dy]
 dx-=tix*8
 dy-=tiy*8
 
 vox_actor_in_tile(tt,tix,tiy,dx,dy,7,7,-dx,-dy)
 vox_actor_in_tile(tt,tix+1,tiy,0,dy,dx-1,7,8-dx,-dy)
 vox_actor_in_tile(tt,tix,tiy+1,dx,0,7,dy-1,-dx,8-dy)
 vox_actor_in_tile(tt,tix+1,tiy+1,0,0,dx-1,dy-1,8-dx,8-dy)
end

function vox_actor_in_tile(en,tix,tiy,x1,y1,x2,y2,sx,sy)
 tix,tiy=tix%mapw,tiy%mapw
 local oid=mapp[tiy][tix]
 
 if oid<32 then
  local nid=newvoxidx
  
  for y=y1,y2 do
   local lin=_vox[y]
   local linh=_voxh[y]
   local elin=_actorvox[y+sy]
   local elinh=_actorvoxh[y+sy]
   
   for x=x1,x2 do
    local clm={}
    local oclm=lin[x][oid]
    local eclm=elin[x+sx][en]
    local mh=max(linh[x][oid],elinh[x+sx][en])
    
    for z=0,mh do
     clm[z]=eclm[z] or oclm[z]
    end
    
    lin[x][nid]=clm
    linh[x][nid]=mh
   end
   
   for x=0,x1-1 do
    local mh=linh[x][oid]
    local clm={}
    local oclm=lin[x][oid]
    for z=0,mh do
     clm[z]=oclm[z]
    end
    lin[x][nid]=clm
    linh[x][nid]=mh
   end
   
   for x=x2+1,7 do
    local mh=linh[x][oid]
    local clm={}
    local oclm=lin[x][oid]
    for z=0,mh do
     clm[z]=oclm[z]
    end
    lin[x][nid]=clm
    linh[x][nid]=mh
   end
  end
  
  for y=0,y1-1 do
   local lin=_vox[y]
   local linh=_voxh[y]
   for x=0,7 do
    local mh=linh[x][oid]
    local clm={}
    local oclm=lin[x][oid]
    for z=0,mh do
     clm[z]=oclm[z]
    end
    lin[x][nid]=clm
    linh[x][nid]=mh
   end
  end
  
  for y=y2+1,7 do
   local lin=_vox[y]
   local linh=_voxh[y]
   for x=0,7 do
    local mh=linh[x][oid]
    local clm={}
    local oclm=lin[x][oid]
    for z=0,mh do
     clm[z]=oclm[z]
    end
    lin[x][nid]=clm
    linh[x][nid]=mh
   end
  end
  
  add(modtiles,{tiy,tix,oid})
  mapp[tiy][tix]=nid
  newvoxidx+=1
 else
  for y=y1,y2 do
   local lin=_vox[y]
   local linh=_voxh[y]
   local elin=_actorvox[y+sy]
   local elinh=_actorvoxh[y+sy]
   for x=x1,x2 do
    local clm=lin[x][oid]
    local eclm=elin[x+sx][en]
    local emh=elinh[x+sx][en]
    
    for z=0,emh do
     clm[z]=eclm[z] or clm[z]
    end
    
    linh[x][oid]=max(linh[x][oid],emh)
   end
  end
 end
 
end

function reset_modtiles()
 for inf in all(modtiles) do
  mapp[inf[1]][inf[2]]=inf[3]
 end
 modtiles={}
 newvoxidx=32
end

function update_animate(ti)
 ti.t+=0.01
 
 if ti.t%0.16<0.01 then
  mapp[ti.tiy][ti.tix]=ti.b+flr(ti.t/0.16)%4
 end
end

function update_shake()
 if abs(shkx)+abs(shky)<0.5 then
  shkx,shky=0,0
 end
 
 shkx*=-0.5-rnd(0.2)
 shky*=-0.5-rnd(0.2)
end

function add_shake(p)
 local a=rnd(1)
 shkx+=p*cos(a)
 shky+=p*sin(a)
end

function gen_sounds()
 if monok==4 then
  return
 end

 if (posx<64*8 and posy>64*8) or (posx>64*8 and posy<64*8) then
  if chance(0.2) and stat(16)==-1 then
   sfx(flr(rnd(3))+1,0)
  end
 end
 
 if posx>64*8 or posy<64*8 then
  if chance(0.2) and stat(17)==-1 then
   sfx(flr(rnd(5))+4,1)
  end
 end
end


function draw_compass(x,y,w)
 do
  local x=x-w/2
  local y=y-3
  rect(x-1,y-1,x+w+1,y+8,0)
  rect(x,y,x+w,y+6,7)
  rectfill(x,y+7,x+w,y+7,13)
  x+=1
  y+=1
  rectfill(x,y,x+w-2,y+4,0)
 end
 
 local letters={'e','n','w','s'}
 for i=0,7 do
  local a=angle_diff(cama,i/8)
  a*=-w*4

  if abs(a)<w/2-2 then
   if i%2<1 then
    print(letters[i/2+1],x+a-2,y-2,13)
   else
    rectfill(x+a,y-1,x+a,y+1,13)
   end
  end
 end
 
 local a=angle_diff(cama,atan2(cabinx-posx,cabiny-posy))
 a*=-w*4
 a=mid(a,-w/2,w/2)

 draw_text("Š",x+a-3,y+1,1,0,true)
 
 if monok<=3 then
  local a=angle_diff(cama,atan2(monox-posx,monoy-posy))
  a*=-w*4
  a=mid(a,-w/2,w/2)
 
  draw_text("€",x+a-3,y+1,1,0,true)
 end

end

function draw_voxel(l,hei)
 local da=0.07
 local x0,y0=round(posx),round(posy)
 local x1=round(posx+l*cos(cama-da))
 local y1=round(posy+l*sin(cama-da))
 local x2=round(posx+l*cos(cama))
 local y2=round(posy+l*sin(cama))
 local x3=round(posx+l*cos(cama+da))
 local y3=round(posy+l*sin(cama+da))
 
 local pts={{x0,y0},{x1,y1},{x2,y2},{x3,y3}}
 
 local lxs,rxs,npts,may,miy={},{},#pts,pts[1][2],pts[1][2]
 
 for i=1,npts do
  local pa,pb=pts[i],pts[i%npts+1]
  if pa[2]>pb[2] then
   for y=pb[2],pa[2] do
    rxs[y]=round(lerp(pb[1],pa[1],(y-pb[2])/(pa[2]-pb[2])))
   end
  elseif pa[2]<pb[2] then
   for y=pa[2],pb[2] do
    lxs[y]=round(lerp(pa[1],pb[1],(y-pa[2])/(pb[2]-pa[2])))
   end
  end
  
  may=max(may,pa[2])
  miy=min(miy,pa[2])
 end
 
 may,miy=round(may),round(miy)
 
 local ocx=cos(cama-0.25)
 local osx=-sin(cama-0.25)
 local ocy=cos(cama)
 local osy=-sin(cama)

 local ystart,yend,ypace
-- if cama%1>=0.25 and cama%1<0.75 then
 if cama%1>=0.5 then
  ystarta,yenda,ypacea=may,max(miy,posy),-1
  ystartb,yendb,ypaceb=miy,min(may,posy),1
 else
  ystarta,yenda,ypacea=miy,min(may,posy),1
  ystartb,yendb,ypaceb=may,max(miy,posy),-1
 end
 
 local xstart,xend,xpace
-- if cama%1>0.5 then
 if cama%1<0.25 or cama%1>=0.75 then
  xstart,xend,xpace=2,1,-1
 else
  xstart,xend,xpace=1,2,1
 end
 
 pal(5,0)
 
 local hvhei=vhei*0.5
 for yy=ystarta,yenda,ypacea do
  local ty=yy%8
  local lin=_vox[ty]
  local linh=_voxh[ty]
  local fy=mapp[flrs[yy%mapwt]]
  local cy=yy-posy
  local cyocy=cy*ocy
  local cyosy=cy*osy

  local xorder={lxs[yy],rxs[yy]}

  for xx=xorder[xstart],xorder[xend],xpace do
   local cx=xx-posx
   local d=(cx*osx+cyosy)
   
   if d<=-3 then
    local ti=fy[flrs[xx%mapwt]]
    local tx=xx%8
    local clm=lin[tx][ti]
    local mh=linh[tx][ti]
   
    local x=3.99*(cx*ocx+cyocy)
    local sca=-(1/d*.7)*48
    local w=2.5*sca
    x=x*sca+64
    
    local order=lorder[mh]
    local drawfoo=_drawfoo[ti]
    
    for ll=0,mh do
     local l=order[ll]
     local c=clm[l]
     
     if c then
      local y=(-4*(l-hvhei))*sca+8*hei+bob+4
      
      --if d<-drawdist+6 then
      -- _drawfoo[ti](x,y,w,drk[c])
      -- 
      --else
       drawfoo(x,y,w,c)
      --end
     end
    end
   end
  end
 end
 
 for yy=ystartb,yendb,ypaceb do
  local ty=yy%8
  local lin=_vox[ty]
  local linh=_voxh[ty]
  local fy=mapp[flrs[yy%mapwt]]
  local cy=yy-posy
  local cyocy=cy*ocy
  local cyosy=cy*osy

  local xorder={lxs[yy],rxs[yy]}

  for xx=xorder[xstart],xorder[xend],xpace do
   local cx=xx-posx
   local d=(cx*osx+cyosy)
   
   if d<=-3 then
    local ti=fy[flrs[xx%mapwt]]
    local tx=xx%8
    local clm=lin[tx][ti]
    local mh=linh[tx][ti]
   
    local x=3.99*(cx*ocx+cyocy)
    local sca=-(1/d*.7)*48
    local w=2.5*sca
    x=x*sca+64
    
    local order=lorder[mh]
    local drawfoo=_drawfoo[ti]
    
    for ll=0,mh do
     local l=order[ll]
     local c=clm[l]
     
     if c then
      local y=(-4*(l-hvhei))*sca+8*hei+bob+4
      
      --if d<-drawdist+6 then
      -- _drawfoo[ti](x,y,w,drk[c])
      --else
       drawfoo(x,y,w,c)
      --end

     end
    end
   end
  end
 end
 
end

function square(x,y,hw,c)
 rectfill(x-hw,y-hw,x+hw,y+hw,c)
end

function circle(x,y,r,c)
 circfill(x,y,r+1,c)
end

function draw_sky()
 for s in all(stars) do
  local x=angle_diff(cama,s.x)
  if abs(x)<0.13 then
   x=64-x*8*127
   spr(s.s,x-4,s.y-4)
  end
 end
 
 local ma=angle_diff(cama,moonx)
 if abs(ma)<0.13 then
  ma=64-ma*8*127
  pal(1,0)
  spr(10,ma-8,moony-8,2,2)
  pal(1,1)
 end
end

function draw_text(str,x,y,al,c,extra)
 local c=c or 0
 local al=al or 1
 if al==1 then x-=#str*2
 elseif al==2 then x-=#str*4 end
 
 y-=3
 
 if extra then
  print(str,x,y-2,0)
  print(str,x-1,y-1,0)
  print(str,x+1,y-1,0)
  print(str,x-2,y,0)
  print(str,x+2,y,0)
  print(str,x-2,y+1,0)
  print(str,x+2,y+1,0)
  print(str,x-1,y+2,0)
  print(str,x+1,y+2,0)
  print(str,x,y+3,0)
 end
 
 print(str,x-1,y+1,13)
 print(str,x+1,y+1,13)
 print(str,x,y+2,13)

 print(str,x-1,y,7)
 print(str,x+1,y,7)
 print(str,x,y-1,7)
 print(str,x,y+1,7)
 
 print(str,x,y,c)
end

function fade(k,refplt,scrn)
 local scrn=scrn and 1 or 0

 for c=0,15 do
  local cc=c
  for i=1,k do
   cc=refplt[cc]
  end
  pal(c,cc,scrn)
 end
end


function create_actor(x,y)
 local e={
  x=x,
  y=y,
  z=0,
  t=0
 }

 add(actors,e)
end

function create_animate(tix,tiy,tib)
 local ti={
  tix=tix,
  tiy=tiy,
  b=tib,
  t=rnd(1)
 }
 
 add(animate,ti)
end


function start_game()
 cama=0.125
 camva=0
 
 posx=96.5*8
 posy=96.5*8
 vspd=0
 hspd=0
 
 bob=0
 
 t=0
 
 drawdist=4
end

function make_world()
 local map={}
 for y=0,mapw-1 do
  map[y]={}
 end
 
 
 for y=0,63 do --garden
  for x=64,127 do
   local ti
   if chance(3) then
    ti=77+rnd(2)
   elseif chance(6) then
    ti=16+rnd(4)
   elseif chance(15) then
    ti=5+rnd(11)
   elseif chance(75) then
    ti=rnd(5)
   else
    ti=0
   end
   
   map[y][x]=flr(ti)
  end
 end 
 
 for y=64,127 do --stony
  for x=0,63 do
   local ti
   if chance(10) then
    ti=92+rnd(12)
   elseif chance(3) then
    ti=84+rnd(4)
   elseif chance(3) then
    ti=16+rnd(8)
   elseif chance(2) then
    ti=5+rnd(11)
   elseif chance(10) then
    ti=rnd(5)
   elseif chance(30) then
    ti=88+rnd(4)
   else
    ti=0
   end
   
   map[y][x]=flr(ti)
  end
 end
 
 for y=64,127 do --swamps
  for x=64,127 do
   local ti
   if chance(15) then
    ti=104+rnd(8)
   elseif chance(25) then
    ti=80+rnd(4)
   elseif chance(20) then
    ti=16+rnd(8)
   elseif chance(75) then
    ti=1+rnd(5)
   else
    ti=0
   end
   map[y][x]=flr(ti)
  end
 end 
 
 for y=0,63 do --forest
  for x=0,63 do
   local ti
   if (x+y)%2==0 and chance(50) or chance(10) then
    ti=77+rnd(3)
   elseif chance(10) then
    ti=5+rnd(11)
   elseif chance(2) then
    ti=80+rnd(4)
   elseif chance(1) then
    ti=104+rnd(8)
   elseif chance(75) then
    ti=1+rnd(5)
   else
    ti=0
   end
   map[y][x]=flr(ti)
  end
 end
 
 --cabin
 repeat
 cabinx,cabiny=flr(rnd(3))+10.5,flr(rnd(3))+2.5
 until (cabinx~=11.5 or cabiny~=3.5)
 for x=0,2 do
 for y=0,3 do
  map[cabiny*8+2+y][cabinx*8+2+x]=sget(x,16+y)+64
 end
 end
 
 map[cabiny*8+6][cabinx*8+3]=0
 
 --water
 local wp={{3,3},{3,11},{11,3},{11,11},{cabinx-0.5,cabiny-0.5}}
 for i=0,23 do
  local x,y,b
  repeat
   x,y=flr(rnd(15)),flr(rnd(15))
   b=true
   for p in all(wp) do
    if x==p[1] and y==p[2] then
     b=false
     break
    end
   end
  until b
  
  add(wp,{x,y})
  
  local k=flr(rnd(5))+1
  
  local sx,sy=k*8,16
  local dx,dy=x*8+4,y*8+4
  
  for xx=0,7 do
  for yy=0,7 do
   local ti=sget(sx+xx,sy+yy)
   if ti>0 then
    ti=(ti-1)*4+24
    map[dy+yy][dx+xx]=ti
   end
  end
  end
 end
 
 animate={}
 for y=0,mapwm do
  local lin=map[y]
  for x=0,mapwm do
   local ti=lin[x]
   
   if ti>=24 and ti<64 then
    create_animate(x,y,ti)
   end
  end
 end
 
 cabinx*=8 cabinx+=3.5 cabinx*=8
 cabiny*=8 cabiny+=3.5 cabiny*=8
 
 --walls
 map[0][0]=112
 map[127][0]=113
 map[127][127]=114
 map[0][127]=115
 
 for i=1,126 do
  map[i][0]=116
  map[127][i]=117
  map[i][127]=118
  map[0][i]=119
 end
 
 --monolith
 if not monok then
  monox,monoy,monok=96,32,1
  map[monoy][monox]=76
  map[monoy-1][monox]=0
  map[monoy+1][monox]=0
  map[monoy][monox-1]=0
  map[monoy][monox+1]=0
  monox=monox*8+4
  monoy=monoy*8+4
 end
 
 --spawn
 for x=95,97 do
 for y=95,97 do
  map[y][x]=flr(rnd(4))
 end
 end
 map[96][96]=0
 
 return map
end

function init_sky()
 stars={}
 for i=0,149 do
  local s={
   x=rnd(512),
   y=8+rnd(32),
   s=rnd(4)<3 and flr(rnd(3)) or flr(rnd(7))
  }
  add(stars,s)
 end
 moonx=0.14*512
 moony=20
 
 for i=0,1 do
  for s in all(stars) do
   for s2 in all(stars) do
    if s~=s2 then
     local d=sqrdist((s.x-s2.x)*.01,(s.y-s2.y)*.01)
     if ((s.s>3 or s2.s>3) and d<0.08) or d<0.03 then
      local a=atan2(s.x-s2.x,s.y-s2.y)
      s.x+=.5*cos(a)
      s.y+=.5*sin(a)
      s2.x-=.5*cos(a)
      s2.y-=.5*sin(a)
     end
    end
   end
   
   local d=sqrdist((s.x-moonx)*.01,(s.y-moony)*.01)
   if d<0.12 then
    local a=atan2(s.x-moonx,s.y-moony)
    s.x+=4*cos(a)
    s.y+=4*sin(a)
   end
  end
 end
 
 for s in all(stars) do
  s.x=flr(s.x%512)/512
  s.y=flr(s.y)
 end
 moonx=0.14
end


function gif_loop()
 drawdist=48
 posx=31.5*8+24*cos(t*0.3)
 posy=31.5*8+24*sin(t*0.3)
 cama=t*0.3+0.5
 _update()
 _draw()
 flip()
 extcmd("rec")
 for i=0,332 do
  posx=31.5*8+24*cos(t*0.3)
  posy=31.5*8+24*sin(t*0.3)
  cama=t*0.3+0.5
  _update()
  _draw()
  flip()
 end
 extcmd("video")
end

function load_voxeldata()
 local newwalls={}
 for ti in all(walls) do
  newwalls[ti]=true
 end
 walls=newwalls

 decompress_spsh(voxset1)
 _vox,_voxh=load_voxtiles(4,64,0)
 decompress_spsh(voxset2)
 _vox,_voxh=load_voxtiles(12,16,64,_vox,_voxh)
 decompress_spsh(voxset3)
 _vox,_voxh=load_voxtiles(8,32,80,_vox,_voxh)
 decompress_spsh(voxset4)
 _vox,_voxh=load_voxtiles(12,8,112,_vox,_voxh)
 
 voxset1=nil
 voxset2=nil
 voxset3=nil
 voxset4=nil
 
-- decompress_spsh(enemdata)
-- --_actorvox,_actorvoxh=load_voxtiles(8,8,8,16)
-- _actorvox,_actorvoxh=load_voxtiles(8,16,0)
-- actordata=nil
 
 _drawfoo={}
 for ti in all(circles) do
  _drawfoo[ti]=circle
 end
 for i=0,#_vox[0][0] do
  if not _drawfoo[i] then
   _drawfoo[i]=square
  end
 end
 circles=nil
 
 reload(0x0,0x0,0x2000)
end

function load_voxtiles(hei,num,start,vox,voxh)
 local vox=vox or {}
 local voxh=voxh or {}
 
 local pdy,pdx
 if hei<=4 then
  pdy=0.25
  pdx=4
 elseif hei<=8 then
  pdy=0.5
  pdx=8
 else
  pdy=1
  pdx=0
 end
 
 for y=0,7 do
  local lin=vox[y] or {}
  local linh=voxh[y] or {}
  for x=0,7 do
   local clm=lin[x] or {}
   local clmh=linh[x] or {}
   for p=0,num-1 do
    local poss=clm[start+p] or {}
    local py=flr(p*pdy)*8
    local px=flr(p*pdx)%16*8
    local mh=-1
    for z=0,hei-1 do
     local c=sget(px+z*8+x,py+y)
     
     if c>0 then
      poss[z]=c
      mh=z
     end
    end
    
    clm[start+p]=poss
    clmh[start+p]=mh
   end
   lin[x]=clm
   linh[x]=clmh
  end
  vox[y]=lin
  voxh[y]=linh
 end
 
 return vox,voxh
end

function vget(x,y,z)
 return _vox[z][y][x]
end

function vset(x,y,z,c)
 _vox[z][y][x]=c
end


function angle_diff(a1,a2)
 local a=a2-a1
 return (a+0.5)%1-0.5
end



dec2hex={[0]='0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
hex2dec={["0"]=0,["1"]=1,["2"]=2,["3"]=3,["4"]=4,["5"]=5,["6"]=6,["7"]=7,["8"]=8,["9"]=9,["a"]=10,["b"]=11,["c"]=12,["d"]=13,["e"]=14,["f"]=15}

function compress_spsh()
 local str=""
 local l=-1
 local c=sget(0,0)

 for y=0,127 do
 for x=0,127 do
  local cc=sget(x,y)
  if c~=cc or l==15 then
   str=str..dec2hex[c]..dec2hex[l]
   c=cc
   l=0
  else
   l+=1
  end
 end
 end
 str=str..dec2hex[c]..dec2hex[l]

 return str
end

function decompress_spsh(str,toscreen)
 local hline
 if toscreen then
  hline=function(cur,l,c)
    local x1,y1=cur%128,flr(cur/128)
    cur+=l
    local x2,y2=cur%128,flr(cur/128)
    if y1==y2 then
     rectfill(x1,y1,x2,y1,c)
    else
     rectfill(x1,y1,127,y1,c)
     rectfill(0,y2,x2,y2,c)
    end
   end
 else
  hline=function(cur,l,c)
    for i=cur,cur+l-1 do
     sset(i%128,i/128,c)
    end
   end
 end
 
 local cur=0
 local k=#str
 for lin=1,k,2 do
  local c=hex2dec[sub(str,lin,lin)]
  local l=hex2dec[sub(str,lin+1,lin+1)]+1
  
  hline(cur,l,c)
  cur+=l
 end
end

function chance(a) return rnd(100)<a end
function pick(ar) return ar[flr(rnd(#ar))+1] end
function sqrdist(x,y) return sqr(x)+sqr(y) end
function sqr(a) return a*a end
function ceil(a) return flr(a+0x.ffff) end
function round(a) return flr(a+0.5) end
function lerp(a,b,i) return (1-i)*a+i*b end


voxset1="0f0f0f0f0f0f0f0f0f0f00100f0f02100f0a100f0f0f0f02100f0a100f0f0f0f0f0f0f0f031006300f0f0f0f0f0f0f0f0f0f0f0f0f03100f0f0f0f0f0f0f0f0f0d100f0f01100f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f091003100f0e1006300f0f0f0310021006300f0f0f0f0f06100f0f00816005800f100210023006b00e100f0f0f0dd005820460810f0f0f03100f0810063001816005800f100080608005800e100f0f0110063006b006b007d0056081048060800f0f0f0f0f0f0f048205800f0f0d1006300f031006300f0f0f081006300f09100f091003100f0e1006300f011004100f0f0f0f09200d100f0f0ac00f031008200f04100630052090200e1000100430008004800f001005c070c002c00f0010052090200f08100420003001200e1000100480003006b006800410063001c002c070c00f07200f03100210052090200f011000100010023000300030028000b000b00480008007100ac00f02100f0b1008200f031000100010023000300080028000b006800210063002c002b00e1006300f0c100f0b1000100430003004b000800480071005c070c00f0f0f011006300f071006800f071008c00f0410063006c00f00100f0e1006300f0f0f05100210023002c002b006c0041004100030043000a004a00f0f0ad001100360066006700f0f0610063006b006a009d006600660067001d0066006600670061003100130033001b003c001c0071002100290023006b006a003d0066006700fd0066006700d10063006c00f0f0f0f0dd0066006700c1006c00f0b10063006a00a1002d0066006700f100f0d1006c00f02100f0f0f0f0f0f10063006c00f001006900f05100f0e100f0f0f0f0f0f0f0f0f0e1204d105600d1303d303630f0f0f0f0a1402d403630462021501d501650263031304d20f031402d40363091402d403630462021501d501650263031303d304620b1403d30462091403d303630461031501d501650263031402d403630561031205d106600f0f0a1501d501650262051303d303630462041106d00f0f0f031303d303630c1204d2046205610f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f021105d105600f011105d106600f0f0f0f0a1105d00f091106d00f0f0f021204d204610f0f0f0f0f001105d10f021204d00f0a1105d105600a1105d105610e1303d303620f0f0e1204d205610911011101d101d1016101610a1204d204620f0f0e1204d205610d1105d105600f0f0e1105d106600f0f0f0f0f0f0d1105d105610b540f0a540f0a540f0a540f0852c30f0852c30f0852c30f0852c30f0751c50f0751c50f0751c50f0751c50f0750c170c30f0750c070c070c20f075070c270c10f0750c60f0750c60f0750c60f0750c60f0750c60f0751c50f0751c50f0751c50f0751c50f0850c50f0850c270c10f0850c170c070c00f0850c070c2700f0751c50f0751c50f0751c50f0751c50f0750c60f0750c60f0750c60f0750c60f0750c60f0750c270c20f0750c170c070c10f0750c070c270c00f0750c60f0750c60f0750c60f0750c60f0751c50f0751c50f0751c50f0751c50f0850c170c070c00f0850c070c2700f0850c50f0850c270c10f0851c40f0851c40f0851c40f0851c40f0951c30f0951c30f0951c30f0951c30f0a540f0a540f0a540f0a540f07c6500f07c6500f07c6500f07c6500f07c6500f07c6500f07c6500f07c6500f07c6500f07c6500f07c6500f07c6500f07c070c270c0500f07c6500f07c270c2500f07c170c070c1500f07c6500f07c6500f07c6500f07c6500f07c5510f07c5510f07c5510f07c5510f0752c0520f0852c0520f0852c0520f0852c0520f085000520f0a5000520f0a5000520f0a5000520f0a5000530f095000530f095000530f095000530f0952c1510f0852c1510f0852c1510f0852c1510f08c5510f07c5510f07c5510f07c5510f07c170c270500f07c6500f07c370c1500f07c270c070c0500f07c6500f07c6500f07c6500f07c6500f07c6500f07c6500f07c6500f07c6500f07c6500f07c170c3500f07c070c070c2500f0770c270c1500f07c6500f07c6500f07c6500f07c6500f0750c60f0750c60f0750c60f0750c60f0751c270c10f0751c170c070c00f0751c070c2700f0751c50f0850c50f0850c50f0850c50f0850c50f0850c50f0850c50f0850c50f0850c50f0850c50f0850c50f0850c50f0850c50f0751c50f0751c50f0751c50f0751c50f0750c60f0750c170c30f0750c070c070c20f075070c270c10f0750c60f0750c60f0750c60f0750c60f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c270c30f07c170c070c20f07c070c270c10f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c270c070c10f07c170c270c00f07c70f07c370c20f07c052c30f07c052c30f07c052c30f07c052c30f075100540f075100540f075100540f075100540f07c5510f07c5510f07c5510f07c5510f07c5500f08c5500f08c5500f08c5500f08c270c1500f08c170c070c0500f08c070c270500f08c5500f08c5500f08c5500f08c5500f08c5500f08c5510f07c5510f07c5510f07c5510f07c6500f07c6500f07c6500f07c6500f07c170c270500f07c6500f07c370c1500f07c270c070c0500f07c6500f07c6500f07c6500f07c6500f075000550f075000550f075000550f075000550f0752c151c00f0752c151c00f0752c151c00f0752c151c00f07c70f07c70f07c70f07c70f07c070c070c30f0770c270c20f07c70f07c170c40f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c470c10f07c370c070c00f07c270c2700f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c070c070c30f0770c270c20f07c70f07c170c40f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c270c30f07c170c070c20f07c070c270c10f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c170c270c00f07c70f07c370c20f07c270c070c10f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07c70f07"
voxset2="0f0f0f0f0f0f0f0f0f0f0f0f0f01204121400f0f0f0f0f0f0f08460f0f0a1402112110022141200221412002214120022141200221412002214120022141200221412000260f0f0a100610062006200620062006200620062006200440250f0f0a100620064006400640064006400640064006400420450f0f0a1006200640064006400640064006400640064004460f0f0a100610062006200620062006200620062006200440250f0f0f0f0f0f0f0f0f0f0f0f0f0f0f07214120400f0f0f0f0f0f0f09460f0f081402102111022041210220412102204121022041210220412102204121022041210220412102260f0f0c100610062006200620062006200620062006200225400f0f0c1006200640064006400640064006400640064002460f0f0c100620064006400640064006400640064006400245200f0f0c1006100620062006200620062006200620062002260f0f0c100610062006200620062006200620062006200225400f0f0c100620064006400640064006400640064006400245200f0f0c1006200640064006400640064006400640064002460f0f0c100610062006200620062006200620062006200225400f0f081402102111022041210220412102204121022041210220412102204121022041210220412102260f0f0f0f0f0f0f0845200f0f0f0f0f0f0f08204120410f0f0f0f0f0f0f0f0f0f0c1006100620062006200620062006200620062004260f0f0a1006200640064006400640064006400640064004460f0f0a1006200640064006400640064006400640064004460f0f0a1006100620062006200620062006200620062004260f0f0a140211211002214120022141200221412002214120022141200221412002214120022141200040250f0f0f0f0f0f0f0820450f0f0f0f0f0f0f09412140200f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f072040214120400f0f0f0f0f0f0f07470f0f07182111211020412141290521052105210529412141280f0f0f0f002043200f0f0f00270f0f0f0f0f0f0f07470f0f0f0f0f0f0f07470f0f0f0f0f0f0f07270f0f0f0f0f0f0f07270f0f0f0f0f0f0f07470f0f0f0f0f0f0f07470f0f0f0f0f0f0f07270f0f07100511051020052105210521052105210521052f200f0f0f0f0f0f0f07470f0f0f0f0f0f0f0721422040200f0f0f0f0f0f0f0f0f0f0a1006100620062006200620062006200620062004260f0f0a1006200640064090054020054090054090054020054090054004460f0f0a10062006400640200540300540300540c00540c005402005400420450f0f0a10061006200620900520300520b00520a00520c0052090052004260f0f0a10061006200620900520300520900520a00520c005209005200440250f0f0a10062006400640200540300540c00540c00540c005402005400420450f0f0a1006200640064090054020054090054090054020054090054004460f0f0a1006100620062006200620062006200620062004260f0f0a1006100620062006200620062006200620062004260f0f0a1006200640064006400640064006400640064004460f0f0a100620064006400640064006400640064006400420450f0f0a1006100620062006200620062006200620062004260f0f0a100610062006200620062006200620062006200440250f0f0a1006200640064006400640064006400640064004460f0f0a100620064006400640064006400640064006400420450f0f0a1006100620062006200620062006200620062004260f0f0b1006100620062006200620062006200620062002260f0f0c100620064006400640064006400640064006400245200f0f0c1006200640064006400640064006400640064002460f0f0c1006100620062006200620062006200620062002260f0f0c100610062006200620062006200620062006200225400f0f0c1006200640064006400640064006400640064002460f0f0c100620064006400640064006400640064006400245200f0f0c100610062006200620062006200620062006200225400f0f0c10061006200620062006200620062005a020062002260f0f0c100620064005e02005e02005e02005e02005e02005e02006400245200f0f0c10062006400580200580068006800680068020064002460f0f0c100610062005e02005e006e006e006e006e020062002260f0f0c1006100620058020058006800680068006802006200225400f0f0c100620064005e02005e006e006e006e006e020064002460f0f0c100620064005802005802005802005802005802005802006400245200f0f0c10061006200620062006200620062005a02006200225400f0f0f0f0f0f0f08270f0f0f0f0f0f0f07470f0f09100110032041200f0f0f0f01470f0f0f01430f0f0f0f01270f0f0f01430f0f0f0f01270f0f0910011003204120034001400390019003930f0f09470f0f0f0f0f0f0f07470f0f0f0f0f0f0f07270f0f0f0f9025900f0f0f270f0f0f0f20904390200f0f0f470f0f0a110f022045200191066006a00f0b470f0f0913042105410220419141200f0f0f270f0f09130421054102204071607040200f0f0f270f0f0a110f02204061706040200f0f0f470f0f0f0f20907390200f0f0f470f0f0f0f9025900f0f0f270f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0718551155115511551155115003501150035011500350115003501155180f0f10051050055105510551055115511003105110031051100310511003105115501005100f0f10051050055105510551055115511003105110031051100310511003105115501005100f0f18551155115511551155115003501150035011500350115003501155180f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0380200570800f0f0f011001110f0f0f05310431201003b030802004b10f0f0c1304210f0f05310433023501b101b102b001b004b10f0f0315022304210541054105410430413002314131013101310130033001b003b002b001b00f0f0215022304210541054105410430413002314131013101310130033001b003b002b001b00f0f031304210f0f0380203103708032023501b101b102b001b004b10f0f05110f0f0b201005802031043303b031b004b10f0f0f00100f0f0f0f0f0f0f0f100f0f0f0f0f0f0f0a110f0f0b90400570903104330330b13004b10f0f0c1304210f0f03402031039040320234904000310130709001b001b004b10f0f031502230421054105410541043041300231413101310130402000b003904000b003b002b001b00f0f02150223042105410541054104304130023141310131013101b003b001b003b002b001b00f0f031304210f0f0531043302350131013102b001b004b10f0f05110f0f0f05310433039040b030037090b00f0f0b100f0f0f0f0740200590400f0f0f0f0f0f0f0f0f0f0e110010063006b004300630063006300531043303b031b004b10f0f0c1304210f0f05310433023501b101b102b001b004b10f0f0315022304210541054105410430413002314131013101310130033001b003b002b001b00f0f0215022304210541054105410430413002314131013101310130033001b003b002b001b00f0f031304210f043006300230023200300234013501b101b102b001b004b10f0f05110f0f0f0531043303b031b004b10f0f0b10063006b006b00f0f0f0f0f0f05"
voxset3="0f0f0f0f0f0f0f0f04100f0f0f0a100f0e300f0f100f06300f0f04120210012006400640064006400f0612052006400640064006400f05100212052001300340053040064006403005400a100210063006b00a300f0f02100f0f0f0f0f0f0f0b100e300f0f0e1006300f0f0f051205200640064006400f0f0f0f0f0e100f06300f0f0f0c800f0f03800f0f0f0f011003100130033001b003300080708002b0063006b003800130058070800210011003200120032001e003e00120032001e003e0062006e0061006300630048000b0063006b00580708008800110062006e0062006e0062006e00f0f0f02800c800f10062006e0062006e00f0f10063006b006300580708001800f07100210022002200220022002e002e00220022002e002e0022006e0051006300630038001b0008004300280018070800f0f0f0f0f071001100330013003b0008070800180708005b004800f0610021002200220022002e002e00220022002e002e0022006e00f0f8003800f0f0f0f0f0f0f0f0f0f0f0f0f0f04150110d111d001d50162046204620461716070017501150111d01201d5016501650165016271600175011003100110031001d000d3016000d0046000d0046000d0046000d2600170037001100310011003d001d003d00160036001600360016003600160036001700370011003100110031001d000d3016000d0046000d0046000d0046000d260017003700110031001d0031001d50160d3600160d3600160d3600170d3600170037001100310011003d001d000d3016000d0046000d0046000d0047000d260017003700110031001d0031001d50f0960d370017003700110031001d0031001d000d3016000d0046000d0046000d0046000d27001700370011003100110031001d50f0970d3600170037001150111d010d01001d50162046204620470617061017501150110d012d001d50f096171607001750f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f011501d011d01101d50165016101610161016101617062017501150112d01101d501607060706101750f091003100110031001d003d00160d3600160d001d0600160d001d0600170d37001700370011003100110031001d003d0016003700170d37002730f0210031001d003d001d003d00160d3600f0170d360017003700110031001d0031001d003d0016003600170d001d0700270d17004710b10031001d0031001d003d00160d3600f0160d3600170037001100310011003d001d003d0017003600170d001d0700270d17004710b100310011003d001d003d00160d3600160d001d0600160d001d0600170d37001700370011003100110031001d003d0017003600170d37002730f02150111d01201d5016501610161016101610160706171017501150111d11101d50161706201750f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0b130f0f0f0c1105d0100f0f0f04130f0f0f0f04110f0f0f0f0f0f0f0d10d00f0f0f0f0f0f0f051105110f0f0f0210011003130f0f0f0f0f0f0f031001100310d0110f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f06110f0f0f0c130f0f0f0c110f0f0f0c130f0f0f0c110f0f0f0f0f0f0f0d110f0f0f0a110f0f0f0f0f0f0f0d110f0f0f0f0f0f0f0d110f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f11051105d01005710f0f041303d012031001d0031001100370120f0c110f05d0100f0f04130311d01003100110031001d003d110700f0c110f05110f0f0f0f0f0f05110510d005110570100f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f07110510d00510d00510700f0f0111011101d010011101d011d0110170d011710f0f05110511051105710f0f01110111011101d0100114d001711070d0100f0f0f05110510700f0f0f0f0f0f0f05110510d00f0f0f0f0f0f0511051105d0100570100f0f0f0f0f0f051105d010051105d0700f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f031105110511051105d010051105d0100510d0041303d01203130312d0031303d00110031001d00310d01070041105110510d0051105110f05d010041303130310d0110311d01003130310011003d00110037012041105d0100511051105110f05110f0f0f0f051105110511051105110510d005110510700f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f051105110510d005110511051105710c130312d003130310d0110310011003100110037010d0100c110511051105d0100f0510d00c130310d0110312d0031303d0011003100110037011700c110511051105110f05110f0f0f0f0d110510d005110511051105d0100510700f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0d1105110511051105110510d005701005710f0f0f0f0511051105110510d005110511051105701003150111d0120115011501d0100111011101110113d10170107303110511051105110f0511057010031501150113d0100115011101d0100110d00110d001701401711070d070031105d010051105110f05d0100510700f0f0f0f051105110510d0051105d01005110510d00570d00f0f0f0f05110511051105110511051105110510700f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0511051105110511051105110570100f0f0f0f0d11051105110510d005d01005d01005710b1501150110d011d010011101d01001d01001110112d1100171d07010700b1105110510d00f05110570100b150110d01301150110d001110111011101147001107110710b110510d005110f0510d005d0700f0f0f0f0d110510d005d01005d0100511051105710f0f0f0f0d11051105110511051105110510700f0f0f0f0f0f0f0f0f0f0f0f0f0f0030063006300eb006b00310063006310630053105b006b106b00410021002300230023002300a30023002b002b002b002b0091002100230023001310231003004300031023101b002b001b102b100b004b00f0030003004300030043000300cb000b004b000b00f0f0f0f0410063006300e3006b006b00f001002100230023002310031033000300331003102b002b002b100b103b000b00410011003300130033001300b30013003b001b003b001b00f0f0f0f0f0b30013003300130033001300bb001b003b001b00510063005310530063106b005b105b0071006300230023002300630023006b002b002b002b00f0f0f0f061006300630023006300230023002b006b002b006b0041006200630063006b006b00f0f0f0f0f0410031001200320013003300130033001b003b001b003b001b00f550f0f0f0b1006200630063006b006b006b00b51c3500f0f0f0910031001200320013003300130033001b003b001b003b006b00850c170c1500f0f0f0710031001200320013003300130033001b003b001b003b00f0250c070c1510f0f0f0a1006200630063006b006b006b00c50c3500f0f0f0910031001200320013003300130033001b003b001b003b001b003b00951c1510f0f0f0c1006200630063006b006b00f04530f0f0f0c530f0f0f0f0f0f0f0952c1500f0f0f0a1105d105610a300530b005b00fb051c050c1500f0f0f0912011001d201300261013106b00d3006b03006b050c1540f0f0f081204d205610f0f0b50c070c050c1500f0f0f081105d10f0f0f0450c151c1500f0f0f0c100630033001300230b005b0013006b030033001b002b10453c2500f0f0f09100630063001300530b0023001b003b03006b0013005b104540f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0910063006b0063006b0063006b00d1501d010d11101d230d10162b06101623061016130b061016030b0306101b030b030b101100010001002300030003002300030003002b000b000b002300030003002b000b000b0023006b00610031001d0031001d003d0016003600160036001b003600130036001b003b002100010001002300030003002b000b000b002300030003002b000b000b00230023002b002b009100310011003d001d003d00130036001b003600130033001b003b0013003b003100010043000300430003004b000b00430003004b000b0043006b00410031001d0031001d003d00160036001600330016003b00130033001b0033002100010001002300030003002b000b000b002300030003002b000b000b0043006b00b10031001d003d001d003d00160036001600360016003600160036001b003b001100010043000300430003004b000b00430003004b000b0043006b006150110d110d101d0b0d3016030630160b060306101603060b0610160b03060b0600130b130b0300f0f0f0f0f0f0f0f00"
voxset4="0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0c41200220412102204220022141200240204020400240204030400242b030024230b002b130b10f0f03130322100342200342200140214000400140200541054105410540300540b005b0300f0f06110511052104402104412004400640064006400640063006b00f0f0710062005410541054006400620062006400640064006b00f0f0710062005410540064006200640064006200620062006300f0f071006100521052105200640064006400640063006b006b00f0f0710062005410541054006400640062006200620062006300f0f07100610052105200620062006200640064006b0063006b00f0f071006200520400520064006400640064006b0063006b006300f0f0711052104420442044204400640064006400640063006b00f0f081303201120034021400340214001422102410541054105410541054105b10f0f0f0f01410241204102412041024120410241204102402040304002402040b0400240204030b002b3300f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0310062006400641064006400640064006200620062006b00f0f051006100621052106200620062006200640063006b006b00f0f05100620064106400640064006400640063006b0063006300f0f04110510200520410541054106400640064006400640064006b00f0f01130321110341214002410020400520410541054105204005204005204005204005b10f0f0f0241200342200342204002422040024221024320024030420230b04202b030b0410231b20f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0a410542204002422040024121400241204102403020410240b0304102b030b0410230b030b10f0f021303230343034220400341204105410541054105410541054105b10f0f041105110521052040064106400640064006400640064006b00f0f051006100620062040054106400640064006400640064006b00f0f051006100620400521062006200620062006200620062006b00f0f051006200641064006400640064006400640063006b006300f0f0410062006400541054105400640064006400640064006b00f0f0710062006400541054006400640064006400640063006300f0f071006200640054105400640064006400640063006b006b00f0f0710061005210521052105200620062006200640064006300f0f0710062005410540064006400640064006400620062006b00f0f0710062005410540064006400640064006400640064006b00f0f0710062005410541054105400640064006200620062006300f0f0710061006200620052105200620062006400640064006b00f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0417211022102041204220400040204220014020400f0f0f0f0f0f0b41032042004220422042204220422042204120432041204220413020422041b030422040b030b041b230b031b00f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0310062006410541064006400640064006400640064006300f0f051006100620062040052040064006400640063006b0063006b00f0f051006100620062105210620062006200620063006b006300f0f0510062006410541064006400640064006400640063006b00f0f0510062006410640064006400640064006400640064006b00f0f0510062006410541054106400640062006200620062006b00f0f0510061006210521062006200620063006b0063006b006300f0f0510062006410640064006400640064006400640064006b00f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f01410321410042204220422042204220422043204120432040204130412040204030b04120402040b030412030b130b030b10f0f1721102211412042210040204220014020400f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0b1855115511551155115511551155115511551155180f0f10051050055105510551055115511003105110031051100310511003105115501005100f0f10051050055105510551055115511003105110031051100310511003105115501005100f0f1855115511551155115511551155115511551155180f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f"

circles={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,77,78,79,80,81,82,83,104,105,106,109,110}
walls={24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,70,71,72,73,75,76,77,78,79,84,85,86,87,96,97,98,99,100,101,102,103,111,112,113,114,115,116,117,118,119}

__gfx__
0000000000000000000000000001000000011000000d0000000d00000001000000dddd0000000000000000111100000000000000000000000000000000000000
000000000000000000000000000d000001000000000100000d161d00001010100d6666d000000000000011d6d111000000000000000000000000000000000000
00010000000000000000000000161000100d0010001610000101010001010101d6766d7d000000000001d66d1111100000000000000000000000000000000000
0017100000060000000d00001d676d1010d7d010d16761d0d61716d000101010d666766d00000000001666d11111110000000000000000000000000000000000
00010000000000000000000000161000000d0000001610000101010001010101d6d6666d0000000001d6d6d11111111000000000000000000000000000000000
000000000000000000000000000d000000000100000100000d161d0010101010d666676d0000000001666d111111111000000000000000000000000000000000
0000000000000000000000000001000000101000000d0000000d0000010101000d76d6d0000000001d676d111111111100000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000100000dddd000000000016666d111111111100000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000016d66d111111111100000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000001d666d111111111100000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000001676d111111111000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000001d6d6d11111111000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000001667d11111110000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000001d66d1111100000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000011d6d111000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000111100000000000000000000000000000000000000
04100000000018400000000000000000000000001840000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6b8000000001a9700000000000188840000000002970000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a90000000059a7000000000002a9a70000000000230000000000000000000000000000000000000000000000000000000000000000000000000000000000000
352000000019a930018400000005a630001884000000018400000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002663001a970000000230000059a700000019a700000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000026a94000000000000026630000005a9300000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000002a700000000000000000000000263000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000002300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001d71000000000000000000000000000000000001111100000000000000000000000000000
0000000000000000000000000000000000000000000000000000001d72710000000000000000000000000000000001d777710000000000000000000000000000
0000000000000000000000000011000000000000000000000000001d7271000000000000000000000000000000001d7333371000000000000000000000000000
00000000000000000000000001d7100000000000000000000000001d727100000000000000000000000000000001d73777737100000000000000000000000000
0000000000000000000000001d72710000000000000000000000001d72710000111110000000000000000000001d737dddd7d100000000000000000000000000
0000000000000000000000001d72710000011111000000000000001dd7271001d7777100000000000111111001d737d111dd1000000000000000000000000000
0000000000000000000000001d727100001d77771011111110000011d727101d72222710000000001d77777101d7377777110000000000000000000000000000
0000000000000000000000001dd7271001d7222271d7d777710001d7777271d727777d1000000001d733333711d7333333710000000000000000000000000000
00000000000000000000000001d727101d7277772772722227101d72222271dd722271000000001d7377777371d7377777d10000000000000000000000000000
00000000000000000000000001d727101dd7772227d727777271d7277772711dd7772710000001d737ddddd737d737dddd100000000000000000000000000000
00000000000000000000000001d7271001d7227727d727dd727d727ddd727111ddd7271000001d737d1111d737737d1111000000000000000000000000000000
00000000000000000000000001dd72711d7277dd727d727dd7277277772271d777727d1000001d73711111d73773710000000000000000000000000000000000
000000000000000000000000001d72711d727d1d727d7271d727d722227727722227d10000001dd7377777737d73710000000000000000000000000000000000
000000000000000000000000001d727d777727772727d7d1dd7ddd7777dd7dd7777d1000000001dd73333337dd73710000000000000000000000000000000000
000000000000000000000000001d7277222772227d7ddd101dd11ddddd1dd1ddddd100000000001dd777777d1dd7d10000000000000000000000000000000000
000000000000000000000000001dd722777dd777ddd1110001100111110110111110000000000001ddddddd101dd100000000000000000000000000000000000
0000000000000000000000000001dd77ddd1dddd1110000000000000000000000000000000000000111111100011000000000000000000000000000000000000
00000000000000000000000000001ddd111011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000111000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000001110000001d7710000000000000000000000111110001111111111110000000000000000000000000000000000000000000
00000000000000000000000000001d77100001d71171000011111100000000011d7777111d777777777771100111111000000000000000000000000000000000
0000000000000000000000000001d71171001d7177171011d77777100000001d7711117d77111111111117711d77777100000000000000000000000000000000
000000000000000000000000001d717717101d71771711d771111171000001d7117777171177777777777117d711111710000000000000000000000000000000
000000000000000000000000001d71aa17101d71aa171d711aaaaa1710001d71aaaaaa11aaaaaaaaaaaaaaa171aaaaa171000000000000000000000000000000
000000000000000000000000001d719917101d719917d719999999917101d7199991117199991199111199911999999917100000000000000000000000000000
000000000000000000000000001d714441711d714417714444111444171d7144411777d711117144177711171441114417100000000000000000000000000000
000000000000000000000000001dd7122171d7122217122211777122217d7122177ddddd7777712217dd77771221712221710000000000000000000000000000
0000000000000000000000000001d7122217d7122177122177ddd7122177122217d1111ddddd7122217dddd71221771221710000000000000000000000000000
0000000000000000000000000001dd714417d714417144417d11d714441714417d100001111d7144417111d71441771441710000000000000000000000000000
00000000000000000000000000001d719991719991719917d101dd719917199171000000001dd719917101d71991771991710000000000000000000000000000
00000000000000000000000000001dd71aaa11aa1771aa1710001d71aa171aa1710000000001d71aa17101d71aa1111aa1710000000000000000000000000000
000000000000000000000000000001dd717771771771771710001d7177171771710000000001d717717101d71777777771710000000000000000000000000000
0000000000000000000000000000001dd71777771771771710001d7177171771710000000001d717717101d71777777771710000000000000000000000000000
00000000000000000000000000000001dd71aaa17d71aa1710001d71aa171aa171000000001d71aaa17101d71aa1111aa1710000000000000000000000000000
000000000000000000000000000000001d719917dd71991711001d719917199171000000001d7199917101d71991771991710000000000000000000000000000
00000000000000000000000000000001d71444171d7144417711d7714417144417100000001d714417d101d71441771444171000000000000000000000000000
00000000000000000000000000000001d712217d1dd71222117771122217712217711110001d7122171001d712217d7122171000000000000000000000000000
0000000000000000000000000000001d7122217101dd712222111222217d71222117777101d71222171001d712217d7122171000000000000000000000000000
0000000000000000000000000000001d714417d1001dd7144444444417ddd7144441111711d714417d1001d714417d7144171000000000000000000000000000
000000000000000000000000000001d7199917100001dd71199999117d11dd719999999171d71991710001d719917d7199171000000000000000000000000000
00000000000000000000000000001d71aaa17d1000001dd771111177d1001dd711aaaaa171d71aa1710001d71aa17d71aa171000000000000000000000000000
00000000000000000000000000001d717717d100000001ddd77777dd100001dd77111117d1dd7117d10001dd7117ddd7117d1000000000000000000000000000
00000000000000000000000000001dd7117d100000000011dddddd110000001ddd77777d101dd77d1000001dd77d11dd77d10000000000000000000000000000
000000000000000000000000000001dd77d100000000000011111100000000011dddddd10001ddd100000001ddd1001ddd100000000000000000000000000000
0000000000000000000000000000001ddd1000000000000000000000000000000111111000001110000000001110000111000000000000000000000000000000
00000000000000000000000000000001110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006f0000000000000000000000000000006c00000000000000
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
010400000e3131c303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000060003600066000b6000e600116000f600116001160012600136000403508605040450b60504035050050860504035040050860008600066000c6000960009600066000460002600006000060000600
011400000021502225086000b60000215022250a6000660000600006000060000600000000021502225086000b600002050220500000000000060002600056000760008600076000021502225086000b60000205
010c00000213500105021350010002135000000000000000000000000000600016000360007600086000860007600076000360000600006000000000000000000000000000000000000000000000000000000000
010800003333535305000003430534305333350000034305000000000034305000000000000000353050000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003653500500005000050038535005003853500500345050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003833538305383353000538335000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003823538205382353020538235002003823500200382350020000200002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003523530200302003522530205352350020000200002000020000200352450020000200352353020535235001000010000100001000010000100002000020000100000000000000000000000000000000
010c00000d3530d3430d3330d3230d3130c3130031300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000046151c606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000106151c606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000006151c606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000d6151c606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000106151c606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000106151c606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000b6151c606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000156151c606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000153631333311333103230e3230c313003130c303003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600003c0563005624056180463c0463003624036180263c0263001624016180163c00600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000113531d045291112900529005290052900500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
