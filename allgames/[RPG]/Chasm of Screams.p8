pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--init

--chasm of screams
--by raptorbandit
--current version: 1.1 2020/07/21
--previous versions: 1.0 2020/06/30

--special thanks for tutorials/code snippets

--youtube tutorials
--doc_robs
--krystman/lazy devs academy

--from the pico-8 forums
--bab_b
--cow
--dragonxvi
--morningtoast
--komeybomb: fade in code 

tick=0
t=0
level=1
kills=0
dirx={-1,1,0,0,1,1,-1,-1}
diry={0,0,-1,1,-1,1,1,-1}

log={
	{0,"status: awakened from stasis"},
	{0,"objective: infiltrate level 7"},
}
 
stairs={
 x=12,
 y=30,
 sym=">",
 hitboxx=0,
 hitboxy=0,
 hitboxw=6,
 hitboxh=6,
 seen=false
}
 
items={}
enemy={}
room={}
tunnelns={}
tunnelew={}
wall={}
door={}
fdn={}
rain={}
levels={"the old docks", "the rigs", "the colony access", "the arcology solarium", "the vertical farm", "subspace b7r", "the chasm of screams"}
	
sash={
 on=false,
 t=0,
 x1=0,
 x2=-20
}

--text placement
upper={20,26,32,38}
lower={80,86,92,98}

dsash={
 on=false,
 x1=0,
 x2=-20,
 x3=-40,
 x4=-60,
 txtx=4,
 txty=upper
}

function _init()
		mode="title"
		create_player()
end

function create_player()
player = {
	x = 0,
	y = 0,
	sym="@",
	col=12,
	hitboxx=0,
	hitboxy=0,
	hitboxw=6,
	hitboxh=6,
 ws = 3, --weapon skill, chance to hit in melee
 bs = 3, --ballistic skill, chance to hit with ranged weapons
	wounds = 5,
	woundsmax=5,
	melee={
		fullname="knife",
		name="knife",
		damage=1,
		sym=","
		},
	gun={
		name = "side-arm",
		damage= 1,
		ammo = 4,
		ammomax = 9,
		sym=";"
		},
	}

aim={
	x=player.x-2,
	y=player.y,
	sym="[]",
	col=12,
	hitboxx=4,
	hitboxy=4,
	hitboxw=4,
	hitboxh=1
}
end

function _update()
	
	t=t+1
	
	if t==61 then t=0 end
	
	if (t%30<15) then
		textflashcol="7"
	else
		textflashcol="11"
	end
	
	if sash.on==true then
		sash.t+=1
		sash.x1+=3
		sash.x2+=3
	end
	if sash.t==120 then
		sash.on=false
		sash.x1=0
		sash.x2=-20
		sash.t=0
	end
	
	if dsash.on==true then
		dsash.x1+=3
		dsash.x2+=3
		dsash.x3+=3
		dsash.x4+=3
	end
	if	dsash.on==false then
		dsash.x1=0
		dsash.x2=-20
		dsash.x3=-40
		dsash.x4=-60
 end

	for i in all(items) do	
		i:attract()
	end
	
	for n in all(fdn) do
		n.y-=rnd(1)
		n.x+=rnd(1)
		n.t+=1
			if n.t == 15 then
				del(fdn,n)
			end
	end
	
	for r in all(rain) do
		r.x += r.dx
		r.y += r.dy
		if r.x>=128 or r.y>=128 then
			del(rain,r)
			createrain()
		end
	end
	
	if mode=="title" then 
		if btnp(5) then
		create_level()
		mode="game"
		end
	end
	if mode=="game" then updategame() end
	if mode=="aim" then updateaim() end
	if mode=="gameover" then updategameover() end
	if mode=="victory" then updatevictory() end
	if mode=="logmenu" then
		if btnp(5) then mode="game"
		end
	end

 if level==1 or level==2 then
 	sfx(2)
 end
end

function createrain()
	add(rain,{
		x=rnd(200)-100,
		y=-rnd(32),
		dx=1,
		dy=1
	})
end
-->8
--update and player

