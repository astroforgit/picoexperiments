pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- godmode is enough
-- by owljey
-- 2019-2020-

--lrudox
--‹‘”ƒŽ—



max_actors = 128
gtick=0
gtick0=0
gtick1=0
actorb={}
actorm={}
actorf={}
sparcle={}
player=nil --obj
cam=nil --obj

stx=0 sty=0
dpal={0,1,1, 2,1,13,6,4,4,9,3, 13,1,13,14}

mes="--"

stat_ini=1
stat_del=2
stat_dmg=3 -- charactor only
sccnt=0
sccmod={[0]=8,8,4,4,4,2,2,2}

--- util ----------------------
function ret_value( flag , v1 , v2 )
	if  flag == true  then
	  return v1
	else
	  return v2
	end
end

function intrnd(num)
	return flr(rnd(num))
end

function xspr(pt,px,py,wd,ht,a) ---screen spr
		spr(pt,(px-stx)*8,(py-sty)*8,wd,ht,a.direct)
end
function xsspr(pt,px,py,wd,ht,xwd,xht,a) ---screen spr
		sspr_scale(pt,(px-stx)*8,(py-sty)*8,wd,ht,xwd,xht,a.direct)
end

--- sparkle -------------------

	--s.size=1 --- 1:8x8  2:16x16
	--s.motion=0 --- +1 patern timing ,if =5 , motion_t,frame+=(+s.size)

xsparkle = {
		t=0 , max_t=8+intrnd(4),	
		dx=0,dy=0,ddx=0,ddy=0,
		dir=false, size=1, motion=0,col=0
		,drawfunc=function(a)
				if a.col > 0 then
					for i=1,15 do
						pal(i,a.col)
					end
				end
				spr(a.frame, (a.x-stx)*8-4, (a.y-sty)*8-4,a.size,a.size,a.dir)
				if a.col >0 then
					pal()
				end
			end
}

function make_sparkle(x,y,frame)
	local s = {
		x=x , y=y , frame=frame
	}
	setmetatable(s,{__index=xsparkle})
	add(sparkle,s)
	return s
end

function move_sparkle( sp )
	if sp.t > sp.max_t then
		del(sparkle,sp)
	end

	sp.x= sp.x + sp.dx
	sp.y= sp.y + sp.dy
	sp.dy= sp.dy+ sp.ddy
	sp.dx= sp.dx+ sp.ddx
	sp.t= sp.t + 1
end

function draw_sparkle(s)
	s:drawfunc()
end

---- sparkles custom -----
---- explode
function make_punch_explode( pl )
    for i=1,10 do
     local s=make_sparkle(player.x+pl.x+0.5, player.y+pl.y, 57+intrnd(3))
     s.dx=s.dx+ rnd(0.4)-0.2
     s.dy=s.dy+ rnd(0.4)-0.2
     s.max_t= 20 
     s.ddy= 0.01
    end
end



---- hokori in jump
function make_sparkles_jumpdust(a)
     local s=make_sparkle( a.x+1, a.y+2, 58)
     s.dx= a.direct and 0.1 or -0.1
     s.dy= 0
     s.max_t= 10
     s.ddy= 0.02
     s.col= 6 --light gray 5 --dark gray
end

---- hokori in grand
function make_sparkles_granddust(a)
    for i=1,2 do
     local s=make_sparkle( a.x+1, a.y+2.0, 26)
     s.dx=  i==1 and 0.2 or -0.2
     s.dir=  i==1 and true or false
     s.dy= 0
     s.max_t= 5
     s.ddy= -0.01
     s.ddx= s.dx/8
     --s.col = 5 --dark gray
	end
end

---- all bakuhatsu
function make_bomb(x0,y0)
	local a = make_actor(21,0,0,false,2) --bomb
	a.movefunc={
		function(a)
			if a.ct%8==0 then
				local x=x0+3+rnd(3)-4
				local y=y0+3+rnd(3)-4
				make_vanish(x,y,1)
			end	
			if a.ct>80 then
				a.stat=stat_del	
			end
		end,
		move_del
	}
	return a
end

---- circle shine
function make_shine(x,y)
	local a = make_actor(21,x,y,false) --shine
	a.x=a.x+2
	a.y=a.y+2
	a.ddx=1.5
	a.dx=6
	a.movefunc={
		function(a)
			a.dx=a.dx+a.ddx
			a.ddx=a.ddx-0.1
			if a.ct>10 then
				a.stat=stat_del	
			end
		end,
		move_del
	}
	a.drawfunc=function(a)

		local xx=a.x*8
		local yy=a.y*8
		if a.ct < 5 then
			local cc=ret_value(a.ct<3,7,10)
			local xx0=xx
			local yy0=yy
			for i=0,5 do
				line(xx0,yy0,xx0-24,yy-50,cc)
				line(xx0+6,yy0,xx+16,yy-50,cc)
				line(xx0,yy0+4,xx-24,yy+25,cc)
				line(xx0+6,yy0+4,xx0+16,yy+25,cc)
				xx0=xx0+1
				yy0=yy0+1
			end
		end

		fillp(0b0011001111001100.1)
	    circ(xx,yy,a.dx+4,10)
		fillp()
	    circ(xx,yy,a.dx+3,7)
	    circ(xx,yy,a.dx,0)
		end

	return a

end

--- actor (base-util)-------------------
function move_empty(a)
	-- empt func
end
function move_del(a)
	a:statdel()
	del_actor(a)
end

function move_dmg(a)
	--a.rad=(a.rad+6.25)%100
	--a.blct=20
	a.stat=stat_del	
end


function draw_caller(a)
	if a.blct>0 then
		a.blct=a.blct-1
		if a.blct%a.blrt==0 then --blink
			return
		end
	end

	if a.stat>0 then
		a:drawfunc()
	end
end

function del_sub_actor(a,ar)
		for i=1,count(ar) do
			local x=ar[i]
			if x.parent==a then
				x.stat=stat_del
			end
		end	
end

function del_actor(a)
	if a.haschild then -- a's children is finish stat.
		del_sub_actor(a,actorb)
		del_sub_actor(a,actorm)
		del_sub_actor(a,actorf)	
	end
	a.kind= -1
	a.stat= -1
	if a.zorder==0 then
		del(actorb,a)
	elseif a.zorder==1 then
		del(actorm,a)
	else
		del(actorf,a)
	end
end

xactor = {
	dx=0 ,dy=0 , stat=0 , zorder=1,
	ct=0,blct=0,blrt=0,
	parent=nil , haschild=false , attacker=nil , hide=false,
	movefunc=nil
	,drawfunc=move_empty	
	,statdel=move_empty
}

planes={actorb,actorm,actorf}
--- actor (base)-------------------
function make_actor(kind,x,y,direct,z)
	local a = {
		kind = kind , x=x,y=y , diret=direct ,
		zorder=z,stat=stat_ini
	}
	setmetatable(a, {__index=xactor})
	a.movefunc={}

	if count(actorb)+count(actorm)+count(actorf) < max_actors then
		add(planes[a.zorder+1],a) -- actorb actor actorf
 	end
	return a
end

function expand_charactor(a)
	a.drawfunc=function(a)
		 	xspr(a.pt[a.pn],a.x,a.y,2,2,a) --draw
		end
	a.statdel=function(a)
			--make_vanish( a.x , a.y ,0 )	
		end

	a.hitandattack=function(a)
		if  hitcheck_player(a,true)==true then
			make_tilt()
			a.stat=stat_dmg
			make_vanish(a.x,a.y)
			rate=0
		end

		if  hitcheck_myattack(a)==true then
			a.stat=stat_dmg
			make_vanish(a.x,a.y,1)	

			 make_sceffect(a.x,a.y,a.sc)
			 rate=ret_value( rate<4 ,rate+1 , rate)

			 if rate>0 then
				 make_scmultieffect(a.x+1.0,a.y,rate+1)
			 end
			update_score(a.sc*(rate+1))
		end
	end		


end


function move_actor(a)
	if a~=nil and a.stat>=0 then
		if a.movefunc[a.stat]==nil then --dbg
			printh("stat="..a.stat, "log") --dbg
			printh("kind="..a.kind, "log") --dbg
		end
		a.movefunc[a.stat](a)
		a.ct=a.ct+1
	end
end

--- actor - tilt -------------
function make_tilt(x,y)
	local a = make_actor(21,0,0,false) --tilt
	a.movefunc={
		function(a)
			if a.ct<15 then
				cdx = (rnd(8)-4 )/4
				cdy = (rnd(8)-4 )/4
			else -- destroy
				cdx = 0
				cdy = 0
				a.stat=stat_del	
			end	
		end,
		move_del
	}
	return a
end

--- effect - player eye down-------------
function make_eyedown(x,y,delay)
	local a=make_actor(2,x,y,false,2) --eyedown
	if delay==nil then
	 delay=0
	end
	a.movefunc={move_empty,move_del}
	a.drawfunc=function(a)
		if  a.ct>=delay  then
		xspr(170, a.x+1.2 , a.y+1.8 ,2,1,a) -- eye masks
		end
	end
	return a
end




--- actor - flash -------------
function make_flash(col)
	local a=make_actor(20,0,0,false,2) --flash
	-- last order is for flash
	a.movefunc={move_empty,move_del}
	a.drawfunc=function(a)
		--printh( "fal "..a.duration  , "log" , false )
		if  a.ct<4  then
			pal( a.dx , 7 , 1)	
		elseif  a.ct<8  then
			pal( a.dx , 10 , 1)
		elseif  a.ct<10  then
			pal( a.dx , 8 , 1)	
		else -- destroy
			pal()
			a.stat=stat_del
		--printh( "del "..a.duration  , "log" , false )
			return
		end
	end
	a.dx=col
	return a
end

--- actor - effectspark(arm) -------------
function make_effectspark(x,y)
	local a=make_actor(44,x,y,false,0) --spark
	a.dx=5
	a.movefunc={
		function(a)
			a.dx=a.dx+1
			if a.dx>10 then
				a.stat=stat_del
			end
		end,
		move_del
	}
	
	a.drawfunc=function(a)
		local bx=a.x
		local by=a.y
		local r=a.dx

		fillp(0b0101010110101010.1)
		circfill(bx-3,by,r  ,9)
		fillp()
		circfill(bx-2,by,r-1,10)
		circfill(bx  ,by,r-3,7)

	end

	return a	
