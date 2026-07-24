pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--gifts on venus
--by trasevol_dog
-- to do:
-- - title
-- - title screen
-- - x-mas sprites
title_screen=true
function _init()
t=0
music(0,0,7)
init_objects(parse"obstacles,slashable,bombs,enemies,bullets,pickups,props,to_u,to_dr0,to_dr1,to_dr2,to_dr3,to_dr4")
init_anim_info()
create_player(0,0)
drk=parse"0=0,13=0,6=13,7=6"
txtposextra=parse"{x=0,y=3},{x=-1,y=2},{x=1,y=2},{x=-2,y=1},{x=2,y=1},{x=-2,y=0},{x=2,y=0},{x=-1,y=-1},{x=1,y=-1},{x=0,y=-2}"
superoutlinepos=parse"{x=-2,y=0},{x=-1,y=-1},{x=-1,y=1},{x=0,y=-2},{x=0,y=2},{x=1,y=-1},{x=1,y=1},{x=2,y=0}"
init_camera()
init_worlds()
progress,world,level,slainbomb=0,0,0,0
init_ship()
camx,camy,tut1=player.x-64,player.y-196,create_textpart(player.x,player.y,capitalize"^move with ‹‘”ƒ  ")
end
function _update()
t+=0.01
if title_screen then
if btnp(4) then title_screen = false end
return
elseif game_over then
if btn(4) and btn(5) then run() end
end
camx,camy=lerp(camx,player.x-64+20*player.vx,0.08),lerp(camy,player.y-68+20*player.vy,0.08)
u_shake()
u_objects()
if slainbomb>=0 then
slainbomb-=0.01
end
(tut1 or tut2 or {}).t = 45
end
function _draw()
xmod,ymod=camx+shkx,camy+shky
vxmod,vymod,lxmod,lymod=xmod-lxmod,ymod-lymod,xmod,ymod
cls()
if world==0 then
my_map((xmod-48*8)/4,ymod/4,8,8,2)
end
my_map(xmod,ymod,0,0,8)
dr_objects(0,2)
my_map(xmod,ymod+4,64,0)
camera(xmod,ymod)
dr_objects(3,4)
for s in group("enemies") do
if s.king then
local y=s.y-14+1.2*cos(s.animt*4)
local foo=function()
spr(89+s.king*16,s.x-4,y)
end
dr_outline(foo,0)
foo()
elseif s.carry then
local o=s.carry
o.animt,o.x,o.y=s.animt,s.x,s.y-9+flr(s.animt/0.08)%2
o:dr()
end
end
if player.state=="done" then
local x,y=player.x+80*(player.animt-0.5)*3,player.y-120*(1+sin(player.animt*0.5))
local foo=function()
--spr(110,x-13,y-6,2,1)
spr(110,x-8,y-6,2,1)
end
dr_outline(foo,0)
foo()
for i=0,3 do
for j=-6,6,12 do
cms(x+j,y,7,2+rnd(1),.75)
end
end
end
-- camera()
if progress==0 then
pal(1,0)
spr(128,400,-140+3.5*cos(t),12,8)
dr_text(capitalize"by ^t^r^a^s^e^v^o^l_^d^o^g",448,-70)
dr_text(capitalize"music by ^gruber",448,-60)
dr_text(capitalize"^pico-8 ^advent #24",448,-150)
end
camera()
if title_screen or dr_gui() then
if t%0.3<0.2 then
dr_text(capitalize"^prezz ^z/Ž to start ",64,112)
end
elseif game_over then
dr_text("g a m e  o v e r",64,48)
dr_text(capitalize"^final ^progress: "..flr(progress/0.13).."%",64,72)
if t%0.3<0.2 then
dr_text(capitalize"^hold ^z/Ž + ^x/— to try again ",64,96)
end
end
if btn(4,1) then
dr_debug()
end
end

--->8
-- * us *
function u_player(s)
s.animt+=0.01
s.idlet+=0.01
local spd,mov=1
if s.state=="done" then
if s.animt>1 then
--next level
next_level()
s.state="idle"
return
end
elseif btnp(4) and (s.state~="slash" or s.animt>0.09) then
local a=atan2((s.faceleft and -1 or 1)*max(abs(s.vx),0.01),s.vy)
s.state,s.animt,s.vx,s.vy="slash",0,4*cos(a),4*sin(a)
local cols=all_collide_objgroup(s,"slashable")
for col in all(cols) do
--if not col.dead then
col.dead,col.left=0,s.faceleft
--end
end
local ox,oy
for i=1,4 do
ox,oy=s.x,s.y
u_move(s)

local ow,oh=s.w,s.h
s.w,s.h=12,12
local cols=all_collide_objgroup(s,"slashable")
for col in all(cols) do
--if not col.dead then
col.dead,col.left=0,s.faceleft
--end
end
s.w,s.h=ow,oh
end
s.x,s.y,tut2=ox,oy,nil
s.vx*=0.5
s.vy*=0.5
add_shake(1.1)
sfx(44)
create_slash(lerp(ox,s.x,0.875),lerp(oy,s.y,0.875),s.faceleft)
end
local stp,stt,n=anim_step(s)
if s.state=="done" then
s.vx*=0.6
s.vy*=0.6
s.idlet=0
elseif not (s.state=="slash" and stp<2) then
if btn(0) then s.vx-=spd mov=true
elseif s.vx<0 then s.vx*=0.6 end
if btn(1) then s.vx+=spd mov=true
elseif s.vx>0 then s.vx*=0.6 end
if btn(2) then s.vy-=spd mov=true
elseif s.vy<0 then s.vy*=0.6 end
if btn(3) then s.vy+=spd mov=true
elseif s.vy>0 then s.vy*=0.6 end
local l=dist(s.vx,s.vy)
local rl=min(l,2)
s.vx,s.vy=s.vx/l*rl,s.vy/l*rl
end
u_move(s)
local col=collide_objgroup(s,"obstacles")
if col then
local a=atan2(col.x-s.x,col.y-s.y)
s.vx-=0.2*cos(a)
s.vy-=0.2*sin(a)
mov=true
end
if mov then
s.idlet=0
if tut1 then
tut1,tut2=nil,create_textpart(s.x,s.y,capitalize"^cut things with ^z/Ž ")
end
end
if s.hurt>0 then
s.hurt-=0.01
end
ostate=s.state
if group_count("bombs")==0 and not(s.state=="slash" and stp<3) then
s.state="done"
elseif s.hurt>0.2 then
s.state="hurt"
elseif s.state=="slash" and n<1 then
s.state="slash"
elseif abs(s.vx)+abs(s.vy)>0.5 then
s.state="run"
elseif s.idlet>1 then
s.state="bored"
else
s.state="idle"
end
if s.state~=ostate then
s.animt=0
if s.life<=0 then
for i=0,13 do
cms(s.x,s.y,7).r=rnd(5)
end
cdb(s.x,s.y,57,0,.5).out,game_over,s.state=true,true,"hurt"
deregister_object(s)
music(-1)
sfx(47)
elseif s.state=="done" then
for o in group("enemies") do
o.dead=0
end

for o in group("bullets") do
o.dead=1
end
end
end
if abs(s.vx)>0.01 then
s.faceleft=s.vx<0
end
end
function u_skull(s)
s.animt+=0.01
if s.carry then
s.carry:u()
if s.carry.timer and s.carry.timer<=0 then
s.carry = nil
end
end
if s.dead then
s.dead+=1
if s.dead>2 then
for i=1,8 do
cms(s.x,s.y,0,rnd(2))
end

local a=rnd(0.1)
cdb(s.x,s.y,79,a,0.5,-2,-2,true)
cdb(s.x,s.y,78,a+0.33,0.5,-2,-2,true)
cdb(s.x,s.y,77,a+0.66,0.5,-2,-2,true)

if s.king then
local sn=106+s.king*2
cdb(s.x,s.y,sn+1,a-0.05,0.5,-14,-2,true)
cdb(s.x,s.y,sn,a+0.45,0.5,-14,-2,true)
end

if s.carry then
local o=s.carry
deregister_object(o)
o.regs,o.x,o.y,o.z,o.vz=o.oregs,s.x,s.y,-8,-1
register_object(o)
end
sfx(45)
add_shake(2)
deregister_object(s)
end
return
end
s.movet-=0.01
s.aimt-=0.01
s.shott-=0.01
sides=parse"right,up,left,down"
if s.movet<=0 then
if chance(25) then
s.wx=0
s.wy=0
s.state=pick(sides)
else
local a=rnd1()
s.wx=0.5*cos(a)
s.wy=0.5*sin(a)
s.state=sides[flr((a+0.125)*4)%4+1]
end
s.movet=0.1+rnd(0.4)
end
if s.shott<=0.01 then
local dx,dy=abs(player.x-s.x),abs(player.y-s.y)
if dx<56 and dy<56 and not(dx<16 and dy<16) then
--shoot

local ii,jj=0,0
if s.king then
if s.king==0 then
ii=0.1
s.shott=0.3+rnd(0.4)
else--if s.king==1 then
jj=0.6
s.shott=0.4+rnd(0.3)
end
else
s.shott=0.15+rnd(0.85)
end

for j=-jj,jj,0.3 do
for i=-ii,ii,0.1 do
create_bullet(
s.x+2*cos(s.aima),
s.y+2*sin(s.aima),
s.aima+i,
1.2+rnd(0.3)+j
)
end
end

s.state,s.aimt=sides[flr((s.aima+0.125)*4)%4+1],0
sfx(42)
end
end
if s.aimt<=0 then
if abs(player.x-s.x)<96 and abs(player.y-s.y)<96 then
s.aima=atan2(player.x-s.x,player.y-s.y)
else
s.aima=rnd1()
end
s.aimt=0.05+rnd(2)
end
s.vx,s.vy=lerp(s.vx,s.wx,0.2),lerp(s.vy,s.wy,0.2)
local col=collide_objgroup(s,"obstacles")
if col then
local a=atan2(col.x-s.x,col.y-s.y)
s.vx-=0.2*cos(a)
s.vy-=0.2*sin(a)
mov=true
end
if chance(10) then cms(s.x,s.y-3,0,1) end

