pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- get dis money - community
-- aaron turner
function _draw()
cls()
mapdraw()
if gamestate__startstate then
startscreendraw()
end
if gamestate__storystate then
storyscreendraw()
end
if gamestate__gameoverstate then
enemydraw()
collectabledraw()
playerdraw()
if gameovertime<=0 then
gameoverscreendraw()
end
end
if gamestate__playstate then
enemydraw()
collectabledraw()
bulletdraw()
playerdraw()
levelcardraw()
end
statedraw()
cameradraw()
debugdraw()
end
function _init()
cartdata("nocomplygames_letsgetdismoney_community_edition_v1")
timeinit()
stateinit()
camerainit()
mapinit()
debuginit()
startscreeninit()
gameoverscreeninit()
playerinit()
levelcarinit()
saveinit()
end
function _update()
timeupdate()
stateupdate()
if slowtime>0 and
gametime % 2<1 then
cameraupdate()
mapupdate()
elseif slowtime<=0 then
cameraupdate()
mapupdate()
end
if gamestate__playstate then
playerupdate()
bulletupdate()
levelcarupdate()
if slowtime>0 and gametime % 4<2 then
enemyupdate()
collectableupdate()
elseif slowtime<=0 then
enemyupdate()
collectableupdate()
end
end
if gamestate__gameoverstate then
if gameovertime>0 and gametime % 4<1 then
enemyupdate()
collectableupdate()
playerupdate()
gameoverscreenupdate()
elseif gameovertime<=0 then
enemyupdate()
collectableupdate()
playerupdate()
gameoverscreenupdate()
end
end
if gamestate__startstate then
startscreenupdate()
end
if gamestate__storystate then
storyscreenupdate()
end
end
function bulletinit()
bullets,actions={},{}
end
function spawnbullet(spawnx,spawny,isgoingleft,isforplayers)
spawnbulletoverload(spawnx,spawny,1,isgoingleft,isforplayers)
end
function bulletfx(bullet)
sfx(4)
if bullet.hitframes<=0 then
bullet.sprite,bullet.hitframes=19,1
end
end
function spawnbulletoverload(spawnx,spawny,speed,isgoingleft,isforplayers)
local bullet={
sprite=18, x=spawnx, y=spawny, width=1, height=1, box={
xleft=1, xright=2, yup=-1, ydown=2
}, flipx=isgoingleft, speed=6.5*speed, dy=rnd(35)/50, aliveframes=0, hitframes=0, isforplayer=isforplayers
}
if isgoingleft then
bullet.dx=bullet.speed*-1
bullet.x-=bullet.speed
else
bullet.dx=bullet.speed
bullet.x+=bullet.speed
end
if bullet.isforplayer then
bullet.dy=0
elseif rnd(2)==0 then
bullet.dy=bullet.dy*-1
end
add(bullets,bullet)
sfx(1)
end
function bulletupdate()
for c in all(actions) do
if costatus(c) then
coresume(c)
else
del(actions,c)
end
end
for bullet in all(bullets) do
if bullet.aliveframes>1 then
if bullet.flipx then
bullet.dx-=.34
else
bullet.dx+=.34
end
if slowtime>0 and bullet.isforplayer then
bullet.x+=(bullet.dx/3)
else
bullet.x+=bullet.dx
end
bullet.y+=bullet.dy
end
if bullet.x<0 or bullet.x>128 or bullet.y<0 or bullet.y>128 then
del(bullets,bullet)
end
if bullet.hitframes<1 and bullet.aliveframes>1 then
if gametime % 2<1 then
bullet.sprite=2
else
bullet.sprite=3
end
end
for enemy in all(enemies) do
if not bullet.isforplayer and
iscollision(bullet,enemy) and
enemy.isdead<=0 and
enemy.immunity<1 then
cashdrop(enemy.x,enemy.y,flr(getcurrentlevel()/2)+1,1)
enemy.isdead+=1
enemiesonscreen-=1
enemiesdefeated+=1
sfx(51)
bulletfx(bullet)
end
end
for boss in all(bosses) do
if not bullet.isforplayer and
iscollision(bullet,boss) and
boss.health>0 and
boss.immunity<1 then
boss.health-=1
boss.immunity=boss.maximmunitty
if boss.health<1 then
spawnhealth((boss.x/2)+10,95,1)
spawnhealth((boss.x/3)+21,99,flr(rnd(2))+1)
spawnhealth((boss.x/2)+34,91,1)
if isfinalboss() then
cashdrop(boss.x,boss.y,getcurrentlevel(),30)
gamestate__finalbossend=true
music(-1)
boss.dy-=8
boss.y+=boss.dy
else
cashdrop(boss.x,boss.y,getcurrentlevel(),15)
del(bosses,boss)
delaygotonextlevel(150)
end
end
sfx(51)
bulletfx(bullet)
end
end
for player in all(players) do
if bullet.isforplayer and
iscollision(bullet,player) and
player.currentinvincible<=0 then
player.health-=1
player.currentinvincible=player.invicibleframes
bulletfx(bullet)
end
end
if iswallleft(bullet) or iswallright(bullet) then
if bullet.hitframes<=0 then
bulletfx(bullet)
end
end
if bullet.hitframes>0 then bullet.hitframes+=1 end
if bullet.hitframes>5 then del(bullets,bullet) end
bullet.aliveframes+=1
end
end
function cashdrop(basex,basey,baseamount,spawnmultiplier)
local c=cocreate(function()
local cashtospawn=flr((getcurrentlevel()/6)*spawnmultiplier)
if cashtospawn<1 then cashtospawn=1 end
for i=cashtospawn,1,-1 do
local cashx=flr(rnd(20))+basex
if cashx>90 then cashx=cashx*-1 end
if cashx<30 then cashx=cashx+10 end
local cashy=flr(rnd(3))+basey-2
spawncash(cashx,cashy,flr(rnd(getcurrentlevel()*2))+baseamount)
yield()
yield()
yield()
end
end)
add(actions,c)
end
function bulletdraw()
for bullet in all(bullets) do
spr(bullet.sprite,bullet.x,bullet.y,1,1,bullet.flipx)
end
end
function camerainit()
gamecamera__x,gamecamera__y,gamecamera__shakeamount,gamecamera__shakeuntil,gamecamera__shakerate,gamecamera__currentshakerate=-128,0,0,0,0,0
end
function screenshake(amount,when,shakerate)
gamecamera__shakeamount,gamecamera__shakeuntil,gamecamera__shakerate=amount,when,shakerate
end
function cameraupdate()
gamecamera__currentshakerate-=1
if gamecamera__shakeuntil>0 then gamecamera__shakeuntil-=1 end
if gamecamera__currentshakerate<0 and
gamecamera__shakeuntil>0 then
gamecamera__currentshakerate=gamecamera__shakerate
if gamecamera__x>0 then
gamecamera__x,gamecamera__y=0,gamecamera__shakeamount
else
gamecamera__y,gamecamera__x=0,gamecamera__shakeamount
end
else
gamecamera__x,gamecamera__y=0,0
end
end
function cameradraw()
camera(gamecamera__x,gamecamera__y)
end
basecollectable={
sprite=10, x=0, y=0, width=1, height=1, dy=0, box={
xleft=1, xright=5, yup=0, ydown=7
}, floaty=0, floatingup=true, maxlifespan=60*4, lifespan=0, floatheight=2, cashtype=false, healthtype=false
}
function basecollectable:new(o)
o=o or {}
setmetatable(o,self)
self.__index=self
return o
end
function collectableinit()
drops,collectablespawnrate={},250
collectablespawnrate=(425)-getcurrentlevel()*2
if bossmode then
collectablespawnrate=flr(collectablespawnrate/1.75)
end
if collectablespawnrate<250 then collectablespawnrate=250 end
end
function spawncash(cashx,cashy,amount)
if gamestate__finalbossstart then
return
end
if count(drops)>50 then
del(drops,drops[0])
end
local newcash=basecollectable:new({
x=cashx, y=cashy
})
newcash.box={
xleft=1, xright=4, yup=0, ydown=3
}
newcash.lifespan,newcash.sprite,newcash.cashtype,newcash.floaty,newcash.amount=newcash.maxlifespan+flr(rnd(20)),10,true,cashy,amount
add(drops,newcash)
end
function spawnhealth(collectablex,collectabley,amount)
if gamestate__finalbossstart then
return
end
local newcollectable=basecollectable:new({
x=collectablex, y=collectabley
})
newcollectable.lifespan,newcollectable.sprite,newcollectable.healthtype,newcollectable.floaty,newcollectable.amount=newcollectable.maxlifespan+flr(rnd(20)),11,true,collectabley,amount
add(drops,newcollectable)
end
function spawncoffee(collectablex,collectabley,amount)
if gamestate__finalbossstart then
return
end
local newcollectable=basecollectable:new({
x=collectablex, y=collectabley
})
newcollectable.lifespan,newcollectable.sprite,newcollectable.coffeetype,newcollectable.coffeetime,newcollectable.floaty=newcollectable.maxlifespan+flr(rnd(20)),12,true,300,collectabley
add(drops,newcollectable)
end
function spawnslowtime(collectablex,collectabley,amount)
if gamestate__finalbossstart then
return
end
local newcollectable=basecollectable:new({
x=collectablex, y=collectabley
})
newcollectable.lifespan,newcollectable.sprite,newcollectable.slowtimetype,newcollectable.slowtime,newcollectable.floaty=newcollectable.maxlifespan,13,true,300,collectabley
add(drops,newcollectable)
end
function floatcollectable(collectable)
if collectable.floatingup then
collectable.dy+=.03
else
collectable.dy-=.03
end
collectable.floaty+=collectable.dy
if collectable.floaty-collectable.y>collectable.floatheight then
collectable.floatingup=false
end
if collectable.floaty<collectable.y then
collectable.floatingup=true
collectable.dy=0
end
end
function generatecollectablespawn()
local spawnlocation={
x=flr(rnd(110)), y=flr(rnd(110)), width=1, height=1
}
if count(bosses)>0 then
local enemyindex=flr(rnd(count(bosses)))+1
spawnlocation.x,spawnlocation.y=bosses[enemyindex].x,bosses[enemyindex].y-8
end
if count(enemies)>0 then
local enemyindex=flr(rnd(count(enemies)))+1
spawnlocation.x,spawnlocation.y=enemies[enemyindex].x,enemies[enemyindex].y-8
end
if isgrounded(spawnlocation) then spawnlocation.y+=8 end
return spawnlocation
end
function collectableupdate()
for collectable in all(drops) do
if collectable.lifespan>0 then collectable.lifespan-=1 end
floatcollectable(collectable)
for player in all(players) do
if iscollision(collectable,player) and player.health>0 then
if collectable.cashtype then
sfx(6)
gamestate__cash+=collectable.amount
if gamestate__cash>=pico__max__number then gamestate__cash=pico__max__number end
del(drops,collectable)
end
if collectable.healthtype then
player.health+=collectable.amount
sfx(5)
if player.health>player.maxhealth then player.health=player.maxhealth end
del(drops,collectable)
end
if collectable.coffeetype then
player.slowtimepowerup,player.coffeepowerup=0,collectable.coffeetime
sfx(5)
del(drops,collectable)
end
if collectable.slowtimetype then
player.coffeepowerup,player.slowtimepowerup=0,collectable.slowtime
sfx(5)
del(drops,collectable)
end
end
if collectable.lifespan<=0 then
del(drops,collectable)
end
end
end
if not allplayersdead() and
gametime % collectablespawnrate==0 and
not levelcarspawned then
local spawn=generatecollectablespawn()
local whichdrop=flr(rnd(9))
if whichdrop>=5 then
spawnhealth(spawn.x,spawn.y,flr(rnd(3))+2)
elseif whichdrop>=2 then
spawncoffee(spawn.x,spawn.y,1)
elseif whichdrop>=0 then
spawnslowtime(spawn.x,spawn.y,1)
end
end
end
function collectabledraw()
for collectable in all(drops) do
if collectable.cashtype then
if collectable.amount>5 then
pal(3,1)
pal(11,12)
elseif collectable.amount>10 then
pal(3,9)
pal(11,10)
elseif collectable.amount>25 then
pal(3,8)
pal(11,14)
elseif collectable.amount>50 then
pal(3,5)
pal(11,13)
end
end
if collectable.lifespan<105 then
if collectable.lifespan % 6>0 and collectable.lifespan % 6<=2 then
pal(1,10)
pal(2,10)
pal(3,10)
pal(4,10)
pal(5,10)
pal(6,10)
pal(7,10)
pal(8,10)
pal(9,10)
pal(11,10)
pal(12,10)
pal(13,10)
pal(14,10)
pal(15,10)
end
end
spr(collectable.sprite,collectable.x,collectable.floaty,collectable.width,collectable.height)
pal()
end
for i=1,count(players) do
local powertitley=0
if i==1 then
powertitley=1
else
powertitley=9
end
if players[i].coffeepowerup>0 then
spr(12,120,powertitley)
end
if players[i].slowtimepowerup>0 then
spr(13,120,powertitley)
end
end
end
function getbox(boxobject)
local boxshift=2
local finalbox={
xright=boxobject.x+boxobject.box.xright+boxshift, xleft=boxobject.x-boxobject.box.xleft+boxshift, yup=boxobject.y-boxobject.box.yup+boxshift, ydown=boxobject.y+boxobject.box.ydown+boxshift
}
return finalbox
end
function iscollision(aobject,bobject)
local abox=getbox(aobject)
local bbox=getbox(bobject)
if abox.xleft>bbox.xright or
bbox.xleft>abox.xright or
abox.yup>bbox.ydown or
bbox.yup>abox.ydown then
return false
end
return true
end
function debuginit()
end
function debugdraw()
end
function enemyinit()
enemies,enemyspawners,enemycatchers,bosses,bossmode,bossspriteindexes,enemyspriteindexes,maxenemyrate,enemiesdefeated,enemiesspawned,enemyspawndelay,enemyspawnskips,enemiesonscreen,maxenemiesonscreen={},{},{},{},false,{64,68,0},{20,23,4,7,36},6,0,0,(60-((getcurrentlevel()-1)*15))/2.35,0,0,getcurrentlevel()*6+6
enemyrate=maxenemyrate
if count(players)>1 then
maxenemiesonscreen+=((getcurrentlevel()-1)*(2+count(players))+6)
end
if getcurrentlevelwithoutloops() % 4==0 then
bossmode=true
end
if bossmode then
local bosshealth=ceil(getcurrentlevel())+7
local bossmaxspeed=1.575
if isfinalboss() then
bossmaxspeed=2.185;
end
local bossmaximmunity=10;
local bossspriteindex=getcurrentlevelwithoutloops()/4
local boss={
spriteindex=bossspriteindexes[bossspriteindex], currentsprite=bossspriteindexes[bossspriteindex], x=90, y=60, width=2, height=2, dx=0, dy=0, box={
xleft=0, xright=11, yup=0, ydown=11
}, flipx=true, immunity=0, maximmunitty=bossmaximmunity, health=bosshealth, speed=bossmaxspeed/2, maxspeed=bossmaxspeed, }
if isfinalboss() then
boss.box.xleft,boss.box.xright,boss.box.yup,boss.box.ydown,boss.width,boss.height=1,4,1,4,1,1
end
add(bosses,boss)
end
if not bossmode then
local spawnery=2
local leftspawner={
sprite=50, x=0, y=spawnery, width=1, height=1, flipx=false, box={
xleft=0, xright=3, yup=3, ydown=5
}
}
local rightspawner={
sprite=49, x=120, y=spawnery, width=1, height=1, flipx=true, box={
xleft=0, xright=3, yup=3, ydown=5
}
}
add(enemyspawners,leftspawner)
add(enemyspawners,rightspawner)
local catchery=105
local leftcatcher={
sprite=54, x=0, y=catchery, width=1, height=1, flipx=false, box={
xleft=0, xright=3, yup=2, ydown=5
}
}
local rightcatcher={
sprite=55, x=120, y=catchery, width=1, height=1, flipx=true, box={
xleft=0, xright=3, yup=2, ydown=5
}
}
add(enemycatchers,leftcatcher)
add(enemycatchers,rightcatcher)
end
end
function isfinalboss()
if getcurrentlevelwithoutloops()==12 then
return true
else
return false
end
end
function spawnenemy()
local spawnpoint=enemyspawners[flr(rnd(count(enemyspawners))+1)]
local levelspriteindex=ceil(getcurrentlevel()/3)+1
if levelspriteindex>count(enemyspriteindexes) then
levelspriteindex=count(enemyspriteindexes)
end
local enemyspriteindex=flr(rnd(levelspriteindex)+1)
local randomsprite=enemyspriteindexes[enemyspriteindex]
local randomspeed=(rnd(2)/5)+(enemyspriteindex/(count(enemyspriteindexes)/2))
if randomspeed>1.985 then randomspeed=1.985 end
randomspeed=randomspeed*2
local enemy={
spriteindex=randomsprite, currentsprite=randomsprite, x=spawnpoint.x, y=spawnpoint.y-4, width=1, height=1, dx=randomspeed, dy=0, box={
xleft=1, xright=4, yup=0, ydown=5
}, flipx=false, immunity=20-getcurrentlevelwithoutloops(), isdead=0
}
add(enemies,enemy)
enemiesonscreen+=1
enemiesspawned+=1
end
function enemyupdate()
enemyspawndelay-=1
if gamestate__playstate and
not bossmode and
enemyspawndelay<0 and
enemiesdefeated<maxenemiesonscreen then
enemyrate-=1
if enemyrate<=0 then
enemyrate=maxenemyrate
local shouldspawn=flr(rnd(maxlevels-getcurrentlevel()+2))
if shouldspawn==1 or enemyspawnskips>=10 then
spawnenemy()
enemyspawnskips=0
else
enemyspawnskips+=count(players)+(getcurrentlevel())
end
end
end
if enemiesdefeated>=maxenemiesonscreen-flr(getcurrentlevel()*2) and
not levelcarspawned then
spawnlevelcar()
end
for spawner in all(enemyspawners) do
if gametime % 7<3 then
spawner.sprite=50
else
spawner.sprite=49
end
if isgrounded(spawner) then
spawner.y=flr(flr(spawner.y)/8)*8
else
spawner.y+=0.75
end
end
for catcher in all(enemycatchers) do
if gametime % 7<3 then
catcher.sprite=55
else
catcher.sprite=54
end
if isgrounded(catcher) then
catcher.y=flr(flr(catcher.y)/8)*8
else
catcher.y+=0.75
end
end
for enemy in all(enemies) do
enemy.immunity-=1
if enemy.isdead>2 then
del(enemies,enemy)
elseif enemy.isdead>0 then
enemy.isdead+=1
end
if enemy.isdead<=0 then
if enemy.x<0 or iswallleft(enemy) then
enemy.x+=1
enemy.flipx,enemy.dx=false,abs(enemy.dx)+.05
if enemy.dx>2 then enemy.dx=2 end
end
if enemy.x>120 or iswallright(enemy) then
enemy.x-=1
enemy.flipx,enemy.dx=true,enemy.dx*-1+.05
if enemy.dx<-2 then enemy.dx=-2 end
end
if enemy.y>120 then
enemy.y=119
end
if gametime % 7<3 then
enemy.currentsprite=enemy.spriteindex+1
else
enemy.currentsprite=enemy.spriteindex
end
if isgrounded(enemy) then
enemy.dy,enemy.y=0,flr(flr(enemy.y)/8)*8
local shouldjump=flr(rnd(30))
if getcurrentlevel()>4 and
shouldjump==9 and
enemy.spriteindex==enemyspriteindexes[1] then
sfx(0)
enemy.dy-=2.4
end
else
enemy.dy+=0.34
end
enemy.x+=enemy.dx
enemy.y+=enemy.dy
for player in all(players) do
if iscollision(player,enemy) and
player.currentinvincible<=0 and
player.health>=1 and
enemy.isdead<=0
then
player.currentinvincible=player.invicibleframes
player.health-=1;
if player.health>0 then sfx(3) end
screenshake(1.35,8,1)
end
end
for catcher in all(enemycatchers) do
if(iscollision(enemy,catcher) and enemy.y<=catcher.y) then
enemiesonscreen-=1
del(enemies,enemy)
end
end
end
end
for boss in all(bosses) do
if gamestate__finalbossstart then
if isgrounded(boss) then
gamestate__finalbossstart=false
else
boss.dy=0.19
boss.y+=boss.dy
end
return
end
if gamestate__finalbossend then
if not runspeedsaved then
savespeed()
runspeedsaved,gamestate__canloop=true,true
end
boss.dy+=0.19
if gametime % 5==0 then
boss.y+=boss.dy
end
if isgrounded(boss) then
delaygotonextlevel(150)
gamestate__finalbossend=false
boss.health=-100
end
return
end
boss.immunity-=1
if boss.health>0 then
if boss.x<0 or iswallleft(boss) then
boss.x+=1
boss.flipx,boss.dx=false,abs(boss.dx)+.1
end
if boss.x>120 or iswallright(boss) then
boss.x-=1
boss.flipx,boss.dx=true,boss.dx*-1+.1
end
if gametime % 7<3 then
if isfinalboss() then
boss.currentsprite=boss.spriteindex+1
else
boss.currentsprite=boss.spriteindex+2
end
else
boss.currentsprite=boss.spriteindex
end
if boss.spriteindex !=bossspriteindexes[1] then
local shouldshoot=flr(rnd(70))
if shouldshoot==10 and
flr(enemyspawndelay/2)+50<=0 and
not allplayersdead() then
local bulletspawnx=4
local bulletspawny=8
local bulletspeed=0.125
if isfinalboss() then
bulletspawny,bulletspeed=0,0.325
end
if boss.flipx then
spawnbulletoverload(boss.x-bulletspawnx,boss.y+bulletspawny,bulletspeed,true,true)
else
spawnbulletoverload(boss.x+bulletspawnx,boss.y+bulletspawny,bulletspeed,false,true)
end
end
end
if isgrounded(boss) then
boss.dy,boss.y=0,flr(flr(boss.y)/8)*8
if boss.spriteindex !=bossspriteindexes[2] then
local shouldjump=flr(rnd(60))
if shouldjump==10 and
not allplayersdead() then
sfx(0)
boss.dy-=3.4
end
end
else
boss.dy+=0.34
end
if boss.y>120 then
boss.y=119
end
local nearestplayer=players[1];
if count(players)>1 then
if (abs(nearestplayer.x-boss.x)>abs(players[2].x-boss.x) and
players[2].health>0) or
players[1].health<=0 then
nearestplayer=players[2];
end
end
if nearestplayer.x-boss.x>0 then
boss.dx+=boss.speed
boss.flipx=false
else
boss.dx-=boss.speed
boss.flipx=true
end
if boss.dx>boss.maxspeed then boss.dx=boss.maxspeed end
if boss.dx<boss.maxspeed*-1 then boss.dx=boss.maxspeed*-1 end
if not allplayersdead() and flr(enemyspawndelay/2)+20<=0 then
if boss.health<3 then
boss.x+=(boss.dx/1.5)
else
boss.x+=boss.dx
end
end
boss.y+=boss.dy
for player in all(players) do
if (iscollision(player,boss) and player.currentinvincible<=0 and player.health>=1) then
player.currentinvincible=player.invicibleframes
player.health-=1;
sfx(3)
screenshake(1.45,9,1)
end
end
else
if isfinalboss() then
boss.currentsprite=17
end
end
end
end
function enemydraw()
if gamestate__finalbossstart and gametime % 60>50 then
if gametime % 60<55 then
rectfill(0,0,128,128,2)
else
rectfill(0,0,128,128,8)
end
end
if gamestate__finalbossend then
rectfill(0,0,128,128,7)
end
for enemy in all(enemies) do
if enemy.spriteindex==enemyspriteindexes[1] and
getcurrentlevel()>4 then
pal(12,8)
end
if enemy.isdead>0 then
hurtpal()
end
spr(enemy.currentsprite,enemy.x,enemy.y,enemy.width,enemy.height,enemy.flipx)
pal()
end
for spawner in all(enemyspawners) do
spr(spawner.sprite,spawner.x,spawner.y,spawner.width,spawner.height,spawner.flipx)
end
for catcher in all(enemycatchers) do
spr(catcher.sprite,catcher.x,catcher.y,catcher.width,catcher.height,catcher.flipx)
end
for boss in all(bosses) do
pal(3,1)
pal(5,4)
pal(14,13)
pal(8,2)
pal(7,8)
if boss.immunity>0 then
hurtpal()
end
spr(boss.currentsprite,boss.x,boss.y,boss.width,boss.height,boss.flipx)
pal()
end
end
function gameoverscreeninit()
gameovertime=30
end
function gameoverscreenshow()
gamestate__playstate=false
gamestate__gameoverstate=true
if not gamestate__gameoverstategood then
sfx(7)
end
playerpowerreset()
playmusic(-1)
gameovertime=32
saverun()
end
function gameoverscreenupdate()
if gameovertime<0 then
if btn(4) or btn(5) then
gamestate__playstate,gamestate__gameoverstate,gamestate__gameoverstategood,gamestate__cash,gamestate__rollingcash,gamestate__runframes,gameovertime=true,false,false,0,0,0,45
resetplaystate()
elseif btn(3) then
stateinit()
camerainit()
mapinit()
startscreeninit()
storyscreendraw()
gameoverscreeninit()
playerinit()
levelcarinit()
end
else
gameovertime-=1
if gameovertime<=0 and not gamestate__gameoverstategood then
playmusic(12)
end
end
end
function gameoverscreendraw()
rectfill(10, 25, 115, 90, 0
)
if gamestate__gameoverstategood then
print("\x87 thanks for playing! \x87",15,30,14)
else
print("game over",50,30,8)
end
print("cash collected: $" .. gamestate__rollingcash,25,40,11)
if loops<=0 then
if not gamestate__gameoverstategood then
print("last level: " .. (getcurrentlevel()-(loops*12)),38,50,7)
end
else
print("loop " .. loops .. ",level " .. (getcurrentlevel()-(loops*12)),34,50,7)
end
print("press \x8e to get dis money",15,70,7);
print("press \x83 to go to start",19,80,7);
end
baselevelcar={
x=64, y=10, width=2, height=1, dy=0, dx=0, box={
xleft=1, xright=10, yup=-1, ydown=4
}, spriteindex=104, sprite=104, spawned=false, immunity=0, liftoff=false, isend=false
}
function baselevelcar:new(o)
o=o or {}
setmetatable(o,self)
self.__index=self
return o
end
function levelcarinit()
levelcars,levelcarspawned,levelcarshot,levelcarshotdelay={},false,0,10
add(levelcars,baselevelcar:new({}))
add(levelcars,baselevelcar:new({
x=90, y=70, immunity=200, isend=true
}))
end
function spawnlevelcar()
levelcarspawned=true
levelcars[1].x,levelcars[1].y,levelcars[1].spawned=playerspawn__x,playerspawn__y,true
end
function spawnendlevelcars()
levelcarspawned=true
levelcars[2].spawned=30,70,true,200,true
end
function levelcarupdate()
for levelcar in all(levelcars) do
if not levelcar.spawned then
return true
end
if levelcar.immunity>0 then
levelcar.immunity-=1
end
if isgrounded(levelcar) and not levelcar.liftoff then
levelcar.dy,levelcar.y,levelcar.sprite=0,flr(flr(levelcar.y)/8)*8,levelcar.spriteindex
elseif levelcar.liftoff then
levelcar.dy-=.42
if levelcar.y>-20 then
screenshake(1.5,2,3)
end
if gametime % 7<3 then
levelcar.sprite=levelcar.spriteindex+4
else
levelcar.sprite=levelcar.spriteindex+6
end
else
levelcar.dy+=.52
if gametime % 7<3 then
levelcar.sprite=levelcar.spriteindex
else
levelcar.sprite=levelcar.spriteindex+2
end
end
if levelcar.y>128 then
levelcar.dy,levelcar.y=-.27,127
end
for player in all(players) do
if levelcar.immunity<=0 and iscollision(levelcar,player) then
player.x,player.y,levelcar.liftoff,levelcar.height=-100,-100,true,2
sfx(8)
end
end
if levelcar.y<-20 then
if levelcar.isend then
gamestate__gameoverstategood=true
gameoverscreenshow()
gameovertime=0
else
gotonextlevel()
end
end
if levelcar.y<-20 then
levelcar.y=-30
levelcar.dy=0
end
levelcar.y+=levelcar.dy
levelcar.x+=levelcar.dx
end
end
function levelcardraw()
for levelcar in all(levelcars) do
if levelcar.spawned then
if levelcar.isend then
pal(14,12)
pal(12,14)
end
spr(levelcar.sprite,levelcar.x,levelcar.y,levelcar.width,levelcar.height)
pal()
if isfinalboss() then
if levelcar.isend then
print("cash out",83,100,11)
else
print("continue?",20,100,8)
end
end
end
end
end
function sort(a,order)
for i=1,#a do
local j=i
if order then
while j>1 and a[j-1]>a[j] do
a[j],a[j-1],j=a[j-1],a[j],j-1
end
else
while j>1 and a[j-1]<a[j] do
a[j],a[j-1],j=a[j-1],a[j],j-1
end
end
end
end
function ceil(num)
return flr(num+0x0.ffff)
end
pico__max__number=32767
function mapinit()
bgstars={}
for i=1,128 do
add(bgstars,{
x=flr(rnd(128)), y=flr(rnd(128)), color=flr(rnd(3)), dx=rnd(1.05)*-1
})
end
currentmap__x,currentmap__y,currentmap__xspread,currentmap__yspread=0,0,32,16
end
function mapupdate()
for star in all(bgstars) do
if gamestate__finalbossstart then
if gametime % 10==0 then
star.x+=star.dx
end
else
star.x+=star.dx
end
if star.x<0 then star.x=128 end
end
end
function mapdraw()
for star in all(bgstars) do
if star.color==0 then
pset(star.x,star.y,5)
elseif star.color==1 then
pset(star.x,star.y,13)
else
pset(star.x,star.y,6)
end
end
if gamestate__playstate or gamestate__gameoverstate then
map(currentmap__x*currentmap__xspread,currentmap__y*currentmap__yspread,0,0,currentmap__yspread,currentmap__xspread)
end
end
function getrelativemaplocation(xyobject,xrelative,yrelative)
if xrelative>0 then xrelative+=xyobject.width-1 end
if yrelative>0 then yrelative+=xyobject.height-1 end
return mget((currentmap__x*currentmap__xspread)+(flr(xyobject.x+4)/8)+xrelative, (currentmap__y*currentmap__yspread)+(flr(xyobject.y)/8)+yrelative)
end
function isgrounded(xyobject)
return fget(getrelativemaplocation(xyobject,0,1),0)
end
function isceiling(xyobject)
return fget(getrelativemaplocation(xyobject,0,-0.15),0)
end
function iswallleft(xyobject)
return fget(getrelativemaplocation(xyobject,-0.5,0),0)
end
function iswallright(xyobject)
return fget(getrelativemaplocation(xyobject,0.5,0),0)
end
function hurtpal()
pal(1,8)
pal(2,8)
pal(3,8)
pal(4,8)
pal(5,8)
pal(6,8)
pal(7,8)
pal(9,8)
pal(10,8)
pal(11,8)
pal(12,8)
pal(13,8)
pal(14,8)
pal(15,8)
end
function playerinit()
players={}
for i=1,gamestate__numplayers do
local spawnmultiplier=(i/2)+1
local spawndistance=8*spawnmultiplier
if i % 2==1 then
spawndistance=spawndistance*-1
end
spawnplayer(spawndistance)
end
playerinputdelay=15
end
function spawnplayer(spawnx)
playerspawn__x,playerspawn__y=60,20
local player={
sprite=0, x=playerspawn__x, y=playerspawn__y, width=1, height=1, dx=0, dy=0, box={
xleft=1, xright=4, yup=1, ydown=4
}, flipx=false, moving=false, grounded=false, jumps=2, maxhealth=10, health=10, invicibleframes=90, currentinvincible=0, coffeepowerup=0, slowtimepowerup=0, wingspowerup=0, bigbulletspowerup=0
}
add(players,player)
resetplayerlocation()
end
function resetplayerlocation()
if count(players)>1 then
for i=1,count(players) do
if i==1 then
players[i].x=playerspawn__x+8
else
players[i].x=playerspawn__x-8
end
players[i].y=playerspawn__y
end
else
players[1].x,players[1].y=playerspawn__x,playerspawn__y
end
end
function playerupdate()
if gamestate__finalbossstart or
gamestate__finalbossend then
playerinputdelay=2
end
if playerinputdelay>0 then
playerinputdelay-=1
end
for i=1,count(players) do
if players[i].health<=0 then
players[i].sprite=17
if not gamestate__gameoverstate and allplayersdead() then
gameoverscreenshow()
players[i].dy-=3.8
else
if isgrounded(players[i]) then
players[i].dy=0
else
players[i].dy+=0.24
end
end
players[i].currentinvincible=0
players[i].y+=players[i].dy
else
playeraction(players[i],i)
if(players[i].moving and gametime % 2<1) then
players[i].sprite=1
else
players[i].sprite=0
end
if players[i].currentinvincible>0 then players[i].currentinvincible-=1 end
if players[i].coffeepowerup>0 then players[i].coffeepowerup-=1 end
if players[i].slowtimepowerup>0 then players[i].slowtimepowerup-=1 end
if players[i].wingspowerup>0 then players[i].wingspowerup-=1 end
end
end
end
function playeraction(player,playerindex)
local playernum,speed,maxspeedmultiplier,gravity=playerindex-1,1.05,2.1,0.375
if player.coffeepowerup>0 then
speed+=.5
end
if player.wingspowerup>0 then gravity-=1 end
if btn(0,playernum) and
not iswallleft(player) and
playerinputdelay<=0 then
player.moving=true
if player.dx>abs(speed*maxspeedmultiplier)*-1 and gametime % 3==1 then player.dx-=speed end
player.flipx=true
elseif btn(1,playernum) and
not iswallright(player) and
playerinputdelay<=0 then
player.moving=true
if player.dx<abs(speed*maxspeedmultiplier) and gametime % 3==1 then player.dx+=speed end
player.flipx=false
else
if abs(player.dx)<speed and gametime % 3==1 then
player.dx=0
elseif player.dx<0 and gametime % 3==1 then
player.dx+=speed
elseif player.dx>0 and gametime % 3==1 then
player.dx-=speed
end
player.moving=false
end
if isgrounded(player) then
player.dy,player.jumps,player.y=0,2,flr(flr(player.y)/8)*8
if not player.grounded then
playermapbump()
player.grounded=true
end
elseif isceiling(player) then
player.dy=gravity
player.y+=0.22
else
player.dy+=gravity
player.grounded=false
end
if ((btnp(5,playernum) or btnp(2,playernum)) and
player.jumps>0 and
not isceiling(player)) and
playerinputdelay<=0 then
playerjump(player)
end
if btnp(4,playernum) and
playerinputdelay<=0 then
if player.flipx then
spawnbullet(player.x-5,player.y,true,false)
player.dx+=0.25
else
spawnbullet(player.x+5,player.y,false,false)
player.dx-=0.25
end
local bulletshake=count(players)*2
if count(bullets)>0 and count(bullets) % bulletshake==1 then
screenshake(1,2,1)
end
end
if count(players)>1 then
for i=1,count(players) do
if i !=playerindex and
players[playerindex].health>=2 and
players[i].health<=0 and
iscollision(players[playerindex],players[i]) then
local halfhealth=flr(players[playerindex].health/2)
players[playerindex].health-=halfhealth
players[i].health=halfhealth
players[i].invicibleframes=120
sfx(3)
end
end
end
if iswallleft(player) and player.dx<0 then
playermapbump()
player.dx=0
end
if iswallright(player) and player.dx>0 then
playermapbump()
player.dx=0
end
player.x+=player.dx
player.y+=player.dy
if player.x<0 then player.x=0 end
if player.x>120 then player.x=120 end
if player.y>120 then player.y=120 end
end
function playerpowerreset()
for player in all(players) do
player.currentinvincible,player.coffeepowerup,player.slowtimepowerup,player.wingspowerup,player.bigbulletspowerup=0,0,0,0,0
end
end
function playerjump(player)
sfx(0)
if player.dy>0 then player.dy=0 end
player.dy-=3.65
player.jumps-=1
end
function playermapbump()
screenshake(1.25,5,1)
sfx(2)
end
function allplayersdead()
local numplayersdead=0
for player in all(players) do
if flr(player.health)<=0 then
numplayersdead+=1
end
end
if numplayersdead>=count(players) then
return true
else
return false
end
end
function playerdraw()
for i=1,count(players) do
if players[i].currentinvincible>(players[i].invicibleframes-10) then
hurtpal()
end
spr(players[i].sprite,players[i].x,players[i].y,1,1,players[i].flipx)
pal()
local numhearts=5
for k=1,numhearts,1 do
local heartcolor=8
if players[i].health>flr(players[i].maxhealth/2) and
k<=players[i].health-flr(players[i].maxhealth/2) then
heartcolor=12
end
if k>players[i].health then
heartcolor=5
end
if i==1 then
print("\x87",8*k-4,2,heartcolor)
else
print("\x87",8*k-4,10,heartcolor)
end
end
end
end
function saveinit()
loadgame()
end
function savereset()
totalcash,topspeeds,topcashruns=0,{},{}
end
function loadgame()
savereset()
if not dget(0) or dget(0)==0 then
return false
end
if dget(0) then
totalcash=dget(0)
if totalcash<0 or totalcash>pico__max__number then totalcash=pico__max__number end
end
end
function saverun()
totalcash+=gamestate__cash
if totalcash<0 or totalcash>pico__max__number then totalcash=pico__max__number end
dset(0,totalcash)
loadgame()
end
function shopinit()
browseindex,browsedelay=1,0
end
function resetbrowsedelay()
browsedelay=5
end
function shopupdate()
if browsedelay>0 then browsedelay-=1 end
if gametime % 6==0 then
for unlock in all(gameunlockables) do
if unlock.spriteindex+1>count(unlock.sprites) then
unlock.spriteindex=1
else
unlock.spriteindex+=1
end
end
end
if btn(2) then
startstatedelay,gamestate__startstate,gamestate__shopstate=60,true,false
end
if btn(0) and browsedelay<=0 then
if browseindex>1 then
browseindex-=1
end
resetbrowsedelay()
end
if btn(1) and browsedelay<=0 then
if browseindex<count(gameunlockables) then
browseindex+=1
end
resetbrowsedelay()
end
if (btn(4) or btn(5)) and browsedelay<=0 then
if not gameunlockables[browseindex].purchased and
totalcash>gameunlockables[browseindex].price then
totalcash-=gameunlockables[browseindex].price
gameunlockables[browseindex].purchased=true
equipunlock(browseindex)
savepurchase()
elseif not gameunlockables[browseindex].equipped and
gameunlockables[browseindex].purchased then
equipunlock(browseindex)
savepurchase()
else
sfx(50)
end
resetbrowsedelay()
end
end
function equipunlock(index)
gameunlockables[1].equipped=false
for i=1,count(gameunlockables) do
if i==index then
gameunlockables[i].equipped=true
else
gameunlockables[i].equipped=false
end
end
end
function shopdraw()
local unlock,pricey,pricecolor=gameunlockables[browseindex],30,11
print(unlock.title.text,unlock.title.x,20,10)
if unlock.equipped then
print("equipped",48,pricey,12)
elseif unlock.purchased then
print("purchased",48,pricey,pricecolor)
else
if unlock.price>totalcash then pricecolor=8 end
print("cost: $" .. unlock.price,40,pricey,pricecolor)
end
if unlock.purchased then
if browseindex==2 then
keboppal()
end
if browseindex==3 then
bunterpal()
end
else
for i=0,15 do
pal(i,5)
end
end
local spritey=45
spr(unlock.sprites[unlock.spriteindex],60,spritey)
pal()
print(unlock.descriptionlineone.text,unlock.descriptionlineone.x,60,7)
print(unlock.descriptionlinetwo.text,unlock.descriptionlinetwo.x,70,7)
if browseindex>1 then
print("\x8b previous",10,85,7);
else
print("\x8b previous",10,85,5);
end
if browseindex<count(gameunlockables) then
print("next \x91",95,85,7);
else
print("next \x91",95,85,5);
end
print("total money: $" .. totalcash,30,95,11)
print("press \x94 to go back to start",8,115,7)
end
function startscreeninit()
startstatedelay=30
playmusic(16)
end
function startscreenupdate()
if startstatedelay<0 then
if btn(1) then
gamestate__numplayers,gamestate__playstate,gamestate__startstate=1,true,false
resetplaystate()
end
if btn(0) then
gamestate__storystate,gamestate__startstate=true,false
end
else
startstatedelay-=1
end
end
function startscreendraw()
print("get dis money",40,15,11);
print("community edition",31,25,8);
if gametime % 12<6 then
spr(0,62,42)
else
spr(1,62,42)
end
pal()
print("\x8b story",26,62,7);
print("start \x91",71,62,7);
print ("total cash: $" .. totalcash,35,85,11)
print ("a game by aaron turner",23,95,12)
print ("get the full game at",25,105,7)
print ("https://getdismoney.com",20,115,12)
end
function stateinit()
gamestate__numplayers,gamestate__cash,gamestate__runframes,gamestate__runseconds,gamestate__runminutes,gamestate__rollingcash,gamestate__startstate,gamestate__playstate,gamestate__storystate,gamestate__numplayersstate,gamestate__statsstate,gamestate__shopstate,gamestate__finalbossstart,gamestate__finalbossend,gamestate__gameoverstate,gamestate__gameoverstategood,gamestate__canloop=1,0,0,0,0,0,true,false,false,false,false,false,false,false,false,false,false
runspeedsaved,nextleveldelay,maxlevels,loops=false,0,12,0
end
function stateupdate()
if gamestate__playstate and not gamestate__canloop then
if gamestate__runframes>=60 then
if gamestate__runseconds>=60 then
gamestate__runminutes+=1
gamestate__runseconds=0
end
gamestate__runseconds+=1
gamestate__runframes=0
end
gamestate__runframes+=1
end
if gamestate__rollingcash<gamestate__cash and gametime % 2==0 then
gamestate__rollingcash+=1
elseif gamestate__rollingcash>=gamestate__cash then
gamestate__rollingcash=gamestate__cash
end
if nextleveldelay>1 then nextleveldelay-=1 end
if nextleveldelay==1 then
if isfinalboss() then
spawnendlevelcars()
else
spawnlevelcar()
end
nextleveldelay-=1
end
end
function statedraw()
if gamestate__playstate then
print("$" .. gamestate__rollingcash,56,2,11)
end
end
function resetplaystate()
mapinit()
debuginit()
playerinit()
bulletinit()
enemyinit()
collectableinit()
runspeedsaved,gamestate__runframes,gamestate__runseconds,gamestate__runminutes,gamestate__canloop=false,0,0,0,false
playmusic(0)
end
function playmusic(track)
music(-1)
music(track)
end
function getcurrentlevel()
local currentlevel=currentmap__x+(currentmap__y*4)
if currentmap__y>2 then
currentlevel=flr(currentlevel/3)+(currentmap__x*2)
if currentlevel % 4==0 then currentlevel-=1 end
end
currentlevel+=1
currentlevel=currentlevel+(loops*maxlevels)
return currentlevel
end
function getcurrentlevelwithoutloops()
local currentlevel=getcurrentlevel()
if getcurrentlevel()>maxlevels then
currentlevel=getcurrentlevel()-(loops*maxlevels)
end
return currentlevel
end
function delaygotonextlevel(delay)
nextleveldelay=delay
end
function gotonextlevel()
if (currentmap__x+1) % 4==0 then
currentmap__x=0;
currentmap__y+=1
if currentmap__y==1 then
playmusic(25)
elseif currentmap__y==2 then
playmusic(29)
end
else
currentmap__x+=1
if currentmap__x==3 then
if currentmap__y<2 then
playmusic(17)
else
playmusic(50)
gamestate__finalbossstart=true
end
end
end
playerpowerreset()
levelcarinit()
enemyinit()
collectableinit()
resetplayerlocation()
end
function storyscreenupdate()
if btn(4) or btn(5) or btn(1) then
startstatedelay,gamestate__startstate,gamestate__storystate=30,true,false
end
end
function storyscreendraw()
print("og deanbad is a gangsta,",10,2,12)
print("in space.",10,12,7)
print("in the year 3030,",10,22,10)
print("gangstas get paid.",10,32,7)
print("alien bounties",10,42,8)
print("is the new hustle,",10,52,7)
print("let's",10,62,7)
print("get dis money",35,62,11)
print("press \x91 to go back to start",8,110,7)
end
function timeinit()
gametime,slowtime=0,0
end
function timeupdate()
gametime+=1
slowtime=0
for player in all(players) do
if player.slowtimepowerup>slowtime then
slowtime=player.slowtimepowerup
end
end
if gametime>=pico__max__number then
timeinit()
end
end
__gfx__
333333003333330000000000000000000000a9000000000000000000000000000000000000000000000000000000000000000000000000005555555555555555
333333333333333300000000000000000000a0000000a9000000000000a8000000a8000000000000000000000777877700777700044444405555555555555555
44744700447447000000000000000000000044400000a0000000000000a0000000a0000000000000033333300778887707444770007ff7005555555555555555
44444400444444008d99a0000d99a000000044800000444000000000009997700099977000000000033bb3300777877707777707000770005454545445454545
cccccc56cccccc560d99a0008d99a000000044400000448000000000009997700099977000000000033333300777777707777770007ff7005545444444445455
4eeeee504eeeee50000000000000000000004000000044400000000000bbbbb000bbbbb000000000000000000666666600666000044444405444454444544445
ee0080008000ee00000000000000000004444000044440000000000000bbbbb000bbbbb000000000000000000000000000000000000000005544144444441455
80000000000080000000000000000000004040000404000000000000003000300030030000000000000000000000000000000000000000005441441441414445
00000000000000000000000000000000000000000000000000000000000000000000000000000000333333337777777755555555000000004444444444444444
00000000000000030000000000000000000000000000000000000000000aa0000000000000000000333333337777777755555555000000004444444444444444
000000000000000300aa0000080909000000000000eeee000000000000aeea00000aa000000000003b3b3b337777777755555555000000004441441441444144
000000000eec453309aaa0000000a0000eeeeee00ecccce0000000000aeeeea000aeea0000000000b4bbb3b3cc7ccc7c54454544000000004144414444141444
000000008eec553389aaaa000d080000ecc77cceecc77cce00000000aeeeeeea0aeeeea0000000004444b444ccccc7cc45445454000000004444444444444414
0000000000ec443309aaa00080900a00ecccccceecccccce000000000aabbaa0aeeeeeea0000000044244424ccc1cccc44544144000000004444144441414141
000000000eec443300aa000000800000ecececeeeececece00000000000aa0000aabbaa00000000042442444c7cc1c7c14441414000000004414441414141414
000000008eec443300000000000000000e0e0e0ee0e0e0e00000000000000000000aa00000000000222222221111111111111111000000004144414411111111
0000000000000000000000000000000000dddd0000dddd0000000000000000000000000000000000333333333333333377777777777777770000000000000000
000000000000000000000000000000000dddddd00dddddd000000000000000000000000000000000333333333333333377777777777777770000000000000000
00000000000000000000000000000000dadeedaddadeedad00000000000000000000000000000000333b33333333b33377777777777777770000000000000000
00000000000000000000000000000000ddeeeeddddeeeedd0000000000000000000000000000000033b3bb3bb3bb3bb377cc7cccccc7cc770000000000000000
00000000000000000000000000000000dd2ee2dddd2ee2dd000000000000000000000000000000003b3bb4b44b4bb3b377cccc7cc7cccc770000000000000000
00000000000000000000000000000000dddddddddddddddd000000000000000000000000000000003bb4424444244bb377c7c7cccc7ccc770000000000000000
00000000000000000000000000000000dddddddddddddddd00000000000000000000000000000000b44244244244244b7ccccc7cccc7ccc70000000000000000
00000000000000000000000000000000d0d0d0d00d0d0d0d0000000000000000000000000000000044244244442442447cc11cccc11cc1c70000000000000000
333333330dddddd00dddddd0777777775555555500000000055555500555555000000000000000004444444444444444cccccccccccccccc0000000000000000
333333330dbee1d00deeeed077777777555555550000000005881a500533885000000000000000004444444442444444cccccccccccccccc0000000000000000
3b3b3b330dbeb1d00d11ced077777777555555550000000005e81a5005a3a85000000000000000004242442444424424c7cc7cccc1cccc1c0000000000000000
b4bbb3b30dbc11d00d1ceed0cc7ccc7c54454544000000000588115005aaa85000000000000000004424424444444244cc7ccc1ccccccccc0000000000000000
4444b4440decc1d00d1bced0ccccc7cc454454540000000005bbba500591185000000000000000004444444444224444ccccc1cccc1ccccc0000000000000000
444444440decc1d00d1cbed0cccccccc445444440000000005e9ba500591c85000000000000000004444244444424444c1ccccccccccc1cc0000000000000000
444424440debb1d00d1cced0c7cccc7c444444140000000005e9ba500591c85000000000000000004244424442444242ccccc1cc1c1c111c0000000000000000
424244240d1111d00d1111d0c1c7c1cc414441440000000005eeba500591cc5000000000000000004424442422222222cc1c1ccc111111110000000000000000
00700000000007000070000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07770000000077700777000000007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0777eeeeeeee77700777eeeeeeee7770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
077e88888888e770077e88888888e770900a0a00000000000a0a0a000a0000000000000000000000000000000000000000000000000000000000000000000000
07e88e8888e88e7007e88e8888e88e700a90a0a9a0a00000a090a0a0a0a000000000000000000000000000000000000000000000000000000000000000000000
0e8888e88e8888e00e8888e88e8888e009a090a90a9000009a9aa9aa99a000000000000000000000000000000000000000000000000000000000000000000000
e888778ee877888ee888778ee877888e8aa8a8a898000000a9a98a98a99000000000000000000000000000000000000000000000000000000000000000000000
e88877888877888ee88877888877888ea8a8a8898a8000008a98a98a980000000000000000000000000000000000000000000000000000000000000000000000
e88877888877888ee88877888877888e889889889880000089888988989000000000000000000000000000000000000000000000000000000000000000000000
e88888888888888ee88888888888888e121212121210000012121212121000000000000000000000000000000000000000000000000000000000000000000000
e88887777778888ee88887777778888eccccccccc7700aa0ccccccccc7700aa00000000000000000000000000000000000000000000000000000000000000000
e88887888878888ee88887888878888eccccccccc77aaa9accccccccc77aaa9a0000000000000000000000000000000000000000000000000000000000000000
e88887777778888ee88887777778888ecccccccccccaaa9acccccccccccaaa9a0000000000000000000000000000000000000000000000000000000000000000
e88888888888888ee88888888888888eccccccccccc00aa0ccccccccccc00aa00000000000000000000000000000000000000000000000000000000000000000
eee8eee8eee8eeeeeeee8eee8eee8eee111111111110000011111111111000000000000000000000000000000000000000000000000000000000000000000000
e0eee0eee0eee0eeee0eee0eee0eee0ec0c0c00c00c000000c0c0c0c0c0000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000eeeeee0000000000eeeeee0000000000eeeeee0000000000eeeeee000000
0000000000000000000000000000000000000000000000000000000000000000000ec7ecc7e00000000ec7ecc7e00000000ec7ecc7e00000000ec7ecc7e00000
0000000000000000000000000000000000000000000000000000000000000000000e7ceccce00000000e7ceccce00000000e7ceccce00000000e7ceccce00000
00000000000000000000000000000000000000000000000000000000000000008eeeeeeeeeeeeeea8eeeeeeeeeeeeeea8eeeeeeeeeeeeeea8eeeeeeeeeeeeeea
0000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0000000000000000000000000000000000000000000000000000000000000000ddd51ddddddd15ddddd15ddddddd51ddddd51ddddddd15ddddd51ddddddd15dd
000000000000000000000000000000000000000000000000000000000000000000015000000051000005100000001500ccc15cc8cccc518ccc815cccccc851cc
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000098c88c8c8c8c88c898c8c88c8c8c88c9
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000089899c988ca9c80089acaca88c89c80
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099a9a8998aa90000a9a8989a89a800
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000999aaaa999000000a9aaa89a89000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa99a9a9000000009a99aa9a0000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a00a90000000000aa09aa00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000a0000a00000
f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2626262626262626262626262626262626262626262
62626262626262626262626262626262626262626262626262626262626262626262626262626262626262f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2626262626262626262626262626262626262626262
62626262626262626262626262626262626262626262626262626262626262626262626262626262626262f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2626262626262626262626262626262626262626262
626262626262626262626262626262626262626262626262626262626262626243f0626262626262626262f2f2f2e043f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2626262626262626262626262626262626262626262
6262626262626262626262626262626262626262626262626262626262626262e1f3f06262626262626262f2f2e0f3e1f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2626262626262626262626262626262626262626262
6262626262626262626262626262626262626262626262626262626262626262e1f3f3f062626262626262f2e0f3f3e1f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2e2e2e2e2e2e243f0e2e2e2e2e2e2e2e2e2626262e04362626262626262626262626262626262
6262626262626262626262626262626262626262626262626262626262626262e1c1c1f3f0626262626262e0f3c1c1e1f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f0f2f2f2f2f2f2f2f2f2f2f2f2f2f2e0f2f2f2f2f2f2f2f2f2f2e2e2e2e2e2e2e1e1e2e2e2e2e2e2e2e2e2626262e1e162626262626262626262626262626262
c1c1626262626262626262626262c1c162626262626262626262626262626262e16262c162626262626262f2c1f2f2e1f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
e1f2f2f2f2f2f2f2f2f2f2f2f2f2f2e1f2f2f2f2f2f2f2f2f2f2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2626262626262626262626262626262626262626262
6262626262626262626262626262626262626262626262626262626262626262e162626262626262626262f2f2f2f2e1f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
e143f0f3f3f3f3f3f3f3f3f3f3e043e1f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3626262626262626262626262626262626262626262
6262626262626262626262626262626262626262626262626262626262626262e162626262626262626262f2f2f2f2e1f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3c1f3c1f3c1f3f3e0f0f3f3c162c162c162626262626262626262626262626262
434343f06262e04343f06262e043434362626262626262626262626262626262e162626262626262626262f2f2f2f2e1f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f3f3f3f3f3e0c1c1c1c1f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3626262626262626262626262626262626262626262
62e1e162626262e1e162626262e1e16262626262626262626262626262626262e162626262626262626262f2f2f2f2e1f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f3f3f3f3f3f1f3f3f3f3f1f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3626262626262626262626262626262626262626262
6262626262626262626262626262626262626262626262626262626262626262e162626262626262626262f2f2f2f2e1f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
c1f3f3f3f3f3f3f3f3f3f3f3f3f3f3c1f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f343f0f3f3f3f3f3f3f3f3f3626262e04362626262626262626262626262626262
c1626262e04362626262e0f0626262c162626262626262626262626262626262e162626262626262626262f2f2f2f2e1f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f34343f3f3626262626262626262626262626262626262626262
f362626262626262626262626262626262626262626262626262626262626262e162626262626262626262f2f2f2f2e1f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f3f3f3f3f3f3f3e0f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e1e1f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f34343f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2e1f2f2f2f2f2f2f2f2f2f2f2f2f2f2e1f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
c1c1c1c1c1c1c1f1f1c1c1c1c1c1c1c1f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3c1c1c1c1c1c1c1f1f1c1c1c1c1c1c1c1f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
c1c1c1c1c1c1c1f1f1c1c1c1c1c1c1c1f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f1c1c1c1c1c1c1c1c1c1c1c1c1c1c1f1f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f2f2f2f3f3f3f2f2f2f3f3f3f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f2f2f2f3f3f3f3f2f3f3f3f3f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f2f2f3f3f3f2f3f3f3f3f3f3f2f3f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f3f3f3f3f2f2f2f2f3f3f3f3f2f2f3f3f3f3f2f2f2f2f2f2f2f2f2f2f2f2f200
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f3f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f3f3f2f2f2f2f2f2f2f2f2f2f2f2f200
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f2f2f3f3f3f3f3f3f3f2f3f3f3f2f2f3f3f2f2f2f2f2f2f2f2f2f2f2f2f2f200
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f2f3f3f3f3f2f2f3f3f3f3f3f3f2f2f3f2f2f2f2f2f2f2f2f2f2f2f2f2f2f200
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f3f2f3f3f3f2f2f3f2f2f3f3f3f2f3f3f2f2f2f2f2f2f2f2f2f2f2f2f2f2f200
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f3f2f3f3f3f3f3f3f2f2f3f3f3f3f3f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f200
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f2f2f3f3f3f3f2f3f2f3f3f3f2f3f3f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f200
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f2f2f2f2f2f3f3f3f2f3f3f2f2f3f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f200
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f2f2f2f2f2f2f3f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f200
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2e2e2e2e2f2f2f2f2f2f2f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2f2f2f2f2f2f2f2f2f2f2f2f2f2f200
__gff__
0101010101010101010000000000010100010000010101010100010101010101010000000101000001010101010100000101010101010000010101010101000101010101000000000000000000000000000000000000000000000000000000000000000000000000010101010101010100000000000000000000000000000000
0101010000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f000000000000000000000000000000002f2f2f2f2f2f2f2f2f2f2f2f002f2f2f00000000000000000000000000000000727272727272727272727272727272727272000000727272727272727272727272727272727272727272727272727272722f2f2f2f0000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f000000000000000000000000000000002f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000727272727272727272720072727272727200000000727272727272727272727272727272727272727272727272727272722f2f2f2f0000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2b2f2f2f2f2f2f2f2f2f2f2f2f2f2f2a2f2e2e2e2e2e2e2e7272727272727272727272727272727272727272727272727272727272727272727272727272727230302b727272727272727272722a3030722f2f2f2f0000000000000000000000
2b2f101010102f2f2f2f2f10102f102a2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f3a2f2f2f2f2f2f2f2f2f2f2f2f2f2f3a2f2e2e2e2e2e2e2e727272727272727272727272727272727272727272727272727272727272727272727272727272723a3a3f2b72727272727272722a3f3a3a722f2f2f2f0000000000000000000000
3a30302b2f2f2f2f2f2f2f2f2a30303a2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2b2f2f2f2f2f2f2f2f2f2f2f2f2a2f2f2e2e2e2e2e2e2e72727272727272723030302b72727272727272722a303030727272727272727272727272727272723a3a2b727272727272727272722a3a3a722f2f2f2f0000000000000000000000
2f2f2f2f2f2f2f2f2f26262f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f302b2f2f2f2f2f2f2f2f2a302f2f2f2e2e2e2e2e2e2e72727272727272723a3a3a3a2b7272727272722a3a3a3a3a727272727272727272727272727272723a3a72302b7272727272722a30723a3a722f2f2f2f2f00000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f3a2f2f2f2f2f2f2f2f3a2f2f2f2f2e2e2e2e2e2e2e72727272727272723a3a3a3a3a2b727272722a3a3a3a3a3a727272727272727272727272727272723a3a7272727272727272727272723a3a722f2f2f2f2f00000000000000000000
2f2f2f2f2a3030303030302b2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2e2e2e2e2e2e2e72727272727272723a3a3a3a3a7272727272723a3a3a3a3a727272727272727272727272727272723a3a7272727272727272727272723a3a722f2f2f2f0000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2e2e2e2e2e2e2e72727272727272723a3a3a3a72727272727272723a3a3a3a727272727272727272727272727272723a3a7272727272727272727272723a3a722f2f2f2f0000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2e2e2e2e2e2e2e72727272727272723a3a3a727272727272727272723a3a3a727272727272727272727272727272723a72727272727272727272727272723a722f2f2f2f2f00000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f1a1a1a1a1a1a1a1a1a1a2f2f2f2f2e2e2e2e2e2e2e727272727272727272727272727272727272727272727272727272727272727272727272727272723a72727272727272727272727272723a722f2f2f2f2f00000000000000000000
1a30302b2f2f2f2f2f2f2f2f2a3030302f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2e2e2e2e2e2e2e7272727272727272727272722a3030303030302b72727272727272727272727272727272727272723a72727272727272727272727272723a722f2f2f2f0000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f1a2f2f2f2f2f2f2f2f2f2f262626261a262626262626262626262626262626261a26262a3a3a3a3a3a3a3a3a2b26261a262626262626262626262626262626263a72727272727272727272727272723a722f2f2f2f0000000000000000000000
2e2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2a2b2f2f26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626263a72727272727272727272727272723a722f2f2f2f0000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f3a3a2f2f26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626263a72727272727272727272727272723a722f2f2f2f0000000000000000000000
1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f1a1a1a1a1a1a1a3b3b1a1a1a1a1a1a1a262626262626262626262626262626261a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a262626262626262626262626262626263a1a1a1a1a1a1a1a1a1a1a1a1a1a1a3a722f2f2f2f2f2f2f0000000000000000
222222222222222222222222222222222f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626267272727272722f2f2f2f2f2f2f0000000000000000
222f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626267272727272722f2f2f2f2f2f2f0000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262633333333332d262626262c3333333333722f2f2f2f2f2f2f0000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626263c3f3c26262626262626262f2f3c3f33722f2f2f2f2f2f2f0000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f332d2f2f2f2f2f2f2f2f2f2626262c332626262626262626262626262626262633332d262626262626262626262c3333262626262626262626262626262626263c3f3f2d262626262626262f2c3f3f33722f2f2f2f2f2f2f2f2f2f2f2f2f2f2f
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626263c332d26262626262626262f2f2c3333722f2f2f2f2f2f2f2f2f2f2f2f2f2f2f
332d2f2f2f2f2f2f2f2f2f2f2f2f2c332f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2c332f2f2f2f2c2d262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626263c262626262626262626262f2f2f2f3c722f2f2f2f2f2f2f2f2f2f2f2f2f2f2f
2f2f2f2f2f2f2c33332d2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626263c262626262626262626262f2f2f2f3c722f2f2f2f2f2f2f2f2f2f2f2f2f2f2f
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f26262626262626262626262626262626262626262626262626262c333333332d2626262626262626262626262626262626262626263c262626262626262626262f2f2f2f3c722f2f2f2f2f2f2f2f2f2f2f2f2f2f2f
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2c2d2f2f2c3333332f262c2d26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626263c262626262626262626262f2f2f2f3c722f2f2f2f2f2f2f2f2f2f2f2f2f2f2f
2f2f2f2c3333332f2f3333332d2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f3c2f2f3c2f26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626263c2d2626262626262626262f2f2f2c3c2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f3c2f2f3c2f262626262626262626262626262626262626262626333333332d261b26261b262c33333333262626262626262626262626262626263c3c2626262626262626262f2f2f3c3c2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f
2d2f2f2f2f2f2f2f2f2f2f2f2f2f2f2c2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2c2d2f2f2f2f2f2f2f2f2f2626262c332626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626263c3c2626262626262626262f2f2f3c3c2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f
2f2f2f2f2f2f2f33332f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f262626262626262626262626262626262626262626262626262c2d262626262c2d26262626262626262626262626262626262626263c3c2626262626262626262f2f2f3c3c2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f
2f2f2f2f2f2f2f3c3c2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f33332f2f26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626263c3c2626262626262626262f2f2f3c3c2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f
1b1b1b1b1b1b1b3d3d1b1b1b1b1b1b1b2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f1b1b1b1b1b1b1b3d3d1b1b1b1b1b1b1b262626262626262626262626262626261b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b262626262626262626262626262626263d3d1b1b1b1b1b1b1b1b1b1b1b1b3d3d2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f
__sfx__
000100000d0500d05018050180501a0501b0501f05023050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000012070080502163019630106300c63009630066300463001630096000560025600026001d6001960018600000000000000000000000000000000000000000000000000000000000000000000000000000
000100000f0700e0700e0700c07005070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002d030310303303033030310302e0302c050290501405013050110500e0500b05008050060500405003050000000000000000000000000000000000000000000000000000000000000000000000000000
00010000126401664023050200501a050150500d05008050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000013750157001675017700197501d700237502b7502f7503175028700217002d70033700397003f70000700007000070000700007000070000700007000070000700007000070000700007000070000700
0001000004730077300e7301474015740157400e73008730017000370002700257002070020700027000c40000000000000000000000000000000000000000000000000000000000000000000000000000000000
001600000706029600070501f60007040186000703001600070200a6000701006600070100160001600016000160001600016000160001600016000a100010000800001000010000100001000010000100001000
00070000016400164002650036400564007640096400d63012630176401b6501e64021650236602c6002d60002600026000460002600016001f600226002460025600276002a6002c6003060032600366003c600
010c00000c0630c000006650c0000c0630c000006650c0000c0630c063006650c0000c0630c000006650c0000c0630c000006650c0000c0630c000006650c0000c0630c063006650c0000c0630c063006650c000
010c00200c0630c6030c6650c0030c063006030c665180000c0630c0630c6650c6030c0630c6030c6650c6030c063126030c0630c0030c0630c0030c0630d0030c0630c0630c063000630c0630c0630c06300063
010c00201c3551c3051c3551a3051f3551c3051a3551a305233552330521355203051d355233051f3551f3051c355213051c3551f3051f355233051a3551f305233551a305213551a3051d355183051835518305
010c00201c4551a7051c4551a7051f3551c3551a3551a705235551a705215551a7051d4551c3551f4551a7051c355100501c355100501c355100501c35510050043510435110341103311c3311c3212831128311
010c00201075010700107501070013750107000e75010700177500e701157500e701117500e701137500e701107500e700107500e700137500e7000e7500e7001775011701157501170111750117010c75011701
010c00200945015450214402d4300943015420214102d41004450104501c4402843004430104201c4102841005450114301d4202941005450114301d42029410024500e4501a44026430024300e4201a41026410
010c002004450104501c4402843004430104201c41028410004500c4501844024430004300c42018410244100945015450214402d4300943015420214102d41007414134141f4242b43407434134441f4542b454
011a00000c063000000c665000000c0030000000000000000c063000000c665000000c003000000c6050c6650c063000000c66500000000000000000000000000c063000000c6650000000000000000000000000
011a000018050240001f000110000c0000e0001c0500c0001f050150001300011000130000e0001a0000c0001c0500e000100001100010000150001f0501f000180500e00010000110000c000150001500013000
011a00001a05000000000000000000000000001f0501f0001d050000000000000000000000000000000000001f05000000000000000000000000001c050000002105000000000000000000000000000000000000
010900000c0630c4050c063104050c6430c3050c063103050c06311502105020e5020c64311502105020e5020c0630c4050e405104050c6430c3050e305103050c0631300211002100020c643130020c64315002
010900000d0510d0511055211152111421113211122111120d0510d0511055211152111421113211122111120d0510d0511055211152131421113213122111120d0510d05110552105520c0150c1250c2350c445
0109000012041120411355215152151421513215122151121204112041135521515215142151321512215112120411204113552151520e142151320e122151121204112041135521355211015111251123511445
0109000000450004500445004450004500045002450024500c4200c42015430154300c4400c440114501145000450004500445004450004500045002450024500745007450004400044005430054300042000420
010900001833118331183311833118331183311733117331163311633116331163311633116331103311033117331173311733117331173311733118331183311033110331103311033110331103311733117331
010900001a3311a3411a3311a3411a3311a34110331103411e3311e3411e3311e3411e3311e341073310734115331173311533117331213312333121331233310c3560c3560e3560e35611340283010e3200c301
010e00000005300200006650000000053000000065500000000530000000655000000000300053006550000000053000000065500053000530000000655000000005300000006550000000053000000065500053
010e00000c3550e3550c3550e355113051130511305113050c3550e3550c3550e355103051030510305103050c3550e3550c3550e355133051330513305133050c3550e355183552635515305153051530515305
010e0000103551335510355133551130511305113051130510355133551035513355103051030510305103051035513355103551335513305133051330513305343552b3551c3551335515305153051530515305
010e0000000040000400004000041135411354113541135400004000040000400004103541035410354103540000400004000040000413354133541335413354000040000400004000042d354213541535415354
010e00000000400004000040000417354173541735417354000040000400004000041a3541a3541a3541a35400004000040000400004103541c35428354343540000400004000040000405355113550535511355
010c00000c0630c000006650c0000c0630c000006650c0000c0630c003006650c0000c0630c000006650c0000c0630c000006650c0000c0630c000006650c0000c0630c00300665006050c06300605006650c063
010c00000d255002050f2550020514255002051225500205162550020512255002050f2550020512255002050d255002050f2550020514255002051225500205162550020512255002050f255002051225500205
010c00000d2450d2450d2450d2450d2450d2450d2450d24516245162451624516245162451624516245162450f2450f2450f2450f2450f2450f2450f2450f2451224512245122451224512245122451224512245
010c00000d2410d2410d2410d2410d2410d2410d2410d24116242162421624216242162421624216242162420f2410f2410f2410f2410f2410f2410f2410f2411224212242122421224212242122421224212242
010c000022202120021600212002160021200216002120021e2020d0020f0020d0020f0020d0020f0020d0021b2020000200002000020000200002160021600222241202411e2411b24119241162411424112241
01140000112020c2021020211202112020e2020e20211202112020020210202002020e202002020c202002020e202002021120200202132020020210202002021020200202132020020215202002021020200202
0114000018601186010c6010c6010c6010c6010c6010c60118601186011860118601246011860118601186010c6010c6010c6010c6010c6010c6010c6010c6012460124601186010c601186010c601186010c601
011400000c0030c0000c0030c000006050c000006050c0000c0030c000006050c003006050c000006050c0000c0030c000006050c000006050c000006050c0030c0030c000006050c000006050c000006050c000
011400001d0011d0011d0011d0011d0011d0011d0011d0011d0011d0011d0011d0011d0011d0011d0011d0011a0011a0011a0011a0011a0011a0011a0011a0011c0011c0011c0011c0011c0011c0011c0011c001
010c00000007300003006750000000073000000067500000000730007300675000000007300003006750000000073000000067500003000730060500675000000007300003006750000000073000030067500073
010c000003442084420344206442014420344208442064420344208442034420644201442034420a4420144203442084420344206442014420344208442014420344208442034420644201442034420a44206442
010c000022462214621e4621d462204621f46219462184621e4621d46219462184621b4621a46219462184621646215462124621146214462134620d4620c4620646205462014620046203462024620146200462
010c00002e4412e4412e4412e4412e4412e4412e4412e44127441274412744127441274412744127441274412a4412a4412a4412a4412a4412a4412a4412a4412c4402c4001e4402a4000f4402c4000144025400
010c000016275162052227516205162751620522275162050f2750f2051b2750f2050f2750f2051b2750f20512275122051e2751220512275122051e275122052c275142051e275122050f275142050127525205
010c00000007300003006050000000073000000060500000000730000300605000000007300003006050000000073000000007300003000730060500073000000007300003000730000000073000730007300073
010c0000014412e4012e4012e401014412e4012e4012e4010144127401274012740101441274012740127401014412a4012a4012a401014412a4012a4012a40101441012710f4410f2711e4411e2712c4412c271
010c00000007300003006050000000073000000060500000000730000300605000000007300003006050000000073000000000300003000730060500003000000007300003000030000000073000030000300003
010c00002a4412a4412a4412a4412a4412a4412a4412a4412c4412c4412c4412c4412c4412c4412c4412c44125441254412544125441254412544125441254412544020470194401b47012440144700144003470
010c0000122751220512275122051227512205122751220514275142051427514205142751420514275142050d2750d2050d2750d2050d2750d2050d2750d2052527520205192751b20512275142050127503205
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000637006370063700000006370063700637003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000013070130700f0700b06008060040600106001060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 09 0b 0d 44
00 09 0b 0d 44
00 09 0b 0d 44
00 0a 0c 0d 44
01 09 0b 0d 0e
00 09 0b 0d 0e
00 09 0b 0d 0e
00 09 0b 0d 0f
00 09 0b 0d 0e
00 09 0b 0d 0e
00 09 0b 0d 0e
02 0a 0b 0d 0f
01 10 11 43 44
00 10 11 43 44
00 10 11 43 44
02 10 12 43 44
03 25 42 43 44
01 13 16 43 44
00 13 16 43 44
00 13 16 43 44
00 13 16 43 44
00 13 16 17 44
00 13 16 17 44
00 13 16 17 44
02 13 16 18 44
01 19 1a 1c 44
00 19 1a 1c 44
00 19 1a 1c 44
02 19 1b 1d 44
01 1e 1f 43 44
00 1e 1f 43 44
00 1e 1f 43 44
00 1e 1f 22 44
00 1e 1f 21 44
00 1e 1f 21 44
00 1e 1f 21 44
00 1e 1f 21 44
00 1e 1f 20 44
00 1e 1f 20 44
00 1e 1f 20 44
02 1e 1f 20 44
01 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
02 41 42 43 44
00 41 42 43 44
00 29 42 43 44
00 2e 28 43 44
00 2c 28 2d 44
01 27 28 2a 2b
00 27 28 2a 2b
00 27 28 2a 2b
00 27 28 2a 2b
00 27 28 2f 30
00 27 28 2f 30
00 27 28 2f 30
02 27 28 2f 30
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
