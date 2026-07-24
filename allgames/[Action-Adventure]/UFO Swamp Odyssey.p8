pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--ufo swamp odyssey
--by paranoid cactus

palette={
-- screen pal
0,128,2,3,4,133,134,15,8,137,9,139,12,5,131,13, -- blue palette: 0,129,2,3,4,1,134,15,8,137,9,139,12,5,131,13,
-- swamp greens
30,14,14,3,3,14,11,7,3,11,7,11,11,3,14,3,
-- gun pals
16,1,1,3,4,5,6,7,5,5,13,11,12,13,14,15,
16,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
16,1,14,3,4,5,6,7,3,11,11,11,12,13,14,15,
16,1,14,3,4,5,6,7,15,12,12,11,12,13,14,15,
16,1,2,3,4,5,6,11,8,9,10,11,3,13,14,14}

title={126,0,127,126,124,125,126,124,127,126,0,127,126,125,0,126,0,127,123,124,125,123,0,0,123,124,125}
titlesprs={{88,40,4,5},{92,40,7,7},{99,40,6,7},{105,40,7,8},{88,48,5,9},{93,48,5,6},{98,48,5,6},{103,48,5,6},{108,48,4,5},{16,16,8},{24,16,5},{29,16,5},{34,16,6},{40,16,6},{24,8,6}}
titlelo={1,2,3,4,5,6,7,8,1,1,9,8}
titlehi={10,11,12,12,0,13,14,15,11}

psprs={
-- 1 player sprites
{x=0,y=0,w=12,h=6},{x=12,y=0,w=4,h=5},{x=16,y=0,w=3,h=2},{x=19,y=0,w=3,h=2},{x=22,y=0,w=2,h=2},{x=16,y=3,w=3,h=2},{x=16,y=2,w=3,h=3},{x=16,y=4,w=3,h=1},{x=16,y=5,w=4,h=3},{x=19,y=2,w=2,h=3},{x=21,y=2,w=3,h=4},
-- 12 friend sprites
{x=45,y=0,w=7,h=5},{x=48,y=5,w=9,h=5},{x=52,y=0,w=7,h=5},{x=59,y=0,w=7,h=5},{x=57,y=5,w=7,h=5},{x=64,y=5,w=7,h=5},
-- 18 eyeball sprites
{x=32,y=0,w=8,h=8},{x=40,y=0,w=5,h=5},
-- 20 coin
{x=24,y=0,w=4,h=4},{x=28,y=0,w=4,h=4},{x=24,y=4,w=2,h=4},
-- 23 canister, 24 laser bolt, 25 goop
{x=12,y=0,w=4,h=6},{x=0,y=8,w=8,h=2},{x=26,y=4,x=4,h=4},
-- 26 floor button
{x=0,y=14,w=8,h=6},
-- 27 green ball
{x=26,y=4,w=4,h=4},
-- 28 portal stand
{x=9,y=10,w=6,h=4},
-- 29 core
{x=48,y=10,w=6,h=4},{x=54,y=10,w=6,h=4},{x=60,y=10,w=6,h=4},{x=66,y=10,w=6,h=4},{x=66,y=0,w=6,h=4},
-- 34 zapper
{x=118,y=40,w=10,h=7},{x=116,y=41,w=2,h=4},{x=116,y=48,w=12,h=8}
}
panms={{
-- 1 player idle
{{s=1,x=-7,y=-8},{s=2,x=0,y=-13,p=1},{s=6,x=-4,y=-2},{s=6,x=0,y=-2},{s=-7,x=4,y=-3}}},
-- 2 player walk
{{{s=1,x=-7,y=-8},{s=2,x=0,y=-13,p=1},{s=3,x=-5,y=-2},{s=4,x=1,y=-2},{s=-7,x=2,y=-3}},
{{s=1,x=-7,y=-8},{s=2,x=0,y=-13,p=1},{s=6,x=-5,y=-2},{s=5,x=2,y=-2},{s=-7,x=2,y=-3}},
{{s=1,x=-7,y=-9},{s=2,x=0,y=-14,p=1},{s=7,x=-4,y=-3},{s=6,x=0,y=-3},{s=-7,x=3,y=-4}},
{{s=1,x=-7,y=-9},{s=2,x=0,y=-14,p=1},{s=7,x=-3,y=-3},{s=6,x=-1,y=-3},{s=-7,x=4,y=-4}},
{{s=1,x=-7,y=-8},{s=2,x=0,y=-13,p=1},{s=6,x=-1,y=-2},{s=8,x=-2,y=-2},{s=-7,x=4,y=-4}},
{{s=1,x=-7,y=-8},{s=2,x=0,y=-13,p=1},{s=6,x=-2,y=-2},{s=-7,x=4,y=-4}},
{{s=1,x=-7,y=-9},{s=2,x=0,y=-14,p=1},{s=6,x=-3,y=-3},{s=7,x=-1,y=-3},{s=-7,x=4,y=-4}},
{{s=1,x=-7,y=-9},{s=2,x=0,y=-14,p=1},{s=6,x=-4,y=-3},{s=7,x=0,y=-3},{s=-7,x=3,y=-4}}},
-- 3 player jump
{{{s=1,x=-7,y=-8},{s=2,x=0,y=-13,p=1},{s=6,x=-3,y=-2},{s=11,x=1,y=-2},{s=-7,x=4,y=-3}},
{{s=1,x=-7,y=-8},{s=2,x=0,y=-13,p=1},{s=3,x=-4,y=-2},{s=10,x=2,y=-2},{s=-7,x=4,y=-4}},
{{s=1,x=-7,y=-8},{s=2,x=0,y=-13,p=1},{s=9,x=-5,y=-2},{s=4,x=1,y=-2},{s=-7,x=4,y=-4}}},
-- 4 eyeball
{{{s=18,x=-4,y=-8}},{{s=18,x=-4,y=-8},{s=19,x=-4,y=-6}}},
-- 5 friend expressions 
{{{s=12,x=-4,y=-11},{s=14,x=-4,y=-7},{s=6,x=-4,y=-2,p=1},{s=6,x=0,y=-2,p=1}}},
{{{s=13,x=-5,y=-12},{s=15,x=-4,y=-7},{s=6,x=-4,y=-2,p=1},{s=6,x=0,y=-2,p=1}}},
{{{s=12,x=-4,y=-11},{s=16,x=-4,y=-7},{s=6,x=-4,y=-2,p=1},{s=6,x=0,y=-2,p=1}}},
{{{s=12,x=-4,y=-12},{s=17,x=-4,y=-7},{s=6,x=-4,y=-2,p=1},{s=6,x=0,y=-2,p=1}}},
-- 9 friend walk
{{{s=12,x=-4,y=-11},{s=14,x=-4,y=-7},{s=3,x=-5,y=-2,p=1},{s=4,x=1,y=-2,p=1}},
{{s=12,x=-4,y=-11},{s=14,x=-4,y=-7},{s=6,x=-5,y=-2,p=1},{s=5,x=2,y=-2,p=1}},
{{s=12,x=-4,y=-12},{s=14,x=-4,y=-8},{s=7,x=-4,y=-3,p=1},{s=6,x=0,y=-3,p=1}},
{{s=12,x=-4,y=-12},{s=14,x=-4,y=-8},{s=7,x=-3,y=-3,p=1},{s=6,x=-1,y=-3,p=1}},
{{s=12,x=-4,y=-11},{s=14,x=-4,y=-7},{s=6,x=-1,y=-2,p=1},{s=8,x=-2,y=-2,p=1}},
{{s=12,x=-4,y=-11},{s=14,x=-4,y=-7},{s=6,x=-2,y=-2,p=1}},
{{s=12,x=-4,y=-12},{s=14,x=-4,y=-8},{s=6,x=-3,y=-3,p=1},{s=7,x=-1,y=-3,p=1}},
{{s=12,x=-4,y=-12},{s=14,x=-4,y=-8},{s=6,x=-4,y=-3,p=1},{s=7,x=0,y=-3,p=1}}},
-- 10 coin
{{{s=20,x=-2,y=-4}},{{s=21,x=-2,y=-4,f=1}},{{s=22,x=-1,y=-4}},{{s=21,x=-2,y=-4}}},
-- 11 fuel canister
{{{s=23,x=-2,y=-6,p=1}}},
-- 12 button
{{{s=26,x=0,y=-6}}},
-- 13 green ball
{{{s=27,x=-2,y=-8}}},
-- 14 portal stand
{{{s=28,x=-3,y=-3}}},
-- 15 core
{{{s=29,x=-3,y=-6}},{{s=30,x=-3,y=-6}},{{s=31,x=-3,y=-6}},{{s=32,x=-3,y=-6}},{{s=33,x=-3,y=-6}}},
-- 16 zapper
{{{s=34,x=-5,y=-6,f=1},{s=35,x=-7,y=-5,f=1}},{{s=34,x=-5,y=-6,f=1},{s=35,x=-7,y=-4,f=1}}},{{{s=36,x=-4,y=-6,f=1}}}
}