end

--- actor - effectpillar -------------
function make_effectpillar(x,y)
	local a=make_actor(19,x,y,false,2) --pillar
	a.x=18
	a.y=7
	a.movefunc={
		function(a)
			if player.stat~=5 then
				a.x=a.x-0.14
			end
			if a.x<-2 then
				a.stat=stat_del
			end
		end,
		move_del
	}
	
	a.drawfunc=function(a)
		for i=0,6 do
			xspr(27, a.x , a.y+i ,2,1,a)
		end
	end

	return a	
end


--- actor - title -------------
function make_title(x,y)
	local a=make_actor(22,x,y,false,0) --title
	field_caller=title_field
	a.rad=0
	a.dec=false
	a.dy=8
	
	local b=make_player(1,8)
	b.stat=6 b.leg0.stat=5 b.leg1.stat=5
		
	a.movefunc={
		function(a)
			local at_max=30
			local at=ret_value( a.ct>at_max , at_max , a.ct)
			if  at==at_max and a.stat==0 then
				make_flash(8)
				make_tilt()
				a.stat=stat_del
			end
			a.y=70-easing_out(at,0,60,at_max)

			if  btnp(4,0)  then -- title scene
					a.stat=3
					sfx(12,3) -- gmie start jingle
					b.stat=stat_del
					a.dy=16
					a.ct=0
			end
		end,
		move_del,
		function(a) --[3] end sub
			if a.ct==1 then
				a.stat=stat_del
				fade_out()
				round_start()
			end
		end
	}
	a.drawfunc=function(a)
		local bx=camx+0
		local by=camy+20
		local boff=64*by+bx/2
		local blen=64*60

		if a.stat==1 then
			if a.dec==false then
				px9_decomp(bx,by,0x1D00,pget,pset) --title
				memcpy(0x4300,0x6000+boff,blen) -- screen to user data
				a.dec=true
			else
				memcpy(0x6000+boff,0x4300,blen) -- user data to screen
			end
		end
		textout("push Ž key",bx+42,by+wavepos(1)+74,4) --"push @ key"
		textout("2020",bx+35,by+100,8)
		spr(208,bx+65,by+98,5,1,false) --"@owljey"

		if a.stat~=stat_del then
			poke(0x5f5f,0x10)
			for i=0,15 do
				poke(0x5f60+i,({[0]=0,0,1,1,2,1,13,6,4,4,9,3,13,1,13,14})[i])
			end
			for i=0,15 do
				local flag=ret_value( i>=a.dy , 255,0 )
				poke(0x5f70+i,flag)	
			end
	
		else
			poke(0x5f5f,0x0)
		end


	end

	music(-1,0,7)
	sfx(6,3)
	return a	
end


--- actor - over(gameover) -------------
function make_over(x,y)
	local a = make_actor(23,x,y,false,2) --over
	--music(5,0,7)

	a.movefunc={
		function(a)	-- [1] flow up gameover 
			local at_max=30
			local at=ret_value( a.ct>at_max , at_max , a.ct)
			if  at==at_max then
				--make_flash(8)
				a.stat=3
				a.ct=0
			end
			a.y=70-easing_out(at,0,60,at_max) -- 70->10
	--printh("a.y="..a.y, "log") --dbg -- 70-10

		end,
		move_del, -- [2] del
		function(a)	-- [3]wait	
			if  a.ct>70  then
				a.stat=4
				a.ct=0
			end
		end,
		function(a)	-- [4]title after wait
			if a.ct>20 and btnp(4,0) then --gameover
				a.stat=stat_del
				--cam.x=0	cam.y=0 --gameover
				deal_gameover()
			end
		end
	}
	a.drawfunc=function(a)
		local bx = camx+50
		local by = camy+32

		if a.stat~=stat_del then
			textout("time up",bx-10+a.y,by,9,4)
			textout("time up",bx+10-a.y,by,9,4)
		end	
	end

	return a
end

--- actor - camera -------------
function make_camera(x,y)
	local a = make_actor(25,x,y,false)--camera 25 or 13
	-- a.x = 0*8 ... 32*8
	camx = x
	camy = y
	a.movefunc={
		function(a)
			if  player~=nil  then
				local diff=(player.x-stx)*8 - a.x
diff=0
				a.dx=0
				if  diff > 52  then
					a.dx = min( 4.0 , (diff-52)/4 )
					a.x = min( a.x+a.dx , 16*8 )
				elseif  diff < 40  then
					a.dx = max( -4.0 , (diff-40)/4 )
					a.x = max( a.x+a.dx , 0 )
				end
			end
			camx=a.x
			camy=0 --a.y
		end,
		move_del
	}

	return a
end

function make_timer(x,y)
	local a = make_actor(55,x,y,false) --timer
	a.dy=0.8
	a.movefunc={
		function(a) --[1]
			a.y=a.y-a.dy
			if a.dy<-0.8 then
				a.dy=0
				a.stat=3
			else
				a.dy=a.dy-0.1
			end
		end,
		move_del, --[2] del
		function(a) --[3] main
			a.y=player.y
			if counts==0 then
				a.ct=0
				a.dy=0.4
				a.stat=4
			end
		end,
		function(a) --[4]
			a.y=a.y+a.dy
			a.dy=a.dy-0.2
			if a.ct==10 then
				a.stat=stat_del
			end
		end
	}
	a.drawfunc=draw_time


	return a
end

scsp={}
scsp[100]=32
scsp[200]=33
scsp[300]=34
--- actor - sceffect(add score effect) -------------
function make_sceffect(x,y,addsc)
	local a = make_actor(8,x,y,false,2) --sceffect
	a.movefunc={
		function(a) --[1]
			a.x=a.x+a.dx
			a.y=a.y+a.dy
			a.dy=ret_value( a.dy < -0.08 , 0 , a.dy-0.02 )
			if a.ct>15 then
				a.stat=3
				a.dy=0.4
				a.ct=0
			end
		end,
		move_del, --[2] del
		function(a) --[3]
			a.x=a.x+a.dx
			a.y=a.y+a.dy
			a.dy = a.dy* -0.9
			if a.ct>30 then
				a.stat=stat_del
			end
		end
	}

	a.drawfunc=function(a)
			xspr(a.pn,a.x,a.y,a.wd,1,a) --sceffect
	end

	a.x=a.x+0.4
	a.y=a.y-0.4
	a.pn=scsp[addsc]-- 100:32 2000:33 300:140
	a.wd=1
	a.dy= -0.02
	
	return a
end

--- actor - combffect(comb effect) -------------
function make_combeffect(x,y)
	local a = make_sceffect(x,y,100) --sceffect "Combo!"
	a.pn=224
	a.wd=3	
	return a
end
--- actor - scmultieffect(comb x2x3...effect) -------------
function make_scmultieffect(x,y,xrate) -- xrate is 2,3,4...
	local a = make_sceffect(x,y,100) --sceffect
	a.pn=33+xrate
	return a
end



--- actor - vanish -------------
function make_vanish(x,y,tp)
	local a = make_actor(9,x,y,false,2) --vanish
	a.pn=ret_value( tp==1 , 2, 1 )
    a.pt={ 78, 136 ,138	,168 }
	a.pc=0

	a.movefunc={
		function(a) --[1]
			a.x = a.x + a.dx
			a.y = a.y + a.dy

			if a.ct>10 then
				a.stat=stat_del	
			end 

		if a.pn>=2 then
			a.pn= 2+flr(a.pc/3)
			a.pc=(a.pc+1) % 9 --0 1 2
		end

		end,
		move_del --[2] del
	}
	a.drawfunc=function(a)
		if a.ct<3 then
			pal( 6 , 6 , 0)
			pal( 10 , 7 , 0)
			pal( 7 , 0 , 0)
		elseif a.ct<6 then
			pal( 10 , 6 , 0)
		elseif a.ct<10 then
			pal( 6 , 0 , 0)
			pal( 10 , 0 , 0)
		end

		xspr(a.pt[a.pn],a.x,a.y,2,2,a) --draw
		pal()
	end
	--a.statdel=move_empty -- not necessary vanish
	return a
end

enemy_tbl={1,5, 3,3, 2,4, 2,4, 1,2, 3,4, 1,5, 2,5, 4,20, 0,0}
enemy_cnt=1
--- actor - roundmanage(round_management) -------------
function make_roundmanage(x,y) -- round start reborn
	local a = make_actor(11,x,y,false) --roundmanage
	a.ct=1
	a.interval=100
	--printh("move_main..init", "log") --dbg
	local zCheck=false
	local zInsta={}

	a.movefunc={
		function(a) --[1]move_main
			if a.ct%250==0 then
				make_effectpillar(0,0)
			end
		
			if a.ct%a.interval==0 then --enemy interval
			--mes="enemy"
				local tp=enemy_tbl[enemy_cnt] enemy_cnt=enemy_cnt+1
				local tn=enemy_tbl[enemy_cnt] enemy_cnt=enemy_cnt+1
				if tp==0 then
					enemy_cnt=1
				else
					local yy=intrnd(6)+6
					zInsta={}
					for i=1,tn do
						add( zInsta ,enemy_typ[tp](32-i*2,yy,i) )
					end
					zCheck=true
				end
			end

			-- zenmetsu check
			if zCheck then
				local hit=0
				for itm in all(zInsta) do
					if itm.stat<0 then hit=hit+1 end
				end

				if hit==#zInsta then
					a.stat=3
					zCheck=false
					zInsta={}
				end
			end
			--

			if counts==0 then --timeup
				a.stat=5
			end
		end,
		move_del, --[2] del
		function(a) --[3] next enemy troop
			mes="rapid!"
			a.ct=a.interval-1
			a.stat=1
		end,
		function(a) --[4]
		end,
		function(a) --[5]gameover
			--make_over()
			a.stat=stat_del
		end
	}
		
	return a
end



---- stage character -----------
--------------------------------

function sub_jump(a)
	if  a.jump > 0  then --- jumping?
		a.jump= a.jump-1
		a.dy= min(a.dy+0.1 , 0.4)
		a.y=ret_value( a.dy<0 , a.y+a.dy, a.y)
	end
