diplScr = {} -- Diplomacy screen
diplScr.margin = 10

function diplScr:init()
    diplCam = Camera(the.screen.width/2, the.screen.height/2)
end

function diplScr:enter()    
    randBg()
end

function diplScr:update(dt)

end

function diplScr:draw()
    diplCam:attach()
    
    for i,foe in ipairs(Player:returnCountry(true).foes) do
        love.graphics.printf(foe.name, 0, diplScr.margin+(50*i), the.screen.width, "center")
        
        local ball = foe.miniature
        ball:setFilter("nearest", "nearest")
        love.graphics.push()
        love.graphics.scale(2)
        love.graphics.draw(ball, 290, (diplScr.margin+((50/2)*i))-ball:getHeight()/2)
        love.graphics.pop()
    end
    

    diplCam:detach()
end

function diplScr:mousepressed(x,y,button)
    if button == "wu" then
        Timer.tween(0.1, diplCam, {y = diplCam.y - 20})
    elseif button == "wd" then
        Timer.tween(0.1, diplCam, {y = diplCam.y + 20})
    end
end

function diplScr:keyreleased(key)
    if key == "tab" or key == "escape" then
        Gamestate.switch(game)
    end
end
