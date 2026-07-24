pico-8 cartridge // http://www.pico-8.com
version 7
__lua__
--ennui
--by watch out for snakes
grandpa={} --controls grandpas state, contains his sprite, x and y position and heading
tiles={} --controls the tiles state, contains collision and interaction data
items={}
game={} --controls the game state, holds the draw and update function pointers
grass={}
hedge={}
flowers={}
shed={}
text={}
objects={}
timers={}

function _init()
	--initilaises game state on powerup or reset
	cls() --clear the screen
	game.upd=updatemenu --sets first update to menu
	game.draw=drawmenu --sets first draw to menu
	timers.titleanim=301
	game.titleanim=0
	game.titlestretch=0
	game.titlestate=0
end

function initgame()
	--initialises the first game variables
	game.moweranim=0
	game.text=false
	grandpa.sprite=000
	grandpa.flip=true
	grandpa.heading=0
	grandpa.tilex=14
	grandpa.tiley=7
	grandpa.x=112
	grandpa.y=56
	grandpa.item=false
	grandpa.timer=0
	grandpa.xdir=0
	grandpa.ydir=0
	grandpa.text=43
	music(0,100)
	game.music=1
	game.over=0
	game.fire=1

	--sets up the tile structure, indexed using tile[x pos][y pos].collision[heading]
	for i = 0,15 do
		tiles[i]={}
		for j = 0,13 do
			tiles[i][j]={}
			tiles[i][j].collision={}
			tiles[i][j].interaction={}
			tiles[i][j].object={}
			for k = 0,3 do
				tiles[i][j].interaction[k]=0
				tiles[i][j].object[k]=0
			end
		end
	end
	--sets up grass structure
	for i = 1,9 do
		grass[i]={}
		for j = 10,12 do
			grass[i][j]={}
			if flr(rnd(2))==1 then
				grass[i][j]=8+flr(rnd(4))
			else
				grass[i][j]=false
			end
		end
	end

	--sets up hedge structure
	for i = 15,15 do
		hedge[i]={}
		for j = 1,5 do
			hedge[i][j]={}
			hedge[i][j].sprite=017
			hedge[i][j].trimmed=false
		end
	end

	--sets up flowers
	
	for i = 8,13 do
		flowers[i]={}
		flowers[i][3]={}
		flowers[i][3].trimmed=false
		if flr(rnd(4))==1 then
			flowers[i][3].trimmed=true
		elseif flr(rnd(2))==1 then
			flowers[i][3].sprite=120
		else
			flowers[i][3].sprite=121
		end
	end

	for i = 4,5 do
		flowers[8][i]={}
		flowers[8][i].trimmed=false
		if flr(rnd(4))==1 then
			flowers[8][i].trimmed=true
		elseif flr(rnd(2))==1 then
			flowers[8][i].sprite=120
		else
			flowers[8][i].sprite=121
		end
	end

	settext()
	setitems() --deals with item info
	setobjects() --deals with object info info
	setcollisions() --deals with all the collisions
	itemcollisions() --deals with item collisions
	setlocations()
	setinteractions() --deals with all the item interactions
	initshed() --initliases the shed and contents
	inittimers() --initialises the timers used in the game
end

function settext()
	--[[25 character width on text box, lines are breaks, pad with spaces to not chop words in half, | are where 
	a new line starts
	        "-------------------------|------------------------|------------------------"]]
	text[0]="press z to interact      press x to grumble"
	text[1]="needs some gas"
	text[2]="fuel sloshes into the    tank."
	text[3]="you flood the motor"
	text[4]="geraniums...             her favourite."
	text[5]="you fill the watering canup with water."
		  --"-------------------------|------------------------|------------------------"
	text[6]="it's already fueled up"
	text[7]="you pour some gas in     the sink"
	text[8]="there's no water in the  can!"
	text[9]="i guess i need to do my  own washing now"
	text[10]="i'm just so angry"
	       --"-------------------------|------------------------|------------------------"
	text[11]="air doesn't fight back"
	text[12]="firewood for one"
	text[13]="**clunk**"
	text[14]="nothing here"
	text[15]="it's a sink"
	       --"-------------------------|------------------------|------------------------"
	text[16]="a well trimmed hedge"
	text[17]="i havn't slept well in   weeks"
	text[18]="a well made bed is its   own reward"
	text[19]="i regret that"
	text[20]="**thwack**"
		-----"-------------------------|------------------------|------------------------"
	text[21]="my throne, shattered"
	text[22]="we bought this one       together in the 70s"
	text[23]="aint that a novel idea,  works too"
	text[24]="take that you commie"
	text[25]="where's that remote?"
	---------"-------------------------|------------------------|------------------------"
	text[26]="**ding**"
	--text[27]="the youths call this     being a hipster........   i think."
	text[28]="ah, well"
	text[29]="~like sands through the  hourglass~"
	text[30]="i cant watch tv without  her"
	text[31]="too many memories"
	---------"-------------------------|------------------------|------------------------"
	text[32]="i'll ask dearest to...   i'll hang them out..     later"
	text[33]="that should be enough to keep us... me warm"
	text[34]="*sigh*"
	text[35]="why bother"
	text[36]="toasty"
	text[37]="it will keep going till  it dies"
	---------"-------------------------|------------------------|------------------------"
	text[38]="if only life was this    easy"
	text[39]="just how she would have  liked them"
	text[40]="that's a bad idea"
	text[41]="i should make the bed"
	text[42]="that trump has some good ideas"
	text[43]="john said the hedges werelooking a bit sad"
	---------"-------------------------|------------------------|------------------------"
	text[44]="i wonder whats on tv"
	text[45]="i miss her so much"
	text[46]="those cut flowers need   some water"
	text[46]="did i leave the mower on?"
	text[47]="a fire would be nice"
	text[48]="the garden needs         cultivating"
	text[49]="honey..."
	text[50]="its getting harder to    get out of bed"
	---------"-------------------------|------------------------|------------------------"
	text[51]="itll will be my time soon"
	text[52]="i'm angry and  i don't   know why"
	text[53]="i'd give anything to haveher back"
	text[54]="i need a drink"
	text[55]="why did she have to go   first"
	---------"-------------------------|------------------------|------------------------"
	text[56]="stupid doctors"
	text[57]="who cares about me..."
	text[58]="another pointless day"
	text[59]="i wish the phone would   ring"
	text[60]="i wish i had appreciated her"
	text[61]="a letter for her..."
	---------"-------------------------|------------------------|------------------------"
	
end

function setitems()
	--sets items up in a structure, minimum is name, symbol, shed, interaction
	--lawnmower - 1
	items[1]={}
	items[1].sprite=042
	items[1].symbol=false
	items[1].flip=true
	items[1].heading=3
	items[1].x=96
	items[1].y=96
	items[1].tilex=12
	items[1].tiley=12
	items[1].interaction=2
	items[1].visible=true
	items[1].fuel=false
	items[1].shed=false
	items[1].flooded=false

	--remote - 2
	items[2]={}
	items[2].name="remote"
	items[2].func=remote
	items[2].sprite=126
	items[2].symbol=201
	items[2].visible=true
	items[2].x=40
	items[2].y=40
	items[2].shed=false
	items[2].tilex=5
	items[2].tiley=5
	items[2].interaction=4

	--detergent - 3
	items[3]={}
	items[3].name="detergent"
	items[3].func=detergent
	items[3].symbol=204
	items[3].tilex=9
	items[3].tiley=8
	items[3].interaction=0
	items[3].shed=false

	--shed empty - 4
	items[4]={}
	items[4].name="----"
	items[4].shed=true
	items[4].interaction=5

	--fire poker - 5
	items[5]={}
	items[5].name="fire poker"
	items[5].func=poker
	items[5].symbol=207
	items[5].tilex=1
	items[5].tiley=4
	items[5].interaction=1
	items[5].shed=false

	--wood - 6
	items[6]={}
	items[6].name="kindling"
	items[6].func=kindling
	items[6].symbol=198
	items[6].tilex=10
	items[6].tiley=12
	items[6].interaction=4
	items[6].shed=false

	--rope - 7
	items[7]={}
	items[7].name="rope"
	items[7].func=rope
	items[7].symbol=73
	items[7].shed=true
	items[7].interaction=5

	--axe - 8
	items[8]={}
	items[8].name="axe"
	items[8].func=axe
	items[8].symbol=76
	items[8].shed=true
	items[8].interaction=5

	--jerry can - 9
	items[9]={}
	items[9].name="jerry can"
	items[9].func=jerrycan
	items[9].symbol=134
	items[9].shed=true
	items[9].interaction=5

	--rake - 10
	items[10]={}
	items[10].name="rake"
	items[10].func=rake
	items[10].symbol=137
	items[10].shed=true
	items[10].interaction=5

	--shears - 11
	items[11]={}
	items[11].name="shears"
	items[11].func=shears
	items[11].symbol=140
	items[11].shed=true
	items[11].interaction=5

	--watering can - 12
	items[12]={}
	items[12].name="watering can"
	items[12].func=wateringcan
	items[12].symbol=192
	items[12].shed=true
	items[12].interaction=5
	items[12].full=false

	--cultivator - 13
	items[13]={}
	items[13].name="cultivator"
	items[13].func=cultivator
	items[13].symbol=195
	items[13].shed=true
	items[13].interaction=5

	--shed exit - 14
	items[14]={}
	items[14].name="exit"
	items[14].shed=true
	items[14].interaction=5