bgstr="000b1811100a0000af18111a01b50000000a111a0019800011105b19800007111fed0000000079111800000a5100d1a600010a00000b51fe000d2111a501dfe0000f211110b50a00791e1116a198000000ab1116c01de0001111113fe00a001110000000000a0d11111100b5710a01c10a019800000f13000a00fde1b1b100a00000fd11100198000e21111571ee00000b5f1118e030000a1113d0e000a6c0111a00000000aa0011111100f101b50211a6c1dea000ab1e00a6c000b1f1f1a06a000000111113fe00a00d1111130000000f79111e00000005111e00000071e0111ca0000000b50a111efd0a01c1980fe171e1006c0079100b55e0a0f211a18018000a00111df00000a0a011113e000000000d1110a0000a071110000000021111106c000000f5b511100005a113de00a10211a01ea00d1c0f71a04a00d141113e0a06a0111000000b5aa0111de000000000a011106c00b5001110a000000fdf11198e000000a1f7111000a181de00a0b1a0e16c19800a1e0a016c6c0a0171ede006c16a11100000004b501110000000000b5011113e00f6a01119800a000000111dea00000071c011100071e1a0004af16c018e1fe0b51a06013e4e05b1010000079118111000000a4f6c111000000000af6c111fe0000180111d0a06c000001110a600000002111110a00211ca0b57914e02113000f716c1a1ea40a4f101000000e2111110a000045a79111a0000000b50601110000002111110a6c10a0000111046a0000000df111b5a0fe1e6cf79118a0fd1e0000018e181056c46c1130a00000f0d111aa000b5180e1116c000000f791c111000c000d2111071e1980000111a71ca00000000111f660a0113e00de1e6c001000a002111e1918e71e13e06a0000000111b5000071e60111800a000000d21111000e0000f11111113ee000011180198000000ab11101806c1d0000001b1e0a100b50afed101fee00211e0a1800000ab111f5a00002111111e0b50a00000f2111c00000000111113de000000111113fe00000b5f11113e91e10a000002110ab1a0f7b50a011300000fe100b1e0a00079111b180000f2111110af6a6c00000f111e00000000111dfe000000001113d00000000079111d00d211b5a000afd1b5f160a0f606c1de0a0000011113004a000d11113e000000ed11106c184e00000011100a0000a011100000000000111e0a00000000021110000fd1f66c0b500198018a6c07911100b5000a01dfde00680000111d00a0000000111050198000000b1110b5000b50111000000000a01110a6ca0000000f1110000001b18eaf6c01de01e71e00ede10af10007910000001ea0001110a050a0000a1111113de00000a0111a07000f1a11100000000b5a111071e6c000000011100000a113e0791e010a0111300000a107910a00e1000000"
fgstr="000003b77b30b300bb77777b0b3bbb77e7e70bbb3bb77b77b337bb3bbbbb00003bbe7373000003bb7b70000000000000000077b3000000077777b00000377e7e730003bb77b77b30b3b3bbbbbb3b003ee737b300000be7e730000000bbb30000"

story={
{{"scavengers got you too huh?",2},{"we're TRAPPED here!",1},{"it's that damned EMP CANNON",4},{"they snare space ships",1},{"then strip them for parts",1},{"they love anything mechanical",4},{"OH NO! you're mechanical!",2},{"they'll want YOUR parts too!",4},{"you're DOOMED!",2},{"unless...",4},{"you disable their EMP CANNON",1},{"HA HA! good luck with that",3}},
{{"ahoy there little robot",3},{"whatcha up to round here?",1},{"oh, tryna ESCAPE are ya?",2},{"i might be able to help",3},{"ya know that EMP CANNON?",4},{"ya gotta take out it's core",1},{"fight fire with fire",3},{"use this EMP FUEL",4},{"it's good against eyebots too",3,2}},
{{"whoa, i'm so CONFUSED",4},{"i went through some PORTALS",1},{"now i don't know where i am!",2},{"i need to rest for a bit",1},{"if you wanna get out...",4},{"you're gonna need this",3},{"it's GRAPPLE FUEL",4},{"just look out for BLUE HOOKS",1},{"time for some HIGH FLYIN' FUN",3,4}},
{{"ooh, someone finally came!",3},{"i've been stuck down here",2},{"there's a PORTAL right there",4},{"and i've got some PORTAL FUEL",3},{"but i can't use it",2},{"you've got that handy zapper",4},{"why don't you give it a go",3,3}},
{{"you did it!",2},{"CONGRATULATIONS!",3},{"i guess you'll be leaving now",4},{"if only you had a bigger ship",1},{"but maybe we'll meet again",4},{"farewell for now little robot",3,-1}}
}

ptypes={{a=10,pn="score",pv=10,snd=32},{a=11,pn="guns",pv=1,snd=36,msg="emp zapper",pali=1},{a=11,pn="guns",pv=1,snd=36,msg="portal zapper",pali=2},{a=11,pn="guns",pv=1,snd=36,msg="grapple zapper",pali=3}}

function _init()
	for i=1,#palette do
		poke(0x42ff+i,palette[i])
	end
	poke(0x5f2e,1)
	for i=1,#bgstr do
		local v=tonum("0x"..sub(bgstr,i,i))
		poke(0x4dff+i,v==0 and 0 or v+48)
	end
	for i=1,#fgstr,2 do
		poke(0xa3a+flr((i-1)/12)*64+flr(((i-1)%12)/2),tonum("0x"..sub(fgstr,i+1,i+1)..sub(fgstr,i,i)))
	end
	memcpy(0x5600,0x1800,2048)
	
	new_game()
	if peek(0x4371)==254 then
		poke(0x4371,0)
		conditionone=true
		music(11)
	else
		music(13)
	end
end

function new_game()
	gamemode=0
	enemies,friends,pickups,particles,hooks,buttons,portals,msglog,sndcue,sndtm,jbtn,sbtn,slvls,zapt,zapdest={},{},{},{},{},{},{},{},{},0,4,5,{228.5,364.5,484.8},0,nil
	pl,camx,camy,camyo,camyd,camtime,slvlo,slvld,slvlt,stm,msgofs,gtime,popup,chat,active,canmove,drawlist,flying,camxp1,camxp2,scrollm,ufoy,ufobob,cannonzapt=new_player(532,96),469,-120,-120,24,0,108.5,108.5,1,0,0,0,nil,nil,btn,btnp,{particles,buttons,enemies,friends,pickups,portals},0,0,0,1,0,0,0
	local storyi=1
	for y=0,63 do
		for x=0,127 do
			local m=mget(x,y)
			if fget(m,0) then
				if m==3 then
					add(pickups,{x=x*8+4,y=y*8+6,ptype=ptypes[1],t=((x%8)/4+(y%32)/16)%2,f=1,
					update=function(p)
						local fc=#panms[p.ptype.a]
						p.t=(p.t+0.02)%2
						p.f=min(flr((p.t%0.5)*2*fc)+1,fc)
					end,
					draw=function(p) draw_sp(p.ptype.a,p.f,p.x,p.y+flr(sin(p.t)*1.5),4,false,p.ptype.pali) end})
				elseif m==4 then
					add(enemies,new_eyeball(x*8+3,y*8+8))
				elseif m==6 then
					if storyi<5 then
						add(friends,new_friend(x*8+3,y*8+8,storyi,5,9))
						storyi+=1
					else
						add(friends,new_friend(x*8+3,y*8+8,storyi,17,16,true))
					end
				elseif m==32 then
					add(buttons,{x=x*8,y=y*8,l=del(slvls,slvls[1]),pt=0,pf=2,
						draw=function(b)
							draw_sp(12,1,b.x,b.y+4,10)
							if b.y+13<sy and b.pf<40 then
								b.pt=(b.pt+1)%b.pf
								if b.pt<1 then
									new_particle(b.x+16,b.y+12.5,rnd()*0.4,0,rnd()<0.5 and 3 or 14,60,0.04,true)
									if b.pf>2 then
										b.pf+=b.pf*0.75
									end
								end
							end
						end})
				elseif m==33 then
					powercore={x=x*8+4,y=y*8+8,f=1,t=0}
				elseif m>=49 and m<=63 then
					local v=m-48
					local px=mget(x-1,y)==20 and x-1 or x+1
					portals[v]={x=px*8+4,y=y*8+6,d=v+(v%2)*2-1,draw=function(p) draw_sp(13,1,p.x,p.y+sin(stm),4) end}
				elseif m==75 then
					add(hooks,{x=x*8+4,y=y*8+8})
				end
			end
		end
	end
end

function _update60()
	jbtnd,sbtnd,gtime,trigger,tpressed,grapple,drain=false,false,(gtime+0.025)%1,active(1,1),active(2,1),canmove(4,1),canmove(5,1)
	if btn(jbtn) then
		if not jbtnlock then
			jbtnd=true
		end
	else
		jbtnlock=false
	end
	if btn(sbtn) then
		if not sbtnlock then
			sbtnd=true
		end
	else
		sbtnlock=false
	end
	if chat then
		local advance=chati==0
		if jbtnd and not jbtnlock then
			jbtnd,jbtnlock,advance=false,true,true
		end
		if sbtnd and not sbtnlock then
			sbtnd,sbtnlock,advance=false,true,true
		end
		
		if advance then
			if chati>0 and chat[chati][3] then
				if chat[chati][3]==-1 then
					poke(0x4371,254)
					run()
				end
				pl:give({ptype=ptypes[chat[chati][3]]})
			end
			chati+=1
			if chati>#chat then
				chat=nil
			else
				local ei=chat[chati][2]
				chatf:setanim(ei)
				sfx(38+ei,3)
				if ei==2 then
					for i=0,4 do
						local sv=sin(i/8)*-2.5
						new_particle(chatf.x-4.5+i*2,chatf.y-12-sv,(i-2)*0.075,-0.2,12,15,0,false)
					end
				end
			end
		end
	end
	
	if popup then
		popup.t-=1
		if popup.t<=0 then
			popup=nil
		end
	end
	
	slvlt=min(slvlt+0.005,1)
	slvl=smoothlerp(slvlo,slvld,slvlt)
	stm=(stm+0.0075)%2
	sy=slvl+sin(stm)*2
	
	update_table(particles)
	
	if powercore then
		powercore.t=(powercore.t+0.04)%1
		powercore.f=flr(powercore.t*5)+1
	end
	
	if gamemode==0 then
		camxp1,camxp2=(camxp1-0.33*scrollm)%176,(camxp2-0.5*scrollm)%336
		
		if transtime then
			if transtime==300 then
				cannonzapt=14
			end
			if transtime==150 then
				music(10,0,3)
			end
			transtime-=1
			if transtime>99 then
				scrollm-=0.005
				if scrollm<0.1 then
					scrollm=0
				end
				ufoy-=(transtime-300)/100
			end
			if cannonzapt>0 and cannonzapt%2==0 then
				zapoffsets={{0,0}}
				for i=1,8 do
					add(zapoffsets,{rnd(8)-4,rnd(8)-4})
				end
				zapoffsets[10]={0,0}
			end
			cannonzapt=max(cannonzapt-1,0)
			if transtime==0 then
				gamemode=1
			end
		else
			ufobob=(ufobob+0.005)%2
			if jbtnd or sbtnd then
				transtime=300
				music(17)
				sfx(30,3)
				local uy=-60+ufoy+sin(ufobob)*3.5
				for i=0,32 do
					new_particle(camx+52,uy,rnd(2)-1,rnd(2)-1,8,90+flr(rnd(60)),0.01,true)
					new_particle(camx+52,uy,rnd()-0.5,rnd()-0.75,9,120+flr(rnd(90)),0.01,true)
				end
			end
		end
	elseif gamemode==1 then
		if trigger and tpressed then
			if grapple then
				pl.guns,pl.gun=3,3
			end
			if drain then
				for i=1,#buttons do
					local b=buttons[i]
					if b.pf==2 then
						slvlo,slvld,slvlt,b.y,b.pf=slvl,b.l,0,b.y+2,3
						sfx(43)
						break
					end
				end
			end
		end
		for m in all(msglog) do
			m.y-=0.25
			m.t-=1
			if m.t==0 then
				del(msglog,m)
			end
		end
		update_table(pickups)
		update_table(enemies)
		if camtime==1 then
			update_table(friends)
			pl:update()
		end
		sndtm=max(sndtm-1,0)
		if #sndcue>0 and sndtm==0 then
			local snd=del(sndcue,sndcue[1])
			sfx(snd.snd,3)
			if snd.msg then
				snd.msg.y=flr(snd.msg.y-msgofs*7)
				msgofs=(msgofs+1)%3
				add(msglog,snd.msg)
			end
			sndtm=8
		end
		if camtime<1 then
			camtime=min(camtime+0.0075,1)
			camy=smoothlerp(camyo,camyd,camtime)
		else
			camx,camy=mid(0,896,flr(pl.x-62.5)),flr(pl.y-71.5)
		end
	end
