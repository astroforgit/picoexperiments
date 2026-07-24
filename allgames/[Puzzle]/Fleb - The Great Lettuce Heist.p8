pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- fleb written by sorcery inc.
-- release march 28th, 2020.

-- standard Š pico-8 license

-- written by the staff:
-- zoraaa, scrub, chizel,
-- cable, and dw817.

-- eliminate all of the king's
-- evil army and collect as
-- much lettuce as you can!

-- game automatically saves
-- your progress and will
-- continue where you left off.

-- make it through the levels
-- to read all of the story.
-- win and see the great
-- original artwork for the
-- ending!

function main() ------------->>
init()
_once=1
::top::
debug=0
cls()
if debug==1 then
  goto skip
end
gabslam()
palt(0,_0)
for i=128,48,-1 do
  sspr(0,0,128,32,0,i)
  pause(2)
end
palt(0,_1)
for i=2,32,2 do
  sspr(0,64,32,32,64-i/2,32-i/2,i,i)
  pause(12)
end
repeat
for i=48,79 do
  for j=0,127 do
    if pget(j,i)>0 then
      pset(j,i,9)
      if rnd()<.25 then
        pset(j,i,10)
      end
    end
  end
end
rectfill(0,90,127,127,0)
d=dget(0)
print("last level achieved="..d,20,110,6)
lv=d+1
if dget(1)<d then
  dset(1,d)
end
d=dget(1)
print("best level achieved="..d,20,100)
print("— erase scores or Ž begin:",6,90)
if btn(5) then
  ok=1
  for i=0,127 do
    pset(i,127,8)
    flip()
    if btn(5)==_0 then
      ok=0
      break
    end
  end
  if ok==1 then
    dset(0,0)
    dset(1,0)
    sfx(0)
  end  
end
flip()
if _once==1 then
  music(0)
  _once=0
