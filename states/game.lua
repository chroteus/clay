game = {}

function game:init()
    initMap()
    
    
    --[[ REWRITE ]]
    -- If death message was printed already previous game, don't print it again at the start of the game.
    for _,country in pairs(countries) do
        local num = 0
        
        
    end
end

function game:enter()
    enteredMap()
    game.timerHandle = Timer.addPeriodic(2, function() checkIfDead() end)
    
    love.mouse.setVisible(false)
    love.mouse.setGrabbed(true)
end

function game:update(dt)
    if not DialogBoxes:present() then
        updateMap(dt)
        msgBox:update(dt)
        randEvent(dt)
    end
    
    DialogBoxes:update(dt)
end

function game:draw()
    drawMap()
    
    
    if editMode.enabled then
        love.graphics.printf("Edit Mode: Q - Select Country, E - Exit out of edit mode, B - Disable borders", 0, 0, the.screen.width, "left")
        love.graphics.printf("Current chosen country: "..editMode.country, 0, 20, the.screen.width, "left")
    else
        if DEBUG then
            love.graphics.printf("E - Enter edit mode.", 0, 0, the.screen.width, "left")
        end
    end
    
    -- GUI
    local guiRectH = 30
    love.graphics.setColor(guiColors.bg)
    love.graphics.rectangle("fill", 0, the.screen.height-guiRectH, the.screen.width, guiRectH)
    love.graphics.setColor(guiColors.fg)
    love.graphics.rectangle("line", 0, the.screen.height-guiRectH, the.screen.width, guiRectH)
    love.graphics.printf("| "..Player.country.." | Level: "..Player.level.." | XP: "..Player.xp.."/"..Player.xpToUp.." | Money: "..Player.money.."G", 10, the.screen.height-25, the.screen.width, "left")
    
    if prefs.firstPlay then
        love.graphics.printf("Press 'Tab'", 0, the.screen.height-25, the.screen.width-15, "right")
    end
    
    love.graphics.setColor(255,255,255)
    
    DialogBoxes:draw()
    msgBox:draw()
end

function game:mousepressed(x, y, button)
    if not DialogBoxes:present() then
        mousepressedMap(x, y, button)
    end
end

function game:mousereleased(x,y,button)
    DialogBoxes:mousereleased(x,y,button)
end

function game:keyreleased(key)
    if key == "escape" then
        Gamestate.switch(pause)
    elseif key == "tab" then
        Gamestate.switch(transState)
    end

    if DEBUG then
        if key == "b" then
            if mapBorderCheck then
                mapBorderCheck = false
            else
                mapBorderCheck = true
            end
        end
    
        if key == "e" then
            if editMode.enabled then
                editMode.enabled = false
            else
                editMode.enabled = true
            end
        end
        
        if editMode.enabled then
            if key == "q" then
                Gamestate.switch(selection)
            end
        end
    end
end

function game:leave()
    Timer.cancel(game.timerHandle)
end
