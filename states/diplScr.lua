diplScr = {} -- Diplomacy screen
diplScr.margin = 10

function diplScr:init()
    diplCam = Camera(the.screen.width/2, the.screen.height/2)
end

function diplScr:enter()
    love.mouse.setVisible(true)    
    randBg()
    
    love.graphics.setFont(bigFont)
end

function diplScr:update(dt)
    screenBtn:update()
end

function diplScr:draw()
    diplCam:attach()
    
    for i,foe in ipairs(Player:returnCountry(true).foes) do
        love.graphics.printf(foe.name, 0, diplScr.margin+(50*i), the.screen.width, "center")

        local ball = foe.miniature
        ball:setFilter("nearest", "nearest")
        love.graphics.push()
        love.graphics.scale(2)
        love.graphics.draw(ball, (the.screen.width/4)-(ball:getWidth()*4), (diplScr.margin+((50/2)*i))-ball:getHeight()/2)
        love.graphics.pop()
    end
    
    diplCam:detach()
    
    screenBtn:draw()
end

function diplScr:mousepressed(x,y,button)
    if button == "wu" then
        Timer.tween(0.2, diplCam, {y = diplCam.y - 40}, "out-quad")
    elseif button == "wd" then
        Timer.tween(0.2, diplCam, {y = diplCam.y + 40}, "out-quad")
    end
end

function diplScr:mousereleased(x,y,button)
    screenBtn:mousereleased(x,y,button)
end

function diplScr:keyreleased(key)
    if key == "tab" or key == "escape" then
        Gamestate.switch(game)
    end
end

function diplScr:leave()
    love.graphics.setFont(gameFont)
end
