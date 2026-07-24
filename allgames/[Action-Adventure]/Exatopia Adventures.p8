pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--exatopia adventures
--by le_gars
--inspired by rolan's curse

--todo:

--line 734
--an end(kinda started working on it)
--better item drop system
--nerf sonic boots
--level up system?
--ennemies dying animation
--collectables?
--add more ennemies???
--map the world

--map color legend
--00:empty
--01:
--02:closed door
--03:dense trees/rock wall
--04:chest
--05:open door
--06:brick wall(with roof)
--07:rock/pillar
--08:ennemy/villager
--09:
--10:brick wall
--11:sparse trees/rock
--12:water
--13:rock wall
--14:
--15:

function _topcuzimlazy()end

function openmenu()
	menu.selectableitems = {}
		for index,item in pairs(itemlist) do
				if(item.qty > 0)then
					add(menu.selectableitems,{index,item})
				end
		end
	menu.open = true 
end

function frnd(n)
	return flr(rnd(n))
end

function _init()
	cartdata("legars_quest")
	--menuitem(1,"inventory",function() openmenu() end)
	
	world = {}

	cam = {
		x = frnd(7818)+128,
		y = frnd(3840)+128,
		state = -1,
		-- game states --
		-- -2 = death
		-- -1 = title
		--  0 = overworld
		--  1 = village
		--  2 = caves
		--  3 = dungeons
		laststate = -1,
	}
	
	palpos = 0 --palette shift position

	dt = 0--deadtime fun stuff
	et = 0--entertime fun stuff
	it = 0--introtime fun stuff

	--save tokens yay
	camx = cam.x
	camy = cam.y

	titleopt = 0--title screen option

	--villagers dialogues
	dialog = false
	dialogtext = ""
	dialogwait = 0
	dialogs = {
		--"111111111111111111111111111\n111111111111111111111111111\n111111111111111111111111111",
		"the swift boots can make   \nyou go really fast. watch  \nout for enemies though!",
		"did you happen to find any \nmaze? i heard many people  \ngot lost in them...",
		"my father used to tell me  \nthat there is a treasure at\nthe end of every cave!",
		"be cautious, monsters are  \ngetting stronger after this\nvillage...",
		"i once saw a knight with a \ngolden armor! was it you?",
		"if only i had more tokens  \ni could buy different clo- \nthes, we all look the same!",
		"some caves have multiple   \nexits, sometime leading to \nsecluded land.",
		"you can use scrolls to get \nback to the last village   \nyou visited.",
		"i heard there was an aband-\nonned village on the north \nwest corner of exatopia.",
		"every resident of exatopia \nknows basic healing magic, \nwe'll all gladly heal you.",
		"i once heard in my dreams  \nthat my progress was saved \nat every village.. whatever\nthat means...",
		"wanna trade?...            \njust kidding i have nothing\nto sell to you..",
		"i have a quest for you!... \n\nnevermind i'll just do it  \nby myself..",
		"i don't have enough tokens,\ni can't move!",
		"i'm so glad there's no evil\noverlord in this world.    \n\njust a couple of monsters.."
	}

	song = -1

	menu = {
		open = false,
		selectableitems = {},
		selecteditem = 0,
		update = function(s)
			if(btnp(5))menu.open = false
			if(btnp(0))s.selecteditem = (s.selecteditem-1)%#s.selectableitems
			if(btnp(1))s.selecteditem = (s.selecteditem+1)%#s.selectableitems
			if(btnp(4))knight.curitem = s.selectableitems[s.selecteditem+1][1]
		end,
		draw = function(s)
			if(menu.open)then
				rect(camx+19,camy+29,camx+111,camy+91,6)
				shade(camx+20,camy+30,camx+110,camy+90,6)
				printc("items (" .. itemlist[menu.selectableitems[menu.selecteditem+1][1]].name .. ")",21,31,7)
				i = 1
				itoff = s.selecteditem*10
				rect(camx+21+itoff,camy+37,camx+30+itoff,camy+46,7)
				for item in all(s.selectableitems) do
					spr(item[2].sprite,camx+12+i*10,camy+38)
					i += 1
				end
				printc("helmet lv." .. knight.harmor,21,48,7)
				printc("armor  lv." .. knight.barmor,21,56,7)
				printc("sword  lv." .. knight.swordlv,21,64,7)
				printc("Ž select - — return",23,84,7)
				printc("press again to pause",25,76,7)
			end
		end,
	}

	entity = {
		hp = 1,
		curhp = 1,
		x = 0,	--x position
		y = 0, --y position
		dx = 0,--direction x
		dy = 0,--direction y
		spd = 1,--speed
		ld = 1,--look direction(1,2,4,8)
		tw = 0,--turn wait
		atk = false, --attack
		atks = false, --attack sound
		aw = 0,--attack wait
		chkpx = 0,--x position on chunk
		chkpy = 0,--y position on chunk
		chkx = 0,--chunk x
		chky = 0,--chunk y
		hsfx = 1,--hurt sfx
		isitem = false,
		--0 : consumable
		--1 : unique item
		--2 : equipment
		itemtype = 0,
	}

	enemytypes = {}--filled later
	addhp = 0--additional hp for levels

	--entity list(enemies, items, villagers)
	entities = {
		list = {},
		--(self,entity,x,y)
		addentity = function(s,e,x,y)--hehe
			newentity = deepcopy(e)
			newentity.curhp += addhp*2
			newentity.ox = x
			newentity.oy = y
			newentity.x = x
			newentity.y = y
			newentity.dx = x
			newentity.dy = y
			newentity.ld = 2^frnd(4)
			if(newentity.isitem)then
				if(newentity.itemtype == 2)then
					newentity.itemid = frnd(3)
				else
					if(newentity.itemtype == 0)then
						newentity.itemid = consumables[frnd(#consumables)+1]
					else
						if(#uniqueitems == 0)then
							newentity.itemtype = 2
							newentity.itemid = frnd(3)
						else
							newentity.itemid = uniqueitems[frnd(#uniqueitems)+1]
						end
					end
				end
			end
			add(s.list,newentity)
		end	
	}

	--filled later
	villager = {}
	pickupitem = {}
	pickupequip = {}

	--item type identifier
	uniqueitems = {1,4,5}
	consumables = {2,3}

	function items()end--bookmark!

	--items list + inventory
	itemlist = {}
	itemlist[0] = {
		name = "nothing",
		qty = 1,
		action = function(s,k)end,
		sprite = 83,
		draw = function()end,
	}
	itemlist[1] = {
		name = "swift boots",
		qty = 0,
		action = function(s,k)
			if(k.dx == k.x and k.dy == k.y)then	
				if(btn(5) == true)then
					--_dev cheat_ 
					--k.spd = 8
					k.spd = 4
					if(band(btn(),15) != 0)k.atks = true
				else
					k.spd = 1
				end
			end
		end,
		sprite = 14,
		draw = function()
			
		end,
	}
	itemlist[2] = {
		name = "teleport",
		qty = 0,
		action = function(s,k)
			if(btnp(5) == true and cam.state != 1)then
				sfx(4,-1)
				k.x = lastvillagex
				k.y = lastvillagey
				k.dx = lastvillagex
				k.dy = lastvillagey
				s.qty -= 1
				cam.state = 0
			end
		end,
		sprite = 13,
		draw = function(s)
		
		end,
	}
	itemlist[3] = {
		name = "potion",
		qty = 0,
		action = function(s,k)
				if(btnp(5) == true and k.curhp < k.hp)then
						sfx(3,-1,frnd(5))
						k.curhp = k.hp
						s.qty -= 1
				end
		end,
		sprite = 28,
		draw = function()
			
		end,
	}
	itemlist[4] = {
		name = "stealth rod",
		qty = 0,
		action = function(s,k)
			if(btnp(5) == true)then
				sfx(3,-1,frnd(5))
				k.hidden = not k.hidden 
			end
		end,
		sprite = 29,
		draw = function()
			
		end,
	}
	itemlist[5] = {
		name = "map",
		show = true,
		qty = 0,
		action = function(s,k)
			if(btnp(5) == true)then
				s.show = not s.show
			end
		end,
		sprite = 31,
		draw = function(s)
			--if(s.show and s.qty > 0 and cam.state < 2)then
			if(s.show and s.qty > 0)then
				palt(0,false)
				if(cam.state < 2)then
					rect(camx+91,camy+3,camx+124,camy+36,15)
					mpal({0,10,11,8,4},{11,6,3,11,11})
					clip(92,4,32,32)
					map(knight.chkx-2,knight.chky-2,camx+88-knight.chkpx+4,camy-knight.chkpy+4,5,5)
					pal()
					pset(camx+108,camy+20,8)
				else
					rect(camx+107,camy+3,camx+124,camy+20,15)
					mpal({0,3,8,11},{4,6,4,7})
					clip(108,4,16,16)
					map(knight.chkx-2,knight.chky-1,camx+96-knight.chkpx+4,camy-knight.chkpy+4,5,5)
					pal()
					pset(camx+116,camy+12,8)
				end
				clip()
				palt()
			end
		end,
	}

	lastbtn = 0
	lastvillagex = 3904
	lastvillagey = 4032

	function knight()end
	--zep add alt+up/down to 
	--functions inside tables pls

	--armor color cap metatable
	cmt = {}
	cmt.__index = function(t,k) t[k] = t[5] end

	lc1 = {6,13,9,0,0}--armor dark
	lc2 = {7,6,10,1,2}--armor light
	hc1 = {1,4,2,6,9}--helmet dark
	hc2 = {13,15,8,7,10}--helmet light

	setmetatable(lc1,cmt)
	setmetatable(lc2,cmt)
	setmetatable(hc1,cmt)
	setmetatable(hc2,cmt)

	--will be merged() in init()
	tempknight = {
		hp = 4,--total health points
		curhp = 4,--current health points
		curitem = 0,--secondary item
		spd = 1,--movement speed
		x = 3904,--x position
		y = 4032,--y position
		dx = 3904,--direction x
		dy = 4032,--direction y
		hw = 0,--hurt wait
		ht = 0,--half tile
		wc = 0,--walk cycle
		harmor = 0,--helmet level
		barmor = 0,--armor level
		swordlv = 0,--sword level
		hidden = false,--used for the stealth rod
		facetile = 0,
		update = function(s)	
					
			local chkx = s.chkx
			local chky = s.chky
			
			--world[(8*chkx)+s.chkpx] = world[(8*chkx)+s.chkpx] or {}
			--world[(8*chkx)+s.chkpx][(8*chky)+s.chkpy] = world[(8*chkx)+s.chkpx][(8*chky)+s.chkpy] or {}
			
			if(not s.hidden)then
			
				curbtn = band(btn(),15)
				if(curbtn != 1 and curbtn != 2 and curbtn != 4 and curbtn != 8)then
					curbtn = curbtn - lastbtn
				else
					lastbtn = curbtn
				end
				
				walking = not move(s,curbtn,s.spd)
				
				--if(not walking)then
				if(checktile(s.chkx,s.chky,s.chkpx,s.chkpy) == 5)then
					if(movedout == true and s.y == s.dy and s.ht == 0)then
						worldpos = {}
						if(world[(8*s.chkx)+s.chkpx+xoff] != nil)worldpos = world[(8*s.chkx)+s.chkpx][(8*s.chky)+s.chkpy]
						if(worldpos != nil)then
							if(worldpos.door == true)then
								et += 4
								if(et >= 132)then
									if(cam.state == 0)then
										cam.state = worldpos.doortype
									else
										cam.state = 0
									end
									s.dx = (s.x+8192)%16384
									s.x = s.dx
									movedout = false
									--printh("hello darkness my old friend")
								end
							end
						end
					end
				else
					movedout = true
					et = 0
				end
				--end
				
				if(walking and (s.x != s.dx or s.y != s.dy))then
					s.wc = (s.wc+1*s.spd)%12
				end		
				
				if(s.aw == 4)then
					s.atk = false
				end
				
				xoff = 0
				yoff = 0
				if(s.ld == 1)xoff = -1
				if(s.ld == 2)xoff = 1
				if(s.ld == 4)yoff = -1
				if(s.ld == 8)yoff = 1
				
				s.facetile = checktile(s.chkx,s.chky,s.chkpx+xoff,s.chkpy+yoff)
				
				if(btn(4) == true)then
					friendly = false
					if(s.facetile == 8 and cam.state == 1 and dialogwait == 0)then
							sfx(3)
							s.curhp = s.hp
							dialogtext = dialogs[frnd(#dialogs)+1]
							dialogwait = 15
							dialog = true
							friendly = true
					elseif(s.ht == 0 and s.facetile == 4)then
						worldpos = {}
						if( world[(8*s.chkx)+s.chkpx+xoff] != nil)worldpos = world[(8*s.chkx)+s.chkpx+xoff][(8*s.chky)+s.chkpy+yoff]
						if(worldpos != nil)then
							if(worldpos.chest == true)then
								entitytype = {}
								if(frnd(2) == 0 and #uniqueitems != 0)then
									entitytype = pickupuniqueitem
								else
									entitytype = pickupequip
								end
								entities:addentity(entitytype,(128*s.chkx)+(s.chkpx*16)+(xoff*16),(128*s.chky)+(s.chkpy*16)+(yoff*16))
								worldpos.entity = true
								worldpos.chest = false
							end
						end
					end
					if(not friendly and dialogwait == 0)then
						if(s.atks and not btn(5))sfx(0,-1,frnd(5))
						s.aw = 8
						s.atk = true
						s.atks = false
					end
				else
					s.atks = true
				end
				s.aw = max(0,s.aw-1)
				s.hw = max(0,s.hw-1)
			else
				s.x = s.dx
				s.y = s.dy
			end
			
			itemlist[s.curitem]:action(s)
			if(itemlist[s.curitem].qty == 0)then
				openmenu()
				menu.open = false
				s.curitem = menu.selectableitems[menu.selecteditem+1][1]
			end
			
			s.hp = 4+(s.barmor*2)+s.harmor
			
		end,
		draw = function(s)
			if(s.hidden)then
				spr(41,s.x,s.y,2,2)
			else
				lfo = 0 --left foot offset
				rfo = 1 --right foot offset
				if(s.wc < 6)then
					lfo = 1
					rfo = 0
				end
				if(s.hw % 2 == 0 or cam.state == -2)then
					if(s.harmor == 1)then
						palt(2,true)
						palt(8,true)
						pal(4,lc2[s.barmor+1])
					end
					mpal({2,8,11,3,13,14},{hc1[s.harmor-1],hc2[s.harmor-1],lc2[s.barmor+1],lc1[s.barmor+1],lc1[s.swordlv+1],lc2[s.swordlv+1]})
					--[[
					pal(2,hc1[s.harmor-1])
					pal(8,hc2[s.harmor-1])
					pal(11,lc2[s.barmor+1])
					pal(3,lc1[s.barmor+1])
					pal(13,lc1[s.swordlv+1])
					pal(14,lc2[s.swordlv+1])
					]]--
					if(s.ld == 1)then
						if(s.atk)then
							spr(5,s.x+7,s.y+9,1,0.9)
							sspr(16,0,16,16,s.x,s.y,16,16,true)
							sspr(56,0,16,8,s.x-14,s.y+8,16,8,true)
							spr(21,s.x-2,s.y+7,1,1,true)
							spr(5,s.x,s.y+9,1,0.9,true)
							spr(22,s.x+8,s.y+7,1,1,true)
						else
							spr(5,s.x+6+lfo,s.y+9,1,0.9)
							sspr(32,0,8,16,s.x,s.y-4,8,16,false,true)
							sspr(16,0,16,16,s.x,s.y,16,16,true)
							spr(5,s.x+1-lfo,s.y+9,1,0.9,true)
						end	
						if(s.harmor > 0)then
							spr(9,s.x,s.y,2,1,true)
						end		
					elseif(s.ld == 2) then
						if(s.atk)then
							spr(5,s.x+1,s.y+9,1,0.9,true)
							sspr(16,0,16,16,s.x,s.y,16,16)
							sspr(56,0,16,8,s.x+14,s.y+8)
							spr(21,s.x+10,s.y+7)
							spr(5,s.x+8,s.y+9,1,0.9)
							spr(22,s.x,s.y+7)
						else
							spr(5,s.x+2-lfo,s.y+9,1,0.9,true)
							sspr(32,0,8,16,s.x+11,s.y-4,8,16,false,true)
							sspr(16,0,16,16,s.x,s.y,16,16)
							spr(5,s.x+7+lfo,s.y+9,1,0.9)
						end		
						if(s.harmor > 0)then
							spr(9,s.x,s.y,2,1)
						end		
					elseif(s.ld == 4) then
						if(s.atk)then
							spr(5,s.x,s.y+8,1,1,true)
							spr(5,s.x+7,s.y+7)
							sspr(32,0,8,16,s.x+10,s.y-12,8,16,false,true)
							spr(22,s.x+9,s.y+1)
							sspr(8,0,8,16,s.x,s.y,8,16,true)
							sspr(8,0,8,16,s.x+8,s.y)
						else
							spr(5,s.x+1,s.y+8-lfo,1,1,true)
							spr(5,s.x+7,s.y+8-rfo)
							sspr(32,0,8,16,s.x+10,s.y-4,8,16,false,true)
							sspr(8,0,8,16,s.x,s.y,8,16,true)
							sspr(8,0,8,16,s.x+8,s.y)
							spr(22,s.x+9,s.y+7)
						end
						if(s.harmor > 0)then
							spr(11,s.x,s.y,1,2,true)
							spr(11,s.x+8,s.y,1,2)
						end	
						spr(22,s.x-1,s.y+7,1,1,true)
					elseif(s.ld == 8) then
						if(s.atk)then
							spr(5,s.x+1,s.y+9,1,1,true)
							spr(5,s.x+7,s.y+7)
							sspr(0,0,8,16,s.x,s.y,8,16,true)
							sspr(0,0,8,16,s.x+8,s.y)
							sspr(32,0,8,16,s.x,s.y+12)
							spr(6,s.x+9,s.y+7)
							if(s.harmor > 0)then
								spr(25,s.x,s.y,1,1,true)
								spr(25,s.x+8,s.y,1,1)
							end
						else
							spr(5,s.x+1,s.y+8-lfo,1,1,true)
							spr(5,s.x+7,s.y+8-rfo)
							sspr(0,0,8,16,s.x,s.y,8,16,true)
							sspr(0,0,8,16,s.x+8,s.y)
							if(s.harmor > 0)then
								spr(25,s.x,s.y,1,1,true)
								spr(25,s.x+8,s.y,1,1)
							end
							sspr(32,0,8,16,s.x,s.y-4,8,16,false,true)
						end
					end	
					palt()	
					pal()	
				end
			end
		end,
		hurt = function(s)
			if(s.hw == 0)then
				s.curhp -= addhp+1
				s.hw = 40
			end
		end,
	}

	shadow = { 0,0,0,0,
											 2,0,5,6,
											 2,4,9,3,
											 1,5,8,4}

	collideable = {3,2,6,7,10,11,12,13}
	
	items = deepcopy(entities)
	
	function enemies() end
	
	--slime lv.1
	enemytypes[1] = deepcopy(entity)
	tempenemytype = {
		curhp = 1,
		update = 
			function(s)
				--current chunk
				s.chkx = flr(s.x/128)
				s.chky = flr(s.y/128)
				
				bbx = flr(s.ox/128)*128
				bby = flr(s.oy/128)*128
				if(s.x <= bbx or s.x >= bbx+112) s.ld = s.ld%2+1
				if(s.y <= bby or s.y >= bby+112) s.ld = s.ld%8+4
				
				if(move(s,s.ld,s.spd))then
					s.ld = 2^frnd(4)
					--if(s.ld <= 2) s.ld = s.ld%2+1
					--if(s.ld >= 4) s.ld = s.ld%8+4
				end
			end,
		draw = 
			function(s)
				spr(64,s.x,s.y,1,2,false)
				spr(64,s.x+8,s.y,1,2,true)
			end,
	}
	merge(enemytypes[1],tempenemytype)
	--slime lv.2
	enemytypes[2] = deepcopy(enemytypes[1])
	tempenemytype = {
		curhp = 2,
		draw = 
			function(s)
				pal(12,8)
				pal(13,2)
				spr(64,s.x,s.y,1,2,false)
				spr(64,s.x+8,s.y,1,2,true)
				pal()
			end,
	}
	merge(enemytypes[2],tempenemytype)
	--stutter slime
	enemytypes[3] = deepcopy(entity)
	tempenemytype = {
		curhp = 1,
		wait = 30,
		update = 
			function(s)
				--current chunk
				s.chkx = flr(s.x/128)
				s.chky = flr(s.y/128)
				
				bbx = flr(s.ox/128)*128
				bby = flr(s.oy/128)*128
				if(s.x <= bbx )s.ld = 2
				if(s.x >= bbx+112) s.ld = 1
				if(s.y <= bby)s.ld = 8
				if(s.y >= bby+112) s.ld = 4
				
				if(move(s,s.ld,s.spd) or s.wait <= 0)then
					s.ld = 2^frnd(4)
					s.wait = 30
				end
				
				s.wait -= 1
			end,
		draw = 
			function(s)
				pal(12,9)
				pal(13,4)
				spr(64,s.x,s.y,1,2,false)
				spr(64,s.x+8,s.y,1,2,true)
				pal()
			end,
	}
	merge(enemytypes[3],tempenemytype)
	--bats
	enemytypes[4] = deepcopy(entity)
	tempenemytype = {
		f = 0,
		spd = 1,
		ax = 0,
		ay = 0,
		hsfx = 5,
		update = 
			function(s)
				s.chkx = flr(s.x/128)
				s.chky = flr(s.y/128)
				
				s.chkpx = flr(0.5+((s.x%128)/16))
				s.chkpy = flr(0.5+((s.y%128)/16))
				
				s.ax = mid(-16,s.ax+frnd(3)-1,16)
				s.ay = mid(-16,s.ay+frnd(3)-1,16)
				
				s.x = s.ax+s.ox+sin(s.f/40)*8
				s.y = s.ay+s.oy+cos(s.f/40)*8
				s.f = (s.f+s.spd)%40
			end,
		draw = 
			function(s)
				if(s.f%5 > 2)then
					spr(70,s.x,s.y,2,1)
					spr(86,s.x+4,s.y+8,2,1)
				else
					spr(86,s.x,s.y,2,1)
					spr(70,s.x+4,s.y+8,2,1)
				end
			end,
	}
	merge(enemytypes[4],tempenemytype)
	
	--villager
	villager = deepcopy(entity)
	tempvillager = {
		update = function() end,
		draw = 
			function(s)
				spr(78,s.x+8,s.y,1,2)
				spr(78,s.x,s.y,1,2,true)
			end,
	}
	merge(villager,tempvillager)
	
	--boss
	boss = deepcopy(entity)
	tempboss = {
		bullet = deepcopy(entity),
		update = 
			function() 
				
			end,
		draw = 
			function(s)
				spr(72,s.x,s.y,2,2)
				if(bullet.curhp!=0)spr(45,bullet.x,bullet.y)
			end,
	}
	merge(boss,tempboss)
	
	--mini-boss
	miniboss = deepcopy(entity)
	tempminiboss = {
		hp = 20,
		curhp = 20,
		update = 
			function(s)		
				if(s.dx == s.x)s.dx = 1-frnd(1)*2
				if(s.dy == s.y)s.dy = 1-frnd(1)*2
				s.chkx = flr(s.x/128)
				s.chky = flr(s.y/128)
				s.x += s.dx
				s.y += s.dy
				
				bbx = flr(s.ox/128)*128
				bby = flr(s.oy/128)*128
				
				if(s.x <= bbx+16 or s.x >= bbx+96)s.dx = -s.dx
				if(s.y <= bby+16 or s.y >= bby+96)s.dy = -s.dy
			end,
		draw = 
			function(s)
				circfill(s.x+8,s.y+8,7,7)
				circfill(s.x+8,s.y+8,4,0)
				rectfill(s.x,s.y,s.x+(s.curhp*16)/s.hp,s.y+2,8)
			end,
	}
	merge(miniboss,tempminiboss)
	
	--pickupitem
	pickupitem = deepcopy(entity)
	temppickupitem = {
		isitem = true,
		itemtype = 0,
		update = function(s)
				--current chunk
				s.chkx = flr(s.x/128)
				s.chky = flr(s.y/128)
		end,
		draw = function(s)
				spr(itemlist[s.itemid].sprite,s.x+4,s.y+4)
		end,
	}
	merge(pickupitem,temppickupitem)
	
	pickupuniqueitem = deepcopy(pickupitem)
	pickupuniqueitem.itemtype = 1
	
	--pickupequipment
	pickupequip = deepcopy(pickupitem)
	temppickupequip = {
		isitem = true,
		itemtype = 2,
		update = function(s)
				--current chunk
				s.chkx = flr(s.x/128)
				s.chky = flr(s.y/128)
		end,
		draw = 
			function(s)
				if(s.itemid == 0)then
					pal(13,lc1[knight.swordlv+2])
					pal(14,lc2[knight.swordlv+2])
					spr(12,s.x+4,s.y+4)
				elseif(s.itemid == 1)then
					pal(11,lc2[knight.barmor+1])
					pal(3,lc1[knight.barmor+1])
					spr(30,s.x+4,s.y+4)
				elseif(s.itemid == 2)then
					pal(11,lc2[knight.barmor+2])
					pal(3,lc1[knight.barmor+2])
					spr(15,s.x+4,s.y+4)
				end
			end,
	}
	merge(pickupequip,temppickupequip)
	
	knight = deepcopy(entity)
	merge(knight,tempknight)
end

saved = false

function _update()
	if(cam.state == -1 or (cam.state == -2 and dt > 140))then
		if(btnp(2) or btnp(3))titleopt = (titleopt+1)%2
		
		if(btnp(4))then
			if(titleopt == 1)then
				knight.x = dget(0)
				knight.dx = knight.x
				knight.y = dget(1)
				knight.dy = knight.y
				knight.harmor = dget(2)
				knight.barmor = dget(3)
				knight.swordlv = dget(4)
				knight.curitem = dget(5)
				knight.curhp = dget(6)
				for i=1,#itemlist do
					itemlist[i].qty = dget(i+6)
				end
				if(itemlist[1].qty != 0)del(uniqueitems,1)
				cam.state = 0
			else
				if(cam.state == -2)run()
				cam.state = 0
			end
		end 
	elseif(cam.state != -2)then
		if(band(64,btn()) == 64 and not menu.open)then
			poke(0x5f30,1)
			openmenu()
		end
		dt = 0
		dialogwait = max(0,dialogwait-1)
		if(menu.open)then
			menu:update()
		else
			if(dialog)then
				if(btnp(4) and dialogwait == 0)then
					dialogwait = 15
					dialog = false
				end
			else
				for e in all(entities.list)do
					if(not e.dead)e:update()
					if(e.chky < knight.chky-1
					or e.chky > knight.chky+1
					or e.chkx < knight.chkx-1
					or e.chkx > knight.chkx+1)then
						world[e.ox/16][e.oy/16].entity = nil
						del(entities.list,e)
					end
					if(world[e.ox/16][e.oy/16].entity and not e.dead)then
						if(wcollide(e.x,e.y,knight.x,knight.y) and knight.hw == 0)then
							if(e.isitem)then
								if(e.x == knight.x and e.y == knight.y)then
									if(e.itemtype == 2)then
										sfx(7,-1,frnd(5))
										if(e.itemid == 0)then
											knight.swordlv += 1
										elseif(e.itemid == 1)then
											knight.harmor += 1
										elseif(e.itemid == 2)then
											knight.barmor += 1
										end
										del(entities.list,e)
									else
										sfx(6,-1,frnd(5))
										itemlist[e.itemid].qty += 1
										del(entities.list,e)
										--knight.curitem = e.itemid
										if(e.itemtype == 1)del(uniqueitems,e.itemid)
									end
								end
							else
								--_dev cheat_
								--if(not knight.hidden and not btn(4,1))then
								if(not knight.hidden)then
									sfx(2,-1,frnd(5))
									knight:hurt()
								end
							end
						end
						local xoff = 0
						local yoff = 0
						if(knight.ld == 1)xoff = -16
						if(knight.ld == 2)xoff = 16
						if(knight.ld == 4)yoff = -16
						if(knight.ld == 8)yoff = 16
						if(btn(4) and knight.atks and not knight.hidden)then
							if(wcollide(e.x,e.y,knight.x+xoff,knight.y+yoff))then
								if(not e.isitem)then
									sfx(e.hsfx,-1,frnd(5))
									e.curhp -= knight.swordlv+1
								end
							end
						end
						if(e.curhp <= 0)then
							e.dead = true
							world[e.ox/16][e.oy/16].entity = false
							--world[e.ox/16][e.oy/16].entity = false
							--item drop rate
							if(rnd(knight.hp+1) > knight.curhp+(knight.hp/3))then
								entities:addentity(pickupitem,(128*e.chkx)+(e.chkpx*16),(128*e.chky)+(e.chkpy*16))
								worldinst(e.chkx,e.chky,e.chkpx,e.chkpy).entity = true
							end
						end
					end
				end
				knight:update()
				if(cam.state == 2 or cam.state == 3)then
					camx = mid((knight.chkx*128)-8,knight.x-56,(knight.chkx*128)+8)
					camy = mid((knight.chky*128)-8,knight.y-56,(knight.chky*128)+8)
				else
					camx = knight.x-56
					--block camera at villages
					if(knight.x < 8192)then
						if(knight.y > 3312)then
							cam.state = 0
							camy = max(3312,knight.y-56)
						elseif(knight.y > 3072)then
							cam.state = 1
							camy = mid(3072,knight.y-56,3200)
						elseif(knight.y > 2288)then
							cam.state = 0
							camy = mid(2288,knight.y-56,2960)
						elseif(knight.y > 2048)then
							cam.state = 1
							camy = mid(2048,knight.y-56,2176)
						elseif(knight.y > 1264)then
							cam.state = 0
							camy = mid(1264,knight.y-56,1936)
						elseif(knight.y > 1024)then
							cam.state = 1
							camy = mid(1024,knight.y-56,1152)
						else
							cam.state = 0
							camy = min(912,knight.y-56)
						end
					else
						camy = knight.y-56
					end
				end
				camera(camx,camy)
				
				if(et == 4)music(-1) sfx(8)
				if(cam.state == 3 and song != 30)then
					music(30)
					song = 30
				elseif(cam.state == 2 and song != 20)then
					music(20)
					song = 20
				elseif(cam.state == 1 and song != 10)then
					music(10)
					song = 10
				elseif(cam.state == 0 and song != 0)then
					music(0)
					song = 0
				end
				if(cam.state == 1)then
					lastvillagex = 56+knight.chkx*128
					lastvillagey = 56+knight.chky*128
				end
			end
		end
		--saving
		if(cam.state == 1 and saved == false)then
			dset(0,lastvillagex)
			dset(1,lastvillagey)
			dset(2,knight.harmor)
			dset(3,knight.barmor)
			dset(4,knight.swordlv)
			dset(5,knight.curitem)
			dset(6,knight.curhp)
			for i=1,#itemlist do
				dset(i+6,itemlist[i].qty)
			end
			saved = true
		end
		if(cam.state != 1)saved = false
	else
		dt = min(dt+2,512)
	end
	
	if(knight.curhp <= 0)knight.spd = 1 music(-1) cam.state = -2
	cam.laststate = cam.state
end

lvlpals = {
	{3,4,5,11,13},
	{1,4,5,13,1},
	{2,5,5,4,13},
	{1,13,0,5,13},
	{1,13,0,5,13}
}

function lvlpal()
	pal()
	if(knight.chkx < 64)then
		palpos = 4-flr((knight.y-1)/1024)
		mpal({3,4,5,11,13},lvlpals[palpos])
	else
		pal()
	end
	addhp = palpos-1
end

movex = 2
movey = 2

function _draw()
	if(cam.state == -2)then
		--camera()
		if(dt < 140)then
			for i=0,7 do
				circfill(camx+8+(i*16),camy+flr(dt/16)*16,dt%16,0)
			end
		else
			for i=0,256 do
				x=rnd(128)+camx
				y=rnd(128)+camy
				c=pget(x,y)
				pset(x+rnd(2)-1,y+rnd(2)-1,c)
			end
			rectfillc(37,19,91,29,0)
			printc("you are dead.",38,20,7)
			rectfillc(44,77,80,95,0)
			printc("abandon",50,78,7)
			printc("revive",50,86,7)
			printc(">",45,78+titleopt*8,7)
		end
		if(dt < 140)knight:draw()
	elseif(cam.state == -1)then
		rectfillc(0,0,128,128,11)
		if(camx >= 7936)movex = -2
		if(camx <= -10)movex = 2
		if(camy >= 3968)movey = -2
		if(camy <= -10)movey = 2
		camx += movex
		camy += movey
		camera(camx,camy)
		smap(camx+56,camy+56,false)
		smap(camx+56,camy+56,true)
		shade(camx+20,camy+15,camx+108,camy+45)
		spr(96,camx+28,camy+20,9,2)
		printc("adventures",34,36,7)
		
		rectfillc(39,74,89,94,7)
		rectfillc(40,75,88,93,0)
		printc("new game",48,78,7)
		printc("load game",48,86,7)
		printc(">",43,78+titleopt*8,7)
		
	else
		--cls()
		if(knight.chkx < 64 )then
			lvlpal()
			rectfillc(0,0,128,128,11)
			pal()
		else
			if(cam.state == 3)pal(4,13)
			rectfillc(0,0,128,128,4)
			lvlpal()
		end
		smap(camx+56,camy+56,false)
		
		if(knight.y <= 1024)pal(5,0)
		if(not menu.open)then
			for e in all(entities.list)do
				pal()
				if(not e.dead)e:draw()
			end
			pal()
			if(knight.y <= 1024)pal(5,0)
			knight:draw()
		end
		pal()
		smap(camx+56,camy+56,true)
		pal()
		for i in all(itemlist) do
			i:draw()
		end
		drawgui()
		
		if(dialog and not menu.open)then
			shade(camx+10,camy+75,camx+118,camy+105)
			rect(camx+9,camy+74,camx+119,camy+106,7)
			printc(dialogtext,11,76,7)
		end
		
		if(et <= 130 and et > 0)then
			rectfillc(0,0,127,et,0)
		end
		
		--_dev_
		--printc(stat(0),1,108)
		--printc("chkpx : " .. knight.chkpx,1,108)
		--printc(stat(1),1,114)
		--printc("chkpy : " .. knight.chkpy,1,114)
	end
end

function drawgui()
	shade(camx+1,camy+1,camx+2+knight.hp*4,camy+8)
	for i=1,knight.hp do
		if(i > knight.curhp)palt(8,true)
		if(i%2 == 0)then
			spr(23,camx-3+(i*4),camy+1,0.7,1,true)
		else
			spr(23,camx-3+(i*4),camy+1,0.7,1)
		end
		palt()
	end
	--item1
	shade(camx+97,camy+113,camx+108,camy+124)
	spr(26,camx+96,camy+112)
	spr(26,camx+96,camy+118,1,1,false,true)
	spr(26,camx+102,camy+112,1,1,true)
	spr(26,camx+102,camy+118,1,1,true,true)
	--item1 sprite
	if(knight.facetile == 8 and cam.state == 1)then
		spr(37,camx+99,camy+115)
	else
		pal(13,lc1[knight.swordlv+1])
		pal(14,lc2[knight.swordlv+1])
		spr(12,camx+99,camy+115)
		pal()
	end
	local i1p = 6
	if(btn(4) == true and not menu.open)i1p = 5
	circfill(camx+97,camy+111,3,i1p)
	circfill(camx+99,camy+111,3,i1p)
	printc("Ž",95,109,0)
	--item2
	shade(camx+113,camy+113,camx+124,camy+124)
	spr(26,camx+112,camy+112)
	spr(26,camx+112,camy+118,1,1,false,true)
	spr(26,camx+118,camy+112,1,1,true)
	spr(26,camx+118,camy+118,1,1,true,true)
	--item2 sprite
	spr(itemlist[knight.curitem].sprite,camx+115,camy+115)
	if(itemlist[knight.curitem].qty > 1)then
		printc(itemlist[knight.curitem].qty,124,109,0)
	end
	local i2p = 6
	if(btn(5) == true and not menu.open)i2p = 5
	circfill(camx+113,camy+111,3,i2p)
	circfill(camx+115,camy+111,3,i2p)
	printc("—",111,109,0)
	--inventory
	spr(26,camx+1,camy+120)
	spr(26,camx+26,camy+120,1,1,true)
	rectfillc(2,121,32,128,6)
	line(camx+4,camy+120,camx+30,camy+120,6)
	printc("inv (p)",4,122,0)
	menu:draw()
end

function shade(x1,y1,x2,y2)
	for x=x1,x2 do
		for y=y1,y2 do
			pset(x,y,shadow[pget(x,y)+1])
		end
	end
end

--check the pixel color at 
--x,y on the sprite on the
--map chunk at cx,cy
function checktile(cx,cy,x,y)
	local curspr = mget(cx+flr(x/8),cy+flr(y/8))
	local sprx = (curspr%16)*8
	local spry = flr(curspr/16)*8
	return sget(sprx+(x%8),spry+(y%8))
end

function wcollide(x1,y1,x2,y2)
	if( x1+16 > x2 
	and x1 < x2+16 
	and y1+16 > y2
	and y1 < y2+16)then
		return true
	else
		return false
	end
end

function collide(x,y)	
	cx = flr(x/8)
	cy = flr(y/8)
	lx = flr(x)%8
	ly = flr(y)%8
	printh(lx .. ":" .. ly .. " - " .. cx .. ":" .. cy)
	if(cx == -1 or cy == -1 or cx == 128 or cy == 32)return true
	tile = checktile(cx,cy,lx,ly)
	for col in all(collideable)do
		if(cam.state == 1 and tile == 8)return true
		if(tile == 4 and worldinst(cx,cy,lx,ly).chest == true)return true
		--_dev cheat_
		--if(tile == col and not btn(4,1))return true
		if(tile == col)return true
	end
	if(knight.hidden and cx == knight.chkx and cy == knight.chky and x == knight.chkpx and y == knight.chkpy)return true
	return false
end

function move(s,d,spd)
	local lastposx = 0
	local lastposy = 0
	local coll = false
	
	local chkx = s.chkx
	local chky = s.chky
	
	local htx = flr((s.x/8))%2
	local hty = flr((s.y/8))%2
	s.ht = bor(htx,hty)
	local ht = s.ht
	
	lastposx = s.dx
	lastposy = s.dy
	
	s.tw = max(0,s.tw-1)
	
	if(s.dx == s.x and s.dy == s.y and s.tw == 0 and et%132 == 0)then
		if(s.ld == d)then
			if(d == 1)s.dx -= 8
			if(d == 2)s.dx += 8
			if(d == 4)s.dy -= 8
			if(d == 8)s.dy += 8
		else
			if(d > 0 and d < 9)s.ld = d s.tw = 3
		end
	end
	
	s.x = mid(s.x-spd,s.dx,s.x+spd)
	s.y = mid(s.y-spd,s.dy,s.y+spd)
	
	local cx1 = (s.x)/16
	local cy1 = (s.y)/16
	local cx2 = (s.x+15)/16
	local cy2 = (s.y+15)/16
	
	local asn = collide(cx1,cy1)
	local bsn = collide(cx1,cy2)
	local csn = collide(cx2,cy1)
	local dsn = collide(cx2,cy2)
	
	if(asn or bsn or csn or dsn==true)then
		s.x = lastposx
		s.y = lastposy
		s.dx = lastposx
		s.dy = lastposy
		coll = true
	end
	
	--position on chunk
	s.chkpx = flr(s.x/16)%8
	s.chkpy = flr(s.y/16)%8
	
	--current chunk
	s.chkx = flr(s.x/128)
	s.chky = flr(s.y/128)
	
	return coll
end

function worldinst(mx,my,x,y)
	world[(8*mx)+x] = world[(8*mx)+x] or {}
	world[(8*mx)+x][(8*my)+y] = world[(8*mx)+x][(8*my)+y] or {}

	return world[(8*mx)+x][(8*my)+y]
end

--custom map drawing function
--cx : chunkx
--cy : chunky
--ab : above player
function smap(cx,cy,ab)
	lvlpal()
	local mxoff = flr(cx/128)
	local myoff = flr(cy/128)
	for mx=-1+mxoff,1+mxoff do
		for my=-1+myoff,1+myoff do
			local curspr = mget(mx,my)
			if(curspr != 0 or mx < 0 or my < 0 or mx > 127 or my > 31)then
				for x=0,7 do
					if(x*16+((mx*128)-cx+64) < 136 and x*16+((mx*128)-cx+64) >= -8)then
						for y=0,7 do
							if(y*16+((my*128)-cy+64) < 142 and y*16+((my*128)-cy+64) >= -8)then
								if((mx < 0 or my < 0) or (mx > 127 or my > 31))then
									if(mx > 63)then
										mpal({8,2 ,10},
										     {6,13,7 })
										spr(43,x*16+(mx*128),y*16+(my*128),2,2)
										lvlpal()
									else
										spr(34,x*16+(mx*128),y*16+(my*128),2,2)
									end
								else
									local sprx = (curspr%16)*8
									local spry = flr(curspr/16)*8
									local curpix = sget(sprx+x,spry+y)
									if(mx >= 0 and my >= 0)then
										drawtile(curpix,x,y,x*16+(mx*128),y*16+(my*128),ab,mx,my,sprx,spry)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	lvlpal()
end

function drawtile(curpix,x,y,sx,sy,ab,mx,my,sprx,spry)
	local msq = 0 --marching square (kinda)
	
	local lp = checktile(mx,my,x-1,y)--sget(sprx+x-1,spry+y)
	local rp = checktile(mx,my,x+1,y)--sget(sprx+x+1,spry+y)
	local tp = checktile(mx,my,x,y-1)--sget(sprx+x,spry+y-1)
	local bp = checktile(mx,my,x,y+1)--sget(sprx+x,spry+y+1)
	lb = false bb = false rb = false tb = false
	if(lp == curpix or lp == 5)lb = true
	if(bp == curpix or bp == 5)bb = true
	if(rp == curpix or rp == 5)rb = true
	if(tp == curpix or tp == 5)tb = true
	--[[
	if(lp == curpix or lp == 5)msq += 1
	if(bp == curpix or bp == 5)msq += 2
	if(rp == curpix or rp == 5)msq += 4
	if(tp == curpix or tp == 5)msq += 8
	]]--
	
	if(not ab)then
		--grass
		if((x+y)%3 == 1 and y%3 != 2 and not menu.open and curpix == 0)then
			envoff = 0
			if(mx >= 64)envoff = 2
			fx = (envoff*2)+1+(x%2+(y%2)*2)
			for i=1,10 do
				palt(i,true)
			end
			palt(fx,false)
			pal(fx,lvlpals[palpos][1]+envoff)
			spr(36,sx+(y%4)*2,sy+(x%4)*2)
			lvlpal()
		--forest
		elseif(((mx <= 63 and curpix == 3) or (mx > 63 and curpix == 13)))then
			spr(34,sx,sy,2,2)
		--chest
		elseif(curpix == 4 and cam.state != -1)then
			if(cam.state == 3)then
				if(worldinst(mx,my,x,y).entity == nil)then
					entities:addentity(miniboss,sx,sy)
					worldinst(mx,my,x,y).entity = true
				end
				if(worldinst(mx,my,x,y).entity == false)then
					if(worldinst(mx,my,x,y).chest == nil)worldinst(mx,my,x,y).chest = true
				else
					drawtile(0,x,y,sx,sy,ab,mx,my,sprx,spry)
				end
			else
				if(worldinst(mx,my,x,y).chest == nil)then
					worldinst(mx,my,x,y).chest = true
				end
			end
			
			if(worldinst(mx,my,x,y).chest)then
				pal()
				spr(33,sx,sy,1,2)
				spr(33,8+sx,sy,1,2,true)
				lvlpal()
			end
		--rock
		elseif(curpix == 7)then
			if(cam.state == 3)then
				spr(46,sx,sy,2,2)
			else
				spr(41,sx,sy,2,2)
			end
		--enemy
		elseif(curpix == 8 and cam.state != -1)then
			if(worldinst(mx,my,x,y).entity == nil)then
				if(cam.state != 1)then
					entities:addentity(enemytypes[frnd(#enemytypes)+1],sx,sy)
				else
					entities:addentity(villager,sx,sy)
				end
				worldinst(mx,my,x,y).entity = true
			end
			drawtile(0,x,y,sx,sy,ab,mx,my,sprx,spry)
		--tree
		elseif(curpix == 11)then
			if(cam.state >= 2)then
				spr(41,sx,sy,2,2)
			else
				spr(32,sx,sy,1,2)
				spr(32,8+sx,sy,1,2)
			end
		--water
		elseif(curpix == 12)then
			--drawtile(0,x,y,sx,sy,ab,mx,my,sprx,spry)
			mpal({8,2,10,7,6,5,13,14,11,3,9,12,1},{12})
			drawrock(lb,bb,rb,tb,sx,sy)
			lvlpal()
			spr(52,sx,sy)
			spr(52,sx+8,sy)
			spr(52,sx+8,sy+8)
			spr(52,sx,sy+8)
		--rock wall
		elseif(((mx <= 63 and (curpix == 13 or curpix == 14)) or (mx > 63 and curpix == 3)))then
			if(cam.state == 3)then
				drawtile(6,x,y,sx,sy,ab,mx,my,sprx,spry)
			else
				mpal({8,14,11,3,10,9,12,1},{6,7,6,13,6,13,7,6})
				--[[
				pal(8,6)
				pal(2,13)
				pal(10,7)
				]]--
				drawrock(lb,bb,rb,tb,sx,sy)			
				lvlpal()
			end
		end
	end
	--wall
	if(curpix == 6 or curpix == 10)then
		if(ab and curpix == 6)sspr(48,24,8,8,sx,sy-8,16,8)
		if(not ab)then
			spr(38,sx,sy)
			spr(38,8+sx,sy)
			spr(38,8+sx,8+sy)
			spr(38,sx,8+sy)
		end
		lvlpal()
	--door
	elseif(curpix == 5 or curpix == 2)then
		rightpix = sget(sprx+x+1,spry+y)
		drawtile(rightpix,x,y,sx,sy,ab,mx,my,sprx,spry)
		--if(((mx <= 63 and (rightpix == 13 or rightpix == 10 or rightpix == 14)) or (mx > 63 and rightpix == 3)))then
		if(rightpix != 6)then
			if(worldinst(mx,my,x,y).door == nil and cam.state != -1)then
				worldinst(mx,my,x,y).door = true
				if(rightpix == 13)worldinst(mx,my,x,y).doortype = 2
				if(rightpix == 10)worldinst(mx,my,x,y).doortype = 3
			end
			pal(11,0)
			if(not ab)sspr(64,16,8,16,2+sx,sy,12,16)
			lvlpal()
		else
			if(not ab)sspr(56,16,8,16,2+sx,sy,12,16)
		end
	end
end

function drawrock(lb,bb,rb,tb,sx,sy)
	paltrock(lb or bb, lb or tb, tb or rb, rb or bb)
	spr(43,sx,sy,2,2)
	palt()
	--[[
	if(msq == 0)then
		paltrock()
		spr(43,sx,sy,2,2)
		palt()
	elseif(msq == 1)then
		spr(43,sx,sy,1,2)
		paltrock()
		spr(44,sx+8,sy,1,2)
		palt()
	elseif(msq == 2)then
		spr(59,sx,sy+8,2,1)
		paltrock()
		spr(43,sx,sy,2,1)
		palt()
	elseif(msq == 3)then
		spr(43,sx,sy)
		spr(59,sx,sy+8,2,1)
		paltrock()
		spr(44,sx+8,sy)
		palt()
	elseif(msq == 4)then
		spr(44,sx+8,sy,1,2)
		paltrock()
		spr(43,sx,sy,1,2)
		palt()
	elseif(msq == 6)then
		spr(44,sx+8,sy)
		spr(59,sx,sy+8,2,1)
		paltrock()
		spr(43,sx,sy)
		palt()
	elseif(msq == 8)then
		spr(43,sx,sy,2,1)
		paltrock()
		spr(59,sx,sy+8,2,1)
		palt()
	elseif(msq == 9)then
		spr(43,sx,sy,1,2)
		spr(44,sx+8,sy)
	 paltrock()
		spr(60,sx+8,sy+8)
		palt()
	elseif(msq == 12)then
		spr(43,sx,sy)
		spr(44,sx+8,sy,1,2)
		paltrock()
		spr(59,sx,sy+8)
		palt()
   else
    spr(43,sx,sy,2,2)
   end
   ]]--
end

--save tokens
function paltrock(r,g,y,b)
	--lvlpal()
	if(not r)palt(8,true) palt(14,true)
	if(not g)palt(11,true) palt (3,true)
	if(not y)palt(10, true) palt(9, true)
	if(not b)palt(12,true) palt(1, true)
	--[[
	palt(8,true)
	palt(2,true)
	palt(10,true)
	]]--
end

--print accounting for camera
function printc(a,b,c,d)
	print(a,camx+b,camy+c,d)
end

--rectfill accounting for camera
function rectfillc(a,b,c,d,e)
	rectfill(camx+a,camy+b,camx+c,camy+d,e)
end

--change multiple colors at once
--if palb length is 1
--every color in pala = palb
function mpal(pala,palb)
	for i,k in pairs(pala)do
		if(#palb == 1)then
			pal(k,palb[1])
		else
			pal(k,palb[i])
		end
	end
end

function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return new_table
    end
    return _copy(object)
end

function merge(t1,t2)
	for k,v in pairs(t2) do t1[k] = v end
end
__gfx__
00000000000000000000000000000000000500000000000000000000000500000000000000888055550000005550000055500000400ccc000aa9999000000000
55500000555000000000005555500000000500000000000000000000005d555555000000088855bbbb550000bb3500005ee5000004f000c00a99977600000000
44450000444500000000054444450000055550000000000000053350555ddddddd50000088855bbbb5b350008bb350005dee50000ff50c0c0044476003b003b0
444450004444500000005444444450005eedd50000000000005bb350005eeeeeeee500008825b5bbb5b5b50088bb350005dee550c05f500c0044777603355330
4444500044445000000544444444500005ed500000055000005bb350005e5555555000008225bb55bbbbbb50888b3500005deee5c005f50c0044776000333300
ff4450004444500000054444ffff500005ed5000003335000005550000050000000000002225bbbb55555500888b35000005de50c0c05ff05544770000333b00
f5ff5000444450000005444fff5f500005ed5000333bb35000000000000000000000000002053bb50000000082bb55000005d5450c000f40445442000003b000
f5ff5000444450000005444fff5f500005ed500005555550000000000000000000000000000053500000000082b350000005505500ccc0045444420000000000
ffff535044450000000555ffffff500005ed50000000000000000000000000000066670055500000000666662bb3000000666600bb3000000000000000000ff0
fff5bbb555550000005bbb5ffff5555005ed500000000000000555000055000005600000bb35000006600000b335000000086000bb300000000280000ffffaaf
555b5330bb3b00000005533555553bb505e5000000555500005bbb500588500056420000b5b350000600000055500000000860003334000000bbbb00f33bbbbf
5335bb35bb35000000053bbbbbb533b5005000000053bb5000b333500588800060042000b5b53500600000000000000000782500099400000b5b5bb0f34bbbcf
bb55bb3533b5000000053bb5bbb555500000000000533b500053bb500058800060004200bbbb3500600000000000000007888250000940000bb5b5b0fbbbcccf
35005550b55000000000555333335000000000000055550000555500000580006000042055553500600000000000000078888825000094000b3333b0fbbccccf
500000005000000000000055555500000000000000000000000000000000500000000042000055006000000000000000788888250000094000333300f3b33ff0
0000000000000000000000000000000000000000000000000000000000000000000000040000000060000000000000000777665000000090000000000ffff000
0000000000000000000500050000000008800000000000006666566600000000000000000000000000000000bbb5766655555aaa00cccc000077766666ddd500
000500000000000000555005505005006640486607777770666d5d66000000000000000000000000000000003335676d556659990c0000c00777666666ddd550
005b50000000000000535053505505007324723575755557d6665ddd0244444002bbbbb000000077d0000000555556d556775555c00cc00c076666666dddd550
005b500000000000053b355335b553505132231077577777555555551555555515bbbbbb000007667d00000066555dd567666567c0cccc0c00665d5d5d555500
05bb650000055555053b35b5353553508218512777777577566666662444444424bbbbbb000066667dd000007675555566665576c0cccc0c000565d5d5d5d000
053bb500005aaaa9533335b533b5335017274241755757575d66666d2444444424bbbbbb000766667ddd00006765555666d55666c00cc00c00056565d5d5d000
0533650005a69555533b533b533b533531550413077777705dddd6661555555515bbbbbb006666667dddd00066d565dd6d5566660c0000c00005656565d5d000
5333b65005a99999533353bb53b353350380663800000007555555552444444424bbbbbb066666667ddddd006d5565ddd556666600cccc00000565656565d000
55333b500569996555335b3b5333b5350007700000000000000000002444444424bbbbbb066666667dddddd0dd567555555d66dd00000000000565656565d000
5353335005a5555a5535333bb53b35350077000000000000000000001555559519bbbbbb6d5666667dddddd055676566765ddd5500000000000565656565d000
5535335005a99955535553333535353507770000006a6a60000000002444449429bbbbbbddd566667dddddd05566655d6d55555100000000000565656565d000
5353535005a9999953543333355353357770000700aa5aa0242424242444444424bbbbbbddddd56667ddddd085d66d55d557751100000000000565656565d000
0535350005a9999905535353553533557000077700600060444244421555555515bbbbbbddddddd666ddddd0e5ddd555557665c100000000007565656565dd00
035553000555955555345554355554550000777000000000242424242444444424bbbbbb6dd56666666dddd085dd55665d6d511100000000077565656565d550
3524453000000000052442244224245000007700006ccc60424442442444444424bbbbbb0666666666666600885556675dd551110000000007776d6d66d65550
0333330000000000555555555555555500077000000ccc00555555551555555515bbbbbb00000000000000008885666655551111000000000077766666d55500
00000000aaaaaaaa3000000030000003000000000000000000000000000000000000055255200000333003330000000000000000000000000000000000000000
00000000aaaaaaaa33000300370000730300003000007000000000000000000000025222222200003000087300b000b003330000033003305550000000070000
000000ddaaaaaaaa380300003000000300000000000000000000d0000d0000000002222222225000300000030b000b00033b0000033003304445000000000000
0000ddccaaaaaaaa3000000037000073000080007008000000011d0011d000000005222d22d25000000000000000000000000000000000004444500000000070
000dccccaaaaaaaa3000000030000003000000000000033000111111111d00000005d2ddddd25000000000000000000000000000000000004444500003300000
00dcccccaaaaaaaa30030800370000730000000000003333011d00110011d0000005dddddddd50003000000300b000b00000033003300330ff44500033330000
00dcc11caaaaaaaa33000300300000030300003000033333000000000000000005d5dd8dd9dd50d0378000030b000b000000333003300330f5ff500033333000
00dcc11caaaaaaaa30000000370000730000000000333333000000000000000055d5dddddddd55d533300333000000000000000000000000f5ff500033333300
0dcccc1cccc00ccc00cccccc00000000000000003330033300000000000000005d1d5dddddd5ddd500000000000cc0000000000cccccccccffff500033333330
0dccc11cccc00ccc000ccccc00000000030000803cc0000300000000000000000115d515555d5110000000b0000cc000000000ccccb00bccfff2250033333300
dccccccccc000ccc0070cccc00500500080000303c000803000dd0000dd0000051dd51155115dd1500000000000cc000008000ccc080000c2222225033330000
dccccccc00000ccc00000ccc0005500000000000300000030011d000011d000051dd55dd1d55dd1500080000cccccccc000007cc000000002222ff5033300000
dccccccc0000cccc000000cc00055000000000003000000300011d0011100000055500511500555000008000cccccccc00000ccc000000002222ff5033000000
dccccccccccccccc0000000c0050050008000030308000c30000111111000000000000055000000000000000000cc0000000cccccc000bcc1111150000000000
05555555cccccccc0080070c000000000300008030000cc3000000110000000000000000000000000b000000000cc000070ccccccc00bccc1144450000080008
00000000cccccccc000000000000000000000000333003330000000000000000000000000000000000000000000cc000cccccccccccccccc5555550000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc000300000003b0000b3
07777777077000007700777777007777777700777777707777777007777777700777777000000000000000000000080000000000000cc0003000000030000003
07666666066700076607666666706666666606666666606666666706666666607666666700080000000000000000000000000000000cc700300707003b0000b3
076000000066000660066600666000066000066000066066000066000066000066600666000cccccccccc000ccccccccccc00ccc000000003000770030000003
076000000066707660066000066000066000066000066066000066000066000066000066000cccccccccc000ccccccccccc00ccc00000000300000003b0000b3
076000000006606600066000066000066000066000066066000066000066000066000066000cc700080cc0000000000000700700007cc0003800000030000003
076000555506606605066000066055066055066055066066000066055066055066000066000cc000000cc0000800000000000000000cc000338000003b0000b3
076770cccc0066600c0667777660cc0660cc0660cc0660667777600cc0660cc066777766000cc000000cc0000000000000000000000cc0003333333330000003
076660dddd0066600d0666666660dd0660dd0660dd066066666660ddd0660dd066666666000cc000000cc000000cc00000000000003333333330033333333333
06d000dddd06ddd60d0dd0000dd0dd0dd0dd0dd0dd0dd0dd000000ddd0dd0dd0dd0000dd000cc000007cc000000cc0000b00008000033333370000833cc00083
06d00000000dd0dd000dd0000dd0000dd0000dd0000dd0dd0000000000dd0000dd0000dd000cc000007cc000000cc70000000b0000003333300000033cc00003
06d00000006dd0dd600dd0000dd0000dd0000dd0000dd0dd0000000000dd0000dd0000dd000cccccccccc000007cc08000000000000083330007000030000000
06d0000000dd000dd00dd0000dd0000dd0000dd0000dd0dd0000000000dd0000dd0000dd000cccccccccc000000cc00000000000000000330000700030000000
06d6666606dd000dd60dd0000dd0000dd0000dd6666dd0dd0000000777dd7770dd0000dd0000000000077000080cc00000b00000000000333000000330000cc3
06dddddd0dd00000dd0dd0000dd0000dd0000ddddddd00dd00000005ddddddd0dd0000dd0800000000000080000cc000080000b0000000033800007338000cc3
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc00000000000000000003330033333333333
330000333300003307000707000000000000033330000003300000033333333333333333aaaaaaaaaaa00aaaaaaaaaaaaaaaaaaaaaaaaaaa3333333333333333
380000733b0000b3007000000000ccccccc003b0300000033000b0033800000000000003ab0000000b0000b00000bbba00000000000000003333333330000003
0000000000000000770ddd0000cccccccccc0bb030300303308b08033000330000003303ab066600000000000000000a00666600006266003333333330773303
000ccb000003b000077d5d000ccccccccccc0000303003033000b0033003300000008303a0062600000000000862600a00626600000000003333333300035300
00bcc000000b3000770000000ccccccccccc008030000003300b00033033000000330003a0008000080000000000000a00000000000000003333333300000000
0000000000000000007070700cccccccccc00000300bb0033000b0033030000300030003a0000000000000000000000a00000000006626003333333330000073
370000833b0800b3070707070ccccccccc00000330000003300b00033000003333000003a0062600626006260062600a0006260000000000333333333cccccc3
3300003333000033700070700cccccccc003030330000003300000033000033333000003a0000000000000000000000a00000000000000003333333333333333
0b00b0b03333333333333333333000000003030333333333333333333000000333300003a0066600000006660000000a000000000000000033333333333cc333
000000000000000330000000300000000083830300033800000000003300003030000003a0062600626006260062600a000000000000000037000073300cc003
0000000000000003300000003040000000000003000000b00000bb003300000030800003a0008000000000800000000a066606600260626030000003300cc003
0000800000bbb0033000333030000000000003330000b00000033b003000800000000003a0066600000000000066660a062602600000000030004003000cc000
00000000008bb0033000033030000000003333330b0000b000b330003000000000003303a0062600626006260062660a000000000626000030000003000cc000
000000000000000330000000308bb00333333333000b000000bb08003300000000003303a0000000000000000008000a00006260000000003cc00cc330000083
00b000b0000000033080080030000003333333330b800000000000003330033000000003a00000000b0000b00000000a00000000000000003cc00cc338000003
333333330000000330000000333333333333333333333333333333333333333333333333aaaaaaaaaaa00aaaaaaaaaaaaaaaaaaaaaaaaaaa3330033333300333
303003030000000330000000000000000000333330000003000000033b0000033333333333333333333003333330033333300333333003333333333333333333
30b00b03033300033008000003300330000003330000000000800003300000b3b0b0b0b33000000330000003380000833700007330700703378000033800ccc3
000000000033000330033330000000800b0000000000080000000c000b0008000b0b0b033cc00073308000033000000330800003300008733800000330000cc3
000800000000080330003380003003000b008000000bb000000ccc0000000000000000833cc0800300007000000770000000000330000000300cc000000000c3
00000000000000033000000003000030000000b0000bb00000cccc0000000000000000833cc0000300070000000000000000000330000000300cc00000000003
000000000080bbbb3000000008000000000000b0008000000000ccb0008000b00b0b0b033cc00003300008033000000330000803308000733000000330000003
30b00b030000bbbbbbbb000003300330333300000000000030000bb03b000003b0b0b0b337000003300000033000000337000073300000033000008330000083
3030030333333333bbbb333300000000333330003000000330000000300000b33333333333300333333003333333333333333333333333333330033333300333
333333333333333333333333ccccccccdddddddd0000000030000003000000003333333333333333333333333330033333333333333333333330033333333333
3cccccc33700007330bbbbb0ccccccccdddddddd0000000c3b0000b3c0000000b0000b3337070703300000733cc00cc33cccccc338000073380000c338000003
3c8008c330033303300ddd00ccccccccdddddddd000000cc30000803ccc00000000400b33c747073300cc8033c0008c33000080330000003300cccc3300c7003
3c0000c330035303300d5d00ccccccccdddddddd00000ccc3b0000b3cccc0000000000003cc00000000c00033c0070c30000000000000000300007c3000cc000
370000733000000330070700ccccccccdddddddd00000ccc30000003ccccc000000000003cc000000000c0033c0700c300000000000000003c700003000cc000
300000033000000330800000ccccccccdddddddd0000cccc3b8000b3ccccc000000000b33c707073308cc0033c8000c330800003300000033cccc0033007c003
300000033000000330000000ccccccccdddddddd0ccccccc30000003cccccc00b0000b3337070703370000033cccccc33cccccc3370000833c00008330000083
333003333330033330000000ccccccccddddddddcccccccc3b0000b3cccccccc3333333333333333333333333333333333333333333333333330033333333333
000000000000070700330030cccccb00cccccccccccccccc0000007000000000dddddddd33300333aaa00aaa00000000333003333303303333033033ccc00ccc
00000000c000000000000000cccccb00cccccccccccccccc00000000d0000070dddddddd300000030000000002600260300000833303303333003003cc000ccc
0b008000cc00080000008300ccccccb0ccccccccc006660c0080000ddd708000dddddddd300000830000066000000000300070030003300000303033cc0333cc
00000000cc00000003003300ccccccb00000000000ba5ab0000000ddddd0000000000000300000036600062602600260000077033303800330383000cc0353cc
000000b0ccc0000000000000ccccc800000000000000000000007dddddd0000000000000300000036260000000000000007700033303033330303000cc0000cc
00800000cccc000000000000ccccc000ccccccccc000000c070ddddddddd7000dddddddd380000030000066002600260300700030000003300303033ccc00ccc
00000000cccccc00cccccccccccbb000cccccccccccccccc00dddddddddddd70dddddddd300000036600062600000000380000033333303330000003ccc00ccc
00000000ccccccc0cccccccc00000000cccccccccccccccc0dddddddddddddd0dddddddd3330033362600000aaa00aaa333003333333303333033033ccc00ccc
3333333333000033000000003333333333333333070000070dddddddddddddd0ddddddddccc00ccc333333333333333333033033330330333303303333333333
00b33b00300000030000800000000000330000330008000007dddddddddddd70ddddddddccc00ccc303330333303030333033033330330333303303333333833
000330000000000000ccccc000333000300ddd0300dddd00000ddddddddddd00dd0666ddccc00ccc300000003000000000033000000080000003000000000000
00008000000b80000cc4bcc000333300000d5d0000ddddd000007ddddddd7000000a5a00ccc00ccc3330333333033833333cc333300330333333303333833333
000800000008b0000cc0000000003330000000000ddddd00000000ddddd8000000000000ccc00ccc3033330330033333333cc333333300333800000333033333
00033000000000000ccccc8000008333000000000ddd08000080007ddd700000dd7007ddccc00ccc380000003300000000033000000330000033330000033000
00b33b003000000300cccc0000000033000000000000000000000000d0000000ddddddddccc00ccc333330333333303333033033330300333000333333033033
3333333333000033000000000000000300000000000000707070000000000000ddddddddccc00ccc333330333333303333033033330330333333333333033033
000000b333333333bb0000bb00007ddddd0000dd00000ddddd000ddddddd00dd33333333cccccccc33033033330333333333333333033033330330333cccccc3
0000000300000000b000000000000dddd000008d00000dddd0000dddddd8000d3c0000c3cccccccc33030033330333333333333333033033330330333c0000c3
070008b300000800000000800dd0008d000000000008000d008000dddd0000003c0400c3cccccccc30033000000000000000083300003033300030003c4004c3
0000000300007000008000000dd00000000dd00000000000000000000000000000000003cc0353cc30333333333338333333303333333003330033333c0000c3
000700b3000700000000000000800000000d700000000000000000000000770000000003cc0000cc38033033338333333333303333038003333033333c0000c3
0000000300800000000000b000000000000000000dd00000dd000800000000003c0000c3cc000ccc303300000000000000000033000003033800000033077033
700008b30000000008000bb3dddd0000d800000d0ddd0000ddd0000ddd00000d3cc00cc3ccc00ccc300003333333303333033033333333033303333333033033
00000003333333330000bb33dddd7000dd0000dd0ddd0000ddd000dddd000ddd33333333ccc00ccc333333333333333333033033333333333333333333033033
330000333333333330000003cccccccccccccccc0000000000000000000000003330033333300333330330333330033333333333333003333330033333333333
3000000330b0b003330000830cccccccccccccc00000000000000000000000003000000338000073330330333000000333000333300000833300003333338303
000ddd000000800033b000330000cccccccccc000bb000b00000000000066600370000033000000333000000300330033c400803300000033003300300000003
000d5d000000000038000b3300000cccccccc0000000000000000000000a5a003070000330cc000000033833300353033c000000000000030003530033330333
000707000000000030000b33000000cccccc00000000000000000000000000003700400330cc000000033033300000033c000000000800030000000033330333
000000000008000033b000330000000cccc0000000b00bb00000000000000000300000733000000333333000300000033c408003300000033700007300000003
30000003300b0b03330000830000000ccc0000000000000000000000080000003707070338000073330000333700007333000333300000033370073333033303
3300003333333333300000030000000cc00000000000000000000000000000003333333333300333330330333333333333333333333003333330033333333333
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4135418b87a49588809588a48ed48e4b4d4b83b3b3b3b3b3b3f4f5f3b38ea99244a09554454f817c91b4b4b4b4b4b4e7b4b4d7e5c4c4c8d5d6b4b4b4b4b4b4b48eb18e8e8eb3b3b3b3b3b3b3b3e9b3b3b3b38eda8edbebec8e9ee9b3b3b3b3b3b3b38e8eaebcaf8e8e8e8e8e8eb3b3b3b3b3b3b3b3b38e8e8e8e8e8e8e8e8e8e
89f58d9b858e9281988781a38e438e4c4b4cb3b3f4f5b29291a4a64f4baeabaabc9faf8e9eb29045a68eb4b4d7d5e3e6e4c8f7b4b3b3b4b4c7c8e3e6b4e3d2b48e438e8e8e8e8e8eb3b3b3b3b3d9b3b3b3b3dacddfce8ffa8ef9fdb3b3b3b3b3b3b3b38ebeb1c98e8e8e8e8e8eb39e9e9eb3e9b3a9b38e8e8e8e8e8ea9b9bdaf
41999c9d988ea2a0a86e988096a7914d5fb5b3b3c0455a4ba7948eaeabac8eadbdacf9bcfd8ea98e5a88b0d7c6b4b4b4c7d6b4b4b3b38796d0e5e6d5d6c6b4b48e438e8edbdfec8e8e8eb3b3f4f652b3b39edbedeadddecdec43f8b3b3b3f9c4c4c4e88eadacbe8e8e8e8e8e8eb39ccb9db3adbdabaaaf8e8e8e8e8eadbf9ffd
8e8e8e8e8e8e8e6f8e8e8ea381e1e0f544c4c45d54444c429695bcaa96cefadedf7fabbaadbc4aba8ead4a558e8e8e8e924b8eb3b3b3a7a987c8e7e3e3c8d8b48e438edadddccdec8e8e8eb3444d44b3b9aafaff8ece9ffaedcddfecb3aeaa7ec2afb38ef99ffd8e8e8e8e8e8e8e8e438e8e8eaee8bbbe8e8e8e8e8eaebcfecc
8e8e5f7c44457d8095838498a5e2d17cc052b3b3c14d7c5cb3b3b3d9b3b3c1dcddefdadfff7faa9fbd7eab4a915ff57db66e5ab3b3f4e290a1b4b4e5e4d6b4b48e438eeacdcddeed8e8e8eb3b754b5b3b3fbdd8edbcdbbcd8eeedcddb3bebb6b5b6cb37fabaacc8eb08e8e8e8e8e8e438e8e8eadbdbcfddbec8e8efcabbdaaac
b4b44b5ac68e828196879495a086b687a7a6b3b3b3b7b5b3b3f4a6c0f3b3b3b7facddfdcebcefdadafbb8ebea24c4b54864342c4c4a0e0918e8eb4b4d6c6b48e8e438eefeece8fba8e8e8eb3b36cb3b3b3dbdd8ecdddcddedddf4dcdb3ad4d9f6db3b38e8ef8bb7f7ebf8e9e8e8e8e438e8e8e8e8eb3f9fadcdd8e8e8e8ebb8e
b4d783b7b48e92a5919795a5a6a1a29690a5f3b3b3b3b3b3f4f5e2a7f5f3b3b3c1cddddecdde4244c04ba9aaaf6f4f446fa2b5b3b35aa44ba3a6888ef8458e8e8e438eeecddcdfec8e8e8eb3aeabaf8e8e8eeaebcded8eeadeebedb3b3b9f3d97a52b38e8e8e8e8ef99f4ac98e8e8e438e8e8e8e8eb3d9b3eecdb88e8e8e8e8e
b49352b3b48ea290a18e8e8e858e8e8e8e8e8eb3b3b3b3b37c90a4a55ab5b3f7b3b7deebed8e8e7c4bf78198bb6f425a7c5cb3b3b3444da54db5b77d5f4b8e8e8e438e8eeeebdeed8e8e8e8ead9fac8e8e8e8e8e8e8e8e8e8e8e8eb3b3b383cfb744b38e8e8e8e8eadfeaf558e8e8e438e8e8e8e8eb3d9b38e8e8e8e8e8e8e8e
b4b4b4b3b44141414141898d8a8c8b4141414141b3b3b3f4898d8d8a8bb3b3d9b3b3b3b3b3b3b3b3b3b3b3b3898a8bb3b3f452b3b3b3898a8bb3b3b3b3b3b38ef6f6f68e8e8e8e8e8e8e8e8e8e438e8e8e8e8e8e8e8e8e8e8e8ef99fafb352d9f4b5b38e8e8e8e8e7fabaa7e8e8e8e438e8e8e8e8eb3d9b3b3b3b3b3b3b38e8e
b4b3b3b3b44141414141999c9a9d9b414141414141b3b3c19c9a9d9c9dc4c451b3b3b3b3b3b3b3b3b3b3b3b3999a9bb3b3d244c4c4c49d9a9bb3b3b3b3b3b38ef6f6f68e8e8e8e8e8e8e8e8e8e438e8e8e8e8e8e8e8e8e8e8e8ea9bed9b3c1c25cb3b38e8e8e8e8e8e8e8e8e8e8e8e438e8eb3b3b3b3cfb3b38e8e9eae9faf8e
b4b3b4b4b4b4c79187a4957d43879691925a88d2bc52b3b35aa55aa7f7b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3d9b3b3b3b3b3b3b3b37ca5f3b3c352f4f0b38e8e8e8e8e9e8e8e8e8e8e8e8e87a3888e8e8e8e8e8e8e8e8e8e8eadaccfb3b3b3b3b38e8e8e8e8e8e8e8e8e8e8e8e8e438e8eb38eb3b3b3b38e8e7ffdf9fecc8e
b4b384b4b4b4d75ae2887f4b544ca3a742b6e0aed35af3b3c17cf57cb5b3f4454fa390a4a5f3b3b3f4c044e14be0a97cae52b3b3b3b3c042a47df544e04b52b38e8e8e7ecc8e8e8e8e8e8e8e97d3988e8e8e8e8e8e8e8e8e8e8eaee8d9b3b3b38e8e8e8e8e8e9e8e8e8e8e8e8e8e8e438e8eb38ea9aeaf9f8e8e8eadbfaaac8e
b4b4c7d6b4e47cc6c75ad05aa5444be1d0a6bb6fad98f5b3b3b3d9b3b3f4547d5ff5a5a04b7cc4c45a45e254f26fa77e818384c4c5b3c14496975445945af2b38eaebdabaa8e8e8e8e8e8eb9bfaabc8e8e8e8ea9aebaa98e8e8eadbcccb3b3b38e8e8e8ebef9ab8e8e8e8e8e8e8e8e438eb3b37ffeaaaaaa8e8e8e8eae4abc8e
d75ae3e5e7c0c6b4b4c77c42c07ce087a78195d191e2a552b3f44d7b796b6c6aa083b7c25cd9b3b3b74bf5d0914da5a67c9394b3b3b3b35a92a67c9596baa5b38e7eaf8efd8e8e8e8e8e8e8e8ef88e8e8e8e8eaaccaefd9e8e8e8e8ebbb3b3b38e8e8e7f4afdc98e8e8e8e8e8e8e4d434db3b38ebbc9bbc98e8e8e8ebbabbd8e
c7f7d5b4e6e4b4b4b4d7456ef545a1975aa0baf0978190918e924b4454448679b3b3b3b3b3f0b3b3b3b77c88a2d1f1f04f7df5d0c45dc4a498bb43a7d3d17cb3b3fbf94a7eba8e8e8e8e8e8e8e8e8e8e8e8e8efefdbead7ee88e8e8e8eb3b3b38e8e8e8eabaaac8e8e9e8e8e8e8e4dfe4db3b38e8eadfac28e8e8e8e8e8e8e8e
b4b4b4b4d75ad6b4b4b48e8e8e8e8e8e8ea58e8e8e8ea2a3e180a64bd0f14d5cb3b3b3b3b3b3b3b3b3b3c1a7a5a68e8e8e97988eb3b3b38e8e8ea5a3c0f65cb3b3b3b3bec98e8e8e8e8e8e8e8e8e8e8e8e8e8eadf9fd8e558e8e8e8eb3b3b3b38e8e8e8e8ecfa98e8ef9bdcc8e8e4d4d4db3b38e8edadcdfef8e8e8e8e8e8e8e
414141898c8a8b4141414141414141418c8a8b4141414141414141414189ca8b414141b3b3b3b3b3b3b3b341898a8b4141414141b3b3b34141898a8b41414141b3b99faaac8e8e8e8e8e8e8e8e8e8e8e8e8e8e8eabac7fac8e8e8eb3b3b3b3b3b38e8e8e8ead4a8ebffd8ec98e8e8e8e8eb3b38e8eeecefadeec8e8e8e8e8e8e
414141999a9cf54141414141414141999d9a4141414141414141414141999a9b414141414141414141414141999a9b414141414141b3b34141999a9b414141418e7f7eab8e8e8e8edfdccda98e8e8e8e8e8e8e8e8e8eb3b3b3b3b3b3b38e8e8eb3b3b38e8e8ebb8ea9c98e8e8e8eb3b3b3b3b3b3b3b3b3eaebcd8eae9fbdaf8e
b3b3b384a5d34ca7f1bfbdbc9fd1888e8e858e8e8e8e8e8e8e8e8ed48e8e855f7d8e8e8e8e8ec08e8e8e8e8e8e6f8e8e8e8788d48eb3b38e8e92a58e8e8e8e8e8e8ebb8e8e8e8e8eeacdcefd8e8e8e8e8e8edadfec7f9fafb3b3b3e9b38e8e8eb38eb3b3b3b3b38ef9aaaf8e8eb3b3b38ea9a9e9a9a9b3b38e8e8ef8f9bdcc8e
b3b3f4d197a588f887bca7d4907c4b918e868e4b4df75fc0f57d925a6d7c44a5b5b7918e8e8eddecf7a38e877c4b8e80a4907ca792c4c47d8e85b68e8e8ef78e8e8e8e8e8e8e8e8eb9faebfb8e8e8e8e8edbcdeecefeabacb3b3b3d9b38e8e8eb38e8e8e8e7f9faafe8ebb8eb3b3b38e7faaaaab7e7ebab3b38e8e7faabcfe8e
b3c37cf57faaaca9817facf296a7a1a2a4a78e7ca5887c83b7696c6b5b6b6b6bb3b397e08eb8facdcddd8e44986e96a5c07cf285a5b3b3c17c4fa0888ea9858e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8efcfadddfedbb8e8eb3b9afaab38e7fbf9faf9e8e8e8eadabac8e8eb3b3b38e8eb9aaaabc7e7ebab3b3b38e8eadbdfd8e
b3c1c0a64bc9aeaaac92967cc095a88e8e6e95986fa7b5b3b37aa6c07ba080e0b08e8ef58e8ecdebdccebd4c969181a48e4dc081b5b3b3b3b7f1d1a395a7868e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8ecd8e8e8e7fbd9facbeb38e8eaefdadac8e8e8e8e8e8e8eb3b3b38e8e8e8ebbbb8ebbbb8e8eb3b3b3b38ebdac8e
b35d5ad0a7fdf9ac8e8587a397a7a0838496a0908081c45dc4e2c07c6da6a5c0f09596a7888eeadfed8e8e9795a3814f7d5ff5b5b3b3b3b3b3b3c14d4ba590918e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8ead7eabba8e8ebbfb8e8e8e8e8e8e8e8e8eb3b38e8e8e8e8e8e8e8e8e8e8e8e8eb3b3b3b3b3b38e
b3b3c190e2adaba096a798a54c4ba293947fa5a88ef5b3b3c37c81d17bc0a7d1bb8e8e97988e8ea68e8e8e8e8ea58e8e975a83b3b3b3b3b3b3b3b3b3b77cd4988e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8eb3b3b3b3b3b38e8e8ebb8e8e8e8e8e8e8e8e8e8e8ec9a9ae8eb3b38e8e8e8e8e8e8e8e8e8e8e8e8e8eb3b3b3b3e9b3
b3b3b34141414141418a414141414141414141898c8a52b34141414141418a41414141414141414141414141898a8b414141b3b3b3b3b3b3b3b3b3b3b3b3b3b38e8e8e8e8e8e8e8e8e8e8e8e8e8e8e9ea9b3aeba8e8eb3b3b38e8e8e8e8e8e8e8e8e8e8e8e8eaa7eaaafb39e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8ed9b3
b3b3b34141414141999a9b414141b4b4b44141999a9c5cb3414141414141cb414141414141b4b4b4b4414141999a9b414141b3b3b3b3b3b3b3b3b3b3b3b3b3b38e8e8e8e8e8e8e8e8e8e8e8e8e8e8ead7e9fcc8e8e8eb3b3b3b3b38e8e8e8e8e8e8e8e8e8e8eadfdbbad9fac8edbdfec8e8e8e8ea98e9e8e8e8e8e8e8e8ed9b3
b3b3f4a58e8e9e8e8e4b5a918eb2c8d6b4d4faec4b7c4f81c0a090a6bc4a4496918e8e8eb4d7e7d8b48e8e8e8ea58e8e8ea0a7c4c480c0e1e2a37cf3b3b3b3b38e8e8e8e8e8e8e8e8e8e8e8e9eb18e8e8ebbfb8e8e8e8eb38e8eb3b3b38e8e8e8e8e8e8e8e8e8efb8e7fac8eaefaddebec8e8e8ebeaeac8e8e8e8e8e8e8ed9b3
b3b34b4d8e8e82bdba8e8e86a5c6b4c7d6b4eedfce445fc6c7a7b0a095a5a081988e92d6b4c7c6b4b4b48e8ef0868ea7a381b5b3b3c17c8ea381f5f58e92d4b38e8e8e8e8e8e8faf8e8e8e7f4abe8e8e8e8e8e8e8e8e8eb38e8e8e8eb38e8e8e8e8e8e8ea98e9e8e8e8e8e8efbeacd8ecee88eadaaac8e8e8e8e8e8e8e8efbb3
b3b3b77c7d8e8e8e8e8e4c7cc6b4796c6bb4eecd4c5ac6b4b4b2a3818e80b64d8eb2c6c7e6d5e3e7d6b48eaef5a795a68ec0b3b3b3b3b7c08e868e7ca5c0b5b38e8e8e8e8eae9faa8e8e8e8e55c98e8e8e8e8e9e8e8e8eb38eb18e8eb38e8e8e8eb18e8eadaaabb3b3b3b3b38edbde8e8e8eb3aeccb3b3b3b3b3b3b3b3b3b3b3
b3b3b3c1c0d48e92a0884bc0c8c8e6e4e3e5b48ec0c7d5e5d6c7e08e92a4818384a0b4b4b4c7e5c682bc968180885f4f87c2c4c4c5b3b3c1b88092a7e2b5b3b38e8e8e7fcce9c98e8e8e8e8eadfd8e8e8e8eaeac8ea9b99fbfcc8e8eb39e8e8e8eadbdbcbfabbf9f8fba8eb3b38e8e8e8e8eb3bbcfb3b3b3b3b3b3b3b3b3b38e
b3b3b3b3b77c924b95a7e2c6b4b4c7d5c6e4c8bdc2b4d8e3c6b48e8e41418a4141a1b4b4b4b4b4b4b4b48ea7a3a64593b5b3b3b3b3b3b3b3b7a5b5b3b3b3b3b38e8e8e8eadabac8e8e8e8e8e8ebb8e8e8e8ead9fbcab8fadbcac8eae9facb08e8e8e8e8e8e8e8ebb8e8e8e8eb3b3b3b3b3b3b3b3adbcbdba8e8e8e8e8e8e8e8e
b3b3b3b3b3b7b5b38e8e8eb4b4b4b4b4b4b4b4b3b3b4b4b4b4b48e8e41829d9c418eb4b4b4b4b4b4b4b48e8e8e8e8e8eb3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b38e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8ebb8e8e8e8e8e8e8eadab8fac8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e
__sfx__
000100001a630196301663015630176301d63024630276302863026630216301c630166301063008630016000160008600066003a600316002f600216001a60026600136003d6000b6003760004600326002a600
00010000151701317011170101700f1700f1701017013170161701b1701e17022170271702a1702a1702a1002b1002b1002b1002910028100271002410023100211002010020100201001f1001e1001e1001d100
000100002007025070270702907029070280702507020070180700f07007070020700107000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000095700957008570075700757005570055700457004570035700357003570035700357003570035700457004570045700557006570085700b5700d570105701357016570195701a5701b5701c5701c570
0001000002570045700857004570085700a5700b5700b570085700a5700c5700f5700b5700a5700c570115700d57011570145700f5701157017570125701657013570185701b5701f5701d570205702257020570
010100003f0403f0403e0403e0403c0403904032040290402004016040100400a0400704005040040400204001040010400100003000030000400004000040000500005000050000500006000060000700008000
000100000f5700f5700f5700f5701057012570135701557016570185701a5701c5701d5701e5700f50010500125002b5702b5702b570215001e5001f50021500165000f5002e5702e5702e570145001650017500
000100000955009550095500a5500b5500d5500f5501255015540175301b5201e5001f5001c5001a50017500165001652017540195501b5501d5502050024500285202b5302e5502f55030550315303151031500
0106000024655236512465513600000000000000000000001c6551a6511c6551a6001c60000000000000000015655136511565500000000000000000000000000e6050c6010e6050000000000000000000000000
000300000d75412754167541a7541975416754127540e7540c7540e75412754177541c7541f754207541f7541c75417754117540f7540f75411754197542075423754257542675425754237541f7541975411754
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800101562015615000001560015620156151562015615156201561515600156001562015615156201561500000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f05000000180001805018050180501804018040180201801000000240002405024030240002200022050240502205024050220502404022040240202201000000000000000022050220200000000000
011000002105000000000001d0501d0501d0501d0401d0401d0201d01000000000001d0501d0501d0301d010200502005020030200101d0501d0501d0301d0101f0501f0501f0501f0501f0301f0201f0101f000
010c00001561500605000050000515605006050060500605156150060500605006051560500605006050060515615006050060500605156050060500605006051561500605006050060515605006050060500605
01100018130300000000000180301c0301f0001f0301f0001c0001c0001c030000001a030000001a0001800018030000001a03000000000000000000000000000000000000000000000000000000000000000000
011000181803000000000000000018030000001a0300000000000000001a030000001c0301c000000001f0001f0300000021030000000000021000000001f0001c0001a000000001a00000000180000000000000
011000182103000000000001f0301c030000001a030000001a0001a0001a0301a0001803018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800201a7701a7001a7701a7001a7701a7001a77019700197700000019770000001977000000197700000019760000001975000000197400000019730000001973000000197200000019710000001971000000
01180000000000000000000000000000000000000000000000000000000000000000000000000000000000000c6000c6000c6000c600106001060010600106001360113601136011360113611136211363113641
01180000157700000019770000001d770000001a770000001c7700000018770000001a77000000177700000018770000001577000000177700000014770000001777017700147700000017770147001577000000
01180000157700000018770000001a7700000018770000001a7700000017770000001877000000157700000017770000001577000000177700000018770000001777000000157700000014770000001777000000
011800001305513055130551305513055130551305513055110551105511055110551105511055110551105515055150551505515055150551505515055150551005510055100551005510055100551005510055
01180000000040000000000000001c0741a0041a07400004230042100421004000041c074000041d07400004000040000400004000041d0741a0041a07400004000040000400004000041a074210041f07400004
011800000000000000000001c0111c0311c0511c0711c0710000000000000001a0111a0311a0511a0711a0710000000000000001d0111d0311d0511d0711d0710000000000000001a0111a0311a0511a0711a071
010800200c0500c03000000000000c050000000c05000000130501303000000000000c050000000c050000000c0500c03000000000000c050000000c05000000130501303000000000000c0500c0000c05000000
011000002105000000000001d0501d0501d0501d0401d0401d0201d01000000000001d0501d0501d0301d01020050200502003020010240502405024030240102205022050220502205026040260402602026010
01100000280502805028040280402803028030240502605028050280202900029050290202b0002b0502b0202b0502b0202900029050290200000028050280202905029040290302902029010290100000000000
011000002805028050280502804028040280402803028030280302802028020280202801028010280102801028000280002800028000280002800028000280002900029000290002900029000290000000000000
0108002013050130300000000000130500000013050000001305013030000000000013050000001305000000130501303000000000001305000000130500000013050130300e00000000130500c0001305000000
0108002015050150300000000000150500000015050000001505015030000000000015050000001505000000150501503000000000001505000000150500000015050150300e00000000150500c0001505000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000c0300c0300c0300c0300c0300c0300c0300c0300c0300c0300c0300c0300c0300c0300c0300c0300c0300c0300c0300c0300c0300c0300c0300c0301303013030130301303013030130301303013030
010c00001003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301503015030150301503015030150301503015030
010c0000150301503015030150301503015030150301503013030130301303013030130301303013030130300c0300c0300c0300c0300c0200c0200c0200c0200c0100c0100c0100c0100c0100c0000c0000c000
011800201305015050160501305015050160501305015050160501305015050160501305015050160500000012050140501505012050140501505012050140501505012050140501505012050140501505000000
011800001305015050160501305015050160501305015050160501305015050160501305015050160501500015050170501805015050170501805015050170501805015050170501805015050170501805000000
011800000275002750027500275002750027500275002750027500275002750027500275002750027500275000750007500075000750007500075000750007500075000750007500075000750007500075000750
011800000275002750027500275002750027500275002750027500275002750027500275002750027500275004750047500475004750047500475004750047500475004750047500475004750047500475004750
011800000000000000000000000000000000000000000000000000000000000000000961009610000000961000000000000000000000000000000000000000000000000000000000000009610096000000009610
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
01 41 24 1e 44
01 41 24 1e 44
00 10 24 1e 44
00 10 24 1e 44
00 10 11 22 44
00 10 12 23 44
00 10 11 22 44
00 10 1f 23 44
02 10 21 1e 44
00 41 42 43 44
01 14 13 43 44
00 14 13 43 44
00 15 13 43 44
00 16 13 43 44
00 14 13 25 44
00 14 13 25 44
00 15 13 26 44
02 16 13 27 44
00 41 42 43 44
00 41 42 43 44
01 17 18 43 44
00 17 18 43 44
01 19 18 43 44
00 19 18 43 44
00 1a 18 43 44
02 1a 18 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 1b 42 43 44
00 1b 42 43 44
00 1b 1c 43 44
00 1b 1c 43 44
00 1b 1d 43 44
02 1b 1d 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 28 2c 43 44
00 29 42 43 44
00 28 2a 43 44
02 29 2b 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
