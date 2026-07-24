pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
// init

function _init()
 palt(0, false)
 palt(11, true)
 cartdata('jfire45_msgtale_2')
 debug = 0
 if debug == 1 then poke(0x5f2d, 1) end
 -- global timer
 t = 0
 -- extra variables
 if peek(0x5e00) == 1 then pointer = 80
 else pointer = 72
 end
 -- game
 state = 0
 story = 0
 location = 'town'
 mus = 'none'
 mapx = 1
 mapy = 2
 boatin = 0
 boatmapx = 5
 boatmapy = 1
 boatx = 10
 boaty = 1
 toggle = 0
 csent = {} // cutscene entities
 enemies = {}
 -- text
 textstr = 'i need to deliver the king\'s ^lletter today.'
 textstr2 = ''
 texty = 0
 textt = 180
 -- player
 px = 6
 py = 7
 ppx = 6
 ppy = 7
 pf = 1
 php = 100
 patk = 8
 pdef = 0
 -- enemies
 etype = 1
 ename = '???'
 ehp = 1
 espr = 0
 -- battle
 bw = 0
 bturn = 1
 zbx = 2
 zbc = 7
end

// custom functions

function printborder(text, x, y, clr, bclr)
 print(text, x - 1, y, bclr)
 print(text, x + 1, y, bclr)
 print(text, x, y - 1, bclr)
 print(text, x, y + 1, bclr)
 print(text, x - 1, y - 1, bclr)
 print(text, x - 1, y + 1, bclr)
 print(text, x + 1, y - 1, bclr)
 print(text, x + 1, y + 1, bclr)
 print(text, x, y, clr)
end

function printc(text,x,y)
 local l=x
 local s=7
 local o=1
 local i=1
 local n=#text+1
 while i<=n do
  local c=sub(text,i,i)
  if c=="^" or c=="" then
   i+=1
   local p=sub(text,o,i-2)
   print(p,l,y,s)
   l+=4*#p
   o=i+1
   c=sub(text,i,i)
   if c=="l" then
    l=x
    y+=6
   else
    for k=1,16 do
     if c==sub("0123456789abcdef",k,k) then
      s=k-1
      break
     end
    end
   end
  end
  i+=1
 end
end

function walltile(xx, yy, ff)
 return fget(mget(xx, yy), ff)
end

function equipname(equip)
 local name = '???'
 if equip == 1 then
  if patk == 8 then name = 'book'
  elseif patk == 10 then name = 'baseball bat'
  elseif patk == 12 then name = 'shortsword'
  elseif patk == 15 then name = 'harpoon gun'
  end
 elseif equip == 2 then
  if pdef == 0 then name = 'clothing'
  elseif pdef == 5 then name = 'dad\'s shirt'
  elseif pdef == 10 then name = 'brown hoodie'
  end
 end
 return name
end

function spawnenemies() -- tag spawnenemies
 for i in all(enemies) do
  del(enemies, i)
 end
 if location == 'gobtrl' then
  repeat
   xx = 4 + flr(rnd(9))
   yy = 4 + flr(rnd(9))
  until walltile(mapx * 16 + xx, mapy * 16 + yy, 0) == false
  etype = 1
  add(enemies, {name = 'goblin',
  hp = 20, f = 3 + flr(rnd(2)),
  bf = 3, x = xx, y = yy, bspr = 49,
  dead = 0})
 elseif location == 'volcano' and mapx == 7 and mapy == 1 then
  while #enemies < 2 do
   repeat
    xx = 4 + flr(rnd(9))
    yy = flr(rnd(9))
   until walltile(mapx * 16 + xx, mapy * 16 + yy, 0) == false
   etype = 1
   add(enemies, {name = 'goblin elite',
   hp = 40, f = 5 + flr(rnd(2)),
   bf = 5, x = xx, y = yy, bspr = 51,
   dead = 0})
  end
 end
end

// update

function locandmus() -- tag locandmus
 if location != 'evap' then
  if mapx == 1 and mapy == 2 then location = 'town'
  elseif mapx == 2 and mapy == 2 then location = 'town'
  elseif mapx == 3 and mapy == 2 then location = 'gobtrl'
  elseif mapx == 4 and mapy == 2 then location = 'gobtrl'
  elseif mapx == 5 and mapy == 2 then location = 'town'
  elseif mapx == 5 and mapy == 3 then location = 'town'
  elseif mapx == 5 and mapy == 1 then location = 'town'
  elseif mapx == 4 and mapy == 3 then location = 'gybase'
  elseif mapx == 5 and mapy == 0 and location != 'volcano2' then location = 'island'
  elseif mapx == 4 and mapy == 0 and location != 'volcano2' then location = 'island'
  elseif mapx == 7 and mapy == 2 and location != 'volcano2' then location = 'volcano'
  end
 end
 if story >= 8.1 and story < 9 and mus != 'evap' then
  location = 'evap'
  mus = 'evap'
  music(20)
 elseif story == 3 and mus != 'evap' then
  location = 'evap'
  mus = 'evap'
  music(20)
 elseif location == 'evap' and story != 3 and (story < 8.1 or story >= 9) then
  location = ''
 elseif state == 3 then
  if mus != 'battlemus' then
   mus = 'battlemus'
   if etype == 1 then music(3)
   elseif etype == 2 then music(15)
   end
  end
 elseif location == 'town' and mus != 'town' then
  mus = 'town'
  music(0)
 elseif location == 'gobtrl' and mus != 'gobtrl' then
  mus = 'gobtrl'
  music(12)
 elseif location == 'gybase' and mus != 'gobtrl' then
  mus = 'gybase'
  music(-1)
 elseif location == 'island' and mus != 'island' then
  mus = 'island'
  music(9)
 elseif location == 'volcano' and mus != 'volcano' then
  mus = 'volcano'
  music(-1)
 elseif location == 'volcano2' and mus != 'volcano2' then
  mus = 'volcano2'
  music(19)
 end
end

function tilestory()
 if story == 4 and state == 3 then
  mset(71, 52, 69)
  mset(72, 50, 69)
 elseif story == 9 and state == 3 then
  mset(119, 10, 0)
  mset(120, 10, 0)
 elseif story == 10 and mapx == 4 and mapy == 0 then
  textstr = 'soldiers: over here! hurry!^lit\'s about to blow!'
  textt = 180
  story = 11
 elseif story == 11 and mapx == 1 and mapy == 2 then
  textstr = 'finally, i\'m home.'
  textt = 180
  story = 12
 end
end

function storycheck()
 if story == 2 and mapx == 4 and mapy == 3 and py <= 11 then
  story = 3
  textstr = 'king: who has come here?^lperish before my blade!'
  textt = 180
 elseif story == 3 then
  if py <= 7 then
   textstr = 'i... i can\'t leave!'
   textt = 180
  end
  if btnp(ƒ) then py -= 1 end
  if py < 5 then py = 5 end
  if btnp(‹) and px < 8 then px += 1
  elseif btnp(‘) and px > 7 then px -= 1
  end
 elseif story == 4 then
  if btnp(ƒ) or btnp(”) or btnp(‘) then
   textstr = 'maybe i should pick that up.'
   textt = 180
  end
  if btnp(ƒ) then py -= 1 end
  if btnp(‹) and px < 8 then px += 1
  elseif btnp(‘) and px > 7 then px -= 1
  end
 elseif story == 5 and (((mapx == 5 or mapx == 6) and mapy == 2) or (mapx == 4 and mapy == 3)) then
  if mget(82, 37) == 0 then
   mset(82, 37, 16)
   mset(81, 38, 17)
   mset(82, 39, 17)
   mset(81, 40, 16)
   mset(82, 41, 17)
   mset(81, 37, 18)
   mset(80, 38, 18)
   mset(81, 39, 19)
   mset(80, 40, 19)
   mset(81, 41, 18)
   mset(94, 38, 17)
   mset(95, 39, 17)
   mset(94, 40, 16)
   mset(95, 37, 16)
   mset(95, 41, 17)
   mset(97, 37, 19)
   mset(96, 38, 18)
   mset(97, 39, 19)
   mset(96, 40, 19)
   mset(97, 41, 18)
   mset(87, 44, 20)
   mset(71, 50, 69)
   mset(90, 21, 0)
  elseif t % 20 == 0 then
   for yy = 0, 63, 1 do
    for xx = 0, 127, 1 do
     if mget(xx, yy) == 16 then mset(xx, yy, 17)
     elseif mget(xx, yy) == 17 then mset(xx, yy, 16)
     elseif mget(xx, yy) == 18 then mset(xx, yy, 19)
     elseif mget(xx, yy) == 19 then mset(xx, yy, 18)
     end
    end
   end
  end
 end
