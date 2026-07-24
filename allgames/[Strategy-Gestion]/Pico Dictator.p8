pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico-8 dictator
-- by toddl

--  pico-8 dictator
--
--  1.00: 2019-07-11 inital release
--  1.01: 2019-12-08 bug fix: crashing when bankrupt
--
--  demake of the zx spectrum game   
--
--  dictator
--
--  http://www.worldofspectrum.org/infoseekid.cgi?id=0001388
-- 
--  devised and written by        
--  don priestley                 
--  https://en.wikipedia.org/wiki/don_priestley
--
--  copyright  dk'tronics  1983    
--  https://en.wikipedia.org/wiki/dk'tronics
--
--  rewritten in c by #kstn (2015)
--  https://github.com/kastian/dictator/
-- 
--  converted to lowres coder 
--  by toddl (2016)
--
--  converted to pico-8
--  by toddl (2019)

cartdata("toddl_dictator")
chars=" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
s2c={}
c2s={}
for i=1,95 do
  c=i+31
  s=sub(chars,i,i)
  c2s[c]=s
  s2c[s]=c
end
function chr_s(i)
  return c2s[i]
end
function asc(s,i)
  return s2c[sub(s,i or 1,i or 1)]
end
function mid_s(s,pos,length)
  return sub(s,pos,pos+length-1)
end
function wait(time)
  local t=flr(time * 26)
  for i=1,max(t,1) do
    flip()
  end
end
function waittap(time)
  local t=flr(time * 26)
  for i=1,max(t,1) do
    flip()
    if btnp(4) or btnp(5) then
      break
    end
  end
end
function dim(table,d1,d2,d3)
  if d2==nil then
    dim1(table,0,d1)
  elseif d3==nil then
    dim2(table,0,d1,d2)
  else
    dim3(table,0,d1,d2,d3)
  end
end
function dim_s(table,d1,d2,d3)
  if d2==nil then
    dim1(table,"",d1)
  elseif d3==nil then
    dim2(table,"",d1,d2)
  else
    dim3(table,"",d1,d2,d3)
  end
end
function dim1(table,def,d1)
  local i
  for i=0,d1 do
    table[i]=def
  end
end
function dim2(table,def,d1,d2)
  local i
  local j
  for i=0,d1 do
    table[i]={}
    for j=0,d2 do
      table[i][j]=def
    end
  end
end
function dim3(table,def,d1,d2,d3)
  local i
  local j
  local k
  for i=0,d1 do
    table[i]={}
    for j=0,d2 do
      table[i][j]={}
      for k=0,d3 do
        table[i][j][k]=def
      end
    end
  end
end
function fr(v)
  return flr(rnd(1)*v)
end
function make_note(pitch,instr,vol,effect)
  return {pitch+64*(instr%4),16*effect+2*vol+flr(instr/4)} -- flr may be redundant when this is poke'd into memory
end
function set_note(sfx,time,note)
  local addr=0x3200+68*sfx+2*time
  poke(addr,note[1])
  poke(addr+1,note[2])
end
function set_speed(sfx,speed)
  poke(0x3200+68*sfx+65,speed)
end
function sound(voice,pitch,duration,instr)
  set_speed(63-voice,5)
  for i=0,31 do
    local n=make_note(pitch,instr,7,0)
    set_note(63-voice,i,n)
  end
  sfx(63-voice,0,0,duration)
end
function soundoff(voice)
  sfx(-1,voice)
end
padleft=-1
padtop=-1
history=dget(0)
function showintro()
  sound(0,63,3,0)
  cls(0)
  padtop=-1
  padleft=0
  p(1,1,"dictator",7,0)
  pn(3,"demake of old zx spectrum game")
  pn(6,"devised and written by")
  pn(8,"don priestley")
  pn(10,"copyright             1983",7,0)
  a_s="dktronics"
  padleft=-1
  for a=1,#a_s do
    p_x=12+a
    if a==1 or a==3 then
      p_bg=7
    elseif a==2 then
      p_bg=10
    elseif a==4 or a==6 or a==8 then
      p_bg=3
    else
      p_bg=12
    end
    p(11+a,10,mid_s(a_s,a,1),0,p_bg)
    padleft=0
  end
  p(1,13,"rewritten in c by #kstn (2015)",5,0)
  pn(15,"converted to lowres coder")
  pn(16,"by toddl (2016)")
  pn(17,"converted to pico-8")
  pn(18,"by toddl (2019)")
  wait4button()
end
function showtitle()
  cls(0)
  padtop=-1
  padleft=0
  p_fg=12
  p_bg=0
  skipit=false
  for p_y=0,21 do
    for x=0,3 do
      p_x=x*8
      p(p_x,p_y,"dictator",p_fg,p_bg)
      p_bg,p_fg=p_fg,p_bg
      if (x==1 or x==3) and not skipit then
        soundoff(0)
        sound(0,47-(p_y*2+flr(x/2))+fr(10),32,2)
        if btnp(4) or btnp(5) then
          skipit=true
        end
        waittap(0.1)
      end
      if btnp(4) or btnp(5) then
        skipit=true
      end
    end
  end
  flip()
  if not skipit then
    for a=1,50 do
      soundoff(0)
      sound(0,11+a,32,2)
      flip()
    end
    soundoff(0)
    wait(0.1)
  else
    soundoff(0)
    flip()
  end
  for y=42,107,3 do
    if y%6==0 then
      color(8)
    else
      color(3)
    end
    rectfill(16,y,111,y+2)
  end
  rectfill(32,42,95,107,1)
  pc(9," ritimban ",0,3)
  pc(15," republic ")
  pc(11,"******",10,1)
  pc(12,"**")
  pc(13,"******")
  sfx(0,0,0,18)
  while stat(16)>=0 do
    flip()
  end
  pc(2," press any button to become ",0,7)
  pc(4," dictator  of the ")
  wait4button()
end
function savescreen()
  v_cnoise={}
  dim(v_cnoise,31,31)
  for ay=0,31 do
    for ax=0,31 do
      if pget(ax*4+3,ay*6+5)~=0 then
        v_cnoise[ay][ax]=1
      end
    end
  end
end
function savescreenextra(x0,y0,x1,y1)
  for ay=y0,y1 do
    for ax=x0,x1 do
      v_cnoise[ay][ax]=1
    end
  end
end
function setsavedscreen(c)
  for ay=0,20 do
    for ax=0,31 do
      if v_cnoise[ay][ax]==0 then
        rectfill(ax*4,ay*6,ax*4+3,ay*6+5,c)
      end
    end
  end
end
function restoredata()
  for a=0,petcnt-1 do
    v_pnd[i_peti][a][i_pnd_used]=false
  end
  for a=0,newscnt-1 do
    v_pnd[i_news][a][i_pnd_used]=false
  end
  for a=0,decisioncnt-1 do
    v_pnd[i_deci][a][i_pnd_used]=false
  end
  for a=0,gcnt-1 do
    v_g[a][i_g_popu]=7
    v_g[a][i_g_stre]=6
    v_g_s[a][i_g_stat]=" "
    v_g[a][i_g_alli]=-1
  end
  v_g[p_guer][i_g_popu]=0
  v_g[p_russ][i_g_stre]=0
  v_g[p_amer][i_g_stre]=0
  treasury=1000
  monthly_cost=60
  your_strength=4
  swiss_bank_account=0
  alive=true
  month=0
  plot_bonus=0
  revo_stre=10
  minimal=0
  finalreport=false
end
function showwelcome()
  cls(7)
  padtop=-1
  padleft=0
  pc(1," welcome to office ",0,12)
  p(0,4," the best dictator of our",0,7)
  pn(6," beloved country of ritimba had ")
  pn(8," a final rating of "..history)
  if history~=0 then
    pni(3," you can always try for "..(history+1).." !")
  else
    pni(3," as this is your first attempt ")
    pni(2," you will no doubt do better ! ")
  end
  pni(3," start with a treasury report  ")
  pni(2," and a police report. (free)   ")
  wait4button()
