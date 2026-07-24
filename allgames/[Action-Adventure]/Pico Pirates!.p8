pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--pico pirates
--by craig tinney (ctinney94)
fully_reveal_map_at_start=false
function sta(str)
local a,l={},0
while l<#str do
l+=1
if sub(str,l,l)=="," then
local s=sub(str,1,l-1)
if s=="true" then
add(a,true)
elseif s=="false" then
add(a,false)
else
n=tonum(s)
if n==null then
add(a,s)
else
add(a,n)
end
end
str,l=sub(str,l+1),0
end
end
return a
end

function init_boat(isPlayer)
return {x=-0,y=0,r=0,d=0,mx=0,my=0,max=2.5,player=isPlayer}
end
camx,camy,cellseed,celltype,stepIndex,morale,tempFlip,playerHpTimer,prevMorale,mapPos,once,dist,fps,currentcell,projectiles,fillps,extra_canons,wpts,prevwpts,btn4,boat,npcBoat,currentcellx,currentcelly,clouds,first_comb,first_topdown,boat_message,txt_timer,score,player_x,player_y,player_draw,player_speed,player_fp_dist,compass_chunks,vt,shakeX,shakeY,shakeTimer,cells,waves,enemyTimer,enemyHpTimer,enemyPrevHp,enemyName,firstChest,world_seed,nextState,st_t,state=0,0,0,"",4,100,false,0,100,127,true,999,{},{},{},sta"0b0101101001011010.1,0b111111111011111.1,0b1010010110100101.1,’",1,{},{},false,init_boat(true),0,15,16,{},true,true,"aH, THE OPEN SEA!",0xffee,0,0,0,false,1,0,0xffff,0,0,0,0,{},{},0,0,100,"",true,0,1,0xfffe,0xfffe

function spr_rot(sx,sy,swh,dx,dy,rot,depth,circ)
local s,c,size=sin(rot),cos(rot),swh/2
local _b,w,spacing,r=(s*s+c*c),sqrt(size^2*2),1,0
if (circ)spacing,r=3,2
for y=-w,w do
for x=-w,w do
local ox,oy=(s*y+c*x)/_b+size,(-s*x+c*y)/_b+size
if ox<swh and oy<swh and ox>0 and oy>0 then
for d=0,depth do
local col=sget(ox+sx+d*12,oy+sy)
if col>0 then
_circfill(dx+x*spacing,dy+(y-d)*spacing,r,col)
end
end
end
end
end
end
_fillp_original=fillp
function fillp(pattern,x,y)
local add_bits,pattern,y,x=band(pattern,0x0000.ffff),band(pattern,0xffff),flr(y)%4,flr(x)%4
if(y~=0)then
r,l={0xfff0,0xff00,0xf000},{0x000f,0x00ff,0x0fff}
pattern=bxor(lshr(band(pattern,r[y]),y*4),shl(band(pattern,l[y]),(4-y)*4))
end
if(x~=0)then
r,l={0xeeee,0xcccc,0x8888},{0x1111,0x3333,0x7777}
pattern=bxor(lshr(band(pattern,r[x]),x),shl(band(pattern,l[x]),4-x))
end
return _fillp_original(bxor(pattern,add_bits))
end
function print_u(s,x,y,c,u)
if (c==nil)c,u=7,1
?s,x,y+1,u
?s,x,y,c
end
function aabbOverlap(a,b)
return ((a.x+a.w>b.x)and (a.x<b.x+b.w))
and ((a.y+a.h>b.y)and (a.y<b.y+b.h))
end
function pal_all(c)
for i=0,15 do
pal(i,c)
end
end
function lerp(a,b,t)
return b*t+(a*(1-t))
end
function rrnd(min,max)
return rnd(max-min)+min
end
function halfprob()
return rnd"2">1
end
function rnd_int(num)
return ceil(rnd(num))
end
function weighted_rnd(array)
local total=0
for a in all(array)do
total+=a
end
r=rnd(total)
for a in all(array)do
if (r<a)return a
r-=a
end
end
function _init()
boat.max=3
for i=0,50 do
add(clouds,{
x=camx+rnd"127",y=camy+rnd"127",
r=4+rnd"10",z=rrnd(1.5,2),vx=0,vy=0,
update=function(c)
local x,y,vx,vy=c.x,c.y,c.vx,c.vy
x+=cellwindy
y-=cellwindx
if (x+vx>camx+128)x-=128
if (y+vy>camy+128)y-=128
if (x+vx<camx-0)x+=128
if (y+vy<camy-0)y+=128
vx,vy=(x-camx-64)*c.z,(y-camy-64)*c.z
c.vx,c.vy,c.x,c.y=mid(0xff80,vx,128),mid(0xff80,vy,128),x,y
end,
draw=function(c)
fillp(fillps[2-flr(c.r/8)])
_circfill(c.x+c.vx,c.y+c.vy,c.r,7)
fillp""
end
})
end
for i=0,159 do
add(wpts,0)
add(prevwpts,0)
end
end