end

function tilecheck()
 local tx = mapx * 16 + px
 local ty = mapy * 16 + py
 if mget(tx, ty - 1) == 84 and story == 12 then
  story = 13
  poke(0x5e0c, 100)
  if patk == 8 and pdef == 0 then poke(0x5e0d, 100) end
 elseif mget(tx, ty - 1) == 84 and story == 11 then
  textstr = 'i can\'t sleep here!'
  textt = 180
 elseif mget(tx, ty - 1) == 84 then
  poke(0x5e00, 1)
  poke(0x5e01, patk)
  poke(0x5e02, pdef)
  poke(0x5e03, mapx)
  poke(0x5e04, mapy)
  poke(0x5e05, px)
  poke(0x5e06, py)
  poke(0x5e07, story)
  poke(0x5e08, boatmapx)
  poke(0x5e09, boatmapy)
  poke(0x5e0a, boatx)
  poke(0x5e0b, boaty)
  php = 100
  textstr = '^cyou slept for a while.^lhp restored and progress saved.'
  textt = 180
 elseif mget(tx, ty - 1) == 82 or mget(tx, ty - 1) == 83 then
  if story == 0 then
   story = 1
   textstr = '^ayou received the king\'s letter.^ltime to leave now.'
   textt = 180
  elseif story == 1 and mapx == 5 then
   story = 2
   textstr = 'i gave the letter to the east^lcastle. time to go home now.'
   textt = 180
  end
 elseif tx == 80 and ty == 17 and patk < 15 then
  patk = 15
  textstr = '^ayou found a harpoon gun^l(15 atk) on a rock. cool!'
  textt = 180
 elseif tx == 99 and ty == 1 and pdef < 5 then
  pdef = 5
  textstr = '^ayou found ^8dad^a\'s shirt...^l....... (5 def)'
  textt = 180
 elseif tx == 38 and ty - 1 == 37 and patk < 10 then
  patk = 10
  textstr = '^ayou found a baseball bat (10^latk) lying against the door.'
  textt = 180
 elseif tx == 90 and ty - 1 == 19 then
  textstr = 'elder: you need my boat?^lit\'s just up there.'
  textt = 180
 elseif tx == 89 and ty == 19 then
  textstr = 'elder: a safe place? there\'s^la small island to the north.'
  textt = 180
 elseif tx == 103 and ty - 1 == 33 then
  textstr = 'a note is stuck onto the door.^l[not home rn. b back later.]'
  textt = 180
 elseif tx == 83 and ty - 1 == 3 then
  if story == 5 then
   textstr = 'woman: who\'s there?'
   textt = 180
   story = 6
  elseif story == 6 then
   textstr = 'woman: that necklace! how did^lyou manage to get that?'
   textt = 180
   story = 6.1
  elseif story == 6.1 then
   textstr = 'woman: come inside.'
   textt = 180
   story = 6.15
  elseif story == 6.15 then
   mset(82, 4, 111)
   mset(82, 5, 111)
   mset(83, 5, 111)
   mset(84, 5, 111)
   mset(84, 4, 111)
   php = 100
   textstr = '^cyou slept for a while.^lhp restored.'
   textt = 180
   story = 6.2
  elseif story == 6.2 then
   textstr = 'woman: ...oh. you\'re awake.'
   textt = 180
   if pdef == 5 then story = 6.21
   else story = 6.25
   end
  elseif story == 6.21 then
   textstr = 'woman: your shirt looks^lpretty torn up.'
   textt = 180
   story = 6.22
  elseif story == 6.22 then
   textstr = 'woman: here\'s one of my old^lhoodies. you can have it.'
   textt = 180
   story = 6.23
  elseif story == 6.23 then
   pdef = 10
   textstr = '^ayou received a brown hoodie^l(10 def) from the woman.'
   textt = 180
   story = 6.25
  elseif story == 6.25 then
   textstr = 'woman: .......'
   textt = 180
   story = 6.3
  elseif story == 6.3 then
   textstr = 'woman: that necklace used to^lbelong to the first king of the'
   textt = 180
   story = 6.4
  elseif story == 6.4 then
   textstr = 'eastern kingdom. he used it^lto control his people.'
   textt = 180
   story = 6.5
  elseif story == 6.5 then
   textstr = 'woman: the people managed to^loverthrow him, and the necklace'
   textt = 180
   story = 6.6
  elseif story == 6.6 then
   textstr = 'was buried with the second^lking and his wife.'
   textt = 180
   story = 6.7
  elseif story == 6.7 then
   textstr = 'woman: it seems like the^lgoblins are after it now.'
   textt = 180
   story = 6.8
  elseif story == 6.8 then
   textstr = 'woman: tch. it should^lhave been destroyed long ago.'
   textt = 180
   story = 6.9
  elseif story == 6.9 then
   textstr = 'woman: there\'s a volcano west^lof here. toss it in there.'
   textt = 180
   story = 6.91
  elseif story == 6.91 then
   mset(82, 4, 0)
   mset(82, 5, 0)
   mset(83, 5, 0)
   mset(84, 5, 0)
   mset(84, 4, 0)
   mset(87, 11, 65)
   story = 7
  else
   textstr = 'woman: ...zzz'
   textt = 180
  end
 elseif tx == 70 and ty == 11 then
  textstr = 'resident: hey you!^li haven\'t seen you before.'
  textt = 180
 elseif mget(tx, ty - 1) == 68 then
  textstr = 'the door seems to be locked.'
  textt = 180
 elseif mget(tx, ty - 1) == 98 then
  textstr = 'here lies ~-~-~.'
  textt = 180
 elseif mget(tx, ty - 1) == 100 then
  if story == 2 then
   textstr = 'wait...^lthere\'s something here...'
   textt = 180
   if btnp(”) then
    mapx = 4
    textstr = ''
    textt = 0
   end
  else
   textstr = 'here lies the previous king^land his wife, the queen.'
   textt = 180
  end
 elseif mget(tx, ty - 1) == 99 then
  if patk < 12 then
   patk = 12
   textstr = '^ayou found a shortsword (12^latk) stuck into the ground.'
   textt = 180
  else
   textstr = 'here lies ^8dad^7...'
   textt = 180
  end
 elseif mget(tx, ty - 1) == 113 then
  textstr = 'go back up?'
  textt = 180
  if btnp(”) then
   mapx = 5
   textstr = ''
   textt = 0
  end
 elseif mget(tx, ty - 1) == 32 then
  etype = 2
  ename = 'fallen king'
  ehp = 100
  emaxhp = ehp
  espr = 50
  state = 2
  story = 4
 elseif mget(tx, ty - 1) == 34 then
  story = 5
  textstr = '^ayou picked up a necklace.^l...?'
  textt = 180
 elseif mget(tx, ty - 1) == 119 or mget(tx, ty - 1) == 120 then
  if story >= 11 then
   textstr = 'soldiers: where are you going?'
   textt = 180
  else
   mapx = 7
   mapy = 2
   px = 7
   py = 14
  end
 elseif (tx == 119 or tx == 120) and ty == 47 then
  mapx = 4
  mapy = 0
  px = 5
  py = 8
 elseif tx == 120 and ty == 34 then
  mapy = 1
  px = 8
  py = 12
  csent = {}
  spawnenemies()
 elseif tx == 120 and ty == 28 then
  if story >= 10 then
   mapy = 2
   px = 8
   py = 2
   spawnenemies()
  else
   textstr = 'i have to keep going!'
   textt = 180
  end
 elseif (tx == 119 or tx == 120) and ty == 13 then
  if story == 8 then
   mset(tx + 1, ty, 95)
   mset(tx - 1, ty, 95)
   mset(tx, ty + 1, 95)
   mset(tx, ty - 1, 95)
   mset(tx - 1, ty + 1, 95)
   mset(tx + 1, ty + 1, 95)
   textstr = 'goblin leader: ah.^lthere you are.'
   textt = 180
   story = 8.1
  elseif story == 8.1 then
   textstr = 'goblin leader: i\'m suprised^lyou made it up here.'
   textt = 180
   story = 8.2
  elseif story == 8.2 then
   textstr = 'goblin leader: even my elites^lcouldn\'t defeat you.'
   textt = 180
   story = 8.3
  elseif story == 8.3 then
   textstr = 'goblin leader: that doesn\'t^lmatter now.'
   textt = 180
   story = 8.4
  elseif story == 8.4 then
   textstr = 'goblin leader: give me the^lnecklace.'
   textt = 180
   story = 8.5
  elseif story == 8.5 then
   textstr = 'goblin leader: ...'
   textt = 180
   story = 8.6
  elseif story == 8.6 then
   textstr = 'goblin leader: no? you must^lbe mistaken.'
   textt = 180
   story = 8.7
  elseif story == 8.7 then
   textstr = 'goblin leader: you don\'t have^la choice.'
   textt = 180
   story = 8.8
  elseif story == 8.8 then
   mset(tx + 1, ty, 69)
   mset(tx - 1, ty, 69)
   mset(tx, ty + 1, 69)
   mset(tx, ty - 1, 69)
   mset(tx - 1, ty + 1, 69)
   mset(tx + 1, ty + 1, 69)
   prephp = php
   textstr = ''
   texty = 0
   textt = 0
   etype = 2
   ename = 'goblin leader'
   ehp = 120
   emaxhp = ehp
   espr = 52
   state = 2
   story = 9
  end
 elseif location == 'volcano' and py <= 9 and story < 8 then
  if story == 7 then
   for yy = 0, 63, 1 do
    for xx = 0, 127, 1 do
     if mget(xx, yy) == 95 then mset(xx, yy, 69) end
    end
   end
   mset(tx + 1, ty, 95)
   mset(tx - 1, ty, 95)
   mset(tx, ty + 1, 95)
   mset(tx, ty - 1, 95)
   textstr = '???: ha! got\'cha!'
   textt = 180
   story = 7.1
  elseif story == 7.1 then
   add(csent, {f = 5, bf = 5,
   x = 7, y = 15, dx = 5,
   dy = 4})
   add(csent, {f = 3, bf = 3,
   x = 7, y = 15, dx = 4,
   dy = 6})
   add(csent, {f = 3, bf = 3,
   x = 7, y = 15, dx = 3,
   dy = 8})
   add(csent, {f = 3, bf = 3,
   x = 7, y = 15, dx = 4,
   dy = 10})
   add(csent, {f = 3, bf = 3,
   x = 7, y = 15, dx = 5,
   dy = 12})
   add(csent, {f = 5, bf = 5,
   x = 8, y = 15, dx = 10,
   dy = 4})
   add(csent, {f = 3, bf = 3,
   x = 8, y = 15, dx = 11,
   dy = 6})
   add(csent, {f = 3, bf = 3,
   x = 8, y = 15, dx = 12,
   dy = 8})
   add(csent, {f = 3, bf = 3,
   x = 8, y = 15, dx = 11,
   dy = 10})
   add(csent, {f = 3, bf = 3,
   x = 8, y = 15, dx = 10,
   dy = 12})
   pret = t
   story = 7.2
  elseif story == 7.3 then
   textstr = 'goblin elite: give me that^lnecklace, or we\'ll stomp you!'
   textt = 180
   story = 7.4
  elseif story == 7.4 then
   textstr = '???: halt!'
   textt = 180
   story = 7.5
  elseif story == 7.5 then
   add(csent, {f = 16, bf = 16,
   x = 7, y = 15, dx = 6,
   dy = 4})
   add(csent, {f = 16, bf = 16,
   x = 7, y = 15, dx = 5,
   dy = 6})
   add(csent, {f = 16, bf = 16,
   x = 7, y = 15, dx = 4,
   dy = 8})
   add(csent, {f = 16, bf = 16,
   x = 7, y = 15, dx = 5,
   dy = 10})
   add(csent, {f = 16, bf = 16,
   x = 7, y = 15, dx = 6,
   dy = 12})
   add(csent, {f = 16, bf = 16,
   x = 8, y = 15, dx = 9,
   dy = 4})
   add(csent, {f = 16, bf = 16,
   x = 8, y = 15, dx = 10,
   dy = 6})
   add(csent, {f = 16, bf = 16,
   x = 8, y = 15, dx = 11,
   dy = 8})
   add(csent, {f = 16, bf = 16,
   x = 8, y = 15, dx = 10,
   dy = 10})
   add(csent, {f = 16, bf = 16,
   x = 8, y = 15, dx = 9,
   dy = 12})
   pret = t
   story = 7.6
  elseif story == 7.7 then
   textstr = 'soldier: we\'ll stall them.^lmessenger, keep going!'
   textt = 180
   story = 7.8
  elseif story == 7.8 then
   mset(tx + 1, ty, 69)
   mset(tx - 1, ty, 69)
   mset(tx, ty + 1, 69)
   mset(tx, ty - 1, 69)
   textstr = ''
   texty = 0
   textt = 0
   story = 8
  end
 elseif story == 9 and tx == 116 and ty == 10 then
  textstr = 'you throw the necklace.^lthe ground is suddenly shaking!'
  textt = 180
  story = 10
  mset(69, 14, 35)
  mset(71, 15, 35)
  mset(70, 17, 65)
  location = 'volcano2'
  mset(69, 4, 75)
  mset(70, 4, 76)
  mset(68, 5, 90)
  mset(69, 5, 91)
  mset(70, 5, 92)
  mset(71, 5, 93)
  mset(68, 6, 106)
  mset(69, 6, 107)
  mset(70, 6, 108)
  mset(71, 6, 109)
  mset(68, 7, 122)
  mset(69, 7, 123)
  mset(70, 7, 124)
  mset(71, 7, 125)
 end
