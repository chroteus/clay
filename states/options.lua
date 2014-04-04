options = {}

prefs = {
    lowresMap = false,
    noCanvas = false,
    firstPlay = true,
}
    
function savePrefs()
    local t = "return {"
    for k,v in pairs(prefs) do
        local v = tostring(v)
        t = t..k.."="..v..","
    end
    t = t.."}"
        
    love.filesystem.write("prefs.lua", t)
end
    
function loadPrefs()
    if love.filesystem.exists("prefs.lua") then
        local prefsFile = love.filesystem.load("prefs.lua")
        prefs = prefsFile() -- calling return function.
    end
end

function options:init()
    options.fixTxt = "Fixes"

    options.btn = {
        lowresMap = GenericButton(1.5, "Low res map", 
            function() 
                if prefs.lowresMap == false then
                    prefs.lowresMap = true
                    options.fixTxt = "Applied lowres map patch."
                    mapImg = love.graphics.newImage("assets/image/lowresMap.jpg")
                else
                    prefs.lowresMap = false
                    options.fixTxt = "Canceled lowres map patch."
                    mapImg = love.graphics.newImage("assets/image/map.jpg")
                end
            end),
            
        noCanvas = GenericButton(3, "Enable/Disable canvas",
            function()
                if prefs.noCanvas == false then
                    prefs.noCanvas = true
                    options.fixTxt = "Disabled canvases."
                else
                    prefs.noCanvas = false
                    options.fixTxt = "Enabled canvases."
                end
            end),
        
        quit = GenericButton(4.5, "<< Back",
            function()
                Gamestate.switch(menu)
            end),
    }
end

function options:enter()
    loadPrefs()
end

function options:update(dt)
    for _,btn in pairs(options.btn) do
        btn:update()
    end
end

function options:draw()
    love.graphics.printf(options.fixTxt, 0, 50, the.screen.width, "center")
    for _,btn in pairs(options.btn) do
        btn:draw()
    end
    
    love.graphics.printf("Use low res map. Turn on if you have old hardware and you're getting errors.", 0, options.btn.lowresMap.y-30, the.screen.width, "center")    
    love.graphics.printf("Improves looks of cells, decreases performance. Turn this on if you're getting errors.", 0, options.btn.noCanvas.y-30, the.screen.width, "center")    
end

function options:mousereleased(x,y,button)
    for _,btn in pairs(options.btn) do
        btn:mousereleased(x,y,button)
    end
end

function options:leave()
    savePrefs()
end