function _update()
if state==0 then
if btnp(5)then
state,st_t=2,0
if (world_seed==0)world_seed=rnd_int"99"
srand(world_seed)
for cx=0,31 do
local subcell={}
add(cells,subcell)
for cy=0,31 do
local wx,wy=rrnd(.25,1),rrnd(.25,1)
if (halfprob())wx*=0xffff
if (halfprob())wy*=0xffff
local _type="sea"
if rnd"1">.925 then
_type="island"
elseif rnd"1">.7 then
_type="enemy"
elseif rnd"1">.6 then
_type="boat"
end
add(subcell,{type=_type,treasure=weighted_rnd(sta"1,1.5,2,2.5"),seed=rnd"4096",windx=wx,windy=wy,visited=fully_reveal_map_at_start})
end
end
while (cells[currentcellx][currentcelly].type!="sea")do
currentcellx,currentcelly=flr(rrnd(2,30)),flr(rrnd(2,30))
end
end
elseif state==1 then
cls""
morale=max(30,morale-.005)
if (boat.x<0xff00)then
currentcellx-=1
if (currentcellx<1)currentcellx+=#cells
cell_shift(512,0)
elseif (boat.x>256)then
currentcellx+=1
if (currentcellx>#cells)currentcellx=1
cell_shift(0xfe00,0)
elseif (boat.y<0xff00)then
currentcelly-=1
if (currentcelly<1)currentcelly+=#cells[currentcellx]
cell_shift(0,512)
elseif (boat.y>256)then
currentcelly+=1
if (currentcelly>#cells)currentcelly=1
cell_shift(0,0xfe00)
end
if (celltype=="island")island_update""
if celltype=="enemy" then
for i=0,4 do
local r,d=rnd"1",rnd(i*32)
add(waves,{x=sin(r)*d,y=-cos(r)*d-1,r=2})
end
end
if player_draw then
if abs(player_x-boat.x)<4 and abs(player_y-boat.y)<4 then
player_draw,magnitude=false,sqrt(boat.x*boat.x + boat.y*boat.y)*.1
sfx"53"
boat.x+=boat.x/magnitude
boat.y+=boat.y/magnitude
end
if (btn"0")player_x-=player_speed
if (btn"1")player_x+=player_speed
if (btn"2")player_y-=player_speed
if (btn"3")player_y+=player_speed
if (btn()>0)player_fp_dist+=1
if player_x<camx+56 then
camx=player_x-56
elseif player_x>camx+72 then
camx=player_x-72
end
if player_y<camy+56 then
camy=player_y-56
elseif player_y>camy+72 then
camy=player_y-72
end
end
map=btn"5"
for c in all(clouds)do
c.update(c)
end
if map then
mapPos=max(mapPos-16,0)
else
mapPos=min(mapPos+16,127)
end
if (not player_draw)boat_update(boat)
if (npcBoat!=0)boat_update(npcBoat)
elseif state==3 then
for c in all(comb_objs)do
c.update(c)
end
elseif state==4 then
update_island_chest_view""
end
st_t+=0.016666
end
function _draw()
if (state<1)cls()
if state==-2 then
print_str('412067616d65206d616465206279',23,60,7)
print_str('43726169672054696e6e6579',25,72,12)
?"@CTINNEY94",45,75,1
if (time()>3)state=0xffff
elseif state==0xffff then
print_str('57697468206d75736963206279',24,60,7)
print_str('436872697320446f6e6e656c6c79',19,72,12)
?"@GRUBER_MUSIC",39,75,1
if (time()>6)state=0 music"29"
elseif state==0 then
for i=1,3 do
print_xl(sta"10,20,32,’"[i],5,i-1,7)
end
local vals=sta"-71,33,13,-71,32,7,-49,5,13,-49,4,7,’"
for i=1,12,3 do
for x=86,109 do
pal(1,vals[i+2])
local a=x+vals[i]
_sspr(x,0,1,26,a,vals[i+1]+sin(t""*-.33+(a*.018))*2)
end
end
for i=1,7 do
print_xl(sta"-12,-2,11,23,31,43,55,’"[i],32,sta"0,3,4,5,7,8,9,’"[i],7)
print_str(({'5072657373','58','746f207374617274'})[min(i,3)],sta"16,52,64,64,64,64,64,’"[i],110+sin(t""*.5)*4,sta"7,8,7,7,7,7,7,’"[i])
end
print_str('576f726c642067656e2073656564',15,78,7)
if world_seed==0 then
print_u(": RND",101,72)
else
print_u(": "..world_seed,101,72)
end
s=2
if (btn(2))s=5 world_seed+=1
if (world_seed>99)world_seed=0
spr(s,108,66)s=18
if (btn(3))s=21 world_seed-=1
if (world_seed<0)world_seed=99
spr(s,108,79)
elseif state==1 then
camera(camx,camy)
cls"12"
boat_text_process""
if celltype=="island" then
for b in all(ib)do
_circfill(b.x,b.y,b.rad+16,1)
end
end
fillp(0b0101101001011010.1)
for w in all(waves)do
circ(w.x,w.y,w.r,7)
w.r+=0.2
if (w.r>10)del(waves,w)
end
fillp""
if (celltype=="island")island_draw""
if celltype=="enemy" then
if (abs(boat.x)<64 and abs(boat.y)<64)state,nextState,st_t=2,3,0music"10"
end
boat_draw(boat)
if (npcBoat!=0)boat_draw(npcBoat)
for c in all(clouds)do
c.draw(c)
end
print_u(currentcellx,camx+102,camy+5)
print_u(currentcelly,camx+116,camy+18)
_rectfill(camx+111,camy,camx+127,camy+16,12)
if (celltype=="island")_circfill(camx+119,camy+8,island_size/16,15)
minimapPos(boat,4)
if (npcBoat!=0)minimapPos(npcBoat,2)
_rect(camx+111,camy,camx+127,camy+16,7)
draw_morale_bar""
for c=0,1 do
pal(6,7^c)
spr_rot(26,2,12,camx+120,camy+44-c,atan2(cellwindx,cellwindy),0)
pal""
end
print_u("wIND",camx+112,camy+30)
boat_text_render(flr(boat.x-24),flr(boat.y-16))
if mapPos<127 then
local _y,_x,e,rot=camy+20,camx-mapPos+1,sta"124,0,3,52,107,18,3,52,true,true,124,0,3,52,107,70,3,52,true,false,124,0,3,52,0,70,3,52,false,true,124,0,3,52,0,18,3,52,false,false,0,58,109,3,2,16,109,3,false,false,0,58,109,3,2,121,109,3,false,true,’",.25
for i=1,#e,10 do
sspr(e[i],e[i+1],e[i+2],e[i+3],_x+e[i+4],camy+e[i+5],e[i+6],e[i+7],e[i+8],e[i+9])
end
rectfill(_x+3,_y-2,_x+106,_y+100,15)
_x+=4
for c=12,13 do
for x=1,32 do
for y=1,32 do
if cells[x][y].visited then
_circfill(_x+x*3,_y+y*3,15-c,9-c)
end
end
end
end
for x=1,32 do
for y=1,32 do
local c,r=15,1
if (cells[x][y].type=="island")_circfill(_x+x*3,_y+y*3,r,c)
end
end
_x+=boat.x/128
_y+=boat.y/128
if (flr(time()*4)%2>0)_pset(_x+currentcellx*3,_y+currentcelly*3,4)
end
if (compass_chunks>-1)_sspr(71+compass_chunks*13,40,13,16,camx+114,camy+54)
if (compass_chunks>2 and npcBoat!=0)spr_rot(106,27,7,camx+120,camy+60,atan2(npcBoat.x-boat.x,npcBoat.y-boat.y)-.25,0)
elseif state==2 then
if st_t>0 and st_t<.8 then
local a=0
for y=0,127 do
if y%2==0 then
_line(camx+127,camy+y,camx+127-st_t*59,camy+y,0)
else
_line(camx,camy+y,camx+st_t*59,camy+y,0)
end
end
for y=0,127 do
local scr,l=0x6000+y*64,-st_t*2
if (y%2==0)l=(st_t+.48)*2
memcpy(scr,scr+l,64)
end
elseif once then
print_str('4c6f6164696e67',76,127,12)
flip""
for _x=1,#cells do
for _y=1,#cells[_x] do
local vals,self=sta"1,0,-1,0,0,1,0,-1,’",cells[_x][_y]
for i=1,8,2 do
local adjCell=cells[mid(1,flr(_x+vals[i]),#cells-1)][mid(1,flr(_y+vals[i+1]),#cells[_x]-1)]
self.windx+=adjCell.windx
self.windy+=adjCell.windy
end
self.windx/=5
self.windy/=5
end
setcell()
end
end
if st_t>1 then
state,once=nextState,false
if (nextState==1)music"0"
if (nextState==3)comb_init(true)
if (nextState==4)init_island_chest_view""music"62"
if (nextState==5)comb_init(npcBoat.player)state,npcBoat=3,0
end
elseif state==3 then
cls"12"
if shakeTimer>0 then
shakeX,shakeY=rrnd(0xfffc,4),rrnd(0xfffc,4)
shakeTimer-=.33
else
shakeX,shakeY=0,0
end
camera(shakeX,shakeY)
_circfill(124,8,24,10)
boat_text_process""
boat_text_render(comb_boat.x,comb_boat.y-16)
for c in all(comb_objs)do
c.draw(c)
end
drawUpdateWater()
memcpy(0x1800,0x7140,0x800)
palt(12,true)
palt(1,true)
pal_all"13"
for y=1,31 do
sspr(0,127-y,128,1,sin(t""+y/20)*(y/5),101+y)
end
for x=0,127 do
local c=sget(x,127)
if (pget(x,101)==1 and c!=12 and c!=7 and c!=1)pset(x,101,c)
end
pal()
if victory then
vt,cols=t""-victory_time,{}
if endGame then
txt_timer=0
if (vt>2)print_str("434f4e47524154554c4154494f4e53",3,32,8)
if (vt>5)print_str("596f752068617665206465666561746564",10,58,7)
if (vt>5)print_str("74686520506972617465204b696e6721",16,68,7)print_u("!",110,62)
if (vt>9)print_str("5468616e6b7320666f7220706c6179696e6721",8,88,10)print_u("!",118,82,10)
else
rectfill(0,48,127,64,0)
pal(15,sget(min(vt*15,4),9))
sspr(0,61,112,14,7,49,114,16)
pal(15,sget(min(vt*15,11),8))
_sspr(0,61,112,14,8,50)
pal""
celltype,currentcell.type,string="sea","sea","cREW MORALE INCREASED!"
print_u(sub(string,0,vt*10),20,68)
morale=min(morale+0.1+rnd".2",100)
if vt>5 then
nextState,state,st_t,boat_message=1,2,0,""
for o in all(comb_objs)do
o=null
end
end
end
elseif morale>0 then
cannonLines(2+comb_boat.x,5+comb_boat.y,comb_boat)
if (tentacles==null)cannonLines(2+enemy.x,5+enemy.y,enemy)
print_u(enemyName,4,113)
rect(4,120,123,126,0)
local barLength0,barLength1=lerp(0,118,enemy.hp/100),lerp(0,118,enemyPrevHp/100)
if enemyHpTimer>0 then
enemyHpTimer=max(0,enemyHpTimer-.075)
if (enemyHpTimer<=1)barLength1=lerp(barLength0,barLength1,enemyHpTimer)
else
enemyPrevHp,barLength1=enemy.hp,barLength0
end
_rectfill(5,119,5+barLength1,124,14)
_rectfill(5,119,5+barLength0,124,8)
_rect(4,119,5+barLength1,124,2)
_rect(4,119,123,125,7)
end
if comb_boat !=null then
if (comb_boat.y>125 or vt>13)then
print_u("fINAL SCORE: "..score.."\nyOUR SEED WAS "..world_seed,32,105)
if (time()%1>.15)print_u("pRESS x TO PLAY AGAIN",24,120)
if (btn"5")run()
end
end
draw_morale_bar""
elseif state==4 then
draw_island_chest_view""
end
if ((state==3 and first_comb)or(state==1 and first_topdown))and txt_timer>0 then
local txt_pos=10
if (txt_timer<10)txt_pos=txt_timer%10
if (txt_timer>50)txt_pos=-txt_timer%15
txt_pos=-sin(txt_pos/30)*48+camy
a=sta"35,26,93,1,1,35,26,93,2,15,36,25,92,3,2,egg!"
for i=1,15,5 do
rectfill(a[i]+camx,txt_pos-a[i+1],a[i+2]+camx,txt_pos-a[i+3]-state*3,a[i+4])
end
if first_topdown then
first_topdown=txt_timer<60
print_u(" tURN: ‹/‘\nmOVE: HOLD ”\n sHOW MAP: —",camx+39,txt_pos-24,15,4)
elseif first_comb then
first_comb=txt_timer<60
print_u(" mOVE: ‹/‘\nsHOOT: HOLD —",camx+37,txt_pos-24,15,4)
end
end
if st_t>1 and st_t<1.5 and state!=4 then
fillp((sta"0,1.5,3.5,7.5,15.5,143.5,2191.5,-30576.5,-14192.5,-6000.5,-1904.5,-1648.5,-1632.5,-1600.5,-1536.5,-512.5,’")[ceil((st_t-1)*32)])
_rectfill(camx,camy,camx+128,camy+128,0)
fillp""
end
tempFlip=false
end
function checklandcol(x,y,r)
for i in all({-r*2,0,.75,.25})do
if (pget(x-sin(r+i)*8,y+cos(r+i)*8)==15)return true
end
end
function newWave(_x,_y)
add(waves,{x=_x,y=_y,r=2})
end
function cell_shift(x,y)
boat.x+=x
boat.y+=y
if (npcBoat!=0)npcBoat.x+=x npcBoat.y+=y
for w in all(waves)do
w.x+=x
w.y+=y
end
for c in all(clouds)do
c.x+=x
c.y+=y
end
setcell""
end
function setcell()
currentcell=cells[currentcellx][currentcelly]
if (not currentcell.visited)score+=1
currentcell.visited,cellwindx,cellwindy,cellseed,celltype=true,mid(-.5,currentcell.windy,.5),mid(-.5,currentcell.windx,.5),currentcell.seed,currentcell.type
if celltype=="island" then
if (cellseed!=prevSeed)fps={}
prevSeed=cellseed
if (not currentcell.visited)score+=24
createisland(cellseed)
elseif npcBoat==0 and celltype=="boat" then
npcBoat,boatCell=init_boat(false),currentcell
enemyAngleOffset=-.25
if compass_chunks>2 then
npcBoat=init_boat(null)
elseif flr(cellseed)%3==0 then
enemyAngleOffset,npcBoat.max=.25,2
end
end
end
function island_update()
for t in all(it)do
t.vx,t.vy=(t.x-camx-64)*t.z,(t.y-camy-64)*t.z
end
for b in all(ib)do
circfill(b.x,b.y,b.rad,15)
end
end
function island_draw()
local _t=(1+sin(t""*.2))*8
for b in all(ib)do
_circfill(b.x,b.y,b.rad+_t+1,7)
end
for b in all(ib)do
_circfill(b.x,b.y,b.rad+_t,13)
end
for b in all(ib)do
_circfill(b.x,b.y,b.rad,15)
end
for b in all(ib)do
_circfill(b.x+(b.r0*8),b.y+(b.r0*8),b.rad/15,6)
end
if (island_size>8)_circfill(0,0,island_size*.8,6)
if (island_size>16)_circfill(0,0,island_size*.5,4)
fillp(0b111111111011111.1,-camx,-camy)
if (island_size>6)_circfill(0,0,island_size*1.35,6)
fillp(0b0101101001011010.1,-camx,-camy)
if (island_size>16)_circfill(0,0,island_size*.35,9)
fillp""
for t in all(it)do
if(t.c<2)t.draw(t)
end
for f in all(fps)do
_pset(f[1],f[2],13)
end
if currentcell.treasure!=0 then
local crossX=sin(currentcell.seed/4096)*island_size
local crossY=cos(currentcell.seed/4096)*island_size
if (abs(crossX-player_x)<6 and abs(crossY-player_y)<6)state,st_t,nextState=2,0,4
_sspr(47,47,10,11,crossX,crossY)
end
if player_draw then
c,player_speed=pget(player_x,player_y),1
if (c==12)player_speed=.1
if player_fp_dist>2 then
if c==15 then
add(fps,{player_x,player_y})
sfx"50"
else
sfx"51"
end
player_fp_dist=0
end
pal""
_circfill(player_x,player_y,1,0)
end
for t in all(it)do
if(t.c>1)t.draw(t)
end
end
function createisland(seed)
srand(seed)
island_size=rrnd(6,70)
size,total_circs,ib,it=island_size,max(island_size/8,5),{},{}
for i=0,total_circs do
local r=i/total_circs
add(ib,{
x=cos(r)*island_size,y=-sin(r)*island_size,
rad=(island_size)*(rrnd(.7,1.3)),
r0=rrnd(0xffff,1),r1=rrnd(0xffff,1),r2=rrnd(0xffff,1),r3=rrnd(0xffff,1)
})
end
if size>24 then
size*=.5
for i=0,size/2 do
local r,sz=i/(size/2),rrnd(8,12)
newtree(rrnd(0xfffb,5)+cos(r)*size,rrnd(0xfffb,5)-sin(r)*size,sz)
end
for i=0,size/4 do
local r,sz=i/(size/4),rrnd(2,12)
newtree(rrnd(0xfffb,5)+(rnd"1"-.5)*size,rrnd(0xfffb,5)-(rnd"1"-.5)*size,sz)
end
for i=1,#it do
local j=i
while j>1 and it[j-1].z>it[j].z do
it[j],it[j-1]=it[j-1],it[j]
j=j-1
end
end
end
end
function newtree(_x,_y,s)
local z=rrnd(1,1.5)
local z_array,c_array,r_array,fillp_array={0,0,0,z-.25,z-.15,z,z+.5,z+1,z+1.25,z+1.5},sta"4,1,1,3,3,3,11,11,7,7,’",sta".25,1,1.1,1,.9,.8,.667,.5,.25,.2,’",sta"0x0000,0b1010010110100101.1,0b0101101001011010.1,0b111111111011111.1,0b0101101001011010.1,0x0000,0b0101101001011010.1,0x0000,0b0101101001011010.1,0x0000,’"
for i=1,10 do
add(it,{
x=_x,y=_y,z=z_array[i]*.1,
vx=0,vy=0,
c=c_array[i],r=s*r_array[i],
palette=fillp_array[i],
draw=function(t)
fillp(t.palette,-camx,-camy)
_circfill(t.x+t.vx,t.y+t.vy,t.r,t.c)
fillp""
end
})
end
end
function boat_text_process()
txt_timer+=.33
print_u(sub(boat_message,0,txt_timer),camx,camy)
memcpy(0x1d00,0x6000,768)
_rectfill(camx,camy,camx+64,camy+12,12)
if txt_timer>#boat_message+45 then
if state==3 then
txt_timer,boat_message=0,"cOME ON THEN PAL,\nSQUARE TAE GO LIKE! "
if halfprob()then
if enemy.steps!=null then
boat_message="bEGONE, GANGLY\nBEAST! "
elseif not endGame then
boat_message="fILTHY LAND\nLOVER! "
end
end
if morale<65 and morale>25 then
boat_message=sta"nO SLACKING YOU\nLAZY SEA DOGS! ,yOU'LL HAVE TO DO\nBETTER THAN THAT! ,arrrr! ,s"[rnd_int"3"]
elseif morale<25 and morale>1 then
boat_message=sta"dON'T GIVE\nUP MEN! ,mAYBE I SHOULDN'T OF\nBEEN A PIRATE... ,wE'RE DONE\nFOR! ,wHY DID WE CHOOSE\nTHEM AS CAPTAIN? ,s"[rnd_int"4"]
end
else
if celltype=="sea" then
xs,ys,dirs,boat_message,txt_timer=sta"-1,1,0,0,’",sta"0,0,1,-1,’",sta"WEST,EAST,SOUTH,NORTH,s","cLEAR HORIZONS... ",0
for i=1,#xs do
local cellToCheck=cells[flr(mid(1,currentcellx+xs[i],31))][flr(mid(1,currentcelly+ys[i],31))]
if not cellToCheck.visited and cellToCheck.type=="island" then
boat_message,i="lAND TO\nTHE "..dirs[i].."! ",9
end
end
elseif celltype!="island" then
txt_timer,boat_message=0,sta"sOMETHING ON\nTHE HORIZON... ,sir! I SPY\nSOMETHING! ,iS THAT WHAT I\nTHINK IT IS? ,s"[rnd_int"3"]
else
boat_message,txt_timer="lAND AHOY!",0
if (player_draw)boat_message=sta"sHOULD WE WAIT\nFOR THE CAPTAIN? ,gOOD TO BE ON\nSOLID GROUND AGAIN... ,iS THAT\ntreasure! ,cAPTAIN'S GONE...\nGET THE RUM OUT! ,s"[rnd_int"4"]
end
end
end
end
function boat_text_render(x0,y0)
if txt_timer>0 and txt_timer<#boat_message+15 then
local _y=0
if (sub(boat_message,#boat_message,#boat_message)==' ')_y=6
palt(12,true)
for y=0,_y,6 do
for x=0,80,2 do
sspr(x,116+y,2,6,x0+x,y0+y+sin(t""+x/#boat_message))
end
end
end
end
function putAFlipInIt()
tempFlip=true
end
menuitem(1, "do a flip()!",putAFlipInIt)
function print_s(_x,_y,_l,c)
local l=_l%7
if (c!=1)print_s(_x,_y+1,_l,1)
set_col_layer(c,(_l-l)/7)
_sspr(7*l,16,7,7,_x,_y-7)
pal()
end
function print_l(_x,_y,_l,c)
local l=_l%7
if (c!=1)print_l(_x,_y+1,_l,1)
set_col_layer(c,(_l-l)/7)
_sspr(12*l,23,12,11,_x,_y-10)
pal()
end
function print_xl(_x,_y,_l,c)
local l=_l%3
if (c!=13)print_xl(_x,_y+1,_l,13)
for x=49,61 do
set_col_layer(c,(_l-l)/3)
_sspr(12*l+x,0,1,22,_x+x,_y+sin(time()*-.33+((_x+x)*.018))*2)
end
pal()
end
function print_str(_str,x,y,c)
local str,p={},x
for i=1,#_str,2 do
add(str,('0x'..sub(_str,i,i+1))+0)
end
add(str,0x20)
for s=0,#str-2 do
local v=str[s+1]
if v>96 then
print_s(p,y,v-97,c)
p+=6
else
print_l(p,y,v-65,c)
if v<65 then
p+=5
else
p+=9
if (str[s+2]<96)p-=1
end
end
end
end
function set_col_layer(c,b)
for i=0,15 do
if band(shl(i),2^b)>0 then
pal(i,c)
else
palt(i,true)
end
end
end
function comb_init(timeToFightAnOctopus)
comb_boat=newComb_boat()
camx,camy,comb_objs,victory,comb_boat.hp,comb_boat.isPlayer,boat_message,txt_timer=0,0,{},false,morale,true,"aLL HANDS\nON DECK! ",0xfffa
camera(0,0)
if timeToFightAnOctopus then
enemyName,vals,tentacles,enemy=sta"a GHASTLY SEA MONSTER,wIGGLEY PETE,tHE DREADED OCTOKRAKEN,aN UNGODLY ABOMINATION,s"[rnd_int"3"],sta"119,96,112,92,87,90,79,88,73,97,’",{},{
hp=100,
x=88,y=88,w=24,h=72,
flashing=0,
timer=0,
steps={
function(o)
o.y+=.5
for t in all(tentacles)do
t.y+=.5
end
if o.y>108 then
if o.hp>0 then
enemyTimer=0
if halfprob()then
stepIndex=3
else
stepIndex=5
end
else
music"28"
victory_time,enemy,victory,boat_message,txt_timer=time(),null,true,"tAKE THAT,\nFOUL BEAST! ",0
victory_time+=0.01
score+=150
del(comb_objs,o)
end
end
end,
function(o)
o.y-=.5
for t in all(tentacles)do
t.y-=.5
end
if o.y<88 then
stepIndex,enemyTimer=4,0
end
end,
function(o)
local target,ta=(abs(comb_boat.x-o.x)-4)/80,{-rnd".2",0,rnd".2"}
for i=1,3 do
fireProjectile(o.x,o.y-8,true,2,ta[i],target+ta[i],o)
end
stepIndex=2
end,
function(o)
if (enemyTimer>3)stepIndex,enemyTimer=1,0
end,
function(o)
local noodle=tentacles[1]
if (noodle.x==119)noodle.x,noodle.y=comb_boat.x,105
if enemyTimer<1.5 and enemyTimer>1 then
noodle.y-=1
elseif enemyTimer>1 then
noodle.y+=.5
if noodle.y>103 then
noodle.x,noodle.y=119,114
enemyTimer=0
stepIndex=2
end
end
end,
},
update=function(o)
enemyTimer+=0.03
o.y+=cos(time())*.25
if (o.hp<=0)stepIndex=1
o.steps[stepIndex](o)
end,
draw=function(o)
dmgFlash(o)
palt(0,true)
_sspr(0,34,29,24,o.x,o.y)
for i=o.x,o.x+33 do
if (o.hp>0)wpts[flr(i+16)]+=rnd(.25)
end
for t in all(tentacles)do
for y=0,24 do
local _x=t.x+2+(1.5*sin(time()+t.o+y*.1))
local _y=t.y+cos(time()+t.o*2)
if (y==1 and o.hp>0)wpts[flr(_x+16)]+=rnd(.25)
_sspr(29,34+y,3,1,_x+1,_y+y)
end
end
pal()
end
}
for i=1,10,2 do
add(tentacles,{x=vals[i],y=vals[i+1],o=rnd"1",w=5,h=24})
end
add(comb_objs,enemy)
else
enemyName,enemy=sta"743 pARROTS,aNOTHER FRANKLY LESSER PIRATE,lAME JOHN SILVER,dAVID JONES AND CREW,tHE dAD pIRATE rOBERTS,jOHN BOAT,the FLYING TAXMAN,hms eGG,a GOAT AT SEA,lITTLE wET mAN,dAVID jASON'S gHOST bOAT,ss dEAD mEME,s"[rnd_int"12"],newComb_boat()
if (timeToFightAnOctopus==null)enemyName,enemy.w,enemy.h,endGame,enemy.hp="tHE pIRATE kING",29,26,true,100
enemy.isPlayer,enemy.x=timeToFightAnOctopus,114
end
for j=1,0,0xffff do
srand"1"
for i=0,25 do
add(comb_objs,{x=rnd"127"+j*2,y=rrnd(8,40)+j,r=rrnd(4,12)+j,c=7-j,vx=rnd".5",
update=function(c)
c.x+=c.vx
if (c.x>140)c.x -=160
end,
draw=function(c)
_circfill(c.x,c.y,c.r,c.c)
end})
end
end
add(comb_objs,comb_boat)
add(comb_objs,enemy)
end
function pt(i)
return wpts[mid(1,flr(i),#wpts-1)]
end
function drawUpdateWater()
for i=1,#wpts do
prevwpts[i],diff,surroundingPoints=wpts[i],wpts[i]-prevwpts[i],0
wpts[i]+=.975+diff*1.125
for j=0xfffc,4 do
surroundingPoints+=pt(i+j)
end
wpts[i]=mid(wpts[i]-surroundingPoints*.005*wpts[i],0,128)
_line(i-16,160,i-16,wpts[i]+97,1)
if abs(diff)>.3 then
_pset(i-16,wpts[i]+97,7)
end
end
end
function comb_boat_move(obj,m)
obj.vx,obj.flipx,x=mid(-1.5,obj.vx+m,1.5),m<0,18
if (m<0)x=23
wpts[mid(1,flr(obj.x+x),160)]-=.7
if (not endGame)sfx"49"
end
function comb_boat_fire_projectile(b)
sfx(48,3)
local max,traj,size,x,y=1,0,1,b.x,b.y
if (b.isPlayer)max=extra_canons
if (b.isPlayer==null)max,size=2,2 x+=12 y+=18
for i=1,max do
if (i>0)traj=rrnd(-.2,.2)
fireProjectile(2+x,5+y,b.flipx,size,b.vx+traj,b.aim+traj,b)
end
b.aim,b.firecd=.1,1
if b.isPlayer!=null then
max=max*.5+1
b.vx-=max
if (b.flipx)b.vx+=max*2
else
b.firecd=1.4
end
end
function newComb_boat()
return {
x=16,y=62,w=8,h=8,vx=0,
flipx=false,aim=.1,firecd=0,
hp=rrnd(50,100),flashing=0,isPlayer=false,
update=function(b)
b.firecd=max(b.firecd-.0333,0)
if b.isPlayer then
if (btn"0")comb_boat_move(b,-.1)
if (btn"1")comb_boat_move(b,.1)
if (btn"5"and b.firecd==0)b.aim+=0.025
if (btn4 and not btn"5" and b.firecd==0 or b.aim>1)comb_boat_fire_projectile(b)
btn4=btn"5"
elseif morale>0 then
b.flipx=true
if (abs(comb_boat.x-b.x)<48)comb_boat_move(b,.1)
if (abs(comb_boat.x-b.x)>72 or b.x>114)comb_boat_move(b,-.1)
if (b.x>125)b.flipx=true
local target=(abs(comb_boat.x-b.x)-4)/80
local a=0.01
if (b.isPlayer==null)a*=2
if (b.aim>target)a*=0xffff
b.aim+=a
if (b.firecd==0 and abs(b.aim-target)<.1 and b.flipx)comb_boat_fire_projectile(b)
end
if b.flashing<=0 and enemy!=null then
if b.isPlayer and enemy.hp>0 then
if (aabbOverlap(b,enemy))hit(b,rrnd(12,17))sfx(61,3)
end
for t in all(tentacles)do
if (aabbOverlap(b,t))hit(b,rrnd(12,17))sfx(61,3)
end
end
if b.hp<=0 then
b.update=function(b)
b.y+=0.1
if not b.isPlayer and b.y>103 then
victory,txt_timer,currentcell.type,boat_message,npcBoat,victory_time,b.update,boatCell.type=true,0,"sea",sta"gLORIOUS\nVICTORY! ,eXCELLENT\nPIRATING MEN! ,s"[rnd_int"2"],0,time()+.01,function()b.y+=0.1 end,"sea"
score+=100
music"28"
if (endGame)music"29"score+=2500
end
end
if b.isPlayer then
sfx(58,3)
boat_message,txt_timer,b._draw,b.draw="abandon ship!",0,comb_boat.draw,function(b)
b._draw(b)
if b.y>100 then
print_str('47414d45204f564552',30,40,8)
end
if b.y>105 then
print_str('596f75722063726577206162616e646f6e6564',8,56,7)
print_str('7468652073696e6b696e672073686970',20,64,7)
end
if b.y>115 then
print_str('596f752077657265206e6f74',28,80,7)
print_str('736f20636f776172646c79',32,88,7)
end
end
end
end
b.vx*=.95
b.x,j=mid(0,b.x+b.vx,120),0
for i=3,5 do
j+=pt(b.x+i)
end
b.y=j/3+90
if (b.isPlayer==null)b.y-=20
end,
draw=function(b)
dmgFlash(b)
pal(1,0)
local s=1
if (b.isPlayer)s=0
if b.isPlayer!=null then
spr(s,b.x,b.y,1,1,b.flipx,false)
else
sspr(113,72,15,16,b.x,b.y,30,32,b.flipx)
end
pal()
if (b.firecd>0.9 and b.firecd<1.3 and b.isPlayer!=null)_circfill(b.x+4,b.y+5,1,b.firecd*25)
end
}
end
function cannonLines(x0,y0,b)
local c=11
if (b.firecd>0)c=5
if (b.isPlayer==null)x0+=12 y0+=18
for x=0,84,2 do
local y=y0+(x^2-b.aim*80*x)/32
local _x=x
if (b.flipx)_x*=0xffff
if (y<103)_pset(x0+_x,y,c)
end
end
function fireProjectile(_x,_y,_left,_r,_vx,_vy,_owner)
add(comb_objs,{
x0=_x,y0=_y,x=_x,y=_y,r=_r,owner=_owner,
w=_r*2,h=_r*2,
t=0,
vx=1.32+abs(_vx),vy=_vy,
left=_left,
x2=0,y2=-64,
x1=0,y1=-64,
update=function(p)
p.t+=.66
if (p.left)p.x-=p.vx*2
p.x+=p.vx
p.y=p.y0-(p.vy*5*p.t)+(.125*p.t^2)
if p.y>102 then
del(comb_objs,p)
sfx"63"
for i=p.x+15,p.x+17 do
wpts[mid(1,flr(i),160)]-=10
end
end
local b=p.owner.isPlayer
if b and enemy!=null then
for t in all(tentacles)do
if aabbOverlap(t,p)then
del(comb_objs,p)
hit(enemy,rrnd(6,11))
sfx"62"
sfx"63"
end
end
if aabbOverlap(enemy,p)then
del(comb_objs,p)
hit(enemy,rrnd(12,18))
sfx"62"
sfx"63"
end
elseif not b then
if aabbOverlap(comb_boat,p)then
del(comb_objs,p)
hit(comb_boat,rrnd(10,14))
sfx"62"
sfx"63"
end
end
end,
draw=function(p)
local r,x,x1,y,y1=p.r-1,p.x,p.x1,p.y,p.y1
if p.owner.steps==null then
_circfill(p.x2,p.y2,r,7)
_circfill((x1+p.x2)/2,(y1+p.y2)/2,r,10)
_circfill(x1,y1,r,9)
_circfill((x+x1)/2,(y1+y)/2,r,8)
end
_circfill(x,y,p.r,0)
p.x2,p.y2=x1,y1
p.x1,p.y1=x,y
end})
end
function dmgFlash(e)
e.flashing-=1
if (time()%.01>.005 and e.flashing>0)pal_all"7"
end
function hit(this,dmg)
flip""
if (endGame and not this.isPlayer)dmg/=3
this.hp,this.flashing,shakeTimer=max(0,this.hp-dmg),10,1
if this.isPlayer then
morale,this.flashing,playerHpTimer=this.hp,25,2
else
enemyHpTimer=2
end
end
function _flip()
if (tempFlip)flip""
end
function _circfill(x,y,r,c)
_flip""
circfill(x,y,r,c)
end
function _pset(x,y,c)
_flip""
pset(x,y,c)
end
function _line(x1,y1,x2,y2,c)
_flip""
line(x1,y1,x2,y2,c)
end
function _rect(x1,y1,x2,y2,c)
_flip""
rect(x1,y1,x2,y2,c)
end
function _rectfill(x1,y1,x2,y2,c)
if (tempFlip)flip""
rectfill(x1,y1,x2,y2,c)
end
function _sspr(sx,sy,sw,sh,dx,dy)
_flip""
sspr(sx,sy,sw,sh,dx,dy)
end
function init_island_chest_view()
camera(0,0)
poke(0x5f2c,3)
music"1"
camx,camy,sand,staticSand,chestClouds,circTrans_start,circTrans_end,sandIndex,chestPos,chestCol,chestCols=0,0,{},{},{},time(),0,1,53,currentcell.treasure*2-1,{sta"8,9,10,2,4,5,1,’",
sta"13,4,9,1,2,2,1,’",
sta"3,9,10,1,4,5,0,’",
sta"4,13,6,2,5,5,1,’"
}
if (chestCol==2 and compass_chunks>2)chestCol=3
if (chestCol==1)extra_canons+=1
if (chestCol==2)compass_chunks+=1
if (chestCol<4)morale=min(morale+20,100)
for i=0,15 do
add(chestClouds,{x=rnd"72",y=rnd"4",r=rrnd(1,4)})
end
for _x=4,62 do
for _y=56,64,4 do
add(staticSand,{x=_x,y=_y-_x*.15})
end
end
srand"3"
for y=0,3,.5 do
for x=0,9,.5 do
add(sand,{x=25+x,y=53+y,vx=0,vy=0,r=rrnd(2,5)})
end
end
end
function circTransition(x,y,t)
for i=72,t-16,-1 do
for j=-1,1 do
circ(x,y+j,i,0)
end
end
end
function update_island_chest_view()
if flr(chestPos)>44 and btnp(5)then
sfx(56-rnd"2")
for i=0,11 do
if sandIndex<#sand+1 then
circTrans_end,grain=time()+2,sand[sandIndex]
grain.vy-=rrnd(4,6)
grain.vx=rrnd(.5,1.5)
grain.r-=1.5
if (halfprob())grain.vx*=0xffff
sandIndex+=1
chestPos-=0.1
if flr(chestPos)==44 then
score+=(chestCol-1)*35
if chestCol<4 then
sfx"57"
else
sfx"59"
end
end
end
end
end
end
function draw_island_chest_view()
cls"12"
for c in all(chestClouds)do
c.x+=c.r*.05
_circfill((c.x-3)%72,c.y,c.r,7)
end
_rectfill(0,28,127,127,1)
local w=4+sin(time()*.5)*2.5
for i=1,3 do
pal(15,sta"7,13,15,s"[i])
for s in all(staticSand)do
_circfill(s.x,s.y,9+({w+1,w,0})[i],15)
end
end
for i=1,7 do
pal(chestCols[1][i],chestCols[chestCol][i])
end
if flr(chestPos)==44 then
sspr(32,34,18,13,23,chestPos-6,18,13)
pal()
firstChest=false
print_u(sta" yOU FOUND\nANOTHER CANNON!,yOU FOUND A BIT\n OF A COMPASS!,yOU FOUND SOME\n TREASURE!, bAH! iT'S\nempty!,s"[chestCol],4,15,10,0)

if (chestCol==1)pal(11,0)_sspr(57,42,14,16,26,29)
if (chestCol==2)_sspr(72,40,13,14,23,29)
if (chestCol==3)_sspr(50,34,12,5,24,39)
else
_sspr(32,47,15,11,23-sin(chestPos/1.5)*.5,chestPos-4)
pal()
for s in all(sand)do
if (s.vx!=0)s.r-=0.1 s.vy+=0.5
s.x+=s.vx
s.y+=s.vy
circfill(s.x,s.y,s.r,15)
end
if(time()%.5>.25 and firstChest)print_u("dIG! —",18,16,10)
end

if flr(chestPos)==44 then
circTransition(32,32,128+(circTrans_end-time())*50)
if circTrans_end-time()<-2.5 then
cls"0"
poke(0x5f2c,0)music"63"
nextState,state,st_t,boat_message,currentcell.treasure=1,2,1,"",0
end
else
circTransition(32,32,(time()-circTrans_start)*50)
end
end
function boat_update(b)
local speed,c,s=.05,cos(b.r),sin(b.r)
b.mx+=cellwindy*.05
b.my-=cellwindx*.05
if b.player then
if(btn"0")b.r=b.r%1+.01
if(btn"1")b.r=b.r%1-.01
if btn"2" then
b.mx+=s*speed
b.my-=c*speed
sfx(49,3)
else
b.mx*=.99
b.my*=.99
end
else
local px,py=boat.x+boat.mx*5,boat.y+boat.my*5
local angle=atan2(b.x-px,b.y-py)+enemyAngleOffset
dist,b.r=sqrt(abs(((b.y-boat.y)/100)^2+((b.x-boat.x)/100)^2)),lerp(b.r,angle+.5,.1)
if dist>4 and compass_chunks<3 then
npcBoat=0
return
else
b.mx+=s*speed*5
b.my-=c*speed*5
end
end
b.mx,b.my=mid(-b.max,b.mx,b.max),mid(-b.max,b.my,b.max)
b.d+=abs(b.mx*b.my)
if (flr(b.d)>2)newWave(b.x-sin(b.r)*4,b.y+cos(b.r)*4)b.d=0
if b.player or celltype!="island" then
b.x,b.y=flr((b.x+b.mx)*2)/2,flr((b.y+b.my)*2)/2
end
if b.player then
if b.x<camx+56 then
camx=flr(b.x-56)
elseif b.x>camx+72 then
camx=flr(b.x-72)
end
if b.y<camy+56 then
camy=flr(b.y-56)
elseif b.y>camy+72 then
camy=flr(b.y-72)
end
if checklandcol(b.x,b.y,b.r)and not player_draw then
sfx"52"
player_draw,player_x,player_y,b.mx,b.my=true,b.x+sin(b.r)*8,b.y-cos(b.r)*8,0,0
end
end
end
function boat_draw(b)
if time()%.25==0 then
newWave(b.x-sin(b.r)*4,b.y+cos(b.r)*4)
end
pal(0,5)
if not b.player then
pal(4,2)pal(15,6)pal(7,13)pal(9,15)
if dist<.25 then
nextState,state,st_t,boat_message,dist=5,2,0,"",512 music"10"
if (compass_chunks>2)music"19"
end
end
spr_rot(-2,76,12,flr(b.x),flr(b.y),b.r,6,b.player==null)
pal()
end
function minimapPos(boat_obj,c)
_pset(camx+lerp(111,127,minimapLerpVal(boat_obj.x)),camy+lerp(1,16,minimapLerpVal(boat_obj.y)),c)
end
function minimapLerpVal(value)
return mid(0,(value+256)/512,1)
end
function draw_morale_bar()
print_str('4d6f72616c65a',camx+1,camy+11,7)
local x,y=camx+42,camy+1
local _x,l,_l,_y=x+57,lerp(57,0,morale/100),lerp(57,0,prevMorale/100),y+10
if playerHpTimer>0 then
playerHpTimer=max(0,playerHpTimer-.1)
if (playerHpTimer<=1)_l=lerp(l,_l,playerHpTimer)
else
prevMorale,_l=morale,l
end
_rectfill(x,y,_x,_y+1,1)
_rectfill(x,y,_x-_l,_y,14)
_rectfill(x+1,y+1,_x-l,_y-1,8)
_rect(x,y,_x-_l,_y-1,2)
_rect(x,y,_x,_y,7)
end
__gfx__
0040000000040000000000007000000000000007000c00000000000011000000000000000000000000000000011111000010001000000000000000000000000d
777700000767000000070000000000000000000000ccc000000000811000000000000000000000000000000011111110001011111000000000000000000000df
07777000007670000077700000000006600000000ccccc00000008890000000000000000000000000000000100001111001111111100000000000000000000df
07777000006767000777770000000066660000000111110000008c888000000000000000000002000004400000000111011000011110000000000000000000df
7777000006767000011111000000066666600000000000000000cc88800000000000000000002200000440000000011110100000111100000000000000000ddf
40400440200400220000000000006666666600000000000000044e98002000000023400000022650000040000000011100100000011110000000000000000dff
41414400221212200000000000000066660000000000000000046ffd422200222277772220026777754400000000111100100000001110000000000000000dff
44444000222222000000000000000066660000000000000000467ffd722220024537777200277277755100000001011100100000001110000000000000000dff
01249af777fa00000777770000000066660000000000000000246fbb022200065510776400577200115100000110011100110000011110000000000000000ddf
012499aaa99000000177710000000066660000000ccccc00000467b10020000475102764005772000511000011100111001011111011100000000000000000df
000000000000000000171000000000666600000001ccc100000467b10000000475102264405772004111000111110111001000000011100000000000000000df
0000000000000000000100000000006666000000001c1000000467b10000000677102260005772044551000001111111001000000011100000000000000000df
000000000000000000000000000000666600000000010000000467b1000000265530662000577604455500000011111100100000001110000000000000000ddf
000000000000000000000000000000000000000000000000000467b1000000265516222000577640455500000000111100101111101110000000000000000dff
000000000000000000000000000000000000000000000000000467b1000002265550222000177600055500000000111100110000011110000000000000000dff
00000000000000000000000070000000000000070000000000046731000002265510222000133600055500000000011100100000001110000000000000000dff
000000000000000000000000000000000000000000220000000467b1000002265510222000137200055500000000011100100000001110000000000000000ddf
aae5fba057770008eff908ff7daa0bffd9005dddd046617760046fb9010002267512222401173300055500000000011100100000001110000000000000000dff
0e501e088528d804d284008700f00c708500e14ad00632060046effbd20002677775327221377775251000000001111100111100001100000000000000000dff
06b3b60085f580050a04000f6e10007d4000a3d2a007023700046fff200000226755772000467777500000000111111100111111101000000000000000000dff
070816008d28900582850007807040b04e00a1e8a0070027000004b0000000020041020004000215000000011111111100111111110000000000000000000ddf
23edf320df7b8008dfd8007ff9600ffffb023dde2222755200000000000000000000000000000040000000110000011100100001100000000000000000000dff
10000000000000022004400000060000001000000000000020000000000000000000000000000000000000000000011100100000000000000000000000000dff
88000000000000000000000088800000000088800000000000000000000022000000000022200022200000000000011100100000000000000000000000000dff
2aa750aaa008801777740000008e73b9800006ff753aa80001bbffdd100006755555720004665157400000000000011100100000000000000000000000000ddf
02e9550a00009d40aa9d48800049e6090004512a845380000097208d1000062354037000006720070000000000000111110000000000000000000000000000df
06f8114b100008817e9140800459a2c00000006f90691000001768801000022354023000007720060000000000000000000000000000000000000000000000df
467993b6000008817fd400804551aa040000006fd68110000013ec500000020374302000017522060000000000000000000000000000080000000000000000df
067aa19640000089f69908000451aa0440000067be011000001bb154000002037530200000752217000000000000000000000000000008000000000000000ddf
07608817000000097609900004592a840000006798710000001fa010600002017610200000750227000000000000000000000000000088800000000000000dff
03608853000000097619800000c12ac0100000679871000000db200c20000201760020000065022700000000000000000000000000005d800000000000000dff
133ecdb33000009ff7f88800088c77d90000047ff9960000019ffffb310022255542220002265572000000000000000000000000000055500000000000000dff
2000000000000000000000000000200c400002000000600000200000000000100000000000000002000000000000000000000000000005000000000000000ddf
000000000000000000000000022200008800000000000660000000000000000000000000000000002200000000000000000000000000050000000000000000df
0000000000000222220000000000002000000999999999994000007c0007c00000000000000000000000000000000000000000000000000000000000000000df
00000000000228888822000000000288000095555555555924008cb9a07a8a0000000000000000000000000000000000000000000000000000000000000000df
0000000002288882828820000000028e00095555555555922407b9a897c9ab000000000000000000000000000000000000000000000000000000000000000ddf
00000000288888882888820000000288009999999999999224c9ac797a9ac9000000000000000000000000000000000000000000000000000000000000000dff
0000000288888882828882000000028e0a11111111111144409b7a9c9ba990000000000000000000000000000000000000000000000000000000000000000dff
00000029888888288888820000000288a11111111111144000000000000000000000000000000000000000000000000000000000000000000000000000000dff
0000002a98888888888882000000028eaaaaaaaaaaa94240000000000000000000000000000000000000000000ddd00000000ddddd00000000ddddd000000ddf
00000029a98889999888820000000288a222a11922292240000000000000000000000000000000000000000000677dd0000dd77677dd0000dd77677dd0000dff
0000002898889aaa988882000000028ea288a119288922400000000000000000bbbb000000000000000000000067777d00d777767777d00d777767777d000dff
00000028888899998888200000000288a2888992888922400000000000000005bbbbbb0000000000000000000077767d00d767777767d00d767777767d000dff
0000002888888888888820000000028ea28888888889224000000000000000055bbbbbb0000000000000000000777777dd77777777777dd77777777777d00ddf
00000028888888888882000000000288a288888888892400000000000000000bdbbbbb00000000000000000000777777dd77777777777dd77777777777d000df
0000002888888888882820000000028ea999999999994000000000000000000bbd55550000000077766d000000d77766dd66777d77766dd66777d77766d000df
0000028888888888228820000000028800aaaaaaaaaaa90088000008000000b5bbbb000000000777777d000000777777d5dd666777777dd77777777777d00ddf
0000288888888822882882000000028e0a222222222292488880008880000bb5bbbb000000000777777d000000777777d000000777777dd77777777777d00ddf
00028888888882882828820000000288a2888888888922418888088880000b5bbbb000000000077767d500000077767d500000077767d55d767777767d500dff
0028882288288288282882000000028ea2888aa288892440188888881000bb5bbbb000000000067777d500000067777d500000067777d55d777767777d500dff
02888288882882882822882280000288aaaaa1199999424001888881000bbbb5bbb0000000000677dd50000000677dd50000000677dd5005dd77677dd5000dff
0288288222888828288228888000028ea222a1192229224008888810000bbb5bbb00000000000ddd5500000000ddd5500000000ddd55000055ddddd550000000
02828820028888288288828820000288a288a1192889224088888880000b5bbbbb00000000000555000000000055500000000005550000000055555000000000
2882882028828882882888220028028ea2888992888922488881888800bbdbd5bb00000000000000000000000000000000000000000000000000000000000000
28882882282028882882888822882288a2888888888922488810188880bb5bbbb000000000000000000000000000000000000000000000000000000000000000
0288828288200288828828888882028ea288888888892401810001881bb55bbbb000000000000000000000000000000000000000000000000000000000000000
00282882820022882882022222200288a99999999999400010000011000000000000000000000000000000000000000000000000000000000000000000000000
0ddddd000ddddd0000000ddddddddddddddddddddd000ddddddddd000ddddd0000000ddddd0000000ddddddddd000ddddd000000000000000000000000000000
ddfffdddddfffdddd0ddddfffdfffdfffdfffdfffdddddfffdfffdddddfffdddd0ddddfffdddd0ddddfffdfffdddddfffdddd0ddd00000000000000000000000
dffffffffffffffffdfffffffffffffffffffffffffffffffffffffffffffffffdfffffffffffdfffffffffffffffffffffffdfffd0000000000000000000000
fff000ffffff00ffff000ffffff0000ffff000fffff00fff000ff000000ff00000ffff00fff00ff0ffffffff0fff000ffffffff0ffffff000000000000000000
0f00000f00f00f0000f0f00f00f000f000ff000f000f00ff000f00000000f0000f0000f00f0000f00f00f00f00f00000f00f00f00f0000f00000000000000000
00f000f000f0f00000f0000f00000f00000ff00f000f000f000f00000000f000f00000f00f0000f00f00f000000f000f000f00000f00000f0000000000000000
00f000f000f0f0000000000f0000f0000000f00f000f000f00f00000000fff00f00000000f0000f00f00f000000f000f000f00000f00000f0000000000000000
00f000f000f0f0000000000f0000f0000000f00f000f0000f0f00000000f0f00f00000000f0000f00f00f00f000f000f000f00f00f00000f0000000000000000
00f00f0000f0f0000000000f0000f0000000f00f00f00000ff000000000f0f00f00000000ffffff00f00ffff000f00f0000ffff00f00000f0000000000000000
000f0f0000f0f0000000000f0000f0000000f00fff000000ff00000000f00f00f00000000f0000f00f00f00f0000f0f0000f00f00f00000f0000000000000000
000f0f0000f0f0000000000f0000f0000000f00f0ff000000f00000000fffff0f00000000f0000f00f00f0000000f0f0000f00000f00000f0000000000000000
000f0f0000f0f0000000000f0000f0000000f00f00ff00000f00000000f000f0f00000000f0000f00f00f0000000f0f0000f00000f00000f0000000000000000
0000f00000f0ff0000f0000f00000f000000f00f00ff00000f00000000f000f0ff0000f00f0000f00f00f000f0000f00000f000f0f00000f0000000000000000
0000f00000f00f0000f0000f000000f0000f000f000ff0000f0000000f0000ff0f0000f00f0000f00f00f00f00000f00000f00f00f0000f00000000000000000
0000f0000fff00ffff00000ff000000ffff0000f0000f000ff000000ff0000ff00ffff00fff00fffffffffff00000f0000fffff0ffffff000000040000000000
00000000000000000000000000000000000000f0f000ff0000000000000000000000000000000000000000000000000000000000000000000006767000000000
000000000000000000000000000000000000000000000ff000000000000000000000000000000000000000000000000000000000000000000000676700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000767600000000
00000000000000000000000000004000000000004000000000000000000000000000000000000000000000000000000000000000000000000007676000000000
00000000000000004000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000040000
0004440000000004f400000000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000007676700767000
000444000000004fff40000000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000767670076700
000444000000004fff40000000400040000000000000000000077700000000007000000000000000000000000000000000000000000400000000676760067600
000444000000004fff40000000404040000000004000000000004000000000004000000000000000000000000000000000000000076700000000767670076700
000444000000004fff40000000400040000000000000000000000000000000000000000000000000000000000000000000000000007670000227676700767000
000444000000004fff40000000400040000000000000000000777770000000777770000000000000000000000000000000000000006767000222040000040022
000444000000004fff40000000404040000000404040000000004000000000004000000000004000000000000000000000000000067670000222121212121220
000444000000004fff40000000490940000000400040000000000000000000000000000000000000000000000000000000000000200400220222222222222200
00044400000000444440000000499940000000400040000000000000000000000000000000000000000000000000000000000000221212200222222222222000
00000000000000044400000000044400000000044400000000000000000000000000000000000000000000000000000000000000222222000022222222220000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000767670000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000076767000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067676000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000076767000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000767670004000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000076700000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000076700007670000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007670006760000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006760007670000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022067600076700000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022204000004002200000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022212121212122000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222222220000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222222200000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002222222222000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000100000000000000000000000001000000000200000000000000000000000000000000000000000074800000000074800000000000000000000000000000000000000000
__map__
cccccccccccccccc040444ccd4cccccccccccccccccccccccccccccccccccccccccccccccc2ce8cc82c1cccc2ce8828888888822888228cc2c88cccc82c8cccc11111111111111111111111111111111111111111111111111111111111111111111c111c111181182c111711228878188111118128128112c18c1cc1ce81c11
11111111111111111111111111111111111111111111111111111111111111111111111171111e1171111111117111111111111811111111711771111711111111111111111111111111111111111111111111111111111111111111111111111111111111111711111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
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
010a06080c1700c1500c1350c1750c1750c1750c1700c1700c1000c1050c1000c1050c1000c1050c1000c1000c1000c1050c1000c1050c1000c1050c1000c1050c1000c105001000010000100001000010000100
010a00013c2100c1050c1000c1050c1000c1050c1000c1000c1000c1050c1000c1050c1000c1050c1000c1050c1000c1050010000100001000010000100001000010000000000000000000000000000000000000
000a06080c0700c0500c0350c0750c0750c0750c0700c0700c0000c0050c0000c0050c0000c0050c0000c0000c0000c0050c0000c0050c0000c0050c0000c0050c0000c005000000000000000000000000000000
010100001335110371233013e0013f0013f0013f0013c001340012b001230011b001120010d0010c0010c0010d00111001160011b001230012d0013300133001310012e00128001230011c001000010000100000
000a00010c17000100001000010500100001050010000100001000010500100001050010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
011906080c1700c1500c1350c1750c1750c1750c1700c1700c1000c1050c1000c1050c1000c1050c1000c1000c1000c1050c1000c1050c1000c1050c1000c1050c1000c105001000010000100001000010000100
003d00200a6000f601156011c6012c6013160131601236011b6010d6010d6010c6010b6010a601096010860107601096010b6010160106601076010f601186011c60125601256011c60116601126010d60109601
000200203c6103b6103c6103b6103c6103b6103c6103b6103c6103b6103c6103b6103c6103b6103c6103b6103c6103b6103c6103b6103c6103b6103c6103b6103c6103b6103c6103b6103c6103b6103c6103b610
011400200f8300f8200f8100fc350fc250fc150fc300fc250fc150fc350fc250fc150cc300cc250cc150c8300c8200c8100cc350cc250cc150c8300c8200c8100f8000f8000f8000310503105031050310003105
0114002022a1022a1022a1516015160151601516010160151601516015160151601518010180151801524a1524a1024a1518015180151801524a1524a1024a1526b0026b0026b051a0051a0051a0051a0001a005
0114002011830118201181011c3511c2511c1513c3013c2513c1513c3513c2513c1514c3014c2514c1514830148201481016c3516c2516c151683016820168100f8000f8000f8000310503105031050310003105
010f000003f0004f0103f0103f0105f0104f0102f0104f0104f0103f0102f0104f0105f0104f0103f0104f0105f0103f0101f0103f0105f0105f0103f0103f0105f0105f0105f0104f0104f0106f0106f0105f01
0114002011830118201181011c3511c2511c1511c3011c2511c1511c3511c2511c1514c3014c2514c1514830148201481016c3516c2516c151683016820168100f8000f8000f8000310503105031050310003105
0114002024a1024a1024a1518015180151801516010160151601516015160151601518010180151801524a1524a1024a151b0151b0151b01526a1526a1026a1526b0026b0026b051a0051a0051a0051a0001a005
011400201b5401b5311b5211b5111b5121b5121b51514715167151b7151f7151b715225402253122521225112251222512225151f7151b71520540205111f5400750007501075010750107501075010750107500
011400202054020531205212051120512205122051514715167151b7151f7151b715185401853118521185111851218512185151f7151b7151671514715137150b4030e40310403104030b4030a4030940300000
011400200f8300f8200f8100fc350fc250fc150fc300fc250fc150fc350fc250fc1508c3008c2508c1508830088200881008c3508c2508c150883008820088100f8000f8000f8000310503105031050310003105
0114002022a1022a1022a1516015160151601516010160151601516015160151601518010180151801524a1524a1024a1518015180151801524a1524a1024a1526b0026b0026b051a0051a0051a0051a0001a005
011400201654016531165211651116512165151371514715167151b5401b53124540245402453124521245112451224512245151f7151b7152654026511275400750007501075010750107501075010750107500
011400200f8300f8200f8100fc350fc250fc150fc300fc250fc150fc350fc250fc1508c3008c2508c1508830088200881008c3508c2508c150883008820088100f8000f8000f8000310503105031050310003105
0114002022a1022a1022a1516015160151601516010160151601516015160151601518010180151801524a1524a1024a1518015180151801524a1524a1024a1526b0026b0026b051a0051a0051a0051a0001a005
011400201b5401b5311b5211b5111b5121b5121b5151b5001b5001b50000000000002454024531245212451124512245122451524500245002654026511275450750007501075010750107501075010750107500
011400201371514715167151b7151f7151b7151371514715167151b7151f7151b7151371514715167151b7151f7151b715207151f7151b7151671514715137150000500005000050000500005000050000500005
011400200b8300b8200b8100bc350bc250bc150bc300bc250bc150bc350bc250bc150dc300dc250dc150d8300d8200d8100dc350dc250dc150d8300d8200d8100f8000f8000f8000310503105031050310003105
0114002022a1022a1022a151601516015160151401014015140151401514015140151201012015120151ea151ea101ea151101511015110151da151da101da1526b0026b0026b051a0051a0051a0051a0001a005
011400202254022531225212251122512225121b5401b5311b5211b5121b51220540205312052120511205122051220512205151d715197151471512715165401650016501165011650216502075000750107501
010a00202471525715267152771524015250152601527015243152531526315273152441525415264152741524215252152621527215242152521526215272152421525215262152721524215252152621527215
010900002420425204262042720424204252042620427204243142531426314273142431425314263142731424414254142641427414244142541426414274142421425214262142721424214252142621427214
010900000cc440cc450cc440cc450cc440cc450cc440cc450cc440cc450cc440cc450cc440cc450cc440cc450cc440cc450cc440cc450cc440cc450cc440cc450fc440dc410ac3109c3108c2105c2104c1101c11
010e00000c0530cc6400c650cc650c0530cc640cc650cc650c0530cc640cc650cc650c0530dc640dc6501c650c0530cc640cc650cc650c0530cc640cc650cc650c0530ac640ac650ac650c0530ac6400c650ac65
000e000018605317051f7331875330705187430c70018743337053070518743327053370530705187431874330705317051f7231874330705187430c700187433370518723187433270533705187231873318743
010e000018605317051f73318753246151a7430c7001b743337053070518743327052461530705187431974330705317051f7231874324615187430c7001874333705187231b7433270524615187231a7331b743
010e000030915249151f73318753246151a7432e9151b74327915309151874330915246152d914187431974328915319151f7231874324615187432f9141874327915187231b7432491524615187231a7332a915
010e00000c0530fc6403c650fc650c0530fc640fc650fc650c0530fc640fc650fc650c05310c6410c6504c650c0530fc640fc650fc650c0530fc640fc650fc650c0530dc640dc650dc650c0530dc6401c650dc65
010e0000227151871721715147141b715257171f715197152971523717287151e7141b7151c717267151f715187151e71727715207141e715177171a71523715177151c71717715217142371518717217151d715
010e00000c0530cc6400c650cc650c0530cc640cc650cc650c0530cc640cc650cc650c0530dc640dc6501c650c05308c6408c6508c650c05308c6408c6508c650c0530ac640ac650fc650c0530ac6400c650ac64
010e00000c5200c5200c5220c52513520135201352013520135201351213512135150f5200f5220f5150e5200f5200f5220f5220f525165201652016520165221652216522165111651516520165221552014530
010e00001252012520125220a5220a5200a5200a5220a525165201652016520165201652216512165151b7221c7201c7201c7201a7201b7101d720207151e7201d7101c7201b7161972017710157161671022725
010e00001952019520195220f5220f5200f5200f5220f5250f5200f5200f5200f5200f5220f5120f5151c7122871028710287102671027710297102c7152a710297102871027716257102371021716227102e715
011400202254022531225212251122512225121b5401b5311b5211b5121b51220540205312052120511205122051220512205151d715197151471512715117151650016501165011650216502075000750107501
010e00000c0530bc6400c650bc650c0530bc640bc650bc650c0530dc640dc650dc650c0530dc640dc6501c650c0530fc640fc650fc650c0530fc640fc650fc650c05303c6403c6503c650c0530fc640fc650fc65
010e00001c5101c5101c5121a5101b5101d510205101e5101c5101c5101c5121c5121a5101a5101a5121b5111b5101b5101b5101b5101b5101b5101b5101b5101b5151c7101b7161971017710157161671022715
010a0000087450c7450f74514745187451b745207450a7450e74511745167451a7451d745227450c7451074513745187451c7451f745247452873028721287112871128711287112871228712287150000500005
010a000000000087150c7140f71514734187351b734207350a7140e71511714167351a7341d725227250c7151071413715187341c7351f7342473024731247112471124711247112471124711247150000500005
0132000c1173011721117151273012721127151473014721147151b7301b7211b715197051470512705117051270514705197051d705197051470512705117051270514705197051d7051970514705127050c000
019600070d5300d5110d5300d5111453014511145151450014501145052160019600106000b6000a6000a6000b6000f6001460019600216002b60031600316002f60000000000000000000000000000000000000
013200180dd400dd410dd410dc250dc350dc450bd400bd410bd410bc250bc350bc350ad400ad410ad410ac250ac350ac4509d4009d4109d410bd400bd410bd4133d0031d012ed0128d0123d011cd010cd010cd01
016400090d5120d5120d5120d5120d5120d5121451214512145120d5020d5020d5020d5020d5020d5021450214502145020b5020f5021450219502215022b50231502315022f5020050200502005020050200502
000a00003565329650186500060100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
0004000004610066101f6001d6001d6001c6001c60000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00010000066100565007610346001f600236003e6003f6003f6003f6003c600346002b600236001b600126000d6000c6000c6000d60011600166001b600236002d6003360033600316002e60028600236001c600
00010000060100505007050340001f000230003e0003f0003f0003f0003c000340002b000230001b000120000d0000c0000c0000d00011000160001b000230002d0003300033000310002e00028000230001c000
000200000c1500f150101500a15012100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200000c1500f150101501515012100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0003000014753187531475309703187001870018700187001870318703187031b7030070300703007032770300703007030070300703007030070300703007030070300703007030070300703007030070300703
00040000137531c753107530070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
003d00200a6100f611156111c6112c6113161131611236111b6110d6110d6110c6110b6110a621096110861107611096110b6110161106611076110f611186111c61125611256111c61116611126110d61109611
000c0000205551b5551d55521555005001b5552655500505005050050500500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000400003132534355323752f3752b375253751f37517365113550d345253252835526375233751f37519375133750b3650535501345193251c3551a37517375133750d375073750530504305000000000000000
00060000071510815006150011500115001150111000f1000f1000d1000d1000c1000c1000c1000c100101000d1000c1000b1000e10010100101000b1000a100091000b1000b1000b10008100051000410003100
000100001335110371213012f3012e301133011a3013a3012f301113011a3013f3011330125301293012e3013030131301313012b301123010c3010b3010c3010e3010030112301163011930118301133010c301
000400003115334153321532f1532b153251531f15317153111530d1430b1330e1231211300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103
000400003142334453324732f4732b473254731f47317463114530d4430b4330e423124131540314403104030d4030c4030b4030e40310403104030b4030a403094030b4030b4030b40308403054030440303403
0003000016b701db701bb6017b600ab500db5013b4019b4008b300bb3013b2018b200cb1014b102bb0022b001ab0019b0019b001ab001cb001bb0018b0014b000fb000cb0009b0007b0006b0004b0000b0000b00
__music__
00 08 09 16 0b
00 0a 0d 16 0b
00 08 09 0e 0b
00 0a 0d 0f 0b
00 10 11 12 0b
00 17 18 19 0b
00 08 09 0e 0b
00 0a 0d 0f 0b
00 10 11 12 0b
02 17 18 27 0b
00 1a 1b 1c 44
00 1d 1e 43 44
00 1d 1e 43 44
01 1d 1f 43 44
00 1d 1f 43 44
00 1d 20 43 44
00 1d 20 43 44
00 21 20 43 44
02 21 20 43 44
00 1a 1b 1c 44
01 1d 20 22 44
00 1d 20 22 44
00 23 20 24 44
00 21 20 25 44
00 23 20 24 44
00 21 20 26 44
00 28 20 29 44
02 28 20 29 44
04 2a 2b 43 44
03 2c 2d 2f 2e
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 38 42 43 44
00 41 42 43 44
