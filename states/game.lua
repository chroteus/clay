game = {}

function game:init()    
    initMap()
    
    charScrBtn = Button(the.screen.width-123, the.screen.height-69, 120, 40, "(C)haracter", function() Gamestate.switch(charScr) end)
end

function game:enter()
    enteredMap()

    love.mouse.setVisible(false)
    love.mouse.setGrabbed(true)
end

function game:update(dt)
    updateMap(dt)
    
    charScrBtn:update()
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
    local guiRectH = 25
    love.graphics.setColor(0,0,0,90)
    love.graphics.rectangle("fill", 0, the.screen.height-guiRectH, the.screen.width, guiRectH)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", 0, the.screen.height-guiRectH, the.screen.width, guiRectH)
    love.graphics.setColor(255,255,255)
    love.graphics.printf("| "..Player.country.." | Level: "..Player.level.." | XP: "..Player.xp.."/"..Player.xpToUp, 10, the.screen.height-20, the.screen.width, "left")

    charScrBtn:draw()
end

function game:mousepressed(x, y, button)
    mousepressedMap(x, y, button)
end

function game:mousereleased(x,y,button)
    charScrBtn:mousereleased(x,y,button)
end

function game:keyreleased(key)
    if key == "escape" then
        Gamestate.switch(pause)
    elseif key == "c" then
        Gamestate.switch(charScr)
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
