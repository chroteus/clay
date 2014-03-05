pause = {}

function pause:init()
    pauseButtons = {
        back = GenericButton(1, "Back", function() Gamestate.switch(game) end),
        save = GenericButton(2.5, "Save", function() saveMap() gameSaved = true end),
        --menuBtn = GenericButton(4, "Menu", function() Gamestate.switch(menu) end)
    }
    
    gameSaved = false
end

function pause:enter()
    love.mouse.setVisible(true)
    love.mouse.setGrabbed(false)
    gameSaved = false
    
    randBg()
end

function pause:update(dt)
    for _,btn in pairs(pauseButtons) do
        btn:update()
    end
end

function pause:draw()
    love.graphics.printf("Pause", 0, 40, the.screen.width, "center")
    if gameSaved then
        if DEBUG then
            love.graphics.printf("Saved the map in: "..love.filesystem.getSaveDirectory(), 0, 200, the.screen.width, "center")
        else
            love.graphics.printf("Saved!", 0, 200, the.screen.width, "center")
        end
    end
    
    for _,btn in pairs(pauseButtons) do
        btn:draw()
    end
end

function pause:mousereleased(x,y,button)
    for _,btn in pairs(pauseButtons) do
        btn:mousereleased(x,y,button)
    end
end

function pause:keyreleased(key)
    if key == "escape" then
        Gamestate.switch(game)
    end
end
