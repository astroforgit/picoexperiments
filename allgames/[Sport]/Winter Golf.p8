pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
daynumber="3"
cls()flip()
extcmd("rec")
::_::
if (btnp()>0) goto donewithintro
cls()
f=4-abs(t()-4)
for z=-3,3 do
 for x=-1,1 do
  for y=-1,1 do
   b=mid(f-rnd(.5),0,1)
   b=3*b*b-2*b*b*b
   a=atan2(x,y)-.25
   c=8+(a*8)%8
   if (x==0 and y==0) c=7
   u=64.5+(x*13)+z
   v=64.5+(y*13)+z
   w=8.5*b-abs(x)*5
   h=8.5*b-abs(y)*5
   if (w>.5) rectfill(u-w,v-h,u+w,v+h,c) rect(u-w,v-h,u+w,v+h,c-1)
  end
 end
end

if rnd()<f-.5 then
 ?daynumber,69-#daynumber*2,65,2
end
 
if f>=1 then
 for j=0,1 do
  for i=1,f*50-50 do
   x=cos(i/50)
   y=sin(i/25)-abs(x)*(.5+sin(t()))
   circfill(65+x*8,48+y*3-j,1,2+j*6)
  end
 end
  
 for i=1,20 do
  ?sub("pico-8 advent calendar",i),17+i*4,90,mid(-1-i/20+f,0,1)*7
 end
end
 
if (t()==8) goto donewithintro

flip()
goto _
::donewithintro::

cartdata("winter_golf_2darray")
music(0)

function _init()
	reload()
 currentmap=1
	state="title"
 maps={"~519c50974f904d8a4d844d7e4e76516f55695b62605d6b5873557c5483548b559157975a9e5fa263a569a770a879a980a98aa991a698a19f9ca3~84ad81ad7dad77ae73ae6dad6aac67ab64ab~9ca397a595a793a8~85ad85b285b585b886ba89ba8cba8fba90b891b691b392b193ae93ab94a993a9~85ad93a8~64ab61ab5ea95ca85aa758a656a454a253a0529e519d,b0ae,7b759f975897,63a455,43|44|45|46|47|48",
       "~826c826f82728374847685788779897a8b7b8e7c917c947c967d997d9c7d9f7da17ca47ca67da97dab7cae7cb07b~796d7970797379767a797a7c~848481847f837d827b817a7f797d797c~aea7aca9aaab~56a658a55ba55ea560a463a4~67bb66bd63bd61be5ebe5bbd58bd~8a3f8b3e~76a174a271a26fa36ca36aa467a464a462a4~b07bb078b075b072b06fb06cb069b066b063b060b05d~b05eb05bb058b055b052b04fb04c~58bd56bc55ba54b754b453b252b052ad53ab54a955a7~919f8fa08da18aa187a184a180a17da17aa177a1~773e7741774477477849784c794e7b507d5280528253855388538b538d52905193519550984f9a4e9c4d9e4ca04ba24aa549a849ab49ae4ab04b~aaaba8ada5aea3afa1b09cb199b396b394b491b48fb58cb58ab686b684b781b77fb87bb877b873b870b96cb969b967ba~69b955b9~5e8e608f638f659068916b926e937193749477957a957c967f96819784978698889a8b9b8d9c909c919e~5c8d5e8e~b495b498b49bb39fb2a2b1a4afa6~826c8269~9d829b819881958192818f818c818a8287828483~b495b492~b493b494~9e82a083a384a685a886~b490b493~b490b38eb28cb08aae89~a886aa87ac88ae89~5c8d5a8b57895587528450814f7f4d7b4c794b764b734a6f~4a6e4a6b4a674963495e485b475747544651464e464b4647464347414840~796d796a79677c677f6782678269,b887,a9a691b077b1a86b63868d947e5e,9a78143,42|43|44|45|46|47|73|74",
       "~625c5f5c5c5c5a5e5861576356665569556d566f5771587359755b765d785f796379657868786b786c7a6d7c~507a4f784d734d6f4c6d4c6a4b684b654b614c5d4d5a4e5850565254565258515c5161516352675368556a576c586c5b6a5d655e635d625d~9e829b8599869787958892898f898c898989878a858b838c828e8190819381978299849c~b57ab577b574b56fb56cb467b364b060ae5eab5ca85aa559a3589f589b589957955791588e588c598a5a875c~5daf60af63af66af~6cbb69bb64ba61ba5eb95bb859b756b654b551b44eb34cb24ab148af47ac46aa46a646a1~4a8c498f489247954699469c46a146a4~547c517c507b~92b195b1~b49fb49cb499b496~ba9dbaa0baa4baa7baaabaadbab0b9b2b9b5b8b7b7b9b6bbb4bcb1bdaebdabbda8bda5bda1bd9dbd99bd95bd92bd90bc8dbc8abc87bc84bd81bd7ebd7bbd78bd73bc71bb6fba6dba~9ab39ab79aba9cbb9fbba2bb~a1bba6bba9bbaab9abb7~acb6acb2~9bb2abb2~a882a683a484a285a0869e88~a982ad83af84b185b287~b885b882b780b77db67bb579b679~b985b989b98cb98fb992~ba91ba95ba98ba9cbb9f~b495b491b48eb38cb28ab287b288~81b17db17ab177b173b16fb16cb16ab068af67af~81b185b1~93b18eb18bb188b185b1~95b198b1~99b19ab19ab3~80647e657d637e618060825f845e865d885c895c~80648263856388628a618d6190609360965f98609b619f62a164a366a468a56aa66c~9e829f80a17ea27ca37aa478a576a674a671a66ea66b~4a8d4b8b4c894d874e8550835181537f537c537d~acb2afb1b1b0b3afb4adb5abb5a8b5a5b4a2b3a0~9aa297a294a291a28ea28ba289a187a0859f849d~9aa29da29ea09e9d9e9a9e979e949e919e8e9e8b9e889f88~6b83678464855f875d885a89588b558d548f529250964f994f9d4fa250a551a752aa54ab56ac58ae5bae5eaf~6b836d826d7f6d7c6d7d,8d93,93655aa6a798,6173165,157|158|159|160|161|162",
       "~6fb172b175b1~698b678c658d628e~75b178b178b479b67bb87db980b983b985b887b7~88b688b389b1~78b189b1~b26db269b265~8c478946864683467f467a46754772476f47~9f5e9d5d9a5d985c955c925c8f5c~a064a0619f5f~8c5f8d5d8f5c905c~a0659f679e699c6b9b6d996e98709671947392748f758d768b7789788779857a827a807b7d7b7b7c787c~747a767b787c~6f476c476747644761475e465c475947~b266b267~8b478e47~ad5aae5caf5eb060b162b265b267~6a8a688b~ad5aac58ab56a954a752a551a350a04e9d4c9b4b984b964a~8f478e47~964a9449924890478f47~8b9b8a9d8aa08aa38aa6~89b18aaf~8aa78ba98bac8aae8ab0~5e735c745a755876567754785279527d517f51825185~6fb16db0~8b9b8b988b958b928b8f8d8e908e938e~638e608f5e905c915a925893569455965698579a589c5a9e5ba15da35fa560a762a964ab66ac68ad6aae6caf6eb1~5a4758485549534a524c~938e968e998e~a789a987ab85ad83ae81af7fb07db17bb178b177b174b171b26fb26cb26b~998e9b8d9e8d~9f8da18ca38ba58aa789a889~6a886a89~51855387548957895a895d896089~8c5f8b618a6389668869886c876e867085728474837681777e77~787279747b757c767e777f77~6a88698667856584638361826084608761896188~4e574e544f525050514e514c~51604f5f4e5d4d5b4d584e564f54~657062715f725e72~6570676f666d646c626b606a5e695c675a66586556635462526150605061~78727674~737a747a~767474767378737a,9761b7b4,7684716e6163,908917,9|10|11|12|13|14",
       "~473f474247454848484b484e495149544957485b475f466346664669476c4770487248754977497a497d487f4882~57c157c3~b86fb873b876b778b67cb57fb482b285b087ae88ad8aab8ba98da78ea58fa390a0909d909a90~a7c3a6c3~b85bb85fb862b865b868~b867b86bb86eb86f~6e3d6e406e436e466d486d4b6d4e6d516d546d586c5c6c5f6c626c656c686b6b6b6e6b716c736d756f777079727b747c767d~72b575b5~8e6f8e6c~b859b85a~8e6c8e698e668e638e60~8e618e5e8e5b8e578f549051924f944d964c984a9b4a9d49a049a248a548a848ab49ad4aaf4cb14eb350b552b654b756b858b85a~6a996b9b6b9e6ba16ba46ba76baa~75b578b57bb57eb5~7db580b5~7fb584b587b58ab5~999098929796969a959f94a193a593a892ab91ad~6a9969976895679365926391619261956198609a5e9b5b9b589b569a54995298529552926192~909190949097~8a918a948a97~849184948497~7e917e947e93~7e947e977e96~789178947897~7291729472977296~72b56fb5~6baa6bad6bb06bb36bb56eb56fb5~91ad91b091b3~8ab58db590b591b591b2~767d787c7a7b7c797e78807783768575877489738c728e718e6e~529250914f8f4d8d4c8b4a8a4988488648834882,499e,9f8cab85b279b269808a,76af145,135|136|137|138|139|140|141|142|143"}
 
 transitionvalue=0
 targetstate=nil
 bonustimer=0
 
 thumbsize=22
 thumbsample={1,3,5,1,1}

 levelsunlocked=1
 if dget(0) then
 	levelsunlocked=dget(0)
 end
 
