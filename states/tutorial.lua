tutorial = {}

function tutorial:init()
    tutText = [[
    WASD/Mouse - Move camera
    ESC = Menu
    Mouse wheel - Zoom in/out
     ]]
    
    tutGameBtn = GenericButton(2, "Start >>", function() Gamestate.switch(game) end)
end

function tutorial:update(dt)
    tutGameBtn:update()
end

function tutorial:draw()
    tutGameBtn:draw()
    love.graphics.printf(tutText, 0, 100, the.screen.width, "center")
end

function tutorial:mousereleased(x,y,button)
    tutGameBtn:mousereleased(x,y,button)
end
