pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--mystic realm dizzy
--by sophie houlden

scroll=128
img="mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbbbmbmbmbmbbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbggbnbnbnbnbbmmhhhgmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbgnnnnnnfffbbmhhhhhhhhmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbgggnffnnfnfbhhhhhggmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbgnnnnnffffbbhhhhhhhhhhhhgmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhhhhbgnggnnfnnfbbhhhhhhhhhhhhhhhggmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhhgggbggnnffffffbbggggggggggggggggmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbgngnnfnnfnfbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbnnnnnfffnfbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhhhhhggmmmmmmhhhhhhhhhhhghhmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbnggnnnffnfbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbggnnffffffbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhggmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbgnnnnfnnfnfbmmmmmmmmmmmmmmmmmmmmmmmmmmhhhhhhhhhhhhhhhhhhhhhhhhhhgggggghggggggmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbgnggnfffffbbmmmmmmmmmmmmmmmmmmmmmmmmmhhhhhhhhhhhhhgggggggggggggghggghhhhgggggmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbnnnnnffnnfbbmmmmmmmmmmmmmmmmmmmmmmmmmmmhgggggggggggggggggggggggggggggggggggmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbgggnnnffffbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhhhhhhhhhhmmmmmmmmmmmmmmmmmmmmmmmmbgnnnnnnnffbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhhhhhhhhhhhhhhhhhmmmmmmmmmmmmmmmmmmbgnggnnfffnfbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhhhhhhhhhhhhhhhhhhhhhhhhhhhhmmmmmmmmmmmmbggnnnnfnnfbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhhhhhhhhhhhhgggggggggggghhhhhhhmmmmmmmmmbggnnnfffffbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhhhhhhhhhggggggggggggggggggggggghgggmmmmmmbgngnffnfnnfbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhhgggggggggggggggggggggggggggggggggmmmmmmmmbgnnnnnffffbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbgggnfffnnfbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbgnnnffffffbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbgnggnnnfnnfbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbggnnnnffffbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbggnnffnnfnfbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbggnnnfffffbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbgnggnnfnnffbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbggnnnfffffbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbgggnnnnfnnfbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbbbbbbbbbbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmbggnnnnffffbbmmmmmmmmmmmmmmmmmmmmmmmmbbbbbbbbbbbbbbbbbbbbbbbbmmmmmmmmmmmmmmmmmmmmbbblllllllllllbbbbbbbbbbmmmmmmmmmmmmmmmmmmmmmmmbgnnnnnfnnfbbmmmmmmmmmmmmmmmmmmmbbbbbllllllllllllllllllllllllbbbmmmmmmmmmmmmmmmbbllllllllllllllllllllllllbbbbbbmmmmmmmmmmmmmmmmmbgnggnffffffbmmmmmmmmmmmmmbbbbbbllllllddlddlllllllllldddddddllllbbbbbmmmmmmmmmmllllllllllllllllllddddddllllllllbbbbmmmmmmmmmmmmmbgnnnnnffffbbmmmmmmmbbbbbblllllllllllllllllllllllllldllldllllllllllddbbbbbbmmmmlllllldlddddlllddllllllddddddlllllldbbbbmmmmmmmmmbgggnnnfnnfbbmmmmbbbllllllddlllllllllllllldddddddddlldddddddddlllllldddddddbbmmdllldlddldddlldddlldddlllddlllddddddllllbbmmmmmmmbgnnnnffffffbbbbblllllldllllldlllllllllldddddllllllblllllllddllddddddddddddddbbldddlddlddlllddddddldbbddddlddddddddddddllbbbmmmmbggnnfnffffblllllllllllllddddllllldddddddlllllllbbbhbbbdddllllddddddddddddddddddddlllddddddddddddbddbbdllllldddbllddddddppllbbbbbggnfffffbbldllllddllllddddlllldddllllllldddddbbhhhhhhhbblddddddddddlddddldddddllddddddllldddddddbddbbbddbddddbbddddddppdddbbdddbbbbffbbblllllddllldlllddllldlddddddlldddddddbhhhhhhhhhhhbdddddddddddddddddddddddlllldddddddbbddbbbblbbbblbbddbdbddddppddddbbdddddddbbllllddllllddlllddddddlllddlddlllllllllbhhhhhhhhhhhhgbddddddddddddddddddddddlllddddbddbllbdbfbbbbbbdbbbdbdlbddjjjbbddblfbddbbbblldlllllllldddlldddddlllldddlddddllldddbhhhhhhhhhhhhhhgbddldddddldddddddddddllddddddbblbbddbbdbldbbdbldbbddbbbjbjdlbbdbdfbbbllllddddlllldlllllddllddlddddddlllllllllllbhhhhhhhhhhhhhhhggbdddddddddddddddddddbddddbbbbllbbdbldfbddffbddbbbbdbbjbdbbdbbbbbblllllllllllddlllllllllldddddllllllllllddddddbhhhhhhhhhhhhhhhhgggbddddddddddddddddddbbddbbldbbbddbbbdbbbdlfblddfbbdbbjblbbfbbbbllllldllldddllldddddddddddlldlldddddlldddddddbhhhhhhhhhhhhhhhhhgggnbddddddddddddddddbblbbbbdfblbfbblbbbbdlbbbddbfbdbbbbldfbdbblllldddlddddllllddllddllllllddddddddddllddddddbhhhhhhhhhhhhhhhhhhhggnnbdddddddddddddddbddbbbdlbbbddbdbbbbdllbfbldbbbbbdbbddbbblllddllllllddllllllldllllldddddddddddddddddddddbhhhhhhhhhhhhhhhhhhhhgggnbdddddddddddddddblbbbbbbbfbdbflbbbbdddfbbdbfdbbbdbbdbblllddllllllldddddlllllldlldlldddddddddddlldddddddbhhhhhhhhhhhhhhhhhhhhgggnnbddddddddddddddbbbbbbbbbbbbddlbbbbbbbdbbbbffbbddbbbllllddddddllllllddllllldddddddddddddddddddddddddddbhhhhhhhhhhhhhhhhhhhhhhgggnnbdddddddddddddbbbbdbbbbbbbbbbbbbbbbbbbbbbbbbbbdbblllddlldddllddddddddddddddddddddddddlllddddddlddddbhhhhhhhhhhhhhhhhhhhhhhhgggnnbdddddddddddddbllllllllllbbbblldbbbbbbbbbbbdbbbldlllllllllldlddllllddddddllddddddllddddddddddlldddbhhhhhhhhhhhhhhhhhhhhhhhgggggnnbddddddddddddddllllldllllllllllllbbbbpppppbbbldddllddddlllldllddlddllddddddddddldddddddddddddddddbhhhhhhhhhhhhhhhhhhhhhhhghgggnnbdddddddddddddllldddldlllldddlllllllpppppppppddddddldddlddddddddddddddddddddddddddddddlddddddlddbhhhhhhhhhhhhhhhhhhhhhhhhhggggnnnbddddddddfdddddddlllllllllllllllllldjpppppppppddddldddddddlldddllddddddldddddddddddllddddddddddbhhhhhhhhhhhhhhhhhhhhhhhhhgggggnnbdddfdddffdddddlldddlddddddlllllllllldpppjpppppppdddddlldddddlddddddddddddddddddddddddddddddllbhhhhbbhhhhhhhhhhhhhhhhhhhhgggggnnbdddddddddddllldlllldddddlllllldddlllldpppppppppjpdddddddlldddddddddllddddddldddddddddddddddddbhhbbgghhhhhhhhhhhhhhhhhhhhhgggggnnbdddddddddddddddlllllldlllllddddddlllddppppjpppppppddddddddlldddlllddddddddddlddddddddddddddbhhbnghhhhhhhhhhhbbbhhhhhhhhggggggnnbdddfffdddfdlldddlllllllldddddddldddddddppppppppppppddfdddddddddddddddllldddddddddddddddddddbhhghbbbhhhhhhhhhgggbbhhhhhhggggggnnnbddddddddfdlldddddddddlllddddddlllldldddppppppjppjpppppdfdddddddddddddddddddddddddddddllddbhhhhbhhhbhhhhhhhhhhggnbhhhhhggggggnnnbddddddffdddddddddddlldddddlllddddddddddddppjppppppppppppfddddddddddddddddddddddddddddddddbhhhbbhhhbhhhhhhhbbbhhgbhhhhhhgggggnnnbdddddddddddddddddddddddddllllldddllldlddddppjppppppjppppppdddfddddddldddddddddddlllddddddbhhhbhhhhgbhhhhhbhhhbhhghhhhhhgggggnnnnbddddddddddddllddddddlddddlldddddldddddddddpppppjpppppjjppppdddddddddddddlldddddddddddddbhhhhbbbhhgbhhhhhbhhhbhhhhhhhhhggggggnnnbddfdffffdddddddddddlldddddddddddddldddddddpppppppppjjpjppjpjjfdddddddddllddddddddddddddbhhhhbbbhhgbhhhhhbhhhgbhhhhhhhhggggggnnnbdddddddfdddddddddddddddddddddddddldddddddddpjppjpppppppjppjjpppddffddddddddddddddddddddbhhhhbbbhhgbhhhhbbbbhgbhhhhhhhhggggggnnnbfddddddddldddddddddddddddddddddddddddddddfddpppjjpppppppppjppppppddddddddddddddddddddfdbhhhhbhhhhgbhhhhbbbbhgbhhhhhhhhhgggggnnnbddddddddddddddddddddddddldddddddddlllddddddddppjppjjjjpjpjjjppjjjjpppfdddffddddfddfdddbhhhhhbhhhgbnhhhgbfbhhgbhhhhhhhhgggggggnnnbdddfdddddddddddddddddddddddddddddddddddddddddpppjppppjjpjpppjjjpppppjjjfdddddddddddddbhhhhhhbggbnghhhgbhhhhgbhhhhhhhhhggggggnnnbddddddddddddddddddddddddddddddddddldddddddddddpppppjjpppjjpppppppppjjppppdfdfddfddffbbhhhhhhhbbbbbbbhgbhhhggbhhhhhhhhgggggggnnnbdddddddddddddddddddddddddddddddddddddddddddddddppjjjpppppjjjjppppjjpppjjjpjdddffdbbbgbhhhhhhhhhbhhhhbhhbgggbnhhhhhhhhgggngggnnfbdfffdffdddddddllddddddddddddddddddddddddddddddddpppjjppjjjppppjjjppjjpjjpjjjjpddbobgbhhhhhhhhhbhhhhhhhhhbbbnhhhhhhhhhgggnnggnnfbddfdfdddddddddddddddddddddddddddddddddddddddddddppppppjjpppjjjjjjjjjjpjpppppjjjboobnbhhhhhhhhbhhhhhhhhhhhhhhhhhhhhhhhhhggnfgnnfbddddffdddddddddddddddddddddllddlddddddddddddddddfpppppppppjjpjjjjppppjjjppppjpboooobbhhhhhhhhbhhhhhhhgghhhhhhhhhhhhhhhhhggfbnnfbdddddfddddddddddddddddddddddddllddddddddddddddddddppjjppjpppppppjppppjppppjjpjbooiocbhhhhhhhbhhhhhhhhgghhhhhhhhhhhhhhhhhhgnfbnfbddfdddddddddddddddddddddddddddddddddddddddddddddddpppppjjpppppppjjjppppjjjppjjbiiiibhhhhhhhhbhhhhhhhggghhhhhhhhhhhhhhhhhhggnfbbbddfddddddddddddddddddddddddddddddddddddddddddddddddppppjjjjjjpjjjjjjjjjjjjjjjjpbccibhhhhhhhhbhhhhhggggghhhhhhhhhhhgnhhhhhggfbboobbddddfdddddddddddddddddddddddddddddddddddddddddddfppjjjjjpppjjpppjpjjpppppjjjboocbbhhhhhhhhhbhggggggnghhhhhhhhhhhhgnnhhhgfoooooiibffffdddddddddddddddddddddddddddddddddddddddddddddppjppppjjppppppjpppppjjjjbooiicbhhhhhhhhhhbbbbbbnghhhhhhhhhhhhhhgnnhgfoooiiiiiibfddddddddddddddddddddddddddddddddddddddddddddddddpppppjppppppppjppjjjjppboocioibhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhggnnfooiiiiccccbdddddddddddddddddddddddddddddddddddddddddddddddddpppppjpjjjjjpjjjpjpppppboibooibhhhhhhhhhbgggghhhhhhhhhhhhhhhhhgggbnboiiiiccbbbbbffdddddddddddddddddddddddddddddddddddddddddddddddpppppjjppppjjjpjjjppjbiobooiiibhhhhhhhhbbbbbbbbbbbbbbbbghhhhhggggboiiiiccbccooobbdddddddddddddddddddddddddddddddddddddddfdddddddpjppjppppjjjppppjjjjjboiboiibbbhhhhhhhhbhhggggggggggnnbghhhhggggbooiicccccooooooodddddddddddddddddddddddddddddddddddddddddddddddfpjjjpppjjppppppjjppboocbiibbcbhhhhhhhhhbhhhhhhggggbbbbhhhhhggggbciicccciiooooooiddddddddddddddddddddddddddddddddddddddddddddddddpppppjjjjjjjpjjppppboocbbbbccbhhhhhhhhhbbbbbbbbbbbbbbhhhhhgggggbccibcociiiooooiidddddddddddddddddddddddddddddddddfdddddddddddddddpppjjjjjjjpjjjppppboicbcioooobhhhhhhhhhbbbbccccccbbhhhhhhggggggbcbccoiiiiooiiiidddddddddddddddddddddddddddddddddfdddddddddddddfdppjjjjjpppjjjjppppboicccooiiibhhhhhhhhhbbccccccbbhhhhhhhgggggggnbccooiicioooiiidddddddddddddddddddddddddddddddddddddddddfdddddfddpjjjppppppjjjjjppbiiccooiccccbhhhhhhhhhhbbbbbbhhhhhhhhhggggggnnbccoiicbiiooiiidddddddddddddddddddddddddddddddddddddddddfddddddfdpppppppppjjjjjjjjbiiiiioccccccbhhhhhhhhhhhhhhhhhhhhhhhgggggggnfbccoiicbiiooiiidddddddddddddddddddddddddddddddddddddddddddddfddffdppppppjjjjjjppjjpbcccccccccccbhhhhhhhhhhhhhhhhhhhhhggggggggnnfbbcooicbiioiiicdddddddddddddddddddddddddddddddddddddddddddddfdddfdpjjjjjjjjjppppppppbcccccccccccbhhhhhhhhhhhhhhhhhhggggggggnnnnbccccoicbciiiiccdddddddddddddddddddddddddddddddddddfdddddddddddddfdfpjjjjjjppppppppjjpbbbccbbbbbbbgghhhhhhhhhhhhhhggggggggnnnnnfbccbccicbiicccccddddddddddddddddddddfdddddddfddddddddfdddddfdddffdfdjjpppjjpppppppjppppppbbbbbbbjjbggghhhhhhhhhgggggggggnnnnnnfffbcobcbbicccccccddddddddddddddddddddfddddddddddddddddddddddfddfddffdpppppjjpppjjjjjjpppppppjjjjpppjbbgggggggggggggggggnnnnnnffffbbciobiiicccccccddddddddddddddddddddddddddddddddddddddddddddddfdddfffpppppjjjjppppjjjjpppjjjjppppppjjbnngggggggggggnnnnnnnnfffbbbjbciioiccccccccdddddddddddddddddddddddddddddddddddddddfdddfdddddddfdppppjjjppppppjjjjjjjjjjjjjpppppjjbbbnnnnnnnnnnnnnnffffbbbjjjppbcciicccccccbddddddddddddddddddddddddddfddddddffdddddfdddddfddffddfppjjppppppppjjjjjjjpppppjjpppppbbnnbbbbbnnfffffbbbbbbffbbjjjjjbbcccccccbbpdddddddddddddddddddddddddddddddddddddddddddfddddddffffdjjppppppppjjjjjjppppppppjjjpjbooggnffibbbbbbbbjbnnnnffiibjjjjjjbbbbbbbpppdddddddddddddddddddddddddddddddddddddfdddddddfffdddfdddppppppppjjjpppppppppppppjjjjboocgggfiiibjjjjjjpboggggfcicbjjjpppjjpjppppjdddddddddddddddddffdddddddddffdddddffdddfffddfdfddffdfdfppjjjjjjjjjjppppppppppjjjjpboioooooiicbjjjjppboocgnnfiicbjjppppppjjpppjjdddddddddddddddddddddddddddddddddddfddddddfdddfdddddfddfjjjjjjjpppjjppppppppppjjjppbiiiiiiiiccbjjppppboioooiiicccbjjpppjjjjjjjjj"
function drawstring(s,x,y,w)
 xx=x yy=y
 for i=1,#s do
  pset(xx,yy,strtocol(sub(s,i,i)))
  xx+=1
  if (xx>=x+w) yy+=1 xx=x
 end