//	poke(0x5f2d, 1)
	
	if state=="title" then
		titletimer=0
		setupsnow()
	elseif state=="game" or state=="edit" then
		setup()
	end
end

function createlists()
	lines={}
	fills={}
	pickups={}
	doors={}
	goals={}
	spots={}
	buckets={}
	for x=0,15 do
		buckets[x]={}
		for y=0,15 do
			buckets[x][y]={}
		end
	end
end

function setup()
	
	createlists()
	if currentmap!=0 then
		loadmap(maps[currentmap])
	end
	if state=="edit" then
		drawstate="lines"
		menuitem(1,"line mode",setlinestate)
		menuitem(2,"fill mode",setfillstate)
		menuitem(3,"snow mode",setsnowstate)
		menuitem(4,"start/goal",setstartstate)
		menuitem(5,"door",setdoorstate)
	elseif state=="game" then
		menuitem(1)
		victory=false
		strokes=0
		if currentmap!=previousmap then
			rendermap()
			previousmap=currentmap
		end
		setupsnow()
		makeball(spawnx,spawny,1)
		finddoors()
		findgoals()
		resettimer=0
		resettimer2=0
		resetfilled=false
		resetready=false
			
		aimangle=.25
	end
	clickdown=false
	clickup=false
	click=false
	oldclick=false
end

