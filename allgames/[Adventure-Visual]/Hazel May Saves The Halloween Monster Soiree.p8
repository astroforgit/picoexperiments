pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--hazel may saves the halloween monster soiree
--james id & wayne kubiak
-- version 1.2

debug=false
walkthrough=false
itemlist={
	[1]="brain",
	[2]="key",
	[3]="pumpkin",
	[4]="skull",
	[5]="potion",
	[6]="tombstone",
	[7]="broom",
	[8]="candy",
	[9]="apple",
	[10]="pizza",
	[11]="cat"}

function _init()
	monsterparty=
		{
			devil={present=false},
			franky={present=false},
			ghost={present=false},
			killer={present=false},
			mummy={present=false},
			scientist={present=true,agent=createscientist(0,0)},
			shedevil={present=false},
			tentacle={present=false},
			vampire={present=false},
			wolfman={present=false},
			zombie={present=false}
		}
	rooms={
		{
			{},
			{createwolfman(32,18),createitem(73,30,75,itemlist[7])},
			{createtail(52,36),createdevil(60,28),createitem(80,64,91,itemlist[11])},
			{createscientist(52,4),createitem(74,12,70,itemlist[2])},
			{createghost(28,28),createitem(84,28,70,itemlist[2])},
			{createkiller(56,64),createitem(62,76,77,itemlist[9])},
			{createzombie(83,36),createitem(83,62,74,itemlist[6])},
			{createtail(72,56),createshedevil(80,48),createitem(80,64,71,itemlist[3])},
		},
		{
			{createvampire(28,24),createdecor(89,56,80,1,2),createdecor(89,96,24,1,2),createdecor(89,96,40,1,2),createitem(32,80,70,"key")},
			{createitem(48,64,76,itemlist[8]),createfrank(88,56),createitem(88,80,70,itemlist[2]),createitem(84,28,73,itemlist[5])},
			{createtentacle(64,48),createdoor(96,48),createitem(60,64,78,itemlist[10])},
			{createdecor(183,36,32,1,2),createdecor(183,84,32,1,2),createdecor(116,32,88,1,1),createdecor(116,88,88,1,1)},
			{createdoor(72,16),createmummy(44,24),createdoor(80,80)},
			{createitem(68,56,72,itemlist[4])},
			{createdoor(24,8),createitem(60,16,70,itemlist[2]),createdoor(96,8)},
			{createitem(24,80,69,itemlist[1])},
		}
	}
	art={obj={}}
	creategamestates()
	createplayer()
	currentroom=createroom(3,1,{})
end

function _update()
	gamestate:update()
end

function _draw()
	gamestate:draw()
end

dither={[1]=-16706,[2]=-6731,[3]=-23131,[4]=-20561,[5]=3855,[6]=21845,[7]=3598,[8]=-4113,[9]=31710,[10]=-4681,[11]=13260,[12]=0}

function createplayer()
	player={
		pos=vector(64,64),
		dir='d',
		grab=false,
		overobj=false,
		inventory={},
 		anim={
 			u={
 				head={6,6},
 				body={22,23,22,24}
 			},
 			d={
 				head={4,5},
 				body={19,20,19,21}
 			},
 			l={
 				head={7,8},
 				body={25,26,25,27}
 			},
 			r={
 				head={7,8},
 				body={25,26,25,27}
 			}
 		},
 		t=0,
 		wallptcollision=function(x,y)
 			return fget(mget(currentroom.x*16+flr(x/8),currentroom.y*16+flr(y/8)),0)
 		end,
 		tilecollision=function(_s,_tile)
 			local currentx=currentroom.x*16
 			local currenty=currentroom.y*16
 			local x1=currentx+flr(_s.pos.x/8)
 			local x2=currentx+flr((_s.pos.x+7)/8)
 			local y1=currenty+flr(_s.pos.y/8)
 			local y2=currenty+flr((_s.pos.y+7)/8)
 			local c1=mget(x1,y1)
 			local c2=mget(x2,y1)
 			local c3=mget(x1,y2)
 			local c4=mget(x2,y2)
 			return c1==_tile or c2==_tile or c3==_tile or c4==_tile
 		end,
		update=function(_s)
			_s.t=(_s.t+0.1)%2
			local mpos=vector(0,0)
			if(btn(”)) mpos.y-=1
			if(btn(ƒ)) mpos.y+=1
			if(btn(‹)) mpos.x-=1
			if(btn(‘)) mpos.x+=1

			if(debug) mpos.x*=2 mpos.y*=2
			_s.grab=btnp(Ž)
			if(mpos.x!=0 or mpos.y!=0)then
				_s.pos.x+=mpos.x
				_s.pos.y+=mpos.y
				
				if(_s.state.state=="idle")then
					local flp=_s.state.flp
					_s.state=_s.walkstate()
					_s.state.flp=flp
				end
			else 
				if(_s.state.state=="walk")then
					_s.state=_s.idlestate()
				end
			end

 		 	if(mpos.x>0) _s.dir='r'
 		 	if(mpos.x<0) _s.dir='l'
 		 	if(mpos.y>0) _s.dir='d'
 		 	if(mpos.y<0) _s.dir='u'

 		 	
	 		if(not walkthrough)then

				if(_s.wallptcollision(_s.pos.x,_s.pos.y+1) or _s.wallptcollision(_s.pos.x,_s.pos.y+6)) then
					_s.pos.x=(flr(_s.pos.x/8)+1)*8
				end
				if(_s.wallptcollision(_s.pos.x+7,_s.pos.y+1) or _s.wallptcollision(_s.pos.x+7,_s.pos.y+6)) then
					_s.pos.x=flr(_s.pos.x/8)*8
				end
				if(_s.wallptcollision(_s.pos.x+1,_s.pos.y) or _s.wallptcollision(_s.pos.x+6,_s.pos.y)) then
					_s.pos.y=(flr(_s.pos.y/8)+1)*8
				end
				if(_s.wallptcollision(_s.pos.x+1,_s.pos.y+7) or _s.wallptcollision(_s.pos.x+6,_s.pos.y+7)) then
					_s.pos.y=flr(_s.pos.y/8)*8
				end

	 			local xoff=0
		 		local yoff=0
		 		local xtile=flr(_s.pos.x/8)
		 		local ytile=flr(_s.pos.y/8)
		 		if(_s:tilecollision(254)) currentroom.x-=1 xoff=-1 xtile=15--_s.pos.x+=128 currentroom.x-=1
	 		 	if(_s:tilecollision(255)) currentroom.x+=1 xoff=1 xtile=0--_s.pos.x-=128 currentroom.x+=1
	 		 	if(_s:tilecollision(252)) currentroom.y-=1 yoff=-1 ytile=15--_s.pos.y+=128 currentroom.y-=1
	 		 	if(_s:tilecollision(253)) currentroom.y+=1 yoff=1 ytile=0--_s.pos.y-=128 currentroom.y+=1

	 		 	local keyi=0
	 		 	for i=1,#_s.inventory do
	 		 		if(_s.inventory[i].name=="key")then
	 		 			keyi=i
	 		 			break
	 		 		end
	 		 	end
		 		for i=1,#currentroom.props do
		 			if(currentroom.props[i].name=="door") then
		 				if(not currentroom.props[i].open) then
		 					if(ptcollision({x=_s.pos.x,y=_s.pos.y+1},currentroom.props[i].pos) or ptcollision({x=_s.pos.x,y=_s.pos.y+6},currentroom.props[i].pos)) then
								if(keyi>0) then
									currentroom.props[i].open=true
									del(_s.inventory,_s.inventory[keyi])
								else
									_s.pos.x=(flr(_s.pos.x/8)+1)*8
								end
							end
							if(ptcollision({x=_s.pos.x+7,y=_s.pos.y+1},currentroom.props[i].pos) or ptcollision({x=_s.pos.x+7,y=_s.pos.y+6},currentroom.props[i].pos)) then
								if(keyi>0) then
									currentroom.props[i].open=true
									del(_s.inventory,_s.inventory[keyi])
								else
									_s.pos.x=(flr(_s.pos.x/8))*8
								end
							end
							if(ptcollision({x=_s.pos.x+1,y=_s.pos.y},currentroom.props[i].pos) or ptcollision({x=_s.pos.x+6,y=_s.pos.y},currentroom.props[i].pos)) then
								if(keyi>0) then
									currentroom.props[i].open=true
									del(_s.inventory,_s.inventory[keyi])
								else
									_s.pos.y=(flr(_s.pos.y/8)+1)*8
								end
							end
							if(ptcollision({x=_s.pos.x+1,y=_s.pos.y+7},currentroom.props[i].pos) or ptcollision({x=_s.pos.x+6,y=_s.pos.y+7},currentroom.props[i].pos)) then
								if(keyi>0) then
									currentroom.props[i].open=true
									del(_s.inventory,_s.inventory[keyi])
								else
									_s.pos.y=(flr(_s.pos.y/8))*8
								end
							end
		 				end
		 			end
		 		end

		 		if(xoff!=0 or yoff!=0) then
		 			currentroom.props=rooms[currentroom.y+1][currentroom.x+1]
		 		 	while(not fget(mget(currentroom.x*16+xtile,currentroom.y*16+ytile),1))do
		 		 		xtile+=xoff
		 		 		ytile+=yoff
		 		 	end
		 		 	_s.pos.x=xtile*8
		 		 	_s.pos.y=ytile*8
	 		 	end
		 	end
 		 	if(_s.pos.x<0) _s.pos.x+=128 currentroom.x-=1 currentroom.props=rooms[currentroom.y+1][currentroom.x+1]
 		 	if(_s.pos.x>128) _s.pos.x-=128 currentroom.x+=1 currentroom.props=rooms[currentroom.y+1][currentroom.x+1]
 		 	if(_s.pos.y<0) _s.pos.y+=128 currentroom.y-=1 currentroom.props=rooms[currentroom.y+1][currentroom.x+1]
 		 	if(_s.pos.y>128) _s.pos.y-=128 currentroom.y+=1 currentroom.props=rooms[currentroom.y+1][currentroom.x+1]

			_s.state:update()
		end,
		draw=function(_s)
			if(_s.overobj) spr(10,_s.pos.x,_s.pos.y-16+sin(_s.t))
			_s.state:draw()
		end,
		idlestate=function()
 		return{
 			flp=false,
			state="idle",
 			update=function(_s)
 			end,
 		 draw=function(_s)
 		 	spr(player.anim[player.dir].head[1],player.pos.x,player.pos.y-8,1,1,(player.dir=='l'),false)
 		 	spr(player.anim[player.dir].body[1],player.pos.x,player.pos.y,1,1,(player.dir=='l'),false)
 		 end
 		}
 	end,
	walkstate=function()
 		return{
			state="walk",
 			tap=0,
 			flp=false,
 			update=function(_s)
 				_s.tap=(_s.tap+1)%20
 			end,
	 		 draw=function(_s)
 		 		spr(player.anim[player.dir].head[flr((_s.tap/5)%2)+1],player.pos.x,flr(player.pos.y)-8+(((_s.tap/5))%2),1,1,(player.dir=='l'),false)
	 		 	spr(player.anim[player.dir].body[flr(_s.tap/5)+1],player.pos.x,flr(player.pos.y),1,1,(player.dir=='l'),false)
	 		 end
 		}
 	end
	}
	player.state=player.idlestate()