end

function update_table(list)
	for i in all(list) do
		i:update()
	end
end

function _draw()
	cls(5)
	camera(camx,camy)
	memcpy(0x1800,0x4e00,2048)
	local layerx,layery=flr(camx*0.66+0.5)+camxp1,flr(camy*0.75+0.5)
	for x=-1,2 do
		map(106,48,layerx+x*176,layery-128,22,16)
		map(84,48,layerx+x*176,layery,22,16)
		map(106,48,layerx+x*176,layery+128,22,16)
	end
	pal(1,0)
	layerx=camx/2+camxp2
	for x=-1,1 do
		for y=0,1 do
			map(42,48,layerx+336*x,camy/2-128+y*256,42,16)
			map(0,48,layerx+336*x,camy/2+y*256,42,16)
		end
	end
	pal()
	if zapt>0 and powercore and zapdest==powercore then
		if zapt<6 then
			circfill(powercore.x-1,powercore.y-5,6*zapt,8)
			circfill(powercore.x-1,powercore.y-5,5*zapt,9)
			circfill(powercore.x-1,powercore.y-5,4*zapt,10)
		else
			if zapt==7 then
				sfx(30)
			end
			local s=sin(zapt/14)
			circfill(powercore.x-1,powercore.y-5,4+s*4,8)
			circfill(powercore.x-1,powercore.y-5,3+s*3,9)
		end
	end
	memcpy(0x1800,0x5600,2048)
	map(0,0,0,0,128,64,30)
	memcpy(0x5f00,0x4310,16)
	rectfill(0,sy,1024,576,14)
	map(0,sy/8+1,0,flr(sy/8)*8+8,128,64,30)
	clip(0,sy-camy,128,8)
	map(0,sy/8,0,flr(sy/8)*8,128,1,30)
	clip()
	pal()
	for l in all(drawlist) do
		for i in all(l) do
			i:draw()
		end
	end
	pl:draw()
	if powercore then
		draw_sp(15,powercore.f,powercore.x,powercore.y,4)
	end
	for m in all(msglog) do
		printc(m.txt,m.x,m.y,10,0)
	end
	if transtime and transtime<150 and camtime<1 then
		local x=camx+25
		for i=1,#title do
			local y=-77+flr((i-1)/9)*8
			if title[i]~=0 then
				spr(title[i],x,y)
			end
			x+=8
			if i%9==0 then
				x=camx+25
			elseif i%3==0 then
				x+=2
			end
		end
		x=camx+26
		for i=1,#titlelo do
			local sp=titlesprs[titlelo[i]]
			sspr(sp[1],sp[2],sp[3],8,x,-49)
			x+=sp[4]
		end
	end
	camera()
	if popup then
		local l=#popup.txt*2+20
		rectfill(59-l,105,69+l,117,1)
		rectfill(58-l,106,70+l,116,1)
		draw_sp(popup.anm,1,65-l,114,8,false,popup.pali,true)
		print("you got",73-l,109,6)
		print(popup.txt,105-l,109,8)
	end
	if chat and chati~=0 then
		local str=chat[chati][1]
		local l=#str*2
		rectfill(59-l,33,68+l,49,7)
		rectfill(58-l,34,69+l,48,7)
		sspr(9,6,7,4,chatf.x-camx-4,50)
		for i=1,#str do
			local c=sub(str,i,i)
			local ordc,y,col=ord(c),39,0
			if ordc>64 and ordc<91 then
				c,y,col=chr(ordc+32),39.5+sin(gtime+i*0.125)*1.5,15
			end
			print(c,60-l+i*4,y,col)
		end
		sspr(0,6,9,7,59,47)
	end
	if gamemode==0 then
		local uy=ufoy+sin(ufobob)*3.5
		if cannonzapt>0 then
			if cannonzapt>9 then
				local s=cannonzapt-9
				circfill(52,67+uy,6*s,8)
				circfill(52,67+uy,5*s,9)
				circfill(52,67+uy,4*s,10)
			end
			draw_zap(-1,128,52,67+uy,zapoffsets,8,10)
		end
		sspr(104,0,16,8,55,46+uy)
		sspr(96,8,32,16,47,54+uy)
		sspr(4,0,6,6,60,51+uy,6,6,true)
		-- title screen
		if not transtime then
			if conditionone then
				local x=36
				for i=1,#titlehi do
					if titlehi[i]==0 then
						x+=4
					else
						local sp=titlesprs[titlehi[i]]
						sspr(sp[1],sp[2],sp[3],8,x,14)
						x+=sp[3]+1
					end
				end
			end		
			printc("press    to start",64,112,7,0)
			sspr(1,7,7,6,54,112)
		end
	else
		-- gun ui
		if pl.guns>1 and not (popup and popup.t>240 and popup.t%16>7) then
			for i=1,pl.guns do
				rectfill(1,123-i*8,8,130-i*8,pl.gun==i and 5 or 1)
				draw_sp(ptypes[i+1].a,1,5,130-i*8,4,false,ptypes[i+1].pali,true)
				sspr(40,8,8,4,1,119-i*8)
			end
			sspr(40,12,8,4,1,123)
		end
		-- score
		if pl.score>0 then
			printc(pl.score,64,120,12,1)
		end
	end
	-- screen pal
	memcpy(0x5f10,0x4300,16)
end

