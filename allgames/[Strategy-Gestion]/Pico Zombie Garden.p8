pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--pico zombie garden
--by flyingsmog and gimbernau

--callbacks
poke(0x5600,unpack(split"8,8,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,63,63,63,63,63,63,63,0,0,0,63,63,63,0,0,0,0,0,63,51,63,0,0,0,0,0,51,12,51,0,0,0,0,0,51,0,51,0,0,0,0,0,51,51,51,0,0,0,0,48,60,63,60,48,0,0,0,3,15,63,15,3,0,0,62,6,6,6,6,0,0,0,0,0,48,48,48,48,62,0,99,54,28,62,8,62,8,0,0,0,0,24,0,0,0,0,0,0,0,0,0,12,24,0,0,0,0,0,0,12,12,0,0,0,10,10,0,0,0,0,0,4,10,4,0,0,0,0,0,0,0,0,0,0,0,0,12,12,12,12,12,0,12,0,0,54,54,0,0,0,0,0,0,54,127,54,54,127,54,0,8,62,11,62,104,62,8,0,0,51,24,12,6,51,0,0,14,27,27,110,59,59,110,0,12,12,0,0,0,0,0,0,24,12,6,6,6,12,24,0,12,24,48,48,48,24,12,0,0,54,28,127,28,54,0,0,0,12,12,63,12,12,0,0,0,0,0,0,0,12,12,6,0,0,0,62,0,0,0,0,0,0,0,0,0,12,12,0,32,48,24,12,6,3,1,0,62,99,115,107,103,99,62,0,24,28,24,24,24,24,60,0,63,96,96,62,3,3,127,0,63,96,96,60,96,96,63,0,51,51,51,126,48,48,48,0,127,3,3,63,96,96,63,0,62,3,3,63,99,99,62,0,127,96,48,24,12,12,12,0,62,99,99,62,99,99,62,0,62,99,99,126,96,96,62,0,0,0,12,0,0,12,0,0,0,0,12,0,0,12,6,0,48,24,12,6,12,24,48,0,0,0,30,0,30,0,0,0,6,12,24,48,24,12,6,0,30,51,48,24,12,0,12,0,0,30,51,59,59,3,30,0,0,0,62,96,126,99,126,0,3,3,63,99,99,99,63,0,0,0,62,99,3,99,62,0,96,96,126,99,99,99,126,0,0,0,62,99,127,3,62,0,124,6,6,63,6,6,6,0,0,0,126,99,99,126,96,62,3,3,63,99,99,99,99,0,0,24,0,28,24,24,60,0,48,0,56,48,48,48,51,30,3,3,51,27,15,27,51,0,12,12,12,12,12,12,56,0,0,0,99,119,127,107,99,0,0,0,63,99,99,99,99,0,0,0,62,99,99,99,62,0,0,0,63,99,99,63,3,3,0,0,126,99,99,126,96,96,0,0,62,99,3,3,3,0,0,0,62,3,62,96,62,0,12,12,62,12,12,12,56,0,0,0,99,99,99,99,126,0,0,0,99,99,34,54,28,0,0,0,99,99,107,127,54,0,0,0,99,54,28,54,99,0,0,0,99,99,99,126,96,62,0,0,127,112,28,7,127,0,62,6,6,6,6,6,62,0,1,3,6,12,24,48,32,0,62,48,48,48,48,48,62,0,12,30,18,0,0,0,0,0,0,0,0,0,0,0,30,0,12,24,0,0,0,0,0,0,14,15,31,27,63,55,51,3,15,31,27,63,63,55,62,30,28,62,55,3,3,27,31,14,30,62,55,103,99,115,63,31,30,31,3,15,15,7,62,62,60,62,2,31,31,3,3,3,30,63,55,3,59,51,63,30,102,102,103,127,127,115,51,51,60,60,24,24,24,12,30,30,127,24,24,24,24,24,15,0,99,51,27,15,27,51,99,0,3,3,3,3,3,3,127,0,51,55,127,107,99,99,99,99,99,103,111,127,123,119,102,102,30,59,51,51,51,55,63,30,63,99,99,63,3,3,3,0,62,99,99,99,99,51,110,0,30,62,54,54,31,31,59,51,62,99,3,62,96,99,62,0,63,12,12,12,12,12,12,0,99,99,99,99,99,99,62,0,99,99,99,99,54,28,8,0,99,99,99,107,127,119,99,0,99,99,54,28,54,99,99,0,99,99,99,126,96,96,63,0,62,63,48,28,14,6,63,31,56,12,12,7,12,12,56,0,8,8,8,0,8,8,8,0,14,24,24,112,24,24,14,0,0,0,110,59,0,0,0,0,0,0,0,0,0,0,0,0,127,127,127,127,127,127,127,0,85,42,85,42,85,42,85,0,65,99,127,93,93,119,62,0,62,99,99,119,62,65,62,0,17,68,17,68,17,68,17,0,4,12,124,62,31,24,16,0,28,38,95,95,127,62,28,0,34,119,127,127,62,28,8,0,42,28,54,119,54,28,42,0,28,28,62,93,28,20,20,0,8,28,62,127,62,42,58,0,62,103,99,103,62,65,62,0,62,127,93,93,127,99,62,0,24,120,8,8,8,15,7,0,62,99,107,99,62,65,62,0,8,20,42,93,42,20,8,0,0,0,0,85,0,0,0,0,62,115,99,115,62,65,62,0,8,28,127,28,54,34,0,0,127,34,20,8,20,34,127,0,62,119,99,99,62,65,62,0,0,10,4,0,80,32,0,0,17,42,68,0,17,42,68,0,62,107,119,107,62,65,62,0,127,0,127,0,127,0,127,0,85,85,85,85,85,85,85,0"))
cls()
poke(0x5f2d, 1)
cartdata("smgupzg")

function _init()
	music(0)
	game={
		state="play",
		mn=1,
		upd=u_s_menu,
		drw=d_s_menu,
		sun=60,
		shovelunlock=false,
		zt=600,
		ztmin=300,
		ztmax=1200,
		wzt=300,
		wztmax=300,
		level=1,
		howmany=1,
		progmax=0,
		az=0,
		mz=0,
		modes={{},{},{},{},},
		hmz=0,
		waveprep=false,
		wt=120,
		wtmax=120,
		fly=140,
		wy=140,
		won=false,
	}
	
	mouse={
		x=0,
		y=0,
		gx=0,
		gy=0,
		tab=0,
		p=0,
		ongrid=false,
		ontab=false,
		onshovel=false,
		canclick=false,
		shovel=false,
		plantselected=false,
		whichplant=0,
	}
	
	board={
		
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		
	}
	
	sundrop={
		t=90,
		tmax=300,
		group=""
	}
	
	
	suns={}
	
--{n,c,p,b}
	levels={
		{3,0,0,0,2,0,0,0},
		{7,0,0,0,4,0,0,0},
		{4,4,0,0,4,1,0,0},
		{6,6,0,0,7,1,0,0},
		{8,8,0,0,5,5,0,0},
		{12,1,2,0,5,1,1,0},
		{10,8,3,0,8,1,0,0,10,9,3,0,8,3,1,0},
		{10,3,0,1,4,1,0,1},
		{7,4,0,0,6,0,1,1,10,7,2,3,7,1,1,1},
		{16,10,1,4,10,1,3,2,24,15,5,10,20,5,4,4},
	}
	
	buyplant={
		{unlock=false,func=c_peashooter,price=40,cd=false,cdt=225,cdtmax=225},
		{unlock=false,func=c_sunflower,price=20,cd=false,cdt=225,cdtmax=225},
		{unlock=false,func=c_cherrybomb,price=60,cd=false,cdt=1500,cdtmax=1500},
		{unlock=false,func=c_wallnut,price=20,cd=false,cdt=900,cdtmax=900},
		{unlock=false,func=c_potmine,price=10,cd=false,cdt=900,cdtmax=900},
		{unlock=false,func=c_snowpea,price=70,cd=false,cdt=225,cdtmax=225},
		{unlock=false,func=c_chomper,price=60,cd=false,cdt=225,cdtmax=225},
		{unlock=false,func=c_repeater,price=80,cd=false,cdt=225,cdtmax=225},
	}
	
	psht={}
	sflw={}
	cbmb={}
	wnut={}
	ptmn={}
	snop={}
	chmp={}
	rptr={}
	
	allplants={psht,sflw,cbmb,wnut,ptmn,snop,chmp,rptr}
	
	lwmw={}
	
	zombies={}
	kzs={}
	
	peas={}
	cbmbexp={}
	powies={}
	ptmnp={}
	spudows={}
	
	--if (dget(1)<=0) game.level=dget(1)
	
end

function _update()
 game.upd()
end

function _draw()
	palt(0,false)
	palt(14,true)
	game.drw()
end
-->8
--states

function u_s_menu()
	u_mouse()
	
	local h=ccol(mouse.x,mouse.y,2,2,23,92,81,11)
	
	if (h) mouse.canclick=true
	
	if (mouse.canclick and mouse.click==1) game.upd=u_s_load game.drw=u_s_load
	
end

function d_s_menu()
	cls(12)
	
	d_background()
	d_lawn()
	
	local a="\014zombie"
	local b="\014garden"
	local aa="P\nI\nC\nO"
	
	
	oprint(a,ctx(a,3.5)-1,38,0,11)
	oprint(b,ctx(a,3.5),47,0,6)
	oprint(aa,32,35,8,7)
	
	local c="a demake of"
	local d="plants vs. zombies"
	local e="by flyingsmog and gimbernau"
	
	oprint(c,42,64,0,7)
	oprint(d,27,74,0,7)
	oprint(e,10,116,7,6)
	
	local clr=1
	
	local c="click here to start"
	if (mouse.canclick) clr=13
	nrectfill(23,92,81,11,0)
	nrectfill(23,91,81,11,15)
	nrectfill(24,92,79,9,clr)
	print(c,ctx(c,2),94,7)
	

	
	
	
	d_mouse()
	
end

function u_s_load()
	
	
	clear_stats()
	read_level()
	
	
	for i=1,5 do
		for j=1,8 do
			board[i][j]=0
		end
	end
	
	for a=1,#allplants do
		for b=1,#allplants[a] do
			allplants[a][b]=nil
		end
	end
	
	for kk=1,#peas do
		peas[kk]=nil
	end
	
	for aa=1,#kzs do
		kzs[aa]=nil
	end
	
	for bb=1,#suns do
		suns[bb]=nil
	end
	
	for cc=1,#zombies do
		zombies[cc]=nil
	end
	
	for cc=1,#buyplant do
		buyplant[cc].cdt=buyplant[cc].cdtmax
		buyplant[cc].cd=false
	end
	
	for z=1,#lwmw do
		lwmw[z]=nil
	end
	
	
	local fdirt={1,2,4,5}
	local stdirt={1,5}
	
	if game.level==1 then
		
		for k=1,4 do
			for l=1,8 do
				board[fdirt[k]][l]=10
			end
		end
		
		c_lawnmower(3)
		
	elseif game.level<4 then
		
		for m=1,2 do
			for n=1,8 do
				board[stdirt[m]][n]=10
			end
		end
		
		for l=2,4 do
			c_lawnmower(l)
		end
		
	else
		
		for w=1,5 do
			c_lawnmower(w)
		end
		
	end
	
	music(8)
	dset(1,game.level)
	game.upd=u_s_play
	game.drw=d_s_play
	
