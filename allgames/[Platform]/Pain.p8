pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--pAIN
--dOCTEUR_rATON
-->8
-- gLOBAL VARIABLES

g_boss3spawning=false
g_circleAnglePrevious=0
g_instsToDel={}
g_kJump	=4
g_level	=0
g_radiusPrevious=0
g_screenShake=0
g_t=0
g_walls={4,27,28,29,34,37,38,43,44,45,46,47,50,51,52,53,54,59,61,62,63}
-->8
-- iNSTANCES

-- @__call gets an array containing all the instances of an object
g_insts={
	setMetatable=function()
		setmetatable(g_insts,{
			__call=function(tbl,obj)
				local insts={}
				foreach(tbl,function(inst)
					if inst.obj==obj then
						add(insts,inst)
					else
						for par in all(inst.par) do
							if par==obj then
								add(insts,inst)
								break
							end
						end
					end
				end)

				return insts
			end

			})
	end
}

g_create={
bbox=function(x,y,w,h,bboxOffsetX,bboxOffsetY)
	return {
		x=x,
		y=y,
		width=w,
		height=h,
		bboxOffsetX=bboxOffsetX,
		bboxOffsetY=bboxOffsetY,

		-- @bboxLeft and @bboxTop are also coordinates for the bounding box
		--[[ it's necessary to assign each variable a value individually
			 because the multiple results don't work in a table construct
			 ]]
		bboxLeft=boundarySet(	x,bboxOffsetX,0),
		bboxTop=boundarySet(	y,bboxOffsetY,0),

		bboxRight=boundarySet(	x,bboxOffsetX,w-1),
		bboxBottom=boundarySet(	y,bboxOffsetY,h-1)
	}

	end,

-- enemy child
bigTree=function(x,y)
	return makeChild(
		{
			draw=function(self)
				spr(19,self.x,self.y,2,2)

				end,

			update=function(self)
				if(isOnScreen(self.x,self.width))self.x-=0.5
				instBboxUpdate(self)

				self:checkDamage()

				end,
		},"enemy",x,y,16,16,0,0,2)

	end,

-- bbox child
block=function(x,y,w,h,bboxOffsetX,bboxOffsetY)
	return g_create.bbox(x,y,w,h,bboxOffsetX,bboxOffsetY)

	end,

-- bbox chilc
boss=function(x,y)
	local w,h=32,32
	return makeChild(
		{
			spawnX=spawnX,
			spawnY=spawnY,
			regenerationTimer=0,


			drawHealthBar=function(self)
				camera()

				local h=4
				local offsetX,offsetY=2,2
				local w=lerp(0,127-offsetX*2,self.health/self.healthMax)
				local barBottom=127-offsetY

				local healthProportion=self.health/self.healthMax
				local color=8+healthProportion*4

				rectfill(offsetX,barBottom,offsetX+w,barBottom-h,color)

				setCamera()

				end,

			init=function(self)
				g_player.spd=0
				g_player.spawnX=g_player.x
				g_player.spawnY=0

				end
		},"enemy",x,y,w,h,0,0,50)

	end,

-- boss child
boss1=function()
	local w,h=32,32
	return makeChild(
		{
			dying=false,
			introDone=false,


			atk=cocreate(function(self)
				local endFrame=g_t
				while true do
					local targetY=self.spawnY+sin(endFrame/100)*40
					while abs(self.y-targetY)>2 do
						self.y=lerp(self.y,targetY,0.1)
						yield()
					end
					local framesDifference=g_t-endFrame
					for i=0,150 do
						self.y=self.spawnY+sin((g_t-framesDifference)/100)*40
						if g_t%40==0 then
							g_create("tree",self.x,self.y+self.width/2)
						end
						yield()
					end

					for i=0,4 do
						while abs(self.x-self.spawnX-24)>6 do
							self.x=lerp(self.x,self.spawnX+24,(abs(self.x-self.spawnX-24)/1024)^0.7)
							yield()
						end

						local vX=-1
						while g_player.x-self.x<4 do
							vX*=1.125
							self.x=max(self.x+vX,g_player.x-8)
							yield()
						end
						g_screenShake=max(g_screenShake,10)
						for i=0,5 do
							yield()
						end

						local destination=g_player.y+g_player.height/2-self.height/2
						while abs(self.x-self.spawnX)>4 do
							self.x=lerp(self.x,self.spawnX,0.2)
							self.y=lerp(self.y,destination,0.1)
							yield()
						end
					end
					endFrame=g_t
				end

				end),

			checkDamage=function(self)
				collidingInst=isInstAndObjColliding(self,"bullet")
				if collidingInst then
					instDel(collidingInst)
					self.health-=1
					g_create("leave",lerp(self.x,self.x+self.width,rnd()),
						self.y,rnd(2)-1,-4)
				end

				if self.health<1 or g_player.x-self.x>64 then
					self.dying=true
				end

				end,

			draw=function(self)
				spr(23,self.x,self.y,4,4)

				if self.dying then
					coresume(self.suffer,self)
				end

				end,

			intro=cocreate(function(self)
				--[[ those are not the actual spawn coordinates, but it
					makes it easier ]]
				self.spawnX=g_player.x+112-w
				self.spawnY=64-h/2
				while (self.x-g_player.x<80) do
					self.x+=2
					self.y+=2
					yield()
				end
				self.introDone=true

				end),

			suffer=cocreate(function(self)
					while self.y<128 do
						spr(66,self.x+self.width/4,self.y+self.height/4,2,2)
						self.y+=2
						self.x-=1
						yield()
						spr(68,self.x+self.width/4,self.y+self.height/4,2,2)
						self.y+=2
						self.x-=1
						yield()
						spr(75,self.x+self.width/4,self.y+self.height/4,2,2)
						self.y+=2
						self.x-=1
						yield()
						spr(77,self.x+self.width/4,self.y+self.height/4,2,2)
						self.y+=2
						self.x-=1
						yield()
					end

					loadLevel2()

				end),

			update=function(self)
				self.regenerationTimer=max(self.regenerationTimer-1,0)

				if not self.introDone then
					coresume(self.intro,self)

				elseif not self.dying then
					coresume(self.atk,self)
				end

				instBboxUpdate(self)

				self:checkDamage()

				end
		},"boss",g_player.x,-48)

	end,

-- boss child
boss2=function()
	local w,h=32,32

	return makeChild(
		{
			dying=false,
			seagulls=0,


			atk=cocreate(function(self)
				while true do
					local projectile=g_create("shuriken",self.spawnX-cos(0.2)*40-24,self.spawnY)
					for i=0,300 do
						self.y=projectile.y-self.height/2
						yield()
					end
					instDel(projectile)

					self:createSeagull()

					local directionX=true
					local directionY=true
					for i=0,300 do
						if directionX then
							self.x+=2
						else
							self.x-=2
						end
						if directionY then
							self.y+=2
						else
							self.y-=2
						end
						if self.x+self.width-g_player.x>120 then
							directionX=false
						elseif self.x-g_player.x<64 then
							directionX=true
						end
						if self.y+self.height>112 then
							directionY=false
						elseif self.y<16 then
							directionY=true
						end
						if i%30==0 then
							g_create("flag",self.x-8,self.y+self.height/2)
						end
						yield()
					end
					self.x=self.spawnX

					self:createSeagull()

					local projectiles={}

					for i=0,300 do
						if (#projectiles<4) then
							add(projectiles,g_create("sun",self.x+64,
								lerp(0,120,i/3)))
						end
						self.y=abs(sin(g_t/100)*(128-self.height))
						if(self.y<10)g_screenShake=10
						yield()
					end
					foreach(projectiles,
						function(inst)
							instDel(inst)
						end)

					self:createSeagull()
				end

				end),

			checkDamage=function(self)
				collidingInst=isInstAndObjColliding(self,"bullet")
				if collidingInst then
					instDel(collidingInst)
					self.health-=1
					g_create("drop",lerp(self.x+10,self.x+self.width-3,rnd()),
						self.y+self.height)
				end

				if self.health<1 or g_player.x-self.x>64 then
					self:die()
				end

				end,

			createSeagull=function(self)
				if not g_insts("seagull")[1] then
					self.seagulls+=1
					g_create("seagull",self.x+64,8)
				end

				end,

			die=function(self)
				foreach(mergeTables(g_insts("shuriken"),g_insts("flag"),g_insts("sun")),
					function(inst)
						instDel(inst)
					end)
				self.dying=true

				end,

			draw=function(self)
				if self.dying then
					coresume(self.suffer,self)
				else
					spr(192,self.x,self.y,4,4)
				end

				end,

			suffer=cocreate(function(self)
				local vY=-4
				local offset=0
				while self.y<128 do
					self.y+=vY
					instBboxUpdate(self)
					vY+=0.25

					offset+=0.2
					sspr(0,97,16,32,self.x,self.y)
					sspr(16,97,16,32,self.x+16+offset,self.y)
					yield()
				end

				loadLevel3()

				end),

			update=function(self)
				self.regenerationTimer=max(self.regenerationTimer-1,0)

				if not self.dying then
					coresume(self.atk,self)
				end

				instBboxUpdate(self)

				self:checkDamage()

				end
		},"boss",g_player.x+112-w,64-h/2)

	end,

boss3=function()
	local w,h=32,32

	return makeChild(
		{
			circles={},
			dying=false,
			fadeIn=false,
			fadeinFrame=0,
			fadeOut=false,
			fadeOutFrame=0,
			fadeOutY=0,
			pig=false,
			spriteHeight=32,
			visible=true,
			_spr=196,



			atk=cocreate(
				function(self)
					while true do
						self:blockWaves()
						self:blockTarget()
						self:blockManual()
						self:blockPaterns()
					end
				end),

			blockPaterns=function(self)
				local farLeft=self.x+8+g_player.width+w

				local offsetY=0

				local makeBlock=function(x,y)
					g_create("evilBlock",farLeft+x*8,(y+offsetY)*8)
				end

				local makeBlocksLine=function(begin,finish,y)
					for i=begin,finish do
						makeBlock(i,y)
					end
				end

				local wait=function()
					for i=0,45 do
						yield()
					end

					local offsetYNew
					repeat
						offsetYNew=rnd(8)
					until abs(offsetYNew-offsetY)>2
					offsetY=offsetYNew
				end

				makeBlock(6,0)
				makeBlocksLine(0,7,1)
				makeBlocksLine(0,7,2)
				makeBlocksLine(1,7,3)
				makeBlocksLine(4,7,4)
				makeBlocksLine(5,7,5)
				makeBlocksLine(5,8,6)


				wait()

				makeBlocksLine(2,6,0)
				makeBlocksLine(0,7,1)
				makeBlocksLine(0,7,2)
				makeBlocksLine(0,7,3)
				makeBlocksLine(1,7,4)
				makeBlocksLine(3,6,5)
				makeBlock(5,6)
				makeBlock(6,7)

				wait()

				makeBlocksLine(0,2,0)
				makeBlocksLine(4,6,0)
				makeBlock(0,2)
				makeBlocksLine(2,4,2)
				makeBlocksLine(6,7,2)
				makeBlocksLine(0,2,4)
				makeBlocksLine(4,6,4)
				makeBlock(0,6)
				makeBlocksLine(2,4,6)
				makeBlocksLine(6,7,6)

				wait()

				makeBlock(3,0)
				makeBlock(5,0)
				makeBlocksLine(3,6,1)
				makeBlocksLine(2,3,2)
				makeBlock(5,2)
				makeBlocksLine(3,5,3)
				makeBlock(3,4)
				makeBlocksLine(5,6,4)
				makeBlocksLine(2,5,5)
				makeBlock(3,6)
				makeBlock(5,6)

				wait()

				makeBlocksLine(2,5,1)
				makeBlock(1,2)
				makeBlocksLine(5,6,2)
				makeBlock(0,3)
				makeBlocksLine(5,7,3)
				makeBlock(0,4)
				makeBlock(7,4)
				makeBlocksLine(1,7,5)
				makeBlocksLine(1,2,6)
				makeBlocksLine(5,6,6)

				wait()

				end,

			blockWaves=function(self)
				local randomPrevious=0
				for i=0,4 do
					local random
					repeat
						random=rnd()
					until abs(random-randomPrevious)>0.2
					local y=lerp(0,119,random)

					self.visible=false

					self.fadeOut=true
					self.fadeOutFrame=g_t
					self.fadeOutY=self.y

					self.y=y-self.height/2+4

					for i=0,6 do
						yield()
					end

					self.visible=true
					self.fadeOut=false

					self.fadeIn=true
					self.fadeInFrame=g_t

					for i=0,7 do
						g_create("waveBlock",127,y-8)

						for j=0,5 do
							yield()
						end
					end

					randomPrevious=random
				end

				self.visible=false

				self.fadeOut=true
				self.fadeOutFrame=g_t
				self.fadeOutY=self.y

				self.y=63-self.height/2

				for i=0,6 do
					yield()
				end

				self.visible=true
				self.fadeOut=false

				self.fadeIn=true
				self.fadeInFrame=g_t

				end,

			blockTarget=function(self)
				for i=0,10 do
					g_create("targetBlock",self.x-8,self.y)

					for i=0,30 do
						yield()
					end
				end

				end,

			blockManual=function(self)
				local function teleport(y)
					self.visible=false

					self.fadeOut=true
					self.fadeOutFrame=g_t
					self.fadeOutY=self.y

					self.y=y-self.height/2+4

					for i=0,10 do
						yield()
					end

					self.visible=true
					self.fadeOut=false

					self.fadeIn=true
					self.fadeInFrame=g_t
				end

				for i=0,4 do
					local blocks={}

					teleport(32)

					for i=0,4 do
						blocks[i+1]=g_create("manualBlock",self.x-8,i*(120/9))
						for i=0,2 do
							yield()
						end
					end

					for block in all(blocks) do
						block.activated=true
					end

					teleport(96)

					for i=5,9 do
						blocks[i+1]=g_create("manualBlock",self.x-8,i*(120/9))
						for i=0,2 do
							yield()
						end
					end

					for block in all(blocks) do
						block.activated=true
					end
				end

				teleport(63-self.height/2)

				end,

			die=function(self)
				-- self:goPig()
				self.dying=true

				foreach(g_insts("evilBlock"),
					function(inst)
						instDel(inst)
					end)

				end,

			update=function(self)
				if not self.pig then
					if self.dying then
						coresume(self.suffer,self)
					else
						coresume(self.atk,self)

						instBboxUpdate(self)

						self.regenerationTimer=max(self.regenerationTimer-1,0)

						self:checkDamage()
					end
				end

				end,

			draw=function(self)
				if self.pig then
					spr(90,self.x,self.y)

					coresume(self.drawText,self)
				else
					if self.fadeOut then
						local w=32/(g_t-self.fadeOutFrame+1)
						sspr(32,96,32,32,self.x+(32-w)/2,self.fadeOutY,w,32)
					end
					if self.visible then
						if self.fadeIn then
							local w=lerp(0,32,(g_t-self.fadeInFrame)/3)
							sspr(32,96,32,32,self.x+(32-w)/2,self.y,w,32)

							if g_t-self.fadeInFrame>2 then
								self.fadeIn=false
							end
						else
							-- spr(196,self.x,self.y,4,4)
							sspr(32,96,32,32,self.x,self.y+(32
								-self.spriteHeight)/2,32,self.spriteHeight)
						end
					end

					if self.dying then
						if g_t%7==0 then
							add(self.circles,0.1)
						end

						for circle in all(self.circles) do
							circ(
								self.x+self.width/2,
								self.y+(32-self.spriteHeight)/2,
								circle,
								7
							)
						end
					end
				end

				end,

			drawText=cocreate(function(self)
				while true do
					music(-1,300)

					while printText do
						stop("...")
						stop("i WONDER WHAT THAT FIRST SPRITE IS SUPPOSED TO BE") -- 🤔
						while true do
							stop("...")
							stop("dON'T YOU HAVE ANYTHING BETTER  TO DO?")
						end
					end

					for i=0,60 do
						yield()
					end

					printText=function(textToPrint)
						for i=0,10 do
							cursor(57,64,7)
							print(textToPrint)
							yield()
						end
					end

					sfx(38)

					local text="p"

					printText(text)

					text=text.."a"

					printText(text)

					text=text.."i"

					printText(text)

					text=text.."n"

					for i=0,3 do
						printText(text)
					end

					stop()
					yield()

				end

				end),

			goPig=function(self)
				g_player.spd=-2

				self.pig=true
				self.x+=self.width/2-4
				self.y+=self.height/2-4

				end,

			suffer=cocreate(function(self)
				for i=0,90 do
					g_screenShake=30

					self.spriteHeight=max(self.spriteHeight*0.97,0)

					for index in pairs(self.circles) do
						self.circles[index]*=1.5
					end

					yield()
				end

				self:goPig()

				end)
		},"boss",g_player.x+112-w,64-h/2)

	end,

bottle=function(x,y)
	return makeChild(
		{
			draw=function(self)
				spr(79,self.x,self.y)

				end,

			update=function(self)
				if isOnScreen(self.x,self.width) then
					self.x-=2
				else
					instDel(self)
				end
				instBboxUpdate(self)

				end,
		},"enemy",x,y,2,4,3,2,100)

	end,

-- bbox child
bullet=function(x,y)
	return makeChild(
		{
			sprIdx=-5,

			draw=function(self)
				if not (g_insts("boss3")[1] or {}).pig then
					self.sprIdx+=1
					spr(7+mid(0,self.sprIdx,6),self.x,self.y)
				end
			end,

			update=function(self)
				self.x+=7

				if(self.x-g_player.x>120)instDel(self)

				instBboxUpdate(self)
			end
		},"bbox",x,y,8,8,0,0)

	end,


-- bbox child
customs=function(x,y)
	return makeChild(
		{
			bullets=0,
			hasAccepted=false,
			x=x,
			y=y,


			accept=function(self)
				g_player.spawnX=self.bboxLeft-g_player.bboxOffsetX

				-- +1 because of the way @bboxBottom and @bboxRight work
				g_player.spawnY=self.bboxBottom-g_player.height
					-g_player.bboxOffsetY+1

				self.width=16
				self.height=15
				self.bboxOffsetX=0
				self.bboxOffsetY=1

				instBboxUpdate(self)

				end,

			draw=function(self)
				palt(0,false)
				palt(3,true)

				local idx=14

				if not self.hasAccepted then
					--[[ can not use foreach() because it is not possible to break out of
						 it]]
					for bullet in all(g_insts("bullet")) do
						--[[ dividing the dist on each axis prevents overflow when
							 squaring ]]
						if ((self.x-bullet.x)/64)^2+((self.y-bullet.y)/64)^2<0.25 then
							idx=32
							break
						end
					end
				end

				spr(idx,self.x,self.y,2,2)

				if self.hasAccepted then
					local y=self.y+10
					line(self.x+1,y,self.x+2,y,8)
					line(self.x+9,y,self.x+10,y,8)
				end

				palt()

				end,

			update=function(self)
				local collidingInst=isRectAndObjColliding(self.bboxLeft,
					self.bboxBottom-16,self.bboxRight,self.bboxBottom,"bullet")

				if collidingInst and ((self.x-g_player.x)/64)^2+((self.y-g_player.y)/64)^2<2.5 then
					self.bullets+=1
					if self.bullets>7 and not self.hasAccepted then
						self:accept()

						self.hasAccepted=true
					elseif not self.hasAccepted then
						instDel(collidingInst)
					end
				end

				end
		},"block",x,y,16+16,128,0-16,15-127)

	end,

drop=function(x,y)
	return {
		x=x,
		y=y,
		vY=0,

		draw=function(self)
			pset(self.x,self.y,13)
		end,

		update=function(self)
			self.y+=self.vY
			self.vY+=0.5

			if(self.vY>5)instDel(self)
		end
	}

	end,

enemy=function(x,y,w,h,bboxOffsetX,bboxOffsetY,health)
	return makeChild(
		{
			dead=false,
			health=health,
			healthMax=health,
			spawnX=x,
			spawnY=y,

			checkDamage=function(self)
				collidingInst=isInstAndObjColliding(self,"bullet")
				if collidingInst then
					instDel(collidingInst)
					self.health-=1
				end

				if self.health<1 or g_player.x-self.x>64 then
					self:die()
				end

				end,

			die=function(self)
				self.dead=true
				self.health=self.healthMax
				self.y=256
				instBboxUpdate(self)

				end
		},"bbox",x,y,w,h,bboxOffsetX,bboxOffsetY)

	end,

evilBlock=function(x,y)
	return makeChild({
		instTime=0,
		_spr=g_walls[flr(rnd(#g_walls))+1],



		draw=function(self)
			spr(self._spr,self.x,self.y)

			end,

		update=function(self)
			self.instTime+=1
			self.x-=3

			if g_player.x-self.x>16 then
				instDel(self)
			end

			instBboxUpdate(self)

			end
	},"enemy",x,y,8,8,0,0,100)

	end,

waveBlock=function(x,y)
	return makeChild({
		update=function(self)
			self.instTime+=1

			self.x-=3
			self.y=self.spawnY+sin((self.instTime-2)/32)*12

			if g_player.x-self.x>16 then
				instDel(self)
			end

			instBboxUpdate(self)

			end
	},"evilBlock",x,y)

	end,

fishbone=function(x,y)
	return makeChild(
		{
			spawnY=y+20,


			draw=function(self)
				spr(86,self.x,self.y)

				end,

			update=function(self)
				if isOnScreen(self.x,self.width) then
					self.x-=1.5
					self.y=self.spawnY-abs(sin(g_t/40)*10)
				else
					instDel(self)
				end
				instBboxUpdate(self)

				end,
		},"enemy",x,y,2,4,3,2,100)

	end,

flag=function(x,y)
	return makeChild(
		{
			vX=0,


			draw=function(self)
				spr(88,self.x,self.y)

				end,

			update=function(self)
				self.vX-=0.2
				self.x+=self.vX

				if not isOnScreen(self.x,self.width) then
					instDel(self)
				end

				instBboxUpdate(self)

				end,
		},"enemy",x,y,2,4,3,2,100)

	end,

leave=function(x,y,vX,vY)
	return {
		x=x,
		y=y,
		size=2,
		vX=vX,
		vY=vY,


		draw=function(self)
			self.size*=0.5
			circfill(self.x,self.y,self.size,3)
		end,

		update=function(self)
			self.x+=self.vX
			self.y+=self.vY
			self.vX*=0.3
			self.vY*=0.3
			if self.size<0.1 then
				instDel(self)
			end
		end
	}

	end,

level1=function()
	return {
		bossCreated=false,

		update=function(self)
			if not self.bossCreated and g_player.x>128*8+g_player.width
				then

				self.bossCreated=true
				g_create("boss1")
			end

			end
	}

	end,

level2=function()
	return {
		bossCreated=false,

		update=function(self)
			if not self.bossCreated and g_player.x>128*8+g_player.width
				then

				self.bossCreated=true
				g_create("boss2")
			end

			end
	}

	end,

manualBlock=function(x,y)
	return makeChild({
		activated=false,
		vX=0,
		vY=0,


		target=cocreate(
			function(self)
				while not self.activated do
					yield()
				end

				local targetX=g_player.x
				local targetY=g_player.y
				local distance=sqrt((self.x-targetX)^2+(self.y-targetY)^2)

				local speed=0.1

				self.vX=(targetX-self.x)/distance*speed
				self.vY=(targetY-self.y)/distance*speed

				while true do
					if self.vX^2+self.vY^2<50 then
						local multiplier=1.2
						self.vX*=multiplier
						self.vY*=multiplier
					end
					yield()
				end

				return
			end),

		update=function(self)
			coresume(self.target,self)

			self.x+=self.vX
			self.y+=self.vY

			if g_player.x-self.x>16 then
				instDel(self)
			end

			instBboxUpdate(self)

			end
	},"evilBlock",x,y)

	end,

-- solid child
player=function()
	local spawnX,spawnY=8,32

	return makeChild(
		{
			-- whether or not the button was held down on the previous frame
			g_kJumpPrev=false,

			fricGround=0.5,
			gravJump=0.5,
			gravNormal=0.35,
			grounded=false,

			-- how many frames have passed since the player started holding
			jumpChargeFrames=0,

			jumpChargeFramesMax=24,
			jumpChargeVelMultiplier=-0.4,
			jumpVelMin=-0.025,
			shootFrequency=0,
			shootTimer=0,
			spawnX=spawnX,
			spawnY=spawnY,
			spd=1.5,
			spdDefault=1.5,
			switchFlicker=0,
			vX=0,
			vY=0,
			vMax=6,
			_spr=1,

			checkDeath=function(self)
				local collidingInst=isInstAndObjColliding(self,"enemy")
				if collidingInst and not (g_insts("boss3")[1] or {}).pig then
					if g_insts("boss")[1] and collidingInst
						~=g_insts("boss")[1] and collidingInst.obj~="shuriken"
						and collidingInst.obj~="sun" then

						instDel(collidingInst)
					end
					self:die()
				end

				if self.bboxTop>127 then
					self.y=0
					self.vY=max(self.vY,0)
					instBboxUpdate(self)
				end

				end,

			die=function(self)
				self.x=self.spawnX-self.bboxOffsetX
				self.y=self.spawnY-self.bboxOffsetY

				self.vX=0
				self.vY=0

				if g_insts("boss")[1] then
					local boss=g_insts("boss")[1]

					if boss.regenerationTimer<=0 then
						boss.health=min(boss.health+3,50)
						boss.regenerationTimer=30
					end
				else
					self.spd=self.spdDefault
				end

				self.jumpChargeFrames=0
				self.shootTimer=0

				if(not g_insts("boss")[1])resetLevel()

				end,

			draw=function(self)
				self:drawSpr()
				self:drawSwitch()

				end,

			drawSpr=function(self)
				palt(0,false)
				palt(2,true)
				spr(self._spr,self.x,self.y,2,2) -- sprite is two tiles wide and high
				palt()

				end,

			drawSwitch=function(self)
				if self.jumpChargeFrames==self.jumpChargeFramesMax then
					self.switchFlicker-=1
					if(self.switchFlicker<0)self.switchFlicker=3
					if(self.switchFlicker<2)pal(7,15)
				end

				if self._spr==1 then
					spr(16,self.x+13,self.y+lerp(4,9,self.jumpChargeFrames
						/self.jumpChargeFramesMax))
				else
					spr(16,self.x-5,self.y+lerp(4,9,self.jumpChargeFrames
						/self.jumpChargeFramesMax),1,1,true)
				end

				pal()
				
				end,

			chargeJump=function(self)
				if btn(g_kJump) then
					self.jumpChargeFrames=min(self.jumpChargeFrames+1,self.jumpChargeFramesMax)
				end

				end,

			joomp=function(self) -- mix between jump and shoot
				self:chargeJump()

				-- bypass the repeat mechanism of @btnp
				if not btn(g_kJump) and g_kJumpPrev then
					self:jump()
					self:shoot()

					if self.jumpChargeFrames<8 then
						self.shootTimer=0
						if g_level~=2 then
							sfx(37)
						end
					elseif self.jumpChargeFrames~=24 then
						-- 5*3-1 because the player shot once
						self.shootTimer=14
						self.shootFrequency=5
						if g_level~=2 then
							sfx(37)
						end
					else
						g_screenShake=max(g_screenShake,1)
						self.shootTimer=17
						self.shootFrequency=3
						if g_level~=2 then
							sfx(36)
						end
					end

					self.jumpChargeFrames=0
				else
					if self.shootTimer~=0 and self.shootTimer%self.shootFrequency==0 then
						self:shoot()
					end

					self.shootTimer=max(self.shootTimer-1,0)
				end

				end,

			jump=function(self)
				self.vY=self.jumpVelMin+self.jumpChargeFrames
					*self.jumpChargeVelMultiplier
				end,

			move=function(self)
				self:setGrounded()

				self:travel()

				self:stopOnCollision()

				self:stayInsideScreen()

				self:vApply()

				--[[ no need to update @grounded as it would be the same as the
					 first one (because the function uses velocity) ]]

				g_kJumpPrev=btn(g_kJump)
				end,

			shoot=function(self)
				g_create("bullet",self.x,self.y)
				end,

			stayInsideScreen=function(self)
				if self.y+self.vY<0 and self.y>0 then
					dirY=sgn(self.vY)

					-- prevents an infinite loop, not necessary
					while self.y+self.vY<0 do -- and sgn(self.vY)==dirY do
						self.vY-=dirY
					end
				elseif self.y<0 then
					if self.vY<0 then
						self.vY=0
					end
				end

				end,

			travel=function(self)
				self:travelX()

				self:travelY()

				instBboxUpdate(self)
				end,

			travelX=function(self)
				self.vX=self.spd
				end,

			travelY=function(self)
				if not self.grounded then
					--[[ function is called in two places with one argument in
						 common, but it uses less tokens ]]
					if self.vY<=0 then
						applyGrav(self,self.gravNormal)
					else
						applyGrav(self,self.gravJump)
					end
				end

				end,

			update=function(self)
				self:joomp()

				self:move()

				self:checkDeath()

				end,

			vReduce=function(self,fric)
				self.vX*=1-fric -- lerp to 0
				end
		},"solid",spawnX,spawnY,16,14,0,0)

	end,

seagull=function(x,y)
	return makeChild(
		{
			atk=cocreate(function(self)
				while true do
					for i=0,90 do
						yield()
					end
					if g_insts("boss").seagulls<4 then
						g_create("fishbone",self.x,self.y)
					end
					yield()
				end

				end),

			die=function(self)
				instDel(self)

				end,

			draw=function(self)
				spr(70,self.x,self.y)

				end,

			update=function(self)
				if (isOnScreen(self.x,self.width)) then
					coresume(self.atk,self)
				end

				-- if(isOnScreen(self.x,self.width) and self.x-g_player.x<96)self.x+=g_player.spdDefault
				if self.x-g_player.x>96 then
					self.x-=3
				end
				instBboxUpdate(self)

				self:checkDamage()

				end,
		},"enemy",x,y,8,8,0,0,2)

	end,

shuriken=function(x,y)
	return makeChild(
		{
			createFrame=g_t,
			instTime=0,


			draw=function(self)
				spr(87,self.x,self.y)

				end,

			update=function(self)
				self.instTime=g_t-self.createFrame

				if self.instTime<20 then
					self.x=self.spawnX-(cos(50/100))*40

					-- self.y-=sin(g_t/50)
					self.y=self.spawnY+sin(self.instTime/83)*20
				else
					self.x=self.spawnX-(cos((self.instTime+30)/100))*40

					self.y=self.spawnY+sin(self.instTime/83)*20


					instBboxUpdate(self)

				end

				end,
		},"enemy",x,y,4,4,2,2,100)

	end,

-- bbox child, object with collision
solid=function(x,y,w,h,bboxOffsetX,bboxOffsetY)
	return makeChild(
		{
			grounded=false,
			vX=0,
			vY=0,
			vMax=6,
			move=function(self)
				self:setGrounded()

				self:stopOnCollisionX()

				self:stopOnCollisionY()

				self:vApply()
				end,

			vApply=function(self)
				self.x+=self.vX
				self.y+=self.vY

				instBboxUpdate(self)
				end,

			setGrounded=function(self)
				--[[ needs to be done first because we can't break out or
					 return from a foreach ]]
				self.grounded=false

				foreach(g_insts("block"),
					function(block)
						if isInstsCollidingAtpos(self,block,self.bboxLeft,
							self.bboxTop+self.vY+1) then

							self.grounded=true
						end
					end)
				end,

			stopOnCollision=function(self)
				self:stopOnCollisionX()

				self:stopOnCollisionY()

				end,

			stopOnCollisionX=function(self)
				local direction=sgn(self.vX)

				for block in all(g_insts("block")) do
					--[[ a sprite drawn at x: 0 < x < 1 will always be the
						 same, whereas a collision check at that same spot
						 will be different because each point is different,
						 that's why I took the bboxTop "above" (so that
						 a collision may be detected when it doesn't occur,
						 but at least it is always detected) ]]
					if isInstsCollidingAtpos(self,block,int(self.bboxLeft
						+self.vX)+direction,self.bboxTop) then

						for i=int(self.vX)+direction,0,-direction do
							if not isInstsCollidingAtpos(self,block,self.bboxLeft+i-frac(self.x),self.bboxTop)
								then

								--[[ it makes more sense to align the
									 player with the block using frac
									 (block is always on round coords) ]]
								self.vX=i-frac(self.x)
								break
							end
							self.vX=0
						end
					end
				end

				if isInstAndTileFlagColliding(self,0,self.vX,0) then
					for i=int(self.vX)+direction,0,-direction do
						if not isInstAndTileFlagColliding(self,0,i-frac(self.x),0)
							then

							--[[ it makes more sense to align the
								 player with the block using frac
								 (block is always on round coords) ]]
							self.vX=i-frac(self.x)
							break
						end
						self.vX=0
					end
				end

				end,

			stopOnCollisionY=function(self)
				local direction=sgn(self.vY)

				for block in all(g_insts("block")) do
					if isInstsCollidingAtpos(self,
						block,self.bboxLeft+self.vX,int(self.bboxTop
						+self.vY)+direction) then

						for i=int(self.vY)+direction,0,-direction do

							--[[ for some reason the sprite goes slightly
								 inside the block when coming from bellow,
								 that's fixed by substracting the
								 fractional component of self.y when
								 checking for collision ]]
							if not isInstsCollidingAtpos(self,block,
								self.bboxLeft+self.vX,self.bboxTop+i
								-frac(self.y))then

								self.vY=i-frac(self.y)
								break
							end

							self.vY=0
						end

						if self.vY>0 then
							self.grounded=true
						end
					end
				end

				if isInstAndTileFlagColliding(self,0,self.vX+self.vX,self.vY+direction) then
					for i=int(self.vY)+direction,0,-direction do
						if not isInstAndTileFlagColliding(self,0,self.vX,i-frac(self.y))
							then

							--[[ it makes more sense to align the
								 player with the block using frac
								 (block is always on round coords) ]]
							self.vY=i-frac(self.y)
							break
						end
						self.vY=0
					end

					-- if self.vY>0 then
					-- 	self.grounded=true
					-- end
				end

				end,

			update=function(self)
				self:move()

				end
		},"bbox",x,y,w,h,bboxOffsetX,bboxOffsetY)

	end,

sun=function(x,y)
	return makeChild(
		{
			draw=function(self)
				spr(89,self.x,self.y)

				end,

			update=function(self)
				self.x-=2
				self.y+=1.5

				if g_player.x-self.x+self.width>16 then
					self.x=g_player.x+112
				end
				if self.y>128 then
					self.y=-self.height
					self.x=g_player.x+112
				end

				instBboxUpdate(self)

				end,
		},"enemy",x,y,4,4,2,2,100)

	end,

targetBlock=function(x,y)
	return makeChild({
		vX=0,
		vY=0,


		target=cocreate(
			function(self)
				for i=0,15 do
					yield()
				end

				local targetX=g_player.x
				local targetY=g_player.y
				local distance=sqrt((self.x-targetX)^2+(self.y-targetY)^2)

				local speed=0.1

				self.vX=(targetX-self.x)/distance*speed
				self.vY=(targetY-self.y)/distance*speed

				while true do
					if self.vX^2+self.vY^2<50 then
						local multiplier=1.2
						self.vX*=multiplier
						self.vY*=multiplier
					end
					yield()
				end

				return
			end),

		update=function(self)
			coresume(self.target,self)

			self.x+=self.vX
			self.y+=self.vY

			if g_player.x-self.x>16 then
				instDel(self)
			end

			instBboxUpdate(self)

			end
	},"evilBlock",x,y)

	end,

tortoise=function(x,y)
	return makeChild(
		{
			atk=cocreate(function(self)
				while true do
					for i=0,35 do
						yield()
					end
					g_create("bottle",self.x,self.y+self.height/2-4)
					yield()
				end

				end),

			draw=function(self)
				spr(64,self.x,self.y,2,2)

				end,

			update=function(self)
				if (isOnScreen(self.x,self.width)) then
					coresume(self.atk,self)
				end

				if(isOnScreen(self.x,self.width) and self.x-g_player.x<96)self.x+=g_player.spdDefault
				instBboxUpdate(self)

				self:checkDamage()

				end,
		},"enemy",x,y,16,16,0,0,5)

	end,

-- enemy child
tree=function(x,y)
	return makeChild(
		{
			die=function(self)
				instDel(self)
				
				end,

			draw=function(self)
				spr(3,self.x,self.y)

				end,

			update=function(self)
				self.x-=1
				instBboxUpdate(self)

				self:checkDamage()

				if not g_insts("boss1")[1] then self:die() end

				end,
		},"enemy",x,y,8,8,0,0,1)

	end,


setMetatable=function()
	--[[ if I don't want the object to be added to @g_insts, I can just use
		 g_create.bbox(props) instead of g_create("bbox", props) for
		 example ]]
	setmetatable(g_create,{
		__call=function(tbl,obj,...)
			inst=tbl[obj](...)

			inst.obj=obj

			addFill(g_insts,inst)

			if(inst.init)inst:init()

			return inst
		end
	})

	end

	}
-->8
-- cOLLISION DETECTION

-- return a point for bounding box
function boundarySet(coord,offset,lengthOffset)
	return coord+offset+lengthOffset
	end

function isInstAndObjColliding(inst,obj)
	-- prevent the instance from being checked too
	local insts=g_insts(obj)
	del(insts,inst)

	local inst2
	for inst2 in all(insts) do
		-- the ckeck can be done manually here to optimize for tokens
		if (isInstsColliding(inst,inst2)) return inst2
	end

	end

function isInstAndObjCollidingAtpos(inst,obj,x,y)
	foreach(g_insts(obj),function(inst2)
		-- if inst2.obj==obj and isInstsCollidingAtpos(inst,inst2,x,y) then
		if isInstsCollidingAtpos(inst,inst2,x,y) then
			return true
		end

		-- if inst2.obj==obj then
		-- 	local collidingInst=isInstsCollidingAtpos(inst,inst2,x,y)
		-- 	if collidingInst then
		-- 		return collidingInst
		-- 	end 
		-- end
	end)

	end

function isInstAndRectColliding(inst,left,top,right,bottom)
	return isRectsColliding(inst.bboxLeft,inst.bboxTop,inst.bboxRight,
		inst.bboxBottom,left,top,right,bottom)
	end

function isInstAndTileFlagColliding(inst,flag,vX,vY)
	local left		=(inst.bboxLeft+vX)/8
	local right		=(inst.bboxRight+vX)/8
	local middleX	=left+inst.width/16

	-- min prevents the game from checking in the next level
	local top		=min((inst.bboxTop+vY)		/8,	15)
	local bottom	=min((inst.bboxBottom+vY)	/8,	15)
	local middleY	=min(top+inst.height/16,		15)

	local levelY	=g_level*16

	return fget(mget(flr(left),		flr(top)	+levelY),flag)
		or fget(mget(flr(right),	flr(top)	+levelY),flag)
		or fget(mget(flr(left),		flr(bottom)	+levelY),flag)
		or fget(mget(flr(right),	flr(bottom)	+levelY),flag)

		-- middles
		or fget(mget(flr(middleX),	flr(top)	+levelY),flag)
		or fget(mget(flr(right),	flr(middleY)+levelY),flag)
		or fget(mget(flr(middleX),	flr(bottom)	+levelY),flag)
		or fget(mget(flr(left),		flr(middleY)+levelY),flag)

	end

function isInstsColliding(inst1,inst2)
	--[[ the bounding box already contains all the info on x, y, width,
		 height, bounding box offset, etc. ]]
	return isInstAndRectColliding(inst1,inst2.bboxLeft,inst2.bboxTop,
		inst2.bboxRight,inst2.bboxBottom)
	end

function isInstsCollidingAtpos(inst1,inst2,x,y)
	-- @inst1 is the one moving
	return isInstAndRectColliding(inst2,x,y,x+inst1.width-1,y+inst1.height-1)
	end

function isLinesColliding(min1, max1, min2, max2)
	return max1>=min2 and max2>=min1
	end

function isRectAndObjColliding(left,top,right,bottom,obj)
	for inst in all(g_insts(obj)) do
		if(isInstAndRectColliding(inst,left,top,right,bottom))return inst
	end

	end

function isRectsColliding(left1,top1,right1,bottom1,left2,top2,right2,
	bottom2)

	return isLinesColliding(left1,right1,left2,right2) and
		isLinesColliding(top1,bottom1,top2,bottom2)
	end
-->8
-- oTHER
-- SAMES AS @add EXECPT IT CREATES THE TABLE IF IT DOES NOT EXIST
	-- function table_val_add_val(tbl,val_tbl,val)
	-- 	tbl[val_tbl]=tbl[val_tbl] or {}
	-- 	add(tbl[val_tbl],val)
	-- end

function addFill(tbl,val)
	tbl[#tbl+1]=val

	end

function applyGrav(self,gravity)
	self.vY=min(self.vY+gravity,self.vMax)
	end

function asin(y)
	return atan2(sqrt(1-y*y),-y)

	end

function frac(float)
	return float-int(float)
	end

function instBboxUpdate(inst)
	local x=inst.x+inst.bboxOffsetX
	local y=inst.y+inst.bboxOffsetY
	inst.bboxLeft=		x
	inst.bboxTop=		y
	inst.bboxRight=		x+inst.width-1
	inst.bboxBottom=	y+inst.height-1
	end

function instantiateObjs(lvl)
	local objs={
		[14]="customs",
		[19]="bigTree",
		[64]="tortoise"
	}
	for i=0,127 do
		for j=0,15 do
			local tile=mget(i,j+lvl*16)

			if(objs[tile])g_create(objs[tile],i*8,j*8)
			if(tile==1)g_player.x=i*8 g_player.y=j*8
		end
	end

	end

function instDel(inst)
	add(g_instsToDel,inst)

	end

-- truncate fractional component of a number
function int(float)
	if (float>0) return flr(float)
	return ceil(float)
	end

function isOnScreen(x,w)
	return x+w>g_player.x-8 and x<g_player.x+120

	end

function lerp(a,b,c)
	return a+(b-a)*c
	end

function loadLevel1()
	g_player=g_create("player")
	instantiateObjs(0)
	g_create("level1")
	music(0)

	end

function loadLevel2()
	g_level=1

	for inst in all(g_insts) do
		if inst.obj~="player" then
			instDel(inst)
		end
	end

	g_player.x=-128
	g_player.spd=g_player.spdDefault
	g_player.spawnX=-128
	g_player.spawnY=32

	instantiateObjs(1)

	g_create("level2")

	end

function loadLevel3()
	g_level=2

	for inst in all(g_insts) do
		if inst.obj~="player" then
			instDel(inst)
		end
	end

	g_player.x=0
	g_player.spawnX=0
	g_player.spawnY=0
	g_player._spr=5

	g_create("boss3")

	g_boss3spawning=true

	music(15)

	end

function makeChild(childInst,parObj,...)
	-- add(childInst.par,parObj)
	childInst=mergeTables(g_create[parObj](...),childInst)
	if childInst.par~=nil then
		add(childInst.par,parObj)
	else
		childInst.par={parObj}
	end
	-- return mergeTables(g_create[parObj](...),childInst)
	return childInst

	end

-- create a table with the contents of all the argument tables
function mergeTables(...)
	local tbl={}
	foreach({...},function(tblArg)
			local k,v
			for k,v in pairs(tblArg) do
				tbl[k]=v
			end
		end)

	return tbl
	end

function reduceScreenShake()
	if g_screenShake<0.1 then
		g_screenShake=0
	else
		g_screenShake*=0.125
	end

	end

function resetLevel()
	for enemy in all(g_insts("enemy")) do
		if enemy.obj=="bottle" or enemy.obj=="shuriken"
			or enemy.obj=="seagull" or enemy.obj=="flag"
			or enemy.obj=="sun" then

			instDel(enemy)
		else
			enemy.dead=false
			enemy.health=enemy.healthMax
			enemy.x=enemy.spawnX
			enemy.y=enemy.spawnY
		end
	end
	for inst in all(g_insts) do
		if inst.obj=="leave" then
			instDel(inst)
		end
	end

	(g_insts("level1")[1] or g_insts("level2")[1] or {}).bossCreated=false
	if g_level~=2 then
		instDel(g_insts("boss")[1])
	end

	end

function setmetatables()
	g_create.setMetatable()

	g_insts.setMetatable()

	-- global table is _ENV
	end
-->8
-- iNIT

setmetatables()

loadLevel1()
-->8
-- uPDATE

spawnBoss3=cocreate(
	function()
		for i=0,94 do
			yield()
		end

		g_boss3spawning=false
	end)


function _update()
	g_t+=1

	if g_boss3spawning then
		coresume(spawnBoss3)
	else
		foreach(g_insts,
			function(inst)
				if(not inst.dead and inst.update)inst:update()
			end)
	end

	foreach(g_instsToDel,
		function(inst)
			del(g_insts,inst)
			del(g_instsToDel,inst)
		end)

	printh(stat(7).." FPS\t"..stat(0).." KiB\t"..stat(1).." (CPU)")
end
-->8
-- dRAW

function drawBackgroundCircle()
	local charge=g_player.jumpChargeFrames/g_player.jumpChargeFramesMax
	local chargeOpposite=1-charge
	local numCircles=8
	local radius=lerp(g_radiusPrevious,charge*16+32,0.5)

	-- """simulate""" 3D
	local view=sin(g_t/64)

	local angle
	for i=0,numCircles-1 do
		angle=i/numCircles+g_circleAnglePrevious
		local boss=g_insts("boss3")[1]
		local pointX=cos(angle)*(radius+charge*12)*view
		local pointY=sin(angle)*(radius+chargeOpposite*4)
		if boss then
			camera(g_player.x-8,0)
			pointX+=boss.x+15
			pointY+=boss.y+3

			
			fillp(0xcc33)
			line(pointX,pointY,boss.x+15,boss.y+3,1)
			fillp()
		else
			pointX+=64
			pointY+=64
		end

		circfill(
			pointX,
			pointY,
			1.5,--+cos(angle)*view*0.75,
			i+8
		)
	end

	-- angle+1/numCircles sets the angle to the angle of the first circle
	-- the rest slightly increases the angle to move the next points
	g_circleAnglePrevious=angle+1/numCircles-1/(chargeOpposite*96+32)

	g_radiusPrevious=radius
end

function _draw()
	cls(0)

	if not g_boss3spawning then
		camera()

		local boss3=g_insts("boss3")[1]

		if not boss3 then
			drawBackgroundCircle()
			setCamera()
		else
			if not boss3.pig then
				if boss3.visible then
					drawBackgroundCircle()
				end
				setCamera()
			end
		end

		if g_level~=2 then
			map(0,0+g_level*16,0,0,128,16,1)
		end

		foreach(g_insts,function(inst)
			if inst.draw and not inst.dead and (isOnScreen(inst.x or 0,inst.witdh or 32) or (boss3 or {}).pig)
				then

				inst:draw()
			end
		end)

		local boss=g_insts("boss")[1]
		if boss then
			if not boss.dying and not boss.pig then
				boss:drawHealthBar()
			end
		end

		reduceScreenShake()
	end
end

function setCamera()
	camera(
		g_player.x-8+((rnd()<0.5)and 1 or -1)*g_screenShake*0.125,
		((rnd()<0.5)and 1 or -1)*g_screenShake*0.125
	)
end
__gfx__
0700700722222005522222220003b000555555552222222005522222000044400000000000000000000000000000000000000000000044403333333333333333
070077072220064445552222003bbb00555555552222000d677552224444fff400004440000000000000000000000000000024404444fff43333300000333333
07000007220604fff476552200033000555555552200d665000075224ffffff4444444440000444000000000000044402222fff42f8888f433300eeeee003333
0700077720666666ff47765200333b005555555520d6600d667777524ffffff42ffffff44444444444444444444888e42ffffff428888e84330eeeeeeeee0333
0700777006ddddd6667077520333bbb05555555520660666d55555754ffffff42ffffff4fffffff42222244444422ff42ffffff42888888430eeeeeeeeeee033
070077770ddddddddd677765003bb300555555550d666d55555555504ffffff42222fff40000ff400000000000002440444444442ff888f430eeeeeeeeeee033
070077070dddddddddd6777503333bb0555555550666d555555555504444fff400002440000000000000000000000000000044402222fff40ee71ee71eeeee03
070007070d007ddddddd67750005500055555555066655555550a050000044400000000000000000000000000000000000000000000024400ee11ee11eeeee03
060000000dd0f5d507dd6775000000003b3b0000066d550a050095500000000000000033bb000000000000005555555555555555555555550ee11ee11eeeeee0
670000000ddddddd0f0dd7750000003333b3ba000665500955555550000000000333bb333b33bb30000000005133131551313135565dd6d50eeeeeeeeeeeeee0
7d0000000dddddddddddd775003b3a33333bbba0066555550055555000000001113333bb33bb3ba3300000005111111553131315565555550eeeeeeeeeeeeee0
d0000000200001ddddddd7520333b33333b3b3bb20d55555555000020000033133131333333b33bb3ba000005133311555555555555dddd530eee0eeeeee2ee0
000000002222200001ddd52233333333333b3bbb220555500002222200001331131111333bb33bb3a3bb0000511111150060060055dd5555302eeeeeeeeee003
000000002222222220000222333333333333b3b322200002222222220003113331313133333333b33b3ba000513133155555555555d556d53082eeeeee228033
0000000022222222222222223333333333333b3022222222222222220031111131313133333b3bbb33a3b300555555555555555555d5d6550882222222888803
00000000222222222222222233333b3a3333333022222222222222220111131311113333333333b3b3bb3ba05855858505555550555555550222222222888803
333300003333333355555555033333b3b33333000555555055555555011113111313333433333bb3bb33b3b05d55555555555555555555d55555555505555555
3300eeee0033000351115515003333333b330000555555555555555511111111113333b4333333bbb3b3bb3b5d55555555555555555555d55555555555555555
30e71ee71e00eee05181551500003333b300000006666660555555551111111111133b888b333333bb3b33bb5d55555555555555555555d50dddddd005555555
0e111e111ee2eee0511155150000033330000000055555505555555511111111113333288333333b3bb33b335d55555555555555555555d500d00d000d0000d0
0e11ee11eee2eee051115dd6000000440000000055555555555555551111111111113b228b3333333b3b3bb35d55555555555555555555d50060060000600060
0e2222eeeeee2ee0518155150000004400000000066666600500d050111111111113333b33333133b33bb33055d555555555555555555d550666666000060060
0222222eeeeeee035111551500000044000000000555555008d00d8010011111111133333331111133330300555dddddddddddddddddd5555555555500006555
0222222eeeeeee0355555555000000444000000055555555000d0000100101111111111313111313130303005555555555555555555555555555555500000555
0222288eeeeeee03555555555555555555555555005555550555555010010100111111111111111003030300558558555d55d555555555550555555055555555
0222888eeeeeee03513133155d5555d556666655055511155555555500000100101002112121101000030000555555555d55d5d5555555555515515551511515
0222888eeeeee0335113311555555555566666555551581555555555000003333313322121233313333000000d0000005d55d5d5555550d05115511555111155
0222888eeeeee0005133311555555555556666655511151555555555001113333313312124433333333333000d000000555555550d0d00d05551155551111115
3022288eeeee88805113131555555555556666655151115555555555112111223313311214333333433343330d00ddd0555555550d0d05555551155551111115
302222eeeee88880555555555555555555566665515515555555555521221111111331111133333333333334066dd000d5d5d555060005555115511555111155
330222222e22888055d5d5d55d5555d50555555551115550555555552111111111111111111333433333333400006660d5d5d555060005555515515551511515
33302220002222035d5d5d55555555550000000055555500055555502211111111111111111111111333334400000000d5d5d5dd000000600555555055555555
00000000000000000000550000000000000155500555050000700000222121112121122212112112234343d400000000000010000100000055000000000dd000
06660000000000000005555000500000000015000000550007770000022522122522122222112222244444400500000000000000000000001500000000667700
0d6660000000066000015558055500000000000800015500df770000022552222222222222122225224d44401550000055000000000055000000000000666600
00d66601d110666600001508000005000000000000001000077ddd00002222222222222255222222224444000100000015000000000555500050000000066000
000d61111d11166000000000080055000500000055000000067dddd0000222222222222222222222222440000005550000000000000155580855000000666700
0000d111d1d11100000000000001550015500000150000000067dd11000002222252222222222225222000000055555800500000000815088800050000666600
0f661d1d111d1d10000555805500100001000080000000000006d000000000022222222222222222200000000018555808550000000555588005550000dddd00
666111d11111d111155558855550500000005580008000000001d000000000000002222222222200000000000018518808500500005555888855550000dddd00
666111d11111d11101158888555855000005588808800000000000d000000d0000777774a0aa000a000000000051158888500500001585888885550000000000
0fdd1d1d111d1d1000058888858855000008588888850500000066dd0000dd00777777740a0aa0a0000000000555588888855500055188898881855000000000
0000d111d1d111000058888988885550005888888888050000000d60dddddd007777777400aaaa0a00e000005155588898855550055888898888855500000000
0006d1111d111660055888898888855005588898898850000066d0600dd00d00777777740aaaaaaa0feeeee05155888898885550055888899888855500000000
0066dd01d110d66605188899989885500158889989885500dd0d600000d00d7077000044aaaaaaa0eeeeeeee0515888998881550555888999898855500000000
0d66600000000dd005518899999885550155899999985550ddd0600000ddddd700000044a0aaaa00eeeeeee00555589999885500155588999998815500000000
0ddd0000000000005555889a999855550515899a99985555fddd000000dd0000000000440a0aa0a000e000e005555899a98855500155888a9998555000000000
000000000000000055555889aa9851555555589aa9855555dddd000000d0000000000044a000aa0a000000000555558aa98555550015588aaa98550000000000
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
00000000000000777777777770000000aa0000000000009aaa000000000000aa0000000000000000000000000000000000000000000000000000000000000000
0000000000077777777777777770000099aa000000000999aaa000000000aaaa0000000000000000000000000000000000000000000000000000000000000000
000000007777777777777777777770009999aa00000009999aa0000000aa99990000000000000000000000000000000000000000000000000000000000000000
00000777777777777777777777777700099999aa0000d9999aa00000aa9999900000000000000000000000000000000000000000000000000000000000000000
0007777777777777777777777777777000099999aa00099999a000aa999990000000000000000000000000000000000000000000000000000000000000000000
007777777777777777777777777777700000999999aa00999900aa99999900000000000000000000000000000000000000000000000000000000000000000000
d777777777777777777777777777777700000099999999999aaa9999990000000000000000000000000000000000000000000000000000000000000000000000
d67777777777777777777777777777770999999aa999999999999999aaaaaaa00000000000000000000000000000000000000000000000000000000000000000
dd7777767777777777777777777777779999999999999999999999999999999a0000000000000000000000000000000000000000000000000000000000000000
ddd676dd677777777777777777777777999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000
ddfddddddd777777777777777777777700000000001199999999c110000000000000000000000000000000000000000000000000000000000000000000000000
0dddddddddd777777777776777777777000006000011999999991101000000000000000000000000000000000000000000000000000000000000000000000000
0ddddd00ddd67777777777d777777777000000000001999999991001000000000000000000000000000000000000000000000000000000000000000000000000
0dddd0000ddd7777777776d777777770000d000010011999999100000000d0000000000000000000000000000000000000000000000000000000000000000000
01dd000000ddd67777776dd777777770000000010011199999a111c0060000000000000000000000000000000000000000000000000000000000000000000000
00000000000dddd6776dddd777777700000000011c11199999a11111000000000000000000000000000000000000000000000000000000000000000000000000
000000000000ddddddd01dd777777700000000601111199999a11c11100000000000000000000000000000000000000000000000000000000000000000000000
0000000000000dddddd01dd7777770000000000001119999999a1100100000000000000000000000000000000000000000000000000000000000000000000000
00000000000001ddddd01dd7777770000000000000099999999aa00c000000000000000000000000000000000000000000000000000000000000000000000000
000000000000011dddd01dd77777000000000600100999999999a000000005000000000000000000000000000000000000000000000000000000000000000000
000000000000011dddd01dd77777000000500000109999999999aa00000000000000000000000000000000000000000000000000000000000000000000000000
00000000000011ddddd1ddd677700000000000000199999999999a06000d00000000000000000000000000000000000000000000000000000000000000000000
00000000000011ddddd1dddd6770000000000d000999999999999aa0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000dd11dddd11dddddd70000000000009999a999999999aa000000000000000000000000000000000000000000000000000000000000000000000000
0000000000dddddddddddddddd77700000000000999a09999990999a000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ddddddddddddddddddd0000000000999a009999990099aa00000000000000000000000000000000000000000000000000000000000000000000000
0000000000ddddddddddddddddddd000000000099a00099a99900099a00000000000000000000000000000000000000000000000000000000000000000000000
0000000000ddddddddddddddddddd00000000099a000099a99900009aa0000000000000000000000000000000000000000000000000000000000000000000000
0000000000ddddddddddddddddddd00000000099a000099a99ad00099a0000000000000000000000000000000000000000000000000000000000000000000000
0000000000ddddddddddddddddddd000000000090000d99a99a00000900000000000000000000000000000000000000000000000000000000000000000000000
0000000000ddddd00dddddddddddd000000000000000099a99a00000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000dd0000000ddd0000dd0000000000000000099a99a00000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000001000000000000000000000000000000000000000000000101010000000001000001010000000001010101010000010101010100000000010101010100000000000000010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000000000000000000000000000000000000026340404040404040404043e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c04040404332f0000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f04040404350000000000000000000000002b2d04000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040404040400000000000000000000000000002500000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000043200000000000004043300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040404040400000000000000000000000000000000000000043304000000000000000000000000000004040400
0000000000000000000000000000000000000000000000040404040404040404043b3d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004041d2e0400000000000000000000000000000000000000000400000000000022320400000000000000260000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404042f0400000000000000000000000000000000000000000000000000000000040000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000032000000000000040404040400000000000000000000000000000000000000000000000000000013000013000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042f0000000000002e0404040400000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040404000000000000040404043600000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040404000000000000000000330400000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000040404040000000000000000000000000000000000000000000000000000000404040404040404042f00000000000000000035040404040400000000000000000026340000000000000000000000000000000000000013001300130000000000000000000000000e000000
00000000000000000000000000000000000000000004330404041b00000000000000000000000000000000000000000000000000043304043b0404043304000000000000000000040404040404000000000e00000000000000000000000000000000000000000000000000000004040400000000000000000000000000000000
00000000000000000022040000320404040000000004040404042e0404040404040404040000000036000000000000000000000004250404220404042504000000000000000000040404040404000000000000360000000000001d1b0404040000000000130000000000000000003b00000000001b0404040404040404040000
2b2c1b33040433040425040000040404040000000004330404042f040404040404043304000000002e000000000000000000000004040404040404040404000000000000000000043304040404260404040404250400000000220404040404000004040400000000000404260000000000000000003500000000000034000000
2c332e0404040404043404040404040433260404041c220404041c0404040404040404340000000422000000000000353f0400002b2c2c2c2c2c2c2c2c2d000000000000000000343d040404040404040404040404040404040404040404260000001c0000000000000036000000000000000000000000000000000000000000
0000000000000032040400000000000000000000040425040404040404040404040404040404040404040404042b2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2d04040404040433040404040404260404040404043304040404042b2d040404040404040000000000000000000000000000000000000000000000002500000000
0000000000000034040400000000000000000000040426000000000000000000000000000000000000000000000000000000040404040404040404042500000000000000000000000000000000000000040000000000000000000404000000000000000000000000000000000000000000000000000400000000000400001d00
0000000000000000040400000000000000000000040400000000000000000000000000000000000000000000000000000000040404040404040400000000000000000000000000000000000000000000040000000000000000002f0400000000000000000000000000000000000000350000000000000000002e000000000400
00000000000000000404000000000000000000000404000000000000000000000000000000000000000000000000000000000004040404041d00000000000000000000000000000000000000000000002600000000000000000000040000000404250000000000000000000000000000000000000000040000040000002f0000
00000000000000000404040000000000000000040404000000000000002c2c000000000000000000000000000000000000000000340404043b0000000000000000000000000400000000000400000000000400000000003e00000004000000040404000000000000000000000004000000040000000000000000360000040000
0000000000000000000404000000000000000004040400000000000000040400000000000000000000000000004000000000000000000000000000000e00000000000000040400000000040400000000040400000000331c00000004000000040404040000000000000000000000000000000000000000002600040000000000
0000000000000000000404040000000000000004043b000000000000220404000000003600000036000000360000003600000000000000000000000000000000000000003504000000000004000000001d040000000000040000000400000004040404000000000000000000002200000000000000000000040000000000001b
0000000000000000000004040400000000000404040000000000000004040404040404040404040404040404040404040404040404040404360000003b3d0000000000001d3f04000000042504000000041b040000000400040000042e0000040404040400000000000000000000000000000000000000000000003400000004
00000000000000000000040404320000001b040404000000000000002f04040404040404040404040404040404040404040404040404040404000000000000000000000004040400000026342f0000000404040000000404040000042600000404040404041d00000000000e0000000000000000000000000000000400000000
000000000000000000000004040404040404040404000000000000000e002c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c000000000000400000000004000000000000000000000000000000000000000000003d0000000404040404042b1b04000000000000000000000000000000000000000000000000
0000000000003600000000000404040404040404040000000000000000000404040404040000000000000000000000000000000004040404040000000000000000000000040000000000000000000000000000000000000000000000000000040404040404040404040404043b00000000000000000400000000000000000000
000000000000331c0000000000002b2c2c2c2c2c2d000000000000040404040404040000000000000000000000000000000000000000040404000000000000000000000033000000000000000000000000000000000000000000000000003e2204042604040404040404000000000000000000000000000000000000000e0000
000000000000260000000000000000004000000000000000000404040404043d000000000000000000000000000000000000000000000004040000000000000000000000340000000000000000000000000000000000000000000000000404040404040404040404000000000000000000000000000000000000000000000000
0000000000000e000000000000000000000000000000000404040404040400000000000000000000000000000000000000000000000000002f040404041b04040404040404040404363233040404040404040404040404040404041c0404040404040404040404000000000000000000000000000000000000040000003b0000
00000000000000003504040425040404040404040425040404040404000000000000000000000000000000000000000000000000000000000004040404040404040404040404040404252e0404040404040404040404040404040435040404040404040404040000000000000000000000000000000000000000000400000000
2f04040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000040404040404043d0404040404043b3d0404040404040404040404040404043404040404040404040400000000000000000000000000000000000000000000000000000000
__sfx__
011c00001a1241a1251a1001f13022134221302113400100001001b1101b1001b12022134221301b134231001a1341a1301a1041f13022134221302113400100001041b1101b1041b12022134221301b13423100
011c00000e3100e313000000e100000001f5002150023500215001f5001e5001c5001b50017500185001b5001c0001c0001c0001c0001a064180601806018065180601806018060180601a060180601806016020
011c00000e2100e210182001321000000162101621015210232000f2100f2040f210162001621016210132100e2100e210182001321000000162101621015210232000f2100f2040f21016200162101621013210
011c00001806518064000001806618060180601a06018060180641806018060180601a06418060180601b5001806518064000001806618060180601a06018060180641806018060180601606415060130601b500
011c0000130601306013065180601606015060130600f0401806018060180601806016060150601306011035130601306013065180601606015060130600f0401806018060180601806016060150601306013065
011c00000e2100e210182001321000000162101621015210232000f2100f2040f210162001621016210132100e2100e210182001321000000162101621015210232000f2100f2040f21016200162001620013200
011c0000130601306013065180601606015060130600f0401806018060180601806016060150601306011035130001300013005180601606015060130600f0401806018060180601806016000150001300013005
011c00000a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573106100d6140d61108624086210463404631
011c000004634046430a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a57307505
011c00000a573046030a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a573075050a57307505
011c0000025731a615226351a615025731a615226351a615025731a615226351a615025731a615226351a615025731a615226351a615025731a615226351a615025731a615226351a615025731a615226351a615
011c0000025731a615226351a615025731a615226351a615025731a615226351a615025731a615226351a615025731a615226351a615025731a615226351a61502503106100d6240d62108634086310464404641
011c00000e2100e210182001321000000162101621015210232000f2100f2040f210162001621016210132100e2100e210182001321000000162101621015210232000f2000f2040f20016070180701607018070
011c00001a1141a1151a1001f12022124221202112400100001001b1101b1001b11022124221201f124231001a1241a1201a1041f12022124221202112400100001041b1101b1041b11022124221201f12423100
011c00001a0701a07518070180751807018075180701807516070130701307500000160701807016070180701a0701a0751807018075180701807518070180751607013070130751807018070180701607018070
011c00001a07000000180701607016070160751807018070160701307000000180701807018070160701d0701a0700000018070160701607016075180701807016070130700d6240d62108634086310464404641
011c0000025731a605226351a605025731a605226351a605025731a605226351a605025731a605226351a605025731a605226351a605025731a605226351a605025731a605226351a605025731a605226351a605
011c00000e0700e0700e0701a070160701607015070150700f070160701507013070130700000000000000000e0700e0700e0701a070160701607015070150700f07016070150701307013070000000000000000
011c0000025731a605226351a605025731a605226351a605025731a605226351a605025731a605226351a605025731a605226351a605025731a605226351a60502503106100d6140d61108624086210463404631
011c00000e2100e210182001321000000162101621015210232000f2100f2040f210162001621016210132100e2100e210182001321000000162101621015210001041b1101b1041b12022134221301f13423100
011c00001306013060130651806016060150601306013065180001800018000180601606015060130601103513060130601306518060160601506013060130651806018060180601806016060150601306013065
010c0000000000000000000000000000000000000000000000000000000000000000000001f3001f3201d320203201f3201d320203201f3201d320204301f4301d430204301f4301d430204301f4301d4301d430
010c00001c4301c4301c4301c4301c4301c4301c4301c4301c4301c4301c4301c4301d4301d4301d4301d4301f4301f4301f4301f4301f4301f4301f4301f4301f4301f4301f4301f4301f4301f4301f4301f435
010c00001f4051f40520430204301f4301f4301d4301d4301f4301f43020430204301f4301f4301d4301d43025430254302543025430254302543025430254302443024430244302443024430244302443024430
010c00001c4301c4301c4301c4301c4301c4301c4301c4301c4301c4301c4301c4301d4301d4301d4301d4301f4301f4301f4301f4301f4301f4301f4301f4302043020430204302043020430204302043020430
010c00002443024430244302443024430244302443024430244302443024430244302443024430244302443024430244302443024430244302443024430244302543025430254302543025430254302543025430
010c0000000000000020430204301f4301f4301d4301d4301f4301f43020430204301f4301f4301d4301d43025430254302543025430254302543025430254302743027430274302743027430274302743027430
010c0000244302443024430244302443024430244302443024430244302443024430244302443024430244302443024435244302443022430224302043020430224302243020430204301f4301f4301d4301d430
010c00001f4301f4301f4301f4301f4301f4301f4301f4301f4301f4301f4301f4301f4301f4301f4301f43020430204302043020430204302043020430204301f4301f4301f4301f4301f4301f4301f4301f430
010c00001c4301c4301c4301c4301c4301c4301c4301c4301c4301c4301c4301c4301d4301d4301d4301d4301f2321f2301f2321f2301f2321f2301f2321f2301f2321f2301f2321f2301f2321f2301f21100000
010c0000000000000020430204301f430204301d4301d4301f4301f43020430204301f4301f4301d4301d43025430254302543025430254302543025430254302443024430254302443022430224302443024430
010c00002443024430244302443024430244302443024430244302443024430244302443024430244302443024430244302443024430244302443024430244302443024430244302443025430244302443024430
010c000027430244302743024430274302443027230242302723026230272302423027230262302423027230272302723027230272302723027230272302723027230272302b4302b43027430274302b4302b430
010c00002b4302b4302b4302b4302c4302c4302c4302c4302c4302c4302c4302c4302c4302c4302c4302c4302c4302c4302c4302c4302c4302c435000002f4002f4402f4302f4302c4302c4302c4302b4302b430
010c00002943029430294302943029430294302943029430284302843028430284302843028430284302843028430284302843028430294302b4302b430294302943029430274302743026430264302443024430
010c00002443024430274302741526430264152443024415264302641527430274152643026415244302441526430274302443027430264302443027430264302443026430274302443027430264302443027430
010300001b433154371b430186201862118611186111861118611186110f0110f0110f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f00000000000002b0002b0000000000000
01030000186241861118611186111861118600186010f0010f001007002b7002b70500700007002770027705244002440027700277050070000700267002670500700007002b7002b70500700007002770027705
01050000247542475024750247502474024740247302473028710287302875028750287402874028730287302b7102b7302b7502b7502b7402b7402b7302b7302e7102e7302e7502e7502e7402e7402e7302e730
010c00001812018125181201812518120181251812018125181201812518120181251812018125181201812518120181251812018125181201812518120181251812018125181201812518120181251812018125
010c00001912019125191201912519120191251912019125191201912519120191251912019125191201912519120191251912019125191201912519120191251912019125191201912519120191251912019125
010c00002412024125241202412524120241252412024125241202412524120241252412024125241202412524120241252412024125241202412524120241252412024125241202412524120241252412024125
010c00002512025125251202512525120251252512025125251202512525120251252512025125251202512525120251252512025125251202512525120251252512025125251202512525120251252512025125
010c0000186450c3200c3200c320186450c3200c3200c320186450c3200c3200c320186450c3200c3200c320186450732007320073201864507320073200732018645073200732007320186450c3200c3200c320
010c0000186450d3200d3200d320186450d3200d3200d320186450d3200d3200d320186450d3200d3200d320186450832008320083201864508320083200832018645083200832008320186450d3200d3200d320
010c0000186450d3200d3200d320186450d3200d3200d320186450d3200d3200d320186450d3200d3200d3201864508320083200832018645083200832008320186450f3200f3200f320186450d3200d3200d320
010c00200c1733c0000c1730000018643000000c1731864500000186430c1730c173186450000300003000030c173000030c17300003186431a3030c1731864500003186430c1731130300003000001864300000
010c00000c3200c3200c3200c3200c3200c3200c3200c3200c3200c3200c3200c3200c3200c3200c3200c3200c3200732007320073200c3200732007320073200c3200732007320073200c3200c3200c3200c320
010c00000d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200832008320083200d3200832008320083200d3200832008320083200d3200d3200d3200d320
010c00000d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200d3200832008320083200d3200832008320083200d3200f3200f3200f3200d3200d3200d3200d320
010c00000c1733c0000c1730000018643000000c1731864500000186430c1730c173186450000300003000030c173000030c17300003186431a3030c1731864500003186430c1731130318643186431864318643
010c00002743426430244302743026430244302743026430244302743026430244302b4302b4302b4302b4302743026430244302743026430244302743026430244302743026430244302b4302b4302c4302c430
010c00002943027430254302943027430254302943027430254302943027430254302c4302c4302c4302c4302943027430254302943027430254302943027430254302943027430254302c4302c4302b4302b430
010c00002943027430254302943027430254302943027430254302943027430254302e4302e4302e4302e4302943027430254302943027430254302943027430254302943027430254302e4302e4302c4302c430
010c000027120271250000000100261202612500000001002b1202b12500000001002712027125000000010027120271250000000100261202612500000001002b1202b125000000010027120271250000000100
010c000029120291250000000100271202712500000001002c1202c12500000001002912029125000000010029120291250000000100271202712500000001002c1202c125000000010029120291250000000100
010c0000165700050000500165700050000500165700050015570005000050000500155700050000500005001a5701a500005001957000500005001857018500175701f500005001657000500005001557000500
010c00002242125421254202542025420254202542025420254202542025420254202542025420254202542026421264202642026420264202642026400254002642126420264202642026420264202642026420
010c000028420284202842028420284202842028420284202a4202a4202a4202a4202a4202a4202a4202a4252a4202a4202a4202a4202a4202a4202a4202a4202c4202c4202c4202c4202c4202c4202c4202c420
010c00002d4202d4202d4202d4202d4202d4202d4202d4202c4202c4202c4202c4202c4202c4202c4202c42028420284202842028420284202842028420284202542025420254202542025420254202542025420
010c00002842028420284202842028420284202842028420284202842028420284202842028420284202842022424254212542025420254202542025420254202842028420284202842028420284202842028420
010c00002d4202d4202d4202d4202d4202d4202d4202d4202f4202f4202f4202f4202f4202f4202f4202f42033420334203342033420334203342033420334202f4202f4202f4202f4202f4202f4202f4202f420
010c000033420364203342133420334203342033420334202f4202f4202f4202f4202f4202f4202f4202f42033420364203342133420334203342033420334202f4202f4202f4202f4202f4202f4202d4212d425
010c00002642026420264202642026420264202642026420264202642026420264202642026420264202642026420264202642026420264202642026420264252642026420264202642026420264202642026420
__music__
00 00 01 07 44
01 02 03 08 44
00 05 03 07 44
00 02 04 0a 44
00 0c 06 0b 44
00 0d 0e 43 44
00 02 0f 10 44
00 02 03 09 44
00 02 03 07 44
00 02 04 0a 44
00 00 04 0a 44
00 02 11 10 44
00 13 11 12 44
00 0d 14 0a 44
02 0d 14 0b 44
00 15 42 43 44
01 16 27 2f 44
00 17 28 30 44
00 18 29 2f 44
00 19 2a 31 44
00 16 27 2b 2e
00 1a 28 2c 32
00 1b 29 2b 2e
00 1c 2a 2d 32
00 1d 27 2b 2e
00 1e 28 2c 32
00 18 29 2b 2e
00 1f 2a 2d 32
00 20 27 2b 2e
00 21 28 2c 32
00 22 29 2b 2e
00 23 2a 2d 32
00 33 36 2b 2e
00 34 37 2c 32
00 33 36 2b 2e
00 35 37 2d 32
02 41 27 2f 44
02 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
