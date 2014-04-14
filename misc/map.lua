require "objects.countries"

map = {}
mapW = 300
mapH = 130

function rmSpc(str)
    local s = str
    s = string.gsub(s, " ", "")
    
    return s
end

function convertStr(str)
    -- converts a string like "UnitedStates" into "United States"
    local s = str
    s = string.gsub(s, "%u", " %1") -- put a space before each upper case letter
    s = string.gsub(s, " ", "", 1) -- remove first space
    return s
end


function createMap() -- Fresh map. Used to load map at first play.
    love.filesystem.remove("map.lua")
    local mapFile = love.filesystem.newFile("assets/map.lua")
    mapFile:open("r")
    local mapString = mapFile:read()
    local mapTable = assert(loadstring(mapString))()
    
    for _,region in pairs(mapTable[1]) do
        local country = idToCountry(region[1])
        table.insert(map, Region(country.id, country.color, country.name, region[2]))
    end
    
    mapFile:close()
end

function loadMap() -- Load an existing map.
    local mapFile = love.filesystem.load("map.lua")
    local mapTable = mapFile() -- Call the return of mapFile
    
    for _,region in pairs(mapTable[1]) do
        local country = idToCountry(region[1])
        table.insert(map, Region(country.id, country.color, country.name, region[2]))
    end
    
    for k,v in pairs(mapTable[2]) do
        Player[k] = v
    end
    
    for countryN,foeTable in pairs(mapTable[3]) do
        local countryName = convertStr(countryN)
    
        for _,country in pairs(countries) do
            for _,foeId in pairs(foeTable) do
                local foe = countries[foeId]
                if country.name == countryName then
                    if not foe:isFoe(country.name) then
                        foe:war(country)
                    end
                end
            end
        end
    end
    
    
    -- load money values
    for countryN,moneyV in pairs(mapTable[4]) do
        local countryName = convertStr(countryN)
        
        for _,country in pairs(countries) do
            if country.name == countryName then
                country.money = moneyV
            end
        end
    end
    
    Player:returnCountry(true).attack = Player.attack
    Player:returnCountry(true).defense = Player.defense
    Player:returnCountry(true).money = Player.money
end

function saveMap(name)
    local mapFile = name or "map.lua" -- An optional name for map.

    local strToApp = ""
    local function append(str)
        strToApp = strToApp..str
    end
    
    append("return {")
    
    append("{")
    for k,region in pairs(map) do
        append("{"..region.id..",")
        
        append("{")
        for k,vertex in pairs(region.vertices) do
            append(vertex..",")
        end
        
        append("}")
        append("},")
    end
    append("},")
    
    append("{")
    for k,v in pairs(Player) do
        local stringV = ""
        if type(v) == "string" then
            stringV = '"'..v..'"'
        elseif type(v) == "table" then
            stringV = "{"
            for k,v in pairs(v) do
                stringV = stringV..tostring(k).."="..tostring(v.name)
            end
            stringV = stringV.."}"
        
        else
            stringV = tostring(v)
        end
        
        if type(v) ~= "function" then
            append(tostring(k).."="..stringV..",")
        end
    end
    

    
    append("},")

    -- save foes
    append("{")
    for _,country in pairs(countries) do
        if #country.foes > 0 then
            local countryName = country.name
            countryName = rmSpc(countryName)
            
            append(countryName.."={")
            for _,foe in pairs(country.foes) do
                append(foe.id..",")
            end
            append("},")
        end
    end
    append("},")
    
    -- save money for each country
    append("{")
    for _,country in pairs(countries) do
        append(rmSpc(country.name).."="..tostring(country.money)..",")
    end
        
    append("},")
    
    append("}")
    
    love.filesystem.write(mapFile, strToApp)
end

mapImg = love.graphics.newImage("assets/image/map.jpg")

function initMap()    
    currAdjCells = {} -- adjacent cells of the selected cell.

    -----------------------
    --Edit Mode variables--
    
    editMode = {
        enabled = false,
        country = "Ukraine", -- Selected country. Paints this country on map.
        buttons = {},
        
        currPoint = {
            x = -10,
            y = -10,
        },
        
        lastPoint = {
            x = -5,
            y = -5
        },
        
        prevLastPoint = {
            x = -30,
            y = -30,
        },
        
        firstPoint = {
            x = -20,
            y = -20,
        },
        
        fpActive = false, -- first point
            
        radius = 1.5,
        
        currPolygon = {},
        
        polFin = false
    }
    
    function editMode.pair()
        -- pairs x,y values in a polygon table like {10,20, 30,40} into {{10,20}, {30,40}}
    
        local pol = editMode.currPolygon
        local t = {}
        for i=2,#pol, 2 do
            table.insert(t, {pol[i-1], pol[i]})
        end
        
        return t
    end
                

    -- Camera
    mapCam = Camera(2400/2, 1040/2)

    -- mapImg outside of init function because it might be changed in options before init function gets called.
    gridImg = love.graphics.newImage("assets/image/grid.png")
    gridImg:setWrap("repeat","repeat")
    gridQ = love.graphics.newQuad(0,0,mapImg:getWidth()/2,mapImg:getHeight()/2,gridImg:getWidth(),gridImg:getHeight())
    
    mapCam.scale = 1.5


    if love.filesystem.exists("map.lua") then
        loadMap()
    else
        createMap()
    end
