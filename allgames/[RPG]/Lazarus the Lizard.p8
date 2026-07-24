pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--lazarus the lizard
--a simple rpg
wall=1
border=2
screenx=0
screeny=0
bulletdamage=1

screenx_old=-1
screenx_old=-1
hp=3
hpmax=3
money=0
string0="this message is a test"
string1="hooray for that"
showingstring=false
gameover=false
key0=false
key1=false
key2=false
bluefire=false
titlescreen=true
function _init()
	for y=0,16 do
		for x=0,16 do
			if (mget(x,y)==3) then
				player = new_player(x*8,y*8)
				--player = new_player(103*8,50*8)
				mset(x,y,1)
			end
		end
	end
	music(0)
	addnpcs()
end

function loadmap()
	ym = screeny/8
	xm = screenx/8
	for y=ym,ym+16 do
		for x=xm,xm+16 do
			if (mget(x,y)==9) then
				mset(x,y,1)
				e=new_enemy(x*8,y*8)
				e.numframes=0
				add(enemies,e)
			end
			if (mget(x,y)==29) then
				mset(x,y,1)
				e=new_enemy(x*8,y*8)
				e.numframes=0
				e.hp=2
				e.value=3
				e.shoots=true
				add(enemies,e)
			end
			
			if (mget(x,y)==129) then
				mset(x,y,96)
				e=new_enemy(x*8,y*8)
				e.numframes=0
				e.hp=2
				e.value=3
				e.shoots=true
				add(enemies,e)
			end
			
			if	(mget(x,y)==88)	then
				if(key0 and key1 and key2)then
					mset(x,y,01)
				end
			end
			if (mget(x,y)==30) then
				mset(x,y,27)
				e=new_enemy(x*8,y*8)
				e.numframes=0
				e.hp=2
				e.value=3
				e.shoots=true
				add(enemies,e)
			end
			
			if (mget(x,y)==10) then
				mset(x,y,27)
				e=new_enemy(x*8,y*8)
				e.numframes=0
				add(enemies,e)
			end
			
			if (mget(x,y)==25)then
				mset(x,y,1)
				e=new_enemy(x*8,y*8)
				e.initframe=25
				e.curframe=25
				e.value=2
				add(enemies,e)
			end
			if (mget(x,y)==26)then
				mset(x,y,27)
				e=new_enemy(x*8,y*8)
				e.initframe=25
				e.curframe=25
				e.value=2
				add(enemies,e)
			end
			if (mget(x,y)==46)then
				mset(x,y,27)
				e=new_enemy(x*8,y*8)
				e.initframe=25
				e.curframe=25
				e.value=5
				e.hp=2
				e.shoots=true
				add(enemies,e)
			end
			
			if (mget(x,y)==62)then
				mset(x,y,1)
				e=new_enemy(x*8,y*8)
				e.initframe=25
				e.curframe=25
				e.value=5
				e.hp=2
				e.shoots=true
				add(enemies,e)
			end
			
			if (mget(x,y)==128)then
				mset(x,y,96)
				e=new_enemy(x*8,y*8)
				e.initframe=25
				e.curframe=25
				e.value=5
				e.hp=2
				e.shoots=true
				add(enemies,e)
			end
			
			if (mget(x,y)==59)then
				mset(x,y,44)
				e=new_enemy(x*8,y*8)
				e.initframe=59
				e.curframe=59
				e.moves=false
				e.numframes=0
				e.takesdamage=false
				add(enemies,e)
			end
			
			if (mget(x,y)==43)then
				mset(x,y,44)
				e=new_enemy(x*8,y*8)
				e.initframe=43
				e.curframe=43
				e.moves=false
				e.numframes=0
				e.takesdamage=false
				add(enemies,e)
			end
			
			if (mget(x,y)==18 or mget(x,y)==23)then
				mset(x,y,44)
				e=new_npc(x*8,y*8,"",23)
				add(npc,e)
			end
		end
	end
	
end

function addnpcs()
	n1=new_npc(39*8,23*8,"",70)
	n1.text="the evil rabbit king"
	n1.text1="is threatening our land!"
	n1.text2="help us!"
	add(npc,n1)
	
	n1=new_npc(38*8,10*8,"",70)
	n1.text="the rocks that"
	n1.text1="are gold might mean"
	n1.text2="something important..."
	add(npc,n1)
	
	n1=new_npc(44*8,28*8,"",102)
	n1.text="hey there friend."
	n1.text1="ur a winner kiddo"
	n1.text2="don't u ever forget that."
	add(npc,n1)
	
	n1=new_npc(34*8,6*8,"",86)
	n1.text="to enter the rabbit king's"
	n1.text1="castle, you need 3 keys."
	n1.text2= "save reptile kind!"
	add(npc,n1)
	
	n1=new_npc(34*8,28*8,"",86)
	n1.text="visit the dragon shop"
	n1.text1="in the north to exchange"
	n1.text2= "coins for powerups."
	add(npc,n1)
	
	n1=new_npc(4*8,11*8,"",118)
	n1.text="lazarus! press Ž to spit"
	n1.text1="fire! the rabbit king's"
	n1.text2= "minions are everywhere."
	add(npc,n1)
	
	n1=new_npc(99*8,2*8,"",86)
	n1.text="this key will help you"
	n1.text1="later on your quest!"
	n1.text2= "cost: 50 coins"
	add(npc,n1)
	
	n1=new_npc(103*8,2*8,"",86)
	n1.text="this extra hp lets you"
	n1.text1="take more damage!"
	n1.text2= "cost: 25 coins"
	add(npc,n1)
	
	n1=new_npc(107*8,2*8,"",86)
	n1.text="this blue fire"
	n1.text1="deals more damage!"
	n1.text2= "cost: 35 coins"
	add(npc,n1)
	
	n1=new_npc(102*8,12*8,"",86)
	n1.text="welcome! to buy an item,"
	n1.text1="stand on the tile by it."
	n1.text2= "make sure to bring coins."
	add(npc,n1)
	
	n1=new_npc(36*8,22*8,"",70)
	n1.text="hey lazarus. if you stand"
	n1.text1="in this health spring,"
	n1.text2= "your hp fills up!"
	add(npc,n1)
	
	add(doors,new_door(42*8,39*8,71*8,46*8,10,false))
	
	add(doors,new_door(71*8,47*8,42*8,40*8,0,false))
	add(doors,new_door(72*8,47*8,42*8,40*8,0,false))
	
	add(doors,new_door(70*8,32*8,87*8,30*8,10,true))
	add(doors,new_door(74*8,32*8,87*8,30*8,10,true))
	add(doors,new_door(70*8,16*8,87*8,30*8,10,true))
	add(doors,new_door(72*8,16*8,87*8,30*8,10,true))
	add(doors,new_door(79*8,5*8,87*8,30*8,10,true))
	add(doors,new_door(79*8,7*8,87*8,30*8,10,true))
	
	add(doors,new_door(95*8,21*8,51*8,53*8,0,false))
	add(doors,new_door(95*8,22*8,51*8,53*8,0,false))
	
	add(doors,new_door(42*8,8*8,103*8,14*8,0,false))
	
	add(doors,new_door(103*8,15*8,42*8,9*8,0,false))
	add(doors,new_door(104*8,15*8,42*8,9*8,0,false))
	
	add(doors,new_door(55*8,55*8,71*8,62*8,10,false))
	add(doors,new_door(71*8,63*8,55*8,56*8,0,false))
	add(doors,new_door(72*8,63*8,55*8,56*8,0,false))
	
	add(doors,new_door(102*8,48*8,103*8,46*8,10,false))
	add(doors,new_door(103*8,48*8,103*8,46*8,10,false))
	add(doors,new_door(104*8,48*8,103*8,46*8,10,false))
	add(doors,new_door(105*8,48*8,103*8,46*8,10,false))
	
	add(keys,new_key(1*8,62*8,0))
	add(keys,new_key(87*8,7*8,2))
	
	add(shops,new_shop_item(99*8,1*8,0,50))
	add(shops,new_shop_item(107*8,1*8,1,35))
	add(shops,new_shop_item(103*8,1*8,2,25))
	add(bosses,new_boss(97*8,35*8))
	
	add(npc,new_npc(115*8,43*8,"",70))
	add(npc,new_npc(117*8,43*8,"",70))
	add(npc,new_npc(121*8,43*8,"",86))
	add(npc,new_npc(123*8,43*8,"",118))
	
	add(npc,new_npc(114*8,44*8,"",118))
	add(npc,new_npc(116*8,44*8,"",86))
	add(npc,new_npc(120*8,44*8,"",86))
	add(npc,new_npc(122*8,44*8,"",102))
