tutorial = {}
tutorial.fadeInit = true

function tutorial:init()
    tutText = [[
    Map:
    WASD/Mouse - Move camera
    Mouse wheel - Zoom in/out
    
    ESC - Menu
    Tab - Character Screen
    
    Battle:
    Space - Attack 
    Hotkey (or click) - Skill
     ]]
    
    tutGameBtn = GenericButton(4, "Start >>", function() switchState(game) end)
end

function tutorial:enter()
    love.graphics.setFont(bigFont)
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

function tutorial:leave()
end
