pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- rogueris: trials of dungeonfall
-- by elneil

fades = {6,5,4,3,2,1,0,1,2,3,4,5,6}
fadeout = 7
fadetarget = 13
chords = {15,13,15,16,15}
amcolours = {7,6,13,5,1}
walltile = 1
blanktile = 2
monsterlow = 4
monsterhigh = monsterlow + 11
healthtile = 77
treasuretile = 71
armourtile = 76
chesttile = 73
playertile = 94
spawntile = 51
highlighttile = 103
stairsintile = 3 -- do not change this
stairsouttile = 75
potionlow = 64
potionhigh = potionlow + 5
amulettile = 124
pipeslow = 118

tilechances = -- (in %)
{
5,	-- treasure
7, -- monster
1, -- armour
3, -- potion
1, -- health
14 -- wall
}

rolltable = {}
for i = 1,#tilechances do
	for j = 1,tilechances[i] do
		add(rolltable,i)
	end
end

for k = #rolltable + 1,100 do
	rolltable[k] = -1;
end

-- high = rare
treasuredropchance =  8
armourdropchance = 14

-- wraith/druid outcomes
wdrolltable = {0,0,0,0,1,2}
	
blocks = {}
blocks[1] = {2,5,8} -- stick
blocks[2] = {4,5,7,8} -- square
blocks[3] = {4,5,8,9} -- s
blocks[4] = {5,6,7,8} -- z
blocks[5] = {4,5,6,8} -- t
blocks[6] = {4,5,6,7} -- l
blocks[7] = {4,5,6,9} -- j
blocks[99] = {2,4,5,6,8} -- spawn
blockbag = {}

-- blocks selected during luck potion
luckbag = {1,5,2}

fadetable={
{0,0,0,0,0,0,0},
{1,1,1,0,0,0,0},
{2,2,2,1,0,0,0},
{3,3,3,1,0,0,0},
{4,2,2,2,1,0,0},
{5,5,1,1,1,0,0},
{6,13,13,5,5,1,0},
{7,6,13,13,5,1,0},
{8,8,2,2,2,0,0},
{9,4,4,4,5,0,0},
{10,9,4,4,5,5,0},
{11,3,3,3,3,0,0},
{12,12,3,1,1,1,0},
{13,5,5,1,1,1,0},
{14,13,4,2,2,1,0},
{15,13,13,5,5,1,0}
}

-- tl of grid
tlx = 2
tly = 6

-- tl of "next" block
nexttlx = 70
nexttly = 13

-- rotated pos of 4th cell in "stick"
rotlist = {1,-1,1,3,1}

-- gamestates
st_none = 0
st_maingame = 1
st_title = 2
st_gameover = 3
st_instructions = 4
st_credits = 5
st_splash = 6
st_pretitle = 7
st_getready = 8

sst_blockhighlight = 1
sst_removelines = 2
sst_gridshake = 3
sst_spawning = 4
sst_losetetris = 5
sst_loserogue = 6
sst_newlevel = 7
sst_win = 8

loseroguetimer = 60
options = {
"play",  
"co-op",
"instructions", 
"credits"
}

potioneffects = {
 "sick", 
 "heal",
 "buff",
 "norm",
 "luck",
 "echo",
 "none"
}

-- colors for flashing text, as per list above
potioneffectcolors = {
 {3,11,7},
 {8,14,7},
 {9,10,7},
 {5,13,7},
 {1,12,7},
 {4,15,7},
}

tutorialcolors = {5,13,6}

--[[
	monsters on each level
	0 skel
	1 mum
	2 orc
	3 slm
	4 gob
	5 dem
	6 cyc
	7 wra
	8 dru
	9 min
	10 zom
	11 snk
]]

monsterdist = {
{4,6,11,0},
{5,8,1,2},
{7,9,10,0},
{3,4,11,1},
{6,8,0,2},
{5,9,11,1},
{3,4,7,2},
{6,8,9,10},
{5,6,7,0},
{3,5,10,11}
}

monsterdesc = {
	"skellies need no introduction.",
	"mummys... mummies? mummii?!",
	"orcs are 'orcsome'.",
	"slimes ooze through armour!",
	"goblin damage can be +/- 1!",
	"demon damage can be +1 or +2!",
	" always hit cyclopses here!",
	"wraiths can steal treasures!",
	"chaos druids might heal you!",
	"minotaurs can smash holes!",
	"zombies always come back!",
	"snakes can dodge attacks!"
}
 
-- sprites in instructions
instrsprites = 
{
	{
		{playertile,30,77},
		{amulettile+2,120,90}
	},
	{
		{monsterlow,37,77},
		{monsterlow+4,45,77},
		{monsterlow+8,53,77}
	},
	{
		{potionlow+1,30,95}
	},
	{
		{stairsouttile,38,17},
		{treasuretile,47,30}
	}, 
 {
		{79,86,11},
		{220,82,29}
	} 
}


tempo = 64 -- ticks per beat
monsterlevelspeed = 30 * 54 -- 30fps * secs
linesperlevel = 7 -- lines needed to level up
maxarmours = 14
maxhealth = 7
fastestblockspeed = 15
potionduration = 30 * 15 -- 30fps * secs
---------------------------
function _init()

tick = 0 -- general ticks - because of bug, separate from dance_anim 
monster_tick = 0 -- for monster xp gain
dance_tick = 0 -- for dance anim
potion_anim = 0 -- for potion anim
	
-- main grid
grid = {}

sstatetimer = 90
state = st_splash
sstate = st_none
titlemenu = 0
tutorial = true
fade = fadeout
fading = false

end

function newlevel()
	
	dance_anim = 0 -- spr offset for dance anims
	floor += 1
	floorskin = floor % 4
	spawned = false
	choice = 99
	newblock = true
	nextchoice = 0
	exitready = false
	exitspawned = false
	potionspawned = 0 -- how many
	treasurespawned = 0 -- how many
	delay = (max (fastestblockspeed, delay -2))
	needzombie = 0 -- num zombies awaiting respawn
	potionflash = 0
	treasureflash = 0
	monster_tick = 0 -- separate from global tick so monsters can lose xp each level

	for ix = 1,10 do
	grid[ix] = {}
		for iy = 1,24 do
		  grid[ix][iy] = 0
		end
	end
	
	healthanims = {}
	armouranims = {}
	-- ref. both arrays, make later code shorter
	bothanims = {healthanims,armouranims}
	
	floaters = {} -- floating text
	deaths = {} -- enemy death anims
	
	state = st_getready
	sstate = st_none
end

function newgame()
	level = 1
	monsterlevel = 2
	calcleveldiff()
	dead = false
	health = 1
	treasures = 0
	armours = 4
	potion = 6 -- no pot active
	potiontimer = 0 -- timer for potion effect
	numlines = 0
	delay = 37 -- starting block speed
	blocknumber = 0 -- for treasure delay hack
	
	treasuretargets = {}
	for i = 1,12 do
		treasuretargets[i] = (i*5) + flr(rnd(3)) - 1
	end
	
	potbag = {}
	
	floor = -1
	-- uncomment this bit if (floor > -1) or game will crash:
	-- bars = 0
	chordnum = 1
	
	-- this helps with reversing controls
	sick = 0
	
	newlevel() -- go!