end

function collision(x,y,x2,y2)
	if(x>=x2-4 and y>=y2-4 and y<y2+4 and x<x2+4)then
		return true
	end
	return false
end

function collision2(x,y,x2,y2)
	if(x>=x2-8 and y>=y2-8 and y<y2+8 and x<x2+8)then
		return true
	end
	return false
end
-->8
--update
function _update()
	if(showingstring)then
		if(btnp(4))then
			showingstring=false
		end
	elseif(gameover==false and titlescreen==false)then
		foreach(npc,function(o) o:update() end)
		player:update()
		foreach(bosses,function(o) o:update() end)
		foreach(enemies,function(o) 
			if(o.x>screenx and o.y>screeny and o.x<screenx+128 and o.y<screeny+128)then	
				o:update() 
			end
		end)
		foreach(bullets,function(o) o:update() end)
		foreach(coins,function(o) o:update() end)
		if(hp<=0)then
			gameover=true
			sfx(19)
			music(63)
		end
	end
end
-->8
--draw
function _draw()
	cls()
	camera(screenx,screeny)
	map(0,0,0,0,128,128,0)
	if(gameover==false)then
		player:draw()
	end
	foreach(npc,function(o) o:draw() end)
	foreach(enemies,function(o) o:draw() end)
	foreach(bullets,function(o) o:draw() end)
	foreach(coins,function(o) o:draw() end)
	foreach(shops,function(o) o:draw() end)
	foreach(keys,function(o) o:draw() end)
	foreach(bosses,function(o) o:draw() end)
	camera(0,0)
	rectfill(0,0,24,7,0)
	rectfill(90,0,128,7,0)
	print("coins:"..money,91,1,7)
	palt(0,true)
	
	if(key0==true)then
		rectfill(0,120,8,128,0)
		spr(63,0,120)
	end
	if(key1==true)then
		rectfill(8,120,16,128,0)
		pal(14,7)
		pal(8,10)
		pal(2,9)
		spr(63,8,120)
		pal()
	end
	if(key2==true)then
		rectfill(16,120,24,128,0)
		pal(14,7)
		pal(8,12)
		pal(2,1)
		spr(63,16,120)
		pal()
	end
	
	if(hpmax>3)then
		rectfill(0,0,32,7,0)
		if(hp>3.5)then
			spr(56,24,0)
		elseif(hp>3)then
			spr(57,24,0)
		else
			spr(58,24,0)
		end
	end
	
	if(hp>2.5)then
		spr(56,16,0)
	elseif(hp>2)then
		spr(57,16,0)
	else
		spr(58,16,0)
	end
	
	if(hp>1.5)then
		spr(56,8,0)
	elseif(hp>1)then
		spr(57,8,0)
	else
		spr(58,8,0)
	end
	
	if(hp>.5)then
		spr(56,0,0)
	elseif(hp>0)then
		spr(57,0,0)
	else
		spr(58,0,0)
	end
	
	if(showingstring)then
		rectfill(8,8,120,32,7)
		print(string0,10,10,0)
		print(string1,10,18,0)
		print(string2,10,26,0)
		print("Ž",111,27,5)
		print("Ž",110,26,11)
	end
	
	if(ending)then
		rectfill(8,8,120,64,3)
		print("lazarus has saved",10,10,11)
		print("the land!",10,16,11)
		print("the rabbit king has been",10,24,11)
		print("defeated, and peace has been",10,30,11)
		print("restored!",10,36,11)
		print("thanks for playing! :)",10,48,11)
	end
	
	if(titlescreen)then
		rectfill(8,8,120,120,0)
		print("lazarus the lizard!",10,10,7)
		print("arrows - move lazarus",10,20,7)
		print("Ž - spit fire, talk",10,26,7)
		print("press Ž to begin",32,96+8,7)
		
		print("the evil rabbit king has",10,48,7)
		print("taken over the land.",10,48+8,7)
		print("it's up to lazarus lizard",10,48+24,7)
		print("to defeat him.",10,48+32,7)
		spr(106,10,96,2,2)
		
		if(btn(4))titlescreen=false
	end
	
	if(gameover)then
		rectfill(8,8,120,64,2)
		print("lazarus has died. :(",10,10,8)
		print("press Ž to restart",10,30,8)
		if(btnp(4))then
			player.x=2*8
			player.y=11*8
			player.tx=-1
			player.ty=-1
			hp=1
			music(0)
			gameover=false
		end
	end
	palt(0,false)	
end
-->8
--player
bulletsleft=2
bullets = {}
coins = {}
ending = false

