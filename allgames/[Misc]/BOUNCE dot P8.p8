pico-8 cartridge // http://www.pico-8.com
version 14
__lua__
-- bounce dot p8
-- @tehsquidz0rz + @taeckerwyss




state="pre" -- gamestates:
	-- pre -- "press z"
	-- title
	-- intro -- intro cutscene
	-- lvl -- next level screen
	-- aim
	-- bounce
	-- win

vx,vy, x,y, angle,power, up,down,left,right,arrowblip=0,0, 0,0, 0.1,6, false,false,false,false,0

wtb, blets, ptb, ftb, htb, stbl, dvds, strfld, atb={}, {}, {}, {}, {}, {}, {}, {}, {}

kx, w1b,w1r, h1b,h1r, w2b,w2r, h2b,h2r, lvlh, blta,bltb,bltc, bbt,bbs, bgcolor,plt = 1000, 10,80, 10,50, 10,5, 10,5, 250, 0,0,0, {},8, 1,{}

name, wname, wnameb, nameo, nameln="level name", "world name", "expanded world name", 0, 0

frameofintro, show_bg_white, firstkanim,restkanim, lvltot,lvlcount,worldcount, freezeframes, bcol,gcol = 0, 0, 50,0, 0,0,1, 0, 8,2

hcount, sfxang,sfxpow,hitsfx, kflip = 2, false,0,0, false

lastx,lasty,lastf, fsx,fsy,fst, wtx,wty,wtltr,wtcount, sleep, ksplodenum, spv,spx,sps, bcx,bcy=0,0,0, 0,0,0, 0,0,0,0, false, 0, 0,0,0.1, 0,0

fnum=0 -- frame
titlest=-1
cartdata("bouncedotp8_hiscores")
hiworld,hilevel = dget(0),dget(1)

function _init()
	palt(0,false)
	palt(7,true)
	name="  -  2017  -  tactical espionage bouncing  -  by aaron taecker-wyss + patrick riordan  -  king bado and his badlets swiped all the food from your village  -  time to get bouncing!  -  @taeckerwyss + @tehsquidz0rz  -  greetz to tnerb, mush + mag, hubol, graphicsogre, gabe cuzzillo, lily zone, nuprahtor, ektomarch, nathalie lawhead, arcane kids, and all the real diy gamedevs around the world!  -  a game of trial and error"
	nameln=#name*4
end

function _update60()
	if (nameo>=nameln)  nameo-=nameln
	fnum+=1
--pre
    if state == "pre" then
		if btnp(4) then
			titlest=30
			music(1)
			sfx(23)
			state="title"
		end
		return
	end
--title
    if state == "title" then
	    if btnp(4) then
			lvlcountup()
			setworldname()
			levelmake()
			gotolvlscreen()
			sfx(22)
        elseif titlest>0 then
			titlest-=1
		end
		dostrfld()
		return
	end
--lvl
	if state == "lvl" then
		if btnp(4) then
			gotointro()
			sfx(3)
		end
		dostrfld()
		return
	end
-- intro, aim, bounce or win
	if fnum%19 < 1 then
		kflip=not kflip 
	end
	if fnum%6 <1 then
		bcol=plt[flr(rnd(5))]
		gcol=(bcol+4)%16
	end
	--do particles
	foreach(ptb,dop)
	foreach(ftb,dof)
	foreach(htb,doh)
    if fst > 0 then
        dofs()
    end
	
	if freezeframes > 0 then
		freezeframes -= 1
	end

--intro
    if state == "intro" then
		ptocanon()
        if btnp(4) then
            state, firstkanim,restkanim, stbl, fst = "aim", 0, 0, {}, 0
			music(0)
        end
        frameofintro = frameofintro + 1
        return
--aim
    elseif state == "aim" then
		if btn(0)then
			angle+=0.001
			if angle>0.34 then
				angle=0.34
				sfx(-1,3)
				sfxang=false
			elseif sfxang==false then
				sfx(30,3)
				sfxang=true
			end
		elseif btn(1)then
			angle-=0.001
			if angle<0.006 then
				angle=0.006
				sfx(-1,3)
				sfxang=false
			elseif sfxang==false then
				sfx(30,3)
				sfxang=true
			end
		else
			sfx(-1,3)
			sfxang=false
		end
		ptocanon()
		if btn(2)then
			power+=0.05
			if power>12.5	then 
				power=12.5 
				sfx(-1,2)
				sfxpow=0
			elseif sfxpow != 1 then
				sfx(31,2)--power-up sound
				sfxpow=1
			end
		elseif btn(3)then
			power-=0.05
			if power<2 then 
				power=2
				sfx(-1,2)
				sfxpow=0
			elseif sfxpow != -1 then
				sfx(32,2)--power-down sound
				sfxpow=-1
			end
		else
			sfx(-1,2)
			sfxpow=0
		end
		
		if btnp(4) then --fire
			sfx(-1,2)
			sfx(-1,3)
			sfxpow=0
			sfxang=false
			state, bcx,bcy, vx,vy, freezeframes = "bounce", 0,0, cos(angle)*power,sin(angle)*power, flr(power*0.5)
			addp(x,y)
			hburst(8,12)
			sfx(24)
			music(flr(rnd(4))+2)
		end
		return
	end
-- bounce or win -- handle reset case first
	if btnp(4) then
		if state == "bounce" then 
			bletrespawn()
            music(0)
            state="aim"
		else --state == "win" 
			lvlcountup()
			angle, power=0.1, 6
			levelmake()
			gotolvlscreen()
		end
		clearfield()
		ptocanon()
		return
	end
-- bounce or win
	foreach(blets,updateblet)
	if freezeframes > 0 then
		return
	end
	updatespring()
	hcount-=1
	if hcount<=0 then
		addhap()
		local wait= max(0, 10-2*sqrt(vx*vx+vy*vy))
		hcount= wait+rnd(7)
	end
	vy+=0.08--gravity
	--collision
	if not col_with_world(x, y, vx, vy) then
		x+=vx
		y+=vy
	end
	if state == "win" then
		if fnum%3==0 then
			kingsplode()
			
		end
		checkwintext()
		foreach(dvds,dodvd)
	else
		if sleep then
			foreach(atb,doa)
			if fnum%14==0 then
				aadd()
			end
			bcam(0,0)
		else
			if lastx==x and lasty==y then
				lastf+=1
				if lastf>5 then
					music(6)
					sleep=true
				end
			else
				lastx=x
				lasty=y
				lastf=0
			end
			local bcamx,bcamy=0,0
			if (btn(0))bcamx-=1
			if (btn(1))bcamx+=1
			if (btn(2))bcamy-=1
			if (btn(3))bcamy+=1
			bcam(bcamx,bcamy)
		end
	end
end

function bcam(xin,yin)
	if xin==0 then
		if bcx>0 then
			bcx-=1
		elseif bcx<0 then
			bcx+=1
		end
	else
		bcx=max(-30,min(30,bcx+xin))
	end
	if yin==0 then
		if bcy>0 then
			bcy-=1
		elseif bcy<0 then
			bcy+=1
		end
	else
		bcy=max(-30,min(30,bcy+yin))
	end
end

function ptocanon()
	x, y = 20+cos(angle)*20, 110+sin(angle)*20
end

function gotolvlscreen()
	state = "lvl"
	music(6)
end

function gotointro()
    state, frameofintro = "intro", 0
    if firstkanim == 0 then
        restkanim = 80
        foodsuck(kx, 50)
    else
		sfx(32,3)
	end
    x, y = 20+cos(angle)*15, 110+sin(angle)*15
    music(-1)
end

function clearfield()
	ksplodenum, sleep, ptb,htb,ftb,atb, spx,spv = 0, false, {},{},{},{}, 0,0
end

function kingsplode()
	ksplodenum+=1
	local myx, myy = (kx-36)+flr(rnd(72)), 52+flr(rnd(64))
	addp(myx,myy)--splode
	if ksplodenum<90 and ksplodenum%2==0 then
		addf(myx,myy,rnd(0.2)-0.1)
	end
end

--   5___6
--  /|   /|
-- 1_|_2/ |
--|  8_|__7
--| /  | /
--4/___3/
function transformpoint(point, matrix)
    local np = {}
    np.x,  np.y, np.z = point.x*matrix[1]+point.y*matrix[2]+point.z*matrix[3] , point.x*matrix[4]+point.y*matrix[5]+point.z*matrix[6] , point.x*matrix[7]+point.y*matrix[8]+point.z*matrix[9]
    return np
end