function updategame()
	
	buttpress=false
	local lx = player.x --last x
	local ly = player.y --last y
	
	if(btnp(0)) then 
		player.x-=6
		buttpress=true
	elseif(btnp(1)) then 
		player.x+=6 
		buttpress=true
	elseif(btnp(2)) then 
		player.y-=6	
		buttpress=true
	elseif(btnp(3)) then 
		player.y+=6 
		buttpress=true
	elseif(btnp(4)) and player.gun.ammo > 0 then 
		resetaim() 
		mode="aim" 
	elseif(btnp(4)) and player.gun.ammo == 0 then 
		add(log,{tick,"out of ammo!"})
		sfx(11)	
	end
	
	for e in all(enemy) do
		if collide(player,e) then
		player.x=lx
		player.y=ly
		pbumpattack(e)
		end
	end
	
	for w in all(wall) do
		if collide(player,w) then 
			player.x=lx
			player.y=ly
			add(log,{tick,"it's a wall."})
		end
		if fov(w) then w.seen=true end
	end
	
	for d in all(door) do
		if collide(player,d) then
		sfx(7)
		player.x=lx
		player.y=ly
		add(log,{tick,"you open the door."})	
		del(door,d)
		end
	end
	
	for i in all(items) do
		if collide(player,i) then
			if log[#(log)][2] == "there's a "..i.name.." here." then
			else
			add(log,{tick,"there's a "..i.name.." here."})
			end
			i:effect()
		end
	end
	
	if fov(stairs) then stairs.seen=true end
	
	if collide(player,stairs) then
		if log[#(log)][2] == "there are stairs here." then
		else
			add(log,{tick,"there are stairs here."})
		end
		if btnp(5) then
			if level==7 then
				mode="victory"
			else
				level+=1
				cleanup()
				create_level()
				mode="game"
			end
		end
	end
	
	if buttpress==true then 
		sfx(1)
		tick+=1
		enemyupdate() 
		buttpress=false
	end
playerdeath()
end

function updateaim()
	
	aim.col=12
	local lx = aim.x
	local ly = aim.y

	if(btnp(0)) then aim.x-=6
		elseif(btnp(1)) then aim.x+=6
		elseif(btnp(2)) then aim.y-=6
		elseif(btnp(3)) then aim.y+=6
		elseif(btnp(5)) then mode="game"
	end
	
	for w in all(wall) do
		if collide (aim,w) then
		aim.x=lx
		aim.y=ly
		end
	end
	
	for d in all(door) do
		if collide (aim,d) then
		aim.x=lx
		aim.y=ly
		end
	end
	
	for e in all(enemy) do
		if collide(aim,e) then
			if fov(e) then aim.col=8
			if (btnp(4)) then
				rangedattack(e) 
			end			
			end
		end
	end
end

function resetaim()
	aim.col=12
	aim.x=player.x-2
	aim.y=player.y
end

function playerdeath()
	if player.wounds<1 then
		add(log,{tick,"you have been consumed."})
		mode="gameover"
		sfx(9,-2)
		sfx(10,-2)
		sfx(12,-2)
		end
end

function pbumpattack(target)
 proll = roll(6)
 eroll = roll(6)
 
	if proll >= player.ws then
		add(log,{tick,"you hit "..target.name.." for "..player.melee.damage.." damage!"})
		target.wounds-=player.melee.damage
		add(fdn,{x=target.x,y=target.y,d="-"..player.melee.damage,t=0,col=7})
		enemydeath()
		sfx(4)
	else
		sfx(3)
		add(log,{tick,"you miss the "..target.name.."!"})
	end
	
	if enemydeath == true then
		if eroll >= target.ws then
			player.wounds-=target.damage
			add(log,{tick,""..target.name.." hit you for "..target.damage.." damage!"})
			add(fdn,{x=player.x,y=player.y,d="-"..target.damage,t=0,col=8})
		else
			sfx(3)
			//going to remove this
			//for now because the log
			//is pretty cluttered already
			//add(log,{tick,""..target.name.." missed!"})
		end
	end
end

function ebumpattack(target)
 eroll = roll(6)
	
	if eroll >= target.ws then
		player.wounds-=target.damage
		add(log,{tick,""..target.name.." hit you for "..target.damage.." damage!"})
		add(fdn,{x=player.x,y=player.y,d="-"..target.damage,t=0,col=8})
	else
		sfx(3)
		add(log,{tick,""..target.name.." missed!"})
	end
end

function rangedattack(target)
	rroll = roll(6)
	player.gun.ammo-=1
	if rroll >= player.bs then
		target.wounds-=player.gun.damage
 	add(log,{tick,"you shoot "..target.name.." for "..player.gun.damage.." damage!"})
		add(fdn,{x=target.x,y=target.y,d="-"..player.gun.damage,t=0,col=7})
		sfx(6)
	elseif rroll < player.bs then
		add(log,{tick,"you miss the "..target.name.."!"})
				add(fdn,{x=target.x,y=target.y,d="miss!",t=0,col=7})
		sfx(3)
	end
	resetaim()
	enemydeath()
	enemyupdate()
	mode="game"
end

function resetgame()
	create_player()
	kills=0
	tick=0
	level=1
	cleanup()
	create_level()
	mode="game"
	dsash.on=false	
end

function updatevictory()
	dsash.on=true
		if btnp(4) then
		resetgame()
	end
end

function updategameover()
	player.col=8
	dsash.on=true
	if btnp(5) then
		resetgame()
	end
end
-->8
--draw
function _draw()
	cls()

	--player area
 --rect(0,12,126,114,15)
 
 --possible room areas
 --rect(0,12,60,60,14) --quad 1
 --rect(66,12,126,60,13) --quad 2
 --rect(0,66,60,114,12) --quad 3
 --rect(66,66,126,114,11) --quad 4
 
 for w in all(wall) do
 	if fov(w) then
		print(w.sym,w.x,w.y,6)
	end
	if not fov(w) and w.seen==true then
		print(w.sym,w.x,w.y,5)
	end
end
	
	for d in all(door) do
		if fov(d) then
			print(d.sym,d.x,d.y,10)
		end
	end
	
	if fov(stairs) then
		print(stairs.sym,stairs.x,stairs.y,10)
	end
	if not fov(stairs) and stairs.seen==true then
		print (stairs.sym,stairs.x,stairs.y,5)
	end
	
	for i in all(items) do
		if (fov(i)) print(i.sym,i.x,i.y,i.col)
	end
	
	for e in all(enemy) do
		if fov(e) then
			print(e.sym,e.x,e.y,e.col)
		end
	end
	
	print(player.sym,player.x,player.y,player.col)
	
	for r in all(rain) do
		line(r.x,r.y,r.x+2,r.y+2,1)
	end
	
	for n in all(fdn) do
 	print(n.d,n.x,n.y,n.col)
 end
	
	--top console
	rectfill(0,10,127,0,1)
	print(log[#(log)-1][2],0,0,6)
	print(log[#(log)][2],0,6,7)
	
	--debug
	--print(tt,0,12,8)
	--print(player.y,18,8)
	--print(eroll,0,24,8)
	
	--bottom console
	rectfill(0,117,127,127,1)
	print("eqpt: "..player.melee.name..",",0,117,7) 
	print("‡",0,123,8)
	print(":"..player.wounds.."/"..player.woundsmax,6,123,woundscolour)
	print(player.gun.name.." "..player.gun.ammo.."/"..player.gun.ammomax,63,117,ammocolour)
	print("z=aim x=interact",63,123,7)
	
	if player.wounds>player.woundsmax/2 then
		woundscolour=7
		if (t%60>30) then
		print("~",2,123,11)
		end
	else
		woundscolour=7
		if (t%30<15) then	
		print("~",2,123,9)
		woundscolour=8
		end
	end
	
	if player.gun.ammo > 0 then
		ammocolour=7
	else ammocolour=8
	end
	
	if mode=="title" then
	cls(0)
	print("welcome to the chasm of screams",dsash.txtx,dsash.txty[1],11)
	print("press x to begin",dsash.txtx,dsash.txty[4],textflashcol)
end
	
	if sash.on==true then
		oprint8("level "..level,4,54,11,0)
		oprint8("entering "..levels[level],4,60,11,0)
		rectfill(sash.x1,54,127,59,0)
		rectfill(sash.x2,60,127,65,0)
	end
	
	if dsash.on==true then
		if player.y<64 then
			dsash.txty=lower
		else
			dsash.txty=upper
		end
		rectfill(dsash.txtx,dsash.txty[1]-1,127,dsash.txty[4]+5,0)
		if mode=="victory" then
			print("status: objective complete ",dsash.txtx,dsash.txty[1],textflashcol)
			print("press z to restart",dsash.txtx,dsash.txty[4],textflashcol)
		else
			print("status report: objective failed ",dsash.txtx,dsash.txty[1],11)
			print("press x to restart",dsash.txtx,dsash.txty[4],textflashcol)
		end
		print("level "..level..": "..levels[level],dsash.txtx,dsash.txty[2],11)
		print("steps: "..tick.." kills: "..kills,dsash.txtx,dsash.txty[3],11)
		rectfill(dsash.x1,dsash.txty[1],127,dsash.txty[1]+5,0)
		rectfill(dsash.x2,dsash.txty[2],127,dsash.txty[2]+5,0)
		rectfill(dsash.x3,dsash.txty[3],127,dsash.txty[3]+5,0)
		rectfill(dsash.x4,dsash.txty[4],127,dsash.txty[4]+5,0)
	end
	
	if mode=="aim" then
		rectfill(63,123,127,127,1)
		print(aim.sym,aim.x,aim.y,aim.col) 
		print("z=shoot x=cancel",63,123,7)
	end
	
	if mode=="logmenu" then
		cls(0)
		local l=0
		for i=#log,1,-1 do
			print(i.."."..log[i][2],0,l,11)
		l+=6
		end
		rectfill(59,121,127,127,1)
		print("x=return to game",60,122,7)
	end
end

function logmenu()
	mode="logmenu"
end

menuitem(1,"log",logmenu)
-->8
--levelgen
function create_level()
	if level>=3 then sfx(9) end
	if level>=5 then sfx(9,-2) sfx(10) end
	if level==7 then sfx(10,-2) sfx(12) end
	sash.on=true
	mapgen()
	roomrender()
	tunnelrenderew()
	tunnelrenderns()
	digtunnel(wall)
end

function cleanup()
	add(log,{tick,"you descend to level "..level.."."})
	for r in all(room) do del(room,r) end
	for t in all(tunnelns) do del(tunnelns,t) end
	for t in all(tunnelew) do del(tunnelew,t) end
	for w in all(wall) do del(wall,w) end
	for d in all(door) do del(door,d) end
	for i in all(items) do del(items,i) end
	for e in all(enemy) do del(enemy,e) end	
	if level>2 then
		for r in all(rain) do del(rain,r) end
	end
	stairs.seen=false
end

function mapgen()
	
	--tile = 6x6 pixels
--player area = 17 x 21 tiles
--or: 0,11, 127, 116
--			x0, y0, x1,  y1

--in tiles of 6x6 pixels
--map_width=21 
--map_height=17

	--minrsizex=5
	--minrsizey=5
	--maxrsizex=10
	--maxrsizey=8
	
	--maxrooms=4

	--possible room locations
		quad1={
		x0=0,
		y0=12,
		x1=60,
		y1=60
		}
		
		quad2={
		x0=66,
		y0=12,
		x1=126,
		y1=60
		}
	
		quad3={
		x0=0,
		y0=66,
		x1=60,
		y1=114
		}
		
		quad4={
		x0=66,
		y0=66,
		x1=126,
		y1=114
		}
		
--level 1 docks
	if level==1 then
		
		for i=1,32 do
			createrain()
		end

		add(room,{
			x0=quad1.x0,
			y0=quad1.y0,
			x1=quad1.x0+(flr(rnd(5))+5)*6,
			y1=quad1.y0+(flr(rnd(5))+3)*6
		})
	
		add(room,{
			x0=quad2.x0,
			y0=quad2.y0,
			x1=quad2.x0+(flr(rnd(5))+5)*6,
			y1=quad2.y0+(flr(rnd(5))+3)*6
		})
	
		add(room,{
			x0=quad3.x0,
			y0=quad3.y0,
			x1=quad3.x0+(flr(rnd(5))+5)*6,
			y1=quad3.y0+(flr(rnd(5))+3)*6
		})
	
		add(room,{
			x0=quad4.x0,
			y0=quad4.y0,
			x1=quad4.x0+(flr(rnd(5))+5)*6,
			y1=quad4.y0+(flr(rnd(5))+3)*6
		})
	
		add(tunnelew,{
			x0=room[1].x1,
			y0=(room[1].y1+room[1].y0)/2,
			x1=room[2].x0,
			y1=(room[2].y1+room[2].y0)/2
		})
	
		add(tunnelew,{
			x0=room[3].x1,
			y0=(room[3].y1+room[3].y0)/2,
			x1=room[4].x0,
			y1=(room[4].y1+room[4].y0)/2
		})
	
		add(tunnelns,{
			x0=(room[1].x1+room[1].x0)/2,
			y0=room[1].y1,
			x1=(room[3].x1+room[3].x0)/2,
			y1=room[3].y0
		})
	
		add(tunnelns,{
			x0=(room[2].x1+room[2].x0)/2,
			y0=room[2].y1,
			x1=(room[4].x1+room[4].x0)/2,
			y1=room[4].y0
		})
		
		for i=1,6 do
			egen(roll(3)+1,1)
		end
		
		pplace(1)
		splace(4)
	
	end
	
--level 2 rigs
	if level==2 then
		
		add(room,{
			x0=quad1.x0,
			y0=quad1.y0,
			x1=quad1.x0+(flr(rnd(5))+5)*6,
			y1=quad1.y0+(flr(rnd(5))+3)*6
		})
	
		add(room,{
			x0=quad2.x0,
			y0=quad2.y0,
			x1=quad2.x0+(flr(rnd(5))+5)*6,
			y1=quad2.y0+(flr(rnd(5))+3)*6
		})
	
		add(room,{
			x0=quad3.x0,
			y0=quad3.y0,
			x1=quad3.x0+(flr(rnd(5))+5)*6,
			y1=quad3.y0+(flr(rnd(5))+3)*6
		})
	
		add(room,{
			x0=quad4.x0,
			y0=quad4.y0,
			x1=quad4.x0+(flr(rnd(5))+5)*6,
			y1=quad4.y0+(flr(rnd(5))+3)*6
		})
	
		add(tunnelew,{
			x0=room[1].x1,
			y0=(room[1].y1+room[1].y0)/2,
			x1=room[2].x0,
			y1=(room[2].y1+room[2].y0)/2
		})
	
		add(tunnelew,{
			x0=room[3].x1,
			y0=(room[3].y1+room[3].y0)/2,
			x1=room[4].x0,
			y1=(room[4].y1+room[4].y0)/2
		})
	
		local l2roll=roll(2)
		if l2roll==1 then
 		add(tunnelns,{
 			x0=(room[1].x1+room[1].x0)/2,
 			y0=room[1].y1,
 			x1=(room[3].x1+room[3].x0)/2,
 			y1=room[3].y0
 		})
		else
 		add(tunnelns,{
 			x0=(room[2].x1+room[2].x0)/2,
 			y0=room[2].y1,
 			x1=(room[4].x1+room[4].x0)/2,
 			y1=room[4].y0
 		})
		end
	
		for i=1,8 do
			egen(roll(4),1)
		end
		
	pplace(4)
	splace(1)
	
	end
	
--level 3 access
	if level==3 then
		add(room,{
			x0=quad1.x0,
			y0=quad1.y0,
			x1=quad1.x0+18,
			y1=quad1.y0+18
		})
	
		add(room,{
			x0=quad2.x1-24,
			y0=quad2.y0,
			x1=quad2.x1-6,
			y1=quad2.y0+18
		})
	
		add(room,{
			x0=quad3.x0,
			y0=quad3.y1-24,
			x1=quad3.x0+18,
			y1=quad3.y1-6
		})
	
		add(room,{
			x0=quad4.x1-24,
			y0=quad4.y1-24,
			x1=quad4.x1-6,
			y1=quad4.y1-6
		})
	
		add(tunnelew,{
			x0=room[1].x1,
			y0=(room[1].y1+room[1].y0)/2,
			x1=room[2].x0,
			y1=(room[2].y1+room[2].y0)/2
		})
	
		add(tunnelew,{
			x0=room[3].x1,
			y0=(room[3].y1+room[3].y0)/2,
			x1=room[4].x0,
			y1=(room[4].y1+room[4].y0)/2
		})
	
		add(tunnelns,{
			x0=(room[2].x1+room[2].x0)/2,
			y0=room[2].y1,
			x1=(room[4].x1+room[4].x0)/2,
			y1=room[4].y0
		})
		
	for i=2,4 do
		egen(i,1)
	end
	create_enemy(30,18,2)
	egen(3,2)
		
	pplace(1)
	splace(3)
	
	end

--level 4 arcology
	if level==4 then
		add(room,{
			x0=quad1.x0,
			y0=quad1.y0,
			x1=quad4.x1-6,
			y1=quad4.y1-6
		})
	
		add(room,{
			x0=quad1.x0+18,
			y0=quad1.y0+18,
			x1=quad1.x1-6,
			y1=quad1.y1-6
		})
		
		add(room,{
			x0=quad2.x0+18,
			y0=quad2.y0+12,
			x1=quad2.x1-18,
			y1=quad2.y1-6
		})
		
		add(room,{
			x0=quad3.x0+18,
			y0=quad3.y0+18,
			x1=quad3.x1-6,
			y1=quad3.y1-18
		})
		
		add(room,{
			x0=quad4.x0+18,
			y0=quad4.y0,
			x1=quad4.x1-24,
			y1=quad4.y1-18
		})
		
	create_enemy(54,60,1)
	create_enemy(18,78,1)
	create_enemy(42,72,1)
	create_enemy(78,96,2)
	create_enemy(60,102,2)
	create_enemy(114,96,2)
	create_enemy(114,18,1)
	create_enemy(30,66,1)
	create_enemy(6,102,1)
	
	player.x=6
	player.y=18
	stairs.x=114
	stairs.y=102
	end
	
	
--level 5 farm
	if level == 5 then
		add(room,{
			x0=quad1.x0,
			y0=quad1.y0,
			x1=quad3.x1-24,
			y1=quad3.y1-6
		})
		
		add(room,{
			x0=quad2.x0+18,
			y0=quad2.y0,
			x1=quad4.x1-6,
			y1=quad4.y1-6
		})
		
		add(tunnelew,{
			x0=room[1].x1,
			--y0=(room[1].y1+room[1].y0)/2,
			y0=108,
			x1=room[2].x0,
			--y1=(room[2].y1+room[2].y0)/2
			y1=114
		})
		for i=1,8 do
			egen(roll(2),roll(2))
		end
		pplace(1)
		splace(2)
	end
	
--level 6 subspace
	if level==6 then
		add(room,{
			x0=quad1.x0,
			y0=quad1.y0,
			x1=quad1.x1,
			y1=quad1.y1
		})
	
		add(room,{
			x0=quad2.x0,
			y0=quad2.y0,
			x1=quad2.x1,
			y1=quad2.y1
		})
	
		add(room,{
			x0=quad3.x0,
			y0=quad3.y0,
			x1=quad3.x1,
			y1=quad3.y1
		})
	
		add(room,{
			x0=quad4.x0,
			y0=quad4.y0,
			x1=quad4.x1,
			y1=quad4.y1
		})
		
		add(tunnelew,{
			x0=room[1].x1,
			y0=(room[1].y1+room[1].y0)/2,
			x1=room[2].x0,
			y1=(room[2].y1+room[2].y0)/2
		})
	
		add(tunnelew,{
			x0=room[3].x1,
			y0=(room[3].y1+room[3].y0)/2,
			x1=room[4].x0,
			y1=(room[4].y1+room[4].y0)/2
		})
	
		add(tunnelns,{
			x0=(room[1].x1+room[1].x0)/2,
			y0=room[1].y1,
			x1=(room[3].x1+room[3].x0)/2,
			y1=room[3].y0
		})
	
		add(tunnelns,{
			x0=(room[2].x1+room[2].x0)/2,
			y0=room[2].y1,
			x1=(room[4].x1+room[4].x0)/2,
			y1=room[4].y0
		})
		
		for i=1,10 do
			egen(roll(4),roll(2))
		end
		egen(2,4)
		pplace(3)
		splace(2)
	end
	
--level 7 chasm
	if level==7 then
		add(room,{
			x0=quad1.x0-6,
			y0=quad1.y0-6,
			x1=quad4.x1,
			y1=quad4.y1
		})
		pplace(1)
		stairs.x=114
		stairs.y=102
	 create_enemy(60,60,1)
	 create_enemy(18,90,1)
	 create_enemy(84,18,1)
	 create_enemy(36,36,1)
	 create_enemy(96,102,3)
	 create_enemy(114,84,4)	
	end
end
	
function egen(r,typ)

	local rndx=room[r].x0+flr(rnd(8))*6
	local rndy=room[r].y0+flr(rnd(8))*6
	
	local ex=mid(room[r].x0+6,rndx,room[r].x1-6)
	local ey=mid(room[r].y0+6,rndy,room[r].y1-6)

	create_enemy(ex,ey,typ)

end

function pplace(r)

	local rndx=room[r].x0+flr(rnd(8))*6
	local rndy=room[r].y0+flr(rnd(8))*6
	
	local x=mid(room[r].x0+6,rndx,room[r].x1-6)
	local y=mid(room[r].y0+6,rndy,room[r].y1-6)
	
	player.x=x
	player.y=y
	
end

function splace(r)

	local rndx=room[r].x0+flr(rnd(8))*6
	local rndy=room[r].y0+flr(rnd(8))*6
	
	local x=mid(room[r].x0+6,rndx,room[r].x1-6)
	local y=mid(room[r].y0+6,rndy,room[r].y1-6)
	
	stairs.x=x
	stairs.y=y
	
end

function roomrender()

 for r in all(room) do
		local j=0
		local k=6
		local l=0
		local o=6
	 local north=flr(r.x1-r.x0)/6
		local west=flr(r.y1-r.y0)/6
		local south=flr(r.x1-r.x0)/6
		local east=flr(r.y1-r.y0)/6
		
			for i=0,north do
	 		create_wall(r.x0+j,r.y0)
				j+=6
			end
			for i=2,west do
	 		create_wall(r.x0,r.y0+k)
				k+=6
			end
			for i=0,south do
	 		create_wall(r.x0+l,r.y1)
				l+=6
			end
		 for i=2,east do
	 		create_wall(r.x1,r.y0+o)
				o+=6
			end
	end
end

function tunnelrenderew()

 for t in all(tunnelew) do
		
		local j=6
		local k=6
		local l=6
		local o=6
		
		local mod1=t.y0%6
		local mod2=t.y1%6
		
		if mod1==3 then t.y0+=3 end
		if mod2==3 then t.y1+=3 end
		
		if (t.y0 <= t.y1) then 
			t.y1=(t.y0-12)
			k-=12
			o-=12
		elseif (t.y0 >= t.y1) then 
			t.y0=(t.y1-12) 
		end
		
	 local north=flr(t.x1-t.x0)/6
		--local west=flr(t.y1-t.y0)/6
		local south=flr(t.x1-t.x0)/6
		--local east=flr(t.y1-t.y0)/6
		
		for i=2,north do
	 	create_wall(t.x0+j,t.y0)
			j+=6
		end
		
		--west
	 	create_wall(t.x0,t.y0+k)
		
		for i=2,south do
			create_wall(t.x0+l,t.y1)
			l+=6
		end
 	
 	--east
	 	create_wall(t.x1,t.y0+o)
	
	end
end

function tunnelrenderns()

 for u in all(tunnelns) do
		
		local j=6
		local k=6
		local l=6
		local o=6
		
		local mod1=u.x0%6
		local mod2=u.x1%6
		
		if mod1==3 then u.x0+=3 end
		if mod2==3 then u.x1+=3 end
		
		if (u.x0 <= u.x1) then 
			u.x1=(u.x0-12)
			j-=12
			l-=12
		elseif (u.x0 >= u.x1) then 
			u.x0=(u.x1-12) 
		end
		
		local west=flr(u.y1-u.y0)/6
		local east=flr(u.y1-u.y0)/6
		
			--north	
	 	create_wall(u.x0+j,u.y0)
			
			for i=2,west do
	 		create_wall(u.x0,u.y0+k)
				k+=6
			end
			
			--south
	 	create_wall(u.x0+l,u.y1)
		 
		 for i=2,east do
	 		create_wall(u.x1,u.y0+o)
				o+=6
			end
	end
end

function create_wall(ox,oy)
add(wall, {
	 			x = ox,
					y = oy,
					sym="#",
					hitboxx=0,
					hitboxy=0,
					hitboxw=6,
					hitboxh=6,
					seen=false
				})
end

function digtunnel(outer_table)
	local duplicates={}
	
	for m=1,#outer_table-1 do
		for n=m+1,#outer_table do
			local duplicate = true
			for key, value in pairs(outer_table[m]) do
				if (value ~= outer_table[n][key]) duplicate = false
			end
			if (duplicate) then
				outer_table[n].sym="door"
				add(duplicates, outer_table[m])
			end
		end
	end		

	for t in all(duplicates) do
		del(outer_table, t)
	end

	for w in all(wall) do
		if w.sym=="door" then
		add(door,{x=w.x,y=w.y,sym="+",hitboxx=0,hitboxy=0,hitboxw=6,hitboxh=6})
		del(wall,w)
		end
	end
end
-->8
--enemies
function create_enemy(ox,oy,typ)
	
	e1= {
			x = ox,
			y = oy,
			sym = "\83",
			col = 9,
			hitboxx=0,
			hitboxy=0,
			hitboxw=6,
			hitboxh=6,
			wounds = 1,
			damage = 1,
			name = "stalker",
			ws=5,
		}
		
	e2= {
			x = ox,
			y = oy,
			sym = "\82",
			col = 9,
			hitboxx=0,
			hitboxy=0,
			hitboxw=6,
			hitboxh=6,
			wounds = 2,
			damage = 1,
			name = "revenant",
			ws=4,
		}
	
	e3={
			x = ox,
			y = oy,
			sym = "G",
			col = 9,
			hitboxx=0,
			hitboxy=0,
			hitboxw=6,
			hitboxh=6,
			wounds = 6,
			damage = 3,
			name="golem",
			ws=4,
		}
		
	e4={
			x = ox,
			y = oy,
			sym = "w",
			col = 9,
			hitboxx=0,
			hitboxy=0,
			hitboxw=6,
			hitboxh=6,
			wounds = 3,
			damage = 2,
			name="wizard",
			ws=3,
		}

	local enemies={e1,e2,e3,e4}
	local rndenemy=enemies[typ]
	
	add(enemy,rndenemy)
	
end

function enemyupdate()
	local pdir="nil"
	local pdirc="nil"

	for e in all(enemy) do
		
		local lx=e.x
		local ly=e.y

		if player.x>e.x	then pdir="e"
		elseif player.x<e.x then pdir="w"
		elseif player.y>e.y then pdir="s"
		elseif player.y<e.y then pdir="n" 
		end
		
		if player.x>e.x	and player.y>e.y
		then pdirc="se"
		elseif player.x<e.x and player.y<e.y
		then pdirc="nw"
		elseif player.x>e.x and player.y<e.y
		then pdirc="ne"
		elseif player.x<e.x and player.y>e.y 
		then pdirc="sw" 
		end		
	
		if fov(e) then
			if pdir=="e" then e.x+=6
			elseif pdir=="w" then e.x-=6
			elseif pdir=="n" then e.y-=6
			elseif pdir=="s" then e.y+=6
			end
		end
		
		if collide(player,e) then
			e.x=lx
			e.y=ly
			ebumpattack(e)
		end
		
		for w in all(wall) do
			if collide(e,w) then
				e.x=lx
				e.y=ly
				--prevent enemies from 
				--getting stuck on walls
				--currently borked
				--if pdir=="e" and pdirc=="se" then e.y+=6 end
				--if pdir=="w" and pdirc=="sw" then e.y+=6 end
				--if pdir=="e" and pdirc=="ne" then e.y-=6 end
				--if pdir=="w" and pdirc=="nw" then e.y-=6 end
			end
		end		
	
		for d in all(door) do
			if collide(e,d) then
			e.x=lx
			e.y=ly
			end
		end
		enemycollide(enemy,lx,ly)
	end
end

function enemycollide(outer_table,ox,oy)
	
	for m=1,#outer_table-1 do
		for n=m+1,#outer_table do
			local duplicate = false
			if 
			outer_table[n].x == outer_table[m].x 
			and
			outer_table[n].y == outer_table[m].y
			then duplicate = true
			end
			if duplicate then
				outer_table[n].x=ox
				outer_table[n].y=oy
			end
		end
	end		
end

function enemydeath()
	for e in all(enemy) do
 	if e.wounds < 1 then
  	sfx(5)
  	add(log,{tick,""..e.name.." is defeated."})
  	enemyitemdrop(e.x,e.y)
  	del(enemy, e)
  	kills+=1
  	return true
		end
	end
end

function enemyitemdrop(ox,oy)
	local iroll = roll(6)
	local wroll = roll(2)
	
	if iroll==6 then
		if (wroll==1) create_gun(ox,oy,(roll(4)))
		if (wroll==2) create_melee(ox,oy,(roll(3)))
	end
	if (iroll==4) create_orb(ox,oy)
	if (iroll==5) create_ammo(ox,oy)

end
-->8
--checks and tools
function roll(x)
	return flr(rnd(x))+1
end

function collide(obj, other)
  if
	other.x+other.hitboxx+other.hitboxw > obj.x+obj.hitboxx and 
	other.y+other.hitboxy+other.hitboxh > obj.y+obj.hitboxy and
	other.x+other.hitboxx < obj.x+obj.hitboxx+obj.hitboxw and
	other.y+other.hitboxy < obj.y+obj.hitboxy+obj.hitboxh 
  then
	return true
  end
end

function fov(obj)
	if obj.x <= (player.x+18) and
	obj.y <= (player.y+18) and
	obj.x >= (player.x-18) and
	obj.y >= (player.y-18)	
	then
		return true
	end
end

function oprint8(_t,_x,_y,_c,_c2)
 for i=1,8 do
  print(_t,_x+dirx[i],_y+diry[i],_c2)
 end
 print(_t,_x,_y,_c)
end
-->8
--items
 
function create_orb(ox,oy)
	orb={
	x=ox,
	y=oy,
	name="orb",
	sym="\79",
	hitboxx=0,
	hitboxy=0,
	hitboxw=6,
	hitboxh=6,
	col = 7,
		
	effect=function(self)
		sfx(8)
		add(fdn,{x=player.x,y=player.y,d="+"..player.woundsmax-player.wounds,t=0,col=11})
		player.wounds=player.woundsmax
		add(log,{tick,"picked up a "..self.name.."."})
		del(items,self)
	end,
			
	attract=function(self)
		if (t%30<15) then
		self.sym="o"
		else
		self.sym="\79"
		end
	end
	}
	add(items,orb)
end
	
function create_ammo(ox,oy)
	ammo={
	x=ox,
	y=oy,
	name="ammo",
	sym="=",
	hitboxx=2,
	hitboxy=2,
	hitboxw=2,
	hitboxh=2,
	col = 10,
		
	effect=function(self)
		player.gun.ammo=player.gun.ammomax
		add(log,{tick,"picked up "..self.name.."."})
		del(items,self)
	end,
			
	attract=function(self)
		if t==30 then
		self.y+=1
		elseif t==60 then
		self.y-=1
		end
	end
	}
	add(items,ammo)
end

function create_melee(ox,oy,typ)
	m1={
	 fullname="sword",
	 name="sword",
	 damage=2,
	 sym="/"
	}
		
	m2={
	 fullname="battle-axe",
	 name="batl-axe",
	 damage=3,
	 sym="|"
	}
	
	m3={
	 fullname="knife",
	 name="knife",
	 damage=1,
	 sym=","
	}
		
	melees={m1,m2,m3}
	rndwpn=melees[typ]
		
	melee={
	 x=ox,
	 y=oy,
	 name=rndwpn.fullname,
	 sym=rndwpn.sym,
	 hitboxx=0,
	 hitboxy=0,
	 hitboxw=6,
	 hitboxh=6,
	 col = 10,
		
	effect=function(self)
		if (btnp(5))	then 
			player.melee=rndwpn
			add(log,{tick,"equipped a "..self.name.."."})
			del(items,self)
			enemyupdate()
		end
	end,
			
	attract=function(self)
		if (t%60>30) then
		self.sym="*"
		self.col=7
		else
		self.sym=rndwpn.sym
		end
	end
	}
	add(items,melee)
end

function create_gun(ox,oy,typ)
 g1 = {
  fullname = "side-arm",
	 name = "side-arm",
	 damage = 1,
	 ammo = roll(9),
	 ammomax = 9,
	 sym=";"
	}
	
	g2 = {
	 fullname = "hand cannon",
	 name = "hand-cnn",
	 damage = 3,
	 ammo = roll(6),
	 ammomax = 6,
	 sym="~"
	}
	
	g3 = {
	 fullname = "laser rifle",
	 name = "lasr-rfl",
	 damage = 1,
	 ammo = roll(20),
	 ammomax = 20,
	 sym="&"
	}
	
	g4 = {
	 fullname = "fusion rifle",
	 name = "fusn-rfl",
	 damage = roll(10),
	 ammo = roll(8),
	 ammomax = 8,
	 sym="%"
	}
	
	guns={g1,g2,g3,g4}
	rndgun=guns[typ]
  
 gun={
	 x=ox,
		y=oy,
		name=rndgun.fullname,
		sym=rndgun.sym,
		hitboxx=0,
		hitboxy=0,
		hitboxw=6,
		hitboxh=6,
		col = 10,
		
		effect=function(self)
			if (btnp(5))	then 
				player.gun=rndgun
				add(log,{tick,"equipped a "..self.name.."."})
				del(items,self)
			end
		end,
			
		attract=function(self)
		end
	}
	add(items,gun)
end
__gfx__
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
010100000602006020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000602006020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000161001600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100000d0500d0500d0500e050120501705019050160500f05006050020500300001000280002a0002a000290002000002000220002c000340003f0000000034000360003600036000320001f0000b00001000
000100000a1500a1500d15010150151501b1502615000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000100000c3100c3101132020320213301e330193200f320073100131000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000100001e5501d5501b5501955016550135500d55009550075500255001550005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100001075010750107500f75020610206102061020610206101071010750107501075006750057500575004750027500770002700017000070000700007000070000700007000070000700007000070000700
000200001555016550165502255023550215501d55019550115500d55009550075500455001550005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0114002010f2511f250ef2510f2511f2511f250ef2510f2511f250ef2510f2511f250ef2510f2511f250ef2510f2511f200ef2010f2511f2010f201af2510f201df2011f2010f251df2010f2021f2011f250ef20
010a002024a360000624a360000624a360000624a36000062ba362ba362ba362ba3600006000061fa36000061fa36000061fa360000624a3624a3624a3600006000000000024a360000026a3626a360000000000
000600002405024000250500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110002013b3319b000fb0013b3300b0000b0000b0000b000eb3010b3310b3311b330db300fb300eb3010b3011b3013b3015b3017b3017b3017b3017b3017b3017b3017b300cb300cb300fb3011b3110b310cb32
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