u_move(s)
end
function u_bullet(s)
s.animt+=0.01
if s.start>=0 then
s.start-=0.25
end
if s.dead then
s.dead-=0.34
if s.dead<=0 then
deregister_object(s)
end
return
end
s.x+=s.vx
s.y+=s.vy
local col=player.hurt<=0 and collide_objobj(s,player)
if col then
damage_player(s)
end
s.w,s.h=2,2
col=col or check_mapcol(s)
if col then
for i=1,3 do
cms(s.x,s.y,0)
end
s.dead=1
end
s.w,s.h=8,8
end
function damage_player(s)
local p=player
p.hurt=0.25
local a=atan2(p.x-s.x,p.y-s.y)
p.vx+=2*cos(a)
p.vy+=2*sin(a)
p.life-=1
sfx(43)
end
function u_move(s)
local nx=s.x+s.vx
local col=check_mapcol(s,nx)
if col then
local tx=flr((nx+col[1]*s.w*0.5)/8)
s.x=tx*8+4-col[1]*(8+s.w+0.5)*0.5
s.vy-=0.5*col[2]
else
s.x=nx
end
local ny=s.y+s.vy
local col=check_mapcol(s,s.x,ny)
if col then
local ty=flr((ny+col[2]*s.h*0.5)/8)
s.y=ty*8+4-col[2]*(8+s.h+0.5)*0.5
s.vx-=0.5*col[1]
else
s.y=ny
end
end
function check_mapcol(s,x,y)
local sx=x or s.x
local sy=y or s.y
local dirs={{-1,-1},{1,-1},{-1,1},{1,1}}
nirs=dirs
local res,b={0,0}
for k,d in pairs(dirs) do
local x=sx+s.w*0.5*d[1]
local y=sy+s.h*0.5*d[2]
if fmget(x/8,y/8,0) then
res[1]+=d[1]
res[2]+=d[2]
b=true
end
end
if res[1]~=0 then res[1]=sgn(res[1]) end
if res[2]~=0 then res[2]=sgn(res[2]) end
return b and res
end
function u_bomb(s)
s.animt+=0.01
if s.z then
s.z+=s.vz
if s.z>0 then
s.vz*=-0.8
s.z=0
end
s.vz+=0.25
end
if s.dead then
s.dead+=1
if s.dead>2 then
for i=1,8 do
cms(s.x,s.y,pick{6,7},rnd(2))
end

local a=rnd(0.1)-0.05
local ns=s.left and 58 or 60
cdb(s.x,s.y,ns,a,0.5,-2,-2,true)
cdb(s.x,s.y,ns+1,a+0.5,0.5,-2,-2,true)
cdb(s.x,s.y,62+frnd(2),nil,0.1,-2,-1,true)
add_shake(2)
deregister_object(s)
sfx(49)

slainbomb=0.3
end
elseif not game_over then
s.timer-=1
if s.timer<=0 then
cex(s.x,s.y,10)
add_shake(8)
deregister_object(s)
player.life,player.hurt=0,0.25
elseif s.timer<=3*60 then
s.animt+=0.01*flr(3-s.timer/60)
end
end
end
function u_pickup(s)
s.animt+=0.01
if s.z then
s.z+=s.vz
if s.z>0 then
s.vz*=-0.8
s.z=0
end
s.vz+=0.25
end
if s.dead then
s.dead+=1
if s.dead>2 then
for i=1,8 do
cms(s.x,s.y,pick{6,13},rnd(2))
end

local a=rnd(0.1)-0.05
local ns=s.left and 94 or 92
cdb(s.x,s.y,ns,a,0.5,-2,-2,true)
cdb(s.x,s.y,ns+1,a+0.5,0.5,-2,-2,true)

if player.life>=5 then
create_textpart(s.x,s.y,"max hp")
else
player.life+=1
create_textpart(s.x,s.y,"+1hp")
end
add_shake(2)
deregister_object(s)
sfx(49)
end
end
end
function u_prop(s)
if s.dead then
s.dead+=1
if s.dead>2 then
for i=1,8 do
cms(s.x,s.y,pick{0,6,13},rnd(2))
end

local a=rnd(0.1)-0.05+(s.faceleft and 0.5 or 0)
local ns=s.s+(((s.left and not s.faceleft) or (s.faceleft and not s.left)) and 3 or 1)
cdb(s.x,s.y,ns,a,0.5,-2,-2,true,s.faceleft)
cdb(s.x,s.y,ns+1,a+0.5,0.5,-2,-2,true,s.faceleft)

add_shake(2)
deregister_object(s)
sfx(49)
end
end
end
function u_hologram(s)
s.animt+=0.01
if s.dead then
s:ou()
if s.dead>2 then
if s.state=="heart" then
create_hologram(s.x,s.y,sk)
elseif s.state=="skull" then
create_hologram(s.x,s.y,create_bomb)
end
end
end
end
function u_boss(s)
s.x=16*8+20*sin(s.animt)
s.y=12*8+10*cos(s.animt*2)
if s.animt%1<0.01 and group_count"enemies"<5 then
for i=-2,2 do
sk(s.x+i*9,s.y+40-abs(i*8),pick(parse"1,2,4,4,5,5"))
cex(s.x,s.y+32,12)
end
end
s.try = false
if group_count"enemies"==1 and s.dead then
for i=0,19 do
local x,y=i%4-2,flr(i/4)-2
cdb(s.x+x*8,s.y+y*8,160+y*16+x).out=true
cex(s.x,s.y,14)
end
boss=sfx(46)
deregister_object(s)
elseif s.dead then
s.try,s.dead = true,false
end
s.animt+=0.01
end

function u_slash(s)
s.t+=0.01
local v=max(flr(s.t/0.025)-2,0)
if v>=3 then
deregister_object(s)
end
end
function u_smoke(s)
s.x+=s.vx
s.y+=s.vy
s.vx*=0.8
s.vy=lerp(s.vy,-1,0.2)
s.r-=0.1
if s.r<=0 then
deregister_object(s)
return
end
end
function u_debris(s)
s.z+=s.vz
s.x+=s.vx
if check_mapcol(s) then
s.x-=s.vx
s.vx=-s.vx
end
s.y+=s.vy
if check_mapcol(s) then
s.y-=s.vy
s.vy=-s.vy
end
if s.z>0 then
s.vx*=0.5
s.vy*=0.5
s.vz*=-0.8
s.z=0
end
s.vz+=0.25
s.l-=0.01
if s.l<0 then
deregister_object(s)
end
end
function u_animpart(s)
s.animt+=0.01
if s.vx then
s.x+=s.vx
s.y+=s.vy
end
local a,a,k=anim_step(s)
if k>=1 then
deregister_object(s)
end
end
function u_part(s)
s.x+=s.vx
s.y+=s.vy
s.z+=s.vz
if s.z>0 then
s.vx*=0.5
s.vy*=0.5
s.vz*=-0.8
s.z=0
end
s.vz+=0.25
s.l-=0.01
if s.l<0 then
deregister_object(s)
end
end
function u_textpart(s)
s.t+=1
s.y-=s.vy
s.vy*=0.9
if s.t>s.l then
deregister_object(s)
end
end

function add_shake(p)
local a=rnd1()
shkx+=p*cos(a)
shky+=p*sin(a)
end
function u_shake()
if abs(shkx)+abs(shky)<0.5 then
shkx,shky=0,0
else
shkx*=-0.5-rnd(0.2)
shky*=-0.5-rnd(0.2)
end
end