function rotatearoundaxis(axis, angle)
    local m, cosa, sina = {}, cos(angle), sin(angle)
    m[1],m[2],m[3],m[4],m[5],m[6],m[7],m[8],m[9] = cosa+(axis.x*axis.x)*(1-cosa) , axis.x*axis.y*(1-cosa)-axis.z*sina , axis.x*axis.z*(1-cosa)+axis.y*sina , axis.y*axis.x*(1-cosa)+axis.z*sina , cosa+axis.y*axis.y*(1-cosa) , axis.y* axis.z*(1-cosa)-axis.x*sina , axis.z* axis.x*(1-cosa)-axis.y*sina , axis.z* axis.y*(1-cosa)+axis.x*sina , cosa+(axis.z*axis.z)*(1-cosa)
    return m
end

function drawcube(x, y, size)
    local points = {}
    points[1],points[2],points[3],points[4],points[5],points[6],points[7],points[8] = {x=-1, y=-1, z=-1} , {x=1, y=-1, z=-1} , {x=1, y=1, z=-1 } , {x=-1, y=1, z=-1} , {x=-1, y=-1, z=1} , {x=1, y=-1, z=1} , {x=1, y=1, z=1} , {x=-1, y=1, z=1}
    local lines = {}
    lines[1], lines[2], lines[3], lines[4], lines[5], lines[6], lines[7], lines[8], lines[9], lines[10], lines[11], lines[12]  = {i=1,j=2}, {i=3,j=2}, {i=1,j=4}, {i=3,j=4}, {i=1,j=5}, {i=2,j=6}, {i=3,j=7}, {i=4,j=8}, {i=5,j=6}, {i=7,j=6}, {i=5,j=8}, {i=7,j=8}

    local rot = rotatearoundaxis({x=sqrt(2/6), y=sqrt(3/6), z=sqrt(1/6)}, fnum/50 + .05 * sin(fnum/40))
    for i=1, 8 do
        points[i] = transformpoint(points[i], rot)
    end
    foreach(lines, function (l)
        line(x + size * points[l.i].x, y + size * points[l.i].y,
            x + size * points[l.j].x, y + size * points[l.j].y, 7)
    end)
end

function bubblesort(array)
    for i=2, count(array) do
        local index = i
        while index > 1 and array[index].z > array[index - 1].z do
            local temp = array[index]
            array[index] = array[index - 1]
            array[index - 1] = temp
            index = index - 1
        end
    end
    return array
end

function _draw()
	cls()
--pre
	if state == "pre" then
        pal(14,8+(fnum*0.34)%6)
        local myy = 60+sin(fnum*.01)*4
        circ(64,myy+4,fnum%90,10+(fnum*0.1)%6)
        spr(47,60,myy)
        print("press", 55, myy - 6, 14)
		return
	end
--title
    if state == "title" then
		drawtitlescreen()
		return
    end
--level start screen
	if state=="lvl" then
		foreach(strfld,drawstrfld)
		drawlvlscreen()
		return
	end
--in-game
	--camera
    if state == "aim" then
        camx,camy = 0,0
    elseif state == "win" then
        camx, camy = kx-64, 0
	elseif state == "intro" then
        if frameofintro < 120 then
            camx = kx - 64
        else
            local t = (frameofintro - 120)/180
            if t > 1 then
                state, camx = "aim", 0
            else
                camx , t = (1-t)*(kx-64)+t*0 , t*t*(3-2*t)
            end
        end
        camy = 0
    else --state == "bounce"
        camx, camy = x+bcx-64+flr(vx), y+bcy-70
	end
	if freezeframes > 0 then
		local mag = .5 * freezeframes + 0.2*freezeframes * freezeframes;
		camx += flr(rnd(mag) - mag / 2)
		camy += flr(rnd(mag) - mag / 2)
	end
	camera(camx, camy)
	drawbgtiles()
	foreach(wtb,drawbox)
	rectfill(-32767,116,32767,200,bcol)--floor
    if state == "aim" or state == "intro" then
		drawspiral(x,y,power+17,0.4)
	end
	--draw canon
	line(20,110,20+cos(angle)*20,110+sin(angle)*20,11)
	spr(160+(angle*300)%4,11,108)--gear
	drawcoil()
	spr(0,16,108)
	--draw badlets
	foreach(blets,drawblet)
	--draw king bado
    local showking = true
    local kingy = 52
    if firstkanim > 0 then
        firstkanim -= 1
        kingy -= firstkanim * 20
        if firstkanim == 0 then
            freezeframes = 18
			foodsuck(kx,92)
			sfx(7,3)
			music(0)
        end
    end
    if restkanim > 0 then
        restkanim -= 1
        if restkanim > 5 then
            showking = sin(restkanim/(5 + (40 - restkanim)/20)) > 0
            kingy -= 40
        else
            kingy -= restkanim * 8
            if restkanim == 0 then
                freezeframes = 15
				music(0)
            end
        end
    end
    if showking then
        spr(1,kx-32,kingy,8,8,kflip)
        print("king bado",kx-18, kingy + 11)
    end
	
	pal(14,9+rnd(7))
	foreach(htb,drawh)
	pal(14,14)
	foreach(ptb,drawp)
	foreach(ftb,drawfood)
    if fst > 0 then
        foreach(stbl, drawfs)
        if (fst<70) fsyum()
    end
	if sleep and state == "bounce" then
		foreach(atb,drawa)
		local myc=8+(fnum*0.25)%8
		pal(14,myc)
		spr(47,x-4,y-32)
		print("reset",x-10 ,y-40 ,myc)
		pal(14,14)
	end
	drawplaya()
    if state == "win" then
		foreach(dvds,drawdvd)
		pal(6,6)
		pal(1,1)
	end
	camera()
	namebar(121,7)
	if state == "bounce" then
		drawarrow()
	end

end

function drawarrow()
	local dirx = kx*0.01 - (camx + 64)*0.01
    local diry = 90*0.01 - (camy + 64)*0.01
    local len = sqrt(dirx * dirx + diry * diry)

    if len > 64*0.01 then
		local dircos, dirsin = dirx/len, diry/len
		local pointx, pointy
		local scrnx,scrny
		if abs(dirx)>abs(diry) then
			pointx=63.5+dirx/abs(dirx)*63.5
			pointy=63+diry/abs(dirx)*56
		else
			pointx=63.5+dirx/abs(diry)*63.5
			pointy=63+diry/abs(diry)*56
		end
		--pset(pointx,pointy,7)
		local crossptx,crosspty = pointx-dircos*5, pointy-dirsin*5
		local arrowax, arroway, arrowbx, arrowby = crossptx-dirsin*3.5, crosspty+dircos*3.5,  crossptx+dirsin*3.5, crosspty-dircos*3.5
		local arrowcolor = flr(fnum*0.2)%4+10
		line(arrowax,arroway,pointx,pointy,arrowcolor)
		line(arrowbx,arrowby,pointx,pointy,arrowcolor)
		line(arrowax,arroway,arrowbx,arrowby,arrowcolor)
		
    end
end

function namebar (yloc,lineclr)
	local ncolor=2+flr(fnum/20)%3
	rectfill(0, yloc+1, 128, yloc+3, lineclr)
	print(name,2-nameo, yloc, ncolor)
	print(name,2+nameln-nameo, yloc, ncolor)
	nameo+=1
end

function drawlvlscreen ()
	namebar(70,1)
	
	local strx=64-#wname*2
	print(wname, strx, 50)
	
	strx=64-#wnameb*2
	print(wnameb, strx, 40)
	
	local wnum="best: "..hiworld.."-"..hilevel
	strx=64-#wnum*2
	print(wnum, strx, 120)
	
	local mycolor=9+rnd(7)
	
	wnum=worldcount.."-"..lvlcount
	strx=#wnum*2
	rectfill(62-strx,58,64+strx,66,1)
	print(wnum, 64-strx, 60, mycolor)
	
	pal(14,mycolor)
	drawsprkl(86,62)
	drawsprkl(42,62)
	pal(14,14)
	
end

