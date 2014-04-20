require "objects.countries"

mapNewGame = false

map = {}
mapW = 300
mapH = 130
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
    
    function editMode.pair() pairVertices(editMode.currPolygon) end

                

    -- Camera
    mapCam = Camera(2400/2, 1040/2)

    -- mapImg outside of init function because it might be changed in options before init function gets called.
    gridImg = love.graphics.newImage("assets/image/grid.png")
    gridImg:setWrap("repeat","repeat")
    gridQ = love.graphics.newQuad(0,0,mapImg:getWidth()/2,mapImg:getHeight()/2,gridImg:getWidth(),gridImg:getHeight())
    
    mapCam.scale = 1.5

    mapMouse = {}
    mapMouse.x, mapMouse.y = mapCam:mousepos()

    if not mapNewGame then
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
        local mapX, mapY = mapCam:cameraCoords(mapImg:getWidth()/2, mapImg:getHeight()/2)

        if mapCam.x < (the.screen.width/2/mapCam.scale) then
            mapCam.x = (the.screen.width/2/mapCam.scale)
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

    if not DEBUG then
        if mapCam.scale < 1.5 then
            mapCam.scale = 1.5
        elseif mapCam.scale > 3 then
            mapCam.scale = 3
        end
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
            
        elseif button == "r" then
            if #editMode.currPolygon >= 2 then
                lp.x, lp.y = plp.x, plp.y
                cp.x, cp.y = lp.x, lp.y
                
                table.remove(editMode.currPolygon)
                table.remove(editMode.currPolygon)
            end
        end
        
        for _,region in pairs(map) do
            region:mousereleased(x,y,button)
        end
        
        if button == "l" then
           if not editMode.polFin then
                table.insert(editMode.currPolygon, cp.x)
                table.insert(editMode.currPolygon, cp.y)
            end
        end
            
        editMode.polFin = false
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
        
        local t = pairVertices(editMode.currPolygon)
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

    
    
   -- love.graphics.draw(gridImg,gridQ,0,0)
        
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
end
