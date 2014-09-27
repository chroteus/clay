menu = {}

function menu:init()
    local function debugBtnFunc()
        if DEBUG then
            DEBUG = false
            menuButtons.debugBtn.text = "Dev Mode: OFF"
        else
            DEBUG = true
            menuButtons.debugBtn.text = "Dev Mode: ON"
        end
    end
    
    function menu.newGame()
        mapNewGame = true
        Gamestate.switch(countrySelect)
    end
    
    menuButtons = {
        -- GenericButton(order, text, action)
        start = GenericButton(2, "New Game", function() menu.newGame() end),
      --  options = GenericButton(3, "Options", function() venus.switch(options) end),
        quit = GenericButton(3, "Exit", function() love.event.quit() end),
        debugBtn = GenericButton(4, "Dev Mode: OFF", function() debugBtnFunc() end),
    }
    
    
    menuConfirmBox = DialogBoxes:new(
        "You have a saved game. Continue?", 
        {"Cancel", function() end}, {"Continue >>", function() menu.newGame() end}
    )
    
	menu.logo = love.graphics.newImage("assets/image/Clay_logo.png")
	menu.credits = [[
		Game by: 
			Chroteus
		
		Art by: 
			Bernd
	]]
	
	menu.mus_credits = [[
		Music by: 
		EliteFerrex
		chainsaw_09 
		ParagonX9
		Waterflame
	]]
	
	menu.soldier = Soldier{frames = "assets/image/battle_mini/Poland.png"}
	menu.soldier:setPos(200,500)
	menu.soldier:setScale(5)
end

function menu:enter()
    if love.filesystem.exists("map.lua") then
        menuButtons.start.y = 3*menuButtons.start.height*2
      --  menuButtons.options.y = 4*menuButtons.options.height*2
        menuButtons.quit.y = 4*menuButtons.quit.height*2 
        menuButtons.debugBtn.y = 5*menuButtons.debugBtn.height*2 
        
        menuButtons.start.action = function() menuConfirmBox:show() end
    
        menuButtons.continue = GenericButton(2, "Continue", function() loading.switch(game) end)
    end
end

function menu:update(dt)
	menu.soldier:update(dt)
    for _,button in pairs(menuButtons) do
        button:update()
    end
end

function menu:draw()
	menu.soldier:draw()
    for _,button in pairs(menuButtons) do
        button:draw()
    end
    
    local logoX = the.screen.width/2-menu.logo:getWidth()/2
    local logoY = 50
    love.graphics.draw(menu.logo, logoX, logoY)
    
    love.graphics.printf("M - Mute", 0, the.screen.height-100, the.screen.width, "center")
	local font = love.graphics.getFont()
    love.graphics.printf(menu.credits, logoX - font:getWidth(menu.credits), logoY + 10, 100, "right")
    love.graphics.printf(menu.mus_credits, 
		logoX + menu.logo:getWidth() + 10, 
		logoY+10, 100, "left")
end

function menu:mousereleased(x,y,button)
    if button == "l" then
        for _,button in pairs(menuButtons) do
            button:mousereleased(x,y,button)
        end
        
        menu.soldier:moveTo(x-32,y-12)
    end
end