end

function d_s_load()
	cls(12)
end

function u_s_play()
	cls()
	
	change_modes()
	waves()
	
	_unlocks()
	
	c_sundrop()
	spawn_zombies()
	
	u_mouse()
	u_sundrop()
	u_putplantonboard()
	u_plantbuyer()
	u_shovel()
	
	local pf={u_peashooter,u_sunflower,u_cherrybomb,u_wallnut,u_potmine,u_snowpea,u_chomper,u_repeater}
	
	for i=1,#allplants do
		foreach(allplants[i],pf[i])
		foreach(allplants[i],u_dieplant)
	end
	
	foreach(lwmw,u_lawnmower)
	
	foreach(zombies,u_zombies)
	
	u_peas()
	
	
end

function d_s_play()
	
	rectfill(0,0,127,127,12)
	
	d_background()
	d_lawn()
	
	ui_progbar()
	ui_level()
	
	d_putplantonboard()

	
	for i=1,#allplants do
		foreach(allplants[i],d_plants)
	end
	
	foreach(lwmw,d_lawnmower)
	
	foreach(kzs,a_kill_zombie)
	foreach(zombies,d_zombies)
	
	p_cbmbexp()
	p_ptmnexp()
	p_powie()
	p_spudow()
	
	
	d_peas()
	
	d_sundrop()
	
	
	
	
	d_plantbuyer()
	d_shovel()
	
	d_wavecome()
	
	d_mouse()
	
	
	
end

function u_s_finishlevel()
	
	u_mouse()
	
	if game.fly>35 then
		game.fly+=.1*(37-game.fly)
	end
	
	local h=ccol(mouse.x,mouse.y,2,2,18,game.fly+36,92,9)
	
	if h then
		mouse.canclick=true
		
		if mouse.click==1 then
			
			if game.level==10
			and game.won then
				music(47)
				for i=1,#sflw do
					sflw[i]=nil
				end
				c_plants(2,4,4)
				game.upd=u_s_end
				game.drw=d_s_end
			else
				game.upd=u_s_load
				game.drw=d_s_load
			end
			
			if game.won then
				
				game.level+=1
				
			end
			
		end
		
	end
	
end

function d_s_finishlevel()
	
	d_s_play()
	
	local names={"sunflower","cherry bomb","wallnut","shovel","potato mine","snowpea","chomper","repeater"}
	local clr=1
	nrectfill(4,game.fly,120,50,0)
	nrectfill(5,game.fly+1,118,48,4)
	nrectfill(6,game.fly+2,116,46,15)
	
	if (mouse.canclick) clr=13
	
	nrectfill(18,game.fly+36,92,9,clr)
	
	if game.won then
		local aa="day complete!"
		local bb="yet another day awaits..."
		
		oprint(aa,ctx(aa,2),game.fly+5,7,12)
		
		if (game.level<=9) print(bb,ctx(bb,2),game.fly+25,1)
		local ccc="click here to continue"
		
		print(ccc,ctx(ccc,2),game.fly+38,7)
		
		if game.level<=8 then
			
			local a="you found the "..names[game.level].."!"
			
			
			
			print(a,ctx(a,2),game.fly+16,1,7)
			
		end
		
		if game.level==10 then
			local a="no more zombies around..."
			print(a,ctx(a,2),game.fly+20,1,7)
		end
		
	else
		
		local aa="oh no..."
		local bb="the zombies ate your brain!"
		local cc="click to try again"
		
		oprint(aa,ctx(aa,2),game.fly+5,3,11)
		print(bb,ctx(bb,2),game.fly+22,3)
		print(cc,ctx(cc,2),game.fly+38,7)
	end
	
	d_mouse()
	
end

function u_s_end()
	
end

function d_s_end()
	cls()
	local a="you beat the zombies!"
	local b="thanks for playing!"
	
	foreach(sflw,d_plants)
	oprint(a,ctx(a,2),30,1,7)
	oprint(b,ctx(b,2),40,1,7)
	
end
-->8
--updates

function u_mouse()
	
	mouse.x=stat(32)
	mouse.y=stat(33)
	mouse.click=stat(34)
	mouse.plant=nil
	
	if (mouse.canclick) mouse.canclick=false
	
	if game.upd==u_s_play then
		local g=ccol(mouse.x,mouse.y,1,1,10,32,112,80)
		
		if g then
			mouse.ongrid=true
			mouse.gx=flr((mouse.x+4)/14)
			mouse.gy=flr(mouse.y/16)-1
		else
			mouse.gx,mouse.gy=nil,nil
			mouse.ongrid=false 
		end
		
		local t=ccol(mouse.x,mouse.y,1,1,3,3,111,18)
		
		if t then
			
			mouse.ontab=true
			mouse.tab=flr(((mouse.x-3)/14)+1)
			
		else
			mouse.ontab=false
			mouse.tab=nil
		end
		
	end
	
	if mouse.plantselected
	and (mouse.click==2 or game.upd==u_s_finishlevel) then
		mouse.whichplant=nil
		mouse.plantselected=false
	end
	
end

function u_sundrop()
	
	for i,sun in pairs(suns) do
		
		sun.t-=1
		
		if sun.group=="drop" then
			
			sun.a+=0.01
			
			if sun.y<sun.yf then
				sun.y+=sun.v
				sun.x+=0.1*cos(sun.a)
			end
			
			if (sun.a==1) sun.a=0
			
		elseif sun.group=="sflw" then
			
			if sun.y<sun.yf then
				sun.x+=0.2*cos(sun.a)
				sun.y+=sun.v
				sun.v+=0.25
			end
			
			
		end
		
		local c=ccol(mouse.x,mouse.y,2,2,sun.x,sun.y,8,8)
		
		if c
		and not mouse.plantselected
		and not mouse.ontab 
		and not mouse.shovel then
			mouse.canclick=true
			if  mouse.click==1 then
				del(suns,suns[i])
				game.sun+=10
			end
		end
		
		if sun.t<0 then
			del(suns,suns[i])
		end
		
	end
	
end

function u_plantbuyer()
	
	for i=1,#buyplant do
		
		if buyplant[i].cd then
			buyplant[i].cdt-=1
			
			if buyplant[i].cdt<0 then
				buyplant[i].cd=false
				buyplant[i].cdt=buyplant[i].cdtmax
			end
			
		end
		
		if buyplant[i].unlock
		and mouse.ontab
		and mouse.tab==i
		and game.sun>=buyplant[i].price
		and not mouse.shovel
		and not buyplant[i].cd then
			
			mouse.canclick=true
			
			if not mouse.plantselected then
				
				if mouse.click==1 then
					
					mouse.whichplant=i
					mouse.plantselected=true
					
				end
				
			end
			
		end
		
	end
	
end

function u_putplantonboard()
	
	if mouse.ongrid
	and mouse.plantselected then
		
		if board[mouse.gy][mouse.gx]==0 then
			mouse.canclick=true
		end
		
		if mouse.canclick
		and mouse.click==1 then
			board[mouse.gy][mouse.gx]=mouse.whichplant
			
			game.sun-=buyplant[mouse.whichplant].price
			
			buyplant[mouse.whichplant].cd=true
			
			buyplant[mouse.whichplant].cd=true
			
			c_plants(mouse.whichplant,mouse.gx,mouse.gy)
			
			mouse.plantselected=false
			
			mouse.whichplant=nil
			
		end
		
	end
	
end

function u_shovel()
	
	if game.shovelunlock then
		local h=ccol(mouse.x,mouse.y,2,2,116,4,9,16)
		
		if h 
		and not mouse.plantselected 
		and not mouse.shovel then
			mouse.canclick=true
			mouse.onshovel=true
			
			if mouse.click==1 then
				mouse.shovel=true
			end
		else
			mouse.onshovel=false
		end
		
		if mouse.shovel then
			
			if mouse.ongrid
			and mouse.click==1
			and board[mouse.gy][mouse.gx]!=10
			and board[mouse.gy][mouse.gx]!=0 then
				board[mouse.gy][mouse.gx]=0
				
				
				
				for i=1,#allplants do
					for j,p in pairs(allplants[i]) do
						if mouse.gx==p.gx
						and mouse.gy==p.gy then
							del(allplants[i],p)
						end
					end
				end
				
				mouse.shovel=false
				
			end
			
			if mouse.click==2 then
				mouse.shovel=false
			end
			
		end
		
		
	end
	
end

function u_peashooter(p)
	
	
	for j=1,#zombies do
		
		if zombies[j].lane==p.lane
		and zombies[j].x<120 then
			p.zol=true
		end
		
	end
	
	if p.zol then
		
		p.t-=1
		
		if p.t<0 then
			
			c_peas("norm",p.x,p.y,p.lane)
			p.t=p.tmax
			
		end
		
		p.zol=false
		
	else
		
		p.t=p.tmax
		
	end
	
end

function u_peas()
	
	for i,pea in pairs(peas) do
		
		pea.x+=pea.v
		
		if (pea.x>130) peas[i]=nil
		
		for j,z in pairs(zombies) do
			
			local h=ccol(pea.x,pea.y,pea.wh,pea.wh,z.x,z.y,11,22)
			
			if h then
				del(peas,pea)
				z.health-=pea.dmg
				z.c=7
				if pea.g=="snow" then
					z.etmax=60
					z.fv=2
					z.oc=12
				end
				break
			end
			
		end
		
	end
	
end

function u_sunflower(s)
	
	
	s.t-=1
	
	if s.t<0 then
		
		c_sflwdrop(s.x,s.y)
		s.t=s.tmax
		
	end
	
end

function u_cherrybomb(c)
	
	
	c.t-=1
	
	if c.t<=0 then
		
		local clr={}
		
		for n=1,30 do
			newexp={x=c.x+6,y=c.y+6,vx=rnd(3)-1.5,vy=rnd(3)-1.5,r=10,c=9}
			add(cbmbexp,newexp)
		end
		
		newpowie={x=c.x-4,y=c.y+3,t=30}
		add(powies,newpowie)
		
		
		for i,z in pairs(zombies) do 
			
			local h=ccol(c.x-14,c.y-16,42,48,z.x,z.y,14,22)
			
			if h
			and (z.lane>=(c.lane-1) and z.lane<=(c.lane+1)) then
				z.health-=c.dmg
			end
			
		end
		
		del(cbmb,c)
		board[c.gy][c.gx]=0
		
	end
	