end

function emptyhands(object)
	if tiles[grandpa.tilex][grandpa.tiley].interaction[grandpa.heading]<=0 then
		if object~=100 and object~=99 then
			if object==7 and not objects[7].used then 
				timers.ennui+=3
				sfx(27)
				objects[7].used=true
				game.text=14
				--game text, use the toilet text
			elseif object==7 and objects[7].used then 
				--game text, already used the toilet text
			elseif object==6 and not objects[6].checked then
				objects[6].checked=true
				timers.ennui-=10
				sfx(22)
				game.text=61
				--game text, checked the mail
			elseif object==6 and objects[6].checked then
				--game text, mail already checked
			elseif object==1 and not objects[1].made then
				objects[1].made = true
				game.text=17
				timers.ennui+=3
				sfx(27)
			elseif object==1 and objects[1].made then
				game.text=18
			elseif object==14 then
				game.text=25
			end
		end
	end
end

function remote(object)
	if object==14 and objects[14].watched==0 then
		timers.tv=1
		grandpa.ydir-=1
		grandpa.tiley-=1
		grandpa.timer=8
		objects[14].watched=1
		timers.ennui+=5
		game.text=29
		sfx(27)
	elseif object==14 and objects[14].watched==1 then
		timers.tv=1
		grandpa.ydir-=1
		grandpa.tiley-=1
		grandpa.timer=8
		objects[14].watched=2
		timers.ennui-=10
		game.text=30
		sfx(22)
	elseif object==14 and objects[14].watched==2 then
		game.text=31
	end
end

function detergent(object)
	if object==3 and not objects[3].used then
		--game text, washed the clothes text
		game.text=9
		objects[3].used=true
		timers.ennui+=3
		sfx(27)
		elseif object==3 and objects[3].used then
		game.text=32
	end
end

function poker(object)
	-- body
	if object==1 then
		game.text=10
	elseif object==00 then
		game.text=11
	elseif object==99 or object==02 or object==03 or object==04 or object==10 then
		game.text=13
	elseif object==05 then
		game.text=19
	elseif object==06 then
		game.text=20
	elseif object==07 then
		game.text=21
	elseif object==08 then
		game.text=24
	elseif object==09 and timers.fire>0 and objects[9].fire==1 then
		game.text=23
		timers.fire=20
		--game text, fire is alive, and you're poking it
		game.text=33
	elseif object==09 and timers.fire<=0 and objects[9].fire==1 then
		timers.ennui-=20
		--game text, fire has died and you've tried to poke it
		game.text=34
	elseif object==09 and timers.fire==0 and objects[9].fire==0 then
		--game text, no fire, and you've tried to poke it
		game.text=35
	elseif object==11 then
		game.text=26
	--elseif object==15 then
		--game.text=27
	--elseif object==12 then
		--game.text=28
	end
end

function kindling(object)
	if objects[9].fire==0 and object==9 and timers.fire<=0 then
		objects[9].fire=1
		timers.fire=20
		timers.ennui+=10
		grandpa.item=false
		--game text, you've lit a fire
		game.text=36
	elseif objects[9].fire==1 and object==9 and timers.fire>0 then
		--game text, there's a fire already lit
		game.text=37
	elseif objects[9].fire==1 and object==9 and timers.fire<=0 then
		timers.fire=20
		grandpa.item=false
		--game text, the fire has gone out, and you're bringing new kindling
		game.text=38
	end
end

function rope(object)
	-- body
end

function axe(object)
	if object==10 then
		game.text=12
		sfx(9)
	end
end

function jerrycan(object)
	if object==99 and not items[1].fuel then
		game.text=2
		items[1].fuel=true
		sfx(18)
	elseif object==99 and items[1].fuel then
		game.text=6 
	end
end

function rake(object)
	-- body
end

function shears(object)
	if object==12 and not hedge[15][grandpa.tiley].trimmed then
		hedge[15][grandpa.tiley].sprite=018
		hedge[15][grandpa.tiley].trimmed=true
		sfx(12)
		timers.ennui+=3
	elseif object==12 and hedge[15][grandpa.tiley].trimmed then
		--game text for already trimmed hedges
		game.text=39
	end
end

function wateringcan(object)
	if object==2 then
		game.text=5
		items[12].full=true
		sfx(18)
	elseif not items[12].full and not (grandpa.tilex==12 and grandpa.tiley==11 and grandpa.heading==1) then
		game.text=8
	end
		
	if items[12].full then
		if object==99 and not items[1].flooded then
			game.text=3
			timers.ennui-=20
			items[1].flooded=true
		elseif object==99 and items[1].flooded then
			--i've already flooded the motor text
			game.text=40
		elseif object==5 and not objects[5].watered then
			game.text=4
			timers.ennui+=5
			objects[5].watered=true
			sfx(17)
		elseif object==5 and objects[5].watered then
			--i've already watered the flowers text
			game.text=41
		end
	end
end

function cultivator(object)
	if object==13 then
		if grandpa.heading==0 then
			if not flowers[grandpa.tilex-1][grandpa.tiley].trimmed then
				flowers[grandpa.tilex-1][grandpa.tiley].trimmed=true
				timers.ennui+=5
				sfx(12)
			else
				--flowers already trimmed text
				game.text=39
			end
		elseif grandpa.heading==1 then
			if not flowers[grandpa.tilex+1][grandpa.tiley].trimmed then
				flowers[grandpa.tilex+1][grandpa.tiley].trimmed=true
				timers.ennui+=5
				sfx(12)
			else
				--flowers already trimmed text
				game.text=39
			end
		elseif grandpa.heading==2 then
			if not flowers[grandpa.tilex][grandpa.tiley-1].trimmed then
				flowers[grandpa.tilex][grandpa.tiley-1].trimmed=true
				timers.ennui+=5
				sfx(12)
			else
				--flowers already trimmed text
				game.text=39
			end
		else
			if not flowers[grandpa.tilex][grandpa.tiley+1].trimmed then
				flowers[grandpa.tilex][grandpa.tiley+1].trimmed=true
				timers.ennui+=5
				sfx(12)
			else
				--flowers already trimmed text
				game.text=39
			end
		end
	end
end

function setobjects()
	--single objects
	--bed
	objects[1]={}
	objects[1].tilex=14
	objects[1].tiley=7
	objects[1].interaction=2
	objects[1].made=false

	--sink
	objects[2]={}
	objects[2].tilex=5
	objects[2].tiley=9
	objects[2].interaction=2
	objects[2].text=15

	--washing machine
	objects[3]={}
	objects[3].tilex=7
	objects[3].tiley=9
	objects[3].interaction=2
	objects[3].used=false

	--fridge
	objects[4]={}
	objects[4].tilex=1
	objects[4].tiley=8
	objects[4].interaction=1

	--flowers
	objects[5]={}
	objects[5].tilex=4
	objects[5].tiley=6
	objects[5].interaction=3
	objects[5].watered=false

	--mailbox
	objects[6]={}
	objects[6].tilex=10
	objects[6].tiley=1
	objects[6].interaction=4
	objects[6].checked=false

	--toilet
	objects[7]={}
	objects[7].tilex=13
	objects[7].tiley=5
	objects[7].interaction=0
	objects[7].used=false

	--mailman
	objects[8]={}
	objects[8].tilex=-1
	objects[8].tiley=-1
	objects[8].interaction=5

	--fireplace
	objects[9]={}
	objects[9].tilex=1
	objects[9].tiley=4
	objects[9].interaction=1
	objects[9].fire=0

	--stump
	objects[10]={}
	objects[10].tilex=11
	objects[10].tiley=12
	objects[10].interaction=2

	--phone
	objects[11]={}
	objects[11].tilex=2
	objects[11].tiley=6
	objects[11].interaction=3

	--special case objects
	--hedges
	objects[12]={}
	objects[12].tilex=15
	objects[12].tileystart=1
	objects[12].tileyend=5
	objects[12].interaction=0

	--flowerbed
	objects[13]={}
	objects[13].tilex=8
	objects[13].tiley=3
	objects[13].tilexend=13
	objects[13].tileyend=5
	objects[13].interaction=0

	--tv
	objects[14]={}
	objects[14].tilexstart=3
	objects[14].tilexend=4
	objects[14].tiley=5
	objects[14].interaction=3
	objects[14].watched=0

	--couch
	objects[15]={}
	objects[15].tilexstart=2
	objects[15].tilexend=5
	objects[15].tiley=3
	objects[15].interaction=3