end
function sub_ground(a)
	if a.jump==0 then ---not jump
		-- falling?
		local ongrnd=falling_loop(a)
		if  ongrnd  then
			a.dy=0	
		else--- falling start?
			a.dx = 0 a.ddx = 0
			a.dy = min( a.dy+0.02 , 0.3 ) -- fall
		end
	
		-- let's jump?
		if ongrnd then
			if a:jpcond() then
				--a.ct=0
				a.jump = 14
				a.dy=-0.8
			end
		end
	end
end


--- actor - enemy -------------
--- tento blue
function make_enemy4(x,y,count) --count:troop index
	local a = make_actor(5,x,y,false) --enemy
	expand_charactor(a)
	a.ct=0-count*5
	a.pt=100
	a.pn=1 a.pc=0
	a.sc=100
	a.dx=-0.2
	a.dy=0
	a.dd=0.01
	a.dir=0
	a.x=34+flr(count/10)*2
	a.y=count % 10

	a.movefunc={
		function(a)--[1]normal

				if  a.ct%20==0 then
					a.dir=1-a.dir
				end

				if  a.x<-1  or a.y<-1 then
					a.stat=stat_del
				else
					a.dd=ret_value( a.dd<0.2 ,a.dd+0.02 , 0.4 )
					if a.dir==0 then
						a.x=a.x-a.dd
					else
						a.x=a.x-a.dd*cos(gtick*2)
						a.y=a.y-a.dd*sin(gtick*2)
					end
				end
				a:hitandattack()
		end,
		move_del, --[2]
		move_dmg, --[3]
	}

	a.drawfunc=function(a)
		a.pc=(a.pc+0.1) % 2.0
		a.pn= flr(a.pc) -- index is 1-
		pal(8,1)
		pal(14,2)
		spr(a.pt+a.pn*2,(a.x-stx)*8,(a.y-sty)*8,2,2,false) --draw
		pal()	
	end

	return a	
end

---- dragonfly
function make_enemy3(x,y,count) --count:troop index
	local a = make_actor(5,x,y,false) --enemy
	expand_charactor(a)
	a.ct=0-count*5
	a.pt=104
	a.pn=1 a.pc=0
	a.sc=100
	a.dx=-0.2
	a.dy=0
	a.dd=0.01
	a.dir=0

	a.movefunc={
		function(a)--[1]normal

				if  a.ct==40  or a.ct==70 then
					a.dir=1-a.dir
				end

				if  a.x<-1  or a.y<-1 then
					a.stat=stat_del
				else
					a.dd=ret_value( a.dd<0.2 ,a.dd+0.02 , 0.4 )
					if a.dir==0 then
						a.x=a.x-a.dd
					else
						a.x=a.x-a.dd*cos(gtick*2)
						a.y=a.y-a.dd*sin(gtick*2)
					end
				end
				a:hitandattack()
		end,
		move_del, --[2]
		move_dmg, --[3]
	}

	a.drawfunc=function(a)
		a.pc=(a.pc+0.1) % 2.0
		a.pn= flr(a.pc) -- index is 1-

			--rotate_spr(a.pt,16,64,16,16,a.rad/100)
			--spr(130,(a.x-stx)*8,(a.y-sty)*8,2,2,false)

		spr(a.pt+a.pn*2,(a.x-stx)*8,(a.y-sty)*8,2,2,false) --draw
		pal()	
	end

	return a	
end

--- tento
function make_enemy2(x,y,count) --count:troop index
	local a = make_actor(4,x,y,false) --enemy
	expand_charactor(a)
	a.ct=0-count*5
	a.pt=100
	a.pn=1 a.pc=0
	a.sc=100
	a.dx=-0.2
	a.dy=0
	a.dd=0.01
	a.dir=0

	a.movefunc={
		function(a)--[1]normal

				if  a.ct==60  or a.ct==70 then
					a.dir=1-a.dir
				end

				if  a.x<-1  or a.y<-1 then
					a.stat=stat_del
				else
					a.dd=ret_value( a.dd<0.2 ,a.dd+0.02 , 0.4 )
					if a.dir==0 then
						a.x=a.x-a.dd
					else
						a.y=a.y-a.dd
					end
				end
				a:hitandattack()
		end,
		move_del, --[2]
		move_dmg, --[3]
	}

	a.drawfunc=function(a)
		a.pc=(a.pc+0.1) % 2.0
		a.pn= flr(a.pc) -- index is 1-

		spr(a.pt+a.pn*2,(a.x-stx)*8,(a.y-sty)*8,2,2,false) --draw
		pal()	
	end

	return a	
end

-- beatle
function make_enemy1(x,y,count) --count:troop index
	local a = make_actor(3,x,y,false) --enemy
	expand_charactor(a)
	a.rad=0
	a.rad=(a.rad+3.14*count)%100
	a.ct=intrnd(80)
	a.pt=96
	a.pn=1 a.pc=0
	a.ddx=0
	--a.haschild=true --kizband
	a.sc=100

	a.movefunc={
		function(a)--[1]normal
				--sub_jump(a)
				local dir=1

				a.ddx=ret_value( a.ddx<0.2 ,a.ddx + 0.02 , 0.1 )
				a.dx=ret_value( a.direct , a.ddx , -a.ddx)
				a.dy=sin(a.rad/100)-a.dy
				a.rad=(a.rad+3.14)%100
				if count % 2==1 then
					dir=0-dir
				end
				if  a.x+a.dx<-2  then
					a.stat=stat_del
				else
					a.x=a.x+a.dx
					a.y=a.y+a.dy*dir
				end
				--sub_ground(a)
				a:hitandattack()
		end,
		move_del, --[2]
		move_dmg, --[3]
	}

	a.drawfunc=function(a)
		a.pc=(a.pc+0.1) % 2.0
		a.pn= flr(a.pc) -- index is 1-

		spr(a.pt+a.pn*2,(a.x-stx)*8,(a.y-sty)*8,2,2,false) --draw
		pal()	
	end


	return a	
end

enemy_typ={make_enemy1,make_enemy2,make_enemy3,make_enemy4} -- after defined enemy's


--	a.jpcond = function(a)
--		return false
--	end

--- actor - player punch-------------
function make_punch(x,y,isRight,par)
	local z=ret_value(isRight,2,0)
	local a = make_actor(2,x,y,false,z) --punch
	a.parent=par
	expand_charactor(a)
	-- x0,y0 ... rootpos , x1,y1...punchpos(offset)
	a.x1=a.x
	a.y1=2 -- punch
	a.y0=a.y1-0.2   --root x,y
	a.rad=-4
	a.zoom=16
	a.brct=0
	a.olct=0
	a.isRight=isRight
	if isRight then
		a.x1=-1	  a.x0=0
		a.pt=132
		a.btno=4 a.abtno=5
	else
		a.x1=4	  a.x0=3.4
		a.pt=134
		a.btno=5 a.abtno=4
	end

	a.movefunc={
		function(a) --[1]
			if player.stat==5 then
				a.stat=6
				a.ct=0
			end
			if a.ct>50 and btnp(a.btno,p) and btnp(a.abtno,p)==false and player.stat~=5 then
				a.dx= -0.2 -- next punch 's hiki
				a.dy=0
				a.rad=0
				a.olct=0
				a.stat=3 --btn
				if a.isRight==false then
					a.stat=5
					a.rad=-4
				end
				a.ct=0
			end
		end,
		move_del, --[2] del
		function(a) -- [3]rocket punch
			a.x1=a.x1+a.dx
			a.dx=ret_value(a.dx>1.0,1.0,a.dx+0.4)

			a.dy=ret_value( btn(2) , -0.04 , a.dy )
			a.dy=ret_value( btn(3) , 0.04 , a.dy )
			a.y1=a.y1+a.dy

			if a.ct==1 then
				local x0=player.x+a.x0
				local y0=player.y+a.y0+0.5
				make_effectspark((x0-stx)*8,(y0-sty)*8)
    sfx(32,3)
			end

			if a.ct==35 then
				make_punch_explode(a)
			end

			if a.x1>15 then
				 a.stat=4 --retrun
				 a.dx=abs(a.x1-a.x0)/20.0
				 a.dy=abs(a.y1-a.y0)/20.0
	--printh("return:"..a.dx.." "..a.dy, "log") --dbg

			end
		end,
		function(a)-- [4]rocket return
			local dx=a.dx
			local dy=a.dy
			dx=dx*sgn(a.x0-a.x1)
			dy=dy*sgn(a.y0-a.y1)

			a.x1=a.x1+dx
			a.y1=a.y1+dy
			a.dx=ret_value(a.dx>1.2,1.2,a.dx+0.1)
			a.dy=ret_value(a.dy>1.2,1.2,a.dy+0.1)


--			dy=abs(a.y1-a.y0)/abs(a.x1-a.x0)
--			dy=ret_value(dy>0.8 , 0.8 , dy )
--			dy=dy*sgn(a.y0-a.y1)


			if a.x1<a.x0 then
				a.x1=a.x0 a.rad=-4 a.y1=a.y0
				a.zoom=16
				a.ct=40
				a.stat=stat_ini
			end
		end,
		function(a)-- [5] big punch (left only)
			a.dx= -0.2
			if a.ct==4 then
				a.zoom=18
			end
			if a.ct==8 then
				a.zoom=20
			end
			if a.ct==12 then
				a.zoom=24
				a.dy=-0.6
				a.rad=a.rad+10
				a.ct=0
				a.stat=3 --btn
			end
		end,
		function(a)-- [6] finish animation
			if a.ct==1 then
				a.rad=80
				a.dy=0.2
			end
			a.y1=a.y1+a.dy
			a.dy=ret_value(a.dy>0.8 , 0.8 , a.dy+0.1 )
			a.y1=min( 12.5-player.y , a.y1 )
		end

	}

	a.drawfunc=function(a)	
		local x0=player.x+a.x0
		local y0=player.y+a.y0+0.5

		--local dx=(a.x-a.x0)/5
		local len=flr((a.x1-a.x0)/0.7)
		local dy=ret_value( a.isRight , (a.y+0.7-y0)/len , (a.y+2.0-y0)/len )

		-- arm cable
		for i=0,len do
			circfill((x0-stx)*8,(y0-sty)*8,2,4)
			x0=x0+0.7
			y0=y0+dy
		end

		-- hand
		a.x=player.x+a.x1
		a.y=player.y+a.y1+sin(gtick)/4

		sub_draw_bright_check(a)
		sub_draw_ola_check(a)

		rotate_spr(a.pt,16,64,16,16,a.rad/100)
		if a.isRight then
			xspr(130,a.x,a.y,2,2,a)
		else
			xsspr(130,a.x,a.y,16,16,a.zoom,a.zoom,a)
		end
		pal()
	end

	return a	