end
until btnp()>0
::skip::
  ord={} seek={}
  for i=1,357 do
    ord[i]=i
  end
  for i=0,356 do
    t=flr(rnd(#ord))+1
    seek[i]=ord[t]-1
    del(ord,ord[t])
  end
hp=3
repeat--level
if lv==0 then
  lv=1
end
dset(0,lv-1)
playerhit=0
storyl={} storyl[0]=""
l=0
for i=1,#story[lv] do
  c=sub(story[lv],i,i)
  if c>="a" and c<="z" then
    c=low[encfr[c]]
  elseif c=="\10" then
    l+=1
    storyl[l]=""
  end
  if c>=" " then
    storyl[l]=storyl[l]..c
  end
end
if debug==0 then
  tellstory()
  pause(32,1)
  rocket=0
  cls()
  nokey(2)
end

if lv==11 then
  wongame()
end
--this guys got his french fries
--and he be like "woah man! them
--tasty fries dawg". crazy yo.
music(1)
tile=decompres(lev[lv])
tile[px][py].hp=hp
repeat
pdm=0
cux=-1
repeat
busy=0
update()
if stat(16)==-1 and ctf==0 then
  --goto leveldone
end
getkey()
if btnd[5] then
  ssfx(11)
  if cux>0 then
    cux=-1
  else
    cux=px
    cuy=py
  end
end
if btnd[4] then
  ssfx(13)
  pdm=1
end
if cux<0 then
  for i=0,3 do
    if btnd[i] then
      ssfx(2)
      x=mov[i*2] y=mov[i*2+1]
      j=tile[px+x][py+y].id
      ok=1
      if j>0 then
        if j>2 and j<=9 then
        jj=j
          if j==8 or j==9 then
            doscramble=1
          end
          ok=0
          ssfx(1)
          tile[px+x][py+y].hp-=1
          if tile[px+x][py+y].hp==0 then
            tile[px+x][py+y].id=1
            boomkit(px+x,py+y,1,1,0)
            update()
            if ctf==0 then
              music(5)
              tile[px][py].pu=0
              hp=tile[px][py].hp
            end
          else
            glox=px+x
            gloy=py+y
            update()
            pause(2)
            glox=-1
          end
        end
        if ok==1 then
          tile[px+x][py+y]=copy(tile[px][py])
          tile[px][py].id=1
          px+=x py+=y
          if j==11 then
            ssfx(21)
            flameon(px,py,1)
            tile[px][py].pu=1
            tile[px][py].hp+=2
          end
        end
        pdm=1
      end
    end
  end
else
  for i=0,3 do
    if btnd[i] then
      ssfx(13)
      cux+=mov[i*2]
      cuy+=mov[i*2+1]
      cux=mid(0,cux,16)
      cuy=mid(0,cuy,20)
    end
  end
end
until pdm==1 or ctf==0
busy=1
for i=0,1 do
  for j=0,356 do
    x=seek[j]%17
    y=flr(seek[j]/17)
    if i==1 then
      tile[x][y].dm=0
    elseif tile[x][y].dm==0 then
      tile[x][y].dm=1
      t=tile[x][y].id
      if t>3 and t<9 then
        for k=1,5 do
          glox=-1
          if k%2==0 then
            glox=x
            gloy=y
          end
          update()
          pause(3)
        end
        coma="."
        t=wordno(tile[x][y].sc,tile[x][y].sp)
        tile[x][y].sp+=1
        if wordno(tile[x][y].sc,tile[x][y].sp)=="" then
          tile[x][y].sp=1
        end
        coma=","
        for k=1,#t do
          ti=copy(tile[x][y])
          d=ti.df
          x2=x+mov[d*2]
          y2=y+mov[d*2+1]
          c=fnc(t,k)
          if c=="s" and tile[x2][y2].id==1 then
            tile[x2][y2].id=8
            tile[x2][y2].sn=64
            tile[x2][y2].df=3
            tile[x2][y2].hp=1
            tile[x2][y2].dm=1
            tile[x2][y2].pu=0
            tile[x2][y2].na="king"
            tile[x2][y2].sc="m"
            tile[x2][y2].sp=1
            ssfx(30)
          elseif c=="f" then
            ssfx(23)
            shoot(x,y,d)
          elseif c=="l" then
            ssfx(6)
            tile[x][y].df=fal[tile[x][y].df]
          elseif c=="r" then
            ssfx(6)
            tile[x][y].df=far[tile[x][y].df]
          elseif c=="m" then
            xl=x+tul[d*2]
            yl=y+tul[d*2+1]
            xr=x+tur[d*2]
            yr=y+tur[d*2+1]
            ta=tile[x2][y2].id
            tl=tile[xl][yl].id
            tr=tile[xr][yr].id
            ox=x
            oy=y
            if ta+tl+tr==0 then
              tile[x][y].df=fao[d]
            else
              repeat
                ok=1
                g=flr(rnd(3))
                if (g==0 and ta==0) or (g==1 and tl==0) or (g==2 and tr==0) then
                  ok=0
                end
              until ok==1
              if g==0 then
                if x2==px and y2==py then
                  playerhit=1
                  break
                end
                if tile[x2][y2].id==1 then
                  tile[x2][y2]=copy(ti)
                  tile[x][y].id=1
                  x=x2
                  y=y2
                elseif tile[x2][y2].id==11 then
                  tile[x2][y2]=copy(ti)
                  tile[x][y].id=1
                  x=x2
                  y=y2
                  tile[x2][y2].pu=1
                  ssfx(21)
                  flameon(x2,y2,0)
                  tile[x2][y2].hp+=2
                end
              elseif g==1 then
                if xl==px and yl==py then
                  tile[x][y].df=fal[d]
                  playerhit=1
                  break
                end
                if tile[xl][yl].id==1 then
                  tile[xl][yl]=copy(ti)
                  tile[x][y].id=1
                  x=xl
                  y=yl
                  tile[xl][yl].df=fal[d]
                end
              elseif g==2 then
                if xr==px and yr==py then
                  tile[x][y].df=far[d]
                  playerhit=1
                  break
                end
                if tile[xr][yr].id==1 then
                  tile[xr][yr]=copy(ti)
                  tile[x][y].id=1
                  tile[xr][yr].df=far[d]
                end
              end
            end
          end
          update()
          if k<#t then
            pause(12)
          end
        end
      end
    end
  end
end
if playerhit>0 then
  a=1
  tile[px][py].hp-=playerhit
  if tile[px][py].hp<=0 then
    gameover()
    goto top
  else
    n=5
    a=0
    if playerhit==2 then
      n=24
      a=4
    end
    boomkit(px,py,a,0,n)
  end
  playerhit=0
end
playerhit=0
pdm=0
if doscramble==1 and ctf>0 then
  scramble()
end
until ctf==0 and quiet()==true
lv+=1
doscramble=0
until forever
end--<<------------------------

function wongame()
  sfx(-1)
  music(19)
  decompresscrn(picwin)
  memcpy(0,24576,8192)
  clip(0,5,127,118)
  i=124
  scrub=0
  repeat
    memcpy(24576,0,8192)
    for j=0,25,2 do
      print(cred1,5+outl[j],i+outl[j+1],0)
      print(cred2,5+outl[j],i+outl[j+1],0)
    end
    print(cred1,5,i,7)
    print(cred2,5,i,scrub%6+8)
    flip()
    i-=.25
    scrub+=0.2
    if i<-332 then
      i=-332
    end
    if i==-332 and btnp(5) then
      run("")
    end
  until forever
  
end


function scramble()
local ti,x,y,c=copy(tile)
  sfx(29)
  for i=1,250 do
    for j=1,300 do
      x=rand(0,127)
      y=rand(0,127)
      c=pget(x,y)
      pset(x+rand(-1,1),y+rand(-1,1),c)
    end
    flip()
    if quiet() then
      break
    end
  end
  ti[px][py].id=1
  for t=0,1 do
    for i=-1,21 do
      for j=-1,17 do
      jj=j
      ii=i
        if t==0 then
          if tile[j][i].id>1 then
            tile[j][i].id=1
          end
        else
          if ti[j][i].id>1 then
            repeat
              x=rand(0,16)
              y=rand(0,20)
            until tile[x][y].id==1 and (x!=px or y!=py)
            tile[x][y]=copy(ti[j][i])
            tile[x][y].dm=1
          end
        end
      end
    end
  end
  tile[px][py].id=3
  doscramble=0
end
function shoot(xx,yy,d)
local a,b,ppx,ppy,x,y=0,.1,px*7+6,py*5+12,xx*7+3,yy*5+10
  for i=1,99 do
    update()
    spr(90+flr(a/8),x,y)
    a=(a+1)%16
    b=b*1.05
    if d==0 then
      x=x-b
    elseif d==1 then
      x=x+b
    elseif d==2 then
      y=y-b
    else
      y=y+b
    end
    if abs(x-ppx)<=3 and abs(y-ppy)<=2 then
      playerhit=2
      break
    end
    flip()
  end
  flp()
end
    
function gameover()
  boomkit(px,py,8,1,24)
  rectfill(0,0,127,8,2)
  color(15)
  for i=1,0,-1 do
    print("g a m e   o v e r",30+i,2+i)
    color(8)
  end          
  music(-1)
  music(20)
  repeat
    flip()
  until btnp(Ž) and quiet()==true
end
function flameon(x,y,typ)
local n
  for i=0,15 do
    update()
    for j=0,5 do
      n=(j+i)%7
      if typ==0 then
        pal(n+1,flra[j])
      else
        pal(n+1,flba[j])
      end
    end
    sspr(96,72,16,16,x*7-1,y*5+5)
    pause(8)
  end
end
function quiet()
  return stat(16)<0
end
function boomkit(xx,yy,si,sp,sx)
local dot,b,s,x,y,n={},{},0
  n=tile[xx][yy].sn
  sp=1-sp
  x=n%16
  y=flr(n/16)
  update(xx,yy)
  for i=0,7 do
    for j=0,7 do
      for k=0,si do
        if sget(x*8+j,y*8+i)>0 then
          b={}
          b.x=3+xx*7+j
          b.y=8+yy*5+i
          b.ax=-.25+rnd(.5)
          b.ay=-.25+rnd(.5)
          add(dot,b)
        end
      end
    end
  end
  for i=sp*32,176-sp*32 do
    if si==0 or si==4 then
      update()
    else
      update(xx,yy)
    end
    for j in all(dot) do
      pset(j.x,j.y,(j.x+j.y+i)%15+1)
      if i==32 then
        ssfx(sx)
      end
      if i>31 then
        j.x+=j.ax
        j.y+=j.ay
        j.ax*=1.03
        j.ay*=1.03
      end
    end
    flp()
  end
end
function tellstory()
  music(9)
  rocket=1
  if lv>1 then
    rocket=2
  end
  cls()
  print("hit (x) to skip storytime",14,0,7)
  line(0,96,127,96,4)
  for i=0,126,2 do
    line(i,8,i,70+rnd(8),1)
    pause(10)
  end
  for i=1,2000 do
    pset(flr(rnd(64))*2,8+rnd(80),0)
    if i%100==0 then
      pause(10)
    end
  end
  rectfill(0,0,127,5,0)
  l=-1
  x=0
  y=-1
  s=0
  dream=0
  f=0
  color(7)
  rocket=1
  for i=1,#storyl do
    x=0 y+=1 l+=1
    sspr(56,56,8,8,48,79,16,16)
    sspr(56,72,8,8,64,79,16,16)
    for j=1,#storyl[l] do
      c=sub(storyl[l],j,j)
      if x==0 then
        if c=="*" then
          dream=.001
          c=""
        elseif c=="0" or c=="1" then
          s=tonum(c)
          x=-2
          y=0
          f=0
          c=""
          repeat
            spr(158+f,120,120)
            pause(1)
            f=(f+.0625)%2
          until btnp(4) or rocket==2
          nookey=1
          f=0
          rectfill(0,98,127,127,0)
        end
      end
      print(c,x*4+2,100+y*6,13+s)
      if (storyl[l+1]>"" or j<#storyl[l]) and (c=="," or c=="." or c=="-" or c=="!" or c=="?" or c==";") then
        pause(16)
      end
      if s==0 then
        sspr(56+(f%3)*8,56,8,8,48,79,16,16)
        if c>="\65" and c<="\90" then
          ssfx(14+rnd(2),3)
        end
      else
        sspr(56+(f%3)*8,72,8,8,64,79,16,16)
        if c>="\65" and c<="\90" then
          ssfx(16+rnd(2),3)
        end
      end
      f=1+flr(rnd(2))
      if dream>0 then
        sspr(0,64,32,32,64-dream,32-dream,dream*2,dream*2)
        dream+=.05
      end
      x+=1
      pause(2+rnd(5))
    end
  end
  nokey()
end--tellstory()
function pause(n,o)
  if rocket==2 then
    return
  end
  if rapid>0 and o==nil then
    n=0
  elseif o!=nil then
    rapid=0
  end
  for i=1,flr(n) do
    if rocket==1 then
      if btn(4) and nookey==0 then
        rapid=5
      elseif btn(5) then
        rocket=2
      elseif btn(4)==false then
        nookey=0
      end
    end
    flp()
  end
  if (rapid>0) rapid-=1
end
function flp()
  flip()
  holdframe()
end
function message(t)
  ssfx(25)
  for i=1,32 do
    t=" "..t.." "
  end
  mesg=t
  mesp=-1
end--message(.)
function update(ix,iy,fl)
local c,t,a,aa,bb,v,x,y
  ctf=0
  cls()
  rectfill(0,0,127,8,1)
  rectfill(0,117,127,127,1)
  if mesp<0 then
    print(sub(mesg,1+(-mesp-1)/4),mesp%4,2,13)
    mesp-=1
    if mesp-128<-4*#mesg then
      mesp=0
    end
  else
    t="fleb the great lettuce heist"
    print(t,9,3,0)
    print(t,8,2,7)
  end
  for z=0,2 do
    for i=0,20 do
      for j=0,16 do
        if j!=ix or i!=iy then
          x=j*7+4
          y=i*5+6
          c=107
          t=tile[j][i].id
          if (t==1) c=108
          if (t>1) c=109
          if (t==9) c=75
          if z==0 then
            spr(c,x,y+6)
          end
          if t>1 and z>0 then
            if t!=9 then
              a=2
              v=tile[j][i].bo
              if (t==3 or t==11) a=3 v=0
              tile[j][i].bo=(tile[j][i].bo+rnd()/20)%2
              if z==1 then
                c=tile[j][i].a
                if t>2 then
                  if j==glox and i==gloy then
                    glow=1
                  end
                  c=tnum(tile[j][i].sn)
                  if c!=112 and c!=74 then
                    ctf+=1
                  end
                  ospr(c+tile[j][i].pu*2,x-1,y+a+v)
                  glow=nil
                end
              elseif t<11 and t>3 then
                c=tile[j][i].df
                spr(122+c,x+tic[c*2]-1,y+a+v+tic[c*2+1])
              end
            end
          end
        end
      end
    end
  end
  if tex!=nil then
    print(tex,64-#tex*2,120,10)
  end
  if cux>=0 then
    sspr(80,72,16,16,cux*7-1,cuy*5+6)
    d=tile[cux][cuy].na
    if d>"" and tile[cux][cuy].id!=1 then
      spr(149,3,119)
      print(tile[cux][cuy].na,13,120,13)
      if d=="king" then
        d=0
      else
        d=tile[cux][cuy].hp
      end
      if d>0 then
        spr(150,48,119)
        print(d,56,120,13)
      end
    else
      print("scanning...",4,120,13)
    end
  else
    print("lv:"..lv,107,120,13)
    print("fleb:"..ctf,75,120,13)
    spr(150,48,119)
    d=tile[px][py].hp
    if d<0 then
      d=0
    end
    print(d,56,120,13)
  end
  if busy==1 then
    spr(180,2,119)
  end
end--update()
function waitkey()
local c=0
  repeat
    getkey()
    if ankey then
      c=0
    end
    c+=1
    flp()
  until c==32
  repeat
    getkey()
  until anykey
end
function nokey(n)
local a
  if rocket==2 then
    return
  end
  if n==_n then
    n=0
  end
  for i=n,2 do
    repeat
      flip()
      a=btn()==0
      if (i==1) a=btn()>0
    until a
  end
  rapid=0
end
function getkey()
  anykey=_0
  for i=0,5 do
    btnd[i]=_0
    if btn(i) then
      btnc[i]+=1
      if btnc[i]%16==1 then
        btnd[i]=_1
        anykey=_1
      end
    else
      btnc[i]=0
    end
  end
  flp()
end--getkey()
function decompres(t)
local tile,x,y,c,d={},0,0,0
  for j=-1,17 do
    tile[j]={}
    for i=-1,21 do
      tile[j][i]={}
      tile[j][i].id=0
      tile[j][i].sn=0
      tile[j][i].na=""
      tile[j][i].bo=rnd(2)
      tile[j][i].df=0
      tile[j][i].sc=""
      tile[j][i].sp=0
      tile[j][i].hp=0
      tile[j][i].pu=0
      tile[j][i].dm=0
    end
  end
  for i=1,#t do
    c=asc6[sub(t,i,i)]
    if c>=17 then
      for j=1,c-16 do
        x+=1
        if x==17 then
          x=0
          y+=1
        end
      end
    else
      if (c==3) px=x py=y
      tile[x][y].id=c
      d=tnum(wordno(fleb[c-2],1))
      tile[x][y].sn=d
      d=tnum(wordno(fleb[c-2],2))
      tile[x][y].hp=d
      d=wordno(fleb[c-2],3)
      if c==9 then
        d="exit"
        tile[x][y].hp=0
      end
      tile[x][y].na=d
      d=wordno(fleb[c-2],4)
      tile[x][y].sc=d
      tile[x][y].sp=1
      
      tile[x][y].df=3
      x+=1
      if x==17 then
        x=0
        y+=1
      end
    end
  end
  return tile
end--decompres(.)
function decompresscrn(t)
local b,p,c,n=0,1,0,0
  holdframe()
  for i=-1,16383 do
    if n>0 then
      n-=1
    else
      c=0
      for j=0,7 do
        if band(asc6[sub(t,p,p)],2^b)>0 then
          if j<4 then n+=2^j else c+=2^(j-4) end
        end
        b+=1 if (b==6) p+=1 b=0
      end
    end
    pset(i%128,i/128,c)
  end
end
function ospr(c,x,y)
  for i=1,15 do
    pal(i,0)
  end
  for i=0,8 do
    if i==8 then
      if glow==1 then
        for j=1,15 do
          pal(j,7)
        end
      else
        pal()
      end
      pal(15,0,1)
    end
    spr(c,x+out[i*2],y+out[i*2+1])
  end
  pal()
  pal(15,0,1)
end--ospr(...)
function wordno(t,a)
local r,n,c="",1
  if (t==_n) return ""
  t=t..coma
  for i=1,#t do
    c=sub(t,i,i)
    if c==coma then
      if (n==a) return r
      r="" n+=1
    else
      r=r..c
    end
  end
  return ""
end--wordno(..)
function tnum(a)
local r=tonum(a)
  if (r==nil) r=0
  return r
end--tnum(.)
function pad(a,b)
  a=""..a
  if #a<b then
    for i=1,b-#a do
      a="0"..a
    end
  end
  return a
end--pad(..)
function copy(t)
local c
  if type(t)=="table" then
    c={}
    for i,j in next,t,nil do
      c[copy(i)]=copy(j)
    end
    setmetatable(c,copy(getmetatable(t)))
  else
    c=t
  end
  return c
end
function mysgn(a)
  if (a==0) return 0
  return sgn(a)
end
function rand(a,b)
  if (a>b) a,b=b,a
  return a+flr(rnd(b-a+1))
end--rand(..)
function fnc(a,b)
  return sub(a,b,b)
end
function init()
cartdata("sorcery_fleb")
if dget(63)!=1234.5678 then
  dset(63,1234.5678)
  dset(0,0)
  dset(1,0)
end
storytime()
  _set_fps(60)
  _n=nil _0=false _1=true
  nookey=0
  rapid=0
  pal(1,129,1) pal()
  pal(15,0,1) palt(15,_0)
rbow={[0]=13,8,9,10,11,12}
  coma=","

outl={[0]=-1,-1,0,-1,1,-1,-1,0,1,0,-1,1,0,1,1,1,2,0,2,1,2,2,1,2,0,2}

mesg="" mesp=0
out={[0]=-1,-1,0,-1,1,-1,-1,0,1,0,-1,1,0,1,1,1,0,0}
flra={[0]=4,8,14,7,14,8}
flba={[0]=1,13,12,7,12,13}
  chr6,asc6,char6={},{},"abcdefghijklmnopqrstuvwxyz.1234567890 !@#$%,&*()-_=+[{]};:'|<>/?"
  for i=0,63 do
    c=sub(char6,i+1,i+1)
    chr6[i]=c asc6[c]=i
  end char6=nil
picwin="aa=q6<[tp>[tp>[q6meiabcq7a[l)<=l)<=l9auiab8q6eeip>[tp>[tpneibb8q6eeia{biqace6abiqcc06ajiqcc06ahiqghiqcc06abiqachq,feq?vuq-fe.beibbsq6aeia{biqace6abiqac06ajiqcc06aj3qcc06ajiqace6&b[.bb[5ffe2b_wabcq6aeiabcq5ubiqac06ajiqcc06a$2qcc06ajiqcce6abi.a>wq<vuq-fe2beiabcq6a[f-:biqac06aji2ace6<_gr{ruq-feznbq6eeia>bg6abiqcceq)he6ab[[b>fq)xeq)h[qafeq>_fsbeibbcq52biqace6aje}r*e]3_3uhb4sh@f5nfesbeibbcq56biqace6a_3udbiqy}f}r3e;j32qq*e5ffesbeibbcq5;_3xyxe-r_3uafe;jr2qmfesd_xqb7uabsq6auh->_3vace]3_3uafe;jr2qmfesbne5b7uabsq6a[h4-@e]3b5r-h[refetbne5b7uabsq6a[h42h{sy}f}r3e>fruqqf[q;fesbeibbcqsa}hwa@e}r*e]3_3uhb4shxftfrxqmfq6eeia>7h}373quce}rbuq6@[_bbbqeferdbxqmfq6eeia>bh6a_3qace9a73x2heubb4seheferuqdbxqmfq6eeia3_l0e_3xy}f}rbuq6@e_b7bqef[q-fetbeibbcq@<bf6a_3race6abiq-xe<fr5qyaesbne1b_uabsq6aeg6abiqace6abiqace6abiqace6i_{x-3e2hr}qyaetb_wqifeabsq6aee6abiqace6<bfqd_{qune2hb}r[nega_u5abuabsq6a[f5l>h5<_hha_uqefe3beibbcq5#bn{g_[q<ne5dnerhverdrcqmferbrxabsq6au[q<>e|q,eqd_}qi3xqa*uqa3uq0qfrbrxabsq6au[q[*e?ed*r<feq?feqlfeqhfeja_[qefe3beibbcqr9r[qj_p]mlgybb[4bb[rbb[sbrcqiv[qafe3beibbcqsm+&s<dp=crm+krvqa*xqa3uqa*uq0aetbneqbrxabsq6aeo[k_p'i1e_q,esbb[4bb[rb7uq&aetbbuq[fq6eeia$t*r<9o=c7m[w6xqa3uqevela_ur;fq6eeia{d*?<tmbad&aax&=faxqa3uqafeqd_cseve4beibbcq?ad&?<dmbal2ba@*-baxqefeqbb[q&aerp7xabsq6a[p?<tmaih&_f,m+caxqeveqdfelarurh7xabsq6a[p?<tmaah&=m1m_gd&a&ferbb[rb_cqmve4beibbcq?<+p-eq&_e1m_kd&-ala1bruqa3uq&aetf7xabsq6a[p?<da[cd&[al2_ila.bruqa3u3mve4beibbcq?<9paa@m-ct&-ah&_el2-alm_cqwqeferbb{qeneuhru5abq6eeia>+p/aa&_a1n-cxm_ch&-el2a-buqqfetbrvqafexn_&absq6a[p?;da=kt&=a|m-kt&-b6w5ybvs2lq6eeia>+p?aq&_a,m-gd&]ilaq< uq<fuq#dq6eeia>+p>m-&=elo_ctaq<vuq;ve|aeibbcq?<+obmha-cd&[a1m{cta_f-xqbbxr[dq6eeia>+p'aa26rxa_2,mcmhy-bae4b_wq<dq6eeia>+p|aa28nhd+jg2aele3brwr<dmabsq6a[p?-da=f]5-f!2aa9&q-fgqb_p=aeibbcq?<tpce}16f@a+eleyj_m[o_p-aeibbcq?<+mo<h2nm e;yle?aeibbcq?<+mamf[aq>ddmnaulfarf7p[c7pabsq6aeoq<toai [ae3a9bq{aqnaudga8j3uae_p[e,pabsq6aeoq<dnqmdarnna6bna0ba[9bnarhg[am3yamw[rba&q<+p{aeibbcq;arpqude[aautdqyaqga ba[9bnarhga fnuaede?<dnabsq6aeoq[de{abnaa [6bayauga bqzbiga fna=a_p?qdq6eeia7de>arnqqdaqj3ybuga bqzaawa6bqzrd6mq<+p[aeibbcq--boqyde[aaurlwa6vqzauga8fqzrd-p?6dq6eeia>be{a7nqmtaqfnyemgaqxga b-yauw[f<+p+aeibbcq5i_mqm+b-aaurdga@ba[ bqzamga bnuaq+a?<dq6eeia>7ei6daqfnya2gaqxga b-yaug[a09a?-dq6eeia*7b-abmq;daqbna#ba[ bqzqlayaqw[a-tb?ydq6eeiar7btade-abmq<daqbna#ba[ b6zae!a8jna?i+a?idq6eeiaf7azade-abmqade/aquae!bqdg[0b6yqlga0f6[qb-p+abmqi-pabsq6aua3ade-abmq<tb ba[6bnyqlgaqhg[7bna bq[qb-p+abmqade-a7a}a_mabsq6a0h-abmqade-abpca3.aanyqdg[8ba[7b3yqdga0bq[qb-p[abmqade-i_a+a_mabsq6a[h-abmqade>aauq,gaudg[6ba{6bnygenuaa|p=abmqade-2ra_a_mabsq6a0h-abmqade<almaa3yjaf{6bnya2na0ram-/9mqade-abmyeae+aeibbcq5ade-abmq#d&-qa.aa {6bq{qbna fnuaalm-cd&/abmqade-&ra=aeibbcq4ade-abmq6d&daf[,ba]ainuqhf[qbazrdfa_cd&-alm-=de-abmqadhcaeibbcq5ade-a7oaif[&bq[rrnaspf[qrayrdfa[cd&-a,oqade-abm5abq6eeia:bmqade-abo-cqur+gardferjnashfeqfna9zq*-a,oqade-abm5aeibbcq3ade-abmqade]elaqjnylav[sb7[ainesfna!n>a-cd&-aloqade-abm5abq6eeia:bmqade-a7n-c9b%baurdf[rjnashf[qfna@j*uaelm_!de-abm5ebq6eeia{bmqade-abmqq9aqv*.aunusd6[qrnujmfa=cd&-a,nqade-abm5abq6eeia:bmqade-arnamf{%bq[rvnaudf[rbna@bnc-aloqade-<reabsq6auh-abmqade-abnaqf{$bq[qbnuqd [aa3uqdv[qfna#n>uaalm-.de-abmqa+hqaeibbcq4ade-abmqudbr3nzaev{qbnuaaf[qb3utda.sxfa-8de-abm5ebq6eeia{bmqade-abmqy9&jqnarnnutda]rb-yttfb-a,nqade-abm5abq6eeia:bmqade-a7n-c+(gmv{a2*uamnc+cd&;abmqa+hraeibbcq3ade-abmqade]alm?g,atjnatt b|cd&-a,nqade-abm5abq6eeia:bmqade-a7n-cd&-<|&cmfaun-)+cd&;abmqa+hraeibbcq3ade-abmqade]alm?4,aqbaud<,*-aloqade-abm5abq6eeia:bmqade-abmqyd&-<1(c<|(;abmqade-<reabsq6auh-abmqade-abo-cd&-<|)?c,c+abmqade-<beabsq6a0h-abmqade-abo-cd&-alm?/|(bubc-abmqa+hraeibbcq5ade-abmq#d&-alm-cd&-<|){kafp<7eabsq6a0h-abmqade-abp-cd&-alm-c+)?c1au<ab5abq6eeia>bmqade-abmq;d&-alm-cd&-<1*im_dji_bsaeibbcq5abmqade-abmq<9m-cd&-alm-cd&-&,ati6ep<-egaeibbcq5ebmqade-abmq<dn-cd&-alm-cd&-alm-cd&-iafdi_dnqbcabsq6a[hsade-abmqade?#d&-alm-cd&bu_as<adv#aq6eeia>re-abmqade-abmq<+paq_dpqafnaeibbcq5ibmqade-abmqade?-tas<-dia_daaeibbcq5mbmqade-abmqade?#das<-dp-aq6eeia>bf-abmqade-abmqade?2dar<-dp[aq6eeia>_e-abmqade-abmqade-a_p{aqep<-doaeibbcq5qbmqade-abmqade-abmqade?etaq<-dp<aq6eeian-htade-abmqade-abmqade?aqep<-dpaaq6eeian_a5abmqade-abmqade-abmqade|aqep<-dpeaq6eeia37a4ade-abmqade-abmqade-abop<-dpyaq6eeia*6h-abmqade-abmqade-abmqade-abmqeqep<-dpqaq6eeia{-g-abmqade-abmqade-abmqade-abmqa-ep<-dpqaq6eeia>6g-abmqade-abmqade-abmqade-abas<-dp<6babsq6a[da-bmqade-abmqade-abmqatar<-dp<acabsq6a[dc[bmqade-abmqade-a6ep<-dp0aq6eeia>-aq6qf-abmqade-a6ep<-dp#aq6eeia>abuyqf-abmae_dp<-dmaeibbcqpa6flqbar<-dp<qdabsq6a[du<aaraqep<-dp;aq6eeia:qepyqep<-dp<aq6eeia>-dga_dp<-dpeaq6eeia>-dp<-dp<qcabsq6a[dp<-dp<-djaeibbcqp<-dp<-dp0aq6eeia>-dp<-dp<qcabsq6a[dp<-dp<-djaeibbcqp<-dp<-dp0aq6eeia>-dp<-dp<qcabsq6a[dp<-dp<-djaeibbcqp<-dp<-dp0aq6eeia>-dp<-dp<qcabsq6a[dp<-dp<-djaeibbcqp<-dp<-dp0aq6eeia>-dp<-dp<qcabsq6a[dp<-dp<-djaeibbcqp<-dp<-dp0aq6aeiabcqp<-dp<-dp2aq6aeiabcq6a[dp<-dp<-dfaeiabsq6eeia>-dp<-dp<-aabsq6ieibb=tp>[tp>[tdbsq6ieiafcq)<=l)<=l)mcq7aeiab=q6<[tp>[tp>[q6meia"
playername="redboi"
lowc="\65\66\67\68\69\70\71\72\73\74\75\76\77\78\79\80\81\82\83\84\85\86\87\88\89\90"
upp="abcdefghijklmnopqrstuvwxyz"
enc="oawqtjesdbxglhnipcymkfvzru"
low={} encto={} encfr={}
for i=1,26 do
  c1=sub(upp,i,i)
  c2=sub(enc,i,i)
  low[c1]=sub(lowc,i,i)
  encto[c1]=c2
  encfr[c2]=c1
end
fleb={}
fleb[0]=""
fleb[1]="112,0,"..playername
fleb[2]="096,1,clonk,m"
fleb[3]="070,2,mite,mm"
fleb[4]="086,2,snider,f.n.n.n.m"
fleb[5]="080,3,stan,n.f.m"
fleb[6]="064,7,king,srsllsrrrm.m.m.m.m.m.m.m.m"
fleb[7]="064,8,king,m"
fleb[9]="074,0,lettuce"
  tic={[0]=-7,2,7,2,0,-5,0,8}
  mov={[0]=-1,0,1,0,0,-1,0,1}
  tul={[0]=0,1,0,-1,-1,0,1,0}
  tur={[0]=0,-1,0,1,1,0,-1,0}
  opp={[0]=1,0,-1,0,0,1,0,-1}
  fao={[0]=1,0,3,2}
  fal={[0]=3,2,0,1}
  far={[0]=2,3,1,0}
getlevels()
  btnc={} btnd={}
  for i=0,5 do
    btnc[i]=0
    btnd[i]=_0
  end
end--init()
function getlevels()
lev={}
lev[01]="?a?a/ebbbb2brbrb2bbbbb2brbrb2bbbbd?a?a>a"
lev[02]="?a?a&ebbbbbe.brbrbrb.bbbbbbb.brbrbrb.bblbbbb.brbrbrb.bbbdbbb?a?a,a"
lev[03]="?a?a4bebb.lbbbsb.bsbsbblwbberbbbrbrbwbrbbbrbbbrbwbrbrbdbrebbwlbbsbsb.bsbbbl.bbeb?a?a3a"
lev[04]="?a:bbbelebbbybrbrbrbrbybbbrbrbbbyerbbdbbreybrbrbrbrbybbbbgbbbbzbsbsb.bbbbbbb.brbrbrb.brbrbrb.lbbbbbl?a:a"
lev[05]="?a?a?abbb2bbbrb2drfle2bbbrb4bbb?a?a>a"
lev[06]="?azbbebbbbbzbtbsbwbgbbbbbbbgbwbsbtbzbbbbtb2btb2btbybbbbbbdbbbbbbultbtbtlubbbbbtbbbbbybtb2btb2btb2lbfbl?a$a"
lev[07]="?aylbbbebblzbwbzbwbzbwbwebbbbbfbbrewbsbsbrbrbwbsbsbrbrbwbsbsbrbrbwbsbbbbrbblwbvb.lbbdbbb?a?a(a"
lev[08]="|lbb4brb4bbfbb4brb1lbbgbbb.bsbsb.bsbsbxbbbdbbbsltlbbrbsbsbsbtbrbrbsbsbsbtbbfbebbebbgbbbvbrbvbrbwbbbvbbeybbblbbb?a:a"
lev[09]="?a'bbblbb1brfslbbzlbbbrbrbxlbbsbblrbxbrerbhrbebbwbbbblsbsbxlsbdblbblxbbbbrbrb.frblbbf.bbbsb3blbb?a'a"
lev[10]="?a.bbbbb.ebbrbrb.brbbbbbgzbrlsbrbybbbbbrerbyfrbrbrbrlybrerbbbbbxbbbbbdrbrbxbrbrbsbrbxlrbrbfbibbxbebsbsbybrbblbbrbybsbsblbbxgbbbbbbsb3bbeb?awa"
end

function storytime()
story={}
story[1]=[[

0 ogcdesm gdmmgt goqr, dm'y
oankm mdlt jnc rnkc atq. etm
rnkc bolldty nh hnv.

1 atqmdlt ymncr, khwgt vdgakc!
igtoyt, o atqmdlt ymncr jdcym!

0 ogcdesm ogcdesm.
vsom ymncr vnkgq rnk gdxt mn
stoc?

1 snv oankm mst ymncr nj mst
vogcky ohq mst wocithmtc.

0 rnk'ft oyxtq jnc msom tftcr
hdesm msdy vttx! snv lohr mdlty
qn d soft mn mtgg rnk msom
focdtmr dy mst yidwt nj gdjt?

1 nxor... nns! d xhnv; mst
ectom gtmmkwt stdym!

0 os rty! locftgnky wsndwt!
gtm lt ytt dj d woh ctwogg vsom
soiithtq ogg msnyt rtocy oen...
]]
story[2]=[[
*
0 cdesm, vtgg oy rnk xhnv, vt
gdft nh gtmmkwt. dm xttiy nkc
anhty hdwt ohq ymcnhe msohxy mn
ogg msom wogwdkl.

1 lsll.

0 dm'y nkc nhgr ynkcwt nj jnnq
ohq dm soy mn at namodhtq dh
joc njj gohqy.

1 ks sks!

0 vtgg, homkcoggr ynltnht soy
mn at dh wsocet nj mst dlincm
ohq tzincm nj ykws o qtgdwowr.

0 mn thykct dm qntyh'm jogg
dhmn mst vcnhe sohqy.

1 vsn voy dm?

0 o ecttqr loh, igodh ohq
ydligt...
]]
story[3]=[[
0 o loh holtq bolty ochngq
aocmsngnltv ngdftc yolktg
kcethmshniit.

1 ennq gncq!

0 hnv hnv, vt'gg soft hnht nj
msom fkgeoc icnjohdmr dh msdy
snkyt! gtm lt wnhmdhkt.

0 bolty voy qndhe sdy
ioitcvncx nht tfthdhe vsth oh
tidisohr sdm sdl...

0 st ictmmr lkws soq wnligtmt
wnhmcng nftc mst gohq'y lnym
fogkagt ctynkcwt.

0 loxdhe sdl tyythmdoggr mst
lnym invtcjkg jgtadoh nkm
mstct!
]]
story[4]=[[

1 ns vnv!

0 vnv dhqttq.

0 mst ctogdyomdnh msom st soq
wnligtmt wnhmcng nftc nkc
homdnh'y gtmmkwt soq sdm sdl
gdxt o mnhht nj acdwxy.

0 dm vthm mn sdy stoq ohq st
qtwgoctq sdlytgj mn ogg msom
st voy hnv mst ckgtc ohq xdhe.

0 st snocqtq ovor ogg mst
ectthy, ohq loqt oftcoet bnty
gdxt rnk ohq lt ior sket
olnkhmy jnc tfth nht gtoj.

1 ns hn!
]]
story[5]=[[
0 httqgtyy mn yor sdy htv ohq
ykqqth icnlnmdnh mn atwnldhe
mst nlhdinmthm ckgtc nj nkc
gohq.

0 vtgg, dm voy qtjdhdmtgr hnm
ctwdtftq ftcr vtgg ar ikagdw
ohq nkc icnfdhwt.

0 ohq dm qdqh'm moxt gnhe jnc
nht loh ohq nht loh ognht mn
qtwdqt st'q soq thnkes.
]]
story[6]=[[

1 vsn voy dm msom ymnnq oeodhym
sdl?

0 vtgg, hnanqr xhnvy sdy ctog
holt, akm mst gtethqy ctjtc mn
sdl oy "ctqand."

0 mst oayngkmt loqgoq qtwdqtq
msom st vnkgq ydhegt sohqtqgr
dhjdgmcomt mst woymgt ohq acdhe
mst gtmmkwt aowx mn mst itnigt!
]]
story[7]=[[
0 msdy dy mst mogt nj sdy
bnkchtr mn mst xdhe'y wsolatc,
ohq mst tidw aommgty st thqkctq
ognhe mst vor...

]]
story[8]=[[
1 yn ctqand vnh ohq yoftq mst
qor jnc ogg nj ky cdesm?

0 yncm nj. st voy etmmdhe
ictmmr joc dhmn mst tfdg xdhe'y
woymgt akm msom voy wtcmodhgr
hnm mst thq nj sdy jtocynlt
ommowxtcy.

1 nns! akm ctqand vnh'm gtm ky
qnvh d atmwso!

0 msom'y cdesm!

0 mstct vtct 10 ykws mcdogy st
soq mn jowt atjnct mstct vnkgq
at o wnligtmt thq mn msdy
vdwxtq xdhe.

0 ohq yn joc st soq atymtq 8 nj
mstl. akm mst nqqy vtct oeodhym
sdl.

0 vdms mst tftc lnkhmdhe hklatc
nj thtldty msom mst tfdg xdhe
soq ytm oeodhym sdl qtmtcldhtq
mn vdit sdl nkm.

0 ohq ctlnft mst goym ftymdet
nj snit vt soq atwokyt om msdy
indhm dm wnkgq jogg dh tdmstc
qdctwmdnh.
]]
story[9]=[[

0 jncmkhomtgr msnkes msdhey
vtct gnnxdhe ki!

0 qkt mn ctqand'y dhmtggdethwt
ohq qdgdethwt wnladhtq st soq
dhqttq wnhpktctq lnym nj mst
xdhe'y tfdg godc.

0 hnv nhgr mst goym mvn
ctlodhtq. mst ecohq sogg nj
xhdesmy ohq jdhoggr - mst
mscnht cnnl dmytgj.

1 ctqand vnh'm gtm ky qnvh!

]]
story[10]=[[
1 yn vsom soiithtq htzm?

0 dm voy dhqttq o qdjjdwkgm
aommgt nj vdmy ohq ldesm ohq yn
joc ctqand soq qnht ctlocxoagr
vtgg jnc sdlytgj.

0 akm sdy qdjjdwkgmdty vtct
oankm mn etm o gnm vncyt.

0 jnc st voy hnv dh mst stocm nj
mst iogowt, mst mscnht cnnl.
ohq mst  tftc mctowstcnky ohq
qtfdnky xdhe voy kinh sdl.

0 ohq mst xdhe soq ynlt yitwdog
ohq dhwctqdagt oadgdmdty nj sdy
nvh ki sdy ygttft ...
]]
story[11]=[[

1 yn vsom soiithtq htzm?

0 vsom soiithtq htzm? vtgg dm
voy wgtoc mn ytt msom ctqand
voy hn ncqdhocr wdmduth.

0 st soq atomth mst xdhe, om sdy
nvh eolt ohq dh sdy nvh
mtccdmncr.

0 mst xdhe voy wnligtmtgr
qtjtomtq ar ctqand ohq jgtq mst
woymgt dh soymt mn yoft sdy nvh
yxdh! mst rtggnv wnvocq.

0 ctqand msth atwolt mst htv
ckgdhe lnhocws ohq mstct htftc
voy o xdhqtc, ethmgtc, hnc lnct
khqtcymohqdhe xdhe msoh sdl.

0 ohq mn msdy qor st ymdgg ckgty
mst gohq, ethtcnky mn o jokgm,
st icnfdqtq gtmmkwt jnc tows
ohq tftcr itcynh jnc jctt.

0 hn wsocet, hn lnhtr. bkym
xdhqhtyy ohq vdyqnl. msnyt vtct
sdy vomwsvncqy.

1 ovv... d voy xdhho snidhe mst
xdhe vnkgqo atomth ctqand ki
ojmtc msdy! msom vnkgqo atth
htom mn ytt!

1 vsom xdhho ymncr dy msdy
ohrvory??

0 slis! dm'y mst xdhq msom'gg
etm rnk o yiohxdhe dj rnk qnh'm
etm cdesm dhmn atq msdy ftcr
dhymohm, rnkhe goqr!

1 stt-stt! d'l mst tfdg xdhe,
hn gtmmkwt jnc ohrnht, hnm o
gtoj! d etm mn xtti ogg mst
lnhtr!

0 hnv, ldyyr!

1 d'l endhe d'l endhe, ysttys!
]]

cred1=[[

f l e b

a sorcery presentation ...




staff ...




zoraaa:

game idea, main sprites, main
maps, opening text, story,
and sound effects.




scrubsandwich:

fearless leader, completed
maps, main musician, artist,
assistance.




chizel9000:

concept artist, illustrations,
testplay, debug, advice.




cabledragon:

superior coding assistance,
quality check.




dw817:

jack of all trades, main cart
programmer, sprite work,
map work, music work,
sfx work, story work,
map editor, code completion.










thank you !

for playing !

press (x) to restart ...








]]
cred2=[[

f l e b

  sorcery




      ...




zoraaa:



 




scrubsandwich:








chizel9000:







cabledragon:







dw817:
















thank you !

for playing !

press (x) to restart ...








]]
end
function gabslam()
local k_tlk,ti,sh,tu={64,68,69},-8,8,8
  rocket=1
  for i=1,127 do
    if i==32 then
      ti=-6
    end
    if i==64 then
      ssfx(26,0)
    end
    if i>=64 then
      sh+=1.75
      ti+=2
      if i==96 then
        for i=8,0,-1 do
          ssfx(27)
          cls()
          if i%2==0 then
            sspr(0,96,128,8,0,60-i)
          else
            sspr(0,96,128,8,0,60+i)
          end
          pause(2)
        end
        break
      end
    end
    cls()
    sspr(0,104,128,8,64-sh,68-sh/16,sh*2,sh/8)
    spr(k_tlk[rand(1,3)],60,60)
    sspr(0,96,128,8,0,ti)
    if rand(0,6)<3 then
      ssfx(28)
    end
    pause(2)
  end
  pause(64)
  music(8)
  pause(192)
  cls()
  rocket=1
  nokey(2)
end
function ssfx(n,c)
  if rocket==2 then
    return
  end
  if c==nil then
    c=3
  end
  sfx(n,c)
end

main()
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007777777777777777777777777777700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007000000000000000000000000000700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007077777007700077777007777770700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007077777007700077777007777770700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007077000007700077000007700770700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007077000007700077000007700770700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007077777007700077777007777700700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007077777007700077777007777700700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007077000007700077000007700770700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007077000007700077777007777770700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007077000007700077777007777770700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007000000007777000000000000000700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007777777707777077777777777777700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077700000000000
07777707000000000000000777777000000000000000000000000000700000000000000000000000000000000000000000000070007700000007000000000000
07070007000000000000000700007000000000000000000007000000700000000000070000700000000000000000000000000070000700000000000000070000
00070007077707777700000700000077770777770007777077770000700000777770777707777070077077777077777000000070000707777707077707777700
00070007070707000700000700000070070700070000007007000000700000700070070000700070007070007070007000000070000707000707070700070000
00070007000707070700000700777070770707070077707007000000700000707070070000700070007070000070707000000077777707070707070000070000
00070007000707077700000700707070000707770070707007000000700000707770070000700070007070000070777000000070000707077707077770070000
00070007000707000000000700007070000700000070007007070000700070700000070700707070007070007070000000000070000707000007000070070700
00070007000707777700000777777070000777770077777007770000777770777770077700777077777077777077777000000070000707777707077770077700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000090a00000000000000000000090a000000000000000000000000000780055000000000000000000cccc00000077777777770007777777701111000
000000000a0aaa0000000000000000000a0aaa00aac5cc00000000000000000070005002000000000000b300cccccc0007777777777777707777777711111100
00a09a0000aaa00000a09a000000000000aaac009acc000000000000000000007000500000000000000b3b00cccccc0007777777777777707777777711111100
00aaaa0000a0000000aaaa000000000000acc5000a5c00000870000000000000706666000000000000b3bb000cccc00077777777777777777777777701111000
00cccc0000cccc00cccccccc0000c5cc00c5cc00aacc0000000700000000000007633300000000000bb3b3000000000077777777777777777777777700000000
00c5c5000c5cc500c5ccccc50000ccc000cc000000cc0000006666000077000000666600000000000b3bb0300000000077777777777777777777777700000000
00cccc000cccc000ccccccccaaaac5c000cccc0000cccc00006333000866330000600600000700000bbb33000000000077777777777777777777777700000000
00c00c0000c00c00c000000ca90acccc00c00c0000c00c000d6666000d63360000d00d0008d66360000000000000000077777777777777777777777700000000
00000000000000000000000000000000000000000099990000000000000000000000000000000000009000000000900077777777777777770007770000000000
00000000000000000090090000000000000909000957070000000000000aa00000000000000000000099a00000a9900077777777777777770007700000000000
0000000000000000095995900000000000959500009000000000000000aa5a0000000000000000000a8a899099a8aa0077777777777777770007000000000000
0009090000000000097f7f70000000000099990009500000000000000a5aa000000550000000000009a0a9000980890077777777777777770000000000000000
009595000090090009fffff009597900009707000090000000aa5a000aaa50000055b50000000000998a8a000aa8a99077777777777777770000000000000000
0099990009599500097f7f7000999000009000000090000000a5a5000aa0aa000056560000aaaa0000a990000099a00007777777777777700000000000000000
0097970009797000099999900959700000999900009999000aaaaaa0a0a0a0a00aa555a00aaa5aa0000090000090000007777777777777700000000000000000
009009000090090009000090009999000090090000900900a0a00a0aa0a00a0aa0a00a0aaaa5a5aa000000000000000000077777777770000000000000000000
00000000000000000075550000000000000000000000000000755500000000000000000000000000ffffff00000000000dddd000000000000000055555000000
00000000000550000755555000000000000000000007500007555550000000000000000000000000f7777f0000110000d0000d00000000000005566666550000
00755500077555007555555500000000007555000075555075555555000000000022220000222200f77fff0000000000d0000d00000000000056600000665000
0755555075566500755555550075550007555550007665557555555500755500002d2d00002d2d00f7f7ff00000000000dddd000000000000560000000006500
075666505566d500555666550755555007666550005d665555666555075555500026660000260600f7ff7ff00000000000000000000000000560aa9998806500
055d6d5055d55500555d6d55075ddd5005d6d55000555d5555d6d55507ddd5500020666000266600fffff7ff0000000000000000000000005600aa0000800650
05555550555bb0b055555555055ddd50055555500b0bb5555555555505ddd55000000000000066600000ff7f0000000000000000000000005600bb0000000650
00b00b0000b0000000b00b000555555000b00b0000000b0000b00b0005555550000000000000000000000fff0000000000000000000000005600bb0000000650
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffff0000000000000000000000000fffff005600cc0000000650
0000000000000000000000000d006d000000000000000000006ddd00ffffffffffffffffff2d22ff00000ffffff00000000000000f222f005600cc0000f00650
0000000000000000000000006d00dd00000000000000000000dddd00ffffffffffff22ffff22ffff0000ff2ff2ff0000000000000ff2ff000560ddeeeff06500
00000000000000000d66ddd000000006000000000d66ddd008000080fffffffffff22dffffd2ffff0000f22ff22f00000000000000fff0000560000000006500
0088880000888800062222d00088880d00858800062222d000588500ff2222ffff2d22ffff22ffff0000ff2ff2ff000000fff000000000000056600000665000
00858500085885000d2121d008588500008880000d1212d000888800ff2d2dffff22ffffff22ffff00000ffffff000000ff2ff00000000000005566666550000
00888800088880000d8888d008888000008580000d2222d000888800ff2666ffff22666fff22666f00000000000000000f222f00000000000000055555000000
00800800008008000080080000800800008888000080080000800800ff2f666fff2ff666ff2ff66600000000000000000fffff00000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000100000001000000010000000100000000000000000000000000000000000000010000000100000001000000010000
00000000000ffffffffffffff0000000000100000001000000010000000100000000000000000000000000000000000000010000000100000001000000010000
00000000ffff333333333333f0000000000d0000011d0000000d1100011d1100000d0000011d0000000d1100011d1100000d0000011d0000000d1100011d1100
000000fff333333b3b3bb3b3ff000000000000000000000000000000000000000001000000010000000100000001000000010000000100000001000000010000
00000ff3333b33b33b3b3b3b3ff00000000000000000000000000000000000000001000000010000000100000001000000010000000100000001000000010000
0000ff333b33b333333333bbb3ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000f333b3333b3333b33333333ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000f3333333333b33b3b3bb3b33f000000000000666666000000000ffffffffffffffffffffffff000000000000000000000000000000000000000000000000
00fff33b3b33b3b333333b33b3b3ff00c00c00c0675555760ee0ee00ffffffffffffffffffffffff00ffffffffffff0000000000000000000000000000000000
00f33b3333b333b33b3bb333b3333f00909a909067777576e88e88e0ffffffffffffffffffffffff0ffccccccccccff00066666666666600005550000fffff00
00f3b33b3b33b333333b33333b3b3ff0a9a7a9a067775576e88888e0ffffffffffffffffffffffff0fccffffffffccf00665555555555660059885000fffff00
00f33b3b333b333b3b333b3b3b3333f004484400677777760e888e00fffffffffffd2fffffffd2ff0fcff000000ffcf06655444444445566059885000f555f00
0ff3b3b3b333b333bb3b33333333b3f009a9a9000667566000e8e000fffd2dffffff2dfffffff2ff0fcf00000000fcf065544333333445560598850005988500
0f33b33b33b3b3333b3b3bb3b3b3b3f00000000000066000000e0000fff222fffff222fffff22dff0fcf00000000fcf055443322223344554444444044444440
ff33b3b3b3b3333b3b3bb3bb3333b3f0000000000006000000000000fff2f2fffff2f2fffff2f2ff0fcf00000000fcf054433221122334450000000000000000
f333b3333b3bb33b3bb3b33bbbbbb3f0002720000008000000000000ddddddd022222220000000000fcf00000000fcf055443322223344550000000000000000
f3333b3b3333333bb33bbbb3b3bbb3f002eee2000800080000000000d0000cd028000820000000000fcf00000000fcf065544333333445560000000000000000
f3b333b3b333b333bb3b3b3bbbb3b3f022e222200009000000000000d000ccd020808020000000000fcf00000000fcf066554444444455660000000000000000
f33b33333bb333bb3bb3b3bb3b3bb3f072eee270809a908000000000dc0cc0d020080020000000000fcff000000ffcf006655555555556600000000000000000
f33b3b3333333b3bb3bb3b3bbbb3b3f02222e2200009000000000000dccc00d020808020000000000fccffffffffccf000666666666666000000000000000000
ff33b3b3b3333bb3b3b3bbb3b3bb3ff002eee2000800080000000000d0c000d028000820000000000ffccccccccccff000000000000000000000000000000000
0f333b333b3bb3b3bb3bb3bbbb3b3f00002720000008000000000000ddddddd0222222200000000000ffffffffffff0000000000000000000000000000000000
0ff3b3b33333bbb3b3b3bb333bb3ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00f33b3b3333b3b3b333b3bb3bb3f00066666660000000000000000000000000000000000fffff000fffff000000000000000000000000000000000000000000
00fff33b33333b3bbbb3bbbbb3b3f000600000600000000000000ffffff00000000000000f222f000f222f0000000fff00000000fff000000000000000000000
0000f333b33333b3b3bb3b3bbb3ff00006000600000000000000ff2ff2ff0000000000000ff2ff000ff2ff000000ff2f00000000f2ff00000000000000000000
0000fff333b333bb3b3b3bb333ff000000606000000000000000f22ff22f00000000000000fff00000fff0000000f22f00000000f22f00000000000000000000
000000fff33b333333b3b333fff0000006070600000000000000ff2ff2ff000000fff00000000000000000000000ff2f00fff000f2ff00000000000000000000
00000000ff333333333333fff0000000607770600000000000000ffffff000000ff2ff00000000000000000000000fff0ff2ff00fff000000000000000000000
000000000ffffffffffffff000000000666666600000000000000000000000000f222f000000000000000000000000000f222f00000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000fffff000000000000000000000000000fffff00000000000000000000000000
00000000177777777777771017777777777777107777777777777710177777777777771077777777777777107777777777777710710000000000017000000000
00000000710000000000017071000000000001707100000000000170710000000000000071000000000000007100000000000170710000000000017000000000
00000000710000000000000071000000000001707100000000000170710000000000000071000000000000007100000000000170710000000000017000000000
00000000177777777777771071000000000001707777777777777710710000000000000077777771000000007777777777777710177777777777771000000000
00000000000000000000017071000000000001707100000000000170710000000000000071000000000000007100000000000170000000171000000000000000
00000000710000000000017071000000000001707100000000000170710000000000000071000000000000007100000000000170000000171000000000000000
00000000177777777777771017777777777777107100000000000170177777777777771077777777777777107100000000000170000000171000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000
00000000000000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000
00000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000
00000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000
00000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000
00000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000
00000000000000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000
00000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000
07777770077777700700007007777770007777000700007007777770077777000000000000000000000000000000000000000000000000000000000000000000
07000070070000700770077007000070070000700700007007000070070000700000000000000000000000000000000000000000000000000000000000000000
07000000070000700707707007000000070000700700007007000000070000700000000000000000000000000000000000000000000000000000000000000000
07000000077777700700007007777700070000700700007007777700077777000000000000000000000000000000000000000000000000000000000000000000
07007770070000700700007007000000070000700070070007000000070070000000000000000000000000000000000000000000000000000000000000000000
07007070070000700700007007000000070000700070070007000000070007000000000000000000000000000000000000000000000000000000000000000000
07000070070070700700007007000070070000700007700007000070070070700000000000000000000000000000000000000000000000000000000000000000
07777770070077700700007007777770007777000007700007777770070077700000000000000000000000000000000000000000000000000000000000000000
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
010600001f61135631396501465022640306401164024640326320e6322f6223e6220b625186203462002610116102c610046100f610216001b10024400185001b70022300187001160018500187001870024300
0104000012653240333465319053286330a02316613296000b6001760000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
01040000006540c654000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000301703c260303503c440301303c2203031000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000003067030660306503064030630306203061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000c071180630c051180430c031180230c01100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003c05500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
017f00000067000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000306703c6503c1700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000c050240503c0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200003005031050300503205000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000300520c00024052000003c052000003c05200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0120000029550295272d5502d5272e5502e5272d5502d5272c5502955028550285272e5502e5272d5502d5272b5502955028550285272e5502e5272d5502d5272955028550265502652722550225272155021527
0102000027e1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000c07100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001307100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003706100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400002855028522265502455023550235222455026550245501f5501f5221c5501c5321c5121c5501f550285502852226550245502355023522245502655024550245221f550285502854028530295502b550
011400002755027522265502655024550245222255022550225502252222550265501a5501a5221a5501a52226550265412653126521265112651226512265122655024550245222655026522245502355023522
012000000e1520e1520e1520e1520e1520e1520e1520e1520c1520c1520c1520c1520c1520c1520c1520c1520a1520a1520a1520a1520a1520a1520a1520a1520915209152091520915211152111521015210152
01060000180100c0151f0201301524030180151f0401301530050240151f060130153c07030015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002b570305602b550305402b530305202b51000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000001451320000255074000036513200004751340004670076700c670156702266030660376603b6603c6503a65037650336502f6402b64027640226401d63018630136300e6200a620066100361000000
010c0000000710c063000510c043000310c023000110c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400003c05300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000024054230512205121051200511f0511e0511d0511c0511b0511a051190511805117051160511505114051130511204111031100210f0110e000000000000000000000000000000000000000000000000
017f00000cf5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002415118153000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000000410c131002210c311000410c131002210c311000411813100221183110004118131002212431100041241310022124311000412413100221243110042130341002613017100471303510023130111
012000003c4313025130471180000c001000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001d5501d5501d5501d5401d5401d5401d5301d5301d5501d5301d5201d5101c5501c5501c5501c5401c5401c5401c5301c5301c5301c5201c5201c5201c5101c5101c5101c51000500005000050000500
010c00001d5501d5501d5501d5501d5521d5321d5221d5151a5501a5501a5501a5501a5521a5321a5221a5151c5501c5521a5501a5521c5501c5501c5521c5521c5521c5521c5521c5521c5521c5321c5221c515
010c00000e1520e1500e1520e1500e1520e1520e1520e152071520715207152071520715007152071500715200152001500015200150001520015200152001520015200152001520015200150001520015000152
010c00001a5501a5501a5501a5501a5521a5321a5221a515175501755017550175501755217532175221751518550185521755017552185501855018552185521855218552185521855218552185321852218515
0118000024550245222655527550275222b5502b5222b522295502952222555295502954029532295222951227555265552455522550225222755027522245552655524555235551f5501f522235502352223522
0118000024550245222655527550275222b5502b5222b522295502952222555295502954029532295222951227555265552455522550225222755027522245252b5502b5322b5222b51232550325323252232512
011800003355532555305552e5502e52233550335223055032551305552f5552b5502b52232550325222e550305512e5552c555295502952230550305222b55030551305222f5502f5222b5502b5222655026522
011800003355532555305552e5502e52233550335223055032551305552f5552b5502b52232550325222e550305512e5552c555295502952230550305222b55030551305222f5552d5552f5502f5422f5322f522
0118000030512305123051230512305123051230512305122e5112e5122e5122e5122e5122e5122e5122e5122c5112c5122c5122c5122c5122c5122c5122c5122b5112b5122d5112d5122f5112f5122f5122f512
0118000030532305323053230532305223052230512305122e5312e5322e5322e5322e5222e5222e5122e5122c5312c5322c5322c5322c5222c5222c5122c512275312753227522275122b5312b5322b5222b512
011800002e5322e5322c5322b5322b5122e5312e5122b5222c5312b5322953227532275122c5312c512295222b531295322753224532245122b5312b512295222b5312b512265312651223531235121f5311f512
012000001a5521a5271d5521d5271d5521d5271d5521d5271d5521855218552185271a5521a5271a5521a5271c552185521855218527195521952719552195271a5521855216552165271a5521a5271955219527
011800002e5322e5322c5322b5322b5122e5312e5122b5222c5312b5322953227532275122c5312c512295222b531295322753224532245122b5312b512295222b5312b5122b5122b51226531265122651226512
011800000c13518135000000c135181350c13513135181350a13516135000000a135161350a1351313516135081351413500000081351413508135111351413507135131350000007135131350b1350f1350e135
011800000c13518135000000c135181350c13513135181350a13516135000000a135161350a13513135161350813514135000000813514135081351113514135071351313507135131350b135171351b1351a135
011800000f1351b135000000f1351b1350f135161351b1350e1351a135000000e1351a1350e135161351a1350c13518135000000c135181350c13513135181350b13517135000000b135171350b1351313517135
011800000f1351b135000000f1351b1350f135161351b1350e1351a135000000e1351a1350e135161351a1350c13518135000000c135181350c135131351813507135131350513511135031350f135021350e135
010600101f6200c0000c0000c0000c0000c0000c0000c0001f6200c0000c0000c0000c0000c0001f6200c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c000
011400002455524555185550c555245550c5550c5550c55524550185510c50024550185510c50024550185512455524555185550c555245550c555245551855530550245510c50024550185510c500185500c551
01140000001500c15015655001500c15000150156550c150001500c15015655001500c15000150156550c150001500c15015655001500c15000150156550c1501815024150156550c1501815015655001500c150
011400002b5502b5222955028550265502652228550295502855024550245221f5501f5321f5121f550245502b5502b5222955028550265502652228550295502855028522245502b5502b5402b5302d5502f550
0114000030550305222e5502c5502b5502b5222955027550265502652224550225501f5501f5221f5501f5222b5502b5412b5312b5212b5112b5122b5122b5122955028550285222955029522285502655026522
010a00201805300000180530000030655000000000000000180530000018053000003065500000000000000030655000001805300000180530000030655000001805300000180530000030655000003065500000
0114000007152131522d6550715213152071522d65513152021520e1522d655021520e152021522d6550e15204152101522d6550415210152041522d6551015204152101522d6550415210152041522d65510152
011400000c152181522d6550c152181520c1522d655181520a152161522d6550a152161520a1522d6551615207152131522d6550715213152071522d6551315205152111522d65505152021520e1522d65502152
01080000225502255022550225502254022540225402253022530225502253022520225101f5501f5501f5501f5401f5401f5401f5301f5301f5301f5201f5201f5201f5101f5101f5101f510005000050000500
010800001855018550185501855018550185401854018540185301853018550185301852018510185501855018550185401854018540185301853018530185201852018520185101851018510185100050000500
01200000235251f525265251f525235251f5252652523525215251e525265251e525215251e52526525235251f5251c525285251c5251f5251c52528525265252352524525265252152523525245252652524525
01200000230322303223022230222301223012230122301221032210322102221022210122101221012210121f0321f0321f0221f0221f0121f0121f0121f0121c0321c0321c0221c02124011240122301223012
012000001f0221f0221f0221f0221f0221f0221f0221f0221e0221e0221e0221e0221e0221e0221e0221e0221c0221c0221c0221c0221c0221c0221c0221c022180221802218022180221c0221c0221e0221e022
0120000026525235251f5252352526525235251f5252352526525215251f52521525265251f525265252752528525245251f5252452528525245251f525245252a52526525235252a5252a525265252a5252d525
012000001f0221f0221f0221f0221f0221f0221f0221f0221e0221e0221e0221e0221e0221e0221e0221e0221c0221c0221c0221c0221c0221c0221c0221c0221e0221e0221e0221e0221e0221e0221e0221e022
012000001a0221a0221a0221a0221a0221a0221a0221a0221a0221a0221a0221a0221a0221a0221a0221a02218022180221802218022180221802218022180221a0221a0221a0221a0221a0221a0221a0221a022
__music__
04 20 21 22 44
01 23 27 2c 30
00 24 28 2d 30
00 25 29 2e 30
02 26 29 2f 30
04 31 32 43 44
01 33 36 12 44
02 34 37 43 44
04 1f 38 39 44
01 3a 3b 3c 44
00 3a 3b 3c 44
00 3d 3e 3f 44
02 3d 3e 3f 44
01 33 36 35 44
00 34 37 35 44
00 33 36 12 35
00 34 37 13 35
00 41 36 43 35
02 41 37 43 35
02 35 42 43 44
00 0c 2a 14 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