function setuplevelselect()
	menuitem(1,"reset progress",resetprogress)
	reload()
	cls()
	memcpy(0,8192*3,8192)
	previousmap=nil
	if dget(#maps)==0 then
		currentmap=levelsunlocked
	end
	for i=1,#maps do
		makethumbnail(maps[i],i-1)
	end
	setupsnow()
end

function _update()
	updatetransition()
	updatemouse()
	
	if state=="title" then
		updatetitle()
	elseif state=="levels" then
		updatelevelselect()
	elseif state=="edit" then
		updateeditor()
	elseif state=="game" then
		if victory then
			updatevictory()
		end
		updatespots()
		updatesnow()
		updateball()
		updatereset()
	elseif state=="bonus" then
		updatebonus()
	end
end

function _draw()
	cls(1)
	if state=="title" then
		drawtitle()
	elseif state=="levels" then
		drawlevelselect()
	elseif state=="edit" then
		drawpickups()
		drawspawn()
		draweditor()
	elseif state=="game" then
		drawpickups()
		drawspots()
		drawball()
		drawdoors()
		drawsnow()
		spr(0,0,0,16,16)
		drawgoals()
		drawreset()
		if victory then
			drawvictory()
		elseif ball.stuck then
			drawaim()
		end
	elseif state=="bonus" then
		drawbonus()
	end
	
	drawtransition()
end

function updatetransition()
	if targetstate then
		transitionvalue+=1/30
		if transitionvalue>1 then
 		transitionvalue=1
 		state=targetstate
 		targetstate=nil
 		if state=="game" or state=="edit" then
 			setup()
 		elseif state=="levels" then
 			setuplevelselect()
 		end
 	end
	else
		transitionvalue-=1/30
		if transitionvalue<0 then
			transitionvalue=0
		end
	end
end

function gotostate(newstate)
	if not targetstate then
		targetstate=newstate
	end
end

function resetprogress()
	for i=0,#maps do
		dset(i,nil)
	end
	_init()
end

function loadmap(str)
	local j
	local i=1
	local x,y,x1,y1,x2,y2
	while i<=#str do
		local char=sub(str,i,i)
		if char=="," then
			j=i+1
			break
		elseif char=="~" then
  	i+=1
  	x1=("0x"..sub(str,i,i+1))-64
  	y1=("0x"..sub(str,i+2,i+3))-64
  	i+=4
  else
  	x1=lines[#lines][3]
  	y1=lines[#lines][4]
  end
		x2=("0x"..sub(str,i,i+1))-64
		y2=("0x"..sub(str,i+2,i+3))-64
		addline(x1,y1,x2,y2)
		i+=4
	end
	
	for i=j,#str,4 do
		if sub(str,i,i)=="," then
			j=i+1
			break
		end
		x=("0x"..sub(str,i,i+1))-64
		y=("0x"..sub(str,i+2,i+3))-64
		add(fills,{x,y})
	end
	
	for i=j,#str,4 do
		if sub(str,i,i)=="," then
			j=i+1
			break
		end
		x=("0x"..sub(str,i,i+1))-64
		y=("0x"..sub(str,i+2,i+3))-64
		add(pickups,{x,y})
	end
	
	spawnx=("0x"..sub(str,j,j+1))-64
	spawny=("0x"..sub(str,j+2,j+3))-64

	j+=4
	local num=""
	for i=j,#str do
		local char=sub(str,i,i)
		if char=="|" or char=="," then
			if #num>0 then
				lines[num+0].door=true
				num=""
			end
		end
		if char=="," then
			j=i+1
			break
		end
		if char!="|" and char!="," then
			num=num..char
		end
		if i==#str and #num>0 then
			lines[num+0].door=true
		end
	end
	
	num=""
	for i=j,#str do
		local char=sub(str,i,i)
		if char=="|" or char=="," then
			if #num>0 then
				lines[num+0].goal=true
				num=""
			end
		end
		if char=="," then
			j=i+1
			break
		end
		if char!="|" and char!="," then
			num=num..char
		end
		if i==#str and #num>0 then
			lines[num+0].goal=true
		end
	end
end

function setupsnow()
	snows={}
	for i=0,200 do
		updatesnow()
	end
end

function makethumbnail(mapdata,index)
	supersample=thumbsample[index+1]
	local size=thumbsize*supersample
	local scale=size/128
	createlists()
	loadmap(mapdata)
	rectfill(0,0,size,size,1)
	for i,l in pairs(lines) do
		local col=7
		if l.goal then
			col=8
		elseif l.door then
			col=13
		end
		line(l[1]*scale,
		     l[2]*scale,
		     l[3]*scale,
		     l[4]*scale,
		     col)
	end
	for i,fill in pairs(fills) do
		floodfill(fill[1]*scale,fill[2]*scale,6)
	end
	for i,snow in pairs(pickups) do
		pset(snow[1]*scale,snow[2]*scale,11)
	end
	
	for x=0,size do
		for y=0,size do
			local x1=x/supersample+index*thumbsize
			local y1=y/supersample
			local old=sget(x1,y1)
			local new=pget(x,y)
			if old==8 then
				new=0
			end
			if new>min(old,1) then
				sset(x1,y1,new)
			end
		end
	end
end

function finddoors()
	local output={}
	for i,l in pairs(lines) do
		if l.door then
			add(doors,l)
			add(output,i)
		end
	end
	return output
end
function findgoals()
	local output={}
	for i,l in pairs(lines) do
		if l.goal then
			add(goals,l)
			add(output,i)
		end
	end
	return output
end

function makeball(x,y,rad)
	ball={}
	ball.x=x
	ball.y=y
	ball.vx=0
	ball.vy=0
	ball.rad=rad
	ball.stuck=false
	ball.lastx=flr(x)
	ball.lasty=flr(y)
	ball.stilltimer=0
end

function makespots(x,y,speed,count,range,vx,vy)
	for i=1,count do
		local a=rnd()
		local r=rnd()
		local x1=x+cos(a)*range*r
		local y1=y+sin(a)*range*r
		makespot(x1,y1,speed,vx,vy)
	end
end

function makespot(x,y,speed,vx,vy)
	local spot={}
	spot.x=x
	spot.y=y
	spot.ox=x
	spot.oy=y
	spot.vx=(rnd(2)-1+vx)*speed
	spot.vy=(rnd(2)-1+vy)*speed
	spot.scol=rnd(3)
	spot.life=1
	spot.decay=1/30/(rnd()+1)
	add(spots,spot)
end

function makesnow()
	local snow
	snow={rnd(128),
	      0,
	      rnd(),
	      .3+rnd(.3),
	      .5+rnd(.5),
	      rnd()<.7}
	add(snows,snow)
end

function updatemouse()
	mousex=stat(32)
	mousey=stat(33)
	
	clickdown=false
	clickup=false
	click=band(stat(34),1)>0
	rclick=band(stat(34),2)>0
	mclick=stat(34)>=4
	if click and not oldclick then
		clickdown=true
	end
	if not click and oldclick then
		clickup=true
	end
	oldclick=click
end

function setlinestate()
	drawstate="lines"
end
function setfillstate()
	drawstate="fills"
end
function setsnowstate()
	drawstate="snow"
end
function setstartstate()
	drawstate="start"
end
function setdoorstate()
	drawstate="door"
end

function updatevictory()
	victimer+=1/30
	if victimer>.6 and btnp()>0 then
		if not targetstate then
 		gotostate("levels")
		end
	end
end

function updatetitle()
	titletimer+=1/60
	updatesnow()
	
	if titletimer>.2 then
		if btnp(4) then
			sfx(7)
			if levelsunlocked>1 then
				gotostate("levels")
			else
				currentmap=1
				gotostate("game")
			end
		end
	end
end

function updatelevelselect()
	updatesnow()
	
	bonusready=true
	for i=1,#maps do
		if dget(i)!=1 then
			bonusready=false
			break
		end
	end
	
	if bonusready then
		if btn(5) then
			bonustimer+=1/30
		elseif bonustimer<1 then
			bonustimer-=1/30
		end
		bonustimer=mid(bonustimer,0,1)
		if bonustimer==1 then
			state="bonus"
			setupbonus()
		end
	else
		bonustimer=0
	end
	
	if not targetstate then
 	if btnp(0) then
 		currentmap-=1
 		sfx(2+rnd(2))
 		if currentmap==0 then
 			currentmap=levelsunlocked
 		end
 	end
 	if btnp(1) then
 		currentmap+=1
 		sfx(2+rnd(2))
 		if currentmap>levelsunlocked then
 			currentmap=1
 		end
 	end
 	if btnp(4) then
 		gotostate("game")
 		sfx(5)
 	end
 end
end

function updateeditor()
	if drawstate=="lines" then
		if clickdown then
 		lastdrawx=mousex
 		lastdrawy=mousey
 	end
 	if click or clickup then
 		local dx=mousex-lastdrawx
 		local dy=mousey-lastdrawy
 		if (click and dx*dx+dy*dy>2*2) or (clickup and (dx!=0 or dy!=0)) then
 			addline(lastdrawx,lastdrawy,mousex,mousey)
 			lastdrawx=mousex
 			lastdrawy=mousey
 		end
 	end
 	
 	if rclick then
 		deletelines(mousex,mousey)
 	end
 elseif drawstate=="fills" then
 	if clickdown then
 		add(fills,{mousex,mousey})
 	end
 	if rclick then
 		deletefills(mousex,mousey)
 	end
 elseif drawstate=="snow" then
 	if clickdown then
 		add(pickups,{mousex,mousey})
 	end
 	if rclick then
 		deletepickups(mousex,mousey)
 	end
 elseif drawstate=="start" then
 	if click then
 		spawnx=mousex
 		spawny=mousey
 	end
 	if rclick then
 		markgoal(mousex,mousey,true)
 	end
 	if mclick then
 		markgoal(mousex,mousey,false)
 	end
 elseif drawstate=="door" then
 	if clickdown then
 		lastdrawx=mousex
 		lastdrawy=mousey
 	end
 	if clickup then
 		if mousex!=lastdrawx or mousey!=lastdrawy then
 			addline(lastdrawx,lastdrawy,mousex,mousey)
 			lines[#lines].door=true
 		end
 	end
 	if rclick then
 		deletelines(mousex,mousey,true)
 	end
 end
	
	if btnp(4) then
		outputmap()
	end
end

function updatereset()
	if btn(5) or resettimer==1 then
		if resetready then
			resettimer+=1/40
			resettimer2+=1/30
			if resettimer>1 then
				gotostate("game")
			end
		end
	else
		if (resetfilled and resettimer==0) or resettimer2==0 then
			resettimer2-=1/30
		else
			resettimer2+=1/30
		end
		resettimer-=1/30
		resetready=true
	end
	resettimer=mid(resettimer,0,1)
	resettimer2=mid(resettimer2,0,1)
	if resettimer2==1 then
		resetfilled=true
	end
	if resettimer2==0 then
		resetfilled=false
	end
end

function updateball()
	if victory then
		return
	end
	
	if ball.stuck then
		local step=.005
		if btn(0) then
			aimangle+=step
		end
		if btn(1) then
			aimangle-=step
		end
		aimangle=mid(aimangle,0,.5)
		
		if btn(4) then
			if not shooting then
				shooting=true
				shottimer=0
  	end
  	shottimer+=1/90
  	shotpower=1-abs(cos(shottimer))
  else
  	if shooting then
  		shooting=false
  		
  		ball.vx=cos(aimangle)*6*shotpower
   	ball.vy=sin(aimangle)*6*shotpower
   	sfx(1)
   	ball.stuck=false
   	strokes+=1
   	makespots(ball.x,ball.y+ball.rad,shotpower*2,shotpower*50,shotpower*2,0,-1)
  	end
  end
	else
		ball.vy+=.1
		moveball(ball.vx,ball.vy)
		
		local moved=true
		if flr(ball.x)==ball.lastx then
			if flr(ball.y)==ball.lasty then
				moved=false
			end
		end
		
		if not moved then
			ball.stilltimer+=1
			if ball.stilltimer>12 then
				ball.stuck=true
			end
		else
			ball.lastx=flr(ball.x)
			ball.lasty=flr(ball.y)
			ball.stilltimer=0
		end
		
		checkpickups()
	end
end

function moveball(vx,vy)
	local dist=sqrt(vx*vx+vy*vy)
	if (dist==0) return
	
	local dirx=vx/dist
	local diry=vy/dist
	local lastsafex=ball.x
	local lastsafey=ball.y
	local lastsafet=0
	
	for step=1,-flr(-dist) do
		local t=min(step,dist)
		local x=ball.x+dirx*t
		local y=ball.y+diry*t
		
		local hit,nx,ny,cx,cy=circvsmap(x,y,ball.rad,vx,vy)
		if hit then
			local proj=dot(ball.vx,ball.vy,nx,ny)
			local count=min(-proj*2*ball.rad,16)
			makespots(cx,cy,dist*.5,count,1,nx,ny)
			
			if proj<-3 then
				sfx(4)
			elseif proj<-1 then
				sfx(2+rnd(2))
			end
			
			ball.vx-=nx*proj*1.4
			ball.vy-=ny*proj*1.4
			ball.vx*=.985
			ball.vy*=.985
			ball.x=lastsafex
			ball.y=lastsafey
			local extradist=dist-lastsafet
			dist=sqrt(ball.vx*ball.vx+ball.vy*ball.vy)
			if extradist>0 and dist>.5 and not victory then
				moveball(ball.vx/dist*extradist,
				         ball.vy/dist*extradist)
			end
			if dist<.5 and ny<-.707 then
				ball.stuck=true
			end
			return
		else
			lastsafex=x
			lastsafey=y
			lastsafet=t
		end
	end
	ball.x+=vx
	ball.y+=vy
end

function circvsmap(x,y,rad,vx,vy)
	local mindist=32000
	local bnx,bny
	local bcx,bcy
	
	local minx=x-rad
	local maxx=x+rad
	local miny=y-rad
	local maxy=y+rad
	minx=flr(minx/8)
	maxx=flr(maxx/8)
	miny=flr(miny/8)
	maxy=flr(maxy/8)
	
	for bx=minx,maxx do
		for by=miny,maxy do
			if bx>=0 and by>=0 and bx<16 and by<16 then
   	for i,l in pairs(buckets[bx][by]) do
   		local lx=(l[3]-l[1])/l[5]
   		local ly=(l[4]-l[2])/l[5]
   		local nx=-ly
   		local ny=lx
   		local cx,cy
   		if dot(x-l[1],y-l[2],lx,ly)<0 then
   			cx=l[1]
   			cy=l[2]
   			nx=x-l[1]
   			ny=y-l[2]
   		elseif dot(x-l[3],y-l[4],lx,ly)>0 then
   			cx=l[3]
   			cy=l[4]
   			nx=x-l[3]
   			ny=y-l[4]
   		else
   			local dx=x-l[1]
   			local dy=y-l[2]
   			local proj=dot(dx,dy,lx,ly)
   			cx=l[1]+lx*proj
   			cy=l[2]+ly*proj
   		end
   		
   		local dx=x-cx
   		local dy=y-cy
   		local sqrdist=dx*dx+dy*dy
   		if sqrdist<rad*rad then
   			if dot(nx,ny,dx,dy)<0 then
   				nx=-nx
   				ny=-ny
   			end
   			if dot(nx,ny,vx,vy)<0 then
   				if l.goal then
   					ball.stuck=true
   					victory=true
   					sfx(6)
   					local oldbest=dget(currentmap)
   					if oldbest==0 or strokes<oldbest then
   						dset(currentmap,strokes)
   					end
   					if currentmap+1>levelsunlocked then
   						levelsunlocked=min(currentmap+1,#maps)
   						dset(0,levelsunlocked)
   					end
   					victimer=0
   					makespots(ball.x,ball.y,3,50,ball.rad,0,-1)
   				end
    			if sqrdist<mindist then
    				mindist=sqrdist
    				bnx=nx
    				bny=ny
    				bcx=cx
    				bcy=cy
    			end
    		end
   		end
   	end
   end
  end
 end
	
	if mindist==32000 then
		return false
	else
		local dist=sqrt(bnx*bnx+bny*bny)
		if (dist>0)bnx,bny=bnx/dist,bny/dist
		return true,bnx,bny,bcx,bcy
	end
end

function checkpickups()
	local dist=ball.rad+7
	for i,snow in pairs(pickups) do
		local dx=snow[1]-ball.x
		local dy=snow[2]-ball.y
		if abs(dx)<128 and abs(dy)<128 then
 		if dx*dx+dy*dy<dist*dist then
 			if #pickups==1 then
 				sfx(7)
 			else
	 			sfx(5)
 			end
 			makespots(snow[1],snow[2],2,30,5,0,0)
 			del(pickups,snow)
 			growball()
 			if #pickups==0 then
 				for j,door in pairs(doors) do
 					del(lines,door)
 					del(doors,door)
 					editbuckets(door,true)
 					for k=0,20 do
 						local t=rnd()
 						makespot(door[1]*t+door[3]*(1-t),door[2]*t+door[4]*(1-t),3,0,-1)
 					end
 				end
 			end
 		end
 	end
	end
end

function growball()
	ball.rad+=1
	local hit,nx,ny
	repeat
		hit,nx,ny=circvsmap(ball.x,ball.y,ball.rad,0,0)
		if hit then
			ball.x+=nx
			ball.y+=ny
		end
	until hit==false
end

function updatespots()
	for i,spot in pairs(spots) do
		spot.ox=spot.x
		spot.oy=spot.y
		spot.x+=spot.vx
		spot.y+=spot.vy
		spot.vx*=.9
		spot.vy*=.9
		spot.vy+=.025
		spot.vx+=rnd(.5)-.25
		spot.life-=spot.decay
		spot.col=5+spot.scol*sqrt(spot.life)
		if spot.life<0 then
			del(spots,spot)
		end
	end
end

function updatesnow()
	a=time()/2
	for i=1,2 do
		makesnow()
	end
	for i,snow in pairs(snows) do
		snow[1]+=sin(a*snow[5]+snow[3])*.5
		snow[2]+=snow[4]
		if state=="game" and snow[6] and sget(snow[1],snow[2])!=0 then
			sset(snow[1],snow[2],6+snow[3]*2)
			del(snows,snow)
		end
		if snow[2]>127 then
			del(snows,snow)
		end
	end
end

function addline(x1,y1,x2,y2)
	local dx=x2-x1
	local dy=y2-y1
	local d=sqrt(dx*dx+dy*dy)
	local l={x1,y1,x2,y2,d}
	add(lines,l)
	if state=="game" then
		editbuckets(l,false)
	end
end

function editbuckets(l,delete)
	local minx=min(l[1],l[3])
	local maxx=max(l[1],l[3])
	local miny=min(l[2],l[4])
	local maxy=max(l[2],l[4])
	
	minx=flr(minx/8)
	maxx=flr(maxx/8)
	miny=flr(miny/8)
	maxy=flr(maxy/8)
	
	for x=minx,maxx do
		for y=miny,maxy do
			if x>=0 and x<16 then
				if y>=0 and y<16 then
					if delete then
						del(buckets[x][y],l)
					else
						add(buckets[x][y],l)
					end
				end
			end
		end
	end
end

function deletepickups(x,y)
	for i,snow in pairs(pickups) do
		local dx=x-snow[1]
		local dy=y-snow[2]
		if dx*dx+dy*dy<5*5 then
			del(pickups,snow)
		end
	end
end

function deletefills(x,y)
	for i,fill in pairs(fills) do
		local dx=x-fill[1]
		local dy=y-fill[2]
		if dx*dx+dy*dy<5*5 then
			del(fills,fill)
		end
	end
end

function deletelines(x,y,onlydoors)
	local matches=clicklines(x,y)
	for i,l in pairs(matches) do
		if onlydoors then
			if l.door then
				del(lines,l)
			end
		else
			if not l.door then
				del(lines,l)
			end
		end
	end
end

function markgoal(x,y,value)
	local matches=clicklines(x,y)
	for i,l in pairs(matches) do
		if not l.door then
			l.goal=value
		end
	end
end

function clicklines(x,y)
	local output={}
	for i,l in pairs(lines) do
		local match=false
		for j=0,1,.5/l[5] do
 		local dx=l[1]*j+l[3]*(1-j)-x
 		local dy=l[2]*j+l[4]*(1-j)-y
 		if dx*dx+dy*dy<2*2 then
 			match=true
 			break
 		end
		end
		if match then
			add(output,l)
		end
	end
	return output
end

function outputmap()
	local out=""
	local doorindices=finddoors()
	local goalindices=findgoals()
	
	for i,l in pairs(lines) do
		local start=1
		if i>1 and lines[i-1][3]==l[1] and lines[i-1][4]==l[2] then
			start=3
		else
			out=out.."~"
		end
		for j=start,4 do
			out=out..numtostr(l[j])
		end
	end
	
	out=out..","
	for i,fill in pairs(fills) do
		for j=1,2 do
			out=out..numtostr(fill[j])
		end
	end
	
	out=out..","
	for i,snow in pairs(pickups) do
		for j=1,2 do
			out=out..numtostr(snow[j])
		end
	end
	
	out=out..","
	if spawnx then
		out=out..numtostr(spawnx)
		out=out..numtostr(spawny)
	else
		out=out.."0000"
	end
	
	for i,index in pairs(doorindices) do
		out=out..index
		if i<#doorindices then
			out=out.."|"
		end
	end
	out=out..","
	for i,index in pairs(goalindices) do
		out=out..index
		if i<#goalindices then
			out=out.."|"
		end
	end
	
	
	printh(out,"@clip")
	cls(7)
	flip()
	flip()
end

function numtostr(n)
	local hex=tostr(n+64,true)
	return sub(hex,5,6)
end

function draweditor()
	drawlines(true)
	if drawstate=="door" then
		if (click) then
			line(lastdrawx,lastdrawy,mousex,mousey,9)
		end
	end
	previewfills()
	circ(mousex,mousey,1,7)
end

function drawspawn()
	if spawnx then
		circfill(spawnx,spawny,2,6+t()*2%2)
	end
end

function drawtitle()
 drawsnow()
 
	local timer=mid(titletimer,0,1)
	local width=26
	local y=17
	uiframe(64-width,y,62+width,y+24,timer)
	spr(0,43,y+3,5,3)

	local texts={"a chilly lil thing",
	             "by eli piilonen",
	             "with music by gruber"}
	y=58
	for i=1,3 do
 	timer=mid((titletimer-.3*i),0,1)
 	text=texts[i]
 	width=#text*2+3
 	uiframe(64-width,y+12*i,63+width,y+10+12*i,timer)
 	sprint(text,64-#text*2,y+3+12*i,6,5)
 end
 
 timer=mid(titletimer-1,0,1)
 width=28
 y=110
 uiframe(64-width,y,62+width,y+10,timer)
 text="press Ž (z) "
 sprint(text,64-#text*2,y+3,14,2)
 
 clip()
 
 if titletimer<.5 then
 	local t=titletimer/.5
 	t=3*t*t-2*t*t*t
 	rectfill(0,127,127,127*t,0)
 end
end

function drawlevelselect()
	drawsnow()
	
	local str="select a level"
	uiframe(61-#str*2,17,66+#str*2,27,1)
	sprint(str,64-#str*2,20,6,5)
	clip()
	
	uiframe(0,76,128,88,1)
	clip()
	
	local x1=64-#maps*thumbsize/2
	x1-=(#maps-1)*3/2
	
	for i=1,#maps do
		
		if currentmap!=i then
			if i>levelsunlocked then
				pal(7,5)
				pal(6,0)
				pal(8,2)
				pal(11,1)
				pal(1,0)
				pal(12,0)
				pal(13,1)
			else
 			pal(7,13)
 			pal(6,5)
 			pal(8,4)
 			pal(11,3)
 			pal(1,0)
 			pal(12,13)
				pal(13,1)
 		end
		end
	
		local x=x1+(i-1)*(thumbsize+3)
		local y=64-thumbsize*.5
		sspr(thumbsize*(i-1),0,thumbsize,thumbsize,
		     x,y)
		rect(x-1,y-1,x+thumbsize,y+thumbsize,12)
		pal()
		if i>levelsunlocked then
			fillp(0b1100100100110110.1)
			rectfill(x,y,x+thumbsize-1,y+thumbsize-1,2)
			fillp()
		end
		if dget(i)==1 then
			drawribbon(x+thumbsize*.5,y+thumbsize+7)
		else
			local num=dget(i)
			if num>0 then
				num=num..""
				sprint(num,x+thumbsize*.5-#num*2+1,y+thumbsize+5,13,2)
			end
		end
	end
	
	if dget(#maps)>0 then
		local col1,col2
		if bonusready then
			lines={"thanks for playing!",
			       "hold — for your prize "}
			col1=11
			col2=3
		else
			lines={"next: find all five",
		 	      "hole-in-one shots!"}
		 col1=15
		 col2=4
		end
		
		local width=47
		uiframe(64-width,103,63+width,122,1)
		clip()
		for i=1,#lines do
			str=lines[i]
			sprint(str,64-#str*2,100+7*i,col1,col2)
		end
	end
	
	if bonustimer>0 then
		local t=bonustimer
		t=3*t*t-2*t*t*t
		circfill(64,64,t*91,0)
		circ(64,64,t*91,5)
	end
end

rcols={10,8,8,8,9}
function drawribbon(x,y)
	local u,v
	for j=0,4 do
		for i=0,1,.05 do
			local x1=x-15+30*i
			local y1=y+3+j
			y1+=sin(x1/9+t())+sin(x1/13.9+t()*.937)
			x1+=sin(x1/13+t()*.618)*2
			if i>0 then
				line(x1,y1,u,v,rcols[j+1])
			end
			u,v=x1,y1
		end
	end
	
	circfill(x,y,4,10)
	circ(x,y,4,9)
	print("1",x-1,y-2,4)
	
	pal(10,7)
	pal(9,15)
	pal(4,9)
	
	for x1=x-4,x+4 do
		for y1=y-4,y+4 do
			if (x1+y1-t()*9)/8%1<.5 then
				pset(x1,y1,pget(x1,y1))
			end
		end
	end
	
	pal()
end

function drawpickups()
	srand(6)
	for i,snow in pairs(pickups) do
		local a=time()+rnd()
		local spinx=sin(a)
		local spiny=cos(a)
		local x=snow[1]
		local y=snow[2]
		for k=1,4 do
			local x1=rnd(7)-3.5
			local y1=rnd(7)-3.5
			local x2=rnd(7)-3.5
			local y2=rnd(7)-3.5
			
			for j=0,5/6,1/6 do
				local c=cos(j)
				local s=sin(j)
				local x3,y3=c*x1-s*y1,s*x1+c*y1
				local x4,y4=c*x2-s*y2,s*x2+c*y2
				y3+=spiny*x3*.4
				y4+=spiny*x4*.4
			
				line(x+x3*spinx,y+y3,x+x4*spinx,y+y4,6+k%2)
			end
		end
	end
	srand(time())
end

function drawball()
	local col=8
	if ball.stuck then
		col=9
	end
	
	circfill(ball.x+.5,ball.y+.5,1,7)
	local fullcir=2*3.14159*ball.rad
	for i=ball.rad,.5,-.5 do
		local cir=2.1*3.14159*i
		for j=1,max(cir,1) do
			local a=j/cir-ball.x/(fullcir)
			local s=1
			local r=i
			local x=cos(a)*r
			local y=sin(a)*r
			local nx=x/ball.rad
			local ny=y/ball.rad
			local nz=sqrt(1-x*x+y*y)
			local dot=(nx-ny)
			local c=6.3+(j*.25%2)+dot
			c=mid(c,5,7)
			if c>5 and c<6 then
				c=13
			end
			if i==ball.rad then
				c=13
			end
			
			local u=(i+j)/16%1
			local v=(i+j*2)/16%1
			
			circfill(ball.x+u+x,ball.y+v+y,s,c)
		end
	end
end

function drawaim()
	local c=cos(aimangle)
	local s=sin(aimangle)
	if shooting then
		for i=-1,1,.5 do
 		local x1=ball.x-s*i+c*(ball.rad+2)
 		local y1=ball.y+c*i+s*(ball.rad+2)
 		local x2=ball.x-s*i+c*(ball.rad+2+12*shotpower)
 		local y2=ball.y+c*i+s*(ball.rad+2+12*shotpower)
 		line(x1+.5,y1+.5,x2+.5,y2+.5,9.1+shotpower)
 	end
	end
	
	local col=8
	for i=ball.rad+2,ball.rad+14 do
		local x=ball.x+c*i
		local y=ball.y+s*i
		pset(x+.5,y+.5,col)
		if i>ball.rad+13 then
			pset(x+.5-c*2+s,y+.5-s*2-c,col)
			pset(x+.5-c*2-s,y+.5-s*2+c,col)
		end
	end
end

function drawspots()
	for i,spot in pairs(spots) do
		if spot.life>.8 and spot.scol>2 then
			circ(spot.x,spot.y,1,spot.col)
		end
		line(spot.x,spot.y,spot.ox,spot.oy,spot.col)
	end
end

function drawsnow()
	for i,snow in pairs(snows) do
		pset(snow[1],snow[2],5+snow[3]*3)
	end
end

function drawlines(showdoors)
	for i,l in pairs(lines) do
		if showdoors or not l.door then
			local c=6
			if (l.door) c=8
			if (l.goal) c=12
			line(l[1],l[2],l[3],l[4],c)
		end
	end
end

function drawdoors()
	for i,l in pairs(doors) do
		line(l[1],l[2],l[3],l[4],6)
		line(l[1],l[2]+1,l[3],l[4]+1,13)
	end
end
function drawgoals()
	for i,l in pairs(goals) do
		for j=0,1 do
 		local c=14
  	if #pickups==0 then
  		if (-t()*2+(l[1]+l[3])/16+j/3)%1<.5 then
  			c=8
  		end
  	end
  	if victory then
  		c+=1
  	end
 		line(l[1],l[2]+j,l[3],l[4]+j,c)
		end
	end
end

function drawreset()
	local col=8
	if not btn(5) then
		col=4
	end
	if targetstate=="game" then
		col=8+t()*30%2
	end
	if resettimer2>0 then
 	local timer=resettimer2
 	local width=37
 	uiframe(64-width,58,64+width,86,timer)
		local text="hold — to reset" 
		sprint(text,64-#text*2,62,8,2)
		circfill(64,78,7,2)
		circ(64,78,7,col)
	end
	
	if resettimer>0 then
 	for i=0,resettimer,1/60 do
 		local a=.25-i
 		line(64,78,64.5+cos(a)*6,78.5+sin(a)*6,col)
 	end
 end
	clip()
end

function drawvictory()
	local w=30
	local h=10
	local timer=min(victimer*2,1)
	uiframe(63-w,46-h,63+w,46+h,timer)

	local str="you got it!"
	sprint(str,64-#str*2,40,14,2)
	str="(in "..strokes.." shots)"
	if strokes==1 then
		str="hole in one!"
	end
	sprint(str,64-#str*2,48,11,3)
	
	clip()
end

darken={0,1,2,2,1,5,13,4,2,4,3,13,1,2,4}
function uiframe(x1,y1,x2,y2,t)
	t=3*t*t-2*t*t*t
	local width=t*(x2-x1)
	local midx=(x1+x2)*.5
	clip(midx-width*.5,0,width,128)

	for i=1,15 do
		pal(i,darken[i])
	end
	
	for x=x1,x2 do
		for y=y1,y2 do
			pset(x,y,pget(x,y))
		end
	end
	pal()
end

function previewfills()
	for i,fill in pairs(fills) do
		circ(fill[1],fill[2],1+t()%2,5)
	end
end

function rendermap()
	cls()
	drawlines()
	drawfills()
	drawrocks()
	memcpy(0,8192*3,8192)
end

function drawfills()
	for i,fill in pairs(fills) do
		floodfill(fill[1],fill[2],6)
	end
end

function floodfill(x,y,col,reqcol)
	local maxpos=127
	if state=="levels" then
		maxpos=thumbsize*supersample
	end
	if (x<0 or y<0 or x>maxpos or y>maxpos) then
		return
	end
	local oldcol=pget(x,y)
	if reqcol==nil or oldcol==reqcol then
		pset(x,y,col)
		floodfill(x+1,y,col,oldcol)
		floodfill(x-1,y,col,oldcol)
		floodfill(x,y+1,col,oldcol)
		floodfill(x,y-1,col,oldcol)
	end
end

function drawrocks()
	local range=7
	for x=0,127 do
		for y=0,127 do
			if pget(x,y)!=0 then
 			local dist=range
 			for i=0,1 do
 				for u=-range,range do
 					if u==0 and i==0 then
 						break
 					end
 					if u!=0 then
  					local x1=x+u*i
  					local y1=y+u*(1-i)
  					if x1>=0 and y1>=0 and x1<=127 and y1<=127 then
   					if pget(x1,y1)==0 then
   						if abs(u)<dist then
   							dist=abs(u)
   						end
   					end
   				end
 					end
 				end
 			end
				if softnoise(x,y,4)>.5 then
					pset(x,y,5)
				end
 			dist/=range
 			if dist-(x+y)%2*.2<rnd() then
 				pset(x,y,7)
 			end
 		end
		end
	end
end

function drawtransition()
	if transitionvalue>0 then
		local a=transitionvalue
		a=3*a*a-2*a*a*a
		for x=0,7 do
			for y=0,7 do
				local dx=x-3.5
				local dy=y-3.5
				local d=sqrt(dx*dx+dy*dy)
				local t=mid(a*6-d,0,1)
				t=3*t*t-2*t*t*t
				if t>0 then
					for i=0,1 do
 					local col=5+(x+y+i)%3
 					local func=rectfill
 					if i==1 then
 						func=rect
 					end
 					func(x*16+8-t*8,y*16+8-t*8,
 					     x*16+7+t*8,y*16+7+t*8,
 					     col)
 				end
				end
			end
		end
	end
end

function softnoise(x,y,scale)
	x/=scale
	y/=scale
	local x1=flr(x)
	local y1=flr(y)
	local x2=x1+1
	local y2=y1+1
	local a=noise(x1,y1)
	local b=noise(x2,y1)
	local c=noise(x1,y2)
	local d=noise(x2,y2)
	local u=x-x1
	local v=y-y1
	return lerp(lerp(a,b,u),
	            lerp(c,d,u),
	            v)
end

function noise(x,y)
	return sin(x*302.513+y*512.719)*417.131%1
end

function lerp(a,b,t)
	return a*(1-t)+b*t
end

function dot(x1,y1,x2,y2)
	return x1*x2+y1*y2
end

function oprint(str,x,y,col1,col2)
	print(str,x+1,y,col2)
	print(str,x-1,y,col2)
	print(str,x,y+1,col2)
	print(str,x,y-1,col2)
	print(str,x,y,col1)
end

function sprint(str,x,y,col1,col2)
	print(str,x,y+1,col2)
	print(str,x,y,col1)
end

function setupbonus()
	globetimer=0
	snows={}
	for i=0,320 do
		local snow={}
		snow.x=rnd(2)-1
		snow.y=rnd(2)-1
		snow.z=rnd(2)-1
		snow.vx=rnd(.2)-.1
		snow.vy=rnd(.2)-.1
		snow.vz=rnd(.2)-.1
		add(snows,snow)
	end
end

function updatebonus()
	globeshake=false
	globetimer+=1/60
	
	if globetimer<1 then
		local t=1-globetimer
		t=3*t*t-2*t*t*t
		camera(0,130*t)
	else
 	if btn(5) and not targetstate then
 		globeshake=true
 		camera(sin(t()*6)+.5,0)
 	else
 		camera(0,0)
 	end
 end
	
	for i,snow in pairs(snows) do
		if globeshake then
			snow.vx+=rnd(.3)-.15
			snow.vy+=rnd(.3)-.15
			snow.vz+=rnd(.3)-.15
		end
		snow.vy-=.0005
		snow.x+=snow.vx
		snow.y+=snow.vy
		snow.z+=snow.vz
		snow.vx*=.9
		snow.vy*=.9
		snow.vz*=.9
		local dist=sqrt(snow.x*snow.x+snow.y*snow.y+snow.z*snow.z)
		if dist>1 then
			snow.x/=dist
			snow.y/=dist
			snow.z/=dist
			snow.vx*=.9
			snow.vy*=.9
			snow.vz*=.9
		elseif snow.y<-.6 then
			snow.y=-.6
		else
			snow.vx+=rnd(.03)-.015
			snow.vz+=rnd(.03)-.015
		end
	end

	if btnp(4) then
		gotostate("levels")
		bonustimer=0
	end
end

function drawbonus()
	cls()
	
	if globetimer==0 then
		return
	end
	
	if not globeshake then
		sprint("Ž/z quit",2,2,13,1)
		sprint("— shake",95,2,14,2)
	end
	
	local fills={0b1110110110110111.1,0b1101101101111110.1,0b1011011111101101.1,0b0111111011011011.1}
	for r=1,5 do
		fillp(fills[flr(t()*16+r)%4+1])
		circfill(64,58,sqrt(r)*22,1)
		fillp()
	end
	
	local cols={3,11,7}
	
	local spin=t()/8
	
	srand()
	for y=0,1 do
 	for i=0,300+y*100 do
 		local a=i*.618+spin
 		local r=i/400*37
 		circfill(64.5+cos(a)*r,95+sin(a)*r*.3-y*7,1,5+rnd(3))
 	end
	end
	
	for y=0,20 do
		srand(8)
 	for i=0,17 do
			local f=.3+rnd()
 		local h=rnd(10)+10
 		local a=rnd()+spin
 		local r=rnd(23)+2
 		local s=2+rnd(3)
			local x1=64+cos(a)*r
			local y1=88+sin(a)*r*.3-y
			local w=(1-y/h)*s
			local c=cols[flr(y*f%3)+1]
		
 		if y<h then
 			line(x1-w,y1-1,x1,y1,c)
 			line(x1+w,y1-1,x1,y1,c)
 		end
 	end
	end
	
	local cs=cos(spin)
	local ss=sin(spin)
	for i,snow in pairs(snows) do
		local x=snow.x*cs-snow.z*ss
		local z=snow.x*ss+snow.z*cs
		local u=64.5+x*48
		local v=58.5+z*11-snow.y*48
		if snow.u and snow.y>-.6 then
			line(u,v,snow.u,snow.v,6+rnd(2))
		end
		snow.u=u
		snow.v=v
	end
	
	srand(t())
	circ(64,58,50,6)
	circ(64,58,51,0)
	clip(0,0,50,127)
	circ(64,58,50,5)
	clip(77,0,50,127)
	circ(64,58,50,7)
	clip()
	
	for a=.54,.96,.0005 do
		local x=cos(a)*39
		local y=89+sin(a)*15
		line(64+x,y,64+x*1.1,y+20,9+(a-spin)*4%2)
	end
end
__gfx__
77000077077770770077077777707777707777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d70000d70d6670d700d70dd66d70d6dd70d6dd670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d70000d700d600d670d7000d7000d60000d700d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d70770d700d600d670d7000d7000d67700d700d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d70d70d700d600d6d7d7000d7000d6d700d667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d70d70d700d600d60d67000d7000d60000d6dd700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d70d70d700d600d60d67000d7000d60000d60d700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d6766766076670d600d7000d7000d67770d600d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dddddd00dddd0dd00d7000d7000dddd70dd00d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007777000067776000770000777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d6ddd700676767600d70000d6dd70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d700d705d67676760d70000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d700000d6d6767670d70000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d7077705d6d676760d70000d67700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d70d670d5d6d676d0d70000d6dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d700d705d5d6d6d50d70000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d777d7005d5d6d500d67770d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000ddd600005d5d5000dddd70d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010100010c170065002b701175012e5011a500176000e6000c6000860006600056000360002600016000160001600016000160001600016000160001600016000160001600016000260002600026000260002600
0101000004131045310a13110531151311653008630076300563003630026300160001600016001d6001860015600136000f60009600016000000000000000000000000000000000000000000000000000000000
010100000143502434026340263402635026000260002600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000163402535026350263402635026000260002600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000016540e5650e675026640e655026000260002600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000037410f04607741130460c7410f0461374113046167410f0461b7411304613545137000f7000770005700000000000000000000000000000000000000000000000000000000000000000000000000000
0102000011657165570b65709757026550a5001065714757066570575701757017470664508745087350873509635097250562502715016150660005600046000260001600026000460002600035000350003500
010100000f7451b046137451f046187451b0461f7451f046227450f046277451f0461f745137000f7000770005700000000000000000000000000000000000000000000000000000000000000000000000000000
010e00002461500405000000000000145000000000000000306050000000000000000014500000000000000030605000000000000000001450000000000000000000000000000000000000145000000000024605
010e0000185260c5261c5260c526185161c516185160c5160c50518505000001801500000000000c1451e7051f7041f702180151f702185051f70200000000000c1450000000000180151870018700000000c145
010e0000185260c5261c5260c526185161c516185160c5161e7040c0250000000000187051b7000c1351e7001d5261152615516115261d516155161d51611516000001802500000000001f526175261f51613516
010e00002461500405071450000000145000000714500145006050714500000000000014500000000000000000605071450000000000001450000000000071450000007145000000000000145071450000000000
010e00001c516105161f516105161c516135161c516105160c000000001002500000175260b526175160b516185260c526105260c5261851610516185160c516000000000018025000000c705000000c11500000
010e00001c526105261f526105261c516135161c51610516000000000018025000002352617526235161751624526185261c51618516245161c5162451618516000000000000000000000c115000000000000000
010e000013725287201c7251c7201a7251c735137251a7351c725137351a72528720137251c7201c725137351a72528720137251c7201c725137351a7251c735137251a7351c725287201a7251c720137251a735
010e00000c0433071013735247100c735007000c0230c033246102461513735307100c73524710137150c0330c0433071013735247100c735007000c0230c033246102461513735307100c73524710137150c033
010e0000182141321113213132101321707215080000800010211102101071310210102171021518000180000c2110c2100c7130c2100c217002150c500005000c2110c2100c7130c2100c2170c2151350007500
010e000000134001310015300130001200011500100001000c1310c130001530c1300c1200c1150c1000c10000131001300015300130001200011500100001000713107130001530713007120071150710007100
010e00000c04300000000000000024615000000c0430000000000000000c043000002461500000000000c0230c04300000000000000024615000000c0430000000000000000c0430000024615000000c0430c023
010e00002461500405071450000000145000000714500145006050714500000000000014500000000000000000605051450000000000001450000000000051450000005145000000000002145071450000007145
010e0000246150040504145000000b145000000b14504145006050b14500000000000414500000000000000000605091450000000000041450000000000091450000009145000000000004145091450000000000
010e0000246150040504145000000b145000000b14504145006050b14500000000000414500000000000000000605001450000000000071450000000000001450000007145000000000007145001450000000000
010e00000c04324730247322473524615267020c0432b7302b7322b7350c04300000246152d732287320c0230c0432f730307213071224615000000c0432673026722267150c0432b73024615287300c0430c023
010e0000246151c7201c7121c715001450c525185252872028712287120c525185250014529722247220c52518525267202871128712001450c52518525247202471224715000002872500145247250c52518525
010e000024615307201c7022d7200914509525155252d7102d7102d71209525155250914524712247120c525185252d7202d7102d712051450c525185251f7101f7121f71500000287200714528720135251f525
010e00002461528720297212971200145001450714528722287220714500145000000014526722247220000007145267202872128712001450000007145247202471224712071452971200145297120714500000
010e00000c04330730327213271224615267020c0432b7302b7222b7150c043000002461529732287320c0230c0432f730307213071224615000000c0432673026722267150c04332730246152b7300c0430c023
010e00000c04334725327003072524615267020c0433473035721357150c04300000246152d7322d7320c0230c04334730347203471224615000000c0432673026722267150c0433073024615247300c0430c023
010e0000246151c7201c7121c71509145095251552528720287122871209525155250914524712247120c525185252d7102d7102d712051450c525185251f7101f7121f71500000287200714528720137251f725
010e00000583405831058550584005830058250580005800118341183105855118401183011825118001180007834078310785507840078300782507800078001383413831078551384013830138250780007800
010e00000c04330710107352471009735007000c0230c033246102461510735307100973524710157150c0330c04330710107352471009735007000c0230c033246102461510735307100973524710157150c033
010e00000983409831098550984009830098250980009800158341583109855158401583015825158001580009834098310985509840098300982509800098001083410831098551084010830108251080010800
010e00000c043307200c7352472005735007000c0230c03324610246150c735307200573524720157150c0330c043307200e7352472007735007000c0230c03324610246150e735307200773524720177150c033
010e00000c0033071013735247100c735007000c0030c003246002460513735307100c735247101c7150c0030c0033071013735247100c735007000c0030c003246002460513735307100c735247101c7150c003
010e000024615137151a7151c715001451a7151c715137151a7151c715137151a71500145137151a7151c715137151a7151c71513715001451c715137151a7151c715137151a7151c715001451a7151c71513715
010e00000c0033071013735247100c735007000c0030c003246002460513735307100c735247101c7150c0030c0033071013735247100c735007000c0030c003246002460513735307000c735247001c7150c003
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
01 08 09 12 44
00 08 0a 12 44
00 0b 09 12 44
00 13 0a 12 44
00 14 0c 12 44
00 15 0d 12 44
00 17 09 16 44
00 1c 0a 16 44
00 19 09 1a 44
00 18 0a 1b 44
00 0e 0f 11 44
00 0e 0f 11 44
00 0e 1e 1f 44
00 0e 20 1d 44
00 22 21 12 44
02 08 23 12 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
