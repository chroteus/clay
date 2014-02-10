--[[ 
"The" module. Makes it easy to access love's functions. (ex: <the.screen.width>
instead of <love.graphics.getWidth()>)
Don't forget to call updateThe() function in love.update and loadThe() in love.load().

Note: You can just call loadThe() in both places. But calling updateThe in update function looks better.
]]--

oldX, oldY = love.mouse.getPosition()
slow = 2 -- half as fast

function loadThe()
    the = {
        screen = {
            width = love.graphics.getWidth(),
            height = love.graphics.getHeight()
        },
    
        mouse = {
            x = love.mouse.getX(),
            y = love.mouse.getY(),
            width = 1,
            height = 1
        },
        
        cell = {
            width = 8,
            height = 8
        },
    
        fps = love.timer.getFPS()
    }
end

function updateThe()
    loadThe()
end
