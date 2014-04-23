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
    
    local function newGame()
        mapNewGame = true
        switchState(countrySelect)
    end
    
    menuButtons = {
        -- GenericButton(order, text, action)
        start = GenericButton(1, "New Game", function() newGame() end),
        options = GenericButton(2, "Options", function() switchState(options) end),
        quit = GenericButton(3, "Exit", function() love.event.quit() end),
        debugBtn = GenericButton(4, "Dev Mode: OFF", function() debugBtnFunc() end),
    }
    
    
    menuConfirmBox = DialogBoxes:new(
        "You have a saved game. Continue?", 
        {"Cancel", function() end}, {"Continue >>", function() newGame() end}
    )
end

function menu:enter()
    if love.filesystem.exists("map.lua") then
        menuButtons.start.y = 2*menuButtons.start.height*2
        menuButtons.options.y = 3*menuButtons.options.height*2
        menuButtons.quit.y = 4*menuButtons.quit.height*2 
        menuButtons.debugBtn.y = 5*menuButtons.debugBtn.height*2 
        
        menuButtons.start.action = function() menuConfirmBox:show() end
    
        table.insert(menuButtons, GenericButton(1, "Continue", function() switchState(game) end))
    end
end

function menu:update(dt)
    if not DialogBoxes:present() then
        for _,button in pairs(menuButtons) do
            button:update()
        end
    end
end

function menu:draw()
    for _,button in pairs(menuButtons) do
        button:draw()
    end
    
    DialogBoxes:draw()
    
    love.graphics.printf("Clay", 0, 50, the.screen.width, "center")
    love.graphics.printf("M - Mute", 0, menuButtons.debugBtn.y + 100, the.screen.width, "center")
end

function menu:mousereleased(x,y,button)
    if button == "l" then
        if not DialogBoxes:present() then
            for _,button in pairs(menuButtons) do
                button:mousereleased(x,y,button)
            end
        end
    end
end