end
function showaccount()
  cls(3)
  padtop=-1
  padleft=0
  for p_y=0,21 do
    p(0,p_y,"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",3,7)
  end
  for x=0,4 do
    printicon(ic_trea,x*24+4,12,0,3,false)
  end
  pc(8," treasury report ",0,7)
  if treasury>=0 then
    t_s="holds"
    p_bg=1
  else
    t_s="owes"
    p_bg=8
  end
  pc(11," the treasury "..t_s.." $"..abs(treasury)..",000 ",7,p_bg)
  pc(13,"  monthly costs are $"..monthly_cost..",000 ",12,1)
  if swiss_bank_account~=0 then
    pc(15," [swiss acct holds $"..swiss_bank_account..",000] ")
  end
  wait4button()
end
function ask4police_report()
  cls(0)
  padtop=-1
  padleft=0
  rectfill(0,0,127,14,10)
  for a=0,4 do
    printicon(ic_spol,a*24+4,0,0,10,false)
  end
  p(0,6,"      secret police report      ",7,0)
  if treasury>0 and v_g[p_spol][i_g_popu]>minimal and v_g[p_spol][i_g_stre]>minimal then
    pc(8," ? ",0,7)
    p(0,14,"        ( costs $1,000 )         ")
    if not input_yesno() then
      return
    end
    treasury=treasury-1
    showpolicereport(false)
  else
    p(0,10,"          not available         ")
    if v_g[p_spol][i_g_popu]<=minimal then
      pni(2,"  your popularity with us is "..v_g[p_spol][i_g_popu])
    end
    if v_g[p_spol][i_g_stre]<=minimal then
      pni(2,"      police strength is "..v_g[p_spol][i_g_stre])
    end
    if treasury<1 then
      pni(2,"    you can't afford a report    ")
    end
    for a=1,20 do
      sound(0,51,32,4)
      flip()
      sound(0,35,32,4)
      flip()
    end
    soundoff(0)
    wait4button()
  end
end
function showpolicereport(finalreport)
  cls(0)
  padtop=-1
  padleft=0
  if finalreport then
    pc(0,"final",7,0)
  else
    pc(0,"month "..month,7,0)
  end
  p(0,2,"                                ",1,1)
  pc(2," secret police report ",0,7)
  p(0,5,"popularity            strengths",7,0)
  printicon(ic_spol,52,21,0,7,false)
  for a=0,gcnt-1 do
    v_g[a][i_g_isal]=false
  end
  for a=0,gcnt-1 do
    g=v_g[a][i_g_alli]
    if g~=-1 then
      v_g[g][i_g_isal]=true
    end
  end
  for a=0,gcnt-1 do
    for i=v_g[a][i_g_popu],1,-1 do
      p(10-i,a+7,""..i,7,3)
    end
    p(10,a + 7,""..(a+1),0,7)
    if v_g[a][i_g_isal] or v_g_s[a][i_g_stat]=="r" then
      p_fg=8
    elseif v_g_s[a][i_g_stat]=="a" then
      p_fg=2
    else
      p_fg=0
    end
    p(11,a+7,v_g_s[a][i_g_fnam],p_fg,10)
    if v_g_s[a][i_g_stat]==" " then
      p_bg=0
      padtop=0
    else
      padtop=-1
      p_bg=8
    end
    p(21,a+7,v_g_s[a][i_g_stat],7,p_bg)
    padtop=-1
    for i=1,v_g[a][i_g_stre] do
      p(21+i,a+7,""..i,7,8)
    end
  end
  p(1,16,"your strength is "..your_strength,7,0)
  pn(17,"strength for revolution is ".. revo_stre)
  wait4button()
  cls(0)
end
function wait4button()
  buttonsub("             button             ",60,9,1)
end
function input_yesno()
  return buttonsub("        o: yes     x: no        ",30,3,8)
end
function buttonsub(buttontext_s,buttonspeed,buttonc1,buttonc2)
  while btn(4) or btn(5) do
    flip()
  end
  padtop=-1
  padleft=0
  p_fg=7
  w4b=0
  yes=false
  first=true
  while true do
    oldbg=p_bg
    if w4b % buttonspeed < buttonspeed / 2 then
      p_bg=buttonc1
    else
      p_bg=buttonc2
    end
    if oldbg ~= p_bg and not first then
      if stat(16)<0 then
        if buttonspeed==30 then
          if p_bg==buttonc1 then
            sound(1,51,1,0)
          else
            sound(1,27,1,0)
          end
        else
          sound(1,39,1,0)
        end
      end
    end
    p(0,20,buttontext_s,p_fg,p_bg)
    flip()
    if btnp(4) then
      yes=true
      break
    end
    if btnp(5) then
      yes=false
      break
    end
    w4b+=1
    first=false
  end
  if buttonspeed==30 then
    if yes then
      p_bg=3
      sound(1,30,3,2)
    else
      p_bg=8
      sound(1,10,3,2)
    end
    p(0,20,buttontext_s,p_fg,p_bg)
    flip()
    if yes then
      p_t_s=" o: yes "
      p_x=7
    else
      p_t_s=" x: no "
      p_x=18
    end
    for i=0,6 do
      p_fg,p_bg=p_bg,p_fg
      p(p_x,20,p_t_s,p_fg,p_bg)
      flip()
    end
  else
    sound(1,20,3,2)
    for i=0,3 do
      p_fg,p_bg=p_bg,p_fg
      p(12, 20," button ",p_fg,p_bg)
      flip()
    end
  end
  return yes
end
function check4plot()
  if month<3 then
    return
  end
  resetplot()
  if month<plot_bonus then
    return
  end
  for a=0,2 do
    if v_g[a][i_g_popu]>minimal then
    else
      for p=0,5 do
        if a==p or v_g[p][i_g_popu]>minimal then
        else
          if v_g[a][i_g_stre]+v_g[p][i_g_stre]>=revo_stre then
            v_g_s[a][i_g_stat]="r"
            v_g[a][i_g_alli]=p
            break
          end
        end
      end
      if v_g_s[a][i_g_stat]==" " then
        v_g_s[a][i_g_stat]="a"
      end
    end
  end
end
function resetplot()
  for a=0,2 do
    v_g_s[a][i_g_stat]=" "
    v_g[a][i_g_alli]=-1
  end
end
function handlebankrupt()
  cls(0)
  padtop=-1
  padleft=0
  pc(5," the treasury is bankrupt ",7,8)
  p(0,9,"your popularity with the army x",7,0)
  pn(11," the secret police will drop ! ")
  pn(13,"    police strength will drop  ")
  pn(15,"and your own strength will drop")
  decreasegroup(p_army,i_g_popu)
  decreasegroup(p_spol,i_g_popu)
  decreasegroup(p_spol,i_g_stre)
  if your_strength>0 then
    your_strength-=1
  end
  wait4button()
  check4plot()
  ask4police_report()
end
function decreasegroup(decrease_group,decrease_idx)
  if v_g[decrease_group][decrease_idx]>0 then
    v_g[decrease_group][decrease_idx]-=1
  end
end
function increasegroup(increase_group,increase_idx)
  if v_g[increase_group][increase_idx]<9 then
    v_g[increase_group][increase_idx]+=1
  end
end
function giveaudience()
  r=fr(1000)%petcnt
  for a=0,petcnt-1 do
    if not v_pnd[i_peti][r][i_pnd_used] then
      break
    end
    if r==petcnt-1 then
      r=0
    else
      r+=1
    end
    if a==petcnt-1 then
      for a=0,petcnt-1 do
        v_pnd[i_peti][a][i_pnd_used]=false
      end
      a=0
    end
  end
  audience_petition=r
  audience_group=v_pnd[i_peti][audience_petition][i_pnd_aut]
  v_pnd[i_peti][audience_petition][i_pnd_used]=true
  cls(10)
  padtop=-1
  padleft=0
  rectfill(0,0,127,5*6-1,3)
  pc(2," an audience ",0,7)
  for a=0,2 do
    printicon(audience_group,a*40+8,36,0,10,false)
  end
  ag_s=v_g_s[audience_group][i_g_name]
  pc(10,"a request from "..ag_s,0,10)
  p(0,13," will your excellency agree to ")
  pn(15,v_pnd_s[i_peti][audience_petition][i_pnd_text],0,7)
  wait4button()
  getadvice(i_peti,audience_petition)
  cls(10)
  pc(1," decision ")
  for a=0,2 do
    printicon(audience_group,a*40+8,18,0,10,false)
  end
  if audience_group==p_peas then
    p_bg=8
  elseif audience_group==p_land then
    p_bg=2
  elseif audience_group==p_army then
    p_bg=1
  else
    p_bg=0
  end
  if audience_group==p_army then
    p_t_s=" "..ag_s.." asks you to "
  else
    p_t_s=" "..ag_s.." ask you to "
  end
  pc(7,p_t_s,7,p_bg)
  p(0,9,v_pnd_s[i_peti][audience_petition][i_pnd_text],7,0)
  getcashadvice(i_peti,audience_petition)
  if cashadvice_result then
    wait4button()
  else
    if input_yesno() then
      if v_pnd[i_peti][audience_petition][i_pnd_cost]~=0 or v_pnd[i_peti][audience_petition][i_pnd_moco]~=0 then
        showaccount()
      end
      transfer(i_peti,audience_petition)
      showaccount()
      return
    end
  end
  for a=0,2 do
    if audience_group==a then
      decvalue=asc(mid_s(v_pnd_s[i_peti][audience_petition][i_pnd_popu],a+1,1))-asc("m")
      v_g[audience_group][i_g_popu]-=decvalue
      v_g[audience_group][i_g_popu]=max(v_g[audience_group][i_g_popu],0)
    end
  end
  showaccount()
