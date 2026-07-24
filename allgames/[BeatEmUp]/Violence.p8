pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- violence: there is no option but violence
-- by sab (konrad.najlepszy@gmail.com)
-- submission for grawitacja 8-bit game jam

--math utils-------------------
function rndr(a,b)
	return a+rnd(b-a)
end

function clamp(v,mn,mx)
	return max(mn,min(v,mx))
end

function strong(x)
	if (x==0) then
		return 0
	elseif (x==1) then
		return 1
	else 
		return x*strong(x-1)
	end
end

function npoint(x,y)
	local p = {}
	p.x = x
	p.y = y
	p.mag = function()
		return sqrt(p.x*p.x+p.y*p.y)
	end
	return p
end

function clone(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

do
 local f={}
 local p={}
 local permutation={151,160,137,91,90,15,
  131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
  190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
  88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,134,139,48,27,166,
  77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
  102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,18,169,200,196,
  135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,250,124,123,
  5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
  223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,172,9,
  129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,228,
  251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,107,
  49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,127,4,150,254,
  138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
 }

 for i=0,255 do
  local t=shr(i,8)
  f[t]=t*t*t*(t*(t*6-15)+10)

  p[i]=permutation[i+1]
  p[256+i]=permutation[i+1]
 end

 function lerp(t,a,b)
  return a+t*(b-a)
 end

 local function grad(hash,x,y,z)
  local h=band(hash,15)
  local u,v,r

  if h<8 then u=x else u=y end
  if h<4 then v=y elseif h==12 or h==14 then v=x else v=z end
  if band(h,1)==0 then r=u else r=-u end
  if band(h,2)==0 then r=r+v else r=r-v end

  return r
 end

 function noise(x)
  local xi=band(x,255)

  x=band(x,0x0.ff)

  local u=f[x]
  local v=f[0]
  local w=f[0]

  local a =p[xi  ]
  local aa=p[a   ]
  local ab=p[a+1 ]
  local b =p[xi+1]
  local ba=p[b   ]
  local bb=p[b+1 ]

  return lerp(w,lerp(v,lerp(u,grad(p[aa  ],x  ,0  ,0  ),
                              grad(p[ba  ],x-1,0  ,0  )),
                       lerp(u,grad(p[ab  ],x  ,-1,0  ),
                              grad(p[bb  ],x-1,-1,0  ))),
                lerp(v,lerp(u,grad(p[aa+1],x  ,0  ,-1),
                              grad(p[ba+1],x-1,0  ,-1)),
                       lerp(u,grad(p[ab+1],x  ,-1,-1),
                              grad(p[bb+1],x-1,-1,-1))))
 end
end

--object utils-----------------
function nlist()
	local l={}
	l.length=0
	l.add=function(el)
		add(l,el)
		l.length+=1
	end
	l.remove=function(el)
		del(l,el)
		l.length-=1
	end
	--compfunc returns false (left higher) or true (right higher). asc=ascending
	l.sortby=function(compfunc,asc)
		if #l>1 then
			for j=1,#l-1 do 
				for i=1,#l-1 do
					local result=compfunc(l[i],l[i+1])
					if (result and asc) then
						local t=l[i]
						l[i]=l[i+1]
						l[i+1]=t
					elseif (not result and not asc) then
						local t=l[i+1]
						l[i+1]=l[i]
						l[i]=t
					end
				end
			end
		end
	end
	return l
end

--useful gameob+jects---------------------------

function ncamera()
 local c=ntran()
	c.lp=npoint(0,0)
	--shakes
	c.sh=npoint(0,0)
	c.sh_pow=0
	c.sh_dur=0
	c.sh_stime=0
	c.shake=function(pow,dur)
		c.sh_pow=pow;
		c.sh_dur=dur
		c.sh_stime=time()
	end
	c.up=function()
		local f=(time()-c.sh_stime)/c.sh_dur
		if (f>1) then
			c.sh.x=0
			c.sh.y=0
		else
			c.sh.x=rnd((1-f)*c.sh_pow)
			c.sh.y=rnd((1-f)*c.sh_pow)
		end
	end
	c.dr=function()
		camera(c.lp.x+c.sh.x, c.lp.y+c.sh.y)
	end
	return c
end

-- transforms tree (uses up and draw recursively)
function ntran()
	local o={}
	o.order=0
	o.lp=npoint(0,0)
	o.lr=0
	o.ls=1.0
	o.parent=null
	o.p=npoint(0,0)
	o.r=0
	o.s=1.0
	o.child=nlist()
	o.up_childs=function()
		if (o.parent==null) then
			o.p.x=o.lp.x
			o.p.y=o.lp.y
			o.r=o.lr
			o.s=o.ls
		else
			local d=o.lp.mag()*o.parent.s
			local an=atan2(o.lp.x,o.lp.y)
			local rot_x=cos(an+o.parent.r)*d
			local rot_y=sin(an+o.parent.r)*d
			o.p.x=o.parent.p.x+rot_x
			o.p.y=o.parent.p.y+rot_y
			o.r=o.lr+o.parent.r
			o.s=o.ls*o.parent.s
		end

		o.up()
		for child in all(o.child) do
			child.up_childs()
		end
	end
	o.up=function() end
	o.dr_childs=function()
		o.dr()
		for child in all(o.child) do
			child.dr_childs()
		end
	end
	o.dr=function() end
	o.add=function(ch)
		ch.parent=o
		o.child.add(ch)
	end
	o.remove=function(ch)
		if (ch != null) then
			ch.parent=null
			o.child.remove(ch)
		end
	end
	o.removeall=function()
		o.child=nlist()
	end
	return o
end

root=ntran()
root.lp.x=64; root.lp.y=64

-- particles!
-- config:
-- {
--	 rate
--   rmin: rotationmin
--   rmax: rotationmax
--   pmin: powermin
--   pmax: powermax
--   smin: sizemin
--   smax: sizemax
--   tmin: lifetimemin
--   tmax: lifetimemax
-- }
function nbloodsystem(cnf,target,target_offset)
	local o=ntran()
	o.cnf=cnf
	o.nextsp=time()
	o.target=target
	o.target_offset=target_offset
	o.parts=nlist()
	o.up=function()
		o.lp.x=o.target.p.x-o.parent.p.x+target_offset.x
		o.lp.y=o.target.p.y-o.parent.p.y+target_offset.y
		while (time()>o.nextsp) do
			local part=nblood(o.cnf)
			part.lp.x=o.lp.x
			part.lp.y=o.lp.y
			o.parts.add(part)
			o.parent.add(part)
			o.nextsp+=1.0/o.cnf.rate
		end
		for child in all(o.parts) do
			if (time()>child.stime+child.ltime) then
				o.parts.remove(child)
				o.parent.remove(child)
			end
		end
	end
	o.dr=function()
		--print(#o.parts,0,100)
	end
	return o
end

function nblood(cnf)
	local p=ntran()
	local power=rndr(cnf.pmin,cnf.pmax)
	local r=rndr(cnf.rmin,cnf.rmax)
	p.v=npoint(cos(r)*power,sin(r)*power)
	p.rad=rndr(cnf.smin,cnf.smax)
	p.stime=time()
	p.ltime=rndr(cnf.tmin,cnf.tmax)
	p.up=function()
		p.lp.x+=p.v.x
		p.lp.y+=p.v.y
		p.v.x*=0.99
		p.v.y+=0.2
	end
	p.dr=function()
		circfill(p.p.x,p.p.y,p.rad,8)
	end
	return p
end

-- sprite
function nsprite(sid,sw,sh,pivotx,pivoty,scale)
	local s=ntran()
	s.sw=sw*8;s.sh=sh*8;s.pivotx=pivotx*scale/2;s.pivoty=pivoty*scale/2
	s.scale=scale
	s.sp_x=(sid*8)%128
	s.sp_y=(flr(sid/16)) * 8
	s.flashstime=time()-5
	s.glitch=false
	s.dr=function()
		if (s.glitch) then
			for x=s.sp_x,s.sp_x+s.sw-1 do
				for y=s.sp_y,s.sp_y+s.sh-1 do
					sset(x,y,rnd(15))
				end
			end
		end
		if (time()<s.flashstime+flashdur) then
			local c=8+flr(rnd(2))
			for i=0,15 do
				pal(i,c)
			end
		end
		sspr(s.sp_x,s.sp_y,s.sw,s.sh,s.p.x+s.pivotx,s.p.y+s.pivoty,s.sw*s.scale,s.sh*s.scale)
		pal()
	end
	return s
end

function nline(w,c1,c2)
	local o=ntran()
	o.w=w;o.c1=c1;o.c2=c2
	o.dr=function()
		local sx=0
		local sy=0
		if (o.parent!=null) then
			sx=o.parent.p.x
			sy=o.parent.p.y
		end
		local halfw=w/2.0
		local of=-halfw
		local sn=sin(o.parent.r+0.25)
		local csn=cos(o.parent.r+0.25)
		while (of<=halfw) do
			of+=0.01
			local ssx=csn*of
			local ssy=sn*of
			line(sx+ssx,sy+ssy,o.p.x+ssx,o.p.y+ssy,o.c1)
		end
		--local ssx=csn*(-halfw)
		--local ssy=sn*(-halfw)
		--line(sx+ssx,sy+ssy,o.p.x+ssx,o.p.y+ssy,o.c2)
		--local ssx=csn*(halfw)
		--local ssy=sn*(halfw)
		--line(sx+ssx,sy+ssy,o.p.x+ssx,o.p.y+ssy,o.c2)
	end
	return o
end

-- game!
function nlimb()
	local o=ntran()
	o.l1=nline(6,15,4)
	o.l2=nline(6,15,4)
	o.add(o.l1)
	o.l1.add(o.l2)
	o.destl1lp=npoint(0,0)
	o.destl2lp=npoint(0,0)
	o.rotateto=function(x,y)
		local ran=noise(time()*2)*20
		o.destl1lp.x=x/2
		o.destl1lp.y=y/2+ran
		o.destl2lp.x=x-o.l1.lp.x
		o.destl2lp.y=y-o.l1.lp.y
	end
	o.up=function()
		o.l1.lp.x+=plr_limb_smoothx*(o.destl1lp.x-o.l1.lp.x)
		o.l1.lp.y+=plr_limb_smoothx*(o.destl1lp.y-o.l1.lp.y)
		o.l2.lp.x+=plr_limb_smoothx*(o.destl2lp.x-o.l2.lp.x)
		o.l2.lp.y+=plr_limb_smoothy*(o.destl2lp.y-o.l2.lp.y)
	end
	return o
end

function nplayer()
	local p=ntran()
	p.hurted=false
	p.hp=plr_max_hp
	p.hasgun=false
	p.lgthleft=base_plr_hand_x
	p.cutperdmg=p.lgthleft/p.hp
	p.facet=0
	p.badfacestime=time()-2
	p.bumpstime=time()-2
	p.bumpdurin=1
	p.bumpdurout=1
	p.bumpdist=20
	p.dmgbumpstime=time()-2

	p.spawn=function()
		p.lp=npoint(-30,0)
		p.container=ntran()
		p.add(p.container)

		p.bodydown=nsprite(2,1,2,-8,0,4)
		p.bodydown.lp=npoint(-24,-12)
		p.container.add(p.bodydown)

		p.head=nsprite(4,1,1,-8,-8,4)
		p.head.lp=npoint(-20,-24)
		p.container.add(p.head)

		p.armcontainer=ntran()
		p.armcontainer.lp=npoint(-12,-4)
		p.container.add(p.armcontainer)

		p.arm=nlimb()
		p.armcontainer.add(p.arm)

		p.calc_handsp()
		p.hand.lp.x=plr_hand_x
		--p.hand.add(ncircle(knife_length,0,2,1))
		p.armcontainer.add(p.hand)
	end

	p.movement=8
	p.up=function()
		if (p.dead) then
			p.up_dead()
			return
		end
		local f=time()%2
		if (f<1) then
			p.lp.x=-22-p.movement*(time()-(flr(time())))
		else
			p.lp.x=-22+p.movement*(time()-1-(flr(time())))
		end

		if (time()>p.badfacestime+0.5) then
			p.mface(0)
		end

		p.hand.lp.y=p.arm.l2.p.y-p.arm.p.y

		if (time()<p.bumpstime+p.bumpdurin+0.1) then
			local f=min(1,(time()-p.bumpstime)/p.bumpdurin)
			p.hand.lp.x=plr_hand_x+p.bumpdist*f
		elseif (time()<p.bumpstime+p.bumpdurin+p.bumpdurout) then
			local f=(time()-p.bumpstime-p.bumpdurin)/p.bumpdurout
			p.hand.lp.x=plr_hand_x+p.bumpdist*(1-f)
		else
			p.hand.lp.x=(p.hand.lp.x+plr_hand_x)/2.0
		end
		if (p.hasgun) then
			p.hand.lp.x-=8
		end

		if (time()<p.dmgbumpstime+plr_bump_d) then
			local f=(time()-p.dmgbumpstime)/plr_bump_d
			if (f<0.25) then
				f*=4
				p.container.lp.x=-plr_bump_p*f
			else
				f=(f-0.25)*1.33333
				p.container.lp.x=-plr_bump_p*(1-f)
			end
		end
	end

	p.att=function()
		if (not p.hasgun) then
			p.bumpstime=time()
			p.bumpdurin=0.1
			p.bumpdurout=0.4
			p.bumpdist=25
		else
			cam.shake(4,0.1)
			sfx(57,-1)
			p.bumpstime=time()
			p.bumpdurin=0.05
			p.bumpdurout=0.1
			p.bumpdist=-5
			screenflash(7)
			if (enemy==null or enemy.dead) then
				p.successfull_attack(null)
			else
				p.successfull_attack(enemy)
			end
			p.ammo-=1
			if (p.ammo==0) then
				p.hasgun=false
				p.calc_handsp()
			end
		end
	end
	p.def=function()
		p.bumpstime=time()
		p.bumpdurin=0.2
		p.bumpdurout=0.3
		p.bumpdist=-18
	end
	p.move_hand=function(y)
		p.arm.rotateto(p.hand.lp.x,y)
	end

	p.dr=function()
		rectfill(p.container.p.x-36,p.container.p.y+16,p.container.p.x-9,p.container.p.y+128,5)
	end

	p.mface=function(t)
		if (t==facet) then
			return
		end
		facet=t
		p.remove(p.head)
		local tempp=clone(p.head.lp)
		if (t==0) then 
			p.head=nsprite(4,1,1,-8,-8,4)
		elseif (t==1) then 
			p.head=nsprite(20,1,1,-8,-8,4)
			p.head.flashstime=time()
			p.bodydown.flashstime=time()
		else
			p.head=nsprite(36,1,1,-8,-8,4)
		end
		p.head.lp=tempp
		p.container.add(p.head)
	end

	p.successfull_attack=function(en)
		p.mface(2)
		p.badfacestime=time()
		if (en!=null) then
			en.headtopsp.flashstime=time()
			en.headbottomsp.flashstime=time()
			en.bodydown.flashstime=time()
			en.bodydown2.flashstime=time()
			en.tookdmg(p.cutperdmg)
		end
	end

	p.check_dmg=function(en)
		if (time()<dmg_cooldown_till) then
			--cooldown
			return
		end
		local xmin=en.headtop.p.x
		local ymin=en.headtop.p.y-en_dmg_y_offset
		local ymax=en.headbottom.p.y+en_dmg_y_offset
		local px=p.hand.p.x+knife_length
		local py=p.hand.p.y+3
		if (px>xmin) then
			-- player hit enemy
			if ((py<ymin and py>ymin-en_collider_h)
				or (py>ymax)) then

				sfx(62,-1)
				slowmo_endt=time()
				if (time()>p.bumpstime+p.bumpdurin+p.bumpdurout) then
					--after attack is done - no need to check
					return
				end
				p.successfull_attack(en)
				dmg_cooldown_till=time()+dmg_cooldown
			-- enemy hit player
			elseif (py>ymin and py<ymax) then
				screenflash(8)
				sfx(60,-1)
				en.clap()
				p.hp=max(0,p.hp-1)
				if (p.hp<plr_max_hp) then
					p.lgthleft-=p.cutperdmg
					plr_hand_x=max(0,p.lgthleft)
				end
				p.hurted=true

				local heart=hearts[#hearts]
				hearts.remove(heart)
				root.remove(heart)
				
				p.dmgbumpstime=time()
				p.mface(1)
				if (p.hp==0) then
					p.die()
				else
					p.badfacestime=time()
					if (blood==null) then
						--blood!
						p.calc_handsp()
						local conf={}
						conf["pmin"]=0.5
						conf["pmax"]=1.0
						conf["smin"]=1
						conf["smax"]=2
						conf["tmin"]=0.1
						conf["tmax"]=0.4
						blood=nbloodsystem(conf,p.hand,npoint(0,0))
						blood.lp.x=5
						blood.lp.y=0
						root.add(blood)
					end
					local f=(p.hp/plr_max_hp)
					blood.cnf.rate=10+f*20
					blood.cnf.rmin=-0.1-f*0.1
					blood.cnf.rmax=0.1+f*0.1
					dmg_cooldown_till=time()+dmg_cooldown
					p.bumpstime=time()-10
				end
			end
		end
	end

	p.calc_handsp=function()
		p.armcontainer.remove(p.hand)
		if (p.hasgun) then
			p.armcontainer.remove(p.hand)
			p.hand=nsprite(32,2,1,0,-8,2)
			p.armcontainer.add(p.hand)
		elseif (p.hurted) then
			p.armcontainer.remove(p.hand)
			p.hand=nsprite(16,2,1,0,-8,2)
			p.armcontainer.add(p.hand)
		else
			p.hand=nsprite(0,2,1,0,-8,2)
			p.armcontainer.add(p.hand)
		end
		if (blood != null) then
			blood.target=p.hand
		end
		--p.hand.add(ncircle(knife_length,0,2,1))
	end

	p.dead=false
	p.deadstime=time()-2
	p.deady=0
	p.die=function()
		music(-1)
		sfx(61,-1)
		p.dead=true
		p.deadstime=time()
		p.deady=p.lp.y
		cam.shake(2,dead_duration)
	end
	p.up_dead=function()
		local f=(time()-p.deadstime)/dead_duration
		p.lp.y=lerp(f,p.deady,140)
		if (f>=1) then
			root.removeall()
			game_state=3
		end
	end

	p.ammo=0
	p.equip_gun=function()
		p.ammo=ammo_max
		p.hasgun=true
		p.calc_handsp()
		sfx(56,-1)
		if (blood != null) then
			for bl in all(blood.parts) do
				bl.parent.remove(bl)
				blood.parts.remove(bl)
			end
			root.remove(blood)
			blood=null
		end
	end
	return p
end

function ncircle(x,y,r,c)
	local o=ntran()
	o.lp.x=x; o.lp.y=y
	o.rad=r
	o.c=c
	o.dr=function()
		circfill(o.p.x,o.p.y,o.rad*o.s,o.c)
		circ(o.p.x,o.p.y,o.rad*o.s,7)
	end
	return o
end

function nenemy()
	e=ntran()
	e.blood=null
	e.lp=npoint(plr_hand_x+en_distance,0)
	e.bodyc=0
	e.basey=e.lp.y
	e.hp=en_hp
	e.dmgbumpstime=time()-2
	e.sid=-1
	e.name=""
	e.last_clap_time=time()-1
	e.spawn=function(conf)
		dmg_cooldown_till=time()+0.5

		e.name=conf[2]
		e.sid=conf[1]
		local cx=(e.sid*8)%128
		local cy=(flr(e.sid/16))*8
		e.bodyc=sget(cx+7,cy+7)
		e.comein_container=ntran()
		e.comein_container.lp=npoint(64,0)
		e.add(e.comein_container)

		e.container=ntran()
		e.comein_container.add(e.container)

		e.bodydown=nsprite(e.sid+32,1,1,0,5,enemy_scale)
		if(e.sid==202) then 	e.bodydown.glitch=true end
		e.bodydown.lp=npoint(0,0)
		e.container.add(e.bodydown)
		e.bodydown2=nsprite(e.sid+27,1,1,0,5,enemy_scale)
		if(e.sid==202) then 	e.bodydown2.glitch=true end
		e.bodydown2.lp=npoint(0,8*enemy_scale)
		e.container.add(e.bodydown2)

		e.headtop=ntran()
		e.container.add(e.headtop)
		e.headtopsp=nsprite(e.sid,1,1,0,-16,enemy_scale)
		if(e.sid==202) then 	e.headtopsp.glitch=true end
		e.headtop.add(e.headtopsp)

		e.headbottom=ntran()
		e.container.add(e.headbottom)
		e.headbottomsp=nsprite(e.sid+16,1,1,0,0,enemy_scale)
		if(e.sid==202) then 	e.headbottomsp.glitch=true end
		e.headbottom.add(e.headbottomsp)
		--e.headbottom.add(ncircle(0,0,3,1))
		--e.headtop.add(ncircle(0,0,3,1))

	end
	e.up=function()
		if (e.dead) then
			e.up_dead()
			return
		end
		if (player.dead) then
			return
		end

		if (e.comein_container.lp.x > 0) then
			e.comein_container.lp.x*=0.9
		end

		if (time()>e.last_clap_time+0.1) then
			e.headtop.lp.y=lerp(timescale*0.05,e.headtop.lp.y,-en_clap_hgt)
			e.headbottom.lp.y=lerp(timescale*0.05,e.headbottom.lp.y,en_clap_hgt)
			if ((time()-e.last_clap_time)>en_autoclap_tim) then
				e.claphalf()
			end
		end
		
		--follow player in y
		local desty=player.hand.p.y-root.lp.y
		if (e.basey!=desty) then
			local v=noise(time()*en_mov_y_smooth_change_sp)
			e.basey+=timescale*(desty-e.basey)*(lerp(v,0.5*en_mov_y_smooth,en_mov_y_smooth))
		end

		--dest perlinized x
		local per1=noise(time()*timescale)
		local elpy=e.basey--+per2*en_mov_y
		local per2=noise(time()*timescale+100)
		local elpx=plr_hand_x+en_distance-abs(per2)*en_mov_x

		--damage bump
		if (time()<e.dmgbumpstime+en_bump_d) then
			local f=(time()-e.dmgbumpstime)/en_bump_d
			if (f<0.25) then
				f*=4
				e.container.lp.x=en_bump_p*f
			else
				f=(f-0.25)*1.33333
				e.container.lp.x=en_bump_p*(1-f)
			end
			e.lp.x=lerp(f,plr_hand_x+en_distance,elpx)
			e.lp.y=lerp(f,e.basey,elpy)
		else
			e.container.lp.x=0
			e.lp.x=elpx
			e.lp.y=elpy
		end
	end
	e.dr=function()
		--rectfill(e.container.p.x+14,e.container.p.y-12,e.container.p.x+128,e.container.p.y+64,e.bodyc)
	end
	e.tookdmg=function(dmg_length)
		screenflash(7)
		e.dmgbumpstime=time()
		e.hp-=1
		try_slowmo();
		if (e.hp<=0) then
			e.die()
		else
			cam.shake(3,0.1)
		end

		if (e.blood==null) then
			--blood!
			local conf={}
			conf["pmin"]=0.5
			conf["pmax"]=1.0
			conf["smin"]=1
			conf["smax"]=2.2
			conf["tmin"]=0.2
			conf["tmax"]=1.5
			e.blood=nbloodsystem(conf,e,npoint(24,player.hand.p.y-64))
			e.blood.lp.x=5
			e.blood.lp.y=0
			e.blood.lr=0.5
			root.add(e.blood)
		end
		local f=(e.hp/en_hp)
		e.blood.cnf.rate=10+f*20
		e.blood.cnf.rmin=-0.1-f*0.1
		e.blood.cnf.rmax=0.1+f*0.1
	end
	e.clap=function()
		e.headtop.lp.y=0
		e.headbottom.lp.y=0
		e.last_clap_time=time()
	end
	e.claphalf=function()
		e.headtop.lp.y=-1
		e.headbottom.lp.y=1
		e.last_clap_time=time()
	end
	e.dead=false
	e.deadstime=time()-2
	e.deady=0
	e.die=function()
		if (e.dead) then
			return
		end

		sfx(63)
		slowmo_endt=time()

		if (wins>1 and wins%2==0) then
			player.hp+=1
			player.lgthleft=min(player.lgthleft+player.cutperdmg,base_plr_hand_x)
			plr_hand_x=max(0,player.lgthleft)
			if (blood != null) then
				for bl in all(blood.parts) do
					root.remove(bl)
				end
				root.remove(blood)
				blood=null
			end
			root.add(nheart(e.lp.x,e.lp.y,player.hp-1))
		end

		if (wins>2 and gun_flying==null and (not player.hasgun) and rnd(1)<gun_spawn_prob) then
			gun_flying=ngun(e.lp.x,e.lp.y)
			root.add(gun_flying)
		end

		e.dead=true
		e.deadstime=time()
		e.deady=e.lp.y
		cam.shake(2,dead_duration)
		wins+=1
		
		e.headtop.remove(e.headtopsp)
		e.headtopsp=nsprite(e.sid+48,1,1,0,-16,enemy_scale)
		if(e.sid==202) then 	e.headtopspglitch=true end
		e.headtop.add(e.headtopsp)
	end
	e.up_dead=function()
		local f=(time()-e.deadstime)/dead_duration
		e.lp.y=lerp(f,e.deady,140)
		if (f >= 1) then
			if (e.blood != null) then
				for bl in all(e.blood.parts) do
					e.blood.parts.remove(bl)
					bl.parent.remove(bl)
				end
				root.remove(e.blood)
			end
			if (wins==20) then
				game_state=3
			else
				next_spawn()
			end
		end
	end
	return e
end

function try_slowmo()
	if (slowmo_en) then
		return
	end
	if (rnd(1)<slowmo_prob) then
		slowmo_en=true
		slowmo_endt=time()+slowmo_dur
		timescale=slowmo_pow
	end
end

function nheart(x,y,i)
	local h=nsprite(96,1,1,0,0,1)
	h.destp=npoint(55.5-9*i,-56)

	if (x==-1 and y==-1) then
		h.lp=clone(h.destp)
	else
		h.lp.x=x
		h.lp.y=y
	end
	h.stime=time()
	h.up=function()
		if (time()-h.stime<0.1) then
			return
		end
		h.lp.x=lerp(0.1,h.lp.x,h.destp.x)
		if (abs(h.lp.x-h.destp.x)<5) h.lp.x=h.destp.x
		h.lp.y=lerp(0.1,h.lp.y,h.destp.y)
		if (abs(h.lp.y-h.destp.y)<5) h.lp.y=h.destp.y
	end
	hearts.add(h)
	return h
end

function ngun(x,y)
	local h=nsprite(97,1,1,0,0,1)
	h.lp.x=x
	h.lp.y=y
	h.stime=time()
	h.up=function()
		if (time()-h.stime<0.1) then
			return
		end
		h.destp=player.hand.lp
		h.lp.x=lerp(0.2,h.lp.x,h.destp.x)
		local xok=false
		local yok=false
		if (abs(h.lp.x-h.destp.x)<5) then
			h.lp.x=h.destp.x
			xok=true
		end
		h.lp.y=lerp(0.2,h.lp.y,h.destp.y)
		if (abs(h.lp.y-h.destp.y)<5) then
			h.lp.y=h.destp.y
			yok=true
		end
		if (xok and yok) then
			root.remove(h)
			gun_flying=null
			player.equip_gun()
		end
	end
	return h
end

last_game_state=-1
game_state=-1

--

function _init()
	game_state=0
	restart()
	root.add(cam)
end

function _update()
	updatestate()
end

function updatestate()
	if (last_game_state!=game_state) then
		startcurstate();
		last_game_state=game_state
	end
	if (game_state==0) then
		update_title()
	elseif (game_state==1) then
		update_intro()
	elseif (game_state==2) then
		update_gameplay()
	elseif (game_state==3) then
		update_gameover()
	end
end

function startcurstate()
	if (game_state==0) then
		start_title()
	elseif (game_state==1) then
		start_intro()
	elseif (game_state==2) then
		start_gameplay()
	elseif (game_state==3) then
		start_gameover()
	end
end

function start_title()
	title_t=time()
end

function update_title()
	if ( (time()-title_t)*2 > title_pr ) then
		title_pr+=1
		if(title_pr==title_prs[6]+1) then
			music(53,0)
		end
		for pr in all(title_prs) do
			if (pr+1==title_pr) then
				sfx(57,-1)
				break
			end
		end
	end
	if (title_pr<=title_prs[6]) then
		if (btn()>0) then
			title_pr=16
			title_x=128
			music(53,0)
		end
	else
		if (not tutorial_show_credits) then
			if (btnp(4)) then
				game_state=1
				music(-1)
			end
		end
		
  		if ((tutorial_show_credits and btnp()>0) or btnp(5)) then
			tutorial_show_credits=not tutorial_show_credits
		end
	end
end

function draw_title()
	title_x+=(min(10,time()-title_t))
	if (title_x>=144) then
		title_x=0
	end
	cls()
	map(0,16,-title_x,0,18,18)
	map(0,16,-title_x+144,0,18,18)
	pal()

	if (not tutorial_show_credits) then

		if (title_pr>title_prs[1]) d_ui_text_c("there",64,16,7)
		if (title_pr>title_prs[2]) d_ui_text_c("is",64,24,7)
		if (title_pr>title_prs[3]) d_ui_text_c("no",64,32,0)
		if (title_pr>title_prs[4]) d_ui_text_c("option",64,40,0)
		if (title_pr>title_prs[5]) d_ui_text_c("but",64,48,0)
		if (title_pr>title_prs[6]) d_ui_text_c("violence",64,56,0)
 
		if (title_pr>12) then
			d_ui_button_c(64,86,"a - play")
			d_ui_button_c(64,100,"b - credits")
		end
	else
		d_ui_text_c("sfx: aceman",64,28)
		d_ui_text_c("music: gruber",64,40)
		d_ui_text_c("(http://add.ph/1en)",64,46)
		d_ui_text_c("the rest:",64,68)
		d_ui_text_c("konrad 'sabikku' slabig",64,74)
		d_ui_text_c("konrad.najlepszy@gmail.com",64,80)
	end
end

function start_intro()
	intro_t=time()
end

function update_intro()
	if ( (time()-intro_t)*2 > intro_pr ) then
		intro_pr+=1
		if (intro_pr==8) then
			sfx(58,-1)
		elseif (intro_pr==17) then
			sfx(59,-1)
		end
	end
	if (btnp(4) or btnp(5)) then
		game_state=2
	end
end

function draw_intro()
	cls()
	if (intro_pr>1 and intro_pr<=5) d_ui_text_c("\"i don't like animals\"",64,56,7)
	if (intro_pr>5 and intro_pr<=7) d_ui_text_c("\"very much.\"",64,56,7)
	if (intro_pr>7 and intro_pr<=11) map(28,0,0,16,16,16)
	if (intro_pr>11 and intro_pr<=16) d_ui_text_c("\"one time a cat bite me\"",64,56,7)
	if (intro_pr>16 and intro_pr<=21) map(18,0,9,0,11,16)
	if (intro_pr>21 and intro_pr<=27) then
		d_ui_text_c("\"so i went to zoo",64,52,7)
		d_ui_text_c("to make things even.\"",64,60,7)
	end
	if (intro_pr>29) then
		game_state=2
	end
end

function start_gameplay()
	player=nplayer()
	player.spawn()
	root.add(player)
	for i=1,plr_max_hp do
		root.add(nheart(-1,-1,i-1))
	end
	controller=player.hand
	music(7)

	enemies_conf_cur=nlist()
	for group in all(enemies_conf) do
		local li =nlist()
		enemies_conf_cur.add(li)
		for entry in all(group) do
			li.add(entry)
		end
		li.sortby(function(a,b)
			return rnd(10)<5
		end)
	end
end

function start_gameover()
end

function next_spawn()
	en_autoclap_tim=1-wins*0.03
	en_bump_p=32
	en_bump_d=0.25
	en_clap_hgt=5+wins*0.2
	if (wins==0) then
		en_mov_x=22
	else
		en_mov_x=22+32*(min(1,(wins-1)/20))
	end
	en_mov_y=40+min(18,(wins-1))
	if (wins==0) then
		en_mov_y_smooth=0.1
	else
		en_mov_y_smooth=0.125+(0.4*(wins-1)/20)
	end
	if (wins==0) then
		en_mov_y_smooth_change_sp=0.5
	else
		en_mov_y_smooth_change_sp=1+(wins-1)/5
	end
	en_collider_h=32
	en_distance=-4
	en_dmg_y_offset=8
	en_hp=flr(1+flr(wins*0.7))

	root.remove(enemy)
	enemy=null
	enemy=nenemy()

	enemy.spawn(enemies_conf_cur[1][1])
	enemies_conf_cur[1].remove(enemies_conf_cur[1][1])
	if (#enemies_conf_cur[1]==0) then
		enemies_conf_cur.remove(enemies_conf_cur[1])
	end
	root.add(enemy)
end

function update_gameplay()
	if (slowmo_en) then
		if (time()>slowmo_endt) then
			slowmo_en=false
			timescale=1
		end
	end
	if (btnp(0,1)) then
		enemy.die()
	end
	if (btnp(0)) then
		player.def()
	end
	if (btnp(1)) then
		player.att()
	end
	if (btn(2)) then
		hand_y-=plr_limb_sp
	end
	if (btn(3)) then
		hand_y+=plr_limb_sp
	end
	local hpfctr=min(1,3*player.hp/plr_max_hp)
	hand_y=clamp(hand_y,hpfctr*plr_limb_miny,hpfctr*plr_limb_maxy)
	player.move_hand(hand_y)
	if (enemy!=null and not player.dead) then
		player.check_dmg(enemy)
	end
	root.up_childs()
end

function update_gameover()
	if (btnp(4)) then
		restart()
		game_state=0
	end
end

function screenflash(c)
	gameplay_screenflash_c=c
	gameplay_screenflash_endt=time()+0.1
end

tutorial_done_ever=false
function draw_gameplay()
	--bg
	scroll_bg_x+=wins/10.0
	if ( scroll_bg_y > max(0,16-flr(wins/4)*4) ) then
		scroll_bg_y-=0.1
	end
	cls()
	if (time()<gameplay_screenflash_endt) then
		for i=0,15 do
			pal(i,gameplay_screenflash_c)
		end
	elseif (slowmo_en) then
		for i=0,15 do
			pal(i,0)
		end
	end
	if (scroll_bg_x>=144) then
		scroll_bg_x=0
	end

	map(0,scroll_bg_y,-scroll_bg_x,0,18,18)
	map(0,scroll_bg_y,-scroll_bg_x+144,0,18,18)
	pal()
	
	--bars back
	rectfill(barsx-3,101,barsx-3,128,5)
	rectfill(barsx+1,102,barsx+1,128,5)
	rectfill(barsx+6,103,barsx+7,128,5)
	line(barsx-5,104,barsx+29,108,5)
	line(barsx-5,105,barsx+29,109,5)
	root.dr_childs()
	line(barsx-1,105,barsx+29,108,5)
	line(barsx-1,106,barsx+29,109,5)
	rectfill(barsx+12,104,barsx+13,128,5)
	rectfill(barsx+18,105,barsx+19,128,5)
	rectfill(barsx+24,106,barsx+27,128,5)
	--rectfill(barsx+32,0,barsx+34,128,0)
	--print(player.lr.." "..player.arm.lr, 10+x, 10)
	--print(time().." "..player.bumpstime.." "..player.bumpdurin.." "..player.bumpdurout)
	--print("wins: "..wins,1,1,0)
	if (not tutorial_done) then
		local allpressed=true
		for i=1,4 do
			local text="";local ssid=0;local btnid=0;
			if (i==1) then
				ssid=66;text="swing up";btnid=2
			elseif (i==2) then
				ssid=67;text="swing down";btnid=3
			elseif (i==3) then
				ssid=65;text="attack";btnid=1
			else
				ssid=64;text="dodge";btnid=0
			end
			local recolor=false
			if ((btnid<2 and btnp(btnid)) or (btnid>=2 and btn(btnid))) then
				tutorial[i]=true
				recolor=true
			end
			if (recolor) then
				pal(6,5)
			else
				pal()
			end
			spr(ssid,78,40+i*9)
			d_ui_text(text,88,41+i*9)
			if (not tutorial[i]) then
 				allpressed=false
			end
		end
		if ((allpressed or tutorial_done_ever) and tutorial_endtime==32767) then
			tutorial_endtime=time()+2
		end
		if (time()>tutorial_endtime) then
			tutorial_done=true
			tutorial_done_ever=true
			next_spawn()
		end
	end
	if (tutorial_done) then
		if (slowmo_en) then
			d_ui_text_v("slowmo",64,-36+164*(slowmo_endt-time())/slowmo_dur)
		elseif (wins<2) then
			d_ui_text_c("watch out for bites!",64,16)
		end
		if (player.hasgun) then
			local tx="ammo: "..player.ammo.." / "..ammo_max
			d_ui_text(tx,124-(#tx)*4,104)
		end
		if (enemy!=null) then
			local txt=enemy.name
			d_ui_text(txt,124-(#txt)*4,112)
		end
		txt="killed: "..wins.." / "..20
		d_ui_text(txt,124-(#txt)*4,120)
		
	end
end

function draw_gameover()
	cls()
	d_ui_text_c("you killed:",64,50)
	d_ui_text_c(""..wins,64,58)
	d_ui_text_c("animals.",64,64)
	if (wins==0) then d_ui_text_c("lame as fuck",64,80)
	elseif (wins<5) then d_ui_text_c("quite lame",64,80)
	elseif (wins<10) then d_ui_text_c("average",64,80)
	elseif (wins<15) then d_ui_text_c("cool",64,80)
	elseif (wins<17) then d_ui_text_c("very cool",64,80)
	elseif (wins<19) then d_ui_text_c("close to reward!",64,80)
	else d_ui_text_c("reward: http://add.ph/1em",64,80) end
end

function _draw()
	if (game_state==0) then
		draw_title()
	elseif (game_state==1) then
		draw_intro()
	elseif (game_state==2) then
		draw_gameplay()
	elseif (game_state==3) then
		draw_gameover()
	end
end

function d_ui_text(text,x,y)
	rectfill(x-1,y-1,x+(#text*4),y+5,0)
	print(text,x,y,7)
end
function d_ui_text_c(text,x,y)
	local hw=#text*4*0.5
	rectfill(x-hw-1,y,x+hw+1,y+5,0)
	print(text,x-hw,y,7)
end
function d_ui_text_v(text,x,y)
	rectfill(x-1,y+6,x+3,y+(#text*6)+6,0)
	for i=1,y do
		if (y > 0) print(sub(text,i-1,i-1),x,y+(i-1)*6,7)
		i+=1
	end
end
function d_ui_button(x,y,text)
	rectfill(x,y-3,x+(#text*3+24),y+12,15)
	print(text,x+8,y+2,0)
end
function d_ui_button_c(x,y,text)
	local hw=#text*4*0.5
	rectfill(x-hw-4,y-4,x+hw+3,y+8,6)
	rect(x-hw-4,y-4,x+hw+3,y+8,0)
	print(text,x-hw,y,0)
end

function restart()
	scroll_bg_y=16
	root=ntran()
	root.lp.x=64; root.lp.y=64

	flashdur=0.2

	gun_flying=null
	gun_spawn_prob=0.15
	gun_equipped=null

	slowmo_en=false
	slowmo_endt=time()
	slowmo_prob=0.2
	slowmo_dur=2
	slowmo_pow=0.1
	timescale=1

	hearts=nlist()

	plr_limb_sp=10
	plr_limb_smoothx=0.5
	plr_limb_smoothy=0.1
	base_plr_hand_x=25
	plr_hand_x=25
	plr_max_hp=4
	plr_limb_maxy=48
	plr_limb_miny=-48
	plr_bump_p=32
	plr_bump_d=0.25

	ammo_max=6

	enemy_scale=4
	en_bump_p=32
	en_bump_d=0.25
	en_clap_hgt=5
	en_mov_x=50
	en_mov_y=48
	en_mov_y_smooth=0.125
	en_mov_y_smooth_change_sp=1
	en_collider_h=32
	en_distance=-4
	en_dmg_y_offset=8
	en_hp=1
	knife_length=22

	dmg_cooldown=1
	dead_duration=1

	barsx=32
	--

	controller = null
	player = null
	enemy=null
	cam = ncamera()
	dmg_cooldown_till=time()+0.5
	--

	hand_y=0

	title_prs={
		1,2,3,5,6,9
	}
	tutorial_show_credits=false

	title_t=0
	title_x=-450
	title_pr=0

	intro_t=0
	intro_pr=0

	last_enemy_id=10
	enemies_conf_cur={}
	enemies_conf={
		{
			{10,"monkey"},{11,"rhino"},{12,"panda"},{13,"giraffe"},{14,"dolphin"}
		},
		{
			{74,"octopus"},{75,"tigled"},{76,"some flower"},{77,"not jesus"},{78,"bananana"}
		},
		{
			{138,"yourself"},{139,"a fetus"},{140,""},{141,"leg that stepped into shit"},{142,"dog"}
		},
		{
			{202,"noise"},{203,"diseases"},{204,"death"},{205,"unconditional love"},{206,"taxes"}
		}
	}
	wins=0

	tutorial={}
	tutorial[0]=false;tutorial[1]=false;tutorial[2]=false;tutorial[3]=false;
	tutorial_endtime=32767
	tutorial_done=false
	scroll_bg_st=32767
	scroll_bg_x=0

	gameplay_screenflash_endt=time()-1
	gameplay_screenflash_c=0
	if (hearts!=null) then
		hearts=nlist()
	end

end
__gfx__
00000000000000000111111100000000099999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff00000000001111111f00000000999f9f900000000000000000000000000000000000000000000ff0ff0000000000000000000000000000000000000000
fff55f56666600001111111f0000000099fffff00000000000000000000000000000000000000000000444ff0000000600050550000090940000000000000000
ff555556600000001ff11111000000009ffedfed000000000000000000000000000000000000000000f4ff446000066600057555000099440000666600000000
ffff5f00000000001ff11111000000009fffffff0000000000000000000000000000000000000000008f8f446060886600777757000999940006666000000000
00ffff00000000001ff1111100000000ffff88ff00000000000000000000000000000000000000000ffff4446666666607857777009979940066c66600000000
00000000000000001ff1111100000000ffff8fff0000000000000000000000000000000000000000ffffff446666666677777777999999a96666666600000000
00000000000000001ff11111000000000fffffff0000000000000000000000000000000000000000f7f7ff446676767657777777997999aa6767666600000000
00000000000000001ff11111000000000999999000000000000000000000000000000000000000007f7f7f446767676675577777000799aa7777666600000000
ff800000070000001ff1111100000000999f9f9000000000000000000000000000000000000000000ffff4440666666600777770000000000077777700000000
fff88777777000001ff111110000000099fdfdf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8f888000000000001fff1111000000009ffefeff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88f80000000000001fff1111000000009fffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80800000000000001fff111500000000fff888ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001111111100000000ff8888ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000011111111000000000ffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000555666665655999999990000000009999990fff4444400555555777777550000099900077666000444440005555500055555000009a90007666600000000
ffff5555555555509999999900000000999f9f90fff444440055555577777775000009a900077666004444440055555500555555000009aa0007766600000000
fff55ff000000000999999990000000099fdfdf0fff444440055555577777775000009aa00077666004444440055556600757755000099aa0007776600000000
fff555000000000099999999000000009fffffffff4444440055555577777775000009a9000076600f444ff40056666607775555000099990007766600000000
fff55f000000000099999999000000009ff888ff0f44444400055555077777550000099900000760ff444ff40056666577555555000099990007767600000000
00ffff00000000009999999900000000fff888ff0044444400065565007755550000099900000760fff44ff40055555577555577000009990007767700000000
00000000000000009999999900000000ffff8fff0044ff440006656600005500000009aa00006660fff44ff4000555557777777500000aa90007766600000000
000000000000000099999999000000000fffffff000ffff40006606600005500000009aa00076666fff44f44000555557777775500000aa90007766600000000
ccccccccccccccccccccccccbbbbbbbbbbbbbbbbcccccccc33333333ffffffffffffffff00f4ff00000000000000000000000000000000000000000000000000
ccccccccccccc777ccccccccbbbbbbbbb3bbbb3bcbccccbc33333333fffffffffff888ff0f4444f0000ff0ff0000000000000000000000000000000000000000
cccccccccc77777777ccccccbbbbbbbbb33b3b3bcbbcbcbc33333333ffffffffff8888fff44444ff000444f80000000600050550000090900000000000000000
cccccccc777777777777ccccbbbbbbbb333b333bbbbcbbbc33333333fffffffff888888f4444444f00f4ff486000066600057585000089800000666600000000
cccccccc777777777777ccccbbbbbbbb33333333bbbbbbbb33333333fffffffff888888ff444444f008fcf488060886600777787000999840666666000000000
ccccccccccccccccccccccccbbbbbbbb33333333bbbbbbbb33333333ffffffffff88888fff4444ff0f8f884886866866078c77870009c9846666866600000000
ccccccccccccccccccccccccbbbbbbbb33333333bbbbbbbb33333333ffffffffff888fffffffffffffff88448666666657cc7787099989890666c66600000000
ccccccccccccccccccccccccbbbbbbbb33333333bbbbbbbb33333333fffffffffffffffffffffffff8f8f8446678787600c77777899989aa0000c66600000000
0666666006666660066666600666666000000000000000000000000000000000000000000000000000000000000000000000000000aaaaa00aa0000000000000
66667666666766666666666666666666000000000000000000000000000000000000000000000000000088880000000000077000000000000aaa000000000000
666776666667766666677666677777760000000000000000000000000000000000000000000000000008888800044400000770300055555000aa000000000000
6677766666677766667777666677776600000000000000000000000000000000000000000000000000888888004444400337733300fffff500aaa00000000000
666776666667766667777776666776660000000000000000000000000000000000000000000000000888888804545444033aa3330fcfcff500aaaa0000000000
666676666667666666666666666666660000000000000000000000000000000000000000000000000c88c88804545444778a8a770fffff5500caca0000000000
5666666556666665566666655666666500000000000000000000000000000000000000000000000088888888044444447a8a8aa70f55ff5500aaaa0000000000
055555500555555005555550055555500000000000000000000000000000000000000000000000008787878804ee44440aaaaaa705ff55550077aa0000000000
06666660066666600000000000000000000000000000000000000000000000000000000000000000727272780444444433aaaa30055555500077aa0000000000
666776666677766600000000000000000000000000000000000000000000000000000000000000002222228804444444033777030555550000aaaa0000000000
6676676666766766000000000000000000000000000000000000000000000000000000000000000008888888044444440007730005555500000aaa0000000000
66777766667776660000000000000000000000000000000000000000000000000000000000000000008888800444444400000300055550000000000000000000
66766766667667660000000000000000000000000000000000000000000000000000000000000000000000000000000000000300005550000000000000000000
66766766667776660000000000000000000000000000000000000000000000000000000000000000000000000000000000000300005500000000000000000000
56666665566666650000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000
05555550055555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000
0ee00ee000000000000000000000000000000000ee02e0e8044444440000030304444ff400aaaa0000022288044444440000030004ffff4400aaaa0000000000
eee88e8800000000000000000000000000000000e202e0ee044444440000033304444ff400aaaa0000222288044444440000030004ffff4400aaaa0000000000
ee88888805666565000000000000000000000000e002e02e04444444000003330444444400aaaa0000222228044444440033030004fff44400aaaa0000000000
e888888805555550000000000000000000000000e02ee02e04444444000003300444444400aaaa00022222280444444400333300044f444400aaaa0000000000
88888888555000000000000000000000000000000022e02e04444444000003000444444400aaaa00e222222804444444000333000444444500aaaa0000000000
08888880550000000000000000000000000000000002e0220444444500000300054444440aaaa000e202202804444444000033000444544500aaaa0000000000
008888000000000000000000000000000000000000002e2255455457000044440554455405aaa000e202e0e804444444000003000444544500aaaa0000000000
00088000000000000000000000000000000000000000220257577557000444440505500555500000ee02e0e804444444000003000444544500aaaa0000000000
2222222222222222888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000aaa0000000000000000000
222222222222222288888888828282820000000000000000000000000000000000000000000000000000888800000000000bb00000000aa000ff000000000000
222222222222222288888888282228220000000000000000000000000000000000000000000000000008888800044400000bb0300055555000fff00000000000
222222222222222288888888222822280000000000000000000000000000000000000000000000000088888800444440033b883300fffff5008f800000000000
22222222222c222c88888888222222220000000000000000000000000000000000000000000000000988988804c4c444033aa3830f8f8ff5a0cfc00000000000
222222222c222c2288888888222222220000000000000000000000000000000000000000000000009c88c98804848484bb8a8ab8088f8f850acfcaaa00000000
22222222c2c2c2c28888888822222222000000000000000000000000000000000000000000000000cccccc9804848484ba88aaa808558f850afffaa000000000
22222222cccccccc88888888222222220000000000000000000000000000000000000000000000008787878804ee844408a8a8a805ff858500aaaa0000000000
22222222555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000000000
22222222555555550000000000000000000000000000000000000000000000000000000000000000099999900000000000000000000000000000000000000000
2222222255555555000000000000000000000000000000000000000000000000000000000000000009f9f9990000000000000000005000000000000000000000
222222225555555500000000000000000000000000000000000000000000000000000000000000000fffff9900fff00000044400000000000000004000000000
22222222555555550000000000000000000000000000000000000000000000000000000000000000defdeff90ffffff000f44440000040000000004000000000
22222222555555550000000000000000000000000000000000000000000000000000000000000000fffffff90f5ffff000ff4444000544000000844000000000
22222222555555550000000000000000000000000000000000000000000000000000000000000000ffffffff0fc5fff00ffcf444004445400048c44000000000
22222222555555550000000000000000000000000000000000000000000000000000000000000000ff88ffff00fffff00ffff444004544400444444000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000ff88ffff000ffff000ff4440022222220044444000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffff00ffffff000044444008888880005555000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008fff000044444000007880005555000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008f8fff000004444000000ff0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008ffff0000004440000000ff0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008fff00000000444000000ff0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000044000000ff0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000ff0000000000000000
000000000000000000000000000000000000000011111ff100080000000fff00000000ff000444401111111000080000000ffff0000000ff0004444000000000
000000000000000000000000000000000000000011111ff100040000000fff00000000ff00044440f111111100040000000ffff0000000ff0004444000000000
000000000000000000000000000000000000000011111ff100080000000fff00000000ff00044440f11111110008000000fffff0000000ff0444444000000000
00000000000000000000000000000000000000001111fff1000800000004f400000008880004444011111ff1000800000ffffff000000fff0444444000000000
00000000000000000000000000000000000000001111fff1000800000004f40000000ccc0004444011111ff100080000fffffff000000fff0004444000000000
00000000000000000000000000000000000000005111fff1000800000004f400000008880444444011111ff100080000ffff4f40000000ff0004444000000000
00000000000000000000000000000000000000001111111100fff0000004f40000000ccc0444444011111ff100040000ffff4f40000000ff0004444000000000
0000000000000000000000000000000000000000111111110fffff0000044400000008880000004411111ff1000800000fff4400000000ff0004444000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000098999900000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000098888990000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000f88889900fff00000044400000000000000004000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888888f90ffffff000f44440000000000000008000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888f88890f5ffff000fcc444000080000000448000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000088fff88f0fc5fff00ff88444000848000044844000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000f888f8ff00fffff00f88844408844488044ccc4000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb0000000000077770000000000999999000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb0000000007777777000000000999999000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb0000000007777777000000000009900000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb0009990007070777008808800009900000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb008f999007777777088088800009900000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb0088ff9000777777088888880009900000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb08cffcf000777770088888880009900000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb008fffff00070700088888880009900000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000003333333300787fff00707070088888880009900000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000333333330000000000777770088888880009900000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000333333330000000000000500008888800000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000333333330000000000000500000888600000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000333333330000000000000500000006600000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000333333330000000000000500000000600000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000333333330000000000000500000000600000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000333333330000000000000500000000600000000000000000
0000000000000000000000000000000000000000333333330088fff0000005000000006000000000bbbbbbbb0008fff000000500000000600990099000000000
0000000000000000000000000000000000000000333333330008fff0000075000000006009900990bbbbbbbb0088ffff00007500000000600990099000000000
0000000000000000000000000000000000000000333333330088fff0000077000000006009900990bbbbbbbb0088ffff07777500000000600990099000000000
000000000000000000000000000000000000000033333333008ffff0000070700000006000999900bbbbbbbb088fffff00000570000000600999999000000000
0000000000000000000000000000000000000000333333330008fff0000070700000006000999900bbbbbbbb008fffff00000570000000600999999000000000
00000000000000000000000000000000000000003333333300008f00000770700000066000999900bbbbbbbb0088ffff00077770000000600990099000000000
00000000000000000000000000000000000000003333333300008f00000000700000606009900990bbbbbbbb0008ff0f00000500000000600990099000000000
00000000000000000000000000000000000000003333333300008fff000007700000606009900990bbbbbbbb0088fff000000500000000600000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888888880000000000077770000000000999999000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888888880000000007777777000000000999c9c000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000008888888800000000077777770000000000c9808000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888888880008880007c7c777000000000089808000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000008888888800889990078787770000000c0089800000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000008888888800888f90008787770000ccc80089800000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888888880888f8f0008787700ccc8ca80009800000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888888880088ffff0007070008ca88880009900000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3030303030303030303030303030303030300000000000000000000000000022222222222222222222000000000080808080808080808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030300000000039000039000000002222372237222237222222220000000080808181818181808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303132300000000037370037003900002237373737373737372237220000000080818080808080818180808080808081818100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030313230303030303030303030303030300000000037370037003700222237373722373722373737222200000081818080808080808081818180818181808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030300000000037373737373700223737372222373722223737373700000080808080808080808080808081818080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030300000393737373737373700373737223030373730302237373700000080808080808080808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030300000373737373737373700373722373737373737373722373700000080808080808080808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030313230303030303030303030300000003737373737383700373737373737373737373737373700000080818181818181818181808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030300000000037373737373700003737373730303037373737373700000081818080808080808081818080808080818100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030300000000000363636363600003637373730373730373737360000000080808080808080808080818181818181818000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303031323030300000000000363636363600363636363737373737373736363600000080808080808080808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030300000000000333333333300363636363636363636363636363600000080808080808080808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3031323030303030303030303030303030300000000000333333333300363636363636363636363636363600000080808080818181818080808080808080808100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030300000000000333333333300003636363636363636363636360000000081818181808080818181808080808080818100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303031323030303030303030300000000000333333333300000000000000000000000000000000000081818080808080808080818181818181818000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030300000000000333333333300000000000000000000000000000000000080808080808080808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303132303030303030303030303132300000000000000000000000000000000000000000000000000000000080808080808080808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030313230303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3530303030303030303030303030303035350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3335353030303030303535353535353533330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333535353535353333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333333333333333333333334340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333333333333333334343436360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3434333333333333343433343436363636360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3636343434343434363634363636363636360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3636363636363636363636363636363636360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3636363636363636363636363636363636360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7011b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70129515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0011d005
0112000003744030250a7040a005137441302508744080251b7110a704037440302524615080240a7440a02508744087250a7040c0241674416025167251652527515140240c7440c025220152e015220150a525
011200000c033247151f5152271524615227151b5051b5151f5201f5201f5221f510225212252022522225150c0331b7151b5151b715246151b5151b5051b515275202752027522275151f5211f5201f5221f515
011200000c0330802508744080250872508044187151b7151b7010f0251174411025246150f0240c7440c0250c0330802508744080250872508044247152b715275020f0251174411025246150f0240c7440c025
011200002452024520245122451524615187151b7151f71527520275202751227515246151f7151b7151f715295202b5212b5122b5152461524715277152e715275002e715275022e715246152b7152771524715
011200002352023520235122351524615177151b7151f715275202752027512275152461523715277152e7152b5202c5212c5202c5202c5202c5222c5222c5222b5202b5202b5222b515225151f5151b51516515
011200000c0330802508744080250872508044177151b7151b7010f0251174411025246150f0240b7440b0250c0330802508744080250872524715277152e715080242e715080242e715246150f0240c7440c025
011600000042500415094250a4250042500415094250a42500425094253f2050a42508425094250a425074250c4250a42503425004150c4250a42503425004150c42500415186150042502425024250342504425
011600000c0330c4130f54510545186150c0330f545105450c0330f5450c41310545115450f545105450c0230c0330c4131554516545186150c03315545165450c0330c5450f4130f4130e5450e5450f54510545
0116000005425054150e4250f42505425054150e4250f425054250e4253f2050f4250d4250e4250f4250c4250a4250a42513425144150a4250a42513425144150a42509415086150741007410074120441101411
011600000c0330c4131454515545186150c03314545155450c033145450c413155451654514545155450c0230c0330c413195451a545186150c033195451a5451a520195201852017522175220c033186150c033
010b00200c03324510245102451024512245122751127510186151841516215184150c0031841516215134150c033114151321516415182151b4151d215224151861524415222151e4151d2151c4151b21518415
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400002c7252c0152c7152a0252a7152a0152a7152f0152c7252c0152c7152801525725250152a7252a0152072520715207151e7251e7151e7151e715217152072520715207151e7251e7151e7151e7151e715
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020725200152071520015217252101521715210152c7252c0152c7152c0152a7252a0152a7152a015257252501525715250152672526015267153401532725310152d715280152672525015217151c015
010e000005145185111c725050250c12524515185150c04511045185151d515110250c0451d5151d0250c0450a0451a015190150a02505145190151a015050450c0451d0151c0150012502145187150414518715
010e000021745115152072521735186152072521735186052d7142b7142971426025240351151521035115151d0451c0051c0251d035186151c0251d035115151151530715247151871524716187160c70724717
010e000002145185111c72502125091452451518515090250e045185151d5150e025090451d5151d025090450a0451a015190150a02505045190151a015050450c0451d0151c0150012502145187150414518715
010e000029045000002802529035186152802529035000001a51515515115150e51518615000002603500000240450000023025240351861523025240350000015515185151c51521515186150c615280162d016
010e000002145185112072521025090452451518515090450e04521515265150e025090451d5151d01504045090451d01520015210250414520015210250404509045280152d0150702505145187150414518715
011a00000173401025117341102512734120250873408025127341202501734010251173411025087340802505734050250d7340d025147341402506734060250873408025127341202511734110250d7340d025
010d00200c0331b51119515195152071220712145151451518615317151d5151d515125050c03314515145150c0330150519515195150d517205161451514515186153171520515205150d5110c033145150c033
011a00000a7340a02511734110250d7340d02505734050250673406025147341402511734110250d7340d0250a7340a02511734110250d7340d02508734080250373403025127341202511734110250d7340d025
010d00200c0331b511295122951220712207122c5102c51018615315143151531514295150c03329515295150c0330150525515255150d517205162051520515186153171520515205150d5110c033145150c033
01180000021100211002110021120e1140e1100e1100e1120d1140d1100d1100d1120d1120940509110091120c1100c1100c1100c1120b1110b1100b1100b1120a1100a1100a1100a11209111091100911009112
01180000117201172011722117221d7201d7201d7221d7221c7211c7201c7201c7201c7221c72218720187221b7211b7201b7201b7201b7221b7221d7221d7221a7201a7201a7201a7201a7221a7221672016722
011800001972019720197221972218720187201872018720147201472015720157201f7211f7201d7201d7201c7201c7201c7221c7221a7201a7201a7221a7251a7201a7201a7221a72219721197201972219722
011800001a7201a7201a7221a7221c7201c7201c7221c7221e7201e7202172021720247212472023720237202272022720227202272022722227221f7201f7202272122720227202272221721217202172221722
0118000002114021100211002112091140911009110091120e1140e1100c1100c1120911209110081100811207110071100711007112061110611006110061120111101110011100111202111021100211002112
0118000020720207202072220722217202172021722217222b7212b72029720297202872128720267202672526720267202672026720267222672228721287202672026720267202672225721257202572225722
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
010700000c5370f0370c5270f0270f537120370f527120271e537230371e527230272f537260372f52726027165371903716527190271c537190371c527210271c53621036245262102624536330362452633026
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
018800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0164002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
011800001d5351f53516525275151d5351f53516525275151f5352053518525295151f5352053518525295151f5352053517525295151f5352053517525295151d5351f53516525275151d5351f5351652527515
010c00200c0330f13503130377140313533516337140c033306150c0330313003130031253e5153e5150c1430c043161340a1351b3130a1353a7143a7123a715306153e5150313003130031251b3130c0331b313
010c00200c0331413508130377140813533516337140c033306150c0330813008130081253e5153e5150c1330c0430f134031351b313031353a7143a7123a715306153e5150313003130031251b3130c0333e515
011800001f5452253527525295151f5452253527525295151f5452253527525295151f5452253527525295151f5452353527525295151f5452353527525295151f5452253527525295151f545225352752529515
010c002013035165351b0351d53513025165251b0251d52513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165251b0351d545
011200000843508435122150043530615014351221502435034351221508435084353061512215054250341508435084350043501435306150243512215034351221512215084350843530615122151221524615
011200000c033242352323524235202351d2352a5111b1350c0331b1351d1351b135201351d135171350c0330c0332423523235202351d2351b235202352a5110c03326125271162c11523135201351d13512215
0112000001435014352a5110543530615064352a5110743508435115152a5110d43530615014352a511084150d4350d4352a5110543530615064352a5110743508435014352a5110143530615115152a52124615
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033115151c1351d1351c1351d135115151d1350c03323135115152213523116221352013522135
0112000001435014352a5110543530615064352a5110743508435115152a5110d435306150143502435034350443513135141350743516135171350a435191351a1350d4351c1351d1351c1351d1352a5011e131
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033192351a235246151c2351d2350c0331f235202350c033222352323522235232352a50130011
0114001800140005351c7341c725247342472505140055352173421725287342872504140045351f7341f725247342472502140025351d7341d72524734247250000000000000000000000000000000000000000
0002000008673116751b675236752a6752e675373750960502605176052a65526655236731d67517675116050c6050a6050130537305373053830537305373053730037300383003830038300393003930039300
000100002767025675226541f6551a6441664512630106350b6240762502604116050f6000c60508604046050160402605051000550518704187051f7041f7050000000000000000000000000000000000000000
000800002504025045250442504525044247052a0402a0452a0442a0452a0442470527050270552705427055270542c4052305023055230542305523054347052005020050200502005020050200502005020050
000400003006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060
000100003f6503e6503e6503e6503e6503e6503e650376503565031650306502f7502f7502e7502e7502e7502e750226502f75030750236503075023650307502565030750266503075030750307503075030750
010400003f6403e65035250362502b65032350307502e7502a4502c7502b4502b7502b750264502c350273502545026450254502335022350213501f3501e3501e3501f2501e2501d2501d2501c2501625014250
010100003b65037650326502e650296501c65014350143501435014350133500d6500d6500d6500d6500e6500e6500e6500d6500c650055500a6500d650372502d2502a25027250252501a250172501525013250
010300002d650226502765025650256502565024650246501d5502665022750152501d6502325023750122501b15012650137500d2500b55011750126500a7500975008750077500525004750027500175002250
__music__
00 00 01 43 44
00 00 01 43 44
01 00 01 43 44
00 00 01 43 44
00 02 03 43 44
02 02 03 43 44
00 04 42 43 44
00 04 42 43 44
00 04 05 43 44
00 04 05 43 44
01 04 05 43 44
00 04 05 43 44
00 06 07 43 44
02 08 09 43 44
01 0a 0b 43 44
00 0c 0d 43 44
00 0a 0e 43 44
02 0c 0e 43 44
00 10 42 43 44
01 10 0f 43 44
00 10 0f 43 44
00 10 11 43 44
00 12 11 43 44
02 12 13 43 44
01 14 15 43 44
00 14 15 43 44
00 16 15 43 44
00 16 15 43 44
00 18 17 43 44
02 16 17 43 44
00 19 42 43 44
01 19 1a 43 44
00 19 1a 43 44
00 1b 1a 43 44
00 19 1c 43 44
02 1b 1c 43 44
01 1d 1e 43 44
00 1d 1f 43 44
00 1d 1e 43 44
00 1d 1f 43 44
00 21 20 43 44
02 1d 22 43 44
00 27 42 43 44
01 24 23 43 44
00 24 23 43 44
02 26 25 43 44
01 28 29 43 44
03 2a 2b 43 44
01 2d 30 43 44
00 2e 30 43 44
00 2d 30 43 44
00 2e 30 43 44
00 2d 2c 43 44
00 2d 2c 43 44
02 2e 2f 43 44
01 31 32 43 44
00 31 32 43 44
00 33 34 43 44
02 35 36 43 44
01 37 38 43 3f
00 37 38 43 3f
00 39 3b 43 3f
00 39 3c 43 3f
02 3a 3d 43 3f
