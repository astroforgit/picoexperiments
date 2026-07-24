pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
-- picoquest v1.2.5
-- by kieron scott

menuitem(1,"v1.2.5",nil)
menuitem(2,"by kjscott, 2020",nil)
deck={
	cards={},
	discards={},
	shuffle=function(self)
		while #self.discards>0 do
			local id=self.discards[1]
			del(self.discards,id)
			add(self.cards,id)
		end
		self.cards=shuffle(self.cards)
	end,
	draw=function(self)
		if (#self.cards==0) self:shuffle()
		if (#self.cards==0) return 0
		local id=self.cards[1]
		del(self.cards,id)
		add(self.discards,id)
		return id
	end,
	trash=function(self,id)
		del(self.discards,id)
	end
}
function deck:new(t)
	self.__index=self
	return setmetatable(t or {},self)
end
function _init()
	cartdata("picoquest_v1-2-1_2020")
	carddefault={name="nothing",sht=0,cost=0,shuffle=true}
	music_off,update_state,draw_state,module,col_drk1,messages,pmenu,ptarget4,ptarget8,pmindex,ptdir,hazards,treasure,dir8,creatures,items,characters,spells,missions,creaturedata,itemdata,characterdata,spelldata,castle,outdoors,tomb,chamber=dget(5),update_splash,draw_splash,dget(1)+1,{[0]=0,0,1,1,2,1,5,6,2,4,9,3,1,1,2,5},{},false,false,false,1,1,{
		[0]=clone(carddefault),
		{name="monster",deck="encounters"},
		{name="trap"}
	},{
		[0]=clone(carddefault),
		{name="item",deck="items"},
		{name="trap",deck="hazards"},
		{name="monster",deck="encounters"},
		{name="gold",gold=10},
		{name="gold",gold=25},
		{name="gold",gold=50},
		{name="jewels",gold=100,trash=true},
		{name="chest",gold=200,trash=true},
		{name="magic",item=strtotable("18,19,20,21,22"),trash=true},
		{name="artifact",item=strtotable("23,24,25,26,27,28"),trash=true}
	},{
		{x=1,y=0},
		{x=1,y=1},
		{x=0,y=1},
		{x=-1,y=1},
		{x=-1,y=0},
		{x=-1,y=-1},
		{x=0,y=-1},
		{x=1,y=-1}
	},{
		[0]=clone(carddefault)
	},{
		[0]=clone(carddefault)
	},{},{},{},"goblin,1,1,2,1,10;orc,1,2,3,2,8;hobbe,1,3,3,3,6;ogre,3,4,4,3,4;cthulhu,5,5,5,5,6,1;skeleton,1,0,2,2,10;zombie,2,0,3,3,8;mummy,3,0,3,4,6;knight,3,3,4,4,4;sorcerer,3,7,3,3,6,1",
	"helmet,1,6,0,100,0,0,1;leather,2,6,0,200,0,0,1;chainmail,2,7,0,500,0,0,2,-1;platemail,2,8,0,800,0,0,3,-2;staff,3,3,0,150,0,0,1,0,1;handaxe,3,6,0,150,1;shortsword,3,5,0,200,1;spear,3,6,0,250,1,0,0,0,1;broadsword,3,6,0,350,2,0;longsword,3,6,0,450,2,0,0,0,1;greataxe,3,7,0,550,3;shield,4,7,0,100,0,0,1,-1;dagger,4,2,0,50,0,1,0,0,0,1;sling,4,3,0,150,0,1;bow,4,6,0,250,0,2;xbow,4,7,0,450,0,3;toolkit,5,0,0,100,0,0,0,0,0,0,1;vial:body,5,4,0,500,0,0,0,0,0,1;vial:move,5,0,0,500,0,0,0,6,0,1;vial:attack,5,0,0,500,2,0,0,0,0,1;vial:defense,5,0,0,500,0,0,2,0,0,1;vial:shoot,5,0,0,500,0,2,0,0,0,1;magic helmet,1,0,0,2000,0,0,1;magic armour,2,0,0,4000,0,0,3;magic sword,3,0,0,5000,3,0,0,0,1,;magic bow,4,0,0,5000,0,4;magic shield,4,0,0,2000,0,0,1;magic wand,5,0,0,10000,0;magic boots,5,0,0,10000,0,0,0,1",
	"1,barbarian,uses random\nblood magic,8,2,0,9|1,1|2|3;2,dwarf,can disarm\ntraps and use\nearth magic,7,3,1,6|2,4|5|6;3,elf,affinity with\nwater and\nair magic,6,4,0,7|14,7|8|9|10|11|12;4,wizard,studied all\nforms of magic,5,5,0,5|14,3|4|5|6|7|8|9|10|11|12|13|14|15",
	"rage,+4 movement per action and +2 attack for 1 turn,1,self,,,0,1,2,0,0,4;cleave,2 damage to all creatures in a circle,1,self,circle,def,2,0;bandage,restores 2 body,1,self,,,-2,0;passwall,move through walls for 1 turn,1,self,passwall,,0,1;stoneskin,+2 defense for 1 turn,1,self,,,0,1,0,0,2;healing,restores four body,1,self,,,-4,0;mists,invisible until start of next turn,1,self,invisible,,0,0;sleep,visible targets can't move until their next turn,1,los,skip,mind,0,0;tidalwave,inflicts 2 damage and skips next turn in line,1,dir4,skip,mind,2,0;swiftwind,+6 movement per action for 1 turn,1,self,,,0,1,0,0,0,6;whirlwind,targets a line cannot move for 1 turn,1,dir4,skip,,0,0;tailwind,+2 ranged damage for 1 turn,1,self,,,0,1,0,2;wrath,+2 attack for 1 turn,1,self,,,0,1,2;fire,inflicts 3 damage to line,1,dir4,,mind,3,0;flame,inflicts 1 damage to all visible targets twice,2,los,,mind,1,0;hellball,,1,player,,mind,3,0;beserk,,1,all,,,0,0,2;barrier,,1,all,,,0,0,0,0,2;summon goblins,,3,player,summon,1,0,0;summon orcs,,2,player,summon,2,0,0;summon hobbe,,1,player,summon,3,0,0;summon skeletons,,3,player,summon,6,0,0;summon zombies,,2,player,summon,7,0,0;summon mummy,,1,player,summon,8,0,0",
	"12,16,2,1;12,17,2,1;32,17,2,1;32,16,2,1;31,10,1;19,10,1;19,23,1;31,23,1;5,16,15,1;5,17,15,1;6,14,14;6,19,14,0,1;13,15,17;13,18,17;10,14,13;10,19,13;16,15,2;16,18,2;23,23,2;22,27,2;25,27,2;26,25,2,1;21,24,13;28,29,14,0,1;28,10,2;25,10,2;22,10,2;21,8,15,1;29,8,15,1,1;25,7,14;25,6,1;29,24,15;29,25,16;20,14,2,1;20,19,2,1;27,21,2;30,15,2,1;16,9,14;13,19,12,1,1;13,20,1;12,19,4;15,21,10,1;17,21,15,1,1",
	"22,1,0;21,1,0;22,3,0;21,3,0;22,6,0;23,9,0;28,6,0;19,15,1;19,18,1;13,18,1;13,15,1;12,16,0;12,17,0;14,10,0;19,18,4;18,14,0;2,11,1;19,25,1;7,31,1;23,2,1;20,13,0;24,15,0;28,18,0;24,17,0;31,19,1;20,19,0;28,23,0;26,29,0;20,24,0;22,27,0;13,30,0;16,22,0;11,24,0;11,27,0;4,26,0;8,22,0;12,14,0;12,19,0;16,8,0;3,7,0",
	"4,10,18;5,10,18;5,9,18;4,9,18;19,15,1;19,6,1;20,11,1;9,9,2,1;20,8,2,1;25,10,2;22,12,2;18,13,2,1;30,11,1;24,14,2,1;24,17,2,1;19,21,1;14,17,1;14,16,1;20,20,2,1;16,15,2;19,18,7;19,11,7;23,7,2,1;14,10,2,1;26,7,13;22,18,9;22,19,9;27,13,10;28,13,11;29,15,12,1,1",
	"5,16,18;5,17,18;6,17,18;6,16,18;13,15,1;13,18,1;19,25,1;19,8,1;28,22,1;28,11,1;12,17,2,1;12,16,2,1;16,18,2;25,10,2;20,9,4;24,14,2,1;26,21,2;23,23,2;20,19,2,1;18,12,2,1;10,17,7;15,16,7;19,21,7;26,16,7;26,14,7;24,19,4;24,22,6;29,15,9;28,15,9;16,10,9;16,11,9;21,7,13;21,16,2;21,18,7"
	leveldata={
		{
			"meeting|you were ambushed\non the way to\ncourt.\n\nescape alive.\n\nreward:\n 50GP|15|26|2|11,29,0;13,19,12;4,26,0;7,23,0;10,22,0;14,20,0;16,18,0;9,21,1;13,18,1;18,17,1;18,16,1;9,29,7;9,23,7;15,16,5;1,12,0;2,11,1;2,13,1|12,23,17,29,99,many were ambushed here;5,23,6,25,11;9,12,9,12,11;15,19,17,19,11;1,12,1,12,1,the path leads out|12,19,14,21,9;12,23,17,29,9,you search the dead;12,23,17,29,9|0,1,1,1,2|0,1,2,5,6,7,12,13,14|0,1,2,3,4,4,4,4,5,5,6|13,28,1;16,24,1|50",
			"discovery|the court wizard\nasks you to search\nan old tomb.\n\nfind the tome.\n\nreward:\n 100GP|7|16|0|"..chamber.."|24,14,24,14,99,you see the tome;27,14,29,16,1,you have found the tome|21,7,22,9,8|0,6,6,6,7;15,9,14,11,10|0,1,2,5,6,7,12,13,14|0,1,2,3,4,4,4,4,5,5,6,7|16,20,6;23,14,6;26,7,6;22,25,7|100",
			"quest|the tome revealed\nthe location of\nan artifact.\n\nfind and return\nit.\n\nreward:\n artifact|6|9|1|"..tomb.."||24,7,26,9,8;25,13,29,17,9;21,17,23,20,10|0,1,1,1,2,2,3|0,1,2,5,6,7,8,12,13,14,15,17|0,1,2,3,4,4,4,4,5,5,6,7,8|27,15,3,0,16;21,20,2;25,8,3;16,12,2;26,16,1;12,10,1;17,16,1;23,17,1|0",
			"betrayal|as you return to\nthe court wizard\nsprings a trap.\n\nyou must escape.\n\nreward:\n your life|7|16|0|"..castle.."|32,16,32,17,1,you found a way out|12,19,12,19,9;15,19,17,21,9;24,7,26,9,9;21,24,25,26,8|0,1,1,1,2,2,3|0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17|0,1,2,3,4,4,4,4,5,5,6,7,8,9|17,16,6;22,11,7;25,22,7;5,18,6;5,15,6;5,14,6;5,19,6;4,16,10;18,17,6;31,20,8;31,14,8|0",
			"ritual|stop the ritual\nfrom being\ncompleted.\n\nkill the three\nsorcerers.\n\nreward:\n 200GP|8|16|0|5,16,18;5,17,18;6,17,18;6,16,18;13,15,1;13,18,1;12,12,1;12,21,1;12,19,2,1;5,20,2;3,21,1;9,22,2;14,21,2,1;11,28,2,1;18,13,2,1;19,12,1;19,21,1;24,13,2,1;20,14,2,1;24,17,2,1;20,20,2,1;18,19,2,1;27,18,4;18,16,4;18,17,1;16,8,4;13,22,4;19,17,6;17,5,9;17,6,9;17,28,16;17,27,16;29,15,15,1,1;25,19,12;27,13,14;13,16,13,1;22,17,11;9,26,2;12,14,2,1;13,11,2;11,8,2|4,14,11,19,99,you hear chanting echoes|13,16,17,17,8;25,19,29,20,9;12,23,17,29,10;10,4,17,7,11;21,17,23,20,8|0,1,1,1,2,2,3|0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17|0,1,2,3,4,4,4,4,5,5,6,7,8,9,10|15,5,10,0,3;15,24,10,0,3;27,15,10,0,2;11,9,6;13,10,6;13,6,8;26,15,9;7,28,2;14,26,3;10,25,1;5,28,1;15,28,1;22,18,1;23,20,1;22,15,6;21,13,6|200",
			"the beast|too late!\n\nfind and kill the\neldritch beast.\n\nreward:\n 250GP|31|16|0|"..castle.."|13,16,15,17,99,you hear canting|12,19,12,19,9;15,19,17,21,9;24,7,26,9,9;21,24,25,26,8|0,1,1,1,2,2,3|0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17|0,1,2,3,4,4,4,4,5,5,6,7,8,9|7,16,5,0,16;7,17,10;16,16,2;26,14,1;28,16,1;24,25,1;22,19,1;21,9,1;22,13,2;10,15,4;10,17,1;10,16,1;10,18,3;16,17,3;27,11,2;22,22,2;28,26,2|250"
		},{},{},{}
	}
	parsefunc(creatures,creaturedata,parsecreature)
	parsefunc(items,itemdata,parseitem)	
	parsefunc(characters,characterdata,parsecharacter)
	parsefunc(spells,spelldata,parsespell)
	for k=1,#leveldata do
		missions[k]={}
		for j=1,#leveldata[k] do
			local data=split(leveldata[k][j],"|",false)
			add(missions[k],{
					name=data[1],
					description=data[2],
					startx=tonum(data[3]),
					starty=tonum(data[4]),
					altspritesheet=data[5],
					level=data[6],
					triggers=data[7],
					rooms=data[8],
					encounters=strtotable(data[9]),
					hazards=strtotable("0,1,2,2,2"),
					items=strtotable(data[10]),
					search=strtotable(data[11]),
					creatures=data[12],
					reward=tonum(data[13])
				}
			)
		end
	end
end
function _update()
	sintime=sin(time())
	update_state()
end
function _draw()
	cls()
	sspr(72,96,56,16,36,0)
	sspr(0,88+module*8,56,8,36,16)
	draw_state()
end
function parsespell(t)
	return {name=t[1],description=t[2],num=t[3],target=t[4],effect=t[5],save=t[6],damage=t[7],action=t[8],atk=t[9] or 0,sht=t[10] or 0,def=t[11] or 0,move=t[12] or 0}
end
function parsecharacter(t)
	return {index=t[1],name=t[2],description=t[3],body=t[4],will=t[5],disarm=t[6]==1,init=split(t[7],"|"),spells=split(t[8],"|"),equipped={},backpack={},atk=1,def=1,sht=0,maxmove=0}
end
function parseitem(t)
	return {name=t[1],slot=t[2],reqbody=t[3],reqwill=t[4],cost=t[5],atk=t[6] or 0,sht=t[7] or 0,def=t[8] or 0,move=t[9] or 0,diag=t[10]==1,discard=t[11]==1,disarm=t[12]==1}
end
function parsecreature(t)
	return {name=t[1],body=t[2],will=t[3],atk=t[4],sht=0,def=t[5],move=t[6],special=t[7]==1 or false}
end
function parselevel(t)
	return {x1=t[1],y1=t[2],x2=t[3],y2=t[4] or 0,e=t[5] or 0,description=t[6]}
end
function parsedata(data,index,i)
	return split(data,",")
end
function parsefunc(array,data,func)
	local arr,i=split(data,";")
	for i=1,#arr do
		if arr[i]!="" then
			add(array,func(parsedata(arr[i],1,#arr[i])))
		end
	end
end
function strtotable(s)
	return split(s,",")
end
function init_message(s)
	if not s then return end
	sfx(5,0)
	while #s>25 do
		for i=25,1,-1 do
			if sub(s,i,i)==" " then
				add(messages,sub(s,1,i))
				s=sub(s,i+1,#s)
				break
			end
		end
	end
	add(messages,s)
	while #messages>4 do
		del(messages,messages[1])
	end
end
function init_board()
	board={}
	for x=1,32 do
		board[x]={}
		for y=1,32 do
			board[x][y]={v=sget(x+95,y-1),los=false}
		end
	end
end
function init_monster(id,x,y,f,e,seen)
	local creature=clone(creatures[id])
	open_door(board[x][y])
	return {
		v=id,x=x,y=y,f=f,e=e,a=0,
		seen=seen or false,name=creature.name,body=creature.body,will=creature.will,
		move=creature.move,atk=creature.atk,sht=creature.sht,def=creature.def,
		special=creature.special,modatk=0,moddef=0,modsht=0,modmove=0,skip=false
	}
end
function init_level()
	messages,rooms,triggers,placeables,monsters,mission={},{},{},{},{},missions[module][player.levels[module]+1]
	player.x,player.y,deck_encounters,deck_hazards,deck_items,deck_search=mission.startx,mission.starty,deck:new({cards=shuffle(clone(mission.encounters))}),deck:new({cards=shuffle(clone(mission.hazards))}),deck:new({cards=shuffle(clone(mission.items))}),deck:new({cards=shuffle(clone(mission.search))})
	parsefunc(rooms,mission.rooms,parselevel)
	parsefunc(triggers,mission.triggers,parselevel)
	parsefunc(placeables,mission.level,parselevel)
	parsefunc(monsters,mission.creatures,parselevel)
	for i=1,#placeables do
		local t=placeables[i]
		board[t.x1][t.y1]={v=t.x2,f=t.y2==1,r=t.e==1,los=false}
	end
	for i=1,#monsters do
		local t=monsters[i]
		monsters[i]=init_monster(t.x2,t.x1,t.y1,t.y2,t.e)
	end
	update_los(player.x,player.y)
end
function init_player(save)
	player=clone(characters[pmindex])
	player.levels,player.equipped,player.gold={0,0,0,0},{0,0,0,0,0},0
	for i=1,#player.init do
		local id=player.init[i]
		equip(items[id].slot,id)
	end
	reinit_player()
	if (save) save_player()
end
function reinit_player()
	local char=characters[player.index]
	player.spells,player.f,player.a,player.move,player.won,player.modatk,player.modsht,player.moddef,player.modmove,player.body,player.will=clone(char.spells),false,2,0,0,0,0,0,0,char.body,char.will
	if player.index==1 then
		player.spells={rnd(player.spells)}
	end
end
function load_player()
	player=clone(characters[dget(6)])
	player.levels,player.gold,player.equipped={dget(2),dget(3),dget(4)},dget(7),{0,0,0,0,0}
	for i=8,12 do equip(i-7,dget(i)) end
	for i=1,dget(13) do add(player.backpack,dget(13+i)) end
	reinit_player()
end
function del_player()
	for i=0,63 do dset(i,0) end
	dset(5,music_off)
end
function save_player()
	del_player()
	dset(0,1)
	dset(1,module-1)
	for i=2,4 do dset(i,player.levels[i-1]) end
	dset(6,player.index)
	dset(7,player.gold)
	for i=8,12 do dset(i,player.equipped[i-7]) end
	dset(13,#player.backpack)
	for i=1,#player.backpack do dset(13+i,player.backpack[i]) end
end
function equip(slot,id)
	unequip(slot)
	if id and id!=0 then
		local item=items[id]
		player.atk+=item.atk or 0
		player.sht+=item.sht or 0
		player.def+=item.def or 0
		player.maxmove+=item.move or 0
		setdisarm(slot,item)
		del(player.backpack,id)
	end
	player.equipped[slot]=id
end
function unequip(slot)
	local id=player.equipped[slot]
	if id!=0 then
		local item=items[id]
		player.atk-=item.atk or 0
		player.sht-=item.sht or 0
		player.def-=item.def or 0
		player.maxmove-=item.move or 0
		setdisarm(slot,item)
		player.equipped[slot]=0
		add(player.backpack,id)
	end
end
function setdisarm(slot,item)
	if slot==5 then
		player.disarm=item.disarm or characters[player.index].disarm or false
	end
end
function update_splash()
	update_music()
	if btnp(”) then
		pmindex=max(1,pmindex-1)
	elseif btnp(ƒ) then 
		pmindex=min(5,pmindex+1)
	elseif btnp(—) then
		if pmindex==1 and is_activesave() then
			draw_state,update_state,pmindex=draw_menu,update_menu,1
			load_player()
		elseif pmindex==2 then
			draw_state,update_state,pmindex=draw_newgame,update_newgame,1
			init_player()
		elseif pmindex==4 then
			draw_state,update_state,pmindex=draw_instructions,update_instructions,1
		elseif pmindex==5 then
			music_off=music_off^^1
		end
	end
end
function update_music()
	if music_off==0 then 
		if stat(24)==-1 then music(0,1500) end
	elseif stat(24)!=-1 then
		music(-1,1000)
	end
end
function update_instructions()
	if btnp(‹) then
		pmindex=max(1,pmindex-1)
	elseif btnp(‘) then 
		pmindex=min(5,pmindex+1)
	elseif btnp(Ž) then
		draw_state,update_state,pmindex=draw_splash,update_splash,1
	end
end
function update_newgame()
	if btnp(‹) then
		pmindex=max(1,pmindex-1)
		init_player()
	elseif btnp(‘) then 
		pmindex=min(#characters,pmindex+1)
		init_player()
	elseif btnp(—) then
		init_player(true)
		draw_state,update_state,pmindex=draw_menu,update_menu,1
	elseif btnp(Ž) then
		draw_state,update_state,pmindex=draw_splash,update_splash,1
		if (is_activesave()) load_player()
	end
end
function update_loadout()
	selection,index={},pmstate
	if pmstate==0 then
		index=pmindex
	end
	for i=1,#player.backpack do
		id=player.backpack[i]
		item=items[id]
		if item.slot==index then
			add(selection,id)
		end
	end
	if btnp(”) then
		pmindex=max(1,pmindex-1)
	elseif btnp(ƒ) then 
		if pmstate==0 then
			pmindex=min(5,pmindex+1)
		else
			pmindex=min(#selection+1,pmindex+1)
		end
	elseif btnp(—) then
		if pmstate==0 then
			if #selection>0 or player.equipped[pmindex]!=0 then
				pmstate=pmindex
				pmindex=1
			end
		else
			if pmindex<=#selection then
				id=selection[pmindex]
				item=items[id]
				if item.reqbody<=player.body and item.reqwill<=player.will then
					equip(pmstate,id)
					pmindex=pmstate
					pmstate=0
				end
			else
				if player.equipped[pmstate]!=0 then
					unequip(pmstate)
				end
				pmindex=pmstate
				pmstate=0
			end
		end
	elseif btnp(Ž) then
		if pmstate==0 then
			draw_state,update_state,pmindex=draw_menu,update_menu,1
			save_player()
		else
			pmindex=pmstate
			pmstate=0
		end
	end
end
function draw_loadout()
	print("head\narmour\nweapon\nranged\nmisc",12,30,7)
	print_stats(100,20,true)
	print_combat(108,44)
	print("” up            down ƒ\nŽ menu        select —",20,116,6)
	dx=4-sintime
	if pmstate==0 then
		print("—",dx,24+pmindex*6,10)
		index=pmindex
	else
		print("—",dx,58+pmindex*6,10)
		index=pmstate
	end
	count,dx,dy=0,68,64
	for i=1,#player.equipped do
		s="---"
		if player.equipped[i]!=0 then
			s=items[player.equipped[i]].name
		end
		print(s,40,24+i*6,7)
	end
	for i=1,#player.backpack do
		item=items[player.backpack[i]]
		if item.slot==index then
			function print_extra(s,sprite)
				if type(s)=="number" and s>=0 then s="+"..tostr(s) end
				if type(sprite)=="number" then
					spr(sprite,dx+indent*20+8,dy-2)
				elseif sprite then
					s=s..sprite
				end
				print(s,dx+indent*20,dy)
				indent+=1
			end
			indent,dy,c=0,64+count*6,7
			if (item.reqbody>player.body or item.reqwill>player.will) c=1
			print(item.name,12,dy,c)
			color(6)
			if item.def!=0 then
				print_extra(item.def,175)
			end
			if item.atk!=0 then
				print_extra(item.atk,190)
			end
			if item.diag then
				print_extra("diag")
			end
			if item.sht!=0 then
				print_extra(item.sht,191)
			end
			if item.discard then
				print_extra("once")
			end
			if item.move!=0 then
				print_extra(item.move,"‰")
			end
			if item.disarm then
				print_extra("disarm")
			end
			count+=1
		end
	end
	if pmstate!=0 then
		print("---",12,64+count*6)
	end
end
function draw_shop()
	diff=pmindex-10
	if (pmindex<11) diff=0
	print("—",1-sintime+pmstate*60,30+(pmindex-diff)*6,10)
	print("gold left:"..player.gold,4,100)
	print("buy            sell\n\n\n\n\n\n\n\n\n\n\n\n\n    ‹ buy         sell ‘\n    ” up          down ƒ\n    Ž menu      select —",4,30,6)
	for i=1,10 do
		item,c=items[i+diff],7
		if player.gold<item.cost then 
			c=1 
		elseif player.body<item.reqbody or player.will<item.reqwill then
			c=5
		end
		print(item.name..":"..item.cost,9,30+i*6,c)
	end
	for i=1,min(10,#player.backpack) do
		if i+diff<=#player.backpack then
			item=items[player.backpack[i+diff]]
			print(item.name..":"..(item.cost\2),69,30+i*6,7)
		end
	end
end
function update_shop()
	backpack=player.backpack
	if btnp(”) then
		pmindex=max(1,pmindex-1)
	elseif btnp(ƒ) then
		val=22
		if (pmstate==1) val=#backpack
		pmindex=min(val,pmindex+1)
	elseif btnp(‹) then
		pmstate=0
	elseif btnp(‘) then 
		if #backpack>0 then
			pmindex,pmstate=min(#backpack,pmindex),1
		end
	elseif btnp(—) then
		if pmstate==0 then
			item=items[pmindex]
			cost=item.cost
			if player.gold>=cost and player.body>=item.reqbody and player.will>=item.reqwill then
				player.gold-=cost
				add(backpack,pmindex)
			end
		elseif pmstate==1 then
			player.gold+=items[backpack[pmindex]].cost\2
			del(backpack,backpack[pmindex])
			pmindex=min(#backpack,pmindex)
			if pmindex==0 then
				reset_menu()
			end
		end
	elseif btnp(Ž) then
		draw_state,update_state=draw_menu,update_menu
		save_player()
		reset_menu()
	end
	
end
function update_menu()
	update_music()
	if btnp(”) then
		pmindex=max(1,pmindex-1)
	elseif btnp(ƒ) then 
		pmindex=min(4,pmindex+1)
	elseif btnp(—) then
		if pmindex==1 then
			if player.levels[module]<#missions[module] then
				draw_state,update_state=draw_game,update_game
				reinit_player()
				init_board()
				init_level()
				music(-1,1500)
			end
		elseif pmindex==2 then
			draw_state,update_state=draw_loadout,update_loadout
		elseif pmindex==3 then
			draw_state,update_state=draw_shop,update_shop
		elseif pmindex==4 then
			draw_state,update_state=draw_splash,update_splash
		end
		reset_menu()
	elseif btnp(Ž) then
		draw_state,update_state=draw_splash,update_splash
		reset_menu()
	end
end
function check_end_turn()
	if is_dead() then game_over()
	elseif update_state==update_game_complete then
	elseif player.a==0 and player.move==0 then end_turn() end
end
function start_turn()
	init_message("**players turn**")
	passwall,invisible,player.modatk,player.modsht,player.moddef,player.modmove,player.a,player.move,update_state=false,false,0,0,0,0,2,0,update_game
end
function end_turn()
	update_state,coroutine_monster=monsters_turn,cocreate(update_enemies)
end
function monsters_turn()
	if coroutine_monster and costatus(coroutine_monster)!="dead" and #monsters>0 then
		if time()\1==time() then
			coresume(coroutine_monster)
			if is_dead() then 
				coroutine_monster=nil
				game_over()
			end
		end
	else
		coroutine_monster=nil
		start_turn()
	end
end
function update_enemies()
	for m=1,#monsters do
		uenemy=monsters[m]
		uenemy.move=creatures[uenemy.v].move+uenemy.modmove
		if uenemy.seen and not (invisible or uenemy.skip) then
			while uenemy.move>0 do
				move_enemy()
				if get_dist(player.x,player.y,uenemy.x,uenemy.y)<=5 and has_los(player.x,player.y,uenemy.x,uenemy.y) then yield() end
			end
		end
		uenemy.modatk,uenemy.modsht,uenemy.moddef,uenemy.modmove,uenemy.skip=0,0,0,0,false
	end
end
function move_enemy()
	px,py,tx,ty,mov=player.x,player.y,uenemy.x,uenemy.y,uenemy.move
	dist,df=get_dist(tx,ty,px,py),player.def+player.moddef
	if has_los(tx,ty,px,py) and uenemy.sht>0 and dist>1 and (tx==px or ty==py) then
		attack(uenemy,player,uenemy.sht+uenemy.modsht,df,"fires for ")
	elseif uenemy.special and rnd()>0.5 then
		spls={{16,17,18},{19,20,21},{22,23,24}}
		pcastspell=rnd(spls[module])
		action_cast(uenemy,pcastspell)
	else
		mdir={}
		for z=1,#dir8,2 do
			dm=dir8[z]
			tmx,tmy=tx+dm.x,ty+dm.y
			if get_dist(px,py,tmx,tmy)<dist and not is_solid(tmx,tmy) then
				target=get_creature(tmx,tmy)
				if target==nil or target==player then
					add(mdir,dm)
				end
			end
		end
		if #mdir>0 then
			mdir=rnd(mdir)
			tx+=mdir.x
			ty+=mdir.y
			if get_creature(tx,ty) then
				attack(uenemy,player,uenemy.atk+uenemy.modatk,df,"hits for ")
			else
				uenemy.x,uenemy.y,mov=tx,ty,1
				sfx(7,0)
				open_door(board[tx][ty])
			end
		end
	end
	uenemy.move-=mov
end
function roll(dice,target)
	total=0
	for i=1,dice do
		if ceil(rnd(6))>=target then total+=1 end
	end
	return total
end
function kill_enemy(target)
	if target!=player then
		if target.body<=0 then
			init_message(target.name.." slain")
			apply_trigger(target.e)
			del(monsters,target)
			sfx(3,0)
		end
	end
end
function attack(attacker,defender,atkdice,defdice,s)
	damage,defense=roll(atkdice,3),roll(defdice,4)
	damage=max(0,damage-defense)
	defender.body-=damage
	init_message(attacker.name.." "..s..damage.." damage")
	sfx(8,0)
	kill_enemy(defender)
end
function reset_menu()
	pmindex,pmstate=1,0
end
function reset_game_menu()
	pmspells,pmenu,pmindex,paction,ptarget4,ptarget8=false,false,1,1,nil,false,false
end
function check_draw(s)
	deck,card,idx=draw_deck(s)
	while card.deck do
		deck,card,idx=draw_deck(card.deck)
	end
	apply_card(deck,card,idx)
end
function draw_deck(name)
	if name=="items" then
		deck=deck_items
		idy=deck_items:draw()
		card=items[idy]
	elseif name=="hazards" then
		deck=deck_hazards
		idy=deck_hazards:draw()
		card=hazards[idy]
	elseif name=="encounters" then
		deck=deck_encounters
		idy=deck_encounters:draw()
		card=creatures[idy]
	elseif name=="treasure" then
		deck=deck_search
		idy=deck_search:draw()
		card=treasure[idy]
	end
	return deck,card,idy
end
function apply_card(deck,card,idz)
	if idz==0 then
		init_message("found nothing")
	elseif deck==deck_items then
		init_message("found "..card.name)
		add(player.backpack,idz)
	elseif deck==deck_encounters then
		tx,ty=get_empty_tile(player.x,player.y)
		if tx!=nil then
			init_message("ambushed by "..card.name)
			add(monsters,init_monster(idz,tx,ty,0,0,true))
		end
	elseif deck==deck_hazards then
		if player.disarm then
			init_message("disarmed trap")
		else
			init_message("trap, lost 1 body")
			player.body-=1
		end
	elseif deck==deck_search then
		if card.gold then
			init_message("found gold")
			player.gold+=card.gold
		end
	end
	if card.shuffle then deck:shuffle() end
	if card.trash then deck:trash(card) end
end
function get_target()
	return dir8[ptdir].x,dir8[ptdir].y
end
function action_attack(actor)
	dx,dy=get_target(actor)
	target=get_creature(actor.x+dx,actor.y+dy)
	if target then
		attack(actor,target,actor.atk+actor.modatk,target.def+target.moddef,"hits for ")
		return true
	end
	return false
end
function action_shoot(actor)
	dx,dy=get_target(actor)
	for i=1,5 do
		target=get_creature(actor.x+dx*i,actor.y+dy*i)
		if target then
			attack(actor,target,actor.sht+actor.modsht,target.def+target.moddef,"fires for ")
			return true
		end
	end
	return false
end
function apply_spell(tile,tx,ty)
	target,sp,ef=get_creature(tx,ty),spell.target,spell.effect
	if target then
		if (sp=="self" and caster==target) or (sp=="los" and target!=caster) or (sp=="all" and target!=player)  or (sp=="player" and target==player) or (sp=="dir4" or sp=="dir8") then
			passwall=ef=="passwall"
			invisible=ef=="invisible"
			target.modatk+=spell.atk
			target.modsht+=spell.sht
			target.moddef+=spell.def
			target.modmove+=spell.move
			if ef=="skip" then
				target.skip=true
				if spell.save=="mind" then
					target.skip=roll(target.will,4)==0
				end
				if target.skip then
					init_message(target.name.." will skip turn")
				else
					init_message(target.name.." resists effect")
				end
			end
			if ef=="summon" then
				tx,ty=get_empty_tile(target.x,target.y)
				if tx!=nil then
					add(monsters,init_monster(tonum(spell.save),tx,ty,0,0,true))
				end
			end
			target.a=min(3,target.a+spell.action)
			if spell.damage>0 then
				s,sv="causes ",target.will
				if spell.save=="def" then
					s,sv="attacks for ",target.def+target.moddef
				end
				attack(caster,target,spell.damage,sv,s)
			elseif spell.damage<0 then
				target.body+=-spell.damage
				if target==player then
					maxbody=characters[target.index].body
				else
					maxbody=creatures[target.v].body
				end
				target.body=min(maxbody,target.body)
			end
		end
	end
end
function action_cast(actor,id)
	caster,id=actor,id or pcastspell
	spell,ax,ay=spells[id],caster.x,caster.y
	init_message(caster.name.." casts "..spell.name)
	for num=1,spell.num do
		if spell.target=="self" then
			apply_spell(nil,ax,ay)
		elseif spell.target=="circle" then
			check_visible_tiles_for(apply_spell,1)
		elseif spell.target=="los" or spell.target=="all" or spell.target=="player" then
			check_visible_tiles_for(apply_spell)
		else
			dx,dy=get_target(caster)
			if ptarget8 then 
				apply_spell(nil,caster.x+dx,caster.y+dy)
			else
				for i=1,5 do
					apply_spell(nil,caster.x+dx*i,caster.y+dy*i)
				end
			end
		end
	end
	if caster==player then
		if (not has_wand() or rnd()>0.5) del(player.spells,id)
		decrease_actions()
	end
end
function print_spell()
	pcastspell=player.spells[pmindex]
	spell=spells[pcastspell]
	init_message("**"..spell.name.."**")
	init_message(spell.description)
end
function correct_ptdir()
	if ptdir%2==0 then
		ptdir=(ptdir+1)%8
	end
end
function update_game()
	if btnp(Ž) then
		reset_game_menu()
	elseif ptarget4 then
		if btnp(‹) then 
			ptdir=(ptdir-2)%8
		elseif btnp(‘) then 
			ptdir=(ptdir+2)%8
		elseif btnp(—) then
			if paction(player) then
				decrease_actions()
			end
			reset_game_menu()
		end
	elseif ptarget8 then
		if btnp(‹) then 
			ptdir-=1
			if ptdir<1 then ptdir+=8 end
		elseif btnp(‘) then 
			ptdir+=1
			if ptdir>8 then ptdir-=8 end
		elseif btnp(—) then
			if paction(player) then
				decrease_actions()
			end
			reset_game_menu()
		end
	elseif pmspells then
		if btnp(”) then 
			pmindex=max(1,pmindex-1)
			print_spell()
		elseif btnp(ƒ) then
			pmindex=min(#player.spells,pmindex+1)
			print_spell()
		elseif btnp(—) then
			reset_game_menu()
			paction,pmspells=action_cast,false
			if spell.target=="dir4" then
				ptarget4=true
				correct_ptdir()
			elseif spell.target=="dir8" then
				ptarget8=true
			else
				action_cast(player,pcastspell)
			end
		end
	elseif pmenu then
		if btnp(”) then 
			pmindex=max(1,pmindex-1)
		elseif btnp(ƒ) then 
			pmindex=min(9,pmindex+1)
		elseif btnp(—) then
			if pmindex==7 then
				reset_game_menu()
				end_turn()
			elseif pmindex==9 then
				reset_game_menu()
				player.won,update_state,draw_state=0,update_menu,draw_menu
				load_player()
			elseif player.a>0 then
				if pmindex==1 and has_spells() then
					pmspells,pmindex=true,1
					print_spell()
				elseif pmindex==2 and has_ranged_weapon() then
					reset_game_menu()
					ptarget4,paction=true,action_shoot
					correct_ptdir()
				elseif pmindex==3 and has_diag_weapon() then
					reset_game_menu()
					ptarget8,paction=true,action_attack
				elseif pmindex==4 then
					found=false
					check_visible_tiles_for(search_hidden_traps)
					check_visible_tiles_for(search_secret_door)
					for i=1,#rooms do
						room=rooms[i]
						if contains(px,py,room.x1,room.y1,room.x2,room.y2) then
							evt=room.e
							init_message(room.description)
							if evt>0 then
								found,room.e=true,0
								apply_trigger(evt)
							else
								init_message("already searched")
							end
						end
					end
					if not found then init_message("found nothing") end
					decrease_actions()
				elseif pmindex==5 and player.disarm then
					check_visible_tiles_for(search_disarm_traps)
					decrease_actions()
				elseif pmindex==6 and has_potion() then
					char,item=characters[player.index],items[player.equipped[5]]
					player.body=min(char.body,player.body+item.reqbody)
					player.will=min(char.will,player.will+item.reqwill)
					player.modatk=item.atk
					player.modsht=item.sht
					player.moddef=item.def
					player.move+=item.move
					player.equipped[5]=0
					reset_game_menu()
				end
			end
		end
	else
		if btnp(‹) then 
			move(player.x-1,player.y,true)
		elseif btnp(‘) then 
			move(player.x+1,player.y,false)
		elseif btnp(”) then 
			move(player.x,player.y-1,false)
		elseif btnp(ƒ) then 
			move(player.x,player.y+1,true)
		elseif btnp(—) then
			pmenu=true
		end
	end
end
function decrease_actions()
	player.a-=1
	reset_game_menu()
	check_end_turn()
end
function update_game_over()
	countdown-=1
	if countdown<0 then
		update_state,draw_state=update_splash,draw_splash
		del_player()
	end
end
function game_over()
	init_message("**you died**")
	countdown,update_state=60,update_game_over
end
function update_game_complete()
	countdown-=1
	if countdown<0 then 
		update_state,draw_state=update_menu,draw_menu
		reinit_player()
		save_player()
	end
end
function complete_mission()
	countdown,update_state=60,update_game_complete
	if player.won>=1 then 
		init_message("**mission complete**")
		if mission.reward>0 then
			init_message("rewarded "..mission.reward.."GP")
			player.gold+=mission.reward
		end
		player.levels[module]+=1
	else
		init_message("**mission incomplete**")
	end
end
function print_complete()
	if (player.won>=1) init_message("objective complete")
end
function apply_trigger(evt)
	if evt==1 then
		player.won+=1
		print_complete()
	elseif evt==2 then
		player.won+=0.5
		print_complete()
	elseif evt==3 then
		player.won+=0.25
		print_complete()
	elseif evt==4 then player.gold+=100
	elseif evt==5 then player.gold+=50
	elseif evt==6 then player.gold+=25
	elseif evt==7 then player.gold+=10
	elseif evt==8 then check_draw("items")
	elseif evt==9 then check_draw("treasure")
	elseif evt==10 then check_draw("hazards")
	elseif evt==11 then check_draw("encounters")
	elseif evt==12 then check_visible_tiles_for(search_secret_door)
	elseif evt==14 then check_visible_tiles_for(open_door)
	elseif evt==15 then 
		player.won+=1
		print_complete()
		complete_mission()
	elseif evt==16 then
		player.won+=1
		id=rnd(strtotable("23,24,25,26,27,28"))
		card=items[id]
		apply_card(deck_items,card,id)
	end
end
function move_trigger(tx,ty)
	for i=1,#triggers do
		trigger=triggers[i]
		if contains(tx,ty,trigger.x1,trigger.y1,trigger.x2,trigger.y2) then
			evt=trigger.e
			if evt>0 then
				found,trigger.e=true,0
				init_message(trigger.description)
				apply_trigger(evt)
			end
		end
	end
end
function move(tx,ty,hflip)
	px,py=player.x,player.y
	if tx<1 or tx>32 or ty<1 or ty>32 then 
		complete_mission()
	elseif board[tx][ty].v==18 then
		move_trigger(tx,ty)
		complete_mission()
	elseif get_creature(tx,ty) then
		if player.a>0 then
			target=get_creature(tx,ty)
			attack(player,target,player.atk+player.modatk,target.def+target.moddef,"hits for ")
			decrease_actions()
			tx,ty=px,py
		end
	elseif not is_solid(tx,ty) or passwall then
		if player.move>0 or player.a>0 then
			tile,dx,dy,mov=board[tx][ty],tx-px,ty-py,1
			sfx(7,0)
			open_door(tile)
			if tile.v>=5 and tile.v<=7 then
				if not tile.visible then
					tile.visible=true
					player.body-=1
					if (tile.v==5) mov=player.move
					init_message("trap, lose 1 body")
				elseif not is_solid(tx+dx,ty+dy) and (player.move>1 or player.a>0) then
					tx,ty,mov=tx+dx,ty+dy,2
				else
					tx,ty,mov=px,py,0
				end
			end
			player.x,player.y,player.f=tx,ty,hflip
			player.move-=mov
			move_trigger(tx,ty)
		end
		if player.move<0 and player.a>0 then
			player.move+=6+player.maxmove+player.modmove
			player.a-=1
		end
		update_los(tx,ty)
		check_end_turn()
	end
end
function update_los(tx,ty)
	for x=max(1,tx-5),min(32,tx+5) do
		for y=max(1,ty-5),min(32,ty+5) do
			board[x][y].los=has_los(x,y,tx,ty)
			for i=1,#monsters do
				monster=monsters[i]
				monster.seen=monster.seen or has_los(tx,ty,monster.x,monster.y)
			end
		end
	end
end
function get_dist(fx,fy,tx,ty)
	local dx,dy=fx-tx,fy-ty
	return sqrt(dx*dx+dy*dy)
end
function has_los(x1,y1,x2,y2)
	if get_dist(x1,y1,x2,y2)<1.5 then
		return true
	elseif y1>y2 then
		x1,x2,y1,y2=x2,x1,y2,y1
	end
	local sy,dy,sx,dx=1,y2-y1
	if x1<x2 then sx,dx=1,x2-x1
	else sx,dx=-1,x1-x2 end
	local frst,err,e2=true,dx-dy
	while not(x1==x2 and y1==y2) do
		if not frst then 
			if is_opaque(x1,y1) then 
				return false
			end
		end
		e2,frst=err+err,false
		if e2>-dy then
			err-=dy
			x1+=sx
		end
		if e2<dx then 
			err+=dx
			y1+=sy
		end
	end
	return true
end
function draw_splash()
	print("—",30-sintime,74+pmindex*6,10)
	c1=1
	if (is_activesave()) c1=6
	print("continue game",38,80,c1)
	print("new game\n---\ninstructions\ntoggle music",38,86,6)
end
function draw_instructions()
	print("",4,24,6)
	if pmindex==1 then
		print("menu and game controls:\n                 = left\n                 = right\n                 = up\n                 = down\n                 = menu/select\n                 = cancel/skip\n\nsymbols:\n       actions        gold\n       move           melee\n       body           ranged\n       will           defense")
		print_stats(8,78)
		print("†:10",70,78,10)
		print_combat(78,84)
		print(" ‹ or arrow key\n ‘ or arrow key\n ” or arrow key\n ƒ or arrow key\n — or x key\n Ž or z key",4,30,7)
	elseif pmindex==2 then
		print("actions:\n\n\n\nmove:\n\n\n\nbody:\n\n\n\nwill:")
		print("2 actions per turn. menu\noptions use one action.\n\n\ntiles per action used. default\nis 6, effects can vary this.\n\n\ntotal damage player can take\nbefore dying.\n\n\ntotal mental damage player can\ntake before dying. also used\nfor magic defense.",8,30,7)
	elseif pmindex==3 then
		print("gold:\n\n\n\nmelee:\n\n\nranged:\n\n\ndefense:")
		print("total gold carried by player.\ncan be used to buy equipment.\n\n\nstrength of melee attack.\n\n\nstrength of ranged attack.\n\n\nstrength of defense against\nranged or melee attacks.",8,30,7)
	elseif pmindex==4 then
		print("\nspells:\n\n\n\nranged:\n\n\nmelee:\n\n\n\nsearch:")
		print("in game actions:",4,24,2)
		print("select spell from list then\nselect direction of target.\n\n\nselect direction of attack.\n\n\nselect direction of attack\nif using a 'diag' weapon.\n\n\nall visible tiles are checked\nfor secret doors, traps and\ntreasure.",8,36,7)
	elseif pmindex==5 then
		print("disarm:\n\n\npotion:\n\n\nend turn\n\n\nquit level:")
		print("visible traps are disarmed.\n\n\nuses vial if equipped.\n\n\nimmediately ends turn.\n\n\nreturns player to main menu.",8,30,7)
	end
	print("Ž menu",52,120,6)
	c=6
	if pmindex==1 then c=1 end
	print("‹ prev",12,120,c)
	c=6
	if pmindex==5 then c=1 end
	print("next ‘",92,120,c)
end
function draw_scroll(x,y,w,h)
	sspr(120,72,4,8,x,y)
	sspr(124,72,4,8,x+w,y)
	sspr(120,72,4,8,x,y+h)
	sspr(124,72,4,8,x+w,y+h)
	rectfill(x+4,y+1,x+w,y+h+6,7)
	line(x+4,y+7,x+4,y+h,0)
	pset(x+w,y+1,0)
	pset(x+w,y+h+6,0)
end
function start_palt()
	palt(0,false)
	palt(14,true)
end
function draw_newgame()
	draw_scroll(0,0,124,73)
	spr(143,17,7,1,1,false,false)
	spr(143,39,7,1,1,true,false)
	spr(143,39,29,1,1,true,true)
	spr(143,17,29,1,1,false,true)
	start_palt()
	sspr((pmindex-1)%2*16,64+(pmindex-1)\2*16,16,16,14+10,14)
	palt()
	char=characters[pmindex]
	print(char.name,10,40,8)
	print(char.description,10,50,0)
	print_stats(74,8,true)
	print_combat(104,14)
	if #player.spells==1 then s=" spell" else s=" spells" end
	print(#player.spells..s,74,40,0)
	for i=1,#char.init do
		item=items[char.init[i]]
		print(item.name,74,44+i*6,0)
	end
	if pmindex==1 then c=1 else c=6 end
	print("‹ prev",16,98,c)
	if pmindex==#characters then c=1 else c=6 end
	print("next ‘",88,98,c)
	print("— select",46,112,6)
	print("Ž cancel",46,120,6)
end
function draw_menu()
	draw_scroll(0,25,124,67)
	player_mission,m=player.levels[module],missions[module]
	for i=1,#m do
		c=1
		if i<=player_mission then
			c=5
		elseif i-1==player_mission then
			c=9
		end
		print(m[i].name,9,33+i*6,c)
	end
	if player_mission>=#missions[module] then
		print("all missions have\nbeen completed.\n\ntry again with\nanother character.",54,29,0)
	else
		print(m[player_mission+1].description,54,29,0)
	end
	print("—",36-sintime,96+pmindex*6,10)
	print("begin\nloadout\nshop\nmain menu",44,102,6)
end
function draw_game()
	px,py=player.x,player.y
	mx,my,tx,ty,trees,altspritesheet=px*8-py*8-56,py*8+px*4-py*4-64,px,py,max(0,mission.altspritesheet-1),min(1,mission.altspritesheet)
	while tx<32 do
		tx+=1
		if (board[tx][py].v>0) break
	end
	while ty<32 do
		ty+=1
		if (board[px][ty].v>0) break
	end
	if ty!=py+1 and board[px+1][py+1].v>0 then
		tx=px+1
	end
	for x=max(1,px-5),min(32,px+5) do
		for y=max(1,py-5),min(32,py+5) do
			tile=board[x][y]
			if tile.los then
				start_palt()
				dist=get_dist(x,y,px,py)
				for j=0,15 do
					c=j
					for k=1,dist-3 do
						c=col_drk1[c]
					end
					pal(j,c)
				end
				v,hflip,reverse,dx,dy=tile.v,tile.f or false,tile.r or false,x*8-y*8-mx,y*4+x*4-my
				if v!=18 then
					alt=16*(altspritesheet+trees*3)
					sspr(alt,0,16,8,dx,dy)
				end
				if v==1 or v==4 or v==17 then
					alt=16*altspritesheet
					if y>=ty or x>=tx then
						sspr(32+alt,0,16,8,dx,dy)
					else
						if trees==1 then
							sspr(56,96,16,24,dx,dy-16)
						else
							sspr(alt,8,16,24,dx,dy-16)
						end
						if v==17 then
							alt=0
							if (reverse) alt=8
							sspr(16+alt,48,8,16,dx,dy-9,8,16,hflip)
						end
					end
				elseif v>=2 and v<=3 then
					alt=16*altspritesheet
					sspr(32+alt,8,16,24,dx,dy-16,16,24,hflip)
					if v==2 then
						sspr(64,8,16,24,dx,dy-16,16,24,hflip)						
					end
				elseif v>=5 and v<=7 and tile.visible then
					sspr(0,v*8-8,16,8,dx,dy-1)
				elseif v==9 then
					sspr(16,32,16,16,dx,dy-9)
				elseif v>=10 and v<=15 then
					altr=0
					if (reverse) altr=16
					sspr(32+(v-10)*16,32+altr,16,16,dx,dy-9,16,16,hflip)
				elseif v==16 then
					sspr(16,32,16,16,dx,dy-9)
				elseif v==18 then
					if board[x-1][y-1].v==18 then
						sspr(80,16,16,8,dx+8,dy-8)
					elseif board[x+1][y-1].v==18 then
						sspr(80,0,16,8,dx,dy-4)
					elseif board[x-1][y].v==18 then
						sspr(80,24,16,8,dx,dy+4)
					else
						sspr(80,8,16,8,dx-8,dy+8)
					end
				end
				if x==px and y==py then
					p=player.index-1
					sspr(p%2*16,p\2%2*16+64,16,16,dx-1,dy-10,16,16,player.f)
				end
				for i=1,#monsters do
					mon=monsters[i]
					if x==mon.x and y==mon.y then
						sspr((mon.v-1)%5*16+32,(mon.v-1)\5*16+64,16,16,dx-1,dy-10,16,16,mon.f)
					end
				end
				palt()
				pal()
			end
		end
	end
	draw_scroll(8,99,108,21)
	print_messages(14,101)
	print_stats(8,16)
	print("†:"..player.gold,8,94,10)
	if pmenu then
		draw_scroll(72,14,64,78)
		dx=79-sintime
		print("Ž",dx,16,9)
		print("—",dx,16+pmindex*6)
		if pmspells then
			print("cancel",88,16,0)
			for i=1,#player.spells do
				print(spells[player.spells[i]].name,88,16+i*6)
			end
		else
			function getc(check)
				if (player.a>0 and check) return 0
				return 5
			end
			print("cancel\n\n\n\n\n\n\nend turn\n---\nquit level",88,16,0)
			print("spells",88,22,getc(has_spells()))
			print("ranged",88,28,getc(has_ranged_weapon()))
			print("melee",88,34,getc(has_diag_weapon()))
			print("search",88,40,getc(true))
			print("disarm",88,46,getc(player.disarm))
			print("potion",88,52,getc(has_potion()))
		end
	elseif ptarget8 or ptarget4 then
		start_palt()
		d,dx,dy=dir8[ptdir],px*8-py*8-mx+2,py*4+px*4-my
		xless,xmore,tx,ty,sx,sy=d.x<0 or d.y>0,d.x>0 or d.y>0,d.x*8-d.y*8,d.x*4+d.y*4,88,112
		if ptarget8 then
			if abs(d.x)+abs(d.y)>1 then
				sx=72
				if d.y!=d.x then
					dx-=sgn(d.x)*8
					sx=80
				end
			end
			sspr(sx,sy,8,8,dx+tx,dy+ty,8,8,xless,xmore)
		else 
			sspr(96,112,8,8,dx+tx,dy+ty,8,8,xless,xmore)
			sspr(88,112,8,8,dx+tx*2,dy+ty*2,8,8,xless,xmore)
		end
		print("Ž\n—\n‹\n‘",79-sintime,24,10)
		print("cancel\naction\nleft\nright",88,24)
		palt()
	else
		print_combat(112,16)
	end
end
function print_messages(x,y)
	for i=1,#messages do
		print(messages[i],x,y+i*6-6,0)
	end
end
function print_stats(tx,ty,maxmove)
	pa,pm,pb,pw=2,6,5,5
	if player then
		pa,pm,pb,pw=player.a,player.move or 6,player.body,player.will
		if maxmove then
			pm=6+player.maxmove or 0
		end
	end
	print("“:"..pa,tx,ty,7)
	print("‰:"..pm,tx,ty+6,5)
	print("‡:"..pb,tx,ty+12,8)
	print("ˆ:"..pw,tx,ty+18,9)
end
function print_combat(tx,ty)
	spr(190,tx-8,ty-2)
	spr(191,tx-8,ty+4)
	spr(175,tx-8,ty+10)
	at,sh,df=3,1,2
	if player then
		at,sh,df=player.atk+player.modatk,player.sht+player.modsht,player.def+player.moddef
	end
	print(":"..at,tx,ty,12)
	print(":"..sh,tx,ty+6,13)
	print(":"..df,tx,ty+12,11)
end
function check_visible_tiles_for(func,len)
	len=len or 5
	for x=max(1,player.x-len),min(32,player.x+len) do
		for y=max(1,player.y-len),min(32,player.y+len) do
			tile=board[x][y]
			if tile.los then
				func(tile,x,y)
			end
		end
	end
end
function open_door(tile,x,y)
	if tile.v==2 then
		tile.v=3
		sfx(4,0)
	end
end
function search_secret_door(tile,x,y)
	if tile.v==4 then
		init_message("found secret door")
		tile.v,tile.f,found=2,board[x][y-1].v==1,true
	end
end
function search_hidden_traps(tile,x,y)
	if tile.v>=5 and tile.v<=7 and not tile.visible then
		init_message("found trap")
		tile.visible,found=true,true
	end
end
function search_disarm_traps(tile,x,y)
	if tile.v==5 or tile.v==7 then
		init_message("found and disarmed trap")
		tile.v=0
	end
end
function is_activesave()
	return dget(0)>0
end
function is_dead()
	return player.body<1 or player.will<1
end
function is_empty(x,y)
	return not is_solid(x,y) and get_creature(x,y)==nil
end
function is_solid(x,y)
	local tile=board[x][y]
	local i=tile.v
	return i==1 or i==4 or (i==6 and tile.visible) or i>7
end
function is_opaque(x,y)
	local tile=board[x][y]
	local i=tile.v
	return i==1 or i==2 or i==4 or (i==6 and tile.visible) or i==17
end
function get_empty_tile(tx,ty)
	d=clone(dir8)
	for i=#d,1,-1 do
		dr=d[i]
		dx,dy=tx+dr.x,ty+dr.y
		if not is_empty(dx,dy) then
			del(d,dr)
		end
	end
	if #d>0 then
		dr=rnd(d)
		return tx+dr.x,ty+dr.y
	end
	return
end
function get_creature(x,y)
	for q=1,#monsters do
		monster=monsters[q]
		if x==monster.x and y==monster.y then
			return monster
		end
	end
	if player.x==x and player.y==y then
		return player
	end
	return nil
end
function has_potion()
	return sub(items[player.equipped[5]].name,1,4)=="vial"
end
function has_wand()
	return items[player.equipped[5]].name=="magic wand"
end
function has_spells()
	return #player.spells>0
end
function has_ranged_weapon()
	return items[player.equipped[4]].sht>0
end
function has_diag_weapon()
	return items[player.equipped[3]].diag
end
function contains(tx,ty,x1,y1,x2,y2)
	return not(tx<x1 or tx>x2 or ty<y1 or ty>y2)
end
function clone(t)
	local table,k,v={}
	for k,v in pairs(t) do
		table[k]=v
		if type(v)=="table" then
			table[k]=clone(v)
		end
	end
	return table
end
function shuffle(t)
	local table,r={}
	while #t>0 do
		r=ceil(rnd(#t))
		add(table,t[r])
		del(t,t[r])
	end
	return table
end
__gfx__
eeeeee6655eeeeeeeeeeee4444eeeeeeeeeeee5555eeeeeeeeeeee2222eeeeeeeeeeee3333eeeeeeeeeeeeeeeeeeeedd11111111111111111111111111111111
eeee66556655eeeeeeee44444444eeeeeeee55555555eeeeeeee22222222eeeeeeee33333333eeeeeeeeeeeeeeeedd0010000000000000000000000000000001
ee665566556655eeee444444244444eeee555555555555eeee222222222222eeee333333333333eeeeeeeeeeeedd000010111111111111111101111111111101
66556655665566554444444444444444555555555555555522222222222222223333333333333333eeeeeeeedd00000010100000100000000101000000000101
55665566556655664444224444424444555555555555555522222222222222223333333333333333eeeeeedd000000dd10100000100000000101000000000101
ee556655665566eeee444424444444eeee555555555555eeee222222222222eeee333333333333eeeeeedd000000dddd10100000100000000101111111111101
eeee55665566eeeeeeee44444444eeeeeeee55555555eeeeeeee22222222eeeeeeee33333333eeeeeedd000000000ddd10100000100000000101001000100101
eeeeee5566eeeeeeeeeeee4444eeeeeeeeeeee5555eeeeeeeeeeee2222eeeeeeeeeeee3333eeeeeedd000000000dd0dd10100000111111111101001000100101
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee550000000ddddd0d10100000100001000101001000100101
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee550000000dddd010100000100001000101111111111101
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee550055500ddd10111111111111000100000000000001
eeeeee1111eeeeeeeeeeee1111eeeeeeeeeeee11eeeeeeeeeeeeee11eeeeeeeeeeeeeeeeeeeeeeeeeeeeee550055500d10000000000001000101111111111101
eeee11111111eeeeeeee11111111eeeeeeee111111eeeeeeeeee111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeee5500550010111111111101000101000100000101
ee111111111111eeee111111111111eeee1111111111eeeeee1111111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeee55007710100000000101000101000100000101
11111111111111111111111111111111eedd1111111111eeee441111111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeee777710100000000101111101000100000101
11111111111111111111111111111111eedd2211111111eeee442211111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7710100000000100000001111100000101
66111111111111114411111111111122ee1d21ee111122eeee4212ee111122eeeeeee444eeeeeeee66eeeeeeeeeeeeee10100000000100000001000100000101
666611111111dd1d4444111111112222eed112eeeedd22eeee4422eeee4422eeeeeee44444eeeeee0066eeeeeeeeeeee10100000000101111101000111111101
5566661111dddd1d4244441111222222eedd22eeeedd22eeee4422eeee4422eeeeeee44444eeeeee000066eeeeeeeeee10100000000101000101000100000101
66556656dddd11d14442444422222221eedd22eeee1d21eeee4421eeee2421eeeeeee44444eeeeee06600066eeeeeeee10111111111101000101000100000101
66565556dd113ddd4444444422223222ee1d21eeeed112eeee4422eeee4422eeeeeee44444eeeeee0666600066eeeeee10000000000001000101111111111101
66566655111ddddd4444442422222222eed112eeeedd22eeee4222eeee4422eeeeeee49444eeeeee066660660066eeee10111111111111111100000000000001
555b6665dd1ddd1d422b444212212222eedd22eeeedd22eeee4422eeee4422eeeeeee49444eeeeee06660666600077ee10100010001000000101111111111101
6655b666dd1d11114422b44422222222eedd22eeee1d21eeee4422eeee4422eeeeeee44444eeeeee066066600077777710100010001000000101000001000101
66665565dd11dd1d4442244422222212ee1d21eeeed112eeee2412eeee4422eeeeeee44444eeeeee060660007777777710100010001000000101000001000101
66665655113ddd1d2444444422322122eed112eeeedd22eeee4422eeee4422eeeeeee44444eeeeee00600077777777ee10111111111000000101000001000101
55665666dddddd1d4444424422222222eedd22eeeedd22eeee4422eeee4412eeeeeee44444eeeeee060077777777eeee10100000001000000101111111000101
65555666dddd11314424444422222232eeed2eeeee1d21eeeee42eeeee4222eeeeeee44444eeeeee0077777777eeeeee10100000001000000101001001000101
65b6556ddd11dddd44b4444212222222eeeeeeeeeed112eeeeeeeeeeee4422eeeeeeee4444eeeeee77777777eeeeeeee10100000001000000101001001000101
ee6666dd111dddeeee444422221222eeeeeeeeeeeedd22eeeeeeeeeeee4422eeeeeeeeee44eeeeee777777eeeeeeeeee10111111111111111101111111111101
eeee6666dd1deeeeeeee44442222eeeeeeeeeeeeeeed2eeeeeeeeeeeee242eeeeeeeeeeeeeeeeeee7777eeeeeeeeeeee10000000000000000000000000000001
eeeeee66ddeeeeeeeeeeee4422eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77eeeeeeeeeeeeee11111111111111111111111111111111
eeeeee0000eeeeeeeeeeeeeeeeeeeeeeee004400e000eeeeee004400eeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeee00dd00eeeeeeeeeeeeee09900eeeee
eeee0055dd00eeeeeeeeeeeeeeeeeeeee044444406660eeee04444440eeeeeeeeeeeeeeeeeeeeeeee0440e0e0eeeeeeee0dddddd00eeeeeeeeeeee0484400eee
ee005555d5dd00eeeeeeeeeeeeeeeeeee05c4444416160eee0dd4444400eeeeeeeeeee00eeeeeeee04444040d0eeeeee0d44dddddd00eeeeeeeeee04888990ee
00155555d5dddd00eeeeee7777eeeeeee0578244466660eee0d4dd4444400eeeeeee005500eeeeeee0440040d0eeeeee0d4544dddddd00eeeeeeee04888dd0ee
5515551155ddddd5eeee77777777eeeee05c82b3464640eee06445dd444440eeeee064411100eeeee044004ddd00eeee0d4ddd44dddddd0eeeeeee04888dd0ee
55151151dd55ddd5ee777777777777eee05ca9b3c44550eee0644544d44550eeee064444415500eee055040060440eee0d45d65544dddd0eeeeeee04888dd0ee
ee115551dddd55ee7777777777777777e0448265755150eee0d44544d55550eee06444444611150ee0445400644440ee0d4666d5514dd50eeeeeee02288dd0ee
eeee55515dddeeee7777777777777777e05844b3c51550eee0d44544655550eeee006444611110eee044045560440eee0d4d6adddd4d550eeeeee008822dd0ee
eeeeeeee00eeeeee66777777777777dde058c144c51150eee0d49544655550eee06600665110050ee044040065440eee0d4669a9ad4d550eeee00888888dd0ee
eee00000110000ee666677777777dddde05ac176451550eee0644594d55550eee06466005001150ee055040060550eeee0469a999d4d550eee028888888220ee
ee0555501110220ee666667777dddddee0586d76855550eee0644544d55550eee064a4660111150ee044554060440eeeeeeeee9aa94d550eee042288822dd0ee
e000555500002220edd66666ddddd11eee44c150851550eeeed44544d55550eee06444465111150eee44004560440eeeeeeeeeee9a4d550eee0488222dddd0ee
0ddd055506660220edddd666ddd1111eeeee4466a51150eeeeee4544655550eeee044446511110eeeeeee04065440eeeeeeeeeeeee4d550eee048884dd02d0ee
e0dd05550666600eeedddddd111111eeeeeeee44851510eeeeeeee44655550eeeeeee446511eeeeeeeeeeee060550eeeeeeeeeeeee4d50eeee048884d0e0deee
ee005550006660eeeeeedddd1111eeeeeeeeeeee451150eeeeeeeeeed55550eeeeeeeee65eeeeeeeeeeeeeeee044eeeeeeeeeeeeeeed0eeeeee02e84deeeeeee
eeee000060000eeeeeeeeedd11eeeeeeeeeeeeeee5500eeeeeeeeeeee5500eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4deeeeeee
eeee000eee000eeeeeeeeeeeeeeeeeeeee004400ee000eeeee004400eeeeeeeeeeeeeeeeeeeeeeeeee00e0eeeeeeeeeeee00dd00eeeeeeeeee09900eeeeeeeee
e0000d0e000d000e4ddeeeeeeeeee44de0444444006660eee04444440eeeeeeeeeeeeeeeeeeeeeeee0440d0eeeeeeeeee0dddddd00eeeeeeee0dd4400eeeeeee
e0400d00040d040e444ddeeeeee44ddde0554444466660eee0554444400eeeeeeeeeee00eeeeeeee04444d00eeeeeeee0555dddddd00eeeeee0dddd990eeeeee
e04400d04400440e4ff44ddee44ddddde0d65544466660eee0dd554444400eeeeeee005500eeeeeee044ddd40eeeeeee055555dddddd00eeee0dddddd0eeeeee
e00440d04004400e4fff444d4ddddddde06d6655446460eee0dddd55444440eeeee064411100eeeee04406040e00eeee05555555dddddd0eee0dddddd0eeeeee
ee004400404400ee4f77ff4d4ddddddde055d6d6544550eee0dddddd544550eeee064444415500eee055060400440eee0555555555dddd0eee0dddddd0eeeeee
eee0040440400eee4f77ff4d4ddddddde0dd556d655150eee0ddddddd55550eee06444444611150ee0445500444440ee055555555555dd0eee0dddddd0eeeeee
eeeeee0400eeeeee4fffff4d4ddddddde0dddd55d55110eee0ddddddd55550eeee006444611110eee044065540440eee055555555555dd0eee0dddddd00eeeee
00000000000000004f88ff4d4ddddddde0dddddd551150eee0ddddddd55550eee06600665110050ee044060045440eee055555555555dd0eee0dddddd8800eee
00000000000000004f888f4d4ddddddde055ddddd55150eee0ddddddd55550eee06466005001150ee055060040550eeeee5555555555dd0eee0dddddd88820ee
0000000000000000444fff4d4dddddeee0d655ddd55550eee0ddddddd55550eee06444660111150ee044550400440eeeeeee55555555dd0eee0dddddd82240ee
0000000000000000eee44f4d4ddddeeeee6d6d55d55150eeeeddddddd55550eee06444465111150eee44065400440eeeeeeeee555555dd0eee0d2dddd2dd40ee
0000000000000000eeeee44e4ddeeeeeeeeed6d6555150eeeeeeddddd55550eeee044446511110eeeeeee00455440eeeeeeeeeee5555dd0eee0d20dddd0240ee
0000000000000000eeeeeeeeeeeeeeeeeeeeeed6651550eeeeeeeeddd55550eeeeeee446511eeeeeeeeeeee000550eeeeeeeeeeeee55d0eeeee02e0dd0e240ee
0000000000000000eeeeeeeeeeeeeeeeeeeeeeeed55150eeeeeeeeeed55550eeeeeeeee65eeeeeeeeeeeeeeee044eeeeeeeeeeeeeee50eeeeeeeeeeddee20eee
0000000000000000eeeeeeeeeeeeeeeeeeeeeeeee5500eeeeeeeeeeee5500eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddeeeeeee
eeeee0eee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000e0eeeeeeee000e0eeeeeeeeeeeee000eeeeee0000000090900000
eeee06000600eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000e0eeeeeeeeeee000bbb030eeee000bbb0b0eeeeeeeeeee0bbb0eeeee0000000009999999
eeee056560060eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000bbb030eeeeeeeee0bbb3bbb0eeee0bbb0bbb0eeeeeeee0ee0bbbbb0e0ee0000000099aaaaaa
eee05555505610eeeeeee0000eeeeeeeeeeee000e0eeeeeee0bbb3bbb0eeeeeeeee0e03bb8b80eeeee03bb8b80eeeeeee0b0e0bb8b800b0e0000000009a44444
eee05f15105610eeeee0055550eeeeeeee000bbb0b0eeeeeee03bb8b80eeeeeeee030503bbbb0eeeeee03bbbb0eeeeee0b3b000bbbb0b3b00000000009a40000
eee05ff5f05610eeee0556fff0eeeeeee0bbb3bbb0eeeeeeeee03bbbb0eeeeeee066300bbbbb0eeeeee0bb7b70eeeeee0b33b0b1b1b3b3b00000000009a40000
eee044fff05610eee0506f1f10eee0eeee03bb8b80eeeeeeeeee0b7b70eeeeeeee033000b310eeeeeeee0b310eeeeeee0b331101b1b1b3b00000000009a40000
eeee0f44005610eee05055fff0e0070eeee03bbbbb0eeeeeeeee00b30eeeeeeeee063334bb340eeeeee0bbbbb0eee00e0b331bbb1b11b3b00000000009a40000
eee0fffff05610eeee0e05555004670eeeee0bbbb0eeeeeeeeee065650eeeeeee06033bbd5dbb0eeee0bbbbbbb0e04400b31bbbbbb3103b00000000000000000
ee0fff444d5610eeeeee04455404670eeeee00b300eee0eeeee06565650eeeeeee0e03bb565bb0eee0bbb3bb3b3044400b00bb3bbbb300b00000000004707740
e0ffdff4fd44440eeee044445404070eeee0b444430e060eee0b0656530000eeeeee0b0bd5db030ee0bb33bbb133440ee00bb3bbbbb3330e0055500044470774
e0ff0ffff0dff0eeee040cccccdd00eeee0b0544503060eeee0b05656434440eeeee0b04bbb4030e0bb03bbbb03440eee05bb0bbbb0033500055500044470774
e0fd0444400ff0eeee04044444040eeeee0b044440030eeeee0b06565006660eeeee0b0bbbbb030e0bb0bbbbb0330eeeee0505bb0bb5050e0555550044470774
ee000f00f0040eeeeee0080080e0eeeeeee00b00b040eeeeeee00b00b0e000eeeeeee00bb0bb00eee000b30b3040eeeeeee0e0bb0bb0e0ee0055500044470774
eeee040040eeeeeeeeee080080eeeeeeeeee0400400eeeeeeeee040040eeeeeeeeeeee0440440eeeeee0bb0bb00eeeeeeeee05b505b50eee005050000470f740
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
eeeeee0000eeeeeeeeee000eeeee0eeeeeeeee000eeeeeeeeeeeee000eeeeeeeeeeeee000eeeeeeeee0eeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000
eeee0088880eeeeeeee0ccc0eee0a0eeeeeee07770eeeeeeeeeee0abb0eeeeeeeeeee07ff0eeeeeee070ee070eeeeeeeeeee0eeee0eeeeee008888000bbbbbb0
eee0f8ffff00eeeeee0ccc110eee0eeeeeee0677770eeeeeeeee03bbbb0eeeeeeeee07f7770eeeeee06700060eeeeeeeeee070ee070eeeee088888800bbbbbb0
eeee0ff3f3040eeee0cc1cccc0e040eeeeee0675750eeeeeeeee03b3b30eeeeeeeee0f75f50eeeeeee067770eeeeeeeeeee06700060eeeee008088800bbbbbb0
eee008ffff040eeee0c0ccccc0e040eeeeee0677570eeeeeeeee03bb3b0eeeeeeeee0777770eeeeeee078780eeee0eeeeeee067770eeeeee080888800bbbbbb0
ee07088fff0400eeee00cc3f3100430eeeeee067770eeeeeeeeee03bbb0eeeeeeeeee07f770eeeeeee0077700ee070eeee00078780e000ee0888880000bbbb00
e0704088b00040eeee0c0ffff00b40eeeeeeee0760eeeeeeeeeeee0b30eeeeeeeeeeee0770eeeeeee06607705007640ee0f8007770088f0e08080000000bb000
ee0444b8bb0040eeeee000fff0e040eeeeeee077770eeeeeeeeee0bbba0eeeeeeeeee077f70eeeee0666600615764440e0888a07708080ee0000000000000000
eee04b8bbb3040eeeeee0a000e040eeeeeee07667650eeeeeeee0babbb30eeeeeeee07977940eeee0556656611044670ee0888a009080eee0000000000000000
eeee0bbbbb0330eeeee0aca0900f0eeeeeee07777750eeeeeeee0b3bb330eeeeeeee077f9750eeee066556601544670eeee0088aa800eeee00000cc0000dd000
eee0b044440040eeee0accc0191440eeeee070067650eeeeeee0b0bbab30eeeeeee070777f40eeee06615660555070eeeee0808aa80eeeee0000ccc0000d0d00
eee0b0bbbb0040eeee0ac1c019140eeeeee0707777050eeeeee0a03bb3030eeeeee0707977050eee05601550450e0eeeeee08088080eeeee000ccc000dddddd0
eee0b0bbbb040eeeee0ac1c019040eeeeee070777700eeeeeee0b0bbbb00eeeeeee0f0f77700eeeee000666000eeeeeeeee08888080eeeee0c0cc0000dddddd0
eeee004004040eeeee0ac1c019040eeeeeee0070070eeeeeeeee00a00b0eeeeeeeee0070090eeeeeee0666060eeeeeeeee088888080eeeee00c00000000d0d00
eeeee04004040eeee0ac1ccc19140eeeeeeee070070eeeeeeeeee0b00b0eeeeeeeeee0f0070eeeeeee0660560eeeeeeee08888888080eeee0c0c0000000dd000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
00ddd0000000000d000000000000000000ddd0000000000000000000eeeeeeebbebeeeee00000000000000000000000000000000000000000000000000000000
00d11d000000000d000000000000000000d11d000000000000000000eeeeebeb333eeeee05550550000000000000000550555500000000000000000000000000
00d00d00dd00dd0d0d0dd000dd00d00d00d00d0d00d0d0dd000dd000eeeebe333b33eeee55aaaa550000000000000055aaaaa550000000000000000000000000
00d00d0d1d0d110dd10d1d0dd10d10d100ddd10d0d10d0d1d0d1d000eeeeb333b33e3eeebaa99aa5b5055b5505555b5aa999aa55550555b55500555b50555b50
00d00d0d0d0d000d1d0d0d0d1001d01d00d00d0d01d0d0d0d01dd000ee3beb3b3b33bebe5aa55aa3aa55aaa55aaaa5baa355aa5aa55aab5aaa555aaa5aaaaaa5
00ddd10ddddd000d0d0d0d0ddd0d10d100d00d0d0d10d0d0d001d000ebe33bb313b333ee5a7357a3aa5aa995aa99aa5aa535aa5aa55aa5aa9aa5aa99599aa995
00111001111100010101010111010010001001010100101010dd1000eeb3bb13bb1113ee07777793775a75357753aa5a755b775a7557a5a7777577555557a555
00000000000000000000000000000000000000000000000000110000ee33bbb133bb333e57799935773775537735775775757757735773779995977551b77511
0000bb000000b000b000000000000bb0b00000000000000b000b0000eeeb3b31b3333be35aa55355aa5aab5baa55aa5aa59aaa3aa5baa5aa533539aa51baa500
000b33000000b000b000000000000b3b3b0000000000000b000b0000e3bbb3b11b33113e5aa51125aa5aa5b5aa55aa5aa559aa5aa5baa5aa555b55aa115aa000
000b00000b00bb00b0b0bb000b000b0b0b00bb00bb00bb0bb00b0000beb3331bb33b113ebaa50005aa59aaab9aaaa959aaaaa9a9aaaaa59aaaabaaa9515aa500
000b0bb0b3b0b3b0b0b0b3b0b3000b0b0b0b3b0b330b330b3b030000eb33b22b111133ee59910005995599935999955599999595999995599995999551599300
000b03b0b0b0b0b0b0b0b0b03b000b0b0b0b0b0b000b000b0b000000e3e332b333313e3e55550001555155355555551555351155155355515555355511555500
0003bb303b30bb30b0b0b0b0b3000b0b0b0bbbbb0003bb0b0b0b0000eebb3b233b3333be11110000111012111111110112110011011211101111211101111100
00003300030033003030303030000303030333330000330303030000ebe3b32b311b3e3e00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000e3eb33221111e3ee00000000000000000000000000000000000000000000000000000000
00007770000000007000000000000000700070000000700070000000eeeee2222221eeeeeee00eeeeeee0eeeeeeeeeeeeeeeeeee000000000000000000000000
00005750000000007000000000000000770070000000700070000000eeeee4242122eeeeee0770eeeee070eeee00000eeeeeee00000000000000000000000000
00000700070077007700000700077000757070700770770077700000eeee424442222eeee077770e0000070ee0777770eeee0077000000000000000000000000
00000700757077707570007570755000705770707570757075500000eee44444242212ee0707707077777770ee007770ee007775000000000000000000000000
00000700707075707070007070770000700570705770707070000000eee422441221e1eee007700e777777700077757000777500000000000000000000000000
00000700575070707770005750750000700070700570707057700000ee44ee442e122eeeee0770ee0000070e77750070777500ee000000000000000000000000
00000500050050505550000500500000500050507750505005500000eeeee44122ee22eeee0770eeeee070ee7500e0507500eeee000000000000000000000000
00000000000000000000000000000000000000005500000000000000eeeeee442eeeeeeeee0770eeeeee0eee00eeee0e00eeeeee000000000000000000000000
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
002000080012500100021150312500135011000013500100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
002000101373500705107251273513745007050070500705137350070013725127351074500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500700
002000001802500000180151a0151c0150000018025000001c0151d0151f0151d0251c0151801018015000051c025000001c0151d0151f015000051a025000051f0151d0151c0151a0251c015180101801500000
0002000018f7012f700cf7008f7000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f00
0005000007f730000007f730000000f0300f0300f0300f0300f0300f0300f0300f0300f0300f0300f0300f0300f0300f0300f0300000000000000000000000000000000000000000000000000000000000000000
000800002471500700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
002000100751007510075150050005510055100551500500045100451004515005000251002510025150050000000000000000500000000000000000005000000000000000000050000000000000000000000000
0002000013f500cf5007f5504f50070000700007005000000500005000050050000004000040000400500000090000900009005000000b0000b0000b005000000d0000d0000d005000000a0000a0000a00000000
000c000018623176030e6030e6030f6030f6030b6030b6030f6030f6030b6030b6030f6030f6030b6030b6030f6030f6030e6030c6030d6030e6030d6030c6030d6030b6030e6030b6030b6030b6030d60300603
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
01 00 42 43 44
00 00 06 43 44
00 00 01 43 44
00 00 01 02 44
02 00 01 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
