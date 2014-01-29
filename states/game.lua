game = {}

function game:init()    
    initMap()
end

function game:enter()
    love.mouse.setVisible(false)
    love.mouse.setGrabbed(true)
end

function game:update(dt)
    updateMap(dt)
end

function game:draw()
    drawMap()
end

function game:mousepressed(x, y, button)
    mousepressedMap(x, y, button)
end

function game:keyreleased(key)
    if DEBUG then
        if key == "e" then
            if editMode.enabled then
                editMode.enabled = false
            else
                editMode.enabled = true
            end
        end
        
        if editMode.enabled then
            if key == "t" then
                Gamestate.switch(selection)
            end
        end
    end
end
