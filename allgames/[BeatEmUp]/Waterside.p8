pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- waterside (lowrezjam 2019)
-- developed by justfire45

function _init()
 cartdata('justfire45_waterside_1')
 poke(0x5f2c, 3)
 palt(0, false)
 palt(14, true)
 init()
end

function init()
 --1 game
 t = 0
 state = 0
 water = 0
 btnx = 0
 btno = 0
 sshake = 0
 s2dark = 20
 s4ice1 = 240
 s4ice2 = 300
 s4ice1x = flr(rnd(56))
 s4ice2x = flr(rnd(56))
 floppy = 0
 floppyy = 64
 --1 overworld
 olv = ''
 olvn = 'olive forest'
 opx = 0
 opy = 72
 otx = 12
 oty = 52
 s3 = 0.5
 --1 player death
 pded = 0
 pdedt = 60
 --1 fade
 fad = 4
 fadi = -1
 fadt = 10
 --1 timer
 timer = 0
 timerp = 0
 timerf = 0
 --1 level
 kills = 0
 rkills = 10
 bg = 1
 bg_table = {}
 enm = {}
 pix = {}
 proj = {}
 dnum = {}
 --1 player
 pf = 1
 px = 28
 py = 35
 pv = 0
 pa = 0
 patk = 1
 php = 6
 pmhp = 6
 pinv = 30
 --2 sword
 psx1 = -128
 psx2 = -128
 psy1 = -128
 psy2 = -128
 --1 boss vars
 bsmn = -1
 bwarn = 1
 bwarnx = -128
 tonextlevel = -1
end

function printborder(tx, x, y, clr, bclr)
 print(tx, x - 1, y, bclr)
 print(tx, x + 1, y, bclr)
 print(tx, x, y - 1, bclr)
 print(tx, x, y + 1, bclr)
 print(tx, x - 1, y - 1, bclr)
 print(tx, x - 1, y + 1, bclr)
 print(tx, x + 1, y - 1, bclr)
 print(tx, x + 1, y + 1, bclr)
 print(tx, x, y, clr)
end

function animate(f, mnf, mxf, spd)
 if t % spd == 0 then
  f += 1
  if f > mxf then f = mnf end
 end
 return f
end

function distance(x1, y1, x2, y2)
 local xx = (x1 - x2) / 64
 local yy = (y1 - y2) / 64
 local i = (xx * xx) + (yy * yy)
 return sqrt(i) * 64
end

function centertext(str)
 return 32 - #str * 2
end

// http://kometbomb.net/pico8/fadegen.html
// v v v

local fadetable={
 {0, 0, 0, 0},
 {1, 1, 0, 0},
 {2, 2, 1, 0},
 {3, 3, 1, 0},
 {4, 2, 2, 0},
 {5, 5, 1, 0},
 {6, 13, 5, 1},
 {7, 6, 13, 1},
 {8, 8, 2, 0},
 {9, 4, 4, 0},
 {10, 9, 4, 5},
 {11, 3, 3, 0},
 {12, 12, 1, 1},
 {13, 5, 1, 1},
 {14, 13, 2, 1},
 {15, 13, 5, 1}
}

function fade(i)
 for c = 0, 15 do
  if flr(i + 1) >= 4 then
   pal(c, 0)
  else
   pal(c, fadetable[c + 1][flr(i + 1)])
  end
 end
end

// ^ ^ ^
// http://kometbomb.net/pico8/fadegen.html

function anybtnp()
 return btnp(‘) or btnp(‹) or btnp(”) or btnp(ƒ) or btnp(Ž) or btnp(—)
end

function levelspawn()
 if #enm == 0 then
	 if bg == 1 then
	  if kills == 0 then
	   spawnenemy(-8, 35, 1)
	   spawnenemy(64, 35, 1)
	  elseif kills == 2 then
	   spawnenemy(-8, 35, 1)
	   spawnenemy(64, 35, 1)
	   spawnenemy(-12, 35, 1)
	   spawnenemy(68, 35, 1)
	  elseif kills == 6 then
	   spawnenemy(-8, 35, 1)
	   spawnenemy(64, 35, 1)
	   spawnenemy(-32, 22, 2)
	   spawnenemy(96, 22, 2)
	  elseif kills == 10 then
	   music(-1)
	   bsmn = 210
	   bwarnx = 38
	  elseif kills >= 32000 then
	   music(-1)
	   sfx(7)
	   tonextlevel = 180
	  end
	 elseif bg == 2 then
	  if kills == 0 then
	   spawnenemy(-16, 35, 3)
	   spawnenemy(104, 35, 3)
	  elseif kills == 2 then
	   spawnenemy(-16, 35, 3)
	   spawnenemy(-24, 35, 3)
	   spawnenemy(-28, 35, 4)
	   spawnenemy(96, 35, 4)
	  elseif kills == 6 then
	   spawnenemy(-32, 22, 2)
	   spawnenemy(-16, 22, 2)
	   spawnenemy(-24, 22, 4)
	   spawnenemy(88, 35, 3)
	   spawnenemy(96, 35, 3)
	  elseif kills == 11 then
	   music(-1)
	   bsmn = 210
	   bwarnx = 4
	  elseif kills >= 32000 then
	   music(-1)
	   sfx(7)
	   tonextlevel = 180
	  end
	 elseif bg == 3 then
	  if kills == 0 then
	   spawnenemy(-16, 35, 5)
	   spawnenemy(-32, 35, 5)
	   spawnenemy(88, 22, 2)
	   spawnenemy(96, 22, 2)
	   spawnenemy(96, 22, 4)
	  elseif kills == 5 then
	   spawnenemy(-16, 35, 6)
	   spawnenemy(-24, 22, 2)
	   spawnenemy(88, 35, 5)
	   spawnenemy(88, 22, 2)
	  elseif kills == 9 then
	   spawnenemy(-16, 35, 6)
	   spawnenemy(-24, 22, 2)
	   spawnenemy(-32, 22, 2)
	   spawnenemy(-40, 22, 2)
	   spawnenemy(88, 35, 4)
	   spawnenemy(96, 35, 6)
	  elseif kills == 15 then
	   music(-1)
	   bsmn = 210
	   bwarnx = 24
	  elseif kills >= 32000 then
	   music(-1)
	   sfx(7)
	   tonextlevel = 180
	  end
	 elseif bg == 4 then
	  if kills == 0 then
	   spawnenemy(-8, 35, 7)
	   spawnenemy(80, 35, 7)
	   spawnenemy(96, 35, 6)
	  elseif kills == 3 then
	   spawnenemy(-32, 35, 5)
	   spawnenemy(-40, 22, 8)
	   spawnenemy(80, 35, 7)
	   spawnenemy(80, 22, 2)
	  elseif kills == 7 then
	   spawnenemy(28, -32, 9)
	  elseif kills == 8 then
	   spawnenemy(28, -32, 9)
	   spawnenemy(88, 22, 2)
	   spawnenemy(96, 22, 2)
	   spawnenemy(96, 22, 8)
	   spawnenemy(104, 22, 2)
	  elseif kills == 13 then
	   music(-1)
	   bsmn = 210
	   bwarnx = 44
	  elseif kills >= 32000 then
	   music(-1)
	   sfx(7)
	   tonextlevel = 180
	  end
	 end
 end
end

function levelend()
 // lv 1 - 12, 52
 // lv 2 - 12, 36
 // lv 3 - 16, 12
 // lv 4 - 48, 28
 // lv 5 - 56, 8
 if olv == 'olive forest' then
  olvn = 'dark cavern'
  otx = 12
  oty = 36
  rkills = 11
 elseif olv == 'dark cavern' then
  olvn = 'relic temple'
  otx = 16
  oty = 12
  rkills = 15
 elseif olv == 'relic temple' then
  olvn = 'mount glimmer'
  otx = 48
  oty = 28
  rkills = 13
 elseif olv == 'mount glimmer' then
  olvn = 'the end'
  otx = 56
  oty = 8
  rkills = 99
 end
 php = pmhp
 fadi = 1
end

