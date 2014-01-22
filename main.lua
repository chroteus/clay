-- Libraries
Timer = require "lib.hump.timer"
Camera = require "lib.hump.camera"
class = require "lib.middleclass"
require "lib.the" -- Gives general info on such things as screen width, height, fps, etc.

require "map"

function love.load()
    love.window.setMode(800, 576)
    --love.window.setFullscreen(true)
    love.mouse.setVisible(false)
    love.mouse.setGrabbed(true)
    --love.graphics.setDefaultFilter("nearest", "nearest") -- Turn off AA.

    loadThe()
    initMap()
    
    the.mouse.x = the.screen.width/2
    the.mouse.y = the.screen.height/2
end

function love.update(dt)
    updateThe()
    updateMap(dt)
    Timer.update(dt)
end

function love.draw()
    drawMap()
end

function love.mousepressed(x, y, button)
    mousepressedMap(x, y, button)
end

-- Collision detection function.
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
