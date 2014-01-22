require "objects.countries"
require "assets.intmap"

function initMap()
    local widthLimit = the.screen.width / the.cell.width    -- Width and height limit are used 
    local heightLimit = the.screen.height / the.cell.height -- to limit the generation of cells.

    local tiledMap = require "assets.maps.default.mapData" -- Returns a table created by Tiled.
    mapData = tiledMap.layers[3].data -- tiledMap has lots of unneeded stuff, so we choose the needed data, the map itself.
    
    map = {}
    
    ---------------------------------------------------------------------
    --Code to make tiled maps nested and compatible with drawing system--
    ---------------------------------------------------------------------
    
    local rowNumber = #mapData/100
    for i=1,rowNumber do map[i] = {} end
    
    local columnIndex, rowIndex = 1,1
    
    for i,char in pairs(mapData) do
        map[columnIndex][rowIndex] = char
        rowIndex = rowIndex + 1
        if i % 100 == 0 then
            columnIndex = columnIndex + 1
            rowIndex = 1
        end
    end
    ----------------------------------------------------------------------
    
    mapCam = Camera(the.screen.width/2, the.screen.height/2)
    mapImg = love.graphics.newImage("assets/image/map2.png")
    gridImg = love.graphics.newImage("assets/image/grid.png")
end

function updateMap(dt)
    ---------------------
    --Moving the camera--
    ---------------------
    local cameraSpeed = 200
    
    if the.mouse.x == 799 or love.keyboard.isDown("d") then 
        mapCam.x = mapCam.x + cameraSpeed*dt
    elseif the.mouse.x == 0 or love.keyboard.isDown("a") then
        mapCam.x = mapCam.x - cameraSpeed*dt
    end
    
    if the.mouse.y == 575 or love.keyboard.isDown("s") then 
        mapCam.y = mapCam.y + cameraSpeed*dt
    elseif the.mouse.y == 0 or love.keyboard.isDown("w") then
        mapCam.y = mapCam.y - cameraSpeed*dt
    end
    
    
    -------------------------
    --Limiting the movement--
    -------------------------
    if mapCam.x < 400/mapCam.scale then 
        mapCam.x = 400/mapCam.scale
    elseif mapCam.x > 400*mapCam.scale then 
        mapCam.x = 400*mapCam.scale
    end
    
    if mapCam.y < 288/mapCam.scale then 
        mapCam.y = 288/mapCam.scale 
    elseif mapCam.y > 288*mapCam.scale then 
        mapCam.y = 288*mapCam.scale 
    end

    -----------------
    --Lımiting zoom--
    -----------------
    if mapCam.scale < 1 then
        mapCam.scale = 1
    elseif mapCam.scale > 2.5 then
        mapCam.scale = 2.5
    end
end

function mousepressedMap(x, y, button)
    if button == "wu" then
        Timer.tween(0.3, mapCam, {scale = mapCam.scale + 0.1}, "out-quad")
    elseif button == "wd" then
        if mapCam.scale > 1 then
            Timer.tween(0.3, mapCam, {scale = mapCam.scale - 0.1}, "out-quad")
        end
    end
end

function drawMap()
    mapCam:attach()
    
    love.graphics.draw(mapImg, 0,0)
    love.graphics.draw(gridImg, 0,0)
    
    for columnIndex,column in pairs(map) do
        for rowIndex,row in pairs(column) do
            for _,country in pairs(countries) do
            
                local x = (rowIndex-1)*the.cell.width
                local y = (columnIndex-1)*the.cell.height
            
                if row == country.id then
                    country:draw(x, y)
                end
                
                if checkCollision(x, y, the.cell.width, the.cell.height, the.mouse.x, the.mouse.y, 1,1) then
                    love.graphics.setColor(255,255,255)
                    love.graphics.rectangle("line", x, y, the.cell.width, the.cell.height)
                end
            end
            
        end
    end
    
    mapCam:detach()
end