end

function boatcheck() -- tag boatcheck
 for yy = 0, 63, 1 do
  for xx = 0, 127, 1 do
   if mget(xx, yy) == 97 then mset(xx, yy, 65) end
  end
 end
 local tx = mapx * 16 + px
 local ty = mapy * 16 + py
 local tpx = mapx * 16 + ppx
 local tpy = mapy * 16 + ppy
 local tbx = boatmapx * 16 + boatx
 local tby = boatmapy * 16 + boaty
 if boatin == 1 then
  if mget(tx, ty) == 96 then
   boatin = 0
   fset(65, 0, true)
  elseif mget(tx, ty) != 65 then
   px = ppx
   py = ppy
  end
  if boatin == 1 then
   boatx = px
   boaty = py
   boatmapx = mapx
   boatmapy = mapy
   local tx = mapx * 16 + px
   local ty = mapy * 16 + py
   mset(tpx, tpy, 65)
   mset(tx, ty, 97)
  end
 else
  mset(boatmapx * 16 + boatx, boatmapy * 16 + boaty, 97)
  if mget(tx, ty) == 97 then
   boatin = 1
   fset(65, 0, false)
  end
 end
end

function battlecheck()
 if #enemies > 0 then
  for i in all(enemies) do
   if (i.x == px + 1 and i.y == py) or
   (i.x == px - 1 and i.y == py) or
   (i.x == px and i.y == py + 1) or
   (i.x == px and i.y == py - 1) or
   (i.x == px and i.y == py) then
    ename = i.name
    ehp = i.hp
    emaxhp = i.hp
    espr = i.bspr
    i.dead = 1
    state = 2
   end
  end
 end
end