end


function enteredMap()
    -- Clear up current adjacent cells table so that none of the cells would be selected.
   -- currAdjCells = {}

    -- Camera isn't limited by borders if true.
    mapBorderCheck = true
end


function updateMap(dt)
    -- Converting camera to mouse coordinates.
    mapMouse = {}
    mapMouse.x, mapMouse.y = mapCam:mousepos()
    
    for _,country in pairs(countries) do
        if #country.foes > 0 then
            country:invade(dt)
        end
    end
    
    ---------------------
    --Moving the camera--
    
    local cameraSpeed = 600/mapCam.scale
    local borderSize = 2

    if love.keyboard.isDown("d") or the.mouse.x > the.screen.width-borderSize then 
        mapCam.x = mapCam.x + cameraSpeed*dt
    elseif  love.keyboard.isDown("a") or the.mouse.x < borderSize then
        mapCam.x = mapCam.x - cameraSpeed*dt
    end
    
    if love.keyboard.isDown("s") or the.mouse.y > the.screen.height-borderSize then 
        mapCam.y = mapCam.y + cameraSpeed*dt
    elseif love.keyboard.isDown("w") or the.mouse.y < borderSize then
        mapCam.y = mapCam.y - cameraSpeed*dt
    end

    
    -----------------------------------
    --Limiting the movement of camera--
    
    if mapBorderCheck then
        local mapWidth, mapHeight = mapCam:worldCoords(the.screen.width, the.screen.height)        
        local mapX, mapY = mapCam:cameraCoords(2400,1040) -- 2400, 1040: Halves of width and height of map image

        if mapCam.x < (the.screen.width/2/mapCam.scale)-1 then
            mapCam.x = (the.screen.width/2/mapCam.scale)-1
        elseif the.screen.width > mapX then
            mapCam.x,_ = mapCam:worldCoords(mapX/2, mapY)
            mapCam.x = mapCam.x - cameraSpeed/2*dt
        end
        
        if mapCam.y < (the.screen.height/2/mapCam.scale)-1 then
            mapCam.y = (the.screen.height/2/mapCam.scale)-1
        elseif the.screen.height > mapY then
            _,mapCam.y = mapCam:worldCoords(mapX, mapY/2)
            mapCam.y = mapCam.y - cameraSpeed/2*dt
        end
    end
    
    --------------
    --Lımit zoom--

    if mapCam.scale < 1.5 then
        mapCam.scale = 1.5
    elseif mapCam.scale > 3 then
        mapCam.scale = 3
    end
    
    -------------
    --Edit Mode--
    
    if editMode.enabled then
        local fp = editMode.firstPoint
        local radius = editMode.radius
        
        if checkCollision(fp.x,fp.y,radius*2,radius*2, mapMouse.x,mapMouse.y,1,1) then
            editMode.fpActive = true
        else
            editMode.fpActive = false
        end
    end
end

function mousepressedMap(x, y, button)
    --------------
    --Zooming in--
       
    if button == "wu" then
        Timer.tween(0.3, mapCam, {scale = mapCam.scale + 0.1}, "out-quad")
    elseif button == "wd" then
        if mapCam.scale > 1.5 then
            Timer.tween(0.3, mapCam, {scale = mapCam.scale - 0.1}, "out-quad")
        end
    end

    -- [[ REWRITE ]]
    if not editMode.enabled then

    end
end

