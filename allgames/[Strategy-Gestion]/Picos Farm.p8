pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- pico's farm
-- fuwaneko games

function _init()
	music(0)
	pal(0,128,1) -- force disrupt
	pal()
	camera(96*8,0)
	
	fading=0
	fadespeed=5
	
	--sprite consts
	dirt=14
	path=15
	sgrass=10
	lgrass=11
	tree=129
	field=154
	solid_dirt=13
	fence=147
	wood=32
	chicken=163
	money=48
	stone=114
	axe=27
	hoe=28
	seeds=107
	seedling=130
	sprout=156
	plant=158
	rent=200
	days_to_rent=7
	gold=50
	
	--int consts
	sx=5 --start x
	sy=6 --start y
	t=0 --tick
	fr=8 --animation speed
	mw=63 --map width
	mh=31 --map height
	tree_flag=1 --flag for tree
	stone_flag=2 --flag for stone
	sell_spot=3 --flag for shipping
	craft_spot=4 --flag for crafting
	growth_time=600
	
	--anim consts
	idled={184,185}
	idler={186,187}
	idlel={188,189}
	idleu={190,191}
	walkd={176,177}
	walkr={178,179}
	walkl={180,181}
	walku={182,183}
	
	--misc consts
	h={-1,1,0,0}
	v={0,0,-1,1}
	walkdir={walkl,walkr,walku,walkd}
	idledir={idlel,idler,idleu,idled}
	mapobj={}
	mobs={}
	fields={}
	blips={}
	inventory={}
	tools={
								{name="scythe",sp=axe,use=tool_harvest},
								{name="hoe",sp=hoe,use=tool_plow},
								{name="seeds",sp=seeds,use=tool_seeds}
							}
	current_tool=1
	titleobj={}
	fade={[0]=0,17,18,19,20,16,22,6,24,25,9,27,28,29,29,31,0,0,16,17,16,16,5,0,2,4,0,3,1,18,2,4}
	--vars
	cx=0 --camera x
	cy=0 --camera y
	hours=6
	minutes=0
	am_pm="am"
	day=1
	menu_choice=1
	main_menu = {
														{"start",start_game},
														{"instructions",instructions},
														{"credits",credits}
													}
	
	setup_asciitables()
	init_player()
	init_map()
	init_title()
	
	instruct = {
												{"welcome!","grow crops to sell off and:make rent each week!:it'll increase over time:& with each thing you build:how long can you last?"},
												{"tools","scythe - harvest crops:hoe - plow fields:seeds - plant 'em: :stand in front of:the box by your house:to sell crops!"},
												{"controls","‹‘”ƒ movement:— use tool:Ž open/close inventory"}
												}
	current_instruct=1
	
	shop={
						{"seeds - $2",plant,2,"gold","seeds",1},
						{"fence - 5 wood",fence,5,"wood","fences",1},
						{"path - 4 for $1",path,1,"gold","paths",4}
						}
	current_shop=1
	
	profits=0
	
	_drw=draw_title
	_upd=update_title
end

function _draw()
	_drw()
	draw_debug()
end

function _update()
	t+=1
	_upd()
end

function init_player()
	plyr={}
	plyr.x=sx*8
	plyr.y=sy*8
	plyr.mx=sx
	plyr.my=sy
	plyr.anim=idled
	plyr.dir=3
	plyr.spr=plyr.anim[1]
end

function init_map()
	mapweights={dirt,dirt,dirt,dirt,dirt,dirt,dirt,dirt,sgrass,sgrass,sgrass,sgrass,lgrass,lgrass,path,tree}
	
	for x=0,mw do
		for y=0,mh do
			if x==0 or x==mw or y==0 or y==mh then
				add_mob(fence,x,y,2)
				mset(x,y,solid_dirt)
			else
				tile=rnd_array(mapweights)
				if tile!=dirt and tile!=tree and mget(x,y)==dirt then
					if tile==path then
						mset(x,y,path)
					else
						add_obj(tile,x,y)
					end
				end
				if tile==tree and mget(x,y)==dirt then
					add_mob(tile,x,y,1)
					mset(x,y,tree)
				end
			end
		end
	end
end

