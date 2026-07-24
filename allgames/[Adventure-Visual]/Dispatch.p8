pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--DISPATCH
function _init()
initmap()
font()
_upd=intro_upd
_drw=intro_drw
end
function _update()
for c in all(actions) do
if (not coresume(c)) del(actions,c)
end
keys:update()
_upd()
if cor and costatus(cor) != 'dead' then
coresume(cor, b)
else
cor=nil
end
if msg and costatus(msg) != 'dead' then
coresume(msg, b)
else
msg=nil
end
end
function _draw()
_drw()
end

--gen
function initmap()
chars='!"#%\'()*+,-./0123456789:;<=>?abcdefghijklmnopqrstuvwxyz[]^_{~}'
moves={}
over=nil
gt=0
searching,st,sp=nil,0,150
ms=50
bleeding=nil
bs=2000
bleedtime=bs
destruct=nil
ds=3000
dt=ds
holding=nil
status=nil
identified=nil
enemyspeed=150
enemymove=0
enemytimer=enemyspeed
bf=0
busy=false
activity=nil
power=nil
rank=nil
offset,offsetmax=0,5
aoffset,aoffsetmax=0,16
attacked=nil
starstone=nil
tracking=nil
fires=0
burning=0
hacked=nil
fdone=nil
comp=0
wait=nil
message=nil
stars={}
colors={2,8,8}
local totstars=25
for i=1,totstars do
local tc=flr(rnd(3)+1)
add(stars,{
x=rnd(128),
y=rnd(128),
sp=tc
})
glit={}
glit.height=128
glit.width=128
glit.t=0
end
mapname()
map,back,w,id,cols={},{},32,1
size=flr(128/w);
makerooms(size*size)
for y=1,size do
for x=1,size do
addroom(x,y,id)
id+= 1
end
end
flightlog()
newroom,here,enemy=map[1],map[1],map[16]
end
function mapname()
ships={
'aeolus',
'andrea gail',
'ark',
'black swan',
'citadel',
'charnel',
'covenant',
'crucible',
'eden',
'erebus',
'faith',
'harmony',
'hel',
'icarus',
'kobayashi maru',
'lansing',
'leviathan',
'naglfar',
'narcissus',
'nightingale',
'raven',
'red witch',
'solis',
'yangtze kiang'}
for i=1,#ships do
ship=ships[flr(rnd(i))+1]
end
a="abcefghijklmnoprstuvxyz"
bb=ceil(rnd(#a))
c=rnd(1+#a)
registry=(bb*5)..sub(a,bb+1,bb+2)..'-'..(bb*1)
end
function makerooms(count)
rooms={'airlock'}
local group={
'cryo',
'engineering',
'life support',
'medical',
'reactor'}
opsnames={'bridge','command','operations','ops'}
ops=opsnames[flr(rnd(4))+1]
add(group,ops)
if ship=='solis' then
cpu='ada' else
cpunames={'angel','cray','sam','mother','!"#$'}
cpu=cpunames[flr(rnd(#cpunames))+1]
end
add(group,cpu)
lab=flr(rnd(2))
if (lab==1) add(group,'lab')
qrtrs=flr(rnd(2))
if (qrtrs==1) add(group,'quarters')
local h=flr(rnd(3))+1
for h=1,h do
add(group,'habitat 0'..h)
end
local x,t=1,#rooms+#group-1
while x < count-t do
local s=numtochar(x+30)
add(group,'storage '..s)
x+=1
end
shuffle(group)
for i=1,#group do
local c=group[i]
add (rooms,c)
end
return rooms
end
function addroom(rx,ry,id)
local room={
name=rooms[id],
x=rx,
y=ry,
walls={true,true,true,true}}
add(map,room)
local body=flr(rnd(2))
if (body==1) room.body=true
local name=room.name
if (name=='medical') room.item='trauma kit'
if (name=='engineering') room.item='isotopes'
if (name=='life support') room.item='sensor'
spawn=flr(rnd(4))
if (name=='lab' and spawn==1) room.item='relic'
if (name=='quarters' and spawn==1) room.item='pumpkin'
if (name=='storage a' and spawn==1) room.item='manifest'
if sub(name,1,7)=='habitat'
or sub(name,1,7)=='storage'
then
repeat
local fset=flr(rnd(2))
if fset==1 and not fdone then
room.item='fire suppr'
fdone=true
end
until fset==1
end
for o=1,#ops do
if (name==ops) room.item='cmd codes'
end
local fire=flr(rnd(10))
if fire==1
and room.name != 'airlock'
and room.item != 'fire suppr' then
room.fire=true
fires+=1
end
end
function buildmap()
next,newroom.chk=findnext(newroom),true
if next then
next.chk=true
add(back,newroom)
dig(newroom,next)
newroom=next;
else
if #back > 0 then
newroom=back[#back]
del(back,newroom)
end
end
end
function findnext(room)
local x,y,cand=room.x,room.y,{}
local up=map[index(x,y-1)]
local rt=map[index(x+1,y)]
local dn=map[index(x,y+1)]
local lt=map[index(x-1,y)]
if up and not up.chk then add(cand,up) end
if rt and not rt.chk then add(cand,rt) end
if dn and not dn.chk then add(cand,dn) end
if lt and not lt.chk then add(cand,lt) end
if (#cand) then d=flr(rnd(#cand)+1) return cand[d]; end
end
function dig(a,b)
local x=a.x - b.x
if x==1 then
a.walls[4]=false;
b.walls[2]=false;
else if (x==-1) then
a.walls[2]=false;
b.walls[4]=false;
end
end
local y=a.y - b.y;
if y==1 then
a.walls[1]=false;
b.walls[3]=false;
else if (y==-1) then
a.walls[3]=false;
b.walls[1]=false;
end
end
end

--intro
function intro_upd()
if btnp(4) then
cor=cocreate(function()
hit=true delay(10)
_upd=goal_upd
_drw=goal_drw
hit,reset=false,true
gt=0
end)
end
for st in all(stars) do
st.y-=st.sp/2
if (st.y<=0) then
st.y=128
st.sp=flr(rnd(3)+1)
end
end
end
function intro_drw()
intro=true
gt+=1
if (gt >= 500) then gt=500 end
bg=0 fg=8
cls(bg)
draw_scroll_text({'    d i s p a ^ c h'},55,2,10,fg)
if gt >= 10 then smol('--',98,66,8) end
if gt >= 15 then line(20,68,26,68,8) end
if gt >= 100 and gt <= 105 then
rectfill(20,59,104,62,8)
wide('d i s p a ^ c h',20,60,0)
end
if (gt >= 200) then spr(80,56,114) spr(81,64,114) end
if gt >= 250 then
print('\142',4+45,117-15,blinkcol)
smol('begin',14+45,117-15,blinkcol)
end
glitch()
clip(0, 28, 128, 72)
if gt >= 1 then
for st in all(stars) do
pset(st.x, st.y, colors[st.sp])
pset(st.x, st.y+2, colors[st.sp])
end
end
clip()
blink()
drawhit(fg)
end
function goal_upd()
gt+=1
if gt >= 200 then
gt=0
intro=nil
_upd=start_upd
_drw=start_drw
end
end
function goal_drw()
cls(0)
text={
'[directive]',
'',
'recover flight',
'log and re^urn.',
'',
'other priorities.',
'rescinded / void.',
'',
'expendable._'
}
draw_scroll_text(text,34,2,15,fg)
glitch()
drawhit(fg)
end
function start_upd()
gt+=1
if (gt >= 500) then gt=500 end
if btnp(2) and not wait then
wait=true
cor=cocreate(function()
boarding=true delay(ms)
gt=0
boarding=nil
_upd=main_upd
_drw=main_drw
end)
wait=nil
end
if btnp(3) and not wait then
wait=true
cor=cocreate(function()
moving=true delay(ms)
gt=0
_upd=end_upd
_drw=end_drw
moving,boarding=nil,nil
over='vacated'
end)
end
end
function start_drw()
cls(bg)
place={'\''..ship..'\'',registry..':'}
epilogue={
'umbilicus locked in place',
'to board the \''..ship..'\'.',
'','',
'the ship was found adrift',
'after triangulating its',
'distress beacon.',
'','',
'no communication.',
'no sign of the crew.',
'','',
'outer hatch unlocked.',
'ready to board.',
'','','',
'no turning back now...',
}
bg,fg=0,5
draw_scroll_text(place,0,2,10,fg)
draw_scroll_text(epilogue,12,1,15,fg)
print('\148',4,115,6)
smol('to move ahead',14,115,6)
if boarding or moving then
fillp(0B1010101010101010.1)
rectfill(0,0,126,98,bg)
rectfill(0,109,128,128,0)
fillp()
rectfill(0,109,128,112,0)
if boarding then
wide('boarding...',4,108,6)
else
wide('turning back...',4,108,6)
end
else
wide('umbilicus',4,108,6)
end
end

--main
function main_drw()



-- drawmap()
showroom(here)
showhud()
end
function main_upd()
buildmap()
traverse()
getdist(here)
if over then
gt=0
destruct=nil
_upd=end_upd
_drw=end_drw
end
end
function traverse()
doenemy()
bleed()
burn()
boom()
gt += 1
if gt >= 5 then
if (gt >= 500) then gt=500 end
moves=canmove(here,last)
fork=face(here,last)
local x,y,w=here.x,here.y,here.walls
if (#moves==0) then
if (btnp(2)) then --FWD
cor=cocreate(function()
moving='up'  delay(ms)
here.visited=true
if (fork=='NORTH' and not w[3]) then
last=here here=map[index(x,y+1)] end
if (fork=='EAST' and not w[4]) then
last=here here=map[index(x-1,y)] end
if (fork=='SOUTH' and not w[1]) then
last=here here=map[index(x,y-1)] end
if (fork=='WEST' and not w[2]) then
last=here here=map[index(x+1,y)] end
moving=nil gt=0
end)
end
end
if (#moves==1) then
if (btnp(2)) then
cor=cocreate(function()
moving='up' delay(ms)
here.visited=true
if (facing=='NORTH' and not w[1]) then
last=here
here=map[index(x,y-1)] end
if (facing=='EAST' and not w[2]) then
last=here
here=map[index(x+1,y)] end
if (facing=='SOUTH' and not w[3]) then
last=here
here=map[index(x,y+1)] end
if (facing=='WEST' and not w[4]) then
last=here
here=map[index(x-1,y)] end
moving=nil gt=0
end)
end
if btnp(3) and here.name != 'airlock' then
cor=cocreate(function()
moving='bk' delay(ms)
here.visited=true
if (fork=='NORTH' and not w[3]) then
last=here here=map[index(x,y+1)] end
if (fork=='EAST' and not w[4]) then
last=here here=map[index(x-1,y)] end
if (fork=='SOUTH' and not w[1]) then
last=here here=map[index(x,y-1)] end
if (fork=='WEST' and not w[2]) then
last=here here=map[index(x+1,y)] end
moving=nil gt=0
end)
end
end
if (#moves==2) then
if (btnp(0)) then
cor=cocreate(function()
here.visited=true
moving='lt' delay(ms)
if (fork=='NORTH' and not w[4]) then
last=here here=map[index(x-1,y)] end
if (fork=='EAST' and not w[1]) then
last=here here=map[index(x,y-1)] end
if (fork=='SOUTH' and not w[2]) then
last=here here=map[index(x+1,y)] end
if (fork=='WEST' and not w[3]) then
last=here here=map[index(x,y+1)] end
moving=nil gt=0
end)
end
if (btnp(1)) then
cor=cocreate(function()
here.visited=true
moving='rt' delay(ms)
if (fork=='NORTH' and not w[2]) then
last=here here=map[index(x+1,y)] end
if (fork=='EAST' and not w[3]) then
last=here here=map[index(x,y+1)] end
if (fork=='SOUTH' and not w[4]) then
last=here here=map[index(x-1,y)] end
if (fork=='WEST' and not w[1]) then
last=here here=map[index(x,y-1)] end
moving=nil gt=0
end)
end
if (btnp(2)) then
cor=cocreate(function()
here.visited=true
if (fork=='NORTH' and not w[1]) then
moving='up' delay(ms)
last=here here=map[index(x,y-1)]
moving=nil gt=0
end
if (fork=='EAST' and not w[2]) then
moving='up' delay(ms)
last=here here=map[index(x+1,y)]
moving=nil gt=0
end
if (fork=='SOUTH' and not w[3]) then
moving='up' delay(ms)
last=here here=map[index(x,y+1)]
moving=nil gt=0
end
if (fork=='WEST' and not w[4]) then
moving='up' delay(ms)
last=here here=map[index(x-1,y)]
moving=nil gt=0
end
end)
end
if (btnp(3)) then
cor=cocreate(function()
moving='bk' delay(ms)
here.visited=true
if (fork=='NORTH' and not w[3]) then
last=here here=map[index(x,y+1)] end
if (fork=='EAST' and not w[4]) then
last=here here=map[index(x-1,y)] end
if (fork=='SOUTH' and not w[1]) then
last=here here=map[index(x,y-1)] end
if (fork=='WEST' and not w[2]) then
last=here here=map[index(x+1,y)] end
moving=nil gt=0
end)
end
end
if keys:up(4) then
busy,wait,activity=nil,nil,nil
access,success,vdu=nil,nil,nil
searching,st,sp=nil,0,150
end
if keys:up(5) then
busy,wait=nil,nil
end
if btnp(4) and not busy then
if here.found then
take()
end
end
if btn(4) and access then
if not vdu then
gt=0
end
vdu=true
end
if keys:held(4) and not wait then
if not here.fire then
if not here.searched then
activity='searching...'
action('search')
else
if here.name=='airlock' then
if bleeding then
hit=nil
showmsg('unable: bleeding')
else
activity='unlocking...'
action('interface')
end
end
if here.name=='reactor' and
holding=='isotopes' then
activity='resetting...'
action('interface')
end
if here.name=='lab' and
holding=='relic' and power then
activity='analysis...'
action('interface')
end
if here.name=='engineering' and power then
activity='disabling...'
action('interface')
end
if here.name=='cryo' then
activity='interface...'
action('interface')
end
if here.name=='medical' then
activity='interface...'
action('interface')
end
if here.name==cpu and here.done != true then
if power then
access,sp=true,300
if holding=='cmd codes' then
activity='accessing...'
else
activity='hacking...'
end
else
activity='interface...'
end
action('interface')
end
end
else
if holding=='fire suppr' then
activity='suppress...'
action('suppress')
else
showmsg('unable: fire')
end
end
end
end
function action(act)
busy,searching=true,true
st += 1
if st==sp then
st=sp
searching,wait=nil,true
if act=='search' then
if here.item then
here.found=true
showmsg('found '..here.item)
else
showmsg('nothing found')
end
here.searched=true
end
if act=='suppress' then
gt=0
here.fire=nil
fires-=1
showmsg('fire suppressed')
end
if act=='interface' then
if here.name=='airlock' then
if holding=='blackbox' then
if destruct then
comp+=20
over='win'
else
comp+=10
over='escape'
end
else
over='vacated'
end
if holding=='pumpkin' then
over='pumpkin'
end
end
if here.name=='reactor'
and holding=='isotopes' then
holding,status,power,here.done=nil,nil,true,true
comp+=40
showmsg('main power online')
gt=0
end
if power then
if here.name=='lab'
and holding=='relic' then
holding,here.done='starstone',true
showmsg('identified')
end
if here.name=='engineering' then
destruct=true
end
if here.name=='cryo' then
over='cryo'
end
if here.name=='medical' then
bs=2000
bleeding=false
bleedtime=bs
attacked=nil
showmsg('injury repaired')
gt=0
end
if here.name==cpu then
if holding=='cmd codes' then
success=1
holding=nil
else
success=flr(rnd(3))
end
if success==1 then
if holding then
here.found=true
here.item=holding
holding=nil
end
holding='blackbox'
status=true
here.done=true
comp+=40
showmsg('found flight log')
else
comp-=5
showmsg('access denied')
end
end
else
showmsg('no effect')
end
end
end
end
function take()
if here.item then
if not holding then
holding=here.item
here.item=nil
status=true
wait=true
end
if (holding=='starstone') starstone=nil
if holding=='sensor' then
if not tracking then
tracking=true
showmsg('sensor active')
end
end
if holding=='trauma kit' and bleeding then
bs=2000
bleeding=false
bleedtime=bs
holding=nil
status=nil
attacked=nil
gt=0
showmsg('used trauma kit')
end
if holding=='manifest' then
for s=1,#map do
map[s].found=true
map[s].searched=true
end
holding,status=nil,nil
showmsg('read manifest')
end
busy=true
end
end
function drop()
if holding=='starstone' then
starstone=here
comp+=10
end
if not here.item then
here.found=true
here.item=holding
holding,status=nil,nil
else
swap=holding
holding=here.item
if (holding=='starstone') starstone=nil
here.item=swap
swap=nil
end
showmsg('left '..here.item)
end
if status==true then
offset+=2
if offset>=offsetmax then
offset=offsetmax
end
else
offset=0
end
if moving or boarding then
message,searching,st=nil,nil,0
aoffset=(aoffset / aoffsetmax) +20
if aoffset>=aoffsetmax then
aoffset=aoffsetmax
end
else
aoffset=0
end
if btn(5) and not busy then
if holding then
if (starstone) here=starstone
if not here.searched then
showmsg('cannot drop')
else
drop()
end
else
showmsg('nothing held')
end
if holding=='starstone' and here.fire then
holding,status,starstone=nil,nil,nil
showmsg('relic destroyed')
end
busy=true
end
function showmsg(setmsg)
if (moving) message=nil
msg=cocreate(function()
message=setmsg
delay(65)
message=nil
end)
end
end
function canmove(room,last)
local x,y,moves=room.x,room.y,{}
up=map[index(x,y-1)]
rt=map[index(x+1,y)]
dn=map[index(x,y+1)]
lt=map[index(x-1,y)]
if (up != last and not room.walls[1]) then
facing='NORTH' add(moves,up) end
if (rt != last and not room.walls[2]) then
facing='EAST' add(moves,rt) end
if (dn != last and not room.walls[3]) then
facing='SOUTH' add(moves,dn) end
if (lt != last and not room.walls[4]) then
facing='WEST'  add(moves,lt) end
return moves
end
function face(a,b)
if (b) then
local x=a.x - b.x
if (x==1) then
fork='EAST'
else if (x==-1) then
fork='WEST'
end
end
local y=a.y - b.y;
if (y==1) then
fork='SOUTH'
else if (y==-1) then
fork='NORTH'
end
end
end
return fork
end
function burn()
if destruct then
for i=1,#map do
if map[i].name=='reactor' then
map[i].fire=true
end
fires=1
end
end
if fires > 0 then
burning +=2
if fires==14 then
msg=cocreate(function()
hit=true delay(5)
hit=false
end)
over='boom'
end
if burning==1000 then
burning=0
local catch=flr(rnd(#map))+1
local fire=flr(rnd(2))
if fire==1 then
if map[catch].fire==nil then
if map[catch].item != 'fire suppr' then
if map[catch] != here then
map[catch].fire=true
fires+=1
if (map[catch].searched and not map[catch].done) comp-=5
if power or tracking then
showmsg('fire: '..map[catch].name)
end
end
end
end
end
end
end
end
function bleed()
if bleeding==true then
bleedtime-=1
if bleedtime==flr((bs/3)*2)
and attacked==here then
msg=cocreate(function()
hit=true delay(5)
hit=false
end)
gt=0
over='killed'
end
if bleedtime <= 0 then
bleedtime=0
over='bled'
end
end
end
function boom()
if destruct==true then
dt-=1
if dt <= 0 then
dt=0
msg=cocreate(function()
hit=true delay(5)
hit=false
end)
over='boom'
end
end
end
function doenemy()
if here==enemy then
if here.name != 'medical'
and here.name != 'quarters'
and not here.fire
and not bleeding
then
if holding=='blackbox' and
enemytimer==flr(enemyspeed/3) then
attacked=here
end
if searching and st >= 50 then
attacked=here
end
if attacked then
msg=cocreate(function()
hit=true delay(5)
hit=false
end)
gt=0
bleeding=true
if holding=='sensor' then
comp-=20
else
  comp-=10
end
end
if searching and attacked != here and bleeding then
if st >= 50 then
msg=cocreate(function()
hit=true delay(5)
hit=false
end)
over='killed'
end
end
end
end
enemytimer-=1
if enemytimer==enemyspeed then
if enemy==here and holding=='sensor' then
showmsg('(((proximity)))')
end
if enemy.item=='sensor'
and tracking then
showmsg('(((activity)))')
end
end
if enemytimer<=0 then
moveenemy()
end
end
function moveenemy()
local x,y,w=enemy.x,enemy.y,enemy.walls
local hunt=enemy.d
enemytimer=enemyspeed+flr(rnd(100))
?enemymove,1,1,8
enemymove=flr(rnd(4))

local up=map[index(x,y-1)]
local rt=map[index(x+1,y)]
local dn=map[index(x,y+1)]
local lt=map[index(x-1,y)]
if holding=='blackbox' then stalk=0 else stalk=1 end
if hunt > stalk and enemymove <= 1 then
if up and up.d < hunt and not w[1] then
enemymove+=1 enemy=up end
if rt and rt.d < hunt and not w[2] then
enemymove+=1 enemy=rt end
if dn and dn.d < hunt and not w[3] then
enemymove+=1 enemy=dn end
if lt and lt.d < hunt and not w[4] then
enemymove+=1 enemy=lt end
end
end
function getdist(room)
for r in all(map) do
r.d=-1
end
local cand,step,candnew={},0,{}
add(cand,room)
room.d=0
repeat
step+=1
candnew={}
for c in all(cand) do
local x,y=c.x,c.y
local up=map[index(x,y-1)]
local rt=map[index(x+1,y)]
local dn=map[index(x,y+1)]
local lt=map[index(x-1,y)]
local w=c.walls
if w[1] then up=nil end
if w[2] then rt=nil end
if w[3] then dn=nil end
if w[4] then lt=nil end
if up and up.d==-1 then up.d=step add(candnew,up) end
if rt and rt.d==-1 then rt.d=step add(candnew,rt) end
if dn and dn.d==-1 then dn.d=step add(candnew,dn) end
if lt and lt.d==-1 then lt.d=step add(candnew,lt) end
end
cand=candnew
until #cand==0
end

--lore
function showroom(here)
local name=here.name
local lore=roomlore(name)
place={'['..ship..']',here.name..':'}
if here.body then
add(lore,'there are human remains.')
add(lore,'blood everywhere.')
add(lore,'')
end
if (here.fire) then
lore={
'fire.',
'',
'dense, suffocating smoke,',
'and wild flames. difficult',
'to see, much less breathe.',
'',
'automated suppression failed.',
'',
'seems to be contained for now,',
'but will spread eventually.',
'',
'nothing can be done here',
'until this subsides.',
''} bg,fg=4,15
if holding=='pumpkin' then
add(lore,'oddly, the pvmpkin appears')
add(lore,'to have lit up. it must think')
add(lore,'this is fine.')
comp=50
end
end
if bleeding then
lore={
'something attacked you.',
'',
'a vicious slash wound was',
'inflicted to your upper body.',
'','',
'you only caught a glimpse of a',
'great bladed horror that lept',
'out from the shadows while',
'your guard was down.',
'',
'your only hope is to seek',
'medical attention. move.',
'',''} bg,fg=8,7
end
if here.found then
if here.item then
add(lore,here.item..' found here.')
end
end
if here.searched and not here.item and not bleeding then
add(lore,here.name..' searched.')
end
if access then
lore={
'org x9001         cells',
'      msg db : pw db',
'      cor db : incor db',
'.code',
'      mov ax, @data',
'      mov ds, ax',
'      mov bx, offset pw',
'      mov ah, 9',
'val:',
'      cmp al, [bx]',
'      inc bx, dec cx',
'      mov ah, 9',
'      mov dx, offset cor',
'      jmp l1',
''}
bg=0
if success then
if success==1 then
add(lore,'interlinked')
fg=3
else
add(lore,'deny')
fg=8
end
else
fg=3
end
end
cls(bg)
draw_scroll_text(place,0,2,10,fg)
draw_scroll_text(lore,12,1,13,fg)
glitch()
pset(0,0,0)
pset(127,0,0)
end
function roomlore(name)
if power then
bg,fg=5,6
else
bg,fg=0,5
end
if name=='airlock' then
if power then
lore={
'red smeared hand prints mark',
'the only means of escape that',
'was denied to the others.',
'',
'this is the way out, if there',
'is nothing else to be done.',
'',}
else
lore={
'inner hatch sealed.',
'',
'you step out into deep cold',
'and darkness.',
'',
'rare flashes of light act',
'as a guide through each room,',
'to aid not stumbling around',
'this dismal vault.',
'',
'it is immediately clear that',
'something dire happened here.',
''}
bg,fg=0,1
end
end
if name=='cryo' then
lore={
'the cryo chamber room. cold.',
'',
'the empty stasis chambers',
'are arranged in a strangely',
'ornate array.',
'',
'some are smashed, but others',
'appear to be operative.',
''}
if power then
add(lore,'a terminal softly beeps,')
add(lore,'patiently awaiting instructions.')
add(lore,'')
bg,fg=1,6
else
bg,fg=0,1
end
end
if name=='medical' then
lore={
'state of the art and pristine',
'if not for the obvious signs',
'of remedial horror.',
'',
'surgical equipment, bandages',
'and gauze, most of it soiled.',
'',
'it is clear that some of the',
'crew did not leave here alive.',
''}
if power then
add(lore,'the operative medical systems')
add(lore,'emit a warm healing glow.')
add(lore,'')
bg,fg=5,7
else
bg,fg=0,6
end
end
if name=='lab' then
lore={
'science and analysis lab full',
'of secrets and knowledge.',
'',
'vials, samples and equipment',
'at one time neatly arranged',
'and labelled, now scattered.',
''}
end
if name==cpu then
lore={
'central mainframe \''..cpu..'\',',
'aware of all that happens',
'aboard the '..ship..'.',
'',
'it is antiquated, unreasonably',
'large, yet feels warm and',
'reliable. humming in a way that',
'could lull to sleep.',
'',
'the room appears unscathed,',
'a condition that almost seems',
'suspicious.',
''}
if power and not here.done then
lore={
cpu..' is online.',
'',
'the flight data is accessable',
'after confirming with proper',
'access codes. protection can be',
'bypassed, but it may take time.',
''}
bg,fg=5,7
end
end
if name==ops then
lore={
ops..' and control systems,',
'mostly inoperable.',
'',
'long range comms are down.',
'it seems someone tried to send',
'a distress call, but it did',
'not get out. perhaps \''..cpu..'\'',
'knows why.',
'',
'one of the '..ops..' staff',
'still has active permissions',
'logged in on this terminal.',
''}
end
if name=='reactor' then
lore={
'the room is vast, cavernous,',
'water falls from the cooling',
'towers, almost like rain.',
'',
'labyrinthine walkways leading',
'around the chamber, railings',
'of questionable safety.',
'',
'the ftl drive is damaged.',
'incapable of travel, it is able',
'to provide power to the ship',
'but materials are needed.',
''}
if power then
lore={
'the core is operational,',
'booming with a rhythm like',
'that of a beating heart.',
'',
'it would be soothing if all',
'else was not so harrowing.',
''}
bg,fg=5,7
end
end
if name=='engineering' then
lore={
'engineering systems providing',
'remote access to the reactor.',
'',
'stores of inert hydrogen held',
'in canisters, many damaged',
'and leaking, flooding the deck.',
'',
'wading through pink liquid',
'hoping to not be electrocuted.',
''}
if power then
add(lore,'reactor containment can be')
add(lore,'controlled from here.')
add(lore,'')
end
end
if name=='life support' then
lore={
'environmental units and gravity',
'plating rendered useless.',
'',
'parts and cables litter the',
'room, mixed with various',
'growing plantlife that have',
'escaped their confines.',
'',
'many systems hastily pulled',
'apart for components to',
'fashion tools. maybe there is',
'something useful in this mess.',
''}
end
if name=='quarters' then
lore={
'personal living space but for',
'one of some importance.',
'',
'opulant, almost regal but',
'with modern furnishings.',
'many items would fetch a high',
'price, but none are useful.',
'',
'the door secured behind you.',
'designed to protect occupants',
'from other areas of the ship.',
''}
end
if sub(name,1,7)=='storage' then
lore={
'a storage area. one of several.',
'',
'heavy machinery with lifters',
'and mission related equipment.',
'',
'a mess of containers strewn',
'the room, many appear hastily',
'raided for supplies.',
'',
'little of value remains, but',
'there may be something useful.',
''}
if name=='storage b' then
lore={'storage containers, equipment',
'and supplies scattered wildly',
'around in a sudden panic.',
'',
'whatever ghastly incident that',
'befell the '..ship..' crew',
'seems to have started here.',
''}
end
end
if sub(name,1,7)=='habitat' then
lore={
'one group of living quarters.',
'',
'canteen and recreational',
'amenities designed to provide',
'for only a few personnel.',
'',
'messy like a storm swept in.',
'',
'trash strewn amongst rotten',
'food and personal belongings.',
'',
'several unmade bunks, covers',
'stained mostly with blood.',
''}
end
return lore
end
function flightlog()
entries={
{'we were woken from cryo early.',
'it seems '..cpu..' picked up',
'a signal coming from a small',
'uncharted moon.',
'',
'it has been identified as some',
'kind of beacon, but not like',
'anything we have seen before.',
'',
'i have informed the crew but',
'they\'re demanding bonus shares.',
'not surprising. anyway.',
'',
'we are setting down to check',
'out whatever this thing is.',
'',
'captain - '..ship},
{'we hit something. tore open',
'a section of the ship.',
'',
'lost a number of good ppl in',
'a matter of seconds before',
'this demon did the rest.',
'x.o. killed right in front of me.',
'',
'must have crawled in via the',
'breach on deck two. i dont know.',
'',
'if anyone finds this i hope you',
'destroy this ship and send that',
'thing back to hell.',
'',
'i\'m shaking.',
'i might be the only one left.'},
{'please help us',
'',
'there is something onboard with',
'us. we can\'t stop it',
'',
'systems are failing',
'',
'i had to seal habitation but i',
'don\'t think it was enough.',
'',
'i can hear screaming from down',
'the hall',
'',
'i\'m so sorry',
'i don\'t know what to d'},
{cpu..' is reporting some really',
'weird shit and the crew are',
'hearing noises coming from one',
'of the cargo bays.',
'',
'they said they found something',
'but i can\'t bring myself to',
'believe what they are talking',
'about. some awful creature?',
'',
'if i didn\'t know better i',
'would bet someone smuggled',
'unregulated meds onboard.',
'',
'i guess i\'ll have to go down',
'there and see what\'s going on.'},
}
log=entries[flr(rnd(#entries))+1]
add(log,'[eof met]')
end

--hud
function showhud()
rectfill(0,103-offset,128,128,0)
line(63,102-offset,65,102-offset,0)
pset(0,102-offset,0)
pset(127,102-offset,0)
wide(here.name,4,108,6)
local w=here.walls
if (gt>=10) then
if (#moves==1) then
if (moves[1].visited==true) then
smol(moves[1].name..' is up ahead...',4,115,6)
else
smol('a door lies ahead...',4,115,6)
end
end
if (#moves==2) then
if (moves[1].visited==true) then
lt=moves[1].name else lt='a door' end
if (moves[2].visited==true) then
rt=moves[2].name else rt='a door' end
if fork =='NORTH' then
if w[2] then
smol('ahead is '..lt..',',4,115,6)
smol('on the left is '..rt..'...',4,120,6)
elseif w[4] then
smol('ahead is '..lt..',',4,115,6)
smol('on the right is '..rt..'...',4,120,6)
else
smol('on the left is '..rt..',',4,115,6)
smol('on the right is '..lt..'...',4,120,6)
end
end
if fork =='EAST' then
if w[1] then
smol('ahead is '..lt..',',4,115,6)
smol('on the right is '..rt..'...',4,120,6)
elseif w[3] then
smol('ahead is '..rt..',',4,115,6)
smol('on the left is '..lt..'...',4,120,6)
else
smol('on the left is '..lt..',',4,115,6)
smol('to the right is '..rt..'...',4,120,6)
end
end
if fork =='SOUTH' then
if w[2] then
smol('ahead is '..lt..',',4,115,6)
smol('on the right is '..rt..'...',4,120,6)
elseif w[4] then
smol('ahead is '..rt..',',4,115,6)
smol('on the left is '..lt..'...',4,120,6)
else
smol('on the left is '..lt..',',4,115,6)
smol('to the right is '..rt..'...',4,120,6)
end
end
if fork =='WEST' then
if w[1] then
smol('ahead is '..rt..',',4,115,6)
smol('on the left is '..lt..'...',4,120,6)
elseif w[3] then
smol('ahead is '..rt..',',4,115,6)
smol('on the right is '..lt..'...',4,120,6)
else
smol('on the left is '..rt..',',4,115,6)
smol('to the right is '..lt..'...',4,120,6)
end
end
end
if (#moves==0) then
if last then
smol('dead end. the only way back',4,115,6)
smol('is through '..last.name,4,120,6)
end
end
end
if destruct then
if dt >= ds-300 or dt <= (ds/6)+40 then
if not moving then
rectfill(0,109,128,128,0)
smol('self destruct initiated. '..flr(dt/30)..' sec',4,115,4)
smol('to reach minimum safe distance.',4,120,4)
end
end
rectfill(0,107,128,114,0)
wide('destruct',4,108,4)
x=dt * ((124-72) / ds)
rectfill(71,107,71+x,110,4)
pset(71,107,0)
pset(71,110,0)
line(123,108,123,109,4)
end
if access then
pal(6,fg)
spr(139, -6, -5, 1, 1, true, true)
spr(139, 126, -5, 1, 1, false, true)
spr(139, -6, 97, 1, 1, true, false)
spr(139, 126, 97, 1, 1, false, false)
pal()
end
if bleeding then
blink()
if bleedtime >= bs-200 then
if not moving then
rectfill(0,109,128,128,0)
smol('suit compromised. fatal injury.',4,115,8)
smol('seek medical attention now.',4,120,8)
end
end
rectfill(0,107,128,114,0)
if bleedtime <= bs/5 then
rectfill(0,109,128,128,0)
wide('dea^h imminent: '..flr(bleedtime/30),4,116,8)
end
wide('bleeding...',4,108,blinkcol)
x=bleedtime * ((124-72) / bs)
rectfill(71,107,71+x,110,8)
pset(71,107,0)
pset(71,110,0)
line(123,108,123,109,8)
end
if message or searching then
fillp(0B1010101010101010.1)
rectfill(0,107,128,128,0)
fillp()
end
if message then
rectfill(0,107,128,112,0)
wide(message,4,108,6)
end
if searching then
rectfill(0,107,128,110,0)
wide(activity,4,108,6)
x=44 * (st / sp)
rectfill(79,107,79+x,110,7)
pset(79,107,0)
pset(79,110,0)
line(123,108,123,109,7)
end
if boarding or moving then
fillp(0B1010101010101010.1)
rectfill(0,0,126,96,bg)
rectfill(0,109,128,128,0)
fillp()
rectfill(0,107,128,112,0)
wide('walking...',4,108,6)
if (moving=='up') as,ac ='=',10
if (moving=='bk') as,ac =';',10
if (moving=='lt') as,ac ='<',10
if (moving=='rt') as,ac ='>',10
if (bleeding) ac=8
if (destruct) ac=4
wide(as,116,124-aoffset,ac)
end
if status==true then
status=true
if offset==offsetmax then
if holding then
wide('taken',4,103,6)
wide(holding,48,103,7)
end
end
else
status=nil
end
drawhit(bg)
end

--end
function end_upd()
gt+=1
if btnp(5) or gt >= 2000 then
initmap()
_upd=intro_upd
_drw=intro_drw
end
if over=='win' or over=='escape' then
if gt >= 300 and gt <= 350 then
decrunch=true
end
if gt >= 350 then
decrunch=nil
gt=0
over='log'
end
end
end
function end_drw()
cls(bg)
if over=='bled' then
title={ ship..'-','you are dead.' }
epilogue={
'a trail leads to a crimson',
'pool, marking your final place',
'of rest.','','how embarrassing...'
} bg=8 fg=7
end
if over=='killed' then
title={  ship..'-','you are dead.' }
epilogue={
'a nightmare of blades looms',
'twelve foot tall and violently',
'cuts you apart. pieces of your',
'body litter the deck with blood.',
'',
'this ship is but a vessel of the',
'damned, claiming you as its',
'final company, your killer as',
'its sole caretaker.',
'',
ship..'...','',
'this is your tomb.',
'',
'one that should drift in the sea',
'of stars, and remain unsealed.',
'',
'',
'                              forever.'
}
bg=8 fg=7
end
if over=='vacated' then
title={ ship..'-','evacuated.' }
epilogue={
-- 'mission abandoned.','',
'you have failed to deliver the',
'black box, accounting for the',
'tragedy and all souls aboard',
'the \''..ship..'\'.',
'',
'your contract has been',
'terminated and you will now',
'live on basic assistance.',
'',
'legal compensation equaling',
'but not limited to the cost of',
'the craft, crew, and payload',
'will be expected, of course.',
'',
'these matters and any possible',
'criminal charges will be',
'discussed at your tribunal.'
}
bg=8 fg=7
end
if over=='cryo' then
title={ ship..'-','hibernation.' }
epilogue={
'you crawed into the cryo stasis',
'pod, ironically numbered \'xiii\'.',
'',
'you were tired.',
'',
'',
'perhaps when you wake, all will',
'be well. but then what if you',
'only drift silently through the',
'void, unnoticed by time?',
'','sweet dreams.'
}
bg=1 fg=7
end
if over=='boom' then
title={ '\''..ship..'\'','destroyed.' }
epilogue={
'\''..ship..'\' exploded.',
'you died in a glorious fire.',
'',
} bg=4 fg=15
end
if over=='win' then
epilogue={'cargo and ship destroyed.',
'','this was an unauthorised action.',
'noted on permanent record.',
''}
end
if over=='escape' then
epilogue={registry..' blackbox returned.',
''}
end
if over=='win' or over=='escape' then
add(epilogue,'mission complete, runner.')
add(epilogue,'decoding flight data...')
bg=3 fg=7
end
if over=='win' then
title={ '\''..ship..'\'','destroyed.' }
end
if over=='escape' then
title={ '\''..ship..'\'','extricated.' }
end
if over=='pumpkin' then
title={ 'got pumpkin','you\'re the best' }
epilogue={
'thank you for your time',
'playing dispatch.',
} bg=9 fg=7
end
if over=='log' then
title={ registry..', da^a','final log entry:' }
epilogue=log
bg=0 fg=3
end
draw_scroll_text(title,0,2,10,fg)
draw_scroll_text(epilogue,12,1,15,fg)
glitch()
if decrunch then
clip(0,0,128,106)
rectfill(0,0,128,102,0)
local t={3,3,8}
local c=rnd(4)
c=flr(c)
for i=10,50,10 do
local gl_height=rnd(glit.height)
rectfill(0,gl_height,128,gl_height+rnd(16),t[3])
rectfill(0,gl_height,128,gl_height+rnd(16),t[1])
end
clip()
end
pset(0,0,0)
pset(127,0,0)
rectfill(0,103,128,128,0)
line(63,102,65,102,0)
pset(0,102,0)
pset(127,102,0)
if over=='escape' or over=='win' then
if not decrunch then
wide('decoding...',4,108,3)
wide('signature: match',4,116,3)
smol('.ii. ..i ii .ii. i.i .. i.',4,120,3)
x=44 * (gt / (sp*2))
rectfill(79,107,79+x,110,3)
pset(79,107,0)
pset(79,110,0)
line(123,108,123,109,3)
else
wide('decrunching...',4,108,3)
end
elseif over=='log' then
pal(6,fg)
spr(139,-6,-5,1,1,true,true)
spr(139,126,-5,1,1,false,true)
spr(139,-6,97,1,1,true,false)
spr(139,126,97,1,1,false,false)
pal()
wide(ship..'_',4,108,6)
if (comp<0) comp=0
if (comp==100) rank='expert.'
if (comp>=90 and comp<100) rank='efficient.'
if (comp>=70 and comp<90) rank='capable.'
if (comp>=50 and comp<70) rank='liability.'
if (comp<50) rank='inept.'
if (comp<20) rank='worthless.'
if comp>100 then rank='genius' comp=100 end
wide('compe^ence: '..comp..'%',4,116,6)
smol(rank,4,120,6)
elseif over=='pumpkin' then
wide('thank you for',4,108,6)
wide('playing dispa^ch.',4,115,6)
else
wide('mission failed',4,108,6)
print('\151',4,115,6)
smol('restart',14,115,6)
end
end

--util
function draw_scroll_text(buffer,x,f,d,c)
for i=1,#buffer do
cur=''
s=buffer[i]
t=d*(i-1)
if gt>t then
t_speed=(gt-t)*2
b=1
if gt<t+d*2 and #buffer[i]!=0 then
cur='_'
end

  --body...

if (f==1) then
  if (#buffer[i] !=0) then
smol(sub(s..cur,b,t_speed+1),4,i*5+x,c)
else
  x-=2
end
else
wide(sub(s..cur,b,t_speed+1),4,i*5+x,c)
end
end
end
end

function glitch()
local t={7,2,5}
local c=flr(c)
for i=0, 10, 4 do
local gl_height=rnd(128)
for h=4, 10, 2 do
pset(gl_height,rnd(128), bg)
pset(gl_height,rnd(100000), fg)
end
end
if here.fire or intro
or access or bleeding or destruct
or gameover=='log' then
o1=flr(rnd(0x1f00)) + 0x6060
o2=o1 + flr(rnd(0x4)+0x2)
len=flr(rnd(0x40))*2
memcpy(o1*1,o2,len)
end
end
function blink()
bf += 1
if bf > 5 then
bf=0
if blinkcol==8 then
blinkcol=0
else
blinkcol=8
end
end
end
function drawhit(gcol)
if hit==true then
memcpy(24576,2^14+rnd(2^14),rnd(8192))
fillp(0B1010101010101010.1)
rectfill(0,0,128,88,bg)
rectfill(0,106,128,128,0)
fillp()
col={1,2,3,4,5,8,9,10,11,12,13,14}
for c=1,#col do
pal(col[c],gcol,1)
end
end
end
function font()
local ws,ss,wdw,sdw,wm,sm=192,128,8,4,{},{}
charlist=' !"#$%&\'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_'
charwidth={[' ']=4,['1']=2,['!']=8,['#']=8,['%']=8,['\'']=2,['"']=8,['(']=3,[')']=3,[',']=2,['.']=2,['/']=3,[':']=2,[';']=8,['<']=8,['>']=8,['?']=8,i=2,['[']=3,['\\']=4,[']']=3}
charwidth2={[' ']=3,['1']=2,['!']=4,['"']=4,['%']=5,['\'']=2,['"']=4,['(']=4,[')']=4,[',']=2,['.']=2,['/']=4,[':']=2,[';']=2,['<']=4,['>']=4,['?']=5,i=2,['[']=3,['\\']=4,[']']=3}
charmap={}
charmap2={}
for i=1,#charlist do
char=sub(charlist,i,i)
charmap[char]=i+ws-1
if(charwidth[char]==nil)charwidth[char]=wdw
charmap2[char]=i+ss-1
if(charwidth2[char]==nil)charwidth2[char]=sdw
end
end
function wide(str,x,y,c)
pal(6, c)
for i=1,#str do
char=sub(str,i,i)
spr(charmap[char],x,y-1)
x+=charwidth[char]
end
pal()
end
function smol(str,x,y,c)
pal(6, c)
for i=1,#str do
char=sub(str,i,i)
spr(charmap2[char],x,y)
x+=charwidth2[char]
end
pal()
end
function index(i,j)
if (i < 1 or j < 1 or i > size or j > size) then
return -1
end
return i+(j-1)*size
end
function shuffle(tbl)
for i=#tbl, 2, -1 do
local j=flr(rnd(i) + 1)
tbl[i], tbl[j]=tbl[j], tbl[i]
end
return tbl
end
function numtochar(v)
return sub(chars, v, v)
end
function delay(t)
for x=1,t do
yield()
end
end
keys={btns={},ct={}}
function keys:update()
for i=0,13 do
if band(btn(),shl(1,i))==shl(1,i) then
if keys:held(i) then
keys.btns[i]=2
keys.ct[i]=(keys.ct[i]+1) % 30
else
keys.btns[i]=3
end
else
if keys:held(i) then
keys.btns[i]=4
else
keys.btns[i]=0
keys.ct[i]=0
end
end
end
end
function keys:held(b) return band(keys.btns[b],2)==2 end
function keys:down(b) return band(keys.btns[b],1)==1 end
function keys:up(b) return band(keys.btns[b],4)==4 end
function keys:pulse(b,r) return (keys:held(b) and keys.ct[b]%r==0) end

--#include debug.lua
--#include logo.lua
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000880008800000000000000000000200000000000000000000000000000000000
000000000000e0000000e0000000e0000000e0000000e000000000000000e0000888088800220220002000200020202000002000000000000000000000000000
0000000000000000000eee000000ee0000000000000ee000000e0e00000eee000080008000200020000202000002020000022200000000000000000000000000
0000000000e000e000eeeee000e0eee000eeeee000eee0e000ee0ee0000000000000800000000000000000000220002200002000000000000000000000000000
0000000000000000000000000000ee00000eee00000ee000000e0e00000eee000080008000200020000202000002020000002000000000000000000000000000
000000000000e0000000e0000000e0000000e0000000e000000000000000e0000888088800220220002000200020202000002000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000880008800000000000000000000200000000000000000000000000000000000
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
77777777777700007777777777777700777777000077777700000000777777007777777777777700770000000000770077000000000000000000000000000000
77777777777700007777777777777700777777000077777700000000777777007777777777777700770000000000770077000000000000000000000000000000
77000000000077007700000000007700000000007700000077777777000000007700000000000000777777777777770000000000000000000000000000000000
77000000000077007700000000007700000000007700000077777777000000007700000000000000777777777777770000000000000000000000000000000000
77000000000077007777777777777700777777007700000077000000000000007700000000000000770000000000770000000000000000000000000000000000
77000000000077007777777777777700777777007700000077000000000000007700000000000000770000000000770000000000000000000000000000000000
77777777777777007700000000007700000000007777777777777777777777007700000000000000770000000000770000000000000000000000000000000000
77777777777777007700000000007700000000007777777777777777777777007700000000000000770000000000770000000000000000000000000000000000
00000000000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000888008808800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008888808888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088800800888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000666000006060000006600000606000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000
00000000006000006060000060600000606000000000000000000000000000000000000000000000000000000600000000000000666000000000000000000000
00000000600000000060000000600000600000000000000000000000000000000000000000000000000000006600000060000000000000000000000000000000
00000000600000006600000000600000600000000000000000000000000000000000000000000000000000000000000060000000000000006000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000600000006600000066600000600000006660000006600000666000006660000066600000000000000000000000000000666000000000000066600000
60600000600000000060000006600000606000006600000060000000606000006660000060600000600000000000000000000000666000000000000000600000
60600000600000000600000000600000666000000060000066600000006000006060000066600000000000000000000000000000666000000000000000000000
06000000600000006660000066600000006000006600000066600000006000006660000000600000600000000000000000000000000000000000000006000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066000006600000066600000660000000060000066600000666000006060000060000000006000006060000060000000666000006660000066600000
00000000606000006660000060000000606000006600000060000000600000006660000060000000006000006600000060000000666000006060000060600000
00000000666000006060000060000000606000006000000006600000606000006060000060000000006000006060000060000000606000006060000060600000
00000000606000006660000066600000666000006660000060000000066000006060000060000000666000006060000066600000606000006060000066600000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66600000666000006660000006600000666000006060000060600000606000006060000060600000666000006600000000000000660000000000000000000000
60600000606000006000000060000000060000006060000060600000606000000600000006000000006000006000000000000000060000000000000000000000
66600000606000006000000000600000060000006060000060600000666000006060000006000000600000006000000000000000060000000000000000000000
60000000660000006000000066600000060000006660000006000000666000006060000006000000666000006600000000000000660000000000000066600000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666606000006000660000060600006000660000000000600000000600000060000000000000000000000000000000000000000000000006000000
00000000000000600600006006006000060600600006000000000000600000006000000006000000000000000000000000000000666666600000000006000000
00000000000606000000060060000600060606000060000000000000000000006000000006000000000000000000000000000000000000000000000060000000
00000000066000006666600000000060600660006600060000000000000000000600000060000000000000000000000060000000000000006000000060000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666660600000006666660066666660600000006666666006666660666666606666666066666660000000000006000006006000006660006006000060000600
60006060600000000000006000066660600000606000000060000000600000606666666060000060600000006666666060060000060606000600600006006000
60060060600000006000000000000060666666600000006060000060000000606000006066666660000000006000006060060000600600600600600006006000
66666660600000006666666066666660000000606666666066666660000000606666666000000060600000006666666006006000000600006006000060000600
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666606666000066666660666666000000666066666660666666606000006060000000000000606006666060000000660006606666666006666660
00000000600000606000666060000000600000606666000060000000600000006666666060000000000000606660000060000000606660606000006060000060
00000000666666606000006060000000600000606000000006666660600006606000006060000000000000606006600060000000600000606000006060000060
00000000600000606666666066666660666666606666666060000000666660606000006060000000666666606000066066666660600000606000006066666600
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666660666666606666666006666660666666606000006060000060600000606000006060000060666666606600000060000060660000006666666066666660
60000060600000606000000060000000000600006000006006000600600000600666660066606660000000606000000066666660060000000006000066666660
66666660600000606000000000000060000600006000006000606000606660606000006000060000600000006000000060000060060000006666666066666660
60000000666066606000000066666660000600006666666000060000660006606000006000060000666666606600000060000060660000000006000066666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0041420043004443000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
