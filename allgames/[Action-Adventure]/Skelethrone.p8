pico-8 cartridge // http://www.pico-8.com
version 11
__lua__
--skelethrone
--frescogusto

--cc1=8+rnd(8) --red
--cc2=rnd(8) -- white
--cc3 =rnd(8) -- black

--cc1=9
--cc2=1
--cc3=2
cc1=12
cc2=7
cc3=0

--shake=0
gamestarted=false
cam={x=0,y=0}
timer,col,finalexplos,
bossx,boxxy=
0,0,0,0,0

function _init()
	music(0)
	level=0
end

function reset()
cc1=12
pl={x=64,y=64,spr=1,dx=0,dy=0,
spd=2,bult=0,lastdir=0,dir=0,
hp=5,invi=0,
shotspd=3,shotrate=6,
bombs=4,dead=false}

--music(-1)
music(15)

kapala,dash,shield,showcompass,
thief=
0,0,false,false,false

inv={
{t=-1,spr=115},
{t=3,spr=126}
}
inv.sel=1

level,world,shake,gold= 
0,1,0,0

end

function addinv(o)
	local isiteminv=false
	
	for i=1,#inv do
		if o.t==inv[i].t then
			isiteminv=true
		end
	end
	
	if not isiteminv then
		inv[#inv+1]={t=o.t,spr=o.spr}
	end
end

function newlvl()

par,bul,ene,bld,bom,
cra,ite,gol,exp=
{},{},{},{},{},
{},{},{},{}

thronex,throney,thronet=0,0,-1

world = flr((level-1)/3)+1
	if(world==1) cc1=4 turnchance=30 --music(17)
	if(world==2) cc1=11 turnchance=50 --music(25)
	if(world==3) cc1=9 turnchance=10 --music(33)
	if(world==4) cc1=8 turnchance=70 --music(41)
	if(world==5) cc1=14 music(25)
	
	if(level==1) music(17)
	if(level==4) music(42)--42
	if(level==7) music(8)--8
	if(level==10) music(31)--32
	
if(level>13) then
	music(0)
end

if level!=0 and level!=13 then
text="level "..world.."-"..(level-1)%3+1
else text="" end
text2,text3="",""
texto=30
texthold=0

lvl={}
lvsize=63
start={x=1+flr(rnd(lvsize-2)),y=1+flr(rnd(lvsize-2))}
stair={x=0,y=0}
wlk={x=start.x,y=start.y,dir=0,steps=0}
maxsteps=1000
--turnchance=30
turnback=6

	for i=0,lvsize do
		lvl[i] = {}
		for j=0,lvsize do
			lvl[i][j]=1
			settile(i,j,1)
		end
	end
	
	bosslvl=false
	startlvl=false
	if(level==0)	startlvl=true
	if(level==13)	bosslvl=true
	
	
	
	if bosslvl then
	
		for i=0,31 do
			for j=0,31 do
				settile(i+16,j+16,mget(65+i,j)-16)
			end
		end
		
		wlk.x=16+16 wlk.y=16+16
		start.x = 16+16 start.y=24+16
	
		makeene(wlk.x*8,wlk.y*8,15)

	
	elseif startlvl then
	
		for i=16,16+12 do
			for j=16,16+12 do
				settile(i,j,0)
			end
		end
		wlk.x=16+2 wlk.y=16+6
		start.x=16+6 start.y=16+6
		makecrate((start.x+4)*8,start.y*8)
		for i=1,10 do
			--makeitem(start.x*8-32+i*8,start.y*8-32,true,flr(rnd(10)) ) --start items
		end
	
	else		
		
		while(wlk.steps<maxsteps) do
			makelvl()
		end

	end
	
	if not bosslvl then
		settile(wlk.x,wlk.y,5)
		stair.x=wlk.x stair.y=wlk.y
	end
	
	
	if not bosslvl and not startlvl then
		if rnd()<0.5	then
			makeshop(0)
		end
		if rnd()<0.3 then
			makeshop(1)
		end
	end
	
	-- remove! its for testing
	--if startlvl then
	 --makeshop(0)
	--end
	
	auto_tile(0,0,lvsize,lvsize)
	
	pl.x=start.x*8 pl.y=start.y*8
	cam.x=pl.x-64 cam.y=pl.y-64
	lvl[start.x][start.y]=8
	
	if not bosslvl then
		for e in all(ene) do
			if abs(pl.x-e.x)<64 and
						abs(pl.y-e.y)<64 and e.t!=14 then
				del(ene,e)
			end
		end
	end

end


	


function _update()

	--pl.dx *= 0.7
	--pl.dy *= 0.7
	
	timer+=1
	if(timer>7) timer=0
	
	blocksel=false
	
	if not gamestarted then
		camera(0,0)
		sfx(-1,3)
		if btnp(5) then
			reset() 
			newlvl()
			gamestarted=true
			sfx(10)
			
		end
		return
	end
	
	if level>13 then
		camera(0,0)
		return
	end
	
	--hack. for test
	--if(btnp(5,1)) level+=1 newlvl() 
	--if(btnp(4,1)) makeitem(pl.x,pl.y,true) 
	
	pl.dx=0 pl.dy=0
	
	pl.spr = 1
	pl.lastdir=pl.dir

	if dash>0 then dash-=1 end
	if dash>6 then
		pl.spd=6
	else pl.spd=2
	end

	
	if finalexplos>0 then
 	if finalexplos%5==0 then
 		explo(bossx+rnd(32)-16,bossy+rnd(32)-16)
 	end
 	finalexplos-=1
	end


	if not pl.dead then
	
	if(btn(0)) pl.dx = -pl.spd pl.dir=3 pl.spr=3
 if(btn(1)) pl.dx = pl.spd  pl.dir=1 pl.spr=3
 if(btn(2)) pl.dy = -pl.spd pl.dir=0 pl.spr=3
 if(btn(3)) pl.dy = pl.spd  pl.dir=2 pl.spr=3
	
	move(pl,pl.dx,pl.dy)
	if pl.spr==3 then
		makepar(pl.x+4,pl.y+4,3,cc2)
	end
	
	
	if(pl.bult>0) pl.bult-=1
	
	
	--thronestuff
	if thronet>0 then 
		thronet-=1
		setshake(20)
		pl.x,pl.y=thronex,throney
		sfx(4)
	elseif thronet==0 then
		--throne gives something
		
		texto=45
		local gift=rnd(8)
		--local gift=6
		
		if gift<1 then
			--pl.hp-=flr(rnd(3))
			for i=1,1+flr(rnd(3)) do
				dmgpl()
				text="trolol"
			end
			
		elseif gift>=1 and gift<2 then
			pl.hp+=1+flr(rnd(10))
			sfx(6)
			text="a blessing"
			
		elseif gift>=2 and gift<3 then
			gold=0
			sfx(8)
			text="remember to pay taxes"
			
		elseif gift>=3 and gift<4  then
			gold+=100+flr(rnd(200))
			sfx(0)
			text="rich bitch"
		
		elseif gift>=4 and gift<5  then
			gold*=2
			sfx(0)
			text="gamble boy"
			
		elseif gift>=5 and gift<6  then
			for i=-1,1 do
				for j=-1,1 do
					if i!=0 or j!=0 then
						makeitem(thronex+i*8,throney+j*8,true,rnd(11))
					end
				end
			end
			text="your mom loves you"
			
		elseif gift>=6 and gift<7  then
			for i=-2,2 do
				for j=-2,2 do
					if i==-2 or j==-2 or i==2 or j==2 then
						makeene(thronex+i*8,throney+j*8,0)
					end
				end
			end
			text="thy audience hath been summoned"
			
		else --gift>=7
			makeitem(thronex,throney-8,true,rnd(5)+6)
			text="a gift from the gods"
		end
		
		-- throne explode
		for i=1,40 do
			local c=cc1
			if(rnd()<0.5)c=cc2			
			makepar(thronex+rnd(32)-16,
			throney+rnd(32)-16,rnd(8),
			c)
		end
		shake=3 sfx(2)
		thronex,throney,thronet=0,0,-1


	end
	
	showcompass=false
	shield=false
	
	if btn(4) then
	-- use item	
		if inv[inv.sel].t==-1	then
			plshoot() 
		end
		if inv[inv.sel].t==3	then
			if pl.bombs>0 and pl.bult<=0	then
				makebomb(pl.x,pl.y)
				pl.bombs-=1
				pl.bult=10
			end 
		end
		if inv[inv.sel].t==7	then
			dig()
		end
		if inv[inv.sel].t==9 then
			fillkapala()
		end
		if inv[inv.sel].t==6	then
			showcompass=true
		end
		if inv[inv.sel].t==8 and dash<=0	then
			dash=10
			sfx(9)			
		end
		if inv[inv.sel].t==10	then
			shield=true		
		end
	end
	
	
	
	end -- end pl.dead
	
	if(pl.invi>0)pl.invi-=1
	
	if pl.dead then
		pl.spr=5
		texto=1
		text2="gameover"
		text=""
		text3="press — to live"
		if(btnp(5)) gamestarted=false music(0)
	end
	

	--subrscribe to channel
	--thanks :^)
	
	for ex in all(exp) do
		if ex.t<4 then
			if dstk(pl.x,pl.y,ex.x,ex.y)<ex.r/1000 then
				dmgpl()
				--del(ene,e)
			end
		end
	end

	
	--enemies ens
	for e in all(ene) do
		
		for ex in all(exp) do
			if ex.t<4 then
			if dstk(e.x,e.y,ex.x,ex.y)<ex.r/1000 then
				for i=1,1 do dmgene(e) end
				--del(ene,e)
			end
			end
		end
		
		
		
		if e.t==5 or e.t==3 or 
		e.t==4 or	
		(e.t==14 and e.state==1) then
		 e.time=0
		end
		
		
		if e.time>0 then e.time-=1
		else --get a target
			e.time=e.maxtime+flr(rnd(60))
			
			--if is in pl range
			if abs(pl.x-e.x)<e.rng and
						abs(pl.y-e.y)<e.rng then
				e.tarx=pl.x+rnd(e.rng)-e.rng/2
				e.tary=pl.y+rnd(e.rng)-e.rng/2
				e.inrng=true
				
				if e.t==14 and thief then
					madshopk(e)
				end
				
				if e.t==3 or e.t==4	then 
					e.tarx=pl.x 
					e.tary=pl.y
				end
				
				--tombstone
				if e.t==6 then
					makeene(e.x,e.y,5)
				end
			
			--if pl not in range
			else
				e.tarx=e.x+rnd(e.rng)-e.rng/2
				e.tary=e.y+rnd(e.rng)-e.rng/2
				e.inrng=false
			end
			
			
		end

		
		e.spr=e.t*2+32+time()*6%2
		if e.t==14 and e.state==1 then 
			e.spr=8+time()*10%2
		end
		
		--set speed
		e.dx=sign(flr(e.tarx)-e.x)*e.spd
		e.dy=sign(flr(e.tary)-e.y)*e.spd

		-- stop if reach destination
		if abs(e.tarx-e.x) < e.spd then
		 e.dx=0
		end
		if abs(e.tary-e.y) < e.spd then
			e.dy=0 
		end

		if e.t==3 then
			if abs(pl.x-e.x)<24 and
						abs(pl.y-e.y)<24 then
				dmgene(e)
			end
			--local v={x=(e.tarx-e.x),y=(e.tary-e.y)}		
 		--if(abs(v.x)<24 and abs(v.y)<24) then
 		--	dmgene(e)
 		--end
 		--v=norm(v)
 		--e.dx=v.x*3 e.dy=v.y*3
 		--bomber
		end
		
		if e.t==14 and e.state==0 then
			--nothing
		else
		move(e,e.dx,e.dy)
		end
		
		if e.t==14 and e.state==1 then
			--shopkeeper destroys
			for i=-1,1 do
				for j=-1,1 do
  			local x=flr(e.x/8)+i
  			local y=flr(e.y/8)+j
  			destroytile(x,y)
				end
			end
			
		end
			
			
		
		if(e.dmgd>0)e.dmgd-=1
		
		if(pl.dead)e.inrng=false
		
		
		--death
		if e.t==15 and e.time<=0 then
			makeene(e.x,e.y,flr(rnd(12)) )
		end
		
		
		-- ene shooting
		if e.inrng and e.shotsp>0 then
			if (e.t==1 and rnd(100)<5 ) or
						(e.t==2 and e.time<=10 and e.time%3==0) or
						(e.t==7 and e.time<=0) or
						(e.t==8 and e.time<=0) or
						(e.t==9 and e.time%5==0  and e.time>e.maxtime/2) or
						(e.t==11 and e.time<=5) or
						(e.t==14 and e.state==1 and e.time%4==0) then
				local v={x=pl.x-e.x,y=pl.y-e.y}
 			v=norm(v)
 			eshoot(e.x,e.y,v.x,v.y,e.shotsp,1)	
				
				if e.t==8 then
				 eshoot(e.x,e.y,-v.x,-v.y,e.shotsp,1)	
					eshoot(e.x,e.y,v.x,-v.y,e.shotsp,1)	
					eshoot(e.x,e.y,-v.x,v.y,e.shotsp,1)	
				end
				
				if e.t==11 then
					eshoot(e.x,e.y,v.x*2,v.y,e.shotsp,1)	
					eshoot(e.x,e.y,v.x,v.y*2,e.shotsp,1)	
				end
				
			end
		end
		
		if aabb(pl.x,pl.y,e.x,e.y) then
			if dash>6 then
				for i=1,5 do
					dmgene(e)
				end
			elseif e.t==14 and e.state==0 then
				--no dmg to pl
			else
				dmgpl()
			end
		end
		
	end
	-- end ene
	
	
	-- bombs
	for b in all(bom) do
		b.time-=1
		if b.time<=0 then
			explo(b.x,b.y)
			del(bom,b)
		end
	end
	
	for c in all(cra) do
		for ex in all(exp) do
			if ex.t<4 then
				if dstk(c.x,c.y,ex.x,ex.y)<ex.r/1000 then
					opencrate(c)
				end
			end
		end
		if dash>6 and aabb(pl.x,pl.y,c.x,c.y) then
			opencrate(c)
		end
	end
	
	for p in all(par) do
 	p.x+=rnd(2)-1
 	p.y+=rnd(2)-1
  p.s -=rnd(0.3)+0.1
  if(p.s<=0) del(par,p)
 end
 
 -- bullets
 for b in all(bul) do
  b.x+=b.dx 
  b.y+=b.dy
  if cmap(b) then
  	buldie(b)
  end
  
  if b.t==0 then --player bull
  	for c in all(cra) do
  		if aabb(b.x,b.y,c.x,c.y) then
  			opencrate(c)
  			buldie(b)
  		end
  	end
  	
  	b.dist+=1
  	if b.dist>16 then
  		buldie(b)
  	end
  	
  	for e in all(ene) do
  		
  		if aabb(e.x,e.y,b.x,b.y) then
  			buldie(b)
  			dmgene(e)
  			e.dx += b.dx
  			e.dy += b.dy
  			if(e.t!=6)move(e,e.dx,e.dy)
  			
  			break
  		end
  	end
  else --enemy bull
  	if aabb(pl.x,pl.y,b.x,b.y) then
  		if (not shield) dmgpl()
  		buldie(b)
  	end
  end
	end
	
	for i in all(ite) do --costs
		if aabb(pl.x,pl.y,i.x,i.y) then
			if texthold<=0 then
				texto=2
				text=""..i.name
				if i.price>0 then
				text2="price="..i.price
				else text2="" end
				text3="press — to get"
				if btnp(5) then
					getitem(i)
					blocksel=true
				end
			end
		end
	end
	
	for g in all(gol) do
		if aabb(pl.x,pl.y,g.x,g.y) then
			getgold(g)
		end
	end
	
	for e in all(exp) do
		if(e.t>0) then e.t-=1
		else del(exp,e) 
		end	
	end
	
	
	if(shake>0) shake -=0.5

	cam.x+=(-cam.x+pl.x-60)/10
	cam.y+=(-cam.y+pl.y-60)/10
	--cam.x=flr(pl.x/128)*128
	--cam.y=flr(pl.y/128)*128
	cam.x=max(0,cam.x) cam.x=min(cam.x,lvsize*8-128+8)
	cam.y=max(0,cam.y) cam.y=min(cam.y,lvsize*8-128+8)
	
	camera(cam.x + rnd(shake)-shake/2,cam.y + rnd(shake)-shake/2)
 --camera(flr(pl.x/128)*128 + rnd(shake)-shake/2,flr(pl.y/128)*128 + rnd(shake)-shake/2)