end

--- actor - player leg-------------
function make_leg(x,y,isRight,par)
	local a = make_actor(2,x,y,false) --leg
	expand_charactor(a)
	a.parent=par

	a.y1=4 -- leg
	a.y0=a.y1-0.3   --root x,y
	a.rad=-3
	a.stat=5 --wait
	a.brct=0
	a.olct=0
	a.zoom=16

	if isRight then
		a.x1=0.2  a.x0=1.0
		a.ct1=20 a.pt=164
	else
		a.x1=1.7 a.x0=2.6 
		a.ct1=0 a.pt=166
	end

	a.movefunc={
		function(a) --[1] walking
			a.ct1=(a.ct1+1) % 40

			if player.jump > 0 then
				a.stat=3
				a.olct=0
			end

			-- timeup hokou chousei
			if player.ongrnd==true and player.stat==5 then
				local cnt=ret_value( isRight , 20 , 0 )
				if a.ct1==cnt then
					a.stat=5
				end
			end

		end,
		move_del, --[2]
		function(a) --[3] jumping
		a.ct1=0
			if isRight then
				a.x1=0.3  a.x0=1.2
			else
				a.x1=2.2 a.x0=3.3
			end

			if player.jump==0 then
				a.stat=1
				if isRight then
					a.x1=0.2  a.x0=1.0 a.ct1=20
				else
					a.x1=1.7 a.x0=2.6  a.ct1=0
				end				
			end
		end,
 		function(a)			--[4]
		 end
		,
		function(a) --[5] wait
			if player.stat~=1 and player.stat~=5 and player.stat~=6 then
				a.stat=1
			end
		end
	}
		
	a.drawfunc=function(a)
--		local off=0.0- 0.5*flr(a.ct1/10)
		local off=0.0- 0.5*cos(a.ct1/40)
		local offy=sin(a.ct1/40)
		offy=ret_value(offy>0.0,0.0,offy)

		if player.stat==5 then
		 off=0
		end

		a.x=player.x+a.x1+off
		a.y=player.y+a.y1+offy
		local x0=player.x+a.x0+off
		local y0=player.y+a.y0

		local dx=-0.2	--(x-x0)/5
		local dy=0.2	--dy=(y-y0)/3

		sub_draw_bright_check(a)
		sub_draw_ola_check(a)


		rotate_spr(a.pt,16,64,16,16,a.rad/100)
		xspr(130,a.x,a.y,2,2,a) --leg

		for i=1,3 do
			--circ((x0-stx)*8,(y0-sty)*8,1,5)
			xspr(160,(x0+dx-stx),(y0-sty),1,1,a) --joint
			--x0=x0+dx
			y0=y0+dy
			--dx=dx+0.2
		end
		pal()
	end

	return a	
end


--- actor - player -------------
--- .x .y ... armor pos
--- .mx .my ... kylo pos
function make_player(x,y)
	local a = make_actor(1,x,y,false,1) --player
	expand_charactor(a)
	a.x0=x 	a.y0=y --- init points
	a.mx=0 a.my=12 a.dy=-0.6
	a.pt={ 64, 66 , 68, 70, 72,74} -- 2-3:walk 4-5:rolling 6:fadein
	a.pn=1 a.pc=0
	a.punch0=make_punch(x,y,false,a)
	a.punch1=make_punch(x,y,true,a)

	a.leg0=make_leg(x,y,false,a)
	a.leg1=make_leg(x,y,true,a)

	a.eyed=make_eyedown(a.x,a.y,0)
	a.haschild=true

	a.jump=0
	a.ongrnd=false
	a.knockback=0
	--a.y=sty-1.0 -- syutugen demo pos
	a.drawhits=draw_hits
	player=a
	a.brct=0

	a.movefunc={
		sub_move_player_toujyou, --[1]toujyou
		move_del,
		function(a)--[3]damaged
			a.ct=0
			a.blct=5 a.blrt=4
			sfx(10,3)
			sub_move_player_pattern(a)
			a.stat=4
		end,		
		function(a) --[4]normal move
			sub_move_player_normal(a)
			sub_move_player_pattern(a)
			if a.knockback>0 and a.blct==0 then -- knockback end
				a.dx=0 a.dy=0
				a.knockback=0
			end	
			if counts==0 and a.jump==0 and a.ongrnd==true and a.knockback==0 then
				a.stat=5
				a.ct1=0
				gtick0=gtick
			end
		end,
		sub_move_player_taijyou, --[5]gameover taijyou
		function(a) --[6]title pose
			if a.eyed~=nil then
				a.eyed.stat=stat_del
			end
			sub_move_player_pattern(a)
			gtick=gtick0
		end
	}


	a.drawfunc=function(a)

		local dy=ret_value(a.stat==4 , 0.2*sin(a.ct/40) , 0 )
		xspr( a.pt[a.pn],a.mx , a.my+dy ,2,2,a) -- kylo

		sub_draw_bright_check(a)

		if a.blct>0 then --damaged
			local c=1+6*(flr(a.ct/4) % 2) -- 1 or 7
			pal(10,c,0)
			pal(4,8-c,0)
		end

		xspr(140, a.x ,  a.y+dy ,4,4,a) -- armor
		pal()


	end	

	return a
end

function sub_move_player_toujyou(a)
	--a.y=a.y+0.2
	local idx=flr(a.ct/2)%2		
	--a.direct=ret_value(idx==2,true,false)
	a.direct=false
	gtick=0 --scroll stop

	--printh("toujyou:"..a.ct, "log") --dbg
	if a.ct<30 then --walk
		a.mx=a.mx+0.1
		a.pn=idx+2 --index
	elseif a.ct<50 then --jump
		a.mx=a.mx+0.15
		a.my=a.my+a.dy
		a.dy+=0.05
		a.pn=idx+4 --index
	else
		a.eyed.stat=2 -- remove
		a.ct=0
		a.direct=false	
		a.pn=6
		a.y=8
		sfx(4,3)	
		a.stat=4
		a.brct=10
		a.punch0.brct=10
		a.punch1.brct=10
		a.leg0.brct=10
		a.leg1.brct=10

		make_timer(a.x,a.y)
		make_shine(a.x,a.y)				
		music(8,0,7) --main bgm

	end

	--if a.y>=a.y0 or (a.y>sty and (btnp(5,p) or btnp(2,p) or btnp(4,p))) then
end

function sub_move_player_taijyou(a)
	--take off animation , no use a.ct
	local idx=flr(a.ct1/2)%2
	--printh("ct1="..a.ct1, "log") --dbg

	if a.ct1==0 then --init
		a.dy=-0.5
		music(5,0,7) -- game over music
	elseif a.ct1<40 then --jump
		a.mx=a.mx+0.15
		if a.my>=12 then
			make_bomb(a.x,a.y)
			a.ct1=39
			make_eyedown(a.x,a.y,20)
		else
			a.my=a.my+a.dy
			a.dy+=0.05
		end
		a.pn=idx+4 --index
	elseif a.ct1<98 then --walk
		a.my=12
		a.mx=a.mx+0.2
		a.pn=idx+2 --index
	elseif a.ct1==98 then
		make_over()
	end
	gtick=gtick0 --scroll stop
	a.ct=-1 -- syncstop
	a.ct1=a.ct1+1
end

function sub_move_player_normal(a) --normal move
	local p = 0 --player number
	local left=btn(0,p)
	local right=btn(1,p)

	local dx=a.dx

	local movable= a.jump==0 and a.knockback==0
	--printh("nobad:"..nobad, "log") --dbg

	if not movable then
		left=false right=false
	end

	local mdx= 0.3

	if left then
		dx= max(dx-0.02 , 0-mdx ) --a.direct=true
	elseif right then
		dx= min(dx+0.02 , mdx) --a.direct=false
	else
		dx= ret_value( abs(dx)> 0.02 ,dx*0.8 , 0.0 ) -- gensoku
	end

	a.dx=dx

	if  a.knockback==1  then --damaged knockback?
		a.knockback=2
		a.jump=8
		a.dy=-0.4
		a.dx=0.0-a.dx*2
		a.stat=3
	end

	if  rangecheck(a.x+a.dx,a.y)  then
		a.dx=0
	end

	a.x=a.x+a.dx
	

	if  a.jump > 0  then --- jumping?
		a.jump= a.jump-1
		a.dy= a.dy+0.1
		a.y=ret_value( a.dy<0 , a.y+a.dy, a.y)
	end

	if a.jump==0 then ---not jump
		local ongrnd =false
		local predy=a.dy

		-- falling?
		ongrnd=falling_loop(a)
		a.ongrnd=ongrnd
		if  ongrnd  then
			if predy~=0 and a.dy==0 then
				make_sparkles_granddust(a)
			end
		else--- falling start?
			a.dy = min( a.dy+0.02 , 0.3 ) -- fall
		end

		-- let's jump?
		--if btnp(5,p) and btnp(4,p) then
		if btnp(2,p) then
			if ongrnd then		
				a.jump=18
				a.dy=-0.8
				make_sparkles_jumpdust(a)
			end
		end

--		if btnp(3,p) then --debug blink
--			a.blct=600 a.blrt=4
--		end

	end
end

function sub_move_player_pattern(a) --sprite pattern
	local pase = ret_value( abs(a.dx)>0.2 , 0.4 , 0.2 )
	pase= a.dx==0 and 0 or pase
	a.pc=(a.pc+pase) % 2.0
	--a.pn= flr(a.pc)+2 -- index is 1-
	a.pn=6
	if a.jump>0  then
		--a.pn=3
	end
	if a.knockback>0  then
		--a.pn=4
	end
	a.mx=a.x+1.1
	a.my=a.y+0.4

end


