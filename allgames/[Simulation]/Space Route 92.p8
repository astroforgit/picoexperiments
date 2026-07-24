pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function s2t(str,join,concat) 
join=join or ','
local cn,t="", {}
for d=1,#str do
local n=sub(str,d,d)
if n ~= join then
cn=cn .. n
else
add(t, concat and cn or tonum(cn))
cn=""
end
end
add(t, concat and cn or tonum(cn))
return t
end
local cur_scn
local acts, inscene, purscn, partsys, actors
local cash=1000
local playership=nil
local SL_X,SL_CW,SL_EN,SL_PW,SL_SH,SL_WP,SL_CG=0,1,2,4,8,16,32
local SL_V=61
local system_colours, system_names, system_icon={},{},{}
system_colours[SL_CW]=14
system_colours[SL_EN]=4
system_colours[SL_PW]=11
system_colours[SL_SH]=12
system_colours[SL_WP]=8
system_colours[SL_CG]=9
system_names[SL_CW]="hABITATION"
system_names[SL_EN] ="eNGINE"
system_names[SL_PW]="pOWER"
system_names[SL_SH]="sHIELDS"
system_names[SL_WP] ="wEAPONS"
system_names[SL_CG] ="cARGO"
system_icon[SL_V]=39
system_icon[SL_CW]=12
system_icon[SL_EN]=13
system_icon[SL_PW]=14
system_icon[SL_SH]=15
system_icon[SL_WP]=28
system_icon[SL_CG]=29
local systems={
SL_EN,
SL_SH,
SL_WP,
SL_PW,
SL_CW,
SL_CG
}
local shiptemplates={
{
name="aPEX sHUTTLE",
seller="r. gUNNE",
description="aPEX mOLE CLASS SHUTTLECRAFT. sMALL, EASY TO HANDLE GOOD FOR NEW CAPTAINS.",
cost=5,
sprite=1,
detailsprite=64, 
scale=1,
bulk=0.5,
setup={
s2t"2,8,2",
s2t"16,32,16",
s2t"0,16,0",
},
layout={
s2t"2,14,2",
s2t"61,61,61",
s2t"0,61,0",
},
offset=8
},
{
name="pcg jOLIET 440",
seller="tITAN p.d.",
description="fORMER sPACEFORCE PATROL SHIP. cOMES WITH cOP sHIELDS,cOP iNERTIAL dAMPENERS, cOP eNGINES. cOCKPIT UTILITY SOCKET NON-FUNCTIONAL",
cost=20,
sprite=5,
detailsprite=72, 
scale=1,
bulk=1.5,
layout={ 
s2t"2,14,2,14,2",
s2t"16,61,45,61,16",
s2t"0,0,45,0,0",
s2t"0,0,45,0,0",
s2t"0,0,45,0,0"
},
setup={ 
s2t"2,2,2,2,2",
s2t"16,4,8,4,16",
s2t"0,0,8,0,0",
s2t"0,0,8,0,0",
s2t"0,0,8,0,0"
},
offset=8
},
{
name="pcg pICAROON",
seller="pLUT. rAKUN",
description="OLDER pEREGRINE cENTENNIAL FREIGHTER. gOOD SPEED, HIGH CARGO CAPACITY. mISSING FORWARD SCANNING ARRAY. sCORTCH MARKS ON EXTERIOR ONLY COSMETIC.",
cost=50,
sprite=3,
scale=1.5,
bulk=2,
detailsprite=68, 
layout={
s2t"0,2,2,2,0",
s2t"61,45,32,45,61",
s2t"61,45,32,45,61",
s2t"61,45,32,45,61",
s2t"16,0,0,0,16"
},
offset=10
},
{
name="rsc 10-07",
seller="C. fOSS",
description="rEFURBISHED WEAPON FRIGATE WITH CUSTOM 'dAZZLE cAMOFLAGE' PAINT JOB.",
cost=170,
sprite=7,
detailsprite=76, 
scale=2,
bulk=2.5,
layout={
s2t"2,14,2,14,2",
s2t"61,45,45,45,61",
s2t"16,28,45,28,16",
s2t"0,0,61,0,0",
s2t"0,0,28,0,0",
},
offset=14
},
{
name="aPEX bADGER",
seller="C. hARBATKIN",
description="lIGHTY USED GOODS TRANSPORT FOR SALE. cAVERNOUS CARGO BAY. cLASSIC DESIGN. oNE CAREFUL OWNER.",
cost=250,
sprite=9,
detailsprite=128, 
scale=2,
bulk=4,
layout={
s2t"0,0,2,2,2,0,0",
s2t"0,0,45,45,45,0,0",
s2t"2,0,45,45,45,0,2",
s2t"61,0,45,45,45,0,61",
s2t"61,0,45,45,45,0,61",
s2t"61,61,45,45,45,61,61",
s2t"0,0,45,45,45,0,0"
},
setup={
s2t"0,0,2,2,2,0,0",
s2t"0,0,32,32,32,0,0",
s2t"2,0,32,32,32,0,2",
s2t"1,0,32,32,32,0,1",
s2t"1,0,32,32,32,0,1",
s2t"1,1,1,1,1,1,1",
s2t"0,0,1,1,1,0,0"
},
offset=13.5
}
}
function dist(a1,a2) 
local a=a1-a2
if(a>64) a -= 128
if(a<-64) a += 128 
return a
end
function efct(sprite,behaviour,hasbounty, count) 
return function()
local spawned={}
for c=1,count or 1 do 
local enemy=actors:new() 
local trk=behaviour == 1 or behaviour == 2 
enemy.hp=1
enemy.time_on_screen=1
enemy.angle=rnd()
enemy.vx=(rnd()*10-5)*5
enemy.vy=(rnd()*10-5)
if behaviour == 1 then
enemy.hp=4
enemy.time_on_screen=300
end
if behaviour == 2  then
enemy.time_on_screen=-1
enemy.angle=0
end
enemy.sx=(sprite%16)*8
enemy.sy=flr(sprite/16)*8
enemy.collision_radius=8
enemy.z=-8
enemy.x=rnd()*128
enemy.y=rnd()*128
enemy.iframes=0
local rspeed=(rnd()-0.5)*2
local zinc=cocreate(ezc(enemy,8,0))
local zouc=cocreate(ezc(enemy,0,-8))
local coldt=function(self) 
if(self.z<-1 or self.z>1) return
if cur_scn ~= nil and tstc(self,cur_scn.player) then
if behaviour == 4 then
cargo_collected += 1
self:destroy()
sfx(12)
else
cur_scn.player:dmg(flr(rnd()*10)+25,self)
self.hp -= 1
end
end
end
enemy.dmg=function(self) 
if(self.iframes>0) return
self.iframes=5
self.hp -= 1
end
enemy.control=function(self)
if(self.z<1) coldt(self)
coresume(zinc)
if costatus(zinc) == 'dead' then
self.control=function(self)
coldt(self)
self.time_on_screen -= 1
self.iframes -= 1     
self.x=wrap(self.x)
self.y=wrap(self.y) 
local player=cur_scn.player
if(trk) then
local dx=dist(self.x,player.x)
local dy=dist(self.y,player.y)
self.vx= dx<0 and 3 or -3
self.vy= dy<0 and 3 or -3
end
if self.time_on_screen == 0 then
self.control=function(self)
self.iframes -= 1
if(self.z>-2) coldt(self)
coresume(zouc)
if costatus(zouc) == 'dead' then
self:destroy()
end
end
end
end
end
end
local draw_base=enemy.draw
enemy.draw=function(self)
if self.hp <= 0  then
self:destroy()
sfx(14)
printh("hasbounty"..(hasbounty and 'yes' or 'no'),"bounty")
if(hasbounty) enemies_slain += 1
end
if(trk == false) self.angle += 0.01*rspeed
if(global_step % 12<3) pal(9,10)
if self.z>5 then 
pal(3,0)
pal(14,0)
pal(11,1)
pal(13,1)
pal(6,0)
pal(5,0)
pal(1,0)
elseif self.z>3 then 
pal(3,1)
pal(14,2)
pal(11,3)
pal(13,5)
pal(6,1)
pal(5,0)
pal(1,0)
elseif self.z>1 then 
pal(11,3)
pal(13,5)
pal(6,5)
pal(5,1)
pal(1,0) 
end
draw_base(self)
pal()
end
add(spawned,enemy)
end
return spawned
end
end
local enc_tmp={
{ 
title="pIRATE mINEFIELD",
pallete=1,
bdur=1000,
music=9,
enemies_rate=6, 
enemies={efct(199,2,true,3)}
},
{ 
title="sPACE rOUTE 92",
pallete=0,
bdur=0
},
{ 
title="sKUB hIVE",
pallete=1,
bdur=1000,
music=9,
enemies_rate=1, 
enemies={efct(203,1,true,1),efct(105,3,false,3)}
},
{ 
title="aSTEROID fIELD",
bdur=500,
music=9,
pallete=5,
enemies_rate=.5,        
enemies={efct(142,3,false,2),efct(174,3,false,2),efct(235,3),efct(44,4)} 
},
{ 
title="oLD wRECK",
bdur=500,
music=13,
pallete=2,
enemies_rate=3, 
enemies={efct(46,3),efct(44,4),efct(73,4)} 
}
}
local levels={
{
dstnt="sPACE sTATION k-9",
encounters=s2t"1,2,4,5,2,2",
totenc=4,
mx=0,my=0,mw=7,mh=8
} ,
{
dstnt="bALAKLAVA",
encounters=s2t"1,1,2,2,2,2,4,4,5,5",
totenc=6,
sx=16, sy=32,
mx=8,my=0,mw=8,mh=8
} ,
{
dstnt="sTORMWING v",
encounters=s2t"1,1,1,2,2,2,2,4,4,4,5,5,5",
totenc=8,
sx=32, sy=32,
mx=16,my=2,mw=11,mh=5
} ,
{
dstnt="tEBAY sERVICES",
encounters=s2t"1,1,1,2,2,2,2,2,2,3,4,4,4,5,5,5",
totenc=10,
sx=48, sy=32,
mx=27,my=0,mw=8,mh=7
} ,
{
dstnt="sATELLITE OF lOVE",
encounters=s2t"1,1,1,1,2,2,2,2,2,3,3,4,4,4,4,5,5,5,5",
totenc=12,
sx=64, sy=32,
mx=36,my=2,mw=9,mh=5
} ,
{
dstnt="wAKEMAN sTATION",
encounters=s2t"1,1,2,2,2,2,2,3,3,3,3,3,3,3,4,4,4,4,5,5,5,5,5,5,5,5,5,5",
totenc=15,
sx=80, sy=32,
mx=46,my=2,mw=8,mh=5
} ,
{
dstnt="fREEDOM sTAR", 
encounters=s2t"1,1,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,4,4,4,4,4,4,5,5,5,5,5",
totenc=17,
sx=96, sy=32,
mx=55,my=2,mw=4,mh=4
} 
} 
function gsfs(setup,slot)
slots={}
for iy=1,#setup do
for ix=1,#setup[iy] do
if(band(setup[iy][ix],slot)>0) add(slots,{x=ix,y=iy})
end
end
return slots
end 
for t in all(shiptemplates) do 
local setup={}
for k,v in pairs(t.layout) do
local row={}
for l,b in pairs(v) do
row[l]=0
for p=1,8 do
if(band(2^p,b)>0)then
row[l]=2^p
break
end
end
end
add(setup,row)
end
t.setup=t.setup or setup
end
function bounce_ease(t)
if t<1/2.75 then
return (7.5625*t*t)
elseif t<2/2.75 then
t=t-(1.5/2.75)
return (7.5625*t*t+0.75) 
elseif t<2.5/2.75 then
t=t-(2.25/2.75)
return (7.5625*t*t+0.9375)
end
t=t-(2.625/2.75)
return (7.5625*t*t+0.984375)
end
function lerp(a,b,t)
return (b-a)*t+a
end
local box_colours={
s2t"8,7,0", 
s2t"7,4,7", 
s2t"7,3,7", 
s2t"0,7,0", 
s2t"0,10,0", 
s2t"1,0,7", 
s2t"7,8,7", 
}
function ezc(enemy,from,to,duration)
duration=duration or 90
return function() 
for t=0,duration do
enemy.z=lerp(from or 8,to or 0,t/duration)
yield()
end
end
end
function draw_box(x,y,w,h,border,bg,corner,horiz,vert,pallete) 
local text_colour=7
if pallete and pallete>0 then
pal(7,box_colours[pallete][1])
pal(12,box_colours[pallete][2])
end
rectfill(x+border,y+border, x+w-border, y+h-border,bg)
spr(corner,x,y)
spr(corner,x+w-border,y,1,1,true,false)
spr(corner,x,y+h-border,1,1,false,true)
spr(corner,x+w-border,y+h-border,1,1,true,true)
sspr((vert % 16)*8,flr(vert/16)*8,8,8,x,y+border,border,h-border*2)
sspr((horiz % 16)*8,flr(horiz/16)*8,8,8,x+border,y,w-border*2,border)
sspr((vert % 16)*8,flr(vert/16)*8,8,8,x+w-border,y+border,border,h-border*2,true,false)
sspr((horiz % 16)*8,flr(horiz/16)*8,8,8,x+border,y+h-border,w-border*2,border,false,true)
pal()
if pallete and pallete>0 then
pal(7,box_colours[pallete][3])   
end
end
inscene=function()
local yt=0
music(2)
local paln=flr(rnd()*(#box_colours+1))
local starfield=csfld()
return {
draw=function(self)
cls(0)
camera()
partsys:draw(-1)
if(yt<1) yt += 0.01
camera(0,lerp(32,-32,bounce_ease(yt)))
draw_box(4,4,120,28,8,12,193,192,208,paln) 
sspr(16,112,64,16,30,8)
sspr(16,112,72,16,30,8)
sspr(16,96,24,16,96,8)
sspr(0,112,16,16,8,8) 
camera()
pal()
if(yt >= 1) print("pRESS \142 TO START",32,68,7)
end,
update=function(self)
partsys:update()
if btnp(4) then
partsys:kill(starfield)
cur_scn=purscn()
end
if(btnp(0)) paln -= 1
if(btnp(1)) paln += 1
paln=mid(0,paln,#box_colours)
end
}
end
purscn=function()
music(0)
pal()
palt()
local STATE_KEY=1    
local STATE_SLOTFOCUS=2
local current_state=STATE_KEY
local curr_tmplt_id=0
local slot_x,slot_y=0,0
local curr_tmplt
local highlightbtn=0
local highlightframes=0
local drawship, drawkey,drawstats
local dsf,drawnavigation
local updateslotfocus,updatenavigation 
local next_template=function()
curr_tmplt_id += 1
curr_tmplt_id %= #shiptemplates  
end
local prev_template=function()
curr_tmplt_id -= 1
if(curr_tmplt_id<0) curr_tmplt_id=#shiptemplates-1 
end
local highlight_colour=function(id) 
if(id ==highlightbtn and highlightframes>0) return 8
return 7
end
local update=function(self)
if current_state == STATE_KEY then updatekey()
elseif current_state == STATE_SLOTFOCUS then updateslotfocus() end
if(highlightframes>0) highlightframes -= 1
end
local fnos=function(sx,sy,layout,isopen)
isopen=isopen or (function(slot) return (slot ~= SL_X) end)
layout=layout or curr_tmplt.layout
local ox=sx-1
local oy=sy-1
for x=ox, ox+#layout do
local mx=(x % #layout)
for y=oy, oy+#layout do
local my=(oy % #layout)
if( isopen(layout[my+1][mx+1]) ) return mx+1,my+1
end
end
return sx,sy
end
local draw=function(self)
if(curr_tmplt ==nil) return
camera()
pal()
palt()
cls(0)
drawship()
printl(curr_tmplt.description,5,73,30,6)
drawnavigation(4,112)
drawstats(72,32)
drawstats(72,32)
end
updateslotfocus=function()
if btnp(1)  then
highlightframes=6
highlightbtn=1
slot_x += 1
end
if btnp(0)  then
highlightframes=6
highlightbtn=2
slot_x -= 1
end
if btnp(2)  then
highlightframes=6
highlightbtn=3
slot_y -= 1
end
if btnp(3)  then
highlightframes=6
highlightbtn=4
slot_y += 1
end
if(slot_x<1) slot_x=#curr_tmplt.layout[1]
if(slot_x>#curr_tmplt.layout[1]) slot_x=1
if(slot_y<1) slot_y=#curr_tmplt.layout
if(slot_y>#curr_tmplt.layout) slot_y=1
slot_x, slot_y=fnos(slot_x,slot_y)
if btnp(5)  then 
menu("rEADY TO LAUNCH?",{"cHANGE lOADOUT","cHANGE sHIP","launch!"},1,function(m) 
if(m ~= 1) then 
slot_x, slot_y=0,0 
current_state=STATE_KEY
end
if(m == 3) then 
cur_scn=acts(curr_tmplt,current_level_index)
end
end)
end
if btnp(4)  then  
local items={}
local values={}
local ccell=curr_tmplt.layout[slot_y][slot_x]
local equipped=curr_tmplt.setup[slot_y][slot_x]
local equipped_index=1
for i in all(systems) do
if band(i,ccell)>0  then
add(items,system_names[i])
add(values,i)
if(band(i,equipped)>0) equipped_index=#items
end
end
menu("cHANGE sLOT TO",items,equipped_index,function(new_index)  
sfx(41)
curr_tmplt.setup[slot_y][slot_x]=values[new_index]
end)
end
end
dsf=function(x,y)
local _y=y
local ccell=curr_tmplt.layout[slot_y][slot_x]
local equipped=curr_tmplt.setup[slot_y][slot_x]
for i in all(systems) do       
if band(i,ccell)>0  then
print(">"..system_names[i].. (((band(i,equipped)>0) and '<') or ''),x,_y,system_colours[i] )
_y += 6
end
end
end
drawship=function()
palt(0,true) 
rect(1,1,127,127,1)
rect(4,4,125,70,current_state == STATE_SLOTFOCUS and 7 or 1)
local sx, sy=(curr_tmplt.sprite % 64)*8, flr(curr_tmplt.sprite/64)*32
print(curr_tmplt.name, 68, 6, 7) 
if curr_tmplt.owned == true  then
print("> yOU",73,12,11)
print("cASH:"..to_money(cash),71,18,11)
print("hULL:"..curr_tmplt.hull .. "/"..(curr_tmplt.bulk*100)  ,71,24,11)
else
print(">"..curr_tmplt.seller,73,12,7)
print("cOST:"..to_money(curr_tmplt.cost),71,18,7)
if cash<curr_tmplt.cost then
print("cASH:"..to_money(cash),71,24,8)
else
print("cASH:"..to_money(cash),71,24,7)
end
end
draw_ship_template(curr_tmplt, 10,10,52, slot_x,slot_y)
sspr(33,64,73,20,52,108) 
end 
drawstats=function(dx,dy)
local engine,weapon,shield,lasers,engines,power,cargo,crew,shields,total_slots,bulk=gtstat(curr_tmplt)
print("eNG:"..flr(engine*100/bulk),dx,dy,4) 
print("wEP:"..flr(weapon*100), dx,dy+6,8)
print("sHIELD:"..flr(shield*100), dx,dy+12,12)
print("cARGO:"..#cargo*2, dx,dy+18,9)
print("pSSNGR:"..#crew*7, dx,dy+24,14)
end
drawnavigation=function(x,y)
if current_state == STATE_KEY  then 
print("\139",x,y, highlight_colour(2))
print((curr_tmplt_id+1) .." of " .. #shiptemplates,x+9,y,7)
print("\145",x+34,y, highlight_colour(1))
color((cash >= curr_tmplt.cost or curr_tmplt.owned == true) and 7 or 8)
print("\142",x,y+6) 
print(curr_tmplt.owned and 'uSE' or "bUY",x+8,y+6)
end
if current_state == STATE_SLOTFOCUS  then 
print("\139",x,y+4, highlight_colour(2))
print("\145",x+12,y+4, highlight_colour(1))
print("\148",x+6,y, highlight_colour(3))
print("\131",x+6,y+8, highlight_colour(4))
print("\142",x+20,y ,7) 
print("eQUIP",x+28,y, 7)
print("\151",x+20,y+6, 7) 
print("sTART",x+28,y+ 6,7)
end
end
updatekey=function()  
if btnp(1)  then
highlightframes=6
highlightbtn=1
next_template()
end
if btnp(0)  then
highlightframes=6
highlightbtn=2
prev_template()
end
if btnp(4)  then 
if curr_tmplt.owned == true  then
if(curr_tmplt.hull<(curr_tmplt.bulk*100) and cash>0) then
local hull_to_repair=((curr_tmplt.bulk*100)-curr_tmplt.hull)
local repair_cash=min(hull_to_repair*0.1,cash)
confirm('rEPAIR THIS SHIP FOR' .. to_money(repair_cash) ..'?',function() 
cash -= repair_cash
curr_tmplt.hull=ceil(min(curr_tmplt.bulk*100, curr_tmplt.hull+repair_cash*10))
end)
else
confirm( 'dO YOU WANT TO USE THIS SHIP?',function() 
playerhull=curr_tmplt.hull
current_state=STATE_SLOTFOCUS
slot_x, slot_y=1,1
end)
end
elseif cash >= curr_tmplt.cost then
confirm( 'aRE YOU SURE YOU WANT PURCHASE THIS SHIP?',function()
playerhull=nil
cash -= curr_tmplt.cost
curr_tmplt.owned=true
ships_owned += 1
curr_tmplt.hull=curr_tmplt.bulk*100
sfx(15)
playerhull=curr_tmplt.hull
current_state=STATE_SLOTFOCUS
slot_x, slot_y=1,1
end)
else
confirm('yOU CANNOT AFFORD THIS SHIP',nil,nil,7)
end
end
curr_tmplt=shiptemplates[curr_tmplt_id+1]
end
drawkey=function(dx,dy) 
local _y=dy 
for i in all(systems) do            
print(">"..system_names[i],dx,_y,system_colours[i])
_y += 6
end
end 
return {        
update=update,
draw=draw
}
end
function gtstat(ship_template)
local lasers,power,engines,cargo,crew,shields=gsfs(ship_template.setup, SL_WP)
,gsfs(ship_template.setup, SL_PW)
,gsfs(ship_template.setup, SL_EN)
,gsfs(ship_template.setup, SL_CG)
,gsfs(ship_template.setup, SL_CW)
,gsfs(ship_template.setup, SL_SH)
local power_distro=#power/((#engines>0 and 1 or 0)+(#lasers>0 and 1 or 0)+(#shields>0 and 1 or 0 ))
local engine, weapon, shield=(#engines>0 and (#engines+power_distro)) or 0
,(#lasers>0 and (#lasers+power_distro)) or 0
,(#shields>0 and (#shields+power_distro )) or 0
return engine,weapon,shield,lasers,engines,power,cargo,crew,shields,#lasers+#engines+#power+#cargo+#crew+#shields,ship_template.bulk or 2
end
game_over_scene=function(x,y) 
local death_time=120
actors:clear()
music(16)
for i=1,7 do
cexp(x+rnd()*10-20,y+rnd()*10-20,0,27)
end
return {
update=function(self)
if(death_time>0) death_time -= 1
if(btnp(4) and death_time <= 0) reset_game()
actors:update()
end,
draw=function(self)
actors:draw()
print("gAME oVER!",12,64,7)
print("yOUR SHIP WAS DESTROYED",12,70,7)
end
}
end 
acts=function(ship_template,level)
music(-1)
playership=ship_template
level=level or 1
local engine,weapon,shield,lasers,engines,power,cargo,crew,shields,total_slots,bulk=gtstat(ship_template)
current_level=levels[level]
local encounters,encounter,state, time_left,enc_dur,camera_shake,warpfield= shuffle(current_level.encounters)
,1
,1
,60*5
,0
,0
,csfld(.5,5,0.001,{0,5,6,7,7,7},1)
warpfield.drawparticle=function(self,p)  
line(p.x,p.y,p.x-sin(p.a)*5, p.y-cos(p.a)*5,self:get_colour(p) )
end
cargo_collected,enemies_slain,playerhull ,playershields= 0
,0
,playerhull or playership.bulk*100
,shield *100
music(enc_tmp[encounters[encounter]].music or -1)  
local intro_update=function() 
if time_left <= 0 then
enc_dur=0
if enc_tmp[encounters[encounter]].bdur>0 then
enc_dur=mid(5000,25, enc_tmp[encounters[encounter]].bdur*(bulk/engine))*10
time_left=enc_dur
sfx(7)
state=2
else
time_left=300
state=3
enc_dur=0
end
end
end
local enemy_countdown=0
local spawned_enemies={}
function spwn_en() 
local enc=enc_tmp[encounters[encounter]]
if(enc.enemies == nil or #enc.enemies == 0) return
enemy_countdown=60*enc.enemies_rate*(rnd() *0.2+0.9)
local spawned=enc.enemies[flr(rnd()*#enc.enemies)+1]()
for k,v in pairs(spawned) do
add(spawned_enemies,v)
v.ondestroy=function(self)  
del(spawned_enemies,self)
end
end
end
function gdistline(dstnt,distance,width)
local spaces=""
width=width or 32
for i=1, width -(#dstnt+#(""..distance)) do
spaces=spaces .. " "
end
return dstnt .. spaces .. distance
end
local intro_draw=function() 
local enc=enc_tmp[encounters[encounter]]
camera(0,-24)
if(time_left>250) camera(0,lerp(128,-24,bounce_ease((300-time_left)/50)))
if(time_left<50) camera(0,lerp(-24,128,bounce_ease((50-time_left)/50)))
pal()
local distance=current_level.totenc-encounter+1
local next_levels={enc.title,"","",gdistline(current_level.dstnt,distance,23)}
for i=(level)+1,#levels do
distance += levels[i].totenc
add(next_levels,gdistline(levels[i].dstnt , distance,23))
end
draw_box(12,0,104,#next_levels*6+12,8,12,193,192,208, enc.pallete)
prlns(next_levels,18,6,7)
pal()
end
local outro_update=function(self)
for enemy in all(spawned_enemies) do
enemy:destroy()
end 
spawned_enemies={}
if time_left <= 0  then 
state=1
encounter += 1 
time_left=60*5
enemy_countdown=0
if encounter>current_level.totenc then
partsys:kill(self.starfield)
partsys:kill(warpfield)
self.player:destroy()
current_level_index=level+1       
swp_res()
return
end   
music(enc_tmp[encounters[encounter]].music or -1)          
end
end
local dstnt_draw=function()
if encounter >= current_level.totenc then
local t=mid(0,(300-time_left)/250,1)
camera(-64,-lerp(-64,96,t))
map(current_level.mx,current_level.my,-current_level.mw*4,-current_level.mh*4,current_level.mw,current_level.mh)
camera()
end
end
local outro_draw=function()
if encounter >= current_level.totenc then
camera(0,-32)
local lines,height=gpl("wELCOME TO " .. current_level.dstnt,17)
draw_box(12,0,104,height+12,8,12,193,192,208, 4)
prlns(lines,18,6,7)
end
end
function createplayer() 
local player=actors:new()
local lasercooldown,laserx,lasera,laserindex,slotscale,slotoffset,enginescale,weaponrefire=0
,{5,-6}
,{-0.01,0.01}
,0        
,12*ship_template.scale/#ship_template.setup
,ship_template.offset or 8
,engine/bulk
,(weapon>0 and 1/weapon) or 0
player.sx=(ship_template.sprite % 16)*8
player.sy=flr(ship_template.sprite/16)*8     
player.collision_radius=ship_template.scale* 8
player.enginescale=enginescale
player.control=function(self)
self.iframes=mid(0,(self.iframes or 0)-1,4)
if btn(0) then 
self.angle -= 0.01
end
if btn(1) then 
self.angle += 0.01
end
self.angle %= 1
local dx,dy,acceleration=sin(self.angle),cos(self.angle),0
acceleration=btn(2) and 100 or btn(3) and -50 or 0
if (btn(4))  self:shootlaser() 
self.v=acceleration
self.tx=dx*self.v
self.ty=dy*self.v
if acceleration ~= 0 then
self.vx=movetowards(self.vx,self.tx,0.25*enginescale)
self.vy=movetowards(self.vy,self.ty,0.25*enginescale)
end
if acceleration>0 then 
local pv=-2 
for thruster in all(engines) do
thruster_x,thruster_y=(thruster.x*slotscale)-slotoffset,(thruster.y*slotscale)-slotoffset
emitfromrotatedpoint(self.thrusters,self.x,self.y,thruster_x,thruster_y+4,self.angle,pv) 
end
sfx(0)
end
if acceleration<0 then
local pv= .8
emitfromrotatedpoint(self.retros,self.x,self.y,1,4, self.angle,pv) 
emitfromrotatedpoint(self.retros,self.x,self.y,-2,4, self.angle,pv) 
sfx(1)
end
if(lasercooldown>0) lasercooldown -= 0.016666
end
player.dmg=function(self,dmg,other) 
if(self.iframes>0) return
self.iframes=20
if playershields>0 then
playershields -= dmg
sfx(8)
if(playershields <= 0) sfx(11)
camera_shake=4
else
playerhull -= dmg
sfx(9)
camera_shake=12
end
end
player.shootlaser=function(self) 
if lasercooldown <= 0 and #lasers>0 then
sfx(2)
lasercooldown=weaponrefire
local claser=lasers[laserindex+1]
local laserx, lasery=rotate_point((claser.x*slotscale)-slotoffset,(claser.y*slotscale)-slotoffset,-self.angle)
laserindex=(laserindex+1) % #lasers
local laser=actors:new()
laser.x=self.x+laserx
laser.y=self.y+lasery 
local _d=laser._draw
laser.draw=function(self) 
line(self.x,self.y,self.x-sin(self.a)*10,self.y-cos(self.a)*10,3)
end 
laser.a=player.angle
laser.t=0.25
laser.collision_radius=2
laser.update=function(_self) 
_self.x += sin(_self.a)*4
_self.y += cos(_self.a)*4
if _self.t <= 0 then
_self:destroy()
else
_self.t -= 0.016666
end
_self.x=wrap(_self.x)
_self.y=wrap(_self.y)
for enemy in all(spawned_enemies) do
if enemy.z<2 and enemy.z>-1 then
if tstc(laser,enemy) then
enemy:dmg()
_self:destroy()
cexp(_self.x-4,_self.y-4,11)
end
end
end
end
end
end
player.update=update_wrap
player.draw=function(self) 
if((self.iframes or 0 )% 4 == 0) draw_wrap(self,ship_template.scale)
if playershields>0 then
circ(self.x,self.y,self.collision_radius+4,12)
end 
end
player.v=0
local retros=partsys:new(0,0,0.15,-1)
retros.neverdie=true
retros.colours={6,6,5,6,5,5,1,5,1,1,0}
local thrusters=partsys:new(0,0,.35,-1)
thrusters.size=function(self,p) 
return (p.t*1.5)+0.5
end
thrusters.time=function(self,p)
return p.t-0.016666/self.lifetime*(rnd(2)+1)
end
thrusters.neverdie=true
thrusters.colours= {10,10,9,10,9,9,10,9,4,4,9,4,2,2,4,2,1,1,2,1}
thrusters.updateparticle=function(self,p) 
p.x, p.y=wrap(p.x),wrap(p.y)
end
player.retros=retros
player.thrusters=thrusters
return player
end
local update=function(self) 
partsys:update()
actors:update()
time_left -= 1
cargo_collected=mid(0,cargo_collected,#cargo*2)
if(state == 1) intro_update(self)         
if state == 2  then
enemy_countdown -= 1 
if(enemy_countdown <= 0) spwn_en() 
if time_left <= 0 then
state=3
time_left=60*5
enc_dur=0
music(-1)
sfx(6)
end
end
if(state == 3) outro_update(self)
if(playerhull <= 0) cur_scn=game_over_scene(self.player.x+8, self.player.y+8)
end
local draw=function(self)
camera()
cls()
pal()
palt()
palt(0,true) 
if camera_shake>0 then
camera_shake -= 1
camera(rnd()*10-5,rnd()*10-5)
end
if(state != 2) partsys:draw(1) 
partsys:draw(-1) 
if(state == 3) dstnt_draw(self)
actors:draw()
partsys:draw(0)
if #lasers>0 then
local px,py=rotate_point(0,48,-self.player.angle)
local tx,ty=self.player.x +px,self.player.y+py
circ(tx         ,ty         ,2,5) 
circ(tx+128   ,ty         ,2,5) 
circ(tx-128   ,ty         ,2,5) 
circ(tx         ,ty+128   ,2,5) 
circ(tx         ,ty-128   ,2,5) 
end
if(state == 1) intro_draw(self)
if(state == 3) outro_draw(self)        
camera()
pal()
if(camera_shake>0) camera(rnd()*10-5,rnd()*10-5)
if enc_dur>0 then
rectfill(1,1,72,9,1)
rectfill(1,1,72*max(0.03,(1-time_left/enc_dur)),9,4)
rect(1,1,72,9,5)
print("jUMP RECHARGE " .. flr((1-time_left/enc_dur)*100).."%",3,3,7)
end 
print("cARGO:"..cargo_collected.."/"..#cargo*2,3,112,cargo_collected<#cargo*2 and 7 or 3)
print("pASSENGERS:"..#crew*7,64,112,7) 
print("sHIELDS:"..max(0,flr(playershields)).."/"..flr(shield *100),3,120,playershields>0 and 7 or 8)
print("hULL:"..max(0,flr(playerhull)).."/"..flr(playership.bulk*100),78,120,playerhull>30 and 7 or 8) 
print("bOUNTIES:"..enemies_slain,78,3,7) 
end 
local scene={
player=createplayer(),
starfield=csfld(),
update=update,
draw=draw
}
return scene
end
function csfld(lifetime,speed, emit, colours, layer)
local starfield=partsys:new(64,64,lifetime or .5,-1)
starfield.neverdie=true
starfield.emit=emit or 0.05
starfield.colours=colours or {0,1,1,5,5,6,6,7}
starfield.emitcd=0
starfield.layer=layer or -1
starfield.size=function(self,p) 
return (1-p.t)*.5 +0.5
end
starfield.onupdate=function(self) 
if starfield.emitcd<0 then
starfield.emitcd=starfield.emit
starfield:add(0,0,rnd(1),speed or 2)
else
starfield.emitcd -= 0.01666666
end
end
return starfield 
end
function to_money(v)  
if(v<1000) return "$"..(flr(v*10)/10).."K"
return "$" .. flr(v)/1000 .. "m"
end
function draw_ship_template(template,x,y,s,highlight_x,highlight_y)
local _x=x
local _y=y
local maxcount=max(#template.layout, #template.layout[1])
local _cellsize=flr(s/maxcount) 
local yoffset=(s-(_cellsize*#template.layout))/2
local xoffset=(s-(_cellsize*#template.layout[1]))/2
_y += yoffset
local sc_w=8
local sc_h=8 
for ri=1,#template.layout do
local row=template.layout[ri]
_x=x+xoffset
for ci=1,#row do
local col=row[ci]
if col ~= 0 then
local installed_component=(template.setup ~= nil and template.setup[ri][ci]) or -1
rectfill(_x,_y,_x+_cellsize,_y+_cellsize, 0)
rect(_x,_y,_x+_cellsize,_y+_cellsize,1)
local stripes={}
local c=col 
for i in all(systems) do                    
if band(c,i)>0 then
c=c-i
local sx, sy=(system_icon[i] % 16)*8, flr(system_icon[i]/16)*8
sspr(sx,sy,sc_w,sc_h,_x+1, _y+1,_cellsize-1, _cellsize-1)  
else 
end
end    
if installed_component>0 then 
rectfill(_x+_cellsize/4 ,_y+_cellsize/4,_x+_cellsize/4*3 ,_y+_cellsize/4*3,system_colours[installed_component] )
rect(_x+_cellsize/4 ,_y+_cellsize/4,_x+_cellsize/4*3 ,_y+_cellsize/4*3,7 )
end             
end
_x += _cellsize
end
_y += _cellsize
end
if highlight_x>0 and highlight_y>0 then
rect(
x+xoffset+_cellsize*(highlight_x-1),
y+yoffset+_cellsize*(highlight_y-1),
x+yoffset+_cellsize*(highlight_x),
y+xoffset+_cellsize*(highlight_y),
7
)
end
end
function movetowards(a,t,d) 
if(a<t) return a+d
if(a>t) return a-d
return a
end
function emitfromrotatedpoint(emitter,x,y,ox,oy,angle,velocity)
local tx,ty=rotate_point(ox,oy,-angle)
return emitter:add(x+tx, y+ty, angle, velocity)
end
wordboundaries=" ,.;:-"
function iwb(char) 
for i=1,#wordboundaries do
if(char == sub(wordboundaries,i,i)) return true
end
return false
end
function gpl(str,w) 
if(#str <= w) return {str},6
local lines={}
local line=""
local word=""
for i=1, #str do
local char=sub(str,i,i)
if(char ~= "\n" and char ~= "\t") word=word .. char
if char == "\t"  then
for i=#word % 4,4 do
word=word .. " "
end
char=" "
end
if iwb(char)  or char == '\n' then
if #(line .. word) >= w or char == '\n' then
add(lines, line)
line=""
end
line=line .. word
word=""
end
end
line=line .. word
add(lines, line)
return lines, #lines*6
end
function printl(str,x,y,w,c)
if(str == nil) return
local lines=gpl(str,w)
prlns(lines,x,y,c)
end
function prlns(lines,x,y,c)
for l=1,#lines do
print(lines[l], x,y+(l-1)*6,c)
end
return #lines*6
end
function _init() 
reset_game()
end
function reset_game()
cash=15
playership=nil
current_level_index=nil
cur_scn=inscene()
for k,t in pairs(shiptemplates) do
t.owned=false 
end    
ships_owned=0
end
function _update60()
global_step=((global_step or 0)+1) % 120
cur_scn:update()
end
function _draw()
cur_scn:draw()
camera()
end
function print_achievments()
?"yOUR SHIP: "..playership.name
?""
if(shiptemplates[1].owned == true and ships_owned == 1) then         
?"yOU MADE IT HERE IN JUST"
?"A shuttle?! aRE YOU crazy?!" 
elseif(shiptemplates[1] == playership) then
?"wHAT HAPPENED TO YOUR OTHER"
?"SHIPS?" 
end
if(shiptemplates[2] == playership) then
?"tHERE'S 72 au TO THE FREEDOM"
?"STAR, IT'S SPACE, AND WE'RE"
?"WEARING SUNGLASSES"
end
if(shiptemplates[3] == playership) then
?"yOU MADE THE FREEDOM RUN IN"
?"0.000349066 PARSECS!" 
end
if(shiptemplates[4] == playership) then
?"gOOD CHOICE, IT'S A WORK OF ART" 
end
if(shiptemplates[5] == playership) then
?"sO LET ME MAKE THIS ABUNDANTLY" 
?"CLEAR: i DO THE JOB AND THEN i" 
?"GET PAID..."
?"NO ALTERING THE DEAL."
end
end
function swp_res()
local cargo_cash,pssngr_cash,bounty_cash=cargo_collected*4
,#gsfs(playership.setup, SL_CW)*.5*current_level.totenc
,enemies_slain*0.4
cash += cargo_cash
cash += pssngr_cash
cash += bounty_cash
playership.hull=playerhull
sfx(10)
music(8)
cur_scn={
update=function()
if btnp(4) then                 
if current_level_index <= #levels then
cur_scn=purscn()
else
music(21)
cur_scn={
update=function()
if(btnp(4)) reset_game()
end,
draw=function() cls()
camera()
map(55,2,64,64,4,4)
?"cONGLATURATION !!!"
?"yOU REACHED THE FREEDOM STAR"
?"wITH "..to_money(cash)
?""
print_achievments()
end
}
end
end
end,
draw=function(self) 
camera(0,-6)
draw_box(12,0,104,78,8,12,193,192,208, 3)
camera(-18,-12)
cursor(0,0)
color(7)            
?"rESULTS"
?gdistline("cARGO:","+"..to_money(cargo_cash),23)
?gdistline("pASSENGERS:","+"..to_money(pssngr_cash),23)
?gdistline("bOUNTIES:","+"..to_money(bounty_cash),23)
?""
color(7)
?gdistline("cASH REMAINING:",to_money(cash),23)
?""
?"press \142"
self.draw=function() end
end
}
end 
function menu(title,items,selected,ok,cancel)
local scene=cur_scn
selected=selected or 1
cur_scn={
draw=function(self)
camera(-16,-68)
local lines,height=gpl(title,24) 
draw_box(-6,-2,102,height+(#items*8)+16,8,12,193,192,208) 
prlns(lines,2,2,7) 
for i=1, #items do
print( (i == selected and "\134" or "")..items[i],6,i*8+height-4,(i == selected and 8) or 7)
end
print("\142 ok, \151 cancel",2,height+(#items*8)+4,7)
end,
update=function(self)
if btnp(2) then
selected -= 1
elseif btnp(3) then
selected += 1
end
selected=mid(1,selected,#items)
if btnp(4) then
cur_scn=scene
if(ok ~= nil) ok(selected)
elseif btnp(5) then
cur_scn=scene
if(cancel ~= nil) cancel(selected)
end
end
}
end
function confirm(dlg,ok,cancel,p) 
local scene=cur_scn
sfx(40)
cur_scn={
draw=function(self)
camera(-16,-32)
local lines,height=gpl(dlg,19)
draw_box(-6,-2,102,height+16,8,12,193,192,208,p)
prlns(lines,2,2,7)
if ok == nil and cancel == nil then
print("\142 ok",2,height+4,7)              
else
print("\142 ok, \151 cancel",2,height+4,7) 
end
end,
update=function(self)
if btnp(4) then
cur_scn=scene
if(ok ~= nil) ok()
elseif btnp(5) then
cur_scn=scene
if(cancel ~= nil) cancel()
end
end
}
end
actors={
new=function(self) 
local a={
x=64,
y=64,
vx=0,
vy=0,
z=0,
angle=0,
sx=8,
sy=0,             
update=function(self)
if(self.control) self:control()
self.x += self.vx*0.016666
self.y += self.vy*0.016666
end,
draw=function(self)
rspr(self.sx,self.sy,32,16,self.angle,2)
local x,y,z,w=project(self.x,self.y,self.z)
sspr(32,16,16,16,x-8*w,y-8*w,16*w,16*w)
if(self.z>1) then
pal()
line(x,y,self.x,self.y,1)
line(self.x-2,self.y-2,self.x+2,self.y+2,10)
line(self.x-2,self.y+2,self.x+2,self.y-2,10)
end
end,
destroy=function(_self)  
if(_self.ondestroy ~= nil) _self:ondestroy()
del(actors._actors,_self)
end
}
if(#self._actors<20) add(self._actors,a)
return a
end,
update=function(self)
for actor in all(self._actors) do
actor:update()
end
end,
draw=function(self)
sorton(self._actors,function(a,b) return b.z-a.z end)
for actor in all(self._actors) do
actor:draw()
end
end,
clear=function(self)
self._actors={}
end,
_actors={},
}
function sorton(a,f)
f=f or function(a,b) return a>b end
for i=1,#a do
local j=i
while j>1 and f(a[j-1], a[j])>0 do
a[j],a[j-1]=a[j-1],a[j]
j=j-1
end
end
end
function update_wrap(self)
if(self.control) self:control()
self.x += self.vx*0.016666
self.y += self.vy*0.016666  
self.x, self.y=wrap(self.x),wrap(self.y)
end
function wrap(x)  
return x % 128
end
function draw_wrap(self,scale)
scale=scale or 1
rspr(self.sx,self.sy,32,16,self.angle,2,scale) 
local x,y,z,w=project(self.x,self.y,self.z) 
w *= scale
sspr(32,16,16,16,x-8*w,y-8*w,16*w,16*w)   
if(self.x <= 16) sspr(32,16,16,16,x-8*w+128,y-8*w,16*w,16*w)   
if(self.y <= 16) sspr(32,16,16,16,x-8*w,y-8*w+128,16*w,16*w)   
if(self.x >= 102) sspr(32,16,16,16,x-8*w-128,y-8*w,16*w,16*w)   
if(self.y >= 102) sspr(32,16,16,16,x-8*w,y-8*w-128,16*w,16*w)   
end
local rspr_clear_col=0
function rspr(sx,sy,x,y,a,w,s)
s=s or 1
local ca,sa=cos(a),sin(a)
local srcx,srcy,addr,pixel_pair
local ddx0,ddy0=ca,sa
local mask=shl(0xfff8,(w-1))
w*=4
ca*=w-0.5
sa*=w-0.5
local dx0,dy0=sa-ca+w,-ca-sa+w
w=s*2*w-1
for ix=0,w do
srcx,srcy=dx0,dy0
for iy=0,w do
if band(bor(srcx,srcy),mask)==0 then
local c=sget(sx+srcx,sy+srcy)
sset(x+ix,y+iy,c)
else
sset(x+ix,y+iy,rspr_clear_col)
end
srcx-=ddy0
srcy+=ddx0
end
dx0+=ddx0
dy0+=ddy0
end
end
local cam_focal=8
function project(x,y,z)
local w=cam_focal/(cam_focal+z)
return (x-64)*w+64,(y-64)*w+64,z,w
end
function rotate_point(x,y,a) 
local sa=sin(a)
local ca=cos(a)    
return (ca*x)-(sa*y), (sa*x)+(ca*y)
end
function tstc(a,b)   
if (abs(a.x-b.x)+abs(a.y-b.y)>max(a.collision_radius,b.collision_radius)*2) return false
local r2=(a.collision_radius+b.collision_radius)*(a.collision_radius+b.collision_radius)
local x2=(a.x-b.x)*(a.x+- b.x)
local y2=(a.y-b.y)*(a.y+- b.y)
return (x2+y2 <= r2)
end
partsys={ 
systems={},
particlecount=function(self)
local c=0
for s in all(self.systems) do
c += #s.particles
end
return c
end,
kill=function(self,system)
del(self.systems,system)
if(system.ondeath) system:ondeath()
end,
update=function(self)
layer=layer or 0
for system in all(self.systems) do
system:_update()
if system:_isdead() then
self:kill(system)
end
end
end,
draw=function(self,layer)
for system in all(self.systems) do
if system.layer == layer then
system:_draw()
end
end
end,
new=function(self,cx,cy,lifetime,layer) 
local system={
layer=layer or 0,
neverdie=false, 
cx=cx, 
cy=cy,
lifetime=lifetime, 
colours={8}, 
particles={},
_isdead=function(self) 
if(self.neverdie) return false
for p in all(self.particles) do
if(p.t>0) return false
end
return true
end,
get_colour=function(self,p)
return self.colours[flr(#self.colours*(1-p.t))+1]
end,
add=function(self,x,y,a,v)
local p={
x=x+self.cx,
y=y+self.cy,
a=a,
v=v,
t=1,
s=1
}
add(self.particles,p)
if(self.onadd) self:onadd(p)
return p
end,
_update=function(self) 
if(self.onupdate) self:onupdate()
for p in all(self.particles) do 
if(self.updateparticle) self:updateparticle(p)
if self.time then 
p.t=self:time(p)
else 
p.t -= 0.01666/self.lifetime
end
if p.t<0 then                        
del(self.particles,p)
if(p.ondeath) p:ondeath()
else
if self.vx then
p.x += self:vx(p)
else
p.x += sin(p.a)*p.v
end
if self.vy then
p.y += self:vy(p)
else
p.y += cos(p.a)*p.v
end
if self.size then
p.s=self:size(p)
end
if self.angle then
p.a=self:angle(p)
end
end                    
end
end,
_draw=function(self) 
for p in all(self.particles) do
if p.t >= 0 then
if self.drawparticle then
self:drawparticle(p)
elseif p.s == 1 then
pset(p.x,p.y,self:get_colour(p))
else 
circfill(p.x,p.y,p.s,self:get_colour(p))
end 
end
end
end
}
add(self.systems,system)
return system
end 
}
function cexp(x,y,colour,sprite,duration) 
colour=colour or 9
sprite=sprite or 11
duration=duration or 20
step=flr(duration/5)
colours={12,13,5,6,7}
local t=0
local explosion=actors:new()
explosion.x=x
explosion.y=y
explosion.draw=function(self)
pal()
palt()
for i=1,#colours do
if t<step*i and t>step*(i-2) then pal(colours[i],colour)
else palt(colours[i],true) end
end 
spr(sprite,self.x,self.y) 
pal()
palt()
end
explosion.update=function(self)
t += 1
if t>duration then
sfx(3)
self:destroy()
end
end
return explosion
end
function shuffle(tbl)
for i=#tbl, 2, -1 do
local j=ceil(rnd(i))
tbl[i], tbl[j]=tbl[j], tbl[i]
end
return tbl
end
__gfx__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000766700e0000000044444400000000b00000000
000000000000055555500000000000000000000000000000000000000000000000000000000000000000000006655660ee00000000444400000000bb00000000
0070070005005d6666d5005000500550055005000000500000050000000000d00d0000000000005555000000765dd567eee000000004400000000bbb00000000
00077000050061156116005000925765567529000052565005652500000000d55d000000000005666650000065dccd56eee000000004400000000bbb00000000
0007700005dddd6666dddd500095d776677d590000656d6116d6560000055199a9155000000006111160000065dccd56000000000000000000000000ccc00000
0070070005766155551667500096d776677d790000171d7667d171000059a191691a9500000001d667100000765dd567000000000000000000000000ccc00000
0000000005dddd5565dddd5000d67d7667d67d00005a1ad66da1a50000d1d419a14d1d00005d05d66650d50006655660000000000000000000000000cc000000
00000000005dd555555dd50000d67d7667d66d00005051daad15050000d9a199a91a9d000056055d6550d50000766700000000000000000000000000c0000000
00000000005661111116650000d66d7667d67d0000500ad66da005000051d491694d150000566e7d76e675000700076000000000000000000000000000000630
000000000005d566665d500000d669d55d966d00006000d67d000600000d5419a145d00000567ed67de775000065005000000000000000000555555000006bb3
000000000005d6cccc6d500000d669d00d959d00000000d67d000000000005916950000000550e567de0550000050d00000000000000000005999950000063a3
000000000000566cc66500000005695000505000000000d66d00000000000d1161d00000000000511500000000ddc05500000000000000000588885000006a33
0000000000000556655000000005950000000000000000577500000000000599a95000000000005115000000550cdd00000008880009900005888850000063a3
000000000000000550000000000050000000000000000005500000000000005115000000000000055000000000d0050000000888000990000588885000006bb3
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000006500050000000088009999000555555000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000006700000008099999900000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600006500
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600500006500
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555555500000000500500001000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000597777e500000000502115511160
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005646626500000000502102201000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005664266500000065555100251560
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005662466500000000022111550000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005626646500000000022100250000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005e77779500000065555100250000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555555500000000002500655560
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005566666666550000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000556666666666665500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000055550000000000000000005666666666666666650000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000555555000000000000000056666666666666666665000000
00000000000000000000000000000000000000000000000000000000000000000000000000000005655555000000000000000556dd7666666666dd7666500000
00000000000000000000000000000000000000000000000000000000000000000000000000000056665555000000000000005555666757666666666666650000
0000000000000000000000000000000000000000000000000000000000000000000000000000056aa666500000000000000555555665d576dd76666666665000
000000000000000000000000000000000000000000000000000000000000000000000000000056aa666500000000000000555555555ddd55566666666dd76500
000000000000000000000000000000000000000000000000000000000000000000000000000566aa6650000000000000005d555556666ddd5666666666666500
00000000000000000000000000000000000000000000000000000000000000000000000000566aa6650000000000000005555555557616d5766666dd76666650
00000000000000000000000000000000000000000000000000000000000000000000000000566a665000000000000000055551dd5557665676dd766666666d50
0000000000000000000000000000000000000000000000000000000000000000000000000005666500000000000000005555555555775665666666666666ddd5
000000000000000000000000000000000000000000000000000000000000000000000000000055500000000000000000555555555755555656666666666dd775
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555555555555666666666dd7665
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555555555555566666ddd776665
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051111555555555555551dddd77666665
0000000000000000000000000000000000000000000000000000000000000000000000000000335000053500000000005dddd11111555555111dd77766666675
00000000000000000000000000000000000000000000000000000000000000000000000000053be5053b3b5000000000555ddddddd111111dddd756666666d65
0000000000000000000000000000000000000000000000000000000000000000000000000053be2e5e23b330000000005555555dddddddddd555555666666665
000000000000000000000000000000000000000000000000000000000000000000000000053be2e252e23b3000000000055555555555555555555555dd666650
00000000000000000000000000000000000000000000000000000000000000000000000005be2e002e552350000000000555555555555555555551dd55666650
0000000000000000000000000000000000000000000000000000000000000000000000000052e20002e25500000000000051d5555555555555dd555555566500
000000000000000000000000000000000000000000000000000000000000000000000000000553002e2e1300000000000055551ddd51dd51dd55555555566500
0000000000000000000000000000000000000000000000000000000000000000000000000052d232e2d3d3000000000000055555555555555555555555555000
000000000000000000000000000000000000000000000000000000000000000000000000051d2d2e2d0db3000000000000005555555555555555555555550000
00000000000000000000000000000000000000000000000000000000000000000000000005d1d2e2d00b35000000000000000555555555555555555555500000
00000000000000000000000000000000000000000000000000000000000000000000000000551e2e1003b50000000000000000551dd555555555551dd5000000
000000000000000000000000000000000000000000000000000000000000000000000000000051e1db3b5000000000000000000555551ddd551dd55550000000
0000000000000000000000000000000000000000000000000000000000000000000000000000051db35500000000000000000000555555555555555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000033350000000000000000000000005555555555550000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555000000000000
000700000555500000000000dddddddd000000000000000000000000000000000000000000000000000000000000000000055100551000000000000000000000
00070000005d000000000000d777775d000000000000000000000000000000000000000000000000000000000000000000055100551000000000000000000000
00070000005d000000000000d77ddd5d000088882888828888888208888882888200088820888828888882008882880000055155510000000000000666660000
005d0000005d000000000000d7dddd5d000008820088200888888208888882882000008828820820888888200882880000055155100000000000056ddddd6000
005d0000005d000000000000d7dddd5d000088820882008820082082882828828888288288200828820882008828820000055551000000000000116dd5ddd500
005d00000007000000000000d7ddd55d00008888088200888202000088220882088208828200882882088200888820000005551000000000000516dd516dd500
005d00000007000000000000d755555d0008828888200888820000088200882088208828820082888882000888882000005551000000000000066dddd6dd5000
005555000007000000000000dddddddd000882088820088200820008820088828828882820088288888820088288200005555100000000000006ddddd5ddd500
005557777777777777755570dddddddd0088200882008888888200882000888828882008208828820882008828820000551551000000000000006dd5515dd500
055dddddddddddddddddd777494444940888828888288888882088888820082000820008888288820888288828820005551551000000000000006d51116dd500
555dddddddddddddddddd777d9dddd9d0000000000000000000000000000000000000000000000000000000000000055100551000000000000006dd616ddd500
555dddddddddddddddddd777494444940000000000000000000000000000000000000000000000000000000000000055100551000000000000006ddd6dd55000
55566666666666666a666777d9dddd9d0f50f50000000000000f5f500000000000ff50000000000f5f50000000000000000000000000000000006ddd55500000
555dddddddddddddddddd777449449440ff0f5ff5f5f50ff500f5f5ff5ff50f500f5f5000ff5f50f5f5ff5f50000fff5ff5ff500000000000000555500000000
555dddddddddddddddddd777ddd99ddd0f5ff5ff5f5f500f500f5f5f50ff50f500fff5f50f50ff50f50f50f50f50f5f5ff5ff500000000000000000000000000
555666a66666666666666777dddddddd0f50f5f50fff50f5f50f5f50f5f50ff500f500ff5f50f50f5f5f50ff5ff5f5f50f5f5000000000000000000000000000
555dddddddddddddddddd777dd11dd110f50f5ff5fff50ff500fff5ff5ff5ff5f5f500ff5f50ff5f5f5ff5ff5ff5f5f50f5ff500000000000000000000000000
55566a6666666666666a6777dd55dd550000000000000000000000000000000ff5000000000000000000000000000000ff500000000000000000000000000000
555dddddddddddddddddd77767516751000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555dddddddddddddddddd77767556755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666660000
5556666666666666a666677767dd67dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000006dddddd000
555dddddddddddddddddd7777676767600000000000000000000000000000000000000000000000000000000000000000000000000000000000006dddddd5000
555dddddddddddddddddd7777676767600000000000000000000000000000000000000000000000000000000000000000000000000000000000006dd55dd5000
555dddddddddddddddddd777767676760000000000000000000000000000000000000000000000000000000000000000000000000000000000006dd511650000
555dddddddddddddddddd77700000077666dcddc00000000555ddddddddddddd00000000555555550000005577000000000000000000000000006dd511650000
55566a6666666666666a677700077766dcddcd5500000000555666664444444400000000000000000000005577000000000000000000000000006d5d66d50000
555dddddddddddddddddd777777666dcdcd5550000000000555ddddddddddddd00000000000000000000000570000000000000000000000000000516dd500000
555dddddddddddddddddd777666dcddc5550000000000000555ddddd4444444400000000000000000000005577000000000000000000000000000d6dd5000000
5556666666666666a6666777dcddcd55000000000000000075566666dddddddd000000000000000000000055770000000000000000000000000000dd50000000
555dddddddddddddddddd777dcd555000000000000000077d75ddddd444444440000000000000000000000557700000000000000000000000000005500000000
055dddddddddddddddddd750555000000000000000077766d75ddddddddddddd0000000000000000000000057000000000000000000000000000000000000000
0055555555555555555555000000000000000000777666dcd75ddddddddddddd7777777700000000000000557700000000000000000000000000000000000000
111111110000011100000000000000000000000000000000dd700000000000000000000000000000000000000000000000000000000000000000000000000000
777777770001177700077777700000777700000000500555dd700500000000000000000000000000000000000000000000000000000067777776000000000000
66666666001776660077777777000777777000000055511155d555000000000900000000000003555530000000000000000000000006dcddcdcd600000000000
cccccccc01776ccc0777000077707770077700000005166666615000000009055090000000003e2e2e2300000000000000000000006dd111111dd60000000000
cccccccc0176cccc077000000770770000770000000568676686500000000051150000000005e2e2e2ee5000000090900909000006dd70000007dd6000000000
cccccccc176ccccc07700000077077000077000000056657656650000009051666509000000555f67f555000000005555550000006c1160000611c6000000000
cccccccc176ccccc0777000077700000077700000000565765650000000051dd8d6500000052ef5775f2e500000952ef6e25900006d1016006101d6000000000
cccccccc176ccccc007777777770000077700000000005567550000000051689918d5900032eee5665ee2e3000005e2f62e5000006c1001661001d6000000000
176ccccc000000000007777777000007770000000000005765000000009516d9986d500003e2eff67ffee230000932e6fe23900006d1006116001c6000000000
176ccccc0000000000000007700000777000000000000056750000000000561811d50000032eeef55fee2e3000003e26f2e3000006d1061001601d6000000000
176ccccc000000000000000770000777000000000000505765050000000905666d50900005e2ef5005fee250000903333330900006c1610000161c6000000000
176ccccc000000000000007700007770000000000000555cc55500000000005dd5000000052e2300003e2e50000003000030000001dd60000001dd1000000000
176ccccc000000000000007700007770000000000000582828250000000009055090000000522300003225000000090000900000001dd666666dd10000000000
176ccccc0000000000000770000077777777000000000555555000000000000090000000000553000035500000000000000000000001dcdcddcd100000000000
176ccccc000000000000077000007777777700000000000000000000000000000000000000000000000000000000000000000000000011111111000000000000
176ccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000077770000000077700007770000000000000000007777077770000000000000000000000000000000000005000000000000000000500000000000000000
00007777777700000777770077777000000000000000007777770777000000000000000000000000000000000055005005555000000000510000000000000000
00077777777770000770770777007700000000000000007707700077000000000000000000000000000000000000005005150000000000177776665000000000
07777777777777700770000770007700000000000000000007770007000000000000000000000000000000000000555555550000000077766655550000000000
07777700007777700777700770007700000000000000000007770077000000000000000007000000000000000000515665150000006666665500000000000000
00077000000770000077770770777000000000000007770007777770000000000000000007000000000000000005155665515000055555551000000000000000
0007007007007000000777077777077000007777007777700077077000000000000000007770000000000000000551d66d155000000000011006000000000000
00000770077000000000770777707777000777700770077700770070000000000070007777777000000000000005151661510000000000061066000000000000
000007700770000000007707700777077077700077000077077700770007770007700000777000770000000000055dd66dd00500000060066556000000000000
00000770077000000000770770777007707700007777777007700077007707707700070077000777700000000005151761000550000066666601000000000000
0000777007770000000077077077000770070000777777007770007707700070700007077700770070000000000051d66d100000000065016000000000000000
00007700007700000007770770770007700770000700000077700077070007707007700770007777700000000000005555515000000010006000000000000000
00007700007700000777700770770007770777770770007077700077077077077707707777700700000000000005500000550000000000005000000000000000
00007700007700000777007770077777770077700077777077700077007770007777007777770777700000000005000000000000000000001000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
800000000000800000000000008000000000000000000000000000000000b8b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
909191919191920080000000b5b69192000000000000b8b8b80000cd919191919191ce0000000000000000000000000000b8b80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a283a183a0a200909192b3b4a0a1a200909192b890a1a1a19200a0a1a18383a1a1a2009092b8b8b8b8b8909200008090a3a3928000004c4d4e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0b2a0a1a2b0b200a083a200b5b6a1a2bab793b783a1a1a1a1a1bba0a183dedd83a1a200b0b2b0a1a1a1b2b0b2008090a3a3a3a39280005c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
81baa083a2bb8100a0a1a2b3b4a083a200b0b1b2b9b0b1b1b1b200a0a183cecd83a1a200909290a1a1a1929092009083b7b8b7b78392006c6d6e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000b0a1b2000000a0a1a20000b0b1b2000000000000b0b1b20000a0a1a18383a1a1a200b0b2b9b981b9b9b0b200b0a3a3a3a3a3a3b2007c7d7e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bab1bb000000b0b1b200000081000000000000000081000000ddb1b1b1b1b1b1de00008100000000000000000081b0b1b1b281000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000810000000000810000000000000000000000000000000000000000b9b9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100000361003610036100361003610036100361003610036000360003600036000360003600036000360003600036000360003600036000360003600036000360003600036000360003600036000360003600
000100001a6151a6151a6151a6151a6151a6151a6151a6151a6151a6151a6151f6063660635606356053e6003e6003e6003e6003f5003f5003f5003f5003f5003f5003f5003f5003f5003f5003f5003f5003f500
000100001924718247172471623716237152371423714227132271223712227112271122710227102270f2270f2270e2270d2270d2270c2270b2270a227092270921708217072170621705217042170321702217
000100000755006550055500455003550025500155000550005500155000550065000650006500065000650006500065000650006500055000550005500055000550004500045000450004500045000450004500
00010000005003a5503855033550315502f5502c5502a5502655023550215501d5501a5501655012550145501b5502355028550215501c55018550145501055009550075500a5500f5500a550045500255000500
00010002187500c7501070011700137001570017700187001a7001c7001d7001f7002170023700247002670028700297002b7002d7002f7003070032700347003570037700397003b7003c700307002470018700
0006000004313053130631307313093130c3130f323103231332315323193231c3231f3332233324343273432a3532e3532f3532f3532f3532f3532f3532f3532f3432f3432f3332f3232f3132f3132f3232f323
000300003635335353343533335332353313532f3532d3532c3532b3532935327353253532435322353203531f3531d3531b3531a35317353163531435312353103530f3530c3530b35308353063530435303353
00040000241511a151001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101
000c00003c65300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603000030000300000
011000001815218152181521c1551c1551c1551d1521d1521d1522115521155211552115221152211522315223152231522415224152241522415224152241522415224152241522415224152241522415224152
000300003c155341052a105231053c155141050e105051053c15528105231051f1053c155121050c105061053c15519105141050f1053c1550310501105001053c1550910515105131053c155111050210500105
000100000c7501275016750197501c7501f7502275023750257502775027750297502a7502a7502a7502b7502b7502b7502b7502a7502a7502975028750277502575023750227501f7501e7501b7501875013750
00010000297502675023750207501c7501975015750107500d7500a75009750077500775007750097500b7500e7501075013750147501475012750117500f7500e7500d7500b7500875006750047500275000750
010700003f6533b653346032d603266031d60316603156031b6032060329603336033a6033e6033f603366032d603266031c6030f603066030060302603076030c6030e60311603166031d60324603326033d603
000200001d5501d5501d5501d5501d5501d5501d5501d5501d5502655026550265502655026550265502655026550265500050000500005000050000500005000050000500005000050000500005000050000500
012000201c735187351c735187351c735187351c735187351d7351a7351d7351a7351d7351a7351d7351a7351c735187351c735187351c735187351c735187351a735177351a735177351a735177351a73517735
012000000c7530c7030c75318753007030c753187530c7030c7530c7030c7530c7030c7530c7030c7530c7030c7530c7030c753187530c7030c75318753187030c7530c7030c7530c703107530c7031075300000
011000202113521135211352113521135211352113521135231352313523135231352413524135241352413521135211352113521135211352113521135211351f1351f1351d1351d1351a1351a1351c1351c135
01180000134021340213402134020c4020c4020c4020c4020c4020c40211402114021040210402104020e402134321343213432134320c4320c4320c4320c4320c4320c43211432114321043210432104320e432
011000180c555005050c5050c5550c5550c5550c555005050c5050c5550c5550c5550c55500505005050c5550c5550c5550c5550c5550c5550c5550c5550c5550c55500505005050c5550c5550c5550c55500505
01180000104321043210432104320c4320c4320c4320c4320c4320c43211432114321043210432104320e432104321043213432134320c4320c4320c4320c4320c4320c43211432114321043210432104320e432
011800001043210432104320e4320c4320c4320c4320c4320c4320c4320e4320e4320c4320c4320b4320b4320c4320c4320c4320c4320c4320c4320c4320c4320040200402004020040200402004020040200402
011800001023510232102320e2320e2320e2350c2300c230132321323210232102320e2320e2320c2320c2351023510232102320e2320e2320e2350c2350c2321023210232102321023210232102350020200200
011800001023510232102320e2320e2320e2350c2300c230132321323210232102320e2320e2320c2320c2351023510232102320e2320e2320e2350c2350c2320c2300c2300c2300c2300c2030c2030c20300203
011000000575504755027550075502755047550575507755057550475502755007550275504755057550775505755047550275500755027550475505755077550575504755027550075502755047550575504755
011000001713217152171521d1521d1321c15200002000021c1321c1321c1221c1221c1221c1121c1121c1121a1521a1521c1520000200002131521315213152171521a152171521815218152181521815218152
011000000c4300c4000c4000c400104300c4000c4000c4000c4300c4000c4000c400134300c4000c4000c4000c4300c4000c4000c400104300c4000c4000c4000c4300c4000c4000c400074300c4000c4000c400
01100020182551825518255002000b2000b2000b2000b200182551825518255002000020000200002000020016255162551625500200002000020000200002001725517255172550020000200002000020000200
01100020182551825518255000050000500005000050000518255182551825500005000050000500005000051b2551b2551b25500005000050000500005000051c2551c2551c2550000500005000050000500005
012000000c0530c05310053000030e0530e05311053000030c0530c05310053000030e0530e05315053000030c0530c05310053000030e0530e05311053000030c0530c05310053150531305311053100530e053
01100020182551c2051325500205102550020513255002051825500205132550020510255002051225500205182551c2051325500205102550020513255002051f2551c255182551f2051f2551c2551825500205
011000002432024330243402435024300243002430024300243202433024340243502430024300243002430024320243302434024350243002430024300243002431024320243302434024350243502430024300
011000001855018550185501855018540185301852018510185501855018550185501854018530185201851018550185501855018550185401853018520185101855018550185501855018540185301852018510
012000000c5400c5300c5200c5101854018530185201851013540135401554010540115401154010540105400c5400c5300c5200c510185401853018520185101c5501c5501a5501855018540185301852018510
012000001c5401c5201a54018540185301853018520185101c5401c5201a54018540185401853018520185101f5401f5201a5401a5201854018520175401752018540185201a5401c5401c5401c5301c5201c510
011000200c0530c0030c0530c0030c0030c0030c0030c003100530c003100530c0030c0030c0030c0030c0030c0530c0030c0530c0030c0030c0030c0030c003130530c003130530c0030c0030c0030000300003
010800003c6500c650306500c650246500c650186500c6503c6500c650306500c650246500c650186500c650171001510013100111001835017350153501335011350103500e3500c3500c3500c3500c3500c350
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300001c5521c5521c5521c5521c5521c5521c5521c5521c5421c5421c5421c5421c5421c5421c5421c5421c5321c5321c5321c5321c5321c5321c5321c5321c5221c5221c5221c5221c5121c5121c5121c512
010100001f7521f7521f7521f7521f7521f7521f7521f7521f7521f7521f7521f7521f7521f7521f7521f75221752217522175221752217522175221752217522175221752217522175221752217522175221752
011000000c1520e15211152111521115211152151521515218152181521815218152181520010200102001020c1520e1521115211152111521115218152181521515215152151521515213152131521315200102
011000000c1520e152111521115211152111521515215152181521815218152181520c1020c1020c1020c10211152111521a1521a1521a1521a1521c1521c1521c1521c1521d1521d1521d1521d1521d1521d152
011000000c1520e15211152111521115211152151521515218152181521815218152181520010200102001020c1520c1521815218152181521815215152151521515215152131521315211152111521115200102
011000003070030700307303072030710307153070030700357003570035730357203571035715357003570039700397003973039720397103971539700397003570035700357303572035710357153570035700
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
03 10 11 43 44
03 10 11 43 44
01 13 14 43 44
00 15 14 43 44
00 16 14 43 44
00 17 14 43 44
02 18 14 43 44
02 1a 42 43 44
03 1b 42 43 44
01 20 42 43 44
01 1e 1c 43 44
00 1e 1d 43 44
02 1e 1f 43 44
00 21 42 43 44
01 22 24 43 44
02 23 24 43 44
05 25 42 43 44
01 2a 2d 43 44
00 2c 2d 43 44
00 2a 2d 43 44
00 2b 2d 43 44
02 41 2d 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
