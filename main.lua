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
require "states.transState"
require "states.upg"
require "states.fade"

-- Misc
require "class.player"
require "class.base"
require "class.skill"
require "class.item"
require "class.region"
require "objects.skills"
require "objects.items"
require "misc.map"
require "misc.mapHelp"
require "misc.msgBox"
require "misc.dialogBox"
require "misc.randEvent"
require "misc.screenBtn"
require "lib.collision"
require "lib.math"

function love.load()
    math.randomseed(os.time())

    love.window.setMode(800, 576, {fullscreen=true, fullscreentype="desktop", vsync=true})
    love.window.setTitle("Clay")
    --love.graphics.setDefaultFilter("nearest", "nearest") -- Turn off AA.

    loadThe()
    screenBtn:initialize()
    
    Gamestate.registerEvents()
    
    if DEBUG then
        Gamestate.switch(game)
    else
        Gamestate.switch(menu)
    end
    
    gameFont = love.graphics.newFont("assets/Sansation_Regular.ttf", 16)
    bigFont = love.graphics.newFont("assets/Sansation_Regular.ttf", 22)
    love.graphics.setFont(gameFont)
    
    -- Backgrounds
    local bgTable = love.filesystem.getDirectoryItems("assets/image/bg")
    
    function randBg()
        local randChoice = math.random(#bgTable)
        local randBg = bgTable[randChoice]
        scrBgImg = love.graphics.newImage("assets/image/bg/"..randBg)
    end
    
    bgLineImg = love.graphics.newImage("assets/image/bgLine.png")
    bgLineImg:setWrap("repeat", "repeat")
    bgLineQ = love.graphics.newQuad(0,0,the.screen.width,the.screen.height,bgLineImg:getWidth(),bgLineImg:getHeight())
    
    randBg()
    loadPrefs()
    
    -- Music
    TEsound.playLooping("assets/sounds/music.ogg", "music")
    musicPaused = false
    
    
    msgBox:add("TAB - Character screen")
    msgBox:add("Welcome to Clay!")
end

function love.update(dt)
    updateThe()
    DialogBoxes:update(dt)
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
            
        -- lines
        love.graphics.draw(bgLineImg,bgLineQ,0,0)
    
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
    elseif key == "home" then
        debug.debug()
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

function bgPrintf(str, x, y, limit, alignment)
    -- prints with a dark background behind the text
    love.graphics.setColor(50,50,50)
    love.graphics.printf(str, x+1, y+1, limit, alignment)
    love.graphics.setColor(255,255,255)
    love.graphics.printf(str, x, y, limit, alignment)
end
    
