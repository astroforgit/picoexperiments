pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--max by ghostronaut
--toyboxjam 2019
local _tok={
['true']=true,
['false']=false}
function nop() return true end
local _g={
cls=cls,clip=clip,map=map,print=print,line=line,spr=spr,sspr=sspr,pset=pset,rect=rect,rectfill=rectfill,sfx=sfx,flr=flr,rnd=rnd
}
local table_delims={['{']="}",['[']="]"}
local function match(s,tokens)
for i=1,#tokens do
if(s==sub(tokens,i,i)) return true
end
return false
end
local function skip_delim(str, pos, delim, err_if_missing)
if sub(str,pos,pos)!=delim then
return pos,false
end
return pos+1,true
end
local function parse_str_val(str, pos, val)
val=val or ''
local c=sub(str,pos,pos)
if(c=='"') return _g[val] or val,pos+1
return parse_str_val(str,pos+1,val..c)
end
local function parse_num_val(str,pos,val)
val=val or ''
local c=sub(str,pos,pos)
if(not match(c,"-xb0123456789abcdef.")) return tonum(val),pos
return parse_num_val(str,pos+1,val..c)
end
function json_parse(str, pos, end_delim)
pos=pos or 1
local first=sub(str,pos,pos)
if match(first,"{[") then
local obj,key,delim_found={},true,true
pos+=1
while true do
key,pos=json_parse(str, pos, table_delims[first])
if(key==nil) return obj,pos
if first=="{" then
pos=skip_delim(str,pos,':',true) 
obj[key],pos=json_parse(str,pos)
else
add(obj,key)
end
pos,delim_found=skip_delim(str, pos, ',')
end
elseif first=='"' then
return parse_str_val(str,pos+1)
elseif match(first,"-0123456789") then
return parse_num_val(str, pos)
elseif first==end_delim then  
return nil,pos+1
else  
for lit_str,lit_val in pairs(_tok) do
local lit_end=pos+#lit_str-1
if sub(str,pos,lit_end)==lit_str then return lit_val,lit_end+1 end
end
end
end
function init_game_data() game_settings() txtdat() scn_data() objects() player()
end
function game_settings()
game=json_parse'{"started":false,"start_scn":1,"g":0.2,"g_on":false,"cursc":0,"testint":1,"err":false,"over":false,"err_msg":"","ed":35}'
game.cor_cg=cocreate(cp_gl)
game.init=function(self)
self.cursc=self.start_scn
for scn in all(scns) do
if scn.init then
scn:init() end end
for pipe in all(pipes) do
add(go,pipe)
end
for enemy in all(enm) do
add(go,enemy) end end
game.update=function(self)
for scn in all(scns) do
if game.cursc==scn.id then
scn:update() end end
for block in all(tb) do
for item in all(block) do
if item.pl then
item.x=pl.x-40
item.y=pl.y-16
item.col=6 end end end end
game.draw=function(self)
cls()
for scn in all(scns) do
if game.cursc==scn.id then
scn:draw()
end
end
if self.err then
rect(30,40,30+#self.err_msg*4,40+7,5)
rectfill(29,39,29+#self.err_msg*4,39+7,0)
print(self.err_msg,30,40,7) 
self.ed-=1 
if self.ed<=0 then 
self.err=false 
self.ed=35
end
end
end
end
function _init()
init_game_data()
game:init()
end
function _update60()
game:update()
end
function _draw()  
game:draw()
end
function ptb(_tb)
for i=2, #_tb do
local tbi_txt=_tb[i].txt
local tbi_col=_tb[i].col
local tbi_x=_tb[i].x
local tbi_y=_tb[i].y
if (i==2 and _tb[i].d>0) _tb[i].d-=1
if _tb[i].d==0 then
if not _tb[i].anim then
_tb[i].c=#tbi_txt
if _tb[1].single then
if _tb[i].d==0 then
if i<#_tb and _tb[i+1].d>0 then
print(tbi_txt,tbi_x,_tb[i].y,tbi_col)
end
if (i==#_tb) print(tbi_txt,tbi_x,tbi_y,tbi_col)
end
else
print(tbi_txt,tbi_x,tbi_y,tbi_col)
end
else
if (_tb[i].c<#tbi_txt) _tb[i].c+=1
if _tb[1].cur then
cur.x=_tb[i].c*4+tbi_x
cur.y=tbi_y-1
end
if (_tb[1].dialog) print(sub(tbi_txt,1,_tb[i].c),tbi_x+1,tbi_y+1,0)
print(sub(tbi_txt,1,_tb[i].c),tbi_x,_tb[i].y,tbi_col)
end
if (i<#_tb and _tb[i+1].d>0 and _tb[i].c==#tbi_txt) _tb[i+1].d-=1
if (i<#_tb and _tb[i+1].d==0 and _tb[1].single) _tb[i].c=-1
if _tb[i]==_tb[#_tb] then
if (_tb[i].d==0) _tb[1].complete=true
end
end
end
end
function wait(f)
for i=1,f do
yield()
end
end
function cp_gl()
while true do
line(0,2,127,2,1)
uit.x_off+=rnd(4)+1
sfx(15)
wait(1)
rectfill(0,10,60,127,1)
sfx(17)
wait(5)
line(80,19,127,19,1)
uit.x_off-=rnd(4)+1
sfx(16)
wait(1)
line(30,50,90,50,1)
uit.x_off=20
sfx(15)
wait(1)
end
end
function cur_blink()
while true do
cur.visible=true
wait(15)
cur.visible=false
wait(15)
end
end
function center(_str,_coor)
if (_coor=="x") new_coor=63-#_str*2
if (_coor=="y") new_coor=61
return new_coor
end
function coli(obj1,obj2,_xrad,_yrad)
if _xrad==nil then xrad=0 else xrad=_xrad end
if _yrad==nil then yrad=0 else yrad=_yrad end
local collide=false
if contains(obj1.scns,game.cursc) and contains(obj2.scns,game.cursc) then
local xs=obj1.w*8/2+obj2.w*8/2
local ys=obj1.h*8/2+obj2.h*8/2
local xd=abs((obj1.x+(obj1.w*8/2))-(obj2.x+(obj2.w*8/2)))               
local yd=abs((obj1.y+(obj1.h*8/2))-(obj2.y+(obj2.h*8/2)))
if xd<xs+xrad and yd<ys+yrad then collide=true 
else collide=false end
else
collide=false
end
return collide  
end
function bh(x1,y1,w1,h1,x2,y2,w2,h2)
local collide=false
local xs=w1*8/2+w2*8/2
local ys=h1*8/2+h2*8/2
local xd=abs((x1+(w1*8/2))-(x2+(w2*8/2)))               
local yd=abs((y1+(h1*8/2))-(y2+(h2*8/2)))
if xd<xs and yd<ys then collide=true 
else collide=false end
return collide  
end
function check_col(axis,coor)
local collided=false
if axis=="x" then
for obj in all(go) do 
if obj.solid and contains(obj.scns,game.cursc) then
if bh(coor,pl.y,pl.w,pl.h,obj.x,obj.y,obj.w,obj.h) then
collided=true
end
end
end
end
if axis=="y" then
for obj in all(go) do
if obj.solid and contains(obj.scns,game.cursc) then
if bh(pl.x,coor,pl.w,pl.h,obj.x,obj.y,obj.w,obj.h) then
collided=true
end
end
end
end
return collided, obj
end
function contains(table, val)
for index, value in pairs(table) do
if value == val then
return true
end
end
return false
end
function err(_msg)
game.err=true
game.err_msg=_msg
end
function handle_obj(handle,self)
for obj in all(go) do
if obj.scns and contains(obj.scns,self.id) then
if (handle=="update" and obj.update) obj:update()
if (handle=="draw" and obj.draw) obj:draw()
end
end
end
function hic(_item,_other,_self)
if _item.state!="taken" then
_item.state="taken"
end 
if _item.state=="taken" and ci_c.on and coli(_self,ci_c) then
_item.state="commented"
err("code err")
end 
if _item.state=="taken" and not _item.col_i.on and coli(_self,_item.col_i) then
_item.state="idle"
end
if _item.state=="taken" and coli(_self,_other.col_i) and not coli(_item,_other) then
_item.state="idle"
_item.switched=true
err("code err")
end
end
function hiu(_item)
if _item.state=="idle" then
if not _item.switched then
_item.x=_item.x_init
_item.y=_item.y_init
else
if _item==i_t then
_item.x=i_f.x_init
_item.y=i_f.y_init
end
if _item==i_f then
_item.x=i_t.x_init
_item.y=i_t.y_init
end
end
_item.col=6
_item.col_i.on=true
end
if _item.state=="taken" then
_item.x=cur.x
_item.y=cur.y
_item.col=12
ci_c.on=true
_item.col_i.on=false
end
if _item.state=="commented" then
_item.x=11
_item.y=59
_item.col=13
ci_c.on=false
end
end
function cplp(self)
local check=false
if self.solid then
if pl.y==self.y then
check=true
else
check=false
end
else
check=true
end
return check
end
function cplp_cur()
local check=false
if game.cursc==6 then
if pl.x>70 then
check=true
else
check=false
end
else
check=true
end
return check
end
function rand (...)
local args={...}
local r=flr(rnd(#args)+1)
return args[r]
end
function rotate_spr(obj)
while true do
obj.y+=2
wait(10)
obj.y-=2
wait(10)
end
end
function txtdat()
tb={}
it1=json_parse'[{"id":0,"x":5,"y":9,"lh":6,"col":6,"single":false,"anim":true,"complete":false,"cur":false},{"id":1,"txt":"game developer max tojoby","d":20},{"id":2,"txt":"went missing 32 years ago.","d":15},{"id":3,"txt":"no one knows what happened.","d":60,"lb":1},{"id":4,"txt":"all he left behind is a disk","d":60},{"id":5,"txt":"containing assets for an","d":15},{"id":6,"txt":"unfinished pico8 game.","d":15},{"id":7,"txt":"in his honor, game developers","d":60,"lb":1},{"id":8,"txt":"around the world will take","d":25},{"id":9,"txt":"part in a toy box jam and","d":25},{"id":10,"txt":"make games out of the assets","d":25},{"id":11,"txt":"max left behind.","d":25},{"id":12,"txt":"you are one of them.","d":130,"lb":2},{"id":13,"txt":"PRESS — TO OPEN PICO8","d":80,"x":"center","y":115,"anim":false,"col":5}]'
it2=json_parse'[{"id":0,"x":1,"y":20,"lh":6,"col":6,"single":false,"anim":false,"complete":false,"cur":true},{"id":1,"txt":"pico-8 0.1.12c","d":10},{"id":2,"txt":"(c) 2014-19 lexaloffle games llp"},{"id":3,"txt":"type help for help","lb":1,"d":10},{"id":4,"txt":">","lb":1,"col":7,"d":10},{"id":5,"txt":"load startcart","col":7,"d":50,"x":10,"y":50,"anim":true},{"id":6,"txt":"loaded startcart.p8 (1118 chars)","d":50,"anim":false},{"id":7,"txt":">","col":7,"anim":true},{"id":8,"txt":" ","x":5,"y":63,"col":7,"anim":true},{"id":9,"txt":" ","x":5,"y":63,"col":7,"anim":true,"d":80}]'
tb1=json_parse'[{"id":0,"x":1,"y":9,"lh":6,"col":13,"single":false,"anim":false,"complete":false,"cur":false},{"id":1,"txt":"-- toy box jam start cart\n-- by that tom hall & friends\n-- sprites/sfx/code: that tom hall\n-- sprites/sfx: lafolie\n-- platforming anims: toby hefflin\n-- music: gruber\n-- additional code: see functions\n-- if you did a function that is\n-- uncredited, let me know!\n-------------------------------\n-- this contains a set of\n-- creative assets to play\n-- with. everyone has the same\n-- set of toys... what will\n-- you make of em?\n-------------------------------\n-- resources:\n--\n-- random useful sprites"}]'
tb2=json_parse'[{"id":0,"x":1,"y":9,"lh":6,"col":13,"single":false,"anim":true,"complete":false,"cur":true},{"id":1,"txt":"-- my project for toy box jam"},{"id":2,"txt":"-- ideas:","d":50},{"id":3,"txt":"-- space shooter?","d":50}]'
tb3=json_parse'[{"id":0,"x":"center","y":"center","lh":6,"col":7,"single":true,"anim":false,"complete":false,"cur":false},{"id":1,"txt":"out of memory","x":"center","y":"center"},{"id":2,"txt":"uot fo mmeory","x":"center","y":"center","d":50},{"id":3,"txt":"me ory","x":63,"y":63,"d":50},{"id":4,"txt":" ","x":63,"y":63,"d":50}]'
tb4=json_parse'[{"id":0,"x":1,"y":1,"lh":6,"col":6,"single":true,"anim":true,"complete":false,"cur":false,"dialog":true},{"id":1,"txt":"UM.\nWHAT JUST HAPPENED?","d":50},{"id":2,"txt":"WHERE AM I?","d":80},{"id":3,"txt":"ARE THOSE...","d":50},{"id":4,"txt":"MY THOUGHTS \nWRITTEN BELOW ME?","d":50},{"id":5,"txt":"WHY DO I LOOK LIKE...","d":100},{"id":6,"txt":".","d":50},{"id":7,"txt":"..","d":50},{"id":8,"txt":"...","d":50},{"id":9,"txt":"OH NO.","d":80},{"id":10,"txt":" ","d":80},{"id":11,"txt":"I NEED TO GET OUT\nOF HERE SOMEHOW...","d":300},{"id":12,"txt":" ","d":100},{"id":13,"txt":"MAYBE I CAN GET INTO THAT\nMENU BAR SOMEHOW","d":1200},{"id":14,"txt":" ","d":200}]'
tb5=json_parse'[{"id":0,"x":-1,"y":53,"lh":6,"col":6,"single":false,"anim":false,"complete":false,"cur":false," dialog":false},{"id":1,"txt":"// ui menu top","col":13,"x":1},{"id":2,"txt":" --","col":13},{"id":3,"txt":"x1=3"},{"id":4,"txt":"x2=10"},{"id":5,"txt":"solid=","x":1},{"id":6,"txt":"r=flr(rnd(20))","x":-35},{"id":7,"txt":"col1=7","x":-5},{"id":8,"txt":"rand="},{"id":9,"txt":"col2=15","x":-6},{"id":10,"txt":"col3=8","x":-5},{"id":11,"txt":"self)","x":-4}]'
tb6=json_parse'[{"id":0,"x":10,"y":65,"lh":0,"col":12,"single":true,"anim":true,"complete":false,"cur":false,"dialog":true},{"id":1,"txt":"OH HEY, YOU THERE!"},{"id":2,"txt":"HOW ARE YOU? LOOKING SHARP!","d":100},{"id":3,"txt":" ","d":100},{"id":4,"txt":"WHO...","pl":true},{"id":5,"txt":"CAN YOU GET ME OUT OF HERE?","d":80},{"id":6,"txt":"I DON\'T...","d":80,"pl":true},{"id":7,"txt":"I THINK YOU CAN TURN OFF\nSPRITE SELECTION SOMEWHERE...","d":80},{"id":8,"txt":"DON\'T THINK I\nREMEMBER WHERE EXACTLY...","d":100},{"id":9,"txt":"","d":100}]'
tb6_2=json_parse'[{"id":0,"x":10,"y":65,"lh":0,"col":12,"single":true,"anim":true,"complete":false,"cur":false,"dialog":true},{"id":1,"txt":"OH, I WOULDN\'T GO IN THERE..."},{"id":2,"txt":"WHY NOT?","d":100,"pl":true},{"id":3,"txt":"ON SECOND THOUGHT,\nDEFINITELY GO IN THERE.","d":100},{"id":4,"txt":"UM, NOT THAT\nREASSURING.","d":100,"pl":true},{"id":5,"txt":"NO NO, REALLY.\nI SET UP THE SPRITE PIPES\n","d":100},{"id":6,"txt":"SO I COULD REACH TAB 0.","d":100},{"id":7,"txt":"I USE THEM ALL THE TIME,\nCOMPLETELY SAFE.","d":100},{"id":8,"txt":"","d":100}]'
tb6_3=json_parse'[{"id":0,"x":10,"y":65,"lh":0,"col":12,"single":true,"anim":true,"complete":false,"cur":false,"dialog":true},{"id":1,"txt":"GREAT, YOU GOT THE KEY!"},{"id":2,"txt":"DUDE, THAT\nGREEN THING!?","d":100,"pl":true},{"id":3,"txt":"OH RIGHT, TOTALLY FORGOT\nABOUT THAT.","d":100},{"id":4,"txt":"YEAH THAT THING IS\nCRAZY DANGEROUS.","d":100},{"id":5,"txt":"WELL THANKS.","d":100,"pl":true},{"id":6,"txt":"NOT TO WORRY!","d":100},{"id":7,"txt":"SO WHAT WAS THAT\nKEY FOR AGAIN...","d":100},{"id":8,"txt":"","d":100}]'
tb6_4=json_parse'[{"id":0,"x":10,"y":65,"lh":0,"col":12,"single":true,"anim":true,"complete":false,"cur":false,"dialog":true},{"id":1,"txt":"TRY BUTTON Ž as in 0"},{"id":2,"txt":"SOME KIND OF BUG","d":100},{"id":3,"txt":"...","d":100,"pl":true},{"id":4,"txt":"","d":100}]'
tb7=json_parse'[{"id":0,"x":-1,"y":53,"lh":6,"col":6,"single":false,"anim":false,"complete":false,"cur":false," dialog":false},{"id":1,"txt":"// general settings","col":13,"x":1},{"id":2,"txt":" --","col":13},{"id":3,"txt":"(atan2(4,0))"},{"id":4,"txt":"var3"},{"id":5,"txt":"sprite_selection=","x":1},{"id":6,"txt":"mxwuzhre","x":-35},{"id":7,"txt":"2.3222","x":-5},{"id":8,"txt":"gravity="},{"id":9,"txt":"max(b)","x":-6},{"id":10,"txt":"frict=0.1","x":-5},{"id":11,"txt":"self)","x":-4}]'
tbx=json_parse'[{"id":0,"x":52,"y":68,"lh":0,"col":6,"single":true,"anim":true,"complete":false,"cur":false,"dialog":true},{"id":1,"txt":"HELLO?","d":100},{"id":2,"txt":"","d":100},{"id":3,"txt":"","d":50}]'
tb8=json_parse'[{"id":0,"x":10,"y":86,"lh":0,"col":12,"single":true,"anim":true,"complete":false,"cur":false,"dialog":true},{"id":1,"txt":"PHEW, THANKS!"},{"id":2,"txt":"WAS STUCK IN THERE FOR\nQUITE A WHILE.","d":50},{"id":3,"txt":"DON\'T EVEN REMEMBER HOW\nTHAT HAPPENED.","d":130},{"id":4,"txt":"I SEE YOU ALSO TURNED\nON GRAVITY.","d":130},{"id":5,"txt":"KINDA NICE TO FEEL ONE\'S\nOWN BODY WEIGHT FOR A CHANGE.","d":80},{"id":6,"txt":" ","d":80},{"id":7,"txt":"SO, WHO ARE YOU?","d":130,"pl":true},{"id":8,"txt":"I\'M MAX! WHO ARE YOU?","d":130},{"id":9,"txt":"I\'M...WAIT. MAX?","d":80,"pl":true},{"id":10,"txt":"MAX!","d":80},{"id":11,"txt":"THE MAX?","d":80,"pl":true},{"id":12,"txt":"MHM, NOT SURE.\nDEFINITELY A MAX THOUGH.","d":130},{"id":13,"txt":"HOW THE HELL\nDID YOU GET HERE?","d":130,"pl":true},{"id":14,"txt":"AND HOW DID I?","d":130,"pl":true},{"id":15,"txt":"HOW DO I GET OUT?","d":130,"pl":true},{"id":16,"txt":"WOOOH, YOU\'VE GOT\nALL THE QUESTIONS.","d":130},{"id":17,"txt":"LET\'S SEE ...\nAH YEAH, SO I WAS\nWORKING ON MY GAME.","d":130},{"id":1,"txt":"AND THEN THE SYSTEM\nCRASHED AND NOW I\'M...\nHERE?","d":130},{"id":19,"txt":"AND YOU\'VE BEEN\nIN HERE ALL THIS TIME?","d":130,"pl":true},{"id":20,"txt":"WELL NO NEED TO EXAGGERATE.\nCOULD ONLY HAVE BEEN\nA FEW HOURS AT MOST.","d":130},{"id":21,"txt":"UM...DUDE IT\'S 2020.","d":150,"pl":true},{"id":22,"txt":"HAHA, YEAH RIGHT.","d":130},{"id":23,"txt":"...","d":130,"pl":true},{"id":24,"txt":"SO HAVE YOU MADE\nANY PROGRESS IN GETTING OUT?","d":130,"pl":true},{"id":25,"txt":"WHAT DO YOU MEAN\nGETTING OUT?","d":130},{"id":26,"txt":"OUT! BACK INTO THE REAL WORLD!","d":130,"pl":true},{"id":27,"txt":"AH, THAT OUT.\nNO NOT REALLY.","d":130},{"id":28,"txt":"SERIOUSLY?\nSO I\'M STUCK HERE AS WELL?","d":130,"pl":true},{"id":29,"txt":"WELL THERE\'S ALWAYS\nREBOOTING THE SYSTEM.","d":130},{"id":30,"txt":"WAIT, YOU HAVEN\'T TRIED THAT?","d":130,"pl":true},{"id":31,"txt":"OF COURSE NOT, I HAVEN\'T\nEVEN SAVED THE GAME YET.","d":130},{"id":32,"txt":"I WOULD LOSE HOURS OF WORK!","d":130},{"id":33,"txt":"THAT IS YOUR CONCERN\nRIGHT NOW?","d":130,"pl":true},{"id":34,"txt":"WE NEED TO REBOOT! NOW!","d":130,"pl":true},{"id":35,"txt":"NO WAY!","d":130},{"id":36,"txt":"YES!","d":130,"pl":true},{"id":37,"txt":"OKAY OKAY!\nWOW, YOU ARE CONVINCING.","d":130},{"id":38,"txt":"SO...HOW?","d":130,"pl":true},{"id":39,"txt":"HOW WHAT?","d":130},{"id":40,"txt":"THE REBOOT.","d":130,"pl":true},{"id":41,"txt":"AH. WELL YOU COULD\nTRY THE OFF SWITCH.","d":130},{"id":42,"txt":"THE...OF COURSE THERE IS\nAN OFF SWITCH. WHERE?","d":130,"pl":true},{"id":43,"txt":"YEAH, SHOULD BE ON\nSPRITE PAGE 0 SOMEWHERE.","d":170},{"id":44,"txt":"DOES THAT MEAN...\nTHE PIPES AGAIN?","d":130,"pl":true},{"id":45,"txt":"OH, YOU KNOW\nABOUT MY PIPES?","d":130},{"id":46,"txt":"I...NEVERMIND.","d":130,"pl":true},{"id":47,"txt":"NO NEED THOUGH, YOU SHOULD\nBE ABLE TO WALK RIGHT OVER.","d":130},{"id":48,"txt":"TURNING OFF GRAVITY SOMEHOW\nSHIFTED ... SOMETHING.","d":130},{"id":49,"txt":" ","d":100},{"id":50,"txt":"GO AHEAD, I\'LL CATCH UP!","d":100},{"id":51,"txt":"","d":100}]'
tb9=json_parse'[{"id":0,"x":10,"y":65,"lh":0,"col":12,"single":true,"anim":true,"complete":false,"cur":false,"dialog":true},{"id":1,"txt":"WHY IS IT NOT WORKING?","pl":true},{"id":2,"txt":"NOT SURE. IT SHOULD!","d":100},{"id":3,"txt":"MAYBE...KEEP PRESSING?","d":150},{"id":4,"txt":" ","d":100}]'
tb={it1,it2,tb1,tb2,tb3,tb4,tb5,tb6,tb6_2,tb6_3,tb6_4,tb7,tbx,tb8,tb9}
for tbi in all(tb) do
for item in all(tbi) do
if item.id!=0 then
if (item.anim==nil) item.anim=tbi[1].anim
if (not item.col) item.col=tbi[1].col
if (not item.x) item.x=tbi[1].x
if (not item.d) item.d=1
item.c=1
if (item.x=="center") item.x=63-#item.txt*2
if (item.y=="center") item.y=61
if (not item.y and item.id==1) item.y=tbi[1].y
if (not item.y) item.y=tbi[item.id].y+tbi[1].lh
if (item.lb) item.y=tbi[item.id].y+tbi[1].lh*(item.lb+1)
if tbi[1].single then
if (not item.y) item.y=tbi[1].y
end
end
end 
end
end
function scn_data()
scns={
{
id=1,
scn=1,
tmr=0,
scncol=0,
update=function(self)
handle_obj("update",self)
if self.scn==1 then
if btnp(—) and (it1[1].complete) then
self.scn=2
sfx(12)
end
end
if self.scn==2 then
self.scncol=0
if (it2[6].d>0) cur.x=9 cur.y=49
if (it2[1].complete) self.scn=3
end
if self.scn==3 then
self.scncol=1
if self.tmr<=1 then 
cur.x=cur.xinit
cur.y=cur.yinit
end
self.tmr+=1
for i=100,135,5 do
if (self.tmr==i) tb1[2].y+=6 cur.y+=6
end
for i=180,215,5 do
if (self.tmr==i) cur.y-=6
end
if self.tmr==500 then
self.scn=4
end
end
if self.scn==4 then
self.tmr+=1
if (tb3[1].complete and self.tmr>=240) game.cursc=5
end
end,
draw=function(self)
rectfill(0,0,127,127,self.scncol)
if self.scn==1 then
ptb(it1)
end
if self.scn==2 then
rectfill(0,0,127,127,0)
if (it2[5].d==0) cur:draw()
ptb(it2)
end
if self.scn==3 then
rectfill(0,0,127,127,1)
handle_obj("draw",self)
ptb(tb1)
if (self.tmr>=250) ptb(tb2)
if (self.tmr>=400) coresume(game.cor_cg)
uib:draw()
end
if self.scn==4 then
ptb(tb3)
end
end
},
{
id=5,
tmr=0,
ctmr=0,
m_st=false,
update=function(self)
if not self.m_st then
music(12)
self.m_st=true
end
self.tmr+=1
handle_obj("update",self)
pl:update()
for i=1, #tb4 do
tb4[i].x=pl.x
tb4[i].y=pl.y+10
end
if game.g_on then
nmx:update()
if self.ctmr<=0 then
nmx.x=130
nmx.y=111
end
self.ctmr+=1
if nmx.x>80 then
nmx.x-=1
coresume(nmx.cor_rotate, nmx)
else
nmx.yflip=false
end
if pl.x>=117 then
game.cursc=7
pl.x=0
pl.y=112
ss.page=0
end
end
end,
draw=function(self)
rectfill(0,0,127,127,1) 
handle_obj("draw",self)
pl:draw()
if game.g_on then
nmx:draw()
ptb(tb8)
else
ptb(tb4)
if self.tmr>=700 then
	print("       // pico8 menu\n            controls\n\n   activate=btn(—)\n   special=btn(Ž)\n   navigate=(‹‘”ƒ)\n   -------",40,70,13)
end
end
end
},
{
id=6,
tmr=0,
false_taken=false,
locked=false,
update=function(self)
self.tmr+=1
handle_obj("update",self)
pl:update()
if self.tmr<=1 then 
cur.x=110
end
if i_t.switched and i_f.switched then
err("> error in ui config")
uit.solid=false
cur.on=false
self.locked=true
scns[4].started=true
end 
end,
draw=function(self)
rectfill(0,0,127,127,1)
handle_obj("draw",self)
pl:draw()
ptb(tb5)
end
},
{
id=7,
tmr=0,
tmr_started=false,
started=false,
printtip=false,
tiptmr=0,
ctmr=0,
addedpipe=false,
init=function(self)
for i=0,8 do
m_p(141,24+i*8,105,0,true)
end
m_p(174,96,105,2,false,true)
m_p(156,96,97,1)
m_p(156,96,89,1,false,false,true)
for i=0,2 do
m_p(156,112,88+8*i,1)
end
for i=0,5 do
m_p(141,104-i*8,112,2)
end
m_p(174,112,112,1,false,true)
m_p(156,56,104,1,true)
m_p(172,56,112,2,false,true)
m_p(140,56,96,1,false,true)
m_p(141,64,96,2)
m_p(174,72,96,2,false,true)
m_p(142,72,89,1,false,true)
for i=0,5 do
m_p(141,64-i*8,89,2)
end
m_p(140,16,89,2,false,true)
m_p(156,16,97,1)
m_p(172,16,105,1,false,true)
local ik1_x=ik1.x
local ik1_y=ik1.y
mk_en(96,ik1_x-8,ik1_y-8,false,false,0)
mk_en(102,ik1_x,ik1_y-8,false,false,0)
mk_en(104,ik1_x+8,ik1_y-8,false,false,0)
mk_en(58,ik1_x+8,ik1_y,false,false,0)
mk_en(102,ik1_x-8,ik1_y,true,false,0)
mk_en(104,ik1_x-8,ik1_y+8,true,false,0)
mk_en(58,ik1_x,ik1_y+8,false,false,0)
mk_en(96,ik1_x+8,ik1_y+8,false,false,0)
mk_en(104,40,89,false,true,2)
end,
update=function(self)
handle_obj("update",self)
pl:update()
for pipe in all(pipes) do
pipe:update()
end
if not pl.passed then
if pl.y>=96 and pl.x==16 then
pl.passed=true
end
else
if pl.x==61 and pl.y==89 then
pl.passed=false
end
end
if game.g_on then
nmx.x=60
nmx.y=79
if btnp(—) and pl.x==56 and pl.y<=90 and not game.over then
self.tmr+=1
sfx(3)
end
else
if btnp(—) and pl.gotkey1 and pl.x>=94 and pl.y<=89 then
self.printtip=true
end
end
end,
draw=function(self)
rectfill(0,0,127,127,5)
for pipe in all(pipes) do
pipe:draw()
end
handle_obj("draw",self)
pl:draw()
if self.started then
ptb(tb6)
end
if ss.page==2 and tb6[1].complete then
ptb(tb6_2)
if pl.gotkey1 and pl.y<85 then
ptb(tb6_3)  
end
end
if ss.page==0 and not game.g_on then
if pl.y<88 then pl.y=88 end
end
if game.g_on then
if pl.y<88 then pl.y=88 end
if btn(—) and pl.x==56 and pl.y>=85 then 
spr(7,70,78)
sspr(56,0,8,8,10,12,65,65)
print("0"..self.tmr,80,80,13)
self.tmr_started=true
end
if self.tmr_started then
self.tiptmr+=1
end
if not btn(—) and self.tmr_started and self.tmr<20 then
self.tmr=0
end
if self.tiptmr>=200 and self.tmr<20 then
ptb(tb9)
end
if self.tmr==20 then
sfx(12)
music(-1)
end
if self.tmr>20 then
game.over=true
cls()
self.tmr+=1
end 
if self.tmr>=150 then
palt(12,true) palt(13,true) palt(1,true) palt(14,true)
nmx:draw()
end
if self.tmr>=170 then
cls()
end
if self.tmr>=200 then
palt(12,true) palt(13,true) palt(1,true) palt(14,true)
nmx:draw()
ptb(tbx)
end
if self.tmr>=500 then
cls()
print("the end",50,61,7)
self.tmr_started=false
end
else
if self.printtip then
ptb(tb6_4)
end
end
if ss.page==2 and pl.y>85 then rectfill(0,0,127,88,0) rectfill(0,120,127,127,0) end
end
},
{
id=8,
started=false,
unlocked=false,
tmr=0,
ctmr=0,
init=function(self)
end,
update=function(self)
self.tmr+=1
if self.tmr<=1 then 
cur.x=110
cur.y=10
end
if not self.started then
i_t.x=69
i_t.item_txt="on,"
i_t.y=76
i_t.x_init=69
i_t.y_init=77
i_t.col_i.x=69
i_t.col_i.y=76
i_t.col_i.on=true
i_t.switched=false
i_t.state="idle"
i_f.item_txt="off,"
i_f.x=31
i_f.y=94
i_f.x_init=31
i_f.y_init=95
i_f.switched=false
i_f.col_i.x=31
i_f.col_i.y=94
i_f.col_i.on=true
i_f.state="idle"
ci_c.on=true
self.started=true
end
handle_obj("update",self)
pl:update()
if game.g_on then
for enemy in all(enm) do
enemy:update()
end
end       
if i_t.switched and i_f.switched then
game.g_on=true
err("error in sprite generation")
end 
end,
draw=function(self)
rectfill(0,0,127,127,1)
handle_obj("draw",self)
pl:draw()
ptb(tb7)
if game.g_on then
for enemy in all(enm) do
enemy:draw()
end
end
end
},
}
end
function objects()
go={}
cur=json_parse'{"x":0,"y":8,"w":1,"h":1,"scns":[1,6,8],"xinit":0,"yinit":8,"solid":true,"col":8,"md":5,"md_init":5,"visible":true,"on":true,"dir_switched":false}'
cur.cor_blink=cocreate(cur_blink)
cur.update=function(self)
if game.cursc==8 then
self.on=true
self.dir_switched=true
end
if self.on then
if (self.cor_blink and costatus(self.cor_blink)!="dead") coresume(self.cor_blink)
if game.cursc==6 or game.cursc==8 then
if pl.moving then
self.md-=1
if self.md<=0 then
if pl.facing=="left" then
if not self.dir_switched then self.x-=4 else self.x+=4 end
end
if pl.facing=="right" then
if not self.dir_switched then self.x+=4 else self.x-=4 end
end
if pl.facing=="up" then
if not self.dir_switched then self.y-=4 else self.y+=4 end
end
if pl.facing=="down" then
if not self.dir_switched then self.y+=4 else self.y-=4 end
end
self.md=self.md_init
end
end
if self.x<=0 then
self.x=0
end
if self.x>=124 then
self.x=123
end
if self.y<=30 then
self.y=30
end
if self.y>=114 then
self.y=114
end
if btnp(—) and cplp_cur() and not game.g_on then 
if coli(self,i_t) then 
hic(i_t,i_f,self)
sfx(03)
elseif coli(self,i_f) then 
hic(i_f,i_t,self)
sfx(03)
else
err("undefined")
sfx(04)
end
end
end
end
end
cur.draw=function(self)
if self.on and self.visible then
if game.cursc!=6 and game.cursc!=8 then
rectfill(self.x,self.y,self.x+4,self.y+5,self.col)
else
pal(6,8) pal(14,8)
spr(63,self.x,self.y,0.8,1)
end
end
end
ci_c=json_parse'{"x":0,"y":54,"w":6.25,"h":1.25,"on":true,"scns":[6,8]}'
i_t=json_parse'{"x":25,"x_init":25,"y":77,"y_init":77,"w":208,"h":0.75,"item_txt":"true,","scns":[6,8],"col":6,"switched":false,"state":"idle","col_i":{"x":25,"y":77,"w":2.5,"h":0.75,"on":true,"scns":[6,8]}}'
i_t.update=function(self)
hiu(self)
end
i_t.draw=function(self)
print(self.item_txt,self.x,self.y,self.col)
end
i_f=json_parse'{"x":19,"x_init":19,"y":95,"y_init":95,"w":2.5,"h":0.75,"item_txt":false,"scns":[6,8],"col":6,"state":"idle","switched":false,"col_i":{"x":19,"y":94,"w":2.5,"h":0.75,"on":true,"scns":[6,8]}}'
i_f.update=function(self)
hiu(self)
end
i_f.draw=function(self)
print(self.item_txt,self.x,self.y,self.col)
end
uit=json_parse'{"showrect":false,"x_off":0,"y_off":0,"x1":3,"x2":10,"y1":1,"y2":7,"tx1":0,"ty1":0,"tx2":127,"ty2":7,"d":0,"d2":0,"col1":8,"col2":15,"col3":2,"col4":14,"col_tab":14,"lock_sp":138,"solid":true,"contain":false,"scns":[1,5,6,7,8],"showtabs":false,"x":0,"y":0,"w":0,"h":0}'
uit.update=function(self)
local cursc=game.cursc
if cursc==1 then
self.showtabs=true
end
if cursc==5 then
self.x_off=27
self.y_off=20
self.d+=1
self.showtabs=true
if self.d>=rnd(50)+50 then
self.col1=9
self.showrect=true
end
if self.d>=rnd(50)+50 then
self.col1=8
self.d=0
self.showrect=false
end
if scns[2].tmr>=300 then
self.d2+=1
if self.d2>=300 then
self.y_off+=8
end
if self.d2>=340 then
self.d2=0
end
end
self.col4=14 self.col5=7
self.col2=15 self.col3=2
end
if cursc==6 or cursc==8 then
self.x_off=40
self.y_off=20
self.d+=1
self.showtabs=true
if pl.x<=40 and not btnp(—) and self.solid then pl.x=44 end
if self.d>=rnd(50)+60 then
self.col1=flr(rnd(2)+3)
self.y_off+=rnd(2)+1
self.x_off+=rnd(2)+5
end
if self.d>=rnd(50)+60 then
self.col1=8
self.d=0
end
self.tx1=2
self.col4=7 self.col5=14
end
if cursc==7 then
self.x_off=27
self.y_off=5
self.d+=1
self.showtabs=false
if self.d>=rnd(50)+60 then
self.col1=flr(rnd(2)+3)
self.y_off+=rnd(2)+1
self.x_off+=rnd(2)+5
end
if self.d>=rnd(50)+60 then
self.col1=8
self.d=0
end
self.col2=2 self.col3=15
end
if coli(pl,self) then
self.contain=true
if btnp(—) and cplp(self) then
if cursc==7 and pl.x>=80+self.x_off and pl.x<=88+self.x_off then
game.cursc=5
sfx(05)
pl.y=self.y+self.y_off+10
end
if cursc==5 and pl.x>=91+self.x_off and pl.x<=98+self.x_off then
game.cursc=7
sfx(05)
pl.y=self.y-self.y_off+5
if not self.solid and not scns[2].started then
scns[2].started=true
end
end
if pl.x>=self.tx1-2+self.x_off and pl.x<=10+self.x_off then
game.cursc=5
sfx(05)
if game.g_on then
pl.y=20
pl.x=40
pl.onground=false
end
end
if curent_scn==8 then
err("malfunction")
sfx(04)
end
if pl.x>=34 and pl.x<=42 then
if not scns[3].locked then
game.cursc=6
sfx(05)
else
err("malfunction")
sfx(04)
end
end
if pl.x>=48 and pl.x<=53 then
	if not scns[5].unlocked then
		if not pl.gotkey1 then
			err("access denied")
			sfx(03)
		else
			scns[5].unlocked=true
			pl.gotkey1=false
			ik1.used=true
			err("access granted")
			sfx(01)
		end
	else
		game.cursc=8
		sfx(05)
	end
end
if pl.x>=32+self.x_off and pl.x<=35+self.x_off then
err("undefined")
sfx(04)
end
end
else
self.contain=false
end
self.x=self.tx1+self.x_off
self.y=self.ty1+self.y_off
self.w=(self.tx2+self.x_off-self.x)/8
self.h=(self.ty2+self.y_off-self.y)/8
end
uit.draw=function(self)
local cursc=game.cursc
for i=0, 15 do
pal(1,8) 
if cursc==1 then pal(12,8) else pal(12,14) end
spr(16,(self.tx1+self.x_off)+i*8,self.ty1+self.y_off)
pal()
end
if self.showrect then
rectfill(29,22,127,30,8)
end
if self.showtabs then
for i=0,2 do 
rectfill(3+self.x_off+i*9,1+self.y_off,10+self.x_off+i*9,7+self.y_off,self.col_tab)
pset(3+self.x_off+i*9,self.y_off+1,8)
print(i,3+self.x_off+3+i*9,1+self.y_off+1,8)
end
print("+",3+self.x_off+3+27,1+self.y_off+1,14)
end
if cursc==5 then
	rectfill(30,21,37,27,7)
	pset(30,21,8)
	print("0",33,22,8)
end
if cursc==6 then
	rectfill(52,21,59,27,7)
	pset(52,21,8)
	print("1",55,22,8)
end
if cursc==8 then
	rectfill(61,21,68,27,7)
	pset(61,21,8)
	print("2",64,22,8)
end
if cursc==5 or cursc==6 then
pal(1,8)
if (scns[5].unlocked) self.lock_sp=139
spr(self.lock_sp,6+self.x_off+18,-3+self.y_off,1,0.9)
pal()
end
if cursc==7 then
rect(3+self.x_off,1+self.y_off,10+self.x_off,7+self.y_off,15)
end
if cursc!=1 then
palt(0,true) palt(5,true) palt(6,true)
pal(7,self.col2)
spr(200,79+self.x_off,self.y_off,1,0.9)
spr(200,82+self.x_off,1+self.y_off,1,0.9,true)
pal()
palt()
pal(1,8) pal(2,8) pal(5,8) pal(6,self.col3) pal(7,self.col3)
spr(117,92+self.x_off,1+self.y_off,1,0.9)
pal(1,self.col3)
spr(117,92+self.x_off,1+self.y_off,1,0.6)
pal()
end
end
uib=json_parse'{"x_off":0,"y_off":0,"solid":true,"scns":[1,5,6,7,8],"d":0,"x":0,"y":121,"w":0,"h":0,"x1":0,"x2":127,"y1":121,"y2":127}'
uib.update=function(self)
if game.cursc==5 or game.cursc==6 then
self.x_off=19
self.d+=1
else
self.x_off=0
self.d=0
end
self.x=self.x_off
self.y=121+self.y_off
self.w=(127+self.x_off-self.x)/8
self.h=(127+self.y_off-self.y)/8
end
uib.draw=function(self)
local cursc=game.cursc
for i=0, 15 do
pal(1,8)
if game.cursc==1 then pal(12,8) else pal(12,14) end
spr(16,(self.x_off)+i*8,121+self.y_off)
pal()
palt()
end
line(0,120,127,120,1)
if cursc==1 then
print("line 1/42",1,122,2)
print("37/8192",93,122,2)
end
if cursc==5 then
if self.d<=50 then
print("37/8192",93,122,2)
end
if self.d<=40 then
print("line / 28",1,122,2)
else
print("lnie 1/ 21",1,122,2)
end
if self.d>=rnd(50) then
print("3^/81 2",93,122,6)
end
if self.d>=rnd(200)+80 then
self.d=0
end
end
if cursc==6 then
if self.d<=50 then
print("3_/8?92",93,122,2)
end
if self.d<=40 then
print("line  / 20",1,122,2)
else
print("line   / 99",1,122,2)
print(flr(cur.y/7-3),21,122,2)
end
if self.d>=rnd(50) then
print("3/8#1 2",93,122,6)
end
if self.d>=rnd(200)+80 then
self.d=0
end
end
if cursc!=7 then
line(123,122,125,122,6)
line(123,124,125,124,2)
line(123,126,125,126,2)
end
end
ss=json_parse'{"scns":[7],"solid":true,"contain":false,"x":0,"y":88,"w":16,"h":7,"row_off":0,"sp_off":0,"page":1,"row_d":0,"sp_d":0,"sp_rnd":0,"sp_rnd_xpos":0,"sp_rnd_ypos":0}'
ss.update=function(self)
local pl_x=pl.x
if btnp(—) and pl.y>=74 and pl.y<=80 then
if pl_x>=92 and pl_x<=99 then
err("malfunction")
sfx(04)
end
if pl_x>=100 and pl_x<=105 then
self.page=1
end
if pl_x>=106 and pl_x<=115 then
self.page=2
end
if pl_x>=118 then
err("malfunction")
sfx(04)
end
end
if self.page==0 then
for pipe in all(pipes) do
if pipe.notdraw and coli(pl,pipe) then
if btnp(Ž) then
self.page=2
sfx(05)
pl.x=pipe.x
end
end
end
end
if self.page==2 then
self.solid=true
end
if game.g_on then
self.solid=false
end
end
ss.draw=function(self)
rectfill(0,87,128,120,0)
rectfill(nmx.x_init,nmx.y_init,nmx.x_init+7,nmx.y_init+7,0)

if self.page!=2 then
local page=self.page*64
for row=0,3 do
for i=0,15 do
spr(i+page+16*row+self.sp_off,i*8+self.row_off,self.y+row*8)
self.sp_d2=0
end
self.row_d+=1
if row==flr(rnd(2)) and self.row_d==30 then
self.row_off=30
end
if self.row_d==50 then
self.row_off=0
end
if self.row_d>100 then
self.row_d=0
end
end
self.sp_d+=1
if self.sp_d==20 then
self.sp_rnd=flr(rnd(63)+64)
self.sp_rnd_xpos=0+flr(rnd(15))*8  
self.sp_rnd_ypos=self.y+8*flr(rnd(4)) 
end
if self.sp_d>=rnd(100)+50 then
self.sp_d=0
end
rectfill(self.sp_rnd_xpos-1,self.sp_rnd_ypos,self.sp_rnd_xpos+7,self.sp_rnd_ypos+7,0)
spr(self.sp_rnd,self.sp_rnd_xpos,self.sp_rnd_ypos)    
if self.page==0 then
rectfill(103,self.y,127,111,0)
end
if not game.g_on then
rect(14,102,25,113,0)
rect(15,103,24,112,7)
end
end
rectfill(79,79,91,85,6)
if not game.g_on then print("098",80,80,13) end
for i=1,3 do        
rectfill(96+i*8,80,96+i*8+6,85,6)
print(i,96+2+i*8,81,13)
line(96+i*8,86,98+i*8+6,85+1,13)
pset(96+i*8,80,5)
pset(96+i*8+6,80,5)
end
if not bh(pl.x,pl.y-7,pl.w,pl.h,96,90,0.75,0.75) and self.page!=0 then pal(6,0) pal(13,0) end
rectfill(96,90,102,95,6)
print("0",98,91,13)
line(96,96,102,96,13)
pset(96,90,0)
pset(102,90,0)
pal()
end
ik1=json_parse'{"scns":[7],"solid":false,"sp":30,"x":112,"x_init":112,"y":96,"y_init":96,"collected":false,"used":false,"w":1,"h":1}'
ik1.update=function(self)
if game.cursc!=7 and self.collected then
add(self.scns,5,6)
end
if btnp(—) and coli(self,pl) and ss.page==0 and not self.collected then
self.collected=true
sfx(12)
end
if self.collected then
pl.gotkey1=true
if pl.xflip then
self.x=pl.x-4
else
self.x=pl.x+4
end
self.y=pl.y-2
if self.used then
del(go,self)
end
else
self.x=self.x_init
self.y=self.y_init
end
end
ik1.draw=function(self)
if game.cursc==7 or pl.gotkey1 then

spr(self.sp,self.x,self.y)

end
end
nmx=json_parse'{"scns":[7],"solid":false,"sp":98,"x":70,"x_init":70,"y":78,"y_init":78,"w":1,"h":1,"frame":0,"xflip":false,"yflip":false}'
nmx.frame_rnd=flr(rnd(100)+20)
nmx.cor_rotate=cocreate(rotate_spr)
nmx.update=function(self)
-- sp animation
self.frame+=1
if self.frame==self.frame_rnd then
self.sp+=1
end
if self.frame==self.frame_rnd+50 then
self.sp-=1
self.frame=0
end
end
nmx.draw=function(self)
spr(self.sp,self.x,self.y,self.w,self.h,self.xflip,self.yflip)
end
i_msspr=json_parse'{"scns":[7],"solid":true,"x":10,"y":-10,"w":8.125,"h":8.125,"sx":16,"sy":48,"dx":0,"dy":0,"frame":0}'
i_msspr.frame_rnd=nmx.frame_rnd
i_msspr.update=function(self)
if game.g_on then
self.y=12
end
self.dx=self.x+1
self.dy=self.y+1
self.frame+=1
if self.frame==self.frame_rnd then
self.sx+=8
end
if self.frame==self.frame_rnd+50 then
self.sx-=8
self.frame=0
end
end
i_msspr.draw=function(self)
rectfill(self.x,self.y,self.x+self.w*8,self.y+self.h*8,0)
if not game.g_on then
sspr(self.sx,self.sy,8,8,self.dx,self.dy,self.w*8-1,self.h*8-1)
end
end
i_cc=json_parse'{"scns":[7],"solid":true,"x":-5,"y":24,"collected":false,"used":false,"w":5.125,"h":4.625}'
i_cc.update=function(self)
if game.g_on then
self.y=49
end
end
i_cc.draw=function(self)
for row=0,3 do
for i=0, 3 do
rectfill(self.x+1+(i*10),self.y+1+(row*9),self.x+10+(i*10),self.y+9+(row*9),i+row*4)
end
end
rect(self.x,self.y,self.x+self.w*8,self.y+self.h*8,0)
end
pipes={}  
enm={}
go={
cur,
uit,
ss,
ci_c,
i_t,
i_t.col_i,
i_f,
i_f.col_i,
ik1,
pipes,
enm,
i_msspr,
nmx,
i_cc,
uib,
}
end
function mk_en(_sp,_x,_y,_palswitch,_sp_anim,_onpage)
add(enm,{
scns={7}, 
solid=false,
sp=_sp,
x=_x,
y=_y,
x_init=_x,
y_init=_y,
onpage=_onpage,
w=1,
h=1,
frame=0,
pos_d=0,
pos_d_rnd=flr(rnd(50)+50),
rnd_xpos=0,
rnd_ypos=0,
palswitch=_palswitch,
sp_anim=_sp_anim,
sp_anim_rand=flr(rnd(100)+20),
update=function(self)
	if pl.passed and pl.x==56 and pl.y==112 then
		pl.passed=false
	end
if self.onpage==2 and not game.g_on then
self.pos_d+=1
if coli(self,pl,-5,-5) then
sfx(4)
if not pl.gotkey1 then
pl.x=112
pl.y=87
pl.passed=false
else
pl.x=96
pl.y=89
pl.passed=true
pl.gotkey1=false
ik1.collected=false
sfx(2)
end
end
if self.pos_d==50 then
self.x=rand(62,57,34)
self.y=rand(112,96,89)
end
if self.pos_d>=80 then
self.pos_d=0
end
end
if game.cursc==7 then
if ss.page==0 and not game.g_on then
if coli(self,pl,-5,-5) then
pl.x-=16
pl.gotkey1=false
ik1.collected=false
sfx(3)
end
self.pos_d+=1
if self.pos_d==self.pos_d_rnd then
self.rnd_xpos=self.x+flr(rnd(15))*8 
self.rnd_ypos=self.y+8*flr(rnd(4))
self.x+=self.rnd_xpos
self.y+=self.rnd_ypos
end
if self.pos_d>=self.pos_d_rnd+self.pos_d_rnd then
self.pos_d=0
self.x=self.x_init
self.y=self.y_init
end
end
end
if self.sp_anim==nil or self.sp_anim then
self.frame+=1
if self.frame==self.sp_anim_rand then
self.sp+=1
end
if self.frame==self.sp_anim_rand+100 then
self.sp-=1
self.frame=0
end
else
end
end,
draw=function(self)
if game.cursc==7 and ss.page==self.onpage then
if self.palswitch then
pal(11,10) pal(3,9) pal(10,3)
end
if coli(pl,self,20,20) then
spr(self.sp,self.x,self.y)
end
pal()
end
end
})
end
function m_p(_sp,_x,_y,_dir,_lower,_corner,_notdraw)
add(pipes,{
lower=_lower,
corner=_corner,
notdraw=_notdraw,
scns={7},
dir=_dir,
dir_switched=false,
sp=_sp,
x=_x,
y=_y,
w=1,
h=1,
update=function(self)
if self.lower then
if pl.passed then  
self.dir=2
else
if self.dir==2 then self.dir=1 end
end
end
if self.corner then
if pl.facing=="left" and bh(pl.x-1,pl.y,pl.w,pl.h,self.x,self.y,self.w,self.h) then
if self.dir==1 then self.dir=2 end
end
if pl.facing=="right" and bh(pl.x+1,pl.y,pl.w,pl.h,self.x,self.y,self.w,self.h) then
if self.dir==1 then self.dir=2 end
end
if pl.facing=="down" and bh(pl.x,pl.y+1,pl.w,pl.h,self.x,self.y,self.w,self.h) then
if self.dir==2 then self.dir=1 end
end
if pl.facing=="up" and bh(pl.x,pl.y-1,pl.w,pl.h,self.x,self.y,self.w,self.h) then
if self.dir==2 then self.dir=1 end
end
end
if self.notdraw and btnp(—) and coli(pl,self) and ss.page==2 then
ss.page=0
sfx(5) 
ss.solid=false
end 
end,
draw=function(self)
if ss.page==2 then
if not self.notdraw then
if not bh(pl.x+1,pl.y+2,pl.w,pl.h,self.x,self.y,self.w,self.h) then pal(5,0) pal(6,0) pal(7,0) end
spr(self.sp,self.x,self.y)
pal()
end
end
end
})
end
function player()
pl=json_parse'{"scns":[5,6,7,8],"x":30,"y":80,"vy":0,"speed":1,"step":0.5,"move_del":100,"xflip":false,"yflip":false,"friction":0.1,"hitsolid":false,"col":false,"acc":0.2,"sp":128,"w":1,"h":1,"passed":false,"onground":false,"blink":false,"shadow":false,"shadow_x_off":0,"shadow_y_off":0,"facing":"right","idle":true,"moving":false,"gotkey1":false}'
pl.cor_pl_anim_idle=cocreate(pl_anim_idle)
pl.cor_pl_anim_move=cocreate(pl_anim_move)
pl.cor_pl_blink=cocreate(pl_anim_blink)
pl.update=function(self)
if (self.cor_pl_blink and costatus(self.cor_pl_blink)!="dead") coresume(self.cor_pl_blink)
handle_pl_state()
move_pl()
if self.shadow and self.y<=ss.y then
self.shadow_x_off=-5
self.shadow_y_off=-5
end
if pl.y+9>=uib.y+2 then
pl.y-=5
end
end
pl.draw=function(self)
if game.cursc!=7 then
pal(1,5)
end
if (pl.blink) pal(12,5)
if coli(pl,ss) and ss.page==0 then
rectfill(self.x,self.y,self.x+7,self.y+7,0)
end
spr(self.sp,self.x,self.y,self.w,self.h,self.xflip,self.yflip)
pal()
end
end
function pl_anim_blink()
while true do
pl.blink=true
wait(rnd(10)+5)
pl.blink=false
wait(rnd(50)+120)
end
end
function handle_pl_state()
local pl_facing=pl.facing
if pl_facing=="left" then
pl.xflip=true
pl.yflip=false
end
if pl_facing=="right" then
pl.xflip=false
pl.yflip=false
end
if pl_facing=="up" then
pl.xflip=false
pl.yflip=false
end
if pl_facing=="down" then
pl.xflip=false
pl.yflip=true
end
if pl.idle then
if pl_facing!="up" or pl_facing!="down" then
coresume(pl.cor_pl_anim_idle)
end
end
if pl.moving then
pl.idle=false
coresume(pl.cor_pl_anim_move)
else
pl.idle=true
end
end
function move_pl()
local pl_x=pl.x
local pl_y=pl.y
local pl_w=pl.w
local pl_h=pl.h
local cursc=game.cursc
local spr_page=ss.page
if game.g_on and not coli(pl,ss) then
if not pl.onground then
pl.vy+=game.g
pl.y+=pl.vy
end
for obj in all(go) do
if obj.solid and contains(obj.scns,cursc) and bh(pl.x,pl.y+1,pl.w,pl.h,obj.x,obj.y,obj.w,obj.h) then
pl.vy=0
pl.y=obj.y-pl.h*8
pl.onground=true
end
end
else
pl.onground=false 
end
if btn(0) then
pl.move_del-=1
for newx=pl_x,pl_x-pl.speed,-1 do
for obj in all(go) do
	if cursc==8 and not coli(pl,cur) and pl.y<113 then
	pl.onground=false
end
if cursc==7 and spr_page==2 and pl_y>80 then
if obj.dir then
if bh(newx,pl.y,pl_w,pl_h,obj.x,obj.y,obj.w,obj.h) and obj.dir==2 and pl_x>obj.x and pl_y==obj.y then
pl.x=newx
else
pl.x=pl.x
end
end
end
if obj.contain and pl_x>=obj.x+2 then
pl.x=newx
end
end
if check_col("x",newx) then
pl.x=pl.x
else
if not coli(pl,ss) then
pl.x=newx
else
if pl.move_del<=0 then 
pl.x=newx-8
pl.move_del=5
end
pl.onground=false
end
end
end
pl.facing="left"
pl.moving=true
else
pl.moving=false
end
if btn(1) then
pl.move_del-=1
for newx=pl_x,pl_x+pl.speed do
for obj in all(go) do
if cursc==8 and not coli(pl,cur) and pl.y<113 then
	pl.onground=false
end
if cursc==7 and spr_page==2 and pl.y>80 then
if obj.dir then
if bh(newx,pl_y,pl_w,pl_h,obj.x,obj.y,obj.w,obj.h) and obj.dir==2 and newx<=obj.x and pl_y==obj.y then
pl.x=newx
else
pl.x=pl.x
end
end
end
if obj.contain then
pl.x=newx
end
end
if check_col("x",newx) then
pl.x=pl.x
else
if not coli(pl,ss) then
pl.x=newx
else
if pl.move_del<=0 then 
pl.x=newx+8
pl.move_del=5
end
pl.onground=false
end
end
end
pl.facing="right"
pl.moving=true
end
if btn(2) then
pl.move_del-=1
if not pl.onground then
for newy=pl.y,pl.y-pl.speed,-1 do
for obj in all(go) do
if cursc==7 then
if spr_page==2 and newy>80 then
if obj.dir then
if bh(pl_x,newy,pl_w,pl_h,obj.x,obj.y,obj.w,obj.h) and obj.dir==1 and pl_x==obj.x and newy>=obj.y then
pl.y=newy
else
pl.y=pl.y
end
end
end
if pl.x==112 then
pl.y=newy
end
end
if obj.contain then
pl.y=pl.y
end
end
if check_col("y",newy) then
pl.y=pl.y
else
if not coli(pl,ss) then
pl.y=newy
else
if pl.move_del<=0 then 
pl.y=newy-8
pl.move_del=5
end
pl.onground=false
end
end
end
pl.facing="up"
pl.moving=true
end
end
if btn(2) and pl.onground then
pl.onground=false
pl.vy=-1.5
end
if btn(3) then
pl.move_del-=1
for newy=pl_y,pl_y+pl.speed do
for obj in all(go) do
if cursc==7 then
if spr_page==2 and newy>80 then
if obj.dir then
if bh(pl_x,newy,pl_w,pl_h,obj.x,obj.y,obj.w,obj.h) and obj.dir==1 and pl_x>=obj.x and pl_x<=obj.x+2 and newy<=obj.y then
pl.x=obj.x
pl.y=newy
else
pl.y=pl.y
end
end
end
end
if obj.contain then
pl.y=pl.y
end
end
if check_col("y",newy) then
pl.y=pl.y
else
if not coli(pl,ss) then
pl.y=newy
else
if pl.move_del<=0 then 
pl.y=newy+8
pl.move_del=5
end
end
end
end
pl.facing="down" 
pl.moving=true
end
if pl.x<=0 then
pl.x=0
end
if pl.x>=120 then
pl.x=120
end
if pl.y<=2 then
pl.y=2
end
if pl.y>=118 then
pl.y=118
end
end
function pl_anim_idle()
while true do
if pl.facing=="left" or pl.facing=="right" then
pl.sp=128
wait(10)
pl.sp=129
wait(10)
else
pl.sp=161
wait(10)
end
end
end
function pl_anim_move()
while true do
if pl.facing=="left" or pl.facing=="right" then
pl.sp=144
wait(10)
pl.sp=145
wait(10)
pl.sp=146
wait(10)
else
pl.sp=160
wait(10)
pl.sp=161
wait(10)
end
end
end
__gfx__
00012000066606666066606660666066606660666066606616666661feeeeee87bbbbbb30000004000000030000300000b0dd030777777674f9f4fff7999a999
07d1257000000000000000000000000000000000007777006d6666d6e8888882b3333331040000000300000003000030d3000b0d76777777fffff9f49999979a
057d57d0660666066660566060333306608888066676d75062444426e8811882b33773310000040000000300000003b0000b030077777677ff4fffff99a99999
22566d11000000000000000000333300008888000077770064222246e8866882b3366531000400000003000000b00bb0b0030000777677779fff9ff999997997
11d6652266606660066605666033330660888806067d675664442446e8877282b3355131400000003000000030b30b003000dd0b677777774fffff9fa9999979
0d75d750000000000000000000331300008818000077770064222a96e8822182b33113310000000400000003003b00030b00000377777776ff4fffff999a9999
07521d70606660666606660660331306608818066605550664424446e8888882b33333310400000003000000030b00000300b00076777777ff9ff9ff99999799
0002100000000000000000000033330000888800000000006422224682222222311111110000400000003000000030000dd030b077776777f9ffff4f979999a9
11c111c17ccc7cc70000000005500550005070500500700000dddd00656565650d0aa000000aa000760000000766660006566650777777500007a90000000070
1c111c1177ccc7cc000000000765676005076005000760050dddddd0666666650df99f000df99f0006500000766550000666666576666650000a0000000006d6
c111c111c77ccc7c00000000076007605076660050766700dddddddd662226650de11e000de11e0700650000664500000659405676565650000aa90000006d60
111c111ccc77ccc7076007600765676050766605007676000555555066666665d55660070d66660200065006650450000009400076666650000a00000006d000
11c111c17cc77ccc07656760076007600766767007667670066666606655566509066602d5d6609200006560650045000009400076565650000a0000076d0000
1c111c11c7cc77cc0760076000000000576676655761166506dd6c6066111665000cc092090cc00200000650600004500009400076565650007aa9007dd6d000
c111c111cc7cc77c1765676100000000766767667610016606dd6c606611166500c11c0200c11c000000604500000045000940000766650000a00a006d06d000
111c111c7cc7cc771d211d2100000000565655656610016606dd6660cc444ccc044004400440044000060004000000040009400000555000009aa900076d0000
0bb3b3b030bbb0030150051001500510940000499999999994000049000099997667060000065000d777777dd55550000076dc0000999900000000000007d000
bb3b3b350bbb3300157556511575515194544449444444444444444400094444641605000065d650566666657665d650075555d0094444900000000000766d00
b3b33333bb3bbb305757651557576515945555490550055004555550009440006666666065616560566666657661656001c6dc109444444900000000076666d0
b3333335b3b3b33505766650057656509400004904500450045004500944000011111156006176d011111155766176d007cc6d50999aa9990000000000044000
0b4334503bbb3b3505666650056565509400004904500450045004509945400076d176d57661110076d176d57661110007cc6d50955aa5590007d00000094000
0009450033b3b355575665155516551594544449045004500454445094405400656165606161d650656165607661d65007cc6d509544444900766d0000094000
0009450003335550156551511155515194555549444444444455554494000544d650d65064616560d650d6507661656007cc6d5095444449076666d000094000
095454540033350301500510015005109400004999999999940000499400004900000000766176d000000000d55176d00066d500999999990004400000094000
000990000777770000077000007dd500007665000554455000007000067666500007000099999999750705607776777677777776777777767777777677777776
049aa94075666660007667000007500007666650554444550000770000565100007a900090040405565656507665766576666665766666657766665576666665
49a99a940065d56000077000077665507666666545444454000076700067650007aaa90094444445057775007665766576555565766776657676656576666665
9a9aa9a900666660076666707766665576565565455a9554000077770067650007aaa90090004005767766606555655576566765767665657667566576666665
9a9aa9a900655d60765555677666666576666665411a911407007000006765000a99990094444445057665007677767776566765767665657667566576666665
49a99a94006666606500005676666665765565654445544476666667006765007556559095555555565656506576657676577765766556657676656576666665
049aa940006777775650056577666655766666654444444407666670006765000aaaa90000055000750605606576657676666665766666657766665576666665
00499400005555500567765007766550655555555444444500777700067666500000000005064005000000005565556565555555655555556555555565555555
00000000000005d9007a4200000000000000000900009999900a000000000000000000000049400000040000a7a9999900076000000000000001000000000000
0e82e82000555d5507a9942000000000000909aa009999aa09000a900009000009009090049a94000049400004a994400007610000111000001c10000eeeee20
e788888205d6d5550a999940000000000000aaaa09a9aaaa00009000008aa800008aa80049a7a940049a9400097999400007610001ccc10001c7c1007262626c
e88888825d7ddd500a99994000000009090a9a9a099a9909a000000000a77a9009a77a009a777a9449a7a94009a99990707765071c777c1001c7c10015252520
0888882056dddd500a9999400000a09a00a9a9a999a997900090000009a77a0000a77a9049a7a940049a9400099a99407667665601ccc10001c7c10002e50000
0088820055ddd5500ae999400000099a09aa9a7799a970000a000000008aa800008aa800049a940000494000009994007676656500111000001c10005e200000
000820000555550007fe9420000099a70aa9a7779aa090000900000000009000090900900049400000040000000a900007655651000000000001000025200000
0000000000555000007942000009aa779aaa97779aa90000000000000000000000000000000400000000000007a9994000766510000000000000000000000000
000550000005500005677650000550000567765000ddd0000000000000033000060aa05065656565757575751111111111111111111111112888888212888821
00566500005666000567765000566500567777650d666d0003333330033bb33006aa00505dddddd66060606015555555555555555555555188eeee88288ee882
0567765066677760567777650567765067766776d67666d033bbbb3333b77b3306a00a506d5555d5575757571565505050505050505556518ea77ae888eaae88
5677776577777776567777655675576577655677d66666d03b7777b33b7777b30600aa505d5cc6d6060606061555550505050505050555518e7777e88ea77ae8
6777777677777777677557765675576556500565dd666d503b7777b33b7777b3060aa0506d5cc6d5757575751555505050505050505555518e7777e88ea77ae8
77777777666775577777777705677650050000500dddd50033bbbb3333b77b3306aa00505d5666d6606060601555550505050505050555518ea77ae888eaae88
56666665005677505666666500566500000000000055500003333330033bb33006a00a506dddddd55757575715655050505050505055565188eeee88288ee882
05555550000566000555555000055000000000000000000000000000000330000600aa5055555555060606061555555555555555555555512888888212888821
00aaaa000007000000dddd0000dddd000022220050222205bb0bb0bb0b0bb0b00000bbb000000000000990003bb1000000666000000770000076660000766600
0a999940000e00000d7cc7d00d7cc7d0552882550528825003abba30b3abba3b000b1b1ba000bbb000007900b3b3b10006000600007755000702826007282060
a979979400e88000d70cc07dd77cc77d22588522225885220bbbbbb00bbbbbb00a0bbbbbb00b1b1b009a9990bb3bbb1060700060077665500602825006282050
a71991740e111800d77cc77dd70cc07d271881722708807203baab3003baab30b00b3707b00bbbbb0979a99913b3b3b160000060775555550066550000665500
a9999994e8191880dccccccddccccccd2888888228888882b003300b00033000b00bbb00b00b370799a999790bbb3bb160000060775e275507d75d6007d75d60
a992299408111820dcc11ccddcc11ccd28881882288188820b3bb3b00b3bb3b0bb0bbbb0bb0bb3309997aa9901b3b3b106000600775227557d7dd5d67d7dd5d6
b30880d5008882000dccccd00dceecd0028888299288882000bbbb00b0bbbb0b0bb0bbbbbbb0bbbb0999a990001bbb3000666000777776557d7dd5d57d7dd5d5
ff0ee0660008200000dddd0000dddd0099222290092222990bb33bb000b33b0000bbbbb00bbbbbb0009a99000001110b00000000055555500665565006655650
08000080a00700b00056650000077000004aa4000077770000777700000000076776d7765000000000d7cd0009aaaa900000567700a7777d0007700000077000
0000000007a00bba056766500076650044a77a4407666670000666700000007676675665650000000d77ccd09a1aa1a9000567760a6666dd0076670000700700
00880800077bba7b5676666500766500aa7777aa71166117a0776657000007667667566566500000d777cccd9a5aa5a905677775a7777d5d0766667007000070
8008e808b0b7aab067666666007665004aa77aa4712662177a6666660000766676675665666500007777cccc9aaaaaa95677775076666d5d7666666770000007
008ee80000ba7ab0666666660076650004a77a40066116606d666666000766667667566566665000dcccdddd09affa900567777676666d5d0005500000077000
000888000b7b77ab56666665007665004a7aa7a405666650d05661150076666676675665666665000dccddd09a9aa9a95677766576666d5d0006600000700700
000000800ab0b7aa05666650076666504aa44aa4006116000006665007666666766756656666665000dcdd00a900009a6777655076666dd00006600007000070
08008000ab0000a00056650006555550aa4004aa0056650000665000766666666552155666666665000dd0009a9009a9776650006ddddd000006600070000007
2002821000028210202000000006822d02822222020220d000000000000000000000000000000000007665000076650005555555555555555555555055677655
0211111122111111022282100026cdcd1111110002200d0000000000000000000000000000000000075006500750065055666666666666666666665556555565
11ddcdcd01ddcdcd001111110216ddddddcdcddd21ddd00002000000000000000000000000000000065006500650000056676767676767676767766556677665
006ddddd106ddddd66ddcdcd0016dddd66666d0081cddd0022ddd000000000000000000000000000766666657666666556777777777777777777776556677665
006d5ddd006d5ddd600ddddd0015ddd066dddd001ddddd008dddd000002282000202820002222200766166657663666556777676767676767676776555677655
0065111d0065111d0005ddd00052111056d111111c66d1111dddd1000221166600211110002282dd766166657663666556766676666666666767766556555565
00520010005200100552211100520010052200000d6661001d66611100666c10011dddd000111110766666657666666556776756666666667577666556677665
0502001005020010500200100502001000502000000552221d666222666dddc066666666666dddd0655555556555555556766665555555555667766556677665
0028210020000000002821002200000002228200005000000000000000000000c0c6cc0000777700056650000000000056677665555575555566765555555555
02111110222821000211111002282100221116660205002002022210202221000cccccc0071111605600650007a00a7056776665565755665555555556677665
d21ddcd60111111021ddcdcd0111111000666c10022560220022822102282210cdd7d7d071111115607006000a9009a056677665565757676565565655555555
d1dd66660ddddcd0666ddddd0dddcdc0066dddcd101d5682011111111111111006ddddd071100115600006000000000056776665575757777576755757777775
00d66d00066dddd06066dd00066dddd05555dd0011ddd62206ddcdcd0ddcdcd00d665ddd71100115560065000000000056677665575756766557675675555557
202211000066dd00001221000066dd00021dd00000dd661260d5dddd6d5dddd000c5ccc071111115056694500a90000056776665565756666565565655677655
02000010002212000110020000221100200100000dd6dc116552ddd16522dd11005c00c0061111500000094507a0000056677665565755665555555556776665
0000000100012000000000200002100000100000d000c1105220011152220001050c00c000555500000000940000000056776665555575555567665556677665
0028226000000000628210000022000022000000222200001112000006822d0026822d0077777777002820000077770056776675555755555677666556776665
002222600028220026111100081d0000820d0000228110001112800026cdcd0016cdcd0000000000028e8200076566d056676756665575656577666556677665
061221600022222006dcdc00621d0000612d000011dcd00011dc600016dddd0006dddd000600600608e7e8007665666d56777667676575657667766555776655
06d11dd0061221160ddddd00611c0200611c0200d66665d5dddd656506dddd0006dddd000000000008eee8007665556d56677777777575757777766575555557
0dd1d1d00dd11ddd05dddd006cdd52016cdd5201dddd0d00ddd6060005ddd00005ddd00000500500028e82007666666d56667676767575756767666557777775
005111000dd1d1dd522dd0d0d66d5211d6665211211100001112000005221110052211100000000000282000076666d056666666666575656666666555555555
0015000000551110220100000d6652100dd6521020001000100020005002000150020001010100100028200000dddd0055666666665575656666665556677665
00105000001051000110000000dd510000dd51002000010010000200500000005000000000000000002820000000000005555555555755555555555055555555
062281100000000000400000202821000028210000282100000000000000000000000000000000007777777711111100566666660015d0005666666500000000
6d6dcdc00000122240900040111111102111111021111110030100000606330000003300000000007555555717777610655115510015d0006666666600000000
506dddd0000dd18090a040900ddbdbd00ddbdbd01ddbdbd003013300663138300031383000077000756556571777610065155551001d50006000000601111110
506dddd0000ddd11a00090a40666dddd1666dddd0666dddd00313830633313300633133000766700755555571776610051155551000d15006000000605555550
5006ddd000ddddd10405a00900d5dd0000d5dd0000d5dd00003313303331301363313013005665007555555717667610655115110001d5006000000605555550
00021111002d6dd00905004a005111000052110000521100033130131110000011100000000550007565565716116761655551510001d0006000000605155150
000200010222166d0a5000900520001005002000052201001110000010000000100000000000000075555557010016716555515100105d006000000605111150
0002000020011006dd1110a05020000050010000500001001000000000000000000000000000000077777777000001105111111500150d000000000005111150
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555775555775775557757755555775555775577557777555555775555557755555577555775557755557755555555555555555555555555555555775
55555555555770555770770577777775557777755770770057777055555770555577005555557755577577005557705555555555555555555555555555557700
55555555555770555500500557707700577770005507700555770775555500555577055555557705777777755777777555555555577777755555555555577005
55555555555500555555555577777775550777755577077557707700555555555577055555557705577077005557700055775555550000005555555555770055
55555555555775555555555557707700577777005770077057707705555555555557755555577005770057755557705555770555555555555577555557700555
55555555555500555555555555005005550770055500550055775775555555555555005555550055500555005555005557700555555555555577055555005555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755555775555777775557777755555777755777777555777755577777755577775555777755555775555557755555557755555555555577555557777755
57700775557770555500077555000775557707705770000057700005550007705770077557700775555770555557705555577005557777555557755555000775
57705770555770555577770055577700577007705777775557777755555577005577770055777770555500555555005555770055555000055555775555577700
57705770555770555770000555550775577777705500077557700775555770055770077555500770555775555557755555577555557777555557700555550005
55777700557777555777777557777700550007705777770055777700555770555577770055777700555770555557705555557755555000055577005555577555
55500005555000055500000055000005555555005500000555500005555500555550000555500005555500555577005555555005555555555550055555550055
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777755577777555577777555777775557777555775577555777755555577755775577557755555575555755775577555777755
57700775577007755770077557700775577007755770000057700000577000055770577055577005555557705770770057705555577557705777577057700775
57707770577777705777770057705500577057705777775557777755577077755777777055577055555557705777700557705555577777705777777057705770
57705000577007705770077557705775577057705770000557700005577057705770077055577055577557705770775557705555577777705770777057705770
55777775577057705777770055777700577777005577777557705555557777005770577055777755557777005770577555777775577007705770577055777700
55500000550055005500000555500005550000055550000055005555555000055500550055500005555000055500550055500000550055005500550055500005
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777775577777755775577557755775577557755775577557755775577777755777775557755555577777555557755555555555
57700775577007755770077557700000555770005770577057705770577777705577770055777700550077005770000555775555550077055577775555555555
57777700577057705777770055777755555770555770577057705770577777705557700555577005555770055770555555577555555577055770077555555555
57700005577077005770077555500775555770555770077055777700577007705577775555577055557700555770555555557755555577055500550055555555
57705555557707755770577057777700555770555577770055577005570055705770077555577055577777755777775555555775577777055555555557777775
55005555555005005500550055000005555500555550000555550055550555505500550055550055550000005500000555555500550000055555555555000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
__gff__
000101010181010001000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000c0000040400000000000000000000000000000000000000000000000000000000000c0c00000000000000000001000000000000000001000000
0000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100002e1502e1502f1502f1502f150351503715000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200002e5502e5503555035550166003a5503a55037500345003350034500385000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200001c620385503455031550305502e5502d5501d6201d6201d6001d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000006500065000650006551305014050140501405014050140501405013050110500e0500b0500905008050070500605005050050500505006050070500105001030010230000000000000000000000000
000400000024000231062002100000240002310022100213190001a00023000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002a750267502a7500070032750377003970039700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0004000036630236701f6711c6511b6511b6511a6511a6511a630176310e631066310463102631016310063100631006110061100611006110061100611006110061101600006000060000300003000030000300
000200000b3240d331103411c341233412634127341293412c3312e32500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000700180062307623000000762300623000000000000623076230000007623006230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000307342b751237511d75117751127510d75108751037310271501713007050c7000a700077000670004700027000170000700007000070000700007000070000700017000070000700007000070000700
000200002f3402f3412f33136334363413634136331363313632136321363213631136315383003f3000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00010000312502b250252502025019250122500e2500e6300e6300e6351520010200072000420000200002000d20009200082000820000200002000120026100121001e100061000d10019100251000c10024100
0006000019150201501c150231502313519130201301c130231302312519120201201c120231202311519110201101c1102311023115001000010000100001000010000100001000010000100001000010000100
000900000b6500b6500b6531c6001c6501c650156300e630096300763005610036100161001615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c6301c630232541c35120353173501b3501935422230246002460025600266002660027600156000f6000b6000760006600056000460004600046000020000200002000020000200002000020000200
0003000028630286301e6501a650186501664014640106400f6400c630096300663005630026100161001610016102750020500235002c5002e50022500295002e500325001f5002a5002d500265002a5001c500
000300000863111631206003365032651306512a651226511a651136410d641086410463101631006110061500000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000017630106300e6500e6301063213652186521e6522a6523663236632306323062221622126220661200612006120161200612006150060000600006000060000600006000060000600006000060000600
000c00201125411255052550000000000112541125505255000000000011254112550525500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000705005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000205004050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000005002050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400001c5151e5151a515150151c5151e5151a015155151c5151e5151a515150151c5151e5151a015155151c5151e51517015230151c5151e51517015230151c5151e515165151c0151c5151e515160151c515
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020515215151c5151901520515215151c0151951520515215151c5151901520515215151c0151951520515215151c0151901520515215151c01525515285152651525515210151c5151a5151901515515
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
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
018800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0164002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
010a000024045270352d02523045260352c02522045250352b02522035250352b02522035250252b01522725257252b71522715257152b71522715257152b7151700017000170001700017000130000c00000000
010a000021705247052a7052072523715297151f72522715287151f71522715287151f71522715287151f71522715287151f71522715287151f70522705287051770017700177001770017700137000c70000700
010c00000f51014510185101b510205102451011510165101a5101d510225102651013510185101c5101f5102451028510285102851028510285102851028515240042450225504255052650426502265050e500
010c000014730187301b730207302473027730167301a7301d730227302673029730187301c7301f73024730287302b730307403073030730307303072030715247042470225704257052670426702267050e700
011200000843508435122150043530615014351221502435034351221508435084353061512215054250341508435084350043501435306150243512215034351221512215084350843530615122151221524615
011200000c033242352323524235202351d2352a5111b1350c0331b1351d1351b135201351d135171350c0330c0332423523235202351d2351b235202352a5110c03326125271162c11523135201351d13512215
0112000001435014352a5110543530615064352a5110743508435115152a5110d43530615014352a511084150d4350d4352a5110543530615064352a5110743508435014352a5110143530615115152a52124615
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033115151c1351d1351c1351d135115151d1350c03323135115152213523116221352013522135
0112000001435014352a5110543530615064352a5110743508435115152a5110d435306150143502435034350443513135141350743516135171350a435191351a1350d4351c1351d1351c1351d1352a5011e131
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033192351a235246151c2351d2350c0331f235202350c033222352323522235232352a50130011
011600000042500415094250a4250042500415094250a42500425094253f2050a42508425094250a425074250c4250a42503425004150c4250a42503425004150c42500415186150042502425024250342504425
011600000c0330c4130f54510545186150c0330f545105450c0330f5450c41310545115450f545105450c0230c0330c4131554516545186150c03315545165450c0330c5450f4130f4130e5450e5450f54510545
0116000005425054150e4250f42505425054150e4250f425054250e4253f2050f4250d4250e4250f4250c4250a4250a42513425144150a4250a42513425144150a42509415086150741007410074120441101411
011600000c0330c4131454515545186150c03314545155450c033145450c413155451654514545155450c0230c0330c413195451a545186150c033195451a5451a520195201852017522175220c033186150c033
010b00200c03324510245102451024512245122751127510186151841516215184150c0031841516215134150c033114151321516415182151b4151d215224151861524415222151e4151d2151c4151b21518415
010200002067021670316602f65031650336503365033650386503f6503f650326502f6502f650006002f6502e6502d650006002b650296502760024650216001e65019600116500a60000630066000161000010
010200000e6510c6530a6520b653056530000000000000000e6510c6530a652000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000013535000002b5070000037535000001f507000002b5350000000000000001f53500000000000000013505000002b5070000037535000001f507000002b5350000000000000001f535000000000000000
011000000062200622006220062202622026220262202622006220062200622006220262202622026220262200622006220062200622026220262202622026220062200622006220062202622026220262202622
__music__
00 16 17 43 44
00 16 17 43 44
01 16 17 43 44
00 16 17 43 44
00 18 19 43 44
02 18 19 43 44
00 1a 42 43 44
01 1a 1b 43 44
00 1a 1b 43 44
00 1a 1c 43 44
00 1a 1c 43 44
02 1d 1e 43 44
01 1f 20 43 44
00 1f 21 43 44
00 1f 20 43 44
00 1f 21 43 44
00 22 23 43 44
02 1f 24 43 44
01 25 26 43 44
00 25 26 43 44
02 27 28 43 44
00 29 2a 43 44
03 2b 2c 43 44
04 2d 2e 43 44
04 2f 30 43 44
01 31 32 43 44
00 31 32 43 44
00 33 34 43 44
02 35 36 43 44
01 37 38 43 44
00 39 3a 43 44
00 37 3b 43 44
02 39 3b 43 44
03 3e 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