--->8
-- * drs *
function dr_self(s)
local state=s.state or "only"
da(s.x,s.y-2,s.name,state,s.animt,s.faceleft)
end
function dr_outlined_self(s,c0)
local sinfo=anim_info[s.name][s.state or "only"]
local spri,wid,hei,xflip=sinfo.sprites[flr(s.animt/sinfo.dt)%#sinfo.sprites+1],sinfo.width or 1,sinfo.height or 1,s.faceleft or false
local foo=function()
spr(spri,s.x-wid*4,s.y+(s.z or 0)-2-hei*4,wid,hei,xflip)
end
dr_outline(foo,c0 or 0)
pal(5,0)
foo()
end

function dr_player(s)
local don=s.state=="done"
if don and s.animt>0.5 then
return
end
if s.hurt>0 and s.hurt%0.04<0.02 then
return
end
--dr_self(s,0,0)
dr_outlined_self(s,0)
end
function dr_skull(s)
if s.dead then
local foo=function()
spr(90,s.x-4,s.y-6)
end
dr_outline(foo)
foo()
if boss then
circ(boss.x,boss.y,24,0)
end
else
dr_outlined_self(s,0)
end
if boss and boss.try then
circfill(s.x,s.y,6,7)
end
end
function dr_bullet(s)
local sp,b
if s.start>0 then
sp=68
elseif s.dead then
sp=73
else
local s=(s.animt/0.015)%8
sp=69+s%4
b=s>=4
end
local foo=function()
spr(sp,s.x-4,s.y-4-2,1,1,b,b)
end
pal(1,0)
foo()
pal(1,1)
end
function dr_bomb(s)
if s.dead then
local foo=function()
spr(54,s.x-4+rnd(2)-1,s.y+(s.z or 0)-6+rnd(2)-1)
end
dr_outline(foo,0)
foo()
else
dr_outlined_self(s,0)
end
end
function dr_pickup(s)
if s.dead then
local foo=function()
spr(91,s.x-4,s.y+(s.z or 0)-6)
end
dr_outline(foo,0)
foo()
else
dr_outlined_self(s,0)
end
end
function dr_prop(s)
local foo=function()
spr(s.s,s.x-4,s.y-6,1,1,s.faceleft)
end
dr_outline(foo,0)
if s.dead then
pal(1,7)
pal(13,7)
pal(6,7)
foo()
pal(1,1)
pal(13,13)
pal(6,6)
else
foo()
end
end
function dr_boss(s)
rectfill(s.x-9,s.y-8,s.x+8,s.y+18,0)
local dy=2+2*cos(s.animt*4)
local foo=function()
spr(196,s.x-16,s.y-2+dy,1,2)
spr(197,s.x+8,s.y-2+dy,1,2)
spr(192,s.x-16,s.y+14+dy,4,1)
if player.x < s.x-8 then
spr(140,s.x-15,s.y-16-dy,4,4)
elseif player.x > s.x+8 then
spr(136,s.x-17,s.y-16-dy,4,4)
else
spr(128,s.x-16,s.y-16-dy,4,4)
end
-- spr(200,s.x-16,s.y-28-dy,4,2)
end
dr_outline(foo,0)
foo()
if s.try then
circfill(s.x,s.y,24,7)
end
end

function dr_slash(s)
local v=max(flr(s.t/0.025)-2,0)
local foo=function()
spr(48+v*2,s.x-8,s.y-2-4,2,1,s.left)
end
-- dr_outline(foo,0)
foo()
end
function dr_explosion(s)
if s.p<2 then
circfill(s.x,s.y,s.r,0)
elseif s.p<4 then
circfill(s.x,s.y,s.r,7)
if s.p<3 and s.r>4 then
for i=0,2 do
local x=s.x+rnd(2.2*s.r)-1.1*s.r
local y=s.y+rnd(2.2*s.r)-1.1*s.r
local r=0.25*s.r+rnd(0.5*s.r)
cex(x,y,r)
end

for i=0,2 do
cms(s.x,s.y,pick{13,6})
end
end
elseif s.p<5 then
-- circ(s.x,s.y,s.r,7)
deregister_object(s)
return
end
s.p+=1
end
function dr_smoke(s)
circfill(s.x,s.y,s.r,s.c)
end
function dr_debris(s)
if s.l<0.15 and s.l%0.04>0.02 then return end
local foo=function()
spr(s.s,s.x-4,s.y-4+s.z,1,1,s.left)
end
if s.out then
dr_outline(foo,0)
end
foo()
end
function dr_part(s)
pset(s.x,s.y+s.z,s.c)
end
function dr_animpart(s)
pal(5,0)
dr_self(s)
pal(5,5)
end
function dr_textpart(s)
local c,k=7,max(3-(s.l-s.t)*0.5,0)
for i=1,k do
c=drk[c]
end
dr_text(s.txt,s.x,s.y,1,c,drk[c])
end

function dr_outline(dr,c,arg,no_mod)
all_colors_to(c)
local xmod,ymod=xmod,ymod
if no_mod then
xmod,ymod=0,0
end
camera(xmod-1,ymod)
dr(arg)
camera(xmod+1,ymod)
dr(arg)
camera(xmod,ymod-1)
dr(arg)
camera(xmod,ymod+1)
dr(arg)
camera(xmod,ymod)
all_colors_to()
end

function dr_gui()
--lifebar
local x,y,w,h=2,2,48,13
rectfill(x-1,y-1,x+w,y+h+1,0)
rect(x,y,x+w-1,y+h-1,7)
rectfill(x,y+h,x+w-1,y+h,13)
local v=player.life
if v>0 then
local xb=x+v/5*(w-4)+1
rectfill(x+2,y+2,xb,y+h-3,6)
if v<4 then
rectfill(xb+1,y+2,xb+1,y+h-3,13)
end
end
local foo=function()
spr(125,x+w/2-4,y+2)
spr(112+v,x+w/2-10,y+2)
spr(117,x+w/2+2,y+2)
end
dr_outline(foo,0,nil,true)
foo()
--bombs left
local n=""..group_count("bombs")
local xb=69
local xa=xb-7*#n-3
local y=4
local foo=function()
dr_number(n,xa,y)
spr(126,xb,y+2)
spr(127,xb,y-6)
if slainbomb%0.08<0.04 then
spr(122,xb-17,y+9)
spr(113,xb-10,y+9)
end
end
dr_outline(foo,0,nil,true)
foo()
--timer
local v=90*30
for s in group("bombs") do
v=min(v,s.timer)
end
if n=="0" then v=0 end
local s=""..flr(v/30)
local ms=sub(""..((v%30)/30*1000+1000),2,4)
local x=86
local y=4
local vs,vms=s*1,ms*1
local foo=function()
dr_number(s,x+14-#s*7,y)
spr(124,x+13,y)
dr_number(ms,x+19,y)
end
dr_outline(foo,0,nil,true)
if not(vs>0 and vs<90 and (vs%10==0 or (vs<10)) and vms<100) then
foo()
else
sfx(48)
end
end
function dr_number(n,x,y)
ns=""..n
for i=1,#ns do
local s=112+sub(ns,i,i)
spr(s,x,y)
x+=7
end
end
function dr_text(str,x,y,al,c1,c2)
str,al,c1,c2=""..str,al or 1,c1 or 7, c2 or 6
x-=al*#str*2
y-=3
for p in all(txtposextra) do
print(str,x+p.x,y+p.y,c0)
end
print(str,x+1,y+1,c2)
print(str,x-1,y+1,c2)
print(str,x,y+2,c2)
print(str,x+1,y,c1)
print(str,x-1,y,c1)
print(str,x,y+1,c1)
print(str,x,y-1,c1)
print(str,x,y,0)
end
function dr_debug()
camera()
rectfill(0,0,32,8,0)
print(stat(1),0,0,7)
end

--->8
-- * creates *
function create_player(x,y)
player=merge_arrays(parse[[
w=4,
h=4,
vx=0,
vy=0,
animt=0,
idlet=0,
hurt=0,
life=4,
name=player,
regs={to_dr2,to_u,obstacle}
]],{
u=u_player,
dr=dr_player
})
set_player(x,y)
register_object(player)
-- return p
end
function set_player(x,y)
player.x,player.y,player.state=x,y,"idle"
end
function sk(x,y,n)
local inf=enem_dat[n or 1]
local s=merge_arrays(parse[[
w=8,
h=8,
vx=0,
vy=0,
wx=0,
wy=0,
animt=0,
name=skull,
regs={to_dr2,to_u,enemies,obstacles,slashable} 
]],{
x=x, y=y,
aima=rnd(1),
movet=rnd(1),
aimt =rnd(1),
shott=0.5+rnd(0.5),
king=inf.king,
state=pick(parse"left,right,up,down"),
u=u_skull,
dr=dr_skull
})
if inf.carry then
local obj
if inf.carry==0 then --bomb
obj=create_bomb(0,0)
deregister_object(obj)
obj.oregs,obj.regs=obj.regs,{"bombs"}
register_object(obj)
else--if inf.carry==1 then --health
obj=create_pickup(0,0)
deregister_object(obj)
obj.oregs,obj.regs=obj.regs,{}
end
s.carry=obj
end
register_object(s)
return s
end
function create_bullet(x,y,a,spd)
local s={
x=x, y=y,
w=4, h=4,
vx=spd*cos(a),
vy=spd*sin(a),
start=1,
animt=0,
u=u_bullet,
dr=dr_bullet,
regs=parse"to_dr2,to_u,bullets"
}
register_object(s)
return s
end
function create_bomb(x,y)
local s=merge_arrays(parse[[
w=8,
h=8,
animt=0,
maxtim=2700,
name=bomb,
state=bounce,
regs={to_dr2,to_u,bombs,obstacles,slashable}
]],{
x=x, y=y,
u=u_bomb,
dr=dr_bomb
})
s.timer=s.maxtim
register_object(s)
return s
end
function create_pickup(x,y)
local s={
x=x, y=y,
w=8, h=8,
animt=0,
name="heart",
u=u_pickup,
dr=dr_pickup,
regs=parse"to_u,to_dr2,pickups,obstacles,slashable"
}
register_object(s)
return s
end
function create_prop(x,y,n,left)
local s={
x=x, y=y,
w=8, h=8,
s=84+(n or frnd(2))*16,
faceleft=(left and left==0) or (not left and chance(50)),
u=u_prop,
dr=dr_prop,
regs=parse"to_u,to_dr2,props,obstacles,slashable"
}
register_object(s)
return s
end
function create_hologram(x,y,create)
local s=create(x,y)
s.state,s.name,s.odr,s.ou,s.u,s.dr=s.name,"hologram",s.dr,s.u,u_hologram,dr_outlined_self
if create~=create_bomb then
add(s.regs,"bombs")
add(objs.bombs,s)
end
end
function create_boss()
local s=merge_arrays(parse[[
x=128,
y=96,
w=32,
h=32,
animt=0,
name=boss,
regs={to_u,to_dr3,enemies,bombs,slashable}
]],{
x=x, y=y,
u=u_boss,
dr=dr_boss
})
register_object(s)
return s
end

function create_slash(x,y,left)
local s={
x=x,
y=y,
left=left,
t=0,
u=u_slash,
dr=dr_slash,
regs=parse"to_u,to_dr3"
}
register_object(s)
end
function cex(x,y,r)
local e={
x=x,
y=y,
r=r,
p=0,
dr=dr_explosion,
regs={"to_dr4"}
}
register_object(e)
end
function cms(x,y,c,spd,a,r)
a,spd=a or rnd1(),spd or 0.5+rnd(2.5)
local s={
x=x,
y=y,
vx=spd*cos(a),
vy=spd*sin(a),
r=r or rnd(3),
c=c,
u=u_smoke,
dr=dr_smoke,
regs=parse"to_u,to_dr3"
}
register_object(s)
return s
end
function cdb(x,y,s,a,spd,z,vz,out,left)
local a,spd=a or rnd1(),spd or 1+rnd(2)
local s={
x=x,
y=y,
w=6,
h=6,
vx=spd*cos(a),
vy=spd*sin(a),
z=z or -2,
vz=vz or -2,
s=s,
out=out,
l=0.4+rnd(0.1),
left=left,
u=u_debris,
dr=dr_debris,
regs=parse"to_dr2,to_u"
}
register_object(s)
return s
end
function create_animpart(x,y,spd,name,state,stateb)
if stateb and chance(50) then
state=stateb
end
local a,spd=rnd1(),spd*(0.8+rnd(0.3))
local s={
x=x,
y=y,
vx=spd*cos(a),
vy=spd*sin(a),
animt=0,
name=name,
state=state,
u=u_animpart,
dr=dr_animpart,
regs=parse"to_dr2,to_u"
}
register_object(s)
end
function create_part(x,y,c,spd,z,vz)
local a=rnd1()
local spd=spd or 1+rnd(2)
local s={
x=x,
y=y,
vx=spd*cos(a),
vy=spd*sin(a),
z=z or -2,
vz=vz or -2,
c=c,
l=0.3+rnd(0.1),
u=u_part,
dr=dr_part,
regs=parse"to_dr2,to_u"
}
register_object(s)
end
function create_textpart(x,y,txt)
local s={
x=x,
y=y,
vy=2,
t=0,
l=50,
txt=txt,
u=u_textpart,
dr=dr_textpart,
regs=parse"to_u,to_dr4"
}
register_object(s)
return s
end

--->8
-- * misc *
function transition(way,full)
if full then
transition(1)
transition(-1)
end
local ptrns,strt,fnsh=parse"15615.5,12495.5,12300.5,0",0,256
if way==-1 then strt,fnsh=fnsh,strt end
for x=strt,fnsh,way*16 do
_draw()
for i=0,3 do
fillp(ptrns[i+1])
rectfill(-1,0,x-43*i,127,0)
end
dr_gui()
flip()
end
end
function level_transition(nworld,nlevel,pltn)
sfx(50)
transition(1)
load_world(nworld,pltn)
world,level=nworld,nlevel
if world==0 then
init_ship()
elseif level==5 then
--boss time
load_sprdata("000000ffff000000000000ffff000000000000ffffc00000000000ffff0000000000ffffaaff00000000ffffffff00000000ffffeabf00000000fffeaaff0000000fffffaaaaf000000ffffffffff000000fffffeaaaf000000ffffeaaabf000003fbbfeaaaaac00003f77fffffffc00003feeffaaaaac00003eeffaaaaabc0000ffeffeaaaaab0000ffdfffffffff0000fffbffaaaaab0000ffbffaaaaaaf0003ffbbfaaaaaaac003ff77ffffffffc003ffeefeaaaaaac003feefeaaaaaab800eafffaaaaaaaa900ffffffffffffff00febffeaaaaaaa900ebffeaaaaaaaa500eaa9aaaaaaaaa900fffdffffffffff00faaa6aaaaaaaa900eaa6aaaaaaaaa503aaa66aaaa696aa43fff77ffff7d7ffc3eaa99aaaa9a5aa43aa99aaaa9a5aa943aa955aa9a59a5a43ffd55ffdf5df5fc3eaa556aa69669643aa556aa696696943a9aaa9a96aaa6a43fdfffdfd7fff7fc3ea6aaa6a5aaa9a43a6aaa6a5aaa9a943aa955aaaa556aa43ffd55ffff557ffc3aaa556aaa955aa43aa556aaa955aa943aa4006aa9001a643ff4007ffd001f7c3aa9001aaa4006943a9001aaa40069943a90003aa4000ea43fd0001ff40007fc3aa4000ea90003a43a4000ea90003a943a90003aa4000e643fd0001ff400077c3aa4000ea90003943a4000ea900039940690003aa4000e900fd0001ff40007f006a4000ea9000390064000ea90003a50069000e96b000e900fd0007ffd0007f005a4003a5ac00390064003a5ac003a5003ac0fa41af03ac003f405fc3f501fc001eb03e906bc0e4003b03e906bc0e9400eabfa6419afeab00ffd5f7c3df57ff003aafe99066bfa900eafe99066bfaa403a6aa6a41a9aa9a43f7ff7fc3fdffdfc0e9aa9a906a6aa6439aa9a906a6aa6903aa66a9006a99aa43ff77ff00ffddffc0ea99aa401aa66a43a99aa401aa66a900eaaaa9006aaaa900ffffff00ffffff003aaaaa401aaaa900eaaaa401aaaaa400ea9aa4001aa6a900ffdffc003ff7ff003aa6a90006a9a900ea6a90006a9aa40015aaa43c1aaa54003ffffc3c3ffffc00056aa90f06aa540015aa90f06aa950000056abebea95000000ffffffffff00000015aafafaa50000005aafafaa5400000003a6aa9a4000000003f7ffdfc000000000e9aaa6900000000e9aaa6900000000039969664000000003dd7d77c000000000e65a59900000000e65a599000000000aaaaaaa900000000ffffffff000000002aaaaaaa40000002aaaaaaa400000000ebaaaaee00000000ffffffff000000003aeaaabb80000003aeaaabb800000000de6ebb9d00000000ffffffff00000000379baee74000000379baee74000000001979e654000000003ffffffc00000000065e79950000000065e79950000000000025940000000000003ffc000000000000096500000000000096500000000034f000000f340000c0010000c0030000000000000000000000000010caa3040039df8003ede40000d00d0000f00f0000000000000000002aaaaaa800000000000e9e7efb99900000d00d0000f00f0000000000000000002600009800000000000ea9b9e66a900000d00d0000f00f0000000000500000002a0000a800000000000eaaa69aaa900000d00d0000f00f0000000002840000002003c0080000000000015aaaaaa5400000d00d0000f00f0003fa800ff002afc0200ff008000000000000056aa950000000d00d0000f00f003e55543ffc1555bc200ff00800000000000000155400000000d00d0000f00f00e50000ffab000059203d7c0800000000003cf000000f3c0000d00d0000f00f00efc000faaa0003f920355c0800000000003fffc003fffc0000d00d0000f00f001abfffeaaafffea420ffff0800000000000ffffffffff00000343400003c3c00056aaaaaa9aaa95020ffff0800000000000ffffffffff00000343400003c3c000015556a555554002000000800000000000ffffffffff00000343400003c3c0000000005500000002a0000a8000000000003ffffffffc00000343400003c3c000000000000000000260000980000000000000ffffff0000000343400003c3c0000000000000000002aaaaaa8000000000000003ffc00000000343400003c3c0000000000000000000000000000000000",0,64,128,48)
memset(0x2000,0,0x1000)
for x=0,19 do
for y=0,19 do
mset(x+70,y+6,64+rnd(4))
end
end
local cols=parse"0=0,13=1,6=2,7=3"
for x=0,15 do
mset(x+8,7,80+cols[sget(112+x,96)])
for y=0,15 do
mset(x+8,y+8,96+cols[sget(96+x,96+y)])
mset(x+72,y+8,0)
end
end
set_player(16*8,20*8)
--set_player(8*8,8*8)
boss = create_boss()
set_props[[
{x=76,y=84,a=0,b=0},
{x=76,y=128,a=0,b=0},
{x=76,y=172,a=0,b=0},
{x=180,y=84,a=0,b=1},
{x=180,y=128,a=1,b=1},
{x=180,y=172,a=0,b=1}
]]
else
gen_map()
end
for i=1,16 do
cms(player.x,player.y,pick(parse"13,6,7,7,7"))
end
camx,camy=player.x-64,player.y-80
for i=1,60 do
loading_screen()
end
sfx(0)
transition(-1)
if progress>=14 then
for i=1,6 do
messup_tiles()
_draw()
flip()
end
end
end
function loading_screen()
cls()
t+=0.01
local loop,world,x=flr((world-1)/3),(world-1)%3+1,60
if loop>0 then
spr(123,80,60)
dr_number(loop,87,60)
x-=28
end
dr_number(world,x-#(""..world)*7,60)
spr(122,x,60)
dr_number(level,x+7,60)
spr(16+(t/0.03)%4,60,80)
dr_gui()
flip()
end
function next_level()
for o in group("props") do
deregister_object(o)
end
for o in group("pickups") do
deregister_object(o)
end
progress+=1
local nworld,nlevel,pltn
if progress<=3*3 then
nworld,nlevel=flr((progress-1)/3)+1,(progress-1)%3+1
elseif progress<=12 then
nworld,nlevel,pltn=progress-9,4,4
elseif progress==13 then
nworld,nlevel,pltn=3,5,4
elseif progress==14 then
nworld,nlevel,pltn=0,0,4
reload(0x1000,0x1000,0x2000)
else
local v=progress-(5*3)
local n=flr(v/10)
if v%10==9 then
nworld,nlevel=n*3+6,5
else
nworld,nlevel=n*3+flr((v%10)/3)+4,(v%10)%3+1
end
end
level_transition(nworld,nlevel,pltn)
end
function gen_map()
cls()
local inf,loop=merge_arrays({},gen_data[(world-1)%3+1][level]),flr((world-1)/3)
if loop>=1 then
local k,e=1+loop*0.25,inf.enem
inf.totl*=k
inf.rect*=k
inf.sqar*=k
inf.circ*=k
e[1]+=4+loop*4
e[3]+=loop*2
e[4]+=loop*2
end
color(1)
for i=1,inf.rect do
local a=48+rnd(32)
local b,c=a+mid(sgn(rnd(2)-1)*rnd(32),32,95),32+rnd(63)
if chance(50) then
rectfill(a,c,b,c+1)
else
rectfill(c,a,c+1,b)
end
end
for i=1,inf.sqar do
local x,y=40+rnd(48),40+rnd(48)
rectfill(x-4,y-4,x+3,y+3)
end
for i=1,inf.circ do
local x,y=40+rnd(48),40+rnd(48)
circfill(x,y,4)
end
rect(32,32,95,95,0)
rectfill(59,63,68,64,2)
rectfill(63,59,64,68,2)
local grid={}
for y=0,63 do
local lin={}
for x=0,63 do
lin[x]=pget(x+32,y+32)
end
grid[y]=lin
end
loading_screen()
local dirs,tls=parse"{-1,0},{1,0},{0,-1},{0,1}",0
while tls<inf.totl do
local x,y=1+frnd(62),1+frnd(62)
local c=grid[y][x]
if c==2 then
for k,d in pairs(dirs) do
local xx,yy=flr(x+d[1]),flr(y+d[2])
local cc=grid[yy][xx]

if cc==1 then
grid[yy][xx]=2
tls+=1
elseif chance(1) then
grid[yy][xx]=2
tls+=1
end
end
end
end
loading_screen()
for y=63,0,-1 do
for x=0,63 do
local c,tceil,tflor=grid[y][x]

if c==2 then
local n=0
for k,d in pairs(dirs) do
local yy=flr(y+d[2])
n+=(grid[yy] and grid[yy][flr(x+d[1])]==2 and 1 or 0)
end

if n<=1 then
grid[y][x],c=3,3
end
end

if c==2 then
tflor=96+max(rnd(8)-4,0)
else
if y<63 and grid[y+1][x]==2 then
tflor=80+max(rnd(8)-4,0)
end

local b
for k,d in pairs(dirs) do
local yy=flr(y+d[2])
b=b or (grid[yy] and grid[yy][flr(x+d[1])])==2
end

if b then
tceil=64+max(rnd(8)-4,0)
end
end
mset(x,y,tflor)
mset(x+64,y,tceil)
end
end
for i=1,4 do
local n=0
while n<inf.elem[i] do
local x,y=frnd(64),frnd(64)
if grid[y][x]==2 then
elem_foo[i](x*8+4,y*8+4)
grid[y][x]=6+i
n+=1
end
end
loading_screen()
end
for i=1,5 do
local n=0
while n<inf.enem[i] do
local x,y=frnd(64),frnd(64)
if grid[y][x]==2 then
sk(x*8+4,y*8+4,i)
grid[y][x]=14
n+=1
end
end
loading_screen()
end
end
function fmget(x,y,f)
return fget(mget(x,y),f)
end
function my_map(camx,camy,ofsx,ofsy,flags)
camera(camx,camy)
local mpx,mpy=flr(camx/8),flr(camy/8)
palt(0,false)
pal(1,0)
map(mpx+ofsx,mpy+ofsy,mpx*8,mpy*8,17,17,flags)
pal(1,1)
palt(0,true)
end
function init_camera()
shkx,shky,camx,camy=0,0,player.x-64,player.y-64
xmod,ymod=camx,camy
lxmod,lymod,vxmod,vymod=xmod,ymod,0,0
end
function init_ship()
set_player(448,40)
set_props[[
{x=436,y=52,a=0,b=0},
{x=460,y=52,a=0,b=1},
{x=428,y=68,a=0,b=0},
{x=468,y=68,a=0,b=1},
{x=412,y=76,a=1,b=0},
{x=484,y=76,a=1,b=1}
]]
if progress==0 then
local cs=parse"0,13,6,7,0,4,9,7"
for i=1,4 do
pal(cs[i],cs[i+4],1)
end
create_hologram(448,72,create_pickup)
else
for i=1,6 do
--sk(447.5+8*cos(i/6),79.5+8*sin(i/6),3)
create_pickup(447.5+8*cos(i/6),79.5+8*sin(i/6))
end
sk(400,72,3)
sk(496,72,3)
end
end
function set_props(str)
local props = parse(str)
for p in all(props) do
create_prop(p.x,p.y,p.a,p.b)
end
end
function load_world(n,pltn)
local pltn=pltn or n
if n>=4 then
pltn=(pltn-4)%3+5
end
local plt,cs=plts[pltn],parse"0,13,6,7"
for i=1,4 do
pal(cs[i],plt[i],1)
end
if n>0 then
n=(n-1)%3+1
end
load_sprdata(tiles[n],0,32,32,24)
load_sprdata(props[n],32,40,40,16)
end
function messup_tiles()
-- for i=1,6 do
local sx,sy=2+frnd(6),32+frnd(6)*4
local sa,v,ox,oy,oa=sy*64+sx*2,0
while v==0 do
ox,oy=frnd(32),16+frnd(12)*4
oa=oy*64+ox
for y=0,3 do
v+=peek(oa+y*64)
v+=peek(oa+y*64+1)
end
end
for y=0,3 do
poke(sa+y*64,peek(oa+y*64))
poke(sa+y*64+1,peek(oa+y*64+1))
end
-- end
end
hex2dec={}
for i=1,16 do
hex2dec[sub("0123456789abcdef",i,i)]=i-1
end
function load_sprdata(str,x,y,w,h)
local i2c,i=parse"0=0,13,6,7",1
for yy=y,y+h-1 do
for xx=x,x+w-1,2 do
local v=hex2dec[sub(str,i,i)]
local ca,cb=i2c[band(v/4,3)],i2c[band(v,3)]
poke(yy*64+xx/2,cb*16+ca)
i+=1
end
end
end
function init_worlds()
tiles=parse[[
0=5554fffc000001004000c000040002004000c30c1d0006404000cc3004046ba44000c0c0000006404000c300000002004000cc000040010000000000000000000000000004400000000000001000000000000000410430000000000047440000fffdffff01000000d99803c010100020d9980f0c0540000040003c3000000000fffefefefffefffeeaa9dd9deaa99aa5eaa9ddfdeaa9ee9eeaa99dd59554de9deaa9edde9554d95deaa9d99deaa9eff9eaa9dffdeaa9eaa99555995595559555,
000000000000000001540000001501500100000000100100000000001500000000000550100000001540040000540550100000000040040000000000000000000000000000000000000000000000000000000000000000000000000000000000a6a69a6aa6aa999a01010410010004446a9a6a9a9a9aa66a1004100404040110aaaaaaaaaeaaaaaaaaaaaaaab9aaafaaaaaaaaeaa6aaba6aaaaaaa9aaaaaba6aaaaaaaaaaaaaa5aaaaaaaaaaaaeaaaaaaaaaaaaaab9aaaaaaaaaaaaaaa6aaaaa,
0444044404040444111110111111111144444504444440441011040101101111404440504444440411111041111111014444440444444444111011101010111000000000000000000000000000000000000000000000000000000000000000000000034000003434dddddf1ddc0df1f17777773777377373444445044444505055555555555555555655555d555555595555557555597555555957655d55657555555595595555d5595575555575556555556555556555955555555555555555,
000000000000000015541414155414141410101010001010100010101140000010001010110000001400101010001414100010101000101000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaafefefbbeeeeeffbee8e8e338cccceae84040411044444000aa6aaa6aaa6aaa6aaaaaaaaabbbabffaaaaaaaaaa666baa6ababaaabbbbbbaa76a6a6aaa66667aa6aaaaaaaabbbabaa6aaaaaaaaa666a556abaaabaaabaaabaa,
]]
props=parse[[
0=03ff000003ff000003ff0c0300000c0300000c03324d0000324d0000324dc039c00000390009c030fff9ff0000f900f9ff00eab9eab000090ab9e000eab9eab90000eab90000ffe5ffe50000ffe50000fffe0000fffe0000fffec0010000c0010000c001c3810000c3810000c381c241c00002410001c240c001c00000010001c00095559550000505559000014001400000014000000fe00fe000000fe00000,
05500000055000000550155400001554000015540ff000000ff000000ff0477140000771000147701ef41e0000f400f41e003fdc3fd0000c0fdc30002ef82ef800002ef800000aa00aa000000aa000000ff000000ff000000ff03fe000003fe000003fe03f9400003f9400003f943e9430000e9400043e903a743a00007400743a00fae4fae000040ae4f000faf9faf90000faf90000faf9faf90000faf90000,
0ff300000ff300000ff33abc00003abc00003abceee90000eee90000eee9f9a5f00009a50005f9a0e699e60000990099e60015541550000405541000c241c2400001424100000340034000000340000003c0000003c0000003c0038000000380000003800fb400000fb400000fb41ed410000ed400041ed017ac170000ac00ac17003ad83ad000080ad83000ee5bee5b0000ee5b000003800380000003800000,
03ff000003ff000003ff0c0300000c0300000c03324d0000324d0000324dc039c00000390009c030fff9ff0000f900f9ff00eab9eab000090ab9e000eab9eab90000eab90000ffe5ffe50000ffe5000000000000000000000000fffe0000fffe0000fffe95990000959900009599bfadb0000fad000dbfa0aa99aa0000990099aa0095ad95a0000d05ad9000bf99bf990000bf990000aaa9aaa90000aaa90000,
]]
plts=parse[[
{0,4,15,7},
{0,3,10,7},
{0,1,13,7},
{0,12,14,7},
{0,2,12,7},
{0,4,11,7},
{0,12,14,7}
]]
-- plts[0]={0,4,9,7}
-- plts[0]={14,12,10,7}
--elem={player,bombs,pickups,props}
--enem={regular,heart,bomb,trishot,lineshot}
gen_data=parse[[
{
{
id=w1-1,
rect=30,
sqar=0,
circ=5,
totl=400,
elem={1,8,2,4},
enem={6,0,0,0,0}
},
{
id=w1-2,
rect=30,
sqar=1,
circ=6,
totl=500,
elem={1,10,2,6},
enem={8,2,0,0,0}
},
{
id=w1-3,
rect=35,
sqar=1,
circ=8,
totl=650,
elem={1,12,3,8},
enem={10,2,4,0,0}
},
{
id=w1-4,
rect=35,
sqar=0,
circ=12,
totl=800,
elem={1,12,2,12},
enem={24,2,8,0,0}
}
},
{
{
id=w2-1,
rect=20,
sqar=12,
circ=0,
totl=500,
elem={1,8,1,5},
enem={8,2,0,2,0}
},
{
id=w2-2,
rect=20,
sqar=16,
circ=0,
totl=800,
elem={1,12,2,6},
enem={10,2,0,4,0}
},
{
id=w2-3,
rect=8,
sqar=24,
circ=0,
totl=1000,
elem={1,14,2,8},
enem={4,2,6,8,0}
},
{
id=w2-4,
rect=8,
sqar=24,
circ=0,
totl=1000,
elem={1,10,4,8},
enem={0,0,10,12,1}
}
},
{
{
id=w3-1,
rect=24,
sqar=8,
circ=0,
totl=700,
elem={1,10,2,8},
enem={9,1,0,0,2}
},
{
id=w3-2,
rect=32,
sqar=2,
circ=0,
totl=800,
elem={1,12,2,8},
enem={10,1,0,1,5}
},
{
id=w3-3,
rect=24,
sqar=0,
circ=16,
totl=1000,
elem={1,14,5,8},
enem={0,0,10,2,8}
},
{
id=w3-4,
rect=32,
sqar=4,
circ=16,
totl=1400,
elem={1,16,6,8},
enem={0,0,16,4,12}
}
}
]]
elem_foo={
set_player,
create_bomb,
create_pickup,
create_prop
}
enem_dat=parse[[
{},
{carry=1},
{carry=0},
{king=0},
{king=1}
]]
end

-- * collisions *
function collide_objgroup(obj,groupname)
for obj2 in group(groupname) do
if collide_objobj(obj,obj2) then
return obj2
end
end
return false
end
function all_collide_objgroup(obj,groupname)
local list={}
for obj2 in group(groupname) do
if collide_objobj(obj,obj2) then
add(list,obj2)
end
end
return list
end
function collide_objobj(obj1,obj2)
return (obj1~=obj2
and abs(obj1.x-obj2.x)<(obj1.w+obj2.w)/2
and abs(obj1.y-obj2.y)<(obj1.h+obj2.h)/2)
end

--->8
-- * animation *
function init_anim_info()
anim_info=parse[[
player={
idle={
sprites={16,17,18,19},
dt=0.04
},
run={
sprites={20,21,22,23,24,25,26,27,28,29,30,31},
dt=0.02
},
slash={
sprites={0,2,4,6},
width=2,
dt=0.03
},
bored={
sprites={14,13,14,15,14,13,13,14,14,15,15,14,14,14,14,12,12,11,10},
dt=0.03
},
hurt={
sprites={57},
dt=1,
},
done={
sprites={19,17,19,17,19,8,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9},
dt=0.05
}
},
skull={
left={
sprites={32,33,34,35},
dt=0.04
},
right={
sprites={36,37,38,39},
dt=0.04
},
up={
sprites={40,41,42,43},
dt=0.04
},
down={
sprites={44,45,46,47},
dt=0.04
}
},
bomb={
bounce={
sprites={55,54,54,55,56,56},
dt=0.03
}
},
heart={
only={
sprites={74,74,75,76,76,75},
dt=0.03
}
},
hologram={
heart={
sprites={188,189,172,173,188,189,74,74,75,76,76,75,74,74,75,76,76,75,74,74,75,76,76,75},
dt=0.02
},
skull={
sprites={188,189,172,173,188,189,44,45,46,47,44,45,46,47,44,45,46,47,44,45,46,47,44,45,46,47},
dt=0.02
},
bomb={
sprites={188,189,172,173,188,189,55,54,54,55,56,56,55,54,54,55,56,56,55,54,54,55,56,56},
dt=0.02
}
}
]]
end
function da(x,y,char,state,t,xflip)
local sinfo=anim_info[char][state]
local wid,hei=sinfo.width or 1,sinfo.height or 1
spr(sinfo.sprites[flr(t/sinfo.dt)%#sinfo.sprites+1],x-wid*4,y-hei*4,wid,hei,xflip)
end
function anim_step(o)
local info=anim_info[o.name][o.state or "only"]
return flr(o.animt/info.dt%#info.sprites),(o.animt%info.dt<0.01),flr((o.animt/info.dt)/#info.sprites)
end

--->8
-- * objects handling *
function init_objects(groups)
objs={}
for name in all(groups) do
objs[name]={}
end
end
function u_objects()
for obj in all(objs.to_u) do
obj.u(obj)
end
end
function dr_objects(start,finish)
start,finish=start or 0,finish or 4
for i=start,finish do
local dobjs=objs["to_dr"..i]
--sorting objects by depth
for i=2,#dobjs do
local k=i
while(k>1 and dobjs[k-1].y>dobjs[k].y) do
dobjs[k],dobjs[k-1]=dobjs[k-1],dobjs[k]
k-=1
end
end
--actually dring
for obj in all(dobjs) do
obj.dr(obj)
end
end
end
function register_object(o)
for reg in all(o.regs) do
add(objs[reg],o)
end
end
function deregister_object(o)
for reg in all(o.regs) do
del(objs[reg],o)
end
end
function group(name) return all(objs[name]) end
function group_count(name) return #objs[name] end

--->8
-- * utilities *
function parse(str)
local ar,c,lc,char,cc={},0,1
while c<=#str do
local field,val
repeat
c+=1
char=sub(str,c,c)
if char=="=" then
field,lc=sub(str,lc,c-1),c+1
elseif char=="{" then
val,cc=parse(sub(str,c+1,#str))
c+=cc
elseif char=="\n" then
lc+=1
end
until char=="," or char=="" or char=="}"
local val=val or sub(str,lc,c-1)
ar[tonum(field) or field or #ar+1],lc=tonum(val) or val,c+1
if char=="}" then break end
end
return ar,c
end
capital=parse"a=\65,b=\66,c=\67,d=\68,e=\69,f=\70,g=\71,h=\72,i=\73,j=\74,k=\75,l=\76,m=\77,n=\78,o=\79,p=\80,q=\81,r=\82,s=\83,t=\84,u=\85,v=\86,w=\87,x=\88,y=\89,z=\90"
function capitalize(str)
local nstr,i="",1
while i<=#str do
local ch=sub(str,i,i)
if ch=='^' then
i+=1
nstr=nstr..sub(str,i,i)
else
nstr=nstr..(capital[ch] or ch)
end
i+=1
end
return nstr
end
function all_colors_to(c)
for i=0,15 do
pal(i,c or i)
end
end
function angle_diff(a1,a2)
return (a2-a1+0.5)%1-0.5
end
function merge_arrays(ard,ars)
for k,v in pairs(ars) do
ard[k]=v
end
return ard
end
function smolsqr(a) return 0.01*a*a end
function smolsqrdist(x,y) return smolsqr(x)+smolsqr(y) end
function plerp(pa,pb,i) return lerp(pa.x,pb.x,i),lerp(pa.y,pb.y,i) end
function lerp(a,b,i) return (1-i)*a+i*b end
function dist(xa,ya,xb,yb) if xb then xa,ya=xb-xa,yb-ya end return sqrt(sqrdist(xa,ya)) end
function sqrdist(x,y) return x*x+y*y end
function sqr(a) return a*a end
function round(a) return flr(a+0.5) end
--function ceil(a) return flr(a+0x.ffff) end
function frnd(a) return flr(rnd(a)) end
function rnd1() return rnd(1) end
function pick(ar) return ar[frnd(#ar)+1] end
function chance(a) return rnd(100)<a end
__gfx__
0000007077700000000000d0ddd00000000000000000000000000000000000000000700000777000000000000000000000000070000000000000000000000000
0000000007777000000000000dddd000000000000000000000000077000000000000070000000770000770000007707000077070007700700007707000007770
0000007707777700000000770d7ddd000000007700d0000000000077000007000007707000077070000770700007707000077070007700700007707000007770
00000077007777000000007700d77d0000000077000dd00000007777700070000007700700077070777775757777757577777575077757500777757007777757
00077777707777700000777770d777d000007777700ddd0000070077070700000777777000777700000770700007707000077000707707007007707500007707
0000007707077770000700770707777000070077070dd77000000077007000007007700007077000000777700007770000077700707777000007777000007777
00007777707770000000077700777000000000770077700000000077000000000007770007077700000700700007007000070070007000000007000000007000
00000007000000000000007000000000000007070000000000000707000000000077070000770700000700000007000000070000000700000007000000070000
00000007000000070000007000000000000007000000070000000000000000000000000000000000000000000000000000000000000000000000070000007700
00077007007700070077007000000070000757000007570000000000000000000007700000077000000770000007700000000000000000700007570000075070
00077007007700700077007000077070000770700007570000077000000770000007700000077007000770000007700000077000000770700007707000077007
00777707077770700777707000077007007770700077570000077070000770000077707007777770007770700077700000077070000757000077707007777770
07077077707707707077077007777707070777000077770000075700007550000705550070077000070555000075577000075700007757000707770070077000
07077000707700007077000070077077070777000007700000077000007777700777770007757700077777000007700000077000007775000707770000077700
00070700007070000070700000077700077000700077070000075000000550000005050000575070075000700075070000075000000770000007070000700070
00700700007007000070070000770700000000000000070000007000000700000070000007000000000000000000070000007000000700000070000007000000
00666660066666000000000000000000066666000066666000000000000000000066660000666600000000000000000000666600006666000000000000000000
07dd66667dd6666006666600006666606666dd7006666dd700666660066666000666666006666660006666000066660006dddd6006dddd600066666000666600
0700d666700d66607dd6666007dd6666666d00700666d00706666dd76666dd700d6666d00d6666d006666660066666600d0770d00d0770d006dddd6006dddd60
07777d667777d660700d66600700d66666d77770066d77770666d007666d007007dd6d7007d6dd700d6666d00d6666d007776770077767700d0770d70d0770d0
06607606660700607777d67707777d666067066006007066776d777766d7777000667700006776000777dd7007dd6d7000660600006606700777677707776770
000070776067007766670067066070777707000077007606760076667707066000d0770000677600007766000067760000d00d00006066000066660000660670
06067067767000677677000006067067760760607600076700007767760760600060660000067000006676000067760000606600000670000066760000606600
07670000000000000000000007670000000076700000000000000000000076700006700000000000000000000006700000067000000000000000000000067000
070000000000000006000000000000000d0000000000000000777700007777000000000000000007000000000077770000000000007777000060060000000000
00070000000000000006000000000000000d00000000000077777777777777770077770000770707000000007777777700000000777777770007700000666600
000077700000000000006660000000000000ddd00000000077777777767777670077770000770707000000007677776700000000767777670d6776d000677600
0000077770000000000006666000000000000dddd000000077777777766776677777777707777070000000077667766070000000066776670666666000677600
000000077770000000000006666000000000000dddd00000777777777777777776677667707700700000077777777000777000000007777700dddd0000d66d00
00000000077700000000000006660000000000000ddd00007777777766666666777777777077700000077666666000006667700000000666066dd66000d6d600
00000000000070000000000000006000000000000000d0000777777006d66d60666666660070070007676d600000000006d67670000000000d6006d000666600
0000000000000070000000000000006000000000000000d00777777006d66d606dd66dd60007000006d66d600000000006d66d60000000000000000000000000
ddddddd07777777000000000000d0000000000000011100000111100011111000111100000010000077007600000000000000000000000000077000000007770
d00000007000000000d00000000600000000000001d66100011d66101111dd100111111000000110076776d00000000000000000000000000676000000006777
d0000000700700700d7d000000d6d000000110001d67761001d67761111d66d1001ddd1101100710076666d00770077000000000000000006070000000000677
d00000007070070000d000d0d66766d0001771001d67761011d6776101d6776101d666d101700000076776d07667766d00000000000000007770000000067770
d0000000700070000000000000d6d0000017710011d66d1011d6761101d677610167776100001001077777d07677776d77700777000000000660000000007700
d000000070070000000000000006000000011000111dd100111d6110001d6610011677610001710000d77d00076776d07667766d000070000000000000000000
d0000000707000000000d000000d000000000000111110001101110000011100001166100100100000d66d0000d66d007677776d060670000000000000000000
00000000000000000000000000000000000000000110000000000000000000000001110000000000000dd000000dd0000dd66dd0076700000000000000000000
000000000000000000d0d00000000000000770000000000000077000000000000007700000000000007777700000000000000000000000000000000000000000
00000000000000000d00000000000000000760000000000000076000000000000007600000000000077777770770077000000000067007700000000007700760
0000000000000000d00d00d007000000007767d000000000007767d000000000007767d0000000007070077777777777000000006d67766700000000766776d6
0000000000000000d0d7d0d0000000000d767dd00d00000000767dd0000000d00d767d000707707077777770777777776d00000000dd6667000000d67666dd00
7777777d77777777000d0000000000000dd766700dd7000000006670000066700dd70000077777700770770007777770076d00000000dd600000d67006dd0000
7d6d6d60000770000d000d000000060007667d6007667d000000006000667d600700000006766760000070000077770000766d000000000000d6670000000000
7d6d6d600077007000ddd000000000007676dd677676dd67000000007676dd670000000000000000070770000007700000077000000000000007700000000000
d0000000077007000000000000000000000760000007600000000000000760000000000000000000077700000000000000000000000000000000000000000000
77777776777677767777777677777776777777760000000077777776000000007777777600000000000000000000000000000000000000000000007777000000
7666666d7d7d6d7d7666666d6d6666dd7000000d000000007000000d000000007000000d00000000000000000000000000000000000000000000070000d00000
7666666d7d7d777d7666666d76766d767007600d000000007007600d000000007007600d000770000000000000000000000770000000000000007077700d0000
7666666d6d7d7ddd6dddddd07d766d7d7006d00d700000000006d00d0000000d7006d00000077000070770000000007000070000000070000777707700dd7770
7666666d767d7d766dddddd07d6ddd7d7000000d700000000000000d0000000d70000000070770700777000000007770070700000000707076d67000dddd6d6d
7666666d7d6d6d7d7666666d7677776d6ddddddd6ddddd00000000dd00dddddd6d000000067667600670000000066760067000000006676076766dddddd6676d
7666666d7d77777d7666666d7666666d000dd000000dd00000000000000dd0000000000000000000000000000000000000000000000000000ddd67677676ddd0
6ddddddd6d6ddddd6ddddddd6ddddddd007776000077760000000000007776000000000000000000000000000000000000000000000000000000dddddddd0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007777777700000000
00777700000770000077770000777700000777000777777000777700077777700077770000777700000000000770000000077000000077007777777700000000
077dd77000777000077dd770077dd77000777700077dddd0077ddd00077dd770077dd770077dd77000000000077000000007700000007700d777777d00000000
0770077000d770000dd007700dd77770077d770007777700077777000dd007700d7777d0077007700077770007700000000dd00000077d000777777000000000
0770077000077000007777d0000dd770077077000dddd770077dd770000077d0077dd7700d777770007777000770000000000000000770000777777000000000
0770077000077000077ddd000770077007777770077007700770077000077d000770077000ddd77000dddd0007700000000770000077d0000777777007700770
0d7777d000777700077777700d7777d00ddd77d00d7777d00d7777d0000770000d7777d0007777d000000000077777700007700000770000077777707dd77dd7
00dddd0000dddd000dddddd000dddd000000dd0000dddd0000dddd00000dd00000dddd0000dddd00000000000dddddd0000dd00000dd00000dddddd0d707707d
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000076670000006666666600000007
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007666666700007777777700000007
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007666dd66670007777777700000006
00000000001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000766dddddd667000666666600000076
0000000011777777771100000000000000000000000000000000000000000000000000000000000000000000000000000066dd6dd6dd66007777777700000066
000000117777777777771100000000000000000000000000000000000000000000000000000000000000000000000000076dddd00dddd6700666666600000766
000001777776666667777710000000000000000000000000000000000000000000000000000000000000000000000000066d6dddddd6d660777777770007666d
00001777766dddddd6677771000000000000000000000000000000000000000000000000000000000000000000000000766dd0dddd0dd66700777777767666dd
000177766dd111111dd66777100000000000000000000000000000000000000000000000000000000000000000000000766dddddddddd667776767776666dddd
0001776dd1100000011dd67710001111110011111100111111000111110000000000000000011110001100110000000076d6dddddddd6d67666666666dddd6dd
001777d11000000000011d7771017777771177777711777777101777771000000000000000177771017711771000000076dd1d1111d1dd67dddddddddd6ddd0d
00177610000000000000016771017777771177777711777777117777771000000000000001777777117771771000000066dddd6666dddd66dd6ddd6dddd0dddd
01777d1000000000000001d777116677661177666611667766117766661000000000000001776677117771771000000076dddd1111dddd67ddd0ddd0dddddddd
0177610000000000000000167711dd77dd1177dddd11dd77dd1177dddd100000000000000177dd77117771771000000076d6dd6666dd6d67dddddddddddddddd
0177d100000000000000001d76101177110177111100117711017711110000000000000001771177117771771000000066dd1dddddd1dd66d1d1d1d1d1d1d1dd
0177100000000000000000016d100177100177771000017710017777710000000000000001771177117777771000000076dddddddddddd67d6d6d6d6d6d6d6dd
017710000000000000011111d10001771001777710000177100167777710000000000000017711771177777710000000000000000000000070000000666ddddd
0177100000000000001777777710017710017766100001771001d666771000000000000001771177117767771000000000000dd00dd000007000000077766666
01771000000000000177777777100177100177dd1000017710001ddd7710000000000000017711771177d77710000000d66d00000000d66d6000000077666666
01777100000000000166666777101177110177110000017710001111771000000000000001771177117717771000000000d6776dd6776d00670000006dddddd0
016771000000000001ddddd7761177777711771000000177100177777710000000000000017777771177177710000000d6776d0000d6776d6600000077666666
01d7771000000000001111777d11777777117710000001771001777776100000000000000167777611771677100000000000d66dd66d0000667000006dddddd0
001677100000000000000177610166666611661000000166100166666d1000000000000001d6666d11661d66100000000dd0000000000dd0d666700077666666
001d77711000000000011777d101dddddd11dd10000001dd1001ddddd100000000000000001dddd101dd11dd100000000000000000000000dd66676777777700
0001677771100000011777761000111111001100000000110000111110000000000000000001111000110011000000000000000000000000dddd666677767677
0001d677777111111777776d1000000000000000000000000000000000000000000000000000000000000000000000000000dd0000dd0000dd6dddd666666666
00001d6677777777777766d10000000000000000000000000000000000000000000000000000000000000000000000000d66d000000d66d0d0ddd6dddddddddd
000001dd667777777766dd1000000000000000000000000000000000000000000000000000000000000000000000000000d6776dd6776d00dddd0dddd6ddd6dd
00000011dd66666666dd1100000000000000000000000000000000000000000000000000000000000000000000000000d6776d0000d6776ddddddddd0ddd0ddd
0000000011dddddddd110000000000000000000000000000000000000000000000000000000000000000000000000000000d66d00d66d000dddddddddddddddd
00000000001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000dd00000000dd00dd1d1d1d1d1d1d1d
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd6d6d6d6d6d6d6d
00000000000000000000000001000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000017100000000000000000017100000000000000000000000000000000000000000000000000000000000dddddddddd00000000000
000000000000000000000001771000000000000000000177100000000000000000000000000000000000000000000000000000000dd66d6666666dd000000000
0000000000000000000000017771000000000000000017771000000000000000000000000000000000000000000000000000000dd6dddd666666666dd0000000
000000000000000000000001677100000000000000001776100000000000000000000000000000000000000000000000000000d6dd6d666666666666dd000000
000000000000000000000001d7771000000000000001777d10000000000000000000000000000000000000000000000000000d666ddd66666d66666666d00000
0000000000000000000000001677100000000000000177610011111111001100001100110000110001111111000000000000d6d66666666666666666666d0000
0000000000000000000000001d77710000000000001777d1017777777711771001771177100177101777777710000000000d666d66666666666666666666d000
000000000000000000000000016771000000000000177610017777777711777101771177100177117777777710000000000d666d66666666666666666666d000
00000000000000000000000001d777100000000001777d1001776666661177710177117710017711776666661000000000dd666dd66666667666666666666d00
0000000000000000000000000016771000000000017761000177dddddd117777117711771001771177dddddd1000000000ddd6dd666666666766666667676d00
000000000000000000000000001d7771000000001777d1000177111111017777117711771001771177111111000000000d6666ddd666dd6666676666d77766d0
0000000000000000000000000001677100000000177610000177111000017777717711771001771177111110000000000d6766666666666666667666666776d0
0000000000000000000000000001d77710000001777d10000177777100017777717711771001771177777771000000000d6666666666666667667666667766d0
0000000000000000000000000000167710000001776100000177777100017767777711771001771167777777100000000d6666666666666666667776677666d0
00000000000000000000000000001d777100001777d1000001776661000177d77777117710017711d6666677100000000d6677666666666666677767676666d0
0000000000000000000000000000016771000017761000000177ddd10001771677771177100177101ddddd77100000000d6677666666667dd6677777777666d0
000000000000000000000000000001d7771001777d100000017711100001771d777711771001771001111177100000000d6777776666666666776666776666d0
0000000000000000000000000000001677100177610000000177111111017711677711771111771011111177100000000d77777766766d6776776667666666d0
0000000000000000000000000000001d77711777d10000000177777777117711d77711777777771177777777100000000d766766777777676766dd66667666d0
0000000000000000000000000000000167711776100000000177777777117710167711677777761177777776100000000d76676776677776676d6dd6666666d0
00000000000000000000000000000001d777777d1000000001666666661166101d6611d666666d116666666d1000000000d6767666666676666d66d666666d00
00000000000000000000000000000000167777610000000001dddddddd11dd1001dd101dddddd101ddddddd10000000000d6666666666d66666ddd66d6666d00
000000000000000000000000000000001d7777d100000000001111111100110000110001111110001111111000000000000d666667666d66d66d66dd66d6d000
000000000000000000000000000000000167761000000000000000000000000000000000000000000000000000000000000d666666666666d6d66dd6666dd000
0000000000000000000000000000000001d66d10000000000000000000000000000000000000000000000000000000000000d6d666d66666666d6ddd666d0000
00000000000000000000000000000000001dd1000000000000000000000000000000000000000000000000000000000000000d66666666ddd66666ddd6d00000
000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000dd666666ddd66666666d000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd6666ddddd66dd6dd0000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd66666666d6dd000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddddd00000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202000000000000000000000009090b0b0000000000000000000000000808080800000000000000000000080800000000000000000000000000000000
0000000000000000080800000000080000000000000000080800000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000006060606000000000000000000000000060606060000000000000000000000000606060600000000000000000000000006060606
__map__
4200005300000053000000000044004200005200000042000000000053004400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000042000053004400430000000000005300530000530000530000000052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000530053000000000042005300000000000042000044000053000042005300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0043000000440000530000000000005300520000530000430000005200005300000000000000000000000000000000000000008d0050515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c40404141414140408d000000
000000420000000000000000420052005300005300520042000053000000004300000000000000000000000000000000000000000060636363636000000000000000000000000000000000008080000000000000000000000000000000000000000000000000000000000000000000000000009c40000000000000409d000000
0000000000000053004200000053000000000000000053000053000053000000000000000000000000000000000000000000000050626060606162500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008f40400000000000004040ae0000
530000005300440000530053000000000000530044000000004200000000534200000000000000000000000000000000000000006061606262606060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c9e9f40000000000000000040bebf8d
0000440000000000000000000000420053004200005300005300004453005300000000000000000000000000000000000051510060606060606060610051510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040414140000000000000000040414140
0000000052000000530043000053cccdcecf4200000053005300005300534200000000000000000000000000000000000063635060606262626260605063630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000040000000000000000040000040
0042000000004342000000440000dcdddedf0000530052000052534200430000000000000000000000000000000000000060626060606060606061606062600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000040
0000440053000000000000005300ecedeeef0000425300005300000000005344000000000000000000000000000000000061606060626262626262606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000040
0053530000000044420053000000fcfdfeff4200530000004400535253000053000000000000000000000000000000005050500060606161606060600050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040404040000000000000000040404040
000000000042000000000000005300530000005300004353000000000000420000000000000000000000000000000000000000500050505050505000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008eaf0040404040404040404040008eaf
00005300430000530000535343000000005300520000005300425300420000000000000000000000000000000000000000000000506e6f61636e6f500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000406e6f00006e6f4000000000
0052000000005300000000000053004253000000530000530000000000000053000000000000000000000000000000000000000000505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040404040400000000000
0000000044000000004200000053000053005300004200005300440000534300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008eaf00008eaf0000000000
5300430000530000000053005200430000000053005353000000004200530043000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004400000053004200530000000000530000000044000052000000004453000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000053005200530000000053005300440042005300530000420043530053000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4200530000000000000053000000000000005300000000530053005300000052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000530053430000000042000053000000534243004200005300005300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000535343000000005300520000530043000000440053000053000000424400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000530042000053000053000000530000005200530000005353005343000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0042000000530000520000004300004400000053000000440043420052000053000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5300004200005300004200445200000000530053000000530000530052004253000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0053005352000053000053000000534300005200534200000053004400005353000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4400420000530000004300004200000053420000004300005200000053004300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000053425342000000530053005300000053000053000053420042530042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4200520000004200005300000000004244530042000044005300530053000053000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000530000530000534200520053440000430000530053004300004200440052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5300000044530000530042000000005353000053520000000053000000530053000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0043004200005200004400535300430000424400005300420053535200530043000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01090000187561f746187361f726187161f706187061f706187061f706187061f706187061f706187061f706187061f706187061f706187061f706187061f706187061f706187061f706187061f706187061f706
015800001756100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200002462524600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
01040004185261b026185261b72600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706
011000040c556185560c5561855600506005060050600506005060050600506005060050600506005060050600506005060050600506005060050600506005060050600506005060050600506005060050600506
01040004185261c026185261c72600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706
010700001837018370183611836018351183501834118340183311833018321183201831118315000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000180c05300225002450020000225002353061024611002250023500230002250c05300225002450020000225002353061024611002250023500240002350020500205002050020500205002050020500200
0110001800330004150033006335073350a3300a3300a3200a2100a3120a3120a2151e9101e9101e9101e9101e9101e9100a320073350a3350632005335033450030500305003050030500305003000030000300
011000180c0030741507310245032b7110c50330600246012b700245002b7110c0530c00313415133101f0012b0000c50330600246011341513310134150c0530050000500005000050000500005000050000500
010c000018d2018d2018d2018d201881018822188321884118d2018d2018d2018d201881018822188321884118d2018d2018d2018d201881018822188321884118d2018d2018d2018d2018810188221883218841
0110001800330004150033006335073350a3300a3300a3200a3100a3100a3100a3100a3151e9101e9101e9101e9101e9101e9101e915063250632005335033450030500305003050030500305003000030000300
011000180c1100c1150c11012115131151611016110161101611016110161121611216112161151e9101e9101e9101e9101e9101e9150611512110111150f1151510509103151040910509105151040910100000
0110001818b1418b1018b1018b1018b2118b2018b2019b201ab311ab301bb311bb311cb411cb411cb411db411db411eb411eb411fb411fb4120b4121b4121b4118b4118b4018b4018b4018b4018b4018b4018b40
010c000024a2517a0530a050000024a25000002fa0530a0524a25000002fa0530a0524a252fa050000030a0524a252fa050000030a0524a252fa050000030a0524a25000002fa0530a0524a25000002fa0530a05
0110001821b4022b4122b4123b4123b4124b4124b4124b4125b4125b4126b4127b4128b4129b412ab412cb412eb412fb4131b4134b4136b4139b413cb413fb411530109301153010930109301153010930115301
0110001818b1018b1018b1018b1018b1018b1018b1018b1018b1018b1018b1018b1018b1018b1018b1018b1018b1018b1018b1018b1018b1018b1018b1018b101530509303153040930509305153040930115305
011000180c0033f2153f215245003f2153f21530600246012b7003f2153f2150c0430c0033f215133003f2152b0003f21530600246013f215133003f2153f2150050000500005000050000500005000050000500
011000180c0033f2153f215245003f2153f21530600246012b7003f2153f2150c0430c0033f215133003f2152b0003f2152444024420264402642028440284200050000500005000050000500005000050000500
010c00001ab201ab201ab201ab201a8101a8221a8321a8411ab201ab201ab201ab201a8101a8221a8321a8411ab201ab201ab201ab201a8101a8221a8321a8411ab201ab201ab201ab201a8101a8221a8321a841
0110001818e3018e2118e1118e1218e1518e0517e3017e2117e1117e1217e1517e001ae301ae211ae111ae121ae151ae0518e3018e2118e1118e1218e1518e0515e0009e0015e0009e0009e0015e0009e0015e00
011000180c0033f2153f215245003f2153f21530600246012b7003f2153f2150c0430c0033f215133003f2152b0003f2152444024420264402642028440284200050000500005000050000500005000050000500
011000180c05302225022450220002225022353061024611022250223502240022250c05302225022450220002225022353061024611022250223502240022251520509203152040920509205152040920115205
0110001824440244221f4401f4301f4221f415120053f2152b7003f2153f2150c0430c0033f215133003f215000001f4202444024420264402642028440264402000021000220002300024000097051570509705
011000181ae301ae211ae111ae121ae151ae0519e3019e2119e1119e1219e1519e051ce301ce211ce111ce121ce151ce051ae301ae211ae111ae121ae151ae0515e0009e0015e0009e0009e0015e0009e0015e00
011000180c05307225072450720007225072353061024611072250723507240072250c05307225072450720007225072353061024611072250723507240072251520509203152040920509205152040920115205
01100018264302642226422264152430224305233003f2152b7003f2153f2150c0430c0033f215133003f215263021f4402644026420284402842029440294201570509705157050970509705157050970515705
0110001818e3018e2118e1118e1218e1518e0517e3017e2117e1117e1217e1517e0515e3015e2115e1115e1215e1515e0517e3017e2117e1117e1217e1517e0515e0009e0015e0009e0009e0015e0009e0015e00
01100018284402842026440264322642226415003003f2152b7003f2153f2150c0430c0033f215133003f215000001f44028440284222b4402b42228440264400230102304153050930315304093050930515304
011000182444024420214401f4401f4321f412000003f2152b7003f2153f2150c0430c0033f215133003f21528305244402d4402d4222d4402d4222d4402d4221530409305093051530409301153050000000000
011000182b4402b42229440294302942229415120053f2152b7003f2153f2150c0430c0033f215133003f215000002942029440294202b4402b4202d4402b4402000021000220002300024000097051570509705
011000182b4402b4322b4202b4152b4022b405120053f2152b7003f2153f2150c0430c0033f215133003f215000002b4202b4402b4202d4402d4222e4402e4222000021000220002300024000097051570509705
011000182d4402d4222b4402b4302b4222b415120053f2152b7003f2153f2150c0430c0033f215133003f215000002b4202b4402b420294402942028440294402000021000220002300024000097051570509705
0110001829440294322942229412294151f405120053f2152b7003f2153f2150c0430c0033f215133003f215000001f4002440024400264002640028400264002000021000220002300024000097051570509705
011000180c05305225052450020005225052353061024611052250523505230052250c05305225052450020005225052353061024611052250523505240052350020500205002050020500205002050020500200
0110001821e3021e2121e1121e1221e1521e001fe301fe211fe111fe121fe151fe0522e3022e2122e1122e1222e1522e0521e3021e2121e1121e1221e1521e0515e0009e0015e0009e0009e0015e0009e0015e00
010c00001dd201dd201dd201dd201d8101d8221d8321d8411dd201dd201dd201dd201d8101d8221d8321d8411dd201dd201dd201dd201d8101d8221d8321d8411dd201dd201dd201dd201d8101d8221d8321d841
011000181fe301fe211fe111fe121fe151fe051ee301ee211ee111ee121ee151ee0521e3021e2121e1121e1221e1521e051fe301fe211fe111fe121fe151fe0515e0009e0015e0009e0009e0015e0009e0015e00
011000181de301de211de111de121de151de051ce301ce211ce111ce121ce151ce051ae301ae211ae111ae121ae151ae051ce301ce211ce111ce121ce151ce0518e0018e0018e0018e0018e0018e0018e0018e00
011000001d3301d3211d3111d3121d3151d3051c3301c3211c3111c3121c3151c3051f3301f3211f3111f3121f3151f3051d3301d3211d3111d3121d3151d3051850018500185001850018500185001850018500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000f3531e145211450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001b263044451a4550045500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000018642246523c6552464218632186221861200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001025311355306342462218612000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000436311365306441c25311355306341c24311345306241c23311335306141c22311325000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001b2530046317565154651356511465105650e4650c5550c4450c5350c4250c5150c415000000000000000000000000000000000000000000000000001b200044001a4000000000000000000000000000
010500002833528435000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001035330634246221861218612000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002455226552295522955229542295322952229515240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 0c 0d 11 0f
00 0c 0d 11 0f
00 0c 0d 0e 0f
00 0c 0d 10 0f
01 08 09 0b 0a
00 08 09 0b 0a
00 08 09 0b 0a
00 08 09 0b 0a
00 08 09 0b 12
00 08 09 0b 12
00 08 09 0b 12
00 08 09 12 0b
00 08 15 12 0b
00 17 19 12 14
00 1a 1c 12 0b
00 08 15 13 0b
00 08 18 15 0b
00 17 1b 19 14
00 1a 1d 1c 0b
00 08 1e 15 0b
00 23 1f 24 25
00 1a 20 26 0b
00 08 21 27 0b
02 23 22 24 25
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
