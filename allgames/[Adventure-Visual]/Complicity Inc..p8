pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- complicity inc.
-- by connor halford

--[[
made solo in 48 hours for
ludum dare 40 compo based on
the theme 'the more you have,
the worse it is'
--]]

--[[
the fade code was written by
me during ld. i made a fade
chart myself too but it sucked
so i generated one with
http://kometbomb.net/pico8/fadegen.html
i feel like that's within rules
--]]

kinds={ --types of window
 "email",
 "click",
 "map",
 "files",
 "censor",
 "balance",
 "process",
}
title_height=7

clock_start=-10
clock_end=480 --8 hours * 60 min
ticks_per_minute=8
--ticks_per_minute=1
function new_task_clock()
 return clock+min_clock_per_task+flr(rnd(max_clock_per_task-min_clock_per_task))
end

--sfx ids
sfx_fail=0
sfx_wrong=1
sfx_right=2
sfx_scroll=3
sfx_censor=4
sfx_complete=5
sfx_email=6
sfx_click=7
sfx_file_destroy=8
sfx_file_drop=9
sfx_overtime=10
sfx_new_task=14
playing_sfx_scroll=false
playing_sfx_censor=false
channel_loop=3

censor_width=20
censor_height=8
censor_cols=flr(128/censor_width)
censor_rows=flr(32/censor_height)

jobs={
 "trainee",
 "junior",
 "associate",
 "expert",
 "senior",
 "manager",
 "administrator",
 "executive",
 "chief",
 "vice president",
 "president",
 "director",
 "partner",
 "owner",
 "prime minister",
 "king and/or queen",
 "emperor and/or empress",
 "god"
}
emails={{
 "subject: first day",
 "greetings employee #452783.",
 "welcome to complicity inc.",
 "",
 "please keep up with all",
 "assigned tasks until end of",
 "day at 17:00. thank you.",
 "",
 "job",
 "@@@",
},{
 "subject: congratulations",
 "greetings employee #452783.",
 "you have been performing",
 "your tasks well.",
 "",
 "you have been promoted to",
 "job",
 "@@@",
},{
 "subject: end of day summary",
 "greetings employee #452783.",
 "today's performance summary:",
 "completed_today",
 "maintained_today",
 "failed_today",
 "overtime_today",
 "",
 "all employees are reminded",
 "that failure to complete 3",
 "tasks in a day will lead to",
 "immediate termination.",
 "thank you.",
},{
 "subject: you're fired",
 "greetings employee #452783.",
 "you have failed to meet",
 "company standards and are",
 "being let go.",
 "",
 "days",
 "job",
 "completed_total",
 "maintained_total",
 "failed_total",
 "overtime_total",
 "",
 "have a nice day.",
}}

function draw_responsibilities(x,y)
 local dy,c=7,2
 print("responsibilities include:",x,y,0)
 if(rank>=1)print("> maintaining power",x,y+1*dy,c)
 if(rank>=2)print("> removal of unwanted assets",x,y+2*dy,c)
 if(rank>=3)print("> maintaining connections",x,y+3*dy,c)
 if(rank>=4)print("> championing our values",x,y+4*dy,c)
 if(rank>=5)print("> profit forecasts",x,y+5*dy,c)
 if(rank>=6)print("> improving society",x,y+6*dy,c)
end

function allocate_censor(b)
 b.col=next_censor%censor_cols
 b.row=flr(next_censor/censor_rows)
 for x=0,censor_width-1 do
  for y=0,censor_height-1 do
   sset(b.col*censor_width+x,
    64+b.row*censor_height+y,10)
  end
 end
 next_censor=(next_censor+1)%(censor_cols*censor_rows)
end

function add_icon(x,y,name)
 local i={}
 i.x=x i.y=y
 i.name=name
 if name=="destroy" then
  i.sx=0 i.sy=16
 end
 add(icons,i)
end