function mousereleasedMap(x,y,button)
    if editMode.enabled then
    
        local fp = editMode.firstPoint
        local cp = editMode.currPoint
        local lp = editMode.lastPoint
        local plp = editMode.prevLastPoint
        
        local radius = editMode.radius
        
        if button == "l" then
            if fp.x < 0 then
                fp.x,fp.y = math.floor(mapMouse.x), math.floor(mapMouse.y)
            end
            
            if checkCollision(fp.x,fp.y,radius*2,radius*2, mapMouse.x,mapMouse.y,1,1) then
                cp.x, cp.y = fp.x, fp.y
                
                if #editMode.currPolygon >= 6 then
                    local country = nameToCountry(editMode.country)
                    
                    table.insert(map, Region(country.id, country.color, editMode.country, editMode.currPolygon))
                    editMode.currPolygon = {}
                    cp.x, cp.y = -20,-20
                    fp.x, fp.y = -10, -10
                    lp.x, lp.y = -5, -5
                    
                    editMode.polFin = true
                end
                
            else
                cp.x, cp.y = math.floor(mapMouse.x), math.floor(mapMouse.y)
            end
            
            plp.x, plp.y = lp.x, lp.y
            lp.x, lp.y = cp.x, cp.y
                        
            for _,region in pairs(map) do
                region:mousereleased(x,y,button)
            end
            
            if not editMode.polFin then
                table.insert(editMode.currPolygon, cp.x)
                table.insert(editMode.currPolygon, cp.y)
            end
            
            editMode.polFin = false
        
        elseif button == "r" then
            if #editMode.currPolygon >= 2 then
                lp.x, lp.y = plp.x, plp.y
                cp.x, cp.y = lp.x, lp.y
                
                table.remove(editMode.currPolygon)
                table.remove(editMode.currPolygon)
            end
        end
    end
end

function drawMap()
    love.graphics.setBackgroundColor(110, 175, 177)

    local drawSelectRect = true
    
    -- Attaches a camera. Everything from now on will be drawn from camera's perspective.
    mapCam:attach()
    
    love.graphics.push()
    love.graphics.scale(2400/mapImg:getWidth())
    love.graphics.draw(mapImg, -1,-1)
    love.graphics.pop()
    
    for _,region in pairs(map) do
        region:draw()
    end
    
    if editMode.enabled then
        local radius = editMode.radius
        local lp = editMode.lastPoint
        local cp = editMode.currPoint
        local fp = editMode.firstPoint
        
       -- love.graphics.setColor(20,20,200)
        love.graphics.circle("fill", lp.x, lp.y, radius)
        love.graphics.circle("fill", cp.x, cp.y, radius)

        if #editMode.currPolygon >= 4 then -- at least 2 vertices are needed to draw a line
            love.graphics.setColor(255,255,255,100)
            love.graphics.line(editMode.currPolygon)
            love.graphics.setColor(225,225,225)
            love.graphics.line(editMode.currPolygon)
        end
        
        local t = editMode.pair()
        for _,vertex in pairs(t) do
            love.graphics.circle("fill", vertex[1], vertex[2], radius)
        end
        
        love.graphics.setColor(255,255,255)
        
        if lp.x > 0 then   
            love.graphics.line(lp.x,lp.y, cp.x,cp.y)
            
        end
        
        if cp.x > 0 then
            if #editMode.currPolygon > 0 then
                love.graphics.line(cp.x,cp.y, mapMouse.x, mapMouse.y)
            end
        end
        
        love.graphics.setColor(255,0,0)
        
        if not editMode.fpActive then
            love.graphics.circle("fill", fp.x, fp.y, radius)    
        else
            love.graphics.circle("fill", fp.x, fp.y, radius*2)
        end
        
        love.graphics.setColor(225,225,225)
    
    end
    
--[[
    love.graphics.push()
    love.graphics.scale(0.25)
    love.graphics.draw(gridImg, -1*mapCam.scale, -1*mapCam.scale)
    love.graphics.pop()
]]--

    
    
    love.graphics.draw(gridImg,gridQ,0,0)
        
    -- Detaches the camera. Things drawn after detach() will not be from camera's perspective.
    -- GUI should be drawn after this function is called. (or in game's draw func)
    mapCam:detach()
    
    local radius = 4
    love.graphics.setColor(100,100,100)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", the.mouse.x, the.mouse.y, radius, 100)
    love.graphics.setLineWidth(1) 
    love.graphics.setColor(255,255,255)
    love.graphics.circle("fill", the.mouse.x, the.mouse.y, radius, 100)
 
    -- Country's name
    local rectW = 150
    local rectH = 25
    local fontHeight = (love.graphics.getFont():getHeight())/2
    love.graphics.setColor(guiColors.bg)
    love.graphics.rectangle("fill", the.screen.width/2-rectW/2, 25-fontHeight, rectW, rectH)
    love.graphics.setColor(guiColors.fg)
    love.graphics.rectangle("line", the.screen.width/2-rectW/2, 25-fontHeight, rectW, rectH)
end
