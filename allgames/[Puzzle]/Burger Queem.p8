pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- general display functions

-- colours
colours = {
 black      = 0,
 darkblue   = 1,
 maroon     = 2,
 darkgreen  = 3,
 brown      = 4,
 darkgrey   = 5,
 lightgrey  = 6,
 white      = 7,
 red        = 8,
 orange     = 9,
 yellow     = 10,
 lightgreen = 11,
 lightblue  = 12,
 mauve      = 13,
 pink       = 14,
 beige      = 15
}

-- sounds and music
sounds = {
 collect = 0,
 yes     = 1,
 no      = 2,
 expired = 3,
 bin     = 4
}

function playsound(sound)
 sfx(sounds[sound])
end

-- print horizontally centred
-- using y position and
-- (optionally) colour
function cprint(text,y,c)
 centrepos = 128/2 - #text*2
 if c ~= nil then
  print(text,centrepos,y,c)
 else
  print(text,centrepos,y,c)
 end
end

-- draw standard dialogue box
function drawalertrect()
 rect(16,16,112,112,colours['lightblue'])
 rectfill(17,17,111,111,colours['lightgrey'])
end

-- deep copy a table
-- returns the copied list
function cpy(l1)
 local cp = {}
 for i in all(l1) do
  add(cp,i)
 end
 return cp
end

-- checks whether 2 lists
-- have the same items
-- in the same order
function identical(l1,l2)
 for num=1,#l1+1 do
  if l1[num] ~= l2[num] then
   return false
  end
 end
 return true
end

-->8
-- state and statemanager

-- stores game state
state = {}
state.__index = state

function state:create(props)
 local this = {}
 local props = props or {}
 this.next = props.next or nil
 this.time = props.time or 0
 this.timeremaining = this.time
 setmetatable(this, state)
 return this
end

-- keeps track and updates
-- a list of states
statemanager = {}
statemanager.__index = statemanager

function statemanager:create(props)
 local this = {}
 local props = props or {}
 this.current = nil
 this.next = props.next or {}
 this.previous = nil
 this.frame = 0
 setmetatable(this, statemanager)
 return this
end

function statemanager:update()
 self.previous = self.current
 self.current = self.current:update()
 -- reset frame for new state
 if self.current ~= self.previous then
  self.frame = 0
 end
 -- stop integer overflow
 if self.frame > 32000 then
  self.frame = 0
 end
 self.frame += 1
end

function statemanager:draw()
 self.current:draw()
end
-->8
-- player

player = {}
player.__index = player

function player:create(props)
 local this = {}
 this.score = 0
 this.x = 60
 this.holding = {}
 this.height = 0
 this.busy = false
 setmetatable(this, player)
 return this
end

function player:update()
 -- update position, but don't
 -- move beyond screen
 if btn(0,0) then
  self.x = max(0, self.x - 2)
 end
 if btn(1,0) then
  self.x = min(self.x + 2, 128 - bottombread.spr_stacked.width)
 end

 -- update burger height
 self:updateheight()

 -- collect any falling items
 -- touching the player
 for f in all(falling.itemlist) do
  if self:hit(f) then
   add(self.holding,f.item)
   del(falling.itemlist,f)
   f = nil
   playsound('collect')
  end
 end

 -- reset burger if at bin,
 -- not busy and
 -- holding additional items
 if p.x < bin.width + 1 and
    not self.busy and
    not identical(p.holding,{bottombread}) then
  p.holding = {bottombread}
  self.height = 2
  playsound('bin')
  self.busy = true
 else
  -- player no longer busy if
  -- moved away from bin
  if p.x > bin.width + 4 then
   self.busy = false
  end
 end

 -- serve food if at hatch,
 -- there are orders waiting,
 -- no orders are processing
 -- and holding additional items
 if self.x > (110 - hatch.width - 1) and
    not os.processing and
    not identical(p.holding,{bottombread}) and
    #os.items > 0 then
  os.processing = true
  result = self:serve()
  if result then
   os.status = 'yes'
   playsound('yes')
  else
   os.status = 'no'
   playsound('no')
  end
 -- no longer processing orders
 -- if moved away from hatch
 else
  if self.x < (110 - hatch.width - 1) then
   os.processing = false
  end
 end