end

function strtocol(s)
 for i=1,16 do
  if (s==sub("abcdefghijklmnop",i,i)) return i-1
 end
 return 0
end

--player stuff
px=0
py=0
fx=0
fy=0
pg=0
pf=false
dead=false
gametitle = true
fadeout=-1
tictoc=false
tictoc2=0

stars=0
score=0
lives=5

airtime=0
stuntime=0

doravar=0
denzilvar=0
dylanvar=0
trollvar=0
dozyvar=0
grandvar=0
zaksvar=0
mermaidvar=0
saveddaisy=false

--checkpoint
cx=900
cy=0
cgx=0
cgy=0
checkinv3={0,0,0}

gameover=false
startgameover=false
gamewon=false


woff=0
yoff=0

kx=0
ky=0


texts={"","","","","","","","","",""}
textx={0,0,0,0,0,0,0,0,0,0}
texty={0,0,0,0,0,0,0,0,0,0}
textw={0,0,0,0,0,0,0,0,0,0}
texth={0,0,0,0,0,0,0,0,0,0}
textcols={0,0,0,0,0,0,0,0,0,0}

placename=""
placetime=0
function showplace()
 placename=""
 placetime=1.5
 
 if woff==0 then
  if (yoff==0) placename="zaks' chamber"
  if (yoff==1) placename="zaks' dark tower"
  if (yoff==2) placename="zaks' dark castle"
  if (yoff==3) placename="zaks' horrid dungeon"
 end
 if woff==1 then
  if (yoff==0) placename="treetops"
  if (yoff==1) placename="yolkfolk villiage"
  if (yoff==2) placename="pleasant woodland"
  if (yoff==3) placename="daisy's prison cell"
 end
 if woff==2 then
  if (yoff==0) placename="treetops"
  if (yoff==1) placename="canopy"
  if (yoff==2) placename="the shore"
  if (yoff==3) placename="dark waters"
 end
 if woff==3 then
  if (yoff==0) placename="tower view"
  if (yoff==1) placename="shining tower"
  if (yoff==2) placename="the castle moat"
  if (yoff==3) placename="murky waters"
 end
 if woff==4 then
  if (yoff==0) placename="cloudy sky"
  if (yoff==1) placename="castle gardens" 
  if (yoff==2) placename="the grand hall"
  if (yoff==3) placename="castle dungeon"
 end
 if woff==5 then  
  if (yoff==0) placename="rainy sky"
  if (yoff==1) placename="castle garden entrance"
  if (yoff==2) placename="castle hallway"
  if (yoff==3) placename="dank cells"
 end
 if woff==6 then
  if (yoff==0) placename="secret tower"
  if (yoff==1) placename="castle gallery"
  if (yoff==2) placename="castle well"
  if (yoff==3) placename="cave pool"
 end
 if woff==7 then
  if (yoff==0) placename="top of the ruins"
  if (yoff==1) placename="ancient ruins"
  if (yoff==2) placename="base of the ruins"
  if (yoff==3) placename="dark cavern"
 end
 if (yoff<0) placename="the sky"
 
end

itemname=""
itemtime=0
function showitem(t)
 itemname=""
 itemtime=1.5
 
 if(t==3)itemname="rusted key"
 if(t==4)itemname="fancy certificate"
 if(t==8)itemname="a snorkel"
 if(t==9)itemname="a sharp axe"
 if(t==10)itemname="a treasure chest"
 if(t==11)itemname="trendy umbrella"
 if(t==12)itemname="loaf of bread"
 if(t==13)itemname="a black cat"
 if(t==14)itemname="bag of rubbish"
 if(t==15)itemname="pristine bucket"
 if(t==16)itemname="gross dungeon apple"
 if(t==17)itemname="a slimy frog"
 if(t==18)itemname="ice cold milk"
 if(t==19)itemname="a heavy rock"
 if(t==21)itemname="enchanted ring"
 if(t==22)itemname="easter egg"
 if(t==23)itemname="a sharp dagger"
 
 if (itemname=="")itemtime=0
end

function actorhere(x,y,ac)
 for i=1,#actors do
  if x==actors[i].x and
     y==actors[i].y and
     ac==actors[i].t then
   return true
  end
 end
 return false
end

function goupdate()
for i=1,#actors do
 actor=actors[i]

 actype=actor.t
 acx=actor.x
 acy=actor.y
 aca=actor.a
 acb=actor.b
 acc=actor.c
 acwoff=actor.woff
 acyoff=actor.yoff
 
 --stars
 if actype==20 then
  if (aca==1) acx=9999
  if getdist(px,py-3,acx+4,acy+4)<7 then
   sfx(56)
   stars+=1
   score+=300
   acx=9999
   aca=1
  end
 end

 --carried objects
  if actor.p then
   if aca==1 then
    acx=px
    acy=py
    acwoff=woff
    acyoff=yoff
   end
  end


 if acwoff==woff and
    acyoff==yoff then

  --fire
  if actype==1 then
   if zaksvar<2 then
    for k=0,3 do
     sparkcol=7
     if (rnd()>0.5) sparkcol=9
     if (rnd()>0.5) sparkcol=10
     addpart(1,acx+2+(rnd()*4),acy+8,sparkcol,acb)
    end
   end
  end


  --spider/bee
  if (actype==2 or actype==30) and texts[1]=="" then
   if acb==false then
    acx+=0.5
    if (actorhere(acx,acy,-27))acb=true
   else
    acx-=0.5
    if (actorhere(acx,acy,-28))acb=false
   end
   
   acc=0
   if(actype==30) acc=sin(time+acy*0.2)*5
   
   if getdist(px,py,acx+4,acy+8+acc)<8 then
    dienow(true)
    if (actype==2) addtext("spider bites are bad!")
    if (actype==30) addtext("oh dear, stung by a bee!")
   end
  end
  
  --sprinkler
  if actype==5 then
   for k=1,2 do
    dropcol=7
    if (rnd()>0.5) dropcol=13
    addpart(2,acx+2+(rnd()*4),acy,dropcol)
   end
  end


 end

 

 actor.t=actype
 actor.x=acx
 actor.y=acy
 actor.a=aca
 actor.b=acb
 actor.c=acc
 actor.woff=acwoff
 actor.yoff=acyoff


end
--keep these outside the loop!
respawning=false

end

function flr8(v)
 return flr(v/8)
end

function godraw()
for i=1,#actors do
 actor=actors[i]
 actype=actor.t
 acx=actor.x
 acy=actor.y
 aca=actor.a

 if actor.woff==woff and
    actor.yoff==yoff then
  
  if actype==71 then
   spr(71,acx,acy,1,1,tictoc2>4)
  end

  --switch
  if actype==99 then
   actor.b=trollvar<2
   ospr2(110,acx,acy,actor.b,1,true)
  end
  
  --switch step
  if actype==88 and trollvar==2 then
   spr(252,acx,acy)
   mset(flr8(acx),flr8(acy),24)
  end
  
  --watergate
  if actype==116 then
   if mermaidvar<3 then
    spr(116,acx,acy)
   else
    mset(flr8(acx),flr8(acy),87)
    spr(87,acx,acy)
   end
  end
  
  --spider
  if actype==2 then
   sframe=23
   if (tictoc2>4) sframe=102
   ospr2(sframe,acx,acy,actor.b,1,true)
  end
  --bee
  if actype==30 then
   bframe=30
   if (tictoc and texts[1]=="") bframe=57
   ospr2(bframe,acx,acy+actor.c,actor.b,1,false)
  end

  --pickupable
  if actor.p and aca==0 then
   ospr2(actor.b,acx,acy,false,1,false)
  end
  
  --star
  if actype==20 and aca==0 then
    ospr2(241,acx+cos(time*0.5+acy*0.1),acy+sin(time+acy*0.1)*2,false,1,false)
  end
  

 end
end
end


function getdist(ax,ay,bx,by)
 a=ax-bx
 b=ay-by
 a*=0.01
 b*=0.01
 a=a*a+b*b
 a=sqrt(a)*100
 --clamp big numbers
 if(a<0) return 32767

 return a
end


