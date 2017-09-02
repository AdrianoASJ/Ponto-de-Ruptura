display.setStatusBar(display.HiddenStatusBar)


local testRect = display.newRect(10,30,60,60)
testRect:setFillColor(150,0,0);

local fundo = display.newImage("imagens/fundo.png")
fundo.x = 90
fundo.y = 50

local hero = display.newImage("imagens/hero.png") 
hero.x = 240
hero.y = 160

local floor = display.newImage("imagens/floor.png")
floor.x = 450
floor.y = 330




local physics = require("physics")
physics.start()

physics.addBody(floor, "static")
physics.addBody(hero, "dynamic")
function mover ()
	
end
hero:addEventListener("tap", mover)

local function onTouch(event)
	if(event.phase =="began")then
		if(event.x < hero.x) then
		-- move to left
		hero:setLinearVelocity(-200, 0)
		else
		-- move to right
		hero:setLinearVelocity(200, 0)
		if(event.x == hero.x + hero.y)then
			--jump
		hero:setLinearVelocity(0, 200)
		end
		end
	end		
end
Runtime:addEventListener("touch", onTouch)

x = display.contentWidth/2
y = display.contentHeight/2
--a boolean variable that shows which direction we are moving
right = true
 
hero.x = x
hero.y = y
