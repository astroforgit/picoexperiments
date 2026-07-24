pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
--picoball - football manager
tutorial=true
animations=true
num_rounds=17
c_tp=0

city_names={
 'barcelona',
 'paris',
 'seoul',
 'amsterdam',
 'sao paulo',
 'st.petersburg',
 'porto',
 'warsaw',
 'tallinn',
 'buenos aires',
 'kawasaki',
 'helsinki',
 'kyiv',
 'heredia',
 'malmo',
 'roma', 
 'munchen',
 'manchester'
}
tips={
 {
  'players have an',
  'attack and defence value.',
  'every player can be played',
  'as attacker or defender.',
  '',
  'some players also have',
  'specialties like   eamwork.',
  sprites={{179,7,18}}
 },
 {
  'your team has to defend.',
  'use   and',
  'to select a defender.',
  '',
  'try to match the opposing',
  'attack with a defence',
  'that is equal or higher.',
  sprites={{61,2,5},{62,2,11}}
 },
 {
  'goal! the defender doesn\'t',
  'have enough',
  'defence to stop the attack.',
  '',
  'after a goal, the defending',
  'team gets the ball.'
 },
 {
  'the defender has enough',
  'defence to stop the attack.',
  '',
  'now the defender will',
  'try to take the ball.'
 },
 {
  'the defender has enough',
  'attack to take the ball.',
  '',
  '(matching values is always',
  'a win for the defender.)'
 },
 {
  'the defender doesn\'t have',
  'enough attack to take the',
  'ball.',
  'the attacking team keeps',
  'the ball and can attack',
  'again with another player.'
 },
 {
  'each of your 11 players',
  'gets to duel.',
  '',
  'your team has the ball.',
  'use   to play your best',
  'attacker (x on keyboard,',
  'b on controller).',
  sprites={{59,5,5}}
 },
 {
  'choose a football club',
  'to manage and use ',
  'to continue (z on keyboard,',
  'a on controller).',
  '',
  'you will play 17 rounds.',
  'your progress will be saved',
  'after each round.',
  sprites={{58,2,19}}
 },
 {
  'this is your team',
  '',
  'you can change it',
  'after each round.'
 },
 {
  'use   to select your',
  'new player on the team',
  '',
  'then remove a player',
  'with   as well, to get',
  'down to 11 players again.',
  sprites={{59,1,5},{59,5,6}}
 },
 {
  'this is just the',
  '\'are you sure?\' screen.',
  '',
  'nothing more!'
 },
 {
  'a second half is always',
  'played, where the other',
  'team gets to kick off.'
 },
 {
  'after 2 halves, if the score',
  'is tied, overtime is played.',
  '',
  'in overtime 2 shorter halves',
  'are played where only',
  '4 players get to duel.'
 },
 {
  'your team is not ready.',
  '',
  'a team has exactly 11 players',
  'with a maximum of 30 stars',
  'and at most 1 keeper.'
 },
 {
  'you can always start',
  'a new run using the menu',
  '(use start or enter).'
 },
 {
  'that was a good run!',
  '',
  'use   to view your final',
  'team and share a screenshot',
  'on the picoball thread!',
  sprites={{58,3,5}}
 },
 {
  '  eepers are very strong.',
  'they always take the ball',
  'after they defend',
  'succesfully.',
  '',
  'keep in mind that you can',
  'only have one keeper',
  'on your team.',
  sprites={{176,3,1}}
 },
 {
  'when players with   liding',
  'defend, they try to take',
  'the ball before the attacker',
  'gets to try and score.',
  sprites={{177,3,19}}
 },
 {
  'players with the   eign',
  'specialty have a choice',
  'in who will defend against',
  'them when they\'re attacking.',
  '',
  'they can pick one out of two',
  'defenders.',
  '(the other defender will',
  'go back into the hand.)',
  sprites={{178,3,18}}
 },
 {
  'players with   eamwork are',
  'stronger when your previous',
  'player is from the same',
  'country.',
  '',
  'the player\'s stats are',
  'green when the bonus is',
  'applied.',
  sprites={{179,3,14}}
 },
 {
  'players with the   eader',
  'specialty get a bonus when',
  'your team attacked and',
  'kept the ball in the',
  'previous duel.',
  sprites={{180,3,18}}
 },
 {
  'players with   omeback get',
  'a bonus when you\'re behind',
  'in the current round.',
  sprites={{181,3,14}}
 },
 {
  '  ucky players get a bonus',
  'when they are the last',
  'attacker of the half.',
  '(last player in the hand.)',
  '',
  'don\'t _always_ save them for',
  'the last minute!',
  sprites={{182,3,1}}
 }
}

abl_hints={
 'eeper:always takes the ball',
 'liding:can take first on def',
 'eign:on att choose a defender',
 'eamwork:+1 after another',
 'eader:+x if you kept the ball',
 'omeback:+x when you\'re behind',
 'ucky:+x if attacking last'
}

c_sel1={12,8,9}
c_sel2={6,14,10}
darker={[0]=0,0,1,1,2,1,5,6,2,4,9,3,1,1,2,5}

function _init()
 cartdata('allstarcardfootballmanager')
 menuitem(1,'start new run',init_run)
 teams=t_range(18)
 set_tp(2)
 r_adr=0x1800
 cards=t_map(t_range(324),read_crd)
 r_adr=0x1b00
 dcks=t_map(teams,read_crds)

 set_viewstate({tim=0,stt='rdy'})
 
 init_run(true)
end

function _update()
 local tip=tips[cur_tip]
 if tip and tip.stt==1 then
  if btnp(4) or btnp(5) then
   tip.stt=2
   cur_tip=nil
   return
  end
 end
 if (not frozen) update_run()
end

function _draw()
 if frozen then
  v.tim+=time()-last_frame
 else
  draw_run()
  draw_tips()
 end
 
 frozen=cur_tip

 last_frame=time()
end

function set_viewstate(vs)
 v=join(v,vs)
end

function set_ani_done()
 set_viewstate({anim={},stt='done'})
end

function show_tip(tip_ind,multi)
 if (not tutorial) return
 local tip=tips[tip_ind]
 local adr=0
 local tip_i=tip_ind
 if tip_i>16 then
  adr=1
  tip_i-=16
 end
 local tip_stt=dget(adr)
 if (not tip or cur_tip) return
 if (not tip.stt and band(tip_stt,2^tip_i)==0) or (multi and tip.stt!=1) then
  if adr==1 then
   if abl_tip_start then
    if time()<abl_tip_start+1.5 then
     return
    end
   else
    abl_tip_start=time()
    return
   end
  end
  abl_tip_start=nil
  cur_tip=tip_ind
  tip.stt=1
  dset(adr,bor(tip_stt,2^tip_i))
 end
end

function draw_tips()
 local tip=tips[cur_tip]
 if cur_tip and tip.stt==1 then
  draw_tip(tip)
 
  local xa=({11,15,91,91,13,41})[cur_tip]
  local xd=({55,71,11,11})[cur_tip]
  local y=({38,66,49,45,45,42})[cur_tip]
  
  if xa then
   print('attack',xa,y,8)
  end
  if xd then
   print('defence',xd,y,12)
  end
 end
end