function sub_draw_bright_check(a) --bright effect
	if a.brct>0 then
		local tbl={9,10,7}
		local c=tbl[(flr(a.brct/4) % 3)+1] -- 3,2,1
		pal(10,c,0)
		pal(9,c,0)
		a.brct=a.brct-1
	end
end

function sub_draw_ola_check(a) --ola effect
	if a.stat==3 or a.stat==4 then
		local tbl={3,11,7,11,3}
		local c=tbl[(flr(a.olct/5) % 5)+1]
		pal(1,c,0)
		a.olct=a.olct+1
	end
end



function draw_hits(a,pos) --- player hits stars
	if a.stat>1 and a.stat<99 then
	local max=ret_value( hits>10,10,hits)
		for i=1,max do
			local xx=camx+38+i*8
			spr( 215,xx,pos+i/4)		
		end
	end
end

function draw_time(a) --- player time
	local xx=camx+(2-stx)*8
	local yy=a.y*8 -3*8
	spr(214,xx,yy)
	local num=counts
	local xrate=1000
	local n=0

	for i=1,6 do
		n=flr(num/xrate)
		if i==4 then
			pset(xx+33,yy+7-i,14) --period
		else
			spr(198+n,xx+8*i,yy-i)
			num=num-n*xrate
			xrate=xrate/10
		end
	end

	if counts>0 then
		counts=counts-1
	end
end

--- utility function ------------------

--- falling_check_loop , effective : a.dy , a.y
function falling_loop(a)
	local ret=false
	if a.dy > 0 then --- falling?
		local imax=a.dy/0.1
		for i=0,imax do
			if hitcheck_under(a,0.0,4.1, 0,3) then
				a.dy = 0.0
				a.y=flr(a.y+0.1) --adjust(important!)
				ret=true
				break
			end
			a.y=a.y+0.1
		end
	elseif  a.dy==0  then
		ret=hitcheck_under(a,0.0,4.1, 0,3)
	end
	return ret
end

function rangecheck(x,y)
	local ret=false
	if  x<stx+0 or x >stx+16-2  then -- 2x2 chr
		ret=true
	end
	if  y<sty+0 or y >sty+14-2  then -- 2x2 chr
		ret=true
	end

	return ret
end

--- hitcheck_under
function hitcheck_under( a , ddx , ddy , bit1 , bit2 )
	local ret = false
	vl = mget(a.x+ddx+0.1  , a.y+2+ddy)
	vr = mget(a.x+ddx+0.1+1, a.y+2+ddy)
	if fget(vl,bit1) or fget(vr,bit1) then
			ret=true ---- on foot!
	elseif fget(vl,bit2) or fget(vr,bit2) then
			ret=true ---- on foot!
	end
	
	--printh("hitchk b:"..bit , "log") --dbg
	--printh("hitchk >:"..ret_value(fget(vl,bit),1,0 ), "log") --dbg
	--printh("hitchk y:"..(a.y+2+ddy) , "log") --dbg

	return ret
end


--- hitcheck pc-body
----- use enemy-function
function hitcheck_player( a , knock)
	local flag=false
	if player~=nil then
--		if player.stat==4 and player.knockback==0 and player.blct==0 then
		if player.stat==4 and player.knockback==0 then
			--flag= a.x < player.x+4.0 and player.x < a.x+wd and a.y < player.y+4.0 and player.y < a.y+ht
			flag= a.x < player.x+4.0 and player.x < a.x+1.0 and a.y < player.y+4.0 and player.y < a.y+1.0
			--flag= abs( player.x - a.x )<1.0 and abs( player.y - a.y )<1.0
			if  knock and flag  then
				player.knockback=1
			end
			if  flag  then
				rate=0 -- combo rate is ended
			end
		end
	end
	return flag
end


----- use enemy-function
function hitcheck_myattack( a )
	local flag1,flag2,flag3,flag4 = false
	local p=player
	if p~=nil then
		local s0=p.punch0.stat
		local s1=p.punch1.stat

		flag1= s0>=2 and s0<=5 and hitcheck_myattack_sub( a , p.punch0 )
		flag2= s1>=2 and s1<=5 and hitcheck_myattack_sub( a , p.punch1 )
		flag3= p.leg0.stat==3 and hitcheck_myattack_sub( a , p.leg0 )
		flag4= p.leg1.stat==3 and hitcheck_myattack_sub( a , p.leg1 )
	end

	return flag1 or flag2 or flag3 or flag4
end

function hitcheck_myattack_sub( a , p )
	local flag = false
	if p~=nil then
		local wd=p.zoom/16
		flag=ret_value( abs(p.x-a.x)<wd and abs(p.y-a.y)<wd , true , false )
		if flag then
			a.attacker=p
		end
	end

	return flag
end


function round_start()
	--printh("round_start" , "log") --dbg

	foreach(sparkle,clean_sparkle)
	foreach(actorb, clean_actor)
	foreach(actorm, clean_actor)
	foreach(actorf, clean_actor)

	counts=900 --timer

	reload(0x1000, 0x1000, 0x2000) -- map restore

	stx=0
	sty=0
	--camx=stx	camy=sty
	cam.x=stx cam.y=sty --round making
	rate=0
	skycol=12

--round make

	make_player(5,8,false)
	camera()
  	field_caller = round_field
	make_roundmanage(0,0)
	
end


function easing_out(tick,start,diff,total)
	tick=tick/total
	return -diff*tick*(tick-2.0)+start
end


-- rotate sprite to sprite
function rotate_spr(pt,x0,y0,wd,ht,rad)
	local sy= flr(pt/16)
	local sx= pt % (sy*16)
	rotate_ssss(sx*8,sy*8,x0,y0,wd,ht,rad)
end

-- rotate sprite to sprite
function rotate_ssss(sx0,sy0,x0,y0,wd,ht,rad)
	local hwd=flr(wd/2)
	local hht=flr(ht/2)
	sx0=sx0+hwd
	sy0=sy0+hht

	for y=0,ht do
		for x=0,wd do
			local xx=x-hwd
			local yy=y-hht
			local sx= xx*cos(rad)+yy*sin(rad)
			local sy= -xx*sin(rad)+yy*cos(rad)
			if sx<0-hwd or sx>=hwd then --clipping
			 sx=-hwd sy=-hht
			end
			if sy<0-hht or sy>=hht then -- clipping
			 sx=-hwd sy=-hht
			end
			local c=sget(sx0+sx,sy0+sy)
			sset(x0+x ,y0+y,c)
		end
	end
end

-- scale sprite
function sspr_scale(pt,x,y,wds,hts,wdd,htd,dir)
		local sy= flr(pt/16)
		local sx= pt % (sy*16)
		sspr(sx*8,sy*8,wds,hts,x,y,wdd,htd,dir)
end

-- outline font
function textout(str , x , y , f ,b)

	? str,x-1,y,b
	? str,x+1,y,b
	? str,x,y-1,b
	? str,x,y+1,b
	? str,x,y,f

end


function fade_out()
	for i=0,40 do
		for j=1,15 do
		col = j
		for k=1,((i+(j%5))/4) do
			col=dpal[col]
		end
		pal(j,col,1)
		end
		flip()
	end
end

function half_fade()
	for j=1,15 do
		pal(j,dpal[dpal[j]],0)
	end
end

-- yet not use
function update_score( add )
	score=score+add
	if  score > hiscore  then
		hiscore=score
	end

end

function dbgfunc(o)
	printh("k:"..o.kind , "log") --dbg
end

-- gamover sub
function deal_gameover()
	--actor , prticles all deleted
	foreach(sparkle,clean_sparkle)
	foreach(actorb, clean_actor)
	foreach(actorm, clean_actor)
	foreach(actorf, clean_actor)

	--printh("gameover del" , "log") --dbg
	--foreach( , dbgfunc ) --dbg
	
	dset(0,hiscore)
	stx=0 sty=0
	deal_start()
	
end

function clean_sparkle(o)
	del(sparkle,o)
end

function clean_actor(o)
	if o.kind<20 then
		del_actor(o)
	end
end

--- game start or restart
function deal_start()
	camx=0 camy=0
	cdx=0 cdy=0
	field_caller = title_field

	--actor , prticles all deleted
	foreach(sparkle,clean_sparkle)
	foreach(actorb, clean_actor)
	foreach(actorm, clean_actor)
	foreach(actorf, clean_actor)

	player=nil
	cam=make_camera(0,0)
	make_title(16,5)
	
	score=0
	rate=0 --- combo rate
	--stock=3
	hits=7
	cls()
end



--- background and field per frame
function title_field( gtick ) --field_caller

	half_fade() --bg is half fade
	round_field( gtick )

	pal()

end


--line scroll info ---
function round_field( gtick ) --field_caller
	local scx=camx+cdx --- billboard x

	rectfill(scx, 0,scx+128,7*8-1,12) -- back sky

	local ly=0
	for i=1,5 do -- sky gradiant
		rectfill(scx,ly,scx+128,ly+6-i,1)
		ly=ly+i+1+i
	end

	local off=camx/5 + (gtick*2) % 46
	mapdraw(stx,sty,   0-off,0,  32,7,0x00)--night buillding	
	local off0=(gtick*5) % 46
	mapdraw(stx,sty+7 , 0-off0,56,  32,6,0x00)--station home
	--printh("off0 "..off0 , "log") --dbg


	-- raster ground (pcg rotate)
	local ad=16*32
	sccnt=gtick/0.01
	for i=0,7 do
		local p=peek4(ad)
		local off= sccnt % sccmod[i]
		if off==0 and gtick>gtick1 then
			p=rotr(p,4)
		end
		poke4(ad,p)
		ad=ad+16*4
	end
	gtick1=gtick
--		sccnt=sccnt+1

	for j=0,31 do
		spr(16,j*8,104)
	end

	local off1=camx/5 + (gtick*80) %  32
	mapdraw(96,14,   0-off1,112, 32,2,0x00) -- bottom floor

end
----
-->8
-- px9 decompress

-- x0,y0 where to draw to
-- src   compressed data address
-- vget  read function (x,y)
-- vset  write function (x,y,v)

