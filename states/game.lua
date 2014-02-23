game = {}

function game:init()    
    initMap()
end

function game:enter()
    enteredMap()

    love.mouse.setVisible(false)
    love.mouse.setGrabbed(true)
end

function game:update(dt)
    updateMap(dt)
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
    love.graphics.printf("Level: "..Player.level.." XP: "..Player.xp.."/"..Player.xpToUp, 10, the.screen.height-20, the.screen.width, "left")
end

function game:mousepressed(x, y, button)
    mousepressedMap(x, y, button)
end

function game:keypressed(key)

end

function game:keyreleased(key)
    if key == "escape" then
        Gamestate.switch(pause)
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
    saveMap()
end
