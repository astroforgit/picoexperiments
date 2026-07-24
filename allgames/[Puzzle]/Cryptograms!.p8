pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--cryptograms
--decode the letters!

cartdata("cryptograms")

alph="abcdefghijklmnopqrstuvwxyz"
abc_str=[[0123456789abcdefghijklmnopqrstuvwxyz',.-ê!?ãë:;&*#~$%^@()/+< 
Ä]]
sounds={
 erase=61,
 write=62,
 move=63,
}
songs={
 game=0,
 win=4,
 menu=5,
}

local st={}
-->8
--functions

function init_cards()
 cards={}
end

function add_card(id,x,y,w,h,z,b,s,d)
 cards[id]={
  x=x,y=y,
  w=w,h=h,
  z=z,
  bg=b,shadow=s,
  draw=d,
 }
 upd_card(cards[id])
end

function upd_card(card)
 card.px=flr(card.x-flr(card.z+.5)+.05)
 card.py=flr(card.y+.05)
 card.px2=flr(card.px+card.w-1+.05)
 card.py2=flr(card.py+card.h-1+.05)
 card.sx=flr(card.x+.05)
 card.sy=flr(card.y+flr(card.z)+.05)
 card.sx2=flr(card.sx+card.w-1+.05)
 card.sy2=flr(card.sy+card.h-1+.05)
end

function move_cards()
 for id,card in pairs(cards) do
  if card.tx then
   card.x+=(card.tx-card.x)/(card.tx_spd or 8)
  end
  if card.ty then
   card.y+=(card.ty-card.y)/(card.ty_spd or 8)
  end
  if card.th then
   card.h+=(card.th-card.h)/(card.th_spd or 8)
  end
  if card.tz then
   card.z+=(card.tz-card.z)/(card.tz_spd or 8)
  end
 end
end

function draw_cards()
 local cards_s={}
 for id,card in pairs(cards) do
  upd_card(card)
  add(cards_s,card)
  local i=#cards_s
  while i>1 and cards_s[i].z<cards_s[i-1].z do
   cards_s[i],cards_s[i-1]=cards_s[i-1],cards_s[i]
   i-=1
  end
 end
 for i=#cards_s,1,-1 do
  local card=cards_s[i]
  rectfill(card.sx,card.sy,card.sx2,card.sy2,card.shadow)
 end
 for i=1,#cards_s do
  local card=cards_s[i]
  rectfill(card.px,card.py,card.px2,card.py2,card.bg)
  clip(card.px,card.py,card.w,card.h)
  card:draw()
  clip()
 end
end

