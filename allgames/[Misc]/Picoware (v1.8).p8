pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- picoware
-- the picoware team

_btnp,btnps=btnp,{}
function btnp(bt)
if(_btnp(bt))sfx(kenable and 27 or 0)
return _btnp(bt)end
function btnpp(bt)local pressed
if not btnps[bt]and btn(bt)then sfx(kenable and 27 or 0)pressed=true end btnps[bt]=btn(bt)return pressed end

function _sort(t,c)local s={}for k, e in pairs(t)do if #s==0 then add(s,e)else local n=1 for i=1,#s do if not c(e,s[i])then break end n+=1 end for i=#s,n,-1 do s[i+1]=s[i]end s[n]=e end end return s end

function _init()
 _kpatt={}
 
 cartdata("picoware_picoware")
 
 _sorted_states=_sort(_states, function(l, r)
  local lz=l.settings.z_index or 0
  local rz=r.settings.z_index or 0
  
  return lz>rz
 end)
  
 _get_subcart_data()
 _load_savedata()

 if _breadcrumb==nil then  
  _set_state(_states.disclaimer, false, true)
  _reset_transition(_transitions.instructions, -9)
 elseif _breadcrumb=="subcart_finish" then
  _set_state(_states.final_cutscene, false, true)
 elseif _breadcrumb=="subcart_cancel" then
  daisy_chain_after_return()
 end  

 _reset_transition(_transitions.camera_x, __state.position.x) 
 _reset_transition(_transitions.camera_y, __state.position.y-128)

 _set_transition_target(_transitions.camera_x, __state.position.x) 
 _set_transition_target(_transitions.camera_y, __state.position.y)
end

function _update60()
 for i=0,6 do
  -- ...not secret stuff Œ
  if (_btnp(i)) k_c(i)
 end
 
 foreach(_coroutines, function(co)
  coresume(co)
  if (costatus(co)=="dead") del(_coroutines, co)
 end)

 for name, tr in pairs(_transitions) do
  if tr.target then
   tr.t=min(tr.t+1/60, tr.time)
   
   tr.value=mix(
    tr.old_target,
    tr.target,
    ss(0,tr.time, tr.t)
   )
   
   tr.finished=tr.t==tr.time
  end
 end
   
 if __state.gui and __state.settings.menuitem_count then
  local horizontal = __state.settings.horizontal
  
  if (btnp(”) and not horizontal)
  or (btnp(‹) and horizontal) then
   __state.menuitem_id-=1
   new_selected="nav"
  
   if __state.menuitem_id==0 then
    __state.menuitem_id=__state.settings.menuitem_count
   end
  end

  if (btnp(ƒ) and not horizontal)
  or (btnp(‘) and horizontal) then
   __state.menuitem_id+=1
   new_selected="nav"
  
   if __state.menuitem_id > __state.settings.menuitem_count then
    __state.menuitem_id=1
   end
  end
 end

 if btnpp(—) and not __state.settings.blocking then
  _state_pop()
 end
 
 for i, state in pairs(_sorted_states) do
  if state.update and (state==__state or state.settings.show_always) then
   _state=state
   state.update(state==__state)
  end
 end 
end

function _shadow(str, x, y, col)
 if not kenable then
 for xx=-1,1 do for yy=-1,1 do
  if (xx*yy==0) print(str, x+xx, y+yy, 7)
 end end
 end
 print(str, x, y, col or 0)
end

function rs(s,x,y,c)
 local sc=({[7]=12,[8]=2,[9]=4,[10]=4,[11]=3,[12]=1,[13]=1,[14]=2,[15]=5})[c]
 if(not kenable)print(s,x,y+1,sc)
 print(s,x,y,c)
end

function _draw()
 camera() cls()
 if(kenable) cls(7)

 for i, state in pairs(_sorted_states) do
  if state.draw and (state==__state or state.settings.show_always) then
   _state=state
   
   local old_clip
   clip,old_clip=function(x,y,w,h)
    if x==nil then
     old_clip()
    else
     old_clip(
      -flr(_transitions.camera_x.value)+state.position.x+x,
      -flr(_transitions.camera_y.value)+state.position.y+y,
      w, h
     )
    end
   end,clip

   camera(
    _transitions.camera_x.value - state.position.x,
    _transitions.camera_y.value - state.position.y
   )
   
   state.draw(state==__state)
   
   clip,old_clip=old_clip,clip
  end
 end
 
 camera()
 
 local _instr="Ž select   — back"
 camera(0,_transitions.instructions.value)
 rectfill(0,119,128,128,kenable and 13 or 9)
 print(_instr, 64-_len(_instr)*2, 121, kenable and 1 or 0)

 if(kenable and t()-kt<.7) for i=0,0x1fff do poke(0x6000+i,rnd(0x100)) end
 camera() 
end

function _len(str)
 local len=#str
 
 for i=1,#str do
  if(sub(str,i,i)>="€") len+=1
 end
 
 return len
end

function _printc(str, ...)
 local y=peek(0x5f27)+6
 print(str, 64-_len(str)*2, y, ...)
 poke(0x5f27, y)
end

function _timeout(func, t)
 t+=time()

 local co= cocreate(function()
  repeat yield() until time() > t
  func()
 end)
 
 add(_coroutines, co)
 return co
end

function _stop_timeout(timeout)
 del(_coroutines, timeout)
end

function _start_gui()
 _state.gui={}
end

function _draw_gui()
 if _transitions.selected_w.value > 0 then 
  local x=_transitions.selected_x.value-2
  local y=_transitions.selected_y.value-2
  local w=_transitions.selected_w.value+2
  
  rectfill(x+1, y+1, x+1+w, y+1+8, kenable and 9 or 8)
  rectfill(x, y, x+w, y+8, kenable and 8 or 7)
 end

 for func in all(_state.gui) do
  func()
 end
end

function _menuitem(str, x, y, id, col)
 local selected = _state.menuitem_id == id
 local w=_len(str)*4

 if selected and new_selected then
  if new_selected=="skip" then
   _reset_transition(_transitions.selected_x,x-w/2)
   _reset_transition(_transitions.selected_y,y)
   _reset_transition(_transitions.selected_w,w)
  else
   _set_transition_target(_transitions.selected_x, x-w/2)
   _set_transition_target(_transitions.selected_y, y)
   _set_transition_target(_transitions.selected_w, w)
  end
  
  new_selected=false
 end

 add(_state.gui, function()
  _shadow(str, x-w/2, y, col or 0)
 end)
 
 return selected and btnpp(Ž)
end

function _set_state(state, playernav, dontpush)
 if __state and __state.exit then
  __state.exit()
 end
 
 if _statestack==nil then
  _statestack={}
 end

 if not dontpush then
  add(_statestack, __state)
 end 

 __state=state
 
 if playernav then
  if playernav=="final" then
   sfx(kenable and 22 or 3)
  elseif playernav=="back" then
   sfx(kenable and 24 or 4)
  else
   sfx(kenable and 23 or 1)
  end
 end
 
 if __state.menuitem_id == nil then
  __state.menuitem_id=1
 end
  
 if __state.enter then
  __state.enter()
 end

 if _transitions.camera_x.target ~= state.position.x
 or _transitions.camera_y.target ~= state.position.y then
  _set_transition_target(_transitions.camera_x, __state.position.x)
  _set_transition_target(_transitions.camera_y, __state.position.y)
 end

 if __state.settings.menuitem_count~=nil then
  new_selected="skip"
 end
end