function _update60()
 t += 1
 -- update location and music
 locandmus()
 -- update tiles according to story
 tilestory()
 -- credits
 if (state == -1 or state == -2) and btnp(Ž) then state = 0
 -- title
 elseif state == 0 then
  if btnp(ƒ) and pointer < 96 then pointer += 8
  elseif btnp(”) and pointer > 72 then pointer -= 8
  end
  if btnp(Ž) then
   if pointer == 72 then state = 1
   elseif pointer == 80 and peek(0x5e00) == 1 then
    patk = peek(0x5e01)
    pdef = peek(0x5e02)
    mapx = peek(0x5e03)
    mapy = peek(0x5e04)
    px = peek(0x5e05)
    py = peek(0x5e06)
    story = peek(0x5e07)
    boatmapx = peek(0x5e08)
    boatmapy = peek(0x5e09)
    boatx = peek(0x5e0a)
    boaty = peek(0x5e0b)
    state = 1
    if story > 0 then
     textstr = ''
     texty = 0
     textt = 0
    end
   elseif pointer == 88 then state = -2
   elseif pointer == 96 then state = -1
   end
   if state == 1 then
    pmapx = mapx
    pmapy = mapy
   end
  end
 -- game
 elseif state == 1 then
  -- update cutscene entities
  if t % 6 == 0 then
   for i in all(csent) do
    i.f += 1
    if i.f > i.bf + 1 then i.f = i.bf end
    if i.x < i.dx and walltile((mapx * 16 + i.x) + 1, mapy * 16 + i.y, 0) == false then i.x += 1
    elseif i.x > i.dx and walltile((mapx * 16 + i.x) - 1, mapy * 16 + i.y, 0) == false then i.x -= 1
    elseif i.y < i.dy and walltile(mapx * 16 + i.x, (mapy * 16 + i.y) + 1, 0) == false then i.y += 1
    elseif i.y > i.dy and walltile(mapx * 16 + i.x, (mapy * 16 + i.y) - 1, 1) == true then i.y -= 1
    elseif i.y > i.dy and walltile(mapx * 16 + i.x, (mapy * 16 + i.y) - 1, 0) == false then i.y -= 1
    end
   end
  end
  -- cutscene extras
  if story == 7.2 and t == pret + 66 then
   textstr = 'goblin elite: suprised?^lwe were hiding outside!'
   textt = 180
   story = 7.3
  elseif story == 7.6 and t == pret + 66 then
   textstr = 'soldier: we had tracked^lyour whereabouts.'
   textt = 180
   story = 7.7
  end
  -- screen shake
  if location == 'volcano2' and mapx == 7 then camera(-0.2 + rnd(0.4), -0.2 + rnd(0.4))
  else camera(0, 0)
  end
  -- update according to story
  storycheck()
  -- turn update
  if btnp(”) or btnp(ƒ) or btnp(‹) or btnp(‘) then
  	-- move player
  	if btnp(”) and walltile(mapx * 16 + px, (mapy * 16 + py) - 1, 0) == false then py -= 1
  	elseif btnp(ƒ) and walltile(mapx * 16 + px, (mapy * 16 + py) + 1, 0) == false then py += 1
  	elseif btnp(‹) and walltile((mapx * 16 + px) - 1, mapy * 16 + py, 0) == false then px -= 1
  	elseif btnp(‘) and walltile((mapx * 16 + px) + 1, mapy * 16 + py, 0) == false then px += 1
  	end
  	-- check for special tiles
  	tilecheck()
  	-- check if inside boat
  	boatcheck()
  	-- set ppx and ppy
  	ppx = px
  	ppy = py
  	-- map change
  	if px == -1 then
  	 if story == 2 and mapx == 5 and mapy == 2 then
  	  px += 1
  	  textstr = 'there are a lot of goblins now.^li have to find another way.'
    	textt = 180
  	 else
   	 px = 15
   	 mapx -= 1
   	 locandmus()
   	 spawnenemies()
   	end
  	elseif px == 16 then
  	 if story == 0 then
  	  px -= 1
  	  textstr = 'i should get the king\'s letter^lbefore i leave.'
    	textt = 180
    elseif story >= 1 and mapx == 5 and mapy == 2 and story <= 2 then
     px -= 1
  	  textstr = 'guards: sorry, but you cannot^lpass. it\'s too dangerous!'
    	textt = 180
    elseif story == 11 and mapx == 4 and mapy == 0 then
     px -= 1
  	  textstr = 'soldiers: where are you going?'
    	textt = 180
    elseif story == 12 and mapx == 1 and mapy == 2 then
     px -= 1
  	  textstr = 'whoops! wrong way!'
    	textt = 180
  	 else
   	 px = 0
   	 mapx += 1
   	 locandmus()
   	 spawnenemies()
   	end
  	elseif py == -1 then
  	 if story == 2 and mapx == 5 and mapy == 3 then
  	  py += 1
  	  textstr = 'huh?^lwhy is the gate locked?'
    	textt = 180
  	 else
  	  if story == 5 and mapx == 5 and mapy == 3 then
  	   textstr = 'guard: that necklace!^lyou must keep it safe!'
    	 textt = 180
  	  end
   	 py = 15
   	 mapy -= 1
   	 locandmus()
   	 spawnenemies()
   	end
  	elseif py == 16 then
   	if story == 5 and mapx == 5 and mapy == 2 then
   	 py -= 1
   	 textstr = 'i definitely don\'t want to^lgo back there again.'
   	 textt = 180
   	elseif story >= 5 and story < 99 and mapx == 5 and mapy == 0 then
   	 py -= 1
   	 textstr = 'i can\'t go back now.'
   	 textt = 180
   	elseif story < 10 and mapx == 7 and mapy == 0 then
   	 py -= 1
   	 textstr = 'i have to throw this^lnecklace into that lava pit.'
   	 textt = 180
   	else
   	 py = 0
   	 mapy += 1
   	 locandmus()
    	spawnenemies()
    end
  	end
  	-- sprite change
  	if pf == 1 then pf = 2
  	else pf = 1
  	end
  	-- battle check 1
  	battlecheck()
  	-- enemy update
  	for i in all(enemies) do
  	 if state == 1 then
   	 local mt = rnd(1)
   	 if mt <= 0.5 then
    	 if i.x < px and walltile((mapx * 16 + i.x) + 1, mapy * 16 + i.y, 0) == false then i.x += 1
    	 elseif i.x > px and walltile((mapx * 16 + i.x) - 1, mapy * 16 + i.y, 0) == false then i.x -= 1
    	 elseif i.y < py and walltile(mapx * 16 + i.x, (mapy * 16 + i.y) + 1, 0) == false then i.y += 1
    	 elseif i.y > py and walltile(mapx * 16 + i.x, (mapy * 16 + i.y) - 1, 0) == false then i.y -= 1
    	 end
    	else
    	 if i.y < py and walltile(mapx * 16 + i.x, (mapy * 16 + i.y) + 1, 0) == false then i.y += 1
    	 elseif i.y > py and walltile(mapx * 16 + i.x, (mapy * 16 + i.y) - 1, 0) == false then i.y -= 1
    	 elseif i.x < px and walltile((mapx * 16 + i.x) + 1, mapy * 16 + i.y, 0) == false then i.x += 1
    	 elseif i.x > px and walltile((mapx * 16 + i.x) - 1, mapy * 16 + i.y, 0) == false then i.x -= 1
    	 end
    	end
    	if i.f == i.bf + 1 then i.f = i.bf
    	else i.f = i.bf + 1
    	end
   	end
  	end
  	-- battle check 2
  	battlecheck()
  end
 -- fade to black
 elseif state == 2 then
  textstr = ''
  if bw < 64 then bw += 1
  else state = 3
  end
  mset(125, 58, espr)
 -- battle
 elseif state == 3 then
  -- player turn
  if bturn == 1 then
   textstr2 = 'press Ž to attack!'
   if btnp(Ž) then
    bturn = 1.1
    zbx = 2
    zbc = 7
   end
  elseif bturn == 1.1 then
   textstr2 = 'press Ž at the red zone!'
   textstr = '<|--------------------^8-----^7--|>'
   zbx += 2
   if zbx > 108 then zbc = 7
   elseif zbx + 6 > 90 then zbc = 10
   end
   if btnp(Ž) then
    if zbc == 10 then
     local dmg = patk - flr(rnd(3))
     ehp -= dmg
     textstr2 = 'you dealt '..dmg..' damage!'
     bturn = 1.2
    else
     textstr2 = 'you missed your attack!'
     bturn = 1.2
    end
   end
  -- enemy turn
  elseif btnp(Ž) and bturn == 1.2 then
   if ehp > 0 then
    textstr = ''
    textstr2 = ename..' is attacking!'
    bturn = 1.3
   else
    if ename == 'goblin leader' and php == prephp then poke(0x5e0e, 100) end
    mset(125, 58, 98)
    textstr2 = '^adefeated '..ename..'!'
    textstr = ''
    bturn = 4
   end
  elseif btnp(Ž) and bturn == 1.3 then
   if ename == 'goblin' then
    eatktype = 1
    eatk = 20
    textstr2 = 'press Ž at the red zone!'
    textstr = '<|--^8---^7----------------------|>'
    zbx = 128
    zbc = 7
   elseif ename == 'fallen king' then
    eatktype = 2
    eatk = 20
    textstr2 = 'press Ž at the red zone!'
    textstr = '<|--^8---^7----------------------|>'
    zbx = 128
    zbc = 7
   elseif ename == 'goblin elite' then
    eatktype = 3
    eatk = 25
    textstr2 = 'press Ž at the red zone!'
    textstr = '<|--^8---^7----------------------|>'
    zbx = 128
    zbc = 7
   elseif ename == 'goblin leader' then
    eatktype = 4 + flr(rnd(2))
    if eatktype == 4 then
     eatk = 30
     textstr2 = 'press Ž at the red zone!'
     textstr = '<|--^8---^7----------------------|>'
     zbx = 128
     zbc = 7
    elseif eatktype == 5 then
     eatk = 35
     textstr2 = 'press Ž at the red zone!'
     textstr = '<|--^8---^7----------------------|>'
     zbx = 128
     zbc = 7
    end
   end
   bturn = 2
  elseif bturn >= 2 and bturn < 2.1 then
   if eatktype == 1 then zbx -= 2
   elseif eatktype == 2 then
    if bturn == 2 then zbx -= 2
    elseif bturn == 2.01 then zbx += 4
    else zbx -= (1 + flr(rnd(3)))
    end
   elseif eatktype == 3 then
    zbx -= flr(rnd(5))
   elseif eatktype == 4 then
    if bturn == 2 then zbx -= 2
    elseif bturn == 2.01 then zbx -= 3
    elseif bturn == 2.02 then zbx -= 4
    end
   elseif eatktype == 5 then
    if bturn == 2 then zbx -= 1 + flr(rnd(3))
    else zbx += 2 + flr(rnd(4))
    end
   end
   if eatktype == 1 or (eatktype == 5 and bturn == 2) or (eatktype == 2 and bturn != 2.01) or eatktype == 3 or eatktype == 4 then
   	if zbx + 6 < 18 then zbc = 7
   	elseif zbx < 28 then zbc = 10
    end
   elseif (eatktype == 2 and bturn == 2.01) or eatktype == 5 then
    if zbx > 108 then zbc = 7
   	elseif zbx + 6 > 90 then zbc = 10
    end
   end
   if btnp(Ž) then
    if zbc == 10 then
     -- attack type 1 / 3
     if eatktype == 1 or eatktype == 3 then
      if rnd(1) <= 0.5 then textstr2 = 'you dodged the attack!'
      else textstr2 = 'you blocked the attack!'
      end
      bturn = 2.1
     -- attack type 2
     elseif eatktype == 2 then
      if bturn < 2.02 then
       bturn += 0.01
       if bturn == 2.01 then
        textstr2 = 'press Ž at the red zone!'
        textstr = '<|--------------------^8-----^7--|>'
        zbx = 2
        zbc = 7
       else
        textstr2 = 'press Ž at the red zone!'
        textstr = '<|--^8---^7----------------------|>'
        zbx = 128
        zbc = 7
       end
      else
       if rnd(1) <= 0.5 then textstr2 = 'you dodged the attack!'
       else textstr2 = 'you blocked the attack!'
       end
       bturn = 2.1
      end
     -- attack type 4
     elseif eatktype == 4 then
      if bturn < 2.02 then
       bturn += 0.01
       zbx = 128
       zbc = 7
      else
       if rnd(1) <= 0.5 then textstr2 = 'you dodged the attack!'
       else textstr2 = 'you blocked the attack!'
       end
       bturn = 2.1
      end
     -- attack type 5
     elseif eatktype == 5 then
      if bturn < 2.01 then
       bturn = 2.01
       textstr2 = 'press Ž at the red zone!'
       textstr = '<|--------------------^8-----^7--|>'
       zbx = 2
       zbc = 7
      else
       if rnd(1) <= 0.5 then textstr2 = 'you dodged the attack!'
       else textstr2 = 'you blocked the attack!'
       end
       bturn = 2.1
      end
     end
    else
     -- attack type 1 / 3
     if eatktype == 1 or eatktype == 3 then
      local dmg = eatk - flr(rnd(3))
      dmg -= pdef
      php -= dmg
      textstr2 = 'you took '..dmg..' damage!'
      bturn = 2.1
     -- attack type 2 / 4
     elseif eatktype == 2 or eatktype == 4 then
      local dmg = eatk - flr(rnd(3))
      dmg -= pdef
      if bturn <= 2.01 then
       dmg += eatk - flr(rnd(3))
       dmg -= pdef
      end
      if bturn <= 2 then
       dmg += eatk - flr(rnd(3))
       dmg -= pdef
      end
      php -= dmg
      textstr2 = 'you took '..dmg..' damage!'
      bturn = 2.1
     -- attack type 5
     elseif eatktype == 5 then
      local dmg = eatk - flr(rnd(3))
      dmg -= pdef
      if bturn == 2 then
       dmg += eatk - flr(rnd(3))
       dmg -= pdef
      end
      php -= dmg
      textstr2 = 'you took '..dmg..' damage!'
      bturn = 2.1
     end
    end
   end
  elseif btnp(Ž) and bturn == 2.1 then
   textstr = ''
   if php > 0 then bturn = 1
   else
    mset(114, 58, 98)
    textstr2 = '^8you were defeated...'
    textstr = 'press [enter] to reset.'
    bturn = 3
   end
  elseif btnp(Ž) and bturn == 4 then
   state = 4
   bw = 0
   bturn = 1
   zbx = 2
   zbc = 7
   for i in all(enemies) do
    if i.dead == 1 then del(enemies, i) end
   end
  end
 -- fade to world
 elseif state == 4 then
  if bw > 0 then bw -= 1
  else state = 1
  end
 end
