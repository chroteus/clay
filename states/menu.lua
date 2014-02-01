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
        createMap()
        Gamestate.switch(countrySelect)
    end
    
    menuButtons = {
        -- GenericButton(order, text, action)
        start = GenericButton(1, "New Game", function() newGame() end),
        quit = GenericButton(2, "Exit", function() love.event.quit() end),
        debugBtn = GenericButton(5.5, "Dev Mode: OFF", function() debugBtnFunc() end),
    }
end

function menu:enter()
    if love.filesystem.exists("map.lua") then
        menuButtons.quit.y = 3*45*2 -- Puts the button below continue button if save file exists.
        menuButtons.start.y = 2*45*2
    
        local function continueGame()
            loadMap()
            Gamestate.switch(game)
        end
    
    
        table.insert(menuButtons, GenericButton(1, "Continue", function() continueGame() end))
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
end

function menu:mousereleased(x,y,button)
    if button == "l" then
        for _,button in pairs(menuButtons) do
            button:mousereleased(x,y,button)
        end
    end
end
