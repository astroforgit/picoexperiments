pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--super hot pellet muncher 2000
--by ultrabrite

ver="1.2.5"
corstr="archive disk worn"

function printc(s,x,y,c) print(s,x-#s*2,y,c) end
function printr(s,x,y,c) print(s,x-#s*4,y,c) end

function prntver()--suicide func
	printr(ver,122,122,6)
	if (corrupt) printc(corstr,64,122,10)
	if (frame>180) prntver=function()end
end

corrupt=(peek(0x4300)==0xee and rnd(20)<1) --after reset only
poke(0x4300,0xee)

-------------------
cartdata("shpm2k")
-- more cotrol on when to write data
-- (think of pi + sdcards)
cdat={
	load=function()
		memcpy(0x5d00,0x5e00,256)
		cdat.timer,cdat.wrt,cdat.changed=60,0,false
	end,
	save=function()
		if cdat.changed then
			memcpy(0x5e00,0x5d00,256)
			cdat.timer,cdat.wrt,cdat.changed=60,1,false
		end
	end,
	icon=function()
		if (cdat.timer>0) spr(240+cdat.wrt,0,0) cdat.timer-=1
	end,
	get=function(slot)
		return peek4(0x5d00+slot*4)
	end,
	set=function(slot,v)
		local ad=0x5d00+slot*4
		if (peek4(ad)!=v) poke4(ad,v) cdat.changed=true
	end
}
dget,dset,dload,dsave=cdat.get,cdat.set,cdat.load,cdat.save

dload()

--load scores
scofs=(corrupt) and 20 or 0
best={}
for i=1,4 do best[i]=dget(scofs+i) end

function setscore(s,n)
	local b=best[n]
	if b<s or b>0 and s<0 then best[n]=s dset(scofs+n,s) end
end

function resetscores()
	for i=1,4 do best[i]=0 dset(scofs+i,0) end
end


-- table tools
function rndi(x) return flr(rnd(x)) end
function rndidx(t) return flr(1+rnd(#t)) end
function randt(t) return t[flr(1+rnd(#t))] end

function shuffle(t,nb,d)-- slight shuffle, nb first cells, random move at range d
	local nb=nb or #t
	for i=1,nb do -- nb swaps
		local a=1+rndi(nb)
		local b=d and min(a+rndi(d),nb) or 1+rndi(nb)
		t[a],t[b]=t[b],t[a]
	end
	return t
end

function clone(t) -- clone all
	local r={} for i,v in pairs(t) do r[i]=v end return r
end

function purge(t) -- only kill numerated part
	for i=#t,1,-1 do t[i]=nil end
end

function insorty(t) -- insertion sort, ascending y
	for n=2,#t do
		local i=n
		while i>1 and t[i].y<t[i-1].y do
			t[i],t[i-1]=t[i-1],t[i]
			i-=1
		end
	end
end

--borned val on a segment
--function linseg(x,x1,y1,x2,y2) return mid(y1,y1+(x-x1)*(y2-y1)/(x2-x1),y2) end
--hardcoded 1-20
function linseg(x,y1,y2) return mid(y1,y1+(x-1)*(y2-y1)/19,y2) end

stack=
{
	clear = function(m) purge(m) end,
	push = function(m,t) m[#m+1]=t end,
	pop = function(m) local t=m[#m] m[#m]=nil return t end,
}


----- dimmer
plut,mlut = {[0]=0,0,1,2,2,1,5,6,2,4,9,3,13,1,8,9},{}
for i=0,15 do
	for j=0,15 do
		mlut[16*i+j]=16*plut[i]+plut[j]
	end
end

function gmemdim(n)
	for i=1,n do
		local a=0x6000+rnd(0x2000) poke(a,mlut[peek(a)])
	end
end

----- only one sfx instance at a time
_sfx=sfx
sfxp={}

function sfx(n) sfxp[n]=true end
function sfx_play()
	for i=0,63 do
		if sfxp[i] then
			_sfx(i)
		end
	end
	sfxp={}
end
----


menuitem(1,"dip switches",function() dips.active=true end)


function dipsdone() dips:save() run() end
function defaults() dips:clear() end

dips={
	{val=0,com={[0]="ghosts stop on a cell",   [1]="ghosts stop at any pixel"}},
	{val=0,com={[0]="harmful stunned ghosts",  [1]="harmless stunned ghosts" }},
	{val=0,com={[0]="stop at walls",           [1]="stop at intersections"   }},
	{val=0,com={[0]="speed trails",            [1]="no speed trail"        }},
	--{val=1,com={[1]="hide ghost targets",[0]="show ghost targets"}},
	{com="defaults",fn=defaults},
	{com="reset scores",fn=resetscores},
	{com="back to game",fn=dipsdone},

	targs=true,
	sel=1,
	active=false,

	init=function(m)
		local sx,sy=8,8
		local st=0
		for mm in all(m) do
			if mm.val then
				st=max(st,max(#mm.com[0],#mm.com[1]))
			else
				st=max(st,#mm.com)
			end
		end
		m.sx,m.sy=st*4+10,#m*10-2
		m.ox,m.oy=64-m.sx/2+1,64-m.sy/2
		m.tm=0

		m:load()
	end,

	readup=function(m)
		m.sync =m[1].val==0
		m.harm =m[2].val==0
		m.peasy=m[3].val!=0
		m.trail=m[4].val==0
		--m.targs=m[5].val==0
	end,

	draw=function(m)
		rectfill(m.ox-4,m.oy-4,m.ox+m.sx+2,m.oy+m.sy+2,0)
		for i=1,#m do
			local dd=m[i]
			local bb=m.oy+i*10-10
			if dd.val then
				spr(dd.val==1 and 159 or 143, m.ox,bb)
				print(dd.com[dd.val],m.ox+8,bb+1,(i==m.sel) and 7 or 6)
			else
				if i==m.sel and m.tm>0 then
					m.tm=max(0,m.tm-1)
				else
					spr(175, m.ox,bb)
				end
				print(dd.com,m.ox+8,bb+1,(i==m.sel) and 7 or 6)
			end
			if (i==m.sel) spr(191,m.ox,bb)
		end
		rect(m.ox-4,m.oy-4,m.ox+m.sx+2,m.oy+m.sy+2,6)
	end,

	edit=function(m)
		poke(0x5f30,1)
		if (btnp(2)) m.sel=1+(m.sel+#m-2)%#m m.tm=0
		if (btnp(3)) m.sel=1+m.sel%#m m.tm=0
		if btnp(4) or btnp(5) or btnp() == 64 then
			poke(0x5f30,1)
			local mm=m[m.sel]
			if (mm.val) mm.val=1-mm.val
			if (mm.fn) mm.fn() m.tm=10
		end
	end,

	load=function(m)
		for i=1,#m do
			local mm=m[i]
			if mm.val then
				mm.val=dget(10+i)
			end
		end
		m:readup()
	end,

	save=function(m)
		for i=1,#m do
			local mm=m[i]
			if mm.val then
				dset(10+i,mm.val)
			end
		end
		dsave()
		--m:readup()
	end,

	clear=function(m)
		for i=1,#m do
			local mm=m[i]
			if mm.val then
				mm.val=0
				--dset(10+i,0)
			end
		end
		m:readup()
	end,

}
dips:init()

sz=22
sz1,sz2,szp=sz-1,sz/2,sz*5

ox,oy=flr((128-szp)/2),4+flr((121-szp)/2)

tile_lut = { [0]=0,3,16,19, 1,2,17,18, 48,51,32,35, 49,50,33,34 }

lcols={{1,2},{1,3},{1,4},{1,5},{2,4},{2,5}}--ot of tokens

slaby={
	col=lcols[1],

	new=function() return setmetatable({},slaby) end,

	make=function(homes,imp,pls)
		local lab = imp and slaby.import(imp) or slaby.build(pls)
		lab:makewayshome(homes)
		lab:biglist()
		lab.spp=204
		lab.col=randt(lcols) --out of tokens
		return lab
	end,

	fake=function()
		local lab = setmetatable({},slaby)
		for a=0,sz1 do
			lab[a]={}
			for b=0,sz1 do
				lab[a][b]={ p=0, b=0, j=0 }
			end
		end
		lab:biglist()
		lab.glist.idx=0
		return lab
	end,

	build=function(pls)
		local m=slaby.new()

		-- basic layout (pillars & rooms)
		k=false
		for a=0,sz1,2 do
			m[a],m[a+1]={},{}
			for b=0,sz1,2 do
				m[a  ][b  ]={ p=0, b=1, j=0 } -- pillar
				m[a+1][b+1]={ p=0, b=0, j=0 } -- room

				m[a][b+1]={ p=0, b=0, j=0 } -- room for now
				m[a+1][b]={ p=0, b=0, j=0 } -- room for now
			end
		end

		--walls
		for a=0,sz1,2 do
			for b=0,sz1,2 do
				--local c=m[a][b]
				local lw=shuffle(m:listways(a,b))
				local w=lw[1]
				local aa,bb=m.wrap(a+sdirs[w].x,b+sdirs[w].y)
				m[aa][bb].b=1
			end
		end

		--done=false
		repeat
			done=true
			---[[ remove dead-ends
			for a=1,sz1,2 do
				for b=1,sz1,2 do
					local w=m:listwalls(a,b)
					while (#w>2) do
						local d=rndidx(w)
						del(w,w[d])
						m:setb(a+sdirs[d].x,b+sdirs[d].y,0)
						done=false
					end
				end
			end
			--if (symh or symv) m:makesym(symh,symv)
		until done

		-- maze ok 90% of the time thanks to dead-end removal.
		-- still occasionally some parts are not connected

		local ok=false
		tries=0
		repeat
			tries+=1
			m:tag(1,1,pls)
			ok=m:checkmainrooms()
		until ok

		m:join()

		return m:shift()
	end,

	import=function(n)
		local lab=slaby.new()
		local i,j,c=n*24-24,96
		for a=0,sz1 do
			lab[a]={}
			for b=0,sz1 do
				local c=sget(i+a,j+b)
				local p=0
				if (c>0 and c<7) p=c+10
				lab[a][b]={ p=p, b=c==13 and 1 or 0 }
			end
		end
		lab:join()
		lab:tag(1,1)
		return lab
	end,

	biglist=function(m)
		m.glist={}
		for a=0,sz2-1 do
			for b=0,sz1 do
				add(m.glist,m[a][b])
				add(m.glist,m[sz1-a][b])
			end
		end
		shuffle(m.glist,nil,60)
		m.glist.idx=#m.glist
	end,

	join=function(m)
		for a=0,sz1 do
			for b=0,sz1 do
				local c=m[a][b]
				c.j=0
				if c.b!=0 then
					local w=m:listwalls(a,b)
					for i in all(w) do c.j+=tile_dir[i] end
				end
				c.co=1+rnd(15)
				local n=rndidx(letsg)
				c.ch=sub(letsg,n,n)
			end
		end
	end,

	glitch=function(m,n)
		for i=1,n do
			local a,b=rndi(sz),rndi(sz)
			local c=m[a][b]
			if c.b!=0 then
				c.co,c.cob=flr(6+rnd(6)),1+rnd(5)
				local n=rndidx(letsg)
				c.ch=sub(letsg,n,n)
			end
		end
	end,

	copyglitch=function(m,n)
		for a=0,sz1 do
			for b=0,sz1 do
				local d,s=m[a][b],n[a][b]
				d.co,d.cob,d.ch=s.co,s.cob,s.ch
			end
		end
	end,

	doglitch=function(m,n)
		if n then
			local c
			for i=1,n do
				if m.glist.idx<#m.glist then
					m.glist.idx+=1
					c=m.glist[m.glist.idx]
				else
					c=m[rndi(sz)][rndi(sz)]
				end
				local n=rndidx(letsg)
				c.ch,c.co,c.cob=sub(letsg,n,n),1+rnd(15),0
			end
		end
		return m.glist.idx>=#m.glist
	end,

	deglitch=function(m,n)
		n=min(n,m.glist.idx)
		if n then
			for i=1,n do
				m.glist[m.glist.idx].ch=nil
				m.glist.idx-=1
			end
		end
		return m.glist.idx==0
	end,

	makewayshome=function(m,h)
		m.hwp={}
		for i=1,#h do
			local hh=h[i]
			local hw = m:makewaypoints(hh.hx,hh.hy)
			hw.hx,hw.hy=hh.hx,hh.hy
			m.hwp[i] = hw
		end

	end,
--[[
	makesym=function(m,h,v)
		for i=1,sz2-1 do
			if v then
				m[0][sz-i].b=m[0][i].b
				m[sz2][sz-i].b=m[sz2][i].b
			end
			if h then
				m[sz-i][0].b=m[i][0].b
				m[sz-i][sz2].b=m[i][sz2].b
			end
			for j=1,sz2-1 do
				if v then
					m[   i][sz-j].b=m   [i][j].b
					m[sz-i][sz-j].b=m[sz-i][j].b
				end
				if h then
					m[sz-i][   j].b=m[i][   j].b
					m[sz-i][sz-j].b=m[i][sz-j].b
				end
			end
		end
	end,
--]]
	shift=function(m,w,h)-- find best map center
		--count spaces
		local shm,svm,lci,lcj=20,20,2,2
		for j=0,sz1,2 do
			local shn,svn=0,0
			for i=1,sz1,2 do
				if (m[j][i].b==0) shn+=1
				if (m[i][j].b==0) svn+=1
			end
			if (shn<shm) lci=j shm=shn
			if (svn<svm) lcj=j svm=svn
		end
		if lci!=0 or lcj!=0 then
			local lab=slaby:new()
			lab.p=m.p
			for i=0,sz1 do
				lab[i]={}
				for j=0,sz1 do
					lab[i][j]=m[(i+lci)%sz][(j+lcj)%sz]
				end
			end
			return lab
		else
			return m
		end
	end,

	checkmainrooms=function(m)
		for a=1,sz1,2 do
			for b=1,sz1,2 do
				if m[a][b].t!=0 then --non connected room
					--look at walls
					local wl=shuffle(m:listwalls(a,b))
					for i=1,#wl do
						local d=wl[1]
						local dx,dy=sdirs[d].x,sdirs[d].y
						local aa,bb=a+dx,b+dy
						local sa,sb=sz-aa,sz-bb
						--check other side
						local ot=m:get(aa+dx,bb+dy)
						if ot.t==0 then
							m:flipwall(aa,bb)
							return false--might be enough
						end
					end
				end
			end
		end
		return true
	end,

	makewaypoints=function(m,x,y)
		local w={}
		for i=0,sz1 do
			w[i]={}
			for j=0,sz1 do
				w[i][j]=1000
			end
		end

		stack:clear()
		local c={a=x,b=y,d=0}
		while(c!=nil) do
			local a,b=m.wrap(c.a,c.b)
			local d=c.d
			local u=w[a][b]
			if u>d then
				local ws= m:getways(a,b)
				if (ws[dir_lf]) stack:push({a=a-1,b=b,d=d+1})
				if (ws[dir_rt]) stack:push({a=a+1,b=b,d=d+1})
				if (ws[dir_up]) stack:push({a=a,b=b-1,d=d+1})
				if (ws[dir_dn]) stack:push({a=a,b=b+1,d=d+1})
				w[a][b]=d
			end
			c=stack:pop()
		end
		return w
	end,

	tag=function(m,i,j,pls)
		m.p=0
		for a=0,sz1 do
			for b=0,sz1 do
				m[a][b].t=16
			end
		end

		stack:clear()
		ij={a=i,b=j}
		while(ij!=nil) do
			local a,b=m.wrap(ij.a,ij.b)
			local c=m[a][b]

			if c.t==16 then

				c.t=0
				if (pls) c.p=1 m.p+=1

				local w= m:getways(a,b)
				if (w[dir_lf]) stack:push({a=a-1,b=b})
				if (w[dir_rt]) stack:push({a=a+1,b=b})
				if (w[dir_up]) stack:push({a=a,b=b-1})
				if (w[dir_dn]) stack:push({a=a,b=b+1})
			end

			ij=stack:pop()
		end

	end,

	draw=function(m,g)
		if not g then
			pal(1,m.col[1])
			pal(2,m.col[2])
		end
		for i=-1,sz do
			local ci=m[(i+sz)%sz]
			local xx=i*5
			for j=-1,sz do
				local c=ci[(j+sz)%sz]
				if g then
					if c.ch then
						local yy=j*5+1
						rectfill(xx+1,yy,xx+5,yy+4,c.cob)
						print(c.ch,xx+2,yy,c.co)
					end
				else
					local yy=j*5
					if c.b!=0 then
						spr(m.spp+tile_lut[c.j],xx,yy)
					end
					if (c.p==1) pset(xx+3,yy+3,6)
					if (c.p==2) spr(5,xx,yy)
					if c.p>10 then
						spr(22+c.p,xx,yy)
						if (c.p==diff+10) spr(32,xx,yy)
					end
				end
			end
		end
		pal(1,1)pal(2,2)
	end,
--[[
	drawg=function(m)
		for i=-1,sz do
			local ci=m[(i+sz)%sz]
			local xx=i*5+1
			for j=-1,sz do
				local c=ci[(j+sz)%sz]
				if c.ch then
					local yy=j*5+1
					rectfill(xx,yy,xx+4,yy+4,0)
					print(c.ch,xx+1,yy,c.co)
				end
			end
		end
	end,
--]]
	p2i=function(x,y)--pix2index
		return flr(((x+szp)%szp)/5), flr(((y+szp)%szp)/5)
	end,

	wrap=function(ki,kj) return (ki+sz)%sz,(kj+sz)%sz end,
	wrapp=function(ki,kj) return (ki+szp)%szp,(kj+szp)%szp end,

	get=function(m,i,j) return m[(i+sz)%sz][(j+sz)%sz] end,
	set=function(m,i,j,k) m[(i+sz)%sz][(j+sz)%sz]=k end,
	setb=function(m,i,j,b) m[(i+sz)%sz][(j+sz)%sz].b=b end,

	flipwall=function(m,ii,jj)
		local b=m:get(ii,jj)
		b.b=1-b.b
	end,

	checkway=function(m,i,j,d)
		return m[(i+sz+sdirs[d].x)%sz][(j+sz+sdirs[d].y)%sz].b==0
	end,

	getways=function(m,i,j)
		local w={}
		for d=1,4 do
			w[d]=m:checkway(i,j,d)
		end
		return w
	end,

	listways=function(m,i,j)
		local w={}
		for d=1,4 do
			if (m:checkway(i,j,d)) add(w,d)
		end
		return w
	end,

	listwalls=function(m,i,j)
		local w={}
		for d=1,4 do
			if (not m:checkway(i,j,d)) add(w,d)
		end
		return w
	end,
} slaby.__index=slaby


-----
score,health,npills,ouch=0,40,0,false

frame=0

dir_no,dir_up,dir_rt,dir_dn,dir_lf=0,1,2,3,4

tile_dir={[0]=0,8,4,2,1}

backdirs={3,4,1,2}--back dir
sdirs={ [0]={x=0,y=0},{x=0,y=-1},{x=1,y=0},{x=0,y=1},{x=-1,y=0} }
dkeys={2,1,3,0}--dir to button number

tdirs={[0]={1,2,3,4},{3,2,4},{4,1,3},{1,2,4},{2,1,3}}--test dirs

pdirs={ [0]={x=0,y=0},{x=0,y=szp-1},{x=1,y=0},{x=0,y=1},{x=szp-1,y=0} }

function movepos(x,y,d) return laby.wrapp(x+pdirs[d].x,y+pdirs[d].y) end

function rndir() return flr(1+rnd(4)) end

md_chase="1chase"
md_scatter="2scatter"
md_done="3done"
md_stun="4stun"
md_fright="5fright"
md_home="6home"
md_wait="7wait"

sghost={

	new=function(q,i)
		local g=setmetatable({},sghost)
		g.hx,g.hy=q.hx,q.hy
		g.cx,g.cy=q.hx,q.hy
		g.x,g.y=q.hx*5,q.hy*5
		g.sx,g.sy=q.sx,q.sy
		g.tx,g.ty=q.sx,q.sy
		g.d=0
		g.sp=i
		g.p=0--pills in pocket
		g.spd=8
		g.cell,g.home=true,true
		g:setmode(md_wait,1000)
		if (i==1) g.think=g.blinky g.dopills=nop
		if (i==2) g.think=g.pinky g.dopills=nop
		if (i==3) g.think=g.inky
		if (i==4) g.think=g.clyde

		return g
	end,

	reset=function(g,hwp)
		g.hw,g.hx,g.hy=hwp,hwp.hx,hwp.hy
		g.cx,g.cy=g.hx,g.hy
		g.x,g.y=g.cx*5,g.cy*5
		g.d,g.p=0,0
		g.cell,g.home=true,true
		g.yep=true
		g:setmode(md_wait,1)
		g.spd=g_spd
		g.spdc=g.spd --current speed
	end,

	blinky=function(g,p)
		g.tx,g.ty = p.cx,p.cy
	end,

	pinky=function(g,p)
		if (p.d>0) g.tx,g.ty = p.cx+sdirs[p.d].x*4,p.cy+sdirs[p.d].y*4 -- (wrap later)
	end,

	inky=function(g,p,c)
		local k=blinky
		 -- symmetric of blinky with respect to blinky's target
		g.tx,g.ty = 2*k.tx-k.cx,2*k.ty-k.cy
	end,

	clyde=function(g,p,c)
		--dist from pac
		local dx,dy=p.cx-g.cx,p.cy-g.cy
		if (dx> sz2) dx-=sz2
		if (dx<-sz2) dx+=sz2
		if (dy> sz2) dy-=sz2
		if (dy<-sz2) dy+=sz2
		local d2=dx*dx+dy*dy

		if d2>25 then -- 5 blocks away (8 pacman tiles)
			g.tx,g.ty=p.cx,p.cy -- chase like blinky
		else
			g.tx,g.ty=g.sx,g.sy -- shy away (scatter)
		end
	end,

	dopills=function(g,p,c)
		if c.p==0 and g.p>0 then -- lay pills
			c.p=(g.cx==p.hx and g.cy==p.hy)and 2 or 1 --pac home->powerpill
			g.p-=1
		elseif c.p==1 and g.p<30 then -- move pills around
			c.p=0 g.p+=1
		end
	end,

	setspeed=function(g,spd)
		g.spd=spd
		g:setmode()
	end,

	setmode=function(g,md,tm)
		local spd=g.spd
		local gmd=md or g.m
		if gmd==md_chase then
			tm=tm or linseg(level, 20, 30)
		elseif gmd==md_scatter then
			tm=tm or linseg(level, 7, 1)
		elseif gmd==md_fright then
			if (g.m==md_home) return
			tm=tm or linseg(level, 7, 2)
			spd=min(g.spd,pac.spd-2)
		elseif gmd==md_stun then
			tm=tm or linseg(level, 2, 1)
		elseif gmd==md_wait then
			tm=tm or -1
		elseif gmd==md_home or gmd==md_done then
			spd=g.spd+2
		end

		g.m=gmd
		g.spdc=spd
		if (tm) g.tm=flr(tm*60)

	end,

	gethome=function(g)
		local d=1000
		for i=1,4 do
			local wi,wj=laby.wrap(g.cx+sdirs[i].x,g.cy+sdirs[i].y)
			local dd=g.hw[wi][wj]
			if (dd<d) newdir=i d=dd
		end
		return newdir
	end,

	update=function(g,ii)

		local p=pac

		if (g.tm>0) g.tm-=1

		if runframe(g.spdc) then

			if g.d!=0 then
				g.x,g.y=movepos(g.x,g.y,g.d)

				g.bck=backdirs[g.d]
				g.cx,g.cy=flr(g.x/5+.5),flr(g.y/5+.5)
				g.cell=(g.x%5)==0 and (g.y%5)==0
				g.home=(g.x==g.hx*5 and g.y==g.hy*5)
			end
		else
			return
		end

		if g.cell then

			local c=laby:get(g.cx,g.cy)
			local w=laby:listways(g.cx,g.cy)

--			local bck=backdirs[g.d]
			if (#w>1) del(w,g.bck) -- no going back

			local do_target=false
			local newdir=0

			if g.m==md_chase then
				g.think(g,p,c)
				g.dopills(g,p,c)
				do_target=true
				if g.tm==0 then
					g:setmode(md_scatter)
					newdir=g.bck
				end
			elseif g.m==md_scatter then
				g.dopills(g,p,c)
				g.tx,g.ty = g.sx,g.sy
				do_target=true
				if g.tm==0 then
					g:setmode(md_chase)
					newdir=g.bck
				end
			elseif g.m==md_home then
				newdir=g:gethome()
				if (g.home) g:setmode(md_stun,1) newdir=0
			elseif g.m==md_done then
				newdir=g:gethome()
				if (g.home) g:setmode(md_wait) newdir=0
			elseif g.m==md_fright then
				newdir=randt(w)
				if (g.tm==0) g:setmode(md_chase)
			elseif g.m>=md_stun then --also md_wait
				newdir=0
				if (g.tm==0) g:setmode(md_scatter,2)
			end

			if do_target then

				--to target
				g.tx,g.ty=(g.tx+sz)%sz,(g.ty+sz)%sz
				local dtx,dty=g.tx-g.cx,g.ty-g.cy
				if (dtx> sz2) g.tx-=sz
				if (dtx<-sz2) g.tx+=sz
				if (dty> sz2) g.ty-=sz
				if (dty<-sz2) g.ty+=sz

				if #w==0 then
					newdir=bck
				elseif #w==1 then
					newdir=w[1] -- no choice
				else -- get closer to target
					local bd=10000
					shuffle(w)
					for i=1,#w do
						local d=sdirs[w[i]]
						local nx,ny=g.cx+d.x,g.cy+d.y
						local dx,dy=g.tx-nx,g.ty-ny
						local d2=dx*dx+dy*dy
						if (d2<bd) bd,newdir=d2,w[i]
					end
				end

			end

			--if (newdir!=0)
			g.d=newdir

		end

		g.yep=false

	end,

	check=function(g,p)
		local dx,dy=g.x-p.x,g.y-p.y
		local d2=dx*dx+dy*dy
		if g.m!=md_home and g.m!=md_done and d2<13 then
			if g.m==md_fright then
				g:setmode(md_home)
				score+=gscore gscore*=2
				sfx(61)
			elseif health>0 and (dips.harm or g.m!=md_stun) then
				g:setmode(md_stun)
				health=max(0,health-(dips.harm and 0.25 or 2))
				ouch=true
				score_blink=5
			end
		end
	end,

	draw=function(g)
		local blk=band(frame,8)==8
		local tw = blk and 6 or 22

		if g.m==md_fright then
			sp1,sp2=tw+5,38+g.d
			if (g.tm<120 and blk) sp1+=1
		elseif g.m==md_home then
			sp1,sp2=39,41--38+g.d
		elseif g.m==md_scatter then
			sp1,sp2=tw+g.sp,54+g.d
		elseif g.m==md_stun then
			sp1,sp2=tw+g.sp,38 + 1+(frame/2)%4
		elseif g.m==md_wait then
			sp1,sp2=tw+g.sp,41
		else
			sp1,sp2=tw+g.sp,38+g.d
		end

		for i=-1,1 do
			local sx=g.x-i*szp
			for j=-1,1 do
				local sy=g.y-j*szp
				spr(sp1,sx,sy)
				spr(sp2,sx,sy)
			end
		end
	end,

} sghost.__index=sghost

pacspr={[0]=138,128,170,133}

spac={

	new=function(h)
		local p=setmetatable({},spac)
		p.hx,p.hy,p.tx,p.ty=h.hx,h.hy,h.hx,h.hy
		p.g=0--skin
		p:reset()
		return p
	end,

	reset=function(p,hwp)
		if (hwp) p.hw,p.hx,p.hy=hwp,hwp.hx,hwp.hy
		p.cx,p.cy=p.hx,p.hy
		p.x,p.y=p.cx*5,p.cy*5
		p.d,p.p=0,0--dir,pills in belly
		p.sp=pacspr[p.g]
		p.cell,p.home,p.yep,p.hold,p.done=true,true,true,true,false
		p.dlk=0
		p.spd=p_spd
	end,
--[[
	teleport=function(p,i,j)
		p.cx,p.cy=i,j
		p.x,p.y=p.cx*5,p.cy*5
		p.d=0
		p.sp=4
		p.cell=true
		p.yep=false
	end,
--]]
	update=function(p)

		if (health==0 or p.done) return

		local w=laby:getways(p.cx,p.cy)
		local c=laby:get(p.cx,p.cy)

		if c.p==1 then
			score+=1
			c.p=0 p.p+=1
			sfx(59)
		elseif c.p==2 then
			score+=5
			c.p=0 p.p+=1
			sfx(60)
			--[[
			blinky:setmode(md_fright)
			pinky:setmode(md_fright)
			inky:setmode(md_fright)
			clyde:setmode(md_fright)
			--]]
			game_setghostsmodes(md_fright)
			gscore=20
		end

		--teleport
		--[[
		local tel=false
		if btnp(5) then
			health=max(health-1,0)
			if health>0 then
				p:teleport(1+rndi(sz2)*2,1+rndi(sz2)*2)
				score-=20
			end
			tel=true
		end
		--]]

		if p.cell then

			if (p.d!=0) sfx(57)

			--menu pods --todo: somewhere else?
			if gs_state==gs_menu and not p.yep then
				--[[if c.p==15 then
					p.g=(p.g+1)%3
					p.sp=128+p.g*5+p.d
					sfx(7)
				else]]
				if c.p>10  then
					game_setmode(c.p-10)
					p.g=diff-1--(p.g+1)%3
					p.sp=pacspr[p.g]+p.d
					sfx(62)
				end
			end

			if dips.peasy and hold and not p.yep then
				local v=laby:listways(p.cx,p.cy)
				if (#v>2) p.d=0
			end

			if (not w[p.d]) p.d=0

			p.yep=true
		else
			p.yep=false
		end

		p.dlk=max(0,p.dlk-1)
		local td=tdirs[p.d]
		for d in all(td) do
			if (btn(dkeys[d]) and w[d] and p.dlk==0) then
				p.d=d
				p.dlk=15-p.spd--lock frames
			end
		end

		if p.d!=0 and runframe(p.spd) then

			local ofx,ofy=(p.x+2)%5,(p.y+2)%5
			if p.d==dir_up or p.d==dir_dn then
				if (ofx<2) p.x+=1
				if (ofx>2) p.x-=1
			elseif p.d==dir_lf or p.d==dir_rt then
				if (ofy<2) p.y+=1
				if (ofy>2) p.y-=1
			end
			p.x,p.y=movepos(p.x,p.y,p.d)
			p.cx,p.cy=laby.p2i(p.x+2,p.y+2)
			p.tx,p.ty=p.cx,p.cy
			p.cell=(p.x%5)==0 and (p.y%5)==0
			p.home=(p.x==p.hx*5 and p.y==p.hy*5)

		end

		pac.hold=(hold and pac.d==0)

		return p.d!=0
	end,

	draw=function(p)
		--if (p.done) return
		local nsp=p.sp
		if health==0 then
			if band(frame,7)==0 then
				p.sp = (p.sp>15 and p.sp<22) and mid(16,p.sp+1,21) or 16
			end
			nsp = p.sp
		else
			if (p.d!=0) p.sp = pacspr[p.g] + p.d
			local tw = band(frame,8)==0
			local spk = tw and p.sp or p.sp+16
			nsp = ouch and 13+(frame/3)%3 or spk
		end

		for i=-1,1 do
			local sx=p.x-i*szp
			for j=-1,1 do
				local sy=p.y-j*szp
				spr(nsp, sx,sy)
			end
		end

	end,
} spac.__index=spac

letsg="abcdefghijklmnopqrstuvwxyz0123456789?()[]{}<>&*=+#@$%"
letsa="abcdefghijklmnopqrstuvwxyz0123456789',.!?:()[]{}<>&*=+#@$%"
splut={} for i=1,#letsa do splut[sub(letsa,i,i)]=63+i end

sletter={

	new=function(cx,cy, ch, d, way, delay, rev, tim)
		if (ch==' ') return nil
		local g=setmetatable({},sletter)
		g.x,g.y=cx*5,cy*5
		g.ox,g.oy=g.x,g.y
		g.ch=ch
		g.sp=splut[ch]
		g.hw=way
		g.d=d
		g.t=delay
		g.l=tim
		g.r=rev--reverse
		return g
	end,

	gethome=sghost.gethome,

	update=function(g)
		if (g.t>0) g.t-=1 return false
		if g.l then
			g.l=max(0,g.l-1)
			if (g.l==0) return true
		end

		g.cx,g.cy=flr(g.x/5),flr(g.y/5)
		if g.x%5==0 and g.y%5==0 then
			if g.hw then
				if (g.hw[g.cx][g.cy]==0) return true
				g.d=g:gethome()
			else
				if not laby:checkway(g.cx,g.cy,g.d) then
					local w=laby:listways(g.cx,g.cy)
					del(w,backdirs[g.d]) -- no going back
					g.d=w[1]
				end
			end
		end
		g.ox,g.oy=g.x,g.y
		g.x,g.y=movepos(g.x,g.y,g.d)
		return false
	end,

	draw=function(g)
		local fp= (not g.r and (g.d==2 or g.d==3)) or (g.r and (g.d==1 or g.d==4))
		local g_x,g_y=g.x,g.y
		if (fp) g_x-=1 g_y-=1
		if (g.t==0)	spr(g.sp,g_x,g_y, 1,1, fp,fp)
	end,

	drawg=function(g)
		if (g.t==0)	print(g.ch,g.x+2,g.y+1,7)
	end,

} sletter.__index=sletter

message=
{
	starth=function(m,str,noaim)
		local w=shuffle({e[1],e[2],e[3],e[4]})
		local src,dst=nil,e[5]
		for ee in all(w) do if ee.home then src=ee end end
		if (not src) return
		--local rev=(dst.hx>src.hx)
		local a,b,c=1,#str,1
		--if (rev) a,b,c=b,a,-1
		local dly=0
		for i=a,b,c do
			local lt=sletter.new(src.hx,src.hy,sub(str,i,i),0,dst.hw,dly,rev)
			add(m,lt)
			dly+=7
		end
	end,

	startm=function(m,str,t)
		local src=randt(spots)
		local d=randt(src.d)
		local dly=0
		for i=1,#str do
			local lt=sletter.new(src.x,src.y,sub(str,i,i),d,nil,dly,false,t)
			add(m,lt)
			dly+=7
		end
	end,

	start=function(m,str,x,y,d,t)
		local dly=0
		for i=1,#str do
			local lt=sletter.new(x,y,sub(str,i,i),d,nil,dly,false,t)
			add(m,lt)
			dly+=7
		end
	end,

	kill=function(m) purge(m) end,

	update=function(m)
		for p in all(m) do
			if (p:update()) del(m,p)
		end
		return #m==0
	end,

	hide=function(m)
		for l in all(m) do rectfill(l.ox,l.oy,l.ox+5,l.oy+5,0) end
	end,

	draw=function(m)
		for l in all(m) do l:draw() end
	end,

	drawg=function(m)
		for l in all(m) do l:drawg() end
	end,

	done=function(m)
		return #m==0
	end,
}

local hp,hg=flr(sz2),flr(sz/4)
local hg1,szh=hg-1,sz-hg
local szh1=szh+1
homes=shuffle(
	{--home cell & scatter cell
	{hx=hg,  hy=hg,  sx=szh1, sy=szh1},
	{hx=hg,  hy=szh, sx=szh1, sy=hg1},
	{hx=szh, hy=hg,  sx=hg1,  sy=szh1},
	{hx=szh, hy=szh, sx=hg1,  sy=hg1},
	{hx=hp,  hy=hp,  sx=hp,   sy=hp},--pac
	},4)

spots={--for messages
	{x=hg,  y=hg,  d={2,3}},
	{x=szh, y=hg,  d={3,4}},
	{x=szh, y=szh, d={1,4}},
	{x=hg,  y=szh, d={1,2}},
}

fspots={--for fruits
	{x=hg, y=hp},
	{x=hp, y=hg},
	{x=szh,y=hp},
	{x=hp, y=szh},
}

fruit_done=true
fruit_timer=0
--low token profile
function fruit_update()
	if (fruit_done) return
	if (fruit_timer>0) then
		fruit_timer-=1
		fruit_done=(fruit_timer==0)
		if abs(pac.x-fruit_spot.x*5)<5 and abs(pac.y-fruit_spot.y*5)<5 then
			score+=fruit_num*10
			health=min(health+8,healthm)
			fruit_done=true
			fruit_timer=0
			fruit_num+=1
			sfx(54)
		end
	else
		if (pac.p>fruit_trig) then
			fruit_spot=randt(fspots)
			fruit_timer=flr(8+rnd(2))*60
		end
	end
end

function game_loadlevel(imp)
	labylevel=slaby.make(homes,imp,not hold)
end

function game_teleport(newlaby)
	if (laby) newlaby:copyglitch(laby)
	laby=newlaby
	shuffle(laby.hwp,4)
	game_setspeed(level)
	for i=1,#e do
		e[i]:reset(laby.hwp[i])
	end
	if (health==0) health=40
end

function game_nextlevel()
	if (laby.p==0) clyde.p=250
	npills=max(laby.p,clyde.p)
	health=min(health+8,healthm)
	level+=1
	pac.done=false

	fruit_done=false
	fruit_timer=0
	fruit_trig=npills*(0.4+rnd(0.2))
end

function game_start()
	score=0
	fruit_num=0
	healthm=20+(slow and 0 or 12)+(dips.peasy and hold and 0 or 8)
	health=healthm
	level=(corrupt) and 255 or 0
end

function game_setghostsmodes(gmode,tm)
	for i=1,4 do e[i]:setmode(gmode,tm) end
end

talk={"well done man!","you were lucky","d'oh!","catch ya next round!","gimme back my pellets!","our pellets! thief!","are you pulling our... legs?","you think you can get away with this?","how can he munch that much?","oh well. munchers gonna munch...","i'm telling your mommy!","scoundrel!"}
brag={"can't hide man!","no luck this time!","try harder dude!","dude what happened?","gg","lol","rofl","a winner is not you","bad enough dudes are us!","lol! we mean troubol!","rest in pieces, dude!","stop messing with us!","we is r0x0rz!","u is sux0rz!","all our pellets are belong to us!"}
taunt={"out ta get ya man!","let's go hunting, bros!", "ya better run man!","okidoki! letsa go!","leave our pellets alone!","we're on your trail man!","hey! where do you think you're going?","that muncher's after our pellets bros!"}
scuse={"sorry dude! can't help it!","we're not bad, we're just designed that way!","no hard feelings, it's just our job!","let's move already!","just pulling your... leg?","i love this menu!","yummy! grilled muncher on the menu!","trololol!","told ya, we're no good"}

function game_check()
	if health==0 then
		pac.done=true
		game_setstate(gs_levelost)
		sfx(55)
	elseif pac.p==npills and pac.home then
		pac.done=true
		game_setstate(gs_levelwon)
		music(0)
	end
	if (pac.done) game_setghostsmodes(md_done)
end

function menu_check()
	if health==0 then
		pac.done=true
		game_setstate(gs_menulost)
		sfx(55)
	elseif pac.home and not pac.yep then
		pac.done=true
		game_setstate(gs_menuwon)
		music(0)
	end
	if pac.done then
		message:kill()
		game_setghostsmodes(md_done)
	end
end

function game_checkhome()
	for i=1,4 do
		if (not e[i].home) return false
	end
	return true
end

gs_intro='00_intro'
gs_wait='10_wait'
gs_fadein='21_fadein'
gs_fadeout='22_fadeout'
gs_menu='31_menu'
gs_menuwon='32_menuwon'
gs_menulost='33_menulost'
gs_game='42_play'
gs_levelwon='43_won'
gs_levelost='44_lost'
gs_next='50_next'
gs_over='51_over'
gs_gonext='52_next'
gs_gomenu='53_menu'

gs_state=gs_menu
gs_nextstate=gs_none

diffstr=
{
"super kid pellet",
"super hot pellet muncher 2000",
"super mr pellet",
"super ms pellet",
}

score_offset=16
score_active=false
score_blink=0

function score_draw()
	if (score_active) score_offset=max(0,score_offset-1) else score_offset=min(16,score_offset+1)
	if (score_offset==16) return
	print('score: '..score,8,2-score_offset,7)
	print('best: '..best[diff],8,122+score_offset,7)
	printr('round: '..level,122,122+score_offset,7)
	if (score_blink>0 and frame%10<5) pal(8,7) score_blink=max(0,score_blink-1)
	local n,p,m=flr(health/4),health%4,healthm/4
	local px=116-m*6
	local k=1
	for i=1,n do spr(4,px+k*6,2-score_offset) k+=1 end
	if (p!=0) spr(p,px+k*6,2-score_offset) k+=1
	for i=k,m do spr(0,px+i*6,2-score_offset) end
	pal(8,8)
end

function game_setmode(d)
	diff=(d==0) and 2 or mid(1,d,4)
	slow=diff%2==1
	hold=diff<3
	dset(9,diff)
	game_setspeed(1)
end

function game_setspeed(lev)
	local spd=mid(5,5+flr(lev/4),10)
	p_spd=slow and spd or 10		--max speed on fast modes
	g_spd=hold and p_spd or spd-1 --hold modes=>same speed

	if (pac) pac.spd=p_spd
	if (blinky) blinky:setspeed(g_spd)
	if (inky) inky:setspeed(g_spd)
	if (pinky) pinky:setspeed(g_spd)
	if (clyde) clyde:setspeed(g_spd)
end

function _init()

	palt(15,true)
	palt(0,false)

	game_setmode(dget(9))

	level=0
	healthm=40
	health=40

	laby=slaby.fake()

	labymenu=slaby.make(homes,1)
	labymenu.spp=200
	labymenu.col=lcols[1]

	blinky=sghost.new(homes[1],1)
	pinky=sghost.new(homes[2],2)
	inky=sghost.new(homes[3],3)
	clyde=sghost.new(homes[4],4)
	pac=spac.new(homes[5],5)

	pac.g=diff-1
	pac.sp=pacspr[pac.g]+pac.d

	e={	blinky,pinky,inky,clyde,pac	}

	dw=clone(e)--sorted for drawing

	game_setstate(gs_intro,gs_gomenu)

end

function game_setstate(st,ns)
	if st==gs_game then
		score_active=true
		score_blink=0
		game_nextlevel()
		game_setghostsmodes(md_scatter,2)
	elseif st==gs_next then
		cor=cocreate(game_loadlevel)
	elseif st==gs_over then
		sfx(58)
	elseif st==gs_menu then
		score_active=false
		cor=cocreate(game_loadlevel)--right now...
		game_start()
		inky.p=0 --btw
		clyde.p=0
		mn_diff=0
		pac.p=npills--hack
		game_setghostsmodes(md_scatter,30)
		fruit_timer=0
	elseif st==gs_fadein then
		dsave()
		sfx(3)
	elseif st==gs_fadeout or st==gs_intro then
		sfx(2)
	end
	gs_state,gs_nextstate,gs_frame=st,ns,frame
end

speeds={ --run frames
{rn=1,tt=6},--10 (1 run frame out of 6)
{rn=1,tt=5},--12
{rn=1,tt=4},--15
{rn=1,tt=3},--20
{rn=1,tt=2},--30
{rn=2,tt=3},--40
{rn=3,tt=4},--45
{rn=4,tt=5},--48
{rn=5,tt=6},--50
{rn=1,tt=1} --60 pix per sec
}

function runframe(spd)
	local sp=speeds[mid(1,spd,#speeds)]
	return frame%sp.tt<sp.rn
end

function _update60()

	frame+=1

	if cor and costatus(cor)!='dead' then
		cor_ok,cor_err=coresume(cor)
	else
		cor=nil
	end

--	sfx_clear()

	if dips.active then dips:edit() return end

	fruit_update()

	if gs_state!=gs_wait and gs_state!=gs_dips then
		ouch = false
		pac:update()
		for i=1,4 do
			local ee=e[i]
			if not pac.hold or health==0 or pac.done or (not ee.cell and dips.sync) then
				ee:update()
			end
			ee:check(pac)
		end
		if (ouch) sfx(56)
	end

	mess_done=message:update()
	home_done=game_checkhome()

	sfx_done=stat(16)<0 and stat(17)<0 and stat(18)<0 and stat(19)<0

	if gs_state==gs_game then

		game_check()

	elseif gs_state==gs_menu then

		menu_check()

		if diff!=mn_diff then
			message:kill()
			message:start(diffstr[diff].."  (best:"..best[diff]..")",sz1,sz1,1)
			mn_diff=diff
		end

	elseif gs_state==gs_menuwon then

		if home_done then
			message:startm( randt(taunt),240 )
			game_setstate(gs_next)
--			music(0)
		end

	elseif gs_state==gs_menulost then

		if home_done then
			message:startm( randt(scuse),240 )
			game_setstate(gs_fadeout,gs_gomenu)
		end

	elseif gs_state==gs_levelwon then

		if home_done then
			message:starth( randt(talk) )
			game_setstate(gs_next)
		end

	elseif gs_state==gs_levelost then

		if home_done then
			setscore(score,diff)
			message:starth( randt(brag) )
			game_setstate(gs_over)
		end

	elseif gs_state==gs_next then

		if mess_done and home_done and sfx_done then
			game_setstate(gs_fadeout,gs_gonext)
		end

	elseif gs_state==gs_gonext then

		if not cor then
			game_teleport(labylevel)
			game_setstate(gs_fadein,gs_game)
		end

	elseif gs_state==gs_gomenu then

		game_teleport(labymenu)
		game_setstate(gs_fadein,gs_menu)

	elseif gs_state==gs_over then

		if home_done then
			if btnp(4) or btnp(5) or stat(31)==' ' then
				message:kill()
				game_setstate(gs_fadeout,gs_gomenu)
			elseif mess_done then
				message:starth(rnd(3)<1 and "press x dude!" or "game over man!")
			end
		end

	elseif gs_state==gs_fadeout then

		if not cor and home_done and mess_done then
			if (laby:doglitch(10)) game_setstate(gs_nextstate)
		end

	elseif gs_state==gs_fadein then

		if laby:deglitch(10) then
			game_setstate(gs_nextstate)
		end

	elseif gs_state==gs_intro then

		if (laby:doglitch(10)) game_setstate(gs_nextstate)

	elseif gs_state==gs_wait then

		if (frame-gs_frame>180) message:kill() game_setstate(gs_nextstate)

	end

	insorty(dw)
	sfx_play()

	if ((corrupt or score<0 or level>255) and not pac.hold and frame%2==0) laby:glitch(1) --laby.spp=196

end

function _draw()

	if dips.active then
		dips:draw()
		return
	end

	if gs_state==gs_intro or (pac.spd>7 and dips.trail) then
		gmemdim(800)
	else
		cls()
	end

	prntver()

	camera(3-ox,3-oy) clip(ox,oy,szp+1,szp+1)

	message:hide()

	laby:draw()
	message:draw()

	if (gs_state!=gs_intro) then
		--homes
		for i=1,5 do
			local g=e[i]
			spr(42+i,g.hx*5,g.hy*5)
			--if (dips.targs) spr(58+i,5*(g.tx+sz)%szp,5*(g.ty+sz)%szp)--targets
		end

		if pac.p==npills then
			spr(29+(frame/6)%3,pac.hx*5,pac.hy*5)
		end

		for d in all(dw) do d:draw() end

		if fruit_timer>0 then
			local sp=(fruit_timer>120 or band(frame,8)==8) and 112 or 120
			spr(sp+fruit_num%8,fruit_spot.x*5,fruit_spot.y*5)
		end
	end

	--laby:drawg(0,0)--glitches
	laby:draw(true)--glitches


	clip() camera()

	rect(ox-1,oy-1,ox+szp+1,oy+szp+1,1)

	score_draw()

	cdat.icon()

	--print(stat(16)..' '..stat(17)..' '..stat(18)..' '..stat(19),2,8,7)
end
__gfx__
f2f2fffff8f2fffff8f8fffff8f8fffff8f8fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaafffffffaaffffffffafff
22222fff88222fff88822fff88882fff88888fffff777fffffaaafffff888fffffeeefffffcccfffff999fffffdddfffff777ffffffaffafffffaffffaaffaff
22222fff82222fff88222fff88822fff88888ffff77677fffaaaaafff88888fffeeeeefffcccccfff99999fffdddddfff77777ffffaaafaffaaaafafafaaaaff
f222fffff222fffff822fffff882fffff888fffff76667fffaaaaafff88888fffeeeeefffcccccfff99999fffdddddfff77777fffaaaaaffafaaafafffaaafff
ff2fffffff2fffffff2fffffff8fffffff8ffffff77677fffaaaaafff88888fffeeeeefffcccccfff99999fffdddddfff77777ffafaaafffafaaaafffaaaafaf
ffffffffffffffffffffffffffffffffffffffffff777ffffa9a9afff82828fffe2e2efffc1c1cfff94949fffd1d1dfff76767ffaffaffffffaffffffaffaaff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaafffffaafffffafffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffff0fffffffaffffffffffffffaaafffff888fffffeeefffffcccfffff999fffffdddfffff777ffff00a00fff0a000fff000a0ff
fa000afff0fff0ffffffffffff0a0ffffff0fffffffffffffaaaaafff88888fffeeeeefffcccccfff99999fffdddddfff77777fff00a00fff00a0afffa0a00ff
faaaaafffa0a0afff00a00fff0aaa0fffa000afffffffffffaaaaafff88888fffeeeeefffcccccfff99999fffdddddfff77777fffaa0aafff0a0a0fff0a0a0ff
faaaaafffaaaaafffaaaaaffff0a0ffffff0fffffffffffffaaaaafff88888fffeeeeefffcccccfff99999fffdddddfff77777fff00a00fffa0a00fff00a0aff
ffaaafffffaaafffffaaaffffff0fffffffafffffffffffffa9a9afff28282fff2e2e2fff1c1c1fff49494fff1d1d1fff67676fff00a00fff000a0fff0a000ff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffff999fffff888fffffdddfffffcccfffffeeefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fff7fffff99499fff88288fffdd5ddfffccdccfffeedeeffffffffffffffffffffffffffffffffffffffffffff8f8fffffefefffffcfcfffff9f9fffffafafff
ff777ffff94449fff82228fffd555dfffcdddcfffedddeffff7f7ffffffffffffff7f7ffff7f7ffff7f7ffffffffffffffffffffffffffffffffffffffffffff
fff7fffff99499fff88288fffdd5ddfffccdccfffeedeeffffffffffffffffffffffffffffffffffffffffffff8f8fffffefefffffcfcfffff9f9fffffafafff
ffffffffff999fffff888fffffdddfffffcccfffffeeefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8fffffffefffffffcfffffff9fffffffaffff
ffffffffffffffffffffffffffffffffffffffffffffffffff1f1ffffffffffffff1f1ffff1f1ffff1f1ffffff888fffffeeefffffcccfffff999fffffaaafff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8fffffffefffffffcfffffff9fffffffaffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f77777fff77777fff77777fff7777ffff77777fff77777fff77777fff7fff7ffff777fffffff77fff7fff7fff7fffffff77f77fff7fff7fff77777fff77777ff
f7fff7fff7fff7fff7fffffff7fff7fff7fffffff7fffffff7fffffff7fff7fffff7fffffffff7fff7fff7fff7fffffff7f7f7fff77ff7fff7fff7fff7fff7ff
f77777fff7777ffff7fffffff7fff7fff777fffff777fffff7ff77fff77777fffff7fffffffff7fff7777ffff7fffffff7fff7fff7f7f7fff7fff7fff77777ff
f7fff7fff7fff7fff7fffffff7fff7fff7fffffff7fffffff7fff7fff7fff7fffff7fffff7fff7fff7fff7fff7fffffff7fff7fff7ff77fff7fff7fff7ffffff
f7fff7fff77777fff77777fff7777ffff77777fff7fffffff77777fff7fff7ffff777ffff77777fff7fff7fff77777fff7fff7fff7fff7fff77777fff7ffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f77777fff77777fff77777fff77777fff7fff7fff7fff7fff7fff7fff7fff7fff7fff7fff77777ffff777fffff77fffff7777ffff7777ffff7fff7fff77777ff
f7fff7fff7fff7fff7fffffffff7fffff7fff7fff7fff7fff7fff7ffff7f7fffff7f7fffffff7ffff7ff77fffff7fffffffff7fffffff7fff7fff7fff7ffffff
f7fff7fff7777ffff77777fffff7fffff7fff7fff7fff7fff7f7f7fffff7fffffff7fffffff7fffff7f7f7fffff7ffffff777ffffff777fff77777fff7777fff
f7ff77fff7fff7fffffff7fffff7fffff7fff7ffff7f7ffff7f7f7ffff7f7ffffff7ffffff7ffffff77ff7fffff7fffff7fffffffffff7fffffff7fffffff7ff
f77777fff7fff7fff77777fffff7fffff77777fffff7ffffff7f7ffff7fff7fffff7fffff77777ffff777fffff777ffff77777fff7777ffffffff7fff7777fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff7777fff77777ffff777fffff777ffffff7fffffffffffffffffffffff7fffff77777ffffffffffffff7fffff7fffffffffffffffffffffffffffffffffffff
f7fffffff7fff7fff7fff7fff7fff7fffff7fffffffffffffffffffffff7fffff7fff7fffff7fffffff7fffffff7ffffffffffffffffffffffffffffffffffff
f7777fffffff7fffff777fffff7777fffffffffffffffffffffffffffff7fffffff777fffffffffffff7fffffff7ffffffffffffffffffffffffffffffffffff
f7fff7fffff7fffff7fff7fffffff7fffffffffffff7fffffffffffffffffffffffffffffff7fffffff7fffffff7ffffffffffffffffffffffffffffffffffff
ff777ffffff7ffffff777ffff7777fffffffffffff7fffffff7ffffffff7fffffff7ffffffffffffffff7fffff7fffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffff43ffffffff4fffffffffffff44ffffffffffffbb3bbfffffffffffffffffffff77ffffffff7fffffffffffff77ffffffffffff77777ff
ffff33ffff333fffff9993ffff884bffff33bffffffbfffffffff4ffff9a9fffffff77ffff777fffff7777ffff7777ffff777ffffff7fffffffff7ffff777fff
fff33ffff8e888fff9a999fff8e8bbfff3bb4bffffbabffffffffafff9a9a9fffff77ffff77777fff77777fff77777fff77777ffff777ffffffff7fff77777ff
ff3f3ffff888e8fff99999fff8e8b8fffb33b3fffbabb3ffffffaafffa9a9affff7f7ffff77777fff77777fff77777fff77777fff77777ffffff77fff77777ff
fe8fe8ffff8e8ffff99999fff88888fff33b3bfffbbbb3fffffaa9fff9a9a9fff77f77ffff777ffff77777fff77777fff77777fff77777fffff777fff77777ff
f88f88fffff8ffffff999fffff888fffffb33fffffbb3ffff9a99fffff9a9ffff77f77fffff7ffffff777fffff777fffff777fffff777ffff7777fffff777fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff66666fff
ffaaaafffa000affffaaaaffffaaaffffaaaafffff8aa8fff80008ffff8aa8ffffaa8ffff8aa8fffffffffffff0a0affffffffffff8fffffffffffff60006fff
faaa00fffa000afffaaa00fffaa4aafff00aaafff8aa00fffa000afff8aa00fffaaca8fff00aa8ffffe8a0ffffa9aaffffe8a0fff0a8effff0a8efff60b06fff
fa4a00fffaaaaafffa4a00fffaaaaafff00a4afffaca00fffaaaaafffaca00fffaaaaafff00acaffff8a9affff8aaaffff8a9afffaaa8ffffa9a8fff60b06fff
faaa00fffaa4aafffaaa00fffa000afff00aaafffaaa00fff8acaafffaaa00fffa000afff00aaafff8aaa0ffffe8a0fff8aaa0fffaa9affff0aaa8ff60706fff
ffaaaaffffaaafffffaaaafffa000afffaaaafffffaaa8ffff8aafffffaaa8fff80008fff8aaafffff0aaaffffff8fffff0aaafffa0a0ffffaaa0fff60006fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff66666fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff66666fff
ffaaa0fff0a0a0ffffaaa0ffffaaaffff0aaafffff8aa0fff0a2a0ffff8aa0ffffaa8ffff0aa8fffffffffffff0aa0ffffffffffff8fffffffffffff60006fff
faaaaafffaa0aafffaaaaafffaa4aafffaaaaafff8aaaafffaa2aafff8aaaafffaaca8fffaaaa8ffffe8a0ffffa9aaffffe8a0fff0a8effff0a8efff60706fff
fa4a00fffaaaaafffa4a00fffaaaaafff00a4afffaca22fffaaaaafffaca22fffaaaaafff22acaffff8a9affff8aaaffff8a9afffaaa8ffffa9a8fff60806fff
faaaaafffaa4aafffaaaaafffaa0aafffaaaaafffaaaaafff8acaafffaaaaafffaa2aafffaaaaafff8aaaaffffe8a0fff8aaaafffaa9affffaaaa8ff60806fff
ffaaa0ffffaaafffffaaa0fff0a0a0fff0aaafffffaaa0ffff8aafffffaaa0fff0a2a0fff0aaafffff0aa0ffffff8fffff0aa0fff0aa0ffff0aa0fff60006fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff66666fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2f2fffffffffffff2f2fffffff2f2fffff2f2ff66666fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff222aafffffa00aff222aafffffaa222fffaa222f60006fff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2aaaafffaa00afff2aaaafffaa1a2fffaaaa2ff60706fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2a1a00ff2aaaaaff2a1a00fffaaaaa2ff00a1a2f60706fff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaaa00fff2a1aafffaaa00fffa00aafff00aaaff60706fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaaaaff222aafffffaaaafffa00affffaaaafff60006fff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2f2ffffffffffffffffffffffffffff66666fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2f2fffffffffffff2f2fffffff2f2fffff2f2ff77777fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff222aafffffa0a0ff222aafffffaa222fffaa222f7fff7fff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2aaaafffaa0aafff2aaaafffaa1a2fffaaaa2ff7fff7fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2a1a00ff2aaaaaff2a1a00fffaaaaa2ff00a1a2f7fff7fff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaaaaafff2a1aafffaaaaafffaa0aafffaaaaaff7fff7fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaaa0ff222aafffffaaa0fff0a0affff0aaafff7fff7fff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2f2ffffffffffffffffffffffffffff77777fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ddddddddddddddddddddddd00000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
d000000000000000000000d00000000000000000000000000000000000000000ff212fffffffffffffffffffffffffffff121fffff2121fff12121fff1212fff
d0ddddddddddddddddddd0d00000000000000000000000000000000000000000f21012ffff1212fff11212fff1121ffff20002fff20000fff00000fff00002ff
d0d00000d00000d00000d0d00000000000000000000000000000000000000000f10001ffff2000fff00000fff0002ffff10101fff10101fff10101fff10101ff
d0d0ddd0d0ddd0d0ddd0d0d00000000000000000000000000000000000000000f21012ffff1211fff21211fff2121ffff20002fff20000fff00000fff00002ff
d0d0d0000000000000d0d0d0000000000000aaa000088800000ccc0000000000ff212fffffffffffffffffffffffffffff121fffff2121fff12121fff1212fff
d0d0d0ddddd0ddddd0d0d0d000000000000aaaaa0088888000ccccc000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
d0d000d100d0d002d000d0d00000000006000a4a00787880007c7cc000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
d0ddd0d0d0d0d0d0d0ddd0d000000000000aaaaa0088888000ccccc000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
d0d000d000000000d000d0d0000000000000aaa00081818000c1c1c000000000ffffffffffffffffffffffffffffffffff121fffff2121fff12121fff1212fff
d0d0d0ddd0ddd0ddd0d0d0d00000000000000000000000000000000000000000ff121ffffff212fff11212fff112fffff20002fff20000fff00000fff00002ff
d0d0d000000a000000d0d0d00000000000000000000000000000000000000000ff202fffff2100fff00000fff0012ffff10101fff10101fff10101fff10101ff
d0d0d0ddd0ddd0ddd0d0d0d00000000000000000000000000000000000000000ff101fffff1001fff20001fff2001ffff20002fff20000fff00100fff00002ff
d0d000d000000000d000d0d00000000000000000000000000000000000000000ff201fffff2012fff12012fff1201ffff10101fff10102fff20002fff20101ff
d0ddd0d0d0d0d0d0d0ddd0d00000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
d0d000d300d0d004d000d0d00000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
d0d0d0ddddd0ddddd0d0d0d00000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
d0d0d0000000000000d0d0d00000000000000000000000000000000000000000ff102fffff1021fff21021fff2102ffff10101fff10102fff20002fff20101ff
d0d0ddd0d0ddd0d0ddd0d0d00000000000000000000000000000000000000000ff101fffff1002fff10002fff1001ffff20002fff20000fff00100fff00002ff
d0d00000d00000d00000d0d0000000000000000aaaaaa0000000088888800000ff202fffff2000fff00000fff0002ffff10101fff10110fff01110fff01101ff
d0ddddddddddddddddddd0d0000000000000000aaaaaa0000000088888800000ff101fffff1001fff20001fff2001ffff20002fff20000fff00100fff00002ff
d000000000000000000000d00000000000000aaaaaaaaaa00008888888888000ff201fffff2012fff12012fff1201ffff10101fff10102fff20002fff20101ff
ddddddddddddddddddddddd00000000000000aaaaaaaaaa00008888888888000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00000000000000000000000000000000066000000aa44aa00007788778888000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00000000000000000000000000000000066000000aa44aa00007788778888000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0d6666000e666600000000000000000000000aaaaaaaaaa00008888888888000ff102fffff1021fff21021fff2102ffff10101fff10102fff20002fff20101ff
0d66d6d00e66d6e0000000000000000000000aaaaaaaaaa00008888888888000ff101fffff1002fff10002fff1001ffff20002fff20000fff00100fff00002ff
0d6666d00e6666e000000000000000000000000aaaaaa0000008822882288000ff202fffff2100fff00000fff0012ffff10101fff10101fff10101fff10101ff
0dddddd00eeeeee000000000000000000000000aaaaaa0000008822882288000ff121ffffff211fff21211fff212fffff20002fff20000fff00000fff00002ff
0d7777d00e7777e0000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffff121fffff2121fff12121fff1212fff
0d7777d00e7777e0000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5153505143515351535153514300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6073606040606060736163604000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7040707143717370407070714300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00100000185500c540135500c550185501c550005500c5501f55013540075501354007550135400755013540245500c540245500c5402855024550005500c5401f5500c550005500c550005500c550005500c550
001000001d550115401855011540145501455005550115500e5501355007550135400755013550075501354011550165401455016540165501a5500a5501655024542245322452224512081320a1320713201132
0003000039010060102f0201002027030180301d0401f0401505026050110502b0500e0502e0500b0502f0500b0502d0500d0502b050100502805013050260501505025050150502505017050250501605025050
000300001705025050160502605016050280501505029050130502c050100502d0500e0502e0500b0502f0500b0502d0500d050290501305024050190501c0501f0401604025030120302e0200d0203a01007010
0003000039010060202f0301004027050180501d0501f0501505026050110502b0500e0502e0500b0502f0500b0502d0500d050290501305024050190501c0501f0501605025050120502e0500d0503a05007050
0004000005550055500655006550065500655008550095500e55011550185501b55022550275502d55035550325502d5502955028550295502b5502c55026550205501e55023550275402c5302c5202951028500
00020000045500c55018550255502b5503155036550385503a55037550315502d550245501c550155500a55003550015500000000000000000000000000000000000000000000000000000000000000000000000
00020000167501d750277502d75030750317503275032750307502f7502a750247501d750157500e7500c7500d75013750197501c750207501e7501a75018750127500a750057500000000000000000000000000
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
00040000260502c5502c05025550320501e55027500225001d500225001d500185001d500185001350018500135000e500135000e500095000e50009500045000950004500015000450001500015000150001500
00040000315502c550275502c550275502255027550225501d550225501d550185501d550185501355018550135500e550135500e550095500e55009550045500955004550015500454001530015200151001500
00010000281202e120341203b1203b120321202a120221201c1201612013120131201812021120281202e120321103e0000000000000000000000000000000000000000000000000000000000000000000000000
00010000285102552022530205401c5501a500195001b5001d5001f50021500225000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000205502b550255503d5502755039550265502e550215502555018550205501955025550225502855024550285501d550215501655018550115501455013550125501855012550195500f550155500a550
0001000028030240401f0501a060170701250012500145001650018500195001b5002740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000075100552009530075400c54008550105500b550155500e55018550105501a550145502155018550235501c550275501f5502a550235502d55027540315302d51036550335503a550375503c55037550
0004000005550055500655006550065500655008550095500e55011550185501b55022550275502d55035550325502d5502955028550295502b5502c55026550205501e55023550275402c5302c5202951028500
00020000045500c55018550255502b5503155036550385503a55037550315502d550245501c550155500a55003550015500000000000000000000000000000000000000000000000000000000000000000000000
00020000167501d750277502d75030750317503275032750307502f7502a750247501d750157500e7500c7500d75013750197501c750207501e7501a75018750127500a750057500000000000000000000000000
__music__
01 00 42 43 44
00 01 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