function _update60()
 --1 delta time
 t += 1
 --1 fade
 if fadt > 0 then fadt -= 1
 else
  fadt = 10
  fad += fadi
  if fad < 0 then fad = 0 end
 end
 fade(fad)
 --1 screen shake
 if sshake > 0 then
  if sshake == 10 then camera(-2, 0)
  elseif sshake == 7 then camera(-2, -2)
  elseif sshake == 4 then camera(0, -2)
  elseif sshake == 1 then camera(0, 0)
  end
  sshake -= 1
 end
 if state == 2 then
		--1 begin level
		if kills == 0 and #enm == 0 and (btnp(—) or btnp(Ž)) then levelspawn() end
	 --1 timer
	 if kills > 0 or #enm > 0 then
	  if timerf < 60 then timerf += 1
	  else
	   if timer < 9999 then timer += 1 end
	   timerf = 0
	  end
	 end
	 --1 music
	 if stat(24) >= 5 and stat(24) <= 7 then music(-1) end
	 if (btnp(Ž) or btnp(—)) and kills == 0 and fadi < 1 then
	  if stat(24) == -1 then
		  if bg == 1 then music(0)
		  elseif bg == 2 then music(8)
		  elseif bg == 3 then music(13)
		  elseif bg == 4 then music(25)
		  end
	  end
	 end
	 --1 summon boss
	 if bsmn > 0 then bsmn -= 1 end
	 if bsmn >= 0 then
		 if bsmn == 0 then
		  bsmn = -1
		  summonboss()
		  music(18)
		 elseif bsmn <= 30 then
		  bwarnx = -128
		 end
		end
		--1 end level
		if tonextlevel > 0 then tonextlevel -= 1
		elseif tonextlevel == 0 then
		 tonextlevel = -1
		 levelend()
		end
	 --1 player
	 if pded == 0 then
		 --2 move
		 if btn(‘) and btn(‹) then
		  if pf % 2 == 0 then pf -= 1 end
		 elseif btn(‘) then
		  if pa < 1 or pf < 3 then
			  if pf > 2 then pf = 1 end
			  pf = animate(pf, 1, 2, 10)
			 end
		  if t % 3 == 0 and px < 56 then px += 1 end
		 elseif btn(‹) then
		  if pa < 1 or pf > 2 then
			  if pf < 3 then pf = 3 end
			  pf = animate(pf, 3, 4, 10)
			 end
		  if t % 3 == 0 and px > 0 then px -= 1 end
		 else
		  if pf % 2 == 0 then pf -= 1 end
		 end
		 --2 jump
		 if btnp(—) and py == 35 and btnx == 0 then
		  btnx = 1
		  pv = -0.9
		 end
		 if not btn(—) and btnx == 1 then btnx = 0 end
		 --2 gravity
		 if pv != 0 then
		  py += pv
		  pv += 0.04
		  if py > 35 then
		   py = 35
		   pv = 0
		  end
		 end
		 --2 attack
		 if pa > 0 then pa -= 1 end
		 if btnp(Ž) and pa == 0 and btno == 0 then
		  btno = 1
		  pa = 30
		  sfx(0)
		 end
		 if not btn(Ž) and btno == 1 then btno = 0 end
		 --2 player collision
		 if pinv > 0 then pinv -= 1 end
		 for i in all(enm) do
		  if i.cx1 > px + 5 or i.cx2 < px + 2
		  or i.cy1 > py + 6 or i.cy2 < py + 2 then
		  else
		   if pinv <= 0 then
			   sfx(2)
			   php -= i.atk
			   pinv = 60
			   if px < i.x then px -= 4
			   else px += 4
			   end
			   pv = -0.3
			   add(dnum, {x = px + 2, y = py - 8, d = i.atk, e = 18})
		   end
		  end
		 end
		 for i in all(proj) do
		  if i.cx1 > px + 5 or i.cx2 < px + 2
		  or i.cy1 > py + 6 or i.cy2 < py + 2 then
		  else
		   if pinv <= 0 then
			   sfx(2)
			   php -= i.atk
			   pinv = 60
			   if px < i.x then px -= 4
			   else px += 4
			   end
			   pv = -0.3
		    add(dnum, {x = px + 2, y = py - 8, d = i.atk, e = 18})
		   end
		  end
		 end
		 --2 death check
		 if php <= 0 then
			 pded = 1
			 psx1 = -128
			 psy1 = -128
			 psx2 = -128
			 psy2 = -128
			 music(-1)
			 for j = 0, 20, 1 do
			  add(pix, {x = px + flr(rnd(8)),
     y = py + ceil(rnd(7)),
			  x_ = rnd(2) - 1, y_ = rnd(1), c = 4})
				 add(pix, {x = px + flr(rnd(8)),
			  y = py + ceil(rnd(7)),
			  x_ = rnd(2) - 1, y_ = rnd(1), c = 15})
			 end
		 end
		else
		 if pdedt > 0 then pdedt -= 1
		 else
		  fadi = 1
		  kills = 0
		 end
		 if fad >= 5 then
		  timer = timerp
		  enm = {}
		  proj = {}
		  pix = {}
		  fadi = -1
		  pded = 0
		  pdedt = 60
		  php = pmhp
		  if bg == 2 then s2dark = 20 end
		  state = 1
		 end
		end
	 --1 enemies
	 for i in all(enm) do
	  if i.inv > 0 then i.inv -= 1 end
	  if i.id == 1 then
	   --2 attack
	   if i.atk1a > 0 then i.atk1a -= 1
	   else
	    if flr(i.y) >= 35 then i.atk1b = 1 end
	   end
	   if i.atk1b == 1 then
	    i.atk1a = 180 - flr(rnd(60))
	    i.f = 193
	    if i.y_ == 0 then i.y_ = -1 end
	    if i.atk1c == 0 then
		    if i.x < px then i.atk1c = 0.2
		    else i.atk1c = -0.2
		    end
	    end
	   end
	   i.x += i.atk1c
	   i.y += i.y_
	   i.y_ += 0.03
    if flr(i.y) >= 35 then
     i.y = 35
	    i.y_ = 0
	    i.f = 192
	    i.atk1b = 0
	    i.atk1c = 0
	   end
	  elseif i.id == 2 then
	   --2 fly
	   i.x += i.x_
	   if i.x < -4 then
	    i.x_ = 0.2
	    i.f = 196
	   elseif i.x > 60 then
	    i.x_ = -0.2
	    i.f = 194
	   end
	   --2 animate
	   if i.f >= 196 then i.f = animate(i.f, 196, 197, 15)
	   else i.f = animate(i.f, 194, 195, 15)
	   end
	  elseif i.id == 3 then
	   --2 walk
	   i.x += i.x_
	   if i.x < px then
	    if i.x_ < 0.2 then i.x_ += 0.01 end
	    if i.f > 199 then i.f = 198 end
	   elseif i.x > px then
	    if i.x_ > -0.2 then i.x_ -= 0.01 end
	    if i.f < 200 then i.f = 200 end
	   end
	   --2 animate
	   if i.f >= 200 then i.f = animate(i.f, 200, 201, 15)
	   else i.f = animate(i.f, 198, 199, 15)
	   end
	  elseif i.id == 4 then
	   --2 attack
	   if i.atk1a > 0 then i.atk1a -= 1
	   else
	    if flr(i.y) >= 35 then i.atk1b = 1 end
	   end
	   if i.atk1b == 1 then
	    i.atk1a = 60 - flr(rnd(30))
	    i.f = 203
	    if i.y_ == 0 then i.y_ = -1 end
	    if i.atk1c == 0 then
		    if i.x < px then i.atk1c = 0.2
		    else i.atk1c = -0.2
		    end
	    end
	   end
	   i.x += i.atk1c
	   i.y += i.y_
	   i.y_ += 0.03
    if flr(i.y) >= 35 then
     i.y = 35
	    i.y_ = 0
	    i.f = 202
	    i.atk1b = 0
	    i.atk1c = 0
	   end
	  elseif i.id == 5 then
	   --2 walk
	   i.x += i.x_
	   if i.x < px then
	    if i.x_ < 0.2 then i.x_ += 0.01 end
	    if i.f > 205 then i.f = 204 end
	   elseif i.x > px then
	    if i.x_ > -0.2 then i.x_ -= 0.01 end
	    if i.f < 206 then i.f = 206 end
	   end
	   --2 animate
	   if i.f >= 206 then i.f = animate(i.f, 206, 207, 15)
	   else i.f = animate(i.f, 204, 205, 15)
	   end
	  elseif i.id == 6 then
	   --2 walk and animate
	   i.x += i.x_
	   if i.x < 4 then
	    if i.x_ < 0.2 then i.x_ += 0.01 end
	    i.f = animate(i.f, 208, 209, 15)
	   elseif i.x > 52 then
	    if i.x_ > -0.2 then i.x_ -= 0.01 end
	    i.f = animate(i.f, 210, 211, 15)
	   else
	    i.x_ = 0
	    if i.f == 209 then i.f = 208
	    elseif i.f == 211 then i.f = 210
	    end
	   end
	   --2 throw bone
	   if i.x >= 4 and i.x <= 52 then
		   if i.f_ > 0 then
		    i.f_ -= 1
		    if i.f_ == 30 then
		     local j = 0.5
		     if i.f == 210 then j = -0.5 end
		     add(proj, {id = 1, f = 214, mnf = 214, mxf = 217, fs = 3,
		     cx1 = -1, cx2 = -1, cy1 = -1, cy2 = -1,
		     cx1_ = 1, cx2_ = 6, cy1_ = 1, cy2_ = 6,
		     x = i.x, y = i.y, x_ = j, atk = 1})
		     if i.f == 208 then i.f = 212
		     elseif i.f == 210 then i.f = 213
		     end
		    end
		   else
		    i.f_ = 120 + flr(rnd(60))
		    if i.f == 212 then i.f = 208
		    elseif i.f == 213 then i.f = 210
		    end
		   end
		  end
	  elseif i.id == 7 then
	   --2 attack
	   if i.atk1a > 0 then i.atk1a -= 1
	   else
	    if flr(i.y) >= 35 then i.atk1b = 1 end
	   end
	   if i.atk1b == 1 then
	    i.atk1a = 60 - flr(rnd(30))
	    i.f = 253
	    if i.y_ == 0 then i.y_ = -1 end
	    if i.atk1c == 0 then
		    if i.x < px then i.atk1c = 0.2
		    else i.atk1c = -0.2
		    end
	    end
	   end
	   i.x += i.atk1c
	   i.y += i.y_
	   i.y_ += 0.03
    if flr(i.y) >= 35 then
     i.y = 35
	    i.y_ = 0
	    i.f = 252
	    i.atk1b = 0
	    i.atk1c = 0
	   end
	  elseif i.id == 8 then
	   --2 fly
	   i.x += i.x_
	   if i.x < -4 then
	    i.x_ = 0.4
	    i.f = 182
	   elseif i.x > 60 then
	    i.x_ = -0.4
	    i.f = 180
	   end
	   --2 animate
	   if i.f >= 182 then i.f = animate(i.f, 182, 183, 15)
	   else i.f = animate(i.f, 180, 181, 15)
	   end
	  elseif i.id == 9 then
	   --2 move
	   if i.y < 22 then i.y += 0.2
	   else
	    if flr(i.x) < i.tx then i.x += 0.2
	    elseif flr(i.x) > i.tx then i.x -= 0.2
	    else i.tx = flr(rnd(56))
	    end
	   end
	   --2 shoot
	   if i.atk_ > 0 then i.atk_ -= 1
	   else
	    i.atk_ = 120 + flr(rnd(60))
	    add(proj, {id = 2, f = 238, mnf = 238, mxf = 238, fs = 999,
			  cx1 = -1, cx2 = -1, cy1 = -1, cy2 = -1, a = atan2(py - i.y, px - i.x),
			  cx1_ = 3, cx2_ = 4, cy1_ = 4, cy2_ = 5,
			  x = i.x, y = i.y, spd = 0.5, atk = 1})
	   end
	   --2 animate
	   i.f = animate(i.f, 176, 179, 6)
	  elseif i.id == 101 then
	   --2 attack
	   if i.atk1a > 0 then i.atk1a -= 1
	   else
	    if flr(i.y) >= 27 then i.atk1b = 1 end
	   end
	   if i.atk1b == 1 then
	    i.atk1a = 60 - flr(rnd(30))
	    i.f = 2
	    if i.y_ == 0 then i.y_ = -2 end
	    if i.atk1c == 0 then
		    if i.x < px then i.atk1c = 0.2
		    else i.atk1c = -0.2
		    end
	    end
	   end
	   i.x += i.atk1c
	   i.y += i.y_
	   i.y_ += 0.03
    if flr(i.y) >= 27 then
     i.y = 27
     if i.y_ > 0.4 then
      sshake = 10
      sfx(3)
     end
	    i.y_ = 0
	    i.f = 1
	    i.atk1b = 0
	    i.atk1c = 0
	   end
	  elseif i.id == 102 then
	   --2 attacks
	   if i.y < 16 then
	    i.y += 0.2
	    i.f = animate(i.f, 1, 2, 15)
	   else
		   if i.atk_ == 1 then
		    if i.x < 44 then i.x += 0.4
		    else
		     i.x = 44
		     i.atk_ = 2
		     i.y_ = 0.7
		     spawnenemy(i.x + 4, 22, 1)
		    end
		    i.f = animate(i.f, 1, 2, 15)
		    k = 0
		    for j in all(enm) do
		     if j.id == 2 then k += 1 end
		    end
		    if flr(i.x) >= 8 and i.sb1 == 0 and k < 2 then
		     spawnenemy(8, 22, 2)
		     i.sb1 = 1
		    elseif flr(i.x) >= 32 and i.sb2 == 0 and k < 2 then
		     spawnenemy(32, 22, 2)
		     i.sb2 = 1
		    end
		   else
		    i.f = 3
		    i.y += i.y_
		    if i.y_ > 0 then i.y_ -= 0.02 end
		    i.x -= 0.5
		    if i.x <= -32 then
		     i.atk_ = 1
		     i.sb1 = 0
		     i.sb2 = 0
		     i.y = 16
		    end
		   end
	   end
	  elseif i.id == 103 then
	   --2 attack
	   if flr(i.y) >= 19 then
	    if i.inair == 1 then
	     i.inair = 0
	     if i.y_ > 0.4 then
	      sshake = 10
	      sfx(3)
	     end
	     i.x_ = 0
	     i.y_ = 0
	     add(proj, {id = 1, f = 222, mnf = 222, mxf = 223, fs = 6,
		    cx1 = -1, cx2 = -1, cy1 = -1, cy2 = -1,
		    cx1_ = 1, cx2_ = 6, cy1_ = 3, cy2_ = 6,
		    x = i.x + 4, y = 35, x_ = 0.5, atk = 1})
		    add(proj, {id = 1, f = 220, mnf = 220, mxf = 221, fs = 6,
		    cx1 = -1, cx2 = -1, cy1 = -1, cy2 = -1,
		    cx1_ = 1, cx2_ = 6, cy1_ = 3, cy2_ = 6,
		    x = i.x + 4, y = 35, x_ = -0.5, atk = 1})
	    end
	    if i.atk_ < 4 then
		    if i.atk__ > 0 then i.atk__ -= 1
		    else
		     i.atk_ += 1
		     i.atk__ = 60
		     if i.x < px then i.x_ = 0.2
			    else i.x_ = -0.2
			    end
		     i.y_ = -1
		    end
		   else
		    if i.atk__ > 0 then i.atk__ -= 1
		    else
		     i.atk_ = 1
		     i.atk__ = 30
		     add(proj, {id = 2, f = 237, mnf = 237, mxf = 237, fs = 999,
			    cx1 = -1, cx2 = -1, cy1 = -1, cy2 = -1, a = atan2(py - (i.y + 8), px - (i.x + 4)),
			    cx1_ = 1, cx2_ = 6, cy1_ = 1, cy2_ = 6,
			    x = i.x + 4, y = i.y + 8, spd = 0.25, atk = 2})
			    add(proj, {id = 2, f = 236, mnf = 236, mxf = 236, fs = 999,
			    cx1 = -1, cx2 = -1, cy1 = -1, cy2 = -1, a = atan2(py - (i.y + 8), px - (i.x + 4)),
			    cx1_ = 1, cx2_ = 6, cy1_ = 1, cy2_ = 6,
			    x = i.x + 4, y = i.y + 8, spd = 0.5, atk = 1})
		    end
		   end
		  else i.inair = 1
	   end
	   i.x += i.x_
	   i.y += i.y_
	   if flr(i.y) < 19 then i.y_ += 0.02 end
	  elseif i.id == 104 then
	   if i.y < 35 and i.atk_ == 0 then
	    i.y += 0.2
	    for j = 7, 13, 5 do
		    add(pix, {x = i.x + flr(rnd(8)),
			   y = i.y + 8, x_ = rnd(0.2) - 0.1,
			   y_ = rnd(1), c = j})
			  end
			 else
			  if i.atk__ > 0 then i.atk__ -= 1
			  else
			   if ceil(i.y) >= 35 then
				   if i.atk_ == 0 then
				    add(proj, {id = 2, f = 148, mnf = 148, mxf = 148, fs = 999,
				    cx1 = -1, cx2 = -1, cy1 = -1, cy2 = -1, a = atan2(py - i.y, px - i.x),
				    cx1_ = 1, cx2_ = 6, cy1_ = 3, cy2_ = 4,
				    x = i.x, y = i.y, spd = 1, atk = 1})
				   elseif i.atk_ == 1 then
				    if i.x > 32 then
				     i.x_ = -0.35
				     i.f = 167
				    else
				     i.x_ = 0.35
				     i.f = 165
				    end
				    i.y_ = -1
				    i.atk__ += 120
				   elseif i.atk_ == 2 then
				    if i.x > 32 then
				     j = 148
				     i.f = 166
				    else
				     j = 132
				     i.f = 164
				    end
				    for k = 1, 2, 1 do
						   add(proj, {id = 2, f = j, mnf = j, mxf = j, fs = 999,
						   cx1 = -1, cx2 = -1, cy1 = -1, cy2 = -1, a = atan2(py - i.y, px - i.x),
						   cx1_ = 1, cx2_ = 6, cy1_ = 3, cy2_ = 4,
						   x = i.x, y = i.y, spd = 1 / k, atk = k})
						  end
				   elseif i.atk_ == 3 then
				   elseif i.atk_ == 4 then
				    i.y_ = -1.5
				    i.atk__ += 300
				   end
				   i.atk__ += 60
				   i.atk___ += 1
				   if i.atk___ > #i.atk____ then
				    i.atk___ = 1
				    i.atk____ = shuffle(i.atk____)
				   end
				   i.atk_ = i.atk____[i.atk___]
				  end
				 end
			  i.x += i.x_
				 i.y += i.y_
				 i.y_ += 0.015
				 if ceil(i.y) >= 35 then
				  i.y = 35
				  i.x_ = 0
				  i.y_ = 0
				 elseif i.y < -8 then
				  i.x = flr(rnd(2)) * 48 + 4
				  if i.x < 32 then i.f = 164
				  else i.f = 166
				  end
				 else if t % 30 == 0 then icemake(i.x) end
				 end
	   end
	  end
	  enmcol()
	 end
	end
