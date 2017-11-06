
local composer = require( "composer" )

local scene = composer.newScene()


local physics = require("physics")
physics.start()
physics.setGravity(0, 0)

--------------------------------------------------------------------------------------
-- VIRTUAL CONTROLLER CODE
--------------------------------------------------------------------------------------

local factory = require("controller.virtual_controller_factory")
local controller = factory:newController()

 
system.activate("multitouch")



local contador = 0
local js1
local js2

local function setupController(displayGroup)
	local js1Properties = {
		nToCRatio = 0.5,	
		radius = 60, 
		x = 200, 
		y = display.contentHeight - 100, 
		restingXValue = 0, 
		restingYValue = 0, 
		rangeX = 200, 
		rangeY = 200
	}

	local js1Name = "js1"
	js1 = controller:addJoystick(js1Name, js1Properties)

	local js2Properties = {
		nToCRatio = 0.5,	
		radius = 60, 
		x = display.contentWidth - 200, 
		y = display.contentHeight - 100, 
		restingXValue = 0, 
		restingYValue = 0, 
		rangeX = 600, 
		rangeY = 600
	}
	
	local js2Name = "js2"
	js2 = controller:addJoystick(js2Name, js2Properties)

	controller:displayController(displayGroup)
	
end

----------------------------------------------------------------------------------------
-- END VIRTUAL CONTROLLER CODE
----------------------------------------------------------------------------------------


local enemyTable = {}
local maxEnemies = 50
local supplyTable = {}
local maxSupplys = 20

local died = false

local player
local gameLoopTimer
local fireTimer
local movementTimer

local backGroup
local mainGroup
local uiGroup
-------------------------------------------------------------------------------------------
-- Animation 
-------------------------------------------------------------------------------------------
local sheetOptions =
{
    width = 54,
    height = 51,
    numFrames = 6
}

local sheet_supply = graphics.newImageSheet( "Supply.png", sheetOptions)
--tamanho total do supply height 51
--						  width 324
local sequences_supply = {
		    {
		        name = "shine",
		        start = 1,
		        count = 6,
		        time = 350,
		        loopCount = 0,
		        loopDirection = "forward"
		    }
		}