function _init()
 music()
 
 for x=0,160 do
 for y=0,55 do
  tilenum=mget(x,y)
  
  if tilenum==116 then
   --watergate
   addactor(116,x,y,82)
  end
  if tilenum==71 then
   --waves
   addactor(71,x,y,mget(x,y-1))
  end
  if tilenum==110 then
   --switch
   addactor(99,x,y,77)
  end
  if tilenum==252 then
   --switch step
   addactor(88,x,y,77)
  end
  if tilenum==27 then
   --mob control
   addactor(-27,x,y,mget(x,y-1))
  end
  if tilenum==28 then
   --mob control
   addactor(-28,x,y,mget(x,y-1))
  end
  if tilenum==23 then
   --spider
   addactor(2,x,y,mget(x,y-1))
  end
  if tilenum==57 then
   --bee
   addactor(30,x,y,mget(x,y-1))
  end
  if tilenum==16 then
   --player
   px=x*8+4 py=y*8
   mset(x,y,13)
  end
  if tilenum==241 then
   --star
   addactor(20,x,y,mget(x,y-1))
  end
  if tilenum==253 then
   --fire
   addactor(1,x,y,237)
  end
  if tilenum==1 then
   --key
   addactor(3,x,y,0,true,1)
  end
  if tilenum==2 then
   --cert
   addactor(4,x,y,0,true,2)
  end
  if tilenum==4 then
   --snorkel
   addactor(8,x,y,77,true,4)
  end
  if tilenum==9 then
   --axe
   addactor(9,x,y,118,true,9)
  end
  if tilenum==63 then
   --treasure
   addactor(10,x,y,13,true,63)
  end
  if tilenum==5 then
   --umbrella
   addactor(11,x,y,0,true,5)
  end
  if tilenum==3 then
   --bread
   addactor(12,x,y,0,true,3)
  end
  if tilenum==6 then
   --cat
   addactor(13,x,y,0,true,6)
  end
  if tilenum==10 then
   --rubbish
   addactor(14,x,y,0,true,10)
  end
  if tilenum==7 then
   --bucket
   addactor(15,x,y,77,true,7)
  end
  if tilenum==8 then
   --apple
   addactor(16,x,y,77,true,8)
  end
  if tilenum==11 then
   --frog
   addactor(17,x,y,0,true,11)
  end
  if tilenum==59 then
   --milk
   addactor(18,x,y,0,true,59)
  end
  if tilenum==53 then
   --rock
   addactor(19,x,y,0,true,53)
  end
  if tilenum==54 then
   --ring
   addactor(21,x,y,87,true,54)
  end
  if tilenum==46 then
   --egg
   addactor(22,x,y,13,true,46)
  end
  if tilenum==26 then
   --dagger
   addactor(23,x,y,0,true,26)
  end
  if tilenum==242 then
   --sprinkler
   addactor(5,x,y,0)
  end
 

 end
 end
end

actors={}
function addactor(t,x,y,replacetile,p,s)
 a={}
 a.t=t
 a.x=x*8
 a.y=y*8
 a.a=0
 a.b=0
 a.c=0
 a.p=p--pickup
 if (s) a.b=s--sprite

 if (t==99) p=true
 a.woff=flr((x*8)/128)
 a.yoff=flr((y*8)/112)


 --mobs
 if t==2 or t==30 then
  a.b=false
  a.d=0
 end


 add(actors,a)

 if (replacetile != -1) mset(x,y,replacetile)
end


parts={}--particles
function addpart(t,x,y,a,b,c,d)
 p={}
 p.t=t
 p.x=x
 p.y=y
 p.a=a
 p.b=b
 p.c=c
 p.d=d
 p.life=10

 if t==1 then
  --spark
  p.fx=rnd()-0.5
  p.fy=(rnd()-1.5)*0.5
  if(b==1) then
   p.y-=8
   p.fy=(rnd()*1.5)*2.5
  end
  p.life=rnd()*15
 end
 if t==2 then
  --drop

  p.fx=(rnd()-0.5)*0.5
  p.fy=0
  p.life=50
  p.c=a
 end


 add(parts,p)
end

function doparticles()
clip(0,16,127,127)
for i=1,#parts do
part = parts[i]
if part then
  --sparks
 if part.t==1 then
  part.x+=part.fx
  part.y+=part.fy
  part.fy-=0.1
  part.fx*=0.9
  part.life-=1*(1+part.fx)
  if(part.life<3)part.a=5
  pset(part.x,part.y,part.a)
 end

 --drops
 if part.t==2 then
  lastx=part.x
  lasty=part.y
  part.x+=part.fx
  part.y+=part.fy

  if solid(part.x,part.y) then
   part.fy*=-0.3
   part.fx=(rnd()-0.5)*5*part.fy
   part.x=lastx
   part.y=lasty
   if solid(part.x,part.y+4) then
    while solid(part.x,part.y)==false do-- and
     part.y+=1
    end
   end
   part.y-=1
   part.life*=rnd()
  end

  part.fy+=0.1
  part.fx*=0.9
  part.life-=1

  line(lastx,lasty,part.x,part.y,part.a)
 end

 
 if part.life<0 then
  del(parts,part)
 end

end
end
clip()
end

inv3={0,0,0}
invhighlight=1

frame=1
anitime=0

stun={48,49}
idle={32,32,33,33}
walk={34,35,36,37}
jump={16,17,18,19,20,21,22,38}
stilljump={52,52,51,51,50,50,32,32}

function pickup(i)
 

 if actors[i].t==17 and dylanvar==2 then
  addtext("  ribbit",3,40,114,43,11)
   
  return
 end

 if (inv3[invhighlight]!=0) dropitem()
 inv3[invhighlight]=i
 actors[i].a=1
 ancl=false
 showitem(actors[i].t)
 return false
end

time=0
timedelta=0.033
function _update()
 tictoc=not tictoc
 
 if (tictoc and texts[1]=="") tictoc2+=1
 if (tictoc2>8) tictoc2=0

 time+=timedelta
 if(fadeout>=0)return

 if(gameover) return

 if gametitle then
  if btn"4" or btn"5" then
   sfx(51)
   fadeout=16
  end
  return
 end

 if(dead) respawnnow()

 goupdate()
 
 
 
 --input
 if texts[1]=="" and pg==1 and stuntime<0 then
  if(btn"0") fx-=0.2 pf=true
  if(btn"1") fx+=0.2 pf=false
 end

 if(stuntime>=0)stuntime-=1
 g=collidesfull(px,py+1,fy>=0,py)
 if fullpmfcheck(5) and fy>=0 then
  g=true
  fy=0.2
 end
 if g then
  --grounded
  checkpointnow(px,py,true)

  if (pg!=1)sfx(54)
  pg=1
  if(airtime>=20) stuntime=30

  if btnp"4" and texts[1]=="" and stuntime<0 then
   fy=-3.1
   sfx(53)
  end
 else
  --not grounded
  pg=0
  fy+=0.2
 end

 --forces
 if pg==1 and (btn"0"==btn"1" or texts[1]!="" or stuntime>0)then
  if fx>0 then
   fx=max(fx-0.6,0)
  else
   fx=min(fx+0.6,0)
  end  
 end
 fx=mid(-1.5,fx,1.5)
 fy=mid(-5,fy,3)
 
 if (fy>=3) airtime+=1
 if (fy<=0) airtime=0
 

 --move player
 moveplayer()


 ancl=true --action not claimed

 actionbtn=btnp"5"
 if (texts[1]!="") actionbtn=false

 
 --pick up actors
 if actionbtn and pg==1 and ancl then
 for i=1,#actors do
  actor = actors[i]
 if pbox(px,py,actor.x,actor.y,8,16) then

   if actor.t==99 then
    addtext("dizzy struggles with the switch, but is not strong enough to move it",0,30,80,70,35)
    addtext("only i can open the way to zaks' chamber",3,50,20,70,22)
    ancl=false
   end

   if actor.p and actor.a==0 and ancl then
    ancl=pickup(i)
   end


 end
 end

  if ancl and inv3[invhighlight]!=0 then
    dropitem()
  end
 end



 --interactions
 ptile1=pmsget()
 
 
 if actionbtn and pg==1 and ancl then
  if ptile1==115 then
   addtext("dizzy finds a small worm perched on a brick",0,30,80,70,28)
   addtext("have you seen daisy, small worm?",6,6,60,50,22)
   addtext("...",3,70,62,20,11)
   addtext("...",3,70,64,20,11)
   addtext("...",3,70,66,20,11)
   addtext("she's probably in another dungeon.",3,52,68,65,22)
   ancl=false
  end
  
  --dozy
  if ptile1==39 then
   if dozyvar==0 then
    addtext("dozy, wake up!",6,30,30,70,11)
    addtext("dizzy tries to wake dozy, but nothing will get him up",0,30,80,70,28)
    dozyvar=1
   end
   if dozyvar==1 then
    addtext("it looks like dozy is sleeping on something...",0,30,80,70,22)
    addtext("but dizzy can't move dozy to get at it",0,30,80,70,22)
   end
   if dozyvar==2 then
    addtext("dozy has gone back to sleeping peacefully",0,30,80,70,22)
   end
   ancl=false
  end
  --daisy
  if ptile1==61 then
   if stars<30 then
    addtext("daisy has been petrified by a spell!",0,30,20,70,28)
    addtext("dizzy will need to find all 30 stars to release her!",0,30,20,70,28)
    
   else
    addtext("all the stars dizzy has collected begin to shine brightly!",0,30,20,70,34)
    addtext("oh dizzy! you saved me!",14,40,32,60,16)
    addtext("i'm so glad you're ok daisy!",6,10,30,50,22)
    
    
    score+=5000
    gamewon=true
    startgameover=true
    saveddaisy=true
   end
   ancl=false
  end
  --denzil
  if ptile1==60 then
   if denzilvar==0 then
    addtext("hi denzil",6,10,30,50,11)
    addtext("yo dizzy! what's up?",1,40,32,60,16)
    addtext("i'm looking for a way to rescue daisy",6,10,34,70,22)
    addtext("i can't help you there diz, i'm just here chilling",1,40,36,70,28)
    denzilvar=1
   end
   if denzilvar==1 then
    addtext("ancient ruins are so cool, totally my scene.",1,40,38,70,28)
    addtext("i doubt they could be any cooler, right diz?",1,40,40,70,28)
    addtext("if you could make it any cooler, i'd gladly give up this cool thing i found.",1,40,42,70,40)
   end
   if denzilvar==2 then
    addtext("thanks dizzy, now i'm cooler than ever!",1,40,30,70,22)
   end
   ancl=false
  end
  --dylan
  if ptile1==55 then
   if dylanvar==1 then
    addtext("hey man, have you found my green buddy yet?",13,50,30,70,22)
    
   end
   if dylanvar==0 then
    addtext("hello dylan",6,10,30,50,11)
    addtext("hey man, have you seen this place?",13,50,30,70,22)
    addtext("it's so green! i really dig it",13,50,32,70,16)
    addtext("i had a green buddy here with me before too",13,50,34,70,22)
    addtext("but they went somewhere",13,50,36,70,16)
    addtext("a green buddy? ok i'll look for them for you.",6,10,38,70,22)
    dylanvar=1
   end
   if dylanvar==2 then
    addtext("ahh man, everything is like, perfect!",13,50,30,70,22)
   end
   
   ancl=false
  end
  
  --grand dizzy
  if ptile1==40 then
   if grandvar==1 then
    addtext("have you found my key yet, young dizzy?",13,50,30,70,22)
   end
   if grandvar==0 then
    addtext("ah young dizzy! i need some help!",13,50,30,70,22)
    addtext("what is it grand dizzy?",6,40,90,50,22)
    addtext("i've lost the key to my house, i'm locked out!",13,50,30,70,22)
    addtext("i'll find your key for you!",6,40,90,50,22)
    grandvar=1
   end
   if grandvar==2 then
    addtext("thank you dizzy, you're such good egg.",13,50,30,70,22)
   end
   ancl=false
  end
  
  --dora
  if ptile1==56 then
   if doravar==0 then
    addtext("hello dora, how are you?",6,10,55,60,16)
    addtext("oh dizzy, it's terrible!",2,50,60,70,16)
    addtext("what is?",6,10,66,60,11)
    doravar=1
   end
   if doravar==1 then
    addtext("i want to go into the garden...",2,50,60,75,16)
    addtext("but it's raining! i'll get drenched!",2,50,62,77,16)
   end
   if doravar==2 then
    addtext("thank you dizzy!",2,50,60,70,11)
   end
   
   ancl=false
  end
  
  --zaks
  if ptile1==125 then
  
   if zaksvar<1 then
    addtext("the evil wizard zaks cackles at dizzy, unafraid!",0,30,20,70,22)
    addtext("haha dizzy, i shall keep daisy trapped forever!",2,10,30,70,22)
   else
    addtext("when i get my magic back dizzy, watch out!",2,10,30,70,28)
   end
   
   ancl=false
  end
  
  --mermaid
  if ptile1==94 or ptile1==62 then
   if mermaidvar==1 or mermaidvar==2 then
    addtext("fair egg, have you found my treasure yet?",13,10,30,70,22)
   end
   if mermaidvar==0 then
    addtext("oh fair egg, woe is me!",13,10,30,70,16)
    addtext("the evil wizard zaks took my treasure!",13,10,32,70,22)
    addtext("if you bring back my treasure, i will give you something special;",13,10,34,70,40)
    addtext("an enchanted ring that removes zaks' magic power!",13,10,36,70,28)
    mermaidvar=1
   end
   if mermaidvar==3 then
    addtext("thank you, fair egg! i love this hat!",13,10,30,70,22)
   end
   ancl=false
  end
  
  --troll
  if ptile1==124 then
   if trollvar==1 then
    addtext("have you not found my certificate yet?",3,50,20,70,22)
    addtext("none shall pass!",3,50,32,70,10)
   end
   if trollvar==0 then
    addtext("none shall pass!",3,50,30,70,10)
    addtext("zaks has ordered me to keep you out!",3,50,22,70,22)
    addtext("why do you work for an evil wizard?",6,4,50,70,22)
    addtext("i'm not qualified for anything else, not anymore",3,50,20,70,28)
    addtext("anymore?",6,4,52,50,11)
    addtext("i had a certificate, but zaks threw it away",3,50,20,78,22)
    addtext("if i find it, will you help me?",6,4,54,70,22)
    addtext("sure, but until then... none shall pass!",3,50,20,70,22)
    trollvar=1
   end
   if trollvar==2 then
    addtext("thanks dizzy, now i can get a job as an interior designer again!",3,2,30,70,34)
   end
   
   ancl=false
  end
  
 end