function setworldname()
	wnameb=""
	if worldcount==1 then
		wname="pleasant pastures"
	elseif worldcount==2 then
		wname="so-sleepy suburbs"
	elseif worldcount==3 then
		wname="cool kid city"
	elseif worldcount==4 then
		wname="the power plant"
	elseif worldcount==5 then
		wname="ferny forest"
	elseif worldcount==6 then
		wname, wnameb="badlet basecamp", "mt bado"
	elseif worldcount==7 then
		wname, wnameb="crevice caverns", "mt bado"
	elseif worldcount==8 then
		wname, wnameb="burr burr glacier", "mt bado"
	elseif worldcount==9 then
		wname ,wnameb="prettyhigh peak", "mt bado"
	elseif worldcount==10 then
		wname, wnameb="giant gates", "castle von bado"
	elseif worldcount==11 then
		wname, wnameb="grand hall", "castle von bado"
	elseif worldcount==12 then
		wname, wnameb="tiptop tower", "castle von bado"
	elseif worldcount==13 then
		wname, wnameb="vertical vortex", "above castle von bado"
	elseif worldcount==14 then
		wname, wnameb="above the earth", "outer space"
	elseif worldcount==15 then
		wname, wnameb="wonky wormhole", "outer space"
	elseif worldcount==16 then
		wname="the diamond realm"
	elseif worldcount==17 then
		wname, wnameb="spiral of unspeakable truths", "eternity"
	elseif worldcount==18 then
		wname, wnameb="an infinite expanse", "eternity"
	end
end

function bounce(lx,ly)
	vx, vy = vx*lx, vy*ly
	if vx>-0.01 and vx<0.01 then
		vx=0
	end

	local mag
	if lx < 0 then
		mag = abs(vx * 2)
		psquish(mag*mag,false)
        if abs(vx) > 0.2 then
            splode(mag)
        end
	else
		mag = abs(vy * 2)
		psquish(mag*mag,true)
        if abs(vy) > 0.2 then
            splode(mag)
        end
	end
end

function splode(mag)
    freezeframes += mag
    addp(x,y)
    sfx(hitsfx)
end


function cross_2d_vec(px, py, wx, wy)
  return px * wy - py * wx
end

-- takes two line segments [p to p+r] and [q to q+s] and finds intersection
-- returns scalar t such that p+t*r is the intersection point, else returns 100
function get_line_col(px, py, rx, ry, qx, qy, sx, sy)
  local r_cross_s = cross_2d_vec(rx, ry, sx, sy)
  if r_cross_s == 0 then
    return 100
  end
  local t = cross_2d_vec(qx - px, qy - py, sx, sy) / r_cross_s
  if t < 0 or t > 1 then
    return 100
  end
  local u = cross_2d_vec(qx - px, qy - py, rx, ry) / r_cross_s
  if u < 0 or u > 1 then
    return 100
  end
  -- double check bounding box incase overflow
  local pmaxx, pminx = px+rx, px
  if rx < 0 then
    pmaxx, pminx = px, px+rx
  end
  local qmaxx,qminx = qx+sx, qx
  if sx < 0 then
    qmaxx,qminx = qx, qx+sx
  end

  if pminx > qmaxx or pmaxx < qminx then
    return 100
  end

  return t
end

-- on collision returns true and moves player
function col_with_world(xstart, ystart, xdelta, ydelta)
  local closestcol = 1.00001
  local collided = false
  local horizontal = false
  local box_collided
  function test_box(box)
    -- top
    local t = get_line_col(xstart, ystart, xdelta, ydelta,
      box.x1, box.y1, box.x2 - box.x1, 0)
    if t < closestcol then
      closestcol,collided,horizontal,box_collided = t, true, true, box
    end
    -- right
    t = get_line_col(xstart, ystart, xdelta, ydelta,
      box.x2, box.y1, 0, box.y2 - box.y1)
    if t < closestcol then
      closestcol,collided,horizontal,box_collided = t, true, false, box
    end
    -- bottom
    t = get_line_col(xstart, ystart, xdelta, ydelta,
     box.x1, box.y2, box.x2 - box.x1, 0)
    if t < closestcol then
      closestcol,collided,horizontal,box_collided = t, true, true, box
    end
    -- left
    t = get_line_col(xstart, ystart, xdelta, ydelta,
     box.x1, box.y1, 0, box.y2 - box.y1)
    if t < closestcol then
      closestcol,collided,horizontal,box_collided = t, true, false, box
    end
  end
  local bletboxlist = {}
  foreach(blets, function(blet)
  						if blet.dead>=0 then
        	local box = get_blet_as_box(blet)
        	box.blet = blet
        	add(bletboxlist, box)
        end
      end)

  local kingbox = {}
  kingbox.x1, kingbox.x2, kingbox.y1, kingbox.y2, kingbox.king = kx-32, kx+32, 52, 200, true

  test_box(kingbox)
  foreach(bletboxlist, test_box)
  foreach(wtb, test_box)
  --check ground
  if ydelta ~= 0 then
  	local t = (112 - ystart)/ydelta
	if t >= 0 and t <= 1 then
		if t < closestcol then
			hitsfx = flr(rnd(17))
			x,y = xstart+xdelta*(t-.01), ystart+ydelta*(t-.01)
			bounce(.95,-.98)
			return true
		end
     end
  end

  if collided == true then
    x,y = xstart+xdelta*(closestcol-.01), ystart+ydelta*(closestcol-.01)
    
    if box_collided.blet then
        killbletobject(box_collided.blet)
		hburst(6,14)
		hitsfx=22
    elseif state ~= "win" and box_collided.king then
        state = "win"
        music(1)
		hburst(10,20)
		hitsfx=23
		addwintxt()
        show_bg_white = 20
        if freezeframes < 15 then
            freezeframes = 15
        end
    else
		hitsfx=flr(rnd(17))
	end
	
	if horizontal then
      bounce(0.97, -0.92)
    else
      bounce(-0.92, 0.97)
    end
	
    return true
  end
  return false
end

function lvlcountup()
	lvltot+=1
	lvlcount+=1
	if worldcount<18 then
		local lvlsperworld=min(1+worldcount,7)
		if lvlcount > lvlsperworld then
			lvlcount=1
			worldcount+=1
			setworldname()
		end
	end
	if worldcount>hiworld or (worldcount==hiworld and lvlcount>hilevel) then
		hiworld=worldcount
		hilevel=lvlcount
		dset(0, hiworld)
		dset(1, hilevel)
	end
end

function addp(nx,ny)
	local ps={}
	ps.sx,ps.sy, ps.prts, ps.life, ps.col = nx,ny, {}, 0, 4+flr(rnd(11))
	
	for i=0,12 do
		local prt, a, r = {}, rnd(1), rnd(3)
		prt.x, prt.y = nx+r*cos(a), ny+r*sin(a)
		a,r=rnd(1),rnd(1)
		prt.ix, prt.iy, prt.col = r*cos(a), r*sin(a), 9
		add(ps.prts,prt)
	end
	add(ptb,ps)
end

function dop(i)
	i.life+=1
	if i.life > 20 then
		del(ptb,i)
		return
	end
	for j in all(i.prts) do
		j.x+=j.ix
		j.y+=j.iy
	end
end

function addf(nx,ny,ang)
	local powah, foodo =2.5+rnd(1), {}
	foodo.x,foodo.y, foodo.vx,foodo.vy, foodo.num, foodo.age,foodo.life = nx-4,ny-4, -sin(ang)*powah, -cos(ang)*powah, 128+flr(rnd(16)), 0,15+rnd(15)
	add(ftb,foodo)
end

function dof(i)
	i.age+=1
	if i.age< i.life then
		i.vy+=0.18
		i.y+=i.vy
		i.x+=i.vx
	elseif i.age>i.life+30 then
		del(ftb,i)
	else
		local wow=(i.age-i.life)/4
		if wow <3 then
			i.num=164+wow
		else 
			i.num=-1
		end
	end
end

function foodsuck (cntrx,cntry)
	sfx(36)
	fsx,fsy,fst=cntrx, cntry, 100
end

function dofs()
	fst-=1
	foreach(stbl,succ)
	if fst>50 and fst%2==0 then
		makefs()
	end
end

function succ(i)
	i.a+=0.04
	i.d-=3
	if i.d<3 then
		del(stbl,i)
	end
end

function makefs()
	local foood={}
	foood.a,foood.d = rnd(10),90
	if rnd(1)>0.8 then
		foood.sp=-1
	else
		foood.sp=128+flr(rnd(16))
	end
	add(stbl,foood)
end

function drawfs(i)
	local myx, myy = fsx+(cos(i.a*0.1)*i.d), fsy+(sin(i.a*0.1)*i.d)
	if i.sp==-1 then
		circfill(myx-1,myy-1,1,4)
	else
		spr(i.sp,myx-4,myy-4)
	end
end

function fsyum()
	local myt, mypal = flr(fst*0.13)%5, 8+(fnum*0.34)%8
	if myt<4 then
		pal(10,mypal)
		spr(164+myt,fsx-4,fsy-4)
		pal(10,10)
	else
		print("yum!",fsx-6,fsy-3,mypal)
	end
