pico-8 cartridge // http://www.pico-8.com
version 11
__lua__
-- spoopy!
-- @platformalist and @enargy
-- playtesting by paige!
-- thanks for playing!
cartdata("spoopy_666")
menuitem(1,"reset treasure", function() un() end)
menuitem(2,"reset map", function() unm() end)
game={}
game.int=true
game.pl=false
game.h=false
game.tr=false
game.hc=0
game.ap=false
ty={}
treasure={}
for i=1,10 do
treasure[i]=dget(i)
v=false
if treasure[i]==1 then v=true end
treasure[i]=v
end
function _load(ad)
dg=flr(ad/4)+11
v=dget(dg)
v=shr(v,2*(ad%4))
v=band(v,0b11)
if v==1 then v=9 end
return v
end
function _save(ad,v)
if v==9 then v=1 end
dg=flr(ad/4)+11
v=shl(v,2*(ad%4))
dset(dg,bor(dget(dg),v))
end
function _init()
if not ml then ml={} end
bg={}
bg.bp=true
bg.ss=0
bg.die=false
if not sel then sel=1 end
os=-28
ts={}
ts[1]="treasure:\nhaunted chalice\n\nfound:\ncountry graveyard\n\npower:\ncunning"
ts[2]="treasure:\ncursed pendant\n\nfound:\ncountry graveyard\n\npower:\naudacity"
ts[3]="treasure:\ngolden pillar\n\nfound:\ncity graveyard\n\npower:\nprudence"
ts[4]="treasure:\ncrimson ring\n\nfound:\ncity graveyard\n\npower:\nvigilance"
ts[5]="treasure:\nmysterious crystal\n\nfound:\nisland of doom\n\npower:\ntenacity"
ts[6]="treasure:\nblack diamond\n\nfound:\nisland of doom\n\npower:\nrestraint"
ts[7]="treasure:\ngolem heart\n\nfound:\nhotel of lost souls\n\npower:\nsavvy"
ts[8]="treasure:\nsalt hourglass\n\nfound:\nhotel of lost souls\n\npower:\nexorcism"
ts[9]="treasure:\nplague elixir\n\nfound:\nhotel of lost souls\n\npower:\nlongevity"
ts[10]="treasure:\nhotel key\n\nfound:\nhotel of lost souls\n\npower:\nduplicity"
ts.get=false
ts.getval=nil
int={}
int.t=0
int.swipey=-140
int.selx=0
int.sely=0
int.hc=0
int.hp=false
int.tv=0
story={}
story.layer=0
for i=1,8 do
story[i]=8
end
txt={}
for i=1,4 do
txt[i]="spoopy string"
end
txt.strcount=0
txt.strdone=false
txt.rollrate=2
book()
snow={}
for i=1,40 do
add(snow,make_snow(x,y,xdir,t))
end
if game.h then
int.h=true
end
music(-1)
end
function _update()
if game.int then
gamestart()
treasureclick()
end
if game.pl then
btncheck()
end
screenshake()
foreach(snow,snowfall)
end
function un()
for i=1,10 do
dset(i,0)
treasure[i]=false
_init()
end
end
function unm()
for i=11,63 do
dset(i,0)
end
_init()
end
function make_snow(x,y,xdir,t)
local new_snow={
x=rnd(128),
y=rnd(170)-180,
xdir=rnd(5)/10,
t=flr(rnd(20)),
}
return new_snow
end
function draw_snow(ts)
local j=false
local b=false
circfill(ts.x,ts.y,0,2)
end
function snowfall(ts)
if ts.t<(21+rnd(2)) then
ts.t+=.5
else
ts.t=0
ts.xdir*=-1
end
if ts.xdir>-0.05 and
ts.xdir<0.05 then
ts.xdir+=.3
end
ts.x+=ts.xdir*((10-story.layer)/10)
if ts.y<130 then
ts.y+=((.4*(10-story.layer))/10)
else 
add(snow,make_snow(x,y,xdir,t))
del(snow,ts)
end 
end
function gamestart()
if int.t>35 then
if btnp(0) or
btnp(1) then
if state==title then
music(-1)
sfx(-1)
game.int=false
game.pl=true
music(12)
bg.level=0
end
end
if btnp(4) then
bg.ss=1
sfx(17)
if state==2 then
elseif state==1 then state=title
else state=1
end
if not int.horde then
int.horde=true
elseif int.horde then
int.horde=false    
end
elseif btnp(5) then
bg.ss=1
sfx(17)
if state==2 then state=title
else state=2 end
mf={}
for i=1,131 do
mf[i]=_load(i)
end
end
end
if int.t<200 then
int.t+=1
end
if int.t>20 and
int.swipey<-2 then
int.swipey+=10
end
if int.t==1 then
sfx(16)
elseif int.t==35 then
bg.ss=2
music(3)
end
end
function treasureclick()
moveclick()
if int.horde and
int.t>35 then
if btnp(0) then
if int.hc==0 or
int.hc==5 then
int.hc+=4
sfx(18)
else
int.hc-=1
sfx(18)
end
end 
if btnp(1) then
if int.hc==4 or
int.hc==9 then
int.hc-=4
sfx(18)
else
int.hc+=1
sfx(18)
end
end
if btnp(2) or
btnp(3) then 
if int.hc>4 then
int.hc-=5
sfx(18)
else
int.hc+=5
sfx(18)
end
end
end
end
function moveclick()
x=(int.hc%5)*22
y=flr(int.hc/5)*18
t=(int.hc%5)*2
if int.hc>=5 then t+=1 end
moveclicker(int.hc,x,y,t)
end
function moveclicker(v,x,y,t)
if int.hc==v then
int.selx=x
int.sely=y
int.tv=t
end
end
function screenshake()
if bg.ss==-1 then
bg.ss=0 
elseif bg.ss==1 then
bg.ss=-1
elseif bg.ss==-2 then
bg.ss=1
elseif bg.ss==2 then
bg.ss=-2
end
end
function btncheck()
if game.ap then
music(12)
game.ap=false
end
if story[1]==8 then
story.layer=0
end
if bg.bp==false then
if btn(0) then
pageflip(0)
book()
story.layer+=1
tr()
beatingheart()
bg.bp=true
sfx(33)
elseif btn(1) then
pageflip(1)
book()
story.layer+=1
tr()
beatingheart()
bg.bp=true
sfx(33)
end
end
if btn(0) or
btn(1) or 
txt.strdone==false then
bg.bp=true
else
bg.bp=false
end
if txt.strcount>10 and
txt.strdone==false then
if btn(0) or
btn(1) then
txt.rollrate=10
end
end
if txt.strdone then
txt.rollrate=2
end
end
function beatingheart()
sfx(-1)
if not bg.die then
if story.layer>2 and
story.layer<5 then
sfx(21)
elseif story.layer>4 and
story.layer<7 then
sfx(22)
elseif story.layer>6 and
story.layer<8 then
sfx(23)
end
end
end
function tc(z,a,b,c,d,e,f,g,h)
if story[1]==a and
story[2]==b and
story[3]==c and
story[4]==d and
story[5]==e and
story[6]==f and
story[7]==g and
story[8]==h then
treasure[z]=true
ts.get=true
ts.getval=z
dset(z,1)
music(10)
end 
end
function tr()
tc(1,1,1,0,1,0,1,0,0)
tc(2,1,1,1,1,0,1,1,0)
tc(3,1,0,0,1,1,0,1,8)
tc(4,1,0,1,0,1,1,1,0)
tc(5,0,0,0,0,0,1,0,1)
tc(6,0,0,1,1,0,1,1,1)
tc(7,0,1,0,0,1,1,0,0)
tc(8,0,1,0,1,1,0,1,1)
tc(9,0,1,1,0,0,0,1,0)
tc(10,0,1,1,1,1,1,0,1)
end
function ps(a,b,c,d,e,f,g,h,t,q,bl,br,die)
ml[nx]={a,b,c,d,e,f,g,h}
if die then
col=2
ty[nx]=col
else
col=9
ty[nx]=col
end
if story[1]==a and
story[2]==b and
story[3]==c and
story[4]==d and
story[5]==e and
story[6]==f and
story[7]==g and
story[8]==h then
txt[1]=t
txt[2]=q
txt[3]=bl
txt[4]=br
_save(nx,col)
if nx>1 then sel=nx end
if die then
txt[2]="the end ... or is it?"
txt[3]="treasure"
txt[4]="retry"
bg.die=true
end
end
nx+=1
end
function pageflip(i)
txt.strcount=0
txt.strdone=false
if not bg.die then
sfx(20)
story[story.layer+1]=i
elseif btnp(0) then
game.int=true
game.pl=false
game.h=true
_init()
elseif btnp(1) then
game.ap=true
_init()
end
for i=1,10 do
if treasure[i] then
game.hc+=0
else
game.hc+=1
end
end
if game.hc==0 then
game.tr=true
else
game.tr=false
game.hc=0
end
end
dictstr="it's\nmidnight\non\nhalloween\n\nand\nthere's\na\nchill\nin\nthe\nair\nyou\nwere\ngoing\nto\nplay\nvideo\ngames\nall\nnight\nbut\npower\nyour\nconsole\ndied\nyou're\nfeeling\ndaring\ntonight\nso\nlace\nup\nboots\nhead\nout\ntoward\ngraveyard\neerily\nquiet\noutside\nground\nglistens\nwith\nan\nearly\nfrost\ncan\nsee\nbreath\nit\ntakes\nnearly\nhour\nwalk\nback-country\nis\nlittered\nfrozen\nflies\nthick\ngravestones\ndeathly\nstill\nsense\nsomeone's\npresence\ncall\ninto\ndark\nbefore\nvoice\necho\nback\nmassive\nflame\nbursts\nfrom\nnearby\ngravestone\ndisembodied\nbooms\n'who\ndares\ndisturb\nour\naccursed\nchant\nsay\nnothing\nhoping\nthat\nwill\nforget\ndoesn't\nsix\nflaming\nsnakes\nslither\ndisintegrating\nbody\nonly\nsmoldering\nremain\napologize\nghostly\npauses\nfor\nmoment\n'your\napology\ndoes\nnot\nforgive\nintrusion\nby\npledging\nsoul\ndarkness\ni\nlet\nlive\nwithout\nhesitation\nagree\nhorrifying\nlaughter\nfills\nfades\nshadow\nstruggle\nmove\nno\navail\nvoid\nworld\neternity\n'i\nmight\n'\n'but\nwhat's\nme\n'you\nare\nwise\nask\nsays\ngolden\nchalice\nappears\nfront\nof\nreceive\nthis\nmade\nfinest\ngold\ngemstones\naccept\nterms\nvanishes\n'it\nshall\nbe\nyours\nten\nyears\nhuman\nreappear\nat\nhome\nhave\nwhat\nhappens\nthen\ngrab\nbolt\n'he's\ntaken\nget\nhim\nbodiless\nscreams\ndeep\nchasm\nahead\nif\njump\nmaybe\nwon't\nable\nfollow\nrun\nedge\nkick\nleg\nleap\nas\nhard\nhundred\nfeet\ndown\nsharp\nrocks\nbottom\nland\nsafely\nother\nside\nhand\nescape\nintact\nafter\npolish\nplace\ntable\nnights\nevil\nvoices\nwhisper\ninside\nthink\nkinda\nneat\nheave\nghastly\nscream\nbloody\nmurder\nbashes\nagainst\n'what\ndone\nwails\n'whaaaat\nyouuuu\ndoone\nsilence\nthey're\ngone\ndive\nbehind\nrock\nhold\ngrows\ncold\nsomething\nwhispers\near\ncannot\nhide\ninvisible\nice-cold\ntightens\naround\nthroat\nworsens\nhorror\nchilling\nunseen\n'dig\ngrave\nwhere\nmushrooms\ngrow\n'oh\nhelp\ninstantly\nseizes\nveins\nicing\nover\nchuckles\nmoving\nlike\nmarionette\nshovel\nyou'll\ndigging\none\nown\ndig\nsoft\ndirt\nlater\nburst\nthrough\ncave\nthankfully\nscramble\nfree\nhole\ncaves\nstaring\npair\nred\neyes\nsomehow\nevery\nshovelful\ntoss\nburies\ndeeper\nbeast's\ncloser\nnowhere\nold\nladder\nmoments\nfoul\nslug-man\ncrawls\nlimply\nhe\ndrops\npendant\nwhich\nsilently\npocket\ndistant\nmusic\nwarbles\nwicked\ndemons\nfill\nunfortunately\nthese\nsuper\nfast\nthey\ndragging\nhis\njaw\nunhinges\nopening\nwide\ndrooling\nanticipation\ntender\nflesh\nraise\napproach\ndemon-circle\nhowl\nsight\npour\nslug\npossessing\nbloats\ntwice\nits\nsize\nscreeches\nstarts\nslithering\nsmash\nterrifying\nwail\nwind\nhurricane\nknocking\nmelt\nwas\ngulp\nact\nblind\nidiocy\nworked\nancient\npowers\nsurge\ncreature\nrears\nbarrels\nincredible\nspeed\nstrike\ncool\nmagical\npose\nthrow\nhands\nforward\nblue\nelectric\nblast\ndestroys\nentire\nincluding\nburp\nswing\nfist\nwet\nspaghetti\nwall\ndemon-\neven\nfeel\npunch\nslurps\nsingle\nbite\nguess\ndidn't\ngain\nstrength\narrive\ncity\nstreets\nfull\npeople\nthere\ndecorations\nlamppost\nstep\nrusty\ngate\nfreeze\ntime\nstands\nshadow-figure's\nface\nobscured\ndirect\nlight\nhair\nlong\ndraw\nnear\nbells\nring\nfigure\nslowly\nspins\ndancer\npirouetting\nturn\nshadow-dancer's\npirouette\nhas\nhypnotized\nstare\nmesmerized\nhorrified\nspinning\napproaches\ndrawing\neternal\ncopy\nspin\nturning\nsame\nrate\nholding\nposition\nfaster\ntwo\nuntil\nmore\nthan\nblur\nfar-\noff\nmemory\nrevolted\nrecoil\nfall\nsync\nshadow's\nmysterious\ndance\nthrown\nhalfway\nacross\nhedge\nlucky\nalive\ngo\nright\nbed\nskeletal\ngrips\npulls\nclose\nnow\nresembles\nwoman\nher\nskin\npeeled\naway\npurple\nfire\nburns\nskull\npouring\nshe\nremains\nshe's\nmind\neyelids\nshadow-dancer\nholds\nbox\njewels\ngift\npromise\nyourself\nlouder\nmelts\nbones\ndust\ngraciously\ngems\noverflow\nwhen\nopen\nturned\nchains\ntrapped\nforever\nlost\nvanished\npillar\ntall\ndrag\nsit\ntop\nwhile\neating\ncereal\nwatching\nscary\nmovies\nflashlight\nquickly\nrealize\nnobody\norb\nfour\npulsating\ndim\nyellow\nfloating\nupright\nclosed\nponder\nchoices\nseems\notherworldly\ncould\nmake\nwish\nor\ninstead\noffer\nblank\nexpression\nmuster\ncourage\nexclaim\nglowing\ncoins\nmouth\nfilling\nwrithe\ndoomed\nfloats\nwings\nyell\nflashes\nleft\nlimp\nbird-wings\nprotruding\nkneecap\nway\ncontrol\nthem\nthose\nremoved\ndo\nwant\nripples\nliquid\nsatin\nsmall\ncrimson\nfalls\nsledgehammer\nconstruction\nsite\nhammer\nmighty\narcs\ndownward\nswap\npositions\nsplats\nripe\nmelon\norb's\nsurface\nname\nyou've\nnever\nheard\nwhispered\ndart\nlocate\nleave\nreturn\ncan't\nwake\ncover\nsigh\nrelieved\nheart\nstops\ndecomposing\ncorpse\nwalking\naside\ndigs\nturns\nweeping\nblood\ninfested\npus\ngush\neye\nsockets\npresses\ntake\ndead\ntail\nsimply\nwasn't\nshake\njust\nglad\nstrains\nterror\nsuddenly\nwithin\nmoves\nsound\nwords\nmuffled\nlean\nforeheads\ntouch\ninstant\nsucked\nwalks\nreach\nmimicking\nfinger\nbeauty\nwatch\nmovie\neat\nsnack\nrest\ndays\nwonder\nbeen\nabout\ndip\nstrange\norange\nmist-fluid\nsizzles\nelectrical\ntingle\nghost-hand\narm\njumps\nlife\ngrabs\npull\npops\njoint\nknees\nblinded\npain\nghost-arm\nsuffocates\ndigested\nrisking\nlimb\nplunge\nclawing\nhowls\nsucks\nghost\nstrong\nsolid\ntear\napart\nbedsheet\nonto\nstreet\nslathered\ngoo\nbarely\nbreathing\nburned\nstranger\ncalls\nambulance\nhealed\ninhale\nghost's\nchanging\npowerful\ninsatiable\none-\nminded\ncarnivore\npossessed\nhungry\nsouls\nday\nrelax\ndvds\ncoffee\ndon't\nremember\nbuying\npick\nread\ntitles\nset\n'island\ndoom'\ndvd\nplayer\npress\n'play'\nimmediately\ngoes\ndoor\ngasp\nhouse\nmoved\nrush\nhow\nlighthouse\ncliff\nrickety\nboat\nrocky\nshore\nbelow\nbeeline\ndodging\ncrossing\nrotten\nlogs\never-present\ngusts\nrain\nneed\nfind\nshelter\nlooks\ndangerous\nforge\nonward\nfog\nrises\nsea\nshadows\nmist\ntricks\nfinally\nslip\nplummeting\ndeath\ncrystal\nformation\nmiddle\nheight\n'sit\noh\nnext\nbodies\npiled\nfolded\nlaundry\nblink\nvaporizes\nrattle\nstone\nfloor\nignore\ncrystal's\nodd\nrequest\ndry\ncontinue\nseem\nany\nmatter\nfar\nsign\nclimb\nfurther\nhigher\nbecomes\nmust\nmile\ngetting\nsweaty\nclifftop\nheadfirst\nrazor-sharp\nvanish\namazed\nlooking\nfifty\nhigh\ndissolves\njoin\neternally\nleaving\nreal\ncomes\nview\nsits\nkitchen\nillusion\nopt\nembankment\n14-foot\ndrop\nhop\nbend\nsnaps\ntwig\nmoan\nhit\nunconscious\ncarefully\nwobbles\ngroans\nbreathe\nrelief\nrowboat\nman\nsitting\n'hop\npush\nglance\nisland\nfisherman\nlaughs\nhe's\ntoo\nalone\nstorm\ncoming\n'the\ngrunts\n'if\npoints\ngutting\nknife\nleaps\ncharges\ndash\nrung\nwaiting\nready\nstand\ndodge\ncharge\nlast\npossible\nplummets\nwater\nman's\nstart\nrowing\nfroths\nlightning\ncrashes\noverhead\noverboard\nweek\ntropical\nbeach\nsurrounded\nsurvived\nenter\nconsumed\nblack\nflames\nrecede\nhaven't\nlonger\ntouches\ngod\ncrazy\nslam\ndozen\nboards\nwindows\ncurl\nroom\n'let\nleeeet\nmeeee\niiiiiiinnnnnn\n'fine\nfine\ngrumble\nscuff\nblinding\nturquoise\nbeams\ncollapse\ncompletely\nhorrors\ndid\nwitness\n'sorry\nnobody's\nlie\nhisses\ncome\nmy\nrefuse\nhospitable\nnerve\ntell\ningrate\niiingraaaate\nowe\nanything\nhuff\nshakes\nfoundation\nharder\nthing\ncollapses\ncrushing\ninvader\nwould\nsend\nleeet\nmeeeeee\niiiiiin\nmiffed\nvoice's\npersistence\n'thaaaank\nyooooou'\npuff\nwhite\nsmoke\nwafts\ndecays\nfruit\n'nope\nroars\nkill\niiiiinnnnn\n'ah\nthank\ncatch\nmoment's\nglimpse\nbrain\nbursting\nplug\nears\nlook\nwindow\nreturned\nstaying\nsometimes\nadvantages\n'wait\n'how\nknow\ntreasure\ncarl\ntalk\ncackles\nknew\ngood\nanyone\nnamed\nsome\nlanguage\ncrushed\ngiant\nmeteor\ntruth\nmean\nhere\n'well\n'that's\ndifferent\nstory\nfumes\ndie\nluck\nreborn\nfloat\nmeet\nwhispering\nstay\ntiny\ndiamond\ntv\n'hotel\nsouls'\nshock\nappear\non-\nscreen\nexactly\ncurrently\ndressed\ndiscover\nhotel\ncreaks\nhotel's\nvalet\ncar-\nloop\nisn't\ncar\nfreezing\nspits\nhazy\nsky\nbone\nicy\nhill\nslide\ngarden\nwarily\nmetal\nsub-zero\ntemperatures\nflowers\nbloom\nshatters\nshiver\nstatue\ngrating\nblunt\nobject\nstatue's\nchest\nraises\ncrooked\npointing\ndirectly\nfingertip\ntrickles\nspine\ninside-\nprop\nhey\nasking\nwho\nargue\nchagrin\nexit\nblocked\nidentical\ncautiously\ntrying\nshow\nharm\nunderstand\ngesture\nflare\nvivid\nseconds\nmaking\nperturbed\nhidden\njoints\ncreaking\nfirst\nsoon\ncross\nthreshold\nsnow\nfield\ndream\nrubble\nstatues'\npile\nbeating\nheavy\nwooden\ncellar\nopens\ncreak\ndescend\nsteps\nlit\ncandle\nend\nbeing\nwatched\nmirror\nhandle\nreflection\nbegins\nmaterial\nplane\ndozens\nshelves\ncanned\nvegetables\ndusted\nsalt\ntrapdoor\nbrush\nhideous\nlaugh\nrumbles\nhot\nsulphur\nnose\nscalding\nboil\nshadow-\nleads\nstairwell\nstairs\nendless\nfaith\nlead\nsomewhere\nclimbing\nclear\nanywhere\ninvestigate\nbrick\nwalls\neither\nstaircase\nmarking\nhalf-circle\noverlapping\ntriangle\ndisappears\nbow\nmercy\nbecome\nfigure's\natop\nsuccessor\narrives\nflick\nshadowy\nhorribly\ntransforms\nhourglass\nkeep\nelevator\ndecorative\nsword\nholster\nabove\ncase\nbutton\n[13]\nslows\nhalt\n'ding'\n13\nhall\nsleeping\njaguar\n[31]\n31\ngrowling\nlets\nloud\njaguar-statue\npounces\nshreds\npieces\nquietly\npast\npass\nnotice\nflicker\nsees\nrips\nwhy\npainting\nrocking\nchair\nhangs\nbear\ntraps\nprod\ntrap\nslams\nshut\nsnapping\nornamental\nhalf\nsword's\ntip\nrebounds\nskewers\ngauntlet\nfew\nsnap\nquick\nceiling\ncovered\nspikes\nlocked\nlate\nskewering\nsprint\nnick\npreserved\nfacing\ncorpse's\nspeaks\nincantations\narms\nlegs\nweak\nwithers\nlifeblood\nflows\nmatch\ngushing\ngreen\nfluid\nshield\nspray\nagain\nvial\nbutterflies\nstomach\ncreep\nshimmy\nalong\nfloors\nledge\nslippery\nluckily\nintroduce\nkindness\nenters\n'you're\nliar\nsteal\nwork\nflicks\nincinerated\nash\npretend\nsoftens\nwondering\nshaky\n'my\nupon\ncarry\ndeed\ncourse\nalways\nborn\ncuts\nstabbed\nstares\ncoldly\nbleed\nsmiles\nrifles\noak\ndesk\ndocument\n'this\nserum\nbuilding\npaper\npen\nlarge\nkey\nspills\nfleshy\nproud\nowner\ncost\ngrip\nboth\nrage\ncouch\n"
dict={}
wc=0 
wstr=''
for i=1,#dictstr do
char=sub(dictstr,i,i)
if char =='\n' then
dict[wc]=wstr
wc+=1
wstr=''
else
wstr=wstr..char
end
end
delimiters={',\n','\n','. ',', ','.\n','?','!\n','.',',',' ... ','! ','!',' ...\n','? ','?\n'}
delimiters[0]=' '
function read(addr,ni)
local str=''
endit=false
cc=0
while not endit do
strkey=peek(addr)+shl(band(peek(addr+1),15),8)
delimkey=shr(band(peek(addr+1),0xf0),4)
dl=delimiters[delimkey]
str=str..dict[strkey]..dl
addr+=2
if peek(addr)+peek(addr+1) == 495 then
endit=true
addr+=2
return str,addr
end
end
return str,addr
end
raddr=1024
st={}
for ni=1,131 do
sti,raddr=read(raddr,ni)
st[ni]=sti
end
function book()
nx=1
ps(8,8,8,8,8,8,8,8,st[nx],"would you rather stay at\nhome and watch a movie, or\nbe a little more dangerous?\nmaybe a little trip to\nthe graveyard is in order?","movie","graveyard")
ps(1,8,8,8,8,8,8,8,st[nx],"are you headed toward the\ncity graveyard near center\nstreet, or the old country\ngraveyard outside town?","city","country")
ps(1,1,8,8,8,8,8,8,st[nx],"should you call out and\nconfront the strange\npresence? or perhaps it\nwould be better to stay\nsilent?","call out","stay quiet")
ps(1,1,0,8,8,8,8,8,st[nx],"you shake in your boots ...\nwhat should you say?","say nothing","apologize")
ps(1,1,0,0,8,8,8,8,st[nx],"q","c","c2",true)
ps(1,1,0,1,8,8,8,8,st[nx],"will you argue the terms\nof the deal? or will you\nagree to pledge your soul\nto darkness?","argue","agree")
ps(1,1,0,1,1,8,8,8,st[nx],"q","c","c2",true)
ps(1,1,0,1,0,8,8,8,st[nx],"ooh, gold! will you accept\nthe treasure from the\nmysterious voice, or will\nyou grab it and run?","accept","grab 'n run!")
ps(1,1,0,1,0,0,8,8,st[nx],"q","c","c2",true)
ps(1,1,0,1,0,1,8,8,st[nx],"it's pretty deep ... if you\nfall, it's over! do you jump\nthe chasm, or hide behind\na nearby rock?","jump!","hide!")
ps(1,1,0,1,0,1,0,8,st[nx],"this chalice really seems\nunlucky. do you want\nto keep it, or chuck it\ninto the canyon?","keep it","chuck it!")
ps(1,1,0,1,0,1,0,0,st[nx],"q","c","c2",true)
ps(1,1,0,1,0,1,0,1,st[nx],"q","c","c2",true)
ps(1,1,0,1,0,1,1,8,st[nx],"q","c","c2",true)
ps(1,1,1,8,8,8,8,8,st[nx],"there's a shovel leaning\nagainst the nearest\ngravestone, by a patch of\nmushrooms. it wouldn't be\nhard to dig a hole, but is\nit really a good idea?\n","refuse","dig")
ps(1,1,1,0,8,8,8,8,st[nx],"q","c","c2",true)
ps(1,1,1,1,8,8,8,8,st[nx],"should you make a path\nto set the red-eyed beast\nfree, or fill the hole\nback up with dirt?","save it!","bury it!")
ps(1,1,1,1,1,8,8,8,st[nx],"q","c","c2",true)
ps(1,1,1,1,0,8,8,8,st[nx],"the demons seem to be\nworshiping the foul-smelling\nslug-man. this seems bad.\nshould you run, or approach\nthe blasphemous ceremony?","run!","approach")
ps(1,1,1,1,0,0,8,8,st[nx],"q","c","c2",true)
ps(1,1,1,1,0,1,8,8,st[nx],"you can't run, and you can't\nhide! should you smash the\npendant, or ... swallow it?","smash it!","swallow it!")
ps(1,1,1,1,0,1,0,8,st[nx],"q","c","c2",true)
ps(1,1,1,1,0,1,1,8,st[nx],"if only you knew what\npowers you wielded! no time\nto practice though! what\npower will you use against\nthe demon-slug?","magic!","strength!")
ps(1,1,1,1,0,1,1,0,st[nx],"q","c","c2",true)
ps(1,1,1,1,0,1,1,1,st[nx],"q","c","c2",true)
ps(1,0,8,8,8,8,8,8,st[nx],"two figures continue moving.\na tall shadowy figure on the\nstreet corner, and a person\nin the distance, who appears\nto be holding a flashlight.\nwho should you approach?","tall shadow","flashlight")
ps(1,0,0,8,8,8,8,8,st[nx],"this isn't natural. you\nshould probably run. or you\ncould dance with the figure\nand see what happens ...","run!","dance")
ps(1,0,0,0,8,8,8,8,st[nx],"q","c","c2",true)
ps(1,0,0,1,8,8,8,8,st[nx],"the dancer reaches out for\nyou with a charred skeletal\nhand. do you recoil, or\naccept the gesture?","recoil","accept")
ps(1,0,0,1,0,8,8,8,st[nx],"q","c","c2",true)
ps(1,0,0,1,1,8,8,8,st[nx],"the fire beckons to you ...\nbut it feels like a dream.\nperhaps you can wake up.\nwill you close your eyes, or\nfall into the flames?","close eyes","fall")
ps(1,0,0,1,1,0,8,8,st[nx],"do you take the gold, or\nopen your eyes?","take it!","open eyes")
ps(1,0,0,1,1,1,8,8,st[nx],"q","c","c2",true)
ps(1,0,0,1,1,0,0,8,st[nx],"q","c","c2",true)
ps(1,0,0,1,1,0,1,8,st[nx],"q","c","c2",true)
ps(1,0,1,8,8,8,8,8,st[nx],"your blood grows cold at the\nsight ... what could have\ncreated something like this?\ndare you speak to it? or\nwould you rather run?","speak","run")
ps(1,0,1,0,8,8,8,8,st[nx],"what would you like to say?","wish","offer")
ps(1,0,1,0,0,8,8,8,st[nx],"what should you wish for?","gold","wings")
ps(1,0,1,0,0,0,8,8,st[nx],"q","c","c2",true)
ps(1,0,1,0,0,1,8,8,st[nx],"q","c","c2",true)
ps(1,0,1,0,1,8,8,8,st[nx],"a cursed ring? you should\ndestroy it! or ... maybe\nthere's more going on here.\nyou could hold onto it ...","smash it!","take it")
ps(1,0,1,0,1,0,8,8,st[nx],"q","c","c2",true)
ps(1,0,1,0,1,1,8,8,st[nx],"perhaps the orb wants to\nreturn this ring to the\ngrave! should you balance it\non the gravestone, or bury\nit? it might be unwise to\ndisturb the soil.","balance","bury")
ps(1,0,1,0,1,1,0,8,st[nx],"q","c","c2",true)
ps(1,0,1,0,1,1,1,8,st[nx],"loose skin hangs from the\ncorpse's jaw, and its one\ngood eye is fixed on you.\nno time to think ... what\nshould you do?","step aside","run!")
ps(1,0,1,0,1,1,1,0,st[nx],"q","c","c2",true)
ps(1,0,1,0,1,1,1,1,st[nx],"q","c","c2",true)
ps(1,0,1,1,8,8,8,8,st[nx],"what could it be saying? and\ndo you really want to know?\nyou could lean in closer, or\ntouch the orb for a better\nconnection.","lean in","touch it")
ps(1,0,1,1,0,8,8,8,st[nx],"q","c","c2",true)
ps(1,0,1,1,1,8,8,8,st[nx],"do you pull away from the\nhand, or give in, and take\nthe ring?","pull away","take it!")
ps(1,0,1,1,1,0,8,8,st[nx],"q","c","c2",true)
ps(1,0,1,1,1,1,8,8,st[nx],"you gasp in horror! your\nheart thumps, and your mind\nraces as the ghost-hand\nsqueezes harder! you could\ngrab the arm with your spare\nhand, or try to pull away!","grab it!","pull away!")
ps(1,0,1,1,1,1,1,8,st[nx],"q","c","c2",true)
ps(1,0,1,1,1,1,0,8,st[nx],"the orb ripples, and you\nsense that it will vanish\nwithout its master. do you\ntry to break out of the orb,\nor accept its unknown\npowers?","break out","accept")
ps(1,0,1,1,1,1,0,0,st[nx],"q","c","c2",true)
ps(1,0,1,1,1,1,0,1,st[nx],"q","c","c2",true)
ps(0,8,8,8,8,8,8,8,st[nx],"'island of doom'\n'hotel of lost souls'\n\nwhich will you watch?","island","hotel")
ps(0,0,8,8,8,8,8,8,st[nx],"instead of a quiet street,\nyou're looking out at a\nrocky island in the middle\nof the sea! dark purple\nclouds rage in an electrical\nstorm above you! what to do?","go outside","stay inside")
ps(0,0,0,8,8,8,8,8,st[nx],"the rain falls in sheets,\nsoaking you to the bone. you\nneed to make a decision, and\nfast. it's a long walk to\nthe lighthouse ... but the\nboat might mean your escape.","lighthouse","rowboat")
ps(0,0,0,0,8,8,8,8,st[nx],"there's a dark, mossy cave\njust up ahead. will you go\nin, or forge onward, into\nthe cold, rainy night?","go in","forge on")
ps(0,0,0,0,1,8,8,8,st[nx],"q","c","c2",true)
ps(0,0,0,0,0,8,8,8,st[nx],"will you stay with the\ncrystal?","sure!","no thanks")
ps(0,0,0,0,0,0,8,8,st[nx],"q","c","c2",true)
ps(0,0,0,0,0,1,8,8,st[nx],"the sign points straight\ndown. do you need to jump\noff the cliff? that's a\nterrible idea. what do you\ndo? you could jump ... or\ncarefully climb down.","jump","climb")
ps(0,0,0,0,0,1,1,8,st[nx],"q","c","c2",true)
ps(0,0,0,0,0,1,0,8,st[nx],"there's a doorway in the\ncrystal. do you walk\nthrough?","walk through","walk away")
ps(0,0,0,0,0,1,0,0,st[nx],"q","c","c2",true)
ps(0,0,0,0,0,1,0,1,st[nx],"q","c","c2",true)
ps(0,0,0,1,8,8,8,8,st[nx],"there's an old, rickety\nladder leaning on the edge\nof the cliff. it doesn't\nlook very safe, but neither\ndoes the drop. should you\nuse the ladder, or jump?","ladder","jump")
ps(0,0,0,1,1,8,8,8,st[nx],"q","c","c2",true)
ps(0,0,0,1,0,8,8,8,st[nx],"it's too dark to properly\nsee his face, but he has a\nscraggly beard, and doesn't\nlook friendly. should you\nask him for a ride, or ask\nabout the island?","ride","island")
ps(0,0,0,1,0,0,8,8,st[nx],"q","c","c2",true)
ps(0,0,0,1,0,1,8,8,st[nx],"not much time to think! do\nyou dodge him, or climb\nback up the ladder?","dodge!","climb!")
ps(0,0,0,1,0,1,1,8,st[nx],"q","c","c2",true)
ps(0,0,0,1,0,1,0,8,st[nx],"now that he's gone, you can\nenter the mysterious cave!\nbut he didn't seem very\ntrustworthy ... maybe you\nshould steal his boat\ninstead.","cave","boat")
ps(0,0,0,1,0,1,0,1,st[nx],"q","c","c2",true)
ps(0,0,0,1,0,1,0,0,st[nx],"q","c","c2",true)
ps(0,0,1,8,8,8,8,8,st[nx],"that doesn't sound like\nsomebody you'd want to let\nin. but it could be\nsomebody who needs help!\nwhat do you do? open\nthe door, or stay put?","open door","stay put")
ps(0,0,1,0,8,8,8,8,st[nx],"q","c","c2",true)
ps(0,0,1,1,8,8,8,8,st[nx],"the voice sounds pretty mad.\nwill you tell it your name,\nor refuse?","tell","refuse")
ps(0,0,1,1,1,8,8,8,st[nx],"q","c","c2",true)
ps(0,0,1,1,0,8,8,8,st[nx],"ah, you have some leverage!\nbetter make this one count.\nmaybe it could send you back\nhome! treasure's never a bad\noption. what do you want\nfrom the mysterious voice?","home","treasure")
ps(0,0,1,1,0,0,8,8,st[nx],"will you let it into your\nhouse?","sure.","nope!")
ps(0,0,1,1,0,0,0,8,st[nx],"q","c","c2",true)
ps(0,0,1,1,0,0,1,8,st[nx],"it sounds like it really\nmeans business! do you\nlet it in?","fine.","never!")
ps(0,0,1,1,0,0,1,0,st[nx],"q","c","c2",true)
ps(0,0,1,1,0,0,1,1,st[nx],"q","c","c2",true)
ps(0,0,1,1,0,1,8,8,st[nx],"that's an odd question.\nshould you lie, or tell the\ntruth?","lie","truth")
ps(0,0,1,1,0,1,0,8,st[nx],"q","c","c2",true)
ps(0,0,1,1,0,1,1,8,st[nx],"noxious fumes pour into your\nlungs as the flames lick at\nyour house! it's toxic, but\nthere's something magical\nabout it. should you breathe\nit in, or run out the door?","breathe","run!")
ps(0,0,1,1,0,1,1,0,st[nx],"q","c","c2",true)
ps(0,0,1,1,0,1,1,1,st[nx],"q","c","c2",true)
ps(0,1,8,8,8,8,8,8,st[nx],"there's one light hanging in\nthe lobby, flickering. the\nair is dusty, cold, and old.\na set of rotating doors is\nto your left, and an old\nelevator is to your right.","door","elevator")
ps(0,1,0,8,8,8,8,8,st[nx],"there seems to be a garden\ndown the hill from here.\nit's pretty cold though,\nand you wouldn't want to\nfreeze out here. there's a\ncellar door to your right.","garden","cellar")
ps(0,1,0,0,8,8,8,8,st[nx],"there's a tall statue of a\nhunched woman in the center\nof the garden. the freezing\nrain streaks tears of ice on\nher cheeks. do you ignore\nthe statue, or approach her?","ignore","approach")
ps(0,1,0,0,0,8,8,8,st[nx],"q","c","c2",true)
ps(0,1,0,0,1,8,8,8,st[nx],"what do you do? you could\ntouch her fingertip, or\nfollow where she points. but\nshe's pointing at the garden\nexit ... you'd have to\nleave.","touch","leave")
ps(0,1,0,0,1,0,8,8,st[nx],"q","c","c2",true)
ps(0,1,0,0,1,1,8,8,st[nx],"this statue is breathing\nheavily, as if it's running,\nor has been injured. do you\nget out of its way, or try\nto help it?","move!","help it")
ps(0,1,0,0,1,1,1,8,st[nx],"q","c","c2",true)
ps(0,1,0,0,1,1,0,8,st[nx],"in a moment of sheer,\ninexplicable behavior, the\nstatues touch each other's\nhands, and combust in a\nmassive explosion! do you\nsearch the rubble, or leave?","search","leave")
ps(0,1,0,0,1,1,0,1,st[nx],"q","c","c2",true)
ps(0,1,0,0,1,1,0,0,st[nx],"q","c","c2",true)
ps(0,1,0,1,8,8,8,8,st[nx],"there's a broken mirror on\nthe ground, with a metal\nhandle. do you pick up the\nmirror, or ignore it?","mirror","ignore")
ps(0,1,0,1,0,8,8,8,st[nx],"q","c","c2",true)
ps(0,1,0,1,1,8,8,8,st[nx],"do you enter the trapdoor,\nor dust away the salt?","enter","dust")
ps(0,1,0,1,1,1,8,8,st[nx],"q","c","c2",true)
ps(0,1,0,1,1,0,8,8,st[nx],"it's too late to turn back\nnow. do you continue down\nthe stairs, or investigate\nwhat might be causing the\nloop?","continue","investigate")
ps(0,1,0,1,1,0,0,8,st[nx],"q","c","c2",true)
ps(0,1,0,1,1,0,1,8,st[nx],"you're in a dark room. at\nthe center of the room is a\npile of treasure. on top of\nthe treasure is a shadowy\nfigure. do you bow to the\nfigure, or throw salt at it?","bow","salt")
ps(0,1,0,1,1,0,1,0,st[nx],"q","c","c2",true)
ps(0,1,0,1,1,0,1,1,st[nx],"q","c","c2",true)
ps(0,1,1,8,8,8,8,8,st[nx],"the door closes, and the\nelevator light dimly\nflickers on. only two\nbuttons seem to work. which\nfloor will you choose?","floor 13","floor 31")
ps(0,1,1,0,8,8,8,8,st[nx],"there's something odd about\nthat statue ... you'd rather\nnot walk past it. you could\nrun past it, or sneak\nthrough the door.","run!","door")
ps(0,1,1,1,8,8,8,8,st[nx],"there's something odd about\nthat statue ... you'd rather\nnot walk past it. you could\nrun past it, or sneak\nout the window.","run!","window")
ps(0,1,1,0,1,8,8,8,st[nx],"q","c","c2",true)
ps(0,1,1,1,0,8,8,8,st[nx],"q","c","c2",true)
ps(0,1,1,0,0,8,8,8,st[nx],"there's an open door across\nthe room ... the painting's\neyes seem to be watching\nyou. you could run past the\nbear traps, or set them off\nwith your sword as you go.","run!","sword")
ps(0,1,1,0,0,1,8,8,st[nx],"q","c","c2",true)
ps(0,1,1,0,0,0,8,8,st[nx],"suddenly, the ceiling begins\nto drop! you could be\nskewered by the spikes in\nseconds! do you go back out\nthe door, or run across the\nroom?","go back!","run!")
ps(0,1,1,0,0,0,0,8,st[nx],"q","c","c2",true)
ps(0,1,1,0,0,0,1,8,st[nx],"there's a box of matches\non the floor. do you burn\nthe body, or close its eyes?","burn it","close eyes")
ps(0,1,1,0,0,0,1,1,st[nx],"q","c","c2",true)
ps(0,1,1,0,0,0,1,0,st[nx],"q","c","c2",true)
ps(0,1,1,1,1,8,8,8,st[nx],"there's a middle-aged man in\na rocking chair, staring at\nyou. a painting of a bear\ntrap hangs on the wall. do\nyou introduce yourself, or\npretend to know him?","introduce","pretend")
ps(0,1,1,1,1,0,8,8,st[nx],"q","c","c2",true)
ps(0,1,1,1,1,1,8,8,st[nx],"that's a lot to sign up for,\nwithout any details. will\nyou accept his request, or\nrefuse?","accept","refuse")
ps(0,1,1,1,1,1,1,8,st[nx],"q","c","c2",true)
ps(0,1,1,1,1,1,0,8,st[nx],"as you inspect the deed, you\nrealize to your horror that\nit's lined with veins. it's\nliving ... pulsating. do you\nsign it, or tear it up?","sign it","tear it")
ps(0,1,1,1,1,1,0,0,st[nx],"q","c","c2",true)
ps(0,1,1,1,1,1,0,1,st[nx],"q","c","c2",true)
end
function _draw()
cls()
foreach(snow,draw_snow)
rect(0,0,127,127,0)
local ss=bg.ss
local iq=int.swipey+bg.ss
if game.int then
rect(1,1+iq,126,62+iq,9)
rect(2,2+iq,125,61+iq,0)
rect(3,3+iq,124,60+iq,9)
rect(1,62+iq,126,126+iq,9)
rect(2,63+iq,125,125+iq,0)
rect(3,64+iq,124,124+iq,9)
line(4,110+iq,123,110+iq,9)
line(64,110+iq,64,123+iq,9)
if state==title then
map(0,21,4,4+iq,15,8)
map(0,29,6,13+iq,14,3)
print("the ten haunted treasures",14,41+iq,9)
print("of halloween",40,47+iq,9)
print("[z]¿treasure   [x] view map",10,70+iq,9)
if game.tr==false then
print("warning! this game has some",10,79+iq,9)
print("spooky, gross stuff in it!",12,85+iq,9)
print("you can still turn back!",16,91+iq,9)
else
print("congratulations! you found",12,79+iq,9)
print("the 10 lost halloween",22,85+iq,9)
print("treasures! great job!",22,91+iq,9)
end
print("press ‹ or ‘ to begin",19,100+iq,9)
print("‹",30,115+iq,9)
print("‘",91,115+iq,9)
elseif state==1 then
local q=int.tv
map(37,0,4,4+iq,21)
line(44,4+iq,44,59+iq,9)
if treasure[q+1] then
sspr((q*8)+8,0,8,8,11,12+iq,40,40)
print(ts[q+1],48,9+iq,9)
else
sspr((88)+8,0,8,8,11,12+iq,40,40)
print("treasure:\nunknown\n\nfound:\nunknown\n\npower:\nunknown",50,9+iq,9)
end
print("back: [z]",16,115+iq,9)
print("map: [x]",79,115+iq,9)
for i=1,5 do
rect((i*22)-8,73+iq,2+(i*22),84+iq,9)
end
for i=1,5 do
rect((i*22)-8,91+iq,2+(i*22),102+iq,9)
end
for i=1,10 do
local j=0
local k=0
if i%2==0 then
j=1
k=0
else
j=0
k=1
end
if treasure[i] then
spr(i,(flr((i+k)/2)*22)-5,75+(j*18)+iq)
else
spr(12,(flr((i+k)/2)*22)-5,75+(j*18)+iq)
end
end
rect(12+int.selx,71+int.sely+iq,26+int.selx,86+int.sely+iq,9)
else
cls()
rect(1,1+iq,126,126+iq,9)
rect(3,3+iq,124,124+iq,9)
line(4,110+iq,123,110+iq,9)
line(64,110+iq,64,123+iq,9)
if btnp(0) then sel-=1 os=-28 sfx(18)
elseif btnp(1) then sel+=1 os=-28 sfx(18)
elseif btnp(2) then sel-=12 os=-28 sfx(18)
elseif btnp(3) then sel+=12 os=-28 sfx(18) end
sel=max(min(131,sel),1)
for k,v in pairs(mf) do
v=_load(k)
s=(flr((k)%12)*8)+17
o=(flr((k)/12)*8)+20
q=0
w=0
if v!=0 then v=ty[k] end
if k==sel then
q=1
end
rect(s+q,o+iq+q,s+5-q,o+5+iq-q,ty[k])
if k==sel then
os+=.25
rect(s,o+iq,s+5,o+5+iq,0)
t=''
if v>0 then
if btnp(4) then
story.layer=0
music(12)
for i=1,8 do
story[i]=ml[sel][i]
if story[i]!=8 then
story.layer+=1
end
game.int=false
game.pl=true
end
state=title
book()
end
for i=1,min(#st[sel],26) do
if os>#st[k]+10 then os=-28 end
local os=flr(os)
if os+i<0 then tt=' '
elseif os+i==0 then tt=k..'.'
else
tt=sub(st[sel],i+os,i+os)
end
if tt=='\n' then tt=' ' end
t=t..tt
end
end
end
rectfill(s+1+q,o+1+iq+q,s+4-q,o+4+iq-q,v)
end
line(4,15+iq,123,15+iq,9)
rectfill(5,5+iq,122,13+iq,9)
print(t,12,7,0)
rectfill(116,5+iq,122,13+iq,9)
print("skip to: [z]",10,115+iq,9)
print("back: [x]",77,115+iq,9)
end
print("eggnog",33,199+iq,9)
print("games",35,205+iq,9)
rect(31,197+iq,57,211+iq,9)
print("enargy",73,202+iq,2)
rect(71,200+iq,97,208+iq,2)
end
if game.pl then
rect(1,1+ss,126,62+ss,9)
rect(2,2+ss,125,61+ss,0)
rect(3,3+ss,124,60+ss,9)
rect(1,62+ss,126,126+ss,9)
rect(2,63+ss,125,125+ss,0)
rect(3,64+ss,124,124+ss,9)
line(4,110+ss,123,110+ss,9)
line(64,110+ss,64,123+ss,9)
local t=#txt[1]
if txt.strcount<t then
txt.strcount+=txt.rollrate
sfx(0)
else
txt.strdone=true
end
str=sub(txt[1],1,txt.strcount)
print(str,9,9+ss,9)
if txt.strdone then
if ts.get==false then
print(txt[2],9,70+ss,9)
else
print("well done! you've found",19,90,9)
print("a halloween treasure!",23,96,9)
rect(59,73,69,84,9)
spr(ts.getval,62,75)
end
print(txt[3],9,115+ss,9)
print(txt[4],70,115+ss,9)
end
end
end
__gfx__
00000000000000000999000009990000099900000900000000000000000000009999900099999000009900000000000009990000009999999999000099999900
00000000999990009000900099999000099900000900000000000000000000009000900090009000009000000000000090009000099999999999900099999900
00700700999990009000900090909000009000009990000000000000090900000909000090009000009900000000000090009000999999999999990099999900
00077000099900009000900090909000090900000990000009990000999990000090000099099000009000000000000000009000999999999999990099999900
00077000009000000909000099099000900090000999000099999000999990000090000090909000099900009999000000090000999990000999990000000000
00700700009000000090000090909000900090000099000099999000999990000909000099099000999990009999900000900000999900000099990000000000
00000000009000000999000090909000900090000999900009990000099900009000900090909000990990009999990000000000999900000099990000000000
00000000099900000090000099999000099900009999900000900000009000009999900009990000099900009999990000900000999900000099990000000000
00999900999900000099990000000000999900009999000000999900999900009009000000000000900900009999999999999999999999990000900900009009
00999900999900000099990000000000999900009999000000999900999900009009000000000000900900000000009900000000990000000000900900009009
00999900000000000099990000000000999900009999000000999900999900009009000000000000900900000000000900000000900000000000900900009009
09999900000000000999990000000000999990009999900000999900999900009009900000000000900900009999000999999999900099990009900900009009
99999900099000009999990099999999999999999999999900999900999900009000999999999999900900000009900900000000900990009999000900009009
99999900999900009999990099999999999999999999999900999900999900009000000000000000900900000000900900000000900900000000000900009009
99999000999900009999990099999999099999999999999900999900999900009900000000000000900900000000900900000000900900000000009900009009
99990000099000009999990099999999009999999999999900999900999900009999999999999999900900000000900900000000900900009999999900009009
000010002000300150006000700080009000a002b003c000d000e000f000010211002100310041045102a0006100f000710081029108ff0fa100b100c102d104
e100c000f1000202710012045000220032024200a000520500006200720082015000a0009200a202b200c200d200e203c002f200030071001308ff0f23003300
4300c2005300f0026300f000a00073025203a000920083029300b200a300b3015000e2008300c3002002a000d303a000b0028300e300f3045100c00204001400
2408ff0fc000340032004400a00054015100640071007400f20284009400f000c0047000a402b400c400d4007000e402f403700005027400150425003500f002
4500550065007506ff0fc00085009504a500b502a00005007400c502d500710024032302e503f500060016022600d400a000f401360071004607560071006600
1202760cff0fc00086045000a00296007400a600b6007002c603d600e600f602070017007100270556003700470071005702f000a0006700c50077008702c000
9708ff0fa700b704c002c703d700e702f700a000b0045000a0025200080044001805c0002800f00038045100f00248005803c000c50097009002a00068007800
b6008808ff0f9800a808b800c0008503c802d80090002300b600e806b803a0027400a603f80009001902f0002909b80023003903700049025900690090007900
8902c003f800c5009900a9025904b9008900a000c902d9005000e908ff0f9800f90071000a09b800c0028503a00059001a052a003a004a005a0090006a027a04
8a09b8003900a0027403c0009a00aa00ba05c000ca006a007a0a5102da00ea00fa06ff0fc0000b00a000590050021b0032008900a00052052b003b00230b4b00
5b0cb802a0006b0074007b07600070008b009b00ab05bb00c000f200cb002304db02a0007400eb004a00fb00f0020c00c00cff0fc0001c00f000a0002c043c02
71004c0050005c006c007c026c00c000f20b000070008c029c00ac04b200bc00cc02aa00a000dc045100c000ec02fc002000a0000d001d07a00059008300f300
900071022d08ff0fc0003d00fc04b200a00259045000710057014d035d00c0004b00ba01c0006d002300020450007d022300200071008d03200054029d04ad00
bd00cd02d400dd00a0005905c000ed000000fd000e08ff0fc0001e00a00059004402a0009b032e00bd023e004e005e006c0023026e007e00cc00aa00a002dc03
8e00ca00c0009e018a06b800a0007400ae05be00ca00ce00de06b802fa04ee03fe000f08ff0fc0001f002f0070003f0450024f0071001303a000b0025f006f04
50007f028f00900071009f03f802af00bf00d400e8048a08b802c200cf04df002d02ef00ff0071000015a1009e00b608ff0fa0006f001013f000710220147000
3010740140148f00f000c005501070006010b600e8047012a00080109018ff0fa014e100c000eb00b010e806b802c01471004600d0117100e010f0100113a002
740011142110c002311070004113c0000b02a00051136110f3004a027110700060145100a9028110c5004a0071009118ff0fc0000b00a00051145000a1124400
a000b110c113c2005302d114c000e110f11244007000021b1214c002221032108900a000421264002300521090035102621032008900a0004210aa02c0008300
70007210890082109218ff0fc0005110a000c11094024400a00042145100a211b210c210c000d212e210c000f2105000f2129000a0009203a000031282109210
90101310f000c001510060002310f0001c08ff0fc000d210c200331043104402a00042135310d11470026310731083109312d400a0004213a310b3107002c310
2000a0009204d312c000e310f313041214102414500070008c02341044105410a000b008ff0fc0001c045100641174104410090084109415a4100b00c0003700
a0009c01b410c00094004202a0007313c410d412e414f41005111510900025108902710035104518ff0fc0005510a000c31450026510a0007515a4108510aa00
a00095108902c0045000a510ac004400a002b514c510230ba002b510d510f000e510f512061416145000261236104200c00cff0fc0004610a000c310b2027000
e4003f0b700056126610f700a000b00450007612311070008610c400d402dd049610c0000117a000441050007310a6124400a000920b00000115da00b6109000
b500c316ff0fc000c6102300ac049000c200d6128900e610f61b51006c002302ea042300071b17122710371090007100e015a00047105714500267104200c000
aa00c2027710871cff0fc00097107000a710b712c7105000d7107100e712f71370000810181228107b00d4007100460250003810a000481252045810a002b51b
c00068100200a002c31050006300ba0cff0fc000781071008810b200a002610089009810a8127e007000b813a000c812b510e500d810e810a002f81450000910
c000020090027000191029133910c002491059106910271cff0fc0007910aa00a00089125204a00099100902a9108900b9145000c91209003000d9102002b210
e91351006c00c002f910f110a0000a1079021a14a000b9102a1090027d033a104a10f308ff0fa0005a106a1083027a14d81090008a129a13f510aa108300ba14
5102e5003800b200a00076156c00c000ca10da143310ea12fa109000a000b0045000a0020b101b102b14311070023b104b18ff0fc0005b10f0001c045100a002
6b107b128b109b10c003c002ab14bb105002cb106c00a000db121800eb14fb12c000f2105000f21044020c106708ff0fc0001c10a0006b122c143c10aa00a000
4c125c146c10a0004c127c13a00078002b128c1050008c10ff00a0029c108900c004ac1000004802bc10cc107000dc1090007000ec12fc100d18ff0f1d14c000
2d1050023d10320089004d10b200a0025d106d107d17a1008d109d10ad12a00089145000ec0090007002bd10da107100ba03a102cd10f0004a00dd1bc0001b02
ba005000ed10fd10f0000e18ff0fa0005d101e102d022e107100911450003e12c0004e13c000f20003005e12b500a0006a106e10b502890070007e138e109e10
8b12ae10be1450007000ce12de10ee10dd008e10fe110f1032008e109218ff0fc0004e107100921451001f122f133f10900071004f112f0071005f13a0026f10
7f1070008f1289009f1090008e101e12e71a7000af1a7002bf1aff0fc0008700cf103d1044028e10921aa00014105f02df106c0071004510ef12d4007100ff14
50007102ff105b10f0000028ff0fc000102099008e12af1349009f1050002022302090007100e71351024020c000502071009214a0022020ca006020f0000025
c00009009000702480229020b200a0003b11a02090007000b0207808ff0fc0005020710092145000a0026f1083000f0390028e107d0083007000c0208902d904
43006c00d0206c00c007c000e020a0004900c022ba045000f02020000120890023021120212031205002412051206128ff0fc0006510a0007121510081209120
b502a12083006c10a0009a150000c200b124c1209c000511d120b2007000e120f1229a13dd00a000b120830070028a00220402201222b200f51092102228ff0f
c000322071004220b6027000c60323005220f0004a00c2026220471dc0007220822070009224a222b220c220f000b010a0024718ff0f62104400a000b124aa00
a002d220e2208900a00202202204c000f2200202a0000320f000822070009228ff0f98009220b6003100a000d9009002a000780cb800c0001320aa02a0002320
b123c01149003320e110d4007102fe14320071004320500292145320a0009912b200d9046c00c00063217323a000b1208320be18ff0f98009220b600932cb800
c000a322f000a000b12370009a10b3215000a000b1201a0ba102c320b200700072108900d322e320f320d4027100fd100424b20048021420f0002420342b6112
ca00f0004b0044205428ff0f8e006420c0007426b800c0002902a000b123a000b120842231109420a42450007002b420c420fa10d4203202a000dc0089002308
ff0fc0000b007000e420d4027000e400f4200525c0005510a0001520b60070022520781451006c00230035224524a000b120b325c0005000a000fa105522652b
a00015207522710022003110700085209528ff0f6c00c000f310a000c422fa14a000a520b522842450007000c520d522e520f52083000622440071004f13c000
1620f002a0005204500026227000f400b200a0004c12c528ff0fc0003620a000fa10200001208902a000f4044620ba015000ed10f0000e1351004020c0024e10
71009214a000b1208302c9146210c0009000a0026a13c00056205020710292145000c000562066200205c000e520c508ff0fc000a110700042100110a002f404
7d00a000fa12dd045000762023000200b202c113a000b1201a045002c0008624962351006c02c0005b10ff047100a622b6237000c620d6228300e6204200c008
ff0fc000f910f6206c00a000d6220720a000fa10020450001722f000c004272337205002472057206720d400f512772087206c0023009722a000fa1044007100
2d03c002a720a000fa145000a0004602d420ac04b728ff0fc0005b10c72050001b00be12d400a000e620d62b51022300e5000c00c00a2302d720d420ac04b723
bb022300e7205d00c004da02b61023005d0ec000f7207102220408201820f0004a00dd18ff0f710046002820f00038015100c000af001c0338227f10c000f30a
a000b122832013134824a0026a105820a000b1206825f510921050245000f51043226820a70070007824f512882098203700a000b128ff0f6c00c000a8204200
a000b121a00096006a10eb12a000a520b52a7102b820c82450009000c202d824710022008300e8224400a000b123a00096022200f820fc1ab2007102460cff0f
6c00c00009204200a000b12170002d006900dd00a002b12419207100b21238032000f510292083007002c420fa13a102bb1a9b123700f5103928ff0fc0002d10
d400a00096022d045000a000b1201a05c000ed10ba044920700059216920700079245000ed10f0000e155100b600a0008920890071029924c000a920da00a802
ca00b92ac000a922c920a000c420fa18ff0fc000d92071002d004400a002b12aa000e920f9220a201a20200071029e10b2007000b1142a223a236c00c0001c00
71002d020110a0004a24f000a722a000fa14a0005a206a20f0027a2450008a2071002d0cff0fc0009a209404500071005a22aa2032008900ba2bc0003d12f000
7100ca24da203702a000ea2ba000fa223e10c0004400a000b12050020b20c00361104a021b205820a0005308ff0f2b207a2050003b24c0024b2071000d002d00
4402a000b1245b20aa00a0024a2ba0006a106b2150007b20c0004400a000b127a0008b2083009b2451000702ab245000c000bb202302cb203110c2003310db2c
ff0fc000e1103200eb20a002fb2ba1000c2090021c242c203c2471029e104c205000aa100f0b70025c206c20c2007c2151003700a0003a10a410791171004600
8b108c245002b0204400a0004108ff0fc0009c20a000ac2046015000e810710091104602bc23a100cc21dc23c0000900ec22fc2470000d211d2037000410bd01
2d20b6003d2480209002a000b12a9028ff0f0000b9207000ba104d24e100c00208207420f0005d2050004922700059239c106d20f020200271007d208d0ac002
8d209d20ad203425c000bd20342002005000cd22a000dd28ff0fc000ed20fd2089000e20900271001e202e2450003e224e235e24a00261006e20320339106112
ca00f000ed10820351004022c0005020710079007e21c0008e209000201b71029e2a8b10ae2cff0fc000be208203ce20f202a9004a0e71009e20b61dc0005b10
940450008e23a0029e2083000f0360007002de20200070000412ee2450007000fe2033120f20200070001f202f203f28ff0fc000822070004f20b600a002de24
51005d00c202530089005f2016016f207f208f205000a0029f20af208900bf2250007614c000cf20f000df22ef28ff0fa0000210ff200034e102c00010302033
d1109002a00041047000c30030304032d400a000503360309000a002703001008030200071024f14ac10c0009032a034b030f0007102c0302000a000cc003f2c
ff0fc000f9104400a00002156000c20077100812d030e0309000a002f0308900a0000214e5127100013a700074026c20f000c000d400dd00a002d0331130b200
e8042131f020b200e800b6007000c608ff0fc000f0203130f000a000d0315000ab1044002303c91009024130dd0a5130020250006130311071339002a0008130
8900c2007724a00245109130d4007102460450007100ff10a132ac00eb20a000b130c13cff0fc000d130a000e130f13202341230cf10fc115000223020007100
1425a000de20e5003232f0004b004230131448005232ce206230c0006303aa00a000012289007000ee24c000030070007232b2007000de2020002308ff0fc000
1b108230ac00a002ee245100a0009230ac02c0008234a000a230a002ee20b233c000c2304a027000d230020037005e1a71026910f20056004f00b602e100ba14
50007100e7100902e230f23300000118ff0fc0005c00d400a0000331133ba0002332cc003f20be204200c0015100482033334331c0009120b50071009c020900
2000ab209203a1025330f1107000d032b810aa00a000de28ff0fc0005020a000d0307e2560004800de245002600048009a130822ff13ff10513063329c007333
71009e128330440000245002c0009330a000ff11a338ff0fc0006300be10d400a000b811b330a000d0302f056c00f5109a100804a000c332de20d3304400e337
c000e110f110a00079027e245000df20cf10940290007100ba0b7000d0305e12f3302000710004308d08ff0fa000de2072204a00c2021434e100c0002430b600
a0020f23c0002210ac00a00298101f20343451026400c000f2000920a0020f246000700044325438ff0fc000a72070008b0013046302f000a0002c0450006430
fc15c00074307100ca206c00c002ec0451007100fd104c02843031107000943bc000a4329000ea24b4307100220020007002b130b81450003d11c4344400a000
5038ff0fc000f910eb20a000fe2243145000d4308232ac032300e4305000f43151007f13c000053070028620890015306c00c0000922a000dc0bc0006510a002
253450002a1d600070003530453090002308ff0f55309009b800a3103903a0009c128900c0006530c410fe200f22fc104400a00054005033c00275309400aa00
a0008531510000000f0ba0009532a5345100b5300f00c537a1003100d5309000a0005402503450007000e5308300f538ff0f06308536b800a31016332632c000
7420fc146000700002120110c918b800a310363070022920aa00700002102f00c005c800770056208700c0003628b802a3104a147000463056329000c4102d03
a3106630d402a0000f2450007630c00cff0fc00086309400f000a0004311500082306c0094106c00c002f20b51006c00c000823470027f209630843090007102
2d045000c0003d10f000a002dc0ba00095308302a630c914c4105630aa02a000b638ff0fc000c630aa00a000b6345002d630c410e630aa00a000f6320730c60b
a3106e02c41022002000a000b130b811500017304400a000273cff0fc00064304400a00037300f2150004730573ba000503267347730873297345000a1008d12
a73bc000662002007002b730d11020007000c732d734e7303700b915c000f73cff0fc0000830a000021450000902183037007000b81089002832383b51004020
a00038324834c0009120b500c0025830b9204c2451029a10480068307830c007c000c50076002000a00285306c00a00088308900180cff0fed10820e0900c000
983fc000a830a0007e2415207002b830c8300110a002d8345000e83002009000a002f0308900a000f833700074028f00d40082030932e800900319302932393c
ff0f4934593cb800c00069315000793071009c000110f002a0007e23c0005020230450027000893099309a12a93001107100460bc002b930f000a00092047102
4f10c9300f03da02d930e930c000f936ff0f0a341a30ba0cb800c0022a30f000a0006d107405a00074003a33f800ca024a30f0005a30ba045000c0026a30f000
4a007a3ea0028a3b9a30e8007100c521aa33ba3cff0f98008d20ca30c000da3cb802c000ea3399309a12a930f110a000d831500071009e20fa30aa00f5120b3a
1b3d1b34ac10a00048122b303b30ac014b30c00cff0fc000c70450009a30a00274007100c523a0007402a600b6007000c603f8020900c2005b3090005a30ba05
da006b308220c0003626ff0f9800c5007b30c000ba00bb00c0028700e80090038b309b32ab3cb800a0007400ae08ff0fc0005020a0007e24bb30aa02a000cb30
db35eb30fb30a00074028f035e2470020c3089001c302c303c320110c0045000710046024c30311070007f205c3cff0f6c3cb800c0006a33a00274007c345000
a0009e22fa3b9800c5008c30c000bb02c0008d208700e800900b193229309c3cff0f493cb800c0005c00f00071029c045000d710a0007e225023ac34bc30c008
b800a00274003903c000cc307002dc30ec308900f5126220460450007102fc30ef140d30320271007720872cff0fc0004e107100921050001d3271002d345100
9502ea03d434c0003d323200a0004d3300007102fb2b71009e208b10b9225d30ba0b6d32dd007d308b10f5128d3cff0f9d39b800a0007400a605ad306420c000
bd30c9205a32cd3eb6102300dd3ee932c000ed30f000dd36ff0fa0007400fd3398000e32c000d0000200f00048001e3b77028d20bd302e303e32dd3cb800a000
740039004e3288209000c200f1305e3150007100ba0083005e226e30370070007e308e3cff0fc0009a30a0009e34b500c0028d20bd302e303e30dd325000b500
c0004910d812ae30f0004a30be33ce31fa09b800a00074003905de307000ee30fe38b802a000d830e1105024500228303830a510dd0cff0fc00005309000a000
b7120f345000c0101f3551046c002f306b30ca0023017100460083003f346c0070025400e6207033c0004f323200890071009e2450005f32a0006f30740ac002
c5007f30be309028ff0fc000d630a00038305002e1103200a0007e2089007102ba0a4400a00079007e2289007100ba03c0008e23a002853083000f0450007102
9e2083009400f000a00014202302b61370008f3028309f325e10f33020007100af30c638ff0fbf308900a020cf3023008307c000543023009000a0001e222e24
50003e204e23f0027100df34c000ef30ff32004410406c00a10220403043c0003d320200d400a000af34f0004042b500a100dd007000504cff0fc0006530a000
db107e225000f910f113230060426c0023001723c000f9103202eb20a000704080409042a043c910b0407000c04090029513d040bf20e042ac00d4007000f040
01413010c000f000a0001148ff0fc000f910eb20a0002140314150004140ac00f000a0025143c0006140f912f110a000714051421a13d8109000741081429144
a000a14209009000b143c000c820811150002300c148ff0fc000d140aa00a00095108902a000e14450002230200271001424ff007000d022bd13700078203110
7142f1402000714016122f00c00450007000024212406e00710022009002d4002f0bc0003d14b728ff0fc0006510a000e14450029124f00071002011b500a000
224032408302211a3c23aa0271006514a000e142424070005240292162407240aa00c00cff0fc000551071002d045002c820a00022408242b200710091137000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
f60082212904ca0017002a44c6200c00a2014d000a002b24234037020f00a40007002c0409200a003a0015440982fff02d44bb009a007d201e0438002e040c000f206302e80115442f0490200c000f0030e40c00b501052083000f006342150019120f00170031445b000a20150432043800e501332473002c0034041ec4fff0
0c00350456010a201e4436040f0037045b200c00ea03840038340a001e245e0039040a203a345f0129013b0407203c04ec410500170064204c0044004bb01a207b0209003d84fff00c00c5000f000a00d1403e248f036b000a001e34322025023f44d50013500a001e04a44140244104420405001f5432008f02da010a001514
05000a0043041e24be0132c0fff00c0063020a003a001554c6004404c6000c0045040a2046440a004704fe510c00d30320000a0013040520e8320a0005043800f0701a00090007004844700026234d001700ab306b013200132007004964fff00c001a011f010a004a2498000a004b04f251b80009000a004c44060007201704
6a3200003f204d340c003f013240052063020a0015340a0005243800f04005001a00700026234d00abc0fff00a004e044f045004e72251042b000700524405000c204d0353040a00542444000a0050340000451055047300070091015604aa200a002603570498000a008f330c208e01c600bb001a0058245984fff00c00db02
20000a005a0473200a005b040500d30344003250060084005c341520c6000c00ba01aa0032401720a601b101960009000a205a440500170064005d240f0033034d000a005e245f341601a400f0004484fff09c0190006004980061149a01980062046314050064042b00ad0096200f00a4a08203653413230f000a0056449c01
3800072066442b000700af019820820365046404ff003280fff00c006704eb010a00654405200700680469046a044d200a0066346b046c24ee0117006d4405000a2050042b036e046b74c6000c006f04dd4107007024b00104034d000a2083b3ad00ac000c00e960fff00c003f01e4036504052080030a00e7423d0171240f00
0700ab41450072540600a901aa000a00cd10150032005e0023030f00b4203101c6000c0036302c00352009400c009a02bb000a0073248a00a4002c0074040a84fff00c00224309006e0175245b000a0073045c00762477344a01d8322c2035001d410c00b50149101500d5000700d40298007814000079045b0047217304d802
de017a540c005c00f103eb83fff00c004d037b240a007c047d0402007e24d10098000a007f3418217c0402000a00dd008b01b821070080a4070081248204070083340c20e30202000a007c4405000a207f048484fff00c0085445a006b0086540a00b0013e0124242c00a542050017006420a1300c00ac008704072081400500
5c007a020a208804d740540389240a00dc034c44ca2107008a048b84fff00c008c04e4036504aa000a208d04b0b1320061218e4405008f2444000700f80390449a219800820365340c00b5010a20900409001700d2400520900084024900abb00c2091040a009084fff00c0056010a0092540600070093049424090007009504
96040a00e7520c00b00032a0800209209734c6000c0090020f00e3220a00920498440a20e70251447a00070087520c009f01dd80fff00c00e302994405000a209204b1010443af209a040f0007009b349c240a00e70251443e511c039d0451040f000700ab1145009e34060007001e24980007009f04a04413230f0007002202
e782fff00c00e302a14405000a209204b1010443af209a040f0007009b349c240a00e70251443e511c03a20451040f000700ab1145009e34060007001e2498000700a304a04413230f002c000502d483fff00c0056010a002202e7220500b5010a005b340a20e702a40423000700a504521405000a00a6043d230f00a7b24600
0c002f20e3403200a7440520a8040c000f00a9c4fff0aa440c00c100ab040a201eb41500c6000c00ac0432100c00ad040700ae049820a90109005f0129b10a201e04b801a4030f00a74205203200af040cb046000c202f00e3403200b0040c000f20a8c4fff0aa440c00c100ab040a201eb432005e0083300520b104b60332e0
0c003600ca200a0045009e040500800307208f0302000a003c320700b22498000700530309000700b304b424b50402000a008b31b624b70467020a001c83fff00c00b8040a004304b604b9242b001700944405003220ba04bb44bc040a20bd0494040900be740a00bf04c004c104cf210a00b9040500c2040c201f010a0077b2
0c00d3010f200a0029407b82fff00c00c1001f010a00c3249800b604b7b40700c404c524bb4415001a005c03c6740c001e011f010a00e72202000a00d000573406200700e702da010a008fd305000a00c7043800c82409003203c984fff00c00b501ff000500b0000a20e7025ba415000020cab40c0074030f00c120da010a00
8f43150000205c03cb340a00c7243d03ca0002000c40cc240c002b0007008b03c9c4fff00c00cd04da010a008f1305001e011f010a003224800209000a00ce049800a3711a00e501090007004b028f5306000700cf046d2209000700b304b444d0240700d4335f01290190200582fff0c6000c0090020f00e4010a20d1042941
0a006d228402d234d62188a2d3341720d4040500d5040901d644052017006400d734d824d90444000a00d1240e414d0017001981fff00c0079010700da4405002d213200be020a006d320a0064204c40db04dc04dd1405000c00de041700a6214d000a00dfb404020c20d303e0441a00090017201901abb006000700e1049820
dc04dd04090017003f81fff0e20409001700e3140c00e40423000a00d4130500e504e6040a00282098000a000544a204e704205000000700ab014102ca4005200a00e8043800e954ea440c0090022c000522d44305009f01dd80fff00c00eb04fc4115208400ec04ed044c01a651ee040700ef848b003a01a353ee04eb030f00
f004a523f1c48b003a01f2040700dc24e104aa000c400500170064204c004400dc048313f3044400f4c4fff00c00f5040f00db03b54005204c01a601f63489006b21f70404020c00b62397818b003a01a441f804aa200a00ac32f9046f0399029020fa048ea07700fc020c000f20fb040200a503f1341601b4200a00fc449800
fd84fff04c01a601e602f6000500c720c6001b338900fe04e0030c200d002c00aa334d000a20d4020c000d00ff447700e0838b200700cb00ae02000544001720e34405000c00d3010f000a2029305b0301050cb03a2102050305c6000c000485fff00c009f4005003a0105553a0106051f012c003301072508450500e3012300
072009350a0538000a00fc54270332300a000b0505000a200c055c00a400a5808b003a217e010c000a000d4507000e15050007000f0594001085fff00a000e0511057302be220a001205fc44c6000c20270317005c320a003301532371020f00000207013a21a4311a00e5010a001325140598000a0005a41520aa00ad001565
fff00c0016050a00fc042b0017257e410500bb0232000900c9710a0033015303b60209001875dc04dd044c004d004c21294105000a000504af73c60032004d420c00660220000220170019b50a00050410053820090017003f81fff0000000000000000000000000000000000000000000000000000000000000000000000000
1d1c1c1c1c1c1c1c1c1c1c1c1c1c1b001d1c1c1c1b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a000000000000000000000000001f001a0000001f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a000000000000000000000000001f001a0000001f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a000000000000000000000000001f001a0000001f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a000000000000000000000000001f001a0000001f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a000000000000000000000000001f001a0000001f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18191919191919191919191919191e00181919191e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d0f0d0e0d0e0d0e0d0e171617000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00140b1510171617161510141217000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0013101700141014101700131011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010200000e77010000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012600001137011361113611136111351113511134111341113311133111321113210e3700c3700a3700e37008370083610835108341083410833108331083210037100361003510034100341003310033100321
012600000c3330c333116730c3330c3330c333116730c3330c3330c333116730c3330c3330c333116730c3330c3330c333116730c3330c3330c333116730c3330c3330c333116730c3330c3330c333116730c333
012800002b7502b7512b7412b7412b7312b7312b7212b7212b7112b7112b7113000028750297502b750247502c7502c7512c7512c7412c7312c7212c7112c7112b7502b7512b7412b7412b73128750297502b750
012800002e7502e7502c7502b7502c7502c7512c7412c7313075030751247402473125750247502e7502c7502b7502b7512b7412b7412b7312b7312b7212b7112975029751297412974129731297212971129711
012800000025000250002530125000250002500025300250002500025000253012500025000250002530025000250002500025301250002500025000253002500025000250002530125000250002500025300250
012800000023300000000000c0000c653000000000000000002330000000000000000c653000000000000000002330000000000000000c653000000000000000002330000000000000000c603000000000000000
012800000742007420074200742007420074200742007420074200742007420074200742007420074200742008421084200842008420084200842008420084200542105420054200542005420054200542005420
012800000a4200a4200a4200a4200a4200a4200a4200a420014210142001420014200142001420014200142007421074200742007420074200742007420074200742007420074200742007420074200742007420
012800000043000430004300043000430004300043000430004300043000430004300043000430004300043003431034300343003430034300343003430034301343113420134201342013420134201342013420
01280000074300743007430074300743007430074300743004431044300443004430044300443004430044300b4310b4300b4300b4300b4300b4300b4300b4300b4310b4300b4300b4300b4300b4300b4300b430
01210000305553355537555385553055533555375553855530555335553755538555305553355537555385552e5553355535555365552e5553355535555365552e5553355535555365552e555335553555536555
012100000007300300000000c0000c603000000000000000000730000000000000000c603000000000000000000730000000000000000c603000000000000000000730000000000000000c603000000000000000
01010000093700e3700f370103700e3700b3700937007370043700237001370004000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01200000003310c42118421244210c0000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0120000005331114311d421294210c0000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01070000300503c0503c0303c0203c0103c0100060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100002b62500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003b22500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012100000c7750f77513775147750c7750f77513775147750c7750f77513775147750c7750f77513775147750a7750f77511775127750a7750f77511775127750a7750f77511775127750a7750f7751177512775
010200000677010000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011b00200004304303000430400300043040030004304003000430400300043040030004304003000430400300043040030004304003000430400300043040030004304003000430400300043040030004304003
011400200004304303000430400300043040030004304003000430400300043040030004304003000430400300043040030004304003000430400300043040030004304003000430400300043040030004304003
010e00200004304303000430400300043040030004304003000430400300043040030004304003000430400300043040030004304003000430400300043040030004304003000430400300043040030004304003
010100000c1730430300173041030c1730410300173041030c1730410300173041030c1730410300173041030c1730410300173041030c1730410300173041030c1730410300173041030c173041030017304103
012100201f7401f7411f7311f7311f7211f7211f7111f71118740187311872118711247402473124721247112274022741227312273122721227212271122711207402073120721207111f7401f7311d7211d711
011400200410304203041030410304103041030410304103041030410304103041030410304103041030410304103041030410304103041030410304103041030410304103041030410304103041030410304103
013400003757530575315053050531575305053557537505335753a575365053a57539575305053257536505375753157535505315753257530505375753b5053557530575305753250530505305753257531505
01450000074200742107421074210742107421074210d421074210742107421074210742107421074210d421074210742107421074210742107421074210d421074210742107421074210742107421074210d421
01450000034200342103421034210342103421034210b421034210342103421034210342103421034210b421034210342103421034210342103421034210b421034210342103421034210342103421034210b421
01390000247251f715207151f7151b715187152472526725277251f7151b7151d7151b7151a715267252b7252a725217152271524715227152171526725237152b7251f715137151f7152b7251a715277251a715
013900000c7200c7200c7200c7200c7200c72013720137200f7200f7200f7200f7200f7200f72013720137201272012720127201272012720127200f7200f7200e7200e7200e7200e72017720177201772017720
01390000007400074000740007400074000740077400774003740037400374003740037400374007740077400674006740067400674006740067400374003740027400274002740027400b7400b7400b7400b740
010200001277010000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 01 02 43 44
00 03 42 43 44
00 04 42 43 44
01 03 06 43 44
00 04 06 43 44
00 03 06 07 09
00 04 06 08 0a
00 03 06 07 09
02 04 06 08 0a
03 0b 42 43 44
03 13 19 43 44
00 1c 1d 43 44
01 1e 1f 20 44
00 1e 1f 20 44
00 41 1f 20 44
02 41 1f 20 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