end
function getadvice(advice_type,advice_no)
  cls(3)
  padtop=-1
  padleft=0
  for a=1,18 do
    pc(a," ? advice ? ",7,0)
  end
  if input_yesno() then
    cls(10)
    pc(1," ! advice ! ",0,7)
    pc(3,v_pnd_s[advice_type][advice_no][i_pnd_text],10,0)
    p(0,5," your popularity with ....",0,7)
    p_y=7
    for a=0,gcnt-1 do
      x=asc(mid_s(v_pnd_s[advice_type][advice_no][i_pnd_popu],a+1,1))-asc("m")
      if x~=0 then
        p(2,p_y,v_g_s[a][i_g_name],0,10)
        if x>0 then
          p_fg=3
          p_t_s="+"..x
        else
          p_fg=8
          p_t_s=""..x
        end
        p(21,p_y,p_t_s,p_fg,10)
        if v_pnd[advice_type][ advice_no][i_pnd_aut]==a then
          if a==p_peas then
            p_bg=8
          elseif a==p_land then
            p_bg=2
          elseif a==p_army then
            p_bg=1
          else
            p_bg=0
          end
          p(23,p_y," <",10,p_bg)
        end
        p_y+=1
      end
    end
    p_y+=1
    p(0,p_y," the strength of ...",0,7)
    p_y+=2
    for a=0,domgcnt-1 do
      x=asc(mid_s(v_pnd_s[advice_type][advice_no][i_pnd_stre],a+1,1))-asc("m")
      if x~=0 then
        p(2,p_y,v_g_s[a][i_g_name],0,10)
        if x>0 then
          p_fg=3
          p_t_s="+"..x
        else
          p_fg=8
          p_t_s=""..x
        end
        p(21,p_y,p_t_s,p_fg,10)
        if v_pnd[advice_type][ advice_no][i_pnd_aut]==a then
          if a==p_peas then
            p_bg=8
          elseif a==p_land then
            p_bg=2
          elseif a==p_army then
            p_bg=1
          else
            p_bg=0
          end
          p(23,p_y," <",10,p_bg)
        end
        p_y+=1
      end
    end
    wait4button()
    cls(0)
  end
end
function getcashadvice(cashadvice_type,cashadvice_no)
  p_ystart=12
  adv_cost=10*v_pnd[cashadvice_type][cashadvice_no][i_pnd_cost]
  adv_monthly_cost=v_pnd[cashadvice_type][cashadvice_no][i_pnd_moco]
  padtop=-1
  padleft=0
  if adv_cost==0 and adv_monthly_cost==0 then
      p(0,p_ystart,"        no money involved       ",0,10)
      cashadvice_result=false
      return
  else
    if adv_cost<0 and adv_monthly_cost<0 and (treasury+adv_cost<0 or treasury+adv_monthly_cost<0) then
      if v_pnd[cashadvice_type][cashadvice_no][i_pnd_aut]==-1 then
        p_y=p_ystart
        p(0,p_y,"  the cash for this decision is ")
        pni(p_y,"       not in the treasury      ")
        p_y+=2
        if not v_pnd[i_deci][p_dec_russ_loan][i_pnd_used] then
          p_y+=1
          pn(p_y," perhaps the russians can help ?")
        end
        if not v_pnd[i_deci][p_dec_amer_aid][i_pnd_used] then
          p_y+=1
          pn(p_y,"the americans are generous folk ")
        end
      else
        p_y=p_ystart
        p(0,p_y," you have insufficient funds to ")
        pni(1,"     pay for this decision.     ")
        pni(1,"     your answer must be no     ")
      end
      cashadvice_result=true
      return
    else
      p_y=p_ystart
      p(0,p_y,"       this decision would      ",0,10)
      if adv_cost~= 0then
        if adv_cost>0 then
          t_s=" add to"
        else
          t_s=" take from"
        end
        pni(2,t_s.." the treasury $"..abs(adv_cost)..",000".."         ")
      end
      if adv_monthly_cost~=0 then
        if adv_cost~=0 then
          pni(2,"               and              ")
        end
        if adv_monthly_cost<0 then
          t_s=" raise"
        else
          t_s=" lower"
        end
        pni(2,t_s.." monthly costs by $"..abs(adv_monthly_cost)..",000      ")
        cashadvice_result=false
        return
      end
    end
  end
end
function changev(transfer_type,transfer_no,a,i_what)
  local cv=asc(mid_s(v_pnd_s[transfer_type][transfer_no][i_what],a+1,1))-asc("m")
  if cv~=0 then
    v_g[a][i_what]+=cv
    v_g[a][i_what]=max(v_g[a][i_what],0)
    v_g[a][i_what]=min(v_g[a][i_what],9)
  end
end
function transfer(transfer_type,transfer_no)
  if mid_s(v_pnd_s[transfer_type][transfer_no][i_pnd_text],32,1)~="*" then
    v_pnd[transfer_type][transfer_no][i_pnd_used]=true
  end
  for a=0,gcnt-1 do
    changev(transfer_type,transfer_no,a,i_pnd_popu)
  end
  for a=0,domgcnt-1 do
    changev(transfer_type,transfer_no,a,i_pnd_stre)
  end
  treasury+=10*v_pnd[transfer_type][transfer_no][i_pnd_cost]
  monthly_cost-=v_pnd[transfer_type][transfer_no][i_pnd_moco]
  if monthly_cost<0 then
    monthly_cost=0
  end
end
function printassassination()
  cls(0)
  padtop=0
  pc(8," assassination attempt ",7,5)
  pc(11," by one of "..v_g_s[assassins][i_g_name].." ",7,8)
end
function check4assassination()
  assassins=fr(1000)%3
  if v_g_s[assassins][i_g_stat] ~= "a" then
    assa_succ=false
    return
  end
  printassassination()
  pc(15," you're dead ! ",7,8)
  savescreen()
  pc(15,"               ",7,8)
  iconx=-22
  for a=0,5 do
    if a==0 then
      dir=1
      targetx=86 + fr(20) - 12
    elseif a==1 then
      dir=-1
      targetx=22 + fr(20) - 12
    elseif a==2 then
      dir=1
      targetx=70 + fr(10) - 12
    elseif a==3 then
      dir=-1
      targetx=49 + fr(10) - 12
    else
      dir=1
      targetx=63 - 12
    end
    while (dir==1 and iconx < targetx) or (dir==-1 and iconx > targetx) do
      printassassination()
      printicon(ic_assa,iconx,10,7,0,false)
      iconx=iconx + dir * 2
      sound(2,flr(iconx/2)+7,32,0)
      flip()
    end
  end
  soundoff(2)
  sound(2,47,6,6)
  if (v_g_s[p_army][i_g_stat]=="a" and v_g_s[p_peas][i_g_stat]=="a" and v_g_s[p_land][i_g_stat]=="a") or v_g[p_spol][i_g_popu] <= minimal or v_g[p_spol][i_g_stre] <= minimal or fr(1000) % 2==0 then
    pc(15," you're dead ! ",7,8)
    alive=false
    assa_succ=true
    dropblood()
  else
    pc(15," attempt failed ",7,3)
    assa_succ=false
    colornoise()
  end
  wait4button()