end

function u_wallnut(w)
	
	
end

function u_potmine(p)
	
	
	if p.t>0 then
		p.t-=1
	else
		p.health=100
		for j,z in pairs(zombies) do
			
			local h=ccol(p.x,p.y,p.w,p.h,z.x,z.y,14,22)
			
			if p.t==0 then
				if h
				and z.lane==p.lane then
					
					z.health-=p.dmg
					del(ptmn,p)
					board[p.gy][p.gx]=0
					
					local c={2,4,10,15}
					for m=1,30 do
						newp={x=p.x+6,y=p.y+8,a=rnd(),c=c[ceil(rnd(#c))],r=rnd(4)+2}
						add(ptmnp,newp)
					end
					
					newspudow={x=p.x-6,y=p.y,t=30}
					add(spudows,newspudow)
					
				end
				
			end
			
		end
		
	end
	
end

function u_snowpea(s)
	
	for j=1,#zombies do
		
		if zombies[j].lane==s.lane
		and zombies[j].x<120 then
			s.zol=true
		end
		
	end
	
	
	if s.zol then
		
		s.t-=1
		
		if s.t<0 then
			
			c_peas("snow",s.x,s.y,s.lane)
			s.t=s.tmax
			
		end
		
		s.zol=false
		
	else
		
		s.t=s.tmax
		
	end
	
end

function u_chomper(c)
	
	if c.t<=0 then
		
		for i,z in pairs(zombies) do
			
			if c.lane==z.lane then
				
				local h=ccol(c.x,c.y,c.w+14,c.h,z.x,z.y+10,2,2)
				
				if h 
				and (z.jumped==nil or z.jumped==true) then
					c.prept-=1
					if c.prept<0 then
						del(zombies,z)
						c.t=c.tmax
						c.prept=c.preptmax
					end
				end
				
			end
				
		end
		
	else
		
		c.t-=1
		
	end
	
end

function u_repeater(r)
	
	for j=1,#zombies do
		
		if zombies[j].lane==r.lane
		and zombies[j].x<120 then
			r.zol=true
		end
		
	end
	
	if r.zol then
		
		r.t-=1
		
		if r.t==0
		or r.t==10 then
			
			c_peas("norm",r.x,r.y,r.lane)
			
			
		end
		
		if (r.t<0) r.t=r.tmax
		
		r.zol=false
		
	else
		
		r.t=r.tmax
		
	end
	
end

function u_dieplant(p)
	
	if p.health<=0 then
		board[p.gy][p.gx]=0
		del(p.tbl,p)
	end
	
end

function u_zombies(z)
	
	if z.x<=-15 then
		sfx(37)
		game.upd=u_s_finishlevel
		game.drw=d_s_finishlevel
		
	end
	
	if z.health<=-50 then
		c_kill_zombie(z,"e") 
		del(zombies,z) 
	elseif z.health<=0 then
		c_kill_zombie(z,"n") 
		del(zombies,z) 
	end
	
	if (z.which=="p" and z.jumped) then
		z.a=0.02 z.na=0.1
	end
	
	if (z.which!="p" and not z.h)
	or (z.which=="p" and not z.jumping and not z.h) then
		
		z.v+=z.a
		z.x-=(z.na+0.1*cos(z.v))/z.fv
		
		if (z.v>1) z.v=0 
		
	end
	
	z.il={}
	z.mx=0
	z.hp=nil
	z.h=false
	z.eating=false
	
	for i,t in pairs(allplants) do
		
		for j,p in pairs(allplants[i]) do
			
			if z.lane==p.lane then
				add(z.il,p)
			end
			
			for k=1,#z.il do
				
				if z.x>=z.il[k].x then
					z.mx=max(z.il[k].x,z.mx)
				end
				
				if z.il[k].x==z.mx then
					z.hp=z.il[k]
				end
				
			end
			
			if z.hp!=nil then
				
				z.h=ccol(z.hp.x,z.hp.y,z.hp.w,z.hp.h,z.x,z.y+10,2,2)
				
			else
				
				z.h=false
				
			end
			
			
			
		end
		
	end
	
	if z.h
	and z.hp!=nil then
		
		if z.which!="p"
		or (z.jumped) then
			z.et-=1
			z.eating=true
			if z.et<=0 then
				z.hp.health-=1
				z.hp.c=7
				z.et=z.etmax
			end
		else
			
			--z.x-=16
			z.yoffset=5
			z.xoffset=16
			z.jumping=true
			
		end
	end
	
end

function u_lawnmower(l)
	
	for i,z in pairs(zombies) do
		
		local h=ccol(l.x,l.y,13,9,z.x,z.y,13,20)
		
		if h
		and z.lane==l.lane then
			del(zombies,z)
			l.go=true
		end
		
	end
	
	if (l.go) l.x+=l.v
	
	if (l.x>130) del(lwmw,l)
	
end
-->8
--draws

function d_background()
	
	line(0,25,120,25,7)
	line(0,26,120,26,6)
	line(0,29,120,29,6)
	
	for i=0,8 do
		sspr(96,32,7,16,i*14+3,16,7,16)
	end
	
	rectfill(0,32,9,111,7)
	rect(-1,32,9,112,6)
	
	for j=1,5 do
		line(0,32+16*j,9,32+16*j,6)
	end
	
	rectfill(122,32,127,111,7)
	rect(122,32,128,112,6)
	
	for k=1,6 do
		line(122,32+12*k,127,32+12*k,6)
	end
	
	rectfill(0,112,127,127,7)
	fillp(„)
	--rectfill(4,32,9,111,6)
	--rectfill(123,32,126,111,6)
	rectfill(0,122,127,127,6)
	fillp()
	line(0,112,127,112,6)
	for i=1,16 do
		line(i*8,112,i*8,127,6)
	end
	--print("level 7",98,114,7)

	
	
end

function ui_level()
	local a=tostr(game.level)
	oprint("day "..a,40-#a*2,117,1,1)
	oprint("day "..a,40-#a*2,116,4,15)
end

function ui_progbar()
	
	local fn=0
	local sn=0
	local fnmax=0
	local snmax=0
	
	for i=1,4 do
		fn+=game.modes[1][i]
		fnmax+=levels[game.level][i]
		
		if levels[game.level][9]!=nil then
			sn+=game.modes[3][i]
			snmax+=levels[game.level][i+8]
		end
		
	end
	
	a=50*(fn/fnmax)
	
	if levels[game.level][9]!=nil then
		a=25*(fn/fnmax)+25*(sn/snmax)
	end
	
	nrectfill(70,116,56,10,1)
	nrectfill(70,115,56,10,4)
	
	nrectfill(71,116,54,8,15)
	nrectfill(72,117,52,6,1)
	
	nrectfill(73,118,50,4,11)
	line(74,121,121,121,3)
	
	if (a>0) nrectfill(73,118,a,4,13)
	
	local os=0
	if (a==50) os=-6
	if (a==0 or (a==25 and fn==0)) os=7
	
	ospr(1,10,64,9,9,72+a+os,117,6,6)
	
	ospr(1,96,0,11,16,74,117,4,8)
	
	if levels[game.level][9]!=nil then
		ospr(1,96,0,11,16,97,117,4,8)
	end
	
end

function d_lawn()
	
	rectfill(10,32,121,111,11)
	for y=1,5 do
		for x=1,8 do
			
			local xp={36,0,50,0,36,0,50,0}
			local xi={0,8,0,22,0,8,0,22}
			local yy={xi,xp,xi,xp,xi}
			local xxx=10+14*(x-1)
			local yyy=32+16*(y-1)
			if yy[y][x]!=0 then
				sspr(yy[y][x],112,14,16,10+14*(x-1),32+16*(y-1),14,16)
			end
			
			if (board[y][x]==10) then
				rectfill(xxx,yyy,9+14*x,31+16*y,4)
				fillp(•)
				rectfill(xxx,yyy,9+14*x,31+16*y,5)
				fillp()
			end
			
		end
	end
	
	
end


function d_mouse()
	
	if mouse.plantselected then
		spr(48,mouse.x,mouse.y)
	elseif mouse.canclick then
		spr(32,mouse.x,mouse.y)
	elseif mouse.shovel then
		ospr(1,0,32,8,8,mouse.x,mouse.y-7,8,8,false,false)
	else
		spr(16,mouse.x,mouse.y)
	end
	
end

function d_wavecome()
	
	if game.waveprep then
		
		if game.wt>0 then
			
			if game.wy>60 then
				game.wy+=.1*(62-game.wy)
			end
			
			game.wt-=1
			local a="huge wave of zombies incoming!"
			oprint(a,ctx(a,2),game.wy,0,8)
		else
			game.wy=140
		end
		
	end
end

function d_sundrop()
	
	for i,sun in pairs(suns) do
		
		if sun.t>120
		or sun.t%6==0 then
			spr(192,sun.x,sun.y)
		end
		
	end
	
	--sun counter
	local a=tostr(game.sun)
	nrectfill(1,116,26,10,1)
	nrectfill(1,115,26,10,4)
	nrectfill(11,116,15,7,15)
	spr(192,2,116)
	print(game.sun,19-#a*2,117,1)
	
end

function d_putplantonboard()
	
	if mouse.plantselected
	and mouse.ongrid
	and board[mouse.gy][mouse.gx]==0 then
		rect(9+14*(mouse.gx-1),31+16*(mouse.gy-1),10+14*mouse.gx,32+16*mouse.gy,7)
	end
	
	
end

function d_plantbuyer()
	
	nrectfill(1,2,115,22,1)
	nrectfill(115,3,11,19,1)
	nrectfill(1,1,115,22,4)
	
	nrectfill(115,2,11,19,4)
	--nrectfill(2,3,113,21,2)
	--nrect(2,2,124,24,4)
	
	
	--plant buttons
	
	for i=1,#buyplant do
		
		local x=3+14*(i-1)
		
		nrectfill(x,3,13,19,1)
		nrectfill(x,2,13,19,5)
		nrectfill(x+1,3,11,17,2)
		
		if buyplant[i].unlock then
			
			
			
			nrectfill(x,2,13,19,13)
			nrectfill(x+1,3,11,17,15)
			
			
			if buyplant[i].cd then
				nrectfill(x+1,19,11,-(15*ceil(buyplant[i].cdt)/buyplant[i].cdtmax),5)
			end
			
			
			if mouse.whichplant==i then
				nrect2(x-1,1,15,21,10)
			end
			
			ospr(1,0,40+7*(i-1),7,7,x+3,5,7,7,false,false)
			
			local c=1
			
			if (game.sun<buyplant[i].price) c=8
			
			print(buyplant[i].price,x+3,14,c)
		end
		
		
	end
	
	--which button mouse is
	
	if mouse.ontab
	and not mouse.plantselected
	and not mouse.shovel
	and buyplant[mouse.tab].unlock then
		local xx=3+14*(mouse.tab-1)
		nrect2(xx-1,1,15,21,7)
	end 
	
	
end

function d_shovel()
	
	nrectfill(116,3,9,17,2)
	
	if game.shovelunlock then
		
		nrectfill(116,3,9,17,15)
		ospr(1,0,108,5,12,118,6,5,12,false,false)
		
		if mouse.onshovel then
			nrect2(115,2,11,19,7)
		end
		
		if mouse.shovel then
			nrect2(115,2,11,19,10)
		end
		
		if mouse.shovel
		and mouse.ongrid
		and board[mouse.gy][mouse.gx]!=10
		and board[mouse.gy][mouse.gx]!=0 then
			rect(9+14*(mouse.gx-1),31+16*(mouse.gy-1),10+14*mouse.gx,32+16*mouse.gy,7)
		end
		
	end
	
end

function d_plants(p)
	
	ospr(p.c,p.sx,p.sy,11,13,p.x,p.y,11,13,false,false)
	
	if (p.c==7) p.c=0
	
	p.anifunc(p)
	
end

function d_peas()
	
	for i,pea in pairs(peas) do
		
		local o=0
		
		if (pea.g=="snow") o=4
		
		ospr(0,0+o,104,4,4,pea.x,pea.y,pea.wh,pea.wh,false,false)
	end
	
end

function d_zombies(z)
	
	sort(zombies,lanecomp)
	
	local offset=0
	local offw=0
	
	z.anit+=1
	
	z.sx=8
	z.sy=64
	
	z.ox=0
	
	if (z.which=="p") offset=22
	if (z.jumping) z.anit=0 z.sx=103 z.sy=30 offset=0 offw=4
	
	
	if z.eating then
		z.sx=47
		if (z.anit>15) z.sx=60
		if (z.anit>30) z.anit=0
	else
		if (z.anit>25) z.sx=21 z.ox=1
		if (z.anit>45) z.sx=34
		if (z.anit>55) z.anit=0
	end
	ospr(z.c,z.sx,z.sy+offset,13+offw,22,z.x,z.y,13,22,false,false)
	
	z.anifunc(z)
	
	if (z.c==7) z.c=z.oc
	
end

function p_cbmbexp()
	
	for i,e in pairs(cbmbexp) do
		e.x+=e.vx
		e.y+=e.vy
		e.r-=0.5
		
		if (e.r<0) cbmbexp[i]=nil
		circfill(e.x,e.y,e.r,e.c)
		circ(e.x,e.y,e.r,5)
	end
	
end

function p_powie()
	
	for i,p in pairs(powies) do
		p.t-=1
		
		oprint("powie!",p.x,p.y,7,8)
		
		if (p.t<0) powies[i]=nil
		
	end
	
end

function p_ptmnexp()
	
	for j,p in pairs(ptmnp) do
		
		p.r-=0.4
		p.x+=2*cos(p.a)
		p.y+=2*(-abs(sin(p.a)))
		
		if (p.r<0) ptmnp[j]=nil
		
		circfill(p.x,p.y,p.r,p.c) 
		circ(p.x,p.y,p.r,0) 
		
	end
	
end

function p_spudow()
	
	for i,s in pairs(spudows) do
		s.t-=1
		ospr(0,52,39,11,13,s.x+6,s.y,11,13)
		oprint("spudow!",s.x,s.y,4,15)
		
		if (s.t<0) spudows[i]=nil
		
	end
	
end

function d_lawnmower(l)
	ospr(0,96,17,13,9,l.x,l.y,13,9,false,false)
end

function a_peashooter(p)
	
	p.anit+=1
	
	if p.anit>15 then 
		p.sy=13
	else
		p.sy=0
	end
	
	if (p.anit==30) p.anit=0
	if (p.t<=0) p.anit=0 p.sy=26
	
	
end

function a_sunflower(p)
	
	
	p.anit+=1
	
	if p.anit>15 then
		p.sy=13
	else
		p.sy=0
	end
	
	if (p.t<=60) p.sy=26
	if (p.anit==30) p.anit=0
	
end

function a_cherrybomb(p)
	
	if (p.t%3==0) p.c=7
	
	
	if (p.t<24) p.sy=13
	if (p.t<12) p.sy=26
	
end

function a_wallnut(p)
	
	local l={4,5}
	local r={8,9}
	local os=0
	p.anit+=1
	
	if (p.anit>30) os=1
	
	if (p.anit>60) p.anit=0
	
	pset(p.x+4+os,p.y+4,0)
	pset(p.x+8+os,p.y+4,0)
	
	if p.health<18 then
		p.sy=26
	elseif p.health<36 then
		p.sy=13
	end
	
end

function a_potmine(p)
	
	local t={0,45,450}
	local y={26,13,0}
	
	if p.t==0 then
		
		p.sy=26
		
		if p.anit>0 then
			p.anit-=1
			
			if p.anit<=(25)
			and p.anit!=(10 or 11 or 12) then
				line(p.x+5,p.y+4,p.x+5,p.y+5,8)
				--ovalfill(p.x+4,p.y+3,p.x+6,p.y+6,8)
			end
			
		else
			p.anit=30
		end
		
	elseif p.t<=45 then
		
		p.sy=13
		
	else
		p.sy=0
	end
	
	
end

function a_snowpea(p)
	
	p.anit+=1
	
	if p.anit>15 then 
		p.sy=13
	else
		p.sy=0
	end
	
	if (p.anit==30) p.anit=0
	if (p.t<=0) p.anit=0 p.sy=26
	
	
end

function a_chomper(p)
	
	p.anit+=1
	
	if p.prept==p.preptmax
	and p.t<=0 then
		p.sx=74
		if p.anit>15 then 
			p.sy=13
		else
			p.sy=0
		end
	elseif p.prept!=p.preptmax
	and p.t<=0 then
		
		if p.prept>15 then
			p.sy=26
		else
			p.sx=63
			p.sy=39
		end
		
	else
		p.prept=p.preptmax
		if p.anit>15 then
			p.sx=74
		else
			p.sx=85
		end
		
	end
	
	if (p.anit==30) p.anit=0
	
end

function a_repeater(p)
	
	p.anit+=1
	
	if p.anit>15 then 
		p.sy=13
	else
		p.sy=0
	end
	
	if (p.anit==30) p.anit=0
	if (p.t<=0) p.anit=0 p.sy=26
	
	
end

function a_nz(z)
	
end

function a_cz(z)
	
	local offset=0
	
	if (z.health<22) offset=1
	if (z.health<16) offset=2
	
	if z.health>10 then
		ospr(z.c,111,0+8*offset,8,8,z.x+4,z.y-7+z.ox,8,8,false)
	end
	
end

function a_pz(z)
	
	if z.jumping then
		z.y-=z.yoffset
		z.yoffset-=0.5
		z.x-=1
		if z.y>=(24+16*(z.lane-1)) then
			z.y=24+16*(z.lane-1)
			z.jumping=false
			z.jumped=true
		end
		line(xx,yy,z.x+4,z.y+8,1)
	elseif not z.jumped then
		
		ospr(0,120,32,5,8,z.x,z.y+3,5,8)
		
		xx=z.x-4 
		yy=z.y+22
		
		line(z.x-10,z.y+3,z.x+1,z.y+3,1)
		line(z.x+12,z.y+3,z.x+20,z.y+3,1)
		
	elseif not z.eating then
		sspr(120,40,5,4,z.x-1,z.y+10,5,4)
	end
	
	local xx=nil
	local yy=nil
end

function a_bz(z)
	
	local offset=0
	
	if (z.health<47) offset=1
	if (z.health<27) offset=2
	
	if z.health>10 then
		ospr(z.c,119,0+9*offset,9,9,z.x+6,z.y-5+z.ox,9,9,false,false)
	end
	
end

function a_fz(z)
	ospr(z.c,96,0,11,17,z.x-2,z.y-7,11,17,false,false)
end

function a_kill_zombie(z)
	
	z.anit-=1
	local os=0
	if z.die=="n" then
		if (z.which=="p") os=22
		if (z.anit<30) z.sx=87 z.w=24 z.xos=-10 z.yos=14
		ospr(0,z.sx,z.sy+os,z.w,22,z.x+z.xos,z.y+z.yos,z.w,22)
	else
		sspr(z.sx,z.sy,z.w,22,z.x+z.xos,z.y+z.yos,z.w,22)
		if (z.anit<40) z.sx=21
		if (z.anit<20) z.sx=34
	end
	
	
	if (z.anit<=0) del(kzs,z)
	
end
--
--function d_zombiecome()
--	
--	if game.zct>0 then
--		if (game.zcy<50) game.zcy+=.1*(48-game.zcy)
--		local a="zombies are coming!"
--		oprint(a,ctx(a,2),game.zcy,0,8)
--		game.zct-=1
--	else
--		game.zcy=-10
--	end
--	
--	
--end
-->8
--pre-mades and functional

function ccol(x1,y1,w1,h1,x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function ospr(col,sx,sy,sw,sh,dx,dy,dw,dh,flip_x,flip_y)
  -- reset palette to black
  for c=0,15 do
    pal(c,col)
  end
  -- draw outline
  for xx=-1,1 do
    for yy=-1,1 do
      sspr(sx,sy,sw,sh,dx+xx,dy+yy,dw,dh,flip_x,flip_y)
    end
  end
  -- reset palette
  pal()
  palt(0,false)
  palt(14,true)
  -- draw final sprite
  sspr(sx,sy,sw,sh,dx,dy,dw,dh,flip_x,flip_y)
end

function oprint(s,x,y,c1,c2)
	for i=0,2 do
	 for j=0,2 do
	  if not(i==1 and j==1) then
	   print(s,x+i,y+j,c1)
	  end
	 end
	end
	print(s,x+1,y+1,c2)
end

function nrectfill(x,y,w,h,c1)
	
	local vx={x,x+w-1,x,x+w-1}
	local vy={y,y,y+h-1,y+h-1}
	local c={}
	for i=1,4 do
		c[i]=pget(vx[i],vy[i])
	end
	
	rectfill(x,y,x+w-1,y+h-1,c1)
	
	for j=1,4 do
		
		pset(vx[j],vy[j],c[j])
		
	end
	
end

function nrect(x,y,w,h,c1)
	
	local vx={x,x+w-1,x,x+w-1}
	local vy={y,y,y+h-1,y+h-1}
	local c={}
	for i=1,4 do
		c[i]=pget(vx[i],vy[i])
	end
	
	rect(x,y,x+w-1,y+h-1,c1)
	
	for j=1,4 do
		
		pset(vx[j],vy[j],c[j])
		
	end
	
end

function nrect2(x,y,w,h,c1)
	
	local lx1={x+2,x+w-1,x+2,x}
	local ly1={y,y+2,y+h-1,y+2}
	local lx2={x+w-3,x+w-1,x+w-3,x}
	local ly2={y,y+h-3,y+h-1,y+h-3}
	local px={x+1,x+w-2,x+1,x+w-2}
	local py={y+1,y+1,y+h-2,y+h-2}
	
	for j=1,4 do
		
		line(lx1[j],ly1[j],lx2[j],ly2[j],c1)
		
		pset(px[j],py[j],c1)
		
	end
	
end

function lanecomp(a,b)
	
	return a.lane>b.lane
	
end

function sort(list,comp)
	
	for i=2,#list do
		
		local j=i
		while j>1 and comp(list[j-1],list[j]) do
			list[j],list[j-1]=list[j-1],list[j]
			j-=1
		end
		
	end
	
end

function ctx(s,n)
	return 64-#s*n
end
-->8
--creates

function c_sundrop()
	
	sundrop.t-=1
	
	if sundrop.t<0 then
		
		newsun={
			group="drop",
			x=flr(rnd(90)+10),
			y=28,
			v=0.25,
			yf=flr(rnd(70)+38),
			a=0,
			t=1200,
		}
		add(suns,newsun)
		sundrop.t=sundrop.tmax
	end
	
end

function c_plants(_n,_x,_y)
	
	new={
		{
			tbl=psht,
			anifunc=a_peashooter,
			sx=8,
			sy=0,
			x=11+14*(_x-1),
			y=33+16*(_y-1),
			gx=_x,
			gy=_y,
			w=11,
			h=13,
			lane=_y,
			zol=true,
			health=6,
			t=45,
			tmax=45,
			anit=0,
			c=0,
		},
		{
			tbl=sflw,
			anifunc=a_sunflower,
			sx=19,
			sy=0,
			x=11+14*(_x-1),
			y=33+16*(_y-1),
			gx=_x,
			gy=_y,
			w=11,
			h=13,
			lane=_y,
			health=6,
			t=180,
			tmax=720,
			anit=0,
			c=0,
		},
		{
			tbl=cbmb,
			anifunc=a_cherrybomb,
			sx=30,
			sy=0,
			x=11+14*(_x-1),
			y=33+16*(_y-1),
			gx=_x,
			gy=_y,
			w=11,
			h=13,
			lane=_y,
			dmg=90,
			health=200,
			t=36,
			anit=1,
			c=0,
		},
		{
			tbl=wnut,
			anifunc=a_wallnut,
			sx=41,
			sy=0,
			x=11+14*(_x-1),
			y=33+16*(_y-1),
			gx=_x,
			gy=_y,
			w=11,
			h=13,
			lane=_y,
			health=72,
			anit=0,
			e=1,
			c=0,
		},
		{
			tbl=ptmn,
			anifunc=a_potmine,
			sx=52,
			sy=0,
			x=11+14*(_x-1),
			y=33+16*(_y-1),
			gx=_x,
			gy=_y,
			w=11,
			h=13,
			lane=_y,
			dmg=200,
			health=6,
			t=450,
			anit=1,
			c=0,
		},
		{
			tbl=snop,
			anifunc=a_snowpea,
			sx=63,
			sy=0,
			x=11+14*(_x-1),
			y=33+16*(_y-1),
			gx=_x,
			gy=_y,
			w=11,
			h=13,
			lane=_y,
			zol=true,
			health=6,
			t=45,
			tmax=45,
			anit=0,
			c=0,
		},
		{
			tbl=chmp,
			anifunc=a_chomper,
			sx=74,
			sy=0,
			x=11+14*(_x-1),
			y=33+16*(_y-1),
			gx=_x,
			gy=_y,
			w=11,
			h=13,
			lane=_y,
			zol=true,
			health=6,
			eat=false,
			t=0,
			prept=30,
			preptmax=30,
			tmax=1260,
			anit=0,
			c=0,
		},
		{
			tbl=rptr,
			anifunc=a_repeater,
			sx=85,
			sy=0,
			x=11+14*(_x-1),
			y=33+16*(_y-1),
			w=11,
			h=13,
			gx=_x,
			gy=_y,
			lane=_y,
			zol=true,
			health=6,
			t=45,
			tmax=45,
			anit=0,
			c=0,
		},
	}
	
	add(allplants[_n],new[_n])
	
end


function c_peas(_group,_x,_y,_lane)
	
	newpea={
		g=_group,
		x=_x+9,
		y=_y+1,
		v=2,
		wh=4,
		dmg=1,
		lane=_lane,
	}
	add(peas,newpea)
	
end

function c_sflwdrop(_x,_y)
	
	newsun={
		group="sflw",
		x=_x+4,
		y=_y+2,
		v=-2,
		yf=_y+7,
		a=rnd(),
		t=1200,
	}
	
	add(suns,newsun)
	
end

function c_zombies(_w)
	
	local ly=0
	
	if (game.level==1) ly=3
	if (game.level==2 or game.level==3) ly=1+ceil(rnd(3))
	if (game.level>3) ly=ceil(rnd(5))
	newzombie={
		{
			which="n",
			anifunc=a_nz,
			eating=false,
			x=130,
			y=24+16*(ly-1),
			sx=8,
			sy=64,
			lane=ly,
			health=10,
			v=1,
			a=0.02,
			na=0.1,
			fv=1,
			et=30,
			etmax=30,
			c=0,
			oc=0,
			anit=0,
		},
		{
			which="c",
			anifunc=a_cz,
			eating=false,
			x=130,
			y=24+16*(ly-1),
			sx=8,
			sy=64,
			ox=0,
			lane=ly,
			health=28,
			v=1,
			a=0.02,
			na=0.1,
			fv=1,
			et=30,
			etmax=30,
			c=0,
			oc=0,
			anit=0,
		},
		{
			which="p",
			anifunc=a_pz,
			eating=false,
			x=130,
			y=24+16*(ly-1),
			sx=8,
			sy=64,
			lane=ly,
			health=17,
			v=1,
			a=0.04,
			na=0.2,
			fv=1,
			et=30,
			etmax=30,
			c=0,
			oc=0,
			jumping=false,
			jumped=false,
			yoffset=0,
			xoffset=0,
			anit=0,
		},
		{
			which="b",
			anifunc=a_bz,
			eating=false,
			x=130,
			y=24+16*(ly-1),
			sx=8,
			sy=64,
			ox=0,
			lane=ly,
			health=65,
			v=1,
			a=0.02,
			na=0.1,
			fv=1,
			et=30,
			etmax=30,
			c=0,
			oc=0,
			anit=0,
		},
		{
			which="f",
			anifunc=a_fz,
			eating=false,
			x=130,
			y=24+16*(3-1),
			sx=8,
			sy=64,
			lane=3,
			health=10,
			v=1,
			a=0.025,
			na=0.125,
			fv=1,
			et=30,
			etmax=30,
			c=0,
			oc=0,
			anit=0,
		},
	}
	
	for i=1,#newzombie do
		if newzombie[i].which==_w then
			add(zombies,newzombie[i])
		end
	end
	
end

function c_lawnmower(l)
	
	nlwmw={
		x=-7,
		y=33+16*(l-1),
		lane=l,
		go=false,
		v=1.5,
	}
	add(lwmw,nlwmw)
	
end

function c_kill_zombie(z,d)
	nkz={
		{
			which=z.which,
			die="n",
			x=z.x,
			y=z.y,
			sx=73,
			sy=64,
			w=13,
			anit=61,
			xos=0,
			yos=3,
		},
		{
			die="e",
			x=z.x,
			y=z.y,
			sx=8,
			sy=40,
			w=13,
			anit=61,
			xos=0,
			yos=0,
		},
	}
	
	for i=1,2 do
		if (d==nkz[i].die) add(kzs,nkz[i])
	end
	
end
-->8
--level stuff

function read_level()
	
	for i=1,#levels[game.level] do
		game.az+=levels[game.level][i]
		
	end
	game.progmax=game.az
	for j=1,4 do
		game.modes[1][j]=levels[game.level][j]
		game.modes[2][j]=levels[game.level][j+4]
		
		if levels[game.level][9]!=nil then
			
			game.modes[3][j]=levels[game.level][j+8]
			game.modes[4][j]=levels[game.level][j+12]
			
		end
		
	end
	
end

function change_modes()
	
	game.hmz=0
	
	for a=1,4 do
		game.hmz+=game.modes[game.mn][a]
	end
	
	
	if game.hmz==0
	and #zombies==0
	and #kzs==0 then 
		if game.az==0 then
			music(40)
			game.won=true
			game.upd=u_s_finishlevel
			game.drw=d_s_finishlevel
			
			else
			game.mn+=1
			game.ztmin=150
			game.ztmax=600
			if game.mn%2==0 then
				game.waveprep=true
				game.wt=game.wtmax
				game.howmany=1
				game.mz=0
			end
		end
	end
	
end

function waves()
	
	if game.mn==2 or game.mn==4 then
		
		if game.waveprep then
			
			game.wzt-=1
			
			if game.wzt==0 then
				if (game.level>1) c_zombies("f")
				game.waveprep=false
				game.wzt=game.wztmax
			end
			
			game.zt=60
			game.ztmin=20
			game.ztmax=40
			
			
		end
		
	end
	
end

function spawn_zombies()
	
	
	local wtz={"n","c","p","b"}
	wntz={}
	local wnz=0
	local hmt=0
	
	for i=1,#wntz do
		wntz[i]=nil
	end
	
	if (game.mz>=3) game.howmany=2
	if (game.mz>=15) game.howmany=3
	if (game.mz>=40) game.howmany=4
	
	for a=1,4 do
		if (game.modes[game.mn][a]>0) hmt+=1 add(wntz,a)
	end
	
	if (game.zt>0) game.zt-=1
	
	if game.az>0
	and hmt>0
	and game.zt<=0 then
		
		for i=1,min(game.hmz,game.howmany) do
			
			if game.az==game.progmax then
				game.zct=game.zctmax
			end
			
			wnz=ceil(rnd(hmt))
			game.mz+=1
			game.modes[game.mn][wntz[wnz]]-=1
			game.az-=1
			c_zombies(wtz[wntz[wnz]])
			
		end
		
		game.zt+=game.ztmin+flr(rnd(game.ztmax-game.ztmin))
		
	end
	
end

function _unlocks()
	
	local plantunlock={
	 {true,false,false,false,false,false,false,false},
	 {true,true,false,false,false,false,false,false},
	 {true,true,true,false,false,false,false,false},
	 {true,true,true,true,false,false,false,false},
	 {true,true,true,true,false,false,false,false},
	 {true,true,true,true,true,false,false,false},
	 {true,true,true,true,true,true,false,false},
	 {true,true,true,true,true,true,true,false},
	 {true,true,true,true,true,true,true,true},
	 {true,true,true,true,true,true,true,true},
	}
	
	local shovelunlock={false,false,false,false,true,true,true,true,true,true}
	
	
	for i=1,8 do
		buyplant[i].unlock=plantunlock[game.level][i]
	end
	
	game.shovelunlock=shovelunlock[game.level]
	
end

function clear_stats()
	
	game.az=0
	game.mz=0
	if game.level==1 then game.sun=60 else game.sun=40 end
	game.zt=600
	game.ztmin=300
	game.ztmax=1200
	game.mn=1
	game.howmany=1
	game.fly=140
	game.wy=140
	game.won=false
	
end

__gfx__
00000000eeeeabbeeeeeeeaaaaaeeeeeeeeeeeeeeeeee4444eeeeeeeeeeeeeeecee6cceeeeeeeeeeeeeeee3eeabbeeee4888888888eeeeeeeeeea9eeeeee66ee
00000000e3eabbbbebeeea44444aeeeeeeeeeeeeeee2444444eeeeeeeeeeeeeeed6cccceceeeeee7e7eeeee3ab3b3ebe48ff8888e88eeeeeeeea08eeee66666e
007007003ebbb0b0bdbea4744474aeeeeeeeeeeeee544444444eeeeeeeeeeeeecdcc0c0c5ceeeee2222eee33bb030bdb48fff88eeeeeeeeeee7994ee66676666
00077000eebbbbbbbdba440444044aeeeeeeebbeee544774477eeeeeeeeeeeeeeccccccc5cebe72222ddeeebbbbbbbdb48888eeeeeeeeeeeea9794e66876666d
00077000eeebbbbbbdba404444404aeeeebb33ebe24447744774eeeeeeeeeeeececccccc5cee3222dde7ee3ebbbbbbdb4888eeeeeeeeeeea799976ee876666dd
00700700eeeebbbeebeea4000004aeeeebb3ee3ee24447744774eeeee7eeeeeeeeecccceceee72ddd7eeeeeeebbbbebe488eeeeeeeeeeee89799448ee76666de
00000000eeeee3eeeeeeea44444aeeeeee3ee882e24444400444eeee766eeeeeeeee3eeeeeeb32d7eeeeeeeeee3eeeee4eeeeeeeeeeeeeee8977664eee666dde
00000000eeeeebeeeeeeeeaaaaaeeeeee3ee822a824444444444eeee666eeeeeeeeebeeeeeb2322de7e7eeeeeebeeeeee4eeeeeeeeeeeeeeee8444eeeee8ddee
e1eeeeeeeeeeebeeeeeeeeee3eeeeee2838e4a80824444444444eeeee6eeeeeeeeeebeeeeee2ee22ddddeeeeeebeeeeee4eeeeeeeeeeeeeeeeeeea9eeeeedeee
171eeeeee333ebe33eee333ebe33ee8a2828e488e22444444444eeee464eeeee333ebe33eeee2ee2222eee333ebe33eee4eeeeeeeeeeeeeeeeeea08eeeee66ee
1771eeee3bbb3b3bb3e3bbb3b3bb3e8882a8eeeee22444444442eee44244eee3bbb3b3bb3eeee22eeeeee3bbb3b3bb3ee4eeeeeeeeeeeeeeeee7994eee6e666e
17771eeee33bb3bb33ee33bb3bb33e880084eeeeee224444445eeeee444eeeee33bb3bb33eebeeb22eebee33bb3bb33ee4eeeeeeeeeeeeeeea9794eee667ed66
177771eeeee33e33eeeeee33e33eeee8844eeeeeeee2224442eeeeeeeeeeeeeeee33e33eeeeebb33233eeeee33e33eeeee4eeeeeeeeeeeee799976ee6876d66d
17711eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4eeeeeeeeeeee89799448e876666dd
11171eeeeeeeabbeeeeeeeaaaaaeeeeeeeeeeeeeeeeee42eeeeeeeeeeeeeeeeecee6cceeeeeeeeeeeeeeee3eeabbeeeeee4eeeeeeeeeeeee8977664ee76666de
eeeeeeeee3eabbbbebeeea44444aeeeeeeeeebbeeeee4442e2eeeeeeeeeeeeeeed6cccceceeeeee7e7eeeee3ab3b3ebeee4eeeeeeeeeeeeeee8444eeee666dde
ee1eeeee3ebbb0b0bdbea4744474aeeeeebb33ebee244774477eeeeeeeeeeeeecdcc0c0c5ceeeee2222eee33bb030bdbee4eeeeeeeeeeeeeeeeeeeeeeee8ddee
e171eeeeeebbbbbbbdba440444044aeeebb3ee3ee22447744774eeeeeeeeeeeeeccccccc5cebe72222ddeeebbbbbbbdbddeeeeeeeeeeeeeeeeeeaa9eeeeedeee
e17111eeeeebbbbbbdba404444404aeeee3ee882e24247744774eeeee7eeeeeececccccc5cee3222dde7ee3ebbbbbbdbdedeeeeeeeeeeeeeeeae908eeeeee6ee
e177771eeeeebbbeebeea4000004aeeee3ee882a824244400444eeee766eeeeeeeecccceceee72ddd7eeeeeeebbbbebeededeeeeeeeeeeeeea97994eee6e666e
1777771eeeeee3eeeeeeea44444aeee2838e2288824424444442eeee666eeeeeeeee3eeeeeeb32d7eeeeeeeeee3eeeeeededeee88eeeeeeeee9974eeee67e666
e177771eeeeeebeeeeeeeeaaaaaeee8a28884a80824444444424eeeee6eeeeeeeeeebeeeeeb2322de7e7eeeeeebeeeeeeededee66eeeeee897994eee6876ed6d
ee1771eee333ebe33eee333e3e33ee888888e488e22444444444eeeff6ffeeee333ebe33eee2ee22ddddee333ebe33eeeeed88855888eeee8e77664e8766d6dd
eee11eee3bbb3b3bb3e3bbb3b3bb3e088828eeeee22444444442e4fffffff4e3bbb3b3bb3eee2ee2222ee3bbb3b3bb3eeee455488455aeeeee8444eee76666de
eeeeeeeee33bb3bb33ee33bb3bb33e8002a4eeeeee224444445eee44fff44eee33bb3bb33eebe22eeeebee33bb3bb33eeee4565445658eeeeeeeeeeeeee66dde
eeeeeeeeeee33e33eeeeee33e33eeee8844eeeeeeee2224442eeeeee444eeeeeee33e33eeeeebb32233eeeee33e33eeeeeee555ee555eeeeeeeeeeeeeee8ddee
ee1111eeeeeeabbeeeeeeeaaaaaeeeeeeeeeebbeeeeeeeeeeeeeeeeeeeeeeeeecee6cceeeeeeeeeeeeeeee3eeabbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedeee
e177771ee3eabbbbebeeea99999aeeeeeebb33ebeeeeee4eeeeeeeeeeeeeeeeeed6cccceceeeeeeeeeeeeee3ab3b3ebeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
1777771e3ebbb0b0b7bea9799979aeeeebb3ee3eeeeee44ee4eeeeeeeeeeeeeecdcc0c0c7ceeeeeeeeeeee33bb030b7beeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e177771eeebbbbbbb7ba990999099aeeee3eeee3ee24e77e477eeeeee7eeeeeeeccccccc7ceeee7e7eeeeeebbbbbbb7beeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee1771eeeeebbbbbb7ba909999909aeee3ee8882e2244774477eeeee766eeeeececccccc7ceeee2222eeee3ebbbbbb7beeeeeeeeeeeeeeeeaaaa99eeeeeeeeee
eee11eeeeeeebbbeebeea9000009aeeee3e8882a824247744772eeee666eeeeeeeeccccecebe7222222eeeeeebbbbebeeeeeeeeeeeeeeeecccccccceeeeeeeee
eeeee888eeeee3eeeeeeea99999aeee283488888824254400444eeeee6eeeeeeeeee3eeeeee32222ddddeeeeee3eeeeeeee7eeeeeeeeee776677aa9edeeeeeee
eeeee8e8eeeeebeeeeeeeeaaaaaeee8a28422888024424444442eeeff6ffeeeeeeeebeeeeee722dd7e7eeeeeeebeeeeeee776eeeeeeeee0766077aaedeeeeeee
eeeee488eeeeebeeeeeeeeee3eeeee888884a280824424444424eefffffffeeeeeeebeeeeeb222d7e7eeeeeeeebeeeeee77776eeeeeeee66667776dadeeeeeee
e76e4eeee333ebe33eee333ebe33ee8888884808ee244244444eefffffff0fee333ebe33eeb2e22ddddeee333ebe33ee7777776eeeeeeee7716666deceeeeeee
7664eeee3bbb3b3bb3e3bbb3b3bb3e0888828eeeeee44444442e4ffff0ff7f43bbb3b3bb3eee2e22222ee3bbb3b3bb3e7777776eeee66eee11166deedeeeeeee
66666eeee33bb3bb33ee33bb3bb33e80882a4eeeeee2444424eee44ffff744ee33bb3bb33eebe222eeebee33bb3bb33e7777776eeec66ee71176deeedeeeeeee
6666deeeeee33e33eeeeee33e33eeee80844eeeeeeee22445eeeeee44444eeeeee33e33eeeeebb33233eeeee33e33eee7777776eeeeeedd6666d8eeedddeeeee
666deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee722eeeeeeeeeeeeeeeeeeeeeee7777776eeeeeee85588688eeeeeeeeee
eeabbeeeeeee00000eeeeee00000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7222ddeeeeeeeeeeeeeeeeeeeeee7777776eeeee66e7788658ee00000eee
eabbbbeeeee0000000eeee0000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee222d7eeeeeeeeeeeeeeeeeeeeeee7777776eeeee66c666658eee0dcddeee
bbb0b0beee770077700ee770077700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebe722ddeeebeee7e7eeeeeeeeeeeeee7777776eeeeee8788888eeee0d000eee
bbbbbbbeee070070700ee070070700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee322d7eeeee3722222eeebeee7e7eee777777688eee07888880eeee000eeeee
bbbbbbbeee000077700ee000077700eeeeeeeeeeeeeeeeeeeeeeeeeeaeeeeeeeee72deeeeeee72222222eee3722222ee77777767e6e7800888eeeeeeeeeeeeee
ebbbbbeeeee00000000eee00000000eeeeeeeeeeeeeeeeeeeeeeeeaee9eeaeaeeb32deeeeeee32d72272eee72222222e7777776e7e6788088eeeeeeeeeeeeeee
eebbbeeeeeee000000eeeee000000eeeeeeeeeeeeeeeeeeeeeeeeaeee9fae99ebe32d7eeeeeb322dd7ddeee32d72272e7777776e887668808eeeeeeeeeeeeeee
eeaaaeeeeee000000eeeee000000eeeeeeeeeeeeeeeeeeeeeeeee9ffeff9e9eeee2e2d7e7ebe2e22222eeeb322dd7dde7777776eeeeee77eeeeeeeeeeeeeeeee
ea444aeeeee0000000eeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeeef9ffafffffeeee2e22dddee2eeeeeeeeebe2e22222eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
a47474aeeeee0000000eeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeef9afff9aeeeee2eee22eee2eeeeeeeeee2eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
a40404ae000000000000eeeee0ee0eeeeeee00000eeeeeeeeeeeeffffffffaebeeb2eeeeebbe2eeeebeeebe2eeeebeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
a44444ae0e00e0000000e0eeeeee0eeeeee0000000eeeeeeeeeefffffffffffebb33223bbeebb2233eeeeebb2233eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ea444aeeee0ee00000000eeee0eeeeeeee770077700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeaaaeeeeeeee00000000eeeeeeeeeeeee070070700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee883eeeeeeeee00000000e0eeeeeeeeee000077700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e82838eeeeeee000000000eeeee0e0eeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
88a2828eeeeee00000000eeee0eeeeeeeeee000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
88882a8eeeeeee00ee000eeeee00e0eeeee000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
8880088eeeeeeee0ee0eeeee00000eeeeee0000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e88884eeeeeeeee00ee0eee0000000eeeeee0000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee844eeeeeeeee00eee0ee000000000eeee000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee444eeeeeeee000ee00e00000000000ee00000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
4774477eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
4704407eeeee66666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66666eeeeeeee66666eeeeeeee66666eeeeeeeddddeeeeee2222eeeeeeeeeeeeeeeeeeeeeeeee
4774477eeee6666666eeeeeee66666eeeeeeee66666eeeeeee6666666eeeeee6666666eeeeee6666666eeeee66666de222244442eeeeeeeeeeeeeeeeeeeeeeee
e44004eeee70667776deeeee6666666eeeeee6666666eeeee70667776deeee70667776deeee7d667776deee66d7766d4444444421eeeeeeeeeeeeeeeeeeeeeee
ee444eeeee77660776deeee70667776deeee70667776deeee77667776deeee77667776deeee77667776deee66777666644440221c1eeeeeeeeeeeeeeeeeeeeee
eee6eeeeee66667776deeee77660776deeee77660776deeee66660776deeee66660776deeee6666d776deee6677761a640444001ee6614eeeeeeeeeeeeeeeeee
ee686eeeeeeaa16666deeee66667776deeee66667776deeeeeaa16666deeeeeaa16666deeeeeaa16666deee6666611160400044116eee4eeeeeeeeeeeeeeeeee
eee6eeeeeeee11166deeeeeeaa16666deeeeeaa16666deeeeee11166deeeeeea11a66deeeeeee11166deeee66666a1160877744cce66c14eeeeeeeeeeeeeeeee
efffffeeeeea11a6deeeeeeee11166deeeeeee11166deeeeeda11a6deeeee6e66666deeeeeeea11a6deeeeee6776aea6008422eeeeeeee4eeeeeeeeeeeeeeeee
fffff0feeee6666642eeeeeea11a6d2eeeeeea11a6d2eeeee66666642eeee6eee00542eeeeee6666642eeeeee7d6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ef0ff7eeeee50004442eeeee66666442eeeee66666442eeee6ee220442eee6455444442eeeee50004442eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeff7eee664450840442e664450840442e664450840442e664600044442eee4454804442e664450840442eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee6cceee6e45e8704442e6e45e8704442e6e45e8704442eee4404440442eee4400044442e6e45e8704442eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e6cccceeee4ee47044442ee4ee47044442ee4ee47044442ee44040044442e666044404442ee4ee47044442eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
dcc0c0ceeeeee27040442eeeee27040442eeeee27040442eeeee02444442eeee040044442eeeee27040442eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
dcccccceeeeeee2440244eeeeee2440244eeeeee2440244eeeeee2444442eeeee02444442eeeeee2440244eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ccccccceeeeee66640244eeeee66640244eeeee66640244eeeeee2442442eeeeee2442442eeeee66640244eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eccccceeeeeee66102001eeeee66102001eeeee66102001eeeeeec111221eeeeeec111221eeeee66102001eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeccceeeeeeeeec1ee6c1eeeeec1eee6c1eeeeeec1ee6c1eeeeeec1ee6c1eeeeeec1ee6c1eeeeeec1e6ec16eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee7e7eeeeeeeeee6ee6eeeeeeee6eee6eeeeeeeee6ee6eeeeeeeee6ee6eeeeeeeee6ee6eeeeeeeee662e661eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e72222eeeeeeeee61ee6eeeeeee61eee6eeeeeeee61ee6eeeeeeee61ee6eeeeeeee61ee6eeeeeeeee44ee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
7222222eeeeeeec1eee1eeeeeec1eeee1eeeeeeec1eee1eeeeeeec1eee1eeeeeeec1eee1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e22ddddeeeeee442ee42eeeee442eee42eeeeee442ee42eeeeee442ee42eeeeee442ee42eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
72d7e7eeeeeeaaaa99eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e22dddeeeeecccccccceeeeeeaaaa99eeeeeeeaaaa99eeeeeeaaaa99eeeeeeeaaaa99eeeeeeeeeeeeeeeeeeeeeeaeeeeeee8eeeeeeeeeeeeeeeeeeeeeeeeeeee
ee222eeeee706677aa9eeeeecccccccceeeeecccccccceeeecccccccceeeeecccccccceeeeeeeeaaaa99eeeec9addeeee88807eeeeeeeeeeeeeeeeeeeeeeeeee
eeabbeeeee7766077aaeeee706677aa9eeee706677aa9eee706677aa9eeee706677aa9eeeeeeeccccccccee9caa66d888588087eeeeeeeeeeeeeeeeeeeeeeeee
eab3b3eeee666677765aeee7766077aaeeee7766077aaeee7766777aaeeee7766777aaeeeeee7d6677aa9ee9cd7766d666580877e88eeeeeeeeeeeeeeeeeeeee
3bb030beeeeaa166665eeee666677765aeee666677765aee66660776daeee66660776daeeeee7766777aaeeac77766d8556680866e7eeeeeeeeeeeeeeeeeeeee
3bbbbbbeeeee111665eeeeeeaa166665eeeeeaa166665eeee7716666deeeee7716666deeeeee6666d776daeac77767648887c087eeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbeeeea11a65eeeeeeee111665eeeeeee111665eeeeee11166deeeeee71176ddeeeeeeee7716666deeac6661165667880876eeeeeeeeeeeeeeeeeeeeeee
ebbbbbeeeee6666548eeeeeea11a658eeeeeea11a658eeede71176d8eeeee66666d68eeeeeeeee11166deeeac7767165667e7e67e67eeeeeeeeeeeeeeeeeeeee
eebbbeeeeeee8554868eeeee66665468eeeee66665468eece6666d868eeeeec8558888eeeeeee71176deeeeec7d6776888eeeeeee88eeeeeeeeeeeeeeeeeeeee
e222222eeeee8668568eeeeee8558568eeeeee8558568eedee8558865eeeeee6888865eeeeeee6666d48eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
29299292eeee86685658eeeee86685658eeeee86685658eeddd8866858eeddcd6886858eeeeeee8558568eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
2297a922eeeee7786588eeeeee7786588eeeeee7786588ee6666c88858eeeeeee668858eeeeeee86685658eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
297aaa92eeeeee8768868eeeeee8768868eeeeee8768868eeeee8785888eeeeee8785888eeeeeee7786588eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
29aaaa92eeeeee78c8000eeeeee78c8000eeeeee78c8000eeeeee878000eeeeeee878000eeeeeeed8768888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
229aa922eeeeeee660888eeeeeee660888eeeeeee660888eeeeee780888eeeeeee780888eeeeeeed78c8000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
29299292eeeeeee668878eeeeeee668878eeeeeee668878eeeeeee08878eeeeeeee08878eeeeeedde660888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e222222eeeeeeeee77767eeeeeeee77767eeeeeeee77767eeeeeee77767eeeeeeee77767eeeeeedde668878eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e33ee11eeeeeeeeee6e6eeeeeeeee6ee6eeeeeeeeee6e6eeeeeeeee6e6eeeeeeeeee6e6eeeeeeeeeee77767eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
3ab317c1eeeeeeee6eee7eeeeeee6eeee7eeeeeeee6eee7eeeeeee7eee6eeeeeeee7eee6eeeeeeeeeee6e6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
3bb31cc1eeeeeee8eeee8eeeeee8eeeee8eeeeeee8eeee8eeeeeee8eee8eeeeeeee8eee8eeeeeeeee86eee8eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e33ee11eeeeeeee87ee78eeeeee87eee78eeeeeee87ee78eeeeee78eee87eeeeee78eee87eeeeeeee87ee78eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
88888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
8eee8eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e8e8eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee8eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee4eeeeeeeee3e3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
77666eeeeeeee3eeeeeeeeeee3eeeeeeeeeee3ee3eeeeeeeeeeee3eeeee3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
76666eeeeeeeeeeeeeeeeeeee3e3eeeeeeeeee3e3eeeeeeeeee3eeeeeeee3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
66666eeeeeeeeeeeeeeeeeeeeeeeeeeee3eeeeeeeeeeee3e3eeeeeeeeeee3e3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
6666deeeeeeeeeeeeeeeeeeeeeeeeeee3a3eeeeeeeeeeee3eeeeeeee3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e66deeee3eeeeeeeee3eeeeeeeeeeeeee3eeeeeeeeeeeeeeeeeeeee3a3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeee3ee3eeeee3e3eee3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeee3e3eeeeeeeeeee3a3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee3eeeeeeeeeeeee3e3eeeeeeeeeeee3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee3eeee3eeeeeee3ee3eeee3e3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee3e3eeeeeeeee3ee3ee3eeeeeeeeee3ee3eee3e3eeeeee3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeee3eeeeeeeeeee3e3e3eeeeeeeeeee3e3eeee3e3e3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
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
490100002271322713217131c71316713117130c703007030370304703097030f7030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
01200000190551a055190551a05516055130551303513015160551305513035130151a055130551303513015190551a055190551a05516055130551303513015160551305513035130151a055130551303513015
01200000190551a055190551a05516055130551303513015160551305513035130151a055130551303513015150551605515055160551305513035130151301513015130351505516055180551a0551f05522055
012000102571526715257152671529715267150070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
012000101612400102131240010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102
0120001013124000041612400104181241a1242e7242b724001040010400104001040010400104001040010400104001040010400104001040010400104001040010400104001040010400104001040010400000
01200000007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702007021f712217122271224712
012000002671126711267112671126711267112671126711257112571125711257112671126711267112671122711227112271122711227112271122711227111f7111f7111f7111f7111f7111f7111f7111f711
012000000000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000033061300003306130000330613306133061330613
012000001f7521f7551a7521a7551675216755137521d7521d7521d7521d7551b7521b7521b7521b755007001a7521a75516752167551375213755167521b7521b7521b7521b7551a7521a7521a7521a75500700
012000001f7521f7551a7521a7551675216755137521d7521d7521d7521d7551b7521b7521b7521b75500000197551a755197551a755197551875516755117551375500000000000000000000000000000000000
012000002b7112b7112b7112b7112b7112b7112b7112b711297112971129711297112771127711277112771126711267112671126711267112671126711267112471124711247112471122711227112271122711
012000002b7112b7112b7112b7112b7112b7112b7112b711297112971129711297112771127711277112771100000000000000000000000000000000000000000000000000000000000000000000000000000000
0120000007125071250a125071250c125071250c1250e1250c1250c1250f1250c125111250c12511125131250e1250e125111250e125131250e125131251512507125071250a125071250c125071250c1250e125
0120000007125071250a125071250c125071250c1250e1250c1250c1250f1250c125111250c12511125131250d1250e1250d1250e1250d1250c1250a125051250712507115071150711507115071150711507115
012000080c6250060030625006000c6250c6253062500600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
012000000c6230060330625006030c6230c62330625000030c6230060330625006030c6230c62330625000030c623006030c623006030c623000030c623000030c6230060330625006030c6230c6233062500003
0120000000700007051b7751c7752177500705007050070500705007051b7751c7751f7751e7751d7751c7751b7721b7721b7721b7721b7721b7721b7721b7751877218775007050070500705007050070500700
012000001a7721a7721a7721a77518700187001c7751d7751c7721c77517772177751c7721c7751a7721a775187721877218772187751c7721c7721c7721c7752177221772217722177500700007000070000700
012000002177520775217752377524770247750070000700217752077521775237752477024775267702677523772237722377223775287722877228772287752c7722c7722c7722c7752f775247003477500700
0120000021770217751877523775247751c7752477523775217702177518775237752477526775247752377521770217751877523775247751c77524775237752177221772217722177523772237722377223775
012000002177221772217722177221772217722177221775007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0120000015730157351873018735107301073518730187351573015735187301873510730107351873018735157301573518730187351373013735187301873511730117351a7301a73510730107351873018735
012000001573015735187301873517730177351a7301a73518730187351c7301c7351d7301d7351a7301a735157301573518730187351073010735187301873515730157350c7000c7001c7351a7351873517735
012000001c7751877515775107751c7751877515775107751d7751877515775107751d7751877515775107751c7751877515775107751c7751877515775107751d7751877515775107751d775187751577510775
012000000913500105101351513500105001050413004135091350010510135151350010500105041300413505130051350c1300c135111301113500130001350513005135001050010505135061350713508135
01200000021300213509130091350e1300e135021300213504130041350b1300b135101350e1350c1350b135091300913009130091350713007130071300713506130061350e1300e13502130021350e13500000
012000000513005135000000c13511130111350013000135021300213500000091350e1300e135021300213504130041350000000000000000000000000000000000000000000000000000000000000000000000
012000000913009135101301013504130041351013010135091300913510130101350413004135101301013505130051350c1300c13500130001350c1300c13505130051350c1300c13508130081350b1300b135
0120000009170091750000000000041700417500000000000917508175091750c175041700417500000000000917508175091750b1750c1700c17510170101750e1700e1750c1700c1750b1700b1750000000000
0120000009170091750000000000071700717500000000000c1750b1750c175101751117011175000000000010170101750c175091750b1700b1750c1700c1750917009175000000000000000000000000000000
0120000009132091320913209132091320913209132091310b1310b1320b1320b1320b1320b1320b1320b1310c1310c1320c1320c1320c1320c1320c1320c1310e1310e1320e1320e1320e1320e1320e1320e131
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003063530000306350000030635306353063530635
011000100c053000000000000000306230000030623000000c0530c0530000000000306230c05300003306230c0000000000000000000c00030600000000c0000c00000000306000c00030600306000000000000
011000200c053000001b3133f21530623000000c0530c0533f2151b3130c05330623000000c05330623000000c0530c0003f2150c05330623306231b3133f2150c0530c0001b31330623000000c0530c0531b300
001c000016552145521155218552185521655214552115520c5520e55210552115521155211552115521155500502005020050200502005020050200502005020050200502005020050200502005020050200500
0138000005125081250a1250b1250c125001050010500105051250010500105001050010500105001050010500105001050010500105001050010500105001050010500105000000000000000000000000000000
21200c0018161181611816118161121611216112161121610c1610c1610c1610c1650010100101001010010100101000000000000000000000000000000000000000000000000000000000000000000000000000
191200200c5500f5500c550165500050016550165550c55000500155500050015550005001555000500155500e550115500e550155500050015550155551655000500155501355011550135500e5500c5500a555
191200200c5500f5500c550165500050016550165550c55000500155500050015550005001555000500155500e550115500e55015550005001555015555135500000013550135551355000000135550000000000
0112000000130001350013000135071300713500105051300010505130000000c1300000000000000000000002130021350213002135091300000000105071300010500105001050010500105001050010500105
0112000000130001350013000135071300713500105051300010505130000000c130000000000000000000000213002135021300213509130000000010507130001050213007130091300a1300c1300e13011130
491200100c62500005006050c6253062500000006050c625006050c625006050c6253062500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500000
011210003062500605306250060530625006053062500605306250060530625006053062500605306250060500605006050060500605006050060500605006050060500605006050060500605000000000000000
011200000020200202002020020200202002020020200202002020020200202002021a2621a2651b2621b2651d2621d2621d2621d2651b2621b2621b2621b2651a265182001f2621f2621f2621f2651d2621d262
011200001d2621d2621d2621d2651b2621b2621b2621b2651a265182001f2621f2621f2621f2651d2621d2621d2621d2651f2621f2621f2621f2621f2621f265002000020000200002001a2621a2651b2621b265
011200001d2621d2621d2621d2651b2621b2621b2621b2651a2621a262182621826216262162621826218262162621626216262162651f2001f2001f2001f200002000020000200002001a2621a2651b2621b265
011200200c053000001b3000c05330623000000c0530c0533f2151b3130c05330623000000c05330623000000c0530c0003f2150c05330623306000c0530c0533f2151b3130c053306230c05330623306231b300
011200200014000140001400014507100021400314005140051420514205142051450314203142031420314502140021400214002145000000314005140071400714207142071420714502142021420214202145
011200001d2621d2621d2621d2651b2621b2621b2621b2651a265182001f2621f2621f2621f2651d2621d2621d2621d2651f2621f2621f2621f2621f2621f26500200002001a2621a2651a2621a2651b2621b265
011200001d2621d2621d2621d2651b2621b2621b2621b2651a2621a262182621826216262162621826218262162621626216262162651f2001f2001f20000000000001f2001a2621a26216262162621a2621a265
011200001626216265000000000016262162651326216262162651a2621a2621a26516262162650000013262162621626213262162621626500000162621326216262162651a2621a26516262162651a2621a265
01120000162621626500000000001d2621d2651d2651d2621d265000001a2621a262182621826216262162621826218262182621a2621a2621a26216262162621626500000000000000000000000000000000000
0112000000000000001a2621a26516262162651a2621a2651626216265000001a20016262162651326216262162651a2621a2621a265162621626513200132621d2621d2621b2621a2621a262182621626216265
0112000000000000001d2621d2621a2621a2621b2621b2621d2621d2621a2621a262182621826216262162621826218262182621a2621a2621a26216262162621626216265000000000000000000000000000000
191200001a5521a5521a5551a5521a555005051a5551d5521d5521d5551a5521a5551655216555135521355211552115551155211555185521855218552185521655216552165521655500505005050050500505
191200001a5521a5521a5551a5521a555005051a5551d5521d5521d5551a5521a5551655216555135521355211552115551155211555185521855218552185521d5521d5521d5521d55500505005050050500505
011200000c0530c0530c0530c0530c0530c0530c0530c053306230c0530c0530c0530c0530c0530c0530c0530c0530c0530c0530c0530c0530c0530c0530c053306230c0530c053306230c0530c053306230c053
011200200014000140001400014000140001400014000145000000000003140031450014000145071400714005140051400514005140051400514005140051450714007140071400714002140021400214002145
01120020001400014000140001400014000140001400014500000000000314003145001400014507140071400514005140051400514005140051400514005145000000310000000031001a2621a2651b2621b265
09120000000000000000000000000000000000000000000000000000001a3601a3601836018360163601636015360153601536515360153601536516360163601636500300003000030000300003000000000000
0912000018300183001a300000000000000000000000000000000000001a3601a360183601836016360163601836018360183651836018360183651a3601a3601a36500300003000030000300003000000000000
0912000000000000000000000000000000000000000000000000000000000000000000000000001f3601f36521360213602236022360263602636026360263602936029360293602936029360293650000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01 03 04 06
00 02 03 05 07
00 02 03 05 07
00 01 03 04 08
01 09 0b 0d 0f
02 0a 0c 0e 10
00 41 42 43 44
00 41 42 43 44
00 11 19 43 44
00 11 19 43 44
00 12 1a 43 44
00 13 1b 20 44
00 14 1c 21 44
00 14 1c 21 44
00 15 19 43 44
00 16 1d 43 44
00 17 1e 43 44
00 16 1d 43 44
00 17 1e 43 44
00 18 42 43 44
00 18 1f 43 44
00 18 1f 20 44
01 11 19 22 44
00 11 19 22 44
00 12 1a 22 44
00 13 1b 20 22
00 14 1c 43 22
00 14 1c 43 22
00 15 19 22 44
00 16 1d 22 44
00 17 1e 22 44
00 16 1d 22 44
00 17 1e 22 44
00 18 22 43 44
00 18 1f 22 44
02 18 1f 22 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
04 23 24 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 26 28 43 44
00 27 29 43 44
00 26 28 2a 44
00 27 28 2a 44
00 2b 2c 43 44
01 2d 26 30 2f
00 2e 26 30 2f
00 31 26 30 2f
00 32 26 30 2f
00 33 42 30 2f
00 34 42 30 2f
00 35 26 30 2f
00 36 26 30 2f
00 3c 37 3a 39
00 3d 37 3a 39
00 3c 37 3a 39
02 3e 38 3b 39
