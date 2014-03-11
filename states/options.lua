options = {}

prefs = {
    lowresMap = false,
    noCanvas = false
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
    if love.filesystem.exists("prefs") then
        local prefsFile = love.filesystem.load("prefs.lua")
        prefs = prefsTable() -- calling return function.
    end
end

function options:init()
    options.fixTxt = "Fixes"

    options.btn = {
        fix1 = GenericButton(1, "Low res map", 
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
            
        fix2 = GenericButton(2, "Disable canvases",
            function()
                if prefs.noCanvas == false then
                    prefs.noCanvas = true
                    options.fixTxt = "Disabled canvases."
                else
                    prefs.noCanvas = false
                    options.fixTxt = "Enabled canvases."
                end
            end),
        
        quit = GenericButton(4, "<< Back",
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
end

function options:mousereleased(x,y,button)
    for _,btn in pairs(options.btn) do
        btn:mousereleased(x,y,button)
    end
end

function options:leave()
    savePrefs()
end