end

// draw

function _draw()
 cls()
 if state == -1 then
  map(mapx * 16, mapy * 16, 0, 0, 16, 16)
  printborder('-- credits --', 38, 16, 7, 0)
  printborder('programmer - justfire45', 16, 32, 7, 0)
  printborder('artist - justfire45', 16, 40, 7, 0)
  printborder('music - justfire45', 16, 48, 7, 0)
  printborder('story - justfire45', 16, 56, 7, 0)
  printborder('-- bug finders --', 30, 72, 7, 0)
 elseif state == -2 then
  local ach1 = 5
  local ach2 = 5
  local ach3 = 5
  if peek(0x5e0c) == 100 then ach1 = 7 end
  if peek(0x5e0d) == 100 then ach2 = 7 end
  if peek(0x5e0e) == 100 then ach3 = 7 end
  map(mapx * 16, mapy * 16, 0, 0, 16, 16)
  printborder('-- achievements --', 28, 16, 7, 0)
  printborder('[home sweet home]', 16, 32, ach1, 0)
  printborder('complete the game.', 16, 40, ach1, 0)
  printborder('[i\'m not a burglar]', 16, 56, ach2, 0)
  printborder('complete the game using', 16, 64, ach2, 0)
  printborder('only the book and clothes.', 16, 72, ach2, 0)
  printborder('[flawless]', 16, 88, ach3, 0)
  printborder('defeat the goblin leader', 16, 96, ach3, 0)
  printborder('without taking damage.', 16, 104, ach3, 0)
 elseif state == 0 then
  map(mapx * 16, mapy * 16, 0, 0, 16, 16)
  printborder('v 1.1.2', 1, 122, 7, 0)
  printborder('a messenger\'s tale', 28, 32, 7, 0)
  printborder('new game', 48, 72, 7, 0)
  if peek(0x5e00) != 1 then printborder('continue', 48, 80, 5, 0)
  else printborder('continue', 48, 80, 7, 0)
  end
  printborder('achievements', 40, 88, 7, 0)
  printborder('credits', 50, 96, 7, 0)
  printborder('>', 24, pointer, 7, 0)
 elseif state != 3 then
  map(mapx * 16, mapy * 16, 0, 0, 16, 16)
  if story >= 6.2 and story < 7 then pf = 111 end
  spr(pf, px * 8, py * 8)
  if #enemies > 0 then
   for i in all(enemies) do
    spr(i.f, i.x * 8, i.y * 8)
   end
  end
  if #csent > 0 then
   for i in all(csent) do
    spr(i.f, i.x * 8, i.y * 8)
   end
  end
  if btnp(—) then
   if toggle == 0 then toggle = 1
   elseif toggle == 1 then toggle = 0
   end
  end
  if toggle == 1 then
   printborder('hp '..php, 2, 2, 8, 0)
   printborder('atk '..patk..' ('..equipname(1)..')', 2, 10, 6, 0)
   printborder('def '..pdef..' ('..equipname(2)..')', 2, 18, 5, 0)
  else
   printborder('— check stats', 2, 2, 7, 0)
  end
  -- the end
  if story == 13 then
   poke(0x5e00, 1)
   poke(0x5e01, patk)
   poke(0x5e02, pdef)
   poke(0x5e03, mapx)
   poke(0x5e04, mapy)
   poke(0x5e05, px)
   poke(0x5e06, py)
   poke(0x5e07, story)
   poke(0x5e08, boatmapx)
   poke(0x5e09, boatmapy)
   poke(0x5e0a, boatx)
   poke(0x5e0b, boaty)
   rectfill(0, 0, 127, 127, 0)
   textstr = '...zzz^lthanks for playing! ~ jfire45'
   textt = 180
  end
  -- display textbox
  if textt > 0 then textt -= 1 end
  if textt > 0 and texty < 15 then texty += 1
  elseif textt == 0 and texty > 0 then texty -= 1
  end
  if py <= 7 then
   rectfill(0, 128 - texty, 127, 128 - texty + 14, 0)
   rect(0, 128 - texty, 127, 128 - texty + 14, 7)
   printc(textstr, 2, 128 - texty + 2)
  else
   rectfill(0, -15 + texty, 127, -15 + texty + 14, 0)
   rect(0, -15 + texty, 127, -15 + texty + 14, 7)
   printc(textstr, 2, -15 + texty + 2)
  end
 end
 if state >= 2 then
  if state != 3 then music(-1) end
  rectfill(0, 0, bw, 127, 0)
  rectfill(-bw + 127, 0, 127, 127, 0)
  if state == 3 then
   map(112, 48, 0, 0, 16, 16)
   rect(0, 119, 127, 127, 7)
   printc(textstr, 2, 121, 7)
   rect(0, 111, 127, 119, 7)
   printc(textstr2, 2, 113, 7)
   rect(2, 2, 56, 12, 7)
   rect(71, 2, 125, 12, 7)
   if php > 0 then rectfill(4, 4, ((php / 100) * 50) + 4, 10, 8) end
   if ehp > 0 then rectfill(-((ehp / emaxhp) * 50) + 123, 4, 123, 10, 8) end
   if bturn == 1.1 or bturn == 1.2 or bturn == 2 or bturn == 2.01 or bturn == 2.02 or bturn == 2.1 then
    printborder('Ž', zbx, 121, zbc, 0)
   end
  end
 end
 if debug == 1 then
  spr(127, stat(32), stat(33))
  printborder(stat(32)..'/'..stat(33), 1, 100, 7, 0)
 end