function px9_decomp(x0,y0,src,vget,vset)

	local function vlist_val(l, val)
		-- find position
		for i=1,#l do
			if l[i]==val then
				for j=i,2,-1 do
					l[j]=l[j-1]
				end
				l[1] = val
				return i
			end
		end
	end

	-- bit cache is between 16 and 
	-- 31 bits long with the next
	-- bit always aligned to the
	-- lsb of the fractional part
	local cache,cache_bits=0,0
	function getval(bits)
		if cache_bits<16 then
			-- cache next 16 bits
			cache+=lshr(peek2(src),16-cache_bits)
			cache_bits+=16
			src+=2
		end
		-- clip out the bits we want
		-- and shift to integer bits
		local val=lshr(shl(cache,32-bits),16-bits)
		-- now shift those bits out
		-- of the cache
		cache=lshr(cache,bits)
		cache_bits-=bits
		return val
	end

	-- 1-based number
	function gn1()
		local bits,tot=1,1

		while 1 do
			local mx,vv=2^bits-1,
				getval(bits)
			tot+=vv
			bits+=1
			if (vv<mx) return tot
		end
	end

	-- header

	local w,h,b,
	el,pr,x,y,splen,mode =
		gn1(),gn1(),gn1(),
		{},{},0,0,0

	for i=1,gn1() do
		add(el,getval(b))
	end
	for y=y0,y0+h-1 do
		for x=x0,x0+w-1 do
		
			splen-=1
			
			if splen<1 then
				splen,mode=gn1(),not mode
			end
			
			local a= y>y0 and vget(x,y-1) or 0
			
			-- create vlist if needed
			local l=pr[a]
			if not l then
				l={}
				for e in all(el) do
					add(l,e)
				end
				pr[a]=l
			end
			
			-- grab index from stream
			-- iff predicted, always 1

			local idx=mode and 1 or gn1()+1
			local v=l[idx]

			-- update predictions
			vlist_val(l, v)
			vlist_val(el, v)
			
			-- set
			vset(x,y,v)
			
			-- advance
			x+=1
			y+=flr(x/w)
			x%=w
			
		end
	end
	
end
-->8
-- system 
-- called at start by pico-8
function _init()
		--printh("180602", "log") --dbg

	if  cartdata("gmie") == true  then
		hiscore=dget(0)
		hiscore=ret_value( hiscore<500 , 500 , hiscore)
	else
		hiscore=500
	end

	sparkle = {}
	deal_start()
	skycol=0 --12
	
end

function _update()
    foreach(actorb, move_actor)
    foreach(actorm, move_actor)
    foreach(actorf, move_actor)
    foreach(sparkle, move_sparkle)
end

function wavepos(x)
	return 1.5*sin(x/32+gtick)
end

function _draw()
	camera(camx+cdx,camy+cdy)
	cls()
	field_caller( gtick )
	gtick +=0.01

	foreach(actorb, draw_caller)
	foreach(actorm, draw_caller)
	foreach(actorf, draw_caller)
	foreach(sparkle, draw_sparkle)



	--information
	--local pos=1.5+sin(gtick)
	textout("score "..score,camx+1,wavepos(1)+8,10,9)
	textout(""..hiscore, camx+56 ,wavepos(56)+4,7,6)

	--star--
	if player~=nil then
		--player:drawhits(10)
	end