end

function  dropitem()
 invactor=actors[inv3[invhighlight]]

 kill=false
 ptile1=pmsget()
 
 dontdrop=false
 
 --snorkel
 if invactor.t==8 and fullpmfcheck(4) then
  dontdrop= true
 end
 
 if invactor.t==10 and mermaidvar==1 then
  --treasure chest
  if ptile1==62 or ptile1==94 then
   addtext("what is this? that's just crummy gold. that's not ~my~ treasure!",13,10,30,70,34)
   
   mermaidvar=2
   score+=100
   dontdrop=true
  end
 end
 if invactor.t==15 and mermaidvar<3 and mermaidvar>0 then
  --bucket
  if ptile1==62 or ptile1==94 then
   addtext("oh you found my treasure!",13,10,30,70,16)
   addtext("thank you, fair egg! this is my favourite hat!",13,10,32,70,22)
   addtext("you are welcome to take the enchanted ring.",13,10,34,70,22)
   addtext("but be careful, zaks will be dangerous until he touches the ring!",13,10,36,70,34)
   sfx(55)
   mermaidvar=3
   score+=1000
   kill=true
  end
 end
 
 if invactor.t==21 then
  --ring
  if ptile1==125 then
   addtext("the enchanted ring drains all of zaks' magic!",0,30,20,70,22)
   addtext("the magical fires burn out!",0,30,20,70,16)
   addtext("curse you dizzy! you win this time!",2,10,30,70,22)
   
   zaksvar=2
   score+=5000
   kill=true
  end
 end
 if invactor.t==11 then
  --umbrella
  if ptile1==56 and doravar>0 then
   addtext("hey dora, here's an umbrella",6,10,60,75,16)
   addtext("thanks dizzy!",2,60,64,60,11)
   
   score+=1000
   doravar=2
   kill=true
  end
 end
 if invactor.t==18 then
  --milk
  if ptile1==60 and denzilvar>0 then
   addtext("denzil, i found a way to make this place cooler",6,10,30,70,28)
   addtext("wow seriously?",1,40,32,70,11)
   addtext("here's some ice cold milk!",6,10,34,70,16)
   addtext("wow thanks! ok you can have this",1,40,36,70,22)
   
   addactor(17,flr8(px-4),flr8(py-7),-1,true,11)
   
   score+=1000
   denzilvar=2
   kill=true
  end
 end
 if invactor.t==17 then
  --frog
  if ptile1==55 and dylanvar>0 then
   addtext("woa, dizzy man! you found my green buddy!",13,50,30,70,22)
   addtext("thanks man, right on!",13,50,30,70,16)
   
   addactor(17,flr8(px-14),flr8(py-7),-1,true,11)
   
   score+=1000
   dylanvar=2
   kill=true
  end
 end

 --certificate
 if invactor.t==4 then
  if ptile1==124 and trollvar>0 then
   addtext("wow, with this i can get a better job!",3,50,20,70,22)
   addtext("thank you dizzy, i'll let you pass now.",3,50,20,70,22)
   sfx(55)
   score+=1000
   trollvar=2
   kill=true
  end
 end
 
 --cat
 if invactor.t==13 then
  if ptile1==39 and dozyvar>0 then
   addtext("the cat is irritated by dozy's snoring!",0,30,80,70,22)
   addtext("it leaps at dozy, and starts scratching him before running away!",0,30,80,70,34)
   
   addtext("~yawn~ oh hi dizzy, i was having a nice long sleep",1,60,50,65,28)
   addtext("what woke me up?",1,60,50,65,16)
   addtext("never mind that dozy, can i have that thing you're lying on?",6,10,60,65,34)
   addtext("oh, ok.",1,60,50,45,11)
   addtext("dozy rolls over revealing a trendy umbrella and goes back to sleep.",0,30,80,70,34)
   
   addactor(11,flr8(px+8),flr8(py-7),-1,true,5)
   
   
   score+=1000
   dozyvar=2
   kill=true
  end
 end
 
 --key
 if invactor.t==3 then
  if ptile1==40 and grandvar>0 then
   addtext("here's your key, grand dizzy!",6,40,90,50,22)
   addtext("thank you dizzy!",13,50,30,70,11)
    
   score+=1000
   grandvar=2
   kill=true
  end
 end
 
 if not kill and
   (ptile1==39 or
   ptile1==40 or
   ptile1==55 or
   ptile1==56 or
   ptile1==60 or
   ptile1==61 or
   ptile1==124 or
   ptile1==62 or
   ptile1==94 or
   ptile1==115) then
  return
 end
 
 ancl=false
 if (dontdrop) return

 invactor.x=px-4
 invactor.y=py-7
 invactor.a=0
 invactor.woff=woff
 invactor.yoff=yoff

 inv3[invhighlight]=0
 
 if (kill)invactor.x=-99
 
end


function moveplayer()
 fromx=px
 fromy=py

 px+=fx
 py+=fy
 
 oneway = fromy<py
 
 --foot collision
 if collidesfull(px,py,oneway,fromy) then
  if collidesfull(fromx,py,oneway,fromy) then
   --floor/ceiling
   px=fromx
   py=fromy
   fy=0
  else
   if collidesfull(px,fromy) then
    --wall
    px = fromx
   end
  end

  if collidesfull(px,py) then
   --still collides
   px=fromx
   py=fromy
   fx=0
   fy=0
  end
 end

 --spikes
 if mfget(px,py+1,2) and fy>0 then
  addtext("look out for spikes!")
  dienow()
 end

 --fire
 if not dead and zaksvar<2 then
  if fullpmfcheck(3) then
  
   addtext("poached!")

   dienow(true)
  end
 end

 
 gotsnorkel = false
 if (inv3[1]>0 and actors[inv3[1]].t==8) gotsnorkel = true
 if (inv3[2]>0 and actors[inv3[2]].t==8) gotsnorkel = true
 if (inv3[3]>0 and actors[inv3[3]].t==8) gotsnorkel = true
 if not dead and not gotsnorkel then
  if fullpmfcheck(4) then
   addtext("can't breathe in water!")
   dienow()
  end
 end

end



function checkpointnow(x,y,g)
 if (gametitle) return


 checkinv3=inv3
 if g then
  cgx=x
  cgy=y
 else
  cx=x
  cy=y
 end
end

function dienow(s)
 lives-=1
 
 sfx(50)
 
 spawnatground=true
 if (s) spawnatground=false
 if (woff==2 and yoff==2) spawnatground=true
 
 if lives<0 then
  addtext("run out of lives!",0,30,30,70,11)
  startgameover=false
  gameover=true
  fadeout=16
  dead=false
  lives=0
  return
 end

 fadeout=16
 
 fx=0
 fy=0
 kx=px
 ky=py
 dead=true
end

function respawnnow()
 px=cx+4
 py=cy+8
 if spawnatground then
  px=cgx
  py=cgy
 end
 dead=false
 respawning=true

 inv3=checkinv3
end

--screen mget
function msget(x,y)
 return mget(flr8(x),flr8(y))
end

--player msget
function pmsget(b)
 if (b)return msget(px,py-b)
 return msget(px,py)
end

function mfget(x,y,f)
 maptile=mget(flr8(x),flr8(y))
 return fget(maptile,f)
end

function solid(x,y)
	return mfget(x,y,0)
end

function solidtop(x,y)
 maptile=mget(flr8(x),flr8(y))
 if (fget(maptile,1)) return true
 return false
end

--player flag check
function fullpmfcheck(f,yoff)
 y2=0
 if (yoff) y2=yoff
 x2=2
 while x2>-3 do
  if (mfget(px+x2,py-y2,f)) return true
  x2-=1
 end
 return false
end

--collision checks
function collidesfull(x,y,owc,y2)
 x2=2
 if(btn"3")owc=false
 while x2>-3 do
  if (collides(x+x2,y,owc,y2)) return true
  x2-=1
 end
 return false
end


function collides(x,y,onewaycheck,y2)
 if (solid(x,y) or (onewaycheck and solidtop(x,y) and solidtop(x,y2)==false)) then
  return true
 else
  ycol=7
  if (solid(x,y-ycol)) return true
  return false
 end
end


wfade={1,2,3,5,13,13,15,7,9,10,7,10,6,6,15,7,7}
bfade={0,0,1,5,5,2,15,6,4,4,9,3,13,5,13,14}
function fadepix(col,lookup)
 return lookup[col+1]
end


--pointinbox?
function pbox(x,y,bx,by,w,h)
 if bx>x or
     bx+w<x or
     by>y or
     by+h<y then
  return false
 end

 return true
end

--pointincircle?
function pcirc(x,y,rad,ax,ay)
 if(pbox(x,y,ax-rad,ay-rad,rad*2,rad*2)==false) return false
 distx=ax-x
 disty=ay-y
 distx*=distx
 disty*=disty
 if (distx+disty>rad*rad)return false
 return true
end

function addtext(text,col,x,y,w,h)
 inputwait=0
 for i=1,#texts do
  if texts[i]=="" then
   texts[i]=text
   textcols[i]=0
   if (col) textcols[i]=col
   textx[i]=15
   texty[i]=60
   textw[i]=100
   texth[i]=10
   if (x) textx[i]=x
   if (y) texty[i]=y
   if (w) textw[i]=w
   if (h) texth[i]=h
   return
  end
 end
end

--remove first text in buffer
function removetext()
 tc=#texts
 for i=1,tc-1 do
  texts[i]=texts[i+1]
  textcols[i]=textcols[i+1]
  textx[i]=textx[i+1]
  texty[i]=texty[i+1]
  textw[i]=textw[i+1]
  texth[i]=texth[i+1]
 end
 texts[tc]="" textcols[tc]=0
 textx[tc]=0 texty[tc]=0 textw[tc]=0 texth[tc]=0
end

inputwait=0
function showtext()
 if(gametitle)return
 
 if texts[1]!="" then
  rectfill(textx[1],texty[1],textx[1]+textw[1],texty[1]+texth[1],textcols[1])
  line(textx[1]+2,texty[1]+1,textx[1]+textw[1]-2,texty[1]+1,7)
  line(textx[1]+2,texty[1]+texth[1]-1,textx[1]+textw[1]-2,texty[1]+texth[1]-1,7)
  line(textx[1]+1,texty[1]+2,textx[1]+1,texty[1]+texth[1]-2,7)
  line(textx[1]+textw[1]-1,texty[1]+2,textx[1]+textw[1]-1,texty[1]+texth[1]-2,7)
  print(wwrap(texts[1],(textw[1]/4)-1),textx[1]+3,texty[1]+3,7)
  inputwait+=1
  if btnp"5" and inputwait>5 then
   inputwait=0
   removetext()
  end  
 end
 
end

function wrap(v,max)
 while v>max do v-=max end
 while v<0 do v+=max end
 return v
end