end
__gfx__
00000000bb4444bbbb4444bb3b3333b33b3333b33b1556b33b1556b3000000000000000000000000000000000000000000000000000000000000000000000000
00000000b444444bb444444b33333333333333333155556331555563000000000000000000000000000000000000000000000000000000000000000000000000
00700700bf0f40fbbf0f40fbb313313bb313313bb313313bb313313b000000000000000000000000000000000000000000000000000000000000000000000000
00077000bf0ff0fbbf0ff0fbb313313bb313313bb313313bb313313b000000000000000000000000000000000000000000000000000000000000000000000000
00077000bb9ff4bbbb9ff4bbbb4333bbbb4333bbbb6333bbbb6333bb000000000000000000000000000000000000000000000000000000000000000000000000
00700700b449444bb449444bb344433bb344433bb346633bb346633b000000000000000000000000000000000000000000000000000000000000000000000000
00000000bf4499bbbb4499fbb34444bbbb44443bb34446bbbb44463b000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbb5bbbb5bbbbbbbbbb3bbbb3bbbbbbbbbb3bbbb3bbbbb000000000000000000000000000000000000000000000000000000000000000000000000
001556000015560030333303303333030015560000003909a0a30000303333030000000000000000000000000000000000000000000000000000000055555555
01555560015555603333333333333333015555600000399999a30000333333330000000000000000000000000000000000000000000000000000000055555555
01555560015555600313313003133130015555600000031331300000031331300000000000000000000000000000000000000000000000000000000055555555
0f0ff0f00f0ff0f003133130031331300f0ff0f00000031331300000031331300000000000000000000000000000000000000000000000000000000055555555
00ffff0000ffff00004333000043330000ffff000000003333000000004333000000000000000000000000000000000000000000000000000000000005050505
11555566115555660344433003444330115555660000066556600000034443300000000000000000000000000000000000000000000000000000000050505050
0f555500005555f003444400004444300f5555f00000035555300000034444300000000000000000000000000000000000000000000000000000000005050505
00000500005000000000030000300000005005000000005005000000003003000000000000000000000000000000000000000000000000000000000050505050
0505505005d55d500115656004155640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555550d555555d1500005641555564000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
0d0dd0d0de0ee0ed1500005541555564000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0ee0e0de0ee0ed015005504f0ff0f4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050505050
00eeee00ddeeeedd0015550040ffff04000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02d11d20d2d11d2d0048940011555566000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ed11de00ed11de0004884004f5555f4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d11d0000d11d000004400004544540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb4444bb3b3333b3b5b55b5b3b1556b339b9aba300000000a000000a000000000000000000000000000000000000000000000000000000000000000000000000
b444444b33333333b555555b31555563399999a3000000000a0a0aa0000000000000000000000000000000000000000000000000000000000000000000000000
bff04f0bb133133bb0dd0ddbb133133bb133133b0000000000aa0aa0000000000000000000000000000000000000000000000000000000000000000000000000
bff0ff0bb133133bb0ee0eebb133133bb133133b000000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000
bb9fffbbbb3334bbbbeeeebbbb3336bbbb3333bb000000000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000
b44944bbbb34443bbbd11d2bbb36643bbb55566b000000000aa0aa00000000000000000000000000000000000000000000000000000000000000000000000000
bf4499fbb344443bbed11debb364443bb355553b000000000a00a0a0000000000000000000000000000000000000000000000000000000000000000000000000
bb4bb4bbbb3bb3bbbbd11dbbbb3bb3bbbb5bb5bb00000000a000000a000000000000000000000000000000000000000000000000000000000000000000000000
03333330c001c0010000000000000000005555000000000000000044000055555550000044444444000000000000598998500000000000000000000000000000
33000033001c001c0000505005050000050055500050000000004044000050000050000040000004000000000000508890500000000000000000000000000000
3033330301c001c00000555555550000500055550000000000404044000505555050000040000444000000000005055890500000000000000000000000000000
303333031c001c000000500000050000500555550000005040404044000505555505000040040444000000000005055895050000000000000000000000000000
33000033c001c0015050505555050505555005550000000040404044000505555505000044040444000000000005055985050000000000000000000000000000
04333340001c001c5550505555050555044444400005000040404000000505555550500044040444000000000005058955505000000000000000000000000000
0044440001c001c05050500550050505040404400000000040400444005050555555050044040444000000000050509855550500000000000000000000000000
040440401c001c005550505005050555044404400000000040044444005050005555050044444444000000000050508985550500000000000000000000000000
50000005555555555555555555555555004444000055000000000000050505550555050000000000000000000505059998550500000000000000000000000000
55555555050005005550000000000555040044400500500000000000505550005055505000000000000000005055508858855050000000000000000000500000
50000005050005005050555005550505400044440500550000000000505555505055550500000000000000005055589959855505000000000000000000000000
50000005050005005550550550550555400444440500505000000005055555550505550500000000000000050555898509855505000000000000000000000050
50000005050005005550505005050555444004445000505000000050555555550505505050000000000000505555955505855050500000000000000000000000
55555555050005005050505005050505088888805000050500000050555555555050050050000000000000505558955550980500500000000000000000050000
50000005050005005050005005000505080808805000050500000050555555555050050505000000000000505558555550980505050000000000000000000000
50000005555555550555555555555550088808805000050500000050555555555050505505000000000000505589555550985055050000000000000000000000
44444444044444400555555001555670055555500505050500000505005555555505055505000000000005050089555555098555050000000000000000000000
44444444400000045000000510000007500000055555555500000500550555555005055505000000000005005589555550089855050000000000000000000000
04000000404444045005500510056006505505050505050500005055005005500550555550500000000050550089055005509855505000000000000000000000
44444444404444045055550510155607505555055555555500005055550550055005555555050000000050555989500550058955550500000000000000000000
44444444404444045055550510155606500000050505050500050555555005500555555555050000000505555990055005558955550500000000000000000000
00000400404444045005500510015006505555050505050500050555555550500555555555505000000505558955505005555955555050000000000000000000
44444444400000045005500510015006505555050505050500050555555550055005555555505000000505559555500550055855555050000000000000000000
44444444044444405005500510015006500550050505050500505555555505500550555555550500005055559555055005505885555505000000000000000000
44044404555555559aa89aa84404440400000000000000000505555555505000000505555555505005055555955050000005058955555050000000004444444b
4404440055555555aa89aa894404440000000000000000000505555555050000000050555555505005055559850500000000508955555050000000004888884b
0440004404400044a89aa89a044000440000000000000000050555555505000000005055555550500505555955050000000050995555505000000000488444bb
004000440040004489aa89aa00400044000000000000000005055555505000000000050555555050050555895050000000000509555550500000000048484bbb
44044044440440449aa89aa8550550550000000000000000050555555050000000000505555550500505559850500000000005089555505000000000484484bb
4404040444040404aa89aa89550505050000000000000000050555555050000000000505555550500505559850500000000005059855505000000000484b484b
0044040000440400a89aa89a88888888000000000000000005000000005000000000050000000050050000980050000000000500898000500000000044bbb484
404044044040440489aa89aa999999990000000000000000005555555555555555555555555555000055559955555555555555555885550000000000bbbbbb44
14141455141414141414141414141404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404000505000414141414555555555555555555551414141414141407070707070707070707070707070707
14145514141414141414141414140404040404040400000000000004040404040404040404040404040404040404040404040404040404040404040404040404
040404040404040404040404040404040404040404040054540004141414551414141414000426440055141414141414070707070707f55454f5070707070707
55551414141414141414141414140404040404000000002434000000000404040404040404040404040404040404040404040404040404040404040404040404
040404040404040404040404040404040404040404040054540004041414141414141406545454540055141414141414070707075454f55464f5545407070707
55141414141414141414141414140404040400000000002535000000000004040404040404040404040404040404040404040404040404040404040404040404
040404040404040404040404040404040404040404000054540000040404141414141414000000000055141414141414070707545454f55454f5545454070707
14141414141414141414141414141404040400000000005454000000000004040404040400000000040404040000000000000000000404040404040404040404
040404040404040404040404040404040404040000000054540000000004040404040404040404040404040404040404070707545454f55454f5545454070707
14141414141414141414141414141404040000000000000054000000000000040404000000004400000000000000000000000000000000000000040404040404
040404040404040404040404040400000000000000440054540000440000004100000000000000000000000000000000070754545454f55454f5545454540707
14141414141414141414141414141414041414000000450054000000000000040400000000005400005454545454545454545454545400000000000000000000
000000000004040404040400000000000000000000540054545454545400000000000000000000000000000000000000070754545454f55454f5545454540707
14141414141414141414141414141414141414140000540054004400000000000000000054545454545400000000000000000000005454545454540000000000
000000000000000000000000005454545454545454545454540000005454545454545454545454545454545454545454070754545454f55454f5545454540707
14141414141414141414141414141414141414141400545454545454545454545454545454000014141400000000000000000000000000000000545454545454
545454545454000000005454545400000000000000000054540045000000000000000000000000000000000000000000070754545454f55454f5545454540707
14141414141414141414141414141404041414140600000054005400440000040400000014141414141414000000040404040404040000000000000000000000
000000000054545454545400000000000000000044000054545454000000004100000000000000000000000000000000070754545454f55454f5545454540707
14141414141414141414141414141404040014141414000054005454540000040404141414141414141414140404040404040404040404040404000000000000
000000000000000000000000000004040404000054545454540000000000040404040404040404040404040404040404070754545454f55454f5545454540707
14141414141414141414141414140404040414141414004454000000000004040404040414141414140404040404040404040404040404040404040404040404
040404040400000000000004040404040404040400000054540000000404040404040404040404040404040404040404070707545454f55454f5545454070707
14141414141414141414141414140404040400141400005454440000000004040404040404040404040404040404040404040404040404040404040404040404
040404040404040404040404040404040404040404000054540000040404040404040404040404040404040404040404070707545454f55454f5545454070707
14141414141414141414141414140404040404000000000054540000000404040404040404040404040404040404040404040404040404040404040404040404
040404040404040404040404040404040404040404000054540000040404040404040404040404040404040404040404070707075454f55454f5545407070707
14141414141414141414141414040404040404040400000000000004040404040404040404040404040404040404040404040404040404040404040404040404
040404040404040404040404040404040404040404045654545604040404040404040404040404040404040404040404070707070707f55454f5070707070707
14141414141414141414140404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404005454000404040404040404040404040404040404040404040407070707070707000007070707070707
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070707070707070707070707070707040404040404005454000404040404040000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070707075454545454540707070707040404042600265454260026040404040000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070754545454221254545454070707040404005454545454545454000404040000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07075454545454545454545454540707040400000000005454000000000004040000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07075454545454025454545454540707040426002600265454260026002604040000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07075454545454545454545454540707040454545454545454545454545404040000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07075454545454545454545454540707040400000000005454000000000004040000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07075454545454545454545454540707040426002600265454260036002604040000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07075454545454545454545454540707040454545454545454545454545404040000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07075454545454545454545454540707040400000000005454000000000004040000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07075454545454545454545454540707040400002600265454260026000004040000000000000000000000000000000000000300000000000000000000130000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
070707545454545454545454540707070404040054545454545454540004040400000000000000000000000000000000f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
070707545454545454545454540707070404040000005404045400000004040400000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070707545454171754545407070707040404040000544646540000040404040000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070707070754000054070707070707040404040404545454540404040404040000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070707070707070707070707070707040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000001010101010101010000000000000000010101010000000000000000000000000000000000000000000000000000000001010101010000010100000101000000000001010101010101010101010100030000010101010101010101010101000301010101000001010101010101010000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041414141414141414141414141414141414141414141414141414141414141414155555555414141554141414141414170707070707070707070707070707070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041414140404040404141414155414141414140404040404040414141414141415555554545555541414141414141414170707070707373737373737070707070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041414040404040404041414155415541414500404040404040454545454141415555455560414155415541414141414170707073737272727272727373707070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041414040404040000045554141554155554500444040400000000000004545415545414141414155414141414141414170707372727272727272727272737070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041404040004748000045415555414141414500000000000000000000000045415541414141414155414141414141414170707272727272727272727272727070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041404040565758590045414141414141414500000000000000000000000045554141414141414141554141414141414170707272727272727272727272727070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041404040666768690000454141414141414500000045454500000000004541414141414141415555414141414141414170707272727272727272727272727070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041404000767778790000454141414141414145454541414155000000454541415555554141554141414141414141414170707272727272727272727272727070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041450000000000000000454141414141414141414141414155454545604141414155415555414141414141414141414170707272727255555555727272727070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041450044000000005400454141414141414141414141415541554141414141415541554141414141414141414141414170707072725500000000557272707070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055450000000044000045414141414141414141414141415555414141414141414141554141414141414141414141414170707000000000151600550000707070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041554545000000004541414141414141414141414141416541554141414141414155414141414141414141414141414170707045554500004545005545707070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055414160454545454141414141414141414141414141415541414141414141414155414141414141414141414141414170707070455555454555455570707070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055414141414141414141414141414141414141414141554141414141414141415541554141414141414141414141414170707070455545454545554570707070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055414141414141414155414141414141414141414141554141414141414141554141554141414141414141414141414170707070704545454545007070707070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041554141415541415541555541414141414155414155415541414141414141414141554141414141414141414141414170707070707045454545707070707070
4141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141554141415555414141415541555541555541414155554141415541555541415541414141414141414155414141414141414141414141414170707070707045454545707070707070
4141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141554141414155414141554155414155414155554155554155414141415555415541414141554141604141414141415555414141414141414141414141414170707070704545454545457070707070
4141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414155415555414155415555415541555541555541414141554141414141414141554141414141404040004141414141414155414141414141414141414141414170707070454545454545454570707070
4141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141415555414141555541554141414141414141414141414141414141414141414155414141414040404040004400414141554155414141414141414141414141414170707070454545454545454570707070
4141414141414141414141414141414141414141414141414141414141414141414141414141414155554141554141554141554141414141414141414141414141414141414141414141414141415541414141404040404000000000004141415541554141414141414141414141414170707045455545454545454545707070
4141414141414141414141414141414141414141414141414141414141414141414155415541415541415555415555554141414141414141414141414141414141414141414141414141414141415541414141404040404065656565654141414155415541414141414141414141414170707045455545454545454545707070
4141414141414141414141414141414141415541414141414141414141414141554141555555554141554141414141414141414141414141414141414141414141414141414141414141414141554141414140404040000000000000000041414155414141414141414141414141414170704545554545454545454545457070
4141414141414141414141414141414141554141414141554141555541554155415555415541554141414141414141414141414141414141414141414141414141414141414141414141414141415555414140404000004243000000000041415541414141414141414141414141414170704545454545454555455545457070
4141414141414141415541414141414141554155554155415541554155414155414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414155414140400000005253000000000041415541414141414141414141414141414170704545454545454555454545457070
4141414141414141554155555541414155555541415541415555414141555541414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141415541414140400000404545400000000041414155414141414141414141414141414170704545454545454545554545457070
4141414141414141415541414155555541414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414155414141400000004545000000004141415541415541414141414141414141414170707045454545454545454545707070
4141414141554141555555414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141554155416055000000404545400000004141415555414141414141414141414141414170707045454545454545454545707070
4141414155414155414155414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141415562004555410000004545000000414141415541414141414141414141414141414170707070454545454945454570707070
4141415541555541414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141555541414141415541554400004544554141005050004141414141554141414141414141414141414141414170707070707045454545707070707070
4141554141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414155414141414155414155554141554545454545005541415050414141414141554141414141414141414141414141414170707070707070707070707070707070
4141555541414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414155554155414141554141554141415500000000554141415050415541414155414141414141414141414141414141414170707070707070707070707070707070
__sfx__
010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0120000018150000001c150000001c15000000181500000018150181511c1501c1511c1501c151181501815117150000001a150000001a15000000171500000017150171511a1501a1511a1501a1511715017151
0120000018635006001c6360060018635006001c6350000018635006001c6360060018635006001c6350000018635006001c6360060018635006001c6350000018635006001c6360060018635006001c63500000
011000001c7701c7701c7601c7601c7501c7501c7401c7401c7701c7701c7601c7601c7501c7501c7401c7401a7701a7701a7601a7601a7501a7501a7401a7401a7701a7701a7601a7601a7501a7501a7401a740
011000001855218551005001a5521a551005001d5521c5521a552185521d5521c5521a5521855200500005001855218551005001a5521a551005001d5521c5521a552185521f5521f5521e5521e5521e55200500
0110000018032000000000018032000001803218031000001a03200000000001a032000001a0321a0310000018032000000000018032000001803218031000001b03200000000001b032000001b0321b03100002
0110000018052000001a052000001d5521c5521a55218552005020050218052005021a052005021d5521c5521d5521f5520050200502005000050000500005000050000500005000000000000000000000000000
011000001d0521d051000021f0521f0511f0511f051000021c0521c051000021d0521d0511d0511d051000021d0521d0510000221052210512105121051000021c0521c051000021f0521f0511f0511f05100000
011000001d0521d051000021f0521f0511f0511f051000021c0521c051000021d0521d0511d0511d051000021d0521d05100002210522105121051210510000221052000021f052000021d052000021c05200000
01200000182521825100000000001d2521d25100000000001c2521c251000020000218252182510000200002182521825100000000001d2521d25100000000001c2521c251000020000218252182510000200002
01200000180501865500000000001d0501d65500000000001d0501d65500000000001a0501a65500000000001d0501d65500000000001d0501d65500000000001a0501a65500000000001a0501a6550000000000
011000002875028751287412874128731287312872128721287502875128741287412873128731287212872126750267512674126741267312673126721267212675026751267412674126731267312672126721
011800001777200700007001777217772177720070000700177720070000700177721777217772007000070018772007000070018772187721877200700007001577200700007001577215772157720070000700
011800002701200000000002701227011270122400024100270122400024000270122701127012240002410024022240002400024022240212402224000241002402224000240002402224021240221810000000
011800001e65500600006001a655186510060018655006001265500600006000e6550c6510c0000c6550c0002a635000002460026635246312460024635300003662530600306003262530621306003062500000
01100000180701c0701d0701a070180701c0701d0701a070180701c0701d0701a070180701c0701d070000001d772007021d772007021d772007021d772007021d772007021d772007021d772007021d77200602
01100000186551d6510060000000186551d6510060000000186551d6510000000000186551d6551d65500600186551d6510060000000186551d6510060000000186551d6510000000000186551d6551d65500600
011000001a772007001a772007001a772007001a7720070018772007001877200700187720070018772007001a772007001a772007001a772007001a772007001c7421c7411c7511c7511c7611c7611c7711c771
011000001a7721a7711a771007001a772007001a772007001c7721c7711c771007001c772007001c772007001a7721a7711a771007001a772007001a772007001d7721d7711d7611d7611d7511d7511d7411d741
011000001d5521a552185521d5521a552185521d5521b5521e5521b552195521e5521b552195521e5521c5521d5521a552185521d5521a552185521d5521b5521c55219552175521c55219552175521c5521a552
011000001864518645186451864518645186451864518645186451864518645186451864518645186451864518645186451864518645186451864518645186451864518645186451864518645186451864518645
011000001c550205501d5501a550215501d5501a5501c5501c551205501d5501a550215501d5501a5501c5501c551205501d5501a550215501d5501a5501c5501c551205501d5501a550215501d5501a5501c550
011000001d550225501f5501c550235501f5501c5501d5501d551225501f5501c550235501f5501c5501d5501d551225501f5501c550235501f5501c5501d5501d551225501f5501c550235501f5501c5501d550
011000000c1400c1420c1440c1460d1410d1430d1450d1470e1400e1410e1430e1450f1420f1440f1460f1470c1400c1470c1450c1430d1410d1460d1440d1420f1400f1470f1460f14410142101451014310141
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
00 01 42 43 44
00 01 02 43 44
03 01 02 03 44
01 04 05 43 44
00 04 05 43 44
00 06 05 43 44
00 06 05 43 44
00 07 05 43 44
02 08 05 43 44
00 09 42 43 44
00 09 0a 43 44
03 09 0a 0b 44
00 0c 42 43 44
00 0c 0d 43 44
03 0c 0d 0e 44
01 0f 42 43 44
00 0f 10 43 44
00 11 10 43 44
02 12 10 43 44
03 13 14 43 44
01 15 17 43 44
02 16 17 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
