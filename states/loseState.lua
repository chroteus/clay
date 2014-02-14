loseState = {}

function loseState:init()
    loseText = "You lost the battle."
    
    --loseContBtn = Butto
end

function loseState:update(dt)

end

function loseState:draw()
    love.graphics.printf(loseText, 0, the.screen.height/2, the.screen.width, "center")

end
