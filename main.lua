DEBUG = false

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
require "states.tutorial"
require "states.battle"
require "states.selection"
require "states.pause"

-- Misc
require "class.player"
require "misc.map"

function love.load()
    love.window.setMode(800, 576)
    --love.window.setFullscreen(true)
    --love.graphics.setDefaultFilter("nearest", "nearest") -- Turn off AA.

    loadThe()
    
    Player:initialize()
    Gamestate.registerEvents()
    
    if DEBUG then
        Gamestate.switch(game)
        Player.country = "Canada"
    else
        Gamestate.switch(menu)
    end
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

-- Convert a table into a string. Used to save map.
-- Written by Kikito.
function serialize(t)
  local serializedValues = {}
  local value, serializedValue
  for i=1,#t do
    value = t[i]
    serializedValue = type(value)=='table' and serialize(value) or value
    table.insert(serializedValues, serializedValue)
  end
  return string.format("{ %s }", table.concat(serializedValues, ', ') )
end