end

function setinteractions()
	for i = 0,15 do
		for j = 0,13 do
			for k = 0,3 do
				tiles[i][j].object[k]=0
			end
		end
	end

	for i=1,11 do
		if objects[i].interaction < 5 then
			if objects[i].interaction==0 then
				tiles[objects[i].tilex-1][objects[i].tiley].object[1]=i
			elseif objects[i].interaction==1 then
				tiles[objects[i].tilex+1][objects[i].tiley].object[0]=i
			elseif objects[i].interaction==2 then
				tiles[objects[i].tilex][objects[i].tiley-1].object[3]=i
			elseif objects[i].interaction==3 then
				tiles[objects[i].tilex][objects[i].tiley+1].object[2]=i
			elseif objects[i].interaction==4 then
				tiles[objects[i].tilex-1][objects[i].tiley].object[1]=i
				tiles[objects[i].tilex+1][objects[i].tiley].object[0]=i
				tiles[objects[i].tilex][objects[i].tiley-1].object[3]=i
				tiles[objects[i].tilex][objects[i].tiley+1].object[2]=i
			end
		end
	end

	for i=objects[12].tileystart,objects[12].tileyend do
		tiles[objects[12].tilex-1][i].object[1]=12
	end

	for i=objects[13].tiley,objects[13].tileyend do
		tiles[objects[13].tilex-1][i].object[1]=13
		tiles[objects[13].tilex+1][i].object[0]=13
		tiles[objects[13].tilex][i-1].object[3]=13
		if i ~= objects[13].tileyend then 
			tiles[objects[13].tilex][i+1].object[2]=13
		end
	end
	for i=objects[13].tilex,objects[13].tilexend do
		tiles[i-1][objects[13].tiley].object[1]=13
		tiles[i+1][objects[13].tiley].object[0]=13
		tiles[i][objects[13].tiley-1].object[3]=13
	end
	for i=objects[14].tilexstart,objects[14].tilexend do
		tiles[i][objects[14].tiley-1].object[3]=14
	end
	for i=objects[15].tilexstart,objects[15].tilexend do
		tiles[i][objects[15].tiley+1].object[2]=15
	end	

	if items[1].tilex~=0 then
		tiles[items[1].tilex-1][items[1].tiley].object[1]=99
	end
	if items[1].tilex~=15 then
		tiles[items[1].tilex+1][items[1].tiley].object[0]=99
	end
	if items[1].tiley~=0 then
		tiles[items[1].tilex][items[1].tiley-1].object[3]=99
	end
	tiles[items[1].tilex][items[1].tiley+1].object[2]=99
	tiles[12][11].object[1]=100
end