function new_player(ix,iy)
	local p={
		x=ix,
		y=iy,
		tx=-1,
		ty=-1,
		lastmovex=0,
		lastmovey=0,
		--animation variables
		initframe=3,
		numframes=3,
		framedelay=4,
		framedelaycount=0,
		currentframe=3,
		animating=true,
		flipped=false,
		hurtcolor=0,
		bulletspeedx=2,
		bulletspeedy=0,
		
		move=function(self)
			self.animating=true
			self.initframe=3
			self.framedelay=4
			self.numframes=3
			
			
			if(self.ty!=-1) then
				if(self.ty>self.y) then
					self.y+=1
					self.initframe=35
				end
				if(self.ty<self.y) then
					self.y-=1
					self.initframe=19
				end
			end
			
			if(self.tx!=-1) then
				if(self.tx>self.x) then
					self.x+=1
					self.flipped=false
					self.initframe=3
				end
				if(self.tx<self.x) then
					self.x-=1
					self.flipped=true
					self.initframe=3
				end
			end
			if(self.tx==self.x) then
				self.tx=-1
			end
			
			if(self.ty==self.y) then
				self.ty=-1
			end
		end,	
		input=function(self)
		
			self.animating=false
			self.framedelay=4
			self.numframes=0
			if(btn(0)) then
				n=self.x-8
				self.lastmovex=-8
				self.lastmovey=0
				self.bulletspeedx=-2
				self.bulletspeedy=0
				if(fget(mget(n/8,self.y/8))!=wall) then
					self.tx=n
				end
			elseif(btn(1)) then
				n=self.x+8
				self.lastmovex=8
				self.lastmovey=0
				self.bulletspeedx=2
				self.bulletspeedy=0
				if(fget(mget(n/8,self.y/8))!=wall) then
					self.tx=n
				end
			elseif(btn(2)) then
				n=self.y-8
				self.lastmovey=-8
				self.lastmovex=0
				self.bulletspeedx=0
				self.bulletspeedy=-2
				if(mget(self.x/8,n/8)!=105 and fget(mget(self.x/8,n/8))!=wall) then
					self.ty=n
				end
			elseif(btn(3)) then
				n=self.y+8
				self.lastmovey=8
				self.lastmovex=0
				self.bulletspeedx=0
				self.bulletspeedy=2
				if(fget(mget(self.x/8,n/8))!=wall) then
					self.ty=n
				end
			end
		end,
		
		collide_enemies=function(self,e,kb)
			if(collision(self.x,self.y,e.x,e.y))then
				if(kb and(self.lastmovex!=0 or self.lastmovey!=0))then
					self.x-=self.lastmovex
					self.y-=self.lastmovey
				elseif(kb==true)then
					self.x-=e.lastmovex
					self.y-=e.lastmovey
				end
				
				if(kb==false)then
					e.remove(e)
				end
				
				self.tx=flr(self.x/8)*8
				self.ty=flr(self.y/8)*8
				hp-=e.damage
				sfx(6)
				self.hurtcolor=5
			end
			
		end,
		ending=function(self)
			ending=true
			self.tx=self.x+64
			music(17)
		end,
		update=function(self)
			if(not ending)then
				if(self.x>111*8)then
					self.ending(self)
				end
			end
			if(self.x==8*36 and self.y==8*23)then
				if(hp<hpmax)then
					hp=hpmax
					sfx(20)
				end
			end
			foreach(doors,function(d)
				if(collision(self.x,self.y,d.x,d.y))then
					music(d.mus)
					self.x=d.newx
					self.y=d.newy
					self.tx=-1
					self.ty=-1
					if(d.spawnenemy)then
						d.enemies(d)
					end
				end
			end)
			foreach(keys,function(d)
				if(collision(self.x,self.y,d.x,d.y))then
					sfx(21)
					if(d.col==0)then
						key0=true
					end
					if(d.col==1)then
						key1=true
					end
					if(d.col==2)then
						key2=true
					end
					del(keys,d)
				end
			end)
			foreach(shops,function(d)
				if(collision(self.x,self.y,d.x,d.y))then
					d.buy(d)
				end
			end)
			foreach(enemies,function(b)self.collide_enemies(self,b,true)end)
			foreach(bullets,function(b)
				if(b.player==false)then
					self.collide_enemies(self,b,false)
				end
			end)
			if(not ending and self.tx==-1 and self.ty==-1) then
				self.input(self)
			else
				self.move(self)
			end
			screenx=flr(self.x/128)*128
			screeny=flr(self.y/128)*128
			
			if(screenx!=screenx_old
				or screeny!=screeny_0ld) then
					screeny_old=screeny
					screenx_old=screenx
					loadmap()
			end
			
			
			if(showingstring==false and btnp(4) and bulletsleft>0)then
				sfx(4)
				b=new_fireball(self.x,self.y,self.bulletspeedx,self.bulletspeedy)
				b.player=true
				add(bullets,b)
				bulletsleft-=1
				if(self.bulletspeedx!=0)then
					self.initframe=51
					self.framedelay=20
					self.framedelaycount=0
				end
				if(self.bulletspeedy>0)then
					self.initframe=52
					self.framedelay=20
					self.framedelaycount=0
				end
			end
		end,
		
		draw=function(self)
			local cf=self.currentframe
			local fd=self.framedelay
			local inf=self.initframe
			local nf=self.numframes
			if(self.hurtcolor>0)then
				self.hurtcolor-=1
				pal(11,10)
				pal(10,11)
			end
			palt(15,true)
			spr(cf,self.x,self.y,1,1,self.flipped,false)
			palt(15,false)
			pal()
			self.framedelaycount+=1
			if(self.framedelaycount>=fd)then
				self.framedelaycount=0
				self.currentframe+=1
				
				if(self.currentframe>inf+nf) then
					self.currentframe=inf
					if(self.initframe==51)then
					self.initframe=3
					end
					if(self.initframe==52)then
					self.initframe=35
					end
				end
				if(self.currentframe<inf) then
					self.currentframe=inf
				end
			end
		end
	}
	return p
end

function new_fireball(ix,iy,isx,isy)
	local b={
		x=ix,
		y=iy,
		sx=isx,
		sy=isy,
		sprite=12,
		initsprite=12,
		maxspr=15,
		imgdelay=1,
		player=true,
		
		update=function(self)
			self.x+=self.sx
			self.y+=self.sy
			if(fget(mget(flr(self.x/8),flr(self.y/8)))==wall)then
				self.remove(self)
			end
			if(self.x<screenx or self.x>screenx+128 or self.y<screeny or self.y>screeny+128)then
				self.remove(self)
			end
		end,
		
		remove=function(self)
			del(bullets,self)
			if(self.player)then
				bulletsleft+=1
			end
		end,
		
		draw=function(self)
			self.imgdelay-=1
			if(self.imgdelay==0)then
				self.imgdelay=2
				self.sprite+=1
				if(self.sprite>self.maxspr)then
					self.sprite=self.initsprite
				end
			end
			
			palt(0,true)
			if(self.player)then
				if(bluefire)then
					pal(8,1)
					pal(9,12)
					pal(10,7)
				end
			end
			spr(self.sprite,self.x,self.y)
			palt(0,false)
			pal()
		end
	}
	return b
end

function new_coin(ix,iy,iv)
	local c={
		x=ix,
		y=iy,
		value=iv,
		sprite=7,
		sprdelay=2,
		update=function(self)
			self.sprdelay-=1
			if(self.sprdelay<0)then
				self.sprite+=1
				self.sprdelay=2
			end
			if(self.sprite>8)then
				self.sprite=7
			end
			
			if(collision(self.x,self.y,player.x,player.y))then
				sfx(5)
				money+=self.value
				del(coins,self)
			end
		end,
		draw=function(self)
			palt(0,true)
			spr(self.sprite,self.x,self.y)
			palt(0,false)
		end
	}
	return c
end
-->8
--enemies
enemies = {}
function new_enemy(ix,iy)
	local e =
	{
		x=ix,
		y=iy,
		initframe=9,
		numframes=1,
		curframe=9,
		frametick=0,
		tx=-1,
		ty=-1,
		tk=0,
		lastmovex=8,
		lastmovey=0,
		damage=.5,
		value=1,
		moves=true,
		hp=1,
		takesdamage=true,
		damagecolors=0,
		shoots=false,
		select_location=function(self)
			r=flr(rnd(4))
			if(self.shoots)then
				r=flr(rnd(8))
			end
			if(r==0)then
				n=self.x+8
				if(fget(mget(n/8,self.y/8))!=wall
						and fget(mget(n/8,self.y/8))!=border ) then
					self.tx=n
					self.lastmovex=8
					self.lastmovey=0
				end
			elseif(r==1)then
				n=self.x-8
				if(fget(mget(n/8,self.y/8))!=wall
						and fget(mget(n/8,self.y/8))!=border ) then
					self.tx=n
					self.lastmovex=-8
					self.lastmovey=0
				end
			elseif(r==2)then
				n=self.y+8
				if(fget(mget(self.x/8,n/8))!=wall
				and fget(mget(self.x/8,n/8))!=border) then
					self.ty=n
					self.lastmovex=0
					self.lastmovey=8
				end
			elseif(r==3)then
				n=self.y-8
				if(fget(mget(self.x/8,n/8))!=wall
				and fget(mget(self.x/8,n/8))!=border) then
					self.ty=n
					self.lastmovex=0
					self.lastmovey=-8
				end
			else
				sfx(11)
				b=new_fireball(self.x,self.y,self.lastmovex/4,self.lastmovey/4)
				b.player=false
				b.sprite=11
				b.initsprite=11
				b.maxspr=11
				b.damage=self.damage
				add(bullets,b)
				self.tk=0
			end
			
			if(self.tx!=-1 or self.ty!=-1) then
				self.tk=0
			end
		end,
		move=function(self)
			self.numframes=1
			spd=1
			if(self.initframe==25)then
				spd=1
			end
			
			if(self.ty!=-1) then
				if(self.ty>self.y) then
					self.y+=spd
				end
				if(self.ty<self.y) then
					self.y-=spd
				end
			end
			
			if(self.tx!=-1) then
				if(self.tx>self.x) then
					self.x+=spd
				end
				if(self.tx<self.x) then
					self.x-=spd
				end
			end
			if(self.tx==self.x) then
				self.tx=-spd
			end
			
			if(self.ty==self.y) then
				self.ty=-spd
			end
		end,
		
		update=function(self)
			self.tk+=1
			spd=15
			if(self.initframe==25)then
				spd=5
			end
			if(self.moves==true and self.tk>=spd and 
			self.tx==-1 and 
			self.ty==-1) then
				self.select_location(self)
			elseif(self.moves==true and self.tx!=-1 or self.ty!=-1)then
				self.move(self)
			end
			
			foreach(bullets,function(o) 
				if(collision(self.x,self.y,o.x,o.y))then
					if(o.player)then
						if(self.takesdamage==true)then
							self.die(self)
							o.remove(o)
						end
					end
				end
			end)
		end,
		remove=function(self)
			self.die(self)
		end,
		die=function(self)
			sfx(7)
			self.hp-=bulletdamage
			if(self.hp<=0)then
				del(enemies,self)
				add(coins,new_coin(self.x,self.y,self.value))
			else
				self.damagecolors=6
			end
		end
		,
		draw=function(self)
			palt(0,true)
			
			
			if(self.damagecolors>0)then
				pal(9,7)
				pal(8,7)
				self.damagecolors-=1
			elseif(self.hp==2)then
				pal(9,12)
				pal(10,1)
				pal(8,4)
				pal(12,15)
				pal(4,11)
			end
			
			if(self.frametick>7)then
				self.frametick=0
				self.curframe+=1
			else
				self.frametick+=1
			end
			if(self.curframe>self.numframes+self.initframe)then
				self.curframe=self.initframe
			end
			spr(self.curframe,self.x,self.y)
			pal()
			palt(0,false)
		end
	}
	return e