end

-- player vs fallingn item
-- hittest

function player:hit(fallingitem)
 return fallingitem.x + 16 > self.x and
        fallingitem.x < self.x+16 and
        fallingitem.y+8 > 120-self.height and
        fallingitem.y < 120
end

-- draw the burger the player
-- is holding
function player:draw()
 local y = 128
 for i in all(self.holding) do
  -- update y position to draw
  -- next item above the current
  y -= i.spr_stacked.height
  i.spr_stacked:draw(self.x,y)
 end
end

function player:reset()
 self.holding = {bottombread}
 self.height = 4
 self.x = 60
end

-- returns true if there is an
-- order matching the burger
-- the player is holding
function player:serve()
 -- iterate over all orders
 for o in all(os.items) do

  -- create copies of the lists
  -- to compare, as the compare
  -- function is destructive
  local olist = cpy(o.recipe.ingredients)
  local plist = cpy(self.holding)

  -- if order matches burger
  -- update score, delete order
  -- and reset player burger
  if identical(plist, olist) then
   self.score += o.recipe.points
   del(os.items,o)
   self.holding = {bottombread}
   return true
  end
 end

 -- no matching order found
 return false
end

-- updates the player height
-- based on the height of
-- burger items being held
function player:updateheight()
 local h = 0
 for i in all(self.holding) do
  h += i.spr_stacked.height
 end
 self.height = h
end

-->8
-- items and sprites

sprite = {}
sprite.__index = sprite
function sprite:create(props)
 local this = {}
 local props = props or {}
 this.spritex = props.spritex
 this.spritey = props.spritey
 this.width = props.width or 16
 this.height = props.height or 16
 setmetatable(this, sprite)
 return this
end

function sprite:draw(x,y)
 sspr(self.spritex, self.spritey, self.width, self.height, x, y)
end

-- a food item
item = {}
item.__index = item

function item:create(props)
    local this = {}
    local props = props or {}
    this.name = props.name or "unnamed"
    -- a food item has 3 sprites
    -- for the falling item, the
    -- stacked burger item and
    -- the item in the order
    -- this.fallingsprite = props.fallingsprite
    this.spr_falling = props.spr_falling
    this.spr_stacked = props.spr_stacked
    this.spr_icon = props.spr_icon
    -- the level for which the
    -- item first appears
    this.level = props.level or 1
    setmetatable(this, item)
    return this
end

function item:drawfalling(x,y)
 sspr(self.spritex, self.spritey, 16, 16, x, y)
end

function item:drawstacked(x,y)
 sspr(self.stackedspritex, self.stackedspritey, 16, self.h, x, y)
end

function item:drawicon(x,y)
 sspr(self.iconx, self.icony, 8, self.h/2, x, y)
end

-- a list of food items
items = {}
items.__index = items

function items:create(props)
    local this = {}
    local props = props or {}
    this.itemlist = {}
    this.randomitems = {}
    setmetatable(this, items)
    return this
end

-- returns all item for the
-- level required
function items:getitemsforlevel(l)
 local items = {}
 for i in all(self.itemlist) do
  if i.level <= l and i ~= bottombread then
   add(items, i)
  end
 end
 return items
end