end
function check4war()
  padleft=-1
  padtop=-1
  if v_g[p_left][i_g_popu]>minimal or v_g[p_left][i_g_stre]<=minimal then
    warlost=false
    return
  end
  if fr(1000)%3>0 then
    cls(7)
    pc(6," threat of war with leftoto ",7,8)
    pc(11," your popularity in ritimba ")
    pc(12,"         will rise          ")
    for a=0,2 do
      increasegroup(a,i_g_popu)
    end
    increasegroup(p_spol,i_g_popu)
    wait4button()
    warlost=false
    return
  end
  ritimban_strength=your_strength
  leftotan_strength=0
  for a=0,2 do
    if v_g[a][i_g_popu]>minimal then
      ritimban_strength+=v_g[a][i_g_stre]
    end
  end
  if v_g[p_spol][i_g_popu]>minimal then
    ritimban_strength+=v_g[p_spol][i_g_stre]
  end
  for a=0,domgcnt do
    if v_g[a][i_g_popu]<=minimal then
      leftotan_strength+=v_g[a][i_g_stre]
    end
  end
  cls(8)
  printicon(ic_army,10,12,0,0,false)
  printicon(ic_army,85,12,0,0,true)
  pc(6," leftoto  invades ",5,7)
  pc(15," a short decisive war ")
  pc(9,"ritimban strength is "..ritimban_strength,7,8)
  pc(11,"leftotan strength is "..leftotan_strength)
  warsounds(false,-99,15," a short decisive war ")
  padtop=0
  padleft=0
  if ritimban_strength>leftotan_strength+fr(1000)%3-1 then
    cls(0)
    pc(10," leftotans routed ",0,7)
    v_g[p_left][i_g_stre]=0
    savescreen()
    colornoise()
    wait4button()
    warlost=false
    return
  else
    cls(0)
    pc(5," leftotan victory ",5,8)
    wait(1)
    if v_pnd[i_deci][p_dec_heli][i_pnd_used] and fr(1000)%3>0 then
      pc(11," you escape by helicopter ! ",3,7)
      savescreen()
      colornoise()
    else
      alive=false
      if v_pnd[i_deci][p_dec_heli][i_pnd_used] then
        pc(9," helicopter engine failure  ",8,7)
        wait(1)
      end
      pc(11,"  you are judged to be an   ",5,8)
      pc(13," enemy of the people and... ")
      pc(15,"     summarily executed     ",8,7)
      savescreen()
      dropblood()
      warlost=true
    end
    wait4button()
  end
end
function endgame()
  cls(10)
  total=0
  for a=0,gcnt do
    total+=v_g[a][i_g_popu]
  end
  printicon(ic_meda,-2,1,0,0)
  padleft=-1
  for a=0,2 do
    p(5,1+a,"**************************",10,8)
  end
  p(6,2,"your rating as president",0,7)
  padleft=0
  p(1,5,"total popularity:",0,10)
  p(-31,5,""..total)
  p(1,7,"months in office ("..month.." * 3):")
  p(-31,7,""..(month*3))
  total+=month*3
  p_y=7
  if alive then
    p_y+=2
    p(1,p_y,"for staying alive:")
    p(-31,p_y,""..10)
    p_y+=2
    p(1,p_y,"for moneygrabbing ")
    p_y+=1
    p(5,p_y,"($"..swiss_bank_account..",000 / 10,000):")
    p(-31,p_y,""..flr(swiss_bank_account/10))
    total+=10+flr(swiss_bank_account/10)
  end
  p_y+=2
  p(1,p_y,"------------------------------")
  p_y+=2
  pn(p_y,"your total is:")
  padleft=-1
  p(-31,p_y,""..total,0,7)
  padleft=0
  if total>history then
    history=total
    dset(0,history)
    p_y+=2
    pc(p_y," this is a new high score ! ")
  else
    p_y+=2
    p(-1,p_y," [ highest score so far is "..history.." ] ",0,10)
  end
  sfx(0,0,0,18)
  wait4button()
  showpolicereport(true)
end
function makedecision()
  while true do
    decisioncls()
    p(0,4," try to ... ",0,10)
    p_y=4
    for a=0,decsectcnt-1 do
      p_y+=2
      p(3,p_y,v_decsect_s[a],10,0)
    end
    while btnp(4) or btnp(5) do
      flip()
    end
    w4b=0
    selection=0
    while true do
      p(3,selection*2+6,v_decsect_s[selection],0,7)
      if w4b%30<15 then
        p_fg=7
        p_bg=0
      else
        p_fg=0
        p_bg=7
      end
      p(0,20," up, down, o: select, x: cancel ",p_fg,p_bg)
      flip()
      p(3,selection*2+6,v_decsect_s[selection],10,0)
      if btnp(2) then
        soundclick()
        selection-=1
        if selection<0 then
          selection=decsectcnt-1
        end
      end
      if btnp(3) then
        soundclick()
        selection+=1
        if selection>=decsectcnt then
          selection=0
        end
      end
      if btnp(4) then
        soundyes()
        break
      end
      if btnp(5) then
        soundno()
        selection=-1
        break
      end
      w4b+=1
    end
    cls()
    if selection==-1 then
      return
    end
    astart=v_decsect[selection][i_ds_astart]
    aend=v_decsect[selection][i_ds_aend]
    decisioncls()
    p(0,4," try to ... ",0,10)
    p(2,6,v_decsect_s[selection],0,10)
    available_decisions=0
    p_y=6
    for a=astart,aend do
      if not v_pnd[i_deci][a][i_pnd_used] then
        p_y+=2
        p(0,p_y,""..v_pnd_s[i_deci][a][i_pnd_text],10,0)
        v_menuitem[available_decisions][i_menu_y]=p_y
        v_menuitem[available_decisions][i_menu_decision]=a
        available_decisions+=1
      end
    end
    if available_decisions==0 then
      p(0,12,"   all of this section used up  ",8,0)
      wait4button()
    else
      while btnp(4) or btnp(5) do
        flip()
      end
      w4b=0
      r=0
      while true do
        p(0,v_menuitem[r][i_menu_y],v_pnd_s[i_deci][v_menuitem[r][i_menu_decision]][i_pnd_text],0,7)
        if w4b%30<15 then
          p_fg=7
          p_bg=0
        else
          p_fg=0
          p_bg=7
        end
        p(0,20," up, down, o: select, x: cancel ",p_fg,p_bg)
        flip()
        p(0,v_menuitem[r][i_menu_y],v_pnd_s[i_deci][v_menuitem[r][i_menu_decision]][i_pnd_text],10,0)
        if btnp(2) then
          soundclick()
          r-=1
          if r<0 then
            r=available_decisions-1
          end
        end
        if btnp(3) then
          soundclick()
          r+=1
          if r>=available_decisions then
            r=0
          end
        end
        if btnp(4) then
          soundyes()
          r=v_menuitem[r][i_menu_decision]
          break
        end
        if btnp(5) then
          soundno()
          r=-1
          break
        end
        w4b+=1
      end
      cls()
      if r==12 or r==13 or r==14 then
        executedecision(r)
        return
      elseif r==-1 then
      else
        getadvice(i_deci,r)
        decisioncls()
        p(0,3,v_pnd_s[i_deci][r][i_pnd_text],7,0)
        getcashadvice(i_deci,r)
        if cashadvice_result then
          wait4button()
        else
          if input_yesno() then
            executedecision(r)
            break
          end
         end
      end
    end
  end
end
function executedecision(r)
  if r==10 then
    your_strength+=2
    showaccount()
    transfer(i_deci,r)
  elseif r==12 then
    cls(0)
    p(0,3,"transfer to a swiss bank account",7,0)
    stolen=flr(treasury/2)
    if stolen>0 then
      pn(11,"the treasury held $"..treasury..",000")
      swiss_bank_account+=stolen
      treasury-=stolen
      pn(13,"$"..stolen..",000 has been transferred")
    else
      p(7,11,"no transfer made")
    end
    wait4button()
  elseif r==13 or r==14 then
    apply4aid(i_deci,r)
  else
    showaccount()
    transfer(i_deci,r)
  end
  if v_pnd[i_deci][r][i_pnd_cost]~=0 or v_pnd[i_deci][r][i_pnd_moco]~=0 then
    showaccount()
  end
end
function decisioncls()
  cls(8)
  for a=0,20 do
    p(0,a,"********************************",10,8)
  end
  pc(1," presidential decision ",7,1)