end

function addhap()
	addh(x+rnd(9)+rnd(9)-9, y+rnd(9)+rnd(9)-9)
end

function addh (hx,hy)
	local hrt={}
	hrt.x, hrt.y, hrt.spr, hrt.age, hrt.life, hrt.rate = hx-4, hy-4, 144+flr(rnd(12)), 0, 80+rnd(80), 5+flr(rnd(20))
	add(htb,hrt)
end

function doh(i)
	i.age+=1
	if i.age>i.life then
		del(htb,i)
		return
	end
	if (i.age%i.rate==0) i.spr=144+flr(rnd(12))
end

function hburst(n,r)
	local stepo=1/n
	for i=0,n do
		addh(x+cos(i*stepo)*r, y+sin(i*stepo)*r)
	end
end

-- level flavaz
function levelmake()
	blets,wtb={},{}
	
	setflav()
	for i=0, 40+flr(sqrt(lvltot)*2) do
		wadd()
	end
	for i=0,blta do
		bletadd(0)
	end
	for i=0,bltb do
		bletadd(1)
	end
	for i=0,bltc do
		bletadd(2)
	end
	bbs=8+rnd(8)
	foreach(bbt,bbadd)
end

function wadd()
	local box={}
	box.x1, box.y1 = flr(50+rnd(1450)), flr(110-rnd(lvlh))
	if rnd(1)>0.3 then
		box.x2, box.y2 = flr(box.x1+w1b+rnd(w1r)), flr(box.y1+h1b+rnd(h1r))
	else
		box.x2, box.y2 = flr(box.x1+w2b+rnd(w2r)) , flr(box.y1+h2b+rnd(h2r))
	end
	add(wtb,box)
end

function bbadd(i)
	local box={}
	if i==0 then 		--lil block
		box.y2=96-(rnd(30)+rnd(70))
		local xrng=41-box.y2
		xrng=max(min(xrng,16),4)
		box.x2 = -16 + rnd(xrng + 16)
		box.x1, box.y1 = box.x2-bbs, box.y2-bbs
	elseif i==1 then 	-- big block
		box.x2, box.y2 = 6-rnd(rnd(64)), 82-(rnd(30)+rnd(80))
		box.x1, box.y1 = box.x2-(bbs*3.24), box.y2-(bbs*2)
	else 				-- column
		box.x2, box.y1, box.y2 = 4-rnd(rnd(64)), 24+rnd(72), 118
		box.x1=box.x2-(bbs*(1+rnd(4)))
	end
	box.x1, box.x2, box.y1, box.y2 = flr(box.x1), flr(box.x2), flr(box.y1), flr(box.y2)
	add(wtb,box)
end

