pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
px,py,pd,mx,my,xo,yo,pdir,psb,spawn_v,php,pmhp,state,ticks,t_amt,mdx,mdy,lmx,tmy,cmx,cmy,cmd,pf,bg,level,pflp,pmove,patk_ticks = 51,64,1.5,0,0,0,0,2,67,0,2,2,10,0,0,0,0,0,0,128,96,8,0,7,0,false,false,0
patk_sp,patk_spd,pax,pay,paflp,phticks,pinhit,pldx,pldy,pc,pdmg,pdef,global_flag,global_x,global_y,inv_sel,inv_ticks = 80,6,0,0,false,0,0,0,0,0,1,0,0,0,0,0,0
global_spawn,gold,num_keys, btn4_ticks,num_deaths,game_time,gticks = 0,0,0,0,0,0,0
messages,curr_msg,en,em,special,spec,item,u_item,title,titlex,dcol = {},nil,{},{},{},{}, {1,1,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0},{"overworld","sewers","catacombs","cave","fire tomb","sea cavern","castle"},{12,20,24,12,12,4,18},{3,1,12,2,13,6}
pdx,pdy,pac = 0,0,0.25
em[0],special[0] = "06:2:7|00:0:0|00:0:0,07:3:6|02:2:7|00:0:0,15:2:6|01:3:7|00:0:0,25:1:0|01:2:6|00:0:0,10:1:7|01:2:6|00:0:0,01:3:6|16:1:7|00:0:0,01:3:6|16:2:7|00:0:0,09:1:0|01:1:6|00:0:0,07:3:6|01:3:7|00:0:0,25:1:0|01:1:6|00:0:0,25:1:0|01:1:6|15:1:7,01:2:6|15:2:7|00:0:0,30:2:6|00:0:0|00:0:0,30:1:6|00:0:0|00:0:0,10:2:7|01:3:6|00:0:0,07:2:7|01:3:6|00:0:0,24:2:7|15:3:6|00:0:0,24:2:7|15:2:6|00:0:0,01:3:6|15:1:7|00:0:0,27:4:6|28:2:7|00:0:0,30:3:6|11:1:7|00:0:0,10:3:6|01:3:7|00:0:0,01:3:6|00:0:0|00:0:0,24:2:7|01:1:6|00:0:0,24:2:7|15:2:6|00:0:0,10:3:6|01:1:7|00:0:0,24:1:7|12:2:6|00:0:0,25:1:7|38:3:6|00:0:0,10:2:7|27:4:6|00:0:0,27:1:6|24:1:7|00:0:0,24:2:7|01:2:6|00:0:0,24:2:7|01:2:6|00:0:0,24:2:7|15:2:6|00:0:0,24:1:7|36:2:6|00:0:0,36:3:6|33:1:7|00:0:0", "38:00:00,001,018|25:05:02,002,002|26:04:02,001,020|25:07:02,001,015|25:02:05,009,020|26:04:00,018,028|25:01:02,009,030|25:01:07,010,030|25:05:00,009,029|26:04:00,033,010|25:06:01,046,003|25:05:02,017,022|25:01:02,018,022|25:07:01,019,022|28:06:00,017,022|25:05:01,005,041|25:02:01,006,041|25:02:02,007,041|30:00:00,025,046|31:00:00,026,047|25:06:02,025,056|25:02:02,025,033|28:05:00,017,025|32:00:00,077,054|29:00:00,077,045|29:00:00,078,026|33:00:00,108,013|34:00:00,083,055|25:02:06,038,046|25:07:02,053,040|26:06:06,045,021|25:02:06,043,040|35:00:00,041,027|25:06:02,054,029|36:00:00,061,013|29:00:00,061,019|28:05:00,060,034|25:02:02,069,044|25:05:00,081,034|25:06:00,070,005|25:05:06,059,021|28:05:00,110,038|25:05:00,086,046|25:05:05,090,057|25:02:02,102,045|25:02:02,103,045|25:02:02,102,046|25:02:02,103,046|25:02:02:078,021|25:02:01,082,010|37:00:00,009,006"
em[1],special[1] = "10:4:7|03:4:6|00:0:0,22:1:0|03:4:7|01:1:0,02:3:6|03:2:7|00:0:0,00:0:0|00:0:0|00:0:0,19:1:0|02:2:6|03:2:7,00:0:0|00:0:0|00:0:0,11:2:7|01:2:6|00:0:0,10:2:7|01:2:6|00:0:0,10:4:7|01:1:6|00:0:0,03:4:6|22:1:0|00:0:0,10:2:7|01:2:6|03:1:6,50:1:0|02:2:6|03:2:7,19:1:0|02:2:6|00:0:0,10:2:7|03:2:6|00:0:0,11:4:7|01:2:6|00:0:0,02:1:6|10:4:7|03:1:6,19:1:0|03:4:6|00:0:0,00:0:0|00:0:0|00:0:0,03:4:6|00:0:0|00:0:0,02:3:6|11:2:7|00:0:0,03:4:6|01:2:7|18:1:0,10:1:7|11:1:7|03:2:0,11:3:7|02:2:6|00:0:0,02:2:6|03:4:7|11:1:0", "25:01:00,001,040|25:01:02,001,049|27:00:00,022,047|27:00:00,021,047|27:00:00,019,047|25:02:02,022,048|25:05:01,026,045|25:02:01,040,049|27:00:00,053,043|25:07:00,058,027|25:05:01,076,027|25:02:00,075,027|25:02:01,082,040|26:04:00,095,045|26:05:01,030,031|25:02:02,042,035|25:01:01,035,018|27:00:00,037,010|25:06:00,035,008|25:07:00,018,001|25:01:00,031,001|27:00:00,013,007|25:01:01,001,022|25:02:01,065,014|25:01:01,052,023|25:02:00,082,005|25:02:05,069,005|25:02:02,075,001" 
em[2],special[2] = "04:4:6|28:2:7|00:0:0,11:2:7|10:2:7|03:1:6,11:1:7|28:4:6|00:0:0,11:2:7|28:2:6|00:0:0,19:1:0|28:4:7|01:2:6,51:1:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,22:1:0|02:4:7|27:1:0,28:5:7|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,28:1:0|11:2:7|04:1:6,10:2:7|04:2:6|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,02:4:6|00:0:0|00:0:0,10:1:7|11:3:7|02:1:6,04:4:6|27:2:7|00:0:0,19:1:0|11:1:7|00:0:0,11:2:7|28:1:6|00:0:0,28:3:7|02:2:6|00:0:0", "25:06:00,001,040|26:06:02,064,005|25:07:00,001,001|25:07:00,099,040|26:04:00,035,014|25:01:02,035,040|25:05:01,048,049|25:02:02,075,049|25:02:02,069,040|25:02:01,064,028|28:06:00,064,018|25:01:02,053,018|25:02:02,018,010|25:02:01,019,010|25:02:02,025,001|25:05:02,001,010|25:06:00,069,001"
em[3],special[3] = "00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,19:1:0|12:1:7|03:2:7,33:3:7|33:3:6|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,33:2:6|04:2:6|15:1:7,18:1:0|16:2:6|00:0:0,12:2:6|00:0:0|00:0:0,10:1:7|12:2:6|00:0:0,12:1:6|02:2:6|00:0:0,28:2:7|12:2:6|00:0:0,10:2:7|02:2:6|00:0:0,03:4:6|22:1:0|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,12:2:6|10:1:7|00:0:0,11:3:7|01:1:6|00:0:0,33:2:6|00:0:0|00:0:0,01:2:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,33:4:6|00:0:0|00:0:0,52:1:0|00:0:0|00:0:0", "25:06:00,001,044|26:02:00,013,044|27:00:00,013,033|25:02:00,001,023|25:07:00,001,014|25:02:00,014,014|27:00:00,036,017|25:02:02,035,001|25:06:00,081,018|26:02:00,076,035|27:00:00,054,010|25:05:00,070,048|25:07:00,091,014|25:02:02,026,044|25:02:02,025,044|25:02:02,026,045|25:02:02,025,045|25:02:02,031,044|25:02:02,031,045" 
em[4],special[4] = "00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,20:1:0|28:4:6|03:2:7,53:1:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,16:1:6|02:2:6|00:0:0,10:2:7|30:4:6|00:0:0,34:4:6|10:1:7|00:0:0,10:2:7|11:2:7|00:0:0,02:2:0|31:2:6|00:0:0,16:1:6|04:3:6|00:0:0,12:2:6|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,31:4:6|03:4:7|00:0:0,31:2:6|00:0:0|00:0:0,01:2:0|30:2:6|00:0:0,31:4:6|10:2:7|00:0:0,11:1:7|33:2:6|00:0:0,22:1:0|31:4:6|01:2:7,10:1:7|12:1:6|16:1:6", "25:01:05,001,040|25:02:02,014,040|26:06:00,058,015|25:05:02,099,049|25:02:01,001,032|25:02:00,001,018|25:05:00,048,023|25:07:00,041,001|25:02:01,042,001|25:02:00,026,045|25:02:02,026,044|25:01:01,058,049|25:02:02,069,049|28:02:02,096,016|28:02:01,098,016|27:00:00,081,017|25:06:00,082,014|25:07:00,056,032|25:05:00,052,018|27:00:00,090,034|27:00:00,091,034|27:00:00,092,034|27:00:00,093,034|27:00:00,094,034|27:00:00,095,034|26:04:00,041,049"
em[5],special[5] = "31:3:6|10:1:7|00:0:0,34:2:6|11:1:7|00:0:0,11:2:7|28:1:6|00:0:0,33:2:7|12:1:6|31:1:6,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,11:2:7|00:0:0|00:0:0,14:1:6|34:4:7|13:2:6,22:1:0|28:2:6|04:2:6,10:1:7|33:1:6|04:2:6,13:2:6|05:4:7|33:1:6,00:0:0|00:0:0|00:0:0,13:1:7|05:4:6|00:0:0,12:1:6|30:3:6|00:0:0,31:2:6|02:2:6|00:0:0,11:1:7|10:1:7|30:1:6,54:1:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,13:2:6|02:2:6|00:0:0,01:2:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0","25:00:05,001,040|25:01:00,014,036|27:00:00,007,018|27:00:00,008,018|27:00:00,007,019|27:00:00,008,019|25:02:00,004,017|25:07:00,031,036|25:02:00,018,036|25:01:00,031,027|25:02:02,009,005|25:02:02,009,006|25:01:00,028,003|25:02:00,021,008|25:05:00,048,001|25:01:00,035,010|26:00:00,048,018|27:00:00,047,018|27:00:00,047,019|27:00:00,047,020|27:00:00,048,020|27:00:00,036,030|25:07:00,053,002|28:06:00,065,002|26:04:00,082,021|26:02:00,058,030|28:05:00,052,036|25:07:00,024,036"
em[6],special[6] =  "00:0:0|00:0:0|00:0:0,00:0:0|00:0:0|00:0:0,23:1:0|05:4:6|00:0:0,29:2:7|31:2:6|31:2:7,38:4:6|00:0:0|00:0:0,55:1:0|00:0:0|00:0:0,35:2:6|14:1:6|37:1:6,10:1:7|32:4:6|00:0:0,37:4:6|00:0:0|00:0:0,12:1:6|02:2:6|00:0:0,38:4:6|16:1:0|00:0:0,13:1:6|14:1:6|16:1:6,37:3:6|00:0:0|00:0:0,32:4:6|00:0:0|00:0:0,37:2:6|13:2:7|00:0:0,37:4:6|10:1:7|00:0:0,32:4:6|14:1:7|00:0:0,02:3:7|05:3:6|00:0:0,05:4:6|05:4:7|00:0:0,11:1:7|37:4:6|00:0:0,00:0:0|00:0:0|00:0:0,35:2:7|37:2:7|00:0:0,32:2:6|11:1:7|00:0:0,11:1:7|38:4:6|00:0:0", "25:05:00,031,042|25:01:02,018,036|25:02:02,031,027|25:02:02,009,031|25:07:00,001,014|25:01:00,001,023|25:01:00,014,023|25:01:00,014,014|25:05:00,025,014|25:01:00,024,023|27:00:00,055,010|25:05:00,052,001|27:00:00,045,027|25:07:00,047,027|26:05:00,059,033|27:00:00,061,040|27:00:00,060,041|27:00:00,059,042|27:00:00,058,043|27:00:00,057,044|27:00:00,056,045|27:00:00,062,044|27:00:00,062,045|27:00:00,062,046|27:00:00,087,043|25:07:00,086,027|25:01:00,099,027|27:00:00,080,027|28:06:00,082,029|26:00:00,075,017|25:01:00,035,005|25:06:00,099,014|25:02:02,064,040|26:05:00,081,005"
exits,gstate,store = {},{},{{5,6,30,80},{6,11,80,150},{6,10,75,275},{6,12,80,300},{5,6,25,70},{6,16,75,350}}
exits["l0131"],exits["l-1811"],exits["l0461"],exits["l-2811"],exits["l04342"],exits["l-3811"],exits["l07745"],exits["l-4811"],exits["l0511"],exits["l-5811"],exits["l09425"],exits["l-6811"],exits["l0741"],exits["l1850"],exits["l0353"],exits["l2850"],exits["l07056"],exits["l3850"],exits["l09817"],exits["l4850"],exits["l57637"],exits["l04320"],exits["l5850"],exits["l010953"],exits["l6850"] = {-1,0,0},{0,103,49},{-2,0,0},{0,356,40},{-3,0,0},{0,344,376},{-4,0,0},{0,607,392},{-5,0,0},{0,408,49},{-6,0,0},{0,752,241},{1,0,0},{0,46,360},{2,0,0},{0,24,464},{3,0,0},{0,568,480},{4,0,0},{0,792,167},{0,344,201},{5,0,0},{0,344,201},{6,0,0},{0,872,463}

