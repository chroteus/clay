DEBUG = false

-- Libraries
Timer = require "lib.hump.timer"
Camera = require "lib.hump.camera"
Gamestate = require "lib.hump.gamestate"
class = require "lib.middleclass"

require "lib.the" -- Gives easy access info on such things as screen width, height, fps, etc.
require "lib.gui" -- GUI lib.
require "lib.TEsound"

-- States
require "states.menu"
require "states.countrySelect"
require "states.game"
require "states.tutorial"
require "states.battle"
require "states.selection"
require "states.pause"
require "states.winState"
require "states.loseState"
require "states.charScr"
require "states.options"
require "states.diplScr"
require "states.gameOver"

-- Misc
require "class.player"
require "class.base"
require "class.skill"
require "objects.skills"
require "misc.map"
require "misc.msgBox"
require "lib.dialogBox"
require "misc.randEvent"

function love.load()
    math.randomseed(os.time())

    love.window.setMode(800, 576, {fullscreen=true, fullscreentype="desktop", vsync=true})
    love.window.setTitle("Clay")
    --love.graphics.setDefaultFilter("nearest", "nearest") -- Turn off AA.

    loadThe()
    
    Gamestate.registerEvents()
    
    if DEBUG then
        Gamestate.switch(game)
    else
        Gamestate.switch(menu)
    end
    
    gameFont = love.graphics.newFont("assets/Sansation_Regular.ttf", 16)
    love.graphics.setFont(gameFont)
    
    -- Backgrounds
    local bgTable = love.filesystem.getDirectoryItems("assets/image/bg")
    
    function randBg()
        local randChoice = math.random(#bgTable)
        local randBg = bgTable[randChoice]
        scrBgImg = love.graphics.newImage("assets/image/bg/"..randBg)
    end
    
    randBg()
    loadPrefs()
    
    -- Music
    TEsound.playLooping("assets/sounds/music.ogg", "music")
    musicPaused = false
end

function love.update(dt)
    updateThe()
    DialogBoxes:update()
    Timer.update(dt)
    TEsound.cleanup()
end

function love.draw()
    
    if Gamestate.current() ~= battle and Gamestate.current() ~= winState and Gamestate.current() ~= loseState then
        love.graphics.setBackgroundColor(45,45,55)
        local imgW, imgH = scrBgImg:getWidth(), scrBgImg:getHeight()
        -- draw the image at the right bottom corner.
        love.graphics.draw(scrBgImg, the.screen.width-imgW, the.screen.height-imgH)
        
        -- tint
        love.graphics.setColor(45,45,55,150)
        love.graphics.rectangle("fill", 0,0, the.screen.width, the.screen.height)
        love.graphics.setColor(255,255,255)
    end
end

function love.keypressed(key, u)
    if key == "m" then
        if not musicPaused then
            TEsound.pause("music")
            musicPaused = true
        else
            TEsound.resume("music")
            musicPaused = false
        end
    end 
end


function love.mousereleased(x, y, button)
    DialogBoxes:mousereleased(x,y,button)
end

function love.quit()
    if Gamestate.current() == game then
        saveMap() -- save on quit
    end
end

function adjCellsOf(rowInd, columnInd)
    local adj = {{0,0,0},
                 {0,0,0},
                 {0,0,0}
                }
                
    adj[1][1] = {rowIndex=rowInd-1, columnIndex=columnInd-1}
    adj[1][2] = {rowIndex=rowInd-1, columnIndex=columnInd}
    adj[1][3] = {rowIndex=rowInd-1, columnIndex=columnInd+1}
                            
    adj[2][1] = {rowIndex=rowInd, columnIndex=columnInd-1}
    adj[2][2] = {rowIndex=rowInd, columnIndex=columnInd}
    adj[2][3] = {rowIndex=rowInd, columnIndex=columnInd+1}
                            
    adj[3][1] = {rowIndex=rowInd+1, columnIndex=columnInd-1}
    adj[3][2] = {rowIndex=rowInd+1, columnIndex=columnInd}
    adj[3][3] = {rowIndex=rowInd+1, columnIndex=columnInd+1}

    return adj
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