function draw_tip(tip)
 local sprites=tip.sprites
 if cur_tip>16 then
  tip=t_concat({'   Öênew specialtyêÖ',''},tip)
 end
 local w=4+4*t_fold(tip,0,function(maxi,s) return max(maxi,#s) end)
 local h=#tip*7+4
 local x,y=(128-w)/2,(128-h)/2-10
 local x2,y2=x+w,y+h
 darken2(x-1,y-1,x2+1,y2+1)
 rect(x,y,x2,y2,15)
 for i=1,#tip do
  print(tip[i],x+3,7*i+y-3,7)
 end

 for s in all(sprites) do
  spr(s[1],x+4*s[3]-3,y+s[2]*7-4)
 end
end

function draw_card(crd,x,y,select,ply_ind,anis,is_new)
 anis=anis or {}
 if (crd==nil) return

 spr(0,x,y,4,4)
  
 draw_ability(crd,x+10,y+11,anis[5])
 for i=0,4 do
  local str_spr=i<crd.str and (crd.rar==1 and 6 or 5) or nil
  draw_star(x+3,y+3+i*5,str_spr)
 end
 draw_flag(crd.tea,x+21,y+21)

 if (is_new) spr(42,x,y)

 draw_select(x,y,x+28,y+28,select)
 
 local att,def=get_bon_stats(ply_ind,crd)
 draw_stat(att,x+10,y+3,att>crd.att and 11 or 8,anis[1],anis[3],-3,-4)
 draw_stat(def,x+20,y+3,def>crd.def and 11 or 12,anis[2],anis[4],-3,-4)
end

function draw_select(x,y,x2,y2,select)
 if (select==nil) return
 rect(x,y,x2,y2,c_sel1[select])
 rect(x+1,y+1,x2-1,y2-1,c_sel2[select])
end

function draw_stat(val,x,y,c,big,blink,big_offset_x,big_offset_y)
 if (blink and flr(time()*10)%2==0) c=darker[c]
 two_digits=abs(val)>9
 if big then
  pal(7,c)
  chr1=flr(val/10)
  chr2=144+val-chr1*10
  x2=x+(two_digits and 7 or 3)
  if two_digits then
   spr(144+chr1,x+big_offset_x,y+big_offset_y,1,2)
  end
  spr(chr2,x2+big_offset_x,y+big_offset_y,1,2)
  pal(7,7)
 else
  x=two_digits and x or x+2
  x-=(val<0 and 4 or 0)
  print(val,x,y,c)
 end
end

function draw_ability(crd,x,y,blink)
 local abl=crd.abl
 if (abl==nil) return
 show_tip(16+abl)
 draw_ability_icon(crd,x,y,blink)
 local dy=(crd.def_bon>0 and crd.att_bon>0) and 3 or 0
 if (crd.att_bon>0) print('+'..crd.att_bon,x+8,y+1-dy,8)
 if (crd.def_bon>0) print('+'..crd.def_bon,x+8,y+1+dy,12)
end

function draw_ability_icon(crd,x,y,blink)
 if (crd.abl==nil) return
 local s=175+crd.abl
 if (blink and flr(time()*10)%2==1) s+=7

 spr(s,x-1,y)
end

function draw_star(x,y,sprite)
 if (not sprite) return
 spr(sprite,x,y)
end

function draw_flag(tea,x,y)
 local t=tea-1
 local row=flr(t/6)
 spr(20+row*16+t%6,x,y)
end

function draw_rarity(rar,x,y)
 if (rar==2) spr(4,x,y)
end

function draw_dif(dif,x,y)
 if dif==1 then
  print('easy',x,y,11)
 elseif dif==2 then
  print('fair',x,y,9)
 elseif dif==3 then
  print('hard',x,y,8)
 else 
  print('deus',x,y,12) 
 end
end

function read_crds()
 return t_map(t_range(r_byte()),function() return cards[r_byte()*256+r_byte()] end)
end

function read_crd()
 next_id=next_id and (next_id+1) or 1
 local att,def=r_byte2()
 local str_rar,abl=r_byte2()
 local str=flr(str_rar/2)
 local att_bon,def_bon=0,0
 if abl>3 then
	 att_bon,def_bon=r_byte2()
 end
 local c={
  id=next_id,
  tea=flr((next_id-1)/18)+1,
  att=att+4,
  def=def+4,
  str=str+1,
  abl=abl>0 and abl or nil,
  att_bon=att_bon,
  def_bon=def_bon,
  rar=str_rar-2*str+1
 }
 
 return c
end

function write_crd(crd)
 local b1=flr(crd.id/256)
 local b2=crd.id-b1*256
 w_byte(b1)
 w_byte(b2)
end

function last(tbl) return tbl[#tbl] end

function t_add(tbl,itm)
 local new_tbl=copy(tbl)
 add(new_tbl,itm)
 return new_tbl
end

function t_rem(tbl,i)
 new_tbl=copy(tbl)
 del(new_tbl,new_tbl[i])
 return new_tbl 
end

function t_fold(tbl,init,f)
 for itm in all(tbl) do
  init=f(init,itm)
 end
 return init 
end


function t_map(tbl,f)
 return t_fold(tbl,{},
  function(a,b)
   return t_add(a,f(b))
  end
 )  
end

function t_sum(tbl,f)
 return t_fold(tbl,0,
  function(a,b)
   return a+f(b)
  end
 )
end

function t_all(tbl,f)
 for itm in all(tbl) do
  if (not f(itm)) return false
 end
 return true
end

function t_contains(tbl,itm)
 return not t_all(tbl,function(x) return x!=itm end)
end

function t_take(tbl,n,start)
 return t_map(t_range(n,start),
  function(i) 
   return tbl[i]
  end)
end

function t_concat(tbl1,tbl2)
 return t_fold(tbl2,tbl1,t_add)
end

function t_move(tbl1,ind,tbl2)
 local itm=tbl1[ind]
 return t_rem(tbl1,ind),t_add(tbl2,itm)
end

function t_filter(tbl,f)
 return t_fold(tbl,{},
  function(a,b)
   return f(b) and t_add(a,b) or a 
  end
 )
end

function t_range(n,start)
 start=start or 1
 tbl={}
 for i=start,n+start-1 do add(tbl,i) end
 return tbl
end

function copy(t)
 local new_t={}
 copy_to(t,new_t)
 return new_t
end

function join(t1,t2)
 if (t1==nil) return t2
 if (t2==nil) return t1
 local new_t=copy(t1)
 copy_to(t2,new_t)
 return new_t
end

function copy_to(t1,t2)
 local meta=getmetatable(t1)
 for k,v in pairs(t1) do t2[k]=v end
 setmetatable(t2,meta)
 return t2
end

function r_byte2()
 local b=peek(r_adr)
 local n2=flr(b/16)
 r_adr+=1
 return b-n2*16,n2
end

function r_byte(b)
 r_adr+=1
 return peek(r_adr-1)
end

function w_byte(b)
 poke(w_adr,b)
 w_adr+=1
end

function rndi(maxi,mini)
 mini=mini or 1
 return flr(rnd(maxi-mini+1))+mini
end

function t_sort(tbl,scorings)
 local new_tbl=copy(tbl)
 for i=1,#new_tbl-1 do
  for j=i,1,-1 do
   local a=new_tbl[j+1]
   if compare(a,new_tbl[j],scorings) then
    new_tbl[j+1]=new_tbl[j]
    new_tbl[j]=a
   end
  end
 end
 return new_tbl
end

function shuffle(list)
 list_copy=copy(list)
 new_list={}
 for i=1,#list do
  item=list_copy[rndi(#list_copy)]
  del(list_copy,item)
  add(new_list,item)
 end
 return new_list
end

function compare(a,b,scorings)
 for score in all(scorings) do
  if (score(a)<score(b)) return true
  if (score(a)>score(b)) return false
 end
end

function sign(number)
 return max(-1,min(1,number))
end

function set_tp(c)
 palt(c_tp,false)
 palt(c,true)
 c_tp=c
end

function darken(x1,y1,x2,y2)
 for x=x1,x2 do
  for y=y1,y2 do
   pset(x,y,darker[darker[pget(x,y)]])
  end
 end
end

function darken2(x1,y1,x2,y2)
 for x=x1,x2 do
  for y=y1,y2 do
   pset(x,y,pget(x,y)>1 and 1 or 0)
  end
 end
end
-->8
--run
difs={1,1,1,2,2,2,2,2,2,3,3,3,3,3,3,4,4,4}

function init_run(restore)
 cur_tip=nil
 r_round=1
 r_tea=1
 r_ctys=gen_ctys()
 r_stt='cmp'
 r_col={}
 r_new_crds={}
 r_dif=nil
 if restore then
  load_run() 
 else
  poke(0x5e08,0)
 end
end

function load_run()
 r_adr=0x5e08
 local tea=r_byte()
 round=r_byte()
 if (tea==0 or round>num_rounds) return

 r_round=round
 r_tea=tea
 r_dif=difs[r_tea]
 r_robin=t_map(teams,r_byte)
 r_ctys=t_map(teams,load_cty)
 r_dck=read_crds()
 r_col=read_crds()
 r_new_crds=read_crds()
end

function load_cty(tea)
 return {
  tea=tea,
  rnk=r_byte(),
  rnk_prv=r_byte(),
  pnt=r_byte(),
  goa=r_byte(),
  goa_vs=r_byte()
 }
end

function save_run()
 w_adr=0x5e08
 w_byte(r_tea)
 w_byte(r_round)
 t_map(r_robin,w_byte)
 t_map(r_ctys,save_cty)
 save_crds(r_dck)
 save_crds(r_col)
 save_crds(r_new_crds)
end

function save_crds(crds)
 w_byte(#crds)
 t_map(crds,write_crd) 
end

function save_cty(cty)
 w_byte(cty.rnk)
 w_byte(cty.rnk_prv)
 w_byte(cty.pnt)
 w_byte(cty.goa)
 w_byte(cty.goa_vs)
end

function update_run()
 if r_stt=='cmp' then
  update_cmp()
  r={}
 elseif r_stt=='cmp_end' then
  if r_round==1 then
   r_dif=difs[r_tea]
   r_dck=gen_ply_dck() 
   r_robin=t_concat({r_tea},shuffle(t_rem(teams,r_tea)))
  end
 
  if not lvl_dcks then
   lvl_dcks=gen_lvl_dcks()
  end
  init_db()
  r_stt='db'
 elseif r_stt=='match' then
  if m.stt!='end' then
   update_match()
  else
   local new_ctys=copy(r_ctys)
   set_new_records(
    new_ctys[r_tea],
    new_ctys[last(r_robin)],
    ply.scr,
    cpu.scr
   )
   r_round+=1
   r_new_crds={}
   if r_round<=num_rounds then
    local num_picks={1,1,2,2,2,2}
    r_rw_type=sign(ply.scr-cpu.scr)
    r_rw_left=num_picks[r_round-1] or 3
    init_rw(r_rw_type,t_concat(r_col,r_dck),r_dck)
    r_stt='rw'
    new_r={}
   else
    r_stt='cmp'
    r_ctys=update_ranks(new_ctys)
   end   
  end
 elseif r_stt=='rw' then
  if rw.pick then
   local crd=rw.crds[rw.pick]
   r_col=t_add(r_col,crd)
   r_new_crds=t_add(r_new_crds,crd)
   r_rw_left-=1

   if r_rw_left==0 then
    r_stt='cmp'
    r_robin=t_concat({r_tea,last(r_robin)},t_take(r_robin,16,2))
    r_ctys=update_ranks(r_ctys)
    new_r={}
   else
    init_rw(r_rw_type,t_concat(r_col,r_dck))
    new_r={}
   end
  else
   update_rw()
  end
 elseif r_stt=='db' then
  if db.stt=='end' then
   local opp_tea=last(r_robin)
   r_dck=copy(db.dck)
   r_col=copy(db.col)
   r_ctys=update_ctys()
   init_match({play_for_me and get_cpu_crd or choose_crd,get_cpu_crd},{r_dck,lvl_dcks[opp_tea][r_round]},{r_tea,opp_tea},tutorial and r_round==1,animations)
   r_stt='match'
   new_r={}   
  else
   update_db()
  end
 end
 r=join(r,new_r)
 if (new_r and r_stt=='cmp' and r_round>1) save_run()
end

function get_match_points(match_result)
 return match_result>0 and {3,0} or (match_result==0 and {1,1} or {0,3})
end

function gen_ply_dck()
 for x=1,1000 do
  local dck={}
  strs=shuffle({4,3,3,3,2,2,2,2,1,1,1})
  for i=1,11 do
   tea=i<=5 and r_tea or nil
   not_tea=not tea and r_tea or nil
   local crd=gen_card({
    function(c) return c.str==strs[i] end,
    function(c) return c.rar==1 end,
    function(c) return not c.abl or c.abl==4 end,
    function(c) return not tea or c.tea==tea end,
    function(c) return not not_tea or c.tea!=not_tea end,
    function(c) return not t_contains(dck,c) end
   })
   if (crd!=nil) add(dck,crd)
  end
  if (#dck==11) return dck
 end
end

function gen_card(conditions)
 local crd=nil
 local i=1
 repeat 
  crd=cards[rndi(324)]
  i+=1
  if (i==500) return nil
 until t_all(conditions,function(f) return f(crd) end)
 return crd
end

function draw_run()
 if r_stt=='match' then
  cls()
  draw_match()
 elseif r_stt=='rw' then
  draw_rw()
 elseif r_stt=='cmp' then
  draw_cmp()
 elseif r_stt=='db' and db.stt!='end' then
  cls()
  draw_db()
 end
end

function init_rw(rw_type,exclude,dck) 
 local max_str={3,4}
 local crds=gen_rewards(rw_type+3,max_str[r_round-1] or 5,exclude,dck)
 
 rw_start=time()
 
 set_viewstate({stt='sel'})

 rw={
  crds=crds,
  rw_type=rw_type
 }
end

function gen_rewards(amount,max_str,exclude,dck) 
 for x=1,100 do
  local rewards={}
  local rar=rndi(4)==1 and 2 or 1 
  local tms={}
  for i=1,18 do 
   for count=1,1+
        max(0,min(4,
         #t_filter(dck,
          function (crd) 
           return crd.tea==i
          end
         )-1
        )
       ) do 
    add(tms,i) 
   end
  end
  
  for i=1,amount do
   local tea=rndi(#tms)
   local crd=gen_card({
    function(c) return c.tea==tms[tea] end,
    function(c) return c.str<=max_str end,
    function(c) return c.rar==rar end,
    function(c) return not t_contains(t_concat(exclude,rewards),c) end
   })
   if (crd!=nil) add(rewards,crd)
  end
  if (#rewards==amount) return rewards
 end
 return rewards
end

function update_rw()
 update_fireworks()
 
 local pick=choose_crd2(#rw.crds)

 rw=join(rw,{pick=pick})
end

function choose_crd2(max_sel)
 local select=min(v.sel_rw,max_sel)

 if (btnp(0) and select>1) select-=1
 if (btnp(1) and select<max_sel) select+=1
 if (btnp(4) or btnp(5)) return select
 
 set_viewstate({sel_rw=select})
end

function draw_rw()
 if rw.rw_type>=1 then
  draw_fireworks()
 else 
  draw_field(true,night)
 end
 
 print('recruit a new player',24,33,7)
 print('for your club',38,40)
 darken(0,119,127,127)
  
 local crds=rw.crds
 
 for i=1,#crds do
  local select=v.stt=='sel' and v.sel_rw==i and 3 or nil

  local cw=31
  draw_card(crds[i],(128-#crds*cw+(cw-29))/2+(i-1)*cw,50,select)

  if (select) draw_ability_hint(crds[i])
 end
end

points={}
nxt=0
rsd=rnd(9999)

function draw_fireworks() --by trasevol_dog
 for i=0,499 do
  circ(rnd(128),rnd(128),1,0)
 end
 
 for pt in all(points) do
  circfill(pt.x,pt.y,pt.r,pt.c)
 end
end

function update_fireworks()
 drk={4,9,3,1,1,8}
 drk[0]=2
 for pt in all(points) do
  pt.x+=pt.vx
  pt.y+=pt.vy
  
  if pt.rckt then
   if pt.y<96 then
    pt.vy+=0.1
    pt.r-=0.1
    if pt.r<=0 then
     for i=0,31 do
      local a=rnd(1)
      spd=1+rnd(2)
      add(points,{
       x=pt.x,
       y=pt.y,
       vx=spd*cos(a),
       vy=spd*sin(a),
       r=rndi(2),
       c=pt.c+flr(rnd(2))*(darker[pt.c]-pt.c)
      })
     end
     del(points,pt)
    end
   end
  else
   pt.r-=0.05
   pt.vy+=0.01
   if pt.r<=0 then
    del(points,pt)
   end
  end
 end
 
 nxt-=0.005
 if nxt<0 then
  nxt=0.1+rnd(0.4)
  add(points,{
   x=32+rnd(64),
   y=130,
   vy=-3-rnd(2),
   vx=rnd(2)-1,
   r=2,
   c=rndi(15,8),
   rckt=true
  })
 end
end
-->8
--competition
function gen_ctys()
 return t_map(teams,
  function(tea)
   return{
    tea=tea,
    pnt=0,
    rnk=9.5,
    goa=0,
    goa_vs=0
   }
  end
 )
end

function update_cmp()
 show_tip(8)
 if (r_round==2) show_tip(15)
 if (r_round>num_rounds) show_tip(16)

 if btnp(4) then
  r_stt='cmp_end'
 end
 if btnp(2) and not r_dif then
  r_tea=max(1,r_tea-1)
 end
 if btnp(3) and not r_dif then
  r_tea=min(18,r_tea+1)
 end 
end

function update_ctys()  
 local results=t_map(t_range(8,2),
  function(i)
   return cpu_vs_cpu(
    r_robin[i],
    r_robin[19-i]
   )
  end
 )
 m=nil
 local new_ctys=copy(r_ctys)
 for i=1,8 do
  set_new_records(
   new_ctys[r_robin[i+1]],
   new_ctys[r_robin[19-i-1]],
   results[i][1],
   results[i][2]
  )
 end
 
 return new_ctys
end

function set_new_records(cty1,cty2,goa,goa_vs)
 local pnts=get_match_points(sign(goa-goa_vs))
 cty1.pnt+=pnts[1]
 cty2.pnt+=pnts[2]
 cty1.goa+=goa
 cty1.goa_vs+=goa_vs
 cty2.goa+=goa_vs
 cty2.goa_vs+=goa
end

function update_ranks(ctys)
 local sorted_ctys=sort_cmp(ctys)
 
 for i=1,18 do
  local cty=sorted_ctys[i]
  cty.rnk_prv=cty.rnk
  cty.rnk=i
 end
 return ctys
end

function sort_cmp(ctys)
 return t_sort(ctys,{
  function(cty) return -cty.pnt end,
  function(cty) return cty.goa_vs-cty.goa end
 })
end

function draw_cmp()
 rectfill(0,0,127,127,1)
 local ctys=sort_cmp(r_ctys)
 for i=1,18 do
  local cty=ctys[i]
  local t=cty.tea
  local y=i*7-5
  if (t==r_tea) rectfill(0,y-2,127,y+5,2) 
  local nxt_opp=r_round>1 and r_round<=num_rounds and t==last(r_robin)
  if nxt_opp then
   print('vs',2,y,10)
  elseif r_dif!=nil then
   draw_stat(i,2,y,t==r_tea and 7 or 13)
  end
  draw_flag(t,11,y-1)
  print(city_names[t],19,y,nxt_opp and 10 or t_contains(t_take(r_robin,r_round-1,2),t) and 5 or 7)
  if r_dif==nil then
   draw_dif(difs[i],96,y)
  else
   draw_stat(cty.pnt,74,y,7)
   spr(8+sign(cty.rnk_prv-cty.rnk),82,y)
   draw_stat(cty.goa,94,y,12)
   print('-',103,y,7)
   draw_stat(cty.goa_vs,108,y,8)
   spr(4,116,y-1)
  end
 end
end
-->8
--match
function opp_of(p) return 3-p end

function set_match_globals()
 pls=g.pls
 cur=pls[g.cur]
 opp=pls[opp_of(g.cur)]
 ply=pls[1]
 cpu=pls[2]
 att=pls[g.att]
 def=pls[opp_of(g.att)]
end

function init_match(actors,dcks,teams,tutorial_match,animate_match)
 start_ply=tutorial_match and 1 or rndi(2)
 init_game(start_ply,actors,dcks,0,0,false,tutorial_match,animate_match)
 set_match_globals()
 m={
  animate_match=animate_match,
  actors=actors,
  dcks=dcks,
  scr={0,0},
  half=1,
  teams=teams
 }
 night=rndi(4)==1
end

function update_match()
 set_match_globals()
 
 update_game()
 if (g==nil) return
 set_match_globals()
  
 local new_half=m.half
 local new_stt='rdy'
 
 if (g.stt=='end') then
  if m.half%2==1 or (m.half==2 and ply.scr==cpu.scr) then
   new_half=m.half+1
   new_start_ply=m.half%2==0 and start_ply or opp_of(start_ply)
   init_game(new_start_ply,m.actors,m.dcks,ply.scr,cpu.scr,new_half>2,false,m.animate_match)
  else
   new_stt='end'
  end
 end
 
 m=join(m,{
  scr={ply.scr,cpu.scr},
  half=new_half,
  stt=new_stt
 })
end

function draw_match()
 draw_game()
 
 local trn=g.trn
 local half=m.half
 local halftrns={0,11,22,26}
 local clocks={0,5,10,15,20,24,28,32,36,40,44,45,50,55,60,65,69,73,77,81,85,89,0,5,10,14,15,20,25,29}
 local clock=clocks[halftrns[half]+trn]
 
 local half_txt=half==1 and '1st half' or (half==2 and '2nd half' or 'overtime')
 local score1=ply.scr
 local score2=cpu.scr
 local big_score1,big_score2
 
 if v.anim==ani_score then
  score1=g_nxt.pls[1].scr
  score2=g_nxt.pls[2].scr

  t=(time()-v.tim)*2
  if t<1 then
   big_score1=score1>ply.scr
   big_score2=score2>cpu.scr 
  else
   set_ani_done()
  end
 end

 print('-',13,2,7)
 draw_stat(score1,7,2,big_score1 and 11 or 7,big_score1,big_score1,-2,-2)
 draw_stat(score2,23,2,big_score2 and 8 or 7,big_score2,big_score2,-2,-2)
 draw_flag(m.teams[1],1,1,m.ply_tea)
 draw_flag(m.teams[2],17,1,m.cpu_tea)

 if clock then
  print((clock<10 and '0' or '')..clock..':00 ',
   34,2,12)
 end
 print(half_txt,57,2,7)
 
 print('round:'..r_round,r_round<10 and 100 or 96,2,9)
end
-->8
--game
ani_duel,ani_score=0,1

function get_tutorial_dck(d)
 local d=t_sort(d,{get_crd_val})
 local no_abl=t_filter(d,function(crd) return not crd.abl end)
 local abl=t_filter(d,function(crd) return crd.abl end)
 local no_abl2=shuffle(t_rem(no_abl,#no_abl))
 return t_concat(
  {last(no_abl)},
  t_concat(
   t_take(no_abl2,6),
   shuffle(t_concat(t_take(no_abl2,11,7),abl))
  )
 )
end

function init_game(start_ply,actors,dcks,ply_scr,opp_scr,add_tim,tutorial_game,animate_game)
 local l=1/r_dif-0.25
 ai_str=rnd(l)-l/2

 local size=add_tim and 4 or 11
 local ply_dck=t_take(shuffle(dcks[1]),size)
 local opp_dck=t_take(shuffle(dcks[2]),size)
 if tutorial_game and not tips[6].stt then
  ply_dck=get_tutorial_dck(dcks[1])
  opp_dck=get_tutorial_dck(dcks[2])
 end
 
 g=({
  animate_game=animate_game,
  actors=actors,
  pls={{
    hnd=t_take(ply_dck,4),
    dck=t_take(ply_dck,7,5),
    brd={},
    scr=ply_scr,
    att_chain=0  
   },
   {
    hnd=t_take(opp_dck,4),
    dck=t_take(opp_dck,7,5),    
    brd={},
    scr=opp_scr,
    att_chain=0,
    evl_att=ts_evl_att,
    evl_def=ts_evl_def
   }
  },
  trn=1,
  cur=start_ply,
  att=start_ply,
  stt='att'
 })
 
 set_viewstate({
  stt='rdy',
  select=1,
  sel_fgn=1,
  sel_rw=2
 })
end

function update_game() 
 if v.stt=='wait' then
  return
 elseif v.stt=='done' then
  set_viewstate({stt='rdy'})
  g=g_nxt
  return
 end
 
 if (cur_tip) return
 
 local get_action=g.actors[g.cur]
 local g_stt=g.stt

 if g_stt=='att' then
   new_g=play_att(get_action())
 elseif g_stt=='def' then
  new_g=play_def(get_action())
 elseif g_stt=='def_fgn' then
  new_g=play_def(get_action())
 elseif g_stt=='att_fgn' then
  new_g=pick_fgn_def(get_action())
 elseif g_stt=='duel' then
  new_g=process_duel()
  if g.animate_game then
   g_nxt=join(g,new_g)
   vs_duel()
   return
  end
 end
 
 g=join(g,new_g)
end

function choose_crd()
 local new_stt=g.stt=='att_fgn' and 'sel_fgn' or 'sel'

 if g.stt=='att' then
  show_tip(1)
  show_tip(7)
 else
  show_tip(2)
 end

 local select=min(v.select,#ply.hnd)
 local sel_fgn=v.sel_fgn
 local s=nil
 if new_stt=='sel' then
	 if (btnp(0) and select>1) select-=1
  if (btnp(1) and select<#ply.hnd) select+=1
  if btnp(4) or btnp(5) then
   s=select 
   new_stt='rdy'
  end
 elseif new_stt=='sel_fgn' then
  if (btnp(0) and sel_fgn>1) sel_fgn-=1
  if (btnp(1) and sel_fgn<#opp.brd) sel_fgn+=1
  if btnp(4) or btnp(5) then
   s=sel_fgn 
   new_stt='rdy'
  end
 end
 
 set_viewstate({
  stt=new_stt,
  select=select,
  sel_fgn=sel_fgn
 })
 
 return s
end

function get_cpu_crd()
 local g_stt=g.stt
 if g_stt=='att' then
  return get_best_crd(cur.hnd,cpu.evl_att)
 elseif g_stt=='def' or g_stt=='def_fgn'  then
  return get_best_crd(cur.hnd,cpu.evl_def)
 elseif g_stt=='att_fgn' then
  local new_opp=copy(opp)
  new_opp.hnd={opp.brd[1],opp.brd[2]}
  new_opp.brd={}
  pls=get_new_pls(new_opp,copy(cur))
  local res= 
   cpu.evl_def(g.cur,1) >
   cpu.evl_def(g.cur,2) 
    and 2 or 1
  pls=g.pls
  return res
 end 
end

function get_best_crd(crds,evl)
 local bst_ind=0
 local bst_val=-9999
 
 for i=1,#crds do
  local val=evl(g.cur,i)
  if (not val) return
  if val>bst_val then
   bst_val=val
   bst_ind=i
  end
 end
 
 return bst_ind
end

function play_att(hnd_ind)
 if (hnd_ind==nil) return 
 if (cur.hnd[hnd_ind]==nil) return
 local new_cur=copy(cur)
 new_cur.hnd,new_cur.brd=t_move(cur.hnd,hnd_ind,cur.brd)
 
 local new_stt=
  (cur.hnd[hnd_ind].abl==3 and
   #opp.hnd>=2) and
   'def_fgn' or 'def'
  
 return {
  pls=get_new_pls(new_cur,copy(opp)),
  cur=opp_of(g.cur),
  stt=new_stt,
  att=g.att
 }
end

function play_def(hnd_ind)
 if (hnd_ind==nil) return
 if (cur.hnd[hnd_ind]==nil) return

 local new_cur=copy(cur)
 new_cur.hnd,new_cur.brd=t_move(cur.hnd,hnd_ind,cur.brd)

 local new_stt='duel'
 local new_cur_ind=g.cur
 
 if g.stt=='def_fgn' then
  if #cur.brd==0 then
   new_stt='def_fgn'
  else
   new_stt='att_fgn'
   new_cur_ind=opp_of(g.cur)
  end
 end

 return {
  pls=get_new_pls(new_cur,copy(opp)),
  cur=new_cur_ind,
  stt=new_stt,
  att=g.att
 }
end

function pick_fgn_def(brd_ind)
 if (brd_ind==nil) return
 if (opp.brd[brd_ind]==nil) return

 local new_opp=copy(opp)
 new_opp.brd,new_opp.hnd=t_move(opp.brd,3-brd_ind,opp.hnd)

 return {
  pls=get_new_pls(copy(cur),new_opp),
  cur=opp_of(g.cur),
  stt='duel'
 }
end

function process_duel()
 local d_att=opp.brd[1]
 local d_def=cur.brd[1]
 
 local new_opp=copy(opp)
 local new_cur_ind=g.cur
 
 local res=duel(d_att,d_def)
 if res==0 then
  new_opp.scr+=1
  new_opp.att_chain=0
 elseif res==1 then
  new_cur_ind=opp_of(g.cur)
  new_opp.att_chain+=1
 elseif res==2 then
  new_cur_ind=g.cur
  new_opp.att_chain=0
 end

 local new_cur=copy(cur)
 new_cur.dck,new_cur.hnd=t_move(cur.dck,1,cur.hnd)
 new_cur.dis=cur.brd[1]
 new_cur.brd={}
 
 new_opp.dck,new_opp.hnd=t_move(opp.dck,1,opp.hnd)
 new_opp.dis=opp.brd[1]
 new_opp.brd={}
 
 local new_stt=#ply.hnd==0 and 'end' or 'att'
 
 return {
  trn=g.trn+1,
  pls=get_new_pls(new_cur,new_opp),
  cur=new_cur_ind,
  att=new_cur_ind,
  stt=new_stt
 }
end

function duel(d_att,d_def)
 local att_att,att_def=get_bon_stats(g.att,d_att)
 local def_att,def_def=get_bon_stats(opp_of(g.att),d_def)

 if d_def.abl==2 and def_att>=att_def then
  return 2
 end
 if att_att>def_def then
  return 0
 elseif d_def.abl!=1 and att_def>def_att then
  return 1
 end

 return 2
end

function get_new_pls(new_cur,new_opp)
 local new_pls={}
 new_pls[g.cur]=new_cur
 new_pls[opp_of(g.cur)]=new_opp
	return new_pls
end

function is_abl_active(ply_ind,crd)
 local abl=crd.abl
 if (abl==nil) return
 local p=pls[ply_ind]
 local opp=pls[opp_of(ply_ind)]
 return (
   abl==7 and 
 	  #p.hnd+#p.brd==1 and
 	  g.att==ply_ind
 	) or (
 	 abl==4 and 
 	  p.dis!=nil and 
 	  crd.tea==p.dis.tea
 	) or (
 	 abl==5 and 
 	  g.att==ply_ind and 
 	  (g.stt=='att' or p.brd[1].id==crd.id) and 
 	  p.att_chain>=1
 	) or (
 	 abl==6 and 
 	  p.scr<opp.scr
 	)
end

function get_bon_stats(ply_ind,crd)
 if ply_ind!=nil and is_abl_active(ply_ind,crd) then
  return crd.att+crd.att_bon,crd.def+crd.def_bon
 else
  return crd.att,crd.def
 end
end

function draw_game()
 draw_field(true,night)
 darken(0,0,127,9)
 darken(0,119,127,127)
 draw_cards()
 
 if g.stt=='def_fgn' and g.cur==1 then
  print('choose 2 defenders',28,78,7)
 end
 
 if (m.half==2) show_tip(12)  
 if (m.half==3) show_tip(13)  
end

function vs_duel()
 set_viewstate({
  anim=ani_duel,
  tim=time(),
  stt='wait'
 })
end

function draw_field(lights,night)
 night=night and r_round!=1
 
 rectfill(0,0,127,127,night and 1 or 3)
 line(2,63,125,63,night and 6 or 7)
 rectfill(62,62,64,64)
 circ(63,63,10)
 rect(40,-1,87,23)
 rect(40,128,87,104)
 rect(2,-1,125,128)
 
 local spr_lights=night and 64 or 70
 if lights then
  spr(spr_lights,-1,-1,5,5,false,false)
  spr(spr_lights,-1,89,5,5,false,true)
  spr(spr_lights,89,-1,5,5,true,false)
  spr(spr_lights,89,89,5,5,true,true)
 end
 
 if not night then
  rect(2,-1,125,128)
 end
end

function draw_cards() 
 anis=animate_duel() or {{},{}}
 
 local ply_brd=ply.brd
 local cpu_brd=cpu.brd

 for i=1,#cpu_brd do
  local selected=v.stt=='sel_fgn' and v.sel_fgn==i
  local x=4+((#cpu_brd==2 and 0 or 0.5)+i)*30
  draw_game_card(2,cpu_brd[i],x,13,selected and 1 or nil,anis[2])
  spr(4,60,44)
 end
 for i=1,#ply_brd do
  local x=4+((#ply_brd==2 and 0 or 0.5)+i)*30
  draw_game_card(1,ply_brd[i],x,52,nil,anis[1])
  spr(4,60,44)
 end

 for i=0,3 do
  local selected=v.stt=='sel' and v.select==i+1
  local select=selected and (g.att==2 and 1 or 2) or nil
  if (select and g.att==1) spr(4,15+i*30,78)
  draw_game_card(1,ply.hnd[i+1],4+i*30,86,select)
 end
end

function animate_duel()
 if (v.anim!=ani_duel) return
 local t=(time()-v.tim)*2
 
 local sliding=def.brd[1].abl==2
 local keeper=def.brd[1].abl==1
 local taken=g_nxt.att!=g.att
 local scored=g_nxt.pls[g.att].scr>att.scr 

 t_start=0
 anis={{},{}}
 if sliding then
  if t-t_start<1 then
   anis[opp_of(g.att)][5]=true
  end
  t_start+=1
 end
 if not sliding then
  t_start,anis=animate_stats(t,t_start,anis,g.att,opp_of(g.att),scored)
 end
 if keeper and not scored then
  if t-t_start>0 and t-t_start<2 then
   anis[opp_of(g.att)][5]=true
  end
  t_start+=2
 elseif sliding or not scored then
  if (t-t_start>=-0.1) show_tip(4)
  t_start,anis=animate_stats(t,t_start,anis,opp_of(g.att),g.att,taken)
 end
 if sliding and (not taken or scored) then
  t_start,anis=animate_stats(t,t_start,anis,g.att,opp_of(g.att),scored)
 end
 if t>=t_start then
  if scored then 
   show_tip(3)
   set_viewstate({anim=ani_score,tim=time()})
   return
  elseif taken and #ply.hnd>0 then
   show_tip(5)
  elseif #ply.hnd>0 then
   show_tip(6)
  end
  
  set_ani_done()
  return
 end 
 return anis
end

function animate_stats(t_now,t_start,anis,ind_att,ind_def,win_att) 
 local t=t_now-t_start-1
 if t>=0 then
  if t<3 then
   anis[ind_att][1]=true 
   if t>=1 then
    anis[ind_def][2]=true
   end
   if t>=2 then
    anis[ind_att][3]=win_att
    anis[ind_def][4]=not win_att
   end
  end
 end
 t_start+=4  
 return t_start,anis
end

function draw_game_card(ply_ind,crd,x,y,select,animations)
 if (crd==nil) return
 draw_card(crd,x,y,select,ply_ind,animations)
 if (select) draw_ability_hint(crd)
end

function draw_ability_hint(crd)
 if (crd.abl==nil) return
 draw_ability_icon(crd,1,120)
 print(abl_hints[crd.abl],9,121,pget(2,125))
 if (crd.abl==4) draw_flag(crd.tea,108,120)
end
-->8
--deck builder
function init_db() 
 select_x=1
 select_y={1,1,1}
 viewport_y={1,1}
 
 if r_round>num_rounds then
  db={
   stt='frm',
   dck=r_dck
  }
 else
  db={
   dck=t_sort(r_dck,{function(crd) return -get_crd_val(crd) end}),
   col=order_col(r_col,r_new_crds),
   str_cnt=0,
   stt='db',
   opp_tea=last(r_robin)
  }
 end
end

function update_db() 
 local new_col=db.col
 local new_dck=db.dck
 local db_stt=db.stt

 if db_stt=='frm' then
  show_tip(11)
 else
  show_tip(9)
  if r_round>1 then
   show_tip(10)
  
   local x,y=choose_crd3({flr((#new_col+1)/2),flr(#new_col/2),#new_dck})
   
   if x!=nil then
    if x==3 then
     new_dck,new_col=t_move(new_dck,y,new_col)
    else
     new_col,new_dck=t_move(new_col,y*2-2+x,new_dck)   
    end
    new_dck=t_sort(new_dck,{function(crd) return -get_crd_val(crd) end})
    new_col=order_col(new_col,r_new_crds)
   end  
  end
 end
 
 local legal,str_cnt=legal_dck(new_dck)
  
 local new_stt=db_stt
 if btnp(4) then
  if legal then 
   if db_stt=='db' and r_round>1 then
    new_stt='frm'

    w_adr=24182
    save_crds(new_dck)
    save_crds(new_col)
   elseif r_round<=num_rounds then
    new_stt='end'
   end
  else
   show_tip(14,true)
  end
 elseif btnp(5) and db_stt=='frm' then
  if r_round<=num_rounds then
   new_stt='db'
  else
   r_stt='cmp'
  end
 end
 
 db=join(db,{
  dck=new_dck,
  col=new_col,
  str_cnt=str_cnt,
  stt=new_stt
 })
end

function legal_dck(dck)
 local str_cnt=t_sum(dck,
  function(crd)
   return crd.str
  end
 )
 
 local kpr_cnt=t_sum(dck,
  function(crd)
   return crd.abl==1 and 1 or 0
  end
 )
  
 return #dck==11 and 
         str_cnt<=30 and 
         kpr_cnt<=1,
        str_cnt
end

function order_col(col,new)
 return t_sort(col,{
  function (crd) return t_contains(new,crd) and 0 or 1 end,
  function (crd) return crd.tea==r_tea and 0 or 1 end,
  function (crd) return -crd.rar end,
  function (crd) return -crd.str end
 })
end

function choose_crd3(max_sel_y)
 while max_sel_y[select_x]==0 do 
  select_x=select_x==1 and 3 or select_x-1
 end

 local dx=max_sel_y[2]==0 and 2 or 1
 local sy=max(1,min(select_y[select_x],max_sel_y[select_x]))
 local vx=max(1,select_x-1)

 if (btnp(5)) return select_x,sy

 if btnp(0) and max_sel_y[1]>0  then
  if select_x==3 then
   select_x-=dx
  elseif select_x==2 then
   select_x=1  
  end
  return
 end
 if btnp(1) and select_x<3 and max_sel_y[select_x+dx]>0 then
  select_x+=dx
  return
 end
 if btnp(2) and sy>1 then
  sy-=1
  if (viewport_y[vx]>sy) viewport_y[vx]-=1
 elseif btnp(3) and sy<max_sel_y[select_x] then
  sy+=1
  if (viewport_y[vx]<sy-(vx==1 and 2 or 10)) viewport_y[vx]+=1
 end
 if select_x<3 then
  select_y[1]=sy 
  select_y[2]=sy
 else
  select_y[3]=sy
 end
end

function draw_db()
 draw_field(false)
 
 if db.stt=='frm' then
  draw_formation()
 else
  draw_dck()
  draw_col()
  if (r_round>1) then
   spr(154,63,30,2,1)
   spr(59,66,39)
  end
 end
 draw_db_info()
end

function draw_db_info()
 darken(0,119,127,127)
 if db.stt=='db' then
  local count=db.str_cnt
  draw_stat(count, 5,121,15)
  print(' out of 30',13,121,15)
  draw_star(54,121,5)
 else
  spr(59,5,120)
  print('back',14,121,15)
 end
 
 if r_round>num_rounds then
  local rnk=r_ctys[r_tea].rnk
  if (rnk<=3) spr(184+rnk,95,120)
  local s=rnk==1 and 'st' or rnk==2 and 'nd' or rnk==3 and 'rd' or 'th'
  if r_dif>2 then
   draw_dif(r_dif,57,121)
  end
  print(rnk..s,100+(rnk<=9 and 4 or 0),121,rnk==1 and 9 or rnk==2 and 6 or rnk==3 and 4 or 7)
  draw_flag(r_tea,117,120)
 else
  spr(58,75,120)
  print('play vs:',84,121,15)
  draw_flag(db.opp_tea,117,120)
 end
end

function draw_formation()
 local d=db.dck
 
 local atts={d[2],d[1],d[3]}
 draw_row(atts,1)  
 local mids={d[4],d[5],d[6]}
 draw_row(mids,2)  
 local defs={d[9],d[7],d[8],d[10]}
 draw_row(defs,3)  
 draw_row({d[11]},4)  
end

function draw_row(crds,row_num)
 local y={2,33,65,95}

 local crd_w={42,32,30,36}
 
 for i=1,#crds do
  dy=(i==1 or i==4) and row_num==3 and 10 or 0
  dy=(i==1 or i==3) and row_num==2 and -0 or dy
  dy=(i==1 or i==3) and row_num==1 and -0 or dy
  local cw=crd_w[row_num]
  draw_card(crds[i],(128-#crds*cw+(cw-28))/2+(i-1)*cw,y[row_num]+dy)
 end
end

function draw_dck()
 if (#db.dck>0) line(78,4,125,4,0)
 for i=1,#db.dck do
  local y=(i-viewport_y[2]+1)*10-6
 	draw_small_card(db.dck[i],78,y,select_x==3 and select_y[select_x]==i and 1 or nil)
 end
end

function draw_col()
 for y=0,flr(#db.col/2) do
  for x=1,0,-1 do
   local crd_x=2+x*30
   local crd_y=4+(y-viewport_y[1]+1)*30
   local crd=db.col[y*2+x+1]
   draw_card(crd,crd_x,crd_y,x==select_x-1 and y==select_y[select_x]-1 and 1 or nil,nil,nil,t_contains(r_new_crds,crd))
  end
 end
end

function draw_small_card(crd,x,y,select)
 spr(10,x,y,6,2)
 
 print(crd.str,x+3,y+3,crd.rar==2 and 9 or 6)
 if (crd.rar==2) spr(42+crd.str,x+3,y+3)
 draw_star(x+7,y+3,crd.rar==2 and 5 or 6)
 local dx=(crd.att>9) and 2 or 4
 print(crd.att,12+x+dx,y+3,8)
 local dx=(crd.def>9) and 11 or 13
 print(crd.def,12+x+dx,y+3,12)
 draw_ability_icon(crd,x+32,y+2)
 draw_flag(crd.tea,x+40,y+3)
 draw_select(x,y,x+47,y+10,select)
end

function get_crd_val(crd)
 if (crd.abl==1) return 0

 local att=crd.att+0.5*crd.att_bon
 local def=crd.def+0.5*crd.def_bon
 if (crd.abl==2) def+=att
  
 return att/def
end

-->8
--ai
function ts_evl_att(ply_ind,hnd_ind)
 local crd=pls[ply_ind].hnd[hnd_ind]
 local att,def=get_bon_stats(ply_ind,crd)
 return ai_str+4.6+(att^1.5+def)^0.85*0.25-crd.str+(crd.abl==3 and 2 or 0)
end

function ts_evl_def(ply_ind,hnd_ind)
 if animations and g.actors[1]==choose_crd then
  for j=1,4 do
   flip()
  end
 end
 
 local att=pls[opp_of(ply_ind)].brd[1]
 local def=pls[ply_ind].hnd[hnd_ind]
 local res=duel(att,def)
 
 return ai_str +
  (res==1 
   and 3.2 or
    res==2
     and 4.3 or 0)-def.str
end

function cpu_vs_cpu(tea1,tea2)
 init_match(
  {get_cpu_crd,get_cpu_crd},
  {lvl_dcks[tea1][r_round],lvl_dcks[tea2][r_round]},
  {tea1,tea2}
 )
 g.animate_game=false
 
 while m.stt!='end' do
  update_match()
 end
 return {ply.scr,cpu.scr}
end

function gen_lvl_dcks()
 return t_map(teams,
  function(tea)
   local final_dck=t_sort(
    shuffle(dcks[tea]),{
     function(crd)
      return ((
       crd.tea==tea and 
       crd.rar==1 and 
       (not crd.abl or 
        crd.abl==4
       )
      ) and 0 or 2) + 
      (crd.abl and 1 or 0)
      + crd.str/5
      + rnd(0.5)
     end
    })
   local base_dck=t_take(final_dck,5)
   local power_cards=t_sort(
    t_take(final_dck,6,6),
    {function(crd) return -crd.str end}
   )
   local ramps={5,4,3.34,2.5}

   return t_map(teams,
    function(lvl) 
     while true do  
      replacements={}
      for i=1,6 do    
       add(
        replacements,
        replace_card(
         power_cards[i],
         max(0,get_downgrade(i,lvl)),
         replacements,
         lvl>=3
        )
       )
      end
    
      local num_power_cards=flr(lvl/ramps[r_dif])
      local lvl_dck=t_concat(
       base_dck,t_concat(
        t_take(power_cards,num_power_cards),
        t_take(replacements,6,num_power_cards+1)
      )) 
      if (legal_dck(lvl_dck)) return lvl_dck
     end
    end
   )
  end
 )
end

function get_downgrade(i,lvl)
 local d=r_dif==4 and 1 or 0
 local f=r_dif>1 and 1 or 0
 if i==1 then
  return 4-f-lvl
 end
 if i==2 then
  return min(3-d,4-f+3-d-lvl)
 end
 if i==3 then
  return min(2,5-f+3-d+2-lvl-r_dif)
 end
 if lvl<=17 and i==5 and r_dif<=2 then
  return 1
 end
 if lvl<=17 and i==4 and r_dif==1 then
  return 1
 end
 return 0
end

function replace_card(crd,downgrade,exclude,abl)
 return gen_card({
  function(c) return c.str==max(1,min(crd.str-downgrade,4)) end,
  function(c) return c.rar==1 end,
  function(c) return c.tea!=crd.tea end,
  function(c) return c.abl!=4 and (not c.abl or abl) end,
  function(c) return not t_contains(exclude,c) end
 })
end
__gfx__
000000000000000000000000000002222077022222f2222222d22222222222222292922222222222222222222222222222222222222222222222222222222222
0f66dd5111111111111555ddd66f022206700722a7af9222676d52222888882229929922222b22220f66dd511111111111111111111111111111111155dd66f0
06000000000000000000000000000222600770222af9222226d52222228882229992999222bbb222060000000000000000000000000000000000000111111110
0d00000000000000000000000000022206067022292422222d25222222282222299299222bbbbb220d0000000000000000000000000000000000001111111110
05000000000000000000000000000222566006222222222222222222222222222292922222222222050000000000000000000000000000000000011111111110
01000000000000000000000000000222250062222222222222222222222222222222222222222222010000000000000000000000000000000000111111111110
01000000000000000000000000000222222222222222222222222222222222222222222222222222010000000000000000000000000000000001111111111110
01000000000000000000000000000222222222222222222222222222222222222222222222222222010000000000000000000000000000000111111111111110
0100000000000000000000000000022288888822cc778822777777228888882233aa332277777722010000000000000000000000000000011111111111111110
0100000000000000000000000000022299999922cc7788227d77d722888888223aaaa32277777722010000000000000000000000000001111111111111111110
0100000000000000000000000000022291a99922cc7788227788772277777722a65daa2211111122000000000000000000000000000000000000000000000000
0100000000000000000000000000022298499922cc7788227711772277777722aa116a2211111122222222222222222222222222222222222222222222222222
0100000000000000000000000111022299999922cc7788227d77d722cccccc223aaaa32288888822222222222222222222222222222222222222222222222222
0100000000000000000000011111022288888822cc77882277777722cccccc2233aa332288888822222222222222222222222222222222222222222222222222
01000000000000000000001111110222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
01000000000000000000011111110222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
010000000000000000001111111102223388882277777722cccccc22cccccc227777772271777722222222227a2222227af222227aa2222272a222227af22222
010000000000000000011111111102223388882277777722cccccc22cccccc2277ee772271777722251cba982f22222222f2222222f22222a2f22222a2222222
011110000000000000111111111102223a988822777777221111112277ff77227e88e7221111112221cba9822f222222af9222222f922222ff922222ff922222
011111000000000001111111111102223a988822888888221111112277ff77227e88e722717777222cba982229222222f2222222229222222292222222922222
01111110000000011111111111110222338888228888882277777722cccccc2277ee7722717777222ba98222f992222299922222f992222222922222f9922222
01111111000001111111111100010222338888228888882277777722cccccc2277777722717777222a9822222222222222222222222222222222222222222222
01111111111111111111110000000222222222222222222222222222222222222222222222222222298222222222222222222222222222222222222222222222
01111111111111111111100000000222222222222222222222222222222222222222222222222222282222222222222222222222222222222222222222222222
01111111111111111111000000000222cccccc22cccccc22c9cccc223377882200000022778777222bbbb3222eeee82227777622277776222777762222222222
01100001111111111110000000000222cccccc2277777722c9cccc22337788220000002277877722b3000332e808088276666662766606627606666222222222
05000000111111111100000000000222cccccc228888882299999922337788228888882288888822b33303d0e80808d0766066d0766006d0760066d022222222
0d0000000001111100000000000002229999992288888822c9cccc22337788228888882277877722b33033d0e88088d0760006d0760006d0760006d022222222
000000000000000000000000000002229999992277777722c9cccc22337788229999992277877722b30333d0e80808d0700000d0766006d0760066d022222222
2222222222222222222222222222222299999922cccccc22c9cccc22337788229999992277877722330003d0880808d0666666d0666606d0660666d022222222
2222222222222222222222222222222222222222222222222222222222222222222222222222222223dddd0028dddd0026dddd0026dddd0026dddd0022222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222220000022200000222000002220000022200000222222222
77777777776767676767676666666666666ddd2d2222222277777777777777b7b7b7bbbbbbbbbb3b3b3b3b222222222222222222222222222222222222222222
77777777777777777676767676767666666dddd22222222277777777777777777b7b7b7bbbbbbbbbb3b3b3b22222222222222222222222222222222222222222
77777777776767676767676666666666666ddd2d22222222777777777777b7b7b7b7bbbbbbbbbb3b3b3b3b222222222222222222222222222222222222222222
77777777777777777676767676767666666dddd222222222777777777777777b7b7b7b7bbbbbbbbbb3b3b3b22222222222222222222222222222222222222222
77777777776767676767676666666666666d2d2d22222222777777777777b7b7b7b7bbbbbbbbbb3b3b3b3b222222222222222222222222222222222222222222
77777777777777767676767676766666666dddd222222222777777777777777b7b7b7bbbbbbbbbbbb3b3b3b22222222222222222222222222222222222222222
7777777767676767676767666666666666dd2d2d222222227777777777b7b7b7b7bbbbbbbbbbbb3b3b3b3b222222222222222222222222222222222222222222
7777777777777776767676767676666666ddd2d2222222227777777777777b7b7b7b7bbbbbbbbbbbb3b3b2b22222222222222222222222222222222222222222
7777676767676767676766666666666666dd2d2d222222227777777777b7b7b7b7bbbbbbbbbb3b3b3b3b22222222222222222222222222222222222222222222
7777777777777676767676767676666666ddd2d2222222227777777777777b7b7b7b7bbbbbbbbbb3b3b3b2b22222222222222222222222222222222222222222
676767676767676767676666666666666ddd2d2222222222777777b7b7b7b7b7bbbbbbbbbbbb3b3b3b3b22222222222222222222222222222222222222222222
777777777776767676767676766666666dddd2d22222222277777777777b7b7b7b7bbbbbbbbbbbb3b3b3b2b22222222222222222222222222222222222222222
676767676767676767666666666666666d2d2d2222222222b7b7b7b7b7b7b7bbbbbbbbbbbb3b3b3b3b3b22222222222222222222222222222222222222222222
77777777767676767676767676666666ddd2d2d2222222227777777b7b7b7b7b7bbbbbbbbbbbbbb3b3b2b2222222222222222222222222222222222222222222
67676767676767676666666666666666dd2d222222222222b7b7b7b7b7b7bbbbbbbbbbbbbb3b3b3b3b2222222222222222222222222222222222222222222222
7676767676767676767676766666666dddd2d222222222227b7b7b7b7b7b7b7b7bbbbbbbbbbbb3b3b3b2b2222222222222222222222222222222222222222222
6767676767676766666666666666666d2d2d222222222222b7b7b7b7b7bbbbbbbbbbbbbb3b3b3b3b3b2222222222222222222222222222222222222222222222
767676767676767676767666666666ddddd2d222222222227b7b7b7b7b7b7bbbbbbbbbbbbbbbb3b3b2b222222222222222222222222222222222222222222222
67676767676766666666666666666ddd2d22222222222222b7b7b7bbbbbbbbbbbbbbbb3b3b3b3b3b222222222222222222222222222222222222222222222222
76767676767676767676766666666dddd2d22222222222227b7b7b7b7b7bbbbbbbbbbbbbbbb3b3b3b2b222222222222222222222222222222222222222222222
6767676766666666666666666666dd2d2d22222222222222bbbbbbbbbbbbbbbbbbbb3b3b3b3b3b3b222222222222222222222222222222222222222222222222
767676767676767676666666666dddd2d2d22222222222227b7b7bbbbbbbbbbbbbbbbbbbb3b3b3b2b22222222222222222222222222222222222222222222222
66666666666666666666666666dd2d2d2222222222222222bbbbbbbbbbbbbbbbbb3b3b3b3b3b3b22222222222222222222222222222222222222222222222222
76767676767676766666666666ddddd2d222222222222222bbbbbbbbbbbbbbbbbbbbbbb3b3b3b2b2b22222222222222222222222222222222222222222222222
6666666666666666666666666ddd2d222222222222222222bbbbbbbbbbbbbbbb3b3b3b3b3b3b2222222222222222222222222222222222222222222222222222
76767676767666666666666dddddd2d22222222222222222bbbbbbbbbbbbbbbbbbbbb3b3b3b2b2b2222222222222222222222222222222222222222222222222
6666666666666666666666dddd2d22222222222222222222bbbbbbbbbbbb3b3b3b3b3b3b3b222222222222222222222222222222222222222222222222222222
767676666666666666666dddddd2d2222222222222222222bbbbbbbbbbbbbbbbb3b3b3b3b2b2b222222222222222222222222222222222222222222222222222
6666666666666666666ddd2d2d22222222222222222222223b3b3b3b3b3b3b3b3b3b3b3b22222222222222222222222222222222222222222222222222222222
666666666666666666ddddd2d2d222222222222222222222bbbbbbbbbbbbb3b3b3b3b3b2b2b22222222222222222222222222222222222222222222222222222
6666666666666666dddd2d2d2222222222222222222222223b3b3b3b3b3b3b3b3b3b3b2222222222222222222222222222222222222222222222222222222222
66666666666666ddddddd2d2d22222222222222222222222bbbbbbb3b3b3b3b3b3b2b2b2b2222222222222222222222222222222222222222222222222222222
66666666666ddddd2d2d2d222222222222222222222222223b3b3b3b3b3b3b3b3b22222222222222222222222222222222222222222222222222222222222222
6666666dddddddddd2d2d2d2222222222222222222222222b3b3b3b3b3b3b3b2b2b2b22222222222222222222222222222222222222222222222222222222222
dddddddddd2d2d2d2d2222222222222222222222222222223b3b3b3b3b3b3b222222222222222222222222222222222222222222222222222222222222222222
ddddddddddddd2d2d2d22222222222222222222222222222b3b3b3b3b2b2b2b2b2b2222222222222222222222222222222222222222222222222222222222222
2d2d2d2d2d2d2222222222222222222222222222222222223b3b3b3b222222222222222222222222222222222222222222222222222222222222222222222222
d2d2d2d2d2d2d2d222222222222222222222222222222222b2b2b2b2b2b2b2b22222222222222222222222222222222222222222222222222222222222222222
2d2d222222222222222222222222222222222222222222222b222222222222222222222222222222222222222222222222222222222222222222222222222222
d2d2d2d22222222222222222222222222222222222222222b2b2b2b2222222222222222222222222222222222222222222222222222222222222222222222222
77777722777722227777772277777722772277227777772277222222777777227777772277777722222f22222f22222222222222222222222222222222222222
7777772277772222777777227777772277227722777777227722222277777722777777227777772222f922222992222222222222222222222222222222222222
772277222277222222227722222277227722772277222222772222222222772277227722772277222f9999999999222222222222222222222222222222222222
77227722227722222222772222227722772277227722222277222222222277227722772277227722f99999999999922222222222222222222222222222222222
77227722227722227777772277777722777777227777772277777722222277227777772277777722299999999999002222222222222222222222222222222222
77227722227722227777772277777722777777227777772277777722222277227777772277777722229900000990022222222222222222222222222222222222
77227722227722227722222222227722222277222222772277227722222277227722772222227722222902222900222222222222222222222222222222222222
77227722227722227722222222227722222277222222772277227722222277227722772222227722222202222202222222222222222222222222222222222222
77777722777777227777772277777722222277227777772277777722222277227777772222227722222222222222222222222222222222222222222222222222
77777722777777227777772277777722222277227777772277777722222277227777772222227722222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2ddddddd2ccccccc244444442999999928888888233333332eeeeeee2666666626666666a92229426d2226d26d222d5222222222222222222222222222222222
2dd7d7dd2ccc77cc244777442997779928878788233377332ee7eeee266767662666776692a99242627662d2d26dd25222222222222222222222222222222222
2dd7d7dd2cc7cccc244744442999799928878788233733332ee7eeee266767662667666692a99242627662d2d26dd25222222222222222222222222222222222
2dd77ddd2cc777cc244774442999799928877788233733332ee7eeee26677666266777662979942226766d222d6dd52222222222222222222222222222222222
2dd7d7dd2cccc7cc244744442999799928878788233733332ee7eeee2667676626666766229742222267d22222d6522222222222222222222222222222222222
2dd7d7dd2cc77ccc244744442999799928878788233377332ee777ee26676766266776662229222222262222222d222222222222222222222222222222222222
2ddddddd2ccccccc244444442999999928888888233333332eeeeeee2666666626666666229942222266d22222dd522222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
4304111500060151107124116520562027204535409144118540394066531a5098641158724c70b7905000430411150044107120652056241127202831854068
44110a4192541138524b641189706a70937343003400150051141165241156202720172411613620914077403944118654112a51a4605b708877509676204300
34041115005110652054252017241108213730914077441158403940865411815530a4608974114a724300340025107120652411562027201821463530854411
39400a4047522a516a60a6705b741179924300340411240530251071206520562411172052354077403944110a41925086506a60a57086737d94115004114300
26117124116520562056202720353285401a41925078504954113c60b1709777208b976043003400511411712065241156202720182146361177400a40825622
515259506a60a674112c716c9660500034041106107120652062252056202724110830774039408257407655301a54118765307a704c701e9150004300061071
206520532540562027241165341177441168400a41865049504b641186754063726e9043001500311540712065206520562411272028318345207744110a4086
5059506a604c74117873b29540500015004414117124116520562027200931914077400a407353485603a46099707976043c718c941143003305302510712065
241156202720643730854411764520684093502a503c60a477306b707776442e915000340026117120652056241127206236308544117740684093505855402a
503c608875307a74119a9622500015003213712056204425402724110830914068403940755540675730986411b1703c71c49098933205303400061411652065
20562027201724117234118544116645300a40925049501c61a5708970c1973042052015004410652056203625402724117330854068400a4093506755405954
1198606975502c71a9953043041115000610712062252056241127205333854077400a4073555067563059501c6199706b7411a4930000000000000000000000
b00080002100300010002000c700a000f0007000c00011b000e10091102400f10002002700c100810022004100d1b0005300f200d210c30052001300a2000300
2200920023b00074004400e300d300c3008400830053001400730064b0000500d40095001500250085007500a400b400c400a5b000660086000600f5001600b5
0046000d102400b61004b000570037001700970067000700c700d600a7007700e7b0008800d800b80018005800ab00f7000800f800e80009b0001a0059007900
d90049003900b900990089000a002ab0004b007a00aa009a002b005a00ba10d2007700ca00dab000db004c008b00bb00ab000d1024009b00fb00a90097b0009c
00dc007c004d008c003300cc005d10e100ec008db0003e00ed002e00dd004e00bd001e009d005e008e00aeb000cf004f00fe00be000f005f00de10d2001100ee
00bfb010d000df106000ef103000ff101010a010b0107010c0b010b1108110e110611001101110f11021003b104110d1b0102310b21072102210521032008010
a2100310e21013b010141004108310a3104310e31093102410c31063103400000000000000000000000000000000000000000000000000000000000000000000
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
000100002800016000170002e7502210025100261002410023100191001e10021000231002a000191001a55029100251002210015100241002a1002a550341002010024100241000000034750000000000000000
0110002000063000003e4001860018615186003e4000000000000000000006318600186153e4003e2003e20000063000003e4001860018615186003e4000000000000322000006318600186153e4003e40000000
011000002174524705217052170521745007052170521745007052170521745007052170521745007052174520700207451c74500705007050070500705007050070500705007050070500705007050070500000
011000001a7451c74500000000001c74500000000001c74500000000001e74500000000001e745000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000287450000000000000002b74500000000002874500000000002b745000000000028745000000000026745000002574521745000000000000000000000000000000000000000000000000000000000000
011000001a7451c74500000000001c74500000000001c74500000000001e74500000000001a745000000000017745000000000010745000000000000000000000000000000000000000000000000000000000000
011000001c7450000000000000001f74500000000001c74500000000001f74500000000001c74500000000001a745000001974515745000000000000000000000000000000000000000000000000000000000000
011000001a7451c74500000000001c74500000000001c74500000000001e74500000000001a745000000000017745000000000010745000000000000000000000000000000000000000000000000000000000000
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
01 01 42 43 02
01 01 42 43 03
01 01 42 43 04
00 01 42 43 05
00 01 42 43 06
01 01 42 43 03
01 01 42 43 04
00 01 42 43 05
00 01 42 43 06
01 01 42 43 03
01 01 42 43 04
00 01 42 43 05
01 01 42 43 06
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
