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
end

function menu:enter()
    if love.filesystem.exists("map.lua") then
        menuButtons.start.y = 3*menuButtons.start.height*2
      --  menuButtons.options.y = 4*menuButtons.options.height*2
        menuButtons.quit.y = 4*menuButtons.quit.height*2 
        menuButtons.debugBtn.y = 5*menuButtons.debugBtn.height*2 
        
        menuButtons.start.action = function() menuConfirmBox:show() end
    
        menuButtons.continue = GenericButton(2, "Continue", function() Gamestate.switch(game) end)
    end
end

function menu:update(dt)
    for _,button in pairs(menuButtons) do
        button:update()
    end
end

function menu:draw()
    for _,button in pairs(menuButtons) do
        button:draw()
    end
    
    love.graphics.setFont(gameFont[80])
    --love.graphics.printf("Clay", 0, 60, the.screen.width, "center")
    love.graphics.setFont(gameFont[16])
    love.graphics.draw(menu.logo, the.screen.width/2-menu.logo:getWidth()/2, 50)
    
    love.graphics.printf("M - Mute", 0, menuButtons.debugBtn.y + 100, the.screen.width, "center")
end

function menu:mousereleased(x,y,button)
    if button == "l" then
        for _,button in pairs(menuButtons) do
            button:mousereleased(x,y,button)
        end
    end
end