end


-->8
--villages
npc={}
doors={}
keys={}
function new_key(ix,iy,c)
	local k={
	x=ix,
	y=iy,
	col=c,
	draw=function(self)
		palt(0,true)
		if(self.col==1)then
			pal(14,7)
			pal(8,10)
			pal(2,9)
		end
		if(self.col==2)then
			pal(14,7)
			pal(8,12)
			pal(2,1)
		end
		spr(63,self.x,self.y)
		palt(0,false)
		pal()
	end
	}
	return k
end
function new_door(ix,iy,nx,ny,m,spe)
	local d = {
	x=ix,
	y=iy,
	newx=nx,
	newy=ny,
	mus=m,
	spawnenemy=spe,
	enemies=function(self)
		e=new_enemy(83*8,29*8)
		e.initframe=25
		e.curframe=25
		e.value=5
		e.hp=2
		e.shoots=true
		add(enemies,e)
		e=new_enemy(87*8,26*8)
		e.initframe=25
		e.curframe=25
		e.value=5
		e.hp=2
		e.shoots=true
		add(enemies,e)
		e=new_enemy(90*8,26*8)
		e.initframe=25
		e.curframe=25
		e.value=5
		e.hp=2
		e.shoots=true
		add(enemies,e)
		e=new_enemy(92*8,19*8)
		e.initframe=25
		e.curframe=25
		e.value=5
		e.hp=2
		e.shoots=true
		add(enemies,e)
		e=new_enemy(82*8,20*8)
		e.initframe=25
		e.curframe=25
		e.value=5
		e.hp=2
		e.shoots=true
		add(enemies,e)
	end
	}
	return d
end
function new_npc(ix,iy,is,isprite)
	local n = {
		x=ix,
		y=iy,
		text=is,
		text1="",
		text2="",
		sprite=isprite,
		curframe=isprite,
		frametick=0,
		
		update=function(self)
			if(abs(player.x-self.x)<=8 and abs(player.y-self.y)<=8)then
				if(btnp(4) and self.text!="")then
					showingstring=true
					string0=self.text
					string1=self.text1
					string2=self.text2
					sfx(12)
				end
			end
		end,
		
		drawmessagebox=function(self)
		
		end,
		
		draw=function(self)
			palt(0,false)
			palt(15,true)
			self.frametick+=1
			if(self.frametick>8)then
				self.curframe+=1
				self.frametick=0
				if(self.sprite+1<self.curframe)then
					self.curframe=self.sprite
				end
			end
			spr(self.curframe,self.x,self.y)
			palt(15,false)
		end
	}
	return n
end
-->8
--shop items
shops={}
function new_shop_item(ix,iy,i,pr)
	local i={
	x=ix,
	y=iy,
	col=c,
	item=i,
	price=pr,
	buy=function(self)
		if(self.item==0 and money>=self.price)then
			sfx(21)
			key1=true
			del(shops,self)
			money-=self.price
		end
		if(self.item==1 and money>=self.price)then
			sfx(21)
			bluefire=true
			bulletdamage=2
			del(shops,self)
			money-=self.price
		end
		if(self.item==2 and money>=self.price)then
			sfx(21)
			hpmax=4
			hp+=1
			del(shops,self)
			money-=self.price
		end
	end,
	draw=function(self)
		print(self.price,self.x+8,self.y+8,7)
		if(self.item==0)then
			pal(14,7)
			pal(8,10)
			pal(2,9)
			spr(63,self.x+8,self.y)
			pal()
		end	
		if(self.item==1)then
			pal(8,1)
			pal(9,12)
			pal(10,7)
			spr(12,self.x+8,self.y)
			pal()
		end	
		if(self.item==2)then
			spr(56,self.x+8,self.y)
			pal()
		end	
	end
	}
	return i
end
-->8
--bosses
bosses = {}
function new_boss(ix,iy)
	local e =
	{
		x=ix,
		y=iy,
		sx=1.5,
		damage=1,
		initframe=76,
		curframe=76,
		frametick=4,
		hp=10,
		deathframe=0,
		damaged=false,
		takedamage=function(self)
			if(not self.damaged)then
				self.hp-=bulletdamage
				self.frametick=8
				self.damaged=true
				if(self.hp<=0)then
					music(99)
				end
			end
		end,
		update=function(self)
			foreach(bullets,function(o) 
				if(collision2(self.x,self.y,o.x,o.y))then
					if(o.player)then
						o.remove(o)
						sfx(7)
						self.takedamage(self)
					end
				end
			end)
			if(player.x>96*8 and player.y<47*8 and player.y>32*8)then
				if(not self.damaged and self.hp>0)then
					self.x+=self.sx
				end
				if(self.x>109*8)then
					self.sx=-1.5
				end
				if(self.hp>0 and rnd(40/(11-self.hp))<1)then
					sfx(11)
					b=new_fireball(self.x+8,self.y+8,0,2)
					b.player=false
					b.sprite=117
					b.initsprite=117
					b.maxspr=117
					b.damage=self.damage
					add(bullets,b)
				end
				if(self.x<96*8)then
					self.sx=1.5
				end
			else
				self.hp=10
			end
		end,
		draw=function(self)
			if(self.damaged)then
				pal(6,15)
				pal(15,11)
			end
			if(self.deathframe>=1)then
				pal(10,8)
			end
			if(self.deathframe>=2)then
				pal(15,8)
			end
			if(self.deathframe>=3)then
				pal(6,8)
			end
			if(self.deathframe>=4)then
				pal(1,8)
			end
			if(self.deathframe>=5)then
				pal(5,8)
			end
			if(self.deathframe>=7)then
				del(bosses,self)
				mset(110,41,96)
				mset(111,41,96)
				mset(110,42,96)
				mset(111,42,96)
				sfx(23)
			end
			spr(self.curframe,self.x,self.y,2,2)
			self.frametick-=1
			if(self.frametick==0)then
				if(self.hp<=0)then
					self.deathframe+=1
					self.frametick=8
					for b in all(bullets) do del(bullets,b) end
					sfx(22)
				else
					self.frametick=4
				end
				self.damaged=false
				if(self.curframe==76)then
					self.curframe=78
				elseif(self.curframe==78)then
					self.curframe=76
				end
			end
			pal()
			rectfill(101*8,33*8,106*8,33*8+4,9)
			rectfill(101*8,33*8,106*8-(self.hp*4),33*8+4,5)
			rectfill(101*8,34*8,105*8,35*8-2,7)
			print("boss hp",101.5*8-1,34*8+1,0)
		end
	}
	return e