end
function apply4aid(aid_type,aid_no)
  cls(7)
  aidgroup=v_pnd[aid_type][aid_no][i_pnd_aut]
  padtop=-1
  pc(1," $ $ $ $ $ $ $ $ $ $ $ $ $ $ $  ",7,3)
  pc(3," application for foreign aid ",7,0)
  padtop=0
  if aidgroup==p_amer then
    for a=0,6 do
      p_y=5+a
      p(8,5+a,"                ",8,8)
      rectfill(8*4,(a+5)*6+3,127-8*4,(a+5)*6+5,7)
    end
    for a=0,3 do
      if a%2==0 then
        t_s="* * * * "
      else
        t_s=" * * * *"
      end
      p(8,5+a,t_s,7,1)
    end
  else
    for a=0,5 do
      p(8,5+a,"                ",8,8)
    end
    p(10,5,"*",10,8)
    p(9,6,"+x)")
  end
  padtop=-1
  p_fg=7
  p_bg=0
  pc(14," wait ",p_fg,p_bg)
  flip()
  if aidgroup==p_russ then
    sfx(2,2)
  else
    sfx(1,2)
  end
  while stat(18)>=0 do
    p_bg,p_fg=p_fg,p_bg
    pc(14," wait ",p_fg,p_bg)
    wait(0.2)
  end
  if month<=fr(1000)%5+3 then
    pc(14," it's too early to give aid ",0,10)
  elseif v_pnd[aid_type][ aid_no][i_pnd_used] then
    pc(14," very sorry,no more loans ",7,8)
  elseif v_g[aidgroup][i_g_popu]<=minimal then
    if aidgroup==p_russ then
      pc(14," niet ! ",7,8)
    else
      pc(14," "..chr_s(34).."nuts !"..chr_s(34).." ",7,8)
    end
  else
    pc(14," "..v_g_s[aidgroup][i_g_name].." will let you have ",7,0)
    loan=v_g[aidgroup][i_g_popu]*30+fr(1000)%200
    pc(16," "..loan..",000 dollars ")
    treasury+=loan
    v_pnd[aid_type][aid_no][i_pnd_used]=true
  end
  wait4button()
end
function check4revolution()
  dictator_strength=0
  revolutionary_strength=0
  allies=-1
  rgroup=-1
  rallies=-1
  for a=0,2 do
    rgroup=fr(1000)%3
    if v_g_s[rgroup][i_g_stat]=="r" then
      break
    end
    if a==2 then
      revo_succ=false
      return
    end
  end
  rallies=v_g[rgroup][i_g_alli]
  cls(0)
  drawrevolutionbanner()
  padtop=0
  pc(10," revolution ",0,7)
  savescreen()
  savescreenextra(0,2,31,5)
  for a=0,7 do
    if a%2==0 then
      sound(2,37,32,2)
      setsavedscreen(0)
    else
      sound(2,13,32,2)
      setsavedscreen(8)
    end
    wait(0.5)
  end
  soundoff(2)
  pc(13," escape attempt ? ",0,10)
  padtop=0
  if input_yesno() then
    cls(7)
    if v_pnd[i_deci][p_dec_heli][i_pnd_used] then
      if fr(1000)%3>0 then
        cls(0)
        pc(9," you escape by helicopter ! ",3,7)
        savescreen()
        colornoise()
        wait4button()
        revo_succ=true
        return
      else
        pc(9," the helicopter won't start ! ",0,8)
        wait4button()
        cls(0)
      end
    end
    escape_to_leftoto()
    revo_succ=true
    return
  end
  cls(8)
  padtop=-1
  pc(1," revolution ",0,7)
  revolutionary_strength=v_g[rgroup][i_g_stre]+v_g[rallies][i_g_stre]
  dictator_strength=your_strength
  pt_s=" "..v_g_s[rgroup][i_g_name].." have joined with "
  lastlen=#pt_s
  p(1,4,pt_s,8,7)
  pn(5,sub(" "..v_g_s[rallies][i_g_name].."                                  ",1,lastlen))
  pn(7," their combined strength is "..revolutionary_strength)
  pc(10," who are you asking for help ?  ",7,0)
  alliescnt=0
  p_y=11
  for a=0,domgcnt-1 do
    if v_g[a][i_g_popu]>minimal then
      p_y+=1
      v_menuitem[alliescnt][i_menu_y]=p_y
      v_menuitem[alliescnt][i_menu_decision]=a
      p(6,p_y," "..v_g_s[a][i_g_name].." ")
      alliescnt=alliescnt+1
    end
  end
  if alliescnt>0 then
    p_y+=1
    v_menuitem[alliescnt][i_menu_y]=p_y
    v_menuitem[alliescnt][i_menu_decision]=-1
    p(6,p_y," escape to leftoto ",7,0)
    while btnp(4) do
      flip()
    end
    w4b=0
    h=0
    while true do
      a=v_menuitem[h][i_menu_decision]
      if a<0 then
        t_s=" escape to leftoto "
      else
        t_s=" "..v_g_s[a][i_g_name].." "
      end
      p(6,v_menuitem[h][i_menu_y],t_s,0,7)
      p_y=20
      p_x=0
      if w4b%30<15 then
        p_fg=7
        p_bg=0
      else
        p_fg=0
        p_bg=7
      end
      p(0,20,"      up, down, o: select       ",p_fg,p_bg)
      flip()
      p(6,v_menuitem[h][i_menu_y],t_s,7,0)
      if btnp(2) then
        soundclick()
        h=h-1
        if h<0 then
          h=alliescnt
        end
      end
      if btnp(3) then
        soundclick()
        h=h+1
        if h>alliescnt then
          h=0
        end
      end
      if btnp(4) then
        soundyes()
        break
      end
      w4b=w4b+1
    end
    cls()
    allies=v_menuitem[h][i_menu_decision]
    if allies==-1 then
      escape_to_leftoto()
      revo_succ=true
      return
    end
    dictator_strength+=v_g[allies][i_g_stre]
  else
    cls(8)
    padtop=-1
    pc(1," revolution ",0,7)
    pc(10," you're on your own ! ",8,0)
    wait4button()
  end
  cls(8)
  padtop=-1
  pc(1," revolution ",0,7)
  p(0,8,"your strength is "..your_strength,7,0)
  if allies~=-1 then
    pn(10,v_g_s[allies][i_g_name].." strength is "..v_g[allies][i_g_stre])
  end
  pn(12,"the revolution's is "..revolutionary_strength,8,7)
  wait4button()
  cls(8)
  pc(10," the revolution has started ",7,0)
  flip()
  warsounds(false,-99,10," the revolution has started ")
  if revolutionary_strength>dictator_strength+fr(1000)%3-1 then
    cls(0)
    padtop=0
    pc(10," you have been overthrown ",0,8)
    pc(11,"      and liquidated      ")
    savescreen()
    dropblood()
    alive=false
    wait4button()
    revo_succ=true
    return
  else
    cls(0)
    padtop=0
    pc(8," the revolt has been crushed ! ",0,3)
    savescreen()
    colornoise()
    pc(11," punish the revolutionaries ? ",7,8)
    if input_yesno() then
      warsounds(true,-99,11," punish the revolutionaries ! ")
      v_g[rgroup][i_g_stre]=0
      v_g[rgroup][i_g_popu]=0
      v_g[rallies][i_g_stre]=0
      v_g[rallies][i_g_popu]=0
    end
    if allies~=-1 then
      v_g[allies][i_g_popu]=0
    end
    plot_bonus=month+2
    resetplot()
    showpolicereport(false)
    revo_succ=false
    return
  end
end
function escape_to_leftoto()
  cls(7)
  pc(9," you have to get through the ",0,7)
  pc(11," mountains to leftoto ")
  wait4button()
  cls(7)
  if fr(1000)%(flr(v_g[p_guer][i_g_stre]/3)+2) then
    alive=false
  else
    alive=true
  end
  cls(0)
  padtop=0
  padleft=0
  if alive then
    pc(9," lucky bastard ! ",0,7)
    pc(11," the guerillas didn't catch you ")
    colornoise()
  else
    pc(7," the guerillas are celebrating ",7,8)
    pc(9," after they caught and ")
    pc(11," liquidated you ! ")
    savescreen()
    dropblood()
  end
  wait4button()