-------------------------------------------------------------------------------------------
--End Animation
-------------------------------------------------------------------------------------------
local function createEnemy()
	if(#enemyTable == maxEnemies) then
		return true
	end

	local newenemy = display.newImageRect(mainGroup, "rato.png" , 100, 100)
	

	table.insert(enemyTable, newenemy)
	physics.addBody(newenemy, "dynamic", {width = 40, height = 40, bounce = 0.8})
	newenemy.myName = "enemy"
---------------------------------------------------------------------------------
	local whereFrom =  math.random(4)
	
	if(whereFrom == 1) then
		newenemy.x = -60
		newenemy.y = math.random(display.contentHeight)
		newenemy:setLinearVelocity(math.random(40, 120), math.random(-40, 40))
	elseif(whereFrom == 2) then
		newenemy.x = math.random(display.contentWidth)
		newenemy.y = -60
		newenemy:setLinearVelocity(math.random(-40, 40), math.random(40, 120))
	elseif(whereFrom == 3) then
		newenemy.x = display.contentWidth + 60
		newenemy.y = math.random(display.contentHeight)
		newenemy:setLinearVelocity(math.random(-120, -40), math.random(-40, 40))
	elseif(whereFrom == 4) then
		newenemy.x = math.random(display.contentWidth)
		newenemy.y = -60
		newenemy:setLinearVelocity(math.random(-40, 40), math.random(-120, -40))
	end
	newenemy:applyTorque(math.random(-1, 1))
end

local function CollisionSupply( self , event )
	--print( "--- COLISAO ---" )
	--print( event.target.myName )        --the first object in the collision
	--print( event.other.myName )         --the second object in the collision
	if(event.other.myName == "player") then
		event.target:removeSelf()
	end
end

----------------------------------------------------------------------------------------------------------
local function createsupply()
	if(#supplyTable == maxSupplys) then
		return true
	end
	print "sheet_supply"
	print (sheet_supply)
	
	local newsupply = display.newSprite(mainGroup, sheet_supply, sequences_supply)
		newsupply.name = 'supply'
		newsupply:setSequence( "sequences_supply" )
		newsupply:play()
	--local newsupply = display.newImageRect(mainGroup, "hero.png" , 100, 100)

	table.insert(supplyTable, newsupply)
	physics.addBody(newsupply, "dynamic", {isSensor = true, width = 50, height = 50})
	

	local whereFrom = math.random(2)

	if(whereFrom == 1) then
		newsupply.x = math.random(display.contentWidth)
		newsupply.y = 30 -- 100 is a center
		newsupply:setLinearVelocity(0, math.random(0, 70))
	end
	newsupply.collision = CollisionSupply
	newsupply:addEventListener("collision")
end
--------------------------------------------------------------------------------------------------------------
local function setupJS1()
	movementTimer = timer.performWithDelay(100, movePlayer, 0)
end

function movePlayer()
	local coords = js1:getXYValues()
	player:setLinearVelocity(coords.x, coords.y)
end

local function setupGun()
	fireTimer = timer.performWithDelay(300, fireSinglebullet, 0)
end

function fireSinglebullet()
	local pos = js2:getXYValues()
	if(pos.x == 0 and pos.y == 0) then
		return true
	end

	local newbullet = display.newCircle(mainGroup, player.x, player.y, 5)
	physics.addBody(newbullet, "dynamic", {isSensor = true})
	newbullet.isBullet = true
	newbullet.myName = "bullet"

	newbullet:toBack()

	transition.to(newbullet, {x = player.x + pos.x, y = player.y + pos.y, time = 500,
		onComplete = function() display.remove( newbullet ) end
	})

	return true
end


local function endGame()
	composer.gotoScene("menu")
end
local function eliminado()
	composer.gotoScene("morte")
end


     
local function onCollision(event)
	if(event.phase == "began") then
		local ob1 = event.object1
		local ob2 = event.object2
	
		if((ob1.myName == "bullet" and ob2.myName == "enemy")
		or (ob1.myName == "enemy" and ob2.myName == "bullet"))
		then

			

			display.remove(ob1)
			display.remove(ob2)


			for i = #enemyTable, 1, -1 do
				if(enemyTable[i] == ob1 or enemyTable[i] == ob2) then
					table.remove(enemyTable, i)
					contador = contador + 1
					break
				end
			end
			 

		elseif(ob1.myName == "player" and ob2.myName == "enemy" or
				ob1.myName == "enemy" and ob2.myName == "player")
		then
			if(died == false) then
				died = true

				player.alpha = 0
				transition.to(player, {x = display.contentCenterX, y = display.contentCenterY, alpha = 1, time = 500,
					onComplete = function()
						died = false
						eliminado()
					end
				})
			end
		end
	end
end

local indicadorContagem = display.newText(contador, display.contentCenterX, display.contentCenterX, native.systemFont, 80 )

local function mostraContagem( event )
	mainGroup:insert(indicadorContagem)
	count = contador


	
	indicadorContagem.text = count
	indicadorContagem:setFillColor(1, 1, 1, 1)
end

local function gameLoop()
	if(contador <= 10) then
		createEnemy()
		createsupply()

		for i = #enemyTable, 1, -1 do
			local en = enemyTable[i]

			if(en.x < -100 or en.x > display.contentWidth + 100
				or en.y < -100 or en.y > display.contentHeight + 100) then
			
				display.remove(en)
				table.remove(enemyTable, i)
			end
		end
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	
	
	physics.pause()

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup()
	sceneGroup:insert(mainGroup)

	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)
	
	setupController(uiGroup)
	

	local background = display.newImageRect(backGroup, "background.png", 728, 1024)
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	
	player = display.newImageRect(mainGroup, "hero.png" ,  100,100 , 15)
	player.x = display.contentCenterX
	player.y = display.contentCenterY
	physics.addBody(player, {radius = 15, isSensor = true})
	player.myName = "player"
	

	local menuButton = display.newText(uiGroup, "Menu", display.contentCenterX, 920, native.systemFont, 44)
	menuButton:setFillColor(1, 1, 1, 1)
	menuButton:addEventListener("tap", endGame)

	setupGun()
	setupJS1()
end

Runtime:addEventListener("enterFrame", mostraContagem)


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
		
		physics.start()
		Runtime:addEventListener("collision", onCollision)
		gameLoopTimer = timer.performWithDelay(500, gameLoop, 0)
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

		--timer.cancel(gameLoopTimer)
		--timer.cancel(fireTimer)
		--timer.cancel(movementTimer)

	elseif ( phase == "did" ) then
		Runtime:removeEventListener("collision", onCollision)
		physics.pause()
		composer.removeScene("timerbasedexample")
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	controller = nil
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