--	if(fget(mget(flr(pl.x/8),flr(pl.y/8)),1)) then
	--exit
	if aabb(pl.x,pl.y,stair.x*8,stair.y*8) then
		texto,text,text2,text3=
		1,"press — to descend",
		"",""
		
		if btnp(5) then
			level+=1
			newlvl()
			blocksel=true
			--cc1=rnd(16)
		end
	end
	
	if aabb(pl.x,pl.y,thronex,throney) and
				thronet<0 then
		texto,text,text2,text3=
		1,
		"— to sit on throne",
		"",""		
		if btnp(5) then		
			thronet=60
			blocksel=true
		end
		
	end
	
	if(texthold>0) texthold-=1

	if not pl.dead and not blocksel then
		if btnp(5) then
			inv.sel+=1
			if(inv.sel>#inv) inv.sel=1	
		end
	end

end



function _draw()
	
	
	--pal(8,12)
	
	cls(cc3)
	pal(8,cc1) pal(7,cc2) pal(0,cc3)
	
	
	-- final screen
	if level>13 then
	
		if timer==0 then
			cc1=8+time()*4%8
		end
		
		cls(cc1)
		
		for i=1,17 do
			for j=1,17 do
					spr(29,-8+i*8+sin(time()+i*0.1),-8+j*8+cos(time()+j*0.1) )
			end
		end
		
		sprs(62+flr(time()*6%2),48+rnd(4)-2,56+rnd(4)-2,4)
		
		printcos("you finally beat death",64,16,cc1)
		printcos("and reached the skelethrone!!!1",64,30,cc1)
		printcos("now suck it all up",64,108,cc2)
		return
	end
	

	--start screen
	if not gamestarted then
		--if(rnd()<0.33) cls(cc1)
		--if(rnd()<0.33) cls(cc2)
		--cc1=8+time()*0.5%6
		if timer==0 then
			col+=1
			cc1=8+col%8
		end
		
		cls(cc1)
		
		pal(8,cc1) pal(7,cc2) pal(0,cc3)
		for i=1,17 do
			for j=1,17 do
					spr(24,-8+i*8+sin(time()+i*0.1),-8+j*8+cos(time()+j*0.1) )
			end
		end
		
		sprs(32+flr(time()*0.5%12)*2+flr(time()*6%2),48,24,4)
		--sprs(32+12,48,24,4)
		
		pal()
		
		printcos("s k e l e t h r o n e",64,76,cc1)
		printmid("press — to start",64,96,cc2)
		
		return
	end
	
	map(0,0,0,0,lvsize+8,lvsize+8)
	
	if level==0 then
		printmid("move ‹”‘ƒ",128+44,128+32,cc1)
		printmid("use weapon Ž",128+48,128+70,cc1)
		printmid("change weapon —",128+48,128+78,cc1)
	end
	
	
	for b in all(bld) do
		spr(112,b.x,b.y)
	end
	
	
	for p in all(par) do
		circfill(p.x,p.y,p.s,p.c)
	end
	
	for c in all(cra) do
		spro(c.spr+time()*2%2,c.x,c.y)
	end
	
	pal(12,cc3)
	spr(21,stair.x*8,stair.y*8)
	pal()	

	for i in all(ite) do
		spro(i.spr,i.x,i.y+sin(time()+(i.x+i.y)*0.01 ))
		if (time()+i.x*0.1+i.y*0.2)%3<0.5 then
			sprow(i.spr,i.x,i.y+sin(time()+(i.x+i.y)*0.01),cc2 )
		end
	end
	
	if thronex!=0 and throney!=0 then
		spro(30,thronex,throney)
	end
	
	pal(12,cc3) pal(8,cc1)
	for g in all(gol) do
		--spro(g.spr+(time()*3+g.x)%2,g.x,g.y)	
		spr(g.spr+(time()*3+g.x)%2,g.x,g.y)
	end
	pal()
	
	-- bullets
	pal(8,cc1) pal(7,cc2) pal(0,cc3)
	for b in all(bul) do
		if(b.t==0) b.spr=115+time()*20%4--b.spr=49+time()*12%2
		if(b.t==1) b.spr=113+time()*12%2
		--b.spr=49+time()*12%2
		spr(b.spr,b.x,b.y)
	end
	
	for b in all(bom) do
		spr(126+time()*10%2,b.x,b.y)
	end
	
	for e in all(exp) do
		circfill(e.x,e.y,e.r,cc1)
	end
	
	for e in all(ene) do
		--if e.t==15 then
		--	if (e.dmgd>0) e.spr=30
		--	sprs(flr(e.spr),e.x,e.y,4)		
		--else
		
		if e.t==15 then
			circfill(e.x+3,e.y+3,12+sin(time())*2,cc1)
		end
		
			spro(e.spr,e.x,e.y)
			if(e.dmgd>0) sprow(e.spr,e.x,e.y,cc2)
		--end
		
		
		
		--printo("_",e.x,e.y,cc1)
		
		--printo(e.x.."_"..e.y,e.x,e.y,10)
		--print("x",e.tarx,e.tary,8)
		--if(e.t==9) spr(e.spr,e.x,e.y,4,4)
	end
	
	--shopkeeper
	--if shopk then
	--	spro(shopk.spr+time()*8%2,shopk.x,shopk.y)
	--	printo("hi",shopk.x,shopk.y-8,cc1)
	--end
	
	if pl.invi%3==0 then
		if not pl.dead then
			spro(pl.spr+time()*10%2,pl.x,pl.y)
		else
			spro(pl.spr,pl.x,pl.y)
		end
		if shield then
			circ(pl.x+4,pl.y+4,8,cc1)
		end
	end
	
	if pl.invi>40 then
		if(pl.invi%2==0)cls(cc1)
		if(pl.invi%2==1)cls(cc2)
		return
	end

	
	if texto>0 or texthold>0 then
		texto-=1
		printmid(text,cam.x+64,cam.y+64-24,cc1)
		printmid(text2,cam.x+64,cam.y+64-16,cc1)
		printmid(text3,cam.x+64,cam.y+64+16,cc2)
	end
	
	--printo(stat(1),cam.x+100,cam.y+16,8)
	--printo(stat(0),cam.x+100,cam.y+8+16,8)
	
	printo("hp="..pl.hp,cam.x,cam.y,cc1)
	printo("gold="..gold,cam.x+92,cam.y,cc1)
	--printo("level="..world.."-"..level,cam.x+64,cam.y,cc1)
	
	--printo(#cra,cam.x,cam.y+8,cc1)
	--printo(#ite,cam.x,cam.y+16,cc1)
	
	--printmid(inv[inv.sel],cam.x+64,cam.y,cc1)
	
	for i=1,#inv do
		local invx=cam.x+i*11-9
		local invy=cam.y+118
		if(i==inv.sel)	rectfill(invx-2,invy-2,invx+8+1,invy+8+1,cc1)
		spro(inv[i].spr,invx,invy)
		if inv[i].t==3 then
			printo(pl.bombs,cam.x+i*8+1,cam.y+122,cc1)
		end
	end
	
	--rect(invx-1,invy-1,invx+8+1,invy+8+1,cc3)
	
	--printo(inv.sel,pl.x,pl.y-8,cc1)
	
	if showcompass then
		spro(14+sin(time()*6)%2,mid(cam.x,stair.x*8,cam.x+120),
										mid(cam.y,stair.y*8,cam.y+120) )
	end
	
	--mappa
	for i=0,lvsize do
		for j=0,lvsize do
			--rect(cam.x+i,cam.y+j,cam.x+i,cam.y+j,lvl[i][j])
		end
	end
	
	--for i=1,100 do
	--	circ(pl.x,pl.y,32+i,0)
	--end
	
	--printo(#ene,cam.x+40,cam.y+40,8)

	
end

function dig()
	if(pl.dir==0) x=pl.x+4 y=pl.y-8+4
	if(pl.dir==1) x=pl.x+4+8 y=pl.y+4
	if(pl.dir==2) x=pl.x+4 y=pl.y+8+4
	if(pl.dir==3) x=pl.x+4-8 y=pl.y+4
	
	x=flr(x/8) y=flr(y/8)
	destroytile(x,y)
	
end

function destroytile(x,y)
	if gettile(x,y)==1 then
 	settile(x,y,13)
 	sfx(4)
 	setshake(6)
 	auto_tile(x-2,y-2,5,5)
 	for m=1,2 do
 		makepar(x*8+4,y*8+4,rnd(8),cc1)
 		makepar(x*8+4,y*8+4,rnd(8),cc2)
 	end
	end
end

function fillkapala()
	for b in all(bld) do
		if aabb(pl.x,pl.y,b.x,b.y) then
			del(bld,b) 
			kapala+=1 sfx(5)
			if(kapala>=8) kapala=0 pl.hp+=1 sfx(6)
		end
	end
end

function plshoot()
	pl.dir=pl.lastdir
		if pl.bult<=0 then
			dx =0 dy = 0
			if(pl.dir==0)	dy=-1
			if(pl.dir==1)	dx=1
			if(pl.dir==2)	dy=1
			if(pl.dir==3)	dx=-1
			eshoot(pl.x,pl.y,dx,dy,pl.shotspd,0)
			--eshoot(pl.x,pl.y,dx+dy,dx+dy,3,0)
			--eshoot(pl.x,pl.y,dx-dy,dx+dy,5,0)
			pl.bult=pl.shotrate
		end
end

function buldie(b)
	del(bul,b)
  	for i=1,5 do
  		makepar(b.x+rnd(8),b.y+rnd(8),rnd(5),cc1)
  		makepar(b.x+rnd(8),b.y+rnd(8),rnd(5),cc2)
  	end
  	setshake(2)
end

function madshopk(sh)
	sh.state,thief=1,true
	for i in all(ite) do
		i.price=0
	end
end

function dmgene(e)
	if(e.hp<=0) return
	e.hp-=1
	e.dmgd=3
	
	if(e.t==14) madshopk(e)
	
 if e.hp<=0 then
 	--if(e.t==0) then
 	--	makeene(e.x,e.y,0)
 	--	makeene(e.x,e.y,0)
 	--end
 	
 	if e.t==15 then
 		stair.x,stair.y,
 		bossx,bossy=32,32,e.x,e.y
 		finalexplos=60
 	
 		music(-1)
 	end
 	
 	local gg=flr(rnd(3))+e.g
 	if(e.t==5)gg=0 -- zombi give no mony
 	
 	for i=1,gg do
 		makegold(e.x+rnd(8)-4,e.y+rnd(8)-4)
 	end
 	
 	if(rnd()<0.02 and e.t!=5)makeitem(e.x,e.y,true)
 	
 	sfx(2)
 	
 	if(e.t==3)	explo(e.x,e.y)
 	if(e.t==6 and rnd(100)<5) makeitem(e.x,e.y,true,5)
 	
 	del(ene,e) makebld(e.x,e.y)
 end
end

function getgold(g)
	for i=1,3 do
		makepar(g.x+rnd(4)+2,g.y+rnd(4)+2,rnd(2)+2,cc1)
	end
	gold += 1
	sfx(0)
	del(gol,g)
end

function opencrate(c)
	
	for i=1,10 do
		makepar(c.x+rnd(8),c.y+rnd(8),rnd(4)+3,cc1)
		makepar(c.x+rnd(8),c.y+rnd(8),rnd(4)+3,cc3)
	end
	
	if rnd(100)<10 then
		makeitem(c.x,c.y,true)
	else
		for i=1,flr(rnd(10))+10 do
			makegold(c.x+rnd(8)-4,c.y+rnd(8)-4)
		end
	end
	
	sfx(2)
	del(cra,c)
end


function getitem(i) 

	if gold<i.price then
		texthold,text0=15,15
		text,text2,text3=
		"not enough currency","",""
		return
	end
	
	if(i.t==0) pl.hp+=1 text="hp up"
	if(i.t==1) pl.hp+=2 text="hp upper"
	if(i.t==2) pl.hp+=3 text="+3 hp"
	if(i.t==3) pl.bombs+=3 text="+3 bombs"
	if(i.t==4) pl.shotrate-=0.5 text="fire rate up"
	if(i.t==5) pl.shotspd+=1 text="faster bones"
	if(i.t==6) text="you know your way"
	if(i.t==7) text="time to mine!"
	if(i.t==8) text="dashman is back"
	if(i.t==9) text="blood for blood"
	if(i.t==10) text="protec from bully"
	
	text2,text3="",""
	texto = 30
	
	sfx(3)	
	gold-=i.price

	for m=1,10 do
		local c=cc1
		if(rnd()<0.5) c=cc2
		makepar(i.x+rnd(8),i.y+rnd(8),rnd(4)+3,c)
	end
	
	if (i.t>=6 and i.t<=10) or
	i.t==3 then
		addinv(i)
	end
	
	del(ite,i)
end

function dmgpl()
	if(pl.invi>0 or pl.dead) return
	pl.hp-=1
 pl.invi=45
 sfx(7)
 if(pl.hp<=0) then
 	pl.dead=true
		setshake(30)
		music(-1)
		sfx(30,3)
 end
end


function makepar(x,y,s,c)
	local p={x=x,y=y,s=s,c=c}
	add(par,p)
end

function makebld(x,y)
	local b={x=x,y=y}
	add(bld,b)
end

function makebomb(x,y)
	local b={x=x,y=y,time=30}
	add(bom,b)
end



function eshoot(x,y,dx,dy,spd,t)
	local b={t=t,x=x,y=y,
	dx=dx*spd,dy=dy*spd,
	spd=spd,spr=49,dist=0}
	
	add(bul,b)
	if(t==0) sfx(4)
	if(t==1) sfx(1)
end

--makeeneee -spawn
function makeene(x,y,t)

	if (#ene>50 and t!=14) return

	local e={x=x,y=y,t=t,hp=0,
	dmgd=0,tarx=0,tary=0,time=0,
	spd=1,inrng=false,g=0,rng=64,
	shotsp=0,maxtime=30}
	e.spr=0
	--slime
	if(t==0) e.hp=2 e.spd=0.25 e.g=0
	--witch
	if(t==1) e.hp=5	e.spd=1.25	e.g=3 e.shotsp=1.5
	--skull	
	if(t==2) e.hp=4	e.spd=1.25	e.g=2 e.shotsp=1.2
	--bomber
	if(t==3) e.hp=1	e.spd=1.25	e.g=5
	--ghost
	if(t==4) e.hp=1	e.spd=1.25	e.g=3
	--zombi
	if(t==5) e.hp=2	e.spd=1.0	e.g=1
	--tombstone
	if(t==6) e.hp=10	e.spd=0		e.g=5 e.maxtime=120 e.rng=128
	--imp
	if(t==7) e.hp=3	e.spd=1.0	e.g=1 e.shotsp=1.0
	--alien
	if(t==8) e.hp=4	e.spd=1	e.g=4 e.shotsp=1.1
	--hat
	if(t==9) e.hp=3	e.spd=1.25	e.g=5 e.shotsp=1.8 e.maxtime=60
	--bat
	if(t==10) e.hp=3	e.spd=1.5	e.g=4
	--vampire
	if(t==11) e.hp=8	e.spd=1.5	e.g=10 e.shotsp=1.0
	--death
	if(t==15) e.hp=200	e.spd=0.25	e.g=0 e.shotsp=2.0
	--shopkkeeper
	if(t==14) e.hp=50	e.spd=1.5	e.g=20 e.shotsp=3.0 e.state=0 e.rng=96
	
	
	--if(t==9) e.hp=40	e.spd=0.5	e.g=500

	add(ene,e)
end

function makecrate(x,y)
	local c={x=x,y=y,t=0,spr=19}	
	add(cra,c)
end

--itemss
function makeitem(x,y,isfree,_t)
	local tt=0
	
	if 				rnd()<0.2 then tt=1
	elseif rnd()<0.15 then tt=2
	elseif rnd()<0.1 then tt=3
	elseif rnd()<0.1 then tt=4
	elseif rnd()<0.15 then tt=5
	elseif rnd()<0.05 then tt=6
	elseif rnd()<0.04 then tt=7
	elseif rnd()<0.02 then tt=8
	elseif rnd()<0.01 then tt=9
	elseif rnd()<0.03 then tt=10
	end
	
	local i={x=x,y=y,t=tt,
	name="item",price=1}
	if(_t) i.t=flr(_t)
	i.spr=i.t+64
	if(i.t==0) i.name="coke" i.price=30
	if(i.t==1) i.name="candy" i.price=50
	if(i.t==2) i.name="candybar" i.price=70
	if(i.t==3) i.name="bombs" i.price=60+level*5
	if(i.t==4) i.name="new skul" i.price=160+level*30
	if(i.t==5) i.name="juicy bone" i.price=100+level*5
	if(i.t==6) i.name="compass" i.price=60+level*10
	if(i.t==7) i.name="pickaxe" i.price=200+level*20
	if(i.t==8) i.name="dasher" i.price=300+level*40
	if(i.t==9) i.name="kappala" i.price=420+level*30
	if(i.t==10) i.name="shield" i.price=220+level*10

	if(isfree) i.price=0
	
	add(ite,i)
end

function makegold(x,y)
	local g={x=x,y=y,spr=27}
	add(gol,g)
end

--exploo
function explo(x,y)
	for i=-2,2 do
		for j=-2,2 do
				if (i==-2 and j==-2)or
									(i==2 and j==-2)or
									(i==-2 and j==2)or
									(i==2 and j==2)
							then
				else
				settile(flr((x+4)/8)+i,flr((y+4)/8)+j,13)
				--makedust(flr((x+4)/8)*8+i*8,flr((y+4)/8)*8+j*8)
				sfx(2)
				for m=1,2 do
					local c=cc1
					if(rnd()<0.5) c=cc2
					makepar(x+4+i*8,y+4+j*8,rnd(8),c)
				end
			end
		end
	end
	
	auto_tile(flr((x+4)/8)-3,flr((y+4)/8)-3,6,6)
	--auto_tile(0,0,lvsize,lvsize)
	
	local e={x=x+4,y=y+4,t=4,r=24}
	add(exp,e)
	
	setshake(12)
end




function move(o,dx,dy)
	local lx=o.x -- last x
 local ly=o.y -- last y
	
	local dxx=flr(dx)
	local dyy=flr(dy)
	
	--local fx=o.x%1
	--local fy=o.y%1
	
	--o.x=flr(o.x)
	--o.y=flr(o.y)
	
	for i=1,abs(dxx) do
		lx=o.x
 	o.x+=sign(dx)
 	
 	if(dx>0) dx-=1
 	if(dx<0) dx+=1
 	
 	if cmap(o) then
 		o.x=lx
 		o.dx=0
 		break
		end
	end

 for i=1,abs(dyy) do
 	ly=o.y
 	o.y+=sign(dy)
 	
 	if(dy>0) dy-=1
 	if(dy<0) dy+=1
 	
 	if cmap(o) then
 		o.y=ly
 		o.dy=0
 		break
		end
 end
 
 --o.x+=fx 
	--o.y+=fy
	lx=o.x
	ly=o.y

 if(abs(dx)<1) o.x+=dx
	if cmap(o) then
 	o.x=lx
 	o.dx=0
 end

 if(abs(dy)<1) o.y+=dy
	if cmap(o) then
 	o.y=ly
 	o.dy=0
 end
 


end

function cmap(o)

    local x1=o.x/8
    local y1=o.y/8
    local x2=(o.x+7)/8
    local y2=(o.y+7)/8
    local a=fget(mget(x1,y1),0)
    local b=fget(mget(x2,y1),0)
    local c=fget(mget(x2,y2),0)
    local d=fget(mget(x1,y2),0)

    return a or b or c or d

end

function sign(num)
	if(num<0) return -1
	if(num>0) return 1
	return 0
end

function aabb(x1,y1,x2,y2)
	if x1 < x2+8 and
				x1+8 > x2 and
				y1 < y2+8 and
				y1+8 > y2 then
		return true
	end
end

--function aabbw(x1,y1,x2,y2,w1,w2)
--	if(x1 < x2+w2 and
--				x1+w1 > x2 and
--				y1 < y2+w2 and
--				y1+w1 > y2) then
--		return true
--	end
--end

function spro(sp,x,y)
	for i=1,15 do
		pal(i,cc3)
	end
	
	for i=-1,1 do
		for j=-1,1 do
			spr(sp,x+i,y+j)
		end
	end
	
	pal()
	pal(8,cc1)
	pal(7,cc2)
	spr(sp,x,y)
end

function sprow(sp,x,y,c1)
	for i=1,15 do
		pal(i,cc3)
	end
	
	for i=-1,1 do
		for j=-1,1 do
			spr(sp,x+i,y+j)
		end
	end
	
	for i=1,15 do
		pal(i,c1)
	end
	spr(sp,x,y)
	pal()
end

function printo(str,x,y,c)
	
	for i=-1,1 do
		for j=-1,2 do
			print(str,x+i,y+j,cc3)
		end
	end
	print(str,x,y,c)
end

function printmid(str,x,y,c)
	printo(str,x-(#str*4)/2,y,c)
end

function printcos(str,x,y,c)
	local l=#str
	for i=1,l do
		local char=sub(str,i,i)
		printo(char,x+i*4-l*2-4,y+sin(time()+i*0.08)*3,c)
	end
end

function makelvl()

	--settile(wlk.x,wlk.y,1)
	local t=0

	if wlk.x<2 or wlk.x>lvsize-2
	or wlk.y<2 or wlk.y>lvsize-2 then
		wlk.dir+=1
		else
		if rnd(100)<turnchance then
			if rnd()<0.5 then wlk.dir += 1
			else wlk.dir -= 1
			end
		end
		if rnd(100)<turnback then
			wlk.dir += 2
			--settile(wlk.x,wlk.y,4)
			--if(rnd(100)<20)	t=3
			if(rnd(100)<10)	makecrate(wlk.x*8,wlk.y*8)
		end
	end

	-- room
	if rnd(100)<5 then
		local roomtype=0
		if rnd(100)<10 then
			roomtype=1
		end
		
		if roomtype==1 then
			for i=-4,4 do
				for j=-3,3 do
					--t=13
					--settile(wlk.x+i,wlk.y+j,t)
				end
			end
		end
		
		for i=-3,3 do
			for j=-2,2 do
				t=0
				--if(roomtype==1) t=2
				--if(i==-2) t=2
				settile(wlk.x+i,wlk.y+j,t)
			end
		end
		
	end
	
	settile(wlk.x,wlk.y,t)

	wlk.dir%=4
	if(wlk.dir==0) wlk.y-=1
	if(wlk.dir==1) wlk.x+=1
	if(wlk.dir==2) wlk.y+=1
	if(wlk.dir==3) wlk.x-=1
	--wlk.steps+=1


end

function settile(x,y,t)
	if(x<0 or x>lvsize or y<0 or y>lvsize) return
	if(x==0 or x==lvsize-0 or y==0 or y==lvsize-0) t=1
	
	if t==0 then
		--enemy gen
		local tt=-1
		local multi=35
		
		if world==1 then
			if rnd(6*multi)<1 then 
				tt=7
			elseif rnd(12*multi)<1 then 
				tt=2
			elseif rnd(3*multi)<1 then 
				tt=0
			elseif rnd(48*multi)<1 then 
				tt=1
			end
		end
		
		if world==2 then
			if rnd(6*multi)<1 then 
				tt=2 --skull
			elseif rnd(12*multi)<1 then 
				tt=6 --tombstone
			elseif rnd(24*multi)<1 then 
				tt=3	--bomber
			elseif rnd(12*multi)<1 then 
				tt=1	--witch
			end
		end
		
		if world==3 then
			if 				rnd(6*multi)<1 then 
				tt=8	--alien
			elseif rnd(6*multi)<1 then 
				tt=10 --bat
			elseif rnd(24*multi)<1 then 
				tt=9 --hatto
			elseif rnd(12*multi)<1 then 
				tt=4	--ghost
			elseif rnd(24*multi)<1 then 
				tt=6	--tomb
			end
		end
		
		if world==4 then
			if 				rnd(6*multi)<1 then 
				tt=4	--ghost
			elseif rnd(6*multi)<1 then 
				tt=2 --skull
			elseif rnd(24*multi)<1 then 
				tt=7 --imp
			elseif rnd(12*multi)<1 then 
				tt=9	--hat
			elseif rnd(24*multi)<1 then 
				tt=11	--vampi
			end
		end
		
		-- enemy spawn
		if(tt!=-1)	makeene(x*8,y*8,tt)
	
	end
	
	if lvl[x][y]!=0 and t==0 then
		wlk.steps+=1
	end 
	
	--if((lvl[x][y]==2 or
	--lvl[x][y]==13) and t==0) then
	--	return
	--end
				
	lvl[x][y]=t
	if(t==13) lvl[x][y]=0
	if(t==0 and rnd()<0.1) t=6+flr(rnd(3)) 
	mset(x,y,t+16)
end

function makeshop(t)

	-- t==0 shop
	-- t==1 throne room

	local cx=flr(rnd(lvsize)) --shop center
	local cy=flr(rnd(lvsize)) --shop center

	--check if center is wall
	while gettile(cx,cy)!=1 do
		cx=flr(rnd(lvsize))
		cy=flr(rnd(lvsize))
	end
	
	--check if center is near floor
	local isnear=-1
	for i=0,8 do
		if(gettile(cx+i,cy)==0) isnear=1
	end
	for i=0,8 do
		if(gettile(cx,cy+i)==0) isnear=2
	end
	for i=-8,0 do
		if(gettile(cx+i,cy)==0) isnear=3
	end
	for i=-8,0 do
		if(gettile(cx,cy+i)==0) isnear=0
	end
	
	if(isnear==-1) makeshop(t) return
	
	for i=-3,3 do
		for j=-3,3 do
			if(gettile(cx+i,cy+j)!=1) then
				makeshop(t)
				return
			end
		end
	end
	
	--shopkeeper test
	if t==0 then
		makeene(cx*8,cy*8,14)
	end
	
	for i=-2,2 do
		for j=-2,2 do
			if(t==0) settile(cx+i,cy+j,2)
			if(t==1) settile(cx+i,cy+j,10)
			
			-- shop items
			if t==0 then
			--shop
				if (i==-1 and j==1) or
							(i==1 and j==-1) or
							(i==1 and j==1) then
					makeitem((cx+i)*8,(cy+j)*8,false,rnd(11) )
				end
				-- always spawn one coke
				if (i==-1 and j==-1) makeitem((cx+i)*8,(cy+j)*8,false,rnd(3) )
				
				
				
			elseif i==0 and j==0 then
			--throne
				--settile(cx+i,cy+j,14)
				thronex=(cx+i)*8
				throney=(cy+j)*8
			end
			
			
			
			
		end
	end
	
	-- if throne no connect
	if(t==1) return
	
	-- connect shop to level
	wlk.x=cx wlk.y=cy
	while(gettile(wlk.x,wlk.y)!=0) do
		
		--if(wlk.x-stair.x>0) wlk.dir=3
		--if(wlk.x-stair.x<0) wlk.dir=1
		--if(abs(wlk.x-stair.x)<16) then
		--	if(wlk.y-stair.y>0) wlk.dir=0
		--	if(wlk.y-stair.y<0) wlk.dir=2
		--end
		wlk.dir=isnear

	if gettile(wlk.x,wlk.y)!=2 and
				gettile(wlk.x,wlk.y)!=5 then
	 settile(wlk.x,wlk.y,0)
	end
	 
		if(wlk.dir==0) wlk.y-=1
		if(wlk.dir==1) wlk.x+=1
		if(wlk.dir==2) wlk.y+=1
		if(wlk.dir==3) wlk.x-=1
	
	end

end


function mag(x,y)
	return sqrt((x)^2+(y)^2)
end

function norm(a)
	local mag=mag(a.x/1000,a.y/1000)*1000
	if mag > 0 then
		a.x=a.x/mag
		a.y=a.y/mag
	else
		a.x=a.x
		a.y=a.y
	end
	return a
end

function setshake(s)
	if(s>shake) shake=s
end

function gettile(x,y)
	if x<1 or x>lvsize-1 or y<1 or y>lvsize-1 then
		return -1
	end
	return lvl[x][y]
end

function auto_tile(x,y,w,h)
 for i=x,x+w do
  for j=y,y+h do
   tile=mget(i, j)
   --printh(tile)
   if fget(tile,0) then
    this_flag=fget(mget(i,j),0)
    if this_flag then
     --this tile should be autotiled
     if fget(mget(i, j-1), 0) then flag_above = 1 else flag_above = 0 end
     if fget(mget(i, j+1), 0) then flag_below = 1 else flag_below = 0 end
     if fget(mget(i-1, j), 0) then flag_left = 1 else flag_left = 0 end
     if fget(mget(i+1, j), 0) then flag_right = 1 else flag_right = 0 end

     new_tile = (1*flag_above) + (2*flag_left) + (4*flag_right) + (8*flag_below)
     --printh('tile '..new_tile)
     mset(i, j, new_tile+96)
					--return new_tile+96
   	end
   end
 	end
 end
end

function dstk(x0,y0,x1,y1)
 local dx=x0/1000-x1/1000
 local dy=y0/1000-y1/1000
 local dsq=dx^2+dy^2
 
 if dsq>0 then
  return sqrt(dsq)
 elseif dsq==0 then
  return 0
 else
  --shouldn't happen
  return 32727
 end
end

function sprs(sp,x,y,scale)
	local border=scale
	for i=1,15 do
		pal(i,cc3)
	end
		sspr(sp%16*8,flr(sp/16)*8,8,8,x,y+border,8*scale,8*scale)
		sspr(sp%16*8,flr(sp/16)*8,8,8,x+border,y+border,8*scale,8*scale)
		sspr(sp%16*8,flr(sp/16)*8,8,8,x+border,y,8*scale,8*scale)
		sspr(sp%16*8,flr(sp/16)*8,8,8,x+border,y-border,8*scale,8*scale)
		sspr(sp%16*8,flr(sp/16)*8,8,8,x,y-border,8*scale,8*scale)	
		sspr(sp%16*8,flr(sp/16)*8,8,8,x-border,y-border,8*scale,8*scale)
		sspr(sp%16*8,flr(sp/16)*8,8,8,x-border,y,8*scale,8*scale)
		sspr(sp%16*8,flr(sp/16)*8,8,8,x-border,y+border,8*scale,8*scale)	
	pal()
	pal(8,cc1) pal(7,cc2) pal(0,cc3)
	sspr(sp%16*8,flr(sp/16)*8,8,8,x,y,8*scale,8*scale)
	
end
__gfx__
00000000007787000000000000778700000000000007780000000000000000000080080000000000000000000000000000000000000000000077770000888800
00000000000870000078770000087000007877000007780000000000000770000087880000800800000000000000000000000000000000000007700000088000
00700700070770700007800007077070000780000777777800088000000778008008700000887800000000000000000000000000000000008000000870000007
00077000707007070707707070700707070770700777777800077000008770000888888000078008000000000077000000000000000000008800008877000077
00077000700770077070070770077007707007070007780000777700007777000088880808888880000000000077000000000000000000008800008877000077
00700700707007077007700770700707700770070007780007888870078888700088880080888800000000000000000000000000000000008000000870000007
00000000007007007070070700000700707007070007780007888870078888700000080000888800000000000000000000000000000000000007700000088000
00000000007007000070070000000700007000000007780000700700007007000000080000800000000000000000000000000000000000000077770000888800
00000000077777700077007700070000000700000777777000000000000000000000000000000000008800000000000000000000000700070078870000000000
0000000077777777007700770007700000077000788cccc700000000000777000000007000000000088880880000000000000000000007000078870000000000
0000000077777777880077000888888008888880788cccc7000000000000000000700000000000000888808800cccc0000cccc00070070000078870000000000
0000000077777777880077008888808888088888788c8cc7000000000700000000000000000000000888000000c88c0000c77c00007000700078870000000000
0000000077777777007700778808808888088088788c8cc7000707000000077000070000007700000000000000c88c0000c77c00000000007788887700000000
0000000077777777007700778888888888888888788c8c87000070000070000000000700000007708880088000cccc0000cccc00007007000788887000000000
0000000077777777770088008870708888707088788c8c8700000000000000000000000000700000088088800000000000000000770000000777777000000000
00000000077777707700880008888880088888800777777000000000000000000000000000000000000008000000000000000000000007000700007000000000
00888800000000007008780000000000077777700000000000070000000000000077770000777700000700000000000000088700000000000070078000000000
08000080008888000707000000087807778778770777777008888880000700000777777007777770007787000007000000088700000887000888808000700780
08077080080000800077770000070070788888877787787788888788088888807777077777077777008777000087770008888887000887000880888008888080
80007008080770800008807000777700778778777888888788788888887888887707077777070777070077770077870008888887088888870088800008808880
80000008800070080008800707088000777007777787787788080808888887887707777777770777700770077770777000088700088888878888888800888000
80000008800000080088880070088000007007007777777708888880880808087777777777777777700777007007700700088700000887000088880088888888
80000008800000080888888000888800007777000077770000700000088888807707707777077077700707000007770700088700000887000080000000888800
08888880088888800888888008888880000000000077770000700000000007007007000770070007000700000000070000088700000887000080000000000800
00888800000000000070000000000000000000000000000080700708000000000078700000000000000000000000000000800800000000008888000088880008
08877880008888000007000000700000000000000000000008787780807007080077800000787000000000000000000000878800008008000087800800888087
88700788088778800007700000070000008008008000000800078000087787800007777700778000000000000000000000087000008878000087808700878007
88700788887007880077770000077000088788808000000800700700000870000077700700077777000000000000000008888880000780008888880708878887
08877880887007887777777700777700800870080888788008777780007007000077777000777007000000000000000080888808088888800088808780888007
00888800088778800088880077777777800000080807808088777788087777800000707000777770000000000000000008888880808888080088800700888007
00800000008888000088880000888800000000000000000088777788887777880000700000707070000000000000000000800800088888800888880708888807
00800000000008000000080000800000000000000000000000000700887000880000700000700000000000000000000000800800008008008888888788888880
00000000000000000008000000700000000000000000000000000000000880000000000000777770007777000000000000000000000000000000000000000000
00000000000008000070700000070000007777700000070000077000000008700000000007000007070000700077770000000000000000000000000000000000
00088000000008700080800000077000077877770000077000778700000007800087000007000007700000070007700000000000000000000000000000000000
00087000000870000000700000788700077878770000700007788770000070080088000007777777700007070070070000000000000000000000000000000000
00078000000870000000800007887870077778770007000007788770000700080087000007887887700000070788887000000000000000000000000000000000
00087000088000000000700007888870007777700770000000777700007000000088880007887887700000070788887000000000000000000000000000000000
00000000007000000000800000788700007070700070000000077000070000000077770000777770070000700788887000000000000000000000000000000000
00000000000000000000000000077000000000000000000000000000000000000000000000707070007777000077770000000000000000000000000000000000
00788700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00788700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00788700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00788700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77888877000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07888870000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880877777788888888087777778088888888777777888888888877777780888888087777778888888808777777808888888877777788888888887777778
88777788877777787777778877777778887777778777777777777777777777778877778887777778777777887777777888777777877777777777777777777777
87777778877777787777777877777778877777778777777777777777777777778777777887777778777777787777777887777777877777777777777777777777
88777788887777887777778877777788887777778877777777777777777777778777777887777778777777787777777887777777877777777777777777778777
88888888888888888888888888888888888888888888888888888888888888888777777887777778777777787777777887777777877777777777777777787877
88888888888888888888888888888888888888888888888888888888888888888777777887777778777777787777777887777777877777777777777777777777
88888888888888888888888888888888888888888888888888888888888888888777777887777778777777787777777887777777877777777777777777777777
08888880088888808888888088888880088888880888888888888888888888888777777887777778877777788777777887777778877777788777777887777778
00000000007777000088880000000770000000000770000000770700000000000000000000770000000700070000000000000000000000000070000000800000
08080800078888700877778000000777000000007770000000777700077777700000000007777077000007000000000000000000000000000007000000080000
00088080788888878777777800007777770000777777000000077000070777700008800007777077070070000000000000000000000000000008800000077000
08080808788888878777777800077700077777770077700000077000077770700008700007770000007000000000000000000000000000000080080000788700
80808880788888878777777800777000777777700007770000077000077777700007800000000000000000700000000000000000000000000800708007887870
08080808788888878777777877770000770000770000777700077000007777000008700077700770007000000000000000000000000000000800008007888870
00808080078888700877778077700000000000000000077700777700000770000000000007707770700000000000000000000000000000000080080000788700
00080000007777000088880007700000000000000000077000707700000000000000000000000700000007000000000000000000000000000008800000077000
08888880007700000877808800007700770777770070000000770000000000000777777000000000000000000000000000000000000000010101010101010101
00878788077770778777787707700770770777770170010107888078070101017777777701010101010101010101010101010101010101000000000000000000
88777778077770778777787700000000000000007777777707888088070000007700007700000000000000000000000000000000000000010101010101010101
00777788077700008777808877007700777707770101700107880000070770017700007701010101010101010101010109010101010188888000000000000000
88777778000000008888088000707770777707770000700000000000070770007700007700000000000000000000000000900000888899999888880000000099
00777788777007707778877870007000777707770000700078800780070770807700007700000000000000000000000000990008899999999999998800000990
88787878077077708778777877000007000000007777777708807880070770807777777700000000000000000000000000099089999999999999999980009000
00888880000007000888878077077700770777770070000000000800000000000777777000000000000000000000000000009899999999999999999988009000
11000000000000111111111100000000110011111111111111111111111111111100000000111111111111111111111111008999999999999977777998990000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008999999999999777777798900000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000089999777999999777007799800000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000899777777799999777007799800000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000899777777799999777777799800000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000899770007799999977777999800000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000899770007799999999999999980000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000899777777999999999999999980000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000899777779999999999999999980000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000899999999999999999999999980000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000899999999999999999999999800000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000899999899999999999999999800000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000089999899999999999999888800000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000089999899999999999988080000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888888800080000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000080000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000080000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000080000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000080000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000080000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000080000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000080000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099900000000000099999900000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099990000000000000000000000
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
0000000000000000000000000000000000010000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010100000000000000000000000000000000
0000000000000000000000000000000001000000010001010001000000000000010101010101010101010101010101010000010101010101010101010101010101010100000001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000
1111111100000000000000001111111111111111110000000000000000000011110000000000000000000000000000110000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000
1111110019000016000000000011111111110000000000000000000000000011110000000000000000000000000000110000000000000010101010101010101000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000
1111000000000000000016000000111111000000000000000000000000000000000000000000000000000000000000110000000000000010101010101010101000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000
1100000000000000000000000000001111000000000000000000110000000000000000000000000000000000000000110000000000000010101010101010101000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000
1100000019001111111100000000001111000000001111000000000000000011110000000000000000000000000000110000000000000010101010101010101000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000
1100190000000000000019000000001111000011111111000000000000000011110000000000000000000000000000110000000000000010101010101010101000101010101010111110101010101010101010101010101010111110101010101010101010101010101010101010101010101010101010000000000000000000
1100001600000000000000001700000000000000000000000000000000000011110000000000000000000000000000110000000000000010101010101010101000101010101010111110101010101010101010101010101010111110101010101010101010101010101010101010101010101010101010000000000000000000
1100000000000000161700180000000000000000000000000000000000000011110000000000000000000000000000110000000000000010101010101010101000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000
1100110000000000000000000000001111000000000000000000000000000011110000000000000000000000000000110000000000000010101010101010101000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000
1100110000000000000000001700001111000000000014140000001100000011110000000000000000000000000000110000000000000010101010101010101000101010101010101010101111101010101010101011111010101010101010101010101010101010101010101010101010101010101010000000000000000000
1111110018001600000000000000001111000000000014140000001111000011110000000000000000000000000000110000000000000010101010101010101000101010101010101010101111101010101010101011111010101010101010101010101010101010101010101010101010101010101010000000000000000000
1111000000000000000000160000111111000011000000000000111111000011110000000000000000000000000000110000000000000010101010101010101000101010101010101010100010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000
1111110000000000180000000011111111001111000000000000000000000011110000000000000000000000000000110000000000000010101010101010101000101010101010101010100010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000
1111111100000000000000001111111111001111000000000000000000000011110000000000000000000000000011110000000000000010101010101010101000111111101010101010100010101010101010101010101010101010101011111110101010101010101010101010101010101010101010000000000000000000
1111111111111100001111111111111111111111111111000011111111111111111111111111111111000011111111110000000000000010101010101010101000111111111010101010100010101010101010101010101010101010101111111110101010101010101010101010101010101010101010000000000000000000
1111111111111100001111111111111111111111111111000011111111111111111111111111111111000011111111110000000000000010101010101010101000111111111010101010100010101010101010101010101010101010101111111110101010101010101010101010101010101010101010000000000000000000
1100000000000000000000000000001111111111111100000000000000001111111111111111111111000011111111110000000000000010101010101010101000111111111010101010101010101010101010101010101010101010101111111110101010101010101010101010101010101010101010000000000000000000
1100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000110000000000000010101010101010101000111111101010101010100010101010101010101010101010101010101011111110101010101010101010101010101010101010101010000000000000000000
1100000000000000000000000000001111000000000000000000160000000011110000000000000000000000000000110000000000000010101010101010101000101010101010101010100010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000
1100000000000000000000000000001111000000000000000000000000000011110000000000000000000000000000110000000000000010101010101010101000101010101010101010100000000000100000000000001010101010101010101010101010101010101010101010101010101010101010000000000000000000
1100000000000000111100000000001111110000000000000000000000000000000000000000000000000000000000110000000000000010101010101010101000101010101010101010101111101010101010101011110010101010101010101010101010101010101010101010101010101010101010000000000000000000
1100000000000011111100000000001111110000160000000000000000000000000000000000000000000000000000110000000000000010101010101010101000101010101010101010101111101010101010101011110010101010101010101010101010101010101010101010101010101010101010000000000000000000
1100000000001111001100000000001111110000000000111100000000000011110000000000000000000000000000110000000000000010101010101010101000101010101010101010100010101010101010101010001010101010101010101010101010101010101010101010101010101010101010000000000000000000
1100000000001111111100000000000000000000000000111111000000160011110000000000000011110000000000110000000000000010101010101010101000101010101000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010101010000000000000000000
1100000000000011111100000000000000000000000011111111110000000011110000000000000011110000000000110000000000000010101010101010101000101010101000111100000000000000000000000000000000111100001010101010101010101010101010101010101010101010101010000000000000000000
1100000000000011000000000000001111110000000011111100000000000011110000000000000000000000000000110000000000000010101010101010101000101010101010111110101010100000100000000000001000111100001010101010101010101010101010101010101010101010101010000000000000000000
1100000000000000000000000000001111110000001111110000001111000011110000000000000000000000000000110000000000000010101010101010101000101010101010101010101010100000000000000000000000000000001010101010101010101010101010101010101010101010101010000000000000000000
1100000000000000000000000000001111110000000000000011000011000011110000000000000000000000000000110000000000000010101010101010101000101010101010101010101010100000000010101010001010100000101010101010101010101010101010101010101010101010101010000000000000000000
1100000000000000000000000000001111000000000000000000000000001111110000000000000000000000000000110000000000000010101010101010101000101010101010101010101010100000000000000000000000000010101010101010101010101010101010101010101010101010101010000000000000000000
1100000000000000000000000011111111111111111111111111111111111111111111111111111111111111111111110000000000000010101010101010101000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000010101010101010101000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000
__sfx__
010600001375521755337550070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
000400001e1730c163001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103
000500002065018640116300c62007610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000e7520e742267312672126711267152670200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702
000200000b06111051060410b02105011000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000d75119711287310170000700317213d71100700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00040000117510b7411c7310b7212e721007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000300001607101071000510000000051000310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001d45018450134400d4400a440074300443003420024200141000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
010500002465415644086240561403614026040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604
01060000057510c7411373121721307111e711167110f7110a7110671103711027110171101700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100020230430e03306023020133760537605000030000310625106151c6021c60010625106150000300003230430e0330602302013170030e003060030200310625106151c6020000337605376051062510615
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01180020020550b73507135020450b725131250204502735021450c0350a74507135020450a7350715502035027450b15507025027350b145130350275502125020351c7450a15513035107450a1351701123725
01060020170530e0530604302033376253761500003000031c6451c6151c6021c60037621376150000300003170530e0530604302033170530e05306043020331c6451c6151c6020000337625376150000300003
01180020020550b735131351a0450b725131251a045027350e1450003522745131350204522735071550e0351a7450b155130251a7350b145130351a755021251a035107450a1551f035107420a1321701223722
01180020020520b732131320e0420b722131220e042027320e1420003216742131320204216732071520e0320e7420b152130220e7320b142130320e752021220e032107420a15213032107420a1321701123721
011800001d525225051f5350050523505225051f505005051d525225051f535005051a5051a5221f505005051d525225051f5350050523505225051f505005051d525225051f535005051a5051a5251f50500505
01080020170530e0530604302033376053760500003000031c6451c6151c6021c6001c6451c6150000300003170530e0530604302033170030e00306003020031c6451c6151c6020000337605376051c6451c615
012000001b7571e757227571e7571b7571e757227571e7571b7571e757237571e7571b7571e757237571e7571e7572275725757227571e7572275725757227571d7572275725757227571d757227572575722757
01140020020450e045020350e055020350e045020550e035000450c055000350c045000550c035000450c055020350e045020550e035020450e055020350e0450505511035050451105505035110450505511035
011400200e7350e7450e7310e7451173511741137351374116731167451673216742137311372511745117310e7250e7450e7250e731117451173213722137451072510735107411072511731117421073110732
011400201a7550e7451a7310e7551d735117411f75513731227411675522742167521f741137551d745117511a7450e7351a7450e7511d735117421f752137451c755107451c751107451d731117421c75110742
0137051e0960412600056140f6100c6100a6100e610066100e6100c61010610106100e6100e6100e610166100a610106101161012610156100d6100a6100e6100d6100d6100f6100b6100a6100b6100861000600
01040020170530e05306043020331c6031c60000003000031c6451c6151c6021c60000003000030000300003170530e0530604302033170530e05306043020331c6451c6151c6020000300003000030000300003
011000200b5451275517735151450b5551273517145155550b7351214517555137350b145125551774513135097551254513155127450953512145137551253509145107550e5350d14509755105350e7450d155
012000200b755125550b755105550b755125550b155107550b555107550b1550e7550b557107550b1520d75507555077050753107755071550775507555077550915509705095410975509555097551214412755
012000001e5221e7221e5321e7321e5421e7421c5321c5321a5221a5221a5321a732197421974219537197371a5221a7221a5321a5321c7411c5421c5321c7321952219532197321953221742215422373123031
012000001e5221e7221e5321e732215422374221031235351f5261f5221f5361f7321c742197021c5371c7371c5221c7221c5321c5321f7411f5421f5321f7321a5221a5321a7321a53219742195422373125035
010a0000187530c7230c7030c7033c6353c6150000300003187530c7230c703000033c6053c6050000300003187530c7230c703000033c6053c6050000300003187530c7230c703000033c6053c6150000300003
010a0000187530c7230c7030c70324635246150000300003187530c7230c703000032463524615187530c723187530c7230c7030000324635246150000300003187530c723187530c72324635187530000318753
010d0020170530e05306043020333c6151c60000003000031c6551c6151c6021c600000033c6153c0053c611170530e0530604302033170530e05306043020331c6551c6151c602000033c6153c6213c0033c615
010d0020170530e05306043020331c6031c60000003000031c6451c6151c6021c60000003000030000300003170530e0530604302033170530e05306043020331c6451c6151c6020000300003000030000300003
011a00200e1550e1251a7511a1050e052001051a752001000905500702001001d0051f0051d0551c051180550e7551a1051a0521a7020e155000021a155007051105210102107050010210055007050010000702
011a00200e1550e1251a7511a1050e052001051a752001000905500702001001d1351c7410c0251c000180050e7551a1051a0521a7020e155000021a155007051105211042110321101216051160211803118042
011a002028055280021a0022805528055000052405500000260552800000000260052604126022290451800528055280021a0022805528055000052b035000002d0422d0422d0322d01221002160002903129020
011a002028055280021a0022805528055000052405500000260552800000000260052604124022240451800521055280021a002210552405500005210350000026045260022d0022d00221002160001a0301a020
01100020120551205119052000051a055000050000500005120551205119052000051c055000050000500005120551205119052000051a0550000500005000051205512051190520000515052000051405500005
011000001e555235031e55223507235031e5541e55500507125521a5321c54512552195421a552005040050521542215352155200502005022155221532005021a5521a532005021953319542005001554115555
0110000017552175451755717535235471755123532175402354500007000000000200000000051e5370000020530145422055714535205401455120532145472055500000000000000200007000051953200000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800000e7320070213742007020f732007020c732007020e732007021673216702157420070211722007020e7320070213742007020f722007020c732007020e7320e7420c7220e7020e7220e7420a73200702
0118000013141131311313113121131211311113111131111a1411a1311a1311a1211a1211a1111a1111a11115141151311513115121151211511115111151111614116131161311612116121161111611116111
0118000013141131311313113121131211f1111f1111f1111a1411a1311a1311a1211a1211a1111a1111a111151411513115131151211512121111211112111122141221312213122121221211d1111d1111d111
011800001f1411f1311f1311f1211f1211d1111d1111d1111a1411a1311a1311a1211a1211a1111a1111a1111b1411b1311b1311b1211b1211a1111a1111a1111814118131181311812118121161111611116111
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
00 21 42 43 44
00 21 42 43 44
01 21 22 1f 44
00 21 23 1f 44
00 21 42 1f 44
02 21 42 1f 44
00 41 42 43 44
00 41 42 43 44
01 14 42 43 44
00 16 42 43 44
00 17 15 43 44
00 17 15 43 44
00 17 42 18 44
02 14 42 18 44
00 41 42 43 44
03 11 42 43 44
00 41 42 43 44
01 28 27 43 44
00 29 27 43 44
00 28 26 43 44
00 29 26 43 44
00 28 27 2a 44
00 28 27 2b 44
00 28 26 2a 44
02 28 26 2b 44
01 19 2c 43 44
00 19 2c 43 44
00 1f 2c 2d 44
00 19 2c 2d 44
00 1f 2c 2e 44
02 1f 2c 2e 44
01 1b 1c 43 44
00 1b 1d 43 44
00 1b 1c 24 44
00 1b 1d 24 44
00 1b 1c 25 44
00 1b 1d 25 44
00 1b 42 25 44
00 1b 42 43 44
00 1b 42 25 44
02 1b 42 25 44
00 41 42 43 44
01 30 42 43 44
00 30 42 43 44
00 30 31 43 44
00 30 32 43 44
00 30 33 43 44
02 30 31 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
