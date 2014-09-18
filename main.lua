DEBUG = false

-- Libraries
Timer = require "lib.hump.timer"
Camera = require "lib.amo" --require "lib.hump.camera"
venus = require "lib.venus"

Gamestate = venus
class = require "lib.middleclass"
loader = require "lib.love-loader"

require "lib.the" -- Gives easy access info on such things as screen width, height, fps, etc.
require "lib.gui" -- GUI lib.
require "lib.TEsound"

require "misc.worldTime"

-- States
require "states.menu"
require "states.countrySelect"
require "states.game"
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
require "states.loading"
require "states.shop"
require "states.inventory"

require "class.player"
require "class.base"
require "class.skill"
require "class.item"
require "class.region"
require "class.buff"
require "class.upgrade"

require "objects.skills"
require "objects.items"
require "objects.buffs"
require "objects.upgrades"

require "misc.map"
require "misc.mapHelp"
require "misc.msgBox"
require "misc.dialogBox"
require "misc.randEvent"
require "misc.screenBtn"
require "misc.infoBox"

require "lib.collision"
require "lib.math"

math.random = love.math.random

function love.load()
    math.randomseed(os.time())
    
    Gamestate.registerEvents()
    venus.effect = "fade"
    venus.duration = 0.6

    love.window.setMode(0, 0, {fullscreen=true, fullscreentype="desktop", vsync=true})
    love.window.setTitle("Clay")
   -- love.graphics.setDefaultFilter("nearest", "nearest") -- Turn off AA.

    loadThe()

    -- Backgrounds
    local bgTable = love.filesystem.getDirectoryItems("assets/image/bg")
    
    function randBg()
        local randChoice = math.random(#bgTable)
        local randBg = bgTable[randChoice]
        scrBgImg = love.graphics.newImage("assets/image/bg/"..randBg)
    end
    
    function drawBallBg()
		if venus.current ~= game and venus.current ~= battle then
			love.graphics.setBackgroundColor(45,45,55)
			local imgW, imgH = scrBgImg:getWidth(), scrBgImg:getHeight()
			
			-- draw the image at the right bottom corner.
			love.graphics.draw(scrBgImg, the.screen.width-imgW, the.screen.height-imgH)
			
			-- tint
			love.graphics.setColor(45,45,55, 120)
			love.graphics.rectangle("fill", 0,0, the.screen.width, the.screen.height)
				
			-- lines
			love.graphics.setColor(0,0,0, 200)
			love.graphics.draw(bgLineImg,bgLineQ,0,0)
		
			love.graphics.setColor(255,255,255)
		end
    end
    
    bgLineImg = love.graphics.newImage("assets/image/bgLine.png")
    bgLineImg:setWrap("repeat", "repeat")
    bgLineQ = love.graphics.newQuad(0,0,the.screen.width,the.screen.height,bgLineImg:getWidth(),bgLineImg:getHeight())
    
    randBg()
    
    screenBtn:initialize()
    
    if DEBUG then
        Gamestate.switch(game)
    else
        Gamestate.switch(menu)
    end
    
    -- Font handling
    gameFont = {}
    local fontHandle = {
        __index = function(t, k)
            gameFont[k] =  love.graphics.newFont("assets/Sansation_Regular.ttf", k)
            return gameFont[k]
        end
    }
    setmetatable(gameFont, fontHandle)
    gameFont["default"] = gameFont[16]
    
    love.graphics.setFont(gameFont[16])
    
    loadPrefs()
    
    -- Music
    musicFiles = love.filesystem.getDirectoryItems("assets/music/main")
    for i=1,#musicFiles do musicFiles[i] = "/assets/music/main/"..musicFiles[i] end
        
    TEsound.playLooping(musicFiles, "music", math.huge, .6)
    musicMute = false
end

function love.update(dt)
    updateThe()
    Timer.update(dt)
    TEsound.cleanup()
    DialogBoxes:update(dt)
end

function love.draw()
    drawBallBg()
end

function love.keypressed(key, u)
	if love.keyboard.isDown("lshift") then
		if key == "m" then
			Player.money = Player.money + 100
		end
	else
		if key == "m" then
			if not musicMute then
				TEsound.volume("all", 0)
				musicMute = true
			else
				TEsound.volume("all", 1)
				musicMute = false
			end
		elseif key == "home" and DEBUG then
			debug.debug()
		end
	end

    DialogBoxes:keypressed(key, u)
end
  
function love.mousereleased(x, y, button)
    DialogBoxes:mousereleased(x,y,button)
end

function love.textinput(t)
    DialogBoxes:textinput(t)
end

function love.quit()
    if venus.current == game then
        saveMap() -- save on quit
    end
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


-- Count the number of times a value occurs in a table.
-- Counts values equal to item via the equality operator.
function table_count(tt, value)
  local count = 0
  for ii,xx in pairs(tt) do
    if xx == value then count = count + 1 end
  end
  return count
end

-- Removes duplicates from a table
function removeDuplicates(tt)
  local newtable = {}
  for ii,xx in ipairs(tt) do
    if table_count(newtable, xx) == 0 then
      newtable[#newtable+1] = xx
    end
  end
  return newtable
end

function CodeToUTF8 (Unicode)
    if (Unicode <= 0x7F) then return string.char(Unicode); end;

    if (Unicode <= 0x7FF) then
      local Byte0 = 0xC0 + math.floor(Unicode / 0x40);
      local Byte1 = 0x80 + (Unicode % 0x40);
      return string.char(Byte0, Byte1);
    end;

    if (Unicode <= 0xFFFF) then
      local Byte0 = 0xE0 +  math.floor(Unicode / 0x1000);
      local Byte1 = 0x80 + (math.floor(Unicode / 0x40) % 0x40);
      local Byte2 = 0x80 + (Unicode % 0x40);
      return string.char(Byte0, Byte1, Byte2);
    end;

    return "";                                   -- ignore UTF-32 for the moment
end

 