function draw_debug()
	--printo(#fields,cx+64,cy+120,7,2)
end

function init_title()
	
	
	for i=96,127 do
		for j=0,31 do
			_t=mget(i,j)
			
			save_tile=false
			outline=0
			
			if _t==sgrass or _t==lgrass then
				mset(i,j,dirt)
				save_tile=true
			end
			if _t==tree or _t==chicken or _t==174 then
				mset(i,j,dirt)
				save_tile=true
				outline=1
			end
			if _t==fence then
				mset(i,j,dirt)
				save_tile=true
				outline=2
			end
			if _t==sprout or _t==plant then
				mset(i,j,field)
				save_tile=true
				outline=3
			end
			
			if save_tile then
				tile={}
				tile.sp=_t
				tile.x=i
				tile.y=j
				tile.o=outline
				add(titleobj,tile)
			end
		end
	end
end

function start_game()
	_upd=update_fade
	_drw=draw_fade
	next_upd=update_newday
	next_drw=draw_newday
	music(8)
	--add_inventory("seeds",20)
	--add_tool("destroy",72,tool_destroy)
end

function instructions()
	_drw=draw_instructions
	_upd=update_instructions
end

function draw_instructions()
	map()
	scroll_tile(139)
	_tx=split(instruct[current_instruct][2],":")
	bigwin(instruct[current_instruct][1],96*8+8,8,112,112,1,6,13)
	for i=0,#_tx-1 do
		print(_tx[i+1],96*8+12,24+i*12,7)
	end
	
	printo(current_instruct.."/"..#instruct,96*8+12,112,7,0)
	if current_instruct==1 then
		ntx="next ‘ - Ž close"
	else
		if current_instruct==#instruct then
			ntx="‹ prev"
		else
			ntx="‹ prev - next ‘"
		end
	end
	printo(ntx,96*8+36,112,7,0)
end

function update_instructions()
	if btnp(Ž) then
		_upd=update_title
		_drw=draw_title
	end
	if btnp(‹) then
		current_instruct-=1
	end
	if btnp(‘) then
		current_instruct+=1
	end
	current_instruct=mid(1,current_instruct,#instruct)
end

function credits()
	_upd=update_credits
	_drw=draw_credits
end

function draw_credits()
	map()
	scroll_tile(139)
	bigwin("credits",96*8+8,8,112,112,1,6,13)
	_tx=split("made by @fuwaneko games:for toyboxjam2020:thanks to-:@thattomhall:@dw817:zep:the pico-8 community",":")
	for i=0,#_tx-1 do
		print(_tx[i+1],96*8+12,24+i*12,7)
	end
	printo("close Ž",96*8+12,112,7,0)
end

function update_credits()
	if btnp(Ž) then
		_upd=update_title
		_drw=draw_title
	end	
end
-->8
--draw

function draw_title()
	
	if fading==0 then
		cls()
		
		map()
		camera(96*8,0)
		--[[
		for _t in all(titleobj) do
			if _t.o!=0 then
				ospr(_t.sp,_t.x*8,_t.y*8,_t.o)
			else
				spr(_t.sp,_t.x*8,_t.y*8)
			end
		end
		]]--
	else
		fadeout()
	end
	
	scroll_tile(139)
	
	dsprintxy(" pico's ",96*8,8,7,1,1)
	dsprintxy("  farm  ",96*8,24,7,12,12)

	for i=1,#main_menu do
		if menu_choice == i then 
			cl=12
			off=12
		else
			cl=1
			off=0
		end
		
		mo=main_menu[i]
		sprintxy("                ",96*8,48+i*12,7,cl,cl)
		sprintxy(mo[1],96*8+off+2,48+i*12,7,cl,cl)
	end
	
	print("@fuwanekogames",96*8+4,120,7,2)
end

function draw_main()
	cls()
	map()
	
	for o in all(mapobj) do
		spr(o.kind,o.x*8,o.y*8)
	end
	
	for o in all(mobs) do
		ospr(o.kind,o.x*8,o.y*8,o.outline)
	end
	
	if #fields>0 then
		draw_fields()
	end
	
	player_anim()
	ospr(plyr.spr,plyr.x,plyr.y,1)
	
	draw_hud()
	
	cx=plyr.x-64
	cy=plyr.y-64
	
	for b in all(blips) do
		b.life-=1
		if b.life<=0 then
			del(blips,b)
		end
		
		b.y-=.5
		ospr(b.sp,cx+b.x-8,cy+b.y-1,b.c)
		printo(b.txt,cx+b.x,cy+b.y,7,b.c)
	end
	
	camera(cx,cy)
	
	if plyr.mx==7 and plyr.my==5 then
		if inventory.plant!=nil and inventory.plant>0 then
			gold+=inventory.plant*2
			profits+=inventory.plant*2
			sfx(4)
			add_blip("+"..inventory.plant*3,64,64,money,3)
			inventory.plant=0
		end
	end
end

function draw_fade()
	fadeout()
end

function draw_hud()
	if #tostr(hours)==1 then
		ht="0"..hours
	else
		ht=hours
	end
	if #tostr(minutes)==1 then
		mt="0"..minutes
	else
		mt=minutes
	end
	
	if gold<10 then
		gt=" $000"..gold
	else
		if gold<100 then
			gt=" $00"..gold
		else
			if gold<1000 then
				gt=" $0"..gold
			else
				if gold<10000 then
					gt=" $"..gold
				else
					gt=" $9999+"
				end
			end
		end
	end
	
	sprintxy(" "..ht..":"..mt..am_pm,cx+3,cy+3,7,6,1)
	ospr(160,cx+2,cy+2,1)
	sprintxy(gt,cx+8,cy+10,7,6,1)
	ospr(48,cx+8,cy+10,1)
	sprintxy(" tool",cx+72,cy+3,7,6,1)
	ospr(tools[current_tool].sp,cx+72,cy+2,1)
end

function draw_inventory()
	--[[
	draw_win(cx+8,cy+8,112,112,1,6)
	sprintxy(" inventory   ",cx+9,cy+9,7,1,13)
	print("Ž",cx+112,cy+10,6)
	]]--
	bigwin("inventory",8,8,112,112,1,6,13)
	_in=0
	for i,j in pairs(inventory) do
		_in+=1
		print(i..": "..j,cx+18,cy+12+(12*_in),7)
	end
	
	draw_toolwheel()
end

function draw_toolwheel()
	printo("current tool",cx+38,cy+100,7,0)
	printo("‹",cx+38,cy+112,7,0)
	printo("‘",cx+78,cy+112,7,0)
	printo(tools[current_tool].name,cx+52,cy+112,7,0)
end

function draw_fields()
	for fi in all(fields) do
		_sx=fi.x*8
		_sy=fi.y*8-4
		st=fi.stage
		
		if st==1 then
			ospr(seedling,_sx,_sy,3)
		end
		if st==2 then
			ospr(sprout,_sx,_sy,3)
		end
		if st==3 then
			ospr(plant,_sx,_sy,3)
		end
		
	end
end

function draw_newday()
	cls()
	camera(0,0)
	daytx="day "..day
	dsprintxy("        ",0,18,7,6,1)
	dsprintxy(daytx,64-(#daytx*8),18,7,6,1)
	printc("rent of "..rent.." due in "..days_to_rent.." days",96,7)
	printc("— to continue",112,7)
	draw_shop(0,36)
end

function draw_shop(_x,_y)
	sprintxy("                ",_x,_y,7,6,1)
	sprintxy("shop",_x+48,_y,7,6,1)
	item=shop[current_shop]
	spr(item[2],_x+60,_y+12)
	printc(item[1],_y+24,7)
	printc("‹ prev ‘ next Ž buy",_y+36,7)
	printc("you have $"..gold,_y+48,7)
end

function draw_gameover()
	cls()
	camera(0,0)
	dsprintxy("        ",0,18,7,6,2)
	dsprintxy("gameover",0,18,7,6,2)
	printc("you made it "..day.." days",52,7)
	printc("and made $"..profits,64,7)
	printc("— play again?",82,7)
end

function update_gameover()
	if btnp(—) then
		run()
	end
end
-->8
--update

function update_title()
	if btnp(Ž) then
		main_menu[menu_choice][2]()
	end
	if btnp(”) then
		menu_choice-=1
	end
	if btnp(ƒ) then
		menu_choice+=1
	end
	menu_choice=mid(1,menu_choice,#main_menu)
end

function update_main()
	
	handle_input()
	handle_time()
	if #fields>0 then
		update_fields()
	end
	
end

function handle_input()
	
	dx=0
	dy=0
	for i=0,3 do
		if btnp(i) then
			dx=h[i+1]
			dy=v[i+1]
		end
	end
	
	if not solid((plyr.mx+dx)*8,(plyr.my+dy)*8,0) then
		plyr.mx+=dx
		plyr.my+=dy
	else 
		if solid((plyr.mx+dx)*8,(plyr.my+dy)*8,tree_flag) then
			amt=1+flr(rnd(4))
			add_inventory("wood",amt)
			mset(plyr.mx+dx,plyr.my+dy,dirt)
			for m in all(mobs) do
				if (m.x==plyr.mx+dx) and (m.y==plyr.my+dy) then
					del(mobs,m)
				end
			end
			add_blip("+"..amt,64,64,wood,3)
			plyr.mx+=dx
			plyr.my+=dy
		end
	end
	
	plyr.mx=mid(0,plyr.mx,mw)
	plyr.my=mid(0,plyr.my,mh)
	
	if plyr.x!=plyr.mx*8 then
		plyr.x=lerp(plyr.x,plyr.mx*8,.5)
	end
	if plyr.y!=plyr.my*8 then
		plyr.y=lerp(plyr.y,plyr.my*8,.5)
	end
	
	if btnp(Ž) then
		_upd=update_inventory
		_drw=draw_inventory
	end
	
	if btnp(—) then
		handle_tools()
	end

end

function update_inventory()
	if btnp(Ž) then
		_upd=update_main
		_drw=draw_main
	end
	
	if btnp(‹) then
		sfx(0)
		current_tool-=1
		if current_tool<1 then current_tool=#tools end
	end
	if btnp(‘) then
		sfx(0)
		current_tool+=1
		if current_tool>#tools then current_tool=1 end
	end
end

function handle_tools()
	_t=tools[current_tool]
	if _t.use!= nil then
		_t.use()
	end
end

function update_fields()
	for f in all(fields) do
		if f.stage!=0 then
			f.time+=1
			if f.time>=growth_time and f.stage<3 then
				f.stage+=1
				f.time=0
			end
		end
	end
end

function handle_time()
	if t%30==1 then
		minutes+=10
		if minutes>=60 then
			hours+=1
			if hours>12 then
				if am_pm=="am" then
					am_pm="pm"
				else
					am_pm="am"
				end
				hours=1
			end
			minutes=0
		end
	end
	
	if am_pm=="pm" then
		fading=max(0,(hours-4)*5)
		fadeout()
	end
	
	tt=hours..":"..minutes..am_pm
	if tt=="11:0pm" then
		_upd=update_fade
		_drw=draw_fade
		next_upd=update_newday
		next_drw=draw_newday
		hours=6
		minutes=0
		am_pm="am"
		day+=1
		fading=0
		
		plyr.mx=sx
		plyr.my=sy
		
		days_to_rent-=1
		if days_to_rent==0 then
			gold-=rent
			if gold<0 then
				_upd=update_gameover
				_drw=draw_gameover
			else
				add_blip("-"..rent,64,64,money,2)
			end
			
			rent=200+(#fields*2)+day*2
			days_to_rent=7
		end
	end
end

function update_fade()
	if fading<0 then
		_upd=next_upd
		_drw=next_drw
		fading=0
	end
end

function update_newday()
	handle_shop()
	if btnp(—) then
		_upd=update_main
		_drw=draw_main
		
		check_tools()
	end
end

function handle_shop()
	if btnp(‹) then
		current_shop-=1
	end
	if btnp(‘) then
		current_shop+=1
	end
	
	current_shop=mid(1,current_shop,#shop)
	
	if btnp(Ž) then
		item=shop[current_shop]
		cost_amt=item[3]
		cost_typ=item[4]
		
		if cost_typ!="gold" then
			if inventory[cost_typ]!=nil and inventory[cost_typ]>cost_amt then
				inventory[cost_typ]-=cost_amt
				add_inventory(item[5],item[6])
			end
		else
			if gold>=cost_amt then
				gold-=cost_amt
				add_inventory(item[5],item[6])
			end
		end
	end
end

function check_tools()
	if inventory["fences"]!=nil then
		has_tool=false
		for i=1,#tools do
			_tool=tools[i]
			if _tool.name=="fence" then
				has_tool=true
			end
		end
		
		if not has_tool then
			add_tool("fence",fence,tool_fence)
		end
	end
	
	if inventory["paths"]!=nil then
		has_tool=false
		for i=1,#tools do
			_tool=tools[i]
			if _tool.name=="path" then
				has_tool=true
			end
		end
		
		if not has_tool then
			add_tool("path",path,tool_path)
		end
	end
end
-->8
-- support library
-------------------------------
-- scroll tile
-- see that water tile?
-- this scrolls it down by 1
function scroll_tile(_tile)
 local temp
 local sheetwidth=64 -- bytes
 local spritestart=0 -- starts at mem address 0x0000
 local spritewide=4 -- 8 pixels=four bytes
 local spritehigh=sheetwidth*8 -- how far to jump down
 local startcol=_tile%16
 local startrow=flr(_tile/16)
 
 if (_tile>255) return
 -- save bottom row of sprite
 temp=peek4(spritestart+(startrow*sheetwidth*8)+(7*sheetwidth)+startcol*spritewide) -- 7th row
 for i=6,0,-1 do
  poke4(spritestart+(startrow*sheetwidth*8)+((i+1)*sheetwidth)+startcol*spritewide,peek4(spritestart+(startrow*sheetwidth*8)+(i*sheetwidth)+startcol*spritewide)) 
 end
 --now put bottom row on top!
 poke4(spritestart+(startrow*sheetwidth*8)+startcol*spritewide,temp) 
end 

-------------------------------
-- print string s at x y with
-- color c and outline optional
function print6(_s,_x,_y,_c,_o)
end
-------------------------------
-- collision detection function;
-- returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
function checkcollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

-------------------------------
function printc(_str,_y,_c)
 where=center_x(_str)
 if (where<0) where=0
 print(_str,where,_y,_c)
end
-------------------------------
-- centered and outlined
function printco(_str,_y,_c,_co)
 where=center_x(_str)
 if (where<0) where=0
 printo(_str,where,_y,_c,_co)
end

-------------------------------
function printo(str, x, y, c0, c1)
for xx = -1, 1 do
 for yy = -1, 1 do
 print(str, x+xx, y+yy, c1)
 end
end
print(str,x,y,c0)
end
-------------------------------
-- string width with glyphs
function strwidth(str)
 local px=0
 for i=1,#str do
  px+=(ord(str,i)<128 and 4 or 8)
 end
 --remove px after last char
 return px-1
end
-------------------------------
-- get centered on screen width
function center_x(str)
 return 64 - strwidth(str)/2
end

-------------------------------
-- sprite print
-- _c = letter color
-- _c2 = line color
-- _c3 = background color of font
-- collapse all these sprite
-- printing routines into one
-- function if you want!
function sprint(_str,_x,_y,_c,_c2,_c3)
 local i, num
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
  
 for i=1,#_str do
  num=asc(sub(_str,i,i))+160
  spr(num,(_x+i-1)*8,_y*8)
 end
 pal()
end
-------------------------------
-- sprite print centered on x
function sprintc(_str,_y,_c,_c2,_c3)
 local i, num
 _x=63-(flr(#_str*8)/2)
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
  
 for i=1,#_str do
  num=asc(sub(_str,i,i))+160
  spr(num,_x+(i-1)*8,_y*8)
 end
 pal()
end
-------------------------------
-- sprite print at x,y pixel coords
function sprintxy(_str,_x,_y,_c,_c2,_c3)
 local i, num
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
  
 for i=1,#_str do
  num=asc(sub(_str,i,i))+160
  spr(num,_x+(i-1)*8,_y)
 end
 pal()
end
-------------------------------
-- double-sized sprite print at x,y pixel coords
function dsprintxy(_str,_x,_y,_c,_c2,_c3)
 local i, num,sx,sy
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
 -- (btw you can use this technique
 -- just to draw sprites bigger)
 for i=1,#_str do
  num=asc(sub(_str,i,i))+160
  sy=flr(num/16)*8
  sx=(num%16)*8
  sspr(sx,sy,8,8,_x+(i-1)*16,_y,16,16)
 end
 pal()
end
-------------------------------
function draw_rwin(_x,_y,_w,_h,_c1,_c2)
 -- would check screen bounds but may want to scroll window on?
 if (_w<12 or _h<12) return(false) -- min size
 -- okay draw inside
 rectfill(_x+3,_y+1,_x+_w-3,_y+_h-1,_c1) -- x big middle bit
 line(_x+2,_y+3,_x+2,_y+_h-3,_c1) -- x left edge taller
 line(_x+1,_y+5,_x+1,_y+_h-5,_c1) -- x left edge shorter
 line(_x+_w-2,_y+3,_x+_w-2,_y+_h-3,_c1) -- x right edge taller
 line(_x+_w-1,_y+5,_x+_w-1,_y+_h-5,_c1) -- x right edge shorter
 --now the border left side
 line(_x,_y+5,_x,_y+_h-5,_c2) -- x longest leftmost edge
 line(_x+1,_y+3,_x+1,_y+4,_c2) -- x 2 left top
 line(_x+1,_y+_h-4,_x+1,_y+_h-3,_c2) -- x 2 left btm
 pset(_x+2,_y+2,_c2)  -- x 1 top dot
 pset(_x+2,_y+_h-2,_c2)  -- x 1 btm dot
 line(_x+3,_y+1,_x+4,_y+1,_c2)  -- x 2 top curve
 line(_x+3,_y+_h-1,_x+4,_y+_h-1,_c2)  -- x 2 btm curve
 --now the border right side
 line(_x+_w,_y+5,_x+_w,_y+_h-5,_c2) -- x longest leftmost edge
 line(_x+_w-1,_y+3,_x+_w-1,_y+4,_c2) -- x 2 left top
 line(_x+_w-1,_y+_h-4,_x+_w-1,_y+_h-3,_c2) -- x 2 left btm
 pset(_x+_w-2,_y+2,_c2)  -- x 1 top dot
 pset(_x+_w-2,_y+_h-2,_c2)  -- x 1 btm dot
 line(_x+_w-3,_y+1,_x+_w-4,_y+1,_c2)  -- x 2 top curve
 line(_x+_w-3,_y+_h-1,_x+_w-4,_y+_h-1,_c2)  -- x 2 btm curve
 -- top and bottom!
 line(_x+5,_y,_x+_w-5,_y,_c2) -- x top
 line(_x+5,_y+_h,_x+_w-5,_y+_h,_c2) -- x bottom
end
-------------------------------
-- draw simple rectangular window
-- with a frame
function draw_win(_x,_y,_w,_h,_c1,_c2)
 rectfill(_x,_y,_x+_w,_y+_h,_c1)
 rect(_x,_y,_x+_w,_y+_h,_c2)
end
------------------------------
--map collide by enargy
function solid(x,y,flag)
 local tx = flr(x/8)
 local ty = flr(y/8)
 tileid = mget(tx,ty)
 return fget(tileid,flag)
end
------------------------------
--outlined sprite
function ospr(sp,x,y,c)
	for k=1,15 do
		pal(k,c)
	end
	for i=x-1,x+1 do
		for j=y-1,y+1 do
			spr(sp,i,j)
		end
	end
	pal()
	spr(sp,x,y)
end	
------------------------------
--animate
function anim(tb)
	return tb[flr(t/fr)%#tb+1]
end
----------------------------
-- sets up ascii tables
-- by yellow afterlife
-- https://www.lexaloffle.com/bbs/?tid=2420
-- btw after ` not sure if 
-- accurate
function setup_asciitables()
 chars=" !\"#$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_`|€€‚ƒ„…†‡ˆ‰Š‹ŽŒŽ‘’“”•–—˜™~"
 -- '
 s2c={}
 c2s={}
 for i=1,#chars do
  c=i+31
  s=sub(chars,i,i)
  c2s[c]=s
  s2c[s]=c
 end
end
---------------------------
function asc(_chr)
 return s2c[_chr]
end
---------------------------
function chr(_ascii)
 return c2s[_ascii]
end
---------------------------
--fade
-- function to fade screen
-- one cycle at a time
function fadeout()
local c,p=0,0
  fading+=1
  if fading%fadespeed==1 then
    fadestep()
    if fading==7*fadespeed+1 then
      cls()
      pal()
      fading=-1
    end
  end
end
-----------------------
--fade func
function fadestep()
	for i=0,15 do
	  c=peek(24336+i)
	  if (c>=128) c-=112
	  p=fade[c]
	  if (p>=16) p+=112
	  pal(i,p,1)
	end
end
-->8
--extras
function add_obj(kind,x,y)
	if kind!=field and kind!=nil then
		o={}
		o.kind=kind
		o.x=x
		o.y=y
		add(mapobj,o)
	else
	
	end
end

function add_mob(kind,x,y,outline)
	if kind!=nil and x!=plyr.mx*8 and y!=plyr.my*8 then
		o={}
		o.kind=kind
		o.x=x
		o.y=y
		o.outline=outline
		add(mobs,o)
	end
end

function rnd_array(tb)
	return tb[flr(rnd(#tb+1))]
end

function lerp(a,b,f)
	return a+f*(b-a)
end

function add_blip(txt,x,y,sp,c)
	bl={}
	bl.txt=txt
	bl.sp=sp
	bl.x=x
	bl.y=y
	bl.c=c
	bl.life=30
	
	add(blips,bl)
end

function add_inventory(item,amount)
	sfx(1)
	if inventory[item]==nil then
		inventory[item]=amount
	else
		inventory[item]+=amount
	end
end

function bigwin(_title,_x,_y,_w,_h,_c1,_c2,_c3) 
	draw_win(cx+_x,cy+_y,_w,_h,_c1,_c2)
	draw_win(cx+_x+1,cy+_y+1,_w-2,7,_c3,_c1)
	sprintxy(" ".._title,cx+_x+2,cy+_y+1,7,_c1,_c3)
	print("Ž",cx+_w,cy+_y+2,_c2)
end

function add_tool(name,sp,use) 
	add(tools,{name=name,sp=sp,use=use})
end

function player_anim()
	--figure out player state
	plyr.anim=idledir[plyr.dir]
	for i=0,3 do
		if btn(i) then
			plyr.dir=i+1
			--plyr.anim=walkdir[i+1]
		end
	end
	plyr.spr=anim(plyr.anim)
end

-->8
---tool functions
function tool_plow()
	sfx(3)
	if mget(plyr.mx,plyr.my)==field then
		for f in all(fields) do
			if f.x==plyr.mx and f.y==plyr.my then
				if f.stage==3 then
					add_inventory("plant",3)
				else if f.stage>0 then
					add_inventory("seeds",1)
				end
				end
				
				del(fields,f)
				mset(plyr.mx,plyr.my,dirt)
			end	
		end		
	else
		mset(plyr.mx,plyr.my,field)
		
		for _o in all(mapobj) do
			if _o.x==plyr.mx and _o.y==plyr.my then
				del(mapobj,_o)
			end
		end
		
		nf={}
		nf.x=plyr.mx
		nf.y=plyr.my
		nf.stage=0
		nf.time=0
		
		add(fields,nf)
	end
end

function tool_seeds()
	if inventory.seeds!=nil and inventory.seeds>0 then
		on_field=false
		
		for f in all(fields) do
			if f.x==plyr.mx and f.y==plyr.my then
				on_field=true
				if f.stage==0 then
					f.stage=1
					inventory["seeds"]-=1
				else
					add_blip("no room!",64,64,0,2)
				end
			end
		end
		
		if on_field==false then
			add_blip("plow first!",64,64,28,2)
		end
	else
		add_blip("no seeds left!",64,64,0,2)
	end
end

function tool_harvest()
	on_field=false
	
	for f in all(fields) do
		if f.x==plyr.mx and f.y==plyr.my then
			on_field=true
			if f.stage==3 then
				add_inventory("plant",3)
				f.stage=0
				f.time=0
				add_blip("+3",64,64,plant,3)
			else
				add_blip("not ready!",64,64,0,2)
			end
		end
	end
	
	if on_field==false then
		add_blip("stand on a field!",50,64,0,2)
	end
end

function tool_path()
	if inventory["paths"]>0 then
		mset(plyr.mx,plyr.my,path)
		sfx(2)
	else
		add_blip("no paths left!",50,64,2)
	end
end

function tool_fence()
	if inventory["fences"]>0 then
		mset(plyr.mx,plyr.my,solid_dirt)
		add_mob(fence,plyr.mx,plyr.my,2)
		sfx(2)
	else
		add_blip("no fences left!",50,64,2)
	end
end

function tool_destroy()
	_d = plyr.dir
	_x=h[_d+1]
	_y=v[_d+1]
	for m in all(mobs) do
		if m.x==(plyr.mx+_x)*8 and m.y==(plyr.my+_y)*8 then
			del(mobs,m)
		end
	end
	mset(plyr.mx+_x,plyr.my+_y,dirt)
end
__gfx__
00000000424442444244424442444244424442446066606612222221feeeeee87bbbbbb30000004000000030000300000b0dd0304f9f4fff4f9f4fff7999a999
0000000022222222222222222222222222222222007777002d2222d2e8888882b3333331040000000300000003000030d3000b0dfffff9f4fffff9f49999979a
00000000444244424442544242333324428888246676d75022444422e8811882b33773310000040000000300000003b0000b0300ff4fffffff4fffff99a99999
00000000222222222222222222333322228888220077770024222242e8866882b3366531000400000003000000b00bb0b00300009fff9ff99fff9ff999997997
0000000024442444244425444233332442888824067d675624442442e8877282b3355131400000003000000030b30b003000dd0b4fffff9f4fffff9fa9999979
00000000222222222222222222331322228818220077770024222a92e8822182b33113310000000400000003003b00030b000003ff4fffffff4fffff999a9999
00000000442444244424442442331324428818246605550624424442e8888882b33333310400000003000000030b00000300b000ff9ff9ffff9ff9ff99999799
0000000022222222222222222233332222888822000000002422224282222222311111110000400000003000000030000dd030b0f9ffff4ff9ffff4f979999a9
333b333bb333b33b0000000005500550005070500500700000dddd00656565650d0aa000000aa000760000000766660006566650777777500007a90000000070
33b333b3bb333b33000000000765676005076005000760050dddddd0666666650df99f000df99f0006500000766550000666666576666650000a0000000006d6
3b333b333bb333b300000000076007605076660050766700dddddddd662226650de11e000de11e0700650000664500000659405676565650000aa90000006d60
b333b33333bb333b076007600765676050766605007676000555555066666665d55660070d66660200065006650450000009400076666650000a00000006d000
333b333bb33bb33307656760076007600766767007667670066666606655566509066602d5d6609200006560650045000009400076565650000a0000076d0000
33b333b33b33bb330760076000000000576676655761166506dd6c6066111665000cc092090cc00200000650600004500009400076565650007aa9007dd6d000
3b333b3333b33bb31765676100000000766767667610016606dd6c606611166500c11c0200c11c000000604500000045000940000766650000a00a006d06d000
b333b333b33b33bb1d211d2100000000565655656610016606dd6660cc444ccc044004400440044000060004000000040009400000555000009aa900076d0000
0bb3b3b030bbb0030150051001500510940000499999999994000049000099997667060000065000d777777dd55550000076dc0000999900000000000007d000
bb3b3b350bbb3300157556511575515194544449444444444444444400094444641605000065d650566666657665d650075555d0094444900000000000766d00
b3b33333bb3bbb305757651557576515945555490550055004555550009440006666666065616560566666657661656001c6dc109444444900000000076666d0
b3333335b3b3b33505766650057656509400004904500450045004500944000011111156006176d011111155766176d007cc6d50999aa9990000000000044000
0b4334503bbb3b3505666650056565509400004904500450045004509945400076d176d57661110076d176d57661110007cc6d50955aa5590007d00000094000
0009450033b3b355575665155516551594544449045004500454445094405400656165606161d650656165607661d65007cc6d509544444900766d0000094000
0009450003335550156551511155515194555549444444444455554494000544d650d65064616560d650d6507661656007cc6d5095444449076666d000094000
095454540033350301500510015005109400004999999999940000499400004900000000766176d000000000d55176d00066d500999999990004400000094000
000990000777770000077000007dd50000766500055445500000700006766650000700009999999975070560eee8eee84f9f4fff4f9f4fff4f9f4fff4f9f4fff
049aa94075666660007667000007500007666650554444550000770000565100007a90009004040556565650e882e882fffff9f4fffff9f4fffff9f4fffff9f4
49a99a940065d56000077000077665507666666545444454000076700067650007aaa9009444444505777500e882e882ff4fffffff4fffffff4fffffff4fffff
9a9aa9a900666660076666707766665576565565455a9554000077770067650007aaa9009000400576776660822282229fff9ff99fff9ff99fff9ff99fff9ff9
9a9aa9a900655d60765555677666666576666665411a911407007000006765000a9999009444444505766500e8eee8ee4fffff9f4fffff9f4fffff9f4fffff9f
49a99a940066666065000056766666657655656544455444766666670067650075565590955555555656565082e882e8ff4fffffff4fffffff4fffffff4fffff
049aa940006777775650056577666655766666654444444407666670006765000aaaa900000550007506056082e882e8ff9ff9ffff9ff9ffff9ff9ffff9ff9ff
004994000055555005677650077665506555555554444445007777000676665000000000050640050000000022822282f9ffff4ff9ffff4ff9ffff4ff9ffff4f
00000000000005d9007a4200000000000000000900009999900a000000000000000000000049400000040000a7a9999900076000000000000001000000000000
0e82e82000555d5507a9942000000000000909aa009999aa09000a900009000009009090049a94000049400004a994400007610000111000001c10000eeeee20
e788888205d6d5550a999940000000000000aaaa09a9aaaa00009000008aa800008aa80049a7a940049a9400097999400007610001ccc10001c7c1007262626c
e88888825d7ddd500a99994000000009090a9a9a099a9909a000000000a77a9009a77a009a777a9449a7a94009a99990707765071c777c1001c7c10015252520
0888882056dddd500a9999400000a09a00a9a9a999a997900090000009a77a0000a77a9049a7a940049a9400099a99407667665601ccc10001c7c10002e50000
0088820055ddd5500ae999400000099a09aa9a7799a970000a000000008aa800008aa800049a940000494000009994007676656500111000001c10005e200000
000820000555550007fe9420000099a70aa9a7779aa090000900000000009000090900900049400000040000000a900007655651000000000001000025200000
0000000000555000007942000009aa779aaa97779aa90000000000000000000000000000000400000000000007a9994000766510000000000000000000000000
000550000005500005677650000550000567765000ddd0000000000000033000060aa05065656565757575751111111111111111111111112888888212888821
00566500005666000567765000566500567777650d666d0003333330033bb33006aa00505dddddd66060606015555555555555555555555188eeee88288ee882
0567765066677760567777650567765067766776d67666d033bbbb3333b77b3306a00a506d5555d5575757571565505050505050505556518ea77ae888eaae88
5677776577777776567777655675576577655677d66666d03b7777b33b7777b30600aa505d5cc6d6060606061555550505050505050555518e7777e88ea77ae8
6777777677777777677557765675576556500565dd666d503b7777b33b7777b3060aa0506d5cc6d5757575751555505050505050505555518e7777e88ea77ae8
77777777666775577777777705677650050000500dddd50033bbbb3333b77b3306aa00505d5666d6606060601555550505050505050555518ea77ae888eaae88
56666665005677505666666500566500000000000055500003333330033bb33006a00a506dddddd55757575715655050505050505055565188eeee88288ee882
05555550000566000555555000055000000000000000000000000000000330000600aa5055555555060606061555555555555555555555512888888212888821
00aaaa000007000000dddd0000dddd000022220050222205bb0bb0bb0b0bb0b00000bbb000000000000990003bb1000000666000000770000076660000766600
0a999940000e00000d7cc7d00d7cc7d0552882550528825003abba30b3abba3b000b1b1ba000bbb000007900b3b3b10006000600007755000712826007282160
a979979400e88000d70cc07dd77cc77d22588522225885220bbbbbb00bbbbbb00a0bbbbbb00b1b1b009a9990bb3bbb1060700060077665500612825006282150
a71991740e111800d77cc77dd70cc07d271881722708807203baab3003baab30b00b3707b00bbbbb0979a99913b3b3b160000060775555550066550000665500
a9999994e8191880dccccccddccccccd2888888228888882b003300b00033000b00bbb00b00b370799a999790bbb3bb160000060775e275507d75d6007d75d60
a992299408111820dcc11ccddcc11ccd28881882288188820b3bb3b00b3bb3b0bb0bbbb0bb0bb3309997aa9901b3b3b106000600775227557d7dd5d67d7dd5d6
b30880d5008882000dccccd00dceecd0028888299288882000bbbb00b0bbbb0b0bb0bbbbbbb0bbbb0999a990001bbb3000666000777776557d7dd5d57d7dd5d5
ff0ee0660008200000dddd0000dddd0099222290092222990bb33bb000b33b0000bbbbb00bbbbbb0009a99000001110b00000000055555500665565006655650
08000080a00700b00056650000077000004aa4000077770000777700000000076776d7765000000000d7cd0009aaaa900000567700a7777d0007700000077000
0000000007a00bba056766500076650044a77a4407666670000666700000007676675665650000000d77ccd09a1aa1a9000567760a6666dd0076670000700700
00880800077bba7b5676666500766500aa7777aa71166117a0776657000007667667566566500000d777cccd9a5aa5a905677775a7777d5d0766667007000070
8008e808b0b7aab067666666007665004aa77aa4712662177a6666660000766676675665666500007777cccc9aaaaaa95677775076666d5d7666666770000007
008ee80000ba7ab0666666660076650004a77a40066116606d666666000766667667566566665000dcccdddd09affa900567777676666d5d0005500000077000
000888000b7b77ab56666665007665004a7aa7a405666650d05661150076666676675665666665000dccddd09a9aa9a95677766576666d5d0006600000700700
000000800ab0b7aa05666650076666504aa44aa4006116000006665007666666766756656666665000dcdd00a900009a6777655076666dd00006600007000070
08008000ab0000a00056650006555550aa0000aa0056650000665000766666666552155666666665000dd0009a9009a9776650006ddddd000006600070000007
b3b00b3b0bbbbbb00000000000000900aaaaaaaaaaaaaaaa994499444444444499999999555555555555555533333333666d6666dd5555ddcccccccc00088000
b039930bbbb33bbb0000000000009a90aaa999aaaaaa99aa944494444444444499444499555d55ddd55dd55d3b3333b36dd666d6d566665dcccccccc00800800
00999200b33bb33b0000000000000900aaaaaa9aaaaaaa9a444444444444444444444444dddddddddddddddd3333333366dd6d6656666665cccccccc08099080
00944200b393323b0000000000e00b00aa9aaa9a99aaaaaa1414141499449944991111995d55d555dd555d55333333336d66666656666665cccccccc80900908
0099920000999200000000000eae0300a9aaa9aaaa9aaaaa414141419444944494111149dddddddddddddddd3333333366666dd656666665cccccccc80900908
09999920044499200000000000e00300a9aaaaaaaaaaa9aa11111111444444449911119955dd5d55d555d55d333333336666d6665d6666d5cccccccc08099080
044499200999992000000b0000b00300aa99aaaaaa999aaa000000004444444444111144dddddddddddddddd3b3333b36dd666ddd5dddd5d1cc11cc100800800
029992200299922000b0030000300300aaaaaaaaaaaaaaaa000000004444444499111199555555555555555533333333d666666ddd5555dd1111111100088000
00000000002222200777000000044000000aa000007000000777700000bbbbbbbbbbbbbbbbbbbb002222222222222222000000000000000000000bbb00990000
2222222202944442067770000049940000a7aa0000700000070070000b333b333b333b3333b333b042244224422442240000000000000000000b3b3b00049000
44444444029999420677770000444200007aa90000700000070070000b34333433343334433343b04444444444444444000000000000000000bbb3bb09094090
44444444022222220677777000494200007aa9007770000077077000b3444444444444444444443b44444444444444220b00000000000000003b3b3094994949
222222220294949206777700004992000a7aaa907770000077077000b3344444444444444444433b4444444444444422b0b0bb00000000000bb3bbb099494490
222222220294949206777000004942000aaa99900000000000000000bb34444444444444444443bb444444444222444400b0b0b0000000000b3b3b0009949900
2442442402949492066600000049920000666d000000000000000000b3344224422442244224433b4224422442224224000b0000077707703bbb000000949000
22422424002222200000000000042200000000000000000000000000b3222222222222222222223b2222222222222222000b0000777777773300000000040000
00aaa900000ee0000000000000800000008000000000000000000000008008000000000000808000000000000fffff000fffff000fffff00002ee20000000000
00666d000eeaaee0000ee0000877000008770000008000000007000000088000000000000008800000000800f44444f0f44444f0f44444f002222220002ee200
067176d00eeaaee00eeaaee0a7170007a7170f0708770007000770700088e800080880800088e80008088000f4fff4f0f4fff4f0f4fff4f0047ff74002222220
6771766db0beeb0b0eeaaee0087777770877ff77a71777770004007708888e800088e80008888e800088e800f4f4f4f0f4f4f4f0f4f4f4f0471ff17404ffff40
6771116db3bbbb3b0bbeebb0077fff77077fff77087fff77009994400818818008888e800818888008888e80f4f444f0f4f444f0f4f444f00ffffff0471ff174
6777766d3bb1b1bb33bb1b1b077ff7700777f770077ff7700949994002888e8001888e100288888001888e80f4ff22f0f4ff1e10f4fff1e1002222000ffffff0
067766d03bbbbbbb33bbbbbb0077770000a7770000777a00099494400288888002888880022288800222888044422220444feee0444feeee00eeee0000eeee00
00666d000333333003333330000a0a0000000a00000a000009944400002228000022280000222200002222000422220004eeeee004eeeeee0040040000400400
0002ee2002ee20000022ee000022ee0000ee220000ee22000222200000022220002ee200000000000022ee000000000000ee2200000000000022220000000000
002222222222220002222220022222200222222002222220222222000022222202222220002ee200022222200022ee000222222000ee22000222222000222200
0447ff7447ff7440044447f0044447f00f7444400f7444404444444004444444047ff74002222220044447f0022222200f744440022222200444444002222220
0471ff1771ff1740044f71f0044f71f00f17f4400f17f440f4444f4004f4444f471ff174047ff740044f71f0044447f00f17f4400f7444404f4444f404444440
00ffffffffffff0000fffff000fffff00fffff000fffff00ffffff0000ffffff0ffffff0471ff17400fffff0044f71f00fffff000f17f4400ffffff04f4444f4
0022220000222200002222000022220000222200002222000022220000222200002222000ffffff00022220000fffff0002222000fffff00002222000ffffff0
00eee400004eee0000eee400004eee00004eee0000eee40004eeee0000eeee4000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee00
00400000000004000040000000000400000004000040000000000400004000000040040000400400004004000040040000400400004004000040040000400400
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555775555775775557757755555775555775577557777555555775555557755555577555775557755557755555555555555555555555555555555775
55555555555770555770770577777775557777755770770057777055555770555577005555557755577577005557705555555555555555555555555555557700
55555555555770555500500557707700577770005507700555770775555500555577055555557705777777755777777555555555577777755555555555577005
55555555555500555555555577777775550777755577077557707700555555555577055555557705577077005557700055775555550000005555555555770055
55555555555775555555555557707700577777005770077057707705555555555557755555577005770057755557705555770555555555555577555557700555
55555555555500555555555555005005550770055500550055775775555555555555005555550055500555005555005557700555555555555577055555005555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755555775555777775557777755555777755777777555777755577777755577775555777755555775555557755555557755555555555577555557777755
57700775557770555500077555000775557707705770000057700005550007705770077557700775555770555557705555577005557777555557755555000775
57705770555770555577770055577700577007705777775557777755555577005577770055777770555500555555005555770055555000055555775555577700
57705770555770555770000555550775577777705500077557700775555770055770077555500770555775555557755555577555557777555557700555550005
55777700557777555777777557777700550007705777770055777700555770555577770055777700555770555557705555557755555000055577005555577555
55500005555000055500000055000005555555005500000555500005555500555550000555500005555500555577005555555005555555555550055555550055
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777755577777555577777555777775557777555775577555777755555577755775577557755555575555755775577555777755
57700775577007755770077557700775577007755770000057700000577000055770577055577005555557705770770057705555577557705777577057700775
57707770577777705777770057705500577057705777775557777755577077755777777055577055555557705777700557705555577777705777777057705770
57705000577007705770077557705775577057705770000557700005577057705770077055577055577557705770775557705555577777705770777057705770
55777775577057705777770055777700577777005577777557705555557777005770577055777755557777005770577555777775577007705770577055777700
55500000550055005500000555500005550000055550000055005555555000055500550055500005555000055500550055500000550055005500550055500005
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777775577777755775577557755775577557755775577557755775577777755777775557755555577777555557755555555555
57700775577007755770077557700000555770005770577057705770577777705577770055777700550077005770000555775555550077055577775555555555
57777700577057705777770055777755555770555770577057705770577777705557700555577005555770055770555555577555555577055770077555555555
57700005577077005770077555500775555770555770077055777700577007705577775555577055557700555770555555557755555577055500550055555555
57705555557707755770577057777700555770555577770055577005570055705770077555577055577777755777775555555775577777055555555557777775
55005555555005005500550055000005555500555550000555550055550555505500550055550055550000005500000555555500550000055555555555000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
__gff__
0101010101000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010810010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0
__map__
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e3b3b3b3b0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e3b3b3b3b0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e01010101350e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e010103010e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000008b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b
__sfx__
000100002e1502e1502f1502f1502f150351503715000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200002e5502e5503555035550166003a5503a55037500345003350034500385000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0001000036630236701f6711c6511b6511b6511a6511a6511a630176310e631066310463102631016310063100631006110061100611006110061100611006110061101600006000060000300003000030000300
00010000312502b250252502025019250122500e2500e6300e6300e6351520010200072000420000200002000d20009200082000820000200002000120026100121001e100061000d10019100251000c10024100
000200002f3402f3412f33136334363413634136331363313632136321363213631136315383003f3000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400001c5151e5151a515150151c5151e5151a015155151c5151e5151a515150151c5151e5151a015155151c5151e51517015230151c5151e51517015230151c5151e515165151c0151c5151e515160151c515
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020515215151c5151901520515215151c0151951520515215151c5151901520515215151c0151951520515215151c0151901520515215151c01525515285152651525515210151c5151a5151901515515
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
00 05 06 43 44
00 05 06 43 44
01 05 06 43 44
00 05 06 43 44
00 07 08 43 44
02 07 08 43 44
00 09 42 43 44
01 09 0a 43 44
00 09 0a 43 44
00 09 0b 43 44
00 09 0b 43 44
02 0c 0d 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