function _draw()

 --fadeout
 camera()
 if startgameover and texts[1]=="" then
  gameover=true
  fadeout=16
  startgameover=false
 end
 if fadeout>=0 then
  kx=wrap(kx,128)
  ky=wrap(ky,111)


  fadeout-=1
  fadey=111
  fade=bfade
  if gameover then
   fade=wfade
   fadey=127
  end
  if(fadeout==0)gametitle=false
  fadey+=16
  for x=0,127 do
   for y=0,fadey do

    pix=pget(x,y)

    if fadeout<8 or gametitle or gameover then
     pix=fadepix(pix,fade)
    else
     if pcirc(x,y,20,kx,ky+6)==false then
      pix=fadepix(pix,fade)
     end
    end
    if(pix>=0) pset(x,y,pix)
   end
  end
  return
 end

 if gameover then
  camera()
  rectfill(0,0,127,127,1)
  line(2,1,125,1,0)
  line(1,2,1,125,0)
  line(2,126,125,126,0)
  line(126,2,126,125,0)
  
  rectfill(15,55,114,105,12)
  line(16,54,113,54,12)
  line(16,106,113,106,12)
  line(17,55,112,55,7)
  line(16,56,16,104,7)
  line(17,105,112,105,7)
  line(113,56,113,104,7)
  
  rectfill(34,9,98,26,12)
  line(35,8,97,8,12)
  line(35,27,97,27,12)
 
  palall(0)
  spr(227,35,10,8,2)
  spr(227,37,10,8,2)
  spr(227,36,9,8,2)
  spr(227,36,11,8,2)
  pal()
  spr(227,36,10,8,2)
  
  ospr(56,24,93,false,0)
  ospr(47,36,93,false,0)
  ospr(60,48,93,false,0)
  ospr(32,60,93,false,0)
  ospr(61,72,93,false,0)
  ospr(40,84,93,false,0)
  ospr(55,96,93,false,0)
  pal()

  if (doravar==2)ospr2(56,24,93,false,0)
  if (dozyvar==2)ospr2(47,36,93,false,0)
  if (denzilvar==2)ospr2(60,48,93,false,0)
  if (saveddaisy)ospr2(61,72,93,false,0)
  if (grandvar==2)ospr2(40,84,93,false,0)
  if (dylanvar==2)ospr2(55,96,93,false,0)



  oprint('game over',47,116,13,5)

  if gamewon then
   oprint('you win!',50,40,7,9)
   ospr2(241,26,40,false,0)
   ospr2(241,96,40,false,0)
   ospr2(32,60,93,false,0)
  else
   oprint('you lose!',48,40,7,5)
  end
  
  sprint("score:",25,62,7,13)
  sprint(score,106-textwidth(score),62,7,13)
  sprint("stars found:",25,70,7,13)
  sprint(stars,106-textwidth(stars),70,7,13)
  sprint("lives left:",25,78,7,13)
  sprint(lives,106-textwidth(lives),78,7,13)

  return
 end

 cls()
 rectfill(0,16,127,111,12)

 lwoff=woff
 lyoff=yoff
 woff=flr(px/128)
 yoff=flr(py/112)
 if (lwoff<woff) checkpointnow(flr8(px+4)*8,py-8)
 if (lwoff>woff) checkpointnow(flr8(px-4)*8,py-8)
 
 if lyoff!=yoff then
  checkpointnow(px-4,py-8)
 end

 srand(time)

 if gametitle then


  woff=0 yoff=1
  camera(0,112)
  savescr()
  loadscr()
  camera(0,0)
 
 
  
  --draw title
  --rectfill(0,0,128,16,12)
  palall(0)
  ty =23+sin(time)*6
  --ty=4
  spr(227,63,ty,8,2)
  spr(227,65,ty,8,2)
  spr(227,64,ty-1,8,2)
  spr(227,64,ty+1,8,2)
  pal()
  spr(227,64,ty,8,2)
  
  scroll-=timedelta*15
  if (scroll<-400) scroll=128
  print("’ sophie houlden   @gruber_music / matthew simmonds  ‡ inspired by classic dizzy games",scroll,4,5)
  
  if sin(time*2)>0 then
   oprint("press button",10,100,10,1)
  end
  
  camera(0,112)
  return

 else
  --draw stuff above game
  
  invspra=0 invsprb=0 invsprc=0
  
  if (inv3[1]!=0) invspra=actors[inv3[1]].b
  if (inv3[2]!=0) invsprb=actors[inv3[2]].b
  if (inv3[3]!=0) invsprc=actors[inv3[3]].b

  if btnp"2" and texts[1]=="" then
   invhighlight+=1
   if (invhighlight==4)invhighlight=1
   if inv3[invhighlight]!=0 then
    showitem(actors[inv3[invhighlight]].t)
   else
    showitem(0)
   end
  end


  spr(invspra,96,4)
  a=(invhighlight*11)+81
  line(3+a,2,12+a,2,6)
  line(2+a,13,2+a,2,6)
  line(3+a,13,12+a,13,6)
  line(13+a,13,13+a,2,6)
  
  spr(invsprb,107,4)
  spr(invsprc,118,4)
  
  --draw title again
  spr(231,55,-1,4,2)
  
  
  print("’",0,1,6)
  print(stars,9,1,6)
  for i=1,lives do
   print("‡",14+i*6,1,6)
  end
  
  print("score:",0,8,6)
  print(score,25,8,6)
  
 end


 camera(woff*128,(yoff*112)-16)




 savescr()
 loadscr()

 

 --draw actors
 godraw()

 --particles
 doparticles()
 
 

 --anim
 curani={}
 if pg==0 then
  curani=jump
  if (fx==0) curani=stilljump
 else
  curani=idle
  if btn"0" != btn"1" and texts[1]=="" then
   curani=walk
  end
 end
 if (stuntime>0)curani=stun

 lastframe=frame
 anitime+=0.5
 if (anitime>1) anitime=0 frame+=1
 if (frame>#curani) frame=1
 
 animsprite=curani[frame]

 --walk sfx
 if frame==2 and lastframe!=frame then
  if (curani==walk) sfx(52)
 end

 --draw player
 ospr2(animsprite,px-4,py-7,pf,1,true)

 ripple()
 
 camera()
 
 if itemtime>0 then
  clip(0,16,128,128)
  w=#itemname*4
  x=127-w
  y=10+min(6,itemtime*30)
  rectfill(x,y,x+w,y+6,0)
  print(itemname,x+1,y+1,7)
  itemtime-=timedelta
  clip()
 end
 if placetime>0 then
  clip(0,16,128,128)
  w=#placename*4
  x=64-w/2
  y=10+min(6,placetime*30)
  rectfill(x,y,x+w,y+6,0)
  print(placename,x+1,y+1,7)
  placetime-=timedelta
  clip()
 end
 
 showtext()

end

function oprint(s,x,y,col,ocol)
 print(s,x-1,y-1,ocol)
 print(s,x+1,y-1,ocol)
 print(s,x-1,y+1,ocol)
 print(s,x+1,y+1,ocol)
 print(s,x-1,y,ocol)
 print(s,x+1,y,ocol)
 print(s,x,y-1,ocol)
 print(s,x,y+1,ocol)
 print(s,x,y,col)
end
function sprint(s,x,y,col,ocol)
 print(s,x,y+1,ocol)
 print(s,x,y,col)
end

function textwidth(num)
 if (num>=10000) return 20
 if (num>=1000) return 16
 if (num>=100) return 12
 if (num>=10) return 8
 return 4
end


function palall(v)
 pal(1,v)
 pal(2,v)
 pal(3,v)
 pal(4,v)
 pal(5,v)
 pal(6,v)
 pal(7,v)
 pal(8,v)
 pal(9,v)
 pal(10,v)
 pal(11,v)
 pal(12,v)
 pal(13,v)
 pal(14,v)
 pal(15,v)
end

--draw sprite outline
function ospr(s,x,y,f,o,notdown)
 palall(o)
 spr(s,x,y-1,1,1,f)
 spr(s,x-1,y,1,1,f)
 spr(s,x+1,y,1,1,f)
 if (not notdown) spr(s,x,y+1,1,1,f)
end

--draw sprite and outline
function ospr2(s,x,y,f,o,notdown)
 ospr(s,x,y,f,o,notdown)
 pal()
 spr(s,x,y,1,1,f)
end


function ripple()
 if (yoff!=3 or woff<2 or woff>3) return
 o=0
 for i=1,110 do
  o+=0.03
  memcpy(scrnpointer+(i*64),scrnpointer+(i*64)+(sin((time+o)*0.5)*2),62)
 end
end




scrnbffrpointer = 0x4300
scrnpointer = 0x6000+1024
scrnbffrlen = 7168
lastwoff=-1 lastyoff=-1
function savescr()
 if (lastwoff==woff and lastyoff==yoff) return

 showplace()

 lastwoff=woff
 lastyoff=yoff

--bg


--draw clouds
 srand(73+(woff-13)*((yoff*12.3)+58))
 y = yoff*112+16
 x = woff*128
 s = 10
 while y<(yoff*112)+110+16 do
   s = rnd(30)+20
   x = rnd(127)+(woff*128)
   y += rnd(30)+10
  drawcloud(x,y,s)
 end
 srand(time)

 --map outline
 palall(1)
 map(woff*16,yoff*14,(woff*128)+1,yoff*112,16,14)
 map(woff*16,yoff*14,(woff*128)-1,yoff*112,16,14)
 map(woff*16,yoff*14,woff*128,(yoff*112)+1,16,14)
 map(woff*16,yoff*14,woff*128,(yoff*112)-1,16,14)
 pal()


 --draw map
 map(woff*16,yoff*14,woff*128,yoff*112,16,14)

 if gametitle then
  camera()
  rectfill(0,0,128,128,12)
  drawstring(img,0,22,128)
  rectfill(0,120,128,128,0)
 end

 memcpy(scrnbffrpointer,scrnpointer,scrnbffrlen)
end

function drawcloud(x,y,csize)
 
 w = rnd(10)+10
 while w>0 do
   x2 = rnd(csize)
   s2 = rnd((csize-x2)/2)+2
   if(rnd(100)>50)x2=-x2
   circfill(x+x2,y,s2,6)
   circfill(x+x2,y-1,s2-2,7)
   circfill(x+x2-1,y,s2-2,7)
   circfill(x+x2,y,s2-2,6)
   circfill(x+x2+1,y,s2-2,6)
   circfill(x+x2-2,y+2,s2-2,6)
   line(x+x2-s2-0,y+1,x+x2-s2+1,y+1,12)
   line(x+x2+s2-1,y+1,x+x2+s2+0,y+1,12)

   w -=1
 end

 --clear screen below
 rectfill((woff*128),y+2,(woff*128)+128,(yoff*112)+111,12)
end

function loadscr()
 memcpy(scrnpointer,scrnbffrpointer,scrnbffrlen)
end

--word wrap
function wwrap(s,w)
 retstr = ""
 linelen=0
 words = strspl(s," ")
 for k=1, #words do
  wrd=words[k]
  if (linelen+#wrd>w)then
   retstr=retstr.."\n"
   linelen=0
  end
  retstr=retstr..wrd.." "
  linelen+=#wrd+1
 end
 retstr=retstr.."\n"
 return retstr
end
 
function strspl(s,sep)
 ret = {}
 bffr=""
 for i=1, #s do
  if (sub(s,i,i)==sep)then
   add(ret,bffr)
   bffr=""
  else
   bffr = bffr..sub(s,i,i)
  end
 end
 if (bffr!="") add(ret,bffr)
 return ret
end
__gfx__
05555550000099000fffff940000000000000009000d0000d000d000006666000030330000007700000dd5000000000000076d5766666d576d576500d50000d6
5000000500094490f44f4959004444000888880908e8e800550d500d06555d6000838220000766000000500003b33b300006dd56dddddd56dd56d5005500006d
5000000500009090fffff9000494444086cc6c848e8e8e80515150d00655d56008888822000766650005d5000b1bb1b00006dd56dddddd56dd56d5005500005d
5000000500094900f4f499004f7f44558cc8cc84282828205d4d505006155d608778882200000650005d5550003bb30000005505550555055505500050000005
5000000500940000ff99990059f955500880880900050000055510500d666650878882220000450005ddd55500033000007666666d57666666666d50d50000d6
5000000509400000094944f04777444500000009000d0000011155500dd5d51028882222000450005d55555503b55b30006ddddddd56dddddddddd505500006d
50000005949000000999fff04f7f445500000909000808000555515000dd550002822220004500005555555501b11b10006ddddddd56dddddddddd50550000d5
0555555009000000ff9f9f005444555000000090000080000d1d1d5000d5d10000202200045000000555555053b00b3500055515550555155505550050000005
00077000000000000000000008000000000880000000008000000000000000007afafaff111af91100000002888788877888788800000000007d6d00d1ddd126
0077760000007700000670008286600000028000000662280006500000000000f999999411a999410000d0208877887777887788000000000076dd005155512d
00777500006777700067777002886600006886000056888006575600000000004444444411a44f910000520087788778877887780000000000065d001e15181d
0777776006677d7088887777068877000558876000778860777788280dd00d805505550511f42f91000765d07788778888778877000000000009a40018121812
067885500688770082887777066777700677777007d7766077778888dd5522266d576666119229910076500077887788887788770000000000a4965618211821
0068860008886500006575600057d770005777000777760007777600d5522210dd56dddd191424f9006500008778877887788778000000000794455288218821
0008200082266000000560000000770000677700007700000007600001000100dd56dddd112b32410650000088778877778877880b00b0037d49442084218421
0008800008000000000000000000000000077000000000000000000020502050550555151414214160000000888788877888788803b030b00042200042214221
000770000000000000077000000770000007700000077000000000002122222200000000000400000776dd600dddddd000000000000000000000000000000000
00777600000770000077760000777600007776000077760000770000222222520077760000050000077dd6d0077767d000000002000000000007700000000000
0076d6000077760000777500007775000077750000777500077d7500222112220065d60000040000076d7dd00d666dd000000222000000000077770000000000
076775608876d688087777600777776007777780077777600777766021165122077777600005000006776dd001dddd100000022200000000007e7e0000065000
8775566888677588888775520678855027777888067885500077886016575611877dd668000400000776dd600666ddd000000252000000000777766006575600
88666688067556608866662200688600226666880068860000668820777766188866668400050000077dd6d007666dd0000022220000030007e77e6077776608
00266200006666000226688000068200088662200022620000066828776886880026620400040000076d7dd00776ddd00022222200b30b000777662077688688
0082880000825800008000800002880000800080002828000000008056828688008288040005000006776dd007766dd022212222030303b00066e20056828688
a00000000000000a0000000008802880000000000000000000777c00000770e000424200077006d007766dd00060006000077000090990f0414442410f944f90
9f07700aa00770f9007776000827728000676600000000000767c6c000333300042774200766ddd007766dd00006160000777600f497794f11b43314f444f459
40777df99f67760408877880007777000677766000555500007c6c000076d6000425d42000765d0007766dd00061116000111100907dc60917bbb31411119145
0075d604407d56000826728007777760887776880566dd500047c40007777660077777600009a40007766dd00067766007d1d160077777601bbb331400a9a914
0777766007777660822672288877778888777688566dddd500099000877556688778866800a4965607776dd00067766087777668877886687bb3331109aa99a1
87755668877556688866668888777688067666605ddddd5500900900886666888866668807944552016ddd10006776608865568888666688bb333111f444f455
28666682286666820066660000776600006dd6005dd555550090090000266200002dd2007d49442006776dd00067666000266200002ee20033331111f444f455
082662800826628000000000000660000000000005555550000990000082880000828800004220000766d6d00006660000828800008288003331111154445455
677777666777776603b0b3b00b3b3bb0b33bb33b33b00bb000000000000000000111111000000000000000000000000026515526ddddd526dddd265177676766
7666666d7666666db33b333bb333b33b3b333b333b3bb33b0033000011001100488888840000000000000000000000006116152d5555552d555261166dddddd1
7666666d7666666d3b333333333333333333b33b33333b3bf03000007711771118988981004f00000000000000004f006126152d5555552d5552612611111111
7666666d7666666d33333333133b3311133333333333333b544f0300cc77cc771888888200f4500000f400000005f40016612222220222022222266122022202
7666666d7666666d13333311113331113313311113313311335444f0c1ccc1cc1898898200450450054540000540450021161662d526dddd26626112d526dddd
7666666ddd66666d00133122221314222222211111443310030054441cc11cc11888888200f4000440f405004000f40055216116552d555561161555552d5555
766666dddddd66dd0222122442222222222422222222212000000054111c111c18988982004500000045004500004500552d1661552d555516612555552d5555
6ddddddddddddddd024424fff44444244ff44ff4422ff420000000051c111c111888888200440000004400000000440022222112220222122112221222022212
677777666776007604444244444424244444444422244420dd141526111111110898898200000000666600000000000067777776519944151111111141111114
7666666d766dd76d004442224422242222244444222444205515152d11111111088888820000006677776666000000007666677719444441111311441ccc66cd
7666dd6d766d766d0044444ff244224244424422222222005514152d11c1111108988982000006777777777766600000777776775944445611b311111cc66ccd
766667dd76dd766d004ffffff2242222244222222422222022151202111111110888888200066766777777777776600077777777594444461bb311111c66cccd
7666667076d7666d004fff444424244fff4222244f444220d5141ddd11111111088228820067777777777777777776007777777754f54456b3bb3111166ccc6d
7666666776d7666d0044ff44444224ffff44224ffff442205515155511111111082112820677777777777776677777607777777759524446333bbb7716ccc6cd
766666dd7d7666dd0044f444444224f4f444422ff444422055141555111111c10215512106777777666777777677776077667777544444561113bbbb1ccc6ccd
6ddddddd6ddddddd0044f444444424444444224ff44442002215121211111111015ddd106777777777767777777777767777677759444456111133334dddddd4
000333000003300000444444444224444422424f16111d51000000000f900f900f900f906777777777777777777777665115115551d555550000000067766776
0003b0003b3330000422444444422244222f42242d11265100000000f445f445f445f4456677777777777777777777661bb1bb15551d554400000006766d766d
00b3b003bb30bb300444444442222222224f42241d511d120dd000009442944294429445666777776777766777776666b7bb67b15511d5440000006d766d766d
3333003b35b0333304422224242422442244442426112d11dd5500005221522105200520666667666676666677666666b57b573151111545000006d0766d766d
333b5303005b3333042224422244fff4422442241d511612d5522d804115411500000000066666666666666666666660bbbbbb3351649545000065007666d76d
03b553030033300304244f4442ffff444422244226112d11011022269f94444500000000066666666666666666666660bb361b3355f9ff54000650007666d76d
0033000000333b000042ff44422444444424222216511652050205214444445500000000006666666666666666666600bb3122b35d16f65406666dd07666d76d
00333330053033300042fffff424444222fff4222d112d115002500204555220000000000000666600006666666600001bbbbb31d11666546ddd555d6ddd66dd
003553bb553bb3300244ffffddddd52642142142fff242402222222200f4420001ffff10ff444444444455210000000051333312111161df5550555022222225
03bb503330003553424444445551552d92192192ff44424022222222004f45001f4f4f41f4f44f44444552210000000f12222222111161d4ffff9f452ddddd51
033bb3000b00000342444444551b112da41941a4444442222122522200f45400f4f44445ff444445444455210000f4451b1112b3dd1115d4944444452d555551
b3033330033b3000422244442201b312941a4194444444422222222200f44500ff444445f4f44444444552210f4445501b2111b31f111554444444552d555551
b30350000005533304222422d526dddd94194194444444422222222200444500f4444455ff44444444445521444500501b2222bb11111545055055502d555551
333350003335533304422222552d5555941a41a4244444422222221200f45200ff444545f4f444f4444552214500000051222222d1d1d5459f459fff2d555511
00003333bb30033300444222552d5555a41a4194222222222522222200f4450014445451ff4444444544552150000000551b11b1111115544445f44425555111
33033003b3300330002222202202221294194194022222202222252200f4550001555510f4f44444444552210000000051bb1bb1665666544455444451111111
00f70ed4d4d4d4f0d4d4d40ef7000000000097a700000000000097a70000000000000097a7000000000000000000000000000000000000000ef70ed4d0f0d0d0
f0eea2d0f0d0e00000c0d0f0d0a2d0f0feeed0d0d0d0d0c171d0d0d0b10e1e1e1e1e1e1e1e0ef70e000000000000000000000414050000a20000002434444546
00f70ed4d4d4d4f0d4f4f40ef7000000000097a7b7160600000097a7000000000000c193a70000b1000000000000000000000000000000000ef70ed4818181d0
81fea2d0f084e0001fc084f0d0a2d081fefeeed0d0d0d00e1e1e1e1e1e1ef7f7f7f7f7f7f7f7f70e00000000000000000000b200b20000a20000002545454635
00f70ed4d4d4d4d4f1f1f10e0e000000000097a700000000000097a70000000000000097a7001700000000000000000000000000000000000ef70ed4d4d0d0d0
fed5a3eef085e01f00c085f0d0a3d5d0fed5feeed0d0d00e0f0f0f0f0f0f0f0f0f0f0f0f0f0f0e0e000000001f0000000000a200a3d100a30000002746453657
00f70e0e0e0ef4f40e0e0e0e0e0000001f0097a700000000000097a70000000000000097a7b70700000000000000000000000000000000000ef70e1e1e1e1e1e
1e1e0ed0f0d0e00000c0d0f0d00e1e1e1e1e1e1e0ed0d0d0b2d0d0d0d0b2d0d0d0d0e0000000b20000000000000000000000a20015041404000000002757be2e
00f70ed4d4d4d4d4d4d4d4d400000000000097a700000017166497a7001f000000000097a70000000000000000000000000000001f0000000e0e0f0f0f0f0f0f
0f0f0ed081d0d08181d0d081d00e0f0f0f0f0f0f0ed0d0d0a2d0d0d0d0a2d0d0d0d0e0000000a20000000000000000000000a3000000b2000000000000f7bfbe
d1f70ed4d4d4d4d4d4d4d4d400d1d2d1d2d197a700000000000097a700000000000064c1a70000000093000000b10000000000000000000000b200c0d0d0d0d0
eeb2d0d0d0d0d0d0d0d0d0d0d0d0b2d0eed0b2d0d0d0d0d0a2d0d0d0d0a2d0d0d0d0e0000000a2000000007676760000001405000000a20000001f00c2672ece
44f70e1e1e0ef4f40e1e1e1e0e444444243454a753d1d200d17397a7d200000000000097a70000000000000000000000000000000000000000a21fd0d0d0d0d0
fea2d084d0d081818181d0d084d0a2d0feeea2d0d0d0c171a3b1d0d0d0a2d0d0d0d0e0000000a20000000077927700000000b2000000a200d10000c2676767f7
352ebeceef0ed4d40e2ebecebf3535354546355444345434542444345400d200d200d297a700d1000000000000000000006000000000000000a300eed0d0d0d0
fea2ee85d0d0d001d0d0d0d085d0a2d0fefea2d0d0d00e1e1e0ed0d5d0a2d0d0d0d0e0000000a20000000077927700000000a2d2d100a3245400c267676767bf
35bebfeff4f4f4f4efbecebfbece3535463645464645463545463635352444545434445434445474748787747474878787877474747474743434440e1e0ed0d0
fea3feeed0d5d0d001d0d5d0d0d0a3d0fefea3ee0e0e1ef7f71e1e0ed0a3d0d0d0d0e000d100a330d2d100046504d2d1d100a3243444344555676767676767f7
bfce2eefd4d4d4d4efbf2ebece2ece35463545464535364646364646464536464546354636354575757575757575757575757575757575753546360ef7f71e1e
1e1e1e1e1e1e1e1e1e1e1e1ef4f41e1e1e1e1e1e1ef7f7f7f7f7f71e1e1e1e1e1e1e0e3444343444443434f765f744442434443535464535464454676767672e
efefefefd4d4d4d4efefefefefefefefcebeefbebfcebeefbfcebeefefceef2ebecebecebecebe7575757575757575757575757575757575bebebecebecebece
efefefefefefefefefefefefd4d4efefefefefefefefefefefefefefefefefefcebecebece2ecebebe2ebfef65efbebfcef7f72ef7bebfcef7bf2e67676767ce
eff4f4f4f4f4f4f4f4f4f4f4f4f4f4efbebfcebe2ebfbecebebfbfcecebfbecebfbebfbece2ebff7f77575757575757575ff757575ff75f7f7bfbff7cebebff7
eff467f4f4f46767f4f4f4f4f4f4efefeff467f4f4d4f4f4f4f467f4f467f4efbebe2ef7cef7f72ef7ceefd465d4ef2ef76767676767676767676767676767f7
efd4c4e4d4d4d4d4d4d4d4d4d4d4c4efefcebe2ebecebfbfbfcebebfcebebeefbecebebfbecebecef7ff75ff757575ff75ff757575fff7f7becebece2ebecebe
ef67d4d4d467d4d4d4d4d4d4d4d4efefef67d4d4d41f6767d4d4d4d4d46767efbf2e67676767676767f7efd470d4efbebf6767f7f7f7f7f72e2ef7f7f7cef72e
efd4d4d4d4d4f1f1f1f1f1d4d4d4d4efbebececebfcebecebebebf2ebecebecebfbebecef7becebecef775ff757575ff75ff757575fff7be7575757575bebece
efd4d4d4565656d4d4c4e4d4f4f4efefefd4565656d4d4d4d4d4d456565667eff7676767676767676767efd4f4f4efbff76767676767676767676767f7f7bfbe
eff4f4f4f4f4efefefefeff4f4f4f4ef2ecebfbecebebfcebebfbebecebf2ebebececebecebfbebfbef7ffff75ff75ff75ff757575f72e75757575ff7575bfbe
efd4d4c15656566771d4d4b1d467efefefd4565656d4d4d437d4d4565656d4eff7676767676767726767efd4d4d4efcece67676767676767671f67676767f7bf
efd4d4d4d4d4f4f4f4f4f4d4c4e4d4efbfbebe2ecebebebececebecebfbebece67bebebfbe2e75757575ffff75ff75ff75ff75ff75757575751f75ff75ffcece
eff4d4efefefefefefefefefefefefefeff4f4f4f4f4f4f4f4efefefefefefefbf67676767f7f7f7f7f7eff4d4d4ef2ebe2ef7f7f72ef7f767676767676767f7
efd4f1f1f1f1d4d4d4d4d41fd4d4d4efbebecebfbeefefefefefefefefefefefbfbebebece7575752ecef7f775ff75ff75ff75ff7575ff75757575ffffff2ebe
efd4d4f4f46767f4f4f4f467f467f4efef80d467d4d4d4d4d4f467f4f4f467eff7676767676767676767efd4d4d4d4f7f76767676767676767676767676767f7
eff4f4f4f4f4d4d4d4d4f1f1f1f1f1efbecebebeceeff4d4f4d4f4d4f4d4f4efbff7cebfbe751f75bfbebecef7ff75fffff7f72eff75ff75757575ffff2ebece
eff4d467d4d4d4d4d4676767d4d4d4efeff4f4d4d4d4565656d4d4565656d4efbff7f76767676767676767d4d4d4d4676767676767676767676767f7f76767f7
efd4d4d4d4d4f4f4f4f4efefefefefefefef2ecebeefd4d4d4d4d4d4d4d4d4efbebfbebeceff75752ebef7be67f7f7f7f767cebfff75ff757591752ece67cebe
efd4d4d4d4d4d4c4e4d4d4d467d4d4efef67d4d4d4d4565656d4d4565656d4eff7676767676767676767d467d4f4676767676767676767676767672e676767f7
eff1f1f1d4d4d4d4d4d4f4f4f4f4f4f4f4f4efefefefd4d4d4d4d4d4d4d4d4efbfbe2ebfbe2e757575bfbecebebecebe67bfbef7be2eff75e5e3ffbfbebfbece
eff4d4d4d4d4d4d4d4d4d4d4f4f4f4efefefefefefefeff4f4f4f4f4f4f4f4eff767676767676767676767d4d46767676767676767676767676767f7679067f7
eff4f4f4f4f4f4d4d4d4d4d4d4d4d4d4d4d4f4f4f4f4d4565656d4d4d4c4e4ef2e6767cebfbe7575ff2e67bebfbfbebebfbebebebfbece2ebfbe2ebebfbe2e67
efd467d4d4f4f4f4efefd4d4d4d4d467f467f4f4f4f4f4d4d4d4d4d4d4d4d4ef2e74747474f7f7f7747474747474f7f7f7f77474748787877474742ef7f7be2e
efe4d4d4d4d4c4e4d4d4d4d41fd4d4d4d4d4d4dfdfdfd4565656d4d3d4d4d4ef672ebfbececeff752ebfbebebecebebfcebebebe2ecebebfbebff7f7becebfce
ef67d4d4d4d4d467efefd45656d4d4d4c4e4d4c4e4d467565656d4d4d4f4f4efbff7f7ff75757575ff7575757575f7bfbe2e7575ff7575757575ffbebfce2ebf
efd4d4d4f1f1f1f1f1f1f1d4d4d4f4efefefefefefefefefefefefefefefefefbecebebfbe2effff7575ff757575ffffff7575ff757575ffffff7547756375ff
efd4c1c4e471b1d4efefd45656d467d4d4d4d4d4d467d4565656d4c4e4d4d4efce2ef7f775757575fffff7f7bef7bfbebfbe2e75ff75ff75752ebecebfbfbece
efefefefefefefefefefefefefefefefbf2ebebece2ebfbecebebfbfbece2ebebfbebfbebfbecebebfbecebebebfbecebebecebe2ebebfbecebef7f7bebfcebe
efefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefbfbebfcef7bff7bef7bf2ebfbebf2ebfbfcebebfbebfcebebfbecebfbfbebfbf
faffff99faf9faf91155551100000000000000000000000000000000000000000000000000000000000000005552050555555555ddddd5266d666d57666666d7
a7aa99947f947f9415ddd5510707007007007aa077aaa077a007a0000000000880000000000000000000000022111511011222225555552d66dddd56666666d6
fa999994f994f9945ddd555579a9a0a00a07449094a4909a90799a0000000008820000000000000000000000d1551151555121105555552d666ddd56666666d6
fa9999949994f9945dd55552a0a0a09aaa09aa0000a0000a00a0040000000008820000088888820000088000011511101551111122022202dd0d5505dd0ddd0d
f9999994444599945d555522a090a0094a0044a000a0000a00a00400000000088ee200088888820800e880005515155ddd511115d526dddd66d76d6666d76666
f99999941111444555555222a000a00aa90aaa9000a000aaa09aa900888880088ee222200088208880880000551115dddd52115d552d555566d666dd66d66666
f9999944222211122552222290009009900999000090009990099000888888088ee222200082088888880000555115d5d552211d552d555566d6666d66d66666
9444444555552225122222210000000000000000000000000000000088228888820088200882002888800000555205555522105d22022212dd0ddd1ddd0ddd1d
55551111000000000070007000000000000000000000000000000000880028888208822088220000e8800000552111557afafaff0009900067776665111b3111
11117af50000a0000c0070cc00077a0007aa007aa07000070a0000008800088222088208888ee0000888000052211122f99999940009900076ddd5d1111b31b3
7af5af94000a99000007c00c000799a074490799a0700079a9a000008800088000882020088822000e8800002111111044444444009aa9006dd55d5111113333
af94f9940a99999a0007cc00000a00a0aaa00a00a0a000a0a0a000008800888008822220000822000e8880001515115522022202009aa9005111111511111311
f994f994002a9920c0ccc100000aaa40a4900aaaa0a000a090a00000888888200ee222000000000000e880000155ddd5d526dddd09aaaa9026756772b311b311
999499940049494000cc1c00000a99a09aaa0a99a0aaa0a000a00000888822000ee200000000000000e8000051dddd55552d555509a77a907dd176d133313111
4444444400900090000cc000000900900999090090999090009000002222000000000000000000000000000051155552552d555509aaaa906d516dd111333111
2222222200000000000000000000000000000000000000000000000000000000000000000000000000000000d5155220220222120099990021155112111b3111
__gff__
0000000000000000000000000000000000000000000000000210000000000004000000000000000000000000000000000000000000000000000000000000100001010101010100000000000000000002010101010101001000202020200010000000010101000002022020200000000100000100010100000200000000000001
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010000000000000000010108000001001000000000000000000102080110
__map__
000000000000000000000000000000000000000000000000000061003b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000052
7f7f00000000007f7f00000000007f7f000000000000000000616067680000000000000000000000000000000000000000000000000000000000000000000000001c0000000000f100003900001b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f1000062
7f7f007f007f007f7f007f007f007f7f0000000000000000617146707100000000595a5b0000000000000000000000000000e0e0000000000000000000e0e00000000000000000000000000000000000000000000000000000e0e00000000000000000000000000000000000e0e0000000000000000000000000000000000062
7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f000000000000006071607161607b610000696a6b000000595b00000000f100000000e0e000e000e000e000e000e0e000001c00000000000000000000391b0000000000000000000000e0e000e000e000e000e000e000e000e000e000e0e0000000000000000000000000000000000052
7fe0e0e0e0e0e0e0e0e0e0e0e0e0e07f0000617b00000070606171617100000000000000000000696b000000000000000000e0e0e1e0e1e0e1e0e1e0e1e0e00000000000000000000000000000000000000000000000000000e0e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e000000000000000000100000000595b000062
7fe04d4d4d4d4d4d4d4d4d4d4d4de07f007170610000f1006171606161006000000000000000000000000000000000000000e07ff0f0f0f0f0f0f0f0f07fe000000000000000000000595b0000000000000000000000000000e07ff0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f07fe000000000000000595a5b000000696b000052
7fe04d0f4d4d0f4d4d0f4d4d0f4de07f46616000000000606160617a716061000000610070000000595a5b00000000000000e07fe0e04d4d4d4d4de0e07fe000000000000000000000696b0000000000000000000000000000e07fe0e04d4d4d4d4d4d4d4d4d4d4d4d4de0e07fe000000000000000696a6b0000000000000062
7fe04d0f4d4d0f4d4d0f4d4d0f4de07f617161000000007160716161600071000000467161600000696a6b00000000000000e07fe04d4d0d0f0d4d4de07fe00000000000000000000000000000000000000000000000000000e0e0e04d0d0d0d0d0d0d0d0d0d0d0d4d4d4de07fe00000595a5b00000000000000000000000052
7fe04d0f4d4d0f4d4d0f4d4d0f4de07f60006170000070006046796171616100000071706171610000000000000000000000e07fe04d0d0e000c0d4de07fe0000000595a5a5b00000000000000000000000000000000000000000d0d0d0d0d0dee0d0d0d0d0d0d0d0d4d4de07fe00000696a6b00000000000000000000000062
7fe04d4f4d4d4f4d4d4f4d4d4f4de07f61706071600000000000797a61706768686868677161700000000000000000000000e07fe04d0e00f1000c4de07fe0000000696a6a6b00000000595b0000000000000000000000000000ee0df10d480defee0d0f0d0f0d0f0d0d4de07fe0000000000000595a5a5b0000000000000052
7fe04d4d4d4d4d4d4d4d4d4d4d4de07f71607060000000606171617a61007700007170617a6171617b000000000000000000e07fe04d0e0000000c4de07fe00000000000000000000000696b000000000000595b000000000000efee0d0d580defefee0f0d0f0d0f0d0d4de07fe00000000000005c5c5c5c5a5b000000000062
7fe04d6d4d4d4d4d4d4d4d4d4d4de07f61616161000000616070797a00007700006061797a71000000000000000000000000e07fe04d0e001a000c4de07fe000000000000000000000000000000000000000696b0000000000e0e0e00d0d0d0defefefee0d0d0d0d0d0d4de07fe0000000000000696a6a6a6a6b000000000052
7fe04d7d4dfdfd4d4d4dfdfd4d4de07f60617a60616000007100676768686800000061676767617061000000000000000000e07fe04d18181818184de07fe000595a5b000000000000000000000000000000f2f20000000000e07fe00d0d0d0defefefefee0d0d0d2e0d4de07fe0000000000000000000000000000000000062
7fe1e1e1e1e1e1e1e1e1e1e14f4fe07f61716070610000000000797a60000000606170617a7b617071600000000000000000e07fe04d0d0d0d0d0d4de07fe000696a6b00000000000000000000000000000000000000000000e07fe0e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0e07fe000000000f10000000000000000595a5b0062
7ff0f0f0f0f0f0f0f0f0f0f04d4de07f6071797a610000006146797a00000000607161616071606160610000000000000000e07fe04d0d0d0d0d0d4de07fe0000000000000707b0000000000000000000000f2f20000000000e0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0e0e07fe000000000000000000000000000696a6b0052
7fe04e4c4e4c4e4c4e4c4e4cfcfce07f7046797a7b0067686868676768670000617060617161616867000000000000000000e07fe04d0d0d180f0d4de07fe0006000004671606100000000000000000000000000004661000000000c0d2b4d4dee0d0d0d0d0d0d0d0d0d0de07fe0000000000000000000000000000000000062
7fe04d0f4d4d0f4d4d0f4d4d4d4de07f0061797a000077000061797a00770000606161797060610077000000000000000000e0e0e00d0d0d0d0f0d4de07fe0007161001d604243452d00004671000000000000000060707b7000000c0d2a0d48ef480e0c480e0c480e0c48e07fe0000000002d00000000000000000000000052
7fe04d0f4d4d0f4d4d0f4d4dfcfce07f68676767676768006171717a7b770000006061797a6100006867000000000000f100ee0d0d0d0d18180d0d4de07fe00a771d424344535354451d022d606100000000001d00006161000000ee0d2a0d58ef580e0c580e0c580e0c58e07fe0000000004040500000000000404100000062
7fe04d4d4d4d4d4d4d4d6c4d4d4de07f007e5f7e5f7e00000000797a617700f1006146797a00000000770000000000000000efee0d0d0d0d0d0f0d4de07fe04442445363646364645443444570611d2d001d4243452d771d003800efee3a0d0d5defefee0d0d0d0d0d0d0de07fe0000000002b004041510000002b0000000052
7fe04d4d4d4d044d4d6e7c4dfcfce07f68677e7e7e7e00000000797a71770000000000797a00000000770000000000000000efefee0d0d0d0d0f0d4d4de07fe0536364546364545363645354424344444345635453444345e0e1e1e1e1e1e1e1e1e1e1e00d480e000c48f1e07fe0000000002a00002b000000002a0000000062
7fe04f4f4fe0e0e0e1e1e1e1e1e1e07f007e5f7e5d7e2800f100797a00676767676700797a00006768680000000000000000e0e0e00d0d0d0d0d0d0d4d4de0e07f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7fe1f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0e01c580e390c581be07fe0000000002a00002a000000003a1d00000052
7fe04d4d4d4d4de07f7f7f7f7f7f7f7f68686767686868000000797a007e7e5f7e7e00797a00007700000000000000000000e07fe04d0d0d0d0f0d0d0d4d4d4de0f0f0f0e0f0f0f0f0f0f0f0e0f0f0f0e0e00d0d0d0d0d0d2b0d0d0d0d0d0de0e00d0d0d0d0d1818180d0de07fe0000000002a00002a0000004140500000f162
7fe04d1f1f4d4de0f0f0f0f0f0e07f006146797a006000000000797a007e5d7e5d7e00797a7b617700000000000000000000e07fe04d0d0d0d0f0d0d0d0d0d4d4d4d4d4d2b4d4d4d4d4d4d4d2b4d4d4de00d0d0e00000c0d2a0d0f0d0d0f0de0e00d480e0000000c480d0de07fe0000000002a00002a000000002b0000000052
7fe04d4f4f4f4f4c4e4c4e4c4ee07f006070797a616070610000676768686868686868677a0000770000000000000000000000e07fe04d0d0d0d0d0e000c0d0dee0d0d0d2a0d0d0d0d0d0d0d2a0d0d0de00d0d0e00000c0d2a0d0f0d0d0f0d2b0d0d580e0000000c580de07fe000000000003a1d3c3a000000002a0000000062
7fe04d4d4d4d4d4d4d4d4d4de07f00006100797a7b6161600000797a60610000000000797a000077000000000000000000000000e07fe0180d0d0d0e000c0d0defee0d0d2a0d0d0e610cf10d2a0e710c2b0d0d181818180d2a0d180d0d180d2aee0d0d18181818180de07fe000000000000050414051000000002a0000000052
7fe04d4d4d4d0f4d0f4df14de07f00000046797a006060700000797a61606100616046796767686868686800000000000000000000e0e04d0d0d0d0e000c0d0defefee0d3a0d0d0d180d0d0d2a0d180d2aee0d0d0d0d0d0d2a0d0d0d0d0d0d2aefee0d0d0d0d0d0d0de0e000000000000000002b00000000002d3a0000000062
007fe04f4f4f0f4d0f4d4de07f0000000000797a000000007046796160706100617060797a00000000000000000000000000000000e0e04d0d0d0d1818184de0e1e1e1e1e01c0d5d0d175d0d3a1b0d0d3aefee0d0d0d0d0d3a1c0d170d1b0d3a5defee1c0d0d170d1be0e000000000000000002a000000004041400000001d52
007fe04d4d4d4d4d4d4d4de07f0000000000797a000000616060797a7b000000000061797a7b000000000000000000000000000000e0e0e0e1e1e04d0d0d4de07f7f7f7fe1e1e1e1e1e1e1e1e1e1e1e1e1e1e00d0d0d0d0de0e1e1e1e1e1e1e0e1e1e1e1e1e1e1e1e0e0e000000000000000002a00000000002b000000004264
007fe04d4d4d4d4d4d4d4de07f0000000000797a000000000000797a61607170000000797a00000000000000000000000000000000000000e07fe04d0d0f0de07f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7fe04d4d4d4d4d4d4de0f0f0f0f0f0f0e0f0f0f0f0f0e07fe000000000000000000000002a00000000002a000000004253
007fe04d4d4d4f4f4f4f4fe07f0000006160617a000000000000797a7b607000000000796161000000000000000000000000000000000000e07fe04d0d0f0d4de07f7ff0f0f0f0f0f0f0f0f0f07f7fe0e00e00000000000c0d0d0d0d0d0d0d0d4d4d4d4d4de07fe000000000000000000000002a00000000003a002d00006264
007fe01f4d4d4d4d4d4d4de07f0000007046797a000000617170797a00000000006146797a70610000000000000000000000000000000000e07fe04d1818180de0f0e00d0d0d0d0d0d0d0d0d0de0f0e0e00e00f10000000c0d480d480d0d0d0d0d0f0d0ff1e07fe000000000000000000000002a000000415040404151006253
007fe04f4f4f4f4f4d4d4de07f0000000000797a000000006046797a00000000000000797a7b700000000000000000000000000000000000e07fe04d0d0f0d0dee0d2b0d0d0d0d0d0d0d0d0d0d2b0d0dee0d0d0d0d0d0d0d0d580d580d0d5d0d0d0d3f0d4de07fe0000000000000000000001d3a0000002b000000002b1d6254
__sfx__
010e000003130030150010003130030150a1250f1350d0050a13507135001050a13503130030150010003130030150a1250f1350d0050a13507135001050a1350013000015000000013000015001300012000115
010e0000000000313003115001300013000125001250c1350c105071350a1300a1120a11207130071150513503130030150010003130031150a1250f1350f1050a13507135001050a13503130030150010003130
010e0000031150a1250f1350f1050a13507135001050a1350013000015000000013000015001300012000115000000313003115001300013000125001250c1350c105071350a1300a1120a112071300711505135
010e00000c033000003c5150c615000000c61530615000000c6150c615000000c6150c03300000006153c515000000c61530615000000c6150c615000000c6150c0333c515006150c615000000c6153061500000
010e00000c6150c615000000c6150c03300000006153c515000000c61530615000000c6150c615000000c6150c03300000006150c615000000c61530615000000c6150c6153c5150c6150c03300000006150c615
010e0000000000c61530615000003c5150c615000000c6150c03300000006150c615000000c61530615000000c6150c6153c5150c6150c03300000006150c615000000c61530615000000c6150c615000003c515
010e00000f5100f5150c5000f5100f515165151b5150d50516515135150c505165150f5100f5150c5000f5100f515165151b5150d50516515135150c505165150c5100c5150c5000c5100c5150c5100c5100c515
010e0000005000f5100f5150c5100c5100c5150c515185150c505135151651016512165151351513505115150f5100f5150c5000f5100f515165151b5150f50516515135150c505165150f5100f5150c5000f510
010e00000f515165151b5150f50516515135150c505165150c5100c5150c5000c5100c5150c5100c5100c5150c5000f5100f5150c5100c5100c5150c515185150c50513515165101651216512135151350011515
010e00000c033277141b512277121b51227715306151b7140f5121b7120f5121b7150c033277141b512277121b51227715306151b7140f5121b7120f5121b7150c03324714185122471218512247123061518714
010e00000c512187120c512187150c033247141851224712185122471530615187140c512187120c512187150c033277141b512277121b51227715306151b7140f5121b7120f5121b7150c033277141b51227712
010e00001b51227715306151b7140f5121b7120f5121b7150c03320714145122071214512207153061524714185122471218512247150c0332071414512207121451220715306152471418512247121851224715
010e0000031150a1250f1350f1050a13507135001050a135081300801500000081300801503130051200511500000031300311508130081300812508125141350c10508135051300511205112031300311508130
010e00000a1300a015001000a1300a015051250a1300a015051350813008015051350a1300a015001000a1300a015051250a1300a015051350813008015051350d13001015000000d1300d015081300d1200d115
010e00000000005130051150d1300d1200d115011200d1300c105081200d1300d120011100a1300a1150813505130050150010005130050150013505130051150513011130111150513505130050150010005130
010e000005015001350513005115051301113011115051350a1300a015001000a1300a015051350a1300a0150000016130161150a0150a1300a015001000a1300a015051350a1300a0150000016130161150a015
010e000027530275102b5302e5302e510275302b5302b5202b5122753027510245302452024515275352753027515245302452024510225302253022522225222453024510275302753027530275202752027520
010e00002752027520275202752027520275202751027510275102751027510275122751227512275122453024520245102753527530275152753527530275152753527530275152753529530295202951527530
010e00002753527535245302452024515225302251524530245302453024530245302453024530245302453024520245202452024520245202452024520245202452024522245122451224512255302551526530
010e000026530265202652526530265152652526530265202651524530245202653026530265222651526530265352653529530295152e5302e5202e5102c5302c5302c5202c5152c5302c5152c5352953029520
010e00002951525520255152053020530205202052020522205122051220530205002253020530205152053020530205302053020530205302053220532205222052220522205151d53020530205151d5301d520
010e00001d51520530205202051022530225302252022510275302752027510265302652026510245302452024510225302252022510265302653026530265302653026520265202652226522265122651226512
010e00000c0332271416512227121651222715306151d714115121d712115121d7150c0332271416512227121651222715306151d714115121d712115121d7150c03325714195122571219512257153061520714
010e0000145122071214512207150c03325714195122571219512257153061520714145122071214512207150c0331d714115121d712115121d71530615187140c512187120c512187150c0331d714115121d712
010e00001d7121151530615187140c512187120c512187150c0332271416512227121651222715306151d714115121d712115121d7150c0332e714225122e712225122e71530615297141d512297121d51229715
010e00000c03322015270152e015330153a01530615330152e0152b01527015220150c0331f01524015270152b015300153061537015300152b01527015240150c03322015270152e015330153a0153061537015
010e0000330152e0152b015270150c03322015270152e015330153a0153061537015330152e0152b015270150c03324015270152c01530015330153061533015300152c01527015240150c03326015290152e015
010e00003201535015306153a01535015320152e015290150c03327015270152e0152b0153301530615370153a01537015330152e0150c0332b015270152b0152e0153301530615370153a01537015330152b015
010e00000613006120061150613006115121350613006115061300613006115061350813008120081150813008120081150813008115061350313003115081350613006120061150613006115121350613006115
010e0000061300613006115061350813008120081150813008120081150a1300a1200a11508130081150a13506130061200611506130061151213506130061150613006130061150a13506130061200611506130
010e000006120061151213012115011300313003115011350a1300a1200a1150a1300a115161350a1300a1150a1300a1200a115051350a1300a1200a110081300812008110061300612006110051300512005110
010e00003a7303a7203a7153a7303a715387303a7303a7153d7303d7203d7103b7303b7203b7103b7123a7303a7203a71238730387203871236730367123a7303a7303a7203a7153a7303a715387303a7303a715
010e00003d7303d7203d7103b7303b7203b7103b7123d7303d7203d7123f7303f7203d7123b7303b7123a7303a7303a7203a7153a7303a715387303a7303a7153d7303d7203d7103a7303a7303a7203a7153a730
010e00003a715387303a7303a7153d7303d7203d7103a7303a7303a7203a7153a7303a715387303a7303a7153e7303e7203e7103a7303a7303a7203a7153873038720387153a7303a7153e7303c7303c7153a735
010e000003130031200301000000000000f12503130031200301000000000000f12500130001200001000000000000c12500130001200001000000000000c12503130031200301000000000000f1250313003120
010e00000301000000000000f12503130031200301000000000000a1250c1300c1150a12007130071150a1200813008120080100000000000141250813008120080250000000000081350a1300a1200a02500000
010e000000000051250a1300a1200a02500000000000e1250f1300f1200f02500000000000a1250f1300f1200f02500000000000a1350f1300f1250f1250e1300e1200e1250c1300c1200c1250a1300a1200a125
010e00002b5302b5202b5102b5302b5202b5102b5302b5202b51529530295252b5302b5302b5222b51224530245202451027530275202953029520295122b5302b5302b5302b5222b51500000000002b5302b520
010e00002b51529530295252b5302b5302b5302b5202b5202b5122b5122b5122b5152e5302c5302c5102b5302b5302b5302b5222b51500000295302b5312b5152b5302b5202b5102953029530295202951529530
010e000029525000002753027520275152953029520295152b5302b5202b5152753027530275202752027522275122751227512275151f0062200627006220060c6150c61527006220060c6150c0331861518615
010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000042203905036050330502c05007300083002471026750297502c7502a7502775024710277502a7502c7502a750287500630006300063000530014550175501a550185401451014540165501855017550
0003000010070110701207014070170701a0701f07024070250702607019070190701a0701c0701f07023070270702c0702f070310703007028070210701e0701d0701f070230702a070360703a0703d0703e070
000100000e610086200c6200462003610036100161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000080500d070150701b07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000a0700b170090700607005070030600104000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000266501a650026401d6502e650226501c64000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000016150155502575015050155501605018550190501a5501e050205502405028550350503d5503f05000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00 03 06 44
00 01 04 07 44
00 02 05 08 44
00 00 03 06 44
00 01 04 07 44
00 02 05 08 44
00 00 09 10 44
00 01 0a 11 44
00 0c 0b 12 44
00 0d 16 13 44
00 0e 17 14 44
00 0f 18 15 44
00 00 09 10 44
00 01 0a 11 44
00 0c 0b 12 44
00 0d 16 13 44
00 0e 17 14 44
00 0f 18 15 44
00 1c 03 1f 44
00 1d 04 20 44
00 1e 05 21 44
00 00 09 10 44
00 01 0a 11 44
00 0c 0b 12 44
00 0d 16 13 44
00 0e 17 14 44
00 0f 18 15 44
00 22 19 25 44
00 23 1a 26 44
00 24 1b 27 44
00 22 19 25 44
00 23 1a 26 44
00 24 1b 27 44
00 1c 03 1f 44
00 1d 04 20 44
02 1e 05 21 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