--	if player~=nil then
--		local aa=player.leg0 
--		spr(2,(aa.x-stx)*8,(aa.y-sty)*8,2,2,false)
--	end
	--debug
	--cursor(camx+5,18)
	--print(mes)
	--mes="--"

	cursor(camx,30)
	if player~=nil then --debug
		--print(">jp:"..player.jump)
		--print(">st:"..player.stat)
		--print(">kb:"..player.knockback)
		--print(">bt:"..player.blct)
		--print(">ct 0:"..player.leg0.ct1.."  1:"..player.leg1.ct1)
	end
	--print(">cpu:"..stat(1))
	--print(">tikc:"..gtick)

	--print(">sp:"..#sparkle)
 	--print(">ac:"..#actorb+#actorm+#actorf)
 	--print(">cmx:"..camx)

--	cursor(camx+35,110)
-- 	if hit3 then 	print(">hit3:t")
--	else	 	print(">hit3:f")
--	end
-- 	if hit0 then	 	print(">hit0:t")
--	else	 	print(">hit0:f")
--	end

end





__gfx__
ccccccc500000000122222222222222512222222222222251111111111111111000000000000000000777700777777771111111101999999919aaa1001eeeeee
cccccc5c000000001222222222222225122222222222222511515151515151510000000000000000077777707777777711111111011111111111111001111111
ccccc5cc000000001222222222222225111111111111111111515151515151510000001111000000777777777777777711111111011111111111111001111111
cccc5ccc0000000012222222222222251dddd111111111111151515151515151000011111111000077777776777777771111111109999949999991100eeeee8e
ccc5cccc0000000012222222222222251d1111111111111111111111111111110001111111111000777777667777777711111111011111111111111001111111
cc5ccccc00000000122222222222222511111111111111111151515151515151001111111111110007766660777777771111111109991999949994900eee1eee
c5cccccc0000000012222222222222251d1111111111111111515151515151510011111111111100006666007777777711111111011111111111111001111111
5ccccccc0000000012222222222222251d111111111111111151515151515151001111111111110000000000777777771111111109999999999499900eeeeeee
1155111111551111113311111133111111111111111111112200002200000000000000000000000000070700005dddcc7c777600511000000000000022000022
111111111111111111111111111111111d111111111111112000000200000000000000000070700000707070005dddccc7777600151000000000000020000002
311333311331133331133331133113331d111111111111110000000000000000007060000707070007070707005dddcc7c777600515000000000000000000000
3113333113311333311333311331133311111111111111110000000011111111070706000070707070707070005dddccc7777600151000000000000000000000
111111111111111111111111111111111d111111111111110000000011111111007070600707070007070706005dddcc7c777600115000000000000000000000
133333111333333113333311133333311d111111111111110000000011111111000706000070606000706060005dddccc7777600511000001111111100000000
3bbbbb313bbbbbb13bbbbb313bbbbbb111111111111111112000000211111111000000000006060000060600005dddcc7c777600151000001111111120000002
13bbb31113bbb33113bbb31113bbb3311d111111111111112200002211111111000000000000000000000000005dddccc7777600115000001111111122000022
00000000000000000000000000000000000000000000000000000000220000220011111111111100220000221111111111111111555555555555555d22000022
06100000061000000610000000000000000000000000000000000000200000020011111dd1111100200000021151515151515151777555555555555d20000002
66100000616100006161000000000220000002200000022000002222000000000011d11dd1dd1100000000001151515151515151777555555555555d00000000
07116161006161610061616100002002000020020000202000002000000000000011d11111dd1100000000001161616161616161555555555555555d00000000
07171717071717170717171780800080808000808080808080808888000000000011d1111111d100000000001111111111111111ee5555555555555d00000000
07171717710717177177171708000800080080080800888808000008000000000011111111111100000000001161616161616161ee5eeeeeeeeeee5d00000000
66616161666161610661616180808888808008808080008080808888200000020011111111111100200000021c6c6c6c6c6c6c6c555555555555555d20000002
00000000000000000000000000000000000000000000000000000000220000220011111111111100220000221c6c6c6c6c6c6c6cdddddddddddddddd22000022
77777777770077777777777741111111220000222200002222000022220000220000000000000000000000000000000000000000555555551111111111111111
6666666666600666666666664011111120000002200000022000000220000002000000000000000000000000000000000000000055555555aabbbbb1aabbbbb1
66666666666666666666666640011111000000000000000000000000000000000000000000000000000700000000000000000000dddddddda1111131a1111131
5555555555555555555555554000111100000000000000000000000000000000000600000007700000077a000700000000000000ddddddddb1bbb331b1bbb331
55555555555555556a9999a64000011100000000000000000000000000000000000000000007a0000077a0007700000000000000ddddddddb1bb3331b1bb3331
555555555555555556666665400000110000000000000000000000000000000000000000000000000000a0000077aa0000000000ddddddddb1b33331b1b33331
55555555555555555555555540000001200000022000000220000002200000020000000000000000000000000007a00000000000ddddddddb1333331b1333331
11111111111111111111111144444444220000222200002222000022220000220000000000000000000000000000a00000000000ddddddddb3333331b3333331
00000000000000000000000000000000000000000000000000000000000000000000000000000000000004444000000000000011110000000000600600600000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000004a4aa400000000001111111100000060000000006000
000000000400000000000000000000000000000000000000000000444404000000004444004400000004a4aaaa44000000111111111111000600000a00000600
000004444a400000000004444400000000000000000000000000444aa44a400000044aaa44a4000000004aaaaaa4400000111111111111000000000000000000
00004aaa44a4000000004aaa4a40000000000444400000000044a4aaaaa440000004aaaaaa444000004aaaaaaaaa400001111111111111106000a00000a00060
0044a4aaaaa400000044a4aaaa44000000004aaa44000000004a4aaaaaa4a4000004a44aaaaaa4000444aaa4aa4a444001111111111111100000000000000000
04a44aaaaaaa400004a44aaaaaa440000044a4aaaa440000004aaaaaaaaa4a40004aaaa9aaa4a4004aa499a4aa4a4aa411111111111111110000000700000000
004aaaaaaaaa4000004aaaaaaaaa400004a44aaaaaa44000004aaaaaaaaaaa40004aaaa9aaa440004aa40aaaaaa44aa4111111111111111160a000777000a060
004aaaa4aa4a4000004aaaaaaa4a4000004aaaaaaaaa400000044aaa9aaaa40004aaaaaaaaaaa400044404444440044011111111111111110000000700000000
000499a4aa4a40000004aa99aa4a4000004aaaaaaa4a4000004a4aaa9aaaa40004a4aaaaaaaaa400000000000000000011111111111111110000000000000000
00004aaaaaa4000000004aaaaaa400000004aa99aa4a4000004aaaaaa44a4000004a4aaaaaa4a400000000000000000001111111111111106000a00000a00060
0004a4aaaa4a40000004aa4aaa40000000004aaaaaa40000000444aaaaaa400000044aaaaa4a4400000000000000000001111111111111100000000000000000
004a44aaaa44a4000004a4a4aaa400000004aaaaaa40000000004a44aaa440000004a44aa4440000000000000000000000111111111111000600000a00000600
00444aaa4aa4440000044a44aaa40000004a4aaaaaa4000000004400444400000000404444000000000000000000000000111111111111000060000000006000
0004aaaa4aaa4000000044aaa94000000004aaa44aa4000000000000000000000000000000000000000000000000000000001111111100000000600600600000
00044444044440000000044444000000000444400444000000000000000000000000000000000000000000000000000000000011110000000000000000000000
00000000000000000000000000000000000200002088200000020000200020000000000000000000000000000000000000000033330000000000003333000000
000000000000000000000000000000000000228888ee8077000022888888100000000076000000000000000760000000000033bbbb330000000033bbbb330000
00000007000000000005600700000040000a5e8888eee876000a5e8888ee8777003300760000000000330007600000000033bbbbbbbb33000033bbbbbbbb3300
0075656400004410007445640000441000a9e88888eee87600a9e88888eee87700330076007600000033000760076000003bbbbbbbbbb300003bbbbbbbbbb300
074445504000414007444450400041500a9ee888888887600a9ee888888ee8760333007700760000033300077007600003bbbbbbbbbbbb3003bbbbbbbbbbbb30
074444560044150000544456004415005a58888ee82776205a58888ee88877600a335077007600500a3350077007605003bbbbbbbbbbbb3003bbbbbbbbbbbb30
07544448444445400045444844444540055588eeee827600055588eeee2776203a335077007605003a335007700765003bb3333bb3333bb33bb3333bb3333bb3
00454445499944000000088549999400005588eeee822200005588eeee2222000333b3b3b3b3b3b30333b3b3b3b3b3b33bbbbbbbb3bbbbb33bbbbbbbb3bbbbb3
000222249aaa9400000222249aaaa900055588eeee827200055588eeee2776200333b3b3b3b3b3b30333b3b3b3b3b3b33bbbbbbbb3bbbbb33bbbbbbbb3bbbbb3
004544454999440000000885499994005a58888ee82776205a58888ee88877603a335077007605003a335007700765003bbbbbbbb3bbbbb33bbbbbbbb3bbbbb3
075444484444454000454448444445400a9ee888888887600a9ee888888ee8760a335077007600500a3350077007605003bbbbb333bbbb3003bbbbb333bbbb30
0744445600441500005444560044150000a9e88888eee87600a9e88888eee8770333007700760000033300077007600003bbbbbbbbbbbb3003bbbbbbbbbbbb30
07444550400041400744445040004150000a5e8888eee876000a5e8888ee877700330076007600000033000760076000003bbb3333bbb300003bbb3333bbb300
007565640000441000744564000044100000228888ee80770000228888881000003300760000000000330007600000000033bb3333bb33000033bbbbbbbb3300
000000070000000000056007000000400002000020882000000200002000200000000076000000000000000760000000000033bbbb330000000033bbbb330000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033330000000000003333000000
00000011110000000000001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001111111100000000111111110000000000000111000000000000011100000000000000000000000000000000000000000000000000000000000000000000
00111111111111000011111111111100011111001666100001111100166610000000000000000000000000dddd00000000000000000000000000000000000000
001111111111110000111111111111001199911199966110119991119966111000000000000000000000dddddddc000000000000000000000000000000000000
01111111111111100111111111111110199999199999966119999919917717710000000000000000000dddddddddc00000000000011000000000100000000000
01111111111111100111111111111110177771999991977117777199911667710000000ddd000000000dddddd66ddc0000000000169100000001910000000000
1111111111111111111111111111111119999199999991111999919999111111000000ddddd0000000ddddd66c66660000000000016910000000191000000000
111111111111111111111111111111111999919999999661199991999916677100000ddddd67000000dddd66ccc6c70000000011101671000000171010000000
1111111111111111111111111111111119999199999197711999919999166771000006dd66c7000000dddd6cccccc70000000019a11671000000017191000000
111111111111111111111111111111111999919999999111199991999a11111100000076cc70000000ddd6ccccccc700000111119a1167100000017991110000
01111111111111100111111111111110199991a999999661199991aaaa1667710000000777000000000cd6cccccc70000019911119aa671000000179119a1000
011111111111111001111111111111101a99991aaaa1a7701a99991aaa11677000000000000000000000cdccccc70000001199a11119a7100000017119a10000
0011111111111100001111111111110011aaa111aaaaa11011aaa111aaaa11100000000000000000000007cccc7000000001199aa1111811100001199a000000
0011111111111100001111111111110001111100011110000111110001111000000000000000000000000077770000000000019999919988811118a1a0000000
0000111111110000000011111111000000000000000000000000000000000000000000000000000000000000000000000011101991199999988889aa10111100
00000011110000000000001111000000000000000000000000000000000000000000000000000000000000000000000011555111199ddd99999999ada1d55110
5000000611000000615555560155015500011111111000000001111111100000000000dddd0000001199999988889aa11555556199d666ddd9999dddd1d55551
055556601111000067666666155015500019999999910000001dddddddd100000000dddddddd000099ddd99999999ada5555556119d77766dd99dd66da155551
0000000011111100076666601500150001911111111a100001d111111116100000ddd66666dd66009d666ddd9999dddd5555561419d777711d99d117da155551
00000000111111000155555015001500191555555551a1001d1555555551610000dd6666c66666009d66666dd99dd66d16555614919d77712d99d217da1ddd11
0000000011111110615555561500150019955555555aa1001dd55555555661000dd666ccc66666609d777666d99d666d116661019199ddddd9999ddda1011110
000000001111111067666666160016001999999aaaaaa1001ddddddddd6661000d6666ccc666666019d77776d99d677d0111100009199999999999aaa1000000
000000001111111107666660155015501999999aaaaaa1001ddddddddd666100dd666ccccc666667199ddddd9999ddda0000000011119999999999aa10000000
000000001111111101555550015501551999999aaaaaa1001ddddddddd666100dd666cccccc66cc79199999999999aa0000000011188119999999a1100000000
11111111111111110060650000055000199999aaaaaaa1001ddddddddd666100dd66ccccccccccc700000000000000000000001550187719aaaaa16110000000
11111111111111110600765000550550199999aaaaaaa1001dddddddd6666100dd66ccccccccccc7000000000000000000001155560177711111161651000000
01111111111111100675566505505500199999aaaaaa11001dddddddd66611000dd6cccccccccc70000000000000000000015555566017777777710655100000
01111111111111106066556605005055119555555551241011d55555555124100d66cccccccccc7000000000000000000015555566649005555600a165510000
00111111111111006556655056055550121999aaaa124441121ddddd661244410066ccccccccc70000000000000000000015555566149990556099a166551000
001111111111110076556606556505001421aaaaa12444411421dd666124444100666ccccccc7700000000000000000000155556610111999999a11166551000
0000111111110000566506600550650001101111101111100110111110111110000077cccc770000000000000000000000015666610000111111100016610000
00000011110000005566600000505000000000000000000000000000000000000000007777000000000000000000000000001111100000000000000001100000
000000000000000000000000000000000000000000000000eeeeeee2000e20000eeeee200eeeeee200eeee200eeeee200eeeeee20eeeee2000eeee200eeeeee2
000000000000000000000000000000000000000000000000e20000e2000e20000ee200e20e2000e20ee20e200ee200000e2000e200000e200e2000e20e2000e2
000000000000000000000000000000000000000000000000e20000e2000e20000ee200e2000000e20e200e200ee200000e20000000000e200e2000e20e2000e2
000000000000000000000000000000000000000000000000e20000e200ee2000000000e2000eee200e200e200eeeeee20eeeeee200000e200e2000e20e200ee2
000000000000000000000000000000000000000000000000eee200e200ee2000000eee2000000ee20e200e20000000e20e2000e200000e2000eeee200eeeeee2
000000000000000000000000000000000000000000000000eee200e200ee200000e2000000000ee20eeeeee2000000e20e20eee20000ee200e200ee2000000e2
000000000000000000000000000000000000000000000000eee200e200ee20000e2000000e200ee20000ee200ee200e20e20eee20000ee200e200ee2000000e2
000000000000000000000000000000000000000000000000eeeeeee200ee20000eeeeee20eeeeee20000ee200eeeeee20eeeeee20000ee200eeeeee2000000e2
000eeee000000000000000000000000000000000000000000dddd600000c60000111000000000000000000110000000000000000000000000000000000000000
00e5555e0007880080008080000788088808000800000000dd77dd6000ccc6001ddd100000000100000001dd0770077007700770077007700770077007700770
00e5ee5e0078008080808080000080080008222800000000d7777d60ccccccc61717111101111d10011101777007700770077007700770077007700770077007
00e5e55e0080008080808080000080088800888000000000d7577d60ddcccc601711177717771777177717717000000770000007700000077000000770000007
00e5ee5e0080008080808080000080080000080000000000d7557d6000dcc6001717171717771717170711107000000770000007700000077000000770000007
00e5555e0082228082828082202280082200080000000000d7777d600dcccc601ddd1ddd1d1d1ddd1ddd1d100700007007000070070000700700007007000070
000eeee00008880008080088808800088800080000000000dd77dd60dcc00cc60111011111010111111101000070070000700700007007000070070000700700
0000000000000000000000000000000000000000000000000dddd600000000000000000000000000000000000007700000077000000770000007700000077000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff0fff71af2096278947dfffff51121ec4433f35862ecc480ffff20c14633b8c6212f30942d88522675835f2eff9c9943b441cf2c30c0727ac9cfacf1cf1
4c085ad746a808746651a56c5af6e0f768f38f5852e098cfac743c92738f39f580f52a06c1a18d8202f0ce02424de6298f39fb2c7212414209f983830481fb00
cfbcff1080868b71ac52f01616272848f790f250593815c34cc367040268f2c1c902cfd990f683852486833cff42411e26cff0897e4148422cbc552a1a1acb44
b1e362ffb06a762958ffd4808ff39c80fffa4270fb0758ff558b884048ff994214e0641c13c349f81707c0f00c11ef5e7b42ffb19f79f9870cfbcfec1cff6838
f1de919f99f7c62240c049f768070818fd8722fb33e5a148ff903eff544ef6694e42e1c52ff380ff7b08ff10b0f11ef75cffd20eff0cf1968b8efff3a0ceff1c
2c761eff148f2cff462148fd343cb97cffff11801e77e9072ffff701090fb31e7a070705e2e74e06c5c741cfe10ff08fff3367c8cff180f368381f1901ec02c1
48f81f1ff32e7c03ac512cf43c817581750cff282731e770f270ff302cff58f7838fff73cff68fffff600ff583817170f25e02c54978ff51f36815ef7116c8ff
fff04effffff11d11f98cfff1a888cfffc759fffff1894effff7129cfff9a0ff3d8888937b9cec8522b88954ce8c69d2b4c4444442194844a1119ff564e172ea
4c144243198c311cd1ea03a1ef764984ae4bb2028c24ea520711ef10f3c0fff2e9429c27e695361b463116129d8468b9469086444effa1bc6bd7683e008b948f
fc011cffa34b0fad11eff848ff3f2903669834ec4c93c8fffb69c423901936b58c180756121b854eff328ffd509da197429ccc6fb4244e061a1a196839ff913b
f66e222b409ff223e121e749ff71938c698cbb9d2290f6529469e8894a34248736fff2efffe44a1efffabc2858ffffe19221fff7e71acfffff08cffffff3b0ff
fff04effffff11d11f98cfff1a888cfffc759fffff1894effff7129cfff9a0ff3d8888937b9cec8522b88954ce8c69d2b4c4444442194844a1119ff564e172ea
__gff__
0000000000000808000000800000000000000000000000000000008080008000000000000000000000000008080000000000000100000000000000000080010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101000000000000000000000000
__map__
01010101010101010101010101060701010101010101010101010101010101330101010101010101010101010101010101010101010101010101010101010133010101010101010101010101010101010101010101010101010101010101013301010101010101010101010101010101010101010101010101010101013c3c3c
01010101010101010101010101060701010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101013c3c3c
01010101010101013801010101060701010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101013c3c3c
3901010138010101060701390106071d01010101010607013a010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101013c3c3c
0101060707013a01060701080906071d060138010106071d01010607010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101013c3c3c
0101060707010d0e060701282906071d06010d0e0106071d01010607010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101013c3c3c
0c172b2c2c0c0f0e0607170c0c2b2c0c060c0d0e0c2b2c1d170c2b2c010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101013c3c3c
30303030313030323030303130303230303130303032303030303030010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101013c3c3c
141504051415040514150405141504051415040514150405141504050101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101013c
040514150405141504051415040514150405141504051415040514150101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101013c
141504051415040514150405141504051415040514150405141504050101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101013c
040514150405141504051415040514150405141504051415040514150101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101013c
020302030203020302030203020302030203020302030203020302030101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101013c
0203020302030203020302030203020302030203020302030203020301010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101012e2f2e2f2e2f2e2f2e2f2e2f2e2f2e2f2e2f2e2f2e2f2e2f2e2f2e2f2e2f2e2f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101013f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
0101010101010101010101010101010101010101010101010101010101010133010101010101010101018c8d010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000
0101014849010101010101010101010101010101016465010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000
01010158590188890101010101018c8c8d8e8f01017475010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000
01464701018c98990101010101019c9c9d9e9f01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000
01565701019c9d8889010101018485acadaeafa7868701010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000001f1f1f1f1f1f1f1f1f1f1f
01010101a7acadaeafa70101019495bcbdbebfa7969701010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000001f1f1f1f1f1f1f1f
010101848501bdbebf01a786870101a60101a60101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000001f1f1f1f1f1f1f
0101019495a60101a60101969701a4a50101a4a501012b2b2b2b01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000001f1f1f1f1f1f1f
010101a4a501a4a5010101010101b4b50101b4b501012b2b2b2b2b010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000001f1f1f1f1f1f1f
010101b4b501b4b501011b1c010101010101010101012b2b2b0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000001f1f1f1f1f1f1f
010101010101010101011b1c010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000001f1f1f1f1f1f1f
01012b2b2b2b010101011b1c0101010101011b1c0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000001f1f001f1f001f1f1f1f1f1f1f1f1f
010101012b2b010101011b1c0101010101011b1c0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000001f000000001f1f001f1f1f1f1f1f1f
010101010101010101011b1c0101010101011b1c0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010c01010101010101000000000000000000001f001f1f1f1f1f1f1f1f1f1f1f1f1f
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f0000000000000000000000001f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0000000000000000000000001f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f
__sfx__
00010000190500e0503805037050320502e0502805024050210501e0501d0501d0501e050000002205027050280502a0500000014050160501805025050250501c0500000034050380503b0503d0503e05000000
00020000000000d1501215016150191501d1502015023650221501c1501a1501915017150161501415015150186501a6501110010100101000e1000d100240002400024000240000000000000000000000000000
000200000e55011550155501f55029550285502555022550205501e5501e5501f5501f55020550225502235024350243502535026350293502a3502c3502f3503a35000000000000000000000000000000000000
001000000c3000f3400f25010350102500f3500f2501035010250000000f0501c0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000266402763028630296402b6402a5502954029550285502755026550245502254021530205302052020520000000000000000000000000000000000000000000000000000000000000000000000000000
000100002343023430234402346025450264502e650316503365035650366503765036650316502e6502c6402b640000000000000000000000000000000000000000000000000000000000000000000000000000
000300002d3522f35231352323423534236332383502b3502d35032350373402233024330273302a3302d3400f34011340133400a3300d3200233001350013500234003330043300332000320003100000000000
000100002443021430214402046020450204500c6500465004650046500465005650056500d6500e6500e6400c6401a200024001330011300103001030010300103000f200103000f2001c2001d2001c2001a200
011000001b3521b35219350013001b3521b3521c350000001d3502d2001f3501f35025100203501e353203500c6001b350000001b350000001b35500000000000000000000000000000000000000000000000000
01050000000000000037053000000000000000350530000000000000003e056000000000000000105501255015556185561c556275562d5562e5502e5502f55033550385503b5503d5503e5500a6500665000000
00040000000000e15201152041520e152091450514503245012500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200000d2350d2400e2550d2550e251102451d3000e2300e2400e0500e2550e255102510e255100500e250103501836018050183501c3501c050183501c35012350133501f3421f3501d3421c3500500200000
010a0000197551b7551e75021753267502875015752197521d7552175523752257532875213002107521375213755097553175028755277502375023750237502375023755000000030500300000000030500000
011400001c5001c7001c7000f7002175023750237502175023750237500000023700237502373023700217002370000000000000000021750237502375021750237502375000000000001c7501c7300000000000
010a00001874018700187401c1401c101187400c130277001875018700187501c1461c101187500c130277001875018700187501c1471c101187500c130277001875018700187501c1471c101187500c13027700
01140000107600e7501a760107501c7600e76010700230000f7600f760107400f7600f700270001f000280002100029000240002b0002d0002f00031000300003200033000000000000000000017000000012700
010a00000000000000184220000018422000001c42200000184200000000000000000000000000000000000000000000001842200000184220000010422000001842000000000000000000000000000000000000
01120000001000c22011120003000c120000000000008120000000c12011120000000c120000001860008320000000c12011120000000c120000000000008120000000c12011120000000c120000000000008320
011000001c7521c0051c745000001a7501c750000001c750000001a05000000180500000018050000001a05000000240551f05524055000001f0531f05300000000001d7501d050000001d74000000000001d750
010b0000217201f7701d7731c7501c7201c700187701a770217201f7701d7731c7701c0001c700187501a7501c0001c0001c0051a7601d6431a7001a7601d6431c0001a7601d6430000000000000000000000000
010a000011255050051125511300112550000011255005001336010360103600f3600000012360000001536015360103600c3600000013360133600e3660e3660e33600000000000000000000000000000000000
011000000c530020000d560100000d650110500c7500c7500c530025000d5600c0000d650110500c7500c7500c5300e5000f560000000d6500e0500c7500c7500e5300e5000f560000000c6500e0500c7500c750
010a00001f0501f0501f0501f0001f0501f0501f0501f0501f0501f0501f0501f0501f0501c0011f0011d0011f0501f0501f0501d1011f0501f0501d0501d0501d0501d0501d0501d0501d050000000000000000
001000001f1501f5500c6531f5501f5501d5501f5001f5501f5500c6531f5501e1001f5500c65311100111001f150265501f653275501f5501d5501f50018550135500c653195501e100125500c653110001b000
011400001c2551a0501c2551a2551c2511a2551c0501a2501d250245001d2551d2551c2511c255246031d2501f3501d3601c0001f3501d3501c5001f3501d350106031c5021d5421d0501d5421d0501d54200000
011400000f4000f5330c13010130131300e500035330e5001b7000f5330c13010130131302b30003533183000c2300e630240000c1300e630000000c1300c6300000000000000000000000000000000000000000
011400001c0601c0601a050180500c000180401b040180401b0401c0400c052180620000000000040001c0501c0501a050180501a000180501b05018040180401d0301a0301c0401d0501a06018060180601d070
0102000000000143501335011350103500e3500c3500b30025350213501f3501c3501a35018350163501435012350103500e3500d3500b3500935006350033500000000000000000000000000000000000000000
0000000036350333501435012350113500f3400d34027330263302432022320203301f3301c3301a3501936018350173501635000000000000000000000000000000000000000000000000000000000000000000
0005000000000270503c0002905130051290511e0011a0011a0011400219000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0114000010750107500e750107300c000187501b750187501b7501c75010750107500000000000040001c7501c7501a750187501a000187500f75018750187501d7501a7501c7501d7501a75018750187501d750
011400001855018550185501855018550185502300018550225502255022550225502255022550000002255020550205502055020550205502055000000205502255022550225502255022550225500000022550
01020000180501f050180501a0500000000000000001a0500000000000000000000000000000000000000000143501335011350103500e3500c3500b300253500000000000000000000000000000000000000000
010a00001f0501f0501f0501f0001f0501f0501f0501f0501f0501f0501f0501f0501f0501c0011f0011d0011c0501f0501c0501d101210501c0502105021050210502105021050210501a050000000000000000
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
04 41 11 43 44
01 0d 0c 43 44
06 0e 0c 43 44
01 41 10 43 44
02 41 10 43 44
04 13 42 43 44
00 41 42 43 44
00 41 42 43 44
01 0e 42 43 44
00 0e 16 43 44
00 0e 42 43 44
02 0e 21 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