function init_font()
 font={}
 font_bmp=[[1c22222222221c000818080808081c001c22020408103e001c22020402221c00040c14243e0404003e20203c02221c000e10203c22221c007e420408080808001c22221c22221c001e22221e02020200180814143e2277007c22223e21217e001e22404040221e007c22212121227c007f21243c24217f007f21243c242070001e22404047221c007722223e222277003e08080808083e001f0404042464380076242830282476007020202020227e00c3665a5a4242e7007722322a262277003c42424242423c007c22223c202070003c4242425a443b007c22223e242277001d22201c02227c007f49080808081c007722222222221c007722221414080800c7828254546cc60077140808142277007722140808081c007e42040810227e000010080800000000000000000010102000000000000010000000003c000000000000000000002a00202020202000200038444408100010000424221000000000084424200000000000000010000010000000001000101020304848334a443b00082a1c7f1c2a080000123f12247e240000000031494600001d2a281c0a2a7c00215224081225420000081422410000003e415d555e403e000204040404040200402020202020400001020408102040000808087f08080800040810201008040020100804081020001810101010101800180808080808180040201008040201000000000000007e0000003c003c0000000204040804040200402020102020400008080808080808083c4299a1a199423c3c42b9a5b9a5423c0000000000000000]]
 local abc=[[0123456789abcdefghijklmnopqrstuvwxyz',.-ê!?ãë:;&*#~$%^@()/+<>[]\_={}|éó ]]
 for i=1,#abc do
  local s=63+i
  font[sub(abc,i,i)]=s
  for y=0,7 do
   local row=tonum("0x"..sub(font_bmp,(i-1)*16+y*2+1,(i-1)*16+y*2+2))
   for x=7,0,-1 do
    sset(x+(s%16)*8,y+flr(s/16)*8,band(row,1)>0 and 7 or 0)
    row=flr(shr(row,1))
   end
  end
 end
end

function print_font(s,x,y,c)
 local prev_7=peek(0x5f07)
 pal(7,peek(0x5f00+c))
 local px,py=x,y
 for i=1,#s do
  local chr=sub(s,i,i)
  if chr=="\n" then
   px=x
   py+=8
  else
   spr(font[chr] or 0,px,py)
   px+=8
  end
 end
 pal(7,prev_7)
end

function print_font_center(s,x1,x2,y,c)
 print_font(s,x1+(x2-x1+1-8*#s)/2,y,c)
end

function print_right(s,x,y,c)
 local w=-1
 for i=1,#s do
  w+=(sub(s,i,i)>="\x80" and 8 or 4)
 end
 print(s,x-(w-1),y,c)
end

function print_center(s,x1,x2,y,c)
 local w=-1
 for i=1,#s do
  w+=(sub(s,i,i)>="\x80" and 8 or 4)
 end
 print(s,x1+(x2-x1+1-w)/2,y,c)
end

function if_btnp_then(f)
 if band(btnp(),0b00001111)>0 then
  f()
 end
end

function init_btns()
 oldbtns=0b00000000
 btns=0b00000000
end

function upd_btns()
 oldbtns=btns
 btns=btn()
end

function btnf(b,p)
 p=(p or 0)*8
 return band(btns,shl(1,b+p))>0
 and band(oldbtns,shl(1,b+p))==0
end

function btnh(b,p)
 p=(p or 0)*8
 return band(btns,shl(1,b+p))>0
end

function btnr(b,p)
 p=(p or 0)*8
 return band(btns,shl(1,b+p))==0
 and band(oldbtns,shl(1,b+p))>0
end

function bin(num,prec)
 local n,s=num,""
 for i=1,prec do
  s=tostr(band(n,1))..s
  n=flr(shr(n,1))
 end
 return s
end

function peekb(addr,bit)
 return band(peek(addr+flr(bit/8)),shl(1,bit%8))
end

function pokeb(addr,bit,val)
 local pow=shl(1,bit%8)
 val=(val and val!=0) and pow or 0
 local byte=addr+flr(bit/8)
 poke(byte,bor(band(peek(byte),0b11111111-pow),val))
end

function load_bit(bit)
 return peekb(0x5e00,bit)
end

function save_bit(bit,val)
 pokeb(0x5e00,bit,val)
end

function next_to_do()
 local i=ph_i
 while load_bit(i-1)>0 do
  i=i%#phrases+1
  if i==ph_i then
   break
  end
 end
 return i
end

function fadepal()
 local dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}
 for j=1,15 do
  local col=j
  for k=1,(flr(mid(0,fade,1)*100)+(j*1.46))/22 do
   col=dpal[col]
  end
  pal(j,col)
 end
end

function fade_in(fade_spd)
 fade_spd=fade_spd or .05
 if fade>0 then
  fade-=fade_spd
 else
  fade=0
 end
end

function fade_out(fade_spd)
 fade_spd=fade_spd or .05
 if fade<1 then
  fade+=fade_spd
 else
  fade=1
 end
end

function is_alpha(str)
 return str and str>="a" and str<="z" or false
end

function index(str,chr,start)
 start=start or 1
 for i=start,#str do
  if sub(str,i,i)==chr then
   return i
  end
 end
 return 0
end

function gen_draw()
 fadepal()
 rectfill(0,0,127,127,7)
 draw_cards()
end

local curr_st={}
function switch_st(st,...)
 local prev=curr_st
 curr_st=st
 if curr_st.enter then
  curr_st:enter(prev,...)
 end
end
-->8
--init/update/draw

function _init()
 fade=1
 decode()
 init_btns()
 init_font()
 local last_ph_i=peek2(0x5efe)
 ph_i=last_ph_i>0 and last_ph_i or 1
 switch_st(st.menu)
end

function _update()
 upd_btns()
 if curr_st.update then
  curr_st:update()
 end
end

function _draw()
 if curr_st.draw then
  curr_st:draw()
 end
end
-->8
--game state

st.game={
 gram_w=15,gram_h=10,
 abc_w=7,abc_h=4,
}

function st.game:enter(prev)
 local phr=phrases[ph_i]
 --generate gram table
 self.gram={
  b={},
  alph={},
  g_alph={},
  text=phr[1],
  author=phr[2],
  theme=phr[3],
 }
 for x=0,self.gram_w-1 do
  self.gram.b[x]={}
  for y=0,self.gram_w-1 do
   self.gram.b[x][y]={}
   --message is all blank
   self.gram.b[x][y]=""
  end
 end
 --generate coded alphabet
 local ca={}
 --populate and shuffle table
 for i=1,26 do
  add(ca,sub(alph,i,i))
 end
 for i=1,26 do
  local j
  repeat
   j=flr(1+rnd(26))
  until sub(alph,i,i)!=ca[j] and sub(alph,j,j)!=ca[i]
  ca[i],ca[j]=ca[j],ca[i]
 end
 --populate coded alphabet
 for i=1,26 do
  self.gram.alph[sub(alph,i,i)]=ca[i]
  --guesses are all blank
  self.gram.g_alph[sub(alph,i,i)]=""
 end
 --add message to letters table
 local i=1
 for y=0,self.gram_h-1 do
  for x=0,self.gram_w-1 do
   local c=sub(self.gram.text,i,i)
   i+=1
   if (c=="\n") break
   self.gram.b[x][y]=c
  end
  if (sub(self.gram.text,i,i)=="\n") i+=1
 end
 --initialize everything else
 if prev!=self then
  init_cards()
  --add a card with the gram
  add_card("gram",300,2,122,87,3,12,6,function(c)
   for x=0,self.gram_w-1 do
    for y=0,self.gram_h-1 do
     local cx,cy=c.px+x*8+1,c.py+y*8+1
     local real_chr=self.gram.b[x][y]
     local alph_chr=self.gram.alph[real_chr]
     local g_alph_chr=self.gram.g_alph[alph_chr]
     if g_alph_chr=="" then
      print(alph_chr,cx+3,cy+1,alph_chr==self.gram.alph[self.gram.b[self.gram_x][self.gram_y]] and 13 or 6)
     else
      if not is_alpha(g_alph_chr) then
       print_font(real_chr,cx,cy,7)
      else
       print_font(g_alph_chr,cx,cy,7)
      end
     end
    end
   end
   print_right("theme: "..self.gram.theme,c.px2-1,c.py2-5,1)
   print_right("- "..self.gram.author,c.px2-1,c.py+87,1)
  end)
  cards.gram.tx=6
  cards.gram.ty=2
  --add a card with the letters
  add_card("abc",600,93,45,30,2,15,6,function(c)
   local abc={"abcdefg","hijklmn","opqrstu","vwxyz  "}
   local x,y=0,0
   for l in all(abc) do
    for i=1,#l do
     local chr,dup=sub(l,i,i),0
     for j=1,26 do
      if (self.gram.g_alph[sub(alph,j,j)]==chr) dup+=1
     end
     print(chr,c.px+x+3,c.py+y+2,dup>1 and 8 or dup>0 and 6 or 4)
     x+=6
    end
    x=0
    y+=7
   end
   print("Å",c.px+34,c.py+23,4)
   rect(c.px+self.abc_x*6+1,c.py+self.abc_y*7,c.px+self.abc_x*6+(self.abc_x==5 and self.abc_y==3 and 13 or 7),c.py+self.abc_y*7+8,2)
  end)
  cards.abc.tx=7
  cards.abc.ty=93
  cards.abc.z_down=2
  cards.abc.z_up=5
  cards.abc.tz=cards.abc.z_down
  cards.abc.tz_spd=2
  --add a card with more info
  add_card("info",900,93,65,30,2,7,6,function(c)
   rect(c.px,c.py,c.px2,c.py2,0)
   for i=1,3 do
    line(c.px+1,c.py+9*i+1,c.px2-1,c.py+9*i+1,12)
    rectfill(c.px+4,c.py+9*i+5,c.px+5,c.py+9*i+6,0)
   end
   line(c.px+9,c.py+1,c.px+9,c.py2-1,8)
   print_center("puzzle "..tostr(ph_i),c.px+10,c.px2,c.py+3,load_bit(ph_i-1)>0 and 3 or 8)
   local real_chr=self.gram.b[self.gram_x][self.gram_y]
   local alph_chr=self.gram.alph[real_chr]
   local g_alph_chr=self.gram.g_alph[alph_chr]
   print_font(alph_chr,c.px+11,c.py+12,0)
   local count,length,solved=0,0,0
   for x=0,self.gram_w-1 do
    for y=0,self.gram_h-1 do
     local rchr=self.gram.b[x][y]
     local achr=self.gram.alph[rchr]
     local gchr=self.gram.g_alph[achr]
     if is_alpha(achr) then
      length+=1
      if (achr==alph_chr) count+=1
      if (gchr!="" and is_alpha(gchr)) solved+=1
     end
    end
   end
   print("count: "..count,c.px+22,c.py+14,0)
   print(flr(solved/length*100).."% filled",c.px+11,c.py+23,0)
  end)
  cards.info.tx=60
  cards.info.ty=93
  music(songs.game)
 end
 self.gram_x=0
 self.gram_y=0
 --start at an alphabetic char
 while not is_alpha(self.gram.b[self.gram_x][self.gram_y]) do
  self.gram_x+=1
  if (self.gram_x>=self.gram_w) self.gram_x%=self.gram_w self.gram_y=(self.gram_y+1)%self.gram_h
 end
 self.abc_x=5
 self.abc_y=3
 self.complete=false
 --save the puzzle you're doing
 poke2(0x5efe,ph_i)
 menuitem(1,"reset puzzle",function()
  switch_st(self)
  sfx(sounds.erase)
 end)
 menuitem(2,"back to menu",function()
  switch_st(st.menu)
 end)
end

function st.game:update()
 fade_in()
 move_cards()
 --if é is being pressed
 if btnf(é) then
  self.gram.g_alph[self.gram.alph[self.gram.b[self.gram_x][self.gram_y]]]=""
  sfx(sounds.erase)
 --if ó is being held
 elseif btn(ó) then
  cards.abc.tz=cards.abc.z_up
  --check d-pad
  if btnp(ë) then
   self.abc_x=(self.abc_x+1)%(self.abc_y==3 and 6 or self.abc_w)
  elseif btnp(ã) then
   self.abc_x=(self.abc_x-1)%(self.abc_y==3 and 6 or self.abc_w)
  elseif btnp(É) then
   self.abc_y=(self.abc_y+1)%self.abc_h
   if self.abc_x==6 and self.abc_y==3 then
    self.abc_x=5
   end
  elseif btnp(î) then
   self.abc_y=(self.abc_y-1)%self.abc_h
   if (self.abc_x==6 and self.abc_y==3) self.abc_x=5
  end
  if_btnp_then(function()
   sfx(sounds.write)
  end)
  --fill in specified letters
  local ind=self.abc_y*7+self.abc_x+1
  self.gram.g_alph[self.gram.alph[self.gram.b[self.gram_x][self.gram_y]]]=sub(alph,ind,ind)
 --if ó is not held
 else
  cards.abc.tz=cards.abc.z_down
  --check d-pad
  if btnp(ë) then
   repeat
    self.gram_x+=1
    if (self.gram_x>=self.gram_w) self.gram_x%=self.gram_w self.gram_y=(self.gram_y+1)%self.gram_h
   until is_alpha(self.gram.b[self.gram_x][self.gram_y])
  elseif btnp(ã) then
   repeat
    self.gram_x-=1
    if (self.gram_x<0) self.gram_x%=self.gram_w self.gram_y=(self.gram_y-1)%self.gram_h
   until is_alpha(self.gram.b[self.gram_x][self.gram_y])
  elseif btnp(É) then
   repeat
    self.gram_y=(self.gram_y+1)%self.gram_h
   until is_alpha(self.gram.b[self.gram_x][self.gram_y])
  elseif btnp(î) then
   repeat
    self.gram_y=(self.gram_y-1)%self.gram_h
   until is_alpha(self.gram.b[self.gram_x][self.gram_y])
  end
  if_btnp_then(function()
   sfx(sounds.move)
  end)
  --highlight matching letter
  local chr=self.gram.g_alph[self.gram.alph[self.gram.b[self.gram_x][self.gram_y]]]
  local ind=index(alph,chr)
  if ind==0 then
   self.abc_x=5
   self.abc_y=3
  else
   self.abc_x=(ind-1)%self.abc_w
   self.abc_y=flr((ind-1)/self.abc_w)
  end
  --check for completion
  self.complete=true
  for y=0,self.gram_h-1 do
   for x=0,self.gram_w-1 do
    local real=self.gram.b[x][y]
    local alpha=self.gram.alph[real]
    local guess=self.gram.g_alph[alpha]
    if (is_alpha(real) and guess!=real) self.complete=false break
   end
  end
 end
 if (self.complete) switch_st(st.win)
end

function st.game:draw()
 gen_draw()
 spr(1,cards.gram.px+self.gram_x*8+7,cards.gram.py+self.gram_y*8+7)
end
-->8
--win state

st.win={}

function st.win:enter()
 save_bit(ph_i-1,true)
 poke2(0x5efe,phi_i)
 cards.gram.th=99
 cards.abc.ty=175
 cards.info.ty=175
 add_card("win",16,-20,109,13,1,9,6,function(c)
  print_center("solved!",c.px,c.px2,c.py+1,2)
  print_center("press ó or é to continue",c.px,c.px2,c.py+7,0)
 end)
 cards.win.ty=107
 self.fading_out=false
 menuitem(1)
 music(songs.win)
end

function st.win:update()
 move_cards()
 if abs(cards.win.y-cards.win.ty)<5 then
  cards.win.tz=7
 end
 if stat(24)<0 then
  if (btnf(ó) or btnf(é)) self.fading_out=true
  if self.fading_out then
   fade_out()
   if (fade>=1) ph_i+=1 switch_st(ph_i>#phrases and st.menu or st.game)
  end
 end
end

st.win.draw=gen_draw
-->8
--menu state

st.menu={}

function st.menu:enter(prev)
 self.prev=prev
 self.opt_names={
  "play",
  "instructions",
  "credits",
  "erase save",
 }
 self.opt_count=#self.opt_names
 if prev.opt_id then
  --if coming from an opt
  for i=1,self.opt_count do
   cards["opt"..tostr(i)].tx=16
  end
 else
  --if not coming from an opt
  init_cards()
  add_card("title",20,8,96,24,4,13,6,function(c)
   print_font_center("cryptograms",c.px,c.px2,c.py+2,7)
   print_center("decode the letters",c.px,c.px2,c.py+11,6)
   print_center("in each of the phrases",c.px,c.px2,c.py+17,6)
  end)
  add_card("copy",12,108,108,12,2,15,6,function(c)
   print_font("é 2019 j.l.h.",c.px+2,c.py+2,4)
  end)
  --add option cards
  for i=1,self.opt_count do
   local opt_name=self.opt_names[i]
   local card_name="opt"..tostr(i)
   local card_y=34+(73-(15*self.opt_count-3))/2+(i-1)*15
   add_card(card_name,16,card_y,100,12,2,12,6,function(c)
    print_font_center(opt_name,c.px,c.px2,c.py+2,1)
   end)
   cards[card_name].tx=16
   cards[card_name].ty=card_y
   cards[card_name].tz_spd=2
  end
  --add cards to appear in opts
  add_card("opt1_c1",200,59,100,23,2,14,6,function(c)
   print_center("choose cryptogram",c.px,c.px2,c.py+2,2)
   print("ã",c.px+30,c.py+9,2)
   print("ë",c.px2-37,c.py+9,2)
   if (st.opt1.lvl) print_font_center(tostr(st.opt1.lvl),c.px,c.px2-1,c.py+8,2) local done=load_bit(st.opt1.lvl-1)>0 print_center(done and "solved" or "not solved",c.px,c.px2,c.py+16,done and 3 or 8)
  end)
  add_card("opt2_c1",200,42,100,57,2,14,6,function(c)
   print([[
a cryptogram is a phrase
that has each letter in
it replaced with a
different letter. to
uncover the phrase, you
must change each letter
back to the right ones.

press ó or é...]],c.px+2,c.py+2,2)
  end)
  add_card("opt2_c2",200,42,100,57,2,14,6,function(c)
   print([[
you can do this by
looking at the patterns
and frequencies of the
letters. for example,
if a letter is way more
common than the others,
it might be an e or a t.

press ó or é...]],c.px+2,c.py+2,2)
  end)
  add_card("opt2_c3",200,42,100,57,2,14,6,function(c)
   print([[
try to look for common
words such as "the",
"to", "and", "of", etc.
the theme given next to
the cryptogram can also
help you figure out some
trickier words!

press ó or é...]],c.px+2,c.py+2,2)
  end)
  add_card("opt2_c4",200,42,100,57,2,14,6,function(c)
   print([[
use îÉãë to go
through the letters of
the phrase. hold ó and
use îÉãë to fill in
a guess for a letter.
use é to erase a guess
for a letter.

press ó or é...]],c.px+2,c.py+2,2)
  end)
  add_card("opt3_c1",200,54,100,33,2,14,6,function(c)
   print_center("programmed by",c.px,c.px2,c.py+2,2)
   print_center("jayson lowis harwin",c.px,c.px2,c.py+8,2)
   print_center("play my other games at",c.px,c.px2,c.py+20,2)
   print_center("winslowjosiah.itch.io",c.px,c.px2,c.py+26,2)
  end)
  add_card("opt4_c1",200,54,100,9,2,14,6,function(c)
   print_center("erase your progress?",c.px,c.px2,c.py+2,2)
  end)
  add_card("opt4_c2",225,67,20,20,2,3,6,function(c)
   print_center("yes",c.px,c.px2,c.py+7,11)
  end)
  add_card("opt4_c3",255,67,20,20,2,8,6,function(c)
   print_center("no",c.px,c.px2,c.py+7,2)
  end)
  cards.opt4_c2.tz_spd=2
  cards.opt4_c3.tz_spd=2
  music(songs.menu)
 end
 self.opt=prev.opt_id or 1
 menuitem(1)
 menuitem(2)
end

function st.menu:update()
 fade_in()
 move_cards()
 self:hover_title()
 for i=1,self.opt_count do
  self:optc(i).tz=self.opt==i and 6 or 2
 end
 if btnp(É) then
  self.opt=(self.opt-1+1)%self.opt_count+1
  sfx(sounds.move)
 elseif btnp(î) then
  self.opt=(self.opt-1-1)%self.opt_count+1
  sfx(sounds.move)
 end
 if (self:optc().px>=0 and btnf(ó)) sfx(sounds.write) switch_st(st["opt"..tostr(self.opt)],self.prev!=st.game and self.prev!=st.win and self.prev!=st.opt1)
end

function st.menu:hover_title()
 cards.title.z=3+1.4*cos(time()*.7)
end

function st.menu:optc(o)
 o=o or self.opt
 return cards["opt"..tostr(o)]
end

function st.menu:draw()
 gen_draw()
 local oc=st.menu:optc()
 spr(1,oc.px+(oc.px2-oc.px)/2-2,oc.py+9)
end
-->8
--menu option states

st.opt1={
 opt_id=1,
 lvl_df=1.075,
}

function st.opt1:enter(prev,do_next)
 for i=1,st.menu.opt_count do
  st.menu:optc(i).tx=-120
 end
 cards.opt1_c1.tx=16
 self.lvl=min(do_next and next_to_do() or ph_i,#phrases)
 self.lvl_d=1
 self.chosen=false
end

function st.opt1:update()
 move_cards()
 st.menu:hover_title()
 if not self.chosen then
  fade_in()
  if btnf(ó) and fade<=0 then
   self.chosen=true
   music(-1,600)
  elseif cards.opt1.sx2<0 and btnf(é) then
   cards.opt1_c1.tx=200
   sfx(sounds.write)
   switch_st(st.menu)
  elseif btnp(ë) and not btn(ã) and not btnr(ã) then
   self.lvl=min(#phrases,self.lvl+flr(self.lvl_d))
   self.lvl_d*=self.lvl_df
   sfx(sounds.move)
  elseif btnp(ã) and not btn(ë) and not btnr(ë) then
   self.lvl=max(1,self.lvl-flr(self.lvl_d))
   self.lvl_d*=self.lvl_df
   sfx(sounds.move)
  elseif btn(ã)==btn(ë) then
   self.lvl_d=1
  end
 else
  fade_out()
  if (fade>=1) ph_i=self.lvl switch_st(st.game)
 end
end

st.opt1.draw=st.menu.draw

st.opt2={
 opt_id=2,
}

function st.opt2:enter()
 for i=1,st.menu.opt_count do
  st.menu:optc(i).tx=-120
 end
 self.opt_cards={
  [0]=cards.opt2,
  cards.opt2_c1,
  cards.opt2_c2,
  cards.opt2_c3,
  cards.opt2_c4,
 }
 self.card=1
end

function st.opt2:update()
 fade_in()
 move_cards()
 st.menu:hover_title()
 for i=1,#self.opt_cards do
  local c=self.opt_cards[i]
  if i<self.card then
   c.tx=-120
  elseif i>self.card then
   c.tx=200
  else
   c.tx=16
  end
 end
 if (self.opt_cards[self.card-1].sx2<0 and (btnf(ó) or btnf(é))) sfx(sounds.write) self.card+=1
 if self.card>#self.opt_cards then
  for i=1,#self.opt_cards do
   local c=self.opt_cards[i]
   if (i<#self.opt_cards) c.x=200
   c.tx=200
  end
  switch_st(st.menu)
 end
end

st.opt2.draw=st.menu.draw

st.opt3={
 opt_id=3,
}

function st.opt3:enter()
 for i=1,st.menu.opt_count do
  st.menu:optc(i).tx=-120
 end
 cards.opt3_c1.tx=16
end

function st.opt3:update()
 fade_in()
 move_cards()
 st.menu:hover_title()
 if (btnf(ó) or btnf(é)) cards.opt3_c1.tx=200 sfx(sounds.write) switch_st(st.menu)
end

st.opt3.draw=st.menu.draw

st.opt4={
 opt_id=4
}

function st.opt4:enter()
 for i=1,st.menu.opt_count do
  st.menu:optc(i).tx=-120
 end
 cards.opt4_c1.tx=16
 cards.opt4_c2.tx=41
 cards.opt4_c3.tx=71
 self.yn_cards={
  [true]=cards.opt4_c2,
  [false]=cards.opt4_c3,
 }
 self.yn=false
end

function st.opt4:update()
 fade_in()
 move_cards()
 st.menu:hover_title()
 if (btnp(ã) or btnp(ë)) self.yn_cards[self.yn].tz=2 self.yn=not self.yn sfx(sounds.move)
 self.yn_cards[self.yn].tz=5
 if (btnf(ó)) for i=1,#phrases do save_bit(i-1,false) end ph_i=1 poke2(0x5efe,ph_i) self.yn_cards[self.yn].tz=2 cards.opt4_c1.tx=200 cards.opt4_c2.tx=225 cards.opt4_c3.tx=255 sfx(sounds.write) switch_st(st.menu)
end

function st.opt4:draw()
 st.menu:draw()
 local c=self.yn_cards[self.yn]
 spr(1,c.px+8,c.py+15)
end
-->8
function decode()
 phrases={}
 local bits,byte="",9
 for i=1,peek(8) do
  local ph,str={},""
  repeat
   if (byte<0x200 and byte%0x40<8) byte=0x40*flr(byte/0x40)+8
   local val=peek(byte)
   bits=bits..bin(val,8)
   byte+=1
   while #bits>=6 do
    local num=tonum("0b"..sub(bits,1,6))
    bits=sub(bits,7)
    local chr=(num==0 and "í" or sub(abc_str,num,num))
    if chr=="Ä" then
     add(ph,str)
     str=""
    else
     str=str..chr
    end
    if (#ph>=3) break
   end
  until #ph>=3
  add(phrases,ph)
 end
end
__gfx__
0000000055a0000046157fe55f275df37e95c57f29d448668f2dad977ff05f4ef88f6d85436fe9b92d8db37e29d3f8756630df56f8e5767e95c57f29d448d7d3
000000005aaa000076f4f95f91476f296f413987ffdc5638f496fe0d467ddd5f69d35822ed59fd39d56ac5876be15f6ee7d879dfd238db977291782e1ee2f316
00700700aaa6e000847b5a776d91b74e7d9679e1d2787adf64d5d34adb5842edf34f7d9679e1d278fbf27d9956f6d95637edd437dd9f6302d43edd6f63f55f6e
000770000a6ee000e7c55bf45f6d75d34e3916f10956fc35a7f74d563dadb48d25d43eff976965cf6e8559fec4f32d0d074bec9f6ed793f9b4267329d448e758
0007700000ee00006c8564f74d563dadb48d25d43effd270b0c4feed84ffe59463115f4eb8b75ebc457fd7f23d95166d65f32edf5369d15636dfd4fd8956fee5
007007000000000084ff29d23c1ad23c6e5f735a773e0ed38ced9463118f5fd9e3f74d563dadb48d25d43eff5369d15636ffc56bd3d4fdb45f5d9968f6d99569
0000000000000000a9f82d8db33ec1d45639d278eb97428d457ff25f4ef89f27dc9463f05f73e7047be5b92ddc537fb0879febd238db577eadc49eff585369c4
00000000000000005bdfe5f755d3563acf6d75967ff817fdbc4f6d75967ff8378d3595f6e8768d25d2fe3656ffe9d356dbd4fee5763d99b93ef1b77d29d2fe75
e2f3c4f35efd53f2e4d440f0076fe19f7091f58d25d2fe3656ff29c2fe35365d3d069eff1579f496f216d393f0062cfdf53f95d57aedd37cf7d4f8b45f301e9f
478dd73edd4ffbd85667f9877fd3436be3c55bf44ffb75d47db845ffd9764dc5c37bdb9722ed9f73db58796db34db808ffe9d2358d5f278df85dfc365ebc26f3
75567829777d998f6ffdd2f635a7f7fd16659158f8dc5667f9877fd1cf6d75967ff817fd75d235efd4fef4d24dfc377d994f6ee7f25d99b76d059f4e39167166
4f7ced9f67d5b76d055f4ef89f4e391671d797323e9f275df34ded4f2fddc47fe397f9e4763d992675eb063fec5f6ed703ffe856387ecf6be0f87d9156383ecf
6d75967ff817fddc5667f9877fd14f7bf09f465df36d65b37ef8572e7dd378db5439d9fb5e9997fd95347df1857fe7d238db16f975d33c36f95f91476f294f2d
7d863c6db53f95d57aedd37cf7d2fee584ffc8d3418d1663115f6606f34edd4ffb05c27d6a4f7beb9732dfd338dbd49ed54ffbe9846fc5e8f7ccd248b4c54c5d
f44db82323cdd4278df25f9908ff6d6630dfd4fd951686dff23e39178edf974cdc756e69e233ec5f69d3d7fde5762edc94330ef33e95164e8dc77b3956f89534
7e29f37da5c34dfc67f71ef97d95c57fd1d3fe75d24f25d2f76d6630ff9589f05f73d79732ef475f090a3e6dd74d9d368ef45f278dd720dc977ff09f6ed7157f
e5d480df9732ef976cf51336df48ffe5d235ef97f925e230df478f7acf2e8d5f71f0d338f117f16d6630ff9589f05f73d754833116f1d956379d06ffe584ffb8
135339a7f3e5763ef8577e91f88d9df7ade3137fdb977cdd9763119f4ef8f56d91b77d99f97f8d556816365f9908ff6d6630dfd4f8b4534e9d364edd4ffb25d2
7c254f6be08f7ef0c24ef1b57d29d448e75359add23cec6f41edb45e9908ff35363dc9c35bddf94f32466ec54f6ed59789fc185d36df6606f37f29f34db8073e
dda7f869c37b81c3fe65d37d9526fee9847bdb866fa585ff991686df848bf05f4ef8d4fc59d438db56f0656630df97f919e4306e5f68e55f79cd9f458da3f77d
d46191365ddc857b1d94468ddf6606f36ff8565af86f41994f7bf09f3d8d573361f32dcc567feb9589f04f7bf09f63d0d22acc85ff95344eedf93f99d751b877
8dbc877ff79589f0dff3656630dfd879dfd2fd3a56ffb4079fdb137fdb93f98956fee5d356dbc5ff2566f1e9847bdbd49dffd278991663d79679d09423ff9589
f0df7ef1f35d9908ffd45637dd9f7b3dd35e3ab98e359762f5b73db01638cd776ec55f50b857428d745e395472d9f94d0d6f63f59f32bc373df09576665f31ed
af63f5373dbc17fdd8843f55c39effd34cdcb47df4445bfb9589f0cffb16565ce85f49e3076be056f7d5565febc57bf8778d95d736db03ffb85f6685d386df56
387e9f36ed59fd25563aef9722ed59fd8556fe16847beb48ff65e430dfd498ff076be0d256dbd56fc146ff6d6630fff25d3e97f235772def075f395463855f63
e35842dcb46d915f69f08f6b325f6685447fe3035f39e330ddf95fb0c57fd7044fcc855fbc367ff095433556f8bc95f6c5d3461dd469d18f7bf05f4ef85f2d7d
e3fec9d3461dd469d3d4fdc8d24ddcd2563a9f713d959edb5873298f4e0d047ff016fe295646ece27376cf2deda4f365c25ebc367ff095433556f8ed84ff1694
59f85f6a3516fe99343d251773e5c46b31a7f339777d29d2fef8087f325638dfd4f8e584ff1a565ce8b94dc156f7d8847b61d3fd75d27895367e995f67e5847f
e3877ff0479beb837ff42730dd5f6ed754f9e9764df89596ff472f8d5f488d446ff3075f39546385df67d5b76df8565af84f7bf08f6ce5847ff0b33d329f4e99
47ffa5d27db4447fe756f0d5534cad977ff09f4ef8f83d995f68e59f6fe0d37ce5d2386a4f7ced9f4ef85f2add474bf4777e29d2fec4564ef8375dfc8f7bf05f
4e9947ff354f6ee7d738f8177db8069effc57b515f8eb4d4f8cdd3461dd469f397f9a5d7fe95069fd59f7ef157fe35364d95b34ddd9f6961f82ddf956911d3fc
1ae2f395347db4d863119f4eb8b76d85f38d3595f6d8846bd0f34dedf97fb4d53f6d4f7ced857ff3075f39546385df61e45f73d71679dbf23e955747dc4f3c6d
856c369f60c56f4199f58df44f2d8d9f7af057fdb44f7ced9769e397f915d3fee5946311773e99069fff847bc1f83d7dd37c95364d91474edc757ff095433556
f8ed84ff75563cdff47ee5c78edf075f39546385777e29f35d9d07ff354f5bef536902d438f4b37d29d2fe79d2f885e330cdaf61c55742ad863febd288ed9463
114f7ced9f427d475f09f97f315322cdb33df1176e85df3c6dd4419d365ffc367db0075f3a7f480d8f8ff037f975d2281df37d998f7ef0d2f7f5b62ddf5439eb
576ff81763c55f6ee797327d475f0ad39defd579e55f61e4774db808ffe984ff75d268f017fdb406fe79562c6d776d054ffbd996496dc3fed49453e8f97f9103
7fe15f323d16363d367ff095433556f83d5f3c0dd73ddf97f9c4f35eb8035ff8b34d7dd579b0b55efc075f3a4f3cdcd27ff49ff3b4f54d959336dd67f7add33e
cd6f216d457ff3075f39546385dff3e45698e55f6591784d0d9f61e44f8f39577e664f7ced9f73db58796db33df08f3ced877fd31479d39473e7076ff9877b39
56f835344ef84f4eec26757adf746dd3fdc5d328cdb37ff095433556f88d6641f807ffd4d2f875d2f809d438dbf26dfdc47ff8376ec55f67c5f37e8d976cf513
36ec9f3ced072fed5f4eb8364d8d9f42dd5f89855f6df5a5f77dd23cf5772dfd075f39d7fd3d167e91087fd1d469f39732df846ba9c47fe55f49e3d256db9583
f0774ddd4ffbc8d78ddf575939973ff8f98f91952e3d07ff3d167e91087fd1d469f3c56b325f63e11789f0177ee7936952b74df0d3f6b4774e0d5f4ef8f85d85
66f1f816791db42dcc567fdbf27ef51334dcb77d8d9753eb97323e5f6591782e6dd579e58f8ff0277329d44876df27cd97f395953d8d5f268de3f33d167e9108
7fd1d469f3157fe54f3cdcd27ff49f93755f7b3dd3fee8467f8559fe75c36bd3f44eb808ff85564e3916f1e5767eb4e8f7dd564a39f23df8c55c3916f13d167e
91087fd1d469f35822ed4f6ef4772d8d9f63e11789f017fee4768e25d3f825e375d7854fe18f5b9906afdf84ffd5878bdd8f5b99069fff056f81f44df0172ccd
e428ec857ff3d478c96630cd576385df4ef807ff35777e95c57f29d448e7146fe0d2378d875bdbd4f8e984ffe4d34dcdf37d999f220ef32ddf9369c55f6ee753
66d5e3f6d5c35b3916f199d7fee584ffc5d37ddb56f0e984ff16565ce8f92fcc23f315d348ffd478c96630cd576385dff3b4f57db0075f3a8f6cc5c3feb49569
f0fb4defd2f795143e8d4f6cc5c3fe39364dc5566fd94f6be08f7d91487e76df26fd1733dfe2f725d34695f34f8d976c06d37c3556f8edd3563916f1b4364e8d
976c06d37cdb97f915767e994ffba5d27c3a5f73e79553f45f3e6d9563114ffbd9d263e15f6ed754f9e5764ef89596ff534cdd775db0d5f33d167e91087fd1d4
69f39732cde375d7f23e391430cdd338f48f3ced483f8d9f7af0047fc1d448e7136955777d999f2acd9733dd4f6be09f7af0047fc1d448e75783e9c36fd3437b
d95f6ee7473f3d16f1e584ff69d441e95f49d3838b7edf26fd076fd3d579c1d456fbd478c96630cd576385df4ef8079fd54ffbe59463118f3b91d7fec4d36311
8f5b9906ffb406fee9847ff059fdb45f4e3916f1b81379ed4f3c3d16f16956386de8f6b406fee9848f5e07ffe558f9e8d440f0076fe19f4e39167176df2c8d83
5b695f778d1739ffd478c96630cd576385df69f04f2e3e5ff316d456eb1463e05f4ef85f4c1d94fe1a563cd9b92d8db37d29e3f31ad456db03ffd5d46769e3f7
4dc25dd7457f91c73bf7584cedd448f7f28d9507fe35776d91b77e29f37db4c5ff16d44eeb5638df584cedd3fcb4778e3597f2b4167929d39cef5638df872fcd
774ded9f7091f54d39774df5979def9732df564ef8376df99576e7d4fe95d7fe95344d39776e06d33c95d2fea9465df4a7f7dc847b61d3fda5d3713eef713197
6311df93e45f2ced847fd303ffd8d24f25b74d99854e8d747ead4ffbc4d258d797228d9f7df8d2468d747d959f77dcb42ddd4ffbe558a9e35879e05f4ac9d23d
ef146c754f6b919732cdaf7131877f72df24dc757d75d44efb584cedd448f7d4f0e5847ff059fdb48f6c95758d9df77df0d2563aaf218db77d995f3cbca3f6c8
d7fe35b74db85798e58f3cfc368dc5d47ef8368efca7f6e5846fd3d879efd57fe56f713187ff35a7f7ed5648dfd579c1d46d85ef7131976311df4ef85f7d9927
f3354f5bef584cedd448d7e342dd979deb584ced876fd3d4f8b8136d65d73e6df86ef81730dcb74eb057429d26f6d55637ef9626dce3f635367d29f32e3d27f7
b495f6355f77ddb73e995f73d71463e05f736a8f6be04f6da5f84dedf95ff1857fd7076fb007fe1e17733916f1ed84ffc55636df56f0b4af7131877fd3d4fd85
56fee9767db4f88d25d2fe16f32e6db53db4367db4e8f6c8d7fe16847bdb48ffb407fff9063b61f37d995f2d3ef92f8dd273d71663f3584cedd448f79732cdf3
2dcdf37d29073fef175ff8774d91378ec5d44e8d742def1689f0a5f7f91660c5976fb0875f3ab96e915f69f05f659158fd1a847bdb97323e4f7bf0f98f765f6d
75d37cf4b75dbcd741b8f58fc5d44e8d748f25d3f8d55637ed9463118f2d8d4f3cdf072fecaf41ed9479ed4f4f01567c6a9f71f0d2fef41460c5b74eb8774d95
06ff35166ee7d47ed7584cedd44876cf6fc1d47bfc5f24cd93336d5f6a85435fb8ef7131976311df4ef807ff35776e9197428d747d99af7131976311f92d6db5
8e9df73d995f73d75773eb9389854f7bdbf27e3a868fc5d43ecd4f6be08f5cf8c39effd36cf057fe25d3478d64213eef7131976311ef71319763114f6d75d3fd
79563cdfc37b35a5f335348e9df74db808ffd95637ed9463115f6ee7478b7edf4d99855fdfd23d25ef7131976311df268d542f1df34d91073ddd9f7fd797f9a5
d33cf4e430ef9732df587961b32ddd9f278d5f7af0476fe1774ded9f6ed7d79dff155f39f26df8065f9986ff6dd248f5d231ff16f99506ff75c36bd18f5b695f
32df478bddb92e8db38dfcb78df027f309e3f1d5e2f3b495f6e9848fdfc52f8db94d91378e95077ed7d23cef5746ad867f324f6be09f4e99d741e95f73e71873
d4567f76df328d27f3c4176955772decd277f7856b11c74bf4ef61c593fdd5d4613124f379d298d55f3c0dd72d6d9f6ed7c23df496fee584ff1a565ce84f7bd7
d4fe3567f71ed276f8375db4d750bc16f86dd248f5d231ff5822ed6f61c593fdd5e2f3e8467fd71679db857be5f93ef0437bddf38d95077ee7d23cdfd286b4d8
fde584ffd9d2376e4f6be06f41b8b77e29e3f3d5e2f335776ef0087fd39732df475bfcf92f8d976931766d99074d39f25fb81671bc44ff6dd248f5d231dfd4fd
e584ff79c36bd15f49e3447fe9d448d7d2f835832fef146c755f87df132c3d364e8d97f936567fd1af41ed9479ed9f7dcd447f32f95fbc17f5b4d53399365fb8
1671bc44ffccf83d2556793516f1e584ffc9d441e96f61c5939debd879df436bd3875bf44f6be3c43ebc5f4eb8a775e7846ba9d3488d744d8daf63f5374df8c2
feb406fee927f3e5765dbc45ffb4364eecc3fb65d435dfd4fe29d26af8364d8d9f6d75d369f04f5fd9e37576df2c8d835b695f778d1739ff856b11c74bf4df73
5a772ddf577eb01631ef587961b36d059f268d542f1df34d8daf413953f2d5457b3916f199367d29d4f83543ffd4d2f819d3fe3656ff35166ee79479db487bf8
27f70d076b519563d3a6f7455638dddf268d542f1df34f0d5f4ef84f6f119573259f268d542f1df35dbc83ffb826f3d5d378f4b95eb85325ecd27335435beb58
796db34db808ffd95637ed9463115f6ed793f91ad44edbf27d25567cb844ff99344d616631cd67f7ec564fd7857bd156f86dd248f5d231ff567fd3856b11c74b
f45f73e7146f81f8add3f24db0b73e25d238f44f6be04ffbd99553df53228d43ffb407ffe984ffd5d237df97428d64f74df94df5572e0e6f413987ff6dd248f5
d231ff1b43d3d879df436b52b77eb4f87d95c57f29d448e71633f4b97db4f84ded5f63e3143c8d5392da5f87efd57929d3fcb4a340ddc3aef7183355f45d3906
3ecddf268d542f1df33f996f63f54f8ff0378e95063ecd5f43d39732ef867fd156f835367d29f36ef9835ef85f73d7072f6db92e8db38d9de775f05f74ddb72e
df074f61c37d3956f89534ce25d4c7b6cf4c6db58db4973ecd5769f3072f6dd48eff072f6dd48edfd4fde5847beb5842dca4f616846fd3d879ef576ea54f3c6d
c48f3116f139364dedb93d99d36d52b74e954f8bb4e8f7ad945339b65d764f4edc757ff0d246edf87ff0d246edf84ddd5f4ef89f36bc9363114f2dfd47ff9934
7de5077fd58f5b9d1671e55f4e9947ff39367d99c74ddb5873299f737adf248df38db45438cddf3cbc95733acf6bd3d37c91373d99d3fd8956fec4c36d75f37e
c9d74edb23f3c5c37b95366e055f776d976369c43feb966ca5d221edd469629f68c54f6ef4777dc9d74eeb033f95c5fff4176cc58f3cdcd27ff45f68c4468eef
473fdd5f737adf272dd25ebc5f218d9342ff072f6dd48eff9489d7c56b325f361d773e99d3fdb44f6e155f220ef34e0d6f63f54f2d6db57d29f37eb8d4f6b45f
361dfa4e91d79cdf435b69d448e79732df874b6d4ffb65d3f1e8467f8559fe75d235dfd4feb85f361df92fcc074bb8f55d39066d65367ff0d246edf87f29d33c
dfd4fdb4366ec4053fe5e430ef072f6dd48edf567feb9732cde3f6c4d7fe16f38e31e3f135b77d2917791db47e29f37da5c37db85336dd9f49d3567fd3035f39
d370668f7be9d47eecd39ddbd238eb085bf9d39dff838b31b34d765f87fc17fdcdc35b39a7f38d564e3916f1f49873e5773e2e436fe94f7b99d5fdb806fef4d5
7a3a9f6db843bfefe330cdd84e3916f1f4953defd4fd959663315698ff835f9d534cedd7fdcdc35b39a7f3cdc35b39a7f335775efc075f3a4f6be3d456f95763
85b92e6d034fed4ffb06d38cef867fd1d47df816fe95069fffd236f017fef4d478e5d363f3072f6dd48eff072f6dd48edf852f0ed3fdb85f66e55f6ed79732ef
d4271dd428edd46972df6425365df8166885df3cbc95733adf4ef807ff35776d916f213eaf63f54f2d8d5f7ff45f4ef8af61c5b3bdc1c35b39a7b3e758732956
7febd66fe5d24e9d365dbc1775e7d26cf506fe35a7f74d563dadb43db4d53af095f6cdc35b39a7f3bc5f27ed845fbc973335d2f839772ddfc53b25d438ef1479
d3977f81d448e7534901c3ff35166ee797329d075fddf97ff02643dfd246c1c3fe7dd24efbd4f0a5d36969f33d999f68e54f3c6dc48ff09f4eb8b75ebc97327d
d24edc774ddd9f4d7d96366e5f73dbd4fd991686df033fb4d73def97323e4f6ed71679eb072f6de434df9489e75359ad9533b4873feb9543f05f7376df642536
5d99d773d71869d3067f7dd268f3c57b29df4ef84f7fd5d338f45f49e3c57b29d327edc47dd7d4fd8956fee5765dbc45ffd9d46769f37d29d448d58f6d759646
dcd23eecb93ef1b77d995f275df33e95d55a39437bf8b37e29d448d55f4d7d96367edf9ddf543fe8d3fc7dd24efb54f9e46661d3833fad8f6f91d741dbd47899
8f6b3297428d742d8db38e9df78d3595f605d438ebc57b29d327edc47d76cf3ebc367dd49446dc877ff3c57b29df7acdf35ebc97327dd24edc774ddd9f4ef85f
271dc44dbc2675e7072f6d6f218da3f78d66206dd4fd7dd24efb967ff09f27ed845fbc9733d55f73669f63d3d47ed7488b6e5f4ef89f6af4978cdf56f0695641
dcd2f635832fddf92f6d037fe14f4f8d573e3d365fbc97f23d5f7ff4b37d995f6606f35ebc97327dd24edc774d91374eed776d16367db4459febd238dbf47de5
d456db9399eb033fb4d73ddfd4feb8956616774d91376d919f82ad467d3167f3b406fe89768db0543f8dd37d96df7df8064eb8b55fbc97f27dd24ef8c57b3953
fd35777e29f37df5963c7df35ef19331fe5f7091f54ded773ef85373355678d79732cdf34edd5f68d7d26af8d296ff973931d2fde4d2784ad4f17dd24efb966c
95344ddd4f6be3c46e654f3c0d563cef5862755f4ef85f7acdf35ebc97327dd24edcc46be39779e1d73cdd9f427d475f09f92fcd9772cd5f7db816363e4f3fe8
d448e556f87dd24efbc57b29d327edc47dd7d4fdb8775dfd53f2b4362edd863fe55f49e3535fe9d73cdfd2fd35b74edd4ffbd45656f8534e9d366e054f5b1956
4ced947776cf2dcdb53d91c87ff3c57b29df4ef85f63e1d36cf0b74ddd9f74ddb72ddf587961b36eb8574d8d742dcd566fe09f68e5d3fd35362def5326dd576c
95e5f74d56f8d5878fb417feed84ff35163ecd067ffbe5f305e260c5d43eef97428d742dcc567fdb9732efd478f81738ed5f73e79722ed6f63f55f31ed5f6ee7
54f935166ed79732ef964c0ed23edf587961b36e055f3cbcb53dc5c36fd9af41ed9479ed5f220ed448e797f9d5c55f695f4ef8e5f7add368d3155369d37ef8df
4ef85f63e1d36cf0b77f29f39d85d3fe35772def487be5f36d055f4e7de3f6b806fee5847b5a773e2ec27d69f88d25d29ed59f4c1d94feb41379ed5f737aef41
6d95237d5f41cc5769f39732dfd478f81738eddf4ef85f63e1d36cf0b74ddd8f3cdc56478d747d29f37e9958f8d5d62fcdf34d91377e29f34d65462c6daf406d
854bf45f49e397599d176c16f93f3195f615d23edddf4ef85f63e1d36cf0b72f6dd579e59f89f017481d949edb9732efd478f81738ed59fd155638ef146c754f
fbe9c34d890030435beb5869e0d3fce5762def137f35067fd55f77dda7f7ccd456db474dc9c23ecddf4ef85f63e1d36cf0b74f3108ff36c37bd14f4b95b98ef4
5f4e99d741e95f49e39732df483fd3d2fdb49f381e5f37ecd45f6e5f68e58ffb85e3f1f4536991e593ff53367dd378dbd559f79732dfd478f81738eddf4ef85f
63e1d36cf0b74edd2675db143cfcf94ded9f74ddb74db8772d8d8f3f9516593e5f4eb8b75ebc457fd716f9d5d378f49f6ed7436b39875b395797ff132cec5f4d
b8866de5b77f29f34d8d877f81d3feed84ff35163ecd067fdbd4fde984ff16565ce859fd69d24cf457fe69c47cb02793dfd49ed59f74ddb77d29d2feb495f6e9
84ffc45659d54f7bf09f69d39732df14669527f74d5662d3d256f8366db8d766d5df4ef85f63e1d36cf0b74f8d147971d24e9d366d859f4ef85f63e1d36cf0b7
4ddd9f7dcc053fe55f6ed79732ef475bfc5f7c6dd3fdb406fec9d3716dd24e9d16fdb4773e952630cd477b3956f8b4b72edf037b72df319d1731df956fe0037f
11df4ef85f63e1d36cf0b77f29f36dc9465cf8f58e3597f235163ecd067febd66fe5d3fd35777d29d2fe3a56ffd4d26891b72e6d488bdd4f3eadd338eb56f8e5
844fcd8f3bd4d72cdce8f7bc132c2dd2f765d4389595f8ed84ff35163ecd067ffb97f9c4f32d7dd73dec4f8cef5822ed6f63f55f3cbcb3ade39722ed5f73d797
32ef543cbcb77da51763115f49e3846ba9f86efd562eedd469d1f93f76e3f7755678b8543fffd66fe5d3fd1e846fd3f44df8d2fc95377ef0c2feb45f6195b35e
3906ff354f2d8d9f22cd9386df484bed5f6ee7875f695f73db97f9d95637cc468edfd376f47a7f91037fe14f8ccd06ffbdd779f8774fed5f73d7f26e69c37bf5
07ffe5763df08f3b61f37d995f7b9d87ff69d438dd5f6ed71473ebd288df463db45763857a2fcc074bb8f55d39066d65366ffd563edddf69f05f49d39732ef54
3cbcb72eed972cdc976385776d059f7b9d877b395678d7d4fde9847bdb97323e4f7bf09f4cdcb44d8d5f33f8d2fd1a9433254f2d8d4f3cef874b6d563cec5f6e
e7573adcd440dc9f7acd9679f467f7cd463ccdb74dcd1863f05f40ed19328d27f3bdd779f8776f914f6ef513fe9506ff79e2f3b5d779f89f42dd9779325f6ee7
576fa9567cdbd288ef437bdde3f6b4777d29f33ef81853dbd66fe5d3fdd9534cad977ff0f95ff8d26cf0b34db806febdd779f8776f85f35dfd57fec4f32def58
73f45f3cbc837fd397f9b9d779f86f41ddd386efd238db485f69f92f7e4f7c91166d854f5bd8567efbd66fe5d3fd2de230dfd879dfe330cd9f39d1d38cf0b37d
29d2fe1af36db8f85dfd53f279563cdfd27ef8164e9d367e994ffb16d43def867bd5d231df58328d5f73ebd4fdb5d779f8a3f6e5846be358328d6f31df072fec
5f73ebd4f8e584ff95174335065bebd27f2956acff96426dd4fa15d436f017fe25d237cd9769f3d66fe5d3fdbdd779b8976385778d3595f6e9d356db9732df14
5f699f37bc577ff05f49e3c52f8dd448665f43d3d879ef848bf04f6f91d741db56f0e9845f7edf247dd3fd75d77cb0f86ffd563edddf735a773dbc5733cd5f6e
e7d66fe5f36d99d37ee797228d5f6ed7072fec9f4ef8e5f7bc9546dd56f8c4d27c9158fdbdd779f8775fbcc83cdf567fe3048b911773f89f7b9d877b395678d7
478befd579f04f3b91d7fef5777e29d2f8b41379ed5f4ef89f7d991733dd4f6be09f3a9d9636df489fc5f36efd564e8d64f74d5662d3543cfc366ffd563eddcf
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
011100000c62300000000000c6231d633000000c623000000c62300000000000c6231d633000000c623000000c62300000000000c6231d633000000c6230c623000001d6330c623000001d633000000c6230c623
011100001a1401a1401c1401a1401a1401a1401714018141181401814017140151411514015140131401014110140101400e1410e1420e1420e1420e1420e1420e1420e1420e1420e14500000000000000000000
01110000135461754613546175461354617546135461754613546185461354618546135461854613546185461554618546155461854613540155411a5401a5401254615546125461554612546155461254615546
011100001a1401a1401c1401a1401a1401a1401714018141181401814017140151411514015140131401314510140101401014515140171411714515142151421514215142151421514500000000000000000000
011100001a1401a1401c1401a1401a1401a14017140171451a1401c1411c1401a140181401814017142171421714217142151421514215142151451b1411b1421b1421b1421b1421c1451e1401e1451f1421f142
011100001354617546135461754613546175461354617546135461854613546185461354618546135461854612546155461254615546125461554612546155461254617546125461754612546175461254617546
011100001f1421f1421f1421f1421f1421f1421f1421f1421f1421f1421f1421f145000000000000000000001714017140171401814017140171451514215142151421514213142131421314213145101400e145
01110000175461c546175461c546175461c546175461c546195461c546195461c546195461c546195461c546185461c546185461c546185461c546185461c5460f5001250017500125000e540105400e5400e540
01080000246141f63118651136310c6110c6152013020130221302213023140231402314023145201402014020140201452315025151251502515022152221522215222152221522215222141221212211122115
01080000207002070022700227002370023700207302073022730227302373023730237302373520730207302073020735207302073020730207301d7301d7301d7301d7301d7301d7301d7211d7211d7111d715
01080000207002070022700227002370023700207302073022730227302373023730237302373520730207302073020735257302573025730257301e7301e7301e7301e7301e7301e7301e7211e7211e7111e715
01030000191001a1001a1001a1001910019100191001910000000000000000000000000000000000000000000000000000000000000000000000000000000000191001a1001a1001a10019100191001910019100
010c0000191501a1511a1501a1501915019150191551050000000000000000000000000000000000000000000000000000000000000000000000000000000000191001a1001a1001a10019100191001910019100
010c0000151501715117150171501715017150151521515215152151521213112135000000000000000000000000000000000000000000000000000000000000191501a1511a1501a15019150191501915517100
010c00001515017151171501715017150171501515215152151521515212131121350000000000101501015510150101501215112155151501515515150151501515015150171501915119150191501915517100
010c0000151501715117152171521715217155171001710000000000000000000000000000000000000000000000000000000000000000000000000000000000191501a1511a1501a15019150191501915519100
010c00001515017151171501715017150171501515215152151521515212131121350000000000101501015510150101501215112155151501515517150171501715017155171501915119150191551715015151
010c0000151501515015150151550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000191501a1511a1501a15019150191501915510500
010c0000157401574519740197451c7401c7452174021745157401574519740197451c7401c7452174021745147401474519740197451c7401c7452174021745147401474519740197451c7401c7452174021745
010c00001274012745157401574519740197451c7401c7451274012745157401574519740197451c7401c74510740107451474014745157401574519740197451074010745147401474515740157451974019745
010c0000127401274515740157451a7401a7451e7401e745127401274515740157451a7401a7451e7401e7451074010745157401574519740197451c7401c7451074010745157401574519740197451c7401c745
010c000017740177451a7401a7451e7401e745237402374517740177451a7401a7451e7401e74523740237451074010745157401574517740177451c7401c7451074010745157401574517740177451c7401c745
010c0000157401574519740197451c7401c7452174021745157401574519740197451c7401c7452174021745137401374519740197451c7401c7452174021745137401374519740197451c7401c7452174021745
010c0000127401274515740157451a7401a7451e7401e745127401274515740157451a7401a7451e7401e745117401174515740157451a7401a7451d7401d745117401174515740157451a7401a7451d7401d745
010c00001074010745157401574519740197451c7401c7451074010745157401574519740197451c7401c745127401274517740177451a7401a7451e7401e745147401474517740177451c7401c7452074020745
010c0000157401574519740197451c7401c7452174021745157401574519740197451c7401c74521740217451074010745157401574517740177451c7401c7451074010745157401574517740177451c7401c745
010c00001353415531155301553015530155301553015530155321553215532155321553215532155321553213531135301353013530135301353013530135301353213532135321353213532135321353213532
010c00001353012531125301253012530125301253012530125321253212532125321253212532125321253211531115301153011530115301153011530115301153211532115321153211532115321153211532
010c00001153010531105301053010530105301053010530105321053210532105321053210532105321053511500115001150011500115001150011500115001150011500115001150011500115001150011500
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
010600000c63021631216302163500600006301363113630136350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500000e55013550175601756017565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000130501f0501f0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00 01 02 44
00 00 03 02 44
00 00 04 05 44
02 00 06 07 44
04 08 09 0a 44
00 0b 0c 43 44
01 0d 12 43 44
00 0d 13 43 44
00 0e 14 43 44
00 0f 15 43 44
00 0d 16 1a 44
00 0d 17 1b 44
00 10 18 1c 44
02 11 19 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