end
--------------------------
function _update()

	-- hack to avoid dropped frames whenever game is paused
	-- thanks to @le_gars for this one
	if btnp() == 64 then tick -= 2 end
	
	tick += 1
	dance_tick += 1
	
	-- leave this here in case potion anims 
	-- required outside of main game
	if ( (tick % 3) == 0) then 
		potion_anim = ((potion_anim + 1) % 3) 
	end
	
	local count = 0  
	dofade()

	if (state == st_maingame) then
		-- music
		pos = tick % tempo
		if ( pos == tempo/2) then
			if (bars-1) % 16 != 7 then sfx(12) end -- snare
			dance_anim = 2
			dance_tick = 0
		elseif pos == (tempo/4)*3
			and potion == 1 
			and health < maxhealth 
			and flr(rnd(4)) == 0 then heal(1) -- heal noise
		elseif pos == 0 then
			bars += 1
			if bars % 2 == 1 then sfx(0) end -- kick
		end
		if (dance_tick == 3) then
			dance_tick = 0
			dance_anim = max(dance_anim-1,0)
		end
		if pos == 0 and bars > 1 and bars % 8 == 1 then 
			sfx(chords[chordnum])
			chordnum += 1
			if chordnum > #chords then chordnum = 1 end 
		end 
		if armours + health < 3 
			and health > 0
			and pos == (tempo / 4) 
		then 
			sfx(14) 
		end
	
		-- potion bag
		if #potbag < 2 then potbag = {0,1,2,3,4,5} end
	
		-- health/armour spawn anims
		for i = 1,2 do
			for k,v in pairs(bothanims[i]) do
				v[1] += v[2]
				if (v[1] < 0 or v[1] > 2) then
					bothanims[i][k] = nil
				end
			end
		end	
			
		-- pot/treasure "flashes"
		if (potionflash > 0) then potionflash -= 1 end
		if (treasureflash > 0) then treasureflash -= 1 end
		
		
		-- floating text
		for v in all (floaters) do
			v[2] -= 1
			v[5] -= 1
			if v[5] == 0 then del(floaters,v) end
		end
		
		-- enemy death anims
		for v in all (deaths) do
			v[3] += 1
			if v[3] == 6 then del(deaths,v) end
		end
		
		if (sstate == st_none) then
			
			-- give monster xp if idle
			monster_tick += 1
			
			-- hack to prevent stairs not working
			-- when you move onto them while creating a line
			if (spawned == true and grid[px][py] == stairsouttile) then 
				sstate = sst_newlevel
				sstatetimer = 72
			end
			
			-- potion timer
			potiontimer -= 1
			if (potiontimer < 1) then
				potiontimer = 0
				sick = 0
				if potion == 2 then
					level -= 2
					calcleveldiff()
				end
				potion = 6 -- none
			end
			
			-- new block?
			if (newblock) then getnewblock() end
			
			-- monster level up
			if ((monster_tick % monsterlevelspeed) == 0) then 
				monsterlevel = min (monsterlevel + 1, 99)
				add(floaters,{92,121,"level up!",3,22})
				sfx(11)
				calcleveldiff()
			end
			
			-- controller
			local down = false
			if not coop then
  			if btn(5) and spawned then -- p0 x button
  				-- l
  				if btnp(0) then moveplayer((2*sick)-1,0)
  				-- r
  				elseif btnp(1) then moveplayer(1-(2*sick),0)
  				-- u
  				elseif btnp(2) then moveplayer(0,(2*sick)-1)
  				-- d
  				elseif btnp(3) then moveplayer(0,1-(2*sick))
  				end
  			else	
  				-- not pressing x...
  				-- l
  				if btnp(0) then moveblock(-1,0)
  				-- r
  				elseif btnp(1) then moveblock(1,0)
  				end		
  				-- d (not at top of screen)
  				if btn(3) then
  					down = downallowed
  				else 
  					downallowed = true 
  				end
  				-- u
  				if btnp(2) then rotate(currentblock) end
  			end		
			else
				if spawned then -- p0 x button
  				-- l
  				if btnp(0) then moveplayer((2*sick)-1,0)
  				-- r
  				elseif btnp(1) then moveplayer(1-(2*sick),0)
  				-- u
  				elseif btnp(2) then moveplayer(0,(2*sick)-1)
  				-- d
  				elseif btnp(3) then moveplayer(0,1-(2*sick))
  				end
  		end
  				-- not pressing x...
  				-- l
  				if btnp(0,1) then moveblock(-1,0)
  				-- r
  				elseif btnp(1,1) then moveblock(1,0)
  				end		
  				-- d (not at top of screen)
  				if btn(3,1) then
  					down = downallowed
  				else 
  					downallowed = true 
  				end
  				-- u
  				if btnp(2,1) then rotate(currentblock) end	
			end
			
			-- block move timer, only move if not pressing down
			timer -= 1
			if (timer == 0) then
				timer = delay
				down = true
			end
			if (down) then moveblock(0,1) end
		
			-- any lines?
			lines = {}
			for y = 24,2,-1 do
				local full = true
				if (y == py) then full = false end
				for x = 1,10 do
					if grid[x][y] == 0 or grid[x][y] > stairsintile then full = false end
				end
				if (full) then 
					add(lines,y) 			
				end
			end
			if (#lines > 0) then
				-- add player xp 
				if (monsterlevel < 99) then 
					numlines += #lines
					-- level up?
					if checklevelup() then
						levelup()
						delay = (max(fastestblockspeed,delay -1))
					end
				end
				
				sstate = sst_blockhighlight 
				sstatetimer = 15
				sfx(8)
			end
		
		elseif (sstate == sst_blockhighlight) then 
			sstatetimer -= 1
			if (sstatetimer == 0) then sstate = sst_removelines end
		
		elseif (sstate == sst_removelines) then
			-- remove lines
			for v in all (lines) do
				for y = v+count,2,-1 do
					-- bump player down
					if (py == y) then py += 1 end
					for x = 1,10 do
						grid[x][y] = grid[x][y-1]
					end
				end
				count += 1
			end
				
			-- clear new lines at top
			for y = 1,count do
				for x = 1,10 do
					grid[x][y] = 0
				end
			end
			
			sstate = sst_gridshake
			sstatetimer = 8
			sfx(7)
			
		elseif (sstate == sst_gridshake) then
			sstatetimer -= 1
			shake()
			if (sstatetimer == 0) then camera() sstate = st_none end
		
		elseif (sstate == sst_spawning) then
			sstatetimer -= 1
			if (sstatetimer == 0) then
				sstate = st_none
				spawned = true
			end
		
		elseif (sstate == sst_losetetris) then
			shake()
			doendtimer()
		elseif (sstate == sst_loserogue) then
			doendtimer()
		elseif (sstate == sst_win) then
			doendtimer()
			if sstatetimer == 122 or sstatetimer == 10 then sfx(22)
			elseif sstatetimer == 120 then sfx(23) end
			amh = min(amh+0.0625,5)
		elseif (sstate == sst_newlevel) then	
			if sstatetimer == 72 then sfx(2) end
			sstatetimer -= 1
			if (sstatetimer == 7) then fade = 0
			elseif (sstatetimer == 0) then newlevel()
			end
		end -- substate	
	
	elseif (state == st_title) then
		
		if (not fading) then 
			if (btnp(2)) then sfx(4) titlemenu -= 1 end
			if (btnp(3)) then sfx(4) titlemenu += 1 end
			titlemenu %= #options
		end
		
		fadeonbutton()
		if (fade == fadeout) then 
			fading = false
			if (titlemenu == 0) then newgame() coop=nil
			elseif (titlemenu == 1) then
				coop=true
				newgame() 
			elseif (titlemenu == 2) then
				state = st_instructions
				instructionspage = 1
			else 
				state = st_credits 
			end	 
		end
		
	elseif (state == st_gameover) then
		fadeonbutton()
		if (fade == fadeout) then 
			fading = false
			state = st_title
			sstate = st_none
		end

	elseif (state == st_getready) then
		fadeonbutton()
		if (fade == fadeout) then 
			fading = false
			state = st_maingame
			sstate = st_none
			
			if floor == 0 then
				tick = -1 -- reset tick == reset music
				bars = 0	
			end
		end
	
	elseif (state == st_splash) then
		sstatetimer -= 1
			if (sstatetimer == 7) then fade = 0 end
			if (sstatetimer == 0) then
				sstatetimer = 25
				logoheight = -1000
				state = st_pretitle
			end
	
	elseif (state == st_pretitle) then	
		sstatetimer -= 1
		logoheight = 25 - (max(sstatetimer - 6,0) * 15)
		if sstatetimer == 0 then
			camera() 
			state = st_title
		elseif sstatetimer == 6 then sfx(18)
		elseif sstatetimer < 5 then 
			shake() 
		end
	
	elseif state == st_instructions and instructionspage < 5 then	
		fadeonbutton()
			if (fade == fadeout) then
				fading = false
				instructionspage += 1
			end
	else
		fadeonbutton()
		if (fade == fadeout) then 
			fading = false 
			state = st_title
		end	
	end -- checking state
	
end -- fn

-------------------------------

function shake()
	camera(flr(rnd(3))-1,flr(rnd(5))-2)
end
			
-------------------------------
function levelup()
	level = min(level + 1, 99) 
	calcleveldiff()
	add(floaters,{92,99,"level up!",3,22})
	sfx(9)
end
-------------------------------
function checklevelup()
	if numlines >= level * linesperlevel 
	or (potion == 2 and numlines >= (level-2) * linesperlevel)
	then return true
	else return false
	end					
end
-------------------------------
function doendtimer()
	sstatetimer -= 1
	if (sstatetimer == 7) then fade = 0 end
	if (sstatetimer == 0) then
		endtext = gameoverrand[flr(rnd(#gameoverrand))+1]
		state = st_gameover
		camera() -- in case we are shaking
	end
end
		
------------------------------		
function fadeonbutton(n)
	if (n == nil) then n = 5 end 	
	if (btnp(n) and not fading) then 
		fade = 0
		fading = true
		sfx(17) 		
	end
end
 
-------------------------------
function _draw()

cls() 

if (state == st_maingame) then

	-- border
	drawbox(tlx-1,tly-3,61,123)
	line (tlx-1,tly-3,tlx+60,tly-3,0)

	-- grid
	for y = 1,24 do
		for x = 1,10 do
			tile = grid[x][y]
			if (tile > 0) then	
				checkforanimation()
				spr (tile,tlx + (x-1)*6,tly + (y-5)*6)
			end
		end 
	end
	
	-- enemy death anims
	for v in all (deaths) do 
			spr(160+v[3],tlx + ((v[1]-1)*6), tly + ((v[2]-5)*6))
	end
	
	if (currentblock) then
	
		tile = blanktile + (floorskin*16)
		-- "next" block etc
		for v in all (blocks[nextchoice]) do
			spr (tile,
			nexttlx + ((v-1) % 3 )*6, 
			nexttly + flr((v-1)/3)*6
			)
		end
		if (nextchoice == 1) do
			spr (tile,nexttlx+6, nexttly+18) 
		end
		
		-- overwrite with lava if grid full
		if sstate == sst_losetetris then tile = 16 + potion_anim * 16 end
				
		if (choice == 1) do 
			spr (tile,
			tlx + ((blockx + extracellx)*6), 
			tly + ((blocky + extracelly - 4)*6)
			)
		end
		
		-- current block
		for y = 0,2 do
			for x = 1,3 do
			tile = currentblock[y*3+x]
				if (tile > 0) then
					checkforanimation()
					-- draw lava if they've lost game
					if sstate == sst_losetetris then tile = 16 + potion_anim * 16 end
					spr (tile,tlx + ((blockx + x - 1)*6), tly + ((blocky + y - 4)*6))
				end
			end -- x
		end -- y
		if tutorial then 
			color(tutorialcolors[potion_anim+1])
			if not spawned then
				
				if blocky < 7 then
					if (coop) print("player 2:",tlx+4,tly+34)
					print("use ‹ and ‘",tlx+4,tly+40)
					print("to move block",tlx+4,tly+46) 
				elseif blocky < 14 then
					print(" use ” to",tlx+7,tly+82)
					print("rotate block",tlx+7,tly+88) 
					print(" and ƒ to",tlx+9,tly+94)
					print("drop block!",tlx+9,tly+100) 
				end
			elseif blocky < 12 then
				if (coop) print ("player 1:",tlx+2,80)
				print ("to move rogue,",tlx+2,86)
				if not coop then
					print (" hold — and",tlx+3,92)
				end
				print ("press ”ƒ‹‘",tlx+2,98)
			end
			color(7)
		end		
		
	
	end -- if (currentblock)
	
	-- highlight full lines
	if (sstate == sst_blockhighlight) then
		for y in all (lines) do
			for x = 0,9 do
			 spr (highlighttile+ ((sstatetimer + x) % 5),tlx + (x*6), tly + ((y - 5)*6))
			end
		end	
	
	elseif (sstate == sst_loserogue) then
		-- awful code
		-- assumes sprites begin at 148, counts down in 2s to 128
		local frame = max(148 - (flr((loseroguetimer - sstatetimer) / 2) * 2),128)
		spr (frame, tlx + ((px-1)*6)-5, tly + ((py-5)*6)-2,2,1)
	end
	
	local tlhudx = 93
	local tlhudy = 12
	local hhudx = 67
	local hhudy = 43
	local ahudx = 67
	local ahudy = 65
	local xphudx = 66
	local xphudy = 98
	local hudcol = 7
	
	-- "next" hud
	print("next",nexttlx+1,nexttly-10,hudcol)
	drawbox(nexttlx-3,nexttly-3,23,29)
	
	
	-- health
	for i = 0,health-1 do
		spr(79 + 16 * dance_anim, hhudx + 3 + (i%7)*8, hhudy + 10) 
	end
	drawbox(hhudx,hhudy+7,59,11)
	
	if armours + health < 3 then color(potioneffectcolors[2][potion_anim+1]) else color(hudcol) end
	print ("health",hhudx+18,hhudy)
	
	-- armour
	for i = 0,armours-1 do
		spr(220 + 16 * dance_anim, ahudx + 3 + (i%7)*8, ahudy + 10 + flr(i/7) * 8) 
	end
		drawbox (ahudx,ahudy+7,59,19)
	print ("armour",ahudx+18,ahudy,hudcol)
	
	-- heart/armour spawn/despawn anims
	for i = 0,1 do
		for k,v in pairs(bothanims[i+1]) do
			spr(112+(i*3)+v[1], hhudx + 3 + ((k-1)%7)*8, hhudy+(i*(ahudy-hhudy)) +(flr((k-1)/7)*8)+ 10) 
		end
	end
	
	-- pipes
	spr(pipeslow + potion_anim*2, xphudx+14,xphudy+9)
	spr(pipeslow + 1 + potion_anim*2, xphudx+22,xphudy+9)
	spr(pipeslow + potion_anim*2, xphudx-3,xphudy+9)
	-- connectors
	rectfill(xphudx+28,xphudy+7,xphudx+30,xphudy+8,6)
	rectfill(xphudx+28,xphudy+16,xphudx+30,xphudy+17,6)
	rectfill(xphudx-3,xphudy+10,xphudx-2,xphudy+15,6)
	
	-- xp bars and bg's
	rectfill (xphudx+26,xphudy-3, xphudx+26+(((numlines % linesperlevel) / linesperlevel) * 34), xphudy+5,2)
	rectfill (xphudx+26,xphudy+19, xphudx+26+(((monster_tick%monsterlevelspeed)/monsterlevelspeed) * 34), xphudy+27,5)
	drawbox(xphudx+25,xphudy+18,35,10)
	drawbox(xphudx+25,xphudy-4,35,10)
	
	-- threat
	rectfill(xphudx+6,xphudy+8,xphudx+16,xphudy+16,basedmgcolor)
	drawbox(xphudx+5,xphudy+7,12,10)
	if potion == 2 then color (potioneffectcolors[3][potion_anim+1]) else color(0) end
	print (basedmgtext,xphudx+12-(#basedmgtext*2), xphudy+10)
	spr(78, xphudx+32,xphudy+10)
	
	-- rest of xp hud
	color(hudcol)
	print ("damage", xphudx+37,xphudy+10)
	print ("level: ",xphudx+1, xphudy-1)
	print (level,xphudx+28, xphudy-1)
	print ("enemy: ",xphudx+1, xphudy+21)
	print (monsterlevel,xphudx+28, xphudy+21)
	
	
	-- top hud
	spr(stairsintile,tlhudx+3,tlhudy)
	print((floor + 1).. "/10",tlhudx+13, tlhudy+1)
		
	spr(treasuretile+treasureflash, tlhudx+3,tlhudy+10)
	print(treasures,tlhudx+13,tlhudy+11)
	
	spr(potionlow + potion + (potion_anim * 16), tlhudx+3,tlhudy+20) 
	spr(87 + potionflash, tlhudx+3,tlhudy+20)
	if (potion < 6) then color (potioneffectcolors[potion+1][potion_anim+1]) else color(hudcol) end
	print(potioneffects[potion+1],tlhudx+13,tlhudy+21)
	
	
	-- player
	if (spawned) then
		if (sstate == sst_newlevel ) then
			-- exit anim
			if sstatetimer > 50 then 
				spr (spawntile+(flr((sstatetimer-51)/2)), tlx + ((px-1)*6), tly + ((py-5)*6))
			end
		elseif sstate != sst_loserogue	then
			-- normal anim
			if (potion < 6) then 
			local p = (potioneffectcolors[potion+1][potion_anim+1]) 
				pal (7,p)
				pal (6,p)
			end
			spr (playertile + (0.5*band(btn(), 32)), tlx + ((px-1)*6), tly + ((py-5)*6))
			pal()
		end
	elseif sstate == sst_spawning and sstatetimer < 23 then 
		-- spawn anim
		spr (spawntile+10-(flr((sstatetimer-1)/2)), tlx + ((px-1)*6), tly + ((py-5)*6))
	end

	-- floating text
	for v in all (floaters) do
		print(v[3],v[1],v[2],potioneffectcolors[v[4]][potion_anim+1])
	end
		
	-- win sequence overlays everything
	if (sstate == sst_win) then
		cl = {0,0,0,5,6,7,7}
		tempx = tlx+((amx-1)*6)
		tempy = tly+((amy-5)*6)	
		rectfill(tempx,tempy-amh,tempx+5,tempy-amh+5,0)
		spr(amulettile+flr(rnd(4)),tempx,tempy-amh)
		if sstatetimer < 8 then cls(cl[sstatetimer])
		elseif sstatetimer < 120 then
			-- rotate colours
			add(amcolours,amcolours[1])
			del(amcolours,amcolours[1])
			pal(7,amcolours[2])
			pal(6,amcolours[3])
			pal(13,amcolours[4])
			pal(5,amcolours[5])
			pal(1,amcolours[1])
			sspr(104,104,24,24,tempx-33,tempy-38,72,72)
			pal()
		elseif sstatetimer > 119 and sstatetimer < 122 then
			cls(sstatetimer-114)
		end
	end
	-- put color back
	color(7)

elseif (state == st_title) then
	
	for i = 1, #options do
		local str = options[i]
		color(7)
		if (i-1 == titlemenu) then color(9) end
		print (str,64-((#str * 4)/2),64 + (i*6))
	end
	
	spr(78,28,70 + (titlemenu * 6),1,1,true,false)
	spr(78,91,70 + (titlemenu * 6))
	spr(208,16,25,12,3)
	print("- trials of dungeonfall -",14,52,7)
	print("”ƒ to select, — to confirm",6,120,6)

elseif (state == st_gameover) then
	color(7)
	if (sstate == sst_win) then
		spr(154,50,20,2,1)
		spr(156,64,20,2,1)
		spr(amulettile+flr(rnd(4)),60,72)
		for i = 1,#wintext do
			print(wintext[i],0,30+(i*6))
		end
	else		
		spr(150,46,20,2,1)
		spr(152,66,20,2,1)
		print (endtext,64-((#endtext/2)*4),40)
		for i = 1,#gameovertext do
			print(gameovertext[i],0,60+(i*6))
		end
	end
	if (tick%30) < 15 then print ("—",121,123,9) end
elseif (state == st_instructions) then
	
	print(instructionspage.."/5",0,1)
	for i = 0,20 do
		if i == 0 or i == 20 then color(9) else color(7) end
		print (text[instructionspage][i+1],0,1 + i*6)
	end
	
	for a in all(instrsprites[instructionspage]) do
		spr(a[1],a[2],a[3]+1)
	end
	
	if (tick%30) < 15 then print ("—",121,123,9) end
	
elseif (state == st_credits) then
	for i = 0,20 do
		if i == 0 then color(9) 
		elseif i == 15 then color(10)
		else color(7) 
		end
		print (text[6][i+1],2,1+(i*6))
	end
	spr(79,118,90)
	if (tick%30) < 15 then print ("—",121,123,9) end
elseif (state == st_splash) then
	print	("somewhere between",30,30,7)
	print ("1980 and 1984...",32,37,7)
	
elseif (state == st_pretitle) then
		if logoheight > -25 then 
			spr(208,16,logoheight,12,3)
			print("- trials of dungeonfall -",14,logoheight+27,7)
		end	
		if sstatetimer == 5 then cls(7) 
		elseif sstatetimer == 4 then cls(6) end

elseif (state == st_getready) then
	
	print("- trials of dungeonfall -",15,15,9)
	spr(192,49,26,3,1)
	spr(195+floor,73-flr(floor/10),26)
	print("scholarly wisdom:",30,48,10)
	for i = 1,4 do
		local n = monsterdist[floor+1][i]
		spr(monsterlow+n,1,52+i*10)
		if n == 6 then spr (78,8,52+i*10) end
		if n > 2 then color(7) else color(6) end
		print(monsterdesc[n+1],11,52+i*10)
	end
	if (tick % 30) < 15 then print ("—",121,123,9) end
	color(7)
end -- state check


end -- fn
-----------------------------

function drawbox(x,y,w,h)
 line (x+1,y, x+w-1,y,13)
	line (x+1,y+h, x+w-1,y+h,1)
	sspr(88,40,1,8,x,y+1,1,h-1)
	sspr(88,40,1,8,x+w,y+1,1,h-1)
end
-----------------------------
function calcleveldiff()
	leveldiff = monsterlevel - level
	if leveldiff > 0 then
		basedmgtext = ""..leveldiff
	else
		basedmgtext = "0"
	end
	-- calc. color of damage text
	if leveldiff > 3 then basedmgcolor = 8
	elseif leveldiff < 2 then basedmgcolor = 3
	else basedmgcolor = 9--= 14 - (flr(leveldiff/2) * 5)  --11-flr(leveldiff/2)--24-(5*leveldiff)
	end
end
------------------------------
function checkforanimation()
	if (tile == blanktile or tile == floortile) then tile += (16 * floorskin)
	elseif (
	tile >= monsterlow and tile <= monsterhigh 
	or tile == healthtile 
	or tile == armourtile
	) then tile += (16 * dance_anim) 
	elseif	(tile >= potionlow and tile <= potionhigh) then tile += 16 * potion_anim
	elseif tile == amulettile then tile += flr(rnd(4))
	end 
end
------------------------------

function moveplayer(dx,dy) 
	x = px+dx
	y = py+dy
		
	if (x > 0 and x < 11 and y > 4 and y < 25) then
		local tile = grid[x][y]	
		
		-- sp. case - snake
		if (tile == monsterlow + 11 and potion != 3) then
			-- jump loc
			sx = x + flr(rnd(3)) - 1
			sy = y + flr(rnd(3)) - 1
			-- able to jump?
			if (
							sx > 0 and sx < 11 
							and sy > 4 and sy < 25
							and grid[sx][sy] == blanktile
							and (sx != px or sy != py)
						)
			then
				grid[sx][sy] = monsterlow + 11
				grid[x][y] = blanktile
				tile = blanktile
				sfx(10)
				addfloater("dodge!",1)
			end
		end
		
		if (tile > walltile) then
			if (tile >= monsterlow and tile <= monsterhigh) then
				
				local damage = leveldiff
				if damage > 0 and tile == monsterlow + 3 and potion != 3 then sfx(27) addfloater("ooze!",3) else sfx(19) end
				-- any dmg fluctuations?
				if (potion != 3) then
					if (tile >= monsterlow + 4 and tile <= monsterlow + 5) then
						-- goblins / demons
						local bonus = (flr(rnd(3)) + (tile - (monsterlow + 5))) 
						damage += bonus
						if bonus != 0 then 
							if bonus > 0 then bonus = "+"..bonus end
							addfloater(""..bonus,4)
						end
					elseif (tile == monsterlow + 6) then
						-- cyclopses
						if px <= x then 
							damage += 2
							addfloater("+2",4)
						end
					elseif (tile == monsterlow + 7) then
						-- wraiths
					 local numlost = wraithdruid()
					 if numlost > 0 and treasures > 0 then 
					 	treasureflash = 3
					 	addfloater("steal!",3) 
							for i = 1,numlost do 
								treasures = max(treasures-1,0)
							end
							sfx(3)
						end
						-- druids
					elseif (tile == monsterlow + 8) then
						local numgained = wraithdruid()
						if numgained > 0 then 
							damage = 0
						 if health < maxhealth then 
								addfloater("heal!",2)
								heal(numgained)
							end
						end
						-- zombies
					elseif (tile == monsterlow + 10) and ((health+armours - damage) > 0) then
						addfloater("respawn!",6)
						needzombie += 1
						sfx(29)	
					end				
				end
		
				if (damage > 0) then
					for i = 1,damage do
						-- take from armour first, unless slime
						if armours > 0 and (tile != monsterlow + 3 or potion == 3) then 
							armouranims[armours] = {2,-1}
							armours -= 1
						else
							if (health > 0) then
								healthanims[health] = {2,-1}							
								health -= 1
							end
						end -- if armours
					end -- for
					if (health == 0) then dead = true sfx(21) end
				end -- if damage
				
				-- u dead yet?
				if (dead) then	
					sstate = sst_loserogue
					sstatetimer = loseroguetimer
				else
					-- kill enemy
					-- calc. state of tile
					add(deaths,{x,y,0})
					if tile == monsterlow + 9 and potion != 3 then
						-- minotaur
						grid[x][y] = 0
						addfloater("smash!",5)
						sfx(18)
					elseif flr(rnd(armourdropchance)) == 0 then
					 grid[x][y] = armourtile
					elseif treasurespawned < 2 and flr(rnd(treasuredropchance)) == 0 then
						-- treasures drop even if exit spawned
						grid[x][y] = treasuretile
						treasurespawned += 1
					else
						grid[x][y] = blanktile
					end -- if tile
				end -- if dead
			
			elseif tile == amulettile then
					grid[x][y] = blanktile
					sstate = sst_win
					sfx(25)
					amx = x
					amy = y
					amh = -0.0625
					potion = 6
					sstatetimer = 210 -- 30fps * 7 secs
			else
				-- pickups!
				if (tile == treasuretile) then 
					sfx(20)
					treasures += 1
					treasurespawned -= 1
					treasureflash = 3
					if (treasures >= treasuretargets[floor+1]) then
						exitready = true	
					end
				elseif (tile == healthtile) and health < maxhealth then heal(1)  
				elseif (tile == armourtile and armours < maxarmours) then 
					sfx(30)
					armours += 1 
					armouranims[armours] = {0,1}
				elseif (tile >= potionlow and tile <= potionhigh) then 
					-- potion id is 0-based
					potionflash = 3
					potionspawned -= 1
					sfx(24)

					-- this step is required
					-- so repeatedly drinking "buff" won't stack 
					local temp = tile - potionlow
					if temp == 2 then
						if potion != 2 then
							level += 2
							calcleveldiff()
						end
					elseif potion == 2 then
						level -= 2
						calcleveldiff()
					end
					
					potion = temp
					if potion == 5 then echochoice = nextchoice end 
					if potion > 0 then sick = 0 else sick = 1 end
					potiontimer = potionduration
					addfloater(potioneffects[potion+1],potion+1)
						
				elseif (tile == stairsouttile) then
					sstate = sst_newlevel
					sstatetimer = 72
				end -- if tile
				if (tile != stairsintile and tile != stairsouttile) then 
					grid[x][y] = blanktile
				end			
				px = x 
				py = y
				sfx(4)
			end -- if tile
		end -- if tile
	end -- if x
end --fn

-----------------------------
function heal(n)
	for i = health+1,min(health+n, maxhealth) do
		health += 1
		healthanims[i] = {0,1}
	end
	sfx(28)
end

------------------------------

-- do not call this function outside of moveplayer()
-- unless you have values for fx and fy
function addfloater(text,clr,fx,fy)
	fx = fx or tlx+((x-1)*6)
	fy = fy or tly-3+((y-5)*6)
	fx -= (#text*4) / 2 - 4
	fx = max(tlx,min(tlx+61-(#text*4),fx)) 
	add(floaters,{fx,fy,text,clr,15})
end


-----------------------------					
-- wraith / druid effects
function wraithdruid()
	return wdrolltable[flr(rnd(6))+1]
end
			
-----------------------------

function moveblock(dx,dy)
if (legalmove(blockx+dx, blocky+dy,currentblock)) then
 blockx = blockx + dx
 blocky = blocky + dy
 if dx != 0 then sfx(6) end
elseif (dy > 0) then sfx(5) bake()
end

end

------------------------------

function legalmove(x,y,block)

-- x and y are 0-based
-- so add 1 to save tokens with array indices
x = x + 1
y = y + 1


-- for each potential cell in block
for bcell = 0,8 do
	local ccell = block[bcell+1] -- contents
	local ccelly = flr(bcell/3) -- y pos in block, 0-based
	local ccellx = bcell % 3 -- x pos in block, 0-based
	
	-- if is a cell
	-- and is oob
	-- or would hit a filled cell
	if (ccell > 0) then
		if ((ccellx + x < 1) 
		or (ccellx + x > 10) 
		or (ccelly + y > 24 )
		or (grid[x+ccellx][y+ccelly] > 0) ) 
		then return false end -- if
	end -- if
end -- for

-- save tokens! merge x/y and extracellx/y into a single value...
x += extracellx
y += extracelly

if (choice == 1) then
	if (x < 1 or x > 10 or y > 24) then	return false end
	if (grid[x][y] > 0) then return false end
end

return true
end

-----------------------------

function rotate ()
-- rotates an array of 16 values
-- representing 4x4 block 

local out = {}

for i = 1,9 do
	out[i] = currentblock[(3-(flr((i-1)/3)))+ (((i-1)%3)*3)]
end

-- temp values for extra cell in "stick"
temprot = ((rotation + 1) % 4)
tempx = rotlist[temprot+1]
tempy = rotlist[temprot+2]

if ( -- 1
		legalmove(blockx,blocky,out) 
		and
		( -- 2
			(choice != 1)
			or 
			( -- 3
				tempx + blockx >= 0 
				and tempx + blockx  < 10 
				and tempy + blocky < 24
				and grid[blockx+tempx+1][blocky+tempy+1] == 0
			) -- 3
		) -- 2
	) -- 1
then
	for i = 1,9 do
		currentblock[i] = out[i]
	end

	-- rotate extra cell
	rotation = temprot
	extracellx = tempx
	extracelly = tempy
	sfx(6)
end -- if
end -- fn

-----------------------------

function bake()
	if tutorial and spawned then tutorial = false end
	for i = 0,8 do 
		if (currentblock[i+1] > 0) then
			grid[blockx+(i%3)+1][blocky+(flr(i/3))+1] = currentblock[i+1]
			currentblock[i+1] = 0 -- hack to not render after being baked
		end
	end
	if (choice == 1) then
		grid[blockx+extracellx+1][blocky+extracelly+1] = blanktile
		choice = 0 -- hack to not render after being baked
	end
	newblock = true
	
	-- spawn player on first bake
	if (not spawned) then 
		sstate = sst_spawning
		sfx(1)
		sstatetimer = 28
		px = blockx+2
		py = blocky+2
	end

end

-----------------------------

function getnewblock()
	
	blocknumber += 1
	
	if (spawned) then	choice = nextchoice end
	
	-- refresh blockbag when low
	if (#blockbag < 3) then 
		blockbag = {1,2,3,4,5,6,7,1,2,5}
	end
	
	-- "echo" potion?
	if potion == 5 then
		nextchoice = echochoice
	
	-- "luck" potion?
	elseif potion == 4 then
		nextchoice = luckbag[flr(rnd(#luckbag)) + 1]
	
	-- neither, get standard block
	else
		nextchoice = blockbag[flr(rnd(#blockbag)) + 1]
		del (blockbag,nextchoice)
	end
	
	currentblock = {}
	
	for i = 1,9 do currentblock[i] = 0 end

	for v in all (blocks[choice]) do 
	
		local t = tileroll()
		
		-- respawn zombies first
		if (needzombie > 0 and flr(rnd(2)) == 1) then
			currentblock[v] = monsterlow + 10
			needzombie -= 1
		elseif t == 1 then
			currentblock[v] = treasuretile
			treasurespawned += 1			
		elseif t == 2 then
			currentblock[v] = monsterlow + monsterdist[floor+1][flr(rnd(4))+1]		
			-- uncomment to force a monster
			--currentblock[v] = monsterlow + 3
		elseif t == 3 then
			currentblock[v] = armourtile
		elseif t == 4 then
		
			pot = potbag[1 + flr(rnd(#potbag))]
			currentblock[v] = potionlow + pot
			del(potbag,pot)
			-- uncomment to force a potion
			--currentblock[v] = potionlow + 3
			potionspawned += 1
		elseif t == 5 then
			currentblock[v] = healthtile			
		elseif t == 6 then
			currentblock[v] = walltile
		else
			currentblock[v] = blanktile
		end
			
		if exitready and exitspawned == false and flr(rnd(10)) == 0 and choice != 99 then 
			exitspawned = true
			if (floor == 9) then
			 currentblock[v] = amulettile
			else
				currentblock[v] = stairsouttile
			end
		end -- if exitready	
	end -- for v
	
	-- add staircase to spawn
	if choice == 99 then
		if currentblock[5] == treasuretile then treasurespawned -= 1 end
		if currentblock[5] >= potionlow and currentblock[5] <= potionhigh then potionspawned -= 1 end
		currentblock[5] = stairsintile
		-- check surroundings
		local contents = currentblock[2] + currentblock[4] + currentblock[6] + currentblock[8] 
		-- if all empty, make a wall, so can see rotation
		if contents == blanktile * 4 then
			currentblock[(flr(rnd(4)) + 1) * 2] = walltile
		-- if all walls, clear one, so not blocked in
		elseif contents == walltile * 4 then
			currentblock[(flr(rnd(4)) + 1) * 2] = blanktile
		end
	end

	-- finalise
	blockx = 4
	blocky = 2
	newblock = false
	timer = delay
	downallowed = false
	
	extracellx = rotlist[1]
	extracelly = rotlist[2]
	rotation = 0
	-- used for drawing/testing 
	-- extra cell on long tetrad
	
	if (legalmove(blockx,blocky,currentblock) == false) then
		-- grid must be full
		sstate = sst_losetetris
		sstatetimer = 64
		sfx(26)
	end	
end

------------------------------
		
function tileroll()
	local out = 0
	while out == 0 do
		out = rolltable[1+flr(rnd(100))]
		if out == 1 then
		 if blocknumber < 4 or exitspawned == true or treasurespawned >= 2 then 
		 	out = -1 --0
		 else
		 	blocknumber = 0
		 end
		elseif out == 4 and (potionspawned >= 2 or (potionspawned == 1 and flr(rnd(3)) != 0)) 
			then out = -1 --0
		elseif out == -1 then
			-- bonus rolls for monster surge and luck potion
			if exitspawned then 
			 if flr(rnd(5)) == 0 then out = 2 end
			else
			 if potion == 4 and treasurespawned < 2 and flr(rnd(40)) == 0 then out = 1 end
			end -- if exitspawned					 
		end -- if out == 1/4/-1
	end -- while
	return out
end -- fn
		
-----------------------------
-- fade function reproduced with thanks
-- from http://kometbomb.net/pico8/fadegen.html

function dofade()
	if (fade < fadetarget) then
		fade += 1
	end	
	
	for c=0,15 do
		pal(c,fadetable[c+1][flr(7-(fades[fade]))])
	end	
end
-----------------------------

text = {
{
 "        - how to play -"
,""
,"rogueris is a mix of two"
,"classic games, both played at"
,"the same time by one player."
,""
,"1) move/drop blocks to create"
,"rooms and corridors to explore!"
,""
," - press ” to rotate a block."
,""
," - press ‹ƒ‘ to move/drop it."
,""
,"2) move   carefully through the"
,"10 floors of dungeonfall, and"
,"retrieve the amulet of lienel!"
,""
," - hold — and press ”ƒ‹‘"
,"   to move around the dungeon."
,""
,""
},
{
 "        - combat level -"
,""
,"making lines from dropped blocks"
,"will eventually increase your" 
,"combat level."
,""
," - lines will only disappear"
,"   if they are clear of items," 
,"   monsters, and adventurers!"
,""
," - remember to position items so"
,"   you can actually get to them!"
,""
,"monsters        have their own" 
,"(shared) combat level; this"
,"goes up automatically over time." 
,""
," - make lines quickly to remain"
,"   on par with the monsters."
,""
,"" 
},
{
"           - combat -"
,""
,"attack monsters by bumping into"
,"them. you will always win, but" 
,"if the monsters have a higher" 
,"combat level than you, you will" 
,"take damage equal to the" 
,"difference in level!"
,""
,"so, if you are level 4 and fight"
,"a level 7 monster, you win, but"
,"will also take (7-4) = 3 damage."
,""
,"many monsters also have special" 
,"rules that affect combat!"
,""
,"potions   may or may not help;" 
,"drunken scholars of dungeonfall"
,"forgot to record their effects."
,""
,""
},
{
"        - progression -"
,"" 
,"you won't be able to see the" 
,"exit down   to the next floor" 
,"of dungeonfall until you steal" 
,"enough gold   ."
,""
,"when you finally exit a floor," 
,"the monsters will lose all of"
,"the xp they gained since the"
,"last time they levelled up."
,""
," - time this to your advantage!"
,""
,""
,"every time you gain a level" 
,"or reach a new floor,"
,"the game will speed up!"
,""
,""
,""
},
{
"     - winning and losing -"
,""
,"if all of your health   is gone," 
,"you will lose the game." 
,""
," - picking up armour   will" 
,"   allow you to soak up damage" 
,"   rather than losing health."
,""
,"if you run out of space to place"
,"a new block, you will also lose"
,"the game."
,""
,"scholars believe that the amulet" 
,"of lienel is somewhere on the" 
,"10th floor of dungeonfall."
,""
,"they also believe that all will"
,"perish trying to retreive it."
,"- will you prove them wrong?"
,""
},
{
"          - credits -"
,""
,""
,"full design / pico-8 version:"
," neil dansey, 2017"
," bbs + twitter: @elneil"
,""
,"initial design / prototype:"
," ollie read + neil dansey, 2012"
," www.oliverread.co.uk/rogueris"
,""
,"special thanks to gena & ollie"
,""
,""
,""
," dedicated to james and bump"
,""
,""
,""
,""
,""
}
}


gameoverrand = 
{
"how unfortunate.",
"ouch.",
"failure seems to be fashionable.",
"we've seen smarter rogues."
}
gameovertext = 
{
"once again, the amulet of lienel",
"remains unclaimed in the depths",
"of dungeonfall.",
"",
"better luck in the next life!"
}
wintext = 
{
"it would appear that the old",
"scholars were too reticent;",
"the amulet of lienel was within",
"reach all along, and brought",
"back home by a humble rogue!",
"",
"",
"",
"become a drunken scholar too,",
"and share its power with us?"
}
__gfx__
0000000011111100111111005555550007777000066666000aaba00009c990000bbbb00080000800044400000ddd000004444000a0000a000dddd00033330000
00000000166661001444410055ddd50075755700777777000bbbbb00cccccd00b0b00b00888888004ff44000d11dd00006666400acccaa0001d1d00078733000
0000000016666100144441005dd115007070070060700700b1b1bb00c767cd001bbbb100a8aa8000f0ff4000d111d00008688600ccccaa000d1ddd0000003000
0000000016666100144441005d1105007707770076666600bbbbbb00d222cd001b00b100888882004ff44000d8181d00076774000c00a1000dddd000b3b3b000
0000000016666100144441005110050007777000677777007b73b000c677cd0011bb110088f8820044444400d1111d000775740044ccc10000ffd000b3000000
000000001111110011111100555555000fd67000066660003333b0000cccd00001dd11002222820094949400d1111d0094776400aacc10000dddd00003b3b300
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111100000000001111110000000000000000000666660000000000000000000bbbb00080000800044400000000000004444000a0000a000dddd00003333000
19a9910000000000155551000000000007777000777777000aaba00009c99000b0b00b0088888800444440000ddd000006666400acccaa0001d1d00007073000
1999810000000000155551000000000077777700657557000bbbbb00cccccd001bbbb100989980004ff44000d11dd00008688600ccccaa000d1ddd0000003000
1a9891000000000015555100000000007070070076666600bbbbbb00c767cd001bbbb10088888000f0ff4000d111d000976774005c55a1000dddd000b3b3b000
1899a10000000000155551000000000077077700677777007b73bb00c677cd0011bb1100888f80004ff44400de1e1d000776740044ccc1000555d000b3000000
1111110000000000111111000000000007777000066660003333b0000cccd00001dd11002222820094949400d1111d0004776400aacc10000dddd0003b3b3000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111100000000001111110000000000000000000000000000000000000000000333300000000000000000000000000000000000000000000000000003333000
1a99810000000000122221000000000007777000066666000aaba00005c550003bbbb30080000800044400000ddd000004444000a000aa000dddd00007873000
1989910000000000122221000000000077777700777777000bbbbb00cccccd00b0b00b00888888004ff44000d11dd00006666400ccccaa0001d1dd0000803000
199a91000000000012222100000000007575570067777700b1b1bb00c767cd001bbbb10098998000ffff4000d111d00008688600cccca1000d1dd000b3b3b000
1a89910000000000122221000000000077077700766666007b73bb00c677cd0011bb11008888800040f44400d7171d009767740044ccc1000dddd000b3000000
1111110000000000111111000000000007777000677777003333b0000cccd00001dd11002222820094949400d1111d004777740044cc10000dddd0003b3b3000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111110000000000111111000000000000000000000000000000000000008000009990000aaaa0006999960078888700099990000aaaa0000000000000000000
189a91000000000013333100000000000000000000000000000000000000080000000900a0000a00966669008777780090000900a0000a000000000000000000
199991000000000013333100000800000099000000aa0000009909000088080000990900a0aa0a00969969008788780090990900a0aa0a000000000000000000
1899a1000000000013333100000000000090000000aaa00000999900008888000099990000aaaa00969999008788880090999900a0aaaa000000000000000000
19a98100000000001333310000000000000000000000000000000000000000000000000000000000966666008777770090000000a00000000000000000000000
111111000000000011111100000000000000000000000000000000000000000000000000000000006966660078888700099990000aaaa0000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
064470000644700006447000064470000644700006447000064470000aaa90000777600007777000077760005555550016c661001818810000d0000008088000
00660000006600000066000000660000006600000066000000660000aaaaa9007777760077777700777776005001150066c66600888889000dd0000088888900
6333b6006e88e6006aa996006555d6006c11c6006ff4460067700600999999006666660077777700666666005011d500cccccc0088888900ddd0000088888900
63b33600688886006999960065d55600611116006444460060000600a55aa9007dd77600777777007dd77600511dd50016c66100888891000110000088889000
6b3336006e8ee6006999a6006d5556006c1cc6006444f60060007600aaaaa9007777760077777700777776005ddd550016c66100188911000010000008890000
06666000066660000666600006666000066660000666600006666000aaaaa9007777760077777700777776005555550011c61100118111000000000000800000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
064470000644700006447000064470000644700006447000064470000000000007aa70000777700006996000d000000016c67100181891000666600008089000
0066000000660000006600000066000000660000006600000066000000000000006600000077000000550000d000000066777700188891006000060008889000
6bb336006888e6006a99a6006dd556006111c6006f44f600670076000000000076666700777777006555560060000000cccc7c00188891006066060008889000
6333360068e88600699996006555560061c116006444460060000600000000007666670077777700655556006000000016c67100188891006066660008889000
6333b6006e8886006a9aa6006555d6006c1116006f4ff6006707760000000000766667007777770065555600d000000016c66100188911006000000008890000
0666600006666000066660000666600006666000066660000666600000006000077770000777700006666000d000000011c61100118111000666600000800000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000
064470000644700006447000064470000644700006447000064470008888890099999a00aaaaab00bbbbb2002222280016c67100111111000777700000000000
0066000000660000006600000066000000660000006600000066000028888800899999009aaaaa00abbbbb00b222220066c76700181891007000070008089000
6b33b6006ee886006999a6006d55d6006cc116006444f60060007600228888008899990099aaaa00aabbbb00bb222200cccc7c00188891007077070008889000
633336006888860069a99600655556006111160064f4460060700600228888008899990099aaaa00aabbbb00bb22220016c66100188891007077770008889000
6b3bb6006888e6006a9996006d5dd6006111c6006f4446006700060028888800899999009aaaaa00abbbbb00b222220016c66100188911007000000008890000
066660000666600006666000066660000666600006666000066660008888890099999a00aaaaab00bbbbb2002222280011c61100119111000777700000900000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111100777777001e1ee100115511007777770017677100000000000000000d000000000000000d000000000000000604449000044490000444900004449000
1122110077777700eeeeef001555510077777700776777000000000000000006000000000000000d000000000000000d49900a0049900a0049900a0049900a00
1122410077777700eeeeef00155551007777770066666600d6dd6dd6dd6dd6dd6dd6dd6dd6dd6dd6dd6dd6dd6dd6dd6d9aa909009aa909009aa909009aa90900
1122410077777700eeeef100115511007777770017677100000000000000000000000000000000000000000000000000a88a0a00acca0a00abba0a00a77a0a00
11241100777777001eef1100115511007777770017677100000000000000000000000000000000000000000000000000a88a0400acca0400abba0400a77a0400
111111007777770011e111001111110077777700116711006dd6dd6dd6dd6dd6dd6dd6dd6dd6dd6dd6dd6dd6dd6dd6dd0aa090000aa090000aa090000aa09000
000000000000000000000000000000000000000000000000000000000000000d000000000000000d000000000000000600000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000d0000000000000006000000000000000d00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000990000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000880800088000000009000090000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000090000000090000000000000000000000000000090000000000aa5a0000000000009959000000
00000000000000000000000000000000000000000000000000090009000090000000000000000000000090000000000000000a0000a000000000090000900000
00000000000000000000000000000000000a0000000000a000000000000000000088000000000000000900000000000000000a0aa05000000000090990500000
000000000000000000000000000000000000000a000000000900000000000000000000000000000000000009900000000000050aaaa000000000050999900000
000000000000000000990000000000900a00000a000000a000900000900000000000000880800000000090099990000000000a00000000000000090000000000
88808888888800889990999999990009a0a0aaaaaaaa0000009099999999000000080888880800000000099000900000000000aa5a0000000000009959000000
00000000000000000000000000000000000000000000000006610661066106610661006106610661616106106161000000616661066161000000000000000000
00000000000000000000000000000000000000000000000061006161666161616161616161616161616161616161000061610610616161000000000000000000
00000088580000000000009959000000000000aaaa00000061006661616166616161616166616161616161616161000061610610616161000000000000000000
0000080000800000000009000090000000000a0000a0000061616161616161006161616161006610061061616161000061610610616161000000000000000000
0000080880500000000009099050000000000a0aa0a0000061616161616106616161061006616161061006100661000061616661616161000000000000000000
0000050888800000000005099990000000000a0aaaa0000061610000000000006161000000006161061000000000000066610000616161000000000000000000
0000080000000000000009000000000000000a000000000061610000000000006161000000006161061000000000000066610000616100000000000000000000
00000088580000000000009959000000000000aaaa00000006610000000000000661000000006161061000000000000066610000616161000000000000000000
777777007777770066666600dddddd00555555001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777007777770066666600dddddd00555555001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777007777770066666600dddddd00555555001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777007777770066666600dddddd00555555001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777007777770066666600dddddd00555555001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777007777770066666600dddddd00555555001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888900999993003333350055555400444448000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
48888800899999009333330035555500544444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44888800889999009933330033555500554444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44888800889999009933330033555500554444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
48888800899999009333330035555500544444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888900999993003333350055555400444448000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06616100066106610661000006100000061000000610000061000000666100000661000066610000066100000661000006100661000000000000000000000000
61006100616161616161000066100000616100006161000061000000610000006100000000610000616100006161000066106161000000000000000000000000
61006100616161616161000006100000006100000061000061610000610000006100000000610000616100006161000006106161000000000000000000000000
66106100616161616610000006100000061000000610000066610000666100006661000006100000061000006661000006106161000000000000000000000000
61006661666166616161000006100000610000000061000000610000006100006161000006100000616100000061000006106161000000000000000000000000
61000000000000006161000006100000610000000061000000610000006100006161000061000000616100000061000006106161000000000000000000000000
61000000000000006161000066610000666100006610000000610000661000000610000061000000661000000061000066616610000000000000000000000000
61000000000000006161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066666661100066666661100066666661166661166661100066666661100066666661166666666661100066666661106c66000000000000000000000000000
00066666661100066666661100066666661166661166661100066666661100066666661166666666661100066666661166c66600000000000000000000000000
000666666611000666666611000666666611666611666611000666666611000666666611666666666611000666666611cccccc00000000000076d51000000000
666d1166661166661166661166661100000066661166661166661166661166661166661100066661100066661100000006c6600000000000076d510000000000
666d1166661166661166661166661100000066661166661166661166661166661166661100066661100066661100000006c6600000000000076d510777700000
d6dd11d6d611d6d611d6d611d6d611000000d6d611d6d611d6d611d6d611d6d611d6d611000d6d611000d6d61100000000c600000000760076d5107666600000
6d6d116d66116d66116d66116d66116d66116d66116d66116d6d6d6d66116d66116d66110006d66110006d6d6d6d661100000000000076d576d5176ddd000000
d6dd11d6d611d6d611d6d611d6d611d6d611d6d611d6d611d6d6d6d6d611d6d611d6d611000d6d611000d6d6d6d6d61100000000000076d576d5176d55000000
6d66116d66116d66116d66116d66116d66116d66116d66116d6d6d6d66116d66116d66110006d66110006d6d6d6d661106c67000000076dd176d76d177700000
d6d6d6611000d6d611d6d611d6d611d6d611d6d611d6d611d6d611000000d6d6d6611000000d6d611000000000d6d6116677770000000766d76d767766677000
dddddd611000ddd611ddd611ddd611ddd611ddd611ddd611ddd611000000dddddd611000000ddd611000000000ddd611cccc7c000051107766777766ddd66700
dddddd611000ddd611ddd611ddd611ddd611ddd611ddd611ddd611000000dddddd611000000ddd611000000000ddd61106c6700000d55111777007dd555dd600
ddd611ddd611ddddddddd611000dddddd611000dddddd611000dddddd611ddd611ddd611ddddddddd611ddddddddd61106c66000006dd555dd70077711155d00
d5d611d5d611d5d5d5d5d6110005d5d5d6110005d5d5d6110005d5d5d611d5d611d5d611d5d5d5d5d611d5d5d5d5d61100c6000000766ddd6677776677011500
5d56115d56115d5d5d5d5611000d5d5d5611000d5d5d5611000d5d5d56115d56115d56115d5d5d5d56115d5d5d5d561100000000000776667767d67d66700000
d5d611d5d611000000000000000000000000000000000000000000000000d5d611d5d61100000000000000000000000000000000000007771d67d671dd670000
5d56115d56110000000000000000000000000000000000000000000000005d56115d561100000000000000000000000006c6700000000055d6715d675d670000
d5d611d5d611000000000000000000000000000000000000000000000000d5d611d5d61100000000000000000000000066c76700000000ddd6715d675d670000
5d56115d5611000d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d6110005d56115d5611000d5d5d5d5d5d5d5d5d5611cccc7c000000066667015d6700670000
d5d611d5d6110005d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5611000d5d611d5d6110005d5d5d5d5d5d5d5d5d61106c66000000007777015d67000000000
55561155561100055555555555555555555555555555555555555561100055561155561100055555555555555555561106c66000000000000015d67000000000
55561155561100000000000000000000000000000000000000000000000055561155561100000000000000000000000000c6000000000000015d670000000000
55561155561100000000000000000000000000000000000000000000000055561155561100000000000000000000000000000000000000000000000000000000
55561155561100000000000000000000000000000000000000000000000055561155561100000000000000000000000000000000000000000000000000000000
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
011000001c0231d000150231f0003c6003a600210001d0003c6051d000210001d0003c6003300023000240001c003210001d000210003c600240001c0031c0003c605210001c0001c0031c0031c0001c0031d000
01040000016130160001600016000260002600176200560007605096000b6000d6001e6201060012600146001760319600276201d6001f6002360024603286002b6052d6002e60033603366033b6003d6033f600
01040000336103d60001600016000260002600126200560007605096002a6000d600176201060012600146001760319600016131d6001f600236000160301600016152d6002e60033603366033b6003d6033f600
011200000224300203012430020300233160000022318000120001800017000170001300017000170001700017000170001700000305003050030500305003050030500305003050030500305003050030500305
000300001c02300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001531026310193101c3101c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001231022310173000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001c02019650166401463012630106200f6200d6100a6100661002610016100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000721003210032100321003210032100f210032103f000162001b2001d2002220000000292002e200332003a2003f20000000000000000000000000000000000000000000000000000000000000000000
00070000290101f0102901030010350103f0103f0103f0103f0003f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090000051111f111001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d00001131311313113130a312033020330200300003000a3000530004300023000030005300043000330002300053000430003300023000530004300033000230005300043000330000300053000330002300
010400001462331613276000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000055240552211521115221152211522115221152211522115221152211522105211052210522105220f5210f5220f5220f5220f5220f5220f5220f5220f5220f5220f5220f5220f5220f5220f5220f523
000c00002241122410220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000000524005220c5210c5220c5220c5220c5220c5220c5220c5220c5220c5220b5210b5220b5220b5220a5210a5220a5220a5220a5220a5220a5220a5220a5220a5220a5220a5220a5220a5220a5220a523
011000000752407522135211352213522135221352213522135221352213522135221252112522125221252211521115221152211522115221152211522115221152211522115221152211522115221152211523
00030000010142a0121f0111e0121e0121c0021d502210021d5021d5021d5021d5021c5001c5021c5021c5021b5001b5021b5021b5021b5021b5021b5021b5021b5021b5021b5021b5021b5021b5021b5021b503
000200001c02019650166401463012630106200f6200d6100a6100763006640096400961009620096100962009610056100661007610076100261002610056100861005600036000360002600036000160001600
000400000a350113101b3102931035310352000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000f520165201b5203340037400184002252027520305203052030520305203052030520305200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000305333053330533305332e5332e5332e5332b5332953327533225331f5331b53316533135330c53303533035330f53300003000000000000000000000000000000000000000000000000000000000000
000100000132004320083200c3201032013320183201f320253202a3202f320383203f3203f3203f3203f3203f3203f3203f3203f3203f3203f3203f3203f3203f3203f3203f3203f3203f3203f3203f3203f320
00200000100111c011100111c011100111c011100111c011100111c011100111c011100111c011100001c000100001c000100001c000100001c000100001c000100001c000100001c000100001c000100001c000
00080000240212b023101031110022000101032000025000100731110022000131032000013103130730000015103151030000013103150730000000000171030000015103170730000000000336003360033603
010f00001d010240102b010300101d010240102b010300101d010240102b010300101d010240102b010300101d010240102b010300101d010240102b010300102900030000370003c0002900030000370003c000
010800000e6161d616296161c6161d6162b6163b616276161361608616146161c6162e616126160e6162e6163b61639616336162d61620616116160f616126161f6160e6162b616376163f6162b6162761626616
000100000a610146100000000000000002b610000000000000000000001b610000000000000000000003061000000000000000036610366102531022310203101c31000000000000000000000000000000000000
01070000220111601022011170102301118010240111c000100001c000100001c000100001c000100001c000100001c000100001c000100001c000100001c000100001c000100001c000100001c000100001c000
011800000441403411024110241200400004020040200402044000340002400004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002b3102b3102b3102b3102b3102b3102b3102b3102b3101f3101f3101f3101f3101f3101f3101f3101f3101f3103f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f300
00010000013000130003300063000b3000f3001830026300323003e3001c300033001e300253001d1001d1003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f300
000100000130004300083000c3001030013300183001f300253002a3002f300383003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f3003f300
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
