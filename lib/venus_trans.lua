local transitions = {}

transitions.slide = {}
local ts = transitions.slide

transitions.slide.state = {}

function transitions.slide.state:draw()
    if ts.pre then
        love.graphics.push()
        love.graphics.translate(ts.pre.x, ts.pre.y)
        if ts.pre.state.draw then ts.pre.state:draw() end
        love.graphics.pop()
    end
    
    if ts.to then 
        love.graphics.push()
        love.graphics.translate(ts.to.x, ts.to.y)
        if ts.to.state.draw then ts.to.state:draw() end
        love.graphics.pop()
    end
end

transitions.slide.switch = function(to, ...)
    ts.pre = {x = 0, y = 0, state = venus.current}
    ts.to = {x = love.window.getWidth(), y = 0, state = to}  
    
    if to.init then to.init(); to.init = nil end
    venus._switch(ts.state)

    Timer.tween(1, ts.pre, {x = -love.window.getWidth()}, "out-quad")
    Timer.tween(1, ts.to, {x = 0}, "out-quad", function() venus._switch(to) end)
end

transitions.slide.draw = function()
    ts.state:draw()
end

return transitions