function setflav()
	local rpfx
	if rnd(1)>0.5 then
		rpfx=0
	else
		rpfx=1+flr(rnd(rnd(16)))
	end
	local x=min( 10, lvltot*0.15)
	
	local rpro, rdsh, rsfx = flr(rnd(5+x+rnd(13-x))), flr(rnd(5+x+rnd(13-x))), 0

	if lvltot>3 and rnd(1)> 1/(1+lvltot*0.15) then
		rsfx=1+flr( rnd( x+rnd(7) ))
	end

	setprefix(rpfx)
	setprotein(rpro)
	setdish(rdsh)
	setsuffix(rsfx)
	name, nameo = name.." ê ááá ê ", 0
	nameln= (#name+5)*4
	if nameln<128 then
		name=name..name
		nameln*=2
	end
end

function setprefix(i)
	if i==0 then
		name, bbt = "",{0}--0:lil box, 1:big block, 2:column
	elseif i==1 then
		name, bbt = "spicy ",{1}
	elseif i==2 then
		name, bbt = "sweet ",{2}
	elseif i==3 then
		name, bbt = "double ",{0,0}
	elseif i==4 then
		name, bbt = "fried ",{0,2}
	elseif i==7 then
		name, bbt = "seared ",{0,1}
	elseif i==6 then
		name, bbt = "sweet & spicy ",{2,1}
	elseif i==8 then
		name, bbt = "extra spicy ",{1,1}
	elseif i==12 then
		name, bbt = "triple ",{0,0,0}
	elseif i==9 then
		name, bbt = "jumbo ",{1,1,2}
	elseif i==5 then
		name, bbt = "crispy ",{0,0,2}
	elseif i==11 then
		name, bbt = "slowcooked ",{0,2,1}
	else
		name, bbt = "super ",{1,1,1}
	end
end

function setdish(i)
	bgcolor, lvlh = 1+(i%5), 260
	if i==0 then
		name,w1b,w1r,h1b,h1r = name.."sandwich ",10,70,25,15
	elseif i==1 then
		name,w1b,w1r,h1b,h1r = name.."burrito ",15,40,15,40
	elseif i==2 then
		name,w1b,w1r,h1b,h1r,lvlh = name.."pasta ",15,65,10,4,220
	elseif i==3 then
		name,w1b,w1r,h1b,h1r,lvlh = name.."stirfry ",15,30,15,30,235
	elseif i==4 then
		name,w1b,w1r,h1b,h1r,lvlh = name.."taco ",25,20,30,10,250
	elseif i==5 then
		name,w1b,w1r,h1b,h1r,lvlh = name.."burger ",25,30,10,50,275
	elseif i==6 then
		name,w1b,w1r,h1b,h1r = name.."pizza ",30,4,30,4
	elseif i==7 then
		name,w1b,w1r,h1b,h1r = name.."salad ",15,20,10,40
	elseif i==8 then
		name,w1b,w1r,h1b,h1r,lvlh = name.."ramen ",20,70,6,2,230
	elseif i==9 then
		name,w1b,w1r,h1b,h1r = name.."stew ",8,50,8,40
	elseif i==10 then
		name,w1b,w1r,h1b,h1r = name.."soup ",10,40,6,55
	elseif i==11 then
		name,w1b,w1r,h1b,h1r = name.."caesar salad ",16,0,20,40
	elseif i==12 then
		name,w1b,w1r,h1b,h1r,lvlh = name.."quesadilla ",20,4,25,40,275
	elseif i==13 then
		name,w1b,w1r,h1b,h1r = name.."panini ",10,60,20,5
	elseif i==14 then
		name,w1b,w1r,h1b,h1r = name.."calzone ",30,10,18,10
	elseif i==15 then
		name,w1b,w1r,h1b,h1r,lvlh = name.."dumpling ",10,5,20,70,300
	elseif i==16 then
		name,w1b,w1r,h1b,h1r = name.."cake ",8,2,15,70
	else
		name,w1b,w1r,h1b,h1r = name.."curry ",14,70,6,30,250
	end
end

function setprotein(i)
	kx=900+i*15
	if i==0 then
		name, w2b, w2r, h2b, h2r = name.."chicken ",15,5,10,5
		setplt(8,9,10,11,12)
	elseif i==1 then
		name, w2b, w2r, h2b, h2r = name.."turkey ",10,8,10,8
		setplt(9,10,11,12,13)
	elseif i==2 then
		name, w2b, w2r, h2b, h2r = name.."beef ",15,10,6,20
		setplt(8,9,10,13,14)
	elseif i==3 then
		name, w2b, w2r, h2b, h2r = name.."bacon ",6,10,6,40
		setplt(10,11,12,13,14)
	elseif i==4 then
		name, w2b, w2r, h2b, h2r = name.."tofu ",20,2,14,2
		setplt(15,14,10,9,13)
	elseif i==5 then
		name, w2b, w2r, h2b, h2r = name.."pork ",6,20,6,20
		setplt(8,9,10,11,13)
	elseif i==6 then
		name, w2b, w2r, h2b, h2r = name.."egg ",10,4,14,6
		setplt(8,9,10,6,7)
	elseif i==7 then
		name, w2b, w2r, h2b, h2r = name.."blackbean ",10,4,20,6
		setplt(6,7,11,12,13)
	elseif i==8 then
		name, w2b, w2r, h2b, h2r = name.."duck ",10,5,8,30
		setplt(8,9,6,12,13)
	elseif i==9 then
		name, w2b, w2r, h2b, h2r = name.."tempe ",20,5,8,10
		setplt(8,9,10,14,15)
	elseif i==10 then
		name, w2b, w2r, h2b, h2r = name.."lamb ",25,10,8,2
		setplt(7,8,9,10,13)
	elseif i==11 then
		name, w2b, w2r, h2b, h2r = name.."mushroom ",12,0,12,0
		setplt(8,9,10,13,14)
	elseif i==12 then
		name, w2b, w2r, h2b, h2r = name.."steak ",10,5,15,30
		setplt(9,9,14,12,15)
	elseif i==13 then
		name, w2b, w2r, h2b, h2r = name.."beef tongue ",15,20,6,10
		setplt(10,11,8,15,6)
	elseif i==14 then
		name, w2b, w2r, h2b, h2r = name.."chicken heart ",20,5,10,10
		setplt(11,12,13,14,15)
	elseif i==15 then
		name, w2b, w2r, h2b, h2r = name.."bison ",20,0,9,30
		setplt(8,10,12,13,14)
	elseif i==16 then
		name, w2b, w2r, h2b, h2r = name.."chickensteak ",9,10,19,5
		setplt(9,11,13,15,6)
	else
		name, w2b, w2r, h2b, h2r = name.."ostrich ",20,10,20,10
		setplt(0,5,6,7,11)
	end
end

function setplt(a,b,c,d,e)
	plt[0],plt[1],plt[2],plt[3],plt[4]=a,b,c,d,e
end

function setsuffix(i)
	blta,bltb,bltc=-1,-1,-1

	if (i==0) return
	if i==1 then
		name,bltc = name.."w cheese", 3
	elseif i==2 then
		name,blta = name.."w chips", 5
	elseif i==3 then
		name,bltb = name.."w fries",4
	elseif i==4 then
		name,blta,bltc = name.."w egg",3,2
	elseif i==5 then
		name,blta,bltb = name.."w butter",4,3
	elseif i==6 then
		name,blta = name.."w sauce",10
	elseif i==7 then
		name,bltc = name.."extra cheese",7
	elseif i==8 then
		name,bltb = name.."w salad",9
	elseif i==9 then
		name,blta,bltb,bltc = name.."w soup",5,3,2
	elseif i==10 then
		name,blta,bltb = name.."no cheese",4,8
	elseif i==11 then
		name,bltb,bltc = name.."w slaw",4,6
	elseif i==12 then
		name,blta = name.."extra sauce",18
	elseif i==13 then
		name,bltb,bltc = name.."w potato wedges",10,2
	elseif i==14 then
		name,blta,bltc = name.."w hardboiled egg",2,6
	elseif i==15 then
		name,blta,bltb,bltc = name.."w soup",6,6,6
	elseif i==16 then
		name,bltc=name.."w poached egg",18
	end
end

----spring----
function psquish(f,h)--force, is horizontal
	if (f<0.5) return
	spx,spv,sps=1-1/(1+(f*0.025)), 0, 0.05+rnd(0.1)
	if (h) spx*=-1
end

function updatespring()
	if spv>=0.01 then--friction
		spv-=0.01
	elseif spv<=-0.01 then
		spv+=0.01
	end
	
	spv+=spx*sps
	spx-=spv
	if abs(spx)<0.02 and abs(spv)<0.03 then
		spx,spv=0,0
	end
end
function ceil(num)
  return flr(num+0x0.ffff)
end

function get_blet_as_box(blet)
    local box = {}
    box.x1, box.x2, box.y1, box.y2 = blet.x, blet.x+blet.bw, blet.y, blet.y-blet.bh
    return box
end

function bletadd(i)
	local let={}
	let.x, let.y, let.food, let.dead = 0,0,2+i,0
	if i==0 then
		let.bs, let.bw, let.bh = 77,16,16
	elseif i==1 then
		let.bs, let.bw, let.bh = 13,16,32
	else
		let.bs, let.bw, let.bh = 73,32,32
	end
	for i=0,10 do
		if rnd(1)>0.7 then -- on floor
			let.x,let.y = 48+flr(rnd(820)),116
		else -- on box
			local w=wtb[1+flr(rnd(#wtb))]
			let.x, let.y = w.x1+flr(rnd(w.x2-w.x1)), w.y1
			let.x -= let.bw*0.5
		end
		if checkblet(let) then
			add(blets,let)
			return
		end
	end
end

function killbletobject(blet)
	local xstep=1/blet.food--stratify placement
	for i=0,blet.food-1 do
		addf(blet.x+blet.bw*(i*xstep+rnd(xstep)), blet.y-rnd(blet.bh*.5)+rnd(blet.bh*.5), 0.1*((xstep*i)-0.5))
	end
    blet.dead=1
end

function bletrespawn()
	for i=1,#blets do
		blets[i].dead=0
	end
end

function checkblet(b)--false if blet overlaps block/another blet/the king
	for w in all(wtb) do
		if w.x1<b.x+b.bw and b.x<w.x2 and w.y1<b.y and b.y<w.y2+b.bh then
			return false
		end
	end
	for i in all(blets) do
		if i!=b and abs(i.x-b.x)<32 and abs(i.y-b.y)<32 then
			return false
		end
	end
	if kx-32<b.x+b.bw and kx+32>b.x and 52<b.y and 116>b.y+b.bh then
		return false
	end
	return true
end

function updateblet(i)
	if i.dead>0 then
		i.dead+=1
		if i.dead%5==2 then
			addp(i.x+rnd(i.bw),i.y-rnd(i.bh))
		end
		if i.dead>20 then
			i.dead=-1
		end
	end
end

function drawplaya()
	local pw, ph = 3+ceil(5*(1-spx)*(1-spx)), 3+ceil(5*(1+spx)*(1+spx))
	sspr(0,8,8,8, x- pw*0.5, y- ph*0.5, pw,ph)
end

function drawblet(i)
	if (i.dead<0) return
	spr(i.bs, i.x, i.y-(i.bh), i.bw/8, i.bh/8, kflip)
end

function drawbox(i)
	rectfill(i.x1 + 1,i.y1 + 1,i.x2-2,i.y2-2,bcol)
	
	pal(8,gcol)
	local widt, cursrx, cursry, sprito = i.x2-i.x1-2, i.x1+1, i.y1-4, 218+worldcount*2
	if widt>16 then
		for j=1,flr(widt/16) do
			spr(sprito, cursrx ,cursry, 2,1)
			cursrx+=16
		end
	end
	spr(sprito, cursrx, cursry, (widt%16)/8, 1)
	pal(8,8)
end

function drawbgtiles()
	if show_bg_white > 0 then
        if sin(show_bg_white/(5 + (20 - show_bg_white)/10)) > 0 then
            pal(0, 7)
        end
        show_bg_white -= 1
    end
	pal(1,bgcolor)
	

	local cur_t_x = camx-(camx*0.85%32)
	while cur_t_x < (camx + 128) do
		local cur_t_y = camy-(camy*0.85%32)
		while cur_t_y < (camy + 128) do
			spr(9, cur_t_x, cur_t_y, 4, 4)
			--sspr(72, 0, 32, 32, cur_t_x, cur_t_y, 64, 64)
			cur_t_y += 32
		end
		cur_t_x += 32
	end
	
    pal(0,0)
	pal(1,1)
end

function drawp(i)
	if i.life <= 1 then
		circfill(i.sx,i.sy,8,7)
		return
	end
	local pcol, size = 7+flr(rnd(8)), ceil((21-i.life)/6)
	circ(i.sx,i.sy,i.life,i.col)
	for j in all(i.prts) do
		circfill(j.x,j.y,size,pcol)
	end
end

function drawcoil()
	local sina, cosa = sin(angle*12)*5, cos(angle*12)*5
	if sina>0 then
		sina=flr(sina)
	else
		sina=ceil(sina)
	end
	if cosa>0 then
		cosa=flr(cosa)
	else
		cosa=ceil(cosa)
	end
	circfill(11,105,5,3)
	line(11+cosa,105+sina,11-cosa,105-sina, 11)	
	circ(11,105,5,11)
end

function drawspiral (cx,cy,len,offs)
	local j
	for i=0,len,0.1 do
		j=i*0.13
		pset(cx-sin(j-offs)*(3+j*2), cy-cos(j-offs)*(3+j*2), 8+(i*0.4+fnum*0.1)%5)
	end
end

function drawfood(i)
	if i.num> 0 then
		spr(i.num,i.x,i.y)
	else
		print("yum!",i.x-4,i.y+2,8+(fnum*0.34)%8)
	end
end

function drawh(i)
	spr(i.spr,i.x,i.y)
end

function aadd()
	local mya={}
	mya.c, mya.t, mya.p = rnd(16), 1, flr(rnd(20))
	if mya.p>12 then
		mya.p=-1
	end
	add(atb,mya)
end

function drawa(i)
	local cool=i.t*0.1
	circfill(x,y,cool*cool,i.c)
end

function doa(i)
	i.t+=1
	if i.t>112 then
		del(atb,i)
	elseif i.p>0 and fnum%i.p==0 then
		i.c=(i.c+4)%16
	end
end

function addwintxt()
	wtltr, wtx, wty, dvds = 0, x-4, y-4, {}
	adddvds()
end

function checkwintext()
	if (wtltr>=6) return
	wtcount+=1
	if wtcount>9 then
		adddvds()
	end
end

function adddvds()
	local spri=wtltr+203
	if (spri>205) spri-=1
	adddvd(1,1,spri)
	adddvd(-1,-1,spri)
	wtltr+=1
	wtcount=0
end
	
function adddvd(myvx,myvy,myspr)
	local dvd={}
	dvd.x, dvd.y, dvd.t, dvd.age, dvd.vx, dvd.vy = wtx, wty, myspr, 0, myvx, myvy
	add(dvds,dvd)
end

function dodvd(i)
	i.x+=i.vx
	if (i.vx>0 and i.x >= kx+56) or (i.vx<0 and i.x <= kx-64) then
		i.vx*=-1
	end
	i.y+=i.vy
	if (i.vy>0 and i.y >= 112) or (i.vy<0 and i.y <= 0) then
		i.vy*=-1
	end
	i.age+=1
end

function drawdvd(i)
	pal(1, 8+(i.age*0.1)%8 )
	local ok=flr((i.age*0.25)%6)
	if (ok>3) ok=6-ok
	if (ok>0) ok+= 4
	pal(6,ok)
	spr(i.t, i.x, i.y)
end

function makestrfld()
	local star={}
	star.x, star.y, star.z = rnd(500)-250, rnd(500)-250, 100
	add(strfld,star)
end

function drawstrfld(i)
	local coolnum=1-sqrt(i.z)*0.09
	pset(64+i.x*coolnum, 64+i.y*coolnum, 8+rnd(8))
end

function dostrfld()
	foreach(strfld,dostrf)
	makestrfld()
end
	
function dostrf(i)
	i.z-=1.2
	if i.z<=0 then
		del(strfld,i)
	end
end

function drawsprkl(sx,sy)
	spr(144+flr(fnum*0.1)%12, sx-4, sy-4)
end

function drawtitlescreen()
	if (titlest>0) then
		circ(64,64,94-titlest*3,7+rnd(5))
	end
	local mycolor=8+flr(rnd(8))
	foreach(strfld,drawstrfld)
	drawtitle()
	namebar(90+titlest*2,1)
	pal(14,mycolor)
	spr(31,8,112 + titlest)
	print("êangle", 18, 113 + titlest*0.8)
	spr(15,82,112+titlest)
	print("êpower", 92, 113+titlest*0.8)
	spr(47,25,120+titlest*0.5)
	print("êlaunch / retry", 35, 121+titlest*0.34)
	pal(14,14)
	print("êêê  press z  êêê", 18, 102+titlest*3, mycolor)
end

function drawtitle()
	local drawarray, sprialnode = {}, {}
	for i=0,10 do
		local node = {}
		node.type, node.i, node.x, node.y, node.z = 0, i, 60+50*cos(-1*fnum/200+i/25), 40+10*sin(i/10+-1*fnum/40)+10*sin(-1*fnum/200+i/20), -1 * sin(-1 * fnum/200 + i/20)
		add(drawarray, node)
	end
	
	sprialnode.type, sprialnode.z = 1,0
	add(drawarray, sprialnode)
	
	local cubenode = {}
	cubenode.type,cubenode.x, cubenode.y, cubenode.z  = 2, 60+50*cos(-1*fnum/200-2/25), 48+10*sin(-2/10-1*fnum/40)+10*sin(-1*fnum/200-2/20)-titlest*2, -1*sin(-1*fnum/200-2/20)
	cubenode.size = 6 - cubenode.z - sin(-2/10 + -1 * fnum/40)
	add(drawarray, cubenode)
	cubenode = {}
	cubenode.type,cubenode.x, cubenode.y, cubenode.z  = 2,60+50*cos(-1*fnum/200+12/25), 48+10*sin(12/10-1*fnum/40)+10*sin(-1*fnum/200-12/20)-titlest*2, -1*sin(-1*fnum/200+12/20)
	cubenode.size = 6 - cubenode.z - sin(12/10 + -1 * fnum/40)
	add(drawarray, cubenode)
	drawarray = bubblesort(drawarray)

	for j=1,#drawarray do 
		local node = drawarray[j]
		if node.type == 0 then
			pal(9, 8+(0.1*(j+fnum))%8)
			pal(10, 8+(0.21*(j+fnum))%8)
			pal(13, 1+(0.13*(j+fnum))%5)
			spr(192 + node.i, node.x, node.y-titlest*2, 1, 2)
		elseif node.type == 1 then
			local spiraly= 10 * sin(fnum/155) +40-titlest*1.5
			circfill(64,spiraly,12,1)
			drawspiral(64, spiraly ,35 + 5 * sin(fnum/400),fnum*-0.01)
		elseif node.type == 2 then
			drawcube(node.x, node.y-titlest, node.size)
		end
	end
	pal(9,9)
	pal(10,10)
	pal(13,13)
end
__gfx__
777bbb77777777777877787778777877787778777877787778777877787778777777777711111111000000000000000011111111778888888888777777eeee77
77b111b777777777818781878187818781878187818781878187818781878187777777771111111010000000000000010111111178111111111187777ee77ee7
77b121b77777777781181118111811181118111811181118111811181118118777777777111111001100000000000011001111118011111111111877ee7777ee
77b111b77777777781111111111111111111111111111111111111111111118777777777111110001110000000000111000111118000188111111187eeeeeeee
7bbbbb337777777781111111111111111111188888811111111111111111118777777777111100001111000000001111000011118880011111111118eeeeeeee
777bb3777777777781111111111111888888881111888888881111111111118777777777111000001111100000011111000001118008001111111118ee7777ee
77bbb33777778777811111111111111111111818818111111111111111111187778777771100000011111100001111110000001180008011111881187ee77ee7
77b77737777778778888888888888888818888111188881888888888888888877877777710000000111111100111111100000001800080181180111877eeee77
778888777777888780001111111111111111111111111111111111111111118788877777011111110000000110000000111111108cc088881800011877eeee77
781111877777777880001111111111111111111111111111111111111111118877777777001111110000001111000000111111008cc00011100cc1187eeeeee7
811111087777888880001111111111111111111111111111111111111111118888877777000111110000011111100000111110008001088811100108ee7ee7ee
818111887777777780001111111111111111111111111111111111111111118777777777000011110000111111110000111100008011811181111087e77ee77e
811188087777888880001111111111111111111111111111111111111111118888877777000001110001111111111000111000008011111181110877e77ee77e
811111087777777780001111111111111111111111111111111111111111118777777777000000110011111111111100110000008001100111108777ee7ee7ee
7818808777778888800011111111111111111118811111111111111111111188888777770000000101111111111111101000000078000000000877777eeeeee7
78877887777777800000001111111811111111111111111111111111111000000877777700000000111111111111111100000000778888888888888877eeee77
77777777777888800111111111111181111111888811111111111111110000000888877700000000111111111111111100000000777800002222222877eeee77
77777777778111800111111111111180111118ccc08111111111111110088880081118770000000101111111111111101000000088880000222888287eeeeee7
77777777781111800111111111111180111180c0c0081111000000000081111008111187000000110011111111111100110000008000000888287828ee7777ee
77777777781111800111888888888880111800ccc0008111088888888801111108111187000001110001111111111000111000008088880818287888eeee7eee
777777777811118001110000008000001111800000081110080008110000111118111187000011110000111111110000111100008888180818888818eee7eeee
777777777811118001188888808000001111188888811118880808188888881118111187000111110000011111100000111110008188180811111118ee7777ee
7777777778011180018c0c008081111111111111111111110008081800c0c081181110870011111100000011110000001111110081881808888888887eeeeee7
7777777777801180080ccc008081111110001118811111111000081800ccc0081811087701111111000000011000000011111110818818002228777777eeee77
77777777777811808000000800818881188001111111188111088811800000081811877710000000111111100111111100000001811118002228777777777777
77777777777811808888888000811111111800111111811111811181188888881811877711000000111111000011111100000011888888002228777777777777
77777777777811800111111000811188811180011118111118111118111111111811877711100000111110000001111100000111887780002228778877777777
77777777778111800111111000081111111118011181111181111111111888888811187711110000111100000000111100001111808788888888780877777777
77777777781111888888888888008111888118011181111811111111111100008000118711111000111000000000011100011111800881111118800877777777
77777777811000008000000000800811111108011180111811111118811110008011111811111100110000000000001100111111800111111111100877777777
77777777811110088111110011180081111008011180011801111180011111008001111811111110100000000000000101111111800111111111100877777777
77777777811100878188880011118008118888011188881800111800018888808800111811111111000000000000000011111111888888888888888877777777
77777777800008778111110011111800818001111101181800018880011111118780111877788888888888888888888888887777777888888888887777777777
77777777888887778188810088888880818001111111181888888cc8011888818778888877811111111111111111111111118777778101011111118777777777
7777777777777777801111080c0c008081888888888888111800c0c0811111118777777777801111111111118881111111111877780111110811001877777777
7777777777777777800111800ccc008081111111111111181800ccc0081111118777777777811111111111111811111111111877800011110810081877777777
77777777777778888000118000000810111111111111111818800000081111118877777777801111111181111110118111111877808011188810801877777777
777777777777822280000188888881101118888888888111180888888811811182877777778111111111081111001801181118888008111111110cc877777777
777777777778222288811111111111011180cc0cc0cc08111800111111181111822877778881188881111081110080018001181880c0811888111cc877777777
7777777777822222228118888111101118000000000000811888888888811888822287778181111118111181110080180ccc1018800001811181100877777777
7777777778022222228011111111111188888888888888881111111111110822222208778111111111811181110081100c0c1008780011111111008777777777
77777777780222222280018888111111111111111111111111111181818008222222087781010cc011111188888881100ccc1008808000000000887777777777
77777777780222222228001111111111111111111111111111111111110082222222087780018888111111111111111100011808808822222228888877777777
77777777780222222222800111118888888888811118011111111111100822222222087780811111111118888881111111111808800222222222000877777777
77777777780222222222280000082222222222280008000000000000008222022222087780801111111181111118111111110888888822222228880877777777
77777777780222222222228888822222222222228888888888888888882220082222087788800000111181100018111101100877781822222228188877777777
77777777780222222280222228222222222222222822222222222222222200082222087777888011111011111111011000000877781111111111187777777777
77777777780222222280022282222222222222222282288888888882222000082222087777780001111001111110010008008087788888888888887777777777
77777777780222222888888822222222222222222228281111122228220000082222087777778000111111111011100008880008777777777777777777777777
77777777780222222222222222222222222222222228288881122222800000082222087777780800011111111011000080002228777777777777777777777777
77777777780022222222222222222222222222222228222281122222288888888222087777800080001111111110000800222228777777777777777777777777
77777777780002222222222222222222222222222228288881122222222222222222087777822008000000000000008800222228777777777777777777777777
77777777778000222222222222222000002222222228281111122222222222222220087778222220888888888888880800022228777777777777777777777777
77777777777800022222222222220000000222222228288881122222222222222200087778022220000000000000000080002228777777777777777777777777
77777777777780002222222222200088880022222228222281100022222222222000087778022228000002222222888008822208777777777777777777777777
77777777777778000222222222000822281111111118288881100002222222220000877778002222800022222228228008222008777777777777777777777777
77777777777777800000000000008222281111111118281111100000222222200008777778000222288222888228028882220087777777777777777777777777
77777777888777780000000000082222281888188818288888888000222222000087788877800022222888228228002222200087777777777777777777777777
77777777822877778888888888822222281828182818222222228000000000000877822877780000222222208222800000000877777777777777777777777777
77777777822287777780000222222222281828182818222222228000000000008778002877778000000000082222280000088777777777777777777777777777
77777777822228888881111111111111188818881888111111111800000000088882222878877800000008822222228888878877777777777777777777777777
77777777820228111111111111111111111111111111111111111188888888811182222878288888888881111111111188882877777777777777777777777777
77777777800008111111111111111111111111111111111111111111111111111180000878220111111111111111111110022877777777777777777777777777
77777777888888888888888888888888888888888888888888888888888888888888888878888888888888888888888888888877777777777777777777777777
77711777771111777777777799777777711711777711177777111177777711777777111777777177777117777111111771171177777711177777117777777777
771ee1777199991777111177979777777191917771899177719999177711917777719881777119177718177714444441719199177771eee17711e91777711777
71ee88171999999171999917977971177719177718889917199994417189881777198891771ee1917188117714444991771991777771ee8171eeee91771ee177
71888817149999411998899179771e817188817718e89941199444411ee888817198894171eee8171888881714499e8171888817771ee8811eeeee9171eee817
77194177184444e1199889417117188118e8881718e8944171eee8171eeee8811988944171ee881711189881199ee99118ee888171198117188888411ee44881
7719417714888e41149994411e817117188888171888441771eee81718ee8881188944171ee881777718888118e9911718e88881199117771444444118844881
7714177771444417714444171881777771888177718441777711117771888817184441771e81177777718e811991177771888817119177771888884171111117
77717777771111777711117771177777771117777711177777777777771111777111177711177777777711177117777777111177711777771111111777777777
777777777777777777777777777777777777777e77777777777777777e77e77e7777777777777777777777777777777777777777777777777777777777777777
77ee7ee777ee7ee7777777777777e777777777e777777e7777e7e7e777e777e77777777777777777777777e77777e77777777777777777777777777777777777
7eeeeeee7e77e77e77ee7ee77777e7777777e7777777eee7777e7e77777777777777e777777ee777777e7e7777e7e7e777777777777777777777777777777777
7eeeeeee7e77777e77eeeee777ee7ee7777eee7777777e7777e777e77e77777e777eee7777eeee777777e777777eee7777777777777777777777777777777777
77eeeee777e777e7777eee777777e7777777e77777e77777777e7e77777777777777e77777eeee77777e7e7777e7e7e777777777777777777777777777777777
777eee77777e7e777777e7777777e77777e777777eee777777e7e7e777e777e777777777777ee77777e777777777e77777777777777777777777777777777777
7777e7777777e77777777777777777777e77777777e77777777777777e77e77e7777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
7777777777777777777777777777777777777777777777777a77a77a777777777777777777777777777777777777777777777777777777777777777777777777
7779a77777779a7777a77a7777aa77777777777777a7a7a777a777a7777777777777777777777777777777777777777777777777777777777777777777777777
77aaaa777aaaaa7779aaaa97779aaaa77777a777777a7a7777777777777777777777777777777777777777777777777777777777777777777777777777777777
79a33aa779a33a7777933a7777933a97777aaa7777a777a77a77777a777777777777777777777777777777777777777777777777777777777777777777777777
79a33a9777933aa777933a7779a33a777777a777777a7a7777777777777777777777777777777777777777777777777777777777777777777777777777777777
779aaa77779a999779a99aa77999aa777777777777a7a7a777a777a7777777777777777777777777777777777777777777777777777777777777777777777777
7779977777997777779779777777997777777777777777777a77a77a777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
76666667766666677766666777666667776666677766666776666667766666677666666776666667766666777666667776666677766666777666666776666667
66666665666666657666666576666665766666657666666566666666666666656666666666666666666666676666666766666667666666676666666666666665
66066605666066607666066576666065766666067666666066666665666666656666666566666665066666576066665766066657666066570666066560666065
76665657766665657766665577666665776666657766666576666555766665577666555766666557666655776666657756665577566655776656655776656657
77666677777666577777666577776655777666667775556677666557776655777766557776555577665577776665577766667777666577777666577777666577
77767577777767577777767577777775777777567777755677775557777555777755577776557777655777776577777767777777676777777676777777676777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777111777777777777777777777777777777777777777777777777777777776666766676666667666766666666666766666677
11111777771117777771111777771ad1771117777111111777777777777777777777777771111177777111776116761676111167611661166111116761111167
1aaad17771aad1777771ad1711771ad171aad1771aaaad1777777777777777777777777771aaad17771aad176116661676611667611161166166666761166116
1aaaad171aaaad171111ad171d171ad11aaaad171aaaad1777777777777777777777777771aaaad171aaaad16116161677611677611111166111677761166116
19d19d1719999d1719d19d1719d119d119999d1719d11177777777777777777777777777719d19d1719d19d16116161677611677611111166166666761111167
1ad1ad171ad1ad171ad1ad171aad1ad11ad1ad171ad1777771111777771117777111111171ad1ad171ad1ad16116161676611667611611166111116761166116
19999d1719d19d1719d19d171999d9d119d1111719d1117771aaa17771aaa1771aaaaad1719d19d1719999d16111111676111167611661166111116761166116
1999d17719d19d1719d19d17199999d119d177771aaad17771911917191119171119d117719999d177199d176666666676666667666676666666666766676666
1aaaad171ad1ad171ad1ad171aaaaad11ad177771999d17771a171a11a171a17771ad17771aaad1771aaaad17777777777777777777777777777777777777777
19999d1719d19d1719d19d1719d999d119d1777719d1177771917191191719177719d177719d1177719d19d17777777777777777777777777777777777777777
19d19d1719d19d1719d19d1719d199d119d1111719d17777719111d119111d177719d177719d1777719d19d17777777777787777787778787777777777777777
19d19d1719d19d1719d19d1719d119d119d19d1719d177777199dd17719dd1777719d177719d1777719d19d17777777778787878787878788787878787878787
19d19d1719999d1719999d1719d171d119999d1719d11117711111777711177777111177719d1777719d19d17777777788888888888888887777777777777777
19999d1719999d1719999d1719d1771119999d1719999d17777777777777777777777777719d1777719999d17777777777777777777777778888888888888888
1999d1777199d17771999d1719d177777199d17719999d17777777777777777777777777719d177777199d177777777777888877778888777878787878787878
11111777771117777711111711177777771117771111117777777777777777777777777771111777777111777777777788777788887777888787878787878787
77777777777777777777777777777777777777777777777777777777777777777777777777777877777777777777777777777777777777777777877777877777
77777777777777777777777777777777787778777777778777777777777777777777777777778787777777777777777777777777777777778778787877777877
77777777777777778888888888888888787777877787787777877777777778777777787777787778777777777777777777777778777787777777878787778787
77777777777777778777877787778777787777877787787777878778787878788777878777877777777877778787777777878778877888777777877877777877
77777777777887778777877787778777787887878787887887888788787888787878777878777777888888888888888877777777777777777777877877777877
88888888888888887878787878787878888888888888888877777777777777777877888778778887888888888888888887878787878787878888888888888888
77777777777777778787878787878787878778787878778777777777777777778778887787788877887888788878887878787878787878787777777777777777
88888888888888887778777877787778787777878787777888888888888888887788877877888778877787778777877787878787878787877878787878787878
77787788877877787877787778777877877787778777877777777777777777777787778777877787777777777777777778777877787778777777777777777777
77878778778787778787878787878787787878787878787877777777777777777778787777787877777777777787777777777777777777777777777777777777
78878877788788778788878787888787778777877787778777777777777777777787778777877787777877777888777778787878787878787778887777788777
87878787878787878787878887878788877787778777877777777777777777777877777878777778778887778888877777777777777777777777777777777777
87878787878787878787878787878787787878787878787877888887777788877787778777877787888888888888888878787878787878787788887777888877
77777777777777777777777777777777777777777777777788787878888878787777777777777777777777777777777777777777777777778878878888788788
77888877778888777888788878887888788878887888788887878787878787877887787878877887787778777877787787877878877887877877778778777787
78777787787777877878787878787878887888788878887878787878787878788778878787788778878887888788878887887878778787777788887777888877
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
010100000d64014340217400c7400c7400c7402e3401b3402b740267401d340217401d7401374011340103401074010330157300f720127200e71011710160101501013010110100f0100e010090100800007000
00020000165400a550105602d6502765013550115500d550020501e2301b220030200301002010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000070501b15015150111500f1500d1500b1500815006150130500d050060500405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000e55008550055503954030540195500e5500c55008550045500a2500565007650096500b6500c65000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000301502e1502b150221501b150041500000003150021500215003150031500315003150031500315003150000000000000000000000000000000000000000000000000000000000000000000000000000
00010000271700f760127502c7402c73028730227301b7300d730107300e72014120111202b610296102661017310153001430012300143000000033300043001c310000102c3001a30000000000002430000000
000100001d750267502a750297502875008250147500f750062500525005250042500425003250022500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000011350213503135009350083500835007350063500965005350086500335000000033500000003350066500665006650066500665000000000000000000000000000000000000000000000000000
00010000193502575026750267500e750177501475010750037500c750000000775003750277500b3500235007350013500735000000073500000007350000000735007350073500735006350063500535001350
00010000143500575004750214500a1500f150141502d1501115011150164500f4500775005750037500275002750027500000002750000000275000000027500000002750027500275000000027500000002750
00010000207501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501e7501e750000001e7501e750000001f7501e7501f7501e750000001e7501e7501e7501e7501e750000001e750000001e75000000
001000001f7501b700000000170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000000001c750297502f7500775006750127500f750037500b750017500775005750057500575005750047500375004750027500475002750047500475002750000000275000000047500000003750
00010000000001d75026750317502a750217501275012750127501375000000147500000000000147500000000000147500000000000157500000000000157500000015750157500000013750000001075000000
0001000012450134500f4500b4500a4500a450097500b45012450164501c4501c45018450134500945003450157500d750017500175028750037500575006750087500b7500f7500000000000000000000000000
00010000144500e150101501315014150141501415014150121500f1500a150071500865009650081500515004150031500215001150000000000000000000000000000000000000000000000000000000000000
00010000157501b750227502475025750257500d250122500f2501b7500b2500625006750012400173006720101000a15006700081500c100087300f1000370009750071000a700071000a750071000870006700
0110000014354063540830406354063540630415354063040630406304123041235421023123041230406304063541230412354123541e02312354063541230406354123041e35412304123541e3041235412354
01100000080550060500605186052464518605006050060520005006050060511634296451860500605200050805500605006050805524645186050805520005060551e005006050105528645186050105523005
011000000c0550c0551105111055150511505518051180550e0550e055130511305517051170551a0511a05510051100551505115055180511805510051100551005510055150511505518051180551505115055
01100000110530c00311053110331c65011103110530c003111030c00311053111031a65011103110530c003110530c00311053110331c65011103111030c003111030c00311053110031565011103110530e033
01100000140530000000000000000d650000000000000000000000000014053000001f65000000000000000000000000000000000000226500000000000000000000000000140530000019650000001400314033
010400003d0732c6550d6532760525373196553860521150241501a150241401a140241301a130241201a120241101a110241101a110241001a1001c0002900026000260000b000290002800033000300002c000
01040000194732c6550d653276051d373196552b753180401a16021160241601a15021150241501a14021140241401a13021130241301a12021120241201a11021110241101a11021110241101a100210002c000
010200000a550135501b4502945028450264501e75023450167500f7502145008750097501f45006540175401c4401253012530194300f5300e530154300f5300b520134200e0200f52012420110101141011400
013c000024537155371c5371d53723537135371a5371c5372153711537175371c5372153710537185371a53724537155371c5371d53723537135371a5371c53721537115371a5371c5372153710537185371a537
0120000015552155521755217552115521155210552105520e5520e55210552105520c5520c5520b5520b5520e5520e5020e5520e502105521050210552105020c5520c5020c5520c5020b5520b5020b5520b502
013000001853711537215371a5371a53713537235371f5371853711537215371a53721537105371f537245371c53715537245371d53721537175372d5371f5372153711537185371c5372153710537185371a537
013000001c53713537235371f5371c5371553718537215371d5371553724537215371f5371753728537245371c537135372f5372b5371c5371553724537215371d5371553718537215371a5370e5371f53723537
013000001b5370c5372b53722537185370a537275371f5371d537075372753722537245370f5371f537185371b5371353724537185371f537115371d5371b5371f5370553718537225371b5370c537225371f537
01100003336151b615276151b60500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
011000000d7240e7210f721107211172112721137211472115721167211772118721197211a7211b7211c7211d7211e7211f721207212172122721237212472125721267212772128721297212a7212b7212c721
011000002572424721237212272121721207211f7211e7211d7211c7211b7211a721197211872117721167211572114721137211272111721107210f7210e7210d7210c7210b7210a72109721087210772106721
011300000f3342a1152a1153a215003041c304043340030403334003043a212003042c1202711125125251152312523115083342311523115352150f334003040333400304352121c0002912027111221202a125
011300001962519605346051c62523033170001a625006051962519605346051c62523033006051a625006051962519605346050060524033006051a625006051962519605346051c62524033006051a6251c615
011300000f0530f00033423334132d6531b505334231100033423334130f053334232c6530f0002121321223100000f000334230f0532c65333423334130000033423225050f053334132d65300000334230f053
010800003f614306212d631296312664118641216411e6252310027153271032715300100231531a1032615300100271531a505271532a5051a535205352a53519530195350d5300d5300d5300d5000d5000d500
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
03 11 12 43 44
03 13 14 43 44
03 19 42 43 44
03 1b 42 43 44
03 1c 42 43 44
03 1d 42 43 44
03 21 21 22 23
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