function setcollisions()
	--[[how collisions work
	each tile is referenced with it's x,y co-ordinate in the game world, when grandpa wants to move
	we check what tile he's standing on what heading he's facing, we then check the collision number
	matching that heading to see if it's a valid move.]]
	for i = 0,15 do
		for j = 0,13 do
			for k = 0,3 do
				tiles[i][j].collision[k]=false
			end
		end
	end

	for i = 0,15 do
		tiles[i][0].collision[2]=true
		tiles[i][12].collision[3]=true
	end

	for i = 0,12 do
		tiles[0][i].collision[0]=true
		tiles[15][i].collision[1]=true
	end

	--set rest of hosue using a nested for loop to visit every tile
	for i = 0,15 do
		for j = 0,12 do
			--vertical slices
			if i==0 and j>=3 and j<=9 then
				tiles[i][j].collision[1]=true
				tiles[i+1][j].collision[0]=true
			end
			
			if (i==1 and j==3) or (i==1 and j>=5 and j<=6)then
				tiles[i][j].collision[1]=true
			end

			if (i==6 and j>=2 and j<=3) or (i==6 and j>=5 and j<=6) or (i==6 and j==9)then
				tiles[i][j].collision[0]=true
			end

			if (i==6 and j>=2 and j<=3) or (i==6 and j==5) or (i==6 and j>=8 and j<=9) then
				tiles[i][j].collision[1]=true
				tiles[i+1][j].collision[0]=true
			end

			if (i==8 and j>=4 and j<=5) or (i==8 and j==8) then
				tiles[i][j].collision[1]=true
				tiles[i+1][j].collision[0]=true
			end

			if (i==9 and j==6) or (i == 9 and j>=8 and j<=9) or (i==9 and j==12) then
				tiles[i][j].collision[1]=true
				tiles[i+1][j].collision[0]=true
			end
			
			if (i==12 and j>=4 and j<=5) or (i==12 and j>=7 and j<=8) or (i==12 and j>=10 and j<=12) then
				tiles[i][j].collision[1]=true
			end

			if (i==13 and j>=4 and j<=5) then
				tiles[i][j].collision[1]=true
				tiles[i+1][j].collision[0]=true
			end

			if i==14 and j>=1 and j<=9 then
				tiles[i][j].collision[1]=true
			end

			--horizontal slices
			if j==1 and i>=2 and i<=6 then
				tiles[i][j].collision[3]=true
				tiles[i][j+1].collision[2]=true
			end

			if (j==3 and i>=9 and i<=13) then
				tiles[i][j].collision[3]=true
				tiles[i][j+1].collision[2]=true
			end

			if (j==4 and i>=2 and i<=5) then
				tiles[i][j].collision[2]=true
				tiles[i][j].collision[3]=true
			end

			if (j==5 and i>=7 and i<=11) or (j==5 and i>=13 and i<=15) then
				tiles[i][j].collision[3]=true
				tiles[i][j+1].collision[2]=true
			end

			if (j==6 and i>=13 and i<=14) then
				tiles[i][j].collision[3]=true
			end

			if (j==7 and i>=2 and i<=5) then
				tiles[i][j].collision[2]=true
			end

			if (j==7 and i==1) or (j==7 and i>=8 and i<=9) then
				tiles[i][j].collision[3]=true
				tiles[i][j+1].collision[2]=true
			end

			if (j==8 and i>=1 and i<=5) or (j==8 and i>=7 and i<=9) or (j==8 and i>=13 and i<=14) then
				tiles[i][j].collision[3]=true
				tiles[i][j+1].collision[2]=true
			end

			if (j==9 and i>=1 and i<=5) or (j==9 and i>=7 and i<=15) then
				tiles[i][j].collision[3]=true
				tiles[i][j+1].collision[2]=true
			end
		end
	end

	--cleans up individual tiles
	for i=1,3,2 do
		tiles[1][2].collision[i]=true
	end
	tiles[1][3].collision[2]=true
	tiles[1][5].collision[2]=true
	tiles[2][4].collision[0]=true
	tiles[2][8].collision[0]=true
	tiles[2][2].collision[0]=true
	tiles[9][1].collision[1]=true
	tiles[10][0].collision[3]=true
	tiles[10][2].collision[2]=true
	tiles[10][11].collision[3]=true
	tiles[10][12].collision[1]=true
	tiles[11][1].collision[0]=true
	tiles[11][5].collision[0]=true
	tiles[11][5].collision[2]=true
	tiles[11][5].collision[3]=true
	tiles[11][11].collision[3]=true
	tiles[12][4].collision[0]=true
	tiles[12][12].collision[0]=true
	tiles[14][7].collision[0]=true
	tiles[14][7].collision[1]=true
	tiles[14][7].collision[3]=true
	tiles[15][0].collision[3]=true
	tiles[15][7].collision[3]=true
	tiles[15][8].collision[0]=true
	tiles[15][8].collision[1]=true
	tiles[15][8].collision[3]=true
end

function itemcollisions()
	--if an item has collisons they're set here, currently mower only
	if items[1].tilex-1 >= 0 then
		tiles[items[1].tilex-1][items[1].tiley].collision[1]=true
	end
	if items[1].tilex+1 <= 15 then
		tiles[items[1].tilex+1][items[1].tiley].collision[0]=true
	end
	if items[1].tiley-1 >= 0 then
		tiles[items[1].tilex][items[1].tiley-1].collision[3]=true
	end
	if items[1].tiley-1<=12 then
		tiles[items[1].tilex][items[1].tiley+1].collision[2]=true
	end
end

function setlocations()
	--[[interactions are delt with the same way as collisions, the item number is stored tiles[x][y].interaction[heading],
	this is for picking up and putting down the item. tiles[x][y].interacts[heading] is for item/tile actions.
	each item has a .interaction and .interacts field. this field is referenced when setting the tile interactions around it, same
	directions as pico8 button inputs.]]
	for i = 0,15 do
		for j = 0,13 do
			for k = 0,3 do
				tiles[i][j].interaction[k]=0
			end
		end
	end

	for i=1,#items do
		if items[i].interaction < 5 then
			if items[i].interaction==0 then
				tiles[items[i].tilex-1][items[i].tiley].interaction[1]=i
			elseif items[i].interaction==1 then
				tiles[items[i].tilex+1][items[i].tiley].interaction[0]=i
			elseif items[i].interaction==2 then
				tiles[items[i].tilex][items[i].tiley-1].interaction[3]=i
			elseif items[i].interaction==3 then
				tiles[items[i].tilex][items[i].tiley+1].interaction[2]=i
			elseif items[i].interaction==4 then
				tiles[items[i].tilex-1][items[i].tiley].interaction[1]=i
				tiles[items[i].tilex+1][items[i].tiley].interaction[0]=i
				tiles[items[i].tilex][items[i].tiley-1].interaction[3]=i
				tiles[items[i].tilex][items[i].tiley+1].interaction[2]=i
			end
		end
	end
end

function initshed()
	shed.cursorx=0
	shed.cursory=0
	item = 7
	for i = 0,1 do
		shed[i]={}
		for j = 0,3 do
			shed[i][j]=item
			item+=1
		end
	end
end

function inittimers()
	game.counter=0
	timers.ennui=180
	timers.fire=0
	timers.tv=0
end

function _update()
	game.upd()
end

function updatemenu()
	timers.titleanim-=1
	game.titleanim+=1

	if timers.titleanim>0 then
		if game.titleanim>=25 then
	 		game.titlestretch=0
	 		game.titleanim=0
	 		game.titlestate+=1
	 		sfx(29)
		elseif game.titleanim>=12.5 then
	 		game.titlestretch=1
		end
	end

	if btnp(4) or timers.titleanim<=-150 then
		initgame()
		game.upd=updategame--updategame --pointers to functions
		game.draw=drawgame--drawgame
		game.text=0
	end
end

function updategame()
	if grandpa.timer==0 then
		if grandpa.item == 001 and items[1].fuel then --grandpa+mower stuf
			sfx(2,0)
			movemower()
			mowerinteract()
		elseif grandpa.item == 001 and not items[1].fuel then
			grandpa.item=false
			game.text=1
		else --grandpa wihtout mower stuff
			interact()
			movegrandpa()
		end
	end
	if items[1].fuel then		
		mower() --sets the mowers position based on grandpas while in use
	end
	updategrandpa() --moves and animates grandpa
	updatetimers()
	gameover()
	if game.music == 1 and timers.ennui<60 then
		game.music=0
		music(1,100)
	elseif game.music==0 and timers.ennui>60 then
		game.music=1
		music(0,100)
	end

	if btnp(5) and grandpa.item ~= 001 then
		grandpa.text+=1
		if grandpa.text>60 and timers.ennui<60 then
			grandpa.text=50
		elseif grandpa.text>50 and timers.ennui>60 then
			grandpa.text=41
		end
		game.text=grandpa.text
	end
end

function movegrandpa()
	for i = 0,3 do --runs a for loop for each of the 4 direction inputs
		if btnp(i) then
			if grandpa.heading==i then --checks it his heading is the same as him move input
				grandpa.timer=8 --set's the step-count per tile transition animation
				if not tiles[grandpa.tilex][grandpa.tiley].collision[grandpa.heading] then --checks to see if he can move into that space
					if grandpa.heading==0 then --depending on heading, update tile number and cue up movement
						grandpa.tilex-=1
						grandpa.xdir-=1
					elseif grandpa.heading==1 then
						grandpa.tilex+=1
						grandpa.xdir+=1
					elseif grandpa.heading==2 then
						grandpa.tiley-=1
						grandpa.ydir-=1
					else
						grandpa.tiley+=1
						grandpa.ydir+=1
					end
				end
			else
			 	grandpa.heading=i --if the heading doesn't match the direction input, rotate to face input
			 	grandpasprite()
			end
		end
	end
end

function grandpasprite()
	if grandpa.heading==0 or grandpa.heading==2 then
		grandpa.flip=true --depending on facing, flip grandpas sprite
	else
		grandpa.flip=false
	end
	if grandpa.item==001 then
		if grandpa.heading<=1 then
			grandpa.sprite=112 --depending on facing, change grandpas sprite
		else
			grandpa.sprite=113
		end
	else
		if grandpa.heading<=1 then
			grandpa.sprite=000 --depending on facing, change grandpas sprite
		else
			grandpa.sprite=001
		end
	end
end

function movemower()
	if btnp(0) then --rotation of mower anti-clockwise. checks current heading, checks collisions and then rotates
		if grandpa.heading==0 then
			if not tiles[grandpa.tilex][grandpa.tiley].collision[3] and not tiles[items[1].tilex][items[1].tiley].collision[3] and
			not tiles[grandpa.tilex][grandpa.tiley+1].collision[0] then
				grandpa.heading=3
			end
		elseif grandpa.heading==1 then
			if not tiles[grandpa.tilex][grandpa.tiley].collision[2] and not tiles[items[1].tilex][items[1].tiley].collision[2] and
			not tiles[grandpa.tilex][grandpa.tiley-1].collision[1] then
				grandpa.heading=2
			end
		elseif grandpa.heading==2 then
			if not tiles[grandpa.tilex][grandpa.tiley].collision[0] and not tiles[items[1].tilex][items[1].tiley].collision[0] and
			not tiles[grandpa.tilex-1][grandpa.tiley].collision[2] then
				grandpa.heading=0
			end
		else
			if not tiles[grandpa.tilex][grandpa.tiley].collision[1] and not tiles[items[1].tilex][items[1].tiley].collision[1] and
			not	tiles[grandpa.tilex+1][grandpa.tiley].collision[3] then 
				grandpa.heading=1
			end
		end
	elseif btnp(1) then --rotation of mower clockwise. checks current heading, checks collisions and then rotates
		if grandpa.heading==0 then
			if not tiles[grandpa.tilex][grandpa.tiley].collision[2] and not tiles[items[1].tilex][items[1].tiley].collision[2] and 
			not tiles[grandpa.tilex][grandpa.tiley-1].collision[0] then
				grandpa.heading=2
			end
		elseif grandpa.heading==1 then
			if not tiles[grandpa.tilex][grandpa.tiley].collision[3] and not tiles[items[1].tilex][items[1].tiley].collision[3] and
			not tiles[grandpa.tilex][grandpa.tiley+1].collision[1] then
				grandpa.heading=3
			end
		elseif grandpa.heading==2 then
			if not tiles[grandpa.tilex][grandpa.tiley].collision[1] and not tiles[items[1].tilex][items[1].tiley].collision[1] and
			not	tiles[grandpa.tilex+1][grandpa.tiley].collision[2] then
				grandpa.heading=1
			end
		else
			if not tiles[grandpa.tilex][grandpa.tiley].collision[0] and not tiles[items[1].tilex][items[1].tiley].collision[0] and
			not	tiles[grandpa.tilex-1][grandpa.tiley].collision[3] then 
				grandpa.heading=0
			end
		end
	elseif btnp(2) then --movement of mower forward. checks current heading, checks collisions and then moves
		if not tiles[items[1].tilex][items[1].tiley].collision[grandpa.heading] then
			grandpa.timer=8
			if grandpa.heading==0 then
				grandpa.tilex-=1
				grandpa.xdir-=1
			elseif grandpa.heading==1 then
				grandpa.tilex+=1
				grandpa.xdir+=1
			elseif grandpa.heading==2 then
				grandpa.tiley-=1
				grandpa.ydir-=1
			else
				grandpa.tiley+=1
				grandpa.ydir+=1
			end
		end
	elseif btnp(3) then --movement of mower backwards. checks current heading, checks collisions and then moves
		if not tiles[grandpa.tilex][grandpa.tiley].collision[items[1].heading] then
			grandpa.timer=8
			if grandpa.heading==0 then
				grandpa.tilex+=1
				grandpa.xdir+=1
			elseif grandpa.heading==1 then
				grandpa.tilex-=1
				grandpa.xdir-=1
			elseif grandpa.heading==2 then
				grandpa.tiley+=1
				grandpa.ydir+=1
			else
				grandpa.tiley-=1
				grandpa.ydir-=1
			end
		end
	end
	grandpasprite()
	setcollisions()
	setlocations()
	itemcollisions()
	setinteractions()
end

function updategrandpa()
	if grandpa.timer>0 then --checks the animation timer
		grandpa.timer-=1 --reduces the timer by one
		if grandpa.xdir~=0 then
			grandpa.x+=grandpa.xdir --takes the number in xdir and adds it to his co-ordinates
			if grandpa.timer==7 or grandpa.timer==5 or grandpa.timer==3 or grandpa.timer==1 then --runs the animation
				grandpa.x+=1
			else
				grandpa.x-=1
			end
		end
		if grandpa.ydir~=0 then
			grandpa.y+=grandpa.ydir
			if grandpa.timer==7 or grandpa.timer==5 or grandpa.timer==3 or grandpa.timer==1 then
				grandpa.y+=1
			else
				grandpa.y-=1
			end
		end
	end

	if grandpa.timer==0 then --resets xdir and ydir to 0 when timer expires
		grandpa.xdir=0
		grandpa.ydir=0
	end
end

function updatetimers()
	game.counter+=1
	if game.counter==30 then
		game.fire=-game.fire
		for i,v in pairs(timers) do
			if timers[i]>0 then
				timers[i]-=1
			end
		end
		game.counter=0
	end
	--game.buffer=timers.fire
end

function gameover()
	if timers.ennui<=0 then
		game.upd=updateover --sets first update to menu
		game.draw=drawover
		timers.black=2
		timers.pause=0
		music(-1)
		grandpa.tilex=14
		grandpa.tiley=7
		grandpa.x=112
		grandpa.y=56
		grandpa.heading=0
		grandpa.item=false
		grandpasprite()
		initshed()
		music(3,100)
	end
end

function updateover()
	if timers.black>0 or timers.pause>0 then
		updatetimers()
	elseif game.over==1 then
		timers.pause=3
	elseif game.over==2 then
		timers.black=1
		grandpa.tilex=6
		grandpa.tiley=9
		grandpa.x=48
		grandpa.y=72
		grandpa.heading=3
		grandpasprite()
		music(3,100)
	elseif game.over==3 then
		timers.pause=3
	elseif game.over==4 then
		timers.black=1
		grandpa.tilex=12
		grandpa.tiley=11
		grandpa.x=96
		grandpa.y=88
		grandpa.heading=1
		grandpasprite()
		music(3,100)
	elseif game.over==5 then
		timers.pause=1
	elseif game.over==6 then
		timers.pause=1
		game.draw=drawshed
	elseif game.over==7 then
		timers.pause=1
		shed[shed.cursorx][shed.cursory]=4
		grandpa.item=7
		sfx(16)
	elseif game.over==8 then
		shed.cursory=1
		timers.pause=1
		sfx(15)
	elseif game.over==9 then
		shed.cursory=2
		timers.pause=1
		sfx(15)
	elseif game.over==10 then
		shed.cursory=3
		timers.pause=1
		sfx(15)
	elseif game.over==11 then
		shed.cursorx=1
		timers.pause=1
		sfx(15)
	elseif game.over==12 then
		timers.pause=2
		game.draw=drawover
		sfx(16)
	elseif game.over==13 then
		timers.pause=2
		grandpa.x=128
		grandpa.y=128
	elseif game.over==14 then
		timers.black=4
		sfx(19)
	elseif game.over==15 then
		music(2,100)
	end
	
	if timers.black==0 and timers.pause==0 and game.over < 99 then
		game.over+=1
	end
end

function interact()
	grabanddrop()
	useitems()
end

function grabanddrop()
	if btnp(4) and grandpa.tilex==12 and grandpa.tiley==11 and grandpa.heading==1 then --special shed case
		shedinteraction()
	elseif btnp(4) and not grandpa.item then --grandps has empty hands
		if tiles[grandpa.tilex][grandpa.tiley].interaction[grandpa.heading] > 0 and not items[tiles[grandpa.tilex][grandpa.tiley].interaction[grandpa.heading]].shed then --checks to see if an item is present, and not in the shed
			grandpa.item=tiles[grandpa.tilex][grandpa.tiley].interaction[grandpa.heading] --puts the item in grandpas inventory
			if grandpa.item==2 then
				items[2].visible=false --special remote case to remove it from the world
			end
		end
	elseif btnp(4) and grandpa.item==2 and tiles[grandpa.tilex][grandpa.tiley].object[grandpa.heading]==0 and timers.tv==0 then --special remote case for putting the remote down anywhere
		if (grandpa.tilex == 5 and grandpa.tiley == 4 and grandpa.heading == 3) or (grandpa.tilex == 6 and grandpa.tiley == 5 and grandpa.heading == 0) then --special remote case for putting it on table
			items[2].x = 40
			items[2].y = 40
			items[2].tilex = 5
			items[2].tiley = 5
		end
		items[grandpa.item].visible=true --draws the remote again
		grandpa.item=false --emtpties grandpas hands
		setlocations()
	elseif btnp(4) and tiles[grandpa.tilex][grandpa.tiley].interaction[grandpa.heading]==grandpa.item then --puts an item back in the correct location
		grandpa.item=false 
	end
	--deals with the remote motion
	if grandpa.item==2 then
		items[2].x = grandpa.x
		items[2].y = grandpa.y
		items[2].tilex = grandpa.tilex
		items[2].tiley = grandpa.tiley
	end
end

function useitems()
	if btnp(4) and grandpa.item and grandpa.item~=1then
		items[grandpa.item].func(tiles[grandpa.tilex][grandpa.tiley].object[grandpa.heading])
	elseif btnp(4) and not grandpa.item then
		emptyhands(tiles[grandpa.tilex][grandpa.tiley].object[grandpa.heading])
	end
	--game.buffer=tiles[grandpa.tilex][grandpa.tiley].object[grandpa.heading]
end

function mowerinteract()
	if btnp(4) then
		sfx(-1,0) --stops mower sound effects
		grandpa.item=false --puts mower down
		setinteractions() --sets all the interactions again so the mower can be used from the new position
	end
end

function shedinteraction()
	game.upd=updateshed
	game.draw=drawshed
end

function updateshed()
	if btnp(0) then
		if shed.cursorx==1 then
			shed.cursorx=0
			sfx(15)
		end
	elseif btnp(1) then
		if shed.cursorx==0 then
			shed.cursorx=1
			sfx(15)
		end
	elseif btnp(2) then
		if shed.cursory>0 then
			shed.cursory-=1
			sfx(15)
		end
	elseif btnp(3) then
		if shed.cursory<3 then
			shed.cursory+=1
			sfx(15)
		end
	end

	if btnp(4) then
		if shed.cursory==3 and shed.cursorx==1 then
			shed.cursorx=0
			shed.cursory=0
			game.upd=updategame
			game.draw=drawgame
		elseif not grandpa.item then
			grandpa.item=shed[shed.cursorx][shed.cursory]
			items[grandpa.item].shed=false
			shed[shed.cursorx][shed.cursory]=4
		elseif grandpa.item and shed[shed.cursorx][shed.cursory]==4 then
			shed[shed.cursorx][shed.cursory]=grandpa.item
			items[grandpa.item].shed=true
			grandpa.item=false
		else
			sheditem=shed[shed.cursorx][shed.cursory]
			shed[shed.cursorx][shed.cursory]=grandpa.item
			items[grandpa.item].shed=true
			grandpa.item=sheditem
			items[grandpa.item].shed=false
		end
		sfx(16)
	end
end

function drawshed()
	drawgame()
	leftmax=0 --initialises our string length variables
	rightmax=0
	for j = 1,3 do --gets the max string length of the left and right menu aprts and adds them together
		currentmax=max(#(items[shed[0][j]].name),#(items[shed[0][j-1]].name))
		leftmax=max(leftmax,currentmax)
		currentmax=max(#(items[shed[1][j]].name),#(items[shed[1][j-1]].name))
		rightmax=max(rightmax,currentmax)
	end
	rightspace=leftmax*4+6
	length=(leftmax+rightmax)*4+13 --performs the arithmatic to get our text box size
	offset=(128-length)/2 --gets the offset to centre the box
	rectfill(offset,48,length+offset,77,1) --draws the centred box
	rect(offset,48,length+offset,77,7)	
	spr(079,offset+2+rightspace*shed.cursorx,50+7*shed.cursory) --draws the cursor as set in updateshed()
	for i = 0,1 do
		for j = 0,3 do
			if shed[i][j] then
				print(items[shed[i][j]].name,offset+2+5+i*rightspace,50+j*7,7) --prints the contents of the shed
			else
				print("----")
			end
		end
	end
end

function mower()
	if grandpa.item==1 then
		--mower facing and placement
		if grandpa.heading==0 then
			items[1].heading=1
			items[1].interaction=1
			items[1].x=grandpa.x-8
			items[1].y=grandpa.y
			items[1].tilex=grandpa.tilex-1
			items[1].tiley=grandpa.tiley
			items[1].flip=false
			items[1].sprite=114
		elseif grandpa.heading==1 then
			items[1].heading=0
			items[1].interaction=0
			items[1].x=grandpa.x+8
			items[1].y=grandpa.y
			items[1].tilex=grandpa.tilex+1
			items[1].tiley=grandpa.tiley
			items[1].flip=true
			items[1].sprite=114
		elseif grandpa.heading==2 then
			items[1].heading=3
			items[1].interaction=3
			items[1].x=grandpa.x
			items[1].y=grandpa.y-8
			items[1].tilex=grandpa.tilex
			items[1].tiley=grandpa.tiley-1
			items[1].flip=false
			items[1].sprite=042
		elseif grandpa.heading==3 then
			items[1].heading=2
			items[1].interaction=2
			items[1].x=grandpa.x
			items[1].y=grandpa.y+8
			items[1].tilex=grandpa.tilex
			items[1].tiley=grandpa.tiley+1
			items[1].flip=true
			items[1].sprite=042
		end
		--mower animation
		if game.moweranim==0 then
			game.moweranim=3
			if items[1].sprite==114 then
				items[1].sprite=115
			elseif items[1].sprite==115 then
				items[1].sprite=114
			elseif items[1].sprite==042 then
				items[1].sprite=043
			else
				items[1].sprite=042
			end
		else
			game.moweranim-=1
		end
		--mower grass cutting
		if items[1].tilex>=1 and items[1].tilex<=9 and items[1].tiley>=10 and items[1].tiley<=12 then
			if grass[items[1].tilex][items[1].tiley] then
				grass[items[1].tilex][items[1].tiley] = false
				timers.ennui+=1
			end
		end
	end
end

function _draw()
	game.draw()
end

function drawmenu()
	cls()
	sspr(112,80,16,16,-62+8*game.titlestate,34,60+8*game.titlestretch,60)
	if timers.titleanim<=-10 then
		print("watch out for snakes!",25,95,7)
	end
end

function drawgame()
	cls() --clear the screen
	map(0,0,0,0,16,13) --draw the map
	drawitems() --draw the ui
	drawsprites() --draw all sprites
	drawgrandpa() --draw grandpa
	drawui() --draw the ui
end

function drawui()
	drawtextbox()
	drawitemsymbol()
end

function drawtextbox()
	rectfill(0,104,127,127,1)
	rect(0,104,127,127,7)
	pset(1,105,7)
	pset(103,105,7)
	pset(1,126,7)
	pset(103,126,7)
	line(104,104,104,127,7)
	if game.text and grandpa.timer==0 then
		game.upd=updatetext
		printtext()
	end
	print("ennui:",0,1,7)
	if timers.ennui<=180 and timers.ennui>=0 then
		rectfill(23,0,23+(104*(1-timers.ennui/180)),6,8)
	end
	rect(23,0,127,6,7)
	-- print(game.buffer,3,119,7)
	-- print(grandpa.tilex,3,107,7)
	-- print(grandpa.tiley,3,113,7)
end

function printtext()
	if #text[game.text]<=25 then
		print(text[game.text],3,107,7)
	elseif #text[game.text]>=25 and #text[game.text]<=50  then
		print(sub(text[game.text],1,25),3,107,7)
		print(sub(text[game.text],26),3,113,7)
	else 
		print(sub(text[game.text],1,25),3,107,7)
		print(sub(text[game.text],26,50),3,113,7)
		print(sub(text[game.text],51),3,119,7)
	end
end

function updatetext()
	if btnp(4) or btnp(5) then
		game.text=false
		game.upd=updategame
	end
end

function drawitemsymbol()
	if grandpa.item==5 then
		spr(items[grandpa.item].symbol,112,104,1,3)
	elseif grandpa.item==8 then
		spr(items[grandpa.item].symbol,104,104,3,2)
		spr(109,112,120,2,1)
	elseif grandpa.item==11 then
		spr(items[grandpa.item].symbol,104,104,3,2)
		spr(items[grandpa.item].symbol,104,104,2,3)
	elseif grandpa.item==12 then
		if not items[12].full then
			pal(12,0)
		end
		spr(items[grandpa.item].symbol,104,104,3,3)
		pal()
	elseif grandpa.item and items[grandpa.item].symbol then
		spr(items[grandpa.item].symbol,104,104,3,3)
	end
end

function drawitems()
	for i = 1,2 do
		if items[i].visible then
			spr(items[i].sprite,items[i].x,items[i].y,1,1,items[i].flip,items[i].flip)
		end
	end
	
end

function drawgrandpa()
	spr(grandpa.sprite,grandpa.x,grandpa.y,1,1,grandpa.flip,grandpa.flip) 
end

function drawsprites()
	drawgrass()
	drawhedge()
	drawbed()
	if not objects[6].checked then
		spr(3,80,8)
	end
	if timers.fire>0 then
		if game.fire>0 then
			pal(8,10)
			pal(10,8)
		end
		spr(119,8,32)
		pal()
	end
end

function drawgrass()
	for i = 1,9 do
		for j = 10,12 do
			if grass[i][j] then
				spr(grass[i][j],i*8,j*8)
			end
		end
	end
end

function drawhedge()
	for i = 15,15 do
		for j = 1,5 do
			if hedge[i][j] then
				spr(hedge[i][j].sprite,i*8,j*8)
			end
		end
	end
	--flowers
	for i = 8,13 do
		if not flowers[i][3].trimmed then
	 		spr(flowers[i][3].sprite,i*8,3*8)
		end
	end
	for i = 4,5 do
		if not flowers[8][i].trimmed then
			spr(flowers[8][i].sprite,8*8,i*8)
		end
	end
end

function drawbed()
	if not objects[1].made then
		spr(164,112,56,2,2)
	end
end

function drawover()
	cls()
	if game.over<15 then
		if timers.black>0 then
			cls()
		else
			drawgame()
		end
	else
		print("ennui",54,61)
	end
end
__gfx__
000000000000000000000000bbabb77bbabbbbbbbbbabbbbabbbbbbbbbbbbbbab3b33bb333b33b3bb3b3b33b3b33bb3b999d9999099d9999bb88abb0000000ba
00666f000066660000000000b848474bbbbbbabbbbbbbbbabbbbbbbbabbabbbb33b3bb333bb3bb3bb3b333bb33bbb33b99ddd99909ddd999bb878a0099dd9905
066ff1f00666f66055555555b484874bbbabbbbbbbbbbbbbbbbbbbabbbbbbbab3b33bb3bbb33bb3b3333b3bbb3b3b33b9ddddd990ddddd99ab3880d99dddd990
06fffff006ffff60d5dddddd4888888bbbbbabababbababbbbabbbbbbbbbbbbbbb3bb3bbb3b3b33b3b3333b3b3b3b3b3ddddddd90dddddd9b8830ddddddddd90
066ffff006ffff60d5dddddd4888888babbbbbbbbbbbbbbbbbbbbbbbbabbbbbbb3b333bbb3bbb3b3b33b3b33b3b3b3b39ddddddd0dddddddb870ddd99dddddd0
066ff1f00f1ff1f0dd5dddddabb00abbbbbbbbbbbbbbbabbbbbbbabbbbbbbbbb33b33b3333b33b33b3b33b3b3b3333b399ddddd909ddddd9bb0ddd9999ddddd0
00666f0000ffff00dd5ddddd00b04babbbabbbabbabbbbbbbbbbbbbbbbbbbbbb3b3b3b3bb33b3b3b3333b33b3b3b3b33999ddd99099ddd99b0ddd999999ddd90
00000000000000005555555500004bbbbbbbbbbbbbbbbbbbbabbbbabbbabbbba3b3b333b33bb3b3b3b3b33bbb3b33b3b9999d9990999d999099d99999999d990
47444444bb433433bb337673343bbbbb05555555bbbbbbabbbbbbbabbbbbbbbb999d9999999d99990333999903339999999d999000000000999d9999999d9990
7a744744b4344344bb33696388bbbabb0577757fabb4444444444444bbabbabb2e2e2e2e2e2e2e2e033399990333999999ddd99999ddd99999ddd99999ddd990
47447a74bb3b3333bb337673878bbbbb0777757fbb414141414141414bbbbbbb88888882e888888803339999033399999ddddd999ddddd999ddddd999ddddd90
44444744b4b43433bb767333b88babab07777577b44414141414141414bbbbbb4444488e288444440333999903339999ddddddd9ddddddd9ddddddd9ddddddd0
44744444bb434334bb69633343bbbbbb077775774f4f414141414141414bbabb44444482e844444409993333099933339ddddddd9ddddddd9ddddddd9dddddd0
47a74474b4334343bb767767388bbbbb077775774f4ff414141414141414bbbb4444444e24444444099933330999333399ddddd999ddddd999ddddd999ddddd0
447447a7bbb33433bb333696878bbbab077775774f4fff414141414141414bbb44444442e44444440999333309993333999ddd9900000000999ddd99999ddd90
44444474b4344343bb333767883bbbbb077775774f4fff4414141414141414ba4444444e2444444400000000000000009999d99922222222000000009999d990
022202222222022222202220999d9999099d99995654fff444444444444444bb44444442e4999999500000066500005655557777000000000000000005557777
0222022222220222222022202e0e2e202e2e2e2e5654ff414141414141414bbb4444444e2499cc9968888185588881855555777755557777544444440d557777
00000000000000000000000088805505555558885554ff414141414141414bab44444442e44cc8c458999f1658999f155555777755557777554444440d557777
02202222222222222222022044450606666654445554ff414141414141414bba4444488e28cccccc08959880089598805555777755557777554444440d557777
02202222222222222222022044456066666654445554f414141414141414bbbb44448882e888444408599880085998807777555577775555114444440d775555
90022222222222222222200944445666666544445554f414141414141414babb8888888e2888888858866885688668857777555577775555114444440d775555
999000000000000000000d9944444566665444444f4ff414141414141414bbbb88888882e8888888686886865868868577775555777755551144444407775555
9999d9999999d9999999d99944444566665444444f4ff414141414141414bbbb2e2e2e2e2e2e2e2e560000656600006677775555777755551144444407775555
b4444444555511aa0555111144444555555444444f4f414141414141414bbbab000000000000000055f577775555777755557777555577770577757754444444
4fffff44555511aa05dddddd44444440444c7c744f4f414141414141414bbbbb00770077666606605fff777755557777555577775555777705555555aaaaeaa7
4f444f4b555511880d66666d444444044447a7a74f4f414141414141414babbb0700770055555660fff8fddddddd4ddddddddddddddd3ddd0ddddddd5aaeee88
4f4f4f4b555518880d66666d44444404444c7c744f4414141414141414bbbbbb0700770055555660fff8ff55555455a5550050056ccc63330555555fbbeeee88
4f4f4f4a1111588c0d66666d444440444447a7444f4414141414141414bbbbbb0077007755555660f88ff58b55655a95558058056c0c63f3055555f5cbbee888
4f4fff4b1118888c0dd8dddd8888800888887888444414141414141414bbbbbb0077007755555d6053ff55885665a9a55508508565c563330055555fbbbb888c
44444444111888880d86666d8888888888888888ba414141414141414bbabbbb0700770066667d60fff5555566555555550050056565655d3a0555555cbbcccc
44bbbb440000000000000000e2e2e2e2e2e2e2e2bbb44444444444444bbbbbab070077007700770000000000000000000000000000000000b300000000000000
9994e4e05555777700991991555507775a5bbbbb0555777700551111000000003b88b3300f0000ff000000000000000000000000000000000000000077000000
99de490055557777190099195555077755b55abb055577770500111199ddd99938783b0900ff0f00000000000000000000004440000000000000000077700000
9dd49404555577779919009955557077b55bbbbb05557777055500119ddddd99b88b309900ffff44440000000000000000044f44000000000000000077770000
ddde490ee4e4e4e09199190055557077bb55abab0555777705551100ddddddd988b30dd9000f4fffff44000000000000004444f4440000000000000077700000
9dd490944949400e1991991977775505a55bbbbb07775555011155559ddddddd78d0dddd00f004444fff4000040000000004444f444000000000000077000000
99de404ee490049499199199777755054bbbbbbb077755550111555599ddddd98b0dddd900000000044ff4444f44400000004444f44440000000000000000000
999409444009494e919919917777555044abbbab077755550111555500000d99b000000000f0000000044ffffffff40000000444444444405000000000000000
999e0e4e04e4e4e41991991977775550b4bbbbbb07775555011155552220200900020222000000000044fff44444ff400000000444444444d500000000000000
9199199191991991babbbbab4495144100000000555577770000004444000000000000000000000004ff444ff0004f400000000004444455dd50000005555599
1991991919919919bbbb3bbb145755445555111155557777005705044055555550770077000000004ff40004f4004f400000000000444f555d55000005550059
9914449199222222bb3bbbbb557754495555111155557777775665000556606655007700000000004f400004f4004f40000000000000465555d5500005550659
91944222222dddd5bbbbbabb77757541555511115555777777566500056600065e507700000000044f400004f4004f4000000000000065655555550005550059
199422dddddddd57bbbbbbb355577549111155555777555500766070056600066e5ee0770000f004040000004f404f400000000600666656555555500555065d
99192ddddddddd573abbbbbb77777549111155555777555500660070056666666ee5e077000000f44f400004f4004f4000000000666666656555550005550059
91992dddddddddd5bbb3babb77777541111155555777555577007700056666676ee5e700000f0f004f400004f4004f4000000000666666665655500005550659
19912ddddddddd57babbbbbb77555449111155555777555577007700056667766eee570000f0ff004ff4444ff404ff4000000000676666665565000005555599
91992ddddddddd57bb3bbbb35555e441007700770077007700770077056766666eee507700ff4000444ffff4004ff400bbbbbbbb067666666660000000005000
19912ddddddddd55abbbbbbb5eee5559007700770077007700770076056665665ee70077ff4f400000044f40004f4000bf4444bb067666766660000066665660
99192dddddddddd5bbbab3bb755577597700770007007700770077060556666655007700004ff40000000400004f40004ff4444b006776776660000066665660
91992dddddddddd5b3bbbbba7777775177007700070077007700770607555555570077000004ff400000000044ff400044ff444b00066777776000006ccc5660
19912dddddddddd5bbbbbbbb77777759007700770077007700770076007700770077007700004ff440000000fff40000bbbbbbbb00000667776000006ccc56d0
9914222dddddddd5bbabbbbb777775590077007700770077007700760077007700770077000004fff4444444ff400000bffffffb000000066760000066665d60
9194422222222222b3bbb3b357575541770077000700770077007706070077007700770000000044ffffffff4400000044ffff44000000006600000066667660
1991991919919919bbabbbbb454544197700770007007700770077000700770077007700000000004444444400000000444ff44b000000000000000077007700
000000fd00000000d5600556565005650077007700000000000000000555555944344434443447a7000000000888800000000000000000000000000000005000
00666f0d00666600d8888185d888818500770077007700776d5dd5d606660059b4434377444343740011110800111f0000555600006566000000000066665660
066ff1fd0666f6600d8599100d85991077007700770077006dddddd666668a594b344b3a343434340111111801111cf006556560065664f055500000cccc5660
06fffffd06ffff6008d9598008d9598077007700770077006dddddd66666005943444bb3437344430114111801111ff00565565005655ff057500000cccc5660
066ffffd06ffff6008d9998008d99980007700770077007766dddd666665a85d7a3a7444443a74341144111801144ff00666566005556ff058500000cccc5660
066ff1fd0f1ff1f00d888f100d888f100077007700770077066666676655005973474444474343440fcffcf001114cf0064ff460055664f059500000cccc5d60
00666f0df0ffff0fd8888185d88881857700770077007700770077000555a85944343444a734443400ffff0000111f0000ffff00006566005b50000066667d60
000000fdddddddddd550055656500656770077007700770077007700055555594443434433444443000000000000100000000000000000005550000077007700
5565555555655555bb655555b5555564555655ab5565555400000000000000000000000000000000000000000000000000000000000000000000000000000000
555555555555655555556555555565445555500b55556544050000000e8e8e8e8000000004400000000000000000000000000000000000567000000000000000
6556556555565555bb565555b55555545555000b555655550550000008e00008e800000000440000000000000000000000000000000055567000000000000000
5555555565555555b5555555555655445550000065554545055500008e8000000e8e800000044000000000000000000000000000000555570000000000000000
556555555555555555555555b55555545600000b555555540055500888e8e8e8e8e8e80000004400000000000000000000000000005555670000000000000000
5555556555555565bbb55565b55565545550000055555544000555668e8e8e8e8e88880000000440000000000000000000000000005556670000000000000000
5555565555555555b5555555bb555545565550505555554400005555688888888888880000000044000000000000000000000000055556700000000700000000
6555555565565555bb5655550bbb5554555555556556554400005556888888888855580000000004400000000000000000000000055556700000077700000000
44484441919919910199199191991990000000009199199100065568888888888855880000000000440000000000000000000000055557000007766500000000
44888444199199190991991919919910199199191991991900065685555588888558880000000000044000000000000000000000555567007776665000000000
48886845991991990919919999199190991991999919919900066888855588888588880000000000004400000000000000000000555670776655555000000000
88868881919919910199199191991990919919919199199100848888885558885588880000000000000440000000000000000000055666666555550000000000
48688845199199190991991919919910199199191991991900484888888555855588880000000000000044000000000000848484840066555555500000000000
44888445991991990919919999199190991991999919919900848888888855555888880000000000000004400000550008484848440055555550000000000000
54581554919919910199199191991990919919919199199100484888888885558888880000000000000000444445550004848484844455555000000000000000
00000000199199190991991919919910199199190000000000848888888855558888880000000000000000444555050008484800084800000000000000000000
babbbbab0199199100000000000000002222222144991441004848888885558558888800bbabbbbb00000445550505000484000004840000000000555bbbbb50
bbbb3bbb0991991909919919199199192ddddd5555559444008488888855588855588800b848484b000005550505000008400000084800000000005b5555555b
bb3bbb880919919909199199488444492dddd57777775449004848888555888885558800b4848777000555050500000000000000848400000000000bb555b55b
bbbbb8780199199101991991455444442dddd577777754410084888855588888888888004888888705550505000000000000000048480000000000abbbbbbbbb
bbbbb8830991991909919919444444542dddd557777554490048485555888888888880004888888b0505050000000000000000048484000000000abbbbbbeeb0
3a88bbb70919919909199199a4444455d2d5d25555575449008488888888888888880000abb00abb050500000000000000000008484800000000abbbbbbb0eee
bb878a8801991991019919914a444451d55757577775544100484888888888880000000000b04bab050000000000000000000004848000000000bbbbb00000e0
bab88b87000000000991991944444415577775755557744900000000000000000000000000004bbb00000000000000000000000000000000000abbbbbf008000
b5bb5bb55b6b5bbbb5b5bb5b5555555557777757777774410577757755557777555577775555777755557777008800000990008800000000000b3bbbbff08800
5bb5b5b55bb555555555555555555555557777757777744905555555555577775555777755557777555577770088800099900888990000000000a3bbbfff8800
6556556565565b65655655656556556555777775777774490ddddddddddddddddddddddddddddddddddddddd400880f0990008809990000000000b3bbbb08800
5555555555555555455555555555555557577757777774410666544455ffffff55555553550050056666655df0000400f0000f000990f000000000b3bbbb0000
5565555555655555556555555565555557757757777774490566655555f5ffff55555333555055056606655d09900000400000f000f004000000000a3bbbb000
55455564455545654555446555545465d5775577777774490055555555f5ffff555553b3550550556565655d09990000099f00000400088000000ab3b33bb000
4544475555554645455444455445564422552227777774413a05555555ffffff55555333550050056565655d00990000999040000000088800ab3a3b3b3bb000
45444a744445455444444444455445541991922245454419b300000000000000000000000000000000000000000000009900000000000088bb33b3b333330000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000044000000000000000005000000000000000000000000000000000000000000050000
000000600006666666660000003333300000000000000000000000000004f40000000000000000555000000000000000000000000000000000fffff000050000
000006600066600000666000003333333000000000000000000000444000f4400000000000000555550000000000000000000000ffffffffff66666f00050000
0000606006600000000066000033335333000000000000000000004f4000ff000000000000007755555000000000000000ffffff555555555ff666f000500000
0006066006000000000006000003335353300000000000000000004f40044f40000000000005758ee5550000000000000f66ff555555555555ff6f0000050000
0060606006600000000066000000353353530000bb0000000000004f404f4f4000000440005555e80e555000000000000f6666fffffffffffffff00000005000
06666556066ccccccccc660000005335535333bbbb000000000400ff44ff4ff000000f40005555e00e55550000000000f6666666ffaacccbbbb2f00000050000
0000066566666666666666000000035333533bbbbb000000004f44ff4ff404f400004f400055555eee55555000000007ff6666666faaaccbbb22f00000500000
00000065556667776777660000000533553bbb5bbb000000004ff0f4ff4044ff4404f4000055555555555555000000000ff666666faaaccbb222f00000050000
0000000655566777677776000000000533355555550000000004ff4ff4004f4ff444f40000655555555555550000000000fff66fffaaaccb9222f00000050000
0000000655566675aa5776000000000003bb555665555500004444ff4f44f404fffff40000666555555558555000000000f5ffff5f8aaac9992ef00000050000
000000005556667aaaa77600000000000bbb56656666665004fffff44fffff404004ff4000066655555588555500000000f555ff5f88aa99999ef00000050000
0000000065566775aa566600000000000bbb5666500006504ff44440044444f4444f440000006665555cc55955a0000000f555555f888999999ef00000050000
000000000656677a55a7660000000000bbbb5506655004504f4004f444004ff4fff4000000000066655c55555a55000000f555555f8889999991f00000555000
0000000006666777777776000000000000b0550066500650044004fff4004f44f44000000000000665555b555555500000f555555f1119999911f00000999000
00000000066666666366660000000000000065500645064000000044f4004fff40000000000000006655555aa555000000f555555f1111111111f00000444000
0000000006666bb66366660000000000000066500665045000000004f4444ff40000000000000000666655aa5550000000f555555f1111111111f0000049f000
000000000666666b366bb6000000000000000650004506500000000f4ffff4f400000000000000000066655a5500000000f555555f1111111111f000004f4000
000000000666666663b666000000000000000455004506000000004f4f44f0f40000000000000000000666555000000000ff55555f7575571111f00000f9f000
000000000066666636666000000000000000006500650000000004f44f4044f400000000000000000000666500000000000fff555f7575571111f000004ff000
00000000000666666666000000000000000000640064000000000040ff4004f40000000000000000000000000000000000000fffff7575571ffff00000ff4000
00000000000000000000000000000000000000600000000000000000f4000040000000000000000000000000000000000000000ffffffffff000000000000000
00000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
c0c000ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000c0c00000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070405060505828184a9040705051200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07a0481d1d470f81b3b3b0b1b2b2441200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
070e202121221f83101010101010131200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
075f0c0c0c0c4085105758767556131200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
070d192324181f83106768646639131200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
070d293334280c2d2d2da294429494a300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
072f2c2c2c2c2c2c2c4391919150515300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0714552c2c2c2c46542e92919160616300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07b6b7b8b9ba4132313fa1959595959000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0762625252625252525204040415161700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0452625262526262625204070725262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
045252626252625252526c300735363700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008b8ba0a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000a0a0a0a0a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000000000307005070080700a0700c0701007012070150701707015070110700e070000000000000000000000000000000130700507011070050700f070060700a07003070080700207004070020700000000000
000500072a0701d0702a0701d5702b0701e070297701d500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000060207005070071700417006370034700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003a40000000000000000000000
002800180c57210570135700c57210570135700c57210570135700c57210570135701157215570185701157215570185701d57221570185701c5701a57018570107000e4000c4000c4000e400104001820018200
012d00180c7150f722137420c7150f722137420b7750f772137720b7750f775137720a7550e752137520a7550e752130520a7750e772137520a0550e772137720200402004020040200402004020040200402004
010d000000000290722b0722d0722d0422510023100211002110022100221001f2001e2001e2001e2001d2001d2001d2001b3001c3001c3001c3001c3001a4001a400194001a4001850017500175000000000000
013c0003120450c0450f0450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000074700e47012470134700f470093700837006360043600335002340013200131001310023000230002300013000130000000000000000000000000000000000000000000000000000000000000000000
0005000005640046600467005660086500a6300e6300e6200c6200b63009640066500766007660086600b6600e6500f640106300f6300f6300d64009650096600367001670000000000000000000000000000000
00060000171701a1701e160221702317016120061500614006140061000617006170061700000000000000002e3002e3002e30000000000000000000000000000000000000000000000000000000000000000000
002800180c07513075130750c07513075130750c07513075130750c07513075130751107518075180751107518075180751107518075180751107511075110751100011000110001100011000110001100011000
012d0018240751f7741f774240751f7741f774230751f7741f774230751f7741f774220751f7741f774227751f7741f7742e7752b7742b7742e7752b7742b7740600006000060000600000000000000000000000
0003000018130131600e1701c17019000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002177023770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001f7701d7701f7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000004330073200932007300033000830004310073200932008300272002420021200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00001c0701807017070190701c070200702507029070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000000100162002610056100761008620096200b6200e630106301163014630156401664017650196401b6401d6501e6501f66020670236702467026670286702a6702c6702e67032670366703b6703e670
000a00000000001220032100323003250032600127001260012500123001270012700127001270012000d7000c7000c7000c7000c7000c7000c7000c700000000a70009700097000000006700000000570004700
010a00000c6440c6400c6450c20500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000122700c2700f2000f20500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001364413640136451320500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01320000137701377013770137001177011770117701170014770147701477014700137701377013770137060c7000f700137001a7001a7001a7001a7001a7051860018600186001860018600186000060000600
013200000c7700c7700c7700c770167701677016770167700e7700e7700e7700e7700c7700c7700c7700c77600006000060000600006000060000600006000060000600006000060000600006000060000600000
003200001b7751b7751b7751b7751a7751a7751a7751a7751a7751a7751a7751a7751b7751b7751b7751b7750f1650f1550f1450f1350f1250f1150f1150f1150000000000000000000000000000000000000000
011000000c27010200132700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700001e2701f2701f2701e27000000000000000011200112001220012200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700001727016270172701727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
03 0d 03 0a 44
03 0e 04 0b 44
00 18 19 1a 44
00 15 42 17 44
00 41 42 43 44
00 41 42 43 44
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
00 04 00 00 00
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
00 41 42 43 44
