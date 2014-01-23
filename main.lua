-- Libraries
Timer = require "lib.hump.timer"
Camera = require "lib.hump.camera"
Gamestate = require "lib.hump.gamestate"
class = require "lib.middleclass"

require "lib.the" -- Gives easy access info on such things as screen width, height, fps, etc.
require "lib.gui" -- GUI lib. Has Buttons only so far.

-- States
require "states.menu"
require "states.countrySelect"
require "states.game"

-- Misc
require "class.player"
require "misc.map"

function love.load()
    love.window.setMode(800, 576)
    --love.window.setFullscreen(true)
    --love.mouse.setVisible(false)
    --slove.mouse.setGrabbed(true)
    --love.graphics.setDefaultFilter("nearest", "nearest") -- Turn off AA.

    loadThe()
    
    Player:initialize()
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end

function love.update(dt)
    updateThe()
    Timer.update(dt)
end

function love.draw()

end

function love.mousepressed(x, y, button)

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

function checkCol(a, b) -- Short version of checkCollision. To be used if both objects have x, y, width and height values.
  return a.x < b.x+b.width and
         b.x < a.x+a.width and
         a.y < b.y+b.height and
         b.y < a.y+a.height
end