function _state_pop()
 local state=_statestack[#_statestack]
 _statestack[#_statestack]=nil
 
 if state~=nil then
  return _set_state(state, "back", true)
 end
end

function _set_menuitem_id(id)
 __state.menuitem_id=id
end

function _set_transition_target(transition, new_target)
 transition.t=0
 transition.old_target=transition.value 
 transition.target=new_target 
end

function _reset_transition(transition, value)
 _set_transition_target(transition, value)
 transition.t=transition.time
 transition.value=transition.target
end

function _draw_picoware_logo(x, y)
 sspr(77, 123, 51, 5,
 kenable and x-8*sin(t()) or x,
 kenable and y+4*sin(t()) or y,
 kenable and 102+16*sin(t()) or 102,
 kenable and 12-8*sin(t()) or 10)
end

_coroutines={}

_transitions={
 camera_x={ value=   0, time=0.45 },
 camera_y={ value=-128, time=0.45 },

 selected_x={ value=64, time=0.2 },
 selected_y={ value=96, time=0.2 },
 selected_w={ value= 0, time=0.2 },
 
 cart_view={ value=1, time=0.2 },
 
 instructions={ value=0, time=0.3 },

 spinner={ value=1, time=0.2 },
}

_states={
 disclaimer={
  settings={},
  
  enter=function()
   if l_disclaimer() then
    _states.disclaimer.hide_and_go()
   end
  end,
  
  update=function()
   if (_states.disclaimer._hide) return

   if btn() > 0 then
    _states.disclaimer.hide_and_go()
   end
  end,
  
  hide_and_go=function()
   s_disclaimer(true)
   _states.disclaimer._hide=true
   _timeout(function()
    _set_state(_states.title, false, true)
   end, 1)
  end,
  
  draw=function()
   if (_states.disclaimer._hide) return
   
   cursor(0,1)
   
   color(8)
   _printc "disclaimer:"
   _printc ""
   
   color(7)
   _printc "this game was made during (and"
   _printc "after) the picoware gamejam."
   _printc ""
   _printc "what you'll experience is"
   _printc "a combined work of 50+ people."
   _printc ""
   _printc "if you like this game,"
   _printc "spread the word!"
   _printc ""
   _printc "if you don't,"
   _printc "let us know why!"
   _printc ""
   
   color(9)
   _printc "also, ! epilepsy warning !"
   _printc "possible epilepsy triggers."
   _printc ""
   _printc ""
   
   fillp(rotl(0x6666.6666,time()*10))
   line(0,108,128,108,6)
   
   color(10)
   _printc "press any key to continue"
  end,
  
  position={ x=0, y=-128 }
 },
 
 title_bg={
  settings={
   show_always=true,
  },
  
  update=function()
   if not _states.title_bg._init then
    _states.title_bg._init=true
    tinit()
   end
   
   tupdate()
  end,
  
  draw=function()
   if(kenable) clip(0,0,128,108)
   tdraw()
   if(kenable) clip()
   for i=1,16 do pal(i,kenable and 9 or 1) end
   fillp(0x5a5a+0.5)
   _draw_picoware_logo(12,38)
   
   pal()
   if(kenable) for i=1,16 do pal(i,8) end
   fillp()
   _draw_picoware_logo(10,36)
   pal()
  end,
  
  position={ x=0, y=0 }
 },
 
 title={
  settings={},
  
  enter=function()
   _transitions.camera_x.time=2
   _transitions.camera_y.time=2
  
   _timeout(function()
    _set_state(_states.title_prompt, false, true)
    new_selected="nav"
   end, _transitions.camera_y.time+0.5)
   
   sfx(8)
  end,
  
  exit=function()
   _transitions.camera_x.time=0.45
   _transitions.camera_y.time=0.45
  end,

      
  position={ x=0, y=0 }
 },

 title_prompt={
  settings={
   menuitem_count=1,
  },
  
  exit=function()
   _set_transition_target(_transitions.instructions, 0)
  end,
  
  update=function()
   _start_gui()

   if _menuitem("press Ž/z", 64, 88, 1) then    
    return _set_state(_states.main_menu, true, true)
   end
  end,
  
  draw=function()
   _draw_gui()
  end,
  
  position={ x=0, y=0 }
 },

 main_menu={
  settings={
   menuitem_count=3,
  },
  
  update=function()   
   _start_gui()
   
   if _menuitem("play", 64, 76, 1) then
    return _set_state(_states.select_mode, true)
   end
   
   if _menuitem("settings", 64, 88, 2) then
    return _set_state(_states.settings, true)
   end
   
   if _menuitem("credits", 64, 100, 3) then
    return _set_state(_states.credits, "final")
   end
  end,
  
  draw=function()   
   _draw_gui()
  end,
  
  position={ x=0, y=0 }
 },

 settings={
  settings={
   menuitem_count=3,
  },
  
  update=function()   
   local self=_states.settings
   
   _start_gui()

   if _menuitem("set base difficulty", 64, 76, 1) then
    return _set_state(_states.set_difficulty, true)
   end
   
   local skip=l_cutscenes()
   local _s=(skip and "" or "don't ").."skip cutscenes!"

   if _menuitem(_s, 64, 88, 2) then
    s_cutscenes(not skip)
    sfx(kenable and 22 or 3)
    new_selected="nav"
   end

   if _menuitem("reset progress", 64, 100, 3) then
    return _set_state(_states.reset_progress, true)
   end   
  end,
  
  draw=function()
   _draw_gui()
  end,
  
  position={ x=0, y=0 }
 }, 
 
 reset_progress={
  settings={
   horizontal=true,
   menuitem_count=2,
  },
  
  update=function()   
   _start_gui()
   
   if _menuitem("no!!", 48, 86, 1) then
    _state_pop()
   end
   
   if _menuitem("yes.", 80, 86, 2) then
    clear_progress()
    
    extcmd "reset"
   end
  end,
  
  draw=function()
   local s1="are you sure you want to"
   local s2="delete all your progress?"
   local s3="you've worked so hard"
   local s4="on making it this far..."
   
   _shadow(s1, 64-#s1*2, 34)
   _shadow(s2, 64-#s2*2, 44)
   _shadow(s3, 64-#s3*2, 54)
   _shadow(s4, 64-#s4*2, 64)
   
   _draw_gui()
  end,
  
  position={ x=0, y=72 }
 }, 

 set_difficulty={
  settings={},
  
  _names={"calm and collected","chilled out","feelin' relaxed","pickin' up speed","brisk and bold","deft determination","greased lightning!","rip-roarin'!","full tilt!","breakneck speed!","maniac momentum!","supersonic!","light speed!","ridiculous speed!!","ludicrous speed!!!"},
  
  enter=function()
   local self=_states.set_difficulty
   
   self._difficulty=l_diff()
   _reset_transition(_transitions.spinner, self._difficulty)      
  end,
  
  update=function()
   local self=_states.set_difficulty
   
   if btnp(”) then
    self._difficulty-=1
    
    if self._difficulty<1 then
     self._difficulty=15
    end
    
    s_diff(self._difficulty)
    _set_transition_target(_transitions.spinner, self._difficulty)
   end

   if btnp(ƒ) then
    self._difficulty+=1
    
    if self._difficulty>15 then
     self._difficulty=1
    end
    
    s_diff(self._difficulty)
    _set_transition_target(_transitions.spinner, self._difficulty)
   end

   if btnpp(Ž) then
    _state_pop()
   end
  end,
  
  draw=function()
   local s1="difficulty:"
   _shadow(s1, 65-#s1*2, 45)
   
   rectfill(12,64,116,73,kenable and 9 or 8)
   rectfill(12,64,116,72,kenable and 8 or 7)
   rect(12,56,116,80,kenable and 8 or 7)

   clip(13,57,102,23)
   
   for i, name in pairs(_states.set_difficulty._names) do
    local _s=name
    _shadow(_s, 64-#_s*2, 66+10*(i-_transitions.spinner.value))
   end
      
   clip()
  end,
  
  position={ x=0, y=72 }
 }, 

 select_mode={
  settings={
   menuitem_count=3,
  },

  enter=function()
   local self=_states.select_mode

   local modes={
    "story",
    "infinity",
    "single"
   }
   
   for i, str in pairs(modes) do
    if str==_mode then
     self.menuitem_id=i
    end
   end
   
   self.settings.show_always=false
  end,
    
  update=function(current)
   if (not current) return
  
   local lambada=function(mode)
    _states.select_mode.settings.show_always=true
    _mode=mode
    return _set_state(_states.cart_view, true)
   end
   
   _start_gui()
   
   if _menuitem("story mode", 64, 76, 1) then
    lambada("story")
   end

   if _menuitem("infinity mode", 64, 88, 2) then
    lambada("infinity")
   end

   if _menuitem("single mode", 64, 100, 3) then
    lambada("single")
   end
  end,
  
  draw=function()   
   _draw_gui()
  end,
  
  position={ x=0, y=0 }
 },

 cart_view={
  settings={
   show_always=true
  },
  
  _cart_id=1,
  
  update=function(current)
   if (not current) return
   
   local self=_states.cart_view
   
   if btnp(‹) and self._cart_id > 1 then
    self._cart_id-=1

    _set_transition_target(
     _transitions.cart_view,
     self._cart_id
    )
   end
   
   if btnp(‘) and self._cart_id < #_carts then
    self._cart_id+=1

    _set_transition_target(
     _transitions.cart_view,
     self._cart_id
    )
   end
 
   if btnp(ƒ) then
    if _mode=="story" then
     _mode="infinity"
    elseif _mode=="infinity" then
     _mode="single"
    elseif _mode=="single" then
     _mode="story"
    end
   end
   
   if btnp(”) then
    if _mode=="story" then
     _mode="single"
    elseif _mode=="infinity" then
     _mode="story"
    elseif _mode=="single" then
     _mode="infinity"
    end
   end
    
   if btnpp(Ž) then
    if _mode=="single" then
     if kenable or self._cart_id <= _progress then
      return _set_state(_states.minigame_list, true)
     end
    elseif (_mode=="story" and (kenable or self._cart_id <= _progress))
    or (_mode=="infinity" and (kenable or self._cart_id < _progress)) then
     _selected_id=self._cart_id
     _set_state(_states.cutscene, "final")
     return
    end
   end
  end,
  
  draw=function()   
   clip(0,0,128,128)
   
   local _sl="locked!"
   local guard=_progress - (_mode=="infinity" and 1 or 0)
      
   for i, cart in pairs(_carts) do
    local x=(i-_transitions.cart_view.value)*40

    if i>guard then
     rect(64-16+x,64-16,64+16+x,64+24,cart.fg)
     print(_sl,64+x-#_sl*2+2,64,cart.bg)
    else
     rect(64-16+x,64-16,64+16+x+1,64+24+1,cart.bg)
     rectfill(64-16+x,64-16,64+16+x,64+24,cart.fg)
     rect(64-14+x,64-14,64+14+x,64+14,7)
     rectfill(64-13+x,64-13,64+13+x,64+13,0)
     sspr(cart.sspr.x,cart.sspr.y,27,27,64-13+x,64-13)
    end
   end
   
   -- masking
   local philips={
    { pattern=0x5a5a, width=40 },
    { pattern=0x8412, width=4 },
   }
   -- philips? because fill-p?
   -- get it? heh? heheheh Œ
   
   local w=20

   if(kenable) pal()
   for phil in all(philips) do
    fillp(phil.pattern+0.5)
    rectfill(64+w,0,64+w+phil.width,128,kenable and 7 or 0)
    rectfill(64-w,0,64-w-phil.width,128,kenable and 7 or 0)
    w+=phil.width
   end
   
   fillp()

   local cart=_carts[_states.cart_view._cart_id]

   rectfill(0,34,128,42,cart.fg)
   
   for i=0,12 do
    line(0,34+i,12,34+i-12,kenable and 7 or 0)
    line(125-i,34+12,125+12-i,34,kenable and 7 or 0)
   end
   print(cart.name,64-#cart.name*2,36,0)

   local _ss=""
   
   local i=_states.cart_view._cart_id
   
   if _mode=="infinity" and i<_progress then
    _ss="highscore: "..sp(cart.score)
   elseif i>guard then
    if _mode=="story" then
     _ss="beat previous stage to unlock!"
    else
     _ss="beat in story mode to unlock!"
    end
   end

   rs(_ss,65-#_ss*2,97,cart.fg)
   
   local _s1=(_mode or "").." mode"
   
   _shadow(_s1,64-#_s1*2,15)

   -- arrows 
   if(kenable) pal(7,8) pal(13,9)  
   spr(34,60, 8)
   spr(35,60,24)
   if(kenable) pal()
   
   clip()
  end,
  
  position={ x=128, y=0 }
 },
 
 score_screen={
  settings={},
  
  enter=function()
   local self=_states.score_screen
   self.settings.show_always=true
   
   local _won=(_mode=="story" and _score==1)
   local _ss={}
   
   local _s1
   
   if _mode=="story" then
    _s1=_won and "stage clear!" or "stage failed!"
   else
    _s1="game over!"
   end
   
   add(_ss, { s=_s1, c=(_won and 11 or 8) })
   add(_ss, {})
   add(_ss, {})
      
   if _mode=="story" and _progressed then
    add(_ss, { s="you can now play this stage", c=7 })
    add(_ss, { s="in infinity mode!", c=7 })
    
    if _selected_id<6 then
     add(_ss, {})
     add(_ss, { s="new story mode stage", c=11 })
     add(_ss, { s="unlocked!", c=11 })
    end
   end
   
   if _mode~="story" then
    add(_ss, { s="final score:", c=7 })
    add(_ss, {})
    add(_ss, { s=sp(_score), c=10 })
    add(_ss, {})
    
    if _progressed then
     add(_ss, { s="new highscore!", c=11 })
    end
   end
   
   if kenable then
    sfx((_progressed or (_mode=="story" and _won)) and 22 or 23)
   else
    sfx((_progressed or (_mode=="story" and _won)) and 5 or 6)
   end
   
   self._ss=_ss
   
   d={i=rnd()<0.01,a=1,b=64,c=.4,d=.8,e={}}
  end,
  
  update=function(current)
   if (not current) return
   
   if btnpp(Ž) then
    sfx(kenable and 22 or 3)

    if _mode=="story" and _progressed and _selected_id==6 then
     _set_state(_states.main_menu, nil, true)
     _set_state(_states.credits)
    else
     daisy_chain_after_return()
    end
   end   
  end,
  
  draw=function()
   local _ms=_mode.." mode"
   
   _shadow(_ms, 64-#_ms*2, 24)
   
   local h=40
   
   for i, str in pairs(_states.score_screen._ss) do
    local s=str.s or ""
    local l=#s
    rs(s, 64-l*2, h, str.c)
    h+=6
   end
   -- dope
   if d.i then
    d.b+=d.c
    d.a+=d.d
    
    d.a=-16+(d.a+16)%144
    d.b=-16+(d.b+16)%144
    
    if(rnd()<.02)add(d.e,{a=238+flr(rnd(2)),b=d.b,c=d.a})
    
    foreach(d.e, function(s)
     s.c+=rnd(2)-1
     s.b-=.4
     if (s.b<-8) del(d.e,s)
     spr(s.a,s.c,s.b)
    end)

    spr(236+flr((time()*4)%2),d.a,d.b,1,1,d.d<0)
   end
  end,
  
  position={ x=128, y=-128 },
 },
 
 final_cutscene={
  settings={},
  
  enter=function()
   if(not(_mode=="story" and _score==1)) _set_state(_states.score_screen, nil,true) return
   _c.set_scene(_cs[_selected_id])
   _states.final_cutscene.settings.show_always=true
  end,
  
  update=function(current)
   if (not current) return
   
   _c.t=600
   if btnpp(Ž) then
    _set_state(_states.score_screen, "final", true)
   end
  end,
  
  draw=function()
   _c.es()
  end,
  
  position={ x=128, y=-256 },
 },
 
 minigame_list={
  settings={z_index=1},

  enter=function()
   local self=_states.minigame_list
   self._cart_id=_states.cart_view._cart_id
   
   self._minigames=_filter_mgs(self._cart_id)
   self.settings.menuitem_count=#self._minigames

   self.menuitem_id=1
     
   if self._minigame then
    for i, minigame in pairs(self._minigames) do
     if minigame==self._minigame then
      self.menuitem_id=i
      break
     end
    end
   end
   
   self._minigame=nil
   
   _reset_transition(_transitions.spinner, self.menuitem_id)
  end,
    
  update=function(current)
   local self=_states.minigame_list
   
   if btnp(”) then
    self.menuitem_id-=1
    
    if self.menuitem_id<1 then
     self.menuitem_id=#self._minigames
    end
    
    _set_transition_target(_transitions.spinner, self.menuitem_id)
   end

   if btnp(ƒ) then
    self.menuitem_id+=1
    
    if self.menuitem_id>#self._minigames then
     self.menuitem_id=1
    end
    
    _set_transition_target(_transitions.spinner, self.menuitem_id)
   end
   
   if btnpp(Ž) then
    _selected_id=self._minigames[self.menuitem_id].id
    _set_state(_states.cutscene, "final")
   end
  end,
  
  draw=function()
   local self=_states.minigame_list

   -- simulated spinner gui
   rectfill(12,79,116,87,kenable and 9 or 8)
   rectfill(12,79,116,87,kenable and 8 or 7)
   rect(12,71,116,95,kenable and 8 or 7)

   clip(13,72,102,23)
   
   for i, minigame in pairs(self._minigames) do
    local _s1=minigame.name
    _shadow(_s1, 64-#_s1*2, 81+10*(i-_transitions.spinner.value))
   end
      
   clip()
   
   local minigame=self._minigames[self.menuitem_id]
   
   local _ss="highscore: " .. sp(minigame.score)
   rs(_ss,64+1-#_ss*2,102,_carts[self._cart_id].fg)
  end,
  
  position={ x=128, y=28 }
 },

 cutscene={
  settings={
   show_always=true
  },
  
  enter=function()
   
   local self=_states.cutscene
   self._cutscene=nil

   _c.reset_scene()

   if not l_cutscenes() and _mode=="story" then
    local cart_id=_states.cart_view._cart_id
    _c.set_scene(_cs[cart_id])
    _c.init()
   else
    self.finish_cutscene()
   end
  end,  
  
  finish_cutscene=function()
   _set_state(_states.post_cutscene, "final")
  end,
  
  update=function(current)
   if (not current) return
   
   if _transitions.camera_x.finished then
    _c.update()
   end
   
   if btnpp(Ž) then
    _c.next_take()
    
    if _c.finished then
     _states.cutscene.finish_cutscene()
    end
   end
  end,
  
  draw=function()
   _c.draw()
  end,
  
  position={ x=128, y=256 }
 },
 
 post_cutscene={
  settings={
   blocking=true,
  },
  
  enter=function()
   _set_transition_target(_transitions.instructions, -9)

   _timeout(function()   
    local cart=_carts[_states.cart_view._cart_id]
    _load_subcart(cart.id) 
   end, _transitions.camera_x.time)
  end,
  
  position={ x=128, y=404 }
 },
 
 credits={
  settings={},
  
  enter=function()
   if(not kenable) music(1)
   local c={
    { s="minigame credits," },
    { s="in no particular order:", dl=24 },
   }
   _states.credits._credits=c
   _states.credits.t=0

   for mg in all(_minigames) do
    add(c, { s=mg.name, c=8 })
    add(c, { s="made by" })
    add(c, { s=mg.made_by, c=12, dl=24 })
   end
   
   add(c,{ dl=96 })
   
   add(c, { s="picoware team:", dl=16 })
   
   for a in all({
    "@cpiod",
    "@knh1901",
    "@reecegames1",
    "@gruber_music",
    "@thattomhall",
    "@szczm_",
   }) do
    add(c, { s=a, c=10 })
   end
   
   add(c, { dl=300 })
   add(c, { s="what are you still doing here?", dl=128 })
   add(c, { s="the credits are over.", dl=256 })
   add(c, { s="really?", dl=384 })
   add(c, { s="go home, the show is over!", })
   add(c, { s="no easter eggs here!", dl=512 })
   add(c, { s="75 79 78 65 77 73 46", c=1 })
  end,
  
  exit=function()
   if (not kenable)music(-1)
  end,
  
  update=function()
   _states.credits.t+=.25
   
   if (btn(”)) _states.credits.t-=4
   if (btn(ƒ)) _states.credits.t+=4
   
   if (_states.credits.t>4570) _states.credits.t=4570
  end,
  
  draw=function()
   local h=136-_states.credits.t
   
   clip(0,0,128,128)
   
   _draw_picoware_logo(10,h+3000)
   rs(" 2019 ", 44, h+3015, 7)
   
   for i, str in pairs(_states.credits._credits) do
    if h>-10 then
     local s=str.s or ""
     local l=#s
     rs(s, 64-l*2, h, str.c or (kenable and 1 or 7))
    end

    h+=(str.dl or 8)

    if (h>128) break
   end
   clip()
  end,
  
  position={ x=0, y=256 }
 },
}

function _set_subcart_data()
 local mode, difficulty, selected_id

 mode=({story=0,infinity=1,single=2})[_mode]

 difficulty=l_diff()
 
 selected_id=_selected_id or 0
 
 poke4(0x4300, mode)
 poke4(0x4304, difficulty)
 poke4(0x4308, selected_id)
 poke4(0x430c, -1)
end

function _get_subcart_data()
 local mode, difficulty, selected_id, score

 mode=peek4(0x4300)
 difficulty=peek4(0x4304)
 selected_id=peek4(0x4308)
 score=peek4(0x430c)
 
 _clear_subcart_data()

 if difficulty==0 then
  _breadcrumb=nil
  return
 end
 
 _mode=({"story", "infinity", "single"})[mode+1]
 _difficulty=difficulty
 _selected_id=selected_id
 _score=score

 if score==-1 then
  _breadcrumb="subcart_cancel"
  return
 end

 _breadcrumb="subcart_finish"
 
 if _mode=="story" then  
  if _score==1 then
   local old_progress=l_prog()
   
   if old_progress == _selected_id then
    poke4(0x5e10, _selected_id+1)
    _progressed=true
   end
  end
 elseif _mode=="infinity" then
  local old_score=load_cart_score(_selected_id)
  
  if old_score < _score then
   poke4(0x5e1c+_selected_id*4, _score)
   _progressed=true
  end
 elseif _mode=="single" then
  local old_score=load_score(_selected_id)
  
  if old_score < _score then
   store_score(_selected_id, _score)
   _progressed=true
  end
 end
end

function clear_progress()
 for i=0x5e00,0x5efc do
  poke4(i, 0)
 end
end

function _load_savedata()
 for i, minigame in pairs(_minigames) do
  minigame.score=load_score(minigame.id)
 end
 
 _progress=l_prog()
 
 for i, cart in pairs(_carts) do
  cart.score=load_cart_score(i)
 end
end

function load_cart_score(id)
 return dget(7+id)
end

function _clear_subcart_data()
 for i=0x4300,0x430c,4 do poke4(i, 0) end
end

function l_prog()local p=dget(4)if p==0 then p=1 poke4(0x5e10, p) end return p end
function l_diff()local d=dget(5)if d==0 then d=1 s_diff(d)end return d end
function s_diff(d)poke4(0x5e14, d)end
function s_cutscenes(s)poke4(0x5e18,s and 1 or 0)end
function l_cutscenes()return dget(6)==1 end
function l_disclaimer()return dget(7)==1 end
function s_disclaimer(r)poke4(0x5e1c,r and 1 or 0)end

function _load_subcart(id)
 local online = stat(102) != 0 or stat(101) ~= nil
  
 local str

 if online then
  str="#"..id
 else
  str=id..".p8.png"
 end
  
 _set_subcart_data()
 local result=load(str, "< back to menu")

 if not result then
  _clear_subcart_data()
    
  if online then
   stop "error occurred while trying to load a minigame cart. check your internet connection."
  else
   stop "error occurred while trying to load a minigame cart. try re-downloading the correctly packaged game from is.gd/picoware"
  end

  return
 end
end

_carts={
 { id="picoware_subcart01", fg=8, bg=10, name="my morning routine", sspr={ x=92, y=23 }},
 { id="picoware_subcart02", fg=9, bg=12, name="a special deal!", sspr={ x=48, y=24 } },
 { id="picoware_subcart03", fg=10, bg=9, name="the bee's knees", sspr={ x=0, y=48 } },
 { id="picoware_subcart04", fg=11, bg=8, name="third time's a charm", sspr={ x=102, y=79 } },
 { id="picoware_subcart05", fg=12, bg=3, name="a clean slate", sspr={ x=44, y=44 } },
 { id="picoware_subcart06", fg=14, bg=12, name="just playing games", sspr={ x=91, y=44 } },
}

_minigames={
 { id=1, cart=1, name="pico-race", made_by="@random_disconnect" },
 { id=2, cart=1, name="sleepers sheepers", made_by="jpecina and typhyter" },
 { id=3, cart=1, name="barbershop sim", made_by="@demonicx + @setff" },
 { id=4, cart=1, name="wake up call", made_by="greencheekgames" },
 { id=5, cart=1, name="pick a good one!", made_by="@leo9" },
 { id=6, cart=1, name="get through the day", made_by="lubu" },
 { id=7, cart=1, name="stay dry", made_by="javier rizzo" },
 { id=8, cart=1, name="slam dunk", made_by="@v360dev" },
 { id=9, cart=1, name="pet the puppos", made_by="dekent.itch.io" },
 { id=10, cart=1, name="shine the spotlight", made_by="jwinslow23" },
 { id=11, cart=1, name="catch all the stars", made_by="@picoter8" },
 { id=12, cart=1, name="save helpi from bosso", made_by="@thattomhall" },

 { id=13, cart=2, name="beam up jelpi", made_by="joll05" },
 { id=14, cart=2, name="abduct the cows", made_by="@mauszozo" },
 { id=15, cart=2, name="avoid the flying jelpis", made_by="@picoter8" },
 { id=16, cart=2, name="shoot the spaceship", made_by="javier rizzo" },
 { id=17, cart=2, name="survive the zombie jelpis", made_by="@picoter8" },
 { id=18, cart=2, name="existence", made_by="@rhizomaticwarmachine" },
 { id=19, cart=2, name="spaceship landing", made_by="jesus gonzalez" },
 { id=20, cart=2, name="alien rescue", made_by="@sam_c_lee" },
 { id=21, cart=2, name="they live", made_by="@rhizomaticwarmachine" },
 { id=22, cart=2, name="jumpship!", made_by="@bellicapax" },
 { id=23, cart=2, name="super jelpi eos", made_by="wander" },
 { id=24, cart=2, name="crush in a jam", made_by="knh190" },

 { id=25, cart=3, name="wigglebee", made_by="@katbuilt and @acreature" },
 { id=26, cart=3, name="oh nose! more bees!", made_by="@jusiv_" },
 { id=27, cart=3, name="obligatory bee game", made_by="@rhizomaticwarmachine" },
 { id=28, cart=3, name="beware of flower pots", made_by="insane scatterbrain" },
 { id=29, cart=3, name="humble bumble", made_by="masternyborg and buzby" },
 { id=30, cart=3, name="shear the sheep", made_by="@ctinney94" },
 { id=31, cart=3, name="save sugar cube!", made_by="cpiod" },
 { id=32, cart=3, name="dizzy fly", made_by="my roe ate" },
 { id=33, cart=3, name="combo bounce", made_by="@doubleatam" },
 { id=34, cart=3, name="home for a hermit crab", made_by="@josephmarksjr" },
 { id=35, cart=3, name="help jelpi vent!", made_by="jamie" },
 { id=36, cart=3, name="climb the tree", made_by="justfire45" },

 { id=37, cart=4, name="ruin the party", made_by="@peepeenanah" },
 { id=38, cart=4, name="sushi scramble", made_by="@robotinker" },
 { id=39, cart=4, name="drop the mint", made_by="dooma4" },
 { id=40, cart=4, name="perfect beer", made_by="dooma4" },
 { id=41, cart=4, name="get the balloon!", made_by="stephmo" },
 { id=42, cart=4, name="spotlight landing", made_by="@svntax" },
 { id=43, cart=4, name="target practice", made_by="@fuwanekogames" },
 { id=44, cart=4, name="pop the balloon", made_by="fwip" },
 { id=45, cart=4, name="paper airplane", made_by="@rhizomaticwarmachine" },
 { id=46, cart=4, name="frequency check", made_by="dberzins" },
 { id=47, cart=4, name="bubble fishy", made_by="qst0" },

 { id=48, cart=5, name="scratch the advertising!", made_by="oniricorpe"},
 { id=49, cart=5, name="publish or perish", made_by="kirais" },
 { id=50, cart=5, name="sort out the beans", made_by="@yeff" },
 { id=51, cart=5, name="find the backwards word", made_by="@nephilim" },
 { id=52, cart=5, name="lantern lights", made_by="capucat" },
 { id=53, cart=5, name="get the shape!", made_by="@reecegames" },
 { id=54, cart=5, name="fill the buckets", made_by="fwip" },
 { id=55, cart=5, name="jelpi counter", made_by="@sam_c_lee" },
 { id=56, cart=5, name="ninja sort", made_by="cupcake<3 (paul wandley)" },
 { id=57, cart=5, name="jelpuzzle", made_by="@vrnspr" },

 { id=58, cart=6, name="pour the tea into the cup", made_by="jwinslow23" },
 { id=59, cart=6, name="walk on ice", made_by="knh190" },
 { id=60, cart=6, name="jelpi lander", made_by="jamie" },
 { id=61, cart=6, name="slide to the goal tile", made_by="numzyx" },
 { id=62, cart=6, name="fuzero", made_by="@planeteightgames" },
 { id=63, cart=6, name="supportive chatroom", made_by="@noscoperadio" },
 { id=64, cart=6, name="jelpocracy", made_by="googroker" },
 { id=65, cart=6, name="tetrominoes in the night", made_by="@alce_x and lin han" },
 { id=66, cart=6, name="get the cherry", made_by="akumarai" },
 { id=67, cart=6, name="catch the bar!", made_by="cpiod" },
 { id=68, cart=6, name="don't drown", made_by="@pixelsix" },
} -- buh

-- minify because limitations
function _filter_mgs(c)local f={}for mg in all(_minigames)do if mg.cart==c then add(f,mg)end end return f end
function _find_mg(i)for mg in all(_minigames)do if mg.id == i then	return mg end end end
function mix(a,b,t)a,b,t=a or 0,b or 0,t or 0 return a*(1-t)+b*t end
function ss(a,b,t)local x=mid((t-a)/(b-a),0,1) return x*x*(3-2*x)end

function daisy_chain_after_return()
 _statestack={}
 __state=nil
 
 local states={
  _states.main_menu,
  _states.select_mode,
  _states.cart_view
 }
  
 if _mode=="single" then
  local minigame=_find_mg(_selected_id)
  _states.cart_view._cart_id=minigame.cart
  _states.minigame_list._minigame=minigame

  add(states, _states.minigame_list)
 else
  _states.cart_view._cart_id=_selected_id
 end
 
 foreach(states, _set_state)

 _reset_transition(
  _transitions.cart_view,
  _states.cart_view._cart_id
 )
 
 if _mode=="single" then
  _reset_transition(
   _transitions.spinner,
   _states.minigame_list.menuitem_id
  )
 end
end

function sp(s)s=tostr(s)
if(#s<3)return sp('0'..s)
return s end

function k_c(bt)
 if(kenable)return
 add(_kpatt,bt)
 if(#_kpatt>11) del(_kpatt,_kpatt[1])
 if h(_kpatt)==19940 then
  kenable=true
  kt=t()  
  sfx(28)
  music(0)
  srand()
  poke(0x5f30,1)
  _progress=7
  for i=0,40 do
   poke(rnd(0x500),rnd(0x100))
  end
  shape={}
  for i=1,50 do
   local a,x,z,b=rnd(),cos(a),sin(a),0.001+rnd(0.005)
   if(rnd()<.5) b=-b
   add(shape,{(10+rnd(30))*x,0,(10+rnd(30))*z,flr(rnd(32)),b<0,rnd()<.5,sin(b),cos(b)})
  end
  foreach(_carts, function(cart)
   cart.fg,cart.bg=cart.bg,cart.fg
  end)
 end
end

function h(t)local o,n=0,0 for i=1,#t do o=2*o+i*t[i]n=4*n+i*i*t[i]end return o*n end
-->8
-- title 3d
-- discord: @ian5
-- bbs: @reecegames
-- twitter: @reecegames1

function tinit()
shape={}
for i=0,31 do
local a=i/32
add(shape,{cos(a)*30,0,sin(a)*30,i})
end
end

function tupdate()roty(0.003,shape)end

function tdraw()
local drawlist={}
for i in all(shape) do
 local a={}
 for j in all(i) do
  add(a,j)
 end
 add(drawlist,a)
end
rotx(0.1,drawlist)
rotz(sin(time()/10)/8,drawlist)
sortz(drawlist)
for i in all(drawlist) do
local size=(i[3]+30)/30*4+4 --col=cols[i[4]]
if(i[3]<-8)for k,v in pairs({1,1,1,2,1,5,15,2,4,9,3,13,1,2,6}) do pal(k,v) end
if(kenable) pal(7,15) -- avoid white on white
if(i[2]>-64)sspr(i[4]*8%128,flr(i[4]/16)*8,8,8,(i[1]-size/2)*2+66,i[2]-size/2+44,size,size,i[5],i[6])
 pal()
end
end

function rotz(a,points)
local sina=sin(a) cosa=cos(a)
foreach(points, function(p)
local x=p[1] y=p[2]
p[1]=x*cosa-y*sina
p[2]=y*cosa+x*sina
end)
end

function roty(a,points)
local sina=sin(a) cosa=cos(a)
foreach(points, function(p)
if(kenable) sina=p[7] cosa=p[8]
local x=p[1] z=p[3]
p[1]=x*cosa-z*sina
p[3]=z*cosa+x*sina
end)
end

function rotx(a,points)
local sina=sin(a) cosa=cos(a)
foreach(points, function(p)
local y=p[2] z=p[3]
p[2]=y*cosa-z*sina
p[3]=z*cosa+y*sina
end)
end

function sortz(a)for i=1,#a do local j=i while j > 1 and a[j-1][3] > a[j][3] do a[j],a[j-1]=a[j-1],a[j] j=j-1 end end end

-->8
-- score load/save for picoware
-- by cpiod

function _lsa(index)
 local i=63-flr(index/3)
 local s=dget(i)
 return {band(lshr(s,4),0x3ff),
 band(shl(s,6),0x3ff),
 band(shl(s,16),0x3ff)}
end

function _ms(s)
 return shl(s[1],4)+lshr(s[2],6)+lshr(s[3],16)
end

function load_score(index)
 return _lsa(index)[index%3+1]
end

function store_score(index,score)
 local i=63-flr(index/3)
 local s=_lsa(index)
 s[index%3+1]=score
 dset(i,_ms(s))
end
-->8

-->8
-- cutscenes
-- knh190

_c={}

_c.print=function(strs)
 local h=102
 
 fillp(0xcccc)
 rect(-1,97,129,127,9)
 fillp()
 
 for text in all(strs) do
  print(text, 8, h, kenable and 0 or 7)
  h+=8
 end
end

_c.set_scene=function(scene)
 _c.scene=scene
end

_c.reset_scene=function()
 _c.take=nil
 _c.finished=false
 _c.scene=nil
end

_c.init=function()
 _c.take=nil
 _c.finished=false
 _c.index=1
 _c.next_take()
end

_c.update=function()
 _c.t+=1
end

_c.draw=function()
 if _c.take then
  clip(0,0,128,128)
  _c.take()
  _c.print(_c.text)
  clip()
 end
end

_c.next_take=function()
 local scene=_c.scene

 _c.take=scene[_c.index]

 if _c.take then
  _c.t=0
 else
  _c.finished=true
 end
 
 _c.text=scene.texts[_c.index]
 
 _c.index+=1
end

_c.es=function()
 if _c.scene then
  _c.scene.es()
  local s=_c.scene.et
  rs(s,64-#s*2,84,15)
 end
end

s1={ 
 function()
  sspr(80,24,48,32,40,40)
  for i=1,4 do
   local tt=((_c.t+i*15)%60)/60
   local x,y=90+20*tt,35-8*tt   
   spr(40, x, y)
  end
 end,
 
 function()sspr(80,24,48,32,40,40)end, 
 function()sspr(0, 24, 48, 24, 40, 40)
  local t1=min(_c.t, 26)  
  local x=108-t1
  local y=59+2*(t1%2)
  spr(36,x,y)
  local door=_c.t>31
  if door then
   rectfill(80, 54, 82, 59, 0)
  end
 end,
 
 texts={{"zzz... zzz...? hmm? oh.","hello, world. morning.",},{"i guess it's time","to get up now...",},{"...and get ready for","yet another great day.",}}
}

s1.es=s1[1]
s1.et="\"a new day ahead!\""

s2={ 
 function()
  sspr(48, 24, 32, 32, 50, 40)
  local t1=min(_c.t, 31)
  local t2=min(_c.t, 21)
  spr(38, 100-t1, 53-2*flr(t1%2))
  spr(37, 50+t2, 55-2*flr(t2%2))
  spr(36, 25+t1, 58-2*flr(t1%2))
 end,
 
 function()
  sspr(48, 24, 32, 32, 50, 40)
  spr(38, 69, 51)
  spr(37, 71, 53)
  spr(36, 56, 56)
  if (mid(0, 30, _c.t) == _c.t) print("look!", 30, 40, kenable and 0 or 7)
  local t2=min(_c.t, 60)
  local s=(-.5-4*sin(t2/120))*8
  sspr(56, 16, 8, 8, -60+t2*4, 20, s, s)
 end,
 
 function()
  sspr(48, 24, 32, 32, 50, 40)
  spr(38, 69, 51)
  spr(37, 71, 53)
  if (_c.t>50) for i=0,15 do pal(i, 7) end
  local t1=mid(50, 70, _c.t)-50
  if (_c.t<70) spr(36, 56, 56-t1)
  pal()
  local t2=min(30, _c.t)
  local t3=max(70, _c.t)-70
  sspr(56, 16, 8, 8, 52, -18+t2*1.8-t3*3, 16, 16)
 end,
 
 texts={{"i hope nothing bad happens","on my way to the store...",},{"\"look, is it a bird?"," an airplane? a ufo?\"",},{"seriously, me again?","give me a breeeeeaaaaak~",}}
}

s2.es=s2[1]
s2.et="\"test tube was comfy.\""

s3={ 
 function()
  local ts=1-2*(mid(70, 80, _c.t)%2)
  sspr(0, 48, 32, 24, 50, 40-ts)
  spr(42, 50, 40-ts)  
  local t1=mid(_c.t,60,70)-60
  if (t1>0) spr(44, 76, -8+t1*7-ts)
 end,
 
 function()
  sspr(0, 48, 32, 24, 50, 40)
  local t1=min(_c.t, 11)
  spr(t1==11 and 41 or 42, 50, 40+t1*2)
  local t2=min(_c.t,19)==19
  local st=45+(_c.t%5==0 and 1 or 0)
  if (t2) spr(st, 59, 62)
  spr(44, 76, 62)
 end,
 
 function()
  sspr(0, 48, 32, 24, 50, 40)
  spr(41, 50, 62)
  local st=45+(_c.t%5==0 and 1 or 0)
  spr(st, 59+_c.t, 62)
  local t1=max(_c.t, 10)-10
  local s2=1-2*flr(t1%2)
  spr(44, 76+t1, 62-s2)
 end,

 texts={{"phew, tests finished! what?","no handshake? you impoliiite~",},{"~pancaaaakes! *ouch* finally!","could this day get any worse?",},{"..oh no, why do i always...","don't sting me pleaaaaase~",}}
}

s3.es=s3[2]
s3.et="\"just five stings.\""

s4={ 
 function()
  local t1=min(_c.t, 10)==10
  local t2=min(_c.t, 70)==70
  if (t1 and not t2) rectfill(40,50,47,60,7) for i=0,15 do pal(i,1) end
  if (t1) spr(44,40,52)
  pal()
 end,
 
 function()
  spr(47,40,52)
  local t1=min(_c.t, 40)==40
  local t2=min(_c.t, 120)==120
  for x=60, 90, 6 do
   spr(37,x,52+2*sin(_c.t/15),1,1,true)
  end
  if (t1) spr(189,35,50) spr(190,47,52)
 end,
 
 function()
  spr(47,40,52)
  for x=60, 90, 6 do
   spr(37,x,52+2*sin(_c.t/15),1,1,true)
  end
  spr(189,35,50) spr(190,47,52)
  spr(191,53,43)
 end,

 texts={{"...ugh, finally home. please,","   no more surprises today-",},{"\"surpriiiiise! *toooot*"," happy birthday, jelpi!\"",},{"okay, i think i've got room","for just one more surprise!",}}
}

s4.es=s4[3]
s4.et="\"hey, free cheesecake!\""

s5={ 
 function()
  local t1=_c.t<60
  if (t1) rectfill(40,50,47,60,7) for i=0,15 do pal(i,1) end spr(36,42,54)
  srand()
  for i=1,30 do
   pset(40+rnd(50),50+rnd(25),10+rnd(6))
  end
  srand(t())
  pal()  
  spr(43,54,53)
 end,
 
 function()
  spr(100, 40, 50, 6, 3)
  local t1=mid(_c.t,10,20)-10
  local t2=mid(_c.t,50,60)-50
  spr(160, 80-t1, 70-t1, 2, 2)
  pal(12, 14)
  spr(160, 39+t2, 70-t2, 2, 2)
  pal()
 end,
 
 function()
  srand(2)
  for i=1,30 do
   pset(40+rnd(50),50+rnd(25),10+rnd(6))
  end
  srand(t())
  local t=(_c.t/2)%120+1
  local t1=mid(t,0,45)
  local t2=mid(t,45,60)-45
  local t3=mid(t,60,105)-60
  local t4=mid(t,105,120)-105
  local dir=(min(t1,1)+min(t2,1)+min(t3,1)-min(t4,1))/4-.25
  local x=85-t1+t3
  local y=60-t2+t4+sin(t/10)
  spr(172, x-cos(dir)*6, y-4+sin(dir)*8, 1, 2)
  spr(186+flr((t/5)%2),x,y)
 end,

 texts={{"thanks for the party! byeee!","...and now for the clean up.",},{"at least everyone stayed to","help me with the clean up.",},{"\"surprise, jelpi! you're"," the best, jelpi!\" ughhh.",}}
}

s5.es=s5[3]
s5.et="\"squeaky clean.\""

s6={ 
 function()
  pal(13, 1) pal(4, 5) pal(9, 4)
  spr(106, 40, 50, 6.5, 3)
  pal()
  local t1=min(_c.t, 22)
  local t2=t1==22
  spr(t2 and 157 or 154, 40+t1, 56-sin(t1/10)+(t2 and 6 or 0))
 end,
 
 function()
  spr(106, 40, 50, 6.5, 3)
  spr(157, 62, 62)
 end,
 
 function()
  local fr = flr(_c.t / 10) % 4
  if(fr<2)pal(13,1)pal(4,9)pal(9, 15)pal(13,6)
  spr(106, 40, 50, 6.5, 3)
  spr(157, 62, 62)
  pal()
 end,

 texts={{"i'm so happy this day has","come to an end! finally...",},{"...i can sit down, relax,","   just me and my pico-8...",},{"       ...and play...","       picoware! ",}}
}

s6.es=s6[2]
s6.et="\"video games.\""


_cs={s1,s2,s3,s4,s5,s6}
__gfx__
40040000000000000022022000a49900000007000f000f0000bbbb00777777760000000000000000999999998000000800005500000000000080080000766500
44440000a0099900002252200a949940000379700ffffff00b3bb3b076666665000a000000533b00455555598800008800050050000000000800008007500650
74744440a09999900105550194949494003007000f1fff10bb8bb8bb7666666500aaa00000fddf0045999959800000084404444000e2eee00888888006500650
444444440a9995990016161044444442000300000effffe0b0b33b0b766666650aa6aa00001ff100459aa95980100108494aaaa40e2eeeee0878878076666665
004444400a9999990066566094949494002888800022200000b00b0076666665aaaa6aa000effe004549a95408888880049aaaa47eeee7760888888076616665
00400040a09a99900666166694949494002888800f8880000bb00bb0766666650aaaaa000022220045444954888888880049aa94077777600281182076616665
00400040a009990000655560099499200002880000000f00bb0000bb7666666500aaa00000888800455555540888888000049940006666600081180076666665
0040004000000000010151010042440000028800000000000b0000b065555555000a000000ffff00444444440800008000044440000000000028820065555555
000000000004400000000000aa000000000000000000000000000000000cc0000002200056565656055555530666660005000050000000009fffffff00000000
000c00c00074470007777700ddd0000000000600000000000000000000c66c000022220065555555033333306688866000500500080800005999999f00677000
000cccc00049940007555770ddaaa00056776680f00000f00000660000c66c00066cc660556677560bfffb536887886000999900888880005979999f66776770
7666ccc00044440007777770daaaaa00567776660ffffff00d1666500c6666c0066cc66065666755055555506872786000919190088800005999999f76577370
000cccc00447744007555570daaaaaa077777765011ff11001166a5d0c6666c00474747055666656000555006887886007e999e0008000005999449f66577760
000c00c04477774407777770daa1a1aa077777000cffffc0005a5a50c666666c00474700656666550005f500668886600075550000000e0e59d9449f67676770
000000000077770007555570daa1a1aa065056000088800000000000cccccccc066666605555555600f5550006666600000aaa90000000e05999999f00677000
000000000090090007777770daaaaaa06050506000f0f0000000000000999900060000606565656500000f000000000000090000000000005555555900505000
0123456789abcdef000700000777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e000
0000000524431125007770000d777d000f00f0000f00f0000f00f00000dddd0000000000000000000009aa000f0000f00f0000f000000000089806000f0ee0f0
00000000000000000777770000d7d0000ffff0000ffff0000ffff0000d8dbdc000fff00000909000009090600ffffff00ff77ff008980060009090660ff77ff0
00000000000000000ddddd00000d00000effe00009ff900009ff9000dddddddd0000f000099aaa60099aaaa00f1ff1f00f1f77f000909066000009000f1f77f0
000000000000000000000000000000000022000000dd000000dd0000008bae00000f000000990906009909060effffe002fff770000009060000990002fff770
000000000000000000000000000000000088000000ee000009cc0000000ba00000ffff000999aaa00999aaa00022220000282200000099000000000000282200
0000000000000000000000000000000000f0f00000f0f00009f0f000080b00000000000000909600009096000088880000866800000000000000900000866800
000000000000000000000000000000000000000000000000000000000800000000000000000990000009900000f00f0000f00f00000090000000000000f00f00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
999999999999999999999999999999999990999999999999cccccccccccccccc5ffff5cccc5ccccc441fffffffffff177cccccccccccccccccccc7ffffffffff
dddddddddddddddddd9dddddddddddddddd0dddddd9dddddcccccccccccccccc5ffff5cccc5cccccff41fffffffffff17777ccccccccccccccc77fffffffffff
555555555555555555955555dd5555555dd055555595555555555555555555cc5ffff5cccc5cccccffff11fffff4444414444444444444444444444444444fff
555555555555555556665555ddce9dec9dd0555556665555ccccccccccccc5cc5ffff5cccc5cccccfffff4144449911491999999949999999994999999999444
555555555555555556665555ddcecdeccdd0555556665555ccccccccccccc5cc5ffff5cccc5cccccffffff411999199111999999949999999444999999999499
11111111111111111f661111ddcecdeccdd011111f661111c5ccc5c5ccccc5cc555555cccc5cc555ffffff499111999499999aaaaaaaa9a99994999999994499
fff6ffff6fffffd66fff6666ddddddddddd066666fff666655ccc555cc5555cc5c5cc5cccc5cc5ccffffff4999999994999aa9999999999aa144999999999499
fff6ffff6fffffd666666666dd9e9c899dd06666666666665ccccc5ccc5c55cc555555cccc5cc5ccffffff4444444444444f999199919999f144444444444444
666666666666661666666666ddeecc8c6dd0666666666666556cc655cc5cc5cc5cc5c5cccc5cc5ccffffff4999994499999f999111119999f199999944999999
fff6ffff6ff99fdf66666666ddeecc8c6dd066666666666655666655555cc5cc555555cccc5cc5ccffffff4999994999999f9ffffffffff9f199999994999999
fff6ffff6ff99fdff6666666ddddddddddd0666666666666cce66eccccc5c5cc5c5cc5cccc5cc5ccffffff4999994999999ff99999999ffff199999994999999
fff6ffff6cc99fdfff666666dd8c9c9e9dd0666666666666ccc55cccccc5c5cc555555cccc5cc5ccffffff4999994999944f99999999999ff199999994999999
ddd1dddd1d111ddffff66666dd8ceceecdd0666000000666ccc66ccccccc55cc555555cccc5cc5ccffffff4444444444444f9999999ff999f144444444444444
fff6ffff6ff66ffffff66666dd8ceceecdd0666066660666cc6cc6ccccccc5cc555555cccc5cc5ccffffff4999999994999f999999999ffff194449999999999
fff6ffff6ff66ffffff66666ddddddddddd066606666066655555555555555555555555555555555fffff49999999944999f99999999999ff194999999999994
ffff6ffff6ff66fffff66666ddce9dec9dd066606666066666666666666666666666666666666666fffff49999999994999f999999999999f194999999999999
ffff66fff66ff66ffff66666ddcecdeccdd066600666066666666666666666666666666666666666fffff49994499994999f999999999999f194999999994444
888888888888888dddd55555ddddddddddd055507777055566666666666666666666666666666666fffff44444444444444f999999999999f144444444444444
48888888888888888ddd5555dd9999999dd055507777055566666666666666666666666666666666fffff49999994999999f9999ff999999f199999444999999
4888888888888448400000005566666dd55000500000050066666666666666666666666666666666fffff49999994999999f999f99999999f199999944999999
10000000000000101000000055ddddd5555000000000000055555555555555555555555555555555fffff49999994999444f999999999999f199999994999999
00000000000000000000000000000000000000000000000066666565666666665656666666666565fffff49999994999999f999999999999f199999994999999
0000000000000000000000000000000066666666565665fffffffffffffffffffffffff565666666999999999999999999999999999999999999999999999994
cccccccccccccccccccccccccccccccc66666666565665fffffffffffffffffffffffff565666666999999999999999999911111111111199999999999999949
cccccccccccccccccccccccccccccccc66666666565665fffffffffffffffffffffffff565666666444444444444444911111111111111111194444444444499
cccccccccccccccccccccccccccccccc6666666656565ffffffffffffffffffffffffff565666666999944449999999994999999999999d94999999999999499
cccccccccccccccccccccccccccccccc666666665655fffffffffffffffffffffffffff56566666699994999949999999444999999999d994999999999999499
cccccccccccccccccccccccccccccccc55555555555f555f555f555f555f555f555f555f555555559999499999999999944999999999d9994999999999999499
cccccccccccccccccccccccccccccccc66666666665f999f999f999f999f999f999f99956666666699994999999999999499999999dd99994999999999944499
cccccccccccccccccccccccccccccccc66666666665999f999f999f999f999f999f999f5666666669999499999999999949999999d9999994999999444444499
ccccccc3ccccc3cccccccccccccccccc6666666666599999999999999999999999999995666666664444444444444444444444444d4444444444444444444499
ccccccc3ccccc3cccccccccccccccccc6666666666599f999f999f999f999f999f99999566666666999999999999444999999ddddddddd999999999999999499
c3ccccc3ccccc3cccc3ccccccccccccc66666666665999999999999999999999999999956666666699999999999944999999dcccccccccd99999999999999499
c3ccc3c33ccc33c3cc3ccccccccccccc66666666665999999999999999999999999999956666666699999999999949999999dceeccc99cd99999999999999499
c33cc3c33ccc33c3c33ccccccccccccc66666666665999999999999999999999999999956666666699999999999949999999ddddddddddd99999999999999499
333cc3333ccc33c3c33ccccccccccccc666666666659999999999999999999999999999566666666999999999999499999999999949999999999999999999499
333cc3333c3a0333c333cccccccccccc666666666659999999999999999999999999999566666666999999999999ddd999999999949999999999ddd994444499
3333c3333c3c3330a333cccccccccccc66666666665999999999999999999999999999956666666644444444444dfffd4444444444444444449dfffd44444499
3333c333333c3333c333cccccccccccc66666666665999999999999999999999999999956666666699994999999dfffdddddddddddddddddddddfffd99999499
3333333333333333c333cccccccccccc66666666665555555555555555555555555555556666666699994999999dfffdffffffdfffffdffffffdfffd99999499
330a333333333333333333333333333366666666666666666666666666666666666666666666666699994999449dffffdfffffffffffffffffdffffd99999499
3333333333333333333333333333333366666666666666666666666666666666666666666666666699994999999dffffdfffffdfffffdfffffdffffd99999499
3333333333333333333333333333333366666666666666666666666666666666666666666666666699994444999dffffdfffffffffffffffffdffffd99999499
3333333333333333a33333333333333366666666666666666666666666666666666666666666666644444444444dffffdfffffdfffffdfffffdffffd44444499
3333333333333333033333333333333366666666666666666666666666666666666666666666666699999999999dffffdddddddddddddddddddffffd99999499
3333333333333333333333333333333366666666666666666666666666666666666666666666666699999999999dfffdfffffffffffffffffffdfffd99999499
33333333333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333000000000000000000000000000000000000000000000000100000001000000010000100010000100000000000000000
33333333333333333333333333333333000000000000000000000000000000000000000000000000111100001111000011111100011111100000000000000000
333333333333333333333333333333330000000000000000000000000000000000000000000000001ff100001ff100001ffff10001ffff100000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000001ff100001ff1000011111100011111100000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000001f1100001f11000011111100011111100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000111100001111000000110000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000011000000110000000001000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000011000000110000001000000000000000000000000000000
05550055500000000000000000000000000000000000000000000000000000000000000000000000000100001000000000004000000000000000000000000000
5ccc55ccc55000000000000000000000000000000000000000000000000000000000000000000000010000000001000000000000000000000000000000000000
5cccf5cccf5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000
55555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000
5cccf5cccf5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5cccf5cccf5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000
05cc505cc50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000
00555005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099900000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000f00f0000f000909990000000000000300000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffff00ffffff00090909008900000000300000ee0ee00
000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffff00ffffff000909090039e000000830000eeeeeee0
000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffff00ffffff0009090903eee000009999e00eeeeeee0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000222200002222000909090000eee0000fffffe00eeeee00
000000000000000000000000000000000000000000000000000000000000000000000000000000000088880000888f00000000000000e0000999999000eee000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000f00f0000f000000000000000000e0000000000000e0000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b30000bb3000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bbb303bbbb300066000000666000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b03bb7773b7777730670600006000600
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b3bbb070bb70707b0600600060700060
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbb3bbbbbbbbbbbb0066000060000060
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b03b1bbb3b1bbbbb0000000060000060
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003b76703b767b30000000006000600
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000767000767000000000000666000
00000000007777000000000000000000cccccccc00000000000000000000000000000009988ff000000000000000000000000000000000000000000000000000
00000000071111700777000000777000cccccccc000000000000000000f000f0f000f0090000f000000000000000000000000000000000000000000000000000
000000007111d1177aaa700077aaa700ccc77777000008088000000000ffffffffffff0a0000e000000000000000000000000000000000000000000000000000
0000000071111d15589a7000589a7000cc700000000088878800000000fffff1fffff10a0000e008000077770777700777007777007000700777700777700777
000000007111111777aaa7007aaa7000cc700000000088887803330000fffffefffffe0b0000d097f00770770077007700077077077070707707707707707700
00000000711111170077700007770000cc700000000088888833333000222fd00222fd0bbccdda777e0777770077007700077077077770707777707777007777
00000000071111700000000000000000cc700000000008888033333333888000088800000dd000b7d00770000077007700077077077777707707707707707700
00000000007777000000000000000000cc700000000000880033333333000f000000f0006666000c000770000777707777077770077077007707707707707777
__gff__
0000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000000000000000000000000000000000000000000000000000000
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
010300000c5450050026500175001c5052050527505065052b50501505175051c5050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500500
010500001f0202b0252830011300233001f30007300133000530002300173051c3050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500300
010600002407018070240700c0751f00007000130000500002000170001c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700002b02030025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500002b0241f0202830011300233001f30007300133000530002300173051c3050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500300
010500002377223775007002274222745007002576225765007002a7522a755007002577225772257622576225762257622575225752257522575225742257422573225722257152470024700247002470024700
010700001d0701d075000001c0001c0401c0451d005000001b0601b0621b0521b0521b0521b0521b0521b0521b0521b0521b0521b0421b0421b0421b0321b0221b0221b0221b0121b0121b0151b0000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900000ca1413a1210a120ca2213a2210a220ca3213a3210a320ca4213a4210a420ca5213a5210a520ca6213a6210a620ca5213a5210a520ca4213a4210a320ca3213a2210a220ca1213a1210a120ca131fa00
011000000070518775187051d77518705187051f77518705187052177518705187051d7751870518705187051c7751870518705187051a775187051870518705187751870518705187051f775187050070500705
000800000f40200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402
0007000025100160001f200233003460016400107002d1001e000203002f4000d1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000c5050050026500175001c5052050527505065052b50501505175051c5050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500500
000500001f0002b0052830011300233001f30007300133000530002300173051c3050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500300
000600002400018000240000c0051f00007000130000500002000170001c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700002b00030005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500002b0041f0002830011300233001f30007300133000530002300173051c3050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500300
000200001e02024010200101a020190201d02027030300303a0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001242216422114221e42210402004022840200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402
000300001242216422114220d42210402004022840200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402
000900000ca1413a1210a120ca2213a2210a220ca3213a3210a320ca4213a4210a420ca5213a5210a520ca6213a6210a620ca5213a5210a520ca4213a4210a320ca3213a2210a220ca1213a1210a120ca131fa00
011000000070518775187051d77518705187051f77518705187052177518705187051d7751870518705187051c7751870518705187051a775187051870518705187751870518705187051f775187050070500705
000800000f41200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402
0007000025150160501f250233503465016450107502d1501e050203502f4500d1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000300000c5350050026500175001c5052050527505065052b50501505175051c5050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500500
000500001f0202b0252830011300233001f30007300133000530002300173051c3050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500300
000600002407018070240700c0751f00007000130000500002000170001c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700002b02030025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500002b0241f0202830011300233001f30007300133000530002300173051c3050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500300
000200001e02024010200101a020190201d02027030300303a0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001242216422114221e42210402004022840200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402
000300001242216422114220d42210402004022840200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402
000900000ca1413a1210a120ca2213a2210a220ca3213a3210a320ca4213a4210a420ca5213a5210a520ca6213a6210a620ca5213a5210a520ca4213a4210a320ca3213a2210a220ca1213a1210a120ca131fa00
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00000d5400d5410d5410d5410d5410d5410c5410c5410b5410a54109531085310753106521055210552105521055210552105521065210752108531095310a5310b5410c5410d5410e5410f5411054123541
010f00001805318000180001800018000180001800018000180531800018000180001800018000180001800018053180001800018000180531800018000180001805318000180001805318053180002400024000
010700000b0140d02211022160321a0321e042260221d03222022250222a032280322c04230042340523403234032340323402434015000020000234000340050000200000000000000000000000000000000000
010f00000814008130081250010008140080250814000100061402071420715120151401517015071400814003140031300114001015011400d015011400010000140001001f7152071523015250150214002015
010f00000c0530000520005200152661500005200150c0330c0531c7141c71500005156252061520015116140c0530000520015200150e62500005230150c053230050c0531c7151c71519615116251f61511614
011700000002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020
011500000c7030c7230c025007030e0250070311723007030070310025007030e0250070313025077230e70300703177230070313025007030e025100250c753007030070300723007030e0250c0250070300703
0106000028630227501c630117500f62009750016250c723006150000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00000c775107752b775107252b725047170470204702007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
010f00200d5400d5420d5320d52210542105150d5420d515105421b7141b71512542125150050213542005020d5420d5020d5420d51210542105120d5420d51213542135151b7151b715105420d522105320d542
__music__
03 3b 42 43 44
01 39 42 43 44
00 39 42 43 44
00 39 42 43 44
00 39 37 43 44
00 39 3a 43 44
00 39 3a 43 44
00 39 3a 43 44
00 39 3a 43 44
00 39 3a 3f 44
00 39 3a 3f 44
00 39 3a 3f 44
00 39 3a 3f 44
00 39 3a 3f 44
00 39 3a 3f 44
00 39 3a 3f 44
00 39 3a 3f 44
00 39 42 3f 44
00 39 42 3f 44
00 41 42 3f 44
00 41 37 3f 44
00 41 3a 3f 44
00 41 3a 3f 44
00 41 3a 3f 44
00 41 42 3f 44
02 36 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
03 3b 3c 43 44
03 3f 3a 39 44