end

function creategamestates()
	gamestate={
		update=function(_s)
			_s.current:update()
		end,
		draw=function(_s)
			_s.current:draw()
		end,
		changestate=function(_s,_state,_params)
			_s.current=_s[_state]()
			_s.current:init(_params)
		end,
		--states
		title=function()
			return {
				tapbgx=0,
				tapbgy=0,
				battap=0,
				ttap=1,
				init=function(_s,_params)
					music(8)
				end,
				update=function(_s)
					_s.tapbgx=(_s.tapbgx+0.005)%2
					_s.tapbgy=(_s.tapbgy+0.0075)%2
					_s.battap=(_s.battap+1)%10
					_s.ttap=(_s.ttap%64)+0.5

					if(btnp(Ž)) music(0) gamestate:changestate("explore")
				end,
				draw=function(_s)
					--draw background
					rectfill(0,0,127,127,2)
					pal(7,13)
					pal(4,13)
					pal(15,13)
					for y=-3,16 do
						for x=-5,6 do
							local off=0
							if(y%2==1) off=-18
							spr(240,x*36-12+off-sin(_s.tapbgx)*32,4+y*8+sin(_s.tapbgy)*10)
						end
					end

					local fgoff=sin(_s.tapbgy+0.15)*5+5

					--plaque
					pal()
					_s:drawplaque(0,fgoff)

					spr(98,39,77+fgoff*.35)
					sspr(16,46,8,10,70,76+fgoff*.5)

					--plaque adornments
					spr(241,96,91+fgoff,1,1,true,false)
					spr(246,104,88+fgoff,1,1,true,false)

					spr(240,16,24+fgoff)
					for x=1,10 do
						spr(244,16+x*8,24+fgoff)
					end
					spr(240,104,24+fgoff,1,1,true)
					for x=0,88,88 do
						for y=1,7 do
							local flp=false
							if(x>0) flp=true
							spr(245,16+x,24+y*8+fgoff,1,1,flp)
						end
					end
					spr(246,16,88+fgoff)
					spr(241,24,91+fgoff)

					pal()

					--logo
					print("hazel",29,40+fgoff,7)
					print("may",51,40+fgoff,7)
					print("saves",65,40+fgoff,7)
					print("the",87,40+fgoff,7)
					local cta = "press z to start"
					print(cta,33,92+fgoff,14)

					for i=1,16 do
						local char=" "
						if(i==flr((sin(_s.tapbgx-0.75)*8))+9)char=sub(cta,i,i)
						print(char,29+(i*4),92+fgoff,7)
					end

					_s:drawlogo(28,48+fgoff)
					spr(97,60,48+fgoff)
					spr(64,87,56+fgoff,1,3)
					spr(65,95,56+fgoff,1,1)
					spr(81,95,64+fgoff,0.5,0.5)
					sspr(9,40,3,8,96,68+fgoff/2)

					batspr={47,63}
					--local sxoff= sin(_s.tapbgx+0.75)*8
					local byoff=sin(_s.tapbgy+0.05)*5
					local bxoff=flr((sin(_s.tapbgx+0.75)*4))
					local bxoff2=flr((sin(_s.tapbgx+0.85)*4))
					spr(batspr[flr(_s.battap/5)+1],78+bxoff,34+byoff)
					spr(batspr[(flr((_s.battap+2)/5)+1)%2+1],26+bxoff2,72+byoff)
				end,
				drawlogo=function(_s,x,y)
					local logodata={"202141242c1210606021402060242c1210606030802020242c12102424d02020242c100010424290202020242c604242902060242c6024241060206060694160601150202020606910116060121",
						"810124121114160605h416030106060606f6020206030122224202f602020612522426f1000102020632322425g12102020103010322224202f1210601120622260202f12114112114322602027",
						"c42432251606n60622260606n30102022222020242s2320222260424s2120222251424p10302022222020242r6062222020606o4243222020606b"}

					for s=1,3 do
						local d=1
						local c={{0,11,11},{9,0,0}}
						local x1=0
						for i=1,#logodata[s] do
							d=(d%2)+1
							local x2=x1+_s.basetoint(sub(logodata[s],i,i))-1
							local remainder=0
							if(x2>71) remainder=x2%70 x2=x2-remainder
							line(x+x1,y,x+x2,y,c[d][s])
							if(remainder>0) then
								x1=0
								x2=remainder-1
								y+=1
								line(x+x1,y,x+remainder,y,c[d][s])
							end
							if(x2>71) x1=0 else x1=x2+1
						end
						y+=4
					end
				end,
				drawplaque=function(_s,_x,fgoff)
					palt(2,true)
					palt(0,false)
					pal(4,4)
					for i=1,2 do
						local y={16,96}
						y=y[i]+fgoff
						local fy=(i==1)

						sprd={{66,16,false},
							{67,24,false},
							{68,32,false},
							{66,48,false},
							{67,56,false},
							{68,64,false},
							{68,81,false},
							{68,89,true},
							{67,97,true},
							{66,105,true,}}

						for sd in all(sprd) do
							spr(sd[1],sd[2],y,1,1,sd[3],fy)
						end

					end
					rectfill(40,16+fgoff,47,103+fgoff,0)
					rectfill(72,16+fgoff,80,103+fgoff,0)

					rectfill(16,24+fgoff,112,96+fgoff,0)
				end,
				basetoint=function(b)
					local base="0123456789abcdefghijklmnopqrstuvwxyz-_+[]{}|:;=.<>?/~`!@#$%^&*()"	
					for i=1,#base do
						if(b==sub(base,i,i)) return i
					end
					return
				end
			}
		end,
		explore=function()
			return {
				init=function(_s,_params)
					pal()
					currentroom.props=rooms[currentroom.y+1][currentroom.x+1]
				end,
				update=function(_s)
					player.overobj=false
					currentroom:update()
					player:update()
				end,
				draw=function(_s)
					cls()
					map(currentroom.x*16,currentroom.y*16,0,0,16,16)

					local draworder={}
					add(draworder,player)
					for p in all(currentroom.props) do
						local foundspot = false
						local newdraworder={}
						for d in all(draworder) do
							if(p.pos.y<=d.pos.y and not foundspot)then
								add(newdraworder,p)
								add(newdraworder,d)
								foundspot=true
							else
								add(newdraworder,d)
							end
						end
						if(not foundspot) add(newdraworder,p)
						draworder=newdraworder
					end
					for p in all(draworder) do
						p:draw()
					end
					--currentroom:draw()
					--player:draw()

					fillp(0b0101101001011010.1)
					rectfill(4,104,123,125,0x0)
					pal()

					spr(240,0,100)
					for i=1,14 do
						spr(244,i*8,100)
					end
					spr(240,120,100,1,1,true)

					spr(245,0,108)
					spr(245,120,108,1,1,true)
					spr(245,0,112)
					spr(245,120,112,1,1,true)

					spr(246,0,120)
					for i=1,14 do
						spr(247,i*8,120)
					end 

					spr(246,120,120,1,1,true)

					local sprl=60-((#player.inventory-1)*5)
					for i=1,#player.inventory do
						spr(player.inventory[i].sprite,sprl+(i-1)*10,112)
					end

					print("item", 56, 105, 7)
				end
			}
		end,
		dialog=function()
			return {
				agent=nil,
				response=false,
				give=false,
				state={},
				init=function(_s,_agent)
					_s:changestate("saystate")
					_s.agent=_agent
					if(_s.agent.portrait!="")then
						import(_s.agent.portrait)
						cls()
						
						fillp()
						pal()
						flip()
						for o in all(art.obj) do
							if(o.typ=="shape" and o.fillfg<16 and #o.verts>2) then
								--transparencies
								ofillfg=o.fillfg
								ofillbg=o.fillbg
								if(ofillfg==16) then 
									if(ofillfg!=0) then
										ofillbg=0
									elseif(ofillfg!=1) then
										ofillbg=1
									end
									palt(ofillbg,true)
								end
								o.activeedges={}
								local scanline=0
								for e in all(o.globaledges) do
									if(e.y_min==scanline) add(o.active_edges,createvert(e))
								end

								local shapedither = dither[o.dither]
								if(o.fillbg==16) shapedither=dither[o.dither]+0.5
								fillp(shapedither)

								for scanline=0,127 do
									o.activeedges=fillscanline(scanline,o.activeedges,o.globaledges,ofillfg,ofillbg)
								end
								fillp()
								pal()
								flip()
							end
							if(o.strokec!=16) then
								if(#o.verts>1) then
									local isline = 0
									if(o.typ=="line") isline=1
									for i=1,#o.verts-isline do
										line(o.verts[i].x,o.verts[i].y,o.verts[(i%#o.verts)+1].x,o.verts[(i%#o.verts)+1].y,o.strokec)
									end
									flip()
								end
							end
						end
					end
				end,
				update=function(_s)
					if(btnp(”)and not _s.response) _s.state.option-=1
					if(btnp(ƒ)and not _s.response) _s.state.option+=1
					_s.state:update()
					if(btnp(Ž)) then
						_s.state:select()
					end
					if(btnp(—)) local exit=false
				end,
				draw=function(_s)
					fillp()
					palt(0,false)
					rectfill(0,92,128,128,0)
					_s.state:draw()
				end,
				saystate=function()
					return {
						option=1,
						tap=0,
						globaldialog={
							{[0]="give an item.",[2]=1},
							{[0]="see ya later!",[2]=1}
						},
						update=function(_s)
							_s.tap=(_s.tap+0.1)%1
							if(_s.option>#gamestate.current.agent.dialog+2) _s.option=1
							if(_s.option<=0) _s.option+=#gamestate.current.agent.dialog+2
						end,
						draw=function(_s)
							local yoff=1
							local i=1
							local y=98
							for i=1,#gamestate.current.agent.dialog+2 do
								if(i<_s.option) then
									if(i<=#gamestate.current.agent.dialog) then
										y-=gamestate.current.agent.dialog[i][2]*6
									else
										y-=6
									end
								end
							end
							for i=1,#gamestate.current.agent.dialog do
								local c=5
								if(_s.option==i) then
									spr(4,8+1.25*sin(_s.tap),y-2+6*yoff)
									c=7
								end

								if(y+6*yoff>86) print(gamestate.current.agent.dialog[i][0],20,y+6*yoff,c)
								yoff+=gamestate.current.agent.dialog[i][2]
							end
							for i=1,2 do
								local c=5
								if(_s.option==#gamestate.current.agent.dialog+i) then
									spr(4,8+1.25*sin(_s.tap),y-2+6*yoff)
									c=7
								end
								print(_s.globaldialog[i][0],20,y+6*yoff,c)
								yoff+=_s.globaldialog[i][2]
							end
							rectfill(16,92,112,96,0)
							rectfill(16,119,112,125,0)
							gamestate.current:drawframe()
						end,
						select=function(_s)
							if(_s.option<=#gamestate.current.agent.dialog) gamestate.current:changestate("responsestate",_s.option,"dialog")
							if(_s.option==#gamestate.current.agent.dialog+1) gamestate.current:changestate("inventorystate")
							if(_s.option==#gamestate.current.agent.dialog+2) gamestate:changestate("explore")
						end
					}
				end,
				responsestate=function(_option,_typ)
					return {
						typ=_typ,
						option=_option,
						tap=0,
						update=function(_s)
							_s.tap=(_s.tap+0.1)%1
						end,
						draw=function(_s)
							if(_s.typ=="dialog") then
								pal(15,gamestate.current.agent.dialogc[2])
								pal(4,gamestate.current.agent.dialogc[2])
								pal(7,gamestate.current.agent.dialogc[1])
								gamestate.current:drawframe()
								print(gamestate.current.agent.dialog[_s.option][1],16,97,gamestate.current.agent.dialogc[1])
							elseif(_s.typ=="inventory") then
								pal(15,gamestate.current.agent.dialogc[2])
								pal(4,gamestate.current.agent.dialogc[2])
								pal(7,gamestate.current.agent.dialogc[1])
								gamestate.current:drawframe()
								print(gamestate.current.agent:giftresponse(player.inventory[_s.option].name),16,97,gamestate.current.agent.dialogc[1])
								--print(gamestate.current.agent.idialog[_s.option].d,16,97,gamestate.current.agent.dialogc[1])
								--if(gamestate.current.agent.idialog[_s.option].receive)del(player.inventory,player.inventory[_s.option])
							end
						end,
						select=function(s)
							if(currentroom.x==3 and currentroom.y==0 and s.option==3) then
								gamestate:changestate("ending")
							else
								if(s.typ=="inventory" and s.option<=#player.inventory) del(player.inventory,player.inventory[s.option])
								if(gamestate.current.agent.satisfied) then
									gamestate:changestate("explore")
								else
									gamestate.current:changestate("saystate")
								end
							end
						end
					}
				end,
				inventorystate=function()
					return {
						option=1,
						tap=0,
						update=function(_s)
							_s.tap=(_s.tap+0.1)%1

							if(_s.option>#player.inventory+1) _s.option=1
							if(_s.option<=0) _s.option+=#player.inventory+1
						end,
						draw=function(_s)

							local yoff=1
							local i=1
							local y=106-(_s.option-1)*6
							for i=1,#player.inventory do
								local c=5
								if(_s.option==i) then
									spr(player.inventory[i].sprite,8+1.25*sin(_s.tap),y-2+6*(i-1))
									c=7
								end

								--if(y+6*yoff>86) 
								local ypos=y+6*(i-1)
								if(ypos>91 and ypos<120) print(player.inventory[i].name,20,ypos,c)
							end

							local c=5
							if(_s.option==#player.inventory+1) then
								spr(8,8+1.25*sin(_s.tap),y-2+6*#player.inventory)
								c=7
							end

							--if(y+6*yoff>86) 
							local ypos=y+6*#player.inventory
							if(ypos>91 and ypos<120) print("go back",20,ypos,c)
							rectfill(16,92,112,96,0)
							rectfill(16,119,112,125,0)
							gamestate.current:drawframe()
						end,
						select=function(s)
							if(s.option==#player.inventory+1)gamestate.current:changestate("saystate") return
							--if(s.option==1)
							gamestate.current:changestate("responsestate",s.option,"inventory") return
						end
					}
				end,
				changestate=function(_s,_state,_params,_params2)
					if(_state=="responsestate")_s.response=true else _s.response=false
					_s.state=_s[_state](_params,_params2)
				end,
				drawframe=function(_s)
					palt(0,true)
					spr(240,0,88)
					for i=1,14 do
						spr(244,i*8,88)
					end
					spr(240,120,88,1,1,true)

					for i=1,3 do
						spr(245,0,88+(i*8))
					end
					for i=1,3 do
						spr(245,120,88+(i*8),1,1,true)
					end

					spr(246,0,120)
					for i=1,14 do
						spr(247,i*8,120)
					end
					spr(246,120,120,1,1,true)

					pal()
				end,
			}
		end,
		ending=function()
			return {
				t=0,
				di=1,
				chars={current=1},
				currentdialog="",
				init=function(_s,_params)
					monsterparty.scientist.agent.pos={x=64,y=56}
					monsterparty.scientist.agent.dialog="happy halloween",
					add(_s.chars,monsterparty.scientist.agent)
					if(monsterparty.franky.present) then
						monsterparty.franky.agent.pos={x=52,y=64}
						monsterparty.franky.agent.dialog="i love party!",
						add(_s.chars,monsterparty.franky.agent)
					end
					if(monsterparty.shedevil.present) then
						monsterparty.shedevil.agent.pos={x=80,y=60}
						monsterparty.shedevil.agent.dialog="jeez, i'm still so tired!",
						add(_s.chars,monsterparty.shedevil.agent)
					end
					if(monsterparty.tentacle.present) then
						monsterparty.tentacle.agent.pos={x=106,y=70}
						monsterparty.tentacle.agent.dialog="behold my dance of death!",
						add(_s.chars,monsterparty.tentacle.agent)
					end
					if(monsterparty.wolfman.present) then
						monsterparty.wolfman.agent.pos={x=28,y=56}
						monsterparty.wolfman.agent.dialog="stay away or pet my belly!",
						add(_s.chars,monsterparty.wolfman.agent)
					end
					if(monsterparty.vampire.present) then
						monsterparty.vampire.agent.pos={x=86,y=36}
						monsterparty.vampire.agent.dialog="i can't stay out too late.",
						add(_s.chars,monsterparty.vampire.agent)
					end
					if(monsterparty.mummy.present) then
						monsterparty.mummy.agent.pos={x=70,y=36}
						monsterparty.mummy.agent.dialog="let's party like its nine!",
						add(_s.chars,monsterparty.mummy.agent)
					end
					if(monsterparty.devil.present) then
						monsterparty.devil.agent.pos={x=36,y=36}
						monsterparty.devil.agent.dialog="i wish anton was here.",
						add(_s.chars,monsterparty.devil.agent)
					end
					if(monsterparty.zombie.present) then
						monsterparty.zombie.agent.pos={x=24,y=40}
						monsterparty.zombie.agent.dialog="mmmmmm.",
						add(_s.chars,monsterparty.zombie.agent)
					end
					if(monsterparty.killer.present) then
						monsterparty.killer.agent.pos={x=60,y=24}
						monsterparty.killer.agent.dialog="i miss my mommy.",
						add(_s.chars,monsterparty.killer.agent)
					end
					if(monsterparty.ghost.present) then
						monsterparty.ghost.agent.pos={x=48,y=50}
						monsterparty.ghost.agent.dialog="wooooohooooooo!",
						add(_s.chars,monsterparty.ghost.agent)
					end
					_s.currentdialog=_s.chars[1].dialog
					music(9)
					pal()
				end,
				update=function(_s)
					_s.t=(_s.t+0.1)%2					
					local currentchar=_s.chars[_s.chars.current]
					if(_s.chars.current>#_s.chars) currentchar=_s.chars[1]
					if(_s.di<=#_s.currentdialog) _s.di+=0.5
					if((btn(4) or btn(5)) and _s.di>=#_s.currentdialog) then
						if(_s.chars.current<#_s.chars)then
							_s.chars.current+=1 _s.di=0 _s.currentdialog=_s.chars[_s.chars.current].dialog 
						elseif(_s.chars.current==#_s.chars)then
							_s.chars.current+=1 _s.di=0 _s.currentdialog="is that everyone?"
						elseif(_s.chars.current==#_s.chars+1)then
							_s.chars.current+=1 _s.di=0 
							if(#_s.chars<5) then
								_s.currentdialog="this is pathetic!"
							elseif(#_s.chars<8) then
								_s.currentdialog="not a terrible turn out!"
							else
								_s.currentdialog="what an awesome party!"
							end
						elseif(_s.chars.current==#_s.chars+2)then
							_s.chars.current+=1 _s.di=0 
							if(#_s.chars<5) then
								_s.currentdialog="hazel, how do you feel"
							elseif(#_s.chars<8) then
								_s.currentdialog="im sure i can make hazel..."
							else
								_s.currentdialog="thanks for making this..."
							end
						elseif(_s.chars.current==#_s.chars+3)then
							_s.chars.current+=1 _s.di=0 
							if(#_s.chars<5) then
								_s.currentdialog="about unnecessary surgery?"
							elseif(#_s.chars<8) then
								_s.currentdialog="into at least 3 more guests!"
							else
								_s.currentdialog="the best halloween ever!"
							end
						else 
							gamestate:changestate("lastscreen")
						end
					end

					currentchar:update()
				end,
				draw=function(_s)
					cls()
					map(0,0,0,0,16,16)

					--draw current characte
					local currentchar=_s.chars[_s.chars.current]
					if(_s.chars.current>#_s.chars) currentchar=_s.chars[1]
					for i=1,#_s.chars do
						_s.chars[i]:draw()
					end

					spr(7,80,80,1,1,true)
					spr(25,80,88,1,1,true)

					--draw gui
					palt(0,false)
					rectfill(4,100,123,125,0)
					pal()

					spr(240,0,96)
					for i=1,14 do
						spr(244,i*8,96)
					end
					spr(240,120,96,1,1,true)

					spr(245,0,104)
					spr(245,120,104,1,1,true)
					spr(245,0,112)
					spr(245,120,112,1,1,true)

					spr(246,0,120)
					for i=1,14 do
						spr(247,i*8,120)
					end 

					spr(246,120,120,1,1,true)

					print(sub(_s.currentdialog,1,_s.di),64-_s.di*2,108,currentchar.dialogc[1])

				end
			}
		end,
		lastscreen=function()
			return {
				t=0,
				text={
					[1]="happy halloween",
					[2]="",
					[3]="from your friends",
					[4]="",
					[5]="wayne kubiak (@wanyodos)",
					[6]="& james id (@jamesid)",
				},
				init=function(_s,_params)
					pal()
				end,
				update=function(_s)
					if(_s.t<60) _s.t+=1
					if(_s.t>=60 and(btn(4) or btn(5))) run()
				end,
				draw=function(_s)
					cls()
					for i=1,#_s.text do
						print(_s.text[i],64-#_s.text[i]*2,32+i*6,9)
					end
					if(_s.t>=60) print("press z or x to restart", 20, 90, 7)
					spr(97,24,36)
					spr(71,96,36)
				end
			}
		end,
	}
	gamestate:changestate("title")
end

function createroom(x,y,_props)
	return {
		x=x, y=y,
		props=_props,
		update=function(_s)
			for p in all(_s.props) do
				p:update()
			end
		end,
		draw=function(_s)
			for p in all(_s.props) do
				p:draw()
			end
		end
	}
end

function createnpc(_x,_y,_props)
	local npc={
		t=0,
		satisfied=false,
		talking=false,
		movinghead=false,
		want={},
		likegift="",
		hategift="",
		pos=vector(_x,_y),
		update=function(_s) 
			_s.t=(_s.t+0.1)%2
			if(not _s.satisfied and boxcollision(_s.pos,player.pos,vector(8,16),vector(8,8))) then
				if(not _s.talking) then
					_s.talking=true
					gamestate:changestate("dialog",_s)
				end
			else
				if(_s.talking) _s.talking=false
			end
		end,
		draw=function(_s)	
			if(_s.movinghead) spr(_s.head[flr(_s.t)+1],_s.pos.x,_s.pos.y+flr(_s.t)) else spr(_s.head,_s.pos.x,_s.pos.y+flr(_s.t))
			spr(_s.body[flr(_s.t)+1],_s.pos.x,_s.pos.y+8)
		end,
		giftresponse=function(_s, _gift)
			for i=1,#_s.want do
				if(_gift==_s.want[i]) _s.satisfied=true monsterparty[_s.name].present=true monsterparty[_s.name].agent=_s:clone() return _s.likegift
			end
			return _s.hategift
		end,
		clone=function(_s)
			local clone={}
			for key,value in pairs(_s) do
				clone[key]=value
			end
			return clone
		end
	}
	for key,value in pairs(_props) do
		npc[key]=value
	end
	return npc
end

function createscientist(_x,_y)
	return createnpc(_x,_y,{
		head=42,
		body={58,59},
		portrait="",
		dialogc={2,1},
		name="scientist",
		dialog={
			{[0]="hey, doc!  what's\n  the prognosis?",
			[1]="halloween is almost\n over, but i'm not sure\n if my guests will arrive.",
			[2]=2},
			{[0]="what do you need?",
			[1]="please help my monster\n friends get ready for\n the party.",
			[2]=1},
			{[0]="we're ready\n let's party!",
			[1]="splendid.  let's\n get this party\n started quickly.",
			[2]=2}
		},
		hategift="oh... thanks."
	})
end

function createvampire(_x,_y)
	return createnpc(_x,_y,{
		head=36,
		body={52,53},
		portrait="",
		dialogc={12,1},
		name="vampire",
		dialog={
			{[0]="hey, drac!  how's it\n  hangin'?",
			[1]=" i can't sleep\n my crypt is bare.\n i vant some decorations!",
			[2]=2},
			{[0]="bite anyone lately?",
			[1]="no. are you volunteering?",
			[2]=1}
		},
		likegift="now i von't be embarassed\n to invite friends over",
		hategift="this sucks.",
		want={itemlist[6],itemlist[4],itemlist[7],itemlist[3]}
	})
end

function createdevil(_x,_y)
	return createnpc(_x,_y,{
		head=32,
		body={48,49},
		portrait=")(g4030/n09m0gt0bw)(g4032do2$o2/s2^x28x2hs)(g4030_}2n{2v.2o<2w`0z~0.<)(g4031/11e11o71i81`6)(g4032h*2%*3~53#b)(e80c39f1@h1>b1-e1ut1t(3-(3yo3sf3fb)(28131`d1#438439e1@g1`e)(e81c0$b0:h0]r0}!1%93492g?2fm28h)(e8130]y0+z0zq0wq0x-0_;0{})(e8132fx2iy2kp2nq2m-2j;2g{)(g1131~31*i30i3813261&11%7)(g71c2cu29+23+21z25x)(g71c0:u0._0!+0#z0>w)(ge1c0^-0^=0$:)(g71c0~`22`28<22^0!^))10*u21v29q2es))10$t0@v0.r0]u))d23@21$0*@)(f71c0]30ze0_o0;p0.k0]f)(f71c2d32ld2jm29p27j2dd)(g11c1;w1}>1|(1<(1;>)(g11c3hu3i/3e(3l(3l.)(g11c3j=3a?33/3d/3l>)(g11c1:;1.<1#/1;/",
		dialogc={8,2},
		name="devil",
		dialog={
			{[0]="hey, scratch!\n what's wrong'?",
			[1]=" i want to party,\n but i have no\n costume!",
			[2]=2}
		},
		likegift="now i'm ready to\n party!'",
		hategift="damn you.",
		want={itemlist[6],itemlist[4],itemlist[1],itemlist[3]}
	})
end

function createshedevil(_x,_y)
	return createnpc(_x,_y,{
		head=33,
		body={48,49},
		portrait=")(g4030uc2tc2zg2vj2-m0tl0_i)(g4030l-0^_0m<0t{)(g4032n-2/+2=]2/:2e:2n{)(g4031-03[13x73[b)(280c0&a0}f0v|1s01[c1qw1r(3:(3+q3ob2u<2hh)(fe0c1i(1e#1g_1um1~j1!g1!735735g37j3zp3;_3.%3;()(fe0c1&c1>60}>0|z0=u0[j0}80<30<j0~t25r28h2432872ek2bv2f=395)(g10c1+j1v~1[(1@(1&>1]])(g10c3kk3j}36/3b(3s(3x?))51$/3b@1#^3c()(g2g21/s1&v3ar33z30;1%y)(g12c0#.0~:0;|0.<)(g12c20<29.2c}24:)(gf2c0%.0%@0#~))10*}25+2a+))10#}0>+0|+))11!11*123*)(g12c1`j1^l35j36i35f1^h1`g)(g72c320323311)(g72c1@21#41#2)(fe230}=0|[0+x0{`)(fe232f=2d[2hy2g`2e/",
		dialogc={8,2},
		name="shedevil",
		dialog={
			{[0]="hey you!\n everything okay?",
			[1]=" i am so hungry!",
			[2]=2}
		},
		likegift="now i've got\n enough energy\n to party!",
		hategift="damn you.",
		want={itemlist[10],itemlist[9],itemlist[8],itemlist[11]}
	})
end

function createmummy(_x,_y)
	return createnpc(_x,_y,{
		head=34,
		body={50,51},
		portrait="",
		dialogc={10,9},
		name="mummy",
		dialog={
			{[0]="hey pharaoh!\n why so mum?",
			[1]="i'm so brittle\ni need to moisterize!",
			[2]=2}
		},
		likegift="this'll do!\n thanks mortal!",
		hategift="hrmph!",
		want={itemlist[3],itemlist[5]}
	})
end

function createkiller(_x,_y)
	return createnpc(_x,_y,{
		head=39,
		body={54,55},
		portrait="",
		dialogc={8,2},
		name="killer",
		dialog={
			{[0]="ready to cut\n a rug?",
			[1]="i need to\ncut something!",
			[2]=2}
		},
		likegift="take that!",
		hategift="bogus!",
		want={itemlist[3],itemlist[4],itemlist[6],itemlist[11]}
	})
end

function createghost(_x,_y)
	return createnpc(_x,_y,{
		head=14,
		body={30,31},
		portrait=")(g4030nr0&s0;+0i_0vx)(g4032fs2$u2>-2!})(g4030;?2v?2t~2_%0+$0<`)(g4031l838a1om1wd)(g4033ka3`b3?f)(c70c0*h0.l0+v0y~1|b1<q1:~1|(3](3:_3:42-z2kl)(g70c3[52?*2^&3(33*b3?e3{g)(g70c1<n1zm1rg1t81-81}d1?e)(g10c3ib3b533934j3an3ij)(g10c2c@2k%2r?2n]2d_26:)(g10c0<?0}!1:11`40^%0!/)(g70c2a;2d`2j@2o>2k}2e{)(g70c0<`0;#0=*1`10#%0``)(gc0c1!(1`#1*}1*$1&()(gc0c3o?3h$3i(3r(3n$)(gc0c3~d3|g3:q3zm3_f)(gc0c1=m1/m1/s1.w1<n",
		dialogc={6,11},
		name="ghost",
		dialog={
			{[0]="ready to scare\n up some fun?",
			[1]="i need to\nimprove my costume!",
			[2]=2}
		},
		likegift="be-ooo-tiful!",
		hategift="mooooan!",
		want={itemlist[1],itemlist[3],itemlist[4],itemlist[10]}
	})
end

function createtentacle(_x,_y)
	return createnpc(_x,_y,{
		movinghead=true,
		head={44,45},
		body={60,61},
		name="tentacle",
		portrait=")(g4030ji0!h0dq0mm)(g4032ei2!i2wn)(g4030{]2r{2l:2s<0-<0=:)(g4030q&0`&1s61x0)(g4032f*2?*3|53~73c73k2)(b30c1z(1h{1-d0!?0]y0we0~32fm2u.3ri3.]3?()(g1g228i2fn2t<3qi3={3<(3q(3t[3dm2n.)(08gc0;f0yk0xv0}+0`y0@m)(08gc0`!0]*1-81}h1@h33721^)(08gc1>w1y_1u<1y&1>(34!30+)(g0gc0+n0:j0/o0?t0;o)(g0gc1:30~&1^11^71`3)(g0gc1_:1<+1$}1%?1>:))70.v0}w))71@91.b))71!~1;@)(g0gc0@p0`y0:+0~]0%x)(g0gc3223371@h1=h1^k34d358)(g0gc32}34!1<(1{*1;(1@(38^39.",
		dialogc={11,8},
		dialog={
			{[0]="ready to slither\n to the party?",
			[1]="all hoo-mans\n must die!",
			[2]=2}
		},
		likegift="delightful!",
		hategift="depart from this\n world, hoo-man!",
		want={itemlist[1],itemlist[3],itemlist[4]}
	})
end

function createwolfman(_x,_y)
	return createnpc(_x,_y,{
		head=40,
		body={56,57},
		portrait=")(g4030rj2yk2}o2+q2=u0tw0-q)(g4032d>2%<2/~2&#)(g4030^>0o>0v~0o^)(g4031=c3]c3xh3]j)(24231/11/91|g1-i1+q1.[30$37?3hx3ml35e331)(6d2c1}l1=g1+e1ya1ma1f818c13i17v16_19`1d<1c(3>(3|?3?`3`]3>z3!t3$l3|a3pd3eb3jh3cm3fq37v3a_1&=1._1~t)(942c0^325f2672fl2me2kr2tl2oz2y_2k?2s/3f23m134d1@d1=80+&0=%0w?0]?0r+0+_0qq0}r0yk0ya0{h0.j0;70@d)(g92c21]26[2fx2c|26:)(g92c0#[0`|0=|0[y0<+)(g12c0#.21.25/20`0#~0`>)(g92c0%]0`<0#=0^;0&]))10?w0#x0^+0*y26v)(g72c26@35021$)(g72c0$$0/@1!1))10/@0$#21#27!)(g92c0$a0@h0~e0?l0]k0.r0~l0%q0&h)(g92c1>81=d1/c1?l1#g1^v31h36l36d3ee37732c3081$c))12g.2b~2a&))11v:1z())13q.3s(",
		dialogc={9,4},
		name="wolfman",
		dialog={
			{[0]="hey wolfie.\n need some pets?",
			[1]="i need something\n to gnaw on!",
			[2]=2}
		},
		likegift="i'm a good boy!",
		hategift="growl!",
		want={itemlist[7],itemlist[4],itemlist[9],itemlist[8],itemlist[10],itemlist[11]}
	})
end

function createtail(_x,_y)
	return {
		t=0,
		sprites={35,37},
		pos=vector(_x,_y),
		update=function(_s) 
			_s.t=(_s.t+0.1)%2
		end,
		draw=function(_s)				
			spr(_s.sprites[flr(_s.t)+1],_s.pos.x,_s.pos.y)
		end,
	}
end

function createfrank(_x,_y)
	return createnpc(_x,_y,{
		head=38,
		body={54,55},
		portrait=")(g4030`m0fn0mq0gu0~s0<q)(g40327n2=n2{r2;w)(g4030{]2m]2h:2o?0[>0-;0}:)(g4030r^0#*1r81u3)(g40327^2[&3y13_5383)(d50c1.g1*q3bf3xf3}n3:(1l(1no1sg)(130c1&p1/i1`436438h1*p)(b30c0}*1<73a82i*2gi0]k)(510c0}90ze0_|0{=0|p0<r0@n0^q24n2ar2fo2h=2k|2lb2c9)(g90c2d]23{25.2a.2c:)(g90c0${0!.0=.0;{)(gb0c0}{2g{2cw0.w)(gb0c0&}0^/21/))10>&0~%27^))12e.2c>29?))10:<0.?0~?)(gd0c0~90.d0/h0<l0/p0$l0!e0&a)(5d0c1}41_41_b1}b)(5d0c3g43l43lb3gb)(g5131|61=61.71/81/b1|9)(g51337b3f93f63d6))11]_1]())13p-3r())11*p32x33()(gd1c1sg1op1rv1wl1[m1|q1=h)(gd1c3bg31p37t3el3pq3vl3{o3xg",
		dialogc={11,3},
		name="franky",
		dialog={
			{[0]="hey, franky!\n why so stiff?",
			[1]="...",
			[2]=2}
		},
		likegift="can speak now.\n good for party.\n thanks.",
		hategift="gurgle...",
		want={itemlist[1],itemlist[5]}
	})
end

function createzombie(_x,_y)
	return createnpc(_x,_y,{
		active=false,
		head=41,
		body={56,57},
		portrait="",
		name="zombie",
		dialogc={10,2},
		dialog={
			{[0]="hey stiff!\n fallin' to pieces?",
			[1]="mmmmmm...",
			[2]=2}
		},
		likegift="mmmmm....",
		hategift="mmmmm....",
		want={itemlist[1],itemlist[4],itemlist[10],itemlist[11]}
	})
end

function createitem(_x,_y,_spr,_name)
	return {
		pos=vector(_x,_y),
		name=_name,
		sprite=_spr,
		active=true,
		update=function(_s)
			if(_s.active and boxcollision(_s.pos,player.pos,vector(8,8),vector(8,8)))then
				player.overobj=true
				if(_s.active and player.grab) then
					add(player.inventory,_s)
					sfx(18)
					_s.active=false
				end
			end
		end,
		draw=function(_s)
			if(_s.active) spr(_s.sprite,_s.pos.x,_s.pos.y)
		end
	}
end

function createdecor(_spr,_x,_y,_w,_h)
	return {
		pos=vector(_x,_y),
		w=_w,
		h=_h,
		name="decor",
		sprite=_spr,
		active=true,
		update=function(_s)
		end,
		draw=function(_s) 
			spr(_s.sprite,_s.pos.x,_s.pos.y,_s.w,_s.h)
		end
	}
end

function createdoor(_x,_y)
	local open=(debug)
	return {
		pos=vector(_x,_y),
		name="door",
		sprite=_spr,
		active=true,
		open=open,
		update=function(_s)
		end,
		draw=function(_s) 
			spr(206,_s.pos.x,_s.pos.y-8)
			if(_s.open) spr(159,_s.pos.x,_s.pos.y) else spr(222,_s.pos.x,_s.pos.y)
		end
	}
end

function fillscanline(_scanline,_active,_global,_ofillfg,_ofillbg)
	local fillc=_ofillfg+(16*_ofillbg)
	for i=1,#_active,2 do
		if(i+1<=#_active) then
			line(round(_active[i].x_val),
				_scanline,
				round(_active[i+1].x_val),
				_scanline,fillc)
		end
 	end
 	
 	--update active edges
 	for a in all(_active) do
 		a.x_val+=a.m
 	end
 	
 	--add any new active edges
 	for g in all(_global) do
 	 if(g.y_min==_scanline+1) add(_active,createvert(g))
 	end
 	
 	--reorder active edges
 	local new_ae={}
 	for a in all(_active) do
 		if(a.y_max>_scanline+1) then
	  		local added=false
	  		local next_ae={}
	  		for n in all(new_ae) do
	  			if(not added and 
	  			a.x_val<n.x_val) then
	  				add(next_ae,a)
	  				added=true
	  			end
	  			add(next_ae,n)
	  		end
	  		if(not added)add(next_ae,a)
	  		new_ae=next_ae
	  	end
 	end
 	return new_ae
end

function createvert(ref)
	return {
		y_min=ref.y_min,
		y_max=ref.y_max,
		x_val=ref.x_val,
		m=ref.m
	}
end

function findedges(_verts)
 --initialize all edges
	local all_edges={}

	for s in all(_verts) do
		local y_min=s.y
		local next_s=_verts[(s.i%#_verts)+1]
		local y_max=next_s.y
		local x_val=s.x
		local mx=(s.x-next_s.x)
		local my=(s.y-next_s.y)
		local m=nil
		if(my!=0) m=mx/my
		if(next_s.y<s.y) then
			y_min=next_s.y
			y_max=s.y
			x_val=next_s.x
		end
		if(s.y==next_s.y) then
		 if(s.x<next_s.x) then
		 	x_val=s.x
			else
				x_val=next_s.x
			end
		end
		add(all_edges,{
			y_min=y_min,
			y_max=y_max,
			x_val=x_val,
			m=m
		})
	end
	
	local global_edges = {}
	--initialize global edge table
	for e in all(all_edges) do
		if(e.m!=nil) then
			new_ge = {}
			local added=false
			for g in all(global_edges) do
			 if(not added and 
			 (e.y_min<g.y_min or
			 (e.y_min==g.y_min and
			 (e.y_max<g.y_max or
			 (e.y_max==g.y_max and
			 e.x_val<g.x_val))))) then
			  add(new_ge,e)
			  added=true
			 end
			 add(new_ge,g)
			end
			if(not added)add(new_ge,e)
			global_edges=new_ge
		end
	end
	
	return global_edges
end

function find(_t,_v)
	for i=1,#_t do
		if(sub(_t,i,i)==_v)return i
	end
	return 0
end

function import(_string)
	local h="0123456789abcdefghijklmnopqrstuvwxyz-_+[]{}|:;=.<>?/~`!@#$%^&*()"
	local i=1
	--local art={}
	art.obj={}
	repeat
		local objtype=sub(_string,i,i+1)
		i+=2
		local newobj={}
		newobj.strokec=find(h, sub(_string,i,i))-1
		i+=1
		if(objtype==")(")then --shape
			newobj.typ="shape"
			newobj.fillfg=find(h, sub(_string,i,i))-1
			newobj.fillbg=find(h, sub(_string,i+1,i+1))-1
			newobj.dither=find(h, sub(_string,i+2,i+2))-1
			i+=3
		else
			newobj.typ="line"
		end
		newobj.verts={}
		local verti=0
		while(i<#_string and sub(_string,i,i+1)!=")(" and sub(_string,i,i+1)!="))") do
			printh(sub(_string,i,i+2))
			verti+=1
			local x=0
			local y=0

			local hundreds=find(h,sub(_string,i,i))-1

			if(hundreds==0b11)then
				x=62 y=62
			elseif(hundreds==0b10)then
				x=62
			elseif(hundreds==0b01)then
				y=62
			end

			x+=find(h,sub(_string,i+1,i+1))
			y+=find(h,sub(_string,i+2,i+2))
			add(newobj.verts, {x=x,y=y,i=verti})
			i+=3
		end
		if(#newobj.verts>2) then
			newobj.globaledges=findedges(newobj.verts)
		end
		add(art.obj,newobj)
	until(i>#_string)

	--return art
end

function addartobj(_typ,_verts,_stroke,_fg,_bg,_dither)
	if(_typ==2) then
		add(art.obj,{
			typ="shape",
			verts=_verts,
			strokec=_stroke,
			fillfg=_fg,
			fillbg=_bg,
			dither=_dither,
			globaledges=findedges(_verts)})
	else
		add(art.obj,{
			typ="line",
			verts=_verts,
			strokec=_stroke})
	end
end

function boxcollision(_pos1, _pos2, _size1, _size2)
	return _pos1.x<_pos2.x+_size2.x and _pos1.x+_size1.x>_pos2.x and _pos1.y<_pos2.y+_size2.y and _pos1.y+_size1.y>_pos2.y
end

function ptcollision(_pos1, _pos2)
	return _pos1.x<_pos2.x+8 and _pos1.x>_pos2.x and _pos1.y<_pos2.y+8 and _pos1.y>_pos2.y
end

function vector(_x,_y,_i)
	return {x=_x,y=_y,i=_i}
end

function round(_value)
	local remainder=_value
	local returnvalue=flr(_value)
	remainder-=returnvalue
	if(remainder>=0.5) returnvalue+=1
	return returnvalue
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000110000000000000000000001101000000000000000000
00000000044999400449994004499940049999400449994004999440049999400499994004999940001881000000000000000000001111000000000000000000
00000000494999944944949449499994494999944949999449949494499999944999999449999994001281000000000000000000001111000067760000000000
000000009944949994ff9f4999444999994994999944999999944999999944499999444999944449001281000000000000000000011111100677776000677600
0000000094ff9f499e1ff1e994ffff4999f94f4994ff4949999999999999ee449999ee44999eee44001221000000000000000000001111000777777006777760
000000009e1ff1e99e1ee1e99e1ff1e9941ff1e99e1ff149999999999999e1f49999e1f4999e11f4000110000000000000000000011111100717717007777770
000000009e1ee1e99fff1ff99e1ee1e99e1ee1e99e1ee1e9494999949949f1f09949f1f4999efff0001281000000000000000000011111100717717007177170
0000000009ffff9090f11f9009ff1f0909ffff9009ffff900444944009449f000949ff400949f800000110000000000000000000001111000777777007177170
00000000008ee800088ee880008ee80000000000000000000022220000000000000000000088e800000000000000000000000000001101000777777007777770
000000000e2882e0f028820f0e2882e0018ee810018ee8100e2882e001222210012222100e28880000282e000e88e80000000000001111007777777776717767
000000000ff880f0f008800f0f0880f00e28fff00fff82f00f0880f00e288240042882e00f088e0000e88ffff00888ee00000000001111007677776777777777
000000000ff1c1f0001cc1000f1cc1f00eccff0000ffccf00f1cc1f00ff1cc0000cc1ff00f0cc0e000ecccfff00cc0ee00000000011111100777777006777760
0000000000cc1c0000cc1c0000cc1c00008811000011c88000cc1c000ff1188008811ff000cc100008cc1c020021cc80000000000111111007d77d7007d77d70
0000000000880880008808800088088000880200002008800022022000200820028002000088820008800120002208000000000001111110006d77d007d777d6
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011110000007d00007077d0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000161100004540400000000045040000dd00d0000000000000000000000000000077600000000000
078ee8700088880006d7776000000008001111000000008001611110444544400494409004a976000d66ddd00000000000000000000000000778770005000500
077ee77008e88e8066d7777d0000008801c11c1000000880013b131045777754449949444aaa9760d66ddd6d0000000000000000000000006787776055555550
08eeee8088f88f88677d77d60000000101cccc100000001003bbbb3047788774f449444f0aa91170dd6226dd0000000000bb00000000bb006633776050a5a050
8188881881ffff18d777dd7600000001c11cc11c000000010333333057177174f114411fa11a1170d2dcc2dd0000000000bbb000000bbb002371326000555000
881ee1888e1ff1e86191191600000000cc8cc8cc00000000731bb1370777777044911944a81a9700d775577d00000000000bbb0000bbb3006311366000606000
087887808e1ee1e8d711117d000000001c6666c10000000063bbbb3604d7d740044114400aa11070077c2770000000000008bb000b8b33000633660000000000
0288882082ee8e280d7776d00000000001788710000000000031130000777500024774200098870002c88c2000000000000bb3000bbb30000066600000000000
002221000000000006d11d600000000001566510000000000d6bbd600d0000d006d22d6000000000002cc200000000000088b3000b8b30000000000000000000
08188280801222807777d77766d11d661555555115188151dd66d6dd6d6116d666666666d6d22d6d067dd760062882600b28bb000b88b3000000000050000050
0ee22080ee2880086d7d77d6776d76771157751161c55551d166661ddd6666dd6d6666d6666666660d6717d00d6717d00bbbbb000bbbbb300000000055000550
0ee181e0ee02810e77d66d7777d66d77cc5675cc66c55151b3d66d3bbbd66dbb44d6dd446d6666d6dd77d7dddd77d7dd0b88bb3003b88b300000000005555500
2288180022881800771dd177001dd100cc1717cc08155111bb11d1bb3b11d1b3426c612444dcd144dd7717ddd177171d8328b338833823380000000000a5a000
00ee0ee000ee0ee000d7170000d71700081111808811511100dddd0000dddd0070cc1c0742cc1c240077d7000077d70082333328823333280000000000555000
000000000000000000110d0000110d008811818888d1151100dd0d0000dd0d000022020070220207004404000044040008888880088888800000000000606000
000000000000000000660660006606600066066000dd011100440440004404400044044000440440006606600066066000000000000000000000000000000000
00000000000000000000000000000000000000000feffef000000000000b000000f77f00007777000066660000000000080000000000f000000ff00000000000
0000600000060000000000000000000000000000fefff22f00000aa0099bb9900f7777f0071111700666666000000092820880000000f0000004ff0000000000
0000600000060000000000000000000000000000e2ee22ee0000a99a9a9999a9ff7777ff0613316006dddd6000000422008778000000f00000aa4ff000000000
0000060000600000000000000000000000000000e2eee2e2aaa9a00aa9aaaa9af117711f007117000d11d1d00000441001788880009b4300008aa4f400000000
00000600006000002000000000022000000000000e22ee229999a00a9a1aa1a941811814061731600dddddd0009941000222877009abbb900aaa8a4400000000
0000060006d000002200000000222000000000000000022020209999991991994771177461733b1661dddd1609d9d00000811200097a99900a8aa90000000000
0000006006d00000222200002222200022000000000000e0000002204999999404f77f40613bbb16611111160d91d0000008802899999999aaa9090000000000
0000006060d00000222222222222220222200222000000e000000000049119400071f70006777760dddddddd991d00000000008004999940aa0a000000000000
0000000660600000000b30000099999000bbb3006dddddddddddddddddddddd606666dd0000000000dddddd00c000c0010000cc000000c0000000c000c010c00
0000000600600000000bb000004444400babbb30dddddddddddddddddddddddd661111dd009949006ddddd160e111e001000ce110100ce101000ce100e111e00
0000006600600000000bb000004222409baa3b346dddddddddddddddddddddd66761166d094424907dd111d601111100100011a11000c1110100c11101111100
0000066000600000000bb000004222409333b3346dddddddddddddddddddddd66677666d94476649d776666d01a1a100010cc11e100011a1010011a101a1a100
0000606000600000000bb0000021112099999994666666666666666666666666066666d09471614901111110cc1e1cc001111111111cc11e011cc11ecc1e1cc0
0006060005550000000bb000002eee2044444422d11111111111eee11111111d000220009476664401efff100011100001111c1001111111cc11111101111100
066006000a5a0000000bb000004444400999994061aaa1c18191181111ffff1600092000944466490378f83000c1c1010cc00c1011c101c0c111c11000c1c000
0000600005050000000bb000004000400000000061bb11c18191e881e11f1f1600092000944244490b7fffb001c1c1100c0000c0110c010cc010c01100c0c000
00006000000bb000000bb0000940000000bb0b006dbbddcd8d9d888dedfff4d67dd22ddd294444920b7bdbb000001000001000000c0c0c000000000000000000
000600000abbb900000bb000094000000bbbbbb06666666666666666666666667d1921d6294244920bbb6bb00c001c000c100c000c1c1c000c000c000c000c00
00060000a9aa9a90000bb000094000000ab3bbb06111819111111111212144166d1111d622924922db7bbbbd0e111e000e111e00011c11000c111c000c111c00
00600000a0aa009000b733000992ee000baabb30615555551b11a111d1d144167dddddd6029999216d7777d60111110001111100011c110001111c000c111100
0060000090a9009000b733000442ee0003bb333061518191bbb1a1c1212199167776766602444421d666666d01a1a10001a1a100c11111c00111c10001c11100
060000009999999000333b00044222000bb333006d555555bbbdadcd212144161dbbbbd102444211dd11111dcc1e1cc0cc1e1cc000111000c11111c0c11111c0
000000004999494000bbbb00024444000b3bb3306666666666666666666666661dbbbbd1004444101d99191101111100011111000011100000cc1000001cc000
0000000004444400000bb000044004000bbbbb306dddddddddddddddddddddd676333366000111100111111000cc1000001cc00000c1c0000001100000110000
b944444444444444444444440044444000b3bb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
944444444444444444444444024444420b3333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
944444444444444444444444029999929bb333340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444222242440944444993b333140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94444444444444444444444400466640999999940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94444444444444444444444400461140444444220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94444444444444444444444400461640099999400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
42242444444444444444444400444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94444444444444440000000000409040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94444444444444440070e0a000409040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
499999994999999901b1819102407042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222220ddddddd02400042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b11100000000000000b0809009999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b22200000000000001b1819102222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0220000000000000ddddddd02444442000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb000bbbbbbbbbbb0000000009999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00200000000002005555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000001
000000001100000055555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d1000001
00200105551002005555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000001
00400001100004005555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000001
00400005511004005555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000001
0090155dd555090079555555555555790000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d1000001
00400001111009009955555555555599000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000001
00900055555007000955d55555dd5590000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070dd5ddddd09000940dd5ddddd0490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00701111111007000490111111100740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04900555555509400070005555500900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09405dddd5dd04900090155dd5550900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
97001111111100790040011111100400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9900555dd55500990020000010000200000000000000000000000000000000000000000000000000000000000000000000000000000000007777777777777777
0205dd5dddddd0200000010155100000000000000000000000000000000000000000000000000000000000000000000000000000000000007cccccc77cccccc7
0401111111111040002000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000c100000cc000000c
00000022222922222222222222292222220000000099999999999900000000005555555500000500555555551111111111111111111111111100000111111111
00000229999949999999999999994999922000000942222222222490000000005555555550550000555555551221212121212121212212210100000110000001
0000029444442444444444444444444449200000092000000000029000000000ddd5555500550055555555551222212222212222212222210100000110000001
0000029444442444444444444444444449200000092000000000029000000000ddd55d555500505555555555112dd2ddd2dddd2ddd2dd2110102222110000001
0000029444222242444444444422224449200000092000000000029000000000555555555555050055ddd555122dd22222222222222dd2210102222110000101
0000029444444444444444444444444449200000092000000000029007aaaa7055dd55555555555555ddd5551122221222222222222222110110222110000001
0000029222222222222222222222222229200000092000000000029009dddd9055dd55555555555555555555122d2222222222222122d2210100022110000001
0000029000000000000000000000000009200000092000000000029009655690555555555555555555555555112d2222222222222222d1111100000111111111
0000029000000040040000000000002209200000094222222222249029655692005055555555555555555000122d2222222222222222d2210000000000000000
0000029000000000000000004044999909200000099999999999999049666694000055555555555555555000111d2222222222222222d2110000000000000000
0000029000000040040000000022244409200000094444444444449029555592550555555555555555550550122d2222222222222222d2210000000000000000
0000029000000040040000000022244409200000094444444444449029555592550555555555555555000550112d2222222222222222d1110000000000000000
00000290000000900900000000000224092000000422444444222240299aa992000505555555555555550000122d2222222222222222d2217cccccc77cccccc7
0000029000000290090000000000244409200000094444444442449022222222500055555555555555500050112d2222222222222222d2117777777777777777
0000029000000290092000000000002209200000042222222222224022222222005555555555555555555000122d2222222222222222d221cccccccccccccccc
0000029000000290092000000000000009200000000000000000000000000000055505555555555500055500111d2222222222222222d2111111111111111111
0000029000000290092000002200000009200000404499999999440400000000555555555555555522222222122d2122222222222222d2211cccccc115000001
0000029000000290092000009999440409200000000222222222200000000000555555555555555522222222112d2212222222222222d111dc5555c1d5000001
0000024000000290090000004444220004200000000000000000000000000000555dd55555555555222222221222222222222222222222211c5555c115000001
0000299000000090090000004444220009920000000000000000000000000000555555555555050021122222122dd22222222222222dd2211c5555c115000001
0000029000000040040000004420000009200000000000000000000000000000dddd55555500505522222222112dd2dddddddddddd2dd2111ccccc7115020201
0000029000000040040000004422200009200000000000000000000000000000dddd55550055005522222122122222222222122222122221dc5555c1d5202021
00000290000000000000000022000000092000000000000000000000000000005555555550550000222222221221221212121212121212211cccccc115222221
00000290000000400400000000000000092000000000000000000000000000005555555500000500222222221111111111111111111111110000000000000000
00000249000000009994999999999999942000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000022000000002222922222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000007000000070000000000000000000000000000000000000000000000000000000000000000000000000000
00777000000000000000000000000000000000000007000000040000000000000000000000000000000000000000000000000000000000000000000000000000
07070707000000700777077707707770000000000007000000070000000000000000000000000000000000000000000000000000000000000000000000000000
070f0700070747000070007007407470777777770007000000070000000000000722227000000000000000000000000000000000000000000000000000000000
04777407000000700777007007707070000000000007000000047000000000000077770000000000000000000000000000000000000000000000000000000000
00707000000000000000000000000000000000000007000000070700000000000007700000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000007000000007777777777770000000000000000000000000000000000000000000000000000000000000000
00707000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000010101000000000000000000000000000000000000000000000000
0000000000000000000000000000000002020000000000000000000000000000000002020000000000000000000000000101010101010100000200000000000001010101010101000200020000000000010101010101010000020000000000000100010101000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b2b2b2b2b2b2b40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000b0b2b2b2b2b1b2b2b3b2b2b40000000000000000b0b2b3b400000000000000000000c0bbbcbcbcbcbdc4000000000000000000000000b0b2b2b3b2b40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b0c6c9c9c9c9c9c9c9c9c9c9c5b4000000000000b0c6b8c9c5b4000000000000000000c0cbccccdacccdc4000000000000000000000000c0bbbcbcbdc5b2d3c3b2b3b2b400000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000b0b1b2b2b3b2b2b2b40000000000c0c9c9b8c9c9b5b6c9c9bac9c9c40000000000b0c6bbbcbcbdc5b1b2b3b2d3c3b2b2b4c0dbdcdcdcdcddc4b0b2b2d3c3b2b2b3b2b40000d0cbccdacdc9cafffec8c9c9c400000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000b0c6bac9c9c9c9c9c9c5b400000000d0c9c9c9c9c9c4d0c9c9c9c9c9d40000000000d0c9cbdacccdc9c9d8c9cafffec8b8c4c0c9ba9293c9c9c4c0c9cafffec8c9c9c9c40000c0cbcccccdb5e3d6d5e3b6c9d400000000b0b2b3b2b2b2d3c3b2b2b2b2b2b40000b0b2b2b2b2b2d3c3b2b2b3b2b2b2b1b2b2b2b2b3b40000
00b0c6c9c9bac9c9c9c9d8c9c5b4000000c0c9c9b5e3e3e4e0e2e3b6c9c9c5d3c3b2b3b2c6c9cbcccccdc9b5e3e3e3d6d5b6c9c4e0e3b6a2a3b5e3e4c0d8b5d6d5b6c9c9c9d40000c0dbdcdcddc400000000c0c9c400000000d0c9c9c9c9cafffec8c9bbbcbdc40000c0daccdacdcafffec8d8c9c9b8c9c9c9c9c9c9c9c40000
00c0c9d8c9bbbcbcbcbdc9c9c9c4000000c0c9c9d4000000000000c0c9c9cafffec8c9c9c9bacbccdacdc9d40000000000c0c9c40000d1fdfdd20000c0c9c40000c0c9c9c9c40000e0e3e3e2e3e400000000d0c9c5b2b1b2b2c6c9b8b5e3e3d6d5e3b6cbdacdc40000c0ccccccb5e3d6d5e3e3e3b6c9bbbcbcbcbcbdd8d40000
00d0c9c9c9cbcccccccdc9c9c9c4000000c0c9c9c5b2b3b4b0b2b1c6c9c9b5d6d5e3e3e3b6c9cbcccccdc9c40000000000c0c9c40000000000000000c0c9c40000d0c9bac9c4000000000000000000000000c0bac9c9c9c9c9c9c9c9c40000000000c0dbdcddc40000c0ccccccc4000000000000c0c9cbccccdacccdc9c40000
00c0c9c9c9cbdacccccdc9c9c9d4000000c0c9c9c9c9c9c4c0c9c9c9c9c9c40000000000c0c9cbcccccdb8c40000000000c0bac5b2b1b2b2b2b3b2b2c6c9c40000c0c9c9c9c5b2b2b1b2b2b4000000000000c0c9c9c9c9c9c9d8c9b5e40000000000c0c9c9bac40000c0daccccc4000000000000c0c9cbdacccccccdc9c40000
00c0c9c9c9cbccccdacdc9d8c9c4000000c0c9d8c9c9c9c5c6c9b8c9c9c9c40000000000d0c9cbdacccdc9d40000000000c0c9d8c9c9c9c9c9c9bbbcbcbdc40000c0c9c9c9c9c9c9c9c9c9c4000000000000c0c9c9c9c9c9c9c9c9c4000000000000c0d8c9c9c40000e0e3b6dcc4000000000000d0c9cbccccccdacdc9c40000
00d0c9c9c9dbdcdcdcddc9c9c9c4000000e0b6c99293c9c9c9c9c9c9c9b5e40000000000c0c9dbdcdcddc9c40000000000c0c9c9c9c9c9c9c9c9dbdcdcddc40000d0c9c9b8c9c9c9d8c9c9d4000000000000d0c9c9b8c9c9c9c9c9d4000000000000c0d9b5e3e400000000c0d9c4000000000000c0c9dbdcdcdcdcddc9d40000
00d1d9d9c9c9c9c9c9c9c9d9d9d200000000e0b6a2a3b5e3e3e3e2e3e3e4000000000000e0e3e2e3e3e3e3e40000000000e0e3e3e3e3e3e2e3e3e3e3e3e3e40000c0c9c9c9c9c9c9c9c9c9c4000000000000c0c9c9c9c9c9c9c9c9c4000000000000d1fdd2000000000000d1fdd2000000000000c0c9bac9c9c9c9c9c9c40000
00000000d9d9d9d9d9d9d90000000000000000d1fdfdd2000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0e3e3e3e2e3e3b6d9b5e4000000000000e0e3e3e3e2e3e3e3e3e4000000000000000000000000000000000000000000000000e0e3e2b6c9b8b5e3e3e40000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d1fdd20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0d9d9c40000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d1fdfdd20000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fc0000000000000000fc00000000000000000000c1fcfcc20000000000
00000000000000000000000000000000000000c1fcfcc200000000000000000000b0b2b1b2b2b3b2b2b2b2b2b2b3b40000000000000000000000000000000000000000000000000000fc00000000000000000000b0b2b1b2b2b2b2b40000000000b0b2b9b2b4b0b1b2b4b0b2b9b3b40000000000000000c0b9b9c40000000000
0000b0b1b2b2b3b2b2b2b2b2b3b40000000000c09091c400000000000000000000c0c9c9c9c9c9c9c9c9c9bac9c9c4000000000000000000000000000000000000000000b0b2b1b2b2b9b3b40000000000000000c0b8c9c9c9c9c9c40000000000c0c9c9c9c4c0c9c9c4c0c9c9c9c40000000000000000c0c9c9c40000000000
0000c0c9c9c9c9c9c9c9bac9c9c400000000b0c6a0a1c5b400b0b2b1b2b3b40000c0c9c9b5e3e3e3e3e3b6c9b8c9c400000000000000c1fcfcc200000000000000000000c0c9c9c9c9c9c9c40000000000000000d0c9bbbcbcbdc9d40000000000c0c9c9bad4c0c9c9c4c0c9c9c9d40000000000000000c0c9c9d40000000000
0000c0c9c9c9c9c9c9c9c9c9c9c400000000d0bbbcbcbdc400c0b8c9c9c9d40000c0c9c9c5b2b2b2b2b4e0b6c9b5e400000000000000c09091c400000000000000000000c0bbbcbdc9c9bad40000000000000000c0c9cbcccccdc9c40000000000c0c9c9c9c4c0c9b8c4d0c9c9c9c40000000000000000c0c9c9c40000000000
0000d0c9c9c9b5e3e3b6c9c9c9d400000000c0cbccdacdc400c0c9c9c9c9c40000c0c9bac9c9bbbcbdc400c0c9c400000000b0b1b2b2c6a0a1c5b1b2b3b4000000000000d0cbcccdb5e3e3e40000000000000000c0c9cbcccccdc9c40000000000d0c9c9c9c4c0c9c9c4c0c9d8c9c40000000000000000d0c9c9c40000000000
0000c0c9c9c9c40000c0c9c9c9c400000000c0cbcccccdc400c0c9c9c9c9c5d3c3c6d8c9b5b6cbcccdc4b0c6c9c5b4000000c0bbbcbcbcbcbcbcbcbcbdc4000000000000c0cbcccdc40000000000000000000000c0c9cbcccccdc9c40000000000c0c9c9c9c4c0c9c9c4c0c9c9c9c40000000000000000c0c9c9c40000000000
0000c0c9b8c9c40000c0c9c9c9c400000000d0cbcccccdd400d0c9c9c9bacafffec8c9c9c4c0cbdacdc4c0c9c9c9c4000000d0cbccccccccdacccccccdd4000000000000c0cbcccdc4b0b2b1b2b2d300000000c3c6c9cbccdacdbad40000000000c0c9b8c9c5c6c9c9c5c6c9c9c9c40000000000000000c0bac9c40000000000
0000c0c9c9c9c40000c0c9c9c9c400000000c0cbcccccdc400c0c9c9c9c9b5d6d5e3e2e3e4d0cbcccdc4d0d8c9c9d4000000d0cbcccccccccccccccccdc4000000000000c0dbdcddc4c0c9c9bacaff00000000fec8c9cbcccccdc9c5d3000000c3c6c9c9c9c9c9c9c9c9c9c9c9c9c40000000000000000c0c9c9c40000000000
0000d0c9c9c9c5b2b4c0c9c9c9c5d30000c3c6cbcccccdc400d0c9c9d8c9d400000000b0b1c6cbcccdc4c0c9c9c9c5d300c3c6cbcccccccccccccccccdc5d300c3b2b3b2c6c9c9c9c4c0c9b5e3e3d600000000d5b6c9dbdcdcddc9caff000000fec8c9c9c9c9c9c9bac9c9c9c9c9d4000000b0b2555657c6c9c9c40000000000
0000c0bbbcbcbcbdd4c0d8c9c9caff0000fec8cbdacccdc400c0c9c9c9c9c400000000c0c9c9dbdcddc4c0c9c9c9caff00fec8cbcccccccccccccccccdcaff00fec8b8c9c9c9c9c9c5c6c9c40000000000000000c0c9c9c9c9c9c9b5d6000000d5b6c9c9c9c9c9c9c9c9c9c9c9c9c4000000c0ba656667c9c9b8d40000000000
0000c0dbdcdcdcddc4e0e3e3e2e3d60000d5b6dbdcdcddd400c0c9c9c9c9c400000000e0e3e2e3e3e3e4e0e3e2e3e3d600d5b6dbdcdcdcdcdcdcdcdcddb5d600d5e3e3e3b6c9d8c9c9c9c9c40000000000000000e0e3e3e3e3e2e3e40000000000e0e3e3e2e3e3e3e3e2e3e3e3e3e4000000d0c9c9c9c9c9c9c9c40000000000
0000e0e3e2e3e3e3e4000000000000000000e0e3e2e3e3e400e0e2e3e3e3e400000000000000000000000000000000000000e0e3e3e3e3e3e3e2e3e3e3e4000000000000e0e2e3e3e3e2e3e40000000000000000000000000000000000000000000000000000000000000000000000000000c0c9c9c9d8c9c9c9c40000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0e3e2e3e3e3e3e3e40000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
012000201121511205112151320513205112051120511205132151321511215112051120513205132051120511215112051121511205132051320511205112051321511215112151120511205132151320511215
011000200003300000000000000000053000000000000000000330000000000000000005300000000000000000033000000000000000000530000000000000000003300000000000000000053000000000000000
012000202453224532245222451224502245022450224502255322553225532255222552225512255022450024532245322452224512245022450224502245022753227532275322752227522275122450024500
01100020000333c605186153c6050005300000000003c605000330000018615000000005300000246151861500033000001861500000000530000000000000000003300000186150000000053000002461518615
01200000000520c05218042000420c032000220c01201002010520d05219042010420d032010220d01200002000520c05218042000420c032000220c01203002030520f0521b042030420f032030220f01201002
012000003070230702307123071230712307123071230712307223072230722307223073230732307323073230732307323074230742307423074230742307323073230722307223071230712307123070200002
0120002010502105521054210532105021055210542105320f5620f5020f5620f5020f5020f5520f5420f5320e5620e5020e5420e5320e5020e5520e5420e5320c5020c5320c5620c5020d5020d5320d5220d512
011800200514305143111031110305143051433061511103071430714313103131030714307143306051310303143031430f1030f1030314303143306150f1030a1430a143161031610307143071433061530615
0118002005072050620504205022050150500005000050000507105061050150700007071070610701507000030720306205042070220001500000000000a0000a0710a0610a015070000707107061070150a000
01300020117100e7110d7110a71108711077110771106711047110471104711037110371103711037210372103721037210372103731037310473105731067310773108721097210b7210d7110f7111171111711
01160000184101d430184201d440184301d450184301d45018400224501a430224401b420224301b41020410184101d430184201d440184301d450184301d45000400224501a430224401b420224301b40000400
0116000000000181101d110181101d110181101d110181101d11018100221101a110221101b110221101b11020110181101d110181101d110181101d110181101d11000100221101a110221101b110221501b400
0116000011410114211143111451114101142111431114510e4100e4210e4310e4311641016421164311645111410114211143111451114101142111431114510e4100e4210e4310e43116450164311642116411
0116000000553005030c6750050300553005030c6750050300553005030c6750050300553005030c6750c67500553005030c6750050300553005030c6750050300553005030c6750050300503005030c6750c675
01160000304103041130421304213043130431304313043130431304313a4303a4313a4313a431354303543133430334313843038431304303043129430294313041130411304213043124431244212442124411
01160000304103041130421304213043130431304313043130431304313a4303a4313a4313a4313543135431334313343138431384313043130431294312943101416074160e426164261c436234362b44634446
001600003f4703e46139451334512d45128441224411f4411a4411743114431114310f4310d4310b4210a4210942107421054210442103411024110141101411014010140101401014010b400084000540002400
011800000000229014290122901229012290152900229002290022901429012290152b0022b0142b0122b0152b002270142701227012270122701524002240022e0022e0142e0122e0152b0022b0142b0122b015
0002000003600096100b63008640066100e630136500a660056300262001600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 01 04 43 44
00 01 04 43 44
00 01 04 02 44
00 01 04 02 44
00 03 04 43 44
00 03 04 43 44
00 03 04 05 44
02 03 04 43 44
03 11 07 08 09
00 41 42 43 0d
01 41 42 0c 0d
00 0a 0b 0c 0d
00 0a 0b 0c 0d
00 0a 0c 0e 0d
00 0a 0c 0f 0d
00 0a 0c 10 0d
02 41 42 0c 0d
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