function printc(txt,x,y,c,olc)
	c,txt=c or 7,tostr(txt)
	if olc then
		for y=y-1,y+1 do
			for x=x-1,x+1 do
				print(txt,x-#txt*2,y,olc)
			end	
		end
	end
	print(txt,x-#txt*2,y,c)
end

function new_player(x,y)
	local jtm,anm,anmf,flp,onground,inwater,ft,nft,canjmp,btm,zap,zapg=0,1,1,true,false,false,4,4,true,0,nil,1
	return {
		sx=x,sy=y,x=x,y=y,vx=0,vy=0,score=0,guns=0,gun=0,
		update=function(p)
			if chat then
				anm,anmf,flp,p.vx,p.vy,zapt=1,1,p.x<chatf.x,0,0,0
				return
			end
			
			if powercore and zapdest==powercore then
				if zapt>8 and flr(sin(0.5+zapt/896)*224)%14==0 then
					sfx(37)
					for i=0,12 do
						new_particle(powercore.x,powercore.y-4,rnd()-0.5,rnd()-0.5,rnd(zapcols),10+flr(rnd(10)),0,true)
					end
				end
			else			
				if p.guns>0 then
					if btnp(3) then
						-- down
						p.gun=p.gun==1 and p.guns or p.gun-1
					elseif btnp(2) then
						-- up
						p.gun=p.gun%p.guns+1
					end
				end
				
				-- move
				if flying<=1 then
					if btn(0) then
						p.vx,flp=(p.vx<-1 and flying>0) and p.vx or max(p.vx-0.125,-1),false
					elseif btn(1) then
						p.vx,flp=(p.vx>1 and flying>0) and p.vx or min(p.vx+0.125,1),true
					elseif onground then
						p.vx*=0.75
						if abs(p.vx)<0.1 then
							p.vx=0
						end
					elseif flying==0 then
						p.vx*=0.95
					end
					p.vx=onground and mid(p.vx,-1,1) or p.vx
				end
				-- jump
				if jbtnd then
					if (onground or p.y>sy) and canjmp then
						-- jtm: counts down while player is holding jump for variable height jump
						-- canjmp: keeps track of whether the player has released the jump button
						jtm,canjmp=0,false
						if onground then
							p.vy-=1.35
							jtm=8
						else
							p.vy=-1.75
						end
						sfx(34)
					elseif jtm>0 then
						-- increase jump velocity while player holds jump
						p.vy-=0.1
					end
				else
					-- not pressing jump so kill jump time and allow jump
					jtm,canjmp=0,true
				end
			end
			
			if jtm==0 then
				-- only apply gravity when jump height isn't increasing
				if p.y<=sy+3 and flying<=1 then
					if abs(p.vy)<0.5 then
						p.vy+=0.075
					else
						p.vy+=0.1
					end
				end
			else
				-- reduce jump timer
				jtm-=1
			end
			-- cap fall speed
			p.vy=min(p.vy,2)
			
			if p.y>sy+3 then
				if p.vy>0 then
					p.vy*=0.95
				end
				p.vy-=0.05
			end
			-- collide with map
			local collided=false
			p.x,p.y,p.vx,p.vy,onground,collided=collideworld(p.x,p.y,p.vx,p.vy,3,12)
			flying=not collided and flying or 0
			p.x+=p.vx
			p.y+=p.vy
			
			if p.y>sy then
				if not inwater and p.vy>0.5 then
					for i=0,10 do
						new_particle(p.x-4+rnd(8),sy,rnd()*0.5-0.25+p.vx*0.5,-rnd(p.vy*0.75)-0.5,3,30,0.1)
					end
					sfx(35,3,p.vy>1.65 and 0 or p.vy>1 and 1 or 2)
				end
				inwater,flying=true,0
			else
				inwater=false
			end
			
			for b in all(buttons) do
				if p.y==b.y and p.x>b.x-3 and p.x<b.x+11 then
					slvlo,slvld,slvlt,b.y,b.pf=slvl,b.l,0,b.y+2,3
					sfx(43)
				end
			end
			
			if flying>0 then
				flying=max(flying-1,1)
			end
			
			-- set animation sequence and frame
			if not onground then
				-- not on ground so use jump sequence set frame to 1
				anm,anmf=3,1
				if p.vy>1.3 then
					-- if going down use frame 3
					anmf=3
				elseif p.vy>-1 then
					-- if near peak of jump use frame 2
					anmf=2
				end
			elseif abs(p.vx)>0.01 then
				-- if on ground and moving use run sequence
				-- set time til next frame based on velocity
				nft=max(1,flr(6-(abs(p.vx)*2)))
				-- set run sequence
				if anm~=2 then
					anm,anmf,ft=2,0,1
				end
				ft-=1
				-- if frame timer hits 0 increment frame
				if ft==0 then
					ft,anmf=nft,anmf%#panms[anm]+1
				end
			else
				-- standing still
				anm,anmf=1,1
			end
			
			-- shooting
			if sbtnd and not (powercore and zapdest==powercore) then
				if btm<0 and p.gun>0 then
					zapg,zapt,zapdest,btm,zapcols=p.gun,14,nil,15,{8,10}
					sfx(37)
					if p.gun==2 then
						zapcols={3,11}
					elseif p.gun==3 then
						zapcols={15,12}
					end
				end
			else
				btm=btm<=0 and -1 or btm
			end
			if btm>0 then
				btm=max(0,btm-1)
			end
			
			if zapt>0 then
				local zd=zapdest
				if not zapdest then
					local d=p.x+(flp and 47 or -47)
					if zapg==1 then
						if powercore and not flp and powercore.x>p.x-50 and powercore.x<p.x-6 and powercore.y<p.y+6 and powercore.y>p.y-12 then
							zapdest,zd,p.vx,p.vy,zapt=powercore,powercore,0,min(p.vy,0),224
							for i=0,12 do
								new_particle(powercore.x,powercore.y-4,rnd()-0.5,rnd()-0.5,rnd(zapcols),10+flr(rnd(10)),0,true)
							end
						else
							for e in all(enemies) do
								if e.hurttime==0 and ((e.x>p.x and e.x<d) or (e.x<p.x and e.x>d)) and e.y<p.y+8 and e.y>p.y-8 then
									zapdest,zd=e,e
									e:hurt()
									sfx(38)
									for i=0,6 do
										new_particle(e.x,e.y-4,rnd()*0.5-0.25,-rnd(),rnd(zapcols),60,0.15)
									end
									break
								end
							end
						end
					elseif zapt==14 then
						if zapg==2 then
							for h in all(portals) do
								if ((h.x>p.x and h.x<d) or (h.x<p.x and h.x>d)) and h.y<p.y+22 and h.y>p.y-25 then
									zapdest,zd=h,h
									sfx(31)
									break
								end
							end
						elseif zapg==3 then
							local hd=d+(flp and 12 or -12)
							for h in all(hooks) do
								if ((h.x>p.x and h.x<hd) or (h.x<p.x and h.x>hd)) and h.y<p.y+6 and h.y>p.y-25 then
									zapdest,zd,flying=h,h,abs((h.x-p.x)/3)+6
									p.vx=h.x>p.x and 3 or -3
									p.vy=min(h.y-p.y,-8)/16
									sfx(31)
									break
								end
							end
						end
					end
					if not zapdest then
						local inc=flp and 8 or -8
						--d-=inc*0.5
						for dx=flr(p.x+inc),flr(p.x+inc*6),inc do
							if is_solid(dx,p.y-4) then
								d=flr(dx/8)*8-min(inc,1)
								if zapt%3==0 then
									new_particle(d,p.y-4,rnd()-0.5,rnd()-0.75,rnd(zapcols),60,0.15)
								end
								break
							end
						end
						zd={x=d,y=p.y}
					end
				elseif zapg==2 and zapt==7 then
					local dest=portals[zd.d]
					zapdest,zd,p.x,p.y=dest,dest,dest.x,dest.y+2
				end
				
				if zapt%2==0 then
					zapoffsets={{0,0}}
					for i=1,8 do
						add(zapoffsets,{rnd(4)-2,rnd(4)-2})
					end
					zapoffsets[10]={0,0}
				end
				zap={p.x+(flp and 7 or -7),p.y-4.5,zd.x,zd.y-4.5}
				zapt=max(zapt-1,0)
				if zapt==0 then
					if powercore and zapdest==powercore then
						for i=0,32 do
							new_particle(powercore.x,powercore.y-4,rnd(2)-1,rnd(2)-1,rnd(zapcols),90+flr(rnd(60)),0.01,true)
							new_particle(powercore.x,powercore.y-4,rnd()-0.5,rnd()-0.75,rnd(zapcols),120+flr(rnd(90)),0.01,true)
						end
						friends[1].sx-=32
						friends[1].chat,friends[1].chatted=story[5],false
						powercore=nil
					end
					zapdest=nil
				end
			end
			
			-- check collision with pickups
			for pu in all(pickups) do
				if not (p.x+4<pu.x-3 or p.x-4>pu.x+3 or p.y<pu.y-5 or p.y-12>pu.y+1) then
					p:give(del(pickups,pu))
				end
			end
		end,
		give=function(p,pu)
			local ptype=pu.ptype
			-- increment property the pickup affects
			p[ptype.pn]+=ptype.pv
			if ptype.msg then
				popup={txt=ptype.msg,anm=ptype.a,pali=ptype.pali,t=360}
				sfx(ptype.snd)
				if ptype.pn=="guns" then
					p.guns=min(p.guns,3)
					p.gun=p.guns
				end
			else
				add(sndcue,{snd=ptype.snd,msg={x=pu.x,y=pu.y-16,t=90,txt="+"..ptype.pv}})
			end
		end,
 		draw=function(p)
			draw_sp(anm,anmf,p.x,p.y,14,flp,p.gun)
			
			if zapt>0 then
				draw_zap(zap[1],zap[2],zap[3],zap[4],zapoffsets,zapcols[1],zapcols[2])
			end
		end
	}
end

function draw_zap(x1,y1,x2,y2,offsets,c1,c2)
	local lx,ly1,ly2,steps=x1,y1,y1,mid(2,flr(abs(x2-x1)/4),9)
	for i=1,steps do
		local lxn,ly1n=lerp(x1,x2,i/steps),lerp(y1,y2,i/steps)
		local ly2n=ly1n+offsets[i+1][1]
		ly1n+=offsets[i+1][2]
		line(lx,ly1,lxn,ly1n,c1)
		line(lx,ly2,lxn,ly2n,c2)
		lx,ly1,ly2=lxn,ly1n,ly2n
	end
end

function new_eyeball(x,y)
	local flp,ax,ay,vx,vy=false,x,y-8,0,0
	return {x=x+12,y=y+10,hurttime=0,
		update=function(e)
			if e.hurttime>0 then
				vy,vx=min(vy+0.15,2),0
				e.hurttime-=1
				if e.hurttime==0 then
					vx,vy=flp and 0.5 or -0.5,-0.25
				end
			else
				local tx,ty,accel,maxspd=ax,ay+20,0.025,0.5
				if abs(ax-pl.x)<32 and pl.y>ay and pl.y<ay+26 then
					tx,ty,accel,maxspd=pl.x,pl.y,0.25,1.5
				end
				if e.x>tx then
					vx,flp=max(vx-accel,-maxspd),false
				end
				if e.x<tx then
					vx,flp=min(vx+accel,maxspd),true
				end
				if e.y>ty then
					vy=max(vy-accel,-maxspd)
				end
				if e.y<ty then
					vy=min(vy+accel,maxspd)
				end
				if abs(vx)<0.0125 then
					vx*=3
				end
				if abs(vy)<0.0125 then
					vy*=3
				end
				if abs(e.x+vx-ax)>20 then
					vx=-vx*0.75
				end
				if abs(e.y+vy-ay)>24 then
					vy=-vy*0.75
				end
			end
			local pvy=vy
			e.x,e.y,vx,vy=collideworld(e.x,e.y,vx,vy,3,8)
			e.x+=vx
			e.y+=vy
			if e.hurttime==0 then
				if e.x+4>pl.x-3 and e.x-4<pl.x+3 and pl.y>ay and pl.y<ay+26 then
					pl.vx,pl.vy,flying=pl.x>e.x and 3 or -3,pl.vy>-1 and -1 or pl.vy,0
					sfx(33)
				end
			else
				if pvy>0 and e.vy==0 then
					vy=pvy*-0.75
				end
			end
		end,
		hurt=function(e)
			e.hurttime,vy=300,-1.5
		end,
		draw=function(e)
			if ax<camx-32 or ax>camx+160 or ay<camy-32 or ay>camy+136 then
				return
			end
			local cx,cy,t,c=ax,ay,1-abs(e.x-ax)/20,ay>sy and 3 or 8
			local cpx,cpy=ax+(e.x-ax)*0.5,ay+t*t*(3-2*t)*18+10
			for i=0,8 do
				local nx,ny=lerp3(ax,ax,e.x,i/8),lerp3(ay,cpy,e.y-3,i/8)
				line(cx,cy,nx,ny,c)
				cx,cy=nx,ny
			end
			draw_sp(4,e.hurttime>0 and 2 or 1,e.x,e.y,8,flp)
			
			-- draw dizzy stars
			if e.hurttime>0 then
				local s=min(e.hurttime/30,1)
				for i=0,2 do
					local xs,y=e.hurttime/48+i*0.3,e.y-13+cos(e.hurttime/40+i*0.3)*1.5
					local x,c=e.x+sin(xs)*5,cos(xs)>0 and 10 or 9
					if s>0.5 and s<1 then
						rectfill(x,y,x+1,y+1,c)
					else
						circfill(x,y,s,c)
					end
				end
			end
		end
	}
end

function new_friend(x,y,storyi,ia,wa,chatted)
	local flp,dx,wait,anm,anmf,ft,wm,dm=false,x,60,5,1,0,chatted and 1 or 90,chatted and 32 or 12
	return {x=x,y=y,sx=x,chat=story[storyi],chatted=chatted,
		update=function(p)
			if not chat then
				if p.x>dx then
					p.x-=0.25
					flp,anm=false,wa
				elseif p.x<dx then
					p.x+=0.25
					flp,anm=true,wa
				elseif wait>0 then
					anm,anmf=ia,1
					wait-=1
				else
					wait=60+flr(rnd(wm))
					if dx>p.sx then
						dx=p.sx-flr(rnd(dm))-4
					else
						dx=p.sx+flr(rnd(dm))+4
					end
				end
			
				if not p.chatted and ((p.x>pl.x-24 and p.x<pl.x-9) or (p.x>pl.x+9 and p.x<pl.x+24)) and p.y==pl.y then
					chati,chat,p.chatted,flp,chatf=0,p.chat,true,p.x<pl.x,p
				end
			end
			if ft>0 then
				ft-=1
			else
				ft=3
				anmf=anmf%#panms[anm]+1
			end
		end,
		setanim=function(p,i)
			anm,anmf=4+i,1
		end,
		draw=function(p)
			draw_sp(anm,anmf,p.x,p.y,12,flp,4)
		end
	}
end

function new_particle(x,y,vx,vy,c,t,g,nonsolid)
	c,t,g=c or 8,t or 60,g or 0.2
	add(particles,{
	update=function(p)
			vy=min(vy+g,7)
			
			-- if particle is solid then bounce
			if not nonsolid then
				if (vx>0 or vx<0) and is_solid(x+vx,y) then
					vx=-vx*0.75
					vy*=0.9
				end
				if (vy>0 or vy<0) and is_solid(x,y+vy) then
					vy=-vy*0.75
					vx*=0.9
				end
			end
			
			x+=vx
			y+=vy
			
			-- delete when its timer expires
			t-=1
			if t==0 or y>=sy or y>camy+140 or y<camy-12 or x<camx-12 or x>camx+140 then
				del(particles,p)
			end
		end,
		draw=function(p)
			pset(x,y,c)
		end
	})
end

function draw_sp(anm,anmf,x,y,h,flp,pali,noswamp)
	if y-h<sy or noswamp then
		draw_spint(anm,anmf,x,y,flp,pali)
	end
	if y>sy and not noswamp then
		memcpy(0x5f00,0x4310,16)
		if y-h<sy then
			clip(x-8-camx,sy-camy,16,16)
		end
		draw_spint(anm,anmf,x,y,flp)
		clip()
	end
	pal()
end

function draw_spint(anm,anmf,x,y,flp,pali)
	for i=1,#panms[anm][anmf] do
		local af=panms[anm][anmf][i]
		local f=true
		if (flp and af.f) or (not flp and not af.f) then
			f=false
		end
		if af.s<1 then
			pset(x+(f and -af.x-1 or af.x)+0.5,y+af.y+0.5,-af.s)
		else
			local s=psprs[af.s]
			if af.p and pali then
				memcpy(0x5f00,0x4320+pali*16,16)
			end
			sspr(s.x,s.y,s.w,s.h,x+(f and -s.w-af.x or af.x)+0.5,y+af.y+0.5,s.w,s.h,f)
			if af.p and pali then
				pal()
			end
		end
	end
end

function collideworld(x,y,vx,vy,w,h)
	local topclip,onground,collided=h>8 and h-8 or h,false,false
	-- only check collision in direction we are moving
	if vx<0 and (is_solid(x+vx-w,y-1) or is_solid(x+vx-w,y-7) or is_solid(x+vx-w,y-h+1)) then
		x,vx,collided=flr((x+vx+w)/8)*8+w,0,true
	end
	if vx>0 and (is_solid(x+vx+w,y-1) or is_solid(x+vx+w,y-7) or is_solid(x+vx+w,y-h+1)) then
		x,vx,collided=flr((x+vx-w)/8)*8+8-w,0,true
	end
	if vy>0 and (is_solid(x-w+1,y+vy) or is_solid(x+w-1,y+vy)) then
		-- hit the floor so set onground to true
		y,vy,onground,collided=flr((y+vy)/8)*8,0,true,true
	end
	if vy<0 and (is_solid(x-w+1,y+vy-h) or is_solid(x+w-1,y+vy-h)) then
		y,vy=flr((y+vy)/8)*8+topclip,0
	end
	return x,y,vx,vy,onground,collided
end

function is_solid(x,y)
	return fget(mget(x/8,y/8),1)
end

function lerp(a,b,t)
	return a+(b-a)*t
end

function smoothlerp(a,b,t)
	return a+(b-a)*(t*t*(3-2*t))
end

function lerp3(a,b,c,t)
	return (1-t)*(1-t)*a+2*(1-t)*t*b+t*t*c
end
__gfx__
00007777cfd0676d7e50efef777aa7790097790029a923b303b303bb3e003bb3e08777a976d5fcff000000000000007fcfeceefe0000000000000000fc77ccfe
000011111f6626280cf7c07c744a9474082297909a7a972b072b3b7bb3e3b11b3e877a99ddd5ee55000000000c0000fefe5c55500000000000000000effffee5
0000a15a1fdd27890e5efe50a49a94a4266728a9999993b303b33beeb3e3b52b3e8aa998ddd5fcff000000000c700f00fe1ceefe000000000000000055555511
6d5d15555fdd268a0e5ece5faaaa9aa46722789889a980030300e3bb3eee3bb3ee8a9988d551f77c000000000f77e000f55ce55100005ddd55110000fc7cffe5
d5157157cfc0289a7cf700ec7a033000621f727a0888200303000eeeee50eeeee50000005cf1ece5000fe0000eccc000e51ceefe000d6d5111111100e5c51e15
0000c77cff00d66d00e500707937b3006fff7298000000003773037730bbbb3003bb3e001fe5efff000ecf0005efff00111fe15100d7d10000001510e5f51e15
06555556077777777e500000a93bb3000677298000000000772707727be7bebe3b7bb3e01ee1e5550000f7c0ee55eee0fc77ccfe0566100000000151e1f11e15
6577ccf5607777700cf00000a903300000228800000000007227072273beeb3e3bbeb3e05511111100000c7cf5000000efcccfe50d6d100000000051efffee55
57c2c2cf5007770005eee510bbbb30000000000001111110377303773e3bb3eee3bb3ee000000000000000c7f0000000000000005d7500000000001510000000
0ccc2ccf000070000fcccfe0bbe3b30000000000111ce1110003030000eeeee50eeeee500000000000000e5fce00000000000000567500000000001510000000
0fc2c2ff000fe000000e5000bbeebb000000000011c7fe11a7777aa77778a777889a7aa90000000000f0ef50efe0000000000000d66d10000000011510000000
05fffff5000e5000000fe000bb00bb000000000011111111aa77aaaa7772aa77889a7a98000000000fc7e5000ee5000000000000f77777cccfcffeee10000000
005555500fcccfe0000000007b007b00000fe00011111111aaaaa9aaa7729a77829a798800000cfefc7cf00000550000000000efc777cccfffffffeee5000000
0000000005eee510000000007b007b00000e500011c7fe119999999aaaa299a72299a8880000cfefc7cfe500000000000000effcc7ccccfffffffffeeee50000
7777666600000000000000003e003e000fcccfe0111ce111000000000000000000000000000cfeffeffe50000000000000efffcc7cccccffffffffffeeeee500
ccc7ffff0000000000000000ee00ee0005eee5100111111000000000000000000000000000cfeffcf5e5000000000000effcfcccccccccccccccfcffffefeee5
1fffeee1000d6000b30b30b3bbbb3b3000bbbb303bbbb3000115555511111110d677676666deff7f5e510000efcf556501155555555555555555111111111110
1cc7fff10005d000bb0bb0bbbbeeebb000bbe3b3bbeebb0005eeeeee51111110576ddddddd6de7f5e5150000555ce16505eeeeeeeeeeeeeeeeeeee5551111110
1115111100011000bb0bb0bbbbb3ebb000bbeebbbbeebb00efffcfccffefeee557ddddddddd6cf55515e0000fe1fe165efffcfcccccccccccccfcfffffefeee5
111d511100000000bbebbebbbbee0bb000bb00bbbb00bb00001111111111110056d51151555cf55515e00000cf1fe16500111111111111111111111111111100
111d5111000000007bbbbbbb7bbbb7bbbb7bbbbb7bbbbb00000511111111100056d1fcfffe7f55515e000000fe1fe16500001111555551111111111111110000
111d5111000110007777bbb3777b3777b3777bb3777bb300000e510000e5100056d1f77cecf5155550000000fe5fe1650000000115eeee551511111110000000
49a7a9450005d0003eeeeeee3eeee3eeee3eeeee3eeeee00005511000051110057d1f7cfef5155d500000000551ce1d500000000000000000000000000000000
54994455000d6000eeeeeeeeeeeeeeeeeeeeeeeeeeeeee005ee5511005ee5111d7d5fcfffe555dd500000000551fe15100000000000000000000000000000000
00000000111111111111111111111111001111000011110000111100001111000011110000000000000110000001100000011000110110111101000000001111
00000000111111111111111111111111001111000011110000111100001111000011110000000000000110000001100000011000110110111101000000001101
00000000111111111111111111111111001111000011110000111100001111000011110000000000000110000001100000011000110110101101000000001101
00000000111111111111111111111111001111000011110000111100001111100111110000000000000110000001100000011000110010100101000000001101
00000000111111110111111111111110001111000011110000111100000111111111110011111111000110000001100000011000010010100100000000001001
00000000111111110111111111111110001111000011110000111100000111111111100011111111000110000001110000111000010010000100000000001000
00000000111111110011111111111100001111001111110000111111000111111111100011111111000110000000111111110000010010000100000000001000
00000000111111110000111111110000001111001111110000111111000100111111000011111111000110000000111111010000010000000000000000000000
6777776766333363663363333363b765977a9945d7767666677766d55fc777777777777777cccfe15fc77ce1000e5000d77666655555555549a7945555555599
666676ddddedeeeddddeedeeeeede6d19794445156dddddddd6d5555e7fffffffffffffffffffff1e7fffff10007c00056dddd655499999949aa9454999994aa
66667ddddddedeeedddededeeededdd19a44445156ddddddddd55555e7feffffffffffffffff3ef5e7ffff35007ffc0056ddddd5599a7a77a4994549a777a477
d6666dddddedededddededeeededed51474444511dddddddddd55551ebfffffffffffffffffff3f5ecfffff50cf00fc01ddddd515499999999444999999994aa
551111111111111111111111111111114a4444511111111155111111eb3ff3fffff3fffffff33335ecfff3f50fc00cf011111111554444444444444444444599
544511111111111111151111111111114a4114511111111154451111533e3f3f3f3f3f3f3f3f3e315f3f3f3100fc7f0011111111155555555555555555555544
594445111212121212145112121212114941545111121212594445115e3333f3f333f3f3f3f333e15ef333e1000ff00011121211111111111111111111111155
594445512181818181295121818181214a4154511121818159444551155555555555555555151111155551110000000011218121111111111111111111111111
5fc7777777cccfe15fc77777c5e7cfe1494154511115fc7777cccfe1111111115511111111111111633663330bbbbb0003b003b00b3000b30000000000000000
e7fffffffffffff1e7ffffffe5fcfff14941545111ec7feffffffff1111111115445111111111111ddedeeedb7b37b0007b007b307b303730000000000000000
ecfefffffffffef5e7fefffff5cffef54944945115c75efffffffef5111212125944451111121212dedeeeddbb30bb000bb03bbb0bbb3bbb0000000000000000
15effffffffffff5ecfffffffefffff5494444511f75effffffffff5112181815944455111218181ddeeeded3bb0bb0b3b30bb0b0bbbbbbb0000000000000000
545efffffffffff5e7fffffffffffff5494444515fe5fffffffffff512181812977a994512181812dddededd0bb33b37bb30bb3b3bb0b3bb0000000000000000
54defffffffe5ff5ecfffffffffffff549411451effefffffffffff5155555559794445111818181ddedeedd00bb3bb3bb03b3bbb3b030bb0000000000000000
54dfffffffe5ecf5ecfffffffffffff549415451ecfffffffffffff5549994454744445112181812dddedeed00b30b300b03b003b3b000b30000000000000000
5fcffffffffccff5ecfffffffffffff549415451ecfffffffffffff5155555514a41145111212121555555550b30030000003000303000300000000000000000
ecfff3fffffffff5ecfffffffffffff549415451ecfffffffffffff511111111494154511111111166336366bbb3003b30bbb30bb0bb0bbb0000000000000000
ecff3ffffffffff5ecffffffffffffe5444154515ffffffffffffff5111511114941545115ddddd5ddeeededb7bb337bb3b7bb3b703bb7b30000000000000000
ecfff3fffff3fff5ecfffffffff6776666666666766d5ffffffffff5111451124944945111115511dddeeeddbb0bbbb0b3bb0bb3b03bbb000000000000000000
ecfe3f3fff3ffe35ecfefffffff67656dddddddd65651ffffffffef51129512149444451115eee51ddededddbb3b3bb0bbbb0bb0bbbbbbb00000000000000000
ecfff3fffff3f3f5ecfffffffff66dddddddddddddd51ffffffffff5121951124994445115ddddd5dddededdbbbb0bb07bbb0b303bb3bb300000000000000000
ecffffffff3f3335ecffffffffffe5111111111111115ffffffffff5118951814455555111111111ddddeddd3b300bb3bbbb3b300bb03b000000000000000000
ecfffffffff3f335ecfffffffffffe5154511511155efffffffffff5121951125111111111121212dddddddd3b0003bbb3bbb3000b300b300000000000000000
ecffffffff3fff35ecfffffffffffff549415451effffffffffffff5118451811111111111218181555555550300003b30bb3000b30000b30000000000000000
ecfffffffffffff1ec3ffe5ff3f3fff149d15d51ecfffffff3fff3e1677777676666666666666666677766d507ffffffffffffffffffffe00cffffffffffffe0
ecfff3ffff3ffff5ecf3e5fcff3ffff5e9e15e51ecff3fff3ffffe51666676dddddddddddddddddddd6d55550cffffffffffffffffffffe00cffffffffffffe0
ebfffffff3f3f3f1ec3f5ecffffff3f1d3ed3e51ecfff3fff3f3fb3566667dddd511115dd511115dddd5555507ffffffffffffffffffffe00cffffffffffffe0
5bf3ffff3f3f3f315bf3efbfff3f3ff1e3eeed515cff3f3fffff333567d67dddd115551dd115551dddd55d1507cfffffffffffffffffffe00cffffffffffffe0
533f3ffff3f333315f3f3bf3f3f3f3f1d3ded4515ff3f333f3f333f166d67dddd15fee1dd15fee1dddd555150777c7cccccccccccccfcfe00cffffffffffffe0
533ef3ff3f333e3153fe333f333f3ef1e9e11451533e33333f333e316d667dddd111551dd511555dddd5515507cffefeeeeeeeeeeeeeeee00cffffffffffffe0
5e333ff3f33333e15e3333f3f333f3e1d3d154515e333333f33333e1d6666dddd15fee5dddddddddddd555510cffefeeeeeeeeeeeeeeeee00cffffffffffffe0
1555555555151111155555555515111149e1545115555555551511115dddd5555115551555555555555111110efefeeeeeeeeeeeeeeeee500cffffffffffffe0
556577a774940000000000000000000000000000000000000000b40000000000000000000000000007372535256576a427377787a78657670000000000000000
00b4000000000000000000000000b40000000000000000f02565452535063646566695a445000000303030303000000000000000000000005737053595263646
061685000000000000000000000000000000000000000000000000000000000000000000000000000000063656165565852565f0000000000000000000000000
000000000000000000000000000000000000000000000021261686573707678657372535041424344454347797a754246400000000007797a6a70717a4273747
27374500000000000000000000000060000000000000000000000000000000000000000000000000000027370737263646566621000000000000000000000000
0000000000000000000000000000000000000000000013412717a476556596748494061625657494455515757484940565000000000000000000000000002515
15a4860000000000000414344477a587a6a597a75464000000000000000000000004146400000000000000008600061647576741d30000000000000000000000
00000000000000000000000025350000000000000004347797a72536561677a700000717266676a44706162565a4765767303000000000000000000000000717
660000000000000000452535455565f0000000553545000000000000000000000025658600000000000000000000073786a477a5a6a754640000000000000000
000000000000000000000000061600000000000000051575859657170666253500000000273777a745573726669577a5a697a700000000000000303030007494
17000000000000000047263646566621000000273747000000000000000000000057170000000000000000000000000000000000007484940000000000000000
0000000000000000000000000717000000000000000717a486256576073706660000000000000000256596071725357585000000000000000004243477a5a795
35000000000000041464273747576741a300000000860000000000000000000000a4850000000000000000000000000000000000000000000000000000000000
00000000000000000000000085950000000000000000000000273777a5a75767000000000000000057377787a70737a447000000000000303074949625357525
1600000000000086748494a48677a6a7000000000000000000000000000000000076470000000000000000000000000000000000000000000000000000000000
00000000000000000000000047a400000000000000000000000000000000b4000000000000000000f0253544556585256500000000007797a6a7256557377626
67000000000000000000000000000000000000000000000000000000000000000025350000000000000000000030300000000000000000000000000000000000
00000000000000000000000025650000000000000000000000000000000000000000000000000000212636465666472737000000000000000085576795749427
0414246400000000000000000000000000000000000000000000000000003030302616c402c40000000000000414246400000000000000000000000000000000
000000000000000000000000576730300000000000000000000000000000000000000000000000334127378657674595863030000000000000867484947797a7
6555654500000000000000000000000000000000000000000000000000000414342737d4e4f40000000000007484944500000000000000000000000000000000
00000000303000000000000077a697a5a700000000000000000000000000000000000000000000002515256576a4041424345464000000000000000000f00515
170666470000000000000000000000000000000000000000000000000000056577a7251555650000000000000000008600000000000030000000000000000000
00000000043400000000000085760000000000000000000000000000000000000000000000000000061657372535256574849445000000000000000000210616
9557377797a7543477a7546400000000000000000000000000003030000057372535263656660000000000000000000000000000000414640000000000003000
000000000535000000000000749400000000000000000000000000000000000000000000000000000717a4960737261654647647000000303030000063410717
2535a4859574849476556545303000000000000000000000000077a7000000005737061657670000000000000000000000000000004577a7000000000077a6a7
00000000061654640000000005650000000000303000000000000000000000000000000000000000000077a687a75767a44577a597a6a5a777a7045454246425
57177645749477a6a727370414546400000000000000000000000000000000007494071700000000000000000000000000000000002515470000000000000000
0000000057377494000000000666000000000077a700000000000000000000000000000000000000000074849455155414043474947585256575256555354527
65251545f00000000000008625654500000000000000000000000000003030308577a6a700000000000000000000000000000000002616041464000000000000
0000000000000000000000002616000000000000000000000000000000000000000000000000000000256685a40666056586968577a745071795063656664776
36561647210000000000000006665424345414246477a6a7542414246477a5a74525150000000000000000000000000000000000000737475565000000000000
00000000000000000000000057173030000000000000000000000000000000000000000000000000002767457526365616749445c47484940565073757672535
372717454193000000000000076705152535749447955565967484942565a495470737000000000000043477a7c404243477a5a697a776450616303000000000
0000000000000000000000008577a5a6a70000000000000000000000000000000000000000000000000000479557370717256547251547950616a45424640717
056577a5a700000000000000000057370616a475749457670565251507177494860000000000000000051595253545a47494000074849486576777a5a7000000
00000000000000000000000086000000000000000000000000000000000000000000000000000000000000865434a42535263646561645962737962535452515
07679585000000000000000000000000071700000000000026160737855535f00000000000000000000717a45767860000000000000000000074942535000000
000000000030000000000000000000000000000000000000000000000000000000000000000000000000007797a6a706662737455767867797a6a70717862616
74849486000000000000000000000000000000000000000027377494860616210000000000000077a6a700000000000000000000000000000000002767303000
0000000077a6a7000000000000000000000000003030300000000000000000000000000000000000000000007494955737748494000000000000000000005767
76850000000000000000300000000000000000000030303000859577a7576741b330300000000000000000000000000000000000000000000000000077a587a7
0000000000000000000000000000000000000000041464000000000000000000000000000000000000000025657605157555658500000000000000000000f005
65470000000000000077a5a700000000000000000077a5a697a72535a49554243454146400000000000000000000000000000030300000000000000000857685
000000000000000000000030303030000000000045251500000000000000003030300000000000000000000717a4061696273747000000000000000000002106
174500000000000000000000000000000000000000000000008606667525650515256545000000000000000000000000000004142464000000000000008677a7
000000000000000000007787a5a697a70000000086061600000000000004143477a754640000000000000000857607172565c445303000003030300000434107
35453030300000000000000000000000300000000000000000005717965737061627377797a5a7000000000000046400000077a6a70414246400000000000000
000000000000000000000000000000000000000000071700000000000005652535748494000000000000000045253595076777a597a700007787a7000077a697
1654345424640000000000000000007797a70000000000000000f025658576071700000000000000000000000077a7000000859576475464f000000000000000
0000000000003000000000000000000000000000000000000000000000271726165565f00000000000000000455767c474849485000000000000000000007484
67962565774500000000000000000000000000000000000000002126164574849400000000000000000000000000000000000424246496452100000000000000
00000000000414640000000000000000000000000000000000000000000085573706662100000000000000004725655565543445303000000000000000303025
2565573705150000000000000000000000000000000000000073410737253576a400000000000000005464000000000000008677a6a587a74183000000000000
000000000045c4470030300000000000003030000000000000000000002565a49607174153000000006000004526160717051547303000000000000000303027
071776a406160000000000000000000000000000778797a5a75424649507375565000000000077a697a7450000000000000000043445957797a5a70000000000
00000004340414246477a6a700000000c404146400000000000000000057177484945424647797a6a5a754246427377585073777a5a697a700000077a6a75424
87a755650717000000000000000000000000000030300515256574849485000666000000000030303077a5a70000000000000077a5a75464c495850000000000
0000004796455434475464850000000077a6a786000000000000000000003030852565748494253574945565867677a6a7002535303030000000000030302535
00002737004700000000000000000000000000000000071706160086a445005767000000000000000000850000000000000000000086964577a7470000000000
0000008677a6a7968696458600000000008685000000000000000000000030304507370086000616850057670005650086000616303030000000000030300717
00000000008600000000000000000000000000000000000027370000008600000000000000000000000086000000000000000000000077a70000860000000000
0000000000860077a6a7860000000000000086000000000000000000000000008600000000000717860000000007370000005767000000000060000000000000
__gff__
0001000101010100000210100210100200001000100000000002101010101010031100000000101002021002101010100001010101010101010101010101010102020202020202020202020902020202020202020202020202020200000000000202020202020202020202000000000002020202020202020202020000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000a0b0000000000000000000000000000000000000000000000000000000000000000000000445251000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000775a796a5a7a45434043775a7a000000000000000000005253
0000191a1b000000000000000000000000000000000000000000000000000000000000000000525674626144525300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005847497455565958000000000000000000007276
7828292a0000000000000000000000000000000000030000000000000000000000000000000072736860636465660000000000000000000000000303000000000000000000000000000000000000000000000000000000000000000000000003030303000000000000000000775a6a7a72764749000000000000000000005867
77092b000000000000000000000000000000000040414600000000000000000000000000000000777a7573547576000000000000000000000040414246000000000000000303030000000000000000000000000000000000000000000000776a7940414600000000000000000000040000000000000000000000000000004042
52510c00000000000000000000000000000000005051540000000000000000000000000000000000474849740000000000000000000000000047484968000000000000775a6a787a0000000000000000000000000000000000030300000000000052535400000000000000000000000000000000000000000000000000005051
707121000000000000000000000000000000000070735400000000000000000000000000000000005253674a000000000000000300000000000000000000000000000000000000000000000000000000000000000000000040414344000000000072525600000003030303000000000000000000000000000000000000007571
52530f000000000000000000775a7a0000000000585974000000000000000303000000000000030375765556000000000000775a7a00000000000000000000000000000000000000000000000000000000000000000000005447495400000000000060614546776a795a6a797a4543777a4546775a7a00000000000000007467
6261775a6a787a0000000000004b0000000000005455560000000000000040460000000000004043505172730000000000000000000000000000000000000000000000000000000000000000000040414243444543776a7a52535974000000000000707647484952536758595556474947495051000000000000000003035452
75766758555658000000000000000000000000005460660000000000000052510000000000005256606167580000000000000000000000000000000000000000000000000000000000000000000052535051684a4748494a7073775a797a000000000000000000727347484975730000000070710000000000000000776a7a62
56525674707654000000000000000000000000007475760000000000000070730000000000007573707177795a7a00000000000000000000000000000000000d0e000000000000000000000000007273606100000000000000000000000000000000000000000000000000000000000000005253000000000000000000555672
667271545740414246000000000000000000000054694a0000000077795a7a580000000000000000000400000000000000000000000000000000000000001c1d1e1f00000000000000000000000058577071000000000000000000000000000000000000000000000000000000000000000062614c204c000000000000606158
735977797a745256540000000000000000000000545051000000000000474954000000000000000000000000000000000000000000000000000000000000262d2e2700000600000000000000000054474849000000000000000000000000000040430000000000000000000000000003030360664d4e4f000000000000707340
56555658525175767400000000000000000000005470710000000000000050560000060000000000000000030303000045460000777a00000040414243775a7a454246777a404146000000000000745556580303030000000000000000000000744a00000000000000000000000040424043757659525100000000776a5a787a
76757368707369505600000000000000000003036859776a7a00000000006066454246775a7a4041424345424677786a7a5403034a5800000050514a525358474849745251545553000000000000546066776a5a6a7a0000000000000000454246776a7a000000000000000000005056744a776a7a7073000000000000000058
484977786a5a7a707100000000000000004043525655566758000000000075764749684a47484952534a47495256584a6740435256740303036061677076745977797a606364656100000000030354757652534a695800000000000000005251505359580000000000000000000060777a030303000000000000000000000054
59505658594749675800000000000000004749606365664a540000000000000000000000000000707177797a60665447495056727652534749707155564a5452565253727168757300000077796a5a787a72734748490000000000775a7a60617076555600000000000000000000727368000000000000000000000000000074
516061745253525654030300000000000000007273626150514546000000000000000000000000000000000070766800006061694a707677787a00757369546261757600000000000000000000000000000000004b000000000000000000757347497073000000000000000000000000000000000000000000775a7a00000052
7662636465636561776a5a7a000000000000000000757670735256000000000000000000000000000000000000000000007573777a680000000000004749687073000000000000000000000000000000000000000000000000000000000000000000775a7a454344454246000000000000000000000000000000000000000075
697571547276606658000000000000000000000000000000007071030303000000000000000000030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f525154525674000000000000000000000000000000000000000040
6a5a796a7a677076740303000000000000000000000000000058775a7a454600000000000000777a45460000000000000000000000000000000000000000000000000000000000004043444542460000000000000000000300000000000000000000000012626364656654000000000000000000000000000000000000030352
55564749474849776a5a6a786a776a79785a6a5a796a7a0000544a5958474900000000000000004749540000000000000000000000000000000000000000000000000000000000005253545556740000000000000000030000000000000000000000003214727374757154030300000000000000000000000000000077787a62
62610000000000000000004b0000000000000004000000000074525354555600000000000000000077795a7a000000000000000000000000000000000000000000000000000000007063646566540000000000000000000300000000000000776a7a44454377785a7a4a40414300000000000000000000000000000000005872
707100000000000000000000000000000000000000000000005460636465660000000000000000000000000000000000000000000003030300000000000000007779786a6a5a796a7a73687576404146000000000000030000000000000000584749684748495253585774525600000000000000000000000000000000004041
59580000000000000000000000000000000000000000000000547273747576775a7a00000000000000000000000077787a00000040414241460000000000000000000004000000000000000000545253000000000000000300000000000000540000000000007073684749757600000000000000000000000000030303005455
515400000000000000000000000000000040414345424677796a7a69545952515253000000000000000000000000000000000000525347484900000000000000000000000000000000000000007472730000000000000300000000000000007400000000000000000004000000000000004041460000000000775a6a795a7a60
71740303000000000000000000000000004749474849545256585556505670717071000000000000000000000000000000000000757655560000000000000000000000000000000000000000005051776a7a00000000777a00000000000000540000000000000000000000000000000000525354000000000000000000005870
56777a45460000000000000000000000000000000050516066746263656167505677787a0000776a5a7a000000000303030000004a587073000000000000404344776a7a454142414600000000606157525600000000000000000000030300544c204c0000000000000000000000000000606674000000000000000000005053
6647484968000000000000000000000000000000007071757154707175764a60665556580000000000000000404142464477786a7a5051000000000003034749545947484952515553000000007071597573000000000000000000776a7a50534d4e4f00004041424377797a444542777a727177787a00000000000000006061
760f0000000000000000000000000000000000000000525367544a5958525670736061540000000000000000544a5253745253594a606100000000775a6a7a67745253694a62617576000003034a47484945414246000000000000000f4a757659555600006847495256594a5455560003030303000000000000000000007071
531200000000000040414600000000000003030303006261474952517460614a5972765400000303030300007469757154606647497071000000000000005556546261525670734a00000077796a7a6752534a555600000000000000125256404360610000000000707147496875730000000000000000000000000000004748
71143e000000000052515445437779786a7a404142437576677475715475764749525177797a454243775a6a7a474959547571555658404146000000030360636465667573594749000000525159505660665770760000030303003c147073544a72710000000000000000000000000000000000000000004041464541424358
4142434546775a7a707168776a7a4748494749777a4748484977787a68775a6a7a7573684a47484955564a595847484950565770717452537779775a6a7a727168757677796a787a00000072734a707175775a6a78796a7a45434445465256745251775a46000000000000000000000000000000000000005251544749525654
__sfx__
01010e101872418741187611875118741187311872118731187311874118731187211872118711187101871000700007000070000700007000070000700007000070000700007000070000700007000000000000
010c07080c1100c1210c1210c1310c1310c1310c1210c121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000021801518715000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001853418534185241852418514245151851518515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c07080c7300c7410c7510c7610c7710c7610c7510c741000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010114160000000000000000000000000000001872418741187611875118741187311872118731187311874118731187211872118711187101871000700007000070000700007000070000700007000000000000
01011a1c0000000000000000000000000000000000000000000000000000000000001872418741187611875118741187311872118731187311874118731187211872118711187101871000000000000000000000
01010e101871418721187211872118711187111871118711187211872118721187111871118711187101871000700007000070000700007000070000700007000070000700007000070000700007000000000000
0140000024b4728b572bb472fb3724b2728b172bb172fb2723b4727b572ab472eb3723b2727b172ab172eb2720b4725b5728b472cb3720b2725b1728b172cb271fb4723b5726b472ab371fb2723b1726b172ab27
014000000bc340bc510bc610bc510bc310bc410bc510bc210bc310bc510bc610bc510bc310bc410bc510bc210bc310bc510bc610bc510bc310bc410bc510bc210bc310bc510bc610bc510bc310bc210bc110bc15
014000001391413931139211391113911139111392113911129101293112921129111291112911129211291110910109311092110911109111091110921109110e9100e9310e9210e9110e9110e9110e9210e911
014000002484424851238412384123821238112381123831238412385123841228512284122831228212281122815288342885128841278512784127831258412684126851268412683126821268112681126815
014000002884428831288512b8512b8412b8112881428831278312785127841278312a8312a8212a8112a8112a815258342584128841288312881128821258412684126851268412683126821268112682126815
0140002030a5030a4030a3030a2030a1030a1030a150bc140bc310bc510bc610bc510bc310bc210bc110bc1531a5031a4031a3031a2031a1031a1031a150bc140bc310bc510bc610bc510bc310bc210bc110bc15
0140000010914109311092110911109111091110921109110f9100f9310f9210f9110f9110f9110f9210f9110d9100d9310d9210d9110d9110d9110d9210d9110b9100b9310b9210b9110b9110b9110b9210b911
0140000022b4726b572bb472eb3722b2726b172bb172eb2721b4726b5729b472eb3721b2726b1729b172eb271fb4722b5727b472bb371fb2722b1727b172bb271fb4723b5726b472ab371fb2723b1726b172ab27
01400000139141393113921139111391113911139211391111910119311192111911119111191111921119110e9100e9310e9210e9110e9110e9110e9210e9110b9100b9310b9210b9110b9110b9110b9210b911
014000002b8442b8312b8512b8512b8412b81128834288302a8312a8512a8412a8412a8312a8212a8112a81525834258312584125841258312583520834208512384123851238412384123831238212381123815
0140002037a5037a4037a3037a2037a1037a153ba403ba3036a5036a4036a3036a2036a1036a1531a3033a4034a5034a4034a3034a2034a1034a1538a4038a3033a5033a4033a3033a2033a1033a1531a4033a30
014000003aa503aa303aa2039a5037a5037a3032a5032a3039a5039a3039a203aa5032a5032a3032a5035a4037a5037a3037a203aa4039a4039a3035a4035a3037a5037a4037a3037a2037a1037a1537a1500000
0140000024b4728b572bb472fb3724b2728b172bb172fb2723b4727b572ab472eb3723b2727b172ab172eb2720b4725b5728b472cb3720b2725b1728b172cb2723b4727b572ab472eb3723b2727b172ab172eb27
014000000000000000000000bc140bc210bc310bc410bc210bc310bc510bc610bc510bc310bc410bc510bc210bc310bc510bc610bc510bc310bc410bc510bc210bc310bc510bc610bc510bc310bc210bc110bc15
014000000c9100c9310c9210c9110c9110c9110c9210c9110b9100b9310b9210b9110b9110b9110b9210b9110d9100d9310d9210d9110d9110d9110d9210d9110b9100b9310b9210b9110b9110b9110b9210b911
014000001091010931109211091110911109111092110911129101293112921129111291112911129211291110910109311092110911109111091110921109110e9100e9310e9210e9110e9110e9110e9210e911
0140000023b4728b572cb472fb3723b2728b172cb172fb2721b4725b5728b472cb3721b2725b1728b172cb2722b4725b572ab472eb3722b2725b172ab172eb271fb4722b5727b472bb371fb2722b1727b172bb27
0140000034a5034a4034a3034a2034a1034a1533a4033a3031a5031a4031a3031a2031a1031a1533a4034a5036a5036a4036a3035a4031a5031a3035a5035a3033a5033a4033a3033a2035a5035a3037a5037a30
0140000010914109311092110911109111091110921109110d9100d9310d9210d9110d9110d9110d9210d91112910129211292112911129111291112921129111391013921139211391113911139111392113911
0140000023b4727b572cb472fb3723b2727b172cb172fb2724b4728b572bb472fb3724b2728b172bb172fb2720b4724b5729b472cb3720b2724b1729b172cb2723b4728b572bb472fb3723b2728b172bb172fb27
0140002038a5038a4038a3038a2038a1038a153ba403ba3037a5037a4037a3037a2037a1037a1532a4034a3035a5035a4035a3035a2035a1035a1538a5038a3034a5034a4034a3034a2034a1034a1537a4039a50
014000001491414931149211491114911149111492114911109101093110921109111091110911109211091111910119311192111911119111191111921119111091010931109211091110911109111092110911
01080000000730c17324670226611e6511a65116651126510e6510a65106651046510265100651006410063100631006210062100611006120061200615000000000000000000000000000000000000000000000
01030000306140011411121180310c031120210452400511005150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700002f0202f0153b0203b0113b015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000065523024160310b13100215000240b11100011006150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000012014230112f0112f01500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000000135070140c011180110c011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002400000000
010a0000170301e0302303027030230302a0302f0302f0212f0212f0112f015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001c31429620002401a6201d414136200c615116150c6150261511615026150761500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000186433c610240230c0110c610006110061000615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001d134181201914118145161301a1411815419130181451b13418120191150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000016120181311a1412115121152211421f1321f1221d1441d1311d1211613116141181401b1301a14118155000000000000000000000000000000000000000000000000000000000000000000000000000
010a0000181241a130181401c1241d1201d1311a12018130191211c11018120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a000018134191201c141181401c1301d1401a1541f1311f145181341c1201c1150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000013125130731f5250002000011186142461122611206111e6111c6111a61118611166111461112611106110e6110c6110a611086110661104611026110061100610006150061400615006140061500615
0128000028e5028e4128e4028e3128e3028e212a8402b8502a8402a8312a8312a8212b8402a850268502683128e5028e5028e4128e4028e3128e302b8402b8302d8502d8412d8312b8502a8502a8412685026831
0128000023d5023d5023d5023d5023d50238402383123830238302385323850238502385023850238502385021d5021d5021d5021d5021d502184021840218312183021853218502185021850218502185021850
012800001f8501f8411e8401f8401f8401f8311f8301e8402184021831218431f8301f8301f8301f8301c8501d8501d8501c8501d8501d8501d8501d8501c8301f8401f8311f8531e8501e8501a8501a8501a850
012800002be502be502a8502b8502b8502f8502f831268402b8502b8532a8502b8502b8502f8502d8502b8502de502de402de312de302de212de202de112de102de102de102b85029850298412b8502b8412b831
0128000023d5023d5023d5023d5023d5023d5023d5023d50238402383123833238412385123850238502385023d5023d5023d50218501f8501f8501d8501f8501f8501f8501f8501f8501c8501c8501d8401d851
012800001c8501c8501c8501c8501c8501c8501a8301c8401e8401e8311e8301e8211e8531e8411d8401d8401c8601c8511c8501c8501c8501c8501c8501c8501a8301a8411a8511a8431a8511a8501a8501a850
010a00001785017850178411784017840178401784017840178311783017830178301783017830178211782017820178201782017820178111781017810178101781017810178101781017810178101781017810
010a0000008001c8501c8501c8411c8401c8411c8401c8401c8401c8311c8301c8301c8301c8301c8301c8211c8201c8201c8201c8201c8201c8111c8101c8101c8101c8101c8101c8101c8101c8101c8101c810
010a00000080000800218502185021841218402184121840218402184021831218302183021830218302183021821218202182021820218202182021811218102181021810218102181021810218102181021810
010a00000080000800008002684026840268312683026831268302683026830268212682026820268202682026820268202681126810268102681026810268102681026810268102681026810268102681026810
014000000994009951099710995109943099410997109941079400795107971079410794307941079610794105940059510597105951059430595105971059510794007951079710795107943079510797107941
012000202182023820248202882021820238202482028820218202382024820288202182023820248202882021820238202482028820218202382024820288202182023820248202882021820238202482028820
0120002023820268202a8202b82023820268202a8202b82023820268202a8202b82023820268202a8202b82021820268202882029820218202682028820298202182026820288202982021820268202882029820
014000001d7241d7311d7211d7111c7201c73118720187211a7201a7311a7111a7211a7111a711177201772118720187311872118711157201573118720187211772017731177211771117710177211771117710
01400000187201873118721187111872118711157201572117720177311771117721177111771118710187211572015731157211571115721157311872018721177201773117721177111c7341c7112173421721
014000001f7241f7311f7211f7111e7201a744177201e7201d7201d7311d7111d7211a7341a7211d7341d7211c7201c7311c7211c7111d7201c720187441c7201a7201a7311a7211a7111c7241c7311c7211c711
0110002021f1021f1023f1023f1024f1024f1028f1028f1021f2021f1023f2023f1024f2024f1028f2028f1021f3021f2023f3023f2024f3024f2028f3028f2021f4021f3023f4023f3024f4024f3028f4028f30
011000000791407910079100791007921079200792007920079200792007920079310793007930079300792107920079200793107930079410794007940079310793007930079410794007951079500795007931
0110000024543185230c5130051524f7023f7022f7021f7020f701ff701ef701df701cf701cf601cf501cf401cf301cf201cf101cf15000000000000000000000000000000000000000000000000000000000000
011000000053400541005210051118f7017f7016f7015f7014f7013f7012f7011f7010f7010f6010f5010f4010f3010f2010f1010f15000000000000000000000000000000000000000000000000000000000000
__music__
01 08 09 0a 44
00 08 0d 17 44
00 08 0b 0a 44
00 08 0c 16 44
00 08 11 17 44
00 14 12 0e 44
00 18 19 1a 44
00 1b 1c 1d 44
00 0f 13 10 44
02 08 15 17 44
02 32 33 34 35
01 2c 2d 2e 44
02 2f 30 31 44
01 3d 3c 43 44
01 36 37 39 44
01 36 37 3a 44
02 36 38 3b 44
00 3e 3f 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
