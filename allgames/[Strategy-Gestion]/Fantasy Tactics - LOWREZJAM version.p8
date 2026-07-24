pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- fantasy tactics
-- lowrezjam 2020
-- by slainte
--------------------------------
local function noop() end

local function dec2hex(val)
  if (tonum(val)<10) return tostr(val)
  return chr(tonum(val)-10+ord("a"))
end

local function hex2dec(val)
  if (val>="a") return tonum(ord(val)-ord("a")+10)
  return tonum(val)
end

local function setgeneralpal(display)
  local paldata={131,2,139,4,5,6,7,136,9,135,138,12,13,14,15}
  pal(paldata,display or 0)
  pal(0,128,display or 0)
  palt(1<<6)
end

-- entity list handler
--------------------------------
local entity_list do
  local mt={
    by_id={},
    by_prio={},
    list={},    
    -- rebuild by_id and by_prio
    refresh = function(self)      
      local idx,e
      self.by_id,self.by_prio={},{}
		    for idx,e in ipairs(self.list) do
								self.by_id[e.id]=idx
								if (self.by_prio[e.priority]==nil) self.by_prio[e.priority]={}								
								add(self.by_prio[e.priority],idx)
		    end   
    end,
    -- add a new entity to the list
    add_e = function(self,e)
      add(self.list,e)
      self:refresh()
    end,  
    -- remove an entity from the list
    del_e = function(self,e)
      local idx,le      
						for idx,le in ipairs(self.by_prio[e.priority]) do
						  if (self.list[le].id==e.id) deli(self.by_prio[e.prio],idx)
						end
						deli(self.list,self.by_id[e.id])
						self.by_id[e.id]=nil
						self:refresh()
    end,    -- find an entity by a callback
    find_e = function(self,cb,...)
      local reslist={}
      for _,e in pairs(self.list) do
        if (cb(e,...)==true) add(reslist,e)
      end
      if (#reslist) then
        -- return the non-dead unit
        for e in all(reslist) do
          if (not e:isdead()) return e
        end
        -- return any of the dead ones
        return reslist[1]
      end
      return false
    end,
    clear = function(self)
      self.by_id=nil
      self.by_prio=nil
      self.list=nil
      self.by_id={}
      self.by_prio={}
      self.list={}
    end    
  }
  mt.__index = mt
  entity_list = setmetatable({},mt)
end

game = {
  title  = "fantasy_tactics",
  dbg    = false,
  dbgempt= true,
  state  = false,       -- current game state
  timer  = 0,           -- global game tick
  e_list = entity_list, -- managed entity list
  debug  = function(self,msg)
    if (self.dbg) then
      printh(msg,self.title,self.dbgemp)
      self.dbgemp=false
    end
  end,
  -- add e to the list
  add_e  = function(self,e)
    self.e_list:add_e(e)
    return e
  end,
  -- remove e from the list and delete it
  del_e  = function(self,e)
    self.e_list:del_e(e)
    e=nil
  end,
  -- find e in list by callback
  find_e  = function(self,cb,...)
    return self.e_list:find_e(cb,...)
  end,
  -- find by id
  find_byid = function(self,id)
    return self:find_e(function(e,id) return (e.id==id) end,id)
  end,
  -- find by cell position
  find_bycell = function(self,i,j)  
    return self:find_e(function(e,i,j) return (e.i==i and e.j==j) end,i,j)
  end,
  -- set active gamestate
  set_state = function(self,state)
    -- a state always clears scren
    cls()
    -- remove previous state junk
    self.e_list:clear()
    -- set the new state
    self.state=state
    state:init()
  end,
  -- true if timer%d == 0
  beat = function(self,d)
    d=d or 1
    return (self.timer%d==0)
  end,
  -- update prototye
  update = function(self)
    local idx,t,id,e
    -- update the timer
    self.timer=(self.timer+1)%60
    -- first update state
    if (self.state) self.state:update()      
    -- then update managed list
    for idx,t in pairs(self.e_list.by_prio) do
      for _,id in ipairs(t) do
        e = self.e_list.list[id]
        if (e) e:update()
      end
    end
  end,
  -- draw prototype
  draw = function(self)
    local idx,t,id,e    
    -- if state forces clearscreen
    if (not self.state or self.state.clearscreen) cls(0)
    -- draw the state
    if (self.state) self.state:draw()
    -- draw the managed list
				-- then update managed list
    for idx,t in pairs(self.e_list.by_prio) do
      for _,id in ipairs(t) do
        e = self.e_list.list[id]
        if (e) e:draw()
      end
    end
  end
}


-- gamestate object
local gamestate do
  local mt = {
  init=noop,
  draw=noop,
  update=noop,
  clearscreen=true,
  __call=function(self,proto)
    local e = setmetatable(proto or {},getmetatable(self))
    self.__index=self
    return e
  end
  }
  mt.__index=mt
  gamestate=setmetatable({},mt)
end

-- entity prototype
local entity do
  local mt = {
    max_id = 0,
    persistent = false,
    x=0,y=0,priority=0,sptable={},
    draw=noop,update=noop,init=noop,
    setpriority=function(self,priority)
      self.priority = priority
    end,
    nextid=function(self)
      self.max_id+=1
      return self.max_id
    end,
    __call=function(self,proto,priority)
      self.__index=self
      proto.__index=proto
      local e = setmetatable({},proto)
      e.id = self:nextid()
      e:setpriority(priority)
      game:add_e(e)
      return e
    end
  }
  mt.__index = mt
  entity=setmetatable({},mt)
end

function _draw()
  game:draw()
--  print(stat(7).." fps",40,0,7)
--  print("cpu:"..flr(stat(1)*100).."%",35,6,7)
end

function _update60()
  game:update()
end

function _init()
  
  -- logos to memory
  local fantasy='ÿÿ‰ÿêÃ¦ŒðÿãÿýˆÃÿû¢ø¿Áÿÿ‚ð‰Žàƒü…¸‡‹«Ð¡Â»È°¡ÂÂÌ¼øðŠŒÂñàÂ‘¬æŸ¦ÃÝ†Í©‚Ò‡ ¢¹Ð’€„‡„Â«–„Š’ˆŽÒŒŽà“Ñ¼„±ˆ”àÁñ‘‰‰¾œ¸€á“œ‚´øÈƒß°¡Ãòž±á«ÂÿÓü¡šÿŸåÇƒÿ¯‰üŸÎ¤£Æÿã¡€'
  local tactics='ÿ—Ï­×—¾áÀ¿†ÅÈ£Œ€Øðˆ€£ˆ°‚¥€ ˆ€‚ÁÉàÌØñàÈÄ‹›¬˜‚üƒ¿¨øò Á¿ àä®Ã„‚á¯“þ’”Ëùÿæ€'
  px9_sdecomp(0,0,fantasy,mget,mset)
  px9_sdecomp(0,17,tactics,mget,mset)
  -- set mode 3 (64x64)
 	poke(0x5f2c,3)
 	clip(0,0,63,63)
 	-- set palette
 	setgeneralpal(1)
 	poke(0x5f2e,1)
 	-- get the game started  
  game:set_state(intro)
end



-->8
-- non game states
--------------------------------

-- intro state
--------------------------------
intro=gamestate({
  mapdata="66331032003120200031103310300030003000200030003110613060006000200020002000620060006040600030003000630060306000300050005000653061006000300050004000",
  })

function intro:init()  
  levelmap:load(self.mapdata)
  self.st = mapstate:init(2,2)
  entity(deer(2,3))
end

function intro:draw()
  levelmap:draw(self.st)  
  draw_logo("fantasy",1,1)
  draw_logo("tactics",10,15)  
end

function intro:update()   
  if (btnp()>0) game:set_state(menu)
end


-- menu state
--------------------------------
menu=gamestate({
  mapdata="551000100010001000100010001000310010001000100031003100310010001000100031001000100010001000100010001000",
})

function menu:init()  
  levelmap:load(self.mapdata)
  self.st = mapstate:init(1,1)  
  self.d = entity(deer(3,3))  
end

function menu:draw()
  draw_logo("fantasy",1,1)
  draw_logo("tactics",10,15)
  levelmap:draw(self.st)
  pal(7,6)
  sspr(0,85,29,5,17,25)
  pal(7,7)
end

function menu:update()
  local d=self.d
  if (btnp(—)) game:set_state(play)
  if (btnp(‘) and not levelmap:empty(d.i+1,d.j)) d.i+=1
  if (btnp(‹) and not levelmap:empty(d.i-1,d.j)) d.i-=1
  if (btnp(”) and not levelmap:empty(d.i,d.j-1)) d.j-=1
  if (btnp(ƒ) and not levelmap:empty(d.i,d.j+1)) d.j+=1
end
-->8
-- global entities
--------------------------------

-- sides
--------------------------------
side_kingdom = 1
side_undead  = 2

sides={
  [side_kingdom]={
    name="the kingdom",
    unitlist={},
    },
  [side_undead]={
    name="the undead",
    unitlist={},
    },
  init = function(self)
    -- nothing to do here for now
  end
}

-- game turn
--------------------------------
local turn do
  local mt = {      
    __call = function(self,side_id)
      game:debug("turn constructor "..tostr(self,true))
      local s=sides[side_id]

      local actmenu=game.state.activemenu
      if (self.nextside and self:checkendgame()) then
        self:endgame()
      else
        turnmenu.opts={""..s.name..""}
        if actmenu and actmenu.state~="off" then
          actmenu.nextmenu=turnmenu
        else      
          game.state.activemenu=turnmenu
          turnmenu:open()
        end
        self.__index=self     
        -- iterate all units in that side and init them
        local u
        for u in all(s.unitlist) do
          u:initturn() 
        end
        return setmetatable({
          side      = side_id,
          unitcount = #s.unitlist,
          unitmoved = 0,
          nextside  = side_id==#sides and 1 or (side_id+1),
          unitlist  = sides[side_id].unitlist
        },self)
      end
    end,
    -- construct next turn
    getnext = function(self)
      game:debug("getnext for "..tostr(self,true))
      if not self:checkendgame() then
        return turn(self.nextside)
      else
        self:endgame(self.side)
        return self
      end
    end,
    -- select first pending unit in side
    selectunit = function(self)
      local u 
      for u in all(sides[self.side].unitlist) do 
        if (not u.done and not u:isdead()) then
          mapstate:centerat(u:getcell())
          return
        end
      end
    end,
    -- check end game
    checkendgame = function(self)
      game:debug("checkendgame for side "..self.side..":"..tostr(self,true))
      -- check enemy side
      for u in all(sides[self.nextside].unitlist) do
        if (not u:isdead()) then
          game:debug(u.name.." not dead:" .. u.life)
          return false
        end
      end      
      game:debug("all dead")
      return true
    end,
    endgame = function(self,side)
      game:debug("ending game for  side "..self.side..":"..tostr(self,true))
      victory.opts={""..sides[self.side].name.."","wins the day"}
      if game.state.activemenu and game.state.activemenu.state~="off" then
        game.state.activemenu.nextmenu=victory
      else      
        game.state.activemenu=victory
        victory:open()
      end
    end,
    -- check end turn
    checkendturn = function(self)
      game:debug("checkendturn for  side "..self.side..":"..tostr(self,true))
      if (self:checkendgame()) then
								self:endgame()
      else      
		      -- check for pending units
		      for u in all(sides[self.side].unitlist) do
		        if (not u.done and not u:isdead()) return
		      end
		      mapstate.turn = self:getnext()
		    end
    end,    
  }
  mt.__index = mt
  turn=setmetatable({},mt)
end

local cell_list do
  local mt = {
  __call = function(self)
    local e = setmetatable({list={},l=0},self)
    self.__index=self        
    return e 
  end,
  getfirst = function(self)
    return self.first.i,self.firs.j
  end,
  len = function(self) 
    return self.l 
  end,
  addij = function(self,i,j)
    self:addcell(cell(i,j))
  end,
  addcell = function(self,t)
    if (not self.first) self.first=t
    if (not self.list[t.j]) self.list[t.j]={}
    add(self.list[t.j],t.i)
    self.l+=1
  end,
  -- cell based search
  inlist = function(self,t)
    return self.list[t.j] and count(self.list[t.j],t.i)>0
  end,
  -- shortcut for i,j calls
  inlistij = function(self,i,j)
    return self:inlist(cell(i,j))
  end
  }
  mt.__index = mt
  cell_list = setmetatable({list={}},mt)
end
-->8
-- mapstate
--------------------------------
mapstate={
  opt = 1, -- menu option
  rotpals = {
    red={
      {[2]=2,[8]=8,[14]=14}, -- base
      {[2]=8,[8]=14,[14]=2}, -- +1
      {[2]=14,[8]=2,[14]=8}, -- +1
      },
   green={
      {[2]=1,[8]=3,[14]=11}, -- base
      {[2]=3,[8]=11,[14]=1}, -- +1
      {[2]=11,[8]=1,[14]=3}, -- +1
      }
    },
  init = function(self,col,row,showcursor)
    local _ENV=self
    posi,posj=col or 1, row or 1    -- curr i=col/j=row position
    cposi,cposj=posi,posj  -- cursor col/row position
    has_cursor=showcursor or false
				return self
  end,
  -- center map at tile
  centerat = function(self,i,j)
    self.cposi,self.cposj=i,j
    self.posi=min(i,levelmap.width-3)
    self.posj=min(j,levelmap.height-3)
  end,
  -- reset unit
  resetunit = function(self) 
    self:releaseunit(true)
  end,
  -- release unit
  releaseunit = function(self,doreset)
    local _ENV=self
    if (activeunit) then
      if (doreset or false) then
        centerat(self,activeunit.i,activeunit.j)
        activeunit:resetpos()
      else
        activeunit:endturn()
      end
      activeunit,mvarea = nil,cell_list()
    end
  end,
  -- activate  unit
  activateunit = function(self,e)       
    if (e and not e:isdead() and not e.done and self.turn.side==e.side) then
      e:calc_movearea(true)
      self.activeunit = e      
      self.mvarea     = e.mvarea
    end
  end,
  -- move/update map position
  update = function(self)
    local btnp,”,ƒ,‹,‘ = btnp,”,ƒ,‹,‘
    local lv = levelmap
    local w,h=lv.width,lv.height
	   local _ENV=self
 	  if (btnp(‘) and cposi<w) then
	     -- moving ‘
	     if (not lv:empty(cposi+1,cposj)) then  
	       cposi+=1   
	       if (cposi>2 and posi<w-3) posi+=1
 	    end
 	  elseif (btnp(‹) and cposi>1) then
	     -- moving ‹
 	    if (not lv:empty(cposi-1,cposj)) then  
	       cposi-=1
 	      if (cposi<posi) posi-=1
 	    end
	   elseif (btnp(ƒ) and cposj<h) then
 	    -- moving ƒ
 	    if (not lv:empty(cposi,cposj+1)) then  
 	      cposj+=1
 	      if (cposj>2 and posj<h-3) posj+=1
 	    end  
 	  elseif (btnp(”) and cposj>1) then
 	    -- moving ”
 	    if (not lv:empty(cposi,cposj-1)) then  
 	      cposj-=1
 	      if (cposj<posj) posj-=1
 	    end
 	  end
  end
}

tiletypes={
  {0,96,5,13,10},  -- empty tile (not blitted!)
  {16,96,5,13,10}, -- rock road
  {32,96,4,9,10},  -- green grass
  {48,96,1,12,10}, -- water
  {64,96,9,15,10}, -- sand
  {0,106,2,13,10}  -- dark forest
}

features={
  data={
    {118,96,10,16,12}, -- green tree
    {98,96,10,16,10},  -- rock
    {108,96,10,16,12}, -- pink tree
    {88,96,10,16,10}   -- crystal
  },
  draw=function(self,idx,x,y)
    f=self.data[idx]
    if (f) then
      palt(1<<15-f[5])
      sspr(f[1],f[2],f[3],f[4],x,y)
      palt(1<<5)
    end
  end
}

-- level data
--------------------------------
levelmap = {
  width=12,
  height=12,
  tiles={},
  features={
    {118,96,10,16,12,'tree'},
    {98,96,10,16,10,'rock'},
    {108,96,10,16,12,'dead tree'},
    {88,96,10,16,10,'crystal'},
  },
  highlight = function(x,y,c)
    line(x+1,y+4,x+7,y+1,c or 7)
    line(x+14,y+4)
    line(x+7,y+7)
    line(x+2,y+4)
  end
}

function levelmap:getz(i,j)
  return self.tiles[i][j]['z']
end

function levelmap:blocked(i,j)
  return self.tiles[i][j]['f']>0 or self:empty(i,j)
end

function levelmap:occupied(i,j)
  local e = game:find_bycell(i,j)
  return self:blocked(i,j) or (e and not e:isdead())
end


function levelmap:passable(i,j)
  return not self:occupied(i,j)
end

function levelmap:empty(i,j)
  return (self.tiles[i][j]['t']==1)
end

function levelmap:iswater(i,j)
  return (self.tiles[i][j]['t']==4)
end

function levelmap:cantarget(i,j)
  return not (self:blocked(i,j) or self:iswater(i,j))
end

function levelmap:insidebounds(i,j)
  return i > 0 and i<=self.width and j>0 and j<=self.height
end

-- initialize an empty map
function levelmap:init()
  local i,j  
  -- clear it just in case
  self.tiles={}
  -- init the structure
  for j=1,self.width do
    for i=1,self.height do
      if (not self.tiles[j]) self.tiles[j]={}
      if (not self.tiles[j][i]) self.tiles[j][i]={}
      self.tiles[j][i]['z']=0
      self.tiles[j][i]['t']=1
      self.tiles[j][i]['f']=0
      self.tiles[j][i]['u']=0
    end
  end
    
  return self
end

function levelmap:load(str)
  local rd,val,tile = 3,nil,nil
  local i,j = 1,1
  -- reset unitlists  
  sides[1].unitlist={}
  sides[2].unitlist={}
  
  self.width=hex2dec(sub(str,1,1))
  self.height=hex2dec(sub(str,2,2))  
  -- precreate things
  self:init()
  -- load the data
  while (rd<#str) do
    local idx,val
    tile=self.tiles[j][i]
    -- read blocks of 4
    tile.t=hex2dec(sub(str,rd,rd))
    rd+=1
    tile.z=hex2dec(sub(str,rd,rd))
    rd+=1
    tile.f=hex2dec(sub(str,rd,rd))
    rd+=1
    tile.u=hex2dec(sub(str,rd,rd))
    if(tile.u>0) then
      -- add the entity to the game
      local e = entity(units[tile.u](j,i))
      local fe = game:find_bycell(e.i,e.j)
      -- add the unit to that side unitlist
      add(sides[e.side].unitlist,e)
    end
    rd+=1
    -- increase i
    i+=1
    if (i>self.width) then
      i=1
      j+=1
    end 
  end  
end

-- receives a map-enabled state
function levelmap:draw(mapstate)

  if (not mapstate) stop("no map state data!")
      
  local i,j=0,0  
  local selected_unit = nil
  -- currently active unit
  local activeunit=mapstate.activeunit
  local mvarea = mapstate.mvarea
  
  -- print the map
  for j=1,self.height do
    local x=32-8*j-8*(mapstate.posi)+8*(mapstate.posj-1)
    for i=1,self.width do
       -- current tile... will need it
      local tile = self.tiles[i][j]
      local tiletype = tiletypes[tile.t]
      local ox=x+8*i
      local y=22+4*j+4*i-4*(mapstate.posi-1)-4*(mapstate.posj-1)
      local h=2*tile.z
      local maxy = y-h-16*(tile.f>0 and 1 or 0)               
      
      -- truncate tile drawing for speed
      -- if tile is out of visible space
      if (tile.t>1 and ox<63 and ox>-16 and y>-10 and maxy<63) then  
        -- high tiles
        if (h>0) then
          local h2,h3=0,0 
  	       if (j<self.height) h2=2*self.tiles[i][j+1].z
          if (i<self.width) h3=2*self.tiles[i+1][j].z
          local px,py=0,y-h+5
          local c1,c2=tiletype[3],tiletype[4]
          rectfill(ox+px,py,ox+7,h2>0 and y+10-h2 or y+5,c1)
          rectfill(ox+8,py,ox+15-px,h3>0 and y+10-h3 or y+5,c2)
          py=y+6
          px+=1    
          while py<y+10 do
            if (py<y+10-h2) line(ox+px,py,ox+7,py,c1)
            if (py<y+16-h3) line(ox+8,py,ox+15-px,py,c2)
            px+=2
            py+=1
          end             
	         y-=h
        end        
        -- base tile
        sspr(tiletype[1],tiletype[2],16,10,ox,y)
        -- check if this is inside the active mvarea
        if (activeunit) then
          local palidx,area ='red',cell_list()
          if not activeunit.hasmoved then
            area = activeunit.mvarea
          elseif activeunit.wait_target then
            area = activeunit.act_area
            palidx='green'            
          end
          if area:len()>0 and area:inlistij(i,j) and not self:iswater(i,j) then
            -- rotate marker palette
            local cidx,shift=1,ceil(game.timer/10)
            local pals=mapstate.rotpals[palidx]
            shift= shift - (shift>3 and 3 or 0)
            pal(pals[shift],0)
            -- print the marker          
            sspr(0,116,16,9,ox,y)        
            pal({[2]=2,[8]=8,[14]=14},0)
          end
        end
        -- selection square
        if (mapstate.cposi==i and mapstate.cposj==j and mapstate.has_cursor) self.highlight(ox,y)
	       -- feature
        if (tile.f>0) features:draw(tile.f,ox+3,y-11)
        -- check if there is a unit here...
        local e = game:find_bycell(i,j)
        if (e) then
          local highlighted=false
          e:setpos(ox,y)
          if (i==mapstate.cposi and j==mapstate.cposj) then
		  		  			 highlighted=true
				  		  	 selected_unit=e
          end
          e:drawat(highlighted)
        end
     end
   end
 end
 return selected_unit  
end
-->8
-- units
--------------------------------
unit = setmetatable({
  jump     = 2,
  maxmoves = 3,
  offset   = 0,
  mgk      = 0,
  side     = 1,
  areas    = {},
  targets  = {},
  checkopt = false,
  -- shadow constructor
  __call = function(self,i,j)
    local e=setmetatable({i=i,j=j},self)
    self.__index = self
    e:init()
    return e
  end,
  -- precalculate stuff
  init = function(self)
    self.life=self.maxlife
    self:savepos()
    self.prevpos={self.i,self.j}
  end,
  -- initialize turn stuff
  initturn = function(self)
    self.hasmoved,self.done,self.wait_target=false,false,false
  end,
  -- finalize turn for unit
  endturn = function(self)
    local _g,_ENV=_ENV,self
    prevpos=sorigpos
    savepos(self)
    hasmoved,done,wait_target=true,true,false
    targets={}
    currtarget=0
    _g.mapstate.turn:checkendturn()
    
  end,
  -- set x,y position (pixels)
  setpos = function(self,x,y)
    self.x,self.y=3+x,y-11
  end,
  -- get cell position (i,j)
  getcell= function(self)
    return self.i,self.j
  end,  
  isdead = function(self)    
    return self.life==0
  end,
  -- update anim
  update = function(self)
    if (game:beat(30)) self.offset+=16
    self.offset%=32
  end,
  -- determine if you can climb up
  canclimb = function(self,ni,nj)
    return self.mvarea:inlistij(ni,nj) and (levelmap:getz(ni,nj)<=levelmap:getz(self.i,self.j)+self.jump)
  end,
  -- determine if you can jump across water
  canjump = function(self,ni,nj)
    return self.mvarea:inlistij(ni,nj) and not levelmap:iswater(ni,nj)
  end,
  activate_target = function(self)
    if (not self.wait_target) return
    if (#self.targets>0) then
      if btnp(‘) or btnp(”) then self:prevtarget()
      elseif btnp(‹) or btnp(ƒ) then self:nexttarget()
      elseif btnp(—) then       
        self.targetcb(self,self:getcurrtarget(),self.targetact) 
      end
    end      
    if btnp(Ž) then 
      -- return to unit menu
      self.wait_target=false
      game.state.activemenu=unitmenu
      unitmenu:open()      
    elseif btnp(—) then mapstate:releaseunit() end
  end,
  nexttarget = function(self)
    if (#self.targets==0) return
    self.curr_target+=(1-(self.curr_target==#self.targets and #self.targets or 0))
    mapstate:centerat(self.targets[self.curr_target]:getcell())
  end,
  prevtarget = function(self)
    if (#self.targets==0) return
    self.curr_target-=1
    if (self.curr_target<=0) self.curr_target=#self.targets
    mapstate:centerat(self.targets[self.curr_target]:getcell())  
  end,
  -- unitmenu callbacks
  doattack = function(self,act)
    self.targetcb=self.executeattack
    self:select_enemy(act)
  end,
  dopotion = function(self,act)    
    local mapstate,_ENV=mapstate,self
    if pots>0 then
      pots-=1
      life+=3
      life= maxlife<life and maxlife or life
    end
    mapstate:releaseunit()
  end,
  -- activate_target callbacks  
  executeattack = function(self,target,act)
    combatscr:combat(self,target,act)
    if (act~="attack") self.mgk-=1
  end,
  -- control moving inside self mvarea
  move = function(self)
    -- don't move if already moved
    if (self.hasmoved) return
    -- handle inputs
    local ma,i,j = self.mvarea,self.i,self.j    
    if btnp(‘) and ma:inlistij(i+1,j) then	     
	     if levelmap:iswater(i+1,j) then i+=(self:canjump(i+2,j) and 2 or 0)
	     else i+=1 end
	   elseif btnp(‹) and ma:inlistij(i-1,j) then
	     if levelmap:iswater(i-1,j) then i+=(self:canjump(i-2,j) and -2 or 0)
	     else i-=1 end
	   elseif btnp(”) and ma:inlistij(i,j-1) then
      if levelmap:iswater(i,j-1) then j+=(self:canjump(i,j-2) and -2 or 0)
      else j-=1 end
    elseif btnp(ƒ) and ma:inlistij(i,j+1) then 
      if levelmap:iswater(i,j+1) then j+=(self:canjump(i,j+2) and 2 or 0)
      else j+=1 end      
    end
    if i~=self.i or j~=self.j then
      self:moveto(i,j)                 
    end
  end,
  -- end move and open action menu
  endmove = function(self)
    self.hasmoved=true
	   game.state.activemenu=unitmenu
    unitmenu:open()
  end,
  -- outline this unit
  outline = function(self)
    local c,x,y=0,self.x,self.y
    local oc = self.side==1 and 14 or 14
    local i,j
    for c=0,15 do
       pal(c,oc)
    end
    for j=y-1,y+1 do
      for i=x-1,x+1 do
        self.x=i
        self.y=j
        self:drawat()        
      end
    end
			 self.x,self.y=x,y
    for c=0,15 do
      pal(c,c)
    end
  end,
  drawat = function(self,highlight)
    if (self.x>-10 and self.x<64 and self.y>-16 and self.y<64) then
      if self:isdead() then
							 sspr(118,64,10,5,self.x-1,self.y+11,10,5,self.i>levelmap.width/2 and true or false)
      else
        if (highlight or false) self:outline()
        sspr(self.sp,self.offset,10,16,self.x,self.y,10,16,self.i>levelmap.width/2 and true or false)
      end
    end
  end,
  -- keep original position for reset
  savepos = function(self)
    self.origpos = {self.i,self.j}
  end,
  -- get 
  resetpos = function(self)
    self:moveto(self.origpos[1],self.origpos[2])
    self:initturn()
  end,
  -- set i,j position
  moveto = function(self,ni,nj) 
    self.i,self.j=ni,nj
    mapstate:centerat(ni,nj)
  end,
  -- calc movearea
  calc_movearea = function(self,forced)
    -- no need to recalculate      
    if ((not forced or false) and self.i==self.prevpos[1] and self.j==self.prevpos[2]) return
    -- new list for the mvarea
    self.mvarea = cell_list()
    -- prepare calculation
    local function checktile(i,j,z,w)
      if levelmap:occupied(i,j) or
         (levelmap:iswater(i,j) and w) or
         (levelmap:getz(i,j)>z+self.jump) then
        return false
      end
      return true
    end
    
    local c=cell(self.i,self.j,0)
    local m,nodes=self.maxmoves,{}
    local olist,clist={},{}
    -- add initial tile
    add(olist,c)
    while(#olist>0) do    
      -- take node off
      local c=olist[1]
      deli(olist,1)      
      local i,j,m=c.i,c.j,c.m
      -- check if it is worse than a previous
      if not clist[i] or not clist[i][j] or clist[i][j]['m']>m then
        m+=1
        local w,z=levelmap:iswater(i,j),levelmap:getz(i,j)
        if (m<=self.maxmoves) then
          -- expand in 4 directions
          if (i>1 and checktile(i-1,j,z,w)) add(olist,cell(i-1,j,m))
          if (i<levelmap.width and checktile(i+1,j,z,w)) add(olist,cell(i+1,j,m))
          if (j>1 and checktile(i,j-1,z,w)) add(olist,cell(i,j-1,m))
          if (j<levelmap.height and checktile(i,j+1,z,w)) add(olist,cell(i,j+1,m))
        end
        -- add to computed tiles
        clist[i]=clist[i] or {}
        clist[i][j]=c
        if (not self.mvarea:inlist(c) and (c.m<self.maxmoves or (c.m==self.maxmoves and not w))) self.mvarea:addcell(c)
      else
        -- skipping, already done with it
      end
    end      
  end,
  -- calculate attack area
  calc_area = function(self,tpl)
    game:debug("calculating area for "..self.name)
    local i,j
    local x,y=30+(tpl*5),64
    self.act_area=cell_list()
    for j=-2,2 do
      for i=-2,2 do
        local cx,cy = x+i+2,y+j+2
        local di,dj = self.i+i,self.j+j
        if levelmap:insidebounds(di,dj) then
          if sget(cx,cy)==15 and levelmap:cantarget(di,dj) then
            self.act_area:addij(di,dj)
            -- acquire targets
            local e=game:find_bycell(di,dj)
            if e and self.targets[e.side] then
              game:debug("found e :"..tostr(e))              if (not e:isdead()) add(self.targets[e.side],e)
            end
          end
        end 
      end
    end
  end,  
  select_friend = function(self,act)
    self:select_units(act,self.side)
  end,  
  select_enemy = function(self,act)
    self:select_units(act,mapstate.turn.nextside)
  end,
  select_units = function(self,act,s)
    local game,_ENV = game,self
    -- build target list    
    targets={[s]={}}
    select_tgt(self,act)    
    targetact=act
    targets=targets[s]
    if #targets>0 then
      curr_target = 0      
      nexttarget(self)
    end
  end,
  -- select target for action and pick targets for side s
  select_tgt = function(self,act)
    -- select adequate area tpl and calc it       
    self.wait_target=true
    self:calc_area(self.areas[act])
  end,
  -- get current target
  getcurrtarget = function(self)
    return #self.targets>0 and self.targets[self.curr_target] or nil
  end
},entity)
unit.__index = unit

priest = setmetatable({
  name  = "priest",
  maxlife = 4,
  mgk   = 5,
  attk  = {attack=1,heal=5},
  def   = 1,
  sp    = 108,
  areas = {attack=0,heal=6},
  extopt= {"heal"}  
},unit)
function priest:checkopt(opt)
  if (opt=="heal") return self.mgk>0
end
function priest:doheal(act)
  self.targetcb=self.executeheal
  self:select_friend(act)
end
function priest:executeheal(target,act)  
  self.mgk-=1
  target.life=min(target.maxlife,target.life+4)  
  mapstate:releaseunit()
end

wizard = setmetatable({
  name  = "wizard",
  maxmoves = 2,
  maxlife  = 3,
  mgk   = 4,
  jump  = 1,
  attk  = {attack=2,fireball=4},
  def   = 1,
  sp    = 118,
  areas = {attack=0,fireball=2},
  extopt= {"fireball"}  
},unit)
function wizard:checkopt(opt)
  if (opt=="fireball") return self.mgk>0
end
function wizard:dofireball(act)
  self.targetcb=self.executeattack
  self:select_enemy(act)
end


halberdier = setmetatable({
  name  = "halberdier",
  maxlife = 3,
  pots  = 1,
  jump  = 1,
  attk  = {attack=3},
  def   = 3,
  sp    = 98,
  areas = {attack=1},
  extopt= {}  
},unit)

axeman = setmetatable({
  name  = "axeman",
  maxmoves = 3,
  maxlife  = 5,
  pots  = 1,
  jump  = 1,
  attk  = {attack=4},
  def   = 2,
  sp    = 88,
  areas = {attack=0},
  extopt= {}
},unit)

archer = setmetatable({
  name  = "archer",
  maxmoves = 4,
  maxlife  = 5,
  jump  = 3,
  pots  = 1,
  attk  = {attack=2},
  def   = 2,
  sp    = 78,
  areas = {attack=3},
  extopt= {}  
},unit)


spear_sk = setmetatable({
  name  = "spear skeleton",
  maxlife = 4,
  attk  = {attack=2},
  def   = 1,
  sp    = 8,
  side  = 2,
  areas = {attack=1},
},unit)

sword_sk = setmetatable({
  name  = "sword skeleton",
  maxlife = 4,
  attk  = {attack=2},
  def   = 2,
  sp    = 28,
  side  = 2,
  areas = {attack=0},
},unit)

scyte_sk = setmetatable({
  name  = "scyte skeleton",
  maxmoves = 2,
  maxlife  = 4,
  attk  = {attack=3},
  def   = 1,
  sp    = 18,
  side  = 2,
  areas = {attack=0},
},unit)


priest_sk = setmetatable({
  name  = "skeleton priest",
  maxlife = 4,
  attk  = {attack=1},
  def   = 1,
  sp    = 38,
  side  = 2,
  mgk   = 4,
  extopt= {"mend"},
  areas = {attack=0,mend=6},
},unit)
function priest_sk:checkopt(opt)
  if (opt=="mend") return self.mgk>0
end
function priest_sk:domend(act)
  self.targetcb=self.executemend
  self:select_friend(act)
end
function priest_sk:executemend(target,act)  
  self.mgk-=1
  target.life=min(target.maxlife,target.life+4)  
  mapstate:releaseunit()
end


necromancer = setmetatable({
  name  = "necromancer",
  maxlife = 6,
  attk  = {attack=2,miasma=4},
  def   = 3,
  sp    = 48,
  mgk   = 3,
  side  = 2,
  extopt= {"miasma"},
  areas = {attack=0,miasma=4},
},unit)
function necromancer:checkopt(opt)
  if (opt=="miasma") return self.mgk>0
end
function necromancer:domiasma(act)
  self.targetcb=self.executeattack
  self:select_enemy(act)
end


-- unit types
--------------------------------
units={spear_sk,scyte_sk,
  sword_sk,priest_sk,
  necromancer,archer,axeman,
  halberdier,priest,wizard}

-- extra units
--------------------------------
deer = setmetatable({
  name  = "deer",
  maxlife = 1,
  sp    = 0,
  update = function(self)
    if (game:beat(30) and ceil(rnd(100))<40) self.offset+=16
    self.offset%=32
  end,
  drawat = function(self,highlight)
    if (self.x>-10 and self.x<64 and self.y>-16 and self.y<64) then  
      sspr(self.sp,32+self.offset,12,16,self.x-2,self.y,12,16,self.i>levelmap.width/2 and true or false)
    end
  end,
},unit)

-->8
-- play state
--------------------------------

play=gamestate({
  mapdata="ee6a3069306930690069056900690069003900370056003200320032106a306830690069006900690069006930680035005500320032003200674067006700670467006900690169003800340054003200320032006700370067006700670068006800370037003300322032003200100037006703370037006702670067006703370032003200320032001000670067006700370067006700670067003700320032003200320010003700670067006700670067006700370037003210320032001000100068306800680068006800380037006600360065003500320010001000683068306700360036003600360035006540330032003200100010003510351035003500560056004500440044004100410041001000100044004400440044002600260045005500550032003200320010001000351035203506350036003607350834003200320032003200100010001000100010001000350a35003400330032003200320032001000100010001000100010003400340033093200320010001000100010001000",  
--  mapdata="33320332003200320032003200320032003207"
})

function play:init()
  -- load the map
  self.lv   = levelmap:load(self.mapdata)
  -- initialize map state
 	self.st   = mapstate:init(1,1,true)
 	-- sides inital calc
 	sides:init()
 	-- set the first turn
 	mapstate.turn = turn(side_kingdom)
end

function play:draw()
  -- draw the map and potential statusbar
  statusbar(levelmap:draw(mapstate))  
  if (self.activemenu) self.activemenu:draw()
end

function play:update()
  
  local u = mapstate.activeunit
  local i,j = mapstate.cposi,mapstate.cposj
  
  if self.activemenu then
    self.activemenu:update()
  elseif not u then
    -- not moving a unit
	   if btnp(—) then
	     -- activate unit selected
	     mapstate:activateunit(game:find_bycell(i,j))
	     -- or show side menu
	     local e = game:find_bycell(i,j)
	     if not e or e:isdead() then 
	       self.activemenu=emptycellmenu
  	     emptycellmenu:open()
  	   end
	   else
	     -- move around
	     mapstate:update()      
	   end
	 else
	   -- controlling a unit
    ----------------------------    	  
    -- cancel orders
	   if not u.wait_target and btnp(Ž) then mapstate:resetunit()
    elseif not u.hasmoved then
      if btnp(—) then
        u:endmove()
      else
        u:move()        
      end    
    elseif u.wait_target then
      u:activate_target()
	   end
	 end
end


-->8
-- hud
--------------------------------

-- statusbar
--------------------------------
function statusbar(e)
 if (not e) return
 -- status bar
 rectfill(0,0,63,6,1)
 line(0,7,63,7,0)
 -- print the icon
 sspr(5*(e.side-1),69,5,5,1,1)
 -- print the stats
 -- life:
 print(e.life,10,1,7)
 sspr(0,64,5,5,14,1)
 -- att:
 print(e.attk.attack,21,1,7)
 sspr(5,64,5,5,25,1)
 -- def:
 print(e.def,32,1,7)
 sspr(10,64,5,5,36,1)
 -- mv:
 print(e.maxmoves,43,1,7)
 sspr(20,64,5,5,47,1)
 if (e.pots) then
   -- pot:
   print(e.pots,54,1,7)
   sspr(15,64,5,5,58,1)
 else
   -- mgk:
   print(e.mgk,54,1,7)
   sspr(25,64,5,5,58,1)
 end

 -- def: 
end

function actionmenu(e)
  if (not e) return
  --move
  sspr(0,74,11,11,12,26)
  sspr(20,64,5,5,15,29)
  --attk
  sspr(0,74,11,11,22,26)
  sspr(5,64,5,5,25,29)
  --itm
  sspr(0,74,11,11,32,26)
  sspr(15,64,5,5,35,29)
  --mgk
  sspr(0,74,11,11,42,26)
  sspr(25,64,5,5,45,29)
end

function menubg()
  line(0,20,63,20,0)
  line(0,54,63,54,0)
  rectfill(0,21,63,53,13)
end

local dialogmenu do
  local mt = {
	  -- off, opening, input, closing
	  state= "off",
	  maxh = 32,
	  minh = 2,
	  inc  = 6,
	  acts = {}, -- extra actions
	  upd  = noop,
	  init = noop,
	  onclose=noop,
	  oncancel=noop,
	  onopt=noop,
	  onupdate=false,
	  ondraw=false,
	  nextmenu=false,
	  -- display the menu
	  draw = function(self)
	    if (self.state=="off") return
	    self:drawbg()	    
					if self.state=="input" then
					  if self.ondraw then
					    self:ondraw()
					  else
		      -- display actions
		      local idx,opttxt
		      local y,spc=17,flr((self.maxh-5*#self.opts)/(#self.opts+1))
							 for idx,opttxt in pairs(self.opts) do
							   local l = textsize(opttxt)>>1
	  						 printws(opttxt,31-l,y+spc,self.opt==idx and 7 or 6)
	  						 y+=(5+spc)
							 end
						end
	    end
	  end,
	  drawbg = function(self) 
	    local h = self.h
	    rectfill(0,32-h/2,63,32+h/2,13)
	    line(0,32-h/2,63,32-h/2,0)
	    line(0,32+h/2,63,32+h/2,0)
	  end,
	  -- control input
	  update = function(self)
	    local st,h = self.state,self.h
	    if st=="opening" then
       if h<self.maxh then self.h+=self.inc
	      else self.state="input" end
	    elseif st=="closing" or st=="canceled" then
	      if h>self.minh then 
	        self.h-=self.inc
       else
         game.state.activemenu=nil
         if st=="closing" then self:onclose()
         else self:oncancel() end         
         self.state="off"
         self.opt=1
         if self.nextmenu then
           game.state.activemenu=self.nextmenu
           self.nextmenu:open()
										 self.nextmenu=false
									end
       end
	    elseif st=="input" then
	      if (self.onupdate) then
	        self:onupdate()
	      else
	       -- defaultcontroller
		      if btnp(Ž) then
		        self.state="canceled"
		      elseif btnp(—) then
		        self:onopt(self.opt)
		      else
		        if btnp(”) and self.opt>1 then self.opt-=1
		        elseif btnp(ƒ) and self.opt<#self.opts then self.opt+=1 end
		      end
		     end
	    end
	  end,
	  open = function(self)
	    self:init() 
	    self.state="opening"
	  end,
	  close = function(self)
	    self.state="closing"
	  end,
	  -- constructor
	  __call = function(self,opts)
	    local m = setmetatable({h=self.minh,opts=opts,opt=1},self)
	    self.__index = self
	    return m
	  end
  }
  mt.__index=mt
  dialogmenu=setmetatable({},mt)
end

victory = dialogmenu({""})
victory.ticks=90
function victory:onupdate()
  local _ENV=self
  ticks-=1
  if (ticks==0) then
    ticks=90
    state="closing"
  end
end
function victory:onclose()
  game:set_state(menu)
end


turnmenu = dialogmenu({""})
turnmenu.ticks=90
function turnmenu:onupdate()
  local _ENV=self
  ticks-=1
  if (ticks==0) then
    ticks=90
    state="closing"
  end
end
function turnmenu:onclose()
  -- center on first unit
  mapstate.turn:selectunit()  
end

unitmenu=dialogmenu({})
function unitmenu:init()
  local u = mapstate.activeunit
  local function addopt(opt) add(self.opts,opt) end
  self.opt=1
  self.opts={"attack"}
  self.u = u
  for eopt in all(u.extopt) do
    if (u.checkopt and u:checkopt(eopt)) addopt(eopt)
  end
  if (u.pots~=nil and u.life<u.maxlife) addopt("potion")
  addopt("end turn")
end
function unitmenu:oncancel()
  mapstate:resetunit()
end
function unitmenu:onopt(opt)
  if opt==#self.opts then
    self:close()
    mapstate:releaseunit()
  else
    -- cb execution
    local opttxt = self.opts[opt]
    self.u["do"..opttxt](self.u,opttxt)
    self:close()  
  end
end

emptycellmenu = dialogmenu({"next unit","end turn"})
function emptycellmenu:onopt(opt)
  if opt==1 then
    self.onclose=noop
    self:close()
    mapstate.turn:selectunit()    
  elseif opt==2 then
    self.onclose = function(self)
      mapstate.turn=mapstate.turn:getnext()
    end
    self:close()
  end
end

combatscr=dialogmenu({})
function combatscr:init()
  self.ticks=180
end
function combatscr:onupdate()
  local btnp,_ENV=btnp,self
  ticks-=1
  if ticks==0 or btnp(—) then
    self:close()
  end
end
function combatscr:combat(attacker,defender,act)
  if (not attacker or not defender) return
  game.state.activemenu=combatscr
  self.defender=defender
  self.res,self.attdice,self.defdice=combatresult(act,attacker.attk[act],defender.def)
  self:open()
end
function combatscr:onclose()
  if self.res>0 then
    self.defender.life-=self.res  
    self.defender.life=max(self.defender.life,0)
  end
  mapstate.turn:checkendturn()
end
function combatscr:ondraw()
  printws("att:",2,23,7)
  printws("def:",2,37,7)
  drawdice(20,self.attdice)
  drawdice(34,self.defdice)
end


-->8
-- support functions
--------------------------------

-- game logos handling
--------------------------------
-- they live in mapdata area
--------------------------------
local logos = {
  fantasy={0,0,62,17},
  tactics={0,17,45,9}
}

-- blit a particular logo (or a mask)
function draw_logo(logo,x,y,mc)
  local px,py,ldata=0,0,logos[logo]  
  for py=0,ldata[4]-1 do
    for px=0,ldata[3]-1 do
      local c=mget(ldata[1]+px,ldata[2]+py)
      if (c~=10) pset(px+x,py+y,mc or c)
    end
  end
end

-- cell lists constructs 
--------------------------------

function cell(i,j,m) return {i=i,j=j,m=m or 0} end 

-- dice rolls
--------------------------------
att_dice_lookup={
  attack={"sw","sh","sw"," ","sw","sh"},
  fireball={"fb","fb","fb","fb","fb"," "},
  miasma={"ms","ms","ms","ms","ms"," "},
  }
def_dice_lookup={
  attack={"sw","sh","sw"," ","sw","sh"},
  fireball={" ","sh"," "," ","sh"," "},
  miasma={" "," ","sh","sh"," "," "},
  }
dice_code={
  attack={"sw","sh"},
  fireball={"fb","sh"},
  miasma={"ms","sh"}
}
function rolldice(lookup,num)
  local res = {}
  while num>0 do
    add(res,lookup[ceil(rnd(6))])
    num-=1
  end
  return res
end

-- autox
function drawdice(y,dice)
  local id,d
  local x=21
  for id,d in pairs(dice) do
    sspr(0,74,11,11,x+10*(id-1),y)
    if d=="sw" then
      sspr(11,74,5,5,x+3+10*(id-1),y+3)
    elseif d=="sh" then  
      sspr(11,79,5,5,x+3+10*(id-1),y+3)    
    elseif d=="fb" then  
      sspr(16,74,5,5,x+3+10*(id-1),y+3)    
    elseif d=="ms" then  
      sspr(16,79,5,5,x+3+10*(id-1),y+3)    
    end    
  end
end

function getdicecode(act)
  return dice_code[act][1],dice_code[act][2]
end

-- combat calcs
function combatresult(act,attval,defval)
  local a,d=getdicecode(act)
  local attdice=rolldice(att_dice_lookup[act],attval)
  local defdice=rolldice(def_dice_lookup[act],defval)
  local res=count(attdice,a)-count(defdice,d)
  return res,attdice,defdice
end

-- texts
--------------------------------

function printws(msg,x,y,c)
  print(msg,x+1,y+1,5)
  print(msg,x,y,c)
end

function textsize(txt)
  local idx,len=#txt,0
  while (idx>0) do
    len+= (ord(txt,idx)<128 and 4 or 8)
    idx-=1
  end
  return len
end

-- px9 decompress, string-only
--------------------------------
function px9_sdecomp
(
	x0,y0, -- where to draw to
	src,   -- compressed data
	vget,  -- read fn (x,y)
	vset   -- write fn (x,y,v)
)
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
	-- 22 bits long with the next
	-- bit always aligned to the
	-- lsb of the fractional part
	local cache,cache_bits,i=0,0,1
	local function getval(bits)
		while cache_bits<16 do
			-- cache next 7 bits
			cache|=(((ord(sub(src,i,i))) or 0)&127)>>>16-cache_bits
			cache_bits+=7
			i+=1
		end
		-- clip out the bits we want
		-- and shift to integer bits
		local val=cache<<32-bits>>>16-bits
		-- now shift those bits out
		-- of the cache
		cache=cache>>>bits
		cache_bits-=bits
		return val
	end

	-- get number plus n
	local function gnp(n)
		local bits=0
		repeat
			bits+=1
			local vv=getval(bits)
			n+=vv
		until vv<(1<<bits)-1
		return n
	end

	-- header

	local 
		w,h_1,      -- w,h-1
		eb,el,pr,
		x,y,
		splen,
		predict
		=
		gnp"1",gnp"0",
		gnp"1",{},{},
		0,0,
		0
		--,nil

	for i=1,gnp"1" do
		add(el,getval(eb))
	end
	for y=y0,y0+h_1 do
		for x=x0,x0+w-1 do
			splen-=1

			if(splen<1) then
				splen,predict=gnp"1",not predict
			end

			local a=y>y0 and vget(x,y-1) or 0

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

			local v=l[predict and 1 or gnp"2"]

			-- update predictions
			vlist_val(l, v)
			vlist_val(el, v)

			-- set
			vset(x,y,v)

			-- advance
			x+=1
			y+=x\w
			x%=w
		end
	end
end
-->8
-- ai for the other side
--------------------------------
aimodes = {
 "closest","strongest","weakest","support","escape"
}

-- find the right target set
-- returns a list of ordered targets
-- prioritizes:
--   + unit can be attacked in this turn
--   + unit matches mode criteria
function findtargets(e,mode)
  local unitlist = sides[mapstate.turn.nextside].unitlist
  local targetlist={}
  for u in all(unitlist) do
    local score = 0
    if (targetinrange(e,u)) score+=2
    if (targetmatches(u,mode,unitlist)) score+=1    
  end  
end

function applymode(e,mode,target)

end
__gfx__
00000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
00000000aaaaaaaa0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0aaaaaaaaaaaaaaaaaaaaaaaaaaa
00700700aaaaaaa060aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0600aaaaaaaaaaaaaaaaaaaaaa0aa
00077000aaaaaaa060aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00a00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa06d670aaaaaaaaaaaaaaaaaaaa020a
00077000aaaaaaa565aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0660660aaaaaaaaaaaaaaaaaaaaaaaaaa00aaaaaaaaaaaaaaa0d570aaaaaaaaaaaaaaaaaaa08720
00700700aaaaaaa020aaaaaaaaaaaaaaaaaaaaaaaaa0a000aa060060aaaaaaaaaaaaaaaaaaaaaaaaaa040aaaa00aaaa0aaa060700aaaaaaaaaaaaaaaaaa08620
00000000aaa0000040aaa0000aaaaaa0000a0aaaa00901c1aa0700d0aaaaaaaaaaaaaaaaaaaaaaaa000040aaa070aa070aa0900d50aaaa00000aaaaa00009890
00000000aa0fff6040aa0fff60aaaa0fff6070aa09994cfcaa077760aaaaaaaaaaaaaaaaaaaaaaa03311040aaa0700070aa04066d0aaa0444420aaa088820950
00000000aa0f8f8040aa0f8f80aaaa0f8f8070aa0f8f81c1aa0f8f80aaaaaaaaaaaaaaaaaaaaaaaa037f740aaaa066d0aaa0407f70aaaa047f70aaaa087f790a
00000000aaa0f65040aaa0f65000aaa0f65070aaa0f65090aaa0f6500aaaaaaaaaaaaaaaaaaaaaaa03fff040aa047f70aaa040fff000aa04fff0aaaa0866d60a
00000000aa0f550040a00f550044000f550070aa0f550070aa0f553b10aaaaaaaaaaaaaaaaaaaaa0333129f0a0d69940aaa040550760a0444220aaa08966d60a
00000000a0f0d0d0400ff0d044d72440d0d499a0f0d0d070a0f0dfb730aaaaaaaaaaaaaaaaaaaaa033820040a06d6940aa0d40d657d0042444220aa08296960a
000000000f00600660f0044f006726406006600f009406600f04400310aaaaaaaaaaaaaaaaaaaa03399f00400f0006d0aa06f06707d0046222240a0808292f0a
000000000f0f0600404446060067224006000a0f0f8200704f4fc1000aaaaaaaaaaaaaaaaaaaaa033821040a4f4444f40aa0406706506f66422f0a0f0822260a
00000000a0f0a060400060a060670000a060aaa0f082600a00f0c160aaaaaaaaaaaaaaaaaaaaaa03ddd1040a00d000670aa04000d00a00642220aaa08882260a
00000000a0f0a06040a0f0a00770a0f0a060aaa0f82060aaa0fc1060aaaaaaaaaaaaaaaaaaaaaa0311d040aaa02077770aa040a040aaa0444220aaa08882260a
00000000aaaaaaaa0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0aaaaaaaaaaaaaaaaaaaaaaaa0aa
00000000aaaaaaa060aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0600aaaaaaaaaaaaaaaaaaaaa080a
00000000aaaaaaa060aaaaaaaaaaaaaaaaaaaaaaaaaaa000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa06d670aaaaaaaaaaaaaaaaaaa08720
00000000aaaaaaa565aaaaaaaaaaaaaaaaaaaaaaaaaa01c1aa00a00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0d570aaaaaaaaaaaaaaaaaaa08620
00000000aaaaaaa020aaaaaaaaaaaaaaaaaa0aaaaaaa0c7ca0660660aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa06070aaaaaaaaaaaaaaaaaaa09890
00000000aaaaaaa040aaaaaaaaaaaaaaaaa070aaaaa001c1aa060060aaaaaaaaaaaaaaaaaaaaaaaaaa000aaaa00aaaa0aaa090000aaaaaaaaaaaaaaaaaaa090a
00000000aaa0000040aaa0000aaaaaa0000070aaa0090090aa0700d0aaaaaaaaaaaaaaaaaaaaaaaa000440aaa070aa070aa040dd50aaaa00000aaaaa0000060a
00000000aa0fff6040aa0fff60aaaa0fff6070aa09994070aa077760aaaaaaaaaaaaaaaaaaaaaaa03311140aaa0700070aa04066d0aaa0444420aaa08882260a
00000000aa0f8f8040aa0f8f8000aa0f8f8070a00f8f8070aa0f8f80aaaaaaaaaaaaaaaaaaaaaaaa037f7040aaa066d0aaa0407f70aaaa047f70aaaa087f760a
00000000aaa0f65040aaa0f650440000f654990f00f65070aa00f650aaaaaaaaaaaaaaaaaaaaaaaa03fff040aa047f70aaa040fff000aa046ff0a0aa0866d60a
00000000aa0f5d0040aa0f55f4d72440550060a0ff550060a0ff550000aaaaaaaaaaaaaaaaaaaaa0333129f0a0d69940aaa040550760a02666200fa08966df0a
00000000a0f0d0d660a0f04460672640d0d600aa00d0d6700f00d0d3b1aaaaaaaaaaaaaaaaaaaa0338820040a06d00f40a0df0d657d00444f4224fa08296960a
000000000f006000400f44600067224060000aaaa094000a4f444f4b73aaaaaaaaaaaaaaaaaaaa039f820040a0f044670aa0406707d00022622000080829260a
000000000f0f0600404f0f060067000f060aaaaa0f8200aa000fc10131aaaaaaaaaaaaaaaaaaaa038880040aa04f00770aa040670650a0444220aa0f0822260a
00000000a0f0a0604000f0a00770a0f0a060aaa0f08260aaa0f0c16000aaaaaaaaaaaaaaaaaaaa03dd0440aaa4d007600aa04000d00aa0444220aaa0888220aa
00000000a0f0a0600aa0f0a0600aa0f0a060aaa0f82060aaa0fc1060aaaaaaaaaaaaaaaaaaaaaa0311d10aaaa0200200aaaa00a040aaa0442220aaa0888220aa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a00aaa00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
0770a0770aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a0770770aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a0700070aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aa044470aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a0455440aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aa04440aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aa0ff44000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa00444440aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa0f4444440aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa0ff44440aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa04f4ff40aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa04040240aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa04040240aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa05050550aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaa000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
00a04440aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
7704477400aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
07747744440aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
070007444440aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a0444704440aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
0455440ff40aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a0444040240aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a0ff0040240aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aa005050550aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
88a88aaa77666dda994aff6aaacaaa0000000f0000f0000f00000000fff00fff0a9aaaa333aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000aaaa
878889a76d67e6da686a442aac6cab00f0000f000fff00f0f00fff0f0f0ffffffa8a9a3bbb3aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0fff600aa
8e888976da6ee8d67e864222aacaea0f0f0ff0ffff0fff000f0f0f0ff0fffffff898993ababaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0f5f50f0a
a8e8aacdaa6786d7e88604442aae8e00f0000f000fff00f0f00fff0f0f0ffffff8899813bbbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa060f660f0a
aa8aa4a99aa68daa776aa00009aaea0000000f0000f0000f00000000fff00fff0a888aa133aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0ff550f5f0
94949aff6aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
999c9ffff6aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
6f7f7ff8f8aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
6f666dffd6aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaf66ad66aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
000000000001117717111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
099999999407177616171aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
091111111207776167677aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
091111111201661166776aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
091111111206166116661aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
091111111207766617771aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
091111111207777677777aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
091111111207777671717aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
091111111207777667776aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
042222222201776116661aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
00000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaa7aaaaaaaaaaaa7aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
7a7aaa77a777aaa777a7aaa77a7a7aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a7aaaa7aa7a7aaa7a7a7aa7a7a7a7aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
7a7aaaa7a777aaa777aa7a777a777aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaa7aaaaaaaaaaaa7aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaa22aaaaaaaaaaaaaa55aaaaaaaaaaaaaa11aaaaaaaaaaaaaa11aaaaaaaaaaaaaa44aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaacccc8ee8ccccc1111ccc
aaaaa226622aaaaaaaaaa556d55aaaaaaaaaa11b311aaaaaaaaaa11cc11aaaaaaaaaa449944aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaccc8efef8ccc1bb331cc
aaa2266666622aaaaaa55ddd66d55aaaaaa1133bbb311aaaaaa11cccccc11aaaaaa4499fff944aaaaaaaaaaaaaaaaaaaaaaaaa000aaacc8ef7fee8c1ab3bb31c
a22666666666622aa55666d6666dd55aa1133bb3bbbb311aa11cccc6c66cc11aa4499ff9ff9f944aaaaaaaaaaaaaa1aaaaaaa05d50aac8ef7f77fec1baaaab1c
26666666666666625dd66dddd6d666d513bbbbbb33b3b3311cc6c66ccccc6cc149fff99ffff9f994aaaaaaaaaaaa161aaaaa05d6d5aa8eeef77fe8c13baaaa3c
522666666666622d555dd6666dd6655d41133bb3bbbb3119111ccccc66ccc11c9449fff99f9f944faaaaaaaaaaa167c1aaaa5dd66daaeff8eefe8c13b33ab31c
a552266666622ddaa5555d66d6d55ddaa441133bb331199aa1111c6cccc11ccaa99449ff99f44ffaaaaaaaaaaaa176d1aaaa556d5d0a8e7fefe8881baabb31cc
aaa55226622ddaaaaaa5555dd55ddaaaaaa4411331199aaaaaa1111cc11ccaaaaaa99449944ffaaaaaaaaaaaaaa17cd1aaaa566dd65ac8ee88ef8c13b3bab31c
aaaaa5522ddaaaaaaaaaa5555ddaaaaaaaaaa441199aaaaaaaaaa1111ccaaaaaaaaaa9944ffaaaaaaaaaaaaa11117cd1aaa056d6665a8fe7efeef8c13baaab31
aaaaaaa5daaaaaaaaaaaaaa5daaaaaaaaaaaaaa49aaaaaaaaaaaaaa1caaaaaaaaaaaaaa9faaaaaaaaaaaaaaa16d16cd1aaa5dd6665da8e7f7e867e1ba3bab3b1
aaaaaaa00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1d516cd11105d56d56dac88ef86ee813b53b3b31
aaaaa001500aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa15166d17c5d5ddd655accc886e88cc11b54b31c
aaa0055111500aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa77116c176c555d5d5d65ccc1578cccccc15411cc
a00511115111500aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa67c16c16c15d65dd566dccc1d61ccccccc54cccc
05115111155111505aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa16cc116cd1566655d6d5cc1d671ccccccc544ccc
200511555111500daaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa16cc1cd1a5dd6655d551d665671cccc3545344c
a220011111500ddaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa22005500ddaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaa2200ddaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaa2daaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaa00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaa002200aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa0022882200aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a00228888882200aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
0228888ee8888220aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a00228888882200aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa0022882200aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaa002200aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaa00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
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
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 41 42 43 44
00 41 42 43 44