function add_window(x,y,kind)
 local w={}
 w.x=x w.y=y
 w.w=50 w.h=title_height+1
 w.tray_index=#windows+1
 w.kind=kind
 w.title=kind
 w.buttons={}
 if kind=="click" then
  w.w=56 w.h+=9
  w.title="reactor"
  w.percent=100
  add_button(w,"refuel",28,1,24,6)
 
 elseif kind=="map" then
  w.w=32 w.h+=52
  w.title="drone"
  w.pan_x=10
  w.pan_y=10
  w.cur_x=31
  w.cur_y=31
  w.target_x=w.cur_x
  w.target_y=w.cur_y
  w.visible=true
  w.percent=100
  add_button(w,"”",11,36,8,6)
  add_button(w,"ƒ",11,44,8,6)
  add_button(w,"‹",1,40,8,6)
  add_button(w,"‘",21,40,8,6)
 
 elseif kind=="files" then
  w.w=62 w.h+=35
  w.title="evidence"
  local rates={3,4,5,6}
  w.files={}
  for i=1,#rates do
   add(w.files,{
    x=4+(i-1)*14,y=15,percent=100,
    rate=rates[1+flr(rnd(#rates))]
   })
   w.files[#w.files].ox=w.files[#w.files].x
   w.files[#w.files].oy=w.files[#w.files].y
   del(rates,w.files[i].rate)
  end
  
 elseif kind=="censor" then
  w.w=53 w.h+=40
  w.percent=100
  w.num_done=0
  w.text={}
  w.blocks={}
  while #w.blocks<3 do
   w.blocks={}
   for y=0,3 do
    for x=0,5 do
     add(w.text,{x=x*8,y=y*8,
      s=4+flr(rnd(8))})
    end
    if rnd(1)<0.5 then --top
     add(w.blocks,{
      x=2+flr(rnd(35)),
      y=2+y*8,
      w=5+flr(rnd(10)),
      h=3,done=false})
    end
    if rnd(1)<0.5 then --bottom
     add(w.blocks,{
      x=2+flr(rnd(35)),
      y=6+y*8,
      w=5+flr(rnd(10)),
      h=3,done=false})
    end
   end
   for i=1,#w.blocks do
    allocate_censor(w.blocks[i])
   end
  end
  
 elseif kind=="balance" then
  w.w=68 w.h+=30
  w.percent=100
  w.target=1000*(11+flr(rnd(12)))
  w.target+=100*flr(rnd(10))
  local delta=1000*(3+flr(rnd(4)))
  delta+=100*flr(rnd(10))
  if rnd(1)<0.5 then
   w.current=w.target-delta
  else
   w.current=w.target+delta
  end
  add_button(w,"+$100",1,14,20,6)
  add_button(w,"+$200",23,14,20,6)
  add_button(w,"+$500",45,14,20,6)
  add_button(w,"-$100",1,22,20,6)
  add_button(w,"-$200",23,22,20,6)
  add_button(w,"-$500",45,22,20,6)
  
 elseif kind=="process" then
  w.w=63 w.h+=29
  w.heads={"‚","Œ"}
  w.bodies={"‰","’"}
  w.colors={9,12,2,11}
  w.watch={
   head=w.heads[1+flr(rnd(#w.heads))],
   col=w.colors[1+flr(rnd(#w.colors))]
  }
  w.jail={
   head=w.heads[1+flr(rnd(#w.heads))],
   col=w.colors[1+flr(rnd(#w.colors))]
  }
  while match(w.watch,w.jail) do
   w.jail={
    head=w.heads[1+flr(rnd(#w.heads))],
    col=w.colors[1+flr(rnd(#w.colors))]
   }
  end
  w.people={}
  w.wrong=0
  w.percent=100
  for i=1,15 do
   if rnd(1)<0.2 then
    if rnd(1)<0.5 then
     add(w.people,{
      head=w.watch.head,
      body=w.bodies[1+flr(rnd(#w.bodies))],
      col=w.watch.col })
    else
     add(w.people,{
      head=w.jail.head,
      body=w.bodies[1+flr(rnd(#w.bodies))],
      col=w.jail.col })
    end
   else
    add(w.people,{
     head=w.heads[1+flr(rnd(#w.heads))],
     body=w.bodies[1+flr(rnd(#w.bodies))],
     col=w.colors[1+flr(rnd(#w.colors))]})
   end
  end
  add_button(w,"ˆ",1,15,8,6)
  add_button(w,"™",11,15,8,6)
  add_button(w,"Š",21,15,8,6)
  
 elseif kind=="email" then
  w.w=119 w.h=112
  add_button(w,"—",w.w-10,-title_height,8,6)
  w.email=1
  email_open=true
 end
 
 add(windows,w)
 if w.kind=="email" then
  w_start=-1 f_start=-1
  i_start=-1 dragging=nil
 elseif dragging=="window" or dragging=="file" then
  bring_to_front(w_start)
  w_start=#windows
 end
end

function add_email(email)
 add_window(4,4,"email")
 windows[#windows].email=email
 sfx(sfx_email)
end

function match(a,b)
 return a.head==b.head and a.col==b.col
end

function add_button(w,str,x,y,wd,h)
 local b={}
 b.str=str
 b.x=x b.y=y b.w=wd b.h=h
 add(w.buttons,b)
end

function remove_window(w)
 local tray_index=w.tray_index
 if (dragging=="window" or dragging=="file") and w==windows[#windows] then
  dragging=nil
  w_start=-1
  f_start=-1
 end
 del(windows,w)
 for i=1,#windows do
  if windows[i].tray_index>tray_index then
   windows[i].tray_index-=1
  end
 end
 if w_start>1 then
  w_start-=1
 end
end

function add_random_window(new_rank)
 local x=12+flr(rnd(64))
 local y=12+flr(rnd(64))
 sfx(sfx_new_task)
 if new_rank and rank<7 then
  if(rank==1)add_window(x,y,"click")
  if(rank==2)add_window(x,y,"files")
  if(rank==3)add_window(x,y,"map")
  if(rank==4)add_window(x,y,"censor")
  if(rank==5)add_window(x,y,"balance")
  if(rank==6)add_window(x,y,"process")
 else
  local options
  if(rank==1)options={"click"}
  if(rank==2)options={"click","files"}
  if(rank==3)options={"click","files","map"}
  if(rank==4)options={"click","files","map","censor"}
  if(rank==5)options={"click","files","map","censor","balance"}
  if(rank>=6)options={"click","files","map","censor","balance","process"}
  add_window(x,y,options[1+flr(rnd(#options))])
 end
end

function bring_to_front(i)
 if(i<1 or i>#windows)return
 local p=i
 while p<=#windows-1 do
  windows[p],windows[p+1]=windows[p+1],windows[p]
  p+=1
 end
end

function _init()
 poke(0x5f2d,1) --enable mouse
 
 pal_idx=0
 fade_dir=0
 fade_delay=0
 
 reset()
 --add_window(40,40,"click")
 --add_window(40,40,"map")
 --add_window(40,40,"files")
 --add_window(40,40,"censor")
 --add_window(40,40,"balance")
 --add_window(40,40,"process")
 --add_email(1)
end

function reset()
 windows={} --in render order
 icons={} --desktop icons
 email_open=false
 
 day=1
 rank=1
 completed_today=0
 completed_total=0
 maintained_today=0
 maintained_total=0
 failed_today=0
 failed_total=0
 overtime_total=0
 
 min_clock_per_task=60
 max_clock_per_task=120
 clock=clock_start
 clock_tick=0
 next_task_clock=new_task_clock()
 
 next_censor=0
 
 dragging=nil
 dragx=0 --pos offset
 dragy=0
 
 mx_start=0 --set on new click
 my_start=0
 w_start=-1 --clicked window
 b_start=-1 --clicked button
 i_start=-1 --clicked icon
 f_start=-1 --clicked file
 
 add_icon(4,4,"destroy")
end

function debug_update()
 if btnp(4) then
  add_random_window()
 end
 if btnp(5) then
  clock=clock_end
 end
 if btnp(0) then
  fade_dir=1
 end
end

function _update60()
 pmx=mx --previous frame's input
 pmy=my
 pmb=mb
 mx=stat(32) --mouse x
 my=stat(33) --mouse y
 mb=stat(34) --mouse buttons
 
 --screen fade
 local fade_spd=1
 if fade_dir<0 then
  pal_idx=max(0,pal_idx-fade_spd)
  if(pal_idx==0)fade_dir=0
 elseif fade_dir>0 then
  pal_idx=min(15,pal_idx+fade_spd)
  if(pal_idx>=15 and fade_delay==0)fade_delay=30
 end
 if fade_delay>0 then
  fade_delay-=1
  if fade_delay<=0 then
   windows={}
   w_start=-1
   if failed_today>=3 then
    --reset after game over
    reset()
   else
    --progress to next day
    clock=clock_start
    day+=1 rank+=1
    completed_today=0
    maintained_today=0
    failed_today=0
    min_clock_per_task=max(30,60-4*rank)
    max_clock_per_task=max(70,120-4*rank)
   end
   fade_dir=-1
  end
 end
 if(fade_dir~=0)return
 
 --mouseover, update, failure
 mouseover=nil
 for i=#windows,1,-1 do
  local w=windows[i]
  if mouseover==nil and in_window(mx,my,w) then
   mouseover=w
  end
  
  update_window(w)
  
  --task failure
  local fail=false
  if w.kind=="click" or w.kind=="map" or w.kind=="censor" or w.kind=="balance" then
   if(w.percent<=0)fail=true
  elseif w.kind=="files" then
   for f=1,#w.files do
    if(w.files[f].percent<=0)fail=true
   end
  elseif w.kind=="process" then
   if(w.wrong>=3 or w.percent<=0)fail=true
  end
  if fail then
   failed_today+=1
   failed_total+=1
   sfx(sfx_fail)
   if w_start>=1 and w_start<=#windows and w==windows[w_start] then
    w_start=-1
   end
   remove_window(w)
   if failed_today>=3 then
    maintained_total+=calc_maintained()
    overtime_total+=max(0,clock-clock_end)
    windows={}
    w_start=-1
    add_email(4)
    break
   end
  end
 end
 
 if release() and playing_sfx_scroll then
  playing_sfx_scroll=false
  sfx(-2,channel_loop)
 end
 
 if click() then
  mx_start=mx
  my_start=my
  w_start=-1
  b_start=-1
  i_start=-1
  f_start=-1
  
  --click window brings to front
  for i=#windows,1,-1 do
   local w=windows[i]
   if in_window(mx,my,w) then
    bring_to_front(i)
    w_start=#windows
    
    --click buttons in window
    for j=1,#w.buttons do
     local b=w.buttons[j]
     if in_rect(mx,my,w.x+1+b.x,w.y+1+title_height+b.y,b.w,b.h) then
      button_click(w,b)
      b_start=j
      break
     end
    end
    
    --click files in window
    if w.kind=="files" and not email_open then
     for j=1,#w.files do
      local f=w.files[j]
      if in_rect(mx,my,w.x+1+f.x,w.y+1+title_height+f.y,9,14) then
       f_start=j
       break
      end
     end
    end
    
    break
   end
  end
  
  --grab icons
  if w_start==-1 then
   for i=1,#icons do
    if in_rect(mx,my,icons[i].x,icons[i].y,16,16) then
     i_start=i
    end
   end
  end
 end
 
 if held() and w_start>0 and b_start>0 then
  button_hold(windows[w_start],windows[w_start].buttons[b_start])
 end
 
 --drag things around
 if dragging=="window" then
  windows[#windows].x=mx-dragx
  windows[#windows].y=my-dragy
  if not held() then
   dragging=nil
   sfx(sfx_file_drop)
  end
  
 elseif dragging=="icon" then
  icons[i_start].x=mx-dragx
  icons[i_start].y=my-dragy
  if not held() then
   dragging=nil
   sfx(sfx_file_drop)
   --icons[i_start].x=8*flr(icons[i_start].x/8)
   --icons[i_start].y=8*flr(icons[i_start].y/8)
  end
  
 elseif dragging=="file" then
  local f=windows[w_start].files[f_start]
  f.x=mx-dragx
  f.y=my-dragy
  if not held() then
   dragging=nil
   local destroyed=false
   for i=1,#icons do
    if icons[i].name=="destroy"
    and in_rect(mx,my,icons[i].x,icons[i].y,16,16) then
     del(windows[w_start].files,f)
     destroyed=true
     sfx(sfx_file_destroy)
     if #windows[w_start].files==0 then
      complete_task(windows[w_start])
     end
     break
    end
   end
   if not destroyed then
    f.x=f.ox f.y=f.oy
    sfx(sfx_file_drop)
   end
  end
  
 elseif held() then
  if w_start>0 then
   local w=windows[w_start]
   if in_title(mx_start,my_start,w) then
    sfx(sfx_click)
    dragging="window"
    dragx=mx-w.x
    dragy=my-w.y
   elseif f_start>0 then
    sfx(sfx_click)
    dragging="file"
    dragx=mx-windows[w_start].files[f_start].x
    dragy=my-windows[w_start].files[f_start].y
   end
  elseif i_start>0 then
   sfx(sfx_click)
   dragging="icon"
   dragx=mx-icons[i_start].x
   dragy=my-icons[i_start].y
  end
 end
 
 --remove completed censors
 for i=#windows,1,-1 do
  if windows[i].kind=="censor"
  and windows[i].num_done==#windows[i].blocks then
   complete_task(windows[i])
   if playing_sfx_censor then
    playing_sfx_censor=false
    sfx(-2,channel_loop)
   end
  end
 end
 
 --clock
 if not email_open then
  clock_tick+=1
  if clock_tick>=ticks_per_minute then
   clock+=1
   clock_tick-=ticks_per_minute
   if clock==0 then
    if(day==1)add_email(1)
    if(day>1)add_email(2)
   elseif day==1 and clock==90 then
    rank+=1
    add_email(2)
   elseif clock>=next_task_clock
   and clock<clock_end-30 then --don't spawn in last half hour
    add_random_window()
    next_task_clock=new_task_clock()
   elseif clock>=clock_end then
    --detect end of day
    maintained_today=calc_maintained()
    if maintained_today==#windows then
     maintained_total+=maintained_today
     overtime_total+=max(0,clock-clock_end)
     windows={}
     w_start=-1
     add_email(3)
    elseif clock-1<clock_end then
     sfx(sfx_overtime)
    end
   end
  end
 end
 
 --debug_update()
end

function update_window(w)
 if(email_open)return
 
 local scale=1+((rank-1)/10)
 
 if w.kind=="click" then
  w.percent=max(0,w.percent-0.08*scale)
  
 elseif w.kind=="map" then
  local dx=w.target_x-w.cur_x
  local dy=w.target_y-w.cur_y
  local d_sqr=dx*dx+dy*dy
  if d_sqr<=1 then
   --pick new target when close
   w.target_x=5+flr(rnd(57))
   w.target_y=5+flr(rnd(57))
  else
   --move to target
   local spd=0.1
   local ang=atan2(dx,dy)
   w.cur_x+=cos(ang)*spd
   w.cur_y+=sin(ang)*spd
  end
  --visibility detection
  w.visible=true
  local l,r=w.x+2,w.x+26
  local t,b=w.y+2+title_height,w.y+26+title_height
  local x,y=map_to_screen(w)
  if(x<l or x>r or y<t or y>b)w.visible=false
  if w.visible then
   w.percent=min(101,w.percent+0.08*scale)
  else
   w.percent=max(0,w.percent-0.08*scale)
  end
  
 elseif w.kind=="files" then
  for f=1,#w.files do
   w.files[f].percent=max(0,w.files[f].percent-w.files[f].rate*scale/100)
  end
  
 elseif w.kind=="censor" then
  local any_painting=false
  for i=1,#w.blocks do
   local b=w.blocks[i]
   if w==mouseover and dragging==nil
   and in_rect(mx,my,w.x+1+b.x,w.y+1+title_height+b.y,b.w-1,b.h-1)
   and not b.done then
    --paint into censor slot
    local sx=b.col*censor_width+mx-w.x-1-b.x
    local sy=64+1+b.row*censor_height+my-w.y-2-title_height-b.y
    sset(sx,sy,0)
    sset(sx+1,sy,0)
    sset(sx-1,sy,0)
    sset(sx,sy+1,0)
    sset(sx,sy-1,0)
    any_painting=true
    
    --sfx
    if not playing_sfx_censor then
     playing_sfx_censor=true
     sfx(sfx_censor,channel_loop)
    end
    
    --calculate if done
    sx=b.col*censor_width
    sy=64+b.row*censor_height
    local painted=0
    for x=0,b.w-1 do
     for y=0,b.h-1 do
      if sget(sx+x,sy+y)==0 then
       painted+=1
      end
     end
    end
    b.done=(painted==b.w*b.h)
    if(b.done)w.num_done+=1
    break
   end
  end
  if w==mouseover and not any_painting and playing_sfx_censor then
   playing_sfx_censor=false
   sfx(-2,channel_loop)
  end
  if w.num_done<#w.blocks then
   w.percent=max(0,w.percent-0.05*scale)
  end
  
 elseif w.kind=="balance" then
  w.percent=max(0,w.percent-0.03*scale)
  
 elseif w.kind=="process" then
  w.percent=max(0,w.percent-0.04*scale)
 end
end

function button_click(w,b)
 if w.kind~="map" then
  sfx(sfx_click)
 end
 
 if w.kind=="email" then
  --only one button: —
  email_open=false
  if w.email==3 then
   --progress to next day
   fade_dir=1
  elseif w.email==4 then
   --reset after game over
   fade_dir=1
  else
   add_random_window(true)
  end
  remove_window(w)
  next_task_clock=new_task_clock()
  w_start=-1
 end
 if(email_open)return
 
 if w.kind=="click" then
  --only one button: refuel
  w.percent=min(101,w.percent+10)
  
 elseif w.kind=="balance" then
  if(b.str=="+$100")w.current+=100
  if(b.str=="+$200")w.current+=200
  if(b.str=="+$500")w.current+=500
  if(b.str=="-$100")w.current-=100
  if(b.str=="-$200")w.current-=200
  if(b.str=="-$500")w.current-=500
  if w.current==w.target then
   complete_task(w)
  end
  
 elseif w.kind=="process" then
  if b.str=="ˆ" then
   if not match(w.watch,w.people[1]) then
    w.wrong+=1
    sfx(sfx_wrong)
   else
    sfx(sfx_right)
   end
  elseif b.str=="™" then
   if not match(w.jail,w.people[1]) then
    w.wrong+=1
    sfx(sfx_wrong)
   else
    sfx(sfx_right)
   end
  elseif b.str=="Š" then
   if match(w.watch,w.people[1]) or match(w.jail,w.people[1]) then
    w.wrong+=1
    sfx(sfx_wrong)
   else
    sfx(sfx_right)
   end
  end
  del(w.people,w.people[1])
  if #w.people==0 then
   complete_task(w)
  end
 end
end

function button_hold(w,b)
 if(email_open)return
 
 if w.kind=="map" then
  local spd=0.2
  if(b.str=="”")w.pan_y=max(0,w.pan_y-spd)
  if(b.str=="ƒ")w.pan_y=min(20,w.pan_y+spd)
  if(b.str=="‹")w.pan_x=max(0,w.pan_x-spd)
  if(b.str=="‘")w.pan_x=min(20,w.pan_x+spd)
  if not playing_sfx_scroll then
   playing_sfx_scroll=true
   sfx(sfx_scroll,channel_loop)
  end
 end
end

function complete_task(w)
 remove_window(w)
 completed_today+=1
 completed_total+=1
 w_start=-1
 f_start=-1
 sfx(sfx_complete)
 
 --if you complete something and
 --now there's nothing to do,
 --reduce timer dramatically
 if #windows==0 and clock<clock_end then
  local d=next_task_clock-clock
  local d2=15+flr(rnd(15))
  if(d>d2)next_task_clock=clock+d2
 end
end

function _draw()
 pal()
 palt()
 
 --screen fade
 for i=0,15 do
  pal(i,sget(32+pal_idx,8+i))
 end
 
 --cls
 rectfill(0,0,127,127,1)
 
 --draw icons
 for i=1,#icons do
  sspr(icons[i].sx,icons[i].sy,16,16,icons[i].x,icons[i].y)
  --local w=4*#icons[i].name
  --print(icons[i].name,icons[i].x+8-0.5*w,icons[i].y+17,7)
 end
 
 --draw windows
 for i=1,#windows do
  draw_window(windows[i])
 end
 
 draw_tray()
 
 --draw cursor
 if dragging=="icon" then
  sspr(icons[i_start].sx,icons[i_start].sy,16,16,icons[i_start].x,icons[i_start].y)
 elseif dragging=="file" then
  draw_file(windows[w_start],windows[w_start].files[f_start])
 end
 palt(0,false)
 palt(15,true)
 spr(1,mx-1,my-1)
 
 --debug_draw()
end

function draw_window(w)
 local l,r=w.x,w.x+w.w--left/right
 local t,b=w.y,w.y+w.h--top/bottom
 
 --window and title
 rect(l,t,r,b,0)
 l+=1 t+=1 r-=1 b-=1
 local bc=6
 if(w==windows[#windows])bc=7
 rectfill(l,t,r,b,bc)
 rectfill(l,t,r,t+title_height-1,5)
 print(w.title,l+1,t+1,bc)
 if w.kind=="email" then
  print("- day "..day,l+25,t+1,bc)
 end
 
 --buttons
 t+=title_height
 local x,y,wd,h
 for i=1,#w.buttons do
  local b=w.buttons[i]
  bc=13
  if w==mouseover and dragging==nil
  and in_rect(mx,my,l+b.x,t+b.y,b.w,b.h) then
   bc=14
  end
  rectfill(l+b.x,t+b.y,l+b.x+b.w,t+b.y+b.h,bc)
  print(b.str,l+b.x+1,t+b.y+1,7)
 end
 
 --custom per window type
 if w.kind=="click" then
  draw_bar(w,1,1,25,7,w.percent)

 elseif w.kind=="map" then
  --map
  rectfill(l+2,t+1,l+27,t+26,0)
  clip(l+3,t+2,24,24)
  sspr(96+w.pan_x,0+w.pan_y,12,12,l+3,t+2,24,24)
  --target
  local x,y=map_to_screen(w)
  rect(x,y,x+1,y+1,8)
  --compass
  if not w.visible then
   local cx,cy,length=l+13,t+13,7
   local dx,dy=x-cx,y-cy
   local ang=atan2(dx,dy)
   local endx,endy=cx+cos(ang)*length,cy+sin(ang)*length
   line(cx,cy,endx,endy,14)
   pset(endx,endy,8)
  end
  clip()
  draw_bar(w,3,28,24,7,w.percent)
  
 elseif w.kind=="files" then
  print("sensitive files",l+1,t+1,8)
  print("please dispose",l+3,t+7,8)
  for f=1,#w.files do
   draw_file(w,w.files[f])
  end
  
 elseif w.kind=="censor" then
  draw_bar(w,1,35,50,4,w.percent)
  rectfill(l+1,t+1,l+50,t+33,15)
  for i=1,#w.text do
   spr(w.text[i].s,l+2+w.text[i].x,t+1+w.text[i].y)
  end
  palt(0,false)
  palt(10,true)
  for i=1,#w.blocks do
   local b=w.blocks[i]
   sspr(b.col*censor_width,
    64+b.row*censor_height,
    b.w,b.h,w.x+1+b.x,w.y+1+title_height+b.y)
   if not w.blocks[i].done then
    rect(l+b.x-1,t+b.y-1,l+b.x+b.w,t+b.y+b.h,8)
   end
  end
  palt()
  
 elseif w.kind=="balance" then
  dollar(w.target,l+7,t+2,2)
  dollar(w.current,l+37,t+2,8)
  draw_bar(w,1,9,65,4,w.percent)
  
 elseif w.kind=="process" then
  line(l+32,t+1,l+32,t+21,5)
  print("ˆ",l+34,t+1,0)
  line(l+32,t+7,l+60,t+7,5)
  print("™",l+34,t+9,0)
  line(l+32,t+15,l+60,t+15,5)
  print("Š",l+34,t+17,0)
  print("other",l+42,t+17,13)
  draw_person(w.watch,l+42,t+1)
  draw_person(w.jail,l+42,t+9)
  rect(l+10,t+1,l+20,t+13,5)
  draw_person(w.people[1],l+12,t+3)
  if #w.people>1 then
   draw_person(w.people[2],l+1,t+3)
  end
  for i=0,2 do
   rectfill(l+39+i*6,t+24,l+42+i*6,t+27,2)
   local c=11
   if(w.wrong>=i+1)c=8
   rect(l+40+i*6,t+25,l+41+i*6,t+26,c)
  end
  draw_bar(w,1,24,29,4,w.percent)
  
 elseif w.kind=="email" then
  rectfill(l,t,l+w.w-2,t+8,6)
  print(emails[w.email][1],l+2,t+2,0)
  for i=2,#emails[w.email] do
   local text=emails[w.email][i]
   local x,y=l+3,t+11+7*(i-2)
   if text=="@@@" then
    draw_responsibilities(x,y)
   elseif text=="job" then
    print("rank:",x,y,0)
    print(jobs[rank],x+24,y,12)
   elseif text=="completed_today" then
    print(" "..completed_today.." task"..s(completed_today).." completed",x,y,3)
   elseif text=="maintained_today" then
    print(" "..maintained_today.." task"..s(maintained_today).." maintained",x,y,3)
   elseif text=="failed_today" then
    print(" "..failed_today.." task"..s(failed_today).." failed",x,y,8)
   elseif text=="overtime_today" then
    print(" "..(clock-clock_end).." min"..s(clock-clock_end).." unpaid overtime",x,y,8)
   elseif text=="days" then
    print("you worked for "..day.." day"..s(day),x,y,0)
   elseif text=="completed_total" then
    print(" "..completed_total.." task"..s(completed_total).." completed",x,y,3)
   elseif text=="maintained_total" then
    print(" "..maintained_total.." task"..s(maintained_total).." maintained",x,y,3)
   elseif text=="failed_total" then
    print(" "..failed_total.." tasks failed",x,y,8)
   elseif text=="overtime_total" then
    print(" "..overtime_total.." min"..s(overtime_total).." unpaid overtime",x,y,8)
   else
    print(text,x,y,0)
   end
  end
 end
end

function s(n) --for plural strings
 if(n==1)return ""
 return "s"
end

function draw_person(p,x,y)
 if p.body then
  print(p.body,x,y+4,p.col)
 end
 print(p.head,x,y,p.col)
end

function dollar(d,x,y,c)
 local s="$"..abs(d)
 if(d<0)s="-"..s
 print(s,x,y,c)
end

function draw_file(w,f)
 local l,t=w.x+1,w.y+1+title_height
 sspr(16,16,16,16,w.x+1+f.x,t+f.y)
 draw_bar(w,f.x-1,f.y+15,11,4,f.percent)
end

function draw_bar(w,x,y,wd,h,percent)
 local l,t=w.x+1,w.y+1+title_height
 rect(l+x,t+y,l+x+wd-1,t+y+h-1,2)
 bc=8+flr((percent-0.5)/25)
 if percent>0 then
  rectfill(l+x+1,t+y+1,
  l+x+1+(wd-3)*(percent/100),
  t+y+h-2,bc)
 end
end

function map_to_screen(w)
 local x=w.x+2+w.cur_x-2*flr(w.pan_x)
 local y=w.y+title_height+2+w.cur_y-2*flr(w.pan_y)
 return x,y
end

function draw_tray()
 rectfill(0,121,127,127,5)
 
 local tw=(107-#windows)/#windows
 local x,y=1,0
 local ti=1
 while ti<=#windows do
  for i=1,#windows do
   local w=windows[i]
   if w.tray_index==ti then
    clip()
    local bc=6
    if(i==#windows)bc=7
    
    --click tray to pick window
    if in_rect(mx,my,flr(x),121,tw-1,6) then
     if(dragging==nil)bc=15
     if click() then
      bring_to_front(i)
      sfx(sfx_click)
     end
    end
    
    rectfill(x,121,x+tw-1,127,bc)
    clip(x,122,tw,5)
    print(w.title,x+1,122,13)
    
    x+=tw+1
    break
   end
  end
  ti+=1
 end
 clip()
 
 --today fails
 x,y=111,115
 for i=0,2 do
  rectfill(x+i*6,y,x+3+i*6,y+3,2)
  local c=11
  if(failed_today>=i+1)c=8
  rect(x+1+i*6,y+1,x+2+i*6,y+2,c)
 end
 
 --clock
 local c=7
 if(clock>clock_end)c=8
 print(get_time_str(),108,122,c)
end

function debug_draw()
 rectfill(0,0,128,4,14)
 local d="nil"
 if(dragging~=nil)d=dragging
 print("x"..mx
 .." y"..my
 .." b"..mb
 .." d"..d
 .." c"..clock
 .." n"..next_task_clock
 .." "..min_clock_per_task.."-"..max_clock_per_task
 ,0,0,7)
end

function calc_maintained()
 local maintained=0
 for i=1,#windows do
  if windows[i].kind=="click"
  or windows[i].kind=="map" then
   maintained+=1
  end
 end
 return maintained
end

function click()
 return band(pmb,1)==0 and
  band(mb,1)==1
end

function release()
 return band(pmb,1)==1 and
  band(mb,1)==0
end

function held()
 return band(mb,1)==1
end

function get_time()
 local hour=9+flr(clock/60)
 local minute=clock%60
 return hour,minute
end

function get_time_str()
 local h,m=get_time()
 if(h<10)h="0"..h
 if(m<10)m="0"..m
 return h..":"..m
end

function in_rect(px,py,x,y,w,h)
 if(px<x)return false
 if(px>x+w)return false
 if(py<y)return false
 if(py>y+h)return false
 return true
end

function in_title(x,y,w)
 return in_rect(x,y,w.x,w.y,w.w,title_height-1)
end

function in_window(x,y,w)
 return in_rect(x,y,w.x,w.y,w.w,w.h)
end
__gfx__
00000000f0ffffff0000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff33333333335555555555555555533333
00000000070fffff0000000000000000f5fff55fffffff5ffff5fffff5fff5fffff5fff5fff5ff5ff5fffffffff5ff5f33333333355555555555555555553333
007007000770ffff0000000000000000f5f5f5f5f55f5f5ff55f55ff5f55f5fff55ff5f5f5f5ff5ff55ff5f55f5f5f5f33333333555555533333555555553333
0007700007770fff0000000000000000ff5f5fff55fff5ffff5fff5f55ff5f5fffff55fff5fff5ffff55fff5fff5f5ff66333335555555533333363355555333
00077000077770ff0000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff36663555555555553333363333555533
0070070007700fff0000000000000000f5fffff5fff5fffff5fffffff5ffffffffff5ffff5f55ffffff5ffffff55ffff33366555553355555333663333555555
00000000f0070fff0000000000000000ff5f5f55f5f5f5fff5ff55f5f5f5555fff5f5ff5f55f5f5ff5f5ff55ff5f5f5f33335555533355553333633333555555
00000000ffffffff0000000000000000ff5f55ff5ff5ff5fff5f5fffff5f5ffff5ff5f5ffff5ffffffff5fff5ff55fff33335555333335553333633333555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033335555333335533333633335555335
00000000000000000000000000000000111111100000000000000000000000000000000000000000000000000000000033355553333335533336333335553333
00000000000000000000000000000000222222111000000000000000000000000000000000000000000000000000000033355553333335553335533355533333
00000000000000000000000000000000333333111000000000000000000000000000000000000000000000000000000033555533333365555555555555533333
00000000000000000000000000000000444222221100000000000000000000000000000000000000000000000000000035555333333663555555555553333333
00000000000000000000000000000000555551111100000000000000000000000000000000000000000000000000000055555333333633355555555533333333
0000000000000000000000000000000066dddd555511100000000000000000000000000000000000000000000000000055566663336633333555533333333333
0000000000000000000000000000000076666ddd5551100000000000000000000000000000000000000000000000000055533336666333333555533333366666
00000dddd00000009994444000000000888822222200000000000000000000000000000000000000000000000000000055333333336633333355553333363333
00ddd6666ddd000099999fff00000000999444444550000000000000000000000000000000000000000000000000000055333333333363333355553333663333
0d6666666666d0009999999ff0000000aa9994445555000000000000000000000000000000000000000000000000000055333333333363333355556336633333
d666666666666d009559999ff0000000bbb333333300000000000000000000000000000000000000000000000000000055333333333363333355556666333333
dd6666666666dd009995599ff0000000ccccc3311111100000000000000000000000000000000000000000000000000055533333333363355555553336633333
ddddd6666ddddd009999999ff0000000ddd555511111000000000000000000000000000000000000000000000000000055553333333335555555553333633333
dddddddddddddd009559999ff0000000eeed44222221100000000000000000000000000000000000000000000000000055553335555555555555533333663335
0ddd88dd88ddd0009995599ff0000000ff6ddd555551100000000000000000000000000000000000000000000000000055555555555555555555333333335555
0ddd88dd88ddd0009999999ff0000000000000000000000000000000000000000000000000000000000000000000000035555555555555333555333333555555
0ddddd88ddddd0009999999ff0000000000000000000000000000000000000000000000000000000000000000000000035555555555333333555533335555555
00dddd88dddd00009999999ff0000000000000000000000000000000000000000000000000000000000000000000000033555553355533333555555555555555
00dd88dd88dd00009999999ff0000000000000000000000000000000000000000000000000000000000000000000000033655333355533333355555555533333
00dd88dd88dd000000999990f0000000000000000000000000000000000000000000000000000000000000000000000033633333355533333335555533333333
00dddddddddd00000000099000000000000000000000000000000000000000000000000000000000000000000000000033633333335533333363555333333333
000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000033663333335533333663355333333333
0000dddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000033363333335553336633355533333333
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
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c0c0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c0cccccccccccccccccccccccccccccccccccccccccccccccccccccc0000cccccccccccc000c000ccccccccccccccccccccccccccccccccccccccccccccccccc
c0cccccccccccccccccccccccccccccccc0000cccccccccccccccccc0cccccc0000cccc00ccc0cc0cccccccccccccccccccccccccccccccccccccccccccccccc
c0cccccc00ccc0000ccccccccccccccccc0cccccc00000ccc0000ccc0000ccc0ccc0cc0cccc00ccccccccccccccccccccccccccccccccccccccccccccccccccc
00000cc0cc0cc0cccccccccccccccccccc0cccccc0cc00ccc0cc0cccccc0ccc0ccc0cc0cccc00ccccccccccccccccccccccccccccccccccccccccccccccccccc
c0ccccc0cc0cc0cccccccccccccccccccc0cccccc000ccccc0cc0cccccc0ccc0ccc0cc0ccccc000ccccccccccccccccccccccccccccccccccccccccccccccccc
c0ccccc0cc0cc0cccccccccccccccccccc000cccc00cccccc0cc0ccc0000ccc00c00cc00cccccc0ccccccccccccccccccccccccccccccccccccccccccccccccc
c0cccccc00ccc0cccccccccccccccccccccc00cccc00c0cccccccccccccccccc000cccc0ccccc00ccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccc000ccccccccccccccccccccccccccccc000cccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c0c0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c0cccccccccccccccccccccccccccccccccccccccccccccccccccccc0000cccccccccccc000c000ccccccccccccccccccccccccccccccccccccccccccccccccc
c0cccccccccccccccccccccccccccccccc0000cccccccccccccccccc0cccccc0000cccc00ccc0cc0cccccccccccccccccccccccccccccccccccccccccccccccc
c0cccccc00ccc0000ccccccccccccccccc0cccccc00000ccc0000ccc0000ccc0ccc0cc0cccc00ccccccccccccccccccccccccccccccccccccccccccccccccccc
00000cc0cc0cc0cccccccccccccccccccc0cccccc0cc00ccc0cc0cccccc0ccc0ccc0cc0cccc00ccccccccccccccccccccccccccccccccccccccccccccccccccc
c0ccccc0cc0cc0cccccccccccccccccccc0cccccc000ccccc0cc0cccccc0ccc0ccc0cc0ccccc000ccccccccccccccccccccccccccccccccccccccccccccccccc
c0ccccc0cc0cc0cccccccccccccccccccc000cccc00cccccc0cc0ccc0000ccc00c00cc00cccccc0ccccccccccccccccccccccccccccccccccccccccccccccccc
c0cccccc00ccc0cccccccccccccccccccccc00cccc00c0cccccccccccccccccc000cccc0ccccc00ccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccc000ccccccccccccccccccccccccccccc000cccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
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
000400002a05025050220501b05015050100500c05005750047500475025000000002800000000290002a0002a0002a0000000000000000000000000000000000000000000000000000000000000000000000000
00030000137700f7700b7700a77003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001b7501a750237502c75039000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000010172007700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
001000010161000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0102000026750267502b7502b7502b7502d7502d7502d750317503175034750117003772037720090002d0002d700317003170034700117003770037700397003c7003c700297002e70035700397003f70000700
000300002875028750267002d700327503372034720347003e700367000070000700007000070000700007003e700367000070000700007000070000700007002870027700267002d70034700327003370034700
0001000018521235002b5002550027500005000050000500005002850000500005000050000500005002850000500005000050000500005000050000500005000050000500005000050024500005000050000500
000200001e6301c6201b6201b61000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000137300f7200b7200a70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000150301a0301d030220302603028030280302803028030170001c0002100026000270002800028000150301a0301d030220302603028030280302803028030280002a0002c0002d0002e0002f00030000
000200000c0501205015050180501805016050120500b0500b0500c0500d0500d0500f0501305018050190501805015050110500e0500d0500f0501005014050190501a0501905014050110500c0500705004050
000200002805028050280502805020050200502005020050180501805018050180501005010050100501005009050090500905009050030500305003050030500700007000070000700007000070000700007000
011000000c0530800300000000000c0530000000000000000c0530000000000000000c0530000000000000000c0530000000000000000c0530000000000000000c0530000000000000000c053000000000000000
000300003075030750000000000035750357500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
