loseState = {}
loseState.msg = "" -- set in battle.lua

function loseState:init()
    loseImg = love.graphics.newImage("assets/image/loseImg.png")
    contBtn = GenericButton(the.screen.height/2 + 100, "Continue >>", function() Gamestate.switch(game) end)
end

function loseState:update(dt)
    contBtn:update()
end

function loseState:draw()
    love.graphics.draw(loseImg, the.screen.width/2-loseImg:getWidth()/2, the.screen.height/2-loseImg:getHeight())
    love.graphics.printf(loseState.msg, 0, the.screen.height/2 + 50, the.screen.width, "center") 
    contBtn:draw()
end

function loseState:mousereleased(x,y,button)
    contBtn:mousereleased(x,y,button)
end