end
__gfx__
000000003333333377777771fffbfbfffffbfbfffffbfbfffffbfbff000770000007700000000000000000000000000090009000008800090008880000888000
000000003333333377777711ffb0b0ffffb0b0ffffb0b0ffffb0b0ff007aaa000007a00000000000000000000000000000900090089980000089998009008800
0000000033b3333377666611f1bbbb5bf1bbbb5bf1bbbb5bf1bbbb5b07a44a90000aa000a0a0009900000000000ee00000000008899a80900889999800000880
00000000333b333377666611ffbbbbbbffbbbbbbffbbbbbbffbbbbbb07a49a90000aa00099900009a0a0009900e88200088800088999800088089a9890008998
000000003333333377666611f1baaafff1baaafff1baaafff1baaaff07a49a90000aa000898999999990000900e8820089a98088899800098000888000089998
0000000033333b3377666611fbbaaabfffbbbaf7fbbaaabfbbbaaabb07a49a90000aa0009999aa9089899999000220008999988008800000800000000908a998
000000003333b33371111111fb5595bfbb5595bbfb5595bfff5595ff00aaa900000a9000000900909999aa900000000008999800008800900900090000089980
000000003333333311111111ffb7fb7f7fffffffffb7fb7ffffb7fff000990000009900000090090009000090000000000888000000888000009000990008800
000000003377773311111111fffbfbfffffbfbfffffbfbfffffbfbff11111111111111110000000000000000a9aaaaaa3333333333333333aaaaaaaa33333333
00000000377777631c11c111ffbbbbbfffbbbbbfffbbbbbfffbbbbbf1c11c111111111114840000000000000aaaaaa9a3333333333333333aaaaaaaa33333333
000000003776666311cc1111ffbb1bbfffbb1bbfffbb1bbfffbb1bbf11cc1111111111118888000048400000aaaaaaaaa3a3a3a333333333aaaaaaaaa3a3a333
000000003776666511111111ffbbbbbfffbbbbbfffbbbbbfffbbbbbf1111111111c11c118008800088880000aa9aaaaaaaaaaaaa33331113aaaa111aaaa9aa33
000000007766665511111111fbbb1bbbfbbb1bbbfbbb1bbbfbbb1bbb11111111111cc111008c880080088080aaaaaa9aaaa9aaaa33331333aaaa1aaa9aaaa333
00000000776665551111c11cfbbbbbbbfbbbbbbffbbbbbbbffbbbbbb1111c11c11111111008c8808008c88809aaaaaaaaaaaaaaa33333133aaaaa1aaaaaaaa33
000000007766655511111cc1ff55555fff55555fff55555fff55555f11111cc1c11c1111000cc888000cc800aaaaaaa99aaaaaaa33333313aaaaaa1aaaaaa333
000000003355555311111111ffbfffbfffffffbfffbfffbfffbfffff111111111cc111110008080000880880aaaa9aaaaaaa9aaa33331113aaaa111aaaaaaa33
000000003773377333333333fffbfbfffffbfbfffffbfbfffffbfbff33333333111111113333d3d111d33333aaaaaaaaaaaaaaaaa9aaaa33a1111aaaaaa9aa33
00000000777777bb33333333ffb0b0bfffb0b0bfffb0b0bfffb0b0bf333333331d1d1d1d33333d111d3d3333aaaaa9aaaaaaa9aaaaaaa333a1aaaaaaaaaaa333
000000007bbbbbbb333b3333ff5bbb5fff5bbb5fff5bbb5fff5bbb5f33333333d3d3d3d33333d3d111d33333aaaaaaaaaa9aaaaaaaaaaa33a11aaaaaaaaaaa33
000000003bbbbbb333b33333ffbbbbbfffbbbbbfffbbbbbfffbbbbbf333333333d3d3d3d33333d111d3d3333aaaaaaa9aaaaaaaaaaa9a333a1aa111aaaaa9333
000000003bbbbb5333333333fbaaaaabfbaaaaabfbaaaaabfbaaaaab3d3d3d3d333333333333d3d111d33333a9aaaaaaaaaaaaa99aaaaa33a1aa1aaaaaaaaa33
00000000bbbbb5553333b333fbaaaaabff7aaaabfbaaaaabfbaaaa7fd3d3d3d33333333333333d111d3d3333aa7777aaaaaa9aaaaaaaa333aaaaa1aaa3a3a333
00000000bbb5555533333b33ff55955fffb5955fff55955fff5595bf1d1d1d1d333333333333d3d111d33333a77bb77aaaaaaaaaaaaaaa33aaaaaa1a33333333
000000004554455433333333ff7fff7fffffffffff7fff7fffffffff111111113333333333333d111d3d3333a73bbb7a9aaaaaaaaaaaa333aaaa111a33333333
000000003444444311111111fffbfbfffffbfbff1111111111d3333333333d11000000000000000000000000abbbb3b3aa6666aaff4444ff3111133300000000
000000003344443311d1d1d1ffb0b0ffffb0b0bf1d1d1d111d3d33333333d3d10ee0ee000ee0110001101100ab3bbbbaa666665af499991f313333330ee00000
00000000334444331d3d3d3df1bbbb5bff5bbb5fd3d3d3d111d3333333333d11e88e88e0e88e1110111111103bbbbb3aa665555a499aa45031133333e00e0000
000000003344443311d3d3d3ffbbbbbbffb888bf3d3d3d111d3d33333333d3d1888888808888111011111110abbbbbbaa6655551441a910031331113e0088888
00000000335445331d3d3333bbbab88ffbb888bb3333d3d111d3d3d33d3d3d11028882000288110001111100a3b3bb3366555511494444503133133380080808
000000003355553311d33333bfaabbbfffabbbaf33333d111d3d3d3dd3d3d3d1002820000028100000111000933bb33966555111494444503333313380020002
00000000355555531d3d3333f55595ffff55955f3333d3d111d1d1d11d1d1d110002000000020000000100009333333966555111495555503333331302200000
000000003333333311d33333fb7ffb7ff7bfffb733333d111111111111111111000000000000000000000000a999999aaa11111a000000003333111300000000
333333333333333333333333333333333333333333333333ffffffffffffffff33777733333333333337c3333333333300000600060000000000060006000000
3333333333333333b33333333333333333333333b3333333ffffffffffffffff377777a333333333337ccc333333333300006f606f60000000006f606f600000
333333333333333b33333333333333333333333b33333333ffffffffffffffff377aaaa3333333e337ccccc33e3333330000af606fa000000000af606fa00000
b33332222222222222233333b33331111111111111133333ffffffffffffffff377aaaa933333e8833555533e88333330000afa8afa000000000afa8afa00000
3b33288888888888888233333b331cccccccccccccc133331b1fcccfffffcccf77aaaa993333e8888361163e888833330000aaaaaaa000000000aaaaaaa00000
3332888888888888888823333331cccccccccccccccc1333bbbccccc1b1ccccc77aaa99933333515331cc1335153333300006166616000000000616661600000
333222222222222222222333333111111111111111111333fffcccccbbbccccc77aaa999333331c1331111331c13333300066116116600000006611611660000
333349999999999999943333333349999999999999943333fffbfffbfffbfffb3399999333333716336666336163333300066666666600000006666666660000
333349111199991111943333333333333333333333333333ffffffffff77f4ff7777777533333766666116666663333300066161616600000006616161660000
3333491cc199991cc1943333333333377777777773333333ff77f4fff88ff4ff7cc6666533337766661cc1666665333300006616166066000660661616600000
3333491cc199991cc19433b3333337777777777666633333f88ff4ff817844f47cc6666533337611161111611165333300066666666666000666666666660000
333349111199991111943b33333377766000000666663333817844f488888ff47c6aa6653333761c16000061c1653333006666fff6666000006666fff6666000
33b34999999999999994333333377666600000066666533388888ff4ffa88848766aa6653333761c10000001c165333300666fffff60000000006fffff666000
3b3349999999999999943333337766666000000666665533ffa88848ffaa8888766a688533337611100000011165333300006fff666660000066666fff600000
333349999999999999943333337766666000000666655533ffaaa888ff8aa8ff7666688533337666600000066655333300666660656560000065656066666000
333344444444444444443333335555555000000555555533f78f78fff78f78ff5555585533337666500000055555333300656560000000000000000065656000
666656651999999166667667666666666666666666666666ffffffffffffffff28282828c1c1c1c10000bb0bb000000000000000000000000000000000000000
6566666610000001676666666666866666cccc6666aaaa66ffffffffffffffff828282821c1c1c1c000b77b77b00000000000000000000000000000000000000
666667661000000166666766668886666c6666c66a6666a6ffffffffffffffff28282828c1c1c1c1001b71771b00000000000000000000000000000000000000
666666661000000166666666666686666c6666c66666aa66fffffffdfffffffd828282821c1c1c1c011b71771b00000000000000000000000000000000000000
666766669000000966676666666686666666cc66666666a6fffffffa0d0ffffa28282828c1c1c1c1001bbbbbbbb3b30000000000000000000000000000000000
6666666690000009666666666666866666cc66666a6666a60d0dadddddddaddd828282821c1c1c1c000bbbbbbbbbbb0000000000000000000000000000000000
656666769000000967666676668888866cccccc666aaaa66ddddddadffddddad28282828c1c1c1c1001bbbbbbbbbbb0000000000000000000000000000000000
666666664000000466666666666666666666666666666666ffdfffdffffdfdff828282821c1c1c1c011bbbaaaa00000000000000000000000000000000000000
111111111111111177777777ccc11ccc0000000000aaaa00ccccfffffffccccf6dddddd66666666600bbbbaaaab0000000000000000000000000000000000000
1cccccc117ccccc17bbb0bb3cc1771cc000000000a9999a0fffccffffccccfff6d555516666776660bbbbbaaaabb000000000000000000000000000000000000
17cccc711ccc7c717b0000b3c17ccc1c00000000a988889affffccffcccfffff66d5516666777766bbbbbbaaaabbb00000000000000000000000000000000000
1cccccc11cccccc170bb0bb317ccccc100000000a98ff89affffcccffccccfff66d5516666777766bbb5555955bbb00000000000000000000000000000000000
1ccc7cc11cccc7c17b0000b317ccccc100000000a98ff89af88fcccff88cccff66d55166677777167b755559557b700000000000000000000000000000000000
17ccccc117ccccc17bb0bb0371cccc1700000000a988889af8fcccfff8ffcccf66d5516667777116000bbb0bbb00000000000000000000000000000000000000
1cccc7c11ccc7cc17b0000b3cc1cc17c000000000a9999a00c0ccfff0c0cccff6d55551667771116000bbb0bbb00000000000000000000000000000000000000
111111111111111133303333ccc117cc0000000000aaaa00ccccffffcccccfff6d11111666111166000b7b7b7b70000000000000000000000000000000000000
2020202020202020202020202020202020202020202020222220202020202020202121212121212121212121212121212121a220202020222220202020202020
20202020202026202620262020202020ffffffffffffffffffffffffffffffff2020202020202020202020202020202020202020202020202020202020202020
20101010101010101010101010101020201010101010101010101210101010202021212121212121212121212121212121231010101010101010101010101020
20060606062036204620562006060620ffffffffffffffffffffffffffffffff2086868686868686868686868686862020060606060606060606060606060620
20101010101010101010101010101020201010101011101010101310101010202082828282828282828282532121212121a21010101010101010101010101020
20060606060606060606060606060620ffffffffffffffffffffffffffffffff2086868686868686868686868686862020060606060606060606060606060620
20c1c1c1c1c1c1c1c1c1c1c1c1c1c12020c1c1c1c1c1c1c1c1c1c1c1c1c1c12020c1c1c1c1f11010101010105321212121a21010101010101010101010101020
20060606060606060606060606060620ffffffffffffffffffffffffffffffff2086868686868686868686868686862020060606060606060606060606060620
20b1b1b1b1b1b1b1b2b1b1b1b1b1b12020b1b1b1b1b1b1b1b1b1b1b1b1b1b12020b1b1b1b1b1f110101010101053212121a21010101010101010101010101020
20060606060606060606060606060620ffffffffffffffffffffffffffffffff2086868686868686868686868686862020060606060606060606060606060620
20b1b1e2b1b1b1b1b3b1b1b1b1b1b12020b1b1b1b1b1b1b1b1b1b1b1b1b1b12020b1b1b1b1b1b1f1111010101110532121a21010101010101010101210121020
20060606060606060606060606060620ffffffffffffffffffffffffffffffff2020969696969696969696969696202020060606060606060606060606060620
20b1b1b1b1b1b1b1b1b1b1b1b1b1b12020b1b1b2b1b1b1b1b1b1b1c3c3b1b2c2c2b1b1b1b1b1b1d2121010101210108282101010101110101010101310131020
20060606060606060606060606060620ffffffffffffffffffffffffffffffff2020060606060606060606060606202020060606060606060606060606060620
20b1b1b2b1a1b1b1b1b1b1b2b1e2b1c2c2b1b1b3b1b1b1b1b1b1b1b1c3b1b3c2c2b1b1b1b1b1b1d2133545551310102222101010101010101010101010101020
20060606060606060606060606060620ffffffffffffffffffffffffffffffff2020060606060606060606060606202020060606060606060606060606060620
20b1b1b3b1b1b1b1b1b1b1b3b1b1b1c2c2b1b1b1b1b1a1b1b1b1b1b1b1b1b12020b1b1b1b1b1b1d211d1d1d11110102222101011101010101010101010101020
20060606060606060606060606060620ffffffffffffffffffffffffffffffff2020868686868686868686868686202020060606060606060606060606060620
20b1b1b1b1b1b1b2b1b1b1b1b1b1b12020c3b1b1b1b1b1b1b1b1b1b1b1b1b12020b1b1b1b1b1b1d2101010101010102020101010101010101010101010101120
20060606060606060606060606060620ffffffffffffffffffffffffffffffff2020868686868686868686868686202006060606060606060606060606060620
20b2b1b1b1b1b1b3b1b1b1b1b1b2b12020c3c3a1b1b1b1b1b1b1b1b1b1b1b12020b1b1b1b1b1b1f2101010101010102020101010101010101010101010101020
20060606060606060606060606060620ffffffffffffffffffffffffffffffff2020868686868686868686868686202006060606060606060606060606060620
20b3b1b1b1b1b1b1b1b1b1b1b1b3b12020b1b1b1b1b1b1b1b1b1b1b1b1b1b12020b1b1b1b1b1f210101010101010102020101210121010101010101110101020
20060606060606060606060606060620ffffffffffffffffffffffffffffffff2020868686868686868686868686202020060606060606060606060606060620
20b1b1b1e2b1b1b1b1b1b1a1b1b1b12020b1b1b1b1b1b1b1b1a0b1b1b1a1b12020b1b1b1b1f21010101010101010102020101310131010101010101010101020
20060606060606060606060606060620ffffffffffffffffffffffffffffffff2020060606068686868606060606202020060606060606060606060606060620
20b1b1b1b1b1b1b1b1b1b1b1b1b1b12020b1b1b1b1b1a0b1b1b1b1b1b1b1b12020b1b1b1f2101010101010101010102020101010101010101010101010101020
20060606060606060606060606060620ffffffffffffffffffffffffffffffff2020060606068686868606060606202020060606060606060606060606060620
20b1b1b1b1b1b1b1b1b1b1b1b1b1b12020b1b1b1b1b1b1b1b1b1b1b1b1b1b12020b1b1d210101010101010101010102020101010101010101010101010101020
20060606060606060606060606060620ffffffffffffffffffffffffffffffff2020060606068686868606060606202020060606060606060606060606060620
20202020202020c2c22020202020202020202020202020c2c2202020202020202020202020202022222020202020202020202020202020222220202020202020
20202020202020262620202020202020ffffffffffffffffffffffffffffffff2020202020202020202020202020202020202020202020202020202020202020
20202020202020c2c22020202020202020202020202020c2c2202020202020202020202020202022222020202020202020202020202020222220202020202020
20202020202020202020202020202020202020202020202020202020202020202020202020208686868620202020202000000000000000000000000000000000
20b1b1b1b1b1b1b1b1b1b1b1b1b1b12020b1b1b1b1b1b2b1b1b1b1b1b1b1b1202010101010101010101010101010102020101010101010101010101010101020
20060606060606060606060606060620200606060606060606060606060806202018061806188686868606080608062000000000000000000000000000000000
20b1b1b1b1b2b1b1b1b1b1b1b1b1b12020b1b1b1b1b1b3b1b1b1b1b1b1b1b1202010101010101010101010101010102020101010101010101010101010101020
20060606060606060606060606060620200606060606060606060606060606202006060606068686868606060606062000000000000000000000000000000000
20b1b1b1b1b3b1b1b1b1b1b2b1b1b12020b1b1c3b1b2b1b2b1b1b1b1b1b1b1202010101010101010101010101010102020101010101010101010101010101020
20060606060606060606060606060620200606180606060606060606060606202006060606068686868606060606062000000000000000000000000000000000
20b1b1b1b1b1b1b1b1b1b1b3b1b1b12020b1b1b1b1b3b1b3b1b1b1b1c3b1b1202010101010101010101010101010102020101010101010101010101010101020
20068706870606060606068706870620200606060606060606060606060606202006060606068686868606060606062000000000000000000000000000000000
20b1c3c3c3b1e1b1b1b1b1b1b1b1b12020b1b1b1b1b1b2b1b1b1b1b1b1e2b12020f110e310101010101010101010102020101010101010101010101010101020
20060606080606060606061806060620200606060606060606060606060606202006060606068686868618060606062000000000000000000000000000000000
20b1b1b1b1b1b1b1b1c3c3c3c3b1b12020b1e1b1b1b1b3b1b1b1b1b1b1b1b12020d2101010101010101010101010102020101010101094a4b410101010101020
20060606060606060606060606060620200606068718060606870606068787202006060606088686868606060606062000000000000000000000000000000000
20b2b1b1b1b1b1b1b1b1b1b1b2b1b1c2c2b1b1b1b1b1b1b1b1b1b1b1b1b1b1c2c2d2101010101010101010101010102020101210121095a5b510101210121020
20060606060606060606060606060626260606060606060606060606060606262606060606068686868618060606062000000000000000000000000000000000
20b3b1b1c3b1b1b1b1b1b1b1b3b1b1c2c2b1b1b1b1b1b1b1b1b1b1e1b1b1b1c2c2d210101010101010101010d110102020101310131010851010101310131020
20060606060687061887060606060626260606060606060606060606060606262606060606088686868606060606062000000000000000000000000000000000
20b2b1c3c3c3b1b1b1e1b1b1b1b1b12020b1b1e1b1b1b1b1b1b1b1b1b1b1b12020f2101010101010101010101010102020101010101010101010101010101020
20060606061887060687060606060620200606068706060606870606068787202006060606068686868618060606062000000000000000000000000000000000
20b3b1b1b1b1b1b1b1e1b1b1b1b1b12020b1b1b1b1b1b1b1e2b1b1b1b1b1b120201010d110101010101010101010102020101010101010101010101010101020
20060606060606060606060606061820200606060606060608060606060606202006060606088686868606060606062000000000000000000000000000000000
20e2a1b1b1b1b1b1b1b1b1b1c3b1b12020b1b1b1b1b1b1b1b1b1b1b1b1b1b1202010101010101010911010e3101010202010d110d11010101010d11010d11020
20060606060606060606060606060620200606060606060606060606060606202006060606060606060606060606062000000000000000000000000000000000
20a1a1e2b1b1b1b1b2b1b1c3c3c3b12020b1b1b1c3b1b1b1b1b2b1c3b1b1b12020101010101010101010101010101020201010d110101010101010d1d1101020
200606060606060606060606060606202006060606060606060606060606062020060606060606060606060606060620000000000000000000000000ffb0b0ff
20e2e2a1a1b2b1b1b3b1b1b1c3b1b12020b1b1b1b1b1b1b1b1b3b1b1b1b1b1202010101010101010101010101010102020101010101010101010101010101020
200687068706060606060687068706202006060806060606060606060608062020060606060606060606060606060620000000000000000000000000ffbbbbbb
20b1e2a1e2b3b1b1b1b1b1b1b1b1b12020b1b1b1b1b1b1b1b1b1b1b1b1b1b1202010101010101010101010101010102020101010101010101010101010101020
200606060606060606060606060606202006060606060606060606060606062020060606060606060606060606060620000000000000000000000000ffbaaaff
20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
202020202020200606202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000ffffffff
__gff__
0000010000000000000000000000000000010000000000010100000000000000000102000000000101010100020000000001010000010101000000000100000001010101010100000101010100000000010101010a01000001010a01000000000000000000000000008000000000000000000000010000000101000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020202020202171717020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000
0201010101010101010101010101010202010137171717362727272727272727272737121212121212121212122a01020201010101010101010101010101010202606060606060606060606060606002026060606060606060606060606060020202027274020272740202727402020200000000000000000000000000000000
2727272727272727272727272727272727273717171717121212121212121212121212121212121212121212122a01020201010101010101010101010101010202606060606060606060606060600202026060606060606060606060606060020202027374020273740202737402020200000000000000000000000000000000
1717171717171717171717171717171717171717171717121212121212121212121212121212121212121212122a01020201010101010101010101010101010202606060606060606060606060606362626060606060606060606060606060020273737373737373737373737373730200000000000000000000000000000000
1717171717171717171717171717171717171717171717121212121212121212121212121212121212121212320101020201010101010101010101011901010202606060606060606060606060600202020260606060606060606060606060020273737373737373737373737373730200000000000000000000000000000000
2828282828282828282828282828282828282828282828282828282828282828282828282828282828282828010101020201010101010101010101010101010202606060606060606060606060606462620260606060606060606060606060020273737373737373737373737373730200000000000000000000000000000000
0201010101010101010101010101010202014801480148010101010101010102020101010101010101010101010101020201011901010101010101010101010202606060606060606060606060600202020260606060606060606060606060020273737373737373737373737373730200000000000000000000000000000000
0201010101010101010101010101010202014801480101010101010901010102020143444444450140414141420101020201010101010101190101010101010202606060606060606060606060606562620260606060606060606060606060020273737373737373737373737373730200000000000000000000000000000000
0201010101010101010101010101010202010101480101010101010101010102020150515151520150516151520101020201010101010101010101010101010202606060606060606060606060600202020260606060606060606060606060020273737373737373737373737373730200000000000000000000000000000000
0240414221010101010111110101010202010101010101010101010101010102020160606060606060606060606001222201010101190101010101190101010202606060606060606060606060606002026060606060606060606060606060020273737373737373737373737373730200000000000000000000000000000000
0250515231010101010101010101012222010101010109010121010101010102020160606060606060606060606001222201010101010101010101010101010202606060606060606060606060606002026060606060606060606060606060020273737373737373737373737373730200000000000000000000000000000000
0201030101010101010101010101012222010101010101010131010101010102020101010101016060010101010101020201010111110101010111110101010202606060606060606060606060606002026060606060606060606060606060020273737373737373737373737373730200000000000000000000000000000000
0201010101010101010111110101010202210101010101010101010101010102021101010101016060010101010111020201010101010101010101010101010202606060606060606060606060606002026060606060606060606060606060020273737373737373737373737373730200000000000000000000000000000000
0201010101010101010101010101010202310101010101010101010101010102020101110101216060210101110101020201010101010101010101010101010202606060606060606060606060606002026060606060606060606060606060020273737373737373737373737373730200000000000000000000000000000000
0201010101010101010101010101010202010101010101010101010101010102020101010101316060310101010101020201010101010101010101010101010202606060600202020202600260606002026060606060606060606060606060020273737373737373737373737373730200000000000000000000000000000000
0202020202020222220202020202020202020202020202222202020202020202020202020202026060020202020202020202020202020222220202020202020202020202020262026202620202020202020202020202020202020202020202020202020202020273730202020202020200000000000000000000000000000000
0202020202020222220202020202020202020202020202222202020202020202020202020202026060020202020202020202020202020222220202020202020202020202020262026202620202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000
0201010101010101010101010101010202010101010101010101010101010102020101010101016060010101010101020201010101010101010101010101010202606060600263026402650260606002026060606060606060606060606060020000000000000000000000000000000000000000000000000000000000000000
020101010101010109010101010101020201010101010101010101010101010202014041422101606043444543444502020101011d010101010101010101010202606060606060606060606060606002026060606060606060606060606060020000000000000000000000000000000000000000000000000000000000000000
020101110101010101010101110101020201010101010101010101010101010202015051523101606050515250515202020101110101010101010101011d010202606060606060606060606060606002026060606060606060606060606060020000000000000000000000000000000000000000000000000000000000000000
0221210101010101010101010121210202010101010101010101010101010102020160606060606060606060606060020201010101010101010101010101010202606060606060606060606060606002026060606060606060606060606060020000000000000000000000000000000000000000000000000000000000000000
02313101090101011101010101313102020101010101010101010101010101020201606060606060606060606060600202011d0101010101011d01010101010202606060606060606060606060606002026060606060606060606060606060620000000000000000000000000000000000000000000000000000000000000000
0227010101010101010101190101010202010101010101010121010101010102020101010101016060010101210101020201010101010101010101010101010202606060606060606060606060606002026060606060606060606060606060620000000000000000000000000000000000000000000000000000000000000000
02172a0101210101010121010101012222010101010101210131012101010122220101017001016060010101310101020201010101010101010101010101010202606060606060606060606060606002026060606060606060606060606060020000000000000000000000000000000000000000000000000000000000000000
0217110101310101010131010101012222010101010101310101013101010122220101010101016060010101010127272727010101010101010101010101010202606060606060606060606060606002026060606060606060606060606060020000000000000000000000000000000000000000000000000000000000000000
02172a01010101010101010111010102020101012101010101010101110109020201404141420160604041420129121212122a0121010101010101012101010202606060606060606060606060606002026060606060606060606060606060020000000000000000000000000000000000000000000000000000000000000000
02172a01010101010101010101010102021101013101012727272727270101020201505151520160605051520129121212122a0131010101010101013101010202606060606060606060606060606002026060606060606060606060606060020000000000000000000000000000000000000000000000000000000000000000
02173601010101010101010101010102020101012727371212121212122a01020201606060606060606060606029121212122a0101010101010101010101010202606060606060606060606060606002026060606060606060606060606060020000000000000000000000000000000000000000000000000000000000000000
0217172a010101010101010101090102020901291212121212121212122a01020201606060606060606060606029121212122a0101010101010101010111010202606060606060606060606060606002026060606060606060606060606060020000000000000000000000000000000000000000000000000000000000000000
0217172a010901010101010101010102020101012828282828282828280101020227272727272727272727272737121212122a0101010101010101010101010202606060606060606060606060606002026060606060606060606060606060020000000000000000000000000000000000000000000000000000000000000000
0217172a010101010101010101010102020101010101010101010101010101020212121212121212121212121212121212122a0101010101010101010101010202606060600202026002020260606002026060606060606060606060606060020000000000000000000000000000000000000000000000000000000000000000
02020202020202020202020202020202020202020202022222020202020202020212121212121212121212121212121212122a0202020222220202020202020202020202020262026202620202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000
__sfx__
0110000024750247002b750297502875028700247502470028750267502875000700297500070000700247002975028750297502b750297500070024750007002675024750267500070028750007000070000700
011000000c655000000c6350c6000e600000000c635106350c635000000c6350000000000000000c635000000c6350000000000000000c6350c6350c6350c6350c6350000000000000000c635000000000000000
011000000c035000000c035000000c03500000110350000011035000001003500000100350000000000000000c035000000c03500000150350000015035000000c035000000c035000000c035000000000000000
011000002475026750287500000026750000000000023750247500000029750000002875000000000000000028750000002675028750297502875024750237502475000000247500000024750000000000000000
0001000007650096500f650326503f6503f65038650326502e6502b650286502565022650216501f6501e6501e6501d6501d6501c6501c6501c6501c6501b6501a650216501b65016650186501e6502165023650
0108000028350303501b300003001c3001c3001d3001e30020300213002130028300273002b300003002e300323002b3002f30031300003000030000300003000030000300003000030000300003000030000300
0106000018373183001a3001c30007000070000700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00000c47100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000297502b7502975000000287500000000000247502975000000297500000029750000002b7002b700297502875029750287502b7502470024750267002675026700267502470024750000000000000000
01100000181520000000000000000000000000180531800030754000000000000000000000000018550184001c05000000000000000000000000003e2511a0000e25200000000000000000000000000000000000
011000001312011100111200c100101200e1000c120000000e120000000e120000000c12000000000000c1200e12000000131200000010120000000c120000001512000000151200000013120000000000000000
011000003014300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002425028250242502b25024250242500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000051500000002150000000415000000021500000004150000000515000000000000000009150021000b150000000b150000000e150000000c150000000915000000000000000000000000000000000000
011000002127000000000000000023270000001c27000000212700000000000000001f27000000212700000024270000002427000000242700000023270000002127000000000000000000000000000000000000
011000002127000000212700000021270000001d270000001d270000001d2700000018270000000000000000212701f270212702327021270000001f270000002127000000000000000000000000000000000000
01100000217502175021750217501d7501d7501a7501a7501c7501c7501c7501c75018750187501875018750217502175021750217501d7501d7501d7501d7502375023750237502375023750237502375023750
011000002465300000246530000024653000002465300000246530000000000000002465300000246530000024653000002465300000246530000024653000002465300000397500000039750000000000000000
011000001523015230152301523015230152301523015230152301523015230152301523015230152301523011230112301123011230112301123011230112301723017230172301723015230152301523015230
011000002d1702d1702d1702d17029170291702917029170241700000024170000002817000000281700000026170261702617026170261702617026170261702d1702d1702d1702d1702d1702d1702d1702d170
0109000024352283522b3522f3522b3520000024353000002b3512f30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900002445026450284502645024450264502b4502b450244502440024400244000040000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000065700007006570000700657000070065700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002415526155281552b15500000281550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000011375000000000000000103750000000000000000c3750000000000000000e3750000000000000001137500000103750000011375000000c375000000c375000000b375000000c375000000000000000
0110000024270000002627000000282702627024270000000000000000282700000028270000000000023270212700000000000000001f270000001f27000000232700000021270000001f270000002127000000
011000001f340000001f34000000233401f3402134000000303003030018340303001834000000000002b3402d340000000000000000183400000018340000001c340000001a340000001c340000000000000000
011000001867500000186750000018675000000000000000186750000018675000001867500000186750000018675000001867500000000000000018675000001867500000000000000000000000001867500000
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
01 02 01 43 44
01 01 02 00 44
00 01 02 03 44
00 01 02 00 44
00 01 02 08 44
00 01 02 09 44
00 01 02 43 0a
00 01 02 00 0a
00 01 02 0a 03
02 41 02 03 44
01 0d 42 10 11
00 0d 0e 10 11
00 0d 0f 10 11
00 0d 12 00 11
00 0d 12 10 11
00 0d 0e 12 11
02 0d 0f 10 11
03 18 19 1a 1b
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
