-- Fade: A state between main states. Fades in black bg and fade out to new state.

fade = {}

function switchState(state)
    Gamestate.switch(fade)
    fade.nextState = state
end

function fade:init()
    fade.rect = {
        x = 0,
        y = 0,
        width = the.screen.width,
        height = the.screen.height,
        color = {10,10,10},
        alpha = 0,
    }
end

function fade:enter(prev)
    fade.prevState = prev
    fade.drawNext = false
    
    local function secondTween()
        fade.drawNext = true
        
        if fade.nextState.init ~= nil then
            fade.nextState:init()
        end
        
        if fade.nextState.enter ~= nil then
            fade.nextState:enter()
        end
        
        Timer.tween(0.30, fade.rect,  {alpha = 0}, "in-quad", function() Gamestate.switch(fade.nextState) end)
    end
    
    Timer.tween(0.20, fade.rect, {alpha = 255}, "out-quad", secondTween)
end

function fade:draw()
    if not fade.drawNext then
        fade.prevState:draw()
    elseif fade.drawNext then
        fade.nextState:draw()
    end
    
    local rect = fade.rect
    love.graphics.setColor(rect.color[1], fade.rect.color[2], fade.rect.color[3], fade.rect.alpha)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height)
    love.graphics.setColor(255,255,255)
end