function add_message(txt,tics)
  if (tics == nil) tics = 50
  msg = {}
  msg.txt,msg.ticks,msg.x = txt,tics,(128 - #txt*4)/2
  add(messages,msg)
end

function add_message_nil(txt,tics)
  if curr_msg == nil then
    add_message(txt,tics)
    return true
  end
  return false
end

function reset_map(xx,yy,ce)
  reload(0x1000,0x1000,0x2000)
  px,py,level,mx,my = xx,yy,0,flr(xx / 128),flr((yy-32) / 96)
  lmx,tmy,cmx,cmy,cmd,bg = mx * 128,my*96,128,96,8,7
  if (ce) load_map_enemies(0)
  load_special(0)
  spawn_enemies(mx,my,0)
  music(-1)
end

function save_p()
  dset(0,gold)
  dset(1,num_keys)
  dset(2,pmhp)
  dset(3,php)
  dset(4,num_deaths)
  dset(5,game_time)
  dset(6,gticks)
  for i = 1,10 do
    dset(7+i,u_item[i])
  end
  for i = 1,8 do
    dset(17+i,item[i])
  end
  local ds = 26
  for i = 0,6 do
    local bv = 0
    for j = 0,15 do
      bv += gstate[i][j] * (2^j)
    end
    dset(ds,bv)
    bv = 0
    ds += 1
    for j = 0,15 do
      bv += gstate[i][j+16] * (2^j)
    end
    dset(ds,bv)
    ds += 1
  end
end

function load_p()
  gold, num_keys,pmhp,php,num_deaths,game_time,gticks = dget(0),dget(1),dget(2),dget(3),dget(4),dget(5),dget(6)
  
  for i = 1,10 do
    u_item[i] = dget(7+i)
  end
  for i = 1,8 do
    item[i] = dget(17+i)
  end
  
  local ds = 26
  for i = 0,6 do
    local v = dget(ds)
    for j = 0,15 do
      local bv = 2^j
      if band(v,bv) == bv then
        gstate[i][j] = 1
      else
        gstate[i][j] = 0
      end
    end
    ds += 1
    v = dget(ds)
    for j = 0,15 do
      local bv = 2^j
      if band(v,bv) == bv then
        gstate[i][j+16] = 1
      else
        gstate[i][j+16] = 0
      end
    end
    ds += 1
  end
end

function init_game(call_car,res)
  for i = 0,6 do
    gstate[i] = {}
    for j = 0,31 do
      gstate[i][j] = 1
    end
  end
  if res then
    item,u_item = {1,1,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0}
    gold,num_keys,num_deaths,game_time,gticks,php,pmhp = 0,0,0,0,0,2,2
    save_p()
  end
  if call_car then
    if not cartdata("strayvoltage_rpg_1") then
      save_p()
    end
  end
  --save_p() --remove to save proper
  load_p()
  if (php < 3) php = min(4,pmhp)
  
  pdir,pf,bg,level,pflp,pmove,patk_ticks,patk_sp,patk_spd,pax,pay,paflp,phticks,pinhit,state,pldx,pldy,pc,pdmg,pdef,global_flag,global_x,global_y,inv_sel,inv_ticks = 2,0,7,0,false,false,0,80,6,0,0,false,0,0, 10,0,0,0,1,0,0,0,0,0,0

  reset_map(32,48,true)
  --reset_map(30,360,true) --d1
  --reset_map(25,470,true) --d2
  --reset_map(570,480,true) --d3
  --reset_map(875,465,true) -- d6
  --reset_map(350,198,true) --d5
  --reset_map(800,160,true) -- d4
  set_player_stats()
end

function _init()
  init_game(true,false)
end

function set_player_stats()
  pdef,pdmg,patk_spd = 0,1,8
  if (item[1] == 2) pdef = 0.5
  if (item[2] == 2) pdmg,patk_spd = 2,7
  if (item[2] == 3) pdmg,patk_spd = 3,6
  if (item[3] == 1) pdmg = pdmg * 2
  if (item[4] == 1) pdef += 1
end

function parse_en(s,x,y,jj)
  local e_num,e_cnt,e_ter = sub(s,jj,jj+1)+0,sub(s,jj+3,jj+3)+0,sub(s,jj+5,jj+5)+0
  return {["n"]=e_num,["c"]=e_cnt,["t"]=e_ter}
end

function load_map_enemies(l)
  enemy_master = {}
  local maxx,maxy = 5,3
  if (l == 0) maxx,maxy = 6,4
  local j = 1
  for y = 0,maxy do
    enemy_master[y] = {}
    for x = 0,maxx do
      enemy_master[y][x] = {}
      for i = 0,2 do
        enemy_master[y][x][i] = parse_en(em[l],x,y,j)
        j += 7
      end
    end
  end
end

function add_special(x,y,i,i1,i2,base)
  if (i < 1) return
  local sp={}
  sp.n,sp.w,sp.h,sp.hticks,sp.base,sp.status,sp.solid, sp.hp,sp.i1,sp.i2,sp.x,sp.y,sp.cost = i,5,8,0,base,1,false,2,i1,i2,x,y,0

  if (i >= 25) sp.solid = true
  if i < 4 then
    sp.sx,sp.sy,sp.h = 121,24,7
  elseif i < 8 then
    sp.sx,sp.sy = 101 + (i-4)*5,24
  elseif i == 10 then
    sp.sx,sp.sy = 21,40
  elseif i < 13 then
    sp.sx,sp.sy = 31+(i-11)*5,40
  elseif i < 25 then
    sp.sx,sp.sy = 41 + (i-15)*5,40
  elseif i == 25 then
    sp.sx,sp.sy,sp.w = 8,24,8
  elseif i == 26 then
    sp.sx,sp.sy,sp.w = 72,24,8
  elseif i == 27 then
    sp.sx,sp.sy,sp.w,sp.solid = 56,16,8,true
  elseif i == 29 then
    sp.sx,sp.sy,sp.w,sp.n = 24,0,8,25
  elseif i == 30 then
    sp.sx,sp.sy,sp.w = 72,32,8
  elseif i == 31 then
    sp.sx,sp.sy,sp.w = 80,8,8
  elseif i == 32 then
    sp.sx,sp.sy,sp.w = 16,48,8
  elseif i == 33 then
    sp.sx,sp.sy,sp.w = 24,48,8
  elseif i == 34 then
    sp.sx,sp.sy,sp.w = 24,56,8
  elseif i == 35 or i == 36 then
    sp.sx,sp.sy,sp.w,sp.solid = 72,32,8,false
  elseif i == 37 or i == 38 then
    sp.sx,sp.sy,sp.w,sp.solid = 72,40,8,false
  end
  
  add(spec,sp)
  if (base >= 0 and gstate[level][base] == 0) sp.status, sp.solid = 0,false
  
  return sp
end

function use_item(i)
  state = 10
  if (php == pmhp) return
  local v = u_item[i]
  if v == 1 then
    php += 2
    add_message("health +2")
  elseif v == 2 then
    php += 10
    add_message("all health restored!")
  else
    return
  end
  u_item[i] = 0
  if (php > pmhp) php = pmhp
  sfx(9,3)
end

function add_special_random(x,y)
  local si = rnd(20) + level
  if si < 17 then
    si = 1
  elseif si < 24 then
    si = 2
  else
    si = 5
  end
  add_special(x,y,si,0,0,-1)
end

function parse_spec(s,j,base) 
  local i = sub(s,j,j+1)+0
  if (i == 28) base, i = -1,25
  if (i == 27) base = -1
  local i1,i2,x,y = sub(s,j+3,j+4)+0,sub(s,j+6,j+7)+0,(sub(s,j+9,j+11)+0) * 8,(sub(s,j+13,j+15)+4) * 8
  add_special(x,y,i,i1,i2,base)
  return base >= 0
end

function load_special(l)
  spec = {}
  local j,k = 1,0
  while (j < #special[l]) do
    if (parse_spec(special[l],j,k)) k += 1
    j += 17
  end
end

function doors(d,xx,yy,vv)
  mv,locx,locy = 48, xx * 17,yy*13
  if (vv > 0) mv = 53
  if band(d,1) == 1 then
    -- up
    mset(locx+7,locy,mv)
    mset(locx+8,locy,mv)
  end
  if band(d,4) == 4 then
    -- down
    mset(locx+7,locy+11,mv)
    mset(locx+8,locy+11,mv)  
  end
  if band(d,2) == 2 then
    -- right
    mset(locx+15,locy+5,mv)
    mset(locx+15,locy+6,mv)
  end
  if band(d,8) == 8 then
    -- left
    mset(locx,locy+5,mv)
    mset(locx,locy+6,mv)
  end
end

function copy_map(xx,yy,n,d)
  bsy = 0 
  if (n > 0) bsy = 12 + (n-1)*10 - 1
  for x1 = 0,16 do 
    for y1 = 0,12 do
      local v = mget(x1+112,y1)
      if (y1 > 0 and y1 <  11) v = mget(x1+112,bsy+y1)
      if (y1 == 12 or x1 == 16) v = 38
      mset(x1+xx*17,y1+yy*13,v)  
    end
  end
  
  doors(d,xx,yy,band(d,16))
 
end

function load_dungeon(n)
  for xx = 0,5 do
    for yy = 0,3 do
      cx,cy = n*12+xx,60+yy
      --get map value
      --copy map room over
      copy_map(xx,yy,mget(cx,cy),mget(cx+6,cy))
    end
  end
  
  mset(8,50,7)
  
  --always place player bottom left at bottom
  px,cmx,cmy,cmd,mx,my = 64,136,104,16,0,3
  lmx,tmy = mx * cmx,my*cmy
  py,level = tmy + 110,n+1
  
  load_map_enemies(level)
  load_special(level)
  spawn_enemies(mx,my,level)
  bg = dcol[level]  
  music(0)
end

function set_location(e)
  for i = 1,1000 do
    if e.terr >= 0 then
      e.x,e.y = lmx + 8*flr(rnd(16)),tmy+32+8*flr(rnd(12))
    else
      e.x,e.y = lmx + 8 + max(0,rnd(112)-e.w),tmy + 40 + rnd(80-e.h)
    end
    if not check_collision(e.x,e.y,false,e.coll,e.terr,e.w,false) then
      local db = false
      for oe in all(en) do
        if (oe != e) db = db or hit(e.x,e.y,oe)  
      end
      if (not db) break
    end
  end
end

function place_enemy(n,t,r)
  local e = {}
  e.bs,e.n,e.ms,e.jy,e.ey,e.pause_shoot,e.pause_ticks,e.f,e.state,e.speed,e.ticks,e.in_hit,e.bspb,e.mf,e.dx,e.dy,e.hp,e.coll,e.terr = 0,n,0,0,0,0,0,0,0,1,0,0,28,2,0,0,2,true,-1
  e.w,e.h,e.c,e.atk,e.aticks,e.num_shots,e.max_a,e.r,e.steal,e.atk_dmg,e.invince,e.scale,e.mticks,e.hticks,e.die_on_shoot,e.dmg = 8,8,0,0,0,1,3200,r,false,1,false,1,0,0,false,1
  
  if n < 3 then
    --spider move enemy
    e.spb,e.speed = 30,1
    if (n == 2) e.speed = 1.25
    if (level > 3) e.speed += 0.25
  elseif n < 6 then
    -- jump enemy
    e.spb,e.ms,e.speed = 13,1,(n-1)*0.25
  elseif n < 12 then
    -- pop up and down
    e.bs,e.spb,e.ms,e.speed,e.state = 2,11,2,0,30
    if ((n == 7) or (n == 10)) e.atk = 2
    if ((n == 8) or (n == 11)) e.atk = 1
    if (n > 8) e.ms = 3
    if (level > 2) e.bs += 0.25
    if (level > 3) e.bs += 0.5 
  elseif n < 15 then
    -- move and shoot
    e.spb,e.hp,e.atk,e.bs,e.aticks = 40,2,1,2,flr(rnd(40)) + 20
    if (n == 13) e.atk = 2
    if (n == 14) e.speed,e.hp,e.num_shots = 1.25,2,2
    if (level > 3) e.bs += 0.5
    if (level > 4) e.num_shots += 1
  elseif n < 18 then
    -- fly and swoop enemy
    e.spb,e.atk,e.bs,e.speed,e.ms,e.coll,e.state = 42,0,0,(n-13)*0.25,4,false,0
  elseif n < 21 then
    -- static trap
    -- always in center
    e.hp,e.spb, e.x,e.y,e.aticks,e.max_a,e.atk, e.bs,e.speed,e.coll,e.bspb = 1,58,60+lmx,76+tmy,5,1,2,3,0,false,122
    if (n == 19) e.max_a = 10
    if (n == 20) e.max_a, e.bs = 10,4
  elseif n < 24 then
    -- static trap, always in center
    -- but shoots at player
    e.hp,e.spb, e.x,e.y,e.aticks,e.max_a,e.atk, e.bs,e.speed,e.coll = 1,59,60+lmx,76+tmy,5,5,1,4,0,false
    if (n == 22) e.max_a = 5
    if (n == 23) e.max_a,e.num_shots = 50,3
  elseif n < 27 then
    -- pop up and down
    e.bs,e.spb,e.ms,e.speed,e.state,e.atk,e.coll,e.terr = 2 + (n-24)/2,96,3,0,30,1,false,7
  elseif n < 30 then
    -- fly and swoop
    -- steal gold
    e.spb, e.steal,e.atk_dmg,e.invince,e.atk,e.bs,e.speed,e.ms,e.coll,e.state = 112, true,0.25,true,0,0,(n-26) * 0.25,4,false,0
  elseif n < 33 then
    e.spb,e.bspb,e.mf,e.atk,e.bs,e.aticks,e.hp,e.pause_shoot,e.speed = 106,122,4,3,0.333,flr(rnd(30)) + 20,4,30,1+ (n-30)*0.25
    if (level > 4) e.bs += 0.167
  elseif n < 36 then
    --mr. destructo
    e.spb,e.bspb,e.mf,e.ms,e.max_a,e.hp,e.speed,e.atk,e.bs,e.aticks,e.invince,e.die_on_shoot = 109,122,4,4,1,1,(n-31)*0.25,4,1,flr(rnd(20)) + 20,30,true,true
    if (level > 4) e.bs += 0.167
  elseif n < 39 then
    -- move and shoot guard
    e.spb,e.hp,e.atk_dmg,e.num_shots,e.speed = 126,6,2,2,(n-33)*0.25
    e.atk,e.aticks,e.pause_shoot,e.bs = 5,flr(rnd(40)) + 25,10,2 * e.speed
    if (level > 5) e.num_shots += 1
  elseif n == 50 then
    e.scale,e.spb,e.ms,e.speed,e.w,e.h,e.hp = 2,13,1,1.5,16,16,12
  elseif n == 51 then
    e.spb, e.steal,e.atk_dmg,e.w,e.h,e.hp,e.scale,e.ms,e.coll,e.state,global_spawn = 112,true,1,16,16,26,2,4,false,0,4
  elseif n == 52 then
    e.spb,e.ms,e.speed,e.w,e.h,e.hp,e.scale,e.num_shots,e.atk,e.aticks,e.bspb,e.mf,e.bs = 100,1,1.25,16,16,20,1,4,1,60,122,4,2.5
  elseif n == 53 then
    e.spb,e.bspb,e.mf,e.w,e.h,e.scale,e.num_shots,e.atk,e.bs,e.aticks,e.hp,e.pause_shoot = 106,122,4,16,16,2,3,3,1,rnd(30) + 20,28,15
  elseif n == 54 then
    global_spawn,e.bs,e.spb,e.ms,e.speed,e.state,e.atk,e.coll,e.w,e.h,e.hp,e.scale,e.num_shots,e.bspb,e.mf = 3,4,11,3,0,30,1,false,16,16,40,2,5,122,4
  elseif n == 55 then
    e.spb,e.ms,e.speed,e.w,e.h,e.hp = 74,4,0.75,16,16,90
    global_spawn,e.num_shots,e.atk,e.aticks,e.bs = 4,4,1,60,2.5
  end
  
  if (e.n >= 50) e.x,e.y = 92+lmx,76+tmy
  
  if (e.hp != 1) e.hp += max((level - 1),0) + max((level - 4)*2,0)
  e.atk_dmg += max((level-3),0)

  e.num_shots_c = e.num_shots
  
  if (t > 0) e.terr = t
  if ((n < 18) or ((n > 23) and (n < 50))) set_location(e)
  
  add(en,e)
  return e
end

function spawn_enemies(mx,my,lv)
  en = {}
  if (lv < 0) return
  
  for i = 0, 2 do
    local ed = enemy_master[my][mx][i]
    if ed["c"] > 0 then
	    for c = 1, ed["c"] do
	      place_enemy(ed["n"],ed["t"],i)
	      --if (ed["n"] == 50) add_message("defeat the giant hopper!")
	      --if (ed["n"] == 51) add_message("defeat the giant ghost!")
	    end
	   end
  end
  spawn_v = 45
end

function set_enemy_dir(d,rev,ee,spd)
  ee.dx,ee.dy = 0,0
  local r = 1
  if (rev) r = -1
  if (d == 0) ee.dy = -spd * r
  if (d == 1) ee.dx = spd * r
  if (d == 2) ee.dy = spd * r
  if (d == 3) ee.dx = -spd * r
end

function pick_dir(e1)
  local d1 = flr(rnd(100)/25)
  set_enemy_dir(d1,false,e1,e1.speed)
end

function check_door()
 if #en < 1 then
   d = mget((level-1)*12+mx+6,60+my)
   if band(d,16) > 0 then
     doors(d,mx,my,0)
     sfx(6)
   end
 end 
end

function enemy_die_drop(e)
  local r,x,y,i = flr(rnd(2.5) + 0.49),e.x,e.y,0
  if (r > 0) add_special_random(x-2,y-2)
  if (r > 1) add_special_random(x+2,y+2)

  if (e.n == 50) i = 18
  if (e.n == 51) i = 17
  if (e.n == 52) i = 19
  if (e.n == 53) i = 20
  if e.n == 54 then
    i = 15
    mset(76,37,7)
  end
  if (e.n == 55) ticks, state = 0,30
  
  if (i > 0) add_special(x+4,y+8,i,0,0,-1)
  if check_door() then
    add_special_random(x-2,y+2)
    add_special_random(x+2,y-2)
  end
end

function handle_hit(e)
		if e.hticks > 12 then
	    if not check_collision(e.x + e.dx, e.y + e.dy,true,e.coll,-1,e.w,false) then
	      e.x += e.dx
	      e.y += e.dy
	    end
	 end
	 
	 if e.hticks == 12 then
	   e.dx,e.dy = 0,0
	   e.hp -= e.dmg
    if e.hp < 0.25 then
      sfx(3)
      e.in_hit,e.hticks,e.f,e.c = 2,20,0,0
      if e.r >= 0 then
        enemy_master[my][mx][e.r]["c"] -= 1
      else
        global_spawn += 1
      end
      return
    end
	 end
	 
  e.c = 0
  if ((e.hticks % 2) == 0) e.c = 10
  if e.hticks < 1 then
    e.in_hit,e.c = 0,0
    if (e.ms == 3) e.c,e.ticks,e.state = -1,15,35
  end
end

function handle_death(e)
  e.c = 0
  if e.hticks > 12 then
    e.c = 8
  else
    e.f = 0 
    if ((e.w > 8) and (e.scale == 1)) e.scale = 2
    if (e.hticks > 8) e.spb = 47
    if (e.hticks == 8) e.spb = 46
    if (e.hticks == 4) e.spb = 45
  end
  
  if e.hticks < 1 then
    del(en,e)
    enemy_die_drop(e)
  end
  
end

function target_player(e,bs)
  dx,dy = px - e.x,py - e.y
  l = sqrt(dx*dx+dy*dy)
  if (l == 0) l = 1
  e.dx,e.dy = dx*bs/l,dy*bs/l
end

function spawn_bullet(e)
  local bullet = {}
  bullet.dx,bullet.dy,bullet.in_hit,bullet.state,bullet.w,bullet.h = 0,0,0,0,6,6
  bullet.spb,bullet.mf,bullet.f,bullet.ticks,bullet.ms,bullet.x,bullet.y,bullet.c = e.bspb,e.mf,0,45,50,e.x+e.w/2-4,e.y+e.h/2-4,0
  bullet.atk_dmg,bullet.scale, bullet.hticks, bullet.mticks = e.atk_dmg,1,0,0
  if ((e.atk == 3) or (e.atk == 4)) bullet.ticks = 25
  return bullet
end

function enemy_shoot(e)
  del(en,e)
  local atk,bs,r = e.atk,e.bs,rnd(10)
 	if e.n == 52 then
    if r > 8 then
     local bullet = spawn_bullet(e)
     bullet.dx,bullet.dy = -bs,0
     add(en,bullet)
    end
  elseif e.n == 53 then
    if r > 7 then
      atk,bs = 1,4
    end
  elseif e.n == 55 then
    if r > 8.5 then
      atk,bs = 4,2
    elseif r > 6 then
      spawn(13,e,5)
      add(en,e)
      return
    end
  end
  if atk == 1 then
    local bullet = spawn_bullet(e)
    target_player(bullet,bs)
    add(en,bullet)
  elseif atk == 5 then
    local bullet = spawn_bullet(e)
    if (e.dx != 0) bullet.dx = e.dx/(abs(e.dx)) * e.bs
    if (e.dy != 0) bullet.dy = e.dy/(abs(e.dy)) * e.bs
    add(en,bullet)
    add(en,e)
    return
  end
  if atk > 1 then
    --all 4 dirs
    local bullet = spawn_bullet(e)
    bullet.dx,bullet.dy = bs,0
    add(en,bullet)
    local bullet = spawn_bullet(e)
    bullet.dx,bullet.dy = -bs,0
    add(en,bullet)
    local bullet = spawn_bullet(e)
    bullet.dx,bullet.dy = 0,bs
    add(en,bullet)
    local bullet = spawn_bullet(e)
    bullet.dx,bullet.dy = 0,-bs
    add(en,bullet)
  end
  if atk > 2 then
    local bullet = spawn_bullet(e)
    bullet.dx,bullet.dy = bs,bs
    add(en,bullet)
    local bullet = spawn_bullet(e)
    bullet.dx,bullet.dy = -bs,-bs
    add(en,bullet)
    local bullet = spawn_bullet(e)
    bullet.dx,bullet.dy = -bs,bs
    add(en,bullet)
    local bullet = spawn_bullet(e)
    bullet.dx,bullet.dy = bs,-bs
    add(en,bullet)
    e.f = 2
    sfx(4)
  end
  add(en,e)
end

function move_bullet(e)
  e.x += e.dx
  e.y += e.dy
  e.f += 0.5
  if (e.f >= e.mf) e.f = 0
  if (e.ticks < 1) then
    del(en,e)
    check_door()
  end
end

function enemy_do_attack(e)
	 e.aticks -= 1
  if e.aticks < 1 then
    if e.die_on_shoot then
      dlx,dly,e.aticks = e.x - px, e.y - py,8
      if (sqrt(dlx*dlx+dly*dly) > 18) return
    end
    e.max_a -= 1
    e.num_shots_c -= 1
    if (e.max_a >= 0) enemy_shoot(e)
    if e.max_a < 1 and e.die_on_shoot then
      e.in_hit,e.hticks, e.mticks,e.hp = 1,16,20,0
    end
    e.aticks = flr(rnd(4)) + 6
    if (rnd(10) > 6.5) e.num_shots_c -= 1
    if e.num_shots_c < 1 then
      e.aticks,e.num_shots_c = rnd(45)+30, e.num_shots
    end
    
    e.pause_ticks = e.pause_shoot
  end
end

function spawn(n,e,r)
  if rnd(10) > r and global_spawn > 0 then
    local ne = place_enemy(n,0,-1)
    e.ticks,ne.x,ne.y, ne.hp, ne.invince = 3,e.x + 8,e.y+8,3,false
    global_spawn -= 1
    return true
  end
  return false
end


function update_enemy(e)
  e.ticks -= 1
  if (e.hticks > 0) e.hticks -= 1
  if (e.mticks > 0) e.mticks -= 1
  
  if e.ms == 50 then
    move_bullet(e)
    return
  end
  
  if (e.state != 22) check_attack_hit(e)
  if e.in_hit == 1 then
    handle_hit(e)
    if (e.mticks > 0) return
  elseif e.in_hit == 2 then
    handle_death(e)
    return
  end
  
  if e.pause_ticks > 0 then
  	e.pause_ticks -= 1
  	return
 end
  
  if e.state == 0 then
    if (e.ms == 2 or e.ms == 3) then
      e.state = 30
      return
    end
    pick_dir(e)
    e.ticks,e.state,e.f = (rnd(35) + 15)/e.speed,10,0
   elseif e.state == 10 then
    if (e.f < 2) then
      e.f += (e.speed / 4)
      if (e.f > 1.99) e.f = 0
    end
    if check_collision(e.x + e.dx, e.y + e.dy,true,e.coll,-1,e.w,false) or (e.x < lmx + 64 and e.n == 52) then
      e.ticks = 0
      if (e.ms == 1) pick_dir(e)
      if ((e.n == 52) and (e.x < lmx + 64)) then
        set_enemy_dir(1,false,e,e.speed)
        e.state,e.f,e.ticks = 20, 1.5, 30
      end
    else
      e.x += e.dx
      e.y += e.dy
    end
    if e.ticks < 1 then
      e.state = 0
      if e.ms == 1 then
        if rnd(10) > 7 then
          e.state,e.f = 20,1.5
        else
          e.state,e.ticks = 10,15
        end
      elseif e.ms == 4 then
        --swoop attack
        if rnd(10) > 5 then
          e.state,e.f,e.ticks = 10,2,15
          target_player(e,e.speed+1)
          if ((e.n == 51) and (not spawn(28,e,8.5))) e.ticks += rnd(6)
        end
      end
    elseif e.atk > 0 then
      if (en.n != 52) enemy_do_attack(e)
    end
  elseif e.state == 20 then
    e.f -= 0.25
    if (e.f < 0.1) e.f,e.state = 2,21
  elseif e.state == 21 then
    if e.n == 52 then
      if (e.aticks > 6) e.aticks = 6
    end
    e.f += 0.5
    if (e.f > 2.9) e.f,e.state,e.jy,e.oy = 2,22,-2-flr(rnd(2)),0
    e.ey = -e.jy
  elseif e.state == 22 then
    if (e.n == 52) enemy_do_attack(e)
    if (check_collision(e.x + e.dx, e.y + e.dy - e.oy,true,e.coll,-1,e.w,false)) then
      e.y += e.jy
    else
      e.y += e.dy + e.jy
      e.x += e.dx
    end
    e.oy += e.jy
    e.jy += 0.2
    if (e.jy >= e.ey) e.jy,e.state,e.f = 0,25,1
  elseif e.state == 25 then
    e.f -= 0.1
    if (e.y < (tmy + 40)) e.y += 1
    if (e.f < 0.1) then
      e.state = 0
      if (e.y < (tmy + 40)) e.y = tmy + 40
    end
  elseif e.state == 30 then
    --waiting to pop up
    e.c,e.state,e.f,e.ticks = 0,31,0,rnd(45)+10 - level * 4
  elseif e.state == 31 then
    if e.ticks < 1 then
      e.state,e.f,e.ticks,e.aticks = 32,1,20-level,0
    end
  elseif e.state == 32 then
    if e.ticks < 1 then
      if (e.n == 54 and rnd(10) > 7) spawn(7,e,9)
      enemy_do_attack(e)
      if (e.num_shots_c == e.num_shots) e.state,e.ticks = 33,flr(rnd(50))+10
    end
  elseif e.state == 33 then
    if (e.ticks < 1) e.state,e.f = 34,0
  elseif e.state == 34 then
    e.state = 30
    if (e.ms == 3) e.c,e.ticks,e.state = -1,45,35
  elseif e.state == 35 then
    if (e.ticks < 1) then
      set_location(e)
      e.state = 30
    end
  end
end

function attack()
  paflp,patk_ticks,pax,pay,patk_sp,pf = false,patk_spd,px + 8,py,80,2
  if (pdir == 3) pax = px - 8
  if (pdir == 0) then
    pax,pay,patk_sp,paflp = px,py - 8,81,true
  elseif (pdir == 2) then
    pax,pay,patk_sp,paflp = px,py + 8,81,false
  end
  sfx(1)
end

function check_special_collisions(xx,yy,csp)
  for s2 in all(spec) do
    if s2.solid and hit(xx,yy,s2) then
        if (csp) check_special_pick(s2)
        return true
    end
  end
  return false
end

-- gold = 1
-- 5 gold = 2
-- heart container = 4
-- red potion = 5 - 2 hearts
-- blue potion = 6 - full hearts
-- key = 7

function check_special_pick(s)
  if (s.cost > gold) return
      if s.n == 1 then
        gold += 1
        add_message("gems +1",15)
      elseif s.n == 2 then
        gold += 5
        add_message("gems +5",15)
      elseif s.n == 7 then
        num_keys += 1
        add_message("picked up a key")
      elseif s.n == 4 then
        pmhp += 1
        php += 1
        add_message("max health +1")
      end
      if s.n == 5 or s.n == 6 then
        local r = false
        for i = 1, 10 do
          if (u_item[i] < 1) then
            u_item[i],r = s.n-4,true
            break
          end
        end
        if (r == false) return
        add_message("picked up a potion")
      end
      if s.n == 10 then
        item[1] = 2
        add_message("mithril shield +0.5 defense")
      elseif s.n == 11 then
        if item[2] < 2 then
          item[2] = 2
          add_message("mithril sword +1 attack dmg")
        else
          return
        end
      elseif s.n == 12 then
        if item[2] < 3 then
          item[2] = 3
          add_message("crystal sword +2 attack dmg")
        else
          return
        end
      elseif s.n > 12 and s.n < 25 then
        message,curr_msg,item[s.n-12] = {},nil,1
        if (s.n == 15) add_message("red ring  2x attack dmg")
        if (s.n == 16) add_message("blue ring  +1 defense")  
        if (s.n == 17) add_message("you found a lost soul!") 
        if (s.n == 18) add_message("you found the skeleton key!") 
        if (s.n == 19) add_message("you found the fire orb!")
        if (s.n == 20) add_message("you found the talisman!")  
      elseif (s.n > 24 and s.n < 30) then
        return false
      elseif s.n == 30 then
        add_message_nil("the skeleton key opens the gate")
        return false
      elseif s.n == 31 then
        if (item[6] == 1) then
          if (s.solid) add_message("you unlock the gate!")
          s.solid = false
        else
          return false
        end
      elseif s.n == 32 then
        if item[5] == 0 then
          add_message_nil("bring me my lost soul!")
          return false
        else
          add_message("my soul! i'm free!")
          add_message("you may pass.")
        end
      elseif s.n == 33 then
        if item[7] == 0 then
          add_message_nil("no fire orb? no pass!!!")
          return false
        else
          add_message("holder of fire- you may pass.")
        end      
      elseif s.n == 34 then
        if item[8] == 0 then
          if (add_message_nil("only those with kildren's")) add_message("talisman may pass.")
          return false
        else
          add_message("enter the castle fair knight.")
        end  
      elseif s.n == 35 then
         if add_message_nil("rumour has it the red ring is") then
           add_message("in a dungeon to the north. it")
           add_message("doubles attack damage.")
         end
         return false
      elseif s.n == 36 then
         if add_message_nil("secret passages exist in the") then
           add_message("mountains. attack them to")
           add_message("reveal them.")
         end
         return false
      elseif s.n== 37 then
        if add_message_nil("will you help us knight?",50) then   
          add_message("kildren has cursed our land",50)
          add_message("with eternal winter. only",50)
          add_message("his defeat will end the curse!",50)
        end
        return false
      elseif s.n == 38 then
        if add_message_nil("chests need a key to open, but",50) then
          add_message("they contain valuable items like",50)
          add_message("hearts. there are two more",50)
          add_message("nearby. get them early!",50)
        end
        return false
      end
      
      gold -= s.cost
      set_player_stats()
      del(spec,s)
      if (pmhp > 9) pmhp = 9
      sfx(2)
      save_p()
end

function check_special_pickup(xx,yy)
  for ss in all(spec) do
    if (hit(xx,yy,ss)) check_special_pick(ss)
  end
  return false
end

function check_bounds(xx,yy,sz)
  local offx = 0
  if (level > 0) offx = 8
  if (((xx + sz) > (lmx + 127 - offx)) or (xx < (lmx+offx)) or (yy < (tmy+offx)) or ((yy+sz) > (tmy+98-offx))) return true
end

function check_collision(xx,yy,cb,cc,te,sz,csp)
  global_flag = 0
  if (cb) then
    if (check_bounds(xx,yy-32,sz)) return true
  end
  if (cc or te > 0) then
    local x,y = flr((xx+sz/2)/8),flr((yy-32+sz/2+2)/8)
    local v = mget(x,y)
    global_flag,global_x,global_y = fget(v),x,y
    
    if te >= 0 then
      if (not fget(v,te)) return true
      return false
    end
    
    if (fget(v,0)) return true
    
    return check_special_collisions(xx,yy,csp)
  end
  return false
end

function hit(x,y,b,of)
  of = of or 2
  x += of
  y += of
  local os,of2 = (8-b.w)/2, 8 - (of * 2)
  return ((x <= b.x + b.w + os) and (b.x + os <= x + of2) and (y <= b.y + b.h + os) and (b.y + os <= y + of2))
end

function hit_blocked(e)
		if (abs(pdx+pdy) > 0.25 or patk_ticks > 0 or e.ms != 50 or e.spb != 28) return false
		local bl,adx,ady = false,abs(e.dx),abs(e.dy)
  if (pdir == 0 and e.dy > 0 and ady >= adx) bl = true 
  if (pdir == 1 and e.dx < 0 and adx >= ady) bl = true
  if (pdir == 2 and e.dy < 0 and ady >= adx) bl = true
  if (pdir == 3 and e.dx > 0 and adx >= ady) bl = true
  if (bl) then
    sfx(11)
    del(en,e)
  end
  return bl
end

function check_player_hit(e)
  if (pinhit > 0) return
  if (spawn_v > 0) return
  if (e.in_hit > 0 or e.state == 22 or e.state == 31 or e.c < 0 or e.die_on_shoot) return
  if hit(px,py,e) then
    if (hit_blocked(e)) return
    sfx(5)
    local dm1 = (e.atk_dmg - pdef)
    if (dm1 < 0.25) dm1 = 0.25
    php -= min(dm1,1)
    if e.ms == 50 then
      del(en,e)
      check_door()
    end
    pinhit,phticks = 1,30
    if e.steal then
      gold -= flr(rnd(9))
      if (gold < 0) gold = 0
    end
    if php < 0.1 then
      --dead
      state, inv_ticks,gold = 18,0,gold - flr(gold * 0.333)
      num_deaths += 1
      add_message("thou art slain!",75)
      save_p()
      music(-1)
      sfx(8,3)
    elseif php < 1.5 then
      sfx(7,3)
    end
  end
end

function remove_perm_special(s)
  s.status,s.solid,gstate[level][s.base] = 0,false,0
  save_p()
end

function open_special(s)
  add_special(s.x-2,s.y-2,s.i1,0,0,-1)
  add_special(s.x+2,s.y+2,s.i2,0,0,-1)
  remove_perm_special(s)
  if (s.sx == 24) sfx(10)
end

function check_attack_special(s)
  if (s.status == 0) return
  if s.n == 26 then
    --unlock chest
    if num_keys > 0 then
      if hit(pax,pay,s) then
        num_keys -= 1
        open_special(s)
        add_message("unlocked chest with key!")
        return
      end
    end
  end
  if (s.n != 25) return
  s.hticks -= 1
  if s.hticks < 1 then
	  if hit(pax,pay,s) then
	    s.hp -= pdmg
	    s.hticks = patk_ticks + 1 
	    if (s.hp < 1) open_special(s)
	  end
	end
end

function load_store(l)
  
  level = l
  local stl = -l
  copy_map(0,0,0,0)
  mset(8,11,7)
  
  --always place player bottom left at bottom
  px,cmx,cmy,cmd,mx,my = 64,136,104,16,0,0
  lmx,tmy = mx * cmx,my*cmy
  py,bg = tmy + 110,4
  
  spec = {}
  local spc = add_special(37,65,store[stl][1],0,0,-1)
  spc.cost = store[stl][3]
  local spc2 = add_special(93,65,store[stl][2],0,0,-1)
  spc2.cost = store[stl][4] 
end

function use_exit(l,x,y)
 curr_msg, messages = nil,{}
	if l == 0 then
   reset_map(x,y, level >= 0)
 elseif l > 0 then
   load_dungeon(l-1)
 else
   load_store(l)
   en = {}
   add_message("welcome to my store!")
   add_message("choose wisely adventurer...")
 end
end

function check_attack_hit(e)
  if (patk_ticks < 1) return
  if ((e.in_hit > 0) or (e.c < 0)) return
  if (e.invince) return
  if hit(pax,pay,e,0) then
    e.in_hit,e.hticks, e.mticks,e.dmg,e.ticks = 1,20,12,pdmg,0
    if (e.ms == 3) e.f =0
    if e.n > 49 then
      --e.mticks, e.hticks = 2,16
      --e.mticks = 2
      e.aticks += 2
      --if (e.n == 52) 
    else
      e.aticks += 8
    end
    set_enemy_dir(pdir,false,e,2)
  end
end

function set_dir(d)
  if pdir != d then
    pdir,psb,pf,pflp,pldx,pldy = d,64,0,false,1,0
    if (d == 0) psb,pldx,pldy = 70,0,-1
    if (d == 2) psb,pldx,pldy = 67,0,1
    if (d == 3) pflp,pldx,pldy = true,-1,0
  else
    pf += 0.33
    if (pf > 1.99) pf = 0
  end
  pmove = true
end

function _update()
  if state == 10 then
    gticks += 1
    if (gticks >= 1800) gticks, game_time = 0, game_time + 1
    if (spawn_v == 0) foreach(en,update_enemy)
    if (spawn_v > 44) spawn_v += 0.25
    if (spawn_v > 47.9) spawn_v = 0
    opx,opy,pmove,pc = px,py,false,0
    if patk_ticks < 1 then
     if phticks > 23 then
       px -= 2*pldx
       py -= 2*pldy
       phticks -= 1
       if (phticks % 2 == 0) pc = 10
     else
       if phticks > 0 then
         phticks -= 1
         if ((phticks % 3) == 0) pc = 6
         if (phticks == 0) pinhit = 0
       end
       local pacl = pac
       if (abs(pdx) + abs(pdy) >= pd) pacl = pd
       
			    if btn(0) then 
			      pdx -= pacl
			      pdy,pdx = 0, mid(-pd,pdx,0)
			  	   set_dir(3)
			    elseif btn(1) then
			      pdx += pacl
			      pdy,pdx = 0, mid(0,pdx,pd)
			      set_dir(1)
			    elseif btn(2) then 
			      pdy -= pacl
			      pdx,pdy = 0, mid(-pd,pdy,0)
			  	   set_dir(0)
			    elseif btn(3) then
			      pdy += pacl
			      pdx,pdy = 0, mid(0,pdy,pd)
			      set_dir(2)
			    end
			    if (not pmove) pf,pdx,pdy = 0,0,0
							px += pdx
							py += pdy
			    if btn(4) then 
			      if (btn4_ticks > 0) then
			        attack()
			        btn4_ticks = 0
			      end
			    else 
			      btn4_ticks += 1
			    end
			    if pinhit < 1 then
			      foreach(en,check_player_hit)
			    end
		   end
    else
      if (not btn(4)) btn4_ticks += 1
      patk_ticks -= 1
      foreach (spec,check_attack_special)
    end
    if (check_collision(px,py,false,true,-1,8,true)) then
      px,py,pf = opx,opy,0
    else
      if (pmove and ((gticks % 4) == 0)) sfx(0)
    end
    
    check_special_pickup(px,py)
    
    if btnp(5) then
      state, inv_sel,inv_ticks = 15,1,0
    end
    
    if px < lmx then
      mdx,state,ticks,t_amt = -1,20,32,27
    elseif px > (lmx+120) then
      mdx,state,ticks,t_amt = 1,20,32,27
    elseif (py-32) < tmy then
      mdy,state,ticks,t_amt = -1,20,24,18
    elseif (py-32) > (tmy+89) then
      mdy,state,ticks,t_amt = 1,20,24,24
    end
    
    if band(global_flag,4) == 4 then
      --hit a special exit
      local key="l"..level..global_x..global_y
      local o = exits[key]
      use_exit(o[1],o[2],o[3])
				end
  elseif state == 15 then
    --pick from inventory
    inv_ticks += 1
    if btnp(0) then
      if (inv_sel > 1) inv_sel -= 1
    elseif btnp(1) then
      if (inv_sel < 10) inv_sel += 1
    end
    
    if (btnp(5)) use_item(inv_sel)
    if (btnp(4)) state = 10
  elseif state == 18 then
  	--dead
  	inv_ticks += 1
  	if inv_ticks > 90 then
  	  init_game(false,false)
  	end
  elseif state == 20 then
    xo,yo = xo + mdx*4,yo + mdy*4
    ticks -= 1
    px += mdx * cmd/t_amt
    py += mdy * cmd/t_amt
    if (ticks == 0) state = 25
  elseif state == 25 then
    mx += mdx
    my += mdy
    lmx,tmy,state,mdx,mdy,xo,yo = mx * cmx,my*cmy,10,0,0,0,0
    spawn_enemies(mx,my,level)
  elseif state == 30 then
    -- won game
    ticks += 1
    if ((abs(ticks) > 90) and (btnp(4))) init_game(false,true)
  end
  
  camera(mx*cmx+xo,my*cmy+yo)
end

function enemy_color(c)
  for i = 0,13 do pal(i,c) end
end

function draw_special(s)
  if (s.status == 0) return
  if s.n == 2 then
    pal(13,11)
  else
  		pal(13,13)
  end
  sspr(s.sx,s.sy,s.w,s.h,s.x,s.y)
end

function draw_enemy(e)
  if spawn_v > 0 then
    spr(spawn_v,e.x,e.y)
  else
    if (e.c < 0) return
    if (e.c > 0) enemy_color(e.c)
    local f = flr(e.spb + e.f)
    if e.scale == 1 then
      if e.w < 9 then
        spr(f,e.x,e.y)
      else
        if (e.f >= 2) f = e.spb + 3
        if (e.f >= 1) f += 1
        spr(f,e.x,e.y,2,2)
      end
    else
      local r = flr(f/16)
      local c = f - (r*16)
      sspr(c*8,r*8,8,8,e.x,e.y,e.scale*8, e.scale*8)
    end
    reset_color()
  end
end

function reset_color()
  pal()
  palt(0,false)
  palt(14,true)
  pal(15,bg)
end

function draw_messages()
  if curr_msg != nil then
    print(curr_msg.txt,curr_msg.x,26,7)
    curr_msg.ticks -= 1
    if (curr_msg.ticks < 1) curr_msg = nil
  end
  if curr_msg == nil then
    if #messages > 0 then
      curr_msg = messages[1]
      del(messages,curr_msg)
    end
  end
end

function _draw()
  cls(bg)
  reset_color()
  map(0,0,0,32,128,64)
  foreach(spec, draw_special)
  reset_color()
  if ((state == 10) or (state == 15)) foreach(en, draw_enemy)
  if (pc > 0) enemy_color(pc)
  spr(psb + pf,px,py,1,1,pflp,false)
  reset_color()
  if patk_ticks > 0 then
    spr(patk_sp,pax,pay,1,1,pflp,paflp)
  end
  map(0,0,0,32,128,64,2)
  camera(0,0)
  rectfill(0,0,128,32,0)
  print("-life-",92,0,8)
  for i = 1,pmhp do
    sspr(96,24,5,6,71+i*6,9)
    if (i <= php) sspr(101,24,5,6,71+i*6,9)
  end
  for i = 0,7 do
    local inum = item[i+1]
    if inum > 0 then
      local xx = i*5
      if i == 0 then
        xx += (inum-1)*5  
      elseif i == 1 then
        xx += (inum-1)*5 + 5
      else
        xx += 15
      end
      sspr(xx+16,40,5,8,80+i*6,17)
    end
  end
  
  for i = 0,9 do
    local xx = u_item[i+1] * 5
    if xx > 0 then
      sspr(xx+101,24,5,8,i*6,9)
    end
  end
  
  sspr(121,24,5,8,0,17)
  print(gold,8,18,6)
  sspr(116,24,5,8,44,17)
  print(num_keys,51,18)
  if (level >= 0) print(title[level+1],titlex[level+1],0)
  
  if level < 0 then
    -- in store
    for s in all(spec) do
      print("cost: "..s.cost,s.x - 16,s.y - 31,7)
    end
    
    spr(73,62,65)
  end
  
  if ((state == 15) and (inv_ticks % 5 != 0)) rect(6*inv_sel-6,9,6*inv_sel-1,17,7)
  
  draw_messages()
  
  if state == 30 then
    rectfill(20,48,108,102,1)
    print("victory!",50,56,7)
    print("the curse is lifted.",26,66)
    print("deaths: "..num_deaths,26,80)
    print("  time: "..game_time.. " mins",26,90)
  end
end
__gfx__
00000000eeeeeeeee00be33e60077066cccccccccccccccce44eeeeee555555ee00be33ee00be30e00000000eeeeeeeeeee55eeeeeeeeeeeeeeeeeeeeeebbeee
00000000eeeeeeee0330be3000766607cc7ccccccccccc7c44444e4e500000050330be3003e0be3000000000eeeeeeeee555555eeeeeeeeeeeeeeeeeeebbbbee
00700700eeeeeeee30330b0e57755557c7c7c7ccc7ccc7c7444444445000000530330b0e30330b0e00000000eeeeeeeee888888eeebbbbeeeeeeeeeeee8bb8ee
00077000eee3eeeee33330b355555555cccc7ccc7ccccccc4440444450000005e33330b3e33330b300000000eee55eeee999999eebbbbbbeeebbbbeeeebbbbee
00077000eee3e3ee3e33e0be55555555cccccccccccccccc44404444500000053e33e0be3e30e00e00000000e555555ee999999eeb8bb8beebbbbbbeeebbbbee
00700700eeee3eee30330b3000000005ccccccc7ccc7cccc444044045000000530330b3030330b3000000000e888888ee999999eebbbbbbeeb8bb8beeebbbbee
00000000eee30eeeb0330b03000000007c7ccc7ccc7c7c7c4444440450000005b0330b03b003000300000000e999999ee989989eebbbbbbebbbbbbbbeebbbbee
00000000eeeeeeee3b00303000000000c7ccccccccccc7cce4444444500000053b0030300b00303000000000e999999ee999999eeebbbbeebbbbbbbbeeebbeee
222222223eeeee3ee4ee4eee444444448888888824422244eee33eee4444444400500500666666666666666666666666eeeeeeeeeeeeeeeee000000ee000000e
28222222ee3eeeeeeeeeeeee44eeee448888a88844444444ee3333ee4444444444444444660006660000066600000666eeeeeeeeeeeeeeee0080808008080800
22202282eeeee3eee4eeeee444eeee448a8888a844444444e33383ee4444444444444444660006660000066600000666eee22eeeeee99eee0808080000808080
22222222eeeeeeeeeeee4eee44eeee448888888844404404e333333e4444444444444444666666666666666666666666ee2882eeee9aa9eee000000ee000000e
22222222e3eeeee3ee4eeeee44444444888a888840404404e833433e4444444444444444666666666666666666666666ee2882eeee9aa9eeee0000eeee0000ee
20228222eee3eeee4eee4eee44eeee448888888844404444e33443334444444444444444666000006660000066600066eee22eeeeee99eeee0e55e0ee0e55e0e
22222222eeeee3eeeeeeeee444eeee448a8888a844444444ee3443ee4444444444444444666000006660000066600066eeeeeeeeeeeeeeeee00eee0ee0eee00e
22222022e3eeeeeeeee4eeee44eeee448888888824444444eee44eee0050050044444444666666666666666666666666eeeeeeeeeeeeeeee0ee0e0e00e0e0ee0
0eeeeeeeeeeeeee0eeeeeeee00000000eeeeeee000000000ffffffff00000000ee888eeeeee888eee00ee00e0eeeeee0e0eeee0eeeeeeeeeeeeeeeeeee8888ee
e0eeeeeeeeeeee0eeeeeeeeeeeeeeee0eeeeeee0eeeeeeeef0ff0f0fee5555e0eee88eeeaee88eee00000000000ee000e0eeee0eeeeeeeeeeeeeeeeee8eeee8e
ee0eeeeeeeeee0eeeeeeeeeeeeeeeee0eeeeeee0eeeeeeeeffffffffe5000050ae6666e54e6666ee0e0000e0e000000ee00ee00eeeeeeeeeeee88eee8eeeeee8
eee0eeeeeeee0eeeeeeeeeeeeeeeeee0eeeeeee0eeeeeeeeff0f0f0fe50000504e0000554e0000eeee9889eeee0000eee000000eeee88eeeee8ee8ee8eeeeee8
eeee0eeeeee0eeeeeeeeeeeeeeeeeee0eeeeeee0eeeeeeeeffffffffe50000505009a00e5009a055ee8888eeee9889eeee0000eeeee88eeeee8ee8ee8eeeeee8
eeeee0eeee0eeeeeeeeeeeeeeeeeeee0eeeeeee0eeeeeeeef0f0f0ffe50000504000000e40000005ee5ee5eeee8888eeeea88aeeeeeeeeeeeee88eee8eeeeee8
eeeeee0ee0eeeeeeeeeeeeeeeeeeeee0eeeeeee0eeeeeeeeffffffffee5555e04055550ee055550eeeeeeeeeee5ee5eeee8888eeeeeeeeeeeeeeeeeee8eeee8e
eeeeeee00eeeeeeeeeeeeeeeeeeeeee0eeeeeee0eeeeeeeeff0f0f0feeeeeee0ee55eeeeeeee55eeeeeeeeeeeeeeeeeeee5ee5eeeeeeeeeeeeeeeeeeee8888ee
00000000eeeeeeeeee5667ee0000000000000000eeeeeeee22222222eeeeeeeeeeeeeeeeee5555eee9a88a9ee888888ee8e8ee8e8ee586ee5c6eeaaaeeeceeee
00000000e57555eee566667eeeeeeee0eeeeeee0eeeeeeee28222222eeeeeeeeeeeeeeeee599995e99aaaa99880000888080888888e586ee5c6eea9aeecdceee
000000005550005e56666667eeeeeee0eeeeeee0e0eeee0e22202282eeeeeeeeeeeeeeee59999995aaaaaaaa808008088000888888e586ee5c6eeaaaecdddcee
00000000e57555ee56776767eeeeeee0eeeeeee0eeeeeeee22222222eeeeeeeeeeeeeeee599559958aa88aa8800aa0088000888888528865dcc6eeeaec7ddcee
000000005676665e56767667eeeeeee0eeeeeee0eeeeeeee22822202eeeeeeeeeeeeeeee555555558aa88aa8800aa008e808ee888e528865dcc6eeaaec7ddcee
000000005676665e56666667eeeeeee0eeeeeee0eeeeeeee22222222eeeeeeeeeeeeeeee59955995aaaaaaaa80800808ee8eeee8ee528865dcc6eeeaeec7ceee
000000005676665e56666667eeeeeee0eeeeeee0e0eeee0e22282022eeeeeeeeeeeeeeee5999999599aaaa9988000088eeeeeeeeeee566ee566eeaaaeeeceeee
00000000e55555ee56766767eeeeeee0eeeeeee0eeeeeeee22222222eeeeeeeeeeeeeeee55555555e9a88a9ee888888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e5e9999eeee9999e9ee9999ee599999eee99999eee99999ee599999eee99999eee99999eee22222eeeeeee82eeeeeeeeeeeeeee82eeeeeee9a9eee82eeeeeeee
e094404e95944041e994404ee040404ee540404eee40404ee099999ee599999eee99999ee2404042eeeeee882eeeeeeeeeeeee882eeeeeeea8aeee882eeeeeee
e0944441e0e44441eee44441e044444ee04d1111ee444111e049994ee0499941e049994eee44444eeeeee88822eeeeeeeaeee88822eeeeee9a9ee88822eeeeee
e00055e1e0e05501eee05501e0ed1111e0edccc1ee55dcc1e0e59511e0e59551e0e59511e6e555eeeeee8888822eeeeea9ae8888822eeeeee4ee8888822ee5ee
15155501e00555e1eee50000151dccc1e0edccc1ee05dcc115155901e0095511e0059501ee556556eaeee51515eeeeeeeaeee51515eeeeeee55ee59595eee55e
e0e555e1151555eeeee55501e00dcc111515dc1eee05dccee0055511151555eeee055511eee565eea9aeee555eeeeeeee4eeee555eeeeeeee55eee555eee55ee
ee55e55ee055ee5eee55ee50ee55dc1ee055d11eee50ed1eee55d55ee055d55eee55d55eee55555eeaee00e5e0055eeee55500e5e005eeeee4e500e5e005eeee
ee55e55eee5eee55ee5eee55ee55d11eeeeee55eee55055eee55deeeeeeee55eee55deeeee55e55ee4e5500000055eeee55e50000005eeeee4ee5000000eeeee
eeeeeeeeee1551eee111ee555eeee4eeee6eeee5ee888eeccceee66ee5555eeeeeaeee9eee11111ee55ee50800e5eeeee4eee5080055eeeee4eee50900eeeeee
eeeeeeeeeee00eeeddc11aa955ee44eee66eee55e88888ccccce6576e5765e222eaeee9ee1404041e55e5000000eeeeee4ee5000055eeeeee4ee5000000eeeee
1eeeeeeeeee00eeedccc1a9995ee44eee66eee55ee888eecccee6756e567588222eae9eeee44844ee4ee5080800eeeeee4ee5080855eeeeee4ee5090900eeeee
5000055eeee00eeedccc1a9995ee44eee66eee55e5eee55eee56776ee555578822ee9eeeeee333eee4e500000000eeeee4e500000000eeeee4e500000000eeee
50000005eee00eeedccc1a9995ee44eee66eee55e5eee55eee56776eeeee577882e999eee5337335e4e500000000eeeee4e500000000eeeee4e500000000eeee
1eeeeeeeeee05eeee1c1ee595ee1111e5555e6666e555ee555ee6776ee655777829aaa9eeee373eee450000000000eeee450000000000eeeee50000000000eee
eeeeeeeeeee05eeeee1eeee5eeee44eee66eee55eeeeeeeeeee6e6e6eeee5e778e9aaa9eeee333eee4ee555e555eeeeeeeee555e555eeeeeeeee555e555eeeee
eeeeeeeeeee5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6555eeeeee999eeeee3e3eee4ee000eeeeeeeeeeeeeeeee000eeeeeeeee000e000eeeee
eeeeeeeee8eaae8eee0000eeee88888eeeeee6e33e6eeeeeeeeee6e33e6eeeeeeee6e3e6eeeeeeeeeaa88aaeeaa88aaeeaa88aaeeee88eeeeeeaaeee8eeaaeee
eeeeeeeee8aaaa8ee580085ee8404048eeee06333360eeeeeeee06333360eeeeee0633360eeeeeeeee0000eeee0000eeee0000eeeee00eeeeee00eeeeae88eae
eee7ee7ee88aa887ee5995eeee44444eeeee03333330eeeeeeee03333330eeeeee0333330eeeeeeeee0aa0eeee0aa0eeee0aa0eeee0000eeee0000eeee0000e8
7eeeeeeee8bbbb8e0ee00ee0e0e888ee000e00733070eeeeeeee00733070eeee888073070eeeeeeeee0000eeee0000eeee0aa0eee0a88a0ee0a88a0ea0a88a0e
e7ee7ee77b9bb9bee550055eee880880040003333330e000eeee03333330eeee8888003300eeeeeee088880ee088880ee000000ee088880ee088880ee088880a
e8eaae8eebbbbbb7eee00eeeeee808ee0444000000000440e00000000000000e888333000000000ee080080ee080080ee080080ee088880ee088880ee0aaaa0e
e8aaaa8eeb3aa3beee5ee5eeee88888e033300377304330004440037730434400444003773043440e08ee080080ee80ee08ee80eee00022ee22000ee8e0000ea
eeeeeeee7b3333bee00ee00eee88e88e004407377330440e04440737733033400444073773303340080eeeeeeeeee080080ee080e22eeeeeeeeee22ee22ee22e
ee577eeeeee577eeee5777eeee88888ee0030777773030ee033307777730440e033307777730440eeeeeaeeeeeeeeeaeeeeeeeeeeeeeeeeaee88888ee088888e
e566677ee556667ee566667ee0f5f5feee0007bb003000eee04407bb003030eee04407bb003030eeea8888eeee8888eee8a888eeae88ea8ee0f5f5fee0f5f5fe
566666675666666756666667e0fffffeeee007770330eeeeee03077033300eeeee03077033300eeee88a8a8ee8a8988eee899a8ae8a8888ee0fffffee0fffffe
568668675686686756866867e0e56666eee030bb0300e00eeee030b03300eeeeeee030b03300eeeee8a8888ee8889a8eee8a888ee888aa8ee0e5222200052222
5666666756666667566666670005ddd6eee0300770000b0eeee0300700000000eee0300700000000e888a8eee8aa888ea888aa8ee8a98a8e00058882e0058882
566666675666666756688667e0056d66eeee00e0bb0770eeeee030e0bb077bb0eee030e0bb077bb0e8a898eee8888a8ee8aaa88ee8898a8ee0052822ee052822
e566667ee566667ee568867eee55566eeeeeeeee07bb0eeeeeee00ee07bb000eeeee00ee07bb000eee88888ee8ae88eaee8888eeee8888eaee55522eee55522e
ee566667566667eee566667eee55e55eeeeeeeeee000eeeeeeeeeeeee000eeeeeeeeeeeee000eeeeeaeeeeeeeeeeeeeeeaeeeeeeeaeeaeeeee55eeeeeeeee55e
20111111111111111111111111111120202083202020202020202010101011111110101173114040101011106111111111111161611111114040111111111111
11111111111111111111111111101130301111112311111123111111231111303011111141111141411111411173113042323232323232323232323232323222
20111173111111731111111111111120202021207310101111112011111111111111111111114040101173116111101111111111111111114040111160111111
11111111835101010151111111101130301111117311111183111111731111303011731011111141411111111111113042324332323232323232323232433222
20111111111111111111111111111190212121201110101011102011101011202011111111114040111111116110111111111111111111114040105101511111
11111111115101010151111111111130301111111111111111111111111011303011111111111141411111111011113042323232323232323232323232323222
20312020202020202020202020202020202020201110101011102011111111202010101111101040401111116110111011111111111011114040115101515151
51515151515101010151515111111130306060606060606060606060111111303030303030303030303030303030303042723272a0a0a0a0a0a0a0a072327222
20312020202020202020202020202020202020201111111111112011111111202010101111101040401111116111111111111111111111114040115101515151
51515151515101010151515111111130306060606060606060606060111111303030303030303030303030303030303042323232a0a0a0a0a0a0a0a032323222
20111160601111111111111160116011111111111111111111111111111111202010101111101040401111116111111111111111111111114040105101015151
51515101010101010101515111111130301111111111111110111111111111111111111111111011111111111111113042323232a0a0a0a0a0a0a0a032323222
20111111601173116011831111736011111110101110101111111110101011202010101111101140401111116111111111111161611111114040105101010151
51510101636363630163015111111130301110111011101111111111111111111110111111111111111110111111113042723272a0a0a0a0a0a0a0a072327222
20111111111111606011111160116011111110101110101111111010101011202010101111101040404011116111111111111161611111114040015101010151
51630163630163636363015111111130301111101140111040404040404040404040404040404040404040404040403042323232323232323232323232323222
20202020202020202011111160116011111110106010101111111110101011202010101111111010404011116111111111111111111111734040015101010101
0101636363636363630151511111113030117311404040114091a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1b142324332323232323232323232433222
20111111111111702011731160111111111110106010107373731010101011202010111111111010404060606011111111111111111173404040015101010101
01016363636363630163511111831130301111114040401140a1324332323232323232323232323232323232323232a142323232323232323232323232323222
20202090202020202011111160111111111110106010101111101010101011202010111173111010404060706011111111111111111140404001010151010101
01016363636363636351511111111130301110114040401140a1323232323232323232323232323232324332323232a1423232323232a03232a0323232323222
20111111111111116011111160116011111110106010101111101010101011202011111111111110404060111111114040404040404040400101010101510101
01016301010101635160111010111030301111111140111140a13232a1a1a1a1a1a1a1a1a132323232323232323232a1423232433232a03232a0323232433222
20117373111111116011831111736011111110106010101111101010101111202011111111111111404060404040404040404040404040010101010101015151
51515101010101515111111111101030301111101140111140a13232a132323232323232a1a1a1a1a13232a1324332a1423232323232a03232a0323232323222
20117373116011111111111160116011111110106010101111111110101111202011111111111111404040401111111111111010111111010101010101015151
51515151515151511111111121703030301111114040111140a13232a13232323232323243a13232a13232a1323232a142a0a0a0a032a03272a032a0a0a0a022
20111111116011111111111160836011111111116011111111111111111111909011111111111111404011111111111111111010101111010101010101015160
60101010108311111111111111303030301111114040114040b13232a13232323232323232a13232a13232a1323232a142323232323232323232323232323222
20202020202020202020202020202020202020202020202020601160202020202020202020202020404011111111202020201110111111010101010101515160
60101010101111111110111111303030301111114040404040a13232a13232919132323232a13232a13232a1323232a142323232323232323232323232323222
20202020202020202020202020202020202020202020202020601160202020202020202020202020404010111111202020201111111101010101010111516060
601111111111111111111111113030303011101140a1a1a1a1a13232a1323291a132323232a13232a13232a1323232a142a0a0a0a032a07232a032a0a0a0a022
20212121212121212121212121212121212121216011111111111111111111202011111111111110404010111010112020111111111111010111111111111111
111110111111111111111111113030303011101140a132323232323232323291a132323232a13232a13232a1323232a1423232323232a03232a0323232323222
20212121212121212121212121212121212121216011111111111111111111202011111111111110404010111010112020111111111111111111201111111111
111110111111101010404011117330303011111140a1323232a132a1a1a1a191a132323232a13232a13232a1323332a1423243323232a03232a0323232433222
20212121212121212121212121212121212121216011111111111111111111202011117311111110404010111111111111111111111111111111112011111110
111111111010404040404040111110303011101140a1324332a1323232433291a132323232a13232a13232a1323232a1423232323232a03232a0323232323222
20212323232123212123212123212121212321216011111111111111111111202011111111111110404010111111111111111111111120111111111120111111
111111104040404040404040111110303011101140a1323232a1323232323291a132323232a1323232323291a1a1a1a142323232323232323232323232323222
20212370232121212173212173212121217321216011111111111111111111202011111111111111818111731111111111111111111111201111731111111111
111110404040404040404040401110303011111140a1323232a1a1a1a1a13291a1a1a1a143a13232433232a1b17091a142323232323232323232727232323222
20212321232121212121212121212121212121211111111111404040111111111111111111111111717111111111111111111111111111201111111111111111
111140404040302173214040401130303011111140a1323232a1323232323232323232a132a1a1a1a1a1a1a1323232a142323232323232323233727232323222
20212321232123212123212123212121212321216011111111404040111111111111111111111110404010111111111111112011111111112011111110111111
111140404030302110102181811130303030301140a1323232a1324040323232323232a132323232323232a1323232a142323232333232327272433232323222
20212383232121212173212173212121212121216011111111114040401111111111111111111110404010111111111111111120111173111120111111111111
10114040403070211010217171113030303030118181323232a1324040323232323232a132323232324332a1323232a142323232323232337272323232323222
20212121232121212121212121212121212121216011111111114040404040111111111110101040404040101010101111111111201111111111111111111111
11114040403030212121214040303030303010117171323232a1324040323232323232a13232323232323232323232a142323232323272724332323232323222
20832121232121212121212121212121212121216011111111114040404040404040404040404040404040404040401011111111111111111111111111111111
11114040404040404040404040303030303010114091a1a1a1a1a1a1a1a1a191a13232a13232323232323232323232b142323232323372723232324332323222
60606060606060606060606060606060606060606060606060404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404091a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a142323232727243323232323232323222
30005000000060c14100410050403010000020a1a0e0a081000000500000000061c1000000000000000000004041000020304050000060a0c041000000000050
10000000418061000000000000000000000000000000000000000000000000000000000000000000000000000000000042323232727232323232323232323222
402010001000709070a0b08100000030000000004050000050103010305041609030c04020304010302060a09070a0c0100000105000704170f0810040301010
405060a0b0d030c00000000000000000000000000000000000000000000000000000000000000000000000000000000042323232323232323232323232323222
00103020000070a090404100000010200000000030d0000030000000104070910000709110000000000051000040005100403040000010809030000020405040
50505161105050410000000000000000000000000000000000000000000000000000000000000000000000000000000042323232323232323232323232323222
00200030405030a0a1b0b08100305010405021a0a0b1a08010200000000030810000318100203010004030a0a0a1a19000000000000010000000000000300000
103030900031b0900000000000000000000000000000000000000000000000000000000000000000000000000000000042323232323232323232323232323222
__gff__
0000010181810104010081000000000000000000810101000001010100000000010101000101020100000000000000000000018040014040800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030320222222222222222222222222222221
0211111101011111010111020207020202121212111112121212121212121209111111111111111102111111111107020303030703030303030304030303030303111111111111111111111111010101111111111111111111111111110101011111111111111111111111111111010324232323232323232323232323232322
0211111212121212121212020212020202123712121212010138111111010102020202021111111102021102020202020311111111111111030304030303030303111111113711111111111111111111111111111111011111371111111111111111111111110111111111011111110324233323232323232323232323332322
0211061201011212010112020212020202120111020202020202020202020202020202021111111111021111110211020311111111111111110304030311111111111111010101111111111111011111111111111111111111111111111111111111111111111111111111111111110324232323232323232323232323232322
0211061201011212010112020212020202120111111111111102011111110102020202111111381111020211110211020311111101111111110404111111110111110101110303030303031111111101011111111111010103030303030303031414141414141414141414141411110324232323342323232323233423232322
0211111201011212010112020212020202120112121237120102011112110102020211111111111111110238110238020311371101011137110404111111111111111111110311111138031111111111111101030303030314141414141414141414111111111111111111110111110324232323232323232323232323232322
0211061212121212121212020238020202120111111111120102011112110102021111111102021111110211110211020311111111011111010404111111111111111111110303030338031101110103030303141414141414141111111114141411111111111111111111111111110324232323232323232323232323232322
0211061211111112060612020212020202120111020111120102011137110102021111110202111111020211110211020311111111111111110404110111110303111111110301010301031111111103031414141111111138181837111818111111111111111411113711141411110324232323342323232323233423232322
0211111211111112121212020238020202120111020111120102011112110102021111021111111102021111110211020311011111111111111818111111010303111111110311110338031137011103031411111111111111171711111717111111110111381411111111141438110324232323232323232323232323232322
0202021302021111111112121212110202120111020138120102011112380102021111371111111102113711020211020311111111111111111717111111030303010101110301110338031111111103031411113701111111111411111414141411111111111411111111111111110324233323232323232323232323332322
0202021302020111110111110111110202121211061111121102111112111102021111111111111111111111111111020311111111111111110404030303030303111111110311110301031111010103031411111111111111111412121414141414111111111414111111111111110324232323232323232323232323232322
0202021302020202020202020202020202110111061111011102111112111102020202020202020202020202020202020311111111111616110404030303030303030312030311110311030311011103031414141414141414141412121414141414141414141414141414141414140321252525252525252525252525252520
02020213020202020202020202020202021111380611110111021111011111020202020202020202020202020202020303111111111116111104040303030303030303120303111103110303111111031414141414141414141414121214141414141414141414141414141414141403240a0a0a0a0a0a23230a0a0a0a0a0a22
02020213020208080808080808080802021101110611110111021111011111111111060606060606060606060606031111111111111111161104041111111103031111111111111103111103111111031411111111111111111111110111111414141111111111111818181111111103240a0a0a0a0a0a23270a0a0a0a0a0a22
02020213020212121212121206121212121101110611113711021111011111111111111106060404040404040603111111111111111116111104041111011103031101111111111103031103111111031411110111111414141414111101011414141111110111111717171114111103240a0a232323232323232323230a0a22
02121212121212111111111106111112121101110611110111021111381111111111111106040404040404040403111111111101111111161104041111111103031111111111110111031103110111031411110114141414141414140101011414141411111111111414141414111103240a0a232334232323233423230a0a22
0212111111111111061111111111111212110111061111011102111111111111111111111104040404040404040311111111111111011611110404111111110303030303030311111103110311111103140111011414141414141414010101141414141111111414141401010111110324232723232323232323232323232322
0212111111111111061137111111111212111111063811111102111101111111111111111104040404040404040311110101011111111116010404111111111111111111110311381103110111111103140111011414141414141414141401141414071111141414141111371111110324232323232323232323232323272322
02121111113711110611370606060606060606060638111111111111371111111111111111040404040404040403111101010111113716010104041111121111111111111103111111031101370101031401110101141414141414010114141414141414141414111111111101011403240a0a232334232323233423230a0a22
02060606063706060611371111061212121111370611011111111111011111111111111111110404040404040316161616161616161616161104040303120303031111011103111111030303030303031401371111011414141437111111111414141414141411111111011414141403240a0a232323232323232323230a0a22
02121111113711110611111111061202021111110611011102111111111111111111111111111104040404071116111101110111110116111104041111121103031111371103111111111111111101031401110101010114141111111101011414141414141411111114141411111103240a0a0a0a0a0a27230a0a0a0a0a0a22
02120606061111110606061111061202021111110611011102111111111111111111111111113711040403111111111111010111010111161104041111111103031111111103111101111111381101031411011111110111011101110111111111010114141111110111111111111103240a0a0a0a0a0a23230a0a0a0a0a0a22
02121212121212121212121212121202021111110611111102111111111111111111111111111111040416161616161616161611111116110104041111111103031111111103111111111101111111031414010101010111110111111101010101010101141111111111111111011103240a0a0a0a0a232323230a0a0a0a0a22
02021302020202020202020202021302020202020202020202020202020202020202020202020202040416161616161616161611111111160104040303030303031111111103111111030303030303031414141414141414141414141414141403111111141414141414141411111103240a2323232323232323232323230a22
02021302020202020202020202021302020202020202020202020202020202020202020202020202040416161616161616161611111116161104040303030303031101111103111111030303030303030303030303030303030303030303030303111111141414141414141411111103240a2323332323232323232327230a22
020213020202020202020202020213020212121212120211111111111111111111111111111111110404111111111111111111111111111111040411111111030311111111031111110311110101030303011101111111111111110111060703031111111411113711111114111111032423232334230a0a0a0a0a2323232322
02383838383838383838383802111102021212121212021111111111010101111111111111111104040411111111111111111111111111111104041111111103031111111103111111031101111212121211111111111111111111111106110303111111141111111111011411111103242323232323233323230a2323232322
02381111111111111111113802111102020202021212021111110211010101111111010111111104041137111111111111111111111111111104111111111103031111111103111111031101111103030311111111111101111111111106110303111111141111141411111411110103242323232323233423230a2323232322
023811111111371111111138021111020202120212120211111102111111111111110101111111040411111111111111111111161616161616041111111111030311111111111111110311111101030303111111111111111111111111111103031111111411111414111114111101032423232323230a0a0a0a0a2323232322
02381111111111111111113802111102020212021111111137110202020202020211010111111604041616161616161616111116161111110404111111371111111111371111113711031111370111030311111132111111321111113211110303011111141111141411111411110103240a2327332323232323232334230a22
02383838383838383838383802111102020238021101010101110211371111111111110111111604040111111111010111111116161137110404111111111111111111110111111111031111110111030301111137110111381111113711110303011111141111141411111401111103240a2323232323232323232323230a22
02020202020202020202020202111102020212021111111111110201010111111111111111110404040111010111111111111116161111110404111111111111111101111111111111111111110111030311111111111111111111111111110303010111141101141411111411111103240a0a0a0a0a232323230a0a0a0a0a22
__sfx__
000100001161011620116301162011610000000000000000046000000000000000000000000000000000000023600000000000000000000000000000000000002460000000000000000000000000000000000000
000200003e2403e2403d2403b2403824036240302402c2302722022210212003310035100371003a1003d1003f1003f1003f1003f1003f1003f1003f100285002550023500215002150000000000000000000000
00060000285402c5402e54031530365303b5203f5003550037500395003a5003c5003c5003230029600256002460022600323000000000000000000000034300000002d300000000000000000000000000000000
000300003134031340303402f3402e3402d3402c3402b3402934027340253402334021340203401d3301b330193301732014320123100f3100c3000a300053000330002300000000000000000000000000000000
000200002c6502e65031650336503665037650336502e6502a6502a6502a6502c6502d6502b6502b6502d650306502d6502f6502c6502f65034650316503065032650356503565023650186500f6500e6500d650
000100003f6403f6403f6403f6403d6403b640386403664032640316402e6402b640296402564023640226401d6401b640186401564012640106400e6400c6400a63006620056100161000000000000000000000
00060000295602e560355502a600000000000000000000000000000000380000000000000000002f100000000000034200000000000000000333000000000000324003b500000003470000000000000000000000
002000002e4402e40026400000002e4402640026400000002e4402e40026400000002e440264002e4002e4002e4402e40000000000002e44000000000002e4002e4402e40000000000002e440000000000000000
001800001c7601c760167601676016760167601676015760157601576015750157401572015710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001d55021550275502e550335503a5503f55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000151502a150271502115020150281502c15030150301503010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003a7503d7503f7503f7503f7503f7503e7503b750357503075029750217500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400001f3202232024320273201f3202232024320273201f3202232024320273201f3202232024320273202a3202d32024320273202a3202d32024320273202a3202d32024320273202a3202d3202432027320
001400001303013030130301303013030130301303013030170301703017030170301a0301a0301a0301a03019030190301903019030120301203012030120301203012030120301203012030120301203012030
011400001d3202032026320273201d3202032026320273201d3202032026320273201d320203202632027320283202b3202632027320283202b3202632027320283202b3202632027320283202b3202632027320
011400001103011030110301103011030110301103011030110301103011030140301403014030190301903018030180301803018030100301003010030100301003010030100301003010030100301003010030
011400001c3201f32024320263201c3201f32024320263201c3201f32024320263201c3201f32024320263201a3201f32024320263201a3201f32024320263201a3201f32024320263201a3201f3202432026320
011400000f0300e0300f0300f0300f0300f0300f0300f0301303013030130301b0301b0301b0301a0301a0300e0300d0300e0300e0300e0300e0300e0300e0301303013030130300e0300e0300e0300d0300d030
01140000183201e32021320243201d32021320243202732021320243202732024320273202a320273202a3202d3202a3202d32030320000000000000000000000000000000000000000000000000000000000000
011400000e030120301503012030150301803015030180301b030180301b0301e030210301e0301b030180301b030180301503011030000000000000000000000000000000000000000000000000000000000000
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
01 10 11 43 44
00 12 13 43 44
00 14 15 43 44
02 16 17 43 44
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