end

function _draw()
 cls()
 if state == 0 then
  map(8, 8, 0, 0, 8, 8)
  if anybtnp() then fadi = 1 end
  if fad > 4 then
   fadi = -1
   if peek(0x5e00) != 10 then state = 1
   else
    sfc = 0
    state = 0.5
   end
  end
  --1 water reflection
	 water += 0.01
	 local i = water
	 for yy = 16, 39, 1 do
	  i += 0.07
	  local ii = cos(i) * 1.05
	  for xx = 0, 63, 1 do
	   pset(xx + ii, 39 + (39 - yy), pget(xx, yy))
			end
	 end
	elseif state == 0.5 then
	 fade(fad)
	 i = 'save file'
	 print(i, centertext(i), 12, 7)
	 i = '[c] load'
	 print(i, centertext(i), 41, 7)
	 i = '[x][ƒ] erase'
	 print(i, centertext(i) - 2, 47, 7)
	 spr(48, 28, 25)
	 if fad == 0 then
		 if btn(Ž) then
		  pmhp = peek(0x5e02)
		  php = pmhp
		  patk = peek(0x5e03)
		  timer = peek4(0x5e04)
	   i = peek(0x5e01)
	   bg = i
	   if i == 2 then
	    olv = 'olive forest'
	    olvn = 'dark cavern'
	    opx, opy = 12, 52
	    otx, oty = 12, 36
	   elseif i == 3 then
	    olv = 'dark cavern'
	    olvn = 'relic temple'
	    opx, opy = 12, 36
	    otx, oty = 16, 12
	   elseif i == 4 then
	    olv = 'relic temple'
	    olvn = 'mount glimmer'
	    opx, opy = 16, 12
	    otx, oty = 48, 28
	   elseif i == 5 then
	    olv = 'mount glimmer'
	    olvn = 'the end'
	    opx, opy = 48, 28
	    otx, oty = 56, 8
	   end
		  fadi = 1
		  sfc = 1
		 elseif btn(—) and btn(ƒ) then
		  poke(0x5e00, 0)
		  fadi = 1
		  sfc = 1
		 end
		end
	 if fad >= 5 and sfc == 1 then
	  fadi = -1
	  state = 1
	 end
 elseif state == 1 then
  timerp = timer
  px = 28
  py = 35
  kills = 0
  bg_table = {}
  if stat(24) == -1 then
   music(5)
  end
  if fad == 0 and distance(otx, oty, opx, opy) > 1 then
	  olv = ''
	  local i = atan2(otx - opx, oty - opy)
	  opx += cos(i) / 2
	  opy += sin(i) / 2
	 else
	  if distance(otx, oty, opx, opy) < 4 then
	   olv = olvn
	   if anybtnp() then
	    fadi = 1
	   end
	   if fad >= 4 then
	    fadi = -1
	    if bg < 5 then state = 2
	    else state = 4
	    end
	   end
	  end
	 end
  map(0, 8, 0, 0, 8, 8)
  spr(111, opx, opy)
  printborder(olv, centertext(olv), 1, 7, 0)
  if floppy > 0 then
	  floppy -= 1
	  if floppyy > 54 then floppyy -= 0.5 end
	 else if floppyy < 64 then floppyy += 0.5 end
	 end
	 spr(48, 54, floppyy)
 elseif state == 2 then
  if fad >= 4 and kills > 0 then
	  fadi = -1
	  state = 3
	  if olvn == 'dark cavern' then bg = 2
	  elseif olvn == 'relic temple' then bg = 3
	  elseif olvn == 'mount glimmer' then bg = 4
	  elseif olvn == 'the end' then bg = 5
	  end
	 end
	 // if btnp(”) then bg += 1
	 // elseif btnp(ƒ) then bg -= 1
	 // end
	 if bg == 1 then
	  -- olive forest
	  if #bg_table == 0 then
	   for i = 0, 10, 1 do
			  repeat
				  xx = flr(rnd(64))
				  yy = flr(rnd(24))
				 until xx < 24 or xx > 40
			  add(bg_table, {x = xx, y = yy})
			 end
	  end
		 for i in all(bg_table) do pset(i.x, i.y, 5) end
		 circfill(32, 20, 8, 7)
		 map(0, 0, 0, 0, 8, 8)
		elseif bg == 2 then
		 -- dark cavern
		 map(16, 0, 0, 0, 8, 8)
		elseif bg == 3 then
		 -- sand temple
		 map(32, 0, 0, 0, 8, 8)
		elseif bg == 4 then
		 -- mount glimmer
		 map(48, 0, 0, 0, 8, 8)
		end
		--1 projectiles
		for i in all(proj) do
		 i.f = animate(i.f, i.mnf, i.mxf, i.fs)
		 if i.id == 1 then i.x += i.x_
		 elseif i.id == 2 then
		  i.x += sin(i.a) * i.spd
		  i.y += cos(i.a) * i.spd
		 elseif i.id == 3 then
		  i.x += i.x_
		  i.y += i.y_
		 end
		 i.cx1 = i.x + i.cx1_
		 i.cx2 = i.x + i.cx2_
		 i.cy1 = i.y + i.cy1_
		 i.cy2 = i.y + i.cy2_
		 if i.f == 239 then
		  if i.cx1 > psx2 or i.cx2 < psx1
		  or i.cy1 > psy2 or i.cy2 < psy1 then
		  	if i.y > 35 then icebreak(i) end
			 else icebreak(i)
			 end
		 end
		 if i.x > 64 or i.x < -32 or i.y < -32 or i.y > 64 then del(proj, i) end
		 spr(i.f, i.x, i.y)
		end
	 --1 boss warning
	 if t % 15 == 0 then bwarn *= -1 end
	 if bwarn == 1 then sspr(112, 120, 16, 3, bwarnx, 41, 16, 3)
	 else sspr(112, 123, 16, 3, bwarnx, 41, 16, 3)
	 end
	 --1 mount glimmer - icicles
	 if bg == 4 and (kills > 0 or #enm > 0) and kills < 13 then
			--2 icicle 1
			if s4ice1 > 0 then s4ice1 -= 1
			else
			 icemake(s4ice1x)
			 s4ice1 = 210 + flr(rnd(90))
				s4ice1x = flr(rnd(56))
			end
			if s4ice1 <= 60 then
			 if bwarn == 1 then sspr(112, 120, 8, 3, s4ice1x, 41, 8, 3)
			 else sspr(112, 123, 8, 3, s4ice1x, 41, 8, 3)
			 end
			end
			--2 icicle 2
			if s4ice2 > 0 then s4ice2 -= 1
			else
			 icemake(s4ice2x)
			 s4ice2 = 210 + flr(rnd(90))
				s4ice2x = flr(rnd(56))
			end
			if s4ice2 <= 60 then
			 if bwarn == 1 then sspr(112, 120, 8, 3, s4ice2x, 41, 8, 3)
			 else sspr(112, 123, 8, 3, s4ice2x, 41, 8, 3)
			 end
			end
		end
		--1 enemies
	 for i in all(enm) do
	  if i.inv % 3 == 0 then
	   if i.id < 100 then spr(i.f, i.x, i.y)
	   else
	    if i.id == 101 then sspr(-16 + (i.f * 16), 112, 16, 16, i.x, i.y, 16, 16)
	    elseif i.id == 102 then sspr(16 + (i.f * 16), 112, 16, 16, i.x, i.y, 16, 16)
	    elseif i.id == 103 then sspr(80, 104, 16, 24, i.x, i.y, 16, 24)
	    elseif i.id == 104 then spr(i.f, i.x, i.y)
	    end
	   end
	  end
	 end
	 --1 player
	 if pded == 0 then
		 if pa >= 6 then
		  if pf < 3 then
			  local i = 33
			  if pa <= 8 then
			   i = 36
			   psx1 = -128
			   psy1 = -128
			   psx2 = -128
			   psy2 = -128
			  elseif pa <= 16 then
			   i = 35
			   psx1 = px + 8
			   psx2 = px + 15
			   psy1 = py
			   psy2 = py + 7
			  elseif pa <= 22 then i = 34
			  end
			  if pinv % 3 == 0 then spr(i, px, py) end
			  spr(i + 16, px + 8, py)
			 else
			  local i = 37
			  if pa <= 8 then
			   i = 40
			   psx1 = -128
			   psy1 = -128
			   psx2 = -128
			   psy2 = -128
			  elseif pa <= 16 then
			   i = 39
			   psx1 = px - 8
			   psx2 = px - 1
			   psy1 = py
			   psy2 = py + 7
			  elseif pa <= 22 then i = 38
			  end
			  if pinv % 3 == 0 then spr(i, px, py) end
			  spr(i + 16, px - 8, py)
			 end
		 else
		  if pinv % 3 == 0 then spr(pf + 16, px, py) end
		 end
		 if pinv % 3 == 0 then spr(pf, px, py) end
  end
	 --1 pixels
	 for i in all(pix) do
	  i.x += i.x_
	  i.y += i.y_
	  i.y_ += 0.01
	  if i.y > 56 then del(pix, i) end
	  pset(i.x, i.y, i.c)
	 end
	 --1 damage number
	 for i in all(dnum) do
	  i.e -= 1
	  if i.e <= 0 then del(dnum, i) end
	  if i.e % 6 == 0 then i.y -= 1 end
	  printborder(i.d, i.x, i.y, 7, 0)
	 end
	 --1 dark cavern - view circle
	 if bg == 2 and s2dark < 64 then
	  if kills >= 11 and s2dark < 64 then s2dark += 1 end
	  local w = s2dark
	  local ppx = px + 4
		 local ppy = py + 4
		 local xmn = ppx - w
		 local xmx = ppx + w
		 local ymn = ppy - w
		 local ymx = ppy + w
		 if xmn < 0 then xmn = 0
		 elseif xmx > 64 then xmx = 64
		 end
		 if ymn < 0 then ymn = 0
		 elseif ymx > 64 then ymx = 64
		 end
	  rectfill(0, 0, 63, ymn, 0)
		 rectfill(0, ymx, 63, 63, 0)
		 rectfill(0, 0, xmn, 63, 0)
		 rectfill(xmx, 0, 63, 63, 0)
		 for yy = ymn, ymx, 1 do
		  for xx = ppx, xmn, -1 do
		   if pget(xx, yy) > 0 then
		    if distance(xx, yy, ppx, ppy) > w then line(xx, yy, xmn, yy, 0) end
		   end
		  end
		  for xx = ppx, xmx, 1 do
		   if pget(xx, yy) > 0 then
		    if distance(xx, yy, ppx, ppy) > w then line(xx, yy, xmx, yy, 0) end
		   end
		  end
		 end
		end
	 --1 water reflection
	 water += 0.01
	 local i = water
	 for yy = 32, 47, 1 do
	  i += 0.07
	  local ii = cos(i) * 1.05
	  for xx = 0, 63, 1 do
	   pset(xx + ii, 47 + (47 - yy), pget(xx, yy))
			end
	 end
	 --1 timer
	 if kills > 0 or #enm > 0 then
	  printborder(timer, 0, 58, 7, 0)
	 end
		--1 instructions
	 if kills == 0 and #enm == 0 and fadi < 1 then
		 local txt = '[x] or [c]'
		 printborder(txt, centertext(txt), 16, 7, 0)
		end
	 --1 hud
	 --2 border
	 local i = pmhp * 3
	 if i < 17 then i = 17 end
	 rectfill(0, 0, i, 5, 0)
	 rectfill(0, 5, 17, 10, 0)
	 --2 hp
	 for i = 1, pmhp, 1 do
	  if php >= i then sspr(0, 8, 2, 4, (i * 3) - 2, 1, 2, 4)
	  else sspr(2, 8, 2, 4, (i * 3) - 2, 1, 2, 4)
	  end
	 end
	 --2 power
	 for i = 1, 5, 1 do
	  if patk >= i then sspr(4, 8, 4, 4, (i * 3) - 2, 6, 4, 4)
	  else sspr(4, 12, 4, 4, (i * 3) - 2, 6, 4, 4)
	  end
	 end
	 --2 kills
	 if kills > 0 or #enm > 0 and fad == 0 then
		 local i = kills
		 if i < 10 then i = '0'..i end
		 if kills < rkills then printborder(i..'/'..rkills, 44, 1, 7, 0)
		 else printborder('boss', 48, 1, 7, 0)
		 end
	 end
	elseif state == 3 then
	 if stat(24) == -1 then
   music(5)
  end
  map(0, 8, 0, 0, 8, 8)
  spr(111, opx, opy)
  printborder(olv, centertext(olv), 1, 7, 0)
	 rectfill(16, 16, 48, 48, 0)
	 rect(16, 16, 48, 48, 7)
	 line(16, 49, 48, 49, 5)
	 line(17, 17, 47, 17, 5)
	 if t % 30 == 0 then s3 *= -1 end
	 spr(5, 22, 20)
	 spr(6, 36, 20)
	 spr(12, 22, 29)
	 spr(7, 36, 29)
	 spr(8.5 + s3, 22, 38)
	 spr(10.5 + s3, 36, 38)
	 if bg < 5 then
		 if btnp(—) then
		  state = 1
		  pmhp += 2
		  php = pmhp
		 elseif btnp(Ž) then
		  state = 1
		  patk += 1
		 end
		 if btnp(—) or btnp(Ž) then
		  floppy = 180
			 poke(0x5e00, 10)
			 poke(0x5e01, bg)
			 poke(0x5e02, pmhp)
			 poke(0x5e03, patk)
			 poke4(0x5e04, timer)
		 end
	 else
	  floppy = 180
		 poke(0x5e00, 10)
		 poke(0x5e01, bg)
		 poke(0x5e02, pmhp)
		 poke(0x5e03, patk)
			poke4(0x5e04, timer)
		 state = 1
	 end
	elseif state == 4 then
	 -- the end
		if #bg_table == 0 then
	  for i = 0, 20, 1 do
			 repeat
			  xx = flr(rnd(64))
				 yy = flr(rnd(32)) + 8
			 until xx < 24 or xx > 40
			 add(bg_table, {x = xx, y = yy})
		 end
	 end  
		for i in all(bg_table) do pset(i.x, i.y, 5) end
		circfill(32, 20, 8, 7)
		map(64, 0, 0, 0, 8, 8)
		spr(42, 28, 35)
		j = 'end'
		printborder(j, centertext(j) + 1, 17, 10, 0)
	 water += 0.01
	 local i = water
	 for yy = 32, 47, 1 do
	  i += 0.07
	  local ii = cos(i) * 1.05
	  for xx = 0, 63, 1 do
	   pset(xx + ii, 47 + (47 - yy), pget(xx, yy))
			end
	 end
	 j = 'time: '..timer..' secs'
		printborder(j, centertext(j) + 1, 52, 7, 0)
	end
end
-->8
-- extra functions

function spawnenemy(x, y, id)
 if id == 1 then
  add(enm, {id = id, f = 192,
  x = x, y = y, y_ = 0,
  atk = 1, atk1a = 180 - flr(rnd(60)),
  atk1b = 0, atk1c = 0, hp = 3,
  cx1 = -1, cx2 = -1, pc = 3,
  cy1 = -1, cy2 = -1, pix1 = 2,
  cx1_ = 1, cx2_ = 6, pix2 = 8,
  cy1_ = 2, cy2_ = 7, inv = 0})
 elseif id == 2 then
  add(enm, {id = id, f = 196,
  x = x, y = y, inv = 0,
  atk = 1, hp = 2, x_ = 0.2,
  cx1 = -1, cx2 = -1, pc = 2,
  cy1 = -1, cy2 = -1, pix1 = 2,
  cx1_ = 1, cx2_ = 6, pix2 = 8,
  cy1_ = 2, cy2_ = 6})
 elseif id == 3 then
  add(enm, {id = id, f = 198,
  x = x, y = y, inv = 0,
  atk = 1, hp = 3, x_ = 0,
  cx1 = -1, cx2 = -1, pc = 6,
  cy1 = -1, cy2 = -1, pix1 = 2,
  cx1_ = 1, cx2_ = 6, pix2 = 8,
  cy1_ = 1, cy2_ = 6})
 elseif id == 4 then
  add(enm, {id = id, f = 202,
  x = x, y = y, y_ = 0,
  atk = 1, atk1a = 60 - flr(rnd(30)),
  atk1b = 0, atk1c = 0, hp = 3,
  cx1 = -1, cx2 = -1, pc = 12,
  cy1 = -1, cy2 = -1, pix1 = 2,
  cx1_ = 1, cx2_ = 6, pix2 = 8,
  cy1_ = 2, cy2_ = 7, inv = 0})
 elseif id == 5 then
  add(enm, {id = id, f = 204,
  x = x, y = y, inv = 0,
  atk = 2, hp = 4, x_ = 0,
  cx1 = -1, cx2 = -1, pc = 6,
  cy1 = -1, cy2 = -1, pix1 = 2,
  cx1_ = 1, cx2_ = 6, pix2 = 8,
  cy1_ = 1, cy2_ = 6})
 elseif id == 6 then
  add(enm, {id = id, f = 208,
  x = x, y = y, inv = 0,
  atk = 1, f_ = 60, hp = 3, x_ = 0,
  cx1 = -1, cx2 = -1, pc = 6,
  cy1 = -1, cy2 = -1, pix1 = 2,
  cx1_ = 1, cx2_ = 6, pix2 = 8,
  cy1_ = 1, cy2_ = 6})
 elseif id == 7 then
  add(enm, {id = id, f = 202,
  x = x, y = y, y_ = 0,
  atk = 1, atk1a = 60 - flr(rnd(30)),
  atk1b = 0, atk1c = 0, hp = 7,
  cx1 = -1, cx2 = -1, pc = 10,
  cy1 = -1, cy2 = -1, pix1 = 2,
  cx1_ = 1, cx2_ = 6, pix2 = 8,
  cy1_ = 2, cy2_ = 7, inv = 0})
 elseif id == 8 then
  add(enm, {id = id, f = 182,
  x = x, y = y, inv = 0,
  atk = 1, hp = 4, x_ = 0.4,
  cx1 = -1, cx2 = -1, pc = 8,
  cy1 = -1, cy2 = -1, pix1 = 2,
  cx1_ = 1, cx2_ = 6, pix2 = 8,
  cy1_ = 2, cy2_ = 6})
 elseif id == 9 then
  add(enm, {id = id, f = 176,
  x = x, y = y, tx = flr(rnd(55)),
  atk = 2, hp = 10, inv = 0,
  cx1 = -1, cx2 = -1, pc = 12,
  cy1 = -1, cy2 = -1, pix1 = 2,
  cx1_ = 1, cx2_ = 6, pix2 = 8,
  cy1_ = 1, cy2_ = 6, atk_ = 240})
 end
end

function summonboss()
 if bg == 1 then
  add(enm, {id = 101, f = 1,
  x = 64, y = 27, y_ = 0,
  atk = 1, atk1a = 60 - flr(rnd(30)),
  atk1b = 0, atk1c = 0, hp = 10,
  cx1 = -1, cx2 = -1, pc = 3,
  cy1 = -1, cy2 = -1, pix1 = 4,
  cx1_ = 1, cx2_ = 14, pix2 = 36,
  cy1_ = 4, cy2_ = 15, inv = 0})
 elseif bg == 2 then
  add(enm, {id = 102, f = 1,
  x = 4, y = -16, y_ = 0,
  atk = 1, atk_ = 1, hp = 12,
  sb1 = 0, sb2 = 0,
  cx1 = -1, cx2 = -1, pc = 2,
  cy1 = -1, cy2 = -1, pix1 = 4,
  cx1_ = 2, cx2_ = 14, pix2 = 36,
  cy1_ = 7, cy2_ = 12, inv = 0})
 elseif bg == 3 then
  add(enm, {id = 103,
  x = 24, x_ = 0, y = -32, y_ = 0,
  atk = 2, atk_ = 1, atk__ = 60,
  cx1 = -1, cx2 = -1, hp = 25, pc = 5,
  cy1 = -1, cy2 = -1, pix1 = 6,
  cx1_ = 2, cx2_ = 13, pix2 = 54,
  cy1_ = 2, cy2_ = 22, inv = 0})
 elseif bg == 4 then
  add(enm, {id = 104, f = 166,
  x = 48, x_ = 0, y = -32, y_ = 0,
  atk = 2, atk_ = 0, atk__ = 30,
  atk___ = 0, atk____ = {1, 2, 3, 4},
  cx1 = -1, cx2 = -1, hp = 15, pc = 12,
  cy1 = -1, cy2 = -1, pix1 = 10,
  cx1_ = 1, cx2_ = 6, pix2 = 10,
  cy1_ = 1, cy2_ = 6, inv = 0})
 end
end

function enmcol()
 for i in all(enm) do
  --1 get values
	 i.cx1 = i.x + i.cx1_
		i.cx2 = i.x + i.cx2_
		i.cy1 = i.y + i.cy1_
		i.cy2 = i.y + i.cy2_
		--1 check collision
	 if i.inv <= 0 then
		 if i.cx1 > psx2 or i.cx2 < psx1
		 or i.cy1 > psy2 or i.cy2 < psy1 then
		 else
		  --2 shared outcomes
		  sfx(1)
		  i.inv = 30
		  for j = 0, i.pix1, 1 do
		   add(pix, {x = i.x + flr(rnd(8)),
		   y = i.y + ceil(rnd(7)),
		   x_ = rnd(2) - 1, y_ = rnd(1), c = i.pc})
		  end
		  if i.cx2_ > 8 then j = 6
		  else j = 2
		  end
		  if i.id == 104 then
		   i.hp -= 1
		   add(dnum, {x = i.x + j, y = i.y - 8, d = 1, e = 18})
		  else
		   i.hp -= patk
		   add(dnum, {x = i.x + j, y = i.y - 8, d = patk, e = 18})
		  end
		  --2 unique outcomes
		  local k = i.id
		  if k == 1 or k == 4 or k == 7 or k == 101 then
		   i.atk1b = 0
		   if i.atk1a < 15 then i.atk1a = 15 end
		   i.y_ = -0.3
		   if i.x < px then i.atk1c = -0.4
		   else i.atk1c = 0.4
		   end
		  else
		   if i.x < px then i.x -= 4
		   else i.x += 4
		   end
		  end
		 end
	 end
	 --1 check death
	 if i.hp <= 0 then
		 for j = 0, i.pix2, 1 do
		  add(pix, {x = i.x + flr(rnd(8)),
		  y = i.y + ceil(rnd(7)),
		  x_ = rnd(2) - 1, y_ = rnd(1), c = i.pc})
		 end
		 if i.id < 100 then
			 kills += 1
	  else
	   kills += 32000
		  for j in all(enm) do j.hp = 0 end
	  end
	  del(enm, i)
	  levelspawn()
  end
 end
end

function icemake(xx)
 add(proj, {id = 3, f = 239, mnf = 239, mxf = 239, fs = 999,
	cx1 = -1, cx2 = -1, cy1 = -1, cy2 = -1,
	cx1_ = 1, cx2_ = 6, cy1_ = 1, cy2_ = 6,
	x = xx, y = -32, x_ = 0, y_ = 1, atk = 1})
end

function icebreak(ice)
 sfx(4)
	del(proj, ice)
	for j = 0, 5, 1 do
		add(pix, {x = ice.x + flr(rnd(8)),
		y = ice.y + ceil(rnd(7)),
		x_ = rnd(2) - 1, y_ = rnd(1), c = 12})
		add(pix, {x = ice.x + flr(rnd(8)),
		y = ice.y + ceil(rnd(7)),
		x_ = rnd(2) - 1, y_ = rnd(1), c = 7})
	end
end

function shuffle(table)
 _a = {}
 for _b = 1, #table, 1 do add(_a, nil) end
 for _b = 1, #table, 1 do
  repeat _c = ceil(rnd(#table)) until _a[_c] == nil
  _a[_c] = table[_b]
 end
 return _a
end
__gfx__
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee88e88eeeeeee77eeeeeeaeee77777eeeeeeeeeee77777eeeeeeeeeeeeeeaaee000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888878eeeee776eeaeeaaee7767677ee77777ee7776677ee77777eeeaee99ae000000000000000000000000
00700700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888888eeee7765eaaae9aee7767677e7767677e7767777e7776677eaaaeea9e000000000000000000000000
00077000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4888884ee47765ee9a9eeaee7776777e7767677e7767777e7767777e9a9ea9ee000000000000000000000000
00077000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee2488842ee2465eeee9eeaaae7767677e7776777e7767777e7767777ee9eeaaae000000000000000000000000
00700700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee24842eee424eeeeeeee999e7767677e7767677e7776677e7767777eeeee999e000000000000000000000000
00000000ee0440eee040040eee0440eee040040eee242eee42e2eeeeeeeeeeee5777775e7767677e5777775e7776677eeeeeeeee000000000000000000000000
00000000ee000eeee00ee00eeee000eee00ee00eeee2eeee2eeeeeeeeeeeeeeee55555eee77777eee55555eee77777eeeeeeeeee000000000000000000000000
4411ee67eee000eeeee000eeee000eeeee000eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88554666ee044400ee044400004440ee004440ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4411e46eee04f440ee04f440044f40ee044f40ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44114e4ee04ff00ee04ff00ee00ff40ee00ff40e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeee15ee0550eeee0550eeee0550eeee0550ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee1111ee0550eeee0550eeee0550eeee0550ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee1e1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee6ee000eee6600066eee00066eee000eeee000ee66600066e66000eeeee000eee00000000eee000ee0000000000000000000000000000000000000000
eeeeeeeee6044400ee044400ee044400ee0444000044406e004440ee004440ee004440ee00000000ee0444000000000000000000000000000000000000000000
eeeeeeeeee04f440ee04f440ee04f440ee04f440044f40ee044f40ee044f40ee044f40ee00000000ee0444400000000000000000000000000000000000000000
eeeeeeeee04ff00ee04ff066e04ff00ee04ff00ee00ff40e660ff40ee00ff40ee00ff40e00000000e044400e0000000000000000000000000000000000000000
eeeeeeeeee0550eeee05540eee05550eee05550eee0550eee04550eee05550eee05550ee00000000ee0550ee0000000000000000000000000000000000000000
eeeeeeeeee0550eeee0550eeee055046ee055046ee0550eeee0550ee640550ee640550ee00000000e0f55f0e0000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000ee0440ee0000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eee00eee0000000000000000000000000000000000000000
000000eeeeeeeeee66eeeeee66666eeeeeeeeeeeeeeeeeeeeeeeee66eee66666eeeeeeee00000000000000000000000000000000000000000000000000000000
0d666d0eeeeeeeee666eeeeee666666eeeeeeeeeeeeeeeeeeeeee666e666666eeeeeeeee00000000000000000000000000000000000000000000000000000000
0d666dd0eeeeeeee66eeeeeeee666666eeeeeeeeeeeeeeeeeeeeee66666666eeeeeeeeee00000000000000000000000000000000000000000000000000000000
0dddddd0eeeeeeeeeeeeeeeeee666666eeeeeeeeeeeeeeeeeeeeeeee666666eeeeeeeeee00000000000000000000000000000000000000000000000000000000
0d7777d0eeeeeeeeeeeeeeeeee666666eeeeeeeeeeeeeeeeeeeeeeee666666eeeeeeeeee00000000000000000000000000000000000000000000000000000000
0d6666d0eeeeeeeeeeeeeeeee6666666eeeeeeeeeeeeeeeeeeeeeeee6666666eeeeeeeee00000000000000000000000000000000000000000000000000000000
0d7777d0eeeeeeeeeeeeeeee6666666e66eeeeeeeeeeeeeeeeeeeeeee6666666eeeeee6600000000000000000000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeee666eeeee66eeeeeeeeeeeeeeeeeeeeeee666eeeeee66ee00000000000000000000000000000000000000000000000000000000
01000010056776501001101005677650101011101111111105677650c00c10d00011110005677650111111110000000005677650000000300156566000000000
1111111105677650111011110567765001110101100000010567765011d0111c0100001005677650000100010000000005677650003001001115556600900000
11111111056776501011110105677650111111110111111005677650101111d11000771005677650110011001010101005677650010000301000000600000000
11111111056776501111111105677650111111110101101005677650111111111000770105677650111111110101010105677650003001030100006000000090
10101010056776501010101005677650101010100101101005677650101010101050000105677650101010101111111105677650010310101000000600000000
01010101056776500101010105677650010101010101101005677650010101011000005105677650010101010011001105677650101010100101105004000000
00000000056776500000000005677650000000000101101005677650000000001005000105677650000000001000100005677650001001111001100600000400
00000000056776500000000005677650000000000101101005677650000000001000000105677650000000001111111105677650011100001111115500000000
eeeeeeee05677650011000100567765001011010000111110567765001c000d00011100005677650111111110000000005677650011115000066666000000000
eeeeeeee056776501101111105677650010110100001000005677650d10d1c110100010005677650100000010000000005677650111111555666666600300000
eeeeeeee056776501111101105677650010110100010000005677650111110110100001005677650011111100000000005677650111555515515556600000000
eeeeeeee0567765011111111056776500101101000100000056776501111111101000c0105677650010110100000000005677650115500505055515600000030
eeeeeeee056776501010101005677650010110100100000005677650101010101010000105677650010110100000000005677650115055055511155500000000
0eeeeee0056776500101010105677650010110100100000005677650010101011000001105677650010110100000000005677650110555055555055601000000
10eeeee0056776500000000005677650010110101000000005677650000000001000000105677650010110100000000005677650115050555555515500000100
00e00e0105677650000000000567765001011010100000000567765000000000100d000105677650010110100000000005677650110550511555515500000000
100010000567765000010001056776500101101011111000056776500000000000000000056776500101101000000000056776501155550550550155eeeeeeee
100100010567765010010110056776500101101000001000056776500010000000000000056776500101101000000000056776501155005155115555ee000eee
110010100567765010001000056776500101101000000100056776500000000000000000056776500101101000000000056776501150555055055155e044400e
10011001056776500111000105677650010110100000010005677650000000c000000000056776500101101000000000056776501150555515515551e04f440e
00101101056776500000100105677650010110100000001005677650000000000000000005677650010110100000000005677650115505500551555104ff00ee
100110100567765010000110056776500111111000000010056776500d00000000000000056776500101101000000000056776501115050000551511e0550eee
001101000567765010011001056776501000000100000001056776500000010000000000056776500101101000000000056776501111110000111111e000eeee
101010100567765001100000056776501111111100000001056776500000000000000000056776500101101000000000056776500111110000111110eeeeeeee
01011110056776500000000005677650000000000000000005677650000000000000000005677650010110100000000005677650000000000000000000000000
0010010105677650000000000567765000000000100010000567765000d000000000000005677650010110100000000005677650000000000000000000000000
01011011056776500000000005677650010101011000100005677650000000000000000005677650010110100000000005677650000000000000000000000000
11110110056776500000000005677650101010101011101105677650000000100000000005677650010110100000000005677650000000000000000000000000
10011001056776500000000005677650111111110000000005677650000000000000000005677650010110100000000005677650000000000000000000000000
10011001056776500000000005677650111111110100010005677650010000000000000005677650011111100000000005677650000000000000000000000000
1101101105677650000000000567765001110101010001000567765000000c000000000005677650100000010000000005677650000000000000000000000000
10111101056776500000000005677650101011101101110105677650000000000000000005677650111111110000000005677650000000000000000000000000
00000000000000000000000000016000eeeeeeee0000cc000cc00ccccc00ccccccc0ccccccc0cccccc0000000000000000000000000000000000000000000000
00000000000000000000000000016000eeeeeeee0000cc000cc0cc111cc011ccc110cc111110cc111cc000000000000000000000000000000000000000000000
00000000000000000000000000155600e0000eee0000cc000cc0cc000cc000ccc000cc000000cc000cc000000000000000000000000000000000000000000000
0000000000000000000000001015550601cc70000000cc0c0cc0ccccccc000ccc000cccccc00cccccc1000000000000000000000000000000000000000000000
000000000005600000000000111555550117c7700000ccccccc0cc111cc000ccc000cc111100cc111cc000000000000000000000000000000000000000000000
000000000055560000000000111156660000000e00001cc1cc10cc000cc000ccc000ccccccc0cc000cc000000000000000000000000000000000000000000000
00000000001505000000000010000006eeeeeeee0000011011001100011000111000111111101100011000000000000000000000000000000000000000000000
00000000010110600000000011155566eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000605550560000000010000006eeeeeeee000000000cccccc0ccccccc0cccccc00ccccccc0000000000000000000000000000000000000000000000000
00000001105105556000000001000060eeeeeeee00000000cc11111011ccc110cc111cc0cc111110000000000000000000000000000000000000000000000000
00000001560015106000000010000006eee0000e00000000cccccc0000ccc000cc000cc0cc000000000000000000000000000000000000000000000000000000
00000001516600055000000001000050000c7c70000000001cccccc000ccc000cc000cc0cccccc00000000000000000000000000000000000000000000000000
0000001155001605560000001000000601c1c7700000000001111cc000ccc000cc000cc0cc111100000000000000000000000000000000000000000000000000
00000010101551050000000011115555e000000000000000cccccc10ccccccc0cccccc10ccccccc0000000000000000000000000000000000000000000000000
00000011055550605600000010000005eeeeeeee0000000011111100111111101111110011111110000000000000000000000000000000000000000000000000
00000111055555100560000011111156eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000111050000516050000011111150eee0000eeee0000ee0000eeee0000eee0000000000000000000000000000000000000000000000000000000000000000
00001110100000056056000001111150ee0cccc0ee0cccc00cccc0ee0cccc0ee0000000000000000000000000000000000000000000000000000000000000000
00011101500000051600600000111500e0ccfcc0e0ccfcc00ccfcc0e0ccfcc0e0000000000000000000000000000000000000000000000000000000000000000
00001105000000001055500000011500e0cff00ee0cff00ee00ffc0ee00ffc0e0000000000000000000000000000000000000000000000000000000000000000
001101010000000050055600000015000cdddf0e0cdddf0ee0fdddc0e0fdddc00000000000000000000000000000000000000000000000000000000000000000
0011101100000000016055000000100000fdd0ee00fdd0eeee0ddf00ee0ddf000000000000000000000000000000000000000000000000000000000000000000
00111015000000005510550000000000ee0110eee010010eee0110eee010010e0000000000000000000000000000000000000000000000000000000000000000
00011101000000005505500000000000ee000eeee00ee00eeee000eee00ee00e0000000000000000000000000000000000000000000000000000000000000000
ee0000eeee0000eeee0000eeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
e0cc770ee0cc770ee0cc770ee0cc770eee0ee000ee0eeeee000ee0eeeeeee0ee0000000000000000000000000000000000000000000000000000000000000000
e011cc0ee011cc0ee011cc0ee011cc0ee0400880e040eeee0880040eeeee040e0000000000000000000000000000000000000000000000000000000000000000
ee0000eeee0000eeee0000eeee0000ee08408880084000ee08880480ee0004800000000000000000000000000000000000000000000000000000000000000000
e0eeee0eee0ee0eeeee00eeeee0ee0ee0888840e0888880ee0488880e08888800000000000000000000000000000000000000000000000000000000000000000
0c0ee070e0c0070eee0c70eee0c0070ee00400eee0048880ee00400e0888400e0000000000000000000000000000000000000000000000000000000000000000
010ee0c0e0100c0eee01c0eee0100c0eee00eeeeee000480eeee00ee084000ee0000000000000000000000000000000000000000000000000000000000000000
00eeee00ee0ee0eeeee00eeeee0ee0eeeeeeeeeeeeeee000eeeeeeee000eeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeee0000eeee0000eeee0000eeeeeeeeeeeeeeeeeeee0000eeee0000eeee0000eeee0000ee
eeeeeeeeeee00eeeee0ee000ee0eeeee000ee0eeeeeee0eee077770ee077770ee077770ee077770eeeeeeeeeeee00eeee044480ee044480ee044480ee044480e
eeeeeeeeee03b0eee0100220e010eeee0220010eeeee010ee067070ee067070ee060770ee060770eeeeeeeeeee01c0eee047070ee047070ee060740ee060740e
ee0000eeee03b0ee02102220021000ee02220120ee000120e066770ee066770ee066770ee066770eee0000eeee01c0eee066770ee066770ee066770ee066770e
e03bbb0ee033bb0e0222210e0222220ee0122220e0222220ee0060eeee0060eeee0600eeee0600eee01ccc0ee011cc0eee006000ee006000000600ee000600ee
0333bbb0e0333b0ee00100eee0012220ee00100e0222100eee0600eeee0600eeee0060eeee0060ee0111ccc0e0111c0ee0477770e04777700777740e0777740e
03333330e033330eee00eeeeee000120eeee00ee021000eeee0660eee060060eee0660eee060060e01111110e011110eee06600ee060060ee00660eee060060e
e000000eee0000eeeeeeeeeeeeeee000eeeeeeee000eeeeeee000eeee00ee00eeee000eee00ee00ee000000eee0000eeee000eeee00ee00eeee000eee00ee00e
ee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e048880ee048880ee048880ee048880ee048880ee048880eeeee00eeeeeee00eeeeeeeeee00eeeeeeeee056666670eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e067070ee067070ee060770ee060770ee067070ee060770eeee060eeeeee060ee00000eee060eeeeeee05555556660eeee00000eee00000ee00000eee00000ee
e066770ee066770ee066770ee066770ee06677000066770eeee070eeeee070eee067760eee070eeeeee05555555560eee06550eee05550eeee05560eee05550e
ee0060eeee0060eeee0600eeee0600eeee006770066600eeeee070eeee070eeeee00000eeee070eeeee05555555560ee06550eee06650eeeeee05560eee05660
ee0600eeee0600eeee0060eeee0060eeee06000ee00060eeeee060eee060eeeeeeeeeeeeeeee060eeee01555555550ee06650eee06550eeeeee05660eee05560
ee0660eee060060eee0660eee060060eee0660eeee0660eeeee00eeee00eeeeeeeeeeeeeeeeee00eeee01555555550ee065550ee066550eeee055560ee055660
ee000eeee00ee00eeee000eee00ee00eee000eeeeee000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee015555550eeee0000000e00000000000000e0000000e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee05555555550eee000000ee000000eeeeeeeeee000000e
eeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee05755666770ee0566667004888870eeeeeeeee0cc770e
eeeeeeeeeeeeeeeeeeeeee0bb0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0075555555570e0155556002444480eeeeeeeee01cc70e
eeeeee0000eeeeeeeeeee0bbbb0eeeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000ee066515555555700155556002444480eeeeeeeee01c7c0e
eeee00bbbb00eeeeeeeee0bbbb0eeeee022200eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee002220eee06705556755700155556002444480eee00eeeee0cc0ee
eee0bbbbbbbb0eeeeeee0bbbbbb0eeee02112200eee00eeeeeeeeeeeeee00eeeeee00eee00221120ee065515515655600155556002444480ee0c70eeee0c70ee
ee0bbbbbbbbbb0eeeeee0bbbbbb0eeee0211112200e0100eeeeeeeeeeee0100ee0010e0022111120ee065505501555700011115001222240ee01c0eeee01c0ee
ee0bbbbbbbbbb0eeeeee03bbbb30eeeee021111122001220eeee000000001220022100221111120ee065550555555560e000000ee000000eeee00eeeeee00eee
e03bbbbbbbbbb30eeee0333333330eeee022211111222020ee00222222222020020222111112220ee00155505555550eeeeeeeeeeeeeeeee4444444444444444
e033bbbbbbbb330eeee0333333330eeee012222222222220e022222222222220022222222222210eeee01555011110eeeeeeeeeeeee00eee4444444444444444
e03333bbbb33330eeee0333333330eeeee0111112220000ee02222111110000ee0000222111110eeeee0111555550eeeeeeeeeeeee09a0ee4444444444444444
0333333333333330ee033333333330eeeee00000110eeeeee0111111110eeeeeeeeee01100000eeeeeee01111510eeeeee0000eeee09a0ee2222222222222222
0333333333333330ee033333333330eeeeeeeeee00eeeeeee011110000eeeeeeeeeeee00eeeeeeeeeeee01555560eeeee09aaa0ee099aa0e2222222222222222
0333333333333330ee033333333330eeeeeeeeeeeeeeeeeee00000eeeeeeeeeeeeeeeeeeeeeeeeeeeee0155555560eee0999aaa0e0999a0e2222222222222222
e03333333333330eee033333333330eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee011115155560ee09999990e099990eeeeeeeeeeeeeeeee
ee000000000000eeeee0000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000eee000000eee0000eeeeeeeeeeeeeeeeee
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000000000006262626262626262000000000000000074747474747474740000000000000000776777676767776700000000000000004b4b4b4b4b4b4b4b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000626262626262626200000000000000007545757575754575000000000000000077776767776777670000000000000000005a000000005a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505050505050500000000000000000626262626262626200000000000000007554757575755475000000000000000067676767776777670000000000000000006a000000006a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60606060606060600000000000000000626262626262626200000000000000007554757575755475000000000000000067677767676777770000000000000000006a000000006a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70707070707070700000000000000000626262626262626200000000000000007564755565756475000000000000000067486767677758670000000000000000007a000000007a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
404040404040404000000000000000004252424252524252000000000000000044444444444444440000000000000000574757575747574700000000000000004a4a4a4a4a4a4a4a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f4f4f4f4f4f4f83000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f4f4e4f4f4f5f930085868788898a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f4f4f4f4f5f81a30095969798999a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5f5f4f4f5f909192000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4d5d5e5f5fa0a1a24a4a4a4a4a4a4a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4d6d6e4d5f5f5f5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4d4d4d4d4d5f5f5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4d4d4d4d4d4d4d5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010200001361213622136321364213642136321362213612000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000211531515309153031530015300000210000d00009000060000500012000100000d0000c0000c0000b000090000800007000050000400003000020000200001000010000100001000010000100000000
010c0000211531513309153031330015300000210000d00009000060000500012000100000d0000c0000c0000b000090000800007000050000400003000020000200001000010000100001000010000100000000
01040000210531505309053030530005300000210000d00009000060000500012000100000d0000c0000c0000b000090000800007000050000400003000020000200001000010000100001000010000100000000
010400002462424625246232462300005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000018c001ac0021c001fc0018c0018c0018c0018c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000267742677524774247752177223775257722777527774277712777127771277712777127771277750000000000000000000000000000000000000000
012000002971423714287142371429714237142871423714297142371428714237142971423714287142371429724237242872423724297242372428724237242972423724287242372429724237242872423724
012000002972423724287242372429724237242872423724297242372428724237242972423724287242372429724237242872423724297242372428724237242972423724287242372429724237242872423724
01200000180541a0541f0541d054230541c045230541a0451c0521c0421c0321c0221705417055170551705517054180541d0541c054210541a0452105418045210541a04521054180451f0541f0451d0541d045
01200000001000010000100001002f7442f73528744287350010000100001000010026740267312672126711001000010000100001002d7442d73524744247350010000100001000010029744297352672426715
0120000021054230541f0541c0541f054210541d0541a0541c0521c0421c0321c0221a0541a0411a0311a02517054180541d0541c0541f0541d054180541d0541c0521c0451c0521c04517055170451703517025
01200000180001a0001f0001d000230001c000230001a0002674426731267212671521744217312172121715180001d0001c000210001a000210001800021000247442473124721247151f7441f7311f7211f715
012000001a754187541f7541a7541a754187541f7541a7541a754187541f7541a7541a754187541f7541a75418754177541d7541875418754177541d7541875418754177541d7541875418754177541d75418754
012000002802428021280212802128011280112801528024280252602426021260212602126011260112601526024260212602126021260112601126015260242602524024240212402124021240112401124015
012000001c714177001c7141c714157140000015714157141c724177001c7241c724157240000015724157241a724177001a7241a724137240000013724137241a734177001a7341a73413734000001373413734
012000001c744177001c7441c744157440000015744157441c744177001c7441c744157440000015744157441a744177001a7441a744137440000013744137441a744177001a7441a74413744000001374413744
012000001c052180001c0441c054180001c0541c045180001f052000001f0441f054000001f0541f045000001d052000001d0441d054000001d0541d0411d0351a0541a0411a0311a0251f0541f0451b0541b045
012000001c7141c7211c7311c7411c7411c7311c7211c7151f7141f7211f7311f7411f7411f7311f7211f7151d7141d7211d7311d7411d7411d7311d7211d7151a7441a7311a7211a7151c7441c7311c7211c715
012000001c1341c124171131c1341c124171131f1341d1251f1341f1241a1131f1341f1241a11323134211251d1341d124181131d1341d12418113211341f1251a1341a124151131a1341a124151131d1341c125
012000001307513073130751307313075130731307513073110751107311075110731107511073110751107310075100731007510073100751007310075100730e0750e0730e0750e0730e0750e0730e0750e073
012000001f1541f1451f1541f1411f1311f1211f1111f1151f124211342214424154241412413124125221542214521154211451d1541d1411d1411d1311d1311d1211d1211d1152115421145221542214122131
010500002212022121221212212122111221112211122115211542115121151211512115121141211412114121141211412113121131211312113121131211212112121121211212112121111211112111121115
012000000e0550e0530e0550e0530e0550e0530e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e000
012000002b5242b5212b5212b5212b5112b5112b5112b515305243052130521305213051130511305113051529524295212952129521295112951129511295152d5242d5212d5212d5212d5112d5112d5112d515
012000001303513033130351303313035130331303513033110451104311045110431104511043110451104310055100531005510053100551005310055100530e0650e0630e0650e0630e0650e0630e0650e063
011000000c1220c115000000b1220c122000000c1220c1120d1320d125186000c1320d132000020d1320d1220e1420e135000000d1420e142000020e1420e1320f1520f145000000e1520f152000020f1520f142
011000000c1550c1500c1450b1520c1500c1550c1550c1420d1550d1500d1450c1520d1500d1550d1550d1420e1550e1500e1450d1520e1500e1550e1550e1420f1550f1500f1450e1520f1500f1550f1550f142
01100000180341803118021180211801118015180551804519034190311902119021190111901519055190451a0341a0311a0211a0211a0111a0151a0551a0451b0341b0311b0211b0211b0111b0151b0551b045
01100000105751057210565105751757417565155750e5651357511570115650e5740e5650f5750c5750c562105751057210565105751757417565155750e5651357511570115650e5740e5650f5751357513562
011000000f0520f0450f0550b0520b0450e0550e0520e0450d0520d0450d05509052090450c0550c0520c0450f0520f0450f0550b0520b0450e0550e0520e0450d0520d0450d0550905209045130551305213045
011000000f5720f5650f5750b5720b5650e5750e5720e5650d5720d5650d57509570095620955209542095350f5720f5650f5750b5720b5650e5750e5720e5650d5720d565125751257012562125521254212535
011000000f7520f7450f7550b7520b7450e7550e7520e7450d7520d7450d7500d7410d7351a7521f7421d7320f7520f7450f7550b7520b7450e7550e7520e74514752147451475014741147351a7521d74221732
011000000f5720f5650f5750b5720b56513575135721356213552135421354213532135321352213522135150f5720f5650f5750b5720b565125750e5720e5620e5520e5420e5420e5320e5320e5220e5220e515
011000000000000000000000000018635000000000000000000000000000000000000000000000181330000000000000000000000000186350000000000000000000000000000000000000000000001813300000
0110000000000000000000000000000000000000000000000000000000000000000000000186151a6251c63500000000000000000000000000000000000000000000000000000000000000000186151a6251c635
01180000305240000000000000003052400000000000000030524000000000000000305240000000000000002f5140000000000000002f5140000000000000002f5140000000000000002f514000000000000000
0118000015754157451a7541a7511a7511a7411a7411a7411a7311a7311a7311a7211a7211a7211a7111a71515754157451875418751187511874118741187411873118731187311872118721187211871118715
011800000000000000000000000000000000000000018100000000000000000000000000000000000001813300000000000000000000000000000000000181000000000000000000000000000000000000018133
0118000015754157451a7541a7451f7541f7451e7541e7451a7541a7411a7411a7311a7311a7211a7211a715137541374518754187451d7541d7451c7541c7451875418741187411873118731187211872118715
011800002d7542170000000000002d744217002d7342170000000000000000000000000000000000000000002b7541370000000000002b744217002b734217000000000000000000000000000000000000000000
0118000015754157451a7541a7511a7511a7511a7511a7511a7411a7411a7411a7411a7411a7411a7311a7311a7311a7311a7311a7311a7211a7211a7211a7211a7211a7211a7111a7111a7111a7111a7111a715
011800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 08 42 43 44
01 09 0a 0b 44
00 09 0a 0b 44
00 09 0c 0d 44
02 09 0c 0d 44
01 0e 42 43 44
00 0e 0f 43 44
02 0e 0f 43 44
00 10 42 43 44
01 11 12 43 44
00 11 12 13 44
00 11 12 13 14
02 11 12 13 14
00 1a 42 43 44
01 15 16 43 44
00 17 18 43 44
00 15 16 19 44
02 17 18 43 44
00 1b 42 43 44
00 1c 1d 43 44
01 1e 1f 23 44
00 1e 1f 23 44
00 20 21 24 44
00 20 21 24 44
02 22 21 43 44
01 25 42 43 44
00 25 26 43 44
00 25 26 27 44
00 25 28 27 44
00 25 28 27 29
02 25 2a 27 29
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
