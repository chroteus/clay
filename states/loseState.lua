loseState = {}

function loseState:init()
    loseImg = love.graphics.newImage("assets/image/loseImg.png")
    winBtn = GenericButton(the.screen.height/2 + 50, "Continue >>", function() Gamestate.switch(game) end)
end

function loseState:update(dt)
    winBtn:update()
end

function loseState:draw()
    love.graphics.draw(loseImg, the.screen.width/2-loseImg:getWidth()/2, the.screen.height/2-loseImg:getHeight())
    winBtn:draw()
end

function loseState:mousereleased(x,y,button)
    winBtn:mousereleased(x,y,button)
end