end
function newsflash()
  if fr(1000)%3>0 then
    return
  end
  r=fr(1000)%newscnt
  newsfound=false
  for a=0,newscnt-1 do
    if not v_pnd[i_news][r][i_pnd_used] then
      newsfound=true
      break
    end
    r+=1
    if r==newscnt then
      r=0
    end
  end
  if not newsfound then
    if reusenews then
      for a=0,newscnt-1 do
        v_pnd[i_news][a][i_pnd_used]=false
      end
    end
    return
  end
  cls(7)
  padtop=-1
  pc(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",7,8)
  pc(5,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
  p_t_s="!"
  for a=2,4 do
    p(0,a,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    p(31,a,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
  end
  for a=0,5 do
    printicon(ic_news,a*40+8,78,0,7,false)
  end
  for a=31,0,-1 do
    p_fg=7
    p_bg=0
    if a%6<3 then
      p_bg,p_fg=p_fg,p_bg
    end
    pc(3," newsflash ",p_fg,p_bg)
    p(a,10,v_pnd_s[i_news][r][i_pnd_text],8,7)
    mask=1
    for b=0,1 do
      if a and mask~=0 then
        sound(0,39,1,2)
      else
        soundoff(0)
      end
      flip()
      if btn(4) or btn(5) then
        b=3
        break
      end
      soundoff(0)
      flip()
      if btn(4) or btn(5) then
        b=3
        break
      end
      mask*=2
    end
    if (btn(4) or btn(5) or b==3) and a>2 then
      a=2
    end
  end
  wait4button()
  transfer(i_news,r)
  check4plot()
  ask4police_report()
end
function colornoise()
  soundoff(2)
  for a=0,20 do
    sound(2,35+fr(24),1,0)
    for ay=0,20 do
      for ax=0,31 do
        if v_cnoise[ay][ax]==0 then
          rectfill(ax*4,ay*6,ax*4+3,ay*6+5,fr(15)+1)
        end
      end
    end
    flip()
  end
  soundoff(2)
end
function dropblood()
  v_blood={}
  dim(v_blood,31)
  soundoff(0)
  repeat
    allblood=true
    sumy=0
    for a=0,31 do
      if v_blood[a]<22 then
        allblood=false
        newy=v_blood[a]+fr(2.5)
        for yy=v_blood[a],newy do
          if v_cnoise[yy][a]==0 then
            rectfill(a*4,yy*6,a*4+3,yy*6+5,8)
          end
        end
        v_blood[a]=newy
      end
      sumy=sumy+newy
    end
    sound(0,max(min(32-flr(sumy/32),63),0),32,2)
    flip()
    flip()
    soundoff(0)
  until allblood
end
function warsounds(punishing,px,py,pt_s)
  if punishing then
    amax=5
  else
    amax=20
  end
  for a=0,amax do
    if (a==20 or (fr(1000)%4==0 and a>0)) and not punishing then
      p(px,py,pt_s,0,7)
      for b=0,fr(10)+10 do
        sound(2,fr(12),1,6)
        flip()
      end
      soundoff(2)
      flip()
    else
      p(px,py,pt_s,7,0)
      for b=3,fr(6)+3 do
        sound(2,11,1,6)
        flip()
        soundoff(2)
        flip()
      end
    end
    flip()
  end
end
function p(px,py,pt_s,pfg,pbg)
  px=px or _px
  py=py or _py
  pt_s=pt_s or _pt_s
  pfg=pfg or _pfg
  pbg=pbg or _pbg
  if #pt_s>32 then
    pt_s=sub(pt_s,1,32)
  end
  if px==-99 then
    pxx=flr((32-#pt_s)/2)
  else
    if px<0 then
      pxx=abs(px)-#pt_s
      if pxx<0 then
        pxx=0
      end
    else
      pxx=px
    end
  end
  rectfill(pxx*4+padleft,py*6+padtop,(pxx+#pt_s)*4-1,py*6+5,pbg)
  print(pt_s,pxx*4,py*6,pfg)
  _px=px
  _py=py
  _pt_s=pt_s
  _pfg=pfg
  _pbg=pbg
end
function pn(py,pt_s,pfg,pbg)
  p(_px,py,pt_s,pfg,pbg)
end
function pni(pyi,pt_s,pfg,pbg)
  _py+=pyi
  p(_px,_py,pt_s,pfg,pbg)
end
function pc(py,pt_s,pfg,pbg)
  p(-99,py,pt_s,pfg,pbg)
end
function printicon(iconno,iconx,icony,iconfg,iconbg,iconmirror)
  m=iconmetadata[iconno+1]
  if iconbg==0 then
    palt(0,true)
  else
    palt(0,false)
    pal(0,iconbg)
  end
  pal(15,iconfg)
  sspr(m[1],m[2],m[3],m[4],iconx,icony,m[3],m[4],iconmirror)
  pal()
end
function initicons()
  iconmetadata={{0,0,32,15},{32,0,32,15},{64,0,32,15},{96,0,24,15},{0,15,24,24},{24,15,24,24},{48,15,24,27},{0,48,64,27},{72,16,32,30}}
  ic_army=0
  ic_peas=1
  ic_land=2
  ic_spol=3
  ic_trea=4
  ic_assa=5
  ic_meda=6
  ic_revo=7
  ic_news=8
end
function initgroup(i,v0,v1,v2_s,v3,v4_s,v5_s)
  v_g[i][i_g_popu]=v0
  v_g[i][i_g_stre]=v1
  v_g_s[i][i_g_stat]=v2_s
  v_g[i][i_g_alli]=v3
  v_g_s[i][i_g_name]=v4_s
  v_g_s[i][i_g_fnam]=v5_s
end
function initgroups()
  gcnt=8
  domgcnt=6
  p_army=0
  p_peas=1
  p_land=2
  p_guer=3
  p_left=4
  p_spol=5
  p_russ=6
  p_amer=7
  i_g_popu=0
  i_g_stre=1
  i_g_alli=2
  i_g_isal=3
  v_g={}
  dim(v_g,gcnt,3)
  i_g_stat=0
  i_g_name=1
  i_g_fnam=2
  v_g_s={}
  dim_s(v_g_s,gcnt,2)
  initgroup(0,7,6," ",-1,"the army"         ,"   army   ")
  initgroup(1,7,6," ",-1,"the peasants"     ," peasants ")
  initgroup(2,7,6," ",-1,"the landowners"   ,"landowners")
  initgroup(3,0,6," ",-1,"the guerillas"    ,"guerillas ")
  initgroup(4,7,6," ",-1,"the leftotans"    ,"leftotans ")
  initgroup(5,7,6," ",-1,"the secret police"," s.police ")
  initgroup(6,7,0," ",-1,"the russians"     ," russians ")
  initgroup(7,7,0," ",-1,"the americans"    ,"americans ")
end
function initpnd2(i0,i1,v0,v1_s,v2_s,v3_s,v4_s,v5_s,v6)
  v_pnd[i0][i1][i_pnd_used]=v0
  v_pnd[i0][i1][i_pnd_cost]=asc(v1_s)-asc("m")
  v_pnd[i0][i1][i_pnd_moco]=asc(v2_s)-asc("m")
  v_pnd_s[i0][i1][i_pnd_popu]=v3_s
  v_pnd_s[i0][i1][i_pnd_stre]=v4_s
  v_pnd_s[i0][i1][i_pnd_text]=v5_s
  v_pnd[i0][i1][i_pnd_aut]=v6
end
function initdecsect(i,v0_s,v1,v2)
  v_decsect_s[i]=v0_s
  v_decsect[i][i_ds_astart]=v1
  v_decsect[i][i_ds_aend]=v2
end
function initpnd()
  petcnt=24
  newscnt=6
  decisioncnt=19
  decsectcnt=5
  i_peti=0
  i_news=1
  i_deci=2
  p_dec_russ_loan=13
  p_dec_amer_aid=14
  p_dec_heli=11
  v_pnd={}
  dim(v_pnd,2,petcnt,3)
  v_pnd_s={}
  dim_s(v_pnd_s,2,petcnt,2)
  i_ds_astart=0
  i_ds_aend=1
  v_decsect_s={}
  dim_s(v_decsect_s,decsectcnt)
  v_decsect={}
  dim(v_decsect,decsectcnt,1)
  i_pnd_used=0
  i_pnd_cost=1
  i_pnd_moco=2
  i_pnd_aut=3
  i_pnd_popu=0
  i_pnd_stre=1
  i_pnd_text=2
  initpnd2(0,0,0,"m","h","qjlmmmmm","pklmmm","     introduce conscription     ",0)
  initpnd2(0,1,0,"m","m","pmjmmmmm","nmlmmm"," requisition land for training  ",0)
  initpnd2(0,2,0,"c","m","plnmlmlm","nmnimm","   attack all guerilla bases    ",0)
  initpnd2(0,3,0,"e","m","plmmimlm","nmnkmm","attack guerilla bases in leftoto",0)
  initpnd2(0,4,0,"m","m","qonmmimm","nmnmmj","  sack the secret police chief  ",0)
  initpnd2(0,5,0,"m","m","pmmmlmio","mmmmmm","expel russian military advisors ",0)
  initpnd2(0,6,0,"m","d","qmlmmmmm","olllmm"," increase the pay of the troops ",0)
  initpnd2(0,7,0,"a","m","qllmllmm","pllklm","  buy more arms and ammunition  ",0)
  initpnd2(0,8,0,"m","m","lonmmmmm","lmmlmm","   stop army sign-up coercion   ",1)
  initpnd2(0,9,0,"m","m","mqimnmmm","molmmm","increase the basic minimum wage ",1)
  initpnd2(0,10,0,"m","p","nqommimm","nnnnmj"," cut the powers of the s.police ",1)
  initpnd2(0,11,0,"m","m","mpkmkmmm","mokmmm","stop leftotan immigrant workers ",1)
  initpnd2(0,12,0,"c","e","lqkmolnm","mnllmm","introduce free education for all",1)
  initpnd2(0,13,0,"m","m","mqjmnlnm","mpjmml","legalise the formation of unions",1)
  initpnd2(0,14,0,"m","m","lqkmnlmm","mollmm","  free their imprisoned leader  ",1)
  initpnd2(0,15,0,"m","s","mplmmmmm","mmmlmm","     start a public lottery     ",1)
  initpnd2(0,16,0,"m","m","kmpmmmmm","lmmmmm","stop military use of their land ",2)
  initpnd2(0,17,0,"m","m","miqmlmlm","mkonmm","  lower the basic minimum wage  ",2)
  initpnd2(0,18,0,"w","h","mmpmnmoi","mmnmmm","nationalise american businesses ",2)
  initpnd2(0,19,0,"m","r","mmpmjmlm","mnomlm","levy duty on all leftoto imports",2)
  initpnd2(0,20,0,"m","q","nnpmmimm","nmnnmk"," cut spending on the s. police  ",2)
  initpnd2(0,21,0,"m","h","mmqmmmmm","mmommm","  decrease heavy land taxation  ",2)
  initpnd2(0,22,0,"m","m","klpmmmmm","llnnmm","release troops to work the land ",2)
  initpnd2(0,23,0,"a","c","nnpmjmon","mmpmkm","build a large irrigation system ",2)
  initpnd2(1, 0,0,"m","m","mmmmmimm","mmmqmi"," president loses s.police files ",-1)
  initpnd2(1, 1,0,"m","m","mmmmmmmm","lmmvmm"," cubans arm and train guerillas ",-1)
  initpnd2(1, 2,0,"m","m","mmmmmmmm","immomn","accident. army barrack blows up ",-1)
  initpnd2(1, 3,0,"m","m","mmmmmmmm","mmjmkm","   banana prices fall by 98%    ",-1)
  initpnd2(1, 4,0,"m","m","mmmmmmmm","mmomim","  major earthquake in leftoto   ",-1)
  initpnd2(1, 5,0,"m","m","mmmmmmmm","milkmm","a plague sweeps through peasants",-1)
  initpnd2(2, 0,0,"m","m","qllmmlmm","nmmlml","make army chief 'vice-president'",-1)
  initpnd2(2, 1,0,"l","i","lqnmomnm","mmmlmm","set up free clinics for workers ",-1)
  initpnd2(2, 2,0,"m","m","lkqmmllm","llomml","give landowners regional powers ",-1)
  initpnd2(2, 3,0,"r","m","kmmmqmkn","lmmlpm","sell american arms to leftoto   ",-1)
  initpnd2(2, 4,0,"y","m","mmlmlmkp","mmmmmm","sell mining rights to u.s. firms",-1)
  initpnd2(2, 5,0,"m","w","kmmmmmpj","mmmmnm","rent the russians a naval base  ",-1)
  initpnd2(2, 6,0,"m","e","nppmmmmm","lmmlmm","decrease general taxation level ",-1)
  initpnd2(2, 7,0,"e","m","pppmmmmm","mmmlmm","stage a big popularity campaign ",-1)
  initpnd2(2, 8,0,"m","u","pppmmdmm","onnnmd","cut s.police powers completely  ",-1)
  initpnd2(2, 9,0,"m","g","jjjmmumm","llllmu","increase s.police powers a lot  ",-1)
  initpnd2(2,10,0,"i","m","kllmmlmm","kmmmml","increase your bodyguard        *",-1)
  initpnd2(2,11,0,"a","m","iijmmkmm","mmmmmm","buy an escape helicopter        ",-1)
  initpnd2(2,12,0,"m","m","mmmmmmmm","mmmmmm","see to your swiss bank account *",-1)
  initpnd2(2,13,0,"m","m","mmmmmmmm","mmmmmm","ask the russians for a 'loan'  *",6)
  initpnd2(2,14,0,"m","m","mmmmmmmm","mmmmmm","ask americans for foreign 'aid'*",7)
  initpnd2(2,15,0,"z","m","nnpmgmkm","mmmmmm","nationalise leftotan businesses ",-1)
  initpnd2(2,16,0,"h","m","pmmmjmlm","rmmkkl","buy heavy artillery for the army",-1)
  initpnd2(2,17,0,"m","m","mplmmlmm","mrlpml","allow peasants free movement    ",-1)
  initpnd2(2,18,0,"m","m","llpmmlmm","llrlml","allow landowners private militia",-1)
  initdecsect(0," 1. please a group       ",0,5)
  initdecsect(1," 2. please all groups    ",6,8)
  initdecsect(2," 3. improve your chances ",9,12)
  initdecsect(3," 4. raise some cash      ",13,15)
  initdecsect(4," 5. strengthen a group   ",16,18)
end
function drawrevolutionbanner()
  for a=0,1 do
    printicon(ic_revo,a*64,12,0,8,false)
  end
end
function soundclick()
  sound(1,23,1,2)
end
function soundyes()
  sound(1,30,3,2)
end
function soundno()
  sound(1,10,3,2)
end
initicons()
initgroups()
initpnd()
v_menuitem={}
dim(v_menuitem,decisioncnt-1,1)
i_menu_y=0
i_menu_decision=1
reusenews=false
while true do
  showintro()
  showtitle()
  restoredata()
  showwelcome()
  showaccount()
  showpolicereport(false)
  while true do
    minimal=fr(1000)%3+2
    revo_stre=fr(1000)%3+10
    month+=1
    cls(10)
    p(11,10," month "..month,0,12)
    p(18,10," "..month.." ",0,7)
    wait4button()
    check4plot()
    if treasury>0 then
      treasury-=monthly_cost
    else
      handlebankrupt()
    end
    giveaudience()
    check4plot()
    check4assassination()
    if assa_succ then
      break
    else
      check4war()
      if warlost then
        break
      end
    end
    check4plot()
    ask4police_report()
    makedecision()
    ask4police_report()
    newsflash()
    check4revolution()
    if revo_succ then
      break
    end
  end
  endgame()
end
exit()
__gfx__
00000000000ff00000000000000000000fff000000000000000000000000fff0000ff0000fff0000000000000000000000000000000000000000000000000000
00000000000ff0000000000000000000000ffff000000000000000000ffff00000ffff00f00ff000000000000000000000000000000000000000000000000000
00000000000ff0000000000000000000000000ffff000000000000ffff0000000f0000ff00000f00000000000000000000000000000000000000000000000000
00f00000000ff0000000000000ff0000000000000ffff000000ffff0000000000f000f0ff0000000ffffffffffff0000000000000ffffff00000000000000000
00ff00ffffffffff0ff0f0f0f0f0ff00000000000000ffffffff0000000000000000f000ff00000ffffffffffffff00000000000ffffffff0000000000000000
00f0fff000ff00ffff0f0f0f0f0f0f000000000000000ffffff00000000000000000f0000f0000ffffffffffffffff000000000ffffffffff000000000000000
00f00fffffff0ffffffffffffffff0000000000000ffff0000ffff000000000000000f000ff00ffffffffffffffffff0000000ffffffffffff00000000000000
00fffff00ffffffffffffffffffff0000000000ffff0000000000ffff00000000000000000f0000ff0ff0ff0ff0ff0000000ffffffffffffffff000000000000
00f000fffffffffff0000000000000000f00ffff0000000000000000ffff00f0000ffffffffffffff0ff0ff0ff0ff000000ff00f000ff000f00ff00000000000
00000000000f000f0000000000000000fffff0000000000000000000000fffff00ffffffffffffffffffffffffffff0000f0000ffffffffff0000f0000000000
00000000000fffff0000000000000000fff00000000000000000000000000fff0fffffffffffffffff00fffff00ffff00000000ffffffffff000000000000000
0000000000ff0f0ff0000000000000000ff00000000000000000000000000ff000ff0fff0fff0ffff0000ffff00ffff00000000ffffffffff000000000000000
000000000ff00f00ff000000000000000fffff00000000000000000000fffff000f000f000f000fff0000ffff00ffff00000000ffffffffff000000000000000
00000000ff000f000ff000000000000000fff0000000000000000000000fff0000f000f000f000fff0000ffffffffff000000ffffffffffffff0000000000000
000000fff000fff000fff00000000000000f000000000000000000000000f0000000000000000000f0000fff0000000000ffffffff0000ffffffff0000000000
00000000000000000000000000000000000f000000000000000000000fffff00000000000000000000f000000000f00000000000000000000000000000000000
00000000000ff0000000000000000000000f0000000000000000000fffffffff0000000000000000000f0000000f000000000000000000000000000000000000
00000000000ff0000000000000000000000f000000000000000000fffffffffff0000000000000000000f00000f0000000000000000000000000000000000000
000000000ffffff000000000000000000fffff000000000000000fffff000fffff0000000000000000000f000f00000000000000000000000000000000000000
00000000ffffffff000000000000000ff00f00ff000000000000ffff00fff00ffff0000000000000000000f0f000000000000000000000000000000000000000
0000000ff000000ff0000000000000f0000f0000f00000000000fff0fffffff0fff00000000000000000000f0000000000000000000000000000000000000000
000000ff000ff000ff00000000000f00000f00000f000000000ffff0fffffff0ffff0000000ffffffffffffffffffffffffff000000000000000000000000000
00000ff0000ff0000f0000000000f00000fff00000f00000000fff0fffffffff0fff00000ffffffffffffffffffffffffffffff0000000000000000000000000
00000ff0000ff000000000000000f000ff0f0ff000f00000000fff0fffffffff0fff0000ffffff000000000000000fffffffffff000000000000000000000000
000000ff000ff00000000000000f0000f00f00f0000f0000000fff0fffffffff0fff0000fff00000000000000000000fffffffff000000000000000000000000
0000000ff00ff00000000000000f000f000f000f000f0000000ffff0fffffff0ffff0000ff0000000000000000000000fff00fff000000000000000000000000
00000000fffffff000000000ffffffffffffffffffffffff0000fff0fffffff0fff00000ff0000000000000000000000ff0000ff000000000000000000000000
000000000fffffff00000000000f000f000f000f000f00000000ffff00fff00ffff00000ff0000000000000000000000ff0000ff000000000000000000000000
000000000000000ff0000000000f0000f00f00f0000f000000000fffff000fffff000000ff0000000000000000000000fff00fff000000000000000000000000
00000000000ff000ff0000000000f000ff0f0ff000f00000000000fffffffffff0000000ff0f00f0ffff0f000f00fff0ffffffff000000000000000000000000
00000000000ff0000ff000000000f00000fff00000f000000000000fffffffff00000000ff0ff0f0f0000f000f0f0000fff00fff000000000000000000000000
000000f0000ff0000ff0000000000f00000f00000f000000000000f00fffff00f0000000ff0f0ff0fff00f000f00f000ff0000ff000000000000000000000000
000000ff000ff000ff000000000000f0000f0000f0000000000000fff00000fff0000000ff0f00f0f0000f0f0f000f00ff0000ff000000000000000000000000
0000000ff00ff00ff00000000000000ff00f00ff00000000000000fffffffffff0000000ff0f00f0f0000ff0ff0000f0fff00fff000000000000000000000000
00000000ffffffff00000000000000000fffff0000000000000000fffffffffff0000000ff0f00f0ffff0f000f0fff00ffffffff000000000000000000000000
000000000ffffff00000000000000000000f000000000000000000fffffffffff0000000ff0000000000000000000000ffffffff000000000000000000000000
00000000000000000000000000000000000f000000000000000000fffffffffff0000000ff0000000000000000000000ffffffff000000000000000000000000
00000000000ff0000000000000000000000f000000000000000000fffff0fffff0000000ff0000000000000000000000ffffffff000000000000000000000000
00000000000ff00000000000000000000000000000000000000000ffff000ffff0000000ff0000000000000000000000ffffffff000000000000000000000000
000000000000000000000000000000000000000000000000000000fff00000fff0000000fff00000000000000000000fffffffff000000000000000000000000
000000000000000000000000000000000000000000000000000000ff0000000ff0000000fffff0000000000000000fffffffffff000000000000000000000000
000000000000000000000000000000000000000000000000000000f000000000f00000000ffffffffffffffffffffffffffffff0000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffff000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000ffff000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000f000000000fffff000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ff000000000ffffff00000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000ffffff000000000fffffff0000000000000000000000000000000000000000000000000000000000000000000000000000
000000ff0000000000ffffffffffffffffff00000000ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000
000000ffff00000000ffffffffffffffffff00000000ff0fffff0000000000000000000000000000000000000000000000000000000000000000000000000000
000000fffff0000000ffffffffffffffffff00000000ff00fff0000000ffff000000000000000000000000000000000000000000000000000000000000000000
000000ffffff000000ffffffffffffff00ff00000000ff000ff0000fffffff000000000000000000000000000000000000000000000000000000000000000000
000000f0ffff000000fffffffff0000000ff00000000f0000f00000fffffff000000000000000000000000000000000000000000000000000000000000000000
000000f000ff000000ff00000000000000ff0000000ff0000000000fffffff000000000000000000000000000000000000000000000000000000000000000000
000000f0000f000000ff00000000000000ff0000000ff0000000000ffff000000000000000000000000000000000000000000000000000000000000000000000
000000f00000000000fff000000000000fff0000000ff0000000000000f000000000000000000000000000000000000000000000000000000000000000000000
000000f000000000000ff000000000ff0fff000000ff00000000000000f000000000000000000000000000000000000000000000000000000000000000000000
000ff0fff00ff000000ff00000000fff0ff0000000ff000000ff000000f000000000000000000000000000000000000000000000000000000000000000000000
ff0ff0ffff0ff00f000ff00f000000fffff0ff00f0ff000000ff0f0ff0fff0000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffff0ffffff0fff0f0fffffffffff0ffffff0f0ffffffff0ffff0f0000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0f0000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000
fff0fffffffffffffffffffffffffffffffffffffffffffff0fffffff0ff0f0f0000000000000000000000000000000000000000000000000000000000000000
f0f0f0fffffffffffffffffffffffffffff0f0f0fffffffff0fffff0f0ff0f000000000000000000000000000000000000000000000000000000000000000000
f0f0f0fffffffffffff00ffffff0ffffff00f0f0ff0ff00ff0f0fff0f0f00ff00000000000000000000000000000000000000000000000000000000000000000
f0f000ffffffffff0f000ff0ff00ffffff00000fff0fff000ff0ff0000ff0ff00000000000000000000000000000000000000000000000000000000000000000
00000ff00fff0ff000000ff0ff000fffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ff00fff0000fff0fff00ff0ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000fff00000000000000000fff0fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
013200001305018050130501305015050130501105010050130500000013050150501a05018050170501505017050180500000000000000000000000000000000000000000000000000000000000000000000000
0114000010050100500d0500905009050090500d0500d0500d050100501005010050150501505015050150501905019050170501505015050150500d0500d0500d0500f0500f0500f05010050100501005010050
011400000a0500a05007050070500c0500c0500c0500705007050070500705000000000000a0500a05007050070500c0500c0500c050070500705007050070500000000000000000000000000000000000000000
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