-- getting items randomly means
-- sometimes items don't appear
-- often enough. this function
-- doesn't return an item a
-- second time until all items
-- have been returned once
function items:getnextrandom()
 -- populate random item list
 -- if list is empty
 if #self.randomitems == 0 then
  self.randomitems = self:getitemsforlevel(level)
  -- add an extra meat or it's too hard
  if level > 2 then
   add(self.randomitems,meat)
  end
 end

 -- get a random item from the
 -- random items list
 local randno = flr(rnd(#self.randomitems)) + 1
 local nextitem = self.randomitems[randno]
 -- remove item from list once
 -- it has been chosen
 del(self.randomitems, nextitem)
 return nextitem
end

function items:reset()
 self.randomitems = {}
end
-->8
-- orders and recipes

-- a burger order
order = {}
order.__index = order

function order:create(props)
 local this = {}
 local props = props or {}
 this.recipe = props.recipe
 -- time to fulfil order
 this.maxtime = props.maxtime
 -- order time remaining
 this.timeremaining = this.maxtime
 setmetatable(this, order)
 return this
end

function order:draw(x,y)
 -- location of order on screen
 local x = x
 local y = y

 -- percentage time left
 -- determines timer bar colour
 local percentage = flr(self.timeremaining / self.maxtime * 100)
 local colour
 if percentage > 60 then
  col = colours['darkgreen']
 elseif percentage > 20 then
  col = colours['orange']
 else
  col = colours['red']
 end

 -- shake order if not long left
 if percentage < 20 then
  x += rnd(2) - 1
  y += rnd(2) - 1
 end

 -- draw box for order
 rect(x,y,x+15,y+20,colours['darkblue'])
 rectfill(x+1,y+1,x+14,y+19,colours['darkgrey'])

 -- draw the burger ordered
 local burgery = 18
 for i in all(self.recipe.ingredients) do
  burgery -= i.spr_icon.height
  i.spr_icon:draw(x+3,y+burgery)
 end

 -- calculate the top position
 -- of the timer bar
 local top = 18 - flr(18 / 100 * percentage)

 -- draw timer bar
 rectfill(x+13,y+top,x+14,y+19,col)
end

-- a list of orders
orders = {}
orders.__index = orders

function orders:create(props)
 local this = {}
 local props = props or {}
 this.items = {}
 this.timeuntilnext = 0
 this.processing = false
 -- status is for drawing
 -- yes/no status image
 -- above the order hatch
 this.status = 'nothing'
 -- time to show the image
 this.statustime = 20
 setmetatable(this, orders)
 return this
end

function orders:reset()
 self.items = {}
 self.timeuntilnext = 0
 self.processing = false
 self.status = 'nothing'
 self.statustime = 20
end

function orders:update()
 -- show yes/no image above
 -- serving hatch for 20 frames
 -- if an order is attempted
 if self.status == 'nothing' then
  self.statustime = 20
 else
  self.statustime -= 1
  if self.statustime < 1 then
    self.statustime = 20
    self.status = 'nothing'
  end
 end

 -- add first order if there are none
 if #self.items >= 0 and #self.items < 5 and self.timeuntilnext <= 0 then
  -- get a random recipe
  rec = rs:getrandom()
  -- order wait time
  ordertime = flr(rec.waittime + (rnd(tolerance*2) - tolerance))
  neworder = order:create({ recipe=rec, maxtime=ordertime })
  add(self.items,neworder)
  -- reset timer for next order
  self.timeuntilnext = rnd(timebetweenorders) + timebetweenorders
 end

 -- maximum if 5 orders at once
 if #self.items < 5 then
  self.timeuntilnext -= 1
 end

 -- process orders
 for o in all(self.items) do
  -- update time for each order
  o.timeremaining -= 1
  -- remove any orders that have expired
  if o.timeremaining < 1 then
   p.score = max(0, p.score - o.recipe.points/2)
   del(self.items,o)
   o = nil
   playsound('expired')
  end
 end
end

function orders:draw()

 -- starting point for orders
 -- on screen
 local x = 3
 local y = 3
 -- draw each order in a row
 for o in all(self.items) do
  o:draw(x,y)
  x+=17
 end
 
 -- serving hatch status
 if self.status == 'yes' then
  tick:draw(120,120)
 end
 if self.status == 'no' then
  cross:draw(120, 120)
 end
end

-- a recipe
recipe = {}
recipe.__index = recipe

function recipe:create(props)
 local this = {}
 local props = props or {}
 this.ingredients = props.ingredients
 this.points = props.points or 10
 this.level = 1

 -- calculate level of recipe
 -- using the level of the
 -- items in the recipe
 if this.ingredients ~= nil then
  for i in all(this.ingredients) do
   if i.level > this.level then
    this.level = i.level
   end
  end
 end

 -- wait time for recipe, used
 -- for order wait time
 -- currently based on game level
 this.waittime = leveldata[level].waittime
 setmetatable(this, recipe)
 return this
end

-- a list of recipes
recipes = {}
recipes.__index = recipes

function recipes:create()
 local this = {}
 local props = props or {}
 this.recipelist = {}
 setmetatable(this, recipes)
 return this
end

-- get a random recipe
-- from the recipe list
function recipes:getrandom()
 local listforthislevel = {}
 for r in all(self.recipelist) do
  if r.level <= level then
   add(listforthislevel,r)
  end
 end
 rno = flr(rnd(#listforthislevel)) + 1
 return self.recipelist[rno]
end

-->8
-- falling items

-- a falling item is an item
-- with an x & y coordinate
fallingitem = {}
fallingitem.__index = fallingitem

function fallingitem:create(props)
 local this = {}
 local props = props or {}
 this.item = props.item
 -- random x position
 this.x = flr(rnd(80)) + 20
 -- start at top of screen
 this.y = 0
 -- random speed
 this.speed = flr(rnd(3)) + 1
 setmetatable(this, fallingitem)
 return this
end

function fallingitem:draw()
 self.item.spr_falling:draw(self.x, self.y) --item:drawfalling(self.x, self.y)
end

-- a list of falling items
fallingitems = {}
fallingitems.__index = fallingitems

function fallingitems:create()
 local this = {}
 local props = props or {}
 this.itemlist = {}
 -- time is set depending on
 -- the current level (1 to start)
 this.timeuntilnext = leveldata[level].timebetweenitems
 setmetatable(this, fallingitems)
 return this
end

function fallingitems:update()
 -- add more items if there aren't enough
 if #self.itemlist < leveldata[level].numberofitems and self.timeuntilnext < 1 then
  self.timeuntilnext = leveldata[level].timebetweenitems
  local newfallingitem = fallingitem:create({ item=is:getnextrandom() })
  add(self.itemlist, newfallingitem)
 else
  self.timeuntilnext -= 1
 end

 -- move/delete any at bottom of screen
 for f in all(self.itemlist) do
  f.y += f.speed
  if f.y > 130 then
   del(self.itemlist,f)
   f=nil
  end
 end
end

function fallingitems:reset()
 self.itemlist = {}
end

function fallingitems:draw()
 for f in all(self.itemlist) do
  f:draw()
 end
end
-->8
-- game initialisation

function _init()

 leveldata = {
  {time=45*60, scoretarget=40, numberofitems=6, timebetweenitems=40, waittime=1500},
  {time=60*60, scoretarget=60, numberofitems=12, timebetweenitems=30, waittime=1500},
  {time=75*60, scoretarget=80, numberofitems=18, timebetweenitems=30, waittime=1500},
  {time=90*60, scoretarget=100, numberofitems=24, timebetweenitems=25, waittime=1500},
  {time=105*60, scoretarget=120, numberofitems=30, timebetweenitems=25, waittime=1500}
 }

 -- magic numbers
 timebetweenorders = 150
 tolerance = 300

 -- setup score and timer
 level = 1
 timer = leveldata[level].time

 stateman = statemanager:create()

 -- create game states

 gamescreen  = state:create({ })
 function gamescreen:draw()
  cls(6)
  map(0,0)
  bin:draw(0,128 - bin.height)
  hatch:draw(128 - hatch.width, 128 - hatch.height)
  falling:draw()
  p:draw()
  os:draw()
  -- score/level display
  print('l' .. level .. ' - ' .. ceil(timer/60),90,3,colours['darkgrey'])
  rect(89,10,121,13,colours['darkgrey'])
  -- don't display score if 0
  if p.score > 0 then
   rectfill(90,11,90+min(flr( p.score / leveldata[level].scoretarget * 30) , leveldata[level].scoretarget / leveldata[level].scoretarget * 30),12,colours['darkgreen'])
  end
  print(p.score .. '/' .. leveldata[level].scoretarget, 90,16,colours['darkgrey'])
 end

 startscreen = state:create({ })
 function startscreen:draw()
  cls(2)
  cprint('burger queem',25,colours['lightgrey'])
  -- burger animation
  local y=80
  local n = 6
  for i in all({bottombread, meat, meat, cheese, meat, pickle, topbread}) do
   y-= i.spr_stacked.height
   n -= 1
   i.spr_stacked:draw(55,min(y,(stateman.frame*4)+(y*3)-(900-(n*n*n*n))))
  end

  c_button:draw(30,110)
  x_button:draw(90,110)
  print('start',24,120,colours['lightgrey'])
  print('instructions',70,120,colours['lightgrey'])
 end

 instructionsscreen = state:create({ time=50 })
 function instructionsscreen:draw()
  cls(2)
  cprint('instructions', 10, colours['lightgrey'])
  cprint('use the arrow keys to',30,colours['white'])
  cprint('build burgers to order',40,colours['white'])
  cprint('move to the far right to',55,colours['white'])
  cprint('serve burgers and the far',65,colours['white'])
  cprint('left to throw a burger away',75,colours['white'])
  cprint('good luck!',90,colours['white'])

  c_button:draw(60,110)
  cprint('back',120,colours['lightgrey'])
 end

 readyscreen = state:create({ time=120 })
 function readyscreen:draw()
  cls(colours['maroon'])
  drawalertrect()
  cprint('level ' .. level, 40, colours['maroon'])
  cprint('target: ' .. leveldata[level].scoretarget .. ' points',60,colours['maroon'])
  cprint('time: ' .. leveldata[level].time / 60 .. 's', 70, colours['maroon'])
  cprint('ready?',90,colours['maroon'])
 end

 yesscreen = state:create({ })
 function yesscreen:draw()
  cls(2)
  drawalertrect()
  cprint('nice work!',30,colours['maroon'])
  cprint('you\'ve unlocked:',40,colours['maroon'])
  local y=55
  for i in all(is.itemlist) do
   if i.level == level then
    i.spr_falling:draw(35,y)
    print(i.name,57,y+6,colours['maroon'])
    y+= 20
   end
  end
  c_button:draw(60,100)
 end

 noscreen = state:create({ })
 function noscreen:draw()
  cls(2)
  drawalertrect()
  cprint('unlucky',50,colours['maroon'])
  cprint('you didn\'t make it...',60,colours['maroon'])
  cprint('...this time!',70,colours['maroon'])
  c_button:draw(60,100)
 end

 endscreen = state:create({ })
 function endscreen:draw()
  cls(2)
  drawalertrect()
  cprint('that\'s it,',30,colours['maroon'])
  cprint('that\'s all the levels',40,colours['maroon'])
  cprint('so i guess you could',60,colours['maroon'])
  cprint('say you\'ve completed',70,colours['maroon'])
  cprint('the game?',80,colours['maroon'])
  c_button:draw(60,100)
 end

 -- define next state for
 -- each game state
 startscreen.next = readyscreen
 instructionsscreen.next = startscreen
 readyscreen.next = gamescreen
 yesscreen.next = readyscreen
 noscreen.next = readyscreen
 endscreen.next = startscreen

 -- game state update methods

 function startscreen:update()
  -- c to play
  if btnp(4,0) then
   return self.next
  -- x for instructions
  elseif btnp(5,0) then
   return instructionsscreen
  else
   return self
  end
 end

 function instructionsscreen:update()
  -- c to progress
  if btnp(4,0) then return self.next else return self end
 end

 function readyscreen:update()
   -- ready screen shows for
   -- a specific time
   self.timeremaining -= 1
   if self.timeremaining < 1 then
    self.timeremaining = self.time
    return self.next
   end
  return self
 end

 function gamescreen:update()
  os:update()
  falling:update()
  p:update()
  timer -= 1

  -- time up
  if timer < 1 then
   p:reset()
   os:reset()
   is:reset()
   falling:reset()
   timer = leveldata[level].time
   p.score = 0
   p.x = 60
   return noscreen
  end

  -- level complete
  if p.score >= leveldata[level].scoretarget then
   level += 1
   if leveldata[level] == nil then
    return endscreen
   else
    p:reset()
    os:reset()
    falling:reset()
    is:reset()
    p.score = 0
    p.x = 60
    timer = leveldata[level].time
    return yesscreen
   end
  end
  return self
 end

 function yesscreen:update()
  -- c to progress
  if btnp(4,0) then return self.next else return self end
 end

 function noscreen:update()
  -- c to progress
  if btnp(4,0) then return self.next else return self end
 end

 function endscreen:update()
  -- reset the game
  level = 1
  p:reset()
  os:reset()
  is:reset()
  falling:reset()
  p.score = 0
  p.x = 60
  timer = leveldata[level].time
  -- c to progress
  if btnp(4,0) then return self.next else return self end
 end

 stateman.current = startscreen

 -- create items

 is = items:create()
 bottombread = item:create({ spr_falling=sprite:create({ spritex=0, spritey=0, width=16, height=16 }),
               spr_stacked=sprite:create({ spritex=0, spritey=28, width=16, height=4 }),
               spr_icon=sprite:create({ spritex=16, spritey=20, width=8, height=2 }) })
 meat = item:create({ name="meat", spr_falling=sprite:create({ spritex=32, spritey=0, width=16, height=16 }),
        spr_stacked=sprite:create({ spritex=0, spritey=20, width=16, height=4 }),
        spr_icon=sprite:create({ spritex=16, spritey=18, width=8, height=2 }) })
 topbread = item:create({ name="bread", spr_falling=sprite:create({ spritex=16, spritey=0, width=16, height=16 }),
            spr_stacked=sprite:create({ spritex=0, spritey=24, width=16, height=4 }),
            spr_icon=sprite:create({ spritex=16, spritey=20, width=8, height=2 }) })
 cheese = item:create({ name="cheese", level=2, spr_falling=sprite:create({ spritex=48, spritey=0, width=16, height=16 }),
          spr_stacked=sprite:create({ spritex=0, spritey=18, width=16, height=2 }),
          spr_icon=sprite:create({ spritex=16, spritey=17, width=8, height=1 }) })
 pickle = item:create({ name="pickle", level=2, spr_falling=sprite:create({ spritex=64, spritey=0, width=16, height=16 }),
          spr_stacked=sprite:create({ spritex=0, spritey=16, width=16, height=2 }),
          spr_icon=sprite:create({ spritex=16, spritey=16, width=8, height=1 }) })
 tomato = item:create({ name="tomato", level=3, spr_falling=sprite:create({ spritex=80, spritey=0, width=16, height=16 }),
          spr_stacked=sprite:create({ spritex=24, spritey=30, width=16, height=2 }),
          spr_icon=sprite:create({ spritex=16, spritey=31, width=8, height=1 }) })
 lettuce = item:create({ name="lettuce", level=3, spr_falling=sprite:create({ spritex=96, spritey=0, width=16, height=16 }),
           spr_stacked=sprite:create({ spritex=24, spritey=27, width=16, height=3 }),
           spr_icon=sprite:create({ spritex=16, spritey=30, width=8, height=1 }) })
 bacon = item:create({ name="bacon", level=4, spr_falling=sprite:create({ spritex=40, spritey=16, width=16, height=16 }),
         spr_stacked=sprite:create({ spritex=24, spritey=23, width=16, height=3 }),
         spr_icon=sprite:create({ spritex=16, spritey=27, width=8, height=2 }) })
 egg = item:create({ name="egg", level=4, spr_falling=sprite:create({ spritex=56, spritey=16, width=16, height=16 }),
       spr_stacked=sprite:create({ spritex=24, spritey=20, width=16, height=2 }),
       spr_icon=sprite:create({ spritex=16, spritey=26, width=8, height=1 }) })
 onion = item:create({ name="red onion", level=5, spr_falling=sprite:create({ spritex=72, spritey=16, width=16, height=16 }),
         spr_stacked=sprite:create({ spritex=24, spritey=18, width=16, height=2 }),
         spr_icon=sprite:create({ spritex=16, spritey=25, width=8, height=2 }) })
 bluecheese = item:create({ name="blue cheese sauce", level=5, spr_falling=sprite:create({ spritex=88, spritey=16, width=16, height=16 }),
              spr_stacked=sprite:create({ spritex=24, spritey=16, width=16, height=2 }),
              spr_icon=sprite:create({ spritex=16, spritey=24, width=8, height=1 }) })
 add(is.itemlist, bottombread)
 add(is.itemlist, meat)
 add(is.itemlist, topbread)
 add(is.itemlist, cheese)
 add(is.itemlist, pickle)
 add(is.itemlist, tomato)
 add(is.itemlist, lettuce)
 add(is.itemlist, bacon)
 add(is.itemlist, egg)
 add(is.itemlist, onion)
 add(is.itemlist, bluecheese)

 -- create recipes

 rs = recipes:create()
 burger = recipe:create({ ingredients={bottombread,meat,topbread} })
 cheeseburger = recipe:create({ ingredients={bottombread,meat,cheese,topbread} })
 doublecheeseburger = recipe:create({ ingredients={bottombread,meat,meat,cheese,topbread} })
 cheeseburgerwithpickles = recipe:create({ ingredients={bottombread,meat,cheese,pickle,topbread} })
 burgerwithpickles = recipe:create({ ingredients={bottombread,meat,pickle,topbread}, points=15 })
 burgerwithtomato = recipe:create({ ingredients={bottombread,meat,tomato,topbread}, points=15 })
 burgerwithlettuce = recipe:create({ ingredients={bottombread,meat,lettuce,topbread}, points=15 })
 burgerwithsalad = recipe:create({ ingredients={bottombread,meat,tomato,lettuce,topbread}, points=15 })
 doublecheeseburgerwithsalad = recipe:create({ ingredients={bottombread,meat,meat,cheese,pickles,tomato,lettuce,topbread}, points=25 })
 breakfastbap = recipe:create({ ingredients={bottombread,meat,bacon,egg,topbread}, points=15 })
 blt = recipe:create({ ingredients={bottombread,bacon,lettuce,tomato,topbread}, points=15 })
 baconcheeseburger = recipe:create({ ingredients={bottombread,meat,cheese,bacon,egg,topbread}, points=20 })
 onionburger = recipe:create({ ingredients={bottombread,meat,tomato,lettuce,onion,topbread}, points=15 })
 bluecheeseburger = recipe:create({ ingredients={bottombread,meat,meat,bluecheese,onion,topbread}, points=25 })
 acidrefluxburger = recipe:create({ ingredients={bottombread,meat,pickle,onion,topbread}, points=20 })
 veggieburger = recipe:create({ ingredients={bottombread,tomato,lettuce,onion,cheese,topbread}, points=15 })

 add(rs.recipelist,burger)
 add(rs.recipelist,cheeseburger)
 add(rs.recipelist,doublecheeseburger)
 add(rs.recipelist,cheeseburgerwithpickles)
 add(rs.recipelist,burgerwithpickles)
 add(rs.recipelist,burgerwithtomato)
 add(rs.recipelist,burgerwithlettuce)
 add(rs.recipelist,burgerwithsalad)
 add(rs.recipelist,doublecheeseburgerwithsalad)
 add(rs.recipelist,blt)
 add(rs.recipelist,breakfastbap)
 add(rs.recipelist,baconcheeseburger)
 add(rs.recipelist,onionburger)
 add(rs.recipelist,acidrefluxburger)
 add(rs.recipelist,bluecheeseburger)
 add(rs.recipelist,veggieburger)


 -- create player
 p = player:create()
 p:reset()

 -- create order system
 os = orders:create()

 -- create falling items list
 falling = fallingitems:create()

 -- graphics for game
 hatch = sprite:create({ spritex=120, spritey=0, width=8, height=8 })
 bin = sprite:create({ spritex=120, spritey=8, width=8, height=8 })
 tick = sprite:create({ spritex=120, spritey=16, width=8, height=8 })
 cross = sprite:create({ spritex=120, spritey=24, width=8, height=8 })
 -- button graphics
 c_button = sprite:create({ spritex=112, spritey=24, width=8, height=8 })
 x_button = sprite:create({ spritex=112, spritey=0, width=8, height=8 })
end
-->8
-- update and draw functions
-- these both update/draw for
-- the current game state

function _update()
 stateman:update()
end

function _draw()
 stateman:draw()
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666511111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000053b00000006566656515555553
000000000000000000000000000000000000000000000000000000999900000000000003b9b0000000000044440000000000003bb500f0006656566515555533
0000000000000000000049999444000000000000000000000000099aaaa00000000000bb99b9000000004448844400000003333bb3066b006665666515555331
000000000000000000099999999444000005554554545000000099aaa9aa0000000003b99bb9b0000004488a8a84400000bb633b3536bb006656566535553351
0000000000000000009999999999940000554454455455000009aaaa909aa00000000399bba9b900004889ee88f8440000bb36635533bb006566656533533551
0000000000000000099999999999944005544554554554500099aaaaaaaaaa00000003bbb99b9b0000499ffe8ff8840000bb3f655336bb006666666513335551
0000000000000000099999999999944055445545544544450099aaaaaaaa9aa0000003bb99ba9b00048898fffffa944000b3bbf533fbbb005555555511311111
04999999999999400f999999999444f05445544544554445009aaa99aaaa0aa000003339ab99bb00048fffffffff894000bb33653fbbb3000000000055555555
44999999999999940fff99949444fff05555445544544455009aa9009aaaaaa00003bb333b9bb000048a88ffff888440000bb333fbbb30000000000055888855
f44999999999944400ffffff99ffff0005554554455555550009a909aaaaaa00003bb9b33333300000488ffeeff894000000bb33fbb500000000000058855585
ffffffffffffffff000ffffffffff00000555555555555500000aa9aaaaaa00000bb99b9b30000000044afeeeffa84000000bb355b3500000000000058585585
04999999999999400000000000000000000544444444450000000aaaaa000000003a9ba9b3000000000488e8eea84000000006b0053000000000000058558585
000000000000000000000000000000000000000000000000000000aaaa0000000039b99bb3000000000044a89884000000000000000000000000000058555885
0000000000000000000000000000000000000000000000000000000aa00000000003bab300000000000000444400000000000000000000000000000055888855
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555
03babb900ba9ba3003300330717000cfc070071f00000000000000000000000000000000000000000000000000000000000000000000000076666666009aaa00
0333333003333330aaaaaaaaf777101f70cf000c0000000000008000000000000000000000000002222200000dd0007600000000000000007666666609aaaaa0
a0aa99aa9aa00aa044444444000e2ee222000000000000000088f9000000077777700000000e7622ee22e0000177000600d660000000000076666666955aa55a
99999aaaa9aaaaaa444444442e522222055e22ee00000000488ff90000006777777700000027002f00022e0000577000006770000000000076666666957aa57a
0555555555555550ffffffff067799aaaaa977700000000488f9980000066aaa977770000270002f00002e00000557000d67000000000000766666669aaaaaaa
4444444444444444ffffffff6677777777777777000000844ff998000066aaa994777700026000f0000062000000577d6650000000000000766666669a8888aa
444444444444444499999999000000000000000000000084ff4880000066a9999447770002600026000062000d005d776770000000000000766666660aa88aa0
044444444444444099999999044444444444400000000084f9940000006aa9999a47777002276f2f00062e000000c11777000060000000007777777700aaaa00
000fffffffff9000c77cc77c4fffffefefffeee800000044f9840000006aa9999a47777000222522fff2e0000077dd16777710000000000066666665009aaa00
0fffffffffff9990222002228e800088888888ee0000444ff84000000567aa9aa47777700002225222225000000dd76617777000000000006655566509aaaaa0
0ff999999999999077aaaa770000000000000000000444ff0000000005677a99477777700000550000005000000007677000070000000000656665659aaaaaaa
f999999999999999eeee44440bb33bbb000066b0004ffff8000000000566777777777700000026000000620000077107170000000000000065666665955aa55a
09999999999999904444eeeeb333333bbb666bbb0488ff88000000000556777776677700000026000000620000066007101000000000000065666565ccaaaacc
999999999999999f000000003300003bbbbbbbbb048ff88000000000005567776556600000000260000f200000d60000100000000000000066555665ca5555ac
4444ffffffffffffbbbbbbbb0489a88898a94440088f00000000000000055555500000000000002666f20000000000000000000000000000666666650aaaaaa0
04444444444444400888888004488888888884400000000000000000000000000000000000000002222000000000000000000000000000005555555500aaaa00
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e3e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e3e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000400000b75009740077300572000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000095500b5500d550105501255014550175501a5501e5502155024550275402953000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c15000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000003615036150351503415032150301502e1502b150271502315023150211501e1501b1501815015150121500f1500c15009150061500000000000000000000000000000000000000000000000000000000
000000001545012450104500e4500c450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
