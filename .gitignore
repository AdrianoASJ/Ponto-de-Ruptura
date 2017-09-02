local background = display.newImage("imagens/backrock.png", display.contentWidth, display.contentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY

local skullbaixo = display.newImage("imagens/skull.png", contentWidth,50) 
skullbaixo.x = display.contentCenterX
skullbaixo.y = display.contentHeight-25

local skullcima = display.newImage("imagens/skull.png", display.contentCenterX, display.contentCenterY)

local physics = require("physics")
physics.start()

physics.addBody(skullcima, {bounce = 1})
physics.addBody(skullbaixo)
 
function kikar ()
	skullcima:applyLinearImpulse(0, -.2, skullcima.x,skullcima.y)
end
skullcima:addEventListener("tap", kikar)

local function onTouch(event)
	if(event.phase =="began")then
		if(event.x < skullbaixo.x) then
		-- move to left
		skullbaixo:setLinearVelocity(-30, -200)
		else
		-- move to right
		skullbaixo:setLinearVelocity(30, -200)
		end
	end		
end
Runtime:addEventListener("touch", onTouch)
